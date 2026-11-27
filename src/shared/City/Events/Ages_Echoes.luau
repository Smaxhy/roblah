--[[
	ECHOES of what other players did at the turning points (Chronicle/Ages.luau): word of it
	reaches your life as a rumour. `when.chronicle` is the act; {actor} and {actorDistrict}
	name who and where. Each is bound to the ages in which it can be said out loud.
]]

local AFTER_THE_LIGHT = { era = { "library", "limbus" } }

return {
	{
		id = "ec_killed_a_capo",
		title = "A Capo Is Dead",
		art = "syndicate",
		text = "Word from {actorDistrict}: {actor} killed a Capo of the Thumb. The Thumb's people are polite to everyone this week, which is worse.",
		weight = 7,
		cooldown = 6,
		when = { chronicle = "killed_a_capo", minAge = 14 },
		choices = {
			{ label = "Bow lower than usual", result = { charisma = 1, sanity = -1, log = "You bowed to a Soldato you'd never seen before. He counted how long." } },
			{ label = "Ask who {actor} is", result = { intelligence = 1, log = "Nobody knew. Everybody had a cousin who did." } },
			{ label = "Keep off the Thumb's streets", result = { speed = 1, sanity = 1, log = "The long way round, for a month. Your legs are better for it." } },
		},
	},
	{
		id = "ec_wrecked_exhibit",
		title = "The Exhibition in Pieces",
		art = "theater",
		text = "In {actorDistrict}, {actor} walked into a Ring exhibition and tore it down. The Ring is calling it a collaboration, and would like to meet the artist.",
		weight = 7,
		cooldown = 6,
		when = { chronicle = "wrecked_exhibit", minAge = 15 },
		choices = {
			{ label = "Go and see what's left", result = { mind = 1, sanity = -2, log = "A white room, and the floor swept into one corner. People stood looking at the corner." } },
			{ label = "Stay away from anything with a frame", result = { sanity = 1, luck = 1, log = "You took the mirror down as well. No sense inviting opinions." } },
		},
	},
	{
		id = "ec_volatile_ego",
		title = "Bright and Cracked",
		art = "street",
		text = "{actor} of {actorDistrict} came back from the brink holding something bright and cracked. Fixers have a name for it: a volatile E.G.O. People cross the road.",
		weight = 7,
		cooldown = 6,
		when = { chronicle = "volatile_ego", world = AFTER_THE_LIGHT, minAge = 12 },
		choices = {
			{ label = "Ask what it cost", result = { intelligence = 1, mind = 1, log = "\"It asks,\" somebody said. \"Every time they use it. One day they'll say yes.\"" } },
			{ label = "Cross the road too", result = { sanity = 1, log = "You crossed. So did everyone. It was a very empty pavement." } },
			{ label = "Nod as you pass", result = { charisma = 1, sanity = -1, log = "They nodded back. The air near them tasted of struck matches." } },
		},
	},
	{
		id = "ec_refused_the_voice",
		title = "Went Home",
		art = "home",
		text = "They say {actor} of {actorDistrict} stood at the very edge, was offered everything, and went home. No light. No monster. Just home.",
		weight = 7,
		cooldown = 6,
		when = { chronicle = "refused_the_voice", world = AFTER_THE_LIGHT, minAge = 12 },
		choices = {
			{ label = "Remember it can be done", result = { mind = 2, log = "You wrote it on the inside of a cupboard door: somebody said no, and went home." } },
			{ label = "Wonder what was offered", result = { intelligence = 1, sanity = -1, log = "Everything, they said. You spent a night working out what yours would be." } },
		},
	},
	{
		id = "ec_let_it_go_out",
		title = "Like a Lamp",
		art = "night",
		text = "{actor} of {actorDistrict} held a volatile E.G.O for years, and one night let it go out, like a lamp. They say {actor} sleeps well now.",
		weight = 7,
		cooldown = 6,
		when = { chronicle = "let_it_go_out", world = AFTER_THE_LIGHT, minAge = 12 },
		choices = {
			{ label = "Good for them", result = { sanity = 2, log = "Power's a thing you can put down. You hadn't known that." } },
			{ label = "What a waste", result = { strength = 1, sanity = -1, log = "You said so in the noodle queue. An old Fixer looked at you until you stopped." } },
		},
	},
	{
		id = "ec_learned_shin",
		title = "A Still Heart",
		art = "rooftop",
		text = "In {actorDistrict}, {actor} has stilled their heart into Shin: years of sitting, and one evening it held. People have started sitting on their roofs at dawn.",
		weight = 7,
		cooldown = 6,
		when = { chronicle = "learned_shin", world = { era = "limbus" }, minAge = 14 },
		choices = {
			{ label = "Try sitting", result = { mind = 1, sanity = 2, log = "Ten minutes, on the roof. Your heart did what it liked. It was still a good ten minutes." } },
			{ label = "Ask how long it took", result = { intelligence = 1, log = "Eleven years, somebody said. Somebody else said nine, as if that were quick." } },
			{ label = "Sleep in", result = { sanity = 1, log = "Dawn came and went without you. You regret nothing." } },
		},
	},
}
