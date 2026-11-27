--[[
	The Ring and the Pinky. The Ring's "art" is presented Roblox-safe as eerie installations,
	stopped clocks and Automanikins (docs/CANON.md 3.5, 12.2). Docent rank "comparable to a Capo
	of the Thumb or a Big Sibling of the Middle" is from Limbus game text. The Pinky stays
	cryptic (3.6); the Ring-Pinky war in the Outskirts is fan-wiki material, so only a rumor.
]]

return {
	-- ── the Ring, from outside ──
	{
		id = "fn_ring_portrait",
		title = "A Remarkable Face",
		text = "A thin man with paint under his fingernails and a Docent's ring on his finger stops you in the street. \"You have a remarkable face,\" he says. \"I'm making a portrait. I'd like to watch you for one year. You won't be harmed. You may not like the result.\" He's from the Ring, and the Ring isn't really asking.",
		weight = 8,
		once = true,
		tags = { "fingers", "strange" },
		when = { minAge = 16, notFlags = { "fn_ring_member" } },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "Agree",
				result = { condition = "fn_ring_subject", wage = { 100, 200 }, setFlags = { "fn_ring_portrait_sat" }, schedule = { event = "fn_ring_unveiling", inYears = 1 }, log = "You agreed. He paid in advance, generously, and you started seeing his patient face at the edge of every crowd." },
			},
			{
				label = "Refuse, politely",
				clash = { stat = "mind", foe = "A Docent's interest", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 1, log = "He bowed. \"Another face, then.\" You never saw him again, which was a relief you could feel in your teeth." },
				lose = { condition = "fn_ring_subject", setFlags = { "fn_ring_portrait_sat" }, schedule = { event = "fn_ring_unveiling", inYears = 1 }, log = "He smiled as though you'd said yes. The year began anyway." },
			},
			{
				label = "Ask to see his other portraits",
				result = { sanity = -5, mind = 2, log = "He showed you a gallery of very lifelike mannequins, all turned toward the door. You didn't ask how lifelike. You left quickly." },
			},
		},
	},
	{
		id = "fn_ring_unveiling",
		title = "The Unveiling",
		text = "An invitation arrives on black card: the unveiling of the Docent's portrait, in a gallery you reach through a closed laundry. The portrait is you, perfectly, standing in your own doorway at 3:12 in the morning, which you have never done. Everyone at the opening looks from the canvas to you, and back again.",
		weight = 0,
		when = { flags = { "fn_ring_portrait_sat" } },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "Buy the portrait",
				hint = "150 Ahn",
				requires = { min = { money = 150 } },
				result = { money = -150, sanity = 2, log = "You bought it and turned it to face the wall. Some nights you are almost sure it has turned back around." },
			},
			{
				label = "Let it hang",
				result = { sanity = -3, intelligence = 2, log = "You left it there. People come to the gallery to see it. Strangers on your street look at you now as if they've seen you somewhere." },
			},
			{
				label = "Ask him to burn it",
				clash = { stat = "mind", foe = "An artist's pride", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 4, log = "He burned it in front of you, smiling. \"The burning was the real portrait,\" he said. You still don't know what that means." },
				lose = { sanity = -4, log = "\"Art isn't burned,\" he said gently. \"It's finished.\" The portrait stays in the gallery, finished." },
			},
		},
	},
	{
		id = "fn_ring_gallery",
		title = "By Invitation Only",
		text = "A black card slides under your door: an opening at a Corporist gallery of the Ring, tonight, before three. The Corporists build Automanikins, life-sized mannequins posed as if caught in the middle of a thought. Rumor says some of them blink. The card has your name on it, spelled correctly, which is somehow the worst part.",
		weight = 6,
		once = true,
		tags = { "fingers", "strange" },
		when = { minAge = 16, notFlags = { "fn_ring_member" } },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "Go to the opening",
				result = { sanity = -4, intelligence = 3, log = "The Automanikins stood in a park of paper trees, each frozen mid-gesture. One had your posture exactly. You didn't sleep, but you've noticed everything since." },
			},
			{
				label = "Give the card to an art student",
				result = { sanity = 1, log = "You gave it to the art student on the third floor. She went, and came back a Pointillist. She paints only in dots now, very small ones." },
			},
			{
				label = "Burn the card",
				result = { sanity = 2, log = "You burned it in the sink. A second card arrived the next morning with a note in the same hand: Another time." },
			},
		},
	},
	{
		id = "fn_ring_pinky_war",
		title = "A War Past the Walls",
		text = "A trader back from the Outskirts swears the Ring and the Pinky are at war out there, past the edge of the City, where nobody can watch. He saw a gallery of mannequins standing in an empty field, he says, and a line of quiet people walking toward it. He doesn't know who won. He doesn't want to know.",
		weight = 4,
		once = true,
		tags = { "fingers", "strange" },
		when = { minAge = 14, world = { era = { "library", "limbus" } } },
		codex = "fn_lore_pinky",
		choices = {
			{
				label = "Believe him",
				result = { sanity = -2, mind = 2, log = "You believed him. After that you noticed how many quiet people there are in the City, and how few of them ever say where they're from." },
			},
			{
				label = "Buy his map of the Outskirts",
				hint = "20 Ahn",
				requires = { min = { money = 20 } },
				result = { money = -20, intelligence = 2, log = "The map showed the City as a small gray shape in a huge blank. Someone had drawn a tiny ring in one corner, and a tiny hand in another." },
			},
		},
	},

	-- ── members ──
	{
		id = "fn_ring_critique",
		title = "Your First Critique",
		text = "A Docent of your school critiques the Students' work once a season, and Students who fail are reassigned to duties nobody describes. Your piece is a room-sized installation of three hundred clocks, all stopped at 3:13. The Docent walks around it twice without a word.",
		weight = 24,
		once = true,
		tags = { "fingers" },
		when = { career = "ring", notFlags = { "fn_ring_docent" } },
		choices = {
			{
				label = "Explain your idea",
				clash = { stat = "intelligence", foe = "A Docent's silence", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, sanity = 2, setFlags = { "fn_ring_praised" }, log = "\"The Night, as an object,\" she said at last. \"Adequate.\" Two other Students wept with envy." },
				lose = { sanity = -4, log = "She said your idea was a description of an idea. You spent the season sweeping the gallery." },
			},
			{
				label = "Say nothing and let it speak",
				clash = { stat = "mind", foe = "A Docent's silence", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 3, mind = 1, setFlags = { "fn_ring_praised" }, log = "You said nothing. Neither did she. She came back the next day, alone, and sat among the clocks for an hour." },
				lose = { sanity = -4, log = "She waited for you to explain. When you didn't, she wrote one word on a card and left it on the floor. You haven't turned it over." },
			},
			{
				label = "Start one clock while she watches",
				result = { sanity = -2, intelligence = 3, log = "You set one clock ticking. Every Student in the room flinched. The Docent laughed out loud, which nobody had ever heard her do." },
			},
		},
	},
	{
		id = "fn_ring_school",
		title = "Choosing a School",
		text = "Every Student of the Ring joins a school eventually. The Pointillists build pictures from tiny dots, patient past the point of sense. The Fauvists work in loud, wild color and keep splitting into smaller Fauvisms over arguments. The Corporists build Automanikins. Each school has sent you an invitation sealed in wax.",
		weight = 20,
		once = true,
		tags = { "fingers" },
		when = { career = "ring", notFlags = { "fn_ring_docent" } },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "The Pointillists",
				result = { setFlags = { "fn_ring_pointillist" }, intelligence = 3, log = "You spent your first year with the Pointillists on a single square of canvas the size of your palm. It has eleven thousand dots. You know each one." },
			},
			{
				label = "The Fauvists",
				result = { setFlags = { "fn_ring_fauvist" }, strength = 2, sanity = 2, log = "The Fauvists welcomed you with a shouting match about the color orange. By the end of the night there were two schools of Fauvism, and you were in both." },
			},
			{
				label = "The Corporists",
				result = { setFlags = { "fn_ring_corporist" }, health = 2, sanity = -2, log = "The Corporists taught you to build an Automanikin's hand. You're fairly sure it moved when you weren't looking. They said that means you did it right." },
			},
		},
	},
	{
		id = "fn_ring_docent",
		title = "A Docent's Ring",
		text = "Your new ring has a shape that only members of the Ring can read: Docent, a rank people compare to a Capo of the Thumb or a Big Sibling of the Middle. Your first duty is to judge a Student who has spent a year on a single piece, and who is standing beside it, trying very hard not to shake.",
		weight = 20,
		once = true,
		tags = { "fingers" },
		when = { career = "ring", flags = { "fn_ring_docent" }, notFlags = { "fn_ring_maestro" } },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "Judge it honestly",
				clash = { stat = "intelligence", foe = "A year of someone's work", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = 2, intelligence = 2, log = "You found the one true thing in it and named it. The Student wept, thanked you, and began again." },
				lose = { sanity = -4, log = "You judged it honestly and harshly. The Student left the Ring that week. You keep the piece in your studio." },
			},
			{
				label = "Praise it, whatever it is",
				result = { sanity = 1, log = "You praised it. The Student glowed. The other Docents looked at you with something like pity." },
			},
			{
				label = "Ask what it's for",
				result = { mind = 2, log = "\"For you,\" the Student said. \"I made it to be judged by you.\" You've never been given a stranger gift." },
			},
		},
	},
	{
		id = "fn_ring_movement",
		title = "Your Own Movement",
		text = "Your work has stopped looking like anyone else's. Other Docents call it a school. Students copy you badly in back rooms. A Maestro of the Ring is someone who has founded a movement of their own, and there are whispers that you are halfway there. All it takes now is a manifesto, a name, and the nerve.",
		weight = 14,
		once = true,
		tags = { "fingers" },
		when = { career = "ring", flags = { "fn_ring_docent" }, notFlags = { "fn_ring_maestro" }, minAge = 30 },
		choices = {
			{
				label = "Write the manifesto",
				clash = { stat = "intelligence", foe = "The first sentence", coins = 3, base = 6, coinPower = 3 },
				win = { promote = true, sanity = 3, log = "You wrote it in one night, eleven lines long. By the end of the month forty Students were calling themselves by the name you chose." },
				lose = { sanity = -5, log = "You wrote a manifesto. Another Docent wrote a better one, about yours. You burned both." },
			},
			{
				label = "Wait for it to found itself",
				result = { sanity = 1, mind = 1, log = "You kept working and said nothing. The Students kept copying. Movements, you decided, are like the Night: they come when they come." },
			},
		},
	},
	{
		id = "fn_ring_maestro",
		title = "Maestro",
		text = "You are a Maestro of the Ring. Your movement has a name, a gallery, a dozen Docents and more Students than you can count, all trying to see the world the way you do. The first opening is tonight, by invitation only, and you alone decide who receives an invitation.",
		weight = 200,
		once = true,
		tags = { "fingers" },
		when = { career = "ring", minRank = 3 },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "Invite the City's critics",
				result = { chronicle = "fn_maestro", sanity = 2, wage = { 200, 400 }, log = "The critics came, saw, and wrote about nothing else for a month. Three of them changed careers." },
			},
			{
				label = "Invite your old street",
				result = { chronicle = "fn_maestro", sanity = 5, log = "You invited everyone from the street you grew up on. Most of them hated it. One old noodle cook stood in front of a piece for an hour and said it was exactly what the Night feels like." },
			},
			{
				label = "Invite no one",
				result = { chronicle = "fn_maestro", sanity = -2, intelligence = 3, log = "You opened the gallery and invited no one. The City talked about the empty opening for years. That was the point." },
			},
		},
	},

	-- ── the Pinky ──
	{
		id = "fn_pinky_coworker",
		title = "The Quiet Coworker",
		text = "Your coworker Ama is the quietest person you know. She does her work, eats at her desk, and once every few years she disappears for exactly a week without asking for time off. Today she's back from one of those weeks, and leaves a small wrapped gift on your desk without a word. Nobody else noticed she was gone.",
		weight = 7,
		once = true,
		tags = { "fingers", "strange" },
		when = { minAge = 20, anyCareer = true },
		codex = "fn_lore_pinky",
		choices = {
			{
				label = "Thank her and ask nothing",
				result = { sanity = 3, setFlags = { "fn_pinky_friend" }, schedule = { event = "fn_pinky_summoned", inYears = 4 }, log = "Inside was a handkerchief embroidered with your initials, perfectly. You thanked her. She smiled, slightly, and went back to work." },
			},
			{
				label = "Ask where she goes",
				clash = { stat = "mind", foe = "A very quiet answer", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, setFlags = { "fn_pinky_friend" }, schedule = { event = "fn_pinky_summoned", inYears = 4 }, log = "\"To see family,\" she said, which was true, you think, in some way you weren't meant to understand." },
				lose = { sanity = -2, log = "She looked at you for a long moment and didn't come in the next day, or ever again. By noon her desk was empty, as if it always had been." },
			},
			{
				label = "Report her absences",
				result = { sanity = -2, log = "The boss checked the records and couldn't find a single absence. He told you to take a week off yourself, and looked worried about you." },
			},
		},
	},
	{
		id = "fn_pinky_summoned",
		title = "A Very Quiet Week",
		text = "One week, without warning, everyone quiet in the District is gone at once: Ama from work, the tea seller who never talks, the night watchman, a Capo's silent driver, a Little Sister of the Middle who only ever nodded. Nobody remarks on it. A week later they're all back at their posts, and nobody remarks on that either.",
		weight = 0,
		when = { flags = { "fn_pinky_friend" } },
		codex = "fn_lore_pinky",
		choices = {
			{
				label = "Ask Ama nothing, ever",
				result = { sanity = 4, log = "You asked nothing. Ama left a cup of tea on your desk every morning for the rest of the year." },
			},
			{
				label = "Follow her next time",
				clash = { stat = "strength", foe = "People who are very good at not being followed", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = -3, mind = 3, log = "You followed her to the edge of the District, where two hundred quiet people stood in the rain, perfectly still. She turned and looked straight at you. You went home." },
				lose = { sanity = -5, log = "You lost her at the first corner. The next morning there was a note on your desk in very neat handwriting: Please don't." },
			},
		},
	},
}
