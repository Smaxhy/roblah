--[[
	Records a few lives played by the real engine + content, step by step, into
	preview/replay.json. The HTML preview (preview/index.html) replays them with
	a browser copy of the Roblox UI.
		lune run tests/record
]]

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local Loader = require("./loader")

local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local sim = Engine.new(pack)
local Rng = Engine.Rng
local Avatar = Engine.Avatar
local Expedition = Engine.Expedition
local Config = Loader.require(root.Config)

-- avatar figures, stored once per distinct look; frames point at them by key
local avatars = {}
local appearanceOf = {} -- key -> the appearance it was built from (store try-ons start from one)
local function avatarKey(ap)
	if not ap then
		return nil
	end
	local key = Avatar.signature(ap)
	appearanceOf[key] = appearanceOf[key] or ap
	if not avatars[key] then
		local full, info = Avatar.build(pack, ap, { ground = true })
		local portrait = Avatar.build(pack, ap, { portrait = true })
		local function r3(v)
			if not v then
				return nil
			end
			return { math.floor(v[1] * 1000 + 0.5) / 1000, math.floor(v[2] * 1000 + 0.5) / 1000, math.floor(v[3] * 1000 + 0.5) / 1000 }
		end
		local function slim(parts)
			local out = {}
			for _, p in parts do
				table.insert(out, { s = p.shape, z = r3(p.size), p = r3(p.pos), r = p.rot, c = p.color, m = if p.material == "plastic" then nil else p.material })
			end
			return out
		end
		avatars[key] = { full = slim(full), portrait = slim(portrait), info = info }
	end
	return key
end

-- what the UI needs from a view (keeps the file small)
local function compact(v, withMenus: boolean?)
	local out = {
		age = v.age,
		year = v.year,
		first = v.first,
		last = v.last,
		alive = v.alive,
		money = v.money,
		sanity = v.sanity,
		stats = v.stats,
		actionsLeft = v.actionsLeft,
		actionsPerYear = v.actionsPerYear,
		district = v.district,
		side = v.side,
		zone = v.zone,
		livingCost = v.livingCost,
		wageMult = v.wageMult,
		fileNo = v.fileNo,
		gear = v.gear,
		conditions = v.conditions,
		av = avatarKey(v.appearance),
		frame = v.appearance and v.appearance.look and v.appearance.look.frame,
		score = v.score,
		generation = v.generation,
		ambitions = v.ambitions,
		quests = v.quests,
		form = { id = v.form.id, name = v.form.name },
		style = if v.style then { name = v.style.name, color = v.style.color, mastery = v.style.mastery, maxMastery = v.style.maxMastery, potency = v.style.potency } else nil,
		traits = nil,
		talent = if v.talent then { name = v.talent.name, desc = v.talent.desc, tierName = v.talent.tierName, color = v.talent.color, affinityName = v.talent.affinityName, affinityColor = v.talent.affinityColor, resonance = v.talent.resonance } else nil,
		affinities = v.affinities,
		world = {},
		relations = {},
	}
	if v.traits and #v.traits > 0 then
		out.traits = {}
		for _, t in v.traits do
			table.insert(out.traits, { name = t.name, desc = t.desc })
		end
	end
	if v.career then
		out.career = { name = v.career.name, rank = v.career.rank, rankIndex = v.career.rankIndex, rankCount = v.career.rankCount, salary = v.career.salary, years = v.career.years }
	end
	for _, w in v.world do
		table.insert(out.world, { label = w.label })
	end
	for id in sim.worldActive do
		local we = pack.worldEvents[id]
		out.worldEvent = { id = id, name = we.name, headline = we.headline, text = we.text, tone = we.tone }
	end
	if withMenus then
		for _, r in v.relations do
			local acts = {}
			for _, a in r.interactions or {} do
				table.insert(acts, { name = a.name, desc = a.desc, enabled = a.enabled, reason = a.reason })
			end
			table.insert(out.relations, { name = r.name, kindName = r.kindName, age = r.age, alive = r.alive, bond = r.bond, interactions = acts })
		end
		out.expeditions = {}
		for _, e in v.expeditions or {} do
			table.insert(out.expeditions, { name = e.name, desc = e.desc, kind = e.kind, cost = e.cost, crewMax = e.crewMax, enabled = e.enabled, reason = e.reason })
		end
	else
		out.relations = nil
	end
	if v.pending then
		local choices = {}
		for _, c in v.pending.choices do
			local clash = nil
			if c.clash then
				local approaches = {}
				for _, a in c.clash.approaches or {} do
					table.insert(approaches, { id = a.id, name = a.name, desc = a.desc, odds = math.floor(a.odds * 100 + 0.5) / 100 })
				end
				clash = {
					approaches = approaches,
					statName = c.clash.statName,
					fight = c.clash.fight,
					odds = math.floor(c.clash.odds * 100 + 0.5) / 100,
					player = { coins = c.clash.player.coins, base = c.clash.player.base, coinPower = c.clash.player.coinPower },
					foe = { name = c.clash.foe.name, coins = c.clash.foe.coins, base = c.clash.foe.base, coinPower = c.clash.foe.coinPower },
				}
			end
			table.insert(choices, { label = c.label, hint = c.hint, enabled = c.enabled, reason = c.reason, clash = clash })
		end
		out.pending = { title = v.pending.title, text = v.pending.text, choices = choices, tone = v.pending.tone, linked = v.pending.linked }
	end
	if withMenus then
		out.activities = {}
		for _, a in v.activities do
			table.insert(out.activities, { name = a.name, desc = a.desc, category = a.category, cost = a.cost, enabled = a.enabled, reason = a.reason, shop = a.shop or nil, clash = if a.clash then true else nil })
		end
		out.shop = {}
		for _, g in v.shop or {} do
			table.insert(out.shop, { name = g.name, slot = g.slot, price = g.price, desc = g.desc, effect = g.effect, enabled = g.enabled, reason = g.reason, owned = g.owned or nil })
		end
		out.careers = {}
		for _, c in v.careers do
			table.insert(out.careers, { name = c.name, desc = c.desc, firstRank = c.firstRank, salary = c.salary, enabled = c.enabled, reason = c.reason, current = c.current })
		end
	end
	return out
end

-- a sensible player: trains toward a job, rests when shaken, heals when hurt,
-- avoids long-odds clashes most of the time
local function pickChoice(brain, view)
	-- say yes to side quests, so the replay shows some
	local ev = sim.eventsById[view.pending.id]
	for i, c in view.pending.choices do
		local def = ev and ev.choices and ev.choices[i]
		if c.enabled and def and def.result and def.result.quest then
			return i
		end
	end
	local best, bestScore = nil, -math.huge
	for i, c in view.pending.choices do
		if c.enabled then
			local score = Rng.next(brain)
			if c.clash then
				score += (c.clash.odds - 0.5) * 2
			end
			if score > bestScore then
				best, bestScore = i, score
			end
		end
	end
	return best
end

-- activity ids differ by pack: what the bot uses to heal, rest, raise a family and earn
local CITY = Config.pack == "City"
local ACT = if CITY
	then { heal = "clinic", rest = { "quiet", "diner" }, family = "foundling_house", tail = { "study", "train", "quiet", "odd_jobs" }, daily = "today", drill = "drill_style" }
	else { heal = "stitcher", rest = { "still", "broth" }, family = "foundling_steps", tail = { "study", "train", "still", "haul", "wade" } }

local function pickActivity(brain, life, view, plan)
	local open = {}
	for _, a in view.activities do
		if a.enabled then
			open[a.id] = true
		end
	end
	if life.stats.health < 45 and open[ACT.heal] then
		return ACT.heal
	end
	if life.sanity < -8 then
		for _, id in ACT.rest do
			if open[id] then
				return id
			end
		end
	end
	if life.age >= 26 and life.age % 7 == 0 and open[ACT.family] and not life.flags.parent then
		return ACT.family
	end
	-- today's event, once, as a kid
	if ACT.daily and open[ACT.daily] and life.age >= 8 and not plan.didDaily then
		plan.didDaily = true
		return ACT.daily
	end
	-- quest steps first
	for _, a in view.activities do
		if a.enabled and string.sub(a.id, 1, 6) == "quest_" then
			return a.id
		end
	end
	-- a fighter drills their style now and then
	if plan.drill and ACT.drill and open[ACT.drill] and life.age >= 12 and Rng.chance(brain, 0.3) then
		return ACT.drill
	end
	local order = { plan.focus }
	for _, id in ACT.tail do
		table.insert(order, id)
	end
	for _, id in order do
		if open[id] and Rng.chance(brain, 0.7) then
			return id
		end
	end
	return nil
end

-- the server's chronicle, shared by the recorded lives the way players share a server:
-- a later life can hear about an earlier one's deeds
local sharedChronicle = {}
local chronicleRun = {}
local function noteChronicle(life, report)
	for _, c in (report and report.chronicle) or {} do
		table.insert(chronicleRun, { act = c.act, name = life.first .. " " .. life.last, district = life.district, lifeId = life.id, age = life.age, year = life.year })
	end
end
local function renderChronicle(entry)
	local def = pack.chronicle and pack.chronicle[entry.act]
	if not def then
		return nil
	end
	local d = pack.districts[entry.district or ""]
	local text = string.gsub(def.text, "{name}", entry.name)
	text = string.gsub(text, "{district}", if d then d.name else "the City")
	return { act = entry.act, text = text, tone = def.tone, announce = def.announce == true, year = entry.year }
end

local function record(label: string, seed: number, opts, plan)
	for id in sim.worldActive do
		sim:setWorldEvent(id, false)
	end
	chronicleRun = {}
	sim:setChronicle(table.clone(sharedChronicle))
	plan.didDaily = false
	local life, birth = sim:newLife({
		seed = seed,
		originId = opts.origin,
		district = opts.district,
		birthEra = opts.era,
		traits = opts.traits,
		style = opts.style,
		alloc = opts.alloc,
		last = opts.last,
		bonusTraits = opts.bonusTraits,
		dailyDay = nil,
		mode = opts.mode,
		affinities = opts.affinities,
	})
	if opts.side and life.side ~= opts.side then
		return nil
	end
	-- what a chronicle-aware frame needs: what this report unlocked and recorded
	local function extras(frame, report)
		if report and report.codex and #report.codex > 0 then
			frame.codex = report.codex
		end
		if report and report.chronicle and #report.chronicle > 0 then
			noteChronicle(life, report)
			local out = {}
			for _, c in report.chronicle do
				local r = renderChronicle({ act = c.act, name = life.first .. " " .. life.last, district = life.district, year = life.year })
				if r then
					table.insert(out, r)
				end
			end
			frame.chronicle = out
		end
		return frame
	end
	local brain = { rng = Rng.seed(seed * 31 + 7) }
	local frames = {}
	table.insert(frames, extras({ action = "born", entries = birth.entries, view = compact(sim:view(life), true) }, birth))
	local guard = 0
	while life.alive and guard < 400 and life.age < (opts.maxAge or 95) do
		guard += 1
		if life.pending then
			local v = sim:view(life)
			local idx = pickChoice(brain, v)
			local approach = nil
			local c = v.pending.choices[idx]
			if c.clash and c.clash.approaches then
				local best, bestOdds = nil, -1
				for _, a in c.clash.approaches do
					if a.odds > bestOdds then
						best, bestOdds = a.id, a.odds
					end
				end
				approach = if Rng.chance(brain, 0.2) then "reckless" else best
			end
			local report = sim:choose(life, idx, approach)
			table.insert(frames, extras({
				action = "choose",
				choiceIndex = idx,
				approach = approach,
				entries = report.entries,
				clash = report.clash,
				view = compact(sim:view(life)),
			}, report))
		else
			-- maybe get a job
			if not life.career and life.age >= (plan.jobAge or 17) then
				local v = sim:view(life)
				for _, c in v.careers do
					if c.enabled and c.id == plan.career then
						local report = sim:joinCareer(life, c.id)
						table.insert(frames, extras({ action = "career", label = c.name, entries = report.entries, view = compact(sim:view(life)) }, report))
						break
					end
				end
			end
			-- buy gear now and then
			if life.age >= 14 and Rng.chance(brain, 0.25) then
				local wish = plan.gear or { plan.tool or "dock_knife", "oilskin", "still_stone", "little_bell", "hook_pole", "lantern_token" }
				for _, id in wish do
					local g = pack.gear[id]
					if g and not (life.gear and life.gear[g.slot]) and life.money >= (g.price or 0) + 60 then
						local report = sim:buyGear(life, id)
						if report then
							table.insert(frames, { action = "gear", label = g.name, entries = report.entries, view = compact(sim:view(life)) })
							break
						end
					end
				end
			end
			-- a world event at a chosen age (the server rolls these for real)
			if plan.world and life.age == plan.world.age and not sim.worldActive[plan.world.id] then
				sim:setWorldEvent(plan.world.id, true)
				local we = pack.worldEvents[plan.world.id]
				if we.startEvent and not life.pending then
					table.insert(life.queue, 1, we.startEvent)
					local report = sim.newReport()
					sim:advance(life, report)
					table.insert(frames, extras({ action = "world", label = we.headline, entries = report.entries, view = compact(sim:view(life)) }, report))
				end
			elseif plan.world and life.age >= plan.world.age + (plan.world.years or 2) and sim.worldActive[plan.world.id] then
				sim:setWorldEvent(plan.world.id, false)
			end
			-- go on expeditions now and then (quest ones first)
			if life.age >= 16 and not life.pending and not life.run and Rng.chance(brain, plan.expeditionChance or 0.18) then
				local pick = nil
				for _, e in Expedition.list(sim, life) do
					local def = pack.expeditions[e.id]
					local wanted = (def.when and def.when.flags) or (plan.expeditions and table.find(plan.expeditions, e.id))
					if e.enabled and e.crewMin <= 1 and wanted then
						pick = pick or e.id
					end
				end
				if pick then
					local _, startReports = Expedition.start(sim, { life }, pick)
					local run = life.run
					table.insert(frames, { action = "setout", label = pack.expeditions[pick].name, entries = (startReports and startReports[1] and startReports[1].entries) or {}, view = compact(sim:view(life)) })
					local steps = 0
					while run and not run.outcome and steps < 12 and life.alive do
						steps += 1
						local card = Expedition.view(sim, { life }, run)
						local best, bestScore, approach = nil, -math.huge, nil
						for _, c in card.stage.choices do
							if c.enabled then
								local score = Rng.next(brain) + (if c.clash then (c.clash.odds - 0.5) else 0)
								if score > bestScore then
									best, bestScore = c, score
								end
							end
						end
						if best and best.clash then
							local top = -1
							for _, a in best.clash.approaches do
								if a.odds > top then
									top, approach = a.odds, a.id
								end
							end
						end
						local slimCard = { name = card.name, kind = card.kind, step = card.step, stage = { title = card.stage.title, text = card.stage.text, tone = card.stage.tone, choices = {} } }
						for _, c in card.stage.choices do
							local clash = nil
							if c.clash then
								local approaches = {}
								for _, a in c.clash.approaches or {} do
									table.insert(approaches, { id = a.id, name = a.name, desc = a.desc, odds = math.floor(a.odds * 100 + 0.5) / 100 })
								end
								clash = {
									statName = c.clash.statName,
									odds = math.floor(c.clash.odds * 100 + 0.5) / 100,
									approaches = approaches,
									player = { coins = c.clash.player.coins, base = c.clash.player.base, coinPower = c.clash.player.coinPower },
									foe = { name = c.clash.foe.name, coins = c.clash.foe.coins, base = c.clash.foe.base, coinPower = c.clash.foe.coinPower },
								}
							end
							table.insert(slimCard.stage.choices, { label = c.label, hint = c.hint, enabled = c.enabled, reason = c.reason, clash = clash })
						end
						local reps, clash = Expedition.choose(sim, { life }, run, best.index, approach)
						table.insert(frames, extras({
							action = "run",
							card = slimCard,
							choiceIndex = best.index,
							approach = approach,
							entries = (reps and reps[1] and reps[1].entries) or {},
							clash = clash,
							view = compact(sim:view(life)),
						}, reps and reps[1]))
					end
				end
			end
			-- spend up to two actions on activities
			for _ = 1, 2 do
				if life.pending or not life.alive or life.actionsLeft <= 0 then
					break
				end
				local v = sim:view(life)
				local id = pickActivity(brain, life, v, plan)
				if not id then
					break
				end
				local report = sim:doActivity(life, id)
				if report then
					table.insert(frames, extras({ action = "activity", label = sim.activitiesById[id].name, entries = report.entries, clash = report.clash, view = compact(sim:view(life)) }, report))
				end
			end
			if not life.pending and life.alive then
				local report = Loader.ageUp(sim, life)
				-- the menus (activities, jobs, shop, people) ride along every third year; the
				-- preview keeps the last ones it saw, and that keeps the file small
				table.insert(frames, extras({ action = "ageUp", entries = report.entries, view = compact(sim:view(life), life.age % 3 == 0) }, report))
			end
		end
	end
	if life.alive then
		sim:kill(life, nil, "Still living when the recording stopped")
	end
	local final = sim:view(life)
	local lantern = sim:lantern(life)
	local names = {}
	for _, id in sim:checkRecords(life) do
		for _, r in pack.records do
			if r.id == id then
				table.insert(names, r.name)
			end
		end
	end
	if #names > 0 then
		lantern.records = names
	end
	local traitNames = {}
	for _, t in life.traits or {} do
		local def = pack.traits and pack.traits[t]
		table.insert(traitNames, if def then def.name else t)
	end
	local eraDef = sim:birthEraDef(opts.era)
	return {
		label = label,
		frames = frames,
		lantern = lantern,
		heirs = final.heirs,
		chronicleRun = chronicleRun,
		build = {
			era = eraDef and eraDef.name,
			born = life.bornYear,
			origin = (sim.originsById[life.origin] or {}).name,
			style = life.style and pack.styles and pack.styles[life.style] and pack.styles[life.style].name,
			traits = traitNames,
			alloc = opts.alloc,
			surname = opts.surname,
		},
		summary = { name = life.first .. " " .. life.last, age = life.age, zone = sim:zoneLabel(life), cause = life.cause, mode = life.mode, talent = sim:talentView(life) },
	}
end

local lives = {}
local specs = nil
if CITY then
	-- one family name from each of three tiers, the way a player would have rolled them
	local function surname(tier: string, i: number)
		local names = pack.surnames.names[tier]
		local name = names[((i - 1) % #names) + 1]
		local tierDef = nil
		for _, t in pack.surnames.tiers do
			if t.id == tier then
				tierDef = t
			end
		end
		return name, { name = name, tier = tier, tierName = tierDef and tierDef.name, color = tierDef and tierDef.color, flavor = pack.surnames.flavor and pack.surnames.flavor[name] }, if tierDef and tierDef.trait then { tierDef.trait } else nil
	end
	local n1, s1, t1 = surname("rare", 7)
	local n2, s2, t2 = surname("uncommon", 4)
	local n3, s3, t3 = surname("epic", 2)
	specs = {
		{
			label = "Fixer's Road",
			opts = { mode = "fixer", origin = "backstreets_family", era = "twilight", side = "backstreets", traits = { "st_aftershock", "heavy_hands" }, style = "tremor", alloc = { strength = 5, health = 5 }, last = n1, surname = s1, bonusTraits = t1, affinities = { "wrath", "gluttony" } },
			plan = { focus = "train", drill = true, career = "fixer", jobAge = 18, gear = { "workshop_knife", "padded_jacket", "fixer_coat", "long_blade", "ampule" }, world = { age = 22, id = "night_in_backstreets", years = 1 }, expeditionChance = 0.22 },
			-- a Fixer who climbs, and dies on the job
			want = function(r)
				return r.summary.age >= 30 and r.summary.age <= 62 and not string.find(string.lower(r.summary.cause or ""), "sleep", 1, true)
			end,
		},
		{
			label = "L Corp agent",
			opts = { origin = "lcorp_family", era = "wings", traits = { "steady_mind", "cold_reader" }, style = "poise", alloc = { mind = 5, health = 4, intelligence = 1 }, last = n2, surname = s2, bonusTraits = t2 },
			plan = { focus = "quiet", career = "lcorp_agent", jobAge = 18, gear = { "moonlight_stone", "padded_jacket", "baton" }, world = { age = 27, id = "abnormality_breach", years = 1 }, expeditionChance = 0.2 },
			-- show a career that climbs
			want = function(r)
				return r.summary.age >= 40
			end,
		},
		{
			label = "After the Light",
			opts = { origin = "street_orphan", era = "after", traits = { "rat_smart", "unflinching" }, style = "bleed", alloc = { strength = 3, health = 3, mind = 3, intelligence = 1 }, last = n3, surname = s3, bonusTraits = t3 },
			plan = { focus = "train", drill = true, career = "limbus_lccb", jobAge = 18, gear = { "baton", "padded_jacket", "moonlight_stone" }, world = { age = 19, id = "distortion_sighting", years = 1 }, expeditionChance = 0.22 },
			-- the City after the Light kills people young
			want = function(r)
				return r.summary.age >= 22 and r.summary.age <= 48 and not string.find(string.lower(r.summary.cause or ""), "sleep", 1, true)
			end,
		},
		{
			label = "Kindred",
			opts = { mode = "kindred", origin = "backstreets_family", era = "after", traits = { "st_deep_cuts", "bleeder" }, style = "bleed", alloc = { strength = 5, health = 3, mind = 2 }, affinities = { "envy", "lust" } },
			plan = { focus = "train", drill = true, gear = { "bleeding_knives", "padded_jacket" }, world = { age = 24, id = "night_in_backstreets", years = 1 }, expeditionChance = 0.2 },
		},
	}
	-- today's event, as the server would pick it for one fixed day
	local day = 20412
	local order = pack.daily and pack.daily.order or {}
	if #order > 0 then
		sim:setDaily(order[(day * 7 + 3) % #order + 1], day)
	end
else
	specs = {
		{
			label = "Gutters life",
			opts = { origin = "ordinary", district = "foundry", side = "gutters" },
			plan = { focus = "train", career = "diver", jobAge = 17, expeditions = { "drowned_arcade", "lost_bell" }, world = { age = 24, id = "breach_tidewell", years = 2 } },
			-- the Gutters are rough: show a life that ends early
			want = function(r)
				return r.summary.age >= 35 and r.summary.age < 62 and not string.find(r.summary.cause, "sleep", 1, true)
			end,
		},
		{ label = "Charter life", opts = { origin = "company_family", district = "glasswall", side = "charter" }, plan = { focus = "study", career = "company", jobAge = 18, expeditions = { "undertow_saltflats", "lost_bell" }, world = { age = 33, id = "lantern_festival", years = 2 } } },
		{ label = "Drownside orphan", opts = { origin = "orphan", district = "drownside", side = "gutters" }, plan = { focus = "train", career = "brine", jobAge = 15, expeditions = { "drowned_arcade", "undertow_saltflats" }, world = { age = 28, id = "fog_week", years = 2 } } },
	}
end
for _, spec in specs do
	local result = nil
	for attempt = 1, 400 do
		result = record(spec.label, 9000 + attempt * 37 + #lives * 1000, spec.opts, spec.plan)
		-- prefer lives with some drama: at least one clash and a decent length
		if result and (not spec.want or spec.want(result)) then
			local clashes = 0
			for _, f in result.frames do
				if f.clash then
					clashes += 1
				end
			end
			if clashes >= 3 and result.summary.age >= 30 then
				break
			end
		end
	end
	-- this life's deeds join the server's chronicle for the lives recorded after it
	for _, e in result.chronicleRun or {} do
		table.insert(sharedChronicle, e)
	end
	result.chronicleRun = nil
	table.insert(lives, result)
	print(string.format("%-18s %s, %d years, %d frames, %s", spec.label, result.summary.name, result.summary.age, #result.frames, result.summary.cause))
end

-- store try-ons: the second replay life (or the first) at about 24, wearing each item
local tryBase = nil
for _, l in { lives[2], lives[1] } do
	for _, f in (l and l.frames) or {} do
		if not tryBase and f.view and f.view.av and f.view.age >= 24 and appearanceOf[f.view.av] then
			tryBase = appearanceOf[f.view.av]
		end
	end
end
local LOOK_CATEGORIES = { skin = true, hair = true, hairColor = true, outfit = true, mark = true }
local tryOnKeys = {}
local store = {}
for _, item in (if pack.fanWork then {} else Config.store.items) do
	local entry = { name = item.name, desc = item.desc, price = item.price, tier = item.tier, kind = item.kind }
	local look = table.clone((tryBase and tryBase.look) or Avatar.defaultLook(pack))
	local changed = false
	entry.framing = "portrait" -- dyes and marks read best close up
	for _, grant in item.grants or {} do
		local category, id = string.match(grant, "^([%w_]+):(.+)$")
		if category and LOOK_CATEGORIES[category] then
			look[category] = id
			changed = true
			if category == "outfit" or category == "hair" then
				entry.framing = "full"
			end
		elseif category == "frame" and not entry.frame then
			entry.frame = id
		end
	end
	if changed then
		entry.av = avatarKey({
			look = look,
			age = math.clamp((tryBase and tryBase.age) or 24, 18, 60),
			form = tryBase and tryBase.form,
			sanity = 0,
			gear = {},
			conditions = {},
		})
		tryOnKeys[entry.av] = true
		entry.frame = nil
	else
		entry.framing = nil
	end
	table.insert(store, entry)
end
local info = {
	store = store,
	storeNote = Config.store.note,
	frames = {},
	meta = pack.meta,
	stats = { order = pack.stats.order, defs = {}, sanity = pack.stats.sanity },
	city = sim:cityInfo(),
	categories = pack.activityCategories,
	approaches = {},
	records = {},
}
for _, id in pack.approaches.order do
	info.approaches[id] = pack.approaches[id].name
end
for _, r in pack.records do
	table.insert(info.records, { id = r.id, name = r.name, desc = r.desc })
end
for _, key in pack.stats.order do
	local s = pack.stats[key]
	info.stats.defs[key] = { name = s.name, short = s.short, color = s.color }
end
for _, o in pack.cosmetics.frame.options do
	info.frames[o.id] = o.color
end
info.fanWork = pack.fanWork == true
info.quickChecks = pack.quickChecks == true
info.intro = pack.intro
info.eras = {}
for _, e in (pack.calendar and pack.calendar.eras) or {} do
	table.insert(info.eras, { id = e.id, name = e.name, desc = e.desc, years = e.years, default = e.default == true })
end
info.origins = {}
for _, o in pack.origins do
	table.insert(info.origins, { id = o.id, name = o.name, desc = o.desc })
end
if pack.styles then
	info.styles = {}
	for _, id in pack.styles.order do
		local st = pack.styles[id]
		table.insert(info.styles, { id = id, name = st.name, desc = st.desc, color = st.color })
	end
end
if pack.traits then
	info.traits = {}
	for _, id in pack.traits.order do
		local t = pack.traits[id]
		if t.pick then
			table.insert(info.traits, { id = id, name = t.name, desc = t.desc, category = t.category })
		end
	end
end
info.traitPicks = pack.traitPicks
info.buildPresets = pack.buildPresets
-- the store catalog (the City's is open: Config.store.sellInFanPacks)
local storeCfg = Config.store or {}
if pack.store and pack.store.items and (not pack.fanWork or storeCfg.sellInFanPacks) then
	info.storeCatalog = { note = pack.store.note, items = {} }
	for _, item in pack.store.items do
		table.insert(info.storeCatalog.items, { name = item.name, desc = item.desc, price = item.price, lunacy = item.lunacy, bonus = item.bonus, tier = item.tier, kind = item.kind, odds = item.odds, consumable = item.consumable == true, random = item.random == true })
	end
end
info.build = pack.build
info.statuses = pack.statuses
-- v0.7: game modes, talents (with the real odds), the guidebook, Lunacy
info.lunacy = pack.meta.premiumName
info.modes = {}
for _, m in pack.modes or {} do
	local start = m.start or {}
	table.insert(info.modes, {
		id = m.id,
		name = m.name,
		tagline = m.tagline,
		desc = m.desc,
		color = m.color,
		startAge = start.age or 0,
		career = start.career and pack.careers[start.career] and pack.careers[start.career].name or nil,
		locked = m.unlock ~= nil,
		unlockText = m.unlockText,
		lightCost = m.unlock and m.unlock.light or nil,
	})
end
if pack.talents then
	info.talentTiers = sim:talentOdds(nil)
	info.premiumOdds = sim:talentOdds("rare")
	info.talents = {}
	for _, tier in pack.talents.tiers do
		for _, id in sim:talentPool(tier.id) do
			local t = pack.traits[id]
			table.insert(info.talents, { id = id, name = t.name, desc = t.desc, tier = tier.id, tierName = tier.name, color = tier.color, affinity = t.affinity })
		end
	end
end
-- the seven sins, and the premade identities (drawn once, so the preview can show them)
if pack.affinities then
	info.affinityWeight = sim.AFFINITY_WEIGHT
	info.affinityResonance = pack.affinityResonance
	info.affinities = {}
	for _, id in pack.affinities.order do
		local a = pack.affinities[id]
		table.insert(info.affinities, { id = id, name = a.name, color = a.color, desc = a.desc })
	end
end
if pack.cosmetics and pack.cosmetics.identities then
	info.identities = {}
	for _, ident in pack.cosmetics.identities do
		local look = Avatar.sanitize(pack, ident.look)
		local locked = {}
		for category, id in ident.look do
			local o = Avatar.option(pack, category, id)
			if o and (o.glow or o.record or o.store) then
				table.insert(locked, o.name)
			end
		end
		local base = { look = look, age = 24, form = if ident.id == "kindred" then "bloodfiend" else "human", sanity = 10, gear = {}, conditions = {} }
		table.insert(info.identities, { id = ident.id, name = ident.name, desc = ident.desc, av = avatarKey(base), locked = locked, weapon = (Avatar.option(pack, "weapon", look.weapon) or {}).name, outfit = (Avatar.option(pack, "outfit", look.outfit) or {}).name })
	end
end
do
	local Guide = require("../src/server/Guide")
	info.guide = Guide._build({ Content = pack, sim = sim })
end
if pack.surnames then
	local total = 0
	for _, t in pack.surnames.tiers do
		total += t.weight
	end
	info.surnames = { pityAt = pack.surnames.pityAt, pityTier = pack.surnames.pityTier, tiers = {} }
	for _, t in pack.surnames.tiers do
		local trait = t.trait and pack.traits and pack.traits[t.trait]
		local names = pack.surnames.names[t.id] or {}
		local flavors = {}
		for _, n in names do
			if pack.surnames.flavor and pack.surnames.flavor[n] then
				flavors[n] = pack.surnames.flavor[n]
			end
		end
		table.insert(info.surnames.tiers, {
			id = t.id,
			name = t.name,
			color = t.color,
			odds = math.floor(t.weight / total * 1000 + 0.5) / 10,
			perk = if trait then trait.name .. ": " .. trait.desc else t.desc,
			names = names,
			flavor = flavors,
		})
	end
end
-- today's event (the server picks one a day)
if sim.dailyId and pack.daily[sim.dailyId] then
	local d = pack.daily[sim.dailyId]
	info.daily = { id = sim.dailyId, name = d.name, desc = d.desc }
end
-- the archive: categories, how many entries there are, and the text of every entry the
-- recorded lives find (so the preview can show what this life has found)
if pack.codex then
	local found = {}
	for _, l in lives do
		for _, f in l.frames do
			for _, id in f.codex or {} do
				found[id] = true
			end
		end
	end
	info.codex = { categories = pack.codex.categories, total = #pack.codex.entries, secrets = 0, entries = {} }
	for _, e in pack.codex.entries do
		if e.secret then
			info.codex.secrets += 1
		end
		if found[e.id] then
			info.codex.entries[e.id] = { title = e.title, text = e.text, category = e.category, secret = e.secret == true }
		end
	end
end
-- the server's chronicle as the last recorded life would see it (newest first)
info.chronicle = {}
for i = #sharedChronicle, math.max(1, #sharedChronicle - 30), -1 do
	local r = renderChronicle(sharedChronicle[i])
	if r then
		table.insert(info.chronicle, r)
	end
end

-- one JSON array, one record per line: info, then each life, then its frames
local lines = { serde.encode("json", { type = "info", info = info }) }
-- only the figures the kept lives use (discarded tries made plenty of others), the store's
-- try-ons and the creator's identities
local used = table.clone(tryOnKeys)
for _, ident in info.identities or {} do
	used[ident.av] = true
end
for _, l in lives do
	for _, f in l.frames do
		if f.view and f.view.av then
			used[f.view.av] = true
		end
	end
end
for key in used do
	local a = avatars[key]
	table.insert(lines, serde.encode("json", { type = "avatar", key = key, full = a.full, portrait = a.portrait, info = a.info }))
end
for i, l in lives do
	table.insert(lines, serde.encode("json", { type = "life", life = i, label = l.label, summary = l.summary, lantern = l.lantern, heirs = l.heirs, build = l.build, frameCount = #l.frames }))
	for j, f in l.frames do
		f.type = "frame"
		f.life = i
		f.i = j
		table.insert(lines, serde.encode("json", f))
	end
end
local json = "[\n" .. table.concat(lines, ",\n") .. "\n]\n"
fs.writeDir("preview")
fs.writeFile("preview/replay.json", json)
print(string.format("wrote preview/replay.json (%d KB, %d records)", math.floor(#json / 1024), #lines))
