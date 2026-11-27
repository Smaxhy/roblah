--!strict
--[[
	MARKETS AND HOMES (v0.12): places to spend money that change with the City.

	pack.markets = { order = { ids }, [id] = market }
	  market: { name, desc, keeper?, emblem?, minAge?, when? (Conditions: who can shop there),
	            markup = { { when, mult, why } }  (prices up or down while something is true:
	            a turf war, a hard year), goods = { good } }
	  good:   { id, name, desc, price, result (an effect result: Effects.apply),
	            when? (Conditions: when it's stocked at all), chance? (0..1: on the shelf this
	            year or not; the same answer all year, a new one every year), once? (one per
	            life), perYear? (how many a year; default 1), requires? (Conditions to buy it,
	            shown as the reason when it's stocked but not for you), tag? }
	  Buying never costs an action. It pays the price, applies the result, and records
	  life.bought[goodId] = { n (this year), age, total }.

	pack.homes = { order = { ids }, [id] = home }: result.home = id moves the life in (the old
	  place is sold for half what it cost); result.sellHome = true sells it.
	  home: { name, desc, price, upkeep (a year), sanity (a year), safety (0..1: bad luck in
	          the streets is that much rarer), hideout (0..1: grudges find you that much less),
	          income? (a year: rent), renown? (a year) }
]]

local Conditions = require(script.Parent.Conditions)

local Market = {}

local function hash(s: string): number
	local h = 7
	for i = 1, #s do
		h = (h * 31 + string.byte(s, i)) % 2147483647
	end
	return h
end

-- on the shelf this year? A stable roll: the same all year, different the next
local function stockRoll(life: any, marketId: string, goodId: string): number
	return (hash(tostring(life.id) .. ":" .. tostring(life.age) .. ":" .. marketId .. ":" .. goodId) % 10000) / 10000
end

function Market.def(self: any, id: string): any
	local m = self.pack.markets
	return m and m[id]
end

function Market.open(self: any, life: any, m: any): (boolean, string?)
	if m.minAge and life.age < m.minAge then
		return false, "Age " .. m.minAge .. "+"
	end
	return Conditions.check(m.when, life, self.pack, { noChance = true })
end

-- prices this year: every markup that holds, multiplied, and the reason for the last one
function Market.markup(self: any, life: any, m: any): (number, string?)
	local mult, why = 1, nil
	for _, mk in m.markup or {} do
		if Conditions.check(mk.when, life, self.pack, { noChance = true }) then
			mult *= mk.mult or 1
			why = mk.why or why
		end
	end
	return mult, why
end

local function boughtThisYear(life: any, g: any): number
	local rec = life.bought and life.bought[g.id]
	if rec and rec.age == life.age then
		return rec.n or 0
	end
	return 0
end

-- stocked: it's on the shelf this year. ok: this life can buy it now (why not, if not).
function Market.goodState(self: any, life: any, marketId: string, m: any, g: any): (boolean, boolean, string?, number)
	if g.when and not Conditions.check(g.when, life, self.pack, { noChance = true }) then
		return false, false, nil, 0
	end
	if g.chance and stockRoll(life, marketId, g.id) >= g.chance then
		return false, false, nil, 0
	end
	local mult = Market.markup(self, life, m)
	local price = self:priceFor(life, math.max(0, math.floor((g.price or 0) * mult + 0.5)))
	local rec = life.bought and life.bought[g.id]
	local home = g.result and g.result.home
	if home and life.home and life.home.id == home then
		return true, false, "You live here", price
	end
	if g.once and rec and (rec.total or 0) > 0 then
		return true, false, "Already yours", price
	end
	if boughtThisYear(life, g) >= (g.perYear or 1) then
		return true, false, "Sold out this year", price
	end
	-- cooldown: years between one and the next (stat-boosting goods aren't a yearly habit)
	if g.cooldown and rec and rec.age and life.age - rec.age < g.cooldown and life.age ~= rec.age then
		local wait = g.cooldown - (life.age - rec.age)
		return true, false, string.format("Back in %d year%s", wait, if wait == 1 then "" else "s"), price
	end
	if g.result and g.result.sellHome and not life.home then
		return true, false, "Nothing to sell", price
	end
	if g.requires then
		local ok, why = Conditions.check(g.requires, life, self.pack, { noChance = true })
		if not ok then
			return true, false, why, price
		end
	end
	if not life.alive then
		return true, false, "This life is over", price
	end
	if life.pending then
		return true, false, "Decide first", price
	end
	if life.money < price then
		return true, false, "Needs " .. price .. " " .. self.pack.meta.currency, price
	end
	return true, true, nil, price
end

function Market.find(self: any, marketId: string, goodId: string): (any, any)
	local m = Market.def(self, marketId)
	if not m then
		return nil, nil
	end
	for _, g in m.goods or {} do
		if g.id == goodId then
			return m, g
		end
	end
	return m, nil
end

-- buys a good: the price, then its result. Returns the report, or nil and why not.
function Market.buy(self: any, life: any, marketId: string, goodId: string, report: any): (any, string?)
	local m, g = Market.find(self, marketId, goodId)
	if not m then
		return nil, "No such market."
	end
	if not g then
		return nil, "Not sold here."
	end
	local open, closed = Market.open(self, life, m)
	if not open then
		return nil, closed
	end
	local stocked, ok, why, price = Market.goodState(self, life, marketId, m, g)
	if not stocked then
		return nil, "Not on the shelf this year."
	end
	if not ok then
		return nil, why
	end
	life.bought = life.bought or {}
	local rec = life.bought[g.id] or { n = 0, age = life.age, total = 0 }
	if rec.age ~= life.age then
		rec.n = 0
		rec.age = life.age
	end
	rec.n += 1
	rec.total = (rec.total or 0) + 1
	life.bought[g.id] = rec
	self:push(life, report, { kind = "event", title = "Bought: " .. g.name, choice = m.name, thread = "you" })
	-- the price is part of the result, so the feed shows it with everything else it did
	local result = table.clone(g.result or {})
	result.money = -price + (if type(result.money) == "number" then result.money else 0)
	if not result.log then
		result.log = "You paid " .. price .. " " .. self.pack.meta.currency .. " for " .. g.name .. "."
	end
	self:applyResult(life, result, report)
	return report, nil
end

-- what each market a life can shop at has this year
function Market.view(self: any, life: any): any
	local markets = self.pack.markets
	if not markets then
		return nil
	end
	local out = {}
	for _, id in markets.order or {} do
		local m = markets[id]
		local open = Market.open(self, life, m)
		if open then
			local mult, why = Market.markup(self, life, m)
			local goods, unseen = {}, 0
			for _, g in m.goods or {} do
				local stocked, ok, reason, price = Market.goodState(self, life, id, m, g)
				if stocked then
					table.insert(goods, {
						id = g.id,
						name = g.name,
						desc = self:render(life, g.desc or ""),
						price = price,
						enabled = ok,
						reason = reason,
						tag = g.tag,
						gains = if g.result then self:stakesOf(g.result, nil, nil, life, nil) else nil,
						once = g.once == true,
					})
				else
					unseen += 1
				end
			end
			table.insert(out, {
				id = id,
				name = m.name,
				desc = self:render(life, m.desc or ""),
				keeper = m.keeper,
				emblem = m.emblem,
				markup = if mult ~= 1 then { mult = mult, why = why } else nil,
				goods = goods,
				unseen = unseen,
			})
		end
	end
	return out
end

-- ── homes ────────────────────────────────────────────────────────────────

function Market.homeDef(self: any, id: string?): any
	local h = self.pack.homes
	return h and id and h[id]
end

-- sells the home the life has (half what it cost); returns what it fetched
function Market.sellHome(self: any, life: any, extra: { any }): number
	local def = life.home and Market.homeDef(self, life.home.id)
	if not def then
		life.home = nil
		return 0
	end
	local got = math.floor((def.price or 0) * 0.5 + 0.5)
	life.money += got
	life.home = nil
	table.insert(extra, { kind = "log", text = "You sold " .. def.name .. " for " .. got .. " " .. self.pack.meta.currency .. ".", deltas = { money = got } })
	return got
end

function Market.moveIn(self: any, life: any, id: string, extra: { any })
	local def = Market.homeDef(self, id)
	if not def then
		return
	end
	if life.home and life.home.id ~= id then
		Market.sellHome(self, life, extra)
	end
	life.home = { id = id, since = life.age }
	life.flags.owns_home = true
	table.insert(extra, { kind = "system", tone = "good", text = "Home now: " .. def.name .. "." })
	self:highlight(life, "Moved into " .. def.name .. ".")
end

-- once a year: upkeep, and what living there does for you
function Market.homeYear(self: any, life: any, report: any)
	local def = life.home and Market.homeDef(self, life.home.id)
	if not def or not life.alive then
		return
	end
	local upkeep = def.upkeep or 0
	-- a household partner pays half
	local partner = self:firstRelation(life, "partner")
	if partner and upkeep > 0 then
		upkeep = math.floor(upkeep / 2 + 0.5)
	end
	if upkeep > 0 and life.money < upkeep then
		-- can't keep it: the bank or the landlord takes it back, and gives back a little
		local back = math.floor((def.price or 0) * 0.3 + 0.5)
		life.money += back
		life.home = nil
		life.flags.owns_home = nil
		self:push(life, report, { kind = "system", tone = "bad", text = "You couldn't keep up with " .. def.name .. ". It was taken back, and you got " .. back .. " " .. self.pack.meta.currency .. " for it.", deltas = { money = back } })
		return
	end
	local deltas: { [string]: number } = {}
	if upkeep > 0 then
		life.money -= upkeep
		deltas.money = -upkeep
	end
	if (def.income or 0) > 0 then
		life.money += def.income
		deltas.money = (deltas.money or 0) + def.income
	end
	if (def.sanity or 0) ~= 0 then
		local cfg = self.pack.stats.sanity
		local before = life.sanity
		life.sanity = math.clamp(life.sanity + def.sanity, cfg.min, cfg.max)
		if life.sanity ~= before then
			deltas.sanity = life.sanity - before
		end
	end
	if next(deltas) then
		self:push(life, report, { kind = "log", text = def.yearLog or ("A year in " .. def.name .. "."), deltas = deltas })
	end
	if (def.renown or 0) > 0 then
		self:addRenown(life, def.renown, report)
	end
end

-- once a year: what sharing a household does for you (a partner at home: Sanity, if you're close)
function Market.householdYear(self: any, life: any, report: any)
	local partner = self:firstRelation(life, "partner")
	if not partner or not life.alive then
		return
	end
	local cfg = self.pack.stats.sanity
	if partner.bond >= 50 then
		local before = life.sanity
		life.sanity = math.clamp(life.sanity + 2, cfg.min, cfg.max)
		if life.sanity ~= before then
			self:push(life, report, { kind = "log", text = "Another year under one roof with " .. partner.first .. ".", deltas = { sanity = life.sanity - before } })
		end
	elseif partner.bond < 25 then
		local before = life.sanity
		life.sanity = math.clamp(life.sanity - 2, cfg.min, cfg.max)
		if life.sanity ~= before then
			self:push(life, report, { kind = "log", text = "You and " .. partner.first .. " barely speak at home anymore.", deltas = { sanity = life.sanity - before } })
		end
	end
end

-- how much rarer bad luck in the streets is, at home (0..0.6)
function Market.homeSafety(self: any, life: any): number
	local def = life.home and Market.homeDef(self, life.home.id)
	return if def then math.clamp(def.safety or 0, 0, 0.6) else 0
end

-- how much harder you are to find, for a grudge (0..0.6)
function Market.homeHideout(self: any, life: any): number
	local def = life.home and Market.homeDef(self, life.home.id)
	return if def then math.clamp(def.hideout or 0, 0, 0.6) else 0
end

function Market.homeView(self: any, life: any): any
	local def = life.home and Market.homeDef(self, life.home.id)
	if not def then
		return nil
	end
	return {
		id = life.home.id,
		name = def.name,
		desc = def.desc,
		since = life.home.since,
		upkeep = def.upkeep or 0,
		income = def.income or 0,
		sanity = def.sanity or 0,
		safety = def.safety or 0,
		hideout = def.hideout or 0,
		sellFor = math.floor((def.price or 0) * 0.5 + 0.5),
	}
end

return Market
