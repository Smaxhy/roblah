--[[
	GENERIC SCREENSHOT STATES for any game made with the blueprint. The snapshot test uses these
	instead of its own (which are the City's) when SNAP_STEPS=game:

		LIFESIM_PACK=<Id> SNAP_STEPS=game node tools/gui_render/shoot.js --device pc
		LIFESIM_PACK=<Id> SNAP_STEPS=game lune run tests/gui_snapshot --device phone

	Every state reads the game's own content (h.pack): the first mode, the first card of its own
	with a fight on it, its first boss. A state that can't happen in this game (no bosses yet)
	is skipped, not failed.
]]

return function(leaveFights)
	-- a card of the game's own (not Base's) that has a fight anyone can pick
	local function fightCard(pack: any): (any, string?)
		local best, label = nil, nil
		for _, e in pack.events do
			if e.source ~= "Base" and e.choices and not e.story and not e.always then
				for _, c in e.choices do
					if type(c) == "table" and c.clash and c.clash.fight and not c.requires and not c.battle then
						return e, c.label
					end
				end
			end
		end
		for _, e in pack.events do
			if e.id == "base_robbed" then
				best, label = e, "Fight"
			end
		end
		return best, label
	end

	local function firstBoss(pack: any): string?
		local ids = {}
		for id in pack.bosses or {} do
			table.insert(ids, id)
		end
		table.sort(ids)
		return ids[1]
	end

	local function grownUp(h)
		local life = h.state.life
		if life and life.age < 22 then
			h.admin({ op = "stat", stat = "age", value = 22 })
			h.settle()
			h.clearPending()
		end
	end

	return {
		{
			name = "intro",
			note = "The join cinematic.",
			settle = 0,
			run = function(h)
				h.startApp()
				h.wait(3.5)
				h.assert(h.has("Intro") or h.has("StartMenu"), "neither the intro nor the menu came up")
			end,
		},
		{
			name = "menu",
			note = "The start menu (after the daily gift).",
			run = function(h)
				if h.has("SkipIntro") then
					h.press("SkipIntro")
					h.wait(1.2)
				end
				h.pressText("COLLECT")
				h.wait(0.6)
				h.assert(h.has("StartMenu"), "no start menu")
			end,
		},
		{
			name = "creator",
			note = "The creator: looks, and a name typed.",
			run = function(h)
				h.closeSheets()
				local mode = (h.pack.modes and h.pack.modes[1] and h.pack.modes[1].id) or "life"
				if not h.press("Mode_" .. mode) then
					h.state.together = false
					h.actions.showQuickStart(mode)
				end
				h.wait(0.6)
				h.assert(h.has("QuickStart"), "the creator didn't open")
				h.type("FirstName", "Robin")
				h.quiet()
			end,
		},
		{
			name = "birth",
			note = "Be born: the birth reveal (family, place, side, then the name).",
			settle = 0,
			run = function(h)
				h.assert(h.press("BeBorn"), "no Be born button")
				for _ = 1, 14 do
					if not h.has("Cutscene") then
						break
					end
					h.press("Cutscene")
					h.wait(0.4)
				end
				h.waitFor(function()
					return h.has("BirthReveal") or (h.state.life ~= nil and h.state.life.alive)
				end, 15, "no birth reveal and no life")
				h.wait(2.5)
			end,
		},
		{
			name = "hud",
			note = "A life six years in: the file card, the year's report, the stats, the action bar.",
			run = function(h)
				h.waitFor(function()
					return h.state.life ~= nil and h.state.life.alive
				end, 25, "the life never started")
				if h.has("SkipTutorial") then
					h.press("SkipTutorial")
					h.wait(0.5)
				end
				h.ensureLife()
				h.liveYears(6)
				h.clearPending()
				h.quiet()
			end,
		},
		{
			name = "activities",
			note = "The Activities sheet: what to do with this year.",
			run = function(h)
				h.ensureLife()
				h.closeSheets()
				h.actions.openActivities()
				h.wait(0.5)
				h.quiet()
				h.assert(h.has("Sheet"), "the Activities sheet didn't open")
			end,
		},
		{
			name = "event",
			note = "One of the game's own cards with a fight on it (forced from the mod menu).",
			run = function(h)
				h.closeSheets()
				h.ensureLife()
				grownUp(h)
				local e = fightCard(h.pack)
				h.assert(e ~= nil, "the game has no card with a fight on it")
				h.admin({ op = "event", id = e.id })
				h.settle()
				h.quiet()
				h.assert(h.has("EventCard"), "the event card didn't open")
			end,
		},
		{
			name = "event-approach",
			note = "The fight choice tapped: how to fight, with the odds of each.",
			run = function(h)
				local _, label = fightCard(h.pack)
				h.assert(label ~= nil and h.choice(label), "no fight choice on the card")
				h.wait(0.4)
				h.assert(h.has("Approach"), "the approach picker didn't open")
			end,
		},
		{
			name = "fight",
			note = "The fight screen in round 2.",
			settle = 0,
			run = function(h)
				h.assert(h.approach(1), "no approach button")
				h.waitRound(1)
			end,
		},
		{
			name = "fight-end",
			note = "The fight is over: the stamp and Continue.",
			run = function(h)
				for _ = 1, 400 do
					if h.findPattern("^CONTINUE$") then
						break
					end
					h.wait(0.1)
				end
				h.assert(h.findPattern("^CONTINUE$"), "the fight never ended")
				h.wait(0.4)
			end,
		},
		{
			name = "store",
			note = "The store.",
			run = function(h)
				h.settle()
				h.wait(2.5)
				h.closeEvent()
				h.actions.openStore()
				h.wait(0.5)
				h.settle()
				h.quiet()
				h.assert(h.has("Sheet"), "the store didn't open")
			end,
		},
		{
			name = "guide",
			note = "The guidebook.",
			run = function(h)
				h.closeSheets()
				h.actions.openGuide()
				h.wait(0.5)
				h.settle()
				h.quiet()
				h.assert(h.has("Search"), "the guidebook didn't open")
			end,
		},
		{
			name = "boss",
			note = "A boss battle in turns (the game's first boss, from the mod menu).",
			run = function(h)
				h.closeSheets()
				local id = firstBoss(h.pack)
				h.assert(id ~= nil, "the game has no bosses yet")
				h.clearPending()
				grownUp(h)
				for _, k in h.pack.stats.order do
					h.admin({ op = "stat", stat = k, value = 70 })
				end
				h.settle()
				h.clearPending()
				h.admin({ op = "battle", id = id })
				h.waitFor(function()
					return h.has("BattleView")
				end, 12, "the battle screen never opened")
				h.wait(0.8)
			end,
		},
		{
			name = "boss-turn",
			note = "After a turn: the hit, the log, the next move.",
			run = function(h)
				h.assert(h.has("BattleView"), "no battle on screen (see boss)")
				h.press("Move_1")
				h.wait(1.2)
			end,
		},
		{
			name = "death",
			note = "The death screen: what happened, and the way back to the menu.",
			run = function(h)
				if leaveFights then
					leaveFights(h)
				end
				h.closeSheets()
				h.clearPending()
				h.admin({ op = "kill" })
				h.waitFor(function()
					return h.has("DeathReport")
				end, 40, "the death screen never showed its report")
				h.wait(1.5)
			end,
		},
	}
end
