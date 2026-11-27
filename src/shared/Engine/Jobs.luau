--[[
	JOBS: work is something you do. A life with a career gets a board of jobs every year
	(pack.jobs), each a check or a fight that scales with its rank. A job done pays, teaches,
	and counts toward the next rank (Sim:ageUp): with pack.jobs.perRank of them done, the
	promotion is certain once the stat and the years are there.

	pack.jobs = {
		perYear = 3,        -- how many are on the board
		perRank = 2,        -- how many make the next promotion certain
		ease = 8,           -- a job is pitched this far under the stat your next rank asks for
		default = "street", -- the family for a career that isn't listed
		byCareer = { fixer = "office", thumb = "syndicate", ... },
		families = {
			office = {
				title = "Contracts",
				list = {
					{ id, name, line, stat (a check) | fight = true (+ foe, enemy, temper),
					  tier = -1|0|1|2|3 (easy .. brutal), pay = share of a year's wage,
					  win, lose (log lines), cost = { sanity = -3 } (what losing takes),
					  rep = { fixers = 2 }, minRank, maxRank, when,
					  careers = { "zwei", ... } (only for these careers), ability (the foe's) },
				},
				hard = { base = 2, coins = 1 }, -- every job in the family is this much harder
				payMult = 1.5,                 -- and pays this much more
			},
				},
			},
		},
	}
]]

local Conditions = require(script.Parent.Conditions)
local Rng = require(script.Parent.Rng)

local Jobs = {}

function Jobs.family(sim, life)
	local jobs = sim.pack.jobs
	if not jobs or not life.career then
		return nil
	end
	local id = (jobs.byCareer and jobs.byCareer[life.career.id]) or jobs.default
	return id and jobs.families[id] or nil
end

-- the board for this year (called when the year turns)
function Jobs.roll(sim, life)
	life.jobs = nil
	local fam = Jobs.family(sim, life)
	if not fam then
		return
	end
	-- a job is for this career (careers), at this rank (minRank..maxRank), in these times (when).
	-- Jobs written for your own career and rank come first: the board is three of those when
	-- there are three, and only then fills up from the rest.
	local own, rest = {}, {}
	local id, rank = life.career.id, life.career.rank
	for i, t in fam.list do
		local fits = (t.minRank == nil or rank >= t.minRank) and (t.maxRank == nil or rank <= t.maxRank)
			and (t.careers == nil or table.find(t.careers, id) ~= nil)
			and Conditions.check(t.when, life, sim.pack, { noChance = true })
		if fits then
			-- last year's jobs sit out a year, so the board changes
			local recent = life.jobsLast and table.find(life.jobsLast, i) ~= nil
			if not recent then
				table.insert(if t.careers or t.minRank or t.maxRank then own else rest, i)
			end
		end
	end
	-- three a year: the career's own first, drawn at random, then any of the rest
	local want = sim.pack.jobs.perYear or 3
	local out = {}
	for _, list in { own, rest } do
		while #list > 0 and #out < want do
			table.insert(out, { t = table.remove(list, Rng.int(life, 1, #list)), done = false })
		end
	end
	-- (v0.13) TWISTS (pack.jobs.twists): the same kind of job is never quite the same job twice
	local twists = sim.pack.jobs.twists
	if twists and #twists > 0 then
		for _, j in out do
			if Rng.chance(life, sim.pack.jobs.twistChance or 0.6) then
				local open, weights = {}, {}
				for ti, tw in twists do
					local tpl = fam.list[j.t]
					local fits = Conditions.check(tw.when, life, sim.pack, { noChance = true })
						and not (tw.fight == true and not (tpl and tpl.fight))
						and not (tw.fight == false and tpl and tpl.fight)
					if fits then
						table.insert(open, ti)
						table.insert(weights, tw.weight or 10)
					end
				end
				local k = Rng.weighted(life, weights)
				if k then
					j.twist = open[k]
				end
			end
		end
	end
	life.jobs = out
	life.jobsLast = {}
	for _, j in out do
		table.insert(life.jobsLast, j.t)
	end
end

-- what a job is up against: a foe pitched just under the stat the next rank asks for
local function numbers(sim, life, tpl)
	local def = sim.pack.careers[life.career.id]
	local rank = life.career.rank
	local level = 20 + rank * 8
	if def.promoteAt and #def.promoteAt > 0 then
		level = def.promoteAt[math.min(rank, #def.promoteAt)]
	end
	local x = math.max(0, level - (sim.pack.jobs.ease or 8))
	local curve = sim.pack.clash or {}
	local coins = math.min(curve.maxCoins or 4, 1 + math.floor(x / (curve.coinsEvery or 32)))
	if tpl.fight then
		-- in a fight your coins come from Speed, so theirs come a little easier too
		coins = math.min(curve.maxCoins or 4, 1 + math.floor((x + 14) / (curve.coinsEvery or 32)))
	end
	local base = math.max(1, 1 + math.floor(x / (curve.baseEvery or 22)) + (tpl.tier or 0) + (if tpl.fight then 1 else 0))
	local power = 2 + math.floor(x / (curve.powerEvery or 50))
	-- some families are simply harder (a Wing's work is done to a Wing's standard)
	local fam = Jobs.family(sim, life)
	local hard = fam and fam.hard
	if hard then
		base += hard.base or 0
		coins = math.min((curve.maxCoins or 4) + 1, coins + (hard.coins or 0))
		power += hard.coinPower or 0
	end
	-- a brutal job (tier 3) brings one more coin to the table
	if (tpl.tier or 0) >= 3 then
		coins = math.min((curve.maxCoins or 4) + 1, coins + 1)
	end
	return coins, base, power
end

-- a job as an option the engine can resolve (clash, win, lose)
function Jobs.option(sim, life, job)
	local fam = Jobs.family(sim, life)
	local tpl = fam and fam.list[job.t]
	if not tpl then
		return nil
	end
	local coins, base, power = numbers(sim, life, tpl)
	local stat = tpl.stat or sim.roles.fight
	local payMult = (fam and fam.payMult) or 1
	-- a name is worth money: renown raises what a job pays
	local ranks = sim.pack.renown and sim.pack.renown.ranks
	if ranks and (life.renown or 0) > 0 then
		local r = 0
		for i, def in ranks do
			if (life.renown or 0) >= def.at then
				r = i
			end
		end
		if r > 0 and ranks[r].perks then
			payMult *= 1 + (ranks[r].perks.pay or 0)
		end
	end
	-- (v0.13) the twist on this one: harder or easier, better or worse paid, and what follows
	local tw = job.twist and sim.pack.jobs.twists and sim.pack.jobs.twists[job.twist]
	if tw then
		base = math.max(1, base + (tw.base or 0))
		coins = math.max(1, coins + (tw.coins or 0))
		payMult *= tw.pay or 1
	end
	local win = { paycheck = (tpl.pay or 0.4) * payMult, log = tpl.win }
	win[tpl.teaches or stat] = 1
	if tpl.rep then
		win.rep = tpl.rep
	end
	local lose = { log = tpl.lose }
	for k, v in tpl.cost or { sanity = -3 } do
		lose[k] = v
	end
	if tw then
		for k, v in tw.win or {} do
			if k == "log" then
				win.log = (win.log or "") .. " " .. v
			else
				win[k] = v
			end
		end
		for k, v in tw.lose or {} do
			if k == "log" then
				lose.log = (lose.log or "") .. " " .. v
			else
				lose[k] = v
			end
		end
	end
	return {
		name = tpl.name,
		clash = {
			stat = stat,
			foe = tpl.foe or (if type(tpl.name) == "table" then tpl.name[1] else tpl.name),
			enemy = tpl.enemy,
			temper = tpl.temper,
			ability = tpl.ability,
			fight = tpl.fight == true,
			coins = coins,
			base = base,
			coinPower = power,
			fixed = true,
		},
		win = win,
		lose = lose,
	}, tpl
end

function Jobs.view(sim, life)
	local fam = Jobs.family(sim, life)
	if not fam or not life.jobs then
		return nil
	end
	local perRank = sim.pack.jobs.perRank or 2
	local out = { title = fam.title or "Jobs", done = life.career.jobs or 0, need = perRank, list = {} }
	for i, job in life.jobs do
		local option, tpl = Jobs.option(sim, life, job)
		if option and tpl then
			local preview = sim:clashPreview(life, option.clash)
			local stakes = sim:stakesView(option, life, sim:workCtx(life))
			local tw = job.twist and sim.pack.jobs.twists and sim.pack.jobs.twists[job.twist]
			table.insert(out.list, {
				index = i,
				name = sim:render(life, tpl.name),
				line = if tpl.line then sim:render(life, tpl.line) else nil,
				twist = if tw then { name = tw.name, line = sim:render(life, tw.line or ""), tone = tw.tone } else nil,
				tier = tpl.tier or 0,
				pay = math.floor(sim:salaryOf(life) * (tpl.pay or 0.4) * (fam.payMult or 1) * ((tw and tw.pay) or 1) + 0.5),
				done = job.done,
				won = job.won,
				clash = preview,
				stakes = stakes,
			})
		end
	end
	return out
end

-- do one: costs an action
function Jobs.take(sim, life, index: number, approachId: string?)
	local job = life.jobs and life.jobs[index]
	if not job or not life.career then
		return nil, "That job isn't on the board."
	end
	if job.done then
		return nil, "You've done that one this year."
	end
	if life.pending then
		return nil, "Decide what to do first."
	end
	if life.run then
		return nil, "Finish your expedition first."
	end
	if (life.actionsLeft or 0) <= 0 then
		return nil, "No actions left this year"
	end
	local option, tpl = Jobs.option(sim, life, job)
	if not option or not tpl then
		return nil, "That job isn't on the board."
	end
	local report = sim.newReport()
	life.actionsLeft -= 1
	local title = sim:render(life, tpl.name)
	life.lastChoice, life.lastClash, life.lastHit = title, nil, nil
	sim:push(life, report, { kind = "event", title = title, thread = "work" })
	life.scene = title
	sim:resolveOption(life, option, report, approachId, sim:workCtx(life))
	life.scene = nil
	job.done = true
	job.won = report.clash ~= nil and report.clash.won == true
	-- a hard job done is talked about (tier 2: +6, tier 3: +12)
	if job.won and (tpl.tier or 0) >= 2 then
		sim:addRenown(life, (tpl.tier - 1) * 6, report)
	end
	if job.won and life.career then
		life.career.jobs = (life.career.jobs or 0) + 1
		sim:tally(life, "jobsDone")
	end
	sim:advance(life, report)
	sim:checkAmbitions(life, report)
	return report
end

return Jobs
