-- probe: play one second story like story_check does, and trace lives that reach 30 without an ending
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local SL = process.args[1] or "sl2_changing"
local N = tonumber(process.args[2]) or 40
local sim = Engine.Sim.new(pack)
local rngState = tonumber(process.args[3]) or 12345
local function rnd(a, b)
	rngState = (rngState * 48271) % 2147483647
	return a + (rngState % (b - a + 1))
end
local sl
for _, s in pack.storylines do
	if s.id == SL then
		sl = s
	end
end
local reached, ended = 0, 0
for i = 1, N do
	local life
	for attempt = 1, 60 do
		local l = sim:newLife({ seed = i * 7919 + attempt * 104729, rollOrigin = true })
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
		if l.alive and not l.pending then
			local w = sl.when or {}
			if w.district then
				l.district = w.district
			end
			if w.side then
				l.side = w.side
			end
			l.storyEnding = l.storyEnding or "left behind"
			l.storiesDone = { {}, {}, {}, {} }
			sim:beginStory(l, sl, sim.newReport())
			l.storyStart = l.age + 1
			life = l
			break
		end
	end
	if life then
		local trace = {}
		local startAge = life.age
		while life.alive and life.age < 45 do
			local before = life.age
			local r = Loader.ageUp(sim, life)
			if life.age ~= before + 1 and life.alive then
				table.insert(trace, string.format("[ageUp %d->%d %s battle=%s pending=%s]", before, life.age, tostring(r ~= nil), tostring(life.battle ~= nil), tostring(life.pending)))
			end
			local guard = 0
			while life.alive and life.pending and guard < 40 do
				guard += 1
				local ev = sim.eventsById[life.pending]
				if ev.story then
					table.insert(trace, string.format("%d:%s", life.age - (life.storyStart or 0), ev.id))
				end
				local v = sim:view(life)
				local open = {}
				for ci, c in v.pending.choices do
					if c.enabled then
						table.insert(open, ci)
					end
				end
				if #open == 0 then
					life.pending = nil
					break
				end
				local ci = open[rnd(1, #open)]
				local approach = if v.pending.choices[ci].clash then "steady" else nil
				if ev.story then
					table.insert(trace, "->" .. tostring(v.pending.choices[ci].label))
				end
				local rep = sim:choose(life, ci, approach)
				if not rep then
					table.insert(trace, "(choose nil)")
					life.pending = nil
				elseif rep.battle then
					table.insert(trace, "(battle)")
				end
			end
			if life.alive and not life.pending and life.stats.health < 40 then
				life.stats.health = math.min(100, life.stats.health + 20)
			end
		end
		local ending = if life.story == sl.id then life.storyEnding else nil
		for _, done in life.storiesDone or {} do
			if done.id == sl.id then
				ending = done.ending
			end
		end
		if life.age >= 30 then
			reached += 1
			if ending then
				ended += 1
			else
				print(string.format("life %d: start %d storyStart %s age %d alive %s story %s era %s", i, startAge, tostring(life.storyStart), life.age, tostring(life.alive), tostring(life.story), tostring(life.world and life.world.era)))
				print("   " .. table.concat(trace, " "))
			end
		end
	end
end
print(string.format("%s: ended %d of %d who reached 30", SL, ended, reached))
