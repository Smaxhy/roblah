--[[
	TURF (v0.13): the streets of a Backstreets District, block by block (Engine/Turf.luau).
	Six blocks a District, each held by someone: the Rats, a local Syndicate, one of the
	Fingers' street operations, or the Kurokumo Clan. A grown life on the Backstreets can step
	into it (Activities/Turf.luau), alone or under someone's colours, take blocks one fight at a
	time, defend them when the year brings a raid (Events/Turf_Wars.luau), and collect what
	they pay. Hold all six and the District is yours in all but name.
	Canon: Syndicates, Rats and the Fingers carve up the Backstreets between them, and nobody
	polices the streets but whoever is strongest [LoR, Limbus]. The blocks are this game's own.
]]

return {
	minAge = 18,
	count = 6,
	blocks = {
		"the noodle row under the overpass",
		"the laundry court",
		"Ninth Alley",
		"the old tram stop",
		"the pawn arcade",
		"the night stalls",
		"the clinic corner",
		"the workshop yard",
		"the shuttered cinema",
		"the water tower steps",
		"the canal stairs",
		"the courier depot",
		"the rooftop gardens",
		"the bathhouse lane",
	},
	factions = {
		rats = { name = "the Rats", color = { 150, 128, 104 }, foe = "rat_boss", rep = "rats" },
		syndicate = { name = "a Syndicate", color = { 116, 120, 170 }, foe = "syndicate" },
		thumb = { name = "the Thumb", color = { 168, 46, 50 }, foe = "thumb_soldato", rep = "thumb" },
		middle = { name = "the Middle", color = { 214, 176, 92 }, foe = "middle_sibling", rep = "middle" },
		kurokumo = { name = "the Kurokumo Clan", color = { 70, 74, 96 }, foe = "kurokumo", rep = "kurokumo" },
		crew = { name = "your own crew", color = { 236, 206, 128 } },
		you = { name = "you", color = { 236, 206, 128 } },
	},
	contest = { "rats", "syndicate", "syndicate", "thumb", "middle", "kurokumo" },
	-- what each block you hold pays a year, and the renown it adds
	income = 55,
	renown = 1,
	-- the event a held street brings, some years (more blocks, more often)
	raid = "turf_raid",
}
