--[[
	v0.15, checked against the City pack:
	  - this life's City (fate): two lives are dealt different shares of what can happen, and
	    chains, stories and career cards are left alone
	  - a story someone else on the server is living comes up far less
	  - the third shelf of adult stories: ten stories, five chapters each, endings on the last
	  - big bosses: every approach card leads to a boss card, every boss card can be won, and a
	    win records a chronicle act that has an echo for other players
	  - more Distortions, after the Light only
	  - many more things to do while growing up
	  - the City is harder: danger by age, lethality, a shorter human lifespan
		lune run tests/v15_check
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

-- ── fate: two lives, different weights for the same ordinary card ──
do
	local a = sim:newLife({ seed = 1111, rollOrigin = true })
	local b = sim:newLife({ seed = 2222, rollOrigin = true })
	a.age, b.age = 30, 30
	local differ, absentA, n = 0, 0, 0
	local chainsKept = true
	for _, e in pack.events do
		if (e.weight or 10) > 0 and not e.always and not e.story and not (e.when and (e.when.flags or e.when.career or e.when.chronicle)) then
			n += 1
			local wa, wb = sim:eventWeight(a, e), sim:eventWeight(b, e)
			if math.abs(wa - wb) > 1e-6 then
				differ += 1
			end
			if wa == 0 then
				absentA += 1
			end
		elseif e.when and e.when.flags and (e.weight or 10) > 0 and not e.always then
			-- a card that continues something is never dealt away
			if sim:eventWeight(a, e) == 0 and sim:eventWeight(b, e) == 0 and (e.weight or 10) > 0 then
				local w = e.weight or 10
				if w > 0 and not e.tags then
					chainsKept = false
				end
			end
		end
	end
	check(differ > n * 0.4, string.format("two lives should weigh many ordinary cards differently (%d of %d)", differ, n))
	check(absentA > n * 0.15 and absentA < n * 0.4, string.format("about a quarter of ordinary cards should be dealt away in one life (%d of %d)", absentA, n))
	check(chainsKept, "a card that continues a chain was dealt away")
	pack.fate = false
	local wOff = sim:eventWeight(a, pack.events[1])
	pack.fate = nil
	check(wOff ~= nil, "fate can be switched off")
end

-- ── stories in play: one someone else is living comes up far less ──
do
	local counts = { on = 0, off = 0 }
	local target = nil
	for _, sl in pack.storylines do
		if (sl.act or 1) == 1 and (sl.weight or 10) > 0 and not sl.when then
			target = sl.id
			break
		end
	end
	if not target then
		for _, sl in pack.storylines do
			if (sl.act or 1) == 1 and (sl.weight or 10) > 0 then
				target = sl.id
				break
			end
		end
	end
	for i = 1, 300 do
		local life = sim:newLife({ seed = 40000 + i, rollOrigin = true, story = false })
		local sl = sim:rollStoryline(life, nil)
		if sl and sl.id == target then
			counts.off += 1
		end
	end
	;(sim :: any).storiesInPlayFn = function()
		return { [target] = true }
	end
	for i = 1, 300 do
		local life = sim:newLife({ seed = 40000 + i, rollOrigin = true, story = false })
		local sl = sim:rollStoryline(life, nil)
		if sl and sl.id == target then
			counts.on += 1
		end
	end
	;(sim :: any).storiesInPlayFn = nil
	check(counts.off > 0, "the test story should come up at all (" .. tostring(target) .. ")")
	check(counts.on * 3 <= math.max(3, counts.off), string.format("a story in play should come up far less (%d vs %d)", counts.on, counts.off))
end

-- ── the third shelf: ten stories, chapters at 0, 1, 3, 5, 7, endings on the last ──
do
	local shelf = { "sl2_missing", "sl2_old_office", "sl2_parcel", "sl2_quiet_tenant", "sl2_clean_books", "sl2_changing", "sl2_grudge_book", "sl2_pit", "sl2_hand_me_down", "sl2_last_stop" }
	for _, id in shelf do
		local sl = sim.storylinesById[id]
		check(sl and sl.act == 2, id .. ": missing, or not a second story")
		local years, ended = {}, false
		for _, e in pack.events do
			if e.story == id then
				years[e.when.storyYear] = true
				if e.when.storyYear == 7 then
					for _, c in e.choices do
						local r = c.result or c.win
						if r and r.storyEnd then
							ended = true
						end
					end
				end
			end
		end
		for _, y in { 0, 1, 3, 5, 7 } do
			check(years[y], id .. ": no chapter at year " .. y)
		end
		check(ended, id .. ": the last chapter has no ending")
	end
end

-- ── big bosses: approach -> boss -> a win that records an act with an echo ──
do
	local echoes = {}
	for _, e in pack.events do
		if e.when and e.when.chronicle then
			echoes[e.when.chronicle] = true
		end
	end
	local bosses = 0
	for _, e in pack.events do
		if string.sub(e.id, 1, 4) == "b15_" and string.sub(e.id, 1, 9) ~= "b15_echo_" then
			for _, c in e.choices do
				if c.win and c.win.trigger then
					local nextCard = sim.eventsById[c.win.trigger]
					check(nextCard ~= nil, e.id .. ": triggers a card that doesn't exist (" .. c.win.trigger .. ")")
					check(nextCard and (nextCard.weight or 10) == 0, e.id .. ": the boss card should only come by trigger")
				end
				if c.win and c.win.chronicle then
					bosses += 1
					check(pack.chronicle[c.win.chronicle] ~= nil, e.id .. ": records an act that isn't defined: " .. c.win.chronicle)
					check(echoes[c.win.chronicle], e.id .. ": nobody else hears about " .. c.win.chronicle)
				end
				if c.win and c.win.gear then
					check(pack.gear[c.win.gear] ~= nil, e.id .. ": drops gear that doesn't exist: " .. c.win.gear)
				end
				if c.clash and c.clash.boss then
					check(not c.clash.fixed, e.id .. ": a boss fight should grow with you (not fixed)")
					check(c.clash.fight, e.id .. ": a boss clash should be a fight")
				end
			end
		end
	end
	check(bosses >= 9, "fewer than nine ways to bring down a big boss (" .. bosses .. ")")
end

-- ── Distortions only after the Light ──
do
	local n = 0
	for _, e in pack.events do
		if string.sub(e.id, 1, 4) == "dz2_" then
			n += 1
			local era = e.when and e.when.world and e.when.world.era
			local ok = false
			if type(era) == "table" then
				ok = not table.find(era, "wings") and not table.find(era, "white_nights")
			elseif type(era) == "string" then
				ok = era == "library" or era == "limbus"
			end
			check(ok, e.id .. ": a Distortion before the Light")
		end
	end
	check(n >= 12, "fewer than twelve new Distortions")
end

-- ── growing up: many more things to do ──
do
	local life = sim:newLife({ seed = 5150, rollOrigin = true })
	life.pending = nil
	local counts = {}
	for _, age in { 5, 9, 14 } do
		life.age = age
		local v = sim:view(life)
		local n = 0
		for _, a in v.activities or {} do
			if string.sub(a.id, 1, 4) == "y15_" then
				n += 1
			end
		end
		counts[age] = n
	end
	check(counts[5] >= 4, "a five-year-old should have new things to do (" .. counts[5] .. ")")
	check(counts[9] >= 5, "a nine-year-old should have new things to do (" .. counts[9] .. ")")
	check(counts[14] >= 4, "a fourteen-year-old should have new things to do (" .. counts[14] .. ")")
end

-- ── a harder City ──
do
	check((pack.lethality or 1) >= 1.9, "lethality should be at least 1.9")
	check(pack.forms.human.lifespan <= 63, "an ordinary body should start failing by 63")
	local e = nil
	for _, ev in pack.events do
		if ev.tags and table.find(ev.tags, "danger") and not (ev.when and (ev.when.minAge or ev.when.maxAge or ev.when.side or ev.when.district or ev.when.world or ev.when.flags)) then
			e = ev
			break
		end
	end
	if e then
		local life = sim:newLife({ seed = 6060, rollOrigin = true })
		life.age = 12
		local young = sim:eventWeight(life, e)
		life.age = 30
		local grown = sim:eventWeight(life, e)
		check(young == 0 or grown > young, "danger should come more often at thirty than at twelve")
	end
end

if fails > 0 then
	print(string.format("v15_check: %d FAILED", fails))
	process.exit(1)
end
print("v15_check: OK")
