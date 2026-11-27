--[[
	The City: a content pack set in Project Moon's City (Lobotomy Corporation, Library of
	Ruina, Limbus Company). A fan work: not affiliated with or endorsed by Project Moon, and
	nothing in it is sold (fanWork = true switches the Robux store off).

	Canon reference for writers: docs/CANON.md. Format reference: docs/CONTENT_GUIDE.md.
	Most content lives in folders that are merged here, so several writers can work at
	once without touching the same file:
		Events/       every module returns a list of events
		Activities/   lists of activities
		Careers/      { order = {...}, [id] = career }
		Expeditions/  { order = {...}, [id] = expedition }
		Quests/       { order = {...}, [id] = quest }
		Lore/         lists of codex entries
		Chronicle/    { [act] = { text, announce, tone } }

	THE AGES: a life is lived across the City's history. `world.era` follows the calendar:
		(before 940)            the Smoke War. Never played: it is over before any life here
		                        begins, and it is how Lobotomy Corporation won its Wing.
		wings          940-977  THE AGE OF L CORP. Lobotomy Corporation holds District 12 in the
		                        fallen Wing's place. Nobody has a word for Distortion or E.G.O.
		white_nights   978      L Corp's last year. The Light spreads from District 12: three
		                        White Nights, then four Dark Days. It was meant to shine seven.
		                        All anyone outside knows is that it failed.
		library        979-1000 THE AGE OF THE LIBRARY. It stands where L Corp was. From here on
		                        a person at the brink hears a voice, and can Distort or find
		                        E.G.O. The City's rank for the Library climbs (world.library).
		limbus         1001+    AFTER THE LIBRARY. The Library is cast out; a second Light shines
		                        seven full days. Shin and Mang can be trained. Distortions never
		                        stopped. Limbus Company's bus is on the road.
	The years are this game's own framing, not canon dates: the ages are long enough to live in.

	Colors are {R, G, B} (0-255) so the engine stays free of Roblox types.
]]

local pack = {}

-- Folder merges. Every ModuleScript in a folder adds to one section, so several writers
-- can work at once without touching the same file. Duplicate ids are reported by the
-- validator (pack.mergeIssues) instead of silently overwriting each other.
pack.mergeIssues = {}
local function sortedModules(folderName: string)
	local list = {}
	for _, child in script:WaitForChild(folderName):GetChildren() do
		if child:IsA("ModuleScript") then
			table.insert(list, child)
		end
	end
	-- Core first, then the rest by name, so merges come out the same every time
	table.sort(list, function(a, b)
		if (a.Name == "Core") ~= (b.Name == "Core") then
			return a.Name == "Core"
		end
		return a.Name < b.Name
	end)
	return list
end
-- { order = {...}, [id] = def } modules
local function mergeOrdered(folderName: string)
	local out = { order = {} }
	for _, child in sortedModules(folderName) do
		local more = require(child)
		for _, id in more.order or {} do
			if more[id] == nil then
				table.insert(pack.mergeIssues, string.format("%s/%s: '%s' is in order but not defined", folderName, child.Name, id))
			elseif out[id] ~= nil then
				table.insert(pack.mergeIssues, string.format("%s/%s: duplicate id '%s'", folderName, child.Name, id))
			else
				out[id] = more[id]
				table.insert(out.order, id)
			end
		end
		for id in more do
			if id ~= "order" and not table.find(more.order or {}, id) then
				table.insert(pack.mergeIssues, string.format("%s/%s: '%s' is defined but missing from order", folderName, child.Name, tostring(id)))
			end
		end
	end
	return out
end
-- modules that return a plain list (events also remember which file they came from)
local function mergeLists(folderName: string, tagSource: boolean?)
	local out = {}
	for _, child in sortedModules(folderName) do
		for _, item in require(child) do
			if tagSource and type(item) == "table" then
				item.source = item.source or child.Name
			end
			table.insert(out, item)
		end
	end
	return out
end

pack.fanWork = true -- a fan game: no Robux store
pack.quickChecks = true -- only real fights get the fight screen

pack.meta = {
	title = "A Life in the City",
	tagline = "Be home before 3:13.",
	about = "One whole life, a year at a time. What you do, who you cross and when you were born decide how it ends. Then the next one begins.",
	currency = "Ahn",
	lanternName = "Book", -- a finished life becomes a book
	ledgerName = "Your Library", -- the shelf of finished lives
	glowName = "Light", -- meta currency
	premiumName = "Lunacy", -- premium currency (bought in the store, earned a little by playing)
	districtWord = "District",
	actionsPerYear = 4, -- more with Speed (tier perks)
	-- time for people is its own budget: three things a year with family and friends, on top
	-- of the four actions for everything else (more of both with Speed, Intelligence, Charisma)
	socialPerYear = 3,
	adultAge = 18,
	maxLogEntries = 400,
	birthHint = "Most people are born in the Backstreets. Every District has its own Wing, its own rules and its own way of getting you killed.",
	-- the City's words for the shared screens
	releaseVerb = "Shelve",
	releaseToast = "The book goes onto the shelf with the others. Someone, someday, will read it.",
	dailyTitle = "Daily visit",
	heldBy = "%s's District: %s.",
	unheld = "No Wing holds this District now.",
	unheldShort = "No Wing holds this District",
	arrivalName = "the Backstreets",
	emptyLedger = "No books yet. Every life that ends is written down and shelved here.",
}

pack.calendar = {
	startYear = 962,
	startJitter = 4,
	-- When you're born decides which ages of the City you live through, and everything in a
	-- life follows it (pack.eraRules below): no Library before the Light, no word for a
	-- Distortion before it, no Limbus Company before the Library is gone, no working L Corp
	-- after its last year. The player may pick an age; if they don't, the City does (weight).
	rollEra = true,
	-- a life that starts grown (a mode) opens with the age the City is in that day
	openingByWorld = { wings = "wings", white_nights = "twilight", library = "library", limbus = "after" },
	eras = {
		{
			id = "wings",
			name = "The Age of L Corp",
			years = "Born around 942",
			year = 942,
			jitter = 3,
			weight = 3,
			desc = "The Smoke War is over. Lobotomy Corporation won it, took the fallen Wing's seat, and District 12 with it. Its energy runs the City and nobody asks how. You'll be near forty before anything changes.",
			has = { "L Corp, the Wing of District 12", "No Distortions, no E.G.O", "The Light comes late in your life" },
			opening = { "The Smoke War is over.", "Lobotomy Corporation won it, and took the fallen Wing's seat.", "District 12 is theirs now. You are born in its long shadow." },
		},
		{
			id = "twilight",
			name = "The last years of L Corp",
			years = "Born around 962",
			year = 962,
			jitter = 3,
			weight = 4,
			desc = "You grow up under L Corp and come of age as it ends. In its last year a Light rises from District 12: three White Nights, then four Dark Days. Your whole adult life is what comes after.",
			has = { "L Corp, then its last year", "The White Nights and Dark Days", "The Library, when you're grown" },
			opening = { "L Corp has held District 12 since before your parents met.", "It says it is building something for everyone.", "You will be grown when it is finished." },
		},
		{
			id = "library",
			name = "The Age of the Library",
			years = "Born around 979",
			year = 979,
			jitter = 2,
			weight = 3,
			desc = "The Light has already shone, and failed. A Library stands where L Corp was, and its name climbs rank by rank. People at the brink hear a voice now. Some come back wrong. A few come back with E.G.O.",
			has = { "The Library and its ranks", "Distortions and E.G.O", "A voice at the brink" },
			opening = { "L Corp's Light rose, and failed: three days of white, then four of dark.", "A Library stands where its tower was.", "People at the brink have started hearing a voice." },
		},
		{
			id = "after",
			name = "After the Library",
			years = "Born around 1001",
			year = 1001,
			jitter = 2,
			weight = 2,
			desc = "The Library is gone, cast out past the wall, and a second Light shone seven full days. Distortions never stopped. Some people train their hearts into Shin and Mang. A company called Limbus crosses the City by bus.",
			has = { "The second Light", "Shin and Mang", "Limbus Company" },
			opening = { "The Library is gone, cast out past the wall.", "A second Light shone, all seven days this time.", "The City is still the City." },
		},
	},
}

-- THE STATS. The usual ones, and Sanity.
--   Health            your body: at zero, you die
--   Strength          your power in a fight (base and per-coin power)
--   Speed             how many coins you bring to a fight (the clashes you can afford to
--                     lose), and who strikes first: the faster side opens one-sided, the
--                     slower side has to clash for everything
--   Intelligence      study, skill and work: jobs and promotions
--   Charisma          people: bonds grow faster, prices come down, talk works
--   Luck              dealt at birth, hard to change: tilts every coin, dodges bad years,
--                     brings finds
--   Mental Strength   how much a mind can carry: holding on at the brink, whether E.G.O
--                     answers, and how little Sanity it costs to use
-- Sanity runs -45..45 and tilts every coin: heads chance = 50% + Sanity%.
pack.stats = {
	order = { "health", "strength", "speed", "intelligence", "charisma", "luck", "mind" },
	vital = "health",
	word = "stat",
	roles = { fight = "strength", work = "intelligence", will = "mind", speed = "speed", charm = "charisma", luck = "luck" },
	grow = { "strength", "speed", "intelligence", "charisma", "mind" },
	growPicks = 4, -- five stats to grow into, so four of them tick up each year of childhood
	health = { name = "Health", short = "HP", color = { 214, 96, 88 }, desc = "Your body. At zero, you die." },
	strength = { name = "Strength", short = "STR", color = { 232, 142, 70 }, desc = "How hard you hit. Your power in every fight." },
	speed = { name = "Speed", short = "SPD", color = { 96, 206, 196 }, desc = "How many clashes you can take in a fight, and who moves first. The faster side strikes one-sided; the slower side has to clash." },
	intelligence = { name = "Intelligence", short = "INT", color = { 120, 170, 226 }, desc = "Study, skill and craft. How well you work and how far a job takes you." },
	charisma = { name = "Charisma", short = "CHA", color = { 226, 126, 178 }, desc = "How people take to you. Bonds grow faster, prices come down, and talking works." },
	luck = { name = "Luck", short = "LCK", color = { 136, 204, 110 }, desc = "The City's coin. Dealt at birth and hard to change: tilts every coin flip, dodges bad years, brings finds.", birth = { 1, 22 } },
	mind = { name = "Mental Strength", short = "MEN", color = { 168, 120, 222 }, desc = "How much your mind can carry. Decides whether you hold together when your Sanity hits the bottom, and what it costs you to call on what's inside you." },
	sanity = { name = "Sanity", min = -45, max = 45, start = 12, rest = 0, drift = 1 },
	-- TIERS: every 20 points of a stat is a tier (I at 0, II at 20 ... V at 80), and tiers have
	-- perks. What each effect does: Engine/Sim.luau, "STAT TIERS, PERKS, NATURE".
	tierEvery = 20,
	-- (v0.13) tiers VI (100) and VII (120) exist past the old ceiling: only a life whose limits
	-- were broken (renown, feats, deeds, gear: Engine/Body.luau capBonus) gets there.
	-- (v0.17) and on, all the way to XXI at 400: trainers' limit courses, augment arms, the
	-- worst things in the City beaten, a Color's name and old blood can carry a stat that far.
	-- Perks at XI (200), XVI (300) and XXI (400) are for the handful who get there.
	tierMax = 21,
	cap = 100,
	perks = {
		health = {
			[3] = { name = "Thick skin", desc = "Wounds take 10% less.", toughness = 0.10 },
			[5] = { name = "Hard to kill", desc = "Wounds take 20% less.", toughness = 0.10 },
			[6] = { name = "Unbroken", desc = "Wounds take 30% less.", toughness = 0.10 },
			[7] = { name = "Walking wall", desc = "Wounds take 40% less.", toughness = 0.10 },
			[11] = { name = "Iron frame", desc = "Wounds take 45% less.", toughness = 0.05 },
			[16] = { name = "Hard as a wall", desc = "Wounds take 50% less.", toughness = 0.05 },
			[21] = { name = "What the City can't break", desc = "Wounds take 55% less.", toughness = 0.05 },
		},
		strength = {
			[3] = { name = "Heavy hands", desc = "+1 power when you Overpower.", stance = { base = 1 } },
			[5] = { name = "Breaker", desc = "Each heads hits 1 harder when you Overpower.", stance = { coinPower = 1 } },
			[6] = { name = "Crusher", desc = "+2 more power when you Overpower.", stance = { base = 2 } },
			[7] = { name = "One blow", desc = "Each heads hits 1 harder again when you Overpower.", stance = { coinPower = 1 } },
			[11] = { name = "Wall-breaker", desc = "+2 power, and each heads 1 harder, when you Overpower.", stance = { base = 2, coinPower = 1 } },
			[16] = { name = "A Color's arm", desc = "+3 more power when you Overpower.", stance = { base = 3 } },
			[21] = { name = "One blow, one street", desc = "+3 power and each heads 1 harder again when you Overpower.", stance = { base = 3, coinPower = 1 } },
		},
		speed = {
			[3] = { name = "Spare hours", desc = "+1 thing to do every year.", actions = 1 },
			[5] = { name = "Never still", desc = "+1 more thing to do every year.", actions = 1 },
			[6] = { name = "Blur", desc = "+2 power when you Outpace.", stance = { base = 2 } },
			[7] = { name = "Gone before the echo", desc = "Each heads hits 1 harder when you Outpace.", stance = { coinPower = 1 } },
			[11] = { name = "Afterimage", desc = "+2 power when you Outpace. At 200 Speed you carry a fifth coin into every fight.", stance = { base = 2 } },
			[16] = { name = "Between heartbeats", desc = "Each heads hits 1 harder again when you Outpace.", stance = { coinPower = 1 } },
			[21] = { name = "Already there", desc = "+3 power when you Outpace. (A sixth coin came at 350.)", stance = { base = 3 } },
		},
		intelligence = {
			[3] = { name = "Worth more", desc = "Wages +15%.", wage = 0.15 },
			[4] = { name = "Quick study", desc = "Whatever you do teaches you 1 more.", training = 1 },
			[5] = { name = "Ahead of the day", desc = "+1 thing to do every year.", actions = 1 },
			[6] = { name = "Mastermind", desc = "Wages +15% more, and +2 power when you Outthink.", wage = 0.15, stance = { base = 2 } },
			[7] = { name = "A mind the Wings would buy", desc = "Whatever you do teaches you 1 more again.", training = 1 },
			[11] = { name = "Three moves ahead", desc = "Wages +20% more, and +2 power when you Outthink.", wage = 0.2, stance = { base = 2 } },
			[16] = { name = "Reads the room, and the District", desc = "Whatever you do teaches you 1 more again.", training = 1 },
			[21] = { name = "A Wing's mind", desc = "+3 power and each heads 1 harder when you Outthink.", stance = { base = 3, coinPower = 1 } },
		},
		charisma = {
			[3] = { name = "Good company", desc = "+1 time for people every year.", social = 1 },
			[4] = { name = "Known face", desc = "Prices 10% lower.", price = 0.10 },
			[5] = { name = "Everyone's friend", desc = "+1 more time for people every year.", social = 1 },
			[6] = { name = "Silver tongue", desc = "Prices 10% lower again, and +2 power when you Talk down.", price = 0.10, stance = { base = 2 } },
			[7] = { name = "The District listens", desc = "+1 more time for people every year.", social = 1 },
			[11] = { name = "Rooms go quiet", desc = "Prices 5% lower again, and +2 power when you Talk down.", price = 0.05, stance = { base = 2 } },
			[16] = { name = "A name people repeat", desc = "+1 more time for people every year.", social = 1 },
			[21] = { name = "The City listens", desc = "+3 power and each heads 1 harder when you Talk down.", stance = { base = 3, coinPower = 1 } },
		},
		mind = {
			[2] = { name = "Steady", desc = "You lose 15% less Sanity.", sanityGuard = 0.15 },
			[4] = { name = "Unshaken", desc = "You lose 30% less Sanity.", sanityGuard = 0.15 },
			[5] = { name = "Whole", desc = "E.G.O costs its minimum.", egoMin = true },
			[6] = { name = "Still water", desc = "You lose 45% less Sanity.", sanityGuard = 0.15 },
			[7] = { name = "Anchor", desc = "You lose 60% less Sanity.", sanityGuard = 0.15 },
			[11] = { name = "Deep water", desc = "You lose 70% less Sanity.", sanityGuard = 0.1 },
			[16] = { name = "Bedrock", desc = "You lose 80% less Sanity.", sanityGuard = 0.1 },
			[21] = { name = "Nothing reaches the bottom", desc = "You lose 90% less Sanity.", sanityGuard = 0.1 },
		},
	},
	-- NATURE: the stat you lean on (your highest of these, once it's 25). +1 on everything that
	-- uses it, and events of its kind come to you more often (pack.natureDraw).
	natures = {
		order = { "strength", "speed", "intelligence", "charisma", "mind" },
		min = 25,
		strength = { name = "The Strong", desc = "+1 on Strength. Trouble comes looking for you." },
		speed = { name = "The Quick", desc = "+1 on Speed. Chases and close calls find you." },
		intelligence = { name = "The Sharp", desc = "+1 on Intelligence. Puzzles and offers find you." },
		charisma = { name = "The Charming", desc = "+1 on Charisma. People bring you their business." },
		mind = { name = "The Unshaken", desc = "+1 on Mental Strength. The strange finds you." },
	},
}
pack.natureDraw = 1.6
-- someone you're close to stands with you in one fight a year (+1 coin); someone closer still
-- gets to you in time, once in a life, when a wound would have ended it
pack.bondPerks = { backAt = 80, saveAt = 92, saveHealth = 6, minAge = 16 }

--[[
	SIDES: every District has a Nest (walled, run by its Wing) and Backstreets
	(everything outside the walls). The first side in `order` is the rich one.
]]
pack.sides = {
	order = { "nest", "backstreets" },
	nest = {
		name = "the Nest",
		short = "Nest",
		desc = "Inside the walls, under the Wing's eye. Safe, clean, taxed, and watched. Residence takes money and paperwork.",
		costMult = 2,
		payMult = 1.25,
		danger = 0.35,
		hazardChance = 0.12,
		evictOnDebt = true,
		evictGrace = 1,
		wear = 0,
		tagWeights = { crime = 0.4, luxury = 2, backstreets = 0.2 },
		color = { 214, 222, 240 },
	},
	backstreets = {
		name = "the Backstreets",
		short = "Backstreets",
		desc = "Everything outside the Nest: restaurants, workshops, academies, Syndicates, Fixers, and the Night, when the Sweepers come.",
		costMult = 0.6,
		payMult = 0.9,
		danger = 1,
		hazardChance = 0.42,
		wear = 1,
		yearly = { health = { -1, 0 } },
		tagWeights = { luxury = 0.3, backstreets = 1.5 },
		color = { 196, 120, 110 },
	},
}

--[[
	DISTRICTS: each held by a Wing (its `corp`). Numbers are canon: a Wing's letter is its
	District's place in the alphabet. `color` is the Wing's color on the skyline.
		wealth (pay x), danger (hazards and "danger" events x), cost (yearly living cost),
		charterCost (Nest residence), charterShare (chance to be born in the Nest),
		population (how often lives start here), careerPay, music (a mood), backdrop
]]
pack.districts = {
	order = { "d4", "d7", "d8", "d11", "d12", "d14", "d16", "d18", "d19", "d20", "d21", "d23" },
	d4 = {
		name = "District 4",
		number = 4,
		corp = "D Corp",
		trade = "ordinary Backstreets trade, and an L Corp branch buried under the streets",
		desc = "A common sort of District: small Fixer offices, noodle stalls, academies, and Rats in the alleys. Something of L Corp's is buried under it.",
		wealth = 1.0,
		danger = 1.0,
		cost = 50,
		charterCost = 1400,
		charterShare = 0.15,
		population = 1.4,
		careerPay = { fixer = 1.1 },
		color = { 150, 170, 200 },
		music = "semi",
		backdrop = { tint = { 236, 230, 220 }, fog = { 110, 100, 100 }, clock = 1 },
	},
	d7 = {
		name = "District 7",
		number = 7,
		corp = "G Corp",
		trade = "the new G Corp, built on the ruins of the old one",
		desc = "Old G Corp fought the Smoke War on the front lines and fell. Veterans here don't talk about it, and the new Wing would rather nobody did.",
		wealth = 0.95,
		danger = 1.15,
		cost = 45,
		charterCost = 1300,
		charterShare = 0.14,
		population = 0.9,
		careerPay = { rcorp = 1.1 },
		color = { 120, 170, 90 },
		music = "emotional",
		backdrop = { tint = { 220, 230, 200 }, fog = { 90, 100, 80 }, clock = 23 },
	},
	d8 = {
		name = "District 8",
		number = 8,
		corp = "H Corp",
		trade = "Boluses: medicine that heals, and medicine that changes what you are",
		desc = "Hongyuan: one vast shifting megastructure. Your room grows with your fortune. The Four Families rule, and the Heishou Packs keep their leashes short.",
		wealth = 1.25,
		danger = 1.0,
		cost = 70,
		charterCost = 1900,
		charterShare = 0.22,
		population = 1.0,
		color = { 214, 64, 64 },
		music = "intense",
		backdrop = { tint = { 255, 214, 200 }, fog = { 120, 60, 50 }, clock = 0.5 },
	},
	d11 = {
		name = "District 11",
		number = 11,
		corp = "K Corp",
		trade = "HP Ampules: one dose and the body remembers being whole",
		desc = "Checkpoints, drones and very clean streets. K Corp's ampules put people back together, and K Corp would like you not to ask how.",
		wealth = 1.4,
		danger = 0.8,
		cost = 75,
		charterCost = 2200,
		charterShare = 0.25,
		population = 1.0,
		careerPay = { kcorp = 1.2 },
		color = { 96, 220, 160 },
		music = "calm",
		backdrop = { tint = { 220, 255, 236 }, fog = { 90, 130, 110 }, clock = 2 },
	},
	d12 = {
		name = "District 12",
		number = 12,
		corp = nil, -- L Corp has its own careers here (see Careers/); after its fall the slot stays empty
		trade = "Enkephalin, while Lobotomy Corporation stood; scavenging, after",
		desc = "Lobotomy Corporation's District. It powered half the City with energy drawn from things in its vaults. After the White Nights and Dark Days it is a ruin with an empty Wing slot.",
		wealth = 1.3,
		danger = 1.2,
		cost = 65,
		charterCost = 1800,
		charterShare = 0.2,
		population = 1.1,
		careerPay = { lcorp_agent = 1.15, lcorp_research = 1.15 },
		color = { 120, 255, 140 },
		music = "scary",
		backdrop = { tint = { 220, 255, 220 }, fog = { 60, 110, 70 }, clock = 1.5 },
	},
	d14 = {
		name = "District 14",
		number = 14,
		corp = "N Corp",
		trade = "Canned Experience, among other things",
		desc = "N Corp's District, where the Nail and Hammer factions hunt what they call impurity. Most people just live on streets like Butter Street and keep their heads down.",
		wealth = 1.1,
		danger = 1.05,
		cost = 55,
		charterCost = 1600,
		charterShare = 0.18,
		population = 1.0,
		color = { 180, 180, 190 },
		music = "angry",
		backdrop = { tint = { 230, 226, 220 }, fog = { 100, 96, 90 }, clock = 23.5 },
	},
	d16 = {
		name = "District 16",
		number = 16,
		corp = "P Corp",
		trade = "space bending: buildings that fold like rubber and stay safe inside",
		desc = "Spires taller than anywhere else, and buildings that bend without breaking. Some nights the streets are not where you left them.",
		wealth = 1.2,
		danger = 0.95,
		cost = 65,
		charterCost = 1800,
		charterShare = 0.2,
		population = 0.9,
		color = { 170, 140, 255 },
		music = "uplifting",
		backdrop = { tint = { 236, 226, 255 }, fog = { 110, 100, 140 }, clock = 21 },
	},
	d18 = {
		name = "District 18",
		number = 18,
		corp = "R Corp",
		trade = "military contracting: the Fourth Pack, Rabbits, Reindeer and Rhinos",
		desc = "R Corp sells armies. Its packs march out by the thousand and fewer march back. Recruiting offices never close.",
		wealth = 1.05,
		danger = 1.25,
		cost = 45,
		charterCost = 1400,
		charterShare = 0.14,
		population = 0.9,
		careerPay = { rcorp = 1.25 },
		color = { 236, 120, 60 },
		music = "battle",
		backdrop = { tint = { 255, 220, 190 }, fog = { 110, 80, 60 }, clock = 22 },
	},
	d19 = {
		name = "District 19",
		number = 19,
		corp = "S Corp",
		trade = "farming and livestock, under a King and his Court",
		desc = "S Corp's Nest has a King with retainers and Court Circles. Some of its people run away, and the Ch'unokkun come after them. The Blade Lineage started here.",
		wealth = 0.9,
		danger = 1.1,
		cost = 40,
		charterCost = 1200,
		charterShare = 0.12,
		population = 0.8,
		color = { 220, 200, 120 },
		music = "emotional",
		backdrop = { tint = { 255, 240, 210 }, fog = { 120, 110, 80 }, clock = 5.5 },
	},
	d20 = {
		name = "District 20",
		number = 20,
		corp = "T Corp",
		trade = "Time: balances, withdrawals, and the Time Tax",
		desc = "A monochrome Nest where color is a privilege. T Corp sells and taxes time itself. The Yurodiviye have a branch in the Backstreets.",
		wealth = 1.3,
		danger = 0.95,
		cost = 70,
		charterCost = 2000,
		charterShare = 0.2,
		population = 0.8,
		color = { 200, 200, 200 },
		music = "calm",
		backdrop = { tint = { 226, 226, 226 }, fog = { 96, 96, 96 }, clock = 0, saturation = -0.5 },
	},
	d21 = {
		name = "District 21",
		number = 21,
		corp = "U Corp",
		trade = "the Great Lake: ports, ships, and a tuning fork that fuses things together",
		desc = "U Corp's institutions float on the Great Lake. The Stingray Portship for the rich, the pirates and whalers for everyone else.",
		wealth = 1.15,
		danger = 1.15,
		cost = 60,
		charterCost = 1700,
		charterShare = 0.16,
		population = 0.9,
		color = { 80, 170, 230 },
		music = "intense",
		backdrop = { tint = { 210, 236, 255 }, fog = { 70, 100, 130 }, clock = 4.5 },
	},
	d23 = {
		name = "District 23",
		number = 23,
		corp = "W Corp",
		trade = "the WARP trains: across the City in seconds, for a price",
		desc = "Home of the WARP trains and their cleanup crews. The Backstreets, the \"Streets of Flavor\", have a reputation nobody likes to explain.",
		wealth = 1.2,
		danger = 1.2,
		cost = 60,
		charterCost = 1800,
		charterShare = 0.16,
		population = 1.0,
		careerPay = { wcorp_cleanup = 1.2 },
		color = { 90, 200, 255 },
		music = "scary",
		backdrop = { tint = { 214, 236, 255 }, fog = { 60, 90, 120 }, clock = 3 },
	},
}

-- World state. The age follows the calendar; so does the City's rank for the Library; the
-- streets shift year to year.
pack.world = {
	{
		key = "era",
		name = "The age",
		byYear = {
			{ from = 0, value = "wings" },
			{ from = 978, value = "white_nights" },
			{ from = 979, value = "library" },
			{ from = 1001, value = "limbus" },
		},
		labels = {
			wings = "The Age of L Corp",
			white_nights = "The White Nights and Dark Days",
			library = "The Age of the Library",
			limbus = "After the Library",
		},
		notes = {
			wings = "Lobotomy Corporation holds District 12 and powers the City.",
			white_nights = "L Corp's last year. Three days of light, then four of dark.",
			library = "A Library stands where L Corp was. People at the brink can Distort.",
			limbus = "The Library is gone. A second Light shone seven days. Distortions remain.",
		},
	},
	{
		-- Hana grades every threat to the City. The Library climbs the whole scale.
		key = "library",
		name = "The Library",
		byYear = {
			{ from = 0, value = "none" },
			{ from = 979, value = "canard" },
			{ from = 981, value = "myth" },
			{ from = 984, value = "legend" },
			{ from = 987, value = "plague" },
			{ from = 990, value = "nightmare" },
			{ from = 994, value = "star" },
			{ from = 998, value = "impurity" },
			{ from = 1001, value = "gone" },
		},
		hide = { none = true },
		labels = {
			canard = "Library: Canard",
			myth = "Library: Urban Myth",
			legend = "Library: Urban Legend",
			plague = "Library: Urban Plague",
			nightmare = "Library: Urban Nightmare",
			star = "Library: Star of the City",
			impurity = "Library: Impurity",
			gone = "The Library is gone",
		},
		notes = {
			canard = "A rumor. Hana won't pay a Fixer to look into it.",
			myth = "Guests have gone in and not come out. Small Offices take the invitations.",
			legend = "Whole Offices are missing. The invitations keep arriving.",
			plague = "Associations have lost Sections to it. Refusing an invitation is now advice.",
			nightmare = "The Fingers have sent their own, and lost them.",
			star = "The highest rank Hana gives. Colors have gone in.",
			impurity = "Past every rank. The Head itself is looking at it.",
			gone = "Cast out past the City wall. The books it made of its guests are not.",
		},
	},
	{
		key = "streets",
		name = "The streets",
		values = { "quiet", "tense", "turf_war" },
		labels = { quiet = "Quiet streets", tense = "Tense streets", turf_war = "Turf war" },
		start = "tense",
		shift = 0.3,
	},
}

-- THE TIMELINE: what exists when. Whatever age a life is born into, the City around it has to
-- match: no Limbus Company (and no Shin or Mang) before the Library is gone, no Library before
-- the Light, no word for a Distortion and no E.G.O of one's own before the Library's age, no
-- working L Corp after its last year.
-- tests/era_check holds every line a player can read to these rules. `eras` is where the words
-- may appear; an entry passes when its conditions already keep it to those eras.
pack.eraRules = {
	{ id = "limbus", eras = { "limbus" }, words = { "Limbus", "LCB", "LCCB", "LCE", "LCD", "Golden Bough", "Mephistopheles", "Peccatul", "Sinner", "Mirror World", "Shin", "Mang", "second Light" } },
	{ id = "library", eras = { "library", "limbus" }, words = { "the Library", "The Library", "Librarian", "Reverberation Ensemble" } },
	{ id = "light", eras = { "white_nights", "library", "limbus" }, words = { "the Light", "White Nights", "Dark Days" } },
	-- nobody Distorts, and nobody has a word for it, until the Light has failed
	{ id = "distortion", eras = { "library", "limbus" }, words = { "Distortion", "Distorted", "Distort" } },
	-- and nobody manifests E.G.O. Inside L Corp the word already exists, for the gear the Wing
	-- draws out of what it contains: those mentions read as equipment, and pass.
	{
		id = "ego",
		eras = { "library", "limbus" },
		words = { "E.G.O" },
		unless = { "(E.G.O)", "E.G.O gear", "E.G.O suit", "E.G.O weapon", "E.G.O Gift", "E.G.O from", "E.G.O was", "extracted", "Extraction", "the Wing's E.G.O", "issued", "locker", "armory", "requisition" },
	},
	-- L Corp after its fall is a ruin and a memory: a mention has to read like one
	{
		id = "lcorp_alive",
		eras = { "wings", "white_nights" },
		words = { "L Corp", "Lobotomy" },
		unless = {
			"old L Corp", "Old L Corp", "former L Corp", "buried", "fell", "fallen", "used to", "ruins", "is gone", "sealed", "sunken",
			"stands dark", "headquarters stood", "L Corp called", "came out of the L Corp tower", "out of L Corp on the last day",
		},
	},
}
-- careers, flags and traits that only exist in some eras: a condition on one of them keeps an
-- entry to those eras as surely as a `world` condition does
pack.eraBound = {
	careers = {
		lcorp_agent = { "wings", "white_nights" },
		lcorp_research = { "wings", "white_nights" },
		limbus_lccb = { "limbus" },
		limbus_lce = { "limbus" },
		lim_lcd = { "limbus" },
	},
	flags = {
		saw_white_nights = { "white_nights", "library", "limbus" },
		saw_the_library = { "library", "limbus" },
		-- The Voice (Storylines/Lore.luau): only set at the brink, after the Light
		sl_vo_lost = { "library", "limbus" },
		sl_vo_ego = { "library", "limbus" },
		sl_vo_heard = { "library", "limbus" },
		heard_the_voice = { "library", "limbus" },
		manifested_ego = { "library", "limbus" },
		saw_second_light = { "limbus" },
		knows_shin = { "limbus" },
	},
	-- nobody is anything but human, or a Bloodfiend, until the Light has failed
	forms = {
		ego = { "library", "limbus" },
		distorted = { "library", "limbus" },
	},
	traits = {
		ego_volatile = { "library", "limbus" },
		shin = { "limbus" },
		mang_one = { "limbus" },
		mang_two = { "limbus" },
		mang_three = { "limbus" },
	},
}
-- entries read by a person and found right for every era they can happen in (a memory of L Corp
-- told after its fall, say): id = true
pack.eraReviewed = {
	lc_rs_head_budget = true, -- "For the Light": L Corp's own project, said before anyone outside knew the word
	limbus_lce = true, -- the Limbus department is named for the fuel
	lc_scr_light = true, -- a former employee, after the fall
	lc_scr_green = true,
	lc_act_green_kettle = true, -- "or used to"
	lc_dly_green_kettle = true, -- photographs on the wall
	lim_bough_d11 = true, -- the floors under the street are the buried branches
	lim_bough_d14 = true,
	lim_bough_d16 = true,
	lim_bough_d20 = true,
	lim_bough_d8 = true,
	lim_dig_shift = true,
	lim_faust_workshop = true,
	lim_lce_regrade = true,
	lim_bus_arrives = true,
	limbus_lccb = true,
	lim_echo_bough = true,
	lim_lccb_sweep = true,
	lc_remnant_limbus = true,
	bs_y_lcorp_after = true,
	lc_echo_truth = true,
	lc_remnant_tea = true,
	fc_rc_lce_badge = true,
	lc_act_manuals = true, -- carried out of the teahouse after the fall
	lim_bough_resonance = true, -- a buried floor
	dz_w_lantern_walk = true, -- "Toward the Light": a lantern's light, in a choice label
	lc_echo_ordeal = true, -- "the Lights Dimmed": street lights
}

-- Careers live in Careers/ (one module per area, merged here).
pack.careers = mergeOrdered("Careers")
table.sort(pack.careers.order, function(a, b)
	return (pack.careers[a].sort or 50) < (pack.careers[b].sort or 50)
end)

-- Forms: what you are. A breaking point can turn you into a Distortion, or you can face
-- what's inside and manifest E.G.O.
pack.forms = {
	-- the City wears people out: an ordinary body starts failing from 63 (lifespan)
	human = { name = "Human", desc = "Soft, warm, breakable. The usual.", lifespan = 63 },
	ego = {
		name = "E.G.O",
		desc = "You looked at the whole of what your despair wanted to become, refused it, and kept it. The voice can't reach you now. Let it out in a fight (the E.G.O approach) for Sanity: the stronger your mind, the less it costs.",
		clash = { base = 1 },
		headsFloor = 25,
		color = { 255, 214, 120 },
		look = { tint = { 236, 226, 214 }, amount = 0.1, eyes = { 255, 214, 120 }, glow = true },
	},
	-- Bloodfiends (Limbus Company, Canto VII): a gift you can take (Events/Bloodfiend.luau).
	-- Quick to heal, slow to age, strong in a fight; the Thirst drains Sanity every year and
	-- Hemobars refill it. They never Distort: at the edge they lose themselves to the Thirst.
	-- (v0.17) Slow to age means slow: a Bloodfiend can see centuries, and the blood only gets
	-- stronger as it gets older (pack.elderBlood). Elders lead Families (canon); the stages
	-- past that are this game's own.
	bloodfiend = {
		name = "Bloodfiend",
		desc = "Kindred of a Family: red-eyed, quick to heal, slow to age, and always a little thirsty. Hemobars keep the Thirst quiet. Bloodfiends are not Distortions.",
		clash = { base = 1 },
		headsFloor = 20,
		ageless = true,
		lifespan = 600,
		yearly = { sanity = { -4, -2 } },
		color = { 200, 40, 52 },
		look = { tint = { 236, 222, 228 }, amount = 0.3, eyes = { 214, 32, 44 }, glow = true },
	},
	distorted = {
		name = "Distortion",
		desc = "Something the City will hire Fixers to deal with.",
		terminal = true,
		color = { 150, 60, 120 },
		look = { tint = { 120, 60, 100 }, amount = 0.45, eyes = { 255, 80, 160 }, glow = true },
	},
}

-- (v0.17) the build a kind of relation is drawn with (cosmetics.body); everyone else is rolled
pack.kindBodies = { mother = "feminine", father = "masculine" }

pack.relationKinds = {
	mother = { name = "Mother", family = true, ageGap = { 20, 36 } },
	father = { name = "Father", family = true, ageGap = { 21, 42 } },
	sibling = { name = "Sibling", family = true, ageGap = { -8, 8 } },
	child = { name = "Child", family = true, heir = true },
	friend = { name = "Friend" },
	mentor = { name = "Mentor" },
	rival = { name = "Rival" },
	-- (v0.12) someone you share a household with: one door, one rent, one table. Roblox-safe:
	-- a household on the District's register, never romance, and never another player.
	partner = { name = "Household partner", family = true },
	-- (v0.12) people you've met (Engine/People.luau): not friends yet
	acquaintance = { name = "Someone you've met" },
	-- (v0.13) someone you're teaching your trade (Events/Episodes_Legacy.luau)
	apprentice = { name = "Apprentice" },
}

-- who you run into, year to year (Engine/People.luau); a role's `when` says who meets whom
-- (v0.13) a household can be made a marriage: on by default; Config.marriage = false (or
-- on = false here) keeps households households. Never romance, never another player.
pack.marriage = { on = true, word = "Spouse" }

pack.acquaintances = {
	minAge = 6,
	chance = 0.35,
	cap = 6,
	drift = 4,
	roles = {
		{ text = "a neighbor from two floors down" },
		{ text = "a kid from the next building", when = { maxAge = 15 } },
		{ text = "a kid from your academy class", when = { maxAge = 17, flags = { "enrolled" } } },
		{ text = "the cook at the night stall on your corner", when = { minAge = 12 } },
		{ text = "a courier who is always in a hurry", when = { minAge = 14 } },
		{ text = "a Workshop apprentice with burn marks on both hands", when = { minAge = 14 } },
		{ text = "someone from the clinic queue", when = { minAge = 16 } },
		{ text = "a coworker", when = { anyCareer = true } },
		{ text = "a coworker who eats lunch alone", when = { anyCareer = true } },
		{ text = "a Grade 9 Fixer from the Office downstairs", when = { minAge = 18 } },
		{ text = "a regular at the corner diner", when = { minAge = 16 } },
		{ text = "a Nest clerk who takes the long way home", when = { minAge = 18, side = "nest" } },
		{ text = "a stall-keeper at the Overpass Market", when = { minAge = 12 } },
		{ text = "someone who also waits up until 4:34", when = { minAge = 16 } },
		{ text = "a tenant from the building across the street", when = { minAge = 18 } },
	},
}

pack.interactions = {
	order = { "spend_time", "say_hello", "ask_about", "befriend", "teach", "ask_help", "make_peace", "bury_hatchet", "spar_rival", "share_household", "hold_wedding", "end_household", "send_word" },
	spend_time = {
		name = "Spend time together",
		desc = "An evening with {rel}.",
		cooldown = 1,
		scenes = true, -- opens a scene with choices (Events/Scenes.luau), when there's one for them
		result = { bond = { 6, 12 }, sanity = { 1, 3 }, log = "You spent an evening with {rel}." },
		logs = {
			mother = "You walked your mother, {rel}, home before three, and she told you about the year the lights went out.",
			father = "You and your father, {rel}, fixed the door lock together. You checked it twice before the Night.",
			sibling = "You and {rel} shared a pot of noodles and argued about which Fixer office was the best.",
			child = "You took {rel} to watch the WARP trains cross the sky.",
			friend = "You and {rel} split a cheap meal at the corner diner and traded gossip from three Districts.",
			mentor = "{rel} walked you through an old job report and told you which parts were lies.",
			rival = "You and {rel} shared a table and an uneasy truce. It held for the evening.",
			partner = "You and {rel} cooked for two, and argued happily about whose turn it was to check the locks.",
			acquaintance = "You and {rel} ended up talking on the stairs until the lights went out on the landing.",
		},
	},
	-- (v0.12) people you've met: get to know them, and some become friends
	say_hello = {
		name = "Stop and talk",
		desc = "Ask {rel} how they are, and wait for the real answer.",
		kinds = { "acquaintance" },
		cooldown = 1,
		result = { bond = { 6, 10 }, sanity = { 0, 1 }, log = "You stopped to talk with {rel} for a while. It turns out you've got more in common than a street." },
	},
	ask_about = {
		name = "Ask about their life",
		desc = "Where {rel} is from, what they do, what they're afraid of. People talk if you listen well.",
		kinds = { "acquaintance" },
		cooldown = 1,
		clash = { stat = "charisma", foe = "Somebody's guard", coins = 2, base = 2, coinPower = 2 },
		win = { bond = { 10, 16 }, intelligence = { 0, 1 }, log = "{rel} told you more than they meant to, and seemed lighter for it." },
		lose = { bond = { -3, -1 }, log = "{rel} gave you polite answers to every question. You'll try again." },
	},
	befriend = {
		name = "Ask them to be friends",
		desc = "Say it out loud. {rel} might say yes.",
		kinds = { "acquaintance" },
		minBond = 45,
		cooldown = 1,
		result = { befriend = true, bond = { 6, 10 }, sanity = 2, log = "{rel} grinned. \"I thought we already were.\"" },
	},
	teach = {
		name = "Teach them something",
		desc = "Locks, numbers, the Fingers' rules. Teaching sharpens you too.",
		kinds = { "child", "sibling", "apprentice" },
		relMinAge = 5,
		relMaxAge = 17,
		minAge = 16,
		cooldown = 1,
		result = { bond = { 4, 8 }, intelligence = { 1, 2 }, log = "You taught {rel} the rules that keep you alive: be home before three, pay what the Fingers ask, and never say a Capo's name carelessly." },
	},
	ask_help = {
		name = "Ask for help",
		desc = "A little {currency} to get through the year. They'll remember it.",
		kinds = { "mother", "father", "sibling", "mentor" },
		minAge = 16,
		minBond = 55,
		cooldown = 3,
		result = { wage = { 25, 60 }, bond = { -6, -2 }, log = "{rel} pressed some {currency} into your hand and told you not to make a habit of it." },
	},
	make_peace = {
		name = "Make peace",
		desc = "Old grudges don't go quietly. Say the hard thing and see what happens.",
		linked = false,
		maxBond = 40,
		cooldown = 2,
		clash = { stat = "mind", foe = "Old grudges", coins = 2, base = 4, coinPower = 3 },
		win = { bond = { 14, 24 }, sanity = 2, log = "You and {rel} talked until the streetlights went off. Something mended." },
		lose = { bond = { -6, -2 }, sanity = -2, log = "It turned into the same old fight with {rel}." },
	},
	-- (v0.13) rivals: fight them properly once a year, or end it and make a friend of them
	bury_hatchet = {
		name = "Bury the hatchet",
		desc = "Buy {rel} a meal and say what neither of you has said: that the rivalry made you both better. They might laugh in your face.",
		kinds = { "rival" },
		linked = false,
		minAge = 14,
		cooldown = 3,
		clash = { stat = "charisma", foe = "Years of grudges", coins = 2, base = 4, coinPower = 3 },
		win = { reconcile = true, sanity = 4, bond = { 18, 28 }, log = "{rel} stared at you for a long time, then laughed, then ordered the most expensive thing on the menu. \"You're paying,\" they said. \"That's how I know you mean it.\"" },
		lose = { bond = { -6, -2 }, sanity = -2, log = "{rel} heard you out, then said they'd see you on the street. It didn't sound like a promise of anything good." },
	},
	spar_rival = {
		name = "Settle it in the yard",
		desc = "Not a street fight: a proper bout, at a training yard, with someone to call it. Win and your name goes up. Lose and theirs does.",
		kinds = { "rival" },
		linked = false,
		minAge = 14,
		cooldown = 1,
		clash = { stat = "strength", foe = "Your rival, at their best", coins = 3, base = 6, coinPower = 4 },
		win = { strength = { 1, 2 }, speed = 1, renown = { 2, 4 }, bond = { 2, 6 }, log = { "You put {rel} on the sand twice out of three. They shook your hand like it cost them something.", "The yard went quiet when you won. {rel} said \"Again next year,\" and meant it.", "{rel} lost and laughed about it, which annoyed you more than losing would have." } },
		lose = { health = { -6, -2 }, mind = 1, bond = { 1, 3 }, log = { "{rel} won, and didn't gloat, which was worse.", "You went down in the second bout and stayed down for a while. {rel} bought the ice for your shoulder." } },
	},
	-- (v0.13) a household made a marriage (pack.marriage below; Config.marriage switches it off)
	hold_wedding = {
		name = "Make it a marriage",
		desc = "Turn the household register into a marriage certificate: a small ceremony at the District office, family in their good coats, a long meal after. Ceremonies cost what they cost.",
		kinds = { "partner" },
		linked = false,
		minAge = 21,
		relMinAge = 21,
		minBond = 80,
		cost = 300,
		cooldown = 2,
		when = { notFlags = { "married" } },
		clash = { stat = "charisma", foe = "The biggest question there is", coins = 2, base = 3, coinPower = 2 },
		win = { marry = true, sanity = 10, bond = { 6, 10 }, log = "{rel} said yes, and then cried, and then made you promise the meal afterwards would have dumplings. It did. Everyone you know was there, in the good coats." },
		lose = { bond = { -2, 0 }, money = 150, log = "{rel} held your hands and said \"not yet, but ask again.\" The District office gave back half the fee." },
	},
	-- (v0.12) a household of your own (Events/Household.luau): only with someone the game made
	share_household = {
		name = "Ask them to share a household",
		desc = "Move in together and put both your names on the District's household register: one door, one rent, one table. It's a big ask.",
		kinds = { "friend" },
		linked = false,
		minAge = 20,
		relMinAge = 20,
		minBond = 70,
		cooldown = 3,
		when = { noRelation = { "partner" } },
		clash = { stat = "charisma", foe = "A very big question", coins = 2, base = 2, coinPower = 2 },
		win = { becomePartner = true, sanity = 6, bond = { 6, 10 }, log = "{rel} said yes before you'd finished asking. You signed the District's household register the next morning, both of you in your good coats." },
		lose = { bond = { -5, -2 }, log = "{rel} said not yet, kindly. \"Ask me again in a while,\" they said, and you will." },
	},
	end_household = {
		name = "End the household",
		desc = "Split the rent, divide the furniture and take your name off the register. It's allowed. It hurts.",
		kinds = { "partner" },
		linked = false,
		cooldown = 1,
		result = { endPartner = true, bond = { -30, -20 }, sanity = -6, log = "You took your name off the register. {rel} helped carry your boxes down the stairs, which was somehow worse." },
	},
	send_word = {
		name = "Send word",
		desc = "A note to {rel}, wherever their life has taken them.",
		linked = true,
		online = true,
		cooldown = 1,
		result = {
			bond = { 4, 8 },
			log = "You sent {rel} a note with a Devyat' courier who looked insulted by how small it was.",
			linked = { sanity = { 1, 3 }, log = "{sender} sent word by courier: a short note, folded twice." },
		},
	},
}

--[[
	ORIGINS: the family you're born into. `district` fixes where (else rolled or picked),
	`side` fixes Nest or Backstreets. glowCost > 0: unlocked with Light.
]]
pack.origins = {
	{
		id = "backstreets_family",
		weight = 30,
		name = "Backstreets Family",
		desc = "Two tired parents, a door with three locks, and a rule about being home before three.",
		birth = "You were born in {zone}, {district}, to two tired parents who checked the locks twice that night.",
		side = "backstreets",
		money = 15,
		family = { mother = true, father = true, siblings = { 0, 2 } },
		household = {
			owns = { "a three-lock flat on the fourth floor, rented by the month", "two rooms over a laundry, rented by the week, with the laundry's noise thrown in free" },
			jobs = {
				mother = { { "seamstress", "stitches Fixer coats at a piecework shop, sixty a week" }, { "noodle cook", "cooks at a noodle stall that shuts at half past two, sharp" }, { "post sorter", "sorts mail at the District post office and reads every return address" } },
				father = { { "dock hand", "hauls crates on the canal docks until his back says stop" }, { "locksmith", "fixes locks for half the block, and checks yours twice" }, { "cart driver", "drives a delivery cart and knows which streets are safe after dark" } },
			},
		},
		glowCost = 0,
	},
	{
		id = "single_parent",
		weight = 22,
		name = "Single Parent",
		desc = "One parent working double shifts at a diner that never closes before the Night.",
		birth = "You were born the night your mother finished a double shift, in {zone}.",
		money = 5,
		stats = { intelligence = 3 },
		charterBias = 0.5,
		family = { mother = true, siblings = { 0, 1 } },
		household = {
			owns = { "a one-room flat above the diner where your mother works", "a room with a curtain down the middle, rented from the diner's owner" },
			jobs = { mother = { { "diner cook", "works double shifts at a diner that never closes before the Night" }, { "diner cook", "runs the grill at the corner diner, sixteen hours a day" } } },
		},
		glowCost = 0,
	},
	{
		id = "street_orphan",
		weight = 9,
		name = "Alley Orphan",
		desc = "Nobody's child. Found on a doorstep in the Backstreets after a Night, somehow still there.",
		birth = "You were found on a doorstep in {district} after a Night, wrapped in a Fixer's coat. Nobody ever came for the coat, either.",
		side = "backstreets",
		money = 0,
		stats = { health = 4 },
		family = { siblings = { 0, 0 } },
		flags = { "foundling" },
		sanity = 4,
		glowCost = 0,
	},
	{
		id = "fixer_family",
		weight = 7,
		name = "Fixer's Kid",
		desc = "Born into a small Fixer office. You learned the word \"contract\" before \"please\".",
		birth = "You were born above a two-room Fixer office in {zone}. The sign on the door was older than your parents.",
		side = "backstreets",
		money = 30,
		stats = { strength = 5, health = 2 },
		family = { mother = true, father = true, siblings = { 0, 1 } },
		flags = { "fixer_blood", "knows_fixers" },
		household = {
			business = "office",
			owns = { "the {office} Office: a two-room Fixer Office in the Backstreets, with a licence on the wall and a sign older than your parents", "the {office} Office: two rooms above a cobbler's, a long coat on the hook, and contracts pinned to the door" },
			jobs = {
				mother = { { "Fixer, Grade 7", "runs the {office} Office and takes the contracts nobody else will" }, { "Fixer, Grade 6", "is the {office} Office's best Fixer, and on most nights its only one" } },
				father = { { "Fixer, Grade 8", "keeps the {office} Office's books, and a blade behind the door" }, { "retired Fixer", "was a Fixer until his knee went; now he answers the {office} Office's door" } },
			},
		},
		glowCost = 2,
	},
	{
		id = "nest_family",
		weight = 12,
		name = "Nest Family",
		desc = "Born inside the walls. Your parents are Feathers, and the Wing has plans for you too.",
		birth = "You were born inside the Nest of {district}, behind three checkpoints. The first thing you saw was a clean white ceiling.",
		side = "nest",
		money = 350,
		stats = { intelligence = 6, mind = 4 },
		family = { mother = true, father = true, siblings = { 0, 1 } },
		flags = { "nest_born", "knows_wings" },
		sanity = 18,
		household = {
			owns = { "a Nest flat with a lift, a window that opens, and a lease the Wing renews every spring" },
			jobs = {
				mother = { { "Feather", "is a Feather of the Wing: a badge, a desk and a salary" }, { "Feather", "audits the Wing's accounts and never brings the work home" } },
				father = { { "Feather", "is a Feather in the Wing's records office" }, { "Feather", "works security on the Nest gates, in a uniform with the Wing's mark" } },
			},
		},
		glowCost = 0, -- v0.8: anyone can be born rich (the roll decides)
	},
	{
		id = "lcorp_family",
		bornBefore = 978, -- an L Corp family needs an L Corp
		weight = 5,
		name = "L Corp Family",
		desc = "Born in District 12 to parents who work for Lobotomy Corporation. They never say what they do there.",
		birth = "You were born in District 12, in the light of the L Corp tower. Your parents came home late and never said why.",
		district = "d12",
		money = 120,
		stats = { mind = 5, intelligence = 3 },
		family = { mother = true, father = true, siblings = { 0, 1 } },
		flags = { "lcorp_family", "knows_lcorp" },
		household = {
			owns = { "a company flat in District 12, with the L Corp tower in the window" },
			jobs = {
				mother = { { "L Corp employee", "works for Lobotomy Corporation, and never says what she does there" } },
				father = { { "L Corp employee", "works nights for Lobotomy Corporation and comes home smelling of something clean" } },
			},
		},
		glowCost = 3,
	},
	{
		id = "smoke_war_family",
		bornBefore = 962, -- the war is a long time ago by then
		weight = 6,
		name = "Veteran's Child",
		desc = "Born in District 7 to a parent who fought in the Smoke War and won't talk about it.",
		birth = "You were born in District 7. Your father kept a uniform in a locked box and flinched at the sound of insects.",
		district = "d7",
		side = "backstreets",
		money = 20,
		stats = { health = 5, strength = 3 },
		family = { mother = true, father = true, siblings = { 0, 1 } },
		flags = { "smoke_war_family", "knows_wings" },
		household = {
			owns = { "a ground-floor flat in District 7 with the windows bricked halfway up" },
			jobs = {
				mother = { { "seamstress", "mends uniforms for the District watch and says nothing about the war" } },
				father = { { "veteran", "fought in the Smoke War and repairs radios now, with very steady hands" } },
			},
		},
		glowCost = 2,
	},
	{
		id = "s_corp_runaway",
		weight = 4,
		name = "Runaway from the Court",
		desc = "Born in District 19 to parents who fled the King's Court. The Ch'unokkun still have their names.",
		birth = "You were born in a shed at the edge of District 19, to parents who had just run from the Court. They kept the lamp low.",
		district = "d19",
		side = "backstreets",
		money = 0,
		stats = { strength = 4, health = 4 },
		family = { mother = true, father = true, siblings = { 0, 0 } },
		flags = { "runaway_family" },
		household = {
			owns = { "nothing on paper: a shed on the District 19 border, and your parents' real names, which they don't use" },
			jobs = {
				mother = { { "day labourer", "picked rice for the Court before she ran; now she takes any work that pays in cash" } },
				father = { { "porter", "carries loads for anyone who doesn't ask for papers" } },
			},
		},
		glowCost = 4,
	},
	{
		id = "hongyuan_family",
		weight = 6,
		name = "Hongyuan Family",
		desc = "Born in District 8, in a room the size of your family's fortune. It's a small room.",
		birth = "You were born in Hongyuan, in a room that shrank a little the year you came.",
		district = "d8",
		money = 40,
		stats = { intelligence = 4, mind = 3 },
		family = { mother = true, father = true, siblings = { 1, 2 } },
		flags = { "hongyuan_family" },
		household = {
			owns = { "a room in Hongyuan that grows and shrinks with the family's fortune. This year it's small" },
			jobs = {
				mother = { { "silk trader", "trades silk for one of the Four Families and counts every bolt twice" } },
				father = { { "ledger clerk", "keeps the accounts of a family much richer than his own" } },
			},
		},
		glowCost = 3,
	},
}

-- Raised by a Bloodfiend Family (unlock with Light, or the Bloodline pass in the store)
table.insert(pack.origins, {
	id = "bf_family_raised",
	weight = 2,
	name = "Raised by a Family",
	desc = "Left at the back door of a shuttered theater, and taken in by the red-eyed people inside. A Bloodfiend Family fed you, schooled you and kept you safe. At eighteen, they'll ask you one question.",
	birth = "You were left at the back door of a shuttered theater in {district}. The people who opened it had red eyes, and they took you in.",
	side = "backstreets",
	money = 40,
	stats = { mind = 3, strength = 2 },
	family = { siblings = { 0, 0 } },
	flags = { "bf_family_raised", "bf_knows", "knows_bloodfiends" },
	household = { owns = { "nothing of your own: the shuttered theater where the Family keeps its nights is home" } },
	glowCost = 5,
})

-- Families with a business of their own: what it is is on the Household card, and at
-- eighteen the business is yours to take over, sell or leave (Events/Life_Household.luau)
for _, o in {
	{
		id = "workshop_family",
		weight = 6,
		name = "Workshop Family",
		desc = "Born above a small weapon Workshop. The forge's heat came up through the floorboards all your childhood.",
		birth = "You were born above the {office} Workshop in {zone}, with the forge still warm under the floor.",
		side = "backstreets",
		money = 40,
		stats = { strength = 2, intelligence = 4 },
		family = { mother = true, father = true, siblings = { 0, 1 } },
		flags = { "workshop_family" },
		household = {
			business = "workshop",
			owns = { "the {office} Workshop: a forge, an anvil, and a maker's mark Fixers still ask for by name", "the {office} Workshop: a small forge that sells blades to Grade 8s and patches up Grade 6s" },
			jobs = {
				mother = { { "smith", "runs the {office} Workshop's forge and signs every blade herself" } },
				father = { { "Workshop clerk", "sells what the {office} Workshop makes, and haggles for both of them" } },
			},
		},
		glowCost = 0,
	},
	{
		id = "diner_family",
		weight = 7,
		name = "Noodle Shop Family",
		desc = "Your family owns a noodle shop: six stools, one pot, and a shutter that comes down at half past two.",
		birth = "You were born in the back room of {office} Noodles in {zone}. The broth was on before you were.",
		side = "backstreets",
		money = 25,
		stats = { charisma = 3, health = 2 },
		family = { mother = true, father = true, siblings = { 0, 2 } },
		flags = { "diner_family" },
		household = {
			business = "diner",
			owns = { "{office} Noodles: six stools, one pot, and a shutter that comes down at half past two, every night, without fail" },
			jobs = {
				mother = { { "noodle cook", "runs {office} Noodles and knows every regular's order" } },
				father = { { "broth cook", "makes the broth at {office} Noodles from a recipe he won't write down" } },
			},
		},
		glowCost = 0,
	},
	{
		id = "landlord_family",
		weight = 4,
		name = "Landlord's Kid",
		desc = "Your family owns the building: five floors of tenants, rent day on the first, and everybody's problems.",
		birth = "You were born on the top floor of your family's building in {zone}. Twenty flats below you, and every one of them owed rent.",
		side = "backstreets",
		money = 80,
		stats = { charisma = 2, intelligence = 2, mind = 2 },
		family = { mother = true, father = true, siblings = { 0, 1 } },
		flags = { "landlord_family" },
		household = {
			business = "landlord",
			owns = { "the whole building: five floors, twenty flats, a boiler that hates winter, and the rent book" },
			jobs = {
				mother = { { "landlady", "collects the rent on the first and argues about it on the second" } },
				father = { { "building super", "fixes everything in the building the rent doesn't cover" } },
			},
		},
		glowCost = 2,
	},
} do
	table.insert(pack.origins, o)
end

-- names for the family business ("the Lantern Office", "Lantern Noodles")
pack.officeNames = {
	"Lantern", "Brass Hinge", "Seven Locks", "Low Lamp", "Grey Heron", "Kettle", "Long Coat", "Iron Kite",
	"Ninth Hour", "Saltwork", "Crow's Bell", "Half Moon", "Copper Gate", "Red Thread", "Stone Step", "Night Owl",
	"Wren", "Cinder", "Old Pier", "Tall Window",
}

pack.activityCategories = {
	order = { "deeds", "turf", "cases", "play", "district", "city", "self", "money", "spend", "gear", "people", "home" },
	deeds = "Deeds: what a name can do",
	turf = "Turf: your streets",
	cases = "Cases: what you're working",
	spend = "Spend: markets, homes, hired help",
	play = "Growing up",
	district = "Only in your District",
	city = "The City",
	self = "Body & mind",
	money = "Money",
	gear = "Gear",
	people = "People",
	home = "Home",
}

-- The everyday activities. More live in Activities/ (merged below).
pack.activities = {
	{
		id = "today",
		category = "city",
		name = "Today in the City",
		desc = "Today's event: the same for everyone on every server, once a day.",
		minAge = 8,
		daily = true,
		result = { log = "You went out to see what the City had in store today." },
	},
	{
		id = "train",
		category = "self",
		name = "Train at a Fixer gym",
		desc = "Trade bruises with off-duty Fixers until something sticks.",
		minAge = 8,
		result = { strength = { 2, 4 }, health = { 0, 1 }, sanity = { -1, 0 }, log = "You spent your evenings at a Fixer gym, getting knocked down by people who do this for a living." },
	},
	{
		id = "run_rooftops",
		category = "self",
		name = "Run the rooftops",
		desc = "From the bathhouse roof to the water tower without touching the street. Trains Speed: more coins in a fight, and the first strike.",
		minAge = 9,
		result = { speed = { 2, 4 }, health = { 0, 1 }, log = "You ran the roofline until your legs shook. Twice you nearly didn't make a gap. You made both." },
	},
	{
		id = "work_the_room",
		category = "self",
		name = "Work the teahouse",
		desc = "Buy one cup, stay three hours, learn every name. Trains Charisma: better bonds, better prices, and talk that works.",
		minAge = 12,
		cost = 4,
		result = { charisma = { 2, 4 }, sanity = { 0, 2 }, log = "You stayed three hours on one cup of tea. By the end the owner was telling you about her son." },
	},
	{
		id = "shrine_coin",
		category = "self",
		name = "Leave a coin at the corner shrine",
		desc = "Nobody knows who it's for. Everyone leaves something. Luck is hard to change; this is one of the few things that might.",
		minAge = 8,
		cost = 12,
		cooldown = 2,
		result = { luck = { 0, 2 }, sanity = { 1, 2 }, log = "You left your coin with the others. On the way home, the rain stopped for exactly as long as your walk." },
	},
	{
		id = "drill_style",
		category = "self",
		name = "Drill your discipline",
		desc = "Practice until your {style} comes without thinking. Raises your mastery, as far as you have a teacher for.",
		minAge = 12,
		when = { hasStyle = true },
		cooldown = 1,
		cost = 20,
		result = { mastery = 1, health = { -1, 0 }, log = "You drilled the same moves a thousand times. Your {style} is getting sharper." },
	},
	-- schooling is a choice (Events/Life_Schooling.luau at six, or Enroll later): nobody is
	-- "at an academy" who never got into one
	{
		id = "study",
		category = "self",
		name = "Go to class",
		desc = "The academy that has your name on its roll: accounting, mechanics, the history of the Wings.",
		minAge = 6,
		when = { flags = { "enrolled" } },
		result = { intelligence = { 2, 4 }, mind = { 0, 1 }, log = "You sat through your classes until the bell rang for the walk home." },
	},
	{
		id = "enroll_academy",
		category = "self",
		name = "Enroll at an academy",
		desc = "Evening classes take anyone who pays the desk. The fee is yours to find.",
		minAge = 7,
		cost = 25,
		when = { notFlags = { "enrolled" } },
		result = { setFlags = { "enrolled" }, intelligence = { 1, 2 }, log = "You put your name on an academy's roll. Classes start at the bell." },
	},
	{
		id = "apprentice_work",
		category = "self",
		name = "Work your apprenticeship",
		desc = "Sweep, fetch, hold the light, and watch how it's done.",
		minAge = 6,
		maxAge = 17,
		when = { flags = { "apprenticed" } },
		result = { health = { 1, 2 }, strength = { 1, 2 }, wage = { 2, 6 }, log = "You swept the workshop floor and watched the smith's hands all day." },
	},
	{
		id = "street_school",
		category = "self",
		name = "Learn the street",
		desc = "Which alleys go through. Which doors open. Who to walk past quickly.",
		minAge = 6,
		maxAge = 17,
		when = { flags = { "street_taught" } },
		result = { mind = { 1, 2 }, speed = { 1, 2 }, log = "You learned two shortcuts and one face to stay away from." },
	},
	-- ── growing up (ages 2 to 13): small things a child can do with a year ──
	{ id = "play_stairwell", category = "play", name = "Play in the stairwell", desc = "Four floors of echo. Every kid in the building knows which step creaks.", minAge = 2, maxAge = 7,
		result = { speed = { 1, 2 }, health = { 0, 1 }, sanity = { 2, 4 }, log = "You raced the big kids up four flights and lost, and played on the stairs until somebody's mother called everyone in." } },
	{ id = "play_chalk", category = "play", name = "Draw with chalk", desc = "A stub of chalk and a wall nobody's watching.", minAge = 2, maxAge = 9,
		result = { intelligence = { 1, 2 }, sanity = { 2, 3 }, log = "You drew your whole street on a wall, with every window lit." } },
	{ id = "play_listen", category = "play", name = "Listen to the grown-ups", desc = "They forget you're under the table. You learn a lot under the table.", minAge = 3, maxAge = 10,
		result = { charisma = { 1, 2 }, mind = { 0, 1 }, log = "You sat under the table and listened to how grown-ups get what they want from each other. You didn't understand all of it. You kept it anyway." } },
	{ id = "home_evening", category = "play", family = true, name = "Stay in with your family", desc = "An evening with the people raising you.", minAge = 2, maxAge = 13,
		when = { hasRelation = { "mother", "father", "sibling" } },
		result = { sanity = { 2, 4 }, relationBond = { kind = "family", amount = 5 }, log = "You stayed in. Somebody told a story about before you were born." } },
	{ id = "kitchen_lessons", category = "play", name = "Lessons at the kitchen table", desc = "Letters and sums by lamplight, from whoever's home.", minAge = 4, maxAge = 10,
		when = { hasRelation = { "mother", "father" } },
		result = { intelligence = { 1, 3 }, relationBond = { kind = "family", amount = 3 }, log = "You did sums at the kitchen table until the numbers stopped swimming." } },
	{ id = "play_fixers", category = "play", name = "Play Fixers and Syndicates", desc = "Somebody has to be the Syndicate. Nobody wants to be the Syndicate.", minAge = 5, maxAge = 11,
		result = { strength = { 1, 2 }, speed = { 0, 1 }, sanity = { 1, 2 }, log = "You were a Grade 1 Fixer with a stick for a sword. You won, because you made the rules." } },
	{ id = "play_courtyard", category = "play", name = "Play in the courtyard", desc = "Trimmed hedges, a fountain, and a minder with a watch.", minAge = 4, maxAge = 12,
		when = { side = "nest" },
		result = { charisma = { 1, 2 }, sanity = { 1, 3 }, log = "You made up a game, talked six other children into its rules, and played in the courtyard until the minder's watch said stop." } },
	{ id = "watch_trains", category = "play", name = "Watch the trains", desc = "From the footbridge you can see the WARP trains leave. Nobody you know has seen one arrive.", minAge = 4, maxAge = 12,
		result = { mind = { 1, 2 }, sanity = { 1, 3 }, log = "You counted eleven trains from the footbridge and wondered where the people went." } },
	{ id = "collect_scrap", category = "play", icon = "cur.ahn", name = "Collect scrap", desc = "Bolts, wire, a cracked lens. The workshop on the corner pays by weight.", minAge = 6, maxAge = 13,
		result = { wage = { 2, 6 }, health = { 0, 1 }, mind = { 0, 1 }, log = "You filled a sack with scrap and sold it at the workshop door." } },
	{ id = "book_cart", category = "play", name = "Borrow from the book cart", desc = "An old man pushes a cart of water-stained books through the District. One Ahn to borrow, and he remembers faces.", minAge = 6, maxAge = 13, cost = 1,
		result = { intelligence = { 1, 3 }, mind = { 0, 1 }, log = "You read a borrowed book twice before the old man came back for it." } },
	{ id = "night_shutters", category = "play", name = "Watch the Night through the shutters", desc = "After three, the Sweepers come. You're supposed to be asleep.", minAge = 7, maxAge = 13, cooldown = 1,
		when = { side = "backstreets" },
		clash = { stat = "mind", foe = "The Night", coins = 1, base = 3, coinPower = 3 },
		win = { mind = { 2, 3 }, setFlags = { "knows_night" }, log = "You watched the whole first wave through the slats and didn't make a sound." },
		lose = { sanity = { -3, -2 }, setFlags = { "knows_night" }, log = "Something stopped under your window. You didn't look again, and you didn't sleep." } },
	{
		id = "quiet",
		category = "self",
		name = "Sit somewhere quiet",
		desc = "A rooftop, a closed shop, a bench away from the noise. Let your head settle.",
		minAge = 4,
		result = { mind = { 1, 3 }, sanity = { 2, 5 }, log = "You sat somewhere quiet until your head stopped buzzing." },
	},
	-- SHIN AND MANG: only after the second Light, and only for someone who's heard it can be done
	{
		id = "still_heart",
		category = "self",
		name = "Still your heart",
		desc = "Sit, breathe, and hold one feeling without letting it move. It takes years. This is how Shin begins.",
		icon = "stat.mind",
		minAge = 16,
		when = { world = { era = "limbus" }, flags = { "knows_shin" }, noTrait = "shin" },
		cooldown = 1,
		clash = { stat = "mind", foe = "Your own restless heart", coins = 2, base = 5, coinPower = 3, fixed = true },
		win = { addTrait = "shin", mind = 2, sanity = 4, chronicle = "learned_shin", schedule = { event = "shin_first_ring", inYears = 2 }, log = "One evening it simply held. You thought of the worst day of your life and your pulse didn't change. Shin." },
		lose = { mind = { 1, 2 }, sanity = 1, log = "Not this year. It's closer than it was." },
	},
	{
		id = "shape_mang_two",
		category = "self",
		name = "Shape a second ring",
		desc = "A second thing you want, or resent, or grieve, held as still as the first. The strain is nearly double.",
		icon = "stat.mind",
		minAge = 18,
		when = { world = { era = "limbus" }, trait = "mang_one", noTrait = "mang_two", min = { mind = 55 } },
		cooldown = 2,
		clash = { stat = "mind", foe = "Two rings at once", coins = 3, base = 5, coinPower = 3, fixed = true },
		win = { addTrait = "mang_two", mind = 2, sanity = -4, log = "Two rings. People step back from you in the street without knowing why." },
		lose = { sanity = { -10, -6 }, log = "The first ring shook loose trying to make room for the second. It took a week to put it back." },
	},
	{
		id = "shape_mang_three",
		category = "self",
		name = "Shape a third ring",
		desc = "Three rings is what a Color carries. Most minds that try this don't come back the same.",
		icon = "stat.mind",
		minAge = 20,
		when = { world = { era = "limbus" }, trait = "mang_two", noTrait = "mang_three", min = { mind = 75 } },
		cooldown = 3,
		clash = { stat = "mind", foe = "Three rings at once", coins = 3, base = 7, coinPower = 3, fixed = true },
		win = { addTrait = "mang_three", mind = 3, sanity = -8, log = "Three. The air around you hums. You understand now why the people who have this don't talk much." },
		lose = { sanity = { -18, -12 }, condition = "night_terrors", log = "You held three for the space of a breath, and then you held none, and then you were on the floor." },
	},
	{
		id = "clinic",
		category = "self",
		name = "Visit a clinic",
		desc = "Patch up whatever the year broke, and treat one injury or illness. Once a year: ampules aren't cheap, and the queue is long.",
		cost = 50,
		cooldown = 1,
		result = { health = { 8, 14 }, cure = "any", log = "A back-alley clinic patched you up and took your {currency}." },
	},
	{
		id = "workshop",
		category = "gear",
		name = "Visit a workshop",
		desc = "Weapons, coats and charms from the City's workshops. Gear changes your odds. Browsing is free.",
		minAge = 10,
		shop = true,
	},
	{
		id = "diner",
		category = "self",
		name = "Eat at a corner diner",
		desc = "Hot noodles, loud strangers, cheap comfort. Be gone before three.",
		minAge = 6,
		cost = 5,
		result = { sanity = { 2, 5 }, charisma = { 0, 1 }, log = "You ate hot noodles at a corner diner and laughed at a stranger's joke." },
	},
	{
		id = "odd_jobs",
		category = "money",
		name = "Take odd jobs",
		desc = "Deliveries, cleanup, carrying things up stairs. Richer Districts pay more.",
		minAge = 10,
		result = { health = { 1, 3 }, wage = { 6, 16 }, log = "You took odd jobs around the District for a few {currency}." },
	},
	{
		id = "double_shift",
		category = "money",
		name = "Work a double shift",
		desc = "More pay. Less of you.",
		when = { anyCareer = true },
		result = { paycheck = 0.35, health = { -4, -1 }, sanity = { -3, -1 }, log = "You worked double shifts until your hands stopped feeling like yours." },
	},
	{
		id = "visit_family",
		family = true,
		category = "people",
		name = "Visit family",
		desc = "Sit with the people who knew you small.",
		minAge = 14,
		when = { hasRelation = { "mother", "father", "sibling", "child" } },
		result = { sanity = { 1, 4 }, relationBond = { kind = "family", amount = 6 }, log = "You spent an evening with family. Nobody fixed anything, and it helped anyway." },
	},
	{
		id = "foundling_house",
		category = "people",
		name = "Visit the foundling house",
		desc = "Children the Night left behind. Maybe one of them is yours now.",
		minAge = 24,
		cost = 40,
		cooldown = 4,
		result = {
			addRelation = { kind = "child", age = { 3, 9 }, bond = 55 },
			sanity = 4,
			setFlags = { "parent" },
			log = "You brought {newRelation} home from the foundling house.",
		},
	},
	{
		id = "apply_nest",
		category = "home",
		name = "Apply for Nest residence",
		desc = "Checkpoints, paperwork and a fee. Inside the walls it's safer, cleaner and much more expensive.",
		minAge = 18,
		move = "charter",
		result = { sanity = 4, log = "Your Nest residence came through. The guards nodded at you this morning instead of searching you." },
	},
	{
		id = "leave_nest",
		category = "home",
		name = "Move out to the Backstreets",
		desc = "Cheaper, louder, and the Night comes every night.",
		minAge = 16,
		move = "gutters",
		result = { log = "You moved out to the Backstreets. The first night, you checked the locks four times." },
	},
	{
		id = "warp_move",
		category = "home",
		name = "Take the WARP train to another District",
		desc = "Across the City in seconds. Start over somewhere new.",
		minAge = 16,
		cost = 60,
		move = "district",
		result = { log = "You took the WARP train. It was over in a blink, and you felt a little older than the blink." },
	},
	-- with a linked friend (another player) who's online; {linked} names them
	{
		id = "shift_together",
		category = "people",
		name = "Work a shift with {linked}",
		desc = "Two pairs of hands on the same job. The boss pays you both.",
		minAge = 14,
		cooldown = 1,
		when = { linked = true },
		result = {
			wage = { 15, 35 },
			sanity = 1,
			log = "You and {linked} worked a shift side by side and split a bun at the end of it.",
			linked = { wage = { 15, 35 }, sanity = 1, log = "{sender} talked the boss into taking you both on for a shift." },
		},
	},
	{
		id = "train_together",
		category = "people",
		name = "Spar with {linked}",
		desc = "Sparring is better with someone who won't go easy on you.",
		minAge = 10,
		cooldown = 1,
		when = { linked = true },
		result = {
			health = { 1, 3 },
			strength = { 1, 2 },
			mastery = { 0, 1 },
			log = "You and {linked} sparred until your arms shook.",
			linked = { health = { 1, 3 }, strength = { 1, 2 }, log = "{sender} dragged you out to spar. You're sore and glad of it." },
		},
	},
	{
		id = "night_watch_together",
		category = "people",
		name = "Ride out the Night with {linked}",
		desc = "Same room, same locks, till the Sweepers pass. A friend adds a coin.",
		minAge = 12,
		cooldown = 2,
		when = { linked = true },
		clash = { stat = "mind", foe = "The Night", coins = 2, base = 4, coinPower = 3, assist = true },
		win = {
			sanity = { 3, 6 },
			log = "You and {linked} talked through the whole Night, till the three waves had passed.",
			linked = { sanity = { 3, 5 }, log = "{sender} kept you talking through the whole Night. It went faster." },
		},
		lose = {
			sanity = { -5, -2 },
			log = "Something scraped at the door during the second wave. Neither of you slept.",
			linked = { sanity = { -4, -1 }, log = "You and {sender} heard something at the door all through the second wave." },
		},
	},
}
for _, act in mergeLists("Activities") do
	table.insert(pack.activities, act)
end
-- BOOKS: found in receptions, expeditions and boss fights; reading one teaches an ability.
-- Each book you hold adds a "Read" activity.
pack.books = mergeOrdered("Books")
for _, id in pack.books.order do
	local b = pack.books[id]
	table.insert(pack.activities, {
		id = "read_" .. id,
		name = "Read: " .. b.name,
		desc = b.desc,
		category = "self",
		schools = b.schools,
		when = { hasBook = id },
		result = { readBook = id, sanity = 1, log = "You found a quiet corner and read " .. b.name .. " until the light went." },
	})
end

-- GEAR: one per slot. look.kind is drawn on the character.
pack.gear = mergeOrdered("Gear")
-- WEAPON ABILITIES: what each weapon does in a fight besides its numbers (Engine/Clash.luau).
-- A weapon tied to a style (gear.style) only does it for someone who fights in that style.
local WEAPON_ABILITIES = {
	-- the workshop's stock
	arm_dagger = { "bleed", 1 }, arm_twin_daggers = { "quick", 1 }, arm_cleaver = { "bleed", 1 }, arm_crowbar = { "tremor", 1 },
	arm_nail_bat = { "bleed", 1 }, arm_machete = { "bleed", 1 }, arm_wrench = { "tremor", 1 }, arm_rapier = { "poise", 1 },
	arm_saber = { "riposte", 2 }, arm_sword_cane = { "riposte", 1 }, arm_umbrella = { "guard", 1 }, arm_mace = { "crush", 1 },
	arm_flail = { "tremor", 2 }, arm_maul = { "crush", 1 }, arm_halberd = { "reach", 1 }, arm_glaive = { "reach", 1 },
	arm_scythe = { "bleed", 2 }, arm_trident = { "pierce", 1 }, arm_harpoon = { "pierce", 2 }, arm_staff = { "guard", 1 },
	arm_whip = { "reach", 1 }, arm_war_fan = { "riposte", 1 }, arm_crossbow = { "volley", 1 }, arm_scattergun = { "volley", 2 },
	arm_twin_pistols = { "volley", 2 }, arm_chainblade = { "bleed", 2 }, arm_drill = { "pierce", 2 }, arm_claws = { "bleed", 1 },
	arm_briefcase = { "guard", 1 },
	-- issued by the organisations that train with them
	arm_zwei_shield = { "guard", 2 }, arm_liu_gauntlets = { "burn", 2 }, arm_cinq_rapier = { "poise", 2 }, arm_dieci_key = { "sinking", 1 },
	arm_courier_trunk = { "guard", 1 }, arm_seven_cane = { "rupture", 2 }, arm_oufi_halberd = { "reach", 1 }, arm_index_blade = { "quick", 1 },
	arm_middle_chain = { "riposte", 2 }, arm_ring_brush = { "bleed", 2 }, arm_kurokumo_blade = { "bleed", 2 }, arm_wcorp_baton = { "charge", 2 },
	arm_rcorp_rifle = { "volley", 2 }, arm_kcorp_injector = { "drink", 2 }, arm_lcorp_baton = { "sinking", 1 }, arm_tuning_fork = { "tremor", 2 },
	arm_nail_hammer = { "pierce", 2 },
	-- the older stock and the loot
	workshop_knife = { "bleed", 1 }, baton = { "tremor", 1 }, workshop_hammer = { "crush", 1 }, atelier_pistol = { "volley", 2 },
	long_blade = { "riposte", 1 }, mechanical_fist = { "crush", 1 }, quake_hammer = { "tremor", 2 }, crack_spear = { "reach", 1 },
	bleeding_knives = { "bleed", 2 }, pyrojade_gauntlet = { "burn", 2 }, drowned_censer = { "sinking", 2 }, steady_katana = { "poise", 2 },
	capacitor_baton = { "charge", 2 }, fx_old_boys_hammer = { "crush", 1 }, fx_mook_blade = { "bleed", 1 }, fn_thumb_pistol = { "volley", 2 },
	fc_capo_revolver = { "volley", 3 }, fc_shi_needle = { "quick", 1 }, lc_ego_penitence = { "guard", 1 }, lc_ego_lament = { "volley", 2 },
	lc_ego_justitia = { "pierce", 2 }, bl_verdict = { "riposte", 2 }, bl_courtesy = { "volley", 3 }, bl_black_cloud = { "quick", 1 },
	bl_prescript = { "pierce", 2 }, bl_grudgebearer = { "crush", 1 }, bl_lullaby = { "guard", 2 }, bl_penance = { "drink", 3 },
	bl_stormgut = { "crush", 1 }, bl_hoofbeat = { "reach", 1 }, bl_pointille = { "pierce", 1 }, bl_snuffer = { "drink", 3 },
}
for id, a in WEAPON_ABILITIES do
	local g = pack.gear[id]
	if g then
		g.ability = g.ability or { id = a[1], potency = a[2] }
	end
end
for _, id in pack.gear.order do
	local g = pack.gear[id]
	local a = g and g.ability
	local def = a and pack.abilities and pack.abilities[a.id]
	if def then
		local line = string.format("In a fight: %s%s. %s", def.name, if (a.potency or 1) > 1 then " " .. tostring(a.potency) else "", def.desc)
		g.effect = if g.effect and g.effect ~= "" then g.effect .. " " .. line else line
	end
end
pack.gear.slots = { "tool", "coat", "charm", "arm" } -- (v0.17) arm: augment arms (Gear/Augments.luau)
-- (v0.13) two or three pieces of one Workshop's line: GearSets.luau
pack.gear.sets = require(script:WaitForChild("GearSets"))

-- CONDITIONS: injuries and worse. Treated at a clinic (`cure`), or they fade.
pack.conditions = {}
for _, child in sortedModules("Conditions") do
	for id, def in require(child) do
		if pack.conditions[id] ~= nil then
			table.insert(pack.mergeIssues, string.format("Conditions/%s: duplicate id '%s'", child.Name, id))
		else
			pack.conditions[id] = def
		end
	end
end

pack.clash = {
	coinsEvery = 32,
	maxCoins = 4,
	-- (v0.17) Speed past every limit: a fifth coin at 200, a sixth at 350
	extraCoinsAt = { 200, 350 },
	baseEvery = 22,
	powerEvery = 50,
	-- the City sends worse at you as you get older: foes gain +1 base at 25, +2 at 37,
	-- +3 from 49 (a clash with `fixed = true` opts out). Keeps adult danger real.
	foeGrowth = { fromAge = 16, everyYears = 6, maxBase = 8 }, -- (v0.15) faster, and higher
	-- you pick which stat to fight with (pack.approaches), so foes in a fight get +1 base
	fightBase = 1,
	-- the stronger your name, the stronger who comes for you: +1 base per 3 Fixer grades
	gradeGrowth = { every = 3 },
}
-- The City is deadly: every Health loss lands this much harder (talents and armor with
-- `toughness` soften it).
pack.lethality = 1.9 -- adults: every Health loss hits 90% harder (v0.15: was 1.7)
-- (v0.15) the City's danger by age: cards tagged "danger" come this much more often from
-- these ages on. The years from twenty to forty-five are when people in the City die.
pack.dangerByAge = { { from = 18, mult = 1.25 }, { from = 24, mult = 1.5 }, { from = 46, mult = 1.25 } }
pack.youthLethality = 1.05 -- under 18: the City is gentler with children, a little
-- (v0.18) HARDER EVENTS (Engine/Sim.luau: clashSides, eventWeight, rollDread). Every clash on
-- an event card is stronger (cardBase), a dangerous card's more so (dangerBase, and one more
-- coin in a fight), and a dangerous card grows with you: +1 base for every `every` points of
-- the stat you face it with past `from` (up to `max`). Dangerous cards come more often, and in
-- some years the City sends one more on top (dread), most often in the years people die.
pack.hardness = {
	fromAge = 14,
	cardBase = 1,
	dangerBase = 2,
	dangerCoins = 1,
	match = { from = 50, every = 35, max = 5 },
	dangerWeight = 1.5,
	dreadWeight = 2.5,
	dread = { fromAge = 16, chance = 0.22, byAge = { { from = 24, chance = 0.32 }, { from = 46, chance = 0.26 } }, focusMult = 0.5 },
}
-- (v0.18) THE HARDER THE RUN, THE RICHER THE HAUL (Engine/Expedition.luau). A run's tier is the
-- strongest clash in it (base + coins 9 / 11 / 13 / 14 for tier II to V; a boss battle is tier
-- V). A success pays its result times `money` (Ahn and wages), `stats` and `renown`, plus `bonus`.
pack.expeditionPay = {
	tiers = { 9, 11, 13, 14 },
	[2] = { money = 1.5, stats = 1.25, renown = 1.25 },
	[3] = { money = 2.5, stats = 1.5, renown = 1.75, bonus = { money = { 1200, 2800 }, renown = 8 } },
	[4] = { money = 4, stats = 2, renown = 2.5, bonus = { money = { 4000, 9000 }, renown = 20, limitBreakFight = 2 } },
	[5] = { money = 6, stats = 3, renown = 3.5, bonus = { money = { 12000, 26000 }, renown = 45, limitBreakFight = 5 } },
}
-- (v0.18) FOCUS (Engine/Focus.luau): the card that starts a thread is what the next years are
-- about; its follow-ups come in order, without a crowd of unrelated cards around them
pack.focus = {
	years = 3, -- how long a focus holds after its last card
	boost = 6, -- its cards come this much more often
	others = 0.5, -- and everything else this much less
	minTopic = 4, -- a subject (a codex entry) needs this many cards to hold a life's attention
	topics = { lib_ = true }, -- whole families of ids that are one subject
	names = { lib_ = "The Library" },
}
pack.childHazard = 0.5 -- under 12: yearly bad luck is half as likely

-- HOW YOU FIGHT. A fight is fought with one of your stats: that stat sets how hard your coins
-- hit (Speed always sets how many you have). Every foe has a TEMPER, and each way of fighting
-- is strong against one temper and poor against another (pack.matchup: +2 / -2 base):
--     Overpower (Strength) breaks the Cunning.   The Quick slip it.
--     Outpace (Speed) runs rings round Brutes.   The Cunning see it coming.
--     Outthink (Intelligence) reads the Quick.   A Brute doesn't care.
-- `gain` scales what a win gives, `loss` what a loss takes; `foeHeads` spoils their coins.
pack.tempers = {
	order = { "brute", "quick", "cunning" },
	brute = { name = "Brute", desc = "Heavy and slow.", weakTo = "speed", strongTo = "wits", color = { 214, 96, 72 } },
	quick = { name = "Quick", desc = "Fast and light.", weakTo = "wits", strongTo = "power", color = { 96, 200, 210 } },
	cunning = { name = "Cunning", desc = "Has a plan.", weakTo = "power", strongTo = "speed", color = { 150, 130, 230 } },
}
pack.matchup = { bonus = 2, penalty = 2 }
pack.approaches = {
	order = { "power", "speed", "wits", "talk", "ego", "volatile" },
	power = {
		name = "Overpower",
		short = "Wins +25%",
		desc = "Fight with Strength. Wins pay a quarter more.",
		stat = "strength",
		fightOnly = true,
		beats = "cunning",
		loses = "quick",
		gain = 1.25,
	},
	speed = {
		name = "Outpace",
		short = "Losses -40%",
		desc = "Fight with Speed. A loss costs you less.",
		stat = "speed",
		fightOnly = true,
		beats = "brute",
		loses = "cunning",
		loss = 0.6,
	},
	wits = {
		name = "Outthink",
		short = "Their coins -10%",
		desc = "Fight with Intelligence. Their coins land worse.",
		stat = "intelligence",
		fightOnly = true,
		beats = "quick",
		loses = "brute",
		foeHeads = -10,
	},
	talk = {
		name = "Talk down",
		short = "No blood",
		desc = "Fight with Charisma. People only. Win, and nobody holds it against you.",
		stat = "charisma",
		fightOnly = true,
		only = "person",
		bloodless = true,
	},
	-- E.G.O is let out, and paid for in Sanity: 14, less 1 for every 8 Mental Strength (never
	-- under 3). Only in a real fight, and only for someone who has manifested it.
	ego = {
		name = "E.G.O",
		short = "Let it out.",
		desc = "Fight with Mental Strength: +1 coin, +2 power, +1 a heads. Costs Sanity: the stronger your mind, the less.",
		stat = "mind",
		fightOnly = true,
		requires = { form = "ego" },
		clash = { coins = 1, base = 2, coinPower = 1 },
		sanityCost = { base = 14, per = 8, min = 3 },
		costLog = "Letting your E.G.O out took something from you.",
		color = { 255, 214, 120 },
	},
	-- a volatile E.G.O hits as hard and costs far more; run out of Sanity and she comes back
	volatile = {
		name = "Volatile E.G.O",
		short = "Let it burn.",
		desc = "Fight with Mental Strength: +2 power, +2 a heads. Costs a lot of Sanity, and a loss hits half again as hard.",
		stat = "mind",
		fightOnly = true,
		requires = { trait = "ego_volatile", form = "human" },
		clash = { base = 2, coinPower = 2 },
		loss = 1.5,
		sanityCost = { base = 22, per = 8, min = 8 },
		costLog = "It burned on the way out. It always does.",
		color = { 255, 150, 90 },
	},
	-- BLOOD ARTS: a Bloodfiend shapes its own blood into a weapon (canon: Hardblood). Paid in
	-- Health before the first clash lands, and drunk back with every clash won.
	hardblood = {
		name = "Hardblood",
		short = "-6 HP · drink",
		desc = "Shape your blood into a blade and fight with Strength: +2 power, +1 a heads, and every heads makes them Bleed. Costs 6 Health. Every clash you win, you drink 4 back, even past your maximum.",
		stat = "strength",
		fightOnly = true,
		requires = { form = "bloodfiend" },
		clash = { base = 2, coinPower = 1 },
		healthCost = 6,
		abilities = { { id = "bleed", potency = 2 }, { id = "drink", potency = 4 } },
		costLog = "The blade you fought with was your own blood.",
		color = { 200, 40, 52 },
	},
	crimson_lance = {
		name = "Crimson Lance",
		short = "-4 HP · pierce",
		desc = "Harden your blood into a lance and fight with Speed: it reaches past their guard (Pierce 2) and you strike first sooner (Quick). Costs 4 Health; every clash you win, you drink 2 back.",
		stat = "speed",
		fightOnly = true,
		requires = { form = "bloodfiend" },
		clash = { base = 1 },
		healthCost = 4,
		abilities = { { id = "pierce", potency = 2 }, { id = "quick", potency = 1 }, { id = "drink", potency = 2 } },
		costLog = "The lance went back into your veins, most of it.",
		color = { 160, 20, 40 },
	},
}
pack.approaches.order = { "power", "speed", "wits", "talk", "ego", "volatile", "hardblood", "crimson_lance" }
-- (v0.17) TECHNIQUES: ways of fighting a teacher gives you or an augment arm carries
-- (City/Techniques.luau), and the teachers themselves (City/Trainers.luau, Engine/Training.luau)
do
	local techniques = require(script:WaitForChild("Techniques"))
	for _, id in techniques.order do
		pack.approaches[id] = techniques[id]
		table.insert(pack.approaches.order, id)
	end
end
pack.trainers = require(script:WaitForChild("Trainers"))

-- ABILITIES in a fight: what each is called on the screen (Engine/Clash.luau has the rules)
pack.abilities = {
	guard = { name = "Guard", desc = "The first clash you lose costs you no coin." },
	riposte = { name = "Riposte", desc = "Lose a clash with heads in it, and they hit weaker next clash." },
	crush = { name = "Crush", desc = "The first clash you win knocks off a second coin." },
	reach = { name = "Reach", desc = "Their first clash can't take a coin from you." },
	volley = { name = "Volley", desc = "Your first clash: every heads hits much harder." },
	quick = { name = "Quick", desc = "You strike first even when you're only a little faster." },
	drink = { name = "Drink", desc = "Every clash you win, you drink: Health back after the fight, even past your maximum." },
	pierce = { name = "Pierce", desc = "Their base power counts for less: armor doesn't help them." },
	bleed = { name = "Bleed", desc = "Your heads make them Bleed: they lose power whenever they hit." },
	burn = { name = "Burn", desc = "Your heads set them burning: they lose power every clash." },
	tremor = { name = "Tremor", desc = "Your heads shake them; shake them enough and a coin comes loose." },
	rupture = { name = "Rupture", desc = "Your heads crack their guard: your next hits land harder." },
	sinking = { name = "Sinking", desc = "Your heads drag them down: their coins land heads less." },
	poise = { name = "Poise", desc = "Your heads build Poise: heads that may count twice." },
	charge = { name = "Charge", desc = "You build Charge every clash, and spend it in one big hit." },
}

-- RENOWN (Engine/Renown.luau): what the City says about you. Its ranks are Hana's own grades
-- for a threat to the City; a person can earn them as surely as a monster can. Each rank's
-- perks hold while you hold it; the high ones are news on the whole server.
pack.renown = {
	minAge = 16, perCoin = 3, floor = 8, -- a won fight: 3 per foe coin + its base - 8
	none = "Nobody yet",
	noneDesc = "Nobody outside your building knows your name. That can change.",
	ranks = {
		{ name = "Known on Your Street", at = 15, desc = "People on your street know your name, and what you do.", line = "Your street knows your name now. Kids say it when they play.", color = { 180, 170, 150 } },
		{ name = "A Name in the District", at = 50, desc = "Shopkeepers stand up straighter. Rats find other alleys. Jobs pay 5% more.", line = "{district} knows your name. Shopkeepers stand up straighter when you come in.", perks = { pay = 0.05 }, color = { 200, 180, 120 } },
		{ name = "Urban Myth", at = 120, desc = "Hana has opened a file on you: the lowest grade it gives anything worth watching. +10 most Health; jobs pay 10% more; every stat can go 5 past 100.", line = "A Hana clerk has opened a file in your name. You're an Urban Myth: something the City has started to talk about.", perks = { maxHealth = 10, pay = 0.1, cap = 5 }, announce = "Hana has graded {name} of {district} an Urban Myth.", color = { 150, 190, 200 } },
		{ name = "Urban Legend", at = 260, desc = "Fixers tell stories about you on slow nights. +20 most Health; jobs pay 15% more; stats can go 10 past 100.", line = "Fixers tell stories about you on slow nights, and some of them are true. Hana grades you an Urban Legend.", perks = { maxHealth = 20, pay = 0.15, cap = 10 }, announce = "{name} of {district} is an Urban Legend now. Hana has posted the grade on every board.", color = { 120, 200, 160 } },
		{ name = "Urban Plague", at = 460, desc = "Syndicates plan around you. Offices bid for you. +30 most Health; jobs pay 20% more; stats can go 15 past 100.", line = "Syndicates plan around you now, and Offices bid for your time. Hana grades you an Urban Plague: a problem a District has to think about.", perks = { maxHealth = 30, pay = 0.2, cap = 15 }, announce = "Hana has raised {name}'s grade: an Urban Plague. Every Syndicate in {district} has had a meeting about it.", color = { 200, 150, 90 } },
		{ name = "Urban Nightmare", at = 740, desc = "Wings take an interest. Associations send someone to watch. +45 most Health; jobs pay 30% more; stats can go 20 past 100.", line = "A Wing has a file on you as thick as Hana's. You're an Urban Nightmare: the kind of name that changes a District just by living in it.", perks = { maxHealth = 45, pay = 0.3, cap = 20 }, announce = "{name} of {district}: Urban Nightmare. The Associations have sent someone to watch.", color = { 210, 110, 90 } },
		{ name = "Star of the City", at = 1150, desc = "There are a handful of these alive. You're one. +60 most Health; jobs pay 40% more; stats can go 30 past 100.", line = "There are a handful of people the whole City knows by name. You're one of them now: a Star of the City.", perks = { maxHealth = 60, pay = 0.4, cap = 30 }, announce = "The City has a new Star: {name} of {district}.", color = { 255, 214, 120 } },
		{ name = "Impurity", at = 1800, desc = "Hana's last grade: a danger to the City itself. Wings hold meetings about you, and the Head may be listening. +80 most Health; jobs pay 50% more; stats can go 40 past 100.", line = "Hana's last grade, the one it gives to things that could change the City: Impurity. The Wings hold meetings about you. Somewhere very high up, something is listening.", perks = { maxHealth = 80, pay = 0.5, cap = 40 }, announce = "Hana has graded {name} of {district} an Impurity. Nobody on the boards is saying anything else today.", color = { 230, 80, 120 } },
	},
}

-- MARKETS AND HOMES (Engine/Market.luau): stock and prices that change with the City
do
	local m = require(script:WaitForChild("Markets"))
	pack.markets = m.markets
	pack.homes = m.homes
end

-- AN OFFICE OF YOUR OWN (Engine/Renown.luau): its size is its rank. It pays by the year.
pack.offices = {
	sizes = {
		{ name = "a one-person Office", desc = "One licence on the wall, one desk, one Fixer: you.", income = 90, renown = 2 },
		{ name = "a small Office", desc = "Three Fixers and a back room. Clients come back.", income = 220, renown = 3 },
		{ name = "a known Office", desc = "Eight Fixers, two floors, and a name that gets you past a checkpoint.", income = 480, renown = 5 },
		{ name = "a big Office", desc = "Twenty Fixers and a waiting list. Syndicates negotiate instead of threatening.", income = 950, renown = 8 },
		{ name = "a great Office of the City", desc = "Fifty Fixers, branches in three Districts, and a seat when Hana calls the Offices together.", income = 1900, renown = 14 },
	},
	-- (v0.18) running it yourself (Engine/Office.luau): your name on the sign, your people on
	-- the roster, a bigger building, rooms that make you stronger, a lab
	hireAge = 18,
	hireBond = 40, -- friends and family who'd follow you
	hireBondMet = 55, -- someone you've only met needs to trust you more
	colors = {
		{ id = "brass", name = "Brass", color = { 214, 170, 90 } },
		{ id = "crimson", name = "Crimson", color = { 206, 64, 64 } },
		{ id = "night", name = "Night blue", color = { 80, 112, 196 } },
		{ id = "jade", name = "Jade", color = { 70, 176, 124 } },
		{ id = "ash", name = "Ash", color = { 176, 176, 182 } },
		{ id = "violet", name = "Violet", color = { 156, 96, 210 } },
		{ id = "amber", name = "Amber", color = { 238, 150, 52 } },
		{ id = "bone", name = "Bone white", color = { 232, 226, 212 } },
	},
	-- Hana's grades: 9 is new, 1 is the best there is. A wage a year, and contracts brought in.
	grades = {
		[1] = { wage = 850, earn = 1500 },
		[2] = { wage = 620, earn = 1100 },
		[3] = { wage = 460, earn = 820 },
		[4] = { wage = 340, earn = 600 },
		[5] = { wage = 250, earn = 440 },
		[6] = { wage = 180, earn = 320 },
		[7] = { wage = 130, earn = 230 },
		[8] = { wage = 90, earn = 160 },
		[9] = { wage = 60, earn = 110 },
	},
	buildings = {
		{ id = "room", name = "a rented room", desc = "One room over a noodle shop, the licence on the wall.", price = 0, crew = 2, income = 1.0 },
		{ id = "storefront", name = "a storefront", desc = "A street door with your name on the glass, a waiting bench and a back room.", price = 12000, crew = 5, income = 1.25 },
		{ id = "floor", name = "a whole floor", desc = "A floor of an old block: desks, a briefing room, space to grow into.", price = 45000, crew = 10, income = 1.5, minSize = 2 },
		{ id = "block", name = "a building of your own", desc = "Five storeys with your sign on the roof. Clients wait in the lobby now.", price = 160000, crew = 20, income = 1.9, minSize = 3 },
		{ id = "tower", name = "a tower by the Nest", desc = "Glass and steel at the edge of the Nest, a guard at the door and a view of every District.", price = 600000, crew = 40, income = 2.5, minSize = 4, minRenown = 5 },
	},
	rooms = {
		{ id = "training", name = "Training room", desc = "Mats, a heavy bag, a rack of practice weapons. Every year: +2 to your best fighting stat, and your Fixers' grades rise faster.", price = 8000, building = 2 },
		{ id = "infirmary", name = "Infirmary", desc = "A cot, a medic on call, a cabinet that's always stocked. Every year: heal 15 Health.", price = 10000, building = 2 },
		{ id = "archive", name = "Archive", desc = "Every case the Office ever took, filed and cross-referenced. Every year: +1 Intelligence, and contracts pay 10% more.", price = 15000, building = 3 },
		{ id = "armory", name = "Armory", desc = "Racks of maintained gear for everyone on the roster. +1 base in every fight.", price = 18000, building = 3 },
		{ id = "lab", name = "Lab", desc = "A Workshop bench, augment test rigs and whatever the last client left behind. Run experiments: a chance at strength nobody sells.", price = 30000, building = 3 },
		{ id = "vault", name = "Vault", desc = "A real safe for real money. Every year: 4% on what you hold, up to 3,000 Ahn.", price = 40000, building = 4 },
	},
	-- the lab: an action and the materials, for one of these
	experiment = {
		cost = 2000,
		outcomes = {
			{ id = "breakthrough", weight = 12, tone = "good", text = "The prototype held under full load. You're stronger than the numbers said you could be: {stat} up.", stat = 4, limitBreak = 5 },
			{ id = "boost", weight = 30, tone = "good", text = "The rig did what the notes promised: {stat} up.", stat = { 2, 4 } },
			{ id = "patent", weight = 16, tone = "good", text = "It works, and a Workshop wants it. They paid well for the drawings.", money = { 2500, 6500 } },
			{ id = "nothing", weight = 26, text = "The readings made no sense. The notes say: try again." },
			{ id = "accident", weight = 16, tone = "bad", text = "The rig kicked back hard. You'll feel it for a week.", health = { -22, -8 }, sanity = -3 },
		},
	},
}

-- COMPASS REGIONS: Associations and Fingers run regional branches (North, South, East, West),
-- each with its own customs. This pack's map: District 12, where the Library stood, is in the
-- South (canon: the Associations met there are South Sections).
pack.directions = function(n: number): string
	if n <= 6 then
		return "North"
	elseif n <= 13 then
		return "South"
	elseif n <= 19 then
		return "East"
	end
	return "West"
end

-- HARD YEARS (Engine/Body.luau, Events/Crises.luau): every life is given one crisis age in each
-- band. That year the City turns on it: every fight is harder, bad luck likelier, and the
-- year opens with its trial.
pack.crisisAges = { { 14, 17 }, { 19, 28 }, { 30, 44 }, { 46, 62 } }
pack.crises = {
	{ id = "turf_war", name = "A Turf War", short = "Two Syndicates want your District.", text = "Two Syndicates want {district}, and this is the year they settle it. Every fight is harder; the streets are worse.", trial = "cr_turf", foeBase = 2, hazard = 1.6, weight = 12, color = { 200, 70, 60 } },
	{ id = "collection", name = "The Collection Year", short = "The Thumb is collecting everything.", text = "The Thumb has declared a Collection Year in {district}. Every debt is called in at once.", trial = "cr_collection", foeBase = 2, hazard = 1.4, weight = 10, when = { minAge = 16 }, color = { 180, 140, 70 } },
	{ id = "winter", name = "A Hard Winter", short = "Cold, coal and coughs.", text = "The worst winter in years. Coal triples in price, and the clinic is full.", trial = "cr_winter", foeBase = 1, hazard = 1.8, weight = 10, color = { 120, 160, 210 } },
	{ id = "contract", name = "A Contract on Your Name", short = "Someone paid to have you killed.", text = "Somebody has paid an Office to end you this year.", trial = "cr_contract", foeBase = 2, hazard = 1.5, weight = 8, when = { minAge = 19 }, color = { 210, 60, 60 } },
	{ id = "sweep", name = "The Wing Sweeps the Wall", short = "The Wing is clearing the blocks by the Nest.", text = "The Wing is clearing the Backstreets against its wall, door by door.", trial = "cr_sweep", foeBase = 2, hazard = 1.5, weight = 8, when = { side = "backstreets", minAge = 16 }, color = { 160, 170, 190 } },
	{ id = "distortions", name = "The Year of Distortions", short = "Minds are breaking all over the District.", text = "A bad year for minds in {district}: people are turning, street by street.", trial = "cr_distortions", foeBase = 2, hazard = 1.6, weight = 10, when = { world = { era = { "library", "limbus" } }, minAge = 14 }, color = { 170, 70, 140 } },
	{ id = "long_nights", name = "The Nights Run Long", short = "The Sweepers come early and stay late.", text = "Something is wrong with the Night this year. The Sweepers come early, stay late, and try doors.", trial = "cr_long_night", foeBase = 1, hazard = 1.7, weight = 9, color = { 90, 100, 150 } },
	{ id = "debts", name = "Everything Comes Due", short = "Every debt at once.", text = "Rent, loans and favours: everything comes due at once.", trial = "cr_debts", foeBase = 1, hazard = 1.4, weight = 8, when = { minAge = 24 }, color = { 200, 170, 90 } },
	{ id = "old_enemy", name = "An Old Enemy", short = "Someone you crossed has come back richer.", text = "Someone you crossed long ago has come back with money and a plan.", trial = "cr_old_enemy", foeBase = 2, hazard = 1.4, weight = 8, when = { minAge = 36 }, color = { 150, 90, 90 } },
}

-- HEALTH past 100: a body the City has hardened holds more (Engine/Body.luau)
-- (v0.17) LONG LIVES (Engine/Body.luau lifespan): what you are sets how long a body lasts
-- (forms[].lifespan), and it can be pushed back: K Corp treatments and Workshop bodies (the
-- `lifespan` effect), a body hardened past its limits (every 10 maximum Health past 100 is a
-- year), and a Color's name. A body wears from 13 years before its lifespan, and hard from
-- 2 years after; past it, every year is a chance.
pack.longLife = {
	perMaxHealth = 0.1,
	maxFromHealth = 60,
	maxBonus = 90, -- treatments and bodies add at most this many years
	color = 20,
	wearFrom = 13,
	hardFrom = 2,
}
-- (v0.17) OLD BLOOD: a Bloodfiend's blood grows stronger with its years as a Bloodfiend.
-- Each stage breaks limits, adds to what the blood can do, and is said aloud.
pack.elderBlood = {
	{ years = 25, name = "Old Blood", limitBreak = { strength = 15, speed = 15, mind = 10 }, stats = { strength = 6, speed = 6 }, maxHealth = 15, log = "Twenty-five years of the Thirst. Your blood moves differently now: slower to spill, quicker to harden. The young ones in the Family have started calling you old, carefully." },
	{ years = 50, name = "Deep Blood", limitBreak = { strength = 20, speed = 20, mind = 15, charisma = 10 }, stats = { strength = 8, speed = 8, mind = 4 }, maxHealth = 20, log = "Half a century. Your Hardblood holds a shape for an hour now if you ask it to. Hunters who come for you have started bringing more friends." },
	{ years = 80, name = "Elder Blood", limitBreak = { strength = 25, speed = 25, mind = 20, charisma = 15 }, stats = { strength = 10, speed = 10, mind = 6 }, maxHealth = 25, log = "Eighty years. Your blood is old enough to lead a Family, if you wanted one. Kindred lower their eyes when you come into a room, and mean it." },
	{ years = 120, name = "Ancient Blood", limitBreak = { all = 25 }, stats = { strength = 12, speed = 12, mind = 8, intelligence = 6 }, maxHealth = 30, log = "A hundred and twenty years. You have outlived the street you were turned on, the District's borders, two of its Syndicates. Your blood remembers all of it." },
	{ years = 180, name = "Blood of Ages", limitBreak = { all = 30 }, stats = { strength = 14, speed = 14, mind = 10, intelligence = 8 }, maxHealth = 40, log = "A hundred and eighty years. Elders come to ask you how it was done, once. Your blood answers before you do." },
	{ years = 260, name = "Undying Blood", limitBreak = { all = 40 }, stats = { strength = 18, speed = 18, mind = 12, intelligence = 10 }, maxHealth = 50, log = "Two hundred and sixty years. Families tell their fledglings about you the way people tell children about the Night: a thing that is real, and old, and best left alone." },
}

pack.vitalMax = {
	base = 100,
	strengthFrom = 50, perStrength = 0.6, -- Strength 100: +30
	perGrade = 7, -- each Fixer grade above 9: Grade 1 is +56, a Color +63
	forms = { bloodfiend = 60, ego = 20 },
}

-- FIGHTING STYLES (fights only): every heads you land builds your style's status.
pack.styles = {
	order = { "tremor", "rupture", "bleed", "burn", "sinking", "poise", "charge" },
	tremor = { name = "Tremor", desc = "Every blow shakes them. Shake them enough and they stagger: Tremor Burst knocks a coin out of their hands.", color = { 214, 180, 92 } },
	rupture = { name = "Rupture", desc = "Crack their guard open. Every hit after lands harder.", color = { 96, 200, 170 } },
	bleed = { name = "Bleed", desc = "Make every move cost them. They lose power each time they act.", color = { 214, 64, 64 } },
	burn = { name = "Burn", desc = "Set them alight. They lose power every round it burns.", color = { 238, 120, 44 } },
	sinking = { name = "Sinking", desc = "Drown their nerve. Their coins come up heads less and less.", color = { 92, 120, 220 } },
	poise = { name = "Poise", desc = "Breathe, and wait for the opening. Your heads can crit and count twice.", color = { 140, 210, 240 } },
	charge = { name = "Charge", desc = "Build power round by round, then let it all out in one discharge.", color = { 120, 200, 255 } },
}
pack.maxMastery = 5
-- SCHOOLS: every way of fighting belongs to the organisation that trains it (Schools.luau).
-- Outside that organisation a discipline stops at mastery 2.
pack.schools = require(script:WaitForChild("Schools"))
pack.outsideMastery = 2
pack.build = { points = 10, maxPer = 5, perPoint = 2 }
pack.traitPicks = 2
-- v0.8: nobody is born with a fighting style. You find it (events, mostly 12-18; modes that
-- start at 18 hand you one). Builds and trait picks are gone from the creator.
pack.styleAtBirth = false
-- v0.8 difficulty: children grow slower, and every stat slows down past 60
pack.childGrowth = 0.6
pack.activityGrowth = 0.75 -- four things a year instead of three: each teaches a little less
pack.slowFrom = 60
pack.slowScale = 0.7
pack.creatorPicks = false
-- where you live matters: an event that only happens in your District is this much likelier
pack.districtEventBoost = 2.5
-- v0.8: how many random events a year, by age (on top of story beats and follow-ups).
-- n = 2.5 means 2, plus a 50% chance of a third.
-- fewer cards from nowhere: a year is mostly what you chose to do with it, your story, and
-- your work (it was 2.5 a year)
pack.eventsPerYear = { { upTo = 0, n = 0 }, { upTo = 3, n = 1 }, { upTo = 59, n = 1.4 }, { upTo = 999, n = 1.2 } }
-- Talents: every life is born with one, by rarity (Traits/Talents.luau). The odds are real
-- and shown to the player; rerolls cost Lunacy.
-- AFFINITIES: the seven sins. Nobody picks theirs: two are dealt at birth (affinityRoll).
-- A talent that matches one of your sins resonates: +3% heads in every clash. A family's sins
-- lean the next child's talent the same way (3x as likely within whatever rarity is rolled).
pack.affinities = {
	order = { "wrath", "lust", "sloth", "gluttony", "gloom", "pride", "envy" },
	wrath = { name = "Wrath", color = { 214, 52, 44 }, desc = "Anger that hits first. Fight talents." },
	lust = { name = "Lust", color = { 236, 120, 34 }, desc = "Want, burning hot. Drive, mastery, growth." },
	sloth = { name = "Sloth", color = { 232, 190, 46 }, desc = "Patience that looks like rest. Luck and calm." },
	gluttony = { name = "Gluttony", color = { 150, 196, 64 }, desc = "Take it all in. Toughness and endurance." },
	gloom = { name = "Gloom", color = { 62, 166, 220 }, desc = "Sorrow that sees clearly. Mental Strength and Sanity." },
	pride = { name = "Pride", color = { 66, 96, 210 }, desc = "Excellence, and knowing it. Growth and every clash." },
	envy = { name = "Envy", color = { 150, 86, 214 }, desc = "Want what they have. Luck, money, stolen tricks." },
}
pack.affinityResonance = 3
pack.affinityRoll = 2
pack.talents = {
	tiers = {
		-- how rare the gift is, in the City's own words
		{ id = "common", name = "Ordinary", weight = 52, color = { 190, 190, 196 } },
		{ id = "uncommon", name = "Promising", weight = 26, color = { 120, 200, 140 } },
		{ id = "rare", name = "Gifted", weight = 13, color = { 100, 160, 240 } },
		{ id = "epic", name = "Prodigy", weight = 6.5, color = { 180, 110, 240 } },
		{ id = "legendary", name = "One in a District", weight = 2.2, color = { 255, 196, 80 } },
		{ id = "unreal", name = "One in the City", weight = 0.3, color = { 255, 70, 90 } },
	},
}
-- (v0.12) YEAR MOODS (Engine/Mood.luau): a year can have a theme of its own, which tilts what
-- happens in it and colours its card. A hard year (pack.crises) is its own theme instead.
pack.yearMoods = {
	chance = 0.5,
	list = {
		{ id = "strangers", name = "The Year of Strangers", text = "New faces everywhere this year.", tags = { people = 2.0, backstreets = 1.4 }, meet = true, minAge = 8, color = { 120, 190, 230 } },
		{ id = "work", name = "A Year of Work", text = "Work found you this year, all of it at once.", tags = { work = 2.0, fixers = 1.4, wing = 1.3 }, minAge = 16, color = { 214, 170, 90 } },
		{ id = "loud", name = "A Loud Year in the Streets", text = "The streets were loud this year, and they didn't quiet down at night.", tags = { danger = 1.5, crime = 1.6, fingers = 1.4, backstreets = 1.3 }, minAge = 12, color = { 214, 92, 78 } },
		{ id = "quiet", name = "A Quiet Year", text = "A quiet year, which in the City is a kind of luck.", tags = { danger = 0.55, crime = 0.6, home = 1.8 }, sanity = 3, color = { 140, 200, 150 } },
		{ id = "strange", name = "A Strange Year", text = "Things didn't add up this year, and nobody would say why.", tags = { strange = 2.4, secret = 1.8, night = 1.4, distortion = 1.3 }, minAge = 8, color = { 170, 120, 230 } },
		{ id = "news", name = "A Year of Big News", text = "The whole City was talking this year: the Wings, the towers, the trains.", tags = { wing = 1.6, lcorp = 1.4, limbus = 1.4, library = 1.4, warp = 1.5 }, minAge = 10, color = { 200, 200, 220 } },
		{ id = "lucky", name = "A Lucky Year", text = "Luck leaned your way this year, for once.", lucky = 2.2, color = { 255, 214, 120 } },
		{ id = "lessons", name = "A Year of Lessons", text = "You learned a great deal this year, some of it on purpose.", tags = { study = 2.2, school = 2.2, research = 1.8 }, minAge = 6, maxAge = 30, color = { 110, 170, 240 } },
		{ id = "nights", name = "A Year of Long Nights", text = "The Nights felt longer this year. Everyone said so.", tags = { night = 2.2, danger = 1.2 }, minAge = 8, color = { 124, 118, 214 } },
	},
}
-- last year's themes come up less this year (never a dangerous card: the City stays the City)
pack.tagFatigue = { after = 2, mult = 0.7, floor = 0.45, skip = { "danger", "crime", "night", "distortion" } }

-- (v0.12) A GIFT THAT WAKES (Engine/Talent.luau): a Gifted talent or better sleeps until a
-- rolled age. Prodigies unlock things at different ages: an early gift brings an academy
-- scholarship, an on-time one an Office that wants you at eighteen, a late one Hana's notice.
pack.talentWake = {
	tiers = { "rare", "epic", "legendary", "unreal" },
	scoutTiers = { "epic", "legendary", "unreal" },
	bands = {
		{ id = "early", name = "early in childhood", min = 4, max = 7, weight = 30, line = "It showed itself early, before you had words for it." },
		{ id = "ontime", name = "around twelve", min = 9, max = 13, weight = 45, line = "It woke the same year everything else started changing too." },
		{ id = "late", name = "late, as a near-adult", min = 15, max = 22, weight = 25, line = "It took its time. Everyone had stopped expecting anything of you." },
	},
	event = "tal_wakes",
	scouts = {
		early = { event = "tal_scout_academy", inYears = 2 },
		ontime = { event = "tal_scout_office", inYears = 2 },
		late = { event = "tal_scout_hana", inYears = 1 },
	},
}

-- (v0.9: no preset builds. What a life can do comes from where it has been.)
pack.traits = mergeOrdered("Traits")

-- LORE: the Archive. Entries live in Lore/ (merged here).
pack.codex = {
	categories = {
		{ id = "city", name = "The City" },
		{ id = "districts", name = "Districts and Wings" },
		{ id = "fingers", name = "The Fingers and Syndicates" },
		{ id = "fixers", name = "Fixers and Associations" },
		{ id = "lobotomy", name = "Lobotomy Corporation" },
		{ id = "abnormalities", name = "Abnormalities" },
		{ id = "library", name = "The Library" },
		{ id = "limbus", name = "Limbus Company" },
		{ id = "bloodfiends", name = "Bloodfiends" },
		{ id = "terms", name = "Words of the City" },
	},
	entries = {},
}
pack.codex.entries = mergeLists("Lore")

-- THE CHRONICLE: deeds that go out to the whole server. Acts live in Chronicle/.
pack.chronicle = {}
for _, child in sortedModules("Chronicle") do
	for act, def in require(child) do
		if pack.chronicle[act] ~= nil then
			table.insert(pack.mergeIssues, string.format("Chronicle/%s: duplicate act '%s'", child.Name, act))
		else
			pack.chronicle[act] = def
		end
	end
end

pack.daily = mergeOrdered("Daily")
pack.surnames = require(script:WaitForChild("Surnames"))
-- GAME MODES: how a life starts. Some skip childhood. `unlock`: a record, a store pass or
-- Light (any one opens it).
pack.modes = {
	{
		id = "city",
		name = "A Life in the City",
		tagline = "From the cradle to the end.",
		desc = "Be born in the Backstreets or a Nest, grow up, and make a life. Every choice is yours.",
		color = { 207, 163, 73 },
	},
	{
		id = "fixer",
		-- (v0.18) off the start menu and the lobby: every life starts from birth or as its own
		-- story (L Corp Agent, Kindred). Kept for old saves and the tests (Config.devModes).
		hidden = true,
		name = "Fixer's Road",
		tagline = "Start at 18 with a license and a borrowed coat.",
		desc = "Skip childhood. You passed Hana's licensing exam last week: Grade 9, the bottom of the scale, signed to a small Office that fights the way its Rep does.",
		color = { 214, 96, 88 },
		start = { age = 18, career = "fixer", stats = { strength = 16, speed = 18, health = 12, mind = 12, intelligence = 10, charisma = 14 }, money = 60, mastery = 1, log = "You're eighteen, licensed, and broke. A small Fixer Office took a chance on you." },
	},
	{
		id = "agent",
		name = "L Corp Agent",
		tagline = "The age of L Corp. Face the fear.",
		desc = "Only in the Age of L Corp: born around 942 and hired at 18 by Lobotomy Corporation. Abnormalities, Ordeals, E.G.O gear from the things you contain, and a long climb to Branch Manager.",
		color = { 110, 255, 140 },
		era = "wings",
		start = { age = 18, career = "lcorp_agent", stats = { mind = 18, health = 12, intelligence = 14, strength = 10, speed = 14, charisma = 14 }, money = 40, log = "Orientation day. They hand you a suit, a badge, and a manual that says Face the Fear, Build the Future." },
	},
	{
		id = "kindred",
		name = "Kindred",
		tagline = "A Bloodfiend from the first night.",
		desc = "Start at 18 as a newly made Bloodfiend of the Morvaine Family: Hardblood, the Thirst, Hemobars and hunters.",
		color = { 214, 32, 44 },
		unlock = { record = "bf_rec_kindred", pass = "pass_bloodline", light = 8 },
		unlockText = "Become a Bloodfiend in any life, get the Bloodline pass, or spend 8 Light.",
		start = {
			age = 18,
			form = "bloodfiend",
			traits = { "bf_hardblood" },
			career = "bf_family",
			flags = { "bf_turned", "bf_knows", "knows_bloodfiends" },
			stats = { strength = 16, speed = 20, health = 14, mind = 12, intelligence = 10, charisma = 16 },
			money = 60,
			log = "Livia of the Morvaine Family made you Kindred last night. Everything smells of iron. There's a Hemobar on the table, and a note: never go to bed thirsty.",
		},
	},
}
-- RANKINGS: the Fixers board. Each Fixer career's ranks map to a Fixer grade (1 = Grade 9,
-- 9 = Grade 1); an Association's Sections sit from about Grade 7 up; a Color is 10.
do
	local office = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
	local sections = { 3, 4, 5, 6, 7, 8, 9 }
	local careers = { fixer = office, hana = { 6, 7, 8, 9, 9 } }
	for _, id in { "zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi" } do
		careers[id] = sections
	end
	pack.rankings = { fixer = { careers = careers, colorFlag = "color_fixer" } }
end
-- DIFFICULTY: picked before a life starts (the start screen), and it can't be changed after.
pack.difficulties = {
	order = { "story", "city", "night" },
	default = "city",
	story = {
		name = "A Gentler City",
		desc = "For learning the City. Wounds land softer, bad years come less often, and what you meet is a little weaker.",
		lethality = 0.7,
		foeBase = -1,
		hazard = 0.6,
		hardness = 0.34, -- (v0.18) the harder cards are only a little harder here
		score = 0.7,
		color = { 120, 200, 140 },
	},
	city = {
		name = "The City",
		desc = "As it is. People die young here, and it's usually something they chose.",
		lethality = 1,
		foeBase = 0,
		hazard = 1,
		score = 1,
		color = { 207, 163, 73 },
	},
	night = {
		name = "The Backstreets at Night",
		desc = "Every wound lands harder, everything you meet is stronger, and bad luck knows your address. Life scores count for more.",
		lethality = 1.3,
		foeBase = 1,
		hazard = 1.35,
		hardness = 1.34, -- (v0.18) and the harder cards harder still
		score = 1.4,
		color = { 214, 64, 64 },
	},
}
-- REPUTATION: how every power in the City regards you (Reputation.luau, Events/Reprisals.luau)
pack.jobs = require(script:WaitForChild("Jobs"))
pack.reputation = require(script:WaitForChild("Reputation"))
-- the two tutorial lessons that are about this pack's own stats (client/App.luau)
pack.tutorial = {
	stats = {
		title = "Your stats",
		text = "Health is your body. The rest are what you do things with. Every 20 points is a tier with a perk, and your highest stat is your nature. Hover any of them to see what it's doing for you.",
	},
	fights = {
		title = "Fights and checks",
		text = "A check tests one stat: the card shows the odds. In a fight you pick which stat to fight with. Every foe has a temper, and one way of fighting beats it.",
	},
}
pack.store = require(script:WaitForChild("Store"))
pack.factions = require(script:WaitForChild("Factions"))
pack.guide = require(script:WaitForChild("Guide"))
-- THE INTRO: the join cinematic (client/UI/Intro.luau). cold = the clock running out at 3:13;
-- cards = the montage, each on its own camera shot (client/BackdropCity.luau SHOTS).
pack.intro = {
	cold = {
		place = "District 23  ·  The Backstreets",
		from = "03:12:55",
		to = "03:13:00",
		stamp = "The Night in the Backstreets",
		line = "Lock the door. Don't answer it.",
	},
	cards = {
		{ word = "Wings", line = "A Wing owns your District. You can see its tower from anywhere.", shot = "nest", scene = "wing", emblem = "faction.wings", color = { 237, 196, 114 } },
		{ word = "Fixers", line = "Grade Nine pays the rent. Grade One gets a color and a funeral.", shot = "alley", scene = "office", emblem = "faction.fixers", color = { 226, 86, 76 } },
		{ word = "The Fingers", line = "The Thumb wants manners. The Middle wants payback. The Index already wrote your name.", shot = "fingers", scene = "hall", emblem = "faction.fingers", color = { 190, 120, 255 } },
		{ word = "Lobotomy Corp.", line = "District 12 never runs out of power. Don't ask what they burn.", shot = "lcorp", scene = "lcorp", emblem = "faction.lcorp", color = { 110, 255, 140 } },
		{ word = "Bloodfiends", line = "They invite you in politely. Leaving is the hard part.", shot = "night", scene = "theater", emblem = "faction.bloodfiend", color = { 214, 32, 44 } },
		{ word = "You", line = "An alley or behind the wall. The City picks where. You pick the rest.", shot = "city", scene = "home", emblem = "logo", color = { 243, 238, 226 } },
	},
	-- older clients: plain narration
	lines = {
		"Twenty-six Districts. A Wing owns each one.",
		"Inside the walls, the Nests. Outside, the Backstreets.",
		"At 3:13 the Sweepers come. Be home.",
		"You're about to be born.",
	},
	title = "A Life in the City",
	subtitle = "Be home before 3:13.",
}

-- RECORDS: achievements a life can earn. Lists in Records/, merged here.
pack.records = mergeLists("Records")

-- Expeditions, quests: folders of { order, [id] } modules.
pack.expeditions = mergeOrdered("Expeditions")
pack.quests = mergeOrdered("Quests")
pack.worldEvents = mergeOrdered("WorldEvents")
pack.ambitions = mergeLists("Ambitions")
-- Titles are checked top to bottom and the first that passes wins; the last one (no check)
-- catches everything. Titles from other modules go just before the catch-all, or before
-- the title named in `before`.
do
	local list = {}
	for _, child in sortedModules("Ribbons") do
		for _, r in require(child) do
			local at = nil
			if r.before then
				for i, other in list do
					if other.id == r.before then
						at = i
						break
					end
				end
			end
			if not at and #list > 0 and list[#list].check == nil and child.Name ~= "Core" then
				at = #list
			end
			r.before = nil
			if at then
				table.insert(list, at, r)
			else
				table.insert(list, r)
			end
		end
	end
	pack.ribbons = list
end
pack.cosmetics = require(script:WaitForChild("Cosmetics"))
pack.hazards = require(script:WaitForChild("Hazards"))
pack.statuses = {
	tremor = { name = "Tremor", color = { 214, 180, 92 } },
	rupture = { name = "Rupture", color = { 96, 200, 170 } },
	bleed = { name = "Bleed", color = { 214, 64, 64 } },
	burn = { name = "Burn", color = { 238, 120, 44 } },
	sinking = { name = "Sinking", color = { 92, 120, 220 } },
	poise = { name = "Poise", color = { 140, 210, 240 } },
	charge = { name = "Charge", color = { 120, 200, 255 } },
}

pack.names = {
	first = {
		"Yuri", "Hana", "Dong-hwan", "Mirae", "Jin", "Sora", "Kaya", "Lev", "Anya", "Matvey",
		"Nadia", "Oskar", "Petra", "Renata", "Sergei", "Talia", "Viktor", "Wen", "Xiao", "Yejin",
		"Ines", "Mateo", "Lucia", "Bruno", "Clara", "Dario", "Elena", "Fabio", "Greta", "Hugo",
		"Iris", "Jonas", "Klara", "Leon", "Mila", "Nico", "Olga", "Pavel", "Rosa", "Stefan",
		"Tomas", "Ulla", "Vera", "Wim", "Yara", "Zeno", "Akira", "Emi", "Haru", "Kenji",
	},
	last = {
		"Kim", "Park", "Han", "Seo", "Moon", "Ivanova", "Petrov", "Volkov", "Rossi", "Bianchi",
		"Weber", "Fischer", "Novak", "Horvat", "Chen", "Li", "Wang", "Mori", "Sato", "Takeda",
		"Castillo", "Moreno", "Dubois", "Laurent", "Lindqvist", "Berg", "Kowalski", "Nowak", "Ortega", "Vance",
	},
}

pack.epitaphs = {
	generic = {
		"{first} was home before three, every night but one.",
		"{first} owed nobody anything, in the end.",
		"Somewhere in the Backstreets, a door {first} fixed still locks.",
		"{first} kept a light on for somebody.",
		"Filed, shelved, remembered.",
	},
	career = {
		fixer = { "{first} closed one last contract.", "A Fixer's coat, hung up for good." },
		thumb = { "{first} knew their place, and kept it.", "Respect was paid in full." },
		middle = { "The Middle remembers {first}.", "{first}'s debts are settled. All of them." },
		lcorp_agent = { "{first} clocked out.", "Remember us." },
		lcorp_research = { "{first} measured everything except the cost.", "The data outlived {first}." },
	},
	form = {
		distorted = { "Something the City sent Fixers after. Once, {first}." },
		ego = { "{first} looked into the dark and brought something back." },
	},
}

-- ENDINGS that leave no body: how each is worded on the end screen (lines, tips), in its
-- epitaph, and in the news (phrase). `match`: words in the cause. `noBody`: no wound report.
pack.endings = {
	{
		id = "book",
		match = { "became a book", "became books" },
		noBody = true,
		phrase = "became a book in the Library",
		short = "a book in the Library",
		lines = { "You signed the invitation, and the reception went against you. Guests who lose become books: you are on a shelf in the Library now, every page of you. Whatever you kept at home goes to whoever is left." },
		tips = {
			"Nobody is made to sign. An invitation can be burned, or kept in a drawer, and it changes nothing until there's a name on the line.",
			"A reception is a real fight against Librarians. The card shows the odds before you sign.",
		},
		epitaphs = {
			"{first} is on a shelf in the Library. Somebody may read them yet.",
			"Very well written, people say. You could tell it was {first} from the first page.",
			"{first} signed. It's a thick book.",
		},
	},
	{
		id = "erased",
		match = { "erased" },
		noBody = true,
		phrase = "was erased by the Head",
		short = "erased",
		lines = { "The Head's Claws leave nothing behind: no body, no record, sometimes not even a name on the lease. A few people remember you. They don't say so." },
		tips = { "The Head's few laws, the Taboos, are absolute. A card that touches one says so; the only safe answer is to have nothing to do with it." },
		epitaphs = { "There was someone called {first}. The records don't agree.", "Nobody remembers {first} quite right. That is how the Head works." },
	},
	{
		id = "swept",
		match = { "swept away", "taken by the night", "by the sweepers" },
		noBody = true,
		phrase = "was taken by the Night",
		short = "taken by the Night",
		lines = { "You were outdoors when the Night came. The Sweepers clean the streets of everyone still on them, and nobody sees those people again." },
		tips = { "Be indoors by 3:13. A choice that keeps you out late says so." },
		epitaphs = { "{first} was out after 3:13.", "The street was very clean the next morning." },
	},
	{
		id = "distorted",
		match = { "distorted", "became a distortion" },
		noBody = true,
		phrase = "became a Distortion",
		short = "Distorted",
		epitaphs = { "What {first} became is still out there, somewhere. It isn't {first}.", "{first} took the hand that was held out." },
	},
}
-- what happened to someone you lost, when "died" is the wrong word (killRelation = { kind, fate })
pack.relationFates = {
	book = { short = "a book in the Library", line = "Your {label}, {first}, is a book in the Library now." },
	erased = { short = "erased", line = "Your {label}, {first}, was erased. The neighbours have stopped saying the name." },
	swept = { short = "taken by the Night", line = "Your {label}, {first}, was out after 3:13. Nobody came home." },
}

pack.deathCauses = {
	wounds = "Their body gave out",
	walkedAway = "Walked out of this life",
	oldAge = {
		"Died in their sleep, old and tired, the locks all checked",
		"Fell asleep by the window, watching the WARP trains go by",
		"Went quietly, with the kettle still warm",
		"Died in their chair, halfway through a story about the old days",
		"Went to sleep after the Night and didn't wake, the kindest way there is",
		"Died old, in their own bed, with the rent paid",
	},
}

pack.hooks = {
	-- after the Light a mind at the bottom Distorts or finds E.G.O; before it, it just gives
	-- (the first whose `when` fits: a Bloodfiend's Thirst, an E.G.O that holds, a volatile
	-- E.G.O that cracks, the voice, and before the Light, nothing with a name)
	breakingPoint = { "core_breaking_point_thirst", "ego_holds", "carmen_returns", "core_breaking_point", "core_breaking_point_old" },
}

-- Events: every module in Events/.
pack.events = mergeLists("Events", true)

-- (v0.13) EPISODES (Episodes.luau): one-time set pieces told over several cards
pack.episodes = require(script:WaitForChild("Episodes"))
-- (v0.13) the long game: turf wars (Turf.luau), cases (Cases.luau), feats (Feats.luau) and the
-- phases of a life (Phases.luau). Engine: Engine/Turf.luau, Engine/Cases.luau, Engine/Feats.luau.
pack.turf = require(script:WaitForChild("Turf"))
pack.cases = require(script:WaitForChild("Cases"))
pack.feats = require(script:WaitForChild("Feats"))
pack.phases = require(script:WaitForChild("Phases"))
-- every open case is worked from the DO tab, a clue at a time, and finished there once its
-- last clue is in (so a finale that goes badly can be tried again)
for _, id in pack.cases.order do
	local c = pack.cases[id]
	local statWord = (pack.stats[c.stat] and pack.stats[c.stat].name) or c.stat
	table.insert(pack.activities, {
		id = "work_" .. id,
		category = "cases",
		name = "Work the case: " .. c.name,
		desc = c.desc .. " Each clue takes " .. statWord .. ".",
		minAge = 16,
		cooldown = 1,
		icon = "stat." .. (if c.stat == "mind" then "mind" else c.stat),
		caseId = id,
		when = { flags = { "case_open_" .. id }, notFlags = { "case_ready_" .. id } },
		clash = { stat = c.stat, foe = c.foe or "A cold trail", coins = c.coins or 2, base = c.base or 4, coinPower = c.coinPower or 3 },
		win = { caseClue = id, [c.stat] = 1, log = { "You found the next thread, and pulled it.", "A long day, a short answer, and a clue.", "Somebody finally talked." } },
		lose = { sanity = -2, log = { "The trail went cold for a while.", "A whole year of doors, and none of them opened.", "You chased the wrong lead to the wrong District." } },
	})
	table.insert(pack.activities, {
		id = "finish_" .. id,
		category = "cases",
		name = "Close the case: " .. c.name,
		desc = "Every clue is in. Go and finish it.",
		minAge = 16,
		cooldown = 1,
		icon = "misc.fight",
		when = { flags = { "case_open_" .. id, "case_ready_" .. id } },
		result = { trigger = c.finale, log = "You went to finish it." },
	})
end

-- (v0.13) WAYS IN (Entrances.luau): a place is found in the world, not picked from a menu.
-- Every expedition with an entrance gets a one-time card that finds it: go in now (no action
-- spent: the descent plays out as cards), remember the way (it joins Places you know on the
-- DO tab), or leave it be.
do
	local entrances = require(script:WaitForChild("Entrances"))
	for _, id in pack.expeditions.order or {} do
		local ex = pack.expeditions[id]
		local en = entrances[id] or ex.entrance
		if ex and en then
			local when = {}
			for k, v in ex.when or {} do
				when[k] = v
			end
			for k, v in en.when or {} do
				when[k] = v
			end
			when.minAge = math.max(ex.minAge or 0, (en.when and en.when.minAge) or 0)
			if when.minAge == 0 then
				when.minAge = nil
			end
			table.insert(pack.events, {
				id = "ex_in_" .. id,
				title = en.title,
				text = en.text,
				weight = en.weight or 5,
				once = true,
				tags = en.tags or { "strange" },
				theme = "delve",
				art = en.art,
				source = "Entrances",
				when = when,
				choices = {
					{ label = en.go or "Go in now", hint = "Straight in, this year. It costs no action.", result = { expedition = id, log = en.goLog or "You went in." } },
					{ label = en.later or "Remember the way, and come back", hint = "It joins Places you know (DO tab).", result = { setFlags = { "found_" .. id }, log = en.laterLog or "You marked the way in, and went home the long way." } },
					{ label = en.leave or "Leave it be", result = { sanity = 1, log = en.leaveLog or "Some doors are better left shut. You told yourself that all the way home." } },
				},
			})
		end
	end
end

--[[
	v0.8: how scenes look and who is in them.
	SCENES: the illustration at the top of an event card (`art = "alley"` on an event).
	Events without one get it from a word in their title or text, else from their file.
]]
pack.scenes = {
	"home", "alley", "street", "rooftop", "night", "nest", "checkpoint", "wing", "lcorp", "office", "workshop",
	"diner", "clinic", "school", "train", "syndicate", "hall", "library", "outskirts", "ruins", "market", "arena",
	"theater", "distortion", "underpass", "bus",
}
local ART_WORDS = {
	{ "diner", "diner" }, { "clinic", "clinic" }, { "stitcher", "clinic" }, { "workshop", "workshop" },
	{ "warp", "train" }, { "train", "train" }, { "rooftop", "rooftop" }, { "roof", "rooftop" },
	{ "checkpoint", "checkpoint" }, { "library", "library" }, { "outskirts", "outskirts" }, { "market", "market" },
	{ "academy", "school" }, { "school", "school" }, { "classroom", "school" }, { "theater", "theater" },
	{ "3:13", "night" }, { "sweeper", "night" }, { "sweepers", "night" }, { "lobotomy", "lcorp" }, { "abnormality", "lcorp" },
	{ "office", "office" }, { "alley", "alley" }, { "alleys", "alley" }, { "rubble", "ruins" }, { "ruins", "ruins" },
	{ "underpass", "underpass" }, { "tunnel", "underpass" }, { "bus", "bus" }, { "nest", "nest" }, { "kitchen", "home" },
	{ "apartment", "home" }, { "bedroom", "home" },
}
local ART_BY_FILE = {
	Bloodfiend = "theater", Core = "street", Daily = "street", Danger_Childhood = "alley", Danger_Distortions = "distortion",
	Danger_Districts = "street", Danger_Echoes = "night", Danger_Fingers = "syndicate", Danger_Head = "hall",
	Danger_Night = "night", Danger_Streets = "alley", Danger_Wings = "nest", Factions_Echoes = "street",
	Factions_Rankings = "office", Factions_Recruit = "office", Factions_Wars = "ruins", Fingers_Clans = "syndicate",
	Fingers_Index = "hall", Fingers_Middle = "syndicate", Fingers_Ricardo = "syndicate", Fingers_Ring = "hall",
	Fingers_Thumb = "hall", LCorp_Outside = "street", Life_Childhood = "home", Life_Elder = "home", Life_Night = "night",
	Life_Origins = "home", Life_Start = "home", Life_Household = "home", Limbus_Distortions = "distortion", Loot_Bosses = "arena",
	Loot_Items = "market", Wings_WCorp = "train", Wings_RCorp = "ruins",
}
local ART_BY_PREFIX = { { "Fixers_", "office" }, { "LCorp_", "lcorp" }, { "Library_", "library" }, { "Limbus_", "bus" }, { "Wings_", "nest" } }
local function artFor(e): string
	-- (a title or text can be a list of variants: the first one stands for them all here)
	local function plain(t: any): string
		return if type(t) == "table" then tostring(t[1] or "") else tostring(t or "")
	end
	local hay = string.lower(plain(e.title) .. " " .. plain(e.text))
	for _, w in ART_WORDS do
		if string.find(hay, "%f[%w]" .. string.gsub(w[1], "%p", "%%%0") .. "%f[%W]") then
			return w[2]
		end
	end
	local src = e.source or ""
	if ART_BY_FILE[src] then
		return ART_BY_FILE[src]
	end
	for _, p in ART_BY_PREFIX do
		if string.sub(src, 1, #p[1]) == p[1] then
			return p[2]
		end
	end
	return "street"
end
for _, e in pack.events do
	if type(e) == "table" and e.art == nil then
		e.art = artFor(e)
	end
end

-- FOES (Foes.luau): who stands across the fight screen. CAST (Cast/): faces for people who talk.
pack.foes = require(script:WaitForChild("Foes"))
-- (v0.16) the big bosses fought in turns (Engine/Battle.luau)
pack.bosses = require(script:WaitForChild("Bosses"))
-- (v0.17) the extreme bosses, for lives past every ordinary limit (City/Bosses17.luau)
for id, def in require(script:WaitForChild("Bosses17")) do
	if pack.bosses[id] ~= nil then
		table.insert(pack.mergeIssues, "Bosses17: duplicate boss id '" .. id .. "'")
	end
	pack.bosses[id] = def
end
pack.cast = {}
for _, c in mergeLists("Cast", true) do
	if type(c) == "table" and type(c.id) == "string" then
		pack.cast[c.id] = c
	end
end
--[[
	STORY GATES: the City is learned in order. An event whose id starts with one of a gate's
	prefixes waits until the life is `minAge` (unless the event sets its own minAge) and
	knows the faction: its `flag` is set (by a rumor, a sighting, an origin, a mode), or the
	life works one of the gate's `careers`, or it's past `openAge` (by then everyone has heard).
	Seeing one of the gated events also teaches the flag. The first gate that matches wins.
]]
local FIXER_CAREERS = { "fixer", "zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi", "hana" }
pack.storyGates = {
	{ flag = "knows_thumb", implies = { "knows_fingers" }, name = "The Thumb", emblem = "faction.thumb", blurb = "One of the five Fingers. Armed, old-fashioned, and obsessed with rank and manners. Disrespect is paid for.", minAge = 14, openAge = 18, careers = { "thumb" },
		prefixes = { "fn_thumb", "fc_tm_thumb", "fc_rc_thumb", "fn_q_apology", "fn_echo_sottocapo", "fn_daily_courtesy", "dz_f_thumb" } },
	{ flag = "knows_middle", implies = { "knows_fingers" }, name = "The Middle", emblem = "faction.middle", blurb = "A Finger that calls itself a family. Hurt one of them and all of them come to collect.", minAge = 14, openAge = 18, careers = { "middle" },
		prefixes = { "fn_middle", "fc_tm_middle", "fc_rc_middle", "fn_world_vengeance", "fn_daily_family_dinner", "dz_f_middle" } },
	{ flag = "knows_index", implies = { "knows_fingers" }, name = "The Index", emblem = "faction.index", blurb = "A Finger that obeys Prescripts: orders that arrive by letter. Nobody knows who writes them.", minAge = 14, openAge = 18, careers = { "index" },
		prefixes = { "fn_index", "fc_rc_index", "fc_ix_", "dz_f_proxies", "fn_q_book" } },
	{ flag = "knows_ring", implies = { "knows_fingers" }, name = "The Ring", emblem = "faction.ring", blurb = "A Finger of artists. You do not want to be their material.", minAge = 15, openAge = 19, careers = { "ring" },
		prefixes = { "fn_ring", "fn_pinky", "fc_rc_ring", "fn_echo_maestro", "dz_echo_ring", "dz_f_exhibition", "dz_f_doll", "dz_f_commission" } },
	{ flag = "knows_fingers", name = "The Fingers", emblem = "faction.fingers", blurb = "The five great Syndicates that rule the Backstreets: Thumb, Index, Middle, Ring and Pinky.", minAge = 14, openAge = 18, careers = { "kurokumo", "thumb", "middle", "index", "ring" },
		prefixes = { "fn_", "fc_rc_kurokumo", "fc_tm_", "dz_f_" } },
	{ flag = "knows_fixers", name = "Fixers", emblem = "faction.fixers", blurb = "Licensed problem-solvers for hire, graded 9 (new) to 1 (legend). They work from Offices and answer to Associations.", minAge = 12, openAge = 15, careers = FIXER_CAREERS,
		prefixes = { "fx_", "fc_rk_", "fc_daily", "fc_ls_", "fc_hc_", "fc_rc_zwei", "fc_rc_seven", "fc_rc_devyat", "fc_rc_cinq", "fc_rc_dieci", "fc_rc_oufi", "fc_rc_office" } },
	{ flag = "knows_wings", name = "The Wings", emblem = "faction.wings", blurb = "The 26 corporations that own the City, one District each. Inside their walls are the Nests.", minAge = 10, openAge = 14, careers = { "wing", "kcorp", "wcorp_cleanup", "rcorp", "wg_tcorp", "wg_hcorp", "nest_clerk" },
		prefixes = { "wg_", "fc_fe_", "fc_rc_wing", "fc_rc_kcorp", "fc_rc_wcorp", "fc_rc_rcorp", "fc_rc_tcorp", "fc_rc_hcorp", "dz_w_" } },
	{ flag = "knows_lcorp", implies = { "knows_wings" }, districts = { "d12" }, after = { eras = { "library", "limbus" }, status = "Fallen", blurb = "The Wing of District 12 until the White Nights. Its tower is dark, its branches are buried, and nobody has taken its place." }, name = "Lobotomy Corporation", emblem = "faction.lcorp", blurb = "The Wing of District 12. It makes the energy the City runs on, from things it keeps locked underground.", minAge = 14, openAge = 18, careers = { "lcorp_agent", "lcorp_research" },
		prefixes = { "lc_", "fc_rc_lcorp", "era_lcorp" } },
	{ flag = "knows_bloodfiends", name = "Bloodfiends", emblem = "faction.bloodfiend", blurb = "People who must drink blood to live. They keep to Families and old manners.", minAge = 14, openAge = 20, careers = { "bf_family" },
		prefixes = { "bf_", "fc_bf_", "fc_rc_family" } },
	{ flag = "knows_limbus", eras = { "limbus" }, name = "Limbus Company", emblem = "faction.limbus", blurb = "A new company that crosses the City by bus, looking for Golden Boughs.", minAge = 16, openAge = 22, careers = { "limbus_lccb", "limbus_lce", "lim_lcd" },
		prefixes = { "lim_", "fc_rc_limbus", "fc_rc_lce", "fc_rc_lcd" } },
	{ flag = "knows_library", eras = { "library", "limbus" }, after = { eras = { "limbus" }, status = "Gone", blurb = "A tower that stood where L Corp fell and turned its guests into books. It's gone now. The books aren't." }, name = "The Library", emblem = "faction.library", blurb = "It appeared where L Corp fell. Guests fight for a book; those who lose become one.", minAge = 16, openAge = 22, prefixes = { "lib_" } },
	{ flag = "knows_distortions", eras = { "library", "limbus" }, name = "Distortions", emblem = "misc.skull", blurb = "A person who breaks can become a monster shaped like their own despair. A few find E.G.O instead.", minAge = 12, openAge = 16, prefixes = { "dz_d_" } },
	{ flag = "knows_syndicates", name = "Syndicates", emblem = "faction.syndicate", blurb = "Gangs that hold a few streets each. Most pay tribute to a Finger. The smallest are called Rats.", minAge = 10, openAge = 13, prefixes = { "fc_rc_poach_syndicate", "fc_rc_syndicate" } },
	{ flag = "knows_night", name = "The Night in the Backstreets", emblem = "faction.night", blurb = "From 3:13 to 4:34 every night, Sweepers clear the Backstreets of anyone outdoors. Indoors is safe.", minAge = 6, openAge = 8, prefixes = { "dz_n_" } },

	--[[ known only (no `prefixes`: these hold nothing back, see Engine/Known.luau). They are
	     learned from cards that name them (`words`), events they `teach`, the District you
	     live in, the job you work, or any standing with them. Blurbs follow Glossary.luau,
	     the Association careers (Careers/Fixers.luau) and the District entries above. ]]
	-- the fifth Finger
	{ flag = "knows_pinky", implies = { "knows_fingers" }, name = "The Pinky", emblem = "faction.pinky", blurb = "The fifth Finger, and the one nobody can describe. Whoever works for it never says so.",
		teaches = { "fn_pinky", "fn_ring_pinky" }, words = { "the Pinky", "The Pinky", "Pinky's" } },
	-- the Backstreets
	{ flag = "knows_kurokumo", implies = { "knows_syndicates" }, name = "The Kurokumo Clan", emblem = "faction.kurokumo", blurb = "A sword clan from the old days that now works as Thumb muscle. Its young members are called Wakashu.", careers = { "kurokumo" },
		teaches = { "fc_rc_kurokumo" }, words = { "Kurokumo", "Wakashu" } },
	{ flag = "knows_rats", implies = { "knows_syndicates" }, name = "The Rats", emblem = "faction.rats", blurb = "Not a gang so much as a crowd: the Backstreets' lowest, who rob whoever looks weaker and answer to nobody. Nobody counts them, and nobody comes looking when one doesn't come back.",
		words = { "the Rats", "The Rats", "Rats'" }, mid = { "Rats" } },
	{ flag = "knows_blade", name = "The Blade Lineage", emblem = "faction.blade", blurb = "Wandering swordsmen who lost their homeland and kept only the blade. They began in District 19, and sell their skill to whoever pays.",
		teaches = { "bl_" }, words = { "Blade Lineage" } },
	-- the Associations (by number: Hana is the First)
	{ flag = "knows_hana", implies = { "knows_fixers" }, name = "The Hana Association", emblem = "faction.hana", blurb = "The First Association runs the Fixer system itself: licenses, Grades, Office credit, and the Colors.", careers = { "hana" },
		teaches = { "fx_hana", "fc_rc_hana" }, words = { "Hana Association", "Hana Association's" } },
	{ flag = "knows_zwei", implies = { "knows_fixers" }, name = "The Zwei Association", emblem = "assoc:2", blurb = "The Second Association: protection and public peace. Zwei calls itself the client's shield.", careers = { "zwei" },
		teaches = { "fx_zwei", "fc_rc_zwei" }, words = { "Zwei" } },
	{ flag = "knows_shi", implies = { "knows_fixers" }, name = "The Shi Association", emblem = "assoc:4", blurb = "The Fourth Association: the quietest, most dangerous contracts in the City. Patient, precise, expensive.", careers = { "shi" },
		teaches = { "fx_shi", "fc_rc_shi" }, words = { "Shi Association", "Shi Fixer", "Shi Fixers", "the Shi" } },
	{ flag = "knows_cinq", implies = { "knows_fixers" }, name = "The Cinq Association", emblem = "assoc:5", blurb = "The Fifth Association: duels by contract. When a client's honor is at stake, a Cinq Fixer stands in.", careers = { "cinq" },
		teaches = { "fx_cinq", "fc_rc_cinq" }, words = { "Cinq" } },
	{ flag = "knows_liu", implies = { "knows_fixers" }, name = "The Liu Association", emblem = "assoc:6", blurb = "The Sixth Association: fights between groups. Every Liu Fixer trains to take on several at once, with incendiaries in their weapons.", careers = { "liu" },
		teaches = { "fx_liu", "fc_rc_liu" }, words = { "Liu Association", "Liu Fixer", "Liu Fixers", "Liu Section", "the Liu" } },
	{ flag = "knows_seven", implies = { "knows_fixers" }, name = "The Seven Association", emblem = "assoc:7", blurb = "The Seventh Association: intelligence and investigation, by whatever means the contract allows.", careers = { "seven" },
		teaches = { "fx_seven", "fc_rc_seven" }, words = { "Seven Association", "Seven Fixer", "Seven Fixers", "the Seven", "The Seven" } },
	{ flag = "knows_devyat", implies = { "knows_fixers" }, name = "The Devyat' Association", emblem = "assoc:9", blurb = "The Ninth Association: couriers with dimensional Courier Trunks. Devyat' is never late.", careers = { "devyat" },
		teaches = { "fx_devyat", "fc_rc_devyat" }, words = { "Devyat" } },
	{ flag = "knows_dieci", implies = { "knows_fixers" }, name = "The Dieci Association", emblem = "assoc:10", blurb = "The Tenth Association: collectors and students of knowledge. Their gear turns what you know into strength.", careers = { "dieci" },
		teaches = { "fx_dieci", "fc_rc_dieci" }, words = { "Dieci" } },
	{ flag = "knows_oufi", implies = { "knows_fixers" }, name = "The Öufi Association", emblem = "assoc:11", blurb = "The Eleventh Association: contracts. Öufi notarizes them, and sees every notarized one carried out.", careers = { "oufi" },
		teaches = { "fx_oufi", "fc_rc_oufi" }, words = { "Öufi", "Oufi" } },
	-- the Wings (you know the one that owns your District)
	{ flag = "knows_kcorp", implies = { "knows_wings" }, name = "K Corp", emblem = "wing:K", blurb = "The Wing of District 11. Its healing ampules can close almost any wound, and it would like you not to ask how.", careers = { "kcorp" }, districts = { "d11" },
		teaches = { "wg_k_", "wg_lore_kcorp", "wg_ampule", "fc_rc_kcorp" }, words = { "K Corp", "K Corp's" } },
	{ flag = "knows_wcorp", implies = { "knows_wings" }, name = "W Corp", emblem = "wing:W", blurb = "The Wing of District 23. Its WARP trains cross the City in seconds. Passengers aren't told how.", careers = { "wcorp_cleanup" }, districts = { "d23" },
		teaches = { "wg_w_", "wg_lore_train", "wg_lore_cleanup", "fc_rc_wcorp" }, words = { "W Corp", "W Corp's", "WARP" } },
	{ flag = "knows_rcorp", implies = { "knows_wings" }, name = "R Corp", emblem = "wing:R", blurb = "The Wing of District 18. It rents out armies: the Rabbit, Reindeer and Rhino teams of its Fourth Pack.", careers = { "rcorp" }, districts = { "d18" },
		teaches = { "wg_r_", "wg_lore_rcorp", "fc_rc_rcorp" }, words = { "R Corp", "R Corp's", "Fourth Pack", "Rabbit Team", "Reindeer Team", "Rhino Team" } },
	{ flag = "knows_tcorp", implies = { "knows_wings" }, name = "T Corp", emblem = "wing:T", blurb = "The Wing of District 20. It collects, sells and taxes time itself. In its Backstreets a day can cost you years.", careers = { "wg_tcorp" }, districts = { "d20" },
		teaches = { "wg_t_", "wg_lore_tcorp", "fc_rc_tcorp" }, words = { "T Corp", "T Corp's" } },
	{ flag = "knows_hcorp", implies = { "knows_wings" }, name = "H Corp", emblem = "wing:H", blurb = "The Wing of District 8, ruled from Hongyuan by old families. A fortune there is measured in rooms.", careers = { "wg_hcorp" }, districts = { "d8" },
		teaches = { "wg_h_", "wg_hcorp", "wg_lore_hcorp", "fc_rc_hcorp" }, words = { "H Corp", "H Corp's", "Hongyuan" } },
	{ flag = "knows_scorp", implies = { "knows_wings" }, name = "S Corp", emblem = "wing:S", blurb = "The Wing of District 19: a King's court of rigid classes. People who run from it are hunted.", districts = { "d19" },
		words = { "S Corp", "S Corp's", "King's Court" } },
	{ flag = "knows_ucorp", implies = { "knows_wings" }, name = "U Corp", emblem = "wing:U", blurb = "The Wing of District 21. Its institutions float on the Great Lake, among the pirates and the whalers.", districts = { "d21" },
		words = { "U Corp", "U Corp's", "Great Lake" } },
	{ flag = "knows_ncorp", implies = { "knows_wings" }, name = "N Corp", emblem = "wing:N", blurb = "The Wing of District 14. Its Nail and Hammer factions hunt what they call impurity.", districts = { "d14" },
		words = { "N Corp", "N Corp's" } },
	{ flag = "knows_gcorp", implies = { "knows_wings" }, name = "G Corp", emblem = "wing:G", blurb = "The old Wing of District 7. It fought the Smoke War on the front line and fell. Its veterans don't talk about it.", districts = { "d7" },
		words = { "G Corp", "G Corp's", "Smoke War" } },
	-- above the Wings, and outside the City
	{ flag = "knows_head", name = "The Head, the Eye and the Claws", emblem = "faction.head", blurb = "The rulers above the Wings. The Eye watches, the Arbiters judge, the Claws carry out the sentence. They enforce the Taboos.",
		words = { "the Head", "The Head", "the Claws", "The Claws", "Arbiter", "Arbiters", "Beholder", "Beholders", "Taboo", "Taboos" } },
	{ flag = "knows_outskirts", name = "The Outskirts", emblem = "faction.outskirts", blurb = "The wasteland beyond the City. No law, no Wings, and things that were never people.",
		words = { "Outskirts" } },

	-- age floors only
	{ minAge = 16, prefixes = { "dz_h_" } },
	{ minAge = 14, prefixes = { "bl_", "fc_echo_", "fc_rc_" } },
	{ minAge = 10, prefixes = { "dz_s_", "dz_x_", "dz_echo_" } },
}

-- "Who you know of", in sections (Engine/Known.luau): each lists its gates' flags in order
pack.knownGroups = {
	{ id = "fingers", name = "The Fingers", flags = { "knows_fingers", "knows_thumb", "knows_index", "knows_middle", "knows_ring", "knows_pinky" } },
	{ id = "streets", name = "The Backstreets", flags = { "knows_syndicates", "knows_kurokumo", "knows_rats", "knows_blade", "knows_night" } },
	{ id = "fixers", name = "Fixers and Associations", flags = { "knows_fixers", "knows_hana", "knows_zwei", "knows_shi", "knows_cinq", "knows_liu", "knows_seven", "knows_devyat", "knows_dieci", "knows_oufi" } },
	{ id = "wings", name = "The Wings", flags = { "knows_wings", "knows_lcorp", "knows_kcorp", "knows_wcorp", "knows_rcorp", "knows_tcorp", "knows_hcorp", "knows_scorp", "knows_ucorp", "knows_ncorp", "knows_gcorp" } },
	{ id = "beyond", name = "Above and beyond", flags = { "knows_head", "knows_bloodfiends", "knows_distortions", "knows_library", "knows_limbus", "knows_outskirts" } },
}

--[[
	STORYLINES (Storylines/): every life that starts at birth lives one main story, picked
	at birth. An event with `story = "<storyline id>"` is one of its beats and only happens
	in lives on that story. The stock opening scenes below are skipped in those lives (the
	story has its own opening).
]]
pack.storylines = mergeLists("Storylines", true)
pack.storyReplaces = { "bs_c_first_", "bs_c_rule_", "bs_c_bori_bread", "bs_c_nest_lotte" }
pack.recapAges = { 18 } -- a look back at who you've become
pack.glossary = require(script:WaitForChild("Glossary"))

-- CANTOS and INTERVALLOS (Chapters.luau): title cards when a life reaches each age.
local chapterData = require(script:WaitForChild("Chapters"))
if chapterData.cantos then
	pack.chapters = chapterData.cantos
	pack.intervallos = chapterData.intervallos or {}
else
	pack.chapters = chapterData
	pack.intervallos = {}
end
pack.chapterWord = "Canto"
pack.interludeWord = "Intervallo"

return pack
