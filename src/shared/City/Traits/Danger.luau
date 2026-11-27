--[[
	Traits, danger and horror (dz_): earned by living through the worst the City has.
	None are pickable at creation. See Traits/Core.luau for the fields.
]]

return {
	order = { "dz_scar_tissue", "dz_night_ears", "dz_dread_calm" },

	dz_scar_tissue = {
		name = "Scar Tissue",
		desc = "You've nearly died often enough that your body expects it. You take 10% less Health damage.",
		category = "body",
		toughness = 0.9,
	},
	dz_night_ears = {
		name = "Night Ears",
		desc = "You hear the hum under the floor before the clock turns. +1 base in Mental Strength checks, +2% heads.",
		category = "street",
		clash = { mind = { base = 1 } },
		heads = 2,
	},
	dz_dread_calm = {
		name = "Calm in the Dark",
		desc = "You met the worst thing in the City and it let you go. Nothing since has come close. +6 Sanity, +1 base in every check.",
		category = "mind",
		sanity = 6,
		clash = { any = { base = 1 } },
	},
}
