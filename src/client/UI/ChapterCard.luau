--[[
	Canto and Intervallo title cards (v0.8).
		ChapterCard.play(ctx, layer, entry)   -- yields ~3 s; a tap skips
	entry: a log entry { kind = "chapter" | "intervallo", word, num, title, text }.
	A Canto: black, a red numeral, a red line that cuts across, the title, one line under it.
	An Intervallo: an interlude between Cantos, quieter: a gold numeral, the title in italics,
	a small ornament.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local ChapterCard = {}

local GOLD = Color3.fromRGB(226, 190, 112)

function ChapterCard.play(ctx, layer: Instance, entry)
	if type(entry) ~= "table" then
		return
	end
	local interlude = entry.kind == "intervallo"
	local accent = if interlude then GOLD else C.crimsonHi
	if ctx.sfx then
		ctx.sfx("transition", { pitch = if interlude then 0.85 else 1 })
	end

	local root = new("TextButton", {
		Name = if interlude then "IntervalloCard" else "CantoCard",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 60,
		Parent = layer,
	})
	local skip = false
	root.Activated:Connect(function()
		skip = true
	end)
	Kit.tween(root, 0.3, { BackgroundTransparency = 0 })

	-- letterbox bars slide in
	for _, top in { true, false } do
		local bar = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(8, 8, 10),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, if top then 0 else 1),
			Position = UDim2.fromScale(0, if top then 0 else 1),
			Size = UDim2.new(1, 0, 0, 0),
			ZIndex = 61,
			Parent = root,
		})
		Kit.tween(bar, 0.5, { Size = UDim2.new(1, 0, 0.12, 0) }, Enum.EasingStyle.Quart)
	end

	local box = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.84, 0, 0, 190),
		ZIndex = 62,
		Parent = root,
	}, { new("UISizeConstraint", { MaxSize = Vector2.new(760, 400) }) })

	local word = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Text = string.upper(entry.word or (if interlude then "Intervallo" else "Canto")) .. "  " .. tostring(entry.num or ""),
		FontFace = F.display,
		TextSize = 20,
		TextColor3 = accent,
		TextXAlignment = if interlude then Enum.TextXAlignment.Center else Enum.TextXAlignment.Left,
		TextTransparency = 1,
		ZIndex = 63,
		Parent = box,
	})
	local line = new("Frame", {
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(if interlude then 0.5 else 0, 0),
		Position = UDim2.new(if interlude then 0.5 else 0, 0, 0, 30),
		Size = UDim2.new(0, 0, 0, 2),
		ZIndex = 63,
		Parent = box,
	})
	local title = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 54),
		Size = UDim2.new(1, 0, 0, 64),
		Text = if interlude then Format.escape(entry.title or "") else string.upper(Format.escape(entry.title or "")),
		TextWrapped = true,
		TextScaled = true,
		FontFace = if interlude then F.serifItalic else F.display,
		TextColor3 = C.text,
		TextXAlignment = if interlude then Enum.TextXAlignment.Center else Enum.TextXAlignment.Left,
		TextTransparency = 1,
		ZIndex = 63,
		Parent = box,
	}, { new("UITextSizeConstraint", { MaxTextSize = if interlude then 46 else 58, MinTextSize = 20 }) })
	local sub = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 128),
		Size = UDim2.new(1, 0, 0, 44),
		Text = Format.escape(entry.text or ""),
		TextWrapped = true,
		FontFace = F.serif,
		TextSize = 17,
		TextColor3 = C.sub,
		TextXAlignment = if interlude then Enum.TextXAlignment.Center else Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTransparency = 1,
		ZIndex = 63,
		Parent = box,
	})
	-- an Intervallo gets a little ornament under its words
	if interlude then
		local orn = new("Frame", {
			BackgroundColor3 = GOLD,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 1, 6),
			Size = UDim2.fromOffset(8, 8),
			Rotation = 45,
			BackgroundTransparency = 1,
			ZIndex = 63,
			Parent = box,
		})
		task.delay(0.9, function()
			if orn.Parent then
				Kit.tween(orn, 0.4, { BackgroundTransparency = 0 })
			end
		end)
	end

	-- the reveal: the word, the line cutting across, the title rising, the line under it
	task.wait(0.25)
	Kit.tween(word, 0.35, { TextTransparency = 0 })
	Kit.tween(line, 0.6, { Size = UDim2.new(if interlude then 0.3 else 1, 0, 0, 2) }, Enum.EasingStyle.Quart)
	task.wait(0.25)
	title.Position = UDim2.fromOffset(0, 66)
	Kit.tween(title, 0.5, { TextTransparency = 0, Position = UDim2.fromOffset(0, 54) }, Enum.EasingStyle.Quart)
	if not interlude then
		-- a short flicker on the numeral, like a bad bulb
		task.delay(0.5, function()
			for _ = 1, 3 do
				if not word.Parent then
					return
				end
				word.TextTransparency = 0.6
				task.wait(0.05)
				if not word.Parent then
					return
				end
				word.TextTransparency = 0
				task.wait(0.07)
			end
		end)
	end
	task.wait(0.45)
	Kit.tween(sub, 0.5, { TextTransparency = 0 })

	local t0 = os.clock()
	for _ = 1, 60 do
		if skip or os.clock() - t0 >= 2.4 then
			break
		end
		task.wait(0.1)
	end
	for _, d in root:GetDescendants() do
		if d:IsA("TextLabel") then
			Kit.tween(d, 0.3, { TextTransparency = 1 })
		elseif d:IsA("Frame") then
			Kit.tween(d, 0.35, { BackgroundTransparency = 1 })
		end
	end
	Kit.tween(root, 0.4, { BackgroundTransparency = 1 })
	task.wait(0.42)
	root:Destroy()
end

return ChapterCard
