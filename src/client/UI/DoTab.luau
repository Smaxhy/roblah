--[[
	DO: what you can do with this year, as tiles instead of a list of paragraphs.

	  THIS YEAR     how many things you can still do
	  WORK          your rank, exactly what the next one is waiting on, and this year's jobs
	  then every kind of activity: an icon, a name, what it gives as chips, the odds if it's a
	  check. What it is in words is a hover (or a long press) away.

	Used by the hub's DO tab on a wide screen and by the Activities sheet on a phone
	(Sheets.activitiesContent calls DoTab.fill).
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Emblem = require(script.Parent.Emblem)
local Tip = require(script.Parent.Tip)
local Feed = require(script.Parent.Feed)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local DoTab = {}

local TILE_H = 74

local function oddsColor(p: number): Color3
	return if p >= 0.6 then C.good elseif p >= 0.35 then C.accentHi else C.bad
end

local function heading(parent: Instance, text: string, order: number, color: Color3?, right: string?)
	local row = new("Frame", { Name = "Heading", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = order, ZIndex = 2, Parent = parent })
	new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.7, 0, 1, 0),
		Text = string.upper(text),
		FontFace = F.display,
		TextSize = 14,
		TextColor3 = color or C.accentHi,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = row,
	})
	if right then
		new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0.3, 0, 1, 0),
			Text = string.upper(right),
			FontFace = F.displayMed,
			TextSize = 12,
			TextColor3 = C.faint,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 2,
			Parent = row,
		})
	end
	return row
end

local function grid(parent: Instance, order: number, columns: number)
	return new("Frame", {
		Name = "Tiles",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.new(1 / columns, if columns > 1 then -4 else 0, 0, TILE_H),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
end

-- what a list of stakes ({ key, min, max } or { text, tone }) says, as up to `limit` chips
local TONE_COLOR = { good = C.good, bad = C.bad, mixed = C.accentHi, strange = C.strange, money = C.money, plain = C.sub }
local function stakeChips(ctx, list, limit: number)
	local out = {}
	for _, g in list or {} do
		if #out >= limit then
			break
		end
		local text, tone = Format.stakeChip(ctx.info, g)
		table.insert(out, { text = string.upper(text), color = TONE_COLOR[tone] or C.sub })
	end
	return out
end
DoTab.stakeChips = stakeChips

-- the same, as one line of coloured words ("+6~9 BOND  +2 SAN"); "" when there is nothing
function DoTab.stakeText(ctx, list, limit: number?): string
	local parts = {}
	for _, c in stakeChips(ctx, list, limit or 6) do
		table.insert(parts, Format.color(Format.escape(c.text), c.color))
	end
	return table.concat(parts, "  ")
end

-- what winning and losing come to, by each way of going in (only the ways that change it)
function DoTab.stanceLines(ctx, clash, stakes): string
	if not (stakes and clash) then
		return ""
	end
	local lines = {}
	local win, lose = DoTab.stakeText(ctx, stakes.win), DoTab.stakeText(ctx, stakes.lose)
	if win ~= "" then
		table.insert(lines, Format.color("WIN  ", C.sub) .. win)
	end
	if lose ~= "" then
		table.insert(lines, Format.color("LOSE  ", C.sub) .. lose)
	end
	for _, a in clash.approaches or {} do
		local own = stakes.approaches and stakes.approaches[a.id]
		if own then
			local w, l = DoTab.stakeText(ctx, own.win), DoTab.stakeText(ctx, own.lose)
			local parts = {}
			if w ~= win and w ~= "" then
				table.insert(parts, Format.color("WIN ", C.sub) .. w)
			end
			if l ~= lose and l ~= "" then
				table.insert(parts, Format.color("LOSE ", C.sub) .. l)
			end
			if #parts > 0 then
				table.insert(lines, "<b>" .. string.upper(Format.escape(a.name)) .. "</b>  " .. table.concat(parts, "   "))
			end
		end
	end
	return table.concat(lines, "\n")
end

-- One tile. opts = { id, name, icon, chips = { { text, color } }, odds, enabled, done, failed,
-- reason, tipBody, accent, onClick }
local function tile(parent: Instance, order: number, opts)
	local enabled = opts.enabled ~= false
	local dim = if enabled then 0 else 0.5
	local btn: any = new("TextButton", {
		Name = opts.id or "Tile",
		AutoButtonColor = false,
		BackgroundColor3 = C.panelLo,
		BackgroundTransparency = if enabled then 0 else 0.4,
		BorderSizePixel = 0,
		Text = "",
		LayoutOrder = order,
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = parent,
	}, { Kit.corner(4) })
	local restColor = if opts.done then C.good elseif opts.failed then C.bad else (opts.accent or C.stroke)
	local restAlpha = if opts.done or opts.failed then 0.2 elseif opts.accent then 0.4 else 0.45
	local stroke = Kit.stroke(restColor, 1, restAlpha)
	stroke.Parent = btn
	-- the icon
	local badge = new("Frame", { BackgroundColor3 = C.panel, BackgroundTransparency = dim, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(30, 30), ZIndex = 2, Parent = btn }, { Kit.corner(4) })
	local icon = Emblem.make(opts.icon or "tab.do", 20)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.ZIndex = 3
	icon.Parent = badge
	Kit.raise(icon, 3)
	-- the odds, top right (checks and fights)
	local oddsW = 0
	if opts.odds then
		oddsW = 44
		new("TextLabel", {
			Name = "Odds",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -8, 0, 8),
			Size = UDim2.fromOffset(oddsW, 18),
			Text = tostring(math.floor(opts.odds * 100 + 0.5)) .. "%",
			FontFace = F.mono,
			TextSize = 15,
			TextColor3 = oddsColor(opts.odds),
			TextTransparency = dim,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 3,
			Parent = btn,
		})
	end
	-- the name: two lines at most
	new("TextLabel", {
		Name = "Name",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(46, 6),
		Size = UDim2.new(1, -46 - oddsW - 10, 0, 34),
		Text = Format.escape(opts.name or ""),
		FontFace = F.displayMed,
		TextSize = 14,
		TextColor3 = C.text,
		TextTransparency = dim,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = btn,
	})
	-- what it gives, or why you can't
	local foot = new("Frame", {
		Name = "Foot",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 1, -25),
		Size = UDim2.new(1, -16, 0, 18),
		ClipsDescendants = true,
		ZIndex = 3,
		Parent = btn,
	}, { Kit.list(4, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center) })
	if opts.done or opts.failed then
		local chip = Feed.chip(if opts.done then "DONE" else "FAILED", if opts.done then C.good else C.bad, 0)
		chip.ZIndex = 3
		chip.Parent = foot
	end
	if not enabled and opts.reason then
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Text = Format.escape(opts.reason),
			FontFace = F.uiMedium,
			TextSize = 11,
			TextColor3 = C.faint,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 1,
			ZIndex = 3,
			Parent = foot,
		})
	else
		for i, c in opts.chips or {} do
			local chip = Feed.chip(c.text, c.color, i)
			chip.TextTransparency = dim
			chip.ZIndex = 3
			chip.Parent = foot
		end
	end
	if opts.tipBody and opts.tipBody ~= "" then
		Tip.attach(btn, opts.name, opts.tipBody)
	end
	if enabled and opts.onClick then
		btn.MouseEnter:Connect(function()
			Kit.tween(stroke, 0.1, { Color = C.accentHi, Transparency = 0 })
		end)
		btn.MouseLeave:Connect(function()
			Kit.tween(stroke, 0.1, { Color = restColor, Transparency = restAlpha })
			Kit.tween(btn, 0.1, { BackgroundColor3 = C.panelLo })
		end)
		btn.MouseButton1Down:Connect(function()
			Kit.tween(btn, 0.06, { BackgroundColor3 = C.panelHi })
		end)
		btn.Activated:Connect(opts.onClick)
	end
	return btn
end
DoTab.tile = tile

-- "How do you fight?": one button per way in, with its odds
function DoTab.pickStance(ctx, title: string, clash, go: (string?) -> (), stakes: any?)
	local list = clash and clash.approaches
	if not list or #list == 0 then
		go(nil)
		return
	end
	local buttons = {}
	for _, a in list do
		table.insert(buttons, {
			label = string.format("%s %d%%", a.name, math.floor(a.odds * 100 + 0.5)),
			style = if a.edge == "advantage" then "primary" elseif a.edge == "resisted" then "danger" else "secondary",
			onClick = function()
				go(a.id)
			end,
		})
	end
	local t = clash.temper
	local text = "How do you go in?"
	if t then
		text = Format.escape(t.name .. ". " .. (t.desc or "") .. (if t.weakName then " Weak to " .. t.weakName .. "." else ""))
	end
	-- what each side brings, and what is at stake
	local function abil(list)
		local parts = {}
		for _, a in list or {} do
			table.insert(parts, string.upper(Format.escape(a.name)) .. (if (a.potency or 1) > 1 then " " .. tostring(a.potency) else ""))
		end
		return table.concat(parts, ", ")
	end
	if clash.abilities then
		text ..= "\n" .. Format.color("You: " .. abil(clash.abilities), C.good)
	end
	if clash.foeAbilities then
		text ..= "\n" .. Format.color("They: " .. abil(clash.foeAbilities), C.bad)
	end
	local lines = DoTab.stanceLines(ctx, clash, stakes)
	if lines ~= "" then
		text ..= "\n\n" .. lines
	end
	ctx.prompt({ title = title, text = text, rich = true, buttons = buttons })
end

-- a requirement on the way to the next rank: green once it's met
local function need(parent: Instance, order: number, label: string, have: number, want: number)
	local met = have >= want
	local chip = Feed.chip(string.format("%s %d/%d", label, math.min(have, math.max(want, have)), want), if met then C.good else C.accentHi, order)
	chip.ZIndex = 3
	chip.Parent = parent
	return chip
end

-- WORK: your rank, what the next one waits on, and this year's jobs
local function drawWork(ctx, content: Instance, life, close: () -> ())
	local career = life.career
	if not career then
		return
	end
	local jobs = life.jobs
	heading(content, "Work", 100, C.accentHi, if jobs then jobs.title else nil)
	local card = new("Frame", {
		Name = "Rank",
		BackgroundColor3 = C.panelHi,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 101,
		ZIndex = 2,
		Parent = content,
	}, { Kit.corner(4), Kit.padding(8, 10, 9, 10), Kit.list(5) })
	local top = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, ZIndex = 2, Parent = card })
	new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.72, 0, 1, 0),
		Text = string.upper(Format.escape(career.rank or "")),
		FontFace = F.display,
		TextSize = 16,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = top,
	})
	new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.28, 0, 1, 0),
		Text = Format.number(career.salary or 0) .. " " .. ctx.info.meta.currency,
		FontFace = F.mono,
		TextSize = 13,
		TextColor3 = C.money,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = top,
	})
	if career.nextRank then
		local row = new("Frame", {
			Name = "Next",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			ZIndex = 2,
			Parent = card,
		}, { new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), Wraps = true, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }) })
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "NEXT  " .. string.upper(Format.escape(career.nextRank)),
			FontFace = F.displayMed,
			TextSize = 12,
			TextColor3 = C.sub,
			LayoutOrder = 0,
			ZIndex = 3,
			Parent = row,
		})
		local sdef = ctx.info.stats.defs[career.promoteStat or ""]
		if career.nextAt then
			need(row, 1, (sdef and sdef.short) or "STAT", career.statNow or 0, career.nextAt)
		end
		need(row, 2, "YEARS", career.rankYears or 0, career.yearsNeed or 2)
		if career.jobsNeed then
			need(row, 3, "JOBS", career.jobs or 0, career.jobsNeed)
		end
	else
		Kit.caps({ Text = "The top of the ladder.", TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 3, Parent = card })
	end
	if not jobs or #jobs.list == 0 then
		return
	end
	local g = grid(content, 102, 1)
	for i, job in jobs.list do
		local clash = job.clash
		local chips = {}
		if job.pay and job.pay > 0 then
			table.insert(chips, { text = "+" .. Format.number(job.pay) .. " " .. ctx.info.meta.currency, color = C.money })
		end
		for _, c in stakeChips(ctx, job.stakes and job.stakes.win, 3) do
			if c.text ~= "PAY" and #chips < 3 then
				table.insert(chips, c)
			end
		end
		if job.tier and job.tier > 0 then
			table.insert(chips, { text = "HARD", color = C.bad })
		end
		-- (v0.13) a job's twist: the thing about this one that isn't like the last
		if job.twist and job.twist.name then
			table.insert(chips, 1, { text = string.upper(job.twist.name), color = if job.twist.tone == "bad" then C.bad elseif job.twist.tone == "good" then C.good else C.strange })
			if #chips > 4 then
				table.remove(chips)
			end
		end
		local canDo = not job.done and (life.actionsLeft or 0) > 0 and not life.pending
		tile(g, i, {
			id = "Job_" .. tostring(job.index),
			name = job.name,
			icon = if clash.fight then "misc.fight" else "stat." .. tostring(clash.stat),
			chips = chips,
			odds = clash.bestOdds or clash.odds,
			enabled = canDo or job.done,
			done = job.done and job.won,
			failed = job.done and not job.won,
			reason = if not job.done and (life.actionsLeft or 0) <= 0 then "No actions left this year" else nil,
			tipBody = if job.twist and job.twist.line then ((job.line or "") .. "\n\n" .. job.twist.line) else job.line,
			accent = if job.twist then C.strange else C.accentLo,
			onClick = if canDo
				then function()
					close()
					if clash.fight then
						DoTab.pickStance(ctx, job.name, clash, function(approach)
							ctx.actions.doJob(job.index, approach)
						end, job.stakes)
					else
						ctx.actions.doJob(job.index, nil)
					end
				end
				else nil,
		})
	end
end

-- everything under the counters. `run(act)` does an activity (the caller knows how);
-- `close()` shuts the sheet this is drawn in, if it is one.
function DoTab.fill(ctx, content: Instance, life, run: (any) -> (), close: () -> (), columns: number?)
	local cols = columns or 2
	drawWork(ctx, content, life, close)

	local cats = ctx.info.categories or { order = {} }
	local orderOf = {}
	for i, c in cats.order do
		orderOf[c] = i
	end
	local grids = {}
	for i, act in life.activities do
		local cat = act.category or "other"
		local base = 200 + (orderOf[cat] or 9) * 100
		if not grids[cat] then
			heading(content, cats[cat] or "Other", base, if cat == "district" then C.crimsonHi else C.accentHi)
			grids[cat] = grid(content, base + 1, cols)
		end
		local chips = stakeChips(ctx, act.gains, 3)
		if act.cost and act.cost > 0 then
			table.insert(chips, 1, { text = Format.number(act.cost) .. " " .. ctx.info.meta.currency, color = C.accent })
		end
		tile(grids[cat], i, {
			id = "Act_" .. act.id,
			name = act.name,
			icon = act.icon or (if act.clash then (if act.clash.fight then "misc.fight" else "stat." .. tostring(act.clash.stat)) else "tab.do"),
			chips = chips,
			odds = if act.clash then (act.clash.bestOdds or act.clash.odds) else nil,
			enabled = act.enabled,
			done = act.done,
			reason = act.reason,
			tipBody = act.desc,
			onClick = function()
				run(act)
			end,
		})
	end
	-- (v0.13) PLACES YOU KNOW: ways in you've found out in the City (a hatch, a lift, a
	-- letter). Nothing is listed until it's found; a found place can be gone back to.
	local exps = {}
	for _, ex in life.expeditions or {} do
		if ex.found ~= false then
			table.insert(exps, ex)
		end
	end
	if #(life.expeditions or {}) > 0 then
		heading(content, "Places you know", 1900, C.strange)
	end
	if #exps == 0 and #(life.expeditions or {}) > 0 then
		Kit.text({ Text = "Nowhere yet. Ways in turn up out in the City: a hatch behind a boiler, a lift with one button too many, a letter with an address. When you find one, it's listed here.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = 1901, ZIndex = 2, Parent = content })
	end
	if #exps > 0 then
		local g = grid(content, 1902, cols)
		for i, ex in exps do
			local chips = { { text = string.upper(ex.purpose or ex.kind or "TRIP"), color = C.strange } }
			if ex.cost and ex.cost > 0 then
				table.insert(chips, { text = Format.number(ex.cost) .. " " .. ctx.info.meta.currency, color = C.accent })
			end
			if (ex.crewMax or 1) > 1 then
				table.insert(chips, { text = if (ex.crewMin or 1) > 1 then "CREW " .. ex.crewMin .. "+" else "SOLO OR CREW", color = C.sub })
			end
			tile(g, i, {
				id = "Exp_" .. tostring(ex.id),
				name = ex.name,
				icon = "tab.crew",
				chips = chips,
				enabled = ex.enabled,
				reason = ex.reason,
				tipBody = ex.desc,
				accent = C.strange,
				onClick = function()
					close()
					ctx.actions.expeditionStart(ex.id)
				end,
			})
		end
	end
end

return DoTab
