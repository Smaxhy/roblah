--[[
	CreatureView: draws an Engine/Creatures creature inside a ViewportFrame. It has the same
	surface as AvatarView, so a caller can make one or the other and carry on.

		local view = CreatureView.new(ctx, {
			size = UDim2, position = UDim2?, anchor = Vector2?, order = number?,
			framing = "portrait" | "full",   -- the face, or the whole creature on its floor
			background = Color3? | false, zIndex = number?,
			angle = number?,                 -- camera angle in degrees. Left out, the creature's own:
			                                 -- it faces screen-left when shown whole (a foe on the
			                                 -- right of the stage) and screen-right in a portrait
			still = false,                   -- true: no idle motion (a list of many small faces)
		})
		view:set(def)       -- def = { shape, color?, eye?, seed?, name?, pose? } (see Engine/Creatures);
		                    -- a foe table from the fight screen works as it is. Rebuilds only when
		                    -- the creature would change; a new pose of the same creature eases over
		view:pose("strike") -- the same creature in another pose: "idle" | "strike" | "hurt" | "down"
		view.frame          -- the holder Frame (parent it where you like)
		view:aim()          -- points the camera again (after changing view.angle or view.framing)

	Idle motion (breathing, wings, a blinking lamp, twitching legs) runs on one Heartbeat
	connection per view, about 30 times a second. It stops for good once the view has left
	the screen, and it never minds parts that have gone missing.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)

local Creatures = require(ReplicatedStorage:WaitForChild("LifeSim"):WaitForChild("Engine"):WaitForChild("Creatures"))

local C = Theme.colors
local new = Kit.new

local MATERIALS = {
	plastic = Enum.Material.SmoothPlastic,
	neon = Enum.Material.Neon,
	metal = Enum.Material.Metal,
	fabric = Enum.Material.Fabric,
	wood = Enum.Material.Wood,
}

local TAU = math.pi * 2
local STEP = 1 / 30 -- idle motion's frame time
local KEY_TURN = 46 -- the light sits this far round from the camera, toward the side the creature faces
-- how long a change of pose takes
local EASE = { idle = 0.26, strike = 0.11, hurt = 0.09, down = 0.5 }

local CreatureView = {}
CreatureView.__index = CreatureView
CreatureView.Creatures = Creatures -- the shared builder (shape ids, variants, poses)

local function cframeOf(spec): CFrame
	local cf = CFrame.new(spec.pos[1], spec.pos[2], spec.pos[3])
	if spec.rot then
		cf *= CFrame.Angles(math.rad(spec.rot[1]), math.rad(spec.rot[2]), math.rad(spec.rot[3]))
	end
	if spec.shape == "cyl" then
		-- Roblox cylinders run along X; turn them upright
		cf *= CFrame.Angles(0, 0, math.rad(90))
	end
	return cf
end

local function sizeOf(spec): Vector3
	local size = spec.size
	if spec.shape == "ball" then
		return Vector3.new(size[1], size[1], size[1])
	elseif spec.shape == "cyl" then
		return Vector3.new(size[2], size[1], size[3])
	end
	return Vector3.new(size[1], size[2], size[3])
end

local function makePart(spec): Part
	local part = Instance.new("Part")
	part.Name = spec.name or "Part"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = MATERIALS[spec.material] or Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(spec.color[1], spec.color[2], spec.color[3])
	if spec.transparency then
		part.Transparency = spec.transparency
	end
	if spec.shape == "ball" then
		part.Shape = Enum.PartType.Ball
	elseif spec.shape == "cyl" then
		part.Shape = Enum.PartType.Cylinder
	end
	part.Size = sizeOf(spec)
	part.CFrame = cframeOf(spec)
	return part
end

function CreatureView.new(ctx, opts)
	opts = opts or {}
	local self = setmetatable({}, CreatureView)
	self.ctx = ctx
	self.framing = opts.framing or "portrait"
	self.angle = opts.angle -- nil: the creature's own
	self.still = opts.still == true
	self.size = opts.size
	self.signature = nil
	self.info = nil
	self.def = nil
	self.items = {} -- one per part: { inst, base, group, ... }
	self.groups = {} -- the moving groups, parents first
	self.clock = 0
	self.since = 0
	self.blend = nil
	self.conn = nil

	local holder = new("Frame", {
		Name = "Creature",
		BackgroundColor3 = if typeof(opts.background) == "Color3" then opts.background else C.panelLo,
		BackgroundTransparency = if opts.background == false then 1 else 0,
		BorderSizePixel = 0,
		Size = opts.size,
		Position = opts.position,
		AnchorPoint = opts.anchor,
		LayoutOrder = opts.order or 0,
		ClipsDescendants = true,
		ZIndex = opts.zIndex or 1,
	}, { Kit.corner(2) })
	-- a glow behind it, in whatever color it's lit with (set when a creature is set)
	local glow = new("Frame", {
		Name = "Glow",
		BackgroundColor3 = Color3.fromRGB(200, 60, 50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromScale(0.9, 0.9),
		ZIndex = opts.zIndex or 1,
		Parent = holder,
	}, {
		new("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
		new("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.25), NumberSequenceKeypoint.new(1, 1) }),
		}),
	})
	self.glow = glow
	local viewport = new("ViewportFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Ambient = Color3.fromRGB(104, 108, 132),
		LightColor = Color3.fromRGB(255, 236, 208),
		LightDirection = Vector3.new(-0.45, -0.9, 0.85),
		ZIndex = holder.ZIndex,
		Parent = holder,
	})
	local camera = new("Camera", { FieldOfView = 30, Parent = viewport })
	viewport.CurrentCamera = camera
	local model = new("Model", { Name = "Figure", Parent = viewport })

	self.frame = holder
	self.viewport = viewport
	self.camera = camera
	self.model = model
	return self
end

-- width over height of the picture, as well as it can be known
local function aspectOf(self): number
	local ok, abs = pcall(function()
		return self.viewport.AbsoluteSize
	end)
	if ok and typeof(abs) == "Vector2" and abs.X >= 1 and abs.Y >= 1 then
		return abs.X / abs.Y
	end
	local size = self.size
	if typeof(size) == "UDim2" and size.X.Scale == 0 and size.Y.Scale == 0 and size.X.Offset > 0 and size.Y.Offset > 0 then
		return size.X.Offset / size.Y.Offset
	end
	return 1.2
end

-- Points the camera at the creature for this view's framing.
function CreatureView:aim()
	local info = self.info
	if not info then
		return
	end
	local portrait = self.framing ~= "full"
	local angle = self.angle
	if angle == nil then
		angle = info.angle or 30
		if portrait then
			angle = -math.min(angle, 28) -- a face in a dialogue box looks toward the words
		end
	end
	local turn = math.rad(angle)
	local aspect = aspectOf(self)
	self.aspect = aspect
	self.aimed = angle

	local target, dist
	if portrait then
		local focus = info.focus or { 0, info.headY, 0 }
		target = Vector3.new(focus[1], info.headY - info.headSize * 0.32, focus[3])
		dist = info.headSize * 4.6
	else
		-- as tall as an Avatar's full view, so both stand on the same floor line; wider or
		-- deeper creatures push the camera back until they fit across too
		local h = math.max(info.height, info.top or 0)
		local size = info.size
		if size then
			local across = size[1] * math.abs(math.cos(turn)) + size[3] * math.abs(math.sin(turn))
			local deep = size[1] * math.abs(math.sin(turn)) + size[3] * math.abs(math.cos(turn))
			h = math.max(h, (across + deep * 0.22) / (1.1 * aspect))
		end
		target = Vector3.new(0, h * 0.5, 0)
		dist = h * 2.25
	end
	local offset = CFrame.Angles(0, turn, 0) * Vector3.new(0, dist * 0.12, -dist)
	self.camera.CFrame = CFrame.lookAt(target + offset, target)

	-- the key light comes from over the camera's shoulder, on the side the creature faces
	local from = -turn + math.rad(if angle >= 0 then KEY_TURN else -KEY_TURN)
	self.viewport.LightDirection = Vector3.new(-0.962 * math.sin(from), -0.9, 0.962 * math.cos(from))
end

-- ── idle motion ─────────────────────────────────────────────────────────────

-- a quick there-and-back once every 1/rate seconds, each one a little different
local function twitchAt(t: number, rate: number, phase: number): number
	local u = t * rate + phase
	local n = math.floor(u)
	local x = (u - n) / math.max(rate, 1e-3) -- seconds into this period
	local len = 0.32
	if x >= len then
		return 0
	end
	local size = 0.55 + 0.45 * ((n * 0.618034) % 1)
	return math.sin(math.pi * x / len) * size
end

-- how far a light is toward "off" (0 lit, 1 dark)
local function dimAt(m, t: number): number
	local kind = m.kind
	if kind == "blink" then
		-- lit, with a short dark gap each period (duty: the share of the period spent dark)
		local u = (t * m.rate + m.phase) % 1
		return if u < (m.duty or 0.07) then 1 else 0
	elseif kind == "pulse" then
		return (m.depth or 0.6) * (0.5 - 0.5 * math.sin(TAU * (t * m.rate + m.phase)))
	else -- flicker: a failing lamp
		local n = math.noise(t * m.rate * 3.1 + m.phase * 17.3, m.phase * 5.7)
		return if n > 0.3 then 0.9 elseif n > 0.18 then 0.45 else 0
	end
end

local function step(self, dt: number)
	local items = self.items
	local blend = self.blend
	self.clock += dt
	self.since += dt
	if blend then
		blend.t += dt
		local a = math.clamp(blend.t / blend.time, 0, 1)
		-- a drop gathers speed; everything else arrives fast and settles
		local e = if blend.fall then a * a else 1 - (1 - a) ^ 3
		for _, it in items do
			if it.from then
				it.base = it.from:Lerp(it.to, e)
			end
		end
		if a >= 1 then
			for _, it in items do
				if it.from then
					it.base = it.to
					it.from = nil
				end
			end
			self.blend = nil
		end
	elseif self.since < STEP then
		return
	end
	self.since = 0

	local t = self.clock
	local groups = self.groups
	for _, g in groups do
		local cf: CFrame? = nil
		local dim: number? = nil
		for _, m in g.motions do
			local kind = m.kind
			if kind == "swing" or kind == "twitch" or kind == "spin" then
				local a
				if kind == "swing" then
					a = math.rad(m.amp) * math.sin(TAU * (t * m.rate + m.phase))
				elseif kind == "twitch" then
					a = math.rad(m.amp) * twitchAt(t, m.rate, m.phase)
				else
					a = TAU * ((t * m.rate + m.phase) % 1)
				end
				if a ~= 0 then
					local r = g.to * CFrame.fromAxisAngle(m.axis, a) * g.back
					cf = if cf then cf * r else r
				end
			elseif kind == "bob" then
				local r = CFrame.new(m.dir * (m.amp * math.sin(TAU * (t * m.rate + m.phase))))
				cf = if cf then r * cf else r
			elseif kind == "blink" or kind == "pulse" or kind == "flicker" then
				dim = math.max(dim or 0, dimAt(m, t))
			end
		end
		local parent = g.parent
		if parent and parent.world then
			cf = if cf then parent.world * cf else parent.world
		end
		g.world = cf
		g.dim = dim
	end
	for _, it in items do
		local g = it.group
		local inst = it.inst
		if (g or blend) and inst.Parent then
			local world = g and g.world
			inst.CFrame = if world then world * it.base else it.base
			if it.lit and g then
				local dim = g.dim or 0
				if dim ~= it.dim then
					it.dim = dim
					inst.Color = it.lit:Lerp(it.off or it.dark, dim)
				end
			end
		end
	end
end

-- is the holder on screen (or at least in a tree)?
local function shown(holder: Instance): boolean
	if holder.Parent == nil then
		return false
	end
	if typeof(game) == "Instance" then
		return holder:IsDescendantOf(game)
	end
	return true
end

function CreatureView:_stop()
	local conn = self.conn
	if conn then
		self.conn = nil
		conn:Disconnect()
	end
end

function CreatureView:_run()
	if self.conn then
		return
	end
	local seen, waited = false, 0
	self.conn = RunService.Heartbeat:Connect(function(dt: number)
		if not shown(self.frame) then
			-- gone for good once it has been on screen; give a view that was never shown a while
			waited += dt
			if seen or waited > 30 then
				self:_stop()
			end
			return
		end
		seen = true
		if self.aspect ~= aspectOf(self) then
			self:aim() -- the picture changed shape (first layout, a resized window)
		end
		local ok, err = pcall(step, self, dt)
		if not ok then
			self.animError = err
			self:_stop()
		end
	end)
end

-- ── building ────────────────────────────────────────────────────────────────

local function colorOf(c): Color3
	return Color3.fromRGB(c[1], c[2], c[3])
end

-- everything about a def except its pose
local function identityOf(def): string
	local same = table.clone(def)
	same.pose = nil
	return Creatures.signature(same)
end

function CreatureView:set(def)
	if type(def) ~= "table" then
		return
	end
	local sig = Creatures.signature(def)
	if sig == self.signature then
		return
	end
	self.signature = sig
	self.def = def
	local parts, info = Creatures.build(def, { ground = self.framing == "full" })
	-- the glow behind it takes the color of its first lit part (its eyes, its lamp)
	if self.glow then
		local lit = nil
		for _, p in parts do
			if p.material == "neon" and p.color then
				lit = p.color
				break
			end
		end
		self.glow.BackgroundColor3 = if lit then Color3.fromRGB(lit[1], lit[2], lit[3]) else Color3.fromRGB(120, 124, 150)
		self.glow.BackgroundTransparency = if self.framing == "full" then 0.72 else 0.8
	end

	-- the moving groups
	local groups, byTag = {}, {}
	if not self.still then
		for _, a in info.anim or {} do
			local g = {
				tag = a.tag,
				parent = a.parent and byTag[a.parent] or nil,
				to = CFrame.new(a.pivot[1], a.pivot[2], a.pivot[3]),
				back = CFrame.new(-a.pivot[1], -a.pivot[2], -a.pivot[3]),
				motions = {},
				world = nil,
				dim = nil,
			}
			for _, m in a.motions do
				local copy = table.clone(m)
				if m.axis then
					copy.axis = Vector3.new(m.axis[1], m.axis[2], m.axis[3])
				end
				if m.dir then
					copy.dir = Vector3.new(m.dir[1], m.dir[2], m.dir[3])
				end
				if m.off then
					g.off = colorOf(m.off)
				end
				table.insert(g.motions, copy)
			end
			byTag[a.tag] = g
			table.insert(groups, g)
		end
	end

	-- the same creature in a new pose keeps its parts and eases them over
	local old = self.items
	local identity = identityOf(def)
	local ease = identity == self.identity and #old == #parts and #old > 0
	if ease then
		for i, spec in parts do
			local it = old[i]
			if it.name ~= spec.name or it.shape ~= spec.shape or it.inst.Parent ~= self.model then
				ease = false
				break
			end
		end
	end
	self.identity = identity

	local items = {}
	if ease then
		for i, spec in parts do
			local it = old[i]
			local inst = it.inst
			inst.Size = sizeOf(spec)
			inst.Material = MATERIALS[spec.material] or Enum.Material.SmoothPlastic
			inst.Color = colorOf(spec.color)
			it.from = it.base
			it.to = cframeOf(spec)
			items[i] = it
		end
		self.blend = { t = 0, time = EASE[info.pose] or 0.2, fall = info.pose == "down" }
	else
		self.model:ClearAllChildren()
		for i, spec in parts do
			local inst = makePart(spec)
			inst.Parent = self.model
			items[i] = { inst = inst, name = spec.name, shape = spec.shape, base = inst.CFrame }
		end
		self.blend = nil
	end
	for i, spec in parts do
		local it = items[i]
		it.group = spec.anim and byTag[spec.anim] or nil
		it.dim = 0
		it.lit, it.dark, it.off = nil, nil, nil
		if spec.material == "neon" and it.group then
			it.lit = colorOf(spec.color)
			it.dark = it.lit:Lerp(Color3.new(0, 0, 0), 0.78)
			it.off = it.group.off
		end
	end
	self.items = items
	self.groups = groups
	self.info = info
	self:aim()
	if #groups > 0 or self.blend then
		self:_run()
	end
end

-- The creature already shown, in another pose.
function CreatureView:pose(name: string)
	local def = self.def
	if def and def.pose ~= name then
		local next = table.clone(def)
		next.pose = name
		self:set(next)
	end
end

return CreatureView
