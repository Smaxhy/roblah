--[[
	BODY AND THINGS THAT HAPPEN TO IT (v0.12), kept out of Sim.luau (which is at the type
	checker's limit). Sim delegates: Sim:maxHealthOf(life) -> Body.maxHealthOf(sim, life).
		maxHealthOf, statCap, settleHealth   Health that grows past 100, and overheal
		playerAbilities, foeAbilities        what a weapon, an art or a foe brings to a fight
		abilitiesView                        abilities as the screen shows them
		bloodAfter                           blood paid for an art, and blood drunk back
		rollHousehold                        what the family owns, and what each parent does
		endingOf, endingPhrase               books, erasures and the Night: endings with no body
]]

local Clash = require(script.Parent.Clash)
local Rng = require(script.Parent.Rng)
local Conditions = require(script.Parent.Conditions)

local Body = {}

-- ── STAT TIERS, PERKS, NATURE ───────────────────────────────────────────────
-- A stat's tier is 1 + floor(value / pack.stats.tierEvery (20)), up to pack.stats.tierMax (5).
-- pack.stats.perks = { <stat> = { [tier] = { name, desc, <effect> } } }: every perk at or under
-- your tier counts. Effects the engine reads:
--   actions, social     more to do in a year
--   toughness           a share of every wound taken off
--   sanityGuard         a share of every Sanity loss taken off
--   wage, price         a share more pay, a share off prices
--   training            +n on the first thing an activity teaches you
--   egoMin = true       approaches with a sanityCost cost their minimum
--   stance = { base, coinPower }   when you fight with that stat
-- MAXIMUM HEALTH (pack.vitalMax): everyone starts at `base`; a body the City has hardened
-- holds more. Strength past `strengthFrom`, a Fixer's grade (fixerRating), what you are (a
-- Bloodfiend's blood), what you carry and wear (gear.maxHealth), talents (trait.maxHealth),
-- and what's been done to you (life.maxHealthBonus: an augment, a K Corp course).
function Body.maxHealthOf(self: any, life): number
	local cfg = self.pack.vitalMax
	if not cfg then
		return 100
	end
	local m = cfg.base or 100
	local str = life.stats[self.roles.fight] or 0
	local from = cfg.strengthFrom or 50
	if cfg.perStrength and str > from then
		m += math.floor((str - from) * cfg.perStrength)
	end
	m += (cfg.perGrade or 0) * math.max(0, self:fixerRating(life) - 1)
	m += (cfg.forms and cfg.forms[life.form]) or 0
	for _, g in self:gearIn(life) do
		m += g.def.maxHealth or 0
	end
	for _, id in life.traits or {} do
		local d = self:traitDef(id)
		if d and type(d.maxHealth) == "number" then
			m += d.maxHealth
		end
	end
	m += life.maxHealthBonus or 0
	-- renown: the bigger your name, the more it takes to bring you down
	local ranks = self.pack.renown and self.pack.renown.ranks
	if ranks and (life.renown or 0) > 0 then
		local r = 0
		for i, def in ranks do
			if (life.renown or 0) >= def.at then
				r = i
			end
		end
		if r > 0 and ranks[r].perks then
			m += ranks[r].perks.maxHealth or 0
		end
	end
	return math.max(10, m)
end

-- the most a stat can be raised to: 100, and Health to its maximum (or past it, by `over`)
function Body.statCap(self: any, life, key: string, over: number?): number
	if key == self.vital then
		return self:maxHealthOf(life) + (over or 0)
	end
	return (self.pack.stats.cap or 100) + Body.capBonus(self, life, key)
end

-- (v0.13) how far past 100 a stat may go: renown (pack.renown.ranks[].perks.cap), feats and
-- deeds that break a limit (life.capBonus), what you carry (gear.capBonus) and what you are
-- (forms[].capBonus). Each is { [stat] = n, all = n } or a number (every stat).
local function capPart(t: any, key: string): number
	if type(t) == "number" then
		return t
	elseif type(t) == "table" then
		return (t[key] or 0) + (t.all or 0)
	end
	return 0
end
function Body.capBonus(self: any, life, key: string): number
	local n = capPart(life.capBonus, key)
	local ranks = self.pack.renown and self.pack.renown.ranks
	local r = (ranks and life.renown and self:renownRank(life)) or 0
	if r > 0 and ranks[r].perks then
		n += capPart(ranks[r].perks.cap, key)
	end
	for _, g in self:gearIn(life) do
		n += capPart(g.def.capBonus, key)
	end
	for _, s in self:activeSets(life) do
		n += capPart(s.bonus.capBonus, key)
	end
	local form = life.form and self.pack.forms[life.form]
	if form then
		n += capPart(form.capBonus, key)
	end
	return n
end

-- (v0.17) HOW LONG A BODY LASTS: forms[].lifespan, pushed back by treatments and Workshop
-- bodies (life.lifespanBonus), a body hardened past its limits (pack.longLife.perMaxHealth for
-- every point of maximum Health past 100) and a Color's name (pack.longLife.color)
function Body.lifespan(self: any, life): number
	local pack = self.pack
	local form = pack.forms[life.form or "human"] or {}
	local ll = pack.longLife
	local n = (form.lifespan or 70) + math.min(life.lifespanBonus or 0, (ll and ll.maxBonus) or 999)
	if ll then
		local extra = math.max(0, self:maxHealthOf(life) - 100) * (ll.perMaxHealth or 0)
		n += math.floor(math.min(ll.maxFromHealth or 60, extra))
		if life.flags and life.flags.color_fixer then
			n += ll.color or 0
		end
	end
	return n
end

-- (v0.17) what a year does to a body: heals it young, wears it old (from `wearFrom` years
-- before its lifespan, and harder from `hardFrom` after). An ageless form never wears.
-- Returns the change in Health for the year.
function Body.wearYear(self: any, life): number
	local vital = self.vital
	local form = self.pack.forms[life.form or "human"]
	local hp = life.stats[vital] or 0
	if form and form.ageless then
		return if hp < 70 then Rng.int(life, 1, 3) else 0
	end
	local ll = self.pack.longLife
	if not ll then
		-- (a pack without long lives keeps the ages it always had: wear from 50, hard from 65)
		if life.age >= 65 then
			return -Rng.int(life, 2, 4)
		elseif life.age >= 50 then
			return -Rng.int(life, 1, 2)
		elseif hp < 55 then
			return Rng.int(life, 1, 3)
		end
		return 0
	end
	local span = Body.lifespan(self, life)
	if life.age >= span + (ll.hardFrom or 2) then
		return -Rng.int(life, 2, 4)
	elseif life.age >= span - (ll.wearFrom or 13) then
		return -Rng.int(life, 1, 2)
	elseif hp < 55 then
		return Rng.int(life, 1, 3)
	end
	return 0
end

-- (v0.17) OLD BLOOD: a Bloodfiend's years as a Bloodfiend, and the stages they reach
function Body.bloodYears(self: any, life): number
	if life.form ~= "bloodfiend" then
		return 0
	end
	return math.max(0, life.age - (life.formAt or life.age))
end
function Body.elderBlood(self: any, life, extra)
	local stages = self.pack.elderBlood
	if not stages or life.form ~= "bloodfiend" then
		return
	end
	local years = Body.bloodYears(self, life)
	life.bloodStage = life.bloodStage or 0
	for i, st in stages do
		if i > life.bloodStage and years >= st.years then
			life.bloodStage = i
			life.capBonus = life.capBonus or {}
			for k, v in st.limitBreak or {} do
				life.capBonus[k] = (life.capBonus[k] or 0) + v
			end
			life.maxHealthBonus = (life.maxHealthBonus or 0) + (st.maxHealth or 0)
			for k, v in st.stats or {} do
				if life.stats[k] ~= nil then
					life.stats[k] = math.min(life.stats[k] + v, self:statCap(life, k))
				end
			end
			table.insert(extra, { kind = "system", tone = "strange", text = st.name .. ". " .. (st.log or "") })
			self:highlight(life, "Became " .. st.name .. " at " .. life.age .. ".")
			self:news(life, life.first .. "'s blood is " .. st.name .. " now.")
		end
	end
end
function Body.bloodStageName(self: any, life): string?
	local stages = self.pack.elderBlood
	local i = life.bloodStage or 0
	return if stages and i > 0 and stages[i] then stages[i].name else nil
end

-- once a year: a maximum that rose brings Health up with it, and Health over the maximum
-- (blood drunk, an ampoule) settles back halfway each year
function Body.settleHealth(self: any, life)
	local vital = self.vital
	local max = self:maxHealthOf(life)
	local seen = life.maxHealthSeen or max
	if max > seen and life.alive then
		life.stats[vital] = math.min(max, life.stats[vital] + (max - seen))
	end
	life.maxHealthSeen = max
	local hp = life.stats[vital]
	if hp > max then
		life.stats[vital] = max + math.floor((hp - max) / 2)
	end
end

-- the abilities a player brings to a fight: the weapon in hand (gear.ability) and the art
-- (approach.abilities). Sets player.abilities and player.quick; returns how much they pierce.
function Body.playerAbilities(self: any, life: any, approach: any, player: any): number
	local list = {}
	for _, g in self:gearIn(life) do
		local a = g.def.ability
		if type(a) == "table" and (g.def.style == nil or g.def.style == life.style) then
			table.insert(list, { id = a.id, potency = a.potency or 1, from = g.def.name })
		end
	end
	for _, a in (approach and approach.abilities) or {} do
		table.insert(list, { id = a.id, potency = a.potency or 1, from = approach.name })
	end
	local pierce = 0
	for _, a in list do
		if a.id == "quick" then
			player.quick = true
		elseif a.id == "pierce" then
			pierce += a.potency
		end
	end
	if #list > 0 then
		player.abilities = list
	end
	return pierce
end

-- what a foe brings: clash.ability, else the foe's own (Foes.luau)
function Body.foeAbilities(self: any, spec: any, foe: any)
	local fdef = self:foeDef(spec)
	local raw = spec.ability or (fdef and fdef.ability)
	if type(raw) ~= "table" then
		return
	end
	local list = if raw.id then { raw } else raw
	foe.abilities = {}
	for _, a in list do
		table.insert(foe.abilities, { id = a.id, potency = a.potency or 1 })
		if a.id == "quick" then
			foe.quick = true
		end
	end
end

-- abilities as the screen shows them: { { id, name, desc, potency, from } }
function Body.abilitiesView(self: any, list: any): any
	if type(list) ~= "table" or #list == 0 then
		return nil
	end
	local defs = self.pack.abilities or Clash.ABILITIES
	local out = {}
	for _, a in list do
		local d = defs[a.id] or Clash.ABILITIES[a.id] or {}
		table.insert(out, { id = a.id, name = d.name or a.id, desc = d.desc or "", potency = a.potency or 1, from = a.from })
	end
	return out
end

-- after a fight: an art paid in blood (approach.healthCost) can leave you at 1, never at 0;
-- and drink gives back Health for every clash you won, past your maximum if it must
function Body.bloodAfter(self: any, life: any, approach: any, res: any, report: any)
	local vital = self.vital
	if approach and approach.healthCost and life.alive then
		local before = life.stats[vital]
		life.stats[vital] = math.max(1, before - approach.healthCost)
		local paid = before - life.stats[vital]
		if paid > 0 then
			self:push(life, report, { kind = "log", text = approach.costLog or "The blood you shaped was your own.", deltas = { [vital] = -paid } })
		end
	end
	local drink = Clash.abilityOf(res.player, "drink")
	if drink > 0 and (res.pWon or 0) > 0 and life.alive then
		local max = self:maxHealthOf(life)
		local before = life.stats[vital]
		local cap = math.max(before, max + math.floor(max / 2))
		life.stats[vital] = math.min(cap, before + drink * res.pWon)
		local got = life.stats[vital] - before
		if got > 0 then
			self:push(life, report, { kind = "log", text = "You drank what you'd spilled.", deltas = { [vital] = got } })
		end
	end
end

-- THE HOUSEHOLD (origin.household): what the family owns, what it lives on, and what each
-- parent does, said plainly on the Household card and the parents' rows. A family business
-- has an id (`business`) that stories and the family's own events can ask after.
--   household = { owns = { "a line", ... }, business = "workshop", jobs = { mother = { { short, text } }, father = ... } }
function Body.rollHousehold(self: any, life, origin)
	local h = origin and origin.household
	if type(h) ~= "table" then
		return
	end
	local names = self.pack.officeNames or { "Lantern" }
	local office = names[Rng.int(life, 1, #names)]
	life.household = { business = h.business, office = office }
	if h.business then
		life.flags["family_business_" .. h.business] = true
	end
	local function pick(list)
		if type(list) ~= "table" or #list == 0 then
			return nil
		end
		return list[Rng.int(life, 1, #list)]
	end
	local function fill(text: string): string
		return (string.gsub(text, "{office}", (string.gsub(office, "%%", "%%%%"))))
	end
	local owns = pick(h.owns)
	if owns then
		life.household.owns = fill(owns)
	end
	for _, rel in life.relations do
		local job = h.jobs and pick(h.jobs[rel.kind])
		if job then
			rel.jobShort = fill(job[1])
			rel.job = fill(job[2])
		end
	end
end

-- How a life ended when it wasn't simply a body giving out (pack.endings): a book in the
-- Library, erased by the Head, taken by the Night. Each kind is worded its own way on the
-- end screen, in the news, and to the friends who hear of it.
function Body.endingOf(self: any, life): any
	local cause = string.lower(tostring(life.cause or ""))
	for _, e in self.pack.endings or {} do
		for _, m in e.match or {} do
			if string.find(cause, m, 1, true) then
				return e
			end
		end
	end
	return nil
end

-- "died", "became a book in the Library", "was erased by the Head"...
function Body.endingPhrase(self: any, life): string
	local e = self:endingOf(life)
	return (e and e.phrase) or "died"
end

-- HARD YEARS (pack.crises): a few years of every life when the City turns on it. At birth a
-- life is given its crisis ages (pack.crisisAges: one age drawn from each band); when one
-- comes round, a crisis whose `when` fits is declared for the year: every fight is harder
-- (foeBase, foeCoins), bad luck is likelier (hazard), and its trial comes first (trial event).
function Body.rollCrisis(self: any, life: any, report: any)
	local pack = self.pack
	if not pack.crises then
		return
	end
	life.crisis = nil
	if not life.crisisAges then
		life.crisisAges = {}
		for _, band in pack.crisisAges or {} do
			local lo, hi = band[1], band[2]
			if life.age <= hi then
				table.insert(life.crisisAges, Rng.int(life, math.max(lo, life.age + 1), hi))
			end
		end
	end
	if not table.find(life.crisisAges, life.age) then
		return
	end
	local list, weights = {}, {}
	for _, c in pack.crises do
		if Conditions.check(c.when, life, pack, { noChance = true }) and (c.trial == nil or self.eventsById[c.trial]) then
			table.insert(list, c)
			table.insert(weights, c.weight or 10)
		end
	end
	local idx = Rng.weighted(life, weights)
	local c = if idx then list[idx] else nil
	if not c then
		return
	end
	life.crisis = c.id
	self:push(life, report, { kind = "crisis", title = c.name, text = self:render(life, c.text or ""), tone = "bad", color = c.color })
	self:highlight(life, "A hard year: " .. c.name)
	if c.trial then
		table.insert(life.queue, 1, c.trial)
	end
end

function Body.crisisDef(self: any, life: any): any
	local id = life.crisis
	if not id then
		return nil
	end
	for _, c in self.pack.crises or {} do
		if c.id == id then
			return c
		end
	end
	return nil
end

-- the hard year as the screen shows it
function Body.crisisView(self: any, life: any): any
	local c = Body.crisisDef(self, life)
	return if c then { name = c.name, text = self:render(life, c.short or c.text or ""), color = c.color } else nil
end

return Body
