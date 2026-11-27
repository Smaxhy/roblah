--[[
	BATTLES WITH FRIENDS (v0.16): the server side of turn-based boss fights (Engine/Battle.luau).

	* A fight starts when a player picks a choice with `battle` (handlers.choose). The fight
	  lives on that player's life (the host). Their crewmates on this server get an invitation:
	  "{name} is fighting {boss}. Join?" (only if they're free: alive, nothing open).
	* handlers.battleJoin { host }    a crewmate steps in. The boss gets more Health.
	* handlers.battleAct { action, approach }   your move this turn. Every fighter chooses their
	  own; the turn resolves when everyone still standing has chosen.
	* handlers.battleGo {}            after BATTLE_WAIT seconds, anyone who has chosen can go
	  ahead without whoever hasn't (they guard).
	Every fighter gets the new state pushed after every move; the one who acted gets it as the
	reply. A fighter who leaves the server is out of the fight; a host who leaves keeps the
	fight on their life and can finish it alone.
]]

local Players = game:GetService("Players")

local Battles = {}

local BATTLE_WAIT = 25

function Battles.install(S)
	local sim = S.sim
	local handlers = S.handlers
	local Battle = S.Engine.Battle

	local fightersOf = {} -- [hostUserId] = { userIds }, the host first
	local hostOf = {} -- [userId] = hostUserId, for anyone in someone's fight (the host too)
	local turnSince = {} -- [hostUserId] = os.clock() when the current turn opened

	local function lifeOfUser(userId: number)
		local session = S.sessionOf(userId)
		return session and session.profile.Data.life, session
	end

	-- the host's life, and every fighter's life by key
	local function gather(hostId: number)
		local hostLife = lifeOfUser(hostId)
		local lives, users = {}, {}
		for _, uid in fightersOf[hostId] or { hostId } do
			local life = lifeOfUser(uid)
			if life then
				lives[tostring(life.id)] = life
				users[tostring(life.id)] = uid
			end
		end
		return hostLife, lives, users
	end

	local function forget(hostId: number)
		for _, uid in fightersOf[hostId] or {} do
			if hostOf[uid] == hostId then
				hostOf[uid] = nil
			end
		end
		fightersOf[hostId] = nil
		turnSince[hostId] = nil
	end

	-- who a player is fighting alongside: their own fight, or the one they joined
	local function hostFor(player: Player, life): number?
		if life and life.battle then
			if not fightersOf[player.UserId] then
				fightersOf[player.UserId] = { player.UserId }
				hostOf[player.UserId] = player.UserId
				turnSince[player.UserId] = os.clock()
			end
			return player.UserId
		end
		if life and life.battleWith then
			local host = hostOf[player.UserId]
			local hostLife = host and lifeOfUser(host)
			if hostLife and hostLife.battle and tostring(hostLife.id) == life.battleWith then
				return host
			end
			-- the fight they were in is gone (the host left, or the server restarted)
			life.battleWith = nil
		end
		return nil
	end

	local function viewFor(hostId: number, forUserId: number)
		local hostLife, lives = gather(hostId)
		local mine = lifeOfUser(forUserId)
		if not hostLife or not hostLife.battle or not mine then
			return nil
		end
		local v = Battle.view(sim, hostLife, lives, tostring(mine.id))
		if v then
			local waited = os.clock() - (turnSince[hostId] or os.clock())
			local me = nil
			for _, f in v.fighters do
				if f.me then
					me = f
				end
			end
			v.canGo = me ~= nil and me.acted and #v.waitingOn > 0 and waited >= BATTLE_WAIT
			v.goIn = math.max(0, math.ceil(BATTLE_WAIT - waited))
			v.withFriends = #(fightersOf[hostId] or {}) > 1
		end
		return v
	end

	-- every fighter's response: their life, their own entries, and the fight as they see it
	local function responseFor(hostId: number, uid: number, report, done)
		local session = S.sessionOf(uid)
		if not session then
			return nil
		end
		local res = S.lifeResponse(session, report)
		res.battle = if done then nil else viewFor(hostId, uid)
		res.battleDone = done
		return res
	end

	local function broadcast(hostId: number, reportsByKey, actingUserId: number?, done)
		local _hostLife, _lives, users = gather(hostId)
		local mine = nil
		for key, uid in users do
			local report = reportsByKey and reportsByKey[key]
			local res = responseFor(hostId, uid, report, done)
			if res then
				if uid == actingUserId then
					mine = res
				else
					local p = Players:GetPlayerByUserId(uid)
					if p then
						S.pushTo(p, res)
					end
				end
			end
		end
		return mine
	end

	-- after a turn: is it over?
	local function afterTurn(hostId: number, reports, actingUserId: number)
		local hostLife = lifeOfUser(hostId)
		local done = nil
		if hostLife and not hostLife.battle then
			done = hostLife.battleDone
		end
		turnSince[hostId] = os.clock()
		local mine = broadcast(hostId, reports, actingUserId, done)
		if done then
			forget(hostId)
		end
		return mine
	end

	-- crewmates who could step in: on this server, alive, nothing open
	local function invite(player: Player, life)
		local crew = S.Crews and S.Crews.crewOf and S.Crews.crewOf(player.UserId)
		if not crew then
			return
		end
		local def = Battle.def(sim, life.battle.boss)
		for _, uid in crew.members do
			if uid ~= player.UserId and not hostOf[uid] then
				local other = lifeOfUser(uid)
				local p = Players:GetPlayerByUserId(uid)
				if p and other and other.alive and not other.pending and not other.run and not other.battle and not other.battleWith and not other.duel then
					S.pushTo(p, { battleInvite = { host = player.UserId, hostName = player.DisplayName, boss = def and def.name or "a boss", title = life.battle.title } })
				end
			end
		end
	end

	-- a fight starts from a choice: register it, and tell the crew
	local baseChoose = handlers.choose
	function handlers.choose(player, session, payload)
		local res = baseChoose(player, session, payload)
		local life = session.profile.Data.life
		if type(res) == "table" and res.ok and life and life.battle then
			fightersOf[player.UserId] = { player.UserId }
			hostOf[player.UserId] = player.UserId
			turnSince[player.UserId] = os.clock()
			res.battle = viewFor(player.UserId, player.UserId)
			task.defer(invite, player, life)
		end
		return res
	end

	function handlers.battleJoin(player, session, payload)
		if type(payload) ~= "table" or type(payload.host) ~= "number" then
			return { ok = false, error = "Bad request." }
		end
		local hostId = math.floor(payload.host)
		local life = session.profile.Data.life
		if not life or not life.alive then
			return { ok = false, error = "Start a life first." }
		end
		if life.pending or life.run or life.battle or life.battleWith or life.duel then
			return { ok = false, error = "Finish what you're doing first." }
		end
		local crew = S.Crews and S.Crews.crewOf and S.Crews.crewOf(player.UserId)
		if not crew or not table.find(crew.members, hostId) then
			return { ok = false, error = "You can only join your crew's fights." }
		end
		local hostLife = lifeOfUser(hostId)
		if not hostLife or not hostLife.battle or not fightersOf[hostId] then
			return { ok = false, error = "That fight is over." }
		end
		local ok, why = Battle.join(sim, hostLife, life)
		if not ok then
			return { ok = false, error = why }
		end
		table.insert(fightersOf[hostId], player.UserId)
		hostOf[player.UserId] = hostId
		local mine = broadcast(hostId, nil, player.UserId, nil)
		mine = mine or { ok = true }
		mine.toast = "You step into the fight."
		return mine
	end

	function handlers.battleAct(player, session, payload)
		if type(payload) ~= "table" or type(payload.action) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local life = session.profile.Data.life
		local hostId = hostFor(player, life)
		if not hostId then
			return { ok = false, error = "There's no fight going on." }
		end
		local hostLife, lives = gather(hostId)
		local approach = if type(payload.approach) == "string" then payload.approach else nil
		local reports, why = Battle.act(sim, hostLife, lives, tostring(life.id), payload.action, approach)
		if not reports and why then
			return { ok = false, error = why }
		end
		if not reports then
			-- chosen; waiting for the others
			local mine = broadcast(hostId, nil, player.UserId, nil)
			mine = mine or { ok = true }
			return mine
		end
		local mine = afterTurn(hostId, reports, player.UserId)
		return mine or { ok = true }
	end

	function handlers.battleGo(player, session, _payload)
		local life = session.profile.Data.life
		local hostId = hostFor(player, life)
		if not hostId then
			return { ok = false, error = "There's no fight going on." }
		end
		local v = viewFor(hostId, player.UserId)
		if not v or not v.canGo then
			return { ok = false, error = "Give them a moment." }
		end
		local hostLife, lives = gather(hostId)
		local reports, why = Battle.resolve(sim, hostLife, lives)
		if not reports then
			return { ok = false, error = why }
		end
		return afterTurn(hostId, reports, player.UserId) or { ok = true }
	end

	-- someone leaves: out of any fight they joined (the host keeps theirs on their life)
	Players.PlayerRemoving:Connect(function(p)
		local hostId = hostOf[p.UserId]
		if hostId and hostId ~= p.UserId and fightersOf[hostId] then
			local list = fightersOf[hostId]
			local i = table.find(list, p.UserId)
			if i then
				table.remove(list, i)
			end
			hostOf[p.UserId] = nil
		elseif hostId == p.UserId then
			-- the host left: the friends' side of the fight ends
			for _, uid in fightersOf[p.UserId] or {} do
				if uid ~= p.UserId then
					local other = lifeOfUser(uid)
					if other then
						other.battleWith = nil
					end
					local op = Players:GetPlayerByUserId(uid)
					if op then
						S.pushTo(op, { toast = p.DisplayName .. " left. The fight is over for you.", battle = false })
					end
				end
			end
			forget(p.UserId)
		end
	end)

	S.battleViewFor = function(player: Player, life)
		local hostId = hostFor(player, life)
		return hostId and viewFor(hostId, player.UserId) or nil
	end
end

return Battles
