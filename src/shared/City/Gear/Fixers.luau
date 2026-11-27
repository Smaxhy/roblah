--[[
	Gear from Workshops, Associations and the Thumb. Big-name Workshops only sell to licensed
	Fixers (canon: they turn no-names away). Association gear needs that Association's career.
	Fields: see Gear/Core.luau. look.kind must be a kind Engine/Avatar draws.
]]

return {
	order = { "fx_exam_primer", "fx_old_boys_hammer", "fx_mook_blade", "fn_thumb_pistol", "fx_zwei_coat", "fx_pyrojade_bangle" },

	fx_exam_primer = {
		name = "Hana Exam Primer",
		slot = "tool",
		price = 50,
		minAge = 12,
		desc = "A dog-eared book of past licensing questions: the Taboos, the hazard grades, which Finger is which. Every academy kid has one, and most have the answers written in.",
		effect = "+2 base power in Intelligence clashes, +1 base in Mental Strength clashes",
		clash = { intelligence = { base = 2 }, mind = { base = 1 } },
		look = { kind = "book", color = { 214, 196, 140 } },
	},
	fx_old_boys_hammer = {
		name = "Old Boys Workshop Hammer",
		slot = "tool",
		price = 480,
		minAge = 18,
		requires = { flags = { "licensed_fixer" } },
		desc = "Old Boys Workshop doesn't sell to just anyone, and its hammers outlive their owners. The maker's mark on the haft is worth half the price.",
		buyLog = "The clerk at Old Boys Workshop checked your license twice before taking your Ahn. The hammer was worth the wait.",
		effect = "+1 coin and +1 base in Health clashes, +2 base in Strength clashes",
		clash = { health = { coins = 1, base = 1 }, strength = { base = 2 } },
		look = { kind = "hammer", color = { 72, 70, 80 } },
	},
	fx_mook_blade = {
		name = "Mook Workshop Blade",
		slot = "tool",
		price = 560,
		minAge = 18,
		requires = { flags = { "licensed_fixer" } },
		desc = "A long single-edged blade from Mook Workshop, balanced so well it feels lighter than it is. Mook only takes orders from licensed Fixers.",
		buyLog = "Mook Workshop fitted the grip to your hand and stamped its mark below the guard.",
		effect = "+1 coin and +1 per-heads power in Strength clashes",
		clash = { strength = { coins = 1, coinPower = 1 } },
		look = { kind = "sword", color = { 206, 210, 222 } },
	},
	fn_thumb_pistol = {
		name = "Thumb-Issue Pistol",
		slot = "tool",
		price = 300,
		minAge = 16,
		requires = { flags = { "fn_thumb_member" } },
		desc = "A Thumb sidearm loaded with propellant rounds. Every bullet costs money, so every bullet is a decision.",
		effect = "+1 coin and +1 base in Strength clashes, -10 Ahn a year in bullets",
		clash = { strength = { coins = 1, base = 1 } },
		yearly = { money = -10 },
		look = { kind = "pistol", color = { 62, 52, 48 } },
	},
	fx_zwei_coat = {
		name = "Zwei Association Coat",
		slot = "coat",
		price = 240,
		minAge = 18,
		requires = { career = "zwei" },
		desc = "The heavy coat of a Zwei Fixer: the client's shield, in cloth. Rats cross the street when they see it.",
		effect = "+2 base in Health clashes, hazards 20% less likely",
		clash = { health = { base = 2 } },
		hazardGuard = 0.8,
		look = { kind = "greatcoat", color = { 40, 56, 96 } },
	},
	fx_pyrojade_bangle = {
		name = "Virescent Pyrojade Bangle",
		slot = "charm",
		price = 520,
		requires = { career = "cinq" },
		desc = "The green-flame bangle of the Cinq Association's Eastern branch. Its fire burns only what the wearer chooses.",
		effect = "+1 coin in Strength clashes",
		clash = { strength = { coins = 1 } },
		look = { kind = "token", color = { 90, 230, 140 } },
	},
}
