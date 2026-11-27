--[[
	Kit settings. Safe to edit.
]]

return {
	-- Which content pack runs (Shared > Pack):
	--   "City"       the Project Moon City: a fan game, so the Robux store is switched off
	--   "Undermere"  the original setting (with the looks-only store)
	pack = "BitLeveling",
	-- (v0.18) show the game modes marked hidden (Fixer's Road) in the start menu and the lobby.
	-- Off for players; the headless tests turn it on.
	devModes = false,

	-- DataStore name. Change the suffix to wipe everyone's saves. Each pack needs its own,
	-- because a life from one pack can't be continued in the other.
	-- (The Undermere pack used "LifeSim_Undermere_v2".)
	dataStoreName = "LifeSim_BitLeveling_v1",

	-- The mod menu. These players (Roblox user ids) can start world events, change today's
	-- event, make any event happen to anyone, set stats, heal, give traits, rolls and more,
	-- and post announcements (filtered like chat). `owner` adds the place's owner, `studio`
	-- lets anyone use it while testing in Studio.
	admin = {
		users = { 523337247 },
		owner = true,
		studio = true,
	},

	-- (v0.13) A household of your own can become a marriage: a ceremony at the District office
	-- with family there, never romance (no dating, no kissing, nothing on screen) and never with
	-- another player. Roblox's maturity questionnaire may still count marriage as a "romance"
	-- theme: if your experience's label must stay at Mild, set this to false and households stay
	-- households.
	marriage = true,

	-- City news in the chat when a player on the server does something big.
	chatNews = true,
	-- show each player's title in their current life in front of their chat messages
	chatTags = true,

	-- A text life-sim doesn't need avatars walking around behind the UI.
	disableCharacters = true,

	-- Procedural 3D city drawn behind the UI (client-side only). Each Ward has its
	-- own spot, light and landmarks; see `backdrop` on each district in Content.
	backdrop = true,

	-- How many finished lives (lanterns) to keep per player.
	maxLanterns = 60,

	-- Sound effects: Roblox Creator Store audio (search "limbus" in the Creator Store's Audio).
	-- An id, or { id = ..., volume = ... }. Leave one out (or "") to silence it. Uploads by
	-- other people can be taken down by Roblox at any time; a missing sound just goes quiet.
	sfx = {
		volume = 0.3, -- v0.10: everything a good deal quieter; the buttons quieter still
		-- the join intro: "LIMBUS COMPANY!", once, as the intro starts
		intro = { id = 136558976377458, volume = 0.45 },
		transition = 111474834139985, -- scene transition: Cantos, Intervallos, the mode select
		-- menus and buttons
		click = { id = 101579863217690, volume = 0.16 }, -- UI click 1
		confirm = { id = 119514733669898, volume = 0.2 }, -- UI click 2
		tab = { id = 131776850478043, volume = 0.16 }, -- battle UI
		reroll = 97564402737431, -- Dante's clock rewinding: rerolls and the birth roll
		resonance = 74578647755806, -- picking a sin
		-- coin clashes
		coin = { id = 132596270805754, volume = 0.22 }, -- coin flip
		tails = { id = 90448103253452, volume = 0.22 }, -- a coin lands tails
		clash = 120171660922619, -- clash draw
		clashWin = 74854125236607, -- clash won
		parry = 111913931670052, -- parry win
		evade = 73456708215174,
		guard = 108548606364997,
		hit = 82880079097413,
		slash = 102360766617958,
		pierce = 114823440881243,
		blunt = 77951971772104,
		crit = 132015436228708, -- critical / Poise hit
		stagger = 137592261284291,
		tremorBurst = 84022207370828,
		burn = 89989865225661,
		bossStart = { id = 108760159697947, volume = 0.4 }, -- Proelium Fatale!
		defeat = 119164791265768,
		-- life
		panic = 81470902110645,
		ego = 104416839342380, -- E.G.O crack
		death = 111878951416164,
		shatter = 88226215199235, -- Sanity breaks
		prescript = 71629892905253,
	},

	-- Background music, picked by mood. The game moves between moods on its own:
	-- battle in clashes, scary in breaches and fog, goofy in childhood, calm in the
	-- Charter, intense on dungeon runs, sad on the death screen, hero for big
	-- moments. A Ward can set its own mood with `music` in Content (districts).
	-- Players can mute it with the speaker button.
	music = {
		enabled = true,
		volume = 0.35,
		fade = 2.5, -- seconds to crossfade between tracks
		hold = 90, -- an ambient mood plays at least this long before the music may change
		moods = {
			boss = { 85214333918906 }, -- Limbus Company boss theme
			hero = { 9042616620, 1837063192, 1837079862 }, -- Last Charge, Releasing the Beast, Gatekeeper
			sad = { 1837083871 }, -- Give In To The Night
			angry = { 1837059295 }, -- Dawn of Destiny
			emotional = { 1837084344 }, -- Higher Ground
			goofy = { 1837065871, 1837065835 }, -- Devilishly Daring, Mischief and Mayhem
			calm = { 1837064422, 1837085693 }, -- Revelation, Ascendant
			uplifting = { 9041839737, 1837072312, 9041844265, 1837060654, 9042612250 }, -- Transcendance, Flower Duet, Whirlpool, The Last Fall, Restored
			semi = { 1837106380, 1837072359, 1837062973, 9039328128, 9041840070, 1837084291, 9042614810 }, -- Gymnopedie, Moonlight Sonata, Battle of Honour, Blood Moon Lullaby, Gravity, Higher Ground, Override
			scary = { 1837059475 }, -- Limitless Reach
			intense = { 1837068276, 9046420614, 1837064012, 9038213562, 1837081677, 9042611959, 9040003655, 1837059570, 9040002148, 9041848481, 9042613158, 1837064066 },
			battle = { 9038213241, 9046408415, 1837063626, 9038220273, 9038213597, 9046407900, 1845149698 }, -- Gekido, Furious, The Executioner, Zengeance, Kyoso, My Thunder, Seek N Destroy
			vocal = { 1837065029, 9038212468, 1837083988 }, -- You Stand Alone, Hunt Me Down, Shadows
			extra = { 122692586554943, 135720954799216, 134075603974035 },
			-- quieter tracks for the lore panel, the menus and slow years. Paste ids you're
			-- allowed to use (the Creator Store's music library is free for Roblox games).
			relaxing = { 1837106380, 1837072359, 1837064422, 1837085693, 1837072312 }, -- Gymnopedie, Moonlight Sonata, Revelation, Ascendant, Flower Duet
		},
		-- which mood plays where (the client picks the first that applies)
		-- Quick checks, the lore panel and celebrations don't change the music any more.
		places = {
			intro = "vocal",
			introNight = "scary", -- the join cinematic at 3:13
			menu = "semi",
			creator = "semi",
			duel = "battle",
			fight = "battle",
			boss = "boss",
			death = "sad",
			dungeon = "intense",
			containment = "battle",
			mission = "semi",
			trip = "uplifting",
			childhood = "relaxing",
			charter = "calm",
			gutters = "semi",
		},
		-- world events with no mood below play by their tone
		worldEventTones = { danger = "intense", strange = "scary" },
		-- world events change the mood while they're on
		worldEvents = {
			abnormality_breach = "scary",
			night_in_backstreets = "intense",
			thumb_crackdown = "angry",
			distortion_sighting = "scary",
			library_appears = "emotional",
			breach_tidewell = "scary",
			fog_week = "scary",
			lantern_festival = "uplifting",
			great_low_tide = "uplifting",
			company_strike = "angry",
		},
	},

	-- Server-wide world events (Content/WorldEvents.luau): a breach, a festival...
	worldEvents = {
		enabled = true,
		firstDelay = 180, -- seconds after the server starts before the first roll
		every = 540, -- seconds between rolls
		chance = 0.65, -- chance each roll starts one
	},

	-- (BitLeveling) THE LIVE CITY: Gates that open in real time in the walkable 3D city
	-- (server/HunterLive). `every` is the seconds between new Gates (a High-Danger life on the
	-- server makes it about half), `maxIncidents` how many run at once, `civilians` how many
	-- people walk the streets. Admins (and anyone in Studio) get a TEST GATE button.
	hunterLive = {
		enabled = true,
		opening = true, -- the opening cinematic when a player joins (a raid party walking into a Gate)
		firstDelay = 45,
		every = { 150, 320 },
		maxIncidents = 2,
		civilians = 24,
		cityName = "Seoul",
		country = "korea",
	},

	-- The store: Robux purchases that are looks only. Nothing here changes stats,
	-- money, Glow, odds, lifespans or leaderboard scores.
	-- Paste ids from the Creator Dashboard: Developer Products (kind = "product")
	-- and Game Passes (kind = "pass"). Leave id = 0 until you've made them; with
	-- testInStudio, items can be test-bought for free in Studio.
	-- (v0.17) REDEEM CODES: typed in the store's "Have a code?" box, once per player. Add your own
	-- here, or make them in game from the mod menu (Codes tab). Grants: "lunacy:N", "light:N",
	-- "rolls:N", "boost:heal", "boost:ahn:N", or a look ("outfit:color_coat", "body:feminine").
	-- expires = a Unix time (os.time()) after which the code stops working; leave it out to keep it.
	codes = {
		WELCOME = { grants = { "lunacy:60", "light:5" }, note = "Welcome to the City: 60 Lunacy and 5 Light." },
	},

	store = {
		testInStudio = true,
		-- A fan pack (like the City) sells nothing unless this is true. The owner's call: on for
		-- a small private game. The catalog comes from the pack (src/shared/City/Store.luau).
		sellInFanPacks = true,
		note = "Nothing here changes your odds, your money or your score.",
		items = {
			-- small
			{ key = "dye_lantern", kind = "product", id = 0, price = 25, tier = "Small", name = "Lantern Gold Dye", desc = "Hair that catches the lamplight.", grants = { "hairColor:lantern" } },
			{ key = "dye_tide", kind = "product", id = 0, price = 25, tier = "Small", name = "Tide Silver Dye", desc = "The color of the Mere at dawn.", grants = { "hairColor:tidesilver" } },
			{ key = "mark_gilt", kind = "product", id = 0, price = 35, tier = "Small", name = "Gilt Freckles", desc = "Freckles that shine like brass leaf.", grants = { "mark:gilt" } },
			-- medium
			{ key = "frame_crimson", kind = "product", id = 0, price = 79, tier = "Medium", name = "Crimson File", desc = "Red brackets on your file card.", grants = { "frame:crimson" } },
			{ key = "frame_brine", kind = "product", id = 0, price = 79, tier = "Medium", name = "Brine File", desc = "Sea-green brackets on your file card.", grants = { "frame:brine" } },
			{ key = "outfit_midnight", kind = "product", id = 0, price = 99, tier = "Medium", name = "Midnight Diver", desc = "Black canvas with a sea-glass collar.", grants = { "outfit:midnight" } },
			{ key = "outfit_rimward", kind = "product", id = 0, price = 99, tier = "Medium", name = "Rimward Finery", desc = "Cream, wine and brass. Dressed for the Charter galas.", grants = { "outfit:rimward" } },
			{ key = "hair_lamphat", kind = "product", id = 0, price = 129, tier = "Medium", name = "Lamplighter's Hat", desc = "A tall felt hat with a little lamp on the band.", grants = { "hair:lamphat" } },
			-- big
			{ key = "pack_parade", kind = "product", id = 0, price = 199, tier = "Big", name = "Lantern Parade", desc = "When a life ends, a whole parade of lanterns goes out with it.", grants = { "lantern:parade" } },
			{ key = "pass_patron", kind = "pass", id = 0, price = 299, tier = "Big", name = "Patron of the Mere", desc = "A patron's purple coat and file card, and a patron badge on every leaderboard. Forever.", grants = { "outfit:patron", "frame:patron", "badge:patron" } },
			{ key = "pack_gilded", kind = "product", id = 0, price = 499, tier = "Big", name = "The Gilded Charter", desc = "A gold coat, a gold file card, golden lanterns, and your name in gold on the rankings.", grants = { "outfit:gilded", "frame:gold", "lantern:gold", "badge:gilded" } },
		},
	},

	-- Print content-pack warnings to the Output window on server start.
	verboseValidation = true,
}
