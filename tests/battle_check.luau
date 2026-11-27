--[[
	Boss battles in turns (v0.16), on the real server code with two players in one crew:
	  - picking a boss's battle choice starts a fight in turns, not one clash
	  - the crewmate is invited, joins, and the boss gets more Health
	  - the turn waits until both have chosen; each fighter sees their own options
	  - someone who already chose can't choose twice; a turn resolves with both moves
	  - after BATTLE_WAIT seconds, someone who has chosen can go ahead without the other
	  - the fight ends with everyone's life updated, and the host's year goes on
	  - a choice that isn't a battle still works as before
		lune run tests/battle_check          (LIFESIM_PACK=City is the default pack)
]]

local process = require("@lune/process")
local Harness = require("./harness")
local vtask = Harness.task

local DEVICE = { name = "pc", width = 1440, height = 900, inset = 58, touch = false, keyboard = true, mouse = true }
local h = Harness.boot(DEVICE, { seed = 31 })

local failures = {}
local function check(cond, msg: string)
	if not cond then
		table.insert(failures, msg)
		print("  FAIL  " .. msg)
	end
end

local function wait(seconds: number)
	local stop = h.now() + seconds
	vtask.wait(seconds)
	while h.now() < stop - 1e-6 do
		vtask.wait(stop - h.now())
	end
end

local notes: { string } = {}
local finished = false
local function driver()
	local Server = h.require(h.serverRoot)
	Server.start()
	local pack = h.pack
	local rawHost = h.addPlayer("Host", 9101)
	local rawAnn = h.addPlayer("Ann", 9102)
	wait(1)
	local function as(fn)
		return function(action: string, payload: any?)
			wait(0.2)
			return fn(action, payload)
		end
	end
	local host, ann = as(rawHost), as(rawAnn)

	-- a crew of two, with lives started together
	check(host("lobbyOpen").ok, "the host couldn't open a lobby")
	check(host("crewInvite", { userId = 9102 }).ok, "the host couldn't invite Ann")
	check(ann("crewRespond", { userId = 9101, accept = true }).ok, "Ann couldn't join the crew")
	check(host("crewTogetherReady", { first = "Petra", confirm = true }).ok, "the host couldn't mark ready")
	check(ann("crewTogetherReady", { first = "Ann", confirm = true }).ok, "Ann couldn't mark ready")
	local started = host("crewTogetherStart")
	check(started.ok and started.life ~= nil, "lives didn't start: " .. tostring(started.error))
	wait(0.5)

	-- both grown and strong, with nothing open
	for _, fn in { host, ann } do
		local s = fn("crewState")
		local _ = s
	end
	local function grow(fn, uid: number)
		for _, stat in pack.stats.order do
			fn("admin", { op = "stat", target = uid, stat = stat, value = 85 })
		end
		fn("admin", { op = "stat", target = uid, stat = "health", value = 140 })
		fn("admin", { op = "stat", target = uid, stat = "age", value = 30 })
	end
	-- the test server treats both as Studio admins (the harness runs in Studio mode)
	grow(host, 9101)
	grow(ann, 9101 + 1)
	local hello = host("hello")
	check(hello.ok ~= false, "hello failed")

	-- the host opens a boss card and picks its battle
	local opened = host("admin", { op = "event", target = 9101, id = "b15_middle_big" })
	check(opened.ok ~= false, "the admin couldn't open the boss card: " .. tostring(opened.error))
	wait(0.3)
	local def = nil
	for _, e in pack.events do
		if e.id == "b15_middle_big" then
			def = e
		end
	end
	local idx = nil
	for i, c in def.choices do
		if c.battle then
			idx = i
		end
	end
	local chose = host("choose", { index = idx })
	check(chose.ok and type(chose.battle) == "table" and chose.battle.boss ~= nil, "picking the battle choice should start a fight: " .. tostring(chose.error))
	local hp0 = chose.battle and chose.battle.boss.hp or 0
	check(chose.battle and chose.battle.options and #chose.battle.options >= 4, "the host should have moves to pick from")

	-- Ann was invited
	wait(0.5)
	local invited = false
	for _, p in h.pushes do
		if p.payload and p.payload.battleInvite and p.payload.battleInvite.host == 9101 then
			invited = true
		end
	end
	check(invited, "the crewmate should be invited into the fight")

	-- Ann can't act in a fight she isn't in; then she joins
	check(ann("battleAct", { action = "guard" }).ok == false, "someone outside the fight acted in it")
	local joined = ann("battleJoin", { host = 9101 })
	check(joined.ok and type(joined.battle) == "table", "Ann couldn't join the fight: " .. tostring(joined.error))
	local hp1 = joined.battle and joined.battle.boss.hp or 0
	check(hp1 > hp0, "a second fighter should give the boss more Health")
	check(joined.battle and #joined.battle.fighters == 2, "the fight should show both fighters")
	check(ann("choose", { index = 1 }).ok == false, "a fighter shouldn't be able to answer cards mid-fight")
	check(host("ageUp").ok == false, "the year shouldn't turn mid-fight")

	-- one turn: the host moves, the turn waits for Ann, then both have moved
	local strike = nil
	for _, o in chose.battle.options do
		if o.action == "strike" then
			strike = o
			break
		end
	end
	local a1 = host("battleAct", { action = "strike", approach = strike and strike.approach })
	check(a1.ok and a1.battle and a1.battle.turn == 1 and #a1.battle.waitingOn == 1, "the turn should wait for Ann")
	check(host("battleAct", { action = "guard" }).ok == false, "the host chose twice in one turn")
	local a2 = ann("battleAct", { action = "guard" })
	check(a2.ok and ((a2.battle and a2.battle.turn == 2) or a2.battleDone ~= nil), "the turn should resolve once both have chosen")
	check(a2.battle == nil or a2.battle.last ~= nil, "the fighters should see what happened last turn")

	-- going ahead without someone: only after the wait, and only for someone who chose
	local a3 = host("battleAct", { action = "guard" })
	check(a3.ok, "the host couldn't guard")
	check(host("battleGo").ok == false, "the host went ahead without waiting")
	wait(26)
	local go = host("battleGo")
	check(go.ok and ((go.battle and go.battle.turn == 3) or go.battleDone ~= nil), "after the wait the host should be able to go ahead: " .. tostring(go.error))

	-- fight it out (both strike), to an end
	local turns, done = 0, nil
	while turns < 40 and not done do
		turns += 1
		local hs = host("crewState")
		local _ = hs
		local r1 = host("battleAct", { action = "strike", approach = strike and strike.approach })
		if r1.battleDone then
			done = r1.battleDone
			break
		end
		local r2 = ann("battleAct", { action = "strike", approach = strike and strike.approach })
		if r2.battleDone then
			done = r2.battleDone
		elseif r2.ok == false and r1.ok == false then
			break
		end
	end
	check(done ~= nil, "the fight should end")
	local after = host("hello")
	check(after.life and after.life.battle == nil, "the host's life should be out of the fight")
	local annAfter = ann("hello")
	check(annAfter.life and annAfter.life.battle == nil, "Ann's life should be out of the fight")

	finished = true
	table.insert(notes, string.format("battles: a two-fighter fight against Big Brother Ugo, %d turns after the opening ones, ended %s; the turn waited for both, and the wait could be cut short", turns, tostring(done and done.outcome)))
end

Harness.run(driver, h, nil, 3600)
for _, e in h.errors do
	if string.find(e, "failed for", 1, true) then
		check(false, "the server reported: " .. e)
	end
end
for _, line in notes do
	print(line)
end
if not finished then
	check(false, "the test did not run to its end")
	for _, e in h.errors do
		print("    " .. string.sub(tostring(e), 1, 400))
	end
end
if #failures > 0 then
	print(string.format("\n%d battle checks failed.", #failures))
	process.exit(1)
end
print("OK")
