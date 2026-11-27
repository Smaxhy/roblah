--[[
	THE VIEW (v0.12, moved out of Sim.luau, which is at the type checker's limit): everything the
	screen is told about a life, built fresh after every action. Sim:view(life) calls View.view.
]]

local Util = require(script.Parent.Util)
local Conditions = require(script.Parent.Conditions)
local Renown = require(script.Parent.Renown)
local Avatar = require(script.Parent.Avatar)
local Expedition = require(script.Parent.Expedition)
local Jobs = require(script.Parent.Jobs)

local View = {}

-- a deterministic roll from a string (the same as Sim's): looks for people with no stored look
local function hashRoll(key: string)
	local h = 5381
	for i = 1, #key do
		h = (h * 33 + string.byte(key, i)) % 2147483647
	end
	if h == 0 then
		h = 1
	end
	return function(n: number): number
		h = (h * 48271) % 2147483647
		return (h % n) + 1
	end
end

function View.view(self: any, life: any): any
	self:settlePending(life)
	local pack = self.pack
	local district = self:districtDef(life)
	local side = self:sideDef(life)
	local form = pack.forms[life.form]
	local v = {
		id = life.id,
		alive = life.alive,
		first = life.first,
		last = life.last,
		age = life.age,
		year = life.year,
		-- (BitLeveling) a calendar can say how a year is written (pack.calendar.label)
		yearLabel = if type(pack.calendar.label) == "function" then pack.calendar.label(life.year) else nil,
		bornYear = life.bornYear,
		bornEra = life.bornEra,
		-- the age this life opens in: the one it was born into, or, for a life that starts
		-- grown (a mode), the one the City is in on its first day
		openingEra = life.bornEra or (pack.calendar.openingByWorld and pack.calendar.openingByWorld[life.world.era]) or nil,
		money = life.money,
		sanity = life.sanity,
		stats = Util.deepCopy(life.stats),
		actionsLeft = life.actionsLeft,
		actionsPerYear = self:actionsPerYear(life),
		district = {
			id = life.district,
			name = district.name or life.district,
			number = district.number or 0,
			corp = district.corp,
		},
		side = { id = life.side, name = side.name or life.side, short = side.short or life.side, rich = life.side == pack.sides.order[1] },
		zone = self:zoneLabel(life),
		livingCost = self:livingCost(life),
		wageMult = math.floor(self:wageMult(life) * 100 + 0.5) / 100,
		form = { id = life.form, name = if form then form.name else life.form, desc = if form then form.desc else "" },
		cause = life.cause,
		heirOf = life.heirOf,
		fileNo = tonumber(life.id) and (tonumber(life.id) % 9000 + 1000) or 1000,
		gear = {},
		conditions = {},
		appearance = self:appearance(life),
		generation = life.generation or 1,
		score = self:score(life),
		ambitions = {},
		run = self:runView(life),
		episodes = self:episodesView(life),
		onCrewRun = life.run ~= nil and life.run.crew == true,
		-- (v0.16) a turn-based fight against a big boss: this life's own (the server fills in
		-- a fight with friends, and the one you joined, from every fighter's life)
		battle = if life.battle then self:battleView(life) elseif life.battleWith then { joined = life.battleWith } else nil,
		battleDone = life.battleDone,
		quests = self:questsView(life),
		expeditions = Expedition.list(self, life),
		traits = self:traitsView(life),
		talent = self:talentView(life),
		affinities = self:affinitiesView(life),
		books = self:booksView(life),
		mode = life.mode,
		style = self:styleView(life),
		daily = self:dailyView(life),
		chapter = self:chapterView(life),
		origin = self:originView(life),
		maxHealth = self:maxHealthOf(life),
		renown = Renown.view(self, life),
		office = Renown.officeView(self, life),
		hold = Renown.holdOf(self, life.district),
		markets = self:marketsView(life),
		home = self:homeView(life),
		crisis = self:crisisView(life),
		mood = self:moodView(life),
		-- (v0.18) what the life is about right now (Engine/Focus.luau)
		focus = (require(script.Parent.Focus) :: any).view(self, life),
		household = if life.household then { owns = life.household.owns, business = life.household.business, office = life.household.office } else nil,
		story = self:storyView(life),
		known = self:knownView(life),
		perkTrait = if life.perkTrait and self:traitDef(life.perkTrait) then self:traitDef(life.perkTrait).name else nil,
	}
	for _, a in life.ambitions or {} do
		local def = self:ambitionDef(a.id)
		if def then
			table.insert(v.ambitions, { id = a.id, name = def.name, desc = def.desc, progress = self:ambitionProgress(life, def) })
		end
	end
	for _, g in self:gearIn(life) do
		table.insert(v.gear, { slot = g.slot, id = g.id, name = g.def.name, desc = g.def.desc, effect = g.def.effect, rarity = g.def.rarity, unique = g.def.unique == true, look = g.def.look, set = g.def.set })
	end
	for _, c in life.conditions or {} do
		local def = pack.conditions and pack.conditions[c.id]
		if def then
			table.insert(v.conditions, { id = c.id, name = def.name, desc = def.desc, years = c.years, good = def.good == true or nil })
		end
	end
	if pack.gear then
		v.shop = {}
		for _, id in pack.gear.order or {} do
			local g = pack.gear[id]
			if g.unique then
				continue -- boss drops and other unique items aren't for sale
			end
			local owned = (life.gear ~= nil and life.gear[g.slot] == id) or (life.stash ~= nil and table.find(life.stash, id) ~= nil)
			local ok, why = true, nil
			if g.minAge and life.age < g.minAge then
				ok, why = false, "Age " .. g.minAge .. "+"
			end
			if ok then
				ok, why = Conditions.check(g.requires, life, pack, { noChance = true })
			end
			local price = self:priceFor(life, g.price or 0)
			if ok and life.money < price then
				ok, why = false, "Needs " .. price .. " " .. pack.meta.currency
			end
			if ok and (not life.alive or life.pending) then
				ok, why = false, if life.pending then "Decide first" else "This life is over"
			end
			table.insert(v.shop, {
				id = id,
				name = g.name,
				slot = g.slot,
				price = price,
				listPrice = if price ~= (g.price or 0) then g.price else nil,
				desc = g.desc or "",
				effect = g.effect or "",
				enabled = ok,
				reason = why,
				owned = owned,
				rarity = g.rarity or "common",
				look = g.look,
				minAge = g.minAge,
				set = g.set,
			})
		end
	end
	if life.career then
		local def = pack.careers[life.career.id]
		v.career = {
			id = life.career.id,
			name = self:careerName(life),
			rank = def.ranks[life.career.rank],
			rankIndex = life.career.rank,
			rankCount = #def.ranks,
			salary = self:salaryOf(life),
			years = life.career.years,
			nextAt = if def.promoteAt then def.promoteAt[life.career.rank] else nil,
			promoteStat = def.promoteStat or self.roles.work,
			-- what the next rank is waiting on
			nextRank = def.ranks[life.career.rank + 1],
			statNow = life.stats[def.promoteStat or self.roles.work] or 0,
			rankYears = life.career.rankYears or 0,
			yearsNeed = def.yearsPerRank or 2,
			jobs = life.career.jobs or 0,
			jobsNeed = if pack.jobs then (pack.jobs.perRank or 2) else nil,
		}
	end
	v.world = {}
	for _, var in pack.world do
		local value = life.world[var.key]
		if var.hide and value and var.hide[value] then
			continue -- not something anyone could know about yet
		end
		table.insert(v.world, {
			key = var.key,
			name = var.name or var.key,
			value = value,
			label = if var.labels and value then var.labels[value] else tostring(value),
			note = if var.notes and value then var.notes[value] else nil,
		})
	end
	v.relations = {}
	for _, rel in life.relations do
		local def = pack.relationKinds[rel.kind] or {}
		table.insert(v.relations, {
			id = rel.id,
			kind = rel.kind,
			kindName = if rel.userId then "Linked friend" elseif rel.married and pack.marriage and pack.marriage.on then (pack.marriage.word or "Spouse") elseif rel.formerRival then "Friend (once a rival)" else (def.name or rel.kind),
			married = rel.married == true or nil,
			formerRival = rel.formerRival == true or nil,
			name = rel.first .. (if rel.last ~= "" then " " .. rel.last else ""),
			age = rel.age,
			bond = rel.bond,
			alive = rel.alive,
			fate = rel.fate,
			job = rel.job,
			jobShort = rel.jobShort,
			role = rel.role,
			sheet = if rel.userId then rel.sheet else nil,
			heir = def.heir == true,
			linked = rel.userId ~= nil,
			online = rel.online == true,
			player = rel.player,
			userId = rel.userId,
			interactions = if rel.alive then self:interactionsFor(life, rel) else nil,
			-- linked friends send their real, current look; everyone else has a stored one
			appearance = if rel.userId and rel.appearance
				then rel.appearance
				else {
					look = rel.look or Avatar.randomLook(pack, hashRoll(tostring(life.id) .. ":" .. tostring(rel.id))),
					age = rel.age,
					form = "human",
				},
		})
	end
	if life.pending then
		local event = self.eventsById[life.pending]
		local choices = {}
		-- a scene with someone: the bond it promises is the bond with them
		local sceneCtx = nil
		if life.sceneRel and event.social then
			local rel = self:relationById(life, life.sceneRel)
			if rel then
				sceneCtx = { target = rel }
			end
		end
		for i, c in event.choices do
			local ok, why = Conditions.check(c.requires, life, pack, { noChance = true })
			table.insert(choices, {
				index = i,
				label = self:render(life, c.label),
				hint = if c.battle and pack.bosses and pack.bosses[c.battle]
					then ((if c.hint then self:render(life, c.hint) .. " " else "") .. "A battle in turns: every turn, you choose.")
					elseif c.hint then self:render(life, c.hint)
					else nil,
				enabled = ok,
				reason = why,
				clash = if c.clash and ok then self:clashPreview(life, c.clash) else nil,
				stakes = if c.clash and ok then self:stakesView(c, life, sceneCtx) else nil,
				-- (v0.16) a battle in turns: the way you fight is picked every turn, not here
				battle = if c.battle and pack.bosses and pack.bosses[c.battle] then (pack.bosses[c.battle].name or true) else nil,
				-- a plain choice says what it gives too
				gains = if not c.clash and c.result then self:stakesOf(c.result, nil, nil, life, sceneCtx) else nil,
			})
		end
		local tone = nil
		for _, tag in event.tags or {} do
			if tag == "danger" or tag == "crime" then
				tone = "danger"
			elseif (tag == "strange" or tag == "tidetouched") and tone == nil then
				tone = "strange"
			end
		end
		v.pending = {
			id = event.id,
			title = self:render(life, event.title),
			text = self:render(life, event.text),
			choices = choices,
			tone = tone,
			art = event.art,
			dialogue = if event.dialogue then self:dialogueView(life, event.dialogue) else nil,
			story = if event.story and self.storylinesById[event.story] then { name = self.storylinesById[event.story].name, tone = self.storylinesById[event.story].tone } else nil,
			terms = self:termsIn(life, event),
			why = self:whyOf(life, event),
			thread = self:threadOf(life, event),
			linked = event.when ~= nil and (event.when.linked == true or event.when.linkedRough == true),
			-- (v0.13) a card of an episode shows where it is in it; a card can have a look of its own
			episode = self:episodeTag(event),
			theme = event.theme or (event.episode and pack.episodes and pack.episodes[event.episode] and pack.episodes[event.episode].theme) or nil,
			rare = event.rare == true or nil,
			-- (v0.14) a cutscene played before the card (client/UI/Stage.luau)
			scene = self:sceneView(life, event),
		}
		if v.pending.linked then
			local friend = self:focusLinked(life, event.when.linkedRough == true)
			if friend then
				v.pending.friend = {
					name = friend.first .. (if friend.last ~= "" then " " .. friend.last else ""),
					appearance = friend.appearance,
				}
			end
		end
	end
	v.activities = {}
	local workCtx = self:workCtx(life)
	for _, act in pack.activities do
		local visible, enabled, why = self:activityState(life, act)
		if visible then
			table.insert(v.activities, {
				id = act.id,
				name = self:render(life, act.name) .. (if act.caseId then (self:caseLabel(life, act.caseId) or "") else ""),
				caseId = act.caseId,
				turf = act.turfFoe == true or nil,
				desc = self:render(life, act.desc),
				category = act.category,
				icon = self:activityIcon(act),
				done = life.actUsed[act.id] == life.age,
				gains = if act.result then self:stakesOf(act.result, nil, nil, life, workCtx) elseif act.win then self:stakesOf(act.win, nil, nil, life, workCtx) else nil,
				-- a risk: what each way of going in would win or cost
				stakes = if act.clash and enabled then self:stakesView(act, life, workCtx) else nil,
				family = act.family == true,
				move = act.move,
				shop = act.shop == true,
				market = act.market,
				daily = act.daily == true,
				cost = self:activityCost(life, act),
				enabled = enabled,
				reason = why,
				clash = if act.clash and enabled then self:clashPreview(life, act.clash) else nil,
			})
		end
	end
	v.careers = {}
	for _, id in pack.careers.order do
		local def = pack.careers[id]
		if not (def.company and not district.corp) then
			local ok, why = self:careerState(life, id)
			table.insert(v.careers, {
				id = id,
				name = if def.company then (district.corp or def.name) else def.name,
				desc = def.desc,
				firstRank = def.ranks[1],
				salary = self:salaryFor(life, id, 1),
				enabled = ok,
				reason = why,
				current = life.career ~= nil and life.career.id == id,
			})
		end
	end
	v.rep = self:repView(life)
	local diff = self:difficultyDef(life)
	v.difficulty = if diff then { id = life.difficulty, name = diff.name, color = diff.color } else nil
	v.socialLeft = life.socialLeft
	v.socialPerYear = self:socialPerYear(life)
	v.jobs = Jobs.view(self, life)
	-- (v0.13) the long game: streets, cases, feats, what part of life this is, what you own
	v.turf = self:turfView(life)
	v.cases = self:casesView(life)
	v.feats = self:featsView(life)
	v.phase = self:phaseView(life)
	v.stash = self:stashView(life)
	v.sets = {}
	for _, s in self:activeSets(life) do
		table.insert(v.sets, { id = s.id, name = s.name, pieces = s.pieces, desc = s.bonus.desc })
	end
	v.caps = {}
	for _, key in pack.stats.order or {} do
		if key ~= self.vital then
			v.caps[key] = self:statCap(life, key)
		end
	end
	-- (v0.17) how long this body is good for; a Bloodfiend's blood and its years
	v.lifespan = self:lifespanOf(life)
	v.bloodStage = self:bloodStageName(life)
	v.trainer = self:trainerView(life)
	-- what your stats are doing for you
	v.perks = self:perksView(life)
	local natureId = self:nature(life)
	local natureDef = natureId and pack.stats.natures[natureId]
	v.nature = if natureDef then { stat = natureId, name = natureDef.name, desc = natureDef.desc } else nil
	v.death = life.death
	if not life.alive then
		v.heirs = {}
		for _, rel in self:heirs(life) do
			table.insert(v.heirs, { id = rel.id, name = rel.first .. " " .. rel.last, age = rel.age })
		end
	end
	return v
end

return View
