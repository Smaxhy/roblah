--[[
	v0.11 systems, checked against the City pack:
	  - fighting by stat: every fight offers the stat stances, with a temper and its matchup
	  - Talk down is only offered against people
	  - tier perks: more Speed is more to do in a year, more Charisma more time for people
	  - nature: the highest stat, with its +1
	  - jobs: a life with a career has a board, a job costs an action, and done jobs make the
	    next promotion certain
	  - scenes with people: "spend time" opens a scene, and its bond lands on that person
	  - second stories: a grown life between stories is found by another
	  - cutscenes: the turning points go out as their own kind of entry
		lune run tests/v11_check
]]
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

-- a grown life to test on
local function grown(seed: number)
	local life = sim:newLife({ seed = seed, rollOrigin = true, mode = "fixer" })
	local guard = 0
	while life.pending and guard < 40 do
		guard += 1
		local v = sim:view(life)
		local pick = nil
		for i, c in v.pending.choices do
			if c.enabled then
				pick = i
				break
			end
		end
		if not pick or not sim:choose(life, pick, nil) then
			life.pending = nil
		end
	end
	return life
end

-- ── fighting by stat ──
do
	local life = grown(11)
	life.stats.strength, life.stats.speed, life.stats.intelligence, life.stats.charisma = 40, 40, 40, 40
	local person = { stat = "strength", foe = "A Rat", enemy = "rat", fight = true, coins = 2, base = 4, coinPower = 2, fixed = true }
	local beast = { stat = "strength", foe = "A stray beast", enemy = "beast", fight = true, coins = 1, base = 2, coinPower = 2, fixed = true }
	local pv = sim:clashPreview(life, person)
	local ids = {}
	for _, a in pv.approaches do
		ids[a.id] = a
	end
	check(ids.power and ids.speed and ids.wits, "a fight offers Overpower, Outpace and Outthink")
	check(ids.talk ~= nil, "Talk down is offered against a person")
	check(ids.steady == nil and ids.reckless == nil and ids.careful == nil, "Steady / Reckless / Careful are gone")
	check(pv.temper ~= nil and pv.temper.weakTo ~= nil, "a fight says the foe's temper and what beats it")
	check(pv.bestOdds ~= nil and pv.best ~= nil, "a fight says your best way in")
	local weak, strong = ids[pv.temper.weakTo], ids[pv.temper.strongTo]
	check(weak and weak.edge == "advantage", "the way the temper is weak to has the advantage")
	check(strong and strong.edge == "resisted", "the way the temper shrugs off is resisted")
	check(weak and strong and weak.odds > strong.odds, "with equal stats, the advantage has better odds than the resisted way")
	local bv = sim:clashPreview(life, beast)
	local talk = false
	for _, a in bv.approaches do
		if a.id == "talk" then
			talk = true
		end
	end
	check(not talk, "Talk down is not offered against a creature")
	-- the stat you fight with is the one that counts
	life.stats.strength, life.stats.intelligence = 10, 90
	local p2 = sim:clashPreview(life, { stat = "strength", foe = "Someone", fight = true, coins = 2, base = 4, coinPower = 2, fixed = true })
	local byId = {}
	for _, a in p2.approaches do
		byId[a.id] = a
	end
	check(byId.wits.base > byId.power.base, "Outthink fights with Intelligence, Overpower with Strength")
	-- a check that isn't a fight has no stances
	local cv = sim:clashPreview(life, { stat = "charisma", foe = "A clerk", coins = 1, base = 2, coinPower = 2, fixed = true })
	check(#(cv.approaches or {}) == 0, "a plain check offers no ways of fighting")
end

-- ── tiers, perks, nature ──
do
	local life = grown(12)
	for _, k in pack.stats.order do
		life.stats[k] = 10
	end
	local base = sim:actionsPerYear(life)
	local people = sim:socialPerYear(life)
	check(base == pack.meta.actionsPerYear, "no perks at the bottom of every stat")
	check(sim:nature(life) == nil, "no nature until a stat is worth leaning on")
	life.stats.speed = 45
	check(sim:actionsPerYear(life) == base + 1, "Speed 40 is one more thing to do a year")
	life.stats.speed = 85
	check(sim:actionsPerYear(life) == base + 2, "Speed 80 is two more")
	life.stats.charisma = 45
	check(sim:socialPerYear(life) == people + 1, "Charisma 40 is one more time for people a year")
	check(sim:nature(life) == "speed", "your nature is your highest stat")
	local v = sim:view(life)
	check(v.nature and v.nature.stat == "speed" and v.nature.name ~= nil, "the view names your nature")
	check(v.perks and v.perks.speed and #v.perks.speed.have == 2, "the view lists the perks you have")
	check(v.perks.charisma.next ~= nil, "and the next one coming")
	life.stats.mind = 10
	local before = life.sanity
	sim:changeSanity(life, -20, {})
	local lostLow = before - life.sanity
	life.sanity = before
	life.stats.mind = 65
	sim:changeSanity(life, -20, {})
	check(before - life.sanity < lostLow, "a strong mind loses less Sanity")
end

-- ── jobs ──
do
	local life = grown(13)
	check(life.career ~= nil, "the Fixer mode starts with a career")
	Loader.ageUp(sim, life)
	local guard = 0
	while life.pending and guard < 40 do
		guard += 1
		local v = sim:view(life)
		local pick = nil
		for i, c in v.pending.choices do
			if c.enabled then
				pick = i
				break
			end
		end
		if not pick or not sim:choose(life, pick, nil) then
			life.pending = nil
		end
	end
	if life.alive and life.career then
		local v = sim:view(life)
		check(v.jobs ~= nil and #v.jobs.list == pack.jobs.perYear, "a life with a career has a jobs board")
		check(v.career.nextRank ~= nil and v.career.jobsNeed == pack.jobs.perRank, "the view says what the next rank waits on")
		local left = life.actionsLeft
		for _, k in pack.stats.order do
			life.stats[k] = 95 -- a sure thing
		end
		life.sanity = 30
		local job = v.jobs.list[1]
		local report = sim:doJob(life, job.index, job.clash.best)
		check(report ~= nil, "a job can be done")
		check(life.actionsLeft == left - 1, "a job costs an action")
		local again = sim:doJob(life, job.index, nil)
		check(again == nil, "a job can't be done twice in a year")
		check((life.career.jobs or 0) >= 1 or (report and report.clash and not report.clash.won), "a job done well counts toward the next rank")
	end
end

-- ── scenes with people ──
do
	local found = false
	for seed = 21, 60 do
		local life = sim:newLife({ seed = seed, rollOrigin = true })
		local mother = nil
		for _, rel in life.relations do
			if rel.kind == "mother" and rel.alive then
				mother = rel
			end
		end
		if mother then
			life.age = 8
			life.pending = nil
			life.queue = {}
			life.socialLeft = 3
			local bond = mother.bond
			local report = sim:interact(life, mother.id, "spend_time", nil)
			if report and life.pending then
				found = true
				local ev = sim.eventsById[life.pending]
				check(ev.social ~= nil, "spending time opens a scene with that person")
				local v = sim:view(life)
				check(string.find(v.pending.text, mother.first, 1, true) ~= nil, "the scene's words use their name")
				check(v.pending.thread and v.pending.thread.kind == "people", "the scene belongs to the people thread")
				sim:choose(life, 1, nil)
				check(mother.bond > bond, "what you chose in the scene lands on that person's bond")
				check(life.sceneRel == nil, "the scene is over once you've chosen")
				break
			end
		end
	end
	check(found, "a life with a mother can spend time with her and get a scene")
end

-- ── second stories ──
do
	local began = 0
	for seed = 31, 50 do
		local life = grown(seed)
		for _ = 1, 12 do
			if not life.alive then
				break
			end
			Loader.ageUp(sim, life)
			local guard = 0
			while life.pending and guard < 40 do
				guard += 1
				local v = sim:view(life)
				local pick = nil
				for i, c in v.pending.choices do
					if c.enabled and not (c.clash and (c.clash.bestOdds or c.clash.odds) < 0.3) then
						pick = i
						break
					end
				end
				pick = pick or 1
				if not sim:choose(life, pick, nil) then
					life.pending = nil
				end
			end
			life.stats.health = math.max(life.stats.health, 60)
		end
		local def = life.story and sim.storylinesById[life.story]
		if def and (def.act or 1) >= 2 then
			began += 1
			local v = sim:view(life)
			check(v.story and v.story.chapters and #v.story.chapters == 5, "a second story has five chapters on its timeline")
			-- its people, with faces (the Story tab's WHO'S IN IT)
			local cast = v.story and v.story.cast
			check(type(cast) == "table" and #cast >= 1 and #cast <= 5, def.id .. ": a second story shows one to five people")
			for _, person in cast or {} do
				check(type(person.name) == "string" and person.name ~= "" and type(person.look) == "table", def.id .. ": everyone in the cast has a name and a face")
				check(type(person.line) == "string" and person.line ~= "", def.id .. ": " .. tostring(person.name) .. " has a line under the name")
			end
		end
	end
	check(began >= 10, "most grown lives between stories are found by another within twelve years (" .. began .. " of 20)")
	-- every story that finds you later names its people, and there are enough of them that
	-- two lives rarely get the same ones
	local second, open = 0, 0
	for _, sl in pack.storylines do
		if (sl.act or 1) >= 2 then
			second += 1
			if sl.when == nil then
				open += 1
			end
			check(type(sl.cast) == "table" and #sl.cast >= 1, sl.id .. ": a second story names its cast")
		end
	end
	check(second >= 12, "at least twelve second stories (" .. second .. ")")
	check(open >= 5, "at least five second stories can find anyone (" .. open .. ")")
	-- a story you're born into can count your own family in its cast
	local sweep = sim.storylinesById.sl_sweepers_hour
	if sweep then
		local found = false
		for seed = 1, 60 do
			local life = sim:newLife({ seed = 7000 + seed, originId = pack.origins[1].id })
			if life.story == "sl_sweepers_hour" then
				found = true
				local cast = sim:storyView(life).cast
				local mother = nil
				for _, rel in life.relations do
					if rel.kind == "mother" then
						mother = rel
					end
				end
				check(mother ~= nil and cast[1] ~= nil and cast[1].name == mother.first, "the Sweepers' Hour shows your own mother first")
				break
			end
		end
		if not found then
			print("  (no life in 60 was born into the Sweepers' Hour; the family cast went unchecked)")
		end
	end
end

-- ── cutscenes ──
do
	local n = 0
	for _, e in pack.events do
		if e.cutscene then
			n += 1
			check(type(e.cutscene.lines) == "table" and #e.cutscene.lines >= 1 and #e.cutscene.lines <= 4, e.id .. ": a cutscene has one to four lines")
		end
	end
	check(n >= 5, "the turning points have cutscenes")
	for _, era in pack.calendar.eras do
		check(type(era.opening) == "table" and #era.opening == 3, era.id .. ": an age opens with three lines")
	end
	local life = grown(41)
	local entry = sim:cutsceneEntry(life, { style = "age", kicker = "{district}", title = "T", lines = { "a", "b" } })
	check(entry.kind == "cutscene" and #entry.lines == 2 and not string.find(entry.kicker, "{", 1, true), "a cutscene entry is rendered for this life")
end

if fails > 0 then
	print(string.format("\n%d check(s) failed", fails))
	require("@lune/process").exit(1)
end
print("v0.11 check: fighting by stat, tempers, perks, nature, jobs, scenes with people, second stories and cutscenes all hold")
print("OK")
