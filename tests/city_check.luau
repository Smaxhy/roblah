--[[
	City pack checks (the canon fan pack in src/shared/City):
	  - the pack validates, and its folder merges found no duplicate ids
	  - every era of birth starts lives in the right years
	  - every career can be joined by someone (its requirements aren't impossible)
	  - dedicated lives can climb to the top: L Corp's Branch Manager and Head of Research
	    (born in the age of the Wings), and the other ladders
	  - every chronicle act is recorded by something, and echoes into other players' lives
		lune run tests/city_check            (add a number for more climbing lives per career)
]]

local process = require("@lune/process")
local Loader = require("./loader")

local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local Rng = Engine.Rng

local failures = {}
local function check(cond, msg)
	if not cond then
		table.insert(failures, msg)
		print("  FAIL  " .. msg)
	end
end

-- ── validation ──────────────────────────────────────────────────────────────
local issues = Engine.Validate.run(pack)
for _, e in issues.errors do
	print("  error  " .. e)
end
check(#issues.errors == 0, "the City pack should validate (" .. #issues.errors .. " errors)")
local nEvents = #pack.events
local nLore = #pack.codex.entries
local nActs = 0
for _ in pack.chronicle do
	nActs += 1
end
print(string.format("City pack: %d events, %d activities, %d careers, %d lore entries, %d chronicle acts, %d expeditions, %d quests, %d traits",
	nEvents, #pack.activities, #pack.careers.order, nLore, nActs, #pack.expeditions.order, #pack.quests.order, #pack.traits.order))

-- ── eras of birth ───────────────────────────────────────────────────────────
local sim = Engine.new(pack)
for _, era in pack.calendar.eras do
	for seed = 1, 12 do
		local life = sim:newLife({ seed = seed * 13, birthEra = era.id })
		check(math.abs(life.year - era.year) <= (era.jitter or 0), string.format("era %s: born in %d", era.id, life.year))
	end
end
print("eras: every era of birth starts lives in its years")

-- ── who can join what ───────────────────────────────────────────────────────
-- the era a career needs (from requires.world.era), so a test life is an adult then
local function eraFor(def)
	local w = def.requires and def.requires.world and def.requires.world.era
	local want = if type(w) == "table" then w[1] else w
	if want == "wings" then
		return "wings"
	elseif want == "limbus" or want == "library" then
		return "after"
	end
	return "twilight"
end
local function districtFor(def)
	local d = def.requires and def.requires.district
	return if type(d) == "table" then d[1] else d
end
local function adultAt(life, age)
	-- skip childhood: age the life without events, then settle it at `age`
	life.age = age
	life.year = life.bornYear + age
	life.pending = nil
	life.queue = {}
	life.actionsLeft = 3
	sim:rollWorld(life, nil, true) -- the world (the era) as of that year
end

for _, id in pack.careers.order do
	local def = pack.careers[id]
	local joined = false
	local why = nil
	for seed = 1, 20 do
		local life = sim:newLife({ seed = seed * 101 + #id, birthEra = eraFor(def), district = districtFor(def), originId = "backstreets_family" })
		adultAt(life, math.max(def.minAge or 16, 20))
		for _, key in pack.stats.order do
			life.stats[key] = 90
		end
		life.money = 5000
		life.sanity = 20
		-- the right side of the wall
		if def.sides and not table.find(def.sides, life.side) then
			life.side = def.sides[1]
		end
		for _, f in (def.requires and def.requires.flags) or {} do
			life.flags[f] = true
		end
		if def.requires and type(def.requires.form) == "string" then
			life.form = def.requires.form
		end
		local ok, reason = sim:careerState(life, id)
		if ok then
			joined = true
			break
		end
		why = reason
	end
	check(joined, string.format("nobody can join %s (%s)", id, tostring(why)))
end
print("careers: every career can be joined by someone who meets its bar")

-- ── dedicated climbers ──────────────────────────────────────────────────────
-- a life that wants one job: trains the stat that job promotes on, rests when shaken,
-- heals when hurt, takes the safest-looking choice, and never quits
local TRAIN = { mind = { "quiet", "study" }, intelligence = { "study", "quiet" }, strength = { "train", "drill_style" }, health = { "odd_jobs", "train" } }
-- does this choice take you off the ladder you're climbing? (a job offer, quitting)
local function leavesLadder(ev, i: number, careerId: string): boolean
	local def = ev and ev.choices and ev.choices[i]
	if not def then
		return false
	end
	for _, r in { def.result, def.win, def.lose } do
		if type(r) == "table" and ((r.career and r.career ~= careerId) or r.quitCareer) then
			return true
		end
	end
	return false
end
local function safestChoice(brain, view, careerId: string?)
	local best, bestScore = nil, -math.huge
	local ev = view.pending.id and sim.eventsById[view.pending.id]
	for i, c in view.pending.choices do
		if c.enabled then
			local score = Rng.next(brain) * 0.3 + (if c.clash then c.clash.odds - 0.35 else 0.5)
			if careerId and leavesLadder(ev, i, careerId) then
				score -= 5
			end
			if score > bestScore then
				best, bestScore = i, score
			end
		end
	end
	return best
end
local function climb(careerId: string, seed: number)
	local def = pack.careers[careerId]
	local origin = if careerId == "lcorp_agent" or careerId == "lcorp_research" then "lcorp_family" else "backstreets_family"
	local life = sim:newLife({ seed = seed, originId = origin, birthEra = eraFor(def), district = districtFor(def), alloc = { [def.promoteStat or "mind"] = 5, health = 5 } })
	life.flags.enrolled = true -- a dedicated climber went to school (v0.9: "Go to class" needs it)
	if def.requires and type(def.requires.form) == "string" then
		life.form = def.requires.form -- a Bloodfiend Family only takes Bloodfiends
	end
	local brain = { rng = Rng.seed(seed * 7 + 3) }
	local best = 0
	local guard = 0
	while life.alive and guard < 800 do
		guard += 1
		if life.pending then
			local v = sim:view(life)
			local idx = safestChoice(brain, v, careerId)
			if not idx then
				break
			end
			sim:choose(life, idx, "careful")
		else
			if not life.career and sim:careerState(life, careerId) then
				sim:joinCareer(life, careerId)
			end
			if life.career and life.career.id == careerId then
				best = math.max(best, life.career.rank)
			end
			for _ = 1, 3 do
				if life.pending or life.actionsLeft <= 0 or not life.alive then
					break
				end
				local open = {}
				for _, a in sim:view(life).activities do
					if a.enabled then
						open[a.id] = true
					end
				end
				local pick = nil
				if life.stats.health < 40 and open.clinic then
					pick = "clinic"
				elseif life.sanity < -5 and open.quiet then
					pick = "quiet"
				else
					for _, a in TRAIN[def.promoteStat or "mind"] or { "study" } do
						if open[a] and not pick then
							pick = a
						end
					end
				end
				if not pick then
					break
				end
				sim:doActivity(life, pick)
			end
			if life.pending or not life.alive then
				continue
			end
			Loader.ageUp(sim, life)
			if life.career and life.career.id == careerId then
				best = math.max(best, life.career.rank)
			end
		end
	end
	return best, #def.ranks
end

local lives = tonumber(process.args[1]) or 30
print(string.format("dedicated climbers (%d lives per career): how many reach the top rank", lives))
local tops = {}
for _, id in pack.careers.order do
	local reached, sum = 0, 0
	local top = #pack.careers[id].ranks
	-- (v0.18) the two L Corp tops are checked below, and a quarter of climbers reach Head of
	-- Research: four lives was too few to be sure of seeing one, so these get at least twelve
	local n = if id == "lcorp_agent" or id == "lcorp_research" then math.max(lives, 12) else lives
	for i = 1, n do
		local best = climb(id, 5000 + i * 31)
		sum += best
		if best >= top then
			reached += 1
		end
	end
	tops[id] = reached / n
	print(string.format("  %-18s top %-24s %3d%%   mean best rank %.1f of %d", id, "(" .. pack.careers[id].ranks[top] .. ")", math.floor(reached / n * 100 + 0.5), sum / n, top))
end
check((tops.lcorp_agent or 0) > 0, "nobody born in the age of the Wings made Branch Manager at L Corp")
check((tops.lcorp_research or 0) > 0, "nobody born in the age of the Wings made Head of Research at L Corp")

-- ── Bloodfiends: the gift, Hemobars, the breaking point ─────────────────────
do
	local life = sim:newLife({ seed = 4321, originId = "backstreets_family", birthEra = "twilight" })
	adultAt(life, 25)
	local hemobar = sim.activitiesById.bf_hemobar
	local ok = sim:activityState(life, hemobar)
	check(not ok, "a human shouldn't see Hemobars")
	assert(sim:forceEvent(life, "bf_gift_offer"))
	sim:choose(life, 1) -- accept the gift
	check(life.form == "bloodfiend", "accepting the gift should make a Bloodfiend")
	check(sim:hasTrait(life, "bf_hardblood"), "Hardblood comes with the gift")
	while life.pending do
		sim:choose(life, 1)
	end
	check((sim:activityState(life, hemobar)), "a Bloodfiend should be able to drink a Hemobar")
	check(pack.forms.bloodfiend.ageless and (pack.forms.bloodfiend.lifespan or 0) > 100, "Bloodfiends age slowly")
	-- at the edge, a Bloodfiend doesn't Distort: only its own choices are open
	-- (the breaking point is a list of cards now: the first whose `when` fits the life is the
	-- one that happens, so the test asks the list the way the engine does)
	life.sanity = pack.stats.sanity.min
	local hook = pack.hooks.breakingPoint
	local edge = nil
	for _, id in (if type(hook) == "table" then hook else { hook }) do
		local ev = sim.eventsById[id]
		if ev and Engine.Conditions.check(ev.when, life, pack, { noChance = true }) then
			edge = id
			break
		end
	end
	check(edge ~= nil, "a Bloodfiend at the edge has no breaking-point card")
	-- and the human cards must not fit a Bloodfiend at all
	for _, id in { "core_breaking_point", "carmen_offer", "carmen_returns" } do
		local ev = sim.eventsById[id]
		check(ev == nil or not Engine.Conditions.check(ev.when, life, pack, { noChance = true }), "the human breaking point (" .. id .. ") fits a Bloodfiend")
	end
	assert(sim:forceEvent(life, edge or "core_breaking_point_thirst"))
	local v = sim:view(life)
	local open = 0
	for _, c in v.pending.choices do
		if c.enabled then
			open += 1
			check(c.label == "Hold on to who you were" or c.label == "Drink the Hemobar you kept for this", "a Bloodfiend shouldn't be offered '" .. c.label .. "' at the edge")
		end
	end
	check(open >= 1, "a Bloodfiend at the edge needs at least one choice it can take")
	print("bloodfiends: the gift, Hemobars and the Thirst's breaking point work")
end

-- ── build types: style traits only work with their own style ────────────────
do
	local a = sim:newLife({ seed = 99, originId = "backstreets_family", style = "tremor", traits = { "st_aftershock" } })
	local b = sim:newLife({ seed = 99, originId = "backstreets_family", style = "bleed", traits = { "st_aftershock" } })
	check(sim:fightPotency(a) == sim:fightPotency(b) + 1, "Aftershock should add Tremor potency only with the Tremor style")
	for _, p in pack.buildPresets or {} do
		check(pack.styles[p.style] ~= nil, "preset " .. p.id .. ": unknown style")
		for _, t in p.traits do
			check(pack.traits[t] and pack.traits[t].pick, "preset " .. p.id .. ": trait " .. t .. " isn't pickable")
		end
	end
	print(string.format("builds: %d presets, style traits gate on their style", #(pack.buildPresets or {})))
end

-- ── the chronicle: every act is recorded somewhere and echoes into other lives ──
local recorded, echoed = {}, {}
local function scanResult(r)
	if type(r) ~= "table" then
		return
	end
	if type(r.chronicle) == "string" then
		recorded[r.chronicle] = true
	elseif type(r.chronicle) == "table" then
		for _, a in r.chronicle do
			recorded[a] = true
		end
	end
end
local function scanChoices(choices)
	for _, c in choices or {} do
		scanResult(c.result)
		scanResult(c.win)
		scanResult(c.lose)
	end
end
local function scanWhen(w)
	if type(w) ~= "table" or w.chronicle == nil then
		return
	end
	for _, a in (if type(w.chronicle) == "table" then w.chronicle else { w.chronicle }) do
		echoed[a] = true
	end
end
for _, e in pack.events do
	scanResult(e.result)
	scanChoices(e.choices)
	scanWhen(e.when)
end
for _, a in pack.activities do
	scanResult(a.result)
	scanResult(a.win)
	scanResult(a.lose)
	scanChoices(a.choices)
	scanWhen(a.when)
end
for _, id in pack.expeditions.order do
	local ex = pack.expeditions[id]
	scanResult(ex.success)
	scanResult(ex.fail)
	for _, st in ex.stages or {} do
		scanChoices(st.choices)
	end
end
for _, id in pack.quests.order do
	local q = pack.quests[id]
	scanResult(q.reward)
	scanResult(q.result)
	for _, st in q.steps or q.stages or {} do
		scanResult(st.result)
		scanChoices(st.choices)
	end
end
local noRecord, noEcho = {}, {}
for act in pack.chronicle do
	if not recorded[act] then
		table.insert(noRecord, act)
	end
	if not echoed[act] then
		table.insert(noEcho, act)
	end
end
table.sort(noRecord)
table.sort(noEcho)
if #noRecord > 0 then
	print("  note  chronicle acts nothing records: " .. table.concat(noRecord, ", "))
end
check(#noEcho == 0, "chronicle acts with no echo in other players' lives: " .. table.concat(noEcho, ", "))
print(string.format("chronicle: %d acts, %d recorded by content, %d with echoes", nActs, nActs - #noRecord, nActs - #noEcho))

-- ── v0.7: talents, modes, Fixer grades, duels ─────────────────────────────────
do
	local sim = Engine.new(pack)
	-- talents land at their stated odds
	local odds = sim:talentOdds(nil)
	local total = 0
	for _, o in odds do
		total += o.percent
	end
	check(math.abs(total - 100) < 0.001, "talent odds should add up to 100%")
	local counts, N = {}, 200000
	local st = { rng = Rng.seed(424242) }
	for _ = 1, N do
		local id, tier = sim:rollTalent(st)
		check(id ~= nil, "a talent roll came up empty")
		counts[tier] = (counts[tier] or 0) + 1
	end
	local line = {}
	for _, o in odds do
		local got = (counts[o.id] or 0) / N * 100
		-- within 10% of the stated rate (or 0.1 points for the rarest)
		check(math.abs(got - o.percent) <= math.max(0.1, o.percent * 0.1), string.format("talent tier %s lands %.2f%% (stated %.2f%%)", o.id, got, o.percent))
		table.insert(line, string.format("%s %.2f%%", o.name, got))
	end
	print("talents: " .. #(pack.traits.order) .. " traits; " .. N .. " rolls landed " .. table.concat(line, ", "))
	-- a Rare-or-better roll never lands below Rare
	local low = 0
	for _ = 1, 20000 do
		local _, tier = sim:rollTalent(st, "rare")
		if tier == "common" or tier == "uncommon" then
			low += 1
		end
	end
	check(low == 0, "a Rare-or-better talent roll landed below Rare " .. low .. " times")

	-- sins: every sin has a talent at every rarity; leaning toward one never moves the
	-- rarity odds, and makes its talents about 3x as likely within the tier
	for _, sinId in pack.affinities.order do
		for _, tier in pack.talents.tiers do
			local has = false
			for _, tid in sim:talentPool(tier.id) do
				if pack.traits[tid].affinity == sinId then
					has = true
				end
			end
			check(has, "sin " .. sinId .. " has no " .. tier.id .. " talent")
		end
	end
	local tierCounts, sinCounts, M = {}, {}, 100000
	local st2 = { rng = Rng.seed(99173) }
	for _ = 1, M do
		local id, tier = sim:rollTalent(st2, nil, { "wrath" })
		tierCounts[tier] = (tierCounts[tier] or 0) + 1
		if pack.traits[id].affinity == "wrath" then
			sinCounts[tier] = (sinCounts[tier] or 0) + 1
		end
	end
	for _, o in odds do
		local got = (tierCounts[o.id] or 0) / M * 100
		check(math.abs(got - o.percent) <= math.max(0.12, o.percent * 0.1), string.format("leaning toward Wrath moved the %s odds to %.2f%% (stated %.2f%%)", o.id, got, o.percent))
	end
	local common = sim:talentPool("common")
	local wrathCommon = 0
	for _, tid in common do
		if pack.traits[tid].affinity == "wrath" then
			wrathCommon += 1
		end
	end
	local expected = wrathCommon * 3 / (wrathCommon * 3 + (#common - wrathCommon))
	local share = (sinCounts.common or 0) / math.max(1, tierCounts.common or 0)
	check(math.abs(share - expected) < 0.03, string.format("Wrath's share of Common talents should be about %.2f (got %.2f)", expected, share))
	print(string.format("sins: %d, each with a talent at every rarity; Wrath's Common share %.2f (no lean: %.2f)", #pack.affinities.order, share, wrathCommon / #common))

	-- every mode starts where it says
	for _, m in pack.modes do
		local life, report = sim:newLife({ seed = 777, originId = "backstreets_family", mode = m.id })
		local start = m.start or {}
		check(life.mode == m.id or not m.start, "mode " .. m.id .. " wasn't recorded on the life")
		if start.age then
			check(life.age == start.age, string.format("mode %s should start at %d (got %d)", m.id, start.age, life.age))
		end
		if start.career then
			check(life.career and life.career.id == start.career, "mode " .. m.id .. " should start in " .. start.career)
		end
		if start.form then
			check(life.form == start.form, "mode " .. m.id .. " should start as " .. start.form)
		end
		if m.era then
			local era = sim:birthEraDef(m.era)
			check(era and math.abs(life.bornYear - era.year) <= (era.jitter or 0) + 1, "mode " .. m.id .. " should be born in its era")
		end
		check(life.talent ~= nil, "a " .. m.id .. " life should be born with a talent")
		check(report and #report.entries > 0, "mode " .. m.id .. " should log its start")
	end
	print("modes: " .. #pack.modes .. " start right")

	-- Fixer grades: an Office Fixer's rank maps to a grade; a Color is 10
	local life = sim:newLife({ seed = 99, originId = "backstreets_family", mode = "fixer" })
	check(sim:fixerRating(life) == 1, "a new Grade 9 Fixer should rate 1 (got " .. sim:fixerRating(life) .. ")")
	local extra = {}
	for _ = 1, 4 do
		sim:promote(life, extra)
	end
	check(sim:fixerRating(life) == 5, "a Grade 5 Fixer should rate 5 (got " .. sim:fixerRating(life) .. ")")
	life.flags.color_fixer = true
	check(sim:fixerRating(life) == 10, "a Color should rate 10")
	local lantern = sim:lantern(life)
	check(lantern.fixerGrade == 10 and lantern.talent ~= nil, "the book should carry the grade and talent")

	-- duels: the same fight seen from both sides
	-- (v0.9: a discipline comes from who trained you, so the two are taught their schools)
	local a = sim:newLife({ seed = 5, originId = "backstreets_family", mode = "fixer" })
	local b = sim:newLife({ seed = 6, originId = "backstreets_family", mode = "fixer" })
	sim:teach(a, "zwei", {})
	sim:teach(b, "kurokumo", {})
	check(a.style == "tremor" and a.school == "zwei" and b.style == "bleed" and b.school == "kurokumo", "teaching a school should set its discipline")
	local sa, sb = sim:duelSides(a, b)
	check(sa.status and sa.status.id == "tremor" and sb.status and sb.status.id == "bleed", "duelists should fight with their styles")
	local res = Engine.Clash.resolve({ rng = Rng.seed(31) }, sa, sb)
	local twice = Engine.Sim.swapRounds(Engine.Sim.swapRounds(res.rounds))
	local same = #twice == #res.rounds
	for i, r in res.rounds do
		local t = twice[i]
		if not t or t.pPower ~= r.pPower or t.fPower ~= r.fPower or t.winner ~= r.winner or t.pCoins ~= r.pCoins then
			same = false
		end
	end
	check(same, "swapping a duel's rounds twice should give the same fight")
	local swapped = Engine.Sim.swapRounds(res.rounds)
	local last = swapped[#swapped]
	check(last and ((res.won and last.fCoins >= 0) or (not res.won)), "a swapped duel should end the same way")
	print(string.format("duels: %d rounds, both sides agree", #res.rounds))
end

if #failures > 0 then
	print(string.format("\n%d checks failed.", #failures))
	process.exit(1)
end
print("\nOK")
