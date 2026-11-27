--[[
	Era audit: nothing in a life may mention something that doesn't exist in its time.
	The City's timeline (pack.world "era"): wings (L Corp runs) -> white_nights -> library -> limbus.
	For every event, activity, expedition stage, hazard and daily event this collects the text a
	player can read and checks it against words that only make sense in some eras. An entry
	passes if its conditions already keep it to those eras (its own `when`, or a career, flag or
	trait that only exists there).
		lune run tests/era_check            (summary, fails on any violation)
		lune run tests/era_check list       (every violation)
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local LIST = process.args[1] == "list"

local ORDER = { "wings", "white_nights", "library", "limbus" }
local ALL = { wings = true, white_nights = true, library = true, limbus = true }
local function set(...)
	local s = {}
	for _, e in { ... } do
		s[e] = true
	end
	return s
end
-- word groups: where each may appear
local RULES = pack.eraRules or {}

local function textOf(t, out, depth)
	depth = depth or 0
	if depth > 8 then
		return
	end
	for k, v in t do
		if type(v) == "string" then
			if k == "title" or k == "text" or k == "label" or k == "log" or k == "line" or k == "name" or k == "desc" or k == "hint" or k == "goal" or k == "storyEnd" or k == "cause" or k == "foe" then
				table.insert(out, v)
			end
		elseif type(v) == "table" and (k == "title" or k == "text" or k == "label" or k == "log" or k == "line" or k == "goal") and type(v[1]) == "string" then
			-- a line written several ways: every way it can read
			for _, one in v do
				if type(one) == "string" then
					table.insert(out, one)
				end
			end
		elseif type(v) == "table" and k ~= "when" and k ~= "requires" then
			textOf(v, out, depth + 1)
		end
	end
end

-- the eras an entry can happen in, from its conditions
local function erasOf(cond, extra)
	local eras = table.clone(ALL)
	local function narrow(allowed)
		for e in eras do
			if not allowed[e] then
				eras[e] = nil
			end
		end
	end
	if cond then
		local w = cond.world and cond.world.era
		if w then
			local allowed = {}
			for _, e in (if type(w) == "table" then w else { w }) do
				allowed[e] = true
			end
			narrow(allowed)
		end
		local notW = cond.notWorld and cond.notWorld.era
		if notW then
			for _, e in (if type(notW) == "table" then notW else { notW }) do
				eras[e] = nil
			end
		end
		-- careers, flags and traits that only exist in some eras (pack.eraBound)
		local bound = pack.eraBound or {}
		local function viaList(list, map)
			if not list or not map then
				return
			end
			local allowed = {}
			local any = false
			for _, id in (if type(list) == "table" then list else { list }) do
				local e = map[id]
				if e then
					any = true
					for _, x in e do
						allowed[x] = true
					end
				else
					return -- one unbound option: no narrowing
				end
			end
			if any then
				narrow(allowed)
			end
		end
		viaList(cond.career, bound.careers)
		if cond.flags then
			for _, f in cond.flags do
				local e = bound.flags and bound.flags[f]
				if e then
					local allowed = {}
					for _, x in e do
						allowed[x] = true
					end
					narrow(allowed)
				end
			end
		end
		viaList(cond.trait, bound.traits)
		viaList(cond.form, bound.forms)
		-- a server-wide world event or today's event only reaches lives in its own eras
		if cond.worldEvent then
			local allowed, any = {}, false
			for _, id in (if type(cond.worldEvent) == "table" then cond.worldEvent else { cond.worldEvent }) do
				local def = pack.worldEvents and pack.worldEvents[id]
				local w = def and def.when and def.when.world and def.when.world.era
				if w then
					any = true
					for _, x in (if type(w) == "table" then w else { w }) do
						allowed[x] = true
					end
				else
					any = false
					break
				end
			end
			if any then
				narrow(allowed)
			end
		end
	end
	return eras
end

local violations = {}
local counts = {}
local reviewed = pack.eraReviewed or {}
local function check(kind, id, file, cond, node, eras)
	if reviewed[id] then
		return
	end
	eras = eras or erasOf(cond)
	local parts = {}
	textOf(node, parts)
	local blob = table.concat(parts, " \n ")
	for _, rule in RULES do
		local hit = nil
		for _, w in rule.words do
			-- whole words only ("the Light", not "the Lights"); a plural s is fine
			local from = 1
			while true do
				local s, e = string.find(blob, w, from, true)
				if not s then
					break
				end
				local after = string.sub(blob, e + 1, e + 1)
				local after2 = string.sub(blob, e + 2, e + 2)
				if not string.match(after, "%a") or (after == "s" and not string.match(after2, "%a")) then
					hit = w
					break
				end
				from = e + 1
			end
			if hit then
				break
			end
		end
		-- a mention that reads as a memory or a ruin is fine anywhere (rule.unless)
		if hit and rule.unless then
			for _, m in rule.unless do
				if string.find(blob, m, 1, true) then
					hit = nil
					break
				end
			end
		end
		if hit then
			local bad = {}
			for _, e in ORDER do
				if eras[e] and not table.find(rule.eras, e) then
					table.insert(bad, e)
				end
			end
			if #bad > 0 then
				-- the sentence around the word, for whoever reviews it
				local at = string.find(blob, hit, 1, true) or 1
				local from = math.max(1, at - 70)
				local ctx = string.gsub(string.sub(blob, from, at + 80), "%s+", " ")
				table.insert(violations, { kind = kind, id = id, file = file, rule = rule.id, word = hit, bad = table.concat(bad, ","), ctx = ctx })
				counts[rule.id] = (counts[rule.id] or 0) + 1
			end
		end
	end
end

-- today's events are queued by the daily activity: they carry the daily's eras
local dailyEras = {}
for _, id in (pack.daily and pack.daily.order) or {} do
	local d = pack.daily[id]
	if d.event and d.eras then
		dailyEras[d.event] = d.eras
	end
	local eras = table.clone(ALL)
	if d.eras then
		eras = {}
		for _, x in d.eras do
			eras[x] = true
		end
	end
	check("daily", id, "daily", nil, { name = d.name, desc = d.desc }, eras)
end
-- a world event's opening scene reaches only the lives its `when` lets it reach
for _, id in (pack.worldEvents and pack.worldEvents.order) or {} do
	local def = pack.worldEvents[id]
	local w = def.when and def.when.world and def.when.world.era
	if def.startEvent and w then
		dailyEras[def.startEvent] = if type(w) == "table" then w else { w }
	end
end
for _, e in pack.events do
	local eras = erasOf(e.when)
	if dailyEras[e.id] then
		for x in eras do
			if not table.find(dailyEras[e.id], x) then
				eras[x] = nil
			end
		end
	end
	check("event", e.id, e.source or "?", e.when, e, eras)
end
for _, a in pack.activities do
	-- a book can only be read by someone who found it, and finding it is an event (checked above)
	if string.sub(a.id, 1, 5) ~= "read_" then
		check("activity", a.id, "activities", a.when, a)
	end
end
for _, h in (pack.hazards and pack.hazards.list) or pack.hazards or {} do
	if type(h) == "table" and h.id then
		check("hazard", h.id, "hazards", h.when, h)
	end
end
for _, id in (pack.expeditions and pack.expeditions.order) or {} do
	local ex = pack.expeditions[id]
	check("expedition", id, "expeditions", ex.when or ex.requires, ex)
end
for _, id in (pack.careers and pack.careers.order) or {} do
	local c = pack.careers[id]
	check("career", id, "careers", c.requires, c)
end
for _, sl in pack.storylines or {} do
	check("storyline", sl.id, "storylines", sl.when, sl)
end
-- (v0.12) what the markets sell, and the homes for sale (a good passes on its own `when`)
for _, id in (pack.markets and pack.markets.order) or {} do
	local m = pack.markets[id]
	check("market", id, "markets", m.when, { name = m.name, desc = m.desc, keeper = m.keeper })
	for _, g in m.goods or {} do
		check("market good", g.id, "markets", g.when, g)
	end
end
for _, id in (pack.homes and pack.homes.order) or {} do
	local h = pack.homes[id]
	local sold = nil
	for _, mid in (pack.markets and pack.markets.order) or {} do
		for _, g in pack.markets[mid].goods or {} do
			if g.result and g.result.home == id then
				sold = g.when
			end
		end
	end
	check("home", id, "markets", sold, h)
end
-- "Who you know of": a faction that only exists in some ages says so (gate.eras)
for _, g in pack.storyGates or {} do
	if g.flag and g.name then
		if g.after and g.after.eras then
			-- what it was (every age it exists in, before `after`), and what became of it
			local before = {}
			for _, e in g.eras or ORDER do
				if not table.find(g.after.eras, e) then
					table.insert(before, e)
				end
			end
			check("known", g.flag, "storyGates", { world = { era = before } }, { name = g.name, desc = g.blurb })
			check("known", g.flag .. " (after)", "storyGates", { world = { era = g.after.eras } }, { name = g.name, desc = g.after.blurb or g.blurb })
		else
			check("known", g.flag, "storyGates", if g.eras then { world = { era = g.eras } } else nil, { name = g.name, desc = g.blurb })
		end
	end
end

table.sort(violations, function(a, b)
	if a.rule ~= b.rule then
		return a.rule < b.rule
	end
	return a.id < b.id
end)
print(string.format("era audit: %d entries checked against %d rules", #pack.events + #pack.activities, #RULES))
for rule, n in counts do
	print(string.format("  %-14s %d", rule, n))
end
if LIST then
	for _, v in violations do
		print(string.format("  %-10s %-34s %-18s [%s] '%s' can happen in: %s\n      ...%s...", v.kind, v.id, v.file, v.rule, v.word, v.bad, v.ctx))
	end
end
if #violations > 0 then
	print(string.format("FAIL: %d places mention something outside its era", #violations))
	process.exit(1)
end
print("OK: every mention fits its era")
