--[[
	THE R6 CREATOR (BitLeveling): your character for walking the live city, built on the real
	R6 rig (Hunter/R6Rig.luau).

	Left, a lit stage: the rig on a glowing dais, turning slowly; drag to turn it, scroll or
	pinch to zoom, BODY / FACE to frame it. Under it, the class dice: roll an outfit for any
	class (or a civilian) and keep your face, skin and hair.
	Right, the tabs (Looks.TABS):
		Presets      whole outfits on class shelves (Fighter .. Healer from E-rank to S-rank,
		             Association, Guild, Civilian, Iconic), each card a little live preview
		Body, Face, Head, Outfit, Gear
		             every option; each piece is followed by its own colour swatches
		Accessories  rings, amulets, bracers, belts... by class with their grade (one per slot,
		             four at once)
		Colours      every colour on one page
	Along the bottom: WEAR MY CLASS (your class's outfit at your rank), UNDO, RANDOM, SAVE.

		Creator.open(gui, call, R6Rig, opts?)   opts.tab / opts.cat open on a tab and a shelf
		Creator.close()
	Server calls (unchanged): r6Get -> { look, rank, class? }, r6Save { look }, r6Hair { id }.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent:WaitForChild("Theme"))
local C, F = Theme.colors, Theme.fonts

local Creator = {}
local open: Frame? = nil
local conns: { any } = {}

local ACCENT = Color3.fromRGB(200, 170, 255)
local ACCENT_DEEP = Color3.fromRGB(98, 72, 176)
local INK = Color3.fromRGB(10, 12, 20)
local CARD = Color3.fromRGB(22, 25, 36)
local CARD_HI = Color3.fromRGB(34, 38, 56)
local GOLDISH = Color3.fromRGB(240, 210, 130)

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
local function corner(inst: Instance, r: number?)
	make("UICorner", { CornerRadius = if r and r >= 100 then UDim.new(1, 0) else UDim.new(0, r or 6) }, inst)
end
local function stroke(inst: Instance, color: Color3, t: number?, thick: number?)
	make("UIStroke", { Color = color, Transparency = t or 0, Thickness = thick or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, inst)
end
local function pad(inst: Instance, l: number, t: number?, r: number?, b: number?)
	make("UIPadding", { PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t or l), PaddingRight = UDim.new(0, r or l), PaddingBottom = UDim.new(0, b or t or l) }, inst)
end
-- (signals the test harness may not have are skipped quietly)
local function connect(obj: any, event: string, fn: (...any) -> ())
	local ok, c = pcall(function()
		return obj[event]:Connect(fn)
	end)
	if ok and c then
		table.insert(conns, c)
	end
end
-- a camera at `eye` looking at `target` (built from its axes: the same everywhere the rig is drawn)
local function lookAt(eye: Vector3, target: Vector3): CFrame
	local look = (target - eye).Unit
	local right = look:Cross(Vector3.new(0, 1, 0)).Unit
	local up = right:Cross(look)
	return CFrame.new(eye.X, eye.Y, eye.Z, right.X, up.X, -look.X, right.Y, up.Y, -look.Y, right.Z, up.Z, -look.Z)
end
local function c3(t: { number }?): Color3
	local v = t or { 200, 200, 200 }
	return Color3.fromRGB(v[1], v[2], v[3])
end

function Creator.close()
	for _, c in conns do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(conns)
	if open then
		open:Destroy()
		open = nil
	end
end

local SWATCH_LISTS = { SKIN = true, PALETTE = true, EYES = true, HAIR_DYES = true, EYE_GLOW = true }
local TOP_GROUPS = { "Everyday", "Coats", "Uniforms", "Robes", "Combat", "Traditional" }
local KEEP = { "skin", "face", "eyes", "brows", "hair", "hairDye", "build", "marks" } -- (who you are: the class dice keep it)

function Creator.open(gui: ScreenGui, call: (string, any?) -> any, R6Rig: any, opts: any?)
	Creator.close()
	opts = opts or {}
	local Shared = ReplicatedStorage:WaitForChild("LifeSim")
	local Looks = require(Shared:WaitForChild("Hunter"):WaitForChild("Looks"))
	local Accessories = Looks.Accessories
	local hairCache = ReplicatedStorage:WaitForChild("HunterHairCache", 5)

	-- ── state ──
	local look = Looks.clean(nil)
	local savedLook = look
	local history: { any } = {}
	local myRank, myClass = 0, nil
	local currentTab = Looks.TABS[1]
	for _, t in Looks.TABS do
		if t.id == opts.tab then
			currentTab = t
		end
	end
	local presetCat = if opts.cat and Looks.find("CATEGORIES", opts.cat) then opts.cat else "fighter"
	local accClass = if opts.cat and table.find(Accessories.CLASSES, opts.cat) then opts.cat else "fighter"
	local wornPreset: string? = nil
	local function classColor(id: string?): Color3
		local cls = id and Looks.find("CLASSES", id)
		return if cls then c3(cls.color) else ACCENT
	end
	local function rankColor(letter: string?): Color3
		local i = table.find(Looks.RANK_LETTERS, letter or "") or 0
		return c3(Looks.RANK_COLORS[i] or Looks.RANK_COLORS[0])
	end

	-- ── the frame ──
	local frame = make("Frame", { Name = "R6Creator", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.95, 0.92), BackgroundColor3 = C.panel, ZIndex = 30 }, gui)
	make("UISizeConstraint", { MaxSize = Vector2.new(1240, 800) }, frame)
	corner(frame, 10)
	stroke(frame, ACCENT, 0.35, 1.5)
	make("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 190, 205)) }, frame)
	open = frame
	make("TextLabel", { Position = UDim2.fromOffset(18, 10), Size = UDim2.new(0.5, 0, 0, 32), BackgroundTransparency = 1, Text = "HUNTER CREATOR", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(220, 200, 255), FontFace = F.display, TextSize = 28 }, frame)
	make("TextLabel", { Position = UDim2.fromOffset(18, 42), Size = UDim2.new(0.62, -18, 0, 18), BackgroundTransparency = 1, Text = "Your look in the live city. Your rank is never chosen here: it's what you awaken at.", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = C.sub, FontFace = F.ui, TextSize = 13 }, frame)
	local rankChip = make("TextLabel", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, 16), Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = CARD, Text = "UNAWAKENED", TextColor3 = C.text, FontFace = F.display, TextSize = 15 }, frame)
	pad(rankChip, 14, 0)
	corner(rankChip, 100)
	stroke(rankChip, ACCENT, 0.5)

	-- ── the stage ──
	local LEFT = 0.42
	local stage = make("Frame", { Name = "Stage", Position = UDim2.fromOffset(18, 70), Size = UDim2.new(LEFT, -26, 1, -190), BackgroundColor3 = Color3.new(1, 1, 1), ClipsDescendants = true }, frame)
	corner(stage, 10)
	stroke(stage, ACCENT, 0.55)
	local stageGrad = make("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(44, 34, 86), Color3.fromRGB(8, 9, 16)) }, stage)
	-- a spotlight behind the rig: soft rings of light
	local spots = {}
	for i, s in { 0.95, 0.7, 0.46 } do
		local sp = make("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromScale(s, s * 0.8), BackgroundColor3 = ACCENT, BackgroundTransparency = 0.955 - i * 0.01, BorderSizePixel = 0 }, stage)
		corner(sp, 100)
		table.insert(spots, sp)
	end
	local view = make("ViewportFrame", { Name = "Preview", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Active = true, Ambient = Color3.fromRGB(128, 126, 150), LightColor = Color3.fromRGB(255, 242, 228), LightDirection = Vector3.new(-0.55, -1, -0.75) }, stage)
	local worldModel = make("WorldModel", {}, view)
	local cam = make("Camera", { FieldOfView = 30 }, view)
	view.CurrentCamera = cam
	-- the dais: a dark disc on a ring of light (the ring takes the outfit's trim colour)
	local up = CFrame.Angles(0, 0, math.rad(90))
	make("Part", { Name = "Dais", Anchored = true, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 7.4, 7.4), CFrame = CFrame.new(0, -0.18, 0) * up, Color = Color3.fromRGB(26, 26, 36), Material = Enum.Material.Metal }, worldModel)
	local ring = make("Part", { Name = "DaisRing", Anchored = true, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.34, 6.5, 6.5), CFrame = CFrame.new(0, -0.14, 0) * up, Color = ACCENT, Material = Enum.Material.Neon }, worldModel)
	make("Part", { Name = "DaisTop", Anchored = true, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.38, 6.1, 6.1), CFrame = CFrame.new(0, -0.12, 0) * up, Color = Color3.fromRGB(18, 18, 26), Material = Enum.Material.Glass }, worldModel)
	local hint = make("TextLabel", { Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 16), BackgroundTransparency = 1, Text = "DRAG TO TURN  ·  SCROLL OR PINCH TO ZOOM", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 230), TextTransparency = 0.2, FontFace = F.displayMed, TextSize = 12 }, stage)
	local _ = hint
	local outfitName = make("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -50), Size = UDim2.new(1, -24, 0, 22), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.new(1, 1, 1), FontFace = F.display, TextSize = 20, TextStrokeTransparency = 0.6 }, stage)
	local outfitSub = make("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -34), Size = UDim2.new(1, -24, 0, 16), BackgroundTransparency = 1, Text = "", TextColor3 = C.sub, FontFace = F.ui, TextSize = 12 }, stage)
	-- the camera's controls
	local camBar = make("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8), Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1 }, stage)
	make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center }, camBar)

	local angle, angleGoal = math.rad(200), math.rad(200)
	local zoom, zoomGoal = 1, 1
	local focus = "body"
	local dragging, lastX, lastTouch, pinchBase = false, 0, 0, 1
	local function camButton(text: string, onClick: () -> ())
		local b = make("TextButton", { Size = UDim2.fromOffset(if #text > 2 then 58 else 28, 24), BackgroundColor3 = CARD, BackgroundTransparency = 0.15, Text = text, TextColor3 = C.text, FontFace = F.display, TextSize = 13 }, camBar)
		corner(b, 12)
		stroke(b, ACCENT, 0.6)
		b.Activated:Connect(function()
			lastTouch = os.clock()
			onClick()
		end)
		return b
	end
	camButton("–", function()
		zoomGoal = math.clamp(zoomGoal + 0.15, 0.45, 1.6)
	end)
	camButton("+", function()
		zoomGoal = math.clamp(zoomGoal - 0.15, 0.45, 1.6)
	end)
	camButton("BODY", function()
		focus, zoomGoal = "body", 1
	end)
	camButton("FACE", function()
		focus, zoomGoal = "face", 1
	end)
	camButton("BACK", function()
		angleGoal = math.rad(20) + math.floor(angleGoal / (2 * math.pi)) * 2 * math.pi
	end)
	connect(RunService, "RenderStepped", function(dt: number)
		if not dragging and os.clock() - lastTouch > 2.5 then
			angleGoal += dt * 0.35 -- (a slow idle turn)
		end
		angle += (angleGoal - angle) * math.min(1, dt * 10)
		zoom += (zoomGoal - zoom) * math.min(1, dt * 8)
		local target = if focus == "face" then Vector3.new(0, 4.6, 0) else Vector3.new(0, 2.55, 0)
		local dist = (if focus == "face" then 6.4 else 17) * zoom
		local lift = if focus == "face" then 0.25 else 2.2
		cam.CFrame = lookAt(target + Vector3.new(math.sin(angle) * dist, lift, math.cos(angle) * dist), target)
	end)
	connect(view, "InputBegan", function(input: InputObject)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			dragging, lastX, lastTouch = true, input.Position.X, os.clock()
		end
	end)
	connect(view, "InputChanged", function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			zoomGoal = math.clamp(zoomGoal - input.Position.Z * 0.12, 0.45, 1.6)
			lastTouch = os.clock()
		end
	end)
	connect(UserInputService, "InputChanged", function(input: InputObject)
		local t = input.UserInputType
		if dragging and (t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch) then
			local dx = input.Position.X - lastX
			lastX = input.Position.X
			angleGoal -= dx * 0.013
			lastTouch = os.clock()
		end
	end)
	connect(UserInputService, "InputEnded", function(input: InputObject)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	connect(UserInputService, "TouchPinch", function(_positions: any, scale: number, _velocity: number, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			pinchBase = zoomGoal
		end
		zoomGoal = math.clamp(pinchBase / math.max(scale, 0.1), 0.45, 1.6)
		lastTouch = os.clock()
	end)

	-- ── the rig ──
	local rig: Model? = nil
	local function hairFor(id: number): Instance?
		if not hairCache or id == 0 then
			return nil
		end
		local a = hairCache:FindFirstChild(tostring(id))
		return a and a:Clone()
	end
	local function describe()
		local p = wornPreset and Looks.find("PRESETS", wornPreset)
		if p then
			outfitName.Text = string.upper(p.name)
			outfitSub.Text = (if p.rank then p.rank .. "-rank · " else "") .. ((Looks.find("CATEGORIES", p.cat) or {}).name or "")
		else
			local top = Looks.find("TOPS", look.top)
			outfitName.Text = string.upper(top and top.name or "")
			local n = #(look.accessories or {})
			outfitSub.Text = if n > 0 then n .. " accessor" .. (if n == 1 then "y" else "ies") else "your own look"
		end
	end
	local building = false
	local function rebuild()
		if building then
			return
		end
		building = true
		if rig then
			rig:Destroy()
			rig = nil
		end
		local ok, m = pcall(R6Rig.build, look, { name = "Preview", hair = hairFor(look.hair), rank = myRank })
		if ok and m then
			-- (the root holds still; the rest stays free for the idle animation)
			for _, d in m:GetDescendants() do
				if d:IsA("BasePart") and d.Name == "HumanoidRootPart" then
					d.Anchored = true
				end
			end
			m.Parent = worldModel
			rig = m
			pcall(function()
				local hum = m:FindFirstChildOfClass("Humanoid")
				local animator = hum and hum:FindFirstChildOfClass("Animator")
				if animator and R6Rig.ANIMS then
					local anim = Instance.new("Animation")
					anim.AnimationId = R6Rig.ANIMS.idle
					local track = (animator :: any):LoadAnimation(anim)
					track.Looped = true
					track:Play()
				end
			end)
		end
		local trim = Looks.color("PALETTE", look.trim)
		ring.Color = if trim then c3(trim) else ACCENT
		describe()
		building = false
	end

	-- ── the layout on the right ──
	local tabs = make("ScrollingFrame", { Name = "Tabs", Position = UDim2.new(LEFT, 0, 0, 70), Size = UDim2.new(1 - LEFT, -18, 0, 36), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollingDirection = Enum.ScrollingDirection.X, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0 }, frame)
	make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tabs)
	local panel = make("Frame", { Position = UDim2.new(LEFT, 0, 0, 108), Size = UDim2.new(1 - LEFT, -18, 1, -190), BackgroundColor3 = INK, BackgroundTransparency = 0.2 }, frame)
	corner(panel, 10)
	stroke(panel, C.stroke, 0.2)
	local body = make("ScrollingFrame", { Name = "Options", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 6, ScrollBarImageColor3 = ACCENT, BorderSizePixel = 0 }, panel)
	pad(body, 12, 10, 14, 14)
	make("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, body)

	local status: TextLabel
	local renderTab: () -> ()
	local renderTabs: () -> ()
	local function snapshot(): any
		local s = table.clone(look)
		s.accessories = table.clone(look.accessories or {})
		return s
	end
	local function remember()
		table.insert(history, snapshot())
		if #history > 40 then
			table.remove(history, 1)
		end
	end
	local function setLook(new: any, keepPreset: boolean?)
		look = Looks.clean(new)
		if not keepPreset then
			wornPreset = nil
		end
		local id = look.hair
		if type(id) == "number" and id > 0 and hairCache and not hairCache:FindFirstChild(tostring(id)) then
			task.spawn(function()
				local res = call("r6Hair", { id = id })
				if res and res.ok and open then
					rebuild()
				end
			end)
		end
		rebuild()
		renderTab()
	end
	local function pick(field: string, value: any)
		remember()
		local new = snapshot()
		new[field] = value
		setLook(new)
	end
	local function applyPreset(id: string)
		remember()
		wornPreset = id
		setLook(Looks.applyPreset(look, id), true)
		local p = Looks.find("PRESETS", id)
		if p and status then
			status.Text = "Wearing " .. p.name .. ". Change anything you like."
		end
	end
	local function rollClass(cls: string?)
		remember()
		local r = Looks.random(function(a, b)
			return math.random(a, b)
		end, if cls == "civilian" then { civilian = true } elseif cls then { class = cls } else nil)
		for _, k in KEEP do
			r[k] = look[k]
		end
		setLook(r)
		if status then
			status.Text = "A new " .. (if cls == "civilian" then "civilian" elseif cls then (Looks.find("CLASSES", cls) or {}).name or cls else "Hunter") .. " outfit. You kept your face."
		end
	end

	-- ── small pieces ──
	local function header(parent: Instance, text: string, order: number, sub: string?)
		local h = make("Frame", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1 }, parent)
		make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = string.upper(text), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = GOLDISH, FontFace = F.display, TextSize = 14 }, h)
		if sub then
			make("TextLabel", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, Text = sub, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = C.sub, FontFace = F.ui, TextSize = 12 }, h)
		end
		return h
	end
	local function chip(parent: Instance, text: string, on: boolean, color: Color3?, onClick: () -> (), order: number?)
		local b = make("TextButton", { LayoutOrder = order or 0, BackgroundColor3 = if on then (color or ACCENT_DEEP):Lerp(Color3.new(0, 0, 0), 0.25) else CARD, Text = string.upper(text), TextColor3 = if on then Color3.new(1, 1, 1) else C.text, FontFace = F.display, TextSize = 13, AutoButtonColor = true }, parent)
		corner(b, 100)
		stroke(b, color or ACCENT, if on then 0 else 0.65, if on then 2 else 1)
		b.Activated:Connect(onClick)
		return b
	end
	local function grid(parent: Instance, order: number, cell: UDim2, gap: number?): Frame
		local g = make("Frame", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, parent)
		make("UIGridLayout", { CellSize = cell, CellPadding = UDim2.fromOffset(gap or 6, gap or 6), SortOrder = Enum.SortOrder.LayoutOrder }, g)
		return g
	end
	local function swatches(parent: Instance, order: number, field: string, listName: string)
		local g = grid(parent, order, UDim2.fromOffset(30, 30), 7)
		for i, o in Looks[listName] do
			local on = look[field] == o.id
			local b = make("TextButton", { LayoutOrder = i, BackgroundColor3 = if o.color then c3(o.color) else CARD_HI, Text = if o.color then "" else "–", TextColor3 = C.text, FontFace = F.uiBold, TextSize = 14, AutoButtonColor = true }, g)
			corner(b, 100)
			stroke(b, if on then Color3.new(1, 1, 1) else Color3.fromRGB(0, 0, 0), if on then 0 else 0.5, if on then 3 else 1)
			b.Activated:Connect(function()
				pick(field, o.id)
			end)
		end
	end
	local function option(parent: Instance, i: number, o: any, field: string)
		local on = look[field] == o.id
		local b = make("TextButton", { LayoutOrder = i, BackgroundColor3 = if on then ACCENT_DEEP else CARD, Text = "", AutoButtonColor = true }, parent)
		corner(b, 6)
		stroke(b, if on then Color3.new(1, 1, 1) else ACCENT, if on then 0.1 else 0.85)
		make("TextLabel", { Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -16, 1, 0), BackgroundTransparency = 1, Text = o.name, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = if on then Color3.new(1, 1, 1) else C.text, FontFace = if on then F.uiBold else F.ui, TextSize = 13 }, b)
		-- a stripe in the colour of the class it suits
		local cls = type(o.cls) == "string" and string.match(o.cls, "^[^,]+")
		if cls then
			local bar = make("Frame", { Position = UDim2.fromOffset(4, 6), Size = UDim2.new(0, 3, 1, -12), BackgroundColor3 = classColor(cls), BorderSizePixel = 0 }, b)
			corner(bar, 2)
		end
		b.Activated:Connect(function()
			pick(field, o.id)
		end)
	end
	local function fieldSection(order: number, field: string)
		local listName = Looks.FIELDS[field]
		local list = Looks[listName]
		local cur = Looks.find(listName, look[field])
		local section = make("Frame", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, body)
		make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, section)
		header(section, Looks.LABELS[field] or field, 0, cur and cur.name or nil)
		if SWATCH_LISTS[listName] then
			swatches(section, 1, field, listName)
		elseif field == "top" then
			-- the tops by kind
			for gi, groupName in TOP_GROUPS do
				make("TextLabel", { LayoutOrder = gi * 2, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = groupName, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.faint, FontFace = F.uiBold, TextSize = 11 }, section)
				local g = grid(section, gi * 2 + 1, UDim2.fromOffset(160, 30))
				for i, o in list do
					if o.group == groupName then
						option(g, i, o, field)
					end
				end
			end
		else
			local g = grid(section, 1, UDim2.fromOffset(160, 30))
			for i, o in list do
				option(g, i, o, field)
			end
		end
	end

	-- ── the presets: class shelves of cards, each a little live preview ──
	local function presetCard(parent: Instance, i: number, p: any)
		local on = wornPreset == p.id
		local col = classColor(p.cat)
		local b = make("TextButton", { LayoutOrder = i, BackgroundColor3 = if on then CARD_HI else CARD, Text = "", AutoButtonColor = true, ClipsDescendants = true }, parent)
		corner(b, 8)
		stroke(b, if on then Color3.new(1, 1, 1) else col, if on then 0 else 0.6, if on then 2 else 1)
		local vp = make("ViewportFrame", { Size = UDim2.new(1, 0, 0, 158), BackgroundColor3 = Color3.new(1, 1, 1), Ambient = Color3.fromRGB(140, 138, 160), LightColor = Color3.fromRGB(255, 244, 230), LightDirection = Vector3.new(-0.5, -1, -0.8) }, b)
		make("UIGradient", { Rotation = 90, Color = ColorSequence.new(col:Lerp(Color3.fromRGB(20, 20, 30), 0.72), Color3.fromRGB(12, 12, 20)) }, vp)
		local tcam = make("Camera", { FieldOfView = 30, CFrame = lookAt(Vector3.new(-4.6, 3.9, -13.2), Vector3.new(0, 2.75, 0)) }, vp)
		vp.CurrentCamera = tcam
		local okT, m = pcall(R6Rig.build, Looks.applyPreset(look, p.id), { name = "Thumb", hair = hairFor(look.hair), rank = myRank })
		if okT and m then
			for _, d in m:GetDescendants() do
				if d:IsA("BasePart") then
					d.Anchored = true
				end
			end
			m.Parent = vp
		end
		if p.rank then
			local badge = make("TextLabel", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = rankColor(p.rank):Lerp(Color3.new(0, 0, 0), 0.45), Text = p.rank, TextColor3 = rankColor(p.rank):Lerp(Color3.new(1, 1, 1), 0.4), FontFace = F.display, TextSize = 16 }, b)
			corner(badge, 100)
			stroke(badge, rankColor(p.rank), 0)
		end
		if on then
			local worn = make("TextLabel", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8), Size = UDim2.fromOffset(52, 20), BackgroundColor3 = Color3.fromRGB(60, 160, 110), Text = "WORN", TextColor3 = Color3.new(1, 1, 1), FontFace = F.display, TextSize = 12 }, b)
			corner(worn, 100)
		end
		make("TextLabel", { Position = UDim2.fromOffset(10, 162), Size = UDim2.new(1, -20, 0, 20), BackgroundTransparency = 1, Text = p.name, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = Color3.fromRGB(235, 225, 255), FontFace = F.uiBold, TextSize = 14 }, b)
		make("TextLabel", { Position = UDim2.fromOffset(10, 182), Size = UDim2.new(1, -20, 0, 44), BackgroundTransparency = 1, Text = p.desc, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = C.sub, FontFace = F.ui, TextSize = 11 }, b)
		b.Activated:Connect(function()
			applyPreset(p.id)
		end)
	end
	local function renderPresets()
		local shelves = grid(body, 0, UDim2.fromOffset(104, 28), 6)
		for i, cat in Looks.CATEGORIES do
			chip(shelves, cat.name, presetCat == cat.id, classColor(cat.id), function()
				presetCat = cat.id
				renderTab()
			end, i)
		end
		local cat = Looks.find("CATEGORIES", presetCat)
		local list = Looks.presetsIn(presetCat)
		local isClass = Looks.find("CLASSES", presetCat) ~= nil
		header(body, (cat and cat.name or "") .. (if isClass then " · E-rank to S-rank" else ""), 1, #list .. " outfits · a click wears it, then change anything")
		local cards = grid(body, 2, UDim2.fromOffset(176, 232), 8)
		for i, p in list do
			presetCard(cards, i, p)
		end
	end

	-- ── accessories: by class, with their grade; one per slot, four at once ──
	local function renderAccessories()
		local worn = look.accessories or {}
		header(body, "Worn", 0, #worn .. " of " .. Looks.MAX_ACCESSORIES .. " · one per slot · click to take off")
		local wornRow = grid(body, 1, UDim2.fromOffset(190, 30), 6)
		for i, id in worn do
			local a = Accessories.find(id)
			if a then
				chip(wornRow, a.grade .. "  " .. a.name .. "  ×", true, rankColor(a.grade), function()
					pick("accessories", Looks.toggleAccessory(look.accessories, id))
				end, i)
			end
		end
		if #worn == 0 then
			make("TextLabel", { LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "Nothing yet. Pick from a class below: higher grades are stronger in a life.", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.faint, FontFace = F.ui, TextSize = 12 }, body)
		end
		local shelves = grid(body, 2, UDim2.fromOffset(104, 28), 6)
		for i, cls in Accessories.CLASSES do
			chip(shelves, Accessories.CLASS_NAMES[cls], accClass == cls, classColor(cls), function()
				accClass = cls
				renderTab()
			end, i)
		end
		local list = Accessories.ofClass(accClass)
		header(body, Accessories.CLASS_NAMES[accClass] .. (if accClass == "any" then "" else "'s accessories"), 3, #list .. " pieces · E to S")
		local g = grid(body, 4, UDim2.fromOffset(236, 64), 6)
		for i, a in list do
			local on = table.find(worn, a.id) ~= nil
			local b = make("TextButton", { LayoutOrder = i, BackgroundColor3 = if on then CARD_HI else CARD, Text = "", AutoButtonColor = true }, g)
			corner(b, 8)
			stroke(b, if on then Color3.new(1, 1, 1) else rankColor(a.grade), if on then 0 else 0.6, if on then 2 else 1)
			local badge = make("TextLabel", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = rankColor(a.grade):Lerp(Color3.new(0, 0, 0), 0.45), Text = a.grade, TextColor3 = rankColor(a.grade):Lerp(Color3.new(1, 1, 1), 0.4), FontFace = F.display, TextSize = 15 }, b)
			corner(badge, 100)
			local gem = make("Frame", { Position = UDim2.fromOffset(15, 40), Size = UDim2.fromOffset(10, 10), Rotation = 45, BackgroundColor3 = c3(a.glow or a.color), BorderSizePixel = 0 }, b)
			local _ = gem
			make("TextLabel", { Position = UDim2.fromOffset(40, 6), Size = UDim2.new(1, -46, 0, 18), BackgroundTransparency = 1, Text = a.name, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = C.text, FontFace = F.uiBold, TextSize = 13 }, b)
			local slotName = ""
			for _, s in Accessories.SLOTS do
				if s.id == a.slot then
					slotName = s.name
				end
			end
			make("TextLabel", { Position = UDim2.fromOffset(40, 24), Size = UDim2.new(1, -46, 0, 34), BackgroundTransparency = 1, Text = slotName .. " · " .. string.gsub(Accessories.effect(a), "%. Made for.*$", ""), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = C.sub, FontFace = F.ui, TextSize = 10 }, b)
			b.Activated:Connect(function()
				pick("accessories", Looks.toggleAccessory(look.accessories, a.id))
			end)
		end
	end

	renderTab = function()
		for _, c in body:GetChildren() do
			if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
				c:Destroy()
			end
		end
		if currentTab.presets then
			renderPresets()
		elseif currentTab.accessories then
			renderAccessories()
		else
			for order, field in currentTab.fields do
				fieldSection(order, field)
			end
		end
		renderTabs()
	end
	renderTabs = function()
		for _, c in tabs:GetChildren() do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end
		for i, t in Looks.TABS do
			local on = currentTab == t
			local b = make("TextButton", { LayoutOrder = i, Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = if on then ACCENT_DEEP else CARD, Text = string.upper(t.name), TextColor3 = if on then Color3.new(1, 1, 1) else C.sub, FontFace = F.display, TextSize = 14, AutoButtonColor = true }, tabs)
			pad(b, 14, 0)
			corner(b, 6)
			if on then
				make("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, -16, 0, 3), BackgroundColor3 = ACCENT, BorderSizePixel = 0 }, b)
			end
			b.Activated:Connect(function()
				currentTab = t
				body.CanvasPosition = Vector2.new(0, 0)
				renderTab()
			end)
		end
	end

	-- ── the class dice, under the stage ──
	local dice = make("Frame", { Name = "Dice", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 18, 1, -66), Size = UDim2.new(LEFT, -26, 0, 52), BackgroundTransparency = 1 }, frame)
	make("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "ROLL AN OUTFIT (KEEPS YOUR FACE)", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.faint, FontFace = F.displayMed, TextSize = 11 }, dice)
	local diceRow = make("Frame", { Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, dice)
	make("UIGridLayout", { CellSize = UDim2.new(0.125, -4, 0, 26), CellPadding = UDim2.fromOffset(4, 4), SortOrder = Enum.SortOrder.LayoutOrder }, diceRow)
	local DICE = { { id = nil, name = "Any" } }
	for _, cls in Looks.CLASSES do
		table.insert(DICE, { id = cls.id, name = cls.name })
	end
	table.insert(DICE, { id = "civilian", name = "Civilian" })
	for i, d in DICE do
		local b = make("TextButton", { LayoutOrder = i, BackgroundColor3 = CARD, Text = string.upper(string.sub(d.name, 1, 4)), TextColor3 = C.text, FontFace = F.display, TextSize = 12, AutoButtonColor = true }, diceRow)
		corner(b, 6)
		stroke(b, if d.id and d.id ~= "civilian" then classColor(d.id) else ACCENT, 0.4)
		b.Activated:Connect(function()
			rollClass(d.id)
		end)
	end

	-- ── the buttons along the bottom ──
	local bar = make("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 18, 1, -12), Size = UDim2.new(1, -36, 0, 42), BackgroundTransparency = 1 }, frame)
	make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder }, bar)
	status = make("TextLabel", { LayoutOrder = 0, Size = UDim2.new(1, -660, 1, 0), BackgroundTransparency = 1, Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextColor3 = C.sub, FontFace = F.ui, TextSize = 13 }, bar)
	local function button(order: number, text: string, color: Color3, w: number, onClick: () -> ())
		local b = make("TextButton", { LayoutOrder = order, Size = UDim2.fromOffset(w, 42), BackgroundColor3 = color, Text = text, TextColor3 = Color3.new(1, 1, 1), FontFace = F.display, TextSize = 15, AutoButtonColor = true }, bar)
		corner(b, 8)
		stroke(b, Color3.new(1, 1, 1), 0.85)
		b.Activated:Connect(onClick)
		return b
	end
	button(1, "WEAR MY CLASS", Color3.fromRGB(150, 96, 40), 150, function()
		local cls = myClass or (if Looks.find("CLASSES", presetCat) then presetCat else "fighter")
		local id = Looks.classPreset(cls, myRank)
		if id then
			applyPreset(id)
			local p = Looks.find("PRESETS", id)
			status.Text = (if myClass then "Your class" else (Looks.find("CLASSES", cls) or {}).name or "") .. ", at your rank: " .. (p and p.name or "") .. "."
		end
	end)
	button(2, "UNDO", C.panelHi, 80, function()
		local prev = table.remove(history)
		if prev then
			wornPreset = nil
			setLook(prev)
			status.Text = "Undone."
		end
	end)
	button(3, "RANDOM", Color3.fromRGB(62, 84, 140), 110, function()
		remember()
		setLook(Looks.random(function(a, b)
			return math.random(a, b)
		end))
		status.Text = "A whole new Hunter, face and all."
	end)
	button(4, "SAVE", Color3.fromRGB(96, 70, 178), 110, function()
		status.Text = "Saving..."
		local res = call("r6Save", { look = look })
		if res and res.ok then
			look = Looks.clean(res.look or look)
			savedLook = look
			status.Text = "Saved. This is how you'll look in the city."
		else
			status.Text = "Couldn't save. Try again."
		end
	end)
	button(5, "CLOSE", C.panelHi, 90, Creator.close)
	local _ = savedLook

	-- ── what the server knows: your look, your rank, your class ──
	task.spawn(function()
		local res = call("r6Get")
		myRank = (res and tonumber(res.rank)) or 0
		myClass = res and (res.class or res.hunterClass)
		if type(myClass) ~= "string" or not Looks.find("CLASSES", myClass) then
			myClass = nil
		end
		if res and res.look then
			look = Looks.clean(res.look)
			savedLook = look
			if type(look.hair) == "number" and look.hair > 0 then
				call("r6Hair", { id = look.hair })
			end
		end
		local letter = Looks.RANK_LETTERS[myRank] or "-"
		rankChip.Text = (if myRank > 0 then letter .. "-RANK" else "UNAWAKENED") .. (if myClass then " · " .. string.upper((Looks.find("CLASSES", myClass) or {}).name or myClass) else "")
		local glow = if myClass then classColor(myClass) else ACCENT
		for _, sp in spots do
			sp.BackgroundColor3 = glow
		end
		if myClass and not opts.cat then
			presetCat = myClass
			accClass = myClass
		end
		if open then
			rebuild()
			renderTab()
		end
	end)
	local _g = stageGrad
	rebuild()
	renderTab()
end

return Creator
