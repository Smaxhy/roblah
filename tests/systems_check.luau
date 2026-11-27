--[[
	Checks for the bigger systems: expeditions (solo and crew), ambitions, world
	events, the life score and titles, heirlooms.
		lune run tests/systems_check
]]
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local sim = Engine.new(pack)
local Expedition = Loader.require(root.Engine.Expedition)
local Rng = Engine.Rng

local function adult(seed, age)
	local life = sim:newLife({ seed = seed, originId = "ordinary" })
	life.age = age or 25
	life.money = 500
	life.pending = nil
	life.actionsLeft = 3
	for _, k in pack.stats.order do
		life.stats[k] = 55
	end
	return life
end

-- play a run to the end, picking the first enabled choice (and Careful in clashes)
local function playRun(lives, run)
	local steps = 0
	while not run.outcome and steps < 30 do
		steps += 1
		local card = Expedition.view(sim, lives, run)
		assert(card and card.stage, "stage card missing")
		local pick = nil
		for _, c in card.stage.choices do
			if c.enabled then
				pick = c
				break
			end
		end
		assert(pick, "no enabled choice at stage " .. card.stage.id)
		local reports, clash = Expedition.choose(sim, lives, run, pick.index, if pick.clash then "careful" else nil)
		assert(reports, "choose failed: " .. tostring(clash))
		if pick.clash then
			assert(clash and clash.rounds, "clash expected")
		end
		local alive = 0
		for _, l in lives do
			if l.alive then
				alive += 1
			end
		end
		if alive == 0 then
			break
		end
	end
	return steps
end

-- every expedition can be played solo and with a crew, to an ending
local outcomes = {}
for _, id in pack.expeditions.order do
	local def = pack.expeditions[id]
	local was = sim.worldActive.breach_tidewell
	sim:setWorldEvent("breach_tidewell", true)
	-- expeditions that only open while a world event runs (a faction war): start it
	local wantWorld = def.when and def.when.worldEvent
	local worldId = if type(wantWorld) == "table" then wantWorld[1] elseif type(wantWorld) == "string" then wantWorld else nil
	local worldWas = worldId and sim.worldActive[worldId]
	if worldId and pack.worldEvents[worldId] then
		sim:setWorldEvent(worldId, true)
	end
	for trial = 1, 25 do
		local size = if trial % 2 == 0 then math.min(3, def.crew and def.crew.max or 1) else 1
		if size < ((def.crew and def.crew.min) or 1) then
			size = (def.crew and def.crew.min) or 1
		end
		local lives = {}
		for m = 1, size do
			local l = adult(1000 + trial * 31 + m * 7, 30)
			-- meet the expedition's own requirements (quest flags, a career, a Ward)
			local when = def.when or {}
			for _, f in when.flags or {} do
				l.flags[f] = true
			end
			if when.district then
				l.district = if type(when.district) == "table" then when.district[1] else when.district
			end
			-- (v0.13) a place that isn't in some District: live somewhere else
			if when.notDistrict then
				local banned = if type(when.notDistrict) == "table" then when.notDistrict else { when.notDistrict }
				if table.find(banned, l.district) then
					local ids = {}
					for did in pack.districts do
						if type(did) == "string" and did ~= "order" and not table.find(banned, did) then
							table.insert(ids, did)
						end
					end
					table.sort(ids)
					l.district = ids[1] or l.district
				end
			end
			if when.side then
				l.side = if type(when.side) == "table" then when.side[1] else when.side
			end
			if when.career then
				local cid = if type(when.career) == "table" then when.career[1] else when.career
				l.career = { id = cid, rank = math.max(1, when.minRank or 1), years = 3, rankYears = 0, district = l.district }
			end
			if when.minAge and l.age < when.minAge then
				l.age = when.minAge
			end
			-- a world requirement that follows the calendar (an era): live in a year that has it
			for key, want in when.world or {} do
				local value = if type(want) == "table" then want[1] else want
				for _, var in pack.world or {} do
					if var.key == key and var.byYear then
						for i, step in var.byYear do
							if step.value == value then
								local nextFrom = var.byYear[i + 1] and var.byYear[i + 1].from
								local year = math.max(step.from, pack.calendar.startYear)
								if nextFrom and year >= nextFrom then
									year = nextFrom - 1
								end
								l.year = year
								l.bornYear = year - l.age
							end
						end
					end
				end
				sim:rollWorld(l, nil, true)
			end
			table.insert(lives, l)
		end
		local run, reports = Expedition.start(sim, lives, id)
		assert(run, id .. ": start failed: " .. tostring(reports))
		for _, l in lives do
			assert(l.run, "run marker missing")
			assert(sim:ageUp(l) == nil, "aging up should wait until the run ends")
		end
		playRun(lives, run)
		assert(run.outcome, id .. ": run never ended")
		outcomes[run.outcome] = (outcomes[run.outcome] or 0) + 1
		for _, l in lives do
			assert(l.run == nil, id .. ": run marker should clear at the end")
		end
		-- cooldown applies
		if def.cooldown and lives[1].alive then
			local _, enabled = Expedition.state(sim, lives[1], id)
			assert(not enabled, id .. ": cooldown should apply")
		end
	end
	sim:setWorldEvent("breach_tidewell", was == true)
	if worldId and pack.worldEvents[worldId] then
		sim:setWorldEvent(worldId, worldWas == true)
	end
end
print(string.format("expeditions: %d kinds played solo and in crews; outcomes: success %d, fail %d, retreat %d", #pack.expeditions.order, outcomes.success or 0, outcomes.fail or 0, outcomes.retreat or 0))

-- a solo run through the Sim API, and the view shows it (the first expedition an adult can take)
do
	local l = adult(777, 30)
	local pickId = nil
	for _, id in pack.expeditions.order do
		local _, enabled = Expedition.state(sim, l, id)
		if enabled and not pickId and ((pack.expeditions[id].crew and pack.expeditions[id].crew.min) or 1) <= 1 then
			pickId = id
		end
	end
	assert(pickId, "no expedition open to a plain adult")
	local rep, err = sim:startExpedition(l, pickId)
	assert(rep, "solo start failed: " .. tostring(err))
	local v = sim:view(l)
	assert(v.run and v.run.stage and #v.run.stage.choices > 0, "solo run should show in the view")
	local r2 = sim:chooseExpedition(l, 1)
	assert(r2, "solo choose failed")
end

-- the rest exercises the original pack's own quest, world event, jobs and gear by name
if pack.fanWork then
	print("(the original pack's quest, breach and heirloom checks run with LIFESIM_PACK=Undermere)")
	print("OK")
	return
end

-- world events: containment only shows during a breach; breach events weigh more
do
	local l = adult(4242, 30)
	sim:setWorldEvent("breach_tidewell", false)
	local function listed()
		for _, e in Expedition.list(sim, l) do
			if e.id == "tidewell_containment" then
				return true
			end
		end
		return false
	end
	assert(not listed(), "containment should be hidden without a breach")
	sim:setWorldEvent("breach_tidewell", true)
	assert(listed(), "containment should show during a breach")
	local ev = sim.eventsById.breach_thing_in_stairwell
	assert(sim:eligible(l, ev), "breach event should be eligible during a breach")
	sim:setWorldEvent("breach_tidewell", false)
	assert(not sim:eligible(l, ev), "breach event should not be eligible after")
end

-- ambitions: three at a time, completing one rolls another and adds to the score
do
	local l = sim:newLife({ seed = 99, originId = "ordinary" })
	local guard = 0
	while (#(l.ambitions or {}) == 0) and l.alive and guard < 20 do
		guard += 1
		if l.pending then
			sim:choose(l, 1)
		else
			Loader.ageUp(sim, l)
		end
	end
	assert(#l.ambitions > 0 and l.age <= 6, "children should have ambitions by age 6 (age " .. l.age .. ")")
	l.age = 20
	l.ambitions = { { id = "first_job" } }
	l.ambitionsDone = {}
	local before = sim:score(l)
	assert(sim:joinCareer(l, "choir") or sim:joinCareer(l, "stoker") or sim:joinCareer(l, "sluice"), "couldn't take a job")
	assert(l.ambitionsDone.first_job, "first_job should be met after taking a job")
	assert(#l.ambitions >= 1, "a new ambition should be drawn")
	assert(sim:score(l) > before, "an ambition should raise the score")
	local v = sim:view(l)
	assert(#v.ambitions >= 1 and v.ambitions[1].name, "view lists ambitions")
end

-- titles and scores across many lives
local titles, best = {}, 0
local brain = { rng = Rng.seed(5) }
for i = 1, 120 do
	local l = sim:newLife({ seed = 50000 + i * 17, originId = "ordinary" })
	local guard = 0
	while l.alive and guard < 400 do
		guard += 1
		if l.pending then
			local v = sim:view(l)
			local pick = 1
			for _, c in v.pending.choices do
				if c.enabled then
					pick = c.index
					if Rng.chance(brain, 0.5) then
						break
					end
				end
			end
			sim:choose(l, pick)
		else
			Loader.ageUp(sim, l)
		end
	end
	local lantern = sim:lantern(l)
	assert(lantern.title and lantern.score, "lanterns need a title and score")
	titles[lantern.title] = (titles[lantern.title] or 0) + 1
	best = math.max(best, lantern.score)
end
local names = {}
for t, n in titles do
	table.insert(names, string.format("%s %d", t, n))
end
table.sort(names)
print("titles: " .. table.concat(names, ", "))
print("best score: " .. best)

-- heirlooms and teaching carry into the next generation
do
	local p = adult(31337, 40)
	p.gear = { coat = "oilskin", tool = "dock_knife" }
	local child = sim:addRelation(p, { kind = "child", age = 12, bond = 70 })
	child.taught = 3
	sim:kill(p, nil, "Test")
	local heir = sim:newLifeFromHeir(p, child.id, 777)
	assert(heir.gear.coat == "oilskin" and heir.gear.tool == "dock_knife", "heirlooms should pass down")
	assert(heir.generation == 2, "generation should count up")
	assert(heir.look == child.look, "heirs keep their look")
end
print("OK")

-- side quests: offer -> activity -> expedition -> scheduled scene -> reward
do
	local qs = Engine.new(pack)
	local l = qs:newLife({ seed = 8080, originId = "ordinary" })
	l.age = 20
	l.money = 300
	l.pending = nil
	l.actionsLeft = 3
	for _, k in pack.stats.order do
		l.stats[k] = 60
	end
	local report = qs.newReport()
	qs:startQuest(l, "missing_ferryman", report)
	assert(l.quests.missing_ferryman and l.flags.q_ferry_ask, "quest should start and open its activity")
	local rep = qs:doActivity(l, "quest_ask_ferry")
	assert(rep, "quest activity failed")
	assert(l.quests.missing_ferryman.step == 2 and l.flags.q_ferry_search, "step 2 should open the expedition")
	l.actionsLeft = 3
	l.pending = nil
	local Expedition2 = Loader.require(root.Engine.Expedition)
	local run = Expedition2.start(qs, { l }, "cannery_pilings")
	assert(run, "quest expedition should be open")
	local guard = 0
	while not run.outcome and guard < 10 do
		guard += 1
		Expedition2.choose(qs, { l }, run, 1, "careful")
	end
	assert(l.flags.done_cannery_pilings or run.outcome ~= "success", "expedition success sets its flag")
	if run.outcome == "success" then
		assert(l.quests.missing_ferryman and l.quests.missing_ferryman.step == 3, "step 3 should start after the expedition")
		-- the scheduled scene arrives next year and finishes the quest
		for _ = 1, 3 do
			if not l.alive or not l.quests.missing_ferryman then
				break
			end
			l.pending = nil
			l.run = nil
			qs:ageUp(l)
			local g2 = 0
			while l.pending and g2 < 6 do
				g2 += 1
				qs:choose(l, 1)
			end
		end
		assert(l.questsDone and l.questsDone.missing_ferryman, "the quest should complete")
		local v = qs:view(l)
		assert(#v.quests >= 1, "quest log should list it")
	end
	print("quests: the ferryman quest runs offer -> activity -> expedition -> scene -> reward")
end
print("OK")
