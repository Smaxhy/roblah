--[[
	Duels in turns (v0.17), on the real server code with two players in one crew:
	  - a challenge accepted starts a duel in turns on both screens (not one roll)
	  - the turn waits until both have chosen; a choice can't be made twice; the other side
	    sees that you chose, not what
	  - mid-duel the year can't turn and no card can be answered
	  - after DUEL_WAIT seconds, someone who has chosen can go ahead without the other
	  - the duel ends with both lives updated and out of the duel
		lune run tests/duel_check
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

	-- Host challenges Ann; Ann accepts
	local ch = host("duelChallenge", { userId = 9102 })
	check(ch.ok, "the host couldn't challenge Ann: " .. tostring(ch.error))
	wait(0.3)
	local acc = ann("duelRespond", { userId = 9101, accept = true })
	check(acc.ok and type(acc.duel) == "table" and acc.duel.me ~= nil, "accepting should start a duel in turns: " .. tostring(acc.error))
	check(acc.duel and acc.duel.options and #acc.duel.options >= 6, "Ann should have her moves")
	local pushed = false
	for _, p in h.pushes do
		if p.payload and type(p.payload.duel) == "table" and p.payload.duel.me then
			pushed = true
		end
	end
	check(pushed, "the host should get the duel on screen too")

	-- one turn: the host chooses, the turn waits, the host can't choose twice
	local a1 = host("duelAct", { action = "guard" })
	check(a1.ok and a1.duel and a1.duel.me.chosen and not a1.duel.them.chosen and a1.duel.turn == 1, "the turn should wait for Ann")
	check(host("duelAct", { action = "feint" }).ok == false, "the host chose twice in one turn")
	check(ann("choose", { index = 1 }).ok == false, "a duelist shouldn't answer cards mid-duel")
	check(ann("ageUp").ok == false, "the year shouldn't turn mid-duel")
	local a2 = ann("duelAct", { action = "feint" })
	check(a2.ok and a2.duel and a2.duel.turn == 2, "the turn should resolve once both have chosen")
	check(a2.duel and a2.duel.last and #a2.duel.last.entries == 2, "both moves should be in the last turn")

	-- going ahead without the other: only after the wait
	check(host("duelAct", { action = "guard" }).ok, "the host couldn't guard")
	check(host("duelGo").ok == false, "the host went ahead without waiting")
	wait(26)
	local go = host("duelGo")
	check(go.ok and ((go.duel and go.duel.turn == 3) or go.duelDone ~= nil), "after the wait the host should be able to go ahead: " .. tostring(go.error))

	-- fight it out
	local turns, done = 0, nil
	while turns < 60 and not done do
		turns += 1
		local r1 = host("duelAct", { action = "strike", approach = "power" })
		if r1.duelDone then
			done = r1.duelDone
			break
		end
		local r2 = ann("duelAct", { action = "strike", approach = "speed" })
		if r2.duelDone then
			done = r2.duelDone
		elseif r1.ok == false and r2.ok == false then
			break
		end
	end
	check(done ~= nil and done.done, "the duel should end")
	local after = host("hello")
	check(after.life and after.life.alive, "the host should be alive after a friendly duel")
	check(host("duelAct", { action = "guard" }).ok == false, "the duel should be over for the host")
	local annAfter = ann("ageUp")
	check(annAfter.ok ~= false or annAfter.error ~= "Finish the fight first.", "Ann's life should be out of the duel")

	finished = true
	table.insert(notes, string.format("duels: a friendly duel in turns between two crewmates, %d turns after the opening ones; the turn waited for both, the wait could be cut short, and both lives came out of it", turns))
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
	print(string.format("\n%d duel checks failed.", #failures))
	process.exit(1)
end
print("OK")
