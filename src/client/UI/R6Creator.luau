--[[
	THE R6 CREATOR (BitLeveling): your character for walking the live city, built on the real
	R6 rig (Hunter/R6Rig.luau). A turntable preview on the left, the options on the right in
	tabs: Body, Face, Hair, Clothes, Hunter Gear. Hair is Roblox's own hair accessories (the
	server loads one the first time someone picks it); colours are swatches. Randomize rolls a
	whole look; Save keeps it on your profile (the server checks every field).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Theme = require(script.Parent:WaitForChild("Theme"))
local C, F = Theme.colors, Theme.fonts

local Creator = {}
local open: Frame? = nil
local spinConn: RBXScriptConnection? = nil

local function make(className: string, props: any, parent: Instance?): any
	local inst = Instance.new(className)
	for k, v in props do
		(inst :: any)[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function Creator.close()
	if spinConn then
		spinConn:Disconnect()
		spinConn = nil
	end
	if open then
		open:Destroy()
		open = nil
	end
end

local SWATCH_LISTS = { SKIN = true, PALETTE = true, EYES = true, HAIR_DYES = true }

function Creator.open(gui: ScreenGui, call: (string, any?) -> any, R6Rig: any)
	Creator.close()
	local Shared = ReplicatedStorage:WaitForChild("LifeSim")
	local Looks = require(Shared:WaitForChild("Hunter"):WaitForChild("Looks"))
	local hairCache = ReplicatedStorage:WaitForChild("HunterHairCache", 5)

	local frame = make("Frame", { Name = "R6Creator", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.92, 0.88), BackgroundColor3 = C.panel, ZIndex = 30 }, gui)
	make("UISizeConstraint", { MaxSize = Vector2.new(1100, 720) }, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, frame)
	make("UIStroke", { Color = Color3.fromRGB(200, 170, 255), Transparency = 0.35, Thickness = 1.5 }, frame)
	open = frame
	make("TextLabel", { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(0.5, 0, 0, 30), BackgroundTransparency = 1, Text = "YOUR R6 HUNTER", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(210, 190, 255), FontFace = F.display, TextSize = 26 }, frame)
	make("TextLabel", { Position = UDim2.fromOffset(16, 40), Size = UDim2.new(1, -32, 0, 18), BackgroundTransparency = 1, Text = "Your look in the live city. Your rank is never chosen here: it's what you awaken at.", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, FontFace = F.ui, TextSize = 13 }, frame)

	-- the preview
	local view = make("ViewportFrame", { Position = UDim2.fromOffset(16, 66), Size = UDim2.new(0.4, -24, 1, -130), BackgroundColor3 = Color3.fromRGB(16, 20, 30), Ambient = Color3.fromRGB(150, 150, 165), LightColor = Color3.fromRGB(255, 244, 230), LightDirection = Vector3.new(-1, -1, -0.6) }, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 6) }, view)
	local worldModel = make("WorldModel", {}, view)
	local cam = make("Camera", { FieldOfView = 32 }, view)
	view.CurrentCamera = cam
	-- a floor disc and a mana glow under the feet
	local floor = make("Part", { Anchored = true, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, 7, 7), CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(40, 50, 80), Material = Enum.Material.Neon, Transparency = 0.3 }, worldModel)
	local _ = floor
	local angle = math.rad(200)
	local zoom = 1
	local rig: Model? = nil

	local look = table.clone(Looks.DEFAULT)
	local function hairFor(id: number): Instance?
		if not hairCache or id == 0 then
			return nil
		end
		local a = hairCache:FindFirstChild(tostring(id))
		return a and a:Clone()
	end
	local building = false
	local function rebuild()
		if building then
			return
		end
		building = true
		if rig then
			rig:Destroy()
		end
		local ok, m = pcall(R6Rig.build, look, { name = "Preview", hair = hairFor(look.hair) })
		if ok and m then
			for _, d in m:GetDescendants() do
				if d:IsA("BasePart") then
					d.Anchored = true
				end
			end
			m.Parent = worldModel
			rig = m
		end
		building = false
	end
	spinConn = RunService.RenderStepped:Connect(function(dt)
		angle += dt * 0.5
		local target = Vector3.new(0, 3, 0)
		local dist = 13 * zoom
		cam.CFrame = CFrame.lookAt(target + Vector3.new(math.sin(angle) * dist, 1.6, math.cos(angle) * dist), target)
	end)

	-- the options
	local tabs = make("Frame", { Position = UDim2.new(0.4, 0, 0, 66), Size = UDim2.new(0.6, -16, 0, 32), BackgroundTransparency = 1 }, frame)
	make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, tabs)
	local body = make("ScrollingFrame", { Position = UDim2.new(0.4, 0, 0, 104), Size = UDim2.new(0.6, -16, 1, -168), BackgroundTransparency = 1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0 }, frame)
	make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, body)

	local currentTab = Looks.TABS[1]
	local renderTab: () -> ()
	local function pick(field: string, value: any)
		look[field] = value
		if field == "hair" and type(value) == "number" and value > 0 and hairCache and not hairCache:FindFirstChild(tostring(value)) then
			task.spawn(function()
				local res = call("r6Hair", { id = value })
				if res and res.ok and open then
					rebuild()
				end
			end)
		end
		rebuild()
		renderTab()
	end

	local function c3(t)
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	renderTab = function()
		for _, c in body:GetChildren() do
			if not c:IsA("UIListLayout") then
				c:Destroy()
			end
		end
		for order, field in currentTab.fields do
			local section = make("Frame", { LayoutOrder = order, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, body)
			make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, section)
			make("TextLabel", { LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = string.upper(Looks.LABELS[field] or field), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, FontFace = F.display, TextSize = 13 }, section)
			local grid = make("Frame", { LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, section)
			if field == "gloves" then
				make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, grid)
				for _, opt in { { false, "None" }, { true, "Gloves" } } do
					local on = look.gloves == opt[1]
					local b = make("TextButton", { Size = UDim2.fromOffset(110, 30), BackgroundColor3 = if on then Color3.fromRGB(90, 70, 160) else C.panelHi, Text = opt[2], TextColor3 = C.text, FontFace = F.uiBold, TextSize = 13 }, grid)
					make("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
					b.Activated:Connect(function()
						pick("gloves", opt[1])
					end)
				end
				continue
			end
			local listName = Looks.FIELDS[field]
			local list = Looks[listName]
			if SWATCH_LISTS[listName] then
				make("UIGridLayout", { CellSize = UDim2.fromOffset(34, 34), CellPadding = UDim2.fromOffset(6, 6) }, grid)
				for _, o in list do
					local on = look[field] == o.id
					local b = make("TextButton", { BackgroundColor3 = if o.color then c3(o.color) else C.panelHi, Text = if o.color then "" else "N", TextColor3 = C.text, FontFace = F.uiBold, TextSize = 12, AutoButtonColor = true }, grid)
					make("UICorner", { CornerRadius = UDim.new(1, 0) }, b)
					make("UIStroke", { Color = if on then Color3.new(1, 1, 1) else C.stroke, Thickness = if on then 3 else 1 }, b)
					b.Activated:Connect(function()
						pick(field, o.id)
					end)
				end
			else
				make("UIGridLayout", { CellSize = UDim2.fromOffset(150, 30), CellPadding = UDim2.fromOffset(6, 6) }, grid)
				for _, o in list do
					local on = look[field] == o.id
					local b = make("TextButton", { BackgroundColor3 = if on then Color3.fromRGB(90, 70, 160) else C.panelHi, Text = o.name, TextColor3 = C.text, FontFace = F.ui, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd, AutoButtonColor = true }, grid)
					make("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
					b.Activated:Connect(function()
						pick(field, o.id)
					end)
				end
			end
		end
	end
	for _, t in Looks.TABS do
		local b = make("TextButton", { Size = UDim2.fromOffset(112, 32), BackgroundColor3 = C.panelHi, Text = string.upper(t.name), TextColor3 = C.text, FontFace = F.display, TextSize = 14 }, tabs)
		make("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
		b.Activated:Connect(function()
			currentTab = t
			renderTab()
		end)
	end

	-- the buttons along the bottom
	local bar = make("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -12), Size = UDim2.new(1, -32, 0, 40), BackgroundTransparency = 1 }, frame)
	make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right }, bar)
	local status = make("TextLabel", { Size = UDim2.new(1, -520, 1, 0), BackgroundTransparency = 1, Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, FontFace = F.ui, TextSize = 13 }, bar)
	local function button(text: string, color: Color3, onClick: () -> ())
		local b = make("TextButton", { Size = UDim2.fromOffset(120, 40), BackgroundColor3 = color, Text = text, TextColor3 = Color3.new(1, 1, 1), FontFace = F.display, TextSize = 15 }, bar)
		make("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
		b.Activated:Connect(onClick)
	end
	button("ZOOM", C.panelHi, function()
		zoom = if zoom > 0.7 then 0.55 else 1
	end)
	button("RANDOMIZE", Color3.fromRGB(70, 90, 140), function()
		look = Looks.random(function(a, b)
			return math.random(a, b)
		end)
		pick("hair", look.hair)
	end)
	button("SAVE", Color3.fromRGB(90, 70, 170), function()
		status.Text = "Saving..."
		local res = call("r6Save", { look = look })
		if res and res.ok then
			look = res.look or look
			status.Text = "Saved. This is how you'll look in the city."
		else
			status.Text = "Couldn't save. Try again."
		end
	end)
	button("CLOSE", C.panelHi, Creator.close)

	task.spawn(function()
		local res = call("r6Get")
		if res and res.look then
			look = res.look
			if type(look.hair) == "number" and look.hair > 0 then
				call("r6Hair", { id = look.hair })
			end
		end
		if open then
			rebuild()
			renderTab()
		end
	end)
	rebuild()
	renderTab()
end

return Creator
