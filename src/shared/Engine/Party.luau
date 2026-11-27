--[[
	THE PARTY (v0.19): bonds with everyone a life meets, and up to four companions who go into
	the Gates beside you. A pack turns it on with `pack.party` (BitLeveling: Interactions.luau);
	without it every function here does nothing and the engine behaves exactly as before.

	PEOPLE. Every relation a life has (family, friends, rivals, the acquaintances People.luau
	brings in, the survivors and raid teammates Gate incidents introduce, the saga characters
	`pack.party.castMeet` names) gets a profile the first time it matters:
		rel.rank      0 (unawakened) .. 6 (S)          rel.class   "fighter" | "mage" | ... | nil
		rel.traits    personality (Party.TRAITS)        rel.power   0..5, grows with training
		rel.revealed  backstory lines told so far       rel.history what you've done together
	An NPC from the game's roster (`pack.roster`, ids "npc_<slug>"; an event introduces one
	with addRelation = { kind, name, age, bond, roster = "<id>" }) takes its rank, class,
	personality, likes, dislikes, backstory and lines from there. Everyone else is generated
	from the life's id and theirs (a hash, never the life's dice), so the same person is the
	same in every view and a life without a party rolls exactly the dice it always did.

	THE PARTY (life.party): up to `max` members { rel, joined, loyalty, share, retainer,
	condition = "fine" | "hurt" | "down", out, wins, losses, unpaid }.
	  ASK       odds from the bond, both ranks (a strong Hunter won't follow a weak one; a weaker
	            one may jump at it), Charisma, your name, their personality (greedy want paying,
	            loyal count the bond twice, proud refuse the weaker, cautious refuse a dangerous
	            life), the party's size and whether you're awakened at all. Shown before you ask,
	            factor by factor; then they ACCEPT or REFUSE in their own words.
	  HELP      a card's clash with `party = { rank, kind }` (Gate incidents) is fought with them:
	            damage classes add power, assassins and rangers land more heads, a Tanker takes
	            the hits and a Healer cuts what you lose. It's in the odds and on the chips. In a
	            boss battle (Engine/Battle) they act every turn: strike, guard, heal.
	  RISK      after the fight each one may be hurt or killed: rarely in a Gate at or under
	            their rank, often in a mismatched one, more in a Red Gate or a Double Dungeon.
	            A death costs Sanity and shakes the others.
	  MONEY     each takes a share of the take; the greedy and the stronger want a yearly
	            retainer too. Unpaid, loyalty falls.
	  LOYALTY   up with shared wins, gifts and a strong bond; down with losses, unpaid money,
	            reckless Gates and deaths. Too low and they leave; a scheming one may sell you
	            out, once. Every year they age, may get stronger, and may leave for reasons of
	            their own (a card: `pack.party.cards`).
	Everything lives in plain tables on the life: it saves as it is.
]]

local Rng = require(script.Parent.Rng)
local Util = require(script.Parent.Util)
local Effects = require(script.Parent.Effects)
local HW = require(script.Parent.HunterWorld)

local Party = {}

Party.MAX = 4
Party.RANKS = { "E", "D", "C", "B", "A", "S" }
local RANK_INDEX = { E = 1, D = 2, C = 3, B = 4, A = 5, S = 6 }
Party.RANK_INDEX = RANK_INDEX
local EMPTY = table.freeze({})

-- the personalities (a roster NPC's `personality`, a generated person's two)
Party.TRAITS = {
	order = { "brave", "cautious", "greedy", "loyal", "proud", "kind", "reckless", "cold", "cheerful", "ambitious", "honest", "scheming" },
	brave = { name = "Brave", desc = "Goes first into a bad room, and likes a Hunter who does the same." },
	cautious = { name = "Cautious", desc = "Counts the exits. Won't follow a life that keeps walking into danger." },
	greedy = { name = "Greedy", desc = "Wants paying, and paying well: a fee to join, a bigger share, a retainer." },
	loyal = { name = "Loyal", desc = "The bond is what counts. Slow to win, very slow to lose." },
	proud = { name = "Proud", desc = "Won't take orders from a weaker Hunter." },
	kind = { name = "Kind", desc = "Likes people who help people. Takes it hard when the party gets hurt." },
	reckless = { name = "Reckless", desc = "Likes a dangerous life. Gets hurt more often than most." },
	cold = { name = "Cold", desc = "Hard to reach. Bonds grow slowly, and they don't say much." },
	cheerful = { name = "Cheerful", desc = "Easy to like, quick to say yes, keeps the party talking." },
	ambitious = { name = "Ambitious", desc = "Wants to climb. Follows someone stronger, leaves someone weaker." },
	honest = { name = "Honest", desc = "Won't stay with a Hunter who breaks the law." },
	scheming = { name = "Scheming", desc = "Always working an angle. Might sell the party out, once." },
}
-- pairs a person can't be at once
local CLASHING = { brave = "cautious", cautious = "reckless", kind = "cold", cheerful = "cold", honest = "scheming", loyal = "scheming" }

-- what each class does for a party (ORIGINAL numbers, tuned by tests/party_check)
local ROLE = {
	fighter = { dmg = 0.36, does = "hits hard beside you" },
	mage = { dmg = 0.4, does = "burns it down from behind you" },
	assassin = { dmg = 0.3, heads = 2, does = "finds the gaps" },
	ranger = { dmg = 0.28, heads = 2, does = "covers you from range" },
	tanker = { dmg = 0.14, absorb = 0.1, per = 0.025, does = "takes the hits meant for you" },
	healer = { dmg = 0.1, absorb = 0.12, per = 0.03, does = "keeps you standing" },
}
Party.ROLE = ROLE
local CLASS_NAMES = { fighter = "Fighter", mage = "Mage", assassin = "Assassin", tanker = "Tanker", ranger = "Ranger", healer = "Healer" }
Party.CLASS_NAMES = CLASS_NAMES
local CLASS_ORDER = { "fighter", "mage", "assassin", "tanker", "ranger", "healer" }
local CLASS_WEIGHT = { 30, 18, 14, 14, 12, 12 }
local RANK_WEIGHT = { 41, 28, 17, 9, 4.2, 0.8 } -- (the pack's awakening weights, for generated people)
-- an ally in a boss battle: Health and a blow by rank
local ALLY_HP = { 60, 90, 130, 190, 280, 420 }
local ALLY_BLOW = { 8, 12, 17, 24, 36, 55 }
Party.ALLY_HP, Party.ALLY_BLOW = ALLY_HP, ALLY_BLOW
-- a yearly retainer (million won) asked by a greedy member, or one who outranks you
local RETAINER = { 1, 2, 5, 12, 30, 90 }
-- a greedy person's fee for joining, when the roster doesn't say
local FEE = { 2, 5, 12, 30, 80, 300 }
-- the extra risk of what kind of place it is: hurt, killed
local KIND_RISK = {
	city = { 0, 0 }, ["break"] = { 0.02, 0.003 }, raid = { 0, 0 }, boss = { 0.02, 0.003 },
	red = { 0.07, 0.025 }, double = { 0.14, 0.07 }, spar = { 0, 0 },
}
-- how likely a generated person of each kind is to have awakened
local AWAKEN = { acquaintance = 0.16, friend = 0.16, mentor = 0.42, rival = 0.48, sibling = 0.1, mother = 0.05, father = 0.05, child = 0.1, partner = 0.12 }
-- the personalities each kind leans to
local KIND_TRAITS = {
	mother = { kind = 4, loyal = 4, cautious = 3, honest = 3, cheerful = 2 },
	father = { loyal = 4, cautious = 3, honest = 3, proud = 2, kind = 2 },
	sibling = { cheerful = 3, loyal = 3, reckless = 2, proud = 2, brave = 2 },
	child = { cheerful = 3, brave = 2, kind = 2 },
	friend = { cheerful = 3, loyal = 3, kind = 2, brave = 2 },
	mentor = { cautious = 3, honest = 3, kind = 2, cold = 2, proud = 2, loyal = 1 },
	rival = { proud = 4, ambitious = 4, cold = 2, scheming = 2, reckless = 2 },
	partner = { loyal = 4, kind = 3, cheerful = 2, honest = 2 },
}

-- ── small helpers ──────────────────────────────────────────────────────────
local function hashOf(key: string): number
	local h = 5381
	for i = 1, #key do
		h = (h * 33 + string.byte(key, i)) % 2147483647
	end
	if h == 0 then
		h = 1
	end
	return h
end
Party.hashOf = hashOf
-- a dice of its own from a string: n -> 1..n
local function roller(key: string): (number) -> number
	local h = hashOf(key)
	return function(n: number): number
		h = (h * 48271) % 2147483647
		return (h % math.max(1, n)) + 1
	end
end
local function chanceOf(roll: (number) -> number, p: number): boolean
	return roll(10000) <= math.floor(p * 10000)
end
local function weightedOf(roll: (number) -> number, weights: { number }): number
	local total = 0
	for _, w in weights do
		total += w
	end
	local x = (roll(1000000) - 1) / 1000000 * total
	for i, w in weights do
		x -= w
		if x < 0 then
			return i
		end
	end
	return #weights
end
local function letter(r: number?): string
	return Party.RANKS[math.clamp(math.floor(r or 1), 1, 6)]
end
Party.letter = letter
local function rankNum(v: any): number
	if type(v) == "number" then
		return math.clamp(math.floor(v), 0, 6)
	elseif type(v) == "string" then
		return RANK_INDEX[string.upper(v)] or 0
	end
	return 0
end
Party.rankNum = rankNum
local function fullName(rel: any): string
	return rel.first .. (if rel.last and rel.last ~= "" then " " .. rel.last else "")
end
Party.fullName = fullName
local function traitSet(rel: any): { [string]: boolean }
	local s = {}
	for _, t in rel.traits or {} do
		s[t] = true
	end
	return s
end
local function cfgOf(sim: any): any
	return sim.pack.party
end

function Party.enabled(sim: any): boolean
	return sim.pack.party ~= nil
end

-- ── the roster (pack.roster: a list of NPC defs) ──────────────────────────────
-- The game's named people come from two lists of the same shape: pack.roster (the game's
-- Roster.luau) and pack.party.cast (the people its own cards introduce). The roster wins
-- when both name the same id.
function Party.rosterDef(sim: any, id: any): any
	if type(id) ~= "string" then
		return nil
	end
	local idx = sim._rosterIndex
	if not idx then
		idx = {}
		local cast = (sim.pack.party and sim.pack.party.cast) or {}
		for _, list in { sim.pack.roster or {}, cast } do
			for _, d in list do
				if type(d) == "table" and type(d.id) == "string" and idx[d.id] == nil then
					idx[d.id] = d
				end
			end
		end
		sim._rosterIndex = idx
	end
	return idx[id]
end

-- an addRelation spec with a roster id: the roster says who they are (their name, and their
-- age from the Gate Year they were born in), whatever the card guessed
function Party.prepare(sim: any, life: any, spec: any): any
	if not Party.enabled(sim) or type(spec) ~= "table" or type(spec.roster) ~= "string" then
		return spec
	end
	local def = Party.rosterDef(sim, spec.roster)
	if not def then
		return spec
	end
	local out = table.clone(spec)
	if type(def.first) == "string" and def.first ~= "" then
		out.name = def.first .. (if type(def.last) == "string" and def.last ~= "" then " " .. def.last else "")
	end
	if type(def.born) == "number" then
		out.age = math.max(0, (life.year or 0) - def.born)
	end
	return out
end

-- a relation already in this life for the same roster NPC (an NPC is met once, and someone
-- who died stays gone: a card that would introduce them again changes nothing)
function Party.existing(sim: any, life: any, spec: any): any
	if not Party.enabled(sim) or type(spec) ~= "table" or type(spec.roster) ~= "string" then
		return nil
	end
	for _, rel in life.relations do
		if rel.roster == spec.roster then
			if rel.alive and type(spec.bond) == "number" then
				rel.bond = math.max(rel.bond or 0, math.min(100, spec.bond))
			end
			return rel
		end
	end
	return nil
end

-- ── a person's profile ─────────────────────────────────────────────────────
-- (have: traits they already have, topped up to n with ones that don't clash with them)
local function pickTraits(roll: (number) -> number, kind: string, n: number, have: { string }?): { string }
	local lean = KIND_TRAITS[kind] or {}
	local out = if have then table.clone(have) else {}
	local guard = 0
	while #out < n and guard < 40 do
		guard += 1
		local ws = {}
		for i, id in Party.TRAITS.order do
			ws[i] = 1 + (lean[id] or 0)
		end
		local id = Party.TRAITS.order[weightedOf(roll, ws)]
		local ok = not table.find(out, id)
		for _, have in out do
			if CLASHING[have] == id or CLASHING[id] == have then
				ok = false
			end
		end
		if ok then
			table.insert(out, id)
		end
	end
	return out
end

local function firstGateYear(sim: any): number
	local hw = sim.pack.hunterWorld
	return (hw and hw.firstYear) or 0
end

-- fills in a person's profile (once). spec: what the event or meeting said about them
function Party.ensure(sim: any, life: any, rel: any, spec: any?)
	if not Party.enabled(sim) or rel == nil or rel.prof or rel.userId ~= nil then
		return rel
	end
	spec = spec or {}
	rel.prof = 1
	local roll = roller(tostring(life.id) .. ":" .. tostring(rel.id) .. ":profile")
	local def = Party.rosterDef(sim, rel.roster or (spec :: any).roster)
	if def then
		rel.roster = def.id
		rel.rank = rankNum(def.rank)
		rel.class = if rel.rank > 0 and CLASS_NAMES[def.class or ""] then def.class else (if rel.rank > 0 then "fighter" else nil)
		rel.traits = {}
		for _, t in (def.personality or {}) do
			if Party.TRAITS[t] and #rel.traits < 4 then
				table.insert(rel.traits, t)
			end
		end
		if #rel.traits == 0 then
			rel.traits = pickTraits(roll, rel.kind, 2)
		end
		rel.work = if type(def.role) == "string" then def.role else rel.work
		rel.guild = if type(def.guild) == "string" then def.guild else nil
		rel.home = if type(def.home) == "string" then def.home else nil
	else
		local s: any = spec
		-- rank: what the meeting said, or a roll for their kind (nobody awakens before the Gates,
		-- and no child has a rank)
		local rank = 0
		if s.rank ~= nil then
			if type(s.rank) == "table" then
				local lo, hi = rankNum(s.rank[1]), rankNum(s.rank[2])
				rank = math.clamp(lo + roll(math.max(1, hi - lo + 1)) - 1, 0, 6)
			elseif s.rank == "near" then
				local mine = math.max(1, HW.playerRank(sim, life))
				rank = math.clamp(mine + roll(3) - 2, 1, 6)
			else
				rank = rankNum(s.rank)
			end
		elseif s.hunter then
			rank = weightedOf(roll, RANK_WEIGHT)
		elseif (rel.age or 0) >= 13 and (life.year or 0) >= firstGateYear(sim) and chanceOf(roll, AWAKEN[rel.kind] or 0.14) then
			rank = weightedOf(roll, RANK_WEIGHT)
		end
		if (rel.age or 0) < 12 then
			rank = 0
		end
		rel.rank = rank
		if rank > 0 then
			local c = s.class
			if c == nil or c == "any" or not CLASS_NAMES[c] then
				c = CLASS_ORDER[weightedOf(roll, CLASS_WEIGHT)]
			end
			rel.class = c
		end
		local said = {}
		if type(s.traits) == "table" then
			for _, t in s.traits do
				if Party.TRAITS[t] and not table.find(said, t) then
					table.insert(said, t)
				end
			end
		end
		-- (what the meeting said about them, and the rest of who they are)
		rel.traits = pickTraits(roll, rel.kind, math.max(2, #said), said)
		if type(s.work) == "string" then
			rel.work = s.work
		end
	end
	rel.power = rel.power or 0
	rel.revealed = rel.revealed or 0
	rel.metAt = rel.metAt or life.age
	rel.history = rel.history or {}
	return rel
end

-- something you two did, for their profile ("your history together")
function Party.note(life: any, rel: any, text: string)
	if not rel or rel.userId ~= nil then
		return
	end
	rel.history = rel.history or {}
	table.insert(rel.history, { age = life.age, text = text })
	while #rel.history > 14 do
		table.remove(rel.history, 1)
	end
end

function Party.onAdd(sim: any, life: any, rel: any, spec: any)
	if not Party.enabled(sim) or not rel then
		return
	end
	if type(spec) == "table" and type(spec.roster) == "string" then
		rel.roster = spec.roster
		-- (the flag a card can wait on: met_<npc id>)
		life.flags["met_" .. spec.roster] = true
	end
	Party.ensure(sim, life, rel, spec)
	local how = type(spec) == "table" and (spec.role or spec.text)
	if type(how) == "string" and how ~= "" then
		Party.note(life, rel, "You met: " .. sim:render(life, how) .. ".")
	end
end

-- ── what someone says (roster lines, else lines for their personality) ──────────────
function Party.line(sim: any, life: any, rel: any, kind: string, salt: string?): string?
	local def = Party.rosterDef(sim, rel.roster)
	local list: any = def and def.lines and def.lines[kind]
	if type(list) == "string" then
		list = { list }
	end
	if type(list) ~= "table" or #list == 0 then
		local pools = (cfgOf(sim).lines or {})[kind] or {}
		list = {}
		for _, t in rel.traits or {} do
			for _, l in pools[t] or {} do
				table.insert(list, l)
			end
		end
		if #list == 0 then
			list = pools.any or {}
		end
	end
	if #list == 0 then
		return nil
	end
	local roll = roller(tostring(life.id) .. ":" .. tostring(rel.id) .. ":" .. kind .. ":" .. tostring(life.age) .. ":" .. tostring(#(rel.history or {})) .. (salt or ""))
	return sim:render(life, list[roll(#list)], { rel = rel.first, relName = fullName(rel) })
end

local function say(sim: any, life: any, report: any, rel: any, kind: string, salt: string?)
	local line = Party.line(sim, life, rel, kind, salt)
	if line and report then
		sim:push(life, report, { kind = "dialogue", who = rel.first, text = line, look = rel.look, speaker = "rel" })
	end
	return line
end
Party.say = say

-- likes and dislikes: the roster's, or two and one from the pack's pools
function Party.likesOf(sim: any, life: any, rel: any): ({ string }, { string })
	local def = Party.rosterDef(sim, rel.roster)
	if def then
		local likes, dislikes = {}, {}
		for _, l in def.likes or {} do
			if type(l) == "string" then
				table.insert(likes, l)
			end
		end
		for _, l in def.dislikes or {} do
			if type(l) == "string" then
				table.insert(dislikes, l)
			end
		end
		return likes, dislikes
	end
	local cfg = cfgOf(sim)
	local roll = roller(tostring(life.id) .. ":" .. tostring(rel.id) .. ":likes")
	local pool, bad = cfg.likes or {}, cfg.dislikes or {}
	local likes, dislikes = {}, {}
	local guard = 0
	while #likes < math.min(3, #pool) and guard < 30 do
		guard += 1
		local l = pool[roll(#pool)]
		if not table.find(likes, l) then
			table.insert(likes, l)
		end
	end
	guard = 0
	while #dislikes < math.min(2, #bad) and guard < 30 do
		guard += 1
		local l = bad[roll(#bad)]
		-- (nobody can't stand the thing they love)
		if not table.find(dislikes, l) and not table.find(likes, l) then
			table.insert(dislikes, l)
		end
	end
	return likes, dislikes
end

-- does a gift answer to one of these likes? (one of a gift's `words`, as a whole word or a
-- plural of one, anywhere in the like: "tea" is in "green tea" but not in "steamed buns")
local function wordIn(hay: string, word: string): boolean
	local w = string.gsub(string.lower(word), "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
	for _, tail in { "", "s", "es" } do
		if string.find(hay, "%f[%w]" .. w .. tail .. "%f[%W]") then
			return true
		end
	end
	return false
end
Party.wordIn = wordIn
local function giftMatches(gift: any, list: { string }): string?
	for _, l in list do
		local low = string.lower(l)
		for _, w in gift.words or {} do
			if wordIn(low, w) then
				return l
			end
		end
	end
	return nil
end
Party.giftMatches = giftMatches

function Party.gift(sim: any, id: any): any
	for _, g in cfgOf(sim).gifts or {} do
		if g.id == id then
			return g
		end
	end
	return nil
end

-- what you'd give them from the People tab: the dearest thing you know they like and can pay
-- for, else something safe, else the cheapest
function Party.giftPlan(sim: any, life: any, rel: any): any
	local likes, dislikes = Party.likesOf(sim, life, rel)
	local knownL, knownD = {}, {}
	for i = 1, math.min(rel.knownLikes or 0, #likes) do
		table.insert(knownL, likes[i])
	end
	for i = 1, math.min(rel.knownDislikes or 0, #dislikes) do
		table.insert(knownD, dislikes[i])
	end
	local best, bestScore = nil, -math.huge
	for _, g in cfgOf(sim).gifts or {} do
		if (g.price or 0) <= life.money then
			local score = -(g.price or 0) * 0.01
			if giftMatches(g, knownL) then
				score += 100 + (g.price or 0) * 0.02
			elseif giftMatches(g, knownD) then
				score -= 200
			end
			if score > bestScore then
				best, bestScore = g, score
			end
		end
	end
	return best
end

-- their backstory: the roster's lines, or lines put together from who they are
function Party.backstory(sim: any, life: any, rel: any): { string }
	local def = Party.rosterDef(sim, rel.roster)
	if def and type(def.backstory) == "table" and #def.backstory > 0 then
		local out = {}
		for _, l in def.backstory do
			table.insert(out, sim:render(life, l, { rel = rel.first, relName = fullName(rel) }))
		end
		return out
	end
	local pools = cfgOf(sim).backstory or {}
	local roll = roller(tostring(life.id) .. ":" .. tostring(rel.id) .. ":story")
	local function from(list: any): string?
		if type(list) ~= "table" or #list == 0 then
			return nil
		end
		return list[roll(#list)]
	end
	local out = {}
	local function add(line: string?)
		if line then
			table.insert(out, sim:render(life, line, { rel = rel.first, relName = fullName(rel) }))
		end
	end
	local origin = pools.origin or {}
	add(from(origin[rel.kind]) or from(origin.any))
	-- the day the sky opened, by how old they were
	local bornYear = (life.year or 0) - (rel.age or 0)
	local atGates = firstGateYear(sim) - bornYear
	local gates = pools.gates or {}
	add(from(if atGates >= 18 then gates.adult elseif atGates >= 10 then gates.teen elseif atGates >= 0 then gates.child else gates.after))
	if (rel.rank or 0) > 0 then
		local aw = pools.awakened or {}
		add(from(aw[rel.class or "fighter"]) or from(aw.any))
		add(from((pools.rank or {})[letter(rel.rank)]))
	else
		add(from(pools.unawakened))
	end
	local wants = pools.want or {}
	add(from(wants[(rel.traits or {})[1] or ""]) or from(wants.any))
	local secrets = pools.secret or {}
	add(from(secrets[(rel.traits or {})[2] or ""]) or from(secrets.any))
	return out
end

-- the bond a backstory line needs (pack.party.tiers)
function Party.tierFor(sim: any, i: number): number
	local tiers = cfgOf(sim).tiers or { 10, 30, 45, 60, 75, 90 }
	return tiers[math.min(i, #tiers)] or 95
end

-- ── the party itself ───────────────────────────────────────────────────────
function Party.state(life: any): any
	local p = life.party
	if p == nil then
		p = { members = {}, fallen = 0, joined = 0, cards = {}, log = {} }
		life.party = p
	end
	p.members = p.members or {}
	p.cards = p.cards or {}
	p.log = p.log or {}
	return p
end

function Party.members(life: any): { any }
	return (life.party and life.party.members) or EMPTY
end

function Party.memberOf(life: any, relId: any): any
	for _, m in Party.members(life) do
		if m.rel == relId then
			return m
		end
	end
	return nil
end

function Party.maxOf(sim: any): number
	return (cfgOf(sim) and cfgOf(sim).max) or Party.MAX
end

local function partyLog(life: any, text: string)
	local st = Party.state(life)
	table.insert(st.log, { age = life.age, text = text })
	while #st.log > 16 do
		table.remove(st.log, 1)
	end
end
Party.partyLog = partyLog

-- the share of the take they want, and the retainer
local function termsFor(sim: any, life: any, rel: any): (number, number)
	local t = traitSet(rel)
	local mine = HW.playerRank(sim, life)
	local theirs = rel.rank or 0
	local share = 0.08
	if t.greedy then
		share += 0.07
	end
	if theirs > mine and mine > 0 then
		share += 0.04 * (theirs - mine)
	end
	if theirs == 0 then
		share = 0.04
	end
	local retainer = 0
	if theirs > 0 and (t.greedy or theirs > math.max(1, mine)) then
		retainer = RETAINER[theirs] * (if t.greedy then 1 else 0.5) * (if theirs > mine then math.max(1, theirs - mine) else 1)
	end
	return math.min(0.3, share), math.floor(retainer + 0.5)
end

-- a greedy person's fee to join (the roster's wantsPay, else by rank)
function Party.feeOf(sim: any, rel: any): number
	local def = Party.rosterDef(sim, rel.roster)
	if def and def.recruit and type(def.recruit.wantsPay) == "number" then
		return math.max(0, math.floor(def.recruit.wantsPay))
	end
	if traitSet(rel).greedy and (rel.rank or 0) > 0 then
		return FEE[rel.rank]
	end
	return 0
end

function Party.addMember(sim: any, life: any, rel: any, extra: { any }?, how: string?): any
	local st = Party.state(life)
	if Party.memberOf(life, rel.id) or #st.members >= Party.maxOf(sim) then
		return nil
	end
	Party.ensure(sim, life, rel)
	local share, retainer = termsFor(sim, life, rel)
	local t = traitSet(rel)
	local m = {
		rel = rel.id,
		joined = life.age,
		loyalty = math.clamp(math.floor(28 + (rel.bond or 0) * 0.5 + (if t.loyal then 10 else 0)), 20, 92),
		share = share,
		retainer = retainer,
		condition = "fine",
		out = 0,
		wins = 0,
		losses = 0,
		unpaid = 0,
	}
	table.insert(st.members, m)
	st.joined = (st.joined or 0) + 1
	life.flags.had_party = true
	local text = string.format("%s joined your party (%s, %s share%s).", fullName(rel), Party.rankWords(rel), tostring(math.floor(share * 100 + 0.5)) .. "%", if retainer > 0 then string.format(", %d a year", retainer) else "")
	partyLog(life, text)
	Party.note(life, rel, how or "Joined your party.")
	if extra then
		table.insert(extra, { kind = "system", tone = "good", text = text })
	end
	return m
end

-- someone leaves the party (why: a line for the log)
function Party.removeMember(sim: any, life: any, relId: any, why: string?, extra: { any }?)
	local st = Party.state(life)
	for i, m in st.members do
		if m.rel == relId then
			table.remove(st.members, i)
			local rel = sim:relationById(life, relId)
			if rel then
				rel.leftParty = life.age
				local text = why or (fullName(rel) .. " left your party.")
				partyLog(life, text)
				if rel.alive then
					Party.note(life, rel, "Left your party.")
				end
				if extra then
					table.insert(extra, { kind = "system", text = text })
				end
			end
			if st.on and st.on.ids then
				local at = table.find(st.on.ids, relId)
				if at then
					table.remove(st.on.ids, at)
				end
			end
			return true
		end
	end
	return false
end

-- a relation died (any way): out of the party
function Party.onDeath(sim: any, life: any, rel: any, extra: { any }?)
	if not Party.enabled(sim) or not life.party then
		return
	end
	if Party.memberOf(life, rel.id) then
		Party.removeMember(sim, life, rel.id, fullName(rel) .. " is gone. The party is one smaller.", nil)
	end
end

function Party.rankWords(rel: any): string
	if (rel.rank or 0) <= 0 then
		return "unawakened"
	end
	return letter(rel.rank) .. "-rank " .. (CLASS_NAMES[rel.class or ""] or "Hunter")
end

-- ── how good your name is, and how dangerous your life looks ────────────────────
function Party.fame(sim: any, life: any): number
	local gw = life.gw
	local c = gw and gw.counts or {}
	local score = (c.saved or 0) * 2 + (c.raids or 0) + (c.red or 0) * 3 + (c.double or 0) * 4 + math.floor((life.renown or 0) / 10)
	if life.career then
		score += (life.career.rank or 1) - 1
	end
	return math.clamp(score / 40, 0, 1)
end

function Party.danger(sim: any, life: any): number
	local d = 0
	if life.gw and life.gw.mode == "crisis" then
		d += 1
	end
	local st = life.party
	if st and st.lastFall and life.age - st.lastFall <= 4 then
		d += 1
	end
	if st and (st.fallen or 0) >= 2 then
		d += 1
	end
	local c = life.gw and life.gw.counts
	if c and ((c.red or 0) + (c.double or 0)) > 0 then
		d += 1
	end
	return d
end

-- ── asking someone to join: the odds, factor by factor ──────────────────────────
-- returns p (0..1), factors { { text, delta } }, and a reason it can't be asked (or nil)
function Party.odds(sim: any, life: any, rel: any): (number, { any }, string?)
	local cfg = cfgOf(sim)
	local factors = {}
	if not cfg or not rel then
		return 0, factors, "Nobody to ask."
	end
	Party.ensure(sim, life, rel)
	local function add(text: string, d: number): number
		if math.abs(d) >= 0.005 then
			table.insert(factors, { text = text, delta = math.floor(d * 100 + (if d >= 0 then 0.5 else -0.5)) / 100 })
		end
		return d
	end
	local why: string? = nil
	local st = life.party
	local n = if st then #st.members else 0
	if not rel.alive or rel.userId ~= nil then
		why = "They can't join."
	elseif Party.memberOf(life, rel.id) then
		why = "Already in your party."
	elseif n >= Party.maxOf(sim) then
		why = string.format("Your party is full (%d).", Party.maxOf(sim))
	elseif st and st.betrayer == rel.id then
		why = "Not after what they did."
	elseif (rel.age or 0) < (cfg.relMinAge or 16) then
		why = "Too young for a party."
	elseif life.age < (cfg.minAge or 16) then
		why = "You're too young to lead a party."
	elseif (rel.age or 0) >= (cfg.retireAge or 62) - 2 then
		why = "Their raiding days are over."
	end
	local t = traitSet(rel)
	local p = cfg.baseOdds or 0.3
	-- the bond (loyal people count it twice; cold ones half)
	local b = rel.bond or 0
	local bw = if t.loyal then 0.012 elseif t.cold then 0.005 else 0.008
	p += add(string.format("Your bond: %d", b), (b - 50) * bw)
	-- the ranks
	local mine, theirs = HW.playerRank(sim, life), rel.rank or 0
	if mine == 0 and theirs > 0 then
		p += add("You're unawakened: Hunters don't follow civilians into Gates", if t.loyal then -0.18 else -0.34)
	elseif mine > 0 and theirs == 0 then
		p += add("They have no rank: a Hunter's life scares them", if t.brave then -0.04 elseif t.cautious then -0.2 else -0.12)
	elseif mine > 0 and theirs > 0 then
		local d = mine - theirs
		if d > 0 then
			p += add(string.format("You outrank them (%s over %s): they'd learn from you", letter(mine), letter(theirs)), math.min(0.26, 0.08 * d) * (if t.ambitious then 1.4 else 1))
		elseif d < 0 then
			p += add(string.format("They outrank you (%s over %s)%s", letter(theirs), letter(mine), if t.proud then ": proud, they won't follow the weaker" else ""), -0.17 * -d * (if t.proud then 1.7 else 1) * (if t.ambitious then 1.2 else 1))
		end
	end
	-- you: Charisma and your name
	local cha = sim:charmOf(life)
	p += add(string.format("Your Charisma: %d", cha), (cha - 30) * 0.004)
	local fame = Party.fame(sim, life)
	if fame > 0.02 then
		p += add("Your name: the raids you've run, the lives you've saved", 0.16 * fame)
	end
	-- their personality
	local fee = Party.feeOf(sim, rel)
	if fee > 0 then
		if life.money >= fee then
			p += add(string.format("You can pay the fee they want (%d)", fee), 0.06)
		else
			p += add(string.format("They want %d %s up front; you have %d", fee, sim.pack.meta.currency, life.money), -0.24)
		end
	end
	local danger = Party.danger(sim, life)
	if t.cautious and danger > 0 then
		p += add("Cautious: your life looks dangerous to them", -0.08 * math.min(3, danger) - 0.04)
	end
	if t.brave and mine > 0 and mine >= theirs then
		p += add("Brave: they like a Hunter who goes first", 0.05)
	end
	if t.reckless then
		p += add("Reckless: a dangerous life sounds good to them", 0.05)
	end
	if t.cheerful then
		p += add("Cheerful: easy to win over", 0.06)
	end
	if t.cold then
		p += add("Cold: they keep to themselves", -0.06)
	end
	if t.kind and life.gw and (life.gw.counts.saved or 0) > 0 then
		p += add("Kind: they've heard you help people", 0.06)
	end
	if t.honest and (life.flags.rogue or life.flags.sgr_rogue or life.flags.unregistered) then
		p += add("Honest: they know what you've been doing", -0.25)
	end
	if t.scheming then
		p += add("Scheming: they see an angle in it", 0.07)
	end
	-- the roster's own say
	local def = Party.rosterDef(sim, rel.roster)
	local rec = def and def.recruit
	if rec then
		local diff = math.clamp(tonumber(rec.difficulty) or 1, 1, 5)
		if diff > 1 then
			p += add("Hard to win over", -0.07 * (diff - 1))
		end
		local need = rankNum(rec.minRank)
		if need > 0 and mine < need then
			p += add(string.format("They only follow a %s-rank or better", letter(need)), -0.6)
		end
	end
	-- the party and the timing
	if n > 0 then
		p += add(string.format("Your party already has %d", n), -0.05 * n)
	end
	if rel.refusedAt and life.age - rel.refusedAt < 2 then
		p += add("They said no not long ago", -0.12)
	end
	if (rel.age or 0) >= 50 then
		p += add("They're getting old for Gates", if (rel.age or 0) >= 55 then -0.3 else -0.14)
	end
	p = math.clamp(p, 0.02, 0.95)
	return math.floor(p * 100 + 0.5) / 100, factors, why
end

-- ask: they accept or refuse, in their own words. Returns { accepted, line, odds, name }.
function Party.ask(sim: any, life: any, rel: any, report: any): any
	local p, _factors, why = Party.odds(sim, life, rel)
	local out: any = { relId = rel.id, name = fullName(rel), odds = p, accepted = false }
	if why then
		out.line = why
		report.party = out
		sim:push(life, report, { kind = "system", text = why })
		return out
	end
	local yes = Rng.chance(life, p)
	out.accepted = yes
	local extra = {}
	if yes then
		local fee = Party.feeOf(sim, rel)
		if fee > 0 and life.money >= fee then
			life.money -= fee
			out.fee = fee
		end
		out.line = say(sim, life, report, rel, "accept")
		Party.addMember(sim, life, rel, extra, "Said yes when you asked them to join your party.")
		if out.fee then
			table.insert(extra, { kind = "system", text = string.format("You paid %s's fee: %d %s.", rel.first, out.fee, sim.pack.meta.currency) })
		end
		rel.bond = math.min(100, (rel.bond or 0) + 3)
	else
		out.line = say(sim, life, report, rel, "refuse")
		rel.refusedAt = life.age
		local t = traitSet(rel)
		local sting = if t.proud or t.cold then 3 else 1
		rel.bond = math.max(0, (rel.bond or 0) - sting)
		Party.note(life, rel, "Turned you down when you asked them to join your party.")
		table.insert(extra, { kind = "system", text = string.format("%s said no (%d%% odds).", rel.first, math.floor(p * 100 + 0.5)) })
	end
	for _, e in extra do
		sim:push(life, report, e)
	end
	report.party = out
	return out
end

-- part ways: they go, with a line (and it stings the ones who cared)
function Party.dismiss(sim: any, life: any, rel: any, report: any): boolean
	local m = Party.memberOf(life, rel.id)
	if not m then
		return false
	end
	say(sim, life, report, rel, "farewell")
	local t = traitSet(rel)
	local hurt = if t.loyal then 8 elseif t.kind then 5 elseif t.greedy or t.cold then 1 else 3
	if m.loyalty < 30 then
		hurt = 0 -- they were halfway out the door
	end
	rel.bond = math.max(0, (rel.bond or 0) - hurt)
	local extra = {}
	Party.removeMember(sim, life, rel.id, string.format("You and %s parted ways.", fullName(rel)), extra)
	for _, e in extra do
		sim:push(life, report, e)
	end
	report.party = { relId = rel.id, name = fullName(rel), dismissed = true }
	return true
end

-- ── helping in a fight ──────────────────────────────────────────────────────
-- the people with you for this clash: the party members who came (a card decides who's
-- there when it comes up, Party.onShow), or one partner (spec.party.with: a raid together)
function Party.present(sim: any, life: any, spec: any): { any }
	local out = {}
	local p = spec and spec.party
	if type(p) ~= "table" then
		return out
	end
	if p.with ~= nil then
		local rel = sim:relationById(life, p.with)
		if rel and rel.alive then
			table.insert(out, { rel = rel, m = Party.memberOf(life, rel.id) })
		end
		return out
	end
	local st = life.party
	if not st or #st.members == 0 then
		return out
	end
	local on = st.on
	for _, m in st.members do
		local rel = sim:relationById(life, m.rel)
		if rel and rel.alive and m.condition ~= "down" and (on == nil or on.ids == nil or table.find(on.ids, m.rel) ~= nil) then
			table.insert(out, { rel = rel, m = m })
		end
	end
	return out
end

-- what they add to this clash: { base, coins, heads, absorb, share, who = { ... } } or nil
function Party.support(sim: any, life: any, spec: any): any
	if not Party.enabled(sim) or type(spec) ~= "table" or type(spec.party) ~= "table" then
		return nil
	end
	local list = Party.present(sim, life, spec)
	if #list == 0 then
		return nil
	end
	local gate = math.clamp(rankNum(spec.party.rank), 1, 6)
	local fight = spec.fight == true
	local will, vital = sim.roles.will, sim.vital
	local sup: any = { base = 0, coins = 0, heads = 0, absorb = 0, share = 0, who = {}, rank = gate, kind = spec.party.kind or "raid" }
	local combat, strongest = 0, 0
	for _, e in list do
		local rel, m = e.rel, e.m
		Party.ensure(sim, life, rel)
		local t = rel.rank or 0
		local role = ROLE[rel.class or ""] or ROLE.fighter
		local hurt = m ~= nil and m.condition == "hurt"
		local cond = if hurt then 0.5 else 1
		local pow = 1 + 0.06 * (rel.power or 0)
		local does
		if fight then
			if t > 0 then
				sup.base += HW.foe(t).base * role.dmg * cond * pow
				sup.heads += (role.heads or 0) * cond
				if role.absorb then
					sup.absorb += (role.absorb + (role.per or 0) * t) * cond
				end
				if role.dmg >= 0.25 and t >= gate - 1 then
					combat += 1
				end
				strongest = math.max(strongest, t)
				does = role.does
			else
				sup.heads += 1
				does = "watches your back (no rank)"
			end
		else
			local add = 1
			if (rel.class == "healer" or rel.class == "tanker") and (spec.stat == will or spec.stat == vital) then
				add = 2
			end
			sup.base += add * cond
			does = "helps"
		end
		local share = 0
		if m then
			share = m.share or 0.08
		elseif spec.party.with ~= nil then
			share = 0.35 -- a raid together is theirs as much as yours
		end
		sup.share += share
		table.insert(sup.who, {
			id = rel.id, name = fullName(rel), first = rel.first, rank = t, rankLetter = if t > 0 then letter(t) else nil,
			class = rel.class, className = CLASS_NAMES[rel.class or ""], does = does, hurt = hurt or nil, share = share, member = m ~= nil,
		})
	end
	if fight then
		sup.base = math.min(sup.base, HW.foe(gate).base * 0.9 + 2)
		if combat >= 2 or strongest >= gate + 1 then
			sup.coins = 1
		end
		sup.heads = math.min(8, sup.heads)
		sup.absorb = math.min(0.5, sup.absorb)
	else
		sup.base = math.min(4, sup.base)
	end
	sup.base = math.floor(sup.base + 0.5)
	sup.heads = math.floor(sup.heads + 0.5)
	sup.absorb = math.floor(sup.absorb * 100 + 0.5) / 100
	sup.share = math.min(0.6, math.floor(sup.share * 100 + 0.5) / 100)
	return sup
end

-- the words on a card for who's with you ("Kang (C Tanker) takes the hits meant for you...")
function Party.supportText(sim: any, sup: any): string?
	if not sup or #sup.who == 0 then
		return nil
	end
	local names = {}
	for _, w in sup.who do
		table.insert(names, w.first .. " (" .. (if w.rankLetter then w.rankLetter .. " " .. (w.className or "Hunter") else "no rank") .. (if w.hurt then ", hurt" else "") .. ")")
	end
	local bits = {}
	if sup.base > 0 then
		table.insert(bits, "+" .. sup.base .. " power")
	end
	if sup.coins > 0 then
		table.insert(bits, "+1 coin")
	end
	if sup.heads > 0 then
		table.insert(bits, "+" .. sup.heads .. "% heads")
	end
	if sup.absorb > 0 then
		table.insert(bits, math.floor(sup.absorb * 100 + 0.5) .. "% less of what you lose")
	end
	local share = if sup.share > 0 then string.format(" Their shares: %d%% of the take.", math.floor(sup.share * 100 + 0.5)) else ""
	return string.format("With you: %s. %s.%s", table.concat(names, ", "), if #bits > 0 then table.concat(bits, ", ") else "Moral support", share)
end

-- a lose result softened by a Tanker and a Healer
function Party.absorbed(sim: any, result: any, sup: any): any
	if not sup or (sup.absorb or 0) <= 0 or type(result) ~= "table" then
		return result
	end
	return sim:scaledResult(result, 1, 1 - sup.absorb)
end

-- a win result as the chips show it: the money after their shares
function Party.netted(result: any, sup: any): any
	if not sup or (sup.share or 0) <= 0 or type(result) ~= "table" or result.money == nil then
		return result
	end
	local out = table.clone(result)
	local keep = 1 - sup.share
	local function cut(n: number): number
		return if n > 0 then math.max(0, math.floor(n * keep + 0.5)) else n
	end
	if type(out.money) == "number" then
		out.money = cut(out.money)
	elseif type(out.money) == "table" then
		out.money = { cut(out.money[1]), cut(out.money[2]) }
	end
	return out
end

-- a choice as its chips should read with the party there: the win after their shares, the
-- loss after what a Tanker and a Healer take off it (the clash itself already has their power)
function Party.displayChoice(sim: any, life: any, choice: any): any
	if type(choice) ~= "table" or type(choice.clash) ~= "table" or type(choice.clash.party) ~= "table" then
		return choice
	end
	local sup = Party.support(sim, life, choice.clash)
	if not sup then
		return choice
	end
	local out = table.clone(choice)
	out.win = Party.netted(choice.win, sup)
	out.lose = Party.absorbed(sim, choice.lose, sup)
	return out
end

-- the money a win brought in, shared out (gained: what the win paid)
function Party.payShares(sim: any, life: any, gained: number, sup: any, report: any)
	if not sup or gained <= 0 or (sup.share or 0) <= 0 then
		return
	end
	local parts, total = {}, 0
	for _, w in sup.who do
		if (w.share or 0) > 0 then
			local cut = math.floor(gained * w.share + 0.5)
			if cut > 0 then
				total += cut
				table.insert(parts, w.first .. " " .. cut)
			end
		end
	end
	if total <= 0 then
		return
	end
	total = math.min(total, math.max(0, life.money))
	life.money -= total
	sim:push(life, report, { kind = "system", text = string.format("Their shares of the take: %d %s (%s).", total, sim.pack.meta.currency, table.concat(parts, ", ")), deltas = { money = -total } })
end

-- a member is gone (killed in a fight). how: the line for it
function Party.fall(sim: any, life: any, rel: any, report: any, how: string?)
	local st = Party.state(life)
	local extra = {}
	local text = how or (fullName(rel) .. " didn't come out.")
	sim:relationDied(life, rel, extra, text)
	sim:changeSanity(life, -Rng.int(life, 3, 7), {})
	st.fallen = (st.fallen or 0) + 1
	st.lastFall = life.age
	st.fallenNames = st.fallenNames or {}
	table.insert(st.fallenNames, fullName(rel))
	while #st.fallenNames > 8 do
		table.remove(st.fallenNames, 1)
	end
	-- it shakes the others: loyalty, and their bond with you
	for _, m in st.members do
		m.loyalty = math.max(0, m.loyalty - 6)
		local other = sim:relationById(life, m.rel)
		if other then
			other.bond = math.max(0, (other.bond or 0) - 3)
		end
	end
	for _, e in extra do
		sim:push(life, report, e)
	end
	Party.queueCard(sim, life, "memorial", rel)
end

-- after a clash fought with them: who got hurt, who didn't come back, loyalty, the shares
function Party.afterClash(sim: any, life: any, spec: any, sup: any, won: boolean, report: any, approachId: string?, gained: number?)
	if not sup or not life.alive then
		return
	end
	local gate, kind = sup.rank or 1, sup.kind or "raid"
	local mine = HW.playerRank(sim, life)
	local risk = KIND_RISK[kind] or KIND_RISK.raid
	local fight = spec.fight == true
	if not won and (sup.absorb or 0) > 0 then
		local names = {}
		for _, w in sup.who do
			if w.class == "tanker" or w.class == "healer" then
				table.insert(names, w.first)
			end
		end
		if #names > 0 then
			sim:push(life, report, { kind = "system", tone = "good", text = string.format("%s took some of it for you: %d%% less than it would have been.", table.concat(names, " and "), math.floor(sup.absorb * 100 + 0.5)) })
		end
	end
	for _, w in sup.who do
		local rel = sim:relationById(life, w.id)
		if not rel or not rel.alive then
			continue
		end
		local m = Party.memberOf(life, rel.id)
		local t = rel.rank or 0
		local tr = traitSet(rel)
		local d = math.max(0, gate - t)
		local hurtP = 0.03 + 0.06 * d + (if won then 0 else 0.1) + risk[1]
		local deadP = (0.0015 + 0.022 * d ^ 1.6) * (if won then 0.35 else 1.3) + risk[2]
		if not fight then
			-- a check (a crowd, a cordon, the cold): bruises, mostly
			hurtP *= 0.4
			deadP *= 0.15
		end
		if rel.class == "tanker" then
			hurtP *= if won then 1.1 else 1.4
		elseif rel.class == "healer" then
			hurtP *= 0.7
			deadP *= 0.8
		end
		if tr.reckless then
			hurtP *= 1.3
			deadP *= 1.25
		elseif tr.cautious then
			hurtP *= 0.8
			deadP *= 0.8
		end
		if t == 0 then
			hurtP *= 1.3
			deadP *= 1.5
		end
		if (kind == "spar") then
			hurtP, deadP = 0, 0
		end
		hurtP = math.clamp(hurtP, 0, 0.75)
		deadP = math.clamp(deadP, 0, 0.4)
		if Rng.chance(life, deadP) then
			say(sim, life, report, rel, "hurt", "fall")
			Party.fall(sim, life, rel, report, string.format("%s didn't come out of it. The Association sent a letter, and the party sent flowers.", fullName(rel)))
			continue
		end
		if Rng.chance(life, hurtP) then
			local badly = Rng.chance(life, 0.25 + 0.1 * d)
			if m then
				m.condition = if badly then "down" else "hurt"
				m.out = if badly then 2 else 1
			end
			say(sim, life, report, rel, "hurt")
			local text = if badly
				then string.format("%s was badly hurt. They'll be out for a while.", rel.first)
				else string.format("%s was hurt. They'll fight at half strength until they heal.", rel.first)
			if not m then
				text = string.format("%s was hurt.", rel.first)
			end
			sim:push(life, report, { kind = "system", tone = "bad", text = text })
			Party.note(life, rel, "Hurt fighting beside you.")
		end
		if m then
			if won then
				m.wins += 1
				m.loyalty = math.min(100, m.loyalty + 3 + (if d > 0 then 2 else 0))
				rel.bond = math.min(100, (rel.bond or 0) + 2)
				Party.note(life, rel, "Won a fight beside you.")
			else
				m.losses += 1
				m.loyalty = math.max(0, m.loyalty - 4)
				Party.note(life, rel, "Lost a fight beside you.")
			end
			-- a Gate two ranks over your own, and they followed you in
			if fight and mine > 0 and gate - mine >= 2 then
				m.loyalty = math.max(0, m.loyalty - (if tr.cautious then 7 elseif tr.reckless then 0 else 2))
			end
		else
			rel.bond = math.min(100, (rel.bond or 0) + (if won then 4 else 1))
		end
	end
	-- a line from the one who did the most (now and then)
	if won and #sup.who > 0 and Rng.chance(life, 0.35) then
		local w = sup.who[Rng.int(life, 1, #sup.who)]
		local rel = sim:relationById(life, w.id)
		if rel and rel.alive then
			say(sim, life, report, rel, "battle")
		end
	end
	if won and gained and gained > 0 then
		Party.payShares(sim, life, gained, sup, report)
	end
end

-- ── a card comes up: who of your party is there ───────────────────────────────
-- A raid, a Red Gate or a Double Dungeon: everyone fit goes in with you. A Gate in the street
-- or a break: whoever was nearby (each fit member six times in ten). A party card: the
-- person it's about.
function Party.onShow(sim: any, life: any, event: any)
	if not Party.enabled(sim) then
		return
	end
	local st = life.party
	if event.partyCard then
		life.sceneRel = st and st.cards[event.id]
	end
	if not st or #st.members == 0 then
		if st then
			st.on = nil
		end
		return
	end
	local kind = nil
	for _, c in event.choices or {} do
		if type(c.clash) == "table" and type(c.clash.party) == "table" then
			kind = c.clash.party.kind or "raid"
			break
		end
	end
	if not kind then
		st.on = nil
		return
	end
	local ids = {}
	local roll = roller(tostring(life.id) .. ":" .. event.id .. ":" .. tostring(life.age) .. ":on")
	for _, m in st.members do
		if m.condition ~= "down" then
			if kind == "city" or kind == "break" then
				if chanceOf(roll, 0.6) then
					table.insert(ids, m.rel)
				end
			else
				table.insert(ids, m.rel)
			end
		end
	end
	st.on = { event = event.id, ids = ids }
end

-- after a card is answered: the people it introduces (pack.party.castMeet), its party card
-- slot, who was there
function Party.afterChoice(sim: any, life: any, event: any, index: number, report: any)
	if not Party.enabled(sim) then
		return
	end
	local st = life.party
	if st then
		st.on = nil
		if event.partyCard then
			st.cards[event.id] = nil
			life.flags["pt_on_" .. event.id] = nil
		end
	end
	local list = (cfgOf(sim).castMeet or {})[event.id]
	if not list or not life.alive then
		return
	end
	for i, spec in list do
		local choices = if type(spec.choice) == "table" then spec.choice else { spec.choice }
		local key = "met_cast_" .. event.id .. "_" .. tostring(i)
		local wonOk = not spec.won or (report and report.clash and report.clash.won == true)
		if (spec.choice == nil or table.find(choices, index) ~= nil) and wonOk and not life.flags[key] then
			life.flags[key] = true
			if spec.adopt then
				-- the card already brought someone into your life (its own addRelation): they
				-- are this person (the newest relation of that kind, met this year)
				Party.adopt(sim, life, spec)
			else
				local extra = {}
				local rel = sim:meetSomeone(life, extra, spec)
				if rel and rel.alive and spec.kind and sim.pack.relationKinds[spec.kind] then
					rel.kind = spec.kind
				end
				for _, e in extra do
					sim:push(life, report, e)
				end
			end
		end
	end
end

-- a castMeet with adopt = true: the person the card just added becomes the roster's (or gets
-- the rank, class and personality the meeting says)
function Party.adopt(sim: any, life: any, spec: any): any
	local kind = spec.kind or "friend"
	local pick = nil
	for _, rel in life.relations do
		if rel.alive and rel.kind == kind and rel.userId == nil and rel.roster == nil and (rel.metAt or -1) == life.age then
			if pick == nil or rel.id > pick.id then
				pick = rel
			end
		end
	end
	if not pick then
		return nil
	end
	local def = type(spec.roster) == "string" and Party.rosterDef(sim, spec.roster)
	if def and Party.existing(sim, life, spec) == nil then
		pick.roster = def.id
		life.flags["met_" .. def.id] = true
		pick.first = def.first or pick.first
		pick.last = def.last or pick.last
		if type(def.born) == "number" then
			pick.age = math.max(0, (life.year or 0) - def.born)
		end
	end
	if type(spec.role) == "string" then
		pick.role = sim:render(life, spec.role)
	end
	-- profile them again with what the meeting says
	pick.prof = nil
	pick.traits = nil
	Party.ensure(sim, life, pick, spec)
	return pick
end

-- a party card (pack.party.cards[kind]) about one person, queued for this year
function Party.queueCard(sim: any, life: any, kind: string, rel: any): boolean
	local cards = cfgOf(sim).cards or {}
	local id = cards[kind]
	if type(id) == "string" and kind == "betray" then
		id = id .. letter(math.max(1, rel.rank or 1))
	end
	if type(id) ~= "string" or not sim.eventsById[id] then
		return false
	end
	local st = Party.state(life)
	if st.cards[id] then
		return false
	end
	st.cards[id] = rel.id
	life.flags["pt_on_" .. id] = true
	table.insert(life.queue, id)
	return true
end

-- ── what a result does to the party (Effects: loyalty, partyLoyalty, partyLeave...) ──
function Party.effect(sim: any, life: any, result: any, target: any, extra: { any })
	if not Party.enabled(sim) then
		return
	end
	local m = target and Party.memberOf(life, target.id)
	if result.loyalty ~= nil and m then
		m.loyalty = math.clamp(m.loyalty + Rng.roll(life, result.loyalty), 0, 100)
	end
	if result.partyLoyalty ~= nil then
		for _, mm in Party.members(life) do
			mm.loyalty = math.clamp(mm.loyalty + Rng.roll(life, result.partyLoyalty), 0, 100)
		end
	end
	if type(result.partyShare) == "number" and m then
		m.share = math.clamp((m.share or 0) + result.partyShare, 0, 0.4)
	end
	-- partyPay = n: pay them what you owe (every retainer missed) and n more years of it, if
	-- you can; if you can't, it's a promise you couldn't keep
	if type(result.partyPay) == "number" and m then
		local owed = (m.retainer or 0) * ((m.unpaid or 0) + math.max(0, result.partyPay))
		if owed <= 0 then
			m.unpaid = 0
		elseif life.money >= owed then
			life.money -= owed
			m.unpaid = 0
			m.prepaid = (m.prepaid or 0) + math.max(0, math.floor(result.partyPay))
			m.loyalty = math.clamp(m.loyalty + 10, 0, 100)
			table.insert(extra, { kind = "system", tone = "good", text = string.format("You paid %s %d %s.", target.first, owed, sim.pack.meta.currency), deltas = { money = -owed } })
		else
			m.loyalty = math.clamp(m.loyalty - 8, 0, 100)
			table.insert(extra, { kind = "system", tone = "bad", text = string.format("You don't have the %d %s you owe %s. They saw you count it twice.", owed, sim.pack.meta.currency, target.first) })
		end
	end
	if result.partyJoin and type(target) == "table" and target.alive and not m then
		Party.addMember(sim, life, target, extra, "Asked to join your party, and you said yes.")
	end
	if result.partyLeave and m then
		Party.removeMember(sim, life, target.id, nil, extra)
	end
	if type(result.partyRecover) == "number" then
		local st = Party.state(life)
		local back = math.floor((st.stolen or 0) * math.clamp(result.partyRecover, 0, 1) + 0.5)
		if back > 0 then
			life.money += back
			st.stolen = 0
			table.insert(extra, { kind = "system", tone = "good", text = string.format("You got %d %s of it back.", back, sim.pack.meta.currency), deltas = { money = back } })
		end
	end
end

-- ── the interactions (pack interactions with `party = "<what>"`) ─────────────────
-- is it open, and why not: (visible, enabled, why)
function Party.gate(sim: any, life: any, rel: any, def: any): (boolean, boolean, string?)
	local kind = def.party
	if not kind or not Party.enabled(sim) then
		return true, true, nil
	end
	if rel.userId ~= nil then
		return false, false, nil
	end
	Party.ensure(sim, life, rel)
	local m = Party.memberOf(life, rel.id)
	if def.member == true and not m then
		return false, false, nil
	end
	if def.member == false and m then
		return false, false, nil
	end
	if def.hunter and HW.playerRank(sim, life) == 0 then
		return false, false, nil
	end
	if def.hunter and (rel.rank or 0) == 0 then
		return false, false, nil
	end
	if kind == "ask" then
		local _p, _f, why = Party.odds(sim, life, rel)
		if why == "Already in your party." or why == "Too young for a party." or why == "You're too young to lead a party." or why == "They can't join." then
			return false, false, nil
		end
		if why then
			return true, false, why
		end
	elseif kind == "gift" then
		if not Party.giftPlan(sim, life, rel) then
			return true, false, "You can't afford a gift"
		end
	elseif kind == "past" then
		local lines = Party.backstory(sim, life, rel)
		if (rel.revealed or 0) >= #lines then
			return true, false, "You know their whole story"
		end
	elseif kind == "raid" or kind == "spar" then
		local mm = m
		if mm and mm.condition == "down" then
			return true, false, "They're still hurt"
		end
	end
	return true, true, nil
end

-- the Gate a raid together goes into: the weaker of the two of you
local function raidRank(sim: any, life: any, rel: any): number
	local mine = HW.playerRank(sim, life)
	local theirs = math.max(1, rel.rank or 1)
	return math.clamp(math.min(math.max(1, mine), theirs), 1, 6)
end
local RAID_PAY = { { 1, 3 }, { 3, 8 }, { 8, 24 }, { 30, 90 }, { 150, 450 }, { 1500, 6000 } }
local RAID_HURT = { { -12, -5 }, { -22, -9 }, { -38, -16 }, { -64, -28 }, { -110, -50 }, { -200, -90 } }

-- the clash an interaction is fought as, for this person (spar, raid), or nil
function Party.optionFor(sim: any, life: any, rel: any, def: any): any
	local kind = def.party
	local fightStat = sim.roles.fight
	if kind == "spar" then
		local t = rel.rank or 0
		local base = if t > 0 then math.max(2, math.floor(HW.foe(t).base * 0.55 + 0.5)) else 2
		return {
			clash = { stat = fightStat, foe = rel.first, coins = if t > 0 then HW.foe(t).coins else 1, base = base, coinPower = if t > 0 then math.max(2, HW.foe(t).coinPower - 1) else 2, fixed = true },
			win = def.win,
			lose = def.lose,
		}
	elseif kind == "raid" then
		local r = raidRank(sim, life, rel)
		local foe = HW.foe(r)
		local L = letter(r)
		local win = table.clone(def.win or {})
		win.money = RAID_PAY[r]
		win.loot = { rank = r, chance = 0.3 }
		local lose = table.clone(def.lose or {})
		lose[sim.vital] = RAID_HURT[r]
		lose.cause = lose.cause or "Killed on a raid with a friend"
		local clash = {
			stat = fightStat,
			foe = "A " .. L .. "-rank Gate's monsters",
			enemy = if sim.pack.foes and sim.pack.foes["gate_" .. string.lower(L)] then "gate_" .. string.lower(L) else nil,
			coins = foe.coins,
			base = math.max(1, math.floor(foe.base * 0.72 + 0.5)),
			coinPower = foe.coinPower,
			fight = true,
			fixed = true,
			party = { rank = r, kind = "raid", with = rel.id },
		}
		return { clash = clash, win = win, lose = lose }
	end
	return nil
end

-- the words under an interaction (the odds of a yes, the gift you'd give...)
function Party.describe(sim: any, life: any, rel: any, def: any, desc: string): (string, any)
	local kind = def.party
	if kind == "ask" then
		local p, factors, why = Party.odds(sim, life, rel)
		local fee = Party.feeOf(sim, rel)
		local text = desc .. string.format(" Chance they say yes: %d%%.", math.floor(p * 100 + 0.5))
		if fee > 0 then
			text ..= string.format(" They'd want %d %s to join.", fee, sim.pack.meta.currency)
		end
		return text, { odds = p, factors = factors, why = why, fee = if fee > 0 then fee else nil }
	elseif kind == "gift" then
		local g = Party.giftPlan(sim, life, rel)
		if g then
			return desc .. string.format(" You'd give them: %s (%d %s).", g.name, g.price or 0, sim.pack.meta.currency), { gift = g.id, cost = g.price }
		end
	elseif kind == "past" then
		local lines = Party.backstory(sim, life, rel)
		local nextI = (rel.revealed or 0) + 1
		if nextI <= #lines then
			local need = Party.tierFor(sim, nextI)
			return desc .. string.format(" They've told you %d of %d things. The next needs a bond of %d.", nextI - 1, #lines, need), { need = need, told = nextI - 1, total = #lines }
		end
	elseif kind == "dismiss" then
		local m = Party.memberOf(life, rel.id)
		if m then
			return desc .. string.format(" Loyalty %d.", math.floor(m.loyalty + 0.5)), nil
		end
	elseif kind == "raid" then
		return desc .. string.format(" A %s-rank Gate: their share is 35%% of the take.", letter(raidRank(sim, life, rel))), nil
	end
	return desc, nil
end

-- learn one more thing they like (or don't)
local function reveal(sim: any, life: any, rel: any, report: any, salt: string): string?
	local likes, dislikes = Party.likesOf(sim, life, rel)
	local roll = roller(tostring(life.id) .. ":" .. tostring(rel.id) .. ":reveal:" .. salt .. ":" .. tostring(life.age))
	local pickDislike = (rel.knownDislikes or 0) < #dislikes and (roll(3) == 1 or (rel.knownLikes or 0) >= #likes)
	if pickDislike then
		rel.knownDislikes = (rel.knownDislikes or 0) + 1
		local d = dislikes[rel.knownDislikes]
		sim:push(life, report, { kind = "system", text = string.format("You learned something about %s: they can't stand %s.", rel.first, d) })
		return d
	elseif (rel.knownLikes or 0) < #likes then
		rel.knownLikes = (rel.knownLikes or 0) + 1
		local l = likes[rel.knownLikes]
		sim:push(life, report, { kind = "system", text = string.format("You learned something about %s: they love %s.", rel.first, l) })
		return l
	end
	return nil
end

-- the gains of training with them: the stats their class leans on
local function trainResult(sim: any, life: any, rel: any, def: any): any
	local result = table.clone(def.result or {})
	local t = rel.rank or 0
	local mine = HW.playerRank(sim, life)
	local gain = 1 + (if t > mine then math.min(2, t - mine) else 0) + (if rel.kind == "mentor" then 1 else 0)
	local classes = sim.pack.hunterWorld and sim.pack.hunterWorld.awakening and sim.pack.hunterWorld.awakening.classes
	local stats = nil
	for _, c in classes or {} do
		if c.id == rel.class then
			stats = c.stats
		end
	end
	local best, second, bv, sv = nil, nil, -1, -1
	for k, n in stats or {} do
		if life.stats[k] ~= nil and k ~= sim.vital then
			if n > bv then
				second, sv = best, bv
				best, bv = k, n
			elseif n > sv then
				second, sv = k, n
			end
		end
	end
	if not best then
		-- someone without a rank: you run and lift together (Speed, a little strength)
		best = if t > 0 then sim.roles.fight else (sim.roles.speed or sim.roles.fight)
		if t == 0 and sim.roles.speed and sim.roles.fight ~= best then
			second = sim.roles.fight
		end
	end
	result[best] = { gain, gain + 1 }
	if second then
		result[second] = { 0, 1 }
	end
	local logs = cfgOf(sim).trainLogs or {}
	result.log = logs[if t > 0 then (rel.class or "fighter") else "civilian"] or result.log
	return result
end

-- runs a party interaction (Sim:interact has spent the time and pushed the title; option is
-- the def with its line for this kind of person). Returns true when it handled it.
function Party.interact(sim: any, life: any, rel: any, def: any, option: any, report: any, tokens: any, approachId: string?, arg: any): boolean
	local kind = def.party
	if not kind or not Party.enabled(sim) then
		return false
	end
	Party.ensure(sim, life, rel)
	local m = Party.memberOf(life, rel.id)
	if kind == "ask" then
		Party.ask(sim, life, rel, report)
		return true
	elseif kind == "dismiss" then
		Party.dismiss(sim, life, rel, report)
		return true
	elseif kind == "gift" then
		local g = (type(arg) == "string" and Party.gift(sim, arg)) or Party.giftPlan(sim, life, rel)
		if not g or (g.price or 0) > life.money then
			sim:push(life, report, { kind = "system", text = "You can't afford that." })
			return true
		end
		life.money -= g.price or 0
		local likes, dislikes = Party.likesOf(sim, life, rel)
		local liked, disliked = giftMatches(g, likes), giftMatches(g, dislikes)
		local t = traitSet(rel)
		local result: any
		if liked then
			result = { bond = { 8, 14 }, log = string.format("You gave %s %s. Their face did something you'll remember.", rel.first, g.name) }
			local at = table.find(likes, liked)
			if at and at > (rel.knownLikes or 0) then
				-- (you know it now; the ones before it you'd have guessed anyway)
				rel.knownLikes = math.max(rel.knownLikes or 0, at)
			end
			say(sim, life, report, rel, "gift")
		elseif disliked then
			result = { bond = { -8, -4 }, log = string.format("You gave %s %s. They thanked you the way people do when they mean the opposite.", rel.first, g.name) }
			local at = table.find(dislikes, disliked)
			if at then
				rel.knownDislikes = math.max(rel.knownDislikes or 0, at)
			end
		else
			result = { bond = if t.greedy then { 4, 8 } elseif t.cold then { 1, 4 } else { 3, 6 }, log = string.format("You gave %s %s. They seemed glad of it.", rel.first, g.name) }
			if (g.price or 0) <= 0 then
				-- (something that cost you nothing but time: it counts, a little)
				result.bond = if t.kind or t.loyal then { 2, 5 } elseif t.greedy then { 0, 2 } else { 1, 3 }
			end
			if t.greedy and (g.price or 0) >= 10 then
				result.bond = { 7, 12 }
			end
		end
		result.money = nil
		sim:push(life, report, { kind = "system", text = string.format("%s: %d %s.", g.name, g.price or 0, sim.pack.meta.currency), deltas = { money = -(g.price or 0) } })
		Effects.apply(sim, life, result, report, tokens)
		if m then
			local up = if liked then 9 elseif disliked then -5 else 4
			m.loyalty = math.clamp(m.loyalty + up, 0, 100)
		end
		rel.gifts = (rel.gifts or 0) + 1
		Party.note(life, rel, string.format("You gave them %s%s.", g.name, if liked then " (they loved it)" elseif disliked then " (they didn't)" else ""))
		report.party = { relId = rel.id, name = fullName(rel), gift = g.id, liked = liked ~= nil, disliked = disliked ~= nil }
		return true
	elseif kind == "past" then
		local lines = Party.backstory(sim, life, rel)
		local nextI = (rel.revealed or 0) + 1
		if nextI > #lines then
			sim:push(life, report, { kind = "system", text = string.format("%s has told you everything there is.", rel.first) })
			return true
		end
		local need = Party.tierFor(sim, nextI)
		if (rel.bond or 0) < need then
			Effects.apply(sim, life, { bond = { 0, 1 }, log = string.format("%s changed the subject. They'll tell you more when you're closer (a bond of %d).", rel.first, need) }, report, tokens)
			report.party = { relId = rel.id, name = fullName(rel), told = false, need = need }
			return true
		end
		rel.revealed = nextI
		sim:push(life, report, { kind = "dialogue", who = rel.first, text = lines[nextI], look = rel.look, speaker = "rel" })
		Effects.apply(sim, life, { bond = { 2, 4 }, log = string.format("%s told you something they don't tell many people.", rel.first) }, report, tokens)
		Party.note(life, rel, "Told you about their past.")
		report.party = { relId = rel.id, name = fullName(rel), told = true, line = lines[nextI], index = nextI, total = #lines }
		return true
	elseif kind == "train" then
		Effects.apply(sim, life, trainResult(sim, life, rel, def), report, tokens)
		if m then
			m.loyalty = math.min(100, m.loyalty + 2)
			if Rng.chance(life, 0.12) and (rel.power or 0) < 5 then
				rel.power = (rel.power or 0) + 1
				sim:push(life, report, { kind = "system", tone = "good", text = string.format("%s got stronger training with you.", rel.first) })
			end
		end
		Party.note(life, rel, "Trained with you.")
		return true
	elseif kind == "spar" or kind == "raid" then
		local option = Party.optionFor(sim, life, rel, def)
		if not option then
			return false
		end
		sim:resolveOption(life, option, report, approachId, tokens)
		Party.note(life, rel, if kind == "spar" then "Sparred with you." else "Raided a Gate with you.")
		return true
	elseif kind == "talk" or kind == "meal" then
		sim:resolveOption(life, option or def, report, approachId, tokens)
		local roll = roller(tostring(life.id) .. ":" .. tostring(rel.id) .. ":" .. kind .. ":" .. tostring(life.age))
		if chanceOf(roll, if kind == "meal" then 0.6 else 0.4) then
			reveal(sim, life, rel, report, kind)
		end
		if chanceOf(roll, 0.35) then
			say(sim, life, report, rel, "greet", kind)
		end
		if m then
			m.loyalty = math.min(100, m.loyalty + (if kind == "meal" then 3 else 1))
		end
		Party.note(life, rel, if kind == "meal" then "Shared a meal with you." else "Talked with you.")
		return true
	end
	return false
end

-- ── a year in a party ──────────────────────────────────────────────────────
local function leaveReason(sim: any, life: any, rel: any, m: any): string?
	local t = traitSet(rel)
	if (m.unpaid or 0) >= 1 then
		return "leave_pay"
	elseif m.loyalty < 40 or (m.losses or 0) > (m.wins or 0) + 2 then
		return "leave_doubt"
	elseif t.ambitious and (rel.rank or 0) >= HW.playerRank(sim, life) then
		return "leave_offer"
	end
	return "leave_own"
end

-- people around a life awaken too, now and then (a hash, not the life's dice)
local function peopleYearly(sim: any, life: any, report: any)
	if (life.year or 0) < firstGateYear(sim) then
		return
	end
	for _, rel in life.relations do
		if rel.alive and rel.userId == nil and rel.prof and (rel.rank or 0) == 0 and (rel.age or 0) >= 13 and (rel.age or 0) <= 44 then
			local roll = roller(tostring(life.id) .. ":" .. tostring(rel.id) .. ":wake:" .. tostring(life.year))
			if chanceOf(roll, 0.006) then
				rel.rank = weightedOf(roll, RANK_WEIGHT)
				rel.class = CLASS_ORDER[weightedOf(roll, CLASS_WEIGHT)]
				Party.note(life, rel, "Awakened: " .. Party.rankWords(rel) .. ".")
				sim:push(life, report, { kind = "system", tone = "strange", text = string.format("%s awakened. The Association measured them %s-rank: a %s.", fullName(rel), letter(rel.rank), CLASS_NAMES[rel.class]) })
			end
		end
	end
end

-- the game's named people (pack.roster) come into a life on their own too: now and then you
-- meet one, most likely someone who lives in your city. (Cards introduce them as well; the
-- people a card is about, pack.party.cast, only ever come through their card.)
function Party.rosterMeet(sim: any, life: any, report: any)
	local roster = sim.pack.roster
	local cfg = cfgOf(sim)
	if type(roster) ~= "table" or #roster == 0 or life.age < (cfg.minAge or 16) then
		return
	end
	if (life.year or 0) < firstGateYear(sim) - 6 or not Rng.chance(life, cfg.rosterMeet or 0.14) then
		return
	end
	local pool, weights = {}, {}
	for _, d in roster do
		if type(d) == "table" and type(d.id) == "string" and not d.canon and not life.flags["met_" .. d.id] then
			local age = if type(d.born) == "number" then (life.year or 0) - d.born else 30
			if age >= 16 and age <= 75 and math.abs(age - life.age) <= 30 then
				table.insert(pool, d)
				table.insert(weights, if d.home ~= nil and d.home == life.district then 5 else 1)
			end
		end
	end
	if #pool == 0 then
		return
	end
	local d = pool[Rng.weighted(life, weights) or 1]
	local role = if type(d.role) == "string" and d.role ~= "" then d.role else "someone from around the city"
	if type(d.guild) == "string" and d.guild ~= "" then
		role ..= ", " .. d.guild
	end
	if d.home ~= nil and d.home == life.district then
		role ..= " (they live nearby)"
	end
	local extra = {}
	sim:meetSomeone(life, extra, { roster = d.id, role = role, bond = { 14, 26 } })
	for _, e in extra do
		sim:push(life, report, e)
	end
end

function Party.yearly(sim: any, life: any, report: any)
	if not Party.enabled(sim) or not life.alive then
		return
	end
	peopleYearly(sim, life, report)
	Party.rosterMeet(sim, life, report)
	local st = life.party
	if not st then
		return
	end
	st.on = nil
	local cfg = cfgOf(sim)
	local cardQueued = false
	-- a card from last year that never came up is let go
	for id, relId in st.cards do
		local rel = sim:relationById(life, relId)
		if not life.flags["pt_on_" .. id] or not rel then
			st.cards[id] = nil
			life.flags["pt_on_" .. id] = nil
		end
	end
	local paid = 0
	for i = #st.members, 1, -1 do
		local m = st.members[i]
		local rel = sim:relationById(life, m.rel)
		if not rel or not rel.alive then
			table.remove(st.members, i)
			continue
		end
		local t = traitSet(rel)
		-- healing
		if m.condition ~= "fine" then
			m.out = (m.out or 1) - 1
			if m.out <= 0 then
				if m.condition == "down" then
					m.condition, m.out = "hurt", 1
				else
					m.condition, m.out = "fine", 0
					sim:push(life, report, { kind = "system", tone = "good", text = string.format("%s is back on their feet.", rel.first) })
				end
			end
		end
		-- getting stronger (and, almost never, a second awakening)
		if Rng.chance(life, 0.14) and (rel.power or 0) < 5 and rel.age < 50 then
			rel.power = (rel.power or 0) + 1
			sim:push(life, report, { kind = "system", tone = "good", text = string.format("%s has been training hard: they hit harder now.", rel.first) })
		end
		if (rel.rank or 0) > 0 and rel.rank < 6 and Rng.chance(life, 0.002) then
			rel.rank += 1
			Party.note(life, rel, "Reawakened: " .. Party.rankWords(rel) .. ".")
			sim:push(life, report, { kind = "system", tone = "strange", text = string.format("%s was measured again: %s-rank now. It almost never happens.", fullName(rel), letter(rel.rank)) })
		end
		-- loyalty drifts toward what the bond says
		local target = 22 + (rel.bond or 0) * 0.6 + (if t.loyal then 12 else 0) - (if t.scheming then 10 else 0)
		m.loyalty = math.clamp(m.loyalty + math.clamp((target - m.loyalty) * 0.25, -3, 3), 0, 100)
		-- the retainer
		local due = m.retainer or 0
		if due > 0 and (m.prepaid or 0) > 0 then
			-- (paid ahead, the year they asked about it)
			m.prepaid -= 1
			m.unpaid = 0
		elseif due > 0 then
			if life.money >= due then
				life.money -= due
				paid += due
				m.unpaid = 0
			else
				m.unpaid = (m.unpaid or 0) + 1
				m.loyalty = math.max(0, m.loyalty - 14)
				sim:push(life, report, { kind = "system", tone = "bad", text = string.format("You couldn't pay %s's retainer this year (%d %s). They noticed.", rel.first, due, sim.pack.meta.currency) })
			end
		end
		-- leaving: age, loyalty, their own reasons, and (once) a betrayal
		if (rel.age or 0) >= (cfg.retireAge or 62) then
			say(sim, life, report, rel, "farewell", "retire")
			Party.removeMember(sim, life, rel.id, string.format("%s retired from the party. Their raiding days are over.", fullName(rel)), nil)
			sim:push(life, report, { kind = "system", text = string.format("%s retired. They'll still pick up when you call.", rel.first) })
		elseif m.loyalty <= 12 then
			say(sim, life, report, rel, "farewell", "quit")
			Party.removeMember(sim, life, rel.id, string.format("%s left the party without a word to anyone.", fullName(rel)), nil)
			sim:push(life, report, { kind = "system", tone = "bad", text = string.format("%s has left your party. Loyalty that low doesn't hold.", rel.first) })
			rel.bond = math.max(0, (rel.bond or 0) - 6)
		elseif not cardQueued then
			if t.scheming and not st.betrayed and m.loyalty < 60 and life.money >= 20 and Rng.chance(life, if m.loyalty < 40 then 0.2 else 0.1) then
				-- the betrayal: they're gone, and so is a share of everything
				local stolen = math.floor(life.money * (0.2 + Rng.int(life, 0, 15) / 100))
				life.money -= stolen
				st.stolen = stolen
				st.betrayed = true
				st.betrayer = rel.id
				table.remove(st.members, i)
				rel.kind = if sim.pack.relationKinds.rival then "rival" else rel.kind
				rel.bond = math.min(rel.bond or 0, 8)
				rel.leftParty = life.age
				Party.note(life, rel, string.format("Sold your party out and took %d %s with them.", stolen, sim.pack.meta.currency))
				partyLog(life, string.format("%s betrayed the party and took %d %s.", fullName(rel), stolen, sim.pack.meta.currency))
				sim:push(life, report, { kind = "system", tone = "bad", text = string.format("%s is gone, and %d %s with them.", fullName(rel), stolen, sim.pack.meta.currency), deltas = { money = -stolen } })
				cardQueued = Party.queueCard(sim, life, "betray", rel)
			else
				local p = 0.025 + (if m.loyalty < 40 then 0.07 else 0) + (if (m.unpaid or 0) >= 1 then 0.12 else 0)
				if t.ambitious and (rel.rank or 0) > HW.playerRank(sim, life) then
					p += 0.06
				end
				if t.cautious and Party.danger(sim, life) > 0 then
					p += 0.05
				end
				if (rel.age or 0) >= 50 then
					p += 0.05
				end
				if Rng.chance(life, p) then
					cardQueued = Party.queueCard(sim, life, leaveReason(sim, life, rel, m), rel)
				end
			end
		end
	end
	if paid > 0 then
		sim:push(life, report, { kind = "system", text = string.format("You paid your party's retainers: %d %s.", paid, sim.pack.meta.currency), deltas = { money = -paid } })
	end
	-- someone who heard of you asks to join (a name, a rank, room in the party)
	if not cardQueued and #st.members < Party.maxOf(sim) and HW.playerRank(sim, life) >= 2 and Party.fame(sim, life) >= 0.2 and Rng.chance(life, 0.08) then
		local pool = {}
		for _, rel in life.relations do
			if rel.alive and rel.userId == nil and not Party.memberOf(life, rel.id) and (rel.rank or 0) > 0 and rel.rank <= HW.playerRank(sim, life) and (rel.age or 0) >= 16 and (rel.age or 0) < 55 and (rel.bond or 0) >= 35 and st.betrayer ~= rel.id then
				table.insert(pool, rel)
			end
		end
		if #pool > 0 then
			Party.queueCard(sim, life, "seek", pool[Rng.int(life, 1, #pool)])
		end
	end
end

-- ── battle allies (Engine/Battle.luau) ─────────────────────────────────────────
function Party.bossRank(def: any): number
	local e = def and def.enemy
	local l = type(e) == "string" and string.match(e, "_(%a)$")
	return if l then (RANK_INDEX[string.upper(l)] or 3) else 3
end

function Party.allies(sim: any, life: any, def: any): any
	if not Party.enabled(sim) then
		return nil
	end
	local list = Party.present(sim, life, { party = { rank = Party.bossRank(def), kind = "boss" } })
	local out = {}
	for _, e in list do
		local rel, m = e.rel, e.m
		local t = rel.rank or 0
		if t > 0 then -- (nobody without a rank follows you into a boss room)
			local hurt = m and m.condition == "hurt"
			local maxHp = ALLY_HP[t]
			table.insert(out, {
				key = "ally:" .. tostring(rel.id),
				rel = rel.id,
				name = rel.first,
				rank = t,
				class = rel.class or "fighter",
				power = rel.power or 0,
				hp = math.floor(maxHp * (if hurt then 0.6 else 1)),
				maxHp = maxHp,
				down = false,
				dealt = 0,
				healed = 0,
				blocked = 0,
				hurt = hurt or nil,
			})
		end
	end
	return if #out > 0 then out else nil
end

-- the boss fight is over: what it did to each of them, and the shares
function Party.afterBattle(sim: any, life: any, b: any, outcome: string, report: any, gained: number?)
	if not Party.enabled(sim) or not b.allies then
		return
	end
	local bossRank = Party.bossRank(sim.pack.bosses and sim.pack.bosses[b.boss])
	local who = {}
	for _, a in b.allies do
		local rel = sim:relationById(life, a.rel)
		local m = rel and Party.memberOf(life, rel.id)
		if rel and rel.alive and life.alive then
			local d = math.max(0, bossRank - (rel.rank or 0))
			if a.down then
				local deadP = math.clamp(0.06 + 0.12 * d + (if outcome == "won" then 0 else 0.1), 0, 0.5)
				if Rng.chance(life, deadP) then
					Party.fall(sim, life, rel, report, string.format("%s went down in the boss room and didn't get up. The healers tried for a long time.", fullName(rel)))
					continue
				end
				if m then
					m.condition, m.out = "down", 2
				end
				sim:push(life, report, { kind = "system", tone = "bad", text = string.format("%s was carried out of the boss room. They'll be out for a while.", rel.first) })
			elseif a.hp < a.maxHp * 0.4 and Rng.chance(life, 0.5) then
				if m then
					m.condition, m.out = "hurt", 1
				end
				sim:push(life, report, { kind = "system", tone = "bad", text = string.format("%s came out hurt.", rel.first) })
			end
			if m then
				if outcome == "won" then
					m.wins += 1
					m.loyalty = math.min(100, m.loyalty + 4)
					rel.bond = math.min(100, (rel.bond or 0) + 3)
					Party.note(life, rel, "Fought a boss beside you, and won.")
				else
					m.losses += 1
					m.loyalty = math.max(0, m.loyalty - 5)
					Party.note(life, rel, "Fought a boss beside you, and lost.")
				end
				table.insert(who, { id = rel.id, first = rel.first, share = m.share or 0.08 })
			end
		end
	end
	if outcome == "won" and gained and gained > 0 and #who > 0 then
		local share = 0
		for _, w in who do
			share += w.share
		end
		Party.payShares(sim, life, gained, { who = who, share = share }, report)
	end
end

-- ── what the screens are told ────────────────────────────────────────────────
-- how to draw them as an R6 Hunter (client/UI/PartySheet builds it with Hunter/Looks)
function Party.lookOf(sim: any, life: any, rel: any): any
	local def = Party.rosterDef(sim, rel.roster)
	local presets = cfgOf(sim).presets or {}
	local preset, overrides = nil, nil
	if def and type(def.look) == "table" then
		preset = def.look.preset
		overrides = def.look.overrides
	end
	local civ = (rel.rank or 0) == 0
	if type(preset) ~= "string" then
		preset = nil
		-- what they do says what they wear (a Surveillance agent, a porter, a cook...)
		local hay = string.lower((rel.role or "") .. " " .. (rel.work or ""))
		for _, b in presets.byWords or {} do
			for _, w in b.words or {} do
				if wordIn(hay, w) then
					preset = b.preset
					break
				end
			end
			if preset then
				break
			end
		end
		if not preset and civ then
			-- everyone else without a rank: everyday clothes (a student's, if they're young)
			local list = if (rel.age or 30) < 20 and presets.young then presets.young else (presets.civilian or { "office" })
			preset = list[roller(tostring(life.id) .. ":" .. tostring(rel.id) .. ":look")(#list)]
		end
		-- (a Hunter with nothing else to go on wears their class's outfit for their rank:
		-- the client's Looks.classPreset(class, rank))
	end
	return {
		preset = preset,
		overrides = overrides,
		seed = hashOf(tostring(life.id) .. ":" .. tostring(rel.id)),
		rank = rel.rank or 0,
		class = if civ then nil else (rel.class or "fighter"),
		civilian = civ,
		age = rel.age,
	}
end

local function traitsView(rel: any): { any }
	local out = {}
	for _, t in rel.traits or {} do
		local d = Party.TRAITS[t]
		if d then
			table.insert(out, { id = t, name = d.name, desc = d.desc })
		end
	end
	return out
end

local function kindName(sim: any, rel: any): string
	local def = sim.pack.relationKinds[rel.kind] or {}
	return def.name or rel.kind
end

function Party.memberView(sim: any, life: any, m: any): any
	local rel = sim:relationById(life, m.rel)
	if not rel then
		return nil
	end
	Party.ensure(sim, life, rel)
	local t = rel.rank or 0
	return {
		relId = rel.id,
		name = fullName(rel),
		first = rel.first,
		age = rel.age,
		kindName = kindName(sim, rel),
		rank = t,
		rankLetter = if t > 0 then letter(t) else nil,
		class = rel.class,
		className = if t > 0 then CLASS_NAMES[rel.class or "fighter"] else "No rank",
		traits = traitsView(rel),
		loyalty = math.floor((m.loyalty or 0) + 0.5),
		bond = rel.bond or 0,
		condition = m.condition or "fine",
		out = m.out or 0,
		share = math.floor((m.share or 0) * 100 + 0.5),
		retainer = m.retainer or 0,
		unpaid = m.unpaid or 0,
		wins = m.wins or 0,
		losses = m.losses or 0,
		joined = m.joined,
		power = rel.power or 0,
		does = (ROLE[rel.class or ""] or ROLE.fighter).does,
		look = Party.lookOf(sim, life, rel),
		appearance = { look = rel.look, age = rel.age, form = "human" },
		line = Party.line(sim, life, rel, "greet", "view"),
		roster = rel.roster,
	}
end

function Party.candidateView(sim: any, life: any, rel: any): any
	Party.ensure(sim, life, rel)
	local p, factors, why = Party.odds(sim, life, rel)
	local t = rel.rank or 0
	return {
		relId = rel.id,
		name = fullName(rel),
		first = rel.first,
		age = rel.age,
		kindName = kindName(sim, rel),
		role = rel.role,
		rank = t,
		rankLetter = if t > 0 then letter(t) else nil,
		class = rel.class,
		className = if t > 0 then CLASS_NAMES[rel.class or "fighter"] else "No rank",
		traits = traitsView(rel),
		bond = rel.bond or 0,
		odds = p,
		factors = factors,
		why = why,
		fee = (function()
			local f = Party.feeOf(sim, rel)
			return if f > 0 then f else nil
		end)(),
		look = Party.lookOf(sim, life, rel),
		roster = rel.roster,
	}
end

-- the PARTY screen
function Party.view(sim: any, life: any): any
	if not Party.enabled(sim) then
		return nil
	end
	local st = life.party or { members = {}, log = {} }
	local mine = HW.playerRank(sim, life)
	local members = {}
	for _, m in st.members do
		local v = Party.memberView(sim, life, m)
		if v then
			table.insert(members, v)
		end
	end
	local candidates = {}
	local cfg = cfgOf(sim)
	for _, rel in life.relations do
		if rel.alive and rel.userId == nil and not Party.memberOf(life, rel.id) and (rel.age or 0) >= (cfg.relMinAge or 16) then
			table.insert(candidates, Party.candidateView(sim, life, rel))
		end
	end
	table.sort(candidates, function(a, b)
		if a.odds ~= b.odds then
			return a.odds > b.odds
		end
		return a.relId < b.relId
	end)
	local gifts = {}
	for _, g in cfg.gifts or {} do
		table.insert(gifts, { id = g.id, name = g.name, price = g.price or 0, desc = g.desc, enabled = (g.price or 0) <= life.money })
	end
	local social = life[sim:socialKey()] or 0
	local canAct, why = true, nil
	if not life.alive then
		canAct, why = false, "This life is over."
	elseif life.pending then
		canAct, why = false, "Decide what to do first."
	elseif social <= 0 then
		canAct, why = false, "No time left for people this year."
	elseif life.age < (cfg.minAge or 16) then
		canAct, why = false, string.format("You can lead a party from %d.", cfg.minAge or 16)
	end
	return {
		max = Party.maxOf(sim),
		count = #members,
		members = members,
		candidates = candidates,
		gifts = gifts,
		log = st.log or {},
		fallen = st.fallenNames or {},
		you = {
			name = life.first .. " " .. life.last,
			rank = mine,
			rankLetter = if mine > 0 then letter(mine) else nil,
			class = life.gw and life.gw.class,
			className = if mine > 0 then CLASS_NAMES[(life.gw and life.gw.class) or "fighter"] else "Unawakened",
			charisma = sim:charmOf(life),
			fame = math.floor(Party.fame(sim, life) * 100 + 0.5),
			money = life.money,
			socialLeft = social,
		},
		canAct = canAct,
		why = why,
		currency = sim.pack.meta.currency,
	}
end

-- a small summary for the life screen's PARTY button
function Party.summary(sim: any, life: any): any
	if not Party.enabled(sim) then
		return nil
	end
	local out = { count = 0, max = Party.maxOf(sim), names = {}, hurt = 0 }
	for _, m in Party.members(life) do
		local rel = sim:relationById(life, m.rel)
		if rel then
			out.count += 1
			table.insert(out.names, rel.first)
			if m.condition ~= "fine" then
				out.hurt += 1
			end
		end
	end
	return out
end

-- a person's profile screen: what you know of them
function Party.profileView(sim: any, life: any, rel: any): any
	if not Party.enabled(sim) or not rel or rel.userId ~= nil then
		return nil
	end
	Party.ensure(sim, life, rel)
	local lines = Party.backstory(sim, life, rel)
	local told = {}
	for i = 1, math.min(rel.revealed or 0, #lines) do
		table.insert(told, lines[i])
	end
	local likes, dislikes = Party.likesOf(sim, life, rel)
	local knownL, knownD = {}, {}
	for i = 1, math.min(rel.knownLikes or 0, #likes) do
		table.insert(knownL, likes[i])
	end
	for i = 1, math.min(rel.knownDislikes or 0, #dislikes) do
		table.insert(knownD, dislikes[i])
	end
	local nextI = #told + 1
	local m = Party.memberOf(life, rel.id)
	local t = rel.rank or 0
	local p, factors, why = Party.odds(sim, life, rel)
	local def = Party.rosterDef(sim, rel.roster)
	return {
		relId = rel.id,
		name = fullName(rel),
		first = rel.first,
		age = rel.age,
		alive = rel.alive,
		kindName = kindName(sim, rel),
		role = rel.role,
		work = rel.work,
		guild = rel.guild,
		rank = t,
		rankLetter = if t > 0 then letter(t) else nil,
		className = if t > 0 then CLASS_NAMES[rel.class or "fighter"] else "No rank",
		power = rel.power or 0,
		traits = traitsView(rel),
		bond = rel.bond or 0,
		likes = knownL,
		likesHidden = #likes - #knownL,
		dislikes = knownD,
		dislikesHidden = #dislikes - #knownD,
		backstory = told,
		backstoryHidden = #lines - #told,
		nextNeed = if nextI <= #lines then Party.tierFor(sim, nextI) else nil,
		history = rel.history or {},
		metAt = rel.metAt,
		inParty = m ~= nil,
		loyalty = if m then math.floor(m.loyalty + 0.5) else nil,
		condition = if m then m.condition else nil,
		odds = if not m then p else nil,
		factors = if not m then factors else nil,
		why = if not m then why else nil,
		quote = Party.line(sim, life, rel, "greet", "profile"),
		look = Party.lookOf(sim, life, rel),
		roster = rel.roster,
		canon = def ~= nil and def.canon == true or nil,
	}
end

return Party
