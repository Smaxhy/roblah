--[[
	THE LIVE WORLD (BitLeveling): Gates that open in a real 3D city on the server, in real
	time, for everyone on it at once. Players walk that city as their own R6 character.

	The same Engine/HunterWorld code that runs a life's years runs these incidents, on a clock:
	a Gate appears at one of the city's sites, people notice it (or don't), police tape it off,
	the Association's measurement team arrives, a raid goes in, and it's cleared or it breaks.
	A break lets real monsters out into the streets; civilians flee, freeze, shelter or film;
	Hunters fight. A player who is there can respond: that puts the incident into their life as
	a card. A player whose character is brought down by a monster takes the injury in their life.

	Multiple incidents can run at once (Config.hunterLive.maxIncidents). Everything is decided
	on the server; clients only draw it (client/HunterLive.luau) and ask (handlers below).

	Handlers (Request remote): hwLive, hwBoard, hwWalk, hwRespond, hwHelp, hwPickup,
	                           r6Get, r6Save, r6Hair
	Remote event Remotes.HunterLive: server -> client { incidents }, { fx }, { walk }
	                                 client -> server "attack"
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local Map = require(script:WaitForChild("Map"))
local Npcs = require(script:WaitForChild("Npcs"))

local HunterLive = {}

local DAY = 9 -- seconds of real time for a day of a Gate's life
local RANK_HP = { [0] = 100, 160, 260, 420, 700, 1100, 2000 }
local RANK_SPEED = { [0] = 16, 18, 19, 20, 22, 24, 28 }
local RANK_DMG = { 14, 26, 50, 95, 170, 380 }
local CRYSTAL_PAY = { 1, 2, 4, 9, 20, 60 } -- million won a crystal, by the monster's rank

function HunterLive.install(S)
	local Content = S.Content
	if not Content.hunterWorld then
		return
	end
	local sim = S.sim
	local HW = S.Engine.HunterWorld
	local cfg = HW.config(Content)
	local liveCfg = (S.Config and S.Config.hunterLive) or {}
	if liveCfg.enabled == false then
		return
	end
	local Shared = ReplicatedStorage:WaitForChild("LifeSim")
	local hunter = Shared:WaitForChild("Hunter")
	local Looks = require(hunter:WaitForChild("Looks"))
	local R6Rig = require(hunter:WaitForChild("R6Rig"))

	local remotes = Shared:WaitForChild("Remotes")
	local event = Instance.new("RemoteEvent")
	event.Name = "HunterLive"
	event.Parent = remotes

	-- the city and its people
	local world = Instance.new("Folder")
	world.Name = "BitLevelingLive"
	world.Parent = Workspace
	Map.build(world)
	Npcs.init(world)
	Npcs.spawnCivilians(liveCfg.civilians or 24, Map.waypoints)
	local hairCache = ReplicatedStorage:FindFirstChild("HunterHairCache") or Instance.new("Folder")
	hairCache.Name = "HunterHairCache"
	hairCache.Parent = ReplicatedStorage
	local crystals = Instance.new("Folder")
	crystals.Name = "Crystals"
	crystals.Parent = world

	-- ── hair accessories (Roblox's own, loaded once, kept for previews) ──
	local loading = {}
	local function ensureHair(id: number): Instance?
		if type(id) ~= "number" or id <= 0 or not Looks.find("HAIR", id) then
			return nil
		end
		local have = hairCache:FindFirstChild(tostring(id))
		if have then
			return have
		end
		if loading[id] then
			return nil
		end
		loading[id] = true
		local ok, model = pcall(function()
			return InsertService:LoadAsset(id)
		end)
		loading[id] = nil
		if not ok or not model then
			return nil
		end
		local acc = model:FindFirstChildWhichIsA("Accessory", true)
		if acc then
			acc.Name = tostring(id)
			acc.Parent = hairCache
		end
		model:Destroy()
		return acc
	end

	-- ── the player's R6 look (saved with their profile) ──
	local function lookOf(session: any): any
		local data = session.profile.Data
		if type(data.r6) ~= "table" then
			data.r6 = Looks.clean(nil)
		end
		return data.r6
	end
	local function lifeOf(session: any): any
		local life = session and session.profile.Data.life
		return if life and life.alive then life else nil
	end
	local function rankOf(session: any): number
		local life = lifeOf(session)
		return if life then HW.playerRank(sim, life) else 0
	end

	-- the world everyone shares is as dangerous as the most dangerous life on it
	local function worldMode(): (string, any)
		for _, session in S.sessions do
			local life = lifeOf(session)
			if life and HW.modeOf(sim, life) == "crisis" then
				return "crisis", cfg.modes.crisis
			end
		end
		return "normal", cfg.modes.normal
	end

	-- ── incidents ──
	local incidents: { any } = {}
	local serial = 0
	local live = { rng = S.Engine.Rng.seed(os.time()) }
	local cityDistrict = { name = liveCfg.cityName or "the city", city = liveCfg.cityName or "the city", country = liveCfg.country or "korea", population = 1, hunters = 1, places = {} }

	local function snapshot(inc: any): any
		return {
			id = inc.id, rank = inc.readRank, trueRank = inc.rank, kind = inc.kind, stage = inc.stage,
			pos = { inc.pos.X, inc.pos.Y, inc.pos.Z }, label = inc.label, red = inc.red == true,
			broke = inc.broke == true, closing = inc.closing == true, sealed = inc.sealed == true,
			monsters = inc.monstersLeft or 0, startedAt = inc.wallStart, outcome = inc.outcome,
			police = inc.police == true, assoc = inc.assoc == true, raid = inc.raidSent == true, inside = inc.inside == true,
			headline = inc.headline,
		}
	end
	local function broadcast()
		local list = {}
		for _, inc in incidents do
			table.insert(list, snapshot(inc))
		end
		event:FireAllClients({ incidents = list })
	end
	local function fx(kind: string, data: any)
		data.fx = kind
		event:FireAllClients(data)
	end

	local function toastAll(text: string, onlyWalking: boolean?)
		for player, session in S.sessions do
			if not onlyWalking or (player.Character and player.Character:GetAttribute("HunterLive")) then
				S.pushTo(player, { toast = text })
			end
		end
	end

	local function newsToScreen()
		if not Map.screen then
			return
		end
		local lines = {}
		for i = #incidents, math.max(1, #incidents - 3), -1 do
			local inc = incidents[i]
			table.insert(lines, "• " .. (inc.headline or ("A " .. HW.rankWord(inc.readRank) .. " Gate at " .. inc.label .. ".")))
		end
		Map.screen.Text = if #lines > 0 then table.concat(lines, "\n") else "No incidents reported. Gate alerts are on."
	end

	local function stage(inc: any, name: string, text: string?)
		inc.stage = name
		if text then
			inc.headline = text
		end
		broadcast()
		newsToScreen()
	end

	local function spawnIncident(force: any?)
		local modeId, mode = worldMode()
		local site = (force and force.site) or Map.sites[math.random(1, #Map.sites)]
		-- no two Gates on one spot
		for _, other in incidents do
			if other.site == site then
				return nil
			end
		end
		local inc = HW.spawn(live, { cfg = cfg, mode = mode, year = 10, district = cityDistrict, districtId = "live", place = site.kind, rank = force and force.rank, kind = force and force.kind })
		inc.placeName = site.label
		HW.lifecycle(live, inc, { mode = mode, breakDays = cfg.breakDays, capacity = HW.capacityFor(cfg, mode, cityDistrict, #incidents * 2) })
		serial += 1
		inc.id = serial
		inc.site = site
		inc.pos = site.pos
		inc.label = site.label
		inc.mode = modeId
		inc.t0 = os.clock()
		inc.wallStart = os.time()
		inc.responded = {}
		inc.helped = {}
		inc.responders = {}
		inc.monsters = {}
		inc.monstersLeft = 0
		inc.stage = "appeared"
		-- the clock, from the engine's days (compressed for watching)
		local found = math.min((inc.foundDay or 0) * DAY, 25)
		inc.at = {
			discovered = if inc.unseen then nil else found + 2,
			police = if inc.unseen then nil else found + 10,
			assoc = if inc.unseen then nil else found + 18,
			raid = if inc.raidDay and not inc.late then found + 30 else nil,
			breakAt = if inc.broke then math.min(70, (inc.breakDays or 7) * DAY) + (if inc.unseen then 0 else found) else nil,
		}
		table.insert(incidents, inc)
		local rw = HW.rankWord(inc.readRank)
		stage(inc, "appeared", string.format("A Gate has opened at %s.", inc.label))
		fx("gateOpen", { id = inc.id })
		Npcs.react(inc.pos, if inc.urban then 140 else 90, Map.shelters, Map.waypoints)
		toastAll(string.format("LIVE: A Gate has opened at %s (%s reading pending).", inc.label, rw), true)
		return inc
	end

	-- a life hears about it (the walking players are there: it's in their news)
	local function lifeNews(inc: any, text: string, tone: string?)
		for player, session in S.sessions do
			local life = lifeOf(session)
			local ch = player.Character
			if life and ch and ch:GetAttribute("HunterLive") then
				HW.addNews(life, "live", text, tone or "plain")
			end
		end
	end

	local function endIncident(inc: any)
		for _, r in inc.responders do
			Npcs.removeResponder(r)
		end
		for _, m in table.clone(inc.monsters) do
			Npcs.removeMonster(m)
		end
		local i = table.find(incidents, inc)
		if i then
			table.remove(incidents, i)
		end
		fx("gateClose", { id = inc.id })
		broadcast()
		newsToScreen()
		Npcs.calm()
	end

	local function ring(inc: any, radius: number, n: number, k: number): Vector3
		local a = (k / n) * math.pi * 2
		return inc.pos + Vector3.new(math.cos(a) * radius, 0.7, math.sin(a) * radius)
	end

	local function tick(inc: any, now: number)
		local t = now - inc.t0
		local A = inc.at
		if A.discovered and t >= A.discovered and inc.stage == "appeared" then
			stage(inc, "discovered", string.format("Gate at %s: police are on their way.", inc.label))
			fx("siren", { id = inc.id, on = true })
		end
		if A.police and t >= A.police and not inc.police then
			inc.police = true
			for k = 1, 3 do
				local r = Npcs.responder("police", ring(inc, 26, 3, k), inc.pos)
				table.insert(inc.responders, r)
			end
			fx("cordon", { id = inc.id, radius = 24 })
			stage(inc, "response", string.format("Cordon up at %s. The Association's measurement team is coming.", inc.label))
		end
		if A.assoc and t >= A.assoc and not inc.assoc then
			inc.assoc = true
			for k = 1, 2 do
				local r = Npcs.responder("staff", ring(inc, 18, 4, k + 0.5), inc.pos)
				table.insert(inc.responders, r)
			end
			local text = string.format("%s reading at %s. Raid rights are being assigned.", string.upper(string.sub(HW.rankWord(inc.readRank), 1, 1)) .. string.sub(HW.rankWord(inc.readRank), 2), inc.label)
			stage(inc, "response", text)
			lifeNews(inc, string.format("LIVE: %s Gate at %s.", HW.rankWord(inc.readRank), inc.label), if inc.readRank >= 4 then "danger" else "plain")
		end
		if A.raid and t >= A.raid and not inc.raidSent then
			inc.raidSent = true
			local n = math.clamp(3 + math.floor(inc.readRank / 2), 3, 6)
			inc.raiders = {}
			for k = 1, n do
				local r = Npcs.responder("hunter", ring(inc, 40, n, k), inc.pos)
				table.insert(inc.responders, r)
				table.insert(inc.raiders, r)
				r.hum:MoveTo(inc.pos)
			end
			stage(inc, "active", string.format("A raid team is going into the %s Gate at %s.", HW.rankWord(inc.readRank), inc.label))
			inc.enterAt = t + 8
		end
		-- the raid goes in: the Hunters vanish into the Gate
		if inc.enterAt and t >= inc.enterAt and not inc.inside then
			inc.inside = true
			for _, r in inc.raiders or {} do
				fx("enter", { id = inc.id, at = { r.model.PrimaryPart.Position.X, r.model.PrimaryPart.Position.Y, r.model.PrimaryPart.Position.Z } })
				r.model.Parent = nil
			end
			if inc.kind == "red" then
				inc.red = true
				inc.sealed = true
				stage(inc, "active", string.format("The Gate at %s has turned RED. The raid team is sealed inside.", inc.label))
				fx("redGate", { id = inc.id })
				lifeNews(inc, string.format("LIVE: A Red Gate at %s. The raid is sealed inside.", inc.label), "strange")
				toastAll(string.format("The Gate at %s has turned red.", inc.label))
			end
			inc.resolveAt = t + (if inc.kind == "red" then 70 elseif inc.kind == "double" then 55 else 40)
		end
		-- inside: cleared (or the red/double story ends)
		if inc.resolveAt and t >= inc.resolveAt and not inc.resolved and not inc.broke then
			inc.resolved = true
			local back = #(inc.raiders or {})
			if inc.outcome == "red_lost" or inc.outcome == "double_lost" then
				back = 0
			elseif inc.outcome == "red_survivors" or inc.outcome == "double_survivors" then
				back = math.max(1, math.floor(back / 2))
			end
			for k, r in inc.raiders or {} do
				if k <= back then
					r.model.Parent = Npcs.folder
					r.model:PivotTo(CFrame.new(inc.pos + Vector3.new(k * 3 - 6, 3, 6)))
				end
			end
			inc.red = false
			inc.sealed = false
			inc.closing = true
			inc.closeAt = t + 14
			local text = HW.headline(inc, cfg)
			stage(inc, "resolved", text)
			lifeNews(inc, "LIVE: " .. text, if back == 0 then "strange" else "good")
		end
		-- the break
		if A.breakAt and t >= A.breakAt and not inc.broken then
			inc.broken = true
			local count = ({ 7, 6, 5, 4, 3, 2 })[inc.rank]
			if inc.outcome == "break_spread" then
				count += 2
			elseif inc.outcome == "zone_lost" then
				count += 4
			end
			for _ = 1, count do
				local m = Npcs.spawnMonster(inc.rank, inc.pos, inc.id)
				table.insert(inc.monsters, m)
			end
			inc.monstersLeft = count
			stage(inc, "escalated", string.format("DUNGEON BREAK at %s: %s monsters are in the streets.", inc.label, HW.rankWord(inc.rank)))
			fx("break", { id = inc.id })
			fx("siren", { id = inc.id, on = true })
			Npcs.react(inc.pos, 220, Map.shelters, Map.waypoints)
			toastAll(string.format("DUNGEON BREAK at %s. Get to shelter.", inc.label))
			lifeNews(inc, string.format("LIVE: Dungeon Break at %s (%s).", inc.label, HW.rankWord(inc.rank)), "danger")
			-- the Association sends Hunters to contain it (later, in a stretched world)
			local _, mode = worldMode()
			inc.reliefAt = t + 18 / math.max(0.3, mode.capacity or 1)
			inc.breakEnd = t + (if inc.outcome == "zone_lost" then 200 elseif inc.outcome == "break_spread" then 140 else 95)
		end
		if inc.reliefAt and t >= inc.reliefAt and not inc.relief then
			inc.relief = true
			local n = math.clamp(2 + inc.rank, 3, 7)
			for k = 1, n do
				local r = Npcs.responder("hunter", ring(inc, 70, n, k), inc.pos)
				r.fighter = true
				table.insert(inc.responders, r)
			end
			stage(inc, "escalated", string.format("Hunters have arrived at the break at %s.", inc.label))
		end
		if inc.broken then
			local alive = 0
			for _, m in table.clone(inc.monsters) do
				if m.hum.Health <= 0 or not m.model.Parent then
					local i = table.find(inc.monsters, m)
					if i then
						table.remove(inc.monsters, i)
					end
					local pos = m.model.PrimaryPart and m.model.PrimaryPart.Position
					if pos then
						fx("kill", { at = { pos.X, pos.Y, pos.Z }, rank = m.rank })
						-- a mana crystal where it fell (canon: monsters carry them)
						local c = Instance.new("Part")
						c.Name = "ManaCrystal"
						c.Anchored = true
						c.CanCollide = false
						c.Size = Vector3.new(0.8, 1.4, 0.8)
						c.Material = Enum.Material.Neon
						c.Color = Color3.fromRGB(110, 180, 255)
						c.CFrame = CFrame.new(Vector3.new(pos.X, 1.4, pos.Z)) * CFrame.Angles(0, math.rad(45), math.rad(20))
						c:SetAttribute("Rank", m.rank)
						c:SetAttribute("Expires", os.clock() + 90)
						local prompt = Instance.new("ProximityPrompt")
						prompt.ActionText = "Collect"
						prompt.ObjectText = "Mana crystal"
						prompt.HoldDuration = 0.4
						prompt.MaxActivationDistance = 8
						prompt.Parent = c
						c.Parent = crystals
					end
					task.delay(0.6, function()
						Npcs.removeMonster(m)
					end)
				else
					alive += 1
				end
			end
			inc.monstersLeft = alive
			if (alive == 0 and inc.relief) or t >= (inc.breakEnd or math.huge) then
				for _, m in table.clone(inc.monsters) do
					Npcs.removeMonster(m)
				end
				inc.monsters = {}
				inc.monstersLeft = 0
				inc.closing = true
				inc.closeAt = t + 10
				inc.broken = false
				inc.at.breakAt = nil
				local text = HW.headline(inc, cfg)
				stage(inc, "aftermath", text)
				lifeNews(inc, "LIVE: " .. text, "danger")
				fx("siren", { id = inc.id, on = false })
			end
		end
		if inc.closeAt and t >= inc.closeAt then
			fx("siren", { id = inc.id, on = false })
			endIncident(inc)
		end
		-- a Gate nobody ever finds and that never breaks (shouldn't happen) still ends
		if t > 420 then
			endIncident(inc)
		end
	end

	-- Hunters (NPC) fight the monsters out in the street
	local function stepResponders(now: number)
		for _, r in Npcs.responders do
			if r.kind == "hunter" and r.fighter and r.model.Parent and r.hum.Health > 0 then
				local root = r.model.PrimaryPart
				local best, bd = nil, 160
				for _, m in Npcs.monsters do
					local mr = m.model.PrimaryPart
					if mr and m.hum.Health > 0 then
						local d = (mr.Position - root.Position).Magnitude
						if d < bd then
							best, bd = m, d
						end
					end
				end
				if best then
					r.hum:MoveTo(best.model.PrimaryPart.Position)
					if bd < 8 and now > r.cool then
						r.cool = now + 0.9
						best.hum:TakeDamage(RANK_DMG[math.clamp(best.rank, 1, 6)] * 0.8)
						local a, b = root.Position, best.model.PrimaryPart.Position
						fx("slash", { from = { a.X, a.Y, a.Z }, to = { b.X, b.Y, b.Z }, rank = best.rank })
					end
				end
			end
		end
	end

	-- ── players in the city ──
	local walking: { [Player]: any } = {}
	local function injure(player: Player, session: any, rank: number, label: string)
		local life = lifeOf(session)
		if not life or life.pending then
			return
		end
		local prank = HW.playerRank(sim, life)
		local base = ({ { 6, 14 }, { 11, 26 }, { 20, 44 }, { 34, 75 }, { 60, 130 }, { 110, 240 } })[math.clamp(rank, 1, 6)]
		local f = 0.5 / (1 + prank * 0.3)
		local report = sim.newReport and sim.newReport() or { entries = {} }
		local result = {
			vitality = { -math.floor(base[2] * f), -math.max(1, math.floor(base[1] * f)) },
			sanity = -4,
			log = string.format("You were caught in the Dungeon Break at %s and brought down in the street. Paramedics got to you.", label),
			cause = "Killed in a Dungeon Break in the street",
		}
		sim:applyResult(life, result, report)
		HW.addHistory(life, { kind = "break", rank = rank, place = label, role = "caught", live = true, alive = life.alive })
		S.pushTo(player, S.lifeResponse(session, report))
	end

	local function spawnCharacter(player: Player, session: any)
		local old = player.Character
		if old then
			old:Destroy()
		end
		local look = lookOf(session)
		local hair = nil
		local tpl = ensureHair(look.hair)
		if tpl then
			hair = tpl:Clone()
		end
		local model = R6Rig.build(look, { name = player.Name, hair = hair })
		local prank = rankOf(session)
		local hum = model:FindFirstChildOfClass("Humanoid") :: Humanoid
		hum.MaxHealth = RANK_HP[prank]
		hum.Health = hum.MaxHealth
		hum.WalkSpeed = RANK_SPEED[prank]
		hum.JumpPower = 50 + prank * 6
		hum.DisplayName = player.DisplayName .. (if prank > 0 then " [" .. HW.rankLetter(prank) .. "-rank]" else "")
		model:SetAttribute("HunterLive", true)
		model:SetAttribute("Rank", prank)
		local spot = Map.spawns[math.random(1, math.max(1, #Map.spawns))] or Vector3.new(0, 4, 0)
		model:PivotTo(CFrame.new(spot + Vector3.new(math.random(-6, 6), 0, math.random(-6, 6))))
		model.Parent = Workspace
		player.Character = model
		pcall(function()
			(model.PrimaryPart :: BasePart):SetNetworkOwner(player)
		end)
		hum.Died:Connect(function()
			local by = model:GetAttribute("LastHitRank")
			if by then
				injure(player, session, by, tostring(model:GetAttribute("LastHitAt") or "the street"))
			end
			task.delay(4, function()
				if walking[player] and player.Parent then
					spawnCharacter(player, session)
				end
			end)
		end)
		walking[player] = { at = os.clock(), lastAttack = 0, picked = 0 }
		return model
	end

	local function stopWalking(player: Player)
		walking[player] = nil
		local ch = player.Character
		if ch and ch:GetAttribute("HunterLive") then
			ch:Destroy()
		end
		player.Character = nil
	end

	-- what a monster's hit does
	local function onHit(m: any, kind: string, victim: any)
		local pos = m.model.PrimaryPart.Position
		if kind == "player" then
			local ch = victim.Character
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			if h then
				local inc = nil
				for _, i in incidents do
					if i.id == m.incident then
						inc = i
					end
				end
				ch:SetAttribute("LastHitRank", m.rank)
				ch:SetAttribute("LastHitAt", inc and inc.label or "the street")
				h:TakeDamage(m.def.dmg)
				local hp = (ch.HumanoidRootPart :: BasePart).Position
				fx("hit", { from = { pos.X, pos.Y, pos.Z }, to = { hp.X, hp.Y, hp.Z }, rank = m.rank, player = victim.UserId })
			end
		elseif kind == "responder" then
			victim.hum:TakeDamage(m.def.dmg * 0.5)
			local rp = victim.model.PrimaryPart.Position
			fx("hit", { from = { pos.X, pos.Y, pos.Z }, to = { rp.X, rp.Y, rp.Z }, rank = m.rank })
		elseif kind == "civilian" then
			Npcs.knockDown(victim)
			local cp = victim.model.PrimaryPart.Position
			fx("hit", { from = { pos.X, pos.Y, pos.Z }, to = { cp.X, cp.Y, cp.Z }, rank = m.rank })
		end
	end

	-- a Hunter player's attack (client asks; server decides)
	event.OnServerEvent:Connect(function(player: Player, action: any, data: any)
		local w = walking[player]
		local session = S.sessions[player]
		if not w or not session or action ~= "attack" then
			return
		end
		local now = os.clock()
		if now - w.lastAttack < 0.42 then
			return
		end
		w.lastAttack = now
		local prank = rankOf(session)
		if prank <= 0 then
			return
		end
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		local h = ch and ch:FindFirstChildOfClass("Humanoid")
		if not root or not h or h.Health <= 0 then
			return
		end
		local life = lifeOf(session)
		local str = (life and life.stats.strength) or 10
		local dmg = RANK_DMG[prank] * (1 + str / 200)
		local look = root.CFrame.LookVector
		local hitAny = false
		for _, m in table.clone(Npcs.monsters) do
			local mr = m.model.PrimaryPart
			if mr and m.hum.Health > 0 then
				local off = mr.Position - root.Position
				local reach = 9 + m.def.size * 2
				if off.Magnitude < reach and (off.Magnitude < 3 or look:Dot(off.Unit) > 0.25) then
					m.hum:TakeDamage(dmg)
					hitAny = true
					if m.hum.Health <= 0 and life then
						HW.addHistory(life, { kind = "break", rank = m.rank, role = "fought", won = true, live = true, alive = true })
					end
				end
			end
		end
		local a = root.Position + look * 4
		fx("swing", { at = { a.X, a.Y, a.Z }, dir = { look.X, look.Y, look.Z }, rank = prank, hit = hitAny, player = player.UserId })
		local _ = data
	end)

	-- picking up a mana crystal
	crystals.DescendantAdded:Connect(function(d)
		if d:IsA("ProximityPrompt") then
			d.Triggered:Connect(function(player: Player)
				local c = d.Parent :: BasePart
				local session = S.sessions[player]
				local life = lifeOf(session)
				if not c or not c.Parent or not life or not walking[player] then
					return
				end
				local ch = player.Character
				local root = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
				if not root or (root.Position - c.Position).Magnitude > 12 then
					return
				end
				local rank = c:GetAttribute("Rank") or 1
				c:Destroy()
				local report = sim.newReport and sim.newReport() or { entries = {} }
				sim:applyResult(life, { money = CRYSTAL_PAY[rank] or 1, log = string.format("You picked up a mana crystal (%s) and sold it to the collection team.", HW.rankWord(rank)) }, report)
				local res = S.lifeResponse(session, report)
				res.toast = string.format("+%d million won: a %s mana crystal", CRYSTAL_PAY[rank] or 1, HW.rankWord(rank))
				S.pushTo(player, res)
			end)
		end
	end)

	-- ── handlers ──
	local handlers = S.handlers
	function handlers.hwLive(_player)
		local list = {}
		for _, inc in incidents do
			table.insert(list, snapshot(inc))
		end
		return { ok = true, incidents = list, walking = walking[_player] ~= nil }
	end
	function handlers.hwBoard(_player, session)
		local life = lifeOf(session) or session.profile.Data.life
		if not life then
			return { ok = true, board = nil }
		end
		return { ok = true, board = HW.view(sim, life) }
	end
	function handlers.hwWalk(player, session, payload)
		local on = type(payload) == "table" and payload.on == true
		if on then
			spawnCharacter(player, session)
			event:FireClient(player, { walk = true })
		else
			stopWalking(player)
			event:FireClient(player, { walk = false })
		end
		return { ok = true, walking = on }
	end
	-- the player steps in: the incident becomes a card in their life
	function handlers.hwRespond(player, session, payload)
		local id = type(payload) == "table" and tonumber(payload.id) or nil
		local inc = nil
		for _, i in incidents do
			if i.id == id then
				inc = i
			end
		end
		local life = lifeOf(session)
		if not inc or not life then
			return { ok = false, error = "That incident is over." }
		end
		if life.pending or life.run or life.battle then
			return { ok = false, error = "Finish what's in front of you first." }
		end
		if inc.responded[player.UserId] then
			return { ok = false, error = "You already answered this one." }
		end
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root or (root.Position - inc.pos).Magnitude > 160 then
			return { ok = false, error = "You're too far away to do anything about it." }
		end
		if life.age < (cfg.minCardAge or 13) then
			return { ok = false, error = "You're too young. Get to an adult and a shelter." }
		end
		local prank = HW.playerRank(sim, life)
		local prefix = if inc.broken then cfg.cards.breakOut elseif inc.red then cfg.cards.red else cfg.cards.cityGate
		local rank = if inc.broken then inc.rank else inc.readRank
		local eventId = prefix .. HW.rankLetter(rank)
		if prank > 0 and sim.eventsById[eventId .. "_h"] then
			eventId ..= "_h"
		end
		if not sim.eventsById[eventId] then
			return { ok = false, error = "Nothing to do here." }
		end
		inc.responded[player.UserId] = true
		local d = sim:districtDef(life)
		local copy = table.clone(inc)
		copy.city = d.city or d.name or "the city"
		copy.district = life.district
		copy.country = d.country or "home"
		HW.queueCard(sim, life, eventId, copy, if prank > 0 then "hunter" else "civilian")
		local report = sim.newReport and sim.newReport() or { entries = {} }
		sim:advance(life, report)
		stopWalking(player)
		event:FireClient(player, { walk = false })
		return S.lifeResponse and S.lifeResponse(session, report) or { ok = true, life = sim:view(life), entries = report.entries }
	end
	-- snap a frozen bystander out of it
	function handlers.hwHelp(player, session)
		local life = lifeOf(session)
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not life or not root then
			return { ok = false, error = "Nobody to help." }
		end
		for _, c in Npcs.civilians do
			local cr = c.model.PrimaryPart
			if cr and c.state == "freeze" and (cr.Position - root.Position).Magnitude < 10 then
				if Npcs.unfreeze(c) then
					local report = sim.newReport and sim.newReport() or { entries = {} }
					sim:applyResult(life, { charisma = 1, sanity = 1, log = "You took a frozen stranger by the arm and got them moving, away from the Gate." }, report)
					local res = S.lifeResponse(session, report)
					res.toast = "You got someone moving. They're running now."
					return res
				end
			end
		end
		return { ok = false, error = "Nobody near you needs help right now." }
	end
	function handlers.r6Get(_player, session)
		return { ok = true, look = lookOf(session) }
	end
	function handlers.r6Save(player, session, payload)
		local look = Looks.clean(type(payload) == "table" and payload.look or nil)
		session.profile.Data.r6 = look
		task.spawn(ensureHair, look.hair)
		-- walking? the new look goes on straight away
		if walking[player] then
			spawnCharacter(player, session)
		end
		return { ok = true, look = look }
	end
	function handlers.r6Hair(_player, _session, payload)
		local id = type(payload) == "table" and tonumber(payload.id) or nil
		if not id then
			return { ok = false }
		end
		local acc = ensureHair(id)
		return { ok = acc ~= nil }
	end
	-- (admins, and anyone in Studio) start a Gate now, to test: { rank = 1..6, kind = "gate" | "red" | "double", breaks = true }
	local Admin = require(script.Parent:WaitForChild("Admin"))
	function handlers.hwAdminSpawn(player, _session, payload)
		if not (Admin.isAdmin and Admin.isAdmin(player)) then
			return { ok = false, error = "Not allowed." }
		end
		payload = if type(payload) == "table" then payload else {}
		local rank = math.clamp(math.floor(tonumber(payload.rank) or math.random(1, 6)), 1, 6)
		local kind = if payload.kind == "red" or payload.kind == "double" then payload.kind else nil
		-- the site nearest the admin's character, if they're walking
		local site = nil
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			local bd = math.huge
			for _, sd in Map.sites do
				local d = (sd.pos - root.Position).Magnitude
				local taken = false
				for _, other in incidents do
					if other.site == sd then
						taken = true
					end
				end
				if d < bd and not taken and d > 30 then
					site, bd = sd, d
				end
			end
		end
		local inc = spawnIncident({ rank = rank, kind = kind, site = site })
		if not inc then
			return { ok = false, error = "Couldn't open one there." }
		end
		if payload.breaks then
			inc.at.breakAt = 20
			inc.at.raid = nil
			inc.broke = true
			inc.outcome = "break_contained"
		end
		print(string.format("[BitLeveling admin] %s opened a %s Gate (%s) at %s", player.Name, HW.rankWord(rank), tostring(kind or "gate"), inc.label))
		return { ok = true, toast = string.format("Opened a %s Gate at %s.", HW.rankWord(rank), inc.label) }
	end

	S.HunterLive = { spawn = spawnIncident, incidents = incidents, sites = Map.sites }

	Players.PlayerRemoving:Connect(function(player)
		walking[player] = nil
	end)

	-- ── the clock ──
	local nextAt = os.clock() + (liveCfg.firstDelay or 45)
	local acc, accNpc = 0, 0
	RunService.Heartbeat:Connect(function(dt)
		acc += dt
		accNpc += dt
		local now = os.clock()
		if accNpc >= 0.25 then
			accNpc = 0
			Npcs.stepCivilians(Map.waypoints)
			Npcs.stepMonsters(onHit)
			stepResponders(now)
			-- walking responders (police, staff) stand their ground
			for _, c in crystals:GetChildren() do
				local e = c:GetAttribute("Expires")
				if e and now > e then
					c:Destroy()
				end
			end
		end
		if acc < 1 then
			return
		end
		acc = 0
		for _, inc in table.clone(incidents) do
			tick(inc, now)
		end
		-- a new Gate, now and then (more often in a High-Danger World)
		if now >= nextAt then
			local modeId = worldMode()
			local lo, hi = liveCfg.every and liveCfg.every[1] or 150, liveCfg.every and liveCfg.every[2] or 320
			if modeId == "crisis" then
				lo, hi = lo * 0.55, hi * 0.55
			end
			nextAt = now + lo + math.random() * (hi - lo)
			if #incidents < (liveCfg.maxIncidents or 2) and #Players:GetPlayers() > 0 then
				spawnIncident()
			end
		end
	end)
end

return HunterLive
