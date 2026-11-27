--[[
	Tiny UI toolkit: Instance builder + the "file" style components.
		Kit.new("Frame", { Size = ..., Parent = ... }, { children... })
	Function-valued props are connected as events: Activated = function() end
]]

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local C = Theme.colors
local F = Theme.fonts

local Kit = {}

function Kit.new(className: string, props, children)
	local inst = Instance.new(className)
	local parent = nil
	if props then
		for k, v in props do
			if k == "Parent" then
				parent = v
			elseif type(v) == "function" then
				(inst :: any)[k]:Connect(v)
			else
				(inst :: any)[k] = v
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = inst
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local new = Kit.new

function Kit.tween(inst: Instance, time: number, props, style: Enum.EasingStyle?, dir: Enum.EasingDirection?)
	local t = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

function Kit.corner(radius: number?)
	return new("UICorner", { CornerRadius = UDim.new(0, radius or Theme.sizes.corner) })
end

function Kit.round()
	return new("UICorner", { CornerRadius = UDim.new(1, 0) })
end

function Kit.stroke(color: Color3?, thickness: number?, transparency: number?)
	return new("UIStroke", {
		Color = color or C.stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Kit.padding(t: number, r: number?, b: number?, l: number?)
	return new("UIPadding", {
		PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r or t),
		PaddingBottom = UDim.new(0, b or t),
		PaddingLeft = UDim.new(0, l or r or t),
	})
end

function Kit.list(padding: number?, direction: Enum.FillDirection?, hAlign: Enum.HorizontalAlignment?, vAlign: Enum.VerticalAlignment?)
	return new("UIListLayout", {
		Padding = UDim.new(0, padding or 0),
		FillDirection = direction or Enum.FillDirection.Vertical,
		HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

function Kit.gradient(top: Color3, bottom: Color3, rotation: number?)
	return new("UIGradient", {
		Color = ColorSequence.new(top, bottom),
		Rotation = rotation or 90,
	})
end

-- Four L-shaped brackets in the corners of a frame (the file's signature).
-- A UIPadding on a frame also moves anything drawn inside it, even through a Folder. Decorations
-- (brackets, stripes) belong on the frame's real edges: this keeps `holder` stretched over
-- the whole frame, padding or not, now and when a padding is added later.
local function overPadding(frame: GuiObject, holder: GuiObject)
	local function place()
		local pad = frame:FindFirstChildOfClass("UIPadding")
		local l = if pad then pad.PaddingLeft.Offset else 0
		local r = if pad then pad.PaddingRight.Offset else 0
		local t = if pad then pad.PaddingTop.Offset else 0
		local b = if pad then pad.PaddingBottom.Offset else 0
		holder.Position = UDim2.fromOffset(-l, -t)
		holder.Size = UDim2.new(1, l + r, 1, t + b)
	end
	frame.ChildAdded:Connect(function(child)
		if child:IsA("UIPadding") then
			place()
		end
	end)
	-- (deferred calls can land after the frame is gone: a panel closed in the same frame)
	local function later()
		pcall(place)
	end
	frame.ChildRemoved:Connect(function(child)
		if child:IsA("UIPadding") then
			task.defer(later)
		end
	end)
	place()
	-- a padding is usually added on the line after the panel is made
	task.defer(later)
end

function Kit.brackets(frame: GuiObject, color: Color3?, len: number?, thick: number?, inset: number?)
	local l, t, i = len or 10, thick or 2, inset or -1
	-- The corners sit inside a Folder: they still draw over the frame, but a
	-- UIListLayout on the frame only arranges direct children, so they never get
	-- stacked into the list along with the frame's real content.
	local layer = new("Folder", { Name = "BracketsLayer", Parent = frame })
	local holder = new("Frame", {
		Name = "Brackets",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = (frame.ZIndex or 1) + 1,
		Parent = layer,
	})
	for _, corner in { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } } do
		local x, y = corner[1], corner[2]
		local px = if x == 0 then i else -i
		local py = if y == 0 then i else -i
		new("Frame", {
			BackgroundColor3 = color or C.accent,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(x, y),
			Position = UDim2.new(x, px, y, py),
			Size = UDim2.fromOffset(l, t),
			ZIndex = holder.ZIndex,
			Parent = holder,
		})
		new("Frame", {
			BackgroundColor3 = color or C.accent,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(x, y),
			Position = UDim2.new(x, px, y, py),
			Size = UDim2.fromOffset(t, l),
			ZIndex = holder.ZIndex,
			Parent = holder,
		})
	end
	overPadding(frame, holder)
	return holder
end

-- Diagonal warning stripes across a frame.
function Kit.stripes(frame: GuiObject, color: Color3, transparency: number?, count: number?)
	-- NumberSequence allows at most 20 keypoints: 3 per stripe, so 6 stripes max
	local n = math.clamp(count or 6, 1, 6)
	local alpha = transparency or 0.7
	local keys = {}
	for s = 0, n - 1 do
		local a = s / n
		local b = (s + 0.5) / n
		table.insert(keys, NumberSequenceKeypoint.new(a, alpha))
		table.insert(keys, NumberSequenceKeypoint.new(b - 0.001, alpha))
		table.insert(keys, NumberSequenceKeypoint.new(b, 1))
	end
	table.insert(keys, NumberSequenceKeypoint.new(1, 1))
	-- in a Folder for the same reason as the brackets: list layouts skip it
	local folder = new("Folder", { Name = "StripesLayer", Parent = frame })
	local layer = new("Frame", {
		Name = "Stripes",
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = frame.ZIndex,
		Parent = folder,
	}, {
		new("UIGradient", { Transparency = NumberSequence.new(keys), Rotation = 35 }),
	})
	overPadding(frame, layer)
	return layer
end

-- Uppercase condensed label.
function Kit.caps(props)
	local defaults = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = F.displayMed,
		TextSize = 13,
		TextColor3 = C.sub,
		Text = "",
	}
	for k, v in props do
		defaults[k] = v
	end
	defaults.Text = string.upper(defaults.Text)
	return new("TextLabel", defaults)
end

-- Text label that wraps and grows vertically with its content.
function Kit.text(props)
	local defaults = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		RichText = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = F.serif,
		TextSize = 16,
		TextColor3 = C.text,
		Text = "",
	}
	for k, v in props do
		defaults[k] = v
	end
	return new("TextLabel", defaults)
end

-- DEPTH: a surface lit from above. The color it's given is its top; it shades down from there.
-- (A UIGradient multiplies, so it can only darken: surfaces that want depth start a little
-- lighter than the flat color they replace.)
local DEPTH_PANEL = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(150, 152, 162))
local DEPTH_SOFT = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(204, 204, 210))
local PANEL_TOP = Color3.fromRGB(21, 24, 30)

function Kit.depth(frame: Instance, soft: boolean?)
	return new("UIGradient", { Name = "Depth", Rotation = 90, Color = if soft then DEPTH_SOFT else DEPTH_PANEL, Parent = frame })
end

-- a hairline of light along a frame's top edge (kept on the real edge, padding or not)
function Kit.sheen(frame: GuiObject, strength: number?)
	local layer = new("Folder", { Name = "SheenLayer", Parent = frame })
	local holder = new("Frame", { Name = "Sheen", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = frame.ZIndex, Parent = layer })
	new("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1 - (strength or 0.07),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(3, 1),
		Size = UDim2.new(1, -6, 0, 1),
		ZIndex = frame.ZIndex,
		Parent = holder,
	})
	overPadding(frame, holder)
	return holder
end

-- a bar of color down a frame's left edge (on the real edge, padding or not)
function Kit.edge(frame: GuiObject, color: Color3, width: number?)
	local layer = new("Folder", { Name = "EdgeLayer", Parent = frame })
	local holder = new("Frame", { Name = "Edge", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = frame.ZIndex, Parent = layer })
	new("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.new(0, width or 3, 1, 0), ZIndex = frame.ZIndex, Parent = holder })
	overPadding(frame, holder)
	return holder
end

-- Panel: a dark box lit from above, with a hairline border (and optional brackets).
function Kit.panel(props, children, bracketColor: Color3?)
	-- (solid: a panel that lets even a little through shows ghosts of whatever is under it)
	local defaults = {
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}
	for k, v in props do
		defaults[k] = v
	end
	local lit = defaults.BackgroundTransparency ~= 1
	if lit and defaults.BackgroundColor3 == C.panel then
		defaults.BackgroundColor3 = PANEL_TOP
	end
	local frame = new("Frame", defaults, children)
	Kit.corner(3).Parent = frame
	Kit.stroke(C.stroke, 1, 0.1).Parent = frame
	if lit then
		Kit.depth(frame, defaults.BackgroundColor3 ~= PANEL_TOP)
		Kit.sheen(frame)
	end
	if bracketColor then
		Kit.brackets(frame, bracketColor, 10, 2, -1)
	end
	return frame
end

local STYLES = {
	primary = { bg = C.accent, text = C.ink, stroke = C.accentHi },
	secondary = { bg = C.panelHi, text = C.text, stroke = C.stroke },
	ghost = { bg = C.panelLo, text = C.sub, stroke = C.stroke },
	paper = { bg = C.paperHi, text = C.ink, stroke = C.paperEdge },
	danger = { bg = C.crimsonLo, text = Color3.fromRGB(255, 214, 208), stroke = C.crimson },
}

-- Button with press feedback. Returns the button and a setEnabled(bool) function.
-- Labels are set in condensed caps unless opts.plain is true.
function Kit.button(opts)
	local style = STYLES[opts.style or "secondary"]
	local enabled = opts.enabled ~= false
	local btn = new("TextButton", {
		Name = opts.name or "Button",
		AutoButtonColor = false,
		BackgroundColor3 = style.bg,
		BorderSizePixel = 0,
		Size = opts.size or UDim2.new(1, 0, 0, 44),
		Position = opts.position,
		AnchorPoint = opts.anchor,
		Text = if opts.plain then (opts.text or "") else string.upper(opts.text or ""),
		RichText = true,
		TextWrapped = true,
		FontFace = opts.font or (if opts.plain then F.uiBold else F.display),
		TextSize = opts.textSize or 16,
		TextColor3 = style.text,
		LayoutOrder = opts.order or 0,
		AutomaticSize = opts.autoSize,
		ZIndex = opts.zIndex or 1,
	})
	Kit.corner(opts.corner or 3).Parent = btn
	local stroke = Kit.stroke(style.stroke, 1, 0.2)
	stroke.Parent = btn
	Kit.depth(btn, true)
	if opts.padding then
		Kit.padding(opts.padding).Parent = btn
	end
	local function apply()
		btn.BackgroundTransparency = if enabled then 0 else 0.5
		btn.TextTransparency = if enabled then 0 else 0.5
		stroke.Transparency = if enabled then 0.2 else 0.7
	end
	apply()

	local pressed = style.bg:Lerp(Color3.new(1, 1, 1), 0.16)
	local hover = style.bg:Lerp(Color3.new(1, 1, 1), 0.07)
	local over = false
	btn.MouseEnter:Connect(function()
		over = true
		if enabled then
			Kit.tween(btn, 0.1, { BackgroundColor3 = hover })
			stroke.Transparency = 0
		end
	end)
	btn.MouseButton1Down:Connect(function()
		if enabled then
			Kit.tween(btn, 0.06, { BackgroundColor3 = pressed })
		end
	end)
	btn.MouseButton1Up:Connect(function()
		Kit.tween(btn, 0.14, { BackgroundColor3 = if over and enabled then hover else style.bg })
	end)
	btn.MouseLeave:Connect(function()
		over = false
		Kit.tween(btn, 0.14, { BackgroundColor3 = style.bg })
		stroke.Transparency = if enabled then 0.2 else 0.7
	end)
	btn.Activated:Connect(function()
		if enabled and opts.onClick then
			opts.onClick()
		end
	end)

	local function setEnabled(v: boolean)
		enabled = v
		apply()
	end
	if opts.parent then
		btn.Parent = opts.parent
	end
	return btn, setEnabled
end

-- Small hard-edged tag.
function Kit.chip(text: string, color: Color3?, order: number?)
	local chip = new("TextLabel", {
		BackgroundColor3 = C.panelLo,
		BackgroundTransparency = 0.05,
		Size = UDim2.new(0, 0, 0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = string.upper(text),
		FontFace = F.displayMed,
		TextSize = 12,
		TextColor3 = color or C.sub,
		LayoutOrder = order or 0,
	})
	Kit.corner(2).Parent = chip
	Kit.padding(0, 9, 0, 9).Parent = chip
	Kit.stroke(color or C.stroke, 1, 0.5).Parent = chip
	return chip
end

-- A rubber stamp: bordered typewriter text, tilted, that thumps into place.
function Kit.stamp(parent: Instance, text: string, color: Color3, props)
	-- floats over the card; the Folder keeps any list layout from stacking it
	local layer = new("Folder", { Name = "StampLayer", Parent = parent })
	local stamp = new("TextLabel", {
		Name = "Stamp",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 0, 0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = string.upper(text),
		FontFace = F.type,
		TextSize = 22,
		TextColor3 = color,
		Rotation = -8,
		ZIndex = 6,
		Parent = layer,
	}, {
		Kit.padding(0, 12, 0, 12),
		Kit.stroke(color, 3, 0),
		Kit.corner(3),
	})
	for k, v in props or {} do
		(stamp :: any)[k] = v
	end
	local scale = new("UIScale", { Scale = 1.9, Parent = stamp })
	stamp.TextTransparency = 1
	Kit.tween(scale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
	Kit.tween(stamp, 0.16, { TextTransparency = 0 })
	return stamp
end

-- Dim full-screen layer used behind modals. If given a layer column, the scrim
-- goes on the column's ScreenGui (behind the column) so it covers the whole screen.
function Kit.scrim(parent: Instance, zIndex: number)
	local target = parent
	local z = zIndex
	if parent:GetAttribute("Column") and parent.Parent then
		target = parent.Parent
		z = 1
	end
	return new("Frame", {
		Name = "Scrim",
		BackgroundColor3 = C.shade,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = z,
		Active = true,
		Parent = target,
	})
end

-- Sets ZIndex on an instance and all its GuiObject descendants (relative offset).
function Kit.raise(root: Instance, z: number)
	if root:IsA("GuiObject") then
		root.ZIndex = z
	end
	for _, d in root:GetDescendants() do
		if d:IsA("GuiObject") then
			d.ZIndex = z
		end
	end
end

-- Shakes a GuiObject around its current position.
Kit.effects = true -- the player can turn screen shake off in the menu

function Kit.shake(obj: GuiObject, magnitude: number?, duration: number?)
	if not Kit.effects then
		return
	end
	local origin = obj.Position
	local m = magnitude or 6
	local steps = math.max(2, math.floor((duration or 0.24) / 0.03))
	task.spawn(function()
		for s = 1, steps do
			if not obj.Parent then
				return
			end
			local falloff = 1 - (s - 1) / steps
			obj.Position = origin + UDim2.fromOffset(math.random(-m, m) * falloff, math.random(-m, m) * falloff)
			task.wait(0.03)
		end
		if obj.Parent then
			obj.Position = origin
		end
	end)
end

return Kit
