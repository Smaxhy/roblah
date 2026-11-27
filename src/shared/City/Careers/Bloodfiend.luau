--[[
	The Bloodfiend Families (Limbus Company, Canto VII): each Family is led by an Elder, a
	First Kindred, from a Nest. A player's Kindred can't be an Elder (only the first
	Bloodfiend's own Kindred are), but can rise to be the Elder's right hand and steward.
	Ranks, the Morvaine Family and its people are this game's own.
]]

return {
	order = { "bf_family" },

	bf_family = {
		sort = 19,
		name = "a Bloodfiend Family",
		teaches = "hardblood",
		uniform = "bf_formal",
		desc = "Serve your Family: its Elder, its Hemobar cellars, its quiet business after dark. Kindred rise by loyalty, nerve and Hardblood. Bloodfiends only.",
		ranks = { "Fledgling", "Kindred of the Family", "Hardblood Knight", "Elder's Hand", "Steward of the Family" },
		salary = { 60, 140, 280, 520, 900 },
		minAge = 18,
		requires = { form = "bloodfiend" },
		promoteStat = "strength",
		promoteAt = { 45, 60, 74, 86 },
		yearsPerRank = 4,
		yearly = { sanity = { 1, 3 } }, -- the Family keeps its own fed
		rankFlags = { [1] = "bf_family_member", [5] = "bf_family_steward" },
		hazard = {
			chance = 0.07,
			result = { health = { -14, -6 }, sanity = -3, log = "Hunters found one of the Family's cellars. You were there when the door came down.", cause = "Lost when hunters raided the Family's cellar" },
		},
	},
}
