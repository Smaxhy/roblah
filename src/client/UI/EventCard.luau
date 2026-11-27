--[[
	Event card, styled as an incident report: a tone band across the top,
	the event on paper, and choices. Clash choices open an approach picker
	(Steady / Reckless / Careful) with the odds for each.
	EventCard.show(ctx, layer, pending, onChoose(index, approachId?)) -> close()
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local AvatarView = require(script.Parent.AvatarView)
local Emblem = require(script.Parent.Emblem)
local Tip = require(script.Parent.Tip)
local Feed = require(script.Parent.Feed)

-- the scene illustration module (client/SceneArt); optional, loaded once
local sceneArt = nil
local function getSceneArt()
	if sceneArt == nil then
		sceneArt = false
		local mod = script.Parent.Parent:FindFirstChild("SceneArt")
		if mod then
			local ok, m = pcall(require, mod)
			if ok and type(m) == "table" and m.draw then
				sceneArt = m
			end
		end
	end
	return sceneArt or nil
end

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local EventCard = {}

local function oddsWord(p: number): string
	if p >= 0.8 then
		return "Strong odds"
	elseif p >= 0.55 then
		return "Good odds"
	elseif p >= 0.35 then
		return "Even odds"
	elseif p >= 0.15 then
		return "Poor odds"
	end
	return "Long odds"
end
EventCard.oddsWord = oddsWord

-- The short line under a risky choice: what it tests and the odds.
function EventCard.oddsLine(clash): string
	if not clash then
		return ""
	end
	local statName: string = tostring(clash.statName or "")
	local what: string = if clash.fight then "Fight (" .. statName .. ")" else statName .. " check"
	return string.format("%s  ·  %s  ·  %d%%", what, oddsWord(clash.odds), math.floor(clash.odds * 100 + 0.5))
end

-- hint: the choice's own hint text, if any. When it already says what kind of
-- clash this is, the odds line doesn't repeat it.
function EventCard.clashLine(clash, hint: string?): string
	if not clash then
		return ""
	end
	local p, f = clash.player, clash.foe
	local named = hint ~= nil and string.find(string.lower(hint), "clash", 1, true) ~= nil
	return string.format(
		"%s%s (~%d%%)\nYou: %d coin%s, %d +%d per heads  ·  %s: %d coin%s, %d +%d",
		if named then "" else clash.statName .. " clash  ·  ",
		oddsWord(clash.odds),
		math.floor(clash.odds * 100 + 0.5),
		p.coins,
		if p.coins == 1 then "" else "s",
		p.base,
		p.coinPower,
		Format.escape(f.name),
		f.coins,
		if f.coins == 1 then "" else "s",
		f.base,
		f.coinPower
	)
end

-- The opening of a long text: whole sentences up to about `limit` characters.
-- "+2 STR +40 Ahn" in green / "-8 HP -4 SAN" in red; things that aren't numbers (a trait, a
-- job, someone's standing with you) come as plain words. `lead` is the word in front:
-- "WIN", "LOSE", "GIVES"; nil leaves it off.
local GOOD, STRANGE = Color3.fromRGB(46, 120, 70), Color3.fromRGB(110, 70, 150)
-- a chip's tone, as a color that reads on paper
local PAPER_TONE = { good = GOOD, money = GOOD, bad = C.crimson, mixed = Color3.fromRGB(170, 112, 24), strange = STRANGE, plain = C.inkSub }
function EventCard.stakesText(ctx, list, lead: string?): string
	local parts = {}
	for _, s in list or {} do
		local text, tone = Format.stakeChip(ctx.info, s)
		table.insert(parts, Format.color(Format.escape(text), PAPER_TONE[tone] or C.inkSub))
	end
	if #parts == 0 then
		return ""
	end
	return (if lead then Format.color(lead .. " ", C.inkSub) else "") .. table.concat(parts, "  ")
end
function EventCard.stakesLine(ctx, list, good: boolean): string
	return EventCard.stakesText(ctx, list, if good then "WIN" else "LOSE")
end

-- who moves first in a fight, in a sentence (clash.first, from Speed)
function EventCard.firstLine(clash): string?
	if not (clash and clash.fight and clash.player and clash.foe and clash.player.speed and clash.foe.speed) then
		return nil
	end
	local mine, theirs = clash.player.speed, clash.foe.speed
	if clash.first == "player" then
		return string.format("You're faster (Speed %d to %d): you strike first, before the clashing starts.", mine, theirs)
	elseif clash.first == "foe" then
		return string.format("They're faster (Speed %d to your %d): they strike first, and you have to clash for everything.", theirs, mine)
	end
	return string.format("Evenly quick (Speed %d to %d): nobody gets a free strike.", mine, theirs)
end

function EventCard.shorten(text: string, limit: number): string
	if #text <= limit + 30 then
		return text
	end
	local cut = 0
	local i = 1
	while true do
		local s, e = string.find(text, "[.!?][\"']?%s", i)
		if not s or e > limit then
			break
		end
		cut = e
		i = e + 1
	end
	if cut < 60 then
		return text
	end
	return (string.gsub(string.sub(text, 1, cut), "%s+$", "")) .. " …"
end

local TONES = {
	danger = { band = C.crimson, label = "Incident report", stamp = "Danger" },
	strange = { band = Color3.fromRGB(34, 92, 88), label = "Unexplained" },
	linked = { band = Color3.fromRGB(34, 92, 88), label = "Linked life" },
	default = { band = C.ink, label = "Report" },
}

-- Row of three approach buttons for a clash choice.
-- odds as a color that reads on paper
local function oddsColor(p: number): Color3
	return if p >= 0.6 then GOOD elseif p >= 0.35 then Color3.fromRGB(170, 112, 24) else C.crimson
end

-- a small tag on paper: "+2 STR", "DEATH", "Night Terrors"
local function paperChip(text: string, color: Color3, order: number): TextLabel
	return new("TextLabel", {
		Name = "Chip",
		BackgroundColor3 = color,
		BackgroundTransparency = 0.86,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 17),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = text,
		FontFace = F.displayMed,
		TextSize = 12,
		TextColor3 = color:Lerp(Color3.new(0, 0, 0), 0.25),
		LayoutOrder = order,
		ZIndex = 3,
	}, { Kit.corner(3), Kit.padding(0, 5, 0, 5) })
end

-- what a result gives or takes, as a row of chips with a word in front ("WIN", "LOSE", "GIVES")
local function stakeRow(ctx, parent: Instance, list, lead: string, order: number)
	if not list or #list == 0 then
		return nil
	end
	local row = new("Frame", {
		Name = "Stakes",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		ZIndex = 3,
		Parent = parent,
	}, { new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Wraps = true, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }) })
	new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 17),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = lead,
		FontFace = F.display,
		TextSize = 11,
		TextColor3 = C.inkSub,
		LayoutOrder = 0,
		ZIndex = 3,
		Parent = row,
	})
	for i, s in list do
		local text, tone = Format.stakeChip(ctx.info, s)
		paperChip(text, PAPER_TONE[tone] or C.inkSub, i).Parent = row
	end
	return row
end

-- HOW DO YOU FIGHT? One button per way in: the stat it uses, your number, the odds, and how it
-- meets this foe's temper.
local function approachRow(ctx, parent, clash, stakes, order: number, onPick)
	local holder = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		Visible = false,
		ZIndex = 2,
		Parent = parent,
	}, { Kit.list(6) })
	-- who you're up against, and what they're weak to
	local temper = clash.temper
	local headText = "HOW DO YOU FIGHT?"
	if temper then
		local tcolor = if temper.color then Theme.rgb(temper.color):Lerp(Color3.new(0, 0, 0), 0.3) else C.inkSub
		headText = string.format(
			'%s   <font color="%s">%s</font>  %s%s',
			headText,
			Format.hex(tcolor),
			string.upper(Format.escape(temper.name)),
			Format.escape(temper.desc or ""),
			if temper.weakName then "  Weak to <b>" .. string.upper(Format.escape(temper.weakName)) .. "</b>." else ""
		)
	end
	Kit.text({ Name = "Temper", Text = headText, FontFace = F.displayMed, TextSize = 12, TextColor3 = C.inkSub, LayoutOrder = 0, ZIndex = 2, Parent = holder })
	local notes = {}
	if clash.first == "player" then
		table.insert(notes, Format.color("You strike first.", GOOD))
	elseif clash.first == "foe" then
		table.insert(notes, Format.color("They strike first.", C.crimson))
	end
	if clash.backer then
		table.insert(notes, Format.color(Format.escape(clash.backer) .. " stands with you: +1 coin.", GOOD))
	end
	local function abil(list)
		local parts = {}
		for _, a in list or {} do
			table.insert(parts, "<b>" .. string.upper(Format.escape(a.name)) .. (if (a.potency or 1) > 1 then " " .. tostring(a.potency) else "") .. "</b>")
		end
		return table.concat(parts, ", ")
	end
	if clash.abilities then
		table.insert(notes, Format.color("You: " .. abil(clash.abilities), GOOD))
	end
	if clash.foeAbilities then
		table.insert(notes, Format.color("They: " .. abil(clash.foeAbilities), C.crimson))
	end
	if #notes > 0 then
		Kit.text({ Name = "First", Text = table.concat(notes, "   "), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.inkSub, LayoutOrder = 0, ZIndex = 2, Parent = holder })
	end
	local list = clash.approaches or {}
	-- on a narrow card (a phone) two to a row, so each has room for its name and its number
	local narrow = (parent :: any).AbsoluteSize.X > 0 and (parent :: any).AbsoluteSize.X < 470
	local perRow = if narrow then 2 elseif #list > 4 then math.ceil(#list / 2) else math.max(1, #list)
	local rows = math.ceil(#list / perRow)
	local row = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, rows * 74 + (rows - 1) * 6),
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = holder,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.new(1 / perRow, -6, 0, 74),
			CellPadding = UDim2.fromOffset(6, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	for i, a in list do
		local sdef = a.stat and ctx.info.stats.defs[a.stat]
		local base = if a.color then Theme.rgb(a.color) elseif sdef and sdef.color then Theme.rgb(sdef.color) else C.accent
		local btn = new("TextButton", {
			Name = "Approach",
			AutoButtonColor = false,
			BackgroundColor3 = base:Lerp(Color3.new(0, 0, 0), 0.62),
			BorderSizePixel = 0,
			Text = "",
			LayoutOrder = i,
			ZIndex = 2,
			Parent = row,
		}, { Kit.corner(4), Kit.stroke(base, if a.edge == "advantage" then 2 else 1, if a.edge == "advantage" then 0 else 0.5) })
		btn:SetAttribute("Approach", a.id)
		local restColor = btn.BackgroundColor3
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = base:Lerp(Color3.new(0, 0, 0), 0.45)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = restColor
		end)
		-- the stat's mark and the way's name
		if a.stat then
			local icon = Emblem.make("stat." .. a.stat, 16)
			icon.Position = UDim2.fromOffset(7, 6)
			icon.ZIndex = 3
			icon.Parent = btn
			Kit.raise(icon, 3)
		end
		new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(if a.stat then 27 else 8, 5),
			Size = UDim2.new(1, if a.stat then -31 else -12, 0, 18),
			Text = string.upper(a.name),
			FontFace = F.display,
			TextSize = 13,
			TextColor3 = C.paperHi,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 3,
			Parent = btn,
		})
		-- the odds, big
		new("TextLabel", {
			Name = "Odds",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(8, 24),
			Size = UDim2.new(0.5, 0, 0, 24),
			Text = tostring(math.floor(a.odds * 100 + 0.5)) .. "%",
			FontFace = F.mono,
			TextSize = 21,
			TextColor3 = base:Lerp(Color3.new(1, 1, 1), 0.45),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
			Parent = btn,
		})
		-- your number in that stat
		if a.stat and a.value then
			new("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -8, 0, 28),
				Size = UDim2.new(0.5, -8, 0, 16),
				Text = string.format("%s %d", a.statShort or "", a.value),
				FontFace = F.mono,
				TextSize = 12,
				TextColor3 = C.paperHi,
				TextTransparency = 0.25,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 3,
				Parent = btn,
			})
		end
		-- how it meets this foe, or what it costs
		local tag, tagColor = nil, C.paperHi
		if a.edge == "advantage" then
			tag, tagColor = "ADVANTAGE", Color3.fromRGB(150, 226, 160)
		elseif a.edge == "resisted" then
			tag, tagColor = "RESISTED", Color3.fromRGB(246, 130, 120)
		elseif a.sanityCost then
			tag, tagColor = string.format("-%d SANITY", a.sanityCost), Color3.fromRGB(196, 160, 240)
		elseif a.healthCost then
			tag, tagColor = string.format("-%d HEALTH", a.healthCost), Color3.fromRGB(246, 120, 120)
		elseif a.natural then
			tag, tagColor = "YOUR NATURE", C.accentHi
		elseif a.short then
			tag = string.upper(a.short)
		end
		if tag then
			new("TextLabel", {
				Name = "Tag",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 1, -20),
				Size = UDim2.new(1, -16, 0, 14),
				Text = tag,
				FontFace = F.displayMed,
				TextSize = 11,
				TextColor3 = tagColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 3,
				Parent = btn,
			})
		end
		Tip.attach(btn, a.name, a.desc)
		local s = new("UIScale", { Parent = btn })
		btn.MouseButton1Down:Connect(function()
			Kit.tween(s, 0.06, { Scale = 0.95 })
		end)
		btn.MouseButton1Up:Connect(function()
			Kit.tween(s, 0.1, { Scale = 1 })
		end)
		btn.Activated:Connect(function()
			onPick(a.id)
		end)
	end
	-- a way in can pay more or cost less: say what each one changes, in numbers
	if stakes and stakes.approaches then
		local baseWin, baseLose = EventCard.stakesText(ctx, stakes.win), EventCard.stakesText(ctx, stakes.lose)
		local n = 0
		for _, a in list do
			local own = stakes.approaches[a.id]
			if own then
				local w, l = EventCard.stakesText(ctx, own.win), EventCard.stakesText(ctx, own.lose)
				local parts = {}
				if w ~= baseWin and w ~= "" then
					table.insert(parts, Format.color("WIN ", C.inkSub) .. w)
				end
				if l ~= baseLose and l ~= "" then
					table.insert(parts, Format.color("LOSE ", C.inkSub) .. l)
				end
				if #parts > 0 then
					n += 1
					Kit.text({
						Name = "StanceStakes",
						Text = "<b>" .. string.upper(Format.escape(a.name)) .. "</b>   " .. table.concat(parts, "   "),
						FontFace = F.uiMedium,
						TextSize = 12,
						TextColor3 = C.inkSub,
						LayoutOrder = 2 + n,
						ZIndex = 2,
						Parent = holder,
					})
				end
			end
		end
	end
	return holder
end

-- One choice on a card: a badge for what it tests, the words, what it gives or risks as
-- chips, and the odds as a number and a meter.
local function choiceButton(ctx, parent: Instance, choice, order: number)
	local clash = choice.clash
	local btn: any = new("TextButton", {
		Name = "Choice",
		AutoButtonColor = false,
		BackgroundColor3 = if clash then Color3.fromRGB(221, 207, 178) else C.paperHi,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		-- (tests read a choice's state from this, as they did when the button was its own text)
		TextTransparency = if choice.enabled then 0 else 0.55,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, {
		Kit.corner(4),
		Kit.stroke(if clash then C.accentLo else C.paperEdge, 1, 0),
		Kit.padding(9, 10, 9, 10),
	})
	btn:SetAttribute("Label", choice.label)
	btn:SetAttribute("Clash", clash ~= nil)
	local fade = if choice.enabled then 0 else 0.5
	if choice.enabled then
		-- it answers the pointer: lighter paper, a darker edge
		local rest = btn.BackgroundColor3
		local edge: any = btn:FindFirstChildOfClass("UIStroke")
		local restEdge = if edge then edge.Color else C.paperEdge
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = rest:Lerp(Color3.new(1, 1, 1), 0.35)
			if edge then
				edge.Color = C.ink
				edge.Thickness = 2
			end
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = rest
			if edge then
				edge.Color = restEdge
				edge.Thickness = 1
			end
		end)
	end

	-- the badge: the stat this tests, crossed blades for a fight, a plain mark otherwise
	local statKey = if clash and not clash.fight then clash.stat else nil
	local sdef = statKey and ctx.info.stats.defs[statKey]
	local badgeColor = if clash and clash.fight then C.crimson elseif sdef and sdef.color then Theme.rgb(sdef.color):Lerp(Color3.new(0, 0, 0), 0.25) else C.paperEdge
	local badge = new("Frame", {
		Name = "Badge",
		BackgroundColor3 = badgeColor,
		BackgroundTransparency = fade,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(34, 34),
		ZIndex = 3,
		Parent = btn,
	}, { Kit.corner(4) })
	if clash then
		local icon = Emblem.make(if clash.fight then "misc.fight" else "stat." .. tostring(clash.stat), 20, Color3.new(1, 1, 1), Color3.new(1, 1, 1))
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.ZIndex = 4
		icon.Parent = badge
		Kit.raise(icon, 4)
	else
		new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "›", FontFace = F.display, TextSize = 24, TextColor3 = C.ink, TextTransparency = fade, ZIndex = 4, Parent = badge })
	end

	local oddsW = if clash then 70 else 0
	local mid = new("Frame", {
		Name = "Mid",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(44, 0),
		Size = UDim2.new(1, -44 - oddsW - (if clash then 8 else 0), 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 3,
		Parent = btn,
	}, { Kit.list(3) })
	Kit.text({ Name = "Label", Text = Format.escape(choice.label), FontFace = F.uiBold, TextSize = 15, TextColor3 = C.ink, TextTransparency = fade, LayoutOrder = 1, ZIndex = 3, Parent = mid })
	-- what kind of thing this is, in three words
	if clash then
		local kindText = if clash.fight
			then "FIGHT" .. (if clash.foe and clash.foe.name then "  ·  " .. string.upper(clash.foe.name) else "")
			else string.upper((sdef and sdef.name) or tostring(clash.stat)) .. " CHECK"
		if sdef and ctx.state and ctx.state.life and ctx.state.life.stats and statKey then
			kindText ..= "  ·  YOU " .. tostring(ctx.state.life.stats[statKey] or 0)
		end
		Kit.caps({ Name = "Kind", Text = kindText, FontFace = F.displayMed, TextSize = 11, TextColor3 = C.inkSub, TextTransparency = fade, LayoutOrder = 2, ZIndex = 3, Parent = mid })
	end
	if choice.stakes and clash then
		stakeRow(ctx, mid, choice.stakes.win, "WIN", 4)
		stakeRow(ctx, mid, choice.stakes.lose, "LOSE", 5)
	elseif choice.gains and #choice.gains > 0 then
		stakeRow(ctx, mid, choice.gains, "GIVES", 4)
	end
	if not choice.enabled and choice.reason then
		Kit.text({ Name = "Reason", Text = Format.escape(choice.reason), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.crimson, LayoutOrder = 6, ZIndex = 3, Parent = mid })
	end
	-- the hint is one hover (or long press) away, not on the card
	if choice.hint then
		Tip.attach(btn, choice.label, choice.hint)
	end

	-- the odds: a number and a meter. A fight shows your best way in.
	if clash then
		local p = clash.bestOdds or clash.odds or 0
		local color = oddsColor(p)
		local box = new("Frame", {
			Name = "OddsBox",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(oddsW, 34),
			ZIndex = 3,
			Parent = btn,
		})
		new("TextLabel", {
			Name = "Odds",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			Text = tostring(math.floor(p * 100 + 0.5)) .. "%",
			FontFace = F.mono,
			TextSize = 20,
			TextColor3 = color,
			TextTransparency = fade,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 3,
			Parent = box,
		})
		local track = new("Frame", { BackgroundColor3 = C.paperEdge, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 5), ZIndex = 3, Parent = box }, { Kit.corner(2) })
		new("Frame", { Name = "Fill", BackgroundColor3 = color, BackgroundTransparency = fade, BorderSizePixel = 0, Size = UDim2.new(math.clamp(p, 0.02, 1), 0, 1, 0), ZIndex = 4, Parent = track }, { Kit.corner(2) })
	end
	return btn
end

-- pending can also be an expedition stage: pending.band = { label, color } replaces the
-- tone band, pending.step labels the right side, pending.note adds a line under the
-- text, and pending.readOnly (a crewmate, not the captain) turns taps into onSuggest(index).
function EventCard.show(ctx, layer: Instance, pending, onChoose, onSuggest)
	local scrim = Kit.scrim(layer, 1)
	Kit.tween(scrim, 0.25, { BackgroundTransparency = 0.3 })

	local tone = pending.band or TONES[if pending.linked then "linked" else (pending.tone or "default")] or TONES.default
	-- THE THREAD: which part of your life this card belongs to. Its color and its mark are the
	-- band; following one color down the feed is following one story.
	local thread = nil
	if not pending.band and pending.thread then
		thread = Feed.thread(pending.thread)
		tone = { band = thread.color:Lerp(Color3.new(0, 0, 0), 0.5), label = thread.label, stamp = tone.stamp }
	end
	if pending.story then
		-- a beat of this life's own story: the band carries its name and its color
		tone = { band = Theme.tone(pending.story.tone):Lerp(Color3.new(0, 0, 0), 0.35), label = "Your story  ·  " .. (pending.story.name or "") }
	end
	-- (v0.13) a card dressed for what it is: an episode, a descent, a facility record...
	local skin = pending.theme and Theme.cardThemes and Theme.cardThemes[pending.theme] or nil
	local episode = pending.episode
	if skin and not pending.story then
		-- (a card that brings its own band, an expedition's stage, keeps its name on it)
		tone = { band = if pending.band and pending.tone == "danger" then tone.band else skin.band, label = if pending.band then tone.label else skin.word, stamp = tone.stamp }
	end
	if episode then
		local ec = if type(episode.color) == "table" then Color3.fromRGB(episode.color[1], episode.color[2], episode.color[3]) else (skin and skin.accent or C.accent)
		tone = { band = (skin and skin.band) or ec:Lerp(Color3.new(0, 0, 0), 0.6), label = "Episode  ·  " .. (episode.name or ""), stamp = tone.stamp, pips = { step = episode.step or 1, of = episode.of or 1, color = ec } }
	end
	local card = new("Frame", {
		Name = "EventCard",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = if skin then skin.paper else C.paper,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = layer,
	}, {
		Kit.corner(2),
		Kit.stroke(if skin then skin.edge else C.paperEdge, 2, 0),
		Kit.list(0),
	})
	-- the motif, over the whole card (in Folders, so the card's list layout leaves it alone)
	if skin then
		local motif = skin.motif
		if motif == "gild" then
			Kit.brackets(card, skin.accent, 18, 3, 4)
		elseif motif == "scan" then
			local folder = new("Folder", { Name = "ScanLayer", Parent = card })
			local keys = {}
			for i = 0, 9 do
				table.insert(keys, NumberSequenceKeypoint.new(i / 10, 0.93))
				table.insert(keys, NumberSequenceKeypoint.new(i / 10 + 0.02, 1))
			end
			table.insert(keys, NumberSequenceKeypoint.new(1, 1))
			new("Frame", { Name = "Scan", BackgroundColor3 = skin.edge, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = folder }, {
				new("UIGradient", { Transparency = NumberSequence.new(keys), Rotation = 90 }),
			})
			Kit.brackets(card, skin.accent, 12, 2, 3)
		elseif motif == "depth" then
			local folder = new("Folder", { Name = "DepthLayer", Parent = card })
			local gauge = new("Frame", { Name = "Depth", BackgroundColor3 = skin.band, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -3, 0, 34), Size = UDim2.new(0, 4, 1, -40), ZIndex = 3, Parent = folder }, { Kit.corner(2) })
			new("Frame", { BackgroundColor3 = skin.accent, BorderSizePixel = 0, Size = UDim2.fromScale(1, 0.4), ZIndex = 4, Parent = gauge }, { Kit.corner(2), Kit.gradient(skin.accent, skin.band, 90) })
		elseif motif == "drip" then
			local folder = new("Folder", { Name = "DripLayer", Parent = card })
			new("Frame", { Name = "Drip", BackgroundColor3 = skin.accent, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 0, 3), ZIndex = 3, Parent = folder })
		elseif motif == "haze" then
			local folder = new("Folder", { Name = "HazeLayer", Parent = card })
			new("Frame", { Name = "Haze", BackgroundColor3 = skin.edge, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = folder }, {
				new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 0.86) }), Rotation = 90 }),
			})
		end
	end
	-- a rare card: a gold ribbon across its corner
	if pending.rare then
		local folder = new("Folder", { Name = "RareLayer", Parent = card })
		local ribbon = new("Frame", { Name = "Rare", BackgroundColor3 = Color3.fromRGB(226, 182, 74), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -26, 0, 52), Size = UDim2.fromOffset(110, 20), Rotation = 35, ZIndex = 6, Parent = folder }, {
			Kit.gradient(Color3.fromRGB(250, 220, 130), Color3.fromRGB(190, 140, 40), 0),
		})
		Kit.caps({ Text = "RARE", Size = UDim2.fromScale(1, 1), TextSize = 12, FontFace = F.display, TextColor3 = Color3.fromRGB(60, 40, 10), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 7, Parent = ribbon })
	end
	local scale = new("UIScale", { Parent = card })
	scale.Scale = 0.94

	-- tone band
	local band = new("Frame", {
		BackgroundColor3 = tone.band,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 0,
		ZIndex = 2,
		Parent = card,
	}, { Kit.padding(0, 16, 0, 16) })
	if pending.tone == "danger" then
		Kit.stripes(band, Color3.fromRGB(0, 0, 0), 0.75, 10)
	end
	local labelX = 0
	if thread or pending.story then
		local mark = Emblem.make(if pending.story then "thread.story" else (thread :: any).emblem, 16, Color3.new(1, 1, 1), Color3.new(1, 1, 1))
		mark.AnchorPoint = Vector2.new(0, 0.5)
		mark.Position = UDim2.new(0, 0, 0.5, 0)
		mark.ZIndex = 3
		mark.Parent = band
		Kit.raise(mark, 3)
		labelX = 22
	end
	Kit.caps({ Text = tone.label, Position = UDim2.fromOffset(labelX, 0), Size = UDim2.new(0.62, -labelX, 1, 0), FontFace = F.display, TextSize = 13, TextColor3 = C.paperHi, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = band })
	-- why this is happening to you is a hover away
	if pending.why then
		Tip.attach(band, tone.label, pending.why)
	end
	local life = ctx.state and ctx.state.life
	if tone.pips then
		-- an episode: how far into it this card is, one pip a card
		local row = new("Frame", { Name = "Pips", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(160, 14), ZIndex = 3, Parent = band }, {
			Kit.list(5, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center),
		})
		local of = math.clamp(tone.pips.of, 1, 8)
		for i = 1, of do
			local on = i <= tone.pips.step
			new("Frame", {
				BackgroundColor3 = if on then tone.pips.color else Color3.new(1, 1, 1),
				BackgroundTransparency = if on then 0 else 0.75,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(if i == tone.pips.step then 18 else 9, 9),
				LayoutOrder = i,
				ZIndex = 3,
				Parent = row,
			}, { Kit.corner(5) })
		end
		Kit.caps({ Text = string.format("%d / %d", tone.pips.step, tone.pips.of), Size = UDim2.fromOffset(38, 14), TextSize = 11, TextColor3 = C.paperHi, TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 0, ZIndex = 3, Parent = row })
	elseif pending.step then
		Kit.caps({
			Text = pending.step,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromScale(0.5, 1),
			TextSize = 12,
			TextColor3 = C.paperHi,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 3,
			Parent = band,
		})
	elseif life and life.district then
		Kit.caps({
			Text = string.format("%s %d · %s", (ctx.info.city and ctx.info.city.word) or "Ward", life.district.number, life.side.short),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromScale(0.5, 1),
			TextSize = 12,
			TextColor3 = C.paperHi,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 3,
			Parent = band,
		})
	end

	-- the scene, drawn (client/SceneArt), when the event has one
	local art = getSceneArt()
	local sceneBanner: any = nil
	local layerWide = (layer :: any).AbsoluteSize.X
	local narrowCard = layerWide > 0 and layerWide < 470
	if art and pending.art then
		local banner = new("Frame", {
			Name = "Scene",
			BackgroundColor3 = C.ink,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 128),
			ClipsDescendants = true,
			LayoutOrder = 0,
			ZIndex = 2,
			Parent = card,
		})
		local seed = 0
		for i = 1, #(pending.id or "") do
			seed = (seed * 31 + string.byte(pending.id, i)) % 100000
		end
		local ok = pcall(function()
			local drawn = art.draw(banner, pending.art, seed, { fade = C.paper })
			-- a little life in it (a flickering sign, rain, a passing train), unless effects are off
			if drawn and Kit.effects and art.animate then
				art.animate(drawn)
			end
		end)
		if not ok then
			banner:Destroy()
		else
			sceneBanner = banner
		end
	end

	local body = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = card,
	}, { Kit.padding(16, 18, 18, 18), Kit.list(10) })

	if pending.friend then
		-- the linked friend this event is about
		local who = new("Frame", {
			Name = "Friend",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 52),
			LayoutOrder = 0,
			ZIndex = 2,
			Parent = body,
		}, { Kit.list(10, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center) })
		local view = AvatarView.new(ctx, { size = UDim2.fromOffset(48, 52), framing = "portrait", zIndex = 2, order = 1, background = C.ink })
		view.frame.Parent = who
		view:set(pending.friend.appearance)
		Kit.text({
			Text = "WITH " .. string.upper(Format.escape(pending.friend.name)),
			FontFace = F.display,
			TextSize = 15,
			TextColor3 = Color3.fromRGB(34, 92, 88),
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.new(0, 0, 0, 0),
			LayoutOrder = 2,
			ZIndex = 2,
			Parent = who,
		})
	end
	Kit.text({ Text = Format.escape(pending.title), FontFace = F.title, TextSize = 22, TextColor3 = C.ink, LayoutOrder = 1, ZIndex = 2, Parent = body })
	new("Frame", { BackgroundColor3 = C.crimson, BorderSizePixel = 0, Size = UDim2.new(0, 40, 0, 3), LayoutOrder = 2, ZIndex = 2, Parent = body })
	-- long scenes show their opening; "More" reads the rest
	local full = pending.text or ""
	local short = EventCard.shorten(full, 150)
	local textLabel = Kit.text({ Name = "EventText", Text = Format.escape(short), FontFace = F.serif, TextSize = 16, TextColor3 = C.ink, LineHeight = 1.2, LayoutOrder = 3, ZIndex = 2, Parent = body })
	if short ~= full then
		local more = new("TextButton", {
			Name = "More",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 80, 0, 20),
			Text = "MORE  ▾",
			FontFace = F.display,
			TextSize = 13,
			TextColor3 = C.crimson,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 3,
			ZIndex = 2,
			Parent = body,
		})
		more.Activated:Connect(function()
			textLabel.Text = Format.escape(full)
			more:Destroy()
		end)
	end
	if pending.crew and #pending.crew > 0 then
		-- who's on this run
		local roster = new("Frame", {
			Name = "Crew",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
			LayoutOrder = 3,
			ZIndex = 2,
			Parent = body,
		}, { Kit.list(6, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center) })
		for i, m in pending.crew do
			local view = AvatarView.new(ctx, { size = UDim2.fromOffset(34, 36), framing = "portrait", zIndex = 2, order = i, background = C.ink })
			view.frame.Parent = roster
			view:set(m.appearance)
		end
	end
	if pending.note then
		Kit.text({ Text = Format.escape(pending.note), FontFace = F.displayMed, TextSize = 13, TextColor3 = C.crimson, LayoutOrder = 3, ZIndex = 2, Parent = body })
	end

	-- City words in this scene that a new life wouldn't know yet: tap (or hover) to read what they are
	if pending.terms and #pending.terms > 0 then
		local row = new("Frame", {
			Name = "Terms",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 4,
			ZIndex = 2,
			Parent = body,
		}, { Kit.list(6, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center), })
		local wrapList = row:FindFirstChildOfClass("UIListLayout")
		if wrapList then
			wrapList.Wraps = true
		end
		Kit.text({ Text = "WHAT'S THAT?", FontFace = F.display, TextSize = 11, TextColor3 = C.inkSub, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.new(0, 0, 0, 0), LayoutOrder = 0, ZIndex = 2, Parent = row })
		local explain = Kit.text({ Name = "TermText", Text = "", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.inkSub, Visible = false, LayoutOrder = 4, ZIndex = 2, Parent = body })
		local open = nil
		for i, t in pending.terms do
			local chip = new("TextButton", {
				Name = "Term",
				AutoButtonColor = false,
				BackgroundColor3 = C.paperHi,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 0, 22),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = string.upper(Format.escape(t.term)),
				FontFace = F.displayMed,
				TextSize = 12,
				TextColor3 = C.ink,
				LayoutOrder = i,
				ZIndex = 2,
				Parent = row,
			}, { Kit.corner(2), Kit.padding(0, 8, 0, 8), Kit.stroke(C.paperEdge, 1, 0) })
			Tip.attach(chip, t.term, t.text)
			chip.Activated:Connect(function()
				if open == i then
					open = nil
					explain.Visible = false
				else
					open = i
					explain.Text = "<b>" .. Format.escape(t.term) .. ".</b>  " .. Format.escape(t.text or "")
					explain.Visible = true
				end
			end)
		end
	end

	local choices = new("Frame", {
		Name = "Choices",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 5,
		ZIndex = 2,
		Parent = body,
	}, { Kit.list(8) })

	-- a talking scene: one line at a time with the speaker's face; the choices come after
	if pending.dialogue and #pending.dialogue > 0 then
		choices.Visible = false
		local box: any = new("TextButton", {
			Name = "Dialogue",
			AutoButtonColor = false,
			BackgroundColor3 = C.ink,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 92),
			Text = "",
			LayoutOrder = 4,
			ZIndex = 2,
			Parent = body,
		}, { Kit.corner(2) })
		local faceHolder = new("Frame", { BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(68, 76), ClipsDescendants = true, ZIndex = 2, Parent = box }, { Kit.corner(2) })
		local nameLabel = new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(86, 8),
			Size = UDim2.new(1, -96, 0, 18),
			Text = "",
			FontFace = F.display,
			TextSize = 14,
			TextColor3 = C.accentHi,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
			Parent = box,
		})
		local lineLabel = new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(86, 28),
			Size = UDim2.new(1, -96, 1, -36),
			Text = "",
			TextWrapped = true,
			FontFace = F.serif,
			TextSize = 15,
			TextColor3 = C.paperHi,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 3,
			Parent = box,
		})
		local hint = new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -8, 1, -4),
			Size = UDim2.fromOffset(60, 14),
			Text = "TAP  ›",
			FontFace = F.displayMed,
			TextSize = 11,
			TextColor3 = C.faint,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 3,
			Parent = box,
		})
		local face = nil
		local index = 0
		local typing = false
		local fullLine = ""
		local function showLine(i: number)
			local d = pending.dialogue[i]
			index = i
			for _, child in faceHolder:GetChildren() do
				if child:IsA("GuiObject") then
					child:Destroy()
				end
			end
			face = nil
			if d.look then
				face = AvatarView.new(ctx, { size = UDim2.fromScale(1, 1), framing = "portrait", zIndex = 3, background = C.panelLo })
				face.frame.Parent = faceHolder
				face:set({ look = d.look, age = 30, form = "human", sanity = 0 })
			else
				-- no face to draw: a shadow with eyes, or a silhouette
				local eye = if d.creature and d.creature.eye then Theme.rgb(d.creature.eye) else nil
				new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(0.7, 0.5), BackgroundColor3 = C.stroke, BorderSizePixel = 0, ZIndex = 3, Parent = faceHolder }, { Kit.corner(8) })
				new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.36), Size = UDim2.fromScale(0.42, 0.38), BackgroundColor3 = C.stroke, BorderSizePixel = 0, ZIndex = 3, Parent = faceHolder }, { Kit.round() })
				if eye then
					for _, x in { 0.42, 0.58 } do
						new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, 0.36), Size = UDim2.fromOffset(5, 5), BackgroundColor3 = eye, BorderSizePixel = 0, ZIndex = 4, Parent = faceHolder }, { Kit.round() })
					end
				end
			end
			local who = string.upper(d.name or "")
			if d.title and d.title ~= "" then
				who ..= "  " .. Format.color(string.upper(d.title), C.faint)
			end
			nameLabel.RichText = true
			nameLabel.Text = who
			nameLabel.TextColor3 = if d.kind == "you" then C.good elseif d.kind == "foe" then C.crimsonHi else C.accentHi
			fullLine = d.line or ""
			-- type it out
			typing = true
			lineLabel.Text = ""
			hint.Text = if i < #pending.dialogue then "TAP  ›" else "TAP  ✓"
			task.spawn(function()
				local n = #fullLine
				local step = math.max(1, math.floor(n / 40))
				for c = 1, n, step do
					if not typing or index ~= i or not lineLabel.Parent then
						return
					end
					lineLabel.Text = string.sub(fullLine, 1, c)
					task.wait(0.02)
				end
				if index == i then
					lineLabel.Text = fullLine
					typing = false
				end
			end)
			if ctx.sfx then
				ctx.sfx("click", { volume = 0.5, pitch = 1.2 })
			end
		end
		local function finish()
			box.Visible = false
			choices.Visible = true
			for _, child in choices:GetChildren() do
				if child:IsA("GuiObject") and child.Name == "Choice" then
					local sc = new("UIScale", { Scale = 0.94, Parent = child })
					Kit.tween(sc, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
				end
			end
		end
		box.Activated:Connect(function()
			if typing then
				typing = false
				lineLabel.Text = fullLine
				return
			end
			if index < #pending.dialogue then
				showLine(index + 1)
			else
				finish()
			end
		end)
		local skipButton = new("TextButton", {
			Name = "SkipDialogue",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 120, 0, 18),
			Text = "SKIP TO CHOICES  ›",
			FontFace = F.display,
			TextSize = 12,
			TextColor3 = C.crimson,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 4,
			ZIndex = 2,
			Parent = body,
		})
		skipButton.Activated:Connect(function()
			typing = false
			skipButton:Destroy()
			finish()
		end)
		box:GetPropertyChangedSignal("Visible"):Connect(function()
			if not box.Visible and skipButton.Parent then
				skipButton:Destroy()
			end
		end)
		showLine(1)
	end

	if tone.stamp then
		Kit.stamp(card, tone.stamp, C.crimson, { Position = UDim2.new(1, -70, 0, 58), Rotation = 9, TextSize = 18 })
	end

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		Kit.tween(scrim, 0.2, { BackgroundTransparency = 1 })
		Kit.tween(scale, 0.2, { Scale = 0.96 })
		task.delay(0.2, function()
			scrim:Destroy()
			card:Destroy()
		end)
	end

	local openPicker = nil
	for i, choice in pending.choices do
		local btn = choiceButton(ctx, choices, choice, i * 2)
		local picker = nil
		if choice.clash and choice.enabled and not choice.battle and choice.clash.approaches and #choice.clash.approaches > 0 then
			picker = approachRow(ctx, choices, choice.clash, choice.stakes, i * 2 + 1, function(approachId)
				if not closed then
					close()
					onChoose(choice.index, approachId)
				end
			end)
		end
		local bscale = new("UIScale", { Parent = btn })
		btn.MouseButton1Down:Connect(function()
			if choice.enabled then
				Kit.tween(bscale, 0.06, { Scale = 0.98 })
			end
		end)
		btn.MouseButton1Up:Connect(function()
			Kit.tween(bscale, 0.1, { Scale = 1 })
		end)
		btn.MouseLeave:Connect(function()
			Kit.tween(bscale, 0.1, { Scale = 1 })
		end)
		btn.Activated:Connect(function()
			if not choice.enabled or closed then
				return
			end
			if pending.readOnly then
				if onSuggest then
					onSuggest(choice.index)
				end
				return
			end
			if picker then
				if openPicker and openPicker ~= picker then
					openPicker.Visible = false
				end
				picker.Visible = not picker.Visible
				openPicker = if picker.Visible then picker else nil
				-- a phone has no room for the picture and the ways to fight at once
				if narrowCard and sceneBanner and sceneBanner.Parent then
					sceneBanner.Visible = openPicker == nil
				end
			else
				close()
				onChoose(choice.index, nil)
			end
		end)
	end

	local function fit(): number
		local host: any = card.Parent
		local room = if host and host:IsA("GuiObject") then host.AbsoluteSize.Y else 0
		local tall = (card :: any).AbsoluteSize.Y / math.max(scale.Scale, 0.01)
		if room > 0 and tall > room - 24 then
			return math.clamp((room - 24) / tall, 0.7, 1)
		end
		return 1
	end
	local settled = false
	Kit.tween(scale, 0.26, { Scale = fit() }, Enum.EasingStyle.Back)
	task.delay(0.3, function()
		settled = true
		if card.Parent then
			scale.Scale = fit()
		end
	end)
	local cardObject: any = card
	cardObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if settled and card.Parent then
			local want = fit()
			if math.abs(want - scale.Scale) > 0.02 then
				scale.Scale = want
			end
		end
	end)
	return close
end

return EventCard
