--[[
	Duels: fight a friend. (v0.17) A duel is fought in turns (Engine/Pvp.luau): every turn both
	players choose (a way of fighting, Guard, Feint, Patch up, Yield), the choices stay hidden
	until both are in, and the turn plays out on both screens. After DUEL_WAIT seconds, a
	player who has chosen can go ahead (the other guards). Leaving the server mid-duel yields.
		handlers.duelAct { action, approach }    your move this turn
		handlers.duelGo {}                        go ahead without the other's move

	* You can challenge a linked friend or a crewmate who is online, alive and free (no open
	  decision, not on an expedition), both 14 or older. One duel per pair per year of life.
	* A friendly duel ends at first blood: the loser is hurt (never below 1 Fortitude), the
	  winner's nerve grows.
	* If both players turned on rough play, it's a blood duel: the loser can die.
	* Challenges expire after INVITE_SECONDS.
]]

local Players = game:GetService("Players")

local Duels = {}

local INVITE_SECONDS = 60
local COOLDOWN = 12 -- seconds between challenges from one player
local MIN_AGE = 14
local DUEL_WAIT = 25 -- (v0.17) seconds before someone who has chosen can go ahead

function Duels.install(S)
	local sim = S.sim
	local Engine = S.Engine
	local handlers = S.handlers
	local invites = {} -- [toUserId] = { [fromUserId] = { at, rough } }
	local lastSent = {} -- [userId] = os.clock()
	local fought = {} -- ["a:b"] = "ageA:ageB" of the last duel
	local Pvp = Engine.Pvp
	local active = {} -- (v0.17) ["a:b"] = { d = Pvp duel, a = userId, b = userId, since = os.clock() }
	local duelOf = {} -- [userId] = "a:b"

	local function pairKey(a: number, b: number): string
		if a < b then
			return a .. ":" .. b
		end
		return b .. ":" .. a
	end

	local function sameCrew(a: number, b: number): boolean
		local Crews = S.Crews
		local crew = Crews and Crews.crewOf(a)
		return crew ~= nil and table.find(crew.members, b) ~= nil
	end

	local function rough(data): boolean
		return data.settings ~= nil and data.settings.rough == true
	end

	-- why these two can't duel right now (nil = they can)
	local function blocked(aId: number, aSession, bId: number, bSession): string?
		if aId == bId then
			return "You can't duel yourself."
		end
		if not bSession then
			return "They're not here right now."
		end
		local aData, bData = aSession.profile.Data, bSession.profile.Data
		local linked = aData.links[tostring(bId)] ~= nil and bData.links[tostring(aId)] ~= nil
		if not linked and not sameCrew(aId, bId) then
			return "You can only duel linked friends and crewmates."
		end
		local a, b = aData.life, bData.life
		if not (a and a.alive) then
			return "Start a life first."
		end
		if not (b and b.alive) then
			return "They're between lives."
		end
		if a.age < MIN_AGE or b.age < MIN_AGE then
			return "Duels are for ages " .. MIN_AGE .. " and up."
		end
		if a.pending or b.pending then
			return "Finish the decision on screen first."
		end
		if a.run or b.run then
			return "Not in the middle of an expedition."
		end
		if a.battle or a.battleWith or b.battle or b.battleWith then
			return "Not in the middle of a fight."
		end
		if a.duel or b.duel or duelOf[aId] or duelOf[bId] then
			return "One of you is already in a duel."
		end
		local key = pairKey(aId, bId)
		local ages = if aId < bId then a.age .. ":" .. b.age else b.age .. ":" .. a.age
		if fought[key] == ages then
			return "You two already fought this year. Age up first."
		end
		return nil
	end

	function handlers.duelChallenge(player, session, payload)
		local targetId = type(payload) == "table" and tonumber(payload.userId)
		if not targetId then
			return { ok = false, error = "Who do you want to duel?" }
		end
		if os.clock() - (lastSent[player.UserId] or -100) < COOLDOWN then
			return { ok = false, error = "Catch your breath first." }
		end
		local target, targetPlayer = S.sessionOf(targetId)
		local why = blocked(player.UserId, session, targetId, target)
		if why then
			return { ok = false, error = why }
		end
		lastSent[player.UserId] = os.clock()
		local blood = rough(session.profile.Data) and rough(target.profile.Data)
		invites[targetId] = invites[targetId] or {}
		invites[targetId][player.UserId] = { at = os.clock(), rough = blood }
		local life = session.profile.Data.life
		S.pushTo(targetPlayer, {
			duelInvite = {
				userId = player.UserId,
				name = player.DisplayName,
				character = string.format("%s %s, %d", life.first, life.last, life.age),
				style = life.style and sim.pack.styles and sim.pack.styles[life.style] and sim.pack.styles[life.style].name or nil,
				rough = blood,
			},
		})
		return { ok = true, toast = "Challenge sent to " .. targetPlayer.DisplayName .. "." }
	end

	-- (v0.17) A DUEL IN TURNS: who's in it, what each sees, and how it ends
	local function livesOf(entry)
		local sa, sb = S.sessionOf(entry.a), S.sessionOf(entry.b)
		local la = sa and sa.profile.Data.life
		local lb = sb and sb.profile.Data.life
		local lives = {}
		if la then
			lives[tostring(la.id)] = la
		end
		if lb then
			lives[tostring(lb.id)] = lb
		end
		return lives, la, lb
	end

	local function viewFor(entry, uid: number)
		local lives, la, lb = livesOf(entry)
		local life = if uid == entry.a then la else lb
		if not life then
			return nil
		end
		local v = Pvp.view(sim, entry.d, lives, tostring(life.id))
		if v then
			local waited = os.clock() - entry.since
			v.canGo = v.me.chosen and not v.them.chosen and waited >= DUEL_WAIT and not v.done
			v.goIn = math.max(0, math.ceil(DUEL_WAIT - waited))
		end
		return v
	end

	local function forget(entry)
		local key = pairKey(entry.a, entry.b)
		active[key] = nil
		if duelOf[entry.a] == key then
			duelOf[entry.a] = nil
		end
		if duelOf[entry.b] == key then
			duelOf[entry.b] = nil
		end
	end

	-- the end: what it did to both lives, the news, and the year's duel used up
	local function finish(entry)
		local lives, la, lb = livesOf(entry)
		local reports = Pvp.finish(sim, entry.d, lives)
		for _, life in lives do
			life.duel = nil
		end
		if la and lb then
			fought[pairKey(entry.a, entry.b)] = if entry.a < entry.b then la.age .. ":" .. lb.age else lb.age .. ":" .. la.age
			local winner = if entry.d.winner == tostring(la.id) then la else lb
			local loser = if winner == la then lb else la
			if S.City and S.City.news then
				pcall(S.City.news, string.format("%s %s %s %s in a %sduel, in %d turns.", winner.first, winner.last, if entry.d.blood and not loser.alive then "killed" else "beat", loser.first .. " " .. loser.last, if entry.d.blood then "blood " else "", entry.d.turn - 1), if entry.d.blood then "danger" else "good")
			end
		end
		forget(entry)
		return reports
	end

	-- every side gets its view; after the end, its life too
	local function broadcast(entry, actingUid: number?, reports)
		local mine = nil
		for _, uid in { entry.a, entry.b } do
			local session = S.sessionOf(uid)
			if session then
				local life = session.profile.Data.life
				local res
				if entry.d.done then
					res = S.lifeResponse(session, reports and life and reports[tostring(life.id)])
					res.duelDone = viewFor(entry, uid) or { done = true }
				else
					res = S.lifeResponse(session, nil)
					res.duel = viewFor(entry, uid)
				end
				if uid == actingUid then
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

	local function startDuel(aPlayer: Player, aSession, bPlayer: Player, bSession, blood: boolean)
		local a, b = aSession.profile.Data.life, bSession.profile.Data.life
		local entry = { d = Pvp.start(sim, a, b, blood), a = aPlayer.UserId, b = bPlayer.UserId, since = os.clock() }
		local key = pairKey(entry.a, entry.b)
		active[key] = entry
		duelOf[entry.a] = key
		duelOf[entry.b] = key
		a.duel = { with = entry.b }
		b.duel = { with = entry.a }
		-- each side sees the other's real figure across the duel screen
		local resA = S.lifeResponse(aSession, nil)
		resA.duel = viewFor(entry, entry.a)
		resA.toast = bPlayer.DisplayName .. " accepted. Choose your move."
		local resB = S.lifeResponse(bSession, nil)
		resB.duel = viewFor(entry, entry.b)
		return resA, resB
	end

	local function entryFor(player: Player, session)
		local key = duelOf[player.UserId]
		local entry = key and active[key]
		local life = session.profile.Data.life
		if not entry and life and life.duel then
			-- a duel that ended without us (the server restarted, or the other side left)
			life.duel = nil
		end
		return entry, life
	end

	function handlers.duelAct(player, session, payload)
		if type(payload) ~= "table" or type(payload.action) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local entry, life = entryFor(player, session)
		if not entry or not life then
			return { ok = false, error = "There's no duel going on." }
		end
		local lives = livesOf(entry)
		local approach = if type(payload.approach) == "string" then payload.approach else nil
		local both, why = Pvp.choose(sim, entry.d, lives, tostring(life.id), payload.action, approach)
		if why then
			return { ok = false, error = why }
		end
		if both then
			Pvp.resolve(sim, entry.d, lives)
			entry.since = os.clock()
			local reports = if entry.d.done then finish(entry) else nil
			return broadcast(entry, player.UserId, reports) or { ok = true }
		end
		return broadcast(entry, player.UserId, nil) or { ok = true }
	end

	function handlers.duelGo(player, session, _payload)
		local entry = entryFor(player, session)
		if not entry then
			return { ok = false, error = "There's no duel going on." }
		end
		local v = viewFor(entry, player.UserId)
		if not v or not v.canGo then
			return { ok = false, error = "Give them a moment." }
		end
		Pvp.resolve(sim, entry.d, livesOf(entry))
		entry.since = os.clock()
		local reports = if entry.d.done then finish(entry) else nil
		return broadcast(entry, player.UserId, reports) or { ok = true }
	end

	-- a duel that outlived its server (or its other player) doesn't hold a life hostage
	local baseHello = handlers.hello
	if baseHello then
		function handlers.hello(player, session, payload)
			local life = session.profile.Data.life
			if life and life.duel and not duelOf[player.UserId] then
				life.duel = nil
			end
			local res = baseHello(player, session, payload)
			local entry = duelOf[player.UserId] and active[duelOf[player.UserId]]
			if type(res) == "table" and entry then
				res.duel = viewFor(entry, player.UserId)
			end
			return res
		end
	end

	function handlers.duelRespond(player, session, payload)
		local fromId = type(payload) == "table" and tonumber(payload.userId)
		local inv = fromId and invites[player.UserId] and invites[player.UserId][fromId]
		if not inv or os.clock() - inv.at > INVITE_SECONDS then
			if fromId and invites[player.UserId] then
				invites[player.UserId][fromId] = nil
			end
			return { ok = false, error = "That challenge has run out." }
		end
		invites[player.UserId][fromId] = nil
		local challenger, challengerPlayer = S.sessionOf(fromId)
		if payload.accept ~= true then
			if challengerPlayer then
				S.pushTo(challengerPlayer, { toast = player.DisplayName .. " turned down your duel." })
			end
			return { ok = true }
		end
		local why = blocked(fromId, challenger, player.UserId, session)
		if why or not challengerPlayer then
			return { ok = false, error = why or "They left." }
		end
		local resA, resB = startDuel(challengerPlayer, challenger, player, session, inv.rough)
		S.pushTo(challengerPlayer, resA)
		return resB
	end

	-- who you could duel right now (linked friends and crewmates who are online)
	function handlers.duelTargets(player, session)
		local out = {}
		local seen = {}
		local function consider(userId: number)
			if seen[userId] or userId == player.UserId then
				return
			end
			seen[userId] = true
			local other, otherPlayer = S.sessionOf(userId)
			if not otherPlayer then
				return
			end
			local life = other.profile.Data.life
			local why = blocked(player.UserId, session, userId, other)
			table.insert(out, {
				userId = userId,
				name = otherPlayer.DisplayName,
				character = if life and life.alive then string.format("%s %s, %d", life.first, life.last, life.age) else nil,
				appearance = if life and life.alive then sim:appearance(life) else nil,
				blocked = why,
				rough = rough(session.profile.Data) and rough(other.profile.Data),
			})
		end
		for key in session.profile.Data.links do
			local id = tonumber(key)
			if id then
				consider(id)
			end
		end
		local Crews = S.Crews
		local crew = Crews and Crews.crewOf(player.UserId)
		for _, id in (crew and crew.members) or {} do
			consider(id)
		end
		return { ok = true, targets = out }
	end

	Players.PlayerRemoving:Connect(function(p)
		invites[p.UserId] = nil
		lastSent[p.UserId] = nil
		-- (v0.17) leaving mid-duel is a yield
		local key = duelOf[p.UserId]
		local entry = key and active[key]
		if entry and not entry.d.done then
			local session = S.sessionOf(p.UserId)
			local life = session and session.profile.Data.life
			if life then
				pcall(function()
					local lives = livesOf(entry)
					Pvp.choose(sim, entry.d, lives, tostring(life.id), "yield", nil)
					Pvp.resolve(sim, entry.d, lives)
					local reports = finish(entry)
					broadcast(entry, p.UserId, reports)
				end)
			else
				-- their life is already gone from the server: the other side's duel just ends
				local otherId = if entry.a == p.UserId then entry.b else entry.a
				local otherSession = S.sessionOf(otherId)
				local otherLife = otherSession and otherSession.profile.Data.life
				if otherLife then
					otherLife.duel = nil
				end
				local op = Players:GetPlayerByUserId(otherId)
				if op then
					S.pushTo(op, { toast = p.DisplayName .. " left. The duel is over.", duelDone = { done = true, abandoned = true } })
				end
			end
			forget(entry)
		end
	end)

	S.duelViewFor = function(player: Player)
		local key = duelOf[player.UserId]
		local entry = key and active[key]
		return entry and viewFor(entry, player.UserId) or nil
	end
end

return Duels
