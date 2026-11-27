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
	                           hwSkillBar, r6Get, r6Save, r6Hair
	Remote event Remotes.HunterLive: server -> client { incidents }, { fx }, { walk }, { bar },
	                                                  { cooldown = { slot, left, id }, mana = { cur, max, regen } },
	                                                  { noMana = { slot, need, have } }
	                                 client -> server "attack", "skill" { slot, aim? = { x, y, z } }
	A walking Hunter's character carries Mana, ManaMax, ManaRegen (refreshed every second) and
	Ability<slot>, AbilityId<slot>, Cooldown<slot>, Element<slot> for each slot.

	MOVES (Hunter/Abilities.luau, 250 of them): a skill bar of five slots (Q E R T, G the
	ultimate). The server checks the class, the unlocking skill, the rank against the move's
	tier, the cooldown and the mana (a pool by rank), waits out the cast time (everyone sees it
	gather), then resolves the move by its kind, clamping every reach, and tells everyone to draw it:
		{ fx = "abilityCast", ability, element, tier, player, at, cast, floor }
		{ fx = "ability", ability, element, kind, shape, tier, slot, player (UserId), rank, at, dir, floor,
		  radius?, range?, duration?, to?, from?, target?, targets? (points the effect lands on:
		  the monsters hit, or each projectile's end), healed? / allies? (players it reached),
		  hits, style? (a construct's look) }
		{ fx = "abilityTick", ability, player, at, to?, hit?, targets?, done? }  (constructs
		  moving and striking, a thunderstorm's bolts)
	client/SkillFx draws them.
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
	-- the Blender mesh kit: in the place already, or fetched by its asset id (Hunter/MeshLibrary)
	task.spawn(function()
		local okLib, MeshLibrary = pcall(require, Shared:WaitForChild("Hunter"):WaitForChild("MeshLibrary"))
		if okLib then
			local loaded = MeshLibrary.load()
			print(if loaded then "[BitLeveling] mesh kit ready: monsters, weapons and gear use the Blender meshes" else "[BitLeveling] no mesh kit: monsters, weapons and gear are built from parts")
		end
	end)
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

	-- ── class abilities in the city: a skill bar of five slots, Q E R T and G (Hunter/Abilities) ──
	-- A class's abilities are unlocked by the life's skills (Skills.luau: class trees, magic
	-- schools, Hunter craft); a few basics need nothing. Their power grows with rank, the weapon
	-- in hand (the same scaling the attack uses), the class's main stat, and how many of the
	-- class's (and the school's) skills the life has learned. The server decides every hit.
	local Abilities = require(hunter:WaitForChild("Abilities"))
	local CLASS_STAT = { fighter = "strength", mage = "intelligence", assassin = "agility", tanker = "vitality", ranger = "agility", healer = "willpower" }
	local function classOf(life: any): string?
		for _, id in Abilities.CLASSES do
			if life and life.flags["class_" .. id] then
				return id
			end
		end
		return nil
	end
	local function skillCount(life: any, class: string): number
		local n = 0
		for _, t in life.traits or {} do
			local def = Content.traits and Content.traits[t]
			if def and def.class == class then
				n += 1
			end
		end
		return n
	end
	local function schoolCount(life: any, school: string): number
		local n = 0
		for _, t in life.traits or {} do
			local def = Content.traits and Content.traits[t]
			if def and def.school == school then
				n += 1
			end
		end
		return n
	end
	local function traitSet(life: any): { [string]: boolean }
		local set = {}
		for _, t in (life and life.traits) or {} do
			set[t] = true
		end
		return set
	end
	-- the bar: what the player picked (saved with the profile), or the best unlocked per slot
	local function barOf(session: any, life: any, class: string?): { [string]: string }
		local saved = session and type(session.profile.Data.hlBar) == "table" and session.profile.Data.hlBar or nil
		return Abilities.resolveBar(class, saved, traitSet(life), rankOf(session))
	end
	-- may this class ever see a move (its own; an art of its class; a school or craft move whose skill it can learn)?
	local function visibleTo(ab: any, class: string, set: { [string]: boolean }): boolean
		if ab.class == class then
			return true
		end
		if ab.class ~= "any" or (ab.classes and not table.find(ab.classes, class)) then
			return false
		end
		if ab.unlock == nil or set[ab.unlock] then
			return true
		end
		local def = Content.traits and Content.traits[ab.unlock]
		return def ~= nil and (def.craft == true or (type(def.classes) == "table" and table.find(def.classes, class) ~= nil))
	end
	local function skillName(id: string): string?
		local def = Content.traits and Content.traits[id]
		return def and def.name
	end
	-- what the HUD and the loadout panel show. The client has Hunter/Abilities for every move's
	-- numbers and looks; this says which are in the slots, which are unlocked, and why the
	-- others aren't. { class, rank, slots = { [slot] = id }, unlocked = { id }, locked = { [id] = reason }, mana }
	local function barView(session: any): any
		local life = lifeOf(session)
		local class = classOf(life)
		local rank = rankOf(session)
		if not life or not class or rank <= 0 then
			return { class = nil, rank = rank, slots = {}, unlocked = {}, locked = {} }
		end
		local set = traitSet(life)
		local unlocked, locked = {}, {}
		for _, ab in Abilities.forClass(class) do
			if visibleTo(ab, class, set) then
				local why = Abilities.lockReason(ab, class, set, rank, skillName)
				if why then
					locked[ab.id] = why
				else
					table.insert(unlocked, ab.id)
				end
			end
		end
		return { class = class, rank = rank, slots = barOf(session, life, class), unlocked = unlocked, locked = locked, learned = skillCount(life, class) }
	end
	-- the bar on the character too (attributes: Ability<slot>, AbilityId<slot>, Cooldown<slot>, Element<slot>)
	local function setBarAttributes(model: Instance?, session: any, life: any, class: string?)
		if not model then
			return
		end
		local bar = if class then barOf(session, life, class) else {}
		for _, slot in Abilities.SLOTS do
			local ab = bar[slot] and Abilities.byId[bar[slot]]
			model:SetAttribute("Ability" .. slot, if ab then ab.name else nil)
			model:SetAttribute("AbilityId" .. slot, if ab then ab.id else nil)
			model:SetAttribute("Cooldown" .. slot, if ab then ab.cd else nil)
			model:SetAttribute("Element" .. slot, if ab then ab.element else nil)
		end
	end
	-- guards (damage taken x for a while: shields, braces), buffs, cooldowns and mana (per
	-- player, so stepping out of the city and back never resets them), and who a monster must chase
	local guardUntil: { [Player]: number } = {}
	local guardMult: { [Player]: number } = {}
	local buffs: { [Player]: any } = {}
	local cools: { [Player]: { [string]: number } } = {}
	local manas: { [Player]: { cur: number, max: number, regen: number, t: number } } = {}
	local provoked: { [any]: { player: Player, untilT: number } } = setmetatable({}, { __mode = "k" }) :: any
	local function guardOf(player: Player): number
		return if (guardUntil[player] or 0) > os.clock() then (guardMult[player] or 0.45) else 1
	end
	local function addGuard(player: Player, mult: number, seconds: number)
		local now = os.clock()
		local active = (guardUntil[player] or 0) > now
		local old = guardMult[player] or 1
		-- a stronger guard already up stays; a weaker or expired one is replaced
		if not active or mult < old then
			guardMult[player] = mult
			guardUntil[player] = now + seconds
		elseif mult == old then
			guardUntil[player] = math.max(guardUntil[player] or 0, now + seconds)
		end
	end
	-- a Hunter's mana: the pool grows with rank (and Intelligence and Willpower), and refills
	local function manaOf(player: Player, session: any): any
		local life = lifeOf(session)
		local rank = rankOf(session)
		local max, regen = Abilities.manaPool(math.max(1, rank), life and life.stats.intelligence or 0, life and life.stats.willpower or 0)
		local m = manas[player]
		local now = os.clock()
		if not m then
			m = { cur = max, max = max, regen = regen, t = now }
			manas[player] = m
		end
		m.cur = math.min(max, m.cur + (now - m.t) * m.regen)
		m.max, m.regen, m.t = max, regen, now
		return m
	end
	local function showMana(player: Player, session: any)
		local ch = player.Character
		if ch and ch:GetAttribute("HunterLive") then
			local m = manaOf(player, session)
			ch:SetAttribute("Mana", math.floor(m.cur))
			ch:SetAttribute("ManaMax", m.max)
			ch:SetAttribute("ManaRegen", math.floor(m.regen * 10) / 10)
		end
	end
	local function dmgBuffOf(player: Player): number
		local b = buffs[player]
		return if b and (b.dmgUntil or 0) > os.clock() then (b.dmg or 1) else 1
	end
	local function weaponMult(life: any): number
		local Weapons = HW.weapons()
		if life and Weapons then
			local base, stars, shiny = Weapons.parse(life.gear and life.gear.weapon)
			if base then
				return 1 + Weapons.power(base, stars, shiny) / 12
			end
		end
		return 1
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
			broke = inc.breakOut == true, closing = inc.closing == true, sealed = inc.sealed == true,
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
			inc.breakOut = true -- what the street sees (inc.broke is the engine's plan)
			local count = ({ 7, 6, 5, 4, 3, 2 })[inc.rank]
			if inc.outcome == "break_spread" then
				count += 2
			elseif inc.outcome == "zone_lost" then
				count += 4
			end
			-- one or two kinds of monster come out of a Gate (its own dungeon's kinds)
			local kinds = Npcs.Monsters.KINDS[math.clamp(inc.rank, 1, 6)]
			local a = kinds[math.random(1, #kinds)]
			local b = kinds[math.random(1, #kinds)]
			for k = 1, count do
				local m = Npcs.spawnMonster(inc.rank, inc.pos, inc.id, if k % 3 == 0 then b else a)
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
						-- now and then, a weapon where it fell (better the higher the rank)
						if math.random() < 0.035 + m.rank * 0.01 then
							local box = Instance.new("Part")
							box.Name = "WeaponCache"
							box.Anchored = true
							box.CanCollide = false
							box.Size = Vector3.new(1.6, 1, 1)
							box.Material = Enum.Material.Metal
							box.Color = Color3.fromRGB(70, 60, 50)
							box.CFrame = CFrame.new(Vector3.new(pos.X + 2, 1.2, pos.Z))
							box:SetAttribute("Rank", m.rank)
							box:SetAttribute("Weapon", true)
							box:SetAttribute("Expires", os.clock() + 120)
							local glow = Instance.new("PointLight")
							glow.Color = Color3.fromRGB(255, 210, 120)
							glow.Range = 10
							glow.Parent = box
							local pp = Instance.new("ProximityPrompt")
							pp.ActionText = "Open"
							pp.ObjectText = "Weapon cache"
							pp.HoldDuration = 0.8
							pp.MaxActivationDistance = 8
							pp.Parent = box
							box.Parent = crystals
						end
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

	Npcs.provoked = provoked
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
		-- the life's own weapon, at its rarity, replaces the look's
		local item = nil
		local life = lifeOf(session)
		local Weapons = HW.weapons()
		if life and Weapons then
			local base, stars, shiny = Weapons.parse(life.gear and life.gear.weapon)
			if base then
				item = { base = base, stars = stars, shiny = shiny }
			end
		end
		local prank = rankOf(session)
		local model = R6Rig.build(look, { name = player.Name, hair = hair, weapon = item, rank = prank })
		local hum = model:FindFirstChildOfClass("Humanoid") :: Humanoid
		hum.MaxHealth = RANK_HP[prank]
		hum.Health = hum.MaxHealth
		hum.WalkSpeed = RANK_SPEED[prank]
		hum.JumpPower = 50 + prank * 6
		hum.DisplayName = player.DisplayName .. (if prank > 0 then " [" .. HW.rankLetter(prank) .. "-rank]" else "")
		model:SetAttribute("HunterLive", true)
		model:SetAttribute("Rank", prank)
		local cls = classOf(life)
		if cls and prank > 0 then
			model:SetAttribute("Class", cls)
			setBarAttributes(model, session, life, cls)
		end
		local spot = Map.spawns[math.random(1, math.max(1, #Map.spawns))] or Vector3.new(0, 4, 0)
		model:PivotTo(CFrame.new(spot + Vector3.new(math.random(-6, 6), 1, math.random(-6, 6))))
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
		-- the skill bar for the HUD (and the loadout panel)
		event:FireClient(player, { bar = barView(session) })
		showMana(player, session)
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
		m.model:SetAttribute("Attacking", (m.model:GetAttribute("Attacking") or 0) + 1) -- the client swings the limb (client/MonsterAnim)
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
				h:TakeDamage(m.def.dmg * guardOf(victim) * (if (m.weakUntil or 0) > os.clock() then (m.weakMult or 1) else 1))
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

	-- ── abilities, resolved on the server (Hunter/Abilities.KINDS says what each kind does) ──
	local function v3t(v: Vector3): { number }
		return { math.floor(v.X * 100 + 0.5) / 100, math.floor(v.Y * 100 + 0.5) / 100, math.floor(v.Z * 100 + 0.5) / 100 }
	end
	local function flat(v: Vector3): Vector3
		local f = Vector3.new(v.X, 0, v.Z)
		return if f.Magnitude > 1e-3 then f.Unit else Vector3.new(0, 0, -1)
	end
	local function monsterPos(m: any): Vector3?
		local mr = m.model and m.model.PrimaryPart
		return if mr and m.hum.Health > 0 then mr.Position else nil
	end
	-- monsters within a radius of a point (flat distance, with some height for flyers)
	local function monstersIn(center: Vector3, radius: number): { any }
		local out = {}
		for _, m in Npcs.monsters do
			local mp = monsterPos(m)
			if mp then
				local off = mp - center
				if Vector3.new(off.X, 0, off.Z).Magnitude < radius + m.def.size * 2 and math.abs(off.Y) < radius + 10 then
					table.insert(out, m)
				end
			end
		end
		return out
	end
	-- the nearest monster ahead (within a cone), or nil
	local function nearestAhead(pos: Vector3, look: Vector3, range: number, dot: number, skip: { [any]: boolean }?): any
		local best, bd = nil, math.huge
		for _, m in Npcs.monsters do
			local mp = monsterPos(m)
			if mp and not (skip and skip[m]) then
				local off = mp - pos
				local d = off.Magnitude
				if d < range + m.def.size * 2 and d < bd and (d < 4 or look:Dot(flat(off)) > dot) then
					best, bd = m, d
				end
			end
		end
		return best
	end
	-- monsters along a line from pos (within width of it)
	local function along(pos: Vector3, dir: Vector3, length: number, width: number): { any }
		local out = {}
		for _, m in Npcs.monsters do
			local mp = monsterPos(m)
			if mp then
				local rel = Vector3.new(mp.X - pos.X, 0, mp.Z - pos.Z)
				local t = rel:Dot(dir)
				if t > -2 and t < length + m.def.size * 2 and (rel - dir * t).Magnitude < width + m.def.size * 1.5 then
					table.insert(out, m)
				end
			end
		end
		return out
	end
	-- walking players (alive) within a radius: { player, hum, root }
	local function playersIn(center: Vector3, radius: number): { any }
		local out = {}
		for _, other in Players:GetPlayers() do
			local och = other.Character
			local oh = och and och:FindFirstChildOfClass("Humanoid")
			local orp = och and och:FindFirstChild("HumanoidRootPart") :: BasePart?
			if oh and orp and oh.Health > 0 and och:GetAttribute("HunterLive") and (orp.Position - center).Magnitude < radius then
				table.insert(out, { player = other, hum = oh, root = orp })
			end
		end
		return out
	end
	local function aimPoint(aim: any, pos: Vector3, look: Vector3, range: number): Vector3
		local p: Vector3? = nil
		if type(aim) == "table" and type(aim[1]) == "number" and type(aim[2]) == "number" and type(aim[3]) == "number" then
			local x, y, z = aim[1], aim[2], aim[3]
			if x == x and y == y and z == z and math.abs(x) < 1e5 and math.abs(y) < 1e5 and math.abs(z) < 1e5 then
				p = Vector3.new(x, y, z)
			end
		end
		local off = if p then Vector3.new(p.X - pos.X, 0, p.Z - pos.Z) else look * (range * 0.6)
		if off.Magnitude > range then
			off = off.Unit * range
		end
		return Vector3.new(pos.X + off.X, pos.Y, pos.Z + off.Z)
	end
	-- how far a dash or blink can go before a wall
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	local function clearDistance(from: Vector3, dir: Vector3, dist: number): number
		local skip: { Instance } = { crystals }
		if Npcs.folder then
			table.insert(skip, Npcs.folder)
		end
		for _, other in Players:GetPlayers() do
			if other.Character then
				table.insert(skip, other.Character)
			end
		end
		rayParams.FilterDescendantsInstances = skip
		local r = Workspace:Raycast(from, dir * dist, rayParams)
		return if r then math.max(0, (r.Position - from).Magnitude - 2.5) else dist
	end

	-- the hit itself, and the kill on the life's record (once a monster)
	local function hurt(m: any, amount: number, life: any): boolean
		if m.hum.Health <= 0 or amount <= 0 then
			return false
		end
		if (m.exposedUntil or 0) > os.clock() then
			amount *= m.exposeMult or 1
		end
		m.hum:TakeDamage(amount)
		if m.hum.Health <= 0 and life and not m.credited then
			m.credited = true
			HW.addHistory(life, { kind = "break", rank = m.rank, role = "fought", won = true, live = true, alive = true })
		end
		return true
	end
	local function slowMonster(m: any, factor: number, seconds: number)
		local now = os.clock()
		m.slowUntil = math.max(m.slowUntil or 0, now + seconds)
		m.hum.WalkSpeed = math.min(m.hum.WalkSpeed, m.def.speed * factor)
		task.delay(seconds, function()
			if m.hum.Parent and os.clock() >= (m.slowUntil or 0) - 0.05 then
				m.hum.WalkSpeed = m.def.speed
			end
		end)
	end
	local function stunMonster(m: any, seconds: number)
		slowMonster(m, 0, seconds)
		m.cool = math.max(m.cool or 0, os.clock() + seconds) -- a stunned monster can't hit either
	end
	local function push(m: any, from: Vector3, ab: any)
		local mr = m.model.PrimaryPart
		if not mr then
			return
		end
		local dir = flat(mr.Position - from)
		local v = if ab.pull
			then -dir * 34 + Vector3.new(0, 6, 0)
			else dir * (ab.knock or 0) + Vector3.new(0, if ab.launch then 48 elseif ab.knock then 14 else 0, 0)
		mr.AssemblyLinearVelocity = v
	end

	-- things that keep working: zones, burns, heals over time, constructs (stepped every 0.25 s)
	local active: { any } = {}
	local function stepActive(now: number)
		for i = #active, 1, -1 do
			local e = active[i]
			if now >= e.untilT or not e.owner.Parent or walking[e.owner] == nil or (e.m and e.m.hum.Health <= 0) then
				table.remove(active, i)
				if e.done then
					e.done(e)
				end
			elseif now >= e.nextT then
				e.nextT = now + e.tick
				local ok, err = pcall(e.step, e, now)
				if not ok then
					warn("[BitLeveling] ability " .. tostring(e.id) .. " failed: " .. tostring(err))
					table.remove(active, i)
				end
			end
		end
	end
	local function burnMonster(m: any, perSecond: number, owner: Player, life: any)
		if m.burning and m.burning.untilT > os.clock() then
			m.burning.untilT = os.clock() + 3
			m.burning.dps = math.max(m.burning.dps, perSecond)
			return
		end
		local e = { id = "burn", owner = owner, m = m, dps = perSecond, untilT = os.clock() + 3, nextT = os.clock() + 0.5, tick = 0.5 }
		e.step = function(self: any)
			hurt(self.m, self.dps * self.tick, life)
		end
		m.burning = e
		table.insert(active, e)
	end
	local function healPlayer(p: any, share: number)
		p.hum.Health = math.min(p.hum.MaxHealth, p.hum.Health + p.hum.MaxHealth * share)
	end
	local function calmCivilians(center: Vector3, radius: number)
		for _, c in Npcs.civilians do
			local cr = c.model.PrimaryPart
			if cr and (cr.Position - center).Magnitude < radius then
				Npcs.unfreeze(c)
			end
		end
	end
	local function addBuff(player: Player, buff: any, seconds: number, baseSpeed: number)
		local b = buffs[player] or {}
		buffs[player] = b
		local now = os.clock()
		if buff.dmg then
			b.dmg = math.max(if (b.dmgUntil or 0) > now then (b.dmg or 1) else 1, buff.dmg)
			b.dmgUntil = now + seconds
		end
		local ch = player.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if buff.speed and hum then
			b.speedUntil = now + seconds
			hum.WalkSpeed = baseSpeed * buff.speed
			task.delay(seconds, function()
				if hum.Parent and os.clock() >= (b.speedUntil or 0) - 0.05 then
					hum.WalkSpeed = baseSpeed
				end
			end)
		end
	end

	local function castAbility(player: Player, session: any, slot: string, aim: any)
		local life = lifeOf(session)
		local class = classOf(life)
		local prank = rankOf(session)
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		local h = ch and ch:FindFirstChildOfClass("Humanoid")
		if not life or not class or prank <= 0 or not ch or not root or not h or h.Health <= 0 then
			return
		end
		-- off cooldown (checked first: it's cheap), not spammed, then the move in that slot, if
		-- this Hunter can use it (class, skill, rank), with the mana for it
		local now0 = os.clock()
		local cool = cools[player] or {}
		cools[player] = cool
		if (cool[slot] or 0) > now0 or now0 - (cool._last or 0) < 0.15 then
			return
		end
		cool._last = now0
		local set = traitSet(life)
		local id = barOf(session, life, class)[slot]
		local ab = id and Abilities.byId[id]
		if not ab or not Abilities.usable(ab, class, set, prank) then
			return
		end
		local mana = manaOf(player, session)
		if mana.cur < ab.mana then
			event:FireClient(player, { noMana = { slot = slot, need = ab.mana, have = math.floor(mana.cur) } })
			return
		end
		mana.cur -= ab.mana
		showMana(player, session)
		local learned = skillCount(life, class)
		local school = if ab.school then schoolCount(life, ab.school) else 0
		local cast = ab.cast or 0
		local cd = ab.cd * (1 - math.min(0.3, learned * 0.02 + school * 0.03))
		cool[slot] = now0 + cd + cast
		event:FireClient(player, { cooldown = { slot = slot, left = cd + cast, id = ab.id }, mana = { cur = math.floor(mana.cur), max = mana.max, regen = mana.regen } })

		-- the Hunter's base damage: rank, the weapon (as the attack), the class's main stat,
		-- a damage buff, and the skills behind it; the move's own multiplier (Hunter/Abilities)
		-- carries its tier
		local stat = life.stats[CLASS_STAT[class] or "strength"] or 10
		local base = RANK_DMG[prank] * weaponMult(life) * (1 + stat / 250) * dmgBuffOf(player) * (1 + learned * 0.04 + school * 0.06)
		local function perform()
			local ch = player.Character
			local root = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			if not ch or not root or not h or h.Health <= 0 or walking[player] == nil then
				return
			end
			local now = os.clock()
			local dmg = base * (ab.mult or 0)
			local pos = root.Position
			local look = flat(root.CFrame.LookVector)
			local floorY = pos.Y - (h.HipHeight + root.Size.Y / 2)
			local hits = 0
			local msg: any = {
				ability = ab.id, element = ab.element, kind = ab.kind, shape = ab.shape, tier = ab.tier, slot = slot, player = player.UserId, rank = prank,
				at = v3t(pos), dir = v3t(look), floor = math.floor(floorY * 100) / 100,
				radius = ab.radius, range = ab.range, duration = ab.duration,
			}
			local function apply(m: any, amount: number, from: Vector3)
				if hurt(m, amount, life) then
					hits += 1
				end
				if ab.slow then
					slowMonster(m, ab.slow, ab.slowFor or 3)
				end
				if ab.stun then
					stunMonster(m, ab.stun)
				end
				if ab.burn then
					burnMonster(m, base * ab.burn, player, life)
				end
				if ab.knock or ab.launch or ab.pull then
					push(m, from, ab)
				end
				if ab.taunt then
					provoked[m] = { player = player, untilT = now + ab.taunt }
				end
				-- curses: a weakened monster hits softer, an exposed one takes more
				if ab.weaken then
					m.weakMult, m.weakUntil = ab.weaken, now + (ab.duration or 5)
				end
				if ab.expose then
					m.exposeMult, m.exposedUntil = ab.expose, now + (ab.duration or 5)
				end
			end
			local function points(list: { any }): { any }
				local out = {}
				for i = 1, math.min(8, #list) do
					local mp = monsterPos(list[i])
					if mp then
						table.insert(out, v3t(mp))
					end
				end
				return out
			end
			local function allies(radius: number?): { any }
				if ab.allies or radius then
					return playersIn(pos, radius or ab.radius or 0)
				end
				return { { player = player, hum = h, root = root } }
			end
			local function centerOf(): Vector3
				if ab.center == "aim" then
					return aimPoint(aim, pos, look, ab.range or 40)
				elseif ab.center == "front" then
					return pos + look * (ab.range or 8)
				elseif ab.center == "target" then
					local m = nearestAhead(pos, look, ab.range or 40, 0.3)
					local mp = m and monsterPos(m)
					return mp or (pos + look * math.min(ab.range or 30, 30))
				end
				return pos
			end
			local kind = ab.kind

			if kind == "aoe" then
				local center = centerOf()
				msg.to = v3t(center)
				local function resolve()
					local list: { any }
					if ab.arc then
						list = {}
						for _, m in monstersIn(pos, ab.range or 10) do
							local mp = monsterPos(m) :: Vector3
							if (mp - pos).Magnitude < 4 or look:Dot(flat(mp - pos)) > ab.arc then
								table.insert(list, m)
							end
						end
					else
						list = monstersIn(center, ab.radius or ab.range or 10)
					end
					msg.targets = points(list)
					for _, m in list do
						apply(m, dmg, center)
					end
					if ab.heal then
						local healed = {}
						for _, p in playersIn(center, ab.radius or 10) do
							healPlayer(p, ab.heal)
							table.insert(healed, v3t(p.root.Position))
						end
						msg.healed = healed
					end
					if ab.element == "holy" then
						calmCivilians(center, ab.radius or 12)
					end
				end
				if ab.delay then
					task.delay(ab.delay, resolve)
				else
					resolve()
				end
			elseif kind == "beam" then
				local list = along(pos, look, ab.range, ab.width or 4)
				msg.to = v3t(pos + look * ab.range)
				msg.targets = points(list)
				for _, m in list do
					apply(m, dmg, pos)
				end
			elseif kind == "projectile" then
				local count = ab.count or 1
				local targets = {}
				if count == 1 then
					local m = nearestAhead(pos, look, ab.range, 0.5)
					if m then
						table.insert(targets, m)
					end
				else
					-- a fan: the nearest monsters inside the arc, one projectile each
					local cand = {}
					for _, m in monstersIn(pos, ab.range) do
						local mp = monsterPos(m) :: Vector3
						if look:Dot(flat(mp - pos)) > (ab.arc or 0.6) then
							table.insert(cand, { m = m, d = (mp - pos).Magnitude })
						end
					end
					table.sort(cand, function(a, b)
						return a.d < b.d
					end)
					for i = 1, math.min(count, #cand) do
						table.insert(targets, cand[i].m)
					end
				end
				-- where each projectile lands: on its monster, the rest fanned out at full range
				local ends = {}
				for _, m in targets do
					table.insert(ends, monsterPos(m) :: Vector3)
				end
				local spread = math.acos(math.clamp(ab.arc or 0.6, -1, 1))
				for i = #ends + 1, count do
					local a = if count == 1 then 0 else (i - 1) / (count - 1) * 2 - 1
					local dir = (CFrame.fromAxisAngle(Vector3.yAxis, a * spread) :: any):VectorToWorldSpace(look)
					table.insert(ends, pos + dir * ab.range)
				end
				local toList = {}
				for _, e in ends do
					table.insert(toList, v3t(e))
				end
				msg.to = toList[1]
				msg.targets = toList
				-- the damage lands when the projectile does
				local far = 0
				for _, e in ends do
					far = math.max(far, (e - pos).Magnitude)
				end
				local travel = math.min(1.2, far / (ab.speed or 120)) + (ab.delay or 0)
				task.delay(travel, function()
					for i, m in targets do
						apply(m, dmg, pos)
						if ab.splash then
							for _, other in monstersIn(ends[i], ab.splash) do
								if other ~= m then
									apply(other, dmg * 0.6, ends[i])
								end
							end
						end
					end
					if ab.splash and #targets == 0 then
						for _, other in monstersIn(ends[1], ab.splash) do
							apply(other, dmg * 0.6, ends[1])
						end
					end
				end)
			elseif kind == "strike" then
				local m = nearestAhead(pos, look, ab.range, 0.2)
				local mp = m and monsterPos(m)
				msg.to = v3t(mp or (pos + look * 5))
				msg.hits = ab.hits
				if m then
					if ab.delay then
						task.delay(ab.delay, function()
							apply(m, dmg, pos)
						end)
					else
						apply(m, dmg, pos)
					end
				end
			elseif kind == "chain" then
				local chain, skip = {}, {}
				local m = nearestAhead(pos, look, ab.range, 0.35)
				while m and #chain < 1 + (ab.chains or 0) do
					table.insert(chain, m)
					skip[m] = true
					m = nearestAhead(monsterPos(m) :: Vector3, look, ab.jump or 20, -2, skip)
				end
				msg.targets = points(chain)
				msg.to = msg.targets[1] or v3t(pos + look * math.min(ab.range, 30))
				for i, c in chain do
					apply(c, dmg * 0.85 ^ (i - 1), pos)
				end
			elseif kind == "dash" or kind == "blink" then
				local dir = if ab.back then -look else look
				local dest: Vector3
				local target = nil
				if ab.center == "target" then
					target = nearestAhead(pos, look, ab.range, 0.35)
					local tp = target and monsterPos(target)
					if tp then
						local off = flat(tp - pos)
						dest = Vector3.new(tp.X, pos.Y, tp.Z) + off * (3 + target.def.size * 2)
						dir = off
					else
						dest = pos + dir * ab.range * 0.6
					end
				elseif ab.center == "aim" then
					dest = aimPoint(aim, pos, look, ab.range)
					dir = flat(dest - pos)
				else
					dest = pos + dir * ab.range
				end
				-- never through a wall
				local want = Vector3.new(dest.X - pos.X, 0, dest.Z - pos.Z)
				local dist = clearDistance(pos, flat(want), want.Magnitude)
				dest = pos + flat(want) * dist
				local face = if ab.back then look else dir
				ch:PivotTo(CFrame.lookAt(dest, dest + face))
				msg.to = v3t(dest)
				msg.from = msg.at
				if kind == "dash" then
					local list: { any }
					if target then
						list = { target }
						msg.target = v3t(monsterPos(target) or dest)
					elseif ab.back then
						-- jump back, then shoot whatever is in front
						local m = nearestAhead(dest, look, 70, 0.5)
						list = if m then { m } else {}
						if m then
							msg.target = v3t(monsterPos(m) :: Vector3)
						end
					else
						list = along(pos, flat(want), dist, ab.width or 4)
					end
					if ab.radius then
						for _, m in monstersIn(dest, ab.radius) do
							if not table.find(list, m) then
								table.insert(list, m)
							end
						end
					end
					msg.targets = points(list)
					for _, m in list do
						apply(m, dmg, if ab.radius then dest else pos)
					end
					if ab.guard then
						addGuard(player, ab.guard, ab.duration or 2)
					end
				else
					-- a blink: a burst where you land, or a cloud where you stood
					if ab.radius then
						local center = if ab.back then pos else dest
						local list = monstersIn(center, ab.radius)
						msg.targets = points(list)
						for _, m in list do
							apply(m, dmg, center)
						end
					end
				end
			elseif kind == "zone" then
				local center = centerOf()
				msg.to = v3t(center)
				local e: any = { id = ab.id, owner = player, untilT = now + ab.duration, nextT = now, tick = ab.tick, center = center }
				e.step = function(self: any)
					local c = self.center
					if ab.follow then
						local ch2 = player.Character
						local r2 = ch2 and ch2:FindFirstChild("HumanoidRootPart") :: BasePart?
						if r2 then
							c = r2.Position
							self.center = c
						end
					end
					local list = monstersIn(c, ab.radius)
					if ab.shape == "storm" then
						-- bolts fall on up to three things under the storm
						while #list > 3 do
							table.remove(list, math.random(1, #list))
						end
						fx("abilityTick", { ability = ab.id, player = player.UserId, at = v3t(c), targets = points(list), floor = msg.floor })
					end
					for _, m in list do
						apply(m, dmg, c)
					end
					if ab.heal or ab.guard then
						for _, p in playersIn(c, ab.radius) do
							if ab.heal then
								healPlayer(p, ab.heal)
							end
							if ab.guard then
								addGuard(p.player, ab.guard, ab.tick + 0.4)
							end
						end
					end
					if ab.element == "holy" then
						calmCivilians(c, ab.radius)
					end
				end
				table.insert(active, e)
			elseif kind == "buff" then
				local list = allies()
				local spots = {}
				for _, p in list do
					if ab.buff then
						addBuff(p.player, ab.buff, ab.duration, RANK_SPEED[rankOf(S.sessions[p.player])] or 16)
					end
					if ab.guard then
						addGuard(p.player, ab.guard, ab.duration)
					end
					table.insert(spots, v3t(p.root.Position))
				end
				msg.allies = spots
			elseif kind == "heal" or kind == "shield" then
				local list = if kind == "heal" then playersIn(pos, ab.radius) else allies()
				local spots = {}
				for _, p in list do
					if ab.heal and not (kind == "heal" and ab.duration and not ab.guard) then
						healPlayer(p, ab.heal)
					end
					if ab.guard then
						addGuard(p.player, ab.guard, ab.duration or 4)
					end
					table.insert(spots, v3t(p.root.Position))
				end
				msg.healed = if kind == "heal" then spots else nil
				msg.allies = spots
				if kind == "heal" then
					calmCivilians(pos, ab.radius)
					-- a cleanse: steadied, a moment's guard, and nothing slowing you
					if ab.cleanse then
						for _, p in list do
							addGuard(p.player, 0.8, 2)
							local base2 = RANK_SPEED[rankOf(S.sessions[p.player])] or 16
							if p.hum.WalkSpeed < base2 then
								p.hum.WalkSpeed = base2
							end
						end
						calmCivilians(pos, ab.radius * 1.5)
					end
					-- some keep healing (motes, regeneration)
					if ab.duration and not ab.guard then
						table.insert(active, {
							id = ab.id, owner = player, untilT = now + ab.duration, nextT = now, tick = ab.tick or 1,
							step = function()
								local r2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
								for _, p in playersIn(if r2 then r2.Position else pos, ab.radius) do
									healPlayer(p, ab.heal)
								end
							end,
						})
					end
					-- and one burns every monster in the light
					if dmg > 0 then
						local list2 = monstersIn(pos, ab.radius)
						msg.targets = points(list2)
						for _, m in list2 do
							apply(m, dmg, pos)
						end
					end
				end
			elseif kind == "taunt" then
				local list = monstersIn(pos, ab.radius)
				for _, m in list do
					provoked[m] = { player = player, untilT = now + ab.duration }
					if dmg > 0 then
						apply(m, dmg, pos)
					else
						hits += 1
					end
					if dmg <= 0 and (ab.slow or ab.stun) then
						if ab.slow then
							slowMonster(m, ab.slow, ab.slowFor or 3)
						end
						if ab.stun then
							stunMonster(m, ab.stun)
						end
					end
				end
				msg.targets = points(list)
				if ab.guard then
					addGuard(player, ab.guard, ab.duration)
					-- (and everyone behind you)
					if ab.allies then
						local spots = {}
						for _, p in playersIn(pos, ab.radius * 0.5) do
							addGuard(p.player, ab.guard, ab.duration)
							table.insert(spots, v3t(p.root.Position))
						end
						msg.allies = spots
					end
				end
			elseif kind == "construct" then
				-- a construct of mana (never a soul): it walks to the nearest monster and strikes
				local cfg = ab.construct or {}
				local spawnAt = if ab.center == "front" then pos + look * (ab.range or 6) else pos
				spawnAt = Vector3.new(spawnAt.X, pos.Y, spawnAt.Z)
				msg.to = v3t(spawnAt)
				msg.style = cfg.style
				local e: any = { id = ab.id, owner = player, untilT = now + ab.duration, nextT = now + 0.5, tick = ab.tick or 0.5, pos = spawnAt, swingT = 0 }
				e.step = function(self: any, t: number)
					local target, td = nil, 80
					for _, m in Npcs.monsters do
						local mp = monsterPos(m)
						if mp then
							local d = (mp - self.pos).Magnitude
							if d < td then
								target, td = m, d
							end
						end
					end
					local hit = nil
					local moved = false
					if target then
						local mp = monsterPos(target) :: Vector3
						local reach = (cfg.reach or 7) + target.def.size * 2
						if td > reach * 0.8 then
							local step = math.min((cfg.speed or 16) * self.tick, td - reach * 0.8)
							self.pos += flat(mp - self.pos) * step
							moved = true
						end
						if td <= reach + 1 and t >= self.swingT then
							self.swingT = t + 0.9
							hurt(target, dmg, life)
							hit = v3t(mp)
							if ab.slow then
								slowMonster(target, ab.slow, ab.slowFor or 2)
							end
						end
					else
						-- nothing to fight: stay by the one who made it
						local r2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
						if r2 and (r2.Position - self.pos).Magnitude > 10 then
							self.pos += flat(r2.Position - self.pos) * math.min((cfg.speed or 16) * self.tick, (r2.Position - self.pos).Magnitude - 8)
							moved = true
						end
					end
					if ab.heal then
						for _, p in playersIn(self.pos, ab.radius or 16) do
							healPlayer(p, ab.heal)
						end
					end
					if moved or hit then
						fx("abilityTick", { ability = ab.id, player = player.UserId, at = v3t(self.pos), to = hit, hit = hit ~= nil, floor = msg.floor, style = cfg.style })
					end
				end
				e.done = function()
					fx("abilityTick", { ability = ab.id, player = player.UserId, done = true })
				end
				table.insert(active, e)
			end
			msg.hits = msg.hits or hits
			fx("ability", msg)
		end
		-- a cast time: everyone sees it gather, then it goes off
		if cast > 0 then
			local r0 = (ch :: Model):FindFirstChild("HumanoidRootPart") :: BasePart?
			local p0 = if r0 then r0.Position else Vector3.zero
			fx("abilityCast", { ability = ab.id, element = ab.element, tier = ab.tier, player = player.UserId, at = v3t(p0), cast = cast, floor = math.floor((p0.Y - 3) * 100) / 100 })
			task.delay(cast, perform)
		else
			perform()
		end
	end

	-- a Hunter player's attack and abilities (client asks; server decides)
	event.OnServerEvent:Connect(function(player: Player, action: any, data: any)
		local w = walking[player]
		local session = S.sessions[player]
		if not w or not session then
			return
		end
		if action == "skill" then
			local slot = type(data) == "table" and data.slot
			if type(slot) == "string" and Abilities.SLOT_INFO[slot] then
				castAbility(player, session, slot, type(data) == "table" and data.aim or nil)
			end
			return
		end
		if action ~= "attack" then
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
		-- the weapon in your hand: its power (stars and shine included) adds to every blow, and
		-- a War Cry or an Eagle Eye adds to it
		local dmg = RANK_DMG[prank] * (1 + str / 200) * weaponMult(life) * dmgBuffOf(player)
		local look = root.CFrame.LookVector
		local hitAny = false
		for _, m in table.clone(Npcs.monsters) do
			local mr = m.model.PrimaryPart
			if mr and m.hum.Health > 0 then
				local off = mr.Position - root.Position
				local reach = 9 + m.def.size * 2
				if off.Magnitude < reach and (off.Magnitude < 3 or look:Dot(off.Unit) > 0.25) then
					hurt(m, dmg, life)
					hitAny = true
				end
			end
		end
		local a = root.Position + look * 4
		fx("swing", { at = { a.X, a.Y, a.Z }, dir = { look.X, look.Y, look.Z }, rank = prank, hit = hitAny, player = player.UserId })
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
				local isWeapon = c:GetAttribute("Weapon") == true
				c:Destroy()
				local report = sim.newReport and sim.newReport() or { entries = {} }
				if isWeapon then
					sim:applyResult(life, { loot = { rank = rank, chance = 1 }, log = "You pried open a weapon cache the monster had been carrying." }, report)
					local res = S.lifeResponse(session, report)
					res.toast = "A weapon! (check your life's log)"
					S.pushTo(player, res)
					return
				end
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
	-- the endings this player's lives have found, and the ones still locked (with a hint)
	function handlers.hwFates(_player, session)
		return { ok = true, fates = HW.fateList(sim.pack, session.profile.Data.fates) }
	end
	-- the skill bar: what's in each slot and what could be (payload { slot, id }: put an unlocked
	-- ability in its slot; { slot } alone: back to the best one). Swapping never skips a cooldown.
	function handlers.hwSkillBar(player, session, payload)
		local life = lifeOf(session)
		local class = classOf(life)
		if not life or not class or rankOf(session) <= 0 then
			return { ok = true, bar = barView(session) }
		end
		if type(payload) == "table" and payload.slot ~= nil then
			local slot = payload.slot
			if type(slot) ~= "string" or not Abilities.SLOT_INFO[slot] then
				return { ok = false, error = "No such slot." }
			end
			local ab = if type(payload.id) == "string" then Abilities.byId[payload.id] else nil
			if payload.id ~= nil and (not ab or ab.slot ~= slot or not Abilities.usable(ab, class, traitSet(life), rankOf(session))) then
				return { ok = false, error = "You haven't learned that one yet." }
			end
			local data = session.profile.Data
			data.hlBar = if type(data.hlBar) == "table" then data.hlBar else {}
			data.hlBar[slot] = if ab then ab.id else nil
			local cool = cools[player] or {}
			cools[player] = cool
			cool[slot] = math.max(cool[slot] or 0, os.clock() + 1.5)
			setBarAttributes(player.Character, session, life, class)
		end
		return { ok = true, bar = barView(session) }
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
		-- (outside a Red Gate you see a sealed Gate in the street: the inside card is for the raid)
		local prefix = if inc.broken then cfg.cards.breakOut else cfg.cards.cityGate
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
		return { ok = true, look = lookOf(session), rank = rankOf(session) }
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
	-- open a Gate on demand (the admin buttons, and the Studio plugin's play test)
	local function adminOpen(payload: any, site: any?, who: string): any
		local rank = math.clamp(math.floor(tonumber(payload.rank) or math.random(1, 6)), 1, 6)
		local kind = if payload.kind == "red" or payload.kind == "double" then payload.kind else nil
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
		print(string.format("[BitLeveling admin] %s opened a %s Gate (%s) at %s", who, HW.rankWord(rank), tostring(kind or "gate"), inc.label))
		return { ok = true, toast = string.format("Opened a %s Gate at %s.", HW.rankWord(rank), inc.label) }
	end
	function handlers.hwAdminSpawn(player, _session, payload)
		if not (Admin.isAdmin and Admin.isAdmin(player)) then
			return { ok = false, error = "Not allowed." }
		end
		payload = if type(payload) == "table" then payload else {}
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
		return adminOpen(payload, site, player.Name)
	end

	S.HunterLive = { spawn = spawnIncident, incidents = incidents, sites = Map.sites }

	-- in Studio only: the BitLeveling Studio plugin's PLAY TEST buttons call this (server view)
	if RunService:IsStudio() then
		local hook = Instance.new("BindableFunction")
		hook.Name = "BitLevelingStudio"
		hook.OnInvoke = function(action: string, payload: any)
			if action == "spawn" then
				return adminOpen(if type(payload) == "table" then payload else {}, nil, "Studio")
			elseif action == "status" then
				return { ok = true, incidents = #incidents, players = #Players:GetPlayers() }
			end
			return { ok = false, error = "unknown action " .. tostring(action) }
		end
		hook.Parent = game:GetService("ServerStorage")
	end

	Players.PlayerRemoving:Connect(function(player)
		walking[player] = nil
		guardUntil[player] = nil
		guardMult[player] = nil
		buffs[player] = nil
		cools[player] = nil
		manas[player] = nil
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
			stepActive(now) -- zones, burns, heals over time, constructs
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
		-- mana refills; the HUD reads it off the character
		for player in walking do
			local session = S.sessions[player]
			if session then
				showMana(player, session)
			end
		end
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
