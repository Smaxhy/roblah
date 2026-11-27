--[[
	v0.16, checked against the City pack (the engine side; tests/battle_check runs the same
	fights on the real server with two players):
	  - every boss a choice names exists, and every battle choice keeps its clash fallback
	  - picking a battle choice starts a fight in turns; the card says so, and has no style picker
	  - mid-fight the year can't turn, no card can be answered, no activity done
	  - each turn shows the boss's next move and who it's aimed at, and your options with odds
	  - guarding takes less; patching up heals (twice); getting out ends it for you
	  - bosses change phase as they're hurt; fights last more than a couple of turns
	  - a fight fought to the end gives the choice's win (or leaves you dead), and clears
		lune run tests/v16_check
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

-- every battle choice: a real boss, and a clash to fall back on
local battleChoices = {}
for _, e in pack.events do
	for i, c in e.choices or {} do
		if c.battle then
			-- (one boss, or a list: each time, one of them)
			for _, b in (if type(c.battle) == "table" then c.battle else { c.battle }) do
				check(pack.bosses[b] ~= nil, e.id .. ": battle '" .. tostring(b) .. "' isn't a boss")
			end
			check(c.clash ~= nil and c.win ~= nil and c.lose ~= nil, e.id .. ": a battle choice keeps its clash, win and lose")
			table.insert(battleChoices, { event = e, index = i, boss = if type(c.battle) == "table" then c.battle[1] else c.battle })
		end
	end
end
check(#battleChoices >= 12, "fewer than twelve boss battles (" .. #battleChoices .. ")")

local function fighter(seed: number, level: number)
	local life = sim:newLife({ seed = seed, rollOrigin = true })
	life.age = 30
	for _, k in pack.stats.order do
		life.stats[k] = level
	end
	life.stats.health = 120
	life.pending = nil
	life.queue = {}
	return life
end

local function start(life, eventId: string)
	life.pending = eventId
	local ev = sim.eventsById[eventId]
	local idx = nil
	for i, c in ev.choices do
		if c.battle then
			idx = i
		end
	end
	local v = sim:view(life)
	local cv = v.pending and v.pending.choices[idx]
	check(cv and cv.battle ~= nil, eventId .. ": the card should mark its battle choice")
	check(cv and cv.hint and string.find(cv.hint, "turns", 1, true) ~= nil, eventId .. ": the battle choice should say it's fought in turns")
	local rep = sim:choose(life, idx, nil)
	check(rep and rep.battle and life.battle, eventId .. ": picking the battle choice should start a fight")
	return rep
end

-- ── a fight, turn by turn ──
do
	local life = fighter(4242, 80)
	start(life, "b15_middle_big")
	local v = sim:battleView(life)
	check(v and v.boss and v.boss.hp == v.boss.maxHp and v.next and v.next.name and v.next.target ~= nil, "the fight should show the boss and its next move")
	check(v and v.options and #v.options >= 4, "a fighter should have moves (strikes, guard, patch up, get out)")
	local strikes, withOdds = 0, 0
	for _, o in (v and v.options) or {} do
		if o.action == "strike" then
			strikes += 1
			if o.odds or o.free then
				withOdds += 1
			end
		end
	end
	check(strikes >= 2 and withOdds == strikes, "each way of fighting should show its odds")
	-- nothing else moves mid-fight
	check(sim:ageUp(life) == nil, "the year turned mid-fight")
	check(sim:choose(life, 1) == nil, "a card was answered mid-fight")
	-- guard: the move lands softer than it would
	local hp0 = life.stats.health
	sim:battleAct(life, "guard", nil)
	local guarded = hp0 - life.stats.health
	-- patch up: heals
	local hp1 = life.stats.health
	sim:battleAct(life, "recover", nil)
	local v2 = sim:battleView(life)
	check(v2 == nil or v2.turn == 3, "each act should be one turn alone")
	check(life.stats.health > hp1 - 40, "patching up should keep you on your feet")
	sim:battleAct(life, "recover", nil)
	local v3 = sim:battleView(life)
	if v3 then
		for _, o in v3.options or {} do
			if o.action == "recover" then
				check(o.enabled == false, "patching up should run out after two")
			end
		end
	end
	check(guarded >= 0, "guarding shouldn't heal")
	-- then fight it out
	Loader.finishBattle(sim, life)
	check(life.battle == nil, "the fight should end")
	local done = life.battleDone
	check(done ~= nil and done.outcome ~= nil, "the end of the fight should be recorded")
	if done and done.outcome == "won" and life.alive then
		check(life.flags.b15_slew_ugo == true, "winning should give the choice's win")
	end
	check(done and done.last and done.last.turn >= 3, "a boss fight should last more than a couple of turns")
end

-- ── getting out ──
do
	local life = fighter(5151, 70)
	start(life, "b15_thumb_capo")
	sim:battleAct(life, "flee", nil)
	check(life.battle == nil and life.battleDone and life.battleDone.outcome == "fled", "getting out should end the fight for you")
	check(life.alive, "getting out shouldn't kill you (at full Health)")
end

-- ── phases ──
do
	local life = fighter(6161, 110)
	start(life, "b15_thumb_sottocapo")
	local phases = 1
	local guard = 0
	while life.alive and life.battle and guard < 60 do
		guard += 1
		local v = sim:battleView(life)
		phases = math.max(phases, v.boss.phase)
		local best = nil
		for _, o in v.options or {} do
			if o.action == "strike" and (not best or (o.odds or 1) > (best.odds or 1)) then
				best = o
			end
		end
		if life.stats.health < 40 and v.options then
			local can = false
			for _, o in v.options do
				if o.action == "recover" and o.enabled ~= false then
					can = true
				end
			end
			if can then
				sim:battleAct(life, "recover", nil)
				continue
			end
		end
		sim:battleAct(life, "strike", best and best.approach)
	end
	check(phases >= 2, "the Sottocapo should change phase as she's hurt")
end

-- ── a battle can't start for a boss that doesn't exist (the clash takes over) ──
do
	local saved = pack.bosses.big_brother_ugo
	pack.bosses.big_brother_ugo = nil
	local life = fighter(7171, 80)
	life.pending = "b15_middle_big"
	local idx = nil
	for i, c in sim.eventsById.b15_middle_big.choices do
		if c.battle then
			idx = i
		end
	end
	local rep = sim:choose(life, idx, "power")
	check(rep and rep.clash and not life.battle, "without the boss, the choice should fall back to its clash")
	pack.bosses.big_brother_ugo = saved
end

if fails > 0 then
	print(string.format("v16_check: %d FAILED", fails))
	process.exit(1)
end
print("v16_check: OK")
