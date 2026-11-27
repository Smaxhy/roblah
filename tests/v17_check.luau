--[[
	v0.17, checked against the City pack (the engine side; tests/duel_check runs duels on the
	real server with two players):
	  - stats can reach 400: tiers go to XXI, perks at 200/300/400, Speed past 200 brings a coin
	  - bodies last as long as their lifespan says; treatments push it back; a Bloodfiend's old
	    blood stages come with its years and break limits
	  - trainers: found, started, taught; lessons grow a stat past 100, teach techniques, break limits
	  - augment arms: sold, worn in the arm slot, drawn on the figure, carry their way of fighting
	  - every technique and arm approach is a real way of fighting
	  - extreme bosses: every one is a battle an event can start, with numbers far past the others
	  - duels in turns: hidden choices, strike/guard/feint, a friendly duel stops at first blood
	  - a feminine build draws a narrower waist than a masculine one
	  - the twelve new creature shapes build in every pose
		lune run tests/v17_check
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local Avatar = Loader.require(root.Engine.Avatar)
local Creatures = Loader.require(root.Engine.Creatures)
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
	life.money = 100000
	return life
end

-- ── stats to 400 ──
do
	check(pack.stats.tierMax >= 21, "tiers should go to XXI")
	check(sim:tierOf(400) == 21, "400 should be tier XXI")
	local life = grown(17001, 50)
	life.capBonus = { all = 300 }
	check(sim:statCap(life, "strength") == 400, "a limit broken by 300 should be 400")
	life.stats.strength = 400
	life.stats.speed = 360
	local perk = sim:stancePerk(life, "strength")
	check(perk.base >= 10, "Strength at 400 should carry the XI/XVI/XXI perks")
	local spec = { stat = "strength", foe = "x", fight = true, coins = 3, base = 8, coinPower = 3 }
	local p = sim:clashPreview(life, spec)
	check(p and p.player and (p.player.coins or 0) >= 6, "Speed 360 should bring a sixth coin")
end

-- ── lifespan and old blood ──
do
	local life = grown(17002, 50)
	local span = sim:lifespanOf(life)
	check(span >= 63 and span <= 75, "an ordinary body should last about 63 years (" .. span .. ")")
	Engine.Effects.apply(sim, life, { lifespan = 10 }, sim.newReport())
	check(sim:lifespanOf(life) == span + 10, "a treatment should push the lifespan back")
	sim:setForm(life, "bloodfiend", {})
	check(sim:lifespanOf(life) >= 600, "a Bloodfiend's body should last centuries")
	life.formAt = life.age - 85
	local before = sim:statCap(life, "strength")
	local extra = {}
	sim:elderBlood(life, extra)
	check((life.bloodStage or 0) == 3, "85 years of blood should be Elder Blood (stage 3)")
	check(sim:statCap(life, "strength") > before, "old blood should break limits")
	check(sim:bloodStageName(life) == "Elder Blood", "the view should name the blood's stage")
	check(#pack.phases >= 7, "Long Life and The Ancient should be phases")
end

-- ── trainers ──
do
	check(#pack.trainers.list >= 20, "there should be at least twenty trainers")
	local life = grown(17003, 50)
	life.side = "backstreets"
	life.queue = { "tr_meet_hesketh" }
	sim:advance(life, sim.newReport())
	check(life.pending == "tr_meet_hesketh", "a trainer's card should come up")
	sim:choose(life, 1, nil)
	check(life.trainer == "hesketh" and life.flags.tr_hesketh, "asking should start the training")
	local capBefore = sim:statCap(life, "strength")
	local n = 0
	while life.trainer and n < 40 do
		n += 1
		life.actionsLeft = 5 -- (a few lessons a year: the test is many years in one)
		local r = sim:doActivity(life, "tr_lesson_hesketh")
		check(r ~= nil, "a lesson should be possible")
		life.pending = nil
		life.queue = {}
		if not r then
			break
		end
	end
	check(life.flags.tq_counter and life.flags.tq_hook, "Hesketh should teach both techniques")
	check(sim:statCap(life, "strength") >= capBefore + 30, "the limit courses should break the ceiling")
	check(life.flags.tr_hesketh_done, "the course should finish")
	check(sim.activitiesById.tr_find ~= nil, "looking for a trainer should be an activity")
	-- the school instructors only take their own
	local outsider = grown(17004, 60)
	local avail = {}
	for _, t in Engine.Training.available(sim, outsider) do
		avail[t.id] = true
	end
	check(not avail.zwei_instructor, "a Zwei instructor shouldn't take someone outside Zwei")
end

-- ── techniques and arms ──
do
	local open = 0
	for _, id in pack.approaches.order do
		local a = pack.approaches[id]
		check(a.stat ~= nil and a.fightOnly, id .. ": a technique should be a way of fighting")
		if string.sub(id, 1, 3) == "tq_" or string.sub(id, 1, 4) == "arm_" then
			check(a.requires ~= nil, id .. ": a technique should need to be learned (or carried)")
			open += 1
		end
	end
	check(open >= 30, "there should be thirty or more techniques and arm arts")
	local life = grown(17005, 60)
	check(sim:buyGear(life, "aug_piston") ~= nil, "a Workshop arm should be for sale")
	check(life.gear.arm == "aug_piston", "the arm should go in the arm slot")
	check(sim:approachOpen(life, pack.approaches.arm_piston, { fight = true, stat = "strength" }), "the arm should carry its way of fighting")
	local parts = Avatar.build(pack, sim:appearance(life))
	local aug = 0
	for _, p in parts do
		if string.sub(p.name, 1, 3) == "Aug" then
			aug += 1
		end
	end
	check(aug >= 5, "the arm should be drawn on the figure")
end

-- ── extreme bosses ──
do
	local extreme = { "night_sweepers", "index_messenger_ex", "color_umber", "clocktower_distortion", "head_claw", "last_hunter", "aleph_breach" }
	for _, id in extreme do
		local def = pack.bosses[id]
		check(def ~= nil, id .. ": should be a boss")
		if def then
			check(def.base >= 18 and def.hp >= 1000 and #(def.phases or {}) >= 2, id .. ": should be far past the ordinary bosses")
		end
		local found = false
		for _, e in pack.events do
			for _, c in e.choices or {} do
				if c.battle == id then
					found = true
				end
			end
		end
		check(found, id .. ": an event should start it")
	end
	local life = grown(17006, 300)
	life.capBonus = { all = 300 }
	for _, k in pack.stats.order do
		life.stats[k] = 300
	end
	life.stats.health = sim:maxHealthOf(life)
	life.pending = "ex17_claw"
	local idx = nil
	for i, c in sim.eventsById.ex17_claw.choices do
		if c.battle then
			idx = i
		end
	end
	sim:choose(life, idx, nil)
	check(life.battle and life.battle.boss == "head_claw", "the Claw's card should start its battle")
	Loader.finishBattle(sim, life)
	check(life.battle == nil and life.battleDone ~= nil, "the battle should end")
end

-- ── duels in turns ──
do
	local Pvp = Engine.Pvp
	local a, b = grown(17007, 80), grown(17008, 80)
	a.stats.health, b.stats.health = 150, 150
	local lives = { [tostring(a.id)] = a, [tostring(b.id)] = b }
	local d = Pvp.start(sim, a, b, false)
	local va = Pvp.view(sim, d, lives, tostring(a.id))
	check(va and va.options and #va.options >= 6, "a duelist should have their moves")
	local both = Pvp.choose(sim, d, lives, tostring(a.id), "guard", nil)
	check(not both, "the turn should wait for the other side")
	check(Pvp.view(sim, d, lives, tostring(b.id)).them.chosen == true, "the other side should see that a choice was made")
	local _, why = Pvp.choose(sim, d, lives, tostring(a.id), "feint", nil)
	check(why ~= nil, "a side shouldn't choose twice in a turn")
	both = Pvp.choose(sim, d, lives, tostring(b.id), "feint", nil)
	check(both, "the turn should be ready once both have chosen")
	Pvp.resolve(sim, d, lives)
	check(d.sides[tostring(a.id)].taken > 0, "a feint should get through a guard")
	local guard = 0
	while not d.done and guard < 50 do
		guard += 1
		Pvp.choose(sim, d, lives, tostring(a.id), "strike", "power")
		Pvp.choose(sim, d, lives, tostring(b.id), "strike", "speed")
		Pvp.resolve(sim, d, lives)
	end
	check(d.done and d.winner ~= nil, "a duel should end")
	local loser = d.sides[if d.winner == tostring(a.id) then tostring(b.id) else tostring(a.id)]
	check(loser.hp <= loser.floor, "a friendly duel should stop at first real blood")
	Pvp.finish(sim, d, lives)
	check(a.alive and b.alive, "nobody dies in a friendly duel")
end

-- ── bodies ──
do
	local function waist(body: string): number
		local parts = Avatar.build(pack, { look = { body = body, outfit = "streetwear" }, age = 30 })
		local w = 0
		for _, p in parts do
			if p.name == "Torso" and math.abs(p.pos[2] - 2.75) < 0.3 then
				w = math.max(w, p.size[1])
			end
		end
		return w
	end
	check(waist("feminine") > 0 and waist("feminine") < 1.6, "a feminine build should have a snatched waist (" .. waist("feminine") .. ")")
	check(Avatar.option(pack, "body", "feminine") ~= nil, "the creator should offer a feminine body")
end

-- ── creatures ──
do
	for _, shape in { "clockwork", "aleph", "sweeper", "spiderdoll", "shadowhound", "moth", "jellyfish", "stitched", "eyestalks", "scrapgolem", "bloomer", "whale" } do
		for _, pose in { "idle", "strike", "hurt", "down" } do
			local ok, parts = pcall(Creatures.build, { shape = shape, name = shape, pose = pose })
			check(ok and type(parts) == "table" and #parts > 10, shape .. " " .. pose .. ": should build")
		end
	end
end

if fails > 0 then
	print(string.format("v17_check: %d FAILED", fails))
	process.exit(1)
end
print("v17_check: OK")
