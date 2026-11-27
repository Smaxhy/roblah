--[[
	BASE: turns a game SPEC (one Luau table) and the content modules beside it into a whole
	content pack the engine, the server and the client can run.

		-- src/shared/Games/<Id>/init.luau
		local Base = require(script.Parent.Parent:WaitForChild("Base"))
		return Base.build(require(script:WaitForChild("Spec")), script)

	The folder of a game (src/shared/Games/<Id>/):
		Spec.luau            the spec: everything about the game in one table (spec/SPEC.md)
		Events/              ModuleScripts, each a list of events (the cards)
		Careers.luau         optional: a list of careers (or { order, [id] })
		Activities.luau      optional: a list of activities
		Expeditions.luau     optional: dungeons, missions and trips: { order, [id] }
		Bosses.luau          optional: turn-based bosses: { [id] = boss }
		Foes.luau            optional: a list of foes (who you fight: looks, tempers, barks)
		Gear.luau            optional: a list of gear items
		Store.luau           optional: { note, items } (what the store sells)
	Anything a module gives is added to what the spec gives; ids must be unique.

	Every system has a working default (Base/Systems.luau, Base/Stats.luau,
	Base/Activities.luau, Base/Events.luau, Base/Cosmetics.luau). A spec only says what makes
	its game different. The pack is checked by Engine/Validate.luau at boot (and in the tests).
]]

local Stats = require(script:WaitForChild("Stats"))
local Systems = require(script:WaitForChild("Systems"))
local Activities = require(script:WaitForChild("Activities"))
local BaseEvents = require(script:WaitForChild("Events"))
local Cosmetics = require(script:WaitForChild("Cosmetics"))

local Base = {}
Base.Stats = Stats
Base.Systems = Systems

local deepCopy = Systems.deepCopy
local merge = Systems.merge

local function child(folder: Instance?, name: string): Instance?
	if not folder then
		return nil
	end
	return (folder :: any):FindFirstChild(name)
end

local function requireChild(folder: Instance?, name: string): any
	local c = child(folder, name)
	if c and c:IsA("ModuleScript") then
		return require(c :: any)
	end
	return nil
end

-- a list of { id = ... } (or { order, [id] }) as { order = { ids }, [id] = def }
local function keyed(into: any, more: any, issues: { string }, what: string)
	if type(more) ~= "table" then
		return
	end
	local function add(id: any, def: any)
		if type(id) ~= "string" or type(def) ~= "table" then
			return
		end
		if into[id] ~= nil then
			table.insert(issues, what .. ": duplicate id '" .. id .. "'")
			return
		end
		def.id = def.id or id
		into[id] = def
		table.insert(into.order, id)
	end
	if more.order then
		for _, id in more.order do
			add(id, more[id])
		end
	elseif #more > 0 then
		for _, def in more do
			add(def.id, def)
		end
	else
		for id, def in more do
			add(id, def)
		end
	end
end

local function append(into: { any }, more: any)
	if type(more) ~= "table" then
		return
	end
	for _, v in more do
		table.insert(into, v)
	end
end

local DEFAULT_META = {
	title = "A Life",
	tagline = "One life, a year at a time.",
	about = "One whole life, a year at a time. What you do and who you cross decide how it ends. Then the next one begins.",
	currency = "coins",
	lanternName = "Story",
	ledgerName = "Your Stories",
	glowName = "Stars",
	premiumName = "Gems",
	districtWord = "Town",
	actionsPerYear = 4,
	socialPerYear = 3,
	adultAge = 18,
	maxLogEntries = 400,
	birthHint = "Where you're born is up to the dice. The rest is up to you.",
	releaseVerb = "Keep",
	releaseToast = "The story goes onto the shelf with the others.",
	dailyTitle = "Daily visit",
	arrivalName = "town",
	emptyLedger = "No stories yet. Every life that ends is written down and kept here.",
}

local DEFAULT_SIDES = {
	{ id = "uptown", name = "Uptown", short = "Uptown", desc = "The good side: clean streets, guards on the corners, rent that hurts.", costMult = 2, payMult = 1.25, danger = 0.35, hazardChance = 0.08, evictOnDebt = true, evictGrace = 1, wear = 0, tagWeights = { crime = 0.4, luxury = 2 }, color = { 226, 214, 170 } },
	{ id = "downtown", name = "Downtown", short = "Downtown", desc = "Everywhere else: cheap rent, loud nights, and trouble close by.", costMult = 0.6, payMult = 0.9, danger = 1, hazardChance = 0.28, wear = 1, tagWeights = { luxury = 0.3 }, color = { 170, 130, 120 } },
}

local DEFAULT_DISTRICTS = {
	{ id = "home", name = "Hometown", desc = "Where it all starts.", wealth = 1, danger = 1, cost = 50, charterCost = 1500, charterShare = 0.3, population = 1 },
}

local DEFAULT_FOES = {
	{ id = "bully", name = "Bully", temper = "brute", look = { skin = "sand", hair = "crop", hairColor = "umber", eyes = "brown", outfit = "hoodie" }, barks = { start = { "Hand it over." }, win = { "Stay down." }, lose = { "Okay! Okay!" } } },
	{ id = "thug", name = "Thug", temper = "brute", ability = { id = "bleed", potency = 1 }, look = { skin = "amber", hair = "shorn", hairColor = "charcoal", eyes = "brown", outfit = "work_overalls", mark = "scar", weapon = "nail_bat" }, barks = { start = { "Wallet. Now.", "Nothing personal." }, win = { "Should've paid." }, lose = { "Fine, fine, keep it!" } } },
	{ id = "guard", name = "Guard", temper = "cunning", ability = { id = "guard", potency = 1 }, look = { skin = "honey", hair = "crop", hairColor = "chestnut", eyes = "hazel", outfit = "hired_guard", weapon = "spear" }, barks = { start = { "Halt." }, win = { "Move along." }, lose = { "...Go." } } },
}

local function sideList(spec: any): { any }
	local w = spec.world or {}
	return w.sides or DEFAULT_SIDES
end

-- build the pack
function Base.build(spec: any, folder: Instance?): any
	spec = spec or {}
	local pack: any = { mergeIssues = {} }
	local issues = pack.mergeIssues

	pack.id = spec.id
	pack.fanWork = spec.fanWork == true
	pack.quickChecks = spec.quickChecks ~= false
	pack.modernCreator = true -- the one-screen creator (client/UI/QuickStart.luau)
	pack.creatorPicks = spec.creatorPicks == true -- births are rolled (no origin or place picks)
	pack.meta = merge(DEFAULT_META, spec.meta)
	local meta = pack.meta
	pack.calendar = merge({ startYear = 1000, startJitter = 3 }, spec.calendar)

	-- ── stats ──
	local stats, roles, approachNames, moodName = Stats.build(spec)
	pack.stats = stats
	pack.roles = roles -- (handy for a game's own modules: Base.roles(pack).fight.id)

	-- ── the world: sides and places ──
	local sides = sideList(spec)
	pack.sides = { order = {} }
	for _, s in sides do
		local def = deepCopy(s)
		def.short = def.short or def.name
		def.costMult = def.costMult or 1
		def.payMult = def.payMult or 1
		def.danger = def.danger or 1
		def.hazardChance = def.hazardChance or 0.2
		def.wear = def.wear or 0
		pack.sides[s.id] = def
		table.insert(pack.sides.order, s.id)
	end
	pack.districts = { order = {} }
	for i, d in (spec.world and spec.world.districts) or DEFAULT_DISTRICTS do
		local def = deepCopy(d)
		def.number = def.number or i
		def.desc = def.desc or ""
		def.wealth = def.wealth or 1
		def.danger = def.danger or 1
		def.cost = def.cost or 50
		def.charterCost = def.charterCost or def.moveCost or 1500
		def.charterShare = def.charterShare or def.share or 0.3
		def.population = def.population or 1
		pack.districts[d.id] = def
		table.insert(pack.districts.order, d.id)
	end
	-- world variables (a river's level, a war on or off...): { key, name, values, labels, start, shift }
	pack.world = deepCopy(spec.world and spec.world.vars) or {}

	-- ── careers ──
	pack.careers = { order = {} }
	keyed(pack.careers, deepCopy(spec.careers), issues, "careers")
	keyed(pack.careers, requireChild(folder, "Careers"), issues, "Careers")

	-- ── forms, people ──
	pack.forms = merge({ human = { name = "Human", desc = "The usual." } }, spec.forms)
	pack.relationKinds = merge(Systems.RELATION_KINDS, spec.people and spec.people.kinds)
	pack.acquaintances = Systems.acquaintances(spec)
	pack.interactions = Systems.interactions(roles)
	for id, def in (spec.people and spec.people.interactions) or {} do
		if pack.interactions[id] == nil then
			table.insert(pack.interactions.order, id)
		end
		pack.interactions[id] = def
	end

	-- ── origins ──
	pack.origins = deepCopy(spec.origins) or {
		{
			id = "ordinary",
			name = "Ordinary Family",
			desc = "Two tired parents and a roof that mostly holds.",
			birth = "You were born to two tired parents in {zone}.",
			money = 15,
			family = { mother = true, father = true, siblings = { 0, 2 } },
			glowCost = 0,
		},
	}

	-- ── activities ──
	pack.activityCategories = merge(Activities.CATEGORIES, spec.activityCategories)
	local drop = {}
	for _, id in spec.dropActivities or {} do
		drop[id] = true
	end
	pack.activities = {}
	for _, act in Activities.build(roles, sides) do
		if not drop[act.id] then
			local re = spec.activityText and spec.activityText[act.id]
			if re then
				act.name = re.name or act.name
				act.desc = re.desc or act.desc
				if re.log and act.result then
					act.result.log = re.log
				end
			end
			table.insert(pack.activities, act)
		end
	end
	append(pack.activities, deepCopy(spec.activities))
	append(pack.activities, requireChild(folder, "Activities"))

	-- ── gear ──
	local gearSpec = spec.gear or {}
	pack.gear = { slots = gearSpec.slots or { "tool", "coat", "charm" }, order = {} }
	keyed(pack.gear, deepCopy(gearSpec.items), issues, "gear")
	keyed(pack.gear, requireChild(folder, "Gear"), issues, "Gear")

	-- ── conditions, hazards ──
	pack.conditions = merge(Systems.conditions(roles), spec.conditions)
	pack.hazards = Systems.hazards(roles, pack.sides.order)
	if spec.baseHazards == false then
		pack.hazards = {}
	end
	append(pack.hazards, deepCopy(spec.hazards))

	-- ── how dangerous it is ──
	local tuning = merge(Systems.TUNING, spec.tuning)
	for k, v in tuning do
		pack[k] = v
	end

	-- ── how you fight ──
	pack.tempers = deepCopy(Systems.TEMPERS)
	pack.matchup = { bonus = 2, penalty = 2 }
	pack.approaches = Systems.approaches(spec, roles, approachNames)
	pack.abilities = deepCopy(Systems.ABILITIES)
	pack.statuses = deepCopy(Systems.STATUSES)
	for id, s in (spec.vfx and spec.vfx.statuses) or {} do
		if pack.statuses[id] then
			pack.statuses[id].name = s.name or pack.statuses[id].name
			pack.statuses[id].color = s.color or pack.statuses[id].color
		end
		if pack.abilities[id] and s.name then
			pack.abilities[id].name = s.name
		end
	end
	pack.difficulties = merge(Systems.DIFFICULTIES, spec.difficulties)

	-- ── a life's goals, titles and records ──
	pack.records = Systems.records(roles)
	for _, r in pack.records do
		r.desc = string.gsub(r.desc, "{currency}", meta.currency)
	end
	append(pack.records, deepCopy(spec.records))
	pack.ambitions = Systems.ambitions(roles, meta.currency)
	append(pack.ambitions, deepCopy(spec.ambitions))
	pack.ribbons = deepCopy(spec.ribbons) or {}
	append(pack.ribbons, Systems.ribbons())

	-- ── looks ──
	pack.cosmetics = deepCopy(Cosmetics)
	for category, options in (spec.looks or {}) do
		local cat = pack.cosmetics[category]
		if type(cat) == "table" and type(cat.options) == "table" and type(options) == "table" then
			for _, o in options do
				table.insert(cat.options, deepCopy(o))
			end
		elseif category == "identities" and type(options) == "table" then
			pack.cosmetics.identities = deepCopy(options)
		end
	end

	-- ── names, endings ──
	pack.names = merge(Systems.NAMES, spec.names)
	pack.epitaphs = merge(Systems.EPITAPHS, spec.epitaphs)
	pack.deathCauses = merge(Systems.DEATH_CAUSES, spec.deathCauses)
	pack.hooks = merge({ breakingPoint = "base_breaking_point" }, spec.hooks)

	-- ── who you fight ──
	pack.foes = { order = {}, match = deepCopy(spec.foeMatch) or {} }
	keyed(pack.foes, deepCopy(DEFAULT_FOES), issues, "foes")
	keyed(pack.foes, deepCopy(spec.foes), issues, "foes")
	keyed(pack.foes, requireChild(folder, "Foes"), issues, "Foes")
	for _, id in pack.foes.order do
		local f = pack.foes[id]
		f.kind = f.kind or "human"
	end
	pack.bosses = {}
	for id, b in deepCopy(spec.bosses) or {} do
		pack.bosses[id] = b
	end
	for id, b in requireChild(folder, "Bosses") or {} do
		if pack.bosses[id] then
			table.insert(issues, "Bosses: duplicate id '" .. tostring(id) .. "'")
		end
		pack.bosses[id] = b
	end

	-- ── dungeons, missions, trips ──
	pack.expeditions = { order = {} }
	keyed(pack.expeditions, deepCopy(spec.dungeons), issues, "dungeons")
	keyed(pack.expeditions, requireChild(folder, "Expeditions"), issues, "Expeditions")
	for _, id in pack.expeditions.order do
		pack.expeditions[id].id = nil -- (an expedition's id is its key)
	end

	-- ── the store ──
	pack.store = deepCopy(spec.store) or requireChild(folder, "Store")

	-- ── the menu, the intro, the guide, the tutorial ──
	local theme = spec.theme or {}
	pack.modes = deepCopy(spec.modes) or {
		{ id = "life", name = meta.title, tagline = meta.tagline, desc = meta.about, color = theme.accent or { 207, 163, 73 } },
	}
	pack.intro = merge({
		title = meta.title,
		subtitle = meta.tagline,
		lines = { meta.about, "You're about to be born." },
	}, spec.intro)
	pack.tutorial = merge(Systems.tutorial(roles, approachNames), spec.tutorial)
	pack.guide = merge({
		basics = {
			{ title = "A year at a time", text = "Press +1 YEAR to live another year. Every year brings cards to answer, and you have a few things to do with it (the DO tab) and some time for people (PEOPLE)." },
			{ title = "Stats", text = string.format("%s keeps you alive. %s, %s, %s, %s, %s and %s are what you do things with. %s is your mood: low %s makes every coin flip worse.", roles.health.name, roles.fight.name, roles.speed.name, roles.work.name, roles.charm.name, roles.luck.name, roles.will.name, moodName, moodName) },
			{ title = "Fights", text = string.format("In a fight you pick how to fight: %s, %s, %s or %s. Every foe has a temper, and one way of fighting beats it.", approachNames.fight, approachNames.speed, approachNames.work, approachNames.charm) },
			{ title = "When it ends", text = string.format("Every life ends. What it was becomes a %s, and %s, kept in %s.", string.lower(meta.lanternName), string.lower(meta.glowName), meta.ledgerName) },
		},
	}, spec.guide)
	if spec.lore then
		pack.codex = { entries = deepCopy(spec.lore) }
	end

	-- ── what the client draws (client/UI/Theme, Stage, Fx3D, App) ──
	pack.theme = deepCopy(spec.theme)
	pack.backdrop = spec.backdrop or "city"
	pack.places = deepCopy(spec.places)
	pack.vfx = deepCopy(spec.vfx)

	-- ── the cards ──
	local events = {}
	for _, e in BaseEvents.build(roles) do
		if spec.baseEvents ~= false or e.id == "base_breaking_point" then
			e.source = "Base"
			table.insert(events, e)
		end
	end
	local evFolder = child(folder, "Events")
	if evFolder then
		local modules = evFolder:GetChildren()
		table.sort(modules, function(a, b)
			return a.Name < b.Name
		end)
		for _, m in modules do
			if m:IsA("ModuleScript") then
				for _, e in require(m :: any) do
					e.source = e.source or m.Name
					table.insert(events, e)
				end
			end
		end
	end
	for _, e in deepCopy(spec.events) or {} do
		e.source = e.source or "Spec"
		table.insert(events, e)
	end
	pack.events = events

	-- ── the picture behind each card (client/SceneArt.luau draws these) ──
	-- A game's own places are scenes too: a card with `art = "<place id>"` (or with one of the
	-- place's `words` in its title or text) plays its cutscenes and fights in that 3D place, and
	-- its 2D banner draws the place's `scene` (one of Base.SCENES; "street" if it has none).
	pack.scenes = deepCopy(spec.scenes) or deepCopy(Base.SCENES)
	local placeWords = {}
	for _, place in pack.places or {} do
		if type(place) == "table" and type(place.id) == "string" then
			if not table.find(pack.scenes, place.id) then
				table.insert(pack.scenes, place.id)
			end
			for _, w in place.words or {} do
				table.insert(placeWords, { string.lower(w), place.id })
			end
		end
	end
	for _, e in events do
		if type(e) == "table" and e.art == nil then
			e.art = Base.artFor(e, placeWords)
		end
	end

	-- a look locked behind a record this game doesn't have unlocks with the meta currency instead
	local known = {}
	for _, r in pack.records do
		known[r.id] = true
	end
	-- and a look sold by a store item this game doesn't sell unlocks with it too (a game's own
	-- store sells its own looks: grants = { "outfit:<id>" }, or `store = "<key>"` on the look)
	local sold = {}
	for _, item in (pack.store and pack.store.items) or {} do
		if type(item) == "table" and item.key then
			sold[item.key] = true
		end
	end
	for _, cat in pack.cosmetics do
		if type(cat) == "table" and type(cat.options) == "table" then
			for _, o in cat.options do
				if type(o) == "table" and o.record and not known[o.record] then
					o.record = nil
					o.glow = o.glow or 4
				end
				if type(o) == "table" and type(o.store) == "string" and not sold[o.store] then
					o.store = nil
					o.glow = o.glow or 6
				end
			end
		end
	end

	-- ── anything else the spec sets directly on the pack (an advanced game's own systems:
	-- renown, offices, talents, storylines... see the City pack for the shapes) ──
	for k, v in spec.pack or {} do
		pack[k] = deepCopy(v)
	end
	return pack
end

-- the scenes client/SceneArt.luau can draw behind a card (an event's `art`)
Base.SCENES = {
	"home", "alley", "street", "rooftop", "night", "nest", "checkpoint", "wing", "lcorp", "office", "workshop",
	"diner", "clinic", "school", "train", "syndicate", "hall", "library", "outskirts", "ruins", "market", "arena",
	"theater", "distortion", "underpass", "bus",
}
-- a card with no `art` gets one from the words in it
local ART_WORDS = {
	{ "clinic", "clinic" }, { "healer", "clinic" }, { "doctor", "clinic" }, { "hospital", "clinic" }, { "workshop", "workshop" },
	{ "forge", "workshop" }, { "smithy", "workshop" }, { "train", "train" }, { "rooftop", "rooftop" }, { "roof", "rooftop" },
	{ "tower", "rooftop" }, { "gate", "checkpoint" }, { "checkpoint", "checkpoint" }, { "library", "library" },
	{ "books", "library" }, { "wilds", "outskirts" }, { "forest", "outskirts" }, { "road", "outskirts" }, { "market", "market" },
	{ "shop", "market" }, { "school", "school" }, { "lesson", "school" }, { "academy", "school" }, { "theater", "theater" },
	{ "stage", "theater" }, { "night", "night" }, { "midnight", "night" }, { "office", "office" }, { "guild", "office" },
	{ "alley", "alley" }, { "ruins", "ruins" }, { "rubble", "ruins" }, { "crypt", "ruins" }, { "cave", "underpass" },
	{ "tunnel", "underpass" }, { "sewer", "underpass" }, { "arena", "arena" }, { "tournament", "arena" }, { "palace", "hall" },
	{ "castle", "hall" }, { "hall", "hall" }, { "temple", "hall" }, { "kitchen", "home" }, { "home", "home" },
	{ "bedroom", "home" }, { "cart", "bus" }, { "carriage", "bus" }, { "inn", "diner" }, { "diner", "diner" },
}
function Base.artFor(e: any, placeWords: any?): string
	local function plain(t: any): string
		return if type(t) == "table" then tostring(t[1] or "") else tostring(t or "")
	end
	local hay = string.lower(plain(e.title) .. " " .. plain(e.text))
	for _, w in placeWords or {} do
		if string.find(hay, "%f[%w]" .. w[1] .. "%f[%W]") then
			return w[2]
		end
	end
	for _, w in ART_WORDS do
		if string.find(hay, "%f[%w]" .. w[1] .. "%f[%W]") then
			return w[2]
		end
	end
	return "street"
end

-- the role -> stat def table (fight, speed, work, charm, luck, will, health) of a built pack
function Base.roles(pack: any): any
	return pack.roles
end

return Base
