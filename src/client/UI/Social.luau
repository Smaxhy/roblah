--[[
	Social screens: Rankings (global leaderboards), the Store (looks only),
	the Crew (parties for expeditions) and Goals (this life's ambitions).
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Sheets = require(script.Parent.Sheets)
local AvatarView = require(script.Parent.AvatarView)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Social = {}

local GOLD = Color3.fromRGB(255, 214, 120)
local SILVER = Color3.fromRGB(200, 206, 214)
local BRONZE = Color3.fromRGB(196, 132, 82)
local LUNACY = Color3.fromRGB(240, 92, 120) -- the premium currency's color

local function clear(frame: Instance)
	for _, child in frame:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function tabRow(parent, names, order: number, onPick)
	local tabs = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 34),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, { Kit.list(6, Enum.FillDirection.Horizontal) })
	local buttons = {}
	local function select(id)
		for key, b in buttons do
			b.BackgroundColor3 = if key == id then C.accent else C.panelHi
			b.TextColor3 = if key == id then C.ink else C.sub
		end
		onPick(id)
	end
	for i, item in names do
		local b = Kit.button({ text = item.name, style = "secondary", size = UDim2.new(0, 0, 1, 0), order = i, textSize = 13, zIndex = 2, onClick = function()
			select(item.id)
		end })
		b.AutomaticSize = Enum.AutomaticSize.X
		Kit.padding(0, 12, 0, 12).Parent = b
		b.Parent = tabs
		buttons[item.id] = b
	end
	return select
end

-- ── rankings ────────────────────────────────────────────────────────────────

function Social.rankings(ctx, layer: Instance, startBoard: string?)
	local sheet = Sheets.open(layer, "Rankings")
	local content = sheet.content
	local body = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		ZIndex = 2,
		Parent = content,
	}, { Kit.list(6) })

	local function fill(board)
		clear(body)
		if sheet.isClosed() then
			return
		end
		if not board then
			Kit.text({ Text = "Reading the ledgers...", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, ZIndex = 2, Parent = body })
			return
		end
		Kit.text({ Text = Format.escape(board.desc or ""), FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 0, ZIndex = 2, Parent = body })
		if #board.entries == 0 then
			Kit.text({ Text = "Nobody on this board yet. Finish a life to get on it.", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.faint, LayoutOrder = 1, ZIndex = 2, Parent = body })
		end
		for i, e in board.entries do
			local rankColor = if e.rank == 1 then GOLD elseif e.rank == 2 then SILVER elseif e.rank == 3 then BRONZE else C.faint
			local rowFrame = new("Frame", {
				Name = "Rank",
				BackgroundColor3 = if e.you then C.panelHi else C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 52),
				LayoutOrder = i + 1,
				ZIndex = 2,
				Parent = body,
			}, { Kit.corner(2), Kit.padding(0, 12, 0, 10) })
			Kit.stroke(if e.you then C.accent else C.stroke, 1, if e.you then 0.1 else 0.5).Parent = rowFrame
			new("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 40, 1, 0),
				Text = "#" .. e.rank,
				FontFace = F.display,
				TextSize = if e.rank <= 3 then 20 else 15,
				TextColor3 = rankColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,
				Parent = rowFrame,
			})
			local nameColor = if e.patron then GOLD else C.text
			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 44, 0, 7),
				Size = UDim2.new(1, -150, 0, 20),
				Text = string.upper(Format.escape(e.name or "?")) .. (if e.you then "  (YOU)" else ""),
				FontFace = F.displayMed,
				TextSize = 15,
				TextColor3 = nameColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 2,
				Parent = rowFrame,
			})
			local lifeLine = {}
			if e.life then
				table.insert(lifeLine, e.life)
			end
			if e.title then
				table.insert(lifeLine, e.title)
			end
			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 44, 0, 27),
				Size = UDim2.new(1, -150, 0, 16),
				Text = Format.escape(table.concat(lifeLine, "  ·  ")),
				FontFace = F.ui,
				TextSize = 12,
				TextColor3 = C.sub,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 2,
				Parent = rowFrame,
			})
			new("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 100, 1, 0),
				Text = Format.escape(e.display or Format.number(e.value)) .. (if (board.unit or "") ~= "" then '\n<font size="10" face="Oswald">' .. string.upper(board.unit) .. "</font>" else ""),
				RichText = true,
				FontFace = F.mono,
				TextSize = 16,
				TextColor3 = if e.rank <= 3 then rankColor else C.money,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 2,
				Parent = rowFrame,
			})
		end
	end

	local boards = {
		{ id = "best", name = "Best life" },
		{ id = "week", name = "This week" },
		{ id = "oldest", name = "Oldest" },
		{ id = "richest", name = "Richest" },
		{ id = "lines", name = "Family lines" },
		{ id = "records", name = "Records" },
		{ id = "fixers", name = "Fixers" },
		{ id = "fights", name = "Fights" },
	}
	local select = tabRow(content, boards, 1, function(id)
		fill(nil)
		ctx.actions.loadLeaderboard(id, function(board)
			fill(board)
		end)
	end)
	select(startBoard or "best")
	return sheet
end

-- ── the store ───────────────────────────────────────────────────────────────

-- What a store item looks like on you: your current look (or your last one)
-- with the item's hair, dye, outfit or mark swapped in. Gear is left off so a
-- coat doesn't hide the outfit you're trying on.
local LOOK_CATEGORIES = { skin = true, hair = true, hairColor = true, outfit = true, mark = true }
local function tryOnAppearance(ctx, item)
	local pack = ctx.info and ctx.info.avatar
	if not pack then
		return nil, nil
	end
	local life = ctx.state.life
	local base = if life and life.alive then life.appearance else nil
	local look = table.clone((base and base.look) or (ctx.state.meta and ctx.state.meta.lastLook) or {})
	local changed = false
	local framing = "portrait" -- dyes and marks read best close up
	for _, key in item.grants or {} do
		local category, id = string.match(key, "^([%w_]+):(.+)$")
		if category and LOOK_CATEGORIES[category] then
			look[category] = id
			changed = true
			if category == "outfit" or category == "hair" then
				framing = "full"
			end
		end
	end
	if not changed then
		return nil, nil
	end
	return framing, {
		look = AvatarView.Avatar.sanitize(pack, look),
		age = math.clamp((base and base.age) or 24, 18, 60),
		form = base and base.form,
		sanity = (base and base.sanity) or 0,
		gear = {},
		conditions = {},
	}
end

-- The bracket color a file-card frame item unlocks, if it unlocks one.
local function frameColor(ctx, item): Color3?
	local cosmetics = ctx.info and ctx.info.avatar and ctx.info.avatar.cosmetics
	for _, key in item.grants or {} do
		local id = string.match(key, "^frame:(.+)$")
		if id then
			for _, o in (cosmetics and cosmetics.frame and cosmetics.frame.options) or {} do
				if o.id == id and o.color then
					return Color3.fromRGB(o.color[1], o.color[2], o.color[3])
				end
			end
		end
	end
	return nil
end

-- (v0.18) THE STORE, big and in the middle of the screen: a header with your wallet and a code
-- box, aisles with icons along the top, and the Featured aisle first (the pass with everything
-- in it, the best-value Lunacy, the starter pack). Every badge is a true thing about the item:
-- BEST VALUE is worked out from the Lunacy you get per Robux, FREE is the bonus it really has,
-- PERMANENT is what a pass is. No timers and no "only a few left": nothing here runs out.
local Emblem = require(script.Parent.Emblem)
local Spring = require(script.Parent.Spring)

local ICON_BY_TIER = { Lunacy = "cur.lunacy", Passes = "misc.star", Looks = "tab.you", Boosts = "tab.light", ["Family names"] = "misc.coin_heads" }
local ICON_BY_KEY = {
	boost_heal = "stat.fortitude", boost_ahn = "cur.ahn", boost_mastery = "misc.fight", light_6 = "cur.light", light_25 = "cur.light",
	pass_trait = "thread.life", pass_points = "stat.justice", pass_bloodline = "faction.bloodfiend", pass_vip = "misc.star",
}

local function iconOf(item): string
	return ICON_BY_KEY[item.key or ""] or ICON_BY_TIER[item.tier or ""] or "tab.store"
end

-- Lunacy a pack gives (from what it grants), for the value badge
local function lunacyOf(item): number?
	for _, g in item.grants or {} do
		local n = tonumber(string.match(tostring(g), "^lunacy:(%d+)"))
		if n then
			return n
		end
	end
	return nil
end

local function emblem(parent: Instance, id: string, size: number, pos: UDim2, anchor: Vector2?, color: Color3?)
	local ok, e = pcall(Emblem.make, id, size, color)
	if ok and e then
		e.AnchorPoint = anchor or Vector2.new(0, 0)
		e.Position = pos
		e.ZIndex = 4
		e.Parent = parent
		return e
	end
	return nil
end

-- a ribbon on a card's corner
local function ribbon(parent: Instance, text: string, color: Color3, order: number)
	return new("TextLabel", {
		Name = "Ribbon",
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		FontFace = F.display,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(16, 12, 14),
		Text = string.upper(text),
		LayoutOrder = order,
		ZIndex = 4,
		Parent = parent,
	}, { Kit.corner(11), Kit.padding(0, 10, 0, 10) })
end

function Social.store(ctx, layer: Instance)
	local sheet = Sheets.open(layer, "Store", nil, { wide = true, center = true })
	local content = sheet.content
	local looks = true
	local aisle = nil -- (the open aisle; Featured first when the store sells Lunacy)
	local lastStore, lastNote = nil, nil
	local function fill(store, note, looksOnly)
		if looksOnly ~= nil then
			looks = looksOnly
		end
		lastStore, lastNote = store, note
		clear(content)
		if sheet.isClosed() then
			return
		end
		local wide = content.AbsoluteSize.X >= 620
		local premium = (ctx.info and ctx.info.lunacy) or "Lunacy"
		local meta = ctx.state.meta or {}

		-- ── the front of the shop ──
		local hero = new("Frame", {
			Name = "StoreHero",
			BackgroundColor3 = Color3.fromRGB(26, 16, 22),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = -3,
			ZIndex = 2,
			Parent = content,
		}, { Kit.corner(8), Kit.padding(16, 18, 16, 18), Kit.stroke(GOLD, 1.5, 0.25), Kit.list(10) })
		new("UIGradient", { Rotation = 18, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 30, 52)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(40, 16, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 10, 18)) }), Parent = hero })
		-- (a narrow screen wraps the line under the title onto a third line: room for it)
		local titleRow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, if wide then 52 else 74), LayoutOrder = 1, ZIndex = 3, Parent = hero })
		emblem(titleRow, "tab.store", 48, UDim2.fromOffset(0, 2), nil, GOLD)
		Kit.text({ Text = "THE CITY STORE", FontFace = F.display, TextSize = if wide then 34 else 26, TextColor3 = GOLD, AutomaticSize = Enum.AutomaticSize.None, Position = UDim2.fromOffset(60, 0), Size = UDim2.new(1, -60, 0, 36), ZIndex = 3, Parent = titleRow })
		Kit.text({ Text = "Lunacy, passes and looks for every life you live. Odds are shown before anything random.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, AutomaticSize = Enum.AutomaticSize.None, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(60, 34), Size = UDim2.new(1, -60, 0, if wide then 18 else 40), ZIndex = 3, Parent = titleRow })
		-- the wallet
		local walletRow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 2, ZIndex = 3, Parent = hero }, {
			new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }),
		})
		for i, w in {
			{ "cur.lunacy", string.upper(premium), meta.lunacy or 0, LUNACY },
			{ "cur.light", string.upper((ctx.info and ctx.info.meta and ctx.info.meta.glowName) or "Light"), meta.glow or 0, GOLD },
		} do
			local pill = new("Frame", { Name = "Wallet_" .. i, BackgroundColor3 = Color3.fromRGB(12, 10, 14), BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = i, ZIndex = 3, Parent = walletRow }, {
				Kit.corner(18), Kit.stroke(w[4], 1, 0.3), Kit.padding(0, 14, 0, 40),
			})
			emblem(pill, w[1], 24, UDim2.new(0, -32, 0.5, 0), Vector2.new(0, 0.5), w[4])
			new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, RichText = true, Text = w[2] .. '  <font color="#' .. w[4]:ToHex() .. '" size="20">' .. Format.number(w[3]) .. "</font>", FontFace = F.display, TextSize = 12, TextColor3 = C.sub, ZIndex = 4, Parent = pill })
		end
		-- have a code?
		local codeRow = new("Frame", { Name = "CodeRow", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 3, ZIndex = 3, Parent = hero })
		local codeBox = new("TextBox", {
			Name = "CodeBox",
			BackgroundColor3 = Color3.fromRGB(10, 8, 12),
			BorderSizePixel = 0,
			Size = UDim2.new(1, -128, 1, 0),
			Text = "",
			PlaceholderText = "Have a code? Type it here",
			PlaceholderColor3 = C.faint,
			ClearTextOnFocus = false,
			FontFace = F.mono,
			TextSize = 15,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
			Parent = codeRow,
		}, { Kit.corner(4), Kit.stroke(C.stroke, 1, 0.2), Kit.padding(0, 10, 0, 10) })
		-- (what's typed is kept as it changes, so the button never reads a box a re-render replaced)
		local typed = ""
		local box = codeBox :: TextBox
		box:GetPropertyChangedSignal("Text"):Connect(function()
			typed = box.Text
		end)
		Kit.button({ name = "Redeem", text = "Redeem", style = "primary", size = UDim2.new(0, 118, 1, 0), position = UDim2.new(1, 0, 0, 0), anchor = Vector2.new(1, 0), textSize = 14, zIndex = 3, parent = codeRow, onClick = function()
			local code = typed
			if #code < 2 then
				return
			end
			ctx.actions.redeemCode(code, function(res)
				if res and res.ok then
					typed = ""
					fill(store, note) -- (a fresh store, with an empty box)
				end
			end)
		end })

		if not store then
			Kit.text({ Text = "Opening the shutters...", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, LayoutOrder = 1, ZIndex = 2, Parent = content })
			return
		end

		-- ── the aisles ──
		local tiers = {}
		local sellsLunacy = false
		for _, item in store do
			if item.tier and not table.find(tiers, item.tier) then
				table.insert(tiers, item.tier)
			end
			if item.currency == "lunacy" or lunacyOf(item) then
				sellsLunacy = true
			end
		end
		local names = {}
		if sellsLunacy then
			table.insert(names, "Featured")
		end
		table.insert(names, "Everything")
		for _, t in tiers do
			table.insert(names, t)
		end
		aisle = aisle or names[1]
		local aisles = new("Frame", { Name = "Aisles", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = -2, ZIndex = 2, Parent = content }, {
			new("UIGridLayout", { CellSize = UDim2.new(if wide then 1 / math.min(#names, 7) else 0.25, -6, 0, 60), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		for i, name in names do
			local on = name == aisle
			local b = Kit.button({ name = "Aisle_" .. i, text = "", style = if on then "primary" else "secondary", size = UDim2.fromScale(1, 1), order = i, zIndex = 3, onClick = function()
				aisle = name
				fill(lastStore, lastNote)
			end })
			b.Parent = aisles
			emblem(b, if name == "Featured" then "misc.star" elseif name == "Everything" then "tab.store" else (ICON_BY_TIER[name] or "tab.store"), 22, UDim2.new(0.5, 0, 0, 7), Vector2.new(0.5, 0), if on then C.ink else GOLD)
			Kit.caps({ Text = name, FontFace = F.displayMed, TextSize = 12, TextColor3 = if on then C.ink else C.text, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -5), Size = UDim2.new(1, -4, 0, 16), ZIndex = 4, Parent = b })
		end

		-- the promise, up front
		local promise = new("Frame", { Name = "Promise", BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = -1, ZIndex = 2, Parent = content }, { Kit.corner(4), Kit.padding(10, 12, 10, 12), Kit.stroke(C.strange, 1, 0.3) })
		Kit.text({
			Text = if looks then Format.color("LOOKS ONLY.  ", C.strange) .. Format.escape(note or "Nothing here changes your odds, your money or your score.") else Format.color("HOW IT WORKS.  ", C.strange) .. Format.escape(note or ""),
			FontFace = F.uiMedium,
			TextSize = 13,
			TextColor3 = C.sub,
			ZIndex = 2,
			Parent = promise,
		})

		-- the best value among the Lunacy packs (the most Lunacy per Robux)
		local bestKey, bestRate = nil, 0
		local smallestKey, smallestPrice = nil, math.huge
		for _, item in store do
			local n = lunacyOf(item)
			if n and (item.price or 0) > 0 then
				local rate = n / item.price
				if rate > bestRate then
					bestKey, bestRate = item.key, rate
				end
				if item.price < smallestPrice then
					smallestKey, smallestPrice = item.key, item.price
				end
			end
		end

		local order = 0
		local function nextOrder()
			order += 1
			return order
		end

		-- one item as a card
		local function itemCard(parent: Instance, item, big: boolean?)
			local inLunacy = item.currency == "lunacy"
			local accent = if item.kind == "pass" then GOLD elseif inLunacy then LUNACY else C.accentHi
			local card = new("Frame", {
				Name = "StoreItem",
				BackgroundColor3 = if big then Color3.fromRGB(30, 22, 30) else C.panel,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = parent,
			}, { Kit.corner(8), Kit.stroke(accent, if big then 2 else 1, if big then 0.15 else 0.5), Kit.padding(14, 14, 14, if big then 120 else 92) })
			if big then
				new("UIGradient", { Rotation = 25, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(170, 150, 170)), Parent = card })
			end
			-- (v0.18) pointing at a card lights it and its edge up, on a spring
			Spring.hover(card, { lighten = if big then 0.08 else 0.06 })
			-- the picture: the item on you, a swatch, or its icon in a glowing disc
			local tryFraming, tryOn = tryOnAppearance(ctx, item)
			local swatch = if tryOn then nil else frameColor(ctx, item)
			if tryOn then
				local figure = AvatarView.new(ctx, { size = UDim2.fromOffset(if big then 100 else 76, if big then 120 else 96), position = UDim2.new(0, if big then -110 else -84, 0, -4), framing = tryFraming, background = C.panelLo, zIndex = 3 })
				figure.frame.Name = "TryOn"
				figure.frame.Parent = card
				figure:set(tryOn)
			elseif swatch then
				local mini = new("Frame", { Name = "FrameSwatch", Position = UDim2.new(0, -82, 0, 6), Size = UDim2.fromOffset(70, 50), BackgroundColor3 = C.panel, BorderSizePixel = 0, ZIndex = 3, Parent = card }, { Kit.corner(3), Kit.stroke(C.stroke, 1, 0.2) })
				Kit.brackets(mini, swatch, 12, 3, 3)
			else
				local disc = new("Frame", { Name = "Icon", BackgroundColor3 = accent, BackgroundTransparency = 0.82, BorderSizePixel = 0, Position = UDim2.new(0, if big then -106 else -80, 0, 0), Size = UDim2.fromOffset(if big then 92 else 68, if big then 92 else 68), ZIndex = 3, Parent = card }, { Kit.corner(46), Kit.stroke(accent, 1.5, 0.35) })
				emblem(disc, iconOf(item), if big then 56 else 40, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), accent)
			end
			local body = new("Frame", { Name = "Body", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 3, Parent = card }, { Kit.list(6) })
			-- badges: only true things
			local tags = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 0, ZIndex = 3, Parent = body }, {
				new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			local nTags = 0
			local function tag(text: string, color: Color3)
				nTags += 1
				ribbon(tags, text, color, nTags)
			end
			if item.key == bestKey then
				tag("Best value", Color3.fromRGB(120, 230, 150))
			end
			if item.bonus and not (item.key == bestKey and string.find(string.lower(item.bonus), "best", 1, true)) then
				tag(item.bonus, LUNACY)
			end
			if item.key == smallestKey then
				tag("Starter", C.accentHi)
			end
			if item.kind == "pass" then
				tag("Permanent", GOLD)
			end
			if item.key == "pass_vip" then
				tag("Everything in one", GOLD)
			end
			if item.random then
				tag("Odds shown", C.strange)
			end
			if nTags == 0 then
				tags:Destroy()
			end
			Kit.text({ Text = string.upper(Format.escape(item.name)), FontFace = F.display, TextSize = if big then 24 else 17, TextColor3 = if big then GOLD else C.text, LayoutOrder = 1, ZIndex = 3, Parent = body })
			Kit.text({ Text = Format.escape(item.desc), FontFace = F.serif, TextSize = if big then 15 else 13, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 3, Parent = body })
			local n = lunacyOf(item)
			if n and (item.price or 0) > 0 then
				Kit.caps({ Text = string.format("%d %s  ·  %.1f per Robux", n, premium, n / item.price), FontFace = F.displayMed, TextSize = 11, TextColor3 = LUNACY, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 3, ZIndex = 3, Parent = body })
			end
			-- paid random items show their odds before you buy
			if item.random and item.odds then
				Kit.text({ Text = Format.color("ODDS  ", C.strange) .. Format.escape(item.odds), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 4, ZIndex = 3, Parent = body })
			end
			if item.reason then
				Kit.text({ Text = Format.escape(item.reason), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.faint, LayoutOrder = 5, ZIndex = 3, Parent = body })
			elseif item.owned then
				Kit.caps({ Text = "Owned", FontFace = F.display, TextSize = 14, TextColor3 = C.good, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 5, ZIndex = 3, Parent = body })
			else
				local buy = Kit.button({
					name = "Buy",
					text = if inLunacy
						then (if item.affordable == false then string.format("Need %d %s", item.lunacy or 0, premium) else string.format("%d %s", item.lunacy or 0, premium))
						else string.format("R$ %d%s", item.price or 0, if item.test then "  (test)" else ""),
					style = if inLunacy and item.affordable == false then "secondary" else "primary",
					size = UDim2.new(0, if big then 220 else 170, 0, if big then 44 else 36),
					order = 6,
					textSize = if big then 17 else 14,
					zIndex = 3,
					onClick = function()
						ctx.actions.buyItem(item, function(updated)
							fill(updated, note)
						end)
					end,
					enabled = item.buyable ~= false and item.affordable ~= false,
				})
				buy.Parent = body
			end
			return card
		end

		local function grid(name: string)
			return new("Frame", { Name = name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
				new("UIGridLayout", { CellSize = UDim2.new(if wide then 0.5 else 1, -6, 0, if wide then 236 else 246), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
		end
		local function heading(text: string, icon: string)
			local h = Sheets.sectionTitle(content, text, nextOrder())
			h.Name = "Section_" .. text
			local _ = icon
			return h
		end

		if aisle == "Featured" then
			-- the hero: the pass that holds everything (or, if it's theirs already, the next one)
			local hero2 = nil
			for _, key in { "pass_vip", "pass_bloodline", "pass_points", "pass_trait" } do
				for _, item in store do
					if item.key == key and not item.owned and not hero2 then
						hero2 = item
					end
				end
			end
			if hero2 then
				heading("Featured", "misc.star")
				itemCard(content, hero2, true)
			end
			-- the best value and the starter
			local pair = {}
			for _, item in store do
				if (item.key == bestKey or item.key == smallestKey) and not table.find(pair, item) then
					table.insert(pair, item)
				end
			end
			if #pair > 0 then
				heading(premium .. ": the best value, and a place to start", "cur.lunacy")
				local g = grid("FeaturedLunacy")
				for _, item in pair do
					itemCard(g, item)
				end
			end
			-- the other passes, if any
			local passes = {}
			for _, item in store do
				if item.kind == "pass" and item ~= hero2 then
					table.insert(passes, item)
				end
			end
			if #passes > 0 then
				heading("Passes: once, for every life", "misc.star")
				local g = grid("FeaturedPasses")
				for _, item in passes do
					itemCard(g, item)
				end
			end
			return
		end
		for _, tier in tiers do
			if aisle == "Everything" or aisle == tier then
				local items = {}
				for _, item in store do
					if item.tier == tier then
						table.insert(items, item)
					end
				end
				if #items > 0 then
					heading(tier, ICON_BY_TIER[tier] or "tab.store")
					local g = grid("Grid_" .. tier)
					for _, item in items do
						itemCard(g, item)
					end
				end
			end
		end
	end
	fill(nil, nil)
	ctx.actions.loadStore(function(store, note, looksOnly)
		fill(store, note, looksOnly)
	end)
	return sheet
end

-- ── duels ───────────────────────────────────────────────────────────────────

-- Who you can duel: linked friends and crewmates who are online.
function Social.duels(ctx, layer: Instance)
	local sheet = Sheets.open(layer, "Duels")
	local content = sheet.content
	local function fill(targets)
		clear(content)
		if sheet.isClosed() then
			return
		end
		Kit.text({
			Text = "Fight a friend with everything you have: your stats, your style, gear and talent. First blood wins. If you both play rough, the loser can die.",
			FontFace = F.serif,
			TextSize = 13,
			TextColor3 = C.sub,
			LayoutOrder = 0,
			ZIndex = 2,
			Parent = content,
		})
		if not targets then
			Kit.text({ Text = "Looking for opponents...", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, LayoutOrder = 1, ZIndex = 2, Parent = content })
			return
		end
		if #targets == 0 then
			Kit.text({ Text = "Link with a friend or make a crew first. Then you can duel them here.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = 1, ZIndex = 2, Parent = content })
		end
		for i, t in targets do
			Sheets.personCard(ctx, content, i + 1, {
				appearance = t.appearance,
				title = Format.escape(t.name) .. (if t.rough then Format.color("  BLOOD DUEL", C.crimsonHi) else ""),
				lines = { if t.character then Format.escape(t.character) else "Between lives", if t.blocked then Format.color(Format.escape(t.blocked), C.faint) else nil },
				accent = if t.rough then C.crimson else C.accent,
				dim = t.blocked ~= nil,
				extra = function(column)
					Kit.button({
						name = "Challenge",
						text = "Challenge",
						style = if t.rough then "danger" else "primary",
						size = UDim2.new(0, 120, 0, 30),
						order = 9,
						zIndex = 2,
						textSize = 13,
						enabled = t.blocked == nil,
						onClick = function()
							ctx.actions.duelChallenge(t.userId)
						end,
					}).Parent = column
				end,
			})
		end
	end
	fill(nil)
	ctx.actions.loadDuelTargets(fill)
	return sheet
end

-- ── the crew ────────────────────────────────────────────────────────────────

function Social.crew(ctx, layer: Instance)
	local sheet = Sheets.open(layer, "Crew", nil, { tall = true, wide = true })
	local content = sheet.content
	local refresh

	local function fill(state)
		clear(content)
		if sheet.isClosed() then
			return
		end
		local order = 0
		local function nextOrder()
			order += 1
			return order
		end
		if not state then
			Kit.text({ Text = "Rounding everyone up...", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, ZIndex = 2, Parent = content })
			return
		end
		Kit.text({
			Text = "A crew goes on expeditions together: the captain proposes one, everyone readies up, the captain makes the calls. Every extra crewmate adds a coin to your clashes.",
			FontFace = F.serif,
			TextSize = 13,
			TextColor3 = C.sub,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = content,
		})
		for _, inv in state.invites or {} do
			Sheets.row(content, nextOrder(), {
				title = Format.escape(inv.name) .. " wants you in their crew",
				accent = C.strange,
				extra = function(btn)
					local bar = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 5, ZIndex = 2, Parent = btn }, { Kit.list(8, Enum.FillDirection.Horizontal) })
					Kit.button({ text = "Join", style = "primary", size = UDim2.new(0.5, -4, 1, 0), order = 1, zIndex = 2, textSize = 14, onClick = function()
						ctx.actions.crewCall("crewRespond", { userId = inv.userId, accept = true }, refresh)
					end }).Parent = bar
					Kit.button({ text = "No thanks", style = "ghost", size = UDim2.new(0.5, -4, 1, 0), order = 2, zIndex = 2, textSize = 14, onClick = function()
						ctx.actions.crewCall("crewRespond", { userId = inv.userId, accept = false }, refresh)
					end }).Parent = bar
				end,
			})
		end
		local crew = state.crew
		if not crew then
			Kit.button({ text = "Start a crew", style = "primary", size = UDim2.new(1, 0, 0, 44), order = nextOrder(), zIndex = 2, onClick = function()
				ctx.actions.crewCall("crewCreate", nil, refresh)
			end }).Parent = content
		else
			Sheets.sectionTitle(content, string.format("Your crew (%d of %d)", #crew.members, crew.max or 4), nextOrder())
			for _, m in crew.members do
				local character = m.character
				local readyTogether = crew.together and crew.together.ready and crew.together.ready[tostring(m.userId)]
				Sheets.personCard(ctx, content, nextOrder(), {
					appearance = character and character.appearance,
					title = Format.escape(m.name) .. (if m.leader then Format.color("  CAPTAIN", C.accent) else "") .. (if m.ready then Format.color("  READY", C.good) else "") .. (if readyTogether then Format.color("  CHARACTER MADE", C.strange) else ""),
					lines = { if character then Format.escape(string.format("%s %s, %d", character.first, character.last, character.age)) else "Between lives" },
					accent = if m.leader then C.accent else C.strange,
					extra = if crew.captain and not m.leader then function(column)
						Kit.button({ text = "Let go", style = "ghost", size = UDim2.new(0, 90, 0, 26), order = 9, zIndex = 2, textSize = 12, onClick = function()
							ctx.actions.crewCall("crewKick", { userId = m.userId }, refresh)
						end }).Parent = column
					end else nil,
				})
			end
			-- starting new lives together is the lobby's job (a whole screen: UI/Lobby)
			Sheets.sectionTitle(content, "Start new lives together", nextOrder())
			Kit.button({
				name = "OpenLobby",
				text = if crew.lobby then "Back to the lobby" else "Open a lobby",
				style = if crew.lobby then "primary" else "secondary",
				size = UDim2.new(1, 0, 0, 44),
				order = nextOrder(),
				zIndex = 2,
				onClick = function()
					sheet.close()
					task.delay(0.25, ctx.actions.openLobby)
				end,
			}).Parent = content

			-- aging up together: everyone readies up for the next year
			Sheets.sectionTitle(content, "Aging up", nextOrder())
			local age = crew.age
			Kit.text({
				Text = if crew.syncAge == false
					then "Everyone ages up on their own."
					elseif age then string.format("%d of %d ready for the next year.%s", age.ready or 0, age.total or 0, if age.youReady then " You're ready." else " Press Age Up when you are.")
					else "Your crew ages up together: everyone presses Age Up, then the year turns for all of you.",
				FontFace = F.serif,
				TextSize = 13,
				TextColor3 = C.sub,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = content,
			})
			if crew.captain then
				local abar = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, { Kit.list(8, Enum.FillDirection.Horizontal) })
				Kit.button({
					name = "SyncAge",
					text = if crew.syncAge == false then "Age up together" else "Age up separately",
					style = "ghost",
					size = UDim2.new(0.5, -4, 1, 0),
					order = 1,
					zIndex = 2,
					textSize = 13,
					onClick = function()
						ctx.actions.crewCall("crewSyncAge", { on = crew.syncAge == false }, refresh)
					end,
				}).Parent = abar
				if age and age.youReady then
					Kit.button({
						name = "AgeNow",
						text = if age.canForce then "Go without them" else string.format("Go without them (%ds)", age.waitLeft or 0),
						style = if age.canForce then "primary" else "ghost",
						size = UDim2.new(0.5, -4, 1, 0),
						order = 2,
						zIndex = 2,
						textSize = 13,
						enabled = age.canForce == true,
						onClick = function()
							sheet.close()
							ctx.actions.crewAgeNow()
						end,
					}).Parent = abar
				end
			end
			Kit.button({
				name = "Duels",
				text = "Duel a crewmate or friend",
				style = "secondary",
				size = UDim2.new(1, 0, 0, 38),
				order = nextOrder(),
				zIndex = 2,
				textSize = 13,
				onClick = function()
					sheet.close()
					task.delay(0.25, ctx.actions.openDuels)
				end,
			}).Parent = content

			if crew.proposal then
				Sheets.sectionTitle(content, "Ready check", nextOrder())
				Sheets.row(content, nextOrder(), {
					title = Format.escape(crew.proposal.name),
					desc = Format.escape(crew.proposal.desc),
					meta = string.format("%d seconds to get ready", crew.proposal.secondsLeft or 0),
					highlight = true,
				})
				if not crew.proposal.youReady then
					local bar = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, { Kit.list(8, Enum.FillDirection.Horizontal) })
					Kit.button({ text = "Ready", style = "primary", size = UDim2.new(0.5, -4, 1, 0), order = 1, zIndex = 2, onClick = function()
						ctx.actions.crewCall("crewReady", { accept = true }, refresh)
					end }).Parent = bar
					Kit.button({ text = "Not ready", style = "ghost", size = UDim2.new(0.5, -4, 1, 0), order = 2, zIndex = 2, onClick = function()
						ctx.actions.crewCall("crewReady", { accept = false }, refresh)
					end }).Parent = bar
				end
			elseif crew.captain and not crew.run then
				Sheets.sectionTitle(content, "Propose an expedition", nextOrder())
				local life = ctx.state.life
				local any = false
				for _, ex in (life and life.expeditions) or {} do
					if ex.crewMax >= #crew.members then
						any = true
						Sheets.row(content, nextOrder(), {
							title = Format.escape(ex.name) .. Format.color("  " .. string.upper(ex.kind), C.faint),
							desc = Format.escape(ex.desc),
							meta = if ex.enabled then string.format("Crew of up to %d  ·  tap to propose", ex.crewMax) else (ex.reason or "Not available"),
							metaColor = if ex.enabled then C.accent else C.faint,
							enabled = ex.enabled,
							onClick = function()
								ctx.actions.crewCall("crewPropose", { id = ex.id }, refresh)
							end,
						})
					end
				end
				if not any then
					Kit.text({ Text = "No expeditions open for a crew this size right now.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
				end
			elseif crew.run then
				Sheets.row(content, nextOrder(), {
					title = "Out on: " .. Format.escape(crew.run.name),
					desc = "Step " .. tostring(crew.run.step or 1) .. ". " .. (if crew.captain then "You're making the calls." else "The captain is making the calls; you can suggest."),
					highlight = true,
					onClick = function()
						sheet.close()
						ctx.actions.openRun()
					end,
				})
			end
			Kit.button({ text = "Leave the crew", style = "danger", size = UDim2.new(1, 0, 0, 38), order = nextOrder(), zIndex = 2, textSize = 14, onClick = function()
				ctx.actions.crewCall("crewLeave", nil, refresh)
			end }).Parent = content
		end
		if (not crew) or (#crew.members < (crew.max or 4)) then
			Sheets.sectionTitle(content, "Invite someone in this server", nextOrder())
			if #(state.players or {}) == 0 then
				Kit.text({ Text = "Nobody else is here right now.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
			end
			for _, p in state.players or {} do
				Sheets.row(content, nextOrder(), {
					title = Format.escape(p.name) .. (if p.inCrew then Format.color("  in a crew", C.faint) else ""),
					meta = "Tap to invite",
					onClick = function()
						ctx.actions.crewCall("crewInvite", { userId = p.userId }, refresh)
					end,
				})
			end
		end
	end

	function refresh(state)
		if state then
			fill(state)
		else
			ctx.actions.crewCall("crewState", nil, function(s)
				fill(s)
			end)
		end
	end
	fill(nil)
	refresh(nil)
	ctx.crewSheetRefresh = function()
		if not sheet.isClosed() then
			refresh(nil)
		end
	end
	return sheet
end

-- ── goals ───────────────────────────────────────────────────────────────────

function Social.goals(ctx, layer: Instance)
	-- (v0.13) the Goals sheet: phase, ambitions, cases, episodes and the feats board
	local okG, Goals = pcall(function()
		return require(script.Parent.Goals) :: any
	end)
	if okG and Goals then
		return Goals.open(ctx, layer)
	end
	local sheet = Sheets.open(layer, "Ambitions")
	local content = sheet.content
	local life = ctx.state.life
	Kit.text({
		Text = "Three goals at a time. Meet one and another takes its place. Each one met adds to this life's score.",
		FontFace = F.serif,
		TextSize = 13,
		TextColor3 = C.sub,
		LayoutOrder = 0,
		ZIndex = 2,
		Parent = content,
	})
	for i, a in (life and life.ambitions) or {} do
		local card = Kit.panel({ LayoutOrder = i, BackgroundColor3 = C.panelLo, ZIndex = 2, Parent = content }, nil, C.accent)
		Kit.padding(12, 14, 12, 14).Parent = card
		Kit.list(6).Parent = card
		Kit.text({ Text = string.upper(Format.escape(a.name)), FontFace = F.display, TextSize = 16, LayoutOrder = 1, ZIndex = 2, Parent = card })
		Kit.text({ Text = Format.escape(a.desc), FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = card })
		if a.progress then
			local track = new("Frame", { BackgroundColor3 = C.panel, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 8), LayoutOrder = 3, ZIndex = 2, Parent = card }, { Kit.corner(1) })
			new("Frame", { BackgroundColor3 = C.accent, BorderSizePixel = 0, Size = UDim2.new(math.clamp(a.progress, 0, 1), 0, 1, 0), ZIndex = 2, Parent = track }, { Kit.corner(1) })
		end
	end
	-- side quests in progress
	local any = false
	for _, q in (life and life.quests) or {} do
		if q.active then
			if not any then
				any = true
				Sheets.sectionTitle(content, "Side quests", 20)
			end
			Sheets.row(content, 21, {
				title = Format.escape(q.name) .. Format.color(string.format("   %d/%d", q.step, q.steps), C.strange),
				desc = Format.escape(q.stepText or ""),
				meta = if q.hint then Format.escape(q.hint) else "",
				accent = C.strange,
			})
		end
	end
	if not life or #(life.ambitions or {}) == 0 then
		Kit.text({ Text = "Nothing to aim for yet. Give it a year or two.", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.faint, LayoutOrder = 9, ZIndex = 2, Parent = content })
	end
	if life then
		Kit.text({
			Text = string.format("This life's score so far: %s", Format.color(Format.number(life.score or 0), C.money)),
			FontFace = F.displayMed,
			TextSize = 15,
			LayoutOrder = 10,
			ZIndex = 2,
			Parent = content,
		})
	end
	return sheet
end

-- a small avatar helper other screens use
Social.AvatarView = AvatarView

return Social
