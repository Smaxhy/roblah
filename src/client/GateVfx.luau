--[[
	THE GATE, DRAWN: a whirlpool standing on its edge (BitLeveling).

	Canon: a Gate is a tear in the air with a dungeon behind it; ordinary Gates are drawn blue,
	and only a Red Gate is named for its colour (it turns red once the raid is inside). There is
	no colour per rank. This module draws one as a vertical vortex:

	  rim        a ragged ring of light at the edge, turning slowly
	  arms       spiral arms winding inward, the inner ones turning faster than the outer
	             (the sense of everything being pulled toward the centre)
	  eye        a dark core with a bright event-horizon ring just around it
	  inflow     sparks drawn in from the rim, spiralling with the arms
	  glow       a soft halo behind, a pulsing light, mist at the base

		local gate = GateVfx.new(parent, CFrame, radius, { red = false, rank = 3 })
		gate:open(1.6)                 -- grow from a pinpoint
		gate:step(dt)                  -- every frame (GateVfx.stepAll does every live one)
		gate:setRed(true)              -- a Red Gate
		gate:surge(1)                  -- flare (a break, someone entering)
		gate:close(1.4)                -- collapse, then destroy itself
	All parts are client-only, anchored, non-colliding; moved in one BulkMoveTo per frame.
]]

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local GateVfx = {}
GateVfx.__index = GateVfx

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"

local PALETTES = {
	blue = {
		rim = Color3.fromRGB(120, 190, 255),
		armOuter = Color3.fromRGB(50, 110, 255),
		armInner = Color3.fromRGB(190, 230, 255),
		horizon = Color3.fromRGB(220, 245, 255),
		eye = Color3.fromRGB(4, 8, 26),
		halo = Color3.fromRGB(60, 120, 255),
		light = Color3.fromRGB(90, 160, 255),
	},
	red = {
		rim = Color3.fromRGB(255, 110, 100),
		armOuter = Color3.fromRGB(200, 20, 30),
		armInner = Color3.fromRGB(255, 190, 170),
		horizon = Color3.fromRGB(255, 220, 210),
		eye = Color3.fromRGB(24, 2, 4),
		halo = Color3.fromRGB(220, 30, 40),
		light = Color3.fromRGB(255, 70, 60),
	},
}

local live: { any } = {}

local function part(props: any, parent: Instance): BasePart
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.Neon
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

-- opts: { red: boolean?, rank: number?, arms: number?, quality: "full" | "lite" }
function GateVfx.new(parent: Instance, center: CFrame, radius: number, opts: any?): any
	opts = opts or {}
	local self = setmetatable({}, GateVfx)
	self.center = center
	self.radius = radius
	self.rank = opts.rank or 3
	self.red = opts.red == true
	self.scale = 0
	self.time = math.random() * 10
	self.surgeAmt = 0
	self.alive = true
	local lite = opts.quality == "lite"
	local pal = PALETTES[if self.red then "red" else "blue"]
	local model = Instance.new("Model")
	model.Name = "Gate"
	model.Parent = parent
	self.model = model

	-- the halo behind it, and the dark eye in front of the halo
	self.halo = part({ Name = "Halo", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.02, radius * 2.7, radius * 2.7), Color = pal.halo, Transparency = 0.82 }, model)
	-- the basin: the dark water the arms turn on (gaps between the arms read as depth)
	self.backHalo = part({ Name = "Basin", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.05, radius * 2.05, radius * 2.05), Color = pal.eye:Lerp(pal.armOuter, 0.22), Material = Enum.Material.SmoothPlastic, Transparency = 0.08 }, model)
	self.eye = part({ Name = "Eye", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, radius * 0.5, radius * 0.5), Color = pal.eye, Material = Enum.Material.SmoothPlastic, Transparency = 0 }, model)

	-- the segments that move every frame: { part, kind, ... }
	self.segs = {}
	local function seg(kind: string, data: any, size: Vector3, color: Color3, transparency: number)
		local p = part({ Name = kind, Size = size, Color = color, Transparency = transparency }, model)
		data.part = p
		data.kind = kind
		data.size = size
		table.insert(self.segs, data)
		return p
	end

	-- the rim: a ragged ring, each piece a little different
	local rimN = if lite then 22 else 34
	for i = 0, rimN - 1 do
		local a = i / rimN * math.pi * 2
		local w = radius * 2 * math.pi / rimN * 1.25
		seg("Rim", { a = a, r = radius * (0.97 + math.random() * 0.06), wob = math.random() * 6 }, Vector3.new(w, 0.35 + math.random() * 0.35, 0.4), pal.rim, 0.05)
	end
	-- spiral arms: outer (slow) and inner (fast), winding in to the eye
	local function arms(count: number, segments: number, r0: number, r1: number, twist: number, speed: number, layer: string)
		for a = 0, count - 1 do
			local base = a / count * math.pi * 2
			for i = 0, segments - 1 do
				local u = i / math.max(1, segments - 1)
				local r = radius * (r0 + (r1 - r0) * u)
				local len = radius * (0.42 - 0.24 * u) * (r0 - r1 + 0.4)
				local width = 0.34 * (1 - u * 0.5) * math.max(0.6, radius / 10)
				local color = pal.armOuter:Lerp(pal.armInner, u)
				seg(layer, { base = base, u = u, r = r, twist = twist, speed = speed }, Vector3.new(math.max(0.4, len), width, 0.34), color, 0.05 + (1 - u) * 0.18)
			end
		end
	end
	arms(if lite then 4 else 5, if lite then 9 else 13, 0.95, 0.4, 2.9, 0.55, "ArmOuter")
	arms(if lite then 3 else 4, if lite then 7 else 10, 0.58, 0.2, 2.5, 1.35, "ArmInner")
	-- the event horizon: a bright thin ring right around the eye
	local horN = if lite then 14 else 20
	for i = 0, horN - 1 do
		local a = i / horN * math.pi * 2
		seg("Horizon", { a = a, r = radius * 0.27 }, Vector3.new(radius * 0.27 * 2 * math.pi / horN * 1.15, 0.22, 0.44), pal.horizon, 0)
	end

	-- the core: a holder for the light and the inflow emitters, turned with the arms
	local core = part({ Name = "Core", Size = Vector3.one * 0.2, Transparency = 1 }, model)
	self.core = core
	self.light = Instance.new("PointLight")
	self.light.Color = pal.light
	self.light.Range = 24 + self.rank * 8
	self.light.Brightness = 3
	self.light.Shadows = false
	self.light.Parent = core
	-- inflow: sparks born on the rim, flying at the eye, swept round with the core
	self.inflow = {}
	local emitN = if lite then 4 else 8
	for i = 0, emitN - 1 do
		local a = i / emitN * math.pi * 2
		local att = Instance.new("Attachment")
		-- +Y of the attachment points from the rim to the eye
		att.CFrame = CFrame.new(math.cos(a) * radius * 0.95, math.sin(a) * radius * 0.95, 0.1) * CFrame.Angles(0, 0, a + math.pi / 2)
		att.Parent = core
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = SPARKLE
		pe.Color = ColorSequence.new(pal.rim, pal.horizon)
		pe.LightEmission = 1
		pe.EmissionDirection = Enum.NormalId.Top
		pe.Speed = NumberRange.new(radius * 0.7, radius * 1.1)
		pe.Lifetime = NumberRange.new(0.6, 0.9)
		pe.SpreadAngle = Vector2.new(14, 14)
		pe.Rate = (if lite then 8 else 14) + self.rank * 3
		pe.LockedToPart = true
		pe.Drag = 0.6
		pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.05) })
		pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.8, 0.1), NumberSequenceKeypoint.new(1, 1) })
		pe.Parent = att
		table.insert(self.inflow, pe)
	end
	-- mist at the base and a slow cloud of motes around it
	local base = Instance.new("Attachment")
	base.Position = Vector3.new(0, -radius * 1.02, 0)
	base.Parent = core
	local mist = Instance.new("ParticleEmitter")
	mist.Texture = SMOKE
	mist.Color = ColorSequence.new(pal.halo:Lerp(Color3.new(1, 1, 1), 0.5))
	mist.LightEmission = 0.3
	mist.Rate = if lite then 3 else 6
	mist.Lifetime = NumberRange.new(3, 5)
	mist.Speed = NumberRange.new(0.5, 1.5)
	mist.SpreadAngle = Vector2.new(180, 15)
	mist.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, radius * 0.35), NumberSequenceKeypoint.new(1, radius * 0.8) })
	mist.Transparency = NumberSequence.new(0.78, 1)
	mist.Parent = base
	self.mist = mist
	local motes = Instance.new("ParticleEmitter")
	motes.Texture = SPARKLE
	motes.Color = ColorSequence.new(pal.rim)
	motes.LightEmission = 1
	motes.Rate = 6 + self.rank * 2
	motes.Lifetime = NumberRange.new(2, 3.5)
	motes.Speed = NumberRange.new(0.3, 1)
	motes.SpreadAngle = Vector2.new(180, 180)
	motes.Size = NumberSequence.new(0.25, 0)
	motes.Shape = Enum.ParticleEmitterShape.Sphere
	motes.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	motes.Parent = core
	self.motes = motes

	self.parts = {}
	for _, s in self.segs do
		table.insert(self.parts, s.part)
	end
	table.insert(self.parts, self.halo)
	table.insert(self.parts, self.backHalo)
	table.insert(self.parts, self.eye)
	table.insert(self.parts, core)
	self.cframes = table.create(#self.parts)
	table.insert(live, self)
	self:step(0)
	return self
end

function GateVfx:setRed(on: boolean)
	if self.red == on then
		return
	end
	self.red = on
	local pal = PALETTES[if on then "red" else "blue"]
	for _, s in self.segs do
		local p = s.part
		if s.kind == "Rim" then
			p.Color = pal.rim
		elseif s.kind == "Horizon" then
			p.Color = pal.horizon
		else
			p.Color = pal.armOuter:Lerp(pal.armInner, s.u or 0)
		end
	end
	self.halo.Color = pal.halo
	self.backHalo.Color = pal.eye:Lerp(pal.armOuter, 0.22)
	self.eye.Color = pal.eye
	self.light.Color = pal.light
	for _, pe in self.inflow do
		pe.Color = ColorSequence.new(pal.rim, pal.horizon)
	end
	self.motes.Color = ColorSequence.new(pal.rim)
	self.mist.Color = ColorSequence.new(pal.halo:Lerp(Color3.new(1, 1, 1), 0.5))
	self:surge(1.2)
end

function GateVfx:surge(amount: number)
	self.surgeAmt = math.max(self.surgeAmt, amount)
	for _, pe in self.inflow do
		pe:Emit(math.floor(6 * amount))
	end
end

function GateVfx:open(seconds: number?)
	self.opening = { t = 0, d = seconds or 1.6 }
end

function GateVfx:close(seconds: number?, after: (() -> ())?)
	self.closing = { t = 0, d = seconds or 1.4, after = after, from = self.scale }
	for _, pe in self.inflow do
		pe.Rate = 0
	end
	self.mist.Rate = 0
	self.motes:Emit(40)
end

function GateVfx:destroy()
	self.alive = false
	local i = table.find(live, self)
	if i then
		table.remove(live, i)
	end
	self.model:Destroy()
end

local function backOut(t: number): number
	local c1, c3 = 1.70158, 2.70158
	return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

function GateVfx:step(dt: number)
	if not self.alive then
		return
	end
	self.time += dt
	if self.opening then
		self.opening.t += dt
		local k = math.clamp(self.opening.t / self.opening.d, 0, 1)
		self.scale = backOut(k)
		if k >= 1 then
			self.opening = nil
			self.scale = 1
		end
	elseif self.closing then
		self.closing.t += dt
		local k = math.clamp(self.closing.t / self.closing.d, 0, 1)
		-- it swells a little, then pinches shut
		self.scale = self.closing.from * (if k < 0.25 then 1 + k * 0.6 else (1.15 * (1 - (k - 0.25) / 0.75)))
		if k >= 1 then
			local after = self.closing.after
			self:destroy()
			if after then
				after()
			end
			return
		end
	elseif self.scale == 0 then
		self.scale = 1
	end
	self.surgeAmt = math.max(0, self.surgeAmt - dt * 1.2)
	local t, s, R = self.time, math.max(0.001, self.scale), self.radius
	local surge = 1 + self.surgeAmt * 0.12
	local spin = 1 + self.surgeAmt * 1.5
	local C = self.center
	-- the plane of the Gate: X right, Y up, Z out of the face
	local i = 0
	local cfs = self.cframes
	for _, sg in self.segs do
		i += 1
		local cf
		if sg.kind == "Rim" then
			local a = sg.a + t * 0.22 * spin
			local r = sg.r * s * surge * (1 + math.sin(t * 3 + sg.wob) * 0.025)
			cf = C * CFrame.new(math.cos(a) * r, math.sin(a) * r, 0) * CFrame.Angles(0, 0, a + math.pi / 2)
		elseif sg.kind == "Horizon" then
			local a = sg.a + t * 2.4 * spin
			local r = sg.r * s * (1 + math.sin(t * 7 + sg.a * 3) * 0.04)
			cf = C * CFrame.new(math.cos(a) * r, math.sin(a) * r, 0) * CFrame.Angles(0, 0, a + math.pi / 2)
		else
			-- a point on a spiral arm: further in is further round, and the inner layer is faster
			local a = sg.base + sg.u * sg.twist + t * sg.speed * spin + math.sin(t * 1.7 + sg.u * 5 + sg.base) * 0.05
			local r = sg.r * s * surge
			-- the tangent of the spiral (pointing along the arm, inward), for the streak's angle
			local lean = math.atan2(1, sg.twist * 0.9)
			cf = C * CFrame.new(math.cos(a) * r, math.sin(a) * r, 0) * CFrame.Angles(0, 0, a + math.pi / 2 + lean)
		end
		cfs[i] = cf
	end
	-- halo, back halo and eye face out of the Gate (a cylinder's axis is its X)
	local face = C * CFrame.Angles(0, math.pi / 2, 0)
	local pulse = 1 + math.sin(t * 2.2) * 0.04
	-- (every layer is centred on the Gate's plane, so it reads the same from either side;
	-- the arms, rim and horizon are thicker than the basin and poke through both faces)
	cfs[i + 1] = face
	cfs[i + 2] = face
	cfs[i + 3] = face
	cfs[i + 4] = C * CFrame.Angles(0, 0, t * 1.1 * spin)
	self.halo.Size = Vector3.new(0.02, R * 2.7 * s * pulse, R * 2.7 * s * pulse)
	self.backHalo.Size = Vector3.new(0.05, R * 2.05 * s, R * 2.05 * s)
	self.eye.Size = Vector3.new(0.3, R * 0.5 * s * (1 - self.surgeAmt * 0.2), R * 0.5 * s * (1 - self.surgeAmt * 0.2))
	for k, sg in self.segs do
		local sz = sg.size
		sg.part.Size = Vector3.new(sz.X * s, sz.Y * math.min(1, s * 1.2), sz.Z)
		local _ = k
	end
	-- (a Gate in a ViewportFrame's WorldModel moves in that world)
	local world = self.world or self.model:FindFirstAncestorWhichIsA("WorldRoot") or Workspace
	self.world = world
	world:BulkMoveTo(self.parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
	self.light.Brightness = (2.6 + self.rank * 0.35) * pulse * (1 + self.surgeAmt) * s
end

function GateVfx.stepAll(dt: number)
	for _, g in table.clone(live) do
		g:step(dt)
	end
end

-- one shared stepper (anything made here animates without the caller doing anything)
local stepping = false
function GateVfx.autoStep()
	if stepping then
		return
	end
	stepping = true
	RunService.RenderStepped:Connect(GateVfx.stepAll)
end

-- a white-blue flash at a point (someone going in, a Gate opening)
function GateVfx.flash(parent: Instance, at: Vector3, color: Color3, size: number, life: number)
	local p = part({ Name = "Flash", Shape = Enum.PartType.Ball, Size = Vector3.one * size * 0.25, Position = at, Color = color, Transparency = 0.05 }, parent)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = size * 3
	light.Brightness = 5
	light.Parent = p
	TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * size, Transparency = 1 }):Play()
	TweenService:Create(light, TweenInfo.new(life), { Brightness = 0 }):Play()
	task.delay(life + 0.1, function()
		p:Destroy()
	end)
end

return GateVfx
