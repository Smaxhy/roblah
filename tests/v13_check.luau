--[[
	v0.13, checked against the City pack:
	  - ways in found in the world start a delve straight away (no menu), and are remembered
	  - episodes: a card knows its episode and step, the chain goes on, the ending is kept
	  - turf wars: join, take, lose, collect, the raid, the map
	  - cases: open, work it clue by clue, finish it, close it
	  - feats and phases: earned at the right time; a feat or a deed can break a limit
	  - stats past 100: the cap moves with renown, feats, gear and sets
	  - the stash: an item replaced goes in it; equip back; sell
	  - sets: two pieces of a line add its bonus
	  - rivals become friends; a household becomes a marriage (and the switch turns it off)
		lune run tests/v13_check
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)

local fails = 0
local function check(ok: any, msg: string)
	if not ok then
		fails += 1
		print("  FAIL  " .. msg)
	end
end

local function settled(seed: number, age: number?)
	local life = sim:newLife({ seed = seed, rollOrigin = true })
	local guard = 0
	while life.alive and guard < 3000 do
		guard += 1
		if life.run then
			local v = sim:view(life)
			local pick = nil
			for _, c in (v.run and v.run.stage and v.run.stage.choices) or {} do
				if c.enabled ~= false then
					pick = c.index
					break
				end
			end
			if not pick or not sim:chooseExpedition(life, pick, nil) then
				life.run = nil
			end
		elseif life.pending then
			local v = sim:view(life)
			local pick = nil
			for _, c in v.pending.choices do
				if c.enabled then
					pick = c.index
					break
				end
			end
			if not pick or not sim:choose(life, pick, nil) then
				life.pending = nil
			end
		elseif life.age >= (age or 0) then
			break
		else
			-- (the City kills a life that always takes the first choice long before 24: keep
			-- it on its feet, since what's checked here is what happens to a grown life)
			life.stats.health = math.max(life.stats.health, 70)
			Loader.ageUp(sim, life)
		end
	end
	return life
end

local function survivor(seed: number, age: number)
	for n = 0, 40 do
		local life = settled(seed + n * 101, age)
		if life.alive and not life.pending and not life.run and life.age >= age then
			return life
		end
	end
	error("no life reached " .. age)
end

-- answers the open card with the choice whose label starts with `label`
local function answer(life, label: string): any
	local v = sim:view(life)
	if not v.pending then
		return nil
	end
	for _, c in v.pending.choices do
		if string.sub(c.label, 1, #label) == label then
			return sim:choose(life, c.index, nil)
		end
	end
	return nil
end

local function forceWin(life, on: boolean)
	-- (a fixed coin for the checks that need a result: Sanity tilts every coin)
	life.sanity = if on then 45 else -45
	for _, k in pack.stats.order do
		if k ~= "health" then
			life.stats[k] = if on then 100 else 1
		end
	end
	life.stats.health = math.max(life.stats.health, 90)
end

-- ── a way in, found in the world: no menu ──
do
	local life = survivor(301, 20)
	life.flags.found_dv_thirteenth_floor = nil
	sim:forceEvent(life, "ex_in_dv_thirteenth_floor")
	local v = sim:view(life)
	check(v.pending and v.pending.theme == "delve", "a way in is drawn as a descent")
	local actions = life.actionsLeft
	sim:choose(life, 1, nil)
	check(life.run ~= nil and life.run.id == "dv_thirteenth_floor", "going in starts the delve straight away")
	check(life.actionsLeft == actions, "and costs no action")
	check(life.flags.found_dv_thirteenth_floor == true, "and the place is remembered")
	local listed = false
	for _, e in sim:view(life).expeditions do
		if e.id == "dv_thirteenth_floor" and e.found then
			listed = true
		end
	end
	check(listed, "it's in Places you know")
end

-- ── an episode ──
do
	local life = survivor(302, 20)
	life.world = life.world or {}
	sim:forceEvent(life, "ep_ru_1")
	local v = sim:view(life)
	check(v.pending and v.pending.episode and v.pending.episode.id == "ep_rain_umbrellas", "an episode's card knows its episode")
	check(v.pending and v.pending.episode and v.pending.episode.step == 1 and v.pending.episode.of == 3, "and its step")
	answer(life, "Wait for the thirteenth")
	v = sim:view(life)
	check(v.pending and v.pending.episode and v.pending.episode.step == 2, "the next card follows at once")
	answer(life, "Ask who the orders")
	answer(life, "Return all thirteen")
	check(life.episodes and life.episodes.ep_rain_umbrellas ~= nil, "the ending is kept")
	local found = false
	for _, e in sim:view(life).episodes do
		if e.id == "ep_rain_umbrellas" and e.ending then
			found = true
		end
	end
	check(found, "and shown on the STORY tab")
end

-- ── turf ──
do
	local life = survivor(303, 20)
	life.side = "backstreets"
	sim:forceEvent(life, "turf_word")
	answer(life, "Step in, for yourself")
	check(life.flags.turf_in == true, "stepping into a turf war")
	local t = sim:turfView(life)
	check(t ~= nil and #t.blocks == pack.turf.count, "the District has its blocks")
	local extra = {}
	sim:turfTake(life, 2, extra)
	check(sim:turfHeld(life) == 2, "taking two blocks")
	sim:turfLose(life, 1, extra)
	check(sim:turfHeld(life) == 1, "losing one")
	local before = life.money
	life.pending = nil
	Loader.ageUp(sim, life)
	check(life.money >= before + pack.turf.income - 400, "a held block pays every year")
	-- the fight for a block is with whoever holds it
	local foe = sim:turfFoe(life)
	check(foe ~= nil and pack.foes[foe] ~= nil, "a block's fight is with its holder (" .. tostring(foe) .. ")")
	sim:turfTake(life, 10, extra)
	check(life.flags.turf_all == true, "holding every block is noticed")
end

-- ── a case ──
do
	local life = survivor(304, 22)
	life.flags.knows_fixers = true
	sim:forceEvent(life, "case_open_courier")
	answer(life, "Take the case")
	check(life.flags.case_open_case_missing_courier == true, "a case opens")
	local v = sim:view(life)
	local work = nil
	for _, a in v.activities do
		if a.id == "work_case_missing_courier" then
			work = a
		end
	end
	check(work ~= nil and string.find(work.name, "0/4", 1, true) ~= nil, "it's worked from the DO tab, with its progress")
	local extra = {}
	for _ = 1, 4 do
		sim:caseClue(life, "case_missing_courier", extra)
	end
	check(life.flags.case_ready_case_missing_courier == true, "the last clue readies the finale")
	check(table.find(life.queue, "case_courier_finale") ~= nil, "and brings it")
	life.queue = {}
	local finish = nil
	for _, a in sim:view(life).activities do
		if a.id == "finish_case_missing_courier" then
			finish = a
		end
	end
	check(finish ~= nil, "a finale that didn't happen can be gone back to")
	sim:forceEvent(life, "case_courier_finale")
	answer(life, "Return the trunk")
	check(life.flags.case_done_case_missing_courier == true and (life.tally.cases or 0) == 1, "the case closes, and counts")
end

-- ── feats, phases, caps ──
do
	local life = survivor(305, 17)
	life.pending = nil
	local report = Loader.ageUp(sim, life)
	local phase, feat = false, false
	for _, e in report.entries do
		if e.kind == "phase" and e.title == "Making a Name" then
			phase = true
		end
		if e.kind == "feat" and e.title == "Made It to Eighteen" then
			feat = true
		end
	end
	check(life.age ~= 18 or phase, "a phase card at 18")
	check(life.age ~= 18 or feat or (life.feats and life.feats.ft_eighteen), "the first feat at 18")
	check(sim:statCap(life, "strength") == 100, "stats stop at 100 to begin with")
	life.renown = pack.renown.ranks[3].at
	check(sim:statCap(life, "strength") == 105, "an Urban Myth's stats can go to 105")
	sim:applyResult(life, { limitBreak = { strength = 7 } }, Engine.Sim.newReport())
	check(sim:statCap(life, "strength") == 112, "a deed that breaks a limit raises it")
	life.renown = pack.renown.ranks[6].at
	sim:checkFeats(life, Engine.Sim.newReport())
	check(life.feats.ft_nightmare ~= nil, "a gold feat is earned when its need holds")
	check(sim:statCap(life, "speed") == 100 + 20 + 5, "and its limit break applies (" .. sim:statCap(life, "speed") .. ")")
	life.stats.strength = 100
	-- (past 90, a gain lands one time in four: very hard, never impossible)
	for _ = 1, 80 do
		sim:applyResult(life, { strength = 3 }, Engine.Sim.newReport())
		life.pending = nil
	end
	check(life.stats.strength > 100 and life.stats.strength <= sim:statCap(life, "strength"), "a stat can now grow past 100 (" .. life.stats.strength .. ")")
	check(sim:tierOf(life.stats.strength) >= 6, "and reach tier VI")
	local fv = sim:featsView(life)
	check(fv and fv.total == #pack.feats.order and fv.earned >= 2, "the feats board lists every feat")
end

-- ── the stash and sets ──
do
	local life = survivor(306, 20)
	life.gear = {}
	life.stash = {}
	local extra = {}
	sim:giveGear(life, "hv_longsword", extra)
	sim:giveGear(life, "sm_brass_knuckles", extra)
	check(life.gear.tool == "sm_brass_knuckles" and table.find(life.stash, "hv_longsword"), "what you replace goes in your stash")
	check(sim:equipGear(life, "hv_longsword") ~= nil and life.gear.tool == "hv_longsword", "equip from the stash")
	check(table.find(life.stash, "sm_brass_knuckles") ~= nil, "and what it replaced goes back in")
	local money = life.money
	check(sim:sellGear(life, "sm_brass_knuckles") ~= nil and life.money > money, "sell from the stash")
	local before = sim:statBonus(life, "strength").base
	sim:giveGear(life, "hv_duster", extra)
	local after = sim:statBonus(life, "strength").base
	check(after >= before + 1 + 2, "two pieces of the Halvard line add the set's bonus (" .. before .. " -> " .. after .. ")")
	check(#sim:view(life).sets == 1, "and the set shows")
	sim:giveGear(life, "hv_whetstone", extra)
	check(sim:statCap(life, "strength") >= 105, "all three let Strength past 100")
end

-- ── rivals and households ──
do
	local life = survivor(307, 24)
	local rival = sim:addRelation(life, { kind = "rival", name = "Odile Varga", age = 24, bond = 20 })
	sim:applyResult(life, { reconcile = true }, Engine.Sim.newReport())
	check(rival.kind == "friend" and rival.formerRival == true and life.flags.former_rival, "a rival can become a friend")
	local partner = sim:addRelation(life, { kind = "friend", name = "Ines Halloran", age = 25, bond = 90 })
	local r = Engine.Sim.newReport()
	sim:resolveOption(life, { result = { becomePartner = true } }, r, nil, { target = partner })
	check(partner.kind == "partner", "a household first")
	sim:resolveOption(life, { result = { marry = true } }, r, nil, { target = partner })
	check(partner.married == true and life.flags.married == true, "then a marriage")
	local shown = nil
	for _, rel in sim:view(life).relations do
		if rel.id == partner.id then
			shown = rel.kindName
		end
	end
	check(shown == "Spouse", "shown as a spouse (" .. tostring(shown) .. ")")
	-- the switch
	pack.marriage.on = false
	local life2 = survivor(308, 24)
	local p2 = sim:addRelation(life2, { kind = "partner", name = "Tobiah Renn", age = 25, bond = 90 })
	sim:resolveOption(life2, { result = { marry = true } }, Engine.Sim.newReport(), nil, { target = p2 })
	check(not p2.married, "with marriage switched off, a household stays a household")
	pack.marriage.on = true
end

-- ── job twists ──
do
	local life = survivor(309, 22)
	-- (v0.18) the board comes with a job: a life that never took one has no board to deal from
	if not life.career then
		local ids = {}
		for id in pack.careers do
			table.insert(ids, id)
		end
		table.sort(ids)
		for _, id in ids do
			life.actionsLeft = math.max(life.actionsLeft or 0, 1)
			if sim:joinCareer(life, id) then
				break
			end
		end
	end
	check(life.career ~= nil, "the job twists check needs a life with a job")
	local twisted = 0
	for _ = 1, 20 do
		Engine.Sim.newReport()
		Loader.ageUp(sim, life)
		life.pending = nil
		life.run = nil
		for _, j in (sim:view(life).jobs and sim:view(life).jobs.list) or {} do
			if j.twist then
				twisted += 1
			end
		end
		if not life.alive then
			break
		end
	end
	check(twisted > 0, "the jobs board deals twists")
end

-- (v0.14) cutscenes: a card with a scene carries it to the screen; an evening with someone you
-- know puts that person in the scene, with their own name and look
do
	local life = survivor(91000, 22)
	local scenes = 0
	for _, e in pack.events do
		if type(e.scene) == "table" then
			scenes += 1
			local s = sim:sceneView(life, e)
			check(s and type(s.title) == "string" and s.key, e.id .. ": its scene doesn't reach the view")
			if s and e.scene.other and (e.scene.other.name or (e.scene.other.rel and sim:firstRelation(life, e.scene.other.rel))) then
				check(s.other and (s.other.appearance or s.other.creature), e.id .. ": the person in its scene has no look")
			end
		end
	end
	check(scenes >= 18, "fewer than 18 cards have a scene")
	local rel = nil
	for _, r in life.relations do
		if (r.kind == "mother" or r.kind == "father" or r.kind == "sibling" or r.kind == "friend") and r.alive ~= false and not r.userId then
			rel = r
			break
		end
	end
	if rel then
		local got = nil
		for _ = 1, 12 do
			life.pending = nil
			life.socialLeft, life.actionsLeft = 3, 3
			rel.talked = nil
			local rep = sim:interact(life, rel.id, "spend_time")
			if rep and life.pending and sim.eventsById[life.pending] and sim.eventsById[life.pending].social then
				got = sim:view(life).pending.scene
				break
			end
			life.age += 1
		end
		check(got ~= nil, "spending time with someone never opened a scene with them in it")
		if got then
			check(got.short == true, "an evening's scene should be the short kind")
			check(got.other and got.other.name == rel.first, "the scene shows someone other than " .. tostring(rel.first))
			check(got.other and got.other.appearance and got.other.appearance.look ~= nil, "the person in the scene has no look")
		end
	else
		print("  (no family or friend in this life to spend an evening with; skipped)")
	end
end

if fails > 0 then
	print(string.format("v13_check: %d FAILED", fails))
	process.exit(1)
end
print("v13_check: OK")
