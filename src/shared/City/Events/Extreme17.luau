--[[
	EXTREME EVENTS (v0.17, ex17_ ids): one-of-a-kind cards that only find lives the City has
	started to fear, each with a battle against an extreme boss (City/Bosses17.luau) built for
	stats past 250. Every one can be walked away from, at a price. Winning breaks every limit
	you have (limitBreak = { all = n }), and the whole server hears about it.

	Gates are Hana's threat grades (renown ranks: 5 Urban Plague, 6 Urban Nightmare, 7 Star of
	the City, 8 Impurity), so the City sends these at people whose name has grown that big.
]]

local function boss(label: string, id: string, fallback: any, win: any, lose: any)
	return { label = label, battle = id, clash = fallback, win = win, lose = lose }
end

return {
	{
		id = "ex17_night_out",
		title = "Out After 3:13",
		art = "night",
		weight = 10,
		once = true,
		tags = { "danger" },
		when = { minAge = 25, side = "backstreets", renown = 5 },
		text = "It's 3:12. A child from the next building is in the street, crying, looking for a cat. In one minute the Night begins, and everyone in the Backstreets knows what comes with it. Every door on the street is shut. Yours is open. You're the only person in the District who might be able to stand in the street through the Night and still be standing at four.",
		scene = { set = "street", title = "Out After 3:13", line = "I can't find her. She's out here somewhere.", other = { name = "A child from next door", role = "looking for a cat", pose = "stand" } },
		choices = {
			boss("Go out and stand in the street", "night_sweepers",
				{ stat = "strength", foe = "The Night's Sweepers", enemy = "sweeper", fight = true, coins = 5, base = 19, coinPower = 9, fixed = true, boss = true },
				{ limitBreak = { all = 20 }, renown = 120, strength = 6, speed = 6, setFlags = { "ex17_survived_night" }, announce = "{name} of {district} stood in the street through the whole Night, and walked back in at four.", log = "At four the street was empty again, the way it always is, except for you, and a child behind you, holding a cat. Every door on the street opened at once." },
				{ health = { -60, -30 }, sanity = -15, log = "You got the child inside at 3:14, and then you got yourself inside, barely, at 3:20. The door has marks on it now that nobody can explain." }),
			{ label = "Pull the child in and bar the door", clash = { stat = "speed", foe = "The last minute before the Night", coins = 4, base = 16, coinPower = 8, fixed = true }, win = { speed = 4, renown = 40, log = "You were across the street and back with the child under your arm before 3:13. The cat came in by itself, the way cats do." }, lose = { health = { -30, -15 }, sanity = -8, log = "You got the child in. Something touched your back as the door shut. You don't talk about it." } },
			{ label = "Shout for them to come in", result = { sanity = -4, log = "You shouted until they came in. The cat came home by itself the next morning, the way cats do, and the child told everyone you'd been scared. You had." } },
		},
	},
	{
		id = "ex17_prescript",
		title = "A Prescript With Your Name",
		art = "nest",
		weight = 9,
		once = true,
		tags = { "danger" },
		when = { minAge = 25, renown = 5 },
		text = "A Messenger of the Index is standing in your kitchen. It didn't knock. It holds out a Prescript the way a waiter holds out a menu, and your name is on it, in the Index's careful hand. \"The Prescript names you,\" it says, almost apologetically. \"It was always going to.\"",
		scene = { set = "room", title = "A Prescript With Your Name", line = "It was always going to be you. Please don't take it personally.", other = { name = "A Messenger of the Index", role = "holding your Prescript", pose = "stand" } },
		choices = {
			boss("Refuse the Prescript", "index_messenger_ex",
				{ stat = "strength", foe = "A Messenger of the Index", enemy = "index_messenger", fight = true, coins = 5, base = 21, coinPower = 10, fixed = true, boss = true },
				{ limitBreak = { all = 25 }, renown = 140, strength = 6, intelligence = 4, rep = { index = -20 }, setFlags = { "ex17_refused_prescript" }, announce = "{name} of {district} refused a Prescript, and the Messenger who brought it went home without an answer.", log = "The Messenger looked at the Prescript for a long time. Then it folded it, very carefully, and put it in its pocket. \"There'll be another,\" it said. \"There's always another.\"" },
				{ health = { -60, -30 }, rep = { index = -10 }, log = "The Messenger carried out as much of the Prescript as it could, which was nearly all of it. You're alive because the last line was smudged." }),
			{ label = "Read the Prescript", clash = { stat = "intelligence", foe = "What the Index wants from you", coins = 4, base = 16, coinPower = 8, fixed = true }, win = { intelligence = 5, rep = { index = 8 }, mind = 3, log = "It asked for something small and strange: a red umbrella left on a particular bench at a particular hour. You did it. Somewhere in the City, something happened exactly as written." }, lose = { sanity = -12, rep = { index = 4 }, log = "You did what it said. You still don't know what it was for. You dream about the bench." } },
		},
	},
	{
		id = "ex17_color_contract",
		title = "A Color Took the Contract",
		art = "rooftop",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { minAge = 28, renown = 6 },
		text = "Somebody important wants you gone, and they paid enough that a Color answered. The Umber Lantern is sitting on the wall across the street, swinging the lantern on its chain, waiting with the patience of somebody who has never once failed a contract. The whole District has gone quiet. It's very polite of the Lantern to let you see it coming.",
		scene = { set = "street", title = "A Color Took the Contract", line = "Nothing personal. It's a contract, and I took it.", other = { name = "The Umber Lantern", role = "a Color of the City", pose = "fight" } },
		choices = {
			boss("Fight a Color", "color_umber",
				{ stat = "strength", foe = "The Umber Lantern", enemy = "color_umber", fight = true, coins = 6, base = 23, coinPower = 11, fixed = true, boss = true },
				{ limitBreak = { all = 30 }, renown = 200, strength = 8, speed = 8, setFlags = { "ex17_beat_a_color" }, announce = "{name} of {district} fought a Color to a standstill, and the Color tore up the contract.", log = "The Umber Lantern sat down on the kerb, set the lantern down, and tore the contract in half. \"I'll give them their money back,\" it said. \"I've never done that. You should be proud.\"" },
				{ health = { -70, -40 }, log = "The Lantern stopped. \"That's enough,\" it said. \"The contract said 'stop them'. You're stopped.\" It left you in the street, alive, as a professional courtesy." }),
			{ label = "Outbid the client", requires = { min = { money = 20000 } }, result = { money = -20000, log = "Colors take contracts. They also take better contracts. The Lantern counted the money twice, bowed, and went to have a long conversation with whoever hired it." } },
			{ label = "Leave the District tonight", result = { sanity = -10, renown = -40, log = "You were four Districts away by dawn. The Lantern didn't follow. A Color doesn't chase; it waits. You'll never quite stop looking at walls." } },
		},
	},
	{
		id = "ex17_clocktower",
		title = "The District That Stopped",
		art = "distortion",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { minAge = 25, renown = 6, world = { era = { "library", "limbus" } } },
		text = "A clockmaker on the next street Distorted at noon, and now every clock in the District is stuck at 12:00 and the square is a Clocktower the height of a Nest wall. Hana graded it Star of the City an hour ago: the grade for things that can end a District. The Associations are still arguing about whose Section goes in. You're already here.",
		choices = {
			boss("Go into the square", "clocktower_distortion",
				{ stat = "strength", foe = "The Stopped Clocktower", enemy = "clocktower", fight = true, coins = 5, base = 22, coinPower = 11, fixed = true, boss = true },
				{ limitBreak = { all = 30 }, renown = 220, strength = 7, mind = 6, setFlags = { "ex17_stopped_clocktower" }, announce = "{name} of {district} went into the square alone and brought down a Star of the City. The District's clocks are running again.", log = "The last gear stopped turning. Every clock in the District ticked once, together, and then went on as if nothing had happened. On the stones where the tower stood there was a pocket watch, still running. You kept it." },
				{ health = { -70, -40 }, sanity = -15, log = "You held it long enough for the Associations to finish arguing. Three Sections went in after you. The District's clocks are an hour slow now, forever." }),
			{ label = "Get the street out first", clash = { stat = "speed", foe = "Four thousand people and one way out", coins = 4, base = 16, coinPower = 8, fixed = true }, win = { speed = 5, charisma = 3, renown = 60, log = "You got the whole street out through the laundries and the back stairs before the Clocktower struck one. Nobody on your street was stopped." }, lose = { health = { -25, -10 }, sanity = -8, log = "You got most of them out. The ones you didn't are still standing in the square at noon, as far as anyone can tell, and always will be." } },
		},
	},
	{
		id = "ex17_claw",
		title = "The Head Is Listening",
		art = "wing",
		weight = 10,
		once = true,
		tags = { "danger" },
		when = { minAge = 30, renown = 8 },
		text = "Hana graded you an Impurity: a danger to the City itself. This morning a figure stood at the end of your street, very still, in a long coat, and every bird on the block flew away at once. You know what it is without anyone telling you. The Head sends Claws where the City's rules are being broken, and someone up there has decided to take a look at you.",
		scene = { set = "street", title = "The Head Is Listening", line = "(It says nothing. It doesn't need to.)", other = { name = "A Claw of the Head", role = "at the end of your street", pose = "stand" } },
		choices = {
			boss("Stand your ground", "head_claw",
				{ stat = "strength", foe = "A Claw of the Head", enemy = "claw", fight = true, coins = 6, base = 27, coinPower = 13, fixed = true, boss = true },
				{ limitBreak = { all = 40 }, renown = 300, strength = 10, speed = 10, mind = 8, setFlags = { "ex17_survived_claw" }, announce = "A Claw of the Head came for {name} of {district}, and went away again. Nobody on the boards has ever posted a sentence like that.", log = "The Claw stopped. It looked at you for a long, long time, and then it put its gloves back on and walked away down the street, at the same unhurried pace, and didn't look back. Somewhere very high up, someone has decided you're not worth the trouble. Today." },
				{ health = { -90, -50 }, sanity = -20, log = "It corrected you, the way the Head corrects the City, and left you breathing, which you understand was a choice it made. You won't be an Impurity again soon. You'll be careful about what you are." }),
			{ label = "Stop what you're doing", result = { sanity = -10, renown = -150, log = "You put it all down: the plans, the name, the reach. The Claw watched for a week. On the eighth day it was gone. The Head isn't interested in people who stop." } },
		},
	},
	{
		id = "ex17_last_hunter",
		title = "The Last Hunter",
		art = "alley",
		weight = 12,
		once = true,
		tags = { "danger" },
		when = { form = "bloodfiend", bloodYears = 160 },
		text = "There's a hunter who has spent forty years on one Bloodfiend, the oldest one in the District, and his teacher spent forty before him, and hers before her. Tonight Aurek Thane is standing in your hall with his teacher's knife and a crossbow and a very old oath. He waited until you were home, so nobody else would be.",
		scene = { set = "hall", title = "The Last Hunter", line = "Forty years. My teacher's forty, and hers. It ends tonight, one way or the other.", other = { name = "Aurek Thane", role = "the last hunter", pose = "fight" } },
		choices = {
			boss("End it", "last_hunter",
				{ stat = "strength", foe = "Aurek Thane, the Last Hunter", enemy = "legend_hunter", fight = true, coins = 5, base = 21, coinPower = 10, fixed = true, boss = true },
				{ limitBreak = { all = 30 }, renown = 160, strength = 8, maxHealth = 20, setFlags = { "ex17_last_hunter" }, announce = "The last hunter of the old line came for {name} of {district}. The line ends there.", log = "Thane sat down against the wall and laughed. \"Forty years,\" he said. \"I knew it'd end with me on the floor. I just thought I'd be older.\" You let him walk out. The line of hunters ends with him, by his own choice." },
				{ health = { -70, -40 }, log = "Thane's oath was older than your blood, almost. You got away into the dark, and he didn't follow. He's writing it down for his student." }),
			{ label = "Talk to him", clash = { stat = "charisma", foe = "A hundred and twenty years of a hunters' line", coins = 4, base = 18, coinPower = 9, fixed = true }, win = { charisma = 6, mind = 4, setFlags = { "ex17_last_hunter" }, log = "You talked until dawn, about his teacher, and hers, and the first one, who you knew. At dawn he put the knife on your table and left it there. The line ends with a conversation." }, lose = { health = { -30, -15 }, log = "He'd heard every story. He wasn't here for stories." } },
		},
	},
	{
		id = "ex17_aleph",
		title = "Containment Failure",
		art = "lcorp",
		weight = 10,
		once = true,
		tags = { "danger" },
		-- (like every extreme card, only for a name the City has started to fear: Urban Plague)
		when = { minAge = 22, renown = 5, career = { "lcorp_agent", "lcorp_research" }, world = { era = { "wings", "white_nights" } } },
		text = "Every alarm in your branch goes off at once, and then changes pitch, which is the sound nobody wants to hear. An ALEPH-class Abnormality is out of containment. The Sephirah's voice on the intercom is very calm. Every agent in your department is younger than you, and every one of them is looking at you.",
		choices = {
			boss("Suppress it", "aleph_breach",
				{ stat = "strength", foe = "An ALEPH-class Abnormality", enemy = "aleph", fight = true, coins = 5, base = 18, coinPower = 8, fixed = true, boss = true },
				{ limitBreak = { all = 25 }, renown = 150, strength = 6, mind = 6, setFlags = { "ex17_suppressed_aleph" }, announce = "{name} suppressed an ALEPH-class breach at L Corp, and the branch held.", log = "It went back into its unit at 4:12 in the afternoon. The department was standing. The manager wrote your name in the day's report in capital letters, which nobody had ever seen a manager do." },
				{ health = { -70, -40 }, sanity = -20, log = "It went back in eventually, because the Sephirah did something you weren't cleared to know about. You were in the medical wing for a month. The department got smaller." }),
			{ label = "Get the department out", clash = { stat = "mind", foe = "A department full of panic", coins = 4, base = 16, coinPower = 8, fixed = true }, win = { mind = 5, charisma = 3, log = "You walked eighteen agents out through the maintenance corridors, talking the whole time in a voice you didn't know you had. All eighteen." }, lose = { sanity = -15, log = "You got most of them out." } },
		},
	},
}
