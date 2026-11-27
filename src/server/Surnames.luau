--[[
	Surname rolls: spin for a family name. Higher tiers are rarer and carry a small trait.
	Rolls are earned by playing (new players get some, one a day for logging in, one per
	finished life, and big moments in a life). They are never sold.
	The odds are shown to the player, and a pity counter guarantees a Rare or better every
	`pityAt` rolls.

	pack.surnames = {
		tiers = { { id, name, weight, color = {r,g,b}, trait = "id"?, desc = "..."? }, ... }  -- common first
		names = { [tierId] = { "Name", ... } },
		pityAt = 10, pityTier = "rare",
	}
	Saved per player: surname = { name, tier }, pendingSurname, rolls, pity.
]]

local Surnames = {}

function Surnames.install(S)
	local Content = S.Content
	local handlers = S.handlers
	local def = Content.surnames
	local rng = Random.new()

	local function tierIndex(id: string?): number
		for i, t in (def and def.tiers) or {} do
			if t.id == id then
				return i
			end
		end
		return 0
	end

	local function tierOf(id: string?)
		local i = tierIndex(id)
		return if i > 0 then def.tiers[i] else nil
	end
	Surnames.tierOf = tierOf

	local function stateOf(data)
		if not def then
			return nil
		end
		local total = 0
		for _, t in def.tiers do
			total += t.weight
		end
		local tiers = {}
		for _, t in def.tiers do
			local trait = t.trait and Content.traits and Content.traits[t.trait]
			table.insert(tiers, {
				id = t.id,
				name = t.name,
				color = t.color,
				odds = math.floor(t.weight / total * 1000 + 0.5) / 10,
				perk = if trait then trait.name .. ": " .. trait.desc else t.desc,
				examples = { table.unpack(def.names[t.id] or {}, 1, 3) },
			})
		end
		-- a premium roll can only land the pity tier or better: its odds, for the player to see
		local pityIdx = tierIndex(def.pityTier or "rare")
		local premiumTotal = 0
		for i, t in def.tiers do
			if i >= pityIdx then
				premiumTotal += t.weight
			end
		end
		local premiumOdds = {}
		for i, t in def.tiers do
			if i >= pityIdx and premiumTotal > 0 then
				table.insert(premiumOdds, { id = t.id, name = t.name, odds = math.floor(t.weight / premiumTotal * 1000 + 0.5) / 10 })
			end
		end
		return {
			current = data.surname,
			pending = data.pendingSurname,
			rolls = data.rolls or 0,
			premiumRolls = data.premiumRolls or 0,
			premiumOdds = premiumOdds,
			pity = data.pity or 0,
			pityAt = def.pityAt or 10,
			pityTier = (tierOf(def.pityTier or "rare") or {}).name,
			tiers = tiers,
		}
	end
	Surnames.state = stateOf

	-- what a new life gets from the family name
	function Surnames.forLife(data)
		local s = data.surname
		if not def or not s then
			return nil, nil
		end
		local tier = tierOf(s.tier)
		return s.name, if tier and tier.trait then { tier.trait } else nil
	end

	local function roll(data, premium: boolean?)
		local pityAt = def.pityAt or 10
		local pityIdx = tierIndex(def.pityTier or "rare")
		local forced = pityIdx > 0 and (premium or (data.pity or 0) + 1 >= pityAt)
		local pool, total = {}, 0
		for i, t in def.tiers do
			if not forced or i >= pityIdx then
				table.insert(pool, t)
				total += t.weight
			end
		end
		local r = rng:NextNumber() * total
		local tier = pool[#pool]
		for _, t in pool do
			r -= t.weight
			if r <= 0 then
				tier = t
				break
			end
		end
		local names = def.names[tier.id]
		local name = names[rng:NextInteger(1, #names)]
		if tierIndex(tier.id) >= pityIdx and pityIdx > 0 then
			data.pity = 0
		else
			data.pity = (data.pity or 0) + 1
		end
		return { name = name, tier = tier.id, tierName = tier.name, color = tier.color, flavor = def.flavor and def.flavor[name] }
	end

	function handlers.surnames(_player, session)
		return { ok = true, surnames = stateOf(session.profile.Data) }
	end

	function handlers.surnameRoll(_player, session, payload)
		local data = session.profile.Data
		if not def then
			return { ok = false, error = "No surnames in this game." }
		end
		if data.pendingSurname then
			return { ok = false, error = "Keep or pass on the last roll first." }
		end
		local premium = type(payload) == "table" and payload.premium == true
		if premium then
			if (data.premiumRolls or 0) <= 0 then
				return { ok = false, error = "No Rare-or-better rolls left." }
			end
			data.premiumRolls -= 1
		else
			if (data.rolls or 0) <= 0 then
				return { ok = false, error = "No rolls left. You earn them by playing, or get more in the Store." }
			end
			data.rolls -= 1
		end
		local rolled = roll(data, premium)
		-- the first surname is kept automatically
		if not data.surname then
			data.surname = { name = rolled.name, tier = rolled.tier, flavor = rolled.flavor }
			return { ok = true, rolled = rolled, kept = true, surnames = stateOf(data) }
		end
		data.pendingSurname = rolled
		return { ok = true, rolled = rolled, surnames = stateOf(data) }
	end

	function handlers.surnameKeep(_player, session, payload)
		local data = session.profile.Data
		local pending = data.pendingSurname
		if not pending then
			return { ok = false, error = "Nothing to keep." }
		end
		data.pendingSurname = nil
		if type(payload) == "table" and payload.keep == true then
			data.surname = { name = pending.name, tier = pending.tier, flavor = pending.flavor }
		end
		return { ok = true, surnames = stateOf(data), toast = if data.surname and data.surname.name == pending.name then "You are a " .. pending.name .. " now. New lives carry the name." else nil }
	end
end

return Surnames
