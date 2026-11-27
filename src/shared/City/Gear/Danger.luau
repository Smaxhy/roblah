--[[
	Unique keepsakes from the deadly expeditions (Expeditions/Danger.luau). Never sold.
	Fields: see Gear/Core.luau.
]]

return {
	order = { "dz_night_token", "dz_outskirts_fang", "dz_nine_key" },

	dz_night_token = {
		name = "Brass Night Token",
		slot = "charm",
		rarity = "epic",
		unique = true,
		desc = "The client pressed it into your hand at dawn. It is warm at 3:13, every night.",
		effect = "Bad luck 35% less likely. +1 Sanity a year. Debuff: -2% heads (it hums when you need quiet).",
		hazardGuard = 0.65,
		yearly = { sanity = 1 },
		heads = -2,
		look = { kind = "token", color = { 214, 172, 84 } },
	},
	dz_outskirts_fang = {
		name = "Outskirts Fang",
		slot = "charm",
		rarity = "epic",
		unique = true,
		desc = "A tooth as long as your hand, from something past the last wall. People give you room.",
		effect = "+1 base and +1 potency in fights. You take 10% less Health damage. Debuff: -1 Sanity a year.",
		fight = { base = 1, potency = 1 },
		toughness = 0.9,
		yearly = { sanity = -1 },
		look = { kind = "token", color = { 230, 226, 210 } },
	},
	dz_nine_key = {
		name = "The Number Nine Key",
		slot = "charm",
		rarity = "legendary",
		unique = true,
		desc = "It opens a door that isn't there anymore. Sometimes you hear it being knocked on.",
		effect = "+2 coins in Mental Strength checks. Resists Sinking 2. Debuff: -2 Sanity a year.",
		clash = { mind = { coins = 2 } },
		resist = { sinking = 2 },
		yearly = { sanity = -2 },
		look = { kind = "token", color = { 120, 130, 150 } },
	},
}
