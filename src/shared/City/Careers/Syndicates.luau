--[[
	The Fingers and other Syndicates: the Thumb, the Middle, the Index, the Ring, the Kurokumo Clan.
	Canon notes: docs/CANON.md sections 3, 8.6 and 12.
	* The Thumb: Soldato Primo, Secondo, Terzo, Quarto, then Capo I to IIII, then the Sottocapo who
	  runs an area. (The Capo dei capi, the "Padrino", is unique and not a career rank.)
	* The Middle: Little Sibling, Big Sibling, Great Sibling (game text has Great Brothers and
	  Great Sisters; a Big Sibling earns the title through a Pilgrimage of Loyalty).
	* The Index: Proselytes train under a Proxy; the trusted carry Prescripts as Messengers.
	* The Ring: Student, Docent, Maestro (a Maestro has founded a movement).
	* The Kurokumo Clan: Wakashu, then Captain (the top title is unknown, so none is used).
	rankFlags: [1] is the shared hook flag (fn_thumb_member, fn_middle_member, fn_index_proxy,
	fn_ring_member); higher ranks leave fn_ marks that events and records use.
	Fields: see Careers/Fixers.luau. Ids must be unique across files.
]]

return {
	order = { "thumb", "middle", "index", "ring", "kurokumo" },

	thumb = {
		regional = "branch", -- a regional branch, as in the Thumb East
		sort = 30,
		name = "the Thumb",
		issue = "fn_thumb_pistol", -- handed over on the first day, if your hands are empty
		teaches = "thumb",
		uniform = "thumb_suit",
		uniformTop = { rank = 9, outfit = "sottocapo_suit" },
		desc = "The Finger of propriety. Every rank from Soldato Primo to Sottocapo has its rules: when you eat, where you stand, how low you bow. Disrespect upward is punished. Bullets are expensive, so a Soldato thinks before shooting.",
		ranks = { "Soldato Primo", "Soldato Secondo", "Soldato Terzo", "Soldato Quarto", "Capo I", "Capo II", "Capo III", "Capo IIII", "Sottocapo" },
		salary = { 30, 50, 75, 110, 170, 250, 360, 520, 900 },
		minAge = 16,
		sides = { "backstreets" },
		requires = { min = { strength = 22, intelligence = 15 } },
		promoteStat = "strength",
		promoteAt = { 28, 35, 42, 50, 58, 66, 74, 84 },
		yearsPerRank = 2,
		rankFlags = { [1] = "fn_thumb_member", [5] = "fn_thumb_capo", [8] = "fn_thumb_capo_iiii", [9] = "fn_thumb_sottocapo" },
		hazard = { chance = 0.09, result = { health = { -10, -3 }, sanity = { -3, -1 }, log = "Someone above you decided you'd been disrespectful. You were corrected, at length.", cause = "Corrected by the Thumb" } },
	},

	middle = {
		regional = "branch", -- a regional branch, as in the Thumb East
		sort = 31,
		name = "the Middle",
		issue = "arm_middle_chain", -- handed over on the first day, if your hands are empty
		teaches = "middle",
		uniform = "middle_jacket",
		desc = "The Finger of loyalty: a family of Little Siblings, Big Siblings and Great Siblings, marked by their tattoos. The Middle remembers, and it always pays its debts, in whichever form. Grudges go in the Book of Vengeance.",
		ranks = { "Little Sibling", "Big Sibling", "Great Sibling" },
		salary = { 60, 240, 650 },
		minAge = 16,
		sides = { "backstreets" },
		requires = { min = { strength = 25 } },
		promoteStat = "strength",
		promoteAt = { 52, 88 },
		yearsPerRank = 5,
		rankFlags = { [1] = "fn_middle_member", [2] = "fn_middle_big", [3] = "fn_middle_great" },
		hazard = { chance = 0.08, result = { health = { -10, -3 }, log = "A grudge came due, and the family went to collect. You were in the front.", cause = "Collecting a grudge for the Middle" } },
	},

	index = {
		regional = "branch", -- a regional branch, as in the Thumb East
		sort = 32,
		name = "the Index",
		issue = "arm_index_blade", -- handed over on the first day, if your hands are empty
		teaches = "index",
		uniform = "index_whites",
		desc = "The Finger of faith. Prescripts arrive on slips of paper, and you carry them out exactly, however strange. Proselytes train under a Proxy; the trusted carry Prescripts to others as Messengers.",
		ranks = { "Proselyte", "Proxy", "Messenger" },
		salary = { 50, 220, 580 },
		minAge = 16,
		sides = { "backstreets" },
		requires = { min = { mind = 28 } },
		promoteStat = "mind",
		promoteAt = { 55, 82 },
		yearsPerRank = 4,
		rankFlags = { [1] = "fn_index_proxy", [2] = "fn_index_ranked_proxy", [3] = "fn_index_messenger" },
		hazard = { chance = 0.08, result = { sanity = { -8, -3 }, log = "A Prescript told you to do something you didn't want to do. You did it, to the letter." } },
	},

	ring = {
		regional = "branch", -- a regional branch, as in the Thumb East
		sort = 33,
		name = "the Ring",
		issue = "arm_ring_brush", -- handed over on the first day, if your hands are empty
		teaches = "ring",
		uniform = "ring_smock",
		desc = "The Finger of art and knowledge. Schools with their own ideas of beauty (Pointillists, Fauvists, Corporists), galleries by invitation, and art nobody else can stand to look at for long.",
		ranks = { "Student", "Docent", "Maestro" },
		salary = { 40, 230, 680 },
		minAge = 16,
		sides = { "backstreets" },
		requires = { min = { intelligence = 30 } },
		promoteStat = "intelligence",
		promoteAt = { 58, 88 },
		yearsPerRank = 4,
		yearly = { sanity = { -1, 0 } },
		rankFlags = { [1] = "fn_ring_member", [2] = "fn_ring_docent", [3] = "fn_ring_maestro" },
		hazard = { chance = 0.07, result = { sanity = { -8, -3 }, log = "A rival school reviewed your work. In person, and at length." } },
	},

	kurokumo = {
		sort = 34,
		name = "the Kurokumo Clan",
		issue = "arm_kurokumo_blade", -- handed over on the first day, if your hands are empty
		teaches = "kurokumo",
		uniform = "kurokumo_coat",
		uniformTop = { rank = 3, outfit = "clan_haori" }, -- (v0.17) a Captain wears the clan's haori
		desc = "A great Backstreets Syndicate of long sheathed blades and dark, wave-patterned coats. Protection fees, strict obedience, and an old feud with the Blade Lineage.",
		ranks = { "Wakashu", "Senior Wakashu", "Captain" },
		salary = { 45, 120, 380 },
		minAge = 16,
		sides = { "backstreets" },
		requires = { min = { strength = 25 } },
		promoteStat = "strength",
		promoteAt = { 45, 70 },
		yearsPerRank = 3,
		rankFlags = { [1] = "fn_kurokumo_member", [3] = "fn_kurokumo_captain" },
		hazard = { chance = 0.08, result = { health = { -10, -3 }, log = "A protection round turned into a sword fight in a narrow alley.", cause = "Cut down in a Kurokumo feud" } },
	},
}
