--[[
	Conditions, area A: the ordinary wear and tear of a Backstreets life.
]]

return {
	-- (v0.12) hired help (Markets.luau, an Office's front desk): good to have, and not an illness
	bs_escorted = { name = "Walked Home", good = true, curable = false, years = 1, hazardMult = 0.75, desc = "A Grade 7 walks you home every night this year. Trouble in the streets finds you a quarter less often.", gainLog = "A Fixer is walking you home this year.", healLog = "Your escort's contract ran out. You walk home alone again." },
	bs_bodyguard = { name = "Bodyguard", good = true, curable = false, years = 1, hazardMult = 0.65, clash = { strength = { base = 1 }, speed = { base = 1 } }, desc = "A Grade 5 a step behind you all year: +1 base in Strength and Speed checks, and a third less trouble in the streets.", gainLog = "You have a bodyguard this year.", healLog = "Your bodyguard's year is up. He shook your hand, once, and left." },
	bs_bad_back = { name = "Bad Back", years = 3, desc = "-1 base in Health checks. Stairs are the enemy now.", gainLog = "Your back went out lifting something you should have asked for help with.", healLog = "Your back stopped complaining, mostly.", clash = { health = { base = -1 } } },
	bs_sprained_ankle = { name = "Sprained Ankle", years = 1, desc = "-1 base in Strength checks and fights.", gainLog = "You came down wrong on a stair and your ankle swelled up like a bun.", healLog = "Your ankle healed. You still take that stair slowly.", clash = { strength = { base = -1 } }, look = "bandaged" },
}
