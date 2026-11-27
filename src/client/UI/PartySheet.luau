--[[
	THE PARTY SCREEN (BitLeveling, v0.19): the people who follow you into the Gates, and
	everyone you could ask. Engine/Party.luau holds the rules; server/HunterParty checks and runs
	every request.

		PartySheet.open(gui, call, {
			view = <partyView>,            (optional: what the server already sent)
			onResponse = function(res),    the app applies a life response (log, life, a fight)
			toast = function(text, color),
			currency = "million won",
		})
		PartySheet.close()

	MEMBERS: up to four cards, each their R6 portrait (Hunter/R6Rig in their class's outfit for
	their rank), their rank badge in its colour (E grey, D green, C blue, B violet, A orange, S
	red and gold), class, what they do for the party, loyalty and bond bars, how they are (fine,
	hurt, down), their share and retainer, and TALK / GIFT / PROFILE / PART WAYS. An open place
	says so. CANDIDATES: everyone else in your life old enough to ask, best odds first, with the
	odds and the reasons for them, ASK and PROFILE. Asking shows their answer: JOINED or SAID
	NO, in their own words, with a little animation. Under it all: what's happened to the party,
	and the names of the ones who didn't come back.
]]

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent:WaitForChild("Theme"))
local NpcProfile = require(script.Parent:WaitForChild("NpcProfile"))
local F = Theme.fonts
local Kit = NpcProfile.kit
local C = Kit.C
local make = Kit.make
local LETTERS = Kit.LETTERS

local PartySheet = {}
local current: any = nil

function PartySheet.close()
	NpcProfile.close()
	if current then
		current:Destroy()
		current = nil
	end
end

function PartySheet.isOpen(): boolean
	return current ~= nil
end

local function clear(f: Instance)
	for _, c in f:GetChildren() do
		if not (c:IsA("UIListLayout") or c:IsA("UIGridLayout") or c:IsA("UIPadding")) then
			c:Destroy()
		end
	end
end

function PartySheet.open(gui: Instance, call: (string, any?) -> any, opts: any?)
	PartySheet.close()
	opts = opts or {}
	local currency = opts.currency or "million won"
	local frame, scrim = Kit.modal(gui, "PartySheet", 1200, 780, 30)
	current = scrim
	local root = scrim
	local Z = 32
	local view: any = opts.view

	local render: () -> ()
	local showResult: (any) -> ()
	local openGifts: (any, ((string?) -> ())?) -> ()

	-- a reply from the server: the app takes the life part, the screen takes the party part
	local function apply(res: any)
		if not res then
			return
		end
		if opts.onResponse then
			opts.onResponse(res)
		end
		if res.party then
			view = res.party
		end
		if current == root then
			render()
			if res.result then
				showResult(res.result)
			end
		end
	end
	local function openProfile(relId: number)
		NpcProfile.open(gui, call, {
			relId = relId,
			currency = currency,
			onResponse = opts.onResponse,
			onChanged = function(res: any)
				if res and res.party then
					view = res.party
					if current == root then
						render()
					end
				end
			end,
			onResult = function(result: any)
				if current == root then
					showResult(result)
				end
			end,
			pickGift = function(p: any, done: (string?) -> ())
				openGifts(p, done)
			end,
		})
	end

	-- ── the header ──
	local header = make("Frame", { Name = "Header", BackgroundTransparency = 1, Position = UDim2.fromOffset(22, 14), Size = UDim2.new(1, -44, 0, 62), ZIndex = Z }, frame)
	local title = Kit.label(header, { Name = "Title", RichText = true, Text = "YOUR PARTY", FontFace = F.display, TextSize = 32, Size = UDim2.new(1, -120, 0, 36), ZIndex = Z })
	local you = Kit.label(header, { Name = "You", RichText = true, Text = "", FontFace = F.uiMedium, TextSize = 13, TextColor3 = C.sub, Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, -120, 0, 20), ZIndex = Z })
	Kit.button(header, "CLOSE", C.mana, PartySheet.close, { name = "Close", anchor = Vector2.new(1, 0), position = UDim2.new(1, 0, 0, 6), size = UDim2.fromOffset(100, 34), zIndex = Z })

	local body = make("ScrollingFrame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(22, 84),
		Size = UDim2.new(1, -44, 1, -100),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = C.mana,
		ZIndex = Z,
	}, frame)
	Kit.list(body, 12)
	Kit.padding(body, 2, 10, 16, 2)

	-- ── a member's card ──
	local function memberCard(parent: Instance, m: any, i: number)
		local rank = m.rank or 0
		local rcol = Kit.rankColor(rank)
		local card = make("Frame", { Name = "Member_" .. tostring(m.relId), BackgroundColor3 = C.panelHi, LayoutOrder = i, ZIndex = Z }, parent)
		Kit.corner(card, 8)
		Kit.gradient(card, C.panelHi, C.panel)
		Kit.stroke(card, if rank == 6 then C.gold else rcol, if rank >= 5 then 2 else 1.5, 0.2)
		local top = make("Frame", { Name = "Top", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 150), ClipsDescendants = true, ZIndex = Z + 1 }, card)
		Kit.portrait(top, m.look, { size = UDim2.new(1, -12, 1, -6), position = UDim2.fromOffset(6, 6), zIndex = Z + 1 })
		Kit.rankBadge(card, rank, 40, { Position = UDim2.fromOffset(12, 12), ZIndex = Z + 3 })
		local cond = Kit.CONDITION[m.condition or "fine"] or Kit.CONDITION.fine
		local chip = Kit.chip(card, cond.text .. (if (m.out or 0) > 0 and m.condition ~= "fine" then string.format(" · %dY", m.out) else ""), cond.color)
		chip.Name = "Condition"
		chip.AnchorPoint = Vector2.new(1, 0)
		chip.Position = UDim2.new(1, -12, 0, 14)
		chip.ZIndex = Z + 3
		local info = make("Frame", { Name = "Info", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 158), Size = UDim2.new(1, -24, 1, -166), ZIndex = Z + 1 }, card)
		Kit.label(info, { Name = "Name", Text = m.name or "?", FontFace = F.display, TextSize = 20, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, 0, 0, 24), ZIndex = Z + 1 })
		Kit.label(info, { Name = "Class", Text = (if rank > 0 then LETTERS[rank] .. "-rank " .. (m.className or "Hunter") else "No rank") .. "  ·  " .. (if m.kind == "acquaintance" then "Acquaintance" else (m.kindName or "")), FontFace = F.uiBold, TextSize = 13, TextColor3 = if rank == 6 then C.gold else rcol:Lerp(Color3.new(1, 1, 1), 0.25), Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = Z + 1 })
		Kit.label(info, { Name = "Does", Text = if rank > 0 then string.upper(string.sub(m.does or "", 1, 1)) .. string.sub(m.does or "", 2) .. "." else "Watches your back. No rank: Gates are dangerous for them.", FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 0, 30), ZIndex = Z + 1 })
		local bars = make("Frame", { Name = "Bars", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 78), Size = UDim2.new(1, 0, 0, 36), ZIndex = Z + 1 }, info)
		Kit.list(bars, 4)
		Kit.bar(bars, "Loyalty", m.loyalty or 0, 100, if (m.loyalty or 0) < 30 then C.bad else C.mana, 1)
		Kit.bar(bars, "Bond", m.bond or 0, 100, C.good, 2)
		local money = string.format("SHARE %d%%", m.share or 0)
		if (m.retainer or 0) > 0 then
			money ..= string.format("  ·  %d/YR", m.retainer)
		end
		if (m.unpaid or 0) > 0 then
			money ..= "  ·  UNPAID"
		end
		Kit.label(info, { Name = "Terms", Text = money .. string.format("  ·  W%d L%d", m.wins or 0, m.losses or 0), FontFace = F.mono, TextSize = 11, TextColor3 = if (m.unpaid or 0) > 0 then C.warn else C.sub, Position = UDim2.fromOffset(0, 118), Size = UDim2.new(1, 0, 0, 16), ZIndex = Z + 1 })
		local grid = make("Frame", { Name = "Actions", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 60), ZIndex = Z + 1 }, info)
		make("UIGridLayout", { CellSize = UDim2.new(0.5, -3, 0, 28), CellPadding = UDim2.fromOffset(6, 4), SortOrder = Enum.SortOrder.LayoutOrder }, grid)
		local can = view.canAct ~= false
		Kit.button(grid, "TALK", C.mana, function()
			apply(call("partyTalk", { relId = m.relId }))
		end, { name = "Talk", order = 1, enabled = can, zIndex = Z + 2, size = UDim2.new() })
		Kit.button(grid, "GIFT", C.gold, function()
			openGifts(m, nil)
		end, { name = "Gift", order = 2, enabled = can, zIndex = Z + 2, size = UDim2.new() })
		Kit.button(grid, "PROFILE", C.manaHi, function()
			openProfile(m.relId)
		end, { name = "Profile", order = 3, zIndex = Z + 2, size = UDim2.new() })
		Kit.button(grid, "PART WAYS", C.bad, function()
			apply(call("partyDismiss", { relId = m.relId }))
		end, { name = "Dismiss", order = 4, enabled = view.alive ~= false, zIndex = Z + 2, size = UDim2.new() })
		return card
	end
	local function openCard(parent: Instance, i: number)
		local card = make("Frame", { Name = "Open_" .. i, BackgroundColor3 = C.panelLo, BackgroundTransparency = 0.2, LayoutOrder = i, ZIndex = Z }, parent)
		Kit.corner(card, 8)
		Kit.stroke(card, C.stroke, 1.5, 0.2)
		local plus = Kit.label(card, { Name = "Plus", Text = "+", FontFace = F.display, TextSize = 64, TextColor3 = C.manaLo, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.38), Size = UDim2.fromOffset(80, 80), ZIndex = Z + 1 })
		plus.TextTransparency = 0.1
		Kit.label(card, { Text = "OPEN PLACE", FontFace = F.display, TextSize = 16, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.55), Size = UDim2.new(1, -20, 0, 20), ZIndex = Z + 1 })
		Kit.label(card, { Text = "Ask someone below. Their odds are on their card.", FontFace = F.ui, TextSize = 12, TextColor3 = C.faint, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.55, 24), Size = UDim2.new(1, -30, 0, 34), ZIndex = Z + 1 })
		return card
	end

	-- ── a candidate's row ──
	local function candidateRow(parent: Instance, c: any, i: number)
		local rank = c.rank or 0
		local rcol = Kit.rankColor(rank)
		local row = make("Frame", { Name = "Candidate_" .. tostring(c.relId), BackgroundColor3 = C.panelHi, BackgroundTransparency = 0.05, Size = UDim2.new(1, 0, 0, 92), LayoutOrder = i, ZIndex = Z }, parent)
		Kit.corner(row, 8)
		Kit.stroke(row, C.stroke, 1, 0.15)
		Kit.portrait(row, c.look, { size = UDim2.fromOffset(78, 78), position = UDim2.fromOffset(7, 7), zIndex = Z + 1 })
		Kit.rankBadge(row, rank, 26, { Position = UDim2.fromOffset(4, 4), ZIndex = Z + 3 })
		local mid = make("Frame", { Name = "Who", BackgroundTransparency = 1, Position = UDim2.fromOffset(98, 8), Size = UDim2.new(1, -360, 1, -14), ZIndex = Z + 1 }, row)
		Kit.label(mid, { Name = "Name", RichText = true, Text = string.format("%s  <font color=\"#%s\" size=\"13\">%s</font>", c.name or "?", Kit.hex(if rank == 6 then C.gold else rcol), if rank > 0 then LETTERS[rank] .. "-rank " .. (c.className or "") else "no rank"), FontFace = F.uiBold, TextSize = 16, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, 0, 0, 20), ZIndex = Z + 1 })
		local traits = {}
		for _, t in c.traits or {} do
			table.insert(traits, t.name)
		end
		Kit.label(mid, { Name = "Kind", Text = (c.kindName or "") .. (if c.role then ": " .. c.role else "") .. (if #traits > 0 then "  ·  " .. table.concat(traits, ", ") else ""), FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(0, 21), Size = UDim2.new(1, 0, 0, 16), ZIndex = Z + 1 })
		local bars = make("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(0.6, 0, 0, 16), ZIndex = Z + 1 }, mid)
		Kit.bar(bars, "Bond", c.bond or 0, 100, C.good, 1)
		-- the two reasons that weigh most
		local fs = table.clone(c.factors or {})
		table.sort(fs, function(a: any, b: any)
			return math.abs(a.delta or 0) > math.abs(b.delta or 0)
		end)
		local bits = {}
		for k = 1, math.min(2, #fs) do
			local f = fs[k]
			table.insert(bits, string.format("<font color=\"#%s\">%s</font>", Kit.hex(if (f.delta or 0) >= 0 then C.good else C.bad), Kit.factorText(f)))
		end
		Kit.label(mid, { Name = "Why", RichText = true, Text = if c.why then string.format("<font color=\"#%s\">%s</font>", Kit.hex(C.warn), c.why) else table.concat(bits, "   "), FontFace = F.ui, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(0, 60), Size = UDim2.new(1, 0, 0, 16), ZIndex = Z + 1 })
		-- the odds, big
		local oddsCol = if c.why then C.faint else Kit.oddsColor(c.odds or 0)
		local right = make("Frame", { Name = "Ask", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8), Size = UDim2.fromOffset(250, 76), ZIndex = Z + 1 }, row)
		Kit.label(right, { Name = "Odds", Text = Kit.pct(c.odds), FontFace = F.display, TextSize = 34, TextColor3 = oddsCol, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.fromOffset(96, 40), ZIndex = Z + 1 })
		Kit.label(right, { Text = if c.fee then string.format("chance of a yes · wants %d up front", c.fee) else "chance of a yes", FontFace = F.uiMedium, TextSize = 11, TextColor3 = C.sub, Position = UDim2.fromOffset(0, 40), Size = UDim2.fromOffset(110, 30), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = Z + 1 })
		local canAsk = c.why == nil and view.canAct ~= false and (view.count or 0) < (view.max or 4)
		Kit.button(right, "ASK", C.mana, function()
			apply(call("partyAsk", { relId = c.relId }))
		end, { name = "AskButton", primary = true, enabled = canAsk, anchor = Vector2.new(1, 0), position = UDim2.new(1, 0, 0, 2), size = UDim2.fromOffset(120, 34), zIndex = Z + 2, textSize = 15 })
		Kit.button(right, "PROFILE", C.manaHi, function()
			openProfile(c.relId)
		end, { name = "ProfileButton", anchor = Vector2.new(1, 0), position = UDim2.new(1, 0, 0, 42), size = UDim2.fromOffset(120, 28), zIndex = Z + 2 })
		return row
	end

	render = function()
		clear(body)
		if not view then
			Kit.label(body, { Text = "Finding your people...", TextColor3 = C.sub, LayoutOrder = 1 })
			return
		end
		local v = view
		local y = v.you or {}
		title.Text = string.format("YOUR PARTY  <font color=\"#%s\">%d / %d</font>", Kit.hex(C.mana), v.count or 0, v.max or 4)
		local rankText = if (y.rank or 0) > 0 then string.format("<font color=\"#%s\"><b>%s-rank %s</b></font>", Kit.hex(if y.rank == 6 then C.gold else Kit.rankColor(y.rank)), LETTERS[y.rank], y.className or "Hunter") else "<b>Unawakened</b>"
		you.Text = string.format("%s  ·  %s  ·  Charisma %d  ·  Reputation %d  ·  %s %s  ·  Time for people: %d left", y.name or "You", rankText, y.charisma or 0, y.fame or 0, tostring(y.money or 0), currency, y.socialLeft or 0)

		local order = 0
		local function nextOrder(): number
			order += 1
			return order
		end
		if v.why then
			local note = Kit.label(body, { Name = "CantAct", Text = v.why, FontFace = F.uiBold, TextSize = 13, TextColor3 = C.warn, BackgroundTransparency = 0.1, BackgroundColor3 = C.warn:Lerp(C.ink, 0.82), Size = UDim2.new(1, 0, 0, 30), LayoutOrder = nextOrder(), ZIndex = Z })
			Kit.corner(note, 6)
			Kit.padding(note, 0, 12, 0, 12)
		end
		-- members
		Kit.heading(body, "Members", nextOrder(), "Up to " .. tostring(v.max or 4) .. " follow you into the Gates. They fight beside you, take a share, and can be hurt.")
		local members = make("Frame", { Name = "Members", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 376), LayoutOrder = nextOrder(), ZIndex = Z }, body)
		make("UIGridLayout", { CellSize = UDim2.new(0.25, -9, 0, 372), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder }, members)
		for i, m in v.members or {} do
			memberCard(members, m, i)
		end
		for i = #(v.members or {}) + 1, v.max or 4 do
			openCard(members, i)
		end
		-- candidates
		local cands = v.candidates or {}
		Kit.heading(body, "People you could ask", nextOrder(), string.format("%d in your life · best odds first", #cands))
		if #cands == 0 then
			Kit.label(body, { Text = "Nobody old enough to ask, yet. Everyone you meet can become someone you trust: talk, eat together, ask about their past.", TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = Z })
		end
		local list = make("Frame", { Name = "Candidates", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = Z }, body)
		Kit.list(list, 8)
		for i, c in cands do
			if i > 24 then
				break
			end
			candidateRow(list, c, i)
		end
		-- what's happened
		local log = v.log or {}
		if #log > 0 or #(v.fallen or {}) > 0 then
			Kit.heading(body, "The party so far", nextOrder())
			for k = #log, math.max(1, #log - 5), -1 do
				local e = log[k]
				Kit.label(body, { RichText = true, Text = string.format("<font color=\"#%s\">AGE %s</font>   %s", Kit.hex(C.mana), tostring(e.age), e.text or ""), TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.ui, TextSize = 13, LayoutOrder = nextOrder(), ZIndex = Z })
			end
			if #(v.fallen or {}) > 0 then
				Kit.label(body, { Name = "Fallen", Text = "In memory: " .. table.concat(v.fallen, ", "), TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = Z })
			end
		end
	end

	-- ── giving a gift ──
	openGifts = function(person: any, done: ((string?) -> ())?)
		local old = frame:FindFirstChild("GiftPicker")
		if old then
			old:Destroy()
		end
		local over = make("Frame", { Name = "GiftPicker", BackgroundColor3 = C.scrim, BackgroundTransparency = 0.3, Size = UDim2.fromScale(1, 1), ZIndex = Z + 20, Active = true }, frame)
		Kit.corner(over, 10)
		local panel = make("Frame", { Name = "Panel", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -80, 1, -80), BackgroundColor3 = C.panel, ZIndex = Z + 21 }, over)
		make("UISizeConstraint", { MaxSize = Vector2.new(820, 620) }, panel)
		Kit.corner(panel, 8)
		Kit.stroke(panel, C.gold, 1.5, 0.2)
		local function finish(id: string?)
			over:Destroy()
			if done then
				done(id)
			elseif id then
				apply(call("partyGift", { relId = person.relId, gift = id }))
			end
		end
		Kit.label(panel, { Text = "A GIFT FOR " .. string.upper(person.first or person.name or ""), FontFace = F.display, TextSize = 24, TextColor3 = C.gold, Position = UDim2.fromOffset(18, 12), Size = UDim2.new(1, -140, 0, 30), ZIndex = Z + 22 })
		local loves = if person.likes and #person.likes > 0 then table.concat(person.likes, ", ") else "you haven't found out yet"
		local hates = if person.dislikes and #person.dislikes > 0 then table.concat(person.dislikes, ", ") else "nothing you know of"
		Kit.label(panel, { RichText = true, Text = string.format("<font color=\"#%s\"><b>LOVES</b></font> %s     <font color=\"#%s\"><b>CAN'T STAND</b></font> %s", Kit.hex(C.good), loves, Kit.hex(C.bad), hates), FontFace = F.ui, TextSize = 13, TextColor3 = C.text, TextWrapped = true, Position = UDim2.fromOffset(18, 44), Size = UDim2.new(1, -36, 0, 34), TextYAlignment = Enum.TextYAlignment.Top, ZIndex = Z + 22 })
		Kit.button(panel, "CANCEL", C.mana, function()
			finish(nil)
		end, { name = "Cancel", anchor = Vector2.new(1, 0), position = UDim2.new(1, -14, 0, 12), size = UDim2.fromOffset(100, 30), zIndex = Z + 22 })
		local grid = make("ScrollingFrame", { Name = "Gifts", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(18, 84), Size = UDim2.new(1, -36, 1, -98), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 5, ScrollBarImageColor3 = C.gold, ZIndex = Z + 22 }, panel)
		make("UIGridLayout", { CellSize = UDim2.new(0.5, -6, 0, 58), CellPadding = UDim2.fromOffset(10, 8), SortOrder = Enum.SortOrder.LayoutOrder }, grid)
		for i, g in (view and view.gifts) or {} do
			local pick = g.id == person.giftPick
			local b = make("TextButton", { Name = "Gift_" .. g.id, Text = "", AutoButtonColor = g.enabled, BackgroundColor3 = if pick then C.gold:Lerp(C.ink, 0.78) else C.panelHi, BackgroundTransparency = if g.enabled then 0 else 0.5, LayoutOrder = if pick then 0 else i, ZIndex = Z + 23 }, grid)
			Kit.corner(b, 6)
			Kit.stroke(b, if pick then C.gold else C.stroke, if pick then 1.5 else 1, 0.1)
			Kit.label(b, { Text = g.name, FontFace = F.uiBold, TextSize = 13, TextColor3 = if g.enabled then C.text else C.faint, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -124, 0, 18), ZIndex = Z + 24 })
			Kit.label(b, { Text = g.desc or "", FontFace = F.ui, TextSize = 11, TextColor3 = C.sub, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(10, 26), Size = UDim2.new(1, -96, 0, 16), ZIndex = Z + 24 })
			Kit.label(b, { Text = if (g.price or 0) > 0 then tostring(g.price) .. " " .. currency else "free", FontFace = F.mono, TextSize = 12, TextColor3 = C.gold, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 6), Size = UDim2.fromOffset(108, 18), ZIndex = Z + 24 })
			if pick then
				Kit.label(b, { Text = "YOUR PICK", FontFace = F.display, TextSize = 11, TextColor3 = C.gold, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 30), Size = UDim2.fromOffset(80, 16), ZIndex = Z + 24 })
			end
			b.Activated:Connect(function()
				if g.enabled then
					finish(g.id)
				end
			end)
		end
		Kit.pop(panel, 0.9)
	end

	-- ── their answer (a join, a no, a goodbye, a gift, a story) ──
	showResult = function(r: any)
		if type(r) ~= "table" then
			return
		end
		local stamp, color, sub = nil, C.mana, nil
		if r.accepted == true then
			stamp, color = "JOINED YOUR PARTY", C.good
		elseif r.accepted == false and r.odds ~= nil then
			stamp, color = "SAID NO", C.bad
		elseif r.dismissed then
			stamp, color = "PARTED WAYS", C.sub
		elseif r.gift then
			stamp, color = if r.liked then "LOVED IT" elseif r.disliked then "NOT A HIT" else "GLAD OF IT", if r.liked then C.gold elseif r.disliked then C.bad else C.mana
			sub = r.giftName
		elseif r.told ~= nil then
			stamp, color = if r.told then "TOLD YOU" else "NOT YET", if r.told then C.manaHi else C.sub
			sub = if r.told then string.format("their story: %d of %d", r.index or 0, r.total or 0) else (if r.need then string.format("a bond of %d", r.need) else nil)
		end
		if not stamp then
			return
		end
		local old = frame:FindFirstChild("Result")
		if old then
			old:Destroy()
		end
		local over = make("TextButton", { Name = "Result", Text = "", AutoButtonColor = false, BackgroundColor3 = C.scrim, BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), ZIndex = Z + 30 }, frame)
		Kit.corner(over, 10)
		local card = make("Frame", { Name = "Card", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(540, 250), BackgroundColor3 = C.panelHi, ZIndex = Z + 31 }, over)
		Kit.corner(card, 10)
		Kit.gradient(card, C.panelHi, C.panel)
		local rim = Kit.stroke(card, color, 2, 0.1)
		-- who it was
		local who: any = nil
		for _, m in (view and view.members) or {} do
			if m.relId == r.relId then
				who = m
			end
		end
		for _, c in (view and view.candidates) or {} do
			if c.relId == r.relId then
				who = who or c
			end
		end
		if who then
			Kit.portrait(card, who.look, { size = UDim2.fromOffset(170, 210), position = UDim2.fromOffset(20, 20), full = true, zIndex = Z + 32 })
			Kit.rankBadge(card, who.rank or 0, 34, { Position = UDim2.fromOffset(26, 26), ZIndex = Z + 34 })
		end
		local x = if who then 210 else 24
		Kit.label(card, { Name = "Who", Text = r.name or "", FontFace = F.display, TextSize = 22, Position = UDim2.fromOffset(x, 22), Size = UDim2.new(1, -x - 20, 0, 28), ZIndex = Z + 32 })
		local stampLabel = Kit.label(card, { Name = "Stamp", Text = stamp, FontFace = F.display, TextSize = 30, TextColor3 = color, Position = UDim2.fromOffset(x, 56), Size = UDim2.new(1, -x - 20, 0, 40), Rotation = -3, ZIndex = Z + 33 })
		local line = r.line
		Kit.label(card, { Name = "Line", Text = if line then "\u{201C}" .. line .. "\u{201D}" else "", FontFace = F.serifItalic, TextSize = 16, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(x, 104), Size = UDim2.new(1, -x - 20, 0, 76), ZIndex = Z + 32 })
		local foot = if r.odds ~= nil then string.format("at %s odds%s", Kit.pct(r.odds), if r.fee then string.format("  ·  you paid their fee: %d %s", r.fee, currency) else "") else (sub or "")
		Kit.label(card, { Name = "Foot", Text = foot, FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.sub, Position = UDim2.fromOffset(x, 186), Size = UDim2.new(1, -x - 130, 0, 20), ZIndex = Z + 32 })
		Kit.button(card, "OK", color, function()
			over:Destroy()
		end, { name = "Ok", primary = true, anchor = Vector2.new(1, 1), position = UDim2.new(1, -18, 1, -18), size = UDim2.fromOffset(100, 34), zIndex = Z + 33 })
		over.Activated:Connect(function()
			over:Destroy()
		end)
		-- the little animation: the card lands, the rim flares, the stamp thumps down
		Kit.pop(card, 0.7)
		Kit.flare(rim, color)
		local s = make("UIScale", { Scale = 1.5 }, stampLabel)
		stampLabel.TextTransparency = 0.6
		TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		TweenService:Create(stampLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
	end

	render()
	Kit.pop(frame, 0.94)
	if not view then
		task.spawn(function()
			local res = call("partyView")
			if res and res.party then
				view = res.party
				if current == root then
					render()
				end
			end
		end)
	end
	return {
		frame = frame,
		root = root,
		set = function(v: any)
			view = v
			render()
		end,
		showResult = function(r: any)
			showResult(r)
		end,
		openGifts = function(p: any)
			openGifts(p, nil)
		end,
		openProfile = openProfile,
		close = PartySheet.close,
	}
end

return PartySheet
