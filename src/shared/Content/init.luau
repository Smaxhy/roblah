--[[
	Undermere: starter content pack (original setting, see docs/SETTING.md)

	This file is the pack manifest. The engine reads everything about the game
	world from here. Swap this whole Content folder to make a different game.
	Format reference: docs/CONTENT_GUIDE.md

	Colors are {R, G, B} (0-255) so the engine stays free of Roblox types.
]]

local pack = {}

pack.meta = {
	title = "Undermere",
	tagline = "A life at the bottom of the crater.",
	currency = "scrip",
	lanternName = "Lantern", -- what a finished life becomes
	ledgerName = "Lantern Ledger", -- the archive of past lives
	glowName = "Glow", -- meta currency earned by releasing lanterns
	districtWord = "Ward", -- what a district is called ("Ward 7")
	actionsPerYear = 3, -- activities allowed per year
	adultAge = 18, -- living costs start here
	maxLogEntries = 400,
}

pack.calendar = {
	startYear = 318, -- a new life is born somewhere in startYear +/- startJitter
	startJitter = 6,
}

-- The four core stats run 0-100. Sanity runs min..max and drives coin odds.
pack.stats = {
	order = { "fortitude", "prudence", "temperance", "justice" },
	fortitude = { name = "Fortitude", short = "FOR", color = { 214, 96, 88 }, desc = "Body and health. At zero, you die." },
	prudence = { name = "Prudence", short = "PRU", color = { 110, 150, 222 }, desc = "Willpower. Hold steady when things get bad." },
	temperance = { name = "Temperance", short = "TEM", color = { 112, 186, 128 }, desc = "Skill, study and craft." },
	justice = { name = "Justice", short = "JUS", color = { 222, 182, 92 }, desc = "Speed, nerve and fighting." },
	-- start: sanity at birth. rest: where mood drifts back to each year (by `drift`).
	sanity = { name = "Sanity", min = -45, max = 45, start = 12, rest = 0, drift = 1 },
}

--[[
	SIDES: every district has the same two sides.
		costMult      living cost multiplier (district.cost x this)
		payMult       salary multiplier
		danger        multiplies the odds of events tagged "danger" and the yearly hazard roll
		hazardChance  base chance per year of a hazard (x district.danger)
		wear          sanity lost per adult year just from living here
		tagWeights    optional multipliers for events with these tags
		yearly        optional effects every year
]]
pack.sides = {
	order = { "charter", "gutters" },
	charter = {
		name = "the Charter",
		short = "Charter",
		desc = "The company's walled enclave up on the sunlit Rim. Swept streets, gaslight, guards at every gate.",
		costMult = 2,
		payMult = 1.25,
		danger = 0.35,
		hazardChance = 0.06,
		evictOnDebt = true, -- a year in debt brings a notice to quit; stay in debt and you're thrown out
		evictGrace = 1, -- years of debt allowed after the notice
		wear = 0,
		tagWeights = { crime = 0.4, luxury = 2 },
		color = { 236, 210, 150 },
	},
	gutters = {
		name = "the Gutters",
		short = "Gutters",
		desc = "Everything outside the walls: tenements down the Terraces, stilt-houses on the Silt, fog, rent, and teeth.",
		costMult = 0.6,
		payMult = 0.9,
		danger = 1,
		hazardChance = 0.26,
		wear = 1,
		yearly = { fortitude = { -1, 0 } }, -- damp, soot and bad food
		tagWeights = { luxury = 0.3 },
		color = { 150, 120, 110 },
	},
}

--[[
	DISTRICTS (Wards): wedge-shaped slices of the crater, each chartered to a company.
		number        shown as "Ward 7"
		corp          the company that holds the charter (nil = no living company)
		wealth        pay multiplier (all careers)
		danger        danger multiplier (hazards + "danger" events)
		cost          base yearly living cost (x side.costMult)
		charterCost   one-time price to buy into the Charter
		charterShare  chance to be born on the Charter side
		population    how often new lives are born here
		careerPay     optional pay multipliers for specific careers
		yearly        optional per-side yearly effects: { charter = {...}, gutters = {...} }
		tagWeights    optional event tag multipliers
]]
pack.districts = {
	order = { "gatewater", "lampwick", "saltpan", "glasswall", "ropewalk", "pumpside", "foundry", "kelpmarket", "bellhollow", "drownside" },
	gatewater = {
		name = "Gatewater",
		number = 1,
		corp = "the Gatewater Exchange",
		trade = "banking, bonds and flood insurance",
		desc = "The richest Ward, built around the great floodgates. Money moves here faster than water.",
		wealth = 1.6,
		danger = 0.75,
		cost = 80,
		charterCost = 2200,
		charterShare = 0.3,
		population = 0.8,
		careerPay = { sluice = 1.3 },
		color = { 214, 190, 120 },
	},
	lampwick = {
		name = "Lampwick",
		number = 2,
		corp = "the Lamplight Company",
		trade = "lamp oil and gaslight",
		desc = "The Ward that lights the city. Its Charter glows all night; its Gutters get the oil that's left.",
		wealth = 1.3,
		danger = 0.95,
		cost = 60,
		charterCost = 1500,
		charterShare = 0.22,
		population = 1,
		careerPay = { diver = 1.1 },
		yearly = { gutters = { fortitude = { -1, 0 } } },
		color = { 240, 176, 90 },
	},
	saltpan = {
		name = "Saltpan",
		number = 3,
		corp = "the Saltworks Charter",
		trade = "salt and preserved food",
		desc = "White heaps of salt and evaporation pans. Hard work, cracked hands, and food that keeps.",
		wealth = 1,
		danger = 1,
		cost = 45,
		charterCost = 1000,
		charterShare = 0.18,
		population = 1.1,
		yearly = { gutters = { fortitude = { -1, 0 } } },
		color = { 220, 220, 214 },
	},
	glasswall = {
		name = "Glasswall",
		number = 4,
		corp = "the Glaziers' Charter",
		trade = "glass, lenses and greenhouses",
		desc = "Greenhouses and observatories. The Charter is beautiful and almost impossible to get into.",
		wealth = 1.4,
		danger = 0.65,
		cost = 70,
		charterCost = 2600,
		charterShare = 0.15,
		population = 0.8,
		careerPay = { sluice = 1.1 },
		yearly = { charter = { sanity = 1 } },
		tagWeights = { study = 1.5 },
		color = { 160, 214, 200 },
	},
	ropewalk = {
		name = "Ropewalk",
		number = 5,
		corp = "the Hempen Company",
		trade = "rope, nets and cable",
		desc = "Long sheds where rope is walked for miles. The docks never sleep, and neither do the accidents.",
		wealth = 0.9,
		danger = 1.15,
		cost = 35,
		charterCost = 800,
		charterShare = 0.15,
		population = 1.1,
		careerPay = { diver = 1.2, brine = 1.1 },
		color = { 180, 150, 110 },
	},
	pumpside = {
		name = "Pumpside",
		number = 6,
		corp = "the Boilermakers' Charter",
		trade = "boilers and engines for the great pumps",
		desc = "The great pumps thunder day and night. Everyone here is half deaf and proud of it.",
		wealth = 1,
		danger = 1,
		cost = 45,
		charterCost = 1100,
		charterShare = 0.2,
		population = 1.2,
		careerPay = { stoker = 1.35 },
		color = { 170, 110, 90 },
	},
	foundry = {
		name = "Foundry Row",
		number = 7,
		corp = "the Ironmongers' Charter",
		trade = "iron, blades and chain",
		desc = "Smog, sparks and hammer-song. The Gutters breathe soot, and arguments end quickly.",
		wealth = 1.1,
		danger = 1.35,
		cost = 40,
		charterCost = 1200,
		charterShare = 0.17,
		population = 1,
		yearly = { gutters = { fortitude = { -2, 0 } } },
		tagWeights = { crime = 1.4 },
		color = { 150, 120, 120 },
	},
	kelpmarket = {
		name = "Kelpmarket",
		number = 8,
		corp = "the Kelp & Net Company",
		trade = "kelp farms, fish and food",
		desc = "Floating farms and loud markets. Poor, but nobody here goes hungry for long.",
		wealth = 0.8,
		danger = 0.9,
		cost = 30,
		charterCost = 700,
		charterShare = 0.14,
		population = 1.3,
		yearly = { gutters = { sanity = 1 }, charter = { sanity = 1 } },
		color = { 110, 170, 120 },
	},
	bellhollow = {
		name = "Bellhollow",
		number = 9,
		corp = "the Bellwrights' Charter",
		trade = "bells, clocks and flood-warning towers",
		desc = "Every hour is announced by a hundred bells. The Choir of Still Water is strongest here.",
		wealth = 1.1,
		danger = 0.8,
		cost = 50,
		charterCost = 1300,
		charterShare = 0.2,
		population = 0.9,
		careerPay = { choir = 1.6 },
		tagWeights = { faith = 1.5 },
		color = { 190, 170, 210 },
	},
	drownside = {
		name = "Drownside",
		number = 10,
		corp = nil, -- the Wreck Company went under; the Brine Kin hold its ruins
		trade = "nothing legal",
		desc = "Half underwater since the Wreck Company failed. No charter, no law, and the best salvage in the city.",
		wealth = 0.6,
		danger = 1.7,
		cost = 15,
		charterCost = 400,
		charterShare = 0.08,
		population = 0.7,
		careerPay = { brine = 1.5, diver = 1.3 },
		tagWeights = { crime = 1.6, salvage = 1.5 },
		color = { 80, 120, 130 },
	},
}

-- World state rolled every year. Events can check it with when = { world = { water = "low" } }.
pack.world = {
	{
		key = "water",
		name = "The Mere",
		values = { "low", "normal", "high" },
		labels = { low = "Low Water", normal = "Still Water", high = "High Water" },
		start = "normal",
		shift = 0.35, -- chance per year to move one step up or down
	},
	-- Calendar-driven variables are also supported (handy for timelines/eras):
	-- { key = "era", byYear = { { from = 0, value = "old" }, { from = 330, value = "new" } } },
}

pack.careers = {
	order = { "company", "stoker", "diver", "sluice", "brine", "choir" },
	-- The Ward's own company. Its name comes from the district's `corp`.
	company = {
		company = true,
		name = "the company",
		desc = "Work for the company that holds your Ward's charter. Good pay, long hours, and they own you a little.",
		ranks = { "Hireling", "Company Clerk", "Overseer", "Section Chief", "Director" },
		salary = { 70, 130, 240, 450, 900 },
		minAge = 16,
		requires = { min = { temperance = 30 } },
		guttersRequire = { min = { temperance = 45 } }, -- harder to get hired from outside the walls
		promoteStat = "temperance",
		promoteAt = { 40, 55, 70, 86 },
		yearsPerRank = 3,
		hazard = { chance = 0.06, result = { sanity = { -6, -2 }, log = "The company cut a department to make the numbers. You watched them carry the desks out." } },
	},
	stoker = {
		name = "Pumpworks",
		desc = "Feed the great pumps that keep the Terraces dry. Hot, loud, honest work.",
		ranks = { "Ash Hand", "Stoker", "Valve Keeper", "Chief Stoker" },
		salary = { 30, 55, 90, 150 },
		minAge = 14,
		sides = { "gutters" },
		promoteStat = "fortitude",
		promoteAt = { 25, 40, 60 }, -- stat needed to reach rank 2, 3, 4
		yearsPerRank = 2,
		yearly = { fortitude = { -1, 0 } },
		hazard = { chance = 0.08, result = { fortitude = { -8, -3 }, log = "A pressure valve spat steam across your arm.", cause = "Scalded at the Pumpworks" } },
	},
	diver = {
		name = "Lantern Guild",
		desc = "Licensed salvage divers who take lanterns and rope down into the drowned streets.",
		ranks = { "Wet Lantern", "Diver", "Deep Diver", "Lantern", "Lantern-Captain" },
		salary = { 50, 100, 190, 360, 650 },
		minAge = 16,
		requires = { min = { justice = 20, fortitude = 20 } },
		promoteStat = "justice",
		promoteAt = { 30, 45, 62, 80 },
		yearsPerRank = 2,
		hazard = {
			chance = 0.15,
			result = { fortitude = { -14, -5 }, sanity = { -6, -2 }, log = "Something in the dark water cut your line. You came up shaking.", cause = "Lost on a dive" },
		},
	},
	sluice = {
		name = "Sluice Authority",
		desc = "The city's own clerks and engineers. They run the floodgates for every Ward, and therefore the city.",
		ranks = { "Junior Clerk", "Clerk", "Gatewarden", "Engineer", "Commissioner" },
		salary = { 70, 120, 210, 380, 800 },
		minAge = 18,
		requires = { min = { temperance = 35 } },
		promoteStat = "temperance",
		promoteAt = { 45, 58, 72, 88 },
		yearsPerRank = 3,
		hazard = { chance = 0.05, result = { sanity = { -8, -3 }, log = "You stamped a flood order for a Silt block. The addresses stayed with you." } },
	},
	brine = {
		name = "Brine Kin",
		desc = "A smuggling family running boats through the drowned streets. Everyone is cousin.",
		ranks = { "Runner", "Boatman", "Ledger-hand", "Cousin", "Elder Kin" },
		salary = { 40, 90, 170, 320, 600 },
		minAge = 14,
		sides = { "gutters" },
		promoteStat = "prudence",
		promoteAt = { 25, 40, 58, 75 },
		yearsPerRank = 2,
		hazard = {
			chance = 0.12,
			result = { fortitude = { -10, -4 }, log = "A rival crew caught you alone under the old viaduct.", cause = "Caught under the viaduct" },
		},
	},
	choir = {
		name = "Choir of Still Water",
		desc = "A quiet faith that sits in long silences by the water. It believes the drowned city is listening.",
		ranks = { "Listener", "Chorister", "Cantor", "Still Voice" },
		salary = { 15, 30, 60, 120 },
		minAge = 12,
		requires = { min = { prudence = 25 } },
		promoteStat = "prudence",
		promoteAt = { 40, 60, 80 },
		yearsPerRank = 3,
		yearly = { sanity = 2 },
		hazard = { chance = 0.06, result = { sanity = { -10, -4 }, log = "During a long silence, you heard the water answer back." } },
	},
}

-- Forms change the rules of a life. clash bonuses apply to every coin clash.
pack.forms = {
	human = { name = "Human", desc = "Soft, warm, breakable. The usual." },
	tidetouched = {
		name = "Tidetouched",
		desc = "The Mere got into your blood. Cool skin, patient lungs, and the Charter gates stay shut to you.",
		clash = { base = 1 },
		yearly = { sanity = -1 },
		blockedSides = { "charter" },
		color = { 96, 196, 190 },
		look = { tint = { 96, 186, 178 }, amount = 0.28, eyes = { 120, 236, 224 }, glow = true },
	},
	surfaced = {
		name = "Surfaced",
		desc = "You went down to the bottom of yourself and came back up holding something.",
		clash = { coins = 1 },
		headsFloor = 25, -- your coins never flip worse than this %
		color = { 240, 210, 140 },
		look = { tint = { 214, 214, 222 }, amount = 0.16, eyes = { 255, 236, 190 }, glow = true },
	},
	drowned = { name = "Drowned", desc = "Something that stands very still in the deep water.", terminal = true, color = { 70, 90, 110 }, look = { tint = { 70, 110, 116 }, amount = 0.45, eyes = { 150, 240, 230 }, glow = true } },
}

pack.relationKinds = {
	mother = { name = "Mother", family = true, ageGap = { 18, 34 } },
	father = { name = "Father", family = true, ageGap = { 18, 40 } },
	sibling = { name = "Sibling", family = true, ageGap = { -8, 8 } },
	child = { name = "Child", family = true, heir = true },
	friend = { name = "Friend" },
	mentor = { name = "Mentor" },
	rival = { name = "Rival" },
}

--[[
	INTERACTIONS: things you do with one person, from the People tab. Each costs
	an action unless `actions = 0`. {rel} names the person.
		kinds = { ... }       which relation kinds see it (default: all)
		linked = true/false   only linked friends (other players) / never them
		online = true         a linked friend must be online
		minAge / relMinAge / relMaxAge, minBond / maxBond, cost, cooldown (years, per person)
		result, or clash + win + lose. `bond = { min, max }` changes your bond with them.
		logs = { [kind] = "..." } swaps the log line by who they are.
]]
pack.interactions = {
	order = { "spend_time", "teach", "ask_help", "make_peace", "send_word" },
	spend_time = {
		name = "Spend time together",
		desc = "An evening with {rel}, doing nothing much.",
		cooldown = 1,
		result = { bond = { 6, 12 }, sanity = { 1, 3 }, log = "You spent an evening with {rel}." },
		logs = {
			mother = "You walked the stairs with your mother, {rel}, and she told you about the year the water rose.",
			father = "You sat on the step with your father, {rel}, mending nets that didn't need mending.",
			sibling = "You and {rel} stayed up arguing about nothing, like when you were small.",
			child = "You took {rel} down to watch the lantern boats come in.",
			friend = "You and {rel} shared a pot of kelp tea and the gossip from three Wards.",
			mentor = "{rel} walked you through an old ledger and told you which numbers lie.",
			rival = "You and {rel} drank to an uneasy truce. It held for the evening.",
		},
	},
	teach = {
		name = "Teach them something",
		desc = "Knots, numbers, the tide tables. Teaching sharpens you too.",
		kinds = { "child", "sibling" },
		relMinAge = 5,
		relMaxAge = 17,
		minAge = 16,
		cooldown = 1,
		result = { bond = { 4, 8 }, temperance = { 1, 2 }, log = "You taught {rel} to read the tide tables. They got it faster than you did." },
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
		clash = { stat = "prudence", foe = "Old grudges", coins = 2, base = 4, coinPower = 3 },
		win = { bond = { 14, 24 }, sanity = 2, log = "You and {rel} talked until the lamp burned down. Something mended." },
		lose = { bond = { -6, -2 }, sanity = -2, log = "It turned into the same old fight with {rel}." },
	},
	send_word = {
		name = "Send word",
		desc = "A note to {rel}, wherever their life has taken them.",
		linked = true,
		online = true,
		cooldown = 1,
		result = {
			bond = { 4, 8 },
			log = "You sent {rel} a note and a pressed kelp flower.",
			linked = { sanity = { 1, 3 }, log = "{sender} sent word: a short note and a pressed kelp flower." },
		},
	},
}

--[[
	Origins: everyone starts as an ordinary civilian. The Ward is rolled (or picked
	on the New Life screen); the side is rolled from the Ward's charterShare unless
	the origin sets `side`. glowCost > 0 means it must be unlocked with Glow.
]]
pack.origins = {
	{
		id = "ordinary",
		name = "Ordinary Family",
		desc = "Two tired parents and a roof that mostly holds. Where that roof is depends on the dice.",
		birth = "You were born to two tired parents in {zone}, Ward {wardNumber}.",
		money = 15,
		family = { mother = true, father = true, siblings = { 0, 2 } },
		glowCost = 0,
	},
	{
		id = "single_parent",
		name = "Single Parent",
		desc = "One parent working double shifts. Tougher odds of a good address.",
		birth = "You were born the night your mother finished a double shift, in {zone}.",
		money = 5,
		stats = { temperance = 3 },
		charterBias = 0.5, -- multiplies the Ward's charterShare
		family = { mother = true, siblings = { 0, 1 } },
		glowCost = 0,
	},
	{
		id = "orphan",
		name = "Gutter Orphan",
		desc = "Nobody's child. Born in the Gutters and tough from the first breath.",
		birth = "You were found in a dry crate on the docks of {district}, wrapped in an old Lantern Guild flag.",
		side = "gutters",
		money = 0,
		stats = { fortitude = 4 },
		family = { siblings = { 0, 0 } },
		flags = { "foundling" },
		sanity = 4,
		glowCost = 0,
	},
	{
		id = "divers_kid",
		name = "Diver's Kid",
		desc = "Born to the Lantern Guild in the Gutters. You could swim before you could walk.",
		birth = "You were born in a stilt-house hung with lanterns in {zone}, to a father who dove for a living.",
		side = "gutters",
		money = 10,
		stats = { justice = 5, fortitude = 3 },
		family = { father = true, siblings = { 0, 1 } },
		flags = { "diver_blood" },
		glowCost = 2,
	},
	{
		id = "company_family",
		name = "Company Family",
		desc = "Born inside the walls. Your parents work for the Ward's company, and so, probably, will you.",
		birth = "You were born inside the walls of {zone}. The first thing you saw was gaslight.",
		side = "charter",
		money = 350,
		stats = { temperance = 6, prudence = 4 },
		family = { mother = true, father = true, siblings = { 0, 1 } },
		flags = { "charter_born" },
		sanity = 18,
		glowCost = 3,
	},
	{
		id = "tideborn",
		name = "Tideborn",
		desc = "Born Tidetouched in the Gutters. The Mere has been in you from the start.",
		birth = "You were born in {zone} during High Water, and you didn't cry when the water reached the cradle.",
		side = "gutters",
		money = 0,
		stats = { fortitude = 6 },
		family = { mother = true, siblings = { 0, 1 } },
		form = "tidetouched",
		flags = { "tideborn" },
		glowCost = 4,
	},
}

--[[
	Activities: up to meta.actionsPerYear per year. Same shape as a choice, plus
	when / cost / cooldown / minAge / category, and optionally `move`:
		move = "charter"   buy into the Charter (costs the Ward's charterCost)
		move = "gutters"   move out to the Gutters
		move = "district"  move to another Ward (the player picks which)
]]
pack.activityCategories = {
	order = { "self", "money", "gear", "people", "home" },
	self = "Body & mind",
	gear = "Gear",
	money = "Money",
	people = "People",
	home = "Home",
}

pack.activities = {
	{
		id = "train",
		category = "self",
		name = "Spar on the docks",
		desc = "Trade bruises with dockhands until something sticks.",
		minAge = 8,
		result = { justice = { 2, 4 }, fortitude = { 0, 1 }, sanity = { -1, 0 }, log = "You spent your evenings sparring on the docks." },
	},
	{
		id = "study",
		category = "self",
		name = "Study by lamplight",
		desc = "Borrowed ledgers, broken textbooks, pump schematics.",
		minAge = 6,
		result = { temperance = { 2, 4 }, log = "You studied by lamplight until your eyes ached." },
	},
	{
		id = "still",
		category = "self",
		name = "Sit by the water",
		desc = "Watch the Mere breathe. Let it take the noise.",
		minAge = 4,
		result = { prudence = { 1, 3 }, sanity = { 2, 5 }, log = "You sat by the water until your head went quiet." },
	},
	{
		id = "stitcher",
		category = "self",
		name = "See a stitcher",
		desc = "Patch up whatever the year broke, and treat one injury or illness.",
		cost = 30,
		result = { fortitude = { 6, 12 }, cure = "any", log = "A stitcher patched you up and took your {currency}." },
	},
	{
		id = "workshop",
		category = "gear",
		name = "Visit a workshop",
		desc = "Tools, coats and charms. Gear changes your odds in clashes. Browsing is free.",
		minAge = 10,
		shop = true,
	},
	{
		id = "broth",
		category = "self",
		name = "Noodle barge",
		desc = "Hot broth, loud strangers, cheap comfort.",
		minAge = 6,
		cost = 5,
		result = { sanity = { 2, 5 }, log = "You ate hot broth on the noodle barge and laughed at a stranger's joke." },
	},
	{
		id = "haul",
		category = "money",
		name = "Haul cargo",
		desc = "Carry crates up the switchback stairs. Richer Wards pay more.",
		minAge = 10,
		result = { fortitude = { 1, 3 }, wage = { 6, 16 }, log = "You hauled cargo up the switchbacks for a few {currency}." },
	},
	{
		id = "double_shift",
		category = "money",
		name = "Work a double shift",
		desc = "More pay. Less of you.",
		when = { anyCareer = true },
		result = { paycheck = 0.35, fortitude = { -4, -1 }, sanity = { -3, -1 }, log = "You worked double shifts until your hands stopped feeling like yours." },
	},
	{
		id = "wade",
		category = "money",
		name = "Wade the shallows",
		desc = "Salvage from the drowned streets. Things live down there.",
		minAge = 12,
		when = { world = { water = { "low", "normal" } } },
		clash = { stat = "justice", foe = "Silt eel", coins = 1, base = 3, coinPower = 2 },
		win = { wage = { 20, 80 }, log = "You came back from the shallows with salvage worth selling." },
		lose = { fortitude = { -12, -6 }, sanity = -3, log = "Something in the shallows bit deep. You came back empty-handed.", cause = "Bitten in the shallows" },
	},
	{
		id = "visit_family",
		category = "people",
		name = "Visit family",
		desc = "Sit with the people who knew you small.",
		minAge = 14,
		when = { hasRelation = { "mother", "father", "sibling", "child" } },
		result = { sanity = { 1, 4 }, relationBond = { kind = "family", amount = 6 }, log = "You spent an evening with family. Nobody fixed anything, and it helped anyway." },
	},
	{
		id = "foundling_steps",
		category = "people",
		name = "Visit the Foundling Steps",
		desc = "Children nobody came back for. Maybe one of them is yours now.",
		minAge = 24,
		cost = 40,
		cooldown = 4,
		result = {
			addRelation = { kind = "child", age = { 3, 9 }, bond = 55 },
			sanity = 4,
			setFlags = { "parent" },
			log = "You brought {newRelation} home from the Foundling Steps.",
		},
	},
	-- with a linked friend (another player) who's online; {linked} names them
	{
		id = "shift_together",
		category = "people",
		name = "Work a shift with {linked}",
		desc = "Two pairs of hands on the same job. The foreman pays you both.",
		minAge = 14,
		cooldown = 1,
		when = { linked = true },
		result = {
			wage = { 15, 35 },
			sanity = 1,
			log = "You and {linked} worked a shift side by side and split a bun at the end of it.",
			linked = { wage = { 15, 35 }, sanity = 1, log = "{sender} talked the foreman into taking you both on for a shift." },
		},
	},
	{
		id = "train_together",
		category = "people",
		name = "Train with {linked}",
		desc = "Sparring is better with someone who won't go easy on you.",
		minAge = 10,
		cooldown = 1,
		when = { linked = true },
		result = {
			fortitude = { 1, 3 },
			justice = { 1, 2 },
			log = "You and {linked} sparred on the docks until your arms shook.",
			linked = { fortitude = { 1, 3 }, justice = { 1, 2 }, log = "{sender} dragged you out to spar on the docks. You're sore and glad of it." },
		},
	},
	{
		id = "salvage_together",
		category = "people",
		name = "Salvage the arcade with {linked}",
		desc = "The drowned arcade at low tide. Two lamps, one rope, a lot of rust. A friend adds a coin to your side.",
		minAge = 16,
		cooldown = 2,
		when = { linked = true },
		clash = { stat = "prudence", foe = "The drowned arcade", coins = 2, base = 5, coinPower = 3, assist = true },
		win = {
			wage = { 30, 70 },
			log = "You and {linked} came up with a sack of brass fittings and split them on the stairs.",
			linked = { wage = { 25, 60 }, log = "{sender} hauled you out of the arcade with a sack of brass. Half of it is yours." },
		},
		lose = {
			fortitude = { -6, -2 },
			log = "The tide came in early. You and {linked} got out with nothing but cuts.",
			cause = "Lost in the drowned arcade",
			linked = { fortitude = { -3, -1 }, log = "The arcade nearly kept you and {sender}. You both got out with nothing." },
		},
	},
	{
		id = "move_charter",
		category = "home",
		name = "Buy into the Charter",
		desc = "Gaslight, guards, and a front door that locks. The company sets the price.",
		minAge = 18,
		move = "charter",
		result = { sanity = 6, log = "You bought your way through the gates of {zone}. The streets here are swept every morning." },
	},
	{
		id = "move_gutters",
		category = "home",
		name = "Move out to the Gutters",
		desc = "Cheaper rent, worse odds. Sometimes you need the money more than the walls.",
		minAge = 16,
		move = "gutters",
		result = { money = { 80, 200 }, sanity = -4, log = "You sold what you could and moved out to {zone}." },
	},
	{
		id = "move_district",
		category = "home",
		name = "Move to another Ward",
		desc = "Pack a cart and start over somewhere else. You'll arrive in the Gutters.",
		minAge = 16,
		cost = 60,
		move = "district",
		result = { sanity = -1, log = "You packed a cart and moved to {zone}." },
	},
}

--[[
	GEAR: one item per slot. Bought at a workshop (the "workshop" activity opens
	the shop) or found through events (result key `gear = "id"`).
		clash        bonuses for clashes that use that stat: { justice = { coins, base, coinPower } }
		yearly       effects every year while carried
		hazardGuard  multiplies your yearly hazard chance (0.8 = 20% safer)
		requires     conditions to buy it
]]
pack.gear = {
	slots = { "tool", "coat", "charm" },
	order = { "dock_knife", "hook_pole", "pocket_ledger", "tide_tables", "diving_lamp", "oilskin", "dock_jacket", "company_greatcoat", "still_stone", "little_bell", "lantern_token" },
	dock_knife = { name = "Dock Knife", slot = "tool", price = 40, minAge = 14, desc = "Short, ugly, honest.", effect = "+2 base power in Justice clashes", clash = { justice = { base = 2 } }, look = { kind = "knife" } },
	hook_pole = { name = "Hooked Pole", slot = "tool", price = 65, minAge = 12, desc = "Long enough to keep things at a distance.", effect = "+1 per-heads power in Justice clashes", clash = { justice = { coinPower = 1 } }, look = { kind = "pole" } },
	pocket_ledger = { name = "Pocket Ledger", slot = "tool", price = 45, desc = "Every debt, every favor, every name.", effect = "+2 base power in Temperance clashes", clash = { temperance = { base = 2 } }, look = { kind = "book", color = { 110, 70, 40 } } },
	tide_tables = { name = "Tide Tables", slot = "tool", price = 55, desc = "A sea-stained almanac of when the Mere rises and falls.", effect = "+1 coin in Prudence clashes", clash = { prudence = { coins = 1 } }, look = { kind = "book", color = { 52, 92, 96 } } },
	diving_lamp = { name = "Guild Diving Lamp", slot = "tool", price = 120, desc = "Only sold to the Lantern Guild. It stays lit underwater.", effect = "+1 coin in Fortitude clashes", requires = { career = "diver" }, clash = { fortitude = { coins = 1 } }, look = { kind = "lamp" } },
	oilskin = { name = "Oilskin Coat", slot = "coat", price = 50, desc = "Keeps the fog off, mostly.", effect = "+1 base in Fortitude clashes, hazards 15% less likely", clash = { fortitude = { base = 1 } }, hazardGuard = 0.85, look = { kind = "coat", color = { 156, 132, 62 } } },
	dock_jacket = { name = "Padded Dock Jacket", slot = "coat", price = 140, minAge = 14, desc = "Quilted canvas that has stopped more than one hook.", effect = "+1 base in Justice and Fortitude clashes", clash = { justice = { base = 1 }, fortitude = { base = 1 } }, look = { kind = "jacket", color = { 122, 98, 70 } } },
	company_greatcoat = { name = "Company Greatcoat", slot = "coat", price = 320, desc = "The cut alone tells the guards you belong inside.", effect = "hazards 30% less likely, +1 Sanity a year", requires = { side = "charter" }, hazardGuard = 0.7, yearly = { sanity = 1 }, look = { kind = "greatcoat", color = { 40, 46, 70 } } },
	still_stone = { name = "Still Stone", slot = "charm", price = 30, desc = "A smooth stone from the Choir's shore. Hold it and breathe.", effect = "+2 base power in Prudence clashes", clash = { prudence = { base = 2 } }, look = { kind = "stone", color = { 150, 152, 150 } } },
	little_bell = { name = "Little Bell", slot = "charm", price = 35, desc = "A Bellhollow charm that rings when nothing touches it.", effect = "+1 Sanity a year", yearly = { sanity = 1 }, look = { kind = "bell" } },
	lantern_token = { name = "Lantern Token", slot = "charm", price = 75, desc = "Brass, warm to the touch, stamped with a lantern.", effect = "+1 base in Justice and Prudence clashes", clash = { justice = { base = 1 }, prudence = { base = 1 } }, look = { kind = "token" } },
}

-- CONDITIONS: injuries and illnesses that last a few years. Gained through
-- results (`condition = "id"`), treated by a stitcher (`cure`), or they fade.
pack.conditions = {
	broken_arm = { name = "Broken Arm", years = 2, desc = "-1 coin in Justice clashes, -1 base in Temperance clashes.", gainLog = "Your arm is broken. It will take a long time to set.", clash = { justice = { coins = -1 }, temperance = { base = -1 } }, look = "cast" },
	fog_lung = { name = "Fog Lung", years = 3, desc = "Lose a little Fortitude every year.", gainLog = "The cough settled in for good. Fog lung.", yearly = { fortitude = { -2, -1 } }, look = "pale" },
	salt_cough = { name = "Salt Cough", years = 2, desc = "Lose a little Fortitude every year.", gainLog = "Salt dust lined your lungs. The cough won't leave.", yearly = { fortitude = { -1, 0 } }, look = "pale" },
	burned_hands = { name = "Burned Hands", years = 2, desc = "-2 base in Temperance clashes.", gainLog = "Your hands are burned and bandaged.", clash = { temperance = { base = -2 } }, look = "bandaged" },
	night_terrors = { name = "Night Terrors", years = 2, desc = "-2 Sanity a year, -1 base in Prudence clashes.", gainLog = "You started waking up shouting.", yearly = { sanity = -2 }, clash = { prudence = { base = -1 } }, look = "shadows" },
	grief = { name = "Grief", years = 1, curable = false, desc = "-2 Sanity this year.", gainLog = "Grief moved in and sat at the table.", healLog = "The grief eased into something you could carry.", yearly = { sanity = -2 }, look = "armband" },
	marked = { name = "Marked by the Kin", years = 4, curable = false, desc = "-1 Sanity a year. No stitcher can fix this.", gainLog = "The Brine Kin have marked you. Everyone in the Gutters knows.", healLog = "The Kin finally forgot your face.", yearly = { sanity = -1 }, look = "kinmark" },
}

-- CLASH CURVE: how a stat becomes clash power. One more coin every coinsEvery
-- points (up to maxCoins), +1 base every baseEvery, +1 per-heads power every
-- powerEvery. Foes are fixed (see each clash), so this sets how fast a trained
-- character outgrows them. Check the odds with: lune run tests/clash_table
pack.clash = { coinsEvery = 30, maxCoins = 4, baseEvery = 16, powerEvery = 50 }

-- APPROACHES: how you go into a coin clash. Picked on the event card.
pack.approaches = {
	order = { "steady", "reckless", "careful" },
	steady = { name = "Steady", desc = "Play it straight." },
	reckless = { name = "Reckless", desc = "+1 coin. Win or lose, it costs you.", clash = { coins = 1 }, after = { sanity = -4, fortitude = { -3, 0 }, log = "Going in reckless took something out of you." } },
	careful = { name = "Careful", desc = "+2 base power, one fewer coin.", clash = { base = 2, coins = -1 } },
}

-- RECORDS: achievements checked when a life ends. Each one is worth 1 Glow the first time.
-- check: { when = {conditions}, bornSide, minPeakMoney, minPeakRank, minMoves, heir, causeHas, minChildren }
pack.records = {
	{ id = "old_bones", name = "Old Bones", desc = "Live to 80.", check = { when = { minAge = 80 } } },
	{ id = "gone_too_soon", name = "Gone Too Soon", desc = "Die before 25.", check = { when = { maxAge = 24 } } },
	{ id = "through_the_gates", name = "Through the Gates", desc = "Born in the Gutters, died in the Charter.", check = { bornSide = "gutters", when = { side = "charter" } } },
	{ id = "fall_from_grace", name = "Fall from Grace", desc = "Born in the Charter, died in the Gutters.", check = { bornSide = "charter", when = { side = "gutters" } } },
	{ id = "never_saw_the_silt", name = "Never Saw the Silt", desc = "Born and died in the Charter.", check = { bornSide = "charter", when = { side = "charter" } } },
	{ id = "lantern_captain", name = "Lantern-Captain", desc = "Die at the top of the Lantern Guild.", check = { when = { career = "diver", minRank = 5 } } },
	{ id = "director", name = "Director", desc = "Die at the top of a Ward's company.", check = { when = { career = "company", minRank = 5 } } },
	{ id = "elder_kin", name = "Elder Kin", desc = "Die at the top of the Brine Kin.", check = { when = { career = "brine", minRank = 5 } } },
	{ id = "still_voice", name = "Still Voice", desc = "Die at the top of the Choir.", check = { when = { career = "choir", minRank = 4 } } },
	{ id = "came_up_gasping", name = "Came Up Gasping", desc = "Surface from your breaking point.", check = { when = { form = "surfaced" } } },
	{ id = "gone_to_the_water", name = "Gone to the Water", desc = "End a life Tidetouched.", check = { when = { form = "tidetouched" } } },
	{ id = "heavy_purse", name = "Heavy Purse", desc = "Hold 10,000 scrip at once.", check = { minPeakMoney = 10000 } },
	{ id = "wanderer", name = "Wanderer", desc = "Move house four times in one life.", check = { minMoves = 4 } },
	{ id = "family_line", name = "Family Line", desc = "Take in two children.", check = { minChildren = 2 } },
	{ id = "carried_on", name = "Carried On", desc = "Finish a life as someone's heir.", check = { heir = true } },
	{ id = "drownside_old", name = "Drownside Old-Timer", desc = "Live to 60 in Drownside.", check = { when = { district = "drownside", minAge = 60 } } },
	{ id = "not_alone", name = "Not Alone", desc = "Link lives with a friend.", check = { when = { flags = { "had_linked" } } } },
}

-- More activities live in their own modules (plain lists, same format).
for _, name in { "MoreActivities", "QuestActivities", "CareerActivities" } do
	for _, act in require(script:WaitForChild(name)) do
		table.insert(pack.activities, act)
	end
end

-- More careers (Content/MoreCareers.luau): { order = { ids }, [id] = career }.
do
	local more = require(script:WaitForChild("MoreCareers"))
	for _, id in more.order or {} do
		if more[id] and not pack.careers[id] then
			pack.careers[id] = more[id]
			table.insert(pack.careers.order, id)
		end
	end
end

-- EXPEDITIONS: missions, dungeons, trips (Content/Expeditions.luau).
pack.expeditions = require(script:WaitForChild("Expeditions"))
for _, name in { "MoreExpeditions", "QuestExpeditions" } do
	local more = require(script:WaitForChild(name))
	for _, id in more.order or {} do
		if more[id] and not pack.expeditions[id] then
			pack.expeditions[id] = more[id]
			table.insert(pack.expeditions.order, id)
		end
	end
end

-- QUESTS: multi-step side stories (Content/Quests.luau).
pack.quests = require(script:WaitForChild("Quests"))

-- WORLD EVENTS: things that happen to the whole server at once (Content/WorldEvents.luau).
pack.worldEvents = require(script:WaitForChild("WorldEvents"))

-- AMBITIONS: goals each life works toward, and TITLES every finished life gets.
pack.ambitions = require(script:WaitForChild("Ambitions"))
pack.ribbons = require(script:WaitForChild("Ribbons"))

-- COSMETICS: what characters look like (Content/Cosmetics.luau). Gear, conditions
-- and forms can also change the figure through their `look` fields.
pack.cosmetics = require(script:WaitForChild("Cosmetics"))

-- Yearly bad luck. Chance per year = side.hazardChance x district.danger.
-- More hazards live in Hazards.luau. side = nil means it can happen anywhere.
pack.hazards = require(script:WaitForChild("Hazards"))

pack.names = {
	first = {
		"Ossa", "Brann", "Ilse", "Teodor", "Mira", "Calla", "Dov", "Hesper", "Joss", "Nell",
		"Orrin", "Pell", "Tamsin", "Wren", "Yarrow", "Edda", "Fen", "Garrow", "Iver", "Jory",
		"Kell", "Lark", "Noor", "Odile", "Piet", "Roan", "Sorrel", "Una", "Bastian", "Agna",
		"Cyr", "Delphine", "Emrys", "Ferris", "Greer", "Hollis", "Isolde", "Jessamy", "Lowen", "Merrit",
	},
	last = {
		"Vell", "Marrow", "Coldwater", "Ashby", "Penhallow", "Drabb", "Kettering", "Mosswood", "Hollin", "Greaves",
		"Tarrant", "Brackwater", "Saltry", "Fenwick", "Duskin", "Harrow", "Voss", "Ingram", "Pellam", "Rook",
		"Stillman", "Underhill", "Wexley", "Ambry", "Corwen",
	},
}

-- Lines carved on a finished life's lantern. Picked by form, then career, then generic.
pack.epitaphs = {
	generic = {
		"The water remembers {first}.",
		"{first} kept a lamp lit for somebody.",
		"{first} owed nobody anything, in the end.",
		"Gone up the stairs for the last time.",
		"{first} heard the pumps every night, and slept anyway.",
	},
	career = {
		company = { "{first} gave the company forty years, and the company kept them.", "Filed, stamped, retired." },
		diver = { "A lantern goes down. A lantern comes up.", "{first} knew the drowned streets by heart." },
		stoker = { "{first} kept the Terraces dry.", "The pumps missed a beat when {first} went." },
		sluice = { "{first} signed a thousand papers and remembered a few.", "Stamped, filed, released." },
		brine = { "Cousin to everyone, debtor to no one.", "{first}'s ledger is closed." },
		choir = { "{first} is listening now.", "The silence was kind to {first}." },
	},
	form = {
		drowned = { "Something stands very still where {first} went under." },
		surfaced = { "{first} came up holding something, and never let go." },
		tidetouched = { "{first} went home to the water." },
	},
}

pack.deathCauses = {
	wounds = "Their body gave out",
	-- old age: one of these at random (a single string works too)
	oldAge = {
		"Died in their sleep, old and tired",
		"Fell asleep by the window, watching the lamps come on",
		"Went quietly, with the kettle still warm",
		"Slipped away in the night as the tide went out",
		"Died in their chair, halfway through a story",
		"Went to sleep and didn't wake, the kindest way there is",
		"Died old, in their own bed, with the rent paid",
	},
}

-- Engine hooks: event ids the engine fires on its own.
pack.hooks = {
	breakingPoint = "core_breaking_point", -- fired when sanity hits its minimum
}

-- Events are loaded from every ModuleScript in the Events folder.
local events = {}
local children = script:WaitForChild("Events"):GetChildren()
table.sort(children, function(a, b)
	return a.Name < b.Name
end)
for _, child in children do
	if child:IsA("ModuleScript") then
		local list = require(child)
		for _, event in list do
			event.source = child.Name
			table.insert(events, event)
		end
	end
end
pack.events = events

return pack
