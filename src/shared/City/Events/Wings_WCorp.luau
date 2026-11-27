--[[
	W Corp (District 23): the WARP trains and their Cleanup Agents, Level 1 to Level 5, the
	CCA power armor at Level 4+, and the five train warnings (Unobstructed, Delayed,
	Congested, Canceled, Derailed). Plus an outsider's ride.
	Career wcorp_cleanup ranks: 1-5 Cleanup Agent Levels 1-5, 6 Cleanup Captain.
	The Congested train is an expedition (Expeditions/LCorp.luau, wg_exp_congested).
]]

local CREW = { career = "wcorp_cleanup" }

return {
	{
		id = "wg_w_first_car",
		title = "Your First Carriage",
		text = "Your first run as a Level 1 Cleanup Agent. The board on the platform says UNOBSTRUCTED: an ordinary train, and an ordinary cleanup. The passengers walk off it looking a little older than they should, blinking. One old woman stays in her seat. She tells you, very calmly, that she has been on this train for a long time.",
		weight = 120,
		once = true,
		tags = { "wing", "warp" },
		when = CREW,
		codex = { "wg_lore_cleanup", "wg_lore_train_states" },
		choices = {
			{
				label = "Clean the carriage fast and say nothing",
				result = { health = 2, paycheck = 0.1, log = "You cleaned the carriage in eleven minutes, a crew record for a Level 1. You didn't look at what you were cleaning. That's the first thing they teach you, and the hardest." },
			},
			{
				label = "Sit with the old woman until her family comes",
				result = { sanity = -3, intelligence = 2, codex = "districts_warp_secret", log = "She told you how long it had been, from the inside. Years. Decades. You held her hand until her grandson came, and he didn't recognize her, and then he did." },
			},
			{
				label = "Ask your Level 3 trainer how the trains really work",
				result = { mind = 2, log = "\"Seconds outside,\" she said. \"Much longer inside. First Class sleeps through it. Everyone else doesn't.\" She handed you a mop. \"That's the whole secret. Now clean.\"" },
			},
		},
	},
	{
		id = "wg_w_delayed",
		title = "DELAYED",
		text = "The board flips to DELAYED: some of the passengers on the incoming train will need subduing before the doors open. Through the fogged windows, you can see a man standing on a seat, shouting at the others about a city that isn't this one, in a language that's almost this one.",
		weight = 24,
		cooldown = 3,
		tags = { "wing", "warp" },
		when = CREW,
		codex = "wg_lore_train_states",
		choices = {
			{
				label = "Subdue him gently",
				hint = "A Health check.",
				clash = { stat = "health", foe = "A man who has been awake for years", coins = 2, base = 4, coinPower = 3 },
				win = { health = 2, paycheck = 0.1, log = "You got him down without hurting him, and held on until he stopped shouting and started crying. Medical took him. He thanked you, though he called you by someone else's name." },
				lose = { health = { -7, -3 }, log = "He was stronger than he looked, the way people who've lived a long time on a train sometimes are." },
			},
			{
				label = "Talk him down",
				hint = "A Charisma check.",
				clash = { stat = "charisma", foe = "Somebody else's city", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, sanity = 1, log = "You asked him about the city he was shouting about, and listened, and he climbed down off the seat to tell you better. By the end he remembered this one." },
				lose = { sanity = -3, log = "He told you about his city until you could almost see it. You're not sure, some nights, which one you live in." },
			},
			{
				label = "Wait for a Level 3",
				result = { mind = 1, log = "You waited for a Level 3, which is in the rules. She subdued him in about four seconds and didn't say anything about you waiting, which was kind." },
			},
		},
	},
	{
		id = "wg_w_recruits",
		title = "Training Recruits",
		text = "Level 3 Cleanup Agents may train recruits, and this year you have three. On their first Unobstructed train, one of them, a boy from the District 23 Backstreets called Nils, freezes in the carriage doorway and won't go in. The others are watching you to see what a Level 3 does.",
		weight = 20,
		cooldown = 4,
		tags = { "wing", "warp" },
		when = { career = "wcorp_cleanup", minRank = 3 },
		choices = {
			{
				label = "Go in first and talk him through it",
				result = { charisma = 2, sanity = 2, setFlags = { "wg_good_trainer" }, log = "You went in first, and talked about nothing, and handed him a mop when he got to the first seat. He's a Level 2 now. He still brings you a bun on the anniversary of that train." },
			},
			{
				label = "Tell him the truth about what he'll see",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "A recruit's fear", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, log = "You told him straight: what's inside, why it's like that, why someone has to clean it. He went in. The truth works better than courage, on the trains." },
				lose = { sanity = -2, log = "He listened, went pale, and handed in his badge that afternoon. Maybe that was the right answer for him." },
			},
			{
				label = "Order him in",
				result = { sanity = -3, setFlags = { "wg_harsh_trainer" }, log = "\"In,\" you said. He went in. He came out and threw up on the platform and went back in. He's a good agent now. He doesn't talk to you." },
			},
		},
	},
	{
		id = "wg_w_cca",
		title = "CCA Authorization",
		text = "Your performance reviews have been the best on your crew three years running, and you've made Level 4. That means you can be authorized to wear CCA: Congestion Cleaning Armor, the powered suit for trains the board marks CONGESTED. The test is a day in the suit on the training platform. Losing one, your supervisor reminds you, is a bigger scandal than losing the agent inside.",
		weight = 40,
		once = true,
		tags = { "wing", "warp" },
		when = { career = "wcorp_cleanup", minRank = 4 },
		codex = "wg_lore_cleanup",
		choices = {
			{
				label = "Take the test",
				hint = "A Health check: a whole day in the armor.",
				clash = { stat = "health", foe = "A day in the CCA", coins = 2, base = 5, coinPower = 3 },
				win = { addTrait = "wg_cca_certified", setFlags = { "wg_cca_authorized" }, paycheck = 0.2, log = "You wore the CCA for twelve hours and finished every drill. When you climbed out, your legs didn't work for an hour. Your supervisor signed the authorization on your back while you lay on the floor." },
				lose = { health = { -6, -3 }, sanity = -2, log = "Seven hours in, the suit's cooling failed and so did you. Next year, they said. The suit was fine, they added." },
			},
			{
				label = "Turn it down. You'd rather work in your own skin",
				result = { sanity = 2, mind = 1, log = "You said no. The suit is for trains that kill people, and you'd rather not be the one who gets sent to them. Your supervisor seemed to respect that more than she expected to." },
			},
		},
	},
	{
		id = "wg_w_canceled",
		title = "CANCELED",
		text = "The board on the platform turns red: CANCELED. Somewhere in the incoming train is a threat on the level of a Grade 1 Fixer, something a passenger became on the way. Level 5 agents handle Canceled trains. You're one of them. The doors will open in four minutes whether you're ready or not.",
		weight = 22,
		cooldown = 4,
		tags = { "wing", "warp" },
		when = { career = "wcorp_cleanup", minRank = 5 },
		codex = "wg_lore_train_states",
		choices = {
			{
				label = "Go in and end it",
				hint = "A real fight, and a very hard one.",
				clash = { stat = "health", foe = "What a passenger became", coins = 3, base = 7, coinPower = 3, fight = true, status = "tremor" },
				win = { health = 2, strength = 2, paycheck = 0.3, log = "You ended it in the sixth carriage. Afterward you sat on the platform with your helmet off for a long time. The board flipped to UNOBSTRUCTED, and the next train came in on time." },
				lose = { health = { -18, -10 }, sanity = -5, log = "It was a Grade 1 Fixer's work, and you are not a Grade 1 Fixer. The Captain's crew finished it over you.", cause = "Went into a Canceled train" },
			},
			{
				label = "Seal the train and hold the doors for the Captain's crew",
				hint = "A Mental Strength check: four minutes, then ten more.",
				clash = { stat = "mind", foe = "Doors that want to open", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = -1, paycheck = 0.15, log = "You sealed every door by hand and held them for fourteen minutes until the Captain's crew arrived. Nobody on the platform ever knew what was on that train." },
				lose = { health = { -9, -5 }, sanity = -4, log = "One door didn't seal. You held it with your shoulder. The Captain's crew got there, eventually." },
			},
		},
	},
	{
		id = "wg_w_derailed",
		title = "DERAILED",
		text = "In all your years with the cleanup crews, you've seen the board say DERAILED twice. Tonight is the third time. As Cleanup Captain, you decide who goes in, and you sign the report afterward that nobody else is allowed to read. Your best Level 5 has already volunteered. She has a daughter starting school next week.",
		weight = 30,
		once = true,
		tags = { "wing", "warp" },
		when = { career = "wcorp_cleanup", minRank = 6 },
		codex = "wg_lore_train_states",
		choices = {
			{
				label = "Send her in. She's the best you have",
				result = { sanity = -6, paycheck = 0.3, log = "She went in. She came out. She didn't go to her daughter's first day of school, because she was still in Medical. You signed the report. You can still recite it." },
			},
			{
				label = "Go in yourself",
				hint = "A real fight against a Derailed train.",
				clash = { stat = "health", foe = "A Derailed train", coins = 4, base = 7, coinPower = 3, fight = true, status = "sinking" },
				win = { health = 2, sanity = 2, paycheck = 0.3, log = "You went in yourself. You came out. The report has your signature at the bottom and your handwriting all the way through, and nobody else will ever read it." },
				lose = { health = { -20, -12 }, sanity = -6, log = "You went in yourself, and the crew had to come in after you.", cause = "Walked into a Derailed train" },
			},
			{
				label = "Wait for W Corp to send its own",
				result = { sanity = -3, mind = 2, log = "You called it upstairs. W Corp sent people you'd never seen, in armor you'd never seen, and they went in, and came out, and left. You signed a report you didn't write." },
			},
		},
	},
	-- an outsider's ride
	{
		id = "wg_first_class",
		title = "First Class",
		text = "Your old academy teacher presses a WARP ticket into your hands: First Class, any District, one way, a gift from a former student who went to work for W Corp. \"I'm too old for trains,\" she says. First Class passengers sleep through the trip in a pod, with snacks when they wake. Standard passengers sit up. Either way it takes ten seconds.",
		weight = 8,
		once = true,
		tags = { "warp" },
		when = { minAge = 12 },
		codex = "districts_w_corp",
		choices = {
			{
				label = "Ride First Class there and back",
				result = { sanity = 3, log = "You lay down in a soft white pod and woke up in another District with a cup of tea and a biscuit in front of you. It was the best sleep of your life. You took the next train home, also First Class, and didn't wonder at all." },
			},
			{
				label = "Swap it for two Standard tickets for you and a friend",
				result = { sanity = 2, mind = 1, relationBond = { kind = "friend", amount = 5 }, log = "You rode Standard with a friend. The lights dipped; the doors opened. You'd planned to talk the whole way, and there wasn't a whole way. You bought noodles on the far side with the difference, and talked there instead." },
			},
			{
				label = "Sell the ticket",
				result = { money = { 60, 120 }, log = "A man in a hurry paid well for it on the station steps. He looked relieved, and then, glancing at the board, worried." },
			},
		},
	},
}
