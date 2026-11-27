--[[
	Conditions, danger and horror (dz_): the scars a bad night leaves. Roblox-safe: "maimed"
	means badly hurt and slower, never a description of the wound.
]]

return {
	dz_terror = {
		name = "Terror",
		years = 3,
		curable = false,
		desc = "-3 Sanity a year, -1 coin in Mental Strength checks. Every hum is the Night coming.",
		gainLog = "Something got into you that night and stayed. You sleep with the light on and your back to the wall.",
		healLog = "The terror faded into ordinary fear, the kind everyone in the City carries.",
		yearly = { sanity = -3 },
		clash = { mind = { coins = -1 } },
		look = "shadows",
	},
	dz_maimed = {
		name = "Maimed",
		years = 6,
		curable = false,
		desc = "-1 coin in Strength checks and fights, -1 base in Health checks. Badly hurt, and slower for it.",
		gainLog = "You were hurt badly enough that it never quite healed. You're slower now, and you know it.",
		healLog = "You learned to move around the old injury. It still aches before rain.",
		clash = { strength = { coins = -1 }, health = { base = -1 } },
		look = "cast",
	},
	-- (v0.12) Events/Bloodfiend_Hunt.luau: a Family you sold out is coming, rank by rank
	bf_hunted_family = {
		name = "Hunted by a Family",
		years = 12,
		curable = false,
		look = "shadows",
		desc = "-1 Sanity a year, -1 base in Mental Strength checks. A Bloodfiend Family wants its due, and it has all the time in the world.",
		gainLog = "A Bloodfiend Family has put your name in its book.",
		healLog = "The Family's book has a line through your name now.",
		yearly = { sanity = -1 },
		clash = { mind = { base = -1 } },
	},
	dz_hunted = {
		name = "Hunted",
		years = 3,
		curable = false,
		desc = "-2 Sanity a year, -1 base in Mental Strength checks. Somebody is following you.",
		gainLog = "Somebody is following you. You can't prove it, and you can't stop checking.",
		healLog = "The footsteps behind you stopped. You still take a different way home every night.",
		yearly = { sanity = -2 },
		clash = { mind = { base = -1 } },
		look = "shadows",
	},
	dz_bad_water = {
		name = "Bad Water",
		years = 2,
		desc = "Lose 2 to 3 Health a year. A clinic can flush it out.",
		gainLog = "Bad water from the block's cistern. Your stomach is a knot and your hands won't stop shaking.",
		healLog = "The sickness from the bad water finally passed.",
		yearly = { health = { -3, -2 } },
		look = "pale",
	},
}
