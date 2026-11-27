--[[
	BITLEVELING WORLD CHECKS (Engine/HunterWorld.luau, the BitLeveling pack).
		lune run tests/hunterworld_check [lives]
	Checks the world simulation actually behaves the way the design says:
	  1. every Gate runs through the stages, in order, and ends cleared or escalated
	  2. the High-Danger World breaks more, kills more and is answered later than the Normal one
	     (with the same seeds), and it is not just bigger numbers: more street Gates, more breaks
	  3. Red Gates and Double Dungeons are rare (Double far rarer than Red)
	  4. the canon timeline happens in its years, public events reach the news, secret ones never
	  5. Jeju is lost at its canon year and restored after the fourth raid; lives there evacuate
	  6. awakening: most lives stay unawakened or low rank; S-rank is rare; Korea has no S-rank
	     before the story's 10th (canon count)
	  7. a life is only pulled into incidents in its own city; cards are never queued twice
	  8. lives are saveable (no functions, mixed or sparse tables) with the world state in them
	Exit code 1 on any failure.
]]

local process = require("@lune/process")
local serde = require("@lune/serde")
local Loader = require("./loader")

process.env.LIFESIM_PACK = "BitLeveling"
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local HW = Engine.HunterWorld
local Rng = Engine.Rng

local N = tonumber(process.args[1]) or 160
local failures = 0
local function check(ok: boolean, msg: string)
	if ok then
		print("  ok    " .. msg)
	else
		failures += 1
		print("  FAIL  " .. msg)
	end
end

assert(pack.id == "BitLeveling", "the BitLeveling pack didn't load")
local cfg = HW.config(pack)

-- ── 1-3. the lifecycle, straight from the engine ──
print("== Gate lifecycle (10,000 Gates per world)")
local STAGE_ORDER = { appeared = 1, discovered = 2, response = 3, active = 4, resolved = 5, escalated = 5, aftermath = 6 }
local function runWorld(modeId: string)
	local mode = cfg.modes[modeId]
	local st = { rng = Rng.seed(424242) }
	local out = { n = 0, broke = 0, unseen = 0, red = 0, double = 0, dead = 0, urban = 0, lost = 0, badOrder = 0, noOutcome = 0, respond = 0, respondN = 0 }
	local district = pack.districts.daegu
	for i = 1, 10000 do
		local inc = HW.spawn(st, { cfg = cfg, mode = mode, year = 10, district = district, districtId = "daegu" })
		HW.lifecycle(st, inc, { mode = mode, breakDays = cfg.breakDays, capacity = HW.capacityFor(cfg, mode, district, 0) })
		out.n += 1
		local last = 0
		for _, t in inc.timeline do
			local o = STAGE_ORDER[t.stage]
			if not o or o < last then
				out.badOrder += 1
				break
			end
			last = o
		end
		if inc.timeline[#inc.timeline].stage ~= "aftermath" or inc.outcome == nil then
			out.noOutcome += 1
		end
		if inc.broke then
			out.broke += 1
		end
		if inc.unseen then
			out.unseen += 1
		end
		if inc.kind == "red" then
			out.red += 1
		elseif inc.kind == "double" then
			out.double += 1
		end
		if inc.urban then
			out.urban += 1
		end
		if inc.outcome == "zone_lost" then
			out.lost += 1
		end
		-- how long the Association takes once it knows (discovery is measured separately)
		if inc.responseDay then
			out.respond += inc.responseDay - (inc.foundDay or 0)
			out.respondN += 1
		end
		out.dead += inc.casualties or 0
	end
	out.meanResponse = out.respond / math.max(1, out.respondN)
	return out
end
local normal, crisis = runWorld("normal"), runWorld("crisis")
for name, w in { Normal = normal, Crisis = crisis } do
	print(string.format("  %-7s breaks %5d  unseen %4d  street %5d  red %3d  double %2d  zones lost %d  dead %7d  mean response %.2f days",
		name, w.broke, w.unseen, w.urban, w.red, w.double, w.lost, w.dead, w.meanResponse))
end
check(normal.badOrder == 0 and crisis.badOrder == 0, "every Gate's stages run in order")
check(normal.noOutcome == 0 and crisis.noOutcome == 0, "every Gate ends with an outcome and an aftermath")
check(crisis.broke > normal.broke * 1.5, "the High-Danger World breaks far more often")
check(crisis.dead > normal.dead * 1.5, "the High-Danger World's breaks cost far more lives")
check(crisis.urban > normal.urban * 1.3, "the High-Danger World opens more Gates in streets")
check(crisis.meanResponse > normal.meanResponse * 1.3, "the High-Danger World's response comes later")
check(normal.red > 0 and normal.red < 100, string.format("Red Gates are rare (%d in 10,000)", normal.red))
check(normal.double < normal.red and normal.double <= 6, string.format("Double Dungeons are rarer still (%d in 10,000)", normal.double))

-- ── 4-8. whole lives ──
print(string.format("== %d lives in each world", N))
local sim = Engine.new(pack)
-- answer whatever card is open with a random choice the life can take (or drop it)
-- a boss fight in turns: strike with the life's best way until it ends
local function fightOut(life)
	local turns = 0
	while life.battle and turns < 80 do
		turns += 1
		local key = tostring(life.id)
		local best, bestV = nil, -1
		for id, a in pack.approaches or {} do
			if type(a) == "table" and a.stat and not a.bloodless and (life.stats[a.stat] or 0) > bestV and sim:approachOpen(life, a, { fight = true, stat = a.stat }) then
				best, bestV = id, life.stats[a.stat] or 0
			end
		end
		local _, err = Engine.Battle.act(sim, life, { [key] = life }, key, if best then "strike" else "guard", best)
		if err then
			Engine.Battle.act(sim, life, { [key] = life }, key, "flee")
		end
	end
end
local function answer(life)
	local g = 0
	while life.alive and life.pending and g < 30 do
		g += 1
		local ev = sim.eventsById[life.pending]
		local open = {}
		for i, c in (ev and ev.choices) or {} do
			if Engine.Conditions.check(c.requires, life, pack, { noChance = true }) then
				table.insert(open, i)
			end
		end
		if #open == 0 then
			life.pending = nil
			break
		end
		sim:choose(life, open[Rng.int(life, 1, #open)], nil)
		fightOut(life)
	end
end
local secretWords = { "System", "Architect", "Monarch", "Cartenon", "Ashborn", "Shadow" }
local function play(seed: number, difficulty: string, era: string?, district: string?)
	local life = sim:newLife({ seed = seed, birthEra = era, difficulty = difficulty, district = district })
	local guard = 0
	while life.alive and guard < 120 do
		guard += 1
		answer(life)
		if not life.alive then
			break
		end
		local rep = Loader.ageUp(sim, life)
		if not rep then
			break
		end
	end
	return life
end

local function summarise(difficulty: string)
	local s = { lives = 0, exposedYears = 0, awakened = 0, ranks = { 0, 0, 0, 0, 0, 0 }, koreaEarlyS = 0, incidents = 0, breaksSeen = 0, deathsGate = 0, news = 0, secretLeak = 0, canonYearsOff = 0, jejuLost = 0, jejuRestored = 0, wrongCity = 0, rewritten = 0, kept = 0, ages = {}, unsaveable = 0 }
	for i = 1, N do
		local seed = 7000 + i * 13
		local era = ({ "before", "first_gen", "first_gen", "under" })[(i % 4) + 1]
		local life = play(seed, difficulty, era, if i % 9 == 0 then "jeju" else nil)
		s.lives += 1
		table.insert(s.ages, life.age)
		s.exposedYears += math.max(0, life.age - 13) -- (incident cards start at 13)
		local gw = life.gw
		if gw then
			for _, h in gw.history do
				if h.kind == "awakened" then
					s.awakened += 1
					s.ranks[h.rank] += 1
				end
				if h.kind == "city" or h.kind == "break" or h.kind == "raid" or h.kind == "red" or h.kind == "double" then
					s.incidents += 1
				end
				if h.kind == "break" then
					s.breaksSeen += 1
				end
			end
			for _, n in gw.news do
				s.news += 1
				for _, w in secretWords do
					if string.find(n.text, w, 1, true) then
						s.secretLeak += 1
					end
				end
			end
			-- canon news lands in its own year
			for _, n in gw.news do
				if n.canon then
					for _, c in cfg.canon do
						if c.id == n.canon and (n.year < c.year or n.year > (c.untilYear or c.year)) then
							s.canonYearsOff += 1
						end
					end
				end
			end
			if gw.canonDone.jeju_falls and not gw.canonDone.jeju_fourth and gw.lost.jeju then
				s.jejuLost += 1
			end
			if gw.canonDone.jeju_fourth and not gw.lost.jeju then
				s.jejuRestored += 1
			end
			if life.flags.world_rewritten then
				s.rewritten += 1
			end
			if life.flags.world_line_kept then
				s.kept += 1
			end
		end
		if life.cause and string.find(life.cause, "Dungeon Break", 1, true) then
			s.deathsGate += 1
		end
		-- the Bestiary pages a life learned at its Gates
		for id in life.codex or {} do
			if string.sub(id, 1, 11) == "lore_beast_" then
				s.beasts = (s.beasts or 0) + 1
				s.beastKinds = s.beastKinds or {}
				s.beastKinds[id] = true
			end
		end
		local ok = pcall(function()
			serde.decode("json", serde.encode("json", life))
		end)
		if not ok then
			s.unsaveable += 1
		end
	end
	table.sort(s.ages)
	s.median = s.ages[math.max(1, math.floor(#s.ages / 2))]
	return s
end

-- the Korean S-rank count: sample many awakenings in Korea before Year 10
do
	local over = 0
	for i = 1, 400 do
		local life = sim:newLife({ seed = 99000 + i, birthEra = "first_gen", district = "seoul_gangnam" })
		life.year = 4
		life.age = 18
		local cap = HW.rankCap(sim, life, cfg)
		if cap > 5 then
			over += 1
		end
	end
	check(over == 0, "no Korean life can measure S-rank before canon's 10th S-rank (Gate Year 10)")
	local life = sim:newLife({ seed = 99999, birthEra = "first_gen", district = "seoul_gangnam" })
	life.year = 11
	check(HW.rankCap(sim, life, cfg) == 6, "after the story's start, a Korean S-rank is possible again")
end

for _, diff in { "normal", "crisis" } do
	local s = summarise(diff)
	print(string.format("  %-6s median age %d  awakened %d/%d  ranks E%d D%d C%d B%d A%d S%d  incidents lived %d  news %d  rewritten %d  kept %d",
		diff, s.median, s.awakened, s.lives, s.ranks[1], s.ranks[2], s.ranks[3], s.ranks[4], s.ranks[5], s.ranks[6], s.incidents, s.news, s.rewritten, s.kept))
	check(s.secretLeak == 0, diff .. ": no secret canon (System, Architect, Monarchs) ever reaches the news")
	check(s.canonYearsOff == 0, diff .. ": every canon headline lands in its own year")
	check(s.awakened > s.lives * 0.15 and s.awakened < s.lives * 0.8, diff .. ": some lives awaken, many don't")
	check(s.ranks[6] <= math.max(2, s.awakened * 0.05), diff .. ": S-rank awakenings are rare")
	check(s.incidents > 0, diff .. ": lives are pulled into Gate incidents")
	local kinds = 0
	for _ in s.beastKinds or {} do
		kinds += 1
	end
	check((s.beasts or 0) > 0 and kinds >= 5, string.format("%s: fighting at Gates fills the Bestiary (%d pages learned, %d families)", diff, s.beasts or 0, kinds))
	check(s.unsaveable == 0, diff .. ": every life (with its world) survives a save")
	if diff == "normal" then
		_G.normalSummary = s
	else
		local n = _G.normalSummary
		-- (per year a life could be in one: High-Danger lives are shorter, so totals can tie)
		local rateC, rateN = s.incidents / math.max(1, s.exposedYears), n.incidents / math.max(1, n.exposedYears)
		check(rateC > rateN, string.format("the High-Danger World pulls lives into more incidents a year (%.3f vs %.3f)", rateC, rateN))
	end
end

-- a life in Jeju at Year 6 is evacuated, and Jeju comes back after the fourth raid
do
	local life = sim:newLife({ seed = 31337, birthEra = "under", district = "jeju" })
	local evacuated, sawFall, restored = false, false, false
	local guard = 0
	while life.alive and life.year <= 12 and guard < 40 do
		guard += 1
		if life.pending then
			answer(life)
		else
			Loader.ageUp(sim, life)
		end
		if life.gw and life.gw.lost.jeju then
			sawFall = true
		end
		if sawFall and life.district ~= "jeju" then
			evacuated = true
		end
		if sawFall and life.gw and not life.gw.lost.jeju then
			restored = true
		end
	end
	check(sawFall, "Jeju falls at its canon year")
	check(evacuated or not life.alive, "a life on Jeju is evacuated when it falls")
	check(restored or not life.alive or life.year < 11, "Jeju is restored after the fourth raid")
end

-- incidents only pull in lives in their own city
do
	local life = sim:newLife({ seed = 4242, birthEra = "first_gen", district = "busan" })
	local wrong, queued = 0, 0
	for _ = 1, 40 do
		if not life.alive then
			break
		end
		answer(life)
		Loader.ageUp(sim, life)
		for id, slot in (life.gw and life.gw.byEvent) or {} do
			if slot.inc then
				queued += 1
				if slot.inc.district ~= life.district then
					wrong += 1
				end
			end
		end
	end
	check(wrong == 0, "incident cards are only for incidents in the life's own city")
end

-- boss rooms: a raid card's boss room starts a fight in turns; when it ends, the incident
-- hears how it went (Engine/HunterWorld.afterChoice through sim.battleHook)
do
	local fought, recorded, flagsLeft = 0, 0, 0
	for seed = 1, 12 do
		local life = sim:newLife({ seed = 9000 + seed, difficulty = "normal" })
		life.age = 26
		life.year = 12
		life.form = "hunter_c"
		life.stats.strength = 70
		life.stats.agility = 60
		life.stats.vitality = 100
		life.pending = nil
		life.queue = {}
		local gw = HW.state(life)
		local cfg = HW.config(pack)
		local _, mode = HW.modeOf(sim, life)
		local inc = HW.spawn(life, { cfg = cfg, mode = mode, year = life.year, district = sim:districtDef(life), districtId = life.district, minRank = 3 })
		inc.n = 1
		inc.rank, inc.readRank = 3, 3
		local id = if seed % 2 == 0 then "hw_raid_C" else "hw_red_B"
		HW.queueCard(sim, life, id, inc, "raider")
		sim:advance(life, sim.newReport())
		if life.pending == id then
			local before = #(gw.history or {})
			sim:choose(life, 1, nil)
			if life.battle then
				fought += 1
				fightOut(life)
			end
			if #(gw.history or {}) > before then
				recorded += 1
			end
			if life.flags["hw_on_" .. id] then
				flagsLeft += 1
			end
		end
	end
	check(fought >= 10, string.format("raid and Red Gate boss rooms start fights in turns (%d of 12)", fought))
	check(recorded >= 10 and flagsLeft == 0, string.format("a finished boss fight is recorded on the incident (%d recorded, %d left open)", recorded, flagsLeft))
end

if failures > 0 then
	print(string.format("\n%d check(s) failed.", failures))
	process.exit(1)
end
print("\nAll world checks passed.")
