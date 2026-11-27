--[[
	DUELS IN TURNS (v0.17): two players, both choosing every turn, choices hidden until both
	have chosen (or the wait runs out). The server keeps the duel (server/Duels.luau); this
	module is the rules, so the same fight can be played in tests without a server.

	Every turn each side picks one:
	  strike <approach>   any way of fighting the life has (Overpower, a technique, an arm,
	                      Hardblood...). Strike against strike is a real clash (Clash.resolve):
	                      the winner's blow lands, the loser's doesn't.
	  guard               takes less than half of a strike, and steadies your next blow.
	                      Beaten by a feint.
	  feint               a bluff: beats a guard (lands in full, and breaks their steadiness),
	                      but a strike catches you in it.
	  recover             patch up, twice a duel.
	  yield               it's over, and you lost.
	A friendly duel ends at first real blood: when someone is down to 40% of what they started
	with. A blood duel (both players turned rough play on) goes to the end, and a life can end
	in it. Afterwards each life takes a share of what it took (Pvp.finish).

	duel = { blood, turn, sides = { [key] = side }, order = { keyA, keyB }, log, last, outcome,
	         winner, done }
	side = { key, name, full, hp, start, floor, recovers, steady, action, approach, taken, dealt }
]]

local Rng = require(script.Parent.Rng)
local Clash = require(script.Parent.Clash)
local Effects = require(script.Parent.Effects)

local Pvp = {}

local LOG_KEEP = 16
local RECOVERS = 2

local function addLog(d, text: string, tone: string?)
	table.insert(d.log, { text = text, tone = tone })
	while #d.log > LOG_KEEP do
		table.remove(d.log, 1)
	end
end

local function keyOf(life): string
	return tostring(life.id)
end

function Pvp.start(sim: any, a: any, b: any, blood: boolean?): any
	local function side(life)
		local hp = life.stats[sim.vital] or 0
		return {
			key = keyOf(life),
			name = life.first or "Someone",
			full = (life.first or "") .. " " .. (life.last or ""),
			hp = hp,
			start = hp,
			-- a friendly duel stops at first real blood: 40% of where you started
			floor = if blood then 0 else math.floor(hp * 0.4),
			recovers = RECOVERS,
			steady = false,
			taken = 0,
			dealt = 0,
		}
	end
	local d = {
		v = 1,
		blood = blood == true,
		turn = 1,
		sides = { [keyOf(a)] = side(a), [keyOf(b)] = side(b) },
		order = { keyOf(a), keyOf(b) },
		log = {},
		rng = { rng = math.random(1, 2147483646) },
	}
	addLog(d, string.format("%s and %s face each other.%s", a.first, b.first, if d.blood then " Rough play: this goes to the end." else " First real blood ends it."), "muted")
	return d
end

local function other(d, key: string): string
	return if d.order[1] == key then d.order[2] else d.order[1]
end

-- the stat a strike is made with: the approach's own (the City fights by stat), or, in a pack
-- whose approaches are ways of going about one fight (the original pack's Steady, Reckless
-- and Careful), the pack's fight stat, as its one-roll duels always used
local function strikeStat(sim: any, a: any): string?
	if not a or a.bloodless then
		return nil
	end
	return a.stat or sim.roles.fight
end

local function canStrike(sim: any, life: any, a: any): boolean
	local stat = strikeStat(sim, a)
	return stat ~= nil and sim:approachOpen(life, a, { fight = true, stat = stat })
end

-- a feint finds the gap in a guard: the feinter's quickest stat (Speed, or their wits)
local function feintStat(sim: any, life: any): string
	local quick, wits = sim.roles.speed, sim.roles.work
	if quick and (life.stats[quick] or 0) >= (life.stats[wits] or 0) then
		return quick
	end
	return wits or sim.roles.fight
end

-- the way of fighting an opponent would most likely use: the open one on their best stat
local function bestApproach(sim: any, life: any): string?
	local best, bestV = nil, -1
	for _, id in (sim.pack.approaches and sim.pack.approaches.order) or {} do
		local a = sim.pack.approaches[id]
		if canStrike(sim, life, a) then
			local v = life.stats[strikeStat(sim, a) :: string] or 0
			if v > bestV then
				best, bestV = id, v
			end
		end
	end
	return best
end

local function sideFor(sim: any, life: any, approachId: string?): any
	local a = approachId and sim.pack.approaches[approachId]
	local stat = strikeStat(sim, a) or sim.roles.fight
	return sim:clashSides(life, { stat = stat, fight = true, fixed = true }, approachId), stat
end

-- how hard a blow lands: like a boss battle's, from the stat it was struck with
local function blow(life: any, stat: string, steady: boolean, mult: number): number
	local v = (life.stats and life.stats[stat]) or 0
	local d = 12 + math.floor(v / 5) + (if steady then 4 else 0)
	return math.max(1, math.floor(d * mult))
end

-- what a side may do this turn: every way of fighting it has, and the rest
function Pvp.options(sim: any, d: any, lives: any, key: string): any
	local me = d.sides[key]
	local life = lives[key]
	local foeLife = lives[other(d, key)]
	if not me or not life or d.done or me.action then
		return nil
	end
	local list = {}
	local theirs = foeLife and sideFor(sim, foeLife, bestApproach(sim, foeLife))
	for _, id in (sim.pack.approaches and sim.pack.approaches.order) or {} do
		local a = sim.pack.approaches[id]
		if canStrike(sim, life, a) then
			local stat = strikeStat(sim, a) :: string
			local mine = sideFor(sim, life, id)
			local odds = if theirs then Clash.estimate(mine, theirs, 160) else nil
			table.insert(list, { action = "strike", approach = id, name = a.name, stat = stat, odds = odds, hit = blow(life, stat, me.steady, 1), color = a.color })
		end
	end
	table.insert(list, { action = "guard", name = "Guard", desc = "A strike does under half. Your next blow is steadier. A feint gets past it." })
	table.insert(list, { action = "feint", name = "Feint", desc = "Beats a guard and breaks it. A strike catches you in it." })
	local heal = 10 + math.floor(sim:maxHealthOf(life) * 0.06)
	table.insert(list, { action = "recover", name = "Patch up", desc = string.format("Heal about %d. %d left.", heal + 3, me.recovers), left = me.recovers, enabled = me.recovers > 0 })
	table.insert(list, { action = "yield", name = "Yield", desc = "It's over, and you lost." })
	return list
end

-- one side's choice for this turn. Returns true when both have chosen (time to resolve).
function Pvp.choose(sim: any, d: any, lives: any, key: string, action: string, approach: string?): (boolean, string?)
	local me = d.sides[key]
	if not me or d.done then
		return false, "There's no duel going on."
	end
	if me.action then
		return false, "You've already chosen this turn."
	end
	local life = lives[key]
	if action == "strike" then
		local a = approach and sim.pack.approaches[approach]
		if not canStrike(sim, life, a) then
			return false, "You can't fight that way."
		end
	elseif action == "recover" then
		if me.recovers <= 0 then
			return false, "Nothing left to patch up with."
		end
	elseif action ~= "guard" and action ~= "feint" and action ~= "yield" then
		return false, "Pick a move."
	end
	me.action = action
	me.approach = if action == "strike" then approach else nil
	return d.sides[other(d, key)].action ~= nil, nil
end

local function hit(d, side, amount: number)
	amount = math.max(0, math.floor(amount))
	side.hp = math.max(0, side.hp - amount)
	side.taken += amount
	return amount
end

-- both have chosen (a side that didn't choose in time guards): play the turn out
function Pvp.resolve(sim: any, d: any, lives: any): any
	if d.done then
		return nil
	end
	local kA, kB = d.order[1], d.order[2]
	local A, B = d.sides[kA], d.sides[kB]
	A.action = A.action or "guard"
	B.action = B.action or "guard"
	local turn = { turn = d.turn, entries = {} }
	local function statusOf(id: string?): string?
		local Battle = require(script.Parent.Battle) :: any
		return Battle.statusOf(id and sim.pack.approaches[id])
	end
	local entries = {
		[kA] = { key = kA, name = A.name, action = A.action, approach = A.approach, status = statusOf(A.approach) },
		[kB] = { key = kB, name = B.name, action = B.action, approach = B.approach, status = statusOf(B.approach) },
	}
	turn.entries = { entries[kA], entries[kB] }
	local function nameOf(id: string?)
		local a = id and sim.pack.approaches[id]
		return if a then a.name else "a strike"
	end

	-- yielding ends it before anything lands
	for _, s in { A, B } do
		if s.action == "yield" then
			addLog(d, s.name .. " yields.", "muted")
			d.done = true
			d.winner = other(d, s.key)
			d.outcome = "yield"
		end
	end
	if not d.done then
		-- patching up happens first
		for _, s in { A, B } do
			if s.action == "recover" then
				s.recovers -= 1
				local life = lives[s.key]
				local heal = Rng.int(d.rng, 10, 16) + math.floor(sim:maxHealthOf(life) * 0.06)
				s.hp = math.min(math.max(s.start, s.hp), s.hp + heal)
				entries[s.key].healed = heal
				addLog(d, string.format("%s patches up (+%d).", s.name, heal), "good")
			end
		end
		local function act(x, y, kx, ky)
			-- x's move against y's move (each pair is played once, from the striker's side)
			local lx, ly = lives[kx], lives[ky]
			local ax, ay = x.action, y.action
			if ax == "strike" and ay == "strike" then
				if kx ~= kA then
					return -- the clash is played once
				end
				local sx, statX = sideFor(sim, lx, x.approach)
				local sy, statY = sideFor(sim, ly, y.approach)
				local res = Clash.resolve(d.rng, sx, sy)
				local winSide, loseSide, wl, wStat, wKey = x, y, lx, statX, kx
				if not res.won then
					winSide, loseSide, wl, wStat, wKey = y, x, ly, statY, ky
				end
				local dmg = hit(d, loseSide, blow(wl, wStat, winSide.steady, 1))
				winSide.dealt += dmg
				entries[wKey].won = true
				entries[wKey].dealt = dmg
				entries[loseSide.key].taken = (entries[loseSide.key].taken or 0) + dmg
				turn.clash = { winner = wKey, rounds = #res.rounds }
				addLog(d, string.format("%s's %s beats %s's %s: %d.", winSide.name, nameOf(winSide.approach), loseSide.name, nameOf(loseSide.approach), dmg), "danger")
			elseif ax == "strike" and ay == "guard" then
				local sx, statX = sideFor(sim, lx, x.approach)
				local _ = sx
				local dmg = hit(d, y, blow(lx, statX, x.steady, 0.4))
				x.dealt += dmg
				entries[kx].dealt = dmg
				entries[ky].taken = (entries[ky].taken or 0) + dmg
				addLog(d, string.format("%s's guard holds against %s: only %d gets through.", y.name, nameOf(x.approach), dmg), "muted")
			elseif ax == "strike" and (ay == "feint" or ay == "recover") then
				local _, statX = sideFor(sim, lx, x.approach)
				local mult = if ay == "feint" then 0.9 else 0.75
				local dmg = hit(d, y, blow(lx, statX, x.steady, mult))
				x.dealt += dmg
				entries[kx].dealt = dmg
				entries[ky].taken = (entries[ky].taken or 0) + dmg
				addLog(d, if ay == "feint" then string.format("%s strikes into %s's feint: %d.", x.name, y.name, dmg) else string.format("%s hits %s while they patch up: %d.", x.name, y.name, dmg), "danger")
			elseif ax == "feint" and ay == "guard" then
				-- the feint finds the gap in the guard: the feinter's quickest stat
				local dmg = hit(d, y, blow(lx, feintStat(sim, lx), x.steady, 1))
				x.dealt += dmg
				y.steady = false
				entries[kx].dealt = dmg
				entries[kx].won = true
				entries[ky].taken = (entries[ky].taken or 0) + dmg
				addLog(d, string.format("%s feints, and %s's guard opens: %d.", x.name, y.name, dmg), "danger")
			elseif ax == "feint" and ay == "recover" then
				local dmg = hit(d, y, blow(lx, feintStat(sim, lx), false, 0.5))
				x.dealt += dmg
				entries[kx].dealt = dmg
				entries[ky].taken = (entries[ky].taken or 0) + dmg
			end
		end
		act(A, B, kA, kB)
		act(B, A, kB, kA)
		if A.action == "guard" and B.action == "guard" then
			addLog(d, "Both guard, and wait. Nobody moves first.", "muted")
		elseif A.action == "feint" and B.action == "feint" then
			addLog(d, "Two feints. Two people who know each other too well.", "muted")
		end
		-- a strike or a feint spends steadiness; a guard builds it
		for _, s in { A, B } do
			if s.action == "guard" then
				s.steady = true
			elseif s.action == "strike" or s.action == "feint" then
				s.steady = false
			end
		end
		-- is it over?
		for _, s in { A, B } do
			if s.hp <= s.floor and not d.done then
				d.done = true
				d.winner = other(d, s.key)
				d.outcome = if d.blood and s.hp <= 0 then "down" else "first_blood"
			end
		end
		if not d.done and A.hp <= A.floor and B.hp <= B.floor then
			d.done = true
			d.winner = if A.hp >= B.hp then kA else kB
			d.outcome = "first_blood"
		end
	end
	for _, s in { A, B } do
		turn.hp = turn.hp or {}
		turn.hp[s.key] = s.hp
		s.action = nil
		s.approach = nil
	end
	d.last = turn
	d.turn += 1
	if d.done then
		local w = d.sides[d.winner]
		addLog(d, (w and w.name or "Someone") .. " wins the duel.", "good")
	end
	return turn
end

-- the end: what each life takes away. A friendly duel costs a share of what you took (never
-- below 1 Health); a blood duel costs all of it, and can end a life.
function Pvp.finish(sim: any, d: any, lives: any): any
	local reports = {}
	for _, key in d.order do
		local s = d.sides[key]
		local life = lives[key]
		local report = sim.newReport()
		reports[key] = report
		if life and life.alive then
			local won = d.winner == key
			local foe = d.sides[other(d, key)]
			local foeName = if foe then foe.full else "them"
			sim:tally(life, if won then "duelsWon" else "duelsLost")
			local vital = sim.vital
			if d.blood then
				-- what the duel took, it took for real (the duel already counted every blow, so
				-- the City's lethality isn't applied twice); a body taken all the way down dies
				local before = life.stats[vital] or 0
				life.stats[vital] = math.max(0, before - s.taken)
				local result: any = { sanity = if won then -3 else -6, log = if won then string.format("You won the blood duel with %s, in %d turns.", foeName, d.turn - 1) else string.format("%s won the blood duel.", foeName) }
				if won then
					result[sim.roles.fight] = 2
				end
				Effects.apply(sim, life, result, report)
				sim:push(life, report, { kind = "log", text = string.format("The duel cost you %d Health.", before - life.stats[vital]), deltas = { [vital] = life.stats[vital] - before } })
				if life.stats[vital] <= 0 and life.alive then
					sim:kill(life, report, "Killed in a blood duel by " .. foeName)
				end
			else
				local loss = math.min(math.floor(s.taken * 0.3), math.max(0, (life.stats[vital] or 1) - 1))
				life.stats[vital] = (life.stats[vital] or 0) - loss
				if won then
					Effects.apply(sim, life, { [sim.roles.fight] = 1, sanity = 2, log = string.format("You beat %s in a duel: %d turns, and a handshake after.", foeName, d.turn - 1) }, report)
				else
					sim:push(life, report, { kind = "log", text = string.format("%s beat you in a duel, in %d turns. You'll feel it tomorrow.", foeName, d.turn - 1), deltas = { [vital] = -loss } })
				end
			end
			sim:highlight(life, string.format("%s a %sduel with %s.", if won then "Won" else "Lost", if d.blood then "blood " else "", foeName))
		end
	end
	return reports
end

-- what one side sees: both sides' bars, the turn, their options, what happened last
function Pvp.view(sim: any, d: any, lives: any, key: string): any
	local me = d.sides[key]
	local them = d.sides[other(d, key)]
	if not me or not them then
		return nil
	end
	local function sideView(s, life)
		return {
			key = s.key,
			name = s.name,
			full = s.full,
			hp = s.hp,
			start = s.start,
			floor = s.floor,
			steady = s.steady,
			recovers = s.recovers,
			chosen = s.action ~= nil,
			appearance = if life then sim:appearance(life) else nil,
		}
	end
	return {
		turn = d.turn,
		blood = d.blood,
		me = sideView(me, lives[key]),
		them = sideView(them, lives[them.key]),
		options = Pvp.options(sim, d, lives, key),
		last = d.last,
		log = d.log,
		done = d.done,
		winner = d.winner,
		won = d.done and d.winner == key or nil,
		outcome = d.outcome,
	}
end

return Pvp
