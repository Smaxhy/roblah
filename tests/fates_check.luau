--[[
	BITLEVELING FATES CHECKS (Fates.luau, Engine/HunterWorld.fateOf, the Saga_* arcs).
		lune run tests/fates_check [lives]
	  1. there are 40 fates, ids unique, exactly one fallback (priority 0, no conditions)
	  2. every flag a fate needs is set by some card (or by the engine), so it can be reached
	  3. every non-canon fate needs the kept world line (directly, or through flags only cards
	     on that line set), and says "non-canon"
	  4. a life that dies with a fate's flags gets that fate: the death screen says it first,
	     the record (lantern) is titled with it and carries its epitaph
	  5. random lives all end with a fate; how many different ones random play finds
	Exit code 1 on any failure.
]]

local process = require("@lune/process")
local Loader = require("./loader")

process.env.LIFESIM_PACK = "BitLeveling"
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local HW = Engine.HunterWorld
local Rng = Engine.Rng
local sim = Engine.new(pack)

local N = tonumber(process.args[1]) or 60
local failures = 0
local function check(ok: boolean, msg: string)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		failures += 1
	end
end

local fates = HW.fatesOf(pack)
check(#fates == 40, string.format("there are 40 fates (%d)", #fates))
local ids, fallbacks = {}, 0
for _, f in fates do
	check(ids[f.id] == nil, "fate id " .. f.id .. " is unique")
	ids[f.id] = true
	if (f.priority or 0) == 0 and (f.when == nil or next(f.when) == nil) and f.cause == nil then
		fallbacks += 1
	end
	assert(type(f.name) == "string" and type(f.desc) == "string" and type(f.hint) == "string", f.id .. " is missing text")
end
check(fallbacks == 1, "exactly one fallback fate")

-- every flag set anywhere in the pack's cards (results, wins, losses, flees)
local setBy: { [string]: { string } } = {}
local function scanResult(r: any, where: string)
	if type(r) ~= "table" then
		return
	end
	for _, flag in r.setFlags or {} do
		setBy[flag] = setBy[flag] or {}
		table.insert(setBy[flag], where)
	end
end
for _, e in pack.events do
	scanResult(e.result, e.id)
	for i, c in e.choices or {} do
		local where = e.id .. "#" .. i
		scanResult(c.result, where)
		scanResult(c.win, where)
		scanResult(c.lose, where)
		scanResult(c.fled, where)
	end
end
for _, a in pack.activities or {} do
	scanResult(a.result, a.id)
end
local ENGINE_FLAGS = { world_rewritten = true, world_line_kept = true, licensed = true, awakened = true, reawakened = true }
local unreachable = {}
for _, f in fates do
	for _, flag in (f.when and f.when.flags) or {} do
		if not ENGINE_FLAGS[flag] and not setBy[flag] then
			table.insert(unreachable, f.id .. " needs " .. flag)
		end
	end
end
check(#unreachable == 0, "every flag a fate needs is set by a card or the engine" .. (if #unreachable > 0 then ": " .. table.concat(unreachable, "; ") else ""))

-- non-canon fates: labelled, and only on the kept line. A flag is on the kept line when every
-- card that sets it needs world_line_kept, or needs a flag that is itself on the kept line.
local cardsOf: { [string]: { any } } = {}
for flag, wheres in setBy do
	cardsOf[flag] = {}
	for _, where in wheres do
		local id = string.match(where, "^([^#]+)")
		table.insert(cardsOf[flag], sim.eventsById[id] or false)
	end
end
local memo: { [string]: boolean } = {}
local function keptFlag(flag: string, depth: number): boolean
	if flag == "world_line_kept" then
		return true
	end
	if memo[flag] ~= nil then
		return memo[flag]
	end
	if depth > 12 or not cardsOf[flag] then
		return false
	end
	memo[flag] = false -- (cycles count as not proven)
	local all = true
	for _, card in cardsOf[flag] do
		local ok = false
		for _, cf in (card and card.when and card.when.flags) or {} do
			if keptFlag(cf, depth + 1) then
				ok = true
			end
		end
		if not ok then
			all = false
		end
	end
	memo[flag] = all
	return all
end
local badNc = {}
for _, f in fates do
	if f.canon == false then
		local text = string.lower(f.desc .. " " .. f.hint)
		if not string.find(text, "non-canon", 1, true) then
			table.insert(badNc, f.id .. " doesn't say non-canon")
		end
		local gated = false
		for _, flag in (f.when and f.when.flags) or {} do
			if keptFlag(flag, 0) then
				gated = true
			end
		end
		if not gated then
			table.insert(badNc, f.id .. " isn't gated on the kept world line")
		end
	end
end
check(#badNc == 0, "non-canon fates say so and need the kept world line" .. (if #badNc > 0 then ": " .. table.concat(badNc, "; ") else ""))

-- a life with a fate's flags dies into that fate (unless a higher one also fits)
local wrong = {}
for i, f in fates do
	local life = sim:newLife({ seed = 300 + i, difficulty = "normal" })
	life.age = (f.when and (f.when.maxAge or f.when.minAge)) or 40
	life.year = math.max(life.year, (f.when and f.when.minYear) or 0)
	for _, flag in (f.when and f.when.flags) or {} do
		life.flags[flag] = true
	end
	local w = f.when or {}
	if type(w.form) == "string" then
		life.form = w.form
	elseif type(w.form) == "table" then
		life.form = w.form[#w.form]
	end
	for k, v in w.min or {} do
		if k == "money" then
			life.money = v + 1
		else
			life.stats[k] = v + 1
		end
	end
	if w.career then
		life.career = { id = w.career, rank = 1, years = 1 }
	end
	sim:kill(life, nil, f.cause and ("Died: " .. f.cause) or "Died in their sleep")
	local got = life.fate and sim.fatesById[life.fate]
	if not got then
		table.insert(wrong, f.id .. " -> nothing")
	elseif got.id ~= f.id and (got.priority or 0) <= (f.priority or 0) then
		table.insert(wrong, f.id .. " -> " .. got.id)
	end
	if got and got.id == f.id and (f.priority or 0) > 0 then
		local lantern = sim:lantern(life)
		if lantern.title ~= f.name or lantern.fate ~= f.id then
			table.insert(wrong, f.id .. ": the record isn't titled with it")
		end
		if not (life.death and life.death.lines[1] and string.find(life.death.lines[1], f.name, 1, true)) then
			table.insert(wrong, f.id .. ": the death screen doesn't say it first")
		end
	end
end
check(#wrong == 0, "a life with a fate's conditions dies into it, and the death screen and record say so" .. (if #wrong > 0 then ": " .. table.concat(wrong, "; ") else ""))

-- random lives: every one ends with a fate
local seen, none = {}, 0
local function answer(life)
	local g = 0
	while life.alive and life.pending and g < 30 do
		g += 1
		local ev = sim.eventsById[life.pending]
		local open = {}
		for i, c in (ev and ev.choices) or {} do
			if Engine.Conditions.check(c.requires, life, pack, { noChance = true }) then
				table.insert(open, i)
			end
		end
		if #open == 0 then
			life.pending = nil
			break
		end
		sim:choose(life, open[Rng.int(life, 1, #open)], nil)
		local turns = 0
		while life.battle and turns < 60 do
			turns += 1
			local key = tostring(life.id)
			Engine.Battle.act(sim, life, { [key] = life }, key, "flee")
		end
	end
end
for i = 1, N do
	local life = sim:newLife({ seed = 11000 + i * 7, difficulty = if i % 2 == 0 then "crisis" else "normal" })
	local guard = 0
	while life.alive and guard < 130 do
		guard += 1
		answer(life)
		if life.alive then
			sim:ageUp(life)
		end
	end
	if life.fate then
		seen[life.fate] = (seen[life.fate] or 0) + 1
	else
		none += 1
	end
end
local kinds = {}
for id, n in seen do
	table.insert(kinds, id .. " " .. n)
end
table.sort(kinds)
print("  random play found " .. #kinds .. " fates: " .. table.concat(kinds, ", "))
check(none == 0, "every random life ends with a fate")
check(#kinds >= 3, "random play alone reaches several fates")

if failures > 0 then
	print(string.format("\n%d check(s) failed.", failures))
	process.exit(1)
end
print("\nEvery fate can be reached, and every life ends in one.")
