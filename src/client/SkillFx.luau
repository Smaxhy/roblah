--[[
	SKILL VFX (BitLeveling): one effect per live-city ability (Hunter/Abilities.luau), drawn on
	every client when the server says an ability was used (server/HunterLive: fx "ability", and
	"abilityTick" for constructs and storms).

		SkillFx.init({ root = folder, me = userId, shake = fn(at, amount, radius),
		               sound = fn(id, at, volume, pitch), characterOf = fn(userId) -> Model? })
		SkillFx.play(msg)       -- msg: the server's { ability, element, at, dir, to, targets, ... }
		SkillFx.tick(msg)       -- a construct moving or striking, a storm's bolts
		SkillFx.cast(msg)       -- a cast gathering at the caster's feet (fx "abilityCast")
		SkillFx.has(id)         -- is there an effect for that ability
		SkillFx.SHAPES[shape]   -- the composable shapes every data-only move is drawn with:
		                           projectile, volley, wave, lance, spikes, nova, shockwave, cone,
		                           slash, strike, meteor, pillar, smite, implode, eruption, rain,
		                           field, storm, wall, orbit, chain, dash, leap, blink, dome, ward,
		                           aura, haste, motes, renew, cleanse, taunt, curse, construct
		SkillFx.LANG[element]   -- each element's language: particle texture, solid material,
		                           flourish (embers, mist, arcs, streaks, rocks, droplets, rays,
		                           an inward pull, bubbles, leaves, runes, ripples, sparks)
		SkillFx.palette(el)     -- { core, glow, dark } Color3s for an element
		SkillFx.EFFECTS[id]     -- the effects themselves, (msg, I) -> () (I: what the msg says, worked out)

	Everything is client-side: anchored, non-colliding, never queried or touched, cleaned up
	with Debris, animated with TweenService (and short task loops for things that orbit or walk).
	Particles use Roblox's own textures (sparkles_main, fire_main, smoke_main and friends).
	An effect stays under SkillFx.MAX_PARTS parts; when the folder is already crowded every
	effect draws about half as much. Big ones shake the camera (the caller's shake code).

	Constructs are made of mana (an armoured guardian, a stone colossus, a warden of light, a
	hawk): never a soul, never anything raised from the dead. Hits are bright flashes and
	sparks; nothing here is gore.
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Abilities = require(ReplicatedStorage:WaitForChild("LifeSim"):WaitForChild("Hunter"):WaitForChild("Abilities"))

local SkillFx = {}
SkillFx.MAX_PARTS = 90
SkillFx.made = 0 -- parts made so far (tests read it)

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local FIRE = "rbxasset://textures/particles/fire_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local SPARKS = "rbxasset://textures/particles/fire_sparks_main.dds"
local GLOW = "rbxasset://textures/particles/explosion01_implosion_main.dds"
local SHOCK = "rbxasset://textures/particles/explosion01_shockwave_main.dds"
local SLASH = "rbxasset://sounds/swordslash.wav"
local LUNGE = "rbxasset://sounds/swordlunge.wav"
local PING = "rbxasset://sounds/electronicpingshort.wav"
local THUD = "rbxasset://sounds/collide.wav"

local ctx: any = {
	root = nil,
	me = nil,
	shake = function(_at: Vector3, _amount: number, _radius: number) end,
	sound = function(_id: string, _at: Vector3, _volume: number, _pitch: number?) end,
	characterOf = function(_userId: number): Model?
		return nil
	end,
}

function SkillFx.init(opts: any)
	for k, v in opts or {} do
		ctx[k] = v
	end
end

-- ── colours ──
local palettes: { [string]: any } = {}
local function rgb(t: { number }): Color3
	return Color3.fromRGB(t[1], t[2], t[3])
end
function SkillFx.palette(element: string?): any
	local id = if element and Abilities.ELEMENTS[element] then element else "mana"
	local p = palettes[id]
	if not p then
		local e = Abilities.ELEMENTS[id]
		p = { core = rgb(e.core), glow = rgb(e.glow), dark = rgb(e.dark) }
		palettes[id] = p
	end
	return p
end
local WHITE = Color3.new(1, 1, 1)

-- ── primitives ──
local function root(): Instance
	return ctx.root
end
local function crowded(): boolean
	local r = ctx.root
	return r ~= nil and #r:GetChildren() > 450
end
local function Q(n: number): number
	return if crowded() then math.max(1, math.ceil(n / 2)) else n
end
local function v3(t: any, fallback: Vector3?): Vector3
	if type(t) == "table" and type(t[1]) == "number" then
		return Vector3.new(t[1], t[2] or 0, t[3] or 0)
	end
	return fallback or Vector3.zero
end
local function flat(v: Vector3): Vector3
	local f = Vector3.new(v.X, 0, v.Z)
	return if f.Magnitude > 1e-3 then f.Unit else Vector3.new(0, 0, -1)
end
local function tween(inst: Instance, t: number, goals: any, style: Enum.EasingStyle?, dir: Enum.EasingDirection?, delay: number?)
	TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out, 0, false, delay or 0), goals):Play()
end
local function part(props: any, life: number?): BasePart
	local p = Instance.new("Part")
	if props.Shape then
		p.Shape = props.Shape
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.Neon
	for k, v in props do
		if k ~= "Shape" then
			(p :: any)[k] = v
		end
	end
	p.Parent = root()
	SkillFx.made += 1
	if life then
		Debris:AddItem(p, life)
	end
	return p
end
local function light(p: Instance, color: Color3, range: number, brightness: number, fadeIn: number?): PointLight
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range
	l.Brightness = brightness
	l.Shadows = false
	l.Parent = p
	if fadeIn then
		tween(l, fadeIn, { Brightness = 0 })
	end
	return l
end
local function emitter(parent: Instance, o: any): ParticleEmitter
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = o.tex or SPARKLE
	pe.Color = o.seq or ColorSequence.new(o.color or WHITE)
	pe.LightEmission = o.light or 1
	pe.Size = if type(o.size) == "number" then NumberSequence.new(o.size, 0) else (o.size or NumberSequence.new(1, 0))
	pe.Transparency = o.transp or NumberSequence.new(0.1, 1)
	pe.Lifetime = NumberRange.new((o.life or { 0.4, 0.8 })[1], (o.life or { 0.4, 0.8 })[2])
	pe.Speed = NumberRange.new((o.speed or { 4, 10 })[1], (o.speed or { 4, 10 })[2])
	pe.SpreadAngle = Vector2.new(o.spread or 180, o.spread or 180)
	pe.Rate = o.rate or 0
	pe.Acceleration = o.accel or Vector3.zero
	pe.Drag = o.drag or 0
	pe.Rotation = NumberRange.new(0, 360)
	pe.RotSpeed = NumberRange.new(-120, 120)
	pe.EmissionDirection = o.dirn or Enum.NormalId.Top
	pe.LockedToPart = o.locked == true
	pe.Parent = parent
	return pe
end
local function emit(pe: ParticleEmitter, n: number)
	pe:Emit(Q(n))
end
-- a one-off burst of particles at a point
local function burst(at: Vector3, o: any, n: number)
	local holder = part({ Size = Vector3.one * (o.box or 1), CFrame = CFrame.new(at), Transparency = 1 }, ((o.life or { 0.4, 0.8 })[2]) + 0.4)
	emit(emitter(holder, o), n)
end
-- a ball of light that swells and fades
local function flash(at: Vector3, color: Color3, size: number, life: number, withLight: boolean?)
	local p = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * size * 0.3, CFrame = CFrame.new(at), Color = color, Transparency = 0.1 }, life + 0.1)
	if withLight ~= false then
		light(p, color, size * 3, 4, life)
	end
	tween(p, life, { Size = Vector3.one * size, Transparency = 1 })
end
-- a flat disc of light along the ground that grows and fades (a shockwave)
local function disc(at: Vector3, radius: number, color: Color3, life: number, thick: number?, material: Enum.Material?)
	local p = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(thick or 0.3, 2, 2), CFrame = CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90)), Color = color, Transparency = 0.2, Material = material or Enum.Material.Neon }, life + 0.1)
	tween(p, life, { Size = Vector3.new(thick or 0.3, radius * 2, radius * 2), Transparency = 1 })
end
-- a ring of segments that flies outward along the ground
local function ring(at: Vector3, r0: number, r1: number, color: Color3, life: number, n: number?, height: number?)
	n = Q(n or 14)
	local seg = (2 * math.pi * r1) / (n :: number) * 0.9
	for k = 0, (n :: number) - 1 do
		local a = k / (n :: number) * math.pi * 2
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		local p = part({ Size = Vector3.new(seg * r0 / r1 + 0.2, height or 0.5, 0.35), CFrame = CFrame.lookAt(at + dir * r0, at + dir * (r0 + 1)) * CFrame.Angles(0, math.rad(90), 0), Color = color, Transparency = 0.05 }, life + 0.1)
		tween(p, life, { CFrame = CFrame.lookAt(at + dir * r1, at + dir * (r1 + 1)) * CFrame.Angles(0, math.rad(90), 0), Size = Vector3.new(seg, (height or 0.5) * 0.4, 0.2), Transparency = 1 })
	end
end
-- a thin neon slash from a to b, tilted, that flares and fades
local function slash(a: Vector3, b: Vector3, color: Color3, width: number, life: number?, tilt: number?)
	local len = (b - a).Magnitude
	if len < 0.1 then
		return
	end
	local p = part({ Size = Vector3.new(width, 0.15, len), CFrame = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, 0, math.rad(tilt or math.random(-50, 50))), Color = color, Transparency = 0.05 }, (life or 0.3) + 0.05)
	tween(p, life or 0.3, { Transparency = 1, Size = Vector3.new(width * 2.4, 0.04, len * 1.1) })
end
-- a crescent of light (a blade's swing) centred at cf, facing its look
local function crescent(cf: CFrame, radius: number, color: Color3, life: number, pieces: number?, width: number?)
	pieces = pieces or 7
	for k = 0, (pieces :: number) - 1 do
		local a = math.rad(-70 + 140 * k / ((pieces :: number) - 1))
		local p0 = (cf * CFrame.new(math.sin(a) * radius, 0, -math.cos(a) * radius)).Position
		local a2 = math.rad(-70 + 140 * (k + 1) / ((pieces :: number) - 1))
		local p1 = (cf * CFrame.new(math.sin(a2) * radius, 0, -math.cos(a2) * radius)).Position
		local thin = 1 - math.abs(k - ((pieces :: number) - 1) / 2) / (pieces :: number)
		local p = part({ Size = Vector3.new((width or 0.9) * thin, 0.12, (p1 - p0).Magnitude + 0.3), CFrame = CFrame.lookAt(p0, p1) * CFrame.new(0, 0, -(p1 - p0).Magnitude / 2), Color = color, Transparency = 0.05 }, life + 0.1)
		tween(p, life, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0.02 * k)
	end
end
-- a projectile: a glowing ball (or a shaped part) with a trail, flying a to b, then onLand
local function projectile(a: Vector3, b: Vector3, color: Color3, glow: Color3, size: number, speed: number, onLand: (() -> ())?, o: any?)
	o = o or {}
	local t = math.clamp((b - a).Magnitude / speed, 0.06, 1.6)
	local shape = (o :: any).shape
	local p = part({
		Shape = if shape then Enum.PartType.Block else Enum.PartType.Ball,
		Size = if shape then shape else Vector3.one * size,
		CFrame = CFrame.lookAt(a, b),
		Color = color,
		Material = (o :: any).material or Enum.Material.Neon,
		Transparency = (o :: any).transparency or 0,
	}, t + 0.6)
	light(p, glow, size * 6 + 4, 3)
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, size * 0.4, 0)
	a0.Parent = p
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -size * 0.4, 0)
	a1.Parent = p
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = ColorSequence.new(glow, color)
	trail.Transparency = NumberSequence.new(0.1, 1)
	trail.Lifetime = (o :: any).trail or 0.25
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Parent = p
	emitter(p, { tex = (o :: any).tex or SPARKLE, color = glow, rate = (o :: any).rate or 50, size = size * 0.7, life = { 0.2, 0.45 }, speed = { 0, 2 }, locked = false })
	tween(p, t, { CFrame = CFrame.lookAt(b, b + (b - a).Unit) * ((o :: any).spin or CFrame.identity) }, Enum.EasingStyle.Linear)
	task.delay(t, function()
		p.Transparency = 1
		for _, c in p:GetChildren() do
			if c:IsA("ParticleEmitter") then
				c.Enabled = false
			elseif c:IsA("PointLight") then
				c.Enabled = false
			end
		end
		if onLand then
			onLand()
		end
	end)
	return t
end
-- lightning: zig-zag neon segments from a to b
local function zigzag(a: Vector3, b: Vector3, color: Color3, width: number, life: number, segs: number?, jitter: number?)
	segs = segs or math.clamp(math.floor((b - a).Magnitude / 4), 3, 9)
	local dir = b - a
	local side = if math.abs(dir.Unit.Y) > 0.9 then Vector3.xAxis else dir.Unit:Cross(Vector3.yAxis).Unit
	local up = side:Cross(dir.Unit)
	local prev = a
	for k = 1, segs :: number do
		local t = k / (segs :: number)
		local pnt = a + dir * t
		if k < (segs :: number) then
			local j = (jitter or 1.6)
			pnt += side * (math.random() - 0.5) * 2 * j + up * (math.random() - 0.5) * 2 * j
		end
		local len = (pnt - prev).Magnitude
		local p = part({ Size = Vector3.new(width, width, len + width), CFrame = CFrame.lookAt((prev + pnt) / 2, pnt), Color = color, Transparency = 0 }, life + 0.05)
		tween(p, life, { Transparency = 1, Size = Vector3.new(width * 0.3, width * 0.3, len) })
		prev = pnt
	end
end
-- a spike that erupts from the ground and sinks again
local function spike(base: Vector3, height: number, width: number, color: Color3, material: Enum.Material, hold: number, tilt: Vector3?, delay: number?)
	local dir = (tilt or Vector3.zero) + Vector3.yAxis
	local up = dir.Unit
	local cfDown = CFrame.lookAt(base - up * height * 0.5, base - up * height * 0.5 + up) * CFrame.Angles(math.rad(-90), 0, 0)
	local cfUp = CFrame.lookAt(base + up * height * 0.45, base + up * height * 0.45 + up) * CFrame.Angles(math.rad(-90), 0, 0)
	local p = part({ Size = Vector3.new(width, height, width), CFrame = cfDown, Color = color, Material = material, Transparency = 0.05 }, (delay or 0) + hold + 0.9)
	tween(p, 0.12, { CFrame = cfUp }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, delay)
	tween(p, 0.5, { CFrame = cfDown, Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, (delay or 0) + hold)
end
-- a vertical column of light (cylinder) that rises and widens
local function pillar(at: Vector3, radius: number, height: number, color: Color3, life: number, delay: number?)
	local p = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(height, radius * 0.3, radius * 0.3), CFrame = CFrame.new(at + Vector3.new(0, height / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = color, Transparency = 0.15 }, (delay or 0) + life + 0.1)
	tween(p, life * 0.3, { Size = Vector3.new(height, radius * 2, radius * 2) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, delay)
	tween(p, life * 0.7, { Transparency = 1, Size = Vector3.new(height, radius * 0.2, radius * 0.2) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, (delay or 0) + life * 0.3)
	return p
end
-- a see-through copy of an R6 body (an afterimage), at a root CFrame
local GHOST = {
	{ Vector3.new(2, 2, 1), CFrame.new(0, 0, 0) },
	{ Vector3.new(1.2, 1.1, 1.1), CFrame.new(0, 1.55, 0) },
	{ Vector3.new(1, 2, 1), CFrame.new(-1.5, 0, 0) },
	{ Vector3.new(1, 2, 1), CFrame.new(1.5, 0, 0) },
	{ Vector3.new(1, 2, 1), CFrame.new(-0.5, -2, 0) },
	{ Vector3.new(1, 2, 1), CFrame.new(0.5, -2, 0) },
}
local function ghost(cf: CFrame, color: Color3, life: number, transparency: number?, material: Enum.Material?)
	for _, g in GHOST do
		local p = part({ Size = g[1], CFrame = cf * g[2], Color = color, Material = material or Enum.Material.ForceField, Transparency = transparency or 0.25 }, life + 0.1)
		tween(p, life, { Transparency = 1 })
	end
end
-- a bubble (shield, dome) that swells to a size, stays, then fades
local function bubble(at: Vector3, size: number, color: Color3, stay: number, material: Enum.Material?)
	local p = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 1, CFrame = CFrame.new(at), Color = color, Material = material or Enum.Material.ForceField, Transparency = 0.15 }, stay + 1.2)
	tween(p, 0.35, { Size = Vector3.one * size }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tween(p, 0.8, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, stay)
	return p
end
-- chunks of rock (or ice) thrown out from a point
local function chunks(at: Vector3, n: number, color: Color3, material: Enum.Material, spread: number, size: number?)
	n = Q(n)
	for _ = 1, n do
		local a = math.random() * math.pi * 2
		local d = spread * (0.4 + math.random() * 0.6)
		local s = (size or 1) * (0.5 + math.random() * 0.7)
		local p = part({ Size = Vector3.one * s, CFrame = CFrame.new(at) * CFrame.Angles(math.random() * 6, math.random() * 6, 0), Color = color, Material = material, Transparency = 0 }, 1.3)
		local mid = at + Vector3.new(math.cos(a) * d * 0.5, 3 + math.random() * 4, math.sin(a) * d * 0.5)
		local land = at + Vector3.new(math.cos(a) * d, -0.2, math.sin(a) * d)
		tween(p, 0.3, { CFrame = CFrame.new(mid) * CFrame.Angles(math.random() * 6, math.random() * 6, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tween(p, 0.4, { CFrame = CFrame.new(land), Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0.3)
	end
end
-- a glyph on the ground: a ring of runes and an inner disc that stays for a while
local function rune(at: Vector3, radius: number, color: Color3, stay: number, n: number?)
	n = Q(n or 12)
	local spin = math.random() * math.pi
	for k = 0, (n :: number) - 1 do
		local a = spin + k / (n :: number) * math.pi * 2
		local p = part({ Size = Vector3.new(radius * 0.42, 0.12, 0.4), CFrame = CFrame.new(at + Vector3.new(math.cos(a) * radius, 0.08, math.sin(a) * radius)) * CFrame.Angles(0, -a + math.pi / 2, 0), Color = color, Transparency = 1 }, stay + 0.8)
		tween(p, 0.25, { Transparency = 0.1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.02 * k)
		tween(p, 0.5, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, stay)
	end
	local inner = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.1, radius * 1.6, radius * 1.6), CFrame = CFrame.new(at + Vector3.new(0, 0.05, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = color, Transparency = 1 }, stay + 0.8)
	tween(inner, 0.3, { Transparency = 0.7 })
	tween(inner, 0.5, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, stay)
	return inner
end
-- parts that orbit a (possibly moving) centre for a while: swirls, cyclones, wells
local function orbit(centerOf: () -> Vector3, n: number, radius: number, height: number, color: Color3, seconds: number, o: any?)
	o = o or {}
	n = Q(n)
	local parts = {}
	for k = 1, n do
		parts[k] = part({ Size = (o :: any).size or Vector3.new(0.4, 0.4, 2.2), CFrame = CFrame.new(centerOf()), Color = color, Material = (o :: any).material or Enum.Material.Neon, Transparency = (o :: any).transparency or 0.15 }, seconds + 0.6)
	end
	local steps = math.max(1, math.floor(seconds * 20))
	task.spawn(function()
		for s = 1, steps do
			local c = centerOf()
			local t = s / 20
			for k, p in parts do
				local a = t * ((o :: any).speed or 6) + k / n * math.pi * 2
				local rr = radius * (if (o :: any).inward then (1 - s / steps * 0.85) else 1) * (0.75 + 0.25 * math.sin(k * 1.7))
				local y = ((k % 4) / 4) * height + ((o :: any).rise or 0) * (s / steps)
				local pos = c + Vector3.new(math.cos(a) * rr, y, math.sin(a) * rr)
				p.CFrame = CFrame.lookAt(pos, pos + Vector3.new(-math.sin(a), 0, math.cos(a)))
			end
			task.wait(0.05)
		end
		for _, p in parts do
			tween(p, 0.4, { Transparency = 1 })
		end
	end)
end
-- an emitter left running over an area for a while (snow, smoke, mist, embers)
local function areaEmitter(at: Vector3, size: Vector3, o: any, seconds: number)
	local holder = part({ Size = size, CFrame = CFrame.new(at), Transparency = 1 }, seconds + ((o.life or { 1, 2 })[2]) + 0.5)
	local pe = emitter(holder, o)
	pe.Rate = if crowded() then (o.rate or 20) * 0.5 else (o.rate or 20)
	task.delay(seconds, function()
		pe.Enabled = false
	end)
	return holder
end
-- a long bright line (beams, lances)
local function lance(a: Vector3, b: Vector3, color: Color3, glow: Color3, width: number, life: number)
	local len = (b - a).Magnitude
	if len < 0.5 then
		return
	end
	local cf = CFrame.lookAt((a + b) / 2, b)
	local core = part({ Size = Vector3.new(width * 0.35, width * 0.35, len), CFrame = cf, Color = glow, Transparency = 0 }, life + 0.1)
	local outer = part({ Size = Vector3.new(width, width, len), CFrame = cf, Color = color, Transparency = 0.45 }, life + 0.1)
	tween(core, life, { Transparency = 1, Size = Vector3.new(0.05, 0.05, len) })
	tween(outer, life * 0.8, { Transparency = 1, Size = Vector3.new(width * 1.8, width * 1.8, len) })
	local holder = part({ Size = Vector3.new(width, width, len), CFrame = cf, Transparency = 1 }, life + 0.9)
	emit(emitter(holder, { color = glow, size = width * 0.5, life = { 0.3, 0.7 }, speed = { 1, 4 } }), math.clamp(math.floor(len / 2), 8, 40))
	light(core, color, math.min(60, width * 8), 3, life)
end

-- what a message says, worked out: positions, the ground, the colours
local function info(d: any): any
	local at = v3(d.at)
	local dir = flat(v3(d.dir, Vector3.new(0, 0, -1)))
	local floor = if type(d.floor) == "number" then d.floor else at.Y - 3
	local I: any = {
		at = at,
		dir = dir,
		right = dir:Cross(Vector3.yAxis),
		floor = floor,
		pal = SkillFx.palette(d.element or (Abilities.byId[d.ability] and Abilities.byId[d.ability].element)),
		def = Abilities.byId[d.ability] or {},
		radius = d.radius or 12,
		range = d.range or 30,
		duration = d.duration or 3,
		me = d.player ~= nil and d.player == ctx.me,
		tier = math.clamp(tonumber(d.tier) or (Abilities.byId[d.ability] and Abilities.byId[d.ability].tier) or 1, 1, 6),
	}
	I.to = v3(d.to, at + dir * math.min(I.range, 30))
	I.targets = {}
	for _, t in d.targets or {} do
		table.insert(I.targets, v3(t))
	end
	I.ground = function(p: Vector3): Vector3
		return Vector3.new(p.X, floor + 0.1, p.Z)
	end
	-- where the caster is now (zones that follow them)
	I.caster = function(): Vector3
		local ch = d.player and ctx.characterOf(d.player)
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		return if hrp and hrp:IsA("BasePart") then hrp.Position else at
	end
	return I
end
local function sound(id: string, at: Vector3, volume: number, pitch: number?)
	ctx.sound(id, at, volume, pitch)
end
local function shake(at: Vector3, amount: number, radius: number)
	ctx.shake(at, amount, radius)
end
-- the points to hit: the server's targets, or a scatter inside the area
local function spots(I: any, center: Vector3, radius: number, n: number): { Vector3 }
	local out = {}
	for _, t in I.targets do
		table.insert(out, I.ground(t))
	end
	while #out < n do
		local a, r = math.random() * math.pi * 2, math.sqrt(math.random()) * radius
		table.insert(out, I.ground(center + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)))
	end
	return out
end

-- ── constructs (mana, never souls) ──
local constructs: { [string]: any } = {}
local STYLES = {
	-- the guardian of mana: armoured legs, a breastplate, a helm with a glowing visor, a shield and a sword of light
	knight = {
		scale = 1.25,
		parts = {
			{ "legL", Vector3.new(1, 2.2, 1), CFrame.new(-0.6, -2.1, 0), "glass" },
			{ "legR", Vector3.new(1, 2.2, 1), CFrame.new(0.6, -2.1, 0), "glass" },
			{ "body", Vector3.new(2.4, 2.4, 1.3), CFrame.new(0, 0.2, 0), "glass" },
			{ "plate", Vector3.new(2.6, 1.2, 1.5), CFrame.new(0, 0.9, 0), "core" },
			{ "head", Vector3.new(1.3, 1.3, 1.3), CFrame.new(0, 2.1, 0), "glass" },
			{ "visor", Vector3.new(1, 0.25, 0.2), CFrame.new(0, 2.15, -0.68), "glow" },
			{ "crest", Vector3.new(0.25, 0.9, 1.4), CFrame.new(0, 2.9, 0), "core" },
			{ "armL", Vector3.new(0.9, 2.2, 0.9), CFrame.new(-1.75, 0, 0), "glass" },
			{ "armR", Vector3.new(0.9, 2.2, 0.9), CFrame.new(1.75, 0, 0), "glass" },
			{ "shield", Vector3.new(0.3, 2.6, 1.8), CFrame.new(-2.3, 0, -0.4), "core" },
			{ "sword", Vector3.new(0.3, 0.3, 4.2), CFrame.new(1.8, -0.4, -2.3), "glow", "armR" },
		},
	},
	-- a colossus of stone with glowing seams
	golem = {
		scale = 1.7,
		parts = {
			{ "legL", Vector3.new(1.4, 2.2, 1.4), CFrame.new(-0.9, -2.1, 0), "stone" },
			{ "legR", Vector3.new(1.4, 2.2, 1.4), CFrame.new(0.9, -2.1, 0), "stone" },
			{ "body", Vector3.new(3.2, 2.8, 2), CFrame.new(0, 0.4, 0), "stone" },
			{ "seam", Vector3.new(3.3, 0.25, 2.1), CFrame.new(0, 0.6, 0), "glow" },
			{ "head", Vector3.new(1.5, 1.2, 1.4), CFrame.new(0, 2.4, -0.2), "stone" },
			{ "eyes", Vector3.new(1, 0.22, 0.2), CFrame.new(0, 2.45, -0.95), "glow" },
			{ "armL", Vector3.new(1.3, 2.8, 1.3), CFrame.new(-2.3, 0, 0), "stone" },
			{ "armR", Vector3.new(1.3, 2.8, 1.3), CFrame.new(2.3, 0, 0), "stone" },
			{ "fistL", Vector3.new(1.6, 1.4, 1.6), CFrame.new(-2.3, -1.8, 0), "stone" },
			{ "fistR", Vector3.new(1.6, 1.4, 1.6), CFrame.new(2.3, -1.8, 0), "stone", "armR" },
		},
	},
	-- a warden of light holding a lantern
	warden = {
		scale = 1.2,
		parts = {
			{ "robe", Vector3.new(2.2, 3.2, 1.6), CFrame.new(0, -1.2, 0), "glass" },
			{ "body", Vector3.new(2, 1.8, 1.1), CFrame.new(0, 0.9, 0), "glass" },
			{ "head", Vector3.new(1.2, 1.2, 1.2), CFrame.new(0, 2.3, 0), "glass" },
			{ "halo", Vector3.new(1.8, 0.15, 1.8), CFrame.new(0, 3.2, 0), "glow" },
			{ "armL", Vector3.new(0.8, 2, 0.8), CFrame.new(-1.45, 0.5, 0), "glass" },
			{ "armR", Vector3.new(0.8, 2, 0.8), CFrame.new(1.45, 0.5, -0.3), "glass" },
			{ "staff", Vector3.new(0.25, 5, 0.25), CFrame.new(1.6, 0.6, -0.6), "core", "armR" },
			{ "lantern", Vector3.new(0.8, 0.9, 0.8), CFrame.new(1.6, 3.3, -0.6), "glow", "armR" },
		},
	},
	-- a hawk of mana: a body, two wings, a tail
	hawk = {
		scale = 1,
		fly = 9,
		parts = {
			{ "body", Vector3.new(0.9, 0.8, 2.2), CFrame.new(0, 0, 0), "core" },
			{ "head", Vector3.new(0.7, 0.7, 0.7), CFrame.new(0, 0.25, -1.3), "glow" },
			{ "wingL", Vector3.new(3.2, 0.15, 1.3), CFrame.new(-1.9, 0.1, 0.1), "glass", "wingL" },
			{ "wingR", Vector3.new(3.2, 0.15, 1.3), CFrame.new(1.9, 0.1, 0.1), "glass", "wingR" },
			{ "tail", Vector3.new(0.9, 0.12, 1.2), CFrame.new(0, 0, 1.6), "glass" },
		},
	},
}
local function buildConstruct(key: string, style: string, at: Vector3, I: any, seconds: number): any
	local def = STYLES[style] or STYLES.knight
	local pal = I.pal
	local h: any = { parts = {}, style = style, def = def, pos = at, yaw = math.atan2(-I.dir.X, -I.dir.Z), move = 0, swing = 0, alive = true }
	local s = def.scale
	for _, spec in def.parts do
		local look = spec[4]
		local props: any = { Size = spec[2] * s, Color = pal.core, Transparency = 0.2, Material = Enum.Material.Neon }
		if look == "glass" then
			props.Color = pal.core
			props.Material = Enum.Material.ForceField
			props.Transparency = 0.05
		elseif look == "glow" then
			props.Color = pal.glow
		elseif look == "stone" then
			props.Color = pal.dark
			props.Material = Enum.Material.Slate
			props.Transparency = 0
		end
		local p = part(props, seconds + 4)
		table.insert(h.parts, { p = p, off = CFrame.new(spec[3].Position * s) * spec[3].Rotation, role = spec[5] })
	end
	local core = h.parts[3] and h.parts[3].p or h.parts[1].p
	light(core, pal.glow, 16, 2.5)
	emitter(core, { color = pal.glow, rate = 14, size = 0.6, life = { 0.5, 1 }, speed = { 0.5, 2 }, locked = false })
	h.root = function(): CFrame
		return CFrame.new(h.pos + Vector3.new(0, (def.fly or 0) + 3 * s, 0)) * CFrame.Angles(0, h.yaw, 0)
	end
	h.place = function(bob: number)
		local base = h.root() * CFrame.new(0, bob, 0)
		for _, e in h.parts do
			local off = e.off
			if e.role == "armR" and h.swing > 0 then
				off = CFrame.new(0, 0.6 * s, 0) * CFrame.Angles(-h.swing * 1.6, 0, 0) * CFrame.new(0, -0.6 * s, 0) * off
			elseif e.role == "wingL" then
				off = CFrame.Angles(0, 0, math.sin(bob * 6) * 0.6) * off
			elseif e.role == "wingR" then
				off = CFrame.Angles(0, 0, -math.sin(bob * 6) * 0.6) * off
			end
			e.p.CFrame = base * off
		end
	end
	h.place(0)
	-- it rises out of a rune
	rune(I.ground(at), 5 * s, pal.glow, 1.2, 10)
	flash(at + Vector3.new(0, 3, 0), pal.glow, 9 * s, 0.6)
	burst(at + Vector3.new(0, 2, 0), { color = pal.glow, size = 1, life = { 0.5, 1 }, speed = { 6, 14 } }, 30)
	constructs[key] = h
	task.delay(seconds + 2.5, function()
		if constructs[key] == h then
			constructs[key] = nil
		end
	end)
	return h
end
local function moveConstruct(h: any, to: Vector3)
	h.move += 1
	local id = h.move
	local from = h.pos
	local d = to - from
	if Vector3.new(d.X, 0, d.Z).Magnitude > 0.3 then
		h.yaw = math.atan2(-d.X, -d.Z)
	end
	task.spawn(function()
		for k = 1, 9 do
			if h.move ~= id or not h.alive then
				return
			end
			h.pos = from:Lerp(to, k / 9)
			h.place(math.sin(k / 9 * math.pi) * 0.35)
			task.wait(0.05)
		end
	end)
end
local function dissolve(h: any, I: any)
	h.alive = false
	for _, e in h.parts do
		tween(e.p, 0.6, { Transparency = 1, Size = e.p.Size * 0.6 })
	end
	local at = h.root().Position
	burst(at, { color = I.pal.glow, size = 1.2, life = { 0.6, 1.2 }, speed = { 3, 9 }, accel = Vector3.new(0, 6, 0) }, 40)
	flash(at, I.pal.glow, 10, 0.5)
end

-- ── the effects, one per ability ──
local E: { [string]: (any, any) -> () } = {}
SkillFx.EFFECTS = E

local STONE = Enum.Material.Slate
local ICE = Enum.Material.Ice

-- FIGHTER
E.cleave = function(_d, I)
	local cf = CFrame.lookAt(I.at, I.at + I.dir) * CFrame.new(0, 0.2, -1.5)
	crescent(cf * CFrame.Angles(0, 0, math.rad(-18)), 8, I.pal.glow, 0.28, 8, 1.1)
	crescent(cf * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, math.rad(12)), 6.5, I.pal.core, 0.22, 6, 0.6)
	burst(I.at + I.dir * 6, { tex = SPARKS, color = I.pal.glow, size = 0.5, life = { 0.2, 0.5 }, speed = { 10, 20 }, spread = 60 }, 18)
	sound(SLASH, I.at, 0.7, 0.8)
end
E.rising_cut = function(_d, I)
	local cf = CFrame.lookAt(I.at, I.at + I.dir) * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, math.rad(90))
	crescent(cf * CFrame.Angles(math.rad(-20), 0, 0), 6, I.pal.glow, 0.35, 8, 1)
	for k = 0, 2 do
		slash(I.ground(I.at + I.dir * (3 + k * 3)), I.at + I.dir * (4 + k * 3) + Vector3.new(0, 7, 0), I.pal.core, 0.6, 0.35, 0)
	end
	chunks(I.ground(I.at + I.dir * 5), 6, Color3.fromRGB(110, 100, 90), STONE, 6, 0.8)
	burst(I.ground(I.at + I.dir * 5), { tex = SMOKE, color = Color3.fromRGB(170, 160, 150), light = 0, size = NumberSequence.new(2, 5), life = { 0.5, 0.9 }, speed = { 4, 8 }, transp = NumberSequence.new(0.4, 1) }, 10)
	sound(SLASH, I.at, 0.7, 1.1)
end
local function dashTrail(I: any, from: Vector3, to: Vector3, color: Color3, n: number)
	local look = flat(to - from)
	for k = 1, n do
		local p = from:Lerp(to, k / (n + 1))
		ghost(CFrame.lookAt(p, p + look), color, 0.35 + k * 0.08)
	end
	for k = -1, 1 do
		local o = look:Cross(Vector3.yAxis) * k * 1.4 + Vector3.new(0, k * 0.6, 0)
		slash(from + o, to + o, color, 0.25, 0.35, 0)
	end
end
E.shoulder_charge = function(d, I)
	local from = v3(d.from, I.at)
	dashTrail(I, from, I.to, I.pal.glow, 3)
	burst(I.ground(from), { tex = SMOKE, color = Color3.fromRGB(180, 170, 160), light = 0, size = NumberSequence.new(2, 6), life = { 0.5, 1 }, speed = { 5, 10 }, transp = NumberSequence.new(0.4, 1) }, 14)
	disc(I.ground(I.to), 8, I.pal.glow, 0.35)
	for _, t in I.targets do
		flash(t, I.pal.glow, 5, 0.3, false)
	end
	shake(I.to, 0.8, 50)
	sound(THUD, I.to, 0.8, 0.8)
end
E.leap_strike = function(d, I)
	local from = v3(d.from, I.at)
	-- the arc through the air
	for k = 1, 6 do
		local t = k / 7
		local p = from:Lerp(I.to, t) + Vector3.new(0, math.sin(t * math.pi) * 12, 0)
		ghost(CFrame.lookAt(p, p + I.dir), I.pal.glow, 0.25 + k * 0.05, 0.5)
	end
	task.delay(0.15, function()
		local g = I.ground(I.to)
		disc(g, (I.radius or 11) + 2, I.pal.core, 0.5, 0.5)
		ring(g, 1, I.radius or 11, I.pal.glow, 0.45, 12)
		chunks(g, 10, I.pal.dark, STONE, 10, 1.1)
		for k = 0, 5 do
			local a = k / 6 * math.pi * 2
			spike(g + Vector3.new(math.cos(a) * 3, 0, math.sin(a) * 3), 3.5, 1.1, I.pal.dark, STONE, 0.5, Vector3.new(math.cos(a), 0, math.sin(a)) * 0.6, 0.02 * k)
		end
		flash(g + Vector3.new(0, 1, 0), I.pal.glow, 10, 0.35)
		shake(g, 1.6, 70)
		sound(THUD, g, 1, 0.6)
	end)
end
E.slam = function(_d, I)
	local g = I.ground(I.at)
	disc(g, 18, I.pal.core, 0.6, 0.8)
	ring(g, 2, 17, I.pal.glow, 0.5, 16, 0.8)
	chunks(g, 12, I.pal.dark, STONE, 14, 1.2)
	for k = 0, 9 do
		local a = k / 10 * math.pi * 2
		spike(g + Vector3.new(math.cos(a) * 7, 0, math.sin(a) * 7), 3, 1.2, I.pal.dark, STONE, 0.4, Vector3.new(math.cos(a), 0, math.sin(a)) * 0.5, 0.03 * k)
	end
	burst(g, { tex = SMOKE, color = Color3.fromRGB(170, 160, 150), light = 0, size = NumberSequence.new(3, 7), life = { 0.6, 1.2 }, speed = { 8, 16 }, spread = 80, transp = NumberSequence.new(0.4, 1) }, 18)
	flash(g + Vector3.new(0, 1, 0), I.pal.glow, 10, 0.4)
	shake(I.at, 1.6, 80)
	sound(THUD, I.at, 1, 0.5)
end
local function spinZone(I: any, n: number, radius: number, colorA: Color3, colorB: Color3)
	orbit(I.caster, n, radius, 3, colorA, I.duration, { size = Vector3.new(0.25, 0.2, radius * 0.55), speed = 11 })
	orbit(I.caster, math.max(2, math.floor(n / 2)), radius * 0.6, 2, colorB, I.duration, { size = Vector3.new(0.2, 0.15, radius * 0.4), speed = -14 })
	local steps = math.floor(I.duration / 0.5)
	for k = 0, steps - 1 do
		task.delay(k * 0.5, function()
			local c = I.caster()
			disc(I.ground(c), radius, colorB, 0.4, 0.2)
			burst(c, { tex = SPARKS, color = colorA, size = 0.4, life = { 0.2, 0.4 }, speed = { 12, 22 }, spread = 20, dirn = Enum.NormalId.Front }, 8)
			sound(SLASH, c, 0.35, 1 + k * 0.05)
		end)
	end
end
E.whirlwind = function(_d, I)
	spinZone(I, 6, 9, I.pal.glow, I.pal.core)
end
E.iron_resolve = function(_d, I)
	bubble(I.at, 8, I.pal.glow, I.duration * 0.8, Enum.Material.ForceField)
	ghost(CFrame.lookAt(I.at, I.at + I.dir), Color3.fromRGB(200, 205, 215), 0.8, 0.3, Enum.Material.Metal)
	burst(I.at, { tex = SPARKS, color = I.pal.glow, size = 0.5, life = { 0.3, 0.6 }, speed = { 6, 12 } }, 20)
	ring(I.ground(I.at), 1, 7, I.pal.glow, 0.4, 10)
	sound(THUD, I.at, 0.6, 1.2)
end
local function aura(at: Vector3, color: Color3, seconds: number, n: number)
	local holder = part({ Size = Vector3.new(2, 4, 2), CFrame = CFrame.new(at), Transparency = 1 }, seconds + 1.5)
	local pe = emitter(holder, { tex = FIRE, color = color, size = NumberSequence.new(1.2, 0), life = { 0.4, 0.8 }, speed = { 2, 5 }, rate = n, spread = 15, accel = Vector3.new(0, 4, 0) })
	task.delay(seconds, function()
		pe.Enabled = false
	end)
end
E.war_cry = function(d, I)
	local mouth = I.at + Vector3.new(0, 1.5, 0)
	for k = 0, 2 do
		task.delay(k * 0.12, function()
			ring(mouth, 1, 10 + k * 8, I.pal.glow, 0.5, 12, 0.4)
		end)
	end
	disc(I.ground(I.at), I.radius, Color3.fromRGB(255, 120, 60), 0.6)
	for i, a in d.allies or {} do
		if i <= 6 then
			aura(v3(a), Color3.fromRGB(255, 140, 60), math.min(I.duration, 4), 14)
		end
	end
	shake(I.at, 0.8, 40)
	sound(PING, I.at, 0.8, 0.4)
end
E.earthsplitter = function(_d, I)
	local from = I.ground(I.at + I.dir * 3)
	local len = (I.to - I.at).Magnitude
	local n = Q(12)
	for k = 0, n - 1 do
		local p = from + I.dir * (len * k / n) + I.right * (math.random() - 0.5) * 2
		spike(p, 4 + math.random() * 3, 1.6 + math.random(), I.pal.dark, STONE, 0.7, I.right * (math.random() - 0.5) * 0.8, k * 0.035)
		if k % 3 == 0 then
			task.delay(k * 0.035, function()
				burst(p, { tex = SMOKE, color = Color3.fromRGB(160, 140, 120), light = 0, size = NumberSequence.new(2, 5), life = { 0.5, 1 }, speed = { 4, 8 }, transp = NumberSequence.new(0.4, 1) }, 6)
			end)
		end
	end
	local crack = part({ Size = Vector3.new(0.8, 0.1, len), CFrame = CFrame.lookAt(from + I.dir * len / 2, from + I.dir * len), Color = I.pal.glow, Transparency = 0.1 }, 1.6)
	tween(crack, 1.4, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	shake(I.at, 2.2, 90)
	sound(THUD, I.at, 1, 0.45)
end
E.bladestorm = function(_d, I)
	spinZone(I, 10, 13, I.pal.glow, Color3.fromRGB(255, 240, 220))
	local holder = areaEmitter(I.at, Vector3.new(4, 4, 4), { tex = SPARKS, color = I.pal.glow, size = 0.5, life = { 0.3, 0.6 }, speed = { 14, 26 }, rate = 40 }, I.duration)
	task.spawn(function()
		for _ = 1, math.floor(I.duration * 10) do
			holder.CFrame = CFrame.new(I.caster())
			task.wait(0.1)
		end
	end)
	shake(I.at, 1.2, 50)
end

-- MAGE
E.mana_bolt = function(_d, I)
	projectile(I.at + Vector3.new(0, 1.5, 0), I.to + Vector3.new(0, 0.5, 0), I.pal.core, I.pal.glow, 1.2, 140, function()
		flash(I.to, I.pal.glow, 7, 0.35)
		burst(I.to, { color = I.pal.glow, size = 0.7, life = { 0.3, 0.6 }, speed = { 6, 14 } }, 18)
	end)
	sound(PING, I.at, 0.5, 1.4)
end
E.flame_lance = function(_d, I)
	local a = I.at + Vector3.new(0, 1.5, 0) + I.dir * 2
	lance(a, I.to + Vector3.new(0, 1.5, 0), I.pal.core, I.pal.glow, 2.2, 0.5)
	local holder = part({ Size = Vector3.new(1.5, 1.5, (I.to - a).Magnitude), CFrame = CFrame.lookAt((a + I.to) / 2, I.to), Transparency = 1 }, 1.4)
	emit(emitter(holder, { tex = FIRE, color = I.pal.core, size = NumberSequence.new(1.6, 0), life = { 0.4, 0.8 }, speed = { 1, 3 }, accel = Vector3.new(0, 5, 0) }), 40)
	for _, t in I.targets do
		flash(t, I.pal.glow, 6, 0.4, false)
	end
	sound(LUNGE, I.at, 0.6, 0.7)
end
local function blinkFx(I: any, from: Vector3, to: Vector3, color: Color3, glow: Color3)
	ghost(CFrame.lookAt(from, from + I.dir), color, 0.5, 0.2)
	flash(from, glow, 6, 0.3, false)
	flash(to, glow, 7, 0.35)
	for _, p in { from, to } do
		local slit = part({ Size = Vector3.new(0.3, 7, 0.3), CFrame = CFrame.new(p), Color = glow, Transparency = 0 }, 0.45)
		tween(slit, 0.35, { Size = Vector3.new(0.05, 10, 0.05), Transparency = 1 })
		burst(p, { color = glow, size = 0.6, life = { 0.3, 0.6 }, speed = { 4, 10 } }, 16)
	end
	slash(from, to, glow, 0.15, 0.25, 0)
	sound(PING, to, 0.5, 1.8)
end
E.arcane_step = function(d, I)
	local from = v3(d.from, I.at)
	blinkFx(I, from, I.to, I.pal.core, I.pal.glow)
	rune(I.ground(I.to), I.radius or 8, I.pal.glow, 0.5, 10)
	ring(I.ground(I.to), 1, I.radius or 8, I.pal.core, 0.35, 10)
end
E.frost_nova = function(_d, I)
	local g = I.ground(I.at)
	disc(g, (I.radius or 19) + 1, I.pal.core, 0.7, 1.1, ICE)
	ring(g, 2, I.radius or 19, I.pal.glow, 0.6, 16, 0.6)
	for k = 0, Q(12) - 1 do
		local a = k / 12 * math.pi * 2
		local r = 5 + (k % 3) * 3
		spike(g + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r), 3 + (k % 2) * 1.5, 0.8, I.pal.glow, ICE, 0.9, Vector3.new(math.cos(a), 0, math.sin(a)) * 0.45, 0.02 * k)
	end
	burst(I.at, { tex = SMOKE, color = I.pal.glow, light = 0.3, size = NumberSequence.new(2, 6), life = { 0.6, 1.2 }, speed = { 8, 14 }, spread = 90, transp = NumberSequence.new(0.3, 1) }, 18)
	flash(I.at, I.pal.glow, 12, 0.45)
	shake(I.at, 0.7, 50)
	sound(PING, I.at, 0.7, 0.6)
end
local function chainFx(I: any, from: Vector3, list: { Vector3 }, color: Color3, glow: Color3, width: number)
	local prev = from
	for i, t in list do
		local a, b = prev, t
		task.delay((i - 1) * 0.06, function()
			zigzag(a, b, glow, width, 0.25)
			zigzag(a, b, color, width * 0.5, 0.35, nil, 2.4)
			flash(b, glow, 5, 0.25, i <= 3)
			burst(b, { tex = SPARKS, color = glow, size = 0.4, life = { 0.15, 0.35 }, speed = { 10, 20 } }, 8)
		end)
		prev = t
	end
end
E.chain_lightning = function(_d, I)
	local list = if #I.targets > 0 then I.targets else { I.to }
	chainFx(I, I.at + Vector3.new(0, 1.5, 0) + I.dir * 1.5, list, I.pal.core, I.pal.glow, 0.45)
	sound(PING, I.at, 0.6, 2)
end
E.mana_shield = function(d, I)
	-- panes of mana orbit you for the duration
	orbit(I.caster, 4, 3.2, 1.5, I.pal.core, I.duration, { size = Vector3.new(2.4, 3.2, 0.15), material = Enum.Material.ForceField, transparency = 0.1, speed = 2.5 })
	for i, a in d.allies or {} do
		if i <= 6 then
			bubble(v3(a), 7, I.pal.glow, 0.6)
		end
	end
	ring(I.ground(I.at), 1, I.radius or 14, I.pal.glow, 0.5, 12)
	sound(PING, I.at, 0.5, 1.1)
end
E.meteor = function(_d, I)
	local g = I.ground(I.to)
	local def = I.def
	local delay = def.delay or 1.1
	local sky = g + Vector3.new(-30, 90, -18)
	-- the telegraph on the ground
	disc(g, (I.radius or 20) * 0.7, I.pal.core, delay, 0.15)
	rune(g, (I.radius or 20) * 0.55, I.pal.glow, delay, 10)
	local rock = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 7, CFrame = CFrame.new(sky), Color = I.pal.dark, Material = Enum.Material.Basalt }, delay + 0.4)
	local shell = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 9, CFrame = CFrame.new(sky), Color = I.pal.core, Transparency = 0.35 }, delay + 0.4)
	light(shell, I.pal.glow, 40, 5)
	emitter(shell, { tex = FIRE, color = I.pal.core, size = NumberSequence.new(6, 1), life = { 0.4, 0.8 }, speed = { 1, 3 }, rate = 60 })
	emitter(rock, { tex = SMOKE, color = Color3.fromRGB(80, 60, 50), light = 0, size = NumberSequence.new(4, 9), life = { 0.8, 1.4 }, speed = { 0, 1 }, rate = 25, transp = NumberSequence.new(0.3, 1) })
	tween(rock, delay, { CFrame = CFrame.new(g + Vector3.new(0, 2, 0)) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(shell, delay, { CFrame = CFrame.new(g + Vector3.new(0, 2, 0)) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(delay, function()
		flash(g + Vector3.new(0, 3, 0), I.pal.glow, (I.radius or 20) * 1.4, 0.7)
		disc(g, (I.radius or 20) + 4, I.pal.core, 0.8, 1.2)
		ring(g, 3, (I.radius or 20) + 2, I.pal.glow, 0.7, 18, 1)
		chunks(g, 14, I.pal.dark, Enum.Material.Basalt, (I.radius or 20), 1.5)
		burst(g + Vector3.new(0, 2, 0), { tex = FIRE, color = I.pal.core, size = NumberSequence.new(5, 1), life = { 0.6, 1.2 }, speed = { 18, 32 }, spread = 70 }, 40)
		burst(g, { tex = SMOKE, color = Color3.fromRGB(90, 70, 60), light = 0, size = NumberSequence.new(6, 12), life = { 1.2, 2 }, speed = { 6, 12 }, spread = 80, transp = NumberSequence.new(0.3, 1) }, 18)
		local scorch = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, (I.radius or 20) * 1.3, (I.radius or 20) * 1.3), CFrame = CFrame.new(g) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(30, 22, 18), Material = Enum.Material.Slate, Transparency = 0.2 }, 6)
		tween(scorch, 2.5, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 3)
		shake(g, 3, 140)
		sound(THUD, g, 1, 0.35)
	end)
end
E.arcane_guardian = function(d, I)
	local key = tostring(d.player) .. ":" .. d.ability
	local old = constructs[key]
	if old then
		dissolve(old, I)
	end
	buildConstruct(key, d.style or "knight", I.to, I, I.duration)
	sound(PING, I.to, 0.7, 0.5)
end
E.cataclysm = function(_d, I)
	local g = I.ground(I.to)
	local def = I.def
	local delay = def.delay or 1.6
	local r = I.radius or 30
	-- runes in the sky over the spot, and on the ground
	local sky = g + Vector3.new(0, 45, 0)
	rune(g, r * 0.8, I.pal.glow, delay + 0.3, 16)
	for k = 0, Q(10) - 1 do
		local a = k / 10 * math.pi * 2
		local p = part({ Size = Vector3.new(r * 0.5, 0.3, 0.6), CFrame = CFrame.new(sky + Vector3.new(math.cos(a) * r * 0.7, 0, math.sin(a) * r * 0.7)) * CFrame.Angles(0, -a, 0), Color = I.pal.glow, Transparency = 1 }, delay + 1)
		tween(p, 0.4, { Transparency = 0.05 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, k * 0.05)
		tween(p, 0.4, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, delay)
	end
	-- beams falling inward
	for k = 0, Q(6) - 1 do
		local a = k / 6 * math.pi * 2
		local top = sky + Vector3.new(math.cos(a) * r * 0.7, 0, math.sin(a) * r * 0.7)
		local bottom = g + Vector3.new(math.cos(a) * r * 0.25, 0, math.sin(a) * r * 0.25)
		task.delay(delay * 0.55 + k * 0.06, function()
			lance(top, bottom, I.pal.core, I.pal.glow, 1.6, 0.4)
		end)
	end
	task.delay(delay, function()
		pillar(g, r * 0.5, 60, I.pal.glow, 0.9)
		flash(g + Vector3.new(0, 4, 0), I.pal.glow, r * 1.5, 0.8)
		disc(g, r + 6, I.pal.core, 0.9, 1.4)
		ring(g, 4, r + 4, I.pal.glow, 0.8, 20, 1.2)
		chunks(g, 12, Color3.fromRGB(70, 70, 90), STONE, r, 1.4)
		burst(g + Vector3.new(0, 3, 0), { color = I.pal.glow, size = 2, life = { 0.8, 1.5 }, speed = { 20, 40 }, spread = 80 }, 50)
		shake(g, 3.5, 180)
		sound(THUD, g, 1, 0.3)
	end)
end

-- ASSASSIN
E.blade_flurry = function(d, I)
	local to = I.to
	for k = 0, (d.hits or 6) - 1 do
		task.delay(k * 0.06, function()
			local o = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 4
			slash(to + o + Vector3.new(0, 1, 0), to - o, if k % 2 == 0 then I.pal.glow else Color3.fromRGB(200, 170, 255), 0.4, 0.22)
			if k % 2 == 0 then
				burst(to, { tex = SPARKS, color = I.pal.glow, size = 0.35, life = { 0.15, 0.3 }, speed = { 8, 16 } }, 6)
			end
		end)
	end
	sound(SLASH, to, 0.6, 1.3)
end
E.fan_of_knives = function(_d, I)
	local list = if #I.targets > 0 then I.targets else { I.to }
	for _, t in list do
		local a = I.at + Vector3.new(0, 1.2, 0)
		projectile(a, t, Color3.fromRGB(220, 225, 235), I.pal.glow, 0.35, 160, function()
			burst(t, { tex = SPARKS, color = I.pal.glow, size = 0.35, life = { 0.15, 0.3 }, speed = { 8, 14 } }, 6)
		end, { shape = Vector3.new(0.25, 0.08, 1.4), material = Enum.Material.Metal, trail = 0.15, rate = 10, spin = CFrame.Angles(0, 0, math.rad(720)) })
	end
	sound(LUNGE, I.at, 0.6, 1.5)
end
E.shadow_step = function(d, I)
	local from = v3(d.from, I.at)
	dashTrail(I, from, I.to, I.pal.core, 4)
	flash(from, I.pal.dark, 5, 0.35, false)
	burst(from, { tex = SMOKE, color = I.pal.core, light = 0.2, size = NumberSequence.new(2, 4), life = { 0.4, 0.8 }, speed = { 2, 5 }, transp = NumberSequence.new(0.3, 1) }, 12)
	local target = v3(d.target, I.to)
	slash(target + Vector3.new(-2, 2, 0), target + Vector3.new(2, -1, 0), I.pal.glow, 0.5, 0.3)
	flash(I.to, I.pal.glow, 6, 0.35)
	sound(LUNGE, I.to, 0.6, 1.2)
end
E.smoke_bomb = function(d, I)
	local from = v3(d.from, I.at)
	local holder = areaEmitter(I.ground(from) + Vector3.new(0, 2, 0), Vector3.new(I.radius or 12, 2, I.radius or 12), { tex = SMOKE, color = Color3.fromRGB(120, 120, 130), light = 0, size = NumberSequence.new(4, 8), life = { 1.5, 2.5 }, speed = { 1, 3 }, rate = 30, transp = NumberSequence.new(0.2, 1) }, 3)
	local _ = holder
	burst(from, { tex = SMOKE, color = Color3.fromRGB(140, 140, 150), light = 0, size = NumberSequence.new(4, 9), life = { 1, 1.8 }, speed = { 6, 12 }, transp = NumberSequence.new(0.2, 1) }, 24)
	flash(from, WHITE, 6, 0.2, false)
	blinkFx(I, from, I.to, Color3.fromRGB(120, 120, 130), Color3.fromRGB(200, 200, 210))
	sound(THUD, from, 0.6, 1.4)
end
E.venom_mist = function(_d, I)
	local g = I.ground(I.to)
	local r = I.radius or 12
	areaEmitter(g + Vector3.new(0, 1.5, 0), Vector3.new(r * 1.6, 2, r * 1.6), { tex = SMOKE, color = I.pal.core, light = 0.3, size = NumberSequence.new(3, 7), life = { 1.2, 2 }, speed = { 0.5, 2 }, rate = 26, transp = NumberSequence.new(0.35, 1), accel = Vector3.new(0, 1, 0) }, I.duration)
	areaEmitter(g + Vector3.new(0, 0.5, 0), Vector3.new(r * 1.4, 1, r * 1.4), { tex = SPARKLE, color = I.pal.glow, size = 0.5, life = { 0.6, 1.2 }, speed = { 1, 3 }, rate = 12, accel = Vector3.new(0, 3, 0) }, I.duration)
	rune(g, r, I.pal.core, I.duration, 10)
	sound(PING, g, 0.4, 0.8)
end
E.crippling_strike = function(d, I)
	for k = 0, (d.hits or 2) - 1 do
		task.delay(k * 0.1, function()
			slash(I.to + Vector3.new(-2.5, -1 + k * 0.4, -1), I.to + Vector3.new(2.5, -1.8 + k * 0.4, 1), I.pal.glow, 0.5, 0.3, 0)
		end)
	end
	rune(I.ground(I.to), 3, Color3.fromRGB(170, 120, 255), 1.5, 8)
	burst(I.to, { tex = SPARKS, color = I.pal.glow, size = 0.4, life = { 0.2, 0.4 }, speed = { 8, 14 } }, 10)
	sound(SLASH, I.to, 0.6, 0.9)
end
E.assassinate = function(d, I)
	local from = v3(d.from, I.at)
	blinkFx(I, from, I.to, I.pal.core, I.pal.glow)
	local target = v3(d.target, I.to)
	task.delay(0.12, function()
		local cf = CFrame.lookAt(target, target + I.dir) * CFrame.Angles(0, 0, math.rad(35))
		crescent(cf, 4, WHITE, 0.4, 9, 1.2)
		slash(target + Vector3.new(-4, 3, 0), target + Vector3.new(4, -2, 0), I.pal.glow, 1, 0.45, 20)
		flash(target, I.pal.glow, 9, 0.4)
		burst(target, { tex = SPARKS, color = WHITE, size = 0.6, life = { 0.2, 0.5 }, speed = { 14, 26 } }, 20)
		shake(target, 1, 40)
		sound(SLASH, target, 0.9, 0.7)
	end)
end
E.afterimage = function(_d, I)
	for k = 0, 3 do
		local a = k / 4 * math.pi * 2
		local p = I.at + Vector3.new(math.cos(a) * 3, 0, math.sin(a) * 3)
		ghost(CFrame.lookAt(p, p + I.dir), I.pal.core, 1 + k * 0.2, 0.35)
	end
	orbit(I.caster, 3, 2.6, 2, I.pal.glow, I.duration, { size = Vector3.new(0.2, 0.2, 1.6), speed = 8 })
	burst(I.at, { color = I.pal.glow, size = 0.6, life = { 0.4, 0.8 }, speed = { 3, 7 } }, 16)
	sound(PING, I.at, 0.4, 1.6)
end
E.phantom_dance = function(_d, I)
	local list = if #I.targets > 0 then I.targets else { I.to }
	for i, t in list do
		task.delay((i - 1) * 0.12, function()
			local a = math.random() * math.pi * 2
			local off = Vector3.new(math.cos(a), 0, math.sin(a)) * 3
			ghost(CFrame.lookAt(t + off, t), I.pal.core, 0.6, 0.2)
			slash(t + off + Vector3.new(0, 2, 0), t - off - Vector3.new(0, 1, 0), I.pal.glow, 0.6, 0.3)
			flash(t, I.pal.glow, 5, 0.3, i <= 2)
			sound(SLASH, t, 0.5, 1.1 + i * 0.05)
		end)
	end
	ring(I.ground(I.at), 1, I.range or 30, I.pal.core, 0.6, 14)
	shake(I.at, 1, 50)
end
E.silent_verdict = function(_d, I)
	local delay = I.def.delay or 0.5
	-- the street goes quiet: a dark hush around the target, then one white cut
	local hush = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 30, CFrame = CFrame.new(I.to), Color = Color3.fromRGB(10, 6, 20), Material = Enum.Material.ForceField, Transparency = 1 }, delay + 1)
	tween(hush, delay * 0.8, { Transparency = 0.2, Size = Vector3.one * 16 })
	tween(hush, 0.3, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, delay)
	task.delay(delay, function()
		local a = I.to - I.right * 9 + Vector3.new(0, 4, 0)
		local b = I.to + I.right * 9 - Vector3.new(0, 2, 0)
		lance(a, b, I.pal.glow, WHITE, 0.9, 0.5)
		crescent(CFrame.lookAt(I.to, I.to + I.dir) * CFrame.Angles(0, 0, math.rad(-25)), 6, WHITE, 0.45, 9, 1.4)
		flash(I.to, WHITE, 14, 0.5)
		burst(I.to, { tex = SPARKS, color = WHITE, size = 0.7, life = { 0.3, 0.6 }, speed = { 20, 34 } }, 26)
		shake(I.to, 2, 70)
		sound(SLASH, I.to, 1, 0.5)
	end)
end

-- TANKER
E.shield_bash = function(_d, I)
	local front = I.at + I.dir * 3.5
	local plate = part({ Size = Vector3.new(4, 4.5, 0.4), CFrame = CFrame.lookAt(front, front + I.dir), Color = I.pal.glow, Material = Enum.Material.ForceField, Transparency = 0.1 }, 0.5)
	tween(plate, 0.4, { CFrame = CFrame.lookAt(front + I.dir * 3, front + I.dir * 4), Transparency = 1 })
	flash(front, WHITE, 7, 0.3)
	ring(I.ground(front), 1, 7, I.pal.glow, 0.35, 10)
	burst(front, { tex = SPARKS, color = I.pal.glow, size = 0.5, life = { 0.2, 0.4 }, speed = { 10, 18 }, spread = 50, dirn = Enum.NormalId.Front }, 14)
	shake(I.at, 1, 40)
	sound(THUD, front, 0.9, 0.9)
end
local function tauntWave(I: any, at: Vector3, radius: number)
	local g = I.ground(at)
	ring(g, 2, radius, Color3.fromRGB(255, 70, 60), 0.8, 18, 0.7)
	disc(g, radius * 0.6, Color3.fromRGB(255, 90, 70), 0.6, 0.2)
	flash(at + Vector3.new(0, 3, 0), Color3.fromRGB(255, 80, 60), 9, 0.5)
	for _, t in I.targets do
		local mark = part({ Size = Vector3.new(0.5, 1.6, 0.5), CFrame = CFrame.new(t + Vector3.new(0, 4, 0)), Color = Color3.fromRGB(255, 60, 50), Transparency = 0.1 }, 1.6)
		tween(mark, 1.4, { Transparency = 1, CFrame = CFrame.new(t + Vector3.new(0, 6, 0)) })
	end
end
E.rampart_slam = function(_d, I)
	local g = I.ground(I.to)
	disc(g, (I.radius or 10) + 1, I.pal.core, 0.5, 0.6)
	chunks(g, 8, I.pal.dark, STONE, 8, 1)
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		spike(g + Vector3.new(math.cos(a) * 4, 0, math.sin(a) * 4), 2.6, 1.3, I.pal.dark, STONE, 0.5, Vector3.new(math.cos(a), 0, math.sin(a)) * 0.4, 0.02 * k)
	end
	tauntWave(I, I.to, I.radius or 10)
	shake(I.to, 1.4, 60)
	sound(THUD, I.to, 1, 0.6)
end
E.bulwark_charge = function(d, I)
	local from = v3(d.from, I.at)
	local look = flat(I.to - from)
	local plate = part({ Size = Vector3.new(5, 5, 0.4), CFrame = CFrame.lookAt(from + look * 3, from + look * 4), Color = I.pal.glow, Material = Enum.Material.ForceField, Transparency = 0.1 }, 0.9)
	tween(plate, 0.25, { CFrame = CFrame.lookAt(I.to + look * 3, I.to + look * 4) }, Enum.EasingStyle.Linear)
	tween(plate, 0.5, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0.3)
	dashTrail(I, from, I.to, I.pal.core, 2)
	burst(I.ground(from), { tex = SMOKE, color = Color3.fromRGB(170, 165, 160), light = 0, size = NumberSequence.new(2, 6), life = { 0.5, 1 }, speed = { 5, 10 }, transp = NumberSequence.new(0.4, 1) }, 12)
	flash(I.to + look * 3, WHITE, 7, 0.3)
	shake(I.to, 1.2, 50)
	sound(THUD, I.to, 1, 0.7)
end
E.provoke = function(_d, I)
	tauntWave(I, I.at, I.radius or 45)
	shake(I.at, 0.6, 40)
	sound(PING, I.at, 0.7, 0.5)
end
E.hold_the_line = function(_d, I)
	local g = I.ground(I.at)
	disc(g, 14, I.pal.core, 0.5, 0.7)
	chunks(g, 8, I.pal.dark, STONE, 12, 1)
	tauntWave(I, I.at, I.radius or 30)
	bubble(I.at, 7, Color3.fromRGB(255, 160, 120), 1.5)
	shake(I.at, 1.6, 70)
	sound(THUD, I.at, 1, 0.5)
end
E.shield_wall = function(d, I)
	-- a row of shields in front of you
	for k = -2, 2 do
		local p = I.at + I.dir * 4 + I.right * k * 2.6
		local s = part({ Size = Vector3.new(2.6, 5, 0.3), CFrame = CFrame.lookAt(I.ground(p) + Vector3.new(0, -2, 0), I.ground(p) + Vector3.new(0, -2, 0) + I.dir), Color = I.pal.glow, Material = Enum.Material.ForceField, Transparency = 0.1 }, I.duration + 1)
		tween(s, 0.25, { CFrame = CFrame.lookAt(I.ground(p) + Vector3.new(0, 2.6, 0), I.ground(p) + Vector3.new(0, 2.6, 0) + I.dir) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.04 * (k + 2))
		tween(s, 0.6, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, I.duration)
	end
	for i, a in d.allies or {} do
		if i <= 6 then
			bubble(v3(a), 6.5, I.pal.glow, 0.5)
		end
	end
	sound(THUD, I.at, 0.8, 1)
end
local function tethers(I: any, list: { any }, color: Color3)
	for i, a in list do
		if i <= 6 then
			local p = v3(a)
			if (p - I.at).Magnitude > 1 then
				lance(I.at + Vector3.new(0, 1, 0), p + Vector3.new(0, 1, 0), color, WHITE, 0.4, 0.8)
			end
			bubble(p, 7, color, 1)
		end
	end
end
E.guardian_oath = function(d, I)
	tethers(I, d.allies or {}, I.pal.core)
	pillar(I.ground(I.at), 3, 20, I.pal.glow, 1)
	ring(I.ground(I.at), 1, I.radius or 28, I.pal.glow, 0.6, 14)
	sound(PING, I.at, 0.6, 0.7)
end
E.bastion = function(_d, I)
	local g = I.ground(I.at)
	for k = 0, Q(8) - 1 do
		local a = k / 8 * math.pi * 2
		spike(g + Vector3.new(math.cos(a) * 9, 0, math.sin(a) * 9), 7, 2.6, I.pal.dark, STONE, I.duration * 0.6, nil, 0.04 * k)
	end
	disc(g, 24, I.pal.core, 0.7, 0.9)
	chunks(g, 12, I.pal.dark, STONE, 18, 1.4)
	tauntWave(I, I.at, I.radius or 60)
	bubble(I.at, 9, Color3.fromRGB(255, 150, 110), I.duration * 0.6)
	shake(I.at, 2.6, 110)
	sound(THUD, I.at, 1, 0.35)
end
E.aegis = function(d, I)
	local r = I.radius or 26
	local dome = bubble(I.at, r * 2, I.pal.glow, I.duration, Enum.Material.ForceField)
	light(dome, I.pal.glow, r * 1.5, 1.5)
	ring(I.ground(I.at), r * 0.3, r, I.pal.core, 0.7, 20, 1)
	rune(I.ground(I.at), r * 0.92, I.pal.glow, I.duration, 18)
	for i, a in d.allies or {} do
		if i <= 6 then
			burst(v3(a), { color = I.pal.glow, size = 0.7, life = { 0.6, 1.2 }, speed = { 2, 5 }, accel = Vector3.new(0, 4, 0) }, 14)
		end
	end
	shake(I.at, 1, 60)
	sound(PING, I.at, 0.8, 0.45)
end

-- RANGER
local function arrow(a: Vector3, b: Vector3, color: Color3, glow: Color3, speed: number, onLand: (() -> ())?)
	return projectile(a, b, color, glow, 0.3, speed, onLand, { shape = Vector3.new(0.18, 0.18, 3), trail = 0.18, rate = 20 })
end
E.piercing_arrow = function(_d, I)
	local a = I.at + Vector3.new(0, 1.5, 0) + I.dir * 1.5
	local b = I.to + Vector3.new(0, 1.5, 0)
	arrow(a, b, I.pal.glow, Color3.fromRGB(190, 255, 190), 260)
	lance(a, b, Color3.fromRGB(170, 255, 170), WHITE, 0.6, 0.45)
	for _, t in I.targets do
		flash(t, Color3.fromRGB(200, 255, 200), 4, 0.25, false)
	end
	sound(LUNGE, I.at, 0.6, 1.6)
end
E.multishot = function(_d, I)
	local list = if #I.targets > 0 then I.targets else { I.to }
	for i, t in list do
		task.delay((i - 1) * 0.04, function()
			arrow(I.at + Vector3.new(0, 1.5, 0), t, I.pal.glow, Color3.fromRGB(190, 255, 190), 180, function()
				flash(t, Color3.fromRGB(200, 255, 200), 3.5, 0.25, false)
			end)
		end)
	end
	sound(LUNGE, I.at, 0.6, 1.4)
end
E.backstep_shot = function(d, I)
	local from = v3(d.from, I.at)
	burst(I.ground(from), { tex = SMOKE, color = Color3.fromRGB(180, 200, 190), light = 0, size = NumberSequence.new(2, 5), life = { 0.4, 0.8 }, speed = { 4, 8 }, transp = NumberSequence.new(0.4, 1) }, 12)
	ghost(CFrame.lookAt(from, from + I.dir), I.pal.core, 0.4)
	for k = -1, 1 do
		slash(from + I.right * k, I.to + I.right * k, I.pal.glow, 0.2, 0.3, 0)
	end
	local target = v3(d.target, I.to + I.dir * 40)
	task.delay(0.1, function()
		arrow(I.to + Vector3.new(0, 1.5, 0), target, I.pal.glow, WHITE, 220, function()
			flash(target, I.pal.glow, 4, 0.3, false)
		end)
	end)
	sound(LUNGE, I.to, 0.6, 1.3)
end
E.arrow_rain = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 15
	rune(c, r, Color3.fromRGB(190, 255, 190), I.duration, 10)
	local n = Q(22)
	for k = 1, n do
		task.delay((k / n) * I.duration, function()
			local a, rr = math.random() * math.pi * 2, math.sqrt(math.random()) * r
			local hit = c + Vector3.new(math.cos(a) * rr, 0, math.sin(a) * rr)
			local p = part({ Size = Vector3.new(0.15, 0.15, 3), CFrame = CFrame.lookAt(hit + Vector3.new(4, 34, 2), hit), Color = Color3.fromRGB(200, 255, 200) }, 0.5)
			tween(p, 0.22, { CFrame = CFrame.lookAt(hit + Vector3.new(0.3, 1.2, 0.15), hit) }, Enum.EasingStyle.Linear)
			tween(p, 0.2, { Transparency = 1 }, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0.24)
			if k % 3 == 0 then
				task.delay(0.22, function()
					flash(hit + Vector3.new(0, 0.4, 0), Color3.fromRGB(200, 255, 200), 2.5, 0.2, false)
				end)
			end
		end)
	end
	sound(LUNGE, c, 0.6, 1.1)
end
E.snare_trap = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 9
	rune(c, r, I.pal.glow, I.duration, 12)
	ring(c, r * 0.3, r, I.pal.core, 0.4, 10)
	local steps = math.floor(I.duration / 1)
	for k = 0, steps - 1 do
		task.delay(k, function()
			disc(c, r, I.pal.core, 0.5, 0.15)
		end)
	end
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		spike(c + Vector3.new(math.cos(a) * r * 0.8, 0, math.sin(a) * r * 0.8), 2.2, 0.35, I.pal.glow, Enum.Material.Neon, I.duration - 0.5, Vector3.new(-math.cos(a), 0, -math.sin(a)) * 0.6, 0.03 * k)
	end
	sound(PING, c, 0.5, 1.2)
end
local function explosion(at: Vector3, pal: any, radius: number, big: boolean?)
	flash(at, pal.glow, radius * 1.2, 0.45)
	disc(Vector3.new(at.X, at.Y - 1.5, at.Z), radius, pal.core, 0.45, 0.4)
	burst(at, { tex = FIRE, color = pal.core, size = NumberSequence.new(3, 0.5), life = { 0.3, 0.7 }, speed = { 10, 22 } }, if big then 36 else 22)
	burst(at, { tex = SMOKE, color = Color3.fromRGB(80, 70, 66), light = 0, size = NumberSequence.new(3, 6), life = { 0.8, 1.4 }, speed = { 4, 9 }, transp = NumberSequence.new(0.3, 1) }, 12)
	burst(at, { tex = SPARKS, color = pal.glow, size = 0.5, life = { 0.4, 0.8 }, speed = { 18, 30 } }, 16)
end
E.explosive_arrow = function(_d, I)
	local t = I.to
	arrow(I.at + Vector3.new(0, 1.5, 0), t, I.pal.core, I.pal.glow, 160, function()
		explosion(t, I.pal, (I.def.splash or 12) * 0.9, false)
		shake(t, 1.2, 60)
		sound(THUD, t, 0.9, 0.7)
	end)
	sound(LUNGE, I.at, 0.6, 1.2)
end
E.eagle_eye = function(_d, I)
	local head = I.at + Vector3.new(0, 1.6, 0)
	for k = 0, 2 do
		task.delay(k * 0.15, function()
			ring(head, 0.5, 3 + k, I.pal.glow, 0.5, 10, 0.2)
		end)
	end
	orbit(I.caster, 3, 2.2, 3, I.pal.core, I.duration, { size = Vector3.new(0.12, 0.12, 2.4), speed = 5, rise = 1 })
	burst(head, { color = I.pal.glow, size = 0.5, life = { 0.4, 0.8 }, speed = { 2, 5 } }, 14)
	sound(PING, I.at, 0.4, 1.9)
end
E.mana_hawk = function(d, I)
	local key = tostring(d.player) .. ":" .. d.ability
	local old = constructs[key]
	if old then
		dissolve(old, I)
	end
	buildConstruct(key, "hawk", I.at, I, I.duration)
	sound(PING, I.at, 0.6, 2.2)
end
E.skypierce = function(_d, I)
	local a = I.at + Vector3.new(0, 1.5, 0) + I.dir * 2
	local b = I.to + Vector3.new(0, 1.5, 0)
	flash(a, I.pal.glow, 8, 0.4)
	lance(a, b, I.pal.core, WHITE, 5, 0.9)
	for k = 1, Q(6) do
		local p = a:Lerp(b, k / 7)
		task.delay(k * 0.03, function()
			ring(p, 1, 6, I.pal.glow, 0.4, 10, 0.3)
		end)
	end
	for _, t in I.targets do
		flash(t, WHITE, 6, 0.3, false)
	end
	shake(I.at, 2.4, 100)
	sound(LUNGE, I.at, 1, 0.6)
end
E.starfall_volley = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 24
	rune(c, r, I.pal.glow, I.duration, 16)
	local n = Q(18)
	for k = 1, n do
		task.delay((k / n) * I.duration, function()
			local a, rr = math.random() * math.pi * 2, math.sqrt(math.random()) * r
			local hit = c + Vector3.new(math.cos(a) * rr, 0, math.sin(a) * rr)
			projectile(hit + Vector3.new(-10, 50, -6), hit, I.pal.core, I.pal.glow, 0.9, 140, if k % 2 == 0 then function()
				flash(hit + Vector3.new(0, 0.5, 0), I.pal.glow, 4, 0.3, false)
			end else nil)
		end)
	end
	shake(c, 1.4, 90)
	sound(PING, c, 0.7, 1.5)
end

-- HEALER
local function motes(at: Vector3, color: Color3, n: number)
	burst(at, { color = color, size = 0.6, life = { 0.8, 1.4 }, speed = { 2, 4 }, spread = 35, accel = Vector3.new(0, 3, 0) }, n)
end
E.mend = function(d, I)
	for i, hp in d.healed or {} do
		if i <= 6 then
			local p = v3(hp)
			flash(p + Vector3.new(0, 1, 0), I.pal.glow, 5, 0.5, i <= 2)
			motes(p, Color3.fromRGB(160, 255, 200), 22)
			ring(I.ground(p), 0.5, 3.5, Color3.fromRGB(160, 255, 200), 0.6, 8, 0.2)
		end
	end
	ring(I.ground(I.at), 1, I.radius or 22, I.pal.glow, 0.6, 12)
	sound(PING, I.at, 0.5, 1.3)
end
E.soothing_light = function(_d, I)
	orbit(I.caster, 6, 3, 3, Color3.fromRGB(190, 255, 220), I.duration, { size = Vector3.new(0.45, 0.45, 0.45), speed = 3, rise = 1.5 })
	local steps = math.floor(I.duration)
	for k = 0, steps - 1 do
		task.delay(k, function()
			motes(I.caster(), Color3.fromRGB(190, 255, 220), 10)
		end)
	end
	sound(PING, I.at, 0.4, 1.5)
end
E.purifying_wave = function(_d, I)
	local g = I.ground(I.at)
	ring(g, 1, I.radius or 16, I.pal.glow, 0.5, 16, 1.4)
	disc(g, I.radius or 16, I.pal.core, 0.5, 0.2)
	burst(I.at, { color = I.pal.glow, size = 0.8, life = { 0.5, 0.9 }, speed = { 14, 22 }, spread = 90 }, 26)
	flash(I.at, I.pal.glow, 9, 0.35)
	sound(PING, I.at, 0.6, 0.9)
end
E.sanctuary = function(_d, I)
	local r = I.radius or 26
	local dome = bubble(I.at, r * 2, Color3.fromRGB(140, 255, 210), I.duration, Enum.Material.ForceField)
	local _ = dome
	ring(I.ground(I.at), 1, r, Color3.fromRGB(140, 255, 210), 1)
	areaEmitter(I.ground(I.at) + Vector3.new(0, 1, 0), Vector3.new(r * 1.4, 1, r * 1.4), { color = Color3.fromRGB(180, 255, 220), size = 0.5, life = { 1, 1.6 }, speed = { 1, 2 }, rate = 18, accel = Vector3.new(0, 3, 0) }, I.duration)
	sound(PING, I.at, 0.6, 0.8)
end
E.regeneration = function(d, I)
	for i, hp in d.healed or {} do
		if i <= 6 then
			local p = v3(hp)
			orbit(function()
				return p
			end, 3, 1.6, 4, Color3.fromRGB(140, 255, 170), math.min(I.duration, 4), { size = Vector3.new(0.3, 0.3, 0.8), speed = 5, rise = 2 })
		end
	end
	ring(I.ground(I.at), 1, I.radius or 24, Color3.fromRGB(140, 255, 170), 0.7, 12)
	sound(PING, I.at, 0.5, 1.1)
end
E.barrier = function(d, I)
	for i, a in d.allies or {} do
		if i <= 6 then
			bubble(v3(a), 7, I.pal.glow, I.duration * 0.8)
		end
	end
	ring(I.ground(I.at), 1, I.radius or 22, I.pal.glow, 0.6, 12)
	burst(I.at, { color = I.pal.glow, size = 0.6, life = { 0.5, 1 }, speed = { 3, 7 } }, 16)
	sound(PING, I.at, 0.6, 1)
end
E.warding_sigil = function(_d, I)
	local g = I.ground(I.at)
	local r = I.radius or 16
	rune(g, r, I.pal.glow, I.duration, 16)
	rune(g, r * 0.55, I.pal.core, I.duration, 8)
	local wall = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(3, r * 2, r * 2), CFrame = CFrame.new(g + Vector3.new(0, 1.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = I.pal.glow, Material = Enum.Material.ForceField, Transparency = 1 }, I.duration + 1)
	tween(wall, 0.4, { Transparency = 0.4 })
	tween(wall, 0.6, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, I.duration)
	sound(PING, I.at, 0.5, 0.9)
end
E.light_warden = function(d, I)
	local key = tostring(d.player) .. ":" .. d.ability
	local old = constructs[key]
	if old then
		dissolve(old, I)
	end
	buildConstruct(key, "warden", I.to, I, I.duration)
	pillar(I.ground(I.to), 3, 30, I.pal.glow, 0.9)
	sound(PING, I.to, 0.7, 0.7)
end
E.grace = function(d, I)
	pillar(I.ground(I.at), 5, 50, I.pal.glow, 1.2)
	for i, hp in d.healed or {} do
		if i <= 6 then
			local p = v3(hp)
			pillar(I.ground(p), 2.5, 30, Color3.fromRGB(255, 250, 220), 1, 0.1 * i)
			motes(p, I.pal.glow, 18)
			bubble(p, 7, I.pal.glow, 1.4)
		end
	end
	ring(I.ground(I.at), 2, I.radius or 40, I.pal.glow, 0.9, 18, 0.8)
	shake(I.at, 0.8, 60)
	sound(PING, I.at, 0.8, 0.6)
end
local function rays(at: Vector3, n: number, length: number, color: Color3, life: number)
	n = Q(n)
	for k = 0, n - 1 do
		local a = k / n * math.pi * 2
		local dir = Vector3.new(math.cos(a), 0.35, math.sin(a)).Unit
		local p = part({ Size = Vector3.new(0.6, 0.6, length), CFrame = CFrame.lookAt(at + dir * length / 2, at + dir * length), Color = color, Transparency = 0.3 }, life + 0.1)
		tween(p, life, { Transparency = 1, Size = Vector3.new(0.1, 0.1, length * 1.3) })
	end
end
E.resurgence = function(d, I)
	local r = I.radius or 45
	flash(I.at + Vector3.new(0, 3, 0), I.pal.glow, r, 0.9)
	rays(I.at + Vector3.new(0, 2, 0), 12, r * 0.8, I.pal.glow, 0.9)
	ring(I.ground(I.at), 2, r, I.pal.core, 1, 20, 1.2)
	disc(I.ground(I.at), r, WHITE, 0.9, 0.3)
	for i, hp in d.healed or {} do
		if i <= 6 then
			motes(v3(hp), I.pal.glow, 20)
		end
	end
	for _, t in I.targets do
		flash(t, I.pal.glow, 5, 0.4, false)
	end
	areaEmitter(I.ground(I.at) + Vector3.new(0, 1, 0), Vector3.new(r, 1, r), { color = I.pal.glow, size = 0.7, life = { 1.2, 2 }, speed = { 1, 3 }, rate = 40, accel = Vector3.new(0, 4, 0) }, 2)
	shake(I.at, 2, 120)
	sound(PING, I.at, 1, 0.4)
end

-- HUNTER CRAFT
E.blink = function(d, I)
	blinkFx(I, v3(d.from, I.at), I.to, I.pal.core, I.pal.glow)
end
E.mana_armour = function(_d, I)
	ghost(CFrame.lookAt(I.at, I.at + I.dir), I.pal.core, I.duration * 0.6, 0.35)
	orbit(I.caster, 4, 1.8, 4, I.pal.glow, I.duration, { size = Vector3.new(0.25, 0.25, 0.25), speed = 4, rise = 1 })
	burst(I.at, { color = I.pal.glow, size = 0.5, life = { 0.4, 0.8 }, speed = { 2, 6 } }, 18)
	sound(PING, I.at, 0.5, 1.2)
end

-- FIRE
E.fireball = function(_d, I)
	local t = I.to
	projectile(I.at + Vector3.new(0, 1.5, 0) + I.dir, t, I.pal.core, I.pal.glow, 1.8, I.def.speed or 110, function()
		explosion(t, I.pal, (I.def.splash or 9), false)
		shake(t, 0.9, 50)
		sound(THUD, t, 0.8, 0.8)
	end, { tex = FIRE, trail = 0.35, rate = 70 })
	sound(LUNGE, I.at, 0.5, 0.8)
end
E.ring_of_fire = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 12
	local n = Q(14)
	for k = 0, n - 1 do
		local a = k / n * math.pi * 2
		local p = c + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
		local holder = part({ Size = Vector3.new(2, 1, 2), CFrame = CFrame.new(p + Vector3.new(0, 0.5, 0)), Color = I.pal.core, Transparency = 0.2 }, I.duration + 1.5)
		local pe = emitter(holder, { tex = FIRE, color = I.pal.core, size = NumberSequence.new(3, 0.4), life = { 0.5, 0.9 }, speed = { 4, 8 }, rate = 12, spread = 12, accel = Vector3.new(0, 4, 0) })
		tween(holder, 0.6, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, I.duration)
		task.delay(I.duration, function()
			pe.Enabled = false
		end)
		if k % 4 == 0 then
			light(holder, I.pal.core, 14, 2)
		end
	end
	disc(c, r, I.pal.dark, 0.6, 0.15)
	sound(LUNGE, c, 0.6, 0.6)
end
E.inferno = function(_d, I)
	local g = I.ground(I.at)
	local r = I.radius or 28
	flash(I.at, I.pal.glow, r, 0.7)
	ring(g, 2, r, I.pal.core, 0.8, 20, 2)
	disc(g, r + 2, I.pal.core, 0.8, 1)
	burst(I.at, { tex = FIRE, color = I.pal.core, size = NumberSequence.new(6, 1), life = { 0.7, 1.3 }, speed = { 22, 40 }, spread = 90 }, 50)
	burst(I.at, { tex = SPARKS, color = I.pal.glow, size = 0.6, life = { 0.8, 1.4 }, speed = { 20, 36 } }, 30)
	areaEmitter(g + Vector3.new(0, 1, 0), Vector3.new(r * 1.4, 1, r * 1.4), { tex = FIRE, color = I.pal.core, size = NumberSequence.new(3, 0), life = { 0.6, 1.1 }, speed = { 3, 7 }, rate = 50, spread = 15, accel = Vector3.new(0, 6, 0) }, 1.5)
	pillar(g, 6, 40, I.pal.glow, 0.8)
	shake(I.at, 3, 140)
	sound(THUD, I.at, 1, 0.4)
end

-- FROST
E.frost_shard = function(_d, I)
	local t = I.to
	projectile(I.at + Vector3.new(0, 1.5, 0) + I.dir, t, I.pal.glow, I.pal.core, 0.6, I.def.speed or 150, function()
		chunks(t, 6, I.pal.glow, ICE, 4, 0.6)
		flash(t, I.pal.glow, 5, 0.3)
		burst(t, { tex = SMOKE, color = I.pal.glow, light = 0.4, size = NumberSequence.new(1, 3), life = { 0.4, 0.8 }, speed = { 3, 6 }, transp = NumberSequence.new(0.3, 1) }, 8)
	end, { shape = Vector3.new(0.5, 0.5, 2.4), material = ICE, transparency = 0.15, trail = 0.3, spin = CFrame.Angles(0, 0, math.rad(540)) })
	sound(PING, I.at, 0.4, 2)
end
E.ice_spikes = function(_d, I)
	local from = I.ground(I.at + I.dir * 3)
	local len = (I.to - I.at).Magnitude
	local n = Q(12)
	for k = 0, n - 1 do
		local p = from + I.dir * (len * k / n) + I.right * (math.random() - 0.5) * 3
		spike(p, 4 + math.random() * 3, 1.1, I.pal.glow, ICE, 0.9, I.right * (math.random() - 0.5) * 0.7 + I.dir * 0.2, k * 0.04)
		if k % 3 == 0 then
			task.delay(k * 0.04, function()
				burst(p, { tex = SMOKE, color = I.pal.glow, light = 0.3, size = NumberSequence.new(1.5, 4), life = { 0.5, 1 }, speed = { 3, 6 }, transp = NumberSequence.new(0.3, 1) }, 5)
			end)
		end
	end
	sound(PING, I.at, 0.6, 0.7)
end
E.blizzard = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 26
	areaEmitter(c + Vector3.new(0, 26, 0), Vector3.new(r * 1.8, 1, r * 1.8), { tex = SPARKLE, color = I.pal.glow, size = 0.7, life = { 1.4, 2 }, speed = { 14, 20 }, rate = 70, spread = 10, dirn = Enum.NormalId.Bottom, accel = Vector3.new(6, 0, 2) }, I.duration)
	areaEmitter(c + Vector3.new(0, 2, 0), Vector3.new(r * 1.6, 2, r * 1.6), { tex = SMOKE, color = I.pal.core, light = 0.3, size = NumberSequence.new(5, 9), life = { 1.6, 2.4 }, speed = { 1, 3 }, rate = 18, transp = NumberSequence.new(0.5, 1) }, I.duration)
	disc(c, r, I.pal.glow, 0.8, 0.4, ICE)
	local n = Q(12)
	for k = 1, n do
		task.delay((k / n) * I.duration, function()
			local a, rr = math.random() * math.pi * 2, math.sqrt(math.random()) * r
			local hit = c + Vector3.new(math.cos(a) * rr, 0, math.sin(a) * rr)
			projectile(hit + Vector3.new(6, 36, 3), hit, I.pal.glow, I.pal.core, 0.8, 120, function()
				chunks(hit, 3, I.pal.glow, ICE, 3, 0.5)
			end, { shape = Vector3.new(0.7, 0.7, 2.6), material = ICE, trail = 0.2, rate = 5 })
		end)
	end
	shake(c, 0.8, 80)
	sound(PING, c, 0.6, 0.5)
end

-- LIGHTNING
E.static_spark = function(_d, I)
	local list = if #I.targets > 0 then I.targets else { I.to }
	chainFx(I, I.at + Vector3.new(0, 1.5, 0) + I.dir, list, I.pal.core, I.pal.glow, 0.3)
	sound(PING, I.at, 0.4, 2.4)
end
local function strikeFromSky(I: any, at: Vector3, width: number)
	local g = I.ground(at)
	zigzag(g + Vector3.new((math.random() - 0.5) * 6, 40, (math.random() - 0.5) * 6), g, I.pal.glow, width, 0.3, 7, 2.2)
	zigzag(g + Vector3.new((math.random() - 0.5) * 6, 40, (math.random() - 0.5) * 6), g, I.pal.core, width * 0.5, 0.4, 6, 3)
	flash(g + Vector3.new(0, 1, 0), I.pal.glow, 6, 0.3, false)
	disc(g, 4, I.pal.glow, 0.3, 0.2)
end
E.thunderclap = function(_d, I)
	local g = I.ground(I.at)
	local r = I.radius or 16
	flash(I.at, I.pal.glow, 12, 0.35)
	ring(g, 1, r, WHITE, 0.4, 16, 0.6)
	disc(g, r, I.pal.core, 0.4, 0.3)
	for k = 0, Q(6) - 1 do
		local a = k / 6 * math.pi * 2
		task.delay(k * 0.03, function()
			strikeFromSky(I, I.at + Vector3.new(math.cos(a) * r * 0.6, 0, math.sin(a) * r * 0.6), 0.5)
		end)
	end
	shake(I.at, 1.8, 80)
	sound(THUD, I.at, 1, 1.4)
end
local function cloud(c: Vector3, r: number, seconds: number, color: Color3)
	for k = 0, 4 do
		local a = k / 5 * math.pi * 2
		local p = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(r * 0.9, r * 0.9, r * 0.9), CFrame = CFrame.new(c + Vector3.new(math.cos(a) * r * 0.45, 40 + (k % 2) * 3, math.sin(a) * r * 0.45)), Color = color, Material = Enum.Material.SmoothPlastic, Transparency = 1 }, seconds + 1.6)
		tween(p, 0.6, { Transparency = 0.45 })
		tween(p, 0.8, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, seconds)
	end
end
E.thunderstorm = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 26
	cloud(c, r, I.duration, Color3.fromRGB(60, 62, 80))
	rune(c, r, I.pal.core, I.duration, 14)
	sound(THUD, c, 0.8, 0.5)
	-- (the bolts come with each tick from the server; a few fall at once anyway)
	for k = 0, 2 do
		task.delay(0.2 + k * 0.15, function()
			local p = spots(I, c, r, 1)[1]
			strikeFromSky(I, p, 0.7)
		end)
	end
end

-- WIND
E.gale_step = function(d, I)
	local from = v3(d.from, I.at)
	for k = -2, 2 do
		local o = I.right * k * 1.2 + Vector3.new(0, (k % 2) * 0.8, 0)
		slash(from + o, I.to + o, I.pal.glow, 0.2, 0.4, 0)
	end
	orbit(function()
		return I.to
	end, 6, 3, 3, I.pal.core, 0.6, { size = Vector3.new(0.15, 0.15, 2.4), speed = 14, rise = 2 })
	burst(I.ground(from), { tex = SMOKE, color = I.pal.glow, light = 0.3, size = NumberSequence.new(2, 5), life = { 0.4, 0.8 }, speed = { 6, 12 }, transp = NumberSequence.new(0.4, 1) }, 12)
	ghost(CFrame.lookAt(from, from + I.dir), I.pal.core, 0.4, 0.5)
	sound(LUNGE, I.to, 0.6, 1.4)
end
E.wind_blades = function(_d, I)
	local list = if #I.targets > 0 then I.targets else { I.to }
	for i, t in list do
		local a = I.at + Vector3.new(0, 1.5, 0)
		local look = flat(t - a)
		local dur = math.clamp((t - a).Magnitude / (I.def.speed or 120), 0.08, 1)
		-- a crescent of air: three thin pieces flying together
		for k = -1, 1 do
			local off = CFrame.new(k * 1.1, 0, math.abs(k) * 0.5) * CFrame.Angles(0, -k * 0.35, 0)
			local p = part({ Size = Vector3.new(1.3, 0.12, 0.5), CFrame = CFrame.lookAt(a, a + look) * off, Color = I.pal.glow, Transparency = 0.05 }, dur + 0.3)
			tween(p, dur, { CFrame = CFrame.lookAt(t, t + look) * off }, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, (i - 1) * 0.05)
			tween(p, 0.2, { Transparency = 1 }, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, dur + (i - 1) * 0.05)
		end
		task.delay(dur + (i - 1) * 0.05, function()
			slash(t + Vector3.new(-2, 1, 0), t + Vector3.new(2, -1, 0), I.pal.glow, 0.4, 0.25)
		end)
	end
	sound(LUNGE, I.at, 0.6, 1.7)
end
E.tempest = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 22
	local function center(): Vector3
		return c
	end
	orbit(center, 12, r * 0.7, 14, I.pal.glow, I.duration, { size = Vector3.new(0.3, 0.3, 4), speed = 7, inward = true })
	orbit(center, 8, r * 0.35, 20, I.pal.core, I.duration, { size = Vector3.new(0.25, 0.25, 3), speed = -9 })
	areaEmitter(c + Vector3.new(0, 2, 0), Vector3.new(r, 2, r), { tex = SMOKE, color = Color3.fromRGB(200, 220, 210), light = 0, size = NumberSequence.new(4, 8), life = { 1, 1.6 }, speed = { 4, 8 }, rate = 22, accel = Vector3.new(0, 10, 0), transp = NumberSequence.new(0.5, 1) }, I.duration)
	disc(c, r, I.pal.core, 0.7, 0.2)
	shake(c, 1.2, 90)
	sound(LUNGE, c, 0.7, 0.5)
end

-- EARTH
E.stone_skin = function(_d, I)
	ghost(CFrame.lookAt(I.at, I.at + I.dir), I.pal.dark, I.duration * 0.5, 0.15, STONE)
	chunks(I.at, 6, I.pal.dark, STONE, 3, 0.6)
	burst(I.ground(I.at), { tex = SMOKE, color = Color3.fromRGB(170, 150, 130), light = 0, size = NumberSequence.new(2, 4), life = { 0.5, 0.9 }, speed = { 3, 6 }, transp = NumberSequence.new(0.4, 1) }, 10)
	ring(I.ground(I.at), 1, 6, I.pal.glow, 0.4, 10)
	sound(THUD, I.at, 0.7, 0.8)
end
E.earth_pillars = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 13
	local list = spots(I, c, r, 7)
	for i, p in list do
		if i <= 8 then
			spike(p, 6 + math.random() * 3, 2.4, I.pal.dark, STONE, 0.8, nil, 0.05 * (i - 1))
			task.delay(0.05 * (i - 1), function()
				burst(p, { tex = SMOKE, color = Color3.fromRGB(160, 140, 120), light = 0, size = NumberSequence.new(2, 5), life = { 0.5, 1 }, speed = { 4, 8 }, transp = NumberSequence.new(0.4, 1) }, 6)
			end)
		end
	end
	disc(c, r, I.pal.glow, 0.5, 0.2)
	chunks(c, 8, I.pal.dark, STONE, r, 1)
	shake(c, 1.5, 70)
	sound(THUD, c, 1, 0.6)
end
E.stone_colossus = function(d, I)
	local key = tostring(d.player) .. ":" .. d.ability
	local old = constructs[key]
	if old then
		dissolve(old, I)
	end
	local g = I.ground(I.to)
	chunks(g, 10, I.pal.dark, STONE, 8, 1.2)
	disc(g, 10, I.pal.glow, 0.6, 0.4)
	buildConstruct(key, "golem", I.to, I, I.duration)
	shake(g, 1.8, 80)
	sound(THUD, g, 1, 0.4)
end

-- HOLY
E.smite = function(_d, I)
	local g = I.ground(I.to)
	pillar(g, 2.4, 40, I.pal.glow, 0.6)
	lance(g + Vector3.new(0, 40, 0), g, I.pal.core, WHITE, 1.5, 0.4)
	flash(g + Vector3.new(0, 1, 0), I.pal.glow, 7, 0.35)
	ring(g, 0.5, I.radius or 6, I.pal.glow, 0.4, 10)
	sound(PING, g, 0.6, 1.2)
end
E.pillar_of_light = function(d, I)
	local g = I.ground(I.to)
	local r = I.radius or 12
	pillar(g, r * 0.75, 60, I.pal.glow, 1.1)
	disc(g, r, I.pal.core, 0.6, 0.3)
	rune(g, r, I.pal.glow, 0.9, 12)
	burst(g + Vector3.new(0, 2, 0), { color = I.pal.glow, size = 0.8, life = { 0.8, 1.4 }, speed = { 4, 10 }, accel = Vector3.new(0, 8, 0) }, 30)
	for i, hp in d.healed or {} do
		if i <= 6 then
			motes(v3(hp), Color3.fromRGB(190, 255, 210), 14)
		end
	end
	shake(g, 0.9, 60)
	sound(PING, g, 0.7, 0.8)
end
E.dawnbreak = function(d, I)
	local g = I.ground(I.at)
	local r = I.radius or 34
	local sun = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 4, CFrame = CFrame.new(I.at + Vector3.new(0, 18, 0)), Color = I.pal.glow, Transparency = 0.05 }, 2.2)
	light(sun, I.pal.glow, 80, 6, 2)
	tween(sun, 0.6, { Size = Vector3.one * 16 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tween(sun, 1, { Transparency = 1, Size = Vector3.one * 30 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0.9)
	rays(I.at + Vector3.new(0, 18, 0), 14, r, I.pal.glow, 1.2)
	ring(g, 2, r, I.pal.core, 0.9, 20, 1)
	disc(g, r, WHITE, 0.9, 0.3)
	for _, t in I.targets do
		flash(t, I.pal.glow, 5, 0.4, false)
	end
	for i, hp in d.healed or {} do
		if i <= 6 then
			motes(v3(hp), I.pal.glow, 16)
		end
	end
	shake(I.at, 2.4, 130)
	sound(PING, I.at, 1, 0.5)
end

-- VOID
local function implode(at: Vector3, pal: any, radius: number, big: boolean?)
	local shell = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * radius * 2, CFrame = CFrame.new(at), Color = pal.core, Material = Enum.Material.ForceField, Transparency = 0.2 }, 0.6)
	tween(shell, 0.35, { Size = Vector3.one * 0.5, Transparency = 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	-- motes pulled in from all round
	local n = Q(if big then 16 else 10)
	for k = 1, n do
		local dir = Vector3.new(math.random() - 0.5, math.random() - 0.3, math.random() - 0.5)
		dir = if dir.Magnitude > 0.01 then dir.Unit else Vector3.yAxis
		local p = part({ Size = Vector3.new(0.3, 0.3, 1.6), CFrame = CFrame.lookAt(at + dir * radius, at), Color = pal.glow, Transparency = 0.05 }, 0.6)
		tween(p, 0.35, { CFrame = CFrame.lookAt(at + dir * 0.4, at), Transparency = 0.8 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local _ = k
	end
	task.delay(0.36, function()
		flash(at, pal.glow, radius * (if big then 1.5 else 1), 0.4)
		burst(at, { color = pal.glow, size = 0.8, life = { 0.4, 0.8 }, speed = { 14, 26 } }, if big then 40 else 20)
		disc(Vector3.new(at.X, at.Y - 1.5, at.Z), radius, pal.core, 0.4, 0.3)
	end)
end
E.void_orb = function(_d, I)
	local t = I.to
	local a = I.at + Vector3.new(0, 1.5, 0) + I.dir
	local travel = projectile(a, t, I.pal.dark, I.pal.glow, 2, I.def.speed or 60, nil, { trail = 0.5, rate = 30 })
	-- a purple rim around the dark core, flying with it
	local rim = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 2.8, CFrame = CFrame.new(a), Color = I.pal.core, Material = Enum.Material.ForceField, Transparency = 0.1 }, travel + 0.2)
	tween(rim, travel, { CFrame = CFrame.new(t) }, Enum.EasingStyle.Linear)
	task.delay(travel + (I.def.delay or 0.4) * 0.3, function()
		implode(t, I.pal, I.def.splash or 10, false)
		sound(PING, t, 0.6, 0.4)
	end)
end
E.gravity_well = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius or 14
	local core = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 3, CFrame = CFrame.new(c + Vector3.new(0, 2, 0)), Color = I.pal.dark, Material = Enum.Material.SmoothPlastic, Transparency = 0 }, I.duration + 0.8)
	light(core, I.pal.core, r * 1.5, 3)
	tween(core, 0.6, { Transparency = 1, Size = Vector3.one * 0.5 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, I.duration)
	rune(c, r, I.pal.core, I.duration, 12)
	orbit(function()
		return c + Vector3.new(0, 0.5, 0)
	end, 10, r * 0.9, 3, I.pal.glow, I.duration, { size = Vector3.new(0.2, 0.2, 1.8), speed = 5, inward = true })
	areaEmitter(c + Vector3.new(0, 0.5, 0), Vector3.new(r * 1.6, 1, r * 1.6), { tex = SMOKE, color = I.pal.core, light = 0.4, size = NumberSequence.new(2, 0.5), life = { 0.8, 1.2 }, speed = { 0.5, 1.5 }, rate = 16, transp = NumberSequence.new(0.4, 1) }, I.duration)
	sound(PING, c, 0.5, 0.35)
end
E.singularity = function(_d, I)
	local c = I.ground(I.to) + Vector3.new(0, 4, 0)
	local delay = I.def.delay or 1.5
	local r = I.radius or 24
	local hole = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 0.5, CFrame = CFrame.new(c), Color = Color3.new(0, 0, 0), Material = Enum.Material.SmoothPlastic, Transparency = 0 }, delay + 0.8)
	light(hole, I.pal.core, r * 2, 5)
	tween(hole, delay, { Size = Vector3.one * 7 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	orbit(function()
		return c
	end, 14, r, 2, I.pal.glow, delay, { size = Vector3.new(0.3, 0.3, 3), speed = 9, inward = true })
	ring(I.ground(c), r, 1, I.pal.core, delay, 16, 0.4)
	task.delay(delay, function()
		implode(c, I.pal, r, true)
		tween(hole, 0.3, { Size = Vector3.one * 0.1, Transparency = 1 })
		task.delay(0.4, function()
			flash(c, WHITE, r * 1.6, 0.5)
			ring(I.ground(c), 2, r + 6, I.pal.glow, 0.7, 18, 0.8)
			shake(c, 3, 150)
			sound(THUD, c, 1, 0.3)
		end)
	end)
end

-- ── THE SHAPES: every move that is only data is drawn by its shape, in its element, at its tier ──
-- Each element has its own language: the particle texture it throws, the material its solid
-- things are made of, and a flourish where it lands (embers, mist, arcs, streaks, rocks,
-- droplets, rays, an inward pull, bubbles, leaves, runes, ripples, sparks).
local LANG: { [string]: any } = {
	physical = { tex = SPARKS, solid = Enum.Material.Metal, flourish = "sparks", sound = SLASH, pitch = 1 },
	fire = { tex = FIRE, solid = Enum.Material.Basalt, flourish = "embers", sound = LUNGE, pitch = 0.8 },
	frost = { tex = SPARKLE, solid = Enum.Material.Ice, flourish = "mist", sound = PING, pitch = 1.6 },
	lightning = { tex = SPARKS, solid = Enum.Material.Neon, flourish = "arcs", sound = PING, pitch = 2.2 },
	wind = { tex = SMOKE, solid = Enum.Material.ForceField, flourish = "streaks", sound = LUNGE, pitch = 1.5 },
	earth = { tex = SMOKE, solid = Enum.Material.Slate, flourish = "rocks", sound = THUD, pitch = 0.6 },
	water = { tex = SPARKLE, solid = Enum.Material.Glass, flourish = "droplets", sound = THUD, pitch = 1.3 },
	holy = { tex = SPARKLE, solid = Enum.Material.Neon, flourish = "rays", sound = PING, pitch = 0.9 },
	void = { tex = GLOW, solid = Enum.Material.SmoothPlastic, flourish = "inward", sound = PING, pitch = 0.4 },
	venom = { tex = SMOKE, solid = Enum.Material.Glass, flourish = "bubbles", sound = PING, pitch = 0.7 },
	life = { tex = SPARKLE, solid = Enum.Material.Grass, flourish = "leaves", sound = PING, pitch = 1.2 },
	mana = { tex = SPARKLE, solid = Enum.Material.ForceField, flourish = "runes", sound = PING, pitch = 1.4 },
	sound = { tex = SHOCK, solid = Enum.Material.ForceField, flourish = "ripples", sound = THUD, pitch = 1.8 },
}
SkillFx.LANG = LANG
local function langOf(I: any): any
	return LANG[I.def.element or "mana"] or LANG.mana
end
-- the colour of a solid thing in that element (stone is dark, void is near black)
local function solidColor(I: any): Color3
	local el = I.def.element
	if el == "earth" or el == "void" then
		return I.pal.dark
	end
	return I.pal.core
end
-- how much of an effect to draw, by tier (E small, S big)
local function many(I: any, n: number): number
	return math.max(1, math.floor(n * (0.7 + I.tier * 0.12) + 0.5))
end

-- the element's flourish at a point
local function flourish(I: any, at: Vector3, strength: number?)
	local L = langOf(I)
	local pal = I.pal
	local k = strength or 1
	local f = L.flourish
	if f == "embers" then
		burst(at, { tex = FIRE, color = pal.core, size = NumberSequence.new(2 * k, 0.2), life = { 0.3, 0.6 }, speed = { 6, 14 } }, 12)
		burst(at, { tex = SPARKS, color = pal.glow, size = 0.4, life = { 0.6, 1.1 }, speed = { 6, 12 }, accel = Vector3.new(0, 8, 0) }, 10)
	elseif f == "mist" then
		burst(at, { tex = SMOKE, color = pal.glow, light = 0.3, size = NumberSequence.new(1.5 * k, 4 * k), life = { 0.5, 1 }, speed = { 3, 6 }, transp = NumberSequence.new(0.3, 1) }, 8)
		chunks(at, 3, pal.glow, ICE, 3 * k, 0.5)
	elseif f == "arcs" then
		for _ = 1, 2 do
			local o = Vector3.new(math.random() - 0.5, math.random(), math.random() - 0.5) * 6 * k
			zigzag(at, at + o, pal.glow, 0.2, 0.2, 3, 0.8)
		end
		burst(at, { tex = SPARKS, color = pal.glow, size = 0.35, life = { 0.15, 0.3 }, speed = { 10, 20 } }, 8)
	elseif f == "streaks" then
		for j = -1, 1 do
			local o = Vector3.new(j * 1.2, j * 0.5, 0)
			slash(at + o - I.right * 3 * k, at + o + I.right * 3 * k, pal.glow, 0.15, 0.3, 0)
		end
		burst(at, { tex = SMOKE, color = pal.glow, light = 0.2, size = NumberSequence.new(1, 3), life = { 0.3, 0.6 }, speed = { 6, 10 }, transp = NumberSequence.new(0.5, 1) }, 6)
	elseif f == "rocks" then
		chunks(at, 5, pal.dark, STONE, 5 * k, 0.8)
		burst(at, { tex = SMOKE, color = Color3.fromRGB(170, 150, 130), light = 0, size = NumberSequence.new(2 * k, 4 * k), life = { 0.5, 0.9 }, speed = { 3, 7 }, transp = NumberSequence.new(0.4, 1) }, 8)
	elseif f == "droplets" then
		burst(at, { color = pal.glow, size = 0.5, life = { 0.5, 0.9 }, speed = { 8, 14 }, spread = 60, accel = Vector3.new(0, -30, 0) }, 16)
		disc(Vector3.new(at.X, I.floor + 0.1, at.Z), 4 * k, pal.core, 0.4, 0.15, Enum.Material.Glass)
	elseif f == "rays" then
		rays(at, 6, 6 * k, pal.glow, 0.4)
	elseif f == "inward" then
		local shell = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 6 * k, CFrame = CFrame.new(at), Color = pal.core, Material = Enum.Material.ForceField, Transparency = 0.3 }, 0.5)
		tween(shell, 0.3, { Size = Vector3.one * 0.3, Transparency = 0.8 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	elseif f == "bubbles" then
		burst(at, { tex = SMOKE, color = pal.core, light = 0.3, size = NumberSequence.new(1.5 * k, 3.5 * k), life = { 0.6, 1.1 }, speed = { 1, 3 }, transp = NumberSequence.new(0.35, 1) }, 8)
		for _ = 1, 3 do
			local b = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * (0.4 + math.random() * 0.4), CFrame = CFrame.new(at + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * 2), Color = pal.glow, Material = Enum.Material.Glass, Transparency = 0.3 }, 1)
			tween(b, 0.9, { CFrame = b.CFrame + Vector3.new(0, 3 + math.random() * 2, 0), Transparency = 1 })
		end
	elseif f == "leaves" then
		for _ = 1, 5 do
			local a = math.random() * math.pi * 2
			local leaf = part({ Size = Vector3.new(0.5, 0.08, 0.7), CFrame = CFrame.new(at) * CFrame.Angles(0, a, 0.4), Color = if math.random() < 0.5 then pal.core else pal.glow, Transparency = 0.05 }, 1.3)
			tween(leaf, 1.1, { CFrame = CFrame.new(at + Vector3.new(math.cos(a) * 4 * k, 2 + math.random() * 2, math.sin(a) * 4 * k)) * CFrame.Angles(1.5, a + 2, 0.8), Transparency = 1 })
		end
		burst(at, { color = pal.glow, size = 0.4, life = { 0.6, 1 }, speed = { 2, 4 }, accel = Vector3.new(0, 3, 0) }, 8)
	elseif f == "runes" then
		rune(Vector3.new(at.X, I.floor + 0.1, at.Z), 3 * k, pal.glow, 0.5, 6)
		burst(at, { color = pal.glow, size = 0.5, life = { 0.3, 0.6 }, speed = { 4, 9 } }, 10)
	elseif f == "ripples" then
		for j = 0, 2 do
			local d0 = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.1, 1, 1), CFrame = CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90)), Color = pal.glow, Material = Enum.Material.ForceField, Transparency = 0.1 }, 0.8)
			tween(d0, 0.5, { Size = Vector3.new(0.1, 7 * k + j * 3, 7 * k + j * 3), Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, j * 0.08)
		end
	else
		burst(at, { tex = SPARKS, color = pal.glow, size = 0.4, life = { 0.2, 0.4 }, speed = { 8, 16 } }, 10)
	end
end
local function landSound(I: any, at: Vector3, volume: number?)
	local L = langOf(I)
	sound(L.sound, at, volume or 0.6, L.pitch)
end
-- a solid body in the element (a rock, a shard, a ball of water, an orb)
local function body(I: any, size: number): any
	local el = I.def.element
	if el == "earth" then
		return { shape = Vector3.new(size, size * 0.9, size), material = STONE, color = I.pal.dark }
	elseif el == "frost" then
		return { shape = Vector3.new(size * 0.45, size * 0.45, size * 1.8), material = ICE, color = I.pal.glow }
	elseif el == "water" then
		return { material = Enum.Material.Glass, color = I.pal.core, transparency = 0.25 }
	elseif el == "void" then
		return { material = Enum.Material.SmoothPlastic, color = I.pal.dark }
	elseif el == "physical" then
		return { shape = Vector3.new(0.18, 0.18, size * 2.4), material = Enum.Material.Metal, color = Color3.fromRGB(220, 225, 235) }
	end
	return { color = I.pal.core }
end
local function shoot(I: any, a: Vector3, b: Vector3, size: number, speed: number, onLand: (() -> ())?)
	local B = body(I, size)
	return projectile(a, b, B.color, I.pal.glow, size, speed, onLand, {
		shape = B.shape, material = B.material, transparency = B.transparency, tex = langOf(I).tex,
		trail = 0.2 + I.tier * 0.04, rate = 20 + I.tier * 8,
	})
end
local function hitAll(I: any, list: { Vector3 }, strength: number?)
	for i, t in list do
		if i <= 6 then
			flash(t, I.pal.glow, 3 + I.tier, 0.3, i <= 2)
			if i <= 3 then
				flourish(I, t, strength)
			end
		end
	end
end

local SHAPES: { [string]: (any, any) -> () } = {}
SkillFx.SHAPES = SHAPES

SHAPES.projectile = function(d, I)
	local a = I.at + Vector3.new(0, 1.5, 0) + I.dir
	local t = I.to
	local size = 0.7 + I.tier * 0.22
	local splash = I.def.splash
	shoot(I, a, t, size, I.def.speed or 130, function()
		flash(t, I.pal.glow, size * 4 + (splash or 0) * 0.6, 0.35)
		flourish(I, t, 0.6 + I.tier * 0.15)
		if splash then
			disc(Vector3.new(t.X, I.floor + 0.1, t.Z), splash, I.pal.core, 0.4, 0.3)
			burst(t, { tex = langOf(I).tex, color = I.pal.core, size = NumberSequence.new(splash * 0.25, 0.3), life = { 0.3, 0.7 }, speed = { splash, splash * 2 } }, many(I, 16))
		end
		landSound(I, t, 0.6)
	end)
	sound(langOf(I).sound, I.at, 0.4, (langOf(I).pitch or 1) * 1.2)
	local _ = d
end
SHAPES.volley = function(_d, I)
	local list = if #I.targets > 0 then I.targets else { I.to }
	local size = 0.4 + I.tier * 0.12
	for i, t in list do
		task.delay((i - 1) * 0.04, function()
			shoot(I, I.at + Vector3.new(0, 1.4, 0) + I.dir, t, size, I.def.speed or 150, function()
				flash(t, I.pal.glow, 2.5 + I.tier * 0.5, 0.25, false)
				if i <= 2 then
					flourish(I, t, 0.5)
				end
			end)
		end)
	end
	sound(langOf(I).sound, I.at, 0.5, (langOf(I).pitch or 1) * 1.3)
end
SHAPES.wave = function(_d, I)
	local a = I.at + Vector3.new(0, 1.2, 0) + I.dir * 2
	local b = I.to + Vector3.new(0, 1.2, 0)
	local w = (I.def.width or 4) * 0.8
	local dur = math.clamp((b - a).Magnitude / 120, 0.12, 0.6)
	local n = many(I, 5)
	for k = 0, n - 1 do
		local u = n == 1 and 0 or (k / (n - 1)) * 2 - 1
		local off = CFrame.new(u * w, 0, math.abs(u) * w * 0.4)
		local p = part({ Size = Vector3.new(w * 0.55, 0.15, 0.6), CFrame = CFrame.lookAt(a, b) * off * CFrame.Angles(0, -u * 0.5, 0), Color = if k % 2 == 0 then I.pal.glow else I.pal.core, Material = if I.def.element == "sound" or I.def.element == "wind" then Enum.Material.ForceField else Enum.Material.Neon, Transparency = 0.05 }, dur + 0.3)
		tween(p, dur, { CFrame = CFrame.lookAt(b, b + (b - a).Unit) * off * CFrame.Angles(0, -u * 0.5, 0) }, Enum.EasingStyle.Linear)
		tween(p, 0.2, { Transparency = 1 }, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, dur)
	end
	local holder = part({ Size = Vector3.new(w * 2, 1, (b - a).Magnitude), CFrame = CFrame.lookAt((a + b) / 2, b), Transparency = 1 }, 1.2)
	emit(emitter(holder, { tex = langOf(I).tex, color = I.pal.glow, size = NumberSequence.new(0.8, 0), life = { 0.3, 0.6 }, speed = { 1, 3 }, transp = NumberSequence.new(0.3, 1) }), many(I, 16))
	task.delay(dur, function()
		hitAll(I, I.targets, 0.6)
	end)
	sound(langOf(I).sound, I.at, 0.5, langOf(I).pitch)
end
SHAPES.lance = function(_d, I)
	local a = I.at + Vector3.new(0, 1.5, 0) + I.dir * 1.5
	local b = I.to + Vector3.new(0, 1.5, 0)
	local width = (I.def.width or 3.5) * 0.55
	if I.def.element == "lightning" then
		zigzag(a, b, I.pal.glow, width * 0.4, 0.35, 10, 1.2)
	end
	lance(a, b, I.pal.core, I.pal.glow, width, 0.35 + I.tier * 0.06)
	flash(a, I.pal.glow, 3 + I.tier, 0.3)
	hitAll(I, I.targets, 0.7)
	if I.tier >= 5 then
		for k = 1, 4 do
			local p = a:Lerp(b, k / 5)
			task.delay(k * 0.03, function()
				ring(p, 0.5, 3 + I.tier, I.pal.glow, 0.35, 8, 0.25)
			end)
		end
		shake(I.at, 1.4 + I.tier * 0.2, 90)
	end
	sound(langOf(I).sound, I.at, 0.6, langOf(I).pitch)
end
SHAPES.spikes = function(_d, I)
	local L = langOf(I)
	local from = I.ground(I.at + I.dir * 3)
	local len = (I.to - I.at).Magnitude
	local n = many(I, 9)
	local w = (I.def.width or 6) * 0.25
	for k = 0, n - 1 do
		local p = from + I.dir * (len * k / n) + I.right * (math.random() - 0.5) * w * 2
		spike(p, 3 + I.tier * 0.6 + math.random() * 2, w + math.random() * 0.5, solidColor(I), L.solid, 0.6, I.right * (math.random() - 0.5) * 0.7, k * 0.035)
		if k % 3 == 0 then
			task.delay(k * 0.035, function()
				flourish(I, p + Vector3.new(0, 1, 0), 0.5)
			end)
		end
	end
	shake(I.at, 0.6 + I.tier * 0.25, 70)
	landSound(I, I.at, 0.8)
end
SHAPES.nova = function(_d, I)
	local g = I.ground(I.to)
	local r = I.radius
	flash(g + Vector3.new(0, 2, 0), I.pal.glow, r * 0.7, 0.45)
	disc(g, r + 1, I.pal.core, 0.55, 0.4 + I.tier * 0.1, if I.def.element == "frost" then ICE else Enum.Material.Neon)
	ring(g, 1, r, I.pal.glow, 0.5, many(I, 14), 0.5)
	local n = many(I, 6)
	for k = 0, n - 1 do
		local a = k / n * math.pi * 2
		flourish(I, g + Vector3.new(math.cos(a) * r * 0.55, 1, math.sin(a) * r * 0.55), 0.5)
	end
	if I.tier >= 4 then
		shake(g, 0.8 + I.tier * 0.3, 90)
	end
	landSound(I, g, 0.8)
end
SHAPES.shockwave = function(_d, I)
	local g = I.ground(I.at)
	local r = I.radius
	for j = 0, math.min(3, 1 + math.floor(I.tier / 2)) do
		task.delay(j * 0.08, function()
			ring(g, 1, r * (1 - j * 0.15), if j % 2 == 0 then I.pal.glow else I.pal.core, 0.45, many(I, 12), 0.7)
		end)
	end
	disc(g, r, I.pal.core, 0.45, 0.3, if I.def.element == "sound" then Enum.Material.ForceField else Enum.Material.Neon)
	flourish(I, I.at, 0.8)
	burst(g, { tex = langOf(I).tex, color = I.pal.glow, size = NumberSequence.new(1.5, 0), life = { 0.3, 0.6 }, speed = { r, r * 1.6 }, spread = 90 }, many(I, 18))
	shake(I.at, 0.6 + I.tier * 0.3, 80)
	landSound(I, I.at, 0.9)
end
SHAPES.cone = function(_d, I)
	local range = I.range
	local cf = CFrame.lookAt(I.at + Vector3.new(0, 0.6, 0), I.at + Vector3.new(0, 0.6, 0) + I.dir)
	local holder = part({ Size = Vector3.one, CFrame = cf, Transparency = 1 }, 1.4)
	local spread = math.deg(math.acos(math.clamp(I.def.arc or 0.55, -1, 1)))
	emit(emitter(holder, { tex = langOf(I).tex, color = I.pal.core, size = NumberSequence.new(1.5 + I.tier * 0.4, 0.2), life = { 0.35, 0.6 }, speed = { range * 1.4, range * 2 }, spread = spread, dirn = Enum.NormalId.Front }), many(I, 30))
	emit(emitter(holder, { tex = SPARKLE, color = I.pal.glow, size = 0.6, life = { 0.3, 0.5 }, speed = { range * 1.2, range * 1.8 }, spread = spread, dirn = Enum.NormalId.Front }), many(I, 12))
	for k = -2, 2 do
		local dir = (CFrame.fromAxisAngle(Vector3.yAxis, math.rad(spread * k / 2.5)) :: any):VectorToWorldSpace(I.dir)
		slash(I.at + dir * 2, I.at + dir * range, if k % 2 == 0 then I.pal.glow else I.pal.core, 0.3, 0.35, 0)
	end
	hitAll(I, I.targets, 0.5)
	landSound(I, I.at, 0.6)
end
SHAPES.slash = function(_d, I)
	local cf = CFrame.lookAt(I.at, I.at + I.dir) * CFrame.new(0, 0.2, -1.5)
	local r = (I.range or 12) * 0.6
	crescent(cf * CFrame.Angles(0, 0, math.rad(math.random(-25, 25))), r, I.pal.glow, 0.28, many(I, 7), 0.8 + I.tier * 0.12)
	if I.tier >= 3 then
		crescent(cf * CFrame.new(0, -0.4, 0) * CFrame.Angles(0, 0, math.rad(math.random(-25, 25))), r * 0.8, I.pal.core, 0.24, 6, 0.6)
	end
	burst(I.at + I.dir * r, { tex = SPARKS, color = I.pal.glow, size = 0.45, life = { 0.2, 0.45 }, speed = { 10, 20 }, spread = 60 }, many(I, 12))
	hitAll(I, I.targets, 0.5)
	sound(SLASH, I.at, 0.7, 0.9 + I.tier * 0.05)
end
SHAPES.strike = function(d, I)
	local to = I.to
	local n = math.clamp(d.hits or I.def.hits or 3, 1, 10)
	local delay = I.def.delay or 0
	for k = 0, n - 1 do
		task.delay(delay + k * 0.06, function()
			local o = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * (3 + I.tier * 0.4)
			slash(to + o + Vector3.new(0, 1, 0), to - o, if k % 2 == 0 then I.pal.glow else I.pal.core, 0.3 + I.tier * 0.05, 0.22)
			if k == n - 1 then
				flash(to, I.pal.glow, 3 + I.tier, 0.3)
				flourish(I, to, 0.6)
			end
		end)
	end
	sound(SLASH, to, 0.6, 1.2)
end
SHAPES.meteor = function(_d, I)
	local g = I.ground(I.to)
	local r = I.radius
	local delay = I.def.delay or 1
	local sky = g + Vector3.new(-24, 70 + I.tier * 6, -14)
	disc(g, r * 0.7, I.pal.core, delay, 0.15)
	rune(g, r * 0.55, I.pal.glow, delay, 10)
	local B = body(I, 3 + I.tier)
	local rock = part({ Shape = if B.shape then Enum.PartType.Block else Enum.PartType.Ball, Size = B.shape or (Vector3.one * (3 + I.tier)), CFrame = CFrame.new(sky), Color = B.color, Material = B.material or Enum.Material.Neon, Transparency = B.transparency or 0 }, delay + 0.3)
	light(rock, I.pal.glow, 30 + I.tier * 4, 4)
	emitter(rock, { tex = langOf(I).tex, color = I.pal.core, size = NumberSequence.new(3 + I.tier * 0.5, 0.5), life = { 0.4, 0.8 }, speed = { 1, 3 }, rate = 30 + I.tier * 10 })
	tween(rock, delay, { CFrame = CFrame.new(g + Vector3.new(0, 1.5, 0)) * CFrame.Angles(2, 1, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(delay, function()
		flash(g + Vector3.new(0, 3, 0), I.pal.glow, r * 1.3, 0.6)
		disc(g, r + 3, I.pal.core, 0.7, 1)
		ring(g, 2, r + 2, I.pal.glow, 0.6, many(I, 14), 0.9)
		chunks(g, many(I, 8), solidColor(I), langOf(I).solid, r, 1.2)
		for k = 0, 3 do
			local a = k / 4 * math.pi * 2
			flourish(I, g + Vector3.new(math.cos(a) * r * 0.4, 1, math.sin(a) * r * 0.4), 0.9)
		end
		shake(g, 1.5 + I.tier * 0.3, 140)
		landSound(I, g, 1)
	end)
end
SHAPES.pillar = function(_d, I)
	local g = I.ground(I.to)
	local r = I.radius
	pillar(g, r * 0.7, 30 + I.tier * 6, I.pal.glow, 0.8 + I.tier * 0.06)
	disc(g, r, I.pal.core, 0.6, 0.3)
	rune(g, r, I.pal.glow, 0.7, many(I, 10))
	burst(g + Vector3.new(0, 2, 0), { tex = langOf(I).tex, color = I.pal.glow, size = NumberSequence.new(1.4, 0), life = { 0.6, 1.2 }, speed = { 4, 10 }, accel = Vector3.new(0, 10, 0) }, many(I, 22))
	flourish(I, g + Vector3.new(0, 1, 0), 1)
	if I.tier >= 4 then
		shake(g, 0.6 + I.tier * 0.3, 80)
	end
	landSound(I, g, 0.8)
end
SHAPES.smite = function(_d, I)
	local g = I.ground(I.to)
	if I.def.element == "lightning" then
		zigzag(g + Vector3.new(0, 45, 0), g, I.pal.glow, 0.5 + I.tier * 0.1, 0.35, 8, 2.4)
	end
	lance(g + Vector3.new(0, 45, 0), g, I.pal.core, I.pal.glow, 1 + I.tier * 0.3, 0.4)
	flash(g + Vector3.new(0, 1, 0), I.pal.glow, 5 + I.tier, 0.35)
	ring(g, 0.5, I.radius, I.pal.glow, 0.4, 10)
	flourish(I, g + Vector3.new(0, 1, 0), 0.8)
	landSound(I, g, 0.7)
end
SHAPES.implode = function(_d, I)
	local g = I.ground(I.to)
	local c = g + Vector3.new(0, 3, 0)
	local delay = I.def.delay or 0.6
	local r = I.radius
	local core = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 0.5, CFrame = CFrame.new(c), Color = if I.def.element == "void" then Color3.new(0, 0, 0) else I.pal.core, Material = if I.def.element == "water" then Enum.Material.Glass else Enum.Material.Neon, Transparency = 0.1 }, delay + 0.8)
	tween(core, delay, { Size = Vector3.one * (2 + I.tier) })
	orbit(function()
		return c
	end, many(I, 8), r, 2, I.pal.glow, delay, { size = Vector3.new(0.25, 0.25, 2.4), speed = 9, inward = true })
	task.delay(delay, function()
		implode(c, I.pal, r, I.tier >= 5)
		tween(core, 0.3, { Size = Vector3.one * 0.1, Transparency = 1 })
		if I.tier >= 4 then
			shake(c, 1 + I.tier * 0.3, 110)
		end
		landSound(I, c, 0.8)
	end)
end
SHAPES.eruption = function(_d, I)
	local L = langOf(I)
	local c = I.ground(I.to)
	local r = I.radius
	local list = spots(I, c, r * 0.8, many(I, 5))
	for i, p in list do
		if i <= 8 then
			spike(p, 4 + I.tier * 0.8, 1.6 + I.tier * 0.2, solidColor(I), L.solid, 0.7, nil, 0.05 * (i - 1))
			task.delay(0.05 * (i - 1), function()
				flourish(I, p + Vector3.new(0, 1, 0), 0.6)
			end)
		end
	end
	disc(c, r, I.pal.glow, 0.5, 0.2)
	shake(c, 0.6 + I.tier * 0.25, 70)
	landSound(I, c, 0.9)
end
SHAPES.rain = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius
	rune(c, r, I.pal.glow, I.duration, many(I, 10))
	local n = Q(many(I, 14))
	local size = 0.5 + I.tier * 0.12
	for k = 1, n do
		task.delay((k / n) * I.duration, function()
			local a, rr = math.random() * math.pi * 2, math.sqrt(math.random()) * r
			local hit = c + Vector3.new(math.cos(a) * rr, 0, math.sin(a) * rr)
			shoot(I, hit + Vector3.new(-6, 40, -3), hit, size, 150, if k % 2 == 0 then function()
				flash(hit + Vector3.new(0, 0.5, 0), I.pal.glow, 2.5 + I.tier * 0.4, 0.25, false)
				if k % 4 == 0 then
					flourish(I, hit + Vector3.new(0, 0.5, 0), 0.4)
				end
			end else nil)
		end)
	end
	if I.tier >= 5 then
		shake(c, 1.2, 90)
	end
	landSound(I, c, 0.6)
end
local function fieldBase(I: any, c: Vector3, r: number, seconds: number)
	local L = langOf(I)
	rune(c, r, I.pal.core, seconds, many(I, 12))
	areaEmitter(c + Vector3.new(0, 1, 0), Vector3.new(r * 1.5, 1.5, r * 1.5), {
		tex = L.tex, color = I.pal.core, light = if L.tex == SMOKE then 0.3 else 1,
		size = if L.tex == SMOKE then NumberSequence.new(3, 6) else NumberSequence.new(0.8, 0),
		life = { 1, 1.6 }, speed = { 0.5, 2 }, rate = 10 + I.tier * 4,
		transp = NumberSequence.new(0.35, 1), accel = Vector3.new(0, 2, 0),
	}, seconds)
end
SHAPES.field = function(_d, I)
	local c = I.ground(if I.def.center == "self" then I.at else I.to)
	local r = I.radius
	fieldBase(I, c, r, I.duration)
	local glow = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, r * 2, r * 2), CFrame = CFrame.new(c) * CFrame.Angles(0, 0, math.rad(90)), Color = I.pal.core, Transparency = 1 }, I.duration + 1)
	light(glow, I.pal.glow, r * 1.4, 1.5)
	tween(glow, 0.3, { Transparency = 0.75 })
	tween(glow, 0.5, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, I.duration)
	if I.def.pull then
		orbit(function()
			return c + Vector3.new(0, 0.5, 0)
		end, many(I, 8), r * 0.9, 4, I.pal.glow, I.duration, { size = Vector3.new(0.25, 0.25, 2.2), speed = 6, inward = true })
	end
	if I.def.heal or I.def.guard then
		bubble(c, r * 2, I.pal.glow, I.duration, Enum.Material.ForceField)
	end
	landSound(I, c, 0.5)
end
SHAPES.storm = function(_d, I)
	local c = I.ground(I.to)
	local r = I.radius
	cloud(c, r, I.duration, I.pal.dark:Lerp(Color3.fromRGB(60, 62, 80), 0.6))
	fieldBase(I, c, r, I.duration)
	for k = 0, 2 do
		task.delay(0.2 + k * 0.15, function()
			SkillFx.stormBolt(I, spots(I, c, r, 1)[1])
		end)
	end
	shake(c, 0.8 + I.tier * 0.2, 110)
	landSound(I, c, 0.8)
end
-- one bolt of a storm, in its element (lightning zig-zags; anything else falls as a shaft)
function SkillFx.stormBolt(I: any, at: Vector3)
	local g = I.ground(at)
	if I.def.element == "lightning" or I.def.element == "sound" then
		zigzag(g + Vector3.new((math.random() - 0.5) * 6, 40, (math.random() - 0.5) * 6), g, I.pal.glow, 0.5 + I.tier * 0.06, 0.3, 7, 2.2)
	else
		lance(g + Vector3.new(0, 40, 0), g, I.pal.core, I.pal.glow, 0.8 + I.tier * 0.1, 0.3)
	end
	flash(g + Vector3.new(0, 1, 0), I.pal.glow, 5, 0.3, false)
	flourish(I, g + Vector3.new(0, 1, 0), 0.6)
end
SHAPES.wall = function(_d, I)
	local L = langOf(I)
	local c = I.ground(I.to)
	local len = I.radius * 2
	local n = many(I, 7)
	for k = 0, n - 1 do
		local u = (k / math.max(1, n - 1)) * 2 - 1
		local p = c + I.right * u * len / 2
		local h = 5 + I.tier * 0.6
		local seg = part({ Size = Vector3.new(len / n + 0.4, h, 1.4), CFrame = CFrame.lookAt(p - Vector3.new(0, h, 0), p - Vector3.new(0, h, 0) + I.dir), Color = solidColor(I), Material = if L.solid == Enum.Material.Neon then Enum.Material.ForceField else L.solid, Transparency = if L.solid == Enum.Material.Glass then 0.3 else 0.05 }, I.duration + 1)
		tween(seg, 0.25, { CFrame = CFrame.lookAt(p + Vector3.new(0, h / 2, 0), p + Vector3.new(0, h / 2, 0) + I.dir) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.03 * k)
		tween(seg, 0.6, { Transparency = 1, CFrame = CFrame.lookAt(p - Vector3.new(0, h * 0.6, 0), p - Vector3.new(0, h * 0.6, 0) + I.dir) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, I.duration)
		if k % 2 == 0 then
			local pe = emitter(seg, { tex = L.tex, color = I.pal.core, size = NumberSequence.new(1.5, 0), life = { 0.5, 0.9 }, speed = { 2, 4 }, rate = 6, accel = Vector3.new(0, 3, 0) })
			task.delay(I.duration, function()
				pe.Enabled = false
			end)
		end
	end
	flourish(I, c + Vector3.new(0, 1, 0), 0.8)
	landSound(I, c, 0.8)
end
SHAPES.orbit = function(_d, I)
	local L = langOf(I)
	local size = if L.solid == Enum.Material.Slate then Vector3.one * 0.9 elseif I.def.element == "lightning" or I.def.element == "fire" then Vector3.one * (0.6 + I.tier * 0.08) else Vector3.new(0.25, 0.25, 1.8)
	orbit(I.caster, many(I, 4), I.radius * 0.6, 2.5, I.pal.glow, I.duration, { size = size, speed = 5, material = if L.solid == Enum.Material.Slate then STONE else Enum.Material.Neon })
	orbit(I.caster, math.max(2, many(I, 2)), I.radius * 0.4, 1.5, I.pal.core, I.duration, { size = size * 0.7, speed = -7 })
	burst(I.at, { tex = L.tex, color = I.pal.glow, size = 0.6, life = { 0.3, 0.7 }, speed = { 4, 9 } }, many(I, 12))
	landSound(I, I.at, 0.5)
end
SHAPES.chain = function(_d, I)
	local list = if #I.targets > 0 then I.targets else { I.to }
	local from = I.at + Vector3.new(0, 1.5, 0) + I.dir
	if I.def.element == "lightning" then
		chainFx(I, from, list, I.pal.core, I.pal.glow, 0.3 + I.tier * 0.05)
	else
		local prev = from
		for i, t in list do
			local a, b = prev, t
			task.delay((i - 1) * 0.07, function()
				lance(a, b, I.pal.core, I.pal.glow, 0.5 + I.tier * 0.08, 0.3)
				flash(b, I.pal.glow, 4, 0.25, i <= 2)
				if i <= 3 then
					flourish(I, b, 0.5)
				end
			end)
			prev = t
		end
	end
	sound(langOf(I).sound, I.at, 0.6, (langOf(I).pitch or 1) * 1.2)
end
SHAPES.dash = function(d, I)
	local from = v3(d.from, I.at)
	dashTrail(I, from, I.to, I.pal.core, math.clamp(1 + math.floor(I.tier / 2), 2, 4))
	burst(I.ground(from), { tex = langOf(I).tex, color = I.pal.glow, light = 0.4, size = NumberSequence.new(1.5, 3), life = { 0.3, 0.7 }, speed = { 4, 9 }, transp = NumberSequence.new(0.35, 1) }, many(I, 10))
	flourish(I, I.to, 0.7)
	hitAll(I, I.targets, 0.4)
	if d.target then
		flash(v3(d.target), I.pal.glow, 5, 0.3)
	end
	sound(LUNGE, I.to, 0.6, 1.1)
end
SHAPES.leap = function(d, I)
	local from = v3(d.from, I.at)
	for k = 1, 5 do
		local t = k / 6
		local p = from:Lerp(I.to, t) + Vector3.new(0, math.sin(t * math.pi) * (8 + I.tier * 2), 0)
		ghost(CFrame.lookAt(p, p + I.dir), I.pal.glow, 0.25 + k * 0.05, 0.5)
	end
	task.delay(0.15, function()
		local g = I.ground(I.to)
		disc(g, (I.radius or 9) + 2, I.pal.core, 0.5, 0.5)
		ring(g, 1, I.radius or 9, I.pal.glow, 0.45, many(I, 10))
		flourish(I, g + Vector3.new(0, 1, 0), 1)
		flash(g + Vector3.new(0, 1, 0), I.pal.glow, 6 + I.tier, 0.35)
		shake(g, 0.8 + I.tier * 0.3, 70)
		landSound(I, g, 1)
	end)
end
SHAPES.blink = function(d, I)
	local from = v3(d.from, I.at)
	blinkFx(I, from, I.to, I.pal.core, I.pal.glow)
	flourish(I, I.to, 0.6)
	if I.def.radius then
		ring(I.ground(if I.def.back then from else I.to), 1, I.def.radius, I.pal.core, 0.4, 10)
	end
end
SHAPES.dome = function(d, I)
	local r = I.radius
	local dome = bubble(I.at, r * 2, I.pal.glow, I.duration, if I.def.element == "water" then Enum.Material.Glass else Enum.Material.ForceField)
	if I.tier >= 4 then
		light(dome, I.pal.glow, r * 1.2, 1.2)
	end
	ring(I.ground(I.at), r * 0.3, r, I.pal.core, 0.6, many(I, 14), 0.8)
	for i, a in d.allies or {} do
		if i <= 6 then
			burst(v3(a), { tex = langOf(I).tex, color = I.pal.glow, size = 0.6, life = { 0.5, 1 }, speed = { 2, 5 }, accel = Vector3.new(0, 3, 0) }, 10)
		end
	end
	flourish(I, I.at + Vector3.new(0, 2, 0), 0.8)
	landSound(I, I.at, 0.6)
end
SHAPES.ward = function(_d, I)
	local L = langOf(I)
	ghost(CFrame.lookAt(I.at, I.at + I.dir), solidColor(I), math.min(I.duration, 3) * 0.6, 0.3, if L.solid == Enum.Material.Neon then Enum.Material.ForceField else L.solid)
	orbit(I.caster, many(I, 3), 2, 3.5, I.pal.glow, I.duration, { size = Vector3.one * 0.35, speed = 4, rise = 1 })
	flourish(I, I.at, 0.6)
	ring(I.ground(I.at), 1, 5 + I.tier, I.pal.glow, 0.4, 10)
	landSound(I, I.at, 0.6)
end
SHAPES.aura = function(d, I)
	local L = langOf(I)
	local list = if d.allies and #d.allies > 0 then d.allies else { d.at }
	for i, a in list do
		if i <= 6 then
			local p = v3(a)
			local holder = part({ Size = Vector3.new(2, 4, 2), CFrame = CFrame.new(p), Transparency = 1 }, math.min(I.duration, 5) + 1.5)
			local pe = emitter(holder, { tex = L.tex, color = I.pal.core, size = NumberSequence.new(1, 0), life = { 0.4, 0.8 }, speed = { 2, 5 }, rate = 8 + I.tier * 3, spread = 15, accel = Vector3.new(0, 4, 0) })
			task.delay(math.min(I.duration, 5), function()
				pe.Enabled = false
			end)
			ring(I.ground(p), 0.5, 3 + I.tier * 0.4, I.pal.glow, 0.5, 8, 0.2)
		end
	end
	for k = 0, 1 do
		task.delay(k * 0.12, function()
			ring(I.at + Vector3.new(0, 1, 0), 1, 6 + k * 4 + I.tier, I.pal.glow, 0.45, 10, 0.3)
		end)
	end
	sound(PING, I.at, 0.5, 0.6 + I.tier * 0.05)
end
SHAPES.haste = function(d, I)
	local list = if d.allies and #d.allies > 0 then d.allies else { d.at }
	for i, a in list do
		if i <= 6 then
			local p = v3(a)
			for k = -1, 1 do
				slash(p + Vector3.new(k * 0.8, -1.5, 0) - I.dir * 2, p + Vector3.new(k * 0.8, -1.5, 0) + I.dir * 3, I.pal.glow, 0.15, 0.4, 0)
			end
			burst(Vector3.new(p.X, I.floor + 0.3, p.Z), { tex = langOf(I).tex, color = I.pal.glow, light = 0.4, size = NumberSequence.new(1, 2), life = { 0.3, 0.6 }, speed = { 3, 6 }, transp = NumberSequence.new(0.4, 1) }, 8)
		end
	end
	orbit(I.caster, 2, 1.6, 0.5, I.pal.core, math.min(I.duration, 4), { size = Vector3.new(0.12, 0.12, 2), speed = 10 })
	if I.def.guard then
		ghost(CFrame.lookAt(I.at - I.dir * 2, I.at), I.pal.core, 0.8, 0.4)
	end
	sound(LUNGE, I.at, 0.4, 1.6)
end
SHAPES.motes = function(d, I)
	local list = if d.healed and #d.healed > 0 then d.healed else { d.at }
	for i, hp in list do
		if i <= 6 then
			local p = v3(hp)
			flash(p + Vector3.new(0, 1, 0), I.pal.glow, 3 + I.tier, 0.45, i <= 2)
			motes(p, I.pal.glow, many(I, 14))
			ring(I.ground(p), 0.5, 3, I.pal.core, 0.5, 8, 0.2)
			if i <= 2 then
				flourish(I, p, 0.5)
			end
		end
	end
	ring(I.ground(I.at), 1, I.radius, I.pal.glow, 0.6, many(I, 10))
	if (I.def.mult or 0) > 0 then
		hitAll(I, I.targets, 0.5)
	end
	sound(PING, I.at, 0.5, 1.3)
end
SHAPES.renew = function(d, I)
	local list = if d.healed and #d.healed > 0 then d.healed else { d.at }
	for i, hp in list do
		if i <= 6 then
			local p = v3(hp)
			orbit(function()
				return p
			end, many(I, 3), 1.6, 3.5, I.pal.glow, math.min(I.duration, 4), { size = Vector3.one * 0.35, speed = 4, rise = 2 })
		end
	end
	local steps = math.min(6, math.floor(I.duration))
	for k = 0, steps - 1 do
		task.delay(k, function()
			motes(I.caster(), I.pal.glow, many(I, 6))
		end)
	end
	if I.def.element == "water" then
		areaEmitter(I.ground(I.at) + Vector3.new(0, 18, 0), Vector3.new(I.radius * 1.4, 1, I.radius * 1.4), { color = I.pal.glow, size = 0.35, life = { 1, 1.4 }, speed = { 14, 18 }, rate = 30, spread = 5, dirn = Enum.NormalId.Bottom }, I.duration)
	end
	ring(I.ground(I.at), 1, I.radius, I.pal.core, 0.7, many(I, 10))
	sound(PING, I.at, 0.5, 1.1)
end
SHAPES.cleanse = function(d, I)
	local g = I.ground(I.at)
	disc(g, I.radius, WHITE, 0.6, 0.2)
	ring(g, 1, I.radius, I.pal.glow, 0.6, many(I, 12), 0.8)
	for i, hp in d.healed or {} do
		if i <= 6 then
			local p = v3(hp)
			pillar(I.ground(p), 1.4, 10, I.pal.glow, 0.6)
			flourish(I, p, 0.5)
		end
	end
	flash(I.at, WHITE, 6, 0.4)
	sound(PING, I.at, 0.6, 1.7)
end
SHAPES.taunt = function(d, I)
	tauntWave(I, I.at, I.radius)
	disc(I.ground(I.at), I.radius * 0.4, I.pal.core, 0.5, 0.3)
	flourish(I, I.at, 0.8)
	for i, a in d.allies or {} do
		if i <= 6 then
			bubble(v3(a), 6, I.pal.glow, 1)
		end
	end
	shake(I.at, 0.6 + I.tier * 0.25, 60)
	landSound(I, I.at, 0.9)
end
SHAPES.curse = function(_d, I)
	local c = I.ground(if I.def.center == "self" then I.at else I.to)
	local r = I.radius
	local exposed = I.def.expose ~= nil
	local color = if exposed then Color3.fromRGB(255, 90, 70) else I.pal.dark:Lerp(Color3.fromRGB(120, 60, 200), 0.5)
	rune(c, r, color, math.min(I.duration, 4), many(I, 10))
	rune(c, r * 0.5, I.pal.core, math.min(I.duration, 4), 6)
	for i, t in I.targets do
		if i <= 6 then
			local mark = part({ Size = Vector3.new(1.4, 1.4, 0.2), CFrame = CFrame.new(t + Vector3.new(0, 4, 0)) * CFrame.Angles(0, 0, math.rad(45)), Color = color, Transparency = 0.1 }, math.min(I.duration, 4) + 0.6)
			tween(mark, 0.6, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, math.min(I.duration, 4))
			flourish(I, t, 0.4)
		end
	end
	burst(c + Vector3.new(0, 1, 0), { tex = langOf(I).tex, color = color, light = 0.4, size = NumberSequence.new(1.5, 0), life = { 0.6, 1 }, speed = { 2, 5 }, accel = Vector3.new(0, -2, 0) }, many(I, 14))
	sound(PING, c, 0.5, 0.5)
end
SHAPES.construct = function(d, I)
	local key = tostring(d.player) .. ":" .. d.ability
	local old = constructs[key]
	if old then
		dissolve(old, I)
	end
	local style = d.style or (I.def.construct and I.def.construct.style) or "knight"
	flourish(I, I.to + Vector3.new(0, 1, 0), 1)
	buildConstruct(key, style, I.to, I, I.duration)
	if I.tier >= 5 then
		shake(I.to, 1.2, 70)
	end
	landSound(I, I.to, 0.8)
end

-- a cast gathering: a circle at the caster's feet in the element, rising light, for the cast time
function SkillFx.cast(d: any)
	if type(d) ~= "table" or not ctx.root then
		return
	end
	local ok, err = pcall(function()
		local I = info(d)
		local t = math.clamp(tonumber(d.cast) or 0.3, 0.05, 2)
		local g = I.ground(I.at)
		rune(g, 2.5 + I.tier * 0.6, I.pal.glow, t, many(I, 8))
		local holder = part({ Size = Vector3.new(3, 0.5, 3), CFrame = CFrame.new(g + Vector3.new(0, 0.3, 0)), Transparency = 1 }, t + 1)
		local pe = emitter(holder, { tex = langOf(I).tex, color = I.pal.glow, size = NumberSequence.new(0.6, 0), life = { 0.4, 0.7 }, speed = { 3, 6 }, rate = 30 + I.tier * 8, spread = 15, accel = Vector3.new(0, 4, 0) })
		light(holder, I.pal.glow, 10 + I.tier * 2, 2)
		task.delay(t, function()
			pe.Enabled = false
		end)
	end)
	if not ok then
		warn("[SkillFx] cast " .. tostring(d.ability) .. ": " .. tostring(err))
	end
end

-- ── playing them ──
-- does a move have an effect (its own, or its shape's)
function SkillFx.has(id: string): boolean
	local ab = Abilities.byId[id]
	return E[id] ~= nil or (ab ~= nil and ((ab.fx ~= nil and E[ab.fx] ~= nil) or SHAPES[ab.shape] ~= nil))
end
function SkillFx.play(d: any): boolean
	if type(d) ~= "table" or type(d.ability) ~= "string" or not ctx.root then
		return false
	end
	local ab = Abilities.byId[d.ability]
	-- a signature move's own effect, or its shape drawn in its element
	local draw = (ab and ab.fx and E[ab.fx]) or E[d.ability] or (ab and SHAPES[ab.shape]) or (type(d.shape) == "string" and SHAPES[d.shape])
	if not draw then
		return false
	end
	local ok, err = pcall(draw, d, info(d))
	if not ok then
		warn("[SkillFx] " .. d.ability .. ": " .. tostring(err))
	end
	return ok
end
-- a construct moved or struck, or a storm's bolts fell
function SkillFx.tick(d: any)
	if type(d) ~= "table" or type(d.ability) ~= "string" or not ctx.root then
		return
	end
	local ok, err = pcall(function()
		local I = info(d)
		if I.def.shape == "storm" then
			for i, t in I.targets do
				if i <= 3 then
					if d.ability == "thunderstorm" then
						strikeFromSky(I, t, 0.7)
					else
						SkillFx.stormBolt(I, t)
					end
				end
			end
			if #I.targets > 0 then
				sound(THUD, I.at, 0.5, 1.2)
			end
			return
		end
		local key = tostring(d.player) .. ":" .. d.ability
		local h = constructs[key]
		if not h then
			return
		end
		if d.done then
			constructs[key] = nil
			dissolve(h, I)
			return
		end
		if d.at then
			moveConstruct(h, v3(d.at))
		end
		if d.hit and d.to then
			local target = v3(d.to)
			h.swing = 1
			task.delay(0.25, function()
				h.swing = 0
			end)
			if h.style == "hawk" then
				-- the hawk dives
				local sky = h.root().Position
				zigzag(sky, target, I.pal.glow, 0.25, 0.25, 4, 0.4)
				slash(target + Vector3.new(-1.5, 1.5, 0), target + Vector3.new(1.5, -1, 0), I.pal.glow, 0.4, 0.25)
			else
				local from = h.root().Position + Vector3.new(0, 1, 0)
				slash(from + I.dir * 2, target, I.pal.glow, 0.7, 0.25, 30)
				if h.style == "golem" then
					disc(I.ground(target), 6, I.pal.glow, 0.35, 0.3)
					chunks(I.ground(target), 4, I.pal.dark, STONE, 5, 0.8)
				end
			end
			flash(target, I.pal.glow, 5, 0.3, false)
			burst(target, { tex = SPARKS, color = I.pal.glow, size = 0.4, life = { 0.2, 0.4 }, speed = { 8, 16 } }, 8)
			sound(SLASH, target, 0.5, if h.style == "golem" then 0.6 else 1.1)
		end
	end)
	if not ok then
		warn("[SkillFx] tick " .. d.ability .. ": " .. tostring(err))
	end
end

return SkillFx
