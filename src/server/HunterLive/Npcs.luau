--[[
	LIVE NPCs in the walkable city (server-side, so everyone sees the same people react):
		civilians   R6 people walking the sidewalks. Each has a temperament that decides what
		            they do when a Gate opens near them (ORIGINAL): most flee, some freeze, some
		            help others, some shelter in a doorway, a few stand and film it.
		responders  police at the cordon, the Association's measurement team, Hunters going in
		monsters    what comes out in a Dungeon Break: by rank (ORIGINAL looks), with hit points,
		            chasing the nearest living thing
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
						p.Transparency = if p.Name == "FacePlate" then 1 else 0
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
			p.Transparency = 0.5
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

-- ── monsters ──────────────────────────────────────────────────────────────
-- ORIGINAL looks by rank, built from parts on a Humanoid (HipHeight carries the body)
local MONSTER = {
	{ name = "Goblin", hp = 60, size = 0.7, color = Color3.fromRGB(96, 130, 70), eye = Color3.fromRGB(255, 220, 80), speed = 16, dmg = 8, shape = "biped" },
	{ name = "Armoured Beetle", hp = 130, size = 1, color = Color3.fromRGB(70, 76, 96), eye = Color3.fromRGB(140, 220, 255), speed = 14, dmg = 14, shape = "crawler" },
	{ name = "Orc", hp = 280, size = 1.35, color = Color3.fromRGB(92, 120, 70), eye = Color3.fromRGB(255, 80, 60), speed = 15, dmg = 24, shape = "biped" },
	{ name = "Ice Bear", hp = 560, size = 1.6, color = Color3.fromRGB(226, 232, 240), eye = Color3.fromRGB(120, 200, 255), speed = 18, dmg = 40, shape = "quad" },
	{ name = "Stone Golem", hp = 1100, size = 2.4, color = Color3.fromRGB(120, 116, 110), eye = Color3.fromRGB(255, 170, 60), speed = 11, dmg = 70, shape = "biped" },
	{ name = "Dragon-kin", hp = 2600, size = 3, color = Color3.fromRGB(46, 34, 66), eye = Color3.fromRGB(255, 60, 90), speed = 17, dmg = 120, shape = "quad" },
}
Npcs.MONSTER = MONSTER

local function weld(a: BasePart, b: BasePart)
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = b
end

local function monsterModel(rank: number): (Model, Humanoid)
	local def = MONSTER[rank]
	local s = def.size
	local model = Instance.new("Model")
	model.Name = def.name
	local function p(name, size, offset, color, mat, shape)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size * s
		part.Color = color or def.color
		part.Material = mat or Enum.Material.SmoothPlastic
		part.CanCollide = false
		part.Massless = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		if shape then
			part.Shape = shape
		end
		part.CFrame = CFrame.new(Vector3.new(0, 0, 0) + offset * s)
		part.Parent = model
		return part
	end
	local root = p("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0))
	root.Transparency = 1
	root.Massless = false
	root.CanCollide = true
	local parts = {}
	if def.shape == "biped" then
		table.insert(parts, p("Body", Vector3.new(2, 2.2, 1.2), Vector3.new(0, 3.1, 0)))
		table.insert(parts, p("Head", Vector3.new(1.3, 1.2, 1.2), Vector3.new(0, 4.9, -0.1)))
		table.insert(parts, p("ArmL", Vector3.new(0.8, 2.2, 0.8), Vector3.new(-1.5, 3, 0)))
		table.insert(parts, p("ArmR", Vector3.new(0.8, 2.2, 0.8), Vector3.new(1.5, 3, 0)))
		table.insert(parts, p("LegL", Vector3.new(0.9, 2, 0.9), Vector3.new(-0.55, 1, 0)))
		table.insert(parts, p("LegR", Vector3.new(0.9, 2, 0.9), Vector3.new(0.55, 1, 0)))
		for _, x in { -0.3, 0.3 } do
			table.insert(parts, p("Eye", Vector3.new(0.22, 0.18, 0.1), Vector3.new(x, 5.05, -0.72), def.eye, Enum.Material.Neon))
		end
	elseif def.shape == "crawler" then
		table.insert(parts, p("Shell", Vector3.new(3, 1.4, 4), Vector3.new(0, 1.4, 0), nil, Enum.Material.Metal))
		table.insert(parts, p("Head", Vector3.new(1.6, 0.9, 1), Vector3.new(0, 1.2, -2.4)))
		for k = -1, 1 do
			for _, x in { -1.8, 1.8 } do
				table.insert(parts, p("Leg", Vector3.new(0.3, 1.1, 0.3), Vector3.new(x, 0.55, k * 1.2), Color3.fromRGB(30, 30, 36)))
			end
		end
		for _, x in { -0.4, 0.4 } do
			table.insert(parts, p("Eye", Vector3.new(0.25, 0.25, 0.1), Vector3.new(x, 1.35, -2.92), def.eye, Enum.Material.Neon))
		end
	else -- quad
		table.insert(parts, p("Body", Vector3.new(2.6, 2.2, 4.6), Vector3.new(0, 2.6, 0)))
		table.insert(parts, p("Head", Vector3.new(1.8, 1.6, 1.8), Vector3.new(0, 3.2, -2.9)))
		for _, x in { -0.9, 0.9 } do
			for _, z in { -1.6, 1.6 } do
				table.insert(parts, p("Leg", Vector3.new(0.9, 1.6, 0.9), Vector3.new(x, 0.8, z)))
			end
			table.insert(parts, p("Eye", Vector3.new(0.25, 0.25, 0.1), Vector3.new(x * 0.45, 3.5, -3.82), def.eye, Enum.Material.Neon))
		end
		if rank >= 6 then
			for _, x in { -1, 1 } do
				table.insert(parts, p("Wing", Vector3.new(4, 0.2, 2.6), Vector3.new(x * 3, 3.6, 0.4), Color3.fromRGB(70, 40, 90)))
			end
		end
	end
	for _, part in parts do
		weld(root, part)
	end
	local glow = Instance.new("PointLight")
	glow.Color = def.eye
	glow.Range = 8 * s
	glow.Brightness = 1.5
	glow.Parent = root
	local hum = Instance.new("Humanoid")
	hum.RigType = Enum.HumanoidRigType.R6
	hum.HipHeight = 2 * s
	hum.WalkSpeed = def.speed
	hum.MaxHealth = def.hp
	hum.Health = def.hp
	hum.DisplayName = def.name
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	hum.NameDisplayDistance = 80
	hum.HealthDisplayDistance = 80
	hum.Parent = model
	model.PrimaryPart = root
	return model, hum
end

Npcs.monsterModel = monsterModel

function Npcs.spawnMonster(rank: number, at: Vector3, incidentId: number): any
	local model, hum = monsterModel(rank)
	-- (its pivot is its root: lift it so the feet start above the street, never under it)
	model:PivotTo(CFrame.new(at + Vector3.new(rng:NextNumber(-3, 3), 3 * MONSTER[rank].size + 1, rng:NextNumber(-3, 3))))
	model:SetAttribute("Incident", incidentId)
	model:SetAttribute("Rank", rank)
	model.Parent = folder
	pcall(function()
		(model.PrimaryPart :: BasePart):SetNetworkOwner(nil)
	end)
	local m = { model = model, hum = hum, rank = rank, def = MONSTER[rank], incident = incidentId, cool = 0, target = nil, home = at }
	table.insert(Npcs.monsters, m)
	return m
end

function Npcs.removeMonster(m: any)
	local i = table.find(Npcs.monsters, m)
	if i then
		table.remove(Npcs.monsters, i)
	end
	if m.model then
		m.model:Destroy()
	end
end

-- hits: a callback the director gives, (attacker, victimKind, victim) -> ()
function Npcs.stepMonsters(onHit: (any, string, any) -> ())
	local now = os.clock()
	for _, m in table.clone(Npcs.monsters) do
		local root = m.model.PrimaryPart
		if not root or m.hum.Health <= 0 then
			continue
		end
		-- the nearest living thing: a player character, a responder, a civilian
		local best, bd, bk = nil, 90, nil
		for _, player in Players:GetPlayers() do
			local ch = player.Character
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			if hrp and h and h.Health > 0 and ch:GetAttribute("HunterLive") then
				local d = (hrp.Position - root.Position).Magnitude
				if d < bd then
					best, bd, bk = player, d, "player"
				end
			end
		end
		for _, r in Npcs.responders do
			local rr = r.model.PrimaryPart
			if rr and r.hum.Health > 0 and r.kind == "hunter" then
				local d = (rr.Position - root.Position).Magnitude
				if d < bd then
					best, bd, bk = r, d, "responder"
				end
			end
		end
		for _, c in Npcs.civilians do
			local cr = c.model.PrimaryPart
			if cr and c.state ~= "down" and c.state ~= "shelter" then
				local d = (cr.Position - root.Position).Magnitude
				if d < bd then
					best, bd, bk = c, d, "civilian"
				end
			end
		end
		if best then
			local pos = if bk == "player" then (best.Character.HumanoidRootPart :: BasePart).Position else best.model.PrimaryPart.Position
			m.hum:MoveTo(pos)
			if bd < 5 + m.def.size * 2 and now > m.cool then
				m.cool = now + 1.1
				onHit(m, bk :: string, best)
			end
		else
			m.hum:MoveTo(m.home)
		end
	end
end

return Npcs
