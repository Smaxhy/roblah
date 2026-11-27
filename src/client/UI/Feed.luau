--[[
	THE FEED: the middle of the life screen. What happened, as cards instead of a wall of text.

	One card per thing that happened (a scene and what you chose, something you did, a year
	turning). Everything that followed from it (what it gave, what it cost, a fight won or lost,
	something learned) lands on the same card as chips and short notes. The words of the outcome
	show as one line; tap the card to read all of it.

	Every card carries the color and the mark of its THREAD: the part of your life it belongs
	to (your story, your work, your people, your District, the age, a grudge...). Following one
	color down the feed is following one story.

		local card = Feed.card(info, { title, thread, choice })
		local card = Feed.year(info, entry)
		card:add(entry)      -- log, clash, system, rep, learned, school, dialogue, summary, world, friend
		card.frame           -- parent it into the log
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Emblem = require(script.Parent.Emblem)
local Tip = require(script.Parent.Tip)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Feed = {}

-- the threads of a life
Feed.THREADS = {
	story = { label = "Your story", color = Color3.fromRGB(226, 86, 76), emblem = "thread.story" },
	work = { label = "Work", color = Color3.fromRGB(207, 163, 73), emblem = "thread.work" },
	people = { label = "People", color = Color3.fromRGB(96, 186, 178), emblem = "thread.people" },
	district = { label = "Your District", color = Color3.fromRGB(120, 170, 226), emblem = "thread.district" },
	age = { label = "The age", color = Color3.fromRGB(240, 214, 140), emblem = "thread.age" },
	brink = { label = "The brink", color = Color3.fromRGB(168, 120, 222), emblem = "thread.brink" },
	grudge = { label = "A grudge", color = Color3.fromRGB(214, 64, 58), emblem = "thread.grudge" },
	danger = { label = "The streets", color = Color3.fromRGB(232, 142, 70), emblem = "thread.danger" },
	past = { label = "From before", color = Color3.fromRGB(170, 172, 186), emblem = "thread.past" },
	self = { label = "What you are", color = Color3.fromRGB(214, 96, 88), emblem = "thread.self" },
	city = { label = "Today in the City", color = Color3.fromRGB(120, 170, 226), emblem = "thread.city" },
	life = { label = "The City", color = Color3.fromRGB(160, 162, 174), emblem = "thread.life" },
	you = { label = "You chose", color = Color3.fromRGB(207, 163, 73), emblem = "tab.do" },
	-- (v0.18) what the life is about right now: the follow-ups of something that happened
	focus = { label = "Following on", color = Color3.fromRGB(236, 196, 104), emblem = "thread.past" },
}

-- a thread as sent by the server ({ kind, label } or just the kind) -> how it looks
function Feed.thread(thread: any)
	local kind = if type(thread) == "table" then thread.kind else thread
	local def = Feed.THREADS[kind or "life"] or Feed.THREADS.life
	local label = def.label
	if type(thread) == "table" and thread.label and thread.label ~= "" then
		label = def.label .. "  ·  " .. thread.label
	end
	return { kind = kind or "life", label = label, color = def.color, emblem = def.emblem }
end

-- a small colored tag: "+2 STR", "WON", "-10 Ahn"
function Feed.chip(text: string, color: Color3, order: number?): TextLabel
	return new("TextLabel", {
		Name = "Chip",
		BackgroundColor3 = color,
		BackgroundTransparency = 0.84,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = text,
		FontFace = F.displayMed,
		TextSize = 12,
		TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.3),
		LayoutOrder = order or 0,
	}, { Kit.corner(3), Kit.padding(0, 6, 0, 6) })
end

-- what changed, as chips, in the order the stats are shown
function Feed.deltaChips(parent: Instance, deltas, info, startOrder: number): number
	local order = startOrder
	local keys = table.clone(info.stats.order)
	table.insert(keys, "sanity")
	table.insert(keys, "money")
	table.insert(keys, "bond")
	for _, key in keys do
		local d = deltas[key]
		if d and d ~= 0 then
			local label
			if key == "money" then
				label = info.meta.currency
			elseif key == "sanity" then
				label = "SAN"
			elseif key == "bond" then
				label = "BOND"
			else
				local def = info.stats.defs[key]
				label = if def then def.short else string.upper(key)
			end
			local color = if key == "money" and d > 0 then C.money elseif d > 0 then C.good else C.bad
			order += 1
			Feed.chip(Format.signed(d) .. " " .. label, color, order).Parent = parent
		end
	end
	return order
end

local Card = {}
Card.__index = Card

-- A YEAR: no box. The age in gold on a rule across the feed, the year at its far end. What the
-- year paid and cost hangs under it.
local function buildYear(info, head)
	local outer: any = new("TextButton", {
		Name = "FeedYear",
		AutoButtonColor = false,
		Text = "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	outer:SetAttribute("Thread", "life")
	local body = new("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = outer,
	}, { Kit.padding(10, 2, 4, 2), Kit.list(4) })
	local headRow = new("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 1, Parent = body })
	local age = new("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = string.upper(Format.escape(head.title or "")),
		FontFace = F.display,
		TextSize = 22,
		TextColor3 = C.accentHi,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = headRow,
	})
	-- the rule runs from the age to the year
	new("Frame", {
		Name = "Rule",
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 84, 0.5, 1),
		Size = UDim2.new(1, -84 - (if head.right then 84 else 0), 0, 1),
		Parent = headRow,
	}, { new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.85) }) }) })
	-- (v0.12) a year with a mood wears it: its colour on the age and the rule, its name beneath
	if head.mood then
		local mc = if head.mood.color then Theme.rgb(head.mood.color) else C.accentHi
		age.TextColor3 = mc:Lerp(Color3.new(1, 1, 1), 0.15)
		local rule = headRow:FindFirstChild("Rule")
		if rule and rule:IsA("Frame") then
			rule.BackgroundColor3 = mc
		end
		Kit.text({
			Name = "Mood",
			Text = Format.color(string.upper(Format.escape(head.mood.name or "")), mc) .. (if head.mood.text and head.mood.text ~= "" then "   " .. Format.color(Format.escape(head.mood.text), C.sub) else ""),
			FontFace = F.displayMed,
			TextSize = 12,
			LayoutOrder = 2,
			Parent = body,
		})
	end
	if head.right then
		new("TextLabel", {
			Name = "Picked",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 80, 1, 0),
			Text = string.upper(Format.escape(head.right)),
			FontFace = F.displayMed,
			TextSize = 12,
			TextColor3 = C.faint,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = headRow,
		})
	end
	return outer, body, age
end

local function build(info, head)
	local t = Feed.thread(head.thread)
	local outer: any, body: any
	if head.year then
		outer, body = buildYear(info, head)
	else
		outer = new("TextButton", {
			Name = "FeedCard",
			AutoButtonColor = false,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(30, 33, 40),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = true,
		}, { Kit.corner(5), Kit.depth(nil :: any, true) })
		outer:SetAttribute("Thread", t.kind)
		-- the thread's color down the left edge
		new("Frame", { Name = "Edge", BackgroundColor3 = t.color, BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, 0), Parent = outer })
		body = new("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(3, 0),
			Size = UDim2.new(1, -3, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = outer,
		}, { Kit.padding(8, 10, 9, 9), Kit.list(5) })

		local headRow = new("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1, Parent = body })
		local hasChoice = head.choice ~= nil and head.choice ~= ""
		-- the thread's mark on a tile of its color
		local tile = new("Frame", {
			Name = "Mark",
			BackgroundColor3 = t.color,
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(24, 24),
			Parent = headRow,
		}, { Kit.corner(5), Kit.stroke(t.color, 1, 0.55) })
		local icon = Emblem.make(t.emblem, 15)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.Parent = tile
		Tip.attach(tile, t.label, nil)
		new("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(32, 0),
			Size = if hasChoice then UDim2.new(0.56, -32, 1, 0) else UDim2.new(1, -32, 1, 0),
			Text = Format.escape(head.title or ""),
			FontFace = F.title,
			TextSize = 14,
			TextColor3 = if head.hazard then C.crimsonHi else C.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = headRow,
		})
		if hasChoice or head.right then
			new("TextLabel", {
				Name = "Picked",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0.44, 0, 1, 0),
				Text = string.upper(Format.escape(head.choice or head.right or "")),
				FontFace = F.displayMed,
				TextSize = 12,
				TextColor3 = t.color,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = headRow,
			})
		end
	end

	-- the words: one line until the card is tapped (and none at all once its year is behind you)
	local text: any = Kit.text({
		Name = "Words",
		Text = "",
		FontFace = F.serif,
		TextSize = 13,
		TextColor3 = C.sub,
		Size = UDim2.new(1, 0, 0, 17),
		AutomaticSize = Enum.AutomaticSize.None,
		TextWrapped = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = false,
		LayoutOrder = 2,
		Parent = body,
	})
	local chips = new("Frame", {
		Name = "Chips",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		LayoutOrder = 3,
		Parent = body,
	}, { new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Wraps = true, SortOrder = Enum.SortOrder.LayoutOrder }) })

	local self = setmetatable({
		frame = outer,
		body = body,
		text = text,
		chips = chips,
		info = info,
		words = {},
		order = 0,
		noteOrder = 10,
		open = false,
		folded = false,
		year = head.year == true,
	}, Card)
	outer.Activated:Connect(function()
		self:toggle()
	end)
	if not head.year then
		-- it answers the pointer: there is more to read inside
		local base = outer.BackgroundColor3
		outer.MouseEnter:Connect(function()
			outer.BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.05)
		end)
		outer.MouseLeave:Connect(function()
			outer.BackgroundColor3 = base
		end)
	end
	return self
end

-- a scene, a choice, something you did
function Feed.card(info, head)
	return build(info, head)
end

-- a year turning: its age on the left, its year on the right
function Feed.year(info, entry)
	return build(info, { title = entry.text or "", right = if entry.year then "Year " .. entry.year else nil, thread = "life", year = true, mood = entry.mood })
end

-- FOLDED: once its year is behind you, a card is its title and what it gave. Its words come
-- back when it's tapped.
function Card:fold(folded: boolean)
	self.folded = folded
	self.text.Visible = #self.words > 0 and (self.open or not folded)
end

function Card:toggle()
	if #self.words == 0 then
		return
	end
	self.open = not self.open
	local t = self.text
	t.Visible = self.open or not self.folded
	t.Text = if self.open then table.concat(self.words, "\n") else self.words[1]
	if self.open then
		t.TextWrapped = true
		t.TextTruncate = Enum.TextTruncate.None
		t.AutomaticSize = Enum.AutomaticSize.Y
		t.Size = UDim2.new(1, 0, 0, 0)
		t.TextColor3 = C.text
	else
		t.TextWrapped = false
		t.TextTruncate = Enum.TextTruncate.AtEnd
		t.AutomaticSize = Enum.AutomaticSize.None
		t.Size = UDim2.new(1, 0, 0, 17)
		t.TextColor3 = C.sub
	end
end

function Card:say(words: string)
	if words == "" then
		return
	end
	table.insert(self.words, words)
	self.text.Text = if self.open then table.concat(self.words, "\n") else self.words[1]
	self.text.Visible = self.open or not self.folded
end

function Card:chip(text: string, color: Color3, tipTitle: string?, tipBody: string?)
	self.order += 1
	local chip = Feed.chip(text, color, self.order)
	chip.Parent = self.chips
	self.chips.Visible = true
	if tipTitle then
		Tip.attach(chip, tipTitle, tipBody)
	end
	return chip
end

-- a short line under the chips: a promotion, something the City did, news of a friend
function Card:note(text: string, color: Color3)
	self.noteOrder += 1
	Kit.text({ Name = "Note", Text = text, FontFace = F.displayMed, TextSize = 12, TextColor3 = color, LayoutOrder = self.noteOrder, Parent = self.body })
end

-- everything that followed from this card's moment
function Card:add(entry)
	local kind = entry.kind
	if kind == "clash" then
		self:chip(if entry.won then "WON" else "LOST", if entry.won then C.good else C.bad, entry.text, nil)
	elseif kind == "learned" then
		self:chip("+ " .. string.upper(entry.title or "ARCHIVE"), C.accentHi, entry.title, entry.text)
	elseif kind == "school" then
		local color = if entry.color then Theme.rgb(entry.color) else C.accentHi
		self:chip("TAUGHT  " .. string.upper(entry.style or entry.title or ""), color, entry.title, entry.text)
	elseif kind == "rep" then
		self:note(string.upper(Format.escape(entry.text or "")), if (entry.delta or 0) >= 0 then C.good else C.crimsonHi)
	elseif kind == "system" then
		local color = if entry.tone == "good" then C.good elseif entry.tone == "bad" then C.crimsonHi elseif entry.tone == "strange" then C.strange else C.accentHi
		self:note(string.upper(Format.escape(entry.text or "")), color)
	elseif kind == "world" then
		self:note(string.upper(Format.escape(entry.text or "")), C.strange)
	elseif kind == "gift" then
		local color = if entry.color then Theme.rgb(entry.color) else C.strange
		self:chip("GIFT  " .. string.upper(entry.title or ""), color, entry.title, entry.text)
		self:note(Format.escape(entry.text or ""), color)
	elseif kind == "renown" then
		local color = if entry.color then Theme.rgb(entry.color) else C.accentHi
		self:chip("RENOWN  " .. string.upper(entry.title or ""), color, entry.title, entry.text)
		self:note(Format.escape(entry.text or ""), color)
	elseif kind == "feat" then
		-- (v0.13) a feat earned, in its tier's color
		local color = if entry.color then Theme.rgb(entry.color) else C.accentHi
		self:chip("FEAT  " .. string.upper(entry.title or ""), color, entry.title, entry.text)
	elseif kind == "episodeEnd" then
		local color = if entry.color then Theme.rgb(entry.color) else C.strange
		self:chip("EPISODE  " .. string.upper(entry.title or ""), color, entry.title, entry.text)
		self:note(Format.escape(entry.text or ""), color)
	elseif kind == "phase" then
		local color = if entry.color then Theme.rgb(entry.color) else C.strange
		self:note("A NEW PART OF LIFE: " .. string.upper(Format.escape(entry.title or "")), color)
		if entry.text and entry.text ~= "" then
			self:say(Format.escape(entry.text))
		end
	elseif kind == "crisis" then
		self:note("A HARD YEAR: " .. string.upper(Format.escape(entry.title or "")), C.crimsonHi)
	elseif kind == "friend" then
		self:note(Format.color(string.upper(Format.escape(entry.name or "A friend")), C.strange) .. "  " .. Format.escape(entry.text or ""), C.sub)
	elseif kind == "dialogue" then
		self:say("<b>" .. string.upper(Format.escape(entry.who or "")) .. "</b>  <i>" .. Format.escape(entry.text or "") .. "</i>")
	else
		-- log, summary: the words, and what changed
		if entry.text and entry.text ~= "" then
			self:say(Format.escape(entry.text))
		end
		if entry.deltas then
			self.order = Feed.deltaChips(self.chips, entry.deltas, self.info, self.order)
			self.chips.Visible = true
		end
	end
end

-- which entries land on the card before them
Feed.ATTACH = { log = true, clash = true, learned = true, renown = true, gift = true, school = true, rep = true, system = true, world = true, friend = true, dialogue = true, summary = true, feat = true, episodeEnd = true, phase = true }

return Feed
