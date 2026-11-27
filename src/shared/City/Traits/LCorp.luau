--[[
	Traits earned in the Wings: L Corp's veterans, scientists and secret-keepers, and
	W Corp's armored cleanup agents. None are pickable; results give them (addTrait).
	Fields: see Traits/Core.luau and docs/CONTENT_GUIDE.md.
]]

return {
	order = { "lc_steadfast_veteran", "lc_breach_hardened", "lc_true_scientist", "lc_knows_the_green", "wg_cca_certified" },

	lc_steadfast_veteran = {
		name = "Steadfast Veteran",
		desc = "Years of Continued Service in one L Corp department. Fear slides off you now. +1 base in Mental Strength and Health checks.",
		clash = { mind = { base = 1 }, health = { base = 1 } },
	},
	lc_breach_hardened = {
		name = "Breach-Hardened",
		desc = "You held a corridor while something impossible came down it, and you're still here. +2 Health, +1 base in fights.",
		stats = { health = 2 },
		fight = { base = 1 },
	},
	lc_true_scientist = {
		name = "Just a Scientist",
		desc = "You turned down the corner office to stay at the bench, and you've never regretted it. +3 Intelligence, +1 coin in Intelligence checks.",
		stats = { intelligence = 3 },
		clash = { intelligence = { coins = 1 } },
	},
	lc_knows_the_green = {
		name = "Knows What the Green Is",
		desc = "You know where L Corp's energy really came from. It's heavy to carry, and it makes you very hard to fool. +1 coin in Mental Strength checks.",
		sanity = -4,
		clash = { mind = { coins = 1 } },
	},
	wg_cca_certified = {
		name = "CCA Certified",
		desc = "W Corp trusted you with its Congestion Cleaning Armor. You never quite stopped standing like you're wearing it. +1 coin in Health checks and fights.",
		clash = { health = { coins = 1 } },
	},
}
