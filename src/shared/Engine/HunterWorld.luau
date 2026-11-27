--[[
	HUNTER WORLD: the Gates as a living world (BitLeveling).

	Gates are not menu portals here. Every year of a life, the world around it makes Gates
	of its own: where they open, how strong they are, whether anyone notices, who answers,
	and whether they're cleared or break. A life is only pulled in when it's actually there
	(it lives in that city, it's a Hunter the raid calls on, it's caught in the street).
	Everything else reaches it the way it reaches real people: the news.

	Pure Luau (no Roblox services), deterministic on the life's own RNG, so the headless
	tests can live thousands of lives with it. The server's live 3D incidents use the same
	spawn/lifecycle code on a clock (server/HunterWorld.luau).

	One shared world state per life (life.gw), and one place every system reads and writes:
		life.gw = {
			mode        "normal" | "crisis"  (pack.hunterWorld.modes)
			serial      incidents made so far (ids)
			recent      the last few incidents near this life, for the incident board
			news        headlines: { year, tag, tone, text }  (local, national, world, canon)
			history     what this life lived through: { year, age, kind, rank, role, outcome }
			byEvent     [event id] = the incident a queued card is about (its {tokens})
			damage      [district id] = how hard a district was hit (heals a little a year)
			lost        [district id] = true for places the Gates took (nobody lives there)
			canonDone   [canon id] = true once a timeline entry has happened in this life
			counts      { witnessed, survived, raids, breaks, red, double, saved }
		}

	THE STAGES of a Gate (every incident runs through them; not all reach every stage):
		1 appeared    the Gate opens: place, rank, kind, environment, stability
		2 discovered  someone sees it (at once in a crowded street, days later in a forest,
		              or never, until it breaks)
		3 response    the Association measures it and decides who raids it
		4 active      a raid is organised (a guild contract, an Association call, or nobody yet)
		5 resolved / escalated   cleared, or a Dungeon Break (and maybe worse)
		6 aftermath   casualties, damage, reputations, news, what's left to rebuild

	Content hooks (pack.hunterWorld.cards): the cards a life is pulled in by are ordinary
	events with weight 0 (never rolled at random) and ids `<prefix><rank letter>`, e.g.
	hw_break_C. HunterWorld queues them and fills their {g...} tokens from the incident.
	A choice can carry `hw = "<role>"` (fought, evacuated, helped, sheltered, raided,
	declined, fled, reported, filmed, entered) so the incident knows what the player did.
]]

local Rng = require(script.Parent.Rng)

local HW = {}

HW.RANKS = { "E", "D", "C", "B", "A", "S" }
HW.RANK_INDEX = { E = 1, D = 2, C = 3, B = 4, A = 5, S = 6 }
HW.STAGES = { "appeared", "discovered", "response", "active", "resolved", "aftermath" }

local NEWS_LIMIT = 48
local HISTORY_LIMIT = 80
local RECENT_LIMIT = 14

-- ── defaults (a pack's hunterWorld overrides any of these) ─────────────────
HW.DEFAULT = {
	firstYear = 0, -- the year the first Gates opened
	breakDays = 7, -- an uncleared Gate breaks after this many days
	defaultMode = "normal",
	modes = {
		normal = {
			name = "Normal World",
			localGates = 6, -- Gates a typical city sees in a year (the notable ones are simulated)
			rankWeights = { 44, 27, 16, 8, 4, 1 },
			cityShare = 0.1, -- share of Gates that open in populated places
			discovery = 1, -- how long remote Gates go unseen (x)
			responseDays = { 0, 2 },
			capacity = 1, -- what the Association and the guilds can field (x)
			raidFail = { 0.03, 0.05, 0.08, 0.12, 0.18, 0.3 },
			secondRaid = 0.85, -- a failed raid is tried again in time, if there's time
			contain = { 0.98, 0.95, 0.9, 0.82, 0.7, 0.5 }, -- a break is put down before it spreads
			loseZone = 0.04, -- an S-rank break that isn't contained can take the whole area
			red = 0.003, -- per Gate: it turns red when the raid goes in
			double = 0.00015, -- per Gate: there's a second dungeon inside
			exposure = 0.06, -- a life in that city is caught near a street incident
			breakExposure = 0.45,
			instability = 0,
			raidCall = 0.55, -- a working Hunter is called on for a Gate their rank fits
			maxCards = 2,
			lethality = 1,
			damageHeal = 2,
			national = 3, -- headlines from elsewhere in the country a year
			world = 2,
			eraBias = 1,
		},
		crisis = {
			name = "High-Danger World",
			localGates = 10,
			rankWeights = { 34, 26, 19, 12, 6.5, 2.5 },
			cityShare = 0.24,
			discovery = 1.5,
			responseDays = { 0.4, 2.4 },
			capacity = 0.74,
			raidFail = { 0.05, 0.08, 0.13, 0.2, 0.3, 0.45 },
			secondRaid = 0.6,
			contain = { 0.94, 0.86, 0.74, 0.6, 0.46, 0.28 },
			loseZone = 0.18,
			red = 0.011,
			double = 0.0009,
			exposure = 0.1,
			breakExposure = 0.22,
			instability = 0.45,
			raidCall = 0.7,
			maxCards = 3,
			lethality = 1.35,
			damageHeal = 1,
			national = 5,
			world = 3,
			eraBias = 1.3,
		},
	},
	-- how busy the Gates are over the timeline (a year's local count and how high the ranks
	-- lean): { from = year, mult = x, high = extra weight on B/A/S }
	eras = { { from = 0, mult = 1, high = 0 } },
	-- what a Gate can open in or near: weight in a district comes from district.places
	places = {
		street = { name = "a street", urban = true, pop = 0.9, vis = 1 },
		plaza = { name = "a plaza", urban = true, pop = 1, vis = 1 },
		parking = { name = "a parking lot", urban = true, pop = 0.6, vis = 0.9 },
		station = { name = "a subway station", urban = true, pop = 1, vis = 1 },
		industrial = { name = "an industrial park", urban = true, pop = 0.35, vis = 0.6 },
		residential = { name = "a residential block", urban = true, pop = 0.8, vis = 0.95 },
		park = { name = "a park", urban = true, pop = 0.5, vis = 0.8 },
		construction = { name = "a construction site", urban = true, pop = 0.3, vis = 0.7 },
		riverside = { name = "the riverside", urban = true, pop = 0.45, vis = 0.75 },
		forest = { name = "a forest", urban = false, pop = 0.05, vis = 0.2 },
		mountain = { name = "a mountainside", urban = false, pop = 0.03, vis = 0.15 },
		farmland = { name = "farmland", urban = false, pop = 0.12, vis = 0.45 },
		coast = { name = "a stretch of coast", urban = false, pop = 0.1, vis = 0.4 },
	},
	envs = { "a cave", "a forest", "an old ruin", "a frozen cavern", "a swamp", "a stone maze" },
	monsters = {
		E = { "goblins" }, D = { "lycans" }, C = { "orcs" }, B = { "high orcs" }, A = { "giants" }, S = { "something nobody had a name for" },
	},
	countries = {
		home = { name = "the country", association = "the Hunter Association", capacity = 1 },
	},
	cards = {
		cityGate = "hw_city_", -- a Gate opens in the street where the life is
		raid = "hw_raid_", -- a working Hunter is called to raid one
		breakOut = "hw_break_", -- the monsters are out
		red = "hw_red_", -- the raid went in and the Gate turned red
		double = "hw_double_", -- there was a second dungeon inside
	},
	canon = {},
	-- an S-rank Gate is rare enough to make the news wherever it is
	headlineRank = 3,
}

local function cfgOf(pack: any): any
	local c = pack.hunterWorld
	if c == nil then
		return nil
	end
	if c._merged then
		return c
	end
	-- fill in what the pack leaves out (once)
	for k, v in HW.DEFAULT do
		if c[k] == nil then
			c[k] = v
		end
	end
	for id, m in c.modes do
		local base = HW.DEFAULT.modes[id] or HW.DEFAULT.modes.normal
		for k, v in base do
			if m[k] == nil then
				m[k] = v
			end
		end
	end
	c._merged = true
	return c
end
HW.config = cfgOf

function HW.enabled(sim: any): boolean
	return sim.pack.hunterWorld ~= nil
end

function HW.rankLetter(i: number): string
	return HW.RANKS[math.clamp(math.floor(i), 1, 6)]
end

-- what the clash on a card fights, by Gate rank: base, coins, power per heads. The same
-- numbers the content generator writes into the cards, so a card and the 3D world agree.
HW.FOE = {
	{ base = 4, coins = 2, coinPower = 3 }, -- E
	{ base = 8, coins = 2, coinPower = 4 }, -- D
	{ base = 13, coins = 3, coinPower = 5 }, -- C
	{ base = 19, coins = 3, coinPower = 6 }, -- B
	{ base = 28, coins = 4, coinPower = 8 }, -- A
	{ base = 42, coins = 4, coinPower = 11 }, -- S
}
function HW.foe(rank: number): any
	return HW.FOE[math.clamp(rank, 1, 6)]
end

-- ── the life's world state ─────────────────────────────────────────────────
function HW.state(life: any): any
	local gw = life.gw
	if gw == nil then
		gw = {
			mode = nil,
			serial = 0,
			recent = {},
			news = {},
			history = {},
			byEvent = {},
			damage = {},
			lost = {},
			canonDone = {},
			counts = { witnessed = 0, survived = 0, raids = 0, breaks = 0, red = 0, double = 0, saved = 0, cityGates = 0 },
		}
		life.gw = gw
	end
	return gw
end

function HW.modeOf(sim: any, life: any): (string, any)
	local cfg = cfgOf(sim.pack)
	local gw = HW.state(life)
	local id = gw.mode
	if id == nil then
		-- the world a life is born into: the difficulty picked on the start screen (when it
		-- names a world), or a game mode's own (pack.modes[].world = "crisis")
		local m = life.mode and sim:modeDef(life.mode)
		if m and m.world and cfg.modes[m.world] then
			id = m.world
		elseif life.difficulty and cfg.modes[life.difficulty] then
			id = life.difficulty
		else
			id = cfg.defaultMode
		end
		gw.mode = id
	end
	return id, cfg.modes[id] or cfg.modes[cfg.defaultMode]
end

-- the player's Hunter rank (1..6), or 0 for someone who never awakened. A pack says which
-- forms are which rank: pack.forms[id].hunterRank
function HW.playerRank(sim: any, life: any): number
	local form = sim.pack.forms and sim.pack.forms[life.form or ""]
	return (form and form.hunterRank) or 0
end

local function eraOf(cfg: any, year: number): any
	local pick = cfg.eras[1]
	for _, e in cfg.eras do
		if year >= (e.from or -math.huge) then
			pick = e
		end
	end
	return pick or { mult = 1, high = 0 }
end
HW.eraOf = eraOf

local function countryOf(cfg: any, district: any): any
	return cfg.countries[district.country or "home"] or cfg.countries.home or { name = "the country", association = "the Hunter Association", capacity = 1 }
end
HW.countryOf = countryOf

local function poisson(st: any, mean: number): number
	-- small means only (a year's Gates near one life): Knuth's method
	local l = math.exp(-mean)
	local k, p = 0, 1
	repeat
		k += 1
		p *= Rng.next(st)
	until p <= l or k > 60
	return k - 1
end

local function pickWeighted(st: any, map: any): string?
	local ids, ws = {}, {}
	for id, w in map do
		table.insert(ids, id)
	end
	table.sort(ids)
	for i, id in ids do
		ws[i] = map[id]
	end
	local i = Rng.weighted(st, ws)
	return if i then ids[i] else nil
end

-- ── stage 1: a Gate appears ────────────────────────────────────────────────
-- ctx = { cfg, mode, year, district (def), districtId, country (def), rankBias, cityBias, kind }
function HW.spawn(st: any, ctx: any): any
	local cfg, mode = ctx.cfg, ctx.mode
	local era = eraOf(cfg, ctx.year or 0)
	-- rank: the mode's weights, leaned higher by the era (the story escalates)
	local w = table.clone(mode.rankWeights)
	local high = (era.high or 0) * (mode.eraBias or 1)
	w[4] += high * 0.5
	w[5] += high * 0.3
	w[6] += high * 0.2
	if ctx.minRank then
		for i = 1, ctx.minRank - 1 do
			w[i] = 0
		end
	end
	local rank = ctx.rank or Rng.weighted(st, w) or 1
	-- where: the district's own mix of places, leaned toward the streets by the mode
	local d = ctx.district or {}
	local placeMix = {}
	for id, pw in d.places or { street = 1, forest = 1 } do
		local p = cfg.places[id]
		if p then
			local urban = if p.urban then mode.cityShare * 10 else (1 - mode.cityShare) * 2
			placeMix[id] = pw * urban * (if p.urban then (ctx.cityBias or 1) else 1)
		end
	end
	local placeId = ctx.place or pickWeighted(st, placeMix) or "street"
	local place = cfg.places[placeId] or cfg.places.street
	local names = (d.placeNames and d.placeNames[placeId]) or nil
	local placeName = if names and #names > 0 then Rng.pick(st, names) else place.name
	local monsters = cfg.monsters[HW.rankLetter(rank)] or { "monsters" }
	local inc = {
		n = 0,
		year = ctx.year or 0,
		day = Rng.int(st, 1, 360),
		rank = rank,
		readRank = rank, -- what the Association's reading says
		kind = "gate",
		place = placeId,
		placeName = placeName,
		urban = place.urban == true,
		pop = math.clamp((place.pop or 0.5) * (d.population or 1), 0, 1.5),
		vis = place.vis or 0.5,
		district = ctx.districtId,
		city = d.city or d.name or "the city",
		country = d.country or "home",
		env = Rng.pick(st, cfg.envs) or "a cave",
		monster = Rng.pick(st, monsters) or "monsters",
		stage = "appeared",
		timeline = {},
		casualties = 0,
		hunterLosses = 0,
	}
	-- the rare ones: a Gate that turns red on the raid, a dungeon with a dungeon inside.
	-- A Double Dungeon reads low (the outer dungeon is all the instruments can see).
	if ctx.kind then
		inc.kind = ctx.kind
	elseif Rng.chance(st, mode.double * (ctx.rareMult or 1)) and rank <= 4 then
		inc.kind = "double"
	elseif Rng.chance(st, mode.red * (ctx.rareMult or 1)) and rank <= 5 then
		inc.kind = "red"
	end
	if inc.kind == "double" then
		inc.readRank = math.max(1, rank)
		inc.rank = math.min(6, rank + 3) -- what's really inside
	elseif inc.kind == "red" then
		inc.rank = math.min(6, rank + 1) -- the red side is worse than the reading
	end
	table.insert(inc.timeline, { day = inc.day, stage = "appeared" })
	return inc
end

-- ── stages 2-6: run it to the end ──────────────────────────────────────────
-- ctx adds: capacity (what can answer here, x), breakDays
function HW.lifecycle(st: any, inc: any, ctx: any): any
	local mode = ctx.mode
	-- canon: about seven days is typical, but Tokyo's S-rank Gate broke in about three. Each
	-- Gate gets its own clock (ORIGINAL spread): mode.instability pulls it shorter
	local typical = ctx.breakDays or 7
	local spread = 0.62 + Rng.next(st) * 0.62 - (mode.instability or 0) * 0.22
	local breakDays = math.max(2.5, typical * spread - (inc.rank >= 6 and 1 or 0))
	inc.breakDays = math.floor(breakDays * 10) / 10
	local cap = math.max(0.15, ctx.capacity or 1)
	local r = inc.readRank
	local trueRank = inc.rank
	local function mark(day: number, stage: string, note: string?)
		inc.stage = stage
		table.insert(inc.timeline, { day = math.floor(day * 10) / 10, stage = stage, note = note })
	end

	-- 2. discovery: a crowded street sees it at once; a forest may never, until it breaks
	local unseen = (1 - inc.vis) * (1.4 - math.min(1, inc.pop))
	local findDays = if inc.urban and inc.pop >= 0.5 then 0 else unseen * 4 * (mode.discovery or 1) * (0.3 + Rng.next(st) * 1.1)
	inc.foundDay = findDays
	if findDays >= breakDays then
		-- nobody knew it was there
		inc.unseen = true
		mark(breakDays, "escalated", "unseen")
	else
		mark(findDays, "discovered")
		-- 3. response: measure it, decide who raids it (higher ranks take longer to field)
		local lo, hi = mode.responseDays[1], mode.responseDays[2]
		local delay = (lo + Rng.next(st) * (hi - lo)) * (1 + (r - 1) * 0.18) / cap
		if r >= 6 then
			delay += 1 + Rng.next(st) * 2 -- an S-rank raid needs the top guilds together
		end
		if inc.urban then
			delay *= 0.7 -- a Gate in a street gets people there faster
		end
		inc.responseDay = findDays + delay
		mark(inc.responseDay, "response")
		-- 4. active: a raid
		local raidDay = inc.responseDay + 0.3 + Rng.next(st) * 0.8
		if raidDay >= breakDays then
			inc.late = true
			mark(breakDays, "escalated", "late")
		else
			mark(raidDay, "active")
			inc.raidDay = raidDay
			if inc.kind == "red" then
				-- the raid went in and the Gate turned red: nobody else can go in, and the way
				-- out is shut until its boss dies. It's decided inside.
				local live = math.clamp(0.75 - (trueRank - r) * 0.2 - (trueRank - 1) * 0.06, 0.05, 0.9) * math.sqrt(cap)
				inc.redSurvived = Rng.chance(st, live)
				inc.hunterLosses = if inc.redSurvived then Rng.int(st, 1, 4 + trueRank) else Rng.int(st, 6, 14 + trueRank * 2)
				mark(raidDay + 0.5, "resolved", if inc.redSurvived then "red_survived" else "red_lost")
				inc.outcome = if inc.redSurvived then "red_survivors" else "red_lost"
			elseif inc.kind == "double" then
				local live = math.clamp(0.25 * math.sqrt(cap), 0.03, 0.4)
				inc.doubleSurvived = Rng.chance(st, live)
				inc.hunterLosses = Rng.int(st, 5, 16)
				mark(raidDay + 0.4, "resolved", if inc.doubleSurvived then "double_survived" else "double_lost")
				inc.outcome = if inc.doubleSurvived then "double_survivors" else "double_lost"
			else
				local fail = mode.raidFail[trueRank] / math.sqrt(cap)
				if Rng.chance(st, fail) then
					inc.hunterLosses = Rng.int(st, 1, 3 + trueRank)
					mark(raidDay + 0.2, "active", "raid_failed")
					-- a second team, if there's time and someone to send
					local again = raidDay + 0.8 + Rng.next(st) * 1.6 / cap
					if again < breakDays and Rng.chance(st, mode.secondRaid * math.sqrt(cap)) then
						inc.raidDay = again
						mark(again, "resolved", "cleared_second")
						inc.outcome = "cleared"
					else
						mark(breakDays, "escalated", "raid_failed")
						inc.late = true
					end
				else
					mark(raidDay + 0.2, "resolved", "cleared")
					inc.outcome = "cleared"
				end
			end
		end
	end

	-- 5b. escalation: a Dungeon Break
	if inc.outcome == nil then
		inc.broke = true
		local contain = mode.contain[trueRank] * math.sqrt(cap)
		-- an unseen Gate's break is found by its victims: the response starts late
		if inc.unseen then
			contain *= 0.85
		end
		local severity = trueRank
		local people = inc.pop * (if inc.urban then 1 else 0.3)
		if Rng.chance(st, contain) then
			inc.outcome = "break_contained"
			inc.casualties = math.floor(people * severity * severity * (0.5 + Rng.next(st)) * (if inc.unseen then 2 else 1))
			mark(breakDays + 0.5 + severity * 0.2 / cap, "resolved", "contained")
		else
			inc.casualties = math.floor(people * severity * severity * (3 + Rng.next(st) * 6) + severity * 4)
			if trueRank >= 6 and Rng.chance(st, mode.loseZone) then
				inc.outcome = "zone_lost"
				mark(breakDays + 3, "escalated", "zone_lost")
			else
				inc.outcome = "break_spread"
				mark(breakDays + 1 + severity * 0.6 / cap, "resolved", "spread")
			end
		end
		inc.hunterLosses += Rng.int(st, 0, severity * 2)
	end
	mark((inc.timeline[#inc.timeline] or { day = 0 }).day + 1, "aftermath")
	return inc
end

-- how bad an incident is for the place it happened (feeds damage and the news)
function HW.severity(inc: any): number
	local base = ({ cleared = 0, red_survivors = 1, red_lost = 2, double_survivors = 1, double_lost = 2, break_contained = 2, break_spread = 5, zone_lost = 12 })[inc.outcome or "cleared"] or 0
	return base * inc.rank
end

-- ── words ──────────────────────────────────────────────────────────────────
local function rankWord(i: number): string
	return HW.rankLetter(i) .. "-rank"
end
HW.rankWord = rankWord

local function article(word: string): string
	local first = string.sub(word, 1, 1)
	-- "an E-rank", "an S-rank", "an A-rank" (letters said with a vowel sound)
	if string.find("AEFHILMNORSX", first, 1, true) then
		return "an " .. word
	end
	return "a " .. word
end
HW.article = article

-- fill {tokens} in a line from a table (lines in pack.hunterWorld.lines use the g-tokens)
local function fill(line: string, t: any): string
	return (string.gsub(line, "{(%w+)}", function(k)
		local v = t[k]
		return if v ~= nil then tostring(v) else "{" .. k .. "}"
	end))
end

-- the {g...} tokens a card about this incident can use. `situation` picks the lines (the
-- card's kind: city, raid, break, red, double); st is an RNG (the life), so the same kind of
-- card reads differently every time it comes up.
function HW.tokens(inc: any, cfg: any, situation: string?, st: any?, prank: number?): any
	local country = cfg.countries[inc.country] or cfg.countries.home or {}
	local rw = rankWord(inc.readRank)
	local t = {
		gRank = rw,
		gARank = article(rw),
		gTrueRank = rankWord(inc.rank),
		gPlace = inc.placeName,
		gCity = inc.city,
		gCountry = country.name or "the country",
		gAssoc = country.association or "the Hunter Association",
		gGuild = inc.guild or country.guild or "a guild",
		gMonster = inc.monster,
		gEnv = inc.env,
		gDead = tostring(inc.casualties or 0),
		gScene = "",
		gCrowd = "",
		gTime = "",
		gWarn = "",
	}
	local lines = cfg.lines or {}
	local function pickLine(pool: any): string
		if type(pool) ~= "table" or #pool == 0 then
			return ""
		end
		local line = if st then Rng.pick(st, pool) else pool[1]
		return fill(line, t)
	end
	t.gTime = pickLine(lines.times)
	local sit = situation and lines[situation]
	if sit then
		-- a place can have its own openings (lines.city.station...), or the situation's own
		t.gScene = pickLine((sit.byPlace and sit.byPlace[inc.place]) or sit.scenes)
		t.gCrowd = pickLine(if cfg._crisisLines and sit.crowdCrisis then sit.crowdCrisis else sit.crowd)
	end
	-- the warning the reading gives a Hunter who doesn't fit it
	local w = lines.warnings
	if w and prank ~= nil then
		local gap = inc.readRank - prank
		if prank <= 0 then
			t.gWarn = pickLine(w.civilian)
		elseif gap >= 2 then
			t.gWarn = pickLine(w.deadly)
		elseif gap == 1 then
			t.gWarn = pickLine(w.above)
		elseif gap <= -2 then
			t.gWarn = pickLine(w.below)
		else
			t.gWarn = pickLine(w.even)
		end
	end
	return t
end

function HW.headline(inc: any, cfg: any, scope: string?): (string, string)
	local rw = rankWord(inc.readRank)
	local where = inc.placeName .. ", " .. inc.city
	local country = cfg.countries[inc.country] or {}
	local o = inc.outcome
	if o == "zone_lost" then
		return string.format("CATASTROPHE: an S-rank Dungeon Break overruns %s. The area is being evacuated and sealed.", inc.city), "danger"
	elseif o == "break_spread" then
		return string.format("DUNGEON BREAK at %s: %s monsters spread before Hunters could contain them. %d dead.", where, rw, inc.casualties), "danger"
	elseif o == "break_contained" then
		if inc.unseen then
			return string.format("An unreported %s Gate near %s broke. Hunters contained it; %d dead.", rw, where, inc.casualties), "danger"
		end
		return string.format("Dungeon Break contained at %s (%s). %d dead.", where, rw, inc.casualties), "danger"
	elseif o == "red_lost" then
		return string.format("A %s raid at %s has not come out. The Association says the Gate turned red.", rw, where), "strange"
	elseif o == "red_survivors" then
		return string.format("Survivors walk out of a Red Gate at %s. %d Hunters did not.", where, inc.hunterLosses), "strange"
	elseif o == "double_lost" or o == "double_survivors" then
		return string.format("A low-rank raid at %s ended in a massacre. The Association is investigating what was inside.", where), "strange"
	end
	if inc.readRank >= 6 then
		return string.format("S-RANK GATE at %s. %s fielded its top guilds; the Gate is closed.", where, country.association or "The Association"), "good"
	end
	return string.format("%s Gate at %s cleared by %s.", rw, where, inc.guild or "a raid team"), "plain"
end

-- ── news, history ──────────────────────────────────────────────────────────
function HW.addNews(life: any, tag: string, text: string, tone: string?, extra: any?)
	local gw = HW.state(life)
	table.insert(gw.news, { year = life.year, age = life.age, tag = tag, tone = tone or "plain", text = text, canon = extra and extra.canon or nil })
	while #gw.news > NEWS_LIMIT do
		table.remove(gw.news, 1)
	end
end

function HW.addHistory(life: any, entry: any)
	local gw = HW.state(life)
	entry.year = entry.year or life.year
	entry.age = entry.age or life.age
	table.insert(gw.history, entry)
	while #gw.history > HISTORY_LIMIT do
		table.remove(gw.history, 1)
	end
end

local function remember(gw: any, inc: any)
	table.insert(gw.recent, {
		n = inc.n,
		year = inc.year,
		rank = inc.readRank,
		trueRank = inc.rank,
		kind = inc.kind,
		place = inc.placeName,
		city = inc.city,
		outcome = inc.outcome,
		dead = inc.casualties,
		lost = inc.hunterLosses,
		broke = inc.broke == true,
		unseen = inc.unseen == true,
		stages = #inc.timeline,
		player = inc.player,
	})
	while #gw.recent > RECENT_LIMIT do
		table.remove(gw.recent, 1)
	end
end

-- ── the year ───────────────────────────────────────────────────────────────
-- what can answer a Gate in this life's district (x): the country, the district's own
-- Hunters, the mode, and how stretched everyone already is this year
local function capacityFor(cfg: any, mode: any, district: any, strain: number): number
	local country = countryOf(cfg, district)
	return (country.capacity or 1) * (district.hunters or 1) * (mode.capacity or 1) / (1 + strain * 0.12)
end
HW.capacityFor = capacityFor

-- a card's id: <prefix><rank letter>, and <prefix><letter>_h for a Hunter when the pack has one
local function cardFor(cfg: any, sim: any, prefix: string, rank: number, hunter: boolean?): string?
	local id = prefix .. HW.rankLetter(rank)
	if hunter and sim.eventsById[id .. "_h"] then
		return id .. "_h"
	end
	if sim.eventsById[id] then
		return id
	end
	return nil
end

-- queue a card about an incident: its tokens are kept by event id until the card is up
local function queueCard(sim: any, life: any, eventId: string, inc: any, role: string)
	local gw = HW.state(life)
	local cfg = cfgOf(sim.pack)
	local situation = string.match(eventId, "^hw_(%a+)_") or "city"
	cfg._crisisLines = gw.mode == "crisis"
	local tokens = HW.tokens(inc, cfg, situation, life, HW.playerRank(sim, life))
	cfg._crisisLines = nil
	gw.byEvent[eventId] = { n = inc.n, role = role, tokens = tokens, inc = {
		n = inc.n, rank = inc.rank, readRank = inc.readRank, kind = inc.kind, place = inc.placeName, city = inc.city,
		outcome = inc.outcome, dead = inc.casualties, year = inc.year, district = inc.district, broke = inc.broke == true,
	} }
	life.flags["hw_on_" .. eventId] = true
	table.insert(life.queue, eventId)
end
HW.queueCard = queueCard

-- the canon timeline: what happens this year, to everyone, and to the people who are there
local function canonYear(sim: any, life: any, report: any, cfg: any)
	local gw = HW.state(life)
	local d = sim:districtDef(life)
	for _, c in cfg.canon do
		if not gw.canonDone[c.id] and life.year >= c.year and life.year <= (c.untilYear or c.year) then
			local reaches = true
			if c.onlyIf and not life.flags[c.onlyIf] then
				reaches = false
			end
			if c.notIf and life.flags[c.notIf] then
				reaches = false
			end
			if reaches then
				gw.canonDone[c.id] = true
				-- the news, for everyone the news reaches (public events only)
				if c.public ~= false and c.headline then
					local here = c.country == nil or c.country == d.country
					local text = if here or not c.abroad then c.headline else c.abroad
					HW.addNews(life, "canon", text, c.tone or "plain", { canon = c.id })
					sim:push(life, report, { kind = "world", text = "NEWS: " .. text })
				end
				-- what it does to the world
				local fx = c.effect or {}
				if fx.lose then
					gw.lost[fx.lose] = true
				end
				if fx.restore then
					gw.lost[fx.restore] = nil
				end
				if fx.damage then
					for id, n in fx.damage do
						gw.damage[id] = (gw.damage[id] or 0) + n
					end
				end
				if fx.flag then
					life.flags[fx.flag] = true
				end
				-- the people who are there live it (a card of the pack's own)
				local there = c.firsthand and sim.eventsById[c.firsthand]
				if there then
					local inPlace = (c.district == nil or c.district == life.district or (type(c.district) == "table" and table.find(c.district, life.district) ~= nil))
						and (c.country == nil or c.country == d.country)
					if inPlace and life.alive and life.age >= (c.minAge or cfg.minCardAge or 13) then
						life.flags["hw_on_" .. c.firsthand] = true
						table.insert(life.queue, c.firsthand)
					end
				end
			end
		end
	end
end

-- a life living in a place the Gates took is moved out (an evacuation, not a choice)
local function evacuate(sim: any, life: any, report: any, cfg: any)
	local gw = HW.state(life)
	if not gw.lost[life.district] then
		return
	end
	local here = sim:districtDef(life)
	local options = {}
	for _, id in sim.pack.districts.order do
		local d = sim.pack.districts[id]
		if not gw.lost[id] and d.country == here.country then
			table.insert(options, id)
		end
	end
	if #options == 0 then
		for _, id in sim.pack.districts.order do
			if not gw.lost[id] then
				table.insert(options, id)
			end
		end
	end
	local to = Rng.pick(life, options)
	if to then
		local extra = {}
		sim:moveDistrict(life, to, extra)
		local d = sim.pack.districts[to]
		sim:push(life, report, { kind = "system", tone = "danger", text = string.format("%s is gone. The evacuation buses took you to %s.", here.name or "Home", d.name or to) })
		for _, e in extra do
			sim:push(life, report, e)
		end
		HW.addHistory(life, { kind = "evacuated", from = here.name, to = d.name })
	end
end

-- the cards: a life is pulled in only when it's really there (or really called)
local function involvement(sim: any, life: any, inc: any, mode: any, prank: number): (string?, string?, number)
	local cfg = cfgOf(sim.pack)
	local cards = cfg.cards
	local working = life.career ~= nil and sim.pack.careers[life.career.id] ~= nil and sim.pack.careers[life.career.id].hunter == true
	local sameDistrict = inc.district == life.district
	if not sameDistrict then
		return nil, nil, 0
	end
	-- children are never put in an incident card (Roblox: children are never shown hurt);
	-- they live through the Gates in the gentler cards of the pack's own, and the news
	if life.age < (cfg.minCardAge or 13) then
		return nil, nil, 0
	end
	-- a working Hunter is called for a Gate their rank fits (the Association keeps raids
	-- to Hunters who can survive them: at most one rank above their own)
	if prank > 0 and working and inc.raidDay and inc.readRank <= prank + 1 and inc.readRank >= prank - 2 then
		if Rng.chance(life, mode.raidCall * 0.5) then
			if inc.kind == "red" then
				return cardFor(cfg, sim, cards.red, inc.readRank), "raider", 90
			elseif inc.kind == "double" then
				return cardFor(cfg, sim, cards.double, inc.readRank), "raider", 95
			end
			return cardFor(cfg, sim, cards.raid, inc.readRank), "raider", 40
		end
	end
	-- a minor is in school or at home most of the day: less often caught out
	local minor = if life.age < 18 then 0.4 else 1
	-- the monsters are out where you live
	if inc.broke and inc.urban then
		local p = mode.breakExposure * math.min(1, inc.pop) * minor
		if Rng.chance(life, p) then
			return cardFor(cfg, sim, cards.breakOut, inc.rank, prank > 0), if prank > 0 then "hunter" else "civilian", 80
		end
	end
	-- a Gate opens in the street in front of you
	if inc.urban and not inc.unseen then
		local p = mode.exposure * math.min(1, inc.pop) * minor
		if Rng.chance(life, p) then
			return cardFor(cfg, sim, cards.cityGate, inc.readRank, prank > 0), if prank > 0 then "hunter" else "civilian", 60
		end
	end
	return nil, nil, 0
end

local function guildFor(sim: any, life: any, cfg: any, inc: any, district: any): string
	local country = countryOf(cfg, district)
	local list = country.guilds
	if inc.readRank >= 5 and country.topGuilds and #country.topGuilds > 0 then
		list = country.topGuilds
	end
	if list and #list > 0 then
		return Rng.pick(life, list)
	end
	return country.association or "a raid team"
end

function HW.year(sim: any, life: any, report: any)
	local cfg = cfgOf(sim.pack)
	if not cfg or not life.alive then
		return
	end
	local gw = HW.state(life)
	local modeId, mode = HW.modeOf(sim, life)
	-- old damage heals a little, and canon happens first (it shapes the year)
	for id, n in gw.damage do
		local left = n - (mode.damageHeal or 2)
		gw.damage[id] = if left > 0 then left else nil
	end
	canonYear(sim, life, report, cfg)
	evacuate(sim, life, report, cfg)
	-- before the first Gate, and after the world is rewritten, there are no Gates
	if life.year < cfg.firstYear or life.flags.world_rewritten then
		return
	end
	local district = sim:districtDef(life)
	local era = eraOf(cfg, life.year)
	HW.awakening(sim, life, cfg)
	local prank = HW.playerRank(sim, life)
	local strain = 0
	-- ── the Gates near this life ──
	local mean = mode.localGates * (era.mult or 1) * (district.gates or 1)
	local count = math.min(24, poisson(life, mean))
	local picked = {}
	for _ = 1, count do
		gw.serial += 1
		local inc = HW.spawn(life, { cfg = cfg, mode = mode, year = life.year, district = district, districtId = life.district })
		inc.n = gw.serial
		inc.guild = guildFor(sim, life, cfg, inc, district)
		local cap = capacityFor(cfg, mode, district, strain)
		HW.lifecycle(life, inc, { mode = mode, breakDays = cfg.breakDays, capacity = cap })
		if inc.readRank >= 4 or inc.broke then
			strain += inc.rank -- a bad week leaves fewer Hunters for the next Gate
		end
		-- the place pays for it
		local sev = HW.severity(inc)
		if sev > 0 then
			gw.damage[life.district] = (gw.damage[life.district] or 0) + sev
		end
		if inc.outcome == "zone_lost" then
			gw.lost[life.district] = true
		end
		-- is this life there?
		local eventId, role, priority = involvement(sim, life, inc, mode, prank)
		if eventId then
			table.insert(picked, { inc = inc, id = eventId, role = role, priority = priority })
		end
		-- the local news: anything that broke, anything big, anything strange
		if inc.broke or inc.readRank >= cfg.headlineRank or inc.kind ~= "gate" or (inc.urban and inc.pop >= 0.8) then
			local text, tone = HW.headline(inc, cfg)
			HW.addNews(life, "local", text, tone)
			inc.reported = true
		end
		if inc.broke then
			gw.counts.breaks += 1
		end
		remember(gw, inc)
	end
	-- the cards this year: the most urgent first, at most mode.maxCards, never the same card twice
	table.sort(picked, function(a, b)
		return a.priority > b.priority
	end)
	local used, shown = {}, 0
	for _, p in picked do
		if shown >= (mode.maxCards or 2) then
			break
		end
		if not used[p.id] and not table.find(life.queue, p.id) then
			used[p.id] = true
			shown += 1
			p.inc.player = { role = p.role }
			queueCard(sim, life, p.id, p.inc, p.role)
		end
	end
	-- ── the rest of the country and the world, in headlines ──
	local elsewhere = {}
	for _, id in sim.pack.districts.order do
		local d = sim.pack.districts[id]
		if id ~= life.district and not gw.lost[id] then
			table.insert(elsewhere, { id = id, def = d, home = d.country == district.country })
		end
	end
	local function headlineFrom(list: any, n: number, tag: string)
		for _ = 1, n do
			if #list == 0 then
				return
			end
			local pick = Rng.pick(life, list)
			local inc = HW.spawn(life, { cfg = cfg, mode = mode, year = life.year, district = pick.def, districtId = pick.id, minRank = if Rng.chance(life, 0.6) then 3 else 1 })
			gw.serial += 1
			inc.n = gw.serial
			inc.guild = guildFor(sim, life, cfg, inc, pick.def)
			HW.lifecycle(life, inc, { mode = mode, breakDays = cfg.breakDays, capacity = capacityFor(cfg, mode, pick.def, 0) })
			if inc.outcome == "zone_lost" and pick.def.canLose == false then
				inc.outcome = "break_spread"
			end
			if inc.outcome == "zone_lost" then
				gw.lost[pick.id] = true
			end
			-- big and strange things abroad, everything worth a headline at home
			if tag == "national" or inc.readRank >= 4 or inc.broke or inc.kind ~= "gate" then
				local text, tone = HW.headline(inc, cfg)
				HW.addNews(life, tag, text, tone)
			end
		end
	end
	local home, abroad = {}, {}
	for _, e in elsewhere do
		table.insert(if e.home then home else abroad, e)
	end
	headlineFrom(home, mode.national or 3, "national")
	headlineFrom(abroad, mode.world or 2, "world")
	-- the biggest headline of the year goes in the life's log
	local top = nil
	for i = #gw.news, 1, -1 do
		local n = gw.news[i]
		if n.year ~= life.year then
			break
		end
		if n.tag ~= "canon" and (top == nil or n.tone == "danger") then
			top = n
		end
	end
	if top then
		sim:push(life, report, { kind = "world", text = "NEWS: " .. top.text })
	end
	-- a city still rebuilding is a hard place to live
	local dmg = gw.damage[life.district] or 0
	if dmg >= 12 then
		sim:changeSanity(life, -math.min(4, math.floor(dmg / 12)), nil)
		if dmg >= 24 then
			sim:push(life, report, { kind = "system", tone = "danger", text = (district.name or "The city") .. " is still rebuilding. Half the streets are cordoned off." })
		end
	end
	gw.lastYear = life.year
	gw.modeName = mode.name
	gw.modeId = modeId
end

-- the highest rank a life can measure at, here and now. Canon counts some countries' S-ranks
-- (Korea's 10th was recognised at the story's start, the first since its 9th two years before),
-- so a life there can't be an S-rank the story never mentions: awakening.rankCaps =
-- { { country, untilYear, max } }. Past the year, the count is open again.
function HW.rankCap(sim: any, life: any, cfg: any): number
	local d = sim:districtDef(life)
	local cap = 6
	for _, rule in (cfg.awakening and cfg.awakening.rankCaps) or {} do
		if (rule.country == nil or rule.country == d.country) and life.year <= (rule.untilYear or math.huge) then
			cap = math.min(cap, rule.max or 6)
		end
	end
	return cap
end

local function district(sim: any, life: any): string
	local d = sim:districtDef(life)
	return d.city or d.name or "the city"
end

-- AWAKENING (pack.hunterWorld.awakening): after the Gates came, some people awakened. The
-- rank they measure at is the rank they keep (canon: rank is normally fixed for life); a
-- very few reawaken, once. The odds by age, the rank and class weights are this game's own
-- (canon gives no numbers). Queues `<card><rank letter>` (or `<reawaken><letter>`).
function HW.awakening(sim: any, life: any, cfg: any)
	local aw = cfg.awakening
	if not aw then
		return
	end
	local prank = HW.playerRank(sim, life)
	local gw = HW.state(life)
	local function luckTilt(weights: { number }): { number }
		local out = table.clone(weights)
		local luck = sim:luckOf(life)
		local f = 1 + math.clamp(luck - 10, 0, 60) / 60 -- the lucky lean a little higher
		for i = 3, #out do
			out[i] *= f
		end
		return out
	end
	if prank == 0 then
		if life.flags.aw_done or life.age < (aw.minAge or 13) or life.age > (aw.maxAge or 40) then
			return
		end
		local p = 0
		for _, row in aw.byAge or {} do
			if life.age >= row.from then
				p = row.p
			end
		end
		if life.year - cfg.firstYear <= (aw.firstWaveYears or 1) then
			p *= aw.firstWave or 2
		end
		if not Rng.chance(life, p) then
			return
		end
		local rank = Rng.weighted(life, luckTilt(aw.rankWeights)) or 1
		rank = math.min(rank, HW.rankCap(sim, life, cfg))
		local classes = aw.classes or {}
		local ws = {}
		for i, c in classes do
			ws[i] = c.weight or 1
		end
		local ci = Rng.weighted(life, ws)
		local class = ci and classes[ci]
		local id = (aw.card or "aw_wake_") .. HW.rankLetter(rank)
		if not sim.eventsById[id] then
			return
		end
		life.flags.aw_done = true
		if class then
			life.flags["class_" .. class.id] = true
			gw.class = class.id
			for k, n in class.stats or {} do
				if life.stats[k] then
					life.stats[k] += n
				end
			end
		end
		gw.byEvent[id] = { tokens = { gRank = rankWord(rank), gARank = article(rankWord(rank)), gClass = (class and class.name) or "Fighter", gCity = district(sim, life) } }
		life.flags["hw_on_" .. id] = true
		table.insert(life.queue, id)
		HW.addHistory(life, { kind = "awakened", rank = rank, class = class and class.id })
	elseif prank < 6 and not life.flags.reawakened and life.age <= (aw.reawakenMaxAge or 45) then
		if Rng.chance(life, aw.reawaken or 0.0015) then
			local up = math.min(HW.rankCap(sim, life, cfg), prank + (if Rng.chance(life, 0.25) then 2 else 1))
			if up <= prank then
				return
			end
			local id = (aw.reawakenCard or "aw_reawaken_") .. HW.rankLetter(up)
			if sim.eventsById[id] then
				life.flags.reawakened = true
				gw.byEvent[id] = { tokens = { gRank = rankWord(up), gARank = article(rankWord(up)), gTrueRank = rankWord(prank), gCity = district(sim, life) } }
				life.flags["hw_on_" .. id] = true
				table.insert(life.queue, id)
				HW.addHistory(life, { kind = "reawakened", rank = up, from = prank })
			end
		end
	end
end

-- a card about an incident is on screen: its tokens are this incident's
function HW.onShow(sim: any, life: any, event: any)
	local gw = life.gw
	local slot = gw and gw.byEvent[event.id]
	if slot then
		gw.tokens = slot.tokens
	end
end

-- the player answered a card: the incident (and the record) knows what they did
function HW.afterChoice(sim: any, life: any, event: any, choice: any, report: any)
	local gw = life.gw
	if not gw then
		return
	end
	local slot = gw.byEvent[event.id]
	life.flags["hw_on_" .. event.id] = nil
	if not slot then
		-- a canon card answered: its choice may rewrite the world
		if choice and choice.hwRewrite and life.alive then
			HW.rewrite(sim, life, report)
		end
		return
	end
	gw.byEvent[event.id] = nil
	gw.tokens = nil
	if slot.inc == nil then
		-- an awakening card, not an incident: nothing for the board
		return
	end
	local won = if report and report.clash then report.clash.won else nil
	local role = choice.hw or "watched"
	local inc = slot.inc
	local entry = {
		kind = string.match(event.id, "^hw_(%a+)_") or "incident",
		rank = inc.readRank,
		trueRank = inc.rank,
		gateKind = inc.kind,
		place = inc.place,
		city = inc.city,
		role = role,
		won = won,
		outcome = inc.outcome,
		alive = life.alive,
	}
	HW.addHistory(life, entry)
	local c = gw.counts
	c.witnessed += 1
	if life.alive then
		c.survived += 1
	end
	if entry.kind == "raid" or entry.kind == "red" or entry.kind == "double" then
		if role ~= "declined" then
			c.raids += 1
		end
	end
	if entry.kind == "red" and life.alive and role ~= "declined" then
		c.red += 1
	end
	if entry.kind == "double" and life.alive and role ~= "declined" then
		c.double += 1
	end
	if entry.kind == "city" then
		c.cityGates += 1
	end
	if (role == "helped" or role == "fought" or role == "held") and won then
		c.saved += 1
	end
	-- the incident board shows what you did there
	for _, r in gw.recent do
		if r.n == inc.n then
			r.player = { role = role, won = won }
		end
	end
	-- a deed the news would carry
	if won and (role == "fought" or role == "held" or role == "helped") and inc.rank >= 3 then
		HW.addNews(life, "local", string.format("Witnesses credit %s %s with saving lives at %s.", if HW.playerRank(sim, life) > 0 then "Hunter" else "a civilian,", life.first .. " " .. life.last, inc.place), "good")
		sim:news(life, string.format("%s held the line at a %s incident in %s.", life.first, rankWord(inc.rank), inc.city))
	end
	sim:tally(life, "hw_" .. entry.kind)
end

-- the canon ending: the world is rewritten. A life that lets it happen keeps living, in a
-- world that never had Gates (the Hunter it was is gone, and nobody remembers).
function HW.rewrite(sim: any, life: any, report: any)
	local gw = HW.state(life)
	life.flags.world_rewritten = true
	local extra = {}
	local civ = (sim.pack.hunterWorld and sim.pack.hunterWorld.rewriteForm) or "human"
	if sim.pack.forms[civ] and life.form ~= civ then
		sim:setForm(life, civ, extra)
	end
	if life.career and sim.pack.careers[life.career.id] and sim.pack.careers[life.career.id].hunter then
		sim:quitCareer(life, extra, "The world was rewritten.")
	end
	for _, e in extra do
		sim:push(life, report, e)
	end
	HW.addHistory(life, { kind = "rewritten" })
	gw.byEvent = {}
end

-- ── loot: weapons out of Gates (result.loot) ───────────────────────────────
-- Hunter/Weapons.luau lives beside the Engine in a BitLeveling build (absent in other packs)
local weaponsModule: any = nil
local function weapons(): any
	if weaponsModule == nil then
		local shared = script.Parent.Parent
		local hunter = shared and shared:FindFirstChild("Hunter")
		local m = hunter and hunter:FindFirstChild("Weapons")
		weaponsModule = if m then require(m :: any) else false
	end
	return weaponsModule or nil
end
HW.weapons = weapons

-- spec: { rank = 1..6 (what grade it leans to), chance = 0..1, minStars, shinyBoost }
function HW.loot(sim: any, life: any, spec: any, extra: any)
	local Weapons = weapons()
	if not Weapons or type(spec) ~= "table" or not life.alive then
		return
	end
	if spec.chance and not Rng.chance(life, spec.chance) then
		return
	end
	local rank = math.clamp(math.floor(spec.rank or math.max(1, HW.playerRank(sim, life))), 1, 6)
	local base, stars, shiny = Weapons.roll(rank, function(n)
		return Rng.int(life, 1, n)
	end, function()
		return Rng.next(life)
	end, spec)
	local id = Weapons.gearId(base, stars, shiny)
	if not (sim.pack.gear and sim.pack.gear[id]) then
		return
	end
	local power = Weapons.power(base, stars, shiny)
	local cb, cs, csh = Weapons.parse(life.gear and life.gear.weapon)
	local held = if cb then Weapons.power(cb, cs, csh) else 0
	local label = Weapons.label(base, stars, shiny)
	table.insert(extra, { kind = "system", tone = if shiny or stars == 3 then "strange" else "good", text = "LOOT: " .. label .. "." })
	if power > held then
		sim:giveGear(life, id, extra)
	else
		life.stash = life.stash or {}
		if #life.stash < 30 and not table.find(life.stash, id) then
			table.insert(life.stash, id)
			table.insert(extra, { kind = "system", text = "It's not better than what you carry. It goes in your stash (sell it in the market)." })
		else
			local pay = math.max(1, math.floor(power * 2))
			life.money += pay
			table.insert(extra, { kind = "system", text = string.format("Your stash is full. A broker took it for %d million won.", pay) })
		end
	end
	local gw = HW.state(life)
	gw.counts.loot = (gw.counts.loot or 0) + 1
	if shiny then
		gw.counts.shiny = (gw.counts.shiny or 0) + 1
		table.insert(extra, { kind = "system", tone = "strange", text = "It's SHINY: the mana has soaked right into it." })
		HW.addNews(life, "local", string.format("A Shiny weapon came out of a Gate in %s: %s.", district(sim, life), label), "good")
		sim:news(life, life.first .. " found a Shiny " .. label .. ".")
	end
	HW.addHistory(life, { kind = "loot", base = base, stars = stars, shiny = shiny })
end

-- ── what the client shows: the incident board and the news ────────────────
-- the little that rides along with every view of a life (the HUD strip)
function HW.summary(sim: any, life: any): any
	local cfg = cfgOf(sim.pack)
	local gw = life.gw
	local _, mode = HW.modeOf(sim, life)
	local prank = HW.playerRank(sim, life)
	local latest = {}
	for i = #gw.news, math.max(1, #gw.news - 2), -1 do
		table.insert(latest, gw.news[i])
	end
	return {
		mode = gw.mode,
		modeName = mode.name,
		gateYear = life.year - cfg.firstYear,
		beforeGates = life.year < cfg.firstYear,
		rewritten = life.flags.world_rewritten == true,
		rank = if prank > 0 then HW.rankLetter(prank) else nil,
		damage = gw.damage[life.district] or 0,
		latest = latest,
		counts = gw.counts,
	}
end

function HW.view(sim: any, life: any): any
	if not life.gw or not sim.pack.hunterWorld then
		return nil
	end
	local cfg = cfgOf(sim.pack)
	local gw = life.gw
	local _, mode = HW.modeOf(sim, life)
	local d = sim:districtDef(life)
	local news = {}
	for i = #gw.news, math.max(1, #gw.news - 24), -1 do
		table.insert(news, gw.news[i])
	end
	local recent = {}
	for i = #gw.recent, 1, -1 do
		table.insert(recent, gw.recent[i])
	end
	local hist = {}
	for i = #gw.history, math.max(1, #gw.history - 30), -1 do
		table.insert(hist, gw.history[i])
	end
	local prank = HW.playerRank(sim, life)
	return {
		mode = gw.mode,
		modeName = mode.name,
		year = life.year,
		gateYear = life.year - cfg.firstYear,
		beforeGates = life.year < cfg.firstYear,
		rewritten = life.flags.world_rewritten == true,
		city = d.city or d.name,
		country = (countryOf(cfg, d).name),
		damage = gw.damage[life.district] or 0,
		news = news,
		recent = recent,
		history = hist,
		counts = gw.counts,
		rank = if prank > 0 then HW.rankLetter(prank) else nil,
		lost = gw.lost,
	}
end

return HW
