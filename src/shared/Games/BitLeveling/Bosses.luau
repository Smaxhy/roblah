--[[
	BOSSES fought in turns (Engine/Battle.luau). A card's choice with `battle = "<id>"` starts one.
		name, title, enemy (a foe id for the look), hp, coins, base, coinPower, temper, cause,
		moves = { { id, name, text, power, weight, target = "one" | "all", heavy, condition } },
		phases = { { at = share of hp left, line, base, coinPower, power, moves = {...} } },
		barks = { start, hurt, phase }
]]
return {
	rat_king = {
		name = "The Rat King", title = "Lord of the Cellars", enemy = "rat_king",
		hp = 150, coins = 3, base = 7, coinPower = 3, temper = "quick",
		cause = "Eaten by the Rat King",
		moves = {
			{ id = "bite", name = "A Thousand Bites", text = "boils up out of the dark and bites everywhere at once", power = 8, weight = 10 },
			{ id = "swarm", name = "The Swarm", text = "splits into a hundred rats that go for everyone", power = 6, weight = 6, target = "all" },
		},
		phases = {
			{ at = 0.4, line = "The Rat King screams, and every rat in the town answers.", base = 1, power = 2,
				moves = { { id = "tide", name = "The Tide of Rats", text = "comes up through the floor", power = 13, weight = 8, heavy = true } } },
		},
		barks = { start = { "*the dark chatters*" }, hurt = { "*shrieks*" }, phase = { "*every rat in town answers*" } },
	},
}
