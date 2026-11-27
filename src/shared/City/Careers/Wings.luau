--[[
	The Wings: a District's own Wing (Feathers and their Classes), Lobotomy Corporation
	(Agents and research), K Corp, W Corp, R Corp, T Corp's Time Collection and the
	Hongyuan households of H Corp.
	Canon notes: docs/CANON.md sections 2, 5, 8.3 and 8.4.
	Fields: name, desc, ranks, salary (per rank), minAge, requires (conditions: district,
	world.era, stats...), sides, guttersRequire (extra need from the Backstreets),
	promoteStat + promoteAt (stat needed for ranks 2..n), yearsPerRank, yearly, hazard,
	rankFlags = { [rank] = "flag" } (a lasting mark, for records and stories), sort (UI order).
	`company = true` means the District's own Wing (its name comes from the District's corp).
	Every module in Careers/ is merged by init.luau; ids must be unique across files.

	L Corp only exists in the wings era (it falls in 978). Its ladders promote every two
	years once the Virtue is there, and events in Events/LCorp_*.luau promote too: a life
	born in the age of the Wings has time to climb to Branch Manager or Head of Research;
	one born just before the White Nights gets a few hard years and a Captain's armband
	if it's lucky.
]]

return {
	order = { "wing", "lcorp_agent", "lcorp_research", "kcorp", "wcorp_cleanup", "rcorp", "wg_tcorp", "wg_hcorp" },

	-- the District's own Wing: Feathers hold numbered Classes, Class 1 the lowest (CANON 8.3)
	wing = {
		sort = 10,
		company = true,
		name = "the Wing",
		uniform = "nest_suit",
		desc = "Work for the Wing that holds your District, as one of its Feathers. Staff hold numbered Classes and Class 1 is the bottom; Directors and Executives sit above Class 5. Good pay, a badge that opens checkpoints, and a company that owns a little of you.",
		ranks = { "Class 1 Staff", "Class 2 Staff", "Class 3 Specialist", "Class 4 Senior Staff", "Class 5 Auditor", "Director", "Executive" },
		salary = { 70, 110, 170, 250, 380, 600, 950 },
		minAge = 16,
		requires = { min = { intelligence = 30 } },
		guttersRequire = { min = { intelligence = 45 } },
		promoteStat = "intelligence",
		promoteAt = { 38, 46, 54, 62, 72, 84 },
		yearsPerRank = 3,
		rankFlags = { [1] = "wg_feather", [5] = "wg_class_five", [6] = "wg_director", [7] = "wg_executive" },
		hazard = { chance = 0.06, result = { sanity = { -6, -2 }, log = "The Wing cut a department to make the numbers. You watched them carry the desks out." } },
	},

	-- Lobotomy Corporation, the field side (CANON 5.4, 8.4)
	lcorp_agent = {
		sort = 11,
		name = "Lobotomy Corporation",
		issue = "arm_lcorp_baton", -- handed over on the first day, if your hands are empty
		uniform = "lcorp_suit",
		desc = "L Corp hires Clerks to keep its departments running and Agents to work inside the containment units. Agents rise from Level 1 to Level 5 as their Virtues grow, the longest-serving become Department Captains, and a rare few are given a branch to run. The pay is unheard of. So is the turnover.",
		ranks = { "Clerk", "Agent, Level 1", "Agent, Level 2", "Agent, Level 3", "Agent, Level 4", "Agent, Level 5", "Department Captain", "Branch Manager" },
		salary = { 80, 150, 220, 320, 450, 620, 850, 1400 },
		minAge = 18,
		requires = { district = "d12", world = { era = "wings" }, min = { health = 25, mind = 25 } },
		promoteStat = "mind",
		promoteAt = { 30, 38, 46, 54, 62, 70, 82 },
		yearsPerRank = 2,
		rankFlags = { [1] = "lcorp_employee", [2] = "lc_was_agent", [7] = "lcorp_captain", [8] = "lcorp_manager" },
		yearly = { sanity = { -2, 0 } },
		hazard = {
			chance = 0.1,
			result = {
				health = { -14, -5 },
				sanity = { -8, -3 },
				condition = "enkephalin_sick",
				setFlags = { "lc_breach_survivor", "saw_abnormality" },
				log = "A containment unit went quiet, then very loud. You came out of the corridor alone.",
				cause = "Lost in a containment breach",
			},
		},
	},

	-- Lobotomy Corporation, the science side (CANON 8.4)
	lcorp_research = {
		sort = 12,
		name = "L Corp Research",
		uniform = "lab_coat",
		desc = "The science side of Lobotomy Corporation: observation logs, Enkephalin yields, work-type studies and the Abnormality encyclopedia. You rise from Lab Assistant to Head of Research on the strength of your work. You'll learn things you can't unlearn.",
		ranks = { "Lab Assistant", "Observer", "Analyst", "Researcher", "Senior Researcher", "Project Lead", "Head of Research" },
		salary = { 70, 120, 190, 280, 420, 620, 950 },
		minAge = 18,
		requires = { district = "d12", world = { era = "wings" }, min = { intelligence = 35 } },
		promoteStat = "intelligence",
		promoteAt = { 40, 47, 54, 61, 69, 80 },
		yearsPerRank = 2,
		rankFlags = { [1] = "lcorp_employee", [7] = "lcorp_head_research" },
		yearly = { sanity = { -1, 0 } },
		hazard = {
			chance = 0.08,
			result = { sanity = { -8, -3 }, condition = "enkephalin_sick", setFlags = { "saw_abnormality" }, log = "You reviewed an observation log for a creature you had named yourself. You stopped naming them after that." },
		},
	},

	-- K Corp: Classes count upward from Class 1 rescue duty (CANON 8.3)
	kcorp = {
		sort = 13,
		name = "K Corp",
		issue = "arm_kcorp_injector", -- handed over on the first day, if your hands are empty
		teaches = "kcorp",
		uniform = "kcorp_whites",
		desc = "District 11's Wing and the maker of the HP Ampule. Classes count upward: Class 1 does rescue duty in the streets, Class 3 Excision Staff guard the labs, and the researchers above them perfect the ampules. One floor nobody below a Director has seen.",
		ranks = { "Class 1 Rescue Staff", "Class 2 Clerical Staff", "Class 3 Excision Staff", "Class 4 Researcher", "Class 5 Senior Researcher", "Lab Director" },
		salary = { 80, 120, 190, 290, 440, 720 },
		minAge = 18,
		requires = { district = "d11", min = { intelligence = 32 } },
		promoteStat = "intelligence",
		promoteAt = { 40, 48, 57, 67, 80 },
		yearsPerRank = 3,
		rankFlags = { [1] = "wg_kcorp_staff", [6] = "wg_kcorp_director" },
		hazard = { chance = 0.05, result = { sanity = { -6, -2 }, log = "A memory-wipe procedure was scheduled for your whole floor. You woke up missing a Tuesday." } },
	},

	-- W Corp: Cleanup Agents Level 1 to 5, CCA armor at Level 4+ (CANON 8.3)
	wcorp_cleanup = {
		sort = 14,
		name = "W Corp Cleanup Crew",
		issue = "arm_wcorp_baton", -- handed over on the first day, if your hands are empty
		teaches = "wcorp",
		uniform = "cleanup_jumpsuit",
		desc = "Someone has to tidy the WARP trains after every run. Cleanup Agents climb from Level 1 to Level 5: Level 3 trains recruits, Level 4 and up with top marks may wear the CCA power armor, and Level 5 handles the worst trains. The pay is good. Nobody says what they cleaned.",
		ranks = { "Cleanup Agent, Level 1", "Cleanup Agent, Level 2", "Cleanup Agent, Level 3", "Cleanup Agent, Level 4", "Cleanup Agent, Level 5", "Cleanup Captain" },
		salary = { 80, 130, 200, 300, 440, 620 },
		minAge = 18,
		requires = { district = "d23", min = { health = 30 } },
		promoteStat = "health",
		promoteAt = { 40, 48, 56, 64, 74 },
		yearsPerRank = 2,
		rankFlags = { [1] = "wg_warp_crew", [4] = "wg_warp_level4", [6] = "wg_warp_captain" },
		yearly = { sanity = { -1, 0 } },
		hazard = { chance = 0.1, result = { health = { -10, -4 }, sanity = { -6, -2 }, log = "A carriage came back from a run with its passengers... changed. You did your job.", cause = "Lost on a WARP cleanup" } },
	},

	-- R Corp: hatched soldiers, human contractors, three kinds of team (CANON 8.3)
	rcorp = {
		sort = 15,
		name = "R Corp Packs",
		issue = "arm_rcorp_rifle", -- handed over on the first day, if your hands are empty
		teachesRoll = { "rcorp_rabbit", "rcorp_reindeer", "rcorp_rhino" }, -- you don't pick your team
		uniform = "pack_fatigues",
		desc = "R Corp sells armies. Most of a Pack is hatched soldiers grown in the Hatchery; humans sign on as contractors. Every Pack has three teams: Rabbits for all-round work, Reindeer for antler-augmented fighters, Rhinos for heavy assault. They march out by the thousand.",
		ranks = { "Contract Recruit", "Packmate", "Veteran Packmate", "Team Leader", "Pack Commander" },
		salary = { 70, 140, 230, 360, 620 },
		minAge = 17,
		requires = { district = "d18", min = { health = 30, strength = 25 } },
		promoteStat = "strength",
		promoteAt = { 38, 50, 62, 76 },
		yearsPerRank = 2,
		rankFlags = { [1] = "wg_pack_member", [4] = "wg_pack_leader" },
		hazard = { chance = 0.14, result = { health = { -16, -6 }, sanity = { -5, -2 }, log = "The pack was sent somewhere it shouldn't have gone. Fewer of you came back.", cause = "Fell on an R Corp contract" } },
	},

	-- T Corp (District 20): Collection Staff, Clerical, VDCU, Audit (CANON 8.3)
	wg_tcorp = {
		sort = 18,
		name = "T Corp Time Collection",
		teaches = "tcorp",
		uniform = "tcorp_monochrome",
		desc = "T Corp sells and taxes time itself. Collection Staff go door to door for what people owe, in hours and days; Clerical Staff keep the ledgers; Class 5 Audit Staff are treated as very senior by everyone. You'll be issued a timepiece, and you'll learn to hear other people's run down.",
		ranks = { "Class 1 Collection Staff", "Class 2 Clerical Staff", "Class 3 VDCU Staff", "Class 4 Collector", "Class 5 Audit Staff" },
		salary = { 80, 130, 210, 330, 560 },
		minAge = 18,
		requires = { district = "d20", min = { mind = 32 } },
		guttersRequire = { min = { mind = 40 } },
		promoteStat = "mind",
		promoteAt = { 42, 54, 66, 80 },
		yearsPerRank = 3,
		rankFlags = { [1] = "wg_time_collector", [5] = "wg_time_auditor" },
		yearly = { sanity = { -1, 0 } },
		hazard = { chance = 0.06, result = { sanity = { -6, -2 }, money = { -40, -10 }, log = "A collection went badly. The debtor had nothing left to give but time, and you had to take it." } },
	},

	-- H Corp (District 8): the great houses of Hongyuan (CANON 8.3)
	wg_hcorp = {
		sort = 19,
		name = "Hongyuan Household",
		uniform = "hcorp_robe",
		desc = "District 8 is ruled by the Four Families under the Family Hierarch, and every great house needs servants, retainers and stewards. Serve a Family well and your room in Hongyuan grows. Fail it, and the room shrinks around you.",
		ranks = { "Household Servant", "Family Retainer", "Senior Retainer", "Chief Retainer", "Family Steward" },
		salary = { 60, 120, 210, 340, 560 },
		minAge = 16,
		requires = { district = "d8", min = { intelligence = 30 } },
		promoteStat = "intelligence",
		promoteAt = { 40, 54, 66, 80 },
		yearsPerRank = 3,
		rankFlags = { [1] = "wg_hongyuan_servant", [5] = "wg_family_steward" },
		hazard = { chance = 0.06, result = { sanity = { -5, -2 }, log = "Two Families quarreled over a seating plan, and someone had to take the blame. It was you." } },
	},
}
