--[[
	SCENES WITH SOMEONE. "Spend time" with a person opens one of these: a moment with two or
	three ways to spend it, each leaning on a different stat. Who they are to you, how close you
	are and how old you both are decide which scenes can come up, and you don't get the same one
	with the same person twice in a row.

	social = { kinds, minBond, maxBond, relMinAge, relMaxAge, minAge, maxAge }
	Words can use {rel} (their first name) and {relKind}. A `bond` in a result lands on them.
	Keep them short: a line or two, then the choices.

	Nothing here names a thing that only exists in one age.
]]

local PARENT = { "mother", "father" }
local EASY = { coins = 1, base = 2, coinPower = 2, fixed = true }

local function check(stat: string, foe: string)
	return { stat = stat, foe = foe, coins = EASY.coins, base = EASY.base, coinPower = EASY.coinPower, fixed = true }
end

return {
	-- ════ parents, while you're small ═══════════════════════════════════════════
	{
		id = "sc_parent_stall",
		title = "The Stall",
		art = "market",
		text = "{rel} needs a hand before the evening rush.",
		weight = 0,
		social = { kinds = PARENT, maxAge = 13 },
		choices = {
			{ label = "Carry the crates", result = { strength = 1, bond = { 5, 9 }, log = "You carried what you could lift, and one you couldn't. {rel} pretended not to help." } },
			{ label = "Call the prices", result = { charisma = 1, bond = { 5, 9 }, log = "You shouted the prices until your voice cracked. Two people bought something just to make you stop." } },
			{ label = "Count the till", result = { intelligence = 1, money = { 2, 6 }, bond = { 4, 8 }, log = "It came out right twice running. {rel} gave you the odd coins." } },
		},
	},
	{
		id = "sc_parent_walk",
		title = "Home Before Three",
		art = "street",
		text = "{rel} is walking home ahead of the Night. You go along.",
		weight = 0,
		social = { kinds = PARENT, maxAge = 13 },
		choices = {
			{ label = "Race to the corner", result = { speed = 1, bond = { 4, 8 }, log = "You won. {rel} let you, and was out of breath anyway." } },
			{ label = "Ask what it was like before", result = { mind = 1, bond = { 6, 10 }, log = "{rel} talked the whole way home. Some of it you'll understand later." } },
			{ label = "Hold on the whole way", result = { sanity = { 2, 4 }, bond = { 7, 12 }, log = "You didn't let go until the door was locked behind you both." } },
		},
	},
	{
		id = "sc_parent_fix",
		title = "The Broken Thing",
		art = "home",
		text = "Something in the flat has stopped working. {rel} has the tools out.",
		weight = 0,
		social = { kinds = PARENT, maxAge = 15 },
		choices = {
			{
				label = "Work out what's wrong",
				clash = check("intelligence", "A machine with one loose part"),
				win = { intelligence = 2, bond = { 7, 11 }, log = "It was the small spring. You found it. {rel} told the neighbours." },
				lose = { intelligence = 1, bond = { 3, 6 }, log = "You took it apart very well. {rel} put it back." },
			},
			{ label = "Hold the lamp steady", result = { mind = 1, bond = { 5, 8 }, log = "An hour without moving. {rel} said that's most of any job." } },
			{ label = "Hand over the tools", result = { speed = 1, bond = { 4, 7 }, log = "By the end you were passing things before {rel} asked." } },
		},
	},

	-- ════ parents, once you're grown ════════════════════════════════════════════
	{
		id = "sc_parent_tea",
		title = "Late Tea",
		art = "home",
		text = "{rel} is up late with the kettle on, looking at nothing.",
		weight = 0,
		social = { kinds = PARENT, minAge = 13 },
		choices = {
			{
				label = "Ask what's wrong",
				clash = check("charisma", "A tired silence"),
				win = { bond = { 9, 14 }, sanity = 2, log = "It took a while. Then {rel} told you, all of it, and looked lighter after." },
				lose = { bond = { 2, 4 }, log = "\"Nothing,\" {rel} said, and poured you a cup, and that was that." },
			},
			{ label = "Sit with them", result = { mind = 1, sanity = { 1, 3 }, bond = { 5, 8 }, log = "Neither of you said much. The kettle did the talking." } },
			{ label = "Do the chores they haven't", result = { strength = 1, sanity = -1, bond = { 6, 10 }, log = "The floor, the water, the lock. {rel} noticed in the morning." } },
		},
	},
	{
		id = "sc_parent_rent",
		title = "Short This Month",
		art = "home",
		text = "{rel} is short on the rent and hasn't said so. You saw the notice.",
		weight = 0,
		social = { kinds = PARENT, minAge = 18 },
		choices = {
			{ label = "Pay it, quietly", requires = { min = { money = 60 } }, result = { money = -60, bond = { 12, 16 }, sanity = 1, log = "You left it under the bread tin. {rel} never mentioned it, and set your place first from then on." } },
			{
				label = "Talk the landlord round",
				clash = check("charisma", "A landlord who's heard it before"),
				win = { charisma = 1, bond = { 8, 12 }, log = "Two weeks' grace, and he thinks it was his idea." },
				lose = { sanity = -2, bond = { 2, 4 }, log = "He'd heard it before. {rel} thanked you for trying, which was worse." },
			},
			{
				label = "Find them extra work",
				clash = check("intelligence", "A District with no work in it"),
				win = { intelligence = 1, bond = { 8, 12 }, log = "A week of evenings at a stall that needed hands. It covered it." },
				lose = { bond = { 2, 4 }, log = "You asked everywhere. Everywhere had already asked someone else." },
			},
		},
	},
	{
		id = "sc_parent_trade",
		title = "Their Old Trade",
		art = "workshop",
		text = "{rel} shows you how the job was done, back when they did it.",
		weight = 0,
		social = { kinds = PARENT, minAge = 12, minBond = 30 },
		choices = {
			{ label = "Learn the lifting", result = { strength = { 1, 2 }, bond = { 4, 7 }, log = "\"Legs, not back.\" You'll hear that in your head for good." } },
			{ label = "Learn the patter", result = { charisma = { 1, 2 }, bond = { 4, 7 }, log = "{rel} could sell a lock to a locksmith. Now you can sell half of one." } },
			{ label = "Learn the books", result = { intelligence = { 1, 2 }, bond = { 4, 7 }, log = "Two columns, one honest. You were shown which." } },
		},
	},

	-- ════ brothers and sisters ══════════════════════════════════════════════════
	{
		id = "sc_sib_roof",
		title = "The Roof",
		art = "rooftop",
		text = "You and {rel} are on the roof, watching WARP trains cross the sky.",
		weight = 0,
		social = { kinds = { "sibling" } },
		choices = {
			{
				label = "Guess which one's late",
				clash = check("luck", "A timetable"),
				win = { luck = 1, sanity = 2, bond = { 5, 8 }, log = "The blue one, by a minute. {rel} wouldn't speak to you for an hour." },
				lose = { sanity = 1, bond = { 5, 8 }, log = "None of them were late. {rel} had read the board before you came up." },
			},
			{ label = "Talk about getting out", result = { mind = 1, bond = { 7, 11 }, log = "A Nest, a Wing job, a door with a real lock. You both knew the odds and said it anyway." } },
			{ label = "Race to the stairs", result = { speed = 1, sanity = 1, bond = { 4, 7 }, log = "You nearly broke your neck. So did {rel}. Worth it." } },
		},
	},
	{
		id = "sc_sib_debt",
		title = "A Small Debt",
		art = "alley",
		text = "{rel} owes some Rats a little money and a large apology.",
		weight = 0,
		social = { kinds = { "sibling" }, minAge = 12, relMinAge = 10 },
		choices = {
			{
				label = "Go and talk to them",
				clash = check("charisma", "Rats who want an apology"),
				win = { charisma = 1, bond = { 9, 13 }, log = "You apologised so well they forgot what for. {rel} is still not sure how." },
				lose = { money = { -12, -6 }, bond = { 4, 7 }, log = "The apology cost extra. You paid it." },
			},
			{
				label = "Go and stand behind {rel}",
				clash = { stat = "strength", foe = "Rats in an alley", enemy = "rat", fight = true, coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 1, bond = { 10, 14 }, log = "They looked at two of you and decided the debt was smaller than they'd thought." },
				lose = { health = { -6, -3 }, bond = { 6, 9 }, log = "You both ran. You were slower. {rel} came back for you." },
			},
			{ label = "Pay it", requires = { min = { money = 20 } }, result = { money = -20, bond = { 6, 9 }, log = "Twenty Ahn and it was over. {rel} owes you instead, which is cheaper." } },
		},
	},
	{
		id = "sc_sib_noodles",
		title = "One Pot",
		art = "home",
		text = "One pot, two forks, and {rel} has an opinion about every Office in the District.",
		weight = 0,
		social = { kinds = { "sibling" } },
		choices = {
			{ label = "Argue back", result = { intelligence = 1, bond = { 4, 7 }, log = "You were right about Zwei. {rel} was right about everything else, loudly." } },
			{ label = "Let them win", result = { sanity = 2, bond = { 7, 10 }, log = "{rel} won four arguments and ate most of the noodles. A good evening." } },
			{ label = "Do the voices", result = { charisma = 1, sanity = 1, bond = { 5, 8 }, log = "Your Thumb Capo is very good. {rel} nearly choked." } },
		},
	},

	-- ════ friends ═══════════════════════════════════════════════════════════════
	{
		id = "sc_friend_favor",
		title = "A Favor",
		art = "street",
		text = "{rel} has a small job and needs a second pair of hands.",
		weight = 0,
		social = { kinds = { "friend" }, minAge = 12 },
		choices = {
			{
				label = "Do the carrying",
				clash = check("strength", "Three flights and a heavy crate"),
				win = { money = { 8, 16 }, strength = 1, bond = { 6, 10 }, log = "Up three flights and nothing broke. {rel} split the money down the middle.", linked = { money = { 8, 16 }, log = "{sender} carried your crate up three flights and nothing broke. You split the money down the middle." } },
				lose = { health = { -3, -1 }, money = { 3, 6 }, bond = { 4, 7 }, log = "The crate won on the second landing. {rel} paid you anyway.", linked = { log = "{sender} lost a fight with your crate on the second landing. You paid them anyway, out of what was left." } },
			},
			{
				label = "Keep watch",
				clash = check("speed", "Someone coming up the street"),
				win = { money = { 8, 16 }, speed = 1, bond = { 6, 10 }, log = "You whistled in time. Both of you were round the corner before the door opened.", linked = { money = { 8, 16 }, log = "{sender} kept watch for you and whistled in time. You were both round the corner before the door opened." } },
				lose = { sanity = -2, bond = { 4, 7 }, log = "You whistled late. It was only the landlord, this time.", linked = { log = "{sender} kept watch for you and whistled late. It was only the landlord, this time." } },
			},
			{
				label = "Do the talking",
				clash = check("charisma", "A buyer who wants it cheaper"),
				win = { money = { 12, 22 }, charisma = 1, bond = { 6, 10 }, log = "The buyer paid more than {rel} had hoped and thanked you for it.", linked = { money = { 12, 22 }, log = "{sender} did the talking. Your buyer paid more than you'd hoped and thanked them for it." } },
				lose = { money = { 2, 5 }, bond = { 4, 7 }, log = "The buyer talked you down. {rel} said it was still better than nothing.", linked = { money = { 2, 5 }, log = "Your buyer talked {sender} down. It was still better than nothing, and you said so." } },
			},
		},
	},
	{
		id = "sc_friend_diner",
		title = "The Corner Diner",
		art = "diner",
		text = "{rel} has gossip from three Districts and no money at all.",
		weight = 0,
		social = { kinds = { "friend" } },
		choices = {
			{ label = "Buy the food", requires = { min = { money = 12 } }, result = { money = -12, sanity = { 2, 4 }, bond = { 8, 12 }, log = "Two bowls and an hour of everybody else's business. Cheap at the price.", linked = { health = 1, sanity = { 2, 4 }, log = "{sender} bought you two bowls at the corner diner, and you paid in gossip from three Districts." } } },
			{ label = "Trade your own", result = { charisma = 1, bond = { 5, 8 }, log = "Yours was better. {rel} is going to repeat it and get it wrong.", linked = { charisma = 1, log = "{sender} traded gossip with you at the diner. Theirs was better. You're going to repeat it." } } },
			{ label = "Listen for what's useful", result = { intelligence = 1, bond = { 4, 7 }, log = "One Office hiring, one street to stay off. You wrote neither down, and remembered both.", linked = { sanity = 1, log = "{sender} let you talk for an hour at the diner and listened to every word of it." } } },
		},
	},
	{
		id = "sc_friend_spar",
		title = "Let's See, Then",
		art = "arena",
		text = "{rel} wants to know if you've got any better.",
		weight = 0,
		social = { kinds = { "friend", "rival" }, minAge = 14, relMinAge = 14 },
		choices = {
			{
				label = "Spar",
				clash = { stat = "strength", foe = "A friend who means it", fight = true, coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 1, speed = 1, bond = { 5, 8 }, log = "You have. {rel} said so from the ground.", linked = { strength = 1, log = "You sparred with {sender}. They've got better. You said so from the ground." } },
				lose = { health = { -3, -1 }, strength = 1, bond = { 5, 8 }, log = "You haven't, much. {rel} showed you where your feet were wrong.", linked = { strength = 1, speed = 1, log = "You sparred with {sender} and showed them where their feet were wrong." } },
			},
			{ label = "Talk through it instead", result = { intelligence = 1, bond = { 4, 6 }, log = "An hour of \"and then if they do that\". Nobody got bruised.", linked = { intelligence = 1, log = "An hour of \"and then if they do that\" with {sender}. Nobody got bruised." } } },
		},
	},
	{
		id = "sc_friend_late",
		title = "Twenty to Three",
		art = "street",
		text = "It's 2:40 and {rel} lives six streets away.",
		weight = 0,
		social = { kinds = { "friend" }, minAge = 10 },
		choices = {
			{
				label = "Walk them home, fast",
				clash = check("speed", "Six streets and twenty minutes"),
				win = { speed = 1, bond = { 10, 14 }, log = "There and back by 3:09. You've never run like that for anyone.", linked = { sanity = 2, log = "{sender} walked you home at twenty to three, fast, and was back at their own door by 3:09." } },
				lose = { sanity = { -5, -3 }, bond = { 8, 11 }, log = "You heard the street go quiet behind you on the way back. You made your door. Just.", linked = { sanity = 1, log = "{sender} walked you home before three. They only just made their own door afterwards." } },
			},
			{ label = "Make them stay", result = { charisma = 1, sanity = 1, bond = { 6, 9 }, log = "{rel} took the floor and snored. Everybody lived.", linked = { sanity = 1, log = "{sender} wouldn't let you walk home at twenty to three. You took the floor. Everybody lived." } } },
			{ label = "Lend them your coat and hope", result = { bond = { 3, 5 }, sanity = -1, log = "The coat came back in the morning. So did {rel}.", linked = { log = "{sender} lent you a coat for the walk home. You brought it back in the morning." } } },
		},
	},

	-- ════ teachers ══════════════════════════════════════════════════════════════
	{
		id = "sc_mentor_lesson",
		title = "An Hour",
		art = "arena",
		text = "{rel} has an hour for you, and not much patience.",
		weight = 0,
		social = { kinds = { "mentor" } },
		choices = {
			{ label = "Drill the basics", result = { strength = { 1, 2 }, bond = { 3, 6 }, log = "The same three moves until your arms shook. \"Again,\" said {rel}, a great many times." } },
			{ label = "Ask how to read a room", result = { charisma = 1, intelligence = 1, bond = { 4, 7 }, log = "\"Who's standing nearest the door, and why.\" You'll never walk into a room the same way." } },
			{ label = "Ask about the worst job", result = { mind = { 1, 2 }, sanity = -1, bond = { 6, 10 }, log = "{rel} told you. You understand some of the patience now." } },
		},
	},
	{
		id = "sc_mentor_report",
		title = "The Old Report",
		art = "office",
		text = "{rel} hands you a job report. \"A third of this is lies. Which third?\"",
		weight = 0,
		social = { kinds = { "mentor" }, minAge = 13 },
		choices = {
			{
				label = "Find the lies",
				clash = check("intelligence", "A report somebody polished"),
				win = { intelligence = 2, bond = { 6, 9 }, log = "The times didn't add up. {rel} nodded once, which is a parade." },
				lose = { intelligence = 1, bond = { 2, 4 }, log = "You picked the true part. {rel} explained why that's the more dangerous mistake." },
			},
			{ label = "Ask who wrote it", result = { charisma = 1, bond = { 4, 7 }, log = "\"I did,\" said {rel}. Then you got the real version." } },
		},
	},

	-- ════ rivals ════════════════════════════════════════════════════════════════
	{
		id = "sc_rival_table",
		title = "The Same Table",
		art = "diner",
		text = "You and {rel} are at the same table. Nobody planned it.",
		weight = 0,
		social = { kinds = { "rival" }, minAge = 12 },
		choices = {
			{
				label = "Needle them",
				clash = check("charisma", "Somebody who knows your weak spots"),
				win = { sanity = 2, charisma = 1, log = "You got the last word and the last dumpling." },
				lose = { sanity = -2, bond = -4, log = "{rel} had a better one ready. They always do." },
			},
			{ label = "Buy them a bowl", requires = { min = { money = 8 } }, result = { money = -8, bond = { 9, 13 }, log = "{rel} ate it very suspiciously, and came back the next week." } },
			{ label = "Compare scars", result = { strength = 1, bond = { 4, 7 }, log = "Theirs are worse. You'll admit that to nobody." } },
		},
	},

	-- ════ your children ═════════════════════════════════════════════════════════
	{
		id = "sc_child_trains",
		title = "The Trains",
		art = "rooftop",
		text = "{rel} wants to watch the WARP trains.",
		weight = 0,
		social = { kinds = { "child" }, relMaxAge = 12 },
		choices = {
			{ label = "Up on your shoulders", result = { strength = 1, sanity = { 2, 4 }, bond = { 8, 12 }, log = "{rel} could see the whole District from up there, and told you about all of it." } },
			{ label = "Say where each one goes", result = { intelligence = 1, bond = { 6, 9 }, log = "District 23, District 10, the long one to the Nest. {rel} can say them back." } },
			{ label = "Make up where each one goes", result = { charisma = 1, sanity = 2, bond = { 7, 11 }, log = "The blue one goes to the moon. {rel} has corrected you every day since." } },
		},
	},
	{
		id = "sc_child_plans",
		title = "Plans",
		art = "home",
		text = "{rel} has plans, and wants to hear you say they're good ones.",
		weight = 0,
		social = { kinds = { "child" }, relMinAge = 15 },
		choices = {
			{ label = "Tell them the truth", result = { mind = 1, bond = { 2, 9 }, log = "You said what you thought. {rel} was quiet, then asked a better question than you'd expected." } },
			{ label = "Tell them they're good", result = { charisma = 1, bond = { 7, 10 }, log = "{rel} left taller. You hope the City agrees with you." } },
			{ label = "Give them something to start with", requires = { min = { money = 80 } }, result = { money = -80, bond = { 12, 16 }, sanity = 2, log = "It wasn't much. It was more than anyone gave you." } },
		},
	},
}
