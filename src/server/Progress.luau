--[[
	Progress: talents, game modes and Lunacy.

	TALENTS  Every life is born with one random talent (pack.talents: tiers and their real
	         odds). The server rolls it before the life starts, so the creator can show it.
	         Rerolls: FREE_PER_DAY free a day (VIP gets FREE_VIP more), then Lunacy.
	         A "Rare or better" reroll costs more, and Legendary or better is guaranteed
	         within PITY_AT of them.
	         Lunacy rerolls are paid random items (Lunacy can be bought with Robux): the odds
	         are shown before every roll, and players whose Roblox policy restricts paid
	         random items only get the free rerolls.
	AFFINITIES  data.affinities: up to two sins (pack.affinities) the player leans toward. Talents
	         of those sins are 3x as likely within the rolled rarity (the rarity odds never
	         change), and a matching talent resonates in the life (+3% heads).
	MODES    pack.modes: how a life starts. A locked mode opens with a record, a store pass,
	         or Light (any one of them).
	LUNACY   data.lunacy. Earned a little by playing (a daily gift, finished lives, new
	         Records) and bought in the store; spent on rerolls and on store items priced
	         in Lunacy (Store.luau, storeSpend).
]]

local Progress = {}

Progress.FREE_PER_DAY = 3
Progress.FREE_VIP = 2
Progress.REROLL_COST = 30
Progress.PREMIUM_COST = 150
Progress.PREMIUM_FROM = "rare"
Progress.PITY_FROM = "legendary"
Progress.PITY_AT = 10
Progress.DAILY_LUNACY = 10
Progress.DAILY_LUNACY_VIP = 20
Progress.LIFE_LUNACY = 2
Progress.RECORD_LUNACY = 3

local S = nil -- the server's shared table, set by install

local function today(): number
	return math.floor(os.time() / 86400)
end

local function rngState()
	return { rng = math.random(1, 2147483646) }
end

local function tierIndex(id: string?): number
	for i, tier in (S.Content.talents and S.Content.talents.tiers) or {} do
		if tier.id == id then
			return i
		end
	end
	return 0
end

function Progress.enabled(): boolean
	return S ~= nil and S.Content.talents ~= nil and S.Content.talents.tiers ~= nil
end

function Progress.freeLeft(data): number
	local per = Progress.FREE_PER_DAY + (if data.perks and data.perks.vip then Progress.FREE_VIP else 0)
	local t = data.talentFree
	if type(t) ~= "table" or t.day ~= today() then
		return per
	end
	return math.max(0, per - (t.used or 0))
end

local function useFree(data)
	local t = data.talentFree
	if type(t) ~= "table" or t.day ~= today() then
		t = { day = today(), used = 0 }
		data.talentFree = t
	end
	t.used += 1
end

local function affinitiesOf(data): { string }
	return S.sim:cleanAffinities(data.affinities)
end

function Progress.talentView(id: string?, data)
	local def = id and S.sim:traitDef(id)
	if not def or not def.talent then
		return nil
	end
	local tier = S.sim:talentTier(def.talent)
	local aff = def.affinity and S.Content.affinities and S.Content.affinities[def.affinity]
	return {
		id = id,
		name = def.name,
		desc = def.desc,
		tier = def.talent,
		tierName = if tier then tier.name else def.talent,
		color = if tier then tier.color else nil,
		rank = tierIndex(def.talent),
		affinity = def.affinity,
		affinityName = if aff then aff.name else nil,
		affinityColor = if aff then aff.color else nil,
		resonance = data ~= nil and def.affinity ~= nil and table.find(affinitiesOf(data), def.affinity) ~= nil,
	}
end

-- the talent the next life will be born with (rolled once, kept until a life starts)
local function ensurePending(data): string?
	if not Progress.enabled() then
		return nil
	end
	local id = data.pendingTalent
	local def = type(id) == "string" and S.sim:traitDef(id)
	if def and def.talent then
		return id
	end
	data.pendingTalent = S.sim:rollTalent(rngState(), nil, affinitiesOf(data))
	return data.pendingTalent
end

-- the affinities a new life starts with
function Progress.affinitiesFor(data): { string }
	if not S then
		return {}
	end
	return affinitiesOf(data)
end

-- startLife takes the pending talent; the next life rolls a fresh one
function Progress.takeTalent(data): string?
	local id = ensurePending(data)
	data.pendingTalent = nil
	return id
end

local function restrictedFor(player: Player?, session): boolean
	local Store = S.Store
	if Store and Store.enabled and Store.randomRestricted then
		return Store.randomRestricted(player, session)
	end
	return false
end

function Progress.talentState(player: Player?, session)
	local data = session.profile.Data
	if not Progress.enabled() then
		return nil
	end
	return {
		talent = Progress.talentView(ensurePending(data), data),
		affinities = affinitiesOf(data),
		affinityWeight = S.sim.AFFINITY_WEIGHT or 3,
		free = Progress.freeLeft(data),
		lunacy = data.lunacy or 0,
		cost = Progress.REROLL_COST,
		premiumCost = Progress.PREMIUM_COST,
		odds = S.sim:talentOdds(nil),
		premiumOdds = S.sim:talentOdds(Progress.PREMIUM_FROM),
		pityLeft = Progress.PITY_AT - (data.talentPity or 0),
		pityAt = Progress.PITY_AT,
		restricted = restrictedFor(player, session),
	}
end

-- ── modes ───────────────────────────────────────────────────────────────────

function Progress.modeDef(id: string?)
	return S.sim:modeDef(id)
end

-- (v0.18) a hidden mode (pack.modes[].hidden) is nobody's, unless Config.devModes says so
local function modeHidden(mode): boolean
	return mode ~= nil and mode.hidden == true and not (S and S.Config and S.Config.devModes)
end
Progress.modeHidden = modeHidden

function Progress.modeUnlocked(data, mode): boolean
	if modeHidden(mode) then
		return false
	end
	local u = mode and mode.unlock
	if not u then
		return mode ~= nil
	end
	if u.record and data.records and data.records[u.record] then
		return true
	end
	if u.pass and data.owned and data.owned[u.pass] then
		return true
	end
	return data.unlocked ~= nil and data.unlocked["mode:" .. mode.id] == true
end

function Progress.modesUnlocked(data)
	local out = {}
	if not S then
		return out
	end
	for _, m in S.Content.modes or {} do
		if Progress.modeUnlocked(data, m) then
			out[m.id] = true
		end
	end
	return out
end

-- the sins, with the talents of each (static; sent once with info)
function Progress.affinitiesInfo()
	local list = {}
	local defs = S.Content.affinities
	for _, id in (defs and defs.order) or {} do
		local a = defs[id]
		local talents = {}
		for _, tier in (S.Content.talents and S.Content.talents.tiers) or {} do
			for _, tid in S.sim:talentPool(tier.id) do
				local def = S.sim:traitDef(tid)
				if def and def.affinity == id then
					table.insert(talents, { id = tid, name = def.name, tier = tier.id, tierName = tier.name, color = tier.color })
				end
			end
		end
		-- (a pack can say more about each: BitLeveling's classes add about, their main stat, their
		-- role in a party and their magic schools)
		local schools = nil
		if type(a.schools) == "table" then
			schools = table.clone(a.schools)
		end
		table.insert(list, {
			id = id, name = a.name, color = a.color, desc = a.desc, talents = talents,
			about = if type(a.about) == "string" then a.about else nil,
			stat = if type(a.stat) == "string" then a.stat else nil,
			role = if type(a.role) == "string" then a.role else nil,
			schools = schools,
		})
	end
	return list
end

-- what the mode screen shows (static; sent once with info)
function Progress.modesInfo()
	local list = {}
	for _, m in S.Content.modes or {} do
		if modeHidden(m) then
			continue
		end
		local start = m.start or {}
		table.insert(list, {
			id = m.id,
			name = m.name,
			tagline = m.tagline,
			desc = m.desc,
			color = m.color,
			startAge = start.age or 0,
			form = start.form,
			career = start.career and S.Content.careers[start.career] and S.Content.careers[start.career].name or nil,
			era = m.era,
			locked = m.unlock ~= nil,
			unlockText = m.unlockText,
			lightCost = m.unlock and m.unlock.light or nil,
			-- (v0.18) only the tests (Config.devModes) ever see a hidden mode, and no menu shows it
			hidden = if m.hidden == true then true else nil,
		})
	end
	return list
end

-- ── Lunacy ──────────────────────────────────────────────────────────────────

function Progress.addLunacy(data, n: number)
	data.lunacy = math.max(0, math.floor((data.lunacy or 0) + n))
end

function Progress.spendLunacy(data, n: number): boolean
	if (data.lunacy or 0) < n then
		return false
	end
	data.lunacy -= n
	return true
end

-- a finished life: a little Lunacy, more for each first-time Record
function Progress.onLifeEnd(data, freshRecords: number): number
	local n = Progress.LIFE_LUNACY + Progress.RECORD_LUNACY * (freshRecords or 0)
	Progress.addLunacy(data, n)
	return n
end

function Progress.dailyLunacy(data): number
	local n = if data.perks and data.perks.vip then Progress.DAILY_LUNACY_VIP else Progress.DAILY_LUNACY
	Progress.addLunacy(data, n)
	return n
end

-- ── install ─────────────────────────────────────────────────────────────────

function Progress.install(shared)
	S = shared
	local handlers = S.handlers

	function handlers.talentState(player, session)
		local st = Progress.talentState(player, session)
		if not st then
			return { ok = false, error = "No talents in this game." }
		end
		return { ok = true, talent = st }
	end

	function handlers.talentReroll(player, session, payload)
		if not Progress.enabled() then
			return { ok = false, error = "No talents in this game." }
		end
		local data = session.profile.Data
		payload = if type(payload) == "table" then payload else {}
		ensurePending(data)
		local premium = payload.premium == true
		local restricted = restrictedFor(player, session)
		local from = nil
		if premium then
			if restricted then
				return { ok = false, error = "Paid rerolls aren't available where you live (Roblox's rules on paid random items)." }
			end
			if not Progress.spendLunacy(data, Progress.PREMIUM_COST) then
				return { ok = false, error = "Not enough Lunacy." }
			end
			data.talentPity = (data.talentPity or 0) + 1
			from = if data.talentPity >= Progress.PITY_AT then Progress.PITY_FROM else Progress.PREMIUM_FROM
		elseif Progress.freeLeft(data) > 0 then
			useFree(data)
		else
			if restricted then
				return { ok = false, error = "No free rerolls left today. They come back tomorrow." }
			end
			if payload.lunacy ~= true then
				return { ok = false, error = "No free rerolls left today.", needLunacy = Progress.REROLL_COST }
			end
			if not Progress.spendLunacy(data, Progress.REROLL_COST) then
				return { ok = false, error = "Not enough Lunacy." }
			end
		end
		local id = S.sim:rollTalent(rngState(), from, affinitiesOf(data))
		if not id then
			return { ok = false, error = "No talents to roll." }
		end
		data.pendingTalent = id
		local view = Progress.talentView(id, data)
		if premium and view and view.rank >= tierIndex(Progress.PITY_FROM) then
			data.talentPity = 0
		end
		return { ok = true, talent = Progress.talentState(player, session), rolled = view, meta = S.metaView(data) }
	end

	-- the sins a player leans toward (up to two); they shape the next talent rolls
	function handlers.setAffinities(player, session, payload)
		local data = session.profile.Data
		local list = type(payload) == "table" and payload.ids or nil
		data.affinities = S.sim:cleanAffinities(list)
		return { ok = true, talent = Progress.talentState(player, session) }
	end

	function handlers.unlockMode(_player, session, payload)
		local data = session.profile.Data
		local mode = type(payload) == "table" and Progress.modeDef(payload.id)
		if not mode then
			return { ok = false, error = "No such mode." }
		end
		if Progress.modeUnlocked(data, mode) then
			return { ok = true, meta = S.metaView(data) }
		end
		local cost = mode.unlock and mode.unlock.light
		if not cost then
			return { ok = false, error = mode.unlockText or "This mode opens another way." }
		end
		if (data.glow or 0) < cost then
			return { ok = false, error = string.format("You need %d Light (you have %d).", cost, data.glow or 0) }
		end
		data.glow -= cost
		data.unlocked = data.unlocked or {}
		data.unlocked["mode:" .. mode.id] = true
		return { ok = true, meta = S.metaView(data), toast = mode.name .. " unlocked." }
	end
end

return Progress
