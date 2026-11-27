--[[
	Applies a result table (see docs/CONTENT_GUIDE.md) to a life.
	All state changes go through the engine's helpers so logging, clamping,
	breaking points and deaths are handled in one place.
]]

local Rng = require(script.Parent.Rng)
local Util = require(script.Parent.Util)
local Renown = require(script.Parent.Renown)
local Training = require(script.Parent.Training)

local Effects = {}


--[[ THE SUMS. What a number in a result comes to for one life is worked out here and nowhere
	else, so the chips on a card (Effects.preview) can't disagree with what the life is given
	(Effects.apply): both call these.

	`chance(p)` settles the leftover fractions: apply rolls for them; a preview asks for the
	least (never) and the most (always). ]]

-- A rolled change `d` to a stat, as it lands on this life (before the 0-100 walls).
-- ctx.training (a quick study's bonus) goes to the first gain and is then spent (ctx.trained).
-- Returns the change, and for a loss of health the multiplier it was taken at.
function Effects.statDelta(engine, life, key: string, d: number, ctx, chance: (number) -> boolean): (number, number?)
	local vital = engine.vital
	local pk = engine.pack
	local before = life.stats[key]
	local hitMult: number? = nil
	-- a quick study learns more from what they set out to do (ctx.training, once)
	if d > 0 and key ~= vital and type(ctx.training) == "number" and not ctx.trained then
		d += ctx.training
		ctx.trained = true
	end
	if d > 0 then
		-- talents that make you learn faster (trait.growth)
		local g = engine:growthOf(life, key)
		if g ~= 1 then
			d = math.max(1, math.floor(d * g + 0.5))
		end
		-- children grow slower (pack.childGrowth), and everyone slows down past
		-- pack.slowFrom (pack.slowScale); leftover fractions round by chance
		-- (Fortitude is health, not a skill: heals are never scaled)
		local scale = 1
		if key ~= vital then
			if pk.childGrowth and life.age < 13 then
				scale *= pk.childGrowth
			end
			if pk.slowFrom and before >= pk.slowFrom then
				scale *= pk.slowScale or 1
			end
			-- more to do in a year, a little less from each thing (pack.activityGrowth)
			if ctx.activity and pk.activityGrowth then
				scale *= pk.activityGrowth
			end
		end
		if scale ~= 1 then
			local x = d * scale
			local whole = math.floor(x)
			d = whole + (if chance(x - whole) then 1 else 0)
		end
	elseif d < 0 and key == vital then
		-- the City is deadly (pack.lethality) to adults; children get pack.youthLethality
		-- (until pack.meta.adultAge); some people are harder to kill (toughness)
		local young = life.age < ((pk.meta and pk.meta.adultAge) or 18)
		local mult = (if young then (pk.youthLethality or 1) else (pk.lethality or 1)) * engine:toughnessOf(life)
		local diff = engine:difficultyDef(life)
		if diff then
			mult *= diff.lethality or 1
		end
		if mult ~= 1 then
			d = -math.max(1, math.floor(-d * mult + 0.5))
		end
		hitMult = mult
	end
	-- diminishing returns: gains slow down as a stat gets high
	if d > 0 and key ~= vital then
		if before >= 90 then
			d = if chance(0.25) then 1 else 0
		elseif before >= 80 then
			d = if chance(0.5) then 1 else 0
		elseif before >= 60 then
			d = math.max(1, math.floor(d / 2))
		end
	end
	return d, hitMult
end

-- A rolled change to the bond with someone. Charisma: time spent on someone goes further
-- (+1 per 25, by chance for the rest).
function Effects.bondDelta(engine, life, d: number, chance: (number) -> boolean, charm: number?): number
	if d > 0 and engine.roles.charm then
		-- (v0.17) Charisma as it was when the choice was offered (a choice that also raises it
		-- doesn't make its own bond bigger than its chip said)
		local x = (charm or engine:charmOf(life)) / 25
		d += math.floor(x) + (if chance(x - math.floor(x)) then 1 else 0)
	end
	return d
end

-- What a result's money comes to, the rolled part aside: pay by the year (paycheck) and pay
-- that follows the District (wage, already rolled).
function Effects.payOf(engine, life, result, wageRoll: number?): number
	local d = 0
	if result.paycheck and life.career then
		d += math.floor(engine:salaryOf(life) * result.paycheck + 0.5)
	end
	if wageRoll ~= nil then
		d += math.floor(wageRoll * engine:wageMult(life) + 0.5)
	end
	return d
end

local function lowOf(v: any): number
	if type(v) == "table" then
		return math.min(math.floor(v[1]), math.floor(v[2]))
	end
	return if type(v) == "number" then v else 0
end
local function highOf(v: any): number
	if type(v) == "table" then
		return math.max(math.floor(v[1]), math.floor(v[2]))
	end
	return if type(v) == "number" then v else 0
end

--[[ WHAT A RESULT WOULD DO to this life, right now: { [key] = { min, max } } for every stat it
	touches, Sanity, money (with pay) and, when ctx.target is someone, the bond with them. The
	same sums as apply, with every roll at its least and then at its most. Nothing is changed.
	ctx: { activity = true, training = n, target = relation } as apply would be given. ]]
function Effects.preview(engine, life, result, extraCtx)
	local out: { [string]: { min: number, max: number } } = {}
	if type(result) ~= "table" then
		return out
	end
	local function note(key: string, n: number)
		local have = out[key]
		if have then
			have.min = math.min(have.min, n)
			have.max = math.max(have.max, n)
		else
			out[key] = { min = n, max = n }
		end
	end
	for pass = 1, 2 do
		local high = pass == 2
		local pick = if high then highOf else lowOf
		local chance = if high
			then function(p: number): boolean
				return p > 1e-9
			end
			else function(p: number): boolean
				return p >= 1
			end
		local ctx = { activity = extraCtx and extraCtx.activity, training = extraCtx and extraCtx.training, trained = false }
		for _, key in engine.coreStats do
			local v = result[key]
			if v ~= nil then
				local before = life.stats[key]
				local d = Effects.statDelta(engine, life, key, pick(v), ctx, chance)
				local cap = engine:statCap(life, key, if key == engine.vital then result.overheal else nil)
				note(key, Util.clamp(before + d, 0, math.max(cap, if d > 0 then before else 0)) - before)
			end
		end
		if result.sanity ~= nil then
			local cfg = engine.pack.stats.sanity
			local d = engine:sanityDelta(life, pick(result.sanity))
			note("sanity", Util.clamp(life.sanity + d, cfg.min, cfg.max) - life.sanity)
		end
		local target = extraCtx and extraCtx.target
		if result.bond ~= nil and type(target) == "table" and target.alive then
			local d = Effects.bondDelta(engine, life, pick(result.bond), chance)
			note("bond", Util.clamp(target.bond + d, 0, 100) - target.bond)
		end
		if result.money ~= nil or result.wage ~= nil or (result.paycheck and life.career) then
			note("money", pick(result.money) + Effects.payOf(engine, life, result, if result.wage ~= nil then pick(result.wage) else nil))
		end
	end
	return out
end

-- extraCtx: optional extra text tokens (e.g. { sender = "Ossa" } for linked effects)
function Effects.apply(engine, life, result, report, extraCtx)
	if result == nil or not life.alive then
		return
	end
	local pack = engine.pack
	local deltas = {}
	local extra = {} -- system lines logged after the main line
	local charmBefore = if engine.roles.charm then engine:charmOf(life) else nil
	local ctx = {}
	if extraCtx then
		for k, v in extraCtx do
			ctx[k] = v
		end
	end
	local function chance(p: number): boolean
		return Rng.chance(life, p)
	end
	-- (v0.18) pay is what the wage was when the work was done: a stat this same result raises
	-- (into a tier whose perk pays more) counts from the next payday, as the card promised
	local salaryNow = if result.paycheck and life.career then engine:salaryOf(life) else 0
	-- (v0.18) and a Sanity loss is softened by what you were when it hit: a stat this same result
	-- raises (into a tier whose perk guards Sanity) guards from the next blow, as promised
	local sanityGuardNow = if result.sanity ~= nil then engine:perkSum(life, "sanityGuard") else 0

	for _, key in engine.coreStats do
		local v = result[key]
		if v ~= nil then
			local before = life.stats[key]
			local d, hitMult = Effects.statDelta(engine, life, key, Rng.roll(life, v), ctx, chance)
			if hitMult then
				-- kept for the death report
				life.lastHit = { amount = -d, before = before, mult = hitMult }
			end
			if d ~= 0 then
				local cap = engine:statCap(life, key, if key == engine.vital then result.overheal else nil)
				life.stats[key] = Util.clamp(before + d, 0, math.max(cap, if d > 0 then before else 0))
				local real = life.stats[key] - before
				if real ~= 0 then
					deltas[key] = (deltas[key] or 0) + real
				end
			end
		end
	end

	if result.sanity ~= nil then
		engine:changeSanity(life, engine:sanityDelta(life, Rng.roll(life, result.sanity), sanityGuardNow), deltas, true)
	end

	-- reputation: how a faction regards you (rep = { thumb = -30 })
	if type(result.rep) == "table" then
		for id, n in result.rep do
			engine:addRep(life, id, Rng.roll(life, n), extra)
		end
	end

	-- bond: with the one person this is about (interactions pass them as ctx.target)
	local target = ctx.target
	if result.bond ~= nil and type(target) == "table" and target.alive then
		local d = Effects.bondDelta(engine, life, Rng.roll(life, result.bond), chance, charmBefore)
		local before = target.bond
		target.bond = Util.clamp(before + d, 0, 100)
		if target.bond ~= before then
			deltas.bond = (deltas.bond or 0) + (target.bond - before)
			ctx.bondMoved = target.bond - before
		end
	end
	-- (v0.13) a way in, found in the world: straight down, no menu (Engine/Expedition.luau)
	if type(result.expedition) == "string" and engine.startExpeditionInline then
		engine:startExpeditionInline(life, result.expedition, extra)
	end
	-- (v0.13) turf wars and cases (Engine/Turf.luau, Engine/Cases.luau)
	if type(result.turfJoin) == "string" and engine.turfJoin then
		engine:turfJoin(life, result.turfJoin, extra)
	end
	if type(result.turfTake) == "number" and result.turfTake > 0 and engine.turfTake then
		engine:turfTake(life, result.turfTake, extra)
	end
	if type(result.turfLose) == "number" and result.turfLose > 0 and engine.turfLose then
		engine:turfLose(life, result.turfLose, extra)
	end
	if result.turfGuard and life.turf then
		life.turf.guardAge = life.age
	end
	if result.turfLeave and life.turf then
		life.turf.side = nil
		life.flags.turf_in = nil
		table.insert(extra, { kind = "system", text = "You're out of the turf war. Whatever blocks you held, you hold alone now." })
	end
	if type(result.caseOpen) == "string" and engine.caseOpen then
		engine:caseOpen(life, result.caseOpen, extra)
	end
	if type(result.caseClue) == "string" and engine.caseClue then
		engine:caseClue(life, result.caseClue, extra)
	end
	if type(result.caseClose) == "string" and engine.caseClose then
		engine:caseClose(life, result.caseClose, extra)
	end
	-- (v0.17) years added to how long this body lasts (a K Corp course, a Workshop body)
	if type(result.lifespan) == "number" and result.lifespan ~= 0 then
		life.lifespanBonus = (life.lifespanBonus or 0) + result.lifespan
		table.insert(extra, { kind = "system", tone = "good", text = string.format("Your body will last about %d years longer.", result.lifespan) })
	end
	-- (v0.13) a limit broken: this life's stats can go past where they could before
	if type(result.limitBreak) == "table" then
		life.capBonus = life.capBonus or {}
		for k, v in result.limitBreak do
			life.capBonus[k] = (life.capBonus[k] or 0) + v
		end
		table.insert(extra, { kind = "system", tone = "good", text = "A limit broke. Some of what you are can grow past where it used to stop." })
	end
	-- (v0.17) a teacher: finding one, starting, a lesson, leaving (Engine/Training.luau)
	if type(result.train) == "table" then
		Training.apply(engine, life, result.train, extra, deltas)
	end
	-- (v0.13) an episode's ending (pack.episodes): kept, and said
	if result.episodeEnd and ctx.episode then
		life.episodes = life.episodes or {}
		local edef = engine.pack.episodes and engine.pack.episodes[ctx.episode]
		local ending = engine:render(life, result.episodeEnd, ctx)
		life.episodes[ctx.episode] = { ending = ending, age = life.age }
		table.insert(extra, { kind = "episodeEnd", title = (edef and edef.name) or ctx.episode, text = ending, color = edef and edef.color })
		engine:highlight(life, ((edef and edef.name) or "An episode") .. ": " .. ending)
	end
	-- (v0.12) people you've met (Engine/People.luau): a new face, or one becoming a friend
	-- (v0.19) a meeting can say who they are: meet = { role, rank, class, kind, chance... }
	if result.meet and engine.meetSomeone then
		engine:meetSomeone(life, extra, if type(result.meet) == "string" or type(result.meet) == "table" then result.meet else nil)
	end
	-- (v0.19) the party (Engine/Party.luau): loyalty, partyLoyalty, partyJoin, partyLeave,
	-- partyShare, partyRecover
	if engine.partyEffect and (result.loyalty ~= nil or result.partyLoyalty ~= nil or result.partyJoin or result.partyLeave or result.partyShare ~= nil or result.partyRecover ~= nil) then
		engine:partyEffect(life, result, target, extra)
	end
	if result.befriend and type(target) == "table" and target.alive and target.kind == "acquaintance" then
		target.kind = "friend"
		table.insert(extra, { kind = "system", tone = "good", text = target.first .. " is a friend now." })
	end
	-- (v0.12) a household of your own: only with someone the game made, never another player
	if result.becomePartner and type(target) == "table" and target.alive and not target.userId then
		local has = false
		for _, r in life.relations do
			if r.alive and r.kind == "partner" then
				has = true
			end
		end
		if not has then
			target.kind = "partner"
			target.partnerSince = life.age
			life.flags.has_partner = true
			table.insert(extra, { kind = "system", tone = "good", text = target.first .. " shares your household now. Two names on the register, one door." })
		end
	end
	-- (v0.13) a household made a marriage (pack.marriage; Config.marriage = false switches it
	-- off): the register becomes a certificate. Never romance, never another player.
	-- (an event that isn't a scene with someone means the first one of that kind)
	local spouse = if type(target) == "table" and target.kind == "partner" then target elseif result.marry then engine:firstRelation(life, "partner") else nil
	if result.marry and spouse and spouse.alive and not spouse.userId and not spouse.married and engine.pack.marriage and engine.pack.marriage.on then
		spouse.married = true
		spouse.marriedAt = life.age
		life.flags.married = true
		table.insert(extra, { kind = "system", tone = "good", text = "You and " .. spouse.first .. " are married now: the District's register says so, and so does everyone who was there." })
		engine:highlight(life, "Married " .. spouse.first .. ".")
	end
	-- (v0.13) a rival who became a friend
	local rival = if type(target) == "table" and target.kind == "rival" then target elseif result.reconcile then engine:firstRelation(life, "rival") else nil
	if result.reconcile and rival and rival.alive and rival.kind == "rival" then
		rival.kind = "friend"
		rival.formerRival = true
		life.flags.former_rival = true
		engine:tally(life, "reconciled")
		table.insert(extra, { kind = "system", tone = "good", text = rival.first .. " was your rival. Now they're a friend: the kind who knows exactly how you fight, and says so." })
		engine:highlight(life, "Made a friend of an old rival, " .. rival.first .. ".")
	end
	if result.endPartner and type(target) == "table" and target.kind == "partner" then
		target.kind = "friend"
		target.married = nil
		life.flags.married = nil
		life.flags.has_partner = nil
		table.insert(extra, { kind = "system", text = target.first .. " isn't on your household register anymore." })
	end
	-- bondExact: a bond change that already happened on a linked friend's side, landing here
	-- by the same amount (no roll, no Charisma: the two of you agree on how close you are)
	if type(result.bondExact) == "number" and type(target) == "table" and target.alive then
		local before = target.bond
		target.bond = Util.clamp(before + result.bondExact, 0, 100)
		if target.bond ~= before then
			deltas.bond = (deltas.bond or 0) + (target.bond - before)
		end
	end

	if result.money ~= nil then
		local d = Rng.roll(life, result.money)
		if d ~= 0 then
			life.money += d
			deltas.money = (deltas.money or 0) + d
		end
	end

	if result.paycheck and life.career then
		local d = math.floor(salaryNow * result.paycheck + 0.5)
		if d ~= 0 then
			life.money += d
			deltas.money = (deltas.money or 0) + d
		end
	end

	-- wage: money that scales with how well this Ward and side pay
	if result.wage ~= nil then
		local d = math.floor(Rng.roll(life, result.wage) * engine:wageMult(life) + 0.5)
		if d ~= 0 then
			life.money += d
			deltas.money = (deltas.money or 0) + d
		end
	end

	if result.setFlags then
		for _, f in result.setFlags do
			-- a "knows_" flag (pack.storyGates) is something learned: the report says so, once
			local gate = engine.gateByFlag and engine.gateByFlag[f]
			if gate and not life.flags[f] and engine.learnEntry then
				-- (and whatever it implies: K Corp is one of the Wings)
				local learned = engine:learnEntry(life, f)
				if learned then
					table.insert(extra, learned)
				end
			end
			life.flags[f] = true
		end
	end
	-- the main storyline: the next thing to do, and how it ended
	if result.goal and life.story then
		life.storyGoal = engine:render(life, result.goal, ctx)
	end
	if result.storyEnd and life.story and not life.storyEnding then
		local ending = engine:render(life, result.storyEnd, ctx)
		life.storyEnding = ending
		life.storyGoal = nil
		local def = engine:storyDef(life)
		table.insert(extra, { kind = "storyEnd", title = if def then def.name else "Your story", text = ending, tone = def and def.tone })
		engine:highlight(life, (if def then def.name else "Their story") .. ": " .. ending)
	end
	if result.clearFlags then
		for _, f in result.clearFlags do
			life.flags[f] = nil
		end
	end

	if result.quitCareer then
		engine:quitCareer(life, extra)
	end
	if result.career then
		engine:setCareer(life, result.career, extra)
		-- careerRank: start higher up (taking over the family business)
		if type(result.careerRank) == "number" and life.career and life.career.id == result.career then
			local def = engine.pack.careers[result.career]
			local rank = math.clamp(math.floor(result.careerRank), 1, #def.ranks)
			life.career.rank = rank
			for r = 1, rank do
				if def.rankFlags and def.rankFlags[r] then
					life.flags[def.rankFlags[r]] = true
				end
			end
			life.peakRank = math.max(life.peakRank or 0, rank)
			table.insert(extra, { kind = "system", tone = "good", text = "You start as " .. def.ranks[rank] .. "." })
		end
	end
	if result.promote then
		engine:promote(life, extra)
	end
	if result.district then
		local to = result.district
		if to == "random" then
			-- (v0.12) anywhere but here: running from something
			local others = {}
			for _, d in pack.districts.order or {} do
				if d ~= life.district then
					table.insert(others, d)
				end
			end
			to = if #others > 0 then Rng.pick(life, others) else life.district
		end
		engine:moveDistrict(life, to, extra)
	end
	if result.side then
		engine:moveSide(life, result.side, extra)
	end
	if result.form then
		engine:setForm(life, result.form, extra)
	end

	-- (v0.12) a home of your own (Engine/Market.luau), and what's been done to your body
	if result.sellHome and engine.sellHome then
		engine:sellHome(life, extra)
	end
	if type(result.home) == "string" and engine.moveIntoHome then
		engine:moveIntoHome(life, result.home, extra)
	end
	if type(result.maxHealth) == "number" and result.maxHealth ~= 0 then
		life.maxHealthBonus = (life.maxHealthBonus or 0) + result.maxHealth
		table.insert(extra, {
			kind = "system",
			tone = if result.maxHealth > 0 then "good" else "bad",
			text = string.format("Most Health %s%d (now %d).", if result.maxHealth > 0 then "+" else "", result.maxHealth, engine:maxHealthOf(life)),
		})
	end
	if result.gear then
		engine:giveGear(life, result.gear, extra)
	end
	-- (BitLeveling) a roll for a weapon (Engine/HunterWorld.loot): { rank, chance, minStars, shinyBoost }
	if result.loot and engine.lootHook then
		engine.lootHook(engine, life, result.loot, extra)
	end
	if result.loseGear then
		engine:loseGear(life, result.loseGear, extra)
	end
	if result.condition then
		engine:addCondition(life, result.condition, extra)
	end
	if result.cure then
		engine:cureCondition(life, result.cure, extra)
	end
	if result.quest and report then
		engine:startQuest(life, result.quest, report)
	end

	-- renown, an Office of your own, and what a deed does to the District (Engine/Renown.luau)
	if result.foundOffice and not life.office then
		Renown.foundOffice(engine, life, report)
	end
	if type(result.officeSize) == "number" and life.office then
		Renown.growOffice(engine, life, result.officeSize, report)
	end
	if result.renown ~= nil then
		Renown.add(engine, life, Rng.roll(life, result.renown), report)
	end
	if result.impact then
		Renown.impact(engine, life, result.impact, report)
	end

	-- traits, style and training
	if result.addTrait then
		for _, id in Util.asList(result.addTrait) do
			engine:addTrait(life, id, extra)
		end
	end
	if result.removeTrait then
		for _, id in Util.asList(result.removeTrait) do
			engine:removeTrait(life, id, extra)
		end
	end
	if result.school then
		engine:teach(life, result.school, extra)
	end
	if result.style then
		engine:setStyle(life, result.style, extra)
	end
	if result.mastery ~= nil then
		local m = Rng.roll(life, result.mastery)
		if m > 0 then
			m = math.max(1, math.floor(m * engine:masteryGrowthOf(life) + 0.5))
		end
		engine:addMastery(life, m, extra)
	end
	-- books: found, and read (reading teaches an ability)
	if result.book then
		for _, id in Util.asList(result.book) do
			engine:giveBook(life, id, extra)
		end
	end
	if result.readBook then
		engine:readBook(life, result.readBook, extra)
	end

	-- lore, the server's chronicle, chat news and surname rolls (the server acts on these)
	if result.codex and report then
		engine:unlockCodex(life, result.codex, report)
	end
	if result.chronicle and report then
		report.chronicle = report.chronicle or {}
		for _, act in Util.asList(result.chronicle) do
			table.insert(report.chronicle, { act = act })
		end
	end
	if result.announce and report then
		report.announce = report.announce or {}
		table.insert(report.announce, engine:render(life, result.announce, ctx))
	end
	if result.rolls and report then
		report.rolls = (report.rolls or 0) + math.max(0, math.floor(result.rolls))
	end

	if result.addRelation then
		local rel = engine:addRelation(life, result.addRelation)
		ctx.newRelation = rel.first
	end
	if result.relationBond then
		engine:bond(life, result.relationBond.kind, result.relationBond.amount or 0)
	end
	if result.killRelation then
		engine:killRelation(life, result.killRelation, extra) -- a kind, or { kind, fate }
	end

	if result.schedule then
		local list = if result.schedule.event then { result.schedule } else result.schedule
		for _, s in list do
			table.insert(life.scheduled, { event = s.event, age = life.age + math.max(1, s.inYears or 1) })
			if type(life.scene) == "string" and life.scene ~= "" then
				engine:setWhy(life, s.event, string.format("This follows from \"%s\", when you were %d.", tostring(life.scene), life.age))
			end
		end
	end
	if result.trigger then
		table.insert(life.queue, result.trigger)
		if type(life.scene) == "string" and life.scene ~= "" then
			engine:setWhy(life, result.trigger, string.format("This follows from \"%s\".", tostring(life.scene)))
		end
	end

	-- LINKED: what this does to the linked friend it is about (another player). The server
	-- delivers it (report.outbox); {sender} in its log becomes this player's first name.
	--   result.linked  effects written for them ("{sender} bought you two bowls...")
	--   a bond that moved with them moves on their side too, by the same amount
	-- so what you do with a linked friend happens in their life as well.
	if report and not ctx.mirrored then
		local friend = nil
		if type(target) == "table" and target.userId then
			friend = target
		elseif result.linked then
			friend = engine:focusLinked(life)
		end
		if friend and friend.userId then
			local theirs = if result.linked then table.clone(result.linked) else nil
			local moved = if friend == target then ctx.bondMoved else nil
			if type(moved) == "number" and moved ~= 0 then
				theirs = theirs or {}
				theirs.bondExact = moved
				if theirs.log == nil then
					theirs.log = if moved > 0 then "{sender} made time for you." else "{sender} and you had words."
				end
			end
			if theirs then
				table.insert(report.outbox, {
					userId = friend.userId,
					result = theirs,
					from = life.first,
					-- what it was, for their feed: the scene and what was chosen in it
					title = if type(life.scene) == "string" and life.scene ~= "" then life.scene else nil,
					choice = if type(life.lastChoice) == "string" then life.lastChoice else nil,
				})
			end
		end
	end

	-- v0.8: what people say back (result.dialogue) comes before the outcome line
	if result.dialogue and report then
		engine:pushDialogue(life, report, result.dialogue, ctx)
	end
	-- a full-screen moment (E.G.O, a Distortion): played before the words land
	if type(result.cutscene) == "table" then
		engine:push(life, report, engine:cutsceneEntry(life, result.cutscene))
	end
	-- (v0.13) a list of lines turns with the years: the same activity reads differently each time
	local logText: any = result.log
	if type(logText) == "table" and #logText > 1 then
		logText = logText[((life.age or 0) + #(life.first or "")) % #logText + 1]
	end
	local text = if logText then engine:render(life, logText, ctx) else nil
	if text ~= nil or next(deltas) ~= nil then
		engine:push(life, report, { kind = "log", text = text or "", deltas = if next(deltas) then deltas else nil })
	end
	for _, entry in extra do
		engine:push(life, report, entry)
	end

	if result.die then
		engine:kill(life, report, engine:render(life, result.die, ctx))
	elseif life.stats[engine.vital] <= 0 and engine:saverFor(life) then
		-- someone who loves you got there in time. Once.
		local saver = engine:saverFor(life)
		life.savedOnce = true
		life.stats[engine.vital] = (pack.bondPerks and pack.bondPerks.saveHealth) or 6
		engine:push(life, report, { kind = "system", tone = "good", text = saver.first .. " got to you in time and carried you home. That only happens once." })
	elseif life.stats[engine.vital] <= 0 then
		-- no cause of its own: name the scene it happened in (life.scene, set by the engine)
		local cause = result.cause
		if not cause and type(life.scene) == "string" and life.scene ~= "" then
			local scene: string = tostring(life.scene)
			cause = string.format(pack.deathCauses.woundsFrom or "Died of their wounds (%s)", scene)
		end
		engine:kill(life, report, cause or pack.deathCauses.wounds)
	end
end

return Effects
