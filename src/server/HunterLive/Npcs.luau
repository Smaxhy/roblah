--[[
	LIVE NPCs in the walkable city (server-side, so everyone sees the same people react):
		civilians   R6 people walking the sidewalks. Each has a temperament that decides what
		            they do when a Gate opens near them (ORIGINAL): most flee, some freeze, some
		            help others, some shelter in a doorway, a few stand and film it.
		responders  police at the cordon, the Association's measurement team, Hunters going in
		monsters    what comes out in a Dungeon Break: one family a Gate, in a pack fit for its
		            rank (a leader, a shaman or an archer, fighters, weaker kin), each fighting
		            its own way (server/HunterLive/MonsterAI: specials with wind-ups the
		            client draws, ranged kinds that keep their distance, healers, summoners)
	Adults only: no child NPC is ever put in danger.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Npcs = {}

local R6Rig: any
local Looks: any
local folder: Folder
local rng = Random.new()

Npcs.civilians = {} :: { any }
Npcs.monsters = {} :: { any }
Npcs.responders = {} :: { any }
Npcs.provoked = nil :: any -- [monster] = { player, untilT }: who it must chase (a Tanker's Provoke)

local TEMPERS = { flee = 55, freeze = 9, help = 10, shelter = 16, film = 10 }
local function temper(): string
	local total = 0
	for _, w in TEMPERS do
		total += w
	end
	local r = rng:NextNumber() * total
	for id, w in TEMPERS do
		r -= w
		if r <= 0 then
			return id
		end
	end
	return "flee"
end

function Npcs.init(parent: Instance)
	local shared = ReplicatedStorage:WaitForChild("LifeSim")
	local hunter = shared:WaitForChild("Hunter")
	R6Rig = require(hunter:WaitForChild("R6Rig"))
	Looks = require(hunter:WaitForChild("Looks"))
	folder = Instance.new("Folder")
	folder.Name = "LiveNPCs"
	folder.Parent = parent
	Npcs.folder = folder
end

local trackCache: { [Model]: { [string]: AnimationTrack } } = setmetatable({}, { __mode = "k" }) :: any

local function animate(model: Model, which: string): AnimationTrack?
	local hum = model:FindFirstChildOfClass("Humanoid")
	local animator = hum and hum:FindFirstChildOfClass("Animator")
	if not animator then
		return nil
	end
	local cache = trackCache[model]
	if not cache then
		cache = {}
		trackCache[model] = cache
	end
	if not cache[which] then
		local anim = Instance.new("Animation")
		anim.AnimationId = R6Rig.ANIMS[which]
		local ok, track = pcall(function()
			return animator:LoadAnimation(anim)
		end)
		if ok and track then
			track.Looped = which ~= "jump"
			cache[which] = track
		end
	end
	for id, t in cache do
		if id ~= which and t.IsPlaying then
			t:Stop(0.2)
		end
	end
	local t = cache[which]
	if t and not t.IsPlaying then
		t:Play(0.2)
	end
	return t
end
Npcs.animate = animate

local function spawnRig(look: any, at: Vector3, name: string, civilian: boolean, weapon: any?): Model
	local model = R6Rig.build(look, { name = name, npc = true, civilian = civilian, weapon = weapon })
	-- (the rig's pivot is its root, three studs above its feet)
	R6Rig.pose(model, CFrame.new(at + Vector3.new(0, 3.2, 0)))
	model.Parent = folder
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart
	pcall(function()
		root:SetNetworkOwner(nil)
	end)
	return model
end

-- ── civilians ─────────────────────────────────────────────────────────────
function Npcs.spawnCivilians(n: number, waypoints: { Vector3 })
	for i = 1, n do
		local look = Looks.random(function(a, b)
			return rng:NextInteger(a, b)
		end, { civilian = true })
		local at = waypoints[rng:NextInteger(1, #waypoints)]
		local model = spawnRig(look, at, "Citizen", true)
		local hum = model:FindFirstChildOfClass("Humanoid") :: Humanoid
		hum.WalkSpeed = rng:NextNumber(6, 9)
		hum.MaxHealth = 100
		hum.Health = 100
		local c = { model = model, hum = hum, temper = temper(), state = "walk", target = nil, until_ = 0, home = at }
		table.insert(Npcs.civilians, c)
		animate(model, "walk")
		local _ = i
	end
end

-- a phone in the hand of someone filming (their arm comes up; raisedArm keeps where it was)
local raisedArm: { [Model]: CFrame } = setmetatable({}, { __mode = "k" }) :: any
local function phone(model: Model)
	if model:FindFirstChild("Phone") then
		return
	end
	local arm = model:FindFirstChild("Right Arm") :: BasePart
	if not arm then
		return
	end
	R6Rig.shell(model, arm, "Phone", Vector3.new(0.5, 0.9, 0.12), CFrame.new(0, -1.1, -0.4) * CFrame.Angles(math.rad(-70), 0, 0), Color3.fromRGB(20, 20, 24), Enum.Material.Glass)
	local torsoPart = model:FindFirstChild("Torso")
	local shoulder = torsoPart and torsoPart:FindFirstChild("Right Shoulder") :: Motor6D?
	if shoulder and not raisedArm[model] then
		raisedArm[model] = shoulder.C0
		shoulder.C0 = shoulder.C0 * CFrame.Angles(0, 0, math.rad(80))
	end
end

-- a civilian reacts to an incident at `pos` (radius r)
function Npcs.react(pos: Vector3, radius: number, shelters: { Vector3 }, waypoints: { Vector3 })
	for _, c in Npcs.civilians do
		local root = c.model.PrimaryPart
		if root and c.hum.Health > 0 and (root.Position - pos).Magnitude < radius and c.state == "walk" then
			c.danger = pos
			if c.temper == "flee" or c.temper == "help" then
				-- away from it, as far as the city goes
				local away = (root.Position - pos)
				away = Vector3.new(away.X, 0, away.Z)
				if away.Magnitude < 1 then
					away = Vector3.new(1, 0, 0)
				end
				c.state = c.temper
				c.target = root.Position + away.Unit * rng:NextNumber(120, 200)
				c.hum.WalkSpeed = rng:NextNumber(16, 21)
				animate(c.model, "run")
			elseif c.temper == "freeze" then
				c.state = "freeze"
				c.hum:MoveTo(root.Position)
				animate(c.model, "idle")
			elseif c.temper == "shelter" then
				local best, bd = nil, math.huge
				for _, s in shelters do
					local d = (s - root.Position).Magnitude
					if d < bd and (s - pos).Magnitude > 30 then
						best, bd = s, d
					end
				end
				c.state = "shelter"
				c.target = best or waypoints[rng:NextInteger(1, #waypoints)]
				c.hum.WalkSpeed = rng:NextNumber(14, 18)
				animate(c.model, "run")
			elseif c.temper == "film" then
				c.state = "film"
				local dir = (root.Position - pos)
				dir = Vector3.new(dir.X, 0, dir.Z)
				c.target = pos + (if dir.Magnitude > 0 then dir.Unit else Vector3.new(1, 0, 0)) * rng:NextNumber(34, 50)
				c.hum.WalkSpeed = 8
				phone(c.model)
				animate(c.model, "walk")
			end
			c.until_ = os.clock() + rng:NextNumber(40, 80)
		end
	end
end

-- a frozen civilian snapped out of it (a player helped them): they run now
function Npcs.unfreeze(c: any)
	if c.state ~= "freeze" or not c.danger then
		return false
	end
	local root = c.model.PrimaryPart
	if not root then
		return false
	end
	local away = (root.Position - c.danger)
	away = Vector3.new(away.X, 0, away.Z)
	c.state = "flee"
	c.target = root.Position + (if away.Magnitude > 0 then away.Unit else Vector3.new(1, 0, 0)) * 160
	c.hum.WalkSpeed = 18
	animate(c.model, "run")
	return true
end

function Npcs.calm()
	for _, c in Npcs.civilians do
		if c.state ~= "walk" and c.state ~= "down" then
			c.until_ = math.min(c.until_, os.clock() + rng:NextNumber(3, 12))
		end
	end
end

-- one step of every civilian (called ~4 times a second)
function Npcs.stepCivilians(waypoints: { Vector3 })
	local now = os.clock()
	for _, c in Npcs.civilians do
		local root = c.model.PrimaryPart
		if not root or not c.model.Parent then
			continue
		end
		if c.state == "down" then
			-- knocked down in a break: carried off by paramedics (they come back later)
			if now > c.until_ then
				c.hum.Health = c.hum.MaxHealth
				c.state = "walk"
				c.model:PivotTo(CFrame.new(waypoints[rng:NextInteger(1, #waypoints)] + Vector3.new(0, 3, 0)))
				for _, p in c.model:GetDescendants() do
					if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
						-- back to what it was (a lens stays see-through; a part under a mesh stays hidden)
						local base = p:GetAttribute("BaseT")
						p.Transparency = if type(base) == "number" then base elseif p.Name == "FacePlate" then 1 else 0
					end
				end
				c.hum.PlatformStand = false
				animate(c.model, "walk")
			end
			continue
		end
		if c.state ~= "walk" and now > c.until_ then
			c.state = "walk"
			c.target = nil
			c.hum.WalkSpeed = rng:NextNumber(6, 9)
			local ph = c.model:FindFirstChild("Phone")
			if ph then
				ph:Destroy()
			end
			-- the arm comes back down
			local was = raisedArm[c.model]
			local torsoPart = c.model:FindFirstChild("Torso")
			local shoulder = torsoPart and torsoPart:FindFirstChild("Right Shoulder") :: Motor6D?
			if was and shoulder then
				shoulder.C0 = was
			end
			raisedArm[c.model] = nil
			animate(c.model, "walk")
		end
		if c.state == "walk" then
			if not c.target or (root.Position - c.target).Magnitude < 5 then
				c.target = waypoints[rng:NextInteger(1, #waypoints)]
			end
			c.hum:MoveTo(c.target)
		elseif c.state == "flee" or c.state == "help" or c.state == "shelter" or c.state == "film" then
			if c.target then
				c.hum:MoveTo(c.target)
				if (root.Position - c.target).Magnitude < 4 then
					if c.state == "film" and c.danger then
						root.CFrame = CFrame.lookAt(root.Position, Vector3.new(c.danger.X, root.Position.Y, c.danger.Z))
						animate(c.model, "idle")
					elseif c.state == "shelter" then
						animate(c.model, "idle")
					end
				end
			end
			-- helpers pull frozen people along with them
			if c.state == "help" then
				for _, o in Npcs.civilians do
					if o.state == "freeze" and o.model.PrimaryPart and (o.model.PrimaryPart.Position - root.Position).Magnitude < 14 then
						Npcs.unfreeze(o)
					end
				end
			end
		end
	end
end

-- a civilian knocked down by a monster (no gore: they fall, fade, and paramedics take them)
function Npcs.knockDown(c: any)
	c.state = "down"
	c.hum.PlatformStand = true
	c.until_ = os.clock() + 25
	animate(c.model, "idle")
	for _, p in c.model:GetDescendants() do
		if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "FacePlate" then
			if p:GetAttribute("BaseT") == nil then
				p:SetAttribute("BaseT", p.Transparency)
			end
			p.Transparency = math.max(p.Transparency, 0.5)
		end
	end
end

-- ── responders: police, the Association's team, Hunters ──────────────────
local POLICE_LOOK = { skin = "light", face = "stern", top = "uniform", topColor = "navy", trim = "white", bottom = "slacks", bottomColor = "navy", shoes = "boots", extra = "cap", hair = 0, hairDye = "jet", armor = "vest", armorColor = "navy", weapon = "none" }
local STAFF_LOOK = { skin = "fair", face = "focused", top = "suit", topColor = "white", trim = "royal", bottom = "slacks", bottomColor = "charcoal", shoes = "dress", extra = "earpiece", hair = 0, hairDye = "dark_brown", armor = "none", weapon = "none" }

function Npcs.responder(kind: string, at: Vector3, face: Vector3, look: any?): any
	local l = look
	if not l then
		if kind == "police" then
			l = table.clone(POLICE_LOOK)
			l.skin = Looks.SKIN[rng:NextInteger(1, 10)].id
		elseif kind == "staff" then
			l = table.clone(STAFF_LOOK)
			l.skin = Looks.SKIN[rng:NextInteger(1, 10)].id
		else
			l = Looks.random(function(a, b)
				return rng:NextInteger(a, b)
			end)
		end
	end
	-- a Hunter carries a real weapon, of any rarity
	local item = nil
	if kind == "hunter" then
		local Weapons = require(ReplicatedStorage:WaitForChild("LifeSim"):WaitForChild("Hunter"):WaitForChild("Weapons"))
		local w = Weapons.list[rng:NextInteger(1, #Weapons.list)]
		item = { base = w.id, stars = rng:NextInteger(1, 3), shiny = rng:NextNumber() < 0.05 }
	end
	local model = spawnRig(l, at, if kind == "hunter" then "Hunter" elseif kind == "police" then "Police Officer" else "Association Staff", kind ~= "hunter", item)
	local root = model.PrimaryPart :: BasePart
	root.CFrame = CFrame.lookAt(root.Position, Vector3.new(face.X, root.Position.Y, face.Z))
	local hum = model:FindFirstChildOfClass("Humanoid") :: Humanoid
	hum.WalkSpeed = if kind == "hunter" then 20 else 12
	hum.MaxHealth = if kind == "hunter" then 600 else 100
	hum.Health = hum.MaxHealth
	animate(model, "idle")
	local r = { kind = kind, model = model, hum = hum, target = nil, cool = 0 }
	table.insert(Npcs.responders, r)
	return r
end

function Npcs.removeResponder(r: any)
	local i = table.find(Npcs.responders, r)
	if i then
		table.remove(Npcs.responders, i)
	end
	if r.model then
		r.model:Destroy()
	end
end

-- ── monsters ──
-- About 180 kinds in 40 families (Hunter/Monsters, through server/HunterLive/Monsters), each with
-- its own body and joints; how they fight is server/HunterLive/MonsterAI.
local Monsters = require(script.Parent:WaitForChild("Monsters"))
local MonsterAI = require(script.Parent:WaitForChild("MonsterAI"))
Npcs.Monsters = Monsters
Npcs.MonsterAI = MonsterAI
-- (the old one-a-rank table, kept for anything that reads it: the first kind of each rank)
Npcs.MONSTER = {}
for r = 1, 6 do
	Npcs.MONSTER[r] = Monsters.DEFS[Monsters.KINDS[r][1]]
end
function Npcs.monsterModel(rank: number, kind: string?): (Model, Humanoid)
	return Monsters.build(kind or Monsters.KINDS[math.clamp(rank, 1, 6)][1])
end

-- A Gate lets out one family: the first kind out of it names the family, and the rest follow
-- that family's pack for the Gate's rank (Monsters.packFor: fighters, a shaman or an archer,
-- the leader if it has one, weaker kin), whatever kinds the caller asks for after.
Npcs.packs = {} :: { [number]: { seq: { string }, i: number } }
local PACK_LEN = 16
local summonsLive = 0

local function place(model: Model, at: Vector3, size: number)
	-- (its pivot is its root: lift it so it starts above the street, never under it)
	local cf = CFrame.new(at + Vector3.new(rng:NextNumber(-3, 3), 4 * size + 1, rng:NextNumber(-3, 3)))
	local ok = pcall(function()
		model:PivotTo(cf)
	end)
	if not ok and model.PrimaryPart then
		-- (no PivotTo offline: move the root, and every part with it)
		local from = model.PrimaryPart.CFrame
		for _, d in model:GetDescendants() do
			if d:IsA("BasePart") then
				d.CFrame = cf * from:ToObjectSpace(d.CFrame)
			end
		end
	end
end

-- spawn one monster of a break. `kind` is what the caller would like; for an incident it is
-- only honoured for the first one out (or always, with exact = true: tests, admin tools).
function Npcs.spawnMonster(rank: number, at: Vector3, incidentId: number, kind: string?, exact: boolean?): any
	local r = math.clamp(rank, 1, 6)
	local list = Monsters.KINDS[r]
	if not exact and incidentId then
		local pack = Npcs.packs[incidentId]
		if not pack then
			local first = if kind and Monsters.DEFS[kind] and Monsters.DEFS[kind].rank == r then kind else list[rng:NextInteger(1, #list)]
			pack = {
				seq = Monsters.packFor(first, r, PACK_LEN, function(a, b)
					return rng:NextInteger(a, b)
				end),
				i = 0,
			}
			Npcs.packs[incidentId] = pack
		end
		pack.i += 1
		kind = pack.seq[(pack.i - 1) % #pack.seq + 1]
	end
	kind = if kind and Monsters.DEFS[kind] then kind else list[rng:NextInteger(1, #list)]
	local def = Monsters.DEFS[kind :: string]
	local model, hum = Monsters.build(kind :: string)
	place(model, at, def.size)
	model:SetAttribute("Incident", incidentId)
	model.Parent = folder
	pcall(function()
		(model.PrimaryPart :: BasePart):SetNetworkOwner(nil)
	end)
	-- (its own copy of the numbers: a special scales its blow through def.dmg for a moment)
	local m = { model = model, hum = hum, rank = def.rank, kind = kind, def = table.clone(def), incident = incidentId, cool = 0, target = nil, home = at }
	MonsterAI.prepare(m, os.clock())
	table.insert(Npcs.monsters, m)
	return m
end

-- a whole pack at once (what a break could call instead of choosing kinds itself)
function Npcs.spawnPack(rank: number, at: Vector3, incidentId: number, count: number): { any }
	local out = {}
	for _ = 1, count do
		table.insert(out, Npcs.spawnMonster(rank, at, incidentId))
	end
	return out
end

-- something a monster called up (or split into): it leaves no crystal, fades when its master's
-- Gate is done, and doesn't outlast a minute
function Npcs.spawnSummon(kind: string, at: Vector3, master: any): any?
	if summonsLive >= 24 or not Monsters.DEFS[kind] then
		return nil
	end
	local m = Npcs.spawnMonster(Monsters.DEFS[kind].rank, at - Vector3.new(0, 4 * Monsters.DEFS[kind].size + 1, 0) + Vector3.new(0, 2, 0), master.incident, kind, true)
	m.summoned = true
	m.master = master
	m.expires = os.clock() + 60
	m.model:SetAttribute("Summoned", true)
	summonsLive += 1
	return m
end

function Npcs.removeMonster(m: any)
	local i = table.find(Npcs.monsters, m)
	if i then
		table.remove(Npcs.monsters, i)
		if m.summoned then
			summonsLive = math.max(0, summonsLive - 1)
		end
	end
	if m.model then
		m.model:Destroy()
	end
	-- (the incident's last monster gone: forget its pack)
	if m.incident and Npcs.packs[m.incident] then
		local any = false
		for _, o in Npcs.monsters do
			if o.incident == m.incident then
				any = true
				break
			end
		end
		if not any then
			Npcs.packs[m.incident] = nil
		end
	end
end

-- the live FX channel (Remotes.HunterLive, created by the director before the city is built)
local fxEvent: RemoteEvent? = nil
local function fireFx(data: any)
	if not fxEvent then
		local shared = ReplicatedStorage:FindFirstChild("LifeSim")
		local remotes = shared and shared:FindFirstChild("Remotes")
		local ev = remotes and remotes:FindFirstChild("HunterLive")
		if ev and ev:IsA("RemoteEvent") then
			fxEvent = ev
		end
	end
	if fxEvent then
		fxEvent:FireAllClients(data)
	end
end
Npcs.fireFx = fireFx

local function rootOf(kind: string?, victim: any): BasePart?
	if kind == "player" then
		local ch = victim.Character
		return ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	end
	return victim and victim.model and victim.model.PrimaryPart
end

-- everyone a monster's blow can reach in a circle: players walking the city, Hunters, civilians
function Npcs.targetsNear(pos: Vector3, radius: number): { any }
	local out = {}
	for _, player in Players:GetPlayers() do
		local ch = player.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		local h = ch and ch:FindFirstChildOfClass("Humanoid")
		if hrp and h and h.Health > 0 and ch:GetAttribute("HunterLive") and (hrp.CFrame.Position - pos).Magnitude <= radius then
			table.insert(out, { kind = "player", victim = player, pos = hrp.CFrame.Position })
		end
	end
	for _, r in Npcs.responders do
		local rr = r.model and r.model.PrimaryPart
		if rr and r.hum.Health > 0 and r.kind == "hunter" and (rr.CFrame.Position - pos).Magnitude <= radius then
			table.insert(out, { kind = "responder", victim = r, pos = rr.CFrame.Position })
		end
	end
	for _, c in Npcs.civilians do
		local cr = c.model and c.model.PrimaryPart
		if cr and c.state ~= "down" and c.state ~= "shelter" and (cr.CFrame.Position - pos).Magnitude <= radius then
			table.insert(out, { kind = "civilian", victim = c, pos = cr.CFrame.Position })
		end
	end
	return out
end

-- the one context MonsterAI works with (one object: what's in flight reads its clock)
local aiCtx: any = {
	now = 0,
	onHit = function() end,
	targets = Npcs.targetsNear,
	allies = function(m: any, radius: number): { any }
		local out = {}
		local root = m.model.PrimaryPart
		if not root then
			return out
		end
		for _, o in Npcs.monsters do
			local orr = o.model.PrimaryPart
			if o ~= m and o.incident == m.incident and orr and o.hum.Health > 0 and (orr.CFrame.Position - root.CFrame.Position).Magnitude <= radius then
				table.insert(out, o)
			end
		end
		return out
	end,
	spawn = function(kind: string, at: Vector3, master: any): any?
		return Npcs.spawnSummon(kind, at, master)
	end,
	fx = fireFx,
	move = function(m: any, pos: Vector3)
		m.hum:MoveTo(pos)
	end,
	whereIs = function(kind: string?, victim: any): Vector3?
		local r = rootOf(kind, victim)
		return r and r.CFrame.Position
	end,
	rand = function(): number
		return rng:NextNumber()
	end,
}
Npcs.aiCtx = aiCtx

-- hits: a callback the director gives, (attacker, victimKind, victim) -> ()
function Npcs.stepMonsters(onHit: (any, string, any) -> ())
	local now = os.clock()
	aiCtx.now = now
	aiCtx.onHit = onHit
	pcall(MonsterAI.update, Npcs.monsters, aiCtx)
	for _, m in table.clone(Npcs.monsters) do
		local root = m.model.PrimaryPart
		-- (what was called up goes when it's dead, when its time is up, or when its Gate is done)
		if m.summoned then
			local orphan = true
			for _, o in Npcs.monsters do
				if o.incident == m.incident and not o.summoned and o.hum.Health > 0 then
					orphan = false
					break
				end
			end
			if m.hum.Health <= 0 or now > (m.expires or math.huge) or orphan then
				if not m.goneAt then
					m.goneAt = now + 1.2
					if m.hum.Health > 0 then
						m.hum.Health = 0
					end
					local p = root and root.CFrame.Position
					if p then
						fireFx({ fx = "kill", at = { p.X, p.Y, p.Z }, rank = m.rank })
					end
				elseif now >= m.goneAt then
					Npcs.removeMonster(m)
				end
				continue
			end
		end
		if not root or m.hum.Health <= 0 then
			continue
		end
		-- the nearest living thing it can sense: a player character, a Hunter, a civilian (or
		-- whoever provoked it, for a few seconds)
		local best, bd, bk = nil, m.def.aggro or 90, nil
		local pv = Npcs.provoked and Npcs.provoked[m]
		local forced = pv and pv.untilT > now and pv.player.Character and pv.player.Character:FindFirstChild("HumanoidRootPart")
		if forced then
			best, bd, bk = pv.player, ((pv.player.Character.HumanoidRootPart :: BasePart).CFrame.Position - root.CFrame.Position).Magnitude, "player"
		else
			for _, v in Npcs.targetsNear(root.CFrame.Position, bd) do
				local d = (v.pos - root.CFrame.Position).Magnitude
				if d < bd then
					best, bd, bk = v.victim, d, v.kind
				end
			end
		end
		local pos = if best then (rootOf(bk, best) :: BasePart).CFrame.Position else nil
		local ok, err = pcall(MonsterAI.step, m, best, bk, pos, bd, aiCtx)
		if not ok then
			-- (if its own way of fighting fails, it still chases and strikes)
			if not m.warned then
				m.warned = true
				warn("[Npcs] " .. tostring(m.kind) .. ": " .. tostring(err))
			end
			if best and pos then
				m.hum:MoveTo(pos)
				if bd < m.def.reach and now > m.cool then
					m.cool = now + 1.1
					onHit(m, bk :: string, best)
				end
			else
				m.hum:MoveTo(m.home)
			end
		end
	end
end

return Npcs
