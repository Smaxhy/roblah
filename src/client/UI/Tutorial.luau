--[[
	A short guided tour of the screen: a bright frame around one thing at a time and a
	card explaining it. Next / Skip; the last step finishes it.
		Tutorial.start(ctx, gui, steps, onDone)
	steps = { { target = function() -> GuiObject? end, title = "...", text = "..." }, ... }
	`gui` must use the same IgnoreGuiInset as the layers it points at (false here).
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Tutorial = {}

function Tutorial.start(ctx, gui: ScreenGui, steps, onDone)
	local root = new("Frame", {
		Name = "Tutorial",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 40,
		Parent = gui,
	})
	local shade = new("Frame", {
		BackgroundColor3 = C.shade,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Active = true,
		ZIndex = 40,
		Parent = root,
	})
	local ring = new("Frame", {
		Name = "Highlight",
		BackgroundTransparency = 1,
		ZIndex = 42,
		Visible = false,
		Parent = root,
	}, { Kit.corner(4), Kit.stroke(C.accentHi, 3, 0) })
	local card = Kit.panel({
		Name = "TutorialCard",
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.new(0, 380, 0, 0),
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0,
		ZIndex = 43,
		Parent = root,
	}, nil, C.accent)
	Kit.padding(16, 18, 16, 18).Parent = card
	Kit.list(8).Parent = card
	local count = Kit.caps({ Text = "", FontFace = F.type, TextSize = 12, TextColor3 = C.crimsonHi, LayoutOrder = 1, ZIndex = 43, Parent = card })
	local heading = Kit.text({ Text = "", FontFace = F.display, TextSize = 20, TextColor3 = C.accentHi, LayoutOrder = 2, ZIndex = 43, Parent = card })
	local body = Kit.text({ Text = "", FontFace = F.serif, TextSize = 14, TextColor3 = C.text, LayoutOrder = 3, ZIndex = 43, Parent = card })
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 4, ZIndex = 43, Parent = card }, {
		Kit.list(8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right),
	})
	local i = 0
	local finished = false
	local show

	local function finish()
		if finished then
			return
		end
		finished = true
		root:Destroy()
		if onDone then
			onDone()
		end
	end
	local skip = Kit.button({ name = "SkipTutorial", text = "Skip", style = "ghost", size = UDim2.fromOffset(90, 38), order = 1, textSize = 14, zIndex = 43, onClick = finish })
	skip.Parent = row
	local nextButton = Kit.button({ name = "NextStep", text = "Next", style = "primary", size = UDim2.fromOffset(120, 38), order = 2, textSize = 15, zIndex = 43, onClick = function()
		show(i + 1)
	end })
	nextButton.Parent = row

	function show(n: number)
		if n > #steps then
			finish()
			return
		end
		i = n
		local step = steps[n]
		count.Text = string.format("%d / %d", n, #steps)
		heading.Text = string.upper(Format.escape(step.title or ""))
		body.Text = Format.escape(step.text or "")
		nextButton.Text = if n == #steps then "GOT IT" else "NEXT"
		local target = step.target and step.target()
		local abs = root.AbsoluteSize
		local cardW = math.min(360, abs.X - 24)
		card.Size = UDim2.new(0, cardW, 0, 0)
		if target and target.Parent and target.AbsoluteSize.X > 0 then
			local pos = target.AbsolutePosition - root.AbsolutePosition
			local size = target.AbsoluteSize
			ring.Visible = true
			ring.Position = UDim2.fromOffset(pos.X - 6, pos.Y - 6)
			ring.Size = UDim2.fromOffset(size.X + 12, size.Y + 12)
			-- the card goes below the target, or above it if there's no room
			local below = pos.Y + size.Y + 16
			local cx = math.clamp(pos.X + size.X / 2, cardW / 2 + 12, abs.X - cardW / 2 - 12)
			if below + 200 < abs.Y then
				card.AnchorPoint = Vector2.new(0.5, 0)
				card.Position = UDim2.fromOffset(cx, below)
			else
				card.AnchorPoint = Vector2.new(0.5, 1)
				card.Position = UDim2.fromOffset(cx, math.max(210, pos.Y - 16))
			end
			local stroke = ring:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = 0.8
				Kit.tween(stroke, 0.4, { Transparency = 0 })
			end
		else
			ring.Visible = false
			card.AnchorPoint = Vector2.new(0.5, 0.5)
			card.Position = UDim2.fromScale(0.5, 0.5)
		end
		ctx.sound("click")
	end

	shade.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			show(i + 1)
		end
	end)
	show(1)
	return finish
end

return Tutorial
