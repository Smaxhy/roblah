--[[
	REPUTATION: how each power in the City regards you. -100..100; everyone starts a stranger at 0.

	It moves when a result says so (rep = { thumb = -30 }), when you beat one of theirs in a fight
	(`beat`, through the foe's faction in Foes.luau), and when you join or rise in one of their
	careers (`careers`). Killing one of a Finger's own is -30: a blood debt.

	At `grudge` or worse they come to collect: once a year, by chance (surer the worse it is), one
	of the faction's `reprisal` events (Events/Reprisals.luau). Some of those are aimed at you.
	Some are aimed at the people you love.

	Small grudges and small favors fade a point at a time. A blood debt (-30 or worse) doesn't.

	Fields: name, short, color, emblem, flag (the storyGates flag: you know of them once they have
	an opinion of you), careers, beat, grudge, minAge, reprisal, grudgeNote, favorNote.
]]

return {
	order = { "thumb", "index", "middle", "ring", "kurokumo", "rats", "fixers", "wings", "lcorp", "bloodfiends", "limbus" },

	thumb = {
		name = "The Thumb",
		short = "Thumb",
		color = { 150, 40, 44 },
		emblem = "faction.thumb",
		flag = "knows_thumb",
		careers = { "thumb" },
		beat = -10,
		grudge = -20,
		reprisal = { "rep_thumb_correction", "rep_thumb_ledger", "rep_thumb_family", "rep_thumb_capo" },
		grudgeNote = "The Thumb keeps a ledger of every insult, by rank. Your name is in it.",
		favorNote = "Thumb Protection. Rats cross the street when they see you.",
	},
	index = {
		name = "The Index",
		short = "Index",
		color = { 206, 214, 232 },
		emblem = "faction.index",
		flag = "knows_index",
		careers = { "index" },
		beat = -8,
		grudge = -20,
		reprisal = { "rep_index_slip", "rep_index_proxy", "rep_index_loved" },
		grudgeNote = "Somewhere a Prescript has your name on it. Nobody decides when it's delivered.",
		favorNote = "Messengers nod to you. Doors you never knocked on are open.",
	},
	middle = {
		name = "The Middle",
		short = "Middle",
		color = { 196, 150, 70 },
		emblem = "faction.middle",
		flag = "knows_middle",
		careers = { "middle" },
		beat = -12,
		grudge = -15,
		reprisal = { "rep_middle_book", "rep_middle_same", "rep_middle_family" },
		grudgeNote = "You're written in the Book of Vengeance. The Middle repays in kind, with interest.",
		favorNote = "A Family that looks after its own counts you close to it.",
	},
	ring = {
		name = "The Ring",
		short = "Ring",
		color = { 190, 70, 140 },
		emblem = "faction.ring",
		flag = "knows_ring",
		careers = { "ring" },
		beat = -8,
		grudge = -20,
		reprisal = { "rep_ring_portrait", "rep_ring_exhibit" },
		grudgeNote = "The Ring has decided you'd make a fine subject.",
		favorNote = "The Docents leave your street out of their work.",
	},
	kurokumo = {
		name = "The Kurokumo Clan",
		short = "Kurokumo",
		color = { 60, 66, 96 },
		emblem = "faction.syndicate",
		flag = "knows_kurokumo",
		careers = { "kurokumo" },
		beat = -10,
		grudge = -20,
		reprisal = { "rep_kurokumo_wave", "rep_syndicate_shop" },
		grudgeNote = "The Dark Wave pays its debts at night, in the rain.",
		favorNote = "The Clan's Wakashu call you by name.",
	},
	-- (v0.18) The Rats aren't an outfit with a name to keep: they're the Backstreets' lowest, a
	-- crowd of bums with knives. Nobody keeps score of what happens to a Rat, so there's no
	-- standing with them, nothing lost for beating or killing one, and nobody who comes to collect
	-- (`nobody`: Engine/Sim.luau addRep, rollReprisal, repView).
	rats = {
		name = "The Rats",
		short = "Rats",
		color = { 140, 120, 90 },
		emblem = "faction.syndicate",
		flag = "knows_rats",
		nobody = true,
	},
	fixers = {
		name = "Hana and the Fixers",
		short = "Fixers",
		color = { 96, 150, 214 },
		emblem = "faction.fixers",
		flag = "knows_fixers",
		careers = { "fixer", "zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi", "hana" },
		beat = -8,
		grudge = -25,
		reprisal = { "rep_fixers_contract", "rep_fixers_blacklist" },
		grudgeNote = "There's a contract with your description on an Office board somewhere.",
		favorNote = "Offices take your word, and your jobs.",
	},
	wings = {
		name = "The Wings",
		short = "Wings",
		color = { 110, 190, 240 },
		emblem = "faction.wings",
		flag = "knows_wings",
		careers = { "wing", "kcorp", "wcorp_cleanup", "rcorp", "wg_tcorp", "wg_hcorp", "nest_clerk" },
		beat = -10,
		grudge = -25,
		reprisal = { "rep_wings_gate", "rep_wings_audit" },
		grudgeNote = "Nest gates read your face and stay shut.",
		favorNote = "Checkpoints wave you through.",
	},
	lcorp = {
		name = "Lobotomy Corporation",
		short = "L Corp",
		color = { 110, 255, 140 },
		emblem = "faction.lcorp",
		flag = "knows_lcorp",
		careers = { "lcorp_agent", "lcorp_research" },
		beat = -10,
		grudge = -25,
		reprisal = { "rep_wings_gate", "rep_wings_audit" },
		grudgeNote = "The Wing of District 12 has a file on you, and it isn't a personnel file.",
		favorNote = "District 12 treats you as one of its own.",
	},
	bloodfiends = {
		name = "The Families",
		short = "Families",
		color = { 200, 40, 52 },
		emblem = "faction.bloodfiend",
		flag = "knows_bloodfiends",
		careers = { "bf_family" },
		beat = -10,
		grudge = -20,
		reprisal = { "rep_family_night" },
		grudgeNote = "The Families have long memories and a great deal of time.",
		favorNote = "An elder of a Family has spoken for you.",
	},
	limbus = {
		name = "Limbus Company",
		short = "Limbus",
		color = { 214, 172, 84 },
		emblem = "faction.limbus",
		flag = "knows_limbus",
		careers = { "limbus_lccb", "limbus_lce", "lim_lcd" },
		beat = -8,
		grudge = -30,
		reprisal = { "rep_fixers_blacklist" },
		grudgeNote = "A red-eyed man on a bus has looked at you once, and remembered.",
		favorNote = "The company's cleanup teams know to leave your building standing.",
	},
}
