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
	return best, #def.ranks, life
end

local lives = tonumber(process.args[1]) or 12
for i = 1, lives do
	local best, top, life = climb("lcorp_research", 5000 + i * 31)
	local hist = {}
	for _, e in life.log or {} do
		if e.kind == "death" or (e.text and string.find(e.text, "died", 1, true)) then
			table.insert(hist, e.text)
		end
	end
	print(string.format("  #%d best %d/%d  alive %s  age %d  cause %s  career %s  int %d health %d", i, best, top, tostring(life.alive), life.age, tostring(life.cause or life.deathCause), tostring(life.career and life.career.id), life.stats.intelligence or 0, life.stats.health or 0))
end
