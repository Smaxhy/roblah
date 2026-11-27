--[[
	v0.12, checked against the City pack:
	  - a card that can't be answered never holds a life (an event removed by an update, or
	    one whose every choice has closed): "decide first" always has something to decide
	  - linked friends: one friend is one entry (older saves that hold them twice are mended),
	    and what you do with them happens in their life too: the same change to the bond on
	    both sides, what the scene gives them, and a line in their feed saying what it was
		lune run tests/v12_check
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

local function settled(seed: number, age: number?)
	local life = sim:newLife({ seed = seed, rollOrigin = true })
	local guard = 0
	while life.alive and guard < 3000 do
		guard += 1
		if life.pending then
			local v = sim:view(life)
			local pick = nil
			for _, c in v.pending.choices do
				if c.enabled then
					pick = c.index
					break
				end
			end
			if not pick or not sim:choose(life, pick, nil) then
				life.pending = nil
			end
		elseif life.age >= (age or 0) then
			break
		else
			Loader.ageUp(sim, life)
		end
	end
	return life
end

-- a life that got as far as `age` (the City doesn't promise it; try seeds until one does)
local function survivor(seed: number, age: number)
	for n = 0, 30 do
		local life = settled(seed + n * 101, age)
		if life.alive and not life.pending and life.age >= age then
			return life
		end
	end
	error("no life reached " .. age)
end

-- ── a card that can't be answered ──
do
	local life = survivor(21, 16)
	-- a life saved while waiting on an event that an update has since removed
	life.pending = "an_event_that_no_longer_exists"
	local ok, v = pcall(function()
		return sim:view(life)
	end)
	check(ok, "viewing a life that waits on a removed event doesn't fail")
	check(ok and v.pending == nil and life.pending == nil, "and the card it can't show is let go")
	local report = Loader.ageUp(sim, life)
	check(report ~= nil, "the year can turn again afterwards")
	-- a card whose every choice has closed
	local life2 = survivor(22, 16)
	local closed = nil
	for _, e in pack.events do
		if e.choices then
			local all = true
			for _, c in e.choices do
				if not (c.requires and c.requires.minMoney) then
					all = false
				end
			end
			if all then
				closed = e
				break
			end
		end
	end
	if closed then
		life2.money = -5
		life2.pending = closed.id
		local v2 = sim:view(life2)
		check(v2.pending == nil and life2.pending == nil, "a card with no open choice is let go (" .. closed.id .. ")")
	end
	-- answering "nothing" doesn't leave a ghost behind
	local life3 = survivor(23, 16)
	life3.pending = "gone_too"
	local r, why = sim:choose(life3, 1, nil)
	check(r == nil and why ~= nil and life3.pending == nil, "choosing on a removed card clears it")
end

-- ── linked friends ──
do
	local a, b = survivor(31, 18), survivor(32, 18)
	check(a.alive and b.alive and not a.pending and not b.pending, "two settled lives to link")
	local function link(life, other, userId)
		return sim:linkFriend(life, { userId = userId, first = other.first, last = other.last, age = other.age, online = true, player = "P" .. userId, appearance = sim:appearance(other) })
	end
	local relB = link(a, b, 2) -- Bo, in Ann's life
	local relA = link(b, a, 1) -- Ann, in Bo's life
	-- an older save with the same friend in it twice
	table.insert(a.relations, { id = a.nextRelId, kind = "friend", first = b.first, last = b.last, age = b.age, bond = 71, alive = true, userId = 2, online = true })
	a.nextRelId += 1
	relB = link(a, b, 2)
	local count = 0
	for _, r in a.relations do
		if r.userId == 2 then
			count += 1
		end
	end
	check(count == 1, "a friend held twice is mended to one entry (found " .. count .. ")")
	check(relB.bond == 71, "and the closer of the two bonds is the one kept")
	relB.bond, relA.bond = 60, 60

	-- everything Ann can do with Bo, done; each time Bo's side is told and agrees on the bond
	local did, mirrored, said = 0, 0, 0
	for round = 1, 40 do
		local c = a
		c.rng = Engine.Rng.seed(500 + round * 13)
		c.socialLeft, c.money = 3, 500
		relB.talked = nil
		relB.scenes = nil
		relB.bond, relA.bond = 60, 60
		local id = if round % 5 == 0 then "send_word" else "spend_time"
		local report = sim:interact(c, relB.id, id)
		if report and c.pending then
			local v = sim:view(c)
			local picks = {}
			for _, ch in v.pending.choices do
				if ch.enabled then
					table.insert(picks, ch)
				end
			end
			local ch = picks[(round % #picks) + 1]
			local way = nil
			if ch.clash and ch.clash.approaches and #ch.clash.approaches > 0 then
				way = ch.clash.approaches[(round % #ch.clash.approaches) + 1].id
			end
			report = sim:choose(c, ch.index, way)
		end
		if report then
			did += 1
			local moved = relB.bond - 60
			local sent = nil
			for _, msg in report.outbox do
				if msg.userId == 2 then
					check(sent == nil, "one thing done is one message to the friend, not two")
					sent = msg
				end
			end
			if moved ~= 0 then
				check(sent ~= nil, "a bond that moved with a linked friend is sent to them (round " .. round .. ")")
			end
			if sent then
				local healthBefore, sanityBefore = b.stats[sim.vital], b.sanity
				local got = sim:applyLinked(b, sent.result, sent.from, { userId = 1, title = sent.title, choice = sent.choice })
				mirrored += 1
				check(relA.bond - 60 == moved, string.format("both sides agree on the bond (theirs moved %d, mine %d; round %d)", relA.bond - 60, moved, round))
				check(b.stats[sim.vital] >= healthBefore and b.sanity >= sanityBefore, "what a friend does for you never costs you health or Sanity")
				local header, line = false, false
				for _, e in got.entries do
					if e.kind == "event" and e.title and e.choice and string.find(e.choice, a.first, 1, true) then
						header = true
					elseif e.kind == "log" and type(e.text) == "string" and e.text ~= "" then
						line = true
						check(not string.find(e.text, "{", 1, true), "their line has no unfilled words in it: " .. e.text)
						if string.find(e.text, a.first, 1, true) then
							said += 1
						end
					end
				end
				check(header and line, "their feed says what it was and who did it (round " .. round .. ")")
				check(#got.outbox == 0, "what lands on the friend doesn't bounce back")
				if b.pending then
					b.pending = nil
				end
			end
			if c.pending then
				c.pending = nil
			end
		end
	end
	check(did >= 30 and mirrored >= 30, string.format("evenings with a linked friend reached them (%d done, %d mirrored)", did, mirrored))
	check(said >= 20, "most of their lines name who it was (" .. said .. ")")
	-- with someone who isn't another player, nothing is sent anywhere
	local npc = nil
	for _, r in a.relations do
		if not r.userId and r.alive and r.kind ~= "friend" then
			npc = r
			break
		end
	end
	if npc then
		a.socialLeft = 3
		npc.talked = nil
		local report = sim:interact(a, npc.id, "spend_time")
		if report and a.pending then
			local v = sim:view(a)
			for _, ch in v.pending.choices do
				if ch.enabled and not ch.clash then
					report = sim:choose(a, ch.index, nil)
					break
				end
			end
		end
		check(report ~= nil and #report.outbox == 0, "an evening with family sends nothing to other players")
	end
end

-- ── books and scrolls: bought, shown, read ──
do
	local life = survivor(41, 20)
	life.books = nil
	local open, closed = nil, nil
	for _, id in pack.books.order do
		local def = pack.books[id]
		if def.trait and not def.schools and not open then
			open = id
		elseif def.trait and def.schools and not closed and not (life.school and table.find(def.schools, life.school)) then
			closed = id
		end
	end
	check(open ~= nil and closed ~= nil, "the pack has a book anyone can read and one written for a discipline")
	if open and closed then
		-- the card that sells one says what you'd be getting, and whether you could follow it
		local chips = sim:stakesOf({ money = -650, book = closed }, nil, nil, life, nil)
		local said = false
		for _, c in chips do
			if c.key == "book" and c.text and string.find(c.text, "needs", 1, true) then
				said = true
			end
		end
		check(said, "a scroll written for another discipline says so before you buy it")
		local Effects = Engine.Effects
		local report = sim.newReport()
		Effects.apply(sim, life, { book = open, log = "Bought." }, report)
		Effects.apply(sim, life, { book = closed, log = "Bought." }, report)
		local v = sim:view(life)
		check(v.books and #v.books == 2, "both are on the shelf the screen shows (" .. tostring(v.books and #v.books) .. ")")
		local byId = {}
		for _, b in v.books or {} do
			byId[b.id] = b
		end
		local a, b = byId[open], byId[closed]
		check(a and a.teaches ~= nil and a.activity ~= nil, "a book says what it teaches and has a way to be read")
		check(b and b.trained == false and b.needs ~= nil and b.canRead == false and b.reason ~= nil and string.find(b.reason, "training", 1, true), "a scroll you can't follow says which training it needs")
		-- reading the one you can: it leaves the shelf and you know the thing
		life.actionsLeft = 3
		life.pending = nil
		v = sim:view(life)
		local can = false
		for _, bk in v.books do
			if bk.id == open then
				can = bk.canRead
			end
		end
		check(can, "a book anyone can read is readable with an action in hand")
		local traitsBefore = #life.traits
		local r = sim:doActivity(life, "read_" .. open)
		check(r ~= nil, "reading it works")
		check(table.find(life.books, open) == nil, "a book that's been read leaves the shelf")
		check(#life.traits == traitsBefore + 1 or table.find(life.traits, pack.books[open].trait) ~= nil, "and you have what it teaches")
		check(table.find(life.books, closed) ~= nil, "the scroll you can't follow yet stays")
	end
end

-- ── endings with no body: a book is a book ──
do
	local life = survivor(51, 20)
	life.stats[sim.vital] = 20
	life.lastHit = { amount = 30, before = 50, mult = 1 }
	local report = sim.newReport()
	Engine.Effects.apply(sim, life, { die = "Became a book on the Floor of History", log = "You lost." }, report)
	check(not life.alive and life.death ~= nil, "losing a reception ends the life")
	local d = life.death
	check(d.ending == "book", "the end screen knows it was the Library")
	local all = table.concat(d.lines, " ") .. " " .. table.concat(d.tips, " ")
	check(string.find(all, "shelf", 1, true) ~= nil, "and says where they are now")
	check(string.find(all, "clinic", 1, true) == nil and string.find(all, "It cost you", 1, true) == nil, "with no talk of wounds or clinics")
	check(sim:endingPhrase(life) == "became a book in the Library", "the news says 'became a book', not 'died'")
	local lantern = sim:lantern(life)
	check(lantern.ending == "book", "the life's record keeps how it ended")
	-- a loved one who signed is a book, not a death
	local life2 = survivor(52, 14)
	local mother = nil
	for _, r in life2.relations do
		if r.kind == "mother" and r.alive then
			mother = r
		end
	end
	if mother then
		local rep2 = sim.newReport()
		Engine.Effects.apply(sim, life2, { killRelation = { kind = "mother", fate = "book" }, log = "She signed." }, rep2)
		check(not mother.alive and mother.fate == "a book in the Library", "a mother who signed is marked as a book")
		local said = false
		for _, e in rep2.entries do
			if type(e.text) == "string" and string.find(e.text, "is a book in the Library now", 1, true) then
				said = true
			end
		end
		check(said, "and the feed says so, not 'died at'")
		local v = sim:view(life2)
		local shown = false
		for _, r in v.relations do
			if r.id == mother.id and r.fate == "a book in the Library" then
				shown = true
			end
		end
		check(shown, "the family list shows her as a book")
	end
end

-- ── the household: what the family owns, what the parents do, and the business at 18 ──
do
	local seen = {}
	for seed = 1, 400 do
		local life = sim:newLife({ seed = 7000 + seed, rollOrigin = true })
		local o = life.origin
		if not seen[o] then
			seen[o] = true
			local v = sim:view(life)
			local def = sim.originsById[o]
			if def.household and def.household.owns then
				check(v.household and v.household.owns and not string.find(v.household.owns, "{", 1, true), "origin " .. o .. ": the Household card says what the family owns")
			end
			for _, rel in v.relations do
				if (rel.kind == "mother" or rel.kind == "father") and def.household and def.household.jobs and def.household.jobs[rel.kind] then
					check(rel.job and rel.jobShort and not string.find(rel.job, "{", 1, true), "origin " .. o .. ": the " .. rel.kind .. " has a job")
				end
			end
			if def.household and def.household.business then
				check(life.flags["family_business_" .. def.household.business], "origin " .. o .. ": the family business is on file")
			end
		end
	end
	check(seen.workshop_family and seen.diner_family, "the free business families turn up in 400 births (the landlord family is unlocked with Light)")
	-- taking over the forge starts you as a Smith
	local life = survivor(61, 18)
	life.flags.family_business_workshop = true
	local report = sim.newReport()
	Engine.Effects.apply(sim, life, { career = "workshop", careerRank = 3, log = "Took the hammer." }, report)
	check(life.career and life.career.id == "workshop" and life.career.rank == 3, "taking over the family Workshop starts you three ranks up")
end

-- ── Health past 100, abilities, and blood ──
do
	local Clash = Engine.Clash
	local life = survivor(71, 20)
	local vital = sim.vital
	check(sim:maxHealthOf(life) >= 100, "everyone holds at least 100 Health")
	life.stats.strength = 100
	life.fixerPeak = 9 -- Grade 1
	local max = sim:maxHealthOf(life)
	check(max >= 180, "a strong Grade 1 Fixer holds far more than 100 Health (" .. max .. ")")
	life.stats[vital] = 90
	Engine.Effects.apply(sim, life, { [vital] = 200, log = "Healed." }, sim.newReport())
	check(life.stats[vital] == max, "an ordinary heal stops at the maximum (" .. life.stats[vital] .. " of " .. max .. ")")
	Engine.Effects.apply(sim, life, { [vital] = 40, overheal = 40, log = "An ampoule." }, sim.newReport())
	check(life.stats[vital] > max, "an overheal goes past the maximum")
	local over = life.stats[vital] - max
	sim:settleHealth(life)
	check(life.stats[vital] - max < over and life.stats[vital] >= max, "and settles back halfway in a year")
	-- a check on Health counts up to 100, however much you hold
	local p1 = select(1, sim:clashSides(life, { stat = vital, foe = "x", coins = 2, base = 4, coinPower = 3, fixed = true }))
	life.stats[vital] = 100
	local p2 = select(1, sim:clashSides(life, { stat = vital, foe = "x", coins = 2, base = 4, coinPower = 3, fixed = true }))
	check(p1.base == p2.base and p1.coins == p2.coins, "Health over 100 doesn't make a Health check easier")
	-- a weapon's ability reaches the fight, and a foe's too
	life.gear = life.gear or {}
	life.gear.tool = "arm_zwei_shield"
	local spec = { stat = "strength", foe = "A Thumb Soldato", enemy = "thumb_soldato", fight = true, coins = 2, base = 4, coinPower = 3, fixed = true }
	local p, f = sim:clashSides(life, spec)
	local hasGuard = false
	for _, a in p.abilities or {} do
		if a.id == "guard" then
			hasGuard = true
		end
	end
	check(hasGuard, "a Zwei shield brings Guard into the fight")
	check(f.abilities and f.abilities[1].id == "volley", "a Thumb Soldato opens with a volley")
	local pv = sim:clashPreview(life, spec)
	check(pv.abilities and pv.foeAbilities, "the fight preview names what both sides bring")
	-- guard: the first lost clash costs no coin
	local st = { rng = Engine.Rng.seed(9) }
	local guarded, plain = 0, 0
	for _ = 1, 300 do
		local a = { name = "A", coins = 2, base = 2, coinPower = 2, heads = 50, abilities = { { id = "guard", potency = 1 } } }
		local b = { name = "B", coins = 2, base = 2, coinPower = 2, heads = 50 }
		if Clash.resolve(st, a, b).won then
			guarded += 1
		end
		if Clash.resolve(st, { name = "A", coins = 2, base = 2, coinPower = 2, heads = 50 }, b).won then
			plain += 1
		end
	end
	check(guarded > plain + 30, string.format("Guard wins more fights than the same side without it (%d vs %d of 300)", guarded, plain))
	-- blood: a Bloodfiend's art costs Health and drinks it back
	local bf = survivor(72, 22)
	bf.form = "bloodfiend"
	bf.stats.strength = 70
	local bspec = { stat = "strength", foe = "A Rat", enemy = "rat", fight = true, coins = 1, base = 1, coinPower = 1, fixed = true }
	local seen = false
	for _, a in sim:clashPreview(bf, bspec).approaches do
		if a.id == "hardblood" then
			seen = a.healthCost == 6 and a.abilities ~= nil
		end
	end
	check(seen, "a Bloodfiend is offered Hardblood, with its cost in Health")
	local r = sim.newReport()
	sim:resolveOption(bf, { clash = bspec, win = { log = "Won." }, lose = { log = "Lost." } }, r, "hardblood")
	check(r.clash ~= nil, "the art was used in the fight")
	local drank = false
	for _, e in r.entries do
		if e.kind == "log" and type(e.text) == "string" and string.find(e.text, "drank", 1, true) then
			drank = true
		end
	end
	check(drank or not r.clash.won, "winning with Hardblood drinks Health back")
	local paid = false
	for _, e in r.entries do
		if e.kind == "log" and type(e.text) == "string" and string.find(e.text, "your own blood", 1, true) then
			paid = true
		end
	end
	check(paid, "the blood art's cost was paid")
end

-- ── Sections and branches follow the District's compass region ──
do
	local life = survivor(81, 20)
	life.district = "d12"
	local report = sim.newReport()
	Engine.Effects.apply(sim, life, { career = "zwei", log = "Joined." }, report)
	check(sim:rankName(life) == "South Section 6 Fixer", "a Zwei Fixer in District 12 is in the South branch (" .. sim:rankName(life) .. ")")
	Engine.Effects.apply(sim, life, { career = "thumb", log = "Joined." }, sim.newReport())
	check(sim:careerName(life) == "the Thumb South" or string.find(sim:careerName(life), "South", 1, true) ~= nil, "the Thumb in District 12 is its South branch (" .. sim:careerName(life) .. ")")
	-- the right uniform on the right people
	check(pack.foes.wcorp_cleanup.look.outfit == "cleanup_jumpsuit", "W Corp's cleanup crew wear the cleanup jumpsuit")
	check(pack.foes.kcorp_staff.look.outfit == "kcorp_whites", "K Corp's staff wear K Corp whites")
	check(pack.foes.tcorp_collector.look.outfit == "tcorp_monochrome", "T Corp's collectors wear T Corp's monochrome")
end

-- ── every card says who it's about before it says "she" ──
do
	local bad = {}
	for _, e in pack.events do
		local list = if type(e.text) == "table" then e.text else { e.text }
		for _, t in list do
			if type(t) == "string" then
				local first = string.match(t, "^%s*(%a+)")
				if first == "She" or first == "He" or first == "Her" or first == "His" or first == "Him" or first == "She's" or first == "He's" then
					table.insert(bad, e.id)
					break
				end
			end
		end
	end
	check(#bad == 0, "cards that open on a bare he/she: " .. table.concat(bad, ", "))
end

-- ── who you know of: every Finger, Wing and Association, with your standing on each ──
do
	-- the Wing that owns your District is one you know from birth (and so you know of Wings)
	local found = nil
	for seed = 1, 600 do
		local life = sim:newLife({ seed = seed, rollOrigin = true })
		if life.district == "d11" then
			found = life
			break
		end
	end
	check(found ~= nil, "some life is born in District 11")
	if found then
		check(found.flags.knows_kcorp == true, "born in District 11, you know K Corp")
		check(found.flags.knows_wings == true, "knowing K Corp, you know there are Wings")
	end
	-- a card that names an Association teaches it (and that there are Fixers)
	local life = survivor(9101, 12)
	life.flags.knows_zwei = nil
	life.flags.knows_fixers = nil
	sim:learnFrom(life, { id = "test_zwei_card", text = "A Zwei Fixer in a grey coat walks a client home past your door." }, nil)
	check(life.flags.knows_zwei == true, "a card naming Zwei teaches the Zwei Association")
	check(life.flags.knows_fixers == true, "knowing Zwei, you know there are Fixers")
	-- a headline alone doesn't (headlines capitalise everything)
	life.flags.knows_cinq = nil
	sim:learnFrom(life, { id = "test_cinq_card", title = "Cinq", text = "Nothing here names it." }, nil)
	check(life.flags.knows_cinq == nil, "a headline alone teaches nothing")
	-- a standing with a faction is knowing of it, and it shows on that faction's entry
	life.flags.knows_kurokumo = nil
	local extra = {}
	sim:addRep(life, "kurokumo", -25, extra)
	check(life.flags.knows_kurokumo == true, "a standing with the Kurokumo Clan is knowing of them")
	local said = false
	for _, e in extra do
		if e.kind == "learned" and e.flag == "knows_kurokumo" then
			said = true
		end
	end
	check(said, "learning of them through a standing says so")
	local known = sim:knownView(life)
	local entry = nil
	for _, k in known.list do
		if k.flag == "knows_kurokumo" then
			entry = k
		end
	end
	check(entry ~= nil and entry.rep ~= nil and entry.rep.value == -25, "the Kurokumo entry carries the standing")
	check(entry ~= nil and entry.group == "streets", "the Kurokumo Clan is listed under the Backstreets")
	for _, r in sim:repView(life) or {} do
		if r.id == "kurokumo" then
			check(r.known == true, "the standing is shown on its entry, so no faction is listed twice")
		end
	end
	-- every standing in the City has an entry of its own
	for _, id in pack.reputation.order do
		local def = pack.reputation[id]
		check(def.flag ~= nil and sim.gateByFlag[def.flag] ~= nil and sim.repOfFlag[def.flag] == id, "standing " .. id .. " has its own entry in Who you know of")
	end
	-- the lists are long enough to matter
	local count = {}
	for _, gr in pack.knownGroups do
		count[gr.id] = #gr.flags
	end
	check((count.fingers or 0) >= 6, "the five Fingers, and the Fingers themselves")
	check((count.fixers or 0) >= 10, "Hana and the Associations")
	check((count.wings or 0) >= 10, "the Wings")
	for _, gr in pack.knownGroups do
		for _, flag in gr.flags do
			local g = sim.gateByFlag[flag]
			check(g ~= nil and g.name ~= nil and g.emblem ~= nil and g.blurb ~= nil, "known entry " .. flag .. " has a name, an emblem and a blurb")
		end
	end
	-- listed group by group, in the groups' order
	local at = {}
	for i, gr in known.groups do
		at[gr.id] = i
	end
	local last, sorted = 0, true
	for _, k in known.list do
		local i = at[k.group] or 99
		if i < last then
			sorted = false
		end
		last = i
	end
	check(sorted, "Who you know of is listed group by group")
end

-- ── markets and homes: stock and prices that change with the City ──
do
	local life = survivor(9301, 20)
	life.money = 100000
	life.pending = nil
	local function market(id)
		for _, m in sim:marketsView(life) or {} do
			if m.id == id then
				return m
			end
		end
		return nil
	end
	local function good(m, id)
		for _, g in (m and m.goods) or {} do
			if g.id == id then
				return g
			end
		end
		return nil
	end
	-- the streets decide what's on the tables
	life.world.streets = "turf_war"
	check(good(market("overpass"), "op_armband") ~= nil, "a turf war puts armbands on the Overpass tables")
	check(market("overpass").markup ~= nil and market("overpass").markup.mult > 1, "a turf war puts the Overpass prices up")
	life.world.streets = "quiet"
	check(good(market("overpass"), "op_armband") == nil, "quiet streets: no armbands")
	-- buying: the price, the result, and no action spent
	local before, actions = life.money, life.actionsLeft
	local sanity = life.sanity
	local noodles = good(market("overpass"), "op_noodles")
	check(noodles ~= nil and noodles.enabled, "noodles are for sale")
	local r = sim:buyMarket(life, "overpass", "op_noodles")
	check(r ~= nil, "buying noodles works")
	check(life.money == before - noodles.price, "the price is paid: " .. tostring(before - life.money) .. " for " .. tostring(noodles.price))
	check(life.sanity > sanity or life.sanity >= pack.stats.sanity.max, "the noodles did their bit")
	check(life.actionsLeft == actions, "buying doesn't use an action")
	-- three bowls a year, then the stall is out
	sim:buyMarket(life, "overpass", "op_noodles")
	sim:buyMarket(life, "overpass", "op_noodles")
	local fourth, why = sim:buyMarket(life, "overpass", "op_noodles")
	check(fourth == nil and why == "Sold out this year", "the night stall sells three bowls a year: " .. tostring(why))
	-- K Corp's ampules heal past full, and cost more outside District 11
	life.district = "d4"
	local away = good(market("kcorp"), "kc_ampule")
	life.district = "d11"
	local home11 = good(market("kcorp"), "kc_ampule")
	check(away and home11 and away.price > home11.price, "ampules cost more outside District 11")
	local max = sim:maxHealthOf(life)
	life.stats.health = max
	sim:buyMarket(life, "kcorp", "kc_ampule")
	check(life.stats.health > max, "an ampule heals past full (" .. life.stats.health .. " of " .. max .. ")")
	-- a regeneration course: more most Health, for good, once
	local m0 = sim:maxHealthOf(life)
	check(sim:buyMarket(life, "kcorp", "kc_course") ~= nil, "the regeneration course can be bought at 20")
	check(sim:maxHealthOf(life) == m0 + 10, "the course adds 10 most Health")
	local again = sim:buyMarket(life, "kcorp", "kc_course")
	check(again == nil, "a regeneration course is once a life")
	-- a home: bought, lived in (upkeep, Sanity), sold for half
	local flat = good(market("letting"), "lt_steel_door_flat")
	check(flat ~= nil and flat.enabled, "a flat with a steel door is for sale")
	sim:buyMarket(life, "letting", "lt_steel_door_flat")
	check(life.home ~= nil and life.home.id == "steel_door_flat", "you live in the flat now")
	check(good(market("letting"), "lt_steel_door_flat").reason == "You live here", "the agent knows you live there")
	local cash = life.money
	sim:buyMarket(life, "letting", "lt_safehouse")
	check(life.home.id == "safehouse", "moving to the safehouse")
	check(life.money == cash - good(market("letting"), "lt_safehouse").price + 700, "the old flat sold for half on the way out")
	local hv = sim:homeView(life)
	check(hv ~= nil and hv.hideout > 0, "a safehouse makes you harder to find")
	cash = life.money
	sim:buyMarket(life, "letting", "lt_sell")
	check(life.home == nil and life.money == cash + 2600, "selling the safehouse brings back half its price")
	-- hired help is good to have, and a clinic doesn't "cure" it
	sim:buyMarket(life, "fixer_desk", "fd_bodyguard")
	check(sim:hasCondition(life, "bs_bodyguard"), "a bodyguard for the year")
	sim:cureCondition(life, "any", {})
	check(sim:hasCondition(life, "bs_bodyguard"), "a check-up doesn't send your bodyguard home")
	-- every market good has a name, a price, a result; every home good names a real home
	for _, id in pack.markets.order do
		for _, g in pack.markets[id].goods do
			check(type(g.name) == "string" and type(g.price) == "number" and type(g.result) == "table", "market good " .. tostring(g.id) .. " is complete")
		end
	end
end

-- ── sell out a Bloodfiend Family, and it hunts you rank by rank ──
do
	local life = survivor(9401, 24)
	life.form = "human"
	life.flags.knows_bloodfiends = true
	life.flags.bf_sold_out = nil
	life.flags.bf_informer = nil
	life.pending = "bf_sell_offer"
	-- (whatever the Families thought of this life before, it starts from nothing here)
	life.rep = life.rep or {}
	life.rep.bloodfiends = 0
	local v = sim:view(life)
	local pick = nil
	for _, c in (v.pending and v.pending.choices) or {} do
		if string.find(c.label, "Sell them", 1, true) then
			pick = c.index
		end
	end
	check(pick ~= nil, "a hunter's price can be taken")
	if pick then
		sim:choose(life, pick, nil)
		check(life.flags.bf_sold_out == true, "selling them out is remembered")
		check(sim:hasCondition(life, "bf_hunted_family"), "the Family hunts you")
		check(sim:repOf(life, "bloodfiends") <= -50, "the Families' standing falls through the floor")
		local next = nil
		for _, s in life.scheduled do
			if s.event == "bf_hunt_fledgling" then
				next = s
			end
		end
		check(next ~= nil, "a Fledgling comes first")
	end
	-- the hunt climbs the ranks, each a harder foe than the last
	local function foeBase(id)
		local e = sim.eventsById[id]
		return e and e.choices[1].clash and e.choices[1].clash.base or 0
	end
	check(foeBase("bf_hunt_fledgling") < foeBase("bf_hunt_knight") and foeBase("bf_hunt_knight") < foeBase("bf_hunt_hand") and foeBase("bf_hunt_hand") < foeBase("bf_hunt_elder"), "Fledgling, Knight, Elder's Hand, Elder: each stronger")
	for _, id in { "bf_fledgling", "bf_knight", "bf_hand", "bf_elder" } do
		check(pack.foes[id] ~= nil and pack.foes[id].faction == "bloodfiends", "the Family's " .. id .. " is a foe of its own")
	end
end

-- ── no two lives read the same chapter names; prodigies wake at different ages ──
do
	local titles, lines = {}, {}
	local nT, nL = 0, 0
	for seed = 1, 40 do
		local life = sim:newLife({ seed = 5000 + seed, rollOrigin = true })
		local ch = sim:chapterView(life)
		if ch then
			if not titles[ch.title] then
				titles[ch.title] = true
				nT += 1
			end
			if not lines[ch.line] then
				lines[ch.line] = true
				nL += 1
			end
		end
	end
	check(nT >= 4, "Canto I has many names across lives (" .. nT .. " seen)")
	check(nL >= 3, "and many first lines (" .. nL .. " seen)")
	-- a sleeping gift: no bonus until it wakes, then a moment of its own
	local found = nil
	for seed = 1, 900 do
		local life = sim:newLife({ seed = 7000 + seed, rollOrigin = true })
		if life.talentWake then
			found = life
			break
		end
	end
	check(found ~= nil, "some lives are born with a gift that sleeps")
	if found then
		local life = found
		check(not sim:hasTrait(life, life.talent), "a sleeping gift isn't working yet")
		check(sim:talentView(life).asleep == true, "the talent card says it's asleep")
		check(sim:resonates(life) == false, "a sleeping gift doesn't resonate")
		local wake = life.talentWake
		local woke, said = false, false
		local guard = 0
		while life.alive and life.age < wake and guard < 60 do
			guard += 1
			if life.pending then
				local v = sim:view(life)
				local pick = nil
				for _, c in v.pending.choices do
					if c.enabled then
						pick = c.index
						break
					end
				end
				if not pick or not sim:choose(life, pick, nil) then
					life.pending = nil
				end
			else
				local r = Loader.ageUp(sim, life)
				for _, e in (r and r.entries) or {} do
					if e.kind == "gift" then
						said = true
					end
				end
			end
		end
		woke = sim:hasTrait(life, life.talent)
		if life.alive then
			check(woke, "the gift wakes at " .. tostring(wake) .. " (life is " .. life.age .. ")")
			check(said, "and the year it wakes says so")
		end
	end
	-- every band has a scout event, and every scout exists
	for band, s in pack.talentWake.scouts do
		check(sim.eventsById[s.event] ~= nil, "the " .. band .. " scout event exists")
	end
end

-- ── a household of your own: with someone the game made, never another player ──
do
	local life = survivor(9501, 20)
	life.age = 26
	life.pending = nil
	life.stats.charisma = math.max(life.stats.charisma, 45)
	local friend = sim:addRelation(life, { kind = "friend", age = { 26, 26 }, bond = 85 })
	local other = sim:addRelation(life, { kind = "friend", age = { 27, 27 }, bond = 85 })
	local player = sim:addRelation(life, { kind = "friend", age = { 26, 26 }, bond = 90 })
	player.userId = 12345
	local vis = sim:interactionState(life, friend, "share_household")
	check(vis, "a close friend can be asked to share a household")
	check(not sim:interactionState(life, player, "share_household"), "never another player")
	-- ask until the answer is yes (it's a Charisma check)
	local tries = 0
	while friend.kind ~= "partner" and tries < 40 do
		tries += 1
		friend.talked = nil
		life.socialLeft = 3
		life.actionsLeft = 3
		friend.bond = 85
		sim:interact(life, friend.id, "share_household")
		life.pending = nil
	end
	check(friend.kind == "partner", "they said yes (after " .. tries .. " asks)")
	check(not sim:interactionState(life, other, "share_household"), "one household at a time")
	-- a partner halves the upkeep on a home
	life.money = 50000
	life.home = { id = "townhouse", since = life.age }
	local before = life.money
	local report = { entries = {} }
	Loader.ageUp(sim, life)
	life.pending = nil
	local paid = before - life.money
	check(paid <= math.floor(pack.homes.townhouse.upkeep / 2 + 0.5) + 2000, "a partner pays half the upkeep (paid " .. paid .. ")")
	-- ending it (the year that just passed could have been the last: this part only needs a
	-- life to ask with)
	if not life.alive then
		life.alive = true
		life.stats.health = 80
	end
	friend.alive = true
	friend.talked = nil
	life.socialLeft = 3
	life.actionsLeft = 3
	life.pending = nil
	life.run = nil
	local ended, whyNot = sim:interact(life, friend.id, "end_household")
	check(friend.kind == "friend", "ending the household puts them back to a friend (" .. tostring(whyNot or (ended and "ran") or "?") .. ", " .. tostring(friend.kind) .. ")")
	-- the words stay Roblox-safe: no romance anywhere in the household cards
	for _, e in pack.events do
		if string.sub(e.id, 1, 5) == "hh_p_" then
			local blob = string.lower((if type(e.text) == "table" then table.concat(e.text, " ") else e.text or "") .. " " .. (e.title or ""))
			for _, w in { "love", "kiss", "date", "romance", "marr", "wedding", "spouse", "husband", "wife" } do
				check(not string.find(blob, "%f[%a]" .. w), "household card " .. e.id .. " says nothing like '" .. w .. "'")
			end
		end
	end
end

-- ── people you've met: talk to them before they're friends ──
do
	local life = survivor(9601, 20)
	life.pending = nil
	local extra = {}
	local rel = sim:meetSomeone(life, extra, "the cook at the night stall on your corner")
	check(rel ~= nil and rel.kind == "acquaintance", "you can meet someone")
	check(#extra == 1 and string.find(extra[1].text, rel.first, 1, true) ~= nil, "and the feed says who")
	local v = sim:view(life)
	local seen = nil
	for _, r in v.relations do
		if r.id == rel.id then
			seen = r
		end
	end
	check(seen ~= nil and seen.role == "the cook at the night stall on your corner", "the People list says who they are to you")
	local ids = {}
	for _, it in (seen and seen.interactions) or {} do
		ids[it.id] = true
	end
	check(ids.say_hello and ids.ask_about, "you can talk to someone you've only met")
	check(not ids.share_household, "but not ask them to share a household")
	-- close enough, and they can become a friend
	rel.bond = 60
	rel.talked = nil
	life.socialLeft = 3
	life.actionsLeft = 3
	sim:interact(life, rel.id, "befriend")
	check(rel.kind == "friend", "an acquaintance can become a friend")
	-- one you never talk to drifts away (v0.18: a life that dies that year proves nothing either
	-- way, so then it's tried on another grown-up life)
	local still, lived = true, false
	for attempt = 0, 6 do
		local l = if attempt == 0 then life else survivor(4100 + attempt * 37, 20)
		l.pending = nil
		local far = sim:meetSomeone(l, nil, "a neighbor from two floors down")
		far.bond = 2
		Loader.ageUp(sim, l)
		l.pending = nil
		if l.alive then
			lived = true
			still = false
			for _, r in l.relations do
				if r == far then
					still = true
				end
			end
			break
		end
	end
	check(lived and not still, "someone you never talk to drifts out of your life")
end

-- ── no two years alike: moods, never two the same running, none in a hard year ──
do
	local life = survivor(9701, 8)
	local seen, last, repeats, inCrisis = {}, nil, 0, 0
	local n = 0
	for _ = 1, 30 do
		if not life.alive then
			break
		end
		-- (v0.15) the City kills young now; this is about moods, so keep this life healthy
		life.stats.health = math.max(life.stats.health or 0, 80)
		if life.pending then
			local v = sim:view(life)
			local pick = nil
			for _, c in v.pending.choices do
				if c.enabled then
					pick = c.index
					break
				end
			end
			if not pick or not sim:choose(life, pick, nil) then
				life.pending = nil
			end
		end
		if not life.pending and life.alive then
			Loader.ageUp(sim, life)
			if life.mood then
				if not seen[life.mood] then
					seen[life.mood] = true
					n += 1
				end
				if life.mood == last then
					repeats += 1
				end
				if life.crisis then
					inCrisis += 1
				end
			end
			last = life.mood
		end
	end
	check(n >= 3, "a life meets several kinds of year (" .. n .. " moods seen)")
	check(repeats == 0, "never the same mood two years running")
	check(inCrisis == 0, "a hard year has no mood of its own")
	-- fatigue: a theme seen a lot last year weighs less this year
	local e, scary = nil, nil
	for _, ev in pack.events do
		local exempt = false
		for _, t in ev.tags or {} do
			if table.find(pack.tagFatigue.skip, t) then
				exempt = true
			end
		end
		if ev.tags and table.find(ev.tags, "fixers") and not ev.story and (ev.weight or 10) > 0 then
			if exempt then
				scary = scary or ev
			else
				e = e or ev
			end
		end
	end
	if e then
		life.mood = nil
		life.tagsLast = {}
		local fresh = sim:eventWeight(life, e)
		life.tagsLast = { fixers = 3 }
		local tired = sim:eventWeight(life, e)
		check(tired < fresh, "a theme from last year comes up less this year")
	end
	if scary then
		life.tagsLast = {}
		local fresh = sim:eventWeight(life, scary)
		for _, t in scary.tags do
			life.tagsLast[t] = 3
		end
		check(sim:eventWeight(life, scary) == fresh, "but a dangerous card never fades")
	end
end

-- ── a grown life matters: renown grades, deeds, an Office, the City's hold ──
do
	local life = survivor(9801, 20)
	life.pending = nil
	life.renown = 0
	local function actState(id)
		for _, a in sim:view(life).activities do
			if a.id == id then
				return a
			end
		end
		return nil
	end
	check(actState("deed_fund_clinic") == nil, "a deed waits for renown")
	local report = { entries = {} }
	local maxBefore = sim:maxHealthOf(life)
	sim:addRenown(life, pack.renown.ranks[3].at, report)
	check(sim:renownRank(life) == 3, "enough renown is a grade (Urban Myth)")
	local said = false
	for _, e in report.entries do
		if e.kind == "renown" then
			said = true
		end
	end
	check(said, "a new grade is announced")
	check(sim:maxHealthOf(life) > maxBefore, "a grade's perks: more most Health")
	check(actState("deed_fund_clinic") ~= nil, "renown opens deeds")
	-- a deed that changes a District: the hold moves, and it goes out to the server
	sim:setHolds({})
	local r2 = { entries = {} }
	sim:applyResult(life, { impact = { kind = "safety", amount = 2, text = "test" }, log = "test" }, r2)
	check(r2.impact ~= nil and #r2.impact == 1, "a deed's impact goes out in the report")
	local hold = sim.holds[life.district]
	check(hold ~= nil and hold.safety == 2, "and the District is safer at once")
	-- an Office: founded, then it pays every year
	life.flags.licensed_fixer = true
	sim:applyResult(life, { foundOffice = true, log = "test" }, { entries = {} })
	check(life.office ~= nil and life.office.size == 1, "an Office of your own")
	local paid = false
	local yr = Loader.ageUp(sim, life)
	life.pending = nil
	for _, e in (yr and yr.entries) or {} do
		if e.kind == "log" and type(e.text) == "string" and string.find(e.text, "Office's contracts paid", 1, true) then
			paid = true
		end
	end
	check(paid or not life.alive, "the Office pays out every year")
end

-- ── different work as you rank up, and harder; hard years at the ages that bring them ──
do
	local Jobs = Engine.Jobs or Loader.require(root.Engine.Jobs)
	local life = survivor(9901, 20)
	life.pending = nil
	life.career = { id = "fixer", rank = 1, years = 0, jobs = 0 }
	local low, high = {}, {}
	local lowBase, highBase, nLow, nHigh = 0, 0, 0, 0
	for _ = 1, 12 do
		Jobs.roll(sim, life)
		for _, j in life.jobs or {} do
			low[j.t] = true
			local _, tpl = Jobs.option(sim, life, j)
			local opt = Jobs.option(sim, life, j)
			if opt and opt.clash then
				lowBase += opt.clash.base or 0
				nLow += 1
			end
		end
	end
	life.career.rank = 7
	for _ = 1, 12 do
		Jobs.roll(sim, life)
		for _, j in life.jobs or {} do
			high[j.t] = true
			local opt = Jobs.option(sim, life, j)
			if opt and opt.clash then
				highBase += opt.clash.base or 0
				nHigh += 1
			end
		end
	end
	local onlyHigh = 0
	for t in high do
		if not low[t] then
			onlyHigh += 1
		end
	end
	check(onlyHigh >= 3, "a Grade 3 gets jobs a Grade 9 never sees (" .. onlyHigh .. " different)")
	check(nLow > 0 and nHigh > 0 and highBase / nHigh > lowBase / nLow, "and they're harder")
	-- hard years come at the ages that bring them
	check(pack.crisisAges ~= nil and #pack.crises >= 3, "the City has hard years to give")
end

if fails > 0 then
	print(fails .. " FAILED")
	process.exit(1)
end
print("v0.12 check: unanswerable cards let go; linked friends one entry, reached, and seen; scrolls and books; who you know of, with standings; markets and homes; a Family's hunt; gifts that wake; Cantos per life; households; people you've met; year moods; renown, Offices and holds")
print("OK")
