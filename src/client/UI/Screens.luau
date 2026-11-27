--[[
	Full screens: Loading, New Life (origin picker), Death (lantern card).
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Sheets = require(script.Parent.Sheets)
local Builder = require(script.Parent.Builder)
local AvatarView = require(script.Parent.AvatarView)
local Talent = require(script.Parent.Talent)
local Layout = require(script.Parent.Layout)

local Avatar = AvatarView.Avatar

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Screens = {}

local function screenFrame(parent: Instance, name: string)
	return new("Frame", {
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = parent,
	})
end

-- ── Loading ─────────────────────────────────────────────────────────────────

function Screens.loading(ctx, parent: Instance)
	local frame = screenFrame(parent, "Loading")
	local box = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = frame,
	}, { Kit.list(10, nil, Enum.HorizontalAlignment.Center) })
	local title = Kit.text({
		Text = "",
		FontFace = F.display,
		TextSize = 46,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 1,
		Parent = box,
	})
	new("Frame", { BackgroundColor3 = C.crimson, BorderSizePixel = 0, Size = UDim2.new(0, 56, 0, 3), LayoutOrder = 2, Parent = box })
	local status = Kit.text({
		Text = "OPENING THE FILE...",
		FontFace = F.type,
		TextSize = 15,
		TextColor3 = C.sub,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 3,
		Parent = box,
	})
	local pulse = true
	task.spawn(function()
		while pulse do
			Kit.tween(status, 0.9, { TextTransparency = 0.6 })
			task.wait(0.9)
			Kit.tween(status, 0.9, { TextTransparency = 0 })
			task.wait(0.9)
		end
	end)
	return {
		frame = frame,
		setTitle = function(t)
			title.Text = string.upper(Format.escape(t))
		end,
		setStatus = function(t)
			status.Text = Format.escape(t)
		end,
		stop = function()
			pulse = false
		end,
	}
end

-- ── New life ────────────────────────────────────────────────────────────────

function Screens.newLife(ctx, parent: Instance, layer: Instance)
	local frame = screenFrame(parent, "NewLife")
	local panel = Kit.panel({
		Size = UDim2.fromScale(1, 1),
		AutomaticSize = Enum.AutomaticSize.None,
		Parent = frame,
	})
	local scroll = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -76),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.stroke,
		Parent = panel,
	}, { Kit.padding(20, 18, 16, 18), Kit.list(10) })

	local selected = nil
	local selectedDistrict = nil -- nil = random
	local cards = {}
	local beginButton, setBegin
	local nameBox
	local typedName = "" -- kept across rebuilds
	local look = nil -- the character being made (cosmetic ids)
	local buildState = Builder.new(ctx) -- style, traits, stat points

	local function recordSet()
		local set = {}
		for _, r in (ctx.state.meta and ctx.state.meta.records) or {} do
			if r.unlocked then
				set[r.id] = true
			end
		end
		return set
	end
	local function usable(category: string, option)
		local meta = ctx.state.meta or {}
		return Avatar.usable(category, option, meta.cosmetics, recordSet())
	end
	local function recordName(id: string): string
		for _, r in (ctx.state.meta and ctx.state.meta.records) or {} do
			if r.id == id then
				return r.name
			end
		end
		return id
	end

	local function refresh()
		for id, card in cards do
			local isSel = id == selected
			card.stroke.Color = if isSel then C.accent else C.stroke
			card.stroke.Transparency = if isSel then 0 else 0.4
			card.frame.BackgroundColor3 = if isSel then C.panelHi else C.panelLo
		end
		if setBegin then
			setBegin(selected ~= nil)
		end
	end

	local function build()
		for _, child in scroll:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		cards = {}
		local meta = ctx.state.meta
		local info = ctx.info
		local order = 0
		local function nextOrder()
			order += 1
			return order
		end
		-- back to the quick creator (or the start menu)
		local backRow = new("Frame", { Name = "BackRow", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = nextOrder(), Parent = scroll })
		Kit.button({
			name = "BackToQuick",
			text = if info.modes and #info.modes > 0 then "‹  Quick creator" else "‹  Menu",
			style = "ghost",
			size = UDim2.new(0, 150, 1, 0),
			textSize = 13,
			onClick = function()
				if info.modes and #info.modes > 0 and ctx.actions.showQuickStart then
					ctx.actions.showQuickStart(ctx.state.mode)
				else
					ctx.actions.showMenu()
				end
			end,
		}).Parent = backRow
		Kit.text({
			Text = "NEW FILE",
			FontFace = F.type,
			TextSize = 14,
			TextColor3 = C.crimsonHi,
			LayoutOrder = nextOrder(),
			Parent = scroll,
		})
		Kit.text({
			Text = string.upper(Format.escape(info.meta.title)),
			FontFace = F.display,
			TextSize = 40,
			LayoutOrder = nextOrder(),
			Parent = scroll,
		})
		Kit.text({
			Text = Format.escape(info.meta.tagline),
			FontFace = F.serifItalic,
			TextSize = 15,
			TextColor3 = C.sub,
			LayoutOrder = nextOrder(),
			Parent = scroll,
		})
		Kit.text({
			Text = string.format("%s %s   ·   %d lives lived", Format.color(tostring(meta.glow), C.accentHi), info.meta.glowName, meta.livesPlayed or 0),
			FontFace = F.uiMedium,
			TextSize = 13,
			TextColor3 = C.faint,
			LayoutOrder = nextOrder(),
			Parent = scroll,
		})

		-- the game mode picked on the start menu, and the talent you'll be born with
		for _, m in info.modes or {} do
			if m.id == ctx.state.mode then
				Kit.text({
					Text = Format.color("MODE   ", C.faint) .. Format.color(string.upper(Format.escape(m.name)), Theme.rgb(m.color or { 207, 163, 73 })),
					FontFace = F.display,
					TextSize = 14,
					LayoutOrder = nextOrder(),
					Parent = scroll,
				})
			end
		end
		if ctx.state.talent then
			Sheets.sectionTitle(scroll, "Talent", nextOrder())
			Talent.card(ctx, scroll, nextOrder())
		end

		-- ── how you look ──
		local pack = info.avatar
		local cos = pack and pack.cosmetics
		if cos then
			if not look then
				local meta2 = ctx.state.meta or {}
				look = Avatar.sanitize(pack, meta2.lastLook or {}, usable)
			end
			Sheets.sectionTitle(scroll, "How you look", nextOrder())
			local figure = AvatarView.new(ctx, { size = UDim2.new(1, 0, 0, 230), framing = "full", spin = true, chart = true, order = nextOrder() })
			figure.frame.Parent = scroll
			Kit.stroke(C.stroke, 1, 0.3).Parent = figure.frame
			local function showFigure()
				figure:set({ look = look, age = 24, form = "human", sanity = 10 })
			end
			showFigure()
			for _, category in cos.order or {} do
				-- (no weapon at the start: in a pack with schools they're found, bought or issued)
				if category == "weapon" and ctx.info and ctx.info.creatorWeapons == false then
					continue
				end
				local cat = cos[category]
				Kit.text({
					Text = string.upper(Format.escape(cat.name or category)),
					FontFace = F.displayMed,
					TextSize = 12,
					TextColor3 = C.sub,
					LayoutOrder = nextOrder(),
					Parent = scroll,
				})
				local row = new("ScrollingFrame", {
					Name = "LookRow",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 46),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.X,
					ScrollingDirection = Enum.ScrollingDirection.X,
					ScrollBarThickness = 0,
					LayoutOrder = nextOrder(),
					Parent = scroll,
				}, { Kit.list(6, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center), Kit.padding(2, 2, 2, 2) })
				local strokes = {}
				local function paint()
					for id, st in strokes do
						local on = look[category] == id
						st.Color = if on then C.accentHi else C.stroke
						st.Thickness = if on then 2 else 1
						st.Transparency = if on then 0 else 0.35
					end
				end
				for i, option in cat.options do
					local ok = usable(category, option)
					local lockText = if ok then "" elseif option.record then "RECORD" else string.format("%d %s", option.glow or 0, string.upper(info.meta.glowName))
					local btn
					if option.color then
						btn = new("TextButton", {
							Name = "LookOption",
							AutoButtonColor = false,
							BackgroundColor3 = Color3.fromRGB(option.color[1], option.color[2], option.color[3]),
							BorderSizePixel = 0,
							Size = UDim2.fromOffset(38, 38),
							Text = if ok then "" else "LOCK",
							FontFace = F.display,
							TextSize = 9,
							TextColor3 = C.text,
							TextStrokeTransparency = 0.4,
							LayoutOrder = i,
							Parent = row,
						}, { Kit.corner(2) })
					else
						btn = new("TextButton", {
							Name = "LookOption",
							AutoButtonColor = false,
							BackgroundColor3 = C.panelLo,
							BorderSizePixel = 0,
							Size = UDim2.new(0, 0, 0, 38),
							AutomaticSize = Enum.AutomaticSize.X,
							Text = string.upper(Format.escape(option.name)) .. (if ok then "" else "\n" .. Format.color(lockText, C.faint)),
							RichText = true,
							FontFace = F.displayMed,
							TextSize = if ok then 13 else 11,
							TextColor3 = if ok then C.text else C.sub,
							LayoutOrder = i,
							Parent = row,
						}, { Kit.corner(2), Kit.padding(0, 12, 0, 12) })
					end
					local st = Kit.stroke(C.stroke, 1, 0.35)
					st.Parent = btn
					strokes[option.id] = st
					btn.Activated:Connect(function()
						if btn.Parent == nil then
							return -- this row was rebuilt
						end
						if usable(category, option) then
							look[category] = option.id
							paint()
							showFigure()
							ctx.sound("click")
						elseif option.record then
							ctx.toast("Earn the " .. recordName(option.record) .. " record to unlock " .. option.name .. ".")
						elseif ((ctx.state.meta and ctx.state.meta.glow) or 0) >= (option.glow or 0) then
							ctx.prompt({
								title = "Unlock " .. option.name .. "?",
								text = string.format("Spend %d %s to unlock %s for every future life.", option.glow or 0, info.meta.glowName, option.name),
								buttons = {
									{ label = "Not now", style = "ghost" },
									{ label = "Unlock", style = "primary", onClick = function()
										ctx.actions.unlockCosmetic(category, option.id, function()
											look[category] = option.id
											build()
										end)
									end },
								},
							})
						else
							ctx.toast(string.format("%s needs %d %s.", option.name, option.glow or 0, info.meta.glowName))
						end
					end)
				end
				paint()
			end
			local shuffle = Kit.button({
				text = "Random look",
				style = "ghost",
				size = UDim2.new(0, 160, 0, 34),
				order = nextOrder(),
				textSize = 13,
				onClick = function()
					for _, category in cos.order or {} do
						if category == "weapon" and ctx.info and ctx.info.creatorWeapons == false then
							continue
						end
						local choices = {}
						for _, option in cos[category].options do
							if usable(category, option) then
								table.insert(choices, option.id)
							end
						end
						if #choices > 0 then
							look[category] = choices[math.random(1, #choices)]
						end
					end
					build()
				end,
			})
			shuffle.Parent = scroll
		end

		-- ── the build: style, traits, stat points, family name ──
		Builder.append(ctx, scroll, nextOrder, buildState, layer)

		Sheets.sectionTitle(scroll, "Your name (optional)", nextOrder())
		nameBox = new("TextBox", {
			BackgroundColor3 = C.panelLo,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 42),
			Text = typedName,
			PlaceholderText = "Leave blank for a random name",
			PlaceholderColor3 = C.faint,
			ClearTextOnFocus = false,
			FontFace = F.uiMedium,
			TextSize = 15,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = nextOrder(),
			Parent = scroll,
		}, { Kit.corner(2), Kit.stroke(C.stroke, 1, 0.3), Kit.padding(0, 12, 0, 12) })
		local box: any = nameBox
		box:GetPropertyChangedSignal("Text"):Connect(function()
			typedName = box.Text
		end)

		local word = info.city.word
		Sheets.sectionTitle(scroll, "Where you're born", nextOrder())
		local districtName = "Random " .. word
		for _, d in info.city.districts do
			if d.id == selectedDistrict then
				districtName = string.format("%s %d · %s", word, d.number, d.name)
			end
		end
		Sheets.row(scroll, nextOrder(), {
			title = Format.escape(districtName),
			desc = info.meta.birthHint or "Some places are richer, some are deadlier.",
			meta = "Tap to choose a " .. word,
			onClick = function()
				Sheets.wardPicker(ctx, layer, {
					title = "Born in which " .. word .. "?",
					includeRandom = true,
					currentId = selectedDistrict,
					onPick = function(id)
						selectedDistrict = id
						build()
					end,
				})
			end,
		})

		Sheets.sectionTitle(scroll, "Your family", nextOrder())
		for _, o in meta.origins do
			local frameCard = new("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Text = "",
				LayoutOrder = nextOrder(),
				Parent = scroll,
			}, { Kit.corner(2), Kit.padding(12, 14, 12, 14), Kit.list(4) })
			local stroke = Kit.stroke(C.stroke, 1, 0.4)
			stroke.Parent = frameCard
			local dim = if o.unlocked then 0 else 0.4
			Kit.text({
				Text = string.upper(Format.escape(o.name)) .. Format.color("   " .. string.upper(o.side or "either side"), C.faint),
				FontFace = F.displayMed,
				TextSize = 16,
				TextTransparency = dim,
				LayoutOrder = 1,
				Parent = frameCard,
			})
			Kit.text({
				Text = Format.escape(o.desc),
				FontFace = F.serif,
				TextSize = 13,
				TextColor3 = C.sub,
				TextTransparency = dim,
				LayoutOrder = 2,
				Parent = frameCard,
			})
			if not o.unlocked then
				local afford = meta.glow >= o.cost
				Kit.text({
					Text = if afford
						then string.format("Tap to unlock for %d %s", o.cost, info.meta.glowName)
						else string.format("Locked  ·  %d %s", o.cost, info.meta.glowName),
					FontFace = F.uiMedium,
					TextSize = 12,
					TextColor3 = if afford then C.accent else C.faint,
					LayoutOrder = 3,
					Parent = frameCard,
				})
			end
			cards[o.id] = { frame = frameCard, stroke = stroke }
			frameCard.Activated:Connect(function()
				if o.unlocked then
					selected = o.id
					refresh()
				elseif meta.glow >= o.cost then
					ctx.actions.unlockOrigin(o.id, function()
						selected = o.id
						build()
					end)
				end
			end)
		end
		if selected == nil or not cards[selected] then
			for _, o in meta.origins do
				if o.unlocked then
					selected = o.id
					break
				end
			end
		end
		refresh()
	end

	local footer = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 76),
		Parent = panel,
	}, { Kit.padding(10, 18, 16, 18) })
	beginButton, setBegin = Kit.button({
		name = "Begin",
		text = "Open the file",
		style = "primary",
		size = UDim2.new(0.62, -6, 1, 0),
		onClick = function()
			if selected then
				local choices = Builder.payload(buildState)
				if ctx.state.together then
					ctx.actions.togetherReady(selected, typedName, selectedDistrict, look, choices)
				else
					ctx.actions.newLife(selected, typedName, selectedDistrict, look, choices)
				end
			end
		end,
	})
	beginButton.Parent = footer
	local ledger = Kit.button({
		text = ctx.info.meta.ledgerName,
		style = "secondary",
		size = UDim2.new(0.38, -6, 1, 0),
		position = UDim2.new(1, 0, 0, 0),
		anchor = Vector2.new(1, 0),
		textSize = 13,
		onClick = function()
			local sheet = Sheets.open(layer, ctx.info.meta.ledgerName, function()
				build()
			end)
			local function fill()
				Sheets.ledgerContent(ctx, sheet.content, fill)
			end
			fill()
		end,
	})
	ledger.Parent = footer

	return {
		frame = frame,
		refresh = function()
			if beginButton then
				beginButton.Text = if ctx.state.together then "I'M READY" else "OPEN THE FILE"
			end
			build()
		end,
	}
end

-- ── Death ───────────────────────────────────────────────────────────────────

function Screens.death(ctx, parent: Instance)
	local frame = screenFrame(parent, "Death")
	-- On a wide screen the "You" panel on the left is empty once a life is over: the book takes
	-- that room as well, and sits in the middle of it (the hub stays where it was, on the right).
	local function span()
		local left = Layout.leftWidth
		if left and left > 0 then
			frame.Position = UDim2.fromOffset(-(left + Layout.GAP), 0)
			frame.Size = UDim2.new(1, left + Layout.GAP, 1, 0)
		else
			frame.Position = UDim2.fromOffset(0, 0)
			frame.Size = UDim2.fromScale(1, 1)
		end
	end
	Layout.changed:Connect(span)
	span()
	-- (v0.18) the way out is always in sight: over the book, not at the end of it
	local bar = new("Frame", {
		Name = "DeathBar",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		Size = UDim2.new(1, -8, 0, 50),
		ZIndex = 3,
		Parent = frame,
	}, { new("UISizeConstraint", { MaxSize = Vector2.new(720, math.huge) }) })
	Kit.button({
		name = "DeathMenu",
		text = "Back to the menu",
		style = "primary",
		size = UDim2.new(0.5, -6, 1, 0),
		textSize = 17,
		zIndex = 3,
		parent = bar,
		onClick = function()
			ctx.actions.showMenu()
		end,
	})
	Kit.button({
		name = "DeathAgain",
		text = "Begin a new life",
		style = "secondary",
		size = UDim2.new(0.5, -6, 1, 0),
		position = UDim2.fromScale(1, 0),
		anchor = Vector2.new(1, 0),
		textSize = 17,
		zIndex = 3,
		parent = bar,
		onClick = function()
			ctx.actions.showNewLife()
		end,
	})
	local scroll = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 70),
		Size = UDim2.new(1, 0, 1, -70),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
		Parent = frame,
	}, { Kit.list(12), Kit.padding(24, 4, 24, 4), new("UISizeConstraint", { MaxSize = Vector2.new(720, math.huge) }) })

	local function show(lantern, life)
		for _, child in scroll:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local info = ctx.info
		local card = new("Frame", {
			BackgroundColor3 = C.paper,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Parent = scroll,
		}, {
			Kit.corner(2),
			Kit.stroke(C.paperEdge, 2, 0),
			Kit.padding(22, 22, 22, 22),
			Kit.list(8, nil, Enum.HorizontalAlignment.Center),
		})
		Kit.gradient(Color3.fromRGB(250, 241, 220), Color3.fromRGB(226, 212, 180)).Parent = card
		local glowDot = new("Frame", {
			BackgroundColor3 = C.accentHi,
			Size = UDim2.fromOffset(18, 18),
			LayoutOrder = 0,
			Parent = card,
		}, { Kit.round(), Kit.stroke(C.accentLo, 2, 0) })
		task.spawn(function()
			while glowDot.Parent do
				Kit.tween(glowDot, 1.2, { BackgroundTransparency = 0.5 })
				task.wait(1.2)
				if not glowDot.Parent then
					break
				end
				Kit.tween(glowDot, 1.2, { BackgroundTransparency = 0 })
				task.wait(1.2)
			end
		end)
		local function centered(text, font, size, color, order)
			return Kit.text({
				Text = text,
				FontFace = font,
				TextSize = size,
				TextColor3 = color,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = order,
				Parent = card,
			})
		end
		centered("A " .. string.lower(info.meta.lanternName) .. " for", F.uiMedium, 12, C.inkSub, 1)
		centered(string.upper(Format.escape(lantern.name)), F.display, 32, C.ink, 2)
		centered(string.format("Year %d to %d  ·  %d years  ·  %s", lantern.born, lantern.died, lantern.age, lantern.zone), F.ui, 13, C.inkSub, 3)
		if lantern.career then
			centered(Format.escape(lantern.career), F.uiMedium, 13, C.inkSub, 4)
		end
		centered(Format.escape(lantern.cause), F.uiBold, 15, Color3.fromRGB(150, 52, 44), 5)
		centered("\"" .. Format.escape(lantern.epitaph) .. "\"", F.serifItalic, 17, C.ink, 6)
		Kit.stamp(card, "Deceased", C.crimson, { Position = UDim2.new(0.78, 0, 0, 46), Rotation = 12, TextSize = 24 })
		if lantern.highlights and #lantern.highlights > 0 then
			local lines = {}
			for _, h in lantern.highlights do
				table.insert(lines, "·  " .. Format.escape(h))
			end
			centered(table.concat(lines, "\n"), F.serif, 13, C.inkSub, 7)
		end

		-- WHAT HAPPENED, and what would have helped: the engine's death report (life.death)
		local death = life and life.death
		if death then
			local box = new("Frame", {
				Name = "DeathReport",
				BackgroundColor3 = Color3.fromRGB(214, 198, 164),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 8,
				Parent = card,
			}, { Kit.corner(2), Kit.stroke(C.paperEdge, 1, 0), Kit.padding(12, 14, 12, 14), Kit.list(5) })
			local function line(text: string, font, size: number, color: Color3, o: number)
				Kit.text({ Text = text, RichText = true, FontFace = font, TextSize = size, TextColor3 = color, LayoutOrder = o, Parent = box })
			end
			line("WHAT HAPPENED", F.display, 13, C.crimson, 1)
			if death.scene then
				local where = "During <b>" .. Format.escape(tostring(death.scene)) .. "</b>"
				if death.choice then
					where ..= ", you chose: <b>" .. Format.escape(tostring(death.choice)) .. "</b>"
				end
				line(where .. ".", F.serif, 14, C.ink, 2)
			end
			for i, l in death.lines or {} do
				line(Format.escape(l), F.serif, 14, C.ink, 2 + i)
			end
			if death.tips and #death.tips > 0 then
				line("WHAT WOULD HAVE HELPED", F.display, 13, Color3.fromRGB(46, 110, 70), 20)
				for i, t in death.tips do
					line("·  " .. Format.escape(t), F.ui, 13, C.inkSub, 20 + i)
				end
			end
		end

		local order = 10
		local function nextOrder()
			order += 1
			return order
		end
		-- the life in numbers: talent, Fixer grade, fights, what it earned
		local facts = {}
		if lantern.talent then
			for _, t in info.traits or {} do
				if t.id == lantern.talent then
					local color = C.accentHi
					for _, tier in info.talentTiers or {} do
						if tier.id == t.talent and tier.color then
							color = Theme.rgb(tier.color)
						end
					end
					table.insert(facts, Format.color("TALENT  ", C.faint) .. Format.color(Format.escape(t.name), color))
				end
			end
		end
		local grade = lantern.fixerGrade or 0
		if grade > 0 then
			table.insert(facts, Format.color("BEST GRADE  ", C.faint) .. (if grade >= 10 then "A Color" else "Grade " .. (10 - grade)))
		end
		if (lantern.fightsWon or 0) > 0 then
			table.insert(facts, Format.color("FIGHTS WON  ", C.faint) .. tostring(lantern.fightsWon))
		end
		if (lantern.lunacy or 0) > 0 then
			table.insert(facts, Format.color("+" .. lantern.lunacy .. " " .. string.upper(info.lunacy or "Lunacy"), Color3.fromRGB(240, 92, 120)))
		end
		if #facts > 0 then
			Kit.text({
				Text = table.concat(facts, "     "),
				FontFace = F.displayMed,
				TextSize = 13,
				TextColor3 = C.sub,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = nextOrder(),
				Parent = scroll,
			})
		end
		if lantern.records and #lantern.records > 0 then
			local box = Kit.panel({ LayoutOrder = nextOrder(), Parent = scroll }, nil, C.accent)
			Kit.padding(12, 14, 12, 14).Parent = box
			Kit.list(4).Parent = box
			Kit.caps({ Text = "New records", FontFace = F.display, TextSize = 13, TextColor3 = C.accentHi, LayoutOrder = 0, Parent = box })
			for i, name in lantern.records do
				Kit.text({ Text = Format.escape(name) .. Format.color("   +1 " .. info.meta.glowName, C.accent), FontFace = F.displayMed, TextSize = 15, LayoutOrder = i, Parent = box })
			end
		end
		if not lantern.released then
			local b = Kit.button({
				text = string.format("%s the %s  (+%d %s)", info.meta.releaseVerb or "Release", string.lower(info.meta.lanternName or "lantern"), lantern.glow, info.meta.glowName),
				style = "secondary",
				size = UDim2.new(1, 0, 0, 46),
				order = nextOrder(),
				onClick = function()
					ctx.actions.releaseLantern(lantern.id, function()
						lantern.released = true
						show(lantern, life)
					end)
				end,
			})
			b.Parent = scroll
		end
		if life and life.heirs then
			for _, heir in life.heirs do
				local b = Kit.button({
					text = string.format("Continue as %s  (age %d)", heir.name, heir.age),
					style = "primary",
					size = UDim2.new(1, 0, 0, 46),
					order = nextOrder(),
					onClick = function()
						ctx.actions.continueHeir(heir.id)
					end,
				})
				b.Parent = scroll
			end
		end
		local again = Kit.button({
			text = "Begin a new life",
			style = if life and life.heirs and #life.heirs > 0 then "secondary" else "primary",
			size = UDim2.new(1, 0, 0, 46),
			order = nextOrder(),
			onClick = function()
				ctx.actions.showNewLife()
			end,
		})
		again.Parent = scroll
		-- (v0.18) and the menu, at the end of the book too
		local back = Kit.button({
			name = "DeathMenuEnd",
			text = "Back to the menu",
			style = "ghost",
			size = UDim2.new(1, 0, 0, 46),
			order = nextOrder(),
			onClick = function()
				ctx.actions.showMenu()
			end,
		})
		back.Parent = scroll
	end

	return { frame = frame, show = show }
end

return Screens
