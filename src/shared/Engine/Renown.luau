--[[
	RENOWN, YOUR OWN OFFICE, AND THE CITY'S HOLD (v0.12): what makes a grown life matter.

	RENOWN (pack.renown): points a life earns by doing things people talk about: beating
	strong foes (Renown.fromFight), hard jobs, hard years, deeds (result.renown). Its ranks
	follow Hana's grades for a threat (Urban Myth, Urban Legend ... Impurity), each with perks
	(maxHealth, pay) and, high enough, news on the whole server (rank.announce).

	AN OFFICE (pack.offices): life.office = { name, size, founded }. Founded by a deed (or
	inherited from a Fixer family), grown by deeds; every year it pays by its size and adds a
	little renown. Its size names are its ranks ("a one-person Office" ... "a great Office").

	THE CITY'S HOLD (per server): what players have done to each District, shared by everyone
	there (set by the server: sim:setHolds). A deed's result.impact goes out in report.impact;
	the server applies it to the shared table and tells everyone. Safety makes bad luck rarer
	in that District, prosperity makes its pay better, and a holder's name is on its streets.
]]

local Renown = {}

-- ── renown ───────────────────────────────────────────────────────────────

function Renown.rankOf(sim: any, points: number): number
	local ranks = sim.pack.renown and sim.pack.renown.ranks
	if not ranks then
		return 0
	end
	local r = 0
	for i, def in ranks do
		if points >= def.at then
			r = i
		end
	end
	return r
end

function Renown.add(sim: any, life: any, n: number, report: any?)
	if not sim.pack.renown or n == 0 or not life.alive then
		return
	end
	local before = life.renown or 0
	life.renown = math.max(0, before + n)
	local oldRank = Renown.rankOf(sim, before)
	local newRank = Renown.rankOf(sim, life.renown)
	if newRank > oldRank then
		local def = sim.pack.renown.ranks[newRank]
		life.peakRenown = math.max(life.peakRenown or 0, newRank)
		if def.flag then
			life.flags[def.flag] = true
		end
		sim:highlight(life, "Renown: " .. def.name)
		if report then
			sim:push(life, report, { kind = "renown", title = def.name, text = sim:render(life, def.line or def.desc or ""), rank = newRank, color = def.color })
			if def.announce then
				report.announce = report.announce or {}
				table.insert(report.announce, sim:render(life, def.announce))
			end
		end
	end
end

-- a fight won is renown: the stronger the foe, the more (adults only)
function Renown.fromFight(sim: any, life: any, res: any, report: any?)
	local cfg = sim.pack.renown
	if not cfg or not res or not res.won or not res.foe then
		return
	end
	if life.age < (cfg.minAge or 16) then
		return
	end
	local f = res.foe
	local n = (f.coins or 1) * (cfg.perCoin or 3) + (f.base or 0) - (cfg.floor or 8)
	if n > 0 then
		Renown.add(sim, life, n, report)
	end
end

-- what a renown rank does for you, summed up to the rank you hold: { maxHealth, pay }
function Renown.perks(sim: any, life: any): any
	local out = { maxHealth = 0, pay = 0 }
	local ranks = sim.pack.renown and sim.pack.renown.ranks
	local r = Renown.rankOf(sim, life.renown or 0)
	if ranks and r > 0 then
		local p = ranks[r].perks or {}
		out.maxHealth = p.maxHealth or 0
		out.pay = p.pay or 0
	end
	return out
end

function Renown.view(sim: any, life: any): any
	local cfg = sim.pack.renown
	if not cfg then
		return nil
	end
	local points = life.renown or 0
	local r = Renown.rankOf(sim, points)
	local def = cfg.ranks[r]
	local nxt = cfg.ranks[r + 1]
	return {
		points = points,
		rank = r,
		name = if def then def.name else (cfg.none or "Nobody yet"),
		desc = if def then def.desc else (cfg.noneDesc or ""),
		color = def and def.color,
		perks = Renown.perks(sim, life),
		next = if nxt then { name = nxt.name, at = nxt.at, from = if def then def.at else 0 } else nil,
		of = #cfg.ranks,
	}
end

-- ── an Office of your own ────────────────────────────────────────────────

function Renown.officeDef(sim: any, size: number): any
	local o = sim.pack.offices
	return o and o.sizes and o.sizes[math.clamp(size, 1, #o.sizes)]
end

function Renown.foundOffice(sim: any, life: any, report: any?, name: string?)
	if life.office then
		return
	end
	local names = sim.pack.officeNames or { "Lantern" }
	local pick = name or (life.household and life.household.office) or names[(life.age * 7 + #life.first) % #names + 1]
	-- (v0.18) a name to be chosen by you (named = false until you do), a room, nobody hired yet
	life.office = { name = pick, size = 1, founded = life.age, building = 1, rooms = {}, crew = {}, color = "brass", named = false }
	life.flags.owns_office = true
	if report then
		sim:push(life, report, { kind = "system", tone = "good", text = "The " .. pick .. " Office is yours: one licence on the wall, one desk, one Fixer." })
	end
	sim:highlight(life, "Opened the " .. pick .. " Office.")
end

function Renown.growOffice(sim: any, life: any, n: number, report: any?)
	local o = life.office
	local sizes = sim.pack.offices and sim.pack.offices.sizes
	if not o or not sizes then
		return
	end
	local before = o.size
	o.size = math.clamp(o.size + n, 1, #sizes)
	if o.size > before and report then
		local def = sizes[o.size]
		sim:push(life, report, { kind = "system", tone = "good", text = "The " .. o.name .. " Office is " .. def.name .. " now." })
		sim:highlight(life, "The " .. o.name .. " Office became " .. def.name .. ".")
	end
end

-- once a year: the Office pays, and its name grows
function Renown.officeYear(sim: any, life: any, report: any?)
	local o = life.office
	local def = o and Renown.officeDef(sim, o.size)
	if not def then
		return
	end
	if (def.income or 0) > 0 then
		life.money += def.income
		if report then
			sim:push(life, report, { kind = "log", text = "The " .. o.name .. " Office's contracts paid out for the year.", deltas = { money = def.income } })
		end
	end
	if (def.renown or 0) > 0 then
		Renown.add(sim, life, def.renown, report)
	end
	-- (v0.18) the crew, the building and the rooms
	local Office = require(script.Parent.Office) :: any
	Office.year(sim, life, report)
end

function Renown.officeView(sim: any, life: any): any
	local o = life.office
	local sizes = sim.pack.offices and sim.pack.offices.sizes
	if not o or not sizes then
		return nil
	end
	local def = sizes[o.size]
	local nxt = sizes[o.size + 1]
	local out = { name = o.name, size = o.size, of = #sizes, rank = def.name, desc = def.desc, income = def.income, next = nxt and nxt.name }
	-- (v0.18) and everything you run in it
	local Office = require(script.Parent.Office) :: any
	local more = Office.view(sim, life)
	if more then
		for k, v in more do
			out[k] = v
		end
	end
	return out
end

-- ── the City's hold ──────────────────────────────────────────────────────

-- this server's record of a District (nil: nobody has changed it)
function Renown.holdOf(sim: any, district: string?): any
	return sim.holds and district and sim.holds[district] or nil
end

-- a result's `impact` (a deed that changes a District): out to the server in report.impact
function Renown.impact(sim: any, life: any, impact: any, report: any?)
	if type(impact) ~= "table" or not report then
		return
	end
	report.impact = report.impact or {}
	local fresh = {}
	for _, i in (if impact.kind then { impact } else impact) do
		local entry = {
			kind = i.kind,
			amount = i.amount or 1,
			district = life.district,
			name = life.first .. " " .. life.last,
			lifeId = life.id,
			text = if i.text then sim:render(life, i.text) else nil,
		}
		table.insert(report.impact, entry)
		table.insert(fresh, entry)
	end
	-- and the life itself sees it at once (the server's copy follows)
	Renown.applyImpact(sim, fresh)
end

-- the shared table, changed: by the server for everyone, by the engine for the life at once
function Renown.applyImpact(sim: any, list: any)
	sim.holds = sim.holds or {}
	for _, i in list do
		local h = sim.holds[i.district] or { safety = 0, prosperity = 0 }
		sim.holds[i.district] = h
		if i.kind == "safety" then
			h.safety = math.clamp((h.safety or 0) + i.amount, -5, 5)
		elseif i.kind == "prosperity" then
			h.prosperity = math.clamp((h.prosperity or 0) + i.amount, -5, 5)
		elseif i.kind == "hold" then
			h.holder = i.name
			h.holderLife = i.lifeId
		end
	end
end

return Renown
