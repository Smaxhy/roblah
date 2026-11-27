--[[
	The life-sim engine. Pure Luau, no Roblox APIs, so the same code runs on
	the Roblox server and in Lune tests.

	local sim = Sim.new(contentPack)
	local life = sim:newLife({ originId = "ordinary", district = "foundry", seed = 12345 })
	local report = sim:ageUp(life)          -- may leave life.pending set
	report = sim:choose(life, 2)            -- resolve a pending event
	report = sim:doActivity(life, "train")
	report = sim:doActivity(life, "move_district", "kelpmarket")
	report = sim:joinCareer(life, "company")

	A report is { entries = {...}, clash = clashResult?, died = boolean, outbox = {...} }.
	Every entry is also appended to life.log (capped). `outbox` holds effects meant
	for linked friends (other players); the server delivers them.
]]

-- (the engine's helper modules come in untyped: their own files are type checked on their own,
-- and inferring all of them inside this one goes past the checker's limit)
local Rng = require(script.Parent.Rng)
local Util = require(script.Parent.Util)
local Clash = require(script.Parent.Clash)
local Conditions = require(script.Parent.Conditions)
local Effects: any = require(script.Parent.Effects) :: any
local Body: any = require(script.Parent.Body) :: any
local Report: any = require(script.Parent.Report) :: any
local Renown: any = require(script.Parent.Renown) :: any
local Known: any = require(script.Parent.Known) :: any
local Market: any = require(script.Parent.Market) :: any
local Talent: any = require(script.Parent.Talent) :: any
local People: any = require(script.Parent.People) :: any
local Mood: any = require(script.Parent.Mood) :: any
local View: any = require(script.Parent.View) :: any
local Avatar = require(script.Parent.Avatar)
local Expedition: any = require(script.Parent.Expedition) :: any
local Jobs: any = require(script.Parent.Jobs) :: any
local Office: any = require(script.Parent.Office) :: any
local Focus: any = require(script.Parent.Focus) :: any
local Turf: any = require(script.Parent.Turf) :: any
local Cases: any = require(script.Parent.Cases) :: any
local Feats: any = require(script.Parent.Feats) :: any
local Battle: any = require(script.Parent.Battle) :: any

local HunterWorld = require(script.Parent.HunterWorld)

local Sim = {}
Sim.__index = Sim

-- the stats a pack gets when it names none (pack.stats.order)
local DEFAULT_STATS = { "fortitude", "prudence", "temperance", "justice" }
local HIGHLIGHT_LIMIT = 8
local MAX_EVENTS_PER_STEP = 12
local LIFE_VERSION = 2

Sim.LIFE_VERSION = LIFE_VERSION

local NEWS_LIMIT = 12
local STASH_MAX = 30

local function newReport()
	return { entries = {}, clash = nil, died = false, outbox = {} }
end
Sim.newReport = newReport

-- A dice roll that doesn't touch a life's RNG, keyed by a string. Used to give
-- old saves (made before looks existed) a stable look without changing their luck.
-- "a Overseer" reads wrong: pick the article from the first letter.
local function aOrAn(word: string): string
	-- names that bring their own article ("An Unopened Prescript", "The Number Nine Key")
	local lower = string.lower(word)
	if string.sub(lower, 1, 2) == "a " or string.sub(lower, 1, 3) == "an " or string.sub(lower, 1, 4) == "the " then
		return word
	end
	local first = string.sub(lower, 1, 1)
	return (if string.find("aeiou", first, 1, true) and first ~= "" then "an " else "a ") .. word
end

local function hashRoll(key: string)
	local h = 5381
	for i = 1, #key do
		h = (h * 33 + string.byte(key, i)) % 2147483647
	end
	if h == 0 then
		h = 1
	end
	return function(n: number): number
		h = (h * 48271) % 2147483647
		return (h % n) + 1
	end
end

-- (v0.15) THIS LIFE'S CITY: every life is dealt its own share of what can happen, from its
-- seed. A quarter of what could come up never does in this life, an eighth comes rarely, a
-- quarter comes often. Two lives never meet the same City, and one life keeps its own flavour.
local FATE_BUCKETS = { 0, 0, 0.45, 1, 1, 1, 1.9, 1.9 }
local function fateOf(lifeId: string, eventId: string): number
	return FATE_BUCKETS[hashRoll(lifeId .. "|" .. eventId)(#FATE_BUCKETS)]
end

-- start-up indexes (kept out of Sim.new so each stays small enough to type-check)
local function indexEvent(self: any, e: any)
		-- which natures this event is drawn to (Sim:eventWeight): its own `draws`, else the
		-- stats its choices test (a fight is anyone's who is strong or quick)
		local draws: any = {}
		if type(e.draws) == "string" then
			draws[e.draws] = true
		elseif type(e.draws) == "table" then
			for _, s in e.draws do
				draws[s] = true
			end
		else
			for _, c in e.choices or {} do
				if type(c) == "table" and type(c.clash) == "table" and type(c.clash.stat) == "string" then
					draws[c.clash.stat] = true
					if c.clash.fight and self.roles and self.roles.speed then
						draws[self.roles.speed] = true
					end
				end
			end
		end
		self.eventDraws = self.eventDraws or {}
		self.eventDraws[e.id] = draws
		-- who speaks in a storyline's chapters (the Story tab shows them once you've met them)
		if e.story and type(e.dialogue) == "table" then
			self.storySpeakers = self.storySpeakers or {}
			local speakers: any = self.storySpeakers[e.story] or {}
			self.storySpeakers[e.story] = speakers
			for _, d in e.dialogue do
				if type(d) == "table" and type(d.who) == "string" and d.who ~= "you" then
					table.insert(speakers, { event = e.id, who = d.who })
				end
			end
		end
		-- a storyline's beats, in the order they come: by age for a story you're born into,
		-- by years since it began for one that finds you later (when.storyYear)
		if e.story then
			local w = e.when or {}
			local rel = w.storyYear or w.minStoryYear
			local at = rel or w.minAge
			if at then
				self.storyBeatList = self.storyBeatList or {}
				local list: any = self.storyBeatList[e.story] or {}
				self.storyBeatList[e.story] = list
				local found = false
				for _, b in list do
					if b.at == at then
						found = true
						break
					end
				end
				if not found then
					table.insert(list, { at = at, relative = rel ~= nil, title = e.title, id = e.id })
				end
			end
		end
end

-- SCENES WITH SOMEONE: events with `social = { kinds, minBond, maxBond, relMinAge, relMaxAge }`
-- are what "spend time" opens. One is picked for the person you chose; its words can use
-- {rel} (their name) and {relKind}; a `bond` in its results lands on them.
local function indexSocial(self: any, pack: any)
	self.socialScenes = {}
	for _, e in pack.events do
		if type(e.social) == "table" then
			table.insert(self.socialScenes, e)
		end
	end
end

local function indexThreads(self: any, pack: any)
	for _, list in self.storyBeatList or {} do
		table.sort(list, function(a, b)
			return a.at < b.at
		end)
	end
	-- whose grudge an event is, and which events are the brink (Sim:threadOf)
	self.reprisalOf = {}
	for _, fid in (pack.reputation and pack.reputation.order) or {} do
		for _, evId in (pack.reputation[fid] and pack.reputation[fid].reprisal) or {} do
			self.reprisalOf[evId] = fid
		end
	end
	self.brinkIds = {}
	do
		local hook = pack.hooks and pack.hooks.breakingPoint
		for _, id in (if type(hook) == "table" then hook else { hook }) do
			self.brinkIds[id] = true
		end
		for _, id in (pack.hooks and pack.hooks.brinkAlso) or {} do
			self.brinkIds[id] = true
		end
	end
end

function Sim.new(pack)
	local self = setmetatable({}, Sim)
	self.pack = pack
	-- THE STATS (pack.stats): `order` lists them; `vital` is the one that kills at zero;
	-- `roles` says which stat does which job. fight: power in a fight. work: jobs and
	-- promotions. will: holding together. And, if the pack has them: speed (how many coins
	-- you bring to a fight and who strikes first), charm (people and prices), luck (the
	-- coins, bad years, finds). `grow` are the ones a child picks up just by growing.
	local statDefs = pack.stats or {}
	self.coreStats = statDefs.order or DEFAULT_STATS
	self.vital = statDefs.vital or "fortitude"
	local roles = statDefs.roles or {}
	self.roles = {
		fight = roles.fight or "justice",
		work = roles.work or "temperance",
		will = roles.will or "prudence",
		speed = roles.speed,
		charm = roles.charm,
		luck = roles.luck,
	}
	indexThreads(self, pack)
	indexSocial(self, pack)
	-- CAST VARIANTS: a cast member with `names = { ... }` goes by a different one in each life
	-- (their `name` is one of the choices). Wherever an event's words use the first name, the
	-- life's own is put in (Sim:render), so the same story has different people in it.
	self.castAlts = {}
	for id, c in pack.cast or {} do
		if type(c) == "table" and type(c.name) == "string" and type(c.names) == "table" and #c.names > 0 then
			local all = { c.name }
			for _, n in c.names do
				table.insert(all, n)
			end
			local function wordPattern(s: string): string
				return "%f[%w]" .. string.gsub(s, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0") .. "%f[%W]"
			end
			local entry = { id = id, name = c.name, all = all, pattern = wordPattern(c.name), short = nil :: string?, shortPattern = nil :: string?, shortFirst = false }
			-- `short`: what the text calls them for short ("Varga" for "Mr. Varga"): the first
			-- or the last word of the name, and so of every other name they can have
			if type(c.short) == "string" and c.short ~= c.name then
				entry.short = c.short
				entry.shortPattern = wordPattern(c.short)
				entry.shortFirst = string.sub(c.name, 1, #c.short) == c.short
			end
			table.insert(self.castAlts, entry)
		end
	end
	table.sort(self.castAlts, function(a, b)
		return #a.name > #b.name -- "Mr. Varga" before "Varga"
	end)
	self.growStats = statDefs.grow or { "prudence", "temperance", "justice" }
	self.growPicks = statDefs.growPicks or 2 -- how many of them tick up each year of childhood
	self.scaledKeys = table.clone(self.coreStats)
	table.insert(self.scaledKeys, "sanity")
	table.insert(self.scaledKeys, "money")
	self.eventsById = {}
	-- (v0.18) the clashes on event cards (pack.hardness makes them harder; the cards
	-- themselves aren't touched, so the content is the same for every Sim)
	self.cardClash = setmetatable({}, { __mode = "k" }) :: any
	for _, e in pack.events do
		self.eventsById[e.id] = e
		indexEvent(self, e)
		local danger = false
		for _, tag in e.tags or {} do
			if tag == "danger" then
				danger = true
			end
		end
		-- (a life's own story keeps the tuning its chapters were written with)
		for _, c in (if e.story then {} else e.choices) or {} do
			if type(c) == "table" and type(c.clash) == "table" then
				self.cardClash[c.clash] = if danger or e.dread then "danger" else "card"
			end
		end
	end
	-- (v0.18) which events follow from which (Engine/Focus.luau)
	Focus.build(self)
	-- (BitLeveling) weapons out of Gates (result.loot)
	if pack.hunterWorld then
		self.lootHook = HunterWorld.loot
	end
	self.activitiesById = {}
	for _, a in pack.activities do
		self.activitiesById[a.id] = a
	end
	self.originsById = {}
	for _, o in pack.origins do
		self.originsById[o.id] = o
	end
	-- world events the server has switched on (a breach, a festival...)
	self.worldActive = {}
	Conditions.worldActive[pack] = self.worldActive
	-- today's daily event and the server's shared chronicle (both set by the server)
	self.dailyId = nil
	self.dayNumber = 0
	self.chronicle = {}
	Conditions.dailyActive[pack] = nil
	Conditions.chronicle[pack] = self.chronicle
	-- lore entries by id
	self.codexById = {}
	for _, entry in (pack.codex and pack.codex.entries) or {} do
		self.codexById[entry.id] = entry
	end
	-- storylines (pack.storylines): one main story per life; an event with `story = "<id>"`
	-- is a beat of that storyline and only happens in lives that are living it
	self.storylinesById = {}
	for _, sl in pack.storylines or {} do
		self.storylinesById[sl.id] = sl
	end
	self.gateByFlag = {}
	for _, g in pack.storyGates or {} do
		if g.flag and not self.gateByFlag[g.flag] then
			self.gateByFlag[g.flag] = g
		end
	end
	-- story gates (pack.storyGates): the first gate whose prefix matches an event's id
	self.gateOf = {}
	for _, e in pack.events do
		for _, g in pack.storyGates or {} do
			local hit = false
			for _, prefix in g.prefixes or {} do
				if string.sub(e.id, 1, #prefix) == prefix then
					hit = true
					break
				end
			end
			if hit then
				self.gateOf[e.id] = g
				break
			end
		end
	end
	Known.build(self)
	return self
end

function Sim:setWorldEvent(id: string, on: boolean)
	self.worldActive[id] = if on then true else nil
end

-- Today's daily event (the same for everyone): an id from pack.daily, and the day number.
function Sim:setDaily(id: string?, dayNumber: number)
	if id and not (self.pack.daily and self.pack.daily[id]) then
		id = nil
	end
	self.dailyId = id
	self.dayNumber = dayNumber
	Conditions.dailyActive[self.pack] = id
end

-- The server's chronicle: notable things players on this server have done, oldest first.
-- { { act = "id", name = "First Last", district = "id", lifeId = "...", userId = n }, ... }
function Sim:setChronicle(list)
	self.chronicle = list or {}
	Conditions.chronicle[self.pack] = self.chronicle
end

-- The latest chronicle entry for one of these acts by someone other than this life.
function Sim:chronicleMatch(life, acts)
	local list = Util.asList(acts)
	for i = #self.chronicle, 1, -1 do
		local e = self.chronicle[i]
		if e.lifeId ~= life.id and table.find(list, e.act) then
			return e
		end
	end
	return nil
end

-- Sets who {actor} refers to while an event about another player's deed is on screen.
function Sim:setActor(life, event)
	life.actor = nil
	local acts = event and event.when and event.when.chronicle
	if acts then
		local e = self:chronicleMatch(life, acts)
		if e then
			local d = self.pack.districts[e.district or ""]
			life.actor = { name = e.name or "someone", district = if d then d.name else "the City", userId = e.userId }
		end
	end
end

-- ── small helpers ───────────────────────────────────────────────────────────

function Sim:push(life, report, entry)
	entry.age = life.age
	table.insert(life.log, entry)
	local cap = self.pack.meta.maxLogEntries or 400
	while #life.log > cap do
		table.remove(life.log, 1)
	end
	if report then
		table.insert(report.entries, entry)
	end
end

function Sim:highlight(life, text: string)
	table.insert(life.highlights, { age = life.age, text = text })
	while #life.highlights > HIGHLIGHT_LIMIT do
		table.remove(life.highlights, 1)
	end
end

-- News: short third-person lines about this life that linked friends get to hear
-- ("Ossa was promoted to Diver"). The server collects them after every action.
function Sim:news(life, text: string)
	life.newsOut = life.newsOut or {}
	table.insert(life.newsOut, text)
	while #life.newsOut > NEWS_LIMIT do
		table.remove(life.newsOut, 1)
	end
end

function Sim:takeNews(life)
	local list = life.newsOut or {}
	life.newsOut = nil
	return list
end

function Sim:lifeRoll(life)
	return function(n: number): number
		return Rng.int(life, 1, n)
	end
end

-- Everything the avatar needs to draw this character as they are right now.
function Sim:appearance(life)
	if not life.look then
		life.look = Avatar.randomLook(self.pack, hashRoll(tostring(life.id)))
	end
	local gear = {}
	for slot, id in life.gear or {} do
		gear[slot] = id
	end
	local conditions = {}
	for _, c in life.conditions or {} do
		table.insert(conditions, c.id)
	end
	local look = table.clone(life.look)
	if self.pack.schools then
		-- weapons are found, bought or issued in a life: nothing is carried from the creator
		look.weapon = nil
	end
	-- an organisation dresses its people (career.uniform; career.uniformTop from a rank up)
	local cdef = life.career and self.pack.careers[life.career.id]
	if cdef and cdef.uniform and life.alive ~= false then
		local outfit = cdef.uniform
		if cdef.uniformTop and life.career.rank >= (cdef.uniformTop.rank or 99) then
			outfit = cdef.uniformTop.outfit or outfit
		end
		look.outfit = outfit
	end
	return {
		look = look,
		age = life.age,
		form = life.form,
		sanity = life.sanity,
		gear = gear,
		conditions = conditions,
	}
end

function Sim:firstRelation(life, kind: string)
	for _, rel in life.relations do
		if rel.alive and rel.kind == kind then
			return rel
		end
	end
	return nil
end

function Sim:districtDef(life)
	return self.pack.districts[life.district] or {}
end

function Sim:sideDef(life)
	return self.pack.sides[life.side] or {}
end

function Sim:arrivalSide(): string
	local sides = self.pack.sides
	return sides.arrival or sides.order[#sides.order]
end

function Sim:zoneLabel(life): string
	local side = self:sideDef(life)
	local district = self:districtDef(life)
	return (side.name or life.side) .. " of " .. (district.name or life.district)
end

function Sim:careerName(life, careerEntry): string
	local entry = careerEntry or life.career
	if not entry then
		return "no one"
	end
	local def = self.pack.careers[entry.id]
	if def.company then
		local d = self.pack.districts[entry.district or life.district]
		return if d and d.corp then d.corp else def.name
	end
	-- a Finger's regional branch ("the Thumb East"); an Association's region is in the rank
	if def.regional == "branch" and entry == life.career then
		local dir = self:directionOf(life)
		if dir then
			return def.name .. " " .. dir
		end
	end
	return def.name
end

function Sim:rankName(life): string
	if not life.career then
		return ""
	end
	local def = self.pack.careers[life.career.id]
	local rank = def.ranks[life.career.rank] or ""
	-- an Association's Sections belong to the branch of the region you work in ("South Section 4")
	if def.regional == "section" then
		local dir = self:directionOf(life)
		if dir then
			rank = (string.gsub(rank, "^Section", dir .. " Section"))
		end
	end
	return rank
end

-- the compass region of the District this life works in (pack.directions: District number ->
-- North / South / East / West). The career's own District when it has one.
function Sim:directionOf(life): string?
	local fn = self.pack.directions
	if type(fn) ~= "function" then
		return nil
	end
	local d = self.pack.districts[(life.career and life.career.district) or life.district]
	local n = d and tonumber(d.number)
	return if n then fn(n) else nil
end

-- pay multiplier for wages in this Ward and side
function Sim:wageMult(life): number
	-- a District players have made prosperous pays better (the City's hold)
	local hold = Renown.holdOf(self, life.district)
	local boom = if hold and hold.prosperity then math.clamp(1 + 0.06 * hold.prosperity, 0.7, 1.3) else 1
	return (self:districtDef(life).wealth or 1) * (self:sideDef(life).payMult or 1) * boom
end

function Sim:salaryFor(life, id: string, rank: number): number
	local def = self.pack.careers[id]
	local base = def.salary[rank] or 0
	local d = self:districtDef(life)
	local mult = self:wageMult(life) * ((d.careerPay and d.careerPay[id]) or 1) * (1 + self:perkSum(life, "wage"))
	-- (BitLeveling) a Hunter's pay follows their rank: careers with `hunter = true` pay
	-- what the form says (pack.forms[form].wage)
	if def.hunter then
		local form = self.pack.forms[life.form or ""]
		mult *= (form and form.wage) or 1
	end
	return math.floor(base * mult + 0.5)
end

function Sim:salaryOf(life): number
	if not life.career then
		return 0
	end
	return self:salaryFor(life, life.career.id, life.career.rank)
end

function Sim:livingCost(life): number
	return math.floor((self:districtDef(life).cost or 0) * (self:sideDef(life).costMult or 1) + 0.5)
end

-- the linked friend (another player) this event is about
function Sim:focusLinked(life, needRough: boolean?)
	local function ok(rel)
		return rel.alive and rel.userId ~= nil and rel.online == true and (not needRough or rel.rough == true)
	end
	if life.focusLink then
		for _, rel in life.relations do
			if rel.id == life.focusLink and ok(rel) then
				return rel
			end
		end
	end
	for _, rel in life.relations do
		if ok(rel) then
			return rel
		end
	end
	return nil
end

-- VARIANTS: a line may be written several ways ({ "one way", "another" }). Each life is dealt
-- one of them, and always the same one, so a card reads the same if it's shown twice. It's a
-- large part of why two lives through the same event don't read alike.
function Sim:variant(life, list): string
	local n = #list
	if n == 0 then
		return ""
	elseif n == 1 then
		return list[1]
	end
	local first = list[1]
	local key = tostring(life.id) .. ":" .. (if type(first) == "string" then string.sub(first, 1, 32) else tostring(n))
	return list[hashRoll(key)(n)]
end

function Sim:render(life, text: any, extra): string
	if type(text) == "table" then
		text = self:variant(life, text)
	end
	local pack = self.pack
	local district = self:districtDef(life)
	local side = self:sideDef(life)
	local linked = self:focusLinked(life)
	local ctx = {
		name = life.first .. " " .. life.last,
		first = life.first,
		last = life.last,
		age = life.age,
		year = life.year,
		zone = self:zoneLabel(life),
		district = district.name or life.district,
		wardNumber = district.number or "?",
		side = side.name or life.side,
		corp = district.corp or "the old company",
		career = self:careerName(life),
		rank = self:rankName(life),
		currency = pack.meta.currency,
		linked = if linked then linked.first else "your friend",
		sender = "a friend",
		actor = if life.actor then life.actor.name else "someone",
		office = if life.household and life.household.office then life.household.office else "the family's",
		actorDistrict = if life.actor then life.actor.district else "the City",
		style = self:styleName(life),
	}
	for kind in pack.relationKinds do
		local rel = self:firstRelation(life, kind)
		ctx[kind] = if rel then rel.first else "someone"
	end
	-- a scene with someone (Sim:interact): their name is in the words
	if life.sceneRel then
		local rel = self:relationById(life, life.sceneRel)
		if rel then
			local kindDef = pack.relationKinds[rel.kind] or {}
			ctx.rel = rel.first
			ctx.relName = rel.first .. (if rel.last ~= "" then " " .. rel.last else "")
			ctx.relKind = string.lower(if rel.userId then "friend" else (kindDef.name or rel.kind))
		end
	end
	-- (BitLeveling) a card about a Gate incident fills its {g...} tokens from the incident
	if life.gw and life.gw.tokens then
		for k, v in life.gw.tokens do
			ctx[k] = v
		end
	end
	if extra then
		for k, v in extra do
			ctx[k] = v
		end
	end
	-- the cast go by this life's names for them (done on the written text, before {tokens}
	-- are filled in, so nobody's sister gets renamed by accident)
	if type(text) == "string" then
		for _, c in self.castAlts do
			local hasFull = string.find(text, c.name, 1, true) ~= nil
			local hasShort = c.short ~= nil and string.find(text, c.short, 1, true) ~= nil
			if hasFull or hasShort then
				local pick = self:variant(life, c.all)
				if pick ~= c.name then
					if hasFull then
						text = string.gsub(text, c.pattern, (string.gsub(pick, "%%", "%%%%")))
					end
					if c.short and c.shortPattern then
						local word = if c.shortFirst then string.match(pick, "^(%S+)") else string.match(pick, "(%S+)$")
						if word then
							text = string.gsub(text, c.shortPattern, (string.gsub(word, "%%", "%%%%")))
						end
					end
				end
			end
		end
	end
	return Util.render(text, ctx)
end

-- what a cast member is called in this life
function Sim:castName(life, cast): string
	if type(cast.names) == "table" and #cast.names > 0 then
		local all = { cast.name }
		for _, n in cast.names do
			table.insert(all, n)
		end
		return self:variant(life, all)
	end
	return cast.name
end

function Sim:randomName(life)
	return Rng.pick(life, self.pack.names.first), Rng.pick(life, self.pack.names.last)
end

-- ── state changes (used by Effects) ─────────────────────────────────────────

-- a change to Sanity as it lands on this life: a strong mind loses less (tier perks with
-- `sanityGuard`). Used by changeSanity and by the chips that promise it (Effects.preview).
function Sim:sanityDelta(life, delta: number, guardNow: number?): number
	if delta < 0 then
		local guard = guardNow or self:perkSum(life, "sanityGuard")
		if guard > 0 then
			delta = -math.max(1, math.floor(-delta * (1 - math.min(0.6, guard)) + 0.5))
		end
	end
	return delta
end

function Sim:changeSanity(life, delta: number, deltas, exact: boolean?)
	if delta == 0 then
		return
	end
	local cfg = self.pack.stats.sanity
	local before = life.sanity
	-- (exact: the guard was already applied, by a caller that knew it better)
	if not exact then
		delta = self:sanityDelta(life, delta)
	end
	life.sanity = Util.clamp(before + delta, cfg.min, cfg.max)
	local real = life.sanity - before
	if real ~= 0 and deltas then
		deltas.sanity = (deltas.sanity or 0) + real
	end
	if life.sanity <= cfg.min and life.alive then
		-- pack.hooks.breakingPoint: one event id, or a list; the first whose `when` fits this
		-- life is the one that happens (what a mind does at the bottom depends on the age)
		local hook = self.pack.hooks and self.pack.hooks.breakingPoint
		for _, id in (if type(hook) == "table" then hook else { hook }) do
			local ev = self.eventsById[id]
			if ev and Conditions.check(ev.when, life, self.pack, { noChance = true }) then
				if life.pending ~= id and not Util.contains(life.queue, id) then
					table.insert(life.queue, 1, id)
				end
				break
			end
		end
	end
end

-- the Fixers board: a career's ranks map to a Fixer grade (pack.rankings.fixer.careers,
-- 9 = Grade 1); the best one reached in a life is kept
function Sim:trackRanking(life)
	local r = self.pack.rankings and self.pack.rankings.fixer
	local scale = r and life.career and r.careers and r.careers[life.career.id]
	if scale then
		life.fixerPeak = math.max(life.fixerPeak or 0, scale[life.career.rank] or 0)
	end
end

-- 0 = never a Fixer, 1..9 = Grade 9..Grade 1, 10 = a Color
function Sim:fixerRating(life): number
	local r = self.pack.rankings and self.pack.rankings.fixer
	if r and r.colorFlag and life.flags[r.colorFlag] then
		return 10
	end
	return life.fixerPeak or 0
end

function Sim:setCareer(life, id: string, extra)
	local def = self.pack.careers[id]
	if not def then
		return
	end
	if life.career and life.career.id == id then
		return
	end
	if def.company and not self:districtDef(life).corp then
		return
	end
	if life.career then
		self:quitCareer(life, extra)
	end
	life.career = { id = id, rank = 1, years = 0, rankYears = 0, district = if def.company then life.district else nil }
	-- they took you on: you start in good standing (at least +20), whatever came before
	local faction = self:careerFaction(id)
	if faction then
		local have = self:repOf(life, faction)
		if have < 20 then
			self:addRep(life, faction, 20 - math.max(have, -100), extra)
		end
	end
	-- working for a faction is one way to learn of it
	for _, g in self.pack.storyGates or {} do
		if g.flag and g.careers and table.find(g.careers, id) and not life.flags[g.flag] then
			life.flags[g.flag] = true
			if g.name and extra then
				table.insert(extra, { kind = "learned", title = g.name, text = g.blurb or "", emblem = g.emblem, flag = g.flag })
			end
		end
	end
	life.peakRank = math.max(life.peakRank or 0, 1)
	self:trackRanking(life)
	-- an organisation arms its own (career.issue): handed over if your hands are empty
	local issued = def.issue and self.pack.gear and self.pack.gear[def.issue]
	if issued and not (life.gear and life.gear[issued.slot]) then
		local lines = extra or {}
		if self:giveGear(life, def.issue, lines) and extra then
			table.insert(extra, { kind = "log", text = "Issued on your first day: " .. issued.name .. ". " .. (issued.effect or "") })
		end
	end
	if def.rankFlags and def.rankFlags[1] then
		life.flags[def.rankFlags[1]] = true
	end
	local text = "You joined " .. self:careerName(life) .. " as " .. aOrAn(def.ranks[1]) .. "."
	table.insert(extra, { kind = "system", text = text })
	self:highlight(life, text)
	-- an organisation trains its people its own way (pack.schools)
	if self.pack.schools then
		local sid = def.teaches
		if not sid and def.teachesRoll then
			-- a small Office fights however its Rep fights; if you already have a discipline one
			-- of them trains, you keep it
			if life.school and table.find(def.teachesRoll, life.school) then
				sid = life.school
			else
				sid = Rng.pick(life, def.teachesRoll)
			end
		end
		if sid then
			self:teach(life, sid, extra)
		end
	end
	self:news(life, life.first .. " started work at " .. self:careerName(life) .. " as " .. aOrAn(def.ranks[1]) .. ".")
end

function Sim:promote(life, extra)
	if not life.career then
		return
	end
	local def = self.pack.careers[life.career.id]
	if life.career.rank >= #def.ranks then
		return
	end
	life.career.rank += 1
	local faction = self:careerFaction(life.career.id)
	if faction then
		self:addRep(life, faction, 6, extra)
	end
	life.career.rankYears = 0
	life.peakRank = math.max(life.peakRank or 0, life.career.rank)
	self:trackRanking(life)
	local text = "Promoted to " .. def.ranks[life.career.rank] .. " at " .. self:careerName(life) .. "."
	table.insert(extra, { kind = "system", text = text, tone = "good" })
	self:highlight(life, text)
	self:news(life, life.first .. " was promoted to " .. def.ranks[life.career.rank] .. " at " .. self:careerName(life) .. ".")
	-- some ranks leave a mark for good (a record, a story): rankFlags = { [rank] = "flag" }
	local flag = def.rankFlags and def.rankFlags[life.career.rank]
	if flag then
		life.flags[flag] = true
	end
end

function Sim:quitCareer(life, extra, why: string?)
	if not life.career then
		return
	end
	local name = self:careerName(life)
	life.career = nil
	table.insert(extra, { kind = "system", text = why or ("You left " .. name .. ".") })
end

function Sim:formBlocksSide(life, sideId: string): boolean
	local form = self.pack.forms[life.form]
	return form ~= nil and form.blockedSides ~= nil and Util.contains(form.blockedSides, sideId)
end

-- keeps a career valid after moving
function Sim:checkCareerHome(life, extra)
	if not life.career then
		return
	end
	local def = self.pack.careers[life.career.id]
	if def.sides and not Util.contains(def.sides, life.side) then
		self:quitCareer(life, extra, "You couldn't keep working for " .. self:careerName(life) .. " from " .. self:sideDef(life).name .. ".")
	elseif def.company and life.career.district ~= life.district then
		self:quitCareer(life, extra, "You left " .. self:careerName(life) .. " behind when you changed " .. (self.pack.meta.districtWord or "Ward") .. "s.")
	end
end

function Sim:moveSide(life, sideId: string, extra): boolean
	local side = self.pack.sides[sideId]
	if not side or life.side == sideId then
		return false
	end
	if self:formBlocksSide(life, sideId) then
		table.insert(extra, { kind = "system", text = "The gates of " .. side.name .. " stayed shut to you." })
		return false
	end
	life.side = sideId
	life.moves = (life.moves or 0) + 1
	life.debtYears = 0
	self:checkCareerHome(life, extra)
	self:news(life, life.first .. " moved to " .. self:zoneLabel(life) .. ".")
	return true
end

function Sim:moveDistrict(life, districtId: string, extra): boolean
	local d = self.pack.districts[districtId]
	if not d or life.district == districtId then
		return false
	end
	life.district = districtId
	life.side = self:arrivalSide()
	life.moves = (life.moves or 0) + 1
	Known.learnPlace(self, life)
	self:checkCareerHome(life, extra)
	self:news(life, life.first .. " moved to " .. self:zoneLabel(life) .. ".")
	return true
end

function Sim:setForm(life, formId: string, extra)
	local pack = self.pack
	local form = pack.forms[formId]
	if not form or life.form == formId then
		return
	end
	life.form = formId
	life.formAt = life.age -- (v0.17) when it happened: a Bloodfiend's blood counts its years from here
	if not form.terminal then
		local text = "You are " .. form.name .. " now."
		table.insert(extra, { kind = "system", text = text, tone = "strange" })
		self:highlight(life, text)
		self:news(life, life.first .. " is " .. form.name .. " now.")
	end
	if form.blockedSides and Util.contains(form.blockedSides, life.side) then
		for _, s in pack.sides.order do
			if not Util.contains(form.blockedSides, s) then
				life.side = s
				table.insert(extra, { kind = "system", text = "You were turned out through the gates, into " .. pack.sides[s].name .. "." })
				self:checkCareerHome(life, extra)
				break
			end
		end
	end
end


function Sim:addRelation(life, spec)
	local pack = self.pack
	local kindDef = pack.relationKinds[spec.kind] or {}
	local first, last
	if spec.name then
		first, last = string.match(spec.name, "^(%S+)%s+(.+)$")
		if not first then
			first, last = spec.name, ""
		end
	else
		first, last = self:randomName(life)
		if kindDef.family then
			last = life.last
		end
	end
	local age
	if spec.age then
		age = Rng.roll(life, spec.age)
	elseif spec.kind == "child" then
		age = 0
	elseif spec.kind == "mentor" then
		age = life.age + Rng.int(life, 12, 30)
	else
		age = math.max(0, life.age + Rng.int(life, -3, 3))
	end
	local rel = {
		id = life.nextRelId,
		kind = spec.kind,
		first = first,
		last = last,
		age = age,
		bond = Util.clamp(spec.bond or 50, 0, 100),
		alive = true,
		-- blood family takes after you; everyone else (adopted children too) is their own
		look = Avatar.randomLook(pack, self:lifeRoll(life), if kindDef.family and not kindDef.heir then life.look else nil),
	}
	life.nextRelId += 1
	table.insert(life.relations, rel)
	if kindDef.heir then
		self:highlight(life, first .. " became part of your family.")
		self:news(life, life.first .. " took in a child, " .. first .. ".")
	end
	return rel
end

-- Linked friends are other players. The server keeps their details fresh.
function Sim:linkFriend(life, spec)
	-- one friend, one entry: a life saved by an older build can hold the same linked friend
	-- twice (they then show twice everywhere). Keep the first, with the closer bond.
	local keep = nil
	for i = #life.relations, 1, -1 do
		local rel = life.relations[i]
		if rel.userId ~= nil and tostring(rel.userId) == tostring(spec.userId) then
			if keep then
				rel.bond = math.max(rel.bond or 0, keep.bond or 0)
				for j = #life.relations, 1, -1 do
					if life.relations[j] == keep then
						table.remove(life.relations, j)
						break
					end
				end
			end
			keep = rel
			rel.userId = spec.userId
		end
	end
	for _, rel in life.relations do
		if rel.userId == spec.userId then
			rel.first = spec.first or rel.first
			rel.last = spec.last or rel.last
			rel.age = spec.age or rel.age
			rel.alive = true
			rel.online = spec.online ~= false
			rel.rough = spec.rough == true
			rel.player = spec.player or rel.player
			rel.appearance = spec.appearance or rel.appearance
			rel.sheet = spec.sheet or rel.sheet
			return rel, false
		end
	end
	local rel = {
		id = life.nextRelId,
		kind = "friend",
		first = spec.first or "Friend",
		last = spec.last or "",
		age = spec.age or life.age,
		bond = 60,
		alive = true,
		userId = spec.userId,
		player = spec.player,
		online = spec.online ~= false,
		rough = spec.rough == true,
		appearance = spec.appearance,
		sheet = spec.sheet,
	}
	life.nextRelId += 1
	table.insert(life.relations, rel)
	life.flags.had_linked = true
	return rel, true
end

function Sim:unlinkFriend(life, userId: number)
	for _, rel in life.relations do
		if rel.userId == userId then
			rel.userId = nil
			rel.online = nil
			rel.rough = nil
			rel.player = nil
		end
	end
end

local function kindMatches(pack, kindFilter: string, rel)
	if kindFilter == "all" then
		return true
	elseif kindFilter == "family" then
		local def = pack.relationKinds[rel.kind]
		return def ~= nil and def.family == true
	end
	return rel.kind == kindFilter
end

function Sim:bond(life, kind: string, amount: number)
	for _, rel in life.relations do
		if rel.alive and kindMatches(self.pack, kind, rel) then
			rel.bond = Util.clamp(rel.bond + amount, 0, 100)
			if kind ~= "all" and kind ~= "family" then
				return
			end
		end
	end
end



-- killRelation: a kind ("mother"), or { kind = "mother", fate = "book" } for someone who didn't
-- die so much as stop being anywhere (pack.relationFates words it)
function Sim:relationDied(life, rel, extra, how: string?, fate: string?)
	rel.alive = false
	local fdef = fate and self.pack.relationFates and self.pack.relationFates[fate]
	if fdef then
		rel.fate = fdef.short
		if not how then
			local kd = self.pack.relationKinds[rel.kind] or {}
			how = Util.render(fdef.line, { label = string.lower(kd.name or rel.kind), first = rel.first, age = rel.age })
		end
	end
	local kindDef = self.pack.relationKinds[rel.kind] or {}
	local label = string.lower(kindDef.name or rel.kind)
	table.insert(extra, {
		kind = "system",
		tone = "bad",
		text = how or ("Your " .. label .. " " .. rel.first .. " died at " .. rel.age .. "."),
	})
	local grief = if kindDef.family then Rng.int(life, 4, 9) else Rng.int(life, 2, 4)
	self:changeSanity(life, -grief, {})
	if kindDef.family and self.pack.conditions and self.pack.conditions.grief then
		self:addCondition(life, "grief", extra)
	end
end

function Sim:killRelation(life, spec: any, extra)
	local kind = if type(spec) == "table" then spec.kind else spec
	local fate = if type(spec) == "table" then spec.fate else nil
	for _, rel in life.relations do
		-- linked friends are real players; their deaths are their own
		if rel.alive and rel.kind == kind and rel.userId == nil then
			self:relationDied(life, rel, extra, nil, fate)
			return
		end
	end
end

function Sim:kill(life, report, cause: string)
	if not life.alive then
		return
	end
	life.alive = false
	life.cause = cause
	life.death = self:deathReport(life, cause)
	life.pending = nil
	life.queue = {}
	life.focusLink = nil
	self:push(life, report, { kind = "death", text = cause })
	if report then
		report.died = true
	end
end

-- ── REPUTATION (pack.reputation) ────────────────────────────────────────────
-- How each faction regards this life: -100..100, and 0 for a stranger. Results move it
-- (rep = { thumb = -30 }); so does beating one of theirs in a fight (foe.faction), and joining
-- or rising in one of their careers (reputation[id].careers). Bad standing brings reprisals:
-- each year a faction that holds a grudge may send one of its `reprisal` events.

local STANDINGS = {
	{ upTo = -60, name = "Marked" },
	{ upTo = -30, name = "Blood debt" },
	{ upTo = -10, name = "Disliked" },
	{ upTo = 9, name = "A stranger" },
	{ upTo = 29, name = "Known" },
	{ upTo = 59, name = "Trusted" },
	{ upTo = 100, name = "One of theirs" },
}

function Sim:standing(n: number): string
	for _, s in (self.pack.reputation and self.pack.reputation.standings) or STANDINGS do
		if n <= s.upTo then
			return s.name
		end
	end
	return "Known"
end

function Sim:repOf(life, id: string): number
	return (life.rep and life.rep[id]) or 0
end

function Sim:addRep(life, id: string, delta: number, extra)
	local def = self.pack.reputation and self.pack.reputation[id]
	if type(def) ~= "table" or delta == 0 then
		return
	end
	if def.nobody then
		-- (v0.18) a crowd nobody keeps score for (the Rats): you know of them now, and that's all
		if def.flag and not life.flags[def.flag] then
			local learned = self:learnEntry(life, def.flag)
			if learned and extra then
				table.insert(extra, learned)
			end
		end
		return
	end
	life.rep = life.rep or {}
	local before = life.rep[id] or 0
	local now = math.clamp(before + delta, -100, 100)
	if now == before then
		return
	end
	life.rep[id] = now
	if def.flag and not life.flags[def.flag] then
		-- you know of them now, one way or the other
		local learned = self:learnEntry(life, def.flag)
		if learned and extra then
			table.insert(extra, learned)
		end
	end
	if extra then
		local real = now - before
		table.insert(extra, {
			kind = "rep",
			faction = id,
			title = def.name,
			delta = real,
			value = now,
			standing = self:standing(now),
			color = def.color,
			text = string.format("%s: %s%d. Standing %d (%s).", def.name, if real > 0 then "+" else "", real, now, self:standing(now)),
		})
	end
end

-- the faction a career belongs to (pack.reputation[id].careers)
function Sim:careerFaction(careerId: string): string?
	local repPack = self.pack.reputation
	for _, id in (repPack and repPack.order) or {} do
		if Util.contains(repPack[id].careers or {}, careerId) then
			return id
		end
	end
	return nil
end

-- once a year: does anyone with a grudge come to collect?
function Sim:rollReprisal(life, report)
	local repPack = self.pack.reputation
	if not repPack or not life.alive or not life.rep then
		return
	end
	local visited = false
	for _, id in repPack.order do
		local def = repPack[id]
		if def.nobody then
			life.rep[id] = nil -- (an old save's score with a crowd nobody counts)
			continue
		end
		local n = life.rep[id] or 0
		if not visited and n <= (def.grudge or -20) and def.reprisal and life.age >= (def.minAge or 14) then
			-- the worse the standing, the surer the visit: 15% a year at -20, 45% at -60, 75% at -100
			local chance = math.min(0.75, (-n) * 0.0075) * (1 - Market.homeHideout(self, life))
			if Rng.chance(life, chance) then
				local pool = {}
				for _, evId in def.reprisal do
					local ev = self.eventsById[evId]
					local last = life.history[evId]
					local fresh = last == nil or (not (ev and ev.once) and life.age - last >= ((ev and ev.cooldown) or 3))
					if ev and fresh and Conditions.check(ev.when, life, self.pack, { noChance = true }) and life.pending ~= evId and not Util.contains(life.queue, evId) then
						table.insert(pool, evId)
					end
				end
				if #pool > 0 then
					local evId = Rng.pick(life, pool)
					table.insert(life.queue, evId)
					self:setWhy(life, evId, string.format("%s hasn't forgotten. Your standing with them is %d (%s).", def.name, n, self:standing(n)))
					visited = true -- one faction's visit a year is plenty
				end
			end
		elseif n ~= 0 and math.abs(n) < 30 and Rng.chance(life, 0.5) then
			-- small grudges and small favors fade; a blood debt doesn't
			life.rep[id] = n + (if n > 0 then -1 else 1)
		end
	end
end

function Sim:repView(life)
	local repPack = self.pack.reputation
	if not repPack then
		return nil
	end
	local out = {}
	for _, id in repPack.order do
		local def = repPack[id]
		local n = self:repOf(life, id)
		if def.nobody then
			continue -- (no standing to show with a crowd nobody counts)
		end
		if n ~= 0 or (def.flag and life.flags[def.flag]) then
			-- `known`: "Who you know of" shows this standing on its own entry
			local gate = def.flag and self.gateByFlag[def.flag]
			local known = gate ~= nil and gate.name ~= nil and life.flags[def.flag] == true and self.repOfFlag[def.flag] == id
			table.insert(out, { id = id, name = def.name, value = n, standing = self:standing(n), color = def.color, emblem = def.emblem, known = known or nil, note = if n <= (def.grudge or -20) then def.grudgeNote else if n >= 30 then def.favorNote else nil })
		end
	end
	return out
end

-- ── DIFFICULTY (pack.difficulties) ──────────────────────────────────────────
-- Picked before a life starts: { name, desc, lethality, foeBase, hazard, score }.

function Sim:difficultyDef(life)
	local d = self.pack.difficulties
	if not d then
		return nil
	end
	return d[life.difficulty or ""] or d[d.default or ""]
end

-- ── WHY (the line under an event that says where it came from) ─────────────

function Sim:setWhy(life, eventId: string, text: string)
	life.why = life.why or {}
	life.why[eventId] = text
end

function Sim:whyOf(life, event): string?
	local given = life.why and life.why[event.id]
	if given then
		return given
	end
	local pack = self.pack
	if event.story and self.storylinesById[event.story] then
		return "Part of your story: " .. self.storylinesById[event.story].name .. "."
	end
	if self.dailyId == event.id then
		return "Today's City event. Everyone on the server can meet it today."
	end
	local when = event.when or {}
	local career = when.career
	if career and life.career and Util.contains(Util.asList(career), life.career.id) then
		local def = pack.careers[life.career.id]
		return "Comes with your job: " .. tostring(def and def.name or life.career.id) .. "."
	end
	if when.form and life.form ~= "human" and pack.forms[life.form] then
		return "Because of what you are: " .. pack.forms[life.form].name .. "."
	end
	if when.district then
		return "Only happens in " .. self:districtDef(life).name .. "."
	end
	local era = when.world and when.world.era
	if era then
		local var = pack.world[1]
		local label = var and var.labels and var.labels[life.world.era]
		if label then
			return "Because of the age you live in: " .. label .. "."
		end
	end
	if when.flags then
		return "Because of something you did, or saw, earlier in this life."
	end
	if when.hasRelation then
		return "Because of the people in your life."
	end
	for _, tag in event.tags or {} do
		if tag == "danger" or tag == "night" or tag == "crime" then
			return "The City's ordinary danger. It happens more in rough Districts and in the " .. self:sideDef(life).name .. "."
		end
	end
	return nil
end

-- CUTSCENES: an event (`cutscene = { style, kicker, title, lines }`) or a result can carry a
-- full-screen moment. It goes out as a log entry of its own kind; the client plays it
-- (UI/Cutscene) and the feed leaves it out.
function Sim:cutsceneEntry(life: any, spec: any): any
	local lines = {}
	for _, l in spec.lines or {} do
		table.insert(lines, self:render(life, l))
	end
	return {
		kind = "cutscene",
		style = spec.style,
		kicker = if spec.kicker then self:render(life, spec.kicker) else nil,
		title = if spec.title then self:render(life, spec.title) else nil,
		lines = lines,
		color = spec.color,
	}
end

-- THREADS: every card belongs to one part of your life, and says so in its band.
--   story, brink, grudge, work, self (what you are), district, age, people, past, danger, city, life
function Sim:threadOf(life: any, event: any): any
	local pack: any = self.pack
	if event.thread then
		return { kind = event.thread }
	end
	if event.story and self.storylinesById[event.story] then
		return { kind = "story", label = self.storylinesById[event.story].name }
	end
	-- (v0.18) part of what this life is about right now
	if life.focus and Focus.belongs(self, life, event) then
		return { kind = "focus", label = life.focus.name }
	end
	if event.social then
		local rel = life.sceneRel and self:relationById(life, life.sceneRel)
		return { kind = "people", label = if rel then rel.first else nil }
	end
	if self.brinkIds[event.id] then
		return { kind = "brink" }
	end
	local faction = self.reprisalOf[event.id]
	if faction then
		return { kind = "grudge", label = pack.reputation[faction].name }
	end
	if self.dailyId == event.id then
		return { kind = "city" }
	end
	local when = event.when or {}
	if when.career and life.career and Util.contains(Util.asList(when.career), life.career.id) then
		return { kind = "work", label = self:careerName(life) }
	end
	if when.form and life.form ~= "human" and pack.forms[life.form] then
		return { kind = "self", label = pack.forms[life.form].name }
	end
	if when.district then
		return { kind = "district", label = self:districtDef(life).name }
	end
	if when.world and when.world.era then
		return { kind = "age" }
	end
	if when.hasRelation or when.linked or when.linkedRough then
		return { kind = "people" }
	end
	if when.flags then
		return { kind = "past" }
	end
	for _, tag in event.tags or {} do
		if tag == "danger" or tag == "night" or tag == "crime" then
			return { kind = "danger" }
		end
	end
	return { kind = "life" }
end

-- ── THE DEATH REPORT: what killed you, and what would have helped ───────────


-- Applies an effect sent by a linked friend (another player).
-- Something a linked friend did lands in this life. info = { userId, title, choice }: who
-- they are here (so a bond lands on them), the scene it happened in and what they chose.
function Sim:applyLinked(life, result, senderFirst: string, info: any?)
	local report = newReport()
	if life.alive and result then
		local rel = nil
		if info and info.userId then
			for _, r in life.relations do
				if r.userId == info.userId and r.alive then
					rel = r
					break
				end
			end
		end
		-- the feed says what it was: their scene, and what they did in it
		if info and (info.title or info.choice) then
			local title = info.title or info.choice
			self:push(life, report, {
				kind = "event",
				title = title,
				choice = if info.choice and info.choice ~= title then senderFirst .. ": " .. info.choice else senderFirst,
				thread = "people",
			})
		end
		Effects.apply(self, life, result, report, { sender = senderFirst, target = rel, mirrored = true })
		self:advance(life, report)
	end
	return report
end


-- ── gear ────────────────────────────────────────────────────────────────────
-- life.gear is { [slot] = gearId }. One item per slot.

function Sim:gearIn(life)
	local list = {}
	local gearPack = self.pack.gear
	if not gearPack then
		return list
	end
	for _, slot in gearPack.slots or {} do
		local id = life.gear and life.gear[slot]
		local def = id and gearPack[id]
		if def then
			table.insert(list, { slot = slot, id = id, def = def })
		end
	end
	return list
end

function Sim:giveGear(life, id: string, extra)
	local def = self.pack.gear and self.pack.gear[id]
	if not def then
		return false
	end
	life.gear = life.gear or {}
	local old = life.gear[def.slot]
	if old == id then
		return false
	end
	life.gear[def.slot] = id
	-- (v0.13) what it replaces goes in your stash, not the bin (Sim:equipGear swaps back)
	life.stash = life.stash or {}
	local at = table.find(life.stash, id)
	if at then
		table.remove(life.stash, at)
	end
	if old and self.pack.gear[old] and #life.stash < STASH_MAX and not table.find(life.stash, old) then
		table.insert(life.stash, old)
		table.insert(extra, { kind = "system", tone = "good", text = "You now carry " .. aOrAn(def.name) .. ". Your " .. self.pack.gear[old].name .. " goes in your stash." })
	elseif old and self.pack.gear[old] then
		table.insert(extra, { kind = "system", text = "You traded in your " .. self.pack.gear[old].name .. " for " .. aOrAn(def.name) .. "." })
	else
		table.insert(extra, { kind = "system", tone = "good", text = "You now carry " .. aOrAn(def.name) .. "." })
	end
	return true
end

function Sim:loseGear(life, which, extra)
	if not life.gear then
		return
	end
	local slot = nil
	if which == true or which == "any" then
		local owned = self:gearIn(life)
		if #owned > 0 then
			slot = Rng.pick(life, owned).slot
		end
	elseif self.pack.gear and self.pack.gear[which] then
		local def = self.pack.gear[which]
		if life.gear[def.slot] == which then
			slot = def.slot
		else
			-- (v0.13) or out of the stash
			local at = life.stash and table.find(life.stash, which)
			if at then
				table.remove(life.stash, at)
				table.insert(extra, { kind = "system", tone = "bad", text = "You no longer have your " .. def.name .. "." })
				return
			end
		end
	else
		slot = which
	end
	local id = slot and life.gear[slot]
	if id then
		life.gear[slot] = nil
		local def = self.pack.gear[id]
		table.insert(extra, { kind = "system", tone = "bad", text = "You lost your " .. (if def then def.name else id) .. "." })
	end
end

function Sim:buyGear(life, id: string)
	local def = self.pack.gear and self.pack.gear[id]
	if not def then
		return nil, "Unknown item."
	end
	if not life.alive then
		return nil, "This life is over."
	end
	if life.pending then
		return nil, "Decide first."
	end
	if (life.gear and life.gear[def.slot] == id) or (life.stash and table.find(life.stash, id)) then
		return nil, "You already have one."
	end
	if def.unique then
		return nil, "That isn't for sale."
	end
	if def.minAge and life.age < def.minAge then
		return nil, "Age " .. def.minAge .. "+"
	end
	local ok, why = Conditions.check(def.requires, life, self.pack, { noChance = true })
	if not ok then
		return nil, why
	end
	local price = self:priceFor(life, def.price or 0)
	if life.money < price then
		return nil, "Needs " .. price .. " " .. self.pack.meta.currency
	end
	local report = newReport()
	life.money -= price
	local extra = {}
	self:giveGear(life, id, extra)
	self:push(life, report, { kind = "event", title = "Bought: " .. def.name, thread = "you" })
	self:push(life, report, { kind = "log", text = def.buyLog or ("You paid " .. price .. " " .. self.pack.meta.currency .. " for " .. aOrAn(def.name) .. "."), deltas = if price > 0 then { money = -price } else nil })
	for _, e in extra do
		self:push(life, report, e)
	end
	return report
end

-- (v0.13) the stash: what you own but aren't carrying. Equip from it (swapping what's in that
-- slot back in), or sell it for part of what it's worth.
function Sim:equipGear(life, id: string)
	if not life.alive then
		return nil, "This life is over."
	end
	if life.pending or life.run then
		return nil, "Not now."
	end
	local def = self.pack.gear and self.pack.gear[id]
	if not def or not life.stash or not table.find(life.stash, id) then
		return nil, "That isn't in your stash."
	end
	if def.minAge and life.age < def.minAge then
		return nil, "Age " .. def.minAge .. "+"
	end
	local report = newReport()
	local extra = {}
	self:giveGear(life, id, extra)
	for _, e in extra do
		self:push(life, report, e)
	end
	return report
end

function Sim:gearValue(id: string): number
	local def = self.pack.gear and self.pack.gear[id]
	if not def then
		return 0
	end
	if def.value then
		return def.value
	end
	local base = def.price or 0
	if base <= 0 then
		local byRarity = { common = 40, uncommon = 90, rare = 220, epic = 520, legendary = 1400, unreal = 3200 }
		base = byRarity[def.rarity or "common"] or 60
		return math.floor(base * 0.6)
	end
	return math.max(1, math.floor(base * 0.4))
end

function Sim:sellGear(life, id: string)
	if not life.alive then
		return nil, "This life is over."
	end
	if life.pending or life.run then
		return nil, "Not now."
	end
	local at = life.stash and table.find(life.stash, id)
	local def = self.pack.gear and self.pack.gear[id]
	if not at or not def then
		return nil, "That isn't in your stash."
	end
	if def.keep then
		return nil, "Nobody would buy that. You wouldn't sell it."
	end
	local pay = self:gearValue(id)
	table.remove(life.stash, at)
	life.money += pay
	local report = newReport()
	self:push(life, report, { kind = "log", text = "You sold your " .. def.name .. " to a workshop that didn't ask where it came from.", deltas = { money = pay } })
	return report
end

function Sim:stashView(life): any
	local out = {}
	for _, id in life.stash or {} do
		local def = self.pack.gear and self.pack.gear[id]
		if def then
			table.insert(out, { id = id, name = def.name, slot = def.slot, rarity = def.rarity or "common", effect = def.effect, desc = def.desc, value = if def.keep then nil else self:gearValue(id), look = def.look, unique = def.unique == true, set = def.set })
		end
	end
	return out
end

function Sim:dropGear(life, slot: string)
	if not life.alive or not life.gear or not life.gear[slot] then
		return nil, "Nothing to drop."
	end
	local report = newReport()
	local extra = {}
	self:loseGear(life, slot, extra)
	for _, e in extra do
		e.tone = nil
		self:push(life, report, e)
	end
	return report
end

-- ── conditions (injuries, illnesses) ────────────────────────────────────────

function Sim:addCondition(life, id: string, extra)
	local def = self.pack.conditions and self.pack.conditions[id]
	if not def then
		return
	end
	life.conditions = life.conditions or {}
	for _, c in life.conditions do
		if c.id == id then
			c.years = math.max(c.years, def.years or 1)
			return
		end
	end
	table.insert(life.conditions, { id = id, years = def.years or 1 })
	table.insert(extra, { kind = "system", tone = "bad", text = def.gainLog or ("You have " .. def.name .. ".") })
	self:news(life, life.first .. " is living with " .. def.name .. ".")
end

function Sim:cureCondition(life, which, extra)
	if not life.conditions or #life.conditions == 0 then
		return
	end
	local index = nil
	for i, c in life.conditions do
		local def = self.pack.conditions[c.id]
		local curable = def and def.curable ~= false
		if (which == true or which == "any") and curable then
			index = i
			break
		elseif c.id == which then
			index = i
			break
		end
	end
	if index then
		local c = table.remove(life.conditions, index)
		local def = self.pack.conditions[c.id]
		table.insert(extra, { kind = "system", tone = "good", text = (if def then def.name else c.id) .. " is behind you now." })
	end
end

function Sim:hasCondition(life, id: string): boolean
	for _, c in life.conditions or {} do
		if c.id == id then
			return true
		end
	end
	return false
end

-- clash bonuses from gear and conditions for one stat
-- ── Speed, Charisma, Luck: packs that name them in pack.stats.roles ────────

-- everything with a number under `field` that this life carries: gear, traits, conditions
-- (v0.13) gear sets (pack.gear.sets = { [id] = { name, two = bonus, three = bonus } }): two or
-- three pieces of one set carried at once add the set's bonus (clash, speed, capBonus, desc)
function Sim:activeSets(life): { any }
	local sets = self.pack.gear and self.pack.gear.sets
	local out = {}
	if not sets then
		return out
	end
	local count: { [string]: number } = {}
	for _, g in self:gearIn(life) do
		if g.def.set then
			count[g.def.set] = (count[g.def.set] or 0) + 1
		end
	end
	for id, n in count do
		local def = sets[id]
		if def then
			if n >= 2 and def.two then
				table.insert(out, { id = id, name = def.name, pieces = 2, bonus = def.two })
			end
			if n >= 3 and def.three then
				table.insert(out, { id = id, name = def.name, pieces = 3, bonus = def.three })
			end
		end
	end
	return out
end

function Sim:carried(life, field: string): number
	local n = 0
	for _, s in self:activeSets(life) do
		if type(s.bonus[field]) == "number" then
			n += s.bonus[field]
		end
	end
	for _, g in self:gearIn(life) do
		if type(g.def[field]) == "number" and (g.def.style == nil or g.def.style == life.style) then
			n += g.def[field]
		end
	end
	for _, id in life.traits or {} do
		local def = self.pack.traits and self.pack.traits[id]
		if def and type(def[field]) == "number" then
			n += def[field]
		end
	end
	for _, c in life.conditions or {} do
		local def = self.pack.conditions and self.pack.conditions[c.id]
		if def and type(def[field]) == "number" then
			n += def[field]
		end
	end
	return n
end

-- how fast this life is in a fight: the Speed stat, and whatever it carries with `speed`
-- (light boots +, a cast or a heavy coat -)
function Sim:speedOf(life): number
	local key = self.roles.speed
	if not key then
		return 0
	end
	return math.max(0, (life.stats[key] or 0) + self:carried(life, "speed"))
end

function Sim:luckOf(life): number
	local key = self.roles.luck
	return if key then math.max(0, (life.stats[key] or 0) + self:carried(life, "luck")) else 0
end

function Sim:charmOf(life): number
	local key = self.roles.charm
	return if key then math.max(0, (life.stats[key] or 0) + self:carried(life, "charm")) else 0
end

-- what a price comes to for this life: Charisma talks it down, up to a fifth off
function Sim:priceFor(life, price: number): number
	local charm = self:charmOf(life)
	local off = math.min(0.2, math.max(0, charm) / 300) + self:perkSum(life, "price") + self:carried(life, "priceCut")
	if off <= 0 or price <= 0 then
		return price
	end
	return math.max(1, math.floor(price * (1 - math.min(0.35, off)) + 0.5))
end




-- (v0.12) these live in Engine/Body.luau; see there
function Sim:maxHealthOf(life: any): number
	return Body.maxHealthOf(self, life)
end
-- (v0.17) how many years this body is good for, and a Bloodfiend's old blood
function Sim:lifespanOf(life: any): number
	return Body.lifespan(self, life)
end
function Sim:bloodStageName(life: any): string?
	return Body.bloodStageName(self, life)
end
function Sim:elderBlood(life: any, extra: any)
	Body.elderBlood(self, life, extra)
end
function Sim:trainerView(life: any): any
	local Training: any = require(script.Parent.Training)
	return Training.view(self, life)
end

function Sim:statCap(life: any, key: string, over: number?): number
	return Body.statCap(self, life, key, over)
end
function Sim:settleHealth(life: any)
	Body.settleHealth(self, life)
end
function Sim:playerAbilities(life: any, approach: any, player: any): number
	return Body.playerAbilities(self, life, approach, player)
end
function Sim:foeAbilities(spec: any, foe: any)
	Body.foeAbilities(self, spec, foe)
end
function Sim:abilitiesView(list: any): any
	return Body.abilitiesView(self, list)
end
function Sim:bloodAfter(life: any, approach: any, res: any, report: any)
	Body.bloodAfter(self, life, approach, res, report)
end
function Sim:rollHousehold(life: any, origin: any)
	Body.rollHousehold(self, life, origin)
end
function Sim:endingOf(life: any): any
	return Body.endingOf(self, life)
end
function Sim:endingPhrase(life: any): string
	return Body.endingPhrase(self, life)
end

function Sim:rollCrisis(life: any, report: any)
	Body.rollCrisis(self, life, report)
end
function Sim:crisisDef(life: any): any
	return Body.crisisDef(self, life)
end
function Sim:crisisView(life: any): any
	return Body.crisisView(self, life)
end
function Sim:moodView(life: any): any
	return Mood.view(self, life)
end

-- (v0.12) a linked friend's life as their friends see it: how strong they are right now
function Sim:friendSheet(life: any): any
	local stats = {}
	for _, key in self.pack.stats.order or {} do
		stats[key] = math.floor((life.stats[key] or 0) + 0.5)
	end
	local rn = Renown.view(self, life)
	local formDef = life.form and life.form ~= "human" and self.pack.forms[life.form]
	return {
		stats = stats,
		maxHealth = self:maxHealthOf(life),
		sanity = math.floor((life.sanity or 0) + 0.5),
		job = if life.career then (self:rankName(life) .. ", " .. self:careerName(life)) else nil,
		renown = if rn and rn.rank > 0 then rn.name else nil,
		form = if formDef then formDef.name else nil,
		money = life.money,
		home = if life.home then Market.homeView(self, life).name else nil,
		office = if life.office then life.office.name else nil,
		age = life.age,
	}
end

-- (v0.12) markets and homes: Engine/Market.luau
function Sim:buyMarket(life: any, marketId: string, goodId: string): (any, string?)
	local report = newReport()
	local ok, why = Market.buy(self, life, marketId, goodId, report)
	if not ok then
		return nil, why
	end
	self:checkAmbitions(life, report)
	return report, nil
end
-- applies a result outside an event (a purchase): as an activity's would be, then what follows
function Sim:applyResult(life: any, result: any, report: any)
	self:resolveOption(life, { result = result }, report, nil, self:workCtx(life))
	self:advance(life, report)
end
function Sim:meetSomeone(life: any, extra: any, role: string?): any
	return People.meet(self, life, extra, role)
end
function Sim:moveIntoHome(life: any, id: string, extra: any)
	Market.moveIn(self, life, id, extra)
end
function Sim:sellHome(life: any, extra: any): number
	return Market.sellHome(self, life, extra)
end
function Sim:marketsView(life: any): any
	return Market.view(self, life)
end
function Sim:homeView(life: any): any
	return Market.homeView(self, life)
end

-- (v0.13) turf wars (Engine/Turf.luau), cases (Engine/Cases.luau), feats and phases (Engine/Feats.luau)
function Sim:turfHeld(life: any): number
	return Turf.held(self, life)
end
function Sim:turfJoin(life: any, side: string, extra: any)
	Turf.join(self, life, side, extra)
end
function Sim:turfTake(life: any, n: number, extra: any)
	Turf.take(self, life, n, extra)
end
function Sim:turfLose(life: any, n: number, extra: any)
	Turf.lose(self, life, n, extra)
end
function Sim:turfView(life: any): any
	return Turf.view(self, life)
end
function Sim:turfFoe(life: any): string?
	return Turf.foeOf(self, life)
end
function Sim:caseOpen(life: any, id: string, extra: any)
	Cases.open(self, life, id, extra)
end
function Sim:caseClue(life: any, id: string, extra: any)
	Cases.clue(self, life, id, extra)
end
function Sim:caseClose(life: any, id: string, extra: any)
	Cases.close(self, life, id, extra)
end
function Sim:casesView(life: any): any
	return Cases.view(self, life)
end
function Sim:caseLabel(life: any, id: string): string?
	return Cases.progressLabel(self, life, id)
end
function Sim:checkFeats(life: any, report: any)
	Feats.check(self, life, report)
end
function Sim:featsView(life: any): any
	return Feats.view(self, life)
end
function Sim:phaseView(life: any): any
	return Feats.phaseView(self, life)
end

-- (v0.12) renown, an Office, the City's hold: Engine/Renown.luau
function Sim:addRenown(life: any, n: number, report: any?)
	Renown.add(self, life, n, report)
end
function Sim:renownRank(life: any): number
	return Renown.rankOf(self, life.renown or 0)
end
function Sim:setHolds(holds: any)
	self.holds = holds or {}
	Conditions.holds[self.pack] = self.holds
end

-- (v0.12) these live in Engine/Report.luau; see there
function Sim:scaledResult(result: any, gain: number, loss: number): any
	return Report.scaledResult(self, result, gain, loss)
end
function Sim:stakesOf(result: any, gain: number?, loss: number?, life: any?, ctx: any?): any
	return Report.stakesOf(self, result, gain, loss, life, ctx)
end
function Sim:stakesView(choice: any, life: any?, ctx: any?): any
	return Report.stakesView(self, choice, life, ctx)
end
function Sim:deathReport(life: any, cause: string): any
	return Report.deathReport(self, life, cause)
end
function Sim:lantern(life: any): any
	return Report.lantern(self, life)
end

function Sim:tierOf(value: number?): number
	local s = self.pack.stats
	return math.clamp(1 + math.floor((value or 0) / (s.tierEvery or 20)), 1, s.tierMax or 5)
end

function Sim:perkSum(life, key: string): number
	local perks = self.pack.stats.perks
	if not perks then
		return 0
	end
	local total = 0
	for stat, byTier in perks do
		local tier = self:tierOf(life.stats[stat])
		for t, perk in byTier do
			if t <= tier and type(perk[key]) == "number" then
				total += perk[key]
			end
		end
	end
	return total
end

function Sim:perkFlag(life, key: string): boolean
	local perks = self.pack.stats.perks
	if not perks then
		return false
	end
	for stat, byTier in perks do
		local tier = self:tierOf(life.stats[stat])
		for t, perk in byTier do
			if t <= tier and perk[key] == true then
				return true
			end
		end
	end
	return false
end

-- what fighting with `stat` gains from its own tier perks
function Sim:stancePerk(life: any, stat: string): any
	local out: any = { base = 0, coinPower = 0, coins = 0 }
	local byTier = self.pack.stats.perks and self.pack.stats.perks[stat]
	if byTier then
		local tier = self:tierOf(life.stats[stat])
		for t, perk in byTier do
			if t <= tier and type(perk.stance) == "table" then
				out.base += perk.stance.base or 0
				out.coinPower += perk.stance.coinPower or 0
				out.coins += perk.stance.coins or 0
			end
		end
	end
	return out
end

-- the perks of every stat, for the UI: what you have and what comes next
function Sim:perksView(life: any): any
	local perks: any = self.pack.stats.perks
	if not perks then
		return nil
	end
	local every: number = self.pack.stats.tierEvery or 20
	local out: any = {}
	for stat, byTier in perks do
		local tier: number = self:tierOf(life.stats[stat])
		local have: any, nextUp: any = {}, nil
		for t = 2, self.pack.stats.tierMax or 5 do
			local perk = byTier[t]
			if perk then
				if t <= tier then
					table.insert(have, { tier = t, name = perk.name, desc = perk.desc })
				elseif not nextUp then
					nextUp = { tier = t, at = (t - 1) * every, name = perk.name, desc = perk.desc }
				end
			end
		end
		out[stat] = { tier = tier, have = have, next = nextUp }
	end
	return out
end

-- NATURE: the stat a life leans on (pack.stats.natures = { order, min, <stat> = { name, desc } }).
-- It gives +1 on everything that uses that stat, and events of that kind find you more often.
function Sim:nature(life): string?
	local n = self.pack.stats.natures
	if not n then
		return nil
	end
	local best, bestV = nil, (n.min or 25) - 1
	for _, id in n.order do
		local v = life.stats[id] or 0
		if v > bestV then
			best, bestV = id, v
		end
	end
	return best
end

function Sim:actionsPerYear(life): number
	return (self.pack.meta.actionsPerYear or 3) + self:perkSum(life, "actions")
end

function Sim:socialPerYear(life): number?
	local base = self.pack.meta.socialPerYear
	if not base then
		return nil
	end
	return base + self:perkSum(life, "social")
end

-- is the foe of this clash someone you can talk to? (not a creature, not `mute`)
function Sim:foeIsPerson(spec): boolean
	local def = spec and self:foeDef(spec)
	return not (def and (def.kind == "creature" or def.mute == true))
end

-- BONDS THAT DO SOMETHING (pack.bondPerks = { backAt, saveAt, saveHealth, minAge }):
-- someone close enough stands with you in one fight a year (+1 coin), and someone closer still
-- gets to you in time, once in a life, when a wound would have ended it.
local function closest(self: any, life: any, floor: number): any
	local perks: any = self.pack.bondPerks
	local best: any = nil
	for _, rel in life.relations or {} do
		if rel.alive and (rel.bond or 0) >= floor and (rel.age or 0) >= (perks.minAge or 16) then
			if not best or rel.bond > best.bond then
				best = rel
			end
		end
	end
	return best
end
function Sim:backerFor(life: any): any
	local perks: any = self.pack.bondPerks
	if not perks or life.backedAge == life.age then
		return nil
	end
	return closest(self, life, perks.backAt or 80)
end
function Sim:saverFor(life: any): any
	local perks: any = self.pack.bondPerks
	if not perks or life.savedOnce then
		return nil
	end
	return closest(self, life, perks.saveAt or 90)
end

-- what using an approach costs in Sanity (approach.sanityCost = { base, per, min }): the
-- stronger the mind (the `will` stat), the less. E.G.O is paid for like this.
function Sim:approachCost(life, approach): number
	local c = approach and approach.sanityCost
	if type(c) ~= "table" then
		return 0
	end
	if self:perkFlag(life, "egoMin") then
		return c.min or 1
	end
	local will = life.stats[self.roles.will] or 0
	return math.max(c.min or 1, (c.base or 10) - math.floor(will / (c.per or 10)))
end

-- may this life take this approach to this clash? (approach.requires, approach.fightOnly)
function Sim:approachOpen(life, approach, spec): boolean
	if not approach then
		return false
	end
	if approach.fightOnly and not (spec and spec.fight) then
		return false
	end
	-- some ways only work on someone who can hear you
	if approach.only == "person" and not self:foeIsPerson(spec) then
		return false
	end
	if approach.requires then
		return (Conditions.check(approach.requires, life, self.pack, { noChance = true }))
	end
	return true
end

function Sim:statBonus(life, stat: string)
	local bonus = { coins = 0, base = 0, coinPower = 0 }
	local function add(tbl)
		local b = tbl and tbl[stat]
		if b then
			bonus.coins += b.coins or 0
			bonus.base += b.base or 0
			bonus.coinPower += b.coinPower or 0
		end
	end
	for _, g in self:gearIn(life) do
		if g.def.style == nil or g.def.style == life.style then
			add(g.def.clash)
		end
	end
	for _, s in self:activeSets(life) do
		add(s.bonus.clash)
	end
	for _, c in life.conditions or {} do
		local def = self.pack.conditions and self.pack.conditions[c.id]
		if def then
			add(def.clash)
		end
	end
	for _, id in life.traits or {} do
		local def = self:traitDef(id)
		if def and def.clash and (def.style == nil or def.style == life.style) then
			add(def.clash)
			add({ [stat] = def.clash.any })
		end
	end
	return bonus
end

-- ── traits, style and mastery ───────────────────────────────────────────────

function Sim:traitDef(id: string)
	return self.pack.traits and self.pack.traits[id]
end

function Sim:hasTrait(life, id: string): boolean
	return table.find(life.traits or {}, id) ~= nil
end

-- Gains a trait. Its one-off effects (stats, sanity, money, flags) apply right away.
function Sim:addTrait(life, id: string, extra): boolean
	local def = self:traitDef(id)
	if not def or self:hasTrait(life, id) then
		return false
	end
	life.traits = life.traits or {}
	table.insert(life.traits, id)
	for key, n in def.stats or {} do
		if life.stats[key] ~= nil then
			life.stats[key] = Util.clamp(life.stats[key] + n, 0, math.max(life.stats[key], self:statCap(life, key)))
		end
	end
	if def.sanity then
		local sc = self.pack.stats.sanity
		life.sanity = Util.clamp(life.sanity + def.sanity, sc.min, sc.max)
	end
	if def.money then
		life.money += def.money
	end
	for _, f in def.flags or {} do
		life.flags[f] = true
	end
	if extra then
		table.insert(extra, { kind = "system", text = "New trait: " .. def.name .. "." })
	end
	return true
end

function Sim:removeTrait(life, id: string, extra): boolean
	local i = table.find(life.traits or {}, id)
	if not i then
		return false
	end
	table.remove(life.traits, i)
	local def = self:traitDef(id)
	if extra and def then
		table.insert(extra, { kind = "system", text = "Lost the trait " .. def.name .. "." })
	end
	return true
end

function Sim:styleName(life): string
	local styles = self.pack.styles
	local def = styles and life.style and styles[life.style]
	return if def then def.name else "your style"
end

function Sim:setStyle(life, id: string, extra)
	local styles = self.pack.styles
	if not (styles and styles[id]) or life.style == id then
		return
	end
	life.style = id
	if extra then
		table.insert(extra, { kind = "system", text = "You fight with " .. styles[id].name .. " now." })
	end
end

-- ── schools (pack.schools): who teaches which way of fighting ───────────────
-- A discipline belongs to the organisation that trains it. school = { name, style, org,
-- desc, careers = { ids that keep training it }, free = true (handed down person to person) }.
-- career.teaches = "school"  |  career.teachesRoll = { "school", ... } (one, by chance)
-- career.trainsAny = true: keeps training whatever school you came with (Hana).
-- Outside its organisation a discipline stops at pack.outsideMastery.

function Sim:schoolDef(life)
	local schools = self.pack.schools
	return if schools and life.school then schools[life.school] else nil
end

-- true while this life works somewhere that trains its school
function Sim:inSchool(life): boolean
	local school = self:schoolDef(life)
	if not school then
		return false
	end
	if school.free then
		return true
	end
	if not life.career then
		return false
	end
	local cdef = self.pack.careers[life.career.id]
	if cdef and cdef.trainsAny then
		return true
	end
	return school.careers ~= nil and table.find(school.careers, life.career.id) ~= nil
end

function Sim:masteryCap(life): number
	local max = self.pack.maxMastery or 5
	if not self.pack.schools or self:inSchool(life) then
		return max
	end
	return math.min(max, self.pack.outsideMastery or 2)
end

-- Learn a school's way of fighting. Coming from another discipline, you start over with
-- half of what you knew; the same discipline under a new teacher keeps what you have.
function Sim:teach(life, schoolId: string, extra)
	local school = self.pack.schools and self.pack.schools[schoolId]
	if not school or life.school == schoolId then
		return
	end
	local styles = self.pack.styles
	local before = life.mastery or 0
	local same = life.style ~= nil and life.style == school.style
	life.school = schoolId
	if school.style and styles and styles[school.style] then
		life.style = school.style
		life.mastery = if same then math.max(before, 1) else math.max(1, math.floor(before / 2))
	end
	local sdef = school.style and styles and styles[school.style]
	if extra then
		table.insert(extra, {
			kind = "school",
			title = school.name,
			text = school.desc or "",
			org = school.org,
			style = sdef and sdef.name,
			color = sdef and sdef.color,
		})
	end
	self:highlight(life, "Learned " .. school.name .. ".")
end

function Sim:addMastery(life, n: number, extra)
	local max = self.pack.maxMastery or 5
	local before = life.mastery or 0
	-- outside the organisation that owns your discipline there's nobody to take you further
	local cap = if n > 0 then math.max(before, self:masteryCap(life)) else max
	life.mastery = Util.clamp(before + n, 0, cap)
	if extra and life.mastery > before then
		table.insert(extra, { kind = "system", text = string.format("%s mastery %d of %d.", self:styleName(life), life.mastery, max) })
	elseif extra and n > 0 and before >= cap and cap < max then
		local school = self:schoolDef(life)
		table.insert(extra, {
			kind = "system",
			text = if school and school.org
				then ("You've gone as far as you can alone. The rest of it is taught inside " .. school.org .. ".")
				else "You've gone as far as you can without a teacher.",
		})
	end
end

-- How strongly this life's style hits in a fight (1-6).
-- ── talents, toughness, books, modes ────────────────────────────────────────

-- how much faster this life learns a stat (traits with `growth`: a number, or { [stat] = n })
function Sim:growthOf(life, key: string): number
	local mult = 1
	for _, id in life.traits or {} do
		local def = self:traitDef(id)
		local g = def and def.growth
		if type(g) == "number" then
			mult *= g
		elseif type(g) == "table" and type(g[key]) == "number" then
			mult *= g[key]
		end
	end
	return mult
end

function Sim:masteryGrowthOf(life): number
	local mult = 1
	for _, id in life.traits or {} do
		local def = self:traitDef(id)
		if def and type(def.masteryGrowth) == "number" then
			mult *= def.masteryGrowth
		end
	end
	return mult
end

-- how much of a Fortitude loss lands (traits and gear with `toughness` < 1 take less)
function Sim:toughnessOf(life): number
	local mult = 1
	for _, id in life.traits or {} do
		local def = self:traitDef(id)
		if def and type(def.toughness) == "number" then
			mult *= def.toughness
		end
	end
	for _, g in self:gearIn(life) do
		if type(g.def.toughness) == "number" then
			mult *= g.def.toughness
		end
	end
	-- a hardy body takes less (tier perks)
	mult *= 1 - math.min(0.5, self:perkSum(life, "toughness"))
	return mult
end

-- the talents of one rarity tier (traits with talent = tierId)
function Sim:talentPool(tierId: string)
	local out = {}
	local traits = self.pack.traits
	for _, id in (traits and traits.order) or {} do
		local def = traits[id]
		if def and def.talent == tierId then
			table.insert(out, id)
		end
	end
	return out
end

-- one random talent by rarity (pack.talents.tiers weights); st: any table with an .rng.
-- fromTier: only that tier and the rarer ones after it can land (a "Rare or better" roll).
-- affinities: sins (pack.affinities) the player leans toward. They never change the
-- rarity odds; within the rolled tier, talents of those sins are AFFINITY_WEIGHT x as likely.
local AFFINITY_WEIGHT = 3
Sim.AFFINITY_WEIGHT = AFFINITY_WEIGHT
function Sim:rollTalent(st, fromTier: string?, affinities: { string }?): (string?, string?)
	local talents = self.pack.talents
	if not talents or not talents.tiers then
		return nil, nil
	end
	local weights = {}
	local open = fromTier == nil
	for i, tier in talents.tiers do
		if tier.id == fromTier then
			open = true
		end
		weights[i] = if open and #self:talentPool(tier.id) > 0 then tier.weight else 0
	end
	local idx = Rng.weighted(st, weights)
	local tier = idx and talents.tiers[idx]
	if not tier then
		return nil, nil
	end
	local pool = self:talentPool(tier.id)
	if affinities and #affinities > 0 then
		local w = {}
		for i, id in pool do
			local def = self:traitDef(id)
			w[i] = if def and def.affinity and table.find(affinities, def.affinity) then AFFINITY_WEIGHT else 1
		end
		local at = Rng.weighted(st, w)
		return pool[at or 1], tier.id
	end
	return Rng.pick(st, pool), tier.id
end

-- the sins a life leans toward, cleaned (known ids, at most 2, no repeats)
function Sim:cleanAffinities(list): { string }
	local out = {}
	local defs = self.pack.affinities
	if not defs or type(list) ~= "table" then
		return out
	end
	for _, id in list do
		if type(id) == "string" and defs[id] and not table.find(out, id) and #out < 2 then
			table.insert(out, id)
		end
	end
	return out
end

-- Resonance: the talent shares a sin with one of the life's affinities
function Sim:resonates(life): boolean
	if Talent.asleep(self, life) then
		return false
	end
	local def = life.talent and self:traitDef(life.talent)
	return def ~= nil and def.affinity ~= nil and life.affinities ~= nil and table.find(life.affinities, def.affinity) ~= nil
end

function Sim:talentTier(tierId: string?)
	for _, tier in (self.pack.talents and self.pack.talents.tiers) or {} do
		if tier.id == tierId then
			return tier
		end
	end
	return nil
end

-- the real odds of each tier, in percent (fromTier as in rollTalent)
function Sim:talentOdds(fromTier: string?)
	local out, total = {}, 0
	local open = fromTier == nil
	for _, tier in (self.pack.talents and self.pack.talents.tiers) or {} do
		if tier.id == fromTier then
			open = true
		end
		if open and #self:talentPool(tier.id) > 0 then
			total += tier.weight
			table.insert(out, { id = tier.id, name = tier.name, color = tier.color, weight = tier.weight, count = #self:talentPool(tier.id) })
		end
	end
	for _, o in out do
		o.percent = if total > 0 then o.weight / total * 100 else 0
		o.weight = nil
	end
	return out
end

function Sim:bookDef(id: string?)
	return id and self.pack.books and self.pack.books[id] or nil
end

function Sim:giveBook(life, id: string, extra)
	local def = self:bookDef(id)
	if not def then
		return
	end
	life.books = life.books or {}
	if table.find(life.books, id) or #life.books >= 12 then
		return
	end
	table.insert(life.books, id)
	local teaches = def.trait and self:traitDef(def.trait)
	local line = "Yours now: " .. def.name .. (if teaches then ". Read it (YOU, or DO) to learn " .. teaches.name .. "." else ". Read it from YOU, or DO.")
	-- written for one discipline: say so the moment it's in your hands
	if def.schools and not (life.school and table.find(def.schools, life.school)) then
		line = "Yours now: " .. def.name .. ". It is written for people with " .. self:schoolNames(def.schools) .. " training: you can keep it, but you can't follow it until you have that."
	end
	table.insert(extra, { kind = "system", tone = "good", text = line })
end

-- "Kurokumo or Blade Lineage": the disciplines a book or an activity is written for
function Sim:schoolNames(list): string
	local names = {}
	for _, id in list or {} do
		local def = self.pack.schools and self.pack.schools[id]
		table.insert(names, (def and def.name) or tostring(id))
	end
	return table.concat(names, " or ")
end

function Sim:readBook(life, id: string, extra)
	local def = self:bookDef(id)
	local at = def and life.books and table.find(life.books, id)
	if not at then
		return
	end
	if def.schools and not (life.school and table.find(def.schools, life.school)) then
		table.insert(extra, { kind = "system", text = def.name .. " assumes training you don't have. You put it back on the shelf." })
		return
	end
	table.remove(life.books, at)
	table.insert(extra, { kind = "system", tone = "good", text = "You read " .. def.name .. " cover to cover." })
	if def.trait then
		self:addTrait(life, def.trait, extra)
	end
	if def.mastery then
		self:addMastery(life, def.mastery, extra)
	end
end

function Sim:modeDef(id: string?)
	for _, m in self.pack.modes or {} do
		if m.id == id then
			return m
		end
	end
	return nil
end

-- a game mode that skips ahead: start at an age, as a form, in a job, with traits
function Sim:applyModeStart(life, mode, report)
	local start = mode.start or {}
	local extra = {}
	life.mode = mode.id
	local styles = self.pack.styles
	if life.style == nil and styles and styles.order and #styles.order > 0 and (start.age or 0) >= 12 and not self.pack.schools then
		life.style = start.style or Rng.pick(life, styles.order)
	end
	if start.age and start.age > life.age then
		local years = start.age - life.age
		life.age = start.age
		life.year += years
		for _, rel in life.relations do
			rel.age = (rel.age or 0) + years
		end
		self:rollWorld(life, nil, true)
	end
	for key, n in start.stats or {} do
		if life.stats[key] then
			life.stats[key] = Util.clamp(life.stats[key] + n, 0, math.max(life.stats[key], self:statCap(life, key)))
		end
	end
	if start.money then
		life.money += start.money
	end
	for _, f in start.flags or {} do
		life.flags[f] = true
	end
	if start.form then
		self:setForm(life, start.form, extra)
	end
	for _, t in start.traits or {} do
		self:addTrait(life, t, extra)
	end
	if start.mastery then
		self:addMastery(life, start.mastery, extra)
	end
	if start.career and self.pack.careers[start.career] then
		self:setCareer(life, start.career, extra)
		if life.career and start.rank and start.rank > 1 then
			life.career.rank = math.min(start.rank, #self.pack.careers[start.career].ranks)
			life.peakRank = math.max(life.peakRank or 0, life.career.rank)
			self:trackRanking(life)
		end
	end
	for _, b in start.books or {} do
		self:giveBook(life, b, extra)
	end
	if start.log then
		table.insert(extra, 1, { kind = "log", text = self:render(life, start.log) })
	end
	for _, e in extra do
		self:push(life, report, e)
	end
end

function Sim:fightPotency(life): number
	local potency = 1 + math.floor((life.mastery or 0) / 2)
	for _, id in life.traits or {} do
		local def = self:traitDef(id)
		if def and def.fight and (def.style == nil or def.style == life.style) then
			potency += def.fight.potency or 0
		end
	end
	for _, g in self:gearIn(life) do
		if g.def.fight and (g.def.style == nil or g.def.style == life.style) then
			potency += g.def.fight.potency or 0
		end
	end
	return math.clamp(potency, 1, 6)
end

-- ── lore ────────────────────────────────────────────────────────────────────

-- Unlocks lore entries; the server keeps them for the account and shows the new ones.
function Sim:unlockCodex(life, ids, report)
	if ids == nil then
		return
	end
	life.codex = life.codex or {}
	for _, id in Util.asList(ids) do
		if self.codexById[id] and not life.codex[id] then
			life.codex[id] = true
			if report then
				report.codex = report.codex or {}
				table.insert(report.codex, id)
			end
		end
	end
end

-- Records (achievements): ids whose `check` this finished life satisfies.
-- Shared test for Records, titles and ambitions:
-- { when = {conditions}, bornSide, minPeakMoney, minPeakRank, minMoves, heir, causeHas,
--   minChildren, minGeneration, tally = { clashesWon = 10, ... } }
function Sim:meetsCheck(life, c): boolean
	c = c or {}
	if not Conditions.check(c.when, life, self.pack, { noChance = true }) then
		return false
	end
	if c.bornSide and life.bornSide ~= c.bornSide then
		return false
	end
	if c.minPeakMoney and (life.peakMoney or 0) < c.minPeakMoney then
		return false
	end
	if c.minPeakRank and (life.peakRank or 0) < c.minPeakRank then
		return false
	end
	if c.minMoves and (life.moves or 0) < c.minMoves then
		return false
	end
	if c.heir and not life.flags.heir then
		return false
	end
	if c.causeHas and not string.find(string.lower(life.cause or ""), string.lower(c.causeHas), 1, true) then
		return false
	end
	if c.minChildren and self:countKind(life, "child") < c.minChildren then
		return false
	end
	if c.minGeneration and (life.generation or 1) < c.minGeneration then
		return false
	end
	for key, need in c.tally or {} do
		if ((life.tally and life.tally[key]) or 0) < need then
			return false
		end
	end
	return true
end

function Sim:countKind(life, kind: string): number
	local n = 0
	for _, rel in life.relations do
		if rel.kind == kind then
			n += 1
		end
	end
	return n
end

-- Counters used by titles, ambitions and the life score.
function Sim:tally(life, key: string, amount: number?)
	life.tally = life.tally or {}
	life.tally[key] = (life.tally[key] or 0) + (amount or 1)
end

function Sim:checkRecords(life)
	local met = {}
	for _, r in self.pack.records or {} do
		if self:meetsCheck(life, r.check) then
			table.insert(met, r.id)
		end
	end
	return met
end

-- ── ambitions: goals a life is working toward (three at a time) ────────────

local AMBITION_SLOTS = 3

function Sim:ambitionDef(id: string)
	for _, a in self.pack.ambitions or {} do
		if a.id == id then
			return a
		end
	end
	return nil
end

-- 0..1 progress toward an ambition, for the HUD bar (nil = no bar)
function Sim:ambitionProgress(life, def): number?
	local p = def.progress
	if not p then
		return nil
	end
	local have, need = 0, 1
	if p.money then
		have, need = life.money, p.money
	elseif p.age then
		have, need = life.age, p.age
	elseif p.rank then
		have, need = (if life.career then life.career.rank else 0), p.rank
	elseif p.stat then
		have, need = life.stats[p.stat] or 0, p.target or 100
	elseif p.tally then
		have, need = (life.tally and life.tally[p.tally]) or 0, p.target or 1
	elseif p.children then
		have, need = self:countKind(life, "child"), p.children
	end
	return math.clamp(have / math.max(1, need), 0, 1)
end

-- fills empty slots with ambitions that fit this age and haven't been done
function Sim:rollAmbitions(life)
	local list = self.pack.ambitions
	if not list then
		return
	end
	life.ambitions = life.ambitions or {}
	life.ambitionsDone = life.ambitionsDone or {}
	local active = {}
	for _, a in life.ambitions do
		active[a.id] = true
	end
	while #life.ambitions < AMBITION_SLOTS do
		local options, weights = {}, {}
		for _, def in list do
			local fits = not active[def.id]
				and not life.ambitionsDone[def.id]
				and life.age >= (def.minAge or 0) - 2
				and life.age <= (def.maxAge or 200)
				and Conditions.check(def.when, life, self.pack, { noChance = true })
				and not self:meetsCheck(life, def.check)
			if fits then
				table.insert(options, def)
				table.insert(weights, def.weight or 10)
			end
		end
		if #options == 0 then
			break
		end
		local pick = options[Rng.weighted(life, weights) or 1]
		table.insert(life.ambitions, { id = pick.id })
		active[pick.id] = true
	end
end

function Sim:checkAmbitions(life, report)
	self:checkQuests(life, report)
	if not life.alive or not self.pack.ambitions then
		return
	end
	life.ambitions = life.ambitions or {}
	life.ambitionsDone = life.ambitionsDone or {}
	local still = {}
	for _, a in life.ambitions do
		local def = self:ambitionDef(a.id)
		if def and life.age >= (def.minAge or 0) and self:meetsCheck(life, def.check) then
			life.ambitionsDone[a.id] = life.age
			self:tally(life, "ambitions")
			self:push(life, report, { kind = "system", tone = "good", text = "Ambition met: " .. def.name .. ".", celebrate = "ambition" })
			self:highlight(life, "Ambition: " .. def.name)
			self:news(life, life.first .. " met an ambition: " .. def.name .. ".")
			if def.reward then
				Effects.apply(self, life, def.reward, report)
			end
		elseif def and (life.age > (def.maxAge or 200) + 1 or not Conditions.check(def.when, life, self.pack, { noChance = true })) then
			-- out of reach now (too old, or the job it needs is gone): let it go, so the slot
			-- can hold something that fits this part of the life
			self:push(life, report, { kind = "system", text = "You let go of a goal: " .. def.name .. "." })
		elseif def then
			table.insert(still, a)
		end
	end
	life.ambitions = still
	self:rollAmbitions(life)
	-- (v0.13) feats: the long goals (Engine/Feats.luau)
	Feats.check(self, life, report)
end

-- ── side quests: multi-step stories, started by an event (result.quest = "id") ──

function Sim:questDef(id: string)
	local q = self.pack.quests
	return q and q[id]
end

function Sim:startQuest(life, id: string, report)
	local def = self:questDef(id)
	if not def or not life.alive then
		return
	end
	life.quests = life.quests or {}
	life.questsDone = life.questsDone or {}
	if life.quests[id] or life.questsDone[id] then
		return
	end
	life.quests[id] = { step = 1, age = life.age }
	self:push(life, report, { kind = "system", tone = "strange", text = "New quest: " .. def.name .. ".", celebrate = "quest" })
	self:news(life, life.first .. " took on a quest: " .. def.name .. ".")
	local first = def.steps[1]
	if first and first.onStart then
		Effects.apply(self, life, first.onStart, report)
	end
end

function Sim:checkQuests(life, report)
	if not life.alive or not life.quests then
		return
	end
	life.questsDone = life.questsDone or {}
	for id, q in life.quests do
		local def = self:questDef(id)
		local guard = 0
		while def and q and guard < 10 do
			guard += 1
			local step = def.steps[q.step]
			if not step or not self:meetsCheck(life, step.check) then
				break
			end
			q.step += 1
			if step.doneLog then
				self:push(life, report, { kind = "system", tone = "good", text = step.doneLog })
			end
			if q.step > #def.steps then
				life.quests[id] = nil
				life.questsDone[id] = life.age
				self:tally(life, "quests")
				self:push(life, report, { kind = "system", tone = "good", text = "Quest complete: " .. def.name .. ".", celebrate = "quest" })
				self:highlight(life, "Quest: " .. def.name)
				self:news(life, life.first .. " finished a quest: " .. def.name .. ".")
				if def.reward then
					Effects.apply(self, life, def.reward, report)
				end
				q = nil
			else
				local nextStep = def.steps[q.step]
				if nextStep.onStart then
					Effects.apply(self, life, nextStep.onStart, report)
				end
			end
		end
		if def and q and def.expires and life.age - q.age > def.expires then
			life.quests[id] = nil
			self:push(life, report, { kind = "system", tone = "bad", text = "Quest lost: " .. def.name .. ". Too much time went by." })
		end
	end
end

function Sim:questsView(life)
	local out = {}
	for id, q in life.quests or {} do
		local def = self:questDef(id)
		if def then
			local step = def.steps[q.step]
			table.insert(out, {
				id = id,
				name = self:render(life, def.name),
				desc = self:render(life, def.desc),
				step = q.step,
				steps = #def.steps,
				stepText = if step then self:render(life, step.text) else "",
				hint = if step and step.hint then self:render(life, step.hint) else nil,
				active = true,
			})
		end
	end
	table.sort(out, function(a, b)
		return a.name < b.name
	end)
	for id, age in life.questsDone or {} do
		local def = self:questDef(id)
		if def then
			table.insert(out, { id = id, name = self:render(life, def.name), desc = self:render(life, def.desc), doneAge = age, active = false, steps = #def.steps, step = #def.steps })
		end
	end
	return out
end

-- ── expeditions, solo (crews are run by the server with Engine/Expedition) ──

function Sim:startExpedition(life, id: string)
	local run, result = Expedition.start(self, { life }, id)
	if not run then
		return nil, result
	end
	return result[1]
end

-- (v0.13) episodes (pack.episodes): where a card sits in its episode, and the ones lived
function Sim:episodeTag(event: any): any
	local def = event.episode and self.pack.episodes and self.pack.episodes[event.episode]
	if not def then
		return nil
	end
	return { id = event.episode, name = def.name, step = event.step, of = def.of, color = def.color }
end
function Sim:episodesView(life: any): any
	local out = {}
	for _, id in (self.pack.episodes and self.pack.episodes.order) or {} do
		local rec = life.episodes and life.episodes[id]
		if rec then
			local def = self.pack.episodes[id]
			table.insert(out, { id = id, name = def.name, ending = rec.ending, age = rec.age, color = def.color })
		end
	end
	return out
end

-- (v0.13) a way in, found in the world: an event's result.expedition takes you straight down,
-- no menu, no action spent. Its stages follow as cards; returns whether it began.
function Sim:startExpeditionInline(life, id: string, extra: any): boolean
	local def = Expedition.def(self, id)
	if not def or not life.alive or life.run then
		return false
	end
	life.flags["found_" .. id] = true
	if not Conditions.check(def.when, life, self.pack, { noChance = true }) then
		return false
	end
	local run, reports = Expedition.start(self, { life }, id, { free = true })
	if not run then
		return false
	end
	for _, e in (reports and reports[1] and reports[1].entries) or {} do
		table.insert(extra, e)
	end
	return true
end

-- (v0.18) running your own Office (Engine/Office.luau): hire, fire, building, room, experiment
function Sim:officeAct(life, op: string, arg: any)
	if not life.alive then
		return nil, "This life is over."
	end
	if not life.office then
		return nil, "You don't have an Office."
	end
	if op == "hire" and type(arg) == "number" then
		return Office.hire(self, life, arg)
	elseif op == "fire" and type(arg) == "number" then
		return Office.fire(self, life, arg)
	elseif op == "building" then
		return Office.buyBuilding(self, life)
	elseif op == "room" and type(arg) == "string" then
		return Office.buyRoom(self, life, arg)
	elseif op == "experiment" then
		if life.pending then
			return nil, "Decide what to do first."
		end
		return Office.experiment(self, life)
	end
	return nil, "Bad request."
end

function Sim:officeRename(life, name: string?, motto: string?, color: string?)
	return Office.rename(self, life, name, motto, color)
end

-- (v0.18) the mod menu's "give them an Office"
function Sim:foundOffice(life, report)
	if life.office then
		return nil, "They already have an Office."
	end
	local r = report or Sim.newReport()
	Renown.foundOffice(self, life, r)
	return r
end

function Sim:doJob(life, index: number, approachId: string?)
	return Jobs.take(self, life, index, approachId)
end

function Sim:chooseExpedition(life, index: number, approachId: string?)
	local run = life.run
	if not run or run.crew then
		return nil, "You're not on an expedition."
	end
	local reports, err = Expedition.choose(self, { life }, run, index, approachId)
	if not reports then
		return nil, err
	end
	return reports[1]
end

function Sim:runView(life)
	local run = life.run
	if not run or run.crew then
		return nil
	end
	return Expedition.view(self, { life }, run)
end

-- ── the life score ("who had the best life") and the title a life ends with ──

-- Scores a life. A long, full life with family, work, money and adventures scores
-- highest. Server-side only, from the real life, so it's fair for the leaderboard.
function Sim:score(life): number
	local t = life.tally or {}
	local bonds = 0
	for _, rel in life.relations do
		if rel.alive and rel.bond >= 70 then
			bonds += 1
		end
	end
	local score = life.age * 6
		+ (life.peakRank or 0) * 25
		+ math.log10(math.max(0, life.peakMoney or 0) + 1) * 40
		+ #self:checkRecords(life) * 30
		+ math.min(4, self:countKind(life, "child")) * 15
		+ math.min(8, bonds) * 8
		+ (t.ambitions or 0) * 25
		+ math.min(10, t.expeditions or 0) * 15
		+ math.min(60, t.clashesWon or 0) * 2
		+ math.min(5, (life.generation or 1) - 1) * 10
	if life.form == "surfaced" then
		score += 40
	end
	-- a harder City counts for more (pack.difficulties[id].score)
	local diff = self:difficultyDef(life)
	if diff and diff.score then
		score *= diff.score
	end
	return math.floor(score + 0.5)
end

-- The first title in pack.ribbons whose check passes (or the last one, the default).
function Sim:ribbon(life)
	local list = self.pack.ribbons or {}
	for _, r in list do
		if r.check and self:meetsCheck(life, r.check) then
			return r
		end
	end
	return list[#list]
end

-- ── life creation ───────────────────────────────────────────────────────────

local function blankLife(self, seed: number)
	local pack = self.pack
	local life = {
		v = LIFE_VERSION,
		id = tostring(seed),
		rng = Rng.seed(seed),
		alive = true,
		age = 0,
		year = 0,
		bornYear = 0,
		first = "",
		last = "",
		district = pack.districts.order[1],
		side = self:arrivalSide(),
		origin = "",
		form = "human",
		stats = {},
		sanity = pack.stats.sanity.start or 0,
		money = 0,
		career = nil,
		peakRank = 0,
		peakMoney = 0,
		flags = {},
		history = {},
		actUsed = {},
		scheduled = {},
		queue = {},
		pending = nil,
		focusLink = nil,
		relations = {},
		nextRelId = 1,
		world = {},
		gear = {}, -- [slot] = gear id
		conditions = {}, -- { { id = string, years = number } }
		bornSide = nil,
		moves = 0,
		actionsLeft = pack.meta.actionsPerYear or 3,
		socialLeft = pack.meta.socialPerYear, -- time for people has its own budget, if the pack says so
		log = {},
		highlights = {},
		cause = nil,
		heirOf = nil,
		generation = 1,
		tally = {},
		traits = {},
		style = nil,
		mastery = 0,
		codex = {},
		dailyDay = nil,
		actor = nil,
	}
	for _, key in self.coreStats do
		-- a stat may be dealt its own way at birth: pack.stats[key].birth = { min, max }
		local def = self.pack.stats[key]
		local birth = def and def.birth
		life.stats[key] = if birth then Rng.int(life, birth[1], birth[2]) else 5 + Rng.int(life, 0, 10)
	end
	life.stats[self.vital] = 42 + Rng.int(life, 0, 14)
	return life
end

function Sim:rollWorld(life, report, initial: boolean?)
	for _, var in self.pack.world do
		if var.byYear then
			local value = nil
			for _, step in var.byYear do
				if life.year >= step.from then
					value = step.value
				end
			end
			if value ~= life.world[var.key] then
				life.world[var.key] = value
				if not initial and var.labels and value then
					self:push(life, report, { kind = "world", text = var.labels[value] or tostring(value) })
				end
			end
		elseif var.values then
			local current = life.world[var.key]
			if current == nil or initial then
				life.world[var.key] = var.start or var.values[1]
			elseif Rng.chance(life, var.shift or 0.3) then
				local idx = table.find(var.values, current) or 1
				local step = if Rng.chance(life, 0.5) then 1 else -1
				local nextIdx = math.clamp(idx + step, 1, #var.values)
				if nextIdx == idx then
					nextIdx = math.clamp(idx - step, 1, #var.values)
				end
				local value = var.values[nextIdx]
				if value ~= current then
					life.world[var.key] = value
					local label = if var.labels then var.labels[value] else value
					self:push(life, report, { kind = "world", text = (var.name or var.key) .. ": " .. tostring(label) })
				end
			end
		end
	end
end

function Sim:addFamily(life, family)
	if not family then
		return
	end
	local kinds = self.pack.relationKinds
	for _, kind in { "mother", "father" } do
		if family[kind] then
			local gap = (kinds[kind] and kinds[kind].ageGap) or { 20, 35 }
			local first = select(1, self:randomName(life))
			table.insert(life.relations, {
				id = life.nextRelId,
				kind = kind,
				first = first,
				last = life.last,
				age = life.age + Rng.int(life, gap[1], gap[2]),
				bond = Rng.int(life, 55, 85),
				alive = true,
				look = Avatar.randomLook(self.pack, self:lifeRoll(life), life.look),
			})
			-- (v0.17) a mother is drawn with a feminine build, a father with a masculine one
			local made = life.relations[#life.relations]
			local body = self.pack.kindBodies and self.pack.kindBodies[kind]
			if body and made and made.look then
				made.look.body = body
			end
			life.nextRelId += 1
		end
	end
	local siblings = if family.siblings then Rng.roll(life, family.siblings) else 0
	for _ = 1, siblings do
		local first = select(1, self:randomName(life))
		table.insert(life.relations, {
			id = life.nextRelId,
			kind = "sibling",
			first = first,
			last = life.last,
			age = math.max(0, life.age + Rng.int(life, -6, 8)),
			bond = Rng.int(life, 40, 80),
			alive = true,
			look = Avatar.randomLook(self.pack, self:lifeRoll(life), life.look),
		})
		life.nextRelId += 1
	end
end

function Sim:rollDistrict(life, preferred: string?): string
	local districts = self.pack.districts
	if preferred and districts[preferred] then
		return preferred
	end
	local weights = {}
	for i, id in districts.order do
		weights[i] = districts[id].population or 1
	end
	return districts.order[Rng.weighted(life, weights) or 1]
end

-- When in the City's history a life starts: pack.calendar.eras = { { id, name, desc, year, jitter }, ... }.
-- Returns the era def for an id, or nil (then the calendar's startYear is used).
function Sim:birthEraDef(id: string?)
	local eras = self.pack.calendar and self.pack.calendar.eras
	if type(id) ~= "string" or not eras then
		return nil
	end
	for _, e in eras do
		if e.id == id then
			return e
		end
	end
	return nil
end

-- The City picks an age to be born into (era.weight).
function Sim:rollEra(st)
	local eras = self.pack.calendar and self.pack.calendar.eras
	if not eras or #eras == 0 then
		return nil
	end
	local weights = {}
	for i, e in eras do
		weights[i] = e.weight or 1
	end
	local idx = Rng.weighted(st, weights)
	return if idx then eras[idx] else nil
end

-- the year a new life would start in, for a group starting together (everyone gets one year)
function Sim:rollBirthYear(eraId: string?, roll: number?)
	local cal = self.pack.calendar
	local era = self:birthEraDef(eraId)
	if not era and cal.rollEra and cal.eras and #cal.eras > 0 then
		-- nobody picked: the City does, by weight
		local total = 0
		for _, e in cal.eras do
			total += e.weight or 1
		end
		local at = math.random() * total
		for _, e in cal.eras do
			at -= e.weight or 1
			if at <= 0 then
				era = e
				break
			end
		end
		era = era or cal.eras[#cal.eras]
	end
	local year, jitter = cal.startYear, cal.startJitter or 0
	if era then
		year, jitter = era.year, era.jitter or 0
	end
	local r = roll or math.random()
	return year - jitter + math.floor(r * (jitter * 2 + 1))
end

-- opts: { seed: number, originId: string?, first: string?, last: string?, district: string?, side: string?, look: table?,
--         traits: {string}?, bonusTraits: {string}?, style: string?, alloc: {[stat]: number}?,
--         birthEra: string?, year: number?, flags: {string}?, dailyDay: number?,
--         extraTraitPicks: number?, extraPoints: number?,  (perks the server grants)
--         talent: string?  (a talent the server rolled; otherwise one is rolled here),
--         mode: string?  (pack.modes: start later in life, as a form, in a job) }
-- opts.look must already be checked against what the player has unlocked (the server does that).
-- traits: up to pack.traitPicks of the traits marked `pick`; bonusTraits (from a surname, say) are free.
-- alloc: bonus points (pack.build.points in all, pack.build.maxPer each, pack.build.perPoint stat each).
function Sim:newLife(opts)
	local pack = self.pack
	local life = blankLife(self, opts.seed or 1)
	-- when: a chosen age of birth (pack.calendar.eras), or one the City picks (calendar.rollEra)
	local startMode = self:modeDef(opts.mode)
	life.year = pack.calendar.startYear + Rng.int(life, -(pack.calendar.startJitter or 0), pack.calendar.startJitter or 0)
	local era = self:birthEraDef((startMode and startMode.era) or opts.birthEra)
	if not era and pack.calendar.rollEra and not (startMode and startMode.start) then
		era = self:rollEra(life)
	end
	if era then
		life.year = era.year + Rng.int(life, -(era.jitter or 0), era.jitter or 0)
		life.bornEra = era.id
	end
	if type(opts.year) == "number" then
		life.year = opts.year
	end
	local origin = self.originsById[opts.originId or ""] or pack.origins[1]
	-- (opts.district and opts.side come from a lobby: everyone starts in one place)
	local wantSide = if type(opts.side) == "string" and pack.sides[opts.side] and table.find(pack.sides.order, opts.side) then opts.side else nil
	if opts.rollOrigin then
		local want = if (opts.district and pack.districts[opts.district]) or wantSide then { district = opts.district, side = wantSide } else nil
		origin = self:rollOrigin(life, opts.allowedOrigins, want) or origin
	end
	life.origin = origin.id
	local rf, rl = self:randomName(life)
	life.first = if opts.first and opts.first ~= "" then opts.first else rf
	life.last = if opts.last and opts.last ~= "" then opts.last else rl
	life.look = if type(opts.look) == "table" then Avatar.sanitize(pack, opts.look) else Avatar.randomLook(pack, self:lifeRoll(life))
	life.bornYear = life.year
	-- some origins fix where you're born (an L Corp family lives in its District)
	life.district = if origin.district and pack.districts[origin.district] then origin.district else self:rollDistrict(life, opts.district)
	Known.learnPlace(self, life)
	life.form = origin.form or "human"
	local district = self:districtDef(life)
	if origin.side and pack.sides[origin.side] then
		-- (with a wanted side, only families that live there, or anywhere, were rolled)
		life.side = origin.side
	elseif wantSide then
		-- the side was chosen for them (a lobby's host)
		life.side = wantSide
	else
		local share = (district.charterShare or 0.2) * (origin.charterBias or 1)
		life.side = if Rng.chance(life, share) then pack.sides.order[1] else self:arrivalSide()
	end
	if self:formBlocksSide(life, life.side) then
		life.side = self:arrivalSide()
	end
	life.money = origin.money or 0
	life.sanity = Util.clamp((pack.stats.sanity.start or 0) + (origin.sanity or 0), pack.stats.sanity.min, pack.stats.sanity.max)
	if origin.stats then
		for key, n in origin.stats do
			life.stats[key] = Util.clamp((life.stats[key] or 0) + n, 0, math.max(life.stats[key] or 0, self:statCap(life, key)))
		end
	end
	if origin.flags then
		for _, f in origin.flags do
			life.flags[f] = true
		end
	end
	if life.side == pack.sides.order[1] then
		life.flags.charter_born = true
	end
	life.bornSide = life.side
	-- the build: picked traits, free traits, a fighting style and bonus stat points
	local picked = 0
	local maxPicks = (pack.traitPicks or 2) + math.clamp(math.floor(tonumber(opts.extraTraitPicks) or 0), 0, 3)
	for _, id in Util.asList(opts.traits or {}) do
		local def = self:traitDef(id)
		if def and def.pick and picked < maxPicks and self:addTrait(life, id) then
			picked += 1
		end
	end
	for _, id in Util.asList(opts.bonusTraits or {}) do
		self:addTrait(life, id)
	end
	-- packs without creator picks (v0.8): the Extra Trait perk is a random trait at birth,
	-- and Born Gifted spreads its points over every virtue
	local perkLines = {}
	if pack.creatorPicks == false then
		local extra = math.clamp(math.floor(tonumber(opts.extraTraitPicks) or 0), 0, 3)
		for _ = 1, extra do
			local pool = {}
			for _, id in (pack.traits and pack.traits.order) or {} do
				local def = pack.traits[id]
				if def and def.pick and not def.talent and not table.find(life.traits or {}, id) then
					table.insert(pool, id)
				end
			end
			if #pool > 0 then
				local id = Rng.pick(life, pool)
				if self:addTrait(life, id) then
					life.perkTrait = id
					table.insert(perkLines, "Extra Trait: " .. ((pack.traits[id] and pack.traits[id].name) or id) .. ".")
				end
			end
		end
		local points = math.clamp(math.floor(tonumber(opts.extraPoints) or 0), 0, 20)
		if points > 0 then
			local each = math.max(1, math.floor(points * ((pack.build and pack.build.perPoint) or 1) / 4))
			for _, key in self.coreStats do
				life.stats[key] = Util.clamp(life.stats[key] + each, 0, self:statCap(life, key))
			end
			table.insert(perkLines, string.format("Born Gifted: +%d to every %s.", each, pack.stats.word or "virtue"))
		end
	end
	if pack.styles and pack.styles.order and #pack.styles.order > 0 then
		if opts.style and pack.styles[opts.style] then
			life.style = opts.style
		elseif pack.styleAtBirth ~= false then
			life.style = Rng.pick(life, pack.styles.order)
		end
	end
	if pack.build and type(opts.alloc) == "table" then
		local left = (pack.build.points or 0) + math.clamp(math.floor(tonumber(opts.extraPoints) or 0), 0, 20)
		for _, key in self.coreStats do
			local n = math.clamp(math.floor(tonumber(opts.alloc[key]) or 0), 0, pack.build.maxPer or left)
			n = math.min(n, left)
			left -= n
			life.stats[key] = Util.clamp(life.stats[key] + n * (pack.build.perPoint or 1), 0, self:statCap(life, key))
		end
	end
	if type(opts.year) == "number" then
		life.year = math.floor(opts.year)
		life.bornYear = life.year
	end
	for _, f in Util.asList(opts.flags or {}) do
		life.flags[f] = true
	end
	life.dailyDay = opts.dailyDay
	self:addFamily(life, origin.family)
	self:rollHousehold(life, origin)
	self:rollWorld(life, nil, true)

	-- difficulty (pack.difficulties), picked before the life starts
	if pack.difficulties then
		life.difficulty = if type(opts.difficulty) == "string" and type(pack.difficulties[opts.difficulty]) == "table" and opts.difficulty ~= "order" then opts.difficulty else pack.difficulties.default
	end
	-- events this player met in their last lives (the server keeps the list)
	if type(opts.stale) == "table" then
		life.stale = {}
		for _, id in opts.stale do
			if type(id) == "string" and self.eventsById[id] then
				life.stale[id] = true
			end
		end
	end
	-- the main storyline: one per life that starts from birth (opts.story = id forces one,
	-- false turns it off; opts.avoidStories are the ones this player lived recently)
	local storyDef = nil
	if pack.storylines and opts.story ~= false and not (startMode and startMode.start) then
		storyDef = (type(opts.story) == "string" and self.storylinesById[opts.story]) or self:rollStoryline(life, opts.avoidStories)
		if storyDef then
			life.story = storyDef.id
			life.storyGoal = storyDef.goal
			life.flags[storyDef.id] = true
		end
	end

	-- a talent: one random trait by rarity (the server rolls it first, so the player sees it)
	life.affinities = self:cleanAffinities(opts.affinities)
	if pack.affinityRoll and pack.affinities then
		-- nobody picks their sins: the City deals them
		local pool = table.clone(pack.affinities.order)
		life.affinities = {}
		for _ = 1, math.min(pack.affinityRoll, #pool) do
			local i = Rng.int(life, 1, #pool)
			table.insert(life.affinities, table.remove(pool, i))
		end
	end
	local talentEntry = nil
	if pack.talents then
		local tid = opts.talent
		local tdef = type(tid) == "string" and self:traitDef(tid)
		if not (tdef and tdef.talent) then
			tid = self:rollTalent(life, nil, life.affinities)
			tdef = tid and self:traitDef(tid)
		end
		if tid and tdef then
			-- (v0.12) a rare gift may sleep until a rolled age (Engine/Talent.luau)
			Talent.grant(self, life, tid, tdef)
			local tier = self:talentTier(tdef.talent)
			local asleep = Talent.asleep(self, life)
			talentEntry = {
				kind = "system",
				tone = "strange",
				text = "Talent: " .. tdef.name .. (if tier then " (" .. tier.name .. ")" else "") .. ". " .. (tdef.desc or "")
					.. (if asleep then " It's asleep in you for now. It will wake when it's ready." else ""),
			}
		end
	end

	local report = newReport()
	self:pushChapter(life, report)
	self:push(life, report, { kind = "year", text = "Born", year = life.year })
	self:push(life, report, { kind = "log", text = self:render(life, origin.birth or "You were born in {zone}.") .. " They named you " .. life.first .. "." })
	if talentEntry then
		self:push(life, report, talentEntry)
	end
	for _, line in perkLines do
		self:push(life, report, { kind = "system", tone = "good", text = line })
	end
	if storyDef then
		self:push(life, report, { kind = "story", title = storyDef.name, text = storyDef.hook or "", tone = storyDef.tone })
	end
	-- a game mode that starts later in life (pack.modes)
	local mode = self:modeDef(opts.mode)
	if mode and mode.start then
		self:applyModeStart(life, mode, report)
	end
	self:rollAmbitions(life)
	return life, report
end

-- The family you're born into, rolled by weight from the ones you've unlocked.
-- `want` = { district = id?, side = id? }: a life that must start in a given District (or on a
-- given side of the wall) never rolls a family that lives somewhere else.
function Sim:rollOrigin(life, allowed, want: any?)
	local list, weights = {}, {}
	for _, o in self.pack.origins do
		local ok = if allowed then table.find(allowed, o.id) ~= nil else (o.glowCost or 0) <= 0
		if want then
			if want.district and o.district and o.district ~= want.district then
				ok = false
			end
			if want.side and o.side and o.side ~= want.side then
				ok = false
			end
		end
		-- some families only exist in some years (an L Corp family needs an L Corp)
		if o.bornBefore and life.year >= o.bornBefore then
			ok = false
		end
		if o.bornAfter and life.year < o.bornAfter then
			ok = false
		end
		if ok and (o.weight or 10) > 0 then
			table.insert(list, o)
			table.insert(weights, o.weight or 10)
		end
	end
	local idx = Rng.weighted(life, weights)
	return if idx then list[idx] else nil
end

-- ── the glossary (pack.glossary): City words worth a line of explanation ────
-- { term, match = { "lowercase words" }, text }. An event card offers up to three of the
-- terms in its text, each one the first two times a life meets it.
-- Does `hay` hold `needle` as a whole word, capitals and all? ("the Middle" is the Finger;
-- "the middle of it" is not.) With `inside`, a hit that opens a sentence doesn't count: every
-- word wears a capital there, so "Sweepers get a free lesson" says nothing about the Night.
-- With `alone`, a hit that runs on into another capitalised word doesn't count either.
local function holdsWord(hay: string, needle: string, inside: boolean?, alone: boolean?): boolean
	local from = 1
	while true do
		local s, e = string.find(hay, needle, from, true)
		if not s or not e then
			return false
		end
		local before = if s > 1 then string.sub(hay, s - 1, s - 1) else " "
		local after = if e < #hay then string.sub(hay, e + 1, e + 1) else " "
		if not string.match(before, "[%w]") and not string.match(after, "[%w]") then
			local rest = string.sub(hay, e + 1, e + 5)
			if alone and (string.match(rest, "^ %u") or string.match(rest, "^ of %u")) then
				-- "the Head Teacher", "the Head of Research", "the Night Market": part of a longer
				-- name, not ours
			elseif not inside then
				return true
			else
				-- what stands before it, spaces aside: nothing, the end of a sentence, or an
				-- opening quote or bracket means this word starts one
				local lead = string.match(string.sub(hay, 1, s - 1), "(%S?)%s*$")
				if lead ~= "" and not string.find(".!?:;\"'(", lead, 1, true) and string.byte(lead) < 128 then
					return true
				end
			end
		end
		from = s + 1
	end
end

-- "The Head Teacher", "Dad and the Night": a headline capitalises every word, so a name that
-- leans on its article ("the Head") proves nothing there
local function leansOnArticle(word: string): boolean
	local first = string.match(word, "^(%a+) ")
	if not first then
		return false
	end
	first = string.lower(first)
	return first == "the" or first == "a" or first == "an" or first == "your"
end

--[[ A glossary entry says what to look for in a card's words:
	match: NAMES. A piece written with a capital (or a digit) must appear exactly as written, as
	       a whole word: anywhere in the body, and in the headline too unless it leans on an
	       article ("the Head"). A piece in all lowercase is loose (any case, any part of a
	       word), for words that only ever mean the one thing ("backstreets").
	mid:   ordinary words that are a name only when they wear a capital INSIDE a sentence
	       ("a Wing", "the Office"). Looked for in the body only, never the headline (headlines
	       capitalise everything), and never as the first word of a sentence.
	No list at all: the term itself, as a name. ]]
function Sim:termMatches(g: any, title: string, body: string, lower: string): (boolean, string?)
	for _, word in g.match or (if g.mid then {} else { g.term }) do
		if string.find(word, "[%u%d]") then
			-- a name that leans on its article stands alone: "the Head", never "the Head Teacher"
			local leans = leansOnArticle(word)
			if holdsWord(body, word, false, leans) or (not leans and holdsWord(title, word)) then
				return true, word
			end
		elseif string.find(lower, word, 1, true) then
			return true, word
		end
	end
	for _, word in g.mid or {} do
		if holdsWord(body, word, true) then
			return true, word
		end
	end
	return false, nil
end

function Sim:termsIn(life, event)
	local glossary = self.pack.glossary
	if not glossary then
		return nil
	end
	-- the words this life is shown (its own variant of each line), before names are filled in:
	-- a sister called Hana is not the Association
	local function shown(text: any): string
		if type(text) == "table" then
			return self:variant(life, text)
		end
		return if type(text) == "string" then text else ""
	end
	local title = shown(event.title)
	local body = shown(event.text)
	for _, d in event.dialogue or {} do
		body ..= "\n" .. shown(d.line)
	end
	local lower = string.lower(title .. " " .. body)
	local seen = life.termsSeen or {}
	-- event.terms: the card is about these, whether or not its words name them
	local named = {}
	for _, term in if type(event.terms) == "table" then event.terms else {} do
		named[term] = true
	end
	local out = {}
	for pass = 1, 2 do
		for _, g in glossary do
			if #out >= 3 then
				break
			end
			if (named[g.term] == true) == (pass == 1) and (seen[g.term] or 0) < 2 then
				if pass == 1 or self:termMatches(g, title, body, lower) then
					table.insert(out, { term = g.term, text = g.text })
				end
			end
		end
	end
	return if #out > 0 then out else nil
end

-- the player has now seen these terms on a card (called when the card is answered)
function Sim:markTerms(life, event)
	local terms = self:termsIn(life, event)
	if terms then
		life.termsSeen = life.termsSeen or {}
		for _, t in terms do
			life.termsSeen[t.term] = (life.termsSeen[t.term] or 0) + 1
		end
	end
end

-- ── chapters (pack.chapters): a title card when a life reaches each age ─────

function Sim:chapterAt(age: number)
	local current, index = nil, 0
	for i, ch in self.pack.chapters or {} do
		if ch.age <= age then
			current, index = ch, i
		end
	end
	return current, index
end

function Sim:chapterView(life)
	local ch, index = self:chapterAt(life.age)
	if not ch then
		return nil
	end
	return { word = self.pack.chapterWord or "Chapter", num = ch.num or tostring(index), title = self:render(life, ch.title), line = self:render(life, ch.line or ""), index = index }
end

-- the family you were born into, for the birth reveal and the You tab
function Sim:originView(life)
	local o = self.originsById[life.origin or ""]
	if not o then
		return nil
	end
	local total, weight = 0, o.weight or 10
	for _, other in self.pack.origins do
		total += other.weight or 10
	end
	return { id = o.id, name = o.name, desc = o.desc, odds = if total > 0 then weight / total else nil }
end

function Sim:pushChapter(life, report)
	local pack = self.pack
	local story = self:storyDef(life)
	for i, ch in pack.chapters or {} do
		if ch.age == life.age then
			-- (v0.12) a Canto's title and line can be lists: every life gets its own (Sim:variant)
			local line = (story and story.cantos and story.cantos[i]) or self:render(life, ch.line or "")
			self:push(life, report, { kind = "chapter", word = pack.chapterWord or "Chapter", num = ch.num or tostring(i), title = self:render(life, ch.title), text = line, index = i })
		end
	end
	for i, iv in pack.intervallos or {} do
		if iv.age == life.age then
			self:push(life, report, { kind = "intervallo", word = pack.interludeWord or "Interlude", num = iv.num or tostring(i), title = iv.title, text = iv.line or "", index = i })
		end
	end
end

-- ── stakes: what a clash can win or cost, scaled by the approach ────────────




--[[ A short list of what a result changes: { { key, min, max } }, for the chips on a card.
	With a `life`, the numbers are what THIS life would really be given right now (the same
	sums Effects.apply does: talents, age, how high the stat already is, toughness, a quick
	study's bonus...), so a chip never promises more or less than what lands. `ctx` is what
	apply would be handed: { activity = true, training = n, target = relation }.
	Without a life they are the numbers as written (for anything not about one life). ]]


-- what an activity or a job is done under (Effects.apply is handed the same)
function Sim:workCtx(life)
	local training = self:perkSum(life, "training") + self:carried(life, "training")
	return { activity = true, training = if training > 0 then training else nil }
end

-- ── who's who: foes on the fight screen, faces in dialogue ──────────────────

local function mergeLook(base, over)
	local out = table.clone(base)
	for k, v in over do
		out[k] = v
	end
	return out
end

-- the pack's foe for a clash: named by spec.enemy, else the first foes.match word found in
-- the foe's name
function Sim:foeDef(spec)
	local foes = self.pack.foes
	local name = if type(spec.foe) == "string" then spec.foe else "Someone"
	local def = foes and spec.enemy and foes[spec.enemy]
	if not def and foes then
		local lower = string.lower(name)
		for _, m in foes.match or {} do
			if string.find(lower, m[1], 1, true) then
				def = foes[m[2]]
				break
			end
		end
	end
	return def, name
end

-- a foe's temper (pack.tempers): the clash's own, the foe's, or, for a stranger, one that
-- follows from their name (so the same stranger always fights the same way)
function Sim:temperOf(spec: any): string?
	local tempers: any = self.pack.tempers
	if not tempers or not (spec and spec.fight) then
		return nil
	end
	if spec.temper then
		return spec.temper
	end
	local def, name = self:foeDef(spec)
	if def and def.temper then
		return def.temper
	end
	local h = 0
	for i = 1, #name do
		h = (h * 31 + string.byte(name, i)) % 9973
	end
	return tempers.order[1 + h % #tempers.order]
end

function Sim:foeFor(spec)
	local def, name = self:foeDef(spec)
	if def then
		return {
			id = def.id,
			name = name,
			kind = def.kind or "human",
			look = if def.kind == "creature" then nil else Avatar.sanitize(self.pack, mergeLook(Avatar.randomLook(self.pack, hashRoll(def.id)), def.look or {})),
			shape = def.shape,
			color = def.color,
			eye = def.eye,
			barks = def.barks,
		}
	end
	return { id = "stranger", name = name, kind = "human", look = Avatar.randomLook(self.pack, hashRoll(name)) }
end

-- (v0.14) someone in a cutscene: a look of their own, the same every time for the same name
function Sim:npcAppearance(name: string, look: any?, age: number?): any
	local base = Avatar.randomLook(self.pack, hashRoll(name or "someone"))
	return { look = Avatar.sanitize(self.pack, mergeLook(base, look or {})), age = age or 30, form = "human" }
end

-- (v0.14) an event's `scene` (a cutscene played before its card), ready for the client:
-- { set, time, title, kicker, line, reply, color, other = { name, role, pose, appearance | creature } }
function Sim:sceneView(life: any, event: any): any
	local s = event and event.scene
	-- (v0.14) time with someone from your own life ("spend time" scenes): they're in it, as you
	-- know them, and the card's first line is the narration. A short scene, not every time.
	local generated = false
	if type(s) ~= "table" and event and event.social and life.sceneRel then
		local sr = self:relationById(life, life.sceneRel)
		if sr and not sr.userId then
			s = { other = { relId = sr.id }, line = event.text, voice = "narrator" }
			generated = true
		end
	end
	if type(s) ~= "table" then
		return nil
	end
	local other = s.other or {}
	local who = nil
	-- someone from your own life (other.rel = "rival", "partner"...): as you know them
	local rel = if other.relId ~= nil then self:relationById(life, other.relId)
		elseif type(other.rel) == "string" then self:firstRelation(life, other.rel)
		else nil
	if rel then
		who = {
			name = rel.first,
			role = if other.role then self:render(life, other.role) else nil,
			pose = other.pose,
			appearance = { look = rel.look or Avatar.randomLook(self.pack, hashRoll(rel.first .. tostring(rel.id))), age = rel.age or 30, form = "human" },
		}
	elseif type(other.name) == "string" then
		local name = self:render(life, other.name)
		who = { name = name, role = if other.role then self:render(life, other.role) else nil, pose = other.pose }
		if other.foe then
			local f = self:foeFor({ enemy = other.foe, foe = name })
			if f.kind == "creature" then
				who.creature = { shape = f.shape, color = f.color, eye = f.eye, seed = f.id, name = name }
			else
				who.appearance = { look = f.look, age = other.age or 30, form = "human" }
			end
		elseif other.creature then
			who.creature = other.creature
		else
			who.appearance = self:npcAppearance(name, other.look, other.age)
		end
	end
	local d = self:districtDef(life)
	return {
		set = s.set or event.art,
		time = s.time,
		title = self:render(life, s.title or event.title or ""),
		kicker = if s.kicker then self:render(life, s.kicker) else (d and d.name or nil),
		line = if s.line then self:render(life, s.line) else nil,
		voice = s.voice,
		reply = if s.reply then self:render(life, s.reply) else nil,
		color = s.color,
		stand = s.stand,
		other = who,
		short = generated or nil,
		key = event.id .. ":" .. tostring(life.age) .. (if generated then ":" .. tostring(other.relId) else ""),
	}
end

-- a dialogue speaker: { name, look?, kind = "cast"|"foe"|"you"|"rel"|"name", creature? }
function Sim:speaker(life, who: string)
	local pack = self.pack
	if who == "you" then
		return { name = life.first, look = life.look, kind = "you" }
	end
	local token = string.match(who, "^{(.-)}$")
	if token then
		local rel = self:firstRelation(life, token)
		if rel then
			return { name = rel.first, look = rel.look, kind = "rel" }
		end
		return { name = self:render(life, who), kind = "name" }
	end
	local cast = pack.cast and pack.cast[who]
	if cast then
		-- someone with several names has a different face in each life too (same clothes)
		local varied = type(cast.names) == "table" and #cast.names > 0
		local base = Avatar.randomLook(pack, hashRoll(if varied then tostring(life.id) .. ":" .. who else who))
		local look = base
		if cast.look then
			local keep = cast.look
			if varied then
				keep = table.clone(cast.look)
				keep.skin, keep.eyes = nil, nil
			end
			look = Avatar.sanitize(pack, mergeLook(base, keep))
		end
		return { name = self:castName(life, cast), title = if cast.title then self:render(life, cast.title) else nil, look = look, kind = "cast" }
	end
	local foe = pack.foes and pack.foes[who]
	if foe then
		local f = self:foeFor({ enemy = who, foe = foe.name })
		return { name = foe.name, look = f.look, kind = "foe", creature = if foe.kind == "creature" then { shape = foe.shape, color = foe.color, eye = foe.eye } else nil }
	end
	return { name = self:render(life, who), kind = "name" }
end

function Sim:dialogueView(life, list, ctx)
	local out = {}
	for _, d in list or {} do
		if type(d) == "table" and type(d.who) == "string" and (type(d.line) == "string" or type(d.line) == "table") then
			local sp = self:speaker(life, d.who)
			sp.line = self:render(life, d.line, ctx)
			table.insert(out, sp)
		end
	end
	return out
end

function Sim:pushDialogue(life, report, list, ctx)
	for _, sp in self:dialogueView(life, list, ctx) do
		self:push(life, report, { kind = "dialogue", who = sp.name, text = sp.line, look = sp.look, speaker = sp.kind, creature = sp.creature })
	end
end

-- Heirs: living relations whose kind is marked heir (children by default).
function Sim:heirs(life)
	local list = {}
	for _, rel in life.relations do
		local def = self.pack.relationKinds[rel.kind]
		if rel.alive and def and def.heir then
			table.insert(list, rel)
		end
	end
	return list
end

function Sim:newLifeFromHeir(parent, relId: number, seed: number)
	local pack = self.pack
	local heir = nil
	for _, rel in parent.relations do
		if rel.id == relId and rel.alive then
			heir = rel
		end
	end
	if not heir then
		return nil
	end
	local life = blankLife(self, seed)
	life.origin = "heir"
	life.heirOf = parent.first .. " " .. parent.last
	life.first = heir.first
	life.last = heir.last
	life.look = heir.look or Avatar.randomLook(pack, self:lifeRoll(life), parent.look)
	life.age = heir.age
	life.year = parent.year
	life.bornYear = parent.year - heir.age
	life.district = parent.district or life.district
	life.side = parent.side or life.side
	life.bornSide = life.side
	life.money = math.floor(math.max(0, parent.money) * 0.6)
	life.sanity = Util.clamp((pack.stats.sanity.start or 0) - 6, pack.stats.sanity.min, pack.stats.sanity.max)
	life.world = Util.deepCopy(parent.world)
	for _ = 1, math.min(heir.age, 17) do
		for _ = 1, self.growPicks do
			local k = Rng.pick(life, self.growStats)
			life.stats[k] = math.min(100, life.stats[k] + Rng.int(life, 1, 2))
		end
	end
	for _, key in self.coreStats do
		life.stats[key] = Util.clamp(life.stats[key] + math.floor((parent.stats[key] or 0) * 0.1), 0, self:statCap(life, key))
	end
	life.stats[self.vital] = math.max(life.stats[self.vital], 45)
	for _, rel in parent.relations do
		if rel.alive and rel.id ~= relId then
			if rel.kind == "child" then
				table.insert(life.relations, {
					id = life.nextRelId,
					kind = "sibling",
					first = rel.first,
					last = rel.last,
					age = rel.age,
					bond = rel.bond,
					alive = true,
					look = rel.look,
				})
				life.nextRelId += 1
			elseif rel.userId then
				-- linked friends carry over to the next generation
				local copy = Util.deepCopy(rel)
				copy.id = life.nextRelId
				life.nextRelId += 1
				table.insert(life.relations, copy)
			end
		end
	end
	life.flags.heir = true
	life.generation = (parent.generation or 1) + 1
	-- teaching pays off: each lesson the parent gave adds to the heir's mind
	local lessons = math.min(6, heir.taught or 0)
	if lessons > 0 then
		local work, will = self.roles.work, self.roles.will
		life.stats[work] = Util.clamp(life.stats[work] + lessons * 2, 0, self:statCap(life, work))
		life.stats[will] = Util.clamp(life.stats[will] + lessons, 0, self:statCap(life, will))
	end
	-- heirlooms: the parent's gear passes down
	for slot, gid in parent.gear or {} do
		if self.pack.gear and self.pack.gear[gid] then
			life.gear[slot] = gid
		end
	end
	-- the family way of fighting passes down, and some traits run in the family
	if parent.style and self.pack.styles and self.pack.styles[parent.style] and (life.age >= 12 or self.pack.styleAtBirth ~= false) then
		life.style = parent.style
	elseif self.pack.styleAtBirth == false and life.age < 12 then
		life.style = nil
	end
	life.mastery = math.floor((parent.mastery or 0) / 2)
	if self.pack.schools then
		life.school = if life.style then parent.school else nil
		life.mastery = math.min(life.mastery, self.pack.outsideMastery or 2)
	end
	-- the family library: unread books pass down, and every heir is born with a talent of their own
	for _, b in parent.books or {} do
		if self:bookDef(b) then
			life.books = life.books or {}
			table.insert(life.books, b)
		end
	end
	-- the family's sins carry down, and lean the heir's talent the same way
	life.affinities = table.clone(parent.affinities or {})
	if self.pack.talents then
		local tid = self:rollTalent(life, nil, life.affinities)
		local tdef = tid and self:traitDef(tid)
		if tid and tdef then
			Talent.grant(self, life, tid, tdef)
		end
	end
	for _, id in parent.traits or {} do
		local def = self:traitDef(id)
		if def and def.inherit then
			self:addTrait(life, id)
		end
	end
	life.codex = table.clone(parent.codex or {})
	life.dailyDay = parent.dailyDay

	self:rollAmbitions(life)
	local report = newReport()
	self:push(life, report, { kind = "year", text = "Age " .. life.age, year = life.year })
	local inherited = if life.money > 0 then (" You inherited " .. life.money .. " " .. pack.meta.currency .. ".") else ""
	self:push(life, report, {
		kind = "log",
		text = "You are " .. life.first .. ", child of " .. parent.first .. " " .. parent.last .. ", in " .. self:zoneLabel(life) .. "." .. inherited,
	})
	local heirlooms = {}
	for _, g in self:gearIn(life) do
		table.insert(heirlooms, g.def.name)
	end
	if #heirlooms > 0 then
		self:push(life, report, { kind = "system", tone = "good", text = "Heirlooms: " .. table.concat(heirlooms, ", ") .. "." })
	end
	if (life.generation or 1) >= 2 then
		self:push(life, report, { kind = "system", text = "Generation " .. life.generation .. " of the " .. life.last .. " line." })
	end
	return life, report
end

-- ── yearly simulation ───────────────────────────────────────────────────────

function Sim:passive(life: any, report: any)
	local vital = self.vital
	local pack = self.pack
	local deltas = {}
	local notes = {}
	local extra = {}
	local district = self:districtDef(life)
	local side = self:sideDef(life)
	local adult = life.age >= (pack.meta.adultAge or 18)

	local function addStat(key: string, d: number)
		if d == 0 then
			return
		end
		local before = life.stats[key]
		life.stats[key] = Util.clamp(before + d, 0, math.max(before, self:statCap(life, key)))
		local real = life.stats[key] - before
		if real ~= 0 then
			deltas[key] = (deltas[key] or 0) + real
		end
	end

	local function applyYearly(tbl)
		if not tbl then
			return
		end
		for _, key in self.coreStats do
			if tbl[key] then
				addStat(key, Rng.roll(life, tbl[key]))
			end
		end
		if tbl.sanity then
			self:changeSanity(life, Rng.roll(life, tbl.sanity), deltas)
		end
		if tbl.money then
			local d = Rng.roll(life, tbl.money)
			life.money += d
			deltas.money = (deltas.money or 0) + d
		end
	end

	-- growing up
	if life.age <= 17 then
		for _ = 1, self.growPicks do
			addStat(Rng.pick(life, self.growStats), Rng.int(life, 1, 2))
		end
		addStat(vital, Rng.int(life, 0, 2))
	end

	-- the body heals when young and wears down when old (v0.17: from its own lifespan; an
	-- ageless form never wears down, and a Bloodfiend's blood grows older and stronger)
	local wear = Body.wearYear(self, life)
	if wear ~= 0 then
		addStat(vital, wear)
	end
	Body.elderBlood(self, life, extra)

	-- where you live
	applyYearly(side.yearly)
	applyYearly(district.yearly and district.yearly[life.side])
	if adult and side.wear and side.wear ~= 0 then
		self:changeSanity(life, -side.wear, deltas)
	end
	applyYearly(pack.forms[life.form] and pack.forms[life.form].yearly)

	-- gear and lasting conditions
	for _, g in self:gearIn(life) do
		applyYearly(g.def.yearly)
	end
	if life.conditions and #life.conditions > 0 then
		local still = {}
		for _, c in life.conditions do
			local def = pack.conditions and pack.conditions[c.id]
			if def then
				applyYearly(def.yearly)
				c.years -= 1
				if c.years > 0 then
					table.insert(still, c)
				else
					table.insert(extra, { kind = "system", tone = "good", text = def.healLog or (def.name .. " finally faded.") })
				end
			end
		end
		life.conditions = still
	end

	-- work
	if life.career then
		local c = life.career
		local def = pack.careers[c.id]
		c.years += 1
		c.rankYears += 1
		local salary = self:salaryOf(life)
		if salary > 0 then
			life.money += salary
			deltas.money = (deltas.money or 0) + salary
			table.insert(notes, "Earned " .. salary .. " " .. pack.meta.currency .. " as " .. aOrAn(def.ranks[c.rank]) .. ".")
		end
		applyYearly(def.yearly)
		-- the work you've done counts: enough jobs (pack.jobs.perRank) make it certain, and a
		-- year sooner; otherwise it's the stat, the years, and whether anyone noticed
		local jobsNeed = pack.jobs and (pack.jobs.perRank or 2) or nil
		local worked = jobsNeed ~= nil and (c.jobs or 0) >= jobsNeed
		local years = math.max(1, (def.yearsPerRank or 2) - (if worked then 1 else 0))
		if c.rank < #def.ranks and c.rankYears >= years then
			local need = if def.promoteAt then def.promoteAt[c.rank] or 0 else 0
			local have = life.stats[def.promoteStat or self.roles.work] or 0
			if have >= need and (worked or Rng.chance(life, 0.6)) then
				self:promote(life, extra)
				if life.career then
					life.career.jobs = 0
				end
			end
		end
	end

	-- cost of living
	if adult then
		local cost = self:livingCost(life)
		if cost > 0 then
			life.money -= cost
			deltas.money = (deltas.money or 0) - cost
			table.insert(notes, "Rent in " .. (side.short or life.side) .. " cost " .. cost .. " " .. pack.meta.currency .. ".")
		end
		if life.money < 0 then
			self:changeSanity(life, -2, deltas)
			table.insert(notes, "You ended the year in debt.")
			life.debtYears = (life.debtYears or 0) + 1
			-- sides that evict debtors (the Charter) serve a notice first, then throw
			-- you out to the arrival side once the debt outlasts the grace years
			if side.evictOnDebt and life.side ~= self:arrivalSide() then
				local grace = side.evictGrace or 1
				if life.debtYears > grace then
					local evicted = {}
					if self:moveSide(life, self:arrivalSide(), evicted) then
						self:changeSanity(life, -6, deltas)
						table.insert(extra, {
							kind = "system",
							tone = "bad",
							text = "You couldn't pay. The company evicted you to " .. self:sideDef(life).name .. ".",
						})
						self:highlight(life, "Evicted from " .. (side.name or life.side))
						for _, e in evicted do
							table.insert(extra, e)
						end
					end
				elseif life.debtYears == 1 then
					table.insert(extra, {
						kind = "system",
						tone = "bad",
						text = string.format(
							"The company served you a notice to quit. Get out of debt within %d year%s or you're out.",
							grace,
							if grace == 1 then "" else "s"
						),
					})
				end
			end
		elseif (life.debtYears or 0) > 0 then
			if side.evictOnDebt and life.side ~= self:arrivalSide() then
				table.insert(extra, { kind = "system", tone = "good", text = "You cleared your debt. The notice to quit was torn up." })
			end
			life.debtYears = 0
		end
	end

	-- mood drifts back toward its resting point
	local cfg = pack.stats.sanity
	local rest = cfg.rest or cfg.start or 0
	if life.sanity > rest then
		self:changeSanity(life, -math.min(cfg.drift or 1, life.sanity - rest), deltas)
	elseif life.sanity < rest then
		self:changeSanity(life, math.min(cfg.drift or 1, rest - life.sanity), deltas)
	end

	life.peakMoney = math.max(life.peakMoney or 0, life.money)

	if #notes > 0 or next(deltas) ~= nil then
		self:push(life, report, {
			kind = "summary",
			text = table.concat(notes, " "),
			deltas = if next(deltas) then deltas else nil,
		})
	end

	-- the people around you get older too (linked friends age with their own lives)
	for _, rel in life.relations do
		if rel.alive and rel.userId == nil then
			rel.age += 1
			if rel.age >= 60 and Rng.chance(life, (rel.age - 58) * 0.012) then
				self:relationDied(life, rel, extra)
			end
		end
	end

	for _, entry in extra do
		self:push(life, report, entry)
	end

	-- work hazards happen after the summary so they read as their own beat
	if life.career and life.alive then
		local def = pack.careers[life.career.id]
		if def.hazard and Rng.chance(life, def.hazard.chance or 0) then
			life.scene = self:careerName(life)
			Effects.apply(self, life, def.hazard.result, report)
			life.scene = nil
		end
	end
end

-- The yearly roll for bad luck that comes with where you live.
function Sim:rollHazard(life, report)
	local pack = self.pack
	if not pack.hazards or not life.alive then
		return
	end
	local chance = (self:sideDef(life).hazardChance or 0) * (self:districtDef(life).danger or 1)
	-- someone usually keeps the youngest out of the worst of it
	if life.age < 12 then
		chance *= self.pack.childHazard or 0.5
	end
	for _, g in self:gearIn(life) do
		chance *= g.def.hazardGuard or 1
	end
	-- Luck: a bad year misses the lucky a little more often (up to 40% fewer)
	if self.roles.luck then
		chance *= 1 - math.min(0.4, self:luckOf(life) / 150)
	end
	local diff = self:difficultyDef(life)
	if diff then
		chance *= diff.hazard or 1
	end
	-- a hard year is a dangerous one
	local crisis = self:crisisDef(life)
	if crisis then
		chance *= crisis.hazard or 1
	end
	-- and a District players have made safer is safer
	local hold = Renown.holdOf(self, life.district)
	if hold and hold.safety then
		chance *= math.clamp(1 - 0.08 * hold.safety, 0.5, 1.4)
	end
	-- and so is a home with a good door (pack.homes: safety), or hired help (condition.hazardMult)
	chance *= 1 - Market.homeSafety(self, life)
	for _, c in life.conditions or {} do
		local cdef = self.pack.conditions and self.pack.conditions[c.id]
		if cdef and type(cdef.hazardMult) == "number" then
			chance *= cdef.hazardMult
		end
	end
	if not Rng.chance(life, math.min(0.75, chance)) then
		return
	end
	local list, weights = {}, {}
	for _, h in pack.hazards do
		local sideOk = h.side == nil or h.side == life.side
		local districtOk = h.district == nil or Util.contains(Util.asList(h.district), life.district)
		if sideOk and districtOk and Conditions.check(h.when, life, pack, { noChance = true }) then
			table.insert(list, h)
			table.insert(weights, h.weight or 10)
		end
	end
	local idx = Rng.weighted(life, weights)
	if not idx then
		return
	end
	local h = list[idx]
	local hazardTitle = self:render(life, h.title)
	self:push(life, report, { kind = "event", title = hazardTitle, hazard = true, thread = "danger" })
	life.scene = hazardTitle
	Effects.apply(self, life, h.result, report)
	life.scene = nil
end

function Sim:eventWeight(life, event): number
	local w = event.weight or 10
	-- Luck: `lucky = true` events (a find, a windfall) come more often to the lucky, and
	-- `unlucky = true` ones less
	if w > 0 and (event.lucky or event.unlucky) and self.roles.luck then
		local f = 0.5 + self:luckOf(life) / 20 -- 0.5x at 0, 1x at 10, 2x at 30, 3x at 50
		w = if event.lucky then w * f else w / f
	end
	-- an event that belongs to this District comes up more than the City-wide ones
	if w > 0 and event.when and event.when.district and self.pack.districtEventBoost then
		w *= self.pack.districtEventBoost
	end
	-- NATURE: what you lean on is what the City sends you (a strong life gets challenged, a
	-- charming one gets offers)
	if w > 0 and self.pack.natureDraw and self.eventDraws then
		local nature = self:nature(life)
		local draws = nature and self.eventDraws[event.id]
		if draws and draws[nature] then
			w *= self.pack.natureDraw
		end
	end
	-- seen in this player's last lives: much rarer in this one, so lives don't repeat
	if w > 0 and life.stale and life.stale[event.id] and not event.always and not event.story then
		w *= 0.12
	end
	-- (v0.15) this life's own City (fateOf): left alone are the cards that continue something
	-- (a flag, a story, a chronicle echo), a career's own cards, and the ones always in play
	if w > 0 and self.pack.fate ~= false and life.id and not event.always and not event.story and not event.fateFree then
		local wh = event.when
		if not (wh and (wh.flags or wh.anyFlags or wh.career or wh.chronicle)) then
			w *= fateOf(tostring(life.id), event.id)
		end
	end
	-- (v0.13) seen already in this life: each time it has come up makes it rarer again (the
	-- second time at 40%, the third at 16%...), so a long life keeps meeting new things
	local seenN = life.timesSeen and life.timesSeen[event.id]
	if w > 0 and seenN and seenN > 0 and not event.always and not event.story then
		w *= 0.4 ^ seenN
	end
	-- (v0.18) what the life is about right now (Engine/Focus.luau)
	w = Focus.weight(self, life, event, w)
	-- (v0.18) the City is harder: dangerous cards come more often (pack.hardness.dangerWeight)
	local H = (self.pack :: any).hardness
	if w > 0 and H and event.tags and (H.dangerWeight or 1) ~= 1 and life.age >= (H.fromAge or 14) then
		for _, tag in event.tags do
			if tag == "danger" then
				w *= H.dangerWeight
				break
			end
		end
	end
	if w > 0 and event.dread and H and H.dreadWeight then
		w *= H.dreadWeight
	end
	-- this year's mood, and last year's themes (Engine/Mood.luau)
	w = Mood.weight(self, life, event, w)
	if w <= 0 or not event.tags then
		return w
	end
	local side = self:sideDef(life)
	local district = self:districtDef(life)
	local ageDanger = 1
	for _, step in (self.pack :: any).dangerByAge or {} do
		if life.age >= step.from then
			ageDanger = step.mult
		end
	end
	for _, tag in event.tags do
		if tag == "danger" then
			w *= (side.danger or 1) * (district.danger or 1) * ageDanger
		end
		if side.tagWeights and side.tagWeights[tag] then
			w *= side.tagWeights[tag]
		end
		if district.tagWeights and district.tagWeights[tag] then
			w *= district.tagWeights[tag]
		end
		for id in self.worldActive do
			local we = self.pack.worldEvents and self.pack.worldEvents[id]
			if we and we.tagWeights and we.tagWeights[tag] then
				w *= we.tagWeights[tag]
			end
		end
	end
	return w
end

function Sim:linkedOk(life, when): boolean
	if not when or not (when.linked or when.linkedRough) then
		return true
	end
	return self:focusLinked(life, when.linkedRough == true) ~= nil
end

function Sim:eligible(life, event): boolean
	if (event.weight or 10) <= 0 then
		return false
	end
	local last = life.history[event.id]
	if last ~= nil then
		if event.once then
			return false
		end
		if life.age - last < (event.cooldown or 3) then
			return false
		end
	end
	if event.story and life.story ~= event.story then
		return false
	end
	if not self:gateOpen(life, event) then
		return false
	end
	return (Conditions.check(event.when, life, self.pack, { noChance = true }))
end

-- ── knowing the City (pack.storyGates) ──────────────────────────────────────

function Sim:knowsGate(life, g): boolean
	if g.flag == nil or life.flags[g.flag] then
		return true
	end
	if g.openAge and life.age >= g.openAge then
		return true
	end
	if g.careers and life.career and table.find(g.careers, life.career.id) then
		return true
	end
	return false
end

-- an event behind a gate waits for the gate's age (unless it sets its own) and knowledge
function Sim:gateOpen(life, event): boolean
	local g = self.gateOf[event.id]
	if not g then
		return true
	end
	local w = event.when
	if g.minAge and life.age < g.minAge and not (w and w.minAge ~= nil) then
		return false
	end
	return self:knowsGate(life, g)
end

-- Sets a "knows_" flag; the first time, the report says what the life just learned about.
function Sim:learn(life, flag: string, report)
	local g = Known.set(self, life, flag)
	if g and g.name and report then
		self:push(life, report, { kind = "learned", title = g.name, text = g.blurb or "", emblem = g.emblem, flag = flag })
	end
end

-- the same, for a result: returns the "learned" entry to show (or nil when it wasn't news)
function Sim:learnEntry(life, flag: string)
	local g = Known.set(self, life, flag)
	if g and g.name then
		return { kind = "learned", title = g.name, text = g.blurb or "", emblem = g.emblem, flag = flag }
	end
	return nil
end

-- seeing an event teaches: the gate holding it, the gates it `teaches`, the names it says
function Sim:learnFrom(life, event, report)
	Known.learnFrom(self, life, event, report)
end

function Sim:learnPlace(life)
	Known.learnPlace(self, life)
end

function Sim:learnCareer(life, careerId: string, report)
	for _, g in self.pack.storyGates or {} do
		if g.flag and g.careers and table.find(g.careers, careerId) then
			self:learn(life, g.flag, report)
		end
	end
end

-- what the life knows of the City, with its standing with each (Known.view)
function Sim:knownView(life)
	return Known.view(self, life)
end

-- ── the main storyline (pack.storylines) ───────────────────────────────────

function Sim:storyDef(life)
	return life.story and self.storylinesById[life.story] or nil
end

-- Picks the life's storyline: by weight, among those whose `when` fits this birth.
-- `avoid` (ids the player lived recently) are a lot less likely, so stories don't repeat.
function Sim:rollStoryline(life, avoid)
	local list, weights = {}, {}
	local inPlay = self:storiesInPlay()
	for _, sl in self.pack.storylines or {} do
		if (sl.act or 1) == 1 and (sl.weight or 10) > 0 and Conditions.check(sl.when, life, self.pack, { noChance = true }) then
			local w = sl.weight or 10
			if avoid and table.find(avoid, sl.id) then
				w *= 0.12
			end
			-- (v0.15) a story someone else on this server is living right now comes up far less
			if inPlay[sl.id] then
				w *= 0.1
			end
			table.insert(list, sl)
			table.insert(weights, w)
		end
	end
	local idx = Rng.weighted(life, weights)
	return if idx then list[idx] else nil
end

-- (v0.15) the stories other lives on this server are in right now: the server sets
-- `sim.storiesInPlayFn` (a function returning { [storyId] = true }); headless, there are none
function Sim:storiesInPlay(): { [string]: boolean }
	local fn = (self :: any).storiesInPlayFn
	if type(fn) == "function" then
		local ok, set = pcall(fn)
		if ok and type(set) == "table" then
			return set
		end
	end
	return {}
end

-- the age a story's last beat falls at, for this life (nil: it has none with an age)
function Sim:storyLastAge(life): number?
	local list = life.story and self.storyBeatList and self.storyBeatList[life.story]
	if not list or #list == 0 then
		return nil
	end
	local last = list[#list]
	return if last.relative then (life.storyStart or 0) + last.at else last.at
end

-- is the story this life is in finished? (an ending reached, or its last beat's age gone by)
function Sim:storyOver(life): boolean
	if not life.story then
		return true
	end
	if life.storyEnding then
		return true
	end
	local last = self:storyLastAge(life)
	return last ~= nil and life.age > last + 1
end

-- SECOND STORIES (storyline.act = 2): once the story you were born into is over and you're
-- grown, another finds you: one whose `when` fits the life you've made (your job, your
-- District, the age). Its beats count years from when it began (when.storyYear).
function Sim:rollNextStory(life: any, report: any)
	local pack: any = self.pack
	if not pack.storylines or life.age < (pack.secondStoryFrom or 17) or not self:storyOver(life) then
		return
	end
	life.storiesDone = life.storiesDone or {}
	if #life.storiesDone >= (pack.maxStories or 4) then
		return
	end
	if not Rng.chance(life, pack.secondStoryChance or 0.5) then
		return
	end
	local seen: any = {}
	for _, s in life.storiesDone do
		seen[s.id] = true
	end
	if life.story then
		seen[life.story] = true
	end
	local list: any, weights: any = {}, {}
	local inPlay = self:storiesInPlay()
	for _, sl in pack.storylines do
		if (sl.act or 1) >= 2 and not seen[sl.id] and (sl.weight or 10) > 0 and Conditions.check(sl.when, life, pack, { noChance = true }) then
			local w = sl.weight or 10
			if inPlay[sl.id] then
				w *= 0.1
			end
			-- one this player lived in a recent life comes up far less (the server's list of
			-- what the last lives met has its chapters on it)
			local beats: any = self.storyBeatList and self.storyBeatList[sl.id]
			local first: any = beats and beats[1]
			if life.stale and (life.stale[sl.id] or (first and first.id and life.stale[first.id])) then
				w *= 0.2
			end
			table.insert(list, sl)
			table.insert(weights, w)
		end
	end
	local idx = Rng.weighted(life, weights)
	local sl = idx and list[idx]
	if not sl then
		return
	end
	self:beginStory(life, sl, report)
end

-- a new story takes hold of a life that's between stories: the old one goes on the shelf
function Sim:beginStory(life: any, sl: any, report: any)
	life.storiesDone = life.storiesDone or {}
	local old = self:storyDef(life)
	if old then
		table.insert(life.storiesDone, { id = old.id, name = old.name, ending = life.storyEnding })
	end
	life.story = sl.id
	life.storyStart = life.age
	life.storyGoal = sl.goal
	life.storyEnding = nil
	life.storyBeats = 0
	life.storyLog = {}
	life.flags[sl.id] = true
	self:push(life, report, { kind = "story", title = sl.name, text = self:render(life, sl.hook), tone = sl.tone, thread = "story" })
	self:highlight(life, "A new story began: " .. sl.name .. ".")
end

-- THE CAST of a story (the Story tab): the people the storyline names, then anyone who has
-- spoken in a chapter you've already lived. Faces, names, and a line each; five at most.
function Sim:storyCast(life: any, def: any): any
	local out: any, seen: any = {}, {}
	local function add(who: string, line: string?)
		if seen[who] or #out >= 5 then
			return
		end
		seen[who] = true
		local sp: any = self:speaker(life, who)
		-- nobody without a face: a plain name, a creature, someone this life doesn't have
		if sp.kind == "name" or sp.kind == "you" or not sp.look or sp.creature then
			return
		end
		table.insert(out, { name = sp.name, line = if line then self:render(life, line) else sp.title, look = sp.look, kind = sp.kind })
	end
	for _, c in def.cast or {} do
		if type(c) == "table" then
			add(c.who, c.line)
		else
			add(c, nil)
		end
	end
	for _, entry in (self.storySpeakers and self.storySpeakers[def.id]) or {} do
		if life.history[entry.event] then
			add(entry.who, nil)
		end
	end
	return out
end

function Sim:storyView(life: any): any
	local def: any = self:storyDef(life)
	if not def then
		return if life.storiesDone and #life.storiesDone > 0 then { done = life.storiesDone, over = true } else nil
	end
	-- the chapters: every beat of this story, the ones behind you, and when the next one comes
	local chapters: any, nextAge: any = {}, nil
	local seenBeats: number = life.storyBeats or 0
	for i, b in (self.storyBeatList and self.storyBeatList[def.id]) or {} do
		local age = if b.relative then (life.storyStart or 0) + b.at else b.at
		local state = if age < life.age or (age == life.age and i <= seenBeats) then "done" else "ahead"
		if state == "ahead" and not nextAge and not life.storyEnding then
			nextAge = age
			state = "next"
		end
		table.insert(chapters, { age = age, title = if state == "done" then self:variant(life, b.title) else nil, state = state })
	end
	return {
		id = def.id,
		name = def.name,
		hook = self:render(life, def.hook),
		tone = def.tone,
		act = def.act or 1,
		goal = life.storyGoal,
		ending = life.storyEnding,
		beats = seenBeats,
		moments = life.storyLog,
		chapters = chapters,
		nextAge = nextAge,
		over = self:storyOver(life),
		done = life.storiesDone,
		cast = self:storyCast(life, def),
	}
end

-- a look back at the life so far (shown at pack.recapAges): who you've become
function Sim:pushRecap(life, report)
	local ages = self.pack.recapAges
	if not ages or not table.find(ages, life.age) then
		return
	end
	local lines = {}
	local def = self:storyDef(life)
	if def then
		table.insert(lines, def.name .. (if life.storyEnding then ": " .. life.storyEnding else ""))
	end
	local styles = self.pack.styles
	if life.style and styles and styles[life.style] then
		table.insert(lines, "You fight with " .. styles[life.style].name .. ".")
	end
	local talent = life.talent and self:traitDef(life.talent)
	if talent then
		table.insert(lines, "Born with " .. talent.name .. ".")
	end
	local alive, lost = 0, 0
	for _, rel in life.relations do
		local def2 = self.pack.relationKinds[rel.kind]
		if def2 and def2.family then
			if rel.alive then
				alive += 1
			else
				lost += 1
			end
		end
	end
	if lost > 0 then
		table.insert(lines, string.format("Family: %d still here, %d gone.", alive, lost))
	elseif alive > 0 then
		table.insert(lines, string.format("Family: all %d still here.", alive))
	end
	for i = math.max(1, #life.highlights - 3), #life.highlights do
		local h = life.highlights[i]
		if h then
			table.insert(lines, string.format("At %d: %s", h.age, h.text))
		end
	end
	self:push(life, report, { kind = "recap", title = string.format("%s at %d", life.first, life.age), lines = lines, text = table.concat(lines, " ") })
end

function Sim:rollEvents(life, count: number)
	if count <= 0 then
		return
	end
	local candidates, weights = {}, {}
	for _, e in self.pack.events do
		if not Util.contains(life.queue, e.id) and self:eligible(life, e) then
			local w = self:eventWeight(life, e)
			if w > 0 then
				table.insert(candidates, e)
				table.insert(weights, w)
			end
		end
	end
	local picked = 0
	while picked < count do
		local idx = Rng.weighted(life, weights)
		if not idx then
			break
		end
		local e = candidates[idx]
		weights[idx] = 0
		local gate = e.when and e.when.chance
		if gate == nil or Rng.chance(life, gate) then
			table.insert(life.queue, e.id)
			picked += 1
		end
	end
end

-- A card that can't be answered must not hold a life: its event is gone from the pack (a life
-- saved before an update), or nothing on it can be chosen any more. Let it pass. Returns true
-- if a card was dropped. (Sim:view calls this, so no screen is ever told to wait on one.)
function Sim:settlePending(life): boolean
	if life.pending == nil then
		return false
	end
	local event = self.eventsById[life.pending]
	if event and event.choices and self:hasOpenChoice(life, event) then
		return false
	end
	life.pending = nil
	life.sceneRel = nil
	life.focusLink = nil
	life.actor = nil
	return true
end

function Sim:hasOpenChoice(life, event): boolean
	for _, c in event.choices do
		if Conditions.check(c.requires, life, self.pack, { noChance = true }) then
			return true
		end
	end
	return false
end

-- picks which linked friend an event is about
function Sim:pickFocus(life, when)
	local needRough = when.linkedRough == true
	local options = {}
	for _, rel in life.relations do
		if rel.alive and rel.userId ~= nil and rel.online == true and (not needRough or rel.rough == true) then
			table.insert(options, rel)
		end
	end
	local rel = Rng.pick(life, options)
	life.focusLink = if rel then rel.id else nil
	return rel ~= nil
end

-- Runs queued events until one needs a choice, the queue empties, or the life ends.
-- Capped per call so two events that trigger each other can't loop forever.
function Sim:advance(life: any, report: any)
	local processed = 0
	-- (a solo run in progress holds the queue: its cards come first, the rest after)
	while life.alive and life.pending == nil and #life.queue > 0 and not (life.run and not life.run.crew) do
		processed += 1
		if processed > MAX_EVENTS_PER_STEP then
			life.queue = {}
			break
		end
		local id = table.remove(life.queue, 1)
		local event = self.eventsById[id]
		if event and event.story and life.story ~= event.story then
			event = nil
		end
		-- a life with a storyline skips the stock opening scenes it replaces (pack.storyReplaces)
		if event and life.story and self.pack.storyReplaces then
			for _, prefix in self.pack.storyReplaces do
				if string.sub(id, 1, #prefix) == prefix then
					event = nil
					break
				end
			end
		end
		-- follow-ups re-check their `when` when they come due (chance is ignored),
		-- so e.g. a lesson from a mentor who has since died quietly doesn't happen
		if event and event.when and not Conditions.check(event.when, life, self.pack, { noChance = true }) then
			event = nil
		end
		if event and event.when and (event.when.linked or event.when.linkedRough) then
			if not self:pickFocus(life, event.when) then
				event = nil
			end
		end
		if event and life.gw then
			HunterWorld.onShow(self, life, event)
		end
		if event then
			life.history[id] = life.age
			-- (v0.13) how many times this life has seen it (Sim:eventWeight makes a repeat rarer)
			life.timesSeen = life.timesSeen or {}
			life.timesSeen[id] = (life.timesSeen[id] or 0) + 1
			self:setActor(life, event)
			self:learnFrom(life, event, report)
			Mood.saw(self, life, event)
			Focus.saw(self, life, event)
			if event.cutscene then
				self:push(life, report, self:cutsceneEntry(life, event.cutscene))
			end
			if event.story then
				life.storyBeats = (life.storyBeats or 0) + 1
			end
			if event.choices then
				-- never strand the player on an event they can't answer
				if self:hasOpenChoice(life, event) then
					life.pending = id
					self:unlockCodex(life, event.codex, report)
				else
					life.focusLink = nil
					life.actor = nil
				end
			else
				local sceneTitle = self:render(life, event.title)
				self:push(life, report, {
					kind = "event",
					title = sceneTitle,
					text = self:render(life, event.text),
					thread = self:threadOf(life, event),
				})
				self:unlockCodex(life, event.codex, report)
				life.scene = sceneTitle
				Effects.apply(self, life, event.result, report)
				life.scene = nil
				life.focusLink = nil
				life.actor = nil
			end
		end
	end
end

-- Makes one event happen right now, skipping its usual conditions (the mod menu uses this).
function Sim:forceEvent(life, id: string)
	if not life.alive then
		return nil, "This life is over."
	end
	if life.pending then
		return nil, "They have a decision open."
	end
	if life.run then
		return nil, "They're on an expedition."
	end
	if life.battle or life.battleWith or life.duel then
		return nil, "They're in the middle of a fight."
	end
	local event = self.eventsById[id]
	if not event then
		return nil, "No such event."
	end
	local report = newReport()
	life.history[id] = life.age
	self:setActor(life, event)
	if event.choices then
		life.pending = id
		self:unlockCodex(life, event.codex, report)
	else
		self:push(life, report, { kind = "event", title = self:render(life, event.title), text = self:render(life, event.text), thread = self:threadOf(life, event) })
		self:unlockCodex(life, event.codex, report)
		Effects.apply(self, life, event.result, report)
		life.actor = nil
		self:advance(life, report)
	end
	return report
end

function Sim:randomEventCount(life): number
	local table_ = self.pack.eventsPerYear
	if table_ then
		for _, row in table_ do
			if life.age <= row.upTo then
				local whole = math.floor(row.n)
				return whole + (if Rng.chance(life, row.n - whole) then 1 else 0)
			end
		end
	end
	if life.age < 4 then
		return if Rng.chance(life, 0.3) then 1 else 0
	elseif life.age < 13 then
		return if Rng.chance(life, 0.7) then 1 else 0
	end
	return if Rng.chance(life, 0.3) then 2 else 1
end



function Sim:ageUp(life: any)
	if not life.alive then
		return nil, "This life is over."
	end
	if life.pending then
		return nil, "Decide what to do first."
	end
	if life.run then
		return nil, "Finish your expedition first."
	end
	if life.battle or life.battleWith or life.duel then
		return nil, "Finish the fight first."
	end
	local pack = self.pack
	local report = newReport()
	life.age += 1
	life.year += 1
	life.actionsLeft = self:actionsPerYear(life)
	life.socialLeft = self:socialPerYear(life)
	life.lastClash, life.lastHit, life.lastChoice = nil, nil, nil
	self:pushChapter(life, report)
	Feats.phaseCheck(self, life, report)
	local yearEntry = { kind = "year", text = "Age " .. life.age, year = life.year }
	self:push(life, report, yearEntry)
	self:pushRecap(life, report)
	Talent.wakeCheck(self, life, report)

	self:rollWorld(life, report)
	-- (BitLeveling) the Gates: the world's own incidents this year (Engine/HunterWorld.luau)
	if self.pack.hunterWorld then
		HunterWorld.year(self, life, report)
	end
	self:rollCrisis(life, report)
	-- (v0.12) a year with a mood of its own (Engine/Mood.luau); a hard year has none
	Mood.roll(self, life, report, yearEntry)
	self:passive(life, report)
	self:rollHazard(life, report)
	self:rollReprisal(life, report)
	Known.learnPlace(self, life)
	People.yearly(self, life, report)
	if life.alive then
		self:rollNextStory(life, report)
		Jobs.roll(self, life)
	end

	self:settleHealth(life)
	if life.alive then
		Renown.officeYear(self, life, report)
		Market.homeYear(self, life, report)
		Market.householdYear(self, life, report)
		Turf.year(self, life, report)
	end
	if life.alive and life.stats[self.vital] <= 0 then
		-- an old body running out is old age, not wounds (unless it was something specific)
		local causes = pack.deathCauses.oldAge
		if life.age >= math.max(65, Body.lifespan(self, life) - 5) and causes then
			self:kill(life, report, if type(causes) == "table" then Rng.pick(life, causes) else causes)
		else
			self:kill(life, report, pack.deathCauses.wounds)
		end
	end
	local oldAt = Body.lifespan(self, life)
	if life.alive and life.age >= oldAt then
		local p = (life.age - (oldAt - 2)) * 0.02 + math.max(0, 30 - life.stats[self.vital]) * 0.005
		if Rng.chance(life, p) then
			local causes = pack.deathCauses.oldAge
			local cause = if type(causes) == "table" then Rng.pick(life, causes) else causes
			self:kill(life, report, cause or "Died of old age")
		end
	end
	if not life.alive then
		return report
	end

	-- (v0.18) a focus that has run its course lets go
	Focus.tick(self, life)
	-- follow-ups that are due this year go first
	local still = {}
	for _, s in life.scheduled do
		if s.age <= life.age then
			table.insert(life.queue, s.event)
		else
			table.insert(still, s)
		end
	end
	life.scheduled = still

	-- milestones (`always = true`): turning points in the world's history that everyone
	-- living through them sees, whatever the random roll does (gate them with `once`)
	for _, e in self.pack.events do
		if e.always and not Util.contains(life.queue, e.id) and self:eligible(life, e) then
			local gate = e.when and e.when.chance
			if gate == nil or Rng.chance(life, gate) then
				table.insert(life.queue, e.id)
			end
		end
	end

	-- a year that carries a beat of your story has one fewer unrelated event (never none)
	local count = self:randomEventCount(life)
	for _, qid in life.queue do
		local qe = self.eventsById[qid]
		if qe and qe.story and qe.story == life.story then
			count = math.max(1, count - 1)
			break
		end
	end
	-- (v0.18) a follow-up of what this life is about comes without a crowd around it
	count = Focus.count(self, life, count)
	self:rollEvents(life, count)
	-- (v0.18) and sometimes the City sends something worse on top (pack.hardness.dread)
	self:rollDread(life)
	Focus.order(self, life)
	self:advance(life, report)
	self:checkAmbitions(life, report)
	return report
end

-- (v0.18) DREAD: on top of the year's cards, sometimes one more, drawn only from the
-- dangerous ones (pack.hardness.dread = { fromAge, chance, byAge = { { from, chance } } })
function Sim:rollDread(life: any)
	local H = (self.pack :: any).hardness
	local d = H and H.dread
	if not d or life.age < (d.fromAge or 16) then
		return
	end
	local chance = d.chance or 0.2
	for _, step in d.byAge or {} do
		if life.age >= step.from then
			chance = step.chance
		end
	end
	local diff = self:difficultyDef(life)
	if diff then
		chance *= diff.hazard or 1
	end
	-- a life in the middle of something gets a little room
	if life.focus then
		chance *= d.focusMult or 0.5
	end
	if not Rng.chance(life, math.min(0.85, chance)) then
		return
	end
	local candidates, weights = {}, {}
	for _, e in self.pack.events do
		local danger = e.dread == true
		if not danger then
			for _, tag in e.tags or {} do
				if tag == "danger" then
					danger = true
					break
				end
			end
		end
		if danger and not Util.contains(life.queue, e.id) and self:eligible(life, e) then
			local w = self:eventWeight(life, e)
			if w > 0 then
				table.insert(candidates, e)
				table.insert(weights, w)
			end
		end
	end
	local idx = Rng.weighted(life, weights)
	if idx then
		local e = candidates[idx]
		local gate = e.when and e.when.chance
		if gate == nil or Rng.chance(life, gate) then
			table.insert(life.queue, e.id)
		end
	end
end

-- ── player actions ──────────────────────────────────────────────────────────



function Sim:clashSides(life: any, spec: any, approachId: string?)
	local form = self.pack.forms[life.form]
	local approach: any = approachId and self.pack.approaches and self.pack.approaches[approachId]
	-- FIGHTING BY STAT: an approach with `stat` is a way of fighting. That stat sets how hard
	-- your coins hit (Speed still sets how many you have).
	local statKey = spec.stat
	local stance = approach ~= nil and approach.stat ~= nil and spec.fight == true and life.stats[approach.stat] ~= nil
	if stance then
		statKey = approach.stat
	end
	local statValue = life.stats[statKey] or 0
	if statKey == self.vital then
		-- Health past 100 is more to lose, not a stronger check
		statValue = math.min(100, statValue)
	end
	local player = Clash.playerSide(life.first, statValue, life.sanity, form, spec.ignoreSanity, self.pack.clash)
	local bonus = self:statBonus(life, statKey)
	local headsBonus = 0
	-- your nature: +1 on the stat you lean on
	if self:nature(life) == statKey then
		bonus.base += 1
		player.natural = true
	end
	if stance then
		local sp = self:stancePerk(life, statKey)
		bonus.base += sp.base
		bonus.coinPower += sp.coinPower
		bonus.coins += sp.coins
		-- the foe's temper against the way you fight
		local temper = self:temperOf(spec)
		local m = self.pack.matchup or {}
		if temper and approach.beats == temper then
			bonus.base += m.bonus or 2
			player.edge = "advantage"
		elseif temper and approach.loses == temper then
			bonus.base -= m.penalty or 2
			player.edge = "resisted"
		end
	end
	-- SPEED: in a fight the coins come from Speed, not from the stat you hit with. It's how
	-- many clashes you can afford to lose, and it decides who strikes first (Clash.resolve).
	local speedKey = self.roles.speed
	local curve = self.pack.clash or {}
	local coinsEvery = curve.coinsEvery or Clash.DEFAULT_CURVE.coinsEvery
	if spec.fight and speedKey then
		local spd = self:speedOf(life)
		local formCoins = (form and form.clash and form.clash.coins) or 0
		player.coins = math.max(1, math.min(curve.maxCoins or Clash.DEFAULT_CURVE.maxCoins, 1 + math.floor(spd / coinsEvery)) + formCoins)
		-- (v0.17) Speed past every limit: one more coin at each of pack.clash.extraCoinsAt
		for _, at in curve.extraCoinsAt or {} do
			if spd >= at then
				player.coins += 1
			end
		end
		player.speed = spd
	end
	-- LUCK tilts every coin a little: +1% heads per 10. A check on Luck itself leans on it
	-- far more: +1% heads per point.
	if self.roles.luck then
		local luck = self:luckOf(life)
		headsBonus += if spec.stat == self.roles.luck then luck else math.floor(luck / 10)
	end
	for _, id in life.traits or {} do
		local def = self:traitDef(id)
		if def then
			headsBonus += def.heads or 0
			if spec.fight and def.fight and (def.style == nil or def.style == life.style) then
				bonus.coins += def.fight.coins or 0
				bonus.base += def.fight.base or 0
				bonus.coinPower += def.fight.coinPower or 0
			end
		end
	end
	-- gear: fight bonuses and luck (style gear only works with its style)
	for _, g in self:gearIn(life) do
		local def = g.def
		if def.style == nil or def.style == life.style then
			headsBonus += def.heads or 0
			if spec.fight and def.fight then
				bonus.coins += def.fight.coins or 0
				bonus.base += def.fight.base or 0
				bonus.coinPower += def.fight.coinPower or 0
			end
		end
	end
	-- (v0.18) your Office at your back: its Fixers, and the armory's kit
	if spec.fight and life.office then
		local officeBase = Office.fightBonus(self, life)
		bonus.base += officeBase
	end
	-- Resonance: a talent of one of your sins steadies your hand
	if self:resonates(life) then
		headsBonus += (self.pack.affinityResonance or 3)
	end
	if headsBonus ~= 0 and not spec.ignoreSanity then
		player.heads = math.clamp(player.heads + headsBonus, 5, 95)
	end
	-- in a fight, your style marks the opponent
	local styles = self.pack.styles
	if spec.fight and styles and life.style and styles[life.style] then
		player.status = Clash.statusOf({ id = styles[life.style].status or life.style, potency = self:fightPotency(life) })
	end
	if approach and approach.clash then
		bonus.coins += approach.clash.coins or 0
		bonus.base += approach.clash.base or 0
		bonus.coinPower += approach.clash.coinPower or 0
	end
	-- ABILITIES (fights only): what's in your hand, and the art you fight with
	local pierce = if spec.fight then self:playerAbilities(life, approach, player) else 0
	-- someone close stands with you: one fight a year
	if spec.fight then
		local backer = self:backerFor(life)
		if backer then
			bonus.coins += 1
			player.backer = backer.first
		end
	end
	player.coins = math.max(1, player.coins + bonus.coins)
	player.base = math.max(0, player.base + bonus.base)
	player.coinPower = math.max(1, player.coinPower + bonus.coinPower)
	if spec.assist then
		local friend = self:focusLinked(life)
		if friend then
			player.coins += 1
			player.name = life.first .. " & " .. friend.first
		end
	end
	local foe = Clash.foeSide(spec)
	if spec.fight then
		self:foeAbilities(spec, foe)
	end
	if pierce > 0 then
		foe.base = math.max(0, foe.base - pierce)
	end
	if stance and approach.foeHeads then
		-- a way of fighting that spoils their coins
		foe.heads = math.clamp(foe.heads + approach.foeHeads, 5, 95)
	end
	if spec.fight and speedKey then
		-- how fast a foe is follows from what it brings (22 for one coin and a base of 3, 44 for
		-- two and 5, 66 for three and 7, 88 for a four-coin boss); a clash or a foe may say
		-- otherwise (clash.speed = an exact number; foe.speed = quicker or slower than that)
		local foeDef = self:foeDef(spec)
		foe.speed = spec.speed or math.max(0, 16 + (foe.coins - 1) * 18 + foe.base * 2 + ((foeDef and foeDef.speed) or 0))
	end
	-- armor that resists a status (gear.resist = { burn = 2 }) weakens the foe's
	if spec.fight and foe.status then
		local resist = 0
		for _, g in self:gearIn(life) do
			local r = g.def.resist and g.def.resist[foe.status.id]
			if type(r) == "number" then
				resist += r
			end
		end
		if resist > 0 then
			local left = foe.status.potency - resist
			foe.status = if left >= 1 then { id = foe.status.id, potency = left } else nil
		end
	end
	-- the City sends worse at you as your life goes on: foes gain base power with your age
	-- (pack.clash.foeGrowth = { fromAge, everyYears, maxBase }); `fixed = true` opts out
	local diff = self:difficultyDef(life)
	if diff and diff.foeBase and not spec.fixed then
		foe.base = math.max(0, foe.base + diff.foeBase)
	end
	-- you choose how to fight, so whoever you fight is a little better than they'd be on paper
	-- (pack.clash.fightBase)
	if spec.fight and not spec.fixed and self.pack.clash and self.pack.clash.fightBase then
		foe.base = math.max(0, foe.base + self.pack.clash.fightBase)
	end
	local growth = self.pack.clash and self.pack.clash.foeGrowth
	if growth and not spec.fixed and life.age >= (growth.fromAge or 25) then
		local steps = 1 + math.floor((life.age - (growth.fromAge or 25)) / (growth.everyYears or 12))
		foe.base += math.min(growth.maxBase or 3, steps)
	end
	-- the stronger your name, the stronger who comes for you (pack.clash.gradeGrowth: +1 base
	-- per `every` Fixer grades), and a hard year makes every fight harder (life.crisis)
	if spec.fight and not spec.fixed then
		local gg = self.pack.clash and self.pack.clash.gradeGrowth
		if gg then
			foe.base += math.floor(self:fixerRating(life) / (gg.every or 3))
		end
		local crisis = self:crisisDef(life)
		if crisis then
			foe.base += crisis.foeBase or 0
			foe.coins = math.min(5, foe.coins + (crisis.foeCoins or 0))
		end
	end
	-- (v0.18) EVENT CARDS ARE HARDER (pack.hardness): every card's foe or obstacle is
	-- stronger, a dangerous card's more so, and a dangerous card grows with you (past
	-- match.from, +1 for every match.every points of the stat you face it with)
	-- (the difficulty scales it: pack.difficulties[id].hardness, 1 when it doesn't say)
	local H = (self.pack :: any).hardness
	local kind = self.cardClash and self.cardClash[spec]
	if H and kind and not spec.fixed and life.age >= (H.fromAge or 14) then
		local hm = (diff and tonumber(diff.hardness)) or 1
		local function scaled(n: number): number
			return math.floor(n * hm + 0.5)
		end
		foe.base += scaled(H.cardBase or 0)
		if kind == "danger" then
			foe.base += scaled(H.dangerBase or 0)
			local m = H.match
			if m then
				local over = math.max(0, statValue - (m.from or 60))
				foe.base += scaled(math.min(m.max or 4, math.floor(over / (m.every or 40))))
			end
			if spec.fight and (H.dangerCoins or 0) > 0 and hm >= 1 then
				foe.coins = math.min(5, foe.coins + H.dangerCoins)
			end
		end
	end
	return player, foe
end

-- A duel between two players' lives. Each fights with their better of Justice and
-- Fortitude, with their style, mastery, gear, traits and talent; each side's armor resists
-- the other's status. Returns both sides (a first) and the stat each used.
function Sim:duelSides(a, b)
	local function sideOf(life)
		-- (a pack with a Speed stat fights on its fight stat alone: Speed brings the coins)
		local fight, vital = self.roles.fight, self.vital
		local stat = if not self.roles.speed and (life.stats[vital] or 0) > (life.stats[fight] or 0) then vital else fight
		local side = self:clashSides(life, { stat = stat, fight = true, fixed = true })
		side.name = life.first .. " " .. life.last
		return side, stat
	end
	local sa, statA = sideOf(a)
	local sb, statB = sideOf(b)
	local function resist(life, side)
		if not side.status then
			return
		end
		local r = 0
		for _, g in self:gearIn(life) do
			local v = g.def.resist and g.def.resist[side.status.id]
			if type(v) == "number" then
				r += v
			end
		end
		if r > 0 then
			local left = side.status.potency - r
			side.status = if left >= 1 then { id = side.status.id, potency = left } else nil
		end
	end
	resist(a, sb)
	resist(b, sa)
	return sa, sb, statA, statB
end

-- The same clash rounds seen from the other side.
function Sim.swapRounds(rounds)
	local out = {}
	for _, r in rounds do
		local fx = nil
		if r.fx then
			fx = {}
			for _, f in r.fx do
				local who, what = string.sub(f, 1, 1), string.sub(f, 2)
				table.insert(fx, (if who == "p" then "f" else "p") .. what)
			end
		end
		table.insert(out, {
			p = r.f,
			f = r.p,
			pPower = r.fPower,
			fPower = r.pPower,
			winner = if r.winner == "player" then "foe" elseif r.winner == "foe" then "player" else r.winner,
			pCoins = r.fCoins,
			fCoins = r.pCoins,
			pStatus = r.fStatus,
			fStatus = r.pStatus,
			fx = fx,
			oneSided = if r.oneSided == "player" then "foe" elseif r.oneSided == "foe" then "player" else nil,
		})
	end
	return out
end

function Sim:clash(life, spec, approachId: string?)
	local player, foe = self:clashSides(life, spec, approachId)
	local res = Clash.resolve(life, player, foe)
	res.stat = spec.stat
	-- (v0.15) a boss fight (clash.boss): the client gives it the full entrance
	res.boss = if spec.boss == true then true else nil
	return res
end


function Sim:clashPreview(life: any, spec: any): any
	local player, foe = self:clashSides(life, spec)
	local stat = self.pack.stats[spec.stat]
	local preview = {
		stat = spec.stat,
		statName = if stat then stat.name else spec.stat,
		player = player,
		foe = foe,
		odds = Clash.estimate(player, foe),
		fight = spec.fight == true,
		enemy = if spec.fight then self:foeFor(spec) else nil,
		-- who strikes first, one-sided ("player" | "foe"), when one side is clearly faster
		first = Clash.firstStrike(player, foe),
		backer = player.backer,
		natural = player.natural,
		abilities = self:abilitiesView(player.abilities),
		foeAbilities = self:abilitiesView(foe.abilities),
	}
	-- the foe's temper, and the way of fighting it is weak to
	local temper = self:temperOf(spec)
	local tdef = temper and self.pack.tempers[temper]
	if tdef then
		local weak = tdef.weakTo and self.pack.approaches and self.pack.approaches[tdef.weakTo]
		preview.temper = {
			id = temper,
			name = tdef.name,
			desc = tdef.desc,
			color = tdef.color,
			weakTo = tdef.weakTo,
			weakName = weak and weak.name,
			weakStat = weak and weak.stat,
			strongTo = tdef.strongTo,
		}
	end
	local approaches = self.pack.approaches
	if approaches and approaches.order then
		preview.approaches = {}
		for _, id in approaches.order do
			local a = approaches[id]
			if self:approachOpen(life, a, spec) then
				local p, f = self:clashSides(life, spec, id)
				local cost = self:approachCost(life, a)
				local sdef = a.stat and self.pack.stats[a.stat]
				local odds = Clash.estimate(p, f)
				table.insert(preview.approaches, {
					id = id,
					name = a.name,
					short = a.short,
					desc = a.desc,
					odds = odds,
					coins = p.coins,
					base = p.base,
					coinPower = p.coinPower,
					sanityCost = if cost > 0 then cost else nil,
					healthCost = a.healthCost,
					abilities = self:abilitiesView(a.abilities),
					color = a.color,
					-- a way of fighting: the stat it uses, your number in it, and how it meets this foe
					stat = if sdef and spec.fight then a.stat else nil,
					statShort = if sdef and spec.fight then sdef.short else nil,
					value = if sdef and spec.fight then (life.stats[a.stat] or 0) else nil,
					edge = p.edge,
					natural = p.natural,
				})
				-- a fight is as good as your best way into it
				if spec.fight and a.stat and (preview.bestOdds == nil or odds > preview.bestOdds) then
					preview.bestOdds = odds
					preview.best = id
				end
			end
		end
	end
	return preview
end


function Sim:resolveOption(life: any, option: any, report: any, approachId: string?, extraCtx: any?)
	local approaches = self.pack.approaches
	if approachId and not (approaches and approaches[approachId]) then
		approachId = nil
	end
	if approachId and not self:approachOpen(life, approaches[approachId], option.clash) then
		approachId = nil
	end
	if option.clash then
		local res = self:clash(life, option.clash, approachId)
		-- kept for the death report: what the last risk was, in numbers
		local statDef = self.pack.stats[option.clash.stat]
		life.lastClash = {
			stat = option.clash.stat,
			statName = (statDef and statDef.name) or tostring(option.clash.stat),
			foe = res.foe.name,
			fight = option.clash.fight == true,
			won = res.won,
			approach = approachId,
			stance = if approachId and approaches[approachId] then approaches[approachId].name else nil,
			edge = res.player.edge,
			first = Clash.firstStrike(res.player, res.foe),
			odds = Clash.estimate(res.player, res.foe),
			pCoins = res.player.coins, pBase = res.player.base, pCoinPower = res.player.coinPower, pHeads = res.player.heads, pSpeed = res.player.speed,
			fCoins = res.foe.coins, fBase = res.foe.base, fCoinPower = res.foe.coinPower, fSpeed = res.foe.speed,
		}
		local stanceDef = approachId and approaches[approachId]
		local temperId = self:temperOf(option.clash)
		local temperDef = temperId and self.pack.tempers[temperId]
		report.clash = {
			won = res.won,
			rounds = res.rounds,
			player = res.player,
			foe = res.foe,
			stat = res.stat,
			fight = option.clash.fight == true,
			-- the way you fought, and the temper you fought it against
			stance = if stanceDef and stanceDef.stat and option.clash.fight then { id = approachId, name = stanceDef.name, stat = stanceDef.stat } else nil,
			temper = if temperDef then { id = temperId, name = temperDef.name, color = temperDef.color } else nil,
		}
		if option.clash.fight then
			self:tally(life, if res.won then "fightsWon" else "fightsLost")
		end
		self:push(life, report, {
			kind = "clash",
			won = res.won,
			text = (if res.won then "Won a clash against " else "Lost a clash against ") .. res.foe.name .. ".",
		})
		self:tally(life, if res.won then "clashesWon" else "clashesLost")
		if approachId == "reckless" then
			self:tally(life, "reckless")
		end
		local approach = approachId and approaches[approachId]
		if approach and approach.stat and option.clash.fight then
			self:tally(life, "fought_" .. approachId)
		end
		if option.clash.fight and res.player.backer then
			life.backedAge = life.age
			self:push(life, report, { kind = "system", tone = "good", text = res.player.backer .. " stood with you." })
		end
		local outcome = if res.won then option.win else option.lose
		if approach and (approach.gain or approach.loss) then
			outcome = self:scaledResult(outcome, approach.gain or 1, approach.loss or 1)
		end
		if option.clash.fight then
			report.clash.enemy = self:foeFor(option.clash)
			-- beat one of a faction's own and they hear of it (unless the outcome says its own piece)
			local foeDef = self:foeDef(option.clash)
			local faction = foeDef and foeDef.faction
			local repDef = faction and self.pack.reputation and self.pack.reputation[faction]
			-- (talked down, nobody was hurt: nothing to hold against you)
			local bloodless = approach ~= nil and approach.bloodless == true
			if res.won and repDef and not bloodless and not (type(outcome) == "table" and type(outcome.rep) == "table" and outcome.rep[faction] ~= nil) then
				local lines = {}
				self:addRep(life, faction, repDef.beat or -8, lines)
				for _, e in lines do
					self:push(life, report, e)
				end
			end
		end
		Effects.apply(self, life, outcome, report, extraCtx)
		if approach and approach.after and life.alive then
			Effects.apply(self, life, approach.after, report)
		end
		self:bloodAfter(life, approach, res, report)
		if option.clash.fight then
			Renown.fromFight(self, life, res, report)
		end
		-- what the approach costs the mind (E.G.O): less, the stronger the mind
		local cost = self:approachCost(life, approach)
		if cost > 0 and life.alive then
			Effects.apply(self, life, { sanity = -cost, log = approach.costLog or ("It cost you " .. cost .. " Sanity.") }, report)
		end
		report.clash.approach = approachId
	else
		Effects.apply(self, life, option.result, report, extraCtx)
	end
end

function Sim:choose(life: any, index: number, approachId: string?)
	if not life.alive then
		return nil, "This life is over."
	end
	if life.battle or life.battleWith or life.duel then
		return nil, "Finish the fight first."
	end
	self:settlePending(life)
	local event = if life.pending then self.eventsById[life.pending] else nil
	if not event then
		return nil, "Nothing to decide."
	end
	local choice = event.choices[index]
	if not choice then
		return nil, "That isn't an option."
	end
	local ok, why = Conditions.check(choice.requires, life, self.pack, { noChance = true })
	if not ok then
		return nil, why
	end
	self:markTerms(life, event)
	life.pending = nil
	local report = newReport()
	local title = self:render(life, event.title)
	local choiceLabel = self:render(life, choice.label)
	self:push(life, report, { kind = "event", title = title, choice = choiceLabel, story = event.story ~= nil or nil, thread = self:threadOf(life, event) })
	self:highlight(life, title)
	if event.story then
		-- the Story tab's "so far": every beat answered, and what you did
		life.storyLog = life.storyLog or {}
		table.insert(life.storyLog, { age = life.age, title = title, choice = choiceLabel })
		while #life.storyLog > 24 do
			table.remove(life.storyLog, 1)
		end
	end
	life.scene = title
	life.lastChoice, life.lastClash, life.lastHit = choiceLabel, nil, nil
	if life.why then
		life.why[event.id] = nil
	end
	-- a scene with someone: what it does to the bond lands on them
	local sceneCtx = nil
	if life.sceneRel and event.social then
		local rel = self:relationById(life, life.sceneRel)
		if rel then
			sceneCtx = self:interactionTokens(life, rel)
		end
	end
	-- (v0.13) a card of an episode: its ending is recorded against the episode
	if event.episode then
		sceneCtx = sceneCtx or {}
		sceneCtx.episode = event.episode
	end
	-- (v0.16) a big boss: a battle in turns instead of one clash (Engine/Battle.luau)
	if choice.battle and Battle.def(self, choice.battle) then
		Battle.begin(self, life, choice.battle, { eventId = event.id, choice = index, art = event.art, title = title })
		report.battle = true
		life.sceneRel = nil
		life.scene = nil
		life.focusLink = nil
		life.actor = nil
		return report
	end
	self:resolveOption(life, choice, report, approachId, sceneCtx)
	if report.clash then
		report.clash.art = event.art -- the fight is staged where the scene was
	end
	-- (BitLeveling) the incident (and the life's record) learns what the player did
	if life.gw then
		HunterWorld.afterChoice(self, life, event, choice, report)
	end
	life.sceneRel = nil
	life.scene = nil
	life.focusLink = nil
	life.actor = nil
	self:advance(life, report)
	self:checkAmbitions(life, report)
	return report
end

-- (v0.16) BATTLES: a turn in a fight against a big boss, for a life fighting alone (the
-- server runs fights with friends through Battle directly, with every fighter's life)
function Sim:battleAct(life: any, action: string, approach: string?)
	local key = tostring(life.id)
	if not life.battle then
		return nil, "There's no fight going on."
	end
	local reports, why = Battle.act(self, life, { [key] = life }, key, action, approach)
	if not reports then
		return nil, why or "Waiting for the others."
	end
	return reports[key] or newReport()
end

function Sim:battleView(life: any, lives: any?, viewer: string?): any
	if not life or not life.battle then
		return nil
	end
	local key = tostring(life.id)
	return Battle.view(self, life, lives or { [key] = life }, viewer or key)
end

-- the emblem an activity is drawn with: its own, else the first thing it's good for
local ACT_ICON_CATEGORY = { people = "tab.friends", home = "tab.city", district = "tab.city", gear = "misc.fight", city = "misc.star", money = "cur.ahn" }
function Sim:activityIcon(act): string
	if act.icon then
		return act.icon
	end
	local r = act.result or act.win
	if type(r) == "table" then
		if r.wage or r.paycheck then
			return "cur.ahn"
		end
		for _, key in self.scaledKeys do
			local v = r[key]
			local n = if type(v) == "table" then v[2] else v
			if key ~= "money" and type(n) == "number" and n > 0 then
				return "stat." .. key
			end
		end
	end
	return ACT_ICON_CATEGORY[act.category or ""] or "tab.you"
end

-- TIME FOR PEOPLE: a pack with meta.socialPerYear gives family and friends their own yearly
-- budget (life.socialLeft), apart from the actions spent on everything else. Interactions
-- spend it, and so do activities marked `social` (or in the "people" category, or `family`).
function Sim:socialKey(): string
	return if self.pack.meta.socialPerYear then "socialLeft" else "actionsLeft"
end

function Sim:budgetOf(act): string
	if self.pack.meta.socialPerYear and (act.social == true or act.family == true or (act.social == nil and act.category == "people")) then
		return "socialLeft"
	end
	return "actionsLeft"
end

function Sim:activityCost(life, act): number
	if act.move == "charter" then
		return self:districtDef(life).charterCost or act.cost or 0
	end
	return act.cost or 0
end

function Sim:activityState(life, act): (boolean, boolean, string?)
	-- returns visible, enabled, reason
	if act.minAge and life.age < act.minAge then
		return false, false, nil
	end
	if act.maxAge and life.age > act.maxAge then
		return false, false, nil
	end
	local ok = Conditions.check(act.when, life, self.pack, { noChance = true })
	if not ok then
		return false, false, nil
	end
	local charterSide = self.pack.sides.order[1]
	if act.move == "charter" and life.side == charterSide then
		return false, false, nil
	end
	if act.move == "gutters" and life.side ~= charterSide then
		return false, false, nil
	end
	if act.move == "district" and #self.pack.districts.order < 2 then
		return false, false, nil
	end
	if act.shop then
		return true, life.alive and not life.pending, if life.pending then "Decide first" else nil
	end
	if not life.alive then
		return true, false, "This life is over"
	end
	if life.pending then
		return true, false, "Decide first"
	end
	if act.move == "charter" and self:formBlocksSide(life, charterSide) then
		return true, false, "The gates won't open for you"
	end
	if (life[self:budgetOf(act)] or 0) <= 0 then
		return true, false, if self:budgetOf(act) == "socialLeft" then "No time left for people this year" else "No actions left this year"
	end
	local cost = self:activityCost(life, act)
	if cost > 0 and life.money < cost then
		return true, false, "Needs " .. cost .. " " .. self.pack.meta.currency
	end
	if act.cooldown and life.actUsed[act.id] and life.age - life.actUsed[act.id] < act.cooldown then
		local wait = act.cooldown - (life.age - life.actUsed[act.id])
		return true, false, "Again in " .. wait .. (if wait == 1 then " year" else " years")
	end
	if act.schools and not (life.school and table.find(act.schools, life.school)) then
		return true, false, "Needs " .. self:schoolNames(act.schools) .. " training"
	end
	if act.result and act.result.mastery and self.pack.schools and (life.mastery or 0) >= self:masteryCap(life) then
		if (life.mastery or 0) >= (self.pack.maxMastery or 5) then
			return true, false, "Nothing left to learn"
		end
		local school = self:schoolDef(life)
		return true, false, if school and school.org then ("Only " .. school.org .. " can take you further") else "Needs a teacher"
	end
	if act.daily then
		local def = self:dailyDef(life)
		if not (def and def.event and self.eventsById[def.event]) then
			return true, false, "Nothing on today"
		end
		if life.dailyDay == self.dayNumber then
			return true, false, "Back tomorrow"
		end
	end
	return true, true, nil
end

function Sim:doActivity(life: any, id: string, arg: any?, approachId: string?)
	local act = self.activitiesById[id]
	if not act then
		return nil, "Unknown activity."
	end
	if act.shop then
		return nil, "Open the workshop to buy gear."
	end
	if act.market then
		return nil, "Open the market to buy."
	end
	local visible, enabled, why = self:activityState(life, act)
	if not visible or not enabled then
		return nil, why or "Not available."
	end
	if life.run then
		return nil, "Finish your expedition first."
	end
	if life.battle or life.battleWith or life.duel then
		return nil, "Finish the fight first."
	end
	if act.move == "district" then
		if type(arg) ~= "string" or not self.pack.districts[arg] then
			return nil, "Pick a " .. (self.pack.meta.districtWord or "Ward") .. " to move to."
		end
		if arg == life.district then
			return nil, "You already live there."
		end
	end
	local report = newReport()
	local cost = self:activityCost(life, act)
	local budget = self:budgetOf(act)
	life[budget] = (life[budget] or 0) - 1
	life.lastChoice, life.lastClash, life.lastHit = act.name, nil, nil
	life.actUsed[act.id] = life.age
	if cost > 0 then
		life.money -= cost
	end
	-- activities done with a linked friend are about one of them
	if act.when and (act.when.linked or act.when.linkedRough) then
		self:pickFocus(life, act.when)
	end
	local actTitle = self:render(life, act.name)
	self:push(life, report, { kind = "event", title = actTitle, thread = if self:budgetOf(act) == "socialLeft" then "people" else "you" })
	life.scene = actTitle
	local extra = {}
	if act.move == "charter" then
		self:moveSide(life, self.pack.sides.order[1], extra)
	elseif act.move == "gutters" then
		self:moveSide(life, self:arrivalSide(), extra)
	elseif act.move == "district" then
		self:moveDistrict(life, arg, extra)
	end
	-- (v0.13) a fight over a block is with whoever holds the block (Engine/Turf.luau)
	local option = act
	if act.turfFoe and act.clash then
		local foe = self:turfFoe(life)
		if foe then
			option = table.clone(act)
			option.clash = table.clone(act.clash)
			option.clash.enemy = foe
		end
	end
	self:resolveOption(life, option, report, approachId, self:workCtx(life))
	life.scene = nil
	life.focusLink = nil
	for _, e in extra do
		self:push(life, report, e)
	end
	-- today's event: once a day per player, the same scene for everyone on the server
	if act.daily then
		life.dailyDay = self.dayNumber
		report.dailyDone = self.dayNumber
		local def = self:dailyDef(life)
		if def then
			table.insert(life.queue, 1, def.event)
		end
	end
	self:advance(life, report)
	self:checkAmbitions(life, report)
	return report
end

-- ── interactions: things you do with one person ─────────────────────────────

function Sim:relationById(life, relId: number)
	for _, rel in life.relations do
		if rel.id == relId then
			return rel
		end
	end
	return nil
end

-- returns visible, enabled, reason
function Sim:interactionState(life, rel, id: string): (boolean, boolean, string?)
	local def = self.pack.interactions and self.pack.interactions[id]
	if not def or not rel or not rel.alive then
		return false, false, nil
	end
	local isLinked = rel.userId ~= nil
	-- (v0.12) an interaction can also wait on the life itself (def.when): no second household
	if def.when and not Conditions.check(def.when, life, self.pack, { noChance = true }) then
		return false, false, nil
	end
	if def.linked == true and not isLinked then
		return false, false, nil
	end
	if def.linked == false and isLinked then
		return false, false, nil
	end
	if def.kinds and not isLinked and not Util.contains(def.kinds, rel.kind) then
		return false, false, nil
	end
	if def.kinds and isLinked and not Util.contains(def.kinds, "friend") then
		return false, false, nil
	end
	if def.minAge and life.age < def.minAge then
		return false, false, nil
	end
	if def.relMinAge and rel.age < def.relMinAge then
		return false, false, nil
	end
	if def.relMaxAge and rel.age > def.relMaxAge then
		return false, false, nil
	end
	if not life.alive then
		return true, false, "This life is over"
	end
	if life.pending then
		return true, false, "Decide first"
	end
	if def.online and not rel.online then
		return true, false, "They're away"
	end
	if def.minBond and rel.bond < def.minBond then
		return true, false, "Needs a bond of " .. def.minBond
	end
	if def.maxBond and rel.bond > def.maxBond then
		return true, false, "Nothing to make up for"
	end
	if (def.actions or 1) > 0 and (life[self:socialKey()] or 0) <= 0 then
		return true, false, if self.pack.meta.socialPerYear then "No time left for people this year" else "No actions left this year"
	end
	local cost = def.cost or 0
	if cost > 0 and life.money < cost then
		return true, false, "Needs " .. cost .. " " .. self.pack.meta.currency
	end
	local last = rel.talked and rel.talked[id]
	if def.cooldown and last and life.age - last < def.cooldown then
		local wait = def.cooldown - (life.age - last)
		return true, false, "Again in " .. wait .. (if wait == 1 then " year" else " years")
	end
	return true, true, nil
end

function Sim:interactionTokens(life, rel)
	local kindDef = self.pack.relationKinds[rel.kind] or {}
	return {
		rel = rel.first,
		relName = rel.first .. (if rel.last ~= "" then " " .. rel.last else ""),
		relKind = string.lower(if rel.userId then "friend" else (kindDef.name or rel.kind)),
		target = rel,
	}
end

-- a scene for an evening with this person: one that fits who they are to you and how close you
-- are, and that you haven't just had with them
-- the scenes an evening with this person could be (and how likely each), without rolling
function Sim:socialSceneList(life: any, rel: any): (any, any)
	local list: any, weights: any = {}, {}
	if not self.socialScenes or #self.socialScenes == 0 then
		return list, weights
	end
	local kind = if rel.userId then "friend" else rel.kind
	local seen = (rel.scenes or {}) :: any
	for _, e in self.socialScenes do
		local s = e.social
		local ok = (s.kinds == nil or table.find(s.kinds, kind) ~= nil)
			and (rel.bond or 0) >= (s.minBond or 0)
			and (rel.bond or 0) <= (s.maxBond or 100)
			and (rel.age or 0) >= (s.relMinAge or 0)
			and (rel.age or 0) <= (s.relMaxAge or 999)
			and life.age >= (s.minAge or 0)
			and life.age <= (s.maxAge or 999)
			and Conditions.check(e.when, life, self.pack, { noChance = true })
		if ok then
			local last = seen[e.id]
			table.insert(list, e)
			-- fresh scenes first; one you've had with them comes round again after a few years
			table.insert(weights, if last == nil then 10 elseif life.age - last >= 4 then 2 else 0.1)
		end
	end
	return list, weights
end

function Sim:pickSocialScene(life: any, rel: any): any
	local list, weights = self:socialSceneList(life, rel)
	if #list == 0 then
		return nil
	end
	local idx = Rng.weighted(life, weights)
	return if idx then list[idx] else nil
end

function Sim:interactionsFor(life, rel)
	local list = {}
	local pack = self.pack
	if not pack.interactions then
		return list
	end
	for _, id in pack.interactions.order or {} do
		local visible, enabled, why = self:interactionState(life, rel, id)
		if visible then
			local def = pack.interactions[id]
			local tokens = self:interactionTokens(life, rel)
			tokens.target = nil
			-- an evening that opens a scene gives what you choose in it, not the plain result
			local scene = def.scenes == true and #self:socialSceneList(life, rel) > 0
			local with = { target = rel }
			table.insert(list, {
				id = id,
				name = self:render(life, def.name, tokens),
				desc = self:render(life, def.desc, tokens),
				enabled = enabled,
				reason = why,
				cost = def.cost,
				clash = if def.clash and enabled then self:clashPreview(life, def.clash) else nil,
				scene = scene or nil,
				gains = if scene then nil elseif def.result then self:stakesOf(def.result, nil, nil, life, with) elseif def.win then self:stakesOf(def.win, nil, nil, life, with) else nil,
				stakes = if def.clash and enabled and not scene then self:stakesView(def, life, with) else nil,
			})
		end
	end
	return list
end

function Sim:interact(life: any, relId: number, id: string, approachId: string?)
	local rel = self:relationById(life, relId)
	local def = self.pack.interactions and self.pack.interactions[id]
	if not rel or not def then
		return nil, "You can't do that."
	end
	local visible, enabled, why = self:interactionState(life, rel, id)
	if not visible or not enabled then
		return nil, why or "Not right now."
	end
	if life.run then
		return nil, "Finish your expedition first."
	end
	if life.battle or life.battleWith or life.duel then
		return nil, "Finish the fight first."
	end
	local report = newReport()
	local budget = self:socialKey()
	life[budget] = (life[budget] or 0) - (def.actions or 1)
	life.lastChoice, life.lastClash, life.lastHit = def.name, nil, nil
	if (def.cost or 0) > 0 then
		life.money -= def.cost
	end
	rel.talked = rel.talked or {}
	rel.talked[id] = life.age
	self:tally(life, "interactions")
	if id == "teach" then
		rel.taught = (rel.taught or 0) + 1
	end
	if rel.userId then
		life.focusLink = rel.id
	end
	local tokens = self:interactionTokens(life, rel)
	local display = table.clone(tokens)
	display.target = nil
	-- an evening with someone is a scene with choices, when the pack has one for them
	local scene = if def.scenes then self:pickSocialScene(life, rel) else nil
	if scene then
		rel.scenes = rel.scenes or {}
		rel.scenes[scene.id] = life.age
		life.sceneRel = rel.id
		table.insert(life.queue, 1, scene.id)
		self:advance(life, report)
		if life.pending ~= scene.id then
			life.sceneRel = nil
		end
		self:checkAmbitions(life, report)
		return report
	end
	self:push(life, report, { kind = "event", title = self:render(life, def.name, display) .. ": " .. tokens.relName, thread = "people" })
	local option = def
	local swap = def.logs and def.logs[if rel.userId then "friend" else rel.kind]
	if swap and def.result then
		option = table.clone(def)
		option.result = table.clone(def.result)
		option.result.log = swap
	end
	self:resolveOption(life, option, report, approachId, tokens)
	life.focusLink = nil
	self:advance(life, report)
	self:checkAmbitions(life, report)
	return report
end

function Sim:careerState(life, id: string): (boolean, string?)
	local def = self.pack.careers[id]
	if not def then
		return false, "Unknown"
	end
	if def.company and not self:districtDef(life).corp then
		return false, self.pack.meta.unheldShort or ("No company holds this " .. (self.pack.meta.districtWord or "Ward"))
	end
	if life.career and life.career.id == id and (not def.company or life.career.district == life.district) then
		return false, "Your current job"
	end
	if life.age < (def.minAge or 16) then
		return false, "Age " .. (def.minAge or 16) .. "+"
	end
	if def.sides and not Util.contains(def.sides, life.side) then
		local s = self.pack.sides[def.sides[1]]
		return false, "Only in " .. (if s then s.short else def.sides[1])
	end
	local ok, why = Conditions.check(def.requires, life, self.pack, { noChance = true })
	if not ok then
		return false, why
	end
	if def.guttersRequire and life.side ~= self.pack.sides.order[1] then
		local ok2, why2 = Conditions.check(def.guttersRequire, life, self.pack, { noChance = true })
		if not ok2 then
			local far = self.pack.sides[self.pack.sides.order[2]]
			return false, (why2 or "Not hiring") .. " (from " .. (if far then far.name else "the Gutters") .. ")"
		end
	end
	if life.pending then
		return false, "Decide first"
	end
	if life.actionsLeft <= 0 then
		return false, "No actions left this year"
	end
	return true, nil
end

function Sim:joinCareer(life, id: string)
	local ok, why = self:careerState(life, id)
	if not ok then
		return nil, why
	end
	if life.run then
		return nil, "Finish your expedition first."
	end
	if life.battle or life.battleWith or life.duel then
		return nil, "Finish the fight first."
	end
	local report = newReport()
	life.actionsLeft -= 1
	local extra = {}
	self:setCareer(life, id, extra)
	for _, e in extra do
		self:push(life, report, e)
	end
	self:checkAmbitions(life, report)
	return report
end

function Sim:leaveCareer(life)
	if not life.alive or not life.career then
		return nil, "You don't have a job."
	end
	local report = newReport()
	local extra = {}
	self:quitCareer(life, extra)
	for _, e in extra do
		self:push(life, report, e)
	end
	return report
end

-- ── views & records ─────────────────────────────────────────────────────────

-- A client-safe snapshot of a life (no RNG state, no hidden queue).
function Sim:traitsView(life)
	local out = {}
	for _, id in life.traits or {} do
		local def = self:traitDef(id)
		if def then
			table.insert(out, { id = id, name = def.name, desc = def.desc, rarity = def.rarity })
		end
	end
	return out
end

function Sim:talentView(life)
	local def = life.talent and self:traitDef(life.talent)
	if not def then
		return nil
	end
	local tier = self:talentTier(def.talent)
	local aff = def.affinity and self.pack.affinities and self.pack.affinities[def.affinity]
	return Talent.viewExtra(self, life, {
		id = life.talent,
		name = def.name,
		desc = def.desc,
		tier = def.talent,
		tierName = tier and tier.name,
		color = tier and tier.color,
		affinity = def.affinity,
		affinityName = aff and aff.name,
		affinityColor = aff and aff.color,
		resonance = self:resonates(life),
	})
end

-- the life's sins (names and colors), for the HUD
function Sim:affinitiesView(life)
	local out = {}
	local defs = self.pack.affinities
	for _, id in life.affinities or {} do
		local a = defs and defs[id]
		if a then
			table.insert(out, { id = id, name = a.name, color = a.color })
		end
	end
	return out
end

-- the books and scrolls this life holds: what each teaches, whether it can be read now, and
-- if not, why (the screen lists them with a Read button)
function Sim:booksView(life)
	local out = {}
	for _, id in life.books or {} do
		local def = self:bookDef(id)
		if def then
			local teaches = def.trait and self:traitDef(def.trait)
			local act = self.activitiesById["read_" .. id]
			local enabled, why = false, nil
			if act then
				local _, can, reason = self:activityState(life, act)
				enabled, why = can, reason
			end
			table.insert(out, {
				id = id,
				name = def.name,
				desc = def.desc,
				rarity = def.rarity,
				teaches = teaches and teaches.name,
				teachesDesc = teaches and teaches.desc,
				mastery = def.mastery,
				needs = if def.schools then self:schoolNames(def.schools) else nil,
				trained = def.schools == nil or (life.school ~= nil and table.find(def.schools, life.school) ~= nil),
				activity = if act then act.id else nil,
				canRead = enabled,
				reason = why,
			})
		end
	end
	return out
end

function Sim:styleView(life)
	local styles = self.pack.styles
	local def = styles and life.style and styles[life.style]
	if not def then
		return nil
	end
	return {
		id = life.style,
		name = def.name,
		desc = def.desc,
		color = def.color,
		mastery = life.mastery or 0,
		maxMastery = self.pack.maxMastery or 5,
		potency = self:fightPotency(life),
		school = self:schoolView(life),
		cap = self:masteryCap(life),
	}
end

function Sim:schoolView(life)
	local school = self:schoolDef(life)
	if not school then
		return nil
	end
	return { id = life.school, name = school.name, org = school.org, desc = school.desc, training = self:inSchool(life), free = school.free == true }
end

-- Today's event, if it belongs to the age this life is living in (daily.eras).
function Sim:dailyDef(life)
	local def = self.dailyId and self.pack.daily and self.pack.daily[self.dailyId]
	if not def then
		return nil
	end
	if def.eras and life and life.world and not table.find(def.eras, life.world.era) then
		return nil
	end
	return def
end

function Sim:dailyView(life)
	local def = self:dailyDef(life)
	if not def then
		return nil
	end
	return { id = self.dailyId, name = def.name, desc = def.desc, day = self.dayNumber, done = life.dailyDay == self.dayNumber }
end

-- (v0.12) everything the screen is told about a life: Engine/View.luau
function Sim:view(life: any): any
	local v = View.view(self, life)
	-- (v0.18) every view of a life is numbered, in the order the server made them: a client that
	-- gets an older one after a newer one (a push that crossed a reply) can tell, and keep the newer
	self.viewSeq = (self.viewSeq or 0) + 1
	if type(v) == "table" then
		v.seq = self.viewSeq
		-- (BitLeveling) the Gates around this life, in brief (the full board: HunterWorld.view)
		if life.gw and self.pack.hunterWorld then
			v.hw = HunterWorld.summary(self, life)
		end
	end
	return v
end

-- Static Ward/side info for the UI (sent once).
function Sim:cityInfo()
	local pack = self.pack
	local districts = {}
	for _, id in pack.districts.order do
		local d = pack.districts[id]
		table.insert(districts, {
			id = id,
			name = d.name,
			number = d.number,
			corp = d.corp,
			trade = d.trade,
			desc = d.desc,
			wealth = d.wealth or 1,
			danger = d.danger or 1,
			cost = d.cost or 0,
			charterCost = d.charterCost or 0,
			charterShare = d.charterShare or 0,
			color = d.color,
			music = d.music,
			backdrop = d.backdrop,
		})
	end
	local sides = {}
	for _, id in pack.sides.order do
		local s = pack.sides[id]
		table.insert(sides, {
			id = id,
			name = s.name,
			short = s.short,
			desc = s.desc,
			costMult = s.costMult or 1,
			payMult = s.payMult or 1,
			danger = s.danger or 1,
			color = s.color,
		})
	end
	return { districts = districts, sides = sides, word = pack.meta.districtWord or "District" }
end


return Sim
