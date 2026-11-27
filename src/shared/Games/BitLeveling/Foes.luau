--[[
	FOES: what stands across the fight screen. gate_<rank> is what a Gate of that rank's
	monsters look like in a fight (creature shapes: client/UI/CreatureView). ORIGINAL looks.
]]
return {
	{ id = "gate_e", name = "Goblin pack", kind = "creature", shape = "swarm", color = { 96, 130, 70 }, eye = { 255, 220, 80 }, temper = "quick", ability = { id = "bleed", potency = 1 }, barks = { start = { "*chattering*" }, win = { "*cackling*" }, lose = { "*scattering*" } } },
	{ id = "gate_d", name = "Armoured beetles", kind = "creature", shape = "crab", color = { 70, 76, 96 }, eye = { 140, 220, 255 }, temper = "brute", ability = { id = "guard", potency = 1 }, barks = { start = { "*clicking*" } } },
	{ id = "gate_c", name = "Orc raider", kind = "creature", shape = "tall", color = { 92, 120, 70 }, eye = { 255, 80, 60 }, temper = "brute", ability = { id = "crush", potency = 2 }, barks = { start = { "*a war cry*" }, win = { "*roaring*" } } },
	{ id = "gate_b", name = "Ice bear", kind = "creature", shape = "beast", color = { 220, 228, 238 }, eye = { 120, 200, 255 }, temper = "brute", ability = { id = "bleed", potency = 2 }, barks = { start = { "*a deep growl*" } } },
	{ id = "gate_a", name = "Stone golem", kind = "creature", shape = "armor", color = { 120, 116, 110 }, eye = { 255, 170, 60 }, temper = "cunning", ability = { id = "guard", potency = 3 }, barks = { start = { "*grinding stone*" } } },
	{ id = "gate_s", name = "Something from the deep Gate", kind = "creature", shape = "serpent", color = { 40, 30, 60 }, eye = { 255, 60, 90 }, temper = "cunning", ability = { id = "burn", potency = 3 }, barks = { start = { "*the air goes heavy*" } } },
	{ id = "rogue_hunter", name = "Rogue Hunter", temper = "cunning", ability = { id = "bleed", potency = 2 }, look = { skin = "sand", hair = "crop", hairColor = "ink", eyes = "brown", outfit = "hoodie", mark = "scar" }, barks = { start = { "You're not taking my licence." }, win = { "Stay out of my way." }, lose = { "Fine! Fine." } } },
}
