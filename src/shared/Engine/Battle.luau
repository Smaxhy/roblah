--[[
	BATTLES (v0.16): turn-based fights against big bosses, alone or with friends.

	An event choice with `battle = "<boss id>"` (pack.bosses) starts one instead of a one-tap
	clash. The boss has Health, phases, and a move it shows one turn ahead: what it's about to
	do, how hard, and to whom. Every fighter picks an action each turn:

	  strike   fight with one of your ways of fighting (Overpower, Outpace, Outthink...).
	           If the boss's move is aimed at you, it's a clash: win it and your blow lands and
	           theirs doesn't; lose it and you take the move. If it's aimed at someone else,
	           your blow lands unopposed (a little lighter).
	  guard    take less than half of what's aimed at you, and your next strike is steadier
	  recover  patch yourself up (twice a battle); if the move is aimed at you, you still take it
	  flee     get out (with a parting blow if it was aimed at you). Your friends fight on.

	When everyone still standing has chosen, the turn resolves. Hurt the boss enough and it
	changes (phases: harder hits, new moves). Bring it to nothing and every fighter still in
	gets the choice's `win`; fall, and you fall; flee, and you get the choice's `fled` (or a
	small default). Damage is real Health: the City's lethality and your toughness apply, and
	a fighter brought to nothing dies, with the boss as the cause.

	State lives on the host's life (life.battle); friends who join carry life.battleWith =
	the host's life id. The engine takes the fighters' lives as a map { [lifeId] = life }.
		Battle.begin(sim, life, bossId, origin)       origin = { eventId, choice, art, title }
		Battle.join(sim, hostLife, life)
		Battle.act(sim, hostLife, lives, key, action, approach)  -> report? (when the turn resolved)
		Battle.resolve(sim, hostLife, lives)           force the turn (missing choices guard)
		Battle.view(sim, hostLife, lives, viewerKey)

	(v0.19) ALLIES: the host's party members who came into the boss room (Engine/Party.luau)
	fight beside the players as allies (b.allies). They act on their own every turn, after the
	players and before the boss: a Healer patches up whoever is worst off, a Tanker plants a
	shield (and may take a blow aimed at one of you), everyone else strikes, by their rank and
	class. The boss can go for them too. An ally brought to nothing goes down; when the fight
	ends, Party.afterBattle says what that cost (hurt, or worse) and pays their shares. Every
	ally move is in the battle log, and allies are in the view's fighters (ally = true).
]]

local Effects = require(script.Parent.Effects)
local Rng = require(script.Parent.Rng)
local Party = require(script.Parent.Party)

local Battle = {}

local MAX_FIGHTERS = 4
local RECOVERS = 2
local LOG_KEEP = 14

-- (v0.17) the status a way of fighting leaves behind, for the screen's effects
local STATUSES = { burn = true, bleed = true, tremor = true, rupture = true, sinking = true, poise = true, charge = true }
local function statusOf(a: any): string?
	for _, ab in (a and a.abilities) or {} do
		if STATUSES[ab.id] then
			return ab.id
		end
	end
	return nil
end
Battle.statusOf = statusOf

local function addLog(b, text: string, tone: string?)
	table.insert(b.log, { turn = b.turn, text = text, tone = tone })
	while #b.log > LOG_KEEP do
		table.remove(b.log, 1)
	end
end

function Battle.def(sim: any, id: string?): any
	return id and sim.pack.bosses and sim.pack.bosses[id] or nil
end

local function fighterOf(b, key: string)
	for _, f in b.fighters do
		if f.key == key then
			return f
		end
	end
	return nil
end

local function active(b, f): boolean
	return not f.down and not f.fled
end

local function bark(def: any, kind: string, rng: any): string?
	local list: any = def.barks and def.barks[kind]
	if type(list) == "table" and #list > 0 then
		return list[Rng.int(rng, 1, #list)]
	end
	return nil
end

-- the moves open in the current phase (a phase can add moves)
local function movesNow(def, b)
	local list = {}
	for _, m in def.moves or {} do
		table.insert(list, m)
	end
	for i = 2, b.phase do
		local ph = def.phases and def.phases[i - 1]
		for _, m in (ph and ph.moves) or {} do
			table.insert(list, m)
		end
	end
	return list
end

-- the boss's numbers in the current phase
local function bossNumbers(def, b)
	local coins, base, coinPower, power = def.coins or 3, def.base or 6, def.coinPower or 3, 0
	for i = 2, b.phase do
		local ph = def.phases and def.phases[i - 1]
		if ph then
			coins += ph.coins or 0
			base += ph.base or 0
			coinPower += ph.coinPower or 0
			power += ph.power or 0
		end
	end
	return coins, base, coinPower, power
end

-- the boss picks its next move and who it's aimed at, and says so
local function pickNext(sim, b, rng)
	local def = Battle.def(sim, b.boss)
	local moves = movesNow(def, b)
	local weights = {}
	for _, m in moves do
		table.insert(weights, m.weight or 10)
	end
	local idx = Rng.weighted(rng, weights) or 1
	local move = moves[idx]
	b.next = move.id
	local targets = {}
	for _, f in b.fighters do
		if active(b, f) then
			table.insert(targets, f.key)
		end
	end
	if move.target == "all" then
		b.target = "all"
	elseif #targets > 0 then
		-- a boss goes for whoever hurt it most, more often than not
		local best, bestDealt = nil, -1
		for _, f in b.fighters do
			if active(b, f) and f.dealt > bestDealt then
				best, bestDealt = f.key, f.dealt
			end
		end
		b.target = if best and Rng.chance(rng, 0.5) then best else targets[Rng.int(rng, 1, #targets)]
	else
		b.target = nil
	end
	-- (v0.19) a party ally standing in the room can draw it instead
	if b.allies and move.target ~= "all" and b.target ~= nil then
		local up = {}
		for _, a in b.allies do
			if not a.down then
				table.insert(up, a)
			end
		end
		if #up > 0 and Rng.chance(rng, 0.22) then
			b.target = up[Rng.int(rng, 1, #up)].key
		end
	end
end

local function allyOf(b, key: string?)
	for _, a in b.allies or {} do
		if a.key == key then
			return a
		end
	end
	return nil
end

local CLASS_WORD = { fighter = "Fighter", mage = "Mage", assassin = "Assassin", tanker = "Tanker", ranger = "Ranger", healer = "Healer" }
local function allyLabel(a): string
	return string.format("%s (%s %s)", a.name, Party.letter(a.rank), CLASS_WORD[a.class] or "Hunter")
end
Battle.allyLabel = allyLabel

-- an ally takes a blow
local function allyTake(b, a, dmg: number)
	if dmg <= 0 or a.down then
		return 0
	end
	local taken = math.min(a.hp, dmg)
	a.hp = math.max(0, a.hp - dmg)
	if a.hp <= 0 then
		a.down = true
		addLog(b, allyLabel(a) .. " goes down.", "danger")
	end
	return taken
end

-- an ally's turn: heal, guard or strike (lives: the fighters' lives; order: who's still in)
local STRIKE = {
	fighter = { mult = 1, verb = "cuts into it" },
	mage = { mult = 1.15, verb = "hits it with a spell" },
	assassin = { mult = 0.95, verb = "finds a gap in its guard", crit = 0.25 },
	ranger = { mult = 0.9, verb = "puts an arrow in it" },
	tanker = { mult = 0.45, verb = "shield-bashes it" },
	healer = { mult = 0.35, verb = "strikes when it turns" },
}
local function allyAct(sim, b, a, lives, order, rng, reportOf)
	a.guarding = false
	local pow = 1 + 0.06 * (a.power or 0)
	if a.class == "healer" then
		-- the worst off of you, if anyone needs it
		local worst, worstRatio, worstLife = nil, 0.7, nil
		for _, f in order do
			local life = lives[f.key]
			if life and life.alive and active(b, f) then
				local ratio = (life.stats[sim.vital] or 0) / math.max(1, sim:maxHealthOf(life))
				if ratio < worstRatio then
					worst, worstRatio, worstLife = f, ratio, life
				end
			end
		end
		if worst and worstLife then
			local heal = math.floor((6 + 5 * a.rank) * pow + 0.5) + Rng.int(rng, 0, 4)
			local before = worstLife.stats[sim.vital] or 0
			Effects.apply(sim, worstLife, { [sim.vital or "health"] = heal }, reportOf(worst.key))
			local got = (worstLife.stats[sim.vital] or 0) - before
			a.healed += got
			addLog(b, string.format("%s mends %s: +%d Health.", allyLabel(a), worst.name, got), "good")
			return
		end
	elseif a.class == "tanker" then
		a.guarding = true
	end
	local s = STRIKE[a.class] or STRIKE.fighter
	local d = math.floor(Party.ALLY_BLOW[a.rank] * s.mult * pow * (if a.hurt then 0.6 else 1) + 0.5) + Rng.int(rng, -2, 2)
	local crit = s.crit and Rng.chance(rng, s.crit)
	if crit then
		d = math.floor(d * 1.7 + 0.5)
	end
	d = math.max(1, d)
	b.hp = math.max(0, b.hp - d)
	a.dealt += d
	if a.class == "tanker" then
		addLog(b, string.format("%s plants a shield in front of the party and %s: %d damage.", allyLabel(a), s.verb, d), "good")
	else
		addLog(b, string.format("%s %s%s: %d damage.", allyLabel(a), s.verb, if crit then ", a clean hit" else "", d), "good")
	end
end

local function moveDef(def, b, id: string?)
	for _, m in movesNow(def, b) do
		if m.id == id then
			return m
		end
	end
	return (def.moves or {})[1]
end

local function newFighter(life)
	return {
		key = tostring(life.id),
		name = life.first or "Someone",
		recovers = RECOVERS,
		guard = false,
		steady = false,
		down = false,
		fled = false,
		acted = nil,
		dealt = 0,
		taken = 0,
	}
end

function Battle.begin(sim: any, life: any, bossId: string, origin: any): (any, string?)
	local def = Battle.def(sim, bossId)
	if not def then
		return nil, "No such boss."
	end
	origin = origin or {}
	local b = {
		v = 1,
		boss = bossId,
		eventId = origin.eventId,
		choice = origin.choice,
		art = origin.art or def.art,
		title = origin.title,
		hp = def.hp,
		maxHp = def.hp,
		phase = 1,
		turn = 1,
		fighters = { newFighter(life) },
		log = {},
		last = nil,
		outcome = nil,
	}
	life.battle = b
	addLog(b, bark(def, "start", life) or (def.name .. " squares up."), "danger")
	-- (v0.19) your party, the ones who came in with you (a boss holds out a little longer)
	local allies = Party.allies(sim, life, def)
	if allies then
		b.allies = allies
		local extra = math.floor((def.hp or 100) * 0.18 * #allies)
		b.hp += extra
		b.maxHp += extra
		local names = {}
		for _, a in allies do
			table.insert(names, allyLabel(a))
		end
		addLog(b, table.concat(names, ", ") .. (if #allies == 1 then " goes in with you." else " go in with you."), "good")
	end
	pickNext(sim, b, life)
	return b
end

function Battle.join(sim: any, hostLife: any, life: any): (any, string?)
	local b = hostLife and hostLife.battle
	if not b or b.outcome then
		return nil, "That fight is over."
	end
	if #b.fighters >= MAX_FIGHTERS then
		return nil, "There's no room in that fight."
	end
	if fighterOf(b, tostring(life.id)) then
		return nil, "You're already in it."
	end
	local def = Battle.def(sim, b.boss)
	table.insert(b.fighters, newFighter(life))
	-- a boss holds out longer against more of you
	local extra = math.floor((def.hp or 100) * 0.6)
	b.maxHp += extra
	b.hp += extra
	life.battleWith = tostring(hostLife.id)
	addLog(b, (life.first or "Someone") .. " joins the fight.", "good")
	return b
end

-- the clash spec of a strike against the boss's move this turn
local function strikeSpec(def, b, move, stat: string)
	local coins, base, coinPower = bossNumbers(def, b)
	return {
		stat = stat,
		foe = def.name,
		enemy = def.enemy,
		fight = true,
		coins = coins + (move.coins or 0),
		base = base + (move.base or 0),
		coinPower = coinPower + (move.coinPower or 0),
		status = move.status and { id = move.status, potency = move.potency or 1 } or def.status,
		temper = def.temper,
		boss = true,
		-- a battle is its own difficulty curve (Health, phases): the boss doesn't also grow
		-- with your age the way a one-clash fight does
		fixed = true,
	}
end

-- how hard a fighter's blow lands, from the stat they fought with
local function blow(life, statKey: string, won: boolean, unopposed: boolean, steady: boolean): number
	local stat = (life.stats and life.stats[statKey]) or 0
	local d = 12 + math.floor(stat / 5)
	if steady then
		d += 4
	end
	if unopposed then
		d = math.floor(d * 0.75)
	end
	if not won then
		d = math.floor(stat / 25)
	end
	return math.max(0, d)
end

local function hurt(sim, life, report, amount: number, cause: string, condition: string?, rng)
	if amount <= 0 or not life.alive then
		return 0
	end
	local before = life.stats[sim.vital] or 0
	-- (the pack's Health stat: its id is the pack's own, e.g. BitLeveling's vitality)
	local result: any = { [sim.vital or "health"] = -amount, cause = cause }
	if condition and sim.pack.conditions and sim.pack.conditions[condition] and Rng.chance(rng, 0.35) then
		result.condition = condition
	end
	Effects.apply(sim, life, result, report)
	return math.max(0, before - (life.stats[sim.vital] or 0))
end

function Battle.act(sim: any, hostLife: any, lives: any, key: string, action: string, approach: string?): (any, string?)
	local b = hostLife and hostLife.battle
	if not b or b.outcome then
		return nil, "There's no fight going on."
	end
	local f = fighterOf(b, key)
	if not f or not active(b, f) then
		return nil, "You're out of this fight."
	end
	if f.acted then
		return nil, "You've already chosen this turn."
	end
	local life = lives[key]
	if not life or not life.alive then
		return nil, "You're out of this fight."
	end
	if action == "recover" and f.recovers <= 0 then
		return nil, "Nothing left to patch yourself up with."
	end
	if action == "strike" then
		local a = approach and sim.pack.approaches and sim.pack.approaches[approach]
		if not (a and a.stat) or a.bloodless or not sim:approachOpen(life, a, { fight = true, stat = a.stat }) then
			return nil, "You can't fight that way."
		end
	elseif action ~= "guard" and action ~= "recover" and action ~= "flee" then
		return nil, "That isn't something you can do."
	end
	f.acted = { action = action, approach = approach }
	for _, other in b.fighters do
		if active(b, other) and not other.acted and lives[other.key] and lives[other.key].alive then
			return nil, nil -- waiting for the others
		end
	end
	return Battle.resolve(sim, hostLife, lives)
end

-- resolves the turn: fighters act (fastest first), then the boss's move lands, then the boss
-- shows its next one. Anyone who hasn't chosen guards. Returns { [key] = report }.
function Battle.resolve(sim: any, hostLife: any, lives: any): (any, string?)
	local b = hostLife.battle
	if not b or b.outcome then
		return nil, "There's no fight going on."
	end
	local def = Battle.def(sim, b.boss)
	local rng = hostLife -- (Rng draws from the host life's own stream)
	local reports = {}
	local function reportOf(key: string)
		reports[key] = reports[key] or sim.newReport()
		return reports[key]
	end
	local move = moveDef(def, b, b.next)
	local _coins, _base, _coinPower, phasePower = bossNumbers(def, b)
	local turn: any = { turn = b.turn, move = move.name, moveText = move.text, target = b.target, entries = {}, heavy = move.heavy == true }
	-- who still fights, fastest first
	local order = {}
	for _, f in b.fighters do
		local life = lives[f.key]
		if active(b, f) and life and life.alive then
			if not f.acted then
				f.acted = { action = "guard" }
			end
			table.insert(order, f)
		elseif active(b, f) and not (life and life.alive) then
			f.down = true
		end
	end
	table.sort(order, function(x, y)
		local lx, ly = lives[x.key], lives[y.key]
		return ((lx.stats.speed or 0) > (ly.stats.speed or 0))
	end)

	local struck = {} -- keys the boss's move is settled for (won the clash, or fled)
	for _, f in order do
		local life = lives[f.key]
		local report = reportOf(f.key)
		local aimed = b.target == "all" or b.target == f.key
		local act = f.acted
		local entry = { key = f.key, name = f.name, action = act.action, approach = act.approach }
		life.scene = b.title or def.name
		if act.action == "flee" then
			f.fled = true
			struck[f.key] = true
			if aimed then
				local dealt = math.floor((move.power + phasePower) * 0.5)
				entry.taken = hurt(sim, life, report, dealt, def.cause or ("Killed by " .. def.name), nil, rng)
			end
			addLog(b, f.name .. " gets out.", "muted")
		elseif act.action == "recover" then
			f.recovers -= 1
			-- (v0.17) a bigger body has more to patch: 10-16, plus 6% of its maximum Health
			local heal = Rng.int(rng, 10, 16) + math.floor(sim:maxHealthOf(life) * 0.06)
			-- (v0.19) the pack's own Health stat (BitLeveling's is vitality): `health` healed nobody
			Effects.apply(sim, life, { [sim.vital or "health"] = heal, sanity = 2 }, report)
			entry.healed = heal
			addLog(b, f.name .. " patches up (+" .. heal .. " Health).", "good")
		elseif act.action == "guard" then
			f.guard = true
			f.steady = true
			addLog(b, f.name .. " braces.", "muted")
		elseif act.action == "strike" then
			local a = sim.pack.approaches[act.approach]
			local statKey = a.stat
			entry.status = statusOf(a)
			if aimed then
				-- a clash: the blow against the boss's move
				local spec = strikeSpec(def, b, move, statKey)
				if f.steady then
					spec.base = math.max(1, spec.base - 2)
				end
				local res = sim:clash(life, spec, act.approach)
				local d = blow(life, statKey, res.won, false, f.steady)
				b.hp = math.max(0, b.hp - d)
				f.dealt += d
				entry.won = res.won
				entry.dealt = d
				entry.rounds = #(res.rounds or {})
				if res.won then
					struck[f.key] = true
					addLog(b, f.name .. " wins the clash with " .. a.name .. ": " .. d .. " damage.", "good")
				else
					addLog(b, f.name .. " loses the clash" .. (if d > 0 then " (" .. d .. " damage)" else "") .. ".", "danger")
				end
			else
				-- unopposed: the boss is busy with someone else
				local d = blow(life, statKey, true, true, f.steady)
				b.hp = math.max(0, b.hp - d)
				f.dealt += d
				entry.won = true
				entry.dealt = d
				entry.free = true
				addLog(b, f.name .. " hits it while it's busy: " .. d .. " damage.", "good")
			end
			f.steady = false
			sim:tally(life, "battleStrikes")
		end
		table.insert(turn.entries, entry)
		if b.hp <= 0 then
			break
		end
	end

	-- (v0.19) the party's turn: each ally still standing heals, guards or strikes
	if b.allies and b.hp > 0 then
		for _, a in b.allies do
			if not a.down and b.hp > 0 then
				allyAct(sim, b, a, lives, order, rng, reportOf)
			end
		end
	end

	if b.hp <= 0 then
		b.last = turn
		local done: any = Battle.finish(sim, hostLife, lives, "won", reports)
		return done, nil
	end

	-- a phase change, once it's hurt enough
	local nextPhase = def.phases and def.phases[b.phase]
	if nextPhase and b.hp <= b.maxHp * (nextPhase.at or 0.5) then
		b.phase += 1
		turn.phase = b.phase
		addLog(b, nextPhase.line or (def.name .. " changes."), "danger")
	end

	-- (v0.19) the party in the way: a Tanker steps in front of a blow aimed at one of you, and
	-- the move lands on any ally it was aimed at (or on all of them, a little lighter)
	local spared = {}
	if b.allies then
		local power = (move.power or 8) + phasePower
		local aimedAt = b.target and b.target ~= "all" and fighterOf(b, b.target)
		if aimedAt and not struck[b.target] then
			for _, a in b.allies do
				if not a.down and a.guarding and Rng.chance(rng, 0.5) then
					local took = allyTake(b, a, math.ceil(power * 0.5))
					a.blocked += took
					spared[b.target] = true
					addLog(b, string.format("%s takes the blow meant for %s (%d).", allyLabel(a), aimedAt.name, took), "good")
					break
				end
			end
		end
		for _, a in b.allies do
			if not a.down and (b.target == "all" or b.target == a.key) then
				local dmg = if b.target == "all" then math.ceil(power * 0.6) else power
				if a.guarding then
					dmg = math.ceil(dmg * 0.5)
				end
				local took = allyTake(b, a, dmg)
				addLog(b, string.format("%s: %s (%d to %s).", def.name, move.text or move.name, took, a.name), "danger")
			end
		end
	end
	-- the boss's move lands on whoever it was aimed at and didn't stop it
	for _, f in order do
		local life = lives[f.key]
		if active(b, f) and life.alive and not struck[f.key] and not spared[f.key] and (b.target == "all" or b.target == f.key) then
			local dmg = (move.power or 8) + phasePower
			if f.guard then
				dmg = math.ceil(dmg * 0.4)
			end
			local taken = hurt(sim, life, reportOf(f.key), dmg, def.cause or ("Killed by " .. def.name), move.condition, rng)
			f.taken += taken
			for _, e in turn.entries do
				if e.key == f.key then
					e.taken = (e.taken or 0) + taken
				end
			end
			addLog(b, def.name .. ": " .. (move.text or move.name) .. " (" .. taken .. " to " .. f.name .. ").", "danger")
			if not life.alive then
				f.down = true
				addLog(b, f.name .. " goes down.", "danger")
			end
		end
	end
	for _, f in b.fighters do
		f.guard = false
		f.acted = nil
	end
	b.last = turn

	-- is anyone still fighting?
	local left = 0
	for _, f in b.fighters do
		local life = lives[f.key]
		if active(b, f) and life and life.alive then
			left += 1
		end
	end
	if left == 0 then
		local anyFled = false
		for _, f in b.fighters do
			if f.fled then
				anyFled = true
			end
		end
		local done: any = Battle.finish(sim, hostLife, lives, if anyFled then "fled" else "lost", reports)
		return done, nil
	end
	b.turn += 1
	local line = if Rng.chance(rng, 0.35) then bark(def, if b.phase > 1 then "phase" else "hurt", rng) else nil
	if line then
		addLog(b, line, "voice")
	end
	pickNext(sim, b, rng)
	return reports
end

-- the end: the choice's results land on everyone it should, and the fight is cleared
function Battle.finish(sim: any, hostLife: any, lives: any, outcome: string, reports: any): any
	local b = hostLife.battle
	local def = Battle.def(sim, b.boss)
	b.outcome = outcome
	reports = reports or {}
	local event = b.eventId and sim.eventsById[b.eventId]
	local choice = event and event.choices and event.choices[b.choice or 0]
	if outcome == "won" then
		addLog(b, def.name .. " is down.", "good")
	end
	local hostGained = 0
	for _, f in b.fighters do
		local life = lives[f.key]
		if life then
			local report = reports[f.key] or sim.newReport()
			reports[f.key] = report
			life.scene = b.title or def.name
			if life.alive and outcome == "won" and not f.fled then
				sim:tally(life, "bossesBeaten")
				sim:push(life, report, { kind = "event", title = "Victory", text = def.name .. " is down." })
				local moneyBefore = life.money
				Effects.apply(sim, life, (choice and choice.win) or def.win, report)
				if life == hostLife then
					hostGained = math.max(0, life.money - moneyBefore)
				end
			elseif life.alive and f.fled then
				Effects.apply(sim, life, (choice and choice.fled) or def.fled or { sanity = -4, log = "You got out. Not everyone does." }, report)
			elseif life.alive and outcome ~= "won" then
				Effects.apply(sim, life, (choice and choice.lose) and Battle.withoutHealth(choice.lose, sim.vital) or { sanity = -6 }, report)
			end
			life.scene = nil
			life.battleWith = nil
			if life ~= hostLife then
				life.battleWith = nil
			end
			report.battleDone = { outcome = outcome, boss = def.name }
		end
	end
	-- (v0.19) the party that fought beside the host: what it cost them, and their shares
	if b.allies then
		local hostReport = reports[tostring(hostLife.id)] or sim.newReport()
		reports[tostring(hostLife.id)] = hostReport
		Party.afterBattle(sim, hostLife, b, outcome, hostReport, hostGained)
	end
	if hostLife.party then
		hostLife.party.on = nil
	end
	hostLife.battleDone = { outcome = outcome, boss = def.name, last = b.last, log = b.log }
	hostLife.battle = nil
	-- (BitLeveling) the card the fight came from learns how it went (Engine/HunterWorld.afterChoice)
	if sim.battleHook and event and choice then
		sim.battleHook(sim, hostLife, event, choice, outcome)
	end
	-- the host's year goes on (anything queued behind the fight)
	if hostLife.alive then
		sim:advance(hostLife, reports[tostring(hostLife.id)] or sim.newReport())
	end
	return reports
end

-- a lose result without its Health loss (the fight already took that)
function Battle.withoutHealth(result: any, vital: string?): any
	if type(result) ~= "table" then
		return result
	end
	local out = table.clone(result)
	out.health = nil
	if vital then
		out[vital] = nil
	end
	out.die = nil
	return out
end

-- what a fighter sees: the boss, the move it's about to make, everyone's state, what they can do
function Battle.view(sim: any, hostLife: any, lives: any, viewerKey: string?): any
	local b: any = hostLife and hostLife.battle
	if not b then
		return nil
	end
	local def: any = Battle.def(sim, b.boss)
	local move = moveDef(def, b, b.next)
	local coins, base, coinPower, phasePower = bossNumbers(def, b)
	local fighters: { any } = {}
	local waitingOn: { string } = {}
	for _, f: any in b.fighters do
		local life = lives[f.key]
		local hp = life and life.stats and life.stats[sim.vital] or 0
		local maxHp = life and sim:maxHealthOf(life) or 100
		table.insert(fighters, {
			key = f.key,
			name = f.name,
			hp = hp,
			maxHp = maxHp,
			down = f.down or (life ~= nil and not life.alive),
			fled = f.fled,
			acted = f.acted ~= nil,
			steady = f.steady,
			recovers = f.recovers,
			dealt = f.dealt,
			targeted = b.target == "all" or b.target == f.key,
			me = f.key == viewerKey,
			look = life and life.look,
			appearance = life and sim:appearance(life),
		})
		if active(b, f) and not f.acted and life and life.alive then
			table.insert(waitingOn, f.name)
		end
	end
	-- (v0.19) the party's allies stand with the fighters (they act on their own: always chosen)
	local allies: { any } = {}
	for _, a: any in b.allies or {} do
		local rel: any = sim:relationById(hostLife, a.rel)
		local entry = {
			key = a.key,
			name = allyLabel(a),
			first = a.name,
			rank = a.rank,
			rankLetter = Party.letter(a.rank),
			class = a.class,
			hp = a.hp,
			maxHp = a.maxHp,
			down = a.down,
			fled = false,
			acted = true,
			steady = a.guarding == true,
			dealt = a.dealt,
			healed = a.healed,
			blocked = a.blocked,
			targeted = b.target == "all" or b.target == a.key,
			me = false,
			ally = true,
			appearance = if rel then { look = rel.look, age = rel.age, form = "human" } else nil,
		}
		table.insert(allies, entry)
		table.insert(fighters, entry)
	end
	local me: any = viewerKey and fighterOf(b, viewerKey)
	local myLife: any = viewerKey and lives[viewerKey]
	local options: { any }? = nil
	if me and active(b, me) and not me.acted and myLife and myLife.alive then
		local list: { any } = {}
		options = list
		local aimed = b.target == "all" or b.target == viewerKey
		for _, id in (sim.pack.approaches and sim.pack.approaches.order) or {} do
			local a: any = sim.pack.approaches[id]
			-- (a way of talking someone down isn't a blow: that's what the card's other choices are for)
			if a.stat and not a.bloodless and sim:approachOpen(myLife, a, { fight = true, stat = a.stat }) then
				local odds: number? = nil
				if aimed then
					local spec = strikeSpec(def, b, move, a.stat)
					if me.steady then
						spec.base = math.max(1, spec.base - 2)
					end
					local p: any = sim:clashPreview(myLife, spec)
					for _, ap: any in p.approaches or {} do
						if ap.id == id then
							odds = ap.odds
						end
					end
					odds = odds or p.odds
				end
				table.insert(list, {
					action = "strike",
					approach = id,
					name = a.name,
					stat = a.stat,
					odds = odds,
					free = not aimed,
					hit = blow(myLife, a.stat, true, not aimed, me.steady),
				})
			end
		end
		table.insert(list, { action = "guard", name = "Guard", desc = "Take less than half, and steady your next strike." })
		local extraHeal = math.floor(sim:maxHealthOf(myLife) * 0.06)
		table.insert(list, { action = "recover", name = "Patch up", desc = string.format("Heal %d to %d Health.", 10 + extraHeal, 16 + extraHeal), left = me.recovers, enabled = me.recovers > 0 })
		table.insert(list, { action = "flee", name = "Get out", desc = if aimed then "Leave the fight, taking a parting blow." else "Leave the fight." })
	end
	local marks: { number } = {}
	for _, ph in def.phases or {} do
		table.insert(marks, ph.at or 0.5)
	end
	local targetName: string? = nil
	if b.target == "all" then
		targetName = "everyone"
	elseif b.target then
		local t: any = fighterOf(b, b.target)
		local ally: any = allyOf(b, b.target)
		targetName = if t then t.name elseif ally then allyLabel(ally) else nil
	end
	local bossView: any = {
		id = b.boss,
		name = def.name,
		title = def.title,
		enemy = sim:foeFor({ enemy = def.enemy, foe = def.name }),
		hp = b.hp,
		maxHp = b.maxHp,
		phase = b.phase,
		phases = if def.phases then #def.phases + 1 else 1,
		phaseMarks = marks,
		coins = coins,
		base = base,
		coinPower = coinPower,
	}
	local nextView: any = { id = move.id, name = move.name, text = move.text, power = (move.power or 8) + phasePower, heavy = move.heavy == true, target = b.target, targetName = targetName }
	return {
		boss = bossView,
		next = nextView,
		turn = b.turn,
		fighters = fighters,
		waitingOn = waitingOn,
		options = options,
		log = b.log,
		last = b.last,
		art = b.art,
		title = b.title,
		host = tostring(hostLife.id),
		outcome = b.outcome,
		allies = if #allies > 0 then allies else nil,
	}
end

return Battle
