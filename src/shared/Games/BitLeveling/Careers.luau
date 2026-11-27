--[[
	CAREERS: a list (or { order, [id] }). Each:
		id, name, desc, ranks = { "Rank 1", ... }, salary = { per rank, a year },
		minAge, requires = { min = { stat = n } }, promoteStat = "<stat id>",
		promoteAt = { stat needed for rank 2, 3, ... }, yearsPerRank, sides = { "<side id>" },
		yearly = { <stat> = n }, hazard = { chance, result = { ..., cause } }
]]
return {
	{
		id = "shopkeep",
		name = "The General Store",
		desc = "Stock shelves, count change, know everyone's business.",
		ranks = { "Stock Hand", "Clerk", "Head Clerk", "Manager", "Owner" },
		salary = { 30, 60, 110, 200, 380 },
		minAge = 14,
		promoteStat = "smarts",
		promoteAt = { 25, 40, 58, 75 },
		yearsPerRank = 2,
	},
	{
		id = "guard",
		name = "The Town Watch",
		desc = "Walk the walls at night and keep the peace, mostly.",
		ranks = { "Recruit", "Watchman", "Sergeant", "Captain", "Commander" },
		salary = { 50, 90, 160, 300, 560 },
		minAge = 16,
		requires = { min = { strength = 20 } },
		promoteStat = "strength",
		promoteAt = { 30, 45, 62, 80 },
		yearsPerRank = 2,
		hazard = { chance = 0.08, result = { health = { -12, -4 }, log = "A brawl on your watch got out of hand.", cause = "Killed on the night watch" } },
	},
}
