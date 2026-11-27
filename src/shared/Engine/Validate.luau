--[[
	Content validator. Run it on any pack before shipping:
		local issues = Validate.run(pack)  -- { errors = {...}, warnings = {...} }
	The Lune test runner prints these; the server also runs it on startup and
	warns in the Output window so mistakes show up immediately in Studio.
]]

local Clash = require(script.Parent.Clash)
local Avatar = require(script.Parent.Avatar)

local Validate = {}

local EVENT_KEYS = { id = 1, title = 1, text = 1, weight = 1, once = 1, cooldown = 1, tags = 1, when = 1, result = 1, choices = 1, source = 1, codex = 1, always = 1, dialogue = 1, art = 1, story = 1, lucky = 1, unlucky = 1, draws = 1, thread = 1, cutscene = 1, social = 1, terms = 1, episode = 1, step = 1, theme = 1, rare = 1, scene = 1, focus = 1, dread = 1, partyCard = 1 }
-- (v0.14) an event's cutscene: client/UI/Stage.luau
local SCENE_KEYS = { set = 1, time = 1, title = 1, kicker = 1, line = 1, voice = 1, reply = 1, color = 1, stand = 1, other = 1 }
local SCENE_SETS = { street = 1, alley = 1, facility = 1, rooftop = 1, room = 1, nest = 1, underpass = 1, hall = 1, lake = 1, stairs = 1, gym = 1 }
local CHOICE_KEYS = { label = 1, hint = 1, requires = 1, result = 1, clash = 1, win = 1, lose = 1, battle = 1, fled = 1, hw = 1, hwRewrite = 1 }
-- (BitLeveling) the tokens a Gate incident card fills (Engine/HunterWorld.luau: HW.tokens)
local GATE_TOKENS = { gRank = 1, gARank = 1, gTrueRank = 1, gPlace = 1, gCity = 1, gCountry = 1, gAssoc = 1, gGuild = 1, gMonster = 1, gEnv = 1, gDead = 1, gScene = 1, gCrowd = 1, gTime = 1, gWarn = 1, gClass = 1 }
local ACTIVITY_KEYS = {
	id = 1, name = 1, desc = 1, minAge = 1, maxAge = 1, cost = 1, cooldown = 1, when = 1, result = 1, clash = 1, win = 1, lose = 1,
	category = 1, move = 1, daily = 1, icon = 1, family = 1, schools = 1, shop = 1, market = 1, turfFoe = 1, caseId = 1,
}
local CLASH_KEYS = { stat = 1, foe = 1, coins = 1, base = 1, coinPower = 1, sanity = 1, ignoreSanity = 1, assist = 1, fight = 1, status = 1, fixed = 1, enemy = 1, speed = 1, temper = 1, boss = 1, party = 1 }
local INTERACTION_KEYS = {
	name = 1, desc = 1, kinds = 1, linked = 1, online = 1, minAge = 1, relMinAge = 1, relMaxAge = 1, minBond = 1, maxBond = 1,
	cost = 1, cooldown = 1, actions = 1, result = 1, clash = 1, win = 1, lose = 1, logs = 1, scenes = 1, when = 1,
	party = 1, member = 1, hunter = 1, sort = 1, -- (v0.19) Engine/Party.luau
}
local REL_TOKENS = { rel = 1, relName = 1, relKind = 1 }
local CREW_TOKENS = { crew = 1, crewNames = 1, champion = 1 }
local STAGE_CHOICE_KEYS = {
	label = 1, hint = 1, requires = 1, result = 1, clash = 1, win = 1, lose = 1,
	next = 1, winNext = 1, loseNext = 1, ["end"] = 1, winEnd = 1, loseEnd = 1,
}
local EXPEDITION_KEYS = {
	name = 1, desc = 1, kind = 1, minAge = 1, maxAge = 1, cost = 1, actions = 1, when = 1, crew = 1, cooldown = 1,
	start = 1, stages = 1, success = 1, fail = 1, retreat = 1, length = 1, purpose = 1, depthWord = 1, entrance = 1, open = 1 }
local ENDINGS = { success = 1, fail = 1, retreat = 1 }
local CHECK_KEYS = { when = 1, bornSide = 1, minPeakMoney = 1, minPeakRank = 1, minMoves = 1, heir = 1, causeHas = 1, minChildren = 1, minGeneration = 1, tally = 1 }
local COND_KEYS = {
	minAge = 1, maxAge = 1, minYear = 1, maxYear = 1, side = 1, notSide = 1, district = 1, notDistrict = 1,
	career = 1, anyCareer = 1, linked = 1, linkedRough = 1, hasGear = 1, noGear = 1, hasCondition = 1, noCondition = 1,
	minRank = 1, form = 1, world = 1, flags = 1, notFlags = 1, min = 1, max = 1, hasRelation = 1,
	noRelation = 1, chance = 1, worldEvent = 1, noWorldEvent = 1,
	daily = 1, chronicle = 1, trait = 1, noTrait = 1, style = 1, minMastery = 1, hasBook = 1, noBook = 1, noStyle = 1, hasStyle = 1,
	minRep = 1, maxRep = 1, storyYear = 1, minStoryYear = 1, maxStoryYear = 1,
	renown = 1, office = 1, crisis = 1,
	school = 1, bloodYears = 1, -- (v0.17)
}
local BASE_RESULT_KEYS = {
	log = 1, sanity = 1, money = 1, paycheck = 1,
	setFlags = 1, clearFlags = 1, career = 1, promote = 1, quitCareer = 1, side = 1, district = 1, form = 1,
	wage = 1, linked = 1, gear = 1, loseGear = 1, condition = 1, cure = 1, bond = 1, quest = 1,
	addRelation = 1, relationBond = 1, killRelation = 1, schedule = 1, trigger = 1, die = 1, cause = 1,
	addTrait = 1, removeTrait = 1, style = 1, mastery = 1, codex = 1, chronicle = 1, announce = 1, rolls = 1,
	book = 1, readBook = 1, dialogue = 1, goal = 1, storyEnd = 1, school = 1, rep = 1, cutscene = 1,
	careerRank = 1, overheal = 1, maxHealth = 1, renown = 1, foundOffice = 1, officeSize = 1, impact = 1,
	home = 1, sellHome = 1, becomePartner = 1, endPartner = 1, meet = 1, befriend = 1,
	expedition = 1, episodeEnd = 1, loot = 1,
	turfJoin = 1, turfTake = 1, turfLose = 1, turfGuard = 1, turfLeave = 1,
	caseOpen = 1, caseClue = 1, caseClose = 1, limitBreak = 1, marry = 1, reconcile = 1,
	lifespan = 1, train = 1, -- (v0.17)
	loyalty = 1, partyLoyalty = 1, partyJoin = 1, partyLeave = 1, partyShare = 1, partyRecover = 1, -- (v0.19) Engine/Party.luau
}
-- filled from the pack's own stats (pack.stats.order) at the start of every run
local RESULT_KEYS: { [string]: number } = {}
local CORE_STATS: { [string]: number } = {}
local LIMIT_STATS: { [string]: number } = {}
local RANGE_KEYS: { string } = {}
local BASE_TOKENS = {
	name = 1, first = 1, last = 1, age = 1, year = 1, zone = 1, career = 1, rank = 1, currency = 1, newRelation = 1,
	district = 1, wardNumber = 1, side = 1, corp = 1, linked = 1, sender = 1,
	actor = 1, actorDistrict = 1, style = 1, office = 1,
}

function Validate.run(pack)
	local errors, warnings = {}, {}
	RESULT_KEYS = table.clone(BASE_RESULT_KEYS)
	CORE_STATS = {}
	LIMIT_STATS = { sanity = 1, money = 1 }
	RANGE_KEYS = {}
	for _, key in (pack.stats and pack.stats.order) or { "fortitude", "prudence", "temperance", "justice" } do
		RESULT_KEYS[key] = 1
		CORE_STATS[key] = 1
		LIMIT_STATS[key] = 1
		table.insert(RANGE_KEYS, key)
	end
	for _, key in { "sanity", "money", "bond", "loyalty", "partyLoyalty" } do
		table.insert(RANGE_KEYS, key)
	end
	local function err(where, msg)
		table.insert(errors, where .. ": " .. msg)
	end
	local function warn(where, msg)
		table.insert(warnings, where .. ": " .. msg)
	end

	-- (v0.19) the game's own named people (pack.roster), and who a meeting introduces
	local PARTY_RANKS = { E = 1, D = 2, C = 3, B = 4, A = 5, S = 6 }
	local PARTY_CLASSES = { fighter = 1, mage = 1, assassin = 1, tanker = 1, ranger = 1, healer = 1 }
	local PARTY_TRAITS = { brave = 1, cautious = 1, greedy = 1, loyal = 1, proud = 1, kind = 1, reckless = 1, cold = 1, cheerful = 1, ambitious = 1, honest = 1, scheming = 1 }
	local rosterIds: { [string]: any } = {}
	local rosterList: { any } = if type(pack.roster) == "table" then pack.roster else {}
	for i, d in rosterList do
		if type(d) == "table" and type(d.id) == "string" then
			rosterIds[d.id] = d
		else
			table.insert(errors, "roster[" .. tostring(i) .. "]: needs an id")
		end
	end
	local function checkRank(where, v, allowRange)
		if v == nil then
			return
		end
		if type(v) == "number" then
			if v < 0 or v > 6 or v ~= math.floor(v) then
				err(where, "rank must be 0..6 or a letter E..S")
			end
		elseif type(v) == "string" then
			if not PARTY_RANKS[v] and v ~= "near" then
				err(where, "rank must be a letter E..S (or 'near')")
			end
		elseif type(v) == "table" and allowRange then
			checkRank(where, v[1], false)
			checkRank(where, v[2], false)
		else
			err(where, "rank must be a letter E..S, a number, or a { low, high } range")
		end
	end
	local MEET_KEYS = { role = 1, text = 1, rank = 1, class = 1, hunter = 1, kind = 1, bond = 1, age = 1, chance = 1, traits = 1, work = 1, roster = 1, name = 1, when = 1, choice = 1, won = 1 }
	local function checkMeet(where, m)
		for k in m do
			if not MEET_KEYS[k] then
				err(where, "unknown meet key '" .. tostring(k) .. "'")
			end
		end
		if m.role ~= nil and type(m.role) ~= "string" then
			err(where, "meet.role must be text")
		end
		checkRank(where, m.rank, true)
		if m.class ~= nil and m.class ~= "any" and not PARTY_CLASSES[m.class] then
			err(where, "meet.class '" .. tostring(m.class) .. "' isn't a Hunter class")
		end
		if m.kind ~= nil and not pack.relationKinds[m.kind] then
			err(where, "meet.kind '" .. tostring(m.kind) .. "' isn't a relation kind")
		end
		for _, t in (if type(m.traits) == "table" then m.traits else {}) do
			if not PARTY_TRAITS[t] then
				err(where, "unknown personality trait '" .. tostring(t) .. "'")
			end
		end
		if m.chance ~= nil and (type(m.chance) ~= "number" or m.chance <= 0 or m.chance > 1) then
			err(where, "meet.chance must be a fraction")
		end
		if m.roster ~= nil and rosterIds[m.roster] == nil and #rosterList > 0 then
			err(where, "meet.roster '" .. tostring(m.roster) .. "' isn't in the roster")
		end
	end

	-- books (pack.books): each teaches a trait (or mastery)
	for _, id in (pack.books and pack.books.order) or {} do
		local b = pack.books[id]
		if type(b) ~= "table" or type(b.name) ~= "string" then
			err("book " .. tostring(id), "needs a name")
		elseif b.trait ~= nil and not (pack.traits and pack.traits[b.trait]) then
			err("book " .. id, "teaches unknown trait '" .. tostring(b.trait) .. "'")
		end
	end
	-- talents (pack.talents.tiers): rarity tiers for the trait every life is born with
	if pack.talents then
		local tierIds = {}
		for i, t in pack.talents.tiers or {} do
			if type(t.id) ~= "string" or tierIds[t.id] then
				err("talents.tiers[" .. i .. "]", "missing or duplicate id")
			end
			tierIds[t.id or ""] = true
			if type(t.weight) ~= "number" or t.weight <= 0 then
				err("talent tier " .. tostring(t.id), "weight must be above 0")
			end
		end
		for _, id in (pack.traits and pack.traits.order) or {} do
			local def = pack.traits[id]
			if def and def.talent ~= nil and not tierIds[def.talent] then
				err("trait " .. id, "talent tier '" .. tostring(def.talent) .. "' isn't in pack.talents.tiers")
			end
			if def and def.affinity ~= nil and not (pack.affinities and pack.affinities[def.affinity]) then
				err("trait " .. id, "affinity '" .. tostring(def.affinity) .. "' isn't in pack.affinities")
			end
		end
	end
	-- affinities (pack.affinities): the sins a player can lean toward in the creator
	if pack.affinities then
		for _, id in pack.affinities.order or {} do
			local a = pack.affinities[id]
			if type(a) ~= "table" or type(a.name) ~= "string" or type(a.color) ~= "table" then
				err("affinity " .. tostring(id), "needs a name and a color")
			end
		end
	end
	-- game modes (pack.modes)
	local modeIds = {}
	for i, m in pack.modes or {} do
		local where = "modes[" .. i .. "]"
		if type(m.id) ~= "string" or modeIds[m.id] then
			err(where, "missing or duplicate id")
		end
		modeIds[m.id or ""] = true
		local st = m.start or {}
		if st.career and not pack.careers[st.career] then
			err(where, "unknown career '" .. tostring(st.career) .. "'")
		end
		if st.form and not pack.forms[st.form] then
			err(where, "unknown form '" .. tostring(st.form) .. "'")
		end
		for _, t in st.traits or {} do
			if not (pack.traits and pack.traits[t]) then
				err(where, "unknown trait '" .. tostring(t) .. "'")
			end
		end
	end
	-- mode unlocks: a record, a store pass or Light
	for i, m in pack.modes or {} do
		local u = m.unlock
		if u then
			local where = "modes[" .. i .. "]"
			if u.record then
				local found = false
				for _, r in pack.records or {} do
					if r.id == u.record then
						found = true
					end
				end
				if not found then
					err(where, "unlock record '" .. tostring(u.record) .. "' isn't a record")
				end
			end
			if u.pass and pack.store and pack.store.items then
				local found = false
				for _, item in pack.store.items do
					if item.key == u.pass then
						found = true
					end
				end
				if not found then
					err(where, "unlock pass '" .. tostring(u.pass) .. "' isn't in the store")
				end
			end
		end
	end
	-- the store catalog: Robux items need a kind and a price; Lunacy items a lunacy cost
	local storeKeys = {}
	for i, item in (pack.store and pack.store.items) or {} do
		local where = "store[" .. i .. "]"
		if type(item.key) ~= "string" or storeKeys[item.key] then
			err(where, "missing or duplicate key")
		end
		storeKeys[item.key or ""] = true
		if type(item.name) ~= "string" or type(item.grants) ~= "table" or #item.grants == 0 then
			err(where, "needs a name and grants")
		end
		if item.lunacy ~= nil then
			if type(item.lunacy) ~= "number" or item.lunacy <= 0 then
				err(where, "lunacy must be a positive cost")
			end
			if item.kind == "pass" then
				err(where, "a pass is bought with Robux, not Lunacy")
			end
		elseif type(item.price) ~= "number" or (item.kind ~= "product" and item.kind ~= "pass") then
			err(where, "a Robux item needs kind (product or pass) and a price")
		end
		if item.random and type(item.odds) ~= "string" then
			err(where, "a random item must show its odds")
		end
	end
	-- gear effects
	for _, id in (pack.gear and pack.gear.order) or {} do
		local g = pack.gear[id]
		if type(g) == "table" then
			if g.style ~= nil and not (pack.styles and pack.styles[g.style]) then
				err("gear " .. id, "style must be a fighting style id")
			end
			for sid in g.resist or {} do
				if not (pack.statuses and pack.statuses[sid]) then
					err("gear " .. id, "resists unknown status '" .. tostring(sid) .. "'")
				end
			end
		end
	end

	-- problems the pack found while merging its folders (duplicate ids across files)
	for _, issue in pack.mergeIssues or {} do
		err("merge", issue)
	end

	-- eras of birth a player can pick (optional)
	if pack.calendar and pack.calendar.eras ~= nil then
		local seenEra = {}
		if type(pack.calendar.eras) ~= "table" then
			err("calendar", "eras must be a list")
		else
			for i, e in pack.calendar.eras do
				local where = "calendar.eras[" .. i .. "]"
				if type(e.id) ~= "string" or seenEra[e.id] then
					err(where, "missing or duplicate id")
				end
				seenEra[e.id or ""] = true
				if type(e.name) ~= "string" then
					err(where, "needs a name")
				end
				if type(e.year) ~= "number" then
					err(where, "needs a year (number)")
				end
				if e.jitter ~= nil and (type(e.jitter) ~= "number" or e.jitter < 0) then
					err(where, "jitter must be a number >= 0")
				end
			end
		end
	end

	local eventIds = {}
	for _, e in pack.events or {} do
		if type(e.id) ~= "string" then
			err("event", "missing id (in " .. tostring(e.source) .. ")")
		elseif eventIds[e.id] then
			err(e.id, "duplicate event id")
		else
			eventIds[e.id] = e
		end
		if e.always and not e.once then
			err(tostring(e.id), "always = true needs once = true, or it fires every year")
		end
	end

	local function asList(v)
		if v == nil then
			return {}
		end
		return if type(v) == "table" then v else { v }
	end

	local codexIds = {}
	for _, entry in (pack.codex and pack.codex.entries) or {} do
		if type(entry.id) == "string" then
			if codexIds[entry.id] then
				err("codex " .. entry.id, "duplicate id")
			end
			codexIds[entry.id] = entry
		end
	end

	local allowRelTokens = false -- {rel}, {relName}, {relKind}: only inside interactions
	local allowCrewTokens = false -- {crew}, {crewNames}, {champion}: only inside expeditions
	local function checkTokens(where, text, cond)
		if type(text) == "table" then
			-- variants: the same line written several ways
			for i, one in text do
				if type(one) ~= "string" or one == "" then
					err(where, "variant " .. i .. " must be text")
				else
					checkTokens(where, one, cond)
				end
			end
			return
		end
		if type(text) ~= "string" then
			return
		end
		for token in string.gmatch(text, "{(%w+)}") do
			if (token == "actor" or token == "actorDistrict") and not (cond and cond.chronicle) then
				warn(where, "uses {" .. token .. "} without when.chronicle (it will read \"someone\")")
			end
			if not BASE_TOKENS[token] and not GATE_TOKENS[token] and not (allowRelTokens and REL_TOKENS[token]) and not (allowCrewTokens and CREW_TOKENS[token]) then
				if pack.relationKinds[token] then
					local gated = false
					for _, k in asList(cond and cond.hasRelation) do
						if k == token then
							gated = true
						end
					end
					if not gated then
						warn(where, "uses {" .. token .. "} without when.hasRelation = \"" .. token .. "\"")
					end
				else
					err(where, "unknown token {" .. token .. "}")
				end
			end
		end
	end

	local function checkCond(where, cond)
		if cond == nil then
			return
		end
		if type(cond) ~= "table" then
			err(where, "condition must be a table")
			return
		end
		for k in cond do
			if not COND_KEYS[k] then
				err(where, "unknown condition key '" .. tostring(k) .. "'")
			end
		end
		for _, key in { "side", "notSide" } do
			for _, s in asList(cond[key]) do
				if not pack.sides[s] then
					err(where, "unknown side '" .. tostring(s) .. "'")
				end
			end
		end
		for _, key in { "hasGear", "noGear" } do
			for _, g in asList(cond[key]) do
				if not (pack.gear and pack.gear[g]) then
					err(where, "unknown gear '" .. tostring(g) .. "'")
				end
			end
		end
		for _, key in { "hasCondition", "noCondition" } do
			for _, c in asList(cond[key]) do
				if not (pack.conditions and pack.conditions[c]) then
					err(where, "unknown condition '" .. tostring(c) .. "'")
				end
			end
		end
		for _, key in { "district", "notDistrict" } do
			for _, d in asList(cond[key]) do
				if not pack.districts[d] then
					err(where, "unknown district '" .. tostring(d) .. "'")
				end
			end
		end
		for _, c in asList(cond.career) do
			if c ~= "none" and not pack.careers[c] then
				err(where, "unknown career '" .. tostring(c) .. "'")
			end
		end
		for _, f in asList(cond.form) do
			if not pack.forms[f] then
				err(where, "unknown form '" .. tostring(f) .. "'")
			end
		end
		for _, k in asList(cond.hasRelation) do
			if not pack.relationKinds[k] then
				err(where, "unknown relation kind '" .. tostring(k) .. "'")
			end
		end
		for _, k in asList(cond.noRelation) do
			if not pack.relationKinds[k] then
				err(where, "unknown relation kind '" .. tostring(k) .. "'")
			end
		end
		for _, tbl in { cond.min, cond.max } do
			if tbl then
				for k in tbl do
					if not LIMIT_STATS[k] then
						err(where, "unknown stat '" .. tostring(k) .. "' in min/max")
					end
				end
			end
		end
		if cond.world then
			for key, want in cond.world do
				local var = nil
				for _, w in pack.world do
					if w.key == key then
						var = w
					end
				end
				if not var then
					err(where, "unknown world key '" .. tostring(key) .. "'")
				elseif var.values then
					for _, val in asList(want) do
						if not table.find(var.values, val) then
							err(where, "world." .. key .. " has no value '" .. tostring(val) .. "'")
						end
					end
				end
			end
		end
		for _, key in { "trait", "noTrait" } do
			for _, t in asList(cond[key]) do
				if not (pack.traits and pack.traits[t]) then
					err(where, "unknown trait '" .. tostring(t) .. "'")
				end
			end
		end
		for _, st in asList(cond.style) do
			if not (pack.styles and pack.styles[st]) then
				err(where, "unknown style '" .. tostring(st) .. "'")
			end
		end
		for _, d in asList(cond.daily) do
			if not (pack.daily and pack.daily[d]) then
				err(where, "unknown daily event '" .. tostring(d) .. "'")
			end
		end
		for _, act in asList(cond.chronicle) do
			if not (pack.chronicle and pack.chronicle[act]) then
				err(where, "unknown chronicle act '" .. tostring(act) .. "' (add it to pack.chronicle)")
			end
		end
		if cond.flags ~= nil and type(cond.flags) ~= "table" then
			err(where, "flags must be a list")
		end
		if cond.notFlags ~= nil and type(cond.notFlags) ~= "table" then
			err(where, "notFlags must be a list")
		end
	end

	local function checkRange(where, key, v)
		if v == nil then
			return
		end
		if type(v) == "number" then
			return
		end
		if type(v) == "table" and type(v[1]) == "number" and type(v[2]) == "number" then
			return
		end
		err(where, key .. " must be a number or {min, max}")
	end

	-- v0.8 talking scenes: { { who = "cast id" | "foe id" | "you" | "{mother}" | "A plain name", line = "..." } }
	local function checkDialogue(where, list, cond)
		if type(list) ~= "table" or #list == 0 then
			err(where, "dialogue must be a non-empty list of { who, line }")
			return
		end
		if #list > 8 then
			warn(where, "dialogue has " .. #list .. " lines; keep it to 5 or fewer")
		end
		for i, d in list do
			local w = where .. "[" .. i .. "]"
			if type(d) == "table" and type(d.line) == "table" then
				checkTokens(w, d.line, cond)
			elseif type(d) ~= "table" or type(d.who) ~= "string" or type(d.line) ~= "string" or d.line == "" then
				err(w, "needs who and line (strings)")
			else
				for k in d do
					if k ~= "who" and k ~= "line" then
						err(w, "unknown dialogue key '" .. tostring(k) .. "'")
					end
				end
				if type(d.line) == "string" and #d.line > 160 then
					warn(w, "line is " .. #d.line .. " characters; keep it under 120")
				end
				local token = string.match(d.who, "^{(.-)}$")
				if token then
					if not (pack.relationKinds and pack.relationKinds[token]) then
						err(w, "who '" .. d.who .. "' isn't a relation token")
					end
				elseif string.match(d.who, "^[%l%d_]+$") and d.who ~= "you" then
					if not ((pack.cast and pack.cast[d.who]) or (pack.foes and pack.foes[d.who])) then
						err(w, "who '" .. d.who .. "' isn't a cast or foe id (plain names start with a capital)")
					end
				end
				checkTokens(w, d.line, cond)
			end
		end
	end

	local function checkResult(where, r, cond)
		if r == nil then
			return
		end
		if type(r) ~= "table" then
			err(where, "result must be a table")
			return
		end
		for k in r do
			if not RESULT_KEYS[k] then
				err(where, "unknown result key '" .. tostring(k) .. "'")
			end
		end
		if r.log == nil then
			warn(where, "result has no log line")
		end
		checkTokens(where, r.log, cond)
		if r.dialogue ~= nil then
			checkDialogue(where .. ".dialogue", r.dialogue, cond)
		end
		for _, key in RANGE_KEYS do
			checkRange(where, key, r[key])
		end
		if r.bond ~= nil and not allowRelTokens then
			warn(where, "bond only does something in interactions (with one person)")
		end
		-- (v0.19) the party: loyalty and leaving are about one person (a party card, a scene)
		if (r.loyalty ~= nil or r.partyLeave or r.partyJoin or r.partyShare ~= nil) and not allowRelTokens then
			warn(where, "loyalty, partyJoin, partyLeave and partyShare only do something with one person (an interaction, a scene, a party card)")
		end
		if r.partyShare ~= nil and (type(r.partyShare) ~= "number" or r.partyShare < -0.4 or r.partyShare > 0.4) then
			err(where, "partyShare must be a number between -0.4 and 0.4")
		end
		if r.partyRecover ~= nil and (type(r.partyRecover) ~= "number" or r.partyRecover < 0 or r.partyRecover > 1) then
			err(where, "partyRecover must be a fraction between 0 and 1")
		end
		if type(r.meet) == "table" then
			checkMeet(where .. ".meet", r.meet)
		elseif r.meet ~= nil and r.meet ~= true and type(r.meet) ~= "string" then
			err(where, "meet must be true, a role, or { role, rank, class, ... }")
		end
		if r.quest and not (pack.quests and pack.quests[r.quest]) then
			err(where, "unknown quest '" .. tostring(r.quest) .. "'")
		end
		if r.career and not pack.careers[r.career] then
			err(where, "unknown career '" .. tostring(r.career) .. "'")
		end
		if r.school and not (pack.schools and pack.schools[r.school]) then
			err(where, "unknown school '" .. tostring(r.school) .. "' (pack.schools)")
		end
		if r.side and not pack.sides[r.side] then
			err(where, "unknown side '" .. tostring(r.side) .. "'")
		end
		if r.district and r.district ~= "random" and not pack.districts[r.district] then
			err(where, "unknown district '" .. tostring(r.district) .. "'")
		end
		checkRange(where, "wage", r.wage)
		for _, b in asList(r.book) do
			if not (pack.books and pack.books[b]) then
				err(where, "unknown book '" .. tostring(b) .. "'")
			end
		end
		if r.readBook and not (pack.books and pack.books[r.readBook]) then
			err(where, "unknown book '" .. tostring(r.readBook) .. "'")
		end
		if r.gear and not (pack.gear and pack.gear[r.gear]) then
			err(where, "unknown gear '" .. tostring(r.gear) .. "'")
		end
		-- (v0.13) delves started from the world, cases, turf and limits
		if r.expedition ~= nil and not (type(r.expedition) == "string" and pack.expeditions and pack.expeditions[r.expedition]) then
			err(where, "unknown expedition '" .. tostring(r.expedition) .. "'")
		end
		for _, k in { "caseOpen", "caseClue", "caseClose" } do
			if r[k] ~= nil and not (type(r[k]) == "string" and pack.cases and pack.cases[r[k]]) then
				err(where, "unknown case '" .. tostring(r[k]) .. "' in " .. k)
			end
		end
		if r.turfJoin ~= nil and not (type(r.turfJoin) == "string" and pack.turf and (r.turfJoin == "crew" or pack.turf.factions[r.turfJoin])) then
			err(where, "turfJoin must be \"crew\" or a pack.turf faction")
		end
		for _, k in { "turfTake", "turfLose" } do
			if r[k] ~= nil and (type(r[k]) ~= "number" or r[k] < 1) then
				err(where, k .. " must be a number of blocks (1+)")
			end
		end
		if r.limitBreak ~= nil then
			if type(r.limitBreak) ~= "table" then
				err(where, "limitBreak must be { stat = n } (or all = n)")
			else
				for k, v in r.limitBreak do
					if (k ~= "all" and not CORE_STATS[k]) or type(v) ~= "number" then
						err(where, "limitBreak: unknown stat '" .. tostring(k) .. "'")
					end
				end
			end
		end
		if r.condition and not (pack.conditions and pack.conditions[r.condition]) then
			err(where, "unknown condition '" .. tostring(r.condition) .. "'")
		end
		if type(r.cure) == "string" and r.cure ~= "any" and not (pack.conditions and pack.conditions[r.cure]) then
			err(where, "unknown condition '" .. tostring(r.cure) .. "' in cure")
		end
		if r.linked then
			-- (a scene with someone carries them: its `linked` effects land when they are a
			-- linked friend, and are skipped for anyone else)
			if not (cond and (cond.linked or cond.linkedRough)) and not allowRelTokens then
				warn(where, "has `linked` effects but the event's when has no linked = true")
			end
			if r.linked.linked or r.linked.die or r.linked.schedule or r.linked.trigger then
				err(where .. ".linked", "linked effects can't use linked/die/schedule/trigger")
			end
			checkResult(where .. ".linked", r.linked, nil)
		end
		if r.form and not pack.forms[r.form] then
			err(where, "unknown form '" .. tostring(r.form) .. "'")
		end
		if r.addRelation then
			if type(r.addRelation) ~= "table" or not pack.relationKinds[r.addRelation.kind] then
				err(where, "addRelation needs a valid kind")
			elseif r.addRelation.roster ~= nil then
				-- (v0.19) one of the game's own named people (pack.roster)
				local rid = r.addRelation.roster
				if type(rid) ~= "string" then
					err(where, "addRelation.roster must be a roster id (npc_<slug>)")
				elseif rosterIds[rid] == nil and #rosterList > 0 then
					err(where, "addRelation.roster '" .. rid .. "' isn't in the roster")
				elseif rosterIds[rid] == nil then
					warn(where, "addRelation.roster '" .. rid .. "' names an NPC, and this game has no roster yet (Roster.luau)")
				end
			end
			for k in (if type(r.addRelation) == "table" then r.addRelation else {}) do
				if k ~= "kind" and k ~= "name" and k ~= "bond" and k ~= "age" and k ~= "roster" then
					err(where, "unknown addRelation key '" .. tostring(k) .. "'")
				end
			end
		end
		if r.relationBond then
			local k = r.relationBond.kind
			if k ~= "family" and k ~= "all" and not pack.relationKinds[k] then
				err(where, "relationBond has unknown kind '" .. tostring(k) .. "'")
			end
		end
		local killKind = if type(r.killRelation) == "table" then r.killRelation.kind else r.killRelation
		if r.killRelation and not pack.relationKinds[killKind] then
			err(where, "killRelation has unknown kind '" .. tostring(killKind) .. "'")
		end
		if type(r.killRelation) == "table" and r.killRelation.fate and not (pack.relationFates and pack.relationFates[r.killRelation.fate]) then
			err(where, "killRelation has unknown fate '" .. tostring(r.killRelation.fate) .. "'")
		end
		if r.schedule then
			local list = if r.schedule.event then { r.schedule } else r.schedule
			for _, s in list do
				if not eventIds[s.event] then
					err(where, "schedule points to missing event '" .. tostring(s.event) .. "'")
				end
			end
		end
		if r.trigger and not eventIds[r.trigger] then
			err(where, "trigger points to missing event '" .. tostring(r.trigger) .. "'")
		end
		if r.setFlags ~= nil and type(r.setFlags) ~= "table" then
			err(where, "setFlags must be a list")
		end
		for _, key in { "addTrait", "removeTrait" } do
			for _, t in asList(r[key]) do
				if not (pack.traits and pack.traits[t]) then
					err(where, "unknown trait '" .. tostring(t) .. "' in " .. key)
				end
			end
		end
		if r.style and not (pack.styles and pack.styles[r.style]) then
			err(where, "unknown style '" .. tostring(r.style) .. "'")
		end
		checkRange(where, "mastery", r.mastery)
		for _, c in asList(r.codex) do
			if not codexIds[c] then
				err(where, "unknown codex entry '" .. tostring(c) .. "'")
			end
		end
		for _, act in asList(r.chronicle) do
			if not (pack.chronicle and pack.chronicle[act]) then
				err(where, "unknown chronicle act '" .. tostring(act) .. "' (add it to pack.chronicle)")
			end
		end
		if r.announce ~= nil then
			if type(r.announce) ~= "string" then
				err(where, "announce must be text")
			else
				checkTokens(where .. ".announce", r.announce, cond)
			end
		end
		if r.rolls ~= nil and (type(r.rolls) ~= "number" or r.rolls < 0) then
			err(where, "rolls must be a positive number")
		end
	end

	local function checkOption(where, o, cond, keys)
		for k in o do
			if not keys[k] then
				err(where, "unknown key '" .. tostring(k) .. "'")
			end
		end
		local hasResult = o.result ~= nil
		local hasClash = o.clash ~= nil
		if hasResult == hasClash then
			err(where, "needs exactly one of `result` or `clash` (+ win/lose)")
		end
		-- (v0.16) a big boss fought in turns: the boss must exist, and the clash stays as the
		-- one-tap fallback (a pack without bosses), with the same win and lose
		if o.battle ~= nil then
			if not (pack.bosses and pack.bosses[o.battle]) then
				err(where, "battle '" .. tostring(o.battle) .. "' isn't a boss (Bosses.luau)")
			end
			if not hasClash then
				err(where, "a battle choice keeps a clash too (its win and lose are the battle's)")
			end
			if o.fled ~= nil then
				checkResult(where .. ".fled", o.fled, cond)
			end
		end
		if hasClash then
			for k in o.clash do
				if not CLASH_KEYS[k] then
					err(where, "unknown clash key '" .. tostring(k) .. "'")
				end
			end
			if not CORE_STATS[o.clash.stat] then
				err(where, "clash.stat must be fortitude/prudence/temperance/justice")
			end
			if o.clash.enemy ~= nil then
				if not (pack.foes and pack.foes[o.clash.enemy]) then
					err(where, "clash.enemy '" .. tostring(o.clash.enemy) .. "' isn't a foe (Foes.luau)")
				elseif not o.clash.fight then
					warn(where, "clash.enemy only shows in a fight (fight = true)")
				end
			end
			if o.clash.status ~= nil then
				if not o.clash.fight then
					warn(where, "clash.status only works in a fight (fight = true)")
				end
				if not Clash.statusOf(o.clash.status) then
					err(where, "clash.status must be one of " .. table.concat(Clash.STATUS_IDS, ", "))
				end
			end
			if o.win == nil or o.lose == nil then
				err(where, "a clash needs both win and lose")
			end
			-- (v0.19) a clash your party fights in: the Gate's rank and what kind of place
			if o.clash.party ~= nil then
				local cp = o.clash.party
				local KINDS = { city = 1, ["break"] = 1, raid = 1, red = 1, double = 1, boss = 1, spar = 1 }
				if type(cp) ~= "table" then
					err(where, "clash.party must be { rank, kind }")
				else
					if type(cp.rank) ~= "number" or cp.rank < 1 or cp.rank > 6 then
						err(where, "clash.party.rank must be 1..6")
					end
					if cp.kind ~= nil and not KINDS[cp.kind] then
						err(where, "clash.party.kind must be city, break, raid, red, double, boss or spar")
					end
				end
			end
			checkResult(where .. ".win", o.win, cond)
			checkResult(where .. ".lose", o.lose, cond)
		else
			checkResult(where .. ".result", o.result, cond)
		end
	end

	-- storylines (pack.storylines): one main story per life
	local storyIds, storyBeats, storyAnchors = {}, {}, {}
	local TONES = { grim = 1, tragic = 1, strange = 1, hopeful = 1 }
	for i, sl in pack.storylines or {} do
		local where = "storyline " .. tostring(sl.id or i)
		if type(sl.id) ~= "string" or storyIds[sl.id] then
			err(where, "missing or duplicate id")
		else
			storyIds[sl.id] = true
		end
		if type(sl.name) ~= "string" or type(sl.hook) ~= "string" then
			err(where, "needs name and hook")
		elseif #sl.hook > 170 then
			warn(where, "hook is " .. #sl.hook .. " characters; keep it under 150")
		end
		if sl.tone ~= nil and not TONES[sl.tone] then
			err(where, "tone must be grim, tragic, strange or hopeful")
		end
		for k in sl do
			if k ~= "id" and k ~= "name" and k ~= "hook" and k ~= "tone" and k ~= "weight" and k ~= "when" and k ~= "goal" and k ~= "cantos" and k ~= "source" and k ~= "act" and k ~= "cast" then
				err(where, "unknown storyline key '" .. tostring(k) .. "'")
			end
		end
		-- who is in it (shown with faces in the Story tab): cast ids, or { who = id | "{relation}", line = "..." }
		if sl.cast ~= nil then
			if type(sl.cast) ~= "table" then
				err(where, "cast must be a list")
			else
				if #sl.cast > 4 then
					warn(where, "cast has " .. #sl.cast .. " people; the Story tab shows five at most, with those who speak")
				end
				for ci, c in sl.cast do
					local who = if type(c) == "table" then c.who else c
					local cw = where .. ".cast[" .. ci .. "]"
					if type(who) ~= "string" then
						err(cw, "needs a cast id, or { who, line }")
					else
						local token = string.match(who, "^{(.-)}$")
						if token then
							if not (pack.relationKinds and pack.relationKinds[token]) then
								err(cw, "'" .. who .. "' isn't a relation token")
							end
						elseif not (pack.cast and pack.cast[who]) then
							err(cw, "'" .. who .. "' isn't in pack.cast")
						end
						if type(c) == "table" then
							if c.line ~= nil and (type(c.line) ~= "string" or #c.line > 70) then
								err(cw, "line must be text of 70 characters or fewer")
							end
							for k in c do
								if k ~= "who" and k ~= "line" then
									err(cw, "unknown key '" .. tostring(k) .. "'")
								end
							end
						elseif not token and type(pack.cast[who].title) ~= "string" then
							warn(cw, "'" .. who .. "' has no title to show under the name")
						end
					end
				end
			end
		end
		if sl.when ~= nil then
			checkCond(where .. ".when", sl.when)
		end
		for idx, line in sl.cantos or {} do
			if type(idx) ~= "number" or type(line) ~= "string" then
				err(where, "cantos must be [canto number] = \"one line\"")
			end
		end
	end
	for _, g in pack.glossary or {} do
		if type(g.term) ~= "string" or type(g.text) ~= "string" then
			err("glossary", "every entry needs term and text")
		elseif #g.text > 150 then
			warn("glossary " .. g.term, "text is " .. #g.text .. " characters; keep it under 130")
		end
		for k in g do
			if k ~= "term" and k ~= "text" and k ~= "match" and k ~= "mid" then
				err("glossary " .. tostring(g.term), "unknown key '" .. tostring(k) .. "'")
			end
		end
		for _, key in { "match", "mid" } do
			if g[key] ~= nil and type(g[key]) ~= "table" then
				err("glossary " .. tostring(g.term), key .. " must be a list of words")
			end
			for _, word in if type(g[key]) == "table" then g[key] else {} do
				if type(word) ~= "string" or #word < 3 then
					err("glossary " .. tostring(g.term), key .. " holds something that isn't a word of three letters or more")
				elseif key == "mid" and not string.find(word, "^%u") then
					-- a `mid` word is told from the ordinary one by its capital
					err("glossary " .. tostring(g.term), "mid word '" .. word .. "' must start with a capital")
				end
			end
		end
	end

	-- events
	local targeted = {}
	for _, e in pack.events or {} do
		local where = tostring(e.id)
		-- a scene with someone (e.social) can use their name, and so can a party card
		allowRelTokens = e.social ~= nil or e.partyCard ~= nil
		if e.partyCard ~= nil and e.partyCard ~= true then
			err(where, "partyCard must be true")
		end
		for k in e do
			if not EVENT_KEYS[k] then
				err(where, "unknown event key '" .. tostring(k) .. "'")
			end
		end
		if type(e.title) ~= "string" then
			err(where, "missing title")
		end
		-- (v0.14) a cutscene before the card
		if e.scene ~= nil then
			if type(e.scene) ~= "table" then
				err(where, "scene must be a table")
			else
				for k in e.scene do
					if not SCENE_KEYS[k] then
						err(where, "unknown scene key '" .. tostring(k) .. "'")
					end
				end
				if e.scene.set ~= nil and not SCENE_SETS[e.scene.set] then
					err(where, "scene.set '" .. tostring(e.scene.set) .. "' isn't a set (street, alley, facility, rooftop, room, nest, underpass, hall, lake, stairs)")
				end
				local o = e.scene.other
				if o ~= nil and (type(o) ~= "table" or (type(o.name) ~= "string" and type(o.rel) ~= "string")) then
					err(where, "scene.other needs a name (or rel = a relation kind)")
				elseif o and o.rel and not pack.relationKinds[o.rel] then
					err(where, "scene.other.rel '" .. tostring(o.rel) .. "' isn't a relation kind")
				elseif o and o.foe and not (pack.foes and pack.foes[o.foe]) then
					err(where, "scene.other.foe '" .. tostring(o.foe) .. "' isn't a foe")
				end
			end
		end
		-- (v0.13) a card of an episode names one the pack has (pack.episodes)
		if e.episode ~= nil and not (type(e.episode) == "string" and pack.episodes and pack.episodes[e.episode]) then
			err(where, "episode '" .. tostring(e.episode) .. "' isn't in pack.episodes")
		end
		-- terms: glossary chips this card shows whatever its words say
		if e.terms ~= nil then
			if type(e.terms) ~= "table" then
				err(where, "terms must be a list of glossary terms")
			else
				for _, term in e.terms do
					local known = false
					for _, g in pack.glossary or {} do
						if g.term == term then
							known = true
							break
						end
					end
					if not known then
						err(where, "terms names '" .. tostring(term) .. "', which the glossary doesn't have")
					end
				end
			end
		end
		for _, c in asList(e.codex) do
			if not codexIds[c] then
				err(where, "unknown codex entry '" .. tostring(c) .. "'")
			end
		end
		if type(e.text) ~= "string" and type(e.text) ~= "table" then
			err(where, "missing text")
		end
		if e.art ~= nil and not (pack.scenes and table.find(pack.scenes, e.art)) then
			err(where, "art '" .. tostring(e.art) .. "' isn't a scene (pack.scenes)")
		end
		if e.dialogue ~= nil then
			checkDialogue(where .. ".dialogue", e.dialogue, e.when)
		end
		if e.story ~= nil then
			if not storyIds[e.story] then
				err(where, "story '" .. tostring(e.story) .. "' isn't a storyline (Storylines/)")
			else
				storyBeats[e.story] = (storyBeats[e.story] or 0) + 1
				if e.always then
					storyAnchors[e.story] = (storyAnchors[e.story] or 0) + 1
				end
			end
		end
		checkTokens(where .. ".title", e.title, e.when)
		checkTokens(where .. ".text", e.text, e.when)
		checkCond(where .. ".when", e.when)
		if (e.result ~= nil) == (e.choices ~= nil) then
			err(where, "needs exactly one of `result` or `choices`")
		end
		checkResult(where .. ".result", e.result, e.when)
		if e.choices then
			-- a beat of a main story may offer five ways out; everything else, up to four
			local most = if e.story then 5 else 4
			if #e.choices < 1 or #e.choices > most then
				err(where, "should have 1-" .. most .. " choices")
			end
			for i, c in e.choices do
				local cw = where .. ".choices[" .. i .. "]"
				if type(c.label) ~= "string" then
					err(cw, "missing label")
				end
				checkTokens(cw .. ".label", c.label, e.when)
				checkCond(cw .. ".requires", c.requires)
				checkOption(cw, c, e.when, CHOICE_KEYS)
			end
		end
		-- collect schedule/trigger targets
		local function collect(r)
			if not r then
				return
			end
			if r.trigger then
				targeted[r.trigger] = true
			end
			if r.schedule then
				local list = if r.schedule.event then { r.schedule } else r.schedule
				for _, s in list do
					targeted[s.event] = true
				end
			end
		end
		collect(e.result)
		for _, c in e.choices or {} do
			collect(c.result)
			collect(c.win)
			collect(c.lose)
		end
	end
	for id in targeted do
		local e = eventIds[id]
		if e and (e.weight == nil or e.weight > 0) then
			warn(id, "is a follow-up (scheduled/triggered) but can also roll randomly; set weight = 0 if that's unintended")
		end
	end
	allowRelTokens = false

	-- activities
	local actIds = {}
	for _, a in pack.activities or {} do
		local where = "activity " .. tostring(a.id)
		if actIds[a.id] then
			err(where, "duplicate id")
		end
		actIds[a.id] = true
		checkCond(where .. ".when", a.when)
		if a.shop or a.market then
			for k in a do
				if not ACTIVITY_KEYS[k] then
					err(where, "unknown key '" .. tostring(k) .. "'")
				end
			end
			if a.market and not (pack.markets and pack.markets[a.market]) then
				err(where, "unknown market '" .. tostring(a.market) .. "'")
			end
		else
			checkOption(where, a, a.when, ACTIVITY_KEYS)
		end
	end

	-- (v0.12) markets and homes (Engine/Market.luau)
	if pack.homes then
		for _, id in pack.homes.order or {} do
			local h = pack.homes[id]
			local where = "home " .. tostring(id)
			if type(h) ~= "table" then
				err(where, "is in order but not defined")
			else
				if type(h.name) ~= "string" or type(h.price) ~= "number" then
					err(where, "needs a name and a price")
				end
				for _, k in { "safety", "hideout" } do
					if h[k] ~= nil and (type(h[k]) ~= "number" or h[k] < 0 or h[k] > 0.6) then
						err(where, k .. " must be a number from 0 to 0.6")
					end
				end
			end
		end
	end
	if pack.markets then
		local goodIds = {}
		for _, id in pack.markets.order or {} do
			local m = pack.markets[id]
			local where = "market " .. tostring(id)
			if type(m) ~= "table" then
				err(where, "is in order but not defined")
			else
				if type(m.name) ~= "string" then
					err(where, "needs a name")
				end
				checkCond(where .. ".when", m.when)
				for i, mk in m.markup or {} do
					checkCond(where .. ".markup[" .. i .. "]", mk.when)
					if type(mk.mult) ~= "number" or mk.mult <= 0 then
						err(where .. ".markup[" .. i .. "]", "needs a positive mult")
					end
				end
				for _, g in m.goods or {} do
					local gw = where .. " good " .. tostring(g.id)
					if type(g.id) ~= "string" or type(g.name) ~= "string" or type(g.price) ~= "number" then
						err(gw, "needs an id, a name and a price")
					end
					if goodIds[g.id] then
						err(gw, "duplicate good id (ids are shared by every market)")
					end
					goodIds[g.id] = true
					checkCond(gw .. ".when", g.when)
					checkCond(gw .. ".requires", g.requires)
					if g.chance ~= nil and (type(g.chance) ~= "number" or g.chance <= 0 or g.chance > 1) then
						err(gw, "chance must be in (0, 1]")
					end
					if type(g.result) ~= "table" then
						err(gw, "needs a result")
					else
						checkResult(gw .. ".result", g.result, g.when)
						if g.result.home and not (pack.homes and pack.homes[g.result.home]) then
							err(gw, "unknown home '" .. tostring(g.result.home) .. "'")
						end
					end
				end
			end
		end
	end

	-- interactions (People tab)
	if pack.interactions then
		allowRelTokens = true
		for _, id in pack.interactions.order or {} do
			local def = pack.interactions[id]
			local where = "interaction " .. id
			if type(def) ~= "table" then
				err(where, "is in order but not defined")
			else
				if type(def.name) ~= "string" then
					err(where, "needs a name")
				end
				checkTokens(where .. ".name", def.name)
				checkTokens(where .. ".desc", def.desc)
				for _, k in def.kinds or {} do
					if not pack.relationKinds[k] then
						err(where, "unknown relation kind '" .. tostring(k) .. "'")
					end
				end
				for kind, line in def.logs or {} do
					if kind ~= "friend" and not pack.relationKinds[kind] then
						err(where, "logs for unknown relation kind '" .. tostring(kind) .. "'")
					end
					checkTokens(where .. ".logs." .. tostring(kind), line)
				end
				local option = {}
				for k, v in def do
					if not INTERACTION_KEYS[k] then
						err(where, "unknown key '" .. tostring(k) .. "'")
					elseif k == "result" or k == "clash" or k == "win" or k == "lose" then
						option[k] = v
					end
				end
				checkOption(where, option, if def.linked then { linked = true } else nil, CHOICE_KEYS)
			end
		end
		allowRelTokens = false
	end

	-- expeditions (missions, dungeons, trips)
	local function checkCheck(where, c)
		if c == nil then
			return
		end
		for k in c do
			if not CHECK_KEYS[k] then
				err(where, "unknown check key '" .. tostring(k) .. "'")
			end
		end
		checkCond(where .. ".when", c.when)
		if c.bornSide and not pack.sides[c.bornSide] then
			err(where, "unknown side '" .. tostring(c.bornSide) .. "'")
		end
	end
	if pack.expeditions then
		allowCrewTokens = true
		for _, id in pack.expeditions.order or {} do
			local e = pack.expeditions[id]
			local where = "expedition " .. id
			if type(e) ~= "table" then
				err(where, "is in order but not defined")
				continue
			end
			for k in e do
				if not EXPEDITION_KEYS[k] then
					err(where, "unknown key '" .. tostring(k) .. "'")
				end
			end
			if type(e.name) ~= "string" or type(e.desc) ~= "string" then
				err(where, "needs a name and desc")
			end
			checkTokens(where .. ".name", e.name)
			checkTokens(where .. ".desc", e.desc)
			if e.kind and not ({ mission = 1, dungeon = 1, trip = 1, containment = 1 })[e.kind] then
				err(where, "kind must be mission, dungeon, trip or containment")
			end
			if e.crew and (type(e.crew.min) ~= "number" or type(e.crew.max) ~= "number" or e.crew.min > e.crew.max or e.crew.min < 1) then
				err(where, "crew needs min and max (1 or more, min <= max)")
			end
			checkCond(where .. ".when", e.when)
			if type(e.stages) ~= "table" or not e.start or not e.stages[e.start] then
				err(where, "needs stages and a start stage that exists")
				continue
			end
			local reached = { [e.start] = true }
			local queue = { e.start }
			while #queue > 0 do
				local sid = table.remove(queue)
				local st = e.stages[sid]
				for _, c in (st and st.choices) or {} do
					for _, key in { "next", "winNext", "loseNext" } do
						local n = c[key]
						if n and e.stages[n] and not reached[n] then
							reached[n] = true
							table.insert(queue, n)
						end
					end
				end
			end
			for sid, st in e.stages do
				local w = where .. " stage " .. tostring(sid)
				if not reached[sid] then
					warn(w, "can never be reached from the start")
				end
				if type(st.title) ~= "string" or type(st.text) ~= "string" then
					err(w, "needs a title and text")
				end
				checkTokens(w .. ".title", st.title)
				checkTokens(w .. ".text", st.text)
				if type(st.choices) ~= "table" or #st.choices == 0 then
					err(w, "needs at least one choice")
					continue
				end
				for i, c in st.choices do
					local cw = w .. " choice " .. i
					local option = {}
					for k, v in c do
						if not STAGE_CHOICE_KEYS[k] then
							err(cw, "unknown key '" .. tostring(k) .. "'")
						elseif k == "label" or k == "hint" or k == "requires" or k == "result" or k == "clash" or k == "win" or k == "lose" then
							option[k] = v
						end
					end
					checkOption(cw, option, e.when, CHOICE_KEYS)
					checkTokens(cw .. ".label", c.label)
					for _, key in { "next", "winNext", "loseNext" } do
						if c[key] ~= nil and not e.stages[c[key]] then
							err(cw, key .. " points at a stage that doesn't exist: " .. tostring(c[key]))
						end
					end
					for _, key in { "end", "winEnd", "loseEnd" } do
						if c[key] ~= nil and not ENDINGS[c[key]] then
							err(cw, key .. " must be success, fail or retreat")
						end
					end
				end
			end
			for _, key in { "success", "fail", "retreat" } do
				if e[key] then
					checkResult(where .. "." .. key, e[key], e.when)
				end
			end
		end
		allowCrewTokens = false
	end

	-- world events (switched on by the server for everyone at once)
	for _, id in (pack.worldEvents and pack.worldEvents.order) or {} do
		local we = pack.worldEvents[id]
		local where = "world event " .. id
		if type(we) ~= "table" then
			err(where, "is in order but not defined")
		else
			if type(we.name) ~= "string" or type(we.headline) ~= "string" or type(we.text) ~= "string" then
				err(where, "needs name, headline and text")
			end
			if we.district and not pack.districts[we.district] then
				err(where, "unknown district '" .. tostring(we.district) .. "'")
			end
			if we.startEvent and not eventIds[we.startEvent] then
				err(where, "startEvent '" .. tostring(we.startEvent) .. "' doesn't exist")
			end
			if we.expedition and not (pack.expeditions and pack.expeditions[we.expedition]) then
				err(where, "expedition '" .. tostring(we.expedition) .. "' doesn't exist")
			end
			if type(we.minutes) ~= "number" or we.minutes <= 0 then
				err(where, "minutes must be a number above 0")
			end
			checkCond(where .. ".when", we.when)
		end
	end

	-- side quests
	local QUEST_KEYS = { name = 1, desc = 1, giver = 1, steps = 1, reward = 1, expires = 1 }
	local STEP_KEYS = { text = 1, hint = 1, check = 1, onStart = 1, doneLog = 1 }
	local questStarted = {}
	for _, e in pack.events do
		local function scan(r)
			if type(r) == "table" and r.quest then
				questStarted[r.quest] = true
			end
		end
		scan(e.result)
		for _, c in e.choices or {} do
			scan(c.result)
			scan(c.win)
			scan(c.lose)
		end
	end
	for _, a in pack.activities or {} do
		if a.result and a.result.quest then
			questStarted[a.result.quest] = true
		end
	end
	for _, id in (pack.quests and pack.quests.order) or {} do
		local q = pack.quests[id]
		local where = "quest " .. id
		if type(q) ~= "table" then
			err(where, "is in order but not defined")
			continue
		end
		for k in q do
			if not QUEST_KEYS[k] then
				err(where, "unknown key '" .. tostring(k) .. "'")
			end
		end
		if type(q.name) ~= "string" or type(q.desc) ~= "string" then
			err(where, "needs a name and desc")
		end
		if type(q.steps) ~= "table" or #q.steps == 0 then
			err(where, "needs at least one step")
		else
			for i, st in q.steps do
				local sw = where .. " step " .. i
				for k in st do
					if not STEP_KEYS[k] then
						err(sw, "unknown key '" .. tostring(k) .. "'")
					end
				end
				if type(st.text) ~= "string" then
					err(sw, "needs text (what the player should do)")
				end
				if type(st.check) ~= "table" then
					err(sw, "needs a check (when the step counts as done)")
				end
				checkCheck(sw .. ".check", st.check)
				if st.onStart then
					local copy = table.clone(st.onStart)
					copy.log = copy.log or "" -- the opening line is optional here
					checkResult(sw .. ".onStart", copy, nil)
				end
			end
		end
		if q.reward then
			checkResult(where .. ".reward", q.reward, nil)
		end
		if not questStarted[id] then
			warn(where, "nothing starts this quest (an event or activity result needs quest = \"" .. id .. "\")")
		end
	end

	-- ambitions and titles
	local ambitionIds = {}
	for i, a in pack.ambitions or {} do
		local where = "ambition " .. tostring(a.id or i)
		if type(a.id) ~= "string" or ambitionIds[a.id] then
			err(where, "missing or duplicate id")
		end
		ambitionIds[a.id or ""] = true
		if type(a.name) ~= "string" or type(a.desc) ~= "string" then
			err(where, "needs a name and desc")
		end
		if type(a.check) ~= "table" then
			err(where, "needs a check")
		end
		checkCheck(where .. ".check", a.check)
		checkCond(where .. ".when", a.when)
		if a.reward then
			checkResult(where .. ".reward", a.reward, nil)
		end
	end
	for i, r in pack.ribbons or {} do
		local where = "title " .. tostring(r.id or i)
		if type(r.name) ~= "string" then
			err(where, "needs a name")
		end
		checkCheck(where .. ".check", r.check)
		if i == #pack.ribbons and r.check then
			warn(where, "the last title should have no check, so every life gets one")
		end
	end

	-- careers
	for _, id in pack.careers.order or {} do
		local c = pack.careers[id]
		local where = "career " .. id
		if not c then
			err(where, "listed in order but not defined")
		else
			if #c.salary ~= #c.ranks then
				err(where, "salary and ranks must be the same length")
			end
			if c.promoteAt and #c.promoteAt ~= #c.ranks - 1 then
				err(where, "promoteAt needs #ranks - 1 entries")
			end
			if c.promoteStat and not CORE_STATS[c.promoteStat] then
				err(where, "bad promoteStat")
			end
			if c.zones then
				err(where, "`zones` was replaced by `sides`")
			end
			for _, s in c.sides or {} do
				if not pack.sides[s] then
					err(where, "unknown side '" .. s .. "'")
				end
			end
			checkCond(where .. ".requires", c.requires)
			checkCond(where .. ".guttersRequire", c.guttersRequire)
			-- schools and uniforms
			if c.teaches and not (pack.schools and pack.schools[c.teaches]) then
				err(where, "teaches an unknown school '" .. tostring(c.teaches) .. "'")
			end
			for _, sid in c.teachesRoll or {} do
				if not (pack.schools and pack.schools[sid]) then
					err(where, "teachesRoll has an unknown school '" .. tostring(sid) .. "'")
				end
			end
			local outfits = {}
			for _, o in (pack.cosmetics and pack.cosmetics.outfit and pack.cosmetics.outfit.options) or {} do
				outfits[o.id] = true
			end
			if c.issue ~= nil and not (pack.gear and type(pack.gear[c.issue]) == "table") then
				err(where, "issue '" .. tostring(c.issue) .. "' isn't a gear item")
			end
			if c.uniform and not outfits[c.uniform] then
				err(where, "uniform '" .. tostring(c.uniform) .. "' isn't an outfit")
			end
			if c.uniformTop and not outfits[c.uniformTop.outfit or ""] then
				err(where, "uniformTop.outfit isn't an outfit")
			end
			if c.hazard then
				checkResult(where .. ".hazard", c.hazard.result, nil)
			end
		end
	end

	-- hard years
	for _, c in pack.crises or {} do
		local where = "crisis " .. tostring(c.id)
		if type(c.id) ~= "string" or type(c.name) ~= "string" then
			err(where, "needs an id and a name")
		end
		if c.trial and not (function()
			for _, e in pack.events or {} do
				if e.id == c.trial then
					return true
				end
			end
			return false
		end)() then
			err(where, "trial '" .. tostring(c.trial) .. "' is not an event")
		end
	end

	-- origins
	for _, o in pack.origins or {} do
		local where = "origin " .. tostring(o.id)
		if o.zone then
			err(where, "`zone` was replaced by `side` (optional)")
		end
		if o.side and not pack.sides[o.side] then
			err(where, "unknown side")
		end
		if o.form and not pack.forms[o.form] then
			err(where, "unknown form")
		end
		if o.district and not pack.districts[o.district] then
			err(where, "unknown district")
		end
		checkTokens(where .. ".birth", o.birth, nil)
		local h = o.household
		if h ~= nil then
			if type(h) ~= "table" then
				err(where, "household must be a table")
			else
				for k in h do
					if k ~= "owns" and k ~= "business" and k ~= "jobs" then
						err(where, "unknown household key '" .. tostring(k) .. "'")
					end
				end
				for kind, list in h.jobs or {} do
					if not pack.relationKinds[kind] then
						err(where, "household.jobs has unknown kind '" .. tostring(kind) .. "'")
					end
					for _, j in list do
						if type(j) ~= "table" or type(j[1]) ~= "string" or type(j[2]) ~= "string" then
							err(where, "each job is { short, sentence }")
						end
					end
				end
			end
		end
	end

	-- clash curve
	if pack.clash ~= nil then
		if type(pack.clash) ~= "table" then
			err("clash", "must be a table")
		else
			for _, key in { "coinsEvery", "maxCoins", "baseEvery", "powerEvery" } do
				local v = pack.clash[key]
				if v ~= nil and (type(v) ~= "number" or v <= 0) then
					err("clash", key .. " must be a number above 0")
				end
			end
		end
	end

	-- sides & districts
	if not pack.sides or not pack.sides.order or #pack.sides.order < 1 then
		err("sides", "needs sides.order with at least one side")
	else
		for _, id in pack.sides.order do
			local s = pack.sides[id]
			if not s then
				err("sides", "'" .. id .. "' is in order but not defined")
			else
				for _, key in { "costMult", "payMult", "danger", "hazardChance", "wear", "evictGrace" } do
					if s[key] ~= nil and type(s[key]) ~= "number" then
						err("side " .. id, key .. " must be a number")
					end
				end
				if type(s.evictGrace) == "number" and (s.evictGrace < 0 or s.evictGrace % 1 ~= 0) then
					err("side " .. id, "evictGrace must be a whole number, 0 or more")
				end
			end
		end
	end
	if not pack.districts or not pack.districts.order or #pack.districts.order < 1 then
		err("districts", "needs districts.order with at least one district")
	else
		for _, id in pack.districts.order do
			local d = pack.districts[id]
			local where = "district " .. id
			if not d then
				err(where, "is in order but not defined")
			else
				if type(d.name) ~= "string" then
					err(where, "needs a name")
				end
				for _, key in { "wealth", "danger", "cost", "charterCost", "charterShare" } do
					if d[key] ~= nil and type(d[key]) ~= "number" then
						err(where, key .. " must be a number")
					end
				end
				for careerId in d.careerPay or {} do
					if not pack.careers[careerId] then
						err(where, "careerPay has unknown career '" .. tostring(careerId) .. "'")
					end
				end
				for sideId in d.yearly or {} do
					if not pack.sides[sideId] then
						err(where, "yearly has unknown side '" .. tostring(sideId) .. "'")
					end
				end
			end
		end
	end

	-- gear, conditions, approaches, records
	if pack.gear then
		for _, id in pack.gear.order or {} do
			local g = pack.gear[id]
			local where = "gear " .. id
			if not g then
				err(where, "is in order but not defined")
			else
				if not table.find(pack.gear.slots or {}, g.slot) then
					err(where, "slot must be one of gear.slots")
				end
				for stat in g.clash or {} do
					if not CORE_STATS[stat] then
						err(where, "clash bonus for unknown stat '" .. tostring(stat) .. "'")
					end
				end
				checkCond(where .. ".requires", g.requires)
			end
		end
	end
	for id, c in pack.conditions or {} do
		for stat in c.clash or {} do
			if not CORE_STATS[stat] then
				err("condition " .. id, "clash penalty for unknown stat '" .. tostring(stat) .. "'")
			end
		end
	end
	-- tempers: each names the way of fighting it's weak to and the one it shrugs off
	if pack.tempers then
		for _, id in pack.tempers.order or {} do
			local t = pack.tempers[id]
			if type(t) ~= "table" or type(t.name) ~= "string" then
				err("temper " .. tostring(id), "needs a name")
			else
				for _, key in { "weakTo", "strongTo" } do
					if t[key] ~= nil and not (pack.approaches and pack.approaches[t[key]]) then
						err("temper " .. id, key .. " names unknown approach '" .. tostring(t[key]) .. "'")
					end
				end
			end
		end
		for _, id in (pack.foes and pack.foes.order) or {} do
			local f = pack.foes[id]
			if f.temper ~= nil and not pack.tempers[f.temper] then
				err("foe " .. id, "unknown temper '" .. tostring(f.temper) .. "'")
			elseif f.temper == nil then
				warn("foe " .. id, "has no temper")
			end
		end
	end
	-- tier perks and natures hang off real stats
	if pack.stats and pack.stats.perks then
		for stat, byTier in pack.stats.perks do
			if not CORE_STATS[stat] then
				err("stats.perks", "unknown stat '" .. tostring(stat) .. "'")
			end
			for tier, perk in byTier do
				if type(tier) ~= "number" or tier < 2 or tier > (pack.stats.tierMax or 5) then
					err("stats.perks." .. tostring(stat), "tier " .. tostring(tier) .. " is out of range")
				elseif type(perk) ~= "table" or type(perk.name) ~= "string" or type(perk.desc) ~= "string" then
					err("stats.perks." .. tostring(stat) .. "[" .. tostring(tier) .. "]", "needs a name and a desc")
				end
			end
		end
	end
	if pack.stats and pack.stats.natures then
		for _, id in pack.stats.natures.order or {} do
			if not CORE_STATS[id] then
				err("stats.natures", "unknown stat '" .. tostring(id) .. "'")
			elseif type(pack.stats.natures[id]) ~= "table" or type(pack.stats.natures[id].name) ~= "string" then
				err("stats.natures." .. id, "needs a name")
			end
		end
	end
	if pack.approaches then
		for _, id in pack.approaches.order or {} do
			local a = pack.approaches[id]
			if type(a) == "table" then
				if a.stat ~= nil and not CORE_STATS[a.stat] then
					err("approach " .. id, "fights with unknown stat '" .. tostring(a.stat) .. "'")
				end
				for _, key in { "beats", "loses" } do
					if a[key] ~= nil and not (pack.tempers and pack.tempers[a[key]]) then
						err("approach " .. id, key .. " names unknown temper '" .. tostring(a[key]) .. "'")
					end
				end
				if a.only ~= nil and a.only ~= "person" then
					err("approach " .. id, "only = 'person' is the one kind there is")
				end
			end
		end
		for _, id in pack.approaches.order or {} do
			if not pack.approaches[id] then
				err("approach " .. id, "is in order but not defined")
			elseif pack.approaches[id].after then
				checkResult("approach " .. id .. ".after", pack.approaches[id].after, nil)
			end
		end
	end
	local recordIds = {}
	for _, r in pack.records or {} do
		if type(r.id) ~= "string" or recordIds[r.id] then
			err("record " .. tostring(r.id), "missing or duplicate id")
		end
		recordIds[r.id or ""] = true
		checkCond("record " .. tostring(r.id) .. ".check.when", r.check and r.check.when)
	end

	for id in storyIds do
		if (storyBeats[id] or 0) < 5 then
			warn("storyline " .. id, "has " .. tostring(storyBeats[id] or 0) .. " beats; a main story needs at least 5 (events with story = \"" .. id .. "\")")
		end
		if (storyAnchors[id] or 0) < 1 then
			err("storyline " .. id, "needs an opening beat with always = true (so every life on this story starts it)")
		end
	end

	-- cosmetics and looks (what Engine/Avatar knows how to draw)
	local function isColor(c)
		return type(c) == "table" and type(c[1]) == "number" and type(c[2]) == "number" and type(c[3]) == "number"
	end
	local HAIR_STYLES = {
		wavy = 1, hime = 1, curtains = 1, shaggy = 1, bowl = 1, afro = 1, locs = 1, lowtails = 1, sidebraid = 1, halfup = 1, undercut = 1, pompadour = 1, topknot = 1,
		crop = true, shorn = true, long = true, bun = true, braid = true, curls = true, ridge = true, hood = true, cap = true, veil = true, tophat = true,
		slick = true, spiky = true, ponytail = true, bob = true, twintails = true, sidecut = true, messy = true,
	}
	local ACCESSORY_STYLES = {
		none = true, sunglasses = true, glasses = true, roundglasses = true, monocle = true, mask = true, halfmask = true,
		visor = true, scarf = true, headband = true, earring = true, fedora = true,
	}
	local MARKS = { none = true, freckles = true, scar = true, ink = true, patch = true }
	-- everything a hand can hold comes from Engine/Arms.luau (through Avatar.toolKinds); coats
	-- and charms are drawn by Avatar itself
	local GEAR_KINDS = { coat = true, jacket = true, greatcoat = true, stone = true, bell = true, token = true }
	local WEAPON_KINDS = {}
	for kind in Avatar.toolKinds do
		GEAR_KINDS[kind] = true
		WEAPON_KINDS[kind] = true
	end
	for kind in Avatar.armKinds or {} do
		GEAR_KINDS[kind] = true -- (v0.17) augment arms
	end
	local CONDITION_LOOKS = { cast = true, pale = true, bandaged = true, shadows = true, armband = true, kinmark = true }
	local cosmetics = pack.cosmetics
	if cosmetics then
		local categories = { "skin", "hair", "hairColor", "outfit", "mark", "frame" }
		for _, optional in { "eyes", "accessory", "weapon" } do
			if cosmetics[optional] ~= nil then
				table.insert(categories, optional)
			end
		end
		for _, category in categories do
			local cat = cosmetics[category]
			local where = "cosmetics." .. category
			if type(cat) ~= "table" or type(cat.options) ~= "table" or #cat.options == 0 then
				err(where, "needs a list of options")
			else
				local seen = {}
				local free = 0
				for i, o in cat.options do
					local w = where .. " option " .. tostring(o.id or i)
					if type(o.id) ~= "string" or seen[o.id] then
						err(w, "missing or duplicate id")
					end
					seen[o.id or ""] = true
					if type(o.name) ~= "string" then
						err(w, "needs a name")
					end
					if o.record and not recordIds[o.record] then
						err(w, "unlocks with unknown record '" .. tostring(o.record) .. "'")
					end
					if o.glow ~= nil and (type(o.glow) ~= "number" or o.glow < 0) then
						err(w, "glow must be a number, 0 or more")
					end
					if category == "skin" and (o.glow or o.record or o.store) then
						err(w, "skin tones can't be locked")
					end
					if o.store ~= nil and type(o.store) ~= "string" then
						err(w, "store must be an item key from Config.store")
					elseif type(o.store) == "string" and pack.store and pack.store.items then
						-- the pack has its own catalog: the key must be one of its items
						local found = false
						for _, item in pack.store.items do
							if item.key == o.store then
								found = true
							end
						end
						if not found then
							err(w, "store item '" .. o.store .. "' isn't in the pack's store catalog")
						end
					end
					if (category == "skin" or category == "hairColor" or category == "frame") and not isColor(o.color) then
						err(w, "needs color = { r, g, b }")
					end
					if category == "hair" and not HAIR_STYLES[o.style or ""] then
						err(w, "style must be one of the hair styles Avatar draws")
					end
					if category == "outfit" and not (isColor(o.shirt) and isColor(o.pants)) then
						err(w, "needs shirt and pants colors")
					end
					if category == "mark" and not MARKS[o.style or o.id or ""] then
						err(w, "Avatar doesn't know how to draw this mark")
					end
					if category == "accessory" and not ACCESSORY_STYLES[o.style or o.id or ""] then
						err(w, "Avatar doesn't know how to draw this accessory")
					end
					if category == "eyes" and not isColor(o.color) then
						err(w, "needs color = { r, g, b }")
					end
					if category == "weapon" and o.id ~= "none" and not WEAPON_KINDS[o.kind or ""] then
						err(w, "kind must be a weapon Avatar draws")
					end
					for _, feature in {
						"longcoat", "cape", "gloves", "armband", "sash", "belt", "apron", "vest", "tie", "buttons", "collar", "shoes",
						"hakama", "skirt", "stripe", "boots", "kneepads", "jacket", "lapels", "wrap", "suspenders", "plate", "tabard", "straps",
						"bandolier", "cuffs", "pauldrons", "epaulettes", "halfcape", "mantle", "fur", "scarf", "pack", "emblem",
					} do
						if category == "outfit" and o[feature] ~= nil and not isColor(o[feature]) then
							err(w, feature .. " must be a color { r, g, b }")
						end
					end
					if not o.record and not o.store and not o.daily and not (o.glow and o.glow > 0) then
						free += 1
					end
				end
				if free == 0 then
					err(where, "needs at least one free option")
				end
			end
		end
		-- premade characters: every pick must be a real option
		for i, ident in cosmetics.identities or {} do
			local where = "cosmetics.identities[" .. i .. "]"
			if type(ident.id) ~= "string" or type(ident.name) ~= "string" or type(ident.look) ~= "table" then
				err(where, "needs id, name and look")
			else
				for category, id in ident.look do
					local cat = cosmetics[category]
					local found = false
					for _, o in (cat and cat.options) or {} do
						if o.id == id then
							found = true
						end
					end
					if not found then
						err(where, "look." .. tostring(category) .. " '" .. tostring(id) .. "' isn't an option")
					end
				end
			end
		end
	end
	-- v0.8: faces for people who talk (pack.cast), foes for the fight screen, chapter cards
	local function checkPartialLook(where, look)
		if look == nil then
			return
		end
		if type(look) ~= "table" or not cosmetics then
			err(where, "look must be a table of cosmetic picks")
			return
		end
		for category, id in look do
			local cat = cosmetics[category]
			local found = false
			for _, o in (cat and cat.options) or {} do
				if o.id == id then
					found = true
				end
			end
			if not found then
				err(where, "look." .. tostring(category) .. " '" .. tostring(id) .. "' isn't an option")
			end
		end
	end
	for id, c in pack.cast or {} do
		local where = "cast " .. tostring(id)
		if type(c.name) ~= "string" then
			err(where, "needs a name")
		end
		-- other names they can go by in other lives; `short` is a word of the name
		if c.names ~= nil then
			if type(c.names) ~= "table" then
				err(where, "names must be a list of other names")
			else
				for _, n in c.names do
					if type(n) ~= "string" or n == "" then
						err(where, "every other name must be text")
					end
				end
			end
		end
		if c.short ~= nil and (type(c.short) ~= "string" or not (type(c.name) == "string" and string.find(c.name, c.short, 1, true))) then
			err(where, "short must be the first or last word of the name")
		end
		for k in c do
			if k ~= "id" and k ~= "name" and k ~= "title" and k ~= "look" and k ~= "source" and k ~= "names" and k ~= "short" then
				err(where, "unknown cast key '" .. tostring(k) .. "'")
			end
		end
		if pack.foes and pack.foes[id] then
			err(where, "same id as a foe")
		end
		checkPartialLook(where, c.look)
	end
	for _, id in (pack.foes and pack.foes.order) or {} do
		local f = pack.foes[id]
		local where = "foe " .. tostring(id)
		if type(f.name) ~= "string" then
			err(where, "needs a name")
		end
		if f.kind == "human" then
			checkPartialLook(where, f.look)
		elseif f.kind ~= "creature" then
			err(where, "kind must be human or creature")
		end
		if f.faction ~= nil and not (pack.reputation and type(pack.reputation[f.faction]) == "table") then
			err(where, "faction '" .. tostring(f.faction) .. "' isn't in pack.reputation")
		end
		if f.speed ~= nil and type(f.speed) ~= "number" then
			err(where, "speed must be a number (quicker or slower than its coins say)")
		end
	end
	-- reputation: every faction's careers and reprisal events exist; results and conditions
	-- name real factions
	local repPack = pack.reputation
	if repPack then
		local reprisalEvents = {}
		for _, e in pack.events do
			reprisalEvents[e.id] = e
		end
		for _, id in repPack.order or {} do
			local def = repPack[id]
			local where = "reputation " .. tostring(id)
			if type(def) ~= "table" or type(def.name) ~= "string" then
				err(where, "needs a name")
			else
				for _, c in def.careers or {} do
					if not pack.careers[c] then
						err(where, "unknown career '" .. tostring(c) .. "'")
					end
				end
				for _, evId in def.reprisal or {} do
					if not reprisalEvents[evId] then
						err(where, "reprisal names unknown event '" .. tostring(evId) .. "'")
					elseif (reprisalEvents[evId].weight or 10) > 0 then
						warn(where, "reprisal event '" .. evId .. "' has a weight: it will also turn up at random")
					end
				end
			end
		end
	end
	local function checkRepKeys(where, tbl)
		if tbl == nil then
			return
		end
		if type(tbl) ~= "table" then
			err(where, "must be { faction = number }")
			return
		end
		for id in tbl do
			if not (repPack and type(repPack[id]) == "table") then
				err(where, "unknown faction '" .. tostring(id) .. "'")
			end
		end
	end
	for _, e in pack.events do
		local where = "event " .. tostring(e.id)
		if e.when then
			checkRepKeys(where .. ".when.minRep", e.when.minRep)
			checkRepKeys(where .. ".when.maxRep", e.when.maxRep)
		end
		for i, c in e.choices or {} do
			for _, key in { "result", "win", "lose" } do
				if type(c[key]) == "table" then
					checkRepKeys(where .. " choice " .. i .. "." .. key .. ".rep", c[key].rep)
				end
			end
		end
	end
	-- difficulties
	local diffs = pack.difficulties
	if diffs then
		for _, id in diffs.order or {} do
			if type(diffs[id]) ~= "table" or type(diffs[id].name) ~= "string" then
				err("difficulty " .. tostring(id), "needs a name")
			end
		end
		if not (diffs.default and type(diffs[diffs.default]) == "table") then
			err("difficulties", "default must name one of them")
		end
	end
	for _, m in (pack.foes and pack.foes.match) or {} do
		if not (pack.foes[m[2]]) then
			err("foes.match '" .. tostring(m[1]) .. "'", "points at unknown foe '" .. tostring(m[2]) .. "'")
		end
	end
	local cantoAges = {}
	for _, ch in pack.chapters or {} do
		if type(ch.age) == "number" then
			cantoAges[ch.age] = true
		end
	end
	local lastIv = -1
	for i, iv in pack.intervallos or {} do
		local where = "intervallos[" .. i .. "]"
		if type(iv.age) ~= "number" or type(iv.title) ~= "string" then
			err(where, "needs age and title")
		elseif iv.age <= lastIv then
			err(where, "intervallos must be in rising age order")
		elseif cantoAges[iv.age] then
			err(where, "an intervallo can't share an age with a canto")
		else
			lastIv = iv.age
		end
	end
	local lastAge = -1
	for i, ch in pack.chapters or {} do
		local where = "chapters[" .. i .. "]"
		-- (v0.12) a title or line may be a list of variants: each life gets one
		local titleOk = type(ch.title) == "string" or (type(ch.title) == "table" and #ch.title > 0 and type(ch.title[1]) == "string")
		if type(ch.line) == "table" then
			for _, l in ch.line do
				checkTokens(where .. ".line", l)
			end
		end
		if type(ch.age) ~= "number" or not titleOk then
			err(where, "needs age and title")
		elseif ch.age <= lastAge then
			err(where, "chapters must be in rising age order")
		else
			lastAge = ch.age
		end
	end

	if pack.gear then
		for _, id in pack.gear.order or {} do
			local g = pack.gear[id]
			if g and g.look ~= nil and not (type(g.look) == "table" and GEAR_KINDS[g.look.kind or ""]) then
				err("gear " .. id, "look.kind must be one of the kinds Avatar draws")
			end
		end
	end
	for id, c in pack.conditions or {} do
		if c.look ~= nil and not CONDITION_LOOKS[c.look] then
			err("condition " .. id, "look must be one of: cast, pale, bandaged, shadows, armband, kinmark")
		end
	end
	for id, f in pack.forms or {} do
		if type(f) == "table" and f.look ~= nil then
			if type(f.look) ~= "table" or (f.look.tint ~= nil and not isColor(f.look.tint)) or (f.look.eyes ~= nil and not isColor(f.look.eyes)) then
				err("form " .. id, "look needs tint/eyes colors")
			end
		end
	end

	-- hazards
	local hazardIds = {}
	for _, h in pack.hazards or {} do
		local where = "hazard " .. tostring(h.id)
		if type(h.id) ~= "string" then
			err("hazard", "missing id")
		elseif hazardIds[h.id] then
			err(where, "duplicate id")
		end
		hazardIds[h.id or ""] = true
		if type(h.title) ~= "string" then
			err(where, "missing title")
		end
		if h.side and not pack.sides[h.side] then
			err(where, "unknown side '" .. tostring(h.side) .. "'")
		end
		for _, d in asList(h.district) do
			if not pack.districts[d] then
				err(where, "unknown district '" .. tostring(d) .. "'")
			end
		end
		checkCond(where .. ".when", h.when)
		if h.result == nil then
			err(where, "needs a result")
		end
		checkResult(where .. ".result", h.result, h.when)
	end

	-- hooks
	if pack.hooks then
		for name, ids in pack.hooks do
			-- one event id, or a list (the first whose `when` fits the life is used)
			for _, id in (if type(ids) == "table" then ids else { ids }) do
				if not eventIds[id] then
					err("hooks." .. name, "points to missing event '" .. tostring(id) .. "'")
				end
			end
		end
	end

	-- traits
	if pack.traits then
		-- (v0.18) two traits with one name can't be told apart on a card or in the mod menu
		local nameOf: { [string]: string } = {}
		for _, id in pack.traits.order or {} do
			local def = pack.traits[id]
			local where = "trait " .. id
			if type(def) ~= "table" then
				err(where, "is in order but not defined")
			else
				if type(def.name) ~= "string" or type(def.desc) ~= "string" then
					err(where, "needs a name and desc")
				else
					local key = string.lower(tostring(def.name))
					if nameOf[key] and nameOf[key] ~= id then
						err(where, "has the same name as trait " .. nameOf[key] .. " ('" .. def.name .. "')")
					else
						nameOf[key] = id
					end
				end
				if def.style ~= nil and not (pack.styles and pack.styles[def.style]) then
					err(where, "style must be a fighting style id (its bonuses only work with that style)")
				end
				for key in def.stats or {} do
					if not CORE_STATS[key] then
						err(where, "unknown stat '" .. tostring(key) .. "'")
					end
				end
				if def.earn ~= nil then
					-- (v0.18) earned by itself: the same need keys as a feat (Engine/Feats.luau)
					local NEED = { age = 1, money = 1, peakMoney = 1, renown = 1, stat = 1, anyStat = 1, allStats = 1, flags = 1, episodes = 1, cases = 1, blocks = 1, office = 1, home = 1, children = 1, closeFriends = 1, married = 1, uniques = 1, legendary = 1, delves = 1, form = 1, careerTop = 1, lives = 1, clashes = 1 }
					if type(def.earn) ~= "table" then
						err(where, "earn must be a table of need keys")
					else
						for key in def.earn do
							if not NEED[key] then
								err(where, "earn: unknown need key '" .. tostring(key) .. "'")
							end
						end
						for key in (type(def.earn.stat) == "table" and def.earn.stat or {}) do
							if not CORE_STATS[key] then
								err(where, "earn.stat: unknown stat '" .. tostring(key) .. "'")
							end
						end
					end
				end
				if def.clash then
					for key, b in def.clash do
						if key ~= "any" and not CORE_STATS[key] then
							err(where, "clash keys are stats or 'any', not '" .. tostring(key) .. "'")
						elseif type(b) ~= "table" then
							err(where, "clash." .. tostring(key) .. " must be { coins, base, coinPower }")
						end
					end
				end
			end
		end
		local picks = 0
		for _, id in pack.traits.order or {} do
			if pack.traits[id] and pack.traits[id].pick then
				picks += 1
			end
		end
		if picks < (pack.traitPicks or 2) then
			warn("traits", "fewer pickable traits than pack.traitPicks")
		end
	end
	-- fighting styles
	if pack.styles then
		for _, id in pack.styles.order or {} do
			local def = pack.styles[id]
			if type(def) ~= "table" or type(def.name) ~= "string" then
				err("style " .. id, "needs a name")
			elseif not Clash.statusOf(def.status or id) then
				err("style " .. id, "status must be one of " .. table.concat(Clash.STATUS_IDS, ", "))
			end
		end
	end
	-- lore codex
	if pack.codex then
		local cats = {}
		for _, c in pack.codex.categories or {} do
			cats[c.id] = true
		end
		for _, entry in pack.codex.entries or {} do
			local where = "codex " .. tostring(entry.id)
			if not cats[entry.category] then
				err(where, "unknown category '" .. tostring(entry.category) .. "'")
			end
			if type(entry.title) ~= "string" or type(entry.text) ~= "string" then
				err(where, "needs a title and text")
			end
		end
	end
	-- daily events
	if pack.daily then
		for _, id in pack.daily.order or {} do
			local def = pack.daily[id]
			if type(def) ~= "table" then
				err("daily " .. id, "is in order but not defined")
			elseif not eventIds[def.event] then
				err("daily " .. id, "event '" .. tostring(def.event) .. "' doesn't exist")
			end
		end
	end
	-- chronicle acts
	for act, def in pack.chronicle or {} do
		if type(def) ~= "table" or type(def.text) ~= "string" then
			err("chronicle " .. tostring(act), "needs text")
		elseif not string.find(def.text, "{name}", 1, true) then
			warn("chronicle " .. tostring(act), "text should mention {name}")
		end
	end
	-- surnames
	if pack.surnames then
		for _, tier in pack.surnames.tiers or {} do
			local where = "surname tier " .. tostring(tier.id)
			if type(tier.weight) ~= "number" or tier.weight <= 0 then
				err(where, "needs a positive weight")
			end
			local names = pack.surnames.names and pack.surnames.names[tier.id]
			if type(names) ~= "table" or #names == 0 then
				err(where, "has no names")
			end
			if tier.trait and not (pack.traits and pack.traits[tier.trait]) then
				err(where, "unknown trait '" .. tostring(tier.trait) .. "'")
			end
		end
	end

	-- (v0.19) the roster and the party (Engine/Party.luau)
	local ROSTER_KEYS = { id = 1, first = 1, last = 1, born = 1, rank = 1, class = 1, guild = 1, role = 1, home = 1, personality = 1, likes = 1, dislikes = 1, backstory = 1, lines = 1, look = 1, recruit = 1, canon = 1, note = 1, gender = 1, title = 1 }
	local LINE_KINDS = { greet = 1, accept = 1, refuse = 1, battle = 1, hurt = 1, farewell = 1, gift = 1 }
	local seenRoster = {}
	for i, d in rosterList do
		if type(d) ~= "table" then
			continue
		end
		local where = "roster " .. tostring(d.id or i)
		if seenRoster[d.id] then
			err(where, "duplicate id")
		end
		seenRoster[d.id] = true
		if type(d.id) == "string" and string.sub(d.id, 1, 4) ~= "npc_" then
			err(where, "id must start with npc_")
		end
		for k in d do
			if not ROSTER_KEYS[k] then
				warn(where, "unknown roster key '" .. tostring(k) .. "'")
			end
		end
		if type(d.first) ~= "string" or d.first == "" then
			err(where, "needs a first name")
		end
		if d.last ~= nil and type(d.last) ~= "string" then
			err(where, "last must be text")
		end
		if d.born ~= nil and type(d.born) ~= "number" then
			err(where, "born must be a Gate Year (a number)")
		end
		if d.rank ~= nil and not PARTY_RANKS[d.rank] then
			err(where, "rank must be E, D, C, B, A or S (or nil for unawakened)")
		end
		if d.class ~= nil and not PARTY_CLASSES[d.class] then
			err(where, "class must be fighter, mage, assassin, tanker, ranger or healer")
		end
		if d.class ~= nil and d.rank == nil then
			warn(where, "has a class but no rank (an unawakened person has no class)")
		end
		if d.personality ~= nil then
			if type(d.personality) ~= "table" then
				err(where, "personality must be a list of traits")
			else
				for _, t in d.personality do
					if not PARTY_TRAITS[t] then
						err(where, "unknown personality trait '" .. tostring(t) .. "'")
					end
				end
			end
		end
		for _, key in { "likes", "dislikes", "backstory" } do
			local v = d[key]
			if v ~= nil then
				if type(v) ~= "table" then
					err(where, key .. " must be a list of text")
				else
					for _, l in v do
						if type(l) ~= "string" or l == "" then
							err(where, key .. " must be a list of text")
						end
					end
				end
			end
		end
		if type(d.backstory) == "table" and (#d.backstory < 1 or #d.backstory > 8) then
			warn(where, "backstory has " .. #d.backstory .. " lines (3 to 6 read best)")
		end
		if d.lines ~= nil then
			if type(d.lines) ~= "table" then
				err(where, "lines must be { greet, accept, refuse, battle, hurt, farewell, gift }")
			else
				for k, v in d.lines do
					if not LINE_KINDS[k] then
						warn(where, "unknown line kind '" .. tostring(k) .. "'")
					end
					local list = if type(v) == "string" then { v } else v
					if type(list) ~= "table" then
						err(where, "lines." .. tostring(k) .. " must be text or a list of text")
					else
						for _, l in list do
							if type(l) ~= "string" then
								err(where, "lines." .. tostring(k) .. " must be text or a list of text")
							end
						end
					end
				end
			end
		end
		if d.look ~= nil and (type(d.look) ~= "table" or (d.look.preset ~= nil and type(d.look.preset) ~= "string")) then
			err(where, "look must be { preset = <Looks preset id>, overrides = {...} }")
		end
		if d.recruit ~= nil then
			local rc = d.recruit
			if type(rc) ~= "table" then
				err(where, "recruit must be { difficulty, minRank, wantsPay }")
			else
				if rc.difficulty ~= nil and (type(rc.difficulty) ~= "number" or rc.difficulty < 1 or rc.difficulty > 5) then
					err(where, "recruit.difficulty must be 1..5")
				end
				if rc.minRank ~= nil and not PARTY_RANKS[rc.minRank] then
					err(where, "recruit.minRank must be E..S")
				end
				if rc.wantsPay ~= nil and (type(rc.wantsPay) ~= "number" or rc.wantsPay < 0) then
					err(where, "recruit.wantsPay must be a number")
				end
			end
		end
	end
	local pc = pack.party
	if type(pc) == "table" then
		for id, list in pc.castMeet or {} do
			local e = nil
			for _, ev in pack.events or {} do
				if ev.id == id then
					e = ev
				end
			end
			if not e then
				err("party.castMeet " .. tostring(id), "isn't an event")
			else
				for i, m in list do
					local where = "party.castMeet " .. tostring(id) .. "[" .. i .. "]"
					checkMeet(where, m)
					for _, c in (if type(m.choice) == "table" then m.choice else { m.choice }) do
						if c ~= nil and not (e.choices and e.choices[c]) then
							err(where, "event has no choice " .. tostring(c))
						end
					end
				end
			end
		end
		for kind, id in pc.cards or {} do
			if kind == "betray" then
				for _, L in { "E", "D", "C", "B", "A", "S" } do
					local found = false
					for _, ev in pack.events or {} do
						if ev.id == id .. L then
							found = true
						end
					end
					if not found then
						err("party.cards.betray", "no card '" .. tostring(id) .. L .. "'")
					end
				end
			else
				local found = nil
				for _, ev in pack.events or {} do
					if ev.id == id then
						found = ev
					end
				end
				if not found then
					err("party.cards." .. tostring(kind), "no card '" .. tostring(id) .. "'")
				elseif not found.partyCard then
					err("party.cards." .. tostring(kind), "card '" .. tostring(id) .. "' needs partyCard = true")
				end
			end
		end
		for _, g in pc.gifts or {} do
			if type(g.id) ~= "string" or type(g.name) ~= "string" or type(g.price) ~= "number" then
				err("party.gifts", "every gift needs id, name and price")
			end
		end
		for kind, pools in pc.lines or {} do
			if not LINE_KINDS[kind] then
				warn("party.lines", "unknown line kind '" .. tostring(kind) .. "'")
			end
			for trait in pools do
				if trait ~= "any" and not PARTY_TRAITS[trait] then
					err("party.lines." .. tostring(kind), "unknown trait '" .. tostring(trait) .. "'")
				end
			end
		end
	end

	return { errors = errors, warnings = warnings }
end

return Validate
