--[[
	Condition checks for `when` (events, activities) and `requires` (choices).
	check() returns ok, reason. The reason is short text for UI hints.
]]

local Rng = require(script.Parent.Rng)
local Util = require(script.Parent.Util)

local Conditions = {}

-- World events running on the server right now, per content pack: worldActive[pack][id] = true.
-- The engine (Sim) owns the set; conditions only read it.
Conditions.worldActive = setmetatable({}, { __mode = "k" })
-- Today's daily event id per pack, and the server's chronicle of players' deeds per pack.
Conditions.dailyActive = setmetatable({}, { __mode = "k" })
Conditions.chronicle = setmetatable({}, { __mode = "k" })
Conditions.holds = setmetatable({}, { __mode = "k" }) -- [pack] = the server's record of each District (Engine/Renown.luau)

function Conditions.statValue(life, key: string): number?
	if key == "sanity" then
		return life.sanity
	elseif key == "money" then
		return life.money
	end
	return life.stats[key] -- nil for anything that isn't one of the pack's stats
end

function Conditions.hasLivingRelation(life, kinds): boolean
	for _, rel in life.relations do
		if rel.alive and Util.contains(kinds, rel.kind) then
			return true
		end
	end
	return false
end

local function statName(pack, key)
	local s = pack.stats[key]
	return s and s.name or key
end

-- opts.noChance = true skips the `chance` gate (used for UI previews and pre-filtering).
function Conditions.check(cond, life, pack, opts): (boolean, string?)
	if cond == nil then
		return true, nil
	end
	opts = opts or {}

	if cond.minAge and life.age < cond.minAge then
		return false, "Age " .. cond.minAge .. "+"
	end
	if cond.worldEvent or cond.noWorldEvent then
		local active = Conditions.worldActive[pack] or {}
		if cond.worldEvent then
			local any = false
			for _, id in Util.asList(cond.worldEvent) do
				if active[id] then
					any = true
				end
			end
			if not any then
				return false, "Not happening right now"
			end
		end
		for _, id in (if cond.noWorldEvent then Util.asList(cond.noWorldEvent) else {}) do
			if active[id] then
				return false, "Not with that going on"
			end
		end
	end
	if cond.maxAge and life.age > cond.maxAge then
		return false, "Too old for this"
	end
	-- (v0.12) a hard year (pack.crises): true = any, false = none, or which ones
	if cond.crisis ~= nil then
		local c = life.crisis
		if cond.crisis == true then
			if not c then
				return false, "Only in a hard year"
			end
		elseif cond.crisis == false then
			if c then
				return false, "Not in a hard year"
			end
		elseif not (c and Util.contains(Util.asList(cond.crisis), c)) then
			return false, "Only in a hard year"
		end
	end
	if cond.daily and not Util.contains(Util.asList(cond.daily), Conditions.dailyActive[pack]) then
		return false, "Not today"
	end
	if cond.chronicle then
		local acts = Util.asList(cond.chronicle)
		local found = false
		for _, e in Conditions.chronicle[pack] or {} do
			if e.lifeId ~= life.id and Util.contains(acts, e.act) then
				found = true
				break
			end
		end
		if not found then
			return false, "Nobody's done that yet"
		end
	end
	if cond.trait then
		local any = false
		for _, id in Util.asList(cond.trait) do
			if table.find(life.traits or {}, id) then
				any = true
			end
		end
		if not any then
			local def = pack.traits and pack.traits[Util.asList(cond.trait)[1]]
			return false, "Needs the " .. (if def then def.name else "right") .. " trait"
		end
	end
	if cond.noTrait then
		for _, id in Util.asList(cond.noTrait) do
			if table.find(life.traits or {}, id) then
				return false, "Not for you"
			end
		end
	end
	-- (v0.17) years as a Bloodfiend (old blood): bloodYears = n
	if cond.bloodYears then
		local years = if life.form == "bloodfiend" then life.age - (life.formAt or life.age) else -1
		if years < cond.bloodYears then
			return false, "Older blood only"
		end
	end
	-- (v0.17) the school you were trained in (pack.schools): school = "zwei" or { ... }
	if cond.school and not Util.contains(Util.asList(cond.school), life.school) then
		local def = pack.schools and pack.schools[Util.asList(cond.school)[1]]
		return false, (if def then def.org else "Another school") .. " only"
	end
	if cond.hasStyle and life.style == nil then
		return false, "Needs a discipline"
	end
	if cond.noStyle and life.style ~= nil then
		return false, "Only before you've found a fighting style"
	end
	if cond.style and not Util.contains(Util.asList(cond.style), life.style) then
		local def = pack.styles and pack.styles[Util.asList(cond.style)[1]]
		return false, (if def then def.name else "Another style") .. " fighters only"
	end
	if cond.minMastery and (life.mastery or 0) < cond.minMastery then
		return false, "Needs mastery " .. cond.minMastery
	end
	-- reputation: minRep = { thumb = 20 }, maxRep = { thumb = -20 }
	if cond.minRep then
		for id, n in cond.minRep do
			if ((life.rep and life.rep[id]) or 0) < n then
				local def = pack.reputation and pack.reputation[id]
				return false, "Needs standing " .. n .. " with " .. ((def and def.name) or id)
			end
		end
	end
	if cond.maxRep then
		for id, n in cond.maxRep do
			if ((life.rep and life.rep[id]) or 0) > n then
				return false, "Not while you're in their good books"
			end
		end
	end
	if cond.minYear and life.year < cond.minYear then
		return false, "Not yet"
	end
	-- years since this life's story began (stories that find you later count from there)
	if cond.storyYear or cond.minStoryYear or cond.maxStoryYear then
		local y = life.age - (life.storyStart or 0)
		if cond.storyYear and y ~= cond.storyYear then
			return false, "Not yet"
		end
		if cond.minStoryYear and y < cond.minStoryYear then
			return false, "Not yet"
		end
		if cond.maxStoryYear and y > cond.maxStoryYear then
			return false, "Those days are gone"
		end
	end
	if cond.maxYear and life.year > cond.maxYear then
		return false, "Those days are gone"
	end
	if cond.side then
		local list = Util.asList(cond.side)
		if not Util.contains(list, life.side) then
			local s = pack.sides[list[1]]
			return false, "Only in " .. (if s then s.short else list[1])
		end
	end
	if cond.notSide and Util.contains(Util.asList(cond.notSide), life.side) then
		return false, "Not here"
	end
	if cond.district then
		local list = Util.asList(cond.district)
		if not Util.contains(list, life.district) then
			local d = pack.districts[list[1]]
			return false, "Only in " .. (if d then d.name else list[1])
		end
	end
	if cond.notDistrict and Util.contains(Util.asList(cond.notDistrict), life.district) then
		return false, "Not in this " .. ((pack and pack.meta and pack.meta.districtWord) or "Ward")
	end
	if cond.linked or cond.linkedRough then
		local found = false
		for _, rel in life.relations do
			if rel.alive and rel.userId ~= nil and rel.online == true and (not cond.linkedRough or rel.rough == true) then
				found = true
				break
			end
		end
		if not found then
			return false, "Needs a linked friend online"
		end
	end
	if cond.career ~= nil then
		local list = Util.asList(cond.career)
		local current = if life.career then life.career.id else "none"
		if not Util.contains(list, current) then
			local c = pack.careers[list[1]]
			return false, if c then "For the " .. c.name else "Needs no job"
		end
	end
	if cond.anyCareer and life.career == nil then
		return false, "Needs a job"
	end
	if cond.minRank and (life.career == nil or life.career.rank < cond.minRank) then
		return false, "Needs a higher rank"
	end
	-- renown: at least this rank of pack.renown (Engine/Renown.luau)
	if cond.renown then
		local ranks = pack.renown and pack.renown.ranks
		local r = 0
		for i, def in ranks or {} do
			if (life.renown or 0) >= def.at then
				r = i
			end
		end
		if r < cond.renown then
			local need = ranks and ranks[cond.renown]
			return false, "Needs renown: " .. (if need then need.name else tostring(cond.renown))
		end
	end
	-- an Office of your own (true), of at least this size (a number), or none (office = false)
	if cond.office ~= nil then
		if cond.office == false then
			if life.office then
				return false, "You already run an Office"
			end
		elseif not life.office then
			return false, "Needs an Office of your own"
		elseif type(cond.office) == "number" and life.office.size < cond.office then
			return false, "Needs a bigger Office"
		end
	end
	if cond.form then
		local list = Util.asList(cond.form)
		if not Util.contains(list, life.form) then
			local f = pack.forms[list[1]]
			return false, (if f then f.name else list[1]) .. " only"
		end
	end
	if cond.world then
		for key, want in cond.world do
			if not Util.contains(Util.asList(want), life.world[key]) then
				return false, "Not this year"
			end
		end
	end
	if cond.flags then
		for _, f in cond.flags do
			if not life.flags[f] then
				return false, "Locked"
			end
		end
	end
	if cond.notFlags then
		for _, f in cond.notFlags do
			if life.flags[f] then
				return false, "Locked"
			end
		end
	end
	if cond.min then
		for key, n in cond.min do
			local v = Conditions.statValue(life, key)
			if v == nil or v < n then
				if key == "money" then
					return false, "Needs " .. n .. " " .. pack.meta.currency
				end
				return false, "Needs " .. statName(pack, key) .. " " .. n
			end
		end
	end
	if cond.max then
		for key, n in cond.max do
			local v = Conditions.statValue(life, key)
			if v == nil or v > n then
				return false, statName(pack, key) .. " too high"
			end
		end
	end
	if cond.hasRelation and not Conditions.hasLivingRelation(life, Util.asList(cond.hasRelation)) then
		return false, "Needs someone close"
	end
	if cond.noRelation and Conditions.hasLivingRelation(life, Util.asList(cond.noRelation)) then
		return false, "Not now"
	end
	if cond.hasBook then
		local has = false
		for _, id in Util.asList(cond.hasBook) do
			if life.books and table.find(life.books, id) then
				has = true
			end
		end
		if not has then
			return false, "Needs the book"
		end
	end
	if cond.noBook then
		for _, id in Util.asList(cond.noBook) do
			if life.books and table.find(life.books, id) then
				return false, "Already have it"
			end
		end
	end
	if cond.hasGear then
		local owned = false
		for _, id in Util.asList(cond.hasGear) do
			local def = pack.gear and pack.gear[id]
			if def and life.gear and life.gear[def.slot] == id then
				owned = true
			end
		end
		if not owned then
			local def = pack.gear and pack.gear[Util.asList(cond.hasGear)[1]]
			return false, "Needs a " .. (if def then def.name else "tool")
		end
	end
	if cond.noGear then
		for _, id in Util.asList(cond.noGear) do
			local def = pack.gear and pack.gear[id]
			if def and life.gear and life.gear[def.slot] == id then
				return false, "Not with that gear"
			end
		end
	end
	if cond.hasCondition or cond.noCondition then
		local function has(id)
			for _, c in life.conditions or {} do
				if c.id == id then
					return true
				end
			end
			return false
		end
		if cond.hasCondition then
			local any = false
			for _, id in Util.asList(cond.hasCondition) do
				if has(id) then
					any = true
				end
			end
			if not any then
				return false, "Not now"
			end
		end
		if cond.noCondition then
			for _, id in Util.asList(cond.noCondition) do
				if has(id) then
					local def = pack.conditions and pack.conditions[id]
					return false, "Not with " .. (if def then def.name else id)
				end
			end
		end
	end
	if cond.chance and not opts.noChance then
		if not Rng.chance(life, cond.chance) then
			return false, "Not this time"
		end
	end
	return true, nil
end

return Conditions
