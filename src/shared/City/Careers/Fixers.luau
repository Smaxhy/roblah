--[[
	Fixers and the Associations.
	Canon notes: docs/CANON.md sections 4, 8.1 and 8.5.
	* The Office ladder: Hana grades a Fixer from Grade 9 (lowest) to Grade 1 from their job
	  reports. Signing with an Office means passing Hana's licensing exam (the stat bar stands
	  for it); the exam itself is also an activity and a world event, with its own scene.
	  Every Fixer must belong to an Office or an Association; a one-person Office counts.
	* Association ladders: numbered Sections, where LOWER NUMBERS ARE MORE SENIOR (Section 6 is
	  the newest, Section 1 the elite), then Section Directors. Each Association runs its own
	  entrance test and reports the result to Hana (Limbus game text), so joining one licenses
	  you too. Association Fixers can't choose their jobs. Hana, the First, takes the sharpest.
	rankFlags leave lasting marks used by events (there is no maxRank condition, so
	"Grade 9 or 8 only" events use notFlags = { "fx_grade_seven" }):
		fixer: [1] licensed_fixer, [3] fx_grade_seven, [5] fx_grade_five, [7] senior_fixer (Grade 3),
		       [9] grade_one_fixer
		Associations: [1] licensed_fixer, [4] fx_section_three, [6] fx_section_director
	Fields: name, desc, ranks, salary (per rank), minAge, requires (conditions), sides,
	guttersRequire, promoteStat + promoteAt (stat needed for ranks 2..n), yearsPerRank, yearly,
	hazard, rankFlags = { [rank] = "flag" }, sort (UI order).
	Every module in Careers/ is merged by init.luau; ids must be unique across files.
]]

-- the Association ladder: Section 6 is the newest, Section 1 the most senior
local SECTIONS = { "Section 6 Fixer", "Section 5 Fixer", "Section 4 Fixer", "Section 3 Fixer", "Section 2 Fixer", "Section 2 Director", "Section 1 Director" }
local SECTION_PAY = { 90, 140, 210, 300, 420, 600, 860 }
local SECTION_AT = { 42, 50, 58, 66, 76, 86 }

return {
	order = { "fixer", "zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi", "hana" },

	fixer = {
		sort = 20,
		name = "a Fixer Office",
		teachesRoll = { "office_tremor", "office_rupture", "office_bleed", "office_burn", "office_sinking", "office_poise", "office_charge" },
		uniform = "fixer_coat",
		desc = "A licensed Fixer in an Office: escorts, retrievals, investigations, and fights you didn't start. Signing on means passing Hana's licensing exam; then Hana grades you from your job reports, Grade 9 up to Grade 1.",
		ranks = { "Grade 9 Fixer", "Grade 8 Fixer", "Grade 7 Fixer", "Grade 6 Fixer", "Grade 5 Fixer", "Grade 4 Fixer", "Grade 3 Fixer", "Grade 2 Fixer", "Grade 1 Fixer" },
		salary = { 40, 60, 85, 120, 170, 240, 340, 480, 700 },
		minAge = 16,
		requires = { min = { strength = 20 } },
		promoteStat = "strength",
		promoteAt = { 26, 33, 40, 48, 56, 64, 72, 82 },
		yearsPerRank = 2,
		rankFlags = { [1] = "licensed_fixer", [3] = "fx_grade_seven", [5] = "fx_grade_five", [7] = "senior_fixer", [9] = "grade_one_fixer" },
		hazard = { chance = 0.07, result = { health = { -10, -3 }, sanity = { -4, -1 }, log = "A job went wrong in a way the client hadn't mentioned. You filed the report from a clinic bed.", cause = "Killed on a Fixer job" } },
	},

	zwei = {
		regional = "section", -- "South Section 4": the branch of the region you work in
		sort = 21,
		name = "the Zwei Association",
		issue = "arm_zwei_shield", -- handed over on the first day, if your hands are empty
		teaches = "zwei",
		uniform = "zwei_style",
		uniformTop = { rank = 6, outfit = "zwei_plate" }, -- (v0.17) the Directors wear the instructors' plate
		desc = "The Second Association: protection and public peace. Zwei calls itself the client's shield, and takes border-guard contracts too. Starts in Section 6; lower Sections are more senior. Association Fixers don't choose their jobs. Entry is by its own exam, which licenses you.",
		ranks = SECTIONS,
		salary = SECTION_PAY,
		minAge = 18,
		requires = { min = { health = 40 } },
		promoteStat = "health",
		promoteAt = SECTION_AT,
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [4] = "fx_section_three", [6] = "fx_section_director" },
		hazard = { chance = 0.07, result = { health = { -9, -3 }, log = "You held a line you were paid to hold. It held. You barely did.", cause = "Fell holding the line" } },
	},

	liu = {
		regional = "section", -- "South Section 4": the branch of the region you work in
		sort = 22,
		name = "the Liu Association",
		issue = "arm_liu_gauntlets", -- handed over on the first day, if your hands are empty
		teaches = "liu",
		uniform = "liu_style",
		uniformTop = { rank = 6, outfit = "liu_elder_robe" }, -- (v0.17) the Directors wear the elders' robe
		desc = "The Sixth Association: fights between groups. Every Liu Fixer is trained to take on several opponents at once, and their weapons have incendiaries built in. Easygoing, cooperative, and usually near something on fire. Entry is by its own exam, which licenses you.",
		ranks = SECTIONS,
		salary = SECTION_PAY,
		minAge = 18,
		requires = { min = { strength = 40 } },
		promoteStat = "strength",
		promoteAt = SECTION_AT,
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [4] = "fx_section_three", [6] = "fx_section_director" },
		hazard = { chance = 0.08, result = { health = { -9, -3 }, condition = "burns", log = "A brawl got out of hand, and so did your own weapon's incendiary.", cause = "Killed in an Association brawl" } },
	},

	seven = {
		regional = "section", -- "South Section 4": the branch of the region you work in
		sort = 23,
		name = "the Seven Association",
		issue = "arm_seven_cane", -- handed over on the first day, if your hands are empty
		teaches = "seven",
		uniform = "seven_style",
		desc = "The Seventh Association: intelligence and investigation, by whatever means the contract allows. You find out what the client wants to know, and sometimes more. Entry is by its own exam, which licenses you.",
		ranks = SECTIONS,
		salary = SECTION_PAY,
		minAge = 18,
		requires = { min = { mind = 40 } },
		promoteStat = "mind",
		promoteAt = SECTION_AT,
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [4] = "fx_section_three", [6] = "fx_section_director" },
		hazard = { chance = 0.06, result = { sanity = { -7, -2 }, health = { -3, 0 }, log = "You found out exactly what the client wanted to know. Someone else found out that you knew." } },
	},

	devyat = {
		regional = "section", -- "South Section 4": the branch of the region you work in
		sort = 24,
		name = "the Devyat' Association",
		issue = "arm_courier_trunk", -- handed over on the first day, if your hands are empty
		teaches = "devyat",
		uniform = "devyat_style",
		desc = "The Ninth Association: couriers with dimensional Courier Trunks and a helper program, Poludnitsa, that pushes you harder when a deadline is close. Devyat' is never late. Entry is by its own exam, which licenses you.",
		ranks = SECTIONS,
		salary = { 80, 130, 200, 290, 400, 580, 830 },
		minAge = 18,
		requires = { min = { intelligence = 35, health = 35 } },
		promoteStat = "intelligence",
		promoteAt = SECTION_AT,
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [4] = "fx_section_three", [6] = "fx_section_director" },
		hazard = { chance = 0.06, result = { health = { -8, -2 }, sanity = { -3, -1 }, log = "A deadline came down to the second. You made it. Your legs didn't stop shaking for a day.", cause = "Lost racing a Devyat' deadline" } },
	},

	shi = {
		regional = "section", -- "South Section 4": the branch of the region you work in
		sort = 25,
		name = "the Shi Association",
		issue = "fc_shi_needle", -- handed over on the first day, if your hands are empty
		teaches = "shi",
		uniform = "shi_robe",
		desc = "The Fourth Association: the quietest, most dangerous contracts in the City, takedowns of people with very powerful enemies. Patient, precise, expensive. Entry is by its own exam, which licenses you.",
		ranks = SECTIONS,
		salary = { 100, 160, 240, 340, 470, 660, 940 },
		minAge = 18,
		requires = { min = { strength = 45, mind = 35 } },
		promoteStat = "strength",
		promoteAt = SECTION_AT,
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [4] = "fx_section_three", [6] = "fx_section_director" },
		yearly = { sanity = { -1, 0 } },
		hazard = { chance = 0.08, result = { health = { -10, -3 }, sanity = { -3, -1 }, log = "A quiet contract went loud. You got out, which is more than the plan promised.", cause = "Lost on a Shi contract" } },
	},

	cinq = {
		regional = "section", -- "South Section 4": the branch of the region you work in
		sort = 26,
		name = "the Cinq Association",
		issue = "arm_cinq_rapier", -- handed over on the first day, if your hands are empty
		teaches = "cinq",
		uniform = "cinq_style",
		desc = "The Fifth Association: duels by contract. When a client's honor is at stake, a Cinq Fixer stands in for them. The West throws a glove and wears a cape; the East announces its name and fights hand to hand. Entry is by its own exam, which licenses you.",
		ranks = SECTIONS,
		salary = SECTION_PAY,
		minAge = 18,
		requires = { min = { strength = 42 } },
		promoteStat = "strength",
		promoteAt = SECTION_AT,
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [4] = "fx_section_three", [6] = "fx_section_director" },
		hazard = { chance = 0.07, result = { health = { -9, -3 }, log = "A duel by contract went the full distance. You won on points and lost on everything else.", cause = "Fell in a contract duel" } },
	},

	dieci = {
		regional = "section", -- "South Section 4": the branch of the region you work in
		sort = 27,
		name = "the Dieci Association",
		issue = "arm_dieci_key", -- handed over on the first day, if your hands are empty
		teaches = "dieci",
		uniform = "dieci_coat",
		desc = "The Tenth Association: collectors and students of knowledge. Their gear turns what you know into strength, and what you spend is gone. They fight with fists and keys. Entry is by its own exam, which licenses you.",
		ranks = SECTIONS,
		salary = SECTION_PAY,
		minAge = 18,
		requires = { min = { intelligence = 45 } },
		promoteStat = "intelligence",
		promoteAt = SECTION_AT,
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [4] = "fx_section_three", [6] = "fx_section_director" },
		hazard = { chance = 0.06, result = { health = { -7, -2 }, intelligence = { -2, -1 }, log = "You spent a piece of knowledge to win a fight. You can't remember now what it was.", cause = "Fell on a Dieci contract" } },
	},

	oufi = {
		regional = "section", -- "South Section 4": the branch of the region you work in
		sort = 28,
		name = "the Öufi Association",
		issue = "arm_oufi_halberd", -- handed over on the first day, if your hands are empty
		teaches = "oufi",
		uniform = "oufi_suit",
		desc = "The Eleventh Association: contracts. Öufi Fixers observe signings, notarize wills and duels, and see every notarized contract carried out. Gaudy hats, axe-bladed weapons, one warning. Entry is by its own exam, which licenses you.",
		ranks = SECTIONS,
		salary = SECTION_PAY,
		minAge = 18,
		requires = { min = { mind = 45 } },
		promoteStat = "mind",
		promoteAt = SECTION_AT,
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [4] = "fx_section_three", [6] = "fx_section_director" },
		hazard = { chance = 0.06, result = { health = { -7, -2 }, sanity = { -5, -2 }, log = "A party broke a contract you were observing. You gave the first and final warning, and then you enforced it.", cause = "Enforcing an Öufi contract" } },
	},

	hana = {
		sort = 29,
		name = "the Hana Association",
		trainsAny = true, -- Hana takes the best from everywhere; they keep the school they came with
		uniform = "hana_formal",
		desc = "The First Association runs the Fixer system itself: licenses, grades, hazard levels, Office credit, and the Colors. It is made up of high-grade Fixers, and its own exam is the hardest in the City. Experienced Fixers get invited.",
		ranks = { "Hana Examiner", "Hana Assessor", "Hazard Assessor", "Credit Committee Assessor", "Hana Section Director" },
		salary = { 160, 260, 400, 600, 920 },
		minAge = 24,
		requires = { min = { mind = 62 } },
		promoteStat = "mind",
		promoteAt = { 55, 66, 78, 90 },
		yearsPerRank = 3,
		rankFlags = { [1] = "licensed_fixer", [5] = "fx_section_director" },
		hazard = { chance = 0.05, result = { sanity = { -6, -2 }, health = { -4, 0 }, log = "You downgraded a Fixer's license. They came to the Hana office to discuss it, with a weapon." } },
	},
}
