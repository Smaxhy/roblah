--[[
	Bottom sheets: Activities, Ward picker, Ward details, and the Life menu
	(Career / People / Friends / City / Ledger tabs).
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local EventCard = require(script.Parent.EventCard)
local DoTab = require(script.Parent.DoTab)
local AvatarView = require(script.Parent.AvatarView)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Sheets = {}

local function screenGuiOf(inst: Instance): ScreenGui?
	local p = inst.Parent
	while p and not p:IsA("ScreenGui") do
		p = p.Parent
	end
	return p :: any
end

-- Open sheets, newest last (a gamepad's B button closes the top one).
Sheets.stack = {}
-- Set by the app on a console: moves the gamepad selection into a newly opened sheet.
Sheets.focus = nil :: ((Instance) -> ())?

-- Generic sheet. Returns { content = ScrollingFrame, close = fn, header = Frame, panel = Frame }
-- opts.tall: nearly the full height. opts.wide: wider than the column where the screen allows.
function Sheets.open(layer: Instance, title: string, onClosed, opts: { tall: boolean?, wide: boolean?, center: boolean? }?)
	local scrim = Kit.scrim(layer, 1)
	Kit.tween(scrim, 0.25, { BackgroundTransparency = 0.45 })
	local tapOut = new("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Parent = scrim,
	})

	local panel = new("Frame", {
		Name = "Sheet",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 2, 0),
		Size = UDim2.new(1, 0, if opts and opts.center then 0.9 elseif opts and opts.tall then 0.95 else 0.82, 0),
		BackgroundColor3 = Color3.fromRGB(21, 24, 30),
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = layer,
	}, {
		Kit.corner(4),
		Kit.stroke(C.strokeHi, 1, 0.35),
		Kit.depth(nil :: any),
	})
	if opts and opts.wide then
		-- as wide as the screen allows (up to 1.7x the column), centered on it
		local gui = screenGuiOf(layer)
		local function widen()
			local colW = (layer :: any).AbsoluteSize.X
			local screenW = if gui then gui.AbsoluteSize.X else colW
			if colW > 0 then
				-- (v0.18) a centered sheet (the store) takes as much of the screen as it can
				local factor = math.clamp((screenW - 32) / colW, 1, if opts and opts.center then 2.2 else 1.7)
				panel.Size = UDim2.new(factor, 0, panel.Size.Y.Scale, 0)
			end
		end
		widen()
		if gui then
			gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(widen)
		end
	end
	Kit.brackets(panel, C.accent, 12, 2, -1)
	-- grab handle
	new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(40, 4),
		BackgroundColor3 = C.stroke,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = panel,
	}, { Kit.round() })

	-- the head: a band of brass light under the title, a rule that fades toward the far side
	new("Frame", {
		Name = "HeadBand",
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 58),
		ZIndex = 2,
		Parent = panel,
	}, {
		Kit.corner(4),
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(1, 1) }) }),
	})
	new("Frame", {
		Name = "HeadRule",
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 57),
		Size = UDim2.new(1, -32, 0, 1),
		ZIndex = 2,
		Parent = panel,
	}, { new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0.9) }) }) })
	local header = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 6),
		Size = UDim2.new(1, 0, 0, 52),
		ZIndex = 2,
		Parent = panel,
	}, { Kit.padding(0, 16, 0, 18) })
	-- a tick of brass before the title
	new("Frame", {
		BackgroundColor3 = C.accentHi,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(4, 22),
		ZIndex = 2,
		Parent = header,
	})
	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -64, 1, 0),
		Text = string.upper(title),
		FontFace = F.display,
		TextSize = 24,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = header,
	})

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		local at = table.find(Sheets.stack, close)
		if at then
			table.remove(Sheets.stack, at)
		end
		Kit.tween(scrim, 0.2, { BackgroundTransparency = 1 })
		Kit.tween(panel, 0.22, { Position = UDim2.new(0.5, 0, 2, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.24, function()
			scrim:Destroy()
			panel:Destroy()
			if onClosed then
				onClosed()
			end
		end)
	end

	local closeButton = Kit.button({
		text = "X",
		style = "ghost",
		size = UDim2.fromOffset(36, 36),
		position = UDim2.new(1, 0, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		corner = 2,
		textSize = 14,
		zIndex = 2,
		onClick = close,
	})
	closeButton.Parent = header
	tapOut.Activated:Connect(close)

	local content = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 60),
		Size = UDim2.new(1, 0, 1, -60),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.accentLo,
		ZIndex = 2,
		Parent = panel,
	}, {
		Kit.padding(8, 16, 24, 16),
		Kit.list(10),
	})

	-- (v0.18) a centered sheet stops in the middle of the screen, not at the bottom
	Kit.tween(panel, 0.32, { Position = if opts and opts.center then UDim2.new(0.5, 0, 0.95, 0) else UDim2.new(0.5, 0, 1, 0) }, Enum.EasingStyle.Quint)
	table.insert(Sheets.stack, close)
	-- with a gamepad, put the selection inside the new sheet
	if Sheets.focus then
		task.delay(0.35, function()
			if not closed then
				Sheets.focus(panel)
			end
		end)
	end
	return { content = content, close = close, header = header, panel = panel, isClosed = function()
		return closed
	end }
end

local function clear(frame: Instance)
	for _, child in frame:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end
Sheets.clear = clear

-- A tappable row with a title, a description and a meta line.
local function row(parent, order: number, opts)
	local enabled = opts.enabled ~= false
	local base = if opts.highlight then Color3.fromRGB(38, 36, 34) else Color3.fromRGB(27, 30, 37)
	local btn = new("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = base,
		BackgroundTransparency = if enabled then 0 else 0.4,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, {
		Kit.corner(5),
		Kit.padding(12, 14, 12, 16),
		Kit.list(4),
		Kit.depth(nil :: any, true),
	})
	local edgeColor = if opts.highlight then C.accent elseif opts.accent then opts.accent else nil
	local rowStroke = Kit.stroke(edgeColor or C.stroke, 1, if opts.highlight then 0.2 else 0.45)
	rowStroke.Parent = btn
	if edgeColor then
		Kit.edge(btn, edgeColor, 3)
	end
	if enabled and opts.onClick then
		-- it can be pressed: it answers the pointer
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.06)
			rowStroke.Transparency = 0.1
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = base
			rowStroke.Transparency = if opts.highlight then 0.2 else 0.45
		end)
	end
	local dim = if enabled then 0 else 0.45
	Kit.text({
		Text = opts.title,
		FontFace = F.displayMed,
		TextSize = 16,
		TextColor3 = C.text,
		TextTransparency = dim,
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = btn,
	})
	if opts.desc and opts.desc ~= "" then
		Kit.text({
			Text = opts.desc,
			FontFace = F.serif,
			TextSize = 13,
			TextColor3 = C.sub,
			TextTransparency = dim,
			LayoutOrder = 2,
			ZIndex = 2,
			Parent = btn,
		})
	end
	if opts.meta and opts.meta ~= "" then
		Kit.text({
			Text = opts.meta,
			FontFace = F.uiMedium,
			TextSize = 12,
			TextColor3 = opts.metaColor or C.accent,
			TextTransparency = dim * 0.6,
			LayoutOrder = 3,
			ZIndex = 2,
			Parent = btn,
		})
	end
	if opts.extra then
		opts.extra(btn)
	end
	local s = new("UIScale", { Parent = btn })
	btn.MouseButton1Down:Connect(function()
		if enabled and opts.onClick then
			Kit.tween(s, 0.07, { Scale = 0.98 })
		end
	end)
	btn.MouseButton1Up:Connect(function()
		Kit.tween(s, 0.1, { Scale = 1 })
	end)
	btn.MouseLeave:Connect(function()
		Kit.tween(s, 0.1, { Scale = 1 })
	end)
	btn.Activated:Connect(function()
		if enabled and opts.onClick then
			opts.onClick()
		end
	end)
	return btn
end
Sheets.row = row

local function sectionTitle(parent, text: string, order: number)
	return Kit.text({
		Text = string.upper(text),
		FontFace = F.display,
		TextSize = 12,
		TextColor3 = C.crimsonHi,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	})
end
Sheets.sectionTitle = sectionTitle

-- A person with their portrait on the left: People, Friends.
-- opts: { appearance, title (rich text), lines = { rich text... }, accent, dim, onClick, extra(textColumn) }
local function personCard(ctx, parent, order: number, opts)
	local card = new("TextButton", {
		Name = "Person",
		AutoButtonColor = false,
		BackgroundColor3 = C.panelLo,
		BackgroundTransparency = if opts.dim then 0.5 else 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, { Kit.corner(2), Kit.padding(8, 12, 8, 8) })
	Kit.stroke(opts.accent or C.stroke, 1, if opts.accent then 0.35 else 0.45).Parent = card
	local view = AvatarView.new(ctx, { size = UDim2.fromOffset(50, 54), framing = "portrait", zIndex = 2, chart = true })
	view.frame.Parent = card
	view:set(opts.appearance)
	local column = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 62, 0, 0),
		Size = UDim2.new(1, -62, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 2,
		Parent = card,
	}, { Kit.list(3) })
	Kit.text({
		Text = opts.title,
		FontFace = F.displayMed,
		TextSize = 16,
		TextColor3 = if opts.dim then C.faint else C.text,
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = column,
	})
	for i, line in opts.lines or {} do
		Kit.text({ Text = line, FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 1 + i, ZIndex = 2, Parent = column })
	end
	if opts.extra then
		opts.extra(column)
	end
	if opts.onClick then
		card.Activated:Connect(opts.onClick)
	end
	return card
end
Sheets.personCard = personCard

-- three little bars: pay, danger, rent
local function wardBars(parent, d, order: number?)
	local holder = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = order or 9,
		ZIndex = 2,
		Parent = parent,
	}, { Kit.list(10, Enum.FillDirection.Horizontal) })
	local function bar(label: string, value: number, color: Color3, idx: number)
		local cell = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1 / 3, -7, 1, 0),
			LayoutOrder = idx,
			ZIndex = 2,
			Parent = holder,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 44, 1, 0),
			Text = label,
			FontFace = F.uiMedium,
			TextSize = 11,
			TextColor3 = C.faint,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 2,
			Parent = cell,
		})
		local track = new("Frame", {
			BackgroundColor3 = C.panel,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 46, 0.5, 0),
			Size = UDim2.new(1, -46, 0, 5),
			ZIndex = 2,
			Parent = cell,
		}, { Kit.corner(3) })
		new("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.new(math.clamp(value, 0.05, 1), 0, 1, 0),
			ZIndex = 2,
			Parent = track,
		}, { Kit.corner(3) })
	end
	bar("Pay", (d.wealth or 1) / 1.7, C.money, 1)
	bar("Danger", (d.danger or 1) / 1.8, C.bad, 2)
	bar("Rent", (d.cost or 0) / 90, C.sub, 3)
	return holder
end
Sheets.wardBars = wardBars

-- ── Ward picker / City ──────────────────────────────────────────────────────

-- opts: { title, includeRandom, currentId, excludeCurrent, onPick(id | nil) }
function Sheets.wardPicker(ctx, layer: Instance, opts)
	local city = ctx.info.city
	local sheet = Sheets.open(layer, opts.title or ("Choose a " .. city.word))
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	if opts.note then
		Kit.text({
			Text = Format.escape(opts.note),
			FontFace = F.serifItalic,
			TextSize = 13,
			TextColor3 = C.sub,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = sheet.content,
		})
	end
	if opts.includeRandom then
		row(sheet.content, nextOrder(), {
			title = "Random " .. city.word,
			desc = "Let the dice decide where you're born, like everyone else.",
			onClick = function()
				sheet.close()
				opts.onPick(nil)
			end,
		})
	end
	for _, d in city.districts do
		local isCurrent = d.id == opts.currentId
		if not (isCurrent and opts.excludeCurrent) then
			row(sheet.content, nextOrder(), {
				title = string.format("%s %d · %s", city.word, d.number, Format.escape(d.name)) .. (if isCurrent then Format.color("   you live here", C.good) else ""),
				desc = Format.escape(d.desc),
				meta = (if d.corp then Format.escape(d.corp) .. " · " .. Format.escape(d.trade) else "No company · " .. Format.escape(d.trade))
					.. string.format("  ·  rent %d+/yr", math.floor(d.cost * 0.6 + 0.5)),
				metaColor = Theme.rgb(d.color or { 200, 200, 200 }),
				highlight = isCurrent,
				extra = function(btn)
					wardBars(btn, d, 4)
				end,
				onClick = if opts.onPick then function()
					sheet.close()
					opts.onPick(d.id)
				end else nil,
			})
		end
	end
	return sheet
end

-- Details about where you live right now.
function Sheets.district(ctx, layer: Instance)
	local life = ctx.state.life
	local city = ctx.info.city
	local d = nil
	for _, x in city.districts do
		if x.id == life.district.id then
			d = x
		end
	end
	local s = nil
	for _, x in city.sides do
		if x.id == life.side.id then
			s = x
		end
	end
	local sheet = Sheets.open(layer, string.format("%s %d · %s", city.word, life.district.number, life.district.name))
	local content = sheet.content
	if d then
		Kit.text({ Text = Format.escape(d.desc), FontFace = F.serif, TextSize = 15, LayoutOrder = 1, ZIndex = 2, Parent = content })
		Kit.text({
			Text = if d.corp then string.format(ctx.info.meta.heldBy or "Chartered to %s: %s.", Format.escape(d.corp), Format.escape(d.trade or "")) else (ctx.info.meta.unheld or "No company holds this Ward anymore."),
			FontFace = F.uiMedium,
			TextSize = 13,
			TextColor3 = Theme.rgb(d.color or { 200, 200, 200 }),
			LayoutOrder = 2,
			ZIndex = 2,
			Parent = content,
		})
		wardBars(content, d, 3)
	end
	if s then
		sectionTitle(content, "You live in " .. s.name, 4)
		Kit.text({ Text = Format.escape(s.desc), FontFace = F.serif, TextSize = 14, TextColor3 = C.sub, LayoutOrder = 5, ZIndex = 2, Parent = content })
	end
	sectionTitle(content, "What it costs you", 6)
	Kit.text({
		Text = string.format(
			"Rent: %s %s a year (adults)\nPay here: x%.2f of the city rate%s",
			Format.number(life.livingCost),
			ctx.info.meta.currency,
			life.wageMult,
			if d and not life.side.rich then string.format("\nBuying into %s: %s %s", (ctx.info.city.sides[1] and ctx.info.city.sides[1].name) or "the rich side", Format.number(d.charterCost), ctx.info.meta.currency) else ""
		),
		FontFace = F.ui,
		TextSize = 14,
		LayoutOrder = 7,
		ZIndex = 2,
		Parent = content,
	})
	local cityButton = Kit.button({
		text = "See every " .. city.word,
		style = "secondary",
		size = UDim2.new(1, 0, 0, 42),
		order = 8,
		zIndex = 2,
		onClick = function()
			sheet.close()
			task.delay(0.25, function()
				Sheets.wardPicker(ctx, layer, { title = "The City", currentId = life.district.id })
			end)
		end,
	})
	cityButton.Parent = content
	return sheet
end

-- ── Activities ──────────────────────────────────────────────────────────────

function Sheets.activities(ctx, layer: Instance)
	local sheet = Sheets.open(layer, "Activities")
	Sheets.activitiesContent(ctx, sheet.content, layer, sheet.close)
	return sheet
end

-- The activities list in any container (the sheet on a phone, the hub panel on a PC).
-- `leave` closes whatever holds it before an activity opens something else.
function Sheets.activitiesContent(ctx, content: Instance, layer: Instance, leave: (() -> ())?)
	local life = ctx.state.life
	if not life then
		return
	end
	local sheet = { content = content, close = leave or function() end }

	-- the year's actions, as pips: how many are left is the first thing you see
	local head = new("Frame", { Name = "ActionsLeft", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 0, ZIndex = 2, Parent = sheet.content })
	local per = life.actionsPerYear or 3
	for i = 1, per do
		local on = i <= life.actionsLeft
		new("Frame", {
			BackgroundColor3 = if on then C.accentHi else C.panelLo,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset((i - 1) * 20, 4),
			Size = UDim2.fromOffset(14, 14),
			ZIndex = 2,
			Parent = head,
		}, { Kit.corner(7), Kit.stroke(if on then C.accentHi else C.stroke, 1, if on then 0 else 0.3) })
	end
	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(per * 20 + 6, 0),
		Size = UDim2.new(1, -(per * 20 + 6), 1, 0),
		Text = string.upper(if life.actionsLeft > 0
			then string.format("%d of %d actions left this year", life.actionsLeft, per)
			else "No actions left: age up for a new year"),
		FontFace = F.display,
		TextSize = 13,
		TextColor3 = if life.actionsLeft > 0 then C.text else C.sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = head,
	})

	local function run(act)
		sheet.close()
		if act.shop then
			task.delay(0.25, function()
				Sheets.shop(ctx, layer)
			end)
			return
		end
		if act.market then
			task.delay(0.25, function()
				Sheets.market(ctx, layer, act.market)
			end)
			return
		end
		if act.clash and act.clash.approaches and #act.clash.approaches > 0 then
			-- a fight: which stat do you fight with?
			task.delay(0.25, function()
				DoTab.pickStance(ctx, act.name, act.clash, function(approach)
					ctx.actions.doActivity(act.id, nil, approach)
				end, act.stakes)
			end)
			return
		end
		if act.move == "district" then
			task.delay(0.25, function()
				Sheets.wardPicker(ctx, layer, {
					title = "Move to which " .. ctx.info.city.word .. "?",
					note = "You'll arrive in " .. (ctx.info.meta.arrivalName or "the Gutters") .. ". Moving costs " .. Format.number(act.cost or 0) .. " " .. ctx.info.meta.currency .. " and an action.",
					currentId = life.district.id,
					excludeCurrent = true,
					onPick = function(id)
						if id then
							ctx.actions.doActivity(act.id, id)
						end
					end,
				})
			end)
		else
			ctx.actions.doActivity(act.id)
		end
	end

	-- the tiles: work first, then every kind of thing to do (UI/DoTab)
	local wideContent = (content :: any).AbsoluteSize.X >= 520
	DoTab.fill(ctx, sheet.content, life, run, sheet.close, if wideContent then 3 else 2)
end


-- ── Gear ────────────────────────────────────────────────────────────────────

function Sheets.gearContent(ctx, content, refresh, layer)
	-- (v0.13) the gear page is the Arsenal now: framed tiles, sets, the stash
	local okA, Arsenal = pcall(function()
		return require(script.Parent.Arsenal) :: any
	end)
	if okA and Arsenal then
		Arsenal.gear(ctx, content, refresh, layer)
		return
	end
	clear(content)
	local life = ctx.state.life
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	-- you, wearing what you carry
	local figure = AvatarView.new(ctx, { size = UDim2.new(1, 0, 0, 220), framing = "full", chart = true, order = nextOrder(), zIndex = 2 })
	figure.frame.Parent = content
	Kit.stroke(C.stroke, 1, 0.3).Parent = figure.frame
	figure:set(life.appearance)
	Kit.text({
		Text = "What you carry changes your odds, and shows on you. One item per slot: a tool, a coat and a charm.",
		FontFace = F.serif,
		TextSize = 13,
		TextColor3 = C.sub,
		LayoutOrder = nextOrder(),
		ZIndex = 2,
		Parent = content,
	})
	local bySlot = {}
	for _, g in life.gear or {} do
		bySlot[g.slot] = g
	end
	for _, slot in { "tool", "coat", "charm", "arm" } do
		sectionTitle(content, if slot == "arm" then "augment arm" else slot, nextOrder())
		local g = bySlot[slot]
		if g then
			local info = nil
			for _, item in life.shop or {} do
				if item.id == g.id then
					info = item
				end
			end
			row(content, nextOrder(), {
				title = Format.escape(g.name),
				desc = Format.escape(g.desc or ""),
				meta = if info then Format.escape(info.effect or "") else "",
				highlight = true,
				extra = function(btn)
					local drop = Kit.button({ text = "Drop", style = "ghost", size = UDim2.new(0, 90, 0, 30), order = 9, zIndex = 2, textSize = 13, onClick = function()
						ctx.actions.dropGear(slot, refresh)
					end })
					drop.Parent = btn
				end,
			})
		else
			Kit.text({ Text = "Empty.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
		end
	end
	local shopButton = Kit.button({
		text = "Visit a workshop",
		style = "primary",
		size = UDim2.new(1, 0, 0, 44),
		order = nextOrder(),
		zIndex = 2,
		onClick = function()
			Sheets.shop(ctx, layer)
		end,
	})
	shopButton.Parent = content
end

function Sheets.shop(ctx, layer: Instance)
	local okA, Arsenal = pcall(function()
		return require(script.Parent.Arsenal) :: any
	end)
	if okA and Arsenal then
		return Arsenal.shop(ctx, layer)
	end
	local sheet = Sheets.open(layer, "Workshop")
	local function fill()
		clear(sheet.content)
		local life = ctx.state.life
		local order = 0
		local function nextOrder()
			order += 1
			return order
		end
		Kit.text({
			Text = Format.color(Format.number(life.money), C.money) .. "  " .. ctx.info.meta.currency .. Format.color("     buying doesn't use an action", C.faint),
			FontFace = F.displayMed,
			TextSize = 15,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = sheet.content,
		})
		local current = nil
		for _, slot in { "tool", "coat", "charm", "arm" } do
			for _, item in life.shop or {} do
				if item.slot == slot then
					if current ~= slot then
						current = slot
						sectionTitle(sheet.content, if slot == "arm" then "augment arms" else slot .. "s", nextOrder())
					end
					local meta = item.effect or ""
					if item.owned then
						meta = "Carrying  ·  " .. meta
					elseif not item.enabled and item.reason then
						meta = item.reason .. "  ·  " .. meta
					else
						meta = string.format("%s %s  ·  %s", Format.number(item.price), ctx.info.meta.currency, meta)
					end
					row(sheet.content, nextOrder(), {
						title = Format.escape(item.name),
						desc = Format.escape(item.desc),
						meta = Format.escape(meta),
						metaColor = if item.owned then C.good elseif item.enabled then C.accent else C.faint,
						enabled = item.enabled and not item.owned,
						highlight = item.owned,
						onClick = function()
							ctx.actions.buyGear(item.id, fill)
						end,
					})
				end
			end
		end
	end
	fill()
	return sheet
end

-- ── Markets (v0.12): stock and prices that change with the City ────────────

function Sheets.market(ctx, layer: Instance, marketId: string)
	local function find()
		for _, m in (ctx.state.life and ctx.state.life.markets) or {} do
			if m.id == marketId then
				return m
			end
		end
		return nil
	end
	local first = find()
	local sheet = Sheets.open(layer, if first then first.name else "Market")
	local function fill()
		clear(sheet.content)
		local life = ctx.state.life
		local m = find()
		local order = 0
		local function nextOrder()
			order += 1
			return order
		end
		if not m then
			Kit.text({ Text = "It's shut to you right now.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = sheet.content })
			return
		end
		Kit.text({
			Text = Format.color(Format.number(life.money), C.money) .. "  " .. ctx.info.meta.currency .. Format.color("     buying doesn't use an action", C.faint),
			FontFace = F.displayMed,
			TextSize = 15,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = sheet.content,
		})
		Kit.text({
			Text = (if m.keeper then Format.color(string.upper(Format.escape(m.keeper)), C.faint) .. "\n" else "") .. Format.escape(m.desc or ""),
			FontFace = F.serif,
			TextSize = 13,
			TextColor3 = C.sub,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = sheet.content,
		})
		if m.markup then
			local up = m.markup.mult > 1
			Kit.text({
				Text = string.format("%s %d%%  ·  %s", if up then "PRICES UP" else "PRICES DOWN", math.floor(math.abs(m.markup.mult - 1) * 100 + 0.5), Format.escape(m.markup.why or "")),
				FontFace = F.displayMed,
				TextSize = 12,
				TextColor3 = if up then C.crimsonHi else C.good,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = sheet.content,
			})
		end
		if #m.goods == 0 then
			Kit.text({ Text = "Nothing on the tables for you this year.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = sheet.content })
		end
		for _, g in m.goods do
			local gives = {}
			for _, s in g.gains or {} do
				local text = Format.stakeChip(ctx.info, s)
				table.insert(gives, text)
			end
			local price = if g.price > 0 then string.format("%s %s", Format.number(g.price), ctx.info.meta.currency) else "Free"
			local meta = if g.enabled then price else ((g.reason or "") .. "  ·  " .. price)
			if #gives > 0 then
				meta ..= "  ·  " .. table.concat(gives, "  ")
			end
			row(sheet.content, nextOrder(), {
				title = Format.escape(g.name),
				desc = Format.escape(g.desc or ""),
				meta = Format.escape(meta),
				metaColor = if g.enabled then C.accent else C.faint,
				enabled = g.enabled,
				highlight = g.reason == "You live here" or g.reason == "Already yours",
				onClick = function()
					ctx.actions.buyMarket(marketId, g.id, fill)
				end,
			})
		end
		if (m.unseen or 0) > 0 then
			Kit.text({
				Text = string.format("%d more thing%s turn up here in other years, or when the City is going through something.", m.unseen, if m.unseen == 1 then "" else "s"),
				FontFace = F.serifItalic,
				TextSize = 12,
				TextColor3 = C.faint,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = sheet.content,
			})
		end
	end
	fill()
	return sheet
end

-- ── Life menu tabs ──────────────────────────────────────────────────────────

local function careerTab(ctx, content, sheet)
	local life = ctx.state.life
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	if life.career then
		local c = life.career
		sectionTitle(content, "Your work", nextOrder())
		local progress = if c.rankIndex >= c.rankCount
			then "Top rank."
			elseif c.nextAt and c.promoteStat then string.format(
				"Next rank needs %s %d and time in the job.",
				(ctx.info.stats.defs[c.promoteStat] or {}).name or c.promoteStat,
				c.nextAt
			)
			else ""
		row(content, nextOrder(), {
			title = Format.escape(c.rank .. " · " .. c.name),
			desc = string.format("Rank %d of %d  ·  %s %s a year  ·  %d year%s in", c.rankIndex, c.rankCount, Format.number(c.salary), ctx.info.meta.currency, c.years, if c.years == 1 then "" else "s"),
			meta = progress,
			highlight = true,
		})
		local quit = Kit.button({
			text = "Quit this job",
			style = "danger",
			size = UDim2.new(1, 0, 0, 40),
			order = nextOrder(),
			zIndex = 2,
			onClick = function()
				sheet.close()
				ctx.actions.leaveCareer()
			end,
		})
		quit.Parent = content
	end
	sectionTitle(content, "Find work (costs an action)", nextOrder())
	for _, job in life.careers do
		if not job.current then
			row(content, nextOrder(), {
				title = Format.escape(job.name),
				desc = Format.escape(EventCard.shorten(job.desc or "", 120)),
				meta = if job.enabled
					then string.format("Start as %s  ·  %s %s a year here", job.firstRank, Format.number(job.salary), ctx.info.meta.currency)
					else (job.reason or "Not available"),
				metaColor = if job.enabled then C.accent else C.faint,
				enabled = job.enabled,
				onClick = function()
					sheet.close()
					ctx.actions.joinCareer(job.id)
				end,
			})
		end
	end
end

local function peopleTab(ctx, content, sheet)
	local life = ctx.state.life
	if #life.relations == 0 then
		Kit.text({
			Text = "No one, yet. The city is full of strangers.",
			FontFace = F.serifItalic,
			TextSize = 14,
			TextColor3 = C.sub,
			ZIndex = 2,
			Parent = content,
		})
		return
	end
	for i, rel in life.relations do
		local kindText = rel.kindName
		if rel.linked and rel.player then
			kindText ..= " (" .. rel.player .. (if rel.online then ", online" else ", away") .. ")"
		elseif rel.role then
			kindText ..= ": " .. rel.role
		end
		local lines = {
			Format.color(Format.escape(kindText), if rel.linked then C.strange else C.sub)
				.. (if rel.alive then "  ·  age " .. rel.age else "  ·  died at " .. rel.age),
		}
		personCard(ctx, content, (if rel.alive then 0 else 1000) + i, {
			appearance = rel.appearance,
			title = Format.escape(rel.name),
			lines = lines,
			accent = if rel.linked then C.strange else nil,
			dim = not rel.alive,
			onClick = if rel.alive then function()
				if sheet then
					sheet.close()
				end
				ctx.actions.openPerson(rel)
			end else nil,
			extra = function(column)
				-- bond meter
				local bar = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 9, ZIndex = 2, Parent = column })
				new("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 56, 1, 0),
					Text = "BOND " .. rel.bond,
					FontFace = F.displayMed,
					TextSize = 11,
					TextColor3 = C.faint,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					Parent = bar,
				})
				local track = new("Frame", {
					BackgroundColor3 = C.panel,
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 58, 0.5, 0),
					Size = UDim2.new(1, -58, 0, 5),
					ZIndex = 2,
					Parent = bar,
				}, { Kit.corner(1) })
				new("Frame", {
					BackgroundColor3 = if rel.alive then C.good else C.faint,
					BorderSizePixel = 0,
					Size = UDim2.new(math.clamp(rel.bond / 100, 0, 1), 0, 1, 0),
					ZIndex = 2,
					Parent = track,
				}, { Kit.corner(1) })
			end,
		})
	end
end

-- One person: how they look, your bond, and what you can do together.
function Sheets.person(ctx, layer: Instance, rel)
	local sheet = Sheets.open(layer, rel.name)
	local content = sheet.content
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	local figure = AvatarView.new(ctx, { size = UDim2.new(1, 0, 0, 190), framing = "full", chart = true, order = nextOrder(), zIndex = 2 })
	figure.frame.Parent = content
	Kit.stroke(if rel.linked then C.strange else C.stroke, 1, 0.3).Parent = figure.frame
	figure:set(rel.appearance)
	Kit.text({
		Text = Format.color(string.upper(Format.escape(rel.kindName)), if rel.linked then C.strange else C.accent)
			.. Format.color(string.format("   AGE %d   ·   BOND %d", rel.age, rel.bond), C.sub),
		FontFace = F.displayMed,
		TextSize = 14,
		LayoutOrder = nextOrder(),
		ZIndex = 2,
		Parent = content,
	})
	if rel.job then
		Kit.text({ Name = "Job", Text = Format.escape(rel.first .. " " .. rel.job .. "."), FontFace = F.serif, TextSize = 14, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
	end
	if rel.role then
		Kit.text({ Name = "Role", Text = Format.escape("You met " .. rel.name .. ": " .. rel.role .. "."), FontFace = F.serif, TextSize = 14, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
	end
	-- (v0.12) a linked friend's life right now: how strong they are, what they've made of it
	local sh = rel.sheet
	if sh then
		sectionTitle(content, "How " .. (rel.name or "they") .. " is doing", nextOrder())
		local bits = {}
		for _, key in (ctx.info.stats and ctx.info.stats.order) or {} do
			local def = ctx.info.stats.defs and ctx.info.stats.defs[key]
			local v = sh.stats and sh.stats[key]
			if v then
				local shown = if key == ctx.info.stats.vital and sh.maxHealth then tostring(v) .. "/" .. tostring(sh.maxHealth) else tostring(v)
				table.insert(bits, Format.color(string.upper((def and def.short) or (def and def.name) or key), C.faint) .. " " .. shown)
			end
		end
		if #bits > 0 then
			Kit.text({ Name = "FriendStats", Text = table.concat(bits, "   "), RichText = true, FontFace = F.mono, TextSize = 12, TextColor3 = C.text, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
		end
		local more = {}
		if sh.job then
			table.insert(more, sh.job)
		end
		if sh.renown then
			table.insert(more, "Renown: " .. sh.renown)
		end
		if sh.form then
			table.insert(more, sh.form)
		end
		if sh.office then
			table.insert(more, "runs the " .. sh.office .. " Office")
		end
		if sh.home then
			table.insert(more, "lives in " .. sh.home)
		end
		if #more > 0 then
			Kit.text({ Name = "FriendLife", Text = Format.escape(table.concat(more, "  ·  ")), FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
		end
		Kit.text({ Text = if rel.online then "As of now. It updates whenever you do something." else "As of the last time you were both here.", FontFace = F.serifItalic, TextSize = 11, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
	end
	sectionTitle(content, "Do something together", nextOrder())
	local list = rel.interactions or {}
	if #list == 0 then
		Kit.text({ Text = "Nothing to do with " .. Format.escape(rel.name) .. " right now.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
	end
	for _, act in list do
		local meta = {}
		if act.cost and act.cost > 0 then
			table.insert(meta, Format.number(act.cost) .. " " .. ctx.info.meta.currency)
		end
		if act.clash then
			table.insert(meta, EventCard.oddsLine(act.clash))
		elseif act.enabled then
			table.insert(meta, "Uses an action")
		end
		if not act.enabled and act.reason then
			table.insert(meta, act.reason)
		end
		-- what it gives, in the numbers this life would really get
		local gives = ""
		if act.scene then
			gives = Format.color("A SCENE", C.accentHi) .. Format.color("  what you choose there decides what it gives", C.sub)
		elseif act.stakes then
			local w, l = DoTab.stakeText(ctx, act.stakes.win), DoTab.stakeText(ctx, act.stakes.lose)
			gives = (if w ~= "" then Format.color("WIN  ", C.sub) .. w else "") .. (if w ~= "" and l ~= "" then "     " else "") .. (if l ~= "" then Format.color("LOSE  ", C.sub) .. l else "")
		elseif act.gains then
			local g = DoTab.stakeText(ctx, act.gains)
			gives = if g ~= "" then Format.color("GIVES  ", C.sub) .. g else ""
		end
		row(content, nextOrder(), {
			title = Format.escape(act.name),
			desc = Format.escape(act.desc) .. (if gives ~= "" then "\n" .. gives else ""),
			meta = Format.escape(table.concat(meta, "  ·  ")),
			metaColor = if act.enabled then C.accent else C.faint,
			enabled = act.enabled,
			onClick = function()
				sheet.close()
				if act.clash and act.clash.approaches and #act.clash.approaches > 0 then
					task.delay(0.25, function()
						DoTab.pickStance(ctx, act.name, act.clash, function(approach)
							ctx.actions.interact(rel.id, act.id, approach)
						end, act.stakes)
					end)
				else
					ctx.actions.interact(rel.id, act.id)
				end
			end,
		})
	end
	return sheet
end

-- Friends tab: linked lives with other players in the server.
function Sheets.friendsContent(ctx, content, friends, refresh)
	clear(content)
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	if not friends then
		Kit.text({ Text = "Asking around...", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, ZIndex = 2, Parent = content })
		return
	end
	Kit.text({
		Text = "Link lives with players in this server. Linked friends show up in each other's lives: they can help, team up in clashes, and grieve. With Rough Play on (both of you), they can also cross you.",
		FontFace = F.serif,
		TextSize = 13,
		TextColor3 = C.sub,
		LayoutOrder = nextOrder(),
		ZIndex = 2,
		Parent = content,
	})

	if #friends.invites > 0 then
		sectionTitle(content, "Invites", nextOrder())
		for _, inv in friends.invites do
			row(content, nextOrder(), {
				title = Format.escape(inv.name) .. " wants to link lives",
				accent = C.strange,
				extra = function(btn)
					local bar = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 5, ZIndex = 2, Parent = btn }, {
						Kit.list(8, Enum.FillDirection.Horizontal),
					})
					local yes = Kit.button({ text = "Accept", style = "primary", size = UDim2.new(0.5, -4, 1, 0), order = 1, zIndex = 2, textSize = 14, onClick = function()
						ctx.actions.linkRespond(inv.userId, true, refresh)
					end })
					yes.Parent = bar
					local no = Kit.button({ text = "Decline", style = "ghost", size = UDim2.new(0.5, -4, 1, 0), order = 2, zIndex = 2, textSize = 14, onClick = function()
						ctx.actions.linkRespond(inv.userId, false, refresh)
					end })
					no.Parent = bar
				end,
			})
		end
	end

	sectionTitle(content, string.format("Linked lives (%d of %d)", #friends.links, friends.max or 8), nextOrder())
	if #friends.links == 0 then
		Kit.text({ Text = "Nobody yet.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
	end
	for _, link in friends.links do
		local who = Format.escape(link.name)
		local status
		if not link.online then
			status = "Not in this server"
		elseif link.character and link.character.alive then
			status = string.format("Playing %s %s, %d  ·  %s", link.character.first, link.character.last, link.character.age, link.character.zone)
		else
			status = "Between lives"
		end
		local lines = { Format.escape(status) }
		if link.online and link.character and link.character.alive and link.character.career then
			table.insert(lines, Format.escape(link.character.career))
		end
		personCard(ctx, content, nextOrder(), {
			appearance = link.character and link.character.appearance,
			title = who .. (if link.online then Format.color("  online", C.good) else Format.color("  away", C.faint)),
			lines = lines,
			accent = C.strange,
		})
	end

	sectionTitle(content, "In this server", nextOrder())
	if #friends.players == 0 then
		Kit.text({ Text = "Nobody else here right now. Invite some friends.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
	end
	for _, p in friends.players do
		row(content, nextOrder(), {
			title = Format.escape(p.name),
			meta = "Tap to invite them to link lives",
			onClick = function()
				ctx.actions.linkRequest(p.userId, refresh)
			end,
		})
	end

	sectionTitle(content, "Settings", nextOrder())
	row(content, nextOrder(), {
		title = "Rough Play: " .. (if friends.rough then Format.color("ON", C.bad) else Format.color("OFF", C.good)),
		desc = "When both of you turn this on, linked friends' events can hurt you: theft, betrayal, bad debts.",
		meta = "Tap to turn " .. (if friends.rough then "off" else "on"),
		onClick = function()
			ctx.actions.setRough(not friends.rough, refresh)
		end,
	})
	local invite = Kit.button({
		text = "Invite Roblox friends to this game",
		style = "secondary",
		size = UDim2.new(1, 0, 0, 42),
		order = nextOrder(),
		zIndex = 2,
		onClick = function()
			ctx.actions.inviteFriends()
		end,
	})
	invite.Parent = content
end

local function cityTab(ctx, content)
	local life = ctx.state.life
	local city = ctx.info.city
	for i, d in city.districts do
		local isHere = life and d.id == life.district.id
		row(content, i, {
			title = string.format("%s %d · %s", city.word, d.number, Format.escape(d.name)) .. (if isHere then Format.color("   you live here", C.good) else ""),
			desc = Format.escape(d.desc),
			meta = if d.corp then (Format.escape(d.corp) .. " · " .. Format.escape(d.trade)) else ("No company · " .. Format.escape(d.trade)),
			metaColor = Theme.rgb(d.color or { 200, 200, 200 }),
			highlight = isHere,
			extra = function(btn)
				wardBars(btn, d, 4)
			end,
		})
	end
end

function Sheets.ledgerContent(ctx, content, onChanged)
	local meta = ctx.state.meta
	local info = ctx.info
	clear(content)
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	Kit.text({
		Text = Format.color(tostring(meta.glow), C.accentHi) .. "  " .. info.meta.glowName
			.. Format.color(string.format("     %d lives  ·  oldest %d", meta.livesPlayed or 0, meta.bestAge or 0), C.faint),
		FontFace = F.title,
		TextSize = 20,
		LayoutOrder = nextOrder(),
		ZIndex = 2,
		Parent = content,
	})

	sectionTitle(content, "Origins", nextOrder())
	for _, o in meta.origins do
		local canAfford = meta.glow >= o.cost
		row(content, nextOrder(), {
			title = Format.escape(o.name) .. (if o.side then Format.color("  · " .. o.side, C.faint) else ""),
			desc = Format.escape(o.desc),
			meta = if o.unlocked then "Unlocked" else string.format("Unlock for %d %s", o.cost, info.meta.glowName),
			metaColor = if o.unlocked then C.good elseif canAfford then C.accent else C.faint,
			enabled = o.unlocked or canAfford,
			onClick = if o.unlocked then nil else function()
				ctx.actions.unlockOrigin(o.id, onChanged)
			end,
		})
	end

	if meta.records and #meta.records > 0 then
		local got = 0
		for _, r in meta.records do
			if r.unlocked then
				got += 1
			end
		end
		sectionTitle(content, string.format("Records  %d / %d  (each one is worth 1 %s)", got, #meta.records, info.meta.glowName), nextOrder())
		for _, r in meta.records do
			row(content, nextOrder(), {
				title = Format.escape(r.name) .. (if r.unlocked then Format.color("   EARNED", C.accent) else ""),
				desc = Format.escape(r.desc),
				enabled = r.unlocked,
			})
		end
	end

	sectionTitle(content, info.meta.ledgerName, nextOrder())
	if #meta.lanterns == 0 then
		Kit.text({
			Text = ctx.info.meta.emptyLedger or "No lanterns yet. Every life that ends will float here.",
			FontFace = F.serifItalic,
			TextSize = 14,
			TextColor3 = C.sub,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = content,
		})
	end
	for _, l in meta.lanterns do
		local lines = {
			string.format("Year %d to %d  ·  %d years  ·  %s", l.born, l.died, l.age, l.zone),
		}
		if l.career then
			table.insert(lines, l.career)
		end
		table.insert(lines, l.cause)
		row(content, nextOrder(), {
			title = Format.escape(l.name),
			desc = Format.escape(table.concat(lines, "\n")) .. "\n" .. Format.color("\"" .. Format.escape(l.epitaph) .. "\"", C.sub),
			meta = if l.released then "Released" else string.format("Release for +%d %s", l.glow, info.meta.glowName),
			metaColor = if l.released then C.faint else C.accent,
			enabled = not l.released,
			onClick = if l.released then nil else function()
				ctx.actions.releaseLantern(l.id, onChanged)
			end,
		})
	end
end

local TABS = { "Career", "People", "Gear", "Quests", "Friends", "City", "Ledger" }

-- The quest log: what each side quest wants from you next.
function Sheets.questsContent(ctx, content)
	local life = ctx.state.life
	local quests = (life and life.quests) or {}
	Kit.text({
		Text = "Side quests come from people and places around the city. Each one has a few steps. Do what the step asks and the story moves on.",
		FontFace = F.serif,
		TextSize = 13,
		TextColor3 = C.sub,
		LayoutOrder = 0,
		ZIndex = 2,
		Parent = content,
	})
	local active, done = 0, 0
	for i, q in quests do
		if q.active then
			active += 1
			local card = Kit.panel({ Name = "Quest", LayoutOrder = i, BackgroundColor3 = C.panelLo, ZIndex = 2, Parent = content }, nil, C.strange)
			Kit.padding(12, 14, 12, 14).Parent = card
			Kit.list(4).Parent = card
			Kit.text({ Text = string.upper(Format.escape(q.name)) .. Format.color(string.format("   STEP %d OF %d", q.step, q.steps), C.strange), FontFace = F.display, TextSize = 16, LayoutOrder = 1, ZIndex = 2, Parent = card })
			Kit.text({ Text = Format.escape(q.stepText or ""), FontFace = F.serif, TextSize = 14, LayoutOrder = 2, ZIndex = 2, Parent = card })
			if q.hint then
				Kit.text({ Text = Format.escape(q.hint), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.accent, LayoutOrder = 3, ZIndex = 2, Parent = card })
			end
		else
			done += 1
			row(content, 500 + i, {
				title = Format.escape(q.name) .. Format.color("   DONE", C.good),
				desc = Format.escape(q.desc or ""),
				meta = if q.doneAge then "Finished at age " .. q.doneAge else "",
				enabled = false,
			})
		end
	end
	if active == 0 then
		Kit.text({ Text = "No quests on right now. Keep living; someone will need you.", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.faint, LayoutOrder = 400, ZIndex = 2, Parent = content })
	end
	if done > 0 then
		sectionTitle(content, "Finished", 499)
	end
end

function Sheets.life(ctx, layer: Instance, startTab: string?)
	local sheet = Sheets.open(layer, "Life")
	-- Seven tabs: one row when there's room, two on a phone. Never hidden off the edge.
	local tabs = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		ZIndex = 2,
		Parent = sheet.content,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Wraps = true,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local body = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = sheet.content,
	}, { Kit.list(10) })

	local buttons = {}
	local current = startTab or "Career"
	local function select(name: string)
		current = name
		for tabName, b in buttons do
			b.BackgroundColor3 = if tabName == name then C.accent else C.panelHi
			b.TextColor3 = if tabName == name then C.ink else C.sub
		end
		clear(body)
		if name == "Career" then
			careerTab(ctx, body, sheet)
		elseif name == "People" then
			peopleTab(ctx, body, sheet)
		elseif name == "Quests" then
			Sheets.questsContent(ctx, body)
		elseif name == "Gear" then
			Sheets.gearContent(ctx, body, function()
				if not sheet.isClosed() and current == "Gear" then
					select("Gear")
				end
			end, layer)
		elseif name == "Friends" then
			local function refresh()
				if not sheet.isClosed() and current == "Friends" then
					ctx.actions.loadFriends(function(friends)
						if not sheet.isClosed() and current == "Friends" then
							Sheets.friendsContent(ctx, body, friends, refresh)
						end
					end)
				end
			end
			Sheets.friendsContent(ctx, body, nil, refresh)
			refresh()
		elseif name == "City" then
			cityTab(ctx, body)
		else
			Sheets.ledgerContent(ctx, body, function()
				select("Ledger")
			end)
		end
	end
	for i, name in TABS do
		local b = Kit.button({
			text = name,
			style = "secondary",
			size = UDim2.new(0, 68, 0, 34),
			order = i,
			textSize = 13,
			zIndex = 2,
			onClick = function()
				select(name)
			end,
		})
		b.Parent = tabs
		buttons[name] = b
	end
	select(current)
	return sheet
end

return Sheets
