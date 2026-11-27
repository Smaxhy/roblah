--[[
	ARSENAL (v0.13): what you carry, what you own, and what the Workshops sell, drawn as
	framed tiles in their rarity's color.
		Arsenal.gear(ctx, content, refresh, layer)   the YOU tab's gear page
		Arsenal.shop(ctx, layer)                     the Workshop sheet
	The gear page: the three slots you carry (each a big tile), the set bonuses that are on,
	how far each stat may go, and the stash (equip, or sell to a Workshop). The Workshop: tabs
	by slot, sorted by rarity then price, each tile saying what it does and what it costs.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Emblem = require(script.Parent.Emblem)
local AvatarView = require(script.Parent.AvatarView)

local C, F = Theme.colors, Theme.fonts
local new = Kit.new

local Arsenal = {}

local RARITY = {
	common = { name = "Common", color = Color3.fromRGB(150, 150, 156), rank = 1 },
	uncommon = { name = "Uncommon", color = Color3.fromRGB(110, 196, 120), rank = 2 },
	rare = { name = "Rare", color = Color3.fromRGB(96, 160, 236), rank = 3 },
	epic = { name = "Epic", color = Color3.fromRGB(178, 110, 236), rank = 4 },
	legendary = { name = "Legendary", color = Color3.fromRGB(240, 186, 70), rank = 5 },
	unreal = { name = "Unreal", color = Color3.fromRGB(236, 80, 120), rank = 6 },
}
Arsenal.RARITY = RARITY

local SLOT = {
	tool = { name = "Weapon", icon = "misc.fight" },
	coat = { name = "Coat", icon = "tab.you" },
	charm = { name = "Charm", icon = "misc.star" },
	arm = { name = "Augment arm", icon = "stat.strength" }, -- (v0.17)
}

function Arsenal.rarity(id: string?): any
	return RARITY[id or "common"] or RARITY.common
end

local function clear(frame: Instance)
	for _, child in frame:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function heading(parent, text: string, order: number, color: Color3?)
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = order, ZIndex = 2, Parent = parent })
	Kit.caps({ Text = string.upper(text), Size = UDim2.new(1, 0, 1, 0), FontFace = F.display, TextSize = 13, TextColor3 = color or C.crimsonHi, ZIndex = 2, Parent = row })
	new("Frame", { BackgroundColor3 = color or C.crimsonHi, BackgroundTransparency = 0.6, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 2, Parent = row })
	return row
end

-- one item, framed in its rarity: { name, rarity, slot, effect, desc, set, price?, value?, ... }
-- opts: { big, carried, note, noteColor, buttons = { { text, style, onClick, enabled } }, dim }
function Arsenal.tile(parent: Instance, item: any, order: number, opts: any): Frame
	opts = opts or {}
	local r = Arsenal.rarity(item.rarity)
	local tile = new("Frame", {
		Name = "Item",
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, {
		Kit.corner(6),
		Kit.stroke(r.color, if opts.carried then 2 else 1, if opts.dim then 0.6 else 0.15),
		Kit.padding(10, 12, 10, 12),
		Kit.list(5),
	})
	-- the rarity glow along the top
	local glowLayer = new("Folder", { Name = "Glow", Parent = tile })
	new("Frame", { BackgroundColor3 = r.color, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, if opts.big then 44 else 30), ZIndex = 2, Parent = glowLayer }, {
		Kit.corner(6),
		new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, if opts.dim then 0.85 else 0.62), NumberSequenceKeypoint.new(1, 1) }), Rotation = 90 }),
	})
	local head = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, if opts.big then 30 else 24), LayoutOrder = 1, ZIndex = 3, Parent = tile }, {
		Kit.list(8, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center),
	})
	local slot = SLOT[item.slot or "tool"] or SLOT.tool
	local mark = Emblem.make(slot.icon, if opts.big then 22 else 18, r.color, r.color)
	mark.LayoutOrder = 1
	mark.ZIndex = 3
	mark.Parent = head
	Kit.raise(mark, 3)
	Kit.text({
		Text = Format.escape(item.name or "?"),
		FontFace = F.displayMed,
		TextSize = if opts.big then 18 else 15,
		TextColor3 = if opts.dim then C.faint else C.text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, if opts.big then -32 else -26, 1, 0),
		TextWrapped = false,
		LayoutOrder = 2,
		ZIndex = 3,
		Parent = head,
	})
	-- rarity · slot · set
	local tags = r.name .. "  ·  " .. slot.name .. (if item.set and item.setName then "  ·  " .. item.setName elseif item.set then "  ·  set" else "") .. (if item.unique then "  ·  one of a kind" else "")
	Kit.caps({ Text = string.upper(tags), Size = UDim2.new(1, 0, 0, 14), TextSize = 11, TextColor3 = r.color, LayoutOrder = 2, ZIndex = 3, Parent = tile })
	-- (fixed-height text areas, so every tile in a grid lines up and nothing spills)
	if item.effect and item.effect ~= "" then
		Kit.text({ Text = Format.escape(item.effect), FontFace = F.uiMedium, TextSize = 12, TextColor3 = if opts.dim then C.faint else C.accentHi, AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.new(1, 0, 0, 44), TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 3, ZIndex = 3, Parent = tile })
	end
	if opts.big and item.desc and item.desc ~= "" then
		Kit.text({ Text = Format.escape(item.desc), FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.sub, AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.new(1, 0, 0, 30), TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 4, ZIndex = 3, Parent = tile })
	end
	if opts.note then
		Kit.text({ Text = opts.note, FontFace = F.displayMed, TextSize = 12, TextColor3 = opts.noteColor or C.faint, AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.new(1, 0, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 5, ZIndex = 3, Parent = tile })
	end
	if opts.buttons and #opts.buttons > 0 then
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 6, ZIndex = 3, Parent = tile }, {
			Kit.list(8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right),
		})
		for i, b in opts.buttons do
			local btn = Kit.button({
				text = b.text,
				style = b.style or "ghost",
				size = UDim2.new(0, b.width or 96, 0, 28),
				order = i,
				zIndex = 3,
				textSize = 13,
				enabled = b.enabled ~= false,
				onClick = b.onClick,
			})
			btn.Parent = row
		end
	end
	return tile
end

local function grid(parent: Instance, order: number, columns: number, height: number): Frame
	local holder = new("Frame", {
		Name = "Grid",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	})
	new("UIGridLayout", {
		CellSize = UDim2.new(1 / columns, -8 * (columns - 1) / columns, 0, height),
		CellPadding = UDim2.fromOffset(8, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})
	return holder
end

local function columnsFor(content: Instance): number
	local w = (content :: any).AbsoluteSize.X
	if w <= 0 then
		return 2
	end
	return if w >= 760 then 3 elseif w >= 420 then 2 else 1
end

local function setNames(ctx): { [string]: string }
	return (ctx.info and ctx.info.gearSets) or {}
end

-- ── the gear page ──────────────────────────────────────────────────────────

function Arsenal.gear(ctx, content, refresh, layer)
	clear(content)
	local life = ctx.state.life
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	local sets = setNames(ctx)
	-- you, wearing it
	local figure = AvatarView.new(ctx, { size = UDim2.new(1, 0, 0, 200), framing = "full", chart = true, order = nextOrder(), zIndex = 2 })
	figure.frame.Parent = content
	Kit.stroke(C.stroke, 1, 0.3).Parent = figure.frame
	figure:set(life.appearance)

	heading(content, "Carrying", nextOrder())
	local bySlot = {}
	for _, g in life.gear or {} do
		bySlot[g.slot] = g
	end
	local slots = grid(content, nextOrder(), columnsFor(content), 204)
	for i, slot in { "tool", "coat", "charm", "arm" } do
		local g = bySlot[slot]
		if g then
			local item = table.clone(g)
			item.setName = item.set and sets[item.set]
			Arsenal.tile(slots, item, i, {
				big = true,
				carried = true,
				buttons = { { text = "Take off", style = "ghost", onClick = function()
					ctx.actions.dropGear(slot, refresh)
				end } },
			})
		else
			local empty = new("Frame", { BackgroundColor3 = C.panelLo, BackgroundTransparency = 0.4, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 2, Parent = slots }, {
				Kit.corner(6),
				Kit.stroke(C.stroke, 1, 0.4),
				Kit.padding(12, 12, 12, 12),
			})
			Kit.caps({ Text = string.upper(SLOT[slot].name) .. "  ·  EMPTY", Size = UDim2.new(1, 0, 0, 16), TextSize = 12, TextColor3 = C.faint, ZIndex = 2, Parent = empty })
			Kit.text({ Text = if slot == "arm" then "Your own arm, for now. Workshops and clinics fit augment arms from 18: each brings its own way of fighting." else "Nothing here yet. A Workshop, a delve or a fight could change that.", Position = UDim2.fromOffset(0, 22), FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.faint, ZIndex = 2, Parent = empty })
		end
	end

	-- sets that are on
	if life.sets and #life.sets > 0 then
		heading(content, "Set bonuses", nextOrder(), C.accentHi)
		for _, s in life.sets do
			Kit.text({
				Text = Format.color(string.upper(Format.escape(s.name)) .. "  ·  " .. s.pieces .. " PIECES", C.accentHi) .. "\n" .. Format.escape(s.desc or ""),
				FontFace = F.uiMedium,
				TextSize = 13,
				TextColor3 = C.text,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = content,
			})
		end
	end

	-- limits past 100
	local past = {}
	for key, cap in life.caps or {} do
		if cap > 100 then
			local def = ctx.info.stats and ctx.info.stats.defs and ctx.info.stats.defs[key]
			table.insert(past, string.format("%s %d", (def and def.short) or key, cap))
		end
	end
	if #past > 0 then
		table.sort(past)
		Kit.text({
			Text = Format.color("LIMITS BROKEN  ", C.strange) .. table.concat(past, "   "),
			FontFace = F.displayMed,
			TextSize = 13,
			TextColor3 = C.text,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = content,
		})
	end

	-- the stash
	local stash = life.stash or {}
	heading(content, string.format("Stash  ·  %d", #stash), nextOrder())
	if #stash == 0 then
		Kit.text({ Text = "What you replace comes here instead of the bin. Take it back out whenever you like, or sell it to a Workshop.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
	else
		table.sort(stash, function(a, b)
			local ra, rb = Arsenal.rarity(a.rarity).rank, Arsenal.rarity(b.rarity).rank
			if ra ~= rb then
				return ra > rb
			end
			return (a.name or "") < (b.name or "")
		end)
		local g = grid(content, nextOrder(), columnsFor(content), 160)
		for i, item in stash do
			local it = table.clone(item)
			it.setName = it.set and sets[it.set]
			local buttons = { { text = "Equip", style = "primary", onClick = function()
				ctx.actions.equipGear(item.id, refresh)
			end } }
			if item.value then
				table.insert(buttons, { text = "Sell " .. Format.number(item.value), style = "ghost", width = 110, onClick = function()
					ctx.actions.sellGear(item.id, refresh)
				end })
			end
			Arsenal.tile(g, it, i, { buttons = buttons })
		end
	end

	local shopButton = Kit.button({
		text = "Visit a workshop",
		style = "primary",
		size = UDim2.new(1, 0, 0, 44),
		order = nextOrder(),
		zIndex = 2,
		onClick = function()
			Arsenal.shop(ctx, layer)
		end,
	})
	shopButton.Parent = content
end

-- ── the Workshop ───────────────────────────────────────────────────────────

local TABS = { { id = "all", name = "All" }, { id = "tool", name = "Weapons" }, { id = "coat", name = "Coats" }, { id = "charm", name = "Charms" }, { id = "arm", name = "Arms" }, { id = "set", name = "Sets" } }

function Arsenal.shop(ctx, layer: Instance)
	local Sheets = require(script.Parent.Sheets) :: any
	local sheet = Sheets.open(layer, "Workshop", nil, { tall = true, wide = true })
	local tab = "all"
	local function fill()
		clear(sheet.content)
		local life = ctx.state.life
		local sets = setNames(ctx)
		local order = 0
		local function nextOrder()
			order += 1
			return order
		end
		Kit.text({
			Text = Format.color(Format.number(life.money), C.money) .. "  " .. ctx.info.meta.currency .. Format.color("     buying doesn't use an action  ·  what you replace goes in your stash", C.faint),
			FontFace = F.displayMed,
			TextSize = 15,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = sheet.content,
		})
		-- tabs
		local bar = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = nextOrder(), ZIndex = 2, Parent = sheet.content }, {
			Kit.list(6, Enum.FillDirection.Horizontal),
		})
		for i, t in TABS do
			local b = Kit.button({
				text = t.name,
				style = if t.id == tab then "primary" else "ghost",
				size = UDim2.new(0, 92, 0, 30),
				order = i,
				zIndex = 2,
				textSize = 13,
				onClick = function()
					tab = t.id
					fill()
				end,
			})
			b.Parent = bar
		end
		-- the stock, grouped by rarity, best first
		local list = {}
		for _, item in life.shop or {} do
			if tab == "all" or item.slot == tab or (tab == "set" and item.set ~= nil) then
				table.insert(list, item)
			end
		end
		table.sort(list, function(a, b)
			if tab == "set" and (a.set or "") ~= (b.set or "") then
				return (a.set or "") < (b.set or "")
			end
			local ra, rb = Arsenal.rarity(a.rarity).rank, Arsenal.rarity(b.rarity).rank
			if ra ~= rb then
				return ra > rb
			end
			return (a.price or 0) < (b.price or 0)
		end)
		local lastGroup = nil
		local g = nil
		local cols = columnsFor(sheet.content)
		for i, item in list do
			local group = if tab == "set" then (sets[item.set] or item.set) else Arsenal.rarity(item.rarity).name
			if group ~= lastGroup then
				lastGroup = group
				heading(sheet.content, group, nextOrder(), if tab == "set" then C.accentHi else Arsenal.rarity(item.rarity).color)
				g = grid(sheet.content, nextOrder(), cols, 180)
			end
			local it = table.clone(item)
			it.setName = it.set and sets[it.set]
			local note, color
			if item.owned then
				note, color = "You own this", C.good
			elseif not item.enabled and item.reason then
				note, color = item.reason, C.faint
			else
				note = Format.number(item.price) .. " " .. ctx.info.meta.currency .. (if item.listPrice then Format.color("  (was " .. Format.number(item.listPrice) .. ")", C.faint) else "")
				color = C.money
			end
			Arsenal.tile(g :: any, it, i, {
				dim = not item.enabled and not item.owned,
				carried = item.owned,
				note = note,
				noteColor = color,
				buttons = if item.enabled and not item.owned then { { text = "Buy", style = "primary", onClick = function()
					ctx.actions.buyGear(item.id, fill)
				end } } else nil,
			})
		end
		if #list == 0 then
			Kit.text({ Text = "Nothing here for you yet.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = sheet.content })
		end
	end
	fill()
	return sheet
end

return Arsenal
