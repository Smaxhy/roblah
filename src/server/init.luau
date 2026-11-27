--[[
	LifeSim server.
	Server-authoritative: the client only ever asks for actions; every roll,
	stat change and save happens here.

	Remotes (in ReplicatedStorage.LifeSim.Remotes):
		Request (RemoteFunction)  client -> server: Request:InvokeServer(action, payload) -> response
		Push    (RemoteEvent)     server -> client: live updates (linked friends, invites, toasts)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local ProfileStore = require(script.ProfileStore)
local Leaderboards = require(script.Leaderboards)
local Crews = require(script.Crews)
local WorldEvents = require(script.WorldEvents)
local Store = require(script.Store)
local Codes = require(script.Codes)
local City = require(script.City)
local Surnames = require(script.Surnames)
local Admin = require(script.Admin)
local Progress = require(script.Progress)
local Guide = require(script.Guide)
local Duels = require(script.Duels)
local Battles = require(script.Battles)

local Server = {}

local started = false

local TEMPLATE = {
	version = 2,
	lanterns = {},
	glow = 0,
	unlocked = {},
	livesPlayed = 0,
	bestAge = 0,
	links = {}, -- [tostring(userId)] = { name = displayName, since = os.time() }
	records = {}, -- [recordId] = os.time() when first earned
	cosmetics = {}, -- ["category:id"] = true for cosmetics unlocked (Glow, store, streaks)
	lastLook = nil, -- the look picked for the last life (the creator starts from it)
	owned = {}, -- [store item key] = true
	receipts = {}, -- recent store PurchaseIds, so a receipt is never granted twice
	daily = { lastDay = 0, streak = 0 },
	bests = {}, -- personal bests already sent to the leaderboards
	settings = { rough = false, music = true, musicVolume = 0.6, sfxVolume = 0.8, uiScale = "auto", effects = true, intro = "short" },
	codex = {}, -- [lore entry id] = os.time() when first found (lore is kept across lives)
	surname = nil, -- { name, tier } once rolled; new lives carry it
	pendingSurname = nil, -- a roll waiting to be kept or passed on
	rolls = 3, -- surname rolls in hand (earned by playing, never sold)
	pity = 0, -- rolls since the last Rare or better
	lunacy = 0, -- the premium currency (earned a little by playing, bought in the store)
	pendingTalent = nil, -- the talent the next life is born with (rolled before it starts)
	talentFree = nil, -- { day, used }: today's free talent rerolls
	talentPity = 0, -- Rare-or-better rerolls since the last Legendary or better
	affinities = {}, -- up to two sins the player leans toward (shape talent rolls)
	dailyEventDay = 0, -- the day today's City event was last done
	stories = {}, -- [storyline id] = { lives = n, endings = { [ending] = true } }: the stories this player has lived
	recentStories = {}, -- the last few storyline ids (so the next birth rolls a different one)
	recentEvents = {}, -- what the last few lives met: those events are much rarer in the next
	difficulty = nil, -- the difficulty last picked (the start screen remembers it)
	flags = {}, -- seenIntro, tutorialDone
	-- life = nil (the current life lives here once started)
}

local LOG_TAIL = 150
local RATE_WINDOW = 1 -- seconds
local RATE_MAX = 8 -- requests per window
local MAX_LINKS = 8
local INVITE_TTL = 120 -- seconds
local DAILY_GLOW = { 1, 1, 2, 1, 2, 2, 4 } -- Glow for days 1-7 of a login streak (then it repeats)

local function tail(list, n: number)
	local out = {}
	for i = math.max(1, #list - n + 1), #list do
		table.insert(out, list[i])
	end
	return out
end

local function titleCase(s: string): string
	return (string.gsub(string.lower(s), "(%a)([%w'%-]*)", function(a, b)
		return string.upper(a) .. b
	end))
end

-- Player-typed names must go through Roblox's text filter before anyone sees them.
local function filterName(player: Player, raw: any): string?
	if type(raw) ~= "string" then
		return nil
	end
	local cleaned = string.gsub(raw, "[^%a%-' ]", "")
	cleaned = string.gsub(cleaned, "^%s+", "")
	cleaned = string.gsub(cleaned, "%s+$", "")
	cleaned = string.sub(cleaned, 1, 16)
	if #cleaned < 2 then
		return nil
	end
	local ok, result = pcall(function()
		local filtered = TextService:FilterStringAsync(cleaned, player.UserId, Enum.TextFilterContext.PublicChat)
		return filtered:GetNonChatStringForBroadcastAsync()
	end)
	if not ok or type(result) ~= "string" or string.find(result, "#", 1, true) then
		return nil
	end
	return titleCase(result)
end

-- (v0.18) an Office's name or motto: letters, digits, spaces and a little punctuation, then
-- Roblox's filter. Anything it hashes out isn't used.
local function filterOfficeText(player: Player, raw: any, maxLen: number): string?
	if type(raw) ~= "string" then
		return nil
	end
	local cleaned = string.gsub(raw, "[^%w%-'&%.,!%? ]", "")
	cleaned = string.gsub(cleaned, "%s+", " ")
	cleaned = string.gsub(cleaned, "^%s+", "")
	cleaned = string.gsub(cleaned, "%s+$", "")
	cleaned = string.sub(cleaned, 1, maxLen)
	if #cleaned < 2 then
		return nil
	end
	local ok, result = pcall(function()
		local filtered = TextService:FilterStringAsync(cleaned, player.UserId, Enum.TextFilterContext.PublicChat)
		return filtered:GetNonChatStringForBroadcastAsync()
	end)
	if not ok or type(result) ~= "string" or string.find(result, "#", 1, true) then
		return nil
	end
	return result
end

function Server.start()
	if started then
		return
	end
	started = true

	local Shared = ReplicatedStorage:WaitForChild("LifeSim")
	local Engine = require(Shared:WaitForChild("Engine"))
	local Content = require(Shared:WaitForChild("Pack"))
	Leaderboards.setCurrency(Content.meta.currency)
	local Config = require(Shared:WaitForChild("Config"))

	-- Validate the content pack so authoring mistakes show up in Output right away.
	local issues = Engine.Validate.run(Content)
	for _, e in issues.errors do
		warn("[LifeSim] content error: " .. e)
	end
	if Config.verboseValidation then
		for _, w in issues.warnings do
			warn("[LifeSim] content warning: " .. w)
		end
	end
	print(string.format("[LifeSim] %s loaded: %d events, %d errors, %d warnings", Content.meta.title, #Content.events, #issues.errors, #issues.warnings))

	local sim = Engine.new(Content)
	local Avatar = Engine.Avatar

	-- the stories this player has lived: every storyline, named only once it's been lived
	local function storiesView(data)
		local list, lived = {}, 0
		for _, sl in Content.storylines or {} do
			local rec = data.stories and data.stories[sl.id]
			if rec then
				lived += 1
				local endings = {}
				for ending in rec.endings or {} do
					table.insert(endings, ending)
				end
				table.sort(endings)
				table.insert(list, { id = sl.id, name = sl.name, tone = sl.tone, lives = rec.lives or 1, endings = endings })
			end
		end
		return { total = #(Content.storylines or {}), lived = lived, list = list }
	end

	local function originInfo(data)
		local list = {}
		for _, o in Content.origins do
			table.insert(list, {
				id = o.id,
				name = o.name,
				desc = o.desc,
				side = if o.side then (Content.sides[o.side] or {}).short else nil,
				cost = o.glowCost or 0,
				unlocked = (o.glowCost or 0) <= 0 or data.unlocked[o.id] == true,
			})
		end
		return list
	end

	-- Static info the UI needs (names, colors, labels). Sent once on hello.
	local info = {
		meta = Content.meta,
		stats = { order = Content.stats.order, defs = {}, sanity = Content.stats.sanity, vital = Content.stats.vital or "fortitude", roles = Content.stats.roles or {}, word = Content.stats.word or "virtue" },
		city = sim:cityInfo(),
		categories = Content.activityCategories,
		approaches = {},
	}
	for _, id in (Content.approaches and Content.approaches.order) or {} do
		info.approaches[id] = Content.approaches[id].name
	end
	-- the difficulties a life can be started on (the start screen)
	if Content.difficulties then
		info.difficulties = { default = Content.difficulties.default, list = {} }
		for _, id in Content.difficulties.order do
			local d = Content.difficulties[id]
			table.insert(info.difficulties.list, { id = id, name = d.name, desc = d.desc, color = d.color })
		end
	end
	info.socialPerYear = Content.meta.socialPerYear
	-- what the client needs to draw avatars: the cosmetics catalog and the looks
	-- of gear, conditions and forms (not the whole content pack)
	info.avatar = { cosmetics = Content.cosmetics, gear = {}, conditions = {}, forms = {} }
	for id, g in Content.gear or {} do
		if type(g) == "table" and g.look then
			info.avatar.gear[id] = { look = g.look, slot = g.slot }
		end
	end
	for id, c in Content.conditions or {} do
		if c.look then
			info.avatar.conditions[id] = { look = c.look }
		end
	end
	for id, f in Content.forms or {} do
		if f.look then
			info.avatar.forms[id] = { look = f.look }
		end
	end
	for _, key in Content.stats.order do
		local s = Content.stats[key]
		info.stats.defs[key] = { name = s.name, short = s.short, color = s.color, desc = s.desc }
	end
	-- (v0.13) the names of the Workshop lines sold as sets
	info.gearSets = {}
	for id, s in (Content.gear and Content.gear.sets) or {} do
		info.gearSets[id] = s.name
	end
	-- the build screen: pickable traits, fighting styles, bonus stat points
	info.traitPicks = Content.traitPicks or 2
	-- eras of birth the player can pick in the creator
	info.eras = {}
	for _, e in (Content.calendar and Content.calendar.eras) or {} do
		table.insert(info.eras, { id = e.id, name = e.name, desc = e.desc, years = e.years, default = e.default == true, has = e.has, opening = e.opening })
	end
	-- (with calendar.rollEra, picking no age lets the City decide)
	info.rollEra = Content.calendar ~= nil and Content.calendar.rollEra == true
	-- sins are dealt at birth, not picked; weapons are found in play, not in the creator
	info.affinityPick = not Content.affinityRoll
	info.schools = Content.schools ~= nil
	info.creatorWeapons = Content.schools == nil
	info.traits = {}
	for _, id in (Content.traits and Content.traits.order) or {} do
		local t = Content.traits[id]
		table.insert(info.traits, { id = id, name = t.name, desc = t.desc, pick = t.pick == true, rarity = t.rarity, category = t.category, talent = t.talent, style = t.style })
	end
	info.styles = {}
	for _, id in (Content.styles and Content.styles.order) or {} do
		local st = Content.styles[id]
		table.insert(info.styles, { id = id, name = st.name, desc = st.desc, color = st.color, status = st.status or id })
	end
	info.statuses = Content.statuses
	info.build = Content.build
	info.buildPresets = Content.buildPresets
	info.modernCreator = Content.modernCreator == true -- (blueprint) Base packs: the one-screen creator
	info.maxMastery = Content.maxMastery or 5
	info.quickChecks = Content.quickChecks == true
	-- v0.8: rolled births (no origin, District or build picks), Cantos, Intervallos, approaches
	info.creatorPicks = Content.creatorPicks ~= false
	info.chapterWord = Content.chapterWord
	info.interludeWord = Content.interludeWord
	info.cantos = Content.chapters
	info.intervallos = Content.intervallos
	info.approachDefs = Content.approaches -- (info.approaches stays id -> name, which the fight screen reads)
	info.fanWork = Content.fanWork == true
	info.intro = Content.intro
	-- (blueprint) the game's look (Base.build: spec.theme, spec.places, spec.vfx, spec.backdrop)
	info.theme = Content.theme
	info.places = Content.places
	info.vfx = Content.vfx
	info.backdrop = Content.backdrop
	info.tutorial = Content.tutorial
	-- the lore panel: titles and categories (the text comes once an entry is found)
	if Content.codex then
		info.codex = { categories = Content.codex.categories, entries = {} }
		for _, e in Content.codex.entries do
			table.insert(info.codex.entries, { id = e.id, category = e.category, title = e.title, secret = e.secret == true })
		end
	end

	local remotes = Shared:FindFirstChild("Remotes")
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = "Remotes"
		remotes.Parent = Shared
	end
	local request = Instance.new("RemoteFunction")
	request.Name = "Request"
	request.Parent = remotes
	local push = Instance.new("RemoteEvent")
	push.Name = "Push"
	push.Parent = remotes

	local store = ProfileStore.New(Config.dataStoreName, TEMPLATE)
	local sessions: { [Player]: any } = {}
	local invites: { [number]: { [number]: number } } = {} -- [toUserId][fromUserId] = os.clock()

	-- (v0.15) the stories everyone on this server is living right now: a new life (or a second
	-- story) rolls one of these far less, so two players don't get the same story
	sim.storiesInPlayFn = function()
		local set = {}
		for _, s in sessions do
			local l = s.profile and s.profile.Data and s.profile.Data.life
			if l and l.alive and type(l.story) == "string" then
				set[l.story] = true
			end
		end
		return set
	end

	local function sessionOf(userId: number)
		local p = Players:GetPlayerByUserId(userId)
		if p then
			return sessions[p], p
		end
		return nil, nil
	end

	local function metaView(data)
		local records = {}
		for _, r in Content.records or {} do
			table.insert(records, { id = r.id, name = r.name, desc = r.desc, unlocked = data.records[r.id] ~= nil })
		end
		return {
			glow = data.glow,
			livesPlayed = data.livesPlayed,
			bestAge = data.bestAge,
			-- (v0.13) every feat this player has ever earned, in any life
			featsEver = data.featsEver,
			lanterns = data.lanterns,
			origins = originInfo(data),
			records = records,
			cosmetics = data.cosmetics,
			lastLook = data.lastLook,
			difficulty = data.difficulty,
			owned = data.owned,
			settings = data.settings,
			bests = data.bests,
			daily = data.daily,
			codex = data.codex or {},
			surname = data.surname,
			rolls = data.rolls or 0,
			premiumRolls = data.premiumRolls or 0,
			perks = data.perks or {},
			pendingBoosts = #(data.pendingBoosts or {}),
			flags = data.flags or {},
			dailyEventDay = data.dailyEventDay or 0,
			lunacy = data.lunacy or 0,
			stories = storiesView(data),
			modes = Progress.modesUnlocked(data),
			talentFree = if Progress.enabled() then Progress.freeLeft(data) else 0,
		}
	end

	local function canUseCosmetic(data)
		return function(category, option)
			return Avatar.usable(category, option, data.cosmetics, data.records)
		end
	end

	local function lanternFor(data, lifeId)
		for _, l in data.lanterns do
			if l.id == lifeId then
				return l
			end
		end
		return nil
	end

	-- ── linked friends ──────────────────────────────────────────────────────

	-- Refreshes the linked-friend relations in this player's life from the
	-- friends' current lives (name, age, online, rough play).
	local function syncLinks(session)
		local data = session.profile.Data
		local life = data.life
		if not life or not life.alive then
			return
		end
		local myRough = data.settings and data.settings.rough == true
		local linkedIds = {}
		for key, link in data.links do
			local userId = tonumber(key)
			if userId then
				linkedIds[userId] = true
				local other = sessionOf(userId)
				local otherLife = other and other.profile.Data.life
				if other and otherLife and otherLife.alive then
					local theirRough = other.profile.Data.settings and other.profile.Data.settings.rough == true
					sim:linkFriend(life, {
						userId = userId,
						first = otherLife.first,
						last = otherLife.last,
						age = otherLife.age,
						online = true,
						rough = myRough and theirRough,
						player = link.name,
						appearance = sim:appearance(otherLife),
						sheet = sim:friendSheet(otherLife),
					})
				else
					for _, rel in life.relations do
						if rel.userId == userId then
							rel.online = false
						end
					end
				end
			end
		end
		for _, rel in life.relations do
			if rel.userId and not linkedIds[rel.userId] then
				sim:unlinkFriend(life, rel.userId)
			end
		end
	end

	local function pushTo(player: Player?, payload)
		if player and player.Parent == Players then
			push:FireClient(player, payload)
		end
	end

	local recordDeath -- forward declaration

	-- Delivers effects that one player's event sent to a linked friend.
	local function deliver(fromPlayer: Player, outbox)
		for _, msg in outbox do
			local target, targetPlayer = sessionOf(msg.userId)
			local targetLife = target and target.profile.Data.life
			local linked = target and target.profile.Data.links[tostring(fromPlayer.UserId)] ~= nil
			if target and targetLife and targetLife.alive and linked then
				syncLinks(target)
				local report = sim:applyLinked(targetLife, msg.result, msg.from, { userId = fromPlayer.UserId, title = msg.title, choice = msg.choice })
				local payload = {
					life = sim:view(targetLife),
					entries = report.entries,
					toast = if msg.title then msg.from .. ": " .. msg.title else "Something from " .. msg.from .. " came your way.",
				}
				if not targetLife.alive then
					recordDeath(target, targetLife)
					payload.lantern = lanternFor(target.profile.Data, targetLife.id)
					payload.meta = metaView(target.profile.Data)
				end
				pushTo(targetPlayer, payload)
			end
		end
	end

	-- Tells linked friends (who are online) that this player's character died.
	local function notifyDeath(session, player: Player, life)
		for key in session.profile.Data.links do
			local userId = tonumber(key)
			local other, otherPlayer = nil, nil
			if userId then
				other, otherPlayer = sessionOf(userId)
			end
			local otherLife = other and other.profile.Data.life
			if other and otherLife and otherLife.alive then
				local extra = {}
				for _, rel in otherLife.relations do
					if rel.userId == player.UserId and rel.alive then
						sim:relationDied(otherLife, rel, extra, "Your linked friend " .. life.first .. " " .. life.last .. " " .. sim:endingPhrase(life) .. ", at " .. life.age .. ".")
						rel.fate = (sim:endingOf(life) or {}).short
					end
				end
				local report = sim.newReport()
				for _, e in extra do
					sim:push(otherLife, report, e)
				end
				pushTo(otherPlayer, { life = sim:view(otherLife), entries = report.entries })
			end
		end
	end

	-- Tells online linked friends what just happened in this player's life (news
	-- lines go into their log) and refreshes how this character looks to them.
	local function shareWithFriends(player: Player, session, news)
		local data = session.profile.Data
		local life = data.life
		if not life then
			return
		end
		for key in data.links do
			local userId = tonumber(key)
			local other, otherPlayer = nil, nil
			if userId then
				other, otherPlayer = sessionOf(userId)
			end
			local otherLife = other and other.profile.Data.life
			if other and otherLife and otherLife.alive and other.profile.Data.links[tostring(player.UserId)] then
				syncLinks(other)
				local report = sim.newReport()
				for _, line in news or {} do
					sim:push(otherLife, report, { kind = "friend", name = life.first .. " " .. life.last, userId = player.UserId, text = line })
				end
				pushTo(otherPlayer, { life = sim:view(otherLife), entries = report.entries })
			end
		end
	end

	function recordDeath(session, life)
		local data = session.profile.Data
		if lanternFor(data, life.id) then
			return
		end
		-- the story this life lived, and how it ended (the player's collection)
		if life.story then
			data.stories = data.stories or {}
			local rec = data.stories[life.story] or { lives = 0, endings = {} }
			rec.lives = (rec.lives or 0) + 1
			if life.storyEnding then
				rec.endings = rec.endings or {}
				rec.endings[life.storyEnding] = true
			end
			data.stories[life.story] = rec
		end
		local lantern = sim:lantern(life)
		-- records earned for the first time pay out 1 Glow each
		local fresh = {}
		for _, id in sim:checkRecords(life) do
			if not data.records[id] then
				data.records[id] = os.time()
				data.glow = (data.glow or 0) + 1
				for _, r in Content.records do
					if r.id == id then
						table.insert(fresh, r.name)
					end
				end
			end
		end
		if #fresh > 0 then
			lantern.records = fresh
		end
		lantern.lunacy = Progress.onLifeEnd(data, #fresh)
		table.insert(data.lanterns, 1, lantern)
		-- every finished life earns a surname roll
		data.rolls = (data.rolls or 0) + 1
		if Config.chatNews ~= false and life.age >= 95 then
			City.news(string.format("%s %s %s at %d. %s", life.first, life.last, sim:endingPhrase(life), life.age, lantern.title or "A long life in the City."), "good")
		end
		while #data.lanterns > (Config.maxLanterns or 60) do
			local removed = false
			for i = #data.lanterns, 1, -1 do
				if data.lanterns[i].released then
					table.remove(data.lanterns, i)
					removed = true
					break
				end
			end
			if not removed then
				table.remove(data.lanterns)
			end
		end
		data.bestAge = math.max(data.bestAge or 0, life.age)
		-- the rankings: only personal bests are sent
		local player = session.player
		if player then
			data.bests = data.bests or {}
			local bests = data.bests
			local recordCount = 0
			for _ in data.records do
				recordCount += 1
			end
			local card = {
				name = player.DisplayName,
				life = lantern.name,
				title = lantern.title,
				detail = string.format("%d years  ·  %s", lantern.age, lantern.zone),
				patron = data.owned ~= nil and (data.owned.pass_patron == true or data.owned.pack_gilded == true),
			}
			local function submit(board: string, key: string, value: number)
				if value > (bests[key] or -1) then
					bests[key] = value
					Leaderboards.submit(board, player.UserId, value, card)
				end
			end
			submit("best", "score", lantern.score or 0)
			local week = Leaderboards.weekNumber()
			if bests.week ~= week then
				bests.week = week
				bests.weekScore = -1
			end
			submit("week", "weekScore", lantern.score or 0)
			submit("oldest", "age", lantern.age or 0)
			submit("richest", "money", lantern.peakMoney or 0)
			submit("lines", "generation", lantern.generation or 1)
			submit("records", "records", recordCount)
			if (lantern.fixerGrade or 0) > 0 then
				submit("fixers", "fixer", lantern.fixerGrade * 1000 + math.min(lantern.fightsWon or 0, 999))
			end
			if (lantern.fightsWon or 0) > 0 then
				submit("fights", "fights", lantern.fightsWon)
			end
			lantern.personalBest = bests.score == lantern.score
			local ok, board = pcall(Leaderboards.view, "best", player.UserId)
			if ok and board then
				local rank = 1
				for _, e in board.entries do
					if e.value > (lantern.score or 0) then
						rank += 1
					end
				end
				lantern.rank = if rank <= 50 then rank else nil
			end
		end
		session.profile:Save()
		if session.player then
			notifyDeath(session, session.player, life)
		end
	end

	local function friendsView(session, player: Player)
		local data = session.profile.Data
		local links = {}
		for key, link in data.links do
			local userId = tonumber(key)
			if userId then
				local other = sessionOf(userId)
				local otherLife = other and other.profile.Data.life
				local character = nil
				if otherLife then
					character = {
						first = otherLife.first,
						last = otherLife.last,
						age = otherLife.age,
						alive = otherLife.alive,
						zone = sim:zoneLabel(otherLife),
						appearance = sim:appearance(otherLife),
						career = if otherLife.career then sim:careerName(otherLife) else nil,
					}
				end
				table.insert(links, { userId = userId, name = link.name, online = other ~= nil, character = character })
			end
		end
		local others = {}
		for _, p in Players:GetPlayers() do
			if p ~= player and sessions[p] and not data.links[tostring(p.UserId)] then
				table.insert(others, { userId = p.UserId, name = p.DisplayName })
			end
		end
		local pending = {}
		for fromId, at in invites[player.UserId] or {} do
			local p = Players:GetPlayerByUserId(fromId)
			if p and os.clock() - at < INVITE_TTL then
				table.insert(pending, { userId = fromId, name = p.DisplayName })
			end
		end
		return { links = links, players = others, invites = pending, rough = data.settings.rough == true, max = MAX_LINKS }
	end

	-- ── responses ───────────────────────────────────────────────────────────

	-- A short title for chat tags: the rank you hold in this life ("Grade 7 Fixer"), or what
	-- you've become. It's made from game data, never from anything a player typed.
	local function chatTag(life): string?
		if not life or not life.alive then
			return nil
		end
		if life.form and life.form ~= "human" and Content.forms and Content.forms[life.form] then
			return Content.forms[life.form].name
		end
		local c = life.career and Content.careers[life.career.id]
		if c and c.ranks then
			return c.ranks[life.career.rank] or c.name
		end
		if life.age < 18 then
			return if life.age < 13 then "Kid" else "Teen"
		end
		return nil
	end
	local function setChatTag(player: Player?, life, data)
		if player then
			local tag = chatTag(life)
			if tag and data and data.perks and data.perks.vip then
				tag = "★ " .. tag
			end
			if player:GetAttribute("LifeSimTag") ~= tag then
				player:SetAttribute("LifeSimTag", tag)
			end
		end
	end

	local function lifeResponse(session, report)
		local data = session.profile.Data
		local life = data.life
		pcall(setChatTag, session.player, life, data)
		local res = {
			ok = true,
			life = if life then sim:view(life) else nil,
			entries = if report then report.entries else nil,
			clash = if report then report.clash else nil,
			codexNew = if report then report.codexNew else nil,
		}
		if report and (report.codexNew or (report.rolls or 0) > 0) then
			res.meta = metaView(data)
		end
		if life and not life.alive then
			recordDeath(session, life)
			res.lantern = lanternFor(data, life.id)
			res.meta = metaView(data)
		end
		return res
	end

	-- Runs one life action with linked friends kept fresh before and after.
	local function lifeAction(player, session, fn)
		local life = session.profile.Data.life
		if not life then
			return { ok = false, error = "Start a life first." }
		end
		syncLinks(session)
		local lookBefore = Avatar.signature(sim:appearance(life))
		local report, err = fn(life)
		if not report then
			return { ok = false, error = err }
		end
		City.afterReport(player, session, report)
		-- (v0.13) feats are kept for the player, across lives (whatever path earned them)
		if life.feats then
			local data = session.profile.Data
			data.featsEver = data.featsEver or {}
			for id, age in life.feats do
				data.featsEver[id] = data.featsEver[id] or age
			end
		end
		local news = sim:takeNews(life)
		if not life.alive then
			news = {} -- a death is announced by notifyDeath
		end
		local res = lifeResponse(session, report)
		if report.outbox and #report.outbox > 0 then
			task.defer(deliver, player, report.outbox)
		end
		if #news > 0 or Avatar.signature(sim:appearance(life)) ~= lookBefore then
			task.defer(shareWithFriends, player, session, news)
		end
		return res
	end

	local handlers = {}

	-- once per calendar day (UTC): a login streak reward
	local function dailyCheck(data)
		local today = math.floor(os.time() / 86400)
		data.daily = data.daily or { lastDay = 0, streak = 0 }
		if data.daily.lastDay == today then
			return nil
		end
		data.daily.streak = if data.daily.lastDay == today - 1 then data.daily.streak + 1 else 1
		data.daily.lastDay = today
		local day = (data.daily.streak - 1) % #DAILY_GLOW + 1
		local glow = DAILY_GLOW[day]
		data.glow = (data.glow or 0) + glow
		local unlocked = nil
		if data.daily.streak >= 7 and not data.cosmetics["hairColor:lamplit"] then
			data.cosmetics["hairColor:lamplit"] = true
			unlocked = "Lamplit hair color"
		end
		-- a surname roll for showing up
		local dailyRolls = if data.perks and data.perks.vip then 2 else 1
		data.rolls = (data.rolls or 0) + dailyRolls
		local lunacy = Progress.dailyLunacy(data)
		return { streak = data.daily.streak, day = day, glow = glow, rewards = DAILY_GLOW, unlocked = unlocked, rolls = dailyRolls, lunacy = lunacy }
	end

	function handlers.hello(player, session)
		local data = session.profile.Data
		syncLinks(session)
		local res = lifeResponse(session, nil)
		res.info = info
		res.daily = dailyCheck(data)
		res.meta = metaView(data)
		res.log = if data.life then tail(data.life.log, LOG_TAIL) else {}
		res.world = WorldEvents.currentFor(data.life)
		res.crew = Crews.viewFor(player.UserId)
		res.chronicle = City.chronicleView()
		res.holds = City.holdsView()
		res.dailyEvent = City.dailyInfo()
		res.surnames = Surnames.state(data)
		res.isAdmin = Admin.isAdmin(player)
		res.talent = Progress.talentState(player, session)
		return res
	end

	-- Starts a new life for a player. `shared` (from a crew starting out together) fixes
	-- the district, the birth year and some flags so their lives begin side by side.
	local function startLife(player: Player, session, payload, shared)
		local data = session.profile.Data
		payload = if type(payload) == "table" then payload else {}
		local current = data.life
		if current and current.alive then
			if payload.confirm ~= true then
				return { ok = false, error = "Your current life isn't over." }
			end
			sim:kill(current, nil, (Content.deathCauses and Content.deathCauses.walkedAway) or "Walked away from this life")
			recordDeath(session, current)
		end
		-- what the last life met goes on the list of things the next lives see far less of, so
		-- no two lives in a row read alike
		if current and type(current.history) == "table" then
			data.recentEvents = data.recentEvents or {}
			local have = {}
			for _, id in data.recentEvents do
				have[id] = true
			end
			for id in current.history do
				if not have[id] then
					table.insert(data.recentEvents, id)
				end
			end
			while #data.recentEvents > 450 do
				table.remove(data.recentEvents, 1)
			end
		end
		-- the difficulty: picked on the start screen, remembered for next time
		local difficulty = if type(payload.difficulty) == "string" and Content.difficulties and type(Content.difficulties[payload.difficulty]) == "table" then payload.difficulty else nil
		if difficulty then
			data.difficulty = difficulty
		end
		-- v0.8 (packs with creatorPicks = false): you don't pick your family, District or side.
		-- They're rolled at birth from the families you've unlocked (Light adds rarer ones).
		local rolled = Content.creatorPicks == false
		local originId = if type(payload.origin) == "string" and not rolled then payload.origin else nil
		local origin = nil
		for _, o in Content.origins do
			if o.id == originId then
				origin = o
			end
		end
		origin = origin or Content.origins[1]
		if (origin.glowCost or 0) > 0 and not data.unlocked[origin.id] then
			return { ok = false, error = "That origin is still locked." }
		end
		local allowedOrigins = nil
		if rolled then
			allowedOrigins = {}
			for _, o in Content.origins do
				if (o.glowCost or 0) <= 0 or data.unlocked[o.id] then
					table.insert(allowedOrigins, o.id)
				end
			end
		end
		local first = filterName(player, payload.first)
		local district = if shared and shared.district then shared.district elseif not rolled and type(payload.district) == "string" and Content.districts[payload.district] then payload.district else nil
		-- the look is checked against what this player has unlocked
		local look = if type(payload.look) == "table" then Avatar.sanitize(Content, payload.look, canUseCosmetic(data)) else nil
		-- no weapon at the start in a pack where weapons are found, bought or issued in a life
		-- (whatever the client sent)
		if look and Content.schools ~= nil then
			look.weapon = Avatar.defaultLook(Content).weapon
		end
		-- the build (traits, style, stat points): the engine enforces the limits
		local traits = {}
		if type(payload.traits) == "table" and not rolled then
			for i, t in payload.traits do
				if type(t) == "string" and i <= 6 then
					table.insert(traits, t)
				end
			end
		end
		local alloc = nil
		if type(payload.alloc) == "table" and not rolled then
			alloc = {}
			for _, key in Content.stats.order do
				alloc[key] = tonumber(payload.alloc[key]) or 0
			end
		end
		-- the game mode (pack.modes): a crew start uses the captain's
		local modeId = nil
		local wantMode = if shared then shared.mode else payload.mode
		if type(wantMode) == "string" and wantMode ~= "" then
			local mode = Progress.modeDef(wantMode)
			if not mode then
				return { ok = false, error = "No such game mode." }
			end
			if not Progress.modeUnlocked(data, mode) then
				return { ok = false, error = mode.name .. " is still locked. " .. (mode.unlockText or "") }
			end
			modeId = mode.id
		end
		local surname, surnameTraits = Surnames.forLife(data)
		local seed = (os.time() * 7919 + player.UserId * 104729 + math.random(1, 1000000)) % 2147483646 + 1
		local life, report = sim:newLife({
			seed = seed,
			originId = origin.id,
			rollOrigin = rolled,
			allowedOrigins = allowedOrigins,
			first = first,
			last = surname,
			district = district,
			side = shared and shared.side,
			look = look,
			traits = traits,
			bonusTraits = surnameTraits,
			style = if type(payload.style) == "string" and not rolled then payload.style else nil,
			alloc = alloc,
			-- (a lobby's host picks the age for everyone)
			birthEra = if shared and type(shared.era) == "string" then shared.era elseif type(payload.era) == "string" then payload.era else nil,
			extraTraitPicks = if data.perks and data.perks.extraTrait then 1 else 0,
			extraPoints = if data.perks and data.perks.bonusPoints then 4 else 0,
			year = shared and shared.year,
			flags = shared and shared.flags,
			dailyDay = data.dailyEventDay,
			mode = modeId,
			affinities = if Content.affinityRoll then nil else Progress.affinitiesFor(data),
			talent = Progress.takeTalent(data),
			avoidStories = data.recentStories,
			stale = data.recentEvents,
			difficulty = (shared and shared.difficulty) or difficulty or data.difficulty,
		})
		data.life = life
		-- the sins this life was dealt lean the family's next talent the same way
		if Content.affinityRoll and life.affinities then
			data.affinities = table.clone(life.affinities)
		end
		-- remember the last few stories so the next birth rolls something else
		if life.story then
			data.recentStories = data.recentStories or {}
			table.insert(data.recentStories, life.story)
			while #data.recentStories > 6 do
				table.remove(data.recentStories, 1)
			end
		end
		if Store.applyPending then
			Store.applyPending(data, report)
		end
		data.lastLook = table.clone(life.look)
		data.livesPlayed = (data.livesPlayed or 0) + 1
		syncLinks(session)
		sim:takeNews(life)
		task.defer(shareWithFriends, player, session, { player.DisplayName .. " started a new life as " .. life.first .. " " .. life.last .. ", in " .. sim:zoneLabel(life) .. "." })
		local res = lifeResponse(session, report)
		res.log = tail(life.log, LOG_TAIL)
		res.meta = metaView(data)
		res.talent = Progress.talentState(player, session)
		return res
	end

	function handlers.newLife(player, session, payload)
		return startLife(player, session, payload, nil)
	end

	-- lore: the text of every entry this player has found
	function handlers.codex(_player, session)
		local found = session.profile.Data.codex or {}
		local entries = {}
		for _, e in (Content.codex and Content.codex.entries) or {} do
			if found[e.id] then
				entries[e.id] = { title = e.title, text = e.text, category = e.category, secret = e.secret == true }
			end
		end
		return { ok = true, entries = entries }
	end

	-- one-time flags the client keeps on the account (seen the intro, done the tutorial)
	local FLAG_KEYS = { seenIntro = true, tutorialDone = true }
	function handlers.setFlag(_player, session, payload)
		if type(payload) ~= "table" or not FLAG_KEYS[payload.key] then
			return { ok = false, error = "Bad request." }
		end
		local data = session.profile.Data
		data.flags = data.flags or {}
		data.flags[payload.key] = payload.value == true
		return { ok = true }
	end

	local function ageUpNow(player, session)
		return lifeAction(player, session, function(life)
			return sim:ageUp(life)
		end)
	end

	-- in a crew that ages together, Age Up is a ready check (server/Crews.luau)
	function handlers.ageUp(player, session)
		local synced = Crews.ageUp and Crews.ageUp(player, session)
		if synced then
			return synced
		end
		return ageUpNow(player, session)
	end

	function handlers.choose(player, session, payload)
		if type(payload) ~= "table" or type(payload.index) ~= "number" then
			return { ok = false, error = "Bad request." }
		end
		local approach = if type(payload.approach) == "string" then payload.approach else nil
		return lifeAction(player, session, function(life)
			return sim:choose(life, math.floor(payload.index), approach)
		end)
	end

	function handlers.activity(player, session, payload)
		if type(payload) ~= "table" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local arg = if type(payload.arg) == "string" then payload.arg else nil
		local approach = if type(payload.approach) == "string" then payload.approach else nil
		return lifeAction(player, session, function(life)
			return sim:doActivity(life, payload.id, arg, approach)
		end)
	end

	-- a job off this year's board (Engine/Jobs)
	function handlers.job(player, session, payload)
		if type(payload) ~= "table" or type(payload.index) ~= "number" then
			return { ok = false, error = "Bad request." }
		end
		local approach = if type(payload.approach) == "string" then payload.approach else nil
		return lifeAction(player, session, function(life)
			return sim:doJob(life, math.floor(payload.index), approach)
		end)
	end

	function handlers.expeditionStart(player, session, payload)
		if type(payload) ~= "table" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local crew = Crews.crewOf(player.UserId)
		if crew and #crew.members > 1 then
			return { ok = false, error = "You're in a crew. The captain proposes expeditions from the Crew screen." }
		end
		return lifeAction(player, session, function(life)
			return sim:startExpedition(life, payload.id)
		end)
	end

	function handlers.expeditionChoose(player, session, payload)
		if type(payload) ~= "table" or type(payload.index) ~= "number" then
			return { ok = false, error = "Bad request." }
		end
		local approach = if type(payload.approach) == "string" then payload.approach else nil
		return lifeAction(player, session, function(life)
			return sim:chooseExpedition(life, math.floor(payload.index), approach)
		end)
	end

	function handlers.leaderboard(player, _session, payload)
		local id = if type(payload) == "table" and type(payload.board) == "string" then payload.board else "best"
		return { ok = true, board = Leaderboards.view(id, player.UserId), boards = Leaderboards.list() }
	end

	function handlers.setSetting(_player, session, payload)
		local data = session.profile.Data
		if type(payload) ~= "table" or type(payload.key) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		if payload.key == "music" and type(payload.value) == "boolean" then
			data.settings.music = payload.value
		elseif (payload.key == "musicVolume" or payload.key == "sfxVolume") and type(payload.value) == "number" then
			data.settings[payload.key] = math.clamp(payload.value, 0, 1)
		elseif payload.key == "uiScale" and (payload.value == "auto" or payload.value == "small" or payload.value == "big" or payload.value == "huge") then
			data.settings.uiScale = payload.value
		elseif payload.key == "effects" and type(payload.value) == "boolean" then
			data.settings.effects = payload.value
		elseif payload.key == "intro" and (payload.value == "full" or payload.value == "short" or payload.value == "off") then
			data.settings.intro = payload.value
		elseif payload.key == "cutscenes" and (payload.value == "full" or payload.value == "fights" or payload.value == "off") then
			-- (v0.14) the 3D cutscenes: all of them, fights only, or none
			data.settings.cutscenes = payload.value
		elseif payload.key == "vfx" and (payload.value == "full" or payload.value == "lite" or payload.value == "flat") then
			-- (v0.18) the 3D stage under fights: everything, fewer particles, or the flat screens
			data.settings.vfx = payload.value
		elseif payload.key == "frame" and type(payload.value) == "string" then
			local option = Avatar.option(Content, "frame", payload.value)
			if not option or not canUseCosmetic(data)("frame", option) then
				return { ok = false, error = "That file card is locked." }
			end
			if data.life then
				data.life.look = data.life.look or {}
				data.life.look.frame = payload.value
			end
			data.lastLook = data.lastLook or {}
			data.lastLook.frame = payload.value
		else
			return { ok = false, error = "Unknown setting." }
		end
		return { ok = true, meta = metaView(data), life = if data.life then sim:view(data.life) else nil }
	end

	-- (v0.18) your own Office: hire your people, move into a bigger building, fit out rooms, run
	-- the lab (Engine/Office.luau)
	function handlers.officeAct(player, session, payload)
		if type(payload) ~= "table" or type(payload.op) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local arg = payload.arg
		if type(arg) == "number" then
			arg = math.floor(arg)
		elseif type(arg) ~= "string" then
			arg = nil
		end
		return lifeAction(player, session, function(life)
			return sim:officeAct(life, payload.op, arg)
		end)
	end

	-- (v0.18) the name on the sign and the line under it: typed by the player, so both go
	-- through Roblox's text filter first (a name that doesn't pass isn't used)
	function handlers.officeName(player, session, payload)
		if type(payload) ~= "table" then
			return { ok = false, error = "Bad request." }
		end
		local name, motto = nil, nil
		if payload.name ~= nil then
			name = filterOfficeText(player, payload.name, 24)
			if not name then
				return { ok = false, error = "That name can't be used. Try another." }
			end
		end
		if type(payload.motto) == "string" then
			if string.match(payload.motto, "^%s*$") then
				motto = ""
			else
				motto = filterOfficeText(player, payload.motto, 60)
				if not motto then
					return { ok = false, error = "That motto can't be used. Try another." }
				end
			end
		end
		local color = if type(payload.color) == "string" then payload.color else nil
		return lifeAction(player, session, function(life)
			return sim:officeRename(life, name, motto, color)
		end)
	end

	function handlers.interact(player, session, payload)
		if type(payload) ~= "table" or type(payload.relId) ~= "number" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local approach = if type(payload.approach) == "string" then payload.approach else nil
		return lifeAction(player, session, function(life)
			return sim:interact(life, math.floor(payload.relId), payload.id, approach)
		end)
	end

	function handlers.buyGear(player, session, payload)
		if type(payload) ~= "table" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		return lifeAction(player, session, function(life)
			return sim:buyGear(life, payload.id)
		end)
	end

	function handlers.buyMarket(player, session, payload)
		if type(payload) ~= "table" or type(payload.market) ~= "string" or type(payload.good) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		return lifeAction(player, session, function(life)
			return sim:buyMarket(life, payload.market, payload.good)
		end)
	end

	function handlers.equipGear(player, session, payload)
		if type(payload) ~= "table" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		return lifeAction(player, session, function(life)
			return sim:equipGear(life, payload.id)
		end)
	end

	function handlers.sellGear(player, session, payload)
		if type(payload) ~= "table" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		return lifeAction(player, session, function(life)
			return sim:sellGear(life, payload.id)
		end)
	end

	function handlers.dropGear(player, session, payload)
		if type(payload) ~= "table" or type(payload.slot) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		return lifeAction(player, session, function(life)
			return sim:dropGear(life, payload.slot)
		end)
	end

	function handlers.joinCareer(player, session, payload)
		if type(payload) ~= "table" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		return lifeAction(player, session, function(life)
			return sim:joinCareer(life, payload.id)
		end)
	end

	function handlers.leaveCareer(player, session)
		return lifeAction(player, session, function(life)
			return sim:leaveCareer(life)
		end)
	end

	function handlers.continueHeir(player, session, payload)
		local data = session.profile.Data
		local parent = data.life
		if not parent or parent.alive or type(payload) ~= "table" or type(payload.id) ~= "number" then
			return { ok = false, error = "No heir to continue as." }
		end
		recordDeath(session, parent)
		local seed = (os.time() * 31 + player.UserId * 7 + math.random(1, 1000000)) % 2147483646 + 1
		local life, report = sim:newLifeFromHeir(parent, payload.id, seed)
		if not life then
			return { ok = false, error = "That heir can't continue." }
		end
		data.life = life
		data.livesPlayed = (data.livesPlayed or 0) + 1
		syncLinks(session)
		sim:takeNews(life)
		task.defer(shareWithFriends, player, session, { player.DisplayName .. " carried on as " .. life.first .. " " .. life.last .. ", age " .. life.age .. "." })
		local res = lifeResponse(session, report)
		res.log = tail(life.log, LOG_TAIL)
		res.meta = metaView(data)
		return res
	end

	function handlers.releaseLantern(player, session, payload)
		local data = session.profile.Data
		if type(payload) ~= "table" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local lantern = lanternFor(data, payload.id)
		if not lantern then
			return { ok = false, error = "No such " .. string.lower(Content.meta.lanternName or "lantern") .. "." }
		end
		if data.life and data.life.id == lantern.id and data.life.alive then
			return { ok = false, error = "That life isn't over." }
		end
		if lantern.released then
			return { ok = false, error = "Already released." }
		end
		lantern.released = true
		data.glow = (data.glow or 0) + (lantern.glow or 1) + (if data.perks and data.perks.vip then 1 else 0)
		return { ok = true, meta = metaView(data) }
	end

	function handlers.unlockOrigin(player, session, payload)
		local data = session.profile.Data
		if type(payload) ~= "table" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local origin = nil
		for _, o in Content.origins do
			if o.id == payload.id then
				origin = o
			end
		end
		if not origin then
			return { ok = false, error = "Unknown origin." }
		end
		if data.unlocked[origin.id] or (origin.glowCost or 0) <= 0 then
			return { ok = true, meta = metaView(data) }
		end
		if (data.glow or 0) < origin.glowCost then
			return { ok = false, error = "Not enough " .. Content.meta.glowName .. "." }
		end
		data.glow -= origin.glowCost
		data.unlocked[origin.id] = true
		return { ok = true, meta = metaView(data) }
	end

	function handlers.unlockCosmetic(player, session, payload)
		local data = session.profile.Data
		if type(payload) ~= "table" or type(payload.category) ~= "string" or type(payload.id) ~= "string" then
			return { ok = false, error = "Bad request." }
		end
		local option = Avatar.option(Content, payload.category, payload.id)
		if not option then
			return { ok = false, error = "Unknown cosmetic." }
		end
		if option.record then
			return { ok = false, error = "Earn that Record to unlock it." }
		end
		local key = Avatar.unlockKey(payload.category, payload.id)
		if not option.glow or option.glow <= 0 or data.cosmetics[key] then
			return { ok = true, meta = metaView(data) }
		end
		if (data.glow or 0) < option.glow then
			return { ok = false, error = "Not enough " .. Content.meta.glowName .. "." }
		end
		data.glow -= option.glow
		data.cosmetics[key] = true
		return { ok = true, meta = metaView(data) }
	end

	-- ── friends handlers ────────────────────────────────────────────────────

	function handlers.friends(player, session)
		syncLinks(session)
		return { ok = true, friends = friendsView(session, player), life = if session.profile.Data.life then sim:view(session.profile.Data.life) else nil }
	end

	function handlers.linkRequest(player, session, payload)
		if type(payload) ~= "table" or type(payload.userId) ~= "number" then
			return { ok = false, error = "Bad request." }
		end
		local target, targetPlayer = sessionOf(payload.userId)
		if not target or targetPlayer == player then
			return { ok = false, error = "That player isn't here." }
		end
		local data = session.profile.Data
		if data.links[tostring(payload.userId)] then
			return { ok = false, error = "You're already linked." }
		end
		local count = 0
		for _ in data.links do
			count += 1
		end
		if count >= MAX_LINKS then
			return { ok = false, error = "You can link with up to " .. MAX_LINKS .. " friends." }
		end
		invites[payload.userId] = invites[payload.userId] or {}
		invites[payload.userId][player.UserId] = os.clock()
		pushTo(targetPlayer, { invite = { userId = player.UserId, name = player.DisplayName } })
		return { ok = true, friends = friendsView(session, player), toast = "Invite sent to " .. targetPlayer.DisplayName .. "." }
	end

	function handlers.linkRespond(player, session, payload)
		if type(payload) ~= "table" or type(payload.userId) ~= "number" then
			return { ok = false, error = "Bad request." }
		end
		local mine = invites[player.UserId]
		local at = mine and mine[payload.userId]
		if mine then
			mine[payload.userId] = nil
		end
		if not at or os.clock() - at > INVITE_TTL then
			return { ok = false, error = "That invite expired." }
		end
		local other, otherPlayer = sessionOf(payload.userId)
		if not other then
			return { ok = false, error = "They left the server." }
		end
		if payload.accept ~= true then
			pushTo(otherPlayer, { toast = player.DisplayName .. " declined your invite." })
			return { ok = true, friends = friendsView(session, player) }
		end
		session.profile.Data.links[tostring(payload.userId)] = { name = otherPlayer.DisplayName, since = os.time() }
		other.profile.Data.links[tostring(player.UserId)] = { name = player.DisplayName, since = os.time() }
		syncLinks(session)
		syncLinks(other)
		local function announce(s, p: Player, withName: string)
			local life = s.profile.Data.life
			if life and life.alive then
				local report = sim.newReport()
				sim:push(life, report, { kind = "system", tone = "good", text = "You linked lives with " .. withName .. "." })
				return { life = sim:view(life), entries = report.entries }
			end
			return {}
		end
		local theirs = announce(other, otherPlayer, player.DisplayName)
		theirs.toast = player.DisplayName .. " linked lives with you."
		pushTo(otherPlayer, theirs)
		local mineRes = announce(session, player, otherPlayer.DisplayName)
		mineRes.ok = true
		mineRes.friends = friendsView(session, player)
		return mineRes
	end

	-- (v0.12) A link is for good: nobody can unlink. The action is refused, not missing, so a
	-- client that still asks gets a plain answer and nothing changes on either side.
	function handlers.unlink(_player, _session, _payload)
		return { ok = false, error = "Linked lives stay linked." }
	end

	function handlers.setRough(player, session, payload)
		if type(payload) ~= "table" or type(payload.on) ~= "boolean" then
			return { ok = false, error = "Bad request." }
		end
		session.profile.Data.settings.rough = payload.on
		syncLinks(session)
		return { ok = true, friends = friendsView(session, player) }
	end

	-- ── crews, world events, the store ──────────────────────────────────────
	local S = {
		ageUpNow = ageUpNow,
		Crews = Crews,
		sim = sim,
		Content = Content,
		Config = Config,
		Expedition = Engine.Expedition,
		Engine = Engine,
		handlers = handlers,
		sessions = sessions,
		sessionOf = sessionOf,
		pushTo = pushTo,
		metaView = metaView,
		recordDeath = recordDeath,
		lanternFor = lanternFor,
		shareWithFriends = shareWithFriends,
		syncLinks = syncLinks,
		startLife = startLife,
		filterName = filterName,
		Avatar = Avatar,
		canUseCosmetic = canUseCosmetic,
		lifeResponse = lifeResponse,
		WorldEvents = WorldEvents,
		City = City,
	}
	-- links two players' lives as friends (what accepting a link invite does)
	function S.linkPlayers(a: Player, aSession, b: Player, bSession)
		if a == b then
			return
		end
		aSession.profile.Data.links[tostring(b.UserId)] = { name = b.DisplayName, since = os.time() }
		bSession.profile.Data.links[tostring(a.UserId)] = { name = a.DisplayName, since = os.time() }
		syncLinks(aSession)
		syncLinks(bSession)
	end
	City.install(S)
	Crews.install(S)
	WorldEvents.install(S)
	Store.install(S)
	S.Store = Store
	Codes.install(S) -- (v0.17) redeem codes: Config.codes and the mod menu's
	Progress.install(S)
	S.Progress = Progress
	Guide.install(S)
	Duels.install(S)
	-- (v0.16) turn-based boss fights, alone or with the crew (after Crews: it wraps choose)
	Battles.install(S)
	info.modes = Progress.modesInfo()
	info.affinities = Progress.affinitiesInfo()
	info.affinityResonance = Content.affinityResonance
	info.talentTiers = if Progress.enabled() then sim:talentOdds(nil) else nil
	info.lunacy = Content.meta.premiumName or "Lunacy"
	info.storeOpen = Store.enabled == true
	Surnames.install(S)
	Admin.install(S)

	-- ── request plumbing ────────────────────────────────────────────────────

	request.OnServerInvoke = function(player: Player, action: any, payload: any)
		if type(action) ~= "string" or handlers[action] == nil then
			return { ok = false, error = "Unknown action." }
		end
		local session = sessions[player]
		local waited = 0
		while not session and waited < 20 and player.Parent == Players do
			task.wait(0.25)
			waited += 0.25
			session = sessions[player]
		end
		if not session then
			return { ok = false, error = "Your save is still loading. Try again in a moment." }
		end
		local now = os.clock()
		if now - session.windowStart > RATE_WINDOW then
			session.windowStart = now
			session.windowCount = 0
		end
		session.windowCount += 1
		if session.windowCount > RATE_MAX then
			return { ok = false, error = "Slow down a little." }
		end
		if session.busy then
			return { ok = false, error = "Still working on your last move." }
		end
		session.busy = true
		local ok, res = pcall(handlers[action], player, session, payload)
		session.busy = false
		if not ok then
			warn("[LifeSim] " .. action .. " failed for " .. player.Name .. ": " .. tostring(res))
			return { ok = false, error = "Something went wrong. Your save is safe." }
		end
		return res
	end

	local function onPlayerAdded(player: Player)
		local profile = store:StartSessionAsync("Player_" .. player.UserId, {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})
		if profile == nil then
			player:Kick("Couldn't load your save. Please rejoin.")
			return
		end
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		-- lives from an older engine version can't be continued safely
		if profile.Data.life and profile.Data.life.v ~= Engine.Sim.LIFE_VERSION then
			profile.Data.life = nil
		end
		-- a crew run doesn't survive the server it was on
		if profile.Data.life and profile.Data.life.run and profile.Data.life.run.crew then
			profile.Data.life.run = nil
		end
		task.spawn(Store.checkPasses, player, profile.Data)
		profile.OnSessionEnd:Connect(function()
			sessions[player] = nil
			player:Kick("Your save was opened on another server. Please rejoin.")
		end)
		if player.Parent ~= Players then
			profile:EndSession()
			return
		end
		sessions[player] = { profile = profile, player = player, busy = false, windowStart = 0, windowCount = 0 }
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		local session = sessions[player]
		invites[player.UserId] = nil
		if session then
			sessions[player] = nil
			session.profile:EndSession()
		end
	end)
end

return Server
