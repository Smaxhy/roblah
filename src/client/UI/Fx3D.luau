--[[
	FX3D (v0.18): real Roblox effects for the 3D stage (UI/World3D.luau): ParticleEmitters,
	Beams, PointLights, Neon and ForceField parts, Highlights, with the camera's shake, punch
	and impact frames from the stage.

	Textures are Roblox's own built-in particle textures (rbxasset://textures/particles/...,
	shipped with every client, so nothing has to be uploaded). The layering of a hit (an
	anticipation glow, a one-frame flash, a coloured core with a dark backing, streaks that
	shoot out and stop, sparks, a ring, smoke on a heavy one, and a light that flashes as its
	range grows) follows the measured recipes in the MIT-licensed roblox-vfx skill
	(github.com/adnvli/vfxskill, vendor/roblox-vfx-recipes-LICENSE.txt).

	  Fx3D.impact(w, pos, { color, heavy, crit, scale, status })
	  Fx3D.slash(w, from, to, { color, bow })      -- a swept crescent, then the impact
	  Fx3D.lightning(w, from, to, color)
	  Fx3D.status(w, pos, id, { floor })           -- burn, bleed, tremor, rupture, sinking, poise, charge
	  Fx3D.heal(w, pos, { floor })   Fx3D.guard(w, pos, color)   Fx3D.dust(w, pos)
	  Fx3D.anticipate(w, pos, color)  Fx3D.phase(w, pos, color, { floor })
	  Fx3D.ko(w, pos)  Fx3D.victory(w, pos, color)
	  Fx3D.flashModel(model, color)                -- a hit actor flashes white
	  Fx3D.aura(w, color, kind) -> { move(pos), stop() }

	Every function is safe to call anywhere (a failure only loses the effect) and cleans up
	after itself. Effects are kept to a few dozen particles each (Roblox's guide: about 400 a
	second, 100 on phones).
]]

local RunService = game:GetService("RunService")

local Fx3D = {}

-- (v0.18) the "3D effects" setting: Full draws everything; Lite draws fewer particles and
-- no flashing lights, for slower phones (Settings > Display; "flat" turns the stage off,
-- see World3D.available)
Fx3D.scale = 1
Fx3D.lights = true
function Fx3D.setQuality(q: string?)
	if q == "lite" then
		Fx3D.scale, Fx3D.lights = 0.45, false
	else
		Fx3D.scale, Fx3D.lights = 1, true
	end
end

local TEX = {
	glow = "rbxasset://textures/particles/explosion01_implosion_main.dds", -- soft round glow
	ring = "rbxasset://textures/particles/explosion01_shockwave_main.dds", -- soft ring
	core = "rbxasset://textures/particles/explosion01_core_main.dds", -- fiery puff
	smoke = "rbxasset://textures/particles/smoke_main.dds", -- grey puff
	star = "rbxasset://textures/particles/sparkles_main.dds", -- four-point star
	fire = "rbxasset://textures/particles/fire_main.dds", -- wispy flame
	sparks = "rbxasset://textures/particles/fire_sparks_main.dds", -- spark dots
	vortex = "rbxasset://textures/particles/forcefield_vortex_main.dds", -- thin ring with dots
}
Fx3D.TEX = TEX

local STATUS = {
	burn = Color3.fromRGB(255, 132, 40),
	bleed = Color3.fromRGB(200, 34, 50),
	tremor = Color3.fromRGB(232, 190, 80),
	rupture = Color3.fromRGB(80, 220, 190),
	sinking = Color3.fromRGB(60, 90, 220),
	poise = Color3.fromRGB(230, 240, 255),
	charge = Color3.fromRGB(90, 180, 255),
}
Fx3D.STATUS = STATUS

local WARM = Color3.fromRGB(255, 226, 170)

-- (blueprint) a game's own effect colors (spec.vfx, sent with hello):
--   statuses = { burn = { color = { r, g, b } }, ... }   tints that status's effect
--   hit = { r, g, b }                                     the color of an ordinary blow
-- (a status keeps its own particles: Burn still flames, Sinking still drips; a game renames
-- them with spec.vfx.statuses[id].name, which the engine's pack.statuses carries)
function Fx3D.useVfx(vfx: any)
	if type(vfx) ~= "table" then
		return
	end
	local function rgb(t: any): Color3?
		if type(t) == "table" and type(t[1]) == "number" then
			return Color3.fromRGB(t[1], t[2], t[3])
		end
		return nil
	end
	for id, st in vfx.statuses or {} do
		local col = type(st) == "table" and rgb(st.color)
		if col and STATUS[id] then
			STATUS[id] = col
		end
	end
	WARM = rgb(vfx.hit) or WARM
end

-- ── small helpers ──────────────────────────────────────────────────────────

local function ns(points): NumberSequence
	if type(points) == "number" then
		return NumberSequence.new(points)
	end
	local kps = {}
	for _, p in points do
		table.insert(kps, NumberSequenceKeypoint.new(p[1], p[2]))
	end
	return NumberSequence.new(kps)
end

local function cs(a: Color3, b: Color3?): ColorSequence
	if b then
		return ColorSequence.new(a, b)
	end
	return ColorSequence.new(a)
end

local function nr(a: number, b: number?): NumberRange
	return NumberRange.new(a, b or a)
end

local function folderOf(w)
	-- (an effect a beat behind, a slash's impact say, can come after its stage has closed: then
	-- there's nowhere to put it, and it's dropped)
	if not w or w.closed or not w.folder or not w.folder.Parent then
		return nil
	end
	return w.folder
end

-- an invisible anchored point to hang effects from; gone after `life` seconds
local function anchor(w, pos: Vector3, life: number): (BasePart?, Attachment?)
	local folder = folderOf(w)
	if not folder then
		return nil, nil
	end
	local p = Instance.new("Part")
	p.Name = "Fx"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.CFrame = CFrame.new(pos)
	local att = Instance.new("Attachment")
	att.Parent = p
	p.Parent = folder
	task.delay(life, function()
		pcall(p.Destroy, p) -- (already gone if its stage closed first)
	end)
	return p, att
end

-- a ParticleEmitter that only fires when told (Rate 0), with these properties
local function emitter(parent: Instance, props): ParticleEmitter
	local pe = Instance.new("ParticleEmitter")
	pe.Enabled = false
	pe.Rate = 0
	pe.LightInfluence = 0
	pe.Speed = nr(0.001)
	pe.SpreadAngle = Vector2.new(0, 0)
	for k, v in props do
		pcall(function()
			(pe :: any)[k] = v
		end)
	end
	pe.Parent = parent
	return pe
end

local function emit(pe: ParticleEmitter, count: number, delay: number?)
	local function go()
		local n = math.max(1, math.floor(count * Fx3D.scale))
		-- (counted on the emitter too, so the test renderer can draw what was emitted)
		pcall(function()
			pe:SetAttribute("LifeSimEmitted", ((pe:GetAttribute("LifeSimEmitted") :: number?) or 0) + n)
		end)
		pcall(function()
			pe:Emit(n)
		end)
	end
	if delay and delay > 0 then
		task.delay(delay, go)
	else
		go()
	end
end

-- run fn(k) for k from 0 to 1 over `dur` seconds on Heartbeat, then done()
local function animate(dur: number, fn: (number) -> (), done: (() -> ())?)
	local t = 0
	local finished = false
	local conn = nil
	local function finish()
		if finished then
			return
		end
		finished = true
		if conn then
			conn:Disconnect()
		end
		if done then
			pcall(done)
		end
	end
	conn = RunService.Heartbeat:Connect(function(dt)
		if finished then
			return
		end
		t += dt
		local k = math.clamp(t / dur, 0, 1)
		local ok = pcall(fn, k)
		if k >= 1 or not ok then
			finish()
		end
	end)
	-- (a stalled clock can't leave anything behind)
	task.delay(dur + 1, finish)
end

-- a light that flashes, then fades as its range grows (the measured way)
local function flashLight(parent: Instance, color: Color3, brightness: number, range0: number, range1: number, dur: number)
	if not Fx3D.lights then
		return
	end
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range0
	light.Shadows = false
	light.Parent = parent
	animate(dur, function(k)
		light.Brightness = brightness * (1 - k) * (1 - k)
		light.Range = range0 + (range1 - range0) * k
	end, function()
		light:Destroy()
	end)
end

local function neonPart(w, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): BasePart?
	local folder = folderOf(w)
	if not folder then
		return nil
	end
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = material or Enum.Material.Neon
	p.Color = color
	p.Size = size
	p.CFrame = cf
	p.Parent = folder
	return p
end

-- ── a hit ──────────────────────────────────────────────────────────────────

-- opts: { color, heavy, crit, scale, status, noCamera }
function Fx3D.impact(w, pos: Vector3, opts)
	opts = opts or {}
	local heavy = opts.heavy == true or opts.crit == true
	local color = opts.color or (opts.status and STATUS[opts.status]) or WARM
	local R = (if heavy then 2.1 else 1.35) * (opts.scale or 1)
	local _, att = anchor(w, pos, 2.6)
	if not att then
		return
	end
	-- flash: in front of everything, a frame or two
	emit(emitter(att, {
		Texture = TEX.star, Lifetime = nr(0.06, 0.1), LockedToPart = true, LightEmission = 1, Brightness = 8, ZOffset = 3,
		Rotation = nr(0, 360), Color = cs(Color3.new(1, 0.97, 0.9)),
		Size = ns({ { 0, R * 0.6 }, { 0.3, R * 1.8 }, { 1, R * 2.1 } }), Transparency = ns({ { 0, 0 }, { 1, 1 } }),
	}), 1)
	-- the coloured core, a white-hot centre, and a dark backing for contrast
	emit(emitter(att, {
		Texture = TEX.core, Lifetime = nr(0.1, 0.16), LockedToPart = true, LightEmission = 1, Brightness = 4, ZOffset = 1,
		Rotation = nr(0, 360), Color = cs(color),
		Size = ns({ { 0, R * 0.8 }, { 0.25, R * 1.4 }, { 1, R * 1.55 } }), Transparency = ns({ { 0, 0 }, { 0.6, 0.1 }, { 1, 1 } }),
	}), 2)
	emit(emitter(att, {
		Texture = TEX.core, Lifetime = nr(0.06, 0.1), LockedToPart = true, LightEmission = 1, Brightness = 12, ZOffset = 2,
		Rotation = nr(0, 360), Color = cs(Color3.new(1, 1, 1)),
		Size = ns({ { 0, R * 0.4 }, { 1, R * 0.7 } }), Transparency = ns({ { 0, 0 }, { 1, 1 } }),
	}), 1)
	emit(emitter(att, {
		Texture = TEX.glow, Lifetime = nr(0.3), LockedToPart = true, LightEmission = 0, Brightness = 1, ZOffset = -1,
		Color = cs(Color3.new(0, 0, 0)),
		Size = ns({ { 0, R * 1.9 }, { 1, R * 2.7 } }), Transparency = ns({ { 0, 0.45 }, { 1, 1 } }),
	}), 1)
	-- streaks that shoot out and stop
	emit(emitter(att, {
		Texture = TEX.glow, Lifetime = nr(0.2, 0.35), Speed = nr(40 * R, 110 * R), SpreadAngle = Vector2.new(180, 180), Drag = 10,
		Orientation = Enum.ParticleOrientation.VelocityParallel, LightEmission = 1, Brightness = 6, ZOffset = 2,
		Color = cs(Color3.new(1, 0.95, 0.8), color), Size = ns({ { 0, R * 0.34 }, { 1, 0 } }), Squash = ns({ { 0, 3 }, { 1, 1 } }),
	}), if heavy then 16 else 10, 0.02)
	-- sparks that arc down
	emit(emitter(att, {
		Texture = TEX.sparks, Lifetime = nr(0.4, 0.9), Speed = nr(10, 42), SpreadAngle = Vector2.new(180, 180), Drag = 5,
		Acceleration = Vector3.new(0, -26, 0), LightEmission = 1, Brightness = 3, Rotation = nr(0, 360),
		Color = cs(Color3.new(1, 0.92, 0.7), color), Size = ns({ { 0, 0.32 }, { 1, 0 } }),
	}), if heavy then 24 else 14, 0.03)
	-- the ring, facing the camera, growing
	emit(emitter(att, {
		Texture = TEX.ring, Lifetime = nr(0.32), LockedToPart = true, LightEmission = 1, Brightness = 2, ZOffset = 0.5,
		Color = cs(color), Size = ns({ { 0, R * 0.6 }, { 0.4, R * 2.6 }, { 1, R * 3.3 } }), Transparency = ns({ { 0, 0 }, { 1, 1 } }),
	}), 1, 0.03)
	if heavy then
		-- smoke that bursts out and hangs, lit by the scene
		emit(emitter(att, {
			Texture = TEX.smoke, Lifetime = nr(0.9, 1.3), Speed = nr(8, 18), SpreadAngle = Vector2.new(180, 180), Drag = 6,
			Acceleration = Vector3.new(0, 2, 0), TimeScale = 0.8, Rotation = nr(0, 360), RotSpeed = nr(-30, 30),
			LightInfluence = 1, Color = cs(Color3.fromRGB(70, 64, 62)), Size = ns(R * 1.4),
			Transparency = ns({ { 0, 0.35 }, { 1, 1 } }),
		}), 5, 0.05)
	end
	flashLight(att, color, if heavy then 10 else 6, 6, if heavy then 22 else 15, if heavy then 0.55 else 0.4)
	if not opts.noCamera and w.shake then
		w:shake(if opts.crit then "huge" elseif heavy then "heavy" else "light")
		w:punch(if heavy then 7 else 3)
		if heavy then
			w:impactFrame("black")
		end
	end
end

-- a swept crescent from `from` to `to`, then the impact where it lands
-- opts: { color, bow (studs), heavy, status }
function Fx3D.slash(w, from: Vector3, to: Vector3, opts)
	opts = opts or {}
	local color = opts.color or (opts.status and STATUS[opts.status]) or Color3.fromRGB(255, 236, 200)
	local mid = (from + to) / 2
	local part = anchor(w, mid, 1.2)
	if not part then
		return
	end
	local up = Vector3.new(0, 1, 0)
	local along = (to - from)
	if along.Magnitude < 0.01 then
		along = Vector3.new(1, 0, 0)
	end
	local side = along.Unit:Cross(up)
	if side.Magnitude < 0.01 then
		side = Vector3.new(0, 0, 1)
	end
	local bowDir = (up * 0.8 + side.Unit * 0.6).Unit
	local a0 = Instance.new("Attachment")
	a0.CFrame = CFrame.fromMatrix(from - mid, bowDir, along.Unit:Cross(bowDir))
	a0.Parent = part
	local a1 = Instance.new("Attachment")
	a1.CFrame = CFrame.fromMatrix(to - mid, -bowDir, along.Unit:Cross(-bowDir))
	a1.Parent = part
	local bow = opts.bow or (along.Magnitude * 0.35)
	local beams = {}
	for i, spec in { { width = 1.25, color = color, light = 1 }, { width = 0.45, color = Color3.new(1, 1, 1), light = 1 } } do
		local b = Instance.new("Beam")
		b.Attachment0, b.Attachment1 = a0, a1
		b.CurveSize0, b.CurveSize1 = bow, bow
		b.Width0, b.Width1 = spec.width * 0.15, spec.width
		b.Segments = 28
		b.FaceCamera = true
		b.LightEmission = spec.light
		b.LightInfluence = 0
		pcall(function()
			b.Brightness = if i == 2 then 4 else 2.5
		end)
		b.Color = cs(spec.color)
		b.Transparency = ns(1)
		b.Parent = part
		table.insert(beams, b)
	end
	-- the sweep: the crescent draws itself across in a tenth of a second, then fades
	animate(0.34, function(k)
		local head = math.clamp(k / 0.3, 0, 1)
		local fade = math.clamp((k - 0.3) / 0.7, 0, 1)
		for _, b in beams do
			local h = math.clamp(head, 0.02, 0.98)
			b.Transparency = ns({ { 0, fade * 0.6 + 0.2 }, { math.max(0.001, h - 0.02), fade }, { math.min(0.999, h + 0.001), 1 }, { 1, 1 } })
		end
	end, function()
		for _, b in beams do
			b:Destroy()
		end
	end)
	task.delay(0.07, function()
		Fx3D.impact(w, to, { color = color, heavy = opts.heavy, status = opts.status })
	end)
end

-- a jagged bolt of Neon segments (Bloom makes it glow), flickering, then gone
function Fx3D.lightning(w, from: Vector3, to: Vector3, color: Color3?)
	color = color or STATUS.charge
	local folder = folderOf(w)
	if not folder then
		return
	end
	local segs = 7
	local pts = { from }
	local dir = to - from
	local side = dir:Cross(Vector3.new(0, 0, 1))
	if side.Magnitude < 0.01 then
		side = Vector3.new(1, 0, 0)
	end
	side = side.Unit
	local up = dir:Cross(side)
	up = if up.Magnitude > 0.01 then up.Unit else Vector3.new(0, 1, 0)
	for i = 1, segs - 1 do
		local p = from + dir * (i / segs)
		local j = dir.Magnitude * 0.08
		p += side * (math.random() - 0.5) * 2 * j + up * (math.random() - 0.5) * 2 * j
		table.insert(pts, p)
	end
	table.insert(pts, to)
	local parts = {}
	for i = 1, #pts - 1 do
		local a, b = pts[i], pts[i + 1]
		local len = (b - a).Magnitude
		local p = neonPart(w, Vector3.new(0.14, 0.14, len), CFrame.lookAt((a + b) / 2, b), color :: Color3)
		if p then
			table.insert(parts, p)
		end
	end
	local _, att = anchor(w, to, 1.2)
	if att then
		flashLight(att, color :: Color3, 7, 4, 14, 0.35)
		emit(emitter(att, {
			Texture = TEX.sparks, Lifetime = nr(0.2, 0.45), Speed = nr(12, 30), SpreadAngle = Vector2.new(180, 180), Drag = 6,
			LightEmission = 1, Brightness = 4, Color = cs(Color3.new(1, 1, 1), color :: Color3), Size = ns({ { 0, 0.3 }, { 1, 0 } }),
		}), 12)
	end
	animate(0.3, function(k)
		local flick = if k < 0.4 then (if math.floor(k * 20) % 2 == 0 then 0 else 0.6) else k
		for _, p in parts do
			p.Transparency = math.clamp(flick, 0, 1)
		end
	end, function()
		for _, p in parts do
			p:Destroy()
		end
	end)
end

-- ── statuses ───────────────────────────────────────────────────────────────

-- opts: { floor = y of the ground under them }
function Fx3D.status(w, pos: Vector3, id: string?, opts)
	opts = opts or {}
	local color = STATUS[id or ""]
	if not color then
		return
	end
	local floorY = opts.floor or (pos.Y - 3)
	local _, att = anchor(w, pos, 2.4)
	if not att then
		return
	end
	if id == "burn" then
		local flames = emitter(att, {
			Texture = TEX.fire, Lifetime = nr(0.5, 0.9), Speed = nr(2, 5), SpreadAngle = Vector2.new(30, 30),
			Acceleration = Vector3.new(0, 7, 0), LightEmission = 1, Brightness = 2, Rotation = nr(0, 360), RotSpeed = nr(-40, 40),
			Color = cs(Color3.fromRGB(255, 190, 80), Color3.fromRGB(220, 60, 20)), Size = ns({ { 0, 1.3 }, { 1, 0.3 } }),
			Transparency = ns({ { 0, 0.2 }, { 1, 1 } }),
		})
		emit(flames, 10)
		emit(flames, 8, 0.25)
		emit(emitter(att, {
			Texture = TEX.sparks, Lifetime = nr(0.8, 1.4), Speed = nr(3, 8), SpreadAngle = Vector2.new(50, 50), Acceleration = Vector3.new(0, 5, 0),
			LightEmission = 1, Brightness = 3, Color = cs(Color3.fromRGB(255, 200, 120), color), Size = ns({ { 0, 0.22 }, { 1, 0 } }),
		}), 14)
		flashLight(att, color, 4, 6, 10, 0.9)
	elseif id == "bleed" then
		-- crimson motes that drip away (stylised: sparks, not anything more)
		emit(emitter(att, {
			Texture = TEX.glow, Lifetime = nr(0.5, 0.9), Speed = nr(2, 6), SpreadAngle = Vector2.new(70, 70),
			Acceleration = Vector3.new(0, -24, 0), LightEmission = 0.4, Brightness = 2, Color = cs(color),
			Size = ns({ { 0, 0.34 }, { 1, 0.1 } }), Transparency = ns({ { 0, 0 }, { 1, 0.8 } }),
		}), 14)
		emit(emitter(att, {
			Texture = TEX.ring, Lifetime = nr(0.3), LockedToPart = true, LightEmission = 1, Brightness = 1.5,
			Color = cs(color), Size = ns({ { 0, 1 }, { 1, 4 } }), Transparency = ns({ { 0, 0.2 }, { 1, 1 } }),
		}), 1)
	elseif id == "tremor" then
		local _, ground = anchor(w, Vector3.new(pos.X, floorY + 0.1, pos.Z), 2)
		if ground then
			local ring = emitter(ground, {
				Texture = TEX.ring, Lifetime = nr(0.45), EmissionDirection = Enum.NormalId.Top,
				Orientation = Enum.ParticleOrientation.VelocityPerpendicular, LightEmission = 1, Brightness = 2,
				Color = cs(color), Size = ns({ { 0, 1 }, { 0.5, 8 }, { 1, 10 } }), Transparency = ns({ { 0, 0 }, { 1, 1 } }),
			})
			emit(ring, 1)
			emit(ring, 1, 0.12)
			emit(ring, 1, 0.24)
			emit(emitter(ground, {
				Texture = TEX.smoke, Lifetime = nr(0.7, 1.1), Speed = nr(6, 12), SpreadAngle = Vector2.new(80, 80), Drag = 4,
				LightInfluence = 1, Rotation = nr(0, 360), Color = cs(Color3.fromRGB(120, 104, 84)), Size = ns(2.2),
				Transparency = ns({ { 0, 0.4 }, { 1, 1 } }),
			}), 8)
		end
		if w.shake then
			w:shake("medium")
		end
	elseif id == "rupture" then
		-- cracks of light run out along the ground, and shards fly
		for i = 1, 6 do
			local ang = (i / 6) * math.pi * 2 + math.random() * 0.4
			local len = 2 + math.random() * 2.5
			local d = Vector3.new(math.cos(ang), 0, math.sin(ang))
			local start = Vector3.new(pos.X, floorY + 0.06, pos.Z)
			local crack = neonPart(w, Vector3.new(0.12, 0.05, 0.01), CFrame.lookAt(start, start + d), color)
			if crack then
				animate(0.7, function(k)
					local grow = math.clamp(k / 0.25, 0, 1)
					local l = math.max(0.01, len * grow)
					crack.Size = Vector3.new(0.12, 0.05, l)
					crack.CFrame = CFrame.lookAt(start + d * (l / 2), start + d * l)
					crack.Transparency = math.clamp((k - 0.5) / 0.5, 0, 1)
				end, function()
					crack:Destroy()
				end)
			end
		end
		emit(emitter(att, {
			Texture = TEX.star, Lifetime = nr(0.3, 0.6), Speed = nr(8, 20), SpreadAngle = Vector2.new(180, 180), Drag = 5,
			LightEmission = 1, Brightness = 3, Rotation = nr(0, 360), RotSpeed = nr(-200, 200),
			Color = cs(Color3.new(1, 1, 1), color), Size = ns({ { 0, 0.7 }, { 1, 0 } }),
		}), 12)
		flashLight(att, color, 5, 4, 12, 0.5)
	elseif id == "sinking" then
		local _, above = anchor(w, pos + Vector3.new(0, 4, 0), 2)
		if above then
			emit(emitter(above, {
				Texture = TEX.glow, Lifetime = nr(0.5, 0.8), Speed = nr(1, 3), SpreadAngle = Vector2.new(40, 40),
				EmissionDirection = Enum.NormalId.Bottom, Acceleration = Vector3.new(0, -34, 0), LightEmission = 0.6, Brightness = 2,
				Color = cs(Color3.fromRGB(120, 150, 255), color), Size = ns({ { 0, 0.3 }, { 1, 0.16 } }),
			}), 16)
		end
		emit(emitter(att, {
			Texture = TEX.smoke, Lifetime = nr(1, 1.4), Speed = nr(1, 3), SpreadAngle = Vector2.new(180, 180), Drag = 2,
			LightInfluence = 0.5, Rotation = nr(0, 360), RotSpeed = nr(-20, 20), Color = cs(Color3.fromRGB(20, 26, 60)),
			Size = ns({ { 0, 2 }, { 1, 3.4 } }), Transparency = ns({ { 0, 0.35 }, { 1, 1 } }),
		}), 6)
	elseif id == "poise" then
		emit(emitter(att, {
			Texture = TEX.star, Lifetime = nr(0.4, 0.7), Speed = nr(2, 5), SpreadAngle = Vector2.new(180, 180), Drag = 3,
			LightEmission = 1, Brightness = 5, Rotation = nr(0, 360), RotSpeed = nr(-90, 90),
			Color = cs(Color3.fromRGB(255, 236, 170), color), Size = ns({ { 0, 0.2 }, { 0.3, 0.9 }, { 1, 0 } }),
		}), 10)
		flashLight(att, Color3.fromRGB(255, 240, 200), 4, 4, 9, 0.45)
	elseif id == "charge" then
		for i = 1, 3 do
			local ang = math.random() * math.pi * 2
			local a = pos + Vector3.new(math.cos(ang) * 2.2, 1.6 + math.random(), math.sin(ang) * 1.2)
			task.delay((i - 1) * 0.08, function()
				Fx3D.lightning(w, a, pos + Vector3.new((math.random() - 0.5), (math.random() - 0.5), 0), color)
			end)
		end
	end
end

-- ── the rest ───────────────────────────────────────────────────────────────

function Fx3D.heal(w, pos: Vector3, opts)
	opts = opts or {}
	local color = Color3.fromRGB(120, 240, 160)
	local _, att = anchor(w, pos, 2.6)
	if not att then
		return
	end
	local motes = emitter(att, {
		Texture = TEX.glow, Lifetime = nr(0.9, 1.4), Speed = nr(1.5, 3.5), SpreadAngle = Vector2.new(60, 60),
		Acceleration = Vector3.new(0, 3, 0), LightEmission = 1, Brightness = 3, Color = cs(Color3.fromRGB(220, 255, 200), color),
		Size = ns({ { 0, 0.1 }, { 0.3, 0.45 }, { 1, 0 } }),
	})
	emit(motes, 10)
	emit(motes, 8, 0.3)
	emit(emitter(att, {
		Texture = TEX.star, Lifetime = nr(0.5, 0.8), Speed = nr(1, 3), SpreadAngle = Vector2.new(180, 180),
		LightEmission = 1, Brightness = 4, Rotation = nr(0, 360), Color = cs(Color3.new(1, 1, 0.9), color), Size = ns({ { 0, 0.6 }, { 1, 0 } }),
	}), 6, 0.1)
	local _, ground = anchor(w, Vector3.new(pos.X, (opts.floor or pos.Y - 3) + 0.1, pos.Z), 1.4)
	if ground then
		emit(emitter(ground, {
			Texture = TEX.ring, Lifetime = nr(0.6), EmissionDirection = Enum.NormalId.Top,
			Orientation = Enum.ParticleOrientation.VelocityPerpendicular, LightEmission = 1, Brightness = 2,
			Color = cs(color), Size = ns({ { 0, 1 }, { 1, 5 } }), Transparency = ns({ { 0, 0.1 }, { 1, 1 } }),
		}), 1)
	end
	flashLight(att, color, 4, 5, 10, 1.0)
end

-- a shield of light: a ForceField bubble that pops up and fades, with a clang of sparks
function Fx3D.guard(w, pos: Vector3, color: Color3?)
	color = color or Color3.fromRGB(140, 200, 255)
	local bubble = neonPart(w, Vector3.new(1, 1, 1), CFrame.new(pos), color :: Color3, Enum.Material.ForceField)
	if bubble then
		local shape = bubble :: Part
		shape.Shape = Enum.PartType.Ball
		animate(0.6, function(k)
			local grow = 1 - (1 - math.clamp(k / 0.25, 0, 1)) ^ 3
			local s = 2.5 + 3.3 * grow
			shape.Size = Vector3.new(s, s, s)
			shape.Transparency = math.clamp((k - 0.4) / 0.6, 0, 1)
		end, function()
			shape:Destroy()
		end)
	end
	local _, att = anchor(w, pos, 1.4)
	if att then
		emit(emitter(att, {
			Texture = TEX.vortex, Lifetime = nr(0.35), LockedToPart = true, LightEmission = 1, Brightness = 3, ZOffset = 1,
			Color = cs(color :: Color3), Size = ns({ { 0, 2 }, { 1, 6.5 } }), Transparency = ns({ { 0, 0 }, { 1, 1 } }),
			Rotation = nr(0, 360), RotSpeed = nr(120, 180),
		}), 1)
		flashLight(att, color :: Color3, 3, 4, 9, 0.4)
	end
end

-- feet hit the ground (a lunge, a landing)
function Fx3D.dust(w, pos: Vector3)
	local _, att = anchor(w, pos + Vector3.new(0, 0.2, 0), 1.6)
	if not att then
		return
	end
	emit(emitter(att, {
		Texture = TEX.smoke, Lifetime = nr(0.5, 0.8), Speed = nr(4, 8), SpreadAngle = Vector2.new(85, 85), Drag = 5,
		EmissionDirection = Enum.NormalId.Top, LightInfluence = 1, Rotation = nr(0, 360), Color = cs(Color3.fromRGB(130, 120, 110)),
		Size = ns({ { 0, 0.8 }, { 1, 1.8 } }), Transparency = ns({ { 0, 0.45 }, { 1, 1 } }),
	}), 6)
end

-- a glow that shrinks into a point, spinning: something is about to land
function Fx3D.anticipate(w, pos: Vector3, color: Color3?)
	local _, att = anchor(w, pos, 0.8)
	if not att then
		return
	end
	emit(emitter(att, {
		Texture = TEX.glow, Lifetime = nr(0.16), LockedToPart = true, LightEmission = 1, Brightness = 3, ZOffset = 1,
		Rotation = nr(0, 360), RotSpeed = nr(-700, -500), Color = cs(color or WARM),
		Size = ns({ { 0, 4.5 }, { 1, 0 } }), Transparency = ns({ { 0, 0.4 }, { 0.3, 0 }, { 1, 0 } }),
	}), 1)
end

-- a boss changes phase: everything goes dark for a beat, a red burst, a ring across the floor
function Fx3D.phase(w, pos: Vector3, color: Color3?, opts)
	opts = opts or {}
	color = color or Color3.fromRGB(220, 40, 52)
	local _, att = anchor(w, pos, 3)
	if not att then
		return
	end
	emit(emitter(att, {
		Texture = TEX.glow, Lifetime = nr(0.6), LockedToPart = true, LightEmission = 0, ZOffset = -2,
		Color = cs(Color3.new(0, 0, 0)), Size = ns({ { 0, 4 }, { 1, 12 } }), Transparency = ns({ { 0, 0.2 }, { 1, 1 } }),
	}), 1)
	emit(emitter(att, {
		Texture = TEX.fire, Lifetime = nr(0.8, 1.3), Speed = nr(3, 8), SpreadAngle = Vector2.new(25, 25),
		Acceleration = Vector3.new(0, 10, 0), LightEmission = 1, Brightness = 3, Rotation = nr(0, 360),
		Color = cs(Color3.fromRGB(255, 120, 100), color :: Color3), Size = ns({ { 0, 2 }, { 1, 0.4 } }), Transparency = ns({ { 0, 0.1 }, { 1, 1 } }),
	}), 22)
	emit(emitter(att, {
		Texture = TEX.glow, Lifetime = nr(0.3, 0.5), Speed = nr(50, 120), SpreadAngle = Vector2.new(180, 180), Drag = 9,
		Orientation = Enum.ParticleOrientation.VelocityParallel, LightEmission = 1, Brightness = 6,
		Color = cs(Color3.new(1, 0.8, 0.8), color :: Color3), Size = ns({ { 0, 0.6 }, { 1, 0 } }), Squash = ns({ { 0, 3 }, { 1, 1 } }),
	}), 22, 0.05)
	local _, ground = anchor(w, Vector3.new(pos.X, (opts.floor or pos.Y - 3) + 0.1, pos.Z), 2)
	if ground then
		emit(emitter(ground, {
			Texture = TEX.ring, Lifetime = nr(0.7), EmissionDirection = Enum.NormalId.Top,
			Orientation = Enum.ParticleOrientation.VelocityPerpendicular, LightEmission = 1, Brightness = 3,
			Color = cs(color :: Color3), Size = ns({ { 0, 2 }, { 0.5, 16 }, { 1, 22 } }), Transparency = ns({ { 0, 0 }, { 1, 1 } }),
		}), 1, 0.05)
	end
	flashLight(att, color :: Color3, 12, 8, 30, 1.0)
	if w.shake then
		w:impactFrame("black")
		w:shake("huge")
		w:tint(color :: Color3, 0.6)
	end
end

-- the last blow: a white frame, a big burst, smoke that hangs
function Fx3D.ko(w, pos: Vector3, color: Color3?)
	Fx3D.impact(w, pos, { color = color or WARM, heavy = true, scale = 1.4, noCamera = true })
	if w.shake then
		w:impactFrame("white")
		task.delay(0.12, function()
			w:impactFrame("black")
		end)
		w:shake("huge")
		w:punch(10)
	end
end

function Fx3D.victory(w, pos: Vector3, color: Color3?)
	color = color or Color3.fromRGB(255, 214, 120)
	local _, att = anchor(w, pos, 3.2)
	if not att then
		return
	end
	emit(emitter(att, {
		Texture = TEX.star, Lifetime = nr(0.8, 1.6), Speed = nr(6, 16), SpreadAngle = Vector2.new(60, 60),
		Acceleration = Vector3.new(0, -6, 0), Drag = 2, LightEmission = 1, Brightness = 5, Rotation = nr(0, 360), RotSpeed = nr(-120, 120),
		Color = cs(Color3.new(1, 1, 0.9), color :: Color3), Size = ns({ { 0, 0.9 }, { 1, 0 } }),
	}), 26)
	emit(emitter(att, {
		Texture = TEX.ring, Lifetime = nr(0.5), LockedToPart = true, LightEmission = 1, Brightness = 2,
		Color = cs(color :: Color3), Size = ns({ { 0, 1 }, { 1, 9 } }), Transparency = ns({ { 0, 0 }, { 1, 1 } }),
	}), 1)
	flashLight(att, color :: Color3, 8, 6, 20, 1.4)
end

-- a hit actor flashes white for a moment (Highlight)
function Fx3D.flashModel(model: Instance?, color: Color3?)
	if not model or not model.Parent then
		return
	end
	local h = Instance.new("Highlight")
	h.FillColor = color or Color3.new(1, 1, 1)
	h.OutlineColor = color or Color3.new(1, 1, 1)
	h.FillTransparency = 0.15
	h.OutlineTransparency = 0.2
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Adornee = model
	h.Parent = model
	animate(0.28, function(k)
		h.FillTransparency = 0.15 + 0.85 * k
		h.OutlineTransparency = 0.2 + 0.8 * k
	end, function()
		h:Destroy()
	end)
end

-- a standing aura (a boss in its last phase, someone at their limit): rising motes until stop()
-- kind: "fire" (flames) or "glow" (soft motes)
function Fx3D.aura(w, color: Color3, kind: string?)
	local handle = { stopped = false }
	local folder = folderOf(w)
	if not folder then
		function handle.move(_pos: Vector3) end
		function handle.stop() end
		return handle
	end
	local p = Instance.new("Part")
	p.Name = "Aura"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = Vector3.new(2.2, 0.2, 1.2)
	p.Parent = folder
	local pe = emitter(p, {
		Texture = if kind == "fire" then TEX.fire else TEX.glow,
		Lifetime = nr(0.8, 1.3), Speed = nr(1, 3), SpreadAngle = Vector2.new(15, 15), EmissionDirection = Enum.NormalId.Top,
		Acceleration = Vector3.new(0, 4, 0), LightEmission = 1, Brightness = 2, Rotation = nr(0, 360), RotSpeed = nr(-30, 30),
		Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Color = cs(Color3.new(1, 1, 1):Lerp(color, 0.5), color), Size = ns({ { 0, if kind == "fire" then 1.1 else 0.5 }, { 1, 0 } }),
		Transparency = ns({ { 0, 0.3 }, { 1, 1 } }),
	})
	pe.Rate = if kind == "fire" then 18 else 12
	pe.Enabled = true
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 1.6
	light.Range = 9
	light.Shadows = false
	light.Parent = p
	function handle.move(pos: Vector3)
		if not handle.stopped then
			p.CFrame = CFrame.new(pos)
		end
	end
	function handle.stop()
		if handle.stopped then
			return
		end
		handle.stopped = true
		pe.Enabled = false
		light.Enabled = false
		task.delay(1.5, function()
			pcall(p.Destroy, p)
		end)
	end
	return handle
end

return Fx3D
