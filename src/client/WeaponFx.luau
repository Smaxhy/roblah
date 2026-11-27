--[[
	WEAPON EFFECTS, CLIENT SIDE (BitLeveling): what a weapon does when it swings, hits and comes
	out, drawn for its family and coloured by its element. The weapon itself (and its ambient
	particles, light and its swing Trail) is built by Hunter/WeaponModels on the rig, which also
	stamps the rig with attributes this module reads:
		WeaponBase, WeaponFamily, WeaponElement, WeaponStars, WeaponShiny, WeaponClass,
		WeaponGrade, WeaponStyle

	API
		WeaponFx.swing(model: Model, opts: SwingOpts?)
			Turns the weapon's Trail(s) ("WeaponTrail") on for the swing, and draws the swing
			for the family's style (Weapons.FAMILIES[f].fx, stamped as WeaponStyle):
				slash   blades, axes, scythes, glaives: a crescent arc
				smash   hammers, maces, flails, greataxes: a shockwave ring, cracks, dust
				thrust  spears, tridents, lances, rapiers, sai: a straight streak and a ring
				shot    bows, longbows, crossbows, arbalests: a projectile streak (a bolt)
				throw   javelins, throwing knives, chakrams: thrown projectiles
				spell   staves, wands, foci, grimoires, tablets: a rune circle and a bolt
				gust    war fans: a fan of wind streaks
				heal    lanterns, thuribles, bells, rods, scepters, crescents: a halo and motes
				punch   gauntlets, claws, katars: a shock ring (claw marks for claws/katars)
				lash    whips, chain-blades, kusarigama: a lash snaking out
				bash    shields: a wall of light pushed forward
			opts (all optional):
				direction: Vector3   where the swing goes (default: the rig's facing)
				origin: Vector3      where it starts (default: the rig's root)
				target: Vector3      a point to aim at (shots, throws and spells fly to it)
				reach: number        how far it reaches (default: the style's own)
				power: number        the weapon's power (Weapons.power): bigger and brighter
				duration: number     how long the trail stays on (default: the style's own)
				parent: Instance     where the effect parts go (default: Workspace.WeaponFx)
		WeaponFx.hit(position: Vector3, element: string?, power: number?, opts: { parent: Instance? }?)
			An impact burst for the element: fire (a fireball and embers), frost (ice shards and
			mist), lightning (bolts from above), venom (a splash and bubbles), void (an implosion),
			holy (a pillar of light), wind (a swirl), earth (rocks and dust), none (sparks).
		WeaponFx.equip(model: Model, opts: { parent: Instance? }?)
			A short flash over the weapon when it appears, a ring at the hand, a burst.
		Sounds (client/WorldSfx, where it happens): swing plays the family's own swing (a blade's
		swish, a greataxe's heavy whoosh, a bow's draw and release, a whip's crack...), hit plays
		the element's impact (and the family's blow when opts.family is given), equip the draw.
		opts.sound = false keeps any of them quiet.
		WeaponFx.familyOf(model): string?      WeaponFx.elementOf(model): string ("none" if unset)
		WeaponFx.styleOf(model): string        WeaponFx.colorOf(element, shade?): Color3
		WeaponFx.trails(model): { Trail }      WeaponFx.STYLES: { string }
		WeaponFx.parent                        set to put every effect under one Instance
	Everything is client-only: anchored (or welded to the weapon), non-colliding, non-querying
	parts, faded with TweenService and removed with Debris. Swing effects cost 10 to 30 parts.
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponFx = {}
WeaponFx.parent = nil :: Instance?
WeaponFx.STYLES = { "slash", "smash", "thrust", "shot", "throw", "spell", "gust", "heal", "punch", "lash", "bash" }

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local FIRE_TEX = "rbxasset://textures/particles/fire_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local R90 = math.rad(90)
local GOLD = Color3.fromRGB(255, 214, 110)

-- the element palette comes from Hunter/Weapons (loaded on first use); this is its fallback
local FALLBACK = {
	none = { { 120, 175, 255 }, { 60, 110, 220 }, { 220, 236, 255 } },
	fire = { { 255, 120, 40 }, { 200, 40, 20 }, { 255, 220, 130 } },
	frost = { { 150, 220, 255 }, { 70, 140, 230 }, { 235, 250, 255 } },
	lightning = { { 255, 232, 90 }, { 120, 150, 255 }, { 255, 255, 230 } },
	venom = { { 120, 230, 80 }, { 40, 130, 50 }, { 210, 255, 170 } },
	void = { { 150, 80, 240 }, { 40, 10, 80 }, { 220, 190, 255 } },
	holy = { { 255, 236, 170 }, { 255, 190, 90 }, { 255, 252, 235 } },
	wind = { { 150, 255, 200 }, { 60, 190, 150 }, { 230, 255, 245 } },
	earth = { { 214, 160, 80 }, { 120, 80, 40 }, { 255, 220, 160 } },
}
local FALLBACK_STYLE = {
	sword = "slash", katana = "slash", odachi = "slash", twinswords = "slash", greatsword = "slash", cleaver = "slash", scythe = "slash",
	axe = "slash", axes = "slash", halberd = "slash", glaive = "slash", dagger = "slash", daggers = "slash",
	greataxe = "smash", warhammer = "smash", hammer = "smash", mace = "smash", flail = "smash",
	spear = "thrust", trident = "thrust", lance = "thrust", rapier = "thrust", sai = "thrust",
	bow = "shot", longbow = "shot", crossbow = "shot", arbalest = "shot",
	javelin = "throw", kunai = "throw", chakram = "throw",
	staff = "spell", wand = "spell", orb = "spell", crystal = "spell", tome = "spell", codex = "spell", tablet = "spell",
	warfan = "gust", censer = "heal", thurible = "heal", bell = "heal", rod = "heal", scepter = "heal", crescent = "heal",
	gauntlets = "punch", claws = "punch", katar = "punch", whip = "lash", chainblade = "lash", kusarigama = "lash",
	shield = "bash", buckler = "bash", towershield = "bash",
}

-- (sounds) client/WorldSfx, loaded on first use; quiet if it isn't there
local worldSfxModule: any = nil
local function sfx(fn: string, ...: any)
	if worldSfxModule == nil then
		worldSfxModule = false
		pcall(function()
			local m = (script :: any).Parent:FindFirstChild("WorldSfx")
			if m then
				worldSfxModule = require(m :: any)
			end
		end)
	end
	if worldSfxModule then
		pcall(worldSfxModule[fn], ...)
	end
end

local weaponsModule: any = nil
local function weapons(): any?
	if weaponsModule == nil then
		local ok, mod = pcall(function()
			local shared = ReplicatedStorage:WaitForChild("LifeSim", 5)
			local hunter = shared and shared:WaitForChild("Hunter", 5)
			local m = hunter and hunter:WaitForChild("Weapons", 5)
			return if m then require(m :: any) else nil
		end)
		weaponsModule = if ok and type(mod) == "table" then mod else false
	end
	return if weaponsModule then weaponsModule else nil
end

-- one-shot particles (guarded: an emitter that can't emit, offline or half-built, is skipped)
local function emit(pe: ParticleEmitter, n: number)
	pcall(function()
		pe:Emit(math.max(1, math.floor(n)))
	end)
end

local function rgb(t: { number }): Color3
	return Color3.fromRGB(t[1], t[2], t[3])
end

-- an element's colours: color (the glow), deep, light
local function palette(element: string?): { color: Color3, deep: Color3, light: Color3 }
	local key = element or "none"
	local W = weapons()
	local e = W and W.ELEMENTS and W.ELEMENTS[key]
	if e then
		return { color = rgb(e.color), deep = rgb(e.deep), light = rgb(e.light) }
	end
	local f = FALLBACK[key] or FALLBACK.none
	return { color = rgb(f[1]), deep = rgb(f[2]), light = rgb(f[3]) }
end

function WeaponFx.colorOf(element: string?, shade: string?): Color3
	local p: any = palette(element)
	return p[shade or "color"] or p.color
end

function WeaponFx.familyOf(model: Instance): string?
	local f = model:GetAttribute("WeaponFamily")
	return if type(f) == "string" then f else nil
end

function WeaponFx.elementOf(model: Instance): string
	local e = model:GetAttribute("WeaponElement")
	return if type(e) == "string" and FALLBACK[e] then e else "none"
end

function WeaponFx.styleOf(model: Instance): string
	local s = model:GetAttribute("WeaponStyle")
	if type(s) == "string" and table.find(WeaponFx.STYLES, s) then
		return s
	end
	local fam = WeaponFx.familyOf(model)
	local W = weapons()
	local def = fam and W and W.FAMILIES and W.FAMILIES[fam]
	if def and def.fx then
		return def.fx
	end
	return (fam and FALLBACK_STYLE[fam]) or "slash"
end

function WeaponFx.trails(model: Instance): { Trail }
	local out = {}
	for _, d in model:GetDescendants() do
		if d:IsA("Trail") and d.Name == "WeaponTrail" then
			table.insert(out, d)
		end
	end
	return out
end

-- ── helpers ────────────────────────────────────────────────────────────────
local function folder(opts: any?): Instance
	local p = (opts and opts.parent) or WeaponFx.parent
	if p then
		return p
	end
	local f = Workspace:FindFirstChild("WeaponFx")
	if not f then
		f = Instance.new("Folder")
		f.Name = "WeaponFx"
		f.Parent = Workspace
	end
	return f :: Instance
end

-- a CFrame at `from` whose -Z looks at `to`
local function aim(from: Vector3, to: Vector3): CFrame
	local d = to - from
	if d.Magnitude < 1e-4 then
		return CFrame.new(from)
	end
	local look = d.Unit
	local up = if math.abs(look.Y) > 0.99 then Vector3.new(1, 0, 0) else Vector3.new(0, 1, 0)
	local right = look:Cross(up).Unit
	local up2 = right:Cross(look)
	return CFrame.new(from.X, from.Y, from.Z, right.X, up2.X, -look.X, right.Y, up2.Y, -look.Y, right.Z, up2.Z, -look.Z)
end

local function part(parent: Instance, size: Vector3, cf: CFrame, color: Color3, transparency: number?, shape: Enum.PartType?, material: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Neon
	p.Transparency = transparency or 0
	p.Name = "Fx"
	p.Parent = parent
	return p
end

local function tween(inst: Instance, t: number, goals: any, delay: number?, style: Enum.EasingStyle?)
	local tw = TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay or 0), goals)
	tw:Play()
	return tw
end

-- fade a part out (growing or shrinking to `size`), then remove it
local function fade(p: BasePart, t: number, size: Vector3?, delay: number?, cf: CFrame?)
	local goals: any = { Transparency = 1 }
	if size then
		goals.Size = size
	end
	if cf then
		goals.CFrame = cf
	end
	tween(p, t, goals, delay)
	Debris:AddItem(p, t + (delay or 0) + 0.15)
end

local function light(p: BasePart, color: Color3, range: number, brightness: number, t: number)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range
	l.Brightness = brightness
	l.Shadows = false
	l.Parent = p
	tween(l, t, { Brightness = 0 })
end

local function scaleOf(power: number?): number
	return math.clamp(0.85 + (power or 3) / 20, 0.85, 2.6)
end

-- one-shot particles at a point, in the element's manner
local BURST = {
	fire = { tex = FIRE_TEX, speed = { 4, 9 }, life = { 0.3, 0.7 }, size = 0.9, accel = Vector3.new(0, 6, 0), drag = 3 },
	frost = { tex = SPARKLE, speed = { 3, 7 }, life = { 0.4, 0.8 }, size = 0.5, accel = Vector3.new(0, -6, 0), drag = 2 },
	lightning = { tex = SPARKLE, speed = { 10, 20 }, life = { 0.1, 0.25 }, size = 0.4, streak = true },
	venom = { tex = SPARKLE, speed = { 3, 6 }, life = { 0.5, 0.9 }, size = 0.45, accel = Vector3.new(0, -14, 0) },
	void = { tex = SPARKLE, speed = { -6, -3 }, life = { 0.4, 0.7 }, size = 0.6 },
	holy = { tex = SPARKLE, speed = { 2, 5 }, life = { 0.6, 1.1 }, size = 0.6, accel = Vector3.new(0, 5, 0), drag = 2 },
	wind = { tex = SPARKLE, speed = { 8, 14 }, life = { 0.2, 0.4 }, size = 0.3, streak = true, drag = 4 },
	earth = { tex = SMOKE, speed = { 2, 5 }, life = { 0.6, 1.2 }, size = 1.4, accel = Vector3.new(0, -3, 0), drag = 3, dusty = true },
	none = { tex = SPARKLE, speed = { 5, 10 }, life = { 0.15, 0.35 }, size = 0.4, streak = true },
}
local function burst(parent: Instance, at: Vector3, element: string?, n: number, scale: number, color: Color3?)
	local b = BURST[element or "none"] or BURST.none
	local pal = palette(element)
	local p = part(parent, Vector3.new(0.2, 0.2, 0.2), CFrame.new(at), pal.color, 1)
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = b.tex
	pe.Color = ColorSequence.new(color or pal.light, pal.color)
	pe.LightEmission = if b.dusty then 0 else 1
	pe.LightInfluence = if b.dusty then 1 else 0
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(b.life[1], b.life[2])
	pe.Speed = NumberRange.new(b.speed[1] * scale, b.speed[2] * scale)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Size = NumberSequence.new(b.size * scale, 0)
	pe.Transparency = NumberSequence.new(if b.dusty then 0.4 else 0, 1)
	pe.Acceleration = b.accel or Vector3.zero
	pe.Drag = b.drag or 0
	pe.Rotation = NumberRange.new(0, 360)
	pe.RotSpeed = NumberRange.new(-120, 120)
	if b.streak then
		pe.Orientation = Enum.ParticleOrientation.VelocityParallel
	end
	pe.Parent = p
	emit(pe, n)
	Debris:AddItem(p, b.life[2] + 0.3)
end

-- a ball of light that swells and fades
local function flash(parent: Instance, at: Vector3, color: Color3, size: number, t: number, glow: number?)
	local p = part(parent, Vector3.one * size * 0.35, CFrame.new(at), color, 0.1, Enum.PartType.Ball)
	if glow then
		light(p, color, size * 3, glow, t)
	end
	fade(p, t, Vector3.one * size)
end

-- a ring of short bars in `cf`'s X-Z plane (around its Y axis) growing from r0 to r1
local function hoop(parent: Instance, cf: CFrame, r0: number, r1: number, n: number, thick: number, color: Color3, t: number, transparency: number?)
	for k = 0, n - 1 do
		local a = k / n * math.pi * 2
		local seg0, seg1 = 2 * math.pi * r0 / n * 1.1, 2 * math.pi * r1 / n * 1.1
		local p = part(parent, Vector3.new(seg0, thick, thick), cf * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -r0), color, transparency or 0.1)
		fade(p, t, Vector3.new(seg1, thick * 0.4, thick * 0.4), nil, cf * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -r1))
	end
end

-- a flat disc in `cf`'s X-Z plane, growing from d0 to d1 across
local function disc(parent: Instance, cf: CFrame, d0: number, d1: number, color: Color3, t: number, transparency: number?)
	local p = part(parent, Vector3.new(0.12, d0, d0), cf * CFrame.Angles(0, 0, R90), color, transparency or 0.3, Enum.PartType.Cylinder)
	fade(p, t, Vector3.new(0.04, d1, d1))
end

-- a straight streak of light from a to b
local function streak(parent: Instance, a: Vector3, b: Vector3, width: number, color: Color3, t: number, transparency: number?, delay: number?): BasePart?
	local len = (b - a).Magnitude
	if len < 0.05 then
		return nil
	end
	local cf = aim((a + b) / 2, b)
	local p = part(parent, Vector3.new(width, width, len), cf, color, transparency or 0.1)
	fade(p, t, Vector3.new(width * 0.2, width * 0.2, len * 1.1), delay)
	return p
end

-- ── where the rig and its weapon are ───────────────────────────────────────
local function rootOf(model: Instance): CFrame
	local r = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
	if r and r:IsA("BasePart") then
		return r.CFrame
	end
	if model:IsA("Model") and model.PrimaryPart then
		return model.PrimaryPart.CFrame
	end
	return CFrame.new()
end
local function attachmentPos(a: Attachment): Vector3
	local p = a.Parent
	if p and p:IsA("BasePart") then
		return (p.CFrame * a.CFrame).Position
	end
	return Vector3.zero
end
-- the tip of the weapon (TrailTop), the base (TrailBottom), and where it glows (its aura)
local function weaponPoints(model: Instance): (Vector3?, Vector3?, Vector3?)
	local tip, base, focus
	for _, d in model:GetDescendants() do
		if d:IsA("Attachment") then
			if d.Name == "TrailTop" and not tip then
				tip = attachmentPos(d)
			elseif d.Name == "TrailBottom" and not base then
				base = attachmentPos(d)
			end
		elseif d:IsA("ParticleEmitter") and d.Name == "WeaponAura" and not focus then
			local p = d.Parent
			if p and p:IsA("BasePart") then
				focus = p.CFrame.Position
			end
		end
	end
	return tip, base, focus or tip
end

local function trailsOn(model: Instance, duration: number)
	local list = WeaponFx.trails(model)
	if #list == 0 then
		return
	end
	local n = ((model:GetAttribute("WeaponFxSwing") or 0) :: number) + 1
	model:SetAttribute("WeaponFxSwing", n)
	for _, t in list do
		t.Enabled = true
	end
	task.delay(duration, function()
		if model:GetAttribute("WeaponFxSwing") == n then
			for _, t in list do
				t.Enabled = false
			end
		end
	end)
end

-- ── the styles ─────────────────────────────────────────────────────────────
-- s: { parent, root (CFrame), origin, dir, right, up, target, reach, scale, element, pal,
--      stars, shiny, family, tip, base, focus }
local STYLE = {}

-- a crescent arc across the front, tilted a little, sweeping from one side to the other
STYLE.slash = function(s)
	local center = s.origin + s.up * 0.6
	local basis = aim(center, center + s.dir) * CFrame.Angles(0, 0, math.rad(if math.random() < 0.5 then -28 else 28))
	local r = s.reach
	local n = 8
	local span = 150
	local width = (0.32 + 0.08 * s.stars) * s.scale
	for k = 0, n - 1 do
		local t = (k + 0.5) / n
		local a = math.rad(-span / 2 + span * t)
		local fat = math.sin(t * math.pi)
		local seg = 2 * r * math.sin(math.rad(span / n) / 2) * 1.15
		local cf = basis * CFrame.Angles(0, -a, 0) * CFrame.new(0, 0, -r)
		local core = part(s.parent, Vector3.new(seg, 0.08, width * (0.25 + 0.75 * fat)), cf, s.pal.light, 0.05)
		fade(core, 0.22, Vector3.new(seg, 0.02, width * 0.15), k * 0.012)
		local glow = part(s.parent, Vector3.new(seg * 1.05, 0.06, width * (0.4 + 0.9 * fat)), cf * CFrame.new(0, 0, -width * 0.2), if s.shiny and k % 2 == 0 then GOLD else s.pal.color, 0.5)
		fade(glow, 0.3, Vector3.new(seg * 1.05, 0.02, width * 1.6), k * 0.012)
	end
	local tipAt = (basis * CFrame.Angles(0, -math.rad(span / 2), 0) * CFrame.new(0, 0, -r)).Position
	burst(s.parent, tipAt, s.element, 6 + s.stars * 3, s.scale * 0.8)
end

-- a shockwave on the ground in front: a ring, a flash, cracks, dust
STYLE.smash = function(s)
	local ground = s.root.Position.Y - 2.9
	local at = s.origin + s.dir * s.reach * 0.75
	local spot = Vector3.new(at.X, ground + 0.1, at.Z)
	local base = CFrame.new(spot)
	hoop(s.parent, base, 0.8, (3.5 + s.stars) * s.scale, 12, 0.3, s.pal.color, 0.45)
	disc(s.parent, base, 1, 4.5 * s.scale, s.pal.light, 0.35, 0.2)
	flash(s.parent, spot + Vector3.new(0, 0.6, 0), s.pal.light, 2.4 * s.scale, 0.3, 4)
	for k = 0, 4 do
		local a = k / 5 * math.pi * 2 + math.random() * 0.6
		local len = (1.6 + math.random() * 1.6) * s.scale
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		local c = part(s.parent, Vector3.new(0.18, 0.06, len), aim(spot + dir * len / 2, spot + dir * len), s.pal.deep:Lerp(Color3.new(0, 0, 0), 0.5), 0)
		fade(c, 1.1, nil, 0.4)
	end
	burst(s.parent, spot, "earth", 10 * s.scale, s.scale)
	burst(s.parent, spot + Vector3.new(0, 0.5, 0), s.element, 8 + s.stars * 4, s.scale)
	if s.element == "earth" then
		for k = 0, 4 do
			local a = k / 5 * math.pi * 2
			local rock = part(s.parent, Vector3.one * (0.35 + math.random() * 0.3) * s.scale, CFrame.new(spot) * CFrame.Angles(a, a * 2, 0), Color3.fromRGB(110, 96, 80), 0, nil, Enum.Material.Slate)
			fade(rock, 0.7, nil, 0.1, CFrame.new(spot + Vector3.new(math.cos(a) * 2.5, 2 + math.random() * 1.5, math.sin(a) * 2.5) * s.scale) * CFrame.Angles(a * 3, a, a))
		end
	end
end

-- a straight streak out of the point and a ring where it ends
STYLE.thrust = function(s)
	local from = s.origin + s.up * 0.4 + s.dir * 1.6
	local to = from + s.dir * s.reach
	streak(s.parent, from, to, 0.16 * s.scale, s.pal.light, 0.22, 0.05)
	streak(s.parent, from, to + s.dir * 0.8, 0.42 * s.scale, s.pal.color, 0.28, 0.6)
	for _, off in { s.right * 0.5 + s.up * 0.3, -s.right * 0.45 - s.up * 0.25 } do
		streak(s.parent, from + off * s.scale, to + off * s.scale - s.dir * 1.5, 0.08, s.pal.color, 0.2, 0.3, 0.03)
	end
	local ring = part(s.parent, Vector3.new(0.1, 0.6, 0.6), aim(to, to + s.dir) * CFrame.Angles(0, R90, 0), s.pal.color, 0.2, Enum.PartType.Cylinder)
	fade(ring, 0.3, Vector3.new(0.04, 2.6 * s.scale, 2.6 * s.scale))
	burst(s.parent, to, s.element, 6 + s.stars * 3, s.scale)
end

-- a projectile from the weapon to the target: a bolt with a trail, a burst where it lands
local function projectile(s, from: Vector3, to: Vector3, size: Vector3, speed: number, spin: boolean?, shape: Enum.PartType?)
	local cf = aim(from, to)
	local bolt = part(s.parent, size, cf, s.pal.light, 0, shape)
	local a0 = Instance.new("Attachment")
	a0.CFrame = CFrame.new(0, size.Y * 0.5, size.Z * 0.5)
	a0.Parent = bolt
	local a1 = Instance.new("Attachment")
	a1.CFrame = CFrame.new(0, -size.Y * 0.5, size.Z * 0.5)
	a1.Parent = bolt
	local tr = Instance.new("Trail")
	tr.Attachment0 = a0
	tr.Attachment1 = a1
	tr.Lifetime = 0.18 + s.stars * 0.04
	tr.LightEmission = 1
	tr.LightInfluence = 0
	tr.FaceCamera = true
	tr.MinLength = 0.05
	tr.Color = ColorSequence.new(if s.shiny then GOLD else s.pal.light, s.pal.color)
	tr.Transparency = NumberSequence.new(0.1, 1)
	tr.WidthScale = NumberSequence.new(1, 0)
	tr.Parent = bolt
	light(bolt, s.pal.color, 6, 1.5 + s.stars * 0.3, 0.6)
	if s.element ~= "none" then
		local pe = Instance.new("ParticleEmitter")
		local b = BURST[s.element] or BURST.none
		pe.Texture = b.tex
		pe.Color = ColorSequence.new(s.pal.light, s.pal.color)
		pe.LightEmission = 1
		pe.Rate = 30 + s.stars * 15
		pe.Lifetime = NumberRange.new(0.15, 0.3)
		pe.Speed = NumberRange.new(0, 0.5)
		pe.Size = NumberSequence.new(0.3 * s.scale, 0)
		pe.Parent = bolt
	end
	local dist = (to - from).Magnitude
	local t = math.clamp(dist / speed, 0.08, 0.6)
	local endCf = aim(to - (to - from).Unit * 0.01, to)
	if spin then
		endCf = endCf * CFrame.Angles(0, 0, math.pi * 0.95)
	end
	tween(bolt, t, { CFrame = CFrame.new(to) * (endCf - endCf.Position) }, nil, Enum.EasingStyle.Linear)
	Debris:AddItem(bolt, t + 0.4)
	task.delay(t, function()
		burst(s.parent, to, s.element, 6 + s.stars * 2, s.scale * 0.8)
	end)
end

STYLE.shot = function(s)
	local from = s.focus or s.tip or (s.origin + s.dir * 1.5 + s.up * 0.5)
	local to = s.target or (from + s.dir * s.reach)
	local big = s.family == "arbalest" or s.family == "longbow"
	projectile(s, from, to, Vector3.new(0.12, 0.12, if big then 2.2 else 1.5) * s.scale, if big then 220 else 170)
	local ring = part(s.parent, Vector3.new(0.08, 0.5, 0.5), aim(from, from + s.dir) * CFrame.Angles(0, R90, 0), s.pal.color, 0.2, Enum.PartType.Cylinder)
	fade(ring, 0.25, Vector3.new(0.03, 2 * s.scale, 2 * s.scale))
end

STYLE.throw = function(s)
	local from = (s.tip or s.origin) + s.up * 0.4
	local to = s.target or (s.origin + s.dir * s.reach)
	if s.family == "javelin" then
		from = s.origin + s.up * 1.6 + s.right * 0.8
	end
	if s.family == "kunai" then
		for k = -1, 1 do
			local side = s.right * k * 1.2
			projectile(s, from, to + side, Vector3.new(0.1, 0.25, 0.7) * s.scale, 150, true)
		end
	elseif s.family == "chakram" then
		projectile(s, from, to, Vector3.new(1.1, 0.1, 1.1) * s.scale, 120, true)
	else
		projectile(s, from, to, Vector3.new(0.14, 0.14, 3) * s.scale, 140)
	end
end

-- a rune circle at the focus and a bolt flying out of it
STYLE.spell = function(s)
	local at = s.focus or (s.origin + s.dir * 1.5 + s.up * 0.5)
	local face = aim(at, at + s.dir)
	local circle = part(s.parent, Vector3.new(0.06, 1.2, 1.2), face * CFrame.Angles(0, R90, 0), s.pal.color, 0.35, Enum.PartType.Cylinder)
	fade(circle, 0.45, Vector3.new(0.02, 3.2 * s.scale, 3.2 * s.scale))
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		local rune = part(s.parent, Vector3.new(0.22, 0.22, 0.05), face * CFrame.Angles(0, 0, a) * CFrame.new(0, 0.9 * s.scale, 0) * CFrame.Angles(0, 0, math.rad(45)), s.pal.light, 0)
		fade(rune, 0.45, nil, 0.05, face * CFrame.Angles(0, 0, a + 0.8) * CFrame.new(0, 1.4 * s.scale, 0) * CFrame.Angles(0, 0, math.rad(45)))
	end
	flash(s.parent, at, s.pal.light, 1.4 * s.scale, 0.25, 3)
	local to = s.target or (at + s.dir * s.reach)
	projectile(s, at + s.dir * 0.6, to, Vector3.one * (0.4 + 0.07 * s.stars) * s.scale, 110, false, Enum.PartType.Ball)
end

-- a fan of wind streaks spreading forward
STYLE.gust = function(s)
	local from = s.origin + s.dir * 1.2 + s.up * 0.4
	for k = -2, 2 do
		local d = (aim(Vector3.zero, s.dir) * CFrame.Angles(0, math.rad(k * 14), 0)).LookVector
		local to = from + d * s.reach
		streak(s.parent, from + d * 0.8, to, 0.18 * s.scale, if k % 2 == 0 then s.pal.light else s.pal.color, 0.35, 0.2, math.abs(k) * 0.03)
	end
	hoop(s.parent, aim(from, from + s.dir) * CFrame.Angles(R90, 0, 0), 0.6, 2.4 * s.scale, 8, 0.12, s.pal.color, 0.35, 0.3)
	burst(s.parent, from + s.dir * s.reach * 0.6, s.element, 10, s.scale)
end

-- a halo at the feet, a soft column of light, motes rising
STYLE.heal = function(s)
	local feet = s.root.Position - Vector3.new(0, 2.8, 0)
	hoop(s.parent, CFrame.new(feet), 1, (4 + s.stars) * s.scale, 12, 0.18, s.pal.color, 0.7, 0.2)
	local column = part(s.parent, Vector3.new(6, 2.2, 2.2), CFrame.new(feet + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, R90), s.pal.light, 0.82, Enum.PartType.Cylinder)
	fade(column, 0.6, Vector3.new(7, 3.4 * s.scale, 3.4 * s.scale))
	local motes = part(s.parent, Vector3.new(4, 0.2, 4), CFrame.new(feet + Vector3.new(0, 0.2, 0)), s.pal.color, 1)
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = SPARKLE
	pe.Color = ColorSequence.new(s.pal.light, s.pal.color)
	pe.LightEmission = 1
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.8, 1.4)
	pe.Speed = NumberRange.new(2, 4)
	pe.SpreadAngle = Vector2.new(15, 15)
	pe.Acceleration = Vector3.new(0, 2, 0)
	pe.Size = NumberSequence.new(0.35, 0)
	pe.EmissionDirection = Enum.NormalId.Top
	pe.Parent = motes
	emit(pe, 10 + s.stars * 5)
	Debris:AddItem(motes, 1.6)
	if s.focus then
		flash(s.parent, s.focus, s.pal.light, 1.6 * s.scale, 0.4, 3)
	end
end

-- a shock ring in front of the fist; claws and katars leave three claw marks
STYLE.punch = function(s)
	local at = (s.tip or (s.origin + s.dir * 2)) + s.dir * 0.6
	local ring = part(s.parent, Vector3.new(0.12, 0.8, 0.8), aim(at, at + s.dir) * CFrame.Angles(0, R90, 0), s.pal.color, 0.2, Enum.PartType.Cylinder)
	fade(ring, 0.25, Vector3.new(0.04, 3 * s.scale, 3 * s.scale))
	flash(s.parent, at, s.pal.light, 1.4 * s.scale, 0.2, 3)
	if s.family == "claws" or s.family == "katar" then
		local face = aim(at, at + s.dir)
		for k = -1, 1 do
			local off = face * CFrame.new(k * 0.45 * s.scale, 0, 0)
			local a = (off * CFrame.new(-0.6, 1.1, 0)).Position
			local b = (off * CFrame.new(0.6, -1.1, 0)).Position
			streak(s.parent, a + s.dir * 0.2, b + s.dir * 0.2, 0.07 * s.scale, s.pal.light, 0.3, 0.05, (k + 1) * 0.02)
		end
	end
	burst(s.parent, at, s.element, 5 + s.stars * 3, s.scale * 0.8)
end

-- a lash snaking out to the reach and back
STYLE.lash = function(s)
	local from = s.tip or (s.origin + s.dir * 1.5)
	local n = 10
	local prev = from
	local amp = 0.9 * s.scale
	for k = 1, n do
		local t = k / n
		local pt = from + s.dir * s.reach * t + s.right * math.sin(t * math.pi * 2) * amp * (1 - t * 0.5) + s.up * math.sin(t * math.pi) * 0.5
		streak(s.parent, prev, pt, (0.22 - t * 0.12) * s.scale, if k % 3 == 0 then s.pal.light else s.pal.color, 0.3, 0.05, t * 0.08)
		prev = pt
	end
	flash(s.parent, prev, s.pal.light, 1.2 * s.scale, 0.2)
	burst(s.parent, prev, s.element, 6 + s.stars * 2, s.scale * 0.8)
end

-- a wall of light pushed forward from the shield
STYLE.bash = function(s)
	local at = s.origin + s.dir * 2 + s.up * 0.2
	local face = aim(at, at + s.dir)
	local wall = part(s.parent, Vector3.new(2.6, 3.2, 0.2) * s.scale, face, s.pal.color, 0.45, nil, Enum.Material.ForceField)
	fade(wall, 0.35, Vector3.new(3.2, 3.8, 0.1) * s.scale, nil, face * CFrame.new(0, 0, -2))
	local ring = part(s.parent, Vector3.new(0.1, 1.5, 1.5), face * CFrame.Angles(0, R90, 0), s.pal.light, 0.2, Enum.PartType.Cylinder)
	fade(ring, 0.3, Vector3.new(0.03, 4.5 * s.scale, 4.5 * s.scale), nil, face * CFrame.new(0, 0, -1.5) * CFrame.Angles(0, R90, 0))
	burst(s.parent, at + s.dir, s.element, 6 + s.stars * 2, s.scale)
end

local REACH = { slash = 3.4, smash = 3, thrust = 7, shot = 60, throw = 45, spell = 45, gust = 12, heal = 0, punch = 2.5, lash = 9, bash = 2.5 }
local DURATION = { slash = 0.3, smash = 0.35, thrust = 0.25, shot = 0.2, throw = 0.25, spell = 0.3, gust = 0.35, heal = 0.4, punch = 0.2, lash = 0.4, bash = 0.25 }

function WeaponFx.swing(model: Model, opts: any?)
	opts = opts or {}
	local style = WeaponFx.styleOf(model)
	local element = WeaponFx.elementOf(model)
	local root = rootOf(model)
	local origin = opts.origin or root.Position
	local dir = opts.direction
	if not dir and opts.target then
		dir = opts.target - origin
	end
	if not dir or dir.Magnitude < 1e-3 then
		dir = root.LookVector
	end
	dir = dir.Unit
	local right = dir:Cross(Vector3.yAxis)
	right = if right.Magnitude > 1e-3 then right.Unit else Vector3.xAxis
	local up = right:Cross(dir).Unit
	local stars = (model:GetAttribute("WeaponStars") or 1) :: number
	local shiny = model:GetAttribute("WeaponShiny") == true
	local tip, base, focus = weaponPoints(model)
	local pal = palette(element)
	local reach = opts.reach or REACH[style] or 4
	if not opts.reach and style == "slash" and tip then
		-- a slash reaches as far as the blade does
		reach = math.clamp((tip - root.Position).Magnitude, 2.4, 5.5)
	end
	trailsOn(model, opts.duration or DURATION[style] or 0.3)
	local s = {
		parent = folder(opts),
		root = root,
		origin = origin,
		dir = dir,
		right = right,
		up = up,
		target = opts.target,
		reach = reach,
		scale = scaleOf(opts.power),
		element = element,
		pal = pal,
		stars = math.clamp(stars, 1, 3),
		shiny = shiny,
		family = WeaponFx.familyOf(model),
		tip = tip,
		base = base,
		focus = focus,
	}
	local draw = STYLE[style] or STYLE.slash
	draw(s)
	if opts.sound ~= false then
		sfx("weapon", s.family, "swing", origin, { power = opts.power, stars = s.stars, style = style })
	end
end

-- ── impacts ────────────────────────────────────────────────────────────────
local HIT = {}
HIT.fire = function(parent, at, pal, k)
	flash(parent, at, pal.color, 3 * k, 0.35, 5)
	flash(parent, at, pal.light, 1.6 * k, 0.2)
	for i = 0, 4 do
		local a = i / 5 * math.pi * 2
		local p = part(parent, Vector3.one * 0.4 * k, CFrame.new(at), pal.color, 0, Enum.PartType.Ball)
		fade(p, 0.5, Vector3.one * 0.1, nil, CFrame.new(at + Vector3.new(math.cos(a) * 2, 1.5 + math.random(), math.sin(a) * 2) * k))
	end
end
HIT.frost = function(parent, at, pal, k)
	flash(parent, at, pal.light, 2.2 * k, 0.3, 3)
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		local d = Vector3.new(math.cos(a), 0.6 + (i % 2) * 0.5, math.sin(a)).Unit
		local shard = part(parent, Vector3.new(0.25, 0.25, 1.1) * k, aim(at, at + d), pal.light, 0.1, nil, Enum.Material.Ice)
		fade(shard, 0.6, Vector3.new(0.1, 0.1, 1.4) * k, 0.1, aim(at + d * 1.6 * k, at + d * 3 * k))
	end
	disc(parent, CFrame.new(at - Vector3.new(0, 1.5, 0)), 1, 4 * k, pal.color, 0.6, 0.5)
end
HIT.lightning = function(parent, at, pal, k)
	flash(parent, at, pal.light, 2 * k, 0.15, 6)
	for b = 0, 2 do
		local from = at + Vector3.new(math.random() * 4 - 2, 9 + math.random() * 3, math.random() * 4 - 2)
		local prev = from
		for i = 1, 4 do
			local t = i / 4
			local pt = from:Lerp(at, t) + (if i < 4 then Vector3.new(math.random() * 1.6 - 0.8, 0, math.random() * 1.6 - 0.8) else Vector3.zero)
			streak(parent, prev, pt, 0.18 * k, if b == 0 then pal.light else pal.color, 0.18, 0, b * 0.04)
			prev = pt
		end
	end
end
HIT.venom = function(parent, at, pal, k)
	flash(parent, at, pal.color, 1.8 * k, 0.3)
	disc(parent, CFrame.new(at - Vector3.new(0, 1.2, 0)), 0.8, 3.6 * k, pal.deep, 0.8, 0.3)
	for i = 0, 4 do
		local off = Vector3.new(math.random() * 2 - 1, 0, math.random() * 2 - 1) * k
		local bubble = part(parent, Vector3.one * (0.25 + math.random() * 0.25) * k, CFrame.new(at + off), pal.light, 0.2, Enum.PartType.Ball)
		fade(bubble, 0.8, Vector3.one * 0.6 * k, i * 0.05, CFrame.new(at + off + Vector3.new(0, 2 + math.random(), 0)))
	end
end
HIT.void = function(parent, at, pal, k)
	local sphere = part(parent, Vector3.one * 4 * k, CFrame.new(at), pal.deep, 0.3, Enum.PartType.Ball)
	fade(sphere, 0.35, Vector3.one * 0.2)
	local core = part(parent, Vector3.one * 0.6 * k, CFrame.new(at), pal.light, 0, Enum.PartType.Ball)
	fade(core, 0.5, Vector3.one * 1.8 * k, 0.3)
	hoop(parent, CFrame.new(at), 2.8 * k, 0.3, 10, 0.15, pal.color, 0.35, 0.2)
end
HIT.holy = function(parent, at, pal, k)
	local pillar = part(parent, Vector3.new(10, 1.1 * k, 1.1 * k), CFrame.new(at + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, 0, R90), pal.light, 0.35, Enum.PartType.Cylinder)
	fade(pillar, 0.55, Vector3.new(12, 0.1, 0.1))
	flash(parent, at, pal.color, 2.4 * k, 0.4, 5)
	for _, rot in { 0, R90 } do
		local beam = part(parent, Vector3.new(0.2, 3.2 * k, 0.2), CFrame.new(at) * CFrame.Angles(0, 0, rot), pal.light, 0)
		fade(beam, 0.35, Vector3.new(0.05, 4.5 * k, 0.05))
	end
end
HIT.wind = function(parent, at, pal, k)
	for i = 0, 3 do
		local a = i / 4 * math.pi * 2
		local cf = CFrame.new(at) * CFrame.Angles(0, a, 0)
		local p = part(parent, Vector3.new(2.2 * k, 0.12, 0.3), cf * CFrame.new(0, i * 0.3 - 0.4, -1 * k), if i % 2 == 0 then pal.light else pal.color, 0.2)
		fade(p, 0.4, Vector3.new(2.6 * k, 0.04, 0.1), nil, CFrame.new(at) * CFrame.Angles(0, a + 1.6, 0) * CFrame.new(0, i * 0.3, -2 * k))
	end
	hoop(parent, CFrame.new(at), 0.6, 3 * k, 8, 0.12, pal.color, 0.35, 0.3)
end
HIT.earth = function(parent, at, pal, k)
	flash(parent, at, pal.color, 2 * k, 0.3, 3)
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		local rock = part(parent, Vector3.one * (0.3 + math.random() * 0.35) * k, CFrame.new(at) * CFrame.Angles(a, a, 0), Color3.fromRGB(120, 100, 80), 0, nil, Enum.Material.Slate)
		fade(rock, 0.6, nil, 0.05, CFrame.new(at + Vector3.new(math.cos(a) * 2.2, 1.6 + math.random() * 1.4, math.sin(a) * 2.2) * k) * CFrame.Angles(a * 2, a, 1))
	end
	hoop(parent, CFrame.new(at - Vector3.new(0, 1.2, 0)), 0.6, 3.2 * k, 10, 0.25, pal.deep, 0.5, 0.2)
end
HIT.none = function(parent, at, pal, k)
	flash(parent, at, pal.light, 1.8 * k, 0.2, 3)
	for i = 0, 3 do
		local d = Vector3.new(math.random() * 2 - 1, math.random() * 1.4 - 0.2, math.random() * 2 - 1)
		if d.Magnitude > 0.1 then
			streak(parent, at, at + d.Unit * 1.6 * k, 0.1, pal.color, 0.18, 0)
		end
	end
end

function WeaponFx.hit(position: Vector3, element: string?, power: number?, opts: any?)
	local key = if element and HIT[element] then element else "none"
	local parent = folder(opts)
	local k = scaleOf(power)
	local pal = palette(key)
	HIT[key](parent, position, pal, k)
	burst(parent, position, key, 10 * k, k)
	if not (opts and opts.sound == false) then
		if key ~= "none" then
			sfx("magic", key, "impact", position, { power = power, volume = 0.6 })
		end
		if opts and opts.family then
			sfx("weapon", opts.family, "hit", position, { power = power })
		end
	end
end

-- ── equip ──────────────────────────────────────────────────────────────────
-- a glow over the weapon's pieces (welded to them, so it follows the hand), a ring and a burst
function WeaponFx.equip(model: Model, opts: any?)
	local parent = folder(opts)
	local element = WeaponFx.elementOf(model)
	local pal = palette(element)
	local shiny = model:GetAttribute("WeaponShiny") == true
	local color = if shiny then GOLD else pal.color
	local pieces = {}
	for _, d in model:GetChildren() do
		if d:IsA("BasePart") and string.sub(d.Name, 1, 6) == "Weapon" and d.Transparency < 0.9 then
			local mesh = d:FindFirstChildOfClass("SpecialMesh")
			if not (mesh and mesh.Scale.X < 0.01) then
				table.insert(pieces, d)
			end
		end
	end
	table.sort(pieces, function(a, b)
		return a.Size.X * a.Size.Y * a.Size.Z > b.Size.X * b.Size.Y * b.Size.Z
	end)
	for i = 1, math.min(#pieces, 14) do
		local src = pieces[i]
		local g: BasePart
		if src:IsA("MeshPart") then
			g = src:Clone()
			for _, ch in g:GetChildren() do
				ch:Destroy()
			end
		elseif src:IsA("WedgePart") then
			g = Instance.new("WedgePart")
		else
			g = Instance.new("Part")
			if src:IsA("Part") then
				(g :: Part).Shape = src.Shape
			end
		end
		g.Name = "FxGhost"
		g.Anchored = false
		g.CanCollide = false
		g.CanQuery = false
		g.CanTouch = false
		g.CastShadow = false
		g.Massless = true
		g.Material = Enum.Material.Neon
		g.Color = color
		g.Transparency = 0.25
		g.Size = src.Size * 1.08 + Vector3.new(0.04, 0.04, 0.04)
		g.CFrame = src.CFrame
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = src
		weld.Part1 = g
		weld.Parent = g
		g.Parent = parent
		tween(g, 0.45, { Transparency = 1 }, (i - 1) * 0.01)
		Debris:AddItem(g, 0.7)
	end
	local tip, _, focus = weaponPoints(model)
	local at = focus or tip or rootOf(model).Position
	local root = rootOf(model)
	hoop(parent, CFrame.new(root.Position - Vector3.new(0, 2.8, 0)), 0.8, 3.2, 10, 0.12, color, 0.45, 0.25)
	flash(parent, at, pal.light, 1.5, 0.3, 3)
	burst(parent, at, element, 12, 0.9, if shiny then GOLD else nil)
	if not (opts and opts.sound == false) then
		sfx("weapon", WeaponFx.familyOf(model), "equip", at)
		if shiny then
			sfx("play", "holy.ding", at, { volume = 0.5, pitch = 1.2 })
		end
	end
end

return WeaponFx
