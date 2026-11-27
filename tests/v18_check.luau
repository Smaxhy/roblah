--[[
	v0.18, checked against the City pack (the engine side; tests/fx_check runs the 3D stage on
	the real client):
	  - earned traits come by themselves the year their need holds, once, and never before
	  - every new talent is in the rolls for its rarity, with a sin
	  - no two traits share a name
	  - Fixer's Road (start at 18) is hidden, and the shipped config doesn't show hidden modes
	  - your own Office: its sign, hiring friends, buildings, rooms, the lab, the year, the fights
	  - events follow on: the card that starts a thread is the life's focus, its follow-ups first
	  - event cards are harder, dangerous ones more so, and the dread roll sends one more
		lune run tests/v18_check
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Config = Loader.require(root.Config)
Config.pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local Feats = Loader.require(root.Engine.Feats)
local sim = Engine.Sim.new(pack)

local fails = 0
local function check(ok: any, msg: string)
	if not ok then
		fails += 1
		print("  FAIL  " .. msg)
	end
end

local function grown(seed: number, level: number?)
	local life = sim:newLife({ seed = seed, rollOrigin = true })
	life.age = 30
	life.pending = nil
	life.queue = {}
	for _, k in pack.stats.order do
		life.stats[k] = level or 50
	end
	life.stats.health = 100
	life.money = 100
	life.peakMoney = 100
	life.tally = life.tally or {}
	return life
end

local function earnedIds(): { string }
	local out = {}
	for _, id in pack.traits.order do
		local def = pack.traits[id]
		if type(def) == "table" and type(def.earn) == "table" then
			table.insert(out, id)
		end
	end
	return out
end

-- ── earned traits ──
do
	local earned = earnedIds()
	check(#earned >= 36, "there should be at least 36 earned traits (" .. #earned .. ")")

	-- a plain grown-up life earns none of the big ones
	local life = grown(101)
	local report = { entries = {} }
	Feats.earnTraits(sim, life, report)
	for _, id in { "tr18_survivor", "tr18_old_hand", "tr18_iron_body", "tr18_unreal_strength", "tr18_well_rounded", "tr18_at_the_peak", "tr18_brawler", "tr18_old_money" } do
		check(not sim:hasTrait(life, id), id .. " shouldn't come before its need holds")
	end

	-- each need, met, brings its trait
	local cases = {
		{ "tr18_survivor", function(l) l.age = 70 end },
		{ "tr18_old_hand", function(l) l.age = 50 end },
		{ "tr18_iron_body", function(l) l.stats.health = 150 end },
		{ "tr18_unreal_strength", function(l) l.stats.strength = 150 end },
		{ "tr18_well_rounded", function(l)
			for _, k in pack.stats.order do
				l.stats[k] = 80
			end
		end },
		{ "tr18_at_the_peak", function(l) l.stats.speed = 250 end },
		{ "tr18_brawler", function(l) l.tally.clashesWon = 15 end },
		{ "tr18_old_money", function(l) l.peakMoney = 100000 end },
		{ "tr18_saver", function(l) l.peakMoney = 10000 end },
	}
	for i, c in cases do
		local l = grown(200 + i)
		c[2](l)
		local r = { entries = {} }
		local before = #(l.traits or {})
		Feats.earnTraits(sim, l, r)
		check(sim:hasTrait(l, c[1]), c[1] .. " should come once its need holds")
		local count = 0
		for _, t in l.traits or {} do
			if t == c[1] or (type(t) == "table" and t.id == c[1]) then
				count += 1
			end
		end
		check(count <= 1, c[1] .. " was given more than once")
		-- a second year doesn't give it again
		local mid = #(l.traits or {})
		Feats.earnTraits(sim, l, r)
		check(#(l.traits or {}) == mid, c[1] .. ": a second year gave more traits")
		check(mid > before, c[1] .. ": nothing was added")
	end

	-- the year's feed says so (through the full yearly check, as the game runs it)
	local l = grown(300)
	l.age = 70
	local r = { entries = {} }
	local okC, errC = pcall(Feats.check, sim, l, r)
	check(okC, "Feats.check failed: " .. tostring(errC))
	check(sim:hasTrait(l, "tr18_survivor"), "the yearly check should grant earned traits too")
	print(string.format("earned traits: %d of them; each need met brought its trait once, and none came early", #earned))
end

-- ── the new talents are in the rolls ──
do
	local tiers = {}
	for _, t in pack.talents.tiers do
		tiers[t.id] = {}
		for _, id in sim:talentPool(t.id) do
			tiers[t.id][id] = true
		end
	end
	local n, missing = 0, {}
	for _, id in pack.traits.order do
		if string.sub(id, 1, 5) == "tal3_" then
			n += 1
			local def = pack.traits[id]
			local tier = def and def.talent
			if not (tier and tiers[tier] and tiers[tier][id]) then
				table.insert(missing, id)
			end
			check(def and type(def.affinity) == "string", id .. " has no sin")
		end
	end
	check(n == 60, "there should be 60 new talents (" .. n .. ")")
	check(#missing == 0, "talents missing from their rarity's rolls: " .. table.concat(missing, ", "))
	print(string.format("talents: %d new ones, every one in its rarity's rolls with a sin", n))
end

-- ── no two traits share a name ──
do
	local seen, dupes = {}, {}
	for _, id in pack.traits.order do
		local def = pack.traits[id]
		local key = def and string.lower(tostring(def.name))
		if key then
			if seen[key] then
				table.insert(dupes, seen[key] .. " / " .. id)
			end
			seen[key] = id
		end
	end
	check(#dupes == 0, "traits with the same name: " .. table.concat(dupes, ", "))
end

-- ── Fixer's Road is off the menus ──
do
	local fixer = nil
	for _, m in pack.modes or {} do
		if m.id == "fixer" then
			fixer = m
		end
	end
	check(fixer ~= nil and fixer.hidden == true, "Fixer's Road (start at 18) should be hidden")
	check(Config.devModes == false, "the shipped config must not show hidden modes (Config.devModes)")
	print("modes: Fixer's Road is hidden, and the shipped config keeps it that way")
end

-- ── your own Office ──
do
	local Renown = Loader.require(root.Engine.Renown)
	local Office = Loader.require(root.Engine.Office)
	local life = grown(500, 60)
	life.money = 5000
	life.actionsLeft = 3
	Renown.foundOffice(sim, life, nil, "Lantern")
	local o = life.office
	check(o and o.named == false, "a new Office should wait for its name")

	-- the sign: a name, a motto, a colour
	check(sim:officeRename(life, "X", nil, nil) == nil, "a one-letter name shouldn't be taken")
	check(sim:officeRename(life, "Bluebell", "We come when called", "jade") ~= nil, "a fair name, motto and colour should be taken")
	check(o.name == "Bluebell" and o.motto == "We come when called" and o.color == "jade" and o.named == true, "the sign should read what was typed")
	sim:officeRename(life, "Bluebell Office", nil, nil)
	check(o.name == "Bluebell", "\"Office\" on the end of the name shouldn't be doubled (" .. tostring(o.name) .. ")")
	check(sim:officeRename(life, nil, nil, "neon-pink") == nil, "a colour that isn't on the list shouldn't be taken")

	-- hiring: a close friend comes, a child, a rival and a stranger don't
	local friend = sim:addRelation(life, { kind = "friend", name = "Ilsa Brandt", bond = 85, age = 28 })
	local mate = sim:addRelation(life, { kind = "friend", name = "Oren Vey", bond = 60, age = 33 })
	local kid = sim:addRelation(life, { kind = "friend", name = "Pim Hale", bond = 90, age = 12 })
	local rival = sim:addRelation(life, { kind = "rival", name = "Corvin Ash", bond = 70, age = 30 })
	local cold = sim:addRelation(life, { kind = "friend", name = "Tam Rook", bond = 20, age = 30 })
	check(select(1, Office.eligible(sim, life, friend)) == true, "a close grown-up friend should be able to join")
	check(select(1, Office.eligible(sim, life, kid)) == false, "a child can't be hired")
	check(select(1, Office.eligible(sim, life, rival)) == false, "a rival won't join")
	check(select(1, Office.eligible(sim, life, cold)) == false, "someone who barely trusts you won't join")
	local money0 = life.money
	check(sim:officeAct(life, "hire", friend.id) ~= nil, "hiring a close friend should work")
	check(#o.crew == 1 and o.crew[1].grade == 8, "a close friend should come in at Grade 8")
	check(life.money < money0, "hiring should cost a first year's wage")
	check(sim:officeAct(life, "hire", friend.id) == nil, "the same friend can't be hired twice")
	check(sim:officeAct(life, "hire", mate.id) ~= nil, "a second friend should fit the first room (2 desks)")
	local third = sim:addRelation(life, { kind = "friend", name = "Nell Quay", bond = 70, age = 40 })
	check(sim:officeAct(life, "hire", third.id) == nil, "a third Fixer shouldn't fit in one room")

	-- the building and the rooms
	check(sim:officeAct(life, "room", "lab") == nil, "a lab shouldn't fit in a single room")
	life.money = 20000
	check(sim:officeAct(life, "building") ~= nil, "moving to a storefront should work with the money")
	check(o.building == 2, "the Office should be in the storefront now")
	check(sim:officeAct(life, "hire", third.id) ~= nil, "a storefront has room for a third Fixer")
	check(sim:officeAct(life, "building") == nil, "a whole floor needs a bigger Office first")
	life.money = 20000
	check(sim:officeAct(life, "room", "training") ~= nil, "a training room should fit in a storefront")
	check(sim:officeAct(life, "room", "training") == nil, "the same room can't be built twice")

	-- the lab: one action and the materials, and something always happens
	o.rooms.lab = true
	life.money = 10000
	local acts = life.actionsLeft
	local rep = sim:officeAct(life, "experiment")
	check(rep ~= nil and #rep.entries > 0, "an experiment should say what happened")
	check(life.actionsLeft == acts - 1, "an experiment should take one action")
	life.actionsLeft = 0
	check(sim:officeAct(life, "experiment") == nil, "no actions left: no experiment")

	-- in a fight, three Fixers behind you count
	local base = Office.fightBonus(sim, life)
	check(base >= 1, "three Fixers on the roster should add to your fights (" .. tostring(base) .. ")")

	-- the year: wages paid, grades rise, the training room trains you
	life.money = 50000
	local before = life.stats[sim.roles.fight]
	local r = sim.newReport()
	Office.year(sim, life, r)
	check(#r.entries > 0, "the Office's year should say what happened")
	check(life.stats[sim.roles.fight] >= before, "the training room shouldn't make you weaker")
	-- an Office that can't pay loses its least loyal Fixer
	life.money = 0
	local crew0 = #o.crew
	Office.year(sim, life, sim.newReport())
	check(#o.crew < crew0, "with no money for wages, someone should leave")

	-- the dead come off the roster
	friend.alive = false
	Office.year(sim, life, sim.newReport())
	for _, m in o.crew do
		check(m.rel ~= friend.id, "a dead Fixer should come off the roster")
	end

	-- firing
	local m1 = o.crew[1]
	if m1 then
		check(sim:officeAct(life, "fire", m1.rel) ~= nil, "letting someone go should work")
	end

	-- what the client sees
	local v = sim:view(life)
	local ov = v.office
	check(ov and ov.named == true and ov.motto and ov.colorRgb and ov.building and ov.rooms and ov.hire and ov.crew, "the Office view should carry the sign, building, rooms, roster and hires")
	print(string.format("office: named, %d hired, moved into %s, rooms built, lab run, year paid, +%d in fights", 3, tostring(ov and ov.building and ov.building.name), base))
end

-- ── events follow on (Engine/Focus.luau) ──
do
	local Focus = Loader.require(root.Engine.Focus)
	local life = grown(700)
	life.age = 30
	-- a Library card: the Library becomes the focus
	local libEvent = sim.eventsById["lib_streets_talk"]
	check(libEvent ~= nil, "lib_streets_talk should exist")
	Focus.saw(sim, life, libEvent)
	check(life.focus ~= nil and life.focus.name == "The Library", "a Library card should make the Library the focus (" .. tostring(life.focus and life.focus.name) .. ")")
	local other = sim.eventsById["dz_s_rat_rifles"]
	local libOther = sim.eventsById["lib_book_stall"]
	check(Focus.weight(sim, life, libOther, 10) > 10 * 3, "Library cards should come far more often while the Library is the focus")
	check(Focus.weight(sim, life, other, 10) < 10, "unrelated cards should come less often while something else is the focus")
	check(sim:threadOf(life, libOther).kind == "focus", "a card of the focus should say it follows on")
	-- a follow-up due this year: one fewer unrelated card, and the follow-up goes first
	life.queue = { "dz_s_rat_rifles", "lib_book_stall" }
	check(Focus.count(sim, life, 2) == 1, "a year with a follow-up of the focus should bring one fewer unrelated card")
	Focus.order(sim, life)
	check(life.queue[1] == "lib_book_stall", "the focus's card should come first in the year")
	-- a stray card doesn't push aside a focus with something still to come
	life.scheduled = { { event = "lib_invite_general", age = life.age + 1 } }
	Focus.saw(sim, life, sim.eventsById["dr18_rat_pack"])
	check(life.focus and life.focus.name == "The Library", "a stray card shouldn't push aside a focus with a follow-up still to come")
	-- and a finished focus lets go
	life.scheduled = {}
	life.queue = {}
	life.age += 5
	Focus.tick(sim, life)
	check(life.focus == nil, "a focus with nothing still to come should let go after its years")
	-- chains are threads: the Capo follows the Soldati
	local ix = sim.focusIndex
	check(ix.threadOf["dr18_thumb_word"] ~= nil and ix.threadOf["dr18_thumb_word"] == ix.threadOf["dr18_thumb_capo"], "a card and the follow-up it schedules should be one thread")
	check(ix.threadOf["dr18_shi_contract"] == ix.threadOf["dr18_shi_client"], "a card and the card it triggers should be one thread")
	local threads = 0
	for id, root in ix.threadOf do
		if id == root then
			threads += 1
		end
	end
	print(string.format("focus: %d threads in the City; a Library card holds the life's attention, follow-ups first", threads))
end

-- ── event cards are harder, and the dread roll ──
do
	local life = grown(800, 60)
	life.age = 30
	local card = sim.eventsById["dr18_thumb_word"].choices[2].clash
	local plain = table.clone(card)
	local _, foeCard = sim:clashSides(life, card)
	local _, foePlain = sim:clashSides(life, plain)
	local H = pack.hardness
	check(foeCard.base >= foePlain.base + H.cardBase + H.dangerBase, string.format("a dangerous card's foe should be harder (%d vs %d)", foeCard.base, foePlain.base))
	check(foeCard.coins >= foePlain.coins, "a dangerous card's foe shouldn't have fewer coins")
	-- the difficulty scales it: gentler on A Gentler City, harder on the Backstreets at Night
	local saveDiff = life.difficulty
	life.difficulty = "story"
	local _, foeStory = sim:clashSides(life, card)
	local _, plainStory = sim:clashSides(life, plain)
	life.difficulty = "night"
	local _, foeNight = sim:clashSides(life, card)
	local _, plainNight = sim:clashSides(life, plain)
	life.difficulty = saveDiff
	check(foeStory.base - plainStory.base < foeCard.base - foePlain.base, "A Gentler City should make the harder cards only a little harder")
	check(foeNight.base - plainNight.base > foeCard.base - foePlain.base, "the Backstreets at Night should make the harder cards harder still")
	-- it grows with you
	life.stats.strength = 200
	local _, foeStrong = sim:clashSides(life, card)
	check(foeStrong.base > foeCard.base, "a dangerous card should grow with the stat you face it with")
	-- the dread roll sends one more dangerous card
	local saved = H.dread
	H.dread = { fromAge = 16, chance = 1 }
	local sent = 0
	for i = 1, 20 do
		local l = grown(900 + i, 40)
		l.age = 28
		l.queue = {}
		sim:rollDread(l)
		if #l.queue == 1 then
			local e = sim.eventsById[l.queue[1]]
			local danger = e.dread == true
			for _, t in e.tags or {} do
				if t == "danger" then
					danger = true
				end
			end
			check(danger, "the dread roll sent a card that isn't dangerous: " .. e.id)
			sent += 1
		end
	end
	H.dread = saved
	check(sent >= 15, "the dread roll at 100% should nearly always send a card (" .. sent .. " of 20)")
	local dread = 0
	for _, e in pack.events do
		if e.dread then
			dread += 1
		end
	end
	check(dread >= 10, "there should be at least ten dread cards (" .. dread .. ")")
	print(string.format("harder: a dangerous card's foe +%d base at 60 (+%d more at 200), %d dread cards, the dread roll sends them", foeCard.base - foePlain.base, foeStrong.base - foeCard.base, dread))
end

-- ── the harder the run, the richer the haul ──
do
	local Expedition = Loader.require(root.Engine.Expedition)
	local counts = { 0, 0, 0, 0, 0 }
	local top = nil
	for _, id in pack.expeditions.order do
		local def = pack.expeditions[id]
		local t = Expedition.tier(sim, def)
		counts[t] += 1
		if not top or t > Expedition.tier(sim, pack.expeditions[top]) then
			top = id
		end
	end
	check(counts[4] + counts[5] >= 3, "there should be a few tier IV-V runs (" .. counts[4] + counts[5] .. ")")
	check(pack.expeditionPay[5].money > pack.expeditionPay[3].money and pack.expeditionPay[3].money > 1, "higher tiers should pay more")
	print(string.format("expeditions by tier: I %d, II %d, III %d, IV %d, V %d (the top: %s)", counts[1], counts[2], counts[3], counts[4], counts[5], tostring(top)))
end

if fails > 0 then
	print(string.format("\n%d v0.18 checks failed.", fails))
	process.exit(1)
end
print("OK")
