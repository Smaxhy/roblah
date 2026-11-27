--[[
	BITLEVELING: a life in the world of Solo Leveling (non-commercial fan game).

	Canon reference: the original Solo Leveling webtoon/manhwa (Chugong, DUBU / Redice
	Studio, h-goon), main story and side story. The anime (A-1 Pictures), the game Solo
	Leveling: Arise and the sequel Ragnarok are NOT used as canon. The research notes this
	content was written from are in docs/BITLEVELING_CANON.md, with a confidence label on every
	fact and a list of popular claims that are NOT canon (colour-coded Gate ranks, a fixed
	seven-day break timer, calendar years...).

	Every piece of content here is one of two things, and the docs say which:
		CANON                  established by the manhwa (Gate ranks, Red Gates, the Jeju
		                       break, the Hunters Association, the National Level Hunters...)
		ORIGINAL GAME CONTENT  this game's own, written to fit the canon without contradicting
		                       it (the player's life, the odds, the incidents in your city,
		                       every number the manhwa never gives)

	The player is never Sung Jinwoo, never the Shadow Monarch's vessel, never chosen. The
	System is his; nobody else has one. Canon characters appear only where they canonically
	would, and mostly the way ordinary people meet them: on the news.

	THE CALENDAR: canon gives no calendar year for anything. Years here count from the first
	Gates ("Gate Year 0"). The story begins about ten years after (Gate Year 10, canon); the
	relative years of the big public events follow the canon brief, approximate where canon is.
]]

local Skills = require(script.Parent:WaitForChild("Skills"))
-- (v0.19) bonds with everyone you meet, and a party of NPCs (Interactions.luau, Engine/Party)
local Interactions = require(script.Parent:WaitForChild("Interactions"))
-- the game's named NPCs (Roster.luau), when the game has one: an empty list until then
local Roster = (function(): { any }
	local m = script.Parent:FindFirstChild("Roster")
	return if m then require(m :: any) else {}
end)()

local function gateYear(y: number): string
	if y < 0 then
		return "Gate Year " .. tostring(y)
	end
	return "Gate Year " .. tostring(y)
end

return {
	id = "BitLeveling",
	-- a fan work: the Robux store stays off (Config.store.sellInFanPacks)
	fanWork = true,

	meta = {
		title = "BitLeveling",
		tagline = "The Gates opened. The world changed. This is one life in it.",
		about = "Be born before the Gates or under them. Grow up, maybe awaken, maybe not. Raid, work, run, hide, rebuild. The world has its own story, and you are not its hero. You are someone who was there.",
		currency = "million won",
		lanternName = "Hunter Record",
		ledgerName = "The Association Archive",
		glowName = "Mana",
		premiumName = "Crystals",
		districtWord = "City",
		actionsPerYear = 4,
		socialPerYear = 3,
		adultAge = 18,
		birthHint = "Where you're born, and when, is up to the dice. Whether you ever awaken is up to the world.",
		releaseVerb = "File it",
		releaseToast = "The record goes into the Association Archive.",
		dailyTitle = "Today's Gate report",
		arrivalName = "city",
		emptyLedger = "No records yet. Every life that ends is filed here, Hunter or not.",
		maxLogEntries = 400,
	},

	-- Gate Year 0 = the first Gates (canon: about ten years before the story begins)
	calendar = {
		startYear = -14,
		startJitter = 2,
		rollEra = true,
		label = gateYear,
		eras = {
			{
				id = "before",
				name = "Before the Gates",
				years = "Born 24 years before the first Gates",
				year = -24,
				jitter = 2,
				weight = 2,
				desc = "You grow up in an ordinary world. You're a grown adult with a job when the sky opens. You can be one of the very first Hunters, or one of the first people to learn what a Dungeon Break is.",
				has = { "An ordinary childhood", "The first Gates when you're grown", "The first awakenings" },
				opening = { "The world is ordinary.", "Nobody has ever heard the word Gate.", "You are born." },
			},
			{
				id = "first_gen",
				name = "The First Generation",
				years = "Born 14 years before the first Gates",
				year = -14,
				jitter = 2,
				weight = 4,
				desc = "The same generation as the story's own Hunters. You're a teenager when the Gates come, in your twenties when the world's story begins, and you live through all of it.",
				has = { "The Gates when you're a teenager", "Awakening while it's new", "The whole canon story as an adult" },
				opening = { "The world is ordinary, for now.", "In fourteen years the sky will open.", "You are born." },
			},
			{
				id = "under",
				name = "Born under the Gates",
				years = "Born 2 years after the first Gates",
				year = 2,
				jitter = 2,
				weight = 2,
				desc = "Gates are something that has always been. Hunters are on the news every night. You're a child through the story's years, and what happens after depends on how the story ends.",
				has = { "A childhood with Gates in it", "The Hunter world as normal life", "The ending, as a child" },
				opening = { "The Gates have been open for two years.", "Your parents still flinch at sirens.", "You are born." },
			},
		},
	},

	-- THE SEVEN STATS (generic life-sim stats; the System's stat window is Jinwoo's alone)
	stats = {
		health = { id = "vitality", name = "Vitality", short = "VIT", color = { 214, 96, 88 }, desc = "Your body. At zero, you die. Awakening makes a body much harder to break: the higher your rank, the more it holds." },
		fight = { id = "strength", name = "Strength", short = "STR", color = { 232, 142, 70 }, desc = "How hard you hit. Your power in every fight, and how far a Hunter's mana takes it." },
		speed = { id = "agility", name = "Agility", short = "AGI", color = { 96, 206, 196 }, desc = "How fast you move: the clashes you can afford to lose in a fight, and who strikes first." },
		work = { id = "intelligence", name = "Intelligence", short = "INT", color = { 120, 170, 226 }, desc = "Study, skill and work. For a Mage, how well mana answers." },
		charm = { id = "charisma", name = "Charisma", short = "CHA", color = { 226, 126, 178 }, desc = "How people take to you. Raid parties follow a voice they trust." },
		luck = { id = "luck", name = "Luck", short = "LCK", color = { 136, 204, 110 }, desc = "Dealt at birth, hard to change. Tilts every coin, and leans an awakening a little higher.", birth = { 1, 22 } },
		will = { id = "willpower", name = "Willpower", short = "WIL", color = { 168, 120, 222 }, desc = "How much fear your mind can carry. Hunters freeze in front of things that are stronger than them; the strong-willed freeze less." },
		mood = { name = "Composure" },
	},

	fighting = {
		fight = { name = "Strike" },
		speed = { name = "Outmaneuver" },
		work = { name = "Read the fight" },
		charm = { name = "Rally" },
	},

	world = {
		sides = {
			{ id = "central", name = "Central", short = "Central", desc = "Near the guild towers and the Association branch. Patrols, sirens that come fast, and rent that hurts.", costMult = 1.8, payMult = 1.2, danger = 0.6, hazardChance = 0.1, evictOnDebt = true, evictGrace = 1, color = { 180, 210, 255 } },
			{ id = "outer", name = "Outer Districts", short = "Outer", desc = "Old apartment blocks, factories and night markets. Cheaper, louder, and further from help.", costMult = 0.7, payMult = 0.95, danger = 1, hazardChance = 0.24, wear = 1, color = { 160, 150, 170 } },
		},
		-- every city: its country (who answers its Gates), where Gates open there, and how
		-- many Hunters it has. placeNames are real streets; incidents there are this game's own.
		districts = {
			{
				id = "seoul_gangnam", name = "Seoul · Gangnam", city = "Seoul", country = "korea",
				desc = "Glass towers, guild headquarters and the most expensive Gate insurance in the country.",
				wealth = 1.5, danger = 0.8, cost = 34, charterCost = 900, charterShare = 0.4, population = 1.2, hunters = 1.4, gates = 1,
				places = { street = 4, plaza = 2, station = 3, parking = 2, construction = 1, park = 1, riverside = 1 },
				placeNames = {
					street = { "Teheran-ro", "the crossing outside Gangnam Station", "Seolleung-ro", "a side street off Apgujeong-ro" },
					plaza = { "the plaza in front of COEX", "a shopping-centre forecourt in Samseong" },
					station = { "Gangnam Station's underground mall", "Seolleung Station", "Samseong Station's exit 5" },
					parking = { "a parking garage under an office tower", "a hotel car park in Yeoksam" },
					construction = { "a tower site in Samseong" },
					park = { "Seonjeongneung's grounds" },
					riverside = { "the Han River bank at Jamwon" },
				},
			},
			{
				id = "seoul_mapo", name = "Seoul · Mapo", city = "Seoul", country = "korea",
				desc = "Universities, live music, street food, and Gates in alleys too narrow for an Association truck.",
				wealth = 1.1, danger = 1, cost = 24, charterCost = 600, charterShare = 0.3, population = 1.1, hunters = 1.1, gates = 1,
				places = { street = 4, residential = 3, station = 2, park = 1, riverside = 2, parking = 1 },
				placeNames = {
					street = { "Hongdae's main street", "a lane behind Hapjeong", "Yeonnam-dong's cafe street" },
					residential = { "an apartment complex in Mangwon", "the villas behind Sinchon" },
					station = { "Hongik University Station", "Hapjeong Station's transfer hall" },
					park = { "the Gyeongui Line Forest Park" },
					riverside = { "Mangwon Hangang Park", "the riverbank under Seogang Bridge" },
					parking = { "a market car park in Mangwon" },
				},
			},
			{
				id = "seoul_guro", name = "Seoul · Guro", city = "Seoul", country = "korea",
				desc = "Factories turned tech parks, cheap rooms, and a lot of low-rank Hunters who live close to the work.",
				wealth = 0.85, danger = 1.2, cost = 16, charterCost = 420, charterShare = 0.25, population = 1, hunters = 0.9, gates = 1.1,
				places = { industrial = 4, residential = 3, street = 2, station = 1, construction = 2, parking = 1 },
				placeNames = {
					industrial = { "the Guro Digital Complex", "a warehouse yard in Gasan", "a printing plant in Guro-dong" },
					residential = { "an old apartment block in Garibong", "a row of rooftop rooms in Guro-dong" },
					street = { "the market street by Guro Station" },
					station = { "Guro Station" },
					construction = { "a redevelopment site in Garibong" },
					parking = { "a delivery depot lot" },
				},
			},
			{
				id = "incheon", name = "Incheon", city = "Incheon", country = "korea",
				desc = "The airport, the port and the container yards. Gates here have opened inside customs.",
				wealth = 1, danger = 1.1, cost = 18, charterCost = 480, charterShare = 0.25, population = 0.9, hunters = 0.8, gates = 1,
				places = { industrial = 3, coast = 2, street = 2, residential = 2, parking = 2 },
				placeNames = {
					industrial = { "the container terminal at Incheon port", "a cold-storage yard in Namdong" },
					coast = { "the mudflats past Songdo" },
					street = { "Chinatown's main gate street", "a shopping street in Bupyeong" },
					residential = { "a new-build complex in Songdo" },
					parking = { "a long-stay car park near the airport" },
				},
			},
			{
				id = "busan", name = "Busan", city = "Busan", country = "korea",
				desc = "The port city in the south-east. Beaches, fish markets, hills of houses, and its own guilds.",
				wealth = 1, danger = 1, cost = 18, charterCost = 480, charterShare = 0.28, population = 1, hunters = 0.85, gates = 1,
				places = { street = 3, coast = 2, residential = 3, industrial = 2, mountain = 1 },
				placeNames = {
					street = { "Seomyeon's crossroads", "the market lanes at Jagalchi" },
					coast = { "Haeundae beach", "the breakwater at Gwangalli" },
					residential = { "the hillside houses of Gamcheon" },
					industrial = { "the shipyards at Yeongdo" },
					mountain = { "a trail on Geumjeongsan" },
				},
			},
			{
				id = "gwangju", name = "Gwangju (Honam)", city = "Gwangju", country = "korea",
				desc = "The south-west's big city. Honam's Hunters answer to the Fame Guild as much as the Association.",
				wealth = 0.95, danger = 1, cost = 15, charterCost = 400, charterShare = 0.25, population = 0.8, hunters = 0.9, gates = 1,
				places = { street = 2, residential = 3, farmland = 2, mountain = 2, industrial = 1 },
				placeNames = {
					street = { "Geumnam-ro", "the arcade at Chungjang-ro" },
					residential = { "an apartment block in Sangmu" },
					farmland = { "rice fields outside the city" },
					mountain = { "the slopes of Mudeungsan" },
					industrial = { "an auto parts plant in Hanam" },
				},
			},
			{
				id = "daegu", name = "Daegu", city = "Daegu", country = "korea",
				desc = "Inland, hot in summer, surrounded by hills. Gates in the mountains are found late.",
				wealth = 0.95, danger = 1.05, cost = 15, charterCost = 400, charterShare = 0.25, population = 0.85, hunters = 0.8, gates = 1.05,
				places = { street = 2, residential = 3, mountain = 3, industrial = 2 },
				placeNames = {
					street = { "Dongseong-ro's shopping street", "the herbal medicine market" },
					residential = { "an apartment estate in Suseong" },
					mountain = { "a trail on Palgongsan", "the forest behind Apsan" },
					industrial = { "a textile works in Seo-gu" },
				},
			},
			{
				id = "jeju", name = "Jeju Island", city = "Jeju", country = "korea",
				desc = "The island. Volcanic stone, tangerine farms and tourists. In canon, an S-rank Gate here broke about four years before the story began, and the island was abandoned.",
				wealth = 1, danger = 1, cost = 16, charterCost = 420, charterShare = 0.25, population = 0.6, hunters = 0.6, gates = 0.9, canLose = true,
				places = { coast = 3, farmland = 2, mountain = 2, street = 1 },
				placeNames = {
					coast = { "the black-sand beach at Samyang", "the cliffs at Jusangjeolli" },
					farmland = { "a tangerine farm near Seogwipo" },
					mountain = { "the lower trails of Hallasan" },
					street = { "Jeju City's old market" },
				},
			},
			{
				id = "tokyo", name = "Tokyo", city = "Tokyo", country = "japan",
				desc = "Japan's capital, and in canon the city an S-rank Dungeon Break nearly ended.",
				wealth = 1.3, danger = 1, cost = 28, charterCost = 800, charterShare = 0.35, population = 1.3, hunters = 1, gates = 1,
				places = { street = 4, station = 3, plaza = 2, residential = 2, riverside = 1 },
				placeNames = {
					street = { "a street behind Shinjuku Station", "Shibuya's scramble crossing", "a back lane in Shimokitazawa" },
					station = { "Shinjuku Station's west exit", "Ikebukuro Station" },
					plaza = { "the plaza under the Tocho towers" },
					residential = { "a danchi estate in Nerima" },
					riverside = { "the Sumida riverbank" },
				},
			},
			{
				id = "us_west", name = "California Coast", city = "Los Angeles", country = "usa",
				desc = "The US West Coast, where canon's first S-rank Gate opened about eight years before the story.",
				wealth = 1.3, danger = 1, cost = 30, charterCost = 850, charterShare = 0.35, population = 1, hunters = 1.2, gates = 1,
				places = { street = 3, parking = 3, coast = 2, residential = 2, industrial = 2 },
				placeNames = {
					street = { "a boulevard downtown", "a strip-mall street in the Valley" },
					parking = { "a stadium parking lot", "a mall lot off the freeway" },
					coast = { "the beach at Santa Monica" },
					residential = { "a suburb in the hills" },
					industrial = { "a rail yard by the river" },
				},
			},
			{
				id = "new_york", name = "New York", city = "New York", country = "usa",
				desc = "Skyscrapers, subway tunnels and guilds with more money than some countries.",
				wealth = 1.5, danger = 0.9, cost = 34, charterCost = 950, charterShare = 0.4, population = 1.4, hunters = 1.3, gates = 1,
				places = { street = 4, station = 3, plaza = 2, park = 2, riverside = 1 },
				placeNames = {
					street = { "an avenue in Midtown", "a block in Brooklyn" },
					station = { "a subway platform under Union Square" },
					plaza = { "a plaza in the Financial District" },
					park = { "a meadow in Central Park" },
					riverside = { "the Hudson riverfront" },
				},
			},
			{
				id = "beijing", name = "Beijing", city = "Beijing", country = "china",
				desc = "China's capital. Its Hunters answer to the state, and the state answers fast.",
				wealth = 1.1, danger = 0.95, cost = 20, charterCost = 600, charterShare = 0.3, population = 1.3, hunters = 1.1, gates = 1,
				places = { street = 3, plaza = 2, residential = 3, industrial = 2, park = 1 },
				placeNames = {
					street = { "a hutong lane near Gulou", "Wangfujing's shopping street" },
					plaza = { "a square outside a shopping centre in Chaoyang" },
					residential = { "a high-rise estate in Haidian" },
					industrial = { "a factory zone in Daxing" },
					park = { "a lake in Chaoyang Park" },
				},
			},
			{
				id = "mumbai", name = "Mumbai", city = "Mumbai", country = "india",
				desc = "The most crowded city on the list. A Gate here is never far from people.",
				wealth = 0.9, danger = 1.15, cost = 14, charterCost = 380, charterShare = 0.25, population = 1.5, hunters = 0.85, gates = 1.05,
				places = { street = 4, station = 3, residential = 3, coast = 1, industrial = 1 },
				placeNames = {
					street = { "a market street in Dadar", "a lane off Colaba Causeway" },
					station = { "a suburban rail platform at Andheri" },
					residential = { "a chawl block in Lower Parel" },
					coast = { "Juhu beach" },
					industrial = { "the docks at Mazagaon" },
				},
			},
		},
	},

	origins = {
		{ id = "ordinary", name = "Ordinary Family", desc = "Two working parents, a small apartment, and dinner at the same time every night.", birth = "You were born to two working parents in {zone}.", money = 4, family = { mother = true, father = true, siblings = { 0, 2 } }, glowCost = 0 },
		{ id = "single", name = "Single Parent", desc = "One parent working two jobs, and a lot of evenings on your own.", birth = "You were born in {zone}. It was always the two of you.", money = 1, side = "outer", stats = { willpower = 3 }, family = { mother = true, siblings = { 0, 1 } }, glowCost = 0 },
		{ id = "shop", name = "Shopkeepers' Kid", desc = "Your family runs a corner restaurant. You grow up in the back of it.", birth = "You were born above your parents' restaurant in {zone}.", money = 6, stats = { charisma = 3 }, family = { mother = true, father = true, siblings = { 0, 2 } }, glowCost = 0 },
		{ id = "military", name = "Military Family", desc = "A parent in uniform, moves every few years, and early mornings.", birth = "You were born on a base outside {district}. Your father was on duty.", money = 5, stats = { strength = 2, willpower = 2 }, family = { mother = true, father = true, siblings = { 0, 1 } }, glowCost = 1 },
		{ id = "doctor", name = "Doctors' Child", desc = "Two parents at the hospital, and a house full of medical books.", birth = "You were born at the hospital where both your parents work, in {zone}.", money = 9, side = "central", stats = { intelligence = 4 }, family = { mother = true, father = true, siblings = { 0, 1 } }, glowCost = 1 },
		{ id = "wealthy", name = "Old Money", desc = "A family company, a driver, and a grandfather who decides everything. (Original: not any canon family.)", birth = "You were born into money in {zone}. The family company sent flowers.", money = 40, side = "central", stats = { charisma = 2, intelligence = 2 }, family = { mother = true, father = true, siblings = { 0, 2 } }, glowCost = 3 },
		{ id = "grandparents", name = "Raised by Grandparents", desc = "Your parents are gone; your grandmother raises you on a pension and stubbornness.", birth = "You were raised by your grandmother in {zone}.", money = 1, side = "outer", stats = { willpower = 3, charisma = 1 }, family = { siblings = { 0, 1 } }, glowCost = 1 },
	},

	-- what a life is: unawakened, or a Hunter of a rank. The rank you measure at is the rank
	-- you keep (canon); `hunterRank` is read by Engine/HunterWorld, `wage` scales Hunter pay,
	-- capBonus is how far training can take each stat (ORIGINAL numbers).
	forms = {
		human = { name = "Unawakened", desc = "No mana, no rank. Most of the world. A Gate is a disaster you watch on the news, or run from." },
		hunter_e = { name = "E-rank Hunter", desc = "Awakened, barely. Stronger and harder to kill than you were, and weaker than almost every other Hunter. The work is low-rank raids and mining crews.", hunterRank = 1, wage = 1, capBonus = { all = 25 }, clash = { base = 1 }, headsFloor = 10, color = { 150, 160, 170 } },
		hunter_d = { name = "D-rank Hunter", desc = "A working Hunter. D-rank Gates are yours; above that, you're support.", hunterRank = 2, wage = 1.7, capBonus = { all = 55 }, clash = { base = 3, coinPower = 1 }, headsFloor = 12, color = { 120, 200, 150 } },
		hunter_c = { name = "C-rank Hunter", desc = "Guilds call you by name. You lead low-rank raids and fill out the ranks of big ones.", hunterRank = 3, wage = 3.2, capBonus = { all = 95 }, clash = { base = 6, coinPower = 1 }, headsFloor = 14, color = { 110, 170, 255 } },
		hunter_b = { name = "B-rank Hunter", desc = "A real asset. A guild builds strike teams around Hunters like you.", hunterRank = 4, wage = 6.5, capBonus = { all = 150 }, clash = { base = 10, coinPower = 2 }, headsFloor = 16, color = { 190, 120, 255 } },
		hunter_a = { name = "A-rank Hunter", desc = "One of a few hundred in the country. Guild officer, raid leader, someone the Association phones first.", hunterRank = 5, wage = 15, capBonus = { all = 230 }, clash = { base = 15, coinPower = 3 }, headsFloor = 18, color = { 255, 170, 70 } },
		hunter_s = { name = "S-rank Hunter", desc = "A national asset. Korea, in canon, recognised ten in the story's whole history. Guilds bid in billions; the news follows you home.", hunterRank = 6, wage = 60, capBonus = { all = 380 }, clash = { base = 24, coinPower = 5, coins = 1 }, headsFloor = 22, color = { 255, 90, 90 } },
	},

	gear = { slots = { "weapon", "armor", "charm" }, items = {} },

	theme = {
		accent = { 92, 160, 255 },
		crimson = { 214, 56, 64 },
		money = { 120, 210, 255 },
		strange = { 150, 120, 255 },
	},
	backdrop = "city",

	-- the 3D sets fights and cutscenes happen in (client/UI/Stage.luau)
	places = {
		{
			id = "gate_street",
			time = "dusk",
			ground = { color = { 70, 72, 78 }, material = "asphalt" },
			skyline = true,
			parts = {
				{ "row", "building", from = -40, to = 40, step = 10, z = -16, jitter = 2 },
				{ "row", "lamp", from = -20, to = 20, step = 10, z = -4 },
				{ "glow", 0, 4, 14, { 80, 150, 255 } },
				{ "cyl", 0, 6, 16, 9, 0.6, { 60, 130, 255 }, "neon" },
			},
			words = { "gate", "street", "crossing", "dungeon break" },
			fights = "street",
		},
		{
			id = "gate_cave",
			time = "inside",
			ground = { color = { 60, 56, 52 }, material = "slate" },
			parts = {
				{ "row", "pillar", from = -24, to = 24, step = 8, z = -10 },
				{ "glow", -6, 2, -6, { 120, 200, 255 } },
				{ "glow", 6, 2, -8, { 120, 200, 255 } },
				{ "ball", 0, 1, -12, 3, { 90, 170, 255 }, "neon" },
			},
			words = { "raid", "dungeon", "cave", "crystal", "boss room" },
			fights = "street",
		},
		{
			id = "red_gate",
			time = "night",
			ground = { color = { 210, 220, 232 }, material = "ice" },
			parts = {
				{ "row", "tree", from = -36, to = 36, step = 9, z = -14, jitter = 3 },
				{ "glow", 0, 10, -20, { 255, 60, 60 } },
			},
			words = { "red gate", "snow", "ice" },
			fights = "street",
		},
	},

	-- the seven fight statuses, renamed for mana and monsters
	vfx = {
		statuses = {
			burn = { name = "Mana Burn", color = { 255, 140, 60 } },
			bleed = { name = "Bleed", color = { 214, 40, 52 } },
			tremor = { name = "Stagger", color = { 220, 190, 120 } },
			rupture = { name = "Armor Break", color = { 120, 220, 255 } },
			sinking = { name = "Fear", color = { 120, 90, 220 } },
			poise = { name = "Focus", color = { 160, 230, 255 } },
			charge = { name = "Mana Charge", color = { 90, 160, 255 } },
		},
	},

	intro = {
		lines = {
			"About ten years before the story everyone knows, the sky opened.",
			"Gates. Doors to somewhere else, with monsters behind them.",
			"Then people began to wake up with power nobody could explain.",
			"The world calls them Hunters. You might become one. You might not.",
			"You're about to be born.",
		},
	},

	-- two worlds, picked on the start screen (and they change how the Gates behave:
	-- pack.hunterWorld.modes below). Not just numbers: the High-Danger World's Gates open
	-- more often in streets, its Association is stretched thinner, its breaks spread further.
	difficulties = {
		order = { "normal", "crisis" },
		default = "normal",
		normal = {
			name = "Normal World",
			desc = "The world as the story tells it. Gates are dangerous and breaks happen, but the Association usually gets there, and a careful life has room to grow.",
			lethality = 1, foeBase = 0, hazard = 1, score = 1, color = { 92, 160, 255 },
		},
		crisis = {
			name = "High-Danger World",
			desc = "An unstable world. More Gates open in the streets, more of them break, the Association and the guilds are always stretched, and help comes late or not at all. Bad timing and a low rank can end a life. Scores count for more.",
			lethality = 1.3, foeBase = 1, hazard = 1.35, hardness = 1.25, score = 1.6, color = { 230, 70, 70 },
		},
	},

	tuning = {
		lethality = 1.2,
		youthLethality = 1,
		childHazard = 0.4,
		hardness = { fromAge = 16, cardBase = 0, dangerBase = 1, dangerCoins = 0, match = { from = 70, every = 50, max = 3 }, dangerWeight = 1.3, dreadWeight = 2, dread = { fromAge = 18, chance = 0.08, byAge = { { from = 24, chance = 0.12 }, { from = 50, chance = 0.08 } }, focusMult = 0.5 } },
		clash = { coinsEvery = 30, maxCoins = 4, extraCoinsAt = { 220, 380 }, baseEvery = 12, powerEvery = 45, foeGrowth = { fromAge = 18, everyYears = 10, maxBase = 3 }, fightBase = 0 },
		-- what a harder raid pays on top (million won): tiers come from the strongest clash (base + coins)
		expeditionPay = {
			tiers = { 12, 18, 26, 36 },
			[2] = { money = 1.2, stats = 1.15, renown = 1.2 },
			[3] = { money = 1.4, stats = 1.3, renown = 1.5, bonus = { money = { 4, 12 } } },
			[4] = { money = 1.6, stats = 1.5, renown = 2, bonus = { money = { 20, 60 } } },
			[5] = { money = 1.8, stats = 1.8, renown = 2.5, bonus = { money = { 80, 240 } } },
		},
		eventsPerYear = { { upTo = 0, n = 0 }, { upTo = 3, n = 1 }, { upTo = 12, n = 1.2 }, { upTo = 59, n = 1.3 }, { upTo = 999, n = 1.1 } },
	},

	names = {
		first = {
			"Minjun", "Seojun", "Doyun", "Jiho", "Hajun", "Eunwoo", "Siwoo", "Junseo", "Taeyang", "Hyunwoo", "Dongha", "Jaewon", "Sungmin", "Kyungho",
			"Seoyeon", "Jiwoo", "Haeun", "Sua", "Yuna", "Chaewon", "Jiyoon", "Minseo", "Dahyun", "Soyeon", "Hayoung", "Eunji", "Yerin", "Nari",
			"Haruto", "Ren", "Yui", "Aoi", "Mei", "Daniel", "Grace", "Marcus", "Elena", "Wei", "Lin", "Arjun", "Priya", "Sofia",
		},
		last = {
			"Kim", "Lee", "Park", "Choi", "Jung", "Kang", "Cho", "Yoon", "Jang", "Lim", "Han", "Oh", "Seo", "Shin", "Kwon", "Hwang", "Ahn", "Song", "Jeon", "Hong",
			"Yamada", "Sato", "Tanaka", "Walker", "Reyes", "Chen", "Wang", "Sharma", "Patel",
		},
	},

	-- the ending lines a Hunter Record can close on
	deathCauses = {
		wounds = "Died of their wounds",
		woundsFrom = "Died of wounds from %s",
		oldAge = { "Died in their sleep, an old person", "Died of old age, with family close", "Died peacefully, years after the last Gate they saw" },
	},

	-- (v0.19) everyone you meet, what you can do with them, and the party's own cards
	people = Interactions.people,
	events = Interactions.cards,

	pack = {
		-- (v0.19) the party (Engine/Party.luau) and the game's named NPCs (Roster.luau)
		party = Interactions.party,
		roster = Roster,
		-- class skills and birth talents (Skills.luau): talents lean to Hunter classes
		traits = Skills.traits,
		talents = Skills.talents,
		affinities = Skills.affinities,
		affinityResonance = 3,
		affinityWord = "classes",
		affinityTab = "Class",
		affinityLabel = "Class",
		traitPicks = 0, -- no traits are picked at birth: skills are learned, talents are dealt

		-- the archive of lore (kept across lives): canon facts marked CANON, this game's own marked ORIGINAL
		codex = {
			categories = {
				{ id = "gates", name = "Gates and Dungeons" },
				{ id = "hunters", name = "Hunters" },
				{ id = "orgs", name = "Associations and Guilds" },
				{ id = "history", name = "What Happened" },
				{ id = "beyond", name = "Beyond the Gates" },
				{ id = "bestiary", name = "Bestiary" },
				{ id = "game", name = "How This World Works (game)" },
			},
			entries = require(script.Parent:WaitForChild("Lore")),
		},

		-- max Vitality by rank (an awakened body holds far more)
		vitalMax = {
			base = 100,
			perStrength = 0.25,
			strengthFrom = 60,
			forms = { hunter_e = 25, hunter_d = 60, hunter_c = 120, hunter_b = 210, hunter_a = 360, hunter_s = 650 },
		},
		-- ── THE GATES (Engine/HunterWorld.luau) ──────────────────────────────
		hunterWorld = {
			firstYear = 0,
			-- the 40 endings a life can be filed under (Fates.luau; Engine/HunterWorld.fateOf)
			fates = require(script.Parent:WaitForChild("Fates")),
			-- canon: an uncleared Gate breaks; the figure usually cited is about seven days,
			-- but canon's Tokyo Gate broke in about three. Seven is typical here, not fixed
			-- (ORIGINAL: the spread is this game's).
			breakDays = 7,
			defaultMode = "normal",
			rewriteForm = "human",
			minCardAge = 13, -- nobody younger is put in an incident card (Roblox: children are never shown hurt)
			headlineRank = 4,
			modes = {
				normal = { name = "Normal World" },
				crisis = { name = "High-Danger World" },
			},
			-- how busy the Gates are as the story goes on (ORIGINAL numbers on canon's arc:
			-- the first years, the long middle, the story's escalation, the war)
			eras = {
				{ from = 0, mult = 0.55, high = 0 },
				{ from = 1, mult = 0.8, high = 0 },
				{ from = 3, mult = 1, high = 0.5 },
				{ from = 8, mult = 1.05, high = 1.5 },
				{ from = 10, mult = 1.15, high = 3 },
				{ from = 11, mult = 1.3, high = 6 },
				{ from = 12, mult = 1.7, high = 12 },
				{ from = 13, mult = 1.15, high = 3 },
			},
			places = {
				street = { name = "a street", urban = true, pop = 0.9, vis = 1 },
				plaza = { name = "a plaza", urban = true, pop = 1, vis = 1 },
				parking = { name = "a parking lot", urban = true, pop = 0.6, vis = 0.9 },
				station = { name = "a subway station", urban = true, pop = 1, vis = 1 },
				industrial = { name = "an industrial park", urban = true, pop = 0.35, vis = 0.6 },
				residential = { name = "a residential block", urban = true, pop = 0.85, vis = 0.95 },
				park = { name = "a park", urban = true, pop = 0.5, vis = 0.8 },
				construction = { name = "a construction site", urban = true, pop = 0.3, vis = 0.7 },
				riverside = { name = "the riverside", urban = true, pop = 0.45, vis = 0.75 },
				forest = { name = "a forest", urban = false, pop = 0.05, vis = 0.2 },
				mountain = { name = "a mountainside", urban = false, pop = 0.03, vis = 0.15 },
				farmland = { name = "farmland", urban = false, pop = 0.12, vis = 0.45 },
				coast = { name = "a stretch of coast", urban = false, pop = 0.15, vis = 0.4 },
			},
			-- inside: environments and monsters (ORIGINAL pools; goblins, orcs, high orcs and
			-- ice bears appear in canon Gates; Jeju's ants and Tokyo's giants stay with their
			-- canon incidents; steel-fanged lycans were the System's, so they're not here).
			-- The families are the bestiary's (Hunter/Bestiary.luau): ice elves, lizardmen,
			-- naga, golems, wyverns, dragon-kin, demons and undead-like knights are canon TYPES;
			-- kobolds, dwarves, forest and dark elves, treants and the rest are this game's own.
			envs = {
				"a limestone cave", "a dark forest under a second sky", "a sunken ruin", "a frozen cavern", "a swamp that smells of copper",
				"a maze of black stone", "a crystal-lined mine", "a desert of red sand", "a fortress of rotted timber",
				"a snowfield under a white sun", "a flooded temple", "a volcanic cavern", "a crypt under a dead kingdom",
				"a rune-carved hall under a mountain", "a forest of mushrooms taller than houses", "a castle of black iron",
				"a labyrinth that moves when nobody watches", "a plain of floating rocks", "a jungle under a green sky",
			},
			monsters = {
				E = { "goblins", "goblins and their shaman", "kobold miners", "giant rats", "cave bats", "mana slimes", "cave crawlers", "skeleton soldiers", "screaming mandrakes", "a mud golem", "mana wisps" },
				D = { "hobgoblins", "goblin wolf riders", "kobolds and their foreman", "armoured beetles", "giant spiders", "dire wolves", "dwarf miners", "lizardman skirmishers", "skeleton archers", "acid slimes", "razorback boars", "a mimic in a treasure room" },
				C = { "orcs", "an orc war band with a shaman", "lizardmen", "naga", "cave trolls", "forest elf rangers", "a dwarf shield wall", "blade mantises", "sand scorpions", "harpies", "fire elementals", "gaunt ghouls", "centaur skirmishers" },
				B = { "ice bears", "ogres", "high orcs", "naga sirens", "dark elf stalkers", "frost trolls", "iron golems", "wraiths", "treants", "kraken spawn", "minotaur raiders", "a dwarf runesmith's hall", "two-headed hounds" },
				A = { "high orcs and a shaman", "stone golems", "wyverns", "ice elf hunters", "a dwarf forge-lord's hall", "dark elf sorceresses", "minotaurs", "grave knights", "demon knights", "a basilisk", "thunder tigers", "centaur lancers" },
				S = { "a horde led by something that spoke", "dragon-kin", "something nobody had a name for", "a lich and its grave knights", "a demon noble's host", "an abyssal serpent", "a three-headed warhound", "a colossus" },
			},
			countries = {
				korea = {
					name = "Korea", association = "the Korean Hunters Association", capacity = 1,
					guilds = { "a mid-size guild", "a small local guild", "an Association-assembled public raid", "a guild's second strike team" },
					topGuilds = { "the Hunters Guild", "the White Tiger Guild", "the Fame Guild", "a coalition of the major guilds" },
				},
				japan = {
					name = "Japan", association = "the Japanese Hunters Association", capacity = 0.9,
					guilds = { "a Tokyo guild", "an Association raid team", "a regional guild" },
					topGuilds = { "the Draw Sword Guild", "Japan's top guilds" },
				},
				usa = {
					name = "the United States", association = "the Hunter Bureau", capacity = 1.25,
					guilds = { "a city guild", "a Bureau-contracted raid team", "a private guild" },
					topGuilds = { "the Scavenger Guild", "one of the big American guilds" },
				},
				china = {
					name = "China", association = "China's Hunter authorities", capacity = 1.05,
					guilds = { "a state raid team", "a provincial guild" },
					topGuilds = { "the state's elite Hunters" },
				},
				india = {
					name = "India", association = "India's Hunter Association", capacity = 0.85,
					guilds = { "a Mumbai guild", "an Association raid team" },
					topGuilds = { "India's strongest Hunters" },
				},
			},
			cards = { cityGate = "hw_city_", raid = "hw_raid_", breakOut = "hw_break_", red = "hw_red_", double = "hw_double_" },

			-- AWAKENING (ORIGINAL odds: canon gives none, only that it seems random, can happen at
			-- any age, and that rank is normally fixed for life; reawakening is extremely rare)
			awakening = {
				card = "aw_wake_",
				reawakenCard = "aw_reawaken_",
				minAge = 12,
				maxAge = 44,
				byAge = { { from = 12, p = 0.02 }, { from = 15, p = 0.05 }, { from = 19, p = 0.045 }, { from = 26, p = 0.025 }, { from = 34, p = 0.012 } },
				firstWave = 2.2,
				firstWaveYears = 1,
				rankWeights = { 41, 28, 17, 9, 4.2, 0.8 },
				reawaken = 0.0012,
				-- canon counts Korea's S-ranks: the 10th (Gate Year 10) was the first since the
				-- 9th (about Year 8). A Korean life measures A at most until the story's start
				-- has passed; after that, an S-rank would be Korea's 11th or later.
				rankCaps = { { country = "korea", untilYear = 10, max = 5 } },
				reawakenMaxAge = 50,
				-- the Hunter classes the manhwa uses (Fighter, Mage, Assassin, Tanker, Ranger,
				-- Healer); the weights and the stat leanings are this game's
				classes = {
					{ id = "fighter", name = "Fighter", weight = 30, stats = { strength = 4, vitality = 2 } },
					{ id = "mage", name = "Mage", weight = 18, stats = { intelligence = 5, willpower = 1 } },
					{ id = "assassin", name = "Assassin", weight = 14, stats = { agility = 5, luck = 1 } },
					{ id = "tanker", name = "Tanker", weight = 14, stats = { vitality = 6, willpower = 1 } },
					{ id = "ranger", name = "Ranger", weight = 12, stats = { agility = 3, intelligence = 2 } },
					{ id = "healer", name = "Healer", weight = 12, stats = { willpower = 3, charisma = 3 } },
				},
			},

			-- THE CANON TIMELINE (the public events of the manhwa, by Gate Year; years are
			-- relative and approximate where canon is: see docs/BITLEVELING_CANON.md). Public
			-- ones reach everyone on the news; people who are there live them (firsthand).
			-- Secret events (the Double Dungeon's System, the Architect, the Monarchs' plots)
			-- are never reported: nobody in the world could know them.
			canon = {
				{ id = "first_gates", year = 0, minAge = 5, headline = "Gates are opening all over the world: tears in the air with something on the other side. Nobody knows what they are.", tone = "strange", firsthand = "cn_first_gates" },
				{ id = "awakenings", year = 0, untilYear = 1, headline = "People are waking up with strength nobody can explain. The papers have started calling them Hunters.", tone = "strange" },
				{ id = "associations", year = 1, untilYear = 2, headline = "Governments are founding Hunter Associations to license Hunters, measure Gates and sell the rights to raid them.", country = "korea", abroad = "Governments are founding Hunter Associations to license Hunters and measure Gates.", tone = "plain" },
				{ id = "kamish", year = 2, headline = "The first S-rank Gate has broken on the US West Coast. Something the news can only call a dragon. Over a hundred Hunters fought it; a handful survived.", tone = "danger", firsthand = "cn_kamish", district = "us_west", effect = { damage = { us_west = 60 } } },
				{ id = "national_level", year = 2, untilYear = 3, headline = "The survivors of the dragon are being called National Level Hunters, each worth as much as an army: America's Thomas Andre and Christopher Reed, China's Liu Zhigang, India's Siddharth Bachchan, and one more.", tone = "plain" },
				{ id = "jeju_falls", year = 6, headline = "S-rank Gate on Jeju Island: the raid failed and the Gate broke. Monsters, ants the size of cars, have overrun the island. Jeju is being evacuated.", country = "korea", abroad = "An S-rank Dungeon Break has overrun South Korea's Jeju Island.", tone = "danger", firsthand = "cn_jeju_falls", district = "jeju", effect = { lose = "jeju" } },
				{ id = "jeju_raid2", year = 7, headline = "Another raid on Jeju Island has failed. The island stays in the ants' hands.", country = "korea", abroad = "A second attempt to retake Jeju Island has failed.", tone = "danger" },
				{ id = "cha_haein", year = 8, headline = "The Association registers Korea's 9th S-rank Hunter: Cha Hae-In, a swordswoman, who joins the Hunters Guild.", country = "korea", tone = "good" },
				{ id = "jeju_raid3", year = 9, headline = "The third raid on Jeju Island has failed. An S-rank Hunter is among the dead.", country = "korea", abroad = "A third raid on Jeju Island has failed, at the cost of an S-rank Hunter.", tone = "danger" },
				{ id = "tenth_s", year = 10, headline = "The Association confirms Korea's 10th S-rank Hunter: Sung Jinwoo, re-evaluated after years as an E-rank once called the weakest Hunter of all mankind.", country = "korea", abroad = "South Korea has registered a 10th S-rank Hunter after a rare re-evaluation.", tone = "strange" },
				{ id = "jeju_fourth", year = 11, headline = "The fourth Jeju raid, a joint Korea-Japan operation, has killed the Ant King. Eight S-rank Hunters died, among them Japan's Goto Ryuji and Korean healer Min Byung-gu. Jeju is free.", country = "korea", abroad = "A Korea-Japan raid has retaken Jeju Island. Eight S-rank Hunters are dead.", tone = "danger", effect = { restore = "jeju" } },
				{ id = "ahjin", year = 11, headline = "Sung Jinwoo founds the Ahjin Guild, with Yoo Jinho as vice-master.", country = "korea", tone = "plain" },
				{ id = "tokyo", year = 11, headline = "An S-rank Dungeon Break in Tokyo: giants are walking through Shinjuku. Japan is asking the world for Hunters.", country = "japan", abroad = "An S-rank Dungeon Break in Tokyo: giants in the streets. Japan is asking the world for help.", tone = "danger", firsthand = "cn_tokyo", district = "tokyo", effect = { damage = { tokyo = 70 } } },
				{ id = "tokyo_saved", year = 11, headline = "Tokyo's giants are dead. One Hunter from Korea is being credited with most of it.", tone = "good" },
				{ id = "igc", year = 11, headline = "At the International Guild Conference in the United States, National Level Hunter Christopher Reed has been found dead.", tone = "danger" },
				{ id = "go_gunhee", year = 12, headline = "Go Gunhee, chairman of the Korean Hunters Association, is dead. Woo Jinchul will lead the Association.", country = "korea", abroad = "The chairman of Korea's Hunter Association has died.", tone = "plain" },
				{ id = "seoul_gate", year = 12, headline = "The largest Gate ever recorded is hanging over Seoul. It has been opening for days. The city is being evacuated.", country = "korea", abroad = "A Gate larger than any on record has appeared over Seoul.", tone = "danger", firsthand = "cn_seoul_gate", district = { "seoul_gangnam", "seoul_mapo", "seoul_guro" }, effect = { damage = { seoul_gangnam = 30, seoul_mapo = 30, seoul_guro = 30 } } },
				{ id = "war", year = 12, headline = "Gates are opening everywhere at once. Armies of monsters, and things that command them. Every Hunter on Earth has been called up.", tone = "danger", firsthand = "cn_war", effect = { flag = "monarch_war" } },
				{ id = "rewrite", year = 12, untilYear = 13, minAge = 0, public = false, firsthand = "cn_rewrite", notIf = "world_line_kept" },
			},

			-- the lines incident cards are written from ({g...} tokens; HW.tokens picks one
			-- of each, so the same kind of card reads differently every time). ORIGINAL.
			lines = {
				times = {
					"Just after the evening rush,", "At ten past two in the morning,", "In the middle of a weekday afternoon,", "On a wet Sunday morning,",
					"As the shops were closing,", "At lunchtime, with the streets full,", "Just before dawn,", "On the way home from work,",
					"During a school run,", "On a public holiday, with everyone out,",
				},
				warnings = {
					civilian = { "You have no rank and no licence. You are exactly who the cordon is for.", "You're not a Hunter. Nobody expects you to do anything but get clear." },
					below = { "The reading is well under your rank. For you, this should be routine. Should be.", "It's beneath you, on paper. Most Hunters who die, die on paper." },
					even = { "It's your rank. A fair fight, if anything in a Gate is fair.", "The reading matches your licence. This is the work you're for." },
					above = { "It reads one rank above yours. The Association's guidance is: support role only.", "The reading is above your licence. You can go. You'd be the weakest one there." },
					deadly = { "It reads two or more ranks above yours. A Hunter your rank does not survive this. The odds say so, and so does every report.", "Far beyond your rank. Even being near it is a risk. Everything you know says run." },
				},
				city = {
					scenes = {
						"the air in {gPlace} folded open: a Gate, {gRank}, hanging a foot off the ground like a hole in a photograph.",
						"a Gate opened in {gPlace}. A phone's reading put it at {gRank} before the police had even arrived.",
						"people in {gPlace} started screaming before anyone saw why. Then they saw it: a Gate, swirling, the height of a bus.",
					},
					byPlace = {
						station = { "the lights in {gPlace} flickered and a Gate opened on the platform, between a vending machine and the stairs. {gARank} reading." },
						plaza = { "a Gate opened in the middle of {gPlace}, beside the fountain. Tourists were photographing it before they understood." },
						parking = { "a Gate opened between two rows of cars in {gPlace}. The alarms on every car went off at once." },
						residential = { "a Gate opened in the courtyard of {gPlace}, under the laundry lines. The reading said {gRank}." },
						construction = { "a Gate opened in the foundation pit of {gPlace}. The workers were already running." },
						park = { "a Gate opened among the trees in {gPlace}. Birds went up all at once." },
					},
					crowd = {
						"Police are taping off the street. An Association measurement van is on its way. Most people are walking, fast, the way the drills taught them.",
						"Phones up, voices high, an officer with a megaphone. The emergency alert buzzes in every pocket at once.",
						"Shops are pulling their shutters down. Somebody's crying. Somebody else is livestreaming.",
					},
					crowdCrisis = {
						"There's no cordon yet. There aren't enough officers. The emergency alert says help is 'being dispatched'. People are running in every direction.",
						"It's the third Gate in the city this week and everyone knows the Association is stretched. Nobody waits for instructions; they just run.",
						"The emergency alert went out late. The crowd has become a crush at the crossing.",
					},
				},
				["break"] = {
					scenes = {
						"the Gate in {gPlace} broke before anyone got to it. {gMonster} came out of it into the street.",
						"sirens everywhere. A Gate in {gPlace} went unattended too long, and now {gMonster} are loose between the buildings.",
						"the ground shook, a Gate in {gPlace} split wide, and {gMonster} poured out.",
					},
					byPlace = {
						station = { "a Gate on the platforms under {gPlace} broke. {gMonster} are coming up the escalators." },
						residential = { "a Gate in the courtyard of {gPlace} broke. {gMonster} are in the stairwells." },
					},
					crowd = {
						"The emergency broadcast is on every screen: shelter in place or head away from the noise. Hunters are on their way.",
						"People are running past you. An officer is shouting directions nobody can hear.",
						"A car has been flipped across the road. You can hear Hunters' radios somewhere, but not close enough.",
					},
					crowdCrisis = {
						"No Hunters yet. The broadcast keeps repeating that teams are 'en route'. It has been repeating that for twenty minutes.",
						"The Association's response is spread over three incidents across the city. This street is not first on the list.",
						"Nobody is coming soon. The people around you seem to understand that at the same moment you do.",
					},
				},
				raid = {
					scenes = {
						"{gGuild} needs Hunters for {gARank} Gate in {gPlace}. Your phone buzzes: you're on the list.",
						"the Association posted a public raid: {gARank} Gate at {gPlace}, opened yesterday. They want licensed Hunters by morning.",
						"{gGuild} bought the raid rights to a Gate in {gPlace}, {gRank}, and they're short a few people. Their recruiter called you directly.",
					},
					crowd = {
						"Inside, the reports say: {gEnv}, and {gMonster}. Electronics die past the entrance, so the miners bring pickaxes.",
						"The briefing is short: {gEnv}, {gMonster}, the boss probably in the deepest chamber. The Gate closes about an hour after the boss dies.",
						"A healer, a tank, two mages and whoever else signs up. The collection team waits outside with crates for the mana crystals.",
					},
					crowdCrisis = {
						"The guild is sending fewer Hunters than it should; three other Gates are open this week. {gEnv}, {gMonster}.",
						"It's the fourth raid this month. Half the team is exhausted. {gEnv}, and {gMonster}.",
					},
				},
				red = {
					scenes = {
						"The raid went into {gPlace}'s Gate on an ordinary morning. Twenty minutes in, someone looked back and the entrance was gone, and the sky had turned the colour of a wound.",
						"Snow. There wasn't supposed to be snow. Behind the raid party the Gate had gone red and closed.",
					},
					crowd = {
						"Time runs wrong in here: the old reports say a day inside for every hour outside.",
						"No radio, no signal. The cold is the first thing that starts killing people.",
					},
				},
				double = {
					scenes = {
						"The boss of {gPlace}'s Gate went down easily. Too easily. Behind its throne there's a second entrance, cut into the rock, older than the dungeon around it.",
						"The raid on {gPlace}'s Gate was finished. Then someone found a passage that wasn't on any map, and at the end of it, a door.",
					},
					crowd = {
						"Someone wants to go through: undiscovered rooms mean crystals nobody has claimed. Someone else wants to call the Association. Everyone is whispering.",
						"Nobody has heard of this happening outside rumours. The air through the door is cold and very still.",
					},
				},
			},
		},
	},
}
