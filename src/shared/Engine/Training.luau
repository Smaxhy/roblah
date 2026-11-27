--[[
	TRAINERS (v0.17): people who teach you, later in life (City/Trainers.luau). The meeting
	cards (Events/Trainers.luau) and the lessons (Activities/Training.luau) are built from that
	list, so a trainer is one entry: who they are, who they'll take on, what they grow, and
	which techniques (City/Techniques.luau) they teach.

	  result.train = { find = true }            look for a teacher: one who'd take you on comes up
	  result.train = { start = id }             you're their student (one teacher at a time)
	  result.train = { lesson = id, hard = true? }
	                                            a lesson: the stat they teach grows, past 100 too
	                                            (a teacher is how a limit gets reached); at set
	                                            lessons they teach a technique; after the last,
	                                            limit courses raise your ceiling; then you're done
	  result.train = { leave = id }             you stop for now (you can find them again)

	life.training = { [id] = { lessons, limits, done } }; life.trainer is the one you're with,
	and the flag "tr_<id>" is set while you are (the lesson activity waits on it). A technique
	is a flag with the technique's id, which its approach requires.
]]

local Rng = require(script.Parent.Rng)
local Conditions = require(script.Parent.Conditions)

local Training = {}

function Training.def(sim: any, id: string?): any
	local t = sim.pack.trainers
	if not t or not id then
		return nil
	end
	return t.byId[id]
end

-- the teachers this life could find now: their `when` fits, they're not done with you, and
-- you're not already with them
function Training.available(sim: any, life: any): any
	local out = {}
	local t = sim.pack.trainers
	for _, def in (t and t.list) or {} do
		local st = life.training and life.training[def.id]
		local open = not (st and st.done) and life.trainer ~= def.id
		if open and (not def.when or Conditions.check(def.when, life, sim.pack, { noChance = true })) then
			table.insert(out, def)
		end
	end
	return out
end

-- a lesson's growth isn't slowed like everything else past 60: it only stops at the ceiling
local function raise(sim: any, life: any, key: string, n: number, deltas: any): number
	if life.stats[key] == nil or n == 0 then
		return 0
	end
	local before = life.stats[key]
	local cap = sim:statCap(life, key)
	life.stats[key] = math.max(before, math.min(before + n, cap))
	local real = life.stats[key] - before
	if real ~= 0 and deltas then
		deltas[key] = (deltas[key] or 0) + real
	end
	return real
end

-- how many lessons a course has: up to its last technique, then its limit courses
function Training.courseLength(def: any): (number, number)
	local lastAt = 0
	for _, tq in def.teaches or {} do
		lastAt = math.max(lastAt, tq.at)
	end
	local lim = def.limit
	local total = lastAt + (if lim then (lim.every or 3) * (lim.times or 0) else 0)
	return math.max(total, def.lessons or 0, 1), lastAt
end

local function techniqueName(sim: any, id: string): string
	local a = sim.pack.approaches and sim.pack.approaches[id]
	return if a then a.name else id
end

-- what's next with this teacher, in a few words ("Counter Stance at lesson 6")
function Training.nextUp(sim: any, def: any, st: any): string?
	local lessons = (st and st.lessons) or 0
	for _, tq in def.teaches or {} do
		if tq.at > lessons then
			return string.format("%s at lesson %d", techniqueName(sim, tq.id), tq.at)
		end
	end
	local total, lastAt = Training.courseLength(def)
	local lim = def.limit
	if lim and (st and st.limits or 0) < (lim.times or 0) then
		local every = lim.every or 3
		local nextAt = lastAt + every * (((st and st.limits) or 0) + 1)
		return string.format("a limit course at lesson %d (+%d to the ceiling)", nextAt, lim.per or 0)
	end
	if lessons < total then
		return string.format("done at lesson %d", total)
	end
	return nil
end

function Training.apply(sim: any, life: any, spec: any, extra: any, deltas: any)
	if type(spec) ~= "table" then
		return
	end
	life.training = life.training or {}
	life.flags = life.flags or {}

	if spec.find then
		local list = Training.available(sim, life)
		if #list == 0 then
			table.insert(extra, { kind = "system", text = "Nobody you found this year would take you on. Come back stronger, or try another District." })
			return
		end
		local def = Rng.pick(life, list)
		table.insert(life.queue, "tr_meet_" .. def.id)
		return
	end

	if spec.leave then
		local def = Training.def(sim, spec.leave)
		if def and life.trainer == def.id then
			life.trainer = nil
			life.flags["tr_" .. def.id] = nil
			table.insert(extra, { kind = "system", text = "You stopped training with " .. def.short .. ". What you learned stays. The door's open if you go back." })
		end
		return
	end

	if spec.start then
		local def = Training.def(sim, spec.start)
		if not def then
			return
		end
		-- one teacher at a time: the last one keeps your place
		if life.trainer and life.trainer ~= def.id then
			local old = Training.def(sim, life.trainer)
			life.flags["tr_" .. life.trainer] = nil
			if old then
				table.insert(extra, { kind = "system", text = "You left " .. old.short .. "'s lessons for " .. def.short .. "'s. " .. old.short .. " shrugged." })
			end
		end
		life.training[def.id] = life.training[def.id] or { lessons = 0, limits = 0 }
		life.trainer = def.id
		life.flags["tr_" .. def.id] = true
		local nextUp = Training.nextUp(sim, def, life.training[def.id])
		table.insert(extra, {
			kind = "system",
			tone = "good",
			text = string.format("%s will teach you. \"Train with %s\" is in your activities now: it grows your %s%s.", def.short, def.short, sim.pack.stats[def.stat].name, if nextUp then ", and next is " .. nextUp else ""),
		})
		sim:highlight(life, "Became " .. def.name .. "'s student at " .. life.age .. ".")
		return
	end

	if spec.lesson then
		local def = Training.def(sim, spec.lesson)
		local st = def and life.training[def.id]
		if not def or not st or st.done then
			return
		end
		st.lessons += 1
		local g = def.gain or { 3, 6 }
		local n = Rng.int(life, g[1], g[2])
		if spec.hard then
			n = math.max(1, math.floor(n / 2))
		end
		raise(sim, life, def.stat, n, deltas)
		for key, v in def.also or {} do
			local m = if type(v) == "table" then Rng.int(life, v[1], v[2]) else v
			raise(sim, life, key, m, deltas)
		end
		-- a technique, at its lesson
		for _, tq in def.teaches or {} do
			if st.lessons == tq.at and not life.flags[tq.id] then
				life.flags[tq.id] = true
				local name = techniqueName(sim, tq.id)
				table.insert(extra, { kind = "system", tone = "good", text = string.format("%s taught you %s. It's a way of fighting now: pick it when a fight starts.", def.short, name) })
				sim:highlight(life, "Learned " .. name .. " from " .. def.name .. ".")
			end
		end
		-- a limit course: after the last technique, every few lessons
		local total, lastAt = Training.courseLength(def)
		local lim = def.limit
		if lim and st.lessons > lastAt and (st.lessons - lastAt) % (lim.every or 3) == 0 and (st.limits or 0) < (lim.times or 0) then
			st.limits = (st.limits or 0) + 1
			life.capBonus = life.capBonus or {}
			life.capBonus[def.stat] = (life.capBonus[def.stat] or 0) + (lim.per or 0)
			raise(sim, life, def.stat, math.floor((lim.per or 0) / 2), deltas)
			table.insert(extra, {
				kind = "system",
				tone = "good",
				text = string.format("%s broke a limit: your %s can go %d further than it could. (%d of %d)", def.short, sim.pack.stats[def.stat].name, lim.per or 0, st.limits, lim.times or 0),
			})
		end
		if st.lessons >= total then
			st.done = true
			life.trainer = nil
			life.flags["tr_" .. def.id] = nil
			life.flags["tr_" .. def.id .. "_done"] = true
			table.insert(extra, { kind = "system", tone = "good", text = def.farewell or (def.short .. " has nothing left to teach you.") })
			sim:highlight(life, "Finished training with " .. def.name .. ".")
		else
			local nextUp = Training.nextUp(sim, def, st)
			table.insert(extra, { kind = "system", text = string.format("Lesson %d of %d with %s.%s", st.lessons, total, def.short, if nextUp then " Next: " .. nextUp .. "." else "") })
		end
	end
end

-- for the screen: who you're training with, and how far along
function Training.view(sim: any, life: any): any
	local def = Training.def(sim, life.trainer)
	if not def then
		return nil
	end
	local st = life.training and life.training[def.id] or { lessons = 0 }
	local total = Training.courseLength(def)
	return {
		id = def.id,
		name = def.name,
		role = def.role,
		stat = def.stat,
		lessons = st.lessons or 0,
		total = total,
		nextUp = Training.nextUp(sim, def, st),
	}
end

return Training
