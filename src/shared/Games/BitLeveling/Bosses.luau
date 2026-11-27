--[[
	BOSSES fought in turns (Engine/Battle.luau): the boss rooms of the Gate raids (ORIGINAL).
]]
return {
	goblin_chief = {
		name = "Goblin Chieftain", title = "Boss of an E-rank Gate", enemy = "gate_e",
		hp = 90, coins = 2, base = 5, coinPower = 3, temper = "quick",
		cause = "Killed by a goblin chieftain",
		moves = {
			{ id = "stab", name = "Rusty Spear", text = "lunges with a rusted spear", power = 6, weight = 10 },
			{ id = "call", name = "Call the Pack", text = "shrieks, and goblins come out of every crack", power = 4, weight = 6, target = "all" },
		},
		phases = { { at = 0.4, line = "The chieftain drinks something glowing from a crystal flask.", base = 1, power = 2 } },
		barks = { start = { "*a shrill war cry*" }, hurt = { "*hissing*" }, phase = { "*it swells, grinning*" } },
	},
	orc_warlord = {
		name = "Orc Warlord", title = "Boss of a C-rank Gate", enemy = "gate_c",
		hp = 220, coins = 3, base = 13, coinPower = 5, temper = "brute",
		cause = "Killed by an orc warlord",
		moves = {
			{ id = "cleave", name = "Cleaver", text = "brings down a cleaver the size of a door", power = 14, weight = 10, heavy = true },
			{ id = "roar", name = "War Roar", text = "roars, and the whole party flinches", power = 7, weight = 6, target = "all" },
		},
		phases = { { at = 0.35, line = "The warlord's eyes go red. It stops feeling pain.", base = 3, power = 3 } },
		barks = { start = { "*a guttural challenge*" }, hurt = { "*snarling*" }, phase = { "*it laughs*" } },
	},
	frost_bear = {
		name = "Alpha Ice Bear", title = "Boss of a B-rank Gate", enemy = "gate_b",
		hp = 380, coins = 3, base = 19, coinPower = 6, temper = "brute",
		cause = "Killed by an alpha ice bear",
		moves = {
			{ id = "maul", name = "Maul", text = "rears up and comes down on you", power = 20, weight = 10, heavy = true },
			{ id = "blizzard", name = "Whiteout", text = "shakes the ceiling loose, and the cavern fills with ice", power = 10, weight = 5, target = "all" },
		},
		phases = { { at = 0.4, line = "Frost spreads across its fur like armour.", base = 4, power = 4 } },
		barks = { start = { "*a roar that shakes the ice*" }, hurt = { "*a pained bellow*" }, phase = { "*the cold deepens*" } },
	},
	golem_lord = {
		name = "Golem Overlord", title = "Boss of an A-rank Gate", enemy = "gate_a",
		hp = 640, coins = 4, base = 28, coinPower = 8, temper = "cunning",
		cause = "Crushed by a golem overlord",
		moves = {
			{ id = "slam", name = "Mountain Fist", text = "brings both fists down", power = 30, weight = 10, heavy = true },
			{ id = "shards", name = "Shard Storm", text = "bursts apart into a storm of stone and reforms", power = 16, weight = 6, target = "all" },
		},
		phases = { { at = 0.3, line = "The core in its chest blazes orange. It's getting faster.", base = 6, power = 6 } },
		barks = { start = { "*stone grinding on stone*" }, hurt = { "*cracking*" }, phase = { "*a furnace roar*" } },
	},
}
