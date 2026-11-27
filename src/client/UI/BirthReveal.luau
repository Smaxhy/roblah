--[[
	The birth reveal (v0.8): after BE BORN, the City rolls where you land.
		local release = BirthReveal.play(ctx, layer, life)   -- yields; a tap hurries it
		release()                                            -- fades the black away
	Four reels spin and stop, one after another, each with its own sound: your family, your
	District, your side of the wall, and your talent. Then your name, and the Canto card.
	`life` is the life view (origin, district, side, talent, first, last, year).
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local BirthReveal = {}

local GOLD = Color3.fromRGB(232, 196, 104)
local STREET = Color3.fromRGB(214, 112, 96)

-- the landing sound for a talent, by rarity
local TIER_SOUND = { common = "click", uncommon = "confirm", rare = "parry", epic = "crit", legendary = "ego", unreal = "ego" }

local function oddsText(p: number?): string?
	if type(p) ~= "number" or p <= 0 then
		return nil
	end
	local n = math.max(1, math.floor(1 / p + 0.5))
	return if n <= 1 then "Most lives start here" else string.format("1 in %d lives", n)
end

function BirthReveal.play(ctx, layer: Instance, life): () -> ()
	if not life then
		return function() end
	end
	local function sfx(name: string, opts: any?)
		if ctx.sfx then
			ctx.sfx(name, opts)
		end
	end

	local root = new("TextButton", {
		Name = "BirthReveal",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 50,
		Parent = layer,
	})
	Kit.tween(root, 0.35, { BackgroundTransparency = 0 })
	local hurry = false
	local done = false
	root.Activated:Connect(function()
		if hurry then
			done = true
		end
		hurry = true
	end)

	-- a thin red line that sweeps across as it starts
	local sweep = new("Frame", {
		BackgroundColor3 = C.crimsonHi,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.16),
		Size = UDim2.new(0, 0, 0, 2),
		ZIndex = 51,
		Parent = root,
	})
	Kit.tween(sweep, 0.6, { Size = UDim2.new(0.7, 0, 0, 2) }, Enum.EasingStyle.Quart)
	local fileLine = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.16, -8),
		Size = UDim2.new(0.8, 0, 0, 18),
		Text = string.format("A NEW FILE  ·  YEAR %s", tostring(life.year or "")),
		FontFace = F.mono,
		TextSize = 13,
		TextColor3 = C.faint,
		TextTransparency = 1,
		ZIndex = 51,
		Parent = root,
	})
	Kit.tween(fileLine, 0.5, { TextTransparency = 0 })
	sfx("reroll")

	local column = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.2),
		Size = UDim2.new(0.86, 0, 0.62, 0),
		ZIndex = 51,
		Parent = root,
	}, { new("UISizeConstraint", { MaxSize = Vector2.new(620, math.huge) }), Kit.list(8) })

	local function reelRow(order: number, label: string)
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60), LayoutOrder = order, ZIndex = 51, Parent = column })
		local cap = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Text = label,
			FontFace = F.displayMed,
			TextSize = 13,
			TextColor3 = C.faint,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1,
			ZIndex = 52,
			Parent = row,
		})
		local value = new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 15),
			Size = UDim2.new(1, 0, 0, 28),
			Text = "",
			RichText = true,
			FontFace = F.display,
			TextSize = 26,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 52,
			Parent = row,
		})
		local sub = new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 43),
			Size = UDim2.new(1, 0, 0, 14),
			Text = "",
			FontFace = F.serif,
			TextSize = 12,
			TextColor3 = C.sub,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 52,
			Parent = row,
		})
		local line = new("Frame", {
			BackgroundColor3 = C.stroke,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(0, 0, 0, 1),
			ZIndex = 52,
			Parent = row,
		})
		return { cap = cap, value = value, sub = sub, line = line }
	end

	-- spin a reel through `pool`, slowing down, and land on `final`
	local function spin(row, pool: { string }, final: string, color: Color3, landSound: string, subText: string?)
		Kit.tween(row.cap, 0.2, { TextTransparency = 0 })
		Kit.tween(row.line, 0.5, { Size = UDim2.new(1, 0, 0, 1) }, Enum.EasingStyle.Quart)
		if not hurry and #pool > 0 then
			local steps = 14
			for i = 1, steps do
				if hurry then
					break
				end
				row.value.Text = string.upper(pool[(i % #pool) + 1])
				row.value.TextColor3 = C.faint
				if i % 2 == 0 then
					sfx("coin", { volume = 0.35, pitch = 0.9 + i * 0.02 })
				end
				task.wait(0.035 + (i / steps) ^ 2 * 0.12)
			end
		end
		row.value.Text = string.upper(final)
		row.value.TextColor3 = color
		row.sub.Text = subText or ""
		local scale = new("UIScale", { Scale = 1.12, Parent = row.value })
		Kit.tween(scale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
		sfx(landSound)
		if not hurry then
			task.wait(0.35)
		end
	end

	-- the pools the reels flicker through
	local originPool, districtPool = {}, {}
	for _, o in (ctx.state.meta and ctx.state.meta.origins) or {} do
		table.insert(originPool, o.name)
	end
	for _, d in (ctx.info and ctx.info.city and ctx.info.city.districts) or {} do
		table.insert(districtPool, d.name or d.id)
	end
	local sidePool = { "The Backstreets", "The Nest" }

	local origin = life.origin
	local district = life.district
	local side = life.side
	local talent = life.talent

	task.wait(0.45)
	-- when: the age this life is born into (everything else follows from it)
	local era = nil
	local eraPool = {}
	for _, w in life.world or {} do
		if w.key == "era" then
			era = w
		end
	end
	for _, e in (ctx.info and ctx.info.eras) or {} do
		table.insert(eraPool, e.name)
	end
	if era and #eraPool > 0 then
		spin(reelRow(1, "WHEN"), eraPool, era.label or "?", C.accentHi, "transition", era.note)
	end
	if origin then
		spin(reelRow(2, "BORN INTO"), originPool, origin.name or "?", C.text, "parry", oddsText(origin.odds))
	end
	if district then
		spin(reelRow(3, "DISTRICT"), districtPool, district.name or district.id or "?", C.text, "clash", nil)
	end
	if side then
		local rich = side.rich == true
		spin(reelRow(4, "SIDE OF THE WALL"), sidePool, side.name or side.id or "?", if rich then GOLD else STREET, if rich then "crit" else "stagger", if rich then "Inside the walls." else "Outside the walls.")
	end
	if talent then
		local tierColor = if talent.color then Theme.rgb(talent.color) else C.accentHi
		spin(reelRow(5, "TALENT"), {}, talent.name or "?", tierColor, TIER_SOUND[talent.tier or ""] or "parry", string.upper(talent.tierName or ""))
		if talent.tier == "unreal" or talent.tier == "legendary" then
			Kit.shake(root, 6, 0.4)
		end
	end
	-- the sins this life was dealt
	if life.affinities and #life.affinities > 0 then
		local row = reelRow(6, "SINS")
		local parts, pool = {}, {}
		for _, a in life.affinities do
			table.insert(parts, Format.color(string.upper(Format.escape(a.name)), Theme.rgb(a.color)))
		end
		for _, a in (ctx.info and ctx.info.affinities) or {} do
			table.insert(pool, string.upper(a.name))
		end
		spin(row, pool, table.concat(parts, "  ·  "), C.text, "resonance", if talent and talent.resonance then "Your talent answers to one of them." else nil)
	end

	-- the name, last
	local name = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.94, 0),
		Size = UDim2.new(0.9, 0, 0, 40),
		Text = string.upper(Format.escape((life.first or "") .. " " .. (life.last or ""))),
		FontFace = F.display,
		TextSize = 34,
		TextColor3 = C.text,
		TextTransparency = 1,
		ZIndex = 52,
		Parent = root,
	})
	Kit.tween(name, 0.4, { TextTransparency = 0 })
	sfx("transition")

	-- hold a moment (or until tapped), then fade out
	hurry = true -- a tap from here on closes it
	local t0 = os.clock()
	for _ = 1, 60 do
		if done or os.clock() - t0 >= 2.2 then
			break
		end
		task.wait(0.1)
	end
	-- the words go; the black stays until the caller lets it go (the Canto card comes next)
	local function fadeWords()
		for _, d in root:GetDescendants() do
			if d:IsA("TextLabel") then
				Kit.tween(d, 0.3, { TextTransparency = 1 })
			elseif d:IsA("Frame") and d.BackgroundTransparency < 1 then
				Kit.tween(d, 0.3, { BackgroundTransparency = 1 })
			end
		end
		task.wait(0.32)
	end
	fadeWords()
	-- the story this life was handed: one card, so you know what your life is about
	local story = life.story
	if story then
		for _, child in root:GetChildren() do
			child:Destroy()
		end
		local tone = Theme.tone(story.tone)
		local page = new("Frame", {
			Name = "Story",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.86, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 51,
			Parent = root,
		}, { new("UISizeConstraint", { MaxSize = Vector2.new(560, math.huge) }), Kit.list(10, nil, Enum.HorizontalAlignment.Center) })
		local function line(text: string, font, size: number, color: Color3, order: number)
			local l = Kit.text({ Text = text, FontFace = font, TextSize = size, TextColor3 = color, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1, LayoutOrder = order, ZIndex = 52, Parent = page })
			return l
		end
		local l1 = line("YOUR STORY", F.displayMed, 14, C.faint, 1)
		local l2 = line(string.upper(Format.escape(story.name or "")), F.display, 44, tone, 2)
		local rule = new("Frame", { BackgroundColor3 = tone, BorderSizePixel = 0, Size = UDim2.fromOffset(0, 2), LayoutOrder = 3, ZIndex = 52, Parent = page })
		local l3 = line(Format.escape(story.hook or ""), F.serifItalic, 18, C.text, 4)
		local l4 = line(if story.goal then Format.escape(story.goal) else "", F.ui, 13, C.sub, 5)
		Kit.tween(l1, 0.4, { TextTransparency = 0 })
		task.wait(0.25)
		sfx("ego", { volume = 0.5 })
		Kit.tween(l2, 0.5, { TextTransparency = 0 })
		Kit.tween(rule, 0.6, { Size = UDim2.fromOffset(160, 2) }, Enum.EasingStyle.Quart)
		task.wait(0.6)
		Kit.tween(l3, 0.6, { TextTransparency = 0 })
		task.wait(0.5)
		Kit.tween(l4, 0.6, { TextTransparency = 0 })
		done = false
		local s0 = os.clock()
		for _ = 1, 80 do
			if done or os.clock() - s0 >= 4.5 then
				break
			end
			task.wait(0.1)
		end
		fadeWords()
	end
	return function()
		if root.Parent then
			Kit.tween(root, 0.45, { BackgroundTransparency = 1 })
			task.delay(0.5, function()
				root:Destroy()
			end)
		end
	end
end

return BirthReveal
