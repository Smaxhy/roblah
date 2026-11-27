--[[
	Limbus Company (the Distortion era): the LCCB, LCE and LCD departments. Writer D.
	Canon notes: docs/CANON.md sections 7.1 and 8.3 (Limbus Company).
	  LCCB  Clearance Before Team. Preliminary Observation is the lowest paid, the most
	        numerous and the most dangerous; "Assistant Manager" is a canon rank, and a
	        Preliminary Observer who survives can be promoted to Manager.
	  LCE   Enkephalin department: research under Chief Researcher Hohenheim.
	  LCD   Distortion department: management for paying clients, and the OSIR Team
	        (led by Moses) that solves Distortions by finding their Inflection Points.
	Rank-specific stories: Events/Limbus_Careers.luau (they check the rank flags below).
	Fields: name, desc, ranks, salary (per rank), minAge, requires (conditions: district,
	world.era, stats...), sides, guttersRequire (extra need from the Backstreets),
	promoteStat + promoteAt (stat needed for ranks 2..n), yearsPerRank, yearly, hazard,
	rankFlags = { [rank] = "flag" } (a lasting mark, for records and stories), sort (UI order).
	Every module in Careers/ is merged by init.luau; ids must be unique across files.
]]

return {
	order = { "limbus_lccb", "limbus_lce", "lim_lcd" },

	limbus_lccb = {
		sort = 16,
		name = "Limbus Company (LCCB)",
		teaches = "lccb",
		uniform = "bus_uniform",
		desc = "The Clearance Before Team: you scout buried L Corp branches before the bus arrives. Preliminary Observation is the lowest paid, biggest and most dangerous section in the company. Survive it, and you can make Manager.",
		ranks = { "Preliminary Observer", "Clearance Staff", "Senior Clearance Staff", "Assistant Manager", "Manager" },
		salary = { 55, 130, 240, 430, 760 },
		minAge = 18,
		requires = { world = { era = "limbus" }, min = { health = 30, mind = 25 } },
		promoteStat = "mind",
		promoteAt = { 40, 54, 68, 82 },
		yearsPerRank = 2,
		rankFlags = { [1] = "lim_limbus_staff", [2] = "lim_lccb_r2", [3] = "lim_lccb_r3", [4] = "lim_lccb_assistant", [5] = "lim_lccb_manager" },
		yearly = { sanity = { -1, 0 } },
		hazard = { chance = 0.13, result = { health = { -12, -5 }, sanity = { -5, -2 }, log = "The branch you scouted wasn't as empty as the map said.", cause = "Lost scouting a buried branch" } },
	},

	limbus_lce = {
		sort = 17,
		name = "Limbus Company (LCE)",
		uniform = "lab_coat",
		desc = "The Enkephalin department: research under Chief Researcher Hohenheim into Abnormalities, Distortions, Peccatula, and the E.G.O gear made from them. The gear's Attunement Boost wears on the people who test it.",
		ranks = { "Lab Assistant", "Researcher", "Senior Researcher", "Lead Researcher" },
		salary = { 90, 200, 380, 700 },
		minAge = 18,
		requires = { world = { era = "limbus" }, min = { intelligence = 38 } },
		promoteStat = "intelligence",
		promoteAt = { 50, 66, 82 },
		yearsPerRank = 3,
		rankFlags = { [1] = "lim_limbus_staff", [2] = "lim_lce_r2", [3] = "lim_lce_r3", [4] = "lim_lce_lead" },
		hazard = { chance = 0.07, result = { sanity = { -8, -3 }, condition = "lim_attunement_strain", log = "A gear test's Attunement Boost went further into your head than it should have." } },
	},

	lim_lcd = {
		sort = 18,
		name = "Limbus Company (LCD)",
		uniform = "bus_uniform",
		desc = "The Distortion department: Distortion management for paying clients, and the OSIR Team, who solve Distortions like detectives, by finding the moment they started. Notebooks first, weapons second.",
		ranks = { "LCD Case Clerk", "Field Investigator", "OSIR Investigator", "Senior OSIR Investigator", "Case Director" },
		salary = { 70, 150, 270, 450, 760 },
		minAge = 18,
		requires = { world = { era = "limbus" }, min = { mind = 35 } },
		promoteStat = "mind",
		promoteAt = { 46, 60, 72, 84 },
		yearsPerRank = 2,
		rankFlags = { [1] = "lim_limbus_staff", [2] = "lim_lcd_r2", [3] = "lim_lcd_r3", [4] = "lim_lcd_r4", [5] = "lim_lcd_director" },
		yearly = { sanity = { -1, 0 } },
		hazard = { chance = 0.09, result = { health = { -8, -2 }, sanity = { -7, -2 }, log = "A case went from Early stage to Late while you were still taking notes.", cause = "Lost on an LCD case" } },
	},
}
