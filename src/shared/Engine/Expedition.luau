--[[
	Expeditions: missions, dungeons and trips. A run moves through stages; each
	stage is a card with choices, like an event. The same code runs a solo run and
	a crew run (several players' lives at once):

	* the captain (the first life in the list) makes the choices,
	* every member gets each stage's results in their own life,
	* clashes are fought by the crew's champion for that stat (whoever is best at
	  it), with +1 coin for each other member (up to +3).

	A run is a plain table: { id, stage, steps, size, outcome }. A solo run is kept
	in life.run (so it survives a rejoin); a crew run is kept by the server and
	each member's life gets life.run = { id, crew = true } so other actions wait.

		local run, reports = Expedition.start(sim, lives, id)
		local card = Expedition.view(sim, lives, run)
		local reports, clash = Expedition.choose(sim, lives, run, index, approach)
]]

local Rng = require(script.Parent.Rng)
local Clash = require(script.Parent.Clash)
local Conditions = require(script.Parent.Conditions)
local Effects = require(script.Parent.Effects)

local Expedition = {}

local MAX_STEPS = 24
local MAX_ASSIST = 3

function Expedition.def(sim, id: string)
	local list = sim.pack.expeditions
	return list and list[id]
end

-- visible, enabled, reason for one life
function Expedition.state(sim, life, id: string): (boolean, boolean, string?)
	local def = Expedition.def(sim, id)
	if not def then
		return false, false, nil
	end
	if def.minAge and life.age < def.minAge then
		return false, false, nil
	end
	if def.maxAge and life.age > def.maxAge then
		return false, false, nil
	end
	if not Conditions.check(def.when, life, sim.pack, { noChance = true }) then
		return false, false, nil
	end
	if not life.alive then
		return true, false, "This life is over"
	end
	if life.pending then
		return true, false, "Decide first"
	end
	if life.run then
		return true, false, "Already out on one"
	end
	if (def.actions or 1) > life.actionsLeft then
		return true, false, "No actions left this year"
	end
	if (def.cost or 0) > 0 and life.money < def.cost then
		return true, false, "Needs " .. def.cost .. " " .. sim.pack.meta.currency
	end
	local last = life.expUsed and life.expUsed[id]
	if def.cooldown and last and life.age - last < def.cooldown then
		local wait = def.cooldown - (life.age - last)
		return true, false, "Again in " .. wait .. (if wait == 1 then " year" else " years")
	end
	return true, true, nil
end

-- (v0.18) THE HARDER THE RUN, THE RICHER THE HAUL. A run's tier comes from the strongest
-- thing in it: the highest base + coins of any clash in its stages, or a boss battle (tier 5).
-- pack.expeditionPay.tiers = { base + coins for tier 2, 3, 4, 5 }; pack.expeditionPay[tier] multiplies
-- what a success pays (money, wages, renown, stat gains) and adds its own bonus on top.
local ROMAN = { "I", "II", "III", "IV", "V" }

function Expedition.tier(sim, def): number
	if type(def) ~= "table" then
		return 1
	end
	sim.expeditionTiers = sim.expeditionTiers or setmetatable({}, { __mode = "k" })
	local cached = sim.expeditionTiers[def]
	if cached then
		return cached
	end
	local top = 0
	local boss = false
	for _, stage in def.stages or {} do
		for _, c in (type(stage) == "table" and stage.choices) or {} do
			if type(c) == "table" then
				if type(c.clash) == "table" and type(c.clash.base) == "number" then
					top = math.max(top, c.clash.base + (tonumber(c.clash.coins) or 1))
				end
				if c.battle then
					boss = true
				end
			end
		end
	end
	local cfg = sim.pack.expeditionPay
	local tier = 1
	if boss then
		tier = 5
	elseif cfg and cfg.tiers then
		for i, need in cfg.tiers do
			if top >= need then
				tier = i + 1
			end
		end
	end
	sim.expeditionTiers[def] = tier
	return tier
end

local STAT_SKIP = { health = true, sanity = true, money = true, wage = true, renown = true }

-- what a success pays at this tier: a copy of the result, multiplied; and the bonus on top
local function richer(sim, result: any, pay: any): any
	local r = table.clone(result)
	local function mul(v: any, m: number): any
		if type(v) == "number" then
			return if v > 0 then math.floor(v * m + 0.5) else v
		elseif type(v) == "table" and type(v[1]) == "number" and type(v[2]) == "number" then
			return { if v[1] > 0 then math.floor(v[1] * m + 0.5) else v[1], if v[2] > 0 then math.floor(v[2] * m + 0.5) else v[2] }
		end
		return v
	end
	for _, k in { "money", "wage" } do
		if r[k] ~= nil then
			r[k] = mul(r[k], pay.money or 1)
		end
	end
	if r.renown ~= nil then
		r.renown = mul(r.renown, pay.renown or 1)
	end
	for k in sim.pack.stats or {} do
		if type(k) == "string" and k ~= "order" and not STAT_SKIP[k] and r[k] ~= nil then
			r[k] = mul(r[k], pay.stats or 1)
		end
	end
	return r
end

-- The expeditions a life can see, for the Activities sheet.
function Expedition.list(sim, life)
	local out = {}
	local pack = sim.pack
	for _, id in (pack.expeditions and pack.expeditions.order) or {} do
		local visible, enabled, why = Expedition.state(sim, life, id)
		if visible then
			local def = pack.expeditions[id]
			table.insert(out, {
				id = id,
				kind = def.kind or "mission",
				-- (v0.13) places are found in the world (an entrance card, a quest, a story);
				-- the DO tab lists only the ones this life knows
				-- (one that a story, a job or the City itself opened is known already)
				found = def.open == true or life.flags["found_" .. id] == true or (life.expUsed ~= nil and life.expUsed[id] ~= nil)
					or (def.when ~= nil and (def.when.flags ~= nil or def.when.career ~= nil or def.when.worldEvent ~= nil)),
				purpose = def.purpose,
				name = sim:render(life, def.name),
				desc = sim:render(life, def.desc) .. (function()
					-- (v0.18) a hard run says what it's worth
					local tier = Expedition.tier(sim, def)
					local pay = pack.expeditionPay and pack.expeditionPay[tier]
					if tier >= 3 and pay then
						return string.format("  Tier %s: pays %sx, with a bonus haul.", ROMAN[tier] or tostring(tier), tostring(pay.money or 1))
					end
					return ""
				end)(),
				tier = Expedition.tier(sim, def),
				cost = def.cost or 0,
				crewMin = (def.crew and def.crew.min) or 1,
				crewMax = (def.crew and def.crew.max) or 1,
				stages = def.length or nil,
				enabled = enabled,
				reason = why,
			})
		end
	end
	return out
end

local function tokens(lives, champion)
	local captain = lives[1]
	local names = {}
	for _, l in lives do
		table.insert(names, l.first)
	end
	return {
		crew = if #lives > 1 then "your crew" else "you",
		crewNames = table.concat(names, ", "),
		champion = if champion then champion.first else captain.first,
	}
end

-- the member best at a stat fights for the crew
local function champion(lives, stat: string)
	local best, bestValue = nil, -1
	for _, l in lives do
		if l.alive then
			local v = l.stats[stat] or 0
			if v > bestValue then
				best, bestValue = l, v
			end
		end
	end
	return best or lives[1]
end

local function crewSides(sim, lives, spec, approachId)
	local champ = champion(lives, spec.stat)
	local player, foe = sim:clashSides(champ, spec, approachId)
	local alive = 0
	for _, l in lives do
		if l.alive then
			alive += 1
		end
	end
	local assist = math.min(MAX_ASSIST, math.max(0, alive - 1))
	if assist > 0 then
		player.coins += assist
		player.name = champ.first .. " & crew"
	end
	return player, foe, champ
end

-- a requirement passes if anyone in the crew meets it
local function crewMeets(sim, lives, requires)
	if not requires then
		return true, nil
	end
	local why = nil
	for _, l in lives do
		if l.alive then
			local ok, reason = Conditions.check(requires, l, sim.pack, { noChance = true })
			if ok then
				return true, nil
			end
			why = why or reason
		end
	end
	return false, why
end

-- opts.free: entered from the world (an event's result.expedition): no action, no fee
function Expedition.start(sim, lives, id: string, opts: any?)
	local def = Expedition.def(sim, id)
	if not def then
		return nil, "No such expedition."
	end
	local crewMin = (def.crew and def.crew.min) or 1
	local crewMax = (def.crew and def.crew.max) or 1
	if #lives < crewMin then
		return nil, "Needs a crew of at least " .. crewMin .. "."
	end
	if #lives > crewMax then
		return nil, if crewMax == 1 then "This one is for one person." else ("At most " .. crewMax .. " can go.")
	end
	for _, l in lives do
		local _, enabled, why = Expedition.state(sim, l, id)
		if not enabled then
			return nil, (if #lives > 1 then l.first .. ": " else "") .. (why or "Not available.")
		end
	end
	local run = { id = id, stage = def.start, steps = 0, size = #lives, outcome = nil, startFort = {} }
	local reports = {}
	for i, l in lives do
		run.startFort[i] = l.stats[sim.vital]
		if not (opts and opts.free) then
			l.actionsLeft -= def.actions or 1
			if (def.cost or 0) > 0 then
				l.money -= def.cost
			end
		end
		-- (v0.13) a place you've been is a place you know
		l.flags["found_" .. id] = true
		l.expUsed = l.expUsed or {}
		l.expUsed[id] = l.age
		l.run = if #lives > 1 then { id = id, crew = true } else run
		local report = sim.newReport()
		sim:push(l, report, { kind = "event", title = "Set out: " .. sim:render(l, def.name), text = sim:render(l, def.desc) })
		reports[i] = report
	end
	-- (v0.12) linked friends see it too: setting out, each fight, how it ended
	if lives[1] then
		sim:news(lives[1], lives[1].first .. " set out on an expedition: " .. sim:render(lives[1], def.name) .. (if #lives > 1 then ", with a crew." else "."))
	end
	return run, reports
end

-- The stage card for the crew (or one player).
function Expedition.view(sim, lives, run)
	local def = Expedition.def(sim, run.id)
	if not def then
		return nil
	end
	local captain = lives[1]
	local out = {
		id = run.id,
		kind = def.kind or "mission",
		purpose = def.purpose,
		length = def.length,
		depthWord = def.depthWord,
		name = sim:render(captain, def.name),
		step = run.steps + 1,
		crew = #lives > 1,
		members = {},
		outcome = run.outcome,
	}
	for _, l in lives do
		table.insert(out.members, { first = l.first, last = l.last, alive = l.alive })
	end
	local stage = def.stages[run.stage]
	if run.outcome or not stage then
		return out
	end
	local tok = tokens(lives, nil)
	local choices = {}
	for i, c in stage.choices do
		local ok, why = crewMeets(sim, lives, c.requires)
		local entry = {
			index = i,
			label = sim:render(captain, c.label, tok),
			hint = if c.hint then sim:render(captain, c.hint, tok) else nil,
			enabled = ok,
			reason = why,
		}
		if c.clash and ok then
			local player, foe, champ = crewSides(sim, lives, c.clash, nil)
			local stat = sim.pack.stats[c.clash.stat]
			entry.clash = {
				stat = c.clash.stat,
				statName = if stat then stat.name else c.clash.stat,
				player = player,
				foe = foe,
				odds = Clash.estimate(player, foe),
				champion = champ.first,
				approaches = {},
			}
			local approaches = sim.pack.approaches
			for _, aid in (approaches and approaches.order) or {} do
				-- only the ways the one leading this clash can actually go in (E.G.O needs one)
				if sim:approachOpen(champ, approaches[aid], c.clash) then
					local p = crewSides(sim, lives, c.clash, aid)
					local cost = sim:approachCost(champ, approaches[aid])
					table.insert(entry.clash.approaches, {
						id = aid,
						name = approaches[aid].name,
						desc = approaches[aid].desc,
						odds = Clash.estimate(p, foe),
						sanityCost = if cost > 0 then cost else nil,
						color = approaches[aid].color,
					})
				end
			end
		end
		table.insert(choices, entry)
	end
	out.stage = {
		id = run.stage,
		title = sim:render(captain, stage.title, tok),
		text = sim:render(captain, stage.text, tok),
		tone = stage.tone,
		choices = choices,
	}
	return out
end

local function finish(sim, lives, run, outcome: string, reports)
	local def = Expedition.def(sim, run.id)
	run.outcome = outcome
	local result = if outcome == "success" then def.success elseif outcome == "fail" then def.fail else def.retreat
	-- coming home: crews patch each other up (half of what the run cost on a success,
	-- a third if they turned back, nothing if it went wrong)
	local mend = if outcome == "success" then 0.5 elseif outcome == "retreat" then 0.34 else 0
	for i, l in lives do
		local before = run.startFort and run.startFort[i]
		local vital = sim.vital
		if l.alive and before and mend > 0 and l.stats[vital] < before then
			local back = math.floor((before - l.stats[vital]) * mend + 0.5)
			if back > 0 then
				local beforeN: number = tonumber(before) or 0
				l.stats[vital] = math.min(math.max(beforeN, sim:maxHealthOf(l)), l.stats[vital] + back)
				sim:push(l, reports[i], { kind = "log", text = "You patched each other up on the way home.", deltas = { [vital] = back } })
			end
		end
	end
	-- (v0.18) a hard run pays like one
	local tier = Expedition.tier(sim, def)
	local pay = sim.pack.expeditionPay and sim.pack.expeditionPay[tier]
	if outcome == "success" and result and pay then
		result = richer(sim, result, pay)
	end
	for i, l in lives do
		if l.alive then
			local tok = tokens(lives, nil)
			if result then
				Effects.apply(sim, l, result, reports[i], tok)
			end
			if outcome == "success" and pay and pay.bonus then
				local b = table.clone(pay.bonus)
				if b.limitBreakFight then
					b.limitBreak = { [sim.roles.fight or "strength"] = b.limitBreakFight }
					b.limitBreakFight = nil
				end
				b.log = string.format("A tier %s haul: what a run like that is worth.", ROMAN[tier] or tostring(tier))
				Effects.apply(sim, l, b, reports[i], tok)
			end
			if outcome == "success" then
				sim:tally(l, "expeditions")
				l.flags["done_" .. run.id] = true -- quests can wait on this
				sim:news(l, l.first .. " came back from " .. sim:render(l, def.name) .. (if #lives > 1 then " with a crew." else "."))
			elseif outcome == "fail" then
				sim:news(l, l.first .. "'s expedition went wrong: " .. sim:render(l, def.name) .. ".")
			else
				sim:news(l, l.first .. " turned back from " .. sim:render(l, def.name) .. ".")
			end
			sim:push(l, reports[i], {
				kind = "system",
				tone = if outcome == "success" then "good" elseif outcome == "fail" then "bad" else nil,
				text = (if outcome == "success" then "Expedition complete: " elseif outcome == "fail" then "Expedition failed: " else "Turned back: ") .. sim:render(l, def.name) .. ".",
				celebrate = if outcome == "success" then "expedition" else nil,
			})
		end
		l.run = nil
		if l.alive then
			sim:checkAmbitions(l, reports[i])
			sim:advance(l, reports[i])
		end
	end
end

-- Resolves the captain's choice for everyone. Returns reports (one per life) and the clash, if any.
function Expedition.choose(sim, lives, run, index: number, approachId: string?)
	local def = Expedition.def(sim, run.id)
	if not def or run.outcome then
		return nil, "This expedition is over."
	end
	local stage = def.stages[run.stage]
	local choice = stage and stage.choices[index]
	if not choice then
		return nil, "That isn't an option."
	end
	local ok, why = crewMeets(sim, lives, choice.requires)
	if not ok then
		return nil, why
	end
	local approaches = sim.pack.approaches
	if approachId and not (approaches and approaches[approachId]) then
		approachId = nil
	end
	local captain = lives[1]
	local reports = {}
	local tok = tokens(lives, nil)
	for i, l in lives do
		reports[i] = sim.newReport()
		if l.alive then
			sim:push(l, reports[i], { kind = "event", title = sim:render(captain, stage.title, tok), choice = sim:render(captain, choice.label, tok) })
		end
	end
	local nextId, ending = choice.next, choice["end"]
	local clashReport = nil
	if choice.clash then
		-- an approach the one leading can't take (no E.G.O to let out, say) is no approach
		if approachId and not sim:approachOpen(champion(lives, choice.clash.stat), approaches[approachId], choice.clash) then
			approachId = nil
		end
		local player, foe, champ = crewSides(sim, lives, choice.clash, approachId)
		local res = Clash.resolve(champ, player, foe)
		clashReport = { won = res.won, rounds = res.rounds, player = res.player, foe = res.foe, stat = choice.clash.stat, approach = approachId }
		local after = tokens(lives, champ)
		for i, l in lives do
			if l.alive then
				reports[i].clash = clashReport
				sim:push(l, reports[i], {
					kind = "clash",
					won = res.won,
					text = (if res.won then "Won a clash against " else "Lost a clash against ") .. res.foe.name .. (if #lives > 1 then " (" .. champ.first .. " led)." else "."),
				})
				Effects.apply(sim, l, if res.won then choice.win else choice.lose, reports[i], after)
			end
		end
		if captain.alive then
			sim:news(captain, string.format("%s, on %s: %s %s.", captain.first, sim:render(captain, def.name), if res.won then "beat" else "lost to", res.foe.name))
		end
		sim:tally(champ, if res.won then "clashesWon" else "clashesLost")
		local approach = approachId and approaches[approachId]
		if approach and approach.after and champ.alive then
			local i = table.find(lives, champ) or 1
			Effects.apply(sim, champ, approach.after, reports[i])
		end
		-- what the approach costs the mind of whoever led (E.G.O)
		local cost = sim:approachCost(champ, approach)
		if cost > 0 and champ.alive then
			local i = table.find(lives, champ) or 1
			Effects.apply(sim, champ, { sanity = -cost, log = approach.costLog or ("It cost you " .. cost .. " Sanity.") }, reports[i])
		end
		if res.won then
			nextId = choice.winNext or choice.next
			ending = choice.winEnd or choice["end"]
		else
			nextId = choice.loseNext or choice.next
			ending = choice.loseEnd or choice["end"]
		end
	else
		for i, l in lives do
			if l.alive then
				Effects.apply(sim, l, choice.result, reports[i], tok)
			end
		end
	end
	run.steps += 1
	-- the dead leave the crew; their life is over
	local alive = 0
	for _, l in lives do
		if l.alive then
			alive += 1
		else
			l.run = nil
		end
	end
	if alive == 0 then
		run.outcome = "fail"
	elseif ending or not nextId or not def.stages[nextId] or run.steps >= MAX_STEPS then
		finish(sim, lives, run, ending or "success", reports)
	else
		run.stage = nextId
	end
	return reports, clashReport
end

-- A crew run's lives went away (server restart, everyone left): clear the markers.
function Expedition.abandon(lives)
	for _, l in lives do
		l.run = nil
	end
end

-- random pick helper for content that wants it (kept here so stages stay data)
Expedition.pick = Rng.pick

return Expedition
