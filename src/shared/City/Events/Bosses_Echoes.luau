--[[
	ECHOES of the big bosses (v0.15): another player on the server brought one down
	(Chronicle/Bosses15.luau), and it reaches this life. {actor} did it, in {actorDistrict}.
	This is where players' stories cross: what one does, the others live with.
]]

return {
	{
		id = "b15_echo_sottocapo",
		title = "The Thumb Closes Ranks",
		text = "Since {actor} beat the Sottocapo in {actorDistrict}, every Capo in the City is doubling the Soldati at the door. Contribution has gone up on every street the Thumb protects, including yours.",
		weight = 8,
		cooldown = 8,
		tags = { "danger" },
		when = { chronicle = "b15_act_sottocapo", minAge = 14, side = "backstreets" },
		choices = {
			{ label = "Pay the new rate", requires = { min = { money = 120 } }, result = { money = -120, rep = { thumb = 2 }, log = "You paid. The Soldato thanked you twice, which is the new rate for thanks." } },
			{
				label = "Refuse, citing {actor}",
				hint = "A real fight. The Thumb is nervous.",
				clash = { stat = "strength", foe = "Soldati with something to prove", enemy = "thumb_soldato", coins = 3, base = 6, coinPower = 3, fight = true, status = { id = "burn", potency = 2 } },
				win = { strength = 2, rep = { thumb = -8 }, log = "\"If {actor} can do it,\" you said. The Soldati found out you could too." },
				lose = { health = { -20, -12 }, condition = "propellant_scar", cause = "Refused the Thumb in a nervous year", log = "Nervous Soldati shoot faster." },
			},
			{ label = "Keep your head down", result = { sanity = -2, money = -40, log = "You paid half and apologised for the other half. The Soldato wrote it down." } },
		},
	},
	{
		id = "b15_echo_big_brother",
		title = "Title 1",
		text = "The whole Middle is reading the same Line in the Book: Title 1, about {actor} of {actorDistrict}. Little Siblings are asking on every street who knows {actor}, and who has ever stood next to them.",
		weight = 8,
		cooldown = 8,
		tags = { "danger" },
		when = { chronicle = "b15_act_big_brother", minAge = 14 },
		choices = {
			{ label = "Say you never met them", clash = { stat = "charisma", foe = "Little Siblings with a drawing", coins = 3, base = 5, coinPower = 3 }, win = { charisma = 1, log = "They showed you a drawing of {actor}. You'd never seen them. It was a very good drawing." }, lose = { health = { -10, -5 }, condition = "in_the_book", log = "They decided you were lying. You weren't. It doesn't matter, to the Book." } },
			{ label = "Ask what {actor} did", result = { mind = 1, sanity = -1, log = "A Little Sister told you, with relish, every detail. The Middle loves a story as much as a grudge." } },
			{ label = "Leave the street for a while", result = { money = -50, sanity = 1, log = "You stayed with a cousin for a month, until the Siblings found a better lead." } },
		},
	},
	{
		id = "b15_echo_prescript",
		title = "A Broken Prescript",
		text = "A Proxy failed a Prescript in {actorDistrict} because of {actor}, and now the Index is uneasy. Proselytes stand on corners rereading their slips, and twice today one has stopped you to ask the time, very precisely.",
		weight = 8,
		cooldown = 8,
		when = { chronicle = "b15_act_prescript", minAge = 12 },
		choices = {
			{ label = "Tell them the time", result = { intelligence = 1, log = "\"Seventeen minutes past,\" you said. They wrote it down and thanked you as if you'd saved a life." } },
			{ label = "Ask what the slip says", clash = { stat = "intelligence", foe = "A Proselyte's devotion", coins = 2, base = 5, coinPower = 3 }, win = { intelligence = 2, rep = { index = 3 }, log = "They let you read it: Ask the time of the third passer-by. You were the third. Everyone relaxed." }, lose = { health = { -8, -4 }, log = "The slip didn't say to show you the slip." } },
			{ label = "Walk the long way home", result = { sanity = 1, log = "Six streets out of your way. Every corner had someone in white on it, reading." } },
		},
	},
	{
		id = "b15_echo_exhibition",
		title = "The Unfinished Piece",
		text = "Since {actor} walked out of an exhibition in {actorDistrict} unfinished, the Ring has been obsessed with the idea. Students are sketching strangers in the street, and every sketch is left half done, on purpose.",
		weight = 7,
		cooldown = 8,
		when = { chronicle = "b15_act_exhibition", minAge = 12 },
		choices = {
			{ label = "Let a Student sketch you", clash = { stat = "luck", foe = "A Student's mood", coins = 2, base = 5, coinPower = 3 }, win = { luck = 1, charisma = 1, log = "Pencil only. She stopped at your chin and gave it to you. \"Unfinished,\" she said, reverent. \"Like {actor}.\"" }, lose = { health = { -8, -4 }, sanity = -3, condition = "deep_cut", log = "She preferred to work in something other than pencil." } },
			{ label = "Ask about {actor}", result = { mind = 1, log = "\"A masterpiece that walked away,\" the Student said. \"We'll never get over it.\"" } },
			{ label = "Cross the street", result = { speed = 1, log = "You crossed. So did the Student. You crossed back. So did she. Eventually she got bored." } },
		},
	},
	{
		id = "b15_echo_kurokumo",
		title = "The Clan Is Watching",
		text = "A Captain of the Kurokumo was beaten by {actor} in {actorDistrict}, and now the Clan is in a mood. Wakashu walk your street in pairs, looking everyone in the eye, hoping someone will look back.",
		weight = 7,
		cooldown = 8,
		tags = { "danger" },
		when = { chronicle = "b15_act_kurokumo", minAge = 14, side = "backstreets" },
		choices = {
			{ label = "Lower your eyes", result = { sanity = -2, log = "You looked at your shoes all week. They're very nice shoes." } },
			{
				label = "Look back",
				hint = "A real fight. The Clan is spoiling for one.",
				clash = { stat = "speed", foe = "Two Wakashu in a mood", enemy = "kurokumo", coins = 3, base = 6, coinPower = 3, fight = true, status = { id = "bleed", potency = 2 } },
				win = { speed = 2, rep = { kurokumo = -6 }, log = "They drew. You were quicker, twice. They bowed, which they never do, and went to tell someone." },
				lose = { health = { -18, -10 }, condition = "deep_cut", cause = "Met a Kurokumo's eyes in a bad week", log = "The Clan was spoiling for a fight. You gave it one." },
			},
			{ label = "Bring them tea", result = { charisma = 1, rep = { kurokumo = 2 }, log = "They took it without a word. The next day they were on a different street." } },
		},
	},
	{
		id = "b15_echo_rhino",
		title = "R Corp Lost Its Rhino",
		text = "R Corp lost the Rhino to {actor} in {actorDistrict}, and has decided it was the whole District's fault. There's a curfew now, with Rabbits on the corners. People with nowhere to be by dark are being counted.",
		weight = 7,
		cooldown = 10,
		tags = { "danger" },
		when = { chronicle = "b15_act_rhino", minAge = 14 },
		choices = {
			{ label = "Keep the curfew", result = { sanity = -2, money = -30, log = "Home by dusk for a month. You lost a month of evening work and kept everything else." } },
			{ label = "Work through it", clash = { stat = "speed", foe = "Rabbits on the corners", coins = 3, base = 6, coinPower = 3 }, win = { speed = 1, wage = { 60, 140 }, log = "Rooftops and back stairs. You made more than usual: nobody else was working." }, lose = { health = { -16, -8 }, cause = "Counted after curfew by R Corp", log = "A Rabbit counted you." } },
			{ label = "Help someone get home", result = { charisma = 1, sanity = 2, log = "You walked an old man three streets home ahead of the Rabbits. He told you all about {actor}, twice." } },
		},
	},
	{
		id = "b15_echo_bellringer",
		title = "Everyone Remembers",
		text = "When {actor} silenced the Bellringer in {actorDistrict}, a whole block remembered every word it had taken from them, all at once. Some of those words were about other people. Some of them were about your street.",
		weight = 6,
		cooldown = 10,
		when = { chronicle = "b15_act_bellringer", minAge = 12, world = { era = { "library", "limbus" } } },
		choices = {
			{ label = "Listen to what came back", result = { mind = 2, sanity = -3, log = "A stranger stopped you to tell you something your grandmother said, years ago, that a bell had kept." } },
			{ label = "Buy {actor} a drink of tea", result = { charisma = 1, sanity = 2, log = "You didn't find them. You left the tea at the noodle stall in their name, which is how the street says thank you." } },
			{ label = "Take your own bell down", result = { sanity = 1, log = "The bell over your door went in a drawer. Just in case." } },
		},
	},
	{
		id = "b15_echo_hostess",
		title = "The Party's Over",
		text = "The guests from the Hostess's party in {actorDistrict} are home, thanks to {actor}: forty people who lost a month dancing. One of them is your neighbour, who keeps asking what the music was.",
		weight = 6,
		cooldown = 10,
		when = { chronicle = "b15_act_hostess", minAge = 12, world = { era = { "library", "limbus" } } },
		choices = {
			{ label = "Sit with your neighbour", result = { charisma = 1, sanity = 1, log = "She hummed it for you. It was lovely. You were both quiet for a while afterwards." } },
			{ label = "Ask what she saw", result = { mind = 2, sanity = -3, log = "\"Everyone was so happy,\" she said. \"That was the frightening part.\"" } },
			{ label = "Throw out the invitation she kept", result = { mind = 1, sanity = 2, log = "She'd kept it in her coat pocket. You burned it in the stove. It burned green." } },
		},
	},
}
