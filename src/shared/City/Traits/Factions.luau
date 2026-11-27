--[[
	Traits earned through factions, recruitment and the faction wars (writer: fc_ ids).
	Earned, never picked. Fields: see Traits/Core.luau. Granted in Events/Factions_*.luau.
]]

return {
	order = { "fc_thumb_protection", "fc_war_veteran", "fc_ranked_name", "fc_double_dealer", "fc_turncoat" },

	fc_thumb_protection = {
		name = "Thumb Protection",
		desc = "A Capo of the Thumb has your name on a short list of people nobody bothers. Rats cross the street. +1 base in Mental Strength and Strength checks.",
		category = "earned",
		clash = { mind = { base = 1 }, strength = { base = 1 } },
	},
	fc_war_veteran = {
		name = "Street-War Veteran",
		desc = "You fought in a war between factions and walked out of it. +1 base in fights, and you take 5% less Health damage.",
		category = "earned",
		fight = { base = 1 },
		toughness = 0.95,
	},
	fc_ranked_name = {
		name = "A Name on the Board",
		desc = "Your name is high on Hana's ranking list. Clients pay more, and challengers know where to find you. +1 power per heads in fights. -2% heads.",
		category = "earned",
		fight = { coinPower = 1 },
		heads = -2,
	},
	fc_double_dealer = {
		name = "Sold to Both Sides",
		desc = "You sold to both sides of a war and got away with it. +1 coin in Mental Strength checks. -3% heads: you never stop checking over your shoulder.",
		category = "earned",
		clash = { mind = { coins = 1 } },
		heads = -3,
	},
	fc_turncoat = {
		name = "Turncoat",
		desc = "You changed sides in the middle of a war. You know how both sides fight, and neither trusts you. +1 potency in fights. -3% heads.",
		category = "earned",
		fight = { potency = 1 },
		heads = -3,
	},
}
