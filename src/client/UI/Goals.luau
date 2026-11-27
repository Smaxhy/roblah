--[[
	GOALS (v0.13): what this life is working toward, all in one place.
		Goals.open(ctx, layer)
	The part of life you're in and what it opened; your ambitions; your open cases; the
	episodes you've seen through; and the feats board, bronze to mythic, with how close you
	are to each and what the rare ones break open.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Sheets = require(script.Parent.Sheets)
local Emblem = require(script.Parent.Emblem)

local C, F = Theme.colors, Theme.fonts
local new = Kit.new

local Goals = {}

local TIER_ORDER = { "mythic", "gold", "silver", "bronze" }
local TIER_FALLBACK = {
	bronze = { name = "Bronze", color = { 196, 142, 92 } },
	silver = { name = "Silver", color = { 196, 204, 214 } },
	gold = { name = "Gold", color = { 240, 196, 92 } },
	mythic = { name = "Mythic", color = { 222, 96, 140 } },
}

local function rgb(t: any, fallback: Color3): Color3
	if type(t) == "table" and #t >= 3 then
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	return fallback
end

local function heading(parent, text: string, order: number, color: Color3?)
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = order, ZIndex = 2, Parent = parent })
	Kit.caps({ Text = string.upper(text), Size = UDim2.new(1, 0, 1, 0), FontFace = F.display, TextSize = 14, TextColor3 = color or C.crimsonHi, ZIndex = 2, Parent = row })
	new("Frame", { BackgroundColor3 = color or C.crimsonHi, BackgroundTransparency = 0.6, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 2, Parent = row })
	return row
end

local function bar(parent, p: number, color: Color3, order: number, height: number?)
	local track = new("Frame", { BackgroundColor3 = C.panel, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, height or 6), LayoutOrder = order, ZIndex = 3, Parent = parent }, { Kit.corner(3) })
	new("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.new(math.clamp(p, 0.02, 1), 0, 1, 0), ZIndex = 4, Parent = track }, { Kit.corner(3), Kit.gradient(color:Lerp(Color3.new(1, 1, 1), 0.25), color, 0) })
	return track
end

local function grid(parent: Instance, order: number, columns: number, height: number): Frame
	local holder = new("Frame", { Name = "Grid", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, ZIndex = 2, Parent = parent })
	new("UIGridLayout", { CellSize = UDim2.new(1 / columns, -8 * (columns - 1) / columns, 0, height), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })
	return holder
end

local function columnsFor(content: Instance): number
	local w = (content :: any).AbsoluteSize.X
	if w <= 0 then
		return 2
	end
	return if w >= 760 then 3 elseif w >= 420 then 2 else 1
end

function Goals.open(ctx, layer: Instance)
	local sheet = Sheets.open(layer, "Goals", nil, { tall = true, wide = true })
	local content = sheet.content
	local life = ctx.state.life
	if not life then
		return sheet
	end
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end

	-- ── the part of life you're in ──
	local phase = life.phase
	if phase then
		local pc = rgb(phase.color, C.strange)
		local card = new("Frame", { BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
			Kit.corner(6),
			Kit.stroke(pc, 1, 0.2),
			Kit.padding(14, 16, 14, 16),
			Kit.list(6),
		})
		local glow = new("Folder", { Parent = card })
		new("Frame", { BackgroundColor3 = pc, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = glow }, {
			Kit.corner(6),
			new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) }), Rotation = 0 }),
		})
		Kit.caps({ Text = "THIS PART OF LIFE", Size = UDim2.new(1, 0, 0, 14), TextSize = 11, TextColor3 = pc, LayoutOrder = 1, ZIndex = 3, Parent = card })
		Kit.text({ Text = string.upper(Format.escape(phase.name or "")), FontFace = F.display, TextSize = 24, TextColor3 = C.text, LayoutOrder = 2, ZIndex = 3, Parent = card })
		Kit.text({ Text = Format.escape(phase.line or ""), FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = 3, Parent = card })
		if phase.unlocks and #phase.unlocks > 0 then
			local chips = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4, ZIndex = 3, Parent = card }, {
				new("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 22), CellPadding = UDim2.fromOffset(8, 4) }),
			})
			for _, u in phase.unlocks do
				Kit.text({ Text = Format.color("◆ ", pc) .. Format.escape(u), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.text, TextTruncate = Enum.TextTruncate.AtEnd, AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.new(1, 0, 1, 0), ZIndex = 3, Parent = chips })
			end
		end
		if phase.nextName then
			Kit.text({ Text = Format.color(string.format("NEXT: %s, AT %d", string.upper(phase.nextName), phase.nextAt or 0), C.faint), FontFace = F.displayMed, TextSize = 12, LayoutOrder = 5, ZIndex = 3, Parent = card })
		end
	end

	-- ── ambitions ──
	heading(content, "Ambitions", nextOrder(), C.accentHi)
	if #(life.ambitions or {}) == 0 then
		Kit.text({ Text = "Nothing to aim for yet. Give it a year or two.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
	else
		local g = grid(content, nextOrder(), columnsFor(content), 108)
		for i, a in life.ambitions do
			local card = new("Frame", { BackgroundColor3 = C.panelLo, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 2, Parent = g }, {
				Kit.corner(6),
				Kit.stroke(C.accent, 1, 0.35),
				Kit.padding(10, 12, 10, 12),
				Kit.list(5),
			})
			Kit.text({ Text = string.upper(Format.escape(a.name)), FontFace = F.display, TextSize = 15, LayoutOrder = 1, ZIndex = 2, Parent = card })
			Kit.text({ Text = Format.escape(a.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = card })
			if a.progress then
				bar(card, a.progress, C.accent, 3)
			end
		end
	end

	-- ── cases ──
	if life.cases and #life.cases > 0 then
		heading(content, "Cases", nextOrder(), C.strange)
		for _, c in life.cases do
			local card = new("Frame", { BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
				Kit.corner(6),
				Kit.stroke(if c.solved then C.good else C.strange, 1, 0.3),
				Kit.padding(10, 12, 10, 12),
				Kit.list(5),
			})
			Kit.text({ Text = string.upper(Format.escape(c.name)) .. Format.color(if c.solved then "   CLOSED" else string.format("   %d / %d CLUES", math.min(c.clues, c.of), c.of), if c.solved then C.good else C.strange), FontFace = F.display, TextSize = 15, LayoutOrder = 1, ZIndex = 2, Parent = card })
			Kit.text({ Text = Format.escape(c.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = card })
			bar(card, if c.solved then 1 else c.clues / math.max(1, c.of), if c.solved then C.good else C.strange, 3)
		end
	end

	-- ── episodes ──
	local eps = life.episodes or {}
	if #eps > 0 then
		heading(content, string.format("Episodes seen through  ·  %d", #eps), nextOrder(), C.strange)
		for _, e in eps do
			local ec = rgb(e.color, C.strange)
			Kit.text({
				Text = Format.color(string.upper(Format.escape(e.name or "")), ec) .. Format.color(string.format("   AGE %d", e.age or 0), C.faint) .. "\n" .. Format.escape(e.ending or ""),
				FontFace = F.uiMedium,
				TextSize = 13,
				TextColor3 = C.text,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = content,
			})
		end
	end

	-- ── feats ──
	local feats = life.feats
	if feats then
		heading(content, string.format("Feats  ·  %d of %d", feats.earned or 0, feats.total or 0), nextOrder(), C.money)
		local tiers = feats.tiers or TIER_FALLBACK
		-- a tally by tier
		local summary = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
			Kit.list(8, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center),
		})
		for i, t in { "bronze", "silver", "gold", "mythic" } do
			local def = tiers[t] or TIER_FALLBACK[t]
			local have, all = 0, 0
			for _, f in feats.list or {} do
				if f.tier == t then
					all += 1
					if f.done then
						have += 1
					end
				end
			end
			Kit.chip(string.format("%s  %d/%d", string.upper(def.name), have, all), rgb(def.color, C.accent), i).Parent = summary
		end
		for _, t in TIER_ORDER do
			local def = tiers[t] or TIER_FALLBACK[t]
			local tc = rgb(def.color, C.accent)
			local list = {}
			for _, f in feats.list or {} do
				if f.tier == t then
					table.insert(list, f)
				end
			end
			if #list > 0 then
				-- earned first, then the closest
				table.sort(list, function(a, b)
					if a.done ~= b.done then
						return a.done
					end
					return (a.progress or 0) > (b.progress or 0)
				end)
				heading(content, def.name, nextOrder(), tc)
				local g = grid(content, nextOrder(), columnsFor(content), 104)
				for i, f in list do
					local card = new("Frame", { BackgroundColor3 = if f.done then tc:Lerp(C.panelLo, 0.82) else C.panelLo, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 2, Parent = g }, {
						Kit.corner(6),
						Kit.stroke(tc, if f.done then 2 else 1, if f.done then 0.1 else 0.6),
						Kit.padding(9, 11, 9, 11),
						Kit.list(4),
					})
					local head = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, ZIndex = 3, Parent = card }, {
						Kit.list(6, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center),
					})
					local mark = Emblem.make(if f.done then "misc.check" else "misc.lock", 14, if f.done then tc else C.faint, if f.done then tc else C.faint)
					mark.LayoutOrder = 1
					mark.ZIndex = 3
					mark.Parent = head
					Kit.raise(mark, 3)
					Kit.text({ Text = string.upper(Format.escape(f.name or "")), FontFace = F.display, TextSize = 14, TextColor3 = if f.done then C.text else C.sub, TextTruncate = Enum.TextTruncate.AtEnd, AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.new(1, -22, 1, 0), TextWrapped = false, LayoutOrder = 2, ZIndex = 3, Parent = head })
					Kit.text({ Text = Format.escape(f.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 3, Parent = card })
					if f.reward then
						Kit.text({ Text = Format.color("BREAKS A LIMIT  ", C.strange) .. Format.escape(f.reward), FontFace = F.uiMedium, TextSize = 11, TextColor3 = C.text, LayoutOrder = 3, ZIndex = 3, Parent = card })
					end
					local ever = ctx.state.meta and ctx.state.meta.featsEver
					if f.done then
						Kit.caps({ Text = string.format("EARNED AT %d", f.age or 0), Size = UDim2.new(1, 0, 0, 12), TextSize = 11, TextColor3 = tc, LayoutOrder = 4, ZIndex = 3, Parent = card })
					elseif ever and ever[f.id] then
						Kit.caps({ Text = "EARNED IN AN EARLIER LIFE", Size = UDim2.new(1, 0, 0, 12), TextSize = 11, TextColor3 = tc:Lerp(C.faint, 0.4), LayoutOrder = 4, ZIndex = 3, Parent = card })
					elseif f.progress then
						bar(card, f.progress, tc, 4, 5)
					end
				end
			end
		end
	end

	-- ── side quests ──
	local any = false
	for _, q in life.quests or {} do
		if q.active then
			if not any then
				any = true
				heading(content, "Side quests", nextOrder(), C.strange)
			end
			Sheets.row(content, nextOrder(), {
				title = Format.escape(q.name) .. Format.color(string.format("   %d/%d", q.step, q.steps), C.strange),
				desc = Format.escape(q.stepText or ""),
				meta = if q.hint then Format.escape(q.hint) else "",
				accent = C.strange,
			})
		end
	end
	Kit.text({
		Text = string.format("This life's score so far: %s", Format.color(Format.number(life.score or 0), C.money)),
		FontFace = F.displayMed,
		TextSize = 15,
		LayoutOrder = nextOrder(),
		ZIndex = 2,
		Parent = content,
	})
	return sheet
end

return Goals
