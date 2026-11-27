--[[
	Crews: groups of players (in the same server) who go on expeditions together.

	* Anyone can start a crew and invite others (up to 4 people).
	* The captain proposes an expedition. Everyone gets a ready check and must
	  accept within READY_SECONDS, or it's called off.
	* On the run, EVERYONE chooses (v0.16): each member picks an option, and the run moves
	  once everyone still on it has picked. The most-picked option is what the crew does
	  (a tie goes the captain's way). After VOTE_WAIT seconds the captain can go with the
	  picks so far. Every member's life gets the results; clashes are fought by the crew's
	  best at that stat, with +1 coin per extra member (Engine/Expedition).
	* Leaving mid-run drops you out (your life keeps what happened so far).
	* THE LOBBY (v0.12): how lives are started together. Whoever leads the crew is the host.
	  The host decides the age everyone is born into, the District, the side of the wall,
	  how hard the City is and how everyone begins; nobody else can change those. Everyone
	  makes a character and marks ready; then the host starts every life at once: one age,
	  one year, one District, already friends.
	* Aging up together: in a crew with two or more living characters, Age Up is a ready
	  check. Each press marks you ready; the year turns for everyone once all are. After
	  AGE_WAIT seconds the captain can go ahead with whoever is ready. The captain can
	  switch it off (crewSyncAge).

	Installed by the server with Crews.install(S), where S carries the shared
	helpers (sim, sessions, pushTo, handlers...).
]]

local Players = game:GetService("Players")

local Crews = {}

local MAX_CREW = 4
local READY_SECONDS = 60
local INVITE_SECONDS = 120
local AGE_WAIT = 20
local VOTE_WAIT = 20

function Crews.install(S)
	local sim = S.sim
	local Expedition = S.Expedition
	local handlers = S.handlers

	local crews = {} -- [crewId] = { id, leader, members = { userId... }, proposal, run }
	local crewOf = {} -- [userId] = crewId
	local invites = {} -- [toUserId] = { [fromUserId] = os.clock() }
	local nextId = 0

	local function playerOf(userId: number)
		return Players:GetPlayerByUserId(userId)
	end

	local function lifeOf(userId: number)
		local session = S.sessionOf(userId)
		return session and session.profile.Data.life, session
	end

	local function memberLives(crew)
		local lives, ids = {}, {}
		for _, id in crew.members do
			local life = lifeOf(id)
			if life and life.alive then
				table.insert(lives, life)
				table.insert(ids, id)
			end
		end
		return lives, ids
	end

	-- members with a living character, online: who ages up together
	local function ageMembers(crew)
		local out = {}
		for _, id in crew.members do
			local p = playerOf(id)
			local life, session = lifeOf(id)
			if p and session and life and life.alive then
				table.insert(out, { id = id, player = p, session = session, life = life })
			end
		end
		return out
	end

	-- the run's lives, captain first (the run is locked to who set out)
	local function runLives(crew)
		local lives, ids = {}, {}
		for _, id in crew.run.members do
			local life = lifeOf(id)
			if life and life.alive and life.run and life.run.crew then
				table.insert(lives, life)
				table.insert(ids, id)
			end
		end
		return lives, ids
	end

	local function view(crew, forUserId: number)
		if not crew then
			return nil
		end
		local out = { id = crew.id, leader = crew.leader, captain = crew.leader == forUserId, members = {}, max = MAX_CREW }
		for _, id in crew.members do
			local p = playerOf(id)
			local life = lifeOf(id)
			table.insert(out.members, {
				userId = id,
				name = if p then p.DisplayName else "Away",
				leader = id == crew.leader,
				character = if life then { first = life.first, last = life.last, age = life.age, alive = life.alive, appearance = sim:appearance(life) } else nil,
				ready = crew.proposal ~= nil and crew.proposal.ready[id] == true,
				ageReady = crew.ageReady ~= nil and crew.ageReady[id] == true,
			})
		end
		-- aging up together
		out.syncAge = crew.syncAge ~= false
		if crew.ageReady then
			local ready, total = 0, 0
			for _, m in ageMembers(crew) do
				total += 1
				if crew.ageReady[m.id] then
					ready += 1
				end
			end
			local waited = os.clock() - (crew.ageSince or os.clock())
			out.age = {
				ready = ready,
				total = total,
				youReady = crew.ageReady[forUserId] == true,
				canForce = crew.leader == forUserId and crew.ageReady[forUserId] == true and waited >= AGE_WAIT,
				waitLeft = math.max(0, math.ceil(AGE_WAIT - waited)),
			}
		end
		-- (v0.16) the crew's picks on the run's current card
		if crew.run and crew.run.votes then
			local counts, names, total, voted = {}, {}, 0, 0
			for _, id in crew.run.members or {} do
				local life = lifeOf(id)
				if life and life.alive and life.run and life.run.crew then
					total += 1
					local v = crew.run.votes[id]
					if v then
						voted += 1
						-- (string keys: a sparse number-keyed table doesn't survive a remote)
						counts[tostring(v.index)] = (counts[tostring(v.index)] or 0) + 1
					else
						local p = playerOf(id)
						table.insert(names, if p then p.DisplayName else "Someone")
					end
				end
			end
			local waited = os.clock() - (crew.run.voteSince or os.clock())
			local mine = crew.run.votes[forUserId]
			out.votes = {
				counts = counts,
				voted = voted,
				total = total,
				waitingOn = names,
				mine = if mine then mine.index else nil,
				canForce = crew.leader == forUserId and voted > 0 and waited >= VOTE_WAIT,
				waitLeft = math.max(0, math.ceil(VOTE_WAIT - waited)),
			}
		end
		if crew.proposal then
			local def = Expedition.def(sim, crew.proposal.id)
			out.proposal = {
				id = crew.proposal.id,
				name = if def then def.name else crew.proposal.id,
				desc = if def then def.desc else "",
				kind = if def then def.kind else "mission",
				secondsLeft = math.max(0, math.floor(crew.proposal.expires - os.clock())),
				youReady = crew.proposal.ready[forUserId] == true,
			}
		end
		if crew.run then
			local lives = runLives(crew)
			if #lives > 0 then
				out.run = Expedition.view(sim, lives, crew.run)
			end
		end
		-- starting lives together: who has made their character (and what it looks like)
		if crew.together then
			local ready, made, all = {}, {}, true
			for _, id in crew.members do
				ready[tostring(id)] = crew.together.picks[id] ~= nil
				if crew.together.picks[id] == nil then
					all = false
				elseif crew.together.shown and crew.together.shown[id] then
					made[tostring(id)] = crew.together.shown[id]
				end
			end
			out.together = { ready = ready, made = made, everyone = all, youReady = crew.together.picks[forUserId] ~= nil }
		end
		-- the lobby: what the host has decided (a missing key means "the City decides")
		if crew.lobby then
			local l = crew.lobby
			out.lobby = { open = true, era = l.era, district = l.district, side = l.side, difficulty = l.difficulty, mode = l.mode }
		end
		return out
	end

	local function pushCrew(crew, extra)
		for _, id in crew.members do
			local payload = { crew = view(crew, id) }
			for k, v in extra or {} do
				payload[k] = v
			end
			S.pushTo(playerOf(id), payload)
		end
	end

	local function leave(userId: number, why: string?)
		local crewId = crewOf[userId]
		local crew = crewId and crews[crewId]
		crewOf[userId] = nil
		if not crew then
			return
		end
		local idx = table.find(crew.members, userId)
		if idx then
			table.remove(crew.members, idx)
		end
		-- drop out of a run in progress
		local life = lifeOf(userId)
		if life and life.run and life.run.crew then
			life.run = nil
		end
		if crew.run then
			local ri = table.find(crew.run.members, userId)
			if ri then
				table.remove(crew.run.members, ri)
			end
			if #crew.run.members == 0 then
				crew.run = nil
			end
		end
		if crew.proposal then
			crew.proposal = nil
		end
		if crew.together then
			crew.together.picks[userId] = nil
			if crew.together.shown then
				crew.together.shown[userId] = nil
			end
		end
		if crew.ageReady then
			crew.ageReady[userId] = nil
		end
		if #crew.members == 0 then
			crews[crewId] = nil
			return
		end
		if crew.leader == userId then
			crew.leader = crew.members[1]
			-- the run follows the new captain
			if crew.run and table.find(crew.run.members, crew.leader) then
				local ri = table.find(crew.run.members, crew.leader)
				table.remove(crew.run.members, ri)
				table.insert(crew.run.members, 1, crew.leader)
			end
		end
		local p = playerOf(userId)
		pushCrew(crew, { toast = (if p then p.DisplayName else "Someone") .. (why or " left the crew.") })
	end
	Crews.leave = leave

	local function create(userId: number)
		nextId += 1
		local crew = { id = nextId, leader = userId, members = { userId }, proposal = nil, run = nil }
		crews[nextId] = crew
		crewOf[userId] = nextId
		return crew
	end

	function Crews.crewOf(userId: number)
		local id = crewOf[userId]
		return id and crews[id]
	end

	function Crews.viewFor(userId: number)
		local crew = Crews.crewOf(userId)
		return view(crew, userId)
	end

	local function stateResponse(player)
		local others = {}
		local mine = Crews.crewOf(player.UserId)
		for _, p in Players:GetPlayers() do
			if p ~= player and S.sessions[p] and not (mine and table.find(mine.members, p.UserId)) then
				table.insert(others, { userId = p.UserId, name = p.DisplayName, inCrew = crewOf[p.UserId] ~= nil })
			end
		end
		local pending = {}
		for fromId, at in invites[player.UserId] or {} do
			local p = playerOf(fromId)
			if p and os.clock() - at < INVITE_SECONDS then
				table.insert(pending, { userId = fromId, name = p.DisplayName })
			end
		end
		return { ok = true, crew = view(mine, player.UserId), players = others, invites = pending }
	end

	function handlers.crewState(player, _session)
		return stateResponse(player)
	end

	function handlers.crewCreate(player, _session)
		if not Crews.crewOf(player.UserId) then
			create(player.UserId)
		end
		return stateResponse(player)
	end

	function handlers.crewInvite(player, _session, payload)
		if type(payload) ~= "table" or type(payload.userId) ~= "number" then
			return { ok = false, error = "Bad request." }
		end
		local target = playerOf(payload.userId)
		if not target or target == player or not S.sessions[target] then
			return { ok = false, error = "That player isn't here." }
		end
		local crew = Crews.crewOf(player.UserId) or create(player.UserId)
		if #crew.members >= MAX_CREW then
			return { ok = false, error = "Your crew is full." }
		end
		if table.find(crew.members, payload.userId) then
			return { ok = false, error = "They're already in your crew." }
		end
		invites[payload.userId] = invites[payload.userId] or {}
		invites[payload.userId][player.UserId] = os.clock()
		S.pushTo(target, { crewInvite = { userId = player.UserId, name = player.DisplayName } })
		local res = stateResponse(player)
		res.toast = "Crew invite sent to " .. target.DisplayName .. "."
		return res
	end

	function handlers.crewRespond(player, _session, payload)
		if type(payload) ~= "table" or type(payload.userId) ~= "number" then
			return { ok = false, error = "Bad request." }
		end
		local mine = invites[player.UserId]
		local at = mine and mine[payload.userId]
		if mine then
			mine[payload.userId] = nil
		end
		if not at or os.clock() - at > INVITE_SECONDS then
			return { ok = false, error = "That invite expired." }
		end
		local inviter = playerOf(payload.userId)
		if payload.accept ~= true then
			S.pushTo(inviter, { toast = player.DisplayName .. " turned down your crew invite." })
			return stateResponse(player)
		end
		local crew = Crews.crewOf(payload.userId)
		if not crew then
			return { ok = false, error = "That crew broke up." }
		end
		if #crew.members >= MAX_CREW then
			return { ok = false, error = "That crew is full." }
		end
		if crew.run then
			return { ok = false, error = "They're out on an expedition. Try again when they're back." }
		end
		if Crews.crewOf(player.UserId) then
			leave(player.UserId, " left to join another crew.")
		end
		table.insert(crew.members, player.UserId)
		crewOf[player.UserId] = crew.id
		pushCrew(crew, { toast = player.DisplayName .. " joined the crew." })
		return stateResponse(player)
	end

	function handlers.crewLeave(player, _session)
		leave(player.UserId)
		return stateResponse(player)
	end

	function handlers.crewKick(player, _session, payload)
		local crew = Crews.crewOf(player.UserId)
		if not crew or crew.leader ~= player.UserId or type(payload) ~= "table" or type(payload.userId) ~= "number" then
			return { ok = false, error = "Only the captain can do that." }
		end
		if payload.userId == player.UserId or not table.find(crew.members, payload.userId) then
			return { ok = false, error = "They're not in your crew." }
		end
		leave(payload.userId, " was let go from the crew.")
		S.pushTo(playerOf(payload.userId), { toast = "You were let go from the crew.", crew = false })
		return stateResponse(player)
	end

	-- ── ready check ──

	function handlers.crewPropose(player, _session, payload)
		local crew = Crews.crewOf(player.UserId)
		if not crew or crew.leader ~= player.UserId then
			return { ok = false, error = "Only the captain can propose an expedition." }
		end
		if type(payload) ~= "table" or type(payload.id) ~= "string" or not Expedition.def(sim, payload.id) then
			return { ok = false, error = "Pick an expedition." }
		end
		if crew.run then
			return { ok = false, error = "Finish this expedition first." }
		end
		local def = Expedition.def(sim, payload.id)
		local crewMax = (def.crew and def.crew.max) or 1
		if #crew.members > crewMax then
			return { ok = false, error = "That one takes at most " .. crewMax .. "." }
		end
		-- everyone must be able to go
		for _, id in crew.members do
			local life = lifeOf(id)
			local p = playerOf(id)
			if not life or not life.alive then
				return { ok = false, error = (if p then p.DisplayName else "Someone") .. " isn't living a life right now." }
			end
			local _, enabled, why = Expedition.state(sim, life, payload.id)
			if not enabled then
				return { ok = false, error = (if p then p.DisplayName else "Someone") .. ": " .. (why or "can't go") }
			end
		end
		crew.proposal = { id = payload.id, ready = { [player.UserId] = true }, expires = os.clock() + READY_SECONDS }
		pushCrew(crew, { readyCheck = true })
		if #crew.members == 1 then
			return handlers.crewReady(player, _session, { accept = true })
		end
		return stateResponse(player)
	end

	local function startRun(crew)
		local proposal = crew.proposal
		crew.proposal = nil
		local lives, ids = memberLives(crew)
		-- the captain goes first: they make the calls
		local ci = table.find(ids, crew.leader)
		if ci and ci > 1 then
			table.insert(lives, 1, table.remove(lives, ci))
			table.insert(ids, 1, table.remove(ids, ci))
		end
		local run, reports = Expedition.start(sim, lives, proposal.id)
		if not run then
			pushCrew(crew, { toast = "The expedition couldn't start: " .. tostring(reports) })
			return
		end
		run.members = ids
		crew.run = run
		for i, id in ids do
			local life = lives[i]
			S.pushTo(playerOf(id), { crew = view(crew, id), life = sim:view(life), entries = reports[i].entries, toast = "The crew sets out." })
		end
	end

	function handlers.crewReady(player, _session, payload)
		local crew = Crews.crewOf(player.UserId)
		if not crew or not crew.proposal then
			return { ok = false, error = "Nothing to get ready for." }
		end
		if type(payload) ~= "table" or payload.accept ~= true then
			crew.proposal = nil
			pushCrew(crew, { toast = player.DisplayName .. " isn't ready. The expedition is called off." })
			return stateResponse(player)
		end
		crew.proposal.ready[player.UserId] = true
		for _, id in crew.members do
			if not crew.proposal.ready[id] then
				pushCrew(crew)
				return stateResponse(player)
			end
		end
		startRun(crew)
		return stateResponse(player)
	end

	-- ── the run ──

	-- the crew's pick: the most-picked option (a tie goes the captain's way, else the first
	-- picked), fought the way most of the people who picked it chose
	local function tally(crew)
		local counts, order = {}, {}
		for _, id in crew.run.members or {} do
			local v = crew.run.votes and crew.run.votes[id]
			if v then
				if not counts[v.index] then
					table.insert(order, v.index)
				end
				counts[v.index] = (counts[v.index] or 0) + 1
			end
		end
		local best, bestN = nil, -1
		local captainPick = crew.run.votes[crew.leader] and crew.run.votes[crew.leader].index
		for _, index in order do
			local n = counts[index]
			if n > bestN or (n == bestN and index == captainPick) then
				best, bestN = index, n
			end
		end
		local approaches = {}
		for _, v in crew.run.votes do
			if v.index == best and v.approach then
				approaches[v.approach] = (approaches[v.approach] or 0) + 1
			end
		end
		local approach, aN = nil, 0
		for id, n in approaches do
			if n > aN then
				approach, aN = id, n
			end
		end
		return best, approach
	end

	function handlers.crewChoose(player, _session, payload)
		local crew = Crews.crewOf(player.UserId)
		if not crew or not crew.run then
			return { ok = false, error = "Your crew isn't out on an expedition." }
		end
		if type(payload) ~= "table" or (type(payload.index) ~= "number" and payload.force ~= true) then
			return { ok = false, error = "Bad request." }
		end
		local lives, ids = runLives(crew)
		if #lives == 0 then
			crew.run = nil
			return { ok = false, error = "Nobody's left on this expedition." }
		end
		if not table.find(ids, player.UserId) then
			return { ok = false, error = "You're not on this run any more." }
		end
		-- (v0.16) everyone picks: record this pick, and wait for the rest of the crew
		crew.run.votes = crew.run.votes or {}
		crew.run.voteSince = crew.run.voteSince or os.clock()
		if type(payload.index) == "number" then
			local card = Expedition.view(sim, lives, crew.run)
			local choice = card and card.stage and card.stage.choices[math.floor(payload.index)]
			if not choice then
				return { ok = false, error = "That isn't an option." }
			end
			if choice.enabled == false then
				return { ok = false, error = choice.reason or choice.why or "The crew can't do that." }
			end
			crew.run.votes[player.UserId] = { index = math.floor(payload.index), approach = if type(payload.approach) == "string" then payload.approach else nil }
		end
		local everyone = true
		for _, id in ids do
			if not crew.run.votes[id] then
				everyone = false
			end
		end
		local forced = payload.force == true and crew.leader == player.UserId and next(crew.run.votes) ~= nil
			and os.clock() - crew.run.voteSince >= VOTE_WAIT
		if not everyone and not forced then
			pushCrew(crew)
			local res = stateResponse(player)
			res.toast = "Picked. Waiting for the rest of the crew."
			return res
		end
		local pickIndex, approach = tally(crew)
		crew.run.votes = nil
		crew.run.voteSince = nil
		local reports, clash = Expedition.choose(sim, lives, crew.run, pickIndex, approach)
		if not reports then
			return { ok = false, error = clash }
		end
		local finished = crew.run.outcome ~= nil
		local outcome = crew.run.outcome
		local summary = nil
		if finished then
			summary = { outcome = outcome, name = Expedition.def(sim, crew.run.id).name }
		end
		local mine = nil
		for i, id in ids do
			local life = lives[i]
			local session = S.sessionOf(id)
			local res = { life = sim:view(life), entries = reports[i].entries, clash = clash, crewDone = summary }
			if session then
				local news = sim:takeNews(life)
				if not life.alive then
					S.recordDeath(session, life)
					res.lantern = S.lanternFor(session.profile.Data, life.id)
					res.meta = S.metaView(session.profile.Data)
				elseif #news > 0 then
					task.defer(S.shareWithFriends, playerOf(id), session, news)
				end
			end
			if finished then
				crew.run = nil
			end
			res.crew = view(crew, id)
			if id == player.UserId then
				mine = res
			else
				S.pushTo(playerOf(id), res)
			end
		end
		if finished then
			crew.run = nil
		end
		mine = mine or {}
		mine.ok = true
		return mine
	end

	function handlers.crewSuggest(player, _session, payload)
		local crew = Crews.crewOf(player.UserId)
		if not crew or not crew.run or type(payload) ~= "table" or type(payload.index) ~= "number" then
			return { ok = false, error = "Nothing to suggest right now." }
		end
		local lives = runLives(crew)
		local card = #lives > 0 and Expedition.view(sim, lives, crew.run)
		local choice = card and card.stage and card.stage.choices[math.floor(payload.index)]
		if not choice then
			return { ok = false, error = "That isn't an option." }
		end
		S.pushTo(playerOf(crew.leader), { toast = player.DisplayName .. " suggests: " .. choice.label, suggestion = { userId = player.UserId, index = choice.index } })
		return { ok = true, toast = "Suggestion sent to the captain." }
	end

	-- ── starting lives together ──
	-- Each member makes their character and marks ready; then the captain starts every
	-- life at once, in the same district and year, already linked as friends.

	function handlers.crewTogetherReady(player, _session, payload)
		local crew = Crews.crewOf(player.UserId)
		if not crew then
			return { ok = false, error = "Make or join a crew first." }
		end
		if type(payload) ~= "table" then
			return { ok = false, error = "Bad request." }
		end
		crew.together = crew.together or { picks = {}, shown = {} }
		crew.together.shown = crew.together.shown or {}
		crew.together.picks[player.UserId] = payload
		-- what the others see of it: the name through Roblox's text filter, the look checked
		-- against what this player has unlocked (the same checks the life itself gets)
		local data = _session and _session.profile and _session.profile.Data
		local shown = { first = nil, look = nil }
		if S.filterName then
			shown.first = S.filterName(player, payload.first)
		end
		if type(payload.look) == "table" and S.Avatar and S.canUseCosmetic and data then
			shown.look = S.Avatar.sanitize(S.Content, payload.look, S.canUseCosmetic(data))
			if S.Content.schools ~= nil then
				shown.look.weapon = S.Avatar.defaultLook(S.Content).weapon -- (no weapon at the start)
			end
		end
		crew.together.shown[player.UserId] = shown
		pushCrew(crew, { toast = player.DisplayName .. " is ready." })
		return stateResponse(player)
	end

	function handlers.crewTogetherCancel(player)
		local crew = Crews.crewOf(player.UserId)
		if crew and crew.together then
			crew.together.picks[player.UserId] = nil
			if crew.together.shown then
				crew.together.shown[player.UserId] = nil
			end
			pushCrew(crew)
		end
		return stateResponse(player)
	end

	-- ── the lobby: the host's settings ──
	-- crew.lobby = { era, district, side, difficulty, mode }; nil = "the City decides".
	local function firstMode(): string?
		for _, m in S.Content.modes or {} do
			if not S.Progress.modeHidden(m) then
				return m.id
			end
		end
		return nil
	end

	local function newLobby(leaderData)
		local diffs = S.Content.difficulties
		local d = leaderData and leaderData.difficulty
		return {
			era = nil,
			district = nil,
			side = nil,
			difficulty = if diffs and type(d) == "string" and table.find(diffs.order, d) then d else (diffs and diffs.default),
			mode = firstMode(),
		}
	end

	-- Opens the lobby (making a crew of one if need be). Anyone in the crew can look at it;
	-- its settings start from the host's own.
	function handlers.lobbyOpen(player, _session)
		local crew = Crews.crewOf(player.UserId) or create(player.UserId)
		if crew.run then
			return { ok = false, error = "Finish your expedition first." }
		end
		if not crew.lobby then
			local leaderSession = S.sessionOf(crew.leader)
			crew.lobby = newLobby(leaderSession and leaderSession.profile.Data)
			crew.together = crew.together or { picks = {}, shown = {} }
			-- the rest of the crew hears about it (their own screens are theirs to open)
			for _, id in crew.members do
				if id ~= player.UserId then
					S.pushTo(playerOf(id), { crew = view(crew, id), lobbyOpened = { name = player.DisplayName } })
				end
			end
		end
		local res = stateResponse(player)
		res.lobbyOpen = true
		return res
	end

	local LOBBY_ANY = { any = true, [""] = true }
	function handlers.lobbySet(player, session, payload)
		local crew = Crews.crewOf(player.UserId)
		if not crew or not crew.lobby then
			return { ok = false, error = "Open a lobby first." }
		end
		if crew.leader ~= player.UserId then
			return { ok = false, error = "Only the host can change that." }
		end
		if type(payload) ~= "table" or type(payload.key) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local Content = S.Content
		local lobby = crew.lobby
		local key, value = payload.key, payload.value
		local any = value == nil or value == false or (type(value) == "string" and LOBBY_ANY[value] == true)
		if key == "era" then
			local mode = lobby.mode and S.Progress and S.Progress.modeDef(lobby.mode)
			if mode and mode.era then
				return { ok = false, error = mode.name .. " has its own age." }
			end
			if any then
				lobby.era = nil
			elseif type(value) == "string" and sim:birthEraDef(value) then
				lobby.era = value
			else
				return { ok = false, error = "No such age." }
			end
		elseif key == "district" then
			if any then
				lobby.district = nil
			elseif type(value) == "string" and table.find(Content.districts.order, value) then
				lobby.district = value
			else
				return { ok = false, error = "No such " .. (Content.meta.districtWord or "District") .. "." }
			end
		elseif key == "side" then
			if any then
				lobby.side = nil
			elseif type(value) == "string" and table.find(Content.sides.order, value) then
				lobby.side = value
			else
				return { ok = false, error = "No such side." }
			end
		elseif key == "difficulty" then
			if type(value) == "string" and Content.difficulties and table.find(Content.difficulties.order, value) then
				lobby.difficulty = value
			else
				return { ok = false, error = "No such difficulty." }
			end
		elseif key == "mode" then
			local mode = type(value) == "string" and S.Progress and S.Progress.modeDef(value)
			if not mode then
				return { ok = false, error = "No such way to begin." }
			end
			if not S.Progress.modeUnlocked(session.profile.Data, mode) then
				return { ok = false, error = mode.name .. " is still locked for you." }
			end
			lobby.mode = mode.id
			if mode.era then
				lobby.era = mode.era -- (a mode with its own age brings it along)
			end
		elseif key == "syncAge" then
			crew.syncAge = value == true
			crew.ageReady = nil
			crew.ageSince = nil
		else
			return { ok = false, error = "Bad request." }
		end
		pushCrew(crew)
		return stateResponse(player)
	end

	-- one age for everyone: the host's, or one the City picks (by the same weights as a birth)
	local function lobbyEra(eraId: string?): string?
		if eraId and sim:birthEraDef(eraId) then
			return eraId
		end
		local cal = S.Content.calendar
		if not (cal and cal.rollEra and cal.eras and #cal.eras > 0) then
			return nil
		end
		local total = 0
		for _, e in cal.eras do
			total += e.weight or 1
		end
		local at = math.random() * total
		for _, e in cal.eras do
			at -= e.weight or 1
			if at <= 0 then
				return e.id
			end
		end
		return cal.eras[#cal.eras].id
	end

	function handlers.crewTogetherStart(player, _session)
		local crew = Crews.crewOf(player.UserId)
		if not crew or crew.leader ~= player.UserId then
			return { ok = false, error = "Only the captain can start everyone's lives." }
		end
		if crew.run then
			return { ok = false, error = "Finish your expedition first." }
		end
		local picks = crew.together and crew.together.picks
		if not picks then
			return { ok = false, error = "Nobody's ready yet." }
		end
		local members = {}
		for _, id in crew.members do
			local p = playerOf(id)
			local session = S.sessionOf(id)
			local pick = picks[id]
			if not (p and session) then
				return { ok = false, error = "Someone left the server." }
			end
			if not pick then
				return { ok = false, error = p.DisplayName .. " hasn't made their character yet." }
			end
			local life = session.profile.Data.life
			if life and life.alive and pick.confirm ~= true then
				return { ok = false, error = p.DisplayName .. " still has a life going." }
			end
			table.insert(members, { player = p, session = session, pick = pick })
		end
		-- one place and one year for everybody. With a lobby the host's settings decide; without
		-- one (an older client) the captain's own character does.
		local Content = S.Content
		local lobby = crew.lobby
		local captainPick = picks[crew.leader]
		local wantDistrict = if lobby then lobby.district else captainPick.district
		local district = if type(wantDistrict) == "string" and table.find(Content.districts.order, wantDistrict) then wantDistrict else Content.districts.order[math.random(1, #Content.districts.order)]
		-- the way everyone begins (each of them must have it unlocked)
		local mode = nil
		local wantMode = if lobby then lobby.mode else captainPick.mode
		if type(wantMode) == "string" and S.Progress then
			mode = S.Progress.modeDef(wantMode)
			if mode then
				for _, m in members do
					if not S.Progress.modeUnlocked(m.session.profile.Data, mode) then
						return { ok = false, error = m.player.DisplayName .. " hasn't unlocked " .. mode.name .. " yet." }
					end
				end
			end
		end
		local era = (mode and mode.era) or (if lobby then lobby.era elseif type(captainPick.era) == "string" then captainPick.era else nil)
		if lobby then
			era = lobbyEra(era)
		end
		local year = sim:rollBirthYear(era)
		local shared = {
			district = district,
			year = year,
			era = if lobby then era else nil,
			side = if lobby then lobby.side else nil,
			difficulty = if lobby then lobby.difficulty else nil,
			flags = { "started_together" },
			mode = if mode then mode.id else nil,
		}
		crew.together = nil
		crew.lobby = nil -- the lobby's work is done
		local results = {}
		for _, m in members do
			local res = S.startLife(m.player, m.session, m.pick, shared)
			results[m.player] = res
		end
		-- everyone is linked with everyone: their lives cross from day one
		for i = 1, #members do
			for j = i + 1, #members do
				local a, b = members[i], members[j]
				if results[a.player].ok and results[b.player].ok then
					S.linkPlayers(a.player, a.session, b.player, b.session)
				end
			end
		end
		local dname = Content.districts[district].name or district
		for _, m in members do
			local res = results[m.player]
			if res.ok then
				local life = m.session.profile.Data.life
				res.life = if life then sim:view(life) else res.life
				res.crew = view(crew, m.player.UserId)
				res.together = true
				res.toast = "You start out together in " .. dname .. "."
			end
			if m.player ~= player then
				S.pushTo(m.player, res)
			end
		end
		return results[player]
	end

	-- ── aging up together ──
	local function syncOn(crew): boolean
		return crew.syncAge ~= false and crew.run == nil and #ageMembers(crew) >= 2
	end

	-- who of these can't turn the year yet, and why (a card to answer, an expedition under way)
	local function heldUp(who)
		for _, m in who do
			sim:settlePending(m.life)
			if m.life.pending then
				return m, "has a card to answer"
			elseif m.life.run then
				return m, "is on an expedition"
			end
		end
		return nil, nil
	end

	-- turns the year for these members; the requester's own response is returned.
	-- Nobody's year turns unless everybody's can: lives that age together stay together.
	local function ageAll(crew, who, requester: Player)
		local stuck, why = heldUp(who)
		if stuck then
			if crew.ageReady then
				crew.ageReady[stuck.id] = nil
			end
			local name = stuck.player.DisplayName
			for _, m in who do
				local payload: any = { crew = view(crew, m.id), ageHeld = true }
				if m.id == stuck.id then
					payload.toast = "Your crew is ready for the next year. " .. (if stuck.life.pending then "Answer your card first." else "Finish your expedition first.")
					payload.life = sim:view(stuck.life)
				else
					payload.toast = string.format("%s %s. The year waits for them.", name, why)
				end
				if m.player ~= requester then
					S.pushTo(m.player, payload)
				end
			end
			local mineToast = if stuck.player == requester
				then "Your crew is ready. " .. (if stuck.life.pending then "Answer your card first." else "Finish your expedition first.")
				else string.format("%s %s. The year waits for them.", name, why)
			return { ok = true, waiting = true, crew = view(crew, requester.UserId), toast = mineToast }
		end
		local wasReady = crew.ageReady or {}
		crew.ageReady = nil
		crew.ageSince = nil
		local mine = nil
		for _, m in who do
			local res = S.ageUpNow(m.player, m.session)
			if m.player == requester then
				mine = res
			elseif res and res.ok then
				res.applyAll = true
				if not wasReady[m.id] then
					res.toast = requester.DisplayName .. " turned the year for the crew."
				end
				S.pushTo(m.player, res)
			elseif res then
				S.pushTo(m.player, { toast = res.error })
			end
		end
		pushCrew(crew)
		return mine
	end

	-- Age Up in a synced crew: a ready check (nil = not synced, age up as normal)
	function Crews.ageUp(player: Player, _session)
		local crew = Crews.crewOf(player.UserId)
		if not crew then
			return nil
		end
		-- out on an expedition together, nobody slips a year ahead of the others
		if crew.syncAge ~= false and crew.run ~= nil and #ageMembers(crew) >= 2 then
			return { ok = false, error = "Finish the expedition first: your crew ages together." }
		end
		if not syncOn(crew) then
			return nil
		end
		-- an open decision comes first (the normal path says so)
		local mine = lifeOf(player.UserId)
		if not mine or mine.pending then
			return nil
		end
		-- (v0.16) nobody's year turns mid-fight: yours, or a crewmate's
		for _, m in ageMembers(crew) do
			if m.life.battle or m.life.battleWith or m.life.duel then
				return { ok = false, error = if m.id == player.UserId then "Finish the fight first." else "Your crew is in a fight. The year waits for it." }
			end
		end
		local members = ageMembers(crew)
		crew.ageReady = crew.ageReady or {}
		crew.ageReady[player.UserId] = true
		crew.ageSince = crew.ageSince or os.clock()
		local ready, all = 0, true
		for _, m in members do
			if crew.ageReady[m.id] then
				ready += 1
			else
				all = false
			end
		end
		if all then
			return ageAll(crew, members, player) or { ok = true }
		end
		pushCrew(crew, { toast = string.format("%s is ready for the next year (%d of %d).", player.DisplayName, ready, #members), ageCheck = true })
		return { ok = true, waiting = true, crew = view(crew, player.UserId), toast = string.format("Waiting for your crew: %d of %d ready.", ready, #members) }
	end

	function handlers.crewAgeCancel(player)
		local crew = Crews.crewOf(player.UserId)
		if crew and crew.ageReady then
			crew.ageReady[player.UserId] = nil
			if next(crew.ageReady) == nil then
				crew.ageReady = nil
				crew.ageSince = nil
			end
			pushCrew(crew)
		end
		return stateResponse(player)
	end

	-- the captain goes ahead with whoever is ready (after AGE_WAIT seconds)
	function handlers.crewAgeNow(player, _session)
		local crew = Crews.crewOf(player.UserId)
		if not crew or crew.leader ~= player.UserId then
			return { ok = false, error = "Only the captain can do that." }
		end
		if not (crew.ageReady and crew.ageReady[player.UserId]) then
			return { ok = false, error = "Ready up yourself first." }
		end
		if os.clock() - (crew.ageSince or os.clock()) < AGE_WAIT then
			return { ok = false, error = "Give them a few more seconds." }
		end
		-- the year turns for everyone, ready or not: nobody is left a year behind. Someone in
		-- the middle of a card holds it (ageAll says who).
		return ageAll(crew, ageMembers(crew), player) or stateResponse(player)
	end

	function handlers.crewSyncAge(player, _session, payload)
		local crew = Crews.crewOf(player.UserId)
		if not crew or crew.leader ~= player.UserId then
			return { ok = false, error = "Only the captain can change that." }
		end
		crew.syncAge = type(payload) == "table" and payload.on == true
		crew.ageReady = nil
		crew.ageSince = nil
		pushCrew(crew, { toast = if crew.syncAge then "Your crew ages up together now." else "Everyone ages up on their own now." })
		return stateResponse(player)
	end

	-- ready checks run out
	task.spawn(function()
		while true do
			task.wait(2)
			for _, crew in crews do
				if crew.proposal and os.clock() > crew.proposal.expires then
					crew.proposal = nil
					pushCrew(crew, { toast = "Not everyone was ready in time. The expedition is called off." })
				end
			end
		end
	end)

	-- a player leaving the server leaves their crew
	Players.PlayerRemoving:Connect(function(player)
		invites[player.UserId] = nil
		leave(player.UserId, " left the server.")
	end)
end

return Crews
