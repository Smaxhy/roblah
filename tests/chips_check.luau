--[[
	THE CHIPS KEEP THEIR WORD. Whatever a card, a tile or a row says it gives ("+2 STR",
	"-4 HP", "+6~9 BOND"), the life is given exactly that: never more, never less.

	Lives of every age and build are taken; everything they can do is read off the view
	(activities and trainings in DO, jobs, actions and scenes in PEOPLE, the choices on the card
	in front of them), then done many times over on copies of the life with different dice,
	and each real change is held against the promised range.
		lune run tests/chips_check [lives] [trials]
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Config = Loader.require(root.Config)
Config.pack = process.env.LIFESIM_PACK or "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local Rng = Engine.Rng

local LIVES = tonumber(process.args[1]) or 14
local TRIALS = tonumber(process.args[2]) or 10

local fails, shown = 0, 0
local function fail(msg: string)
	fails += 1
	if shown < 40 then
		shown += 1
		print("  FAIL  " .. msg)
	end
end

local function clone(t: any, seen: any?): any
	if type(t) ~= "table" then
		return t
	end
	local map = seen or {}
	if map[t] then
		return map[t]
	end
	local out = {}
	map[t] = out
	for k, v in t do
		out[clone(k, map)] = clone(v, map)
	end
	return out
end

local KEYS = table.clone(sim.coreStats)
table.insert(KEYS, "sanity")
table.insert(KEYS, "money")
table.insert(KEYS, "bond")

-- the range a list of chips promises for a key (nothing said = nothing changes)
local function promised(chips: any, key: string): (number, number)
	for _, c in chips or {} do
		if c.key == key and not c.text then
			return c.min or 0, c.max or 0
		end
	end
	return 0, 0
end

-- what the outcome really changed: the first log line of the report (the outcome's own)
local function outcome(report: any): any?
	for _, e in report.entries do
		if e.kind == "log" then
			return e.deltas or {}
		end
	end
	return nil
end

local checked, kept = 0, 0
local tally: { [string]: number } = {}
local reach: { [string]: { lo: boolean, hi: boolean, min: number, max: number } } = {}

local function hold(what: string, chips: any, report: any, label: string)
	local real = outcome(report)
	if not real then
		return
	end
	checked += 1
	tally[what] = (tally[what] or 0) + 1
	local fine = true
	for _, key in KEYS do
		local lo, hi = promised(chips, key)
		local got = real[key] or 0
		if got < lo or got > hi then
			fine = false
			fail(("%s: %s promised %s%d~%d %s, gave %d"):format(what, label, if lo >= 0 then "+" else "", lo, hi, key, got))
		end
		if lo ~= hi then
			local r = reach[label .. "/" .. key]
			if not r then
				r = { lo = false, hi = false, min = lo, max = hi }
				reach[label .. "/" .. key] = r
			end
			r.lo = r.lo or got == lo
			r.hi = r.hi or got == hi
		end
	end
	if fine then
		kept += 1
	end
end

local function withDice(life: any, n: number): any
	local c = clone(life)
	c.rng = Rng.seed(n * 7919 + (life.age or 0) * 104729 + 17)
	return c
end

-- the ways into a risk: each stance offered, and going in plain
local function ways(clash: any): { any }
	local out: { any } = { false }
	for _, a in (clash and clash.approaches) or {} do
		table.insert(out, a.id)
	end
	return out
end

local function chipsFor(stakes: any, approach: any, won: boolean): any
	local side = if won then "win" else "lose"
	if approach and stakes.approaches and stakes.approaches[approach] then
		return stakes.approaches[approach][side]
	end
	return stakes[side]
end

-- everything this life could do right now, checked
local function checkLife(life: any, tag: string)
	local v = sim:view(life)
	-- the card in front of them
	if v.pending then
		for _, ch in v.pending.choices do
			if ch.enabled then
				for _, way in if ch.clash then ways(ch.clash) else { false } do
					for t = 1, TRIALS do
						local c = withDice(life, t)
						local report = sim:choose(c, ch.index, if way then way else nil)
						if report then
							local label = ("%s [%s] %s%s"):format(tag, v.pending.id, ch.label, if way then " (" .. way .. ")" else "")
							if ch.clash and report.clash then
								hold("choice", chipsFor(ch.stakes, way, report.clash.won), report, label)
							elseif not ch.clash then
								hold("choice", ch.gains, report, label)
							end
						end
					end
				end
			end
		end
		return
	end
	-- DO: activities and trainings
	for _, act in v.activities do
		local def = sim.activitiesById[act.id]
		if act.enabled and not act.shop and not act.market and not act.move and def then
			for _, way in if act.clash then ways(act.clash) else { false } do
				for t = 1, TRIALS do
					local c = withDice(life, t)
					local report = sim:doActivity(c, act.id, nil, if way then way else nil)
					if report then
						local label = ("%s activity %s%s"):format(tag, act.id, if way then " (" .. way .. ")" else "")
						if act.clash and report.clash then
							hold("activity", chipsFor(act.stakes, way, report.clash.won), report, label)
						elseif not act.clash then
							hold("activity", act.gains, report, label)
						end
					end
				end
			end
		end
	end
	-- jobs
	for _, job in (v.jobs and v.jobs.list) or {} do
		if not job.done and (life.actionsLeft or 0) > 0 then
			for _, way in ways(job.clash) do
				for t = 1, TRIALS do
					local c = withDice(life, t)
					local report = sim:doJob(c, job.index, if way then way else nil)
					if report and report.clash then
						hold("job", chipsFor(job.stakes, way, report.clash.won), report, ("%s job %s%s"):format(tag, job.name, if way then " (" .. way .. ")" else ""))
					end
				end
			end
		end
	end
	-- PEOPLE: what you can do with each of them, and the scenes that opens
	for _, rel in v.relations do
		for _, act in rel.interactions or {} do
			if act.enabled then
				if act.scene then
					for t = 1, math.max(2, TRIALS // 3) do
						local c = withDice(life, t)
						local opened = sim:interact(c, rel.id, act.id)
						if opened and c.pending then
							checkLife(c, tag .. " with " .. rel.kind)
						end
					end
				else
					for _, way in if act.clash then ways(act.clash) else { false } do
						for t = 1, TRIALS do
							local c = withDice(life, t)
							local report = sim:interact(c, rel.id, act.id, if way then way else nil)
							if report then
								local label = ("%s people %s/%s%s"):format(tag, act.id, rel.kind, if way then " (" .. way .. ")" else "")
								if act.clash and report.clash then
									hold("people", chipsFor(act.stakes, way, report.clash.won), report, label)
								elseif not act.clash then
									hold("people", act.gains, report, label)
								end
							end
						end
					end
				end
			end
		end
	end
end

-- ── fixed cases: the sums, where they are easy to follow ──
do
	local life = sim:newLife({ seed = 3, rollOrigin = true })
	life.pending, life.queue = nil, {}
	life.age = 30
	for _, k in sim.coreStats do
		life.stats[k] = 30
	end
	life.traits = {}
	local Effects = Engine.Effects
	local function range(result: any, ctx: any?, key: string): (number, number)
		local p = Effects.preview(sim, life, result, ctx)[key]
		return if p then p.min else 0, if p then p.max else 0
	end
	local stat = sim.coreStats[2]
	local lo, hi = range({ [stat] = 4 }, nil, stat)
	if not (lo == 4 and hi == 4) then
		fail(("a plain +4 at 30 is +4 (got %d~%d)"):format(lo, hi))
	end
	-- an activity gives a little less (pack.activityGrowth), and says so
	if pack.activityGrowth then
		lo, hi = range({ [stat] = 4 }, { activity = true }, stat)
		local x = 4 * pack.activityGrowth
		if not (lo == math.floor(x) and hi == math.ceil(x)) then
			fail(("an activity's +4 is +%d~%d (got %d~%d)"):format(math.floor(x), math.ceil(x), lo, hi))
		end
	end
	-- high stats grow slowly, and the chip knows
	life.stats[stat] = 85
	lo, hi = range({ [stat] = 4 }, nil, stat)
	if not (lo == 0 and hi == 1) then
		fail(("a +4 at 85 is +0~1 (got %d~%d)"):format(lo, hi))
	end
	life.stats[stat] = 100
	lo, hi = range({ [stat] = 4 }, nil, stat)
	if not (lo == 0 and hi == 0) then
		fail(("a +4 at 100 is nothing (got %d~%d)"):format(lo, hi))
	end
	local chips = sim:stakesOf({ [stat] = 4 }, nil, nil, life, nil)
	if not (chips[1] and chips[1].capped) then
		fail("a stat at its top says so instead of promising")
	end
	-- a loss of health is taken at the City's rate
	life.stats[sim.vital] = 80
	lo, hi = range({ [sim.vital] = -10 }, nil, sim.vital)
	local c = clone(life)
	Effects.apply(sim, c, { [sim.vital] = -10 }, nil)
	local real = c.stats[sim.vital] - 80
	if not (lo == real and hi == real) then
		fail(("a -10 to health lands as %d, and the chip said %d~%d"):format(real, lo, hi))
	end
	-- the bond with someone, Charisma and all
	local rel = { alive = true, bond = 50 }
	lo, hi = range({ bond = { 8, 12 } }, { target = rel }, "bond")
	local x = sim:charmOf(life) / 25
	if not (lo == 8 + math.floor(x) and hi == 12 + math.ceil(x)) then
		fail(("bond 8~12 with Charisma %d is +%d~%d (got %d~%d)"):format(sim:charmOf(life), 8 + math.floor(x), 12 + math.ceil(x), lo, hi))
	end
	rel.bond = 97
	lo, hi = range({ bond = { 8, 12 } }, { target = rel }, "bond")
	if not (lo == 3 and hi == 3) then
		fail(("a bond at 97 can only rise 3 (got %d~%d)"):format(lo, hi))
	end
end

-- ── lives of every age and build ──
local AGES = { 7, 11, 15, 19, 26, 34, 45, 58 }
local made = 0
for n = 1, LIVES do
	local life = sim:newLife({ seed = 900 + n * 31, rollOrigin = true })
	local target = AGES[(n - 1) % #AGES + 1]
	local guard = 0
	while life.alive and guard < 4000 do
		guard += 1
		if life.pending then
			-- the cards on the way are checked too (every fourth, to keep this quick)
			if guard % 4 == 0 then
				checkLife(life, ("life %d age %d"):format(n, life.age))
			end
			local v = sim:view(life)
			local pick = nil
			for i, c in v.pending.choices do
				if c.enabled and (pick == nil or (guard + i) % 3 == 0) then
					pick = c.index
				end
			end
			if not pick or not sim:choose(life, pick, nil) then
				life.pending = nil
			end
		elseif life.age >= target then
			break
		else
			Loader.ageUp(sim, life)
		end
	end
	if life.alive and not life.pending then
		made += 1
		-- as they are
		checkLife(life, ("life %d age %d"):format(n, life.age))
		-- and as other builds: stats low, middling, high and at the top; rich and poor
		for b, level in { 8, 45, 63, 84, 93, 100 } do
			local c = clone(life)
			for _, k in sim.coreStats do
				if k ~= sim.vital then
					c.stats[k] = math.min(100, level + (b * 3 + #k) % 5)
				end
			end
			c.stats[sim.vital] = math.max(20, 100 - b * 12)
			c.sanity = ({ 40, 10, -20, 0, 44, -38 })[b]
			c.money = 4000
			c.actionsLeft, c.socialLeft = 3, 3
			for _, rel in c.relations do
				rel.bond = ({ 20, 50, 70, 90, 97, 100 })[b]
				rel.talked = nil
			end
			checkLife(c, ("life %d age %d build %d"):format(n, life.age, level))
		end
	end
end

-- how often the two ends of a range were really met (a range that is never reached at one end
-- promises something that can't happen)
local wide, unmet = 0, 0
local unmetList = {}
for label, r in reach do
	wide += 1
	if not (r.lo and r.hi) then
		unmet += 1
		if #unmetList < 6 then
			table.insert(unmetList, ("%s (%d~%d: %s end never seen)"):format(label, r.min, r.max, if r.lo then "top" else "bottom"))
		end
	end
end

print(("chips: %d lives; %d outcomes checked, %d kept their word"):format(made, checked, kept))
local parts = {}
for what, n in tally do
	table.insert(parts, what .. " " .. n)
end
table.sort(parts)
print("  " .. table.concat(parts, ", "))
print(("  ranges: %d, both ends seen in %d"):format(wide, wide - unmet))
for _, line in unmetList do
	print("    " .. line)
end
if fails > 0 then
	print(fails .. " FAILED")
	process.exit(1)
end
print("CHIPS OK")
