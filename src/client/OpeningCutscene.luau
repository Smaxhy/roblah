--[[
	THE OPENING (BitLeveling): about fifty seconds, Skip ends it any time.

	A set is built far from everything, client-only, and the camera cuts between shots:
	   0- 6  SKY      the sky tears open over the city: a Gate in the clouds, lightning, mana
	                  falling like meteors
	   6-12  STREET   a Gate opens in a street at night: a shockwave, the asphalt cracks, people
	                  run past the camera
	  12-15  RESPONSE the Association's van brakes in behind the police cordon
	  15-35  THE RAID six Hunters walk up, each a different class in that class's gear, and each
	                  gets a moment: the Tanker's shield slam, the Fighter's greatsword, the
	                  Mage's circle and fireball, the Assassin's vanish, the Ranger's arrow, the
	                  Healer's light (with a card: the class and what it does)
	  35-40  BREAK    the Gate heaves and a High Orc Warlord forces its way out; the party throws
	                  it back (a taunt, a fireball, a charge)
	  40-47  INSIDE   they walk in one by one; the camera follows the last one through the
	                  whirlpool's tunnel into white
	  47-52  TITLE    BITLEVELING, letter by letter
	The Hunters are the real R6 rigs in the game's outfit presets (with the Blender mesh kit and
	cloth physics if the place has them); the monster is the live city's own (Hunter/Monsters,
	animated by client/MonsterAnim). Every cue is guarded: if one fails, the rest still plays.

		OpeningCutscene.play()   -- yields until it's over or skipped
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local GateVfx = require(script.Parent:WaitForChild("GateVfx"))

local OpeningCutscene = {}

local SET = Vector3.new(0, 0, 3000)
local GATE_Z = 150
local LINE_Z = 118 -- the party's line, in front of the cordon
local LENGTH = 52.5

local LINES = {
	{ 0.8, 5.6, "Ten years ago, the sky opened." },
	{ 6.4, 11.6, "Gates. Doors to somewhere else, with monsters on the other side." },
	{ 12.2, 14.8, "Then people began to wake up with power." },
	{ 15.2, 17.4, "The world calls them Hunters." },
	{ 35.4, 37.6, "Most raids are routine." },
	{ 37.8, 40.2, "Some aren't." },
	{ 41.0, 46.6, "And somewhere behind every Gate, a story that isn't anyone else's." },
}

-- the party: a class each, in that class's preset (Looks.PRESETS), with a weapon to match.
-- `look` is the fallback if a preset isn't there.
local PARTY = {
	{ class = "TANKER", line = "Holds the line.", preset = "tank", color = Color3.fromRGB(255, 170, 70), x = 0, z = 0, weapon = { base = "bulwark", stars = 3 }, look = { top = "tactical", topColor = "olive", armor = "heavy", armorColor = "slate", build = "broad" } },
	{ class = "FIGHTER", line = "Breaks what's in front of it.", preset = "striker", color = Color3.fromRGB(255, 90, 80), x = -5, z = -2, weapon = { base = "ogre_greatsword", stars = 2 }, look = { top = "guild", topColor = "crimson", armor = "plate" } },
	{ class = "MAGE", line = "Bends mana into fire and frost.", preset = "mage", color = Color3.fromRGB(110, 170, 255), x = 5, z = -2, weapon = { base = "sage_staff", stars = 3 }, look = { top = "robe", topColor = "navy", trim = "gold" } },
	{ class = "ASSASSIN", line = "Strikes before you see it.", preset = "assassin", color = Color3.fromRGB(180, 110, 255), x = -9, z = -5, weapon = { base = "shadowglass", stars = 2, shiny = true }, look = { top = "hoodie", topColor = "black", build = "slim" } },
	{ class = "RANGER", line = "Never misses twice.", preset = "ranger", color = Color3.fromRGB(120, 220, 130), x = 9, z = -5, weapon = { base = "wyvern_longbow", stars = 3 }, look = { top = "trench", topColor = "forest" } },
	{ class = "HEALER", line = "Brings everyone home.", preset = "healer", color = Color3.fromRGB(140, 255, 210), x = 0, z = -7, weapon = { base = "mercy_lantern", stars = 2 }, look = { top = "medic", topColor = "white", trim = "teal" } },
}

-- ── little builders ─────────────────────────────────────────────────────────
local function part(props: any, parent: Instance): BasePart
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

local function at(x: number, y: number, z: number): Vector3
	return SET + Vector3.new(x, y, z)
end

local function tween(obj: Instance, t: number, goal: any, style: Enum.EasingStyle?, dir: Enum.EasingDirection?)
	local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), goal)
	tw:Play()
	return tw
end

local function emitter(parent: Instance, props: any): ParticleEmitter
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.LightEmission = 1
	pe.Rate = 0
	for k, v in props do
		(pe :: any)[k] = v
	end
	pe.Parent = parent
	return pe
end

-- ── effects (all anchored neon and particles, gone when they're done) ─────────
local Fx = {}

function Fx.ring(folder: Instance, pos: Vector3, color: Color3, radius: number, life: number, height: number?)
	local p = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(height or 0.3, 1, 1), CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)), Color = color, Material = Enum.Material.Neon, Transparency = 0.1 }, folder)
	tween(p, life, { Size = Vector3.new(height or 0.3, radius * 2, radius * 2), Transparency = 1 })
	Debris:AddItem(p, life + 0.1)
end

function Fx.burst(folder: Instance, pos: Vector3, color: Color3, count: number, speed: number, life: number)
	local rng = Random.new()
	for _ = 1, count do
		local dir = rng:NextUnitVector()
		local s = rng:NextNumber(0.2, 0.6)
		local p = part({ Size = Vector3.new(s, s, s * 3), CFrame = CFrame.lookAt(pos, pos + dir), Color = color, Material = Enum.Material.Neon }, folder)
		tween(p, life, { CFrame = CFrame.lookAt(pos + dir * speed * rng:NextNumber(0.5, 1), pos + dir * (speed + 1)), Transparency = 1, Size = Vector3.new(0.05, 0.05, s) })
		Debris:AddItem(p, life + 0.1)
	end
end

function Fx.flash(folder: Instance, pos: Vector3, color: Color3, size: number, life: number)
	local p = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * size * 0.3, Position = pos, Color = color, Material = Enum.Material.Neon, Transparency = 0.05 }, folder)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = size * 3
	l.Brightness = 6
	l.Parent = p
	tween(p, life, { Size = Vector3.one * size, Transparency = 1 })
	tween(l, life, { Brightness = 0 })
	Debris:AddItem(p, life + 0.1)
end

function Fx.pillar(folder: Instance, pos: Vector3, color: Color3, height: number, life: number)
	local p = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(height, 0.5, 0.5), CFrame = CFrame.new(pos + Vector3.new(0, height / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = color, Material = Enum.Material.Neon, Transparency = 0.2 }, folder)
	tween(p, 0.35, { Size = Vector3.new(height, 5, 5) }, Enum.EasingStyle.Back)
	task.delay(life - 0.6, function()
		tween(p, 0.6, { Size = Vector3.new(height, 0.2, 0.2), Transparency = 1 })
	end)
	local motes = emitter(p, { Color = ColorSequence.new(color, Color3.new(1, 1, 1)), Rate = 40, Lifetime = NumberRange.new(1, 1.8), Speed = NumberRange.new(3, 7), SpreadAngle = Vector2.new(180, 180), Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) }) })
	local _ = motes
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = 30
	l.Brightness = 4
	l.Parent = p
	Debris:AddItem(p, life + 0.1)
end

-- a magic circle on the ground: two rings and runes turning the other way
function Fx.circle(folder: Instance, pos: Vector3, color: Color3, radius: number, life: number): Model
	local m = Instance.new("Model")
	m.Name = "MagicCircle"
	m.Parent = folder
	local parts = {}
	for k, r in { radius, radius * 0.72 } do
		local segs = 28
		for i = 1, segs do
			local a = (i / segs) * math.pi * 2
			local p = part({ Size = Vector3.new(r * math.pi * 2 / segs + 0.05, 0.08, 0.16), CFrame = CFrame.new(pos) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0.1, r), Color = color, Material = Enum.Material.Neon, Transparency = 1 }, m)
			tween(p, 0.4 + i * 0.01, { Transparency = 0.05 })
			table.insert(parts, { p = p, r = r, a = a, dir = if k == 1 then 1 else -1 })
		end
	end
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		local p = part({ Size = Vector3.new(0.6, 0.1, 0.6), CFrame = CFrame.new(pos) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0.12, radius * 0.86) * CFrame.Angles(0, math.rad(45), 0), Color = Color3.new(1, 1, 1):Lerp(color, 0.4), Material = Enum.Material.Neon, Transparency = 1 }, m)
		tween(p, 0.5, { Transparency = 0 })
		table.insert(parts, { p = p, r = radius * 0.86, a = a, dir = -1, rune = true })
	end
	local t = 0
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		t += dt
		if not m.Parent then
			conn:Disconnect()
			return
		end
		for _, q in parts do
			local a = q.a + t * 0.9 * q.dir
			q.p.CFrame = CFrame.new(pos) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0.1, q.r) * (if q.rune then CFrame.Angles(0, math.rad(45), 0) else CFrame.identity)
		end
	end)
	task.delay(life, function()
		for _, q in parts do
			tween(q.p, 0.4, { Transparency = 1 })
		end
		Debris:AddItem(m, 0.5)
	end)
	return m
end

-- something thrown: a glowing orb with a trail that flies to a point, then bursts
function Fx.projectile(folder: Instance, from: Vector3, to: Vector3, color: Color3, size: number, time: number, onHit: (() -> ())?)
	local p = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * size, Position = from, Color = color, Material = Enum.Material.Neon }, folder)
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, size * 0.4, 0)
	a0.Parent = p
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -size * 0.4, 0)
	a1.Parent = p
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = ColorSequence.new(color, Color3.new(1, 1, 1))
	trail.LightEmission = 1
	trail.Lifetime = 0.35
	trail.Transparency = NumberSequence.new(0, 1)
	trail.Parent = p
	emitter(p, { Texture = "rbxasset://textures/particles/fire_main.dds", Color = ColorSequence.new(color), Rate = 60, Lifetime = NumberRange.new(0.3, 0.5), Speed = NumberRange.new(1, 3), Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size * 0.8), NumberSequenceKeypoint.new(1, 0) }) })
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = 18
	l.Brightness = 4
	l.Parent = p
	local tw = tween(p, time, { Position = to }, Enum.EasingStyle.Linear)
	tw.Completed:Connect(function()
		Fx.flash(folder, to, color, size * 7, 0.5)
		Fx.burst(folder, to, color, 18, 9, 0.6)
		Fx.ring(folder, to, color, size * 5, 0.5)
		p:Destroy()
		if onHit then
			onHit()
		end
	end)
end

-- a slash: a thin crescent of light swept through the air
function Fx.slash(folder: Instance, cf: CFrame, color: Color3, length: number)
	local segs = 9
	for i = 1, segs do
		local a = math.rad(-70 + 140 * (i - 1) / (segs - 1))
		local p = part({ Size = Vector3.new(0.12, 0.35, length / segs * 1.6), CFrame = cf * CFrame.Angles(a, 0, 0) * CFrame.new(0, 0, -length * 0.5), Color = color, Material = Enum.Material.Neon, Transparency = 1 }, folder)
		task.delay(i * 0.015, function()
			p.Transparency = 0.05
			tween(p, 0.35, { Transparency = 1, Size = Vector3.new(0.05, 0.1, length / segs * 2) })
		end)
		Debris:AddItem(p, 0.6)
	end
end

function Fx.smoke(folder: Instance, pos: Vector3, color: Color3)
	local holder = part({ Size = Vector3.one, Position = pos, Transparency = 1 }, folder)
	local pe = emitter(holder, { Texture = "rbxasset://textures/particles/smoke_main.dds", LightEmission = 0, Color = ColorSequence.new(color), Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 6) }), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) }), Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(2, 6), SpreadAngle = Vector2.new(180, 180) })
	pe:Emit(40)
	Debris:AddItem(holder, 2)
end

-- lightning: a zig-zag of neon from a to b that flickers out
function Fx.bolt(folder: Instance, a: Vector3, b: Vector3, color: Color3)
	local rng = Random.new()
	local steps = 10
	local prev = a
	for i = 1, steps do
		local k = i / steps
		local nextP = a:Lerp(b, k) + (if i < steps then rng:NextUnitVector() * (b - a).Magnitude * 0.05 else Vector3.zero)
		local mid = (prev + nextP) / 2
		local p = part({ Size = Vector3.new(0.5, 0.5, (nextP - prev).Magnitude), CFrame = CFrame.lookAt(mid, nextP), Color = color, Material = Enum.Material.Neon }, folder)
		tween(p, 0.35, { Transparency = 1, Size = Vector3.new(0.1, 0.1, (nextP - prev).Magnitude) })
		Debris:AddItem(p, 0.4)
		prev = nextP
	end
end

-- ── the set ─────────────────────────────────────────────────────────────────
local function buildSet(folder: Instance, R6Rig: any, Looks: any)
	local rng = Random.new(4242)
	part({ Size = Vector3.new(260, 1, 460), Position = at(0, -0.5, 110), Color = Color3.fromRGB(34, 36, 40), Material = Enum.Material.Asphalt }, folder)
	for _, side in { -1, 1 } do
		part({ Size = Vector3.new(14, 1.2, 460), Position = at(side * 19, 0, 110), Color = Color3.fromRGB(110, 110, 108), Material = Enum.Material.Concrete }, folder)
		for k = 0, 11 do
			local h = rng:NextInteger(30, 120)
			local w = rng:NextInteger(18, 26)
			local z = -40 + k * 26
			local c = at(side * (38 + w / 2 - 8), 0, z)
			part({ Size = Vector3.new(w, h, 22), Position = c + Vector3.new(0, h / 2, 0), Color = Color3.fromRGB(rng:NextInteger(40, 70), rng:NextInteger(44, 72), rng:NextInteger(52, 84)), Material = Enum.Material.Concrete }, folder)
			for f = 1, math.floor(h / 8) do
				if rng:NextNumber() < 0.7 then
					part({ Size = Vector3.new(0.3, 2.4, 18), Position = c + Vector3.new(-side * (w / 2 + 0.05), f * 8 - 3, 0), Color = if rng:NextNumber() < 0.75 then Color3.fromRGB(255, 214, 150) else Color3.fromRGB(150, 200, 255), Material = Enum.Material.Neon, Transparency = 0.2 }, folder)
				end
			end
			if rng:NextNumber() < 0.45 then
				local sign = part({ Size = Vector3.new(0.6, rng:NextInteger(10, 20), 2.4), Position = c + Vector3.new(-side * (w / 2 + 1.5), h * 0.45, 0), Color = ({ Color3.fromRGB(255, 70, 110), Color3.fromRGB(70, 200, 255), Color3.fromRGB(255, 190, 60), Color3.fromRGB(150, 110, 255) })[rng:NextInteger(1, 4)], Material = Enum.Material.Neon }, folder)
				local l = Instance.new("PointLight")
				l.Color = sign.Color
				l.Range = 14
				l.Parent = sign
			end
		end
		for k = 0, 8 do
			local base = at(side * 13, 0, -30 + k * 26)
			part({ Size = Vector3.new(0.5, 15, 0.5), Position = base + Vector3.new(0, 7.5, 0), Color = Color3.fromRGB(30, 30, 34), Material = Enum.Material.Metal }, folder)
			local head = part({ Size = Vector3.new(1.4, 0.4, 2), Position = base + Vector3.new(-side * 1.6, 15, 0), Color = Color3.fromRGB(255, 232, 190), Material = Enum.Material.Neon }, folder)
			local l = Instance.new("SpotLight")
			l.Face = Enum.NormalId.Bottom
			l.Range = 30
			l.Angle = 110
			l.Brightness = 2.4
			l.Color = Color3.fromRGB(255, 220, 170)
			l.Parent = head
		end
	end
	for z = -40, 260, 12 do
		part({ Size = Vector3.new(0.5, 0.05, 6), Position = at(0, 0.02, z), Color = Color3.fromRGB(220, 200, 110), Material = Enum.Material.Neon, Transparency = 0.4 }, folder)
	end
	-- the cordon, the police cars and their light bars
	local bars = {}
	for k = -5, 5 do
		part({ Size = Vector3.new(3.4, 2, 0.4), Position = at(k * 3.6, 1.6, 126), Color = if k % 2 == 0 then Color3.fromRGB(240, 130, 30) else Color3.fromRGB(240, 240, 240) }, folder)
	end
	part({ Size = Vector3.new(40, 0.16, 0.05), Position = at(0, 2.5, 125.8), Color = Color3.fromRGB(250, 220, 40), Material = Enum.Material.Neon }, folder)
	for _, x in { -14, 14 } do
		local body = CFrame.new(at(x, 0, 104)) * CFrame.Angles(0, math.rad(if x < 0 then 25 else -25), 0)
		part({ Size = Vector3.new(6.4, 2.4, 13), CFrame = body * CFrame.new(0, 2, 0), Color = Color3.fromRGB(236, 236, 236) }, folder)
		part({ Size = Vector3.new(6.5, 0.8, 7), CFrame = body * CFrame.new(0, 2.2, 0), Color = Color3.fromRGB(20, 40, 110) }, folder)
		part({ Size = Vector3.new(5.8, 2, 7), CFrame = body * CFrame.new(0, 4.1, 0.6), Color = Color3.fromRGB(30, 40, 50), Material = Enum.Material.Glass, Transparency = 0.2 }, folder)
		for j, col in { Color3.fromRGB(255, 40, 40), Color3.fromRGB(40, 90, 255) } do
			local b = part({ Size = Vector3.new(1.6, 0.5, 0.9), CFrame = body * CFrame.new(j * 2 - 3, 5.3, 0.6), Color = col, Material = Enum.Material.Neon }, folder)
			local l = Instance.new("PointLight")
			l.Color = col
			l.Range = 22
			l.Brightness = 3
			l.Parent = b
			table.insert(bars, b)
		end
	end
	-- the Association's van (it drives in: a Model so it moves as one)
	local van = Instance.new("Model")
	van.Name = "Van"
	local vroot = part({ Size = Vector3.new(7, 7, 16), CFrame = CFrame.new(at(0, 4, 0)), Color = Color3.fromRGB(240, 242, 246) }, van)
	part({ Size = Vector3.new(7.1, 1.2, 16.1), CFrame = CFrame.new(at(0, 3.2, 0)), Color = Color3.fromRGB(28, 70, 160) }, van)
	part({ Size = Vector3.new(6.6, 2.4, 0.2), CFrame = CFrame.new(at(0, 5.2, -8.05)), Color = Color3.fromRGB(30, 40, 50), Material = Enum.Material.Glass }, van)
	for _, x in { -2.6, 2.6 } do
		part({ Size = Vector3.new(1.2, 0.6, 0.2), CFrame = CFrame.new(at(x, 2.6, -8.05)), Color = Color3.fromRGB(255, 250, 220), Material = Enum.Material.Neon }, van)
	end
	van.PrimaryPart = vroot
	van.Parent = folder
	-- people at the tape (and the ones who'll run past the camera)
	local function person(seed: number, still: boolean): Model
		local r = Random.new(seed)
		local look = Looks.random(function(a, b)
			return r:NextInteger(a, b)
		end, { civilian = true })
		local m = R6Rig.build(look, { name = "Civilian", npc = true, civilian = true })
		-- someone standing still is anchored whole; a runner only at the root (its limbs swing)
		for _, d in m:GetDescendants() do
			if d:IsA("BasePart") and (still or d.Name == "HumanoidRootPart") then
				d.Anchored = true
			end
		end
		return m
	end
	local crowd = {}
	for k = 1, 8 do
		local m = person(100 + k, true)
		local x = (if k % 2 == 0 then 1 else -1) * (8 + rng:NextNumber() * 8)
		m:PivotTo(CFrame.lookAt(at(x, 3, 92 + rng:NextNumber() * 5), at(0, 3, GATE_Z)))
		local arm = m:FindFirstChild("Right Arm") :: BasePart?
		if arm and k % 3 ~= 0 then
			R6Rig.shell(m, arm, "Phone", Vector3.new(0.5, 0.9, 0.12), CFrame.new(0, -1.1, -0.4), Color3.fromRGB(20, 20, 24), Enum.Material.Glass)
		end
		m.Parent = folder
		table.insert(crowd, m)
	end
	local runners = {}
	for k = 1, 9 do
		local m = person(300 + k, false)
		m.Parent = folder
		table.insert(runners, { model = m, x = rng:NextNumber(-11, 11), z0 = GATE_Z - 12 - rng:NextNumber() * 18, speed = rng:NextNumber(15, 21), delay = rng:NextNumber(0, 1.4) })
	end
	return bars, crowd, runners, van
end

local function loopAnim(model: Model, R6Rig: any, which: string, speed: number?): AnimationTrack?
	local hum = model:FindFirstChildOfClass("Humanoid")
	local animator = hum and hum:FindFirstChildOfClass("Animator")
	if not animator then
		return nil
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = R6Rig.ANIMS[which] or R6Rig.ANIMS.idle
	local ok, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)
	if ok and track then
		track.Looped = true
		track:Play(0.1)
		track:AdjustSpeed(speed or 1)
		return track
	end
	return nil
end

-- swing an arm: the shoulder's C0 turned forward and back (works with or without an animation)
local function swingArm(model: Model, side: string, up: number, hold: number, down: number?)
	local torso = model:FindFirstChild("Torso")
	local joint = torso and torso:FindFirstChild(side .. " Shoulder") :: Motor6D?
	if not joint then
		return
	end
	local base = joint.C0
	local sign = if side == "Right" then 1 else -1
	tween(joint, up, { C0 = base * CFrame.Angles(0, 0, math.rad(150) * sign) }, Enum.EasingStyle.Back)
	task.delay(up + hold, function()
		tween(joint, down or 0.18, { C0 = base * CFrame.Angles(0, 0, math.rad(-20) * sign) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay((down or 0.18) + 0.4, function()
			tween(joint, 0.4, { C0 = base })
		end)
	end)
end

local function letterbox(gui: ScreenGui): (Frame, Frame)
	local top = Instance.new("Frame")
	top.BackgroundColor3 = Color3.new(0, 0, 0)
	top.BorderSizePixel = 0
	top.Size = UDim2.fromScale(1, 0.11)
	top.ZIndex = 2
	top.Parent = gui
	local bottom = top:Clone()
	bottom.AnchorPoint = Vector2.new(0, 1)
	bottom.Position = UDim2.fromScale(0, 1)
	bottom.Parent = gui
	return top, bottom
end

local function ease(k: number): number
	k = math.clamp(k, 0, 1)
	return k * k * (3 - 2 * k)
end

function OpeningCutscene.play()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local shared = ReplicatedStorage:WaitForChild("LifeSim", 20)
	local hunter = shared and shared:WaitForChild("Hunter", 10)
	if not hunter then
		return
	end
	local R6Rig = require(hunter:WaitForChild("R6Rig"))
	local Looks = require(hunter:WaitForChild("Looks"))
	local okM, Monsters = pcall(require, hunter:WaitForChild("Monsters", 5))
	local okA, MonsterAnim = pcall(require, script.Parent:WaitForChild("MonsterAnim", 5))
	local hairCache = ReplicatedStorage:FindFirstChild("HunterHairCache")
	local camera = Workspace.CurrentCamera
	while not camera do
		task.wait()
		camera = Workspace.CurrentCamera
	end

	-- night, fog, bloom, and a grade that can flash red
	local saved = { ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor }
	Lighting.ClockTime = 0.3
	Lighting.Brightness = 1.2
	Lighting.Ambient = Color3.fromRGB(40, 46, 70)
	Lighting.OutdoorAmbient = Color3.fromRGB(50, 56, 84)
	Lighting.FogStart = 140
	Lighting.FogEnd = 760
	Lighting.FogColor = Color3.fromRGB(14, 18, 34)
	local bloom = Instance.new("BloomEffect")
	bloom.Name = "OpeningBloom"
	bloom.Intensity = 1.1
	bloom.Size = 30
	bloom.Threshold = 0.85
	bloom.Parent = Lighting
	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "OpeningGrade"
	grade.Saturation = 0.1
	grade.Contrast = 0.1
	grade.Parent = Lighting

	local folder = Instance.new("Folder")
	folder.Name = "OpeningCutscene"
	folder.Parent = Workspace
	local bars, _crowd, runners, van = buildSet(folder, R6Rig, Looks)
	local skyC = at(0, 150, GATE_Z + 140)
	local skyGate = GateVfx.new(folder, CFrame.new(skyC) * CFrame.Angles(math.rad(-20), 0, 0), 34, { rank = 6 })
	local gateC = at(0, 13, GATE_Z)
	local gate = GateVfx.new(folder, CFrame.new(gateC), 11.5, { rank = 4 })

	-- the party, in their class presets, standing out of shot until they walk up
	local party = {}
	for i, p in PARTY do
		local look = Looks.applyPreset(Looks.DEFAULT, p.preset)
		if not Looks.find("PRESETS", p.preset) then
			for k, v in p.look do
				look[k] = v
			end
			look = Looks.clean(look)
		end
		local hair = nil
		if hairCache then
			local h = hairCache:FindFirstChild(tostring(look.hair))
			hair = h and h:Clone()
		end
		local ok, m = pcall(R6Rig.build, look, { name = p.class, hair = hair, weapon = p.weapon, rank = 4 + (i % 3) })
		if ok and m then
			local root = m:FindFirstChild("HumanoidRootPart") :: BasePart
			root.Anchored = true
			m:PivotTo(CFrame.new(at(p.x, 3, LINE_Z + p.z - 40)))
			m.Parent = folder
			table.insert(party, { def = p, model = m, root = root, inside = false, walk = nil, idle = nil })
		end
	end

	-- the monster that tries to get out
	local brute, bruteRig = nil, nil
	if okM and Monsters then
		local ok, m = pcall(Monsters.build, "warlord")
		if ok and m then
			-- the root is anchored; the limbs hang on their joints so MonsterAnim can move them
			(m.PrimaryPart :: BasePart).Anchored = true
			m:PivotTo(CFrame.new(at(0, -60, GATE_Z)))
			m.Parent = folder
			brute = m
			if okA and MonsterAnim then
				bruteRig = MonsterAnim.rig(m)
			end
		end
	end

	-- the screen
	local gui = Instance.new("ScreenGui")
	gui.Name = "OpeningCutsceneGui"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 100
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	local fade = Instance.new("Frame")
	fade.Size = UDim2.fromScale(1, 1)
	fade.BackgroundColor3 = Color3.new(0, 0, 0)
	fade.BorderSizePixel = 0
	fade.ZIndex = 8
	fade.Parent = gui
	letterbox(gui)
	local caption = Instance.new("TextLabel")
	caption.AnchorPoint = Vector2.new(0.5, 1)
	caption.Position = UDim2.new(0.5, 0, 0.87, -10)
	caption.Size = UDim2.new(0.8, 0, 0, 40)
	caption.BackgroundTransparency = 1
	caption.TextColor3 = Color3.fromRGB(230, 236, 255)
	caption.TextStrokeTransparency = 0.5
	caption.Font = Enum.Font.GothamMedium
	caption.TextScaled = true
	caption.Text = ""
	caption.TextTransparency = 1
	caption.ZIndex = 3
	caption.Parent = gui
	-- the class card (slides in from the left for each Hunter's moment)
	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0, 0.5)
	card.Position = UDim2.new(-0.5, 0, 0.5, 0)
	card.Size = UDim2.fromScale(0.34, 0.16)
	card.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
	card.BackgroundTransparency = 0.25
	card.BorderSizePixel = 0
	card.ZIndex = 4
	card.Parent = gui
	local cardBar = Instance.new("Frame")
	cardBar.Size = UDim2.new(0, 6, 1, 0)
	cardBar.BorderSizePixel = 0
	cardBar.ZIndex = 5
	cardBar.Parent = card
	local cardTitle = Instance.new("TextLabel")
	cardTitle.Position = UDim2.new(0, 22, 0.08, 0)
	cardTitle.Size = UDim2.new(1, -30, 0.5, 0)
	cardTitle.BackgroundTransparency = 1
	cardTitle.Font = Enum.Font.GothamBlack
	cardTitle.TextScaled = true
	cardTitle.TextXAlignment = Enum.TextXAlignment.Left
	cardTitle.TextColor3 = Color3.new(1, 1, 1)
	cardTitle.ZIndex = 5
	cardTitle.Parent = card
	local cardLine = cardTitle:Clone()
	cardLine.Position = UDim2.new(0, 22, 0.58, 0)
	cardLine.Size = UDim2.new(1, -30, 0.3, 0)
	cardLine.Font = Enum.Font.GothamMedium
	cardLine.TextColor3 = Color3.fromRGB(210, 216, 230)
	cardLine.Parent = card
	local function showCard(p: any)
		cardBar.BackgroundColor3 = p.color
		cardTitle.Text = p.class
		cardTitle.TextColor3 = Color3.new(1, 1, 1):Lerp(p.color, 0.45)
		cardLine.Text = p.line
		card.Position = UDim2.new(-0.5, 0, 0.5, 0)
		tween(card, 0.4, { Position = UDim2.new(0.04, 0, 0.5, 0) }, Enum.EasingStyle.Back)
		task.delay(2.4, function()
			tween(card, 0.3, { Position = UDim2.new(-0.5, 0, 0.5, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end)
	end
	local skip = Instance.new("TextButton")
	skip.AnchorPoint = Vector2.new(1, 0)
	skip.Position = UDim2.new(1, -16, 0, 16)
	skip.Size = UDim2.fromOffset(110, 34)
	skip.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	skip.BackgroundTransparency = 0.2
	skip.TextColor3 = Color3.fromRGB(220, 226, 240)
	skip.Font = Enum.Font.GothamBold
	skip.TextSize = 15
	skip.Text = "SKIP  >"
	skip.ZIndex = 9
	skip.Parent = gui
	Instance.new("UICorner").Parent = skip
	-- the title: one label a letter, so they can drop in one by one
	local titleHolder = Instance.new("Frame")
	titleHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	titleHolder.Position = UDim2.fromScale(0.5, 0.45)
	titleHolder.Size = UDim2.fromScale(0.8, 0.16)
	titleHolder.BackgroundTransparency = 1
	titleHolder.ZIndex = 9
	titleHolder.Parent = gui
	local letters = {}
	local word = "BITLEVELING"
	for i = 1, #word do
		local l = Instance.new("TextLabel")
		l.AnchorPoint = Vector2.new(0.5, 0.5)
		l.Size = UDim2.fromScale(1 / #word, 1)
		l.Position = UDim2.fromScale((i - 0.5) / #word, -0.6)
		l.BackgroundTransparency = 1
		l.Text = string.sub(word, i, i)
		l.Font = Enum.Font.GothamBlack
		l.TextScaled = true
		l.TextColor3 = Color3.fromRGB(160, 210, 255)
		l.TextStrokeColor3 = Color3.fromRGB(40, 90, 200)
		l.TextStrokeTransparency = 0.3
		l.TextTransparency = 1
		l.ZIndex = 9
		l.Parent = titleHolder
		table.insert(letters, l)
	end
	local sub = Instance.new("TextLabel")
	sub.AnchorPoint = Vector2.new(0.5, 0.5)
	sub.Position = UDim2.fromScale(0.5, 0.58)
	sub.Size = UDim2.fromScale(0.6, 0.05)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.GothamMedium
	sub.TextScaled = true
	sub.Text = "Not every Hunter is the hero of the story."
	sub.TextColor3 = Color3.fromRGB(200, 210, 230)
	sub.TextTransparency = 1
	sub.ZIndex = 9
	sub.Parent = gui

	local done = false
	skip.Activated:Connect(function()
		done = true
	end)
	tween(fade, 1.4, { BackgroundTransparency = 1 })

	-- models gliding somewhere over time (stepped by the main loop below)
	local movers = {}
	local tNow = 0
	local function move(model: Model, goal: CFrame, dur: number, style: string?)
		table.insert(movers, { model = model, from = model:GetPivot(), to = goal, t0 = tNow, dur = dur, style = style or "out" })
	end
	local function stepMovers()
		for i = #movers, 1, -1 do
			local mv = movers[i]
			local k = math.clamp((tNow - mv.t0) / mv.dur, 0, 1)
			local e = if mv.style == "in" then k * k * k elseif mv.style == "linear" then k else 1 - (1 - k) ^ 3
			if mv.model.Parent then
				mv.model:PivotTo(mv.from:Lerp(mv.to, e))
			end
			if k >= 1 then
				table.remove(movers, i)
			end
		end
	end

	-- ── the cues: things that happen once, at a time ──
	local shake = 0
	local function cue(fn: () -> ())
		local ok, err = pcall(fn)
		if not ok then
			warn("[BitLeveling] opening cue failed: " .. tostring(err))
		end
	end
	local function heroAt(i: number): any
		return party[i]
	end
	local function handOf(m: any): Vector3
		local arm = m.model:FindFirstChild("Right Arm") :: BasePart?
		return if arm then (arm.CFrame * CFrame.new(0, -1.2, 0)).Position else m.root.CFrame.Position
	end
	local cues = {
		-- the sky splits: the high Gate opens with lightning and meteors
		{ 0.6, function()
			skyGate:open(2.4)
		end },
		{ 1.4, function()
			Fx.bolt(folder, skyC + Vector3.new(-40, 20, 0), skyC + Vector3.new(-10, -40, -20), Color3.fromRGB(180, 210, 255))
			Lighting.Brightness = 3
			tween(Lighting, 0.4, { Brightness = 1.2 })
		end },
		{ 2.3, function()
			for k = 1, 5 do
				task.delay(k * 0.35, function()
					local from = skyC + Vector3.new(math.random(-60, 60), math.random(-10, 10), math.random(-20, 20))
					Fx.projectile(folder, from, at(math.random(-120, 120), 0, math.random(200, 400)), Color3.fromRGB(120, 180, 255), 2.4, 1.4)
				end)
			end
		end },
		{ 3.6, function()
			Fx.bolt(folder, skyC + Vector3.new(30, 25, 0), skyC + Vector3.new(60, -60, -10), Color3.fromRGB(200, 220, 255))
			Lighting.Brightness = 3.4
			tween(Lighting, 0.4, { Brightness = 1.2 })
			shake = 0.5
		end },
		-- a Gate opens in the street
		{ 6.2, function()
			gate:open(1.4)
			Fx.ring(folder, at(0, 0.3, GATE_Z), Color3.fromRGB(120, 190, 255), 50, 1.2)
			Fx.flash(folder, gateC, Color3.fromRGB(190, 225, 255), 30, 0.8)
			shake = 1.2
			-- the asphalt cracks, glowing
			local rng = Random.new(7)
			for _ = 1, 16 do
				local a = rng:NextNumber(0, math.pi * 2)
				local len = rng:NextNumber(6, 18)
				local mid = at(math.cos(a) * len * 0.6, 0.06, GATE_Z + math.sin(a) * len * 0.6)
				local crack = part({ Size = Vector3.new(rng:NextNumber(0.3, 0.8), 0.06, len), CFrame = CFrame.lookAt(mid, at(0, 0.06, GATE_Z)), Color = Color3.fromRGB(110, 180, 255), Material = Enum.Material.Neon, Transparency = 1 }, folder)
				tween(crack, 0.3, { Transparency = 0.15 })
			end
		end },
		{ 6.9, function()
			for _, r in runners do
				r.go = true
			end
		end },
		-- the van brakes in
		{ 12.0, function()
			van:PivotTo(CFrame.new(at(-15, 4, 40)))
			move(van, CFrame.new(at(-15, 4, 92)) * CFrame.Angles(0, math.rad(12), 0), 2.2)
		end },
		{ 14.3, function()
			Fx.smoke(folder, at(-15, 1, 92), Color3.fromRGB(80, 80, 90))
		end },
		-- the party walks up
		{ 14.8, function()
			for _, m in party do
				m.walk = loopAnim(m.model, R6Rig, "walk", 0.8)
				m.walking = true
			end
		end },
		{ 19.0, function()
			for _, m in party do
				m.walking = false
				if m.walk then
					m.walk:Stop(0.3)
				end
				m.idle = loopAnim(m.model, R6Rig, "idle", 1)
			end
		end },
		-- the Tanker: a shield slam
		{ 19.3, function()
			local h = heroAt(1)
			if h then
				showCard(h.def)
				swingArm(h.model, "Left", 0.25, 0.25, 0.12)
				task.delay(0.6, function()
					Fx.ring(folder, h.root.CFrame.Position - Vector3.new(0, 2.8, 0), h.def.color, 18, 0.7, 0.5)
					Fx.burst(folder, h.root.CFrame.Position - Vector3.new(0, 2, -1), Color3.fromRGB(150, 140, 120), 16, 6, 0.6)
					Fx.smoke(folder, h.root.CFrame.Position - Vector3.new(0, 2.5, 0), Color3.fromRGB(120, 110, 100))
					shake = 1.0
				end)
			end
		end },
		-- the Fighter: a greatsword cleave
		{ 22.0, function()
			local h = heroAt(2)
			if h then
				showCard(h.def)
				swingArm(h.model, "Right", 0.3, 0.2, 0.12)
				task.delay(0.55, function()
					Fx.slash(folder, h.root.CFrame * CFrame.new(0, 0.5, 0), h.def.color, 10)
					Fx.burst(folder, h.root.CFrame.Position + Vector3.new(0, 0, 5), Color3.fromRGB(255, 220, 160), 14, 7, 0.5)
					shake = 0.6
				end)
			end
		end },
		-- the Mage: a circle, a rising sun of fire
		{ 24.7, function()
			local h = heroAt(3)
			if h then
				showCard(h.def)
				Fx.circle(folder, h.root.CFrame.Position - Vector3.new(0, 2.9, 0), h.def.color, 5, 2.4)
				swingArm(h.model, "Right", 0.5, 1.2, 0.3)
				task.delay(0.8, function()
					local hand = handOf(h) + Vector3.new(0, 3, 0)
					Fx.flash(folder, hand, Color3.fromRGB(255, 160, 60), 6, 1.4)
					Fx.projectile(folder, hand, hand + Vector3.new(0, 26, 30), Color3.fromRGB(255, 130, 50), 2, 1.1)
				end)
			end
		end },
		-- the Assassin: gone in smoke, back behind the line with afterimages
		{ 27.4, function()
			local h = heroAt(4)
			if h then
				showCard(h.def)
				Fx.smoke(folder, h.root.CFrame.Position, Color3.fromRGB(40, 30, 60))
				local start = h.root.CFrame
				for _, d in h.model:GetDescendants() do
					if d:IsA("BasePart") and d.Transparency < 1 then
						d:SetAttribute("BaseT", d.Transparency)
						d.Transparency = 1
					end
				end
				task.delay(0.6, function()
					local target = start * CFrame.new(10, 0, -6)
					for k = 1, 4 do
						local ghost = part({ Size = Vector3.new(2, 5, 1), CFrame = start:Lerp(target, k / 4), Color = h.def.color, Material = Enum.Material.Neon, Transparency = 0.5 }, folder)
						tween(ghost, 0.5, { Transparency = 1 })
						Debris:AddItem(ghost, 0.6)
					end
					h.model:PivotTo(target)
					for _, d in h.model:GetDescendants() do
						if d:IsA("BasePart") and d:GetAttribute("BaseT") ~= nil then
							d.Transparency = d:GetAttribute("BaseT")
						end
					end
					Fx.flash(folder, target.Position, h.def.color, 7, 0.4)
					Fx.slash(folder, target * CFrame.Angles(0, math.rad(90), 0), h.def.color, 6)
				end)
			end
		end },
		-- the Ranger: an arrow into the sky
		{ 30.1, function()
			local h = heroAt(5)
			if h then
				showCard(h.def)
				swingArm(h.model, "Left", 0.3, 0.9, 0.2)
				task.delay(0.9, function()
					local from = handOf(h) + Vector3.new(0, 2, 0)
					Fx.projectile(folder, from, from + Vector3.new(-4, 60, 40), h.def.color, 0.8, 0.7, function()
						Fx.ring(folder, from + Vector3.new(-4, 60, 40), h.def.color, 12, 0.6)
					end)
				end)
			end
		end },
		-- the Healer: a pillar of light, everyone's wounds closing
		{ 32.8, function()
			local h = heroAt(6)
			if h then
				showCard(h.def)
				Fx.pillar(folder, h.root.CFrame.Position - Vector3.new(0, 3, 0), h.def.color, 40, 2.4)
				for _, m in party do
					task.delay(math.random() * 0.6, function()
						Fx.flash(folder, m.root.CFrame.Position, h.def.color, 5, 0.8)
					end)
				end
			end
		end },
		-- the break: the Gate heaves red, a Warlord forces its way out
		{ 35.6, function()
			gate:surge(1.2)
			grade.TintColor = Color3.fromRGB(255, 170, 170)
			tween(grade, 1.5, { TintColor = Color3.fromRGB(255, 225, 225) })
			shake = 1.4
			if brute then
				brute:PivotTo(CFrame.lookAt(at(0, 6, GATE_Z + 2), at(0, 6, LINE_Z)))
				move(brute, CFrame.lookAt(at(0, 6, GATE_Z - 12), at(0, 6, LINE_Z)), 1.6)
			end
		end },
		{ 37.0, function()
			if brute then
				Fx.ring(folder, at(0, 0.4, GATE_Z - 12), Color3.fromRGB(255, 80, 60), 26, 0.8)
				brute:SetAttribute("Attacking", 1)
				shake = 1.6
			end
			local t1 = heroAt(1)
			if t1 then
				Fx.ring(folder, t1.root.CFrame.Position, Color3.fromRGB(255, 200, 80), 30, 0.7, 1) -- the taunt
			end
		end },
		{ 38.0, function()
			local m = heroAt(3)
			if m and brute then
				local from = handOf(m) + Vector3.new(0, 1, 0)
				Fx.projectile(folder, from, at(0, 7, GATE_Z - 12), Color3.fromRGB(255, 120, 40), 2.2, 0.6, function()
					shake = 1.8
				end)
			end
			local f = heroAt(2)
			if f then
				move(f.model, CFrame.lookAt(at(-2, 3, GATE_Z - 18), at(0, 3, GATE_Z)), 0.5)
				task.delay(0.5, function()
					swingArm(f.model, "Right", 0.1, 0.05, 0.1)
					Fx.slash(folder, CFrame.new(at(-1, 4, GATE_Z - 16)), Color3.fromRGB(255, 90, 80), 12)
				end)
			end
		end },
		{ 39.0, function()
			if brute then
				Fx.burst(folder, at(0, 6, GATE_Z - 12), Color3.fromRGB(140, 200, 255), 30, 10, 0.9)
				Fx.flash(folder, at(0, 6, GATE_Z - 12), Color3.fromRGB(200, 230, 255), 16, 0.6)
				move(brute, CFrame.lookAt(at(0, 6, GATE_Z + 4), at(0, 6, LINE_Z)), 0.8, "in")
				task.delay(0.8, function()
					brute.Parent = nil
					gate:surge(0.8)
				end)
			end
		end },
		-- in, one by one
		{ 40.6, function()
			for i, m in party do
				if m.idle then
					m.idle:Stop(0.2)
				end
				task.delay((i - 1) * 0.55, function()
					m.walk = loopAnim(m.model, R6Rig, "walk", 1.1)
					m.entering = true
				end)
			end
		end },
	}
	table.sort(cues, function(a, b)
		return a[1] < b[1]
	end)
	local nextCue = 1

	-- ── the camera, shot by shot ──
	local function shot(t: number): (Vector3, Vector3, number)
		if t < 6 then
			local k = ease(t / 6)
			return at(-10 + 6 * k, 3, 20 + 30 * k), skyC + Vector3.new(0, -10 * k, 0), 62 - 10 * k
		elseif t < 12 then
			local k = ease((t - 6) / 6)
			return at(4 - 3 * k, 1.6, GATE_Z - 46 + 10 * k), gateC + Vector3.new(0, -3, 0), 58
		elseif t < 15 then
			local k = ease((t - 12) / 3)
			return at(-30 + 6 * k, 7, 84 + 6 * k), at(-15, 4, 92), 50
		elseif t < 19 then
			-- they walk toward the camera (it stands between them and the Gate)
			local k = ease((t - 15) / 4)
			return at(0, 2.4 + k * 0.6, LINE_Z + 14 - 3 * k), at(0, 4.2, LINE_Z - 12 + 6 * k), 50
		elseif t < 35.2 then
			-- each Hunter's moment: the camera finds them, low, from the front
			local i = math.clamp(math.floor((t - 19) / 2.7) + 1, 1, #party)
			local h = party[i]
			local k = ((t - 19) % 2.7) / 2.7
			if h then
				local p = h.root.CFrame.Position
				local side = if h.def.x >= 0 then 1 else -1
				return p + Vector3.new(side * (5 - 1.5 * k), 1.2 + k * 0.4, 8 - 2 * k), p + Vector3.new(0, 1.2, 0), 46 - 6 * k
			end
			return at(0, 4, LINE_Z + 12), at(0, 4, LINE_Z), 50
		elseif t < 40.4 then
			local k = ease((t - 35.2) / 5.2)
			return at(10 - 4 * k, 3 + k, LINE_Z - 16 + 2 * k), at(0, 6, GATE_Z - 10), 56 - 8 * k
		elseif t < 47.4 then
			local k = ease((t - 40.4) / 7)
			local start = at(0, 6, LINE_Z - 18)
			local finish = gateC + Vector3.new(0, 0, 4)
			return start:Lerp(finish, k), gateC + Vector3.new(0, 0, 20), 70 - 30 * k + (if k > 0.85 then (k - 0.85) * 300 else 0)
		end
		return at(0, 6, GATE_Z + 40), at(0, 6, GATE_Z + 80), 70
	end

	camera.CameraType = Enum.CameraType.Scriptable
	local t = 0
	local flashed = false
	local tunnel = {}
	local conn = RunService.RenderStepped:Connect(function(dt)
		t += dt
		tNow = t
		stepMovers()
		gate:step(dt)
		skyGate:step(dt)
		while nextCue <= #cues and t >= cues[nextCue][1] do
			cue(cues[nextCue][2])
			nextCue += 1
		end
		-- people running past the camera
		for _, r in runners do
			if r.go then
				r.t = (r.t or -r.delay) + dt
				if r.t > 0 then
					if not r.anim then
						r.anim = loopAnim(r.model, R6Rig, "run", 1.6)
					end
					local z = r.z0 - r.speed * r.t
					r.model:PivotTo(CFrame.lookAt(at(r.x, 3, z), at(r.x, 3, z - 10)))
				end
			end
		end
		-- the party: walking up to their line, then into the Gate
		for i, m in party do
			if m.walking then
				local k = math.clamp((t - 14.8) / 4.2, 0, 1)
				local z = LINE_Z + m.def.z - 40 * (1 - k)
				m.root.CFrame = CFrame.lookAt(at(m.def.x, 3, z), at(m.def.x, 3, z + 10))
			elseif m.entering and not m.inside then
				m.enterT = (m.enterT or 0) + dt
				local p = m.root.CFrame.Position
				local goal = at(0, 3, GATE_Z)
				local step = (goal - p) * Vector3.new(1, 0, 1)
				if step.Magnitude < 2 then
					m.inside = true
					GateVfx.flash(folder, p + Vector3.new(0, 1, 2), Color3.fromRGB(190, 225, 255), 9, 0.5)
					gate:surge(0.7)
					m.model.Parent = nil
				else
					local np = p + step.Unit * math.min(step.Magnitude, 9 * dt)
					m.model:PivotTo(CFrame.lookAt(np, np + step.Unit))
				end
			end
			local _ = i
		end
		-- the Warlord breathes and swings (its own procedural animation)
		if brute and bruteRig and okA then
			pcall(MonsterAnim.animate, bruteRig, dt, t)
		end
		for k, b in bars do
			b.Transparency = if (math.floor(t * 6) + k) % 2 == 0 then 0 else 0.85
		end
		-- the camera, with a shake that dies away
		local eye, target, fov = shot(t)
		if shake > 0.01 then
			eye += Vector3.new((math.random() - 0.5) * shake, (math.random() - 0.5) * shake, 0)
			shake *= math.exp(-dt * 4)
		end
		camera.CFrame = CFrame.lookAt(eye, target)
		camera.FieldOfView = math.clamp(fov, 20, 120)
		-- through the whirlpool: rings of light rushing past
		if t > 45.4 and t < 47.8 then
			if #tunnel < 18 and math.random() < 0.6 then
				local ring = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 26, 26), CFrame = CFrame.new(eye + camera.CFrame.LookVector * 40) * CFrame.Angles(0, math.rad(90), 0), Color = Color3.fromRGB(math.random(80, 160), math.random(150, 220), 255), Material = Enum.Material.ForceField, Transparency = 0.2 }, folder)
				table.insert(tunnel, ring)
			end
			for i = #tunnel, 1, -1 do
				local r = tunnel[i]
				r.CFrame = r.CFrame * CFrame.new(-dt * 60, 0, 0) * CFrame.Angles(dt * 3, 0, 0)
				if (r.CFrame.Position - eye):Dot(camera.CFrame.LookVector) < 0 then
					r:Destroy()
					table.remove(tunnel, i)
				end
			end
		end
		-- captions
		local text = ""
		for _, line in LINES do
			if t >= line[1] and t <= line[2] then
				text = line[3]
			end
		end
		if text ~= caption.Text then
			caption.Text = text
			caption.TextTransparency = 1
			tween(caption, 0.4, { TextTransparency = if text == "" then 1 else 0 })
		end
		-- into white, then the title, a letter at a time
		if t >= 47.6 and not flashed then
			flashed = true
			fade.BackgroundColor3 = Color3.new(1, 1, 1)
			fade.BackgroundTransparency = 1
			tween(fade, 0.25, { BackgroundTransparency = 0 })
			task.delay(0.35, function()
				tween(fade, 0.6, { BackgroundColor3 = Color3.fromRGB(4, 6, 14) })
				for i, l in letters do
					task.delay(i * 0.07, function()
						l.Position = UDim2.fromScale((i - 0.5) / #letters, -0.6)
						tween(l, 0.45, { Position = UDim2.fromScale((i - 0.5) / #letters, 0.5), TextTransparency = 0 }, Enum.EasingStyle.Back)
					end)
				end
				task.delay(1.2, function()
					-- a shimmer runs across the title
					for i, l in letters do
						task.delay(i * 0.05, function()
							tween(l, 0.15, { TextColor3 = Color3.new(1, 1, 1) })
							task.delay(0.15, function()
								tween(l, 0.4, { TextColor3 = Color3.fromRGB(160, 210, 255) })
							end)
						end)
					end
					tween(sub, 1, { TextTransparency = 0 })
				end)
			end)
		end
		if t >= LENGTH then
			done = true
		end
	end)
	while not done do
		task.wait()
	end
	conn:Disconnect()
	for _, l in letters do
		tween(l, 0.4, { TextTransparency = 1 })
	end
	tween(sub, 0.4, { TextTransparency = 1 })
	tween(card, 0.2, { Position = UDim2.new(-0.5, 0, 0.5, 0) })
	fade.BackgroundColor3 = Color3.new(0, 0, 0)
	fade.BackgroundTransparency = 0
	task.wait(0.4)
	folder:Destroy()
	bloom:Destroy()
	grade:Destroy()
	for k, v in saved do
		(Lighting :: any)[k] = v
	end
	camera.FieldOfView = 70
	tween(fade, 0.8, { BackgroundTransparency = 1 })
	task.delay(0.9, function()
		gui:Destroy()
	end)
end

OpeningCutscene.Fx = Fx -- (the title screen borrows them)
OpeningCutscene.PARTY = PARTY

return OpeningCutscene
