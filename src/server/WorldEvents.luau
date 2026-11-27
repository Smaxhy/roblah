--[[
	World events for the whole server: a containment breach, Lantern Night, the
	Great Low Tide, Fog Week, a strike (Content/WorldEvents.luau).

	Every Config.worldEvents.every seconds there's a Config.worldEvents.chance it
	starts one. Everyone gets a banner; everyone living a life gets the opening
	scene (startEvent) in their life; it runs for `minutes`, then ends.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local WorldEvents = {}

function WorldEvents.install(S)
	local sim = S.sim
	local Conditions = S.Engine.Conditions
	local Content = S.Content
	local cfg = (S.Config and S.Config.worldEvents) or {}
	local list = Content.worldEvents
	local active = nil -- { id, endsAt }
	local last = nil

	local function banner(id: string, ended: boolean?)
		local we = list[id]
		return {
			id = id,
			name = we.name,
			headline = we.headline,
			text = if ended then (we.endText or (we.name .. " is over.")) else we.text,
			tone = we.tone,
			district = we.district,
			expedition = we.expedition,
			secondsLeft = if active and not ended then math.max(0, math.floor(active.endsAt - os.clock())) else 0,
			ended = ended == true,
		}
	end

	function WorldEvents.current()
		if active then
			return banner(active.id)
		end
		return nil
	end

	-- what one life sees (a world event limited to an era stays hidden from the others)
	function WorldEvents.currentFor(life)
		if not active then
			return nil
		end
		local we = list[active.id]
		if we and we.when and not (life and life.alive and Conditions.check(we.when, life, Content, { noChance = true })) then
			return nil
		end
		return banner(active.id)
	end

	local function stop()
		if not active then
			return
		end
		local id = active.id
		local reached = active.reached or {}
		active = nil
		sim:setWorldEvent(id, false)
		for _, p in Players:GetPlayers() do
			if reached[p.UserId] then
				S.pushTo(p, { world = banner(id, true) })
			end
		end
	end

	WorldEvents.stop = stop

	function WorldEvents.start(id: string)
		local we = list and list[id]
		if not we then
			return false
		end
		if active then
			stop()
		end
		active = { id = id, endsAt = os.clock() + (we.minutes or 6) * 60 }
		last = id
		sim:setWorldEvent(id, true)
		for _, p in Players:GetPlayers() do
			local session = S.sessions[p]
			local life = session and session.profile.Data.life
			-- a world event can be limited to some lives (an era, say): others don't see it
			local reaches = we.when == nil or (life ~= nil and life.alive and (Conditions.check(we.when, life, Content, { noChance = true })))
			local payload = { world = if reaches then banner(id) else nil }
			if reaches and life and life.alive and we.startEvent and sim.eventsById[we.startEvent] and not life.run then
				-- the opening scene jumps the queue for everyone who's playing
				table.insert(life.queue, 1, we.startEvent)
				if not life.pending then
					local report = sim.newReport()
					sim:advance(life, report)
					payload.entries = report.entries
				end
				payload.life = sim:view(life)
			end
			if payload.world or payload.life then
				S.pushTo(p, payload)
			end
			if reaches then
				active.reached = active.reached or {}
				active.reached[p.UserId] = true
			end
		end
		return true
	end

	local function roll()
		local options, weights = {}, {}
		for _, id in list.order or {} do
			if id ~= last then
				table.insert(options, id)
				table.insert(weights, list[id].weight or 1)
			end
		end
		local total = 0
		for _, w in weights do
			total += w
		end
		local r = math.random() * total
		for i, w in weights do
			r -= w
			if r <= 0 then
				return options[i]
			end
		end
		return options[#options]
	end

	-- Studio only: start one by hand (for testing)
	function S.handlers.debugWorldEvent(_player, _session, payload)
		if not RunService:IsStudio() then
			return { ok = false, error = "Studio only." }
		end
		local id = if type(payload) == "table" and type(payload.id) == "string" then payload.id else roll()
		if not WorldEvents.start(id) then
			return { ok = false, error = "No such world event." }
		end
		return { ok = true, world = WorldEvents.current() }
	end

	if not list or not list.order or #list.order == 0 or cfg.enabled == false then
		return
	end
	task.spawn(function()
		local every = cfg.every or 540
		local chance = cfg.chance or 0.65
		task.wait(cfg.firstDelay or 180)
		while true do
			if active and os.clock() >= active.endsAt then
				stop()
				task.wait(every)
			elseif not active then
				if #Players:GetPlayers() > 0 and math.random() < chance then
					WorldEvents.start(roll())
				else
					task.wait(every)
				end
			else
				task.wait(5)
			end
		end
	end)
end

return WorldEvents
