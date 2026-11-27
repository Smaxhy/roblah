--[[
	Yearly hazards: plain bad luck that comes with where you live.
	Each year: chance = side.hazardChance x district.danger. If it hits, one
	hazard is picked by weight from those that match your side and `when`.
		side     "gutters" / "charter" / nil (anywhere)
		district optional Ward id (or list) this hazard is limited to
		when     normal conditions (minAge etc.)
		result   a normal result table (use `cause` for possibly fatal ones)
]]

return {
	-- ── the Gutters ──
	{
		id = "hz_mugged",
		title = "Jumped on the Stairs",
		side = "gutters",
		weight = 12,
		when = { minAge = 12 },
		result = { condition = "night_terrors", money = { -40, -8 }, fortitude = { -6, -2 }, sanity = -2, log = "Three shapes in the fog took your coat, your coins, and some of your nerve.", cause = "Beaten on the switchback stairs" },
	},
	{
		id = "hz_fire",
		title = "Fire in the Tenement",
		side = "gutters",
		weight = 7,
		result = { condition = "burned_hands", money = { -60, -15 }, fortitude = { -8, -2 }, sanity = -4, log = "A lamp tipped on the floor below. You got out with the clothes you were wearing.", cause = "Caught in a tenement fire" },
	},
	{
		id = "hz_fever",
		title = "Fog Fever",
		side = "gutters",
		weight = 9,
		result = { condition = "fog_lung", fortitude = { -10, -4 }, log = "The fog got into your chest and stayed for a month.", cause = "Fog fever" },
	},
	{
		id = "hz_rent",
		title = "The Rent Doubles",
		side = "gutters",
		weight = 8,
		when = { minAge = 18 },
		result = { money = { -50, -20 }, sanity = -3, log = "The landlord found a new number for the rent and nailed it to your door." },
	},
	{
		id = "hz_collapse",
		title = "The Stairs Give Way",
		side = "gutters",
		weight = 4,
		result = { condition = "broken_arm", fortitude = { -16, -6 }, sanity = -2, log = "A rotten landing gave way under you. You fell a whole floor.", cause = "Fell when the stairs gave way" },
	},
	{
		id = "hz_flood_room",
		title = "Water Under the Door",
		side = "gutters",
		weight = 6,
		when = { world = { water = "high" } },
		result = { money = { -35, -10 }, fortitude = { -4, -1 }, log = "High Water came under the door in the night and ruined everything at floor level." },
	},
	-- ── the Charter ──
	{
		id = "hz_pickpocket",
		title = "Light Fingers at the Gala",
		side = "charter",
		weight = 8,
		when = { minAge = 14, notDistrict = "drownside" },
		result = { money = { -80, -20 }, sanity = -1, log = "Someone very well dressed relieved you of your purse at a company gala." },
	},
	{
		id = "hz_riot",
		title = "The Gates Are Rushed",
		side = "charter",
		weight = 5,
		result = { fortitude = { -10, -3 }, sanity = -4, log = "A crowd from the Gutters broke through the gate on your street before the guards closed it again.", cause = "Trampled when the gates were rushed" },
	},
	{
		id = "hz_audit",
		title = "Company Inspection",
		side = "charter",
		weight = 6,
		when = { minAge = 18, notDistrict = "drownside" },
		result = { money = { -60, -20 }, sanity = -2, log = "Company inspectors found three violations in your house and fined you for all of them." },
	},
	{
		id = "hz_charter_levy",
		title = "The Levy Rises",
		side = "charter",
		weight = 7,
		when = { minAge = 18, notDistrict = "drownside" },
		result = { money = { -90, -40 }, sanity = -2, log = "The company raised your residence levy and back-dated it a full year." },
	},
	{
		id = "hz_charter_nerves",
		title = "A Season of Nerves",
		side = "charter",
		weight = 6,
		when = { minAge = 12 },
		result = { sanity = { -6, -3 }, log = "Talk of riots at the gate kept you awake all season, listening for the bell." },
	},
	-- ── anywhere ──
	{
		id = "hz_tram",
		title = "Runaway Tram",
		weight = 3,
		when = { minAge = 8 },
		result = { fortitude = { -14, -4 }, log = "A tram lost its brake on the switchback and you didn't jump quite fast enough.", cause = "Hit by a runaway tram" },
	},
	{
		id = "hz_lamps_out",
		title = "Every Lamp Goes Out",
		weight = 4,
		result = { sanity = { -6, -3 }, log = "Every lamp on your street went out at once, and something walked past your window in the dark." },
	},
	-- ── one Ward only ──
	{
		id = "hz_gatewater_overflow",
		title = "The Gates Open Early",
		side = "gutters",
		district = "gatewater",
		weight = 8,
		when = { world = { water = "high" } },
		result = {
			money = { -30, -10 },
			fortitude = { -8, -2 },
			log = "Gatewater opened its floodgates early to keep the Exchange cellars dry, and your street took the overflow.",
			cause = "Swept away by floodgate overflow",
		},
	},
	{
		id = "hz_lampwick_lamp_flare",
		title = "Cheap Oil Flares",
		side = "gutters",
		district = "lampwick",
		weight = 9,
		result = {
			money = { -30, -8 },
			fortitude = { -8, -2 },
			log = "Watered ration oil flared in your lamp and set the curtains burning before you smothered it.",
			cause = "Burned when a ration lamp flared",
		},
	},
	{
		id = "hz_saltpan_salt_lung",
		title = "Salt in the Lungs",
		side = "gutters",
		district = "saltpan",
		weight = 10,
		when = { minAge = 12 },
		result = { condition = "salt_cough", fortitude = { -8, -3 }, log = "Salt dust off the evaporation pans settled in your lungs, and the cough stayed till spring.", cause = "Salt lung" },
	},
	{
		id = "hz_glasswall_pane",
		title = "A Pane Falls",
		side = "charter",
		district = "glasswall",
		weight = 8,
		result = {
			fortitude = { -9, -3 },
			sanity = -2,
			log = "A loose pane slid off a greenhouse roof and caught you a glancing blow on the way down.",
			cause = "Struck by a falling greenhouse pane",
		},
	},
	{
		id = "hz_ropewalk_cable",
		title = "A Dock Cable Snaps",
		district = "ropewalk",
		weight = 9,
		when = { minAge = 10 },
		result = {
			fortitude = { -14, -4 },
			sanity = -2,
			log = "A loaded cable snapped on the Ropewalk docks and whipped past close enough to knock you flat.",
			cause = "Struck by a snapping dock cable",
		},
	},
	{
		id = "hz_pumpside_steam_main",
		title = "A Steam Main Bursts",
		district = "pumpside",
		weight = 8,
		result = {
			fortitude = { -10, -3 },
			sanity = -1,
			log = "A steam main burst under the street outside your door and scalded you along with half the block.",
			cause = "Scalded by a burst steam main",
		},
	},
	{
		id = "hz_foundry_smog",
		title = "Smog on the Chest",
		side = "gutters",
		district = "foundry",
		weight = 10,
		result = { condition = "fog_lung", fortitude = { -9, -3 }, sanity = -1, log = "The Foundry smog settled on your chest for a whole winter and coughed you thin.", cause = "Choked by the Foundry smog" },
	},
	{
		id = "hz_foundry_brawl",
		title = "Wrong End of a Quarrel",
		district = "foundry",
		weight = 7,
		when = { minAge = 14 },
		result = {
			fortitude = { -11, -4 },
			sanity = -2,
			log = "A quarrel outside the chain shop spilled into the street, and you were in the way.",
			cause = "Caught in a Foundry Row brawl",
		},
	},
	{
		id = "hz_drownside_wreckers",
		title = "Wreckers in the Night",
		district = "drownside",
		weight = 10,
		result = {
			money = { -50, -15 },
			fortitude = { -6, -1 },
			sanity = -2,
			log = "Wreckers pried your shutters open in the night and carried off everything that would float.",
			cause = "Caught by wreckers in Drownside",
		},
	},
}
