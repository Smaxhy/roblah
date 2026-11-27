--[[
	THE PARTY (BitLeveling, v0.19): the server side of bonds and the NPC party.
	Engine/Party.luau holds the rules; this checks every request and runs it on the life.

	Handlers (the Request remote), all of them for the player's own living life:
		partyView                         the PARTY screen: members, candidates and their odds, gifts
		partyProfile { relId }            one person: backstory so far, likes, traits, your history,
		                                  and what you can do with them right now
		partyAsk     { relId }            ask them to join (they accept or refuse, in their words)
		partyDismiss { relId }            part ways with a member
		partyGift    { relId, gift }      give one of the pack's gifts (pack.party.gifts)
		partyTalk    { relId }            talk (you may learn what they like)
		partyMeal    { relId }            share a meal
		partyPast    { relId }            ask about their past (a line of it, by bond)
		partyTrain   { relId }            train together
		partySpar    { relId, approach? } spar (a clash with their numbers)
		partyRaid    { relId, approach? } raid a Gate together (a clash, with them beside you)
		partyDo      { relId, id, approach?, gift? }   any of the above by interaction id
	Every reply is the usual life response (life, entries, clash...) plus `party` (the PARTY
	screen again), `result` (what the person said and did: accepted, line, odds...) and, for
	partyProfile and anything done from it, `profile`.

	Checked here: the payload's shape, that the person is one of this life's living NPCs (never
	a linked player), that the interaction is one of the party's, that a gift and a way of
	fighting exist. The engine checks the rest (time left this year, money, cooldowns, who can
	be asked) and says why not.
]]

local HunterParty = {}

-- what each named handler does (Engine/Party interactions in Games/BitLeveling/Interactions)
local NAMED = {
	partyAsk = "bl_ask",
	partyDismiss = "bl_dismiss",
	partyGift = "bl_gift",
	partyTalk = "spend_time",
	partyMeal = "bl_meal",
	partyPast = "bl_past",
	partyTrain = "bl_train",
	partySpar = "bl_spar",
	partyRaid = "bl_raid",
}

local function finite(n: any): boolean
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

function HunterParty.install(S)
	local Content = S.Content
	if type(Content.party) ~= "table" then
		return -- (a pack without a party: nothing to install)
	end
	local sim = S.sim
	local handlers = S.handlers

	-- the interactions this module runs: the party's own, the kit's talk, asking to be friends
	local allowed: { [string]: boolean } = {}
	for _, id in NAMED do
		if Content.interactions and Content.interactions[id] then
			allowed[id] = true
		end
	end
	for id, def in Content.interactions or {} do
		if type(def) == "table" and def.party ~= nil then
			allowed[id] = true
		end
	end
	if Content.interactions and Content.interactions.bl_befriend then
		allowed.bl_befriend = true
	end
	local gifts: { [string]: boolean } = {}
	for _, g in Content.party.gifts or {} do
		if type(g) == "table" and type(g.id) == "string" then
			gifts[g.id] = true
		end
	end

	local function lifeOf(session: any): any
		local life = session and session.profile and session.profile.Data.life
		return if life and life.alive then life else nil
	end

	-- the NPC a request is about: one of this life's own living people (not a linked player)
	local function personOf(life: any, payload: any): (any, string?)
		if type(payload) ~= "table" or not finite(payload.relId) then
			return nil, "Bad request."
		end
		local relId = math.floor(payload.relId)
		local rel = sim:relationById(life, relId)
		if not rel then
			return nil, "They aren't in your life."
		end
		if rel.userId ~= nil then
			return nil, "That's another player. Send word instead."
		end
		if not rel.alive then
			return nil, "They're gone."
		end
		return rel, nil
	end

	local function profileOf(life: any, rel: any): any
		local p = sim:npcProfile(life, rel.id)
		if p then
			-- what you can do with them right now (the same list as the People tab's)
			p.interactions = sim:interactionsFor(life, rel)
		end
		return p
	end

	-- runs one interaction on the life the way the server's other life actions do: linked
	-- friends kept fresh, the city told, feats kept, news shared, the life sent back
	local function act(player: Player, session: any, rel: any, id: string, approach: string?, arg: any?, withProfile: boolean?)
		local life = lifeOf(session)
		if not life then
			return { ok = false, error = "You need a living life for that." }
		end
		S.syncLinks(session)
		local report, err = sim:interact(life, rel.id, id, approach, arg)
		if not report then
			return { ok = false, error = err or "Not right now." }
		end
		if S.City and S.City.afterReport then
			pcall(S.City.afterReport, player, session, report)
		end
		if life.feats then
			local data = session.profile.Data
			data.featsEver = data.featsEver or {}
			for fid, age in life.feats do
				data.featsEver[fid] = data.featsEver[fid] or age
			end
		end
		local news = sim:takeNews(life)
		local res = S.lifeResponse(session, report)
		if life.alive and #news > 0 and S.shareWithFriends then
			task.defer(S.shareWithFriends, player, session, news)
		end
		res.result = report.party
		res.party = if life.alive then sim:partyView(life) else nil
		if withProfile and life.alive then
			local again = sim:relationById(life, rel.id)
			res.profile = if again and again.alive then profileOf(life, again) else nil
		end
		return res
	end

	function handlers.partyView(_player, session)
		local life = lifeOf(session)
		if not life then
			return { ok = false, error = "You need a living life for that." }
		end
		return { ok = true, party = sim:partyView(life) }
	end

	function handlers.partyProfile(_player, session, payload)
		local life = lifeOf(session)
		if not life then
			return { ok = false, error = "You need a living life for that." }
		end
		local rel, why = personOf(life, payload)
		if not rel then
			return { ok = false, error = why }
		end
		return { ok = true, profile = profileOf(life, rel) }
	end

	-- the named ones
	for name, id in NAMED do
		if allowed[id] then
			handlers[name] = function(player, session, payload)
				local life = lifeOf(session)
				if not life then
					return { ok = false, error = "You need a living life for that." }
				end
				local rel, why = personOf(life, payload)
				if not rel then
					return { ok = false, error = why }
				end
				local approach = if type(payload.approach) == "string" and Content.approaches and Content.approaches[payload.approach] then payload.approach else nil
				local arg = nil
				if id == "bl_gift" then
					if payload.gift ~= nil then
						if type(payload.gift) ~= "string" or not gifts[payload.gift] then
							return { ok = false, error = "That isn't something you can give." }
						end
						arg = payload.gift
					end
				end
				return act(player, session, rel, id, approach, arg, payload.profile == true)
			end
		end
	end

	-- any of them by id (the NPC profile's list)
	function handlers.partyDo(player, session, payload)
		local life = lifeOf(session)
		if not life then
			return { ok = false, error = "You need a living life for that." }
		end
		local rel, why = personOf(life, payload)
		if not rel then
			return { ok = false, error = why }
		end
		if type(payload.id) ~= "string" or not allowed[payload.id] then
			return { ok = false, error = "That isn't something you can do with them." }
		end
		local approach = if type(payload.approach) == "string" and Content.approaches and Content.approaches[payload.approach] then payload.approach else nil
		local arg = nil
		if payload.gift ~= nil then
			if type(payload.gift) ~= "string" or not gifts[payload.gift] then
				return { ok = false, error = "That isn't something you can give." }
			end
			arg = payload.gift
		end
		return act(player, session, rel, payload.id, approach, arg, payload.profile ~= false)
	end

	HunterParty.allowed = allowed
end

return HunterParty
