--[[
	FOCUS (v0.18): when something starts, it's what the next years are about.

	Events used to come one random card after another, so an invitation to the Library could
	be followed by a bakery, a dog and a tax form before anything came of it. Now the card that
	starts a thread becomes the life's FOCUS for a few years:
	  - the cards of that thread (and of the same subject) come far more often, the rest less
	  - a year with one of its follow-ups due brings one fewer unrelated card
	  - this year's cards are put in order: the focus first, then everything else
	  - the event card says so ("Following on · The Library")

	A thread is every event joined to another by `schedule` or `trigger`, in either direction.
	A subject is the codex entry a card teaches, or a whole family of ids named in
	pack.focus.topics (every lib_ card is about the Library). An event can name its own with
	`focus = "some_key"`.

		Focus.build(sim)                     once, from Sim.new
		Focus.saw(sim, life, event)          an event came up (Sim:advance)
		Focus.tick(sim, life)                a new year: a finished focus lets go
		Focus.weight(sim, life, event, w)    Sim:eventWeight
		Focus.count(sim, life, n)            Sim:ageUp, the number of random cards
		Focus.order(sim, life)               Sim:ageUp, after the cards are drawn
		Focus.belongs(sim, life, event)      is this card part of the focus?
		Focus.view(sim, life)                { name, years } for the screen
]]

local Focus = {}

local function cfg(sim: any): any
	return sim.pack.focus or {}
end

-- union-find over event ids
local function find(parent: { [string]: string }, x: string): string
	local root = x
	while parent[root] and parent[root] ~= root do
		root = parent[root]
	end
	-- (flatten the path)
	while parent[x] and parent[x] ~= root do
		local nxt = parent[x]
		parent[x] = root
		x = nxt
	end
	return root
end

local function union(parent: { [string]: string }, a: string, b: string)
	parent[a] = parent[a] or a
	parent[b] = parent[b] or b
	local ra, rb = find(parent, a), find(parent, b)
	if ra ~= rb then
		-- the alphabetically first id is the root, so the key is the same on every server
		if ra < rb then
			parent[rb] = ra
		else
			parent[ra] = rb
		end
	end
end

-- every event id a result leads to (schedule, trigger), however deep it's written
local function followsOf(result: any, out: { string }, depth: number?)
	local d = depth or 0
	if type(result) ~= "table" or d > 4 then
		return
	end
	local s = result.schedule
	if type(s) == "table" then
		if type(s.event) == "string" then
			table.insert(out, s.event)
		else
			for _, one in s do
				if type(one) == "table" and type(one.event) == "string" then
					table.insert(out, one.event)
				end
			end
		end
	end
	if type(result.trigger) == "string" then
		table.insert(out, result.trigger)
	end
	-- outcomes written as lists ({ chance = 0.5, ... }) and the like
	for k, v in result do
		if type(v) == "table" and k ~= "schedule" and k ~= "when" and k ~= "requires" then
			followsOf(v, out, d + 1)
		end
	end
end

function Focus.build(sim: any)
	local parent: { [string]: string } = {}
	local byId = sim.eventsById or {}
	for _, e in sim.pack.events or {} do
		local out = {}
		followsOf(e.result, out)
		for _, c in e.choices or {} do
			if type(c) == "table" then
				followsOf(c.result, out)
				followsOf(c.win, out)
				followsOf(c.lose, out)
			end
		end
		for _, target in out do
			if byId[target] and target ~= e.id then
				union(parent, e.id, target)
			end
		end
	end
	-- a thread is a group of two or more; its key is its root
	local threadOf: { [string]: string } = {}
	local size: { [string]: number } = {}
	for id in parent do
		local root = find(parent, id)
		threadOf[id] = root
		size[root] = (size[root] or 0) + 1
	end
	-- subjects: an explicit `focus`, a family of ids, or the codex entry
	local topics = cfg(sim).topics or {}
	local topicOf: { [string]: string } = {}
	local topicSize: { [string]: number } = {}
	for _, e in sim.pack.events or {} do
		local t = nil
		if type(e.focus) == "string" then
			t = e.focus
		else
			for prefix in topics do
				if string.sub(e.id, 1, #prefix) == prefix then
					t = prefix
					break
				end
			end
			if not t then
				local cx = e.codex
				if type(cx) == "table" then
					cx = cx[1]
				end
				if type(cx) == "string" then
					t = cx
				end
			end
		end
		if t then
			topicOf[e.id] = t
			topicSize[t] = (topicSize[t] or 0) + 1
		end
	end
	sim.focusIndex = { threadOf = threadOf, threadSize = size, topicOf = topicOf, topicSize = topicSize }
end

local function index(sim: any): any
	if not sim.focusIndex then
		Focus.build(sim)
	end
	return sim.focusIndex
end

local function threadKey(sim: any, id: string): string?
	return index(sim).threadOf[id]
end

local function topicKey(sim: any, id: string): string?
	return index(sim).topicOf[id]
end

-- is this card part of focus f?
local function inFocus(sim: any, id: string, f: any): boolean
	if not f then
		return false
	end
	local t = threadKey(sim, id)
	if t and t == f.thread then
		return true
	end
	local s = topicKey(sim, id)
	return s ~= nil and s == f.topic
end

function Focus.belongs(sim: any, life: any, event: any): boolean
	return event ~= nil and inFocus(sim, event.id, life.focus)
end

-- something of the focus is still to come (scheduled for a later year, or waiting this one)
local function stillComing(sim: any, life: any, f: any): boolean
	for _, s in life.scheduled or {} do
		if inFocus(sim, s.event, f) then
			return true
		end
	end
	for _, id in life.queue or {} do
		if inFocus(sim, id, f) then
			return true
		end
	end
	return false
end

local function nameFor(sim: any, life: any, event: any, topic: string?): string
	local names = cfg(sim).names or {}
	if topic and names[topic] then
		return names[topic]
	end
	local title = event.title
	if type(title) == "string" and title ~= "" then
		local ok, out = pcall(function()
			return sim:render(life, title)
		end)
		if ok and type(out) == "string" then
			return out
		end
		return title
	end
	return "What happened"
end

-- an event came up: if it starts or continues a thread, that's what the next years are about
function Focus.saw(sim: any, life: any, event: any)
	-- (a pack without `focus` keeps its cards as they were)
	if not event or not sim.pack.focus or cfg(sim).enabled == false or event.always then
		return
	end
	local ix = index(sim)
	local thread = ix.threadOf[event.id]
	local topic = ix.topicOf[event.id]
	local years = cfg(sim).years or 3
	local f = life.focus
	if f and inFocus(sim, event.id, f) then
		-- more of the same: it holds a while longer
		f.untilAge = math.max(f.untilAge or 0, life.age + years)
		f.seen = (f.seen or 1) + 1
		f.thread = f.thread or thread
		return
	end
	-- only a real thread takes hold: one that leads somewhere, or a subject with several cards
	local minTopic = cfg(sim).minTopic or 4
	local real = (thread ~= nil) or (topic ~= nil and (ix.topicSize[topic] or 0) >= minTopic)
	if not real then
		return
	end
	-- a focus with something still to come isn't pushed aside by a stray card
	if f and life.age <= (f.untilAge or 0) and stillComing(sim, life, f) then
		return
	end
	life.focus = {
		thread = thread,
		topic = topic,
		name = nameFor(sim, life, event, topic),
		since = life.age,
		untilAge = life.age + years,
		seen = 1,
	}
end

-- a new year: a focus that has run its course, with nothing still to come, lets go
function Focus.tick(sim: any, life: any)
	local f = life.focus
	if f and life.age > (f.untilAge or 0) and not stillComing(sim, life, f) then
		life.focus = nil
	end
end

function Focus.weight(sim: any, life: any, event: any, w: number): number
	local f = life.focus
	if not f or w <= 0 then
		return w
	end
	if inFocus(sim, event.id, f) then
		return w * (cfg(sim).boost or 6)
	end
	-- a life's own story, the turning points of the world and what happens with friends who
	-- play with you aren't drowned out
	local wh = event.when
	if event.always or event.story or event.social or (wh and (wh.linked or wh.linkedRough)) then
		return w
	end
	return w * (cfg(sim).others or 0.5)
end

-- a year with a follow-up of the focus due brings one fewer unrelated card
function Focus.count(sim: any, life: any, n: number): number
	local f = life.focus
	if not f or n <= 0 then
		return n
	end
	for _, id in life.queue or {} do
		if inFocus(sim, id, f) then
			return math.max(0, n - 1)
		end
	end
	return n
end

-- this year's cards in order: the focus first (in the order they came), then the rest
function Focus.order(sim: any, life: any)
	local f = life.focus
	if not f or #(life.queue or {}) < 2 then
		return
	end
	local first, rest = {}, {}
	for _, id in life.queue do
		if inFocus(sim, id, f) then
			table.insert(first, id)
		else
			table.insert(rest, id)
		end
	end
	if #first == 0 then
		return
	end
	for _, id in rest do
		table.insert(first, id)
	end
	life.queue = first
end

function Focus.view(sim: any, life: any): any
	local f = life.focus
	if not f then
		return nil
	end
	return { name = f.name, years = math.max(0, (f.untilAge or life.age) - life.age), since = f.since }
end

return Focus
