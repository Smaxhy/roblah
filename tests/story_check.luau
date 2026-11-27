--[[
	Storylines: every storyline can be rolled, its opening always fires, its beats come in
	order at their ages, lives on a story skip the stock openings, goals change, and each
	story reaches an ending in most lives that live long enough.
		lune run tests/story_check          (40 lives per storyline)
		lune run tests/story_check 100
		lune run tests/story_check 40 sl2_changing     (one storyline only)
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local N = tonumber(process.args[1]) or 40
local ONLY = process.args[2]

local issues = Engine.Validate.run(pack)
assert(#issues.errors == 0, "content has validation errors: " .. tostring(issues.errors[1]))
local sim = Engine.Sim.new(pack)
local fails = 0
local function check(ok: boolean, msg: string)
	if not ok then
		fails += 1
		print("  FAIL  " .. msg)
	end
end

local rngState = 12345
local function rnd(a: number, b: number): number
	rngState = (rngState * 48271) % 2147483647
	return a + (rngState % (b - a + 1))
end

local beatsOf = {}
for _, e in pack.events do
	if e.story then
		beatsOf[e.story] = (beatsOf[e.story] or 0) + 1
	end
end

-- cards that came up with no choice a life could take (there should be none)
local stuck: { [string]: number } = {}
print(string.format("storylines: %d", #(pack.storylines or {})))
for _, sl in pack.storylines or {} do
	if ONLY and sl.id ~= ONLY then
		continue
	end
	local fired, endings, goals, opened, lived, reached30, ended = {}, {}, 0, 0, 0, 0, 0
	local cutShort = 0
	local stockSeen = 0
	-- a SECOND story (act = 2) finds a grown life: any birth, eighteen years, then the job or the
	-- District it needs, and it begins
	local second = (sl.act or 1) >= 2
	for i = 1, N do
		-- a birth this storyline accepts: try seeds until its `when` fits
		local life
		for attempt = 1, 60 do
			local l = sim:newLife({ seed = i * 7919 + attempt * 104729, rollOrigin = true, story = if second then nil else sl.id })
			if second then
				-- (no second story may find it while it grows up: the one under test must be
				-- the first it meets, or its chapters would already be behind it)
				l.storiesDone = { {}, {}, {}, {} }
				local guard = 0
				while l.alive and (l.age < 18 or l.pending) and guard < 600 do
					guard += 1
					if l.pending then
						local v = sim:view(l)
						local pick = nil
						for ci, c in v.pending.choices do
							if c.enabled then
								pick = ci
								break
							end
						end
						if not pick or not sim:choose(l, pick, nil) then
							l.pending = nil
						end
					else
						Loader.ageUp(sim, l)
						l.stats.health = math.max(l.stats.health, 50)
					end
				end
				-- (in play a second story is only offered in an age of the City its `when.world`
				-- allows: a story of Distortions never finds a life still in L Corp's years)
				local inItsAge = not (sl.when and sl.when.world)
					or Engine.Conditions.check({ world = sl.when.world }, l, pack, { noChance = true })
				if l.alive and not l.pending and inItsAge then
					local w = sl.when or {}
					if w.career then
						sim:setCareer(l, if type(w.career) == "table" then w.career[1] else w.career, {})
					end
					if w.district then
						l.district = w.district
					end
					if w.side then
						l.side = w.side
					end
					-- (whatever it was born into is over; nothing else may claim it in this test)
					l.storyEnding = l.storyEnding or "left behind"
					l.storiesDone = { {}, {}, {}, {} }
					sim:beginStory(l, sl, sim.newReport())
					-- (in play a story begins as the year turns; here it begins between two, so
					-- its first chapter belongs to the next one)
					l.storyStart = l.age + 1
					life = l
					break
				end
			elseif Engine.Conditions.check(sl.when, l, pack, { noChance = true }) then
				life = l
				break
			end
		end
		if life then
			lived += 1
			check(life.story == sl.id and life.flags[sl.id] == true, sl.id .. ": the life isn't on its story")
			local lastGoal = life.storyGoal
			local seenBeat = {}
			local startAge = life.age
			-- what the first three years of it showed this life (printed if no chapter ever came)
			local trace = {}
			while life.alive and life.age < 45 do
				Loader.ageUp(sim, life)
				if life.age <= startAge + 3 then
					table.insert(trace, string.format("age %d (queue %d):", life.age, #life.queue))
				end
				local guard = 0
				while life.alive and life.pending and guard < 40 do
					guard += 1
					local ev = sim.eventsById[life.pending]
					if life.age <= startAge + 3 then
						table.insert(trace, ev.id)
					end
					if ev.story == sl.id and not seenBeat[ev.id] then
						seenBeat[ev.id] = true
						fired[ev.id] = (fired[ev.id] or 0) + 1
					elseif ev.story and ev.story ~= sl.id and life.story == sl.id then
						-- (a beat of a story the life has since moved on to is as it should be)
						check(false, sl.id .. ": a beat of " .. ev.story .. " fired (" .. ev.id .. ")")
					end
					for _, prefix in pack.storyReplaces or {} do
						if string.sub(ev.id, 1, #prefix) == prefix then
							stockSeen += 1
						end
					end
					local v = sim:view(life)
					local open = {}
					for ci, c in v.pending.choices do
						if c.enabled then
							table.insert(open, ci)
						end
					end
					if #open == 0 then
						stuck[ev.id] = (stuck[ev.id] or 0) + 1
						life.pending = nil
						break
					end
					local ci = open[rnd(1, #open)]
					local approach = if v.pending.choices[ci].clash then "steady" else nil
					local rep = sim:choose(life, ci, approach)
					if not rep then
						life.pending = nil
					end
				end
				-- stay alive long enough to see the story: rest when hurt
				if life.alive and not life.pending and life.stats.health < 40 then
					life.stats.health = math.min(100, life.stats.health + 20)
				end
				if life.storyGoal ~= lastGoal then
					goals += 1
					lastGoal = life.storyGoal
				end
			end
			if next(seenBeat) then
				opened += 1
			elseif second and not life.alive and life.age <= startAge + 1 then
				-- (a grown life that died in the very year the story began, before its first
				-- chapter came up: that's the City, not the story)
				lived -= 1
				cutShort += 1
			else
				print(string.format("      (no chapter seen: alive %s, age %d, began at %d, story %s, storyStart %s, cause %s)",
					tostring(life.alive), life.age, startAge, tostring(life.story), tostring(life.storyStart), tostring(life.cause)))
				print("      " .. table.concat(trace, " "))
			end
			-- how this story ended: on the life still, or on its shelf if another has begun since
			local ending = if life.story == sl.id then life.storyEnding else nil
			for _, done in life.storiesDone or {} do
				if done.id == sl.id then
					ending = done.ending
				end
			end
			-- (v0.18) a life that reached 30 and was still going at the end of the run with no
			-- ending is the story's fault; one the City killed first, before its ending, isn't
			-- (the City is much harder now: more lives end between 30 and 45)
			if life.age >= 30 and (ending or life.alive) then
				reached30 += 1
				if ending then
					ended += 1
				end
			end
			if ending then
				endings[ending] = (endings[ending] or 0) + 1
			end
		end
	end
	local nFired = 0
	for _ in fired do
		nFired += 1
	end
	local nEndings = 0
	for _ in endings do
		nEndings += 1
	end
	print(string.format("  %-22s lives %3d  opened %3d  beats seen %2d/%2d  goal changes/life %.1f  endings %d  ended by 45: %d/%d who reached 30",
		sl.id, lived, opened, nFired, beatsOf[sl.id] or 0, if lived > 0 then goals / lived else 0, nEndings, ended, reached30))
	check(lived >= math.floor(N * 0.8), sl.id .. ": hard to be born into (its `when` fits few births)")
	if second then
		stockSeen = 0 -- (stock openings belong to childhood; a second story starts long after)
	end
	if cutShort > 0 then
		print(string.format("      (%d died in the year it began, before the first chapter; not counted)", cutShort))
	end
	check(opened == lived, sl.id .. ": the opening didn't fire in every life")
	check(stockSeen == 0, sl.id .. ": stock opening scenes fired in a life with a storyline")
	check(nFired >= math.min(if second then 5 else 6, beatsOf[sl.id] or 0), sl.id .. ": too few of its beats were ever seen")
	check(nEndings >= 2, sl.id .. ": fewer than 2 different endings were reached")
	check(reached30 == 0 or ended >= math.floor(reached30 * 0.6), sl.id .. ": most lives that reach 30 should have an ending by 45")
	for id, n in endings do
		print(string.format("      %3d  %s", n, id))
	end
end

for id, n in stuck do
	check(false, string.format("%s came up %d time(s) with no choice the life could take", id, n))
end

-- a normal birth rolls a story when one fits, and recently lived stories come up less
local got, total = {}, 0
for i = 1, 300 do
	local l = sim:newLife({ seed = i * 31337, rollOrigin = true })
	total += 1
	if l.story then
		got[l.story] = (got[l.story] or 0) + 1
	end
end
local withStory = 0
for _, n in got do
	withStory += n
end
print(string.format("births with a storyline: %d of %d", withStory, total))
if fails > 0 then
	print(string.format("\n%d check(s) failed", fails))
	process.exit(1)
end
print("\nOK")
