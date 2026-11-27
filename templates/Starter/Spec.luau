--[[
	THE GAME SPEC: everything that makes this game this game, in one table.
	Base.build (src/shared/Base) turns it into a whole content pack; anything left out gets a
	working default. The full reference is spec/SPEC.md; the shapes of cards, dungeons, bosses
	and foes are in docs/CONTENT_GUIDE.md and in the files beside this one.

	Stat ids: the seven stats below have ids (`health`, `strength`...). Everywhere else (cards,
	careers, gear, dungeons) uses those ids: `{ strength = 2 }`, `stat = "strength"`.
	Colors are { r, g, b } (0-255). Tokens in text: {first} {currency} {district} {side} {zone}.
]]

return {
	id = "Starter", -- the folder name (src/shared/Games/Starter) and the save name

	meta = {
		title = "A Starter Life",
		tagline = "One life, a year at a time.",
		about = "Grow up, find work, make friends and enemies, and see how it ends.",
		currency = "coins", -- the money word: "50 coins"
		lanternName = "Story", -- what a finished life becomes
		ledgerName = "Your Stories", -- the shelf of finished lives
		glowName = "Stars", -- meta currency (earned by finishing lives, records, the daily gift)
		premiumName = "Gems", -- premium currency (the store)
		districtWord = "Town", -- what a place is called ("Town 3")
		actionsPerYear = 4, -- things to do a year (DO tab); more with Speed and Smarts perks
		socialPerYear = 3, -- time for people a year (PEOPLE tab)
		adultAge = 18,
	},

	calendar = { startYear = 1000, startJitter = 3 },

	-- THE SEVEN STATS (fixed jobs, your names). See Base/Stats.luau for what each one does.
	stats = {
		health = { id = "health", name = "Health", short = "HP", color = { 214, 96, 88 }, desc = "Your body. At zero, you die." },
		fight = { id = "strength", name = "Strength", short = "STR", color = { 232, 142, 70 }, desc = "How hard you hit." },
		speed = { id = "speed", name = "Speed", short = "SPD", color = { 96, 206, 196 }, desc = "How many clashes you can take, and who strikes first." },
		work = { id = "smarts", name = "Smarts", short = "INT", color = { 120, 170, 226 }, desc = "Study, skill and jobs." },
		charm = { id = "charm", name = "Charm", short = "CHA", color = { 226, 126, 178 }, desc = "How people take to you." },
		luck = { id = "luck", name = "Luck", short = "LCK", color = { 136, 204, 110 }, desc = "Dealt at birth: tilts every coin.", birth = { 1, 22 } },
		will = { id = "will", name = "Willpower", short = "WIL", color = { 168, 120, 222 }, desc = "How much your mind can carry." },
		mood = { name = "Mood" }, -- the engine's Sanity: low mood makes every coin worse
	},

	-- the four ways to fight (each beats one foe temper): rename them for your world
	fighting = {
		fight = { name = "Overpower" },
		speed = { name = "Outpace" },
		work = { name = "Outthink" },
		charm = { name = "Talk down" },
	},

	-- WHERE LIVES HAPPEN: sides (the first is the rich one) and places
	world = {
		sides = {
			{ id = "uptown", name = "Uptown", short = "Uptown", desc = "Clean streets, guards on the corners, rent that hurts.", costMult = 2, payMult = 1.25, danger = 0.35, hazardChance = 0.08, evictOnDebt = true, evictGrace = 1, color = { 226, 214, 170 } },
			{ id = "downtown", name = "Downtown", short = "Downtown", desc = "Cheap rent, loud nights, trouble close by.", costMult = 0.6, payMult = 0.9, danger = 1, hazardChance = 0.28, wear = 1, color = { 170, 130, 120 } },
		},
		districts = {
			{ id = "riverside", name = "Riverside", desc = "Warehouses and barges along the river.", wealth = 0.9, danger = 1.2, cost = 40, charterCost = 1200, charterShare = 0.25, population = 1.2 },
			{ id = "hilltop", name = "Hilltop", desc = "Old houses, older money.", wealth = 1.4, danger = 0.7, cost = 80, charterCost = 2400, charterShare = 0.45, population = 0.7 },
		},
	},

	-- WHO YOU'RE BORN AS (unlockable ones cost Stars: glowCost)
	origins = {
		{ id = "ordinary", name = "Ordinary Family", desc = "Two tired parents and a roof that mostly holds.", birth = "You were born to two tired parents in {zone}.", money = 15, family = { mother = true, father = true, siblings = { 0, 2 } }, glowCost = 0 },
		{ id = "street_kid", name = "On Your Own", desc = "Nobody's child, and tough from the first breath.", birth = "Nobody knows exactly where you were born. Somewhere in {district}.", side = "downtown", money = 0, stats = { health = 4 }, family = { siblings = { 0, 0 } }, glowCost = 2 },
	},

	-- CAREERS: ranks, pay per rank, what promotes you. More in Careers.luau.
	careers = {},

	-- GEAR: one item per slot. More in Gear.luau.
	gear = { slots = { "tool", "coat", "charm" }, items = {} },

	-- THE LOOK OF THE GAME
	theme = {
		accent = { 207, 163, 73 }, -- buttons, highlights, brass edges
		crimson = { 196, 50, 42 }, -- danger
		money = { 234, 200, 108 },
		-- panel = { 14, 16, 20 }, text = { 236, 232, 225 }, strange = { 96, 186, 178 } ...
	},
	backdrop = "city", -- behind the UI: "city" (a skyline), "crater" (a lit crater town) or "none"

	-- MAPS: the 3D places fights and cutscenes happen in (client/UI/Stage.luau: usePlaces)
	places = {
		{
			id = "town_square",
			time = "dusk",
			ground = { color = { 120, 112, 100 }, material = "slate" },
			parts = {
				{ "row", "building", from = -30, to = 30, step = 9, z = -12, jitter = 1 },
				{ "row", "lamp", from = -16, to = 16, step = 8, z = -3 },
				{ "cyl", 0, 1, -6, 4, 2, { 150, 146, 140 }, "marble" }, -- a fountain
				{ "glow", 0, -1, 10, { 255, 210, 150 } },
			},
			words = { "square", "town" },
			fights = "street",
		},
	},

	-- EFFECTS: rename and tint the seven statuses (burn, bleed, tremor, rupture, sinking, poise, charge)
	vfx = {
		statuses = {
			-- sinking = { name = "Frost", color = { 150, 210, 255 } },
		},
		-- hit = { 255, 226, 170 },
	},

	-- THE JOIN INTRO: lines typed over the backdrop (or `cold` + `cards`, like the City pack)
	intro = {
		lines = { "Every town has its stories.", "This one is about to have yours.", "You're about to be born." },
	},

	-- HOW HARD IT IS (Base/Systems.luau: TUNING). The defaults are dangerous; a gentler game:
	tuning = {
		lethality = 1.4,
		-- hardness = { cardBase = 0, dangerBase = 1, dread = { chance = 0.1 } },
		-- focus = { topics = { lib_ = true }, names = { lib_ = "The Library" } },
	},

	-- THE STORE (what it sells; prices are Robux suggestions, ids come from the Creator Dashboard)
	-- store = { note = "...", items = { ... } }   -- or in Store.luau

	-- NAMES people are given
	names = {
		first = { "Ada", "Bram", "Cleo", "Dario", "Elin", "Felix", "Greta", "Hugo", "Ines", "Jonas" },
		last = { "Ashford", "Brook", "Caldwell", "Dunmore", "Ellery", "Fairfax", "Garner", "Holloway" },
	},
}
