--[[
	Bloodfiend traits (earned, not picked). Canon: Limbus Company, Canto VII. Bloodfiends
	harden their blood into weapons and armor (Hardblood); their strength grows with their
	access to blood and their place in the Family. See Events/Bloodfiend.luau.
]]

return {
	order = { "bf_hardblood", "bf_old_blood", "bf_family_friend" },

	bf_hardblood = {
		name = "Hardblood",
		desc = "Your blood hardens at will into blades, armor, whatever the fight needs. +2 base and +1 potency in fights.",
		fight = { base = 2, potency = 1 },
	},
	bf_old_blood = {
		name = "Old Blood",
		desc = "Decades of Hemobars and Family service have made your blood thick and quick. +1 coin in fights.",
		fight = { coins = 1 },
	},
	bf_family_friend = {
		name = "Friend of the Family",
		desc = "A Bloodfiend Family raised you or owes you, and vouches for you after dark. +1 base in Mental Strength checks.",
		clash = { mind = { base = 1 } },
	},
}
