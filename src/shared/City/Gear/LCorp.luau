--[[
	E.G.O gear: weapons and suits extracted from Abnormalities by L Corp's Extraction Team.
	Each is handed out by an event (gear = "id") and sets a flag of the same name, so a
	life that has earned it can have it refitted at a workshop if it's lost. After the
	fall, E.G.O with the old logo still changes hands, and heirs inherit it.
	Fields: see Gear/Core.luau.
]]

return {
	order = { "lc_ego_penitence", "lc_ego_lament", "lc_ego_justitia", "lc_ego_lamp" },

	lc_ego_penitence = {
		name = "Penitence (E.G.O)",
		slot = "tool",
		price = 300,
		minAge = 18,
		desc = "ZAYIN E.G.O from One Sin and Hundreds of Good Deeds: a heavy mace capped with a hollow skull and a ring of thorns. It eases the mind of whoever carries it, as long as they know what justice is.",
		effect = "+1 base in Strength and Mental Strength clashes, +1 Sanity a year",
		requires = { flags = { "lc_ego_penitence" } },
		clash = { strength = { base = 1 }, mind = { base = 1 } },
		yearly = { sanity = 1 },
		look = { kind = "mace", color = { 206, 196, 176 } },
	},
	lc_ego_lament = {
		name = "Solemn Lament (E.G.O)",
		slot = "tool",
		price = 600,
		minAge = 18,
		desc = "HE E.G.O from The Funeral of the Dead Butterflies: two pistols, one black and one white. One grieves for the dead, the other mourns the living ahead of time. You'll find yourself speaking more quietly.",
		effect = "+1 coin and +1 base in Strength clashes, -1 Sanity a year",
		requires = { flags = { "lc_ego_lament" } },
		clash = { strength = { coins = 1, base = 1 } },
		yearly = { sanity = -1 },
		look = { kind = "pistol", color = { 34, 34, 40 } },
	},
	lc_ego_justitia = {
		name = "Justitia (E.G.O)",
		slot = "tool",
		price = 1200,
		minAge = 20,
		desc = "WAW E.G.O from Judgement Bird: a blade wrapped in bandages it doesn't want removed. It weighs whoever it's pointed at, and whoever holds it.",
		effect = "+2 base and +1 power per heads in Strength clashes, +1 base in Mental Strength clashes",
		requires = { flags = { "lc_ego_justitia" } },
		clash = { strength = { base = 2, coinPower = 1 }, mind = { base = 1 } },
		look = { kind = "sword", color = { 232, 228, 216 } },
	},
	lc_ego_lamp = {
		name = "Lamp (E.G.O Suit)",
		slot = "coat",
		price = 900,
		minAge = 20,
		desc = "WAW E.G.O from Big Bird: a dark, heavy suit hung with small lantern lights. It keeps the dark off you, and you'll catch yourself watching for a beast that never comes.",
		effect = "+1 base in Health and Mental Strength clashes, hazards 30% less likely",
		requires = { flags = { "lc_ego_lamp" } },
		clash = { health = { base = 1 }, mind = { base = 1 } },
		hazardGuard = 0.7,
		look = { kind = "greatcoat", color = { 42, 38, 56 } },
	},
}
