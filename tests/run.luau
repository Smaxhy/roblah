--[[
	Content validation + headless life simulation.
		lune run tests/run            -- 3000 lives
		lune run tests/run 20000      -- more lives
	Exits non-zero on validation errors or runtime errors.
]]

local process = require("@lune/process")
local serde = require("@lune/serde")
local Loader = require("./loader")

local LIVES = tonumber(process.args[1]) or 3000

local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)

-- ── validation ──────────────────────────────────────────────────────────────
local issues = Engine.Validate.run(pack)
print(string.format("Content: %d events, %d activities, %d careers, %d origins", #pack.events, #pack.activities, #pack.careers.order, #pack.origins))
for _, w in issues.warnings do
	print("  warn  " .. w)
end
for _, e in issues.errors do
	print("  ERROR " .. e)
end
if #issues.errors > 0 then
	print(string.format("\n%d validation errors.", #issues.errors))
	process.exit(1)
end

-- ── helpers ─────────────────────────────────────────────────────────────────
local function isArray(t)
	local n = 0
	for _ in t do
		n += 1
	end
	for i = 1, n do
		if t[i] == nil then
			return false
		end
	end
	return true
end

-- DataStores can't save mixed or sparse tables, functions or userdata.
local function checkSaveable(v, path)
	local tv = type(v)
	if tv == "function" or tv == "userdata" or tv == "thread" then
		error("unsaveable " .. tv .. " at " .. path)
	end
	if tv ~= "table" then
		return
	end
	if getmetatable(v) ~= nil then
		error("table with metatable at " .. path)
	end
	local hasString, hasNumber = false, false
	for k in v do
		if type(k) == "string" then
			hasString = true
		elseif type(k) == "number" then
			hasNumber = true
		else
			error("bad key type at " .. path)
		end
	end
	if hasString and hasNumber then
		error("mixed table at " .. path)
	end
	if hasNumber and not isArray(v) then
		error("sparse array at " .. path)
	end
	for k, child in v do
		checkSaveable(child, path .. "." .. tostring(k))
	end
end

local sim = Engine.new(pack)
local Rng = Engine.Rng

-- one server's chronicle, shared by every simulated life (so events about other players'
-- deeds, `when.chronicle`, get played too), and a new "day" per life for today's event
local chronicle = {}
sim:setChronicle(chronicle)
local function noteChronicle(life, report)
	for _, c in (report and report.chronicle) or {} do
		table.insert(chronicle, { act = c.act, name = life.first .. " " .. life.last, district = life.district, lifeId = life.id })
		if #chronicle > 80 then
			table.remove(chronicle, 1)
		end
	end
end

-- ── simulation ──────────────────────────────────────────────────────────────
local stats = {
	lives = 0,
	errors = {},
	ages = {},
	causes = {},
	forms = {},
	careers = {},
	fired = {},
	clashes = 0,
	clashWins = 0,
	heirRuns = 0,
	peakMoney = 0,
}

local function bump(t, k)
	t[k] = (t[k] or 0) + 1
end

local Expedition = Engine.Expedition

-- plays an expedition solo to its end with random choices and approaches
-- (v0.13) a delve that a card started (a way in found in the world) plays out like any other
local finishRun
local function playExpedition(brain, life, id)
	local reports = Expedition.start(sim, { life }, id)
	if not reports then
		return
	end
	finishRun(brain, life, id)
end
function finishRun(brain, life, id)
	local run = life.run
	if not run then
		return
	end
	id = id or run.id
	stats.expeditions = stats.expeditions or {}
	local guard = 0
	while run and not run.outcome and guard < 30 do
		guard += 1
		local card = Expedition.view(sim, { life }, run)
		local open = {}
		for _, c in (card and card.stage and card.stage.choices) or {} do
			if c.enabled then
				table.insert(open, c)
			end
		end
		if #open == 0 then
			error("expedition " .. id .. " stuck at stage " .. tostring(card and card.stage and card.stage.id) .. ": no choice is available")
		end
		local pick = Rng.pick(brain, open)
		local approach = if pick.clash then Rng.pick(brain, { "steady", "reckless", "careful" }) else nil
		local reps = Expedition.choose(sim, { life }, run, pick.index, approach)
		assert(reps, "expedition choice failed")
		if not life.alive then
			break
		end
	end
	if guard >= 30 then
		error("expedition " .. id .. " never ended")
	end
	stats.expeditions[run.outcome or "died"] = (stats.expeditions[run.outcome or "died"] or 0) + 1
end

local worldIds = (pack.worldEvents and pack.worldEvents.order) or {}
-- how often the bot goes on an expedition (per year); `lune run tests/run 500 noexp` turns them off
EXPEDITION_RATE = if process.args[2] == "noexp" then 0 else 0.12

local function playLife(seed: number, life)
	local brain = { rng = Rng.seed(seed * 7 + 3) }
	local years = 0
	local worldOn, worldYears = nil, 0
	-- (v0.18) a form that lives for centuries (a Bloodfiend, since v0.17) gets the years to
	-- reach the end of them; everyone else ends well inside 200
	local function capFor(l): number
		local form = pack.forms and pack.forms[l.form or "human"]
		return if form and (form.lifespan or 0) > 150 then form.lifespan + 200 else 200
	end
	while life.alive and years < capFor(life) do
		-- now and then a world event is on (the server rolls these for real)
		if worldOn then
			worldYears -= 1
			if worldYears <= 0 then
				sim:setWorldEvent(worldOn, false)
				worldOn = nil
			end
		elseif #worldIds > 0 and Rng.chance(brain, 0.05) then
			worldOn = Rng.pick(brain, worldIds)
			worldYears = 2
			sim:setWorldEvent(worldOn, true)
			local we = pack.worldEvents[worldOn]
			if we.startEvent and sim.eventsById[we.startEvent] and not life.pending and not life.run then
				table.insert(life.queue, 1, we.startEvent)
				sim:advance(life, sim.newReport())
			end
		end
		years += 1
		if life.run then
			finishRun(brain, life, nil)
		end
		-- resolve any pending decisions
		local guard = 0
		while life.pending and life.alive and guard < 25 do
			guard += 1
			local v = sim:view(life)
			local options = {}
			for _, c in v.pending.choices do
				-- play like a person: long-odds clashes are only taken now and then
				local reckless = c.clash and (c.clash.bestOdds or c.clash.odds) < 0.35
				-- and nobody picks the option that says, plainly, that it ends them
				local fatal = false
				for _, g in c.gains or {} do
					if g.key == "die" then
						fatal = true
					end
				end
				if c.enabled and not fatal and (not reckless or Rng.chance(brain, 0.12)) then
					table.insert(options, c.index)
				end
			end
			if #options == 0 then
				for _, c in v.pending.choices do
					if c.enabled then
						table.insert(options, c.index)
					end
				end
			end
			if #options == 0 then
				error("pending event " .. v.pending.id .. " has no enabled choices at age " .. life.age)
			end
			local pickIdx = Rng.pick(brain, options)
			local approach = nil
			local picked = v.pending.choices[pickIdx]
			if picked and picked.clash and picked.clash.approaches and #picked.clash.approaches > 0 then
				-- mostly the way with the best odds, sometimes whatever comes to hand
				local list = picked.clash.approaches
				local best = list[1]
				for _, a in list do
					if a.odds > best.odds then
						best = a
					end
				end
				approach = (if Rng.chance(brain, 0.75) then best else Rng.pick(brain, list)).id
				stats.approaches = stats.approaches or {}
				stats.approaches[approach] = (stats.approaches[approach] or 0) + 1
			end
			local report = assert(sim:choose(life, pickIdx, approach))
			noteChronicle(life, report)
			if life.run and life.alive then
				stats.inlineDelves = (stats.inlineDelves or 0) + 1
				finishRun(brain, life, nil)
			end
			-- (v0.16) a big boss in turns: fought to the end, and counted
			if life.battle and life.alive then
				stats.battles = (stats.battles or 0) + 1
				Loader.finishBattle(sim, life)
				local done = life.battleDone
				if done then
					stats.battleOutcomes = stats.battleOutcomes or {}
					local key = if life.alive then done.outcome else "died"
					stats.battleOutcomes[key] = (stats.battleOutcomes[key] or 0) + 1
				end
			end
			if report.clash then
				stats.clashes += 1
				if report.clash.won then
					stats.clashWins += 1
				end
			end
		end
		if guard >= 25 then
			error("stuck resolving events at age " .. life.age)
		end
		if not life.alive then
			break
		end
		-- maybe look for work
		if life.career == nil and life.age >= 14 and Rng.chance(brain, 0.4) then
			local v = sim:view(life)
			local open = {}
			for _, c in v.careers do
				if c.enabled then
					table.insert(open, c.id)
				end
			end
			if #open > 0 then
				assert(sim:joinCareer(life, Rng.pick(brain, open)))
			end
		end
		-- go on an expedition now and then
		if EXPEDITION_RATE > 0 and life.age >= 14 and not life.pending and not life.run and Rng.chance(brain, EXPEDITION_RATE) then
			local open = {}
			for _, e in Expedition.list(sim, life) do
				if e.enabled and e.crewMin <= 1 then
					table.insert(open, e.id)
				end
			end
			if #open > 0 then
				playExpedition(brain, life, Rng.pick(brain, open))
			end
		end
		-- spend actions
		for _ = 1, life.actionsLeft do
			if life.pending or not life.alive then
				break
			end
			-- shop for gear now and then (before checking what's affordable)
			if Rng.chance(brain, 0.15) and pack.gear then
				local id = Rng.pick(brain, pack.gear.order)
				if sim:buyGear(life, id) then
					stats.gearBought = (stats.gearBought or 0) + 1
				end
			end
			local v = sim:view(life)
			-- (v0.12) now and then, spend: something this life can afford at a market
			if v.markets and Rng.chance(brain, 0.3) then
				local can = {}
				for _, m in v.markets do
					for _, g in m.goods do
						if g.enabled and g.price <= life.money * 0.6 then
							table.insert(can, { m.id, g.id })
						end
					end
				end
				if #can > 0 then
					local pick = Rng.pick(brain, can)
					local bought = sim:buyMarket(life, pick[1], pick[2])
					if bought then
						stats.bought = (stats.bought or 0) + 1
						stats.boughtIds = stats.boughtIds or {}
						stats.boughtIds[pick[2]] = (stats.boughtIds[pick[2]] or 0) + 1
						noteChronicle(life, bought)
					end
					if life.pending or not life.alive then
						break
					end
					v = sim:view(life)
				end
			end
			-- someone with a job does the job: usually one off the board when the odds are fair
			if v.jobs and life.actionsLeft > 0 and not life.pending and Rng.chance(brain, 0.45) then
				local took = false
				for _, j in v.jobs.list do
					local odds = j.clash.bestOdds or j.clash.odds
					if not j.done and (odds >= 0.4 or Rng.chance(brain, 0.15)) then
						local approach = nil
						if j.clash.approaches and #j.clash.approaches > 0 then
							local best = j.clash.approaches[1]
							for _, a in j.clash.approaches do
								if a.odds > best.odds then
									best = a
								end
							end
							approach = best.id
						end
						local jr = assert(sim:doJob(life, j.index, approach))
						stats.jobs = (stats.jobs or 0) + 1
						if jr.clash then
							stats.clashes += 1
							if jr.clash.won then
								stats.clashWins += 1
								stats.jobsWon = (stats.jobsWon or 0) + 1
							end
						end
						took = true
						break
					end
				end
				if took then
					continue
				end
			end
			local open = {}
			for _, a in v.activities do
				if a.enabled and not a.shop and not a.market then
					table.insert(open, a.id)
				end
			end
			if #open == 0 or Rng.chance(brain, 0.2) then
				break
			end
			local pickId = Rng.pick(brain, open)
			-- a half-sensible player: usually patches up when badly hurt or shaken
			local isOpen = {}
			for _, id in open do
				isOpen[id] = true
			end
			-- the healing and calming activities differ by pack (Undermere: stitcher, still;
			-- the City: clinic, quiet or diner)
			local heal = if isOpen.stitcher then "stitcher" elseif isOpen.clinic then "clinic" else nil
			local calm = if isOpen.still then "still" elseif isOpen.quiet then "quiet" elseif isOpen.diner then "diner" else nil
			if life.stats[pack.stats.vital or "fortitude"] < 40 and heal and Rng.chance(brain, 0.7) then
				pickId = heal
			elseif life.sanity < -12 and calm and Rng.chance(brain, 0.5) then
				pickId = calm
			end
			local arg = nil
			if sim.activitiesById[pickId].move == "district" then
				local others = {}
				for _, d in pack.districts.order do
					if d ~= life.district then
						table.insert(others, d)
					end
				end
				arg = Rng.pick(brain, others)
			end
			local report = assert(sim:doActivity(life, pickId, arg))
			noteChronicle(life, report)
			if sim.activitiesById[pickId].category == "deeds" then
				stats.deeds = (stats.deeds or 0) + 1
			end
			if report.clash then
				stats.clashes += 1
				if report.clash.won then
					stats.clashWins += 1
				end
			end
		end
		if life.pending or not life.alive then
			continue
		end
		noteChronicle(life, assert(sim:ageUp(life)))
		life.lowSanity = math.min(life.lowSanity or 99, life.sanity)
	end
	if worldOn then
		sim:setWorldEvent(worldOn, false)
	end
	if life.alive then
		error("life never ended (age " .. life.age .. ")")
	end
end

local function record(life)
	stats.lives += 1
	local title = sim:ribbon(life)
	stats.titles = stats.titles or {}
	if title then
		stats.titles[title.name] = (stats.titles[title.name] or 0) + 1
	end
	for _ in life.questsDone or {} do
		stats.questsDone = (stats.questsDone or 0) + 1
	end
	stats.ambitionsMet = (stats.ambitionsMet or 0) + ((life.tally and life.tally.ambitions) or 0)
	stats.bestScore = math.max(stats.bestScore or 0, sim:score(life))
	stats.records = stats.records or {}
	for _, id in sim:checkRecords(life) do
		stats.records[id] = (stats.records[id] or 0) + 1
	end
	for _, c in life.conditions or {} do
		stats.conditionsAtDeath = (stats.conditionsAtDeath or 0) + 1
	end
	stats.bySide = stats.bySide or {}
	local bs = stats.bySide[life.birthSide or "?"] or { n = 0, early = 0, ages = 0 }
	bs.n += 1
	bs.ages += life.age
	if life.age < 50 then
		bs.early += 1
	end
	stats.bySide[life.birthSide or "?"] = bs
	stats.byDistrict = stats.byDistrict or {}
	stats.byDistrict[life.birthDistrict or "?"] = (stats.byDistrict[life.birthDistrict or "?"] or 0) + 1
	table.insert(stats.ages, life.age)
	bump(stats.causes, life.cause or "?")
	bump(stats.forms, life.form)
	-- second stories (storyline.act = 2): every one this life was in, finished or not
	do
		local n = 0
		stats.secondIds = stats.secondIds or {}
		local function count(id)
			for _, sl in pack.storylines or {} do
				if sl.id == id and (sl.act or 1) >= 2 then
					n += 1
					bump(stats.secondIds, id)
				end
			end
		end
		for _, s in life.storiesDone or {} do
			count(s.id)
		end
		if life.story then
			count(life.story)
		end
		stats.secondStories = (stats.secondStories or 0) + n
		if n > 0 then
			stats.livesWithSecond = (stats.livesWithSecond or 0) + 1
		end
	end
	if life.career then
		bump(stats.careers, life.career.id)
	end
	for id in life.history do
		bump(stats.fired, id)
	end
	stats.peakMoney = math.max(stats.peakMoney, life.peakMoney or 0)
	-- (v0.12) what a grown life amounted to: renown grades, Offices, deeds
	stats.renownRanks = stats.renownRanks or {}
	local rr = life.peakRenown or 0
	stats.renownRanks[rr] = (stats.renownRanks[rr] or 0) + 1
	stats.renownTotal = (stats.renownTotal or 0) + (life.renown or 0)
	if life.office then
		stats.offices = (stats.offices or 0) + 1
	end
	if life.home then
		stats.homes = (stats.homes or 0) + 1
	end
	for id in life.history do
		if string.sub(id, 1, 3) == "rn_" then
			stats.renownEvents = (stats.renownEvents or 0) + 1
		end
	end
	stats.lowSanity = stats.lowSanity or {}
	table.insert(stats.lowSanity, life.lowSanity or life.sanity)
end

for i = 1, LIVES do
	local seed = 1000 + i * 7919
	local origin = pack.origins[(i % #pack.origins) + 1].id
	-- lives are born in every era a player can pick, and each plays on its own "day"
	local eras = (pack.calendar and pack.calendar.eras) or {}
	local era = if #eras > 0 then eras[(i % #eras) + 1].id else nil
	local dailyOrder = (pack.daily and pack.daily.order) or {}
	if #dailyOrder > 0 then
		sim:setDaily(dailyOrder[(i % #dailyOrder) + 1], 30000 + i)
	end
	local ok, err = pcall(function()
		local life = sim:newLife({ seed = seed, originId = origin, birthEra = era })
		life.birthSide, life.birthDistrict = life.side, life.district
		playLife(seed, life)
		local lantern = sim:lantern(life)
		assert(lantern.name and lantern.epitaph and lantern.glow, "bad lantern")
		checkSaveable(life, "life")
		checkSaveable(lantern, "lantern")
		serde.decode("json", serde.encode("json", life))
		record(life)
		-- play one heir if there is one
		local heirs = sim:heirs(life)
		if #heirs > 0 and i % 3 == 0 then
			local child = sim:newLifeFromHeir(life, heirs[1].id, seed + 1)
			assert(child, "heir failed")
			child.birthSide, child.birthDistrict = child.side, child.district
			playLife(seed + 1, child)
			stats.heirRuns += 1
			record(child)
		end
	end)
	if not ok then
		table.insert(stats.errors, string.format("seed %d (%s): %s", seed, origin, tostring(err)))
		if #stats.errors >= 15 then
			break
		end
	end
end

-- ── report ──────────────────────────────────────────────────────────────────
table.sort(stats.ages)
local total = 0
for _, a in stats.ages do
	total += a
end
local n = #stats.ages
local function pct(pred)
	local c = 0
	for _, a in stats.ages do
		if pred(a) then
			c += 1
		end
	end
	return string.format("%d%%", math.floor(100 * c / math.max(1, n) + 0.5))
end

print(string.format("\nPlayed %d lives (%d as heirs).", stats.lives, stats.heirRuns))
if n > 0 then
	print(string.format("Lifespan: mean %.1f, median %d, max %d", total / n, stats.ages[math.max(1, math.floor(n / 2))], stats.ages[n]))
	print("Reached 18: " .. pct(function(a) return a >= 18 end) .. "  30: " .. pct(function(a) return a >= 30 end) .. "  50: " .. pct(function(a) return a >= 50 end) .. "  70: " .. pct(function(a) return a >= 70 end))
end
print(string.format("Clashes: %d (won %.0f%%)", stats.clashes, 100 * stats.clashWins / math.max(1, stats.clashes)))
if stats.lowSanity and #stats.lowSanity > 0 then
	table.sort(stats.lowSanity)
	local m = #stats.lowSanity
	print(string.format(
		"Lowest sanity reached per life: 5th pct %d, median %d, 95th pct %d",
		stats.lowSanity[math.max(1, math.floor(m * 0.05))],
		stats.lowSanity[math.max(1, math.floor(m * 0.5))],
		stats.lowSanity[math.max(1, math.floor(m * 0.95))]
	))
end
print("Peak money seen: " .. stats.peakMoney)

local function top(t, label, limit)
	local list = {}
	for k, v in t do
		table.insert(list, { k, v })
	end
	table.sort(list, function(a, b)
		return a[2] > b[2]
	end)
	print(label)
	for i = 1, math.min(limit, #list) do
		print(string.format("  %5d  %s", list[i][2], list[i][1]))
	end
end
if stats.bySide then
	for side, bs in stats.bySide do
		print(string.format("Born in %-8s %5d lives, mean age %.1f, died before 50: %d%%", side, bs.n, bs.ages / math.max(1, bs.n), math.floor(100 * bs.early / math.max(1, bs.n) + 0.5)))
	end
end
print(string.format("Gear bought: %d  ·  conditions active at death: %d", stats.gearBought or 0, stats.conditionsAtDeath or 0))
local ex = stats.expeditions or {}
print(string.format("Expeditions: success %d, fail %d, turned back %d, died %d", ex.success or 0, ex.fail or 0, ex.retreat or 0, ex.died or 0))
do
	local bo = stats.battleOutcomes or {}
	print(string.format("Boss battles: %d fought; won %d, lost %d, fled %d, died %d", stats.battles or 0, bo.won or 0, bo.lost or 0, bo.fled or 0, bo.died or 0))
end
print(string.format("Jobs: %d taken, %d done well; second stories begun: %d, in %d lives", stats.jobs or 0, stats.jobsWon or 0, stats.secondStories or 0, stats.livesWithSecond or 0))
if stats.secondIds and next(stats.secondIds) then
	local parts = {}
	for k, v in stats.secondIds do
		table.insert(parts, k .. " " .. v)
	end
	table.sort(parts)
	print("Second stories: " .. table.concat(parts, ", "))
end
do
	local parts = {}
	for r = 0, 8 do
		if stats.renownRanks and stats.renownRanks[r] then
			table.insert(parts, string.format("%d:%d", r, stats.renownRanks[r]))
		end
	end
	print(string.format("Renown (best grade: lives) %s  ·  mean renown %.0f  ·  Offices owned %d  ·  deeds %d  ·  renown events %d", table.concat(parts, " "), (stats.renownTotal or 0) / math.max(1, stats.lives or 1), stats.offices or 0, stats.deeds or 0, stats.renownEvents or 0))
	local top = {}
	for id, n in stats.boughtIds or {} do
		table.insert(top, { id = id, n = n })
	end
	table.sort(top, function(a, b)
		return a.n > b.n
	end)
	local names = {}
	for i = 1, math.min(8, #top) do
		table.insert(names, top[i].id .. " " .. top[i].n)
	end
	print(string.format("Markets: %d bought, %d lives died owning a home  ·  most bought: %s", stats.bought or 0, stats.homes or 0, table.concat(names, ", ")))
end
print(string.format("Side quests finished: %d  ·  ambitions met: %d  ·  best life score: %d", stats.questsDone or 0, stats.ambitionsMet or 0, stats.bestScore or 0))
if stats.approaches then
	local parts = {}
	for k, v in stats.approaches do
		table.insert(parts, k .. " " .. v)
	end
	print("Approaches used: " .. table.concat(parts, ", "))
end
if stats.records then
	top(stats.records, "Records earned (lives):", 20)
end
top(stats.causes, "Causes of death:", 12)
top(stats.forms, "Final forms:", 6)
top(stats.careers, "Careers at death:", 8)
top(stats.titles or {}, "Titles:", 10)

local never = {}
for _, e in pack.events do
	if not stats.fired[e.id] then
		table.insert(never, e.id)
	end
end
print(string.format("Events fired: %d / %d", #pack.events - #never, #pack.events))
if #never > 0 then
	print("  never fired: " .. table.concat(never, ", "))
end

if #stats.errors > 0 then
	print("\nRUNTIME ERRORS:")
	for _, e in stats.errors do
		print("  " .. e)
	end
	process.exit(1)
end
print("\nOK")
