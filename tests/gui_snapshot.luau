--[[
	GUI snapshots: boots the real client UI (src/client/App.luau and src/client/UI/*) against the
	real server inside Lune (see tests/harness.luau), drives it to named states, and after each
	one dumps the PlayerGui tree to JSON with everything needed to draw it. tools/gui_render
	turns the dumps into PNGs (node tools/gui_render/shoot.js runs both; see its README).

		lune run tests/gui_snapshot                       every state, PC and phone
		lune run tests/gui_snapshot --device phone        one device (pc | phone | tablet)
		lune run tests/gui_snapshot --states menu,hud     only these (prefixes work: creator)
		lune run tests/gui_snapshot --size 1920x1080      another screen size (with --device)
		lune run tests/gui_snapshot --list                the states, in order
		lune run tests/gui_snapshot --verbose             also show what the game prints
		lune run tests/gui_snapshot --out some/dir        where the dumps go
			(default tools/gui_render/out/dumps/<device>/<state>.json)

	Run it from the repo root. States run in order in one session (the menu comes after the
	intro, the HUD after the creator); picking a few still runs the ones before them, it just
	doesn't save them. A state that fails (say a screen was rewritten and a button got a new
	name) is skipped with a message and the rest carry on.

	── adding a state ──
	Add an entry to STEPS below: { name = "...", note = "...", run = function(h) ... end }.
	run() drives the app with the h.* helpers; the dump is taken when it returns, after
	`settle` seconds (default 0.6, so tweens finish; 0 to catch something mid-animation).
	capture = false makes a step that only moves the app along. If run() errors, the state is
	skipped. Helpers (all wait on the virtual clock, so they're instant in real time):
		h.wait(seconds)                 let time pass (tweens, cinematics, delays)
		h.waitFor(fn, seconds, message) wait until fn() is true (fails the state with message)
		h.quiet()                       wait for toasts and celebration banners to go
		h.settle()                      wait until the app isn't busy talking to the server
		h.find(name) / h.findAll(name)  first / every visible instance with that Name
		h.findText(text)                a visible text object whose text contains `text`
		h.findPattern(luaPattern)       ... whose whole upper-cased plain text matches a Lua pattern
		h.press(nameOrInstance)         tap a visible button (by Name, or the instance)
		h.pressText(text)               tap the visible button whose text contains `text`
		h.has(name)                     is something with that Name on screen
		h.choice(text)                  tap the event-card choice whose label contains `text`
		h.approach(n)                   tap approach n (1 = first) in the open approach picker
		h.type(name, text)              type into a TextBox (fires its Text-changed signal)
		h.admin(payload)                a mod-menu call ({ op = "event", id = ... }; target is you)
		h.closeSheets()                 close every open bottom sheet
		h.ensureLife()                  make sure a life is going and the HUD is up
		h.liveYears(n)                  live n years (picks safe choices, presses Continue)
		h.pickChoice() / h.closeEvent() answer the open event card (a safe choice first)
		h.waitRound(n)                  wait for round n on the fight screen
		h.continueFight()               press Continue on a finished fight
		h.ctx / h.state / h.actions     the App's ctx (App.ctx), its state and actions
		h.ui(name)                      a client UI module (h.ui("Sheets"))
		h.player2(action, payload)      act as a second player on the server (userId 777)
		h.p2Life()                      give the second player a grown-up life with nothing pending
		h.device                        { name, width, height, inset, touch, ... }
	h.assert(cond, message) fails the state with that message. After a failed state the runner
	clears whatever a crashed screen left on the clash layer (a fight screen that errors leaves
	its scrim up), so the states after it aren't covered.
]]

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local Harness = require("./harness")
local vtask = Harness.task -- the virtual clock's task library (the driver waits on it)

-- ── devices ─────────────────────────────────────────────────────────────────
-- inset: Roblox's topbar. ScreenGuis with IgnoreGuiInset = false start below it.
local DEVICES = {
	pc = { name = "pc", width = 1440, height = 900, inset = 58, touch = false, keyboard = true, mouse = true },
	phone = { name = "phone", width = 390, height = 844, inset = 58, touch = true, keyboard = false, mouse = false },
	tablet = { name = "tablet", width = 1024, height = 768, inset = 58, touch = true, keyboard = false, mouse = false },
}
local DEFAULT_DEVICES = { "pc", "phone" }

-- (v0.17) leave whatever fight is on screen: a boss battle's last move is Get out, a duel's
-- is Yield; then Continue until the screen has gone
local function leaveFights(h)
	for _ = 1, 3 do
		local inBattle, inDuel = h.has("BattleView"), h.has("DuelView")
		if not inBattle and not inDuel then
			return
		end
		local last = nil
		for i = 1, 24 do
			if h.find("Move_" .. i) then
				last = i
			end
		end
		if last then
			h.press("Move_" .. last)
		end
		h.wait(0.4)
		if inDuel then
			pcall(h.player2, "duelAct", { action = "guard" })
		end
		for _ = 1, 40 do
			if not (h.has("BattleView") or h.has("DuelView")) then
				break
			end
			h.press("Continue")
			h.wait(0.3)
		end
	end
end

-- ── states ──────────────────────────────────────────────────────────────────
-- the mode the life is made in (Fixer's Road: starts at 18, with a job). SNAP_MODE=city shoots a
-- life from birth instead (a child, with a story, childhood activities and a family).
local MODE = process.env.SNAP_MODE or "fixer"

local STEPS = {
	{
		name = "intro",
		note = "The join cinematic at 3:13 AM: the clock runs out and THE NIGHT slams in (5.3 s in). On a first join the daily-streak popup is already up underneath.",
		settle = 0,
		run = function(h)
			h.startApp()
			h.wait(5.3 - h.sinceStart())
			h.assert(h.has("Intro"), "the intro isn't playing")
		end,
	},
	{
		name = "intro-montage",
		note = "The join cinematic: a montage card (9.6 s in).",
		settle = 0,
		run = function(h)
			h.wait(9.6 - h.sinceStart())
			h.assert(h.has("Card"), "no montage card on screen")
		end,
	},
	{
		name = "daily",
		note = "Skip pressed: the mode select comes up with the daily streak popup over it.",
		run = function(h)
			h.assert(h.press("SkipIntro"), "no Skip button on the intro")
			h.wait(1.2)
			h.assert(h.has("StartMenu"), "the mode select didn't follow the intro")
		end,
	},
	{
		name = "menu",
		note = "The mode select (start menu), after collecting the daily reward.",
		run = function(h)
			h.pressText("COLLECT")
			h.wait(0.6)
			h.assert(h.has("StartMenu"), "no start menu")
		end,
	},
	{
		name = "v18-menu-store",
		note = "The store opened from the banner on the start menu (v0.18): big and centered, over the mode select.",
		run = function(h)
			h.assert(h.has("StartStore"), "no store banner on the start menu")
			h.assert(h.press("StartStoreOpen"), "no Open the store button on the banner")
			h.wait(1.0)
			h.assert(h.has("StoreHero") and h.has("Aisles"), "the store didn't open from the start menu")
		end,
	},
	{
		name = "creator",
		note = "The creator (v0.8, one screen): the Looks tab, the Office Fixer look picked, a name typed.",
		run = function(h)
			h.closeSheets()
			h.wait(0.4)
			-- (v0.18) Fixer's Road has no card on the start menu any more; the tests start it directly
			if not h.press("Mode_" .. MODE) then
				h.assert(not h.has("Mode_fixer"), "Fixer's Road is back on the start menu")
				h.state.together = false
				h.actions.showQuickStart(MODE)
			end
			h.wait(0.6)
			h.assert(h.has("QuickStart"), "the creator didn't open")
			if h.has("Identity_night_walker") then
				h.press("Identity_night_walker")
			end
			h.type("FirstName", "Petra")
			h.quiet()
		end,
	},
	{
		name = "creator-hair",
		note = "The creator: the Hair tab (styles and colour swatches).",
		run = function(h)
			h.assert(h.press("Tab_hair"), "no Hair tab in the creator")
			h.quiet()
		end,
	},
	{
		name = "v17-body",
		note = "The creator's Body tab (v0.17): a feminine build, narrower shoulders and a snatched waist.",
		run = function(h)
			h.assert(h.press("Tab_body"), "no Body tab in the creator")
			h.wait(0.3)
			h.assert(h.pressText("FEMININE"), "no Feminine option in the Body tab")
			h.wait(0.8)
		end,
	},
	{
		name = "creator-when",
		note = "The creator: the When tab. Pick the age to be born into, or let the City decide; everything in the life follows it.",
		run = function(h)
			h.assert(h.press("Tab_when"), "no When tab in the creator")
			h.wait(0.3)
			h.quiet()
		end,
	},
	{
		name = "creator-sins",
		note = "The creator: the Talent tab. Sins are dealt at birth now; the talent and its rerolls are here.",
		run = function(h)
			h.assert(h.press("Tab_sins"), "no Talent tab in the creator")
			h.wait(0.3)
			h.quiet()
		end,
	},
	{
		name = "opening",
		note = "Be born pressed: the age you were born into, in three lines (the opening cutscene), before the birth reveal.",
		settle = 0,
		run = function(h)
			h.assert(h.press("BeBorn"), "no Be born button")
			h.waitFor(function()
				return h.has("Cutscene")
			end, 6, "the opening cutscene didn't start")
			-- all three lines up
			h.waitFor(function()
				local n = 0
				for _, l in h.findAll("Line") do
					if h.realOf[l].TextTransparency < 0.05 then
						n += 1
					end
				end
				return n >= 3
			end, 8, "the opening never showed its lines")
		end,
	},
	{
		name = "birth",
		note = "The City rolls where you land (BirthReveal): family, District, side of the wall, talent, then the name.",
		settle = 0,
		run = function(h)
			if not h.has("Cutscene") and not h.has("BirthReveal") then
				h.assert(h.press("BeBorn"), "no Be born button")
			end
			-- tap through the opening
			for _ = 1, 12 do
				if not h.has("Cutscene") then
					break
				end
				h.press("Cutscene")
				h.wait(0.4)
			end
			h.waitFor(function()
				return h.has("BirthReveal")
			end, 12, "the birth reveal didn't start")
			-- the name comes last, in big type, once every reel has landed
			h.waitFor(function()
				local root = h.find("BirthReveal")
				for _, c in (root and h.realOf[root]:GetChildren()) or {} do
					if c:IsA("TextLabel") and c.TextSize == 34 and c.TextTransparency < 0.05 then
						return true
					end
				end
				return false
			end, 15, "the birth reveal never got to the name")
		end,
	},
	{
		name = "canto",
		note = "Canto I: the chapter card that opens a life (after the birth reveal).",
		settle = 0,
		run = function(h)
			h.waitFor(function()
				return h.has("CantoCard")
			end, 8, "no Canto card after the birth reveal")
			h.wait(1.6)
		end,
	},
	{
		name = "tutorial",
		note = "The life starts on the HUD and the quick tour points at the file card.",
		run = function(h)
			if not (h.state.life and h.state.life.alive) and h.has("BeBorn") then
				h.press("BeBorn") -- the birth states were skipped
			end
			h.waitFor(function()
				return h.state.life ~= nil and h.state.life.alive and h.has("TutorialCard")
			end, 20, "no tour card after the life started")
		end,
	},
	{
		name = "hud",
		note = "A life four years in: the file card, the report (log), the virtues, the action bar.",
		run = function(h)
			if h.has("SkipTutorial") then
				h.press("SkipTutorial")
				h.wait(0.5)
			end
			h.ensureLife()
			h.liveYears(4)
			h.clearPending()
			if h.state.life.pending then
				local n, open = 0, 0
				for _, b in h.findAll("Choice") do
					n += 1
				end
				print("DEBUG card:", h.has("EventCard"), "choices:", n, "dialogue:", h.has("Dialogue"), "busy:", h.state.busy, h.state.applying, "errors:", #h.errors, h.errors[#h.errors])
			end
			h.assert(not h.state.life.pending, "an event is still open: " .. tostring(h.state.life.pending and h.state.life.pending.id) .. h.lastWarning())
			h.quiet()
		end,
	},
	{
		name = "hub-story",
		note = "The hub's Story tab: the story this life was handed, what's next, the Canto, the beats so far, the collection.",
		run = function(h)
			h.ensureLife()
			h.closeSheets()
			h.clearPending()
			h.actions.openStory()
			h.wait(0.5)
			h.quiet()
			h.assert(h.has("Tab_story"), "the Story tab is missing from the hub")
		end,
	},
	{
		name = "hub-family",
		note = "The hub's Family tab: the household, parents, brothers and sisters, with portraits and bonds.",
		run = function(h)
			h.actions.openFamily()
			h.wait(0.5)
			h.quiet()
			h.assert(h.has("Household"), "the Family tab didn't draw the household")
		end,
	},
	{
		name = "hub-you",
		note = "The hub's You tab: family name, talent and sins (dealt at birth), discipline, traits.",
		run = function(h)
			if h.has("Tab_you") then
				h.press("Tab_you")
			end
			h.wait(0.5)
			h.quiet()
		end,
	},
	{
		name = "story-beat",
		note = "A beat of the life's own story: the band carries the story's name, and City words can be tapped for a line of explanation.",
		run = function(h)
			h.closeSheets()
			h.ensureLife()
			h.clearPending()
			h.admin({ op = "event", id = "sl_col_inspection" })
			h.settle()
			h.quiet()
			h.assert(h.has("EventCard"), "the story beat didn't open")
			h.closeEvent()
			if h.has("Tab_activities") then
				h.press("Tab_activities")
			end
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
		name = "life",
		note = "The Life sheet, on its Career tab.",
		run = function(h)
			h.closeSheets()
			h.actions.openLife("Career")
			h.wait(0.5)
			h.quiet()
			h.assert(h.has("Sheet"), "the Life sheet didn't open")
		end,
	},
	{
		name = "v18-office-name",
		note = "Your own Office (v0.18): it asks for its name the first time, with a motto and the sign's colour.",
		run = function(h)
			h.closeSheets()
			h.ensureLife()
			h.clearPending()
			h.admin({ op = "stat", stat = "money", value = 90000 })
			h.admin({ op = "office" })
			h.wait(1.6)
			h.assert(h.has("SignForm") and h.has("OfficeNameBox"), "the Office didn't ask for its name")
			h.type("OfficeNameBox", "Bluebell")
			h.type("OfficeMottoBox", "We come when called")
			h.assert(h.press("SignColor_jade"), "no colour swatches for the sign")
			h.wait(0.3)
		end,
	},
	{
		name = "v18-office",
		note = "The sign hung: the building, rooms, roster, and the friends who'd join.",
		run = function(h)
			h.assert(h.press("SaveSign"), "no button to hang the sign")
			h.wait(0.6)
			h.assert(h.has("OfficeSign") and not h.has("SignForm"), "the sign wasn't hung")
			h.assert(h.has("MoveIn") and h.has("Roster"), "no premises or roster in the Office")
			h.assert(h.press("MoveInButton"), "no way to move to a bigger building")
			h.wait(0.6)
		end,
	},
	{
		name = "event",
		note = "An event card (Polite Collection, forced from the mod menu): a plain choice, a check and a fight.",
		run = function(h)
			h.closeSheets()
			h.ensureLife()
			h.clearPending()
			h.admin({ op = "event", id = "core_debt_collector" })
			h.settle()
			h.quiet()
			h.assert(h.has("EventCard"), "the event card didn't open")
		end,
	},
	{
		name = "event-approach",
		note = "The fight choice tapped: the approach picker (Steady / Reckless / Careful) with the odds.",
		run = function(h)
			h.assert(h.choice("down the stairs"), "no fight choice on the card")
			h.wait(0.4)
			h.assert(h.has("Approach"), "the approach picker didn't open")
		end,
	},
	{
		name = "fight",
		note = "The fight screen in round 2 (an event fight, after picking an approach).",
		settle = 0,
		run = function(h)
			h.assert(h.approach(1), "no approach button")
			h.waitRound(1)
		end,
	},
	{
		name = "fight-end",
		note = "The fight is over: the Won/Lost stamp and Continue.",
		run = function(h)
			h.assert(h.findPattern("^ROUND %d") or h.findPattern("^VS$"), "no fight screen up (see fight)")
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
		name = "fight-crows",
		note = "A fight against a creature (carrion crows): the 3D monster on the stage, in round 2.",
		settle = 0,
		run = function(h)
			h.continueFight()
			h.settle()
			h.clearPending()
			h.admin({ op = "event", id = "ad_f_pigeon_roof" })
			h.settle()
			h.wait(0.6)
			if h.has("SkipDialogue") then
				h.press("SkipDialogue")
				h.wait(0.4)
			end
			h.assert(h.choice("Grab the other broom"), "no fight choice on the crow card")
			h.wait(0.4)
			h.assert(h.approach(1), "no approach button")
			h.waitRound(1)
		end,
	},
	{
		name = "fight-crows-end",
		note = "The crows go down: the knockout and the stamp.",
		run = function(h)
			for _ = 1, 400 do
				if h.findPattern("^CONTINUE$") then
					break
				end
				h.wait(0.1)
			end
			h.assert(h.findPattern("^CONTINUE$"), "the crow fight never ended")
			h.wait(0.5)
		end,
	},
	{
		name = "check",
		note = "A quick check (Talk your way out, a Prudence check): the coins and the result.",
		settle = 0,
		run = function(h)
			h.continueFight()
			h.settle()
			h.clearPending()
			h.admin({ op = "event", id = "core_debt_collector" })
			h.settle()
			h.wait(0.6)
			h.assert(h.choice("Talk your way out"), "no check choice on the card")
			h.wait(0.2)
			if h.has("Approach") then
				h.approach(1)
			end
			for _ = 1, 60 do
				if h.has("Check") then
					break
				end
				h.wait(0.05)
			end
			h.assert(h.has("Check"), "the check card didn't show" .. h.lastWarning())
			h.wait(0.9)
		end,
	},
	{
		name = "store",
		note = "The store sheet.",
		run = function(h)
			h.settle()
			h.wait(2.5)
			h.closeEvent()
			h.actions.openStore()
			h.wait(0.5)
			h.settle()
			h.quiet()
			h.assert(h.has("Sheet"), "the store sheet didn't open")
		end,
	},
	{
		name = "guide",
		note = "The guidebook, on its Fights page.",
		run = function(h)
			h.closeSheets()
			h.actions.openGuide("fights")
			h.wait(0.5)
			h.settle()
			h.quiet()
			h.assert(h.has("Search"), "the guidebook didn't open")
		end,
	},
	{
		name = "crew",
		note = "The crew sheet with a second player in your crew (you're captain).",
		run = function(h)
			h.closeSheets()
			local ok, err = pcall(function()
				h.p2Life()
				h.actions.crewCall("crewCreate")
				h.settle()
				h.actions.crewCall("crewInvite", { userId = 777 })
				h.settle()
				local joined = h.player2("crewRespond", { userId = 4242, accept = true })
				assert(joined.ok, tostring(joined.error))
				h.settle()
			end)
			if not ok then
				print("        (a crew with a second player didn't work: " .. tostring(err) .. "; showing the sheet as it is)")
			end
			h.closeSheets()
			h.actions.openCrew()
			h.wait(0.5)
			h.settle()
			h.quiet()
			h.assert(h.has("Sheet"), "the crew sheet didn't open")
		end,
	},
	{
		name = "duel",
		note = "A duel in turns (v0.17): your crewmate challenged you. Both of you choose every move, hidden until both are in.",
		settle = 0,
		run = function(h)
			h.closeSheets()
			h.ensureLife()
			h.clearPending()
			h.admin({ op = "stat", stat = "age", value = 25 })
			h.admin({ op = "stat", stat = "health", value = 120 })
			h.p2Life()
			local r = h.player2("duelChallenge", { userId = 4242 })
			h.assert(r.ok, "the duel challenge failed: " .. tostring(r.error))
			h.settle()
			h.assert(h.press("PromptButton2"), "no Fight button on the duel prompt")
			h.waitFor(function()
				return h.has("DuelView")
			end, 10, "the duel screen never opened" .. h.lastWarning())
			h.wait(1.0)
		end,
	},
	{
		name = "duel-turn",
		note = "A duel after a turn: what both of you did, the hit, the bars.",
		settle = 0,
		run = function(h)
			h.press("Move_1")
			h.wait(0.3)
			h.player2("duelAct", { action = "guard" })
			h.wait(0.45)
		end,
	},
	{
		name = "duel-end",
		note = "Yielding ends a duel: the end screen.",
		settle = 0,
		run = function(h)
			h.wait(1.2)
			local last = nil
			for i = 1, 24 do
				if h.find("Move_" .. i) then
					last = i
				end
			end
			h.assert(last ~= nil, "no moves on the duel screen")
			h.press("Move_" .. last) -- Yield is the last move
			h.wait(0.3)
			h.player2("duelAct", { action = "guard" })
			h.wait(0.8)
		end,
	},
	{
		name = "duel-after",
		note = "(not a picture: the duel's end screen is closed)",
		settle = 0,
		run = function(h)
			leaveFights(h)
			h.assert(not h.has("DuelView"), "the duel screen is still up")
		end,
	},
	{
		name = "event-talk",
		note = "A talking scene on an event card (Too Much Change): the speaker's face and the line, tap to go on.",
		run = function(h)
			h.continueFight()
			h.settle()
			h.closeSheets()
			h.ensureLife()
			h.clearPending()
			h.admin({ op = "event", id = "kl_pak_change" })
			h.settle()
			h.wait(1.2)
			h.assert(h.has("Dialogue"), "the talking scene didn't show")
		end,
	},
	{
		name = "event-talk-choices",
		note = "After the talk: the choices, with what each risk can win or cost.",
		run = function(h)
			for _ = 1, 6 do
				if not h.has("Dialogue") then
					break
				end
				h.press("Dialogue")
				h.wait(0.3)
				h.press("Dialogue")
				h.wait(0.3)
			end
			h.wait(0.4)
		end,
	},
	{
		name = "voice",
		note = "The brink, after the Light (What She Offers, forced from the mod menu): the voice has spoken, and every choice says what it risks.",
		run = function(h)
			h.closeSheets()
			h.ensureLife()
			h.clearPending()
			h.admin({ op = "event", id = "carmen_offer" })
			h.settle()
			h.wait(1.2)
			for _ = 1, 6 do
				if not h.has("Dialogue") then
					break
				end
				h.press("Dialogue")
				h.wait(0.3)
				h.press("Dialogue")
				h.wait(0.3)
			end
			h.wait(0.4)
			h.assert(h.has("EventCard"), "the event card didn't open")
		end,
	},
	{
		name = "death",
		note = "Her hand taken: the death screen says what happened, and what would have helped.",
		run = function(h)
			h.assert(h.choice("Take her hand"), "no such choice on the card")
			h.waitFor(function()
				return h.has("DeathReport")
			end, 40, "the death screen never showed its report")
			h.wait(1.5)
		end,
	},
	-- ── v0.12: the lobby (starting lives together) ──
	{
		name = "lobby",
		note = "The lobby as its host: a second player in and ready with the character they made, the host's settings picked.",
		run = function(h)
			h.closeSheets()
			h.quiet()
			-- (the second player is in your crew from the crew picture; if not, they're asked in)
			h.actions.openLobby()
			h.settle()
			h.assert(h.has("Lobby"), "the lobby didn't open")
			if not (h.state.crew and #h.state.crew.members >= 2) then
				h.player2("friends")
				h.actions.crewCall("crewInvite", { userId = 777 })
				h.settle()
				local joined = h.player2("crewRespond", { userId = 4242, accept = true })
				h.assert(joined.ok, "the second player couldn't join the lobby: " .. tostring(joined.error))
				h.settle()
			end
			h.assert(h.state.crew and h.state.crew.captain and h.state.crew.lobby, "you should be the lobby's host")
			h.actions.lobbySet("era", "library")
			h.settle()
			h.actions.lobbySet("district", "d12")
			h.settle()
			local ready = h.player2("crewTogetherReady", { first = "Mira", look = { skin = "deep", hair = "ponytail", hairColor = "rust", outfit = "fixer_coat" }, confirm = true })
			h.assert(ready.ok, "the second player couldn't ready up: " .. tostring(ready.error))
			h.settle()
			h.wait(0.6)
			h.quiet()
			h.assert(h.find("Picker_era") ~= nil, "the host should have the pickers")
			h.assert(h.find("StartTogether") ~= nil, "the host should have the start button")
		end,
	},
	{
		name = "lobby-creator",
		note = "Make my character, from the lobby: the same creator, with no When tab, the host's settings in its head, and I'M READY.",
		run = function(h)
			h.assert(h.press("MakeTogether"), "no Make my character button in the lobby")
			h.wait(0.8)
			h.settle()
			h.assert(h.has("QuickStart"), "the creator didn't open from the lobby")
			h.assert(not h.has("Tab_when"), "the creator in a lobby still offers When")
			h.assert(h.findPattern("^I'M READY$") ~= nil, "the creator in a lobby should say I'M READY")
		end,
	},
	{
		name = "lobby-ready",
		note = "Back in the lobby with everyone ready: the host can start.",
		run = function(h)
			h.assert(h.press("BeBorn"), "no I'M READY button")
			h.settle()
			h.wait(0.8)
			h.quiet()
			h.assert(h.has("Lobby"), "the lobby didn't come back after readying up")
			h.assert(h.state.crew and h.state.crew.together and h.state.crew.together.everyone == true, "everyone should be ready now")
		end,
	},
	{
		name = "lobby-guest",
		note = "The lobby as someone who isn't the host: the same settings as a short locked list.",
		run = function(h)
			-- hand the lobby to the second player: you leave, they open one and ask you in
			h.actions.leaveLobby()
			h.settle()
			h.wait(0.5)
			local theirs = h.player2("lobbyOpen")
			h.assert(theirs.ok, "the second player couldn't open a lobby: " .. tostring(theirs.error))
			h.player2("lobbySet", { key = "era", value = "after" })
			h.player2("lobbySet", { key = "district", value = "d21" })
			h.player2("lobbySet", { key = "side", value = "backstreets" })
			local asked = h.player2("crewInvite", { userId = 4242 })
			h.assert(asked.ok, "the second player couldn't ask you in: " .. tostring(asked.error))
			h.wait(0.6)
			h.assert(h.pressText("JOIN"), "no Join button on the invite")
			h.settle()
			h.wait(0.8)
			h.quiet()
			h.assert(h.has("Lobby"), "joining didn't open their lobby")
			h.assert(h.state.crew and h.state.crew.captain ~= true and h.state.crew.lobby and h.state.crew.lobby.era == "after", "you should be a guest in their lobby")
			h.assert(h.find("Picker_era") == nil and h.find("Setting") ~= nil, "a guest should see the locked list, not the pickers")
			h.assert(h.find("StartTogether") == nil, "a guest shouldn't have the start button")
		end,
	},
	{
		name = "linked-people",
		note = "After a lobby start (the host began everyone's lives): the People tab. Your friend is there once.",
		run = function(h)
			-- you ready up, the host starts on Fixer's Road (so both are grown), the lives begin
			h.player2("lobbySet", { key = "mode", value = "fixer" })
			h.assert(h.press("MakeTogether"), "no Make my character button")
			h.wait(0.8)
			h.settle()
			h.assert(h.press("BeBorn"), "no I'M READY button")
			h.settle()
			h.wait(0.6)
			local started = h.player2("crewTogetherStart")
			h.assert(started.ok, "the host couldn't start everyone's lives: " .. tostring(started.error))
			-- the opening, the birth roll and the first chapter card play; then the life screen
			h.waitFor(function()
				return h.state.life ~= nil and h.state.life.alive == true and h.ctx.hud.root.Visible and not h.state.cinema
			end, 90, "the life never came up after the host started it")
			h.wait(1)
			if h.has("SkipTutorial") then
				h.press("SkipTutorial")
				h.wait(0.4)
			end
			h.clearPending()
			h.quiet()
			local linked, total = 0, 0
			for _, rel in h.state.life.relations do
				total += 1
				if rel.linked then
					linked += 1
				end
			end
			h.assert(linked == 1, string.format("you should have exactly one linked friend after a lobby start of two (have %d of %d people)", linked, total))
			h.actions.openFamily()
			h.wait(0.6)
			h.quiet()
		end,
	},
	{
		name = "linked-scene",
		note = "Spending time with your linked friend: the scene, with what it does for them as well.",
		run = function(h)
			local rel = nil
			for _, r in h.state.life.relations do
				if r.linked then
					rel = r
				end
			end
			h.assert(rel, "no linked friend to spend time with")
			h.closeSheets()
			h.actions.interact(rel.id, "spend_time")
			h.settle()
			h.wait(0.8)
			h.assert(h.has("EventCard"), "spending time with a linked friend didn't open a scene")
		end,
	},
	{
		name = "linked-after",
		note = "After the evening: your feed and the People tab. Your friend is still there once.",
		run = function(h)
			h.assert(h.pickChoice(), "no choice to take on the scene")
			h.settle()
			h.wait(1)
			h.clearPending()
			h.quiet()
			local linked = 0
			for _, rel in h.state.life.relations do
				if rel.linked then
					linked += 1
				end
			end
			h.assert(linked == 1, "after an evening with them you should still have one linked friend (have " .. linked .. ")")
			h.actions.openFamily()
			h.wait(0.6)
			h.quiet()
		end,
	},
	{
		name = "linked-received",
		note = "Your friend does something for you: it lands in your life too, as a card in your feed.",
		run = function(h)
			h.closeSheets()
			local theirs = h.player2("friends").life
			local relId = nil
			for _, r in theirs.relations do
				if r.linked then
					relId = r.id
				end
			end
			h.assert(relId, "the second player has no linked friend")
			local it = h.player2("interact", { relId = relId, id = "spend_time" })
			h.assert(it.ok, "the second player couldn't spend time with you: " .. tostring(it.error))
			local pending = it.life and it.life.pending
			if pending then
				local pick = 1
				for _, c in pending.choices do
					if c.enabled and not c.clash then
						pick = c.index
						break
					end
				end
				local ch = h.player2("choose", { index = pick })
				h.assert(ch.ok, "the second player couldn't choose: " .. tostring(ch.error))
			end
			h.wait(1.2)
			h.quiet()
		end,
	},
	-- ── v0.12 ──
	{
		name = "friend-sheet",
		note = "A linked friend's page: how strong they are right now (every stat, most Health, job, renown).",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			local rel = nil
			for _, r in h.state.life.relations do
				if r.linked then
					rel = r
				end
			end
			h.assert(rel, "no linked friend")
			h.assert(rel.sheet ~= nil, "the linked friend came without their current stats")
			h.actions.openPerson(rel)
			h.wait(0.6)
			h.quiet()
			h.assert(h.has("FriendStats"), "the friend's page doesn't show their stats")
		end,
	},
	{
		name = "market",
		note = "The Overpass Market: what's on the tables this year, what each thing gives, and prices that move with the streets.",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			h.admin({ op = "stat", stat = "money", value = 90000 })
			h.settle()
			h.quiet()
			h.ui("Sheets").market(h.ctx, h.ctx.sheetLayer, "overpass")
			h.wait(0.6)
			h.quiet()
		end,
	},
	{
		name = "you-renown",
		note = "The You tab, grown up: renown (Hana's grades for a threat), and a home of your own.",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			h.admin({ op = "stat", stat = "renown", value = 300 })
			h.settle()
			h.actions.buyMarket("letting", "lt_safehouse")
			h.settle()
			h.clearPending()
			h.quiet()
			h.actions.openYouPanel()
			h.wait(0.6)
			h.quiet()
			h.assert(h.findText("RENOWN") or h.findText("Renown"), "no Renown card on the You tab")
		end,
	},
	{
		name = "city-known",
		note = "The City tab: who you know of, by section, with your standing on each; the Districts this server has changed.",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			h.actions.openCityPanel()
			h.wait(0.6)
			h.quiet()
			h.assert(h.findText("WHO YOU KNOW OF") or h.findText("Who you know of"), "no Who you know of on the City tab")
		end,
	},
	-- ── v0.14: cutscenes (UI/Stage.luau), caught mid-play ──
	{
		name = "v14-fight-walk",
		note = "A fight, acted out: you and your foe walk into the alley from either side.",
		run = function(h)
			h.closeEvent()
			h.closeSheets()
			h.clearPending()
			local Avatar = h.ui("AvatarView").Avatar
			local look = Avatar.randomLook(h.ctx.info.avatar, h.roller(0.37))
			local clash = {
				fight = true,
				won = true,
				rounds = { { winner = "player" }, { winner = "tie" }, { winner = "foe" }, { winner = "player" } },
				stance = { name = "Overpower" },
				foe = { name = "Syndicate Enforcer" },
				enemy = { id = "syndicate", kind = "human", name = "Syndicate Enforcer", look = look, barks = { start = { "The boss sends regards." }, lose = { "This isn't over." } } },
			}
			h.stageClash = clash
			Harness.task.spawn(function()
				h.ui("Stage").fightIntro(h.ctx, h.ctx.cinemaLayer, clash, { art = "alley", kicker = "District 21  ·  Backstreets", full = true })
				h.stageDone = true
			end)
			h.wait(0.9)
		end,
	},
	{
		name = "v14-fight-closeup",
		note = "The foe up close, with a name plate and a line.",
		run = function(h)
			h.wait(1.6)
		end,
	},
	{
		name = "v14-fight-title",
		note = "Squared off, a low shot, FIGHT.",
		run = function(h)
			h.waitFor(function()
				return h.findText("FIGHT") ~= nil
			end, 10, "FIGHT never came up")
			h.wait(0.12)
		end,
	},
	{
		name = "v14-fight-exchange",
		note = "After the coins, the fight's own rounds acted out: whoever took a round lands a blow.",
		run = function(h)
			h.waitFor(function()
				return h.stageDone == true
			end, 12, "the fight intro never ended")
			h.stageDone = false
			Harness.task.spawn(function()
				h.ui("Stage").fightOutro(h.ctx, h.ctx.cinemaLayer, h.stageClash, { art = "alley" })
				h.stageDone = true
			end)
			h.wait(0.95)
		end,
	},
	{
		name = "v14-fight-end",
		note = "The blow that settled it, and the fall.",
		run = function(h)
			h.waitFor(function()
				return h.findText("VICTORY") ~= nil
			end, 12, "VICTORY never came up")
			h.wait(0.1)
		end,
	},
	{
		name = "v14-meet",
		note = "A meeting: you walk up the stairwell to someone sitting on the steps.",
		run = function(h)
			h.waitFor(function()
				return h.stageDone == true
			end, 12, "the fight ending never ended")
			h.stageDone = false
			local Avatar = h.ui("AvatarView").Avatar
			Harness.task.spawn(function()
				h.ui("Stage").meet(h.ctx, h.ctx.cinemaLayer, {
					set = "stairs",
					title = "The Neighbor's Badge",
					kicker = "Across the landing",
					line = "They gave me a suit today. It fits like it was waiting for me.",
					other = { name = "Ilse Brandt", role = "your neighbor, an L Corp agent", pose = "sit", appearance = { look = Avatar.randomLook(h.ctx.info.avatar, h.roller(0.71)), age = 27, form = "human" } },
				})
				h.stageDone = true
			end)
			h.wait(2.6)
		end,
	},
	{
		name = "v14-meet-line",
		note = "Their line, close up.",
		run = function(h)
			h.wait(1.6)
		end,
	},
	{
		name = "v14-street",
		note = "Another set: a Backstreets street at night, with a creature for a foe.",
		run = function(h)
			h.waitFor(function()
				return h.stageDone == true
			end, 14, "the meeting never ended")
			h.stageDone = false
			local clash = {
				fight = true,
				won = false,
				foe = { name = "Something in the dark" },
				enemy = { id = "night_stalker", kind = "creature", name = "Something in the dark", shape = "tall", color = { 30, 30, 40 }, eye = { 240, 70, 60 } },
			}
			Harness.task.spawn(function()
				h.ui("Stage").fightIntro(h.ctx, h.ctx.cinemaLayer, clash, { art = "street", kicker = "District 12  ·  Backstreets" })
				h.stageDone = true
			end)
			h.wait(1.0)
		end,
	},
	{
		name = "v14-facility",
		note = "The old L Corp corridor, for a meeting by an intercom.",
		run = function(h)
			h.waitFor(function()
				return h.stageDone == true
			end, 14, "the creature fight never ended")
			h.stageDone = false
			local Avatar = h.ui("AvatarView").Avatar
			Harness.task.spawn(function()
				h.ui("Stage").meet(h.ctx, h.ctx.cinemaLayer, {
					set = "facility",
					title = "The Hatch Behind the Boiler",
					line = "Agent Voss, please report to the Welfare Team.",
					other = { name = "The intercom", role = "a voice in the wall", appearance = { look = Avatar.randomLook(h.ctx.info.avatar, h.roller(0.13)), age = 30, form = "human" } },
				})
				h.stageDone = true
			end)
			h.wait(2.2)
		end,
	},
	{
		name = "v14-train",
		note = "Doing something with your year: training on a straw dummy.",
		run = function(h)
			h.waitFor(function()
				return h.stageDone == true
			end, 14, "the facility meeting never ended")
			h.stageDone = false
			h.ui("Stage").vignettesSeen = {}
			Harness.task.spawn(function()
				h.ui("Stage").vignette(h.ctx, h.ctx.cinemaLayer, "train", {})
				h.stageDone = true
			end)
			h.wait(1.15)
		end,
	},
	{
		name = "v14-moment",
		note = "A turning point: a new part of life, out on a roof at dusk.",
		run = function(h)
			h.waitFor(function()
				return h.stageDone == true
			end, 14, "the training never ended")
			h.stageDone = false
			Harness.task.spawn(function()
				h.ui("Stage").moment(h.ctx, h.ctx.cinemaLayer, { title = "Making a Name", kicker = "A new part of life", line = "You're grown, by the City's count. Everything is open, and nothing is free." })
				h.stageDone = true
			end)
			h.wait(3.4)
		end,
	},
	{
		name = "v14-descent",
		note = "Going in: a delve found in the world, and you walking up to the way in.",
		run = function(h)
			h.waitFor(function()
				return h.stageDone == true
			end, 14, "the moment never ended")
			h.stageDone = false
			Harness.task.spawn(function()
				h.ui("Stage").descent(h.ctx, h.ctx.cinemaLayer, { title = "The Branch Under the Laundromat", kicker = "Exploration", set = "underpass" })
				h.stageDone = true
			end)
			h.wait(1.1)
		end,
	},
	-- ── v0.13 ──
	{
		name = "v13-episode",
		note = "An episode's card: its name in the band, pips for how far along it is, and the paper of its theme.",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			h.admin({ op = "event", id = "ep_ru_1" })
			h.wait(0.8)
			h.quiet()
			h.assert(h.findText("Thirteen Umbrellas") or h.findPattern("THIRTEEN UMBRELLAS"), "no episode band")
		end,
	},
	{
		name = "v13-terminal",
		note = "A card from an old L Corp facility: green paper, scan lines, the episode's pips.",
		run = function(h)
			h.closeEvent()
			h.clearPending()
			h.admin({ op = "event", id = "ep_ic_2" })
			h.wait(0.8)
			h.quiet()
		end,
	},
	{
		name = "v13-rare",
		note = "A rare card: the gold ribbon, and the paper of a once-in-a-life moment.",
		run = function(h)
			h.closeEvent()
			h.clearPending()
			h.admin({ op = "event", id = "ep_mw_4" })
			h.wait(0.8)
			h.quiet()
		end,
	},
	{
		name = "v13-arsenal",
		note = "The gear page: what you carry in framed rarity tiles, the set bonus that's on, broken limits, and the stash.",
		run = function(h)
			h.closeEvent()
			h.clearPending()
			h.admin({ op = "stat", stat = "money", value = 90000 })
			h.admin({ op = "stat", stat = "renown", value = 300 })
			for _, id in { "sm_brass_knuckles", "hv_longsword", "nw_waxed_coat", "hv_duster", "sm_scarf", "hv_whetstone" } do
				h.admin({ op = "gear", id = id })
			end
			h.settle()
			h.quiet()
			h.ui("Sheets").life(h.ctx, h.ctx.sheetLayer, "Gear")
			h.wait(0.8)
			h.quiet()
		end,
	},
	{
		name = "v13-workshop",
		note = "The Workshop: tabs by slot and by set, tiles grouped by rarity, prices and what each piece does.",
		run = function(h)
			h.closeSheets()
			h.ui("Arsenal").shop(h.ctx, h.ctx.sheetLayer)
			h.wait(0.8)
			h.quiet()
		end,
	},
	{
		name = "v13-goals",
		note = "Goals: the part of life you're in, ambitions, cases, episodes, and the feats board from bronze to mythic.",
		run = function(h)
			h.closeSheets()
			h.actions.openGoals()
			h.wait(0.8)
			h.quiet()
			h.assert(h.findPattern("FEATS") or h.findText("Feats"), "no feats on the Goals sheet")
		end,
	},
	{
		name = "v13-turf",
		note = "The City tab in a turf war: your District's blocks, who holds each, and which are yours.",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			h.admin({ op = "event", id = "turf_word" })
			h.wait(0.6)
			h.choice("Step in, for yourself")
			h.settle()
			h.clearPending()
			h.quiet()
			h.actions.openCityPanel()
			h.wait(0.6)
			h.quiet()
		end,
	},
	-- ── v0.15 ──
	{
		name = "v15-boss",
		note = "A big boss: a Capo of the Thumb gets the full entrance, a red plate and his line.",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			h.stageDone = false
			local Avatar = h.ui("AvatarView").Avatar
			local clash = {
				fight = true,
				won = false,
				boss = true,
				foe = { name = "Capo Aurelio Brandimarte", coins = 3 },
				-- the Capo's own look, as City/Foes.luau dresses him
				enemy = { id = "thumb_capo", kind = "human", name = "Capo Aurelio Brandimarte", look = { skin = "fair", hair = "slick", hairColor = "ash", eyes = "grey", outfit = "sottocapo_suit", accessory = "fedora", weapon = "revolver" }, barks = { start = { "Kneel, and this goes quickly." } } },
			}
			h.ui("Stage").fightsSeen = 3
			Harness.task.spawn(function()
				h.ui("Stage").fightIntro(h.ctx, h.ctx.cinemaLayer, clash, { art = "street", kicker = "The Thumb" })
				h.stageDone = true
			end)
			h.wait(2.3)
		end,
	},
	{
		name = "v15-kids",
		note = "Growing up: what a seven-year-old can do with a year now.",
		run = function(h)
			h.waitFor(function()
				return h.stageDone == true
			end, 14, "the boss entrance never ended")
			h.closeSheets()
			h.clearPending()
			h.admin({ op = "stat", stat = "age", value = 7 })
			h.settle()
			h.clearPending()
			h.quiet()
			h.actions.openActivities()
			h.wait(0.6)
			h.quiet()
			h.assert(h.has("Sheet"), "the Activities sheet didn't open")
		end,
	},
	-- ── v0.16 ──
	{
		name = "v16-battle",
		note = "A boss battle in turns: the Capo, his Health and phases, the move he's about to make and at whom, and your moves with their odds.",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			h.admin({ op = "stat", stat = "age", value = 30 })
			for _, k in { "strength", "speed", "intelligence", "charisma", "mind", "luck" } do
				h.admin({ op = "stat", stat = k, value = 82 })
			end
			h.admin({ op = "stat", stat = "health", value = 120 })
			h.settle()
			h.clearPending()
			h.admin({ op = "event", id = "b15_thumb_capo" })
			h.wait(0.8)
			h.quiet()
			h.choice("Fight the Capo")
			h.waitFor(function()
				return h.has("BattleView")
			end, 10, "the battle screen never opened")
			h.wait(0.6)
		end,
	},
	{
		name = "v16-battle-turn",
		note = "After a turn: the hit lands, the log says what happened, and the next move shows.",
		run = function(h)
			h.press("Move_1")
			h.wait(1.0)
		end,
	},
	{
		name = "v17-store",
		note = "The store (v0.17), from the STORE button: the header with your wallet, a box for codes, aisles to jump to.",
		run = function(h)
			-- (the v16 battle is still on screen: get out of it)
			leaveFights(h)
			h.closeSheets()
			h.assert(not h.has("BattleView"), "the battle screen is still up")
			h.assert(h.press("QuickStore"), "no STORE button in the quick bar")
			h.wait(1.0)
			h.assert(h.has("StoreHero"), "the store didn't open with its header")
		end,
	},
	{
		name = "v17-mod",
		note = "The mod menu (v0.17), from the MOD button: the Power tab (every stat to 400, limit breaks, lifespan, techniques, trainers).",
		run = function(h)
			h.closeSheets()
			h.assert(h.press("QuickMod"), "no MOD button for the admin")
			h.wait(0.8)
			h.assert(h.press("AdminTab_Power"), "no Power tab in the mod menu")
			h.wait(0.5)
		end,
	},
	{
		name = "v17-look",
		note = "Customised from the mod menu: a feminine build, a furnace arm, the Lantern's coat, and every stat at 400.",
		run = function(h)
			h.closeSheets()
			h.admin({ op = "look", category = "body", id = "feminine" })
			h.admin({ op = "look", category = "outfit", id = "lantern_coat" })
			h.admin({ op = "gear", id = "aug_furnace" })
			h.admin({ op = "maxStats", value = 400 })
			h.settle()
			h.wait(0.8)
		end,
	},
	{
		name = "v17-extreme",
		note = "An extreme boss in turns (v0.17): the Stopped Clocktower, a Star of the City Distortion, Health in the thousands.",
		run = function(h)
			h.closeSheets()
			h.clearPending()
			h.admin({ op = "battle", id = "clocktower_distortion" })
			h.waitFor(function()
				return h.has("BattleView")
			end, 10, "the extreme battle never opened")
			h.wait(1.2)
		end,
	},
	{
		name = "v17-extreme-turn",
		note = "A turn landing: the slash, the sparks, the ring, the damage number.",
		run = function(h)
			h.press("Move_1")
			h.wait(0.35)
		end,
	},
	{
		name = "v18-store",
		note = "The store (v0.18): big and centered, the Featured aisle first (the pass with everything, the best value, the starter pack).",
		run = function(h)
			leaveFights(h)
			h.closeSheets()
			h.assert(h.press("QuickStore"), "no STORE button in the quick bar")
			h.wait(1.0)
			h.assert(h.has("StoreHero") and h.has("Aisles"), "the store didn't open with its header and aisles")
		end,
	},
	{
		name = "v18-store-lunacy",
		note = "The store's Lunacy aisle: every pack with its icon, its bonus, and how much Lunacy per Robux.",
		run = function(h)
			h.assert(h.press("Aisle_3"), "no third aisle")
			h.wait(0.5)
		end,
	},
	{
		name = "v18-talents",
		note = "The mod menu's Talents tab (v0.18): what they have, every talent by rarity and sin, and every trait, to give or take away.",
		run = function(h)
			h.closeSheets()
			h.assert(h.press("QuickMod"), "no MOD button for the admin")
			h.wait(0.8)
			h.assert(h.press("AdminTab_Talents"), "no Talents tab in the mod menu")
			h.wait(0.5)
			h.assert(h.has("TalentGrid"), "no talent cards")
		end,
	},
	{
		name = "v18-fx-preview",
		note = "The mod menu's Effects tab (v0.18): a 3D preview of Burn, you and a training dummy on the real stage.",
		settle = 0.1,
		run = function(h)
			h.assert(h.press("AdminTab_Effects"), "no Effects tab in the mod menu")
			h.wait(0.4)
			h.assert(h.press("Fx3_4"), "no 3D Burn preview button")
			h.wait(1.05)
			h.assert(h.has("FxPreview"), "the 3D preview didn't open")
		end,
	},
	{
		name = "v18-fx-after",
		note = "The preview ends by itself and the mod menu comes back.",
		capture = false,
		run = function(h)
			h.wait(3.5)
			h.assert(not h.has("FxPreview"), "the 3D preview didn't close")
			h.closeSheets()
		end,
	},
}

-- (blueprint) a game made with the blueprint shoots its own generic states (SNAP_STEPS=game):
-- tests/game_steps.luau reads the game's content to pick its mode, a fight and a boss
if process.env.SNAP_STEPS == "game" then
	STEPS = require("./game_steps")(leaveFights)
end

-- ── the dump ────────────────────────────────────────────────────────────────
local roblox = require("@lune/roblox")

local function num(x: number)
	if x ~= x then
		return 0
	end
	if x == math.huge or x == -math.huge then
		return nil -- JSON null: the renderer reads it as infinity
	end
	return math.floor(x * 1000 + 0.5) / 1000
end
local function byte(x: number): number
	return math.clamp(math.floor(x * 255 + 0.5), 0, 255)
end

local ENCODE = {}
ENCODE.number = num
function ENCODE.string(v)
	return v
end
function ENCODE.boolean(v)
	return v
end
function ENCODE.UDim2(v)
	return { num(v.X.Scale), num(v.X.Offset), num(v.Y.Scale), num(v.Y.Offset) }
end
function ENCODE.UDim(v)
	return { num(v.Scale), num(v.Offset) }
end
function ENCODE.Vector2(v)
	return { num(v.X), num(v.Y) }
end
function ENCODE.Vector3(v)
	return { num(v.X), num(v.Y), num(v.Z) }
end
function ENCODE.Color3(c)
	return { byte(c.R), byte(c.G), byte(c.B) }
end
function ENCODE.EnumItem(e)
	return e.Name
end
function ENCODE.Font(f)
	return { family = f.Family, weight = f.Weight.Name, style = f.Style.Name }
end
function ENCODE.ColorSequence(s)
	local out = {}
	for _, k in s.Keypoints do
		table.insert(out, { num(k.Time), byte(k.Value.R), byte(k.Value.G), byte(k.Value.B) })
	end
	return out
end
function ENCODE.NumberSequence(s)
	local out = {}
	for _, k in s.Keypoints do
		table.insert(out, { num(k.Time), num(k.Value), num(k.Envelope) })
	end
	return out
end
function ENCODE.NumberRange(r)
	return { num(r.Min), num(r.Max) }
end
function ENCODE.Rect(r)
	return { num(r.Min.X), num(r.Min.Y), num(r.Max.X), num(r.Max.Y) }
end
function ENCODE.CFrame(cf)
	local out = {}
	for _, v in { cf:GetComponents() } do
		table.insert(out, num(v))
	end
	return out
end
local function encode(v)
	local e = ENCODE[typeof(v)]
	if e then
		return e(v)
	end
	return nil
end

local GUI_PROPS = {
	"Visible", "Size", "Position", "AnchorPoint", "AutomaticSize", "Rotation", "ZIndex", "LayoutOrder",
	"BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "BorderColor3", "BorderMode",
	"ClipsDescendants", "SizeConstraint",
}
local TEXT_PROPS = {
	"Text", "RichText", "FontFace", "TextSize", "TextScaled", "TextWrapped", "TextColor3", "TextTransparency",
	"TextXAlignment", "TextYAlignment", "TextTruncate", "LineHeight", "TextStrokeColor3", "TextStrokeTransparency",
	"MaxVisibleGraphemes",
}
local IMAGE_PROPS = { "Image", "ImageColor3", "ImageTransparency", "ScaleType", "SliceCenter", "SliceScale", "TileSize", "ImageRectOffset", "ImageRectSize" }
local CLASS_PROPS = {
	TextLabel = TEXT_PROPS,
	TextButton = TEXT_PROPS,
	TextBox = table.move({ "PlaceholderText", "PlaceholderColor3", "MultiLine" }, 1, 3, #TEXT_PROPS + 1, table.clone(TEXT_PROPS)),
	ScrollingFrame = {
		"CanvasSize", "CanvasPosition", "AutomaticCanvasSize", "ScrollingDirection", "ScrollBarThickness",
		"ScrollBarImageColor3", "ScrollBarImageTransparency", "VerticalScrollBarInset", "HorizontalScrollBarInset",
		"VerticalScrollBarPosition", "ScrollingEnabled",
	},
	ImageLabel = IMAGE_PROPS,
	ImageButton = IMAGE_PROPS,
	ViewportFrame = { "Ambient", "LightColor", "LightDirection", "ImageColor3", "ImageTransparency" },
	CanvasGroup = { "GroupTransparency", "GroupColor3" },
	VideoFrame = { "Video" },
}
local MOD_PROPS = {
	UICorner = { "CornerRadius" },
	UIStroke = { "Color", "Thickness", "Transparency", "ApplyStrokeMode", "LineJoinMode", "Enabled", "BorderStrokePosition" },
	UIGradient = { "Color", "Transparency", "Rotation", "Offset", "Enabled" },
	UIPadding = { "PaddingTop", "PaddingRight", "PaddingBottom", "PaddingLeft" },
	UIListLayout = { "Padding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder", "Wraps", "HorizontalFlex", "VerticalFlex", "ItemLineAlignment" },
	UIGridLayout = { "CellSize", "CellPadding", "FillDirection", "FillDirectionMaxCells", "StartCorner", "HorizontalAlignment", "VerticalAlignment", "SortOrder" },
	UIPageLayout = { "Padding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder" },
	UITableLayout = { "Padding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder" },
	UIAspectRatioConstraint = { "AspectRatio", "AspectType", "DominantAxis" },
	UISizeConstraint = { "MinSize", "MaxSize" },
	UITextSizeConstraint = { "MinTextSize", "MaxTextSize" },
	UIScale = { "Scale" },
	UIFlexItem = { "FlexMode", "GrowRatio", "ShrinkRatio", "ItemLineAlignment" },
}
local SCREEN_PROPS = { "Enabled", "DisplayOrder", "IgnoreGuiInset", "ZIndexBehavior", "ScreenInsets", "ClipToDeviceSafeArea" }
-- what Lune can't read until it's set (no default in its database): Roblox's defaults
local FALLBACK = {
	IgnoreGuiInset = false,
	CornerRadius = { 0, 8 },
}

local function propsFor(real): { string }
	local cls = real.ClassName
	if MOD_PROPS[cls] then
		return MOD_PROPS[cls]
	end
	if real:IsA("LayerCollector") then
		return SCREEN_PROPS
	end
	local list = table.clone(GUI_PROPS)
	for _, k in CLASS_PROPS[cls] or {} do
		table.insert(list, k)
	end
	return list
end

local function readAll(real, list)
	local out = {}
	for _, key in list do
		local ok, v = pcall(function()
			return real[key]
		end)
		if ok and v ~= nil then
			out[key] = encode(v)
		elseif FALLBACK[key] ~= nil then
			out[key] = FALLBACK[key]
		end
	end
	return out
end

local function same(a, b): boolean
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for k, v in a do
		if not same(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end

local defaultsCache = {}
local function defaultsOf(real)
	local cls = real.ClassName
	if defaultsCache[cls] == nil then
		local ok, fresh = pcall(roblox.Instance.new, cls)
		defaultsCache[cls] = if ok then readAll(fresh, propsFor(fresh)) else false
	end
	return defaultsCache[cls]
end

local function partsOf(h, vp)
	local parts = {}
	for _, d in vp:GetDescendants() do
		if d:IsA("BasePart") then
			local ok, part = pcall(function()
				return {
					class = d.ClassName,
					shape = if d:IsA("Part") then d.Shape.Name else "Block",
					size = ENCODE.Vector3(d.Size),
					cframe = ENCODE.CFrame(d.CFrame),
					color = ENCODE.Color3(d.Color),
					material = d.Material.Name,
					transparency = num(d.Transparency),
				}
			end)
			if ok then
				table.insert(parts, part)
			end
		end
	end
	local cam = h.vpCamera[vp] or vp:FindFirstChildOfClass("Camera")
	local camera = nil
	if cam then
		camera = { cframe = ENCODE.CFrame(cam.CFrame), fov = num(cam.FieldOfView) }
	end
	return { camera = camera, parts = parts, avatar = h.avatarOf[vp] }
end

-- (v0.18) the 3D stage (src/client/UI/World3D.luau), when one is up: its parts, the camera,
-- the light, and its effects (particles as emitted counts, lights, beams) for the renderer
local function worldOf(h)
	local ws = h.dm:GetService("Workspace")
	local folder = ws:FindFirstChild("LifeSimWorld3D")
	if not folder then
		return nil
	end
	local cam = ws:FindFirstChild("Camera")
	local lighting = h.dm:GetService("Lighting")
	local parts, fx = {}, {}
	local function worldPos(inst): any
		if inst:IsA("Attachment") then
			local p = inst.Parent
			if p and p:IsA("BasePart") then
				return (p.CFrame * inst.CFrame).Position
			end
		elseif inst:IsA("BasePart") then
			return inst.CFrame.Position
		end
		return nil
	end
	local function seqEnds(seq)
		local kps = seq.Keypoints
		return kps[1].Value, kps[#kps].Value
	end
	for _, d in folder:GetDescendants() do
		if d:IsA("BasePart") and d.Transparency < 0.999 then
			pcall(function()
				table.insert(parts, {
					shape = if d:IsA("Part") then d.Shape.Name else "Block",
					size = ENCODE.Vector3(d.Size),
					cframe = ENCODE.CFrame(d.CFrame),
					color = ENCODE.Color3(d.Color),
					material = d.Material.Name,
					transparency = num(d.Transparency),
				})
			end)
		elseif d:IsA("ParticleEmitter") then
			pcall(function()
				local pos = worldPos(d.Parent)
				local emitted = d:GetAttribute("LifeSimEmitted") or 0
				if d.Enabled and d.Rate > 0 then
					emitted += math.floor(d.Rate * d.Lifetime.Max)
				end
				if pos and emitted > 0 then
					local maxSize = 0
					for _, k in d.Size.Keypoints do
						maxSize = math.max(maxSize, k.Value)
					end
					local c0 = d.Color.Keypoints[1].Value
					local c1 = d.Color.Keypoints[#d.Color.Keypoints].Value
					local t0 = seqEnds(d.Transparency)
					local tex = string.match(d.Texture, "([%w_]+)%.%w+$") or "glow"
					table.insert(fx, {
						kind = "particles",
						tex = tex,
						pos = ENCODE.Vector3(pos),
						count = emitted,
						size = num(maxSize),
						speed = num(d.Speed.Max),
						life = num(d.Lifetime.Max),
						drag = num(d.Drag),
						accel = ENCODE.Vector3(d.Acceleration),
						spread = num(math.max(d.SpreadAngle.X, d.SpreadAngle.Y)),
						streak = d.Orientation.Name == "VelocityParallel",
						flat = d.Orientation.Name == "VelocityPerpendicular",
						light = num(d.LightEmission),
						alpha = num(1 - t0),
						color0 = ENCODE.Color3(c0),
						color1 = ENCODE.Color3(c1),
					})
				end
			end)
		elseif d:IsA("PointLight") and d.Enabled then
			pcall(function()
				local pos = worldPos(d.Parent)
				if pos and d.Brightness > 0.05 then
					table.insert(fx, { kind = "light", pos = ENCODE.Vector3(pos), color = ENCODE.Color3(d.Color), brightness = num(d.Brightness), range = num(d.Range) })
				end
			end)
		elseif d:IsA("Beam") then
			pcall(function()
				local a0, a1 = d.Attachment0, d.Attachment1
				local p0, p1 = worldPos(a0), worldPos(a1)
				local t0, t1 = seqEnds(d.Transparency)
				if p0 and p1 and math.min(t0, t1) < 0.95 then
					local x0 = (a0.Parent.CFrame * a0.CFrame).RightVector
					local x1 = (a1.Parent.CFrame * a1.CFrame).RightVector
					table.insert(fx, {
						kind = "beam",
						p0 = ENCODE.Vector3(p0),
						p1 = ENCODE.Vector3(p1),
						c0 = ENCODE.Vector3(p0 + x0 * d.CurveSize0),
						c1 = ENCODE.Vector3(p1 - x1 * d.CurveSize1),
						width0 = num(d.Width0),
						width1 = num(d.Width1),
						color = ENCODE.Color3(d.Color.Keypoints[1].Value),
						alpha = num(1 - math.min(t0, t1)),
					})
				end
			end)
		end
	end
	return {
		camera = cam and { cframe = ENCODE.CFrame(cam.CFrame), fov = num(cam.FieldOfView) } or nil,
		lighting = {
			clock = num(lighting.ClockTime),
			brightness = num(lighting.Brightness),
			ambient = ENCODE.Color3(lighting.Ambient),
			outdoor = ENCODE.Color3(lighting.OutdoorAmbient),
		},
		parts = parts,
		fx = fx,
	}
end

-- the PlayerGui as JSON-ready tables; only what's visible (a hidden subtree draws nothing)
local function dumpGui(h)
	local defaults = {}
	local count = 0
	local function node(real)
		local cls = real.ClassName
		local isGui = real:IsA("GuiObject")
		local isMod = MOD_PROPS[cls] ~= nil
		local isLayer = real:IsA("LayerCollector")
		local isFolder = cls == "Folder"
		if not (isGui or isMod or isLayer or isFolder) then
			return nil
		end
		if isGui and not real.Visible then
			return nil
		end
		if isLayer and not real.Enabled then
			return nil
		end
		count += 1
		local out = { class = cls, name = real.Name }
		if not isFolder then
			local d = defaultsOf(real)
			local props = readAll(real, propsFor(real))
			if d then
				defaults[cls] = d
				for k, v in props do
					if same(v, d[k]) then
						props[k] = nil
					end
				end
			end
			if next(props) then
				out.props = props
			end
		end
		if real:IsA("ViewportFrame") then
			out.viewport = partsOf(h, real)
		end
		if not isMod then
			local kids = {}
			for _, c in real:GetChildren() do
				local n = node(c)
				if n then
					table.insert(kids, n)
				end
			end
			if #kids > 0 then
				out.children = kids
			end
		end
		return out
	end
	local guis = {}
	for _, g in h.realPlayerGui:GetChildren() do
		local n = node(g)
		if n then
			table.insert(guis, n)
		end
	end
	return guis, defaults, count
end

-- ── the driver's helpers ────────────────────────────────────────────────────
local function makeHelpers(h)
	local realOf, signalsOf = h.realOf, h.signalsOf
	local startedAt = nil

	local function visible(real): boolean
		local r = real
		while r do
			if r:IsA("GuiObject") and not r.Visible then
				return false
			end
			if r:IsA("LayerCollector") then
				local ok, enabled = pcall(function()
					return r.Enabled
				end)
				return not ok or enabled ~= false
			end
			r = r.Parent
		end
		return false
	end
	local function plain(s: string): string
		s = string.gsub(s, "<[^>]*>", "")
		s = string.gsub(s, "&lt;", "<")
		s = string.gsub(s, "&gt;", ">")
		s = string.gsub(s, "&amp;", "&")
		return string.upper(s)
	end

	function h.assert(cond, message)
		if not cond then
			error(message or "assertion failed", 0)
		end
		return cond
	end
	function h.wait(seconds: number?)
		local t = math.max(0, seconds or 0)
		local stop = h.now() + t
		vtask.wait(t)
		while h.now() < stop - 1e-6 do
			vtask.wait(stop - h.now())
		end
	end
	function h.sinceStart(): number
		return if startedAt then h.now() - startedAt else 0
	end
	function h.findAll(name: string)
		local out = {}
		for _, d in h.realPlayerGui:GetDescendants() do
			if d.Name == name and visible(d) then
				table.insert(out, h.wrap(d))
			end
		end
		return out
	end
	function h.find(name: string)
		return h.findAll(name)[1]
	end
	function h.has(name: string): boolean
		return h.find(name) ~= nil
	end
	-- a visible text object whose whole (plain, upper-cased) text matches a Lua pattern
	function h.findPattern(pattern: string)
		for _, d in h.realPlayerGui:GetDescendants() do
			if (d:IsA("TextLabel") or d:IsA("TextButton")) and visible(d) and string.find(plain(d.Text), pattern) then
				return h.wrap(d)
			end
		end
		return nil
	end
	-- the newest warning the game printed (" (...)" or ""), for error messages
	function h.lastWarning(): string
		for i = #h.errors, 1, -1 do
			local e = h.errors[i]
			if string.sub(e, 1, 9) == "warning: " then
				return " (" .. string.gsub(string.sub(e, 10), "^%[LifeSim%] ", "") .. ")"
			end
		end
		return ""
	end
	-- waits (up to maxSeconds) until check() is true; errors with `message` if it never is
	function h.waitFor(check, maxSeconds: number, message: string)
		for _ = 1, math.ceil(maxSeconds * 20) do
			if check() then
				return
			end
			h.wait(0.05)
		end
		error(message .. h.lastWarning(), 0)
	end
	-- waits for toasts and celebration banners to go (they come and go on their own, one
	-- banner at a time, about 3 s each: a few years of found lore can queue up a minute)
	function h.quiet(maxSeconds: number?)
		local toastGui = h.realPlayerGui:FindFirstChild("LifeSimToast")
		for _ = 1, (maxSeconds or 60) * 10 do
			local busy = false
			if toastGui then
				for _, d in toastGui:GetDescendants() do
					if d.Name == "Celebration" or (d:IsA("TextLabel") and d.Text ~= "" and visible(d)) then
						busy = true
						break
					end
				end
			end
			if not busy then
				break
			end
			h.wait(0.1)
		end
	end
	-- the fight screen (ClashView.play) gets to round n
	function h.waitRound(n: number)
		local before = #h.errors
		for _ = 1, 160 do
			if h.findPattern("^ROUND " .. n) then
				h.wait(0.75) -- the coins are flipped and the powers up about 0.75 s into a round
				return
			end
			if #h.errors > before and not h.findPattern("^ROUND %d") and not h.findPattern("^VS$") then
				break
			end
			h.wait(0.05)
		end
		error("the fight screen never got to round " .. n .. h.lastWarning(), 0)
	end
	-- after a failed state: a screen that crashed can leave its overlay up (the fight screen's
	-- scrim does), which would cover every later picture
	function h.recover(): number
		local cleared = 0
		local clash = h.realPlayerGui:FindFirstChild("LifeSimClash")
		if clash and not h.findPattern("^CONTINUE$") then
			for _, c in clash:GetChildren() do
				if c.Name == "Column" then
					for _, cc in c:GetChildren() do
						if cc:IsA("GuiObject") then
							cc:Destroy()
							cleared += 1
						end
					end
				elseif c:IsA("GuiObject") then
					c:Destroy()
					cleared += 1
				end
			end
		end
		pcall(h.closeSheets)
		return cleared
	end
	function h.findText(text: string)
		local want = string.upper(text)
		for _, d in h.realPlayerGui:GetDescendants() do
			if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and visible(d) then
				if string.find(plain(d.Text), want, 1, true) then
					return h.wrap(d)
				end
			end
		end
		return nil
	end
	local function fire(p, event: string, ...)
		local sig = signalsOf[p] and signalsOf[p][event]
		if sig then
			sig:Fire(...)
			return true
		end
		return false
	end
	function h.press(target): boolean
		local p = target
		if type(target) == "string" then
			p = nil
			for _, cand in h.findAll(target) do
				if realOf[cand]:IsA("GuiButton") then
					p = cand
					break
				end
			end
		end
		if not p then
			return false
		end
		fire(p, "MouseButton1Down")
		fire(p, "MouseButton1Up")
		local a = fire(p, "Activated")
		local b = fire(p, "MouseButton1Click")
		return a or b
	end
	function h.pressText(text: string): boolean
		local want = string.upper(text)
		for _, d in h.realPlayerGui:GetDescendants() do
			if d:IsA("GuiButton") and d:IsA("TextButton") and visible(d) and string.find(plain(d.Text), want, 1, true) then
				return h.press(h.wrap(d))
			end
		end
		return false
	end
	function h.type(name: string, text: string)
		local box = h.find(name)
		h.assert(box and realOf[box]:IsA("TextBox"), "no TextBox " .. name)
		box.Text = text
		fire(box, "FocusLost", true)
	end
	function h.choice(text: string): boolean
		local want = string.upper(text)
		for _, b in h.findAll("Choice") do
			if string.find(plain(realOf[b]:GetAttribute("Label") or realOf[b].Text), want, 1, true) then
				return h.press(b)
			end
		end
		return false
	end
	function h.approach(n: number?): boolean
		local list = h.findAll("Approach")
		local b = list[n or 1]
		return b ~= nil and h.press(b)
	end
	function h.settle(maxSeconds: number?)
		local state = h.state
		local spins = 0
		while state and (state.busy or state.applying) and spins < (maxSeconds or 30) * 20 do
			spins += 1
			h.wait(0.05)
		end
		h.wait(0.1)
	end
	function h.admin(payload)
		local res = nil
		local p = table.clone(payload)
		if p.target == nil and p.op ~= "world" and p.op ~= "daily" and p.op ~= "announce" then
			p.target = 4242
		end
		h.actions.adminCall(p, function(r)
			res = r
		end)
		h.settle()
		h.assert(res and res.ok, "admin " .. tostring(p.op) .. " failed: " .. tostring(res and res.error))
		return res
	end
	function h.closeSheets()
		local Sheets = h.ui("Sheets")
		for _ = 1, 10 do
			local top = Sheets.stack[#Sheets.stack]
			if not top then
				break
			end
			top()
			h.wait(0.3)
		end
	end
	-- an event card left open (or its approach picker) gets its first plain choice
	function h.closeEvent()
		for _ = 1, 6 do
			if not h.state.life or not h.state.life.pending then
				return
			end
			h.pickChoice()
			h.settle()
			h.wait(0.3)
			h.continueFight()
		end
	end
	-- the first enabled choice without a fight or check, else the first enabled one
	function h.pickChoice(): boolean
		local best, bestOrder, fallback, fallbackOrder = nil, math.huge, nil, math.huge
		for _, b in h.findAll("Choice") do
			local real = realOf[b]
			if real.TextTransparency == 0 then
				local risky = real:GetAttribute("Clash") == true
				if not risky and real.LayoutOrder < bestOrder then
					best, bestOrder = b, real.LayoutOrder
				end
				if real.LayoutOrder < fallbackOrder then
					fallback, fallbackOrder = b, real.LayoutOrder
				end
			end
		end
		local pick = best or fallback
		if not pick then
			return false
		end
		h.press(pick)
		h.wait(0.05)
		if h.has("Approach") then
			h.approach(1)
		end
		return true
	end
	-- the fight screen waits for Continue; a check card closes itself
	function h.continueFight()
		for _ = 1, 600 do
			if h.findPattern("^CONTINUE$") and h.pressText("CONTINUE") then
				h.wait(0.2)
				return true
			end
			if not (h.state.applying or h.state.busy) then
				return false
			end
			h.wait(0.1)
		end
		return false
	end
	-- answer whatever the life is waiting on (talk, choices, fights) so a forced event can open
	function h.clearPending()
		for _ = 1, 30 do
			local life = h.state.life
			if not (life and life.alive and life.pending) then
				break
			end
			if h.has("SkipDialogue") then
				h.press("SkipDialogue")
				h.wait(0.2)
			end
			if not h.pickChoice() then
				h.wait(0.3)
			end
			h.settle()
			h.continueFight()
		end
		h.closeEvent()
	end

	function h.ensureLife()
		local life = h.state.life
		if not (life and life.alive) then
			h.actions.newLife("backstreets_family", "Petra", nil, nil, { mode = MODE })
			h.settle()
			h.wait(1.5)
			if h.has("SkipTutorial") then
				h.press("SkipTutorial")
				h.wait(0.4)
			end
		end
		local hud = h.ctx.hud
		if hud and not hud.root.Visible then
			h.actions.showMenu()
			h.wait(0.3)
			h.press("Continue")
			h.wait(0.5)
		end
		h.assert(h.state.life and h.state.life.alive, "no life")
	end
	function h.liveYears(n: number)
		local startAge = h.state.life.age
		for _ = 1, 200 do
			h.settle()
			h.continueFight()
			local life = h.state.life
			if not life.alive or life.age >= startAge + n then
				break
			end
			if life.pending then
				if not h.pickChoice() then
					h.wait(0.5)
				end
			else
				-- one thing to do each year, so the report has some of everything
				for _, a in life.activities or {} do
					if a.enabled and life.actionsLeft > 0 and not a.clash and math.random() < 0.5 then
						h.actions.doActivity(a.id)
						h.settle()
						h.continueFight()
						break
					end
				end
				if not h.state.life.pending and h.state.life.alive then
					h.actions.ageUp()
				end
			end
			h.wait(0.2)
		end
		h.settle()
		h.continueFight()
		-- whatever the last year opened gets answered
		for _ = 1, 6 do
			if not h.state.life.pending then
				break
			end
			h.pickChoice()
			h.settle()
			h.continueFight()
			h.wait(0.3)
		end
	end
	function h.ui(name: string)
		return h.require(h.clientRoot.UI[name])
	end
	function h.startApp()
		local Server = h.require(h.serverRoot)
		local before = #h.errors
		Server.start()
		-- what the server says while loading content isn't about any one screen: one line for it
		local loading = #h.errors - before
		if loading > 0 then
			for _ = 1, loading do
				table.insert(h.bootLog, table.remove(h.errors, before + 1))
			end
			print(string.format("        (the server printed %d warnings while loading the content pack; --verbose shows them)", loading))
			if h.verbose then
				for _, e in h.bootLog do
					print("        " .. e)
				end
			end
		end
		local App = h.require(h.clientRoot.App)
		startedAt = h.now()
		App.start()
		h.App = App
		h.ctx = App.ctx
		h.state = App.ctx.state
		h.actions = App.ctx.actions
		h.assert(h.ctx and h.state.info, "the app didn't say hello to the server")
		-- (v0.14) the fight screens below are caught as they open: the acted-out intro would
		-- stand in front of them. The cutscene states call Stage themselves.
		h.actions.setSetting("cutscenes", "off")
		h.settle()
	end
	-- a roll(n) for looks made up on the spot (Avatar.randomLook)
	function h.roller(seed: number)
		local s = math.max(1, math.floor(seed * 2147483646))
		return function(n: number): number
			s = (s * 48271) % 2147483647
			return (s % n) + 1
		end
	end
	local p2 = nil
	function h.player2(action: string, payload: any?)
		if not p2 then
			p2 = h.addPlayer("Mira", 777)
		end
		return p2(action, payload)
	end
	-- the second player has a grown-up life with nothing waiting on them
	local p2Alive = false
	function h.p2Life()
		if not p2Alive then
			local r = h.player2("newLife", { origin = "backstreets_family", first = "Mira", mode = MODE, look = { skin = "deep", hairColor = "rust" } })
			h.assert(r.ok, "the second player couldn't start a life: " .. tostring(r.error))
			p2Alive = true
		end
		for _ = 1, 20 do
			local st = h.player2("friends").life
			if not (st and st.pending) then
				break
			end
			local pick = 1
			for _, c in st.pending.choices do
				if c.enabled then
					pick = c.index
					break
				end
			end
			h.player2("choose", { index = pick })
		end
	end
end

-- ── command line ────────────────────────────────────────────────────────────
local args = {}
do
	local i = 1
	local list = process.args
	while i <= #list do
		local a = list[i]
		if string.sub(a, 1, 2) == "--" then
			local key = string.sub(a, 3)
			local value = list[i + 1]
			if value == nil or string.sub(value, 1, 2) == "--" then
				args[key] = true
			else
				args[key] = value
				i += 1
			end
		end
		i += 1
	end
end

if args.list then
	for _, s in STEPS do
		print(string.format("%-16s %s", s.name, s.note or ""))
	end
	return
end

local OUT = if type(args.out) == "string" then args.out else "tools/gui_render/out/dumps"

-- which states get saved (the steps before them still run)
local wanted = nil
if type(args.states) == "string" then
	wanted = {}
	for part in string.gmatch(args.states, "[^,%s]+") do
		table.insert(wanted, part)
	end
end
local function isWanted(name: string): boolean
	if not wanted then
		return true
	end
	for _, w in wanted do
		if name == w or string.sub(name, 1, #w) == w then
			return true
		end
	end
	return false
end
local lastWanted = 0
for i, s in STEPS do
	if isWanted(s.name) and s.capture ~= false then
		lastWanted = i
	end
end
if lastWanted == 0 then
	print("no state matches --states " .. tostring(args.states) .. " (lune run tests/gui_snapshot --list)")
	process.exit(1)
end

-- several devices: one process each (a Lune process can boot the client once)
local deviceArg = if type(args.device) == "string" then args.device else "all"
if deviceArg == "all" or string.find(deviceArg, ",", 1, true) then
	local list = if deviceArg == "all" then DEFAULT_DEVICES else {}
	if deviceArg ~= "all" then
		for d in string.gmatch(deviceArg, "[^,%s]+") do
			table.insert(list, d)
		end
	end
	local failed = 0
	for _, d in list do
		local childArgs = { "run", "tests/gui_snapshot", "--device", d, "--out", OUT }
		if type(args.states) == "string" then
			table.insert(childArgs, "--states")
			table.insert(childArgs, args.states)
		end
		local r = process.exec("lune", childArgs, { stdio = "inherit" })
		if not r.ok then
			failed += 1
		end
	end
	process.exit(if failed > 0 then 1 else 0)
end

local device = DEVICES[deviceArg]
if not device then
	print("unknown device " .. deviceArg .. " (pc, phone, tablet)")
	process.exit(1)
end
device = table.clone(device)
if type(args.size) == "string" then
	local w, hgt = string.match(args.size, "^(%d+)x(%d+)$")
	assert(w, "--size wants WIDTHxHEIGHT, like 1920x1080")
	device.width, device.height = tonumber(w), tonumber(hgt)
	device.name = device.name .. "-" .. args.size
end
if args.inset then
	device.inset = tonumber(args.inset) or device.inset
end

-- ── run ─────────────────────────────────────────────────────────────────────
print(string.format("GUI snapshot: %s %dx%d (topbar %d)", device.name, device.width, device.height, device.inset))
local okBoot, h = pcall(Harness.boot, device, { seed = 7, verbose = args.verbose == true })
if not okBoot then
	print("  FAIL  boot: " .. tostring(h))
	process.exit(1)
end
h.verbose = args.verbose == true
h.bootLog = {}
makeHelpers(h)

local dir = OUT .. "/" .. device.name
local pending = {} -- writes waiting for the main thread
local manifest = { device = device, states = {} }
local errorsSeen = 0

local function capture(step, index: number)
	local guis, defaults, count = dumpGui(h)
	local dump = {
		format = "gui-snapshot/1",
		state = step.name,
		index = index,
		note = step.note,
		device = device.name,
		screen = { device.width, device.height },
		inset = device.inset,
		time = num(h.now()),
		defaults = defaults,
		guis = guis,
		world = worldOf(h),
	}
	local json = serde.encode("json", dump, false)
	table.insert(pending, { path = dir .. "/" .. step.name .. ".json", data = json })
	return count, #json
end

local function newErrors(): { string }
	local out = {}
	for i = errorsSeen + 1, #h.errors do
		table.insert(out, h.errors[i])
	end
	errorsSeen = #h.errors
	return out
end

local saved, skipped = 0, 0
local function driver()
	for i = 1, lastWanted do
		local step = STEPS[i]
		local ok, err = pcall(step.run, h)
		local errs = newErrors()
		if ok then
			h.wait(step.settle or 0.6)
			for _, e in newErrors() do
				table.insert(errs, e)
			end
			if step.capture ~= false and isWanted(step.name) then
				local okCap, count, bytes = pcall(capture, step, i)
				if okCap then
					saved += 1
					print(string.format("  ok    %-16s %5d objects  %4d KB  t=%.1fs", step.name, count, bytes // 1024, h.now()))
					table.insert(manifest.states, { name = step.name, note = step.note, index = i, ok = true })
				else
					skipped += 1
					print(string.format("  skip  %-16s couldn't dump: %s", step.name, tostring(count)))
					table.insert(manifest.states, { name = step.name, note = step.note, index = i, ok = false, error = tostring(count) })
				end
			end
		else
			skipped += 1
			print(string.format("  skip  %-16s %s", step.name, tostring(err)))
			table.insert(manifest.states, { name = step.name, note = step.note, index = i, ok = false, error = tostring(err) })
			local okRec, cleared = pcall(h.recover)
			if okRec and cleared > 0 then
				print(string.format("        (cleared %d objects a crashed screen left on the clash layer, so later states aren't covered)", cleared))
			end
		end
		for _, e in errs do
			local warning = string.sub(e, 1, 9) == "warning: "
			local text = if warning then string.sub(e, 10) else e
			print("        (" .. (if warning then "game warning" else "ui error") .. ") " .. (string.gsub(text, "\n", "\n        ")))
		end
	end
end

-- Lune's fs can't run inside the scheduler's coroutines: writes happen here, between frames
fs.writeDir(dir)
-- the states this run redoes lose their old dump first (a state that's skipped now has none)
for i = 1, lastWanted do
	local step = STEPS[i]
	if isWanted(step.name) and step.capture ~= false and fs.isFile(dir .. "/" .. step.name .. ".json") then
		fs.removeFile(dir .. "/" .. step.name .. ".json")
	end
end
local previous = {}
if fs.isFile(dir .. "/manifest.json") then
	local okRead, old = pcall(function()
		return serde.decode("json", fs.readFile(dir .. "/manifest.json"))
	end)
	if okRead and type(old) == "table" and type(old.states) == "table" then
		for _, st in old.states do
			if type(st) == "table" and st.name and not isWanted(st.name) then
				table.insert(previous, st)
			end
		end
	end
end
local function flush()
	for _, w in pending do
		fs.writeFile(w.path, w.data)
	end
	pending = {}
end

-- the driver runs as the main coroutine, waiting on the virtual clock
Harness.run(driver, h, flush, 3600)
flush()
-- states from earlier runs that this one didn't redo stay listed
for _, st in previous do
	table.insert(manifest.states, st)
end
table.sort(manifest.states, function(a, b)
	return (a.index or 0) < (b.index or 0)
end)
manifest.saved = saved
manifest.skipped = skipped
fs.writeFile(dir .. "/manifest.json", serde.encode("json", manifest, true))
print(string.format("%s: %d saved, %d skipped -> %s/", device.name, saved, skipped, dir))
if saved == 0 then
	process.exit(1)
end
