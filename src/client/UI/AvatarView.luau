--[[
	AvatarView: draws an Engine/Avatar figure inside a ViewportFrame.

		local view = AvatarView.new(ctx, {
			size = UDim2, position = UDim2?, anchor = Vector2?, order = number?,
			framing = "portrait" | "full",   -- head and shoulders, or the whole figure
			spin = false,                    -- slowly turn (the character creator)
			chart = false,                   -- mugshot height lines behind the figure
			background = Color3?, zIndex = number?,
		})
		view:set(appearance)   -- rebuilds only when the figure would change
		view.frame             -- the holder Frame (parent it where you like)

	The figure's parts come from ctx.info.avatar (cosmetics and the looks of
	gear, conditions and forms), sent by the server on hello.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)

local Avatar = require(ReplicatedStorage:WaitForChild("LifeSim"):WaitForChild("Engine"):WaitForChild("Avatar"))

local C = Theme.colors
local new = Kit.new

local MATERIALS = {
	plastic = Enum.Material.SmoothPlastic,
	neon = Enum.Material.Neon,
	metal = Enum.Material.Metal,
	fabric = Enum.Material.Fabric,
	wood = Enum.Material.Wood,
}

local AvatarView = {}
AvatarView.__index = AvatarView
AvatarView.Avatar = Avatar -- the shared builder (catalog helpers for the creator)

local function makePart(spec)
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
	local cf = CFrame.new(spec.pos[1], spec.pos[2], spec.pos[3])
	if spec.rot then
		cf *= CFrame.Angles(math.rad(spec.rot[1]), math.rad(spec.rot[2]), math.rad(spec.rot[3]))
	end
	local size = spec.size
	if spec.shape == "ball" then
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(size[1], size[1], size[1])
	elseif spec.shape == "cyl" then
		-- Roblox cylinders run along X; turn them upright
		part.Shape = Enum.PartType.Cylinder
		part.Size = Vector3.new(size[2], size[1], size[3])
		cf *= CFrame.Angles(0, 0, math.rad(90))
	else
		part.Size = Vector3.new(size[1], size[2], size[3])
	end
	part.CFrame = cf
	return part
end

function AvatarView.new(ctx, opts)
	local self = setmetatable({}, AvatarView)
	self.ctx = ctx
	self.framing = opts.framing or "portrait"
	self.angle = opts.angle or -18
	self.signature = nil
	self.info = nil

	local holder = new("Frame", {
		Name = "Avatar",
		BackgroundColor3 = opts.background or C.panelLo,
		BackgroundTransparency = if opts.background == false then 1 else 0,
		BorderSizePixel = 0,
		Size = opts.size,
		Position = opts.position,
		AnchorPoint = opts.anchor,
		LayoutOrder = opts.order or 0,
		ClipsDescendants = true,
		ZIndex = opts.zIndex or 1,
	}, { Kit.corner(2) })
	if opts.chart then
		-- mugshot height chart: faint lines behind the figure
		for i = 1, 5 do
			new("Frame", {
				BackgroundColor3 = C.strokeHi,
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, i / 6, 0),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = holder.ZIndex,
				Parent = holder,
			})
		end
	end
	local viewport = new("ViewportFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Ambient = Color3.fromRGB(150, 146, 152),
		LightColor = Color3.fromRGB(255, 240, 222),
		LightDirection = Vector3.new(0.45, -0.9, 0.85),
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

	if opts.spin then
		-- turn slowly while shown; stop for good once removed from the screen
		task.spawn(function()
			local shown = false
			while true do
				task.wait()
				if holder.Parent then
					shown = true
					self.angle = (self.angle + 0.6) % 360
					self:aim()
				elseif shown then
					break
				end
			end
		end)
	end
	return self
end

-- Points the camera at the figure for this view's framing.
function AvatarView:aim()
	local info = self.info
	if not info then
		return
	end
	local target, dist
	if self.framing == "full" then
		local h = math.max(info.height, info.top or 0) -- room for a tall hat
		target = Vector3.new(0, h * 0.5, 0)
		dist = h * 2.25
	else
		target = Vector3.new(0, info.headY - info.headSize * 0.32, 0)
		dist = info.headSize * 4.6
	end
	local offset = CFrame.Angles(0, math.rad(self.angle or 0), 0) * Vector3.new(0, dist * 0.12, -dist)
	self.camera.CFrame = CFrame.lookAt(target + offset, target)
end

function AvatarView:set(appearance)
	if not appearance then
		return
	end
	local sig = Avatar.signature(appearance)
	if sig == self.signature then
		return
	end
	self.signature = sig
	local pack = self.ctx.info and self.ctx.info.avatar
	if not pack then
		return
	end
	self.model:ClearAllChildren()
	local parts, info = Avatar.build(pack, appearance, { portrait = self.framing == "portrait", ground = self.framing == "full" })
	for _, spec in parts do
		makePart(spec).Parent = self.model
	end
	self.info = info
	self:aim()
end

return AvatarView
