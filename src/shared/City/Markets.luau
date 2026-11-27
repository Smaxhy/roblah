--[[
	MARKETS AND HOMES (Engine/Market.luau). What's on a market's tables changes with the
	streets (world.streets), what the City is going through this week (worldEvent), a hard
	year (crisis), the age (world.era) and where you live (district). Prices move with them
	(markup). Buying never costs an action.

	Lore: K Corp's ampules and its District 11 (Glossary, District entries); prosthetics, and
	N Corp's Nail and Hammer hunting "impurity" in District 14; Hongyuan's rooms that grow
	with a fortune (District 8); the Great Lake (District 21); the dead branches of L Corp
	after its fall; Fixers for hire by Grade, and the Seven Association, who find people.
	Roblox Moderate: nothing to drink, smoke or gamble; violence only implied.
]]

local markets = {
	order = { "overpass", "kcorp", "prosthetics", "fixer_desk", "letting" },
}

-- ── the Overpass Market: whatever the streets are doing this year ──────────
markets.overpass = {
	name = "The Overpass Market",
	keeper = "Forty stalls under the old overpass",
	desc = "Forty stalls under the old overpass, lit by bare bulbs. What's on the tables depends on what the streets are doing.",
	minAge = 10,
	markup = {
		{ when = { world = { streets = "turf_war" } }, mult = 1.3, why = "Turf war: everything costs more" },
		{ when = { world = { streets = "quiet" } }, mult = 0.85, why = "Quiet streets: the stalls are haggling" },
		{ when = { crisis = "debts" }, mult = 0.8, why = "Everything comes due: people are selling cheap" },
	},
	goods = {
		{ id = "op_noodles", name = "Noodles from the night stall", desc = "A paper bowl of noodles, too hot, eaten standing up. The stall shuts at half past two.", price = 8, perYear = 2,
			result = { sanity = { 1, 2 }, health = { 0, 1 }, log = "You ate standing up under a bare bulb. The broth was better than it had any right to be." } },
		{ id = "op_bandages", name = "Bandages and disinfectant", desc = "A roll of bandages, a brown bottle, and a stall-keeper who doesn't ask what happened.", price = 40,
			result = { health = { 4, 7 }, log = "You cleaned it and wrapped it yourself, in a doorway. It stung. It held." } },
		{ id = "op_tape", name = "Knuckle tape and a mouthguard", desc = "A boxer's kit from a stall that sells to Rats and Grade 9s alike.", price = 45, once = true, when = { minAge = 12 },
			result = { strength = 1, log = "You taped your hands the way the stall-keeper showed you. They felt like someone else's, someone who knew what they were doing." } },
		{ id = "op_exam_papers", name = "A stack of old exam papers", desc = "Ten years of academy exams, with the answers written in by a different hand.", price = 60, cooldown = 3, when = { world = { streets = { "quiet", "tense" } } },
			result = { intelligence = { 1, 2 }, log = "You worked through them at the kitchen table, one a night. Some of the answers were wrong. Finding which ones was the lesson." } },
		{ id = "op_fruit", name = "Fresh fruit off a Nest truck", desc = "Real fruit, the kind the Nest eats. It fell off a truck, and nobody went back for it.", price = 40, chance = 0.6, when = { world = { streets = "quiet" } },
			result = { health = { 2, 4 }, sanity = { 2, 4 }, log = "You ate a peach over the sink, slowly. You'd forgotten what one tasted like." } },
		{ id = "op_lock", name = "A second lock for your door", desc = "Fitted the same night, by a woman who used to open locks for a living.", price = 90, once = true, when = { world = { streets = { "tense", "turf_war" } } },
			result = { sanity = 3, luck = 1, log = "Two locks now. You slept through the night for the first time in a month." } },
		{ id = "op_armband", name = "An armband that says you're with someone", desc = "In a turf war, colours matter. This one belongs to whoever is winning this week.", price = 120, cooldown = 3, when = { world = { streets = "turf_war" } },
			result = { luck = { 1, 2 }, charisma = 1, log = "You wore it on the right arm, on the right streets, and people let you pass." } },
		{ id = "op_night_map", name = "A map of the Night's waves", desc = "Hand-drawn: where the Sweepers came from on each of the last thirty Nights. Some of it is guesswork.", price = 70, once = true, chance = 0.5, when = { minAge = 12 },
			result = { luck = 1, intelligence = 1, setFlags = { "knows_night" }, log = "You learned the map by heart. The Night has habits, it turns out." } },
		-- what the City is going through this week
		{ id = "op_candles", name = "Candles, water and a deadbolt", desc = "The Sweepers are restless tonight. The stalls sold out of everything else hours ago.", price = 35, when = { worldEvent = "night_in_backstreets" },
			result = { sanity = { 3, 5 }, log = "You locked the door twice, lit the candles and waited it out. You were still there in the morning." } },
		{ id = "op_breach_map", name = "L Corp's evacuation routes", desc = "Someone is selling copies of L Corp's own evacuation routes while the sirens are still going.", price = 50, when = { worldEvent = "abnormality_breach" },
			result = { intelligence = 1, luck = 1, log = "You studied the routes until the sirens stopped. You hope you'll never need them." } },
		{ id = "op_manners", name = "A pamphlet on Thumb manners", desc = "The Thumb is collecting. A pamphlet on how to bow to a Soldato is selling faster than bread.", price = 30, when = { worldEvent = "thumb_crackdown" },
			result = { charisma = 1, rep = { thumb = 3 }, log = "You practised the bow from the pamphlet. A Soldato watched you do it on your step, and nodded once." } },
		{ id = "op_charm", name = "A charm against Distortions", desc = "Wire and glass beads. The man selling it swears it works. It doesn't. People buy it anyway.", price = 40, when = { worldEvent = "distortion_sighting" },
			result = { sanity = { 3, 5 }, log = "It doesn't work. You know it doesn't work. You slept better with it anyway." } },
		{ id = "op_exam_answers", name = "Last year's Hana exam answers", desc = "Hana's exams are on. These answers are from last year, mostly wrong, and very cheap.", price = 25, when = { worldEvent = "hana_exams" },
			result = { intelligence = 1, log = "Half of them were wrong. You learned more from finding out which half." } },
		-- a hard year at the tables
		{ id = "op_bread_sack", name = "Bread by the sack", desc = "A hard year. The bakery stall sells by the sack to anyone with the Ahn to stock up.", price = 30, when = { crisis = true },
			result = { health = { 2, 3 }, sanity = 2, log = "A sack of bread in the cupboard. Whatever this year does, you won't go hungry for a while." } },
		-- rare stock: it isn't there every year
		{ id = "op_maker_notes", name = "A Workshop maker's notebook", desc = "Sketches and notes from a Workshop that closed: mostly about steel, a little about the people who carried it.", price = 180, once = true, chance = 0.3, when = { minAge = 14 },
			result = { strength = 1, speed = 1, intelligence = 1, log = "You read it cover to cover. You hold a blade differently now, even a kitchen knife." } },
		{ id = "op_library_page", name = "A page that fell out of the Library", desc = "A single page, warm to the touch. The seller says it fell out of a book in the Library. It might have.", price = 250, chance = 0.35, when = { world = { era = "library" } },
			result = { intelligence = 2, sanity = -2, log = "You read it once, and remembered a whole stranger's afternoon: the light, the tea, the knock at the door." } },
	},
}

-- ── K Corp: ampules, check-ups, and courses nobody explains ────────────────
markets.kcorp = {
	name = "A K Corp pharmacy",
	keeper = "Clean counters, and a drone over the door",
	desc = "Ampules in rows behind glass. K Corp puts people back together, for a price, and would like you not to ask how.",
	minAge = 12,
	markup = {
		{ when = { notDistrict = "d11" }, mult = 1.6, why = "Brought in from District 11" },
		{ when = { worldEvent = "abnormality_breach" }, mult = 1.3, why = "A breach: everyone wants ampules" },
		{ when = { crisis = true }, mult = 1.2, why = "A hard year: the queue is out the door" },
	},
	goods = {
		{ id = "kc_ampule", name = "An HP ampule", desc = "One dose. It closes cuts you can see and some you can't, and leaves you a little more than whole for a while.", price = 280,
			result = { health = { 25, 35 }, overheal = 15, log = "It went in cold and spread warm. The cut on your arm closed while you watched, and kept going a little past where you started." } },
		{ id = "kc_case", name = "A case of HP ampules", desc = "Six ampules in foam. Fixers buy them by the case before a big contract.", price = 1100, when = { minAge = 16 },
			result = { health = { 50, 65 }, overheal = 30, log = "You used two that night and kept the rest by the door. You haven't felt this whole since you were small." } },
		{ id = "kc_checkup", name = "A K Corp check-up", desc = "A clean room, a scan, a nurse who doesn't make small talk. Whatever is wrong with you, they'll name it and treat it.", price = 260,
			result = { health = { 6, 10 }, cure = "any", log = "They found it, named it and fixed it in an afternoon. The bill was itemised to the minute." } },
		{ id = "kc_course", name = "A regeneration course", desc = "Twelve visits over a year. K Corp says your body will be harder to break afterwards. It doesn't say how. +10 most Health, for good.", price = 2400, once = true, when = { minAge = 18 },
			result = { maxHealth = 10, health = 10, setFlags = { "kc_regen_one" }, log = "Twelve visits, twelve rooms, twelve nurses who never gave their names. You heal faster now. You try not to think about why." } },
		{ id = "kc_course_two", name = "A second regeneration course", desc = "For returning clients. The forms are longer this time, and so are the visits. +12 most Health, for good.", price = 5200, once = true, when = { minAge = 22 }, requires = { flags = { "kc_regen_one" } },
			result = { maxHealth = 12, health = 12, log = "You signed forty pages. You don't remember the visits very well. You've never been sick since." } },
	},
}

-- ── a prosthetics surgeon: a body is something you can upgrade ─────────────
markets.prosthetics = {
	name = "A prosthetics surgeon",
	keeper = "A surgeon whose own hands are steel",
	desc = "Arms, knees, eyes and spines, fitted in a back room. In the City a body is something you can upgrade, if you can pay for it.",
	minAge = 18,
	markup = {
		{ when = { district = "d14" }, mult = 2.2, why = "N Corp's Nail and Hammer hunt augmented people here" },
		{ when = { district = "d11" }, mult = 0.85, why = "District 11 has the best surgeons" },
	},
	goods = {
		{ id = "pr_forearm", name = "A plated forearm", desc = "Your own arm, inside a steel sleeve that takes the blade for you. +6 most Health, +2 Strength.", price = 1600, once = true,
			result = { maxHealth = 6, strength = 2, setFlags = { "augmented" }, log = "It aches when it rains. It also stopped a knife last week, so you've forgiven it." } },
		{ id = "pr_knees", name = "Sprung knees", desc = "Springs and pistons where the cartilage was. You'll outrun people who used to catch you. +3 Speed.", price = 1500, once = true,
			result = { speed = 3, setFlags = { "augmented" }, log = "You took the stairs three at a time on the way home, because you could." } },
		{ id = "pr_eye", name = "A clockwork eye", desc = "It ticks very quietly, and it sees in the dark. Fixers like them for night work.", price = 2100, once = true,
			result = { intelligence = 2, luck = 1, setFlags = { "augmented" }, log = "You can see the grain of the wall across the street at night now. Your other eye is jealous." } },
		{ id = "pr_heart", name = "A heart regulator", desc = "A small machine that keeps your heart steady when nothing else is. +8 most Health.", price = 3000, once = true, when = { minAge = 22 },
			result = { maxHealth = 8, mind = 2, setFlags = { "augmented" }, log = "You noticed it the first time something went wrong: everyone panicked, and your heart didn't." } },
		{ id = "pr_spine", name = "A braced spine with a second motor", desc = "The big one: a frame along your spine that carries what your bones can't. +15 most Health.", price = 4200, once = true, when = { minAge = 20 },
			result = { maxHealth = 15, strength = 1, setFlags = { "augmented" }, log = "It took a season to walk without thinking about it. Now you carry crates on one shoulder and people stare." } },
	},
}

-- ── an Office's front desk: hire a Fixer ───────────────────────────────────
markets.fixer_desk = {
	name = "An Office's front desk",
	keeper = "A tired receptionist and a contract book",
	desc = "Every Office takes small contracts from walk-ins. Name the job and pay the fee, and a Fixer does it.",
	minAge = 14,
	markup = {
		{ when = { world = { streets = "turf_war" } }, mult = 1.4, why = "Turf war: every Fixer is busy" },
		{ when = { worldEvent = "hana_exams" }, mult = 0.8, why = "Exam season: new licences, hungry Fixers" },
	},
	goods = {
		{ id = "fd_escort", name = "A Grade 7 to walk you home, for a year", desc = "A Fixer meets you after work every night for a year. The streets notice.", price = 1100,
			result = { condition = "bs_escorted", log = "Her name was on the contract and her coat was too big for her. Nobody bothered you all year." } },
		{ id = "fd_bodyguard", name = "A Grade 5 bodyguard, for a dangerous year", desc = "A step behind you, everywhere, for a year. Fights go better with one of these at your back.", price = 3000, when = { minAge = 18 },
			result = { condition = "bs_bodyguard", log = "He never said more than three words a day. Twice that year, three words were all it took." } },
		{ id = "fd_tutor", name = "Lessons from a retired Fixer", desc = "Grade 4, retired, bad knee. Teaches anyone who pays how to stay alive in a fight.", price = 350, cooldown = 3,
			result = { strength = 1, speed = 1, mind = 1, log = "She made you run the same three drills for a month, then told you you'd live longer now. She was probably right." } },
		{ id = "fd_sorry_thumb", name = "A Fixer to carry an apology to the Thumb", desc = "The right words and the right gift, carried by someone the Soldati respect.", price = 500, when = { maxRep = { thumb = -10 } },
			result = { rep = { thumb = 20 }, log = "The Fixer came back with your gift unopened and a nod from a Capo. That's as good as it gets." } },
		{ id = "fd_sorry_middle", name = "A Fixer to settle with the Middle", desc = "The Middle never forgets, but it can be paid. A Fixer who knows the family carries the payment.", price = 700, when = { maxRep = { middle = -10 } },
			result = { rep = { middle = 20 }, log = "The payment was accepted. Your name is still in their book, with a line through it now." } },
		{ id = "fd_sorry_index", name = "A Fixer to ask the Index what it wants", desc = "Nobody argues with a Prescript. But a Fixer can ask what would close the matter.", price = 650, when = { maxRep = { index = -10 } },
			result = { rep = { index = 18 }, log = "The answer came by letter, as they do. You did what it said, exactly. The matter is closed." } },
	},
}

-- ── a letting agent: a home of your own ───────────────────────────────────
local function home(id: string, name: string, price: number, desc: string, when: any?, log: string)
	return { id = "lt_" .. id, name = name, desc = desc, price = price, once = false, when = when, tag = "home", result = { home = id, log = log } }
end
markets.letting = {
	name = "A letting agent",
	keeper = "A man with a hundred keys on one ring",
	desc = "Flats, rooms, safehouses and stranger places. Buy one, and it's yours until you sell it or stop paying its upkeep.",
	minAge = 16,
	markup = {
		{ when = { world = { streets = "turf_war" } }, mult = 0.8, why = "Turf war: people are selling to get out" },
		{ when = { crisis = "debts" }, mult = 0.75, why = "Everything comes due: homes are going cheap" },
		{ when = { world = { streets = "quiet" } }, mult = 1.1, why = "Quiet streets: everyone wants to stay" },
	},
	goods = {
		home("steel_door_flat", "A flat with a steel door", 1400, "Two rooms, a kitchen, and a door that would stop a Rat with a crowbar. 40 a year to keep.", nil,
			"You signed, and the agent took one key off his ring and gave it to you. The door closed like a vault."),
		home("flat_above_shop", "A flat above a shop", 2800, "You own the shop downstairs too, and rent it out: 140 a year in, 60 a year to keep.", nil,
			"The noodle smell comes up through the floor every evening. So does the rent."),
		home("hongyuan_room", "A room in Hongyuan", 3600, "In Hongyuan a room grows with its owner's fortune. Yours has a window, and a door that locks.", { district = "d8" },
			"The room was smaller than the drawing. The steward said it would grow, if you did."),
		home("lake_houseboat", "A houseboat on the Great Lake", 4400, "A tarred hull, a stove and the whole Lake outside the window. Pirates mostly leave small boats alone.", { district = "d21" },
			"You slept the first night with the hull creaking and the Lake slapping the sides. You've never slept better."),
		home("branch_bunker", "A bunker in an old L Corp branch", 1100, "Concrete, ten metres down, in what's left of one of old L Corp's buried branches. Nothing comes down here. Nothing alive, anyway.", { district = "d12", world = { era = { "library", "limbus" } } },
			"The agent wouldn't come down the stairs with you. The air was dry and cold, and very, very quiet."),
		home("safehouse", "A safehouse with three exits", 5200, "A back door, a roof hatch and a tunnel to the next building. Grudges have a much harder time finding you.", { minAge = 18 },
			"The agent showed you all three ways out, then made you find them again in the dark."),
		home("nest_apartment", "An apartment in the Nest", 14000, "Clean water, quiet halls, a doorman. The Wing's guards are outside, and they're on your side.", { side = "nest" },
			"The doorman learned your name on the first day. The water ran clear from the first tap."),
		home("townhouse", "A townhouse on a quiet street", 22000, "Three floors and a front step where people know your name. Living here is a kind of renown.", { minAge = 20 },
			"Three floors of your own. You walked through every room twice before you believed it."),
		home("whole_building", "A whole building, tenants and all", 60000, "Thirty flats, a shop on the corner and a garden on the roof: 2,600 a year in rents, 1,100 to keep.", { minAge = 25 },
			"You own a building. The tenants call you by your surname now, and they mean it as a title."),
		{ id = "lt_sell", name = "Sell your home", desc = "The agent buys it back for half what you paid, today, no questions.", price = 0,
			result = { sellHome = true, log = "You handed the keys back. The agent put them on his ring without looking." } },
	},
}

-- what each home is like to live in (Engine/Market.luau). Names fit "Home now: ...".
local homes = {
	order = { "steel_door_flat", "flat_above_shop", "hongyuan_room", "lake_houseboat", "branch_bunker", "safehouse", "nest_apartment", "townhouse", "whole_building" },
	steel_door_flat = { name = "a flat with a steel door", desc = "Two rooms, a kitchen, and a door that would stop a Rat with a crowbar.", price = 1400, upkeep = 40, sanity = 2, safety = 0.1, hideout = 0.1 },
	flat_above_shop = { name = "a flat above a shop", desc = "The shop downstairs is yours too, and it pays rent.", price = 2800, upkeep = 60, income = 140, sanity = 2, safety = 0.1 },
	hongyuan_room = { name = "a room in Hongyuan", desc = "A room that grows with its owner's fortune.", price = 3600, upkeep = 90, sanity = 3, safety = 0.15 },
	lake_houseboat = { name = "a houseboat on the Great Lake", desc = "A tarred hull, a stove and the whole Lake outside the window.", price = 4400, upkeep = 70, sanity = 5, safety = 0.1 },
	branch_bunker = { name = "a bunker in an old L Corp branch", desc = "Ten metres down in a buried branch, where nothing alive comes.", price = 1100, upkeep = 20, sanity = -1, safety = 0.3, hideout = 0.3 },
	safehouse = { name = "a safehouse with three exits", desc = "A back door, a roof hatch, and a tunnel.", price = 5200, upkeep = 120, sanity = 1, safety = 0.2, hideout = 0.45 },
	nest_apartment = { name = "an apartment in the Nest", desc = "Clean water, quiet halls, and the Wing's guards outside.", price = 14000, upkeep = 420, sanity = 4, safety = 0.3, hideout = 0.2 },
	townhouse = { name = "a townhouse on a quiet street", desc = "Three floors, and a step where people know your name.", price = 22000, upkeep = 520, sanity = 4, safety = 0.25, renown = 2 },
	whole_building = { name = "a whole building, tenants and all", desc = "Thirty flats, a shop and a roof garden, and the rents come to you.", price = 60000, upkeep = 1100, income = 2600, sanity = 4, safety = 0.2, renown = 4 },
}

return { markets = markets, homes = homes }
