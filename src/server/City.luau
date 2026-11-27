--[[
	The shared City: what every player on this server shares.
		- today's event: one per real day (00:00 UTC), the same for everyone
		- the chronicle: notable deeds by players here. Events can be about another
		  player's deed (when.chronicle), so lives on one server cross and change each other
		- city news in the chat when someone does something big
	It also files away what a life action reports beyond the life itself: lore found,
	surname rolls earned, today's event done.
]]

local Players = game:GetService("Players")

local City = {}

local CHRONICLE_MAX = 40
local CHRONICLE_SHOWN = 12
local NEWS_GAP = 8 -- seconds between chat news lines caused by the same player

function City.install(S)
	local sim = S.sim
	local Content = S.Content

	local chronicle = {}
	sim:setChronicle(chronicle)
	-- THE CITY'S HOLD on this server: what players' deeds have done to each District
	-- (Engine/Renown.luau). Everyone here shares it; it lasts as long as the server does.
	local holds = {}
	sim:setHolds(holds)
	local lastNews: { [number]: number } = {}
	local override = nil -- { id, day }: an admin's pick for today

	local function today(): number
		return math.floor(os.time() / 86400)
	end

	local function dailyFor(day: number): string?
		if override and override.day == day then
			return override.id
		end
		local order = Content.daily and Content.daily.order
		if not order or #order == 0 then
			return nil
		end
		-- a fixed walk through the list so neighboring days differ
		return order[(day * 7 + 3) % #order + 1]
	end

	local function dailyInfo()
		local id = sim.dailyId
		local def = id and Content.daily and Content.daily[id]
		if not def then
			return nil
		end
		return { id = id, name = def.name, desc = def.desc, day = sim.dayNumber }
	end
	City.dailyInfo = dailyInfo

	local function refreshDaily(announce: boolean?)
		local day = today()
		local id = dailyFor(day)
		local changed = id ~= sim.dailyId or day ~= sim.dayNumber
		sim:setDaily(id, day)
		if changed and announce then
			local info = dailyInfo()
			for _, p in Players:GetPlayers() do
				local session = S.sessions[p]
				local life = session and session.profile.Data.life
				S.pushTo(p, { daily = info, life = if life then sim:view(life) else nil })
			end
			if info then
				City.news("Today in the City: " .. info.name .. ".", "accent")
			end
		end
	end
	refreshDaily(false)

	-- an admin can swap today's event
	function City.setDaily(id: string): boolean
		if not (Content.daily and Content.daily[id]) then
			return false
		end
		override = { id = id, day = today() }
		refreshDaily(true)
		return true
	end

	-- A line of city news: every client shows it in the chat as a system message.
	function City.news(text: string, tone: string?)
		for _, p in Players:GetPlayers() do
			S.pushTo(p, { news = { text = text, tone = tone or "news" } })
		end
	end

	local function render(text: string, entry): string
		local d = Content.districts[entry.district or ""]
		local out = string.gsub(text, "{name}", entry.name)
		out = string.gsub(out, "{district}", if d then d.name else "the City")
		return out
	end

	local function entryView(entry)
		local def = Content.chronicle and Content.chronicle[entry.act]
		return { act = entry.act, text = if def then render(def.text, entry) else entry.name, userId = entry.userId, at = entry.at }
	end

	-- every District someone has changed: { district, name, safety, prosperity, holder }
	function City.holdsView()
		local out = {}
		for id, h in holds do
			local d = Content.districts[id]
			table.insert(out, { district = id, name = if d then d.name else id, safety = h.safety or 0, prosperity = h.prosperity or 0, holder = h.holder })
		end
		table.sort(out, function(a, b)
			return a.name < b.name
		end)
		return out
	end

	function City.chronicleView()
		local out = {}
		for i = #chronicle, math.max(1, #chronicle - CHRONICLE_SHOWN + 1), -1 do
			table.insert(out, entryView(chronicle[i]))
		end
		return out
	end

	-- Adds a deed to the chronicle, tells everyone, and puts it in the chat if it's big.
	function City.record(player: Player?, life, act: string)
		local def = Content.chronicle and Content.chronicle[act]
		if not def or not life then
			return
		end
		local entry = {
			act = act,
			name = life.first .. " " .. life.last,
			district = life.district,
			lifeId = life.id,
			userId = if player then player.UserId else 0,
			at = os.time(),
		}
		table.insert(chronicle, entry)
		while #chronicle > CHRONICLE_MAX do
			table.remove(chronicle, 1)
		end
		local view = entryView(entry)
		for _, p in Players:GetPlayers() do
			S.pushTo(p, { chronicle = view })
		end
		if def.announce then
			City.news(view.text, def.tone)
		end
	end

	-- After any life action: lore, rolls, today's event, the chronicle and chat news.
	function City.afterReport(player: Player, session, report)
		if not report then
			return
		end
		local data = session.profile.Data
		local life = data.life
		if report.codex then
			data.codex = data.codex or {}
			local fresh = {}
			for _, id in report.codex do
				if not data.codex[id] then
					data.codex[id] = os.time()
					table.insert(fresh, id)
				end
			end
			if #fresh > 0 then
				report.codexNew = fresh
			end
		end
		if report.rolls and report.rolls > 0 then
			data.rolls = (data.rolls or 0) + report.rolls
		end
		if report.dailyDone then
			data.dailyEventDay = report.dailyDone
		end
		for _, c in report.chronicle or {} do
			City.record(player, life, c.act)
		end
		-- a deed changed a District: the shared table already has it (the engine wrote to it);
		-- tell everyone, and say it in the chat when the deed has words of its own
		if report.impact and #report.impact > 0 then
			local view = City.holdsView()
			for _, p in Players:GetPlayers() do
				S.pushTo(p, { holds = view })
			end
			for _, i in report.impact do
				if i.text then
					City.news(i.text, "accent")
				end
			end
		end
		for _, text in report.announce or {} do
			local now = os.clock()
			if now - (lastNews[player.UserId] or -NEWS_GAP) >= NEWS_GAP then
				lastNews[player.UserId] = now
				City.news(text)
			end
		end
	end

	-- the day turns over at midnight UTC
	task.spawn(function()
		while true do
			task.wait(30)
			if today() ~= sim.dayNumber then
				refreshDaily(true)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastNews[player.UserId] = nil
	end)
end

return City
