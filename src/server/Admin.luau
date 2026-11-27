--[[
	The mod menu: whitelisted players can make anything happen.
	Who counts as an admin (Config.admin):
		users = { 523337247, ... }   these Roblox user ids
		owner = true                 the place's owner (for a place owned by a person)
		studio = true                anyone testing in Studio
	Every action is checked here on the server, so the menu can't be faked by a client.
	Announcements go through Roblox's text filter like any other typed text.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Admin = {}


function Admin.install(S)
	local sim = S.sim
	local Content = S.Content
	local handlers = S.handlers
	local cfg = (S.Config and S.Config.admin) or {}

	local function isAdmin(player: Player): boolean
		for _, id in cfg.users or {} do
			if id == player.UserId then
				return true
			end
		end
		if cfg.owner ~= false and game.CreatorType == Enum.CreatorType.User and game.CreatorId == player.UserId and player.UserId > 0 then
			return true
		end
		if cfg.studio ~= false and RunService:IsStudio() then
			return true
		end
		return false
	end
	Admin.isAdmin = isAdmin

	local function sorted(list)
		table.sort(list, function(a, b)
			return a.name < b.name
		end)
		return list
	end

	local catalog = nil
	local catalogCache = nil -- (v0.18) the content doesn't change while the server runs: built once
	local function buildCatalog()
		if catalog then
			return catalog
		end
		catalog = { events = {}, traits = {}, styles = {}, gear = {}, conditions = {}, daily = {}, worldEvents = {}, forms = {}, talents = {},
			-- (v0.17)
			bosses = {}, trainers = {}, techniques = {}, careers = {}, factions = {}, looks = {}, lookOrder = {} }
		for id, def in Content.bosses or {} do
			if type(def) == "table" and def.name then
				table.insert(catalog.bosses, { id = id, name = def.name .. "  (" .. tostring(def.hp or "?") .. " HP)" })
			end
		end
		for _, t in (Content.trainers and Content.trainers.list) or {} do
			table.insert(catalog.trainers, { id = t.id, name = t.name .. " · " .. tostring(t.stat) })
		end
		for _, id in (Content.approaches and Content.approaches.order) or {} do
			local a = Content.approaches[id]
			if a and a.requires and (string.sub(id, 1, 3) == "tq_" or string.sub(id, 1, 4) == "arm_") then
				table.insert(catalog.techniques, { id = id, name = a.name })
			end
		end
		for id, def in Content.careers or {} do
			if type(def) == "table" and def.name then
				table.insert(catalog.careers, { id = id, name = def.name })
			end
		end
		for _, id in (Content.reputation and Content.reputation.order) or {} do
			table.insert(catalog.factions, { id = id, name = Content.reputation[id].name or id })
		end
		for _, catId in (Content.cosmetics and Content.cosmetics.order) or {} do
			local c = Content.cosmetics[catId]
			if c and c.options and catId ~= "frame" then
				table.insert(catalog.lookOrder, catId)
				local opts = {}
				for _, o in c.options do
					table.insert(opts, { id = o.id, name = o.name or o.id })
				end
				catalog.looks[catId] = { name = c.name or catId, options = opts }
			end
		end
		-- (v0.18) talents and traits with what they do, their rarity and their sin, for the cards
		local tierRank = { common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5, unreal = 6 }
		for id, def in Content.traits or {} do
			if type(def) == "table" and def.talent then
				table.insert(catalog.talents, { id = id, name = def.name, tier = def.talent, rank = tierRank[def.talent] or 0, affinity = def.affinity, desc = def.desc })
			end
		end
		table.sort(catalog.talents, function(a, b)
			if a.rank ~= b.rank then
				return a.rank > b.rank
			end
			return a.name < b.name
		end)
		for id, def in Content.forms or {} do
			if type(def) == "table" and not def.terminal then
				table.insert(catalog.forms, { id = id, name = def.name or id })
			end
		end
		for _, e in Content.events do
			table.insert(catalog.events, { id = e.id, name = e.title or e.id })
		end
		for id, def in Content.traits or {} do
			if type(def) == "table" and def.name and not def.talent then
				table.insert(catalog.traits, { id = id, name = def.name, desc = def.desc, earned = def.earn ~= nil })
			end
		end
		for _, id in (Content.styles and Content.styles.order) or {} do
			table.insert(catalog.styles, { id = id, name = Content.styles[id].name })
		end
		for id, def in Content.gear or {} do
			if type(def) == "table" and def.name then
				table.insert(catalog.gear, { id = id, name = def.name })
			end
		end
		for id, def in Content.conditions or {} do
			if type(def) == "table" and def.name then
				table.insert(catalog.conditions, { id = id, name = def.name })
			end
		end
		for _, id in (Content.daily and Content.daily.order) or {} do
			table.insert(catalog.daily, { id = id, name = Content.daily[id].name })
		end
		for id, def in Content.worldEvents or {} do
			if type(def) == "table" and def.name then
				table.insert(catalog.worldEvents, { id = id, name = def.name })
			end
		end
		for key, list in catalog do
			-- (the look categories keep the pack's own order)
			if key ~= "lookOrder" and key ~= "looks" and key ~= "talents" then
				sorted(list)
			end
		end
		return catalog
	end

	local function playersView()
		local out = {}
		for _, p in Players:GetPlayers() do
			local session = S.sessions[p]
			local life = session and session.profile.Data.life
			local entry = { userId = p.UserId, name = p.DisplayName }
			if life then
				entry.life = {
					first = life.first,
					last = life.last,
					age = life.age,
					alive = life.alive,
					stats = table.clone(life.stats),
					sanity = life.sanity,
					money = life.money,
					style = life.style,
					mastery = life.mastery or 0,
					traits = table.clone(life.traits or {}),
					talent = life.talent,
					pending = life.pending ~= nil,
					-- (v0.17)
					form = life.form,
					look = table.clone(life.look or {}),
					caps = {},
					lifespan = sim:lifespanOf(life),
					trainer = life.trainer,
					renown = life.renown or 0,
				}
				for _, k in sim.coreStats do
					entry.life.caps[k] = sim:statCap(life, k)
				end
			end
			table.insert(out, entry)
		end
		return out
	end

	local function catalogOf()
		if not catalogCache then
			catalogCache = buildCatalog()
		end
		return catalogCache
	end

	-- (v0.18) the catalog goes out when the menu opens; every action after that sends the rest
	local function state(withCatalog: boolean?)
		local world = S.WorldEvents and S.WorldEvents.current()
		return {
			players = playersView(),
			catalog = if withCatalog then catalogOf() else nil,
			worldActive = if world then world.id else nil,
			daily = sim.dailyId,
			codes = if S.Codes then S.Codes.list() else {}, -- (v0.17)
		}
	end

	-- pushes a changed life to its player, handling a death
	local function pushLife(targetPlayer: Player, session, report, toast: string?)
		local data = session.profile.Data
		local life = data.life
		local payload = {
			life = if life then sim:view(life) else nil,
			entries = if report then report.entries else nil,
			toast = toast,
			meta = S.metaView(data),
		}
		if life and not life.alive then
			S.recordDeath(session, life)
			payload.lantern = S.lanternFor(data, life.id)
			payload.meta = S.metaView(data)
		end
		S.pushTo(targetPlayer, payload)
	end

	local function filterAnnouncement(player: Player, raw: any): string?
		if type(raw) ~= "string" then
			return nil
		end
		local text = string.sub(string.gsub(raw, "[%c]", " "), 1, 200)
		if #string.gsub(text, "%s", "") == 0 then
			return nil
		end
		local ok, result = pcall(function()
			local filtered = TextService:FilterStringAsync(text, player.UserId, Enum.TextFilterContext.PublicChat)
			return filtered:GetNonChatStringForBroadcastAsync()
		end)
		return if ok and type(result) == "string" then result else nil
	end

	local ops = {}

	function ops.world(_admin, a)
		if type(a.id) ~= "string" then
			return "Pick a world event."
		end
		if a.on == false then
			S.WorldEvents.stop()
			return nil, "World event ended."
		end
		if not S.WorldEvents.start(a.id) then
			return "Couldn't start that world event."
		end
		return nil, "World event started."
	end

	function ops.daily(_admin, a)
		if type(a.id) ~= "string" or not S.City.setDaily(a.id) then
			return "Unknown daily event."
		end
		return nil, "Today's event changed."
	end

	-- (v0.17) redeem codes (server/Codes.luau): make one, or take one away
	function ops.codeAdd(admin, a)
		local Codes = S.Codes
		if not Codes then
			return "Codes aren't running."
		end
		if type(a.code) ~= "string" or type(a.grants) ~= "string" then
			return "Type a code and what it gives."
		end
		local grants, why = Codes.parseGrants(a.grants)
		if not grants then
			return why
		end
		local note = if type(a.note) == "string" and a.note ~= "" then string.sub(a.note, 1, 120) else nil
		if note then
			note = filterAnnouncement(admin, note) or nil
		end
		local err = Codes.add(a.code, grants, note, tonumber(a.days), admin.Name)
		if err then
			return err
		end
		return nil, "Code " .. Codes.norm(a.code) .. " is live."
	end

	function ops.codeRemove(_admin, a)
		local Codes = S.Codes
		if not Codes or type(a.code) ~= "string" then
			return "Pick a code."
		end
		local err = Codes.remove(a.code)
		if err then
			return err
		end
		return nil, "Code removed."
	end

	function ops.announce(admin, a)
		local text = filterAnnouncement(admin, a.text)
		if not text then
			return "Type something to announce."
		end
		S.City.news("[ANNOUNCEMENT] " .. text, "admin")
		return nil, "Announced."
	end

	-- the rest act on one player's life
	local lifeOps = {}

	function lifeOps.event(life, a)
		if type(a.id) ~= "string" then
			return nil, "Pick an event."
		end
		return sim:forceEvent(life, a.id)
	end

	function lifeOps.stat(life, a)
		local value = tonumber(a.value)
		if not value then
			return nil, "Enter a number."
		end
		local report = sim.newReport()
		if table.find(sim.coreStats, a.stat) then
			-- (v0.13) up to the stat's own limit, which can be past 100. (v0.17) Past it, the limit
			-- goes up to meet it: the mod menu can set a stat to 400.
			value = math.clamp(math.floor(value), 0, 2000)
			if a.stat ~= sim.vital and value > sim:statCap(life, a.stat) then
				life.capBonus = life.capBonus or {}
				life.capBonus[a.stat] = (life.capBonus[a.stat] or 0) + (value - sim:statCap(life, a.stat))
			end
			life.stats[a.stat] = if a.stat == sim.vital then value else math.min(value, sim:statCap(life, a.stat))
		elseif a.stat == "sanity" then
			local sc = Content.stats.sanity
			life.sanity = math.clamp(math.floor(value), sc.min, sc.max)
		elseif a.stat == "money" then
			life.money = math.floor(value)
		elseif a.stat == "age" then
			life.age = math.clamp(math.floor(value), 0, 1000) -- (v0.17) lives can go on that long
		elseif a.stat == "renown" then
			-- (v0.12) renown points: grades, perks and announcements follow
			sim:addRenown(life, math.max(0, math.floor(value)) - (life.renown or 0), report)
		else
			return nil, "Unknown stat."
		end
		sim:push(life, report, { kind = "system", text = "Something changed. (" .. tostring(a.stat) .. " set to " .. math.floor(value) .. ")" })
		return report
	end

	function lifeOps.heal(life)
		local report = sim.newReport()
		life.stats[sim.vital] = math.max(life.stats[sim.vital], 80)
		life.sanity = math.max(life.sanity, 0)
		life.conditions = {}
		sim:push(life, report, { kind = "system", tone = "good", text = "You feel whole again." })
		return report
	end

	function lifeOps.trait(life, a)
		local report = sim.newReport()
		local extra = {}
		if a.on == false then
			sim:removeTrait(life, a.id, extra)
		elseif not sim:addTrait(life, a.id, extra) then
			return nil, "Unknown trait, or they have it."
		end
		for _, e in extra do
			sim:push(life, report, e)
		end
		return report
	end

	function lifeOps.style(life, a)
		local report = sim.newReport()
		local extra = {}
		sim:setStyle(life, a.id, extra)
		if a.mastery ~= nil and tonumber(a.mastery) then
			life.mastery = math.clamp(math.floor(tonumber(a.mastery) :: number), 0, Content.maxMastery or 5)
			table.insert(extra, { kind = "system", text = "Mastery set to " .. life.mastery .. "." })
		end
		for _, e in extra do
			sim:push(life, report, e)
		end
		return report
	end

	-- what they are: human, E.G.O, Bloodfiend (terminal forms like Distortion are left out)
	function lifeOps.form(life, a)
		local def = type(a.id) == "string" and Content.forms and Content.forms[a.id]
		if not def or def.terminal then
			return nil, "Pick a form."
		end
		if life.form == a.id then
			return nil, "They already are."
		end
		local report = sim.newReport()
		local extra = {}
		sim:setForm(life, a.id, extra)
		for _, e in extra do
			sim:push(life, report, e)
		end
		return report
	end

	-- swap the life's talent (any tier, Unreal included)
	function lifeOps.talent(life, a)
		local def = type(a.id) == "string" and Content.traits and Content.traits[a.id]
		if not def or not def.talent then
			return nil, "Pick a talent."
		end
		local report = sim.newReport()
		local extra = {}
		if life.talent and life.talent ~= a.id then
			sim:removeTrait(life, life.talent, extra)
		end
		sim:addTrait(life, a.id, extra)
		life.talent = a.id
		life.talentWake = nil -- a talent set from the mod menu is awake at once
		table.insert(extra, { kind = "system", tone = "strange", text = "Talent: " .. def.name .. "." })
		for _, e in extra do
			sim:push(life, report, e)
		end
		return report
	end

	function lifeOps.gear(life, a)
		local report = sim.newReport()
		local extra = {}
		if not (Content.gear and Content.gear[a.id]) then
			return nil, "Unknown gear."
		end
		sim:giveGear(life, a.id, extra)
		for _, e in extra do
			sim:push(life, report, e)
		end
		return report
	end

	function lifeOps.condition(life, a)
		local report = sim.newReport()
		local extra = {}
		if a.on == false then
			sim:cureCondition(life, a.id, extra)
		elseif Content.conditions and Content.conditions[a.id] then
			sim:addCondition(life, a.id, extra)
		else
			return nil, "Unknown condition."
		end
		for _, e in extra do
			sim:push(life, report, e)
		end
		return report
	end

	-- ── (v0.17) character customization: any part of the look, the body included ──
	function lifeOps.look(life, a)
		local report = sim.newReport()
		life.look = life.look or {}
		if a.random then
			local Avatar = S.Engine.Avatar
			life.look = Avatar.randomLook(Content, function(n)
				return math.random(1, n)
			end)
		else
			local cat = type(a.category) == "string" and Content.cosmetics and Content.cosmetics[a.category]
			if not cat or a.category == "frame" then
				return nil, "Pick a part of the look."
			end
			local found = nil
			for _, o in cat.options do
				if o.id == a.id then
					found = o
				end
			end
			if not found then
				return nil, "Pick an option."
			end
			life.look[a.category] = found.id
		end
		sim:push(life, report, { kind = "system", text = "You look different. (" .. tostring(a.category or "everything") .. ")" })
		return report
	end

	-- every limit, or one, raised
	function lifeOps.limitBreak(life, a)
		local n = math.clamp(math.floor(tonumber(a.amount) or 0), -1000, 1000)
		if n == 0 then
			return nil, "Enter an amount."
		end
		local key = if type(a.stat) == "string" and a.stat ~= "" then a.stat else "all"
		life.capBonus = life.capBonus or {}
		life.capBonus[key] = (life.capBonus[key] or 0) + n
		local report = sim.newReport()
		sim:push(life, report, { kind = "system", tone = "good", text = string.format("A limit moved: %s %+d.", key, n) })
		return report
	end

	-- every stat at a value (the limits rise to meet it), Health to its maximum
	function lifeOps.maxStats(life, a)
		local report = sim.newReport()
		local target = math.floor(tonumber(a.value) or 0)
		life.capBonus = life.capBonus or {}
		for _, k in sim.coreStats do
			if k ~= sim.vital then
				local want = if target > 0 then target else sim:statCap(life, k)
				if want > sim:statCap(life, k) then
					life.capBonus[k] = (life.capBonus[k] or 0) + (want - sim:statCap(life, k))
				end
				life.stats[k] = math.min(want, sim:statCap(life, k))
			end
		end
		life.stats[sim.vital] = sim:maxHealthOf(life)
		sim:push(life, report, { kind = "system", tone = "good", text = "Every stat set to " .. (if target > 0 then tostring(target) else "its limit") .. "." })
		return report
	end

	function lifeOps.lifespan(life, a)
		local n = math.floor(tonumber(a.amount) or 0)
		if n == 0 then
			return nil, "Enter a number of years."
		end
		life.lifespanBonus = (life.lifespanBonus or 0) + n
		local report = sim.newReport()
		sim:push(life, report, { kind = "system", tone = "good", text = string.format("Lifespan %+d years (now about %d).", n, sim:lifespanOf(life)) })
		return report
	end

	-- a boss battle in turns, any boss (the extreme ones too)
	function lifeOps.battle(life, a)
		local Battle = S.Engine.Battle
		if type(a.id) ~= "string" or not Battle.def(sim, a.id) then
			return nil, "Pick a boss."
		end
		if life.run then
			return nil, "They're on an expedition."
		end
		-- (an admin's battle replaces whatever fight they were in)
		life.battle = nil
		life.battleWith = nil
		life.duel = nil
		life.pending = nil
		Battle.begin(sim, life, a.id, { title = Battle.def(sim, a.id).name })
		local report = sim.newReport()
		report.battle = true
		return report
	end

	function lifeOps.trainer(life, a)
		local Training = S.Engine.Training
		if not Training.def(sim, a.id) then
			return nil, "Pick a trainer."
		end
		local report = sim.newReport()
		S.Engine.Effects.apply(sim, life, { train = { start = a.id } }, report)
		return report
	end

	function lifeOps.technique(life, a)
		local def = type(a.id) == "string" and Content.approaches and Content.approaches[a.id]
		if not def then
			return nil, "Pick a technique."
		end
		local report = sim.newReport()
		if string.sub(a.id, 1, 4) == "arm_" then
			-- an arm's way of fighting comes with the arm
			local gearId = def.requires and def.requires.hasGear
			if gearId and Content.gear[gearId] then
				local extra = {}
				sim:giveGear(life, gearId, extra)
				for _, e in extra do
					sim:push(life, report, e)
				end
			end
		else
			life.flags[a.id] = true
		end
		sim:push(life, report, { kind = "system", tone = "good", text = "Learned " .. def.name .. "." })
		return report
	end

	function lifeOps.flag(life, a)
		if type(a.id) ~= "string" or a.id == "" then
			return nil, "Type a flag."
		end
		life.flags[a.id] = if a.on == false then nil else true
		local report = sim.newReport()
		sim:push(life, report, { kind = "system", text = "Flag " .. a.id .. (if a.on == false then " cleared." else " set.") })
		return report
	end

	-- (v0.18) an Office of their own (they name it themselves)
	function lifeOps.office(life)
		return sim:foundOffice(life)
	end

	function lifeOps.rep(life, a)
		local value = tonumber(a.value)
		if type(a.id) ~= "string" or not (Content.reputation and Content.reputation[a.id]) or not value then
			return nil, "Pick a faction and a value."
		end
		life.rep = life.rep or {}
		life.rep[a.id] = math.clamp(math.floor(value), -100, 100)
		local report = sim.newReport()
		sim:push(life, report, { kind = "system", text = "Standing with " .. (Content.reputation[a.id].name or a.id) .. ": " .. life.rep[a.id] .. "." })
		return report
	end

	function lifeOps.career(life, a)
		if type(a.id) ~= "string" or not (Content.careers and Content.careers[a.id]) then
			return nil, "Pick a career."
		end
		local report = sim.newReport()
		local extra = {}
		sim:setCareer(life, a.id, extra)
		local rank = tonumber(a.rank)
		if rank and life.career then
			life.career.rank = math.max(0, math.floor(rank))
		end
		for _, e in extra do
			sim:push(life, report, e)
		end
		return report
	end

	-- years as a Bloodfiend: old blood stages that are due come at once
	function lifeOps.bloodYears(life, a)
		if life.form ~= "bloodfiend" then
			return nil, "They aren't a Bloodfiend. Set the form first."
		end
		local n = math.max(0, math.floor(tonumber(a.value) or 0))
		life.formAt = life.age - n
		local report = sim.newReport()
		local extra = {}
		sim:elderBlood(life, extra)
		for _, e in extra do
			sim:push(life, report, e)
		end
		sim:push(life, report, { kind = "system", text = "Their blood is " .. n .. " years old." })
		return report
	end

	function lifeOps.color(life)
		local report = sim.newReport()
		local extra = {}
		sim:addTrait(life, "color_fixer", extra)
		for _, e in extra do
			sim:push(life, report, e)
		end
		return report
	end

	function lifeOps.kill(life)
		local report = sim.newReport()
		sim:kill(life, report, "Taken by something nobody saw coming")
		return report
	end

	-- account-level gifts (no life needed)
	local dataOps = {}

	function dataOps.rolls(data, a)
		data.rolls = math.max(0, (data.rolls or 0) + math.floor(tonumber(a.amount) or 0))
		return "Rolls: " .. data.rolls .. "."
	end

	function dataOps.glow(data, a)
		data.glow = math.max(0, (data.glow or 0) + math.floor(tonumber(a.amount) or 0))
		return ((Content.meta and Content.meta.glowName) or "Glow") .. ": " .. data.glow .. "."
	end

	function dataOps.lunacy(data, a)
		data.lunacy = math.max(0, (data.lunacy or 0) + math.floor(tonumber(a.amount) or 0))
		return ((Content.meta and Content.meta.premiumName) or "Lunacy") .. ": " .. data.lunacy .. "."
	end

	function dataOps.unlockAll(data)
		for _, catId in { "skin", "hair", "hairColor", "outfit", "mark", "frame", "accessory", "eyes", "body", "weapon" } do
			local cat = Content.cosmetics and Content.cosmetics[catId]
			for _, o in (cat and cat.options) or {} do
				data.cosmetics[catId .. ":" .. o.id] = true
			end
		end
		for _, o in Content.origins do
			data.unlocked[o.id] = true
		end
		for _, m in Content.modes or {} do
			data.unlocked["mode:" .. m.id] = true
		end
		return "Everything unlocked."
	end

	function handlers.adminState(player)
		if not isAdmin(player) then
			return { ok = false, error = "Not allowed." }
		end
		return { ok = true, admin = state(true) }
	end

	function handlers.admin(player, _session, payload)
		if not isAdmin(player) then
			return { ok = false, error = "Not allowed." }
		end
		if type(payload) ~= "table" or type(payload.op) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local op = payload.op
		print(string.format("[LifeSim admin] %s (%d): %s %s", player.Name, player.UserId, op, tostring(payload.id or payload.stat or payload.target or "")))
		if ops[op] then
			local err, toast = ops[op](player, payload)
			if err then
				return { ok = false, error = err }
			end
			return { ok = true, toast = toast, admin = state() }
		end
		local target = if type(payload.target) == "number" then Players:GetPlayerByUserId(payload.target) else nil
		local session = target and S.sessions[target]
		if not session then
			return { ok = false, error = "Pick a player who's in the server." }
		end
		local data = session.profile.Data
		if dataOps[op] then
			local toast = dataOps[op](data, payload)
			S.pushTo(target, { meta = S.metaView(data), toast = "An admin sent you something." })
			return { ok = true, toast = toast, admin = state() }
		end
		local fn = lifeOps[op]
		if not fn then
			return { ok = false, error = "Unknown action." }
		end
		local life = data.life
		if not life or not life.alive then
			return { ok = false, error = "They aren't living a life right now." }
		end
		local report, err = fn(life, payload)
		if not report then
			return { ok = false, error = err or "That didn't work." }
		end
		pushLife(target, session, report, "Something in the City shifted around you.")
		return { ok = true, toast = "Done.", admin = state() }
	end
end

return Admin
