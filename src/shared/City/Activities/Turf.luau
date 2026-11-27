--[[
	TURF (v0.13): what a life in a turf war does with its year (category "turf"). Engine:
	Engine/Turf.luau; the District's blocks: City/Turf.luau; the war's events:
	Events/Turf_Wars.luau. A fight for a block is with whoever holds it (turfFoe).
]]

return {
	{
		id = "turf_take",
		category = "turf",
		name = "Take a block",
		desc = "Pick a street someone else holds and make it yours. Whoever holds it will fight for it.",
		minAge = 18,
		cooldown = 1,
		icon = "misc.fight",
		turfFoe = true,
		when = { side = "backstreets", flags = { "turf_in" } },
		clash = { stat = "strength", foe = "Whoever holds the block", enemy = "syndicate", fight = true, coins = 3, base = 6, coinPower = 4 },
		win = { turfTake = 1, renown = { 3, 6 }, money = { 60, 160 }, log = { "The block is yours. By evening the shopkeepers were paying you, and looking relieved about it.", "You took the block street by street. The last holdout shook your hand and asked what your rates were.", "They fought for it. You fought harder. New name on the street." } },
		lose = { health = { -14, -5 }, money = { -120, -40 }, cause = "A turf war", log = { "They held the block, and made a point of it.", "You came for the block and left without it, and without your good jacket." } },
	},
	{
		id = "turf_walk",
		category = "turf",
		name = "Walk your blocks",
		desc = "Be seen on your streets, all year: pay calls, settle squabbles, check the shutters. A year you've walked is raided half as often.",
		minAge = 18,
		cooldown = 1,
		icon = "misc.walk",
		when = { side = "backstreets", flags = { "turf_in" } },
		result = { turfGuard = true, charisma = 1, sanity = 1, log = { "You walked your blocks every evening. The noodle row knows your footsteps now.", "Calls paid, squabbles settled, shutters checked. Nobody tried anything this year, and everyone knows why.", "You walked your streets until the shopkeepers started setting a chair out for you." } },
	},
	{
		id = "turf_collect",
		category = "turf",
		name = "Collect in person",
		desc = "Go round your blocks yourself instead of sending someone. It pays more, and people remember your face.",
		minAge = 18,
		cooldown = 1,
		icon = "misc.money",
		when = { side = "backstreets", flags = { "turf_in" } },
		clash = { stat = "charisma", foe = "Shopkeepers with a hundred excuses", coins = 2, base = 4, coinPower = 3 },
		win = { money = { 150, 400 }, renown = 1, log = { "Every shop paid, most of them with a smile, one of them with a bowl of soup.", "You collected in person. It's surprising how much easier people find it to pay a face." } },
		lose = { money = { 40, 90 }, sanity = -1, log = { "Half the shops had excuses. Good ones, mostly.", "You came back with less than you went out with in mind, and two promises." } },
	},
	{
		id = "turf_leave",
		category = "turf",
		name = "Get out of the turf war",
		desc = "Stop fighting for streets. You keep whatever you still hold, but nobody's colours protect you now.",
		minAge = 18,
		cooldown = 1,
		icon = "misc.walk",
		when = { flags = { "turf_in" } },
		result = { turfLeave = true, sanity = 3, log = "You took off the colours and went home. The war went on without you, which is what wars do." },
	},
}
