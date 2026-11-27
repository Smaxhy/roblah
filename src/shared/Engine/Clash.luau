--[[
	Coin clash.
	Each round both sides flip their remaining coins:
		power = base + heads * coinPower
	Higher power wins the round and the loser loses one coin. A tie re-flips.
	The side that runs out of coins loses.

	Fights add status effects. A side may carry `status = { id, potency }`.
	Every heads it lands builds its status (potency x GAIN), whether it won the round or not.
		marks (on the opponent):
			tremor   x2; at 5 it bursts and the opponent loses a coin (staggered)
			rupture  your hits land harder: +1 power per point (up to 6), -1 a round
			bleed    the opponent loses power when it lands heads (up to 5), -1 each time
			burn     the opponent loses half the burn in power (up to 3) every round, -1 a round
			sinking  x2; the opponent's heads chance drops 5% per point, -1 a round
		buffs (on yourself):
			poise    x2; each heads may crit, counting twice (15% per poise, max 75%), -1 a round
			charge   +1 a round and +1 per heads; at 4 it discharges for +(potency + 2) power

	ABILITIES (fights only; side.abilities = { { id, potency } }): what a weapon, an art or a foe
	brings besides raw power.
		a status id (bleed, burn, tremor, rupture, sinking, poise, charge): a second status,
		          built by your heads exactly like your style's
		guard     the first `potency` clashes you lose cost you no coin (a shield, a trunk)
		riposte   lose a clash with heads in it, and they lose `potency` power next clash
		crush     the first clash you win knocks off a second coin
		reach     their first clash can't take a coin from you: you were never in range
		volley    your first clash: every heads hits for 2 x potency more (a gun's opening)
		quick     you strike first when you're only half as much faster (FIRST_MARGIN / 2)
		drink     every clash you win is blood you get back (Sim heals potency each, after)
		pierce    (Sim) their base counts for `potency` less; armor doesn't help them
	Each fires as an fx tag ("pguard", "fcrush"...) for the fight screen to call out.

	SPEED (fights where both sides carry a `speed`). The faster side, by FIRST_MARGIN or more,
	strikes first, one-sided: only it flips, and nothing answers. If that power beats the slower
	side's bare base, the slower side loses a coin; if it's down to its last coin it's knocked
	off balance instead (-OFF_BALANCE power in its first clash). The slower side gets no such
	opening: it has to clash for everything. The opening is the first entry of `rounds`, marked
	`oneSided = "player" | "foe"`.
]]

local Rng = require(script.Parent.Rng)
local Util = require(script.Parent.Util)

local Clash = {}

local MAX_ROUNDS = 40

export type Side = {
	name: string,
	coins: number,
	base: number,
	coinPower: number,
	heads: number, -- heads chance in percent
	status: { id: string, potency: number }?, -- fights only
	speed: number?, -- fights only: who strikes first
	edge: string?, -- "advantage" | "resisted": the way you fight against the foe's temper
	natural: boolean?, -- fighting with the stat you lean on
	backer: string?, -- someone close stood with you (+1 coin)
	abilities: { { id: string, potency: number } }?, -- fights only (see ABILITIES above)
	quick: boolean?, -- strikes first at half the usual margin
}

Clash.MARKS = { tremor = true, rupture = true, bleed = true, burn = true, sinking = true }
Clash.BUFFS = { poise = true, charge = true }
Clash.STATUS_IDS = { "tremor", "rupture", "bleed", "burn", "sinking", "poise", "charge" }
local CAP = 20
Clash.FIRST_MARGIN = 8
local OFF_BALANCE = 2
local TREMOR_BURST = 5
local CHARGE_FULL = 4
-- how much each heads adds, times potency (tuned so every status is worth about the same)
local GAIN = { tremor = 2, rupture = 1, bleed = 1, burn = 1, sinking = 2, poise = 2 }

-- what each ability is called and does, in a line (the pack may rename them: pack.abilities)
Clash.ABILITIES = {
	guard = { name = "Guard", desc = "The first clash you lose costs you no coin." },
	riposte = { name = "Riposte", desc = "Lose a clash with heads in it, and they hit weaker next clash." },
	crush = { name = "Crush", desc = "The first clash you win knocks off a second coin." },
	reach = { name = "Reach", desc = "Their first clash can't take a coin from you." },
	volley = { name = "Volley", desc = "Your first clash: every heads hits much harder." },
	quick = { name = "Quick", desc = "You strike first even when you're only a little faster." },
	drink = { name = "Drink", desc = "Every clash you win, you drink: Health back after the fight, even past your maximum." },
	pierce = { name = "Pierce", desc = "Their base power counts for less." },
	bleed = { name = "Bleed", desc = "Your heads make them Bleed: they lose power whenever they hit." },
	burn = { name = "Burn", desc = "Your heads set them burning: they lose power every clash." },
	tremor = { name = "Tremor", desc = "Your heads shake them; enough shaking knocks a coin loose." },
	rupture = { name = "Rupture", desc = "Your heads crack their guard: your next hits land harder." },
	sinking = { name = "Sinking", desc = "Your heads drag them down: their coins land heads less." },
	poise = { name = "Poise", desc = "Your heads build Poise: heads that may count twice." },
	charge = { name = "Charge", desc = "You build Charge every clash, and spend it in one big hit." },
}

local function abilityOf(side: Side, id: string): number
	local n = 0
	for _, a in side.abilities or {} do
		if a.id == id then
			n += a.potency or 1
		end
	end
	return n
end
Clash.abilityOf = abilityOf

-- the statuses a side builds: its style's, then any its abilities add
local function statusesOf(side: Side): { { id: string, potency: number } }
	local out = {}
	if side.status then
		table.insert(out, side.status)
	end
	for _, a in side.abilities or {} do
		if Clash.MARKS[a.id] or Clash.BUFFS[a.id] then
			table.insert(out, { id = a.id, potency = math.clamp(a.potency or 1, 1, 6) })
		end
	end
	return out
end

function Clash.headsChance(sanity: number, floor: number?): number
	local h = Util.clamp(50 + sanity, 5, 95)
	if floor and h < floor then
		h = floor
	end
	return h
end

-- Builds the player's side from a stat value (0-100) plus form bonuses.
-- How a stat becomes clash power: one more coin every `coinsEvery` points (up to
-- `maxCoins`), +1 base every `baseEvery`, +1 per-heads power every `powerEvery`.
-- A content pack can override any of these in pack.clash.
Clash.DEFAULT_CURVE = { coinsEvery = 30, maxCoins = 4, baseEvery = 12, powerEvery = 40 }

function Clash.playerSide(name: string, stat: number, sanity: number, form, ignoreSanity: boolean?, curve: any?): Side
	local c = curve or Clash.DEFAULT_CURVE
	local d = Clash.DEFAULT_CURVE
	local coins = math.min(c.maxCoins or d.maxCoins, 1 + math.floor(stat / (c.coinsEvery or d.coinsEvery)))
	local base = 1 + math.floor(stat / (c.baseEvery or d.baseEvery))
	local coinPower = 2 + math.floor(stat / (c.powerEvery or d.powerEvery))
	local floor = nil
	if form then
		if form.clash then
			coins += form.clash.coins or 0
			base += form.clash.base or 0
			coinPower += form.clash.coinPower or 0
		end
		floor = form.headsFloor
	end
	local heads = if ignoreSanity then 50 else Clash.headsChance(sanity, floor)
	return { name = name, coins = math.max(1, coins), base = base, coinPower = coinPower, heads = heads }
end

-- spec.status: "bleed" or { id = "bleed", potency = 2 } (fights only)
function Clash.statusOf(raw): { id: string, potency: number }?
	if type(raw) == "string" then
		raw = { id = raw }
	end
	if type(raw) ~= "table" or not (Clash.MARKS[raw.id] or Clash.BUFFS[raw.id]) then
		return nil
	end
	return { id = raw.id, potency = math.clamp(math.floor(raw.potency or 1), 1, 6) }
end

function Clash.foeSide(spec): Side
	return {
		name = spec.foe or "Opponent",
		coins = math.max(1, spec.coins or 1),
		base = spec.base or 2,
		coinPower = spec.coinPower or 2,
		heads = Clash.headsChance(spec.sanity or 0),
		status = if spec.fight then Clash.statusOf(spec.status) else nil,
	}
end

local function flip(st, count: number, heads: number)
	local flips = table.create(count)
	local n = 0
	for i = 1, count do
		local h = Rng.next(st) < heads / 100
		flips[i] = h
		if h then
			n += 1
		end
	end
	return flips, n
end

-- who strikes first, one-sided: "player", "foe", or nil when neither is clearly faster
function Clash.firstStrike(player: Side, foe: Side): string?
	if not (player.speed and foe.speed) then
		return nil
	end
	local pm = if player.quick then Clash.FIRST_MARGIN / 2 else Clash.FIRST_MARGIN
	local fm = if foe.quick then Clash.FIRST_MARGIN / 2 else Clash.FIRST_MARGIN
	if player.speed >= foe.speed + pm then
		return "player"
	elseif foe.speed >= player.speed + fm then
		return "foe"
	end
	return nil
end

local function newState(side: Side)
	local list = statusesOf(side)
	local chargeP = nil
	for _, s in list do
		if s.id == "charge" then
			chargeP = math.max(chargeP or 0, s.potency)
		end
	end
	return {
		off = 0, -- knocked off balance: power lost in the next clash
		coins = side.coins,
		start = side.coins,
		marks = { tremor = 0, rupture = 0, bleed = 0, burn = 0, sinking = 0 }, -- marks ON this side
		poise = 0,
		charge = 0,
		statuses = list,
		chargeP = chargeP,
		guard = abilityOf(side, "guard"),
		riposte = abilityOf(side, "riposte"),
		crush = if abilityOf(side, "crush") > 0 then 1 else 0,
		reach = abilityOf(side, "reach") > 0,
		volley = abilityOf(side, "volley"),
		won = 0, -- clashes won (drink heals by them)
	}
end

local function snapshot(state)
	local out = nil
	for id, n in state.marks do
		if n > 0 then
			out = out or {}
			out[id] = n
		end
	end
	if state.poise > 0 then
		out = out or {}
		out.poise = state.poise
	end
	if state.charge > 0 then
		out = out or {}
		out.charge = state.charge
	end
	return out
end

-- One side's power this round, after its own buffs and the marks on it and on its opponent.
local function powerOf(st, side: Side, me, other, heads: number, fx, tag: string)
	local power = side.base + heads * side.coinPower
	-- poise: each heads may crit
	if me.poise > 0 then
		local chance = math.min(0.75, me.poise * 0.15)
		for _ = 1, heads do
			if Rng.next(st) < chance then
				power += side.coinPower
				table.insert(fx, tag .. "crit")
			end
		end
		me.poise -= 1
	end
	-- charge: a full charge discharges into this round
	if me.charge >= CHARGE_FULL and me.chargeP then
		me.charge -= CHARGE_FULL
		power += me.chargeP + 2
		table.insert(fx, tag .. "discharge")
	end
	-- rupture on the opponent: my hits land harder
	if other.marks.rupture > 0 and heads > 0 then
		power += math.min(other.marks.rupture, 6)
		other.marks.rupture -= 1
	end
	-- bleed on me: it costs me when I act
	if me.marks.bleed > 0 and heads > 0 then
		power -= math.min(me.marks.bleed, 5)
		me.marks.bleed -= 1
		table.insert(fx, tag .. "bleed")
	end
	-- burn on me: every round
	if me.marks.burn > 0 then
		power -= math.min(3, math.ceil(me.marks.burn / 2))
		me.marks.burn -= 1
		table.insert(fx, tag .. "burn")
	end
	return math.max(0, power)
end

-- Each heads leaves a mark on the opponent (or builds a buff), whether or not the round was won.
local function applyStatus(_side: Side, me, other, heads: number, _won: boolean, fx, tag: string, otherTag: string)
	for _, status in me.statuses do
		local id, potency = status.id, status.potency
		if id == "charge" then
			me.charge = math.min(CAP, me.charge + 1 + heads)
		elseif heads > 0 then
			local gain = heads * potency * (GAIN[id] or 1)
			if id == "poise" then
				me.poise = math.min(CAP, me.poise + gain)
			elseif Clash.MARKS[id] then
				other.marks[id] = math.min(CAP, other.marks[id] + gain)
				if id == "tremor" and other.marks.tremor >= TREMOR_BURST then
					other.marks.tremor = 0
					if other.coins > 0 then
						other.coins -= 1
						table.insert(fx, otherTag .. "burst")
					end
				end
			end
		end
	end
end

-- a clash lost: the loser's reach (first clash) and guard turn it aside; otherwise a coin goes,
-- and the winner's crush may take a second
local function hit(win, loser, wtag: string, ltag: string, fx, firstClash: boolean)
	win.won += 1
	if firstClash and loser.reach then
		table.insert(fx, ltag .. "reach")
		return
	end
	if loser.guard > 0 then
		loser.guard -= 1
		table.insert(fx, ltag .. "guard")
		return
	end
	loser.coins -= 1
	if win.crush > 0 and loser.coins > 0 then
		loser.coins -= 1
		win.crush = 0
		table.insert(fx, wtag .. "crush")
	end
end

-- st: any table with an .rng field (a life, or a scratch state)
function Clash.resolve(st, player: Side, foe: Side)
	local P, F = newState(player), newState(foe)
	local statuses = #P.statuses > 0 or #F.statuses > 0
	local firstClash = true
	local rounds = {}
	local guard = 0
	-- the first strike: the faster side attacks before the clashing starts
	local first = Clash.firstStrike(player, foe)
	if first then
		local A, AS, D, DS = player, P, foe, F
		if first == "foe" then
			A, AS, D, DS = foe, F, player, P
		end
		local flips, heads = flip(st, AS.coins, math.clamp(A.heads, 5, 95))
		local power = A.base + heads * A.coinPower
		local landed = power > D.base
		local fx = { (if first == "player" then "p" else "f") .. "first" }
		if landed then
			if DS.coins > 1 then
				DS.coins -= 1
			else
				DS.off = OFF_BALANCE
				table.insert(fx, (if first == "player" then "f" else "p") .. "offbalance")
			end
		end
		table.insert(rounds, {
			oneSided = first,
			p = if first == "player" then flips else {},
			f = if first == "foe" then flips else {},
			pPower = if first == "player" then power else D.base,
			fPower = if first == "foe" then power else D.base,
			winner = if landed then first else "tie",
			pCoins = P.coins,
			fCoins = F.coins,
			fx = fx,
		})
	end
	while P.coins > 0 and F.coins > 0 and guard < MAX_ROUNDS do
		guard += 1
		local fx = {}
		local pHeadsChance = math.clamp(player.heads - P.marks.sinking * 5, 5, 95)
		local fHeadsChance = math.clamp(foe.heads - F.marks.sinking * 5, 5, 95)
		local pFlips, pHeads = flip(st, P.coins, pHeadsChance)
		local fFlips, fHeads = flip(st, F.coins, fHeadsChance)
		local pPower, fPower
		if statuses then
			pPower = powerOf(st, player, P, F, pHeads, fx, "p")
			fPower = powerOf(st, foe, F, P, fHeads, fx, "f")
			P.marks.sinking = math.max(0, P.marks.sinking - 1)
			F.marks.sinking = math.max(0, F.marks.sinking - 1)
		else
			pPower = player.base + pHeads * player.coinPower
			fPower = foe.base + fHeads * foe.coinPower
		end
		-- volley: a gun's opening, the first clash only
		if firstClash then
			if P.volley > 0 and pHeads > 0 then
				pPower += pHeads * P.volley * 2
				table.insert(fx, "pvolley")
			end
			if F.volley > 0 and fHeads > 0 then
				fPower += fHeads * F.volley * 2
				table.insert(fx, "fvolley")
			end
		end
		if P.off > 0 then
			pPower = math.max(0, pPower - P.off)
			P.off = 0
		end
		if F.off > 0 then
			fPower = math.max(0, fPower - F.off)
			F.off = 0
		end
		local winner = "tie"
		if pPower > fPower then
			winner = "player"
			hit(P, F, "p", "f", fx, firstClash)
			-- riposte: lost, but it landed something; they pay for it next clash
			if F.riposte > 0 and fHeads > 0 then
				P.off = math.max(P.off, F.riposte)
				table.insert(fx, "friposte")
			end
		elseif fPower > pPower then
			winner = "foe"
			hit(F, P, "f", "p", fx, firstClash)
			if P.riposte > 0 and pHeads > 0 then
				F.off = math.max(F.off, P.riposte)
				table.insert(fx, "priposte")
			end
		end
		if winner ~= "tie" then
			firstClash = false
		end
		if statuses then
			applyStatus(player, P, F, pHeads, winner == "player", fx, "p", "f")
			applyStatus(foe, F, P, fHeads, winner == "foe", fx, "f", "p")
		end
		table.insert(rounds, {
			p = pFlips,
			f = fFlips,
			pPower = pPower,
			fPower = fPower,
			winner = winner,
			pCoins = P.coins,
			fCoins = F.coins,
			pStatus = if statuses then snapshot(P) else nil,
			fStatus = if statuses then snapshot(F) else nil,
			fx = if #fx > 0 then fx else nil,
		})
	end
	local won = P.coins > 0 and F.coins == 0
	if P.coins > 0 and F.coins > 0 then
		won = P.coins > F.coins
	end
	return { won = won, rounds = rounds, player = player, foe = foe, pWon = P.won, fWon = F.won }
end

-- Rough win chance for the UI, using a throwaway RNG so the life's RNG is untouched.
-- Deterministic per matchup, so results are cached.
local estimateCache = {}
local cacheSize = 0

function Clash.estimate(player: Side, foe: Side, samples: number?): number
	samples = samples or 300
	local ps, fs = player.status, foe.status
	local function abil(side: Side): string
		local parts = {}
		for _, a in side.abilities or {} do
			table.insert(parts, a.id .. (a.potency or 1))
		end
		return table.concat(parts, "+") .. (if side.quick then "q" else "")
	end
	local key = table.concat({
		abil(player), abil(foe),
		player.coins, player.base, player.coinPower, player.heads,
		foe.coins, foe.base, foe.coinPower, foe.heads, samples,
		if ps then ps.id .. ps.potency else "-", if fs then fs.id .. fs.potency else "-",
		Clash.firstStrike(player, foe) or "-",
	}, ",")
	local cached = estimateCache[key]
	if cached then
		return cached
	end
	local st = { rng = Rng.seed(player.base * 7919 + foe.base * 104729 + player.heads * 31 + foe.coins * 17 + 1) }
	local wins = 0
	for _ = 1, samples do
		if Clash.resolve(st, player, foe).won then
			wins += 1
		end
	end
	local p = wins / samples
	if cacheSize > 20000 then
		estimateCache = {}
		cacheSize = 0
	end
	estimateCache[key] = p
	cacheSize += 1
	return p
end

return Clash
