--[[
	FOES: who stands across the fight screen. A clash names one with `enemy = "<id>"`.
		id, name, kind = "human" | "creature", temper = "brute" | "quick" | "cunning",
		look (human: an avatar look) or shape/color/eye (creature: client/UI/CreatureView shapes:
		beast, bird, blob, serpent, swarm, tall, mantis, crab, moth, whale, scrapgolem, ...),
		ability = { id = "bleed" | "burn" | "guard" | "quick" | ..., potency = n },
		barks = { start = {...}, win = {...}, lose = {...} }
]]
return {
	{ id = "brawler", name = "Champion Brawler", temper = "brute", ability = { id = "crush", potency = 1 }, look = { skin = "bronze", hair = "shorn", hairColor = "ink", eyes = "brown", outfit = "trainer_wraps", mark = "scar" }, barks = { start = { "Another one." }, win = { "Next!" }, lose = { "...Good fight." } } },
	{ id = "rat_king", name = "The Rat King", kind = "creature", shape = "swarm", color = { 90, 80, 70 }, eye = { 255, 80, 60 }, temper = "quick", ability = { id = "bleed", potency = 2 }, barks = { start = { "*a thousand teeth chatter*" } } },
}
