--[[
	Traits earned in Fixer and Syndicate lives (none are pickable at creation).
	Fields: see Traits/Core.luau.
]]

return {
	order = { "fx_clean_reports", "fx_section_drilled", "fx_workshop_sponsor", "fn_knows_their_place", "fn_struck_from_book", "fn_not_worth_the_ink", "fn_prescript_grace" },

	fx_clean_reports = {
		name = "Clean Reports",
		desc = "Hana trusts your job reports, and so do clients. +1 base in Mental Strength and Intelligence checks.",
		category = "earned",
		clash = { mind = { base = 1 }, intelligence = { base = 1 } },
	},
	fx_section_drilled = {
		name = "Section-Drilled",
		desc = "An Association drilled you until the moves came without thinking. +1 base in fights, +3 Health.",
		category = "earned",
		stats = { health = 3 },
		fight = { base = 1 },
	},
	fx_workshop_sponsor = {
		name = "Workshop Sponsor",
		desc = "A Workshop keeps your weapon sharp for free, because your name sells their work. +1 power per heads in Strength clashes.",
		category = "earned",
		clash = { strength = { coinPower = 1 } },
	},
	fn_knows_their_place = {
		name = "Knows Their Place",
		desc = "You can tell a Capo from a Soldato across a crowded street, and you bow to exactly the right depth. +1 base in Mental Strength checks, +3 Mental Strength.",
		category = "earned",
		stats = { mind = 3 },
		clash = { mind = { base = 1 } },
	},
	fn_struck_from_book = {
		name = "Struck from the Book",
		desc = "Your name was written in the Middle's Book of Vengeance, and crossed out again. Nothing frightens you quite the same way now. +3 heads chance.",
		category = "earned",
		heads = 3,
	},
	fn_not_worth_the_ink = {
		name = "Not Worth the Ink",
		desc = "A Big Brother of the Middle opened his Book, looked at you, and decided you weren't worth the ink. You've felt oddly lucky ever since. +2 heads chance, +4 Sanity.",
		category = "earned",
		heads = 2,
		sanity = 4,
	},
	fn_prescript_grace = {
		name = "Grace of the Prescript",
		desc = "You carried out Prescripts to the letter until it felt like grace. +1 base in Intelligence checks, +2 heads chance.",
		category = "earned",
		heads = 2,
		clash = { intelligence = { base = 1 } },
	},
}
