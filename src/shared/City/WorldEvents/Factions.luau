--[[
	Faction wars (writer: fc_ ids): server-wide, a few minutes long. Each has a start event
	everyone old enough sees (pick a side, profiteer, or hide), war scenes gated with
	when = { worldEvent = id }, and an aftermath a year later that pays the winning side.
	Who wins depends on the District (see the lists at the top of Events/Factions_Wars.luau),
	so a citywide war goes different ways in different places. Scenes: Events/Factions_Wars.luau.
	None of them run during the White Nights and Dark Days.
]]

local ERAS = { "wings", "library", "limbus" }

return {
	order = { "fc_we_thumb_middle", "fc_we_liu_shi", "fc_we_feathers", "fc_we_families", "fc_we_crusade", "fc_we_crackdown" },

	fc_we_thumb_middle = {
		name = "The Thumb and the Middle",
		headline = "TWO FINGERS ARE AT WAR",
		text = "A Soldato left a Big Sister's title off her name at a funeral. The Thumb wants an apology; the Middle has written a Capo into the Book of Vengeance. Shutters are coming down all over the Backstreets.",
		minutes = 8,
		weight = 2,
		tone = "danger",
		district = "d4",
		when = { world = { era = ERAS } },
		tagWeights = { fc_tm = 8, fingers = 2, crime = 1.3 },
		startEvent = "fc_tm_start",
		expedition = "fc_exp_hold_street",
		endText = "The Thumb and the Middle have agreed on something, quietly. The shutters go up one street at a time.",
	},
	fc_we_liu_shi = {
		name = "Fire and Silence",
		headline = "THE LIU AND THE SHI HAVE CONTRACTS ON THE SAME MAN",
		text = "A Liu Section is paid to keep a shipping magnate alive. A Shi Section is paid to make sure he isn't. Neither Association chose the job, and both will finish it. The streets around his tea house are emptying.",
		minutes = 7,
		weight = 2,
		tone = "danger",
		district = "d16",
		when = { world = { era = ERAS } },
		tagWeights = { fc_ls = 8, fixers = 2 },
		startEvent = "fc_ls_start",
		expedition = "fc_exp_tea_house",
		endText = "The contract is finished, one way or the other. The Liu put out their fires. The Shi were never there.",
	},
	fc_we_feathers = {
		name = "Feathers in the Street",
		headline = "K CORP AND R CORP FEATHERS ARE FACING OFF",
		text = "An R Corp Rabbit team chased a deserter across a District line, and K Corp's Excision Staff met them at the checkpoint. Both Wings have Feathers in the Backstreets now, and neither will leave first.",
		minutes = 7,
		weight = 2,
		tone = "danger",
		district = "d11",
		when = { world = { era = ERAS } },
		tagWeights = { fc_fe = 8, kcorp = 2, rcorp = 2 },
		startEvent = "fc_fe_start",
		expedition = "fc_exp_depot",
		endText = "Both Wings call it a misunderstanding, now resolved. The Zwei go home, and the Backstreets count their windows.",
	},
	fc_we_families = {
		name = "Red Eyes on the Rooftops",
		headline = "THE ROOFTOPS ARE NOT SAFE AFTER MIDNIGHT",
		text = "Two Bloodfiend Families, the Morvaine and the Corveaux, are fighting over whose nights these are. Fixer Offices are tripling their rates for contracts on red-eyed individuals. Lock your windows.",
		minutes = 7,
		weight = 2,
		tone = "strange",
		district = "d16",
		when = { world = { era = ERAS } },
		tagWeights = { fc_bf = 8, night = 1.5 },
		startEvent = "fc_bf_start",
		endText = "An Elder's Hand carried terms across the rooftops. The Families have agreed whose nights are whose, in writing.",
	},
	fc_we_crusade = {
		name = "The Index on the March",
		headline = "EVERY PROSELYTE GOT THE SAME SLIP",
		text = "At noon every Proselyte of the Index in the District received the same Prescript: one word, Kurokumo. Nobody knows what it means. The Index is walking into the Clan's streets, and the Clan is drawing its long blades.",
		minutes = 7,
		weight = 2,
		tone = "danger",
		district = "d7",
		when = { world = { era = ERAS } },
		tagWeights = { fc_ix = 8, fingers = 2 },
		startEvent = "fc_ix_start",
		expedition = "fc_exp_hold_street",
		endText = "The slips have stopped. The Proselytes have gone home, and so have the Kurokumo, mostly.",
	},
	fc_we_crackdown = {
		name = "The Crackdown",
		headline = "HANA IS CHECKING LICENSES",
		text = "Hana Examiners in gray, with Zwei shields behind them, are sealing job boards and checking every Fixer's license, street by street. Anyone caught working without one pays, one way or another.",
		minutes = 6,
		weight = 2,
		district = "d4",
		when = { world = { era = ERAS } },
		tagWeights = { fc_hc = 8, fixers = 2 },
		startEvent = "fc_hc_start",
		endText = "Hana unseals the job boards. The list of fines goes up beside the list of new licenses, and both are long.",
	},
}
