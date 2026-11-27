--[[
	The lobby (v0.12): starting lives together, on the real server code with three players.
	  - "With friends" opens a lobby; whoever leads the crew is the host
	  - only the host can change the settings; every value is checked against the pack
	  - a mode that has its own age brings it along, and that age can't then be changed
	  - what the others see of your character went through the name filter and the look check
	  - starting needs everyone ready, and only the host can do it
	  - everyone starts in the SAME age, year, District and (when chosen) side of the wall,
	    on the host's difficulty, already friends; a family tied to another District or side
	    is never rolled
	  - "the City decides" still gives everyone one age and one District
	  - there is no unlinking: the server refuses it
		lune run tests/lobby_check          (LIFESIM_PACK=City is the default pack)
]]

local process = require("@lune/process")
local Harness = require("./harness")
local vtask = Harness.task

local DEVICE = { name = "pc", width = 1440, height = 900, inset = 58, touch = false, keyboard = true, mouse = true }
local h = Harness.boot(DEVICE, { seed = 12 })

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
	local rawHost = h.addPlayer("Host", 9001)
	local rawAnn = h.addPlayer("Ann", 9002)
	local rawBo = h.addPlayer("Bo", 9003)
	wait(1)
	-- (the server allows eight requests a second per player: a pause before each)
	local function as(fn)
		return function(action: string, payload: any?)
			wait(0.2)
			return fn(action, payload)
		end
	end
	local host, ann, bo = as(rawHost), as(rawAnn), as(rawBo)

	-- ── opening it ──
	local opened = host("lobbyOpen")
	check(opened.ok and opened.lobbyOpen == true, "the host couldn't open a lobby: " .. tostring(opened.error))
	check(opened.crew and opened.crew.captain == true and opened.crew.lobby and opened.crew.lobby.open == true, "the lobby should be on the host's crew, with them as host")
	local firstMode = pack.modes and pack.modes[1] and pack.modes[1].id
	check(opened.crew.lobby.mode == firstMode, "a new lobby begins on the first way to begin")
	check(opened.crew.lobby.era == nil and opened.crew.lobby.district == nil and opened.crew.lobby.side == nil, "a new lobby leaves the age and the place to the City")
	check(opened.crew.lobby.difficulty == pack.difficulties.default, "a new lobby is on the pack's own difficulty")

	-- ── the others come in ──
	check(host("crewInvite", { userId = 9002 }).ok, "the host couldn't invite Ann")
	check(host("crewInvite", { userId = 9003 }).ok, "the host couldn't invite Bo")
	local joinedA = ann("crewRespond", { userId = 9001, accept = true })
	local joinedB = bo("crewRespond", { userId = 9001, accept = true })
	check(joinedA.ok and joinedA.crew and #joinedA.crew.members == 2 and joinedA.crew.lobby and joinedA.crew.lobby.open == true, "Ann should land in the host's lobby")
	check(joinedB.ok and joinedB.crew and #joinedB.crew.members == 3 and joinedB.crew.captain ~= true, "Bo should be in the lobby, and not its host")

	-- ── only the host decides ──
	local era = pack.calendar.eras[#pack.calendar.eras].id
	local district = pack.districts.order[2]
	local side = pack.sides.order[1]
	local sneaky = ann("lobbySet", { key = "era", value = era })
	check(sneaky.ok == false, "someone who isn't the host changed the age")
	check(bo("lobbySet", { key = "district", value = district }).ok == false, "someone who isn't the host changed the District")
	check(ann("crewTogetherStart").ok == false, "someone who isn't the host started everyone's lives")

	-- ── every value is checked ──
	check(host("lobbySet", { key = "era", value = "the_future" }).ok == false, "an age that doesn't exist was accepted")
	check(host("lobbySet", { key = "district", value = "order" }).ok == false, "'order' isn't a District")
	check(host("lobbySet", { key = "district", value = "nowhere" }).ok == false, "a District that doesn't exist was accepted")
	check(host("lobbySet", { key = "side", value = "the_moon" }).ok == false, "a side that doesn't exist was accepted")
	check(host("lobbySet", { key = "difficulty", value = "order" }).ok == false, "'order' isn't a difficulty")
	check(host("lobbySet", { key = "difficulty", value = "default" }).ok == false, "'default' isn't a difficulty")
	check(host("lobbySet", { key = "mode", value = "godmode" }).ok == false, "a way to begin that doesn't exist was accepted")
	check(host("lobbySet", { key = "nonsense", value = 1 }).ok == false, "a setting that doesn't exist was accepted")
	check(host("lobbySet", "era").ok == false, "a request that isn't a table was accepted")

	-- ── the host sets the City ──
	local hard = pack.difficulties.order[#pack.difficulties.order]
	check(host("lobbySet", { key = "era", value = era }).ok, "the host couldn't set the age")
	check(host("lobbySet", { key = "district", value = district }).ok, "the host couldn't set the District")
	check(host("lobbySet", { key = "side", value = side }).ok, "the host couldn't set the side")
	local set = host("lobbySet", { key = "difficulty", value = hard })
	check(set.ok and set.crew.lobby.era == era and set.crew.lobby.district == district and set.crew.lobby.side == side and set.crew.lobby.difficulty == hard, "the lobby should carry what the host set")
	local seen = ann("crewState")
	check(seen.crew.lobby.era == era and seen.crew.lobby.district == district and seen.crew.lobby.side == side and seen.crew.lobby.difficulty == hard, "the others should see what the host set")

	-- ── a way to begin that has its own age brings it along ──
	local aged = nil
	for _, m in pack.modes or {} do
		if m.era and not m.unlock then
			aged = m
		end
	end
	if aged then
		local r = host("lobbySet", { key = "mode", value = aged.id })
		check(r.ok and r.crew.lobby.mode == aged.id and r.crew.lobby.era == aged.era, aged.name .. " should bring its own age with it")
		check(host("lobbySet", { key = "era", value = era }).ok == false, "the age was changed under a way to begin that has its own")
		check(host("lobbySet", { key = "mode", value = firstMode }).ok, "the host couldn't go back to the first way to begin")
		check(host("lobbySet", { key = "era", value = era }).ok, "the host couldn't set the age again")
	end
	-- a locked way to begin stays locked
	for _, m in pack.modes or {} do
		if m.unlock then
			check(host("lobbySet", { key = "mode", value = m.id }).ok == false, m.name .. " is locked, and the host set it anyway")
		end
	end

	-- ── making characters ──
	check(host("crewTogetherStart").ok == false, "lives started before anyone was ready")
	local okLook = { skin = pack.cosmetics.skin.options[1].id }
	local readyH = host("crewTogetherReady", { first = "Petra", look = okLook, era = "the_future", district = "nowhere", mode = "godmode", confirm = true })
	check(readyH.ok and readyH.crew.together.youReady == true, "the host couldn't mark ready")
	check(host("crewTogetherStart").ok == false, "lives started with two people still choosing")
	-- a name with things in it that aren't letters, and a look made of nonsense
	local readyA = ann("crewTogetherReady", { first = "M1r@<b>a", look = { skin = "not_a_skin", hair = 12, outfit = { "x" }, extra = "junk" }, confirm = true })
	check(readyA.ok, "Ann couldn't mark ready")
	local made = readyA.crew.together.made and readyA.crew.together.made["9002"]
	check(made ~= nil, "what Ann made should be there for the others to see")
	if made then
		check(made.first == nil or string.match(made.first, "^[%a%-' ]+$") ~= nil, "a shown name must be letters only (got " .. tostring(made.first) .. ")")
		check(type(made.look) == "table" and made.look.skin ~= "not_a_skin" and made.look.extra == nil and type(made.look.hair) ~= "number", "a shown look must be checked against the pack")
	end
	check(bo("crewTogetherReady", { first = "Bo", confirm = true }).ok, "Bo couldn't mark ready")
	local all = host("crewState")
	check(all.crew.together.everyone == true, "everyone is ready now")

	-- ── the start: one age, one year, one District, one side, the host's difficulty ──
	local started = host("crewTogetherStart")
	check(started.ok and started.life ~= nil, "the host couldn't start everyone's lives: " .. tostring(started.error))
	wait(0.5)
	local lives = {}
	for name, fn in { Host = host, Ann = ann, Bo = bo } do
		local st = fn("friends")
		lives[name] = st.life
		check(st.ok and st.life ~= nil and st.life.alive == true, name .. " should be living a life now")
	end
	local hl = lives.Host
	if hl and lives.Ann and lives.Bo then
		for name, life in lives do
			check(life.district.id == district, name .. " was born in " .. tostring(life.district.id) .. ", not the host's " .. district)
			check(life.side.id == side, name .. " was born on the " .. tostring(life.side.id) .. " side, not the host's " .. side)
			check(life.year == hl.year, name .. " was born in another year than the host")
			check(life.bornEra == era, name .. " was born into " .. tostring(life.bornEra) .. ", not the host's " .. era)
			check(life.difficulty ~= nil and life.difficulty.id == hard, name .. " isn't on the host's difficulty")
			local links = 0
			for _, rel in life.relations or {} do
				if rel.linked then
					links += 1
					-- (v0.12) how strong a linked friend is right now comes with them
					check(type(rel.sheet) == "table" and type(rel.sheet.stats) == "table" and rel.sheet.maxHealth ~= nil, name .. " should see " .. tostring(rel.name) .. "'s current stats")
				end
			end
			check(links == 2, name .. " should be linked with the other two (has " .. links .. ")")
		end
	end
	local after = host("crewState")
	check(after.crew ~= nil and after.crew.lobby == nil and after.crew.together == nil, "the lobby should be gone once the lives have begun (the crew stays)")

	-- ── "the City decides": still one age and one District for everybody ──
	local seenDistricts, seenEras = {}, {}
	for round = 1, 6 do
		check(host("lobbyOpen").ok, "the host couldn't open a second lobby")
		for _, fn in { host, ann, bo } do
			check(fn("crewTogetherReady", { first = "Again", confirm = true }).ok, "someone couldn't ready up in round " .. round)
		end
		local again = host("crewTogetherStart")
		check(again.ok, "round " .. round .. " didn't start: " .. tostring(again.error))
		wait(0.3)
		local a, b, c = host("friends").life, ann("friends").life, bo("friends").life
		if a and b and c then
			check(a.district.id == b.district.id and b.district.id == c.district.id, "round " .. round .. ": the City put them in different Districts")
			check(a.year == b.year and b.year == c.year, "round " .. round .. ": the City gave them different years")
			check(a.bornEra == b.bornEra and b.bornEra == c.bornEra and a.bornEra ~= nil, "round " .. round .. ": the City gave them different ages")
			seenDistricts[a.district.id] = true
			seenEras[a.bornEra] = true
		end
	end
	local nd, ne = 0, 0
	for _ in seenDistricts do
		nd += 1
	end
	for _ in seenEras do
		ne += 1
	end
	check(nd >= 2, "six rounds of 'the City decides' all landed in one District")

	-- ── a chosen side is everyone's side, in every District ──
	for _, wantSide in pack.sides.order do
		for i = 1, 3 do
			local d = pack.districts.order[((i * 5) % #pack.districts.order) + 1]
			check(host("lobbyOpen").ok, "the host couldn't open a lobby for the side test")
			check(host("lobbySet", { key = "side", value = wantSide }).ok and host("lobbySet", { key = "district", value = d }).ok, "the host couldn't set a side and a District")
			for _, fn in { host, ann, bo } do
				fn("crewTogetherReady", { first = "Side", confirm = true })
			end
			local r = host("crewTogetherStart")
			check(r.ok, "the side test didn't start: " .. tostring(r.error))
			wait(0.3)
			for name, fn in { Host = host, Ann = ann, Bo = bo } do
				local life = fn("friends").life
				check(life ~= nil and life.side.id == wantSide and life.district.id == d, string.format("%s should be on the %s side of %s (is %s of %s)", name, wantSide, d, life and life.side.id or "?", life and life.district.id or "?"))
			end
		end
	end

	-- ── there is no unlinking ──
	local refused = ann("unlink", { userId = 9001 })
	check(refused.ok == false, "the server let someone unlink")
	local still = ann("friends")
	local kept = false
	for _, link in (still.friends and still.friends.links) or {} do
		if link.userId == 9001 then
			kept = true
		end
	end
	check(kept, "a refused unlink still dropped the link")

	-- ── lives that age together stay together ──
	local function lifeOf(fn)
		return fn("friends").life
	end
	local function settle(fn)
		for _ = 1, 40 do
			local life = lifeOf(fn)
			if not (life and life.alive and life.pending) then
				return life
			end
			local pick = 1
			for _, c in life.pending.choices do
				if c.enabled then
					pick = c.index
					break
				end
			end
			fn("choose", { index = pick })
		end
		return lifeOf(fn)
	end
	local a0, b0, c0 = settle(host), settle(ann), settle(bo)
	-- ── what you do with a linked friend happens in their life too ──
	if a0 and b0 and a0.alive and b0.alive then
		local function relWith(life, userId)
			local found, n = nil, 0
			for _, r in life.relations do
				if r.userId == userId then
					found = r
					n += 1
				end
			end
			return found, n
		end
		local mine, nMine = relWith(a0, 9002)
		local theirs, nTheirs = relWith(b0, 9001)
		check(nMine == 1 and nTheirs == 1, string.format("a friend you started with is listed once (host sees Ann %d times, Ann sees the host %d times)", nMine, nTheirs))
		if mine and theirs then
			local sent = nil
			for _, act in mine.interactions or {} do
				if act.id == "send_word" and act.enabled then
					sent = host("interact", { relId = mine.id, id = "send_word" })
				end
			end
			if sent and sent.ok then
				wait(0.4)
				local mine2 = relWith(lifeOf(host), 9002)
				local theirs2 = relWith(lifeOf(ann), 9001)
				check(mine2.bond - mine.bond ~= 0, "sending word should move the bond")
				check(theirs2.bond - theirs.bond == mine2.bond - mine.bond, string.format("both friends agree on the bond (host %+d, Ann %+d)", mine2.bond - mine.bond, theirs2.bond - theirs.bond))
				table.insert(notes, string.format("linked: the host sent word, and the bond moved %+d in both lives", mine2.bond - mine.bond))
			else
				check(false, "the host couldn't send word to Ann: " .. tostring(sent and sent.error))
			end
		end
		a0, b0, c0 = settle(host), settle(ann), settle(bo)
	end
	if a0 and b0 and c0 and a0.alive and b0.alive and c0.alive then
		check(a0.age == b0.age and b0.age == c0.age, "the three should have started at one age")
		host("ageUp")
		ann("ageUp")
		check(lifeOf(host).age == a0.age, "the year should wait until everyone is ready")
		-- Bo is handed a card while the others wait: nobody's year may turn without him
		local card = nil
		for _, e in pack.events do
			-- (an ordinary card: not a boss's, whose first choice starts a battle in turns)
			local battle = false
			for _, c in e.choices or {} do
				if c.battle then
					battle = true
				end
			end
			if e.choices and not e.when and not e.story and not e.social and not battle then
				card = e.id
				break
			end
		end
		local handed = host("admin", { op = "event", target = 9003, id = card })
		wait(0.3)
		local boLife = lifeOf(bo)
		if handed.ok and boLife.pending then
			-- the host waited long enough to go without him, and tries to
			wait(25)
			local forced = host("crewAgeNow")
			check(forced.ok ~= true or forced.waiting == true or lifeOf(host).age == a0.age, "the host could turn the year while Bo had a card to answer")
			check(lifeOf(host).age == a0.age and lifeOf(ann).age == a0.age and lifeOf(bo).age == a0.age, "nobody's year should turn while one of them has a card")
			settle(bo)
			-- (answering a card can lead to another; the three ready up again once all are clear)
			settle(host)
			settle(ann)
			host("ageUp")
			ann("ageUp")
			bo("ageUp")
			wait(0.4)
			local a1, b1, c1 = lifeOf(host), lifeOf(ann), lifeOf(bo)
			if a1.alive and b1.alive and c1.alive then
				check(a1.age == a0.age + 1 and b1.age == a1.age and c1.age == a1.age, string.format("all three should turn the year together (%d, %d, %d from %d)", a1.age, b1.age, c1.age, a0.age))
			end
			-- the host goes ahead after the wait: it takes everyone, ready or not
			settle(host)
			settle(ann)
			settle(bo)
			local a2 = lifeOf(host)
			if a2.alive and lifeOf(ann).alive and lifeOf(bo).alive then
				host("ageUp")
				wait(25)
				local go = host("crewAgeNow")
				wait(0.4)
				local a3, b3, c3 = lifeOf(host), lifeOf(ann), lifeOf(bo)
				check(go.ok ~= false, "the host couldn't go ahead after the wait: " .. tostring(go.error))
				check(a3.age == a2.age + 1 and b3.age == a3.age and c3.age == a3.age, string.format("going ahead should take everyone (%d, %d, %d from %d)", a3.age, b3.age, c3.age, a2.age))
				table.insert(notes, string.format("ageing together: a card held the year for all three; then %d -> %d together; the host's go-ahead took everyone to %d", a0.age, a0.age + 1, a3.age))
			end
		else
			check(false, "couldn't hand Bo a card to test with: " .. tostring(handed.error))
		end
	end

	-- ── the host leaving hands the lobby on ──
	check(host("lobbyOpen").ok, "the host couldn't open a last lobby")
	host("crewLeave")
	wait(0.3)
	local handed = ann("crewState")
	check(handed.crew ~= nil and handed.crew.captain == true and handed.crew.lobby ~= nil, "when the host leaves, the next member should hold the lobby")
	check(ann("lobbySet", { key = "difficulty", value = pack.difficulties.order[1] }).ok, "the new host couldn't change a setting")

	finished = true
	table.insert(notes, string.format("lobby: host-only settings, checked values, one age / year / District / side for all (%d Districts and %d ages seen over six open rounds), no unlinking", nd, ne))
end

Harness.run(driver, h, nil, 3600)
for _, e in h.errors do
	-- warnings the server printed while the test ran (a failed handler shows up here)
	if string.find(e, "failed for", 1, true) then
		check(false, "the server reported: " .. e)
	end
end
if #h.kicked > 0 then
	check(false, "a player was kicked: " .. tostring(h.kicked[1]))
end
for _, line in notes do
	print(line)
end
if not finished then
	-- the driver stopped before its last line: an error in it, or it ran out of time
	check(false, "the test did not run to its end")
	for _, e in h.errors do
		print("    " .. string.sub(tostring(e), 1, 400))
	end
end
if #failures > 0 then
	print(string.format("\n%d lobby checks failed.", #failures))
	process.exit(1)
end
print("OK")
