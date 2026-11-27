--[[
	CUTSCENES: the moments that aren't a card. One full-screen player for all of them.

		Cutscene.play(ctx, layer, spec)     -- yields until it's over; a tap moves it on

	spec = { style, kicker, title, lines = { ... } }
	  kicker   a small line over the title ("YEAR 942", "DISTRICT 12")
	  title    the big words
	  lines    up to four short lines, shown one after another
	  style    how it looks:
	    age          a new age of the City: black, a gold rule
	    light        the Light: the screen goes white and stays pale
	    dark         the Dark Days: black, and the words are dim
	    voice        someone speaking at the brink: deep violet, slow
	    ego          E.G.O: gold out of black
	    distortion   crimson, and it doesn't hold still
	    story        a story taking hold of you: its own color (spec.color)

	It never lasts longer than about nine seconds, tapped or not.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Cutscene = {}

local STYLES = {
	age = { back = Color3.fromRGB(4, 4, 6), glow = Color3.fromRGB(60, 44, 14), accent = Color3.fromRGB(237, 196, 114), text = C.text },
	light = { back = Color3.fromRGB(244, 238, 216), glow = Color3.fromRGB(255, 255, 255), accent = Color3.fromRGB(150, 110, 30), text = Color3.fromRGB(40, 34, 22), flash = true },
	dark = { back = Color3.fromRGB(0, 0, 0), glow = Color3.fromRGB(22, 4, 4), accent = Color3.fromRGB(150, 44, 40), text = Color3.fromRGB(150, 146, 140) },
	voice = { back = Color3.fromRGB(8, 4, 16), glow = Color3.fromRGB(58, 30, 96), accent = Color3.fromRGB(190, 150, 240), text = Color3.fromRGB(226, 216, 240), slow = true },
	ego = { back = Color3.fromRGB(6, 5, 2), glow = Color3.fromRGB(150, 112, 30), accent = Color3.fromRGB(255, 222, 130), text = C.text },
	distortion = { back = Color3.fromRGB(10, 0, 0), glow = Color3.fromRGB(120, 12, 12), accent = Color3.fromRGB(240, 70, 60), text = Color3.fromRGB(236, 210, 204), shake = true },
	story = { back = Color3.fromRGB(4, 4, 6), glow = Color3.fromRGB(70, 20, 18), accent = Color3.fromRGB(226, 86, 76), text = C.text },
}

function Cutscene.play(ctx, layer: Instance, spec)
	if type(spec) ~= "table" then
		return
	end
	local st = table.clone(STYLES[spec.style or "age"] or STYLES.age)
	if spec.color then
		st.accent = Theme.rgb(spec.color)
		st.glow = st.accent:Lerp(Color3.new(0, 0, 0), 0.7)
	end
	local lines = {}
	for i, l in spec.lines or {} do
		if i <= 4 and type(l) == "string" then
			table.insert(lines, l)
		end
	end
	if ctx.sfx then
		ctx.sfx("transition", { pitch = if st.slow then 0.7 elseif st.flash then 1.3 else 0.9 })
	end

	local root: any = new("TextButton", {
		Name = "Cutscene",
		AutoButtonColor = false,
		BackgroundColor3 = if st.flash then Color3.new(1, 1, 1) else st.back,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 60,
		Parent = layer,
	})
	root:SetAttribute("Style", spec.style or "age")
	local taps = 0
	root.Activated:Connect(function()
		taps += 1
	end)
	Kit.tween(root, if st.flash then 0.15 else 0.4, { BackgroundTransparency = 0 })
	if st.flash then
		-- the Light: white first, then it settles to something you can look at
		task.delay(0.5, function()
			if root.Parent then
				Kit.tween(root, 1.2, { BackgroundColor3 = st.back })
			end
		end)
	end

	-- a glow behind the words: wide, soft, the color of the moment
	local glow = new("Frame", {
		Name = "Glow",
		BackgroundColor3 = st.glow,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.62),
		ZIndex = 61,
		Parent = root,
	}, {
		new("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.15), NumberSequenceKeypoint.new(1, 1) }),
		}),
	})
	Kit.tween(glow, 1.2, { BackgroundTransparency = 0 })

	-- letterbox bars
	for _, top in { true, false } do
		local bar = new("Frame", {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, if top then 0 else 1),
			Position = UDim2.fromScale(0, if top then 0 else 1),
			Size = UDim2.new(1, 0, 0, 0),
			ZIndex = 62,
			Parent = root,
		})
		Kit.tween(bar, 0.5, { Size = UDim2.new(1, 0, 0.11, 0) }, Enum.EasingStyle.Quart)
	end

	local box = new("Frame", {
		Name = "Words",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.84, 0, 0, 300),
		ZIndex = 63,
		Parent = root,
	}, { new("UISizeConstraint", { MaxSize = Vector2.new(820, 420) }) })

	local y = 0
	local kicker = nil
	if spec.kicker and spec.kicker ~= "" then
		kicker = new("TextLabel", {
			Name = "Kicker",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 0, 22),
			Text = string.upper(Format.escape(spec.kicker)),
			FontFace = F.type,
			TextSize = 18,
			TextColor3 = st.accent,
			TextTransparency = 1,
			ZIndex = 64,
			Parent = box,
		})
		y += 30
	end
	local title = nil
	if spec.title and spec.title ~= "" then
		title = new("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, y + 14),
			Size = UDim2.new(1, 0, 0, 74),
			Text = string.upper(Format.escape(spec.title)),
			TextWrapped = true,
			TextScaled = true,
			FontFace = F.display,
			TextColor3 = if spec.style == "light" then st.text else st.accent,
			TextTransparency = 1,
			ZIndex = 64,
			Parent = box,
		}, { new("UITextSizeConstraint", { MaxTextSize = 68, MinTextSize = 26 }) })
		y += 84
	end
	local rule = new("Frame", {
		Name = "Rule",
		BackgroundColor3 = st.accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, y + 4),
		Size = UDim2.new(0, 0, 0, 2),
		ZIndex = 64,
		Parent = box,
	})
	y += 22
	local labels = {}
	for i, l in lines do
		labels[i] = new("TextLabel", {
			Name = "Line",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 0, 30),
			Text = Format.escape(l),
			TextWrapped = true,
			FontFace = if spec.style == "voice" then F.serifItalic else F.serif,
			TextSize = 20,
			TextColor3 = st.text,
			TextTransparency = 1,
			ZIndex = 64,
			Parent = box,
		})
		y += 34
	end
	local hint = new("TextLabel", {
		Name = "Hint",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.86, 0),
		Size = UDim2.fromOffset(220, 18),
		Text = "TAP",
		FontFace = F.displayMed,
		TextSize = 13,
		TextColor3 = st.text,
		TextTransparency = 1,
		ZIndex = 64,
		Parent = root,
	})

	-- waits `seconds`, or until the next tap; false if the scene is gone
	local function hold(seconds: number): boolean
		local before = taps
		local t0 = os.clock()
		while os.clock() - t0 < seconds do
			if taps > before or not root.Parent then
				break
			end
			task.wait(0.05)
		end
		return root.Parent ~= nil
	end

	local pace = if st.slow then 1.25 else 0.85
	hold(0.3)
	if kicker then
		Kit.tween(kicker, 0.4, { TextTransparency = 0 })
		hold(0.35)
	end
	if title then
		Kit.tween(title, 0.6, { TextTransparency = 0, Position = UDim2.fromOffset(0, (title :: any).Position.Y.Offset - 14) }, Enum.EasingStyle.Quart)
		if st.shake and Kit.effects then
			-- it doesn't hold still
			task.spawn(function()
				for _ = 1, 14 do
					if not title.Parent then
						return
					end
					(title :: any).Rotation = (math.random() - 0.5) * 2.4
					task.wait(0.06)
				end
				if title.Parent then
					(title :: any).Rotation = 0
				end
			end)
		end
	end
	Kit.tween(rule, 0.7, { Size = UDim2.new(0.5, 0, 0, 2) }, Enum.EasingStyle.Quart)
	hold(0.6)
	for _, label in labels do
		Kit.tween(label, 0.5, { TextTransparency = if spec.style == "dark" then 0.15 else 0 })
		if not hold(pace) then
			return
		end
	end
	Kit.tween(hint, 0.4, { TextTransparency = 0.5 })
	hold(if #lines > 0 then 2.6 else 1.6)

	for _, d in root:GetDescendants() do
		if d:IsA("TextLabel") then
			Kit.tween(d, 0.3, { TextTransparency = 1 })
		elseif d:IsA("Frame") then
			Kit.tween(d, 0.35, { BackgroundTransparency = 1 })
		end
	end
	Kit.tween(root, 0.45, { BackgroundTransparency = 1 })
	task.wait(0.47)
	if root.Parent then
		root:Destroy()
	end
end

return Cutscene
