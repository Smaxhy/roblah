--[[
	Core events: the engine's hook events (pack.hooks) and the turning points of the
	City's history that every life lives through (the eras in init.luau).
]]

return {
	-- ── the breaking point: Sanity hits bottom ──
	{
		id = "core_breaking_point_old",
		when = { world = { era = { "wings", "white_nights" } } },
		title = "The Edge",
		text = "It all comes down on you at once, every year of it. Your hands won't stop. The room is too small, and the City outside it is too big. Nobody has a word yet for the place you're standing in.",
		weight = 0,
		choices = {
			{
				label = "Hold on to the people who need you",
				hint = "Easier, if there's still someone to hold on to.",
				requires = { form = { "human", "ego" }, hasRelation = { "child", "mother", "father", "sibling", "friend", "mentor" } },
				clash = { stat = "mind", foe = "The weight of it", coins = 1, base = 3, coinPower = 3, ignoreSanity = true, fixed = true },
				win = { sanity = 55, relationBond = { kind = "all", amount = 15 }, log = "You thought of their faces until the room came back. Somebody made tea. You drank it." },
				lose = { sanity = 35, health = { -8, -4 }, condition = "night_terrors", log = "You came back from it weeks later, thinner. They'd kept your place at the table." },
			},
			{
				label = "Walk until it lets go",
				hint = "Health check. Your coins flip fair here.",
				requires = { form = { "human", "ego" } },
				clash = { stat = "health", foe = "The weight of it", coins = 2, base = 3, coinPower = 3, ignoreSanity = true, fixed = true },
				win = { sanity = 50, health = 2, log = "You walked the District end to end, twice. By morning it had let go of you. Your feet took longer to forgive you." },
				lose = { sanity = 30, quitCareer = true, money = { -60, -20 }, condition = "night_terrors", log = "You don't remember the month after. You lost the job, and some money, and kept yourself. It was a fair trade." },
			},
			{
				label = "Hold on to who you were",
				hint = "Mental Strength check. A Bloodfiend at the edge loses itself to the Thirst.",
				requires = { form = "bloodfiend" },
				clash = { stat = "mind", foe = "The Thirst", coins = 2, base = 3, coinPower = 3, ignoreSanity = true, fixed = true },
				win = { sanity = 55, mind = 4, log = "You held on to your name, your street, the people who knew you before. The Thirst backed down, for now." },
				lose = { die = "Lost to the Thirst", chronicle = "bf_lost", log = "The Thirst won. What walked out of your door that night wasn't you anymore, and the Fixers who came for it didn't know your name." },
			},
			{
				label = "Drink the Hemobar you kept for this",
				hint = "150 Ahn's worth of the good ones.",
				requires = { form = "bloodfiend", min = { money = 150 } },
				result = { money = -150, sanity = 50, log = "You kept one sealed box at the back of the cupboard for exactly this night. It was enough. Barely." },
			},
		},
	},

	-- ── money trouble ──
	{
		id = "core_debt_collector",
		title = "Polite Collection",
		text = "A man in a pressed suit is waiting on your stairs with his hat in his hands. He represents people you borrowed from. \"We're in no hurry,\" he says, which is how you know they are.",
		weight = 60,
		cooldown = 2,
		when = { minAge = 16, max = { money = -1 } },
		choices = {
			{
				label = "Work it off",
				result = { money = 45, health = { -8, -4 }, sanity = -3, setFlags = { "worked_off_debt" }, log = "You spent a season carrying crates for his employers to clear your name. Nobody asked what was in them." },
			},
			{
				label = "Talk your way out",
				clash = { stat = "charisma", foe = "A patient collector", coins = 2, base = 3, coinPower = 3 },
				win = { money = 20, log = "You talked so long and so courteously that he forgave half of it, just to leave." },
				lose = { money = -15, sanity = -4, log = "Your excuses only added interest." },
			},
			{
				label = "Throw him down the stairs",
				clash = { stat = "strength", foe = "The collector", coins = 2, base = 4, coinPower = 3, fight = true },
				win = { sanity = 2, setFlags = { "crossed_collectors" }, log = "He went down the stairs faster than he came up. His employers will remember this." },
				lose = { health = { -14, -8 }, money = -20, log = "He was much better at this than he looked.", cause = "Settled a debt the hard way" },
			},
		},
	},

	-- the turning points of each age, and the voice at the brink, are in Events/Ages.luau
}
