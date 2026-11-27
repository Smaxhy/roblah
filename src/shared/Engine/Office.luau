--[[
	YOUR OFFICE, RUN BY YOU (v0.18): what the Office of Renown.foundOffice grows into.

	life.office = {
		name, size, founded,             (v0.12, Renown.luau: size is its rank, grown by deeds)
		named      true once the player chose its name (the server filters what they typed)
		motto      a line under the sign (filtered too), or nil
		color      the sign's colour (pack.offices.colors)
		building   which premises (pack.offices.buildings, from a rented room to a tower)
		rooms      { [id] = true } (pack.offices.rooms: training, infirmary, armory, lab...)
		crew       { { rel = relation id, grade = 9..1, since = age } }
	}

	Hiring takes a grown-up who'd follow you (a friend, family, someone you've met and trust) if
	the building has a desk free. Each one costs a wage a year and brings in contracts by their
	grade (Hana's grades: 9 is new, 1 is the best there is), and grades rise with the years,
	faster with a training room. The crew and the armory stand behind you in a fight. Rooms do
	their work once a year; the lab runs an experiment when you ask it to.
]]

local Rng = require(script.Parent.Rng)
local Util = require(script.Parent.Util)

local Office = {}

local function cfg(sim: any): any
	return sim.pack.offices
end

local function ensure(o: any): any
	o.building = o.building or 1
	o.rooms = o.rooms or {}
	o.crew = o.crew or {}
	o.color = o.color or "brass"
	return o
end

function Office.enabled(sim: any): boolean
	local c = cfg(sim)
	return c ~= nil and c.buildings ~= nil and #c.buildings > 0
end

function Office.building(sim: any, life: any): any
	local c = cfg(sim)
	local o = life.office
	if not c or not c.buildings or not o then
		return nil
	end
	ensure(o)
	return c.buildings[math.clamp(o.building, 1, #c.buildings)]
end

function Office.capacity(sim: any, life: any): number
	local b = Office.building(sim, life)
	return (b and b.crew) or 0
end

local function relOf(life: any, relId: number): any
	for _, rel in life.relations or {} do
		if rel.id == relId then
			return rel
		end
	end
	return nil
end

local function crewEntry(o: any, relId: number): (any, number?)
	for i, m in o.crew or {} do
		if m.rel == relId then
			return m, i
		end
	end
	return nil, nil
end

local function gradeOf(c: any, grade: number): any
	return (c.grades and c.grades[math.clamp(grade, 1, 9)]) or { wage = 100, earn = 150 }
end

-- who'd come and work for you, and why someone wouldn't
function Office.eligible(sim: any, life: any, rel: any): (boolean, string?)
	local c = cfg(sim)
	if not rel or not rel.alive then
		return false, "They aren't around any more."
	end
	if crewEntry(life.office, rel.id) then
		return false, "Already on your roster."
	end
	if (rel.age or 0) < (c.hireAge or 18) then
		return false, "Too young to carry a licence."
	end
	local kindDef = sim.pack.relationKinds and sim.pack.relationKinds[rel.kind]
	if rel.kind == "rival" or (kindDef and kindDef.rival) then
		return false, "They'd sooner see you fail."
	end
	local need = if rel.kind == "acquaintance" then (c.hireBondMet or 55) else (c.hireBond or 40)
	if (rel.bond or 0) < need then
		return false, string.format("They don't trust you enough yet (bond %d of %d).", rel.bond or 0, need)
	end
	return true, nil
end

local function wageOf(sim: any, m: any): number
	return gradeOf(cfg(sim), m.grade).wage
end

local function fail(why: string): (nil, string)
	return nil, why
end

function Office.hire(sim: any, life: any, relId: number): (any, string?)
	local o = life.office
	if not o then
		return fail("You don't have an Office.")
	end
	ensure(o)
	if #o.crew >= Office.capacity(sim, life) then
		return fail("There's no desk free. A bigger building has room for more.")
	end
	local rel = relOf(life, relId)
	local ok, why = Office.eligible(sim, life, rel)
	if not ok then
		return fail(why or "They won't come.")
	end
	local c = cfg(sim)
	-- the bond they have with you is a head start: close friends come in a grade up
	local grade = if (rel.bond or 0) >= 80 then 8 else 9
	local signing = gradeOf(c, grade).wage
	if life.money < signing then
		return fail(string.format("A first year's wage up front: %d Ahn.", signing))
	end
	life.money -= signing
	table.insert(o.crew, { rel = rel.id, grade = grade, since = life.age })
	rel.bond = Util.clamp((rel.bond or 50) + 5, 0, 100)
	local report = sim.newReport()
	sim:push(life, report, { kind = "log", text = string.format("%s signed on with the %s Office as a Grade %d Fixer.", rel.first, o.name, grade), deltas = { money = -signing } })
	sim:highlight(life, rel.first .. " joined the " .. o.name .. " Office.")
	return report
end

function Office.fire(sim: any, life: any, relId: number): (any, string?)
	local o = life.office
	local m, i = if o then crewEntry(o, relId) else nil, nil
	if not o or not m or not i then
		return fail("They aren't on your roster.")
	end
	table.remove(o.crew, i)
	local rel = relOf(life, relId)
	local report = sim.newReport()
	if rel then
		rel.bond = Util.clamp((rel.bond or 50) - 10, 0, 100)
		sim:push(life, report, { kind = "system", text = rel.first .. " cleared their desk at the " .. o.name .. " Office. It was quiet after." })
	end
	return report
end

function Office.buyBuilding(sim: any, life: any): (any, string?)
	local o = life.office
	local c = cfg(sim)
	if not o or not c or not c.buildings then
		return fail("You don't have an Office.")
	end
	ensure(o)
	local nxt = c.buildings[o.building + 1]
	if not nxt then
		return fail("There's nowhere bigger to move to.")
	end
	if (o.size or 1) < (nxt.minSize or 1) then
		return fail(string.format("Grow the Office first: %s needs %s.", nxt.name, (c.sizes and c.sizes[nxt.minSize] and c.sizes[nxt.minSize].name) or ("size " .. tostring(nxt.minSize))))
	end
	if nxt.minRenown and sim:renownRank(life) < nxt.minRenown then
		return fail("The landlords there want a name first (renown grade " .. nxt.minRenown .. ").")
	end
	if life.money < (nxt.price or 0) then
		return fail(string.format("%s costs %d Ahn.", nxt.name, nxt.price or 0))
	end
	life.money -= nxt.price or 0
	o.building += 1
	local report = sim.newReport()
	sim:push(life, report, { kind = "log", tone = "good", text = string.format("The %s Office moved into %s. %s", o.name, nxt.name, nxt.desc or ""), deltas = { money = -(nxt.price or 0) } })
	sim:highlight(life, "Moved the " .. o.name .. " Office into " .. nxt.name .. ".")
	sim:news(life, "The " .. o.name .. " Office moved into " .. nxt.name .. ".")
	return report
end

function Office.roomDef(sim: any, id: string): any
	for _, r in (cfg(sim) and cfg(sim).rooms) or {} do
		if r.id == id then
			return r
		end
	end
	return nil
end

function Office.buyRoom(sim: any, life: any, id: string): (any, string?)
	local o = life.office
	if not o then
		return fail("You don't have an Office.")
	end
	ensure(o)
	local def = Office.roomDef(sim, id)
	if not def then
		return fail("There's no such room.")
	end
	if o.rooms[id] then
		return fail("You already have one.")
	end
	if o.building < (def.building or 1) then
		local b = cfg(sim).buildings[def.building or 1]
		return fail("There's no space for it yet: it needs " .. ((b and b.name) or "a bigger building") .. ".")
	end
	if life.money < (def.price or 0) then
		return fail(string.format("%s costs %d Ahn.", def.name, def.price or 0))
	end
	life.money -= def.price or 0
	o.rooms[id] = true
	local report = sim.newReport()
	sim:push(life, report, { kind = "log", tone = "good", text = string.format("The %s Office has a %s now. %s", o.name, string.lower(def.name), def.desc or ""), deltas = { money = -(def.price or 0) } })
	return report
end

-- the fighting stat an experiment or a training room works on: the one you lean on most
local function fightStat(sim: any, life: any): string
	local best, bestV = sim.roles.fight or "strength", -1
	for _, k in { sim.roles.fight, sim.roles.speed, sim.roles.will } do
		if k and life.stats[k] ~= nil and life.stats[k] > bestV then
			best, bestV = k, life.stats[k]
		end
	end
	return best
end

local function raise(sim: any, life: any, key: string, n: number): number
	local before = life.stats[key] or 0
	life.stats[key] = math.min(before + n, math.max(before, sim:statCap(life, key)))
	return life.stats[key] - before
end

-- the lab: an action and some money for a chance at something nobody else has
function Office.experiment(sim: any, life: any): (any, string?)
	local o = life.office
	local c = cfg(sim)
	if not o or not c then
		return fail("You don't have an Office.")
	end
	ensure(o)
	if not o.rooms.lab then
		return fail("You need a lab for that.")
	end
	local e = c.experiment or {}
	local cost = e.cost or 2000
	if (life.actionsLeft or 0) <= 0 then
		return fail("No actions left this year.")
	end
	if life.money < cost then
		return fail(string.format("Materials cost %d Ahn.", cost))
	end
	life.actionsLeft -= 1
	life.money -= cost
	local report = sim.newReport()
	local total = 0
	for _, out in e.outcomes or {} do
		total += out.weight or 1
	end
	local roll = Rng.int(life, 1, math.max(1, total))
	local pick = nil
	for _, out in e.outcomes or {} do
		roll -= out.weight or 1
		if roll <= 0 then
			pick = out
			break
		end
	end
	pick = pick or { text = "The readings made no sense." }
	local deltas: { [string]: number } = { money = -cost }
	local key = fightStat(sim, life)
	local statName = (sim.pack.stats[key] and sim.pack.stats[key].name) or key
	if pick.limitBreak then
		life.capBonus = life.capBonus or {}
		life.capBonus[key] = (life.capBonus[key] or 0) + pick.limitBreak
	end
	if pick.stat then
		local n = if type(pick.stat) == "table" then Rng.int(life, pick.stat[1], pick.stat[2]) else pick.stat
		local got = raise(sim, life, key, n)
		if got ~= 0 then
			deltas[key] = got
		end
	end
	if pick.money then
		local n = if type(pick.money) == "table" then Rng.int(life, pick.money[1], pick.money[2]) else pick.money
		life.money += n
		deltas.money += n
	end
	if pick.health then
		local n = if type(pick.health) == "table" then Rng.int(life, pick.health[1], pick.health[2]) else pick.health
		local vital = sim.vital
		local before = life.stats[vital]
		life.stats[vital] = math.max(1, before + n)
		deltas[vital] = life.stats[vital] - before
	end
	if pick.sanity then
		sim:changeSanity(life, pick.sanity, deltas)
	end
	local text = string.gsub(pick.text or "", "{stat}", statName)
	if pick.limitBreak then
		text ..= string.format(" (%s can go %d further.)", statName, pick.limitBreak)
	end
	sim:push(life, report, { kind = "log", tone = pick.tone, text = text, deltas = deltas })
	if pick.id == "breakthrough" then
		sim:highlight(life, "A breakthrough in the " .. o.name .. " Office's lab.")
	end
	return report
end

-- what the player typed for a name, a motto and a colour (the server has filtered the words)
function Office.rename(sim: any, life: any, name: string?, motto: string?, color: string?): (any, string?)
	local o = life.office
	if not o then
		return fail("You don't have an Office.")
	end
	ensure(o)
	-- everything is checked before anything changes
	local n = nil
	if name ~= nil then
		n = string.gsub(string.gsub(name, "^%s+", ""), "%s+$", "")
		n = string.gsub(n :: string, "%s+[Oo]ffice$", "") -- (it's always "the ... Office")
		if #(n :: string) < 2 or #(n :: string) > 24 then
			return fail("A name between 2 and 24 letters.")
		end
	end
	if color ~= nil then
		local found = false
		for _, col in cfg(sim).colors or {} do
			if col.id == color then
				found = true
			end
		end
		if not found then
			return fail("That colour isn't one the sign-painters have.")
		end
	end
	if n ~= nil then
		o.name = n
		o.named = true
	end
	if motto ~= nil then
		local m = string.gsub(string.gsub(motto, "^%s+", ""), "%s+$", "")
		o.motto = if #m > 0 then string.sub(m, 1, 60) else nil
	end
	if color ~= nil then
		o.color = color
	end
	local report = sim.newReport()
	sim:push(life, report, { kind = "system", tone = "good", text = "The sign over the door reads: the " .. o.name .. " Office" .. (if o.motto then ". \"" .. o.motto .. "\"" else ".") })
	return report
end

-- once a year (from Renown.officeYear): the crew is paid and pays its way, grades rise, the
-- rooms do their work, and a big building adds to your name
function Office.year(sim: any, life: any, report: any?)
	local o = life.office
	local c = cfg(sim)
	if not o or not c or not c.buildings then
		return
	end
	ensure(o)
	local b = Office.building(sim, life)
	-- people who aren't here any more
	for i = #o.crew, 1, -1 do
		local m = o.crew[i]
		local rel = relOf(life, m.rel)
		if not rel or not rel.alive then
			table.remove(o.crew, i)
			if rel and report then
				sim:push(life, report, { kind = "system", text = rel.first .. "'s desk at the " .. o.name .. " Office stays empty this year." })
			end
		end
	end
	-- wages first; if the money isn't there, the one least bound to you walks
	local wages = 0
	for _, m in o.crew do
		wages += wageOf(sim, m)
	end
	while #o.crew > 0 and life.money < wages do
		local worst, wi = nil, nil
		for i, m in o.crew do
			local rel = relOf(life, m.rel)
			if not worst or (rel and rel.bond or 0) < (worst.bond or 0) then
				worst, wi = rel, i
			end
		end
		if not wi then
			break
		end
		local gone = table.remove(o.crew, wi)
		wages -= wageOf(sim, gone)
		if worst and report then
			worst.bond = Util.clamp((worst.bond or 50) - 15, 0, 100)
			sim:push(life, report, { kind = "system", tone = "bad", text = worst.first .. " couldn't wait any longer for their pay and left the " .. o.name .. " Office." })
		end
	end
	local earned = 0
	for _, m in o.crew do
		earned += gradeOf(c, m.grade).earn
	end
	earned = math.floor(earned * ((b and b.income) or 1) * (if o.rooms.archive then 1.1 else 1) + 0.5)
	if #o.crew > 0 then
		life.money += earned - wages
		if report then
			sim:push(life, report, { kind = "log", text = string.format("The %s Office's %d Fixers brought in %d Ahn of contracts; their wages came to %d.", o.name, #o.crew, earned, wages), deltas = { money = earned - wages } })
		end
	end
	-- grades rise with the years (a training room makes it quicker; the last grades are slow)
	for _, m in o.crew do
		if m.grade > 1 then
			local p = (if o.rooms.training then 0.42 else 0.26) * (if m.grade <= 3 then 0.4 else 1)
			if Rng.chance(life, p) then
				m.grade -= 1
				local rel = relOf(life, m.rel)
				if rel and report then
					sim:push(life, report, { kind = "system", tone = "good", text = string.format("%s passed Hana's review: a Grade %d Fixer now.", rel.first, m.grade) })
				end
			end
		end
	end
	-- the rooms
	local deltas: { [string]: number } = {}
	if o.rooms.training then
		local key = fightStat(sim, life)
		local got = raise(sim, life, key, 2)
		if got ~= 0 then
			deltas[key] = got
		end
	end
	if o.rooms.infirmary then
		local vital = sim.vital
		local before = life.stats[vital]
		life.stats[vital] = math.min(math.max(before, sim:maxHealthOf(life)), before + 15)
		if life.stats[vital] ~= before then
			deltas[vital] = life.stats[vital] - before
		end
	end
	if o.rooms.archive and sim.roles.work then
		local got = raise(sim, life, sim.roles.work, 1)
		if got ~= 0 then
			deltas[sim.roles.work] = got
		end
	end
	if o.rooms.vault and life.money > 0 then
		local interest = math.min(3000, math.floor(life.money * 0.04))
		if interest > 0 then
			life.money += interest
			deltas.money = interest
		end
	end
	if next(deltas) and report then
		sim:push(life, report, { kind = "log", text = "A year in the " .. o.name .. " Office: the training room, the infirmary, the archive and the vault did their work.", deltas = deltas })
	end
end

-- the Office at your back in a fight: its Fixers, and the armory's kit
function Office.fightBonus(sim: any, life: any): (number, number)
	local o = life.office
	if not o or not cfg(sim) or not cfg(sim).buildings then
		return 0, 0
	end
	ensure(o)
	local n = #o.crew
	local base = if n >= 20 then 3 elseif n >= 8 then 2 elseif n >= 3 then 1 else 0
	if o.rooms.armory then
		base += 1
	end
	return base, 0
end

-- what the Office sheet shows (Engine/View.luau: life.office)
function Office.view(sim: any, life: any): any
	local o = life.office
	local c = cfg(sim)
	if not o or not c or not c.buildings then
		return nil
	end
	ensure(o)
	local b = Office.building(sim, life)
	local nxt = c.buildings[o.building + 1]
	local colorRgb = nil
	for _, col in c.colors or {} do
		if col.id == o.color then
			colorRgb = col.color
		end
	end
	local crew = {}
	local wages, earns = 0, 0
	for _, m in o.crew do
		local rel = relOf(life, m.rel)
		local g = gradeOf(c, m.grade)
		wages += g.wage
		earns += g.earn
		table.insert(crew, { rel = m.rel, name = if rel then (rel.first .. " " .. (rel.last or "")) else "?", kind = rel and rel.kind, grade = m.grade, since = m.since, wage = g.wage, earn = g.earn, look = rel and rel.look, age = rel and rel.age })
	end
	local hire = {}
	if #o.crew < ((b and b.crew) or 0) then
		for _, rel in life.relations or {} do
			if rel.alive and not crewEntry(o, rel.id) and (rel.age or 0) >= (c.hireAge or 18) then
				local ok, why = Office.eligible(sim, life, rel)
				table.insert(hire, { rel = rel.id, name = rel.first .. " " .. (rel.last or ""), kind = rel.kind, bond = rel.bond, age = rel.age, ok = ok, why = why, look = rel.look, linked = rel.userId ~= nil or nil })
			end
		end
		table.sort(hire, function(x, y)
			if x.ok ~= y.ok then
				return x.ok == true
			end
			return (x.bond or 0) > (y.bond or 0)
		end)
	end
	local rooms = {}
	for _, r in c.rooms or {} do
		table.insert(rooms, { id = r.id, name = r.name, desc = r.desc, price = r.price, owned = o.rooms[r.id] == true, open = o.building >= (r.building or 1), needs = (c.buildings[r.building or 1] or {}).name })
	end
	local base = Office.fightBonus(sim, life)
	return {
		named = o.named == true,
		motto = o.motto,
		color = o.color,
		colorRgb = colorRgb,
		colors = c.colors,
		building = { index = o.building, of = #c.buildings, name = b and b.name, desc = b and b.desc, crew = b and b.crew },
		nextBuilding = nxt and { name = nxt.name, desc = nxt.desc, price = nxt.price, crew = nxt.crew, minSize = nxt.minSize, minRenown = nxt.minRenown },
		crew = crew,
		hire = hire,
		rooms = rooms,
		wages = wages,
		earns = math.floor(earns * ((b and b.income) or 1) * (if o.rooms.archive then 1.1 else 1) + 0.5),
		fightBase = base,
		experimentCost = (c.experiment and c.experiment.cost) or 2000,
		lab = o.rooms.lab == true,
	}
end

return Office
