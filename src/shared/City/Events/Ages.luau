--[[
	THE AGES: the turning points every life in the City lives through, and the voice.

	The Smoke War is over before any life here begins. Then:
	  The Age of L Corp        Lobotomy Corporation holds District 12 in the fallen Wing's place.
	  its last year            THE LIGHT. Three White Nights, then four Dark Days. It was meant to
	                           shine for seven. All anyone outside L Corp knows is that it failed.
	  The Age of the Library   a Library where L Corp stood. From here on a person at the brink
	                           hears a voice; they can Distort, or find E.G.O. Hana's rank for the
	                           Library climbs: Canard, Urban Myth, Urban Legend, Urban Plague,
	                           Urban Nightmare, Star of the City, Impurity.
	  After the Library        the Library is cast out. A second Light shines seven full days.
	                           Shin and Mang can be trained. Distortions never stopped.

	THE VOICE (pack.hooks.breakingPoint). When Sanity hits the floor after the Light, a woman speaks.
	The player sees her name; the person living the life never learns it. Follow her and you
	Distort (the life ends). Look at what she shows you and refuse her, with enough Mental
	Strength, and you manifest E.G.O. Look and fall short and you come back with a VOLATILE E.G.O:
	bright, cracked, and no protection at all the next time she speaks. You can also refuse to
	look: that costs you weeks of your life and gives you nothing, and it's always there.

	Every check against her is `fixed`: what you're up against is yourself, so it doesn't grow
	with your age or with how hard the City is (`lune run tests/odds mind` prints the table).
	Mental Strength comes in steps (a coin every 32, base every 22), so the odds do too:
	                                   at 55   65   75   90   97   100
	  looking alone (3/7/3)             0%    1%   3%  22%  52%  63%
	  with someone to hold (2/7/3)      1%    8%  17%  55%  83%  88%
	  the second time, alone (2/7/3)    1%    8%  17%  55%  83%  88%
	  the second time, held (2/6/3)     2%   18%  55%  56%  84%  97%
	E.G.O is for a strong mind (about 90). A middling one (about 75) can get there the long way,
	through a volatile E.G.O and a second coin-flip that ends it if it's lost. Most people can't,
	and what's left to them is to turn away.

	Lines given as lists are variants: each life is dealt one.
]]

local AFTER = { "library", "limbus" }
local CLOSE = { "child", "mother", "father", "sibling", "friend", "mentor" }

local EGO_WIN = {
	form = "ego",
	cutscene = { style = "ego", kicker = "You looked at all of it", title = "E.G.O", lines = { "You didn't look away.", "You didn't let go.", "What came out of you is yours." } },
	sanity = 60,
	mind = 4,
	removeTrait = "ego_volatile",
	setFlags = { "manifested_ego", "heard_the_voice" },
	codex = "terms_ego",
	chronicle = "manifested_ego",
	dialogue = {
		{ who = "carmen", line = { "...Oh. You'd rather carry it.", "You looked. Most people can't bear to look.", "So that's your answer. I didn't think you had it in you." } },
		{ who = "carmen", line = { "Then carry it well. I'll be listening.", "It's yours, then. All of it. Don't put it down again.", "I only ever wanted you to stop hiding. I suppose you have." } },
	},
	log = {
		"You looked at the whole of it, the thing your despair wanted to be, and you didn't let go and you didn't look away. It came out of you whole, and it's yours: E.G.O.",
		"She showed you everything you'd given up. You said: I know. And I'm still here. What you were holding when the room came back was made of all of it. E.G.O.",
	},
}

local VOLATILE = {
	addTrait = "ego_volatile",
	cutscene = { style = "ego", kicker = "You said no", title = "Volatile E.G.O", lines = { "But you flinched from the worst of it.", "What you're holding is bright, and cracked.", "It won't protect you the next time." } },
	sanity = 32,
	mind = 1,
	setFlags = { "heard_the_voice" },
	codex = "terms_volatile",
	chronicle = "volatile_ego",
	dialogue = {
		{ who = "carmen", line = { "You said no. But you couldn't look at all of it, could you?", "Half an answer. I'll take it, for now.", "You're holding it by the blade, you know." } },
		{ who = "carmen", line = { "I'll come back when you're tired.", "That won't hold. I'll be here when it doesn't.", "We'll talk again. We always do." } },
	},
	log = {
		"You refused her. But you flinched from the worst of what she showed you, and what came out of you is only half a thing: bright, and cracked down the middle. A volatile E.G.O. It won't protect you the next time.",
		"You said no and meant most of it. What you're holding burns and flickers and doesn't quite keep its shape. People who know call it a volatile E.G.O, and they say it the way you'd say a cracked beam.",
	},
}

local DISTORT = {
	form = "distorted",
	cutscene = { style = "distortion", kicker = "You took her hand", title = "Distortion", lines = { "It was such a relief.", "What stood up in your place has your voice.", "It has none of your reasons." } },
	die = "Became a Distortion",
	chronicle = "distorted",
	log = {
		"You took her hand. It was the kindest thing anyone had done for you in years. Somewhere in {district} a new Distortion is standing where you were, and someone is already calling the Fixers.",
		"You let go. It was such a relief. The thing that stood up in your place has your voice and none of your reasons, and the street around it has stopped making sense.",
	},
}

return {
	-- ════ THE LIGHT: L Corp's last year ════════════════════════════════════════
	{
		id = "era_white_nights",
		always = true,
		cutscene = { style = "light", kicker = "District 12", title = "The Light", lines = { "It rose from the L Corp tower at dawn.", "They say it was meant to shine for seven days.", "Tonight, there is no night." } },
		title = "The White Nights",
		art = "lcorp",
		text = {
			"A pillar of light comes up out of the L Corp tower in District 12 and doesn't stop. It spreads over every District, every Nest, every Backstreet. Night doesn't fall. For three days nobody you know of dies, and people walk outside at three in the morning without looking over their shoulders.",
			"It starts as a glow over District 12, where the Wing's tower is. By noon there's no shade anywhere in the City. By the hour the Sweepers should have come, the streets are full of people standing with their faces turned up. Nobody knows what it is. For three days, nothing bad happens to anyone.",
			"You can read by it at midnight. It comes from L Corp, everyone agrees, and nobody at L Corp is answering. For three days there is no dark in the City at all, and the strange part is how fast people stop being afraid.",
		},
		weight = 400,
		once = true,
		when = { world = { era = "white_nights" } },
		codex = "city_white_nights",
		choices = {
			{
				label = "Walk out into it",
				result = { sanity = { 6, 12 }, addTrait = "light_touched", setFlags = { "saw_white_nights" }, trigger = "era_dark_days", log = { "You stood in it with everyone else. It felt like being forgiven for something. You'll never describe it properly.", "You stood in the street with your eyes shut and it came through your eyelids anyway. For a while you weren't tired." } },
			},
			{
				label = "Lock the doors and watch through the shutters",
				result = { mind = 2, sanity = { -2, 2 }, setFlags = { "saw_white_nights" }, trigger = "era_dark_days", log = "Nothing that comes out of a Wing is free. You watched it through a gap in the shutters and waited for the price." },
			},
			{
				label = "Find the people you love",
				requires = { hasRelation = CLOSE },
				result = { sanity = { 4, 8 }, relationBond = { kind = "all", amount = 10 }, setFlags = { "saw_white_nights" }, trigger = "era_dark_days", log = "You crossed the District in the strange light to find them. Everyone you love was alive, and standing in a doorway looking up." },
			},
		},
	},
	{
		id = "era_dark_days",
		always = true,
		cutscene = { style = "dark", kicker = "The fourth morning", title = "The Dark Days", lines = { "The Light went out.", "Four days without a sun.", "Nobody outside the tower knows why it failed." } },
		title = "The Dark Days",
		art = "night",
		text = {
			"On the fourth morning the light goes out. Not dimmer: out, all at once, like a hand closing. No sun comes up behind it. For four days the City is dark at noon, the lamps won't hold, and everything the light had been keeping quiet comes back at once. Later, people will say it was meant to last seven days. Nobody will be able to say why it didn't.",
			"Three days of light. Then four of dark, the kind you can't see your hand in, at midday. Things come out of District 12. People do things they'd never have done a week ago. Whatever L Corp was trying to give the City, it gave less than half of it, and nobody outside that tower will ever be told what went wrong.",
		},
		weight = 0,
		once = true,
		when = { world = { era = "white_nights" } },
		choices = {
			{
				label = "Bar the door and keep everyone inside",
				clash = { stat = "mind", foe = "Four days of dark", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = -3, relationBond = { kind = "all", amount = 6 }, log = "Four days by one candle, rationed. You told every story you knew. When the sun came back, it came back ordinary, and nobody in your rooms was missing." },
				lose = { sanity = { -12, -8 }, health = { -8, -4 }, condition = "night_terrors", log = "On the third day somebody opened the door. You don't talk about the fourth." },
			},
			{
				label = "Go out and help whoever's still out there",
				clash = { stat = "strength", foe = "What came out in the dark", coins = 2, base = 5, coinPower = 3, fight = true },
				win = { strength = 2, sanity = -4, rep = { fixers = 8 }, log = "You brought nine people in off your street, one at a time, by feel. You never saw what was following the last one. You heard it." },
				lose = { health = { -18, -10 }, sanity = -8, condition = "night_terrors", cause = "Lost in the Dark Days", log = "You went out with a lamp. The lamp didn't last." },
			},
			{
				label = "Run for a Nest gate",
				requires = { side = "backstreets" },
				clash = { stat = "speed", foe = "The dark between here and the wall", coins = 2, base = 4, coinPower = 3 },
				win = { speed = 2, sanity = -5, log = "The gates were shut. But there was light on the other side of them, and you sat with your back against the wall for four days, in the last strip of it." },
				lose = { health = { -14, -8 }, sanity = -8, cause = "Lost in the Dark Days", log = "You never found the wall." },
			},
		},
	},
	{
		id = "era_lcorp_falls",
		always = true,
		title = "The Last Day at L Corp",
		art = "lcorp",
		text = "There is no L Corp anymore. The tower is dark, the facility is sealing itself floor by floor, and your badge doesn't open anything. Nobody above you is answering. Somewhere below, things that used to be contained are waking up, and the light that came out of this building has just gone out over the whole City.",
		weight = 500,
		once = true,
		when = { world = { era = "white_nights" }, career = { "lcorp_agent", "lcorp_research" } },
		codex = "lcorp_fall",
		choices = {
			{
				label = "Get everyone out you can",
				clash = { stat = "health", foe = "The collapse", coins = 2, base = 5, coinPower = 3 },
				win = { quitCareer = true, sanity = 4, addTrait = "manager_material", chronicle = "lcorp_evacuated", log = "You got a whole corridor of clerks out before the doors sealed. Some of them still send you something every year." },
				lose = { quitCareer = true, health = { -14, -6 }, sanity = -8, condition = "night_terrors", log = "You got some of them out. You think about the others.", cause = "Lost in the fall of L Corp" },
			},
			{
				label = "Take the research notes with you",
				requires = { career = "lcorp_research" },
				result = { quitCareer = true, money = { 200, 500 }, sanity = -4, setFlags = { "kept_lcorp_notes" }, codex = "lcorp_enkephalin", log = "You walked out with a bag of observation logs. Someone, someday, will pay a lot for them. Someone else will want them burned." },
			},
			{
				label = "Leave and never look back",
				result = { quitCareer = true, sanity = -2, log = "You walked out of District 12 and didn't turn around when the ground shook." },
			},
		},
	},

	-- ════ THE AGE OF THE LIBRARY ═══════════════════════════════════════════════
	{
		id = "era_library",
		always = true,
		cutscene = { style = "age", kicker = "A new age", title = "The Library", lines = { "Where L Corp stood, there is a tower nobody built.", "It sends invitations.", "And people at the brink have started hearing a voice." } },
		title = "A Tower Where the Light Began",
		art = "library",
		text = {
			"Where L Corp's headquarters stood, there is a tower now. People are calling it a Library. They say it sends invitations, that a guest who wins inside leaves with any book they want, and that a guest who loses becomes one. Hana has filed it as a Canard: a rumor, not worth a Fixer's fee.",
			"District 12 has no Wing. What it has, in the hole where the L Corp tower was, is a Library nobody built. Invitations have started turning up under doors. The Associations' word for it, this year, is Canard: a story people tell. The people who accepted the invitations haven't come back to say otherwise.",
		},
		weight = 300,
		once = true,
		when = { world = { era = "library" }, minAge = 8 },
		codex = "library_tower",
		choices = {
			{ label = "Ask someone who has seen it", result = { sanity = -2, mind = 2, setFlags = { "saw_the_library" }, log = "A carter who works the District 12 road says you can see it from the last checkpoint on a clear day: a tower with no lit windows, in the hole where the Wing was. \"It looks back,\" he said. \"A little.\"" } },
			{ label = "Ask what happened to L Corp", result = { intelligence = 1, codex = "city_dark_days", log = "Nobody knows. That's the true answer and everybody gives it. The Wing lit up the City for three days, the light failed, and then there was no Wing." } },
			{ label = "Stay well away", result = { sanity = 2, log = "You stayed in your District. A sensible choice, which you made again every day after." } },
		},
	},
	{
		id = "era_first_distortion",
		always = true,
		title = "A New Word",
		art = "distortion",
		text = {
			"A man two streets over lost his shop, then his brother, then a week of sleep. On Tuesday there was something in his rooms that wasn't him, and the street outside had gone wrong: doors opening onto the same stairwell, a smell of ledger ink. The Fixers who dealt with it had a word ready. Distortion.",
			"It happens to a seamstress in your District first. She'd been at the end of her rope for a year. People heard her talking to someone in an empty room, gently, the way you talk to a friend. Then what came down her stairs had too many hands and all of them were sewing. The Fixers call it a Distortion. They say it's been happening since the Light.",
		},
		weight = 300,
		once = true,
		when = { world = { era = AFTER }, minAge = 10 },
		codex = "terms_distortion",
		choices = {
			{ label = "Ask the Fixers what causes it", result = { intelligence = 2, setFlags = { "knows_distortions" }, codex = "terms_voice", log = "Nobody's sure. People pushed too far, one of them said. They hear something first. A voice. It's kind to them. If you ever hear it, he said, say no and keep saying it." } },
			{ label = "Ask if anyone ever comes back from it", result = { mind = 2, setFlags = { "knows_distortions" }, codex = "terms_ego", log = "Once in a while, she said. Someone goes right to the edge and comes back holding something instead. A coat, a blade, a light. They call that E.G.O. She'd seen it once. She didn't say it like good news." } },
			{ label = "Go home and check on everyone you know", requires = { hasRelation = CLOSE }, result = { sanity = 2, relationBond = { kind = "all", amount = 6 }, setFlags = { "knows_distortions" }, log = "Everyone was fine. You asked each of them twice, and how they were sleeping." } },
		},
	},
	{
		id = "lib_rank_plague",
		always = true,
		title = "Urban Plague",
		art = "library",
		text = {
			"The news goes round every Office in a day: Hana has raised the Library to Urban Plague. Three years ago it was a rumor. Whole Offices have gone in since, then a Section of an Association, and none of them came back out. The invitations keep arriving.",
			"Urban Plague. Hana doesn't give that grade to stories. An Association has lost a whole Section to the Library, the papers say, and the advice from now on is simple: if an invitation comes, don't sign it.",
		},
		weight = 300,
		once = true,
		when = { world = { library = "plague", era = "library" }, minAge = 12 },
		codex = "library_ranks",
		choices = {
			{ label = "Ask a Fixer how the ranks work", result = { intelligence = 2, setFlags = { "knows_fixers" }, log = "Canard, Urban Myth, Urban Legend, Urban Plague, Urban Nightmare, Star of the City. It's how Hana prices a threat, she said. The Library has gone up four of them in the time it takes to train an apprentice." } },
			{ label = "Decide you'd never sign one", result = { mind = 2, sanity = 1, log = "It asks what you want most and promises you a book about it. You practised saying no to that in the mirror." } },
			{ label = "Wonder what book you'd ask for", result = { sanity = -2, setFlags = { "lib_tempted" }, log = "You knew the answer straight away. That was the part that bothered you." } },
		},
	},
	{
		id = "lib_rank_star",
		always = true,
		title = "Star of the City",
		art = "library",
		text = {
			"There is no grade above this one. Hana has named the Library a Star of the City. The Fingers have sent their own people in, and lost them. They say a Color accepted an invitation this winter, and the City is waiting to hear how that ended.",
			"Star of the City: the top of Hana's scale, the grade for things that can end a District. That's the Library now. The Thumb sent a Capo. The Index sent Proxies. Somebody says even a Color went in. None of it has slowed the invitations.",
		},
		weight = 300,
		once = true,
		when = { world = { library = "star", era = "library" }, minAge = 12 },
		codex = "library_ranks",
		choices = {
			{ label = "Listen to what people say about it", result = { charisma = 1, intelligence = 1, log = "Every stall has a theory. The one you believe is the old woman's: it isn't killing them, she said. It's keeping them." } },
			{ label = "Watch District 12 from a rooftop", result = { mind = 2, sanity = -3, setFlags = { "saw_the_library" }, log = "There's a light in it, high up. Not a lamp. The same color as the one that covered the City once." } },
			{ label = "Keep your head down", result = { sanity = 2, log = "Stars of the City happen to other people. You made sure of it." } },
		},
	},
	{
		id = "lib_rank_impurity",
		always = true,
		title = "Impurity",
		art = "library",
		text = "The word comes down from somewhere above Hana, above the Wings, from the Head itself: the Library is an Impurity. There's no grade for that. It isn't a measure of danger. It means the City has decided the thing must not exist. People stop saying the Library's name out loud.",
		weight = 300,
		once = true,
		when = { world = { library = "impurity", era = "library" }, minAge = 12 },
		codex = "library_ranks",
		choices = {
			{ label = "Ask what the Head does to an Impurity", result = { intelligence = 2, sanity = -3, log = "Nobody answered. The man you asked looked at the sky, and then moved his stall to another street." } },
			{ label = "Stay out of District 12 until it's over", result = { sanity = 2, mind = 1, log = "Whatever is coming for that tower, you won't be standing next to it." } },
		},
	},

	-- ════ AFTER THE LIBRARY ════════════════════════════════════════════════════
	{
		id = "era_library_gone",
		always = true,
		cutscene = { style = "light", kicker = "Where the Library stood", title = "The Second Light", lines = { "The Library is gone, cast out past the wall.", "A Light rises again.", "This time it shines all seven days." } },
		title = "The Second Light",
		art = "ruins",
		text = {
			"The Library is gone. Cast out past the wall, people say, by the Head's own hand. On its last day a light came up from where it stood, the same light as before, and everybody over twenty went white and started counting. One day. Three. Four. It didn't go out. Seven full days this time, and then it faded like an ordinary evening.",
			"This time it lasted. The tower in District 12 is gone, thrown out into the Outskirts with everything in it, and on the day it went the Light rose again. People who remembered the first one stood at their windows waiting for the dark. It never came. Seven days, the whole seven, and on the eighth the sun rose as if nothing had happened.",
		},
		weight = 400,
		once = true,
		when = { world = { era = "limbus" }, minAge = 4 },
		codex = "city_second_light",
		choices = {
			{ label = "Stand in it, all seven days", result = { sanity = { 8, 14 }, mind = 2, setFlags = { "saw_second_light" }, trigger = "era_after", log = "It wasn't like the stories of the first one. It didn't feel like being forgiven. It felt like being handed something heavy and told it was yours." } },
			{ label = "Count the days from behind a door", result = { mind = 3, setFlags = { "saw_second_light" }, trigger = "era_after", log = "You counted every one. On the fourth night you didn't sleep at all. On the eighth morning you opened the door." } },
			{ label = "Hold on to someone", requires = { hasRelation = CLOSE }, result = { sanity = { 6, 10 }, relationBond = { kind = "all", amount = 10 }, setFlags = { "saw_second_light" }, trigger = "era_after", log = "You sat it out together. Nobody said much. It was the first whole week any of you could remember without being afraid." } },
		},
	},
	{
		id = "era_after",
		always = true,
		title = "What the Light Left",
		art = "street",
		text = {
			"People hoped the Distortions would stop when the second Light finished. They didn't. Something else started instead. Here and there, someone who has spent years holding their own heart steady finds they can do things with it: a blow that lands twice as hard, a ring of something burning behind them when they move. The old schools have names for it already. Shin. Mang.",
			"The Distortions go on. The second Light changed something else. A dockhand in District 21 who'd trained his temper for twenty years put a hook through a ship's plate last week, and people swear there was a ring of fire at his back when he did it. Shin, the fencing schools call the stillness. Mang, the ring. They say it can be learned.",
		},
		weight = 0,
		once = true,
		when = { world = { era = "limbus" } },
		codex = "terms_shin",
		choices = {
			{ label = "Ask who teaches it", result = { intelligence = 1, setFlags = { "knows_shin" }, log = "Nobody teaches it quickly. It isn't like E.G.O, which comes all at once at the worst moment of your life. This takes years of a quiet heart. You can start any time. Most people stop." } },
			{ label = "Ask what it costs", result = { mind = 1, setFlags = { "knows_shin" }, log = "Every ring you shape is something you want, or resent, or grieve, held perfectly still. One is a strain. Two is nearly twice that. The people with three don't talk much." } },
			{ label = "Ask about the bus", result = { charisma = 1, setFlags = { "knows_shin", "knows_limbus" }, log = "A company called Limbus, the stallholder said. A dozen of them on a bus, going wherever L Corp's old branches are buried. Looking for something gold. He didn't know more, and didn't want to." } },
		},
	},

	-- ════ THE VOICE ════════════════════════════════════════════════════════════
	-- a Bloodfiend doesn't Distort: at the edge it loses itself to the Thirst
	{
		id = "core_breaking_point_thirst",
		title = "The Thirst",
		art = "theater",
		text = "It all comes down at once, and under it is the Thirst, which has been patient with you. A Bloodfiend at the edge doesn't hear a voice. It only gets hungry.",
		weight = 0,
		when = { form = "bloodfiend" },
		choices = {
			{
				label = "Hold on to who you were",
				hint = "A Mental Strength check. Your coins flip fair here.",
				clash = { stat = "mind", foe = "The Thirst", coins = 2, base = 3, coinPower = 3, ignoreSanity = true, fixed = true },
				win = { sanity = 55, mind = 4, log = "You held on to your name, your street, the people who knew you before. The Thirst backed down, for now." },
				lose = { die = "Lost to the Thirst", chronicle = "bf_lost", log = "The Thirst won. What walked out of your door that night wasn't you anymore, and the Fixers who came for it didn't know your name." },
			},
			{
				label = "Drink the Hemobar you kept for this",
				hint = "150 Ahn's worth of the good ones.",
				requires = { min = { money = 150 } },
				result = { money = -150, sanity = 50, log = "You kept one sealed box at the back of the cupboard for exactly this night. It was enough. Barely." },
			},
		},
	},
	-- someone who has already manifested E.G.O has answered her once: it holds
	{
		id = "ego_holds",
		title = "She Tries Again",
		art = "home",
		text = {
			"Everything comes down on you at once, the way it did before. And there she is, as gentle as ever. But you've seen all of what she has to show you. You're holding it.",
			"The floor goes out from under you again. You know this place. You know the voice that's about to speak, and you know what you said to it last time.",
		},
		dialogue = { { who = "carmen", line = { "You look so tired. You could put it down, you know.", "Still carrying it? It must be so heavy by now." } } },
		weight = 0,
		when = { form = "ego" },
		choices = {
			{ label = "Tell her you already answered", result = { sanity = 40, mind = 1, log = "E.G.O is the answer, and it doesn't need giving twice. She laughed, not unkindly, and the room came back." } },
			{
				label = "Ask her why she does this",
				result = {
					sanity = 34,
					intelligence = 1,
					setFlags = { "asked_the_voice" },
					dialogue = { { who = "carmen", line = "Because everyone here is in pain, and almost nobody will look at it. I wanted to give them a way to stop pretending. I still do." } },
					log = "You believed her. That was the frightening part. You said no anyway, and she let you go.",
				},
			},
		},
	},
	-- a volatile E.G.O is no protection: this is the second time, and it's worse
	{
		id = "carmen_returns",
		title = "She Comes Back",
		art = "home",
		text = {
			"The cracked thing you've been carrying gutters like a lamp in wind. You knew this was coming. The woman's voice at the brink told you it would.",
			"It was never whole, the thing you came back with. Tonight it's coming apart in your hands, and the woman's voice from the brink is speaking before the pieces have stopped moving.",
		},
		dialogue = {
			{ who = "carmen", line = { "I said I'd come back when you were tired.", "There you are. It didn't hold, did it? I'm sorry. I did tell you." } },
			{ who = "carmen", line = { "You only looked at half of it. Let me show you the rest.", "Let it finish. You've held half of it for so long. Doesn't it hurt?" } },
		},
		weight = 0,
		when = { trait = "ego_volatile", world = { era = AFTER } },
		choices = {
			{
				label = "Look at the rest of it",
				hint = "A hard Mental Strength check. Fail, and there's no third time.",
				clash = { stat = "mind", foe = "The half you wouldn't look at", coins = 2, base = 7, coinPower = 3, ignoreSanity = true, fixed = true },
				win = EGO_WIN,
				lose = DISTORT,
			},
			{
				label = "Hold on to someone, and look",
				hint = "Easier, with a face to hold on to.",
				requires = { hasRelation = CLOSE },
				clash = { stat = "mind", foe = "The half you wouldn't look at", coins = 2, base = 6, coinPower = 3, ignoreSanity = true, fixed = true },
				win = EGO_WIN,
				lose = DISTORT,
			},
			{
				label = "Let it go out",
				hint = "You lose the volatile E.G.O, and you stay yourself.",
				result = {
					removeTrait = "ego_volatile",
					sanity = 30,
					mind = -2,
					health = { -6, -3 },
					setFlags = { "let_it_go_out" },
					chronicle = "let_it_go_out",
					dialogue = { { who = "carmen", line = { "Oh. You'd rather have nothing than half? ...All right.", "You're putting it down. That isn't what I meant, you know." } } },
					log = {
						"You opened your hands. The cracked light guttered and went out, and it took something of you with it. You're only yourself again: tired, smaller, and alive.",
						"You let it go before it could finish coming apart. The room was just a room. You sat on the floor until morning, with nothing in your hands at all.",
					},
				},
			},
			{ label = "Let her finish it", hint = "This is how people Distort.", result = DISTORT },
		},
	},
	{
		id = "core_breaking_point",
		cutscene = { style = "voice", kicker = "The brink", title = "", lines = { "The room goes quiet, the way rooms don't.", "Someone is speaking. Close, and warm.", "Nobody else is here." } },
		title = "The Brink",
		art = "home",
		text = {
			"It all comes down on you at once, every year of it. The room goes quiet in a way rooms don't. Then someone is speaking, close and warm, as if she'd been sitting beside you the whole time.",
			"You've run out. There's nothing left to hold yourself up with, and you can feel the shape your despair wants to take, and it isn't human. That's when you hear her. A woman's voice, kind, and not coming from anywhere.",
			"Your hands won't stop. The walls are too close and the City outside them is too big, and you are so tired of pretending it's fine. A voice says your name. Nobody else is in the room.",
		},
		dialogue = {
			{ who = "carmen", line = { "There you are. You've carried that for such a long time.", "Shh. It's all right. You don't have to hold it together for me.", "I've been listening. You're hurting so much, and nobody's noticed." } },
			{ who = "carmen", line = { "You don't have to keep pretending it doesn't hurt.", "What if you stopped hiding it? Just once. Just with me.", "Let me help you. I only want you to be what you really are." } },
		},
		weight = 0,
		when = { world = { era = AFTER }, form = { "human" } },
		codex = "terms_voice",
		choices = {
			{
				label = "Ask who she is",
				result = {
					mind = 1,
					setFlags = { "heard_the_voice", "asked_the_voice" },
					trigger = "carmen_offer",
					dialogue = {
						{ who = "carmen", line = { "Someone who wanted people to stop hiding from themselves. That's all I ever wanted.", "A doctor, once. I tried to cure a sickness everyone here has. I'm still trying." } },
						{ who = "carmen", line = "It doesn't matter who I was. You matter. Tell me what you gave up." },
					},
					log = "She answered you. She sounded glad you'd asked. Nobody had asked you anything in a long time, either.",
				},
			},
			{ label = "Listen", result = { setFlags = { "heard_the_voice" }, trigger = "carmen_offer", log = "You stopped fighting it and listened. It was a relief just to be spoken to like that." } },
			{
				label = "Don't answer. Hold on to something real.",
				hint = "A Mental Strength check. Fail, and you'll hear her out.",
				clash = { stat = "mind", foe = "A kind voice", coins = 1, base = 3, coinPower = 3, ignoreSanity = true, fixed = true },
				win = { sanity = 45, mind = 3, setFlags = { "heard_the_voice", "refused_the_voice" }, chronicle = "refused_the_voice", log = { "You counted the floorboards. You said your own name out loud, and your street, and what you had for breakfast. The voice waited, and then it wasn't there. You came back with nothing at all, and you were glad of it.", "You put your hands flat on the table and felt the grain. A real table. A real room. She sighed, fondly, and let you go." } },
				lose = { sanity = -1, setFlags = { "heard_the_voice" }, trigger = "carmen_offer", log = "You tried to think of anything else. She waited until you couldn't." },
			},
		},
	},
	{
		id = "carmen_offer",
		title = "What She Offers",
		art = "home",
		text = {
			"The woman's voice, the one people hear at the bottom of themselves, knows exactly what you gave up to get this far. She says it out loud, gently, the thing you never told anyone. Then she tells you that you can have it back. All you have to do is stop holding yourself in.",
			"The woman's voice, the one people hear at the bottom of themselves, shows you. Not with words: you can see it, the shape you'd be if you let go, and it's big, and it isn't afraid of anything, and nobody will ever make it small. It would be so easy. She's holding out a hand you can't see.",
		},
		dialogue = {
			{ who = "carmen", line = { "Let it out. Be what you already are, under all of it. I'll help you.", "You've been so good for so long, and what did it get you? Put it down.", "Nobody will ever hurt you like that again. I promise. Just take my hand." } },
		},
		weight = 0,
		when = { world = { era = AFTER }, form = { "human" } },
		choices = {
			{ label = "Take her hand", hint = "This is how people Distort.", result = DISTORT },
			{
				label = "Look at what she's showing you, and say no",
				hint = "A Mental Strength check. Your coins flip fair here. Win: E.G.O. Lose: you hold on, but only to half of it.",
				clash = { stat = "mind", foe = "Your own distortion", coins = 3, base = 7, coinPower = 3, ignoreSanity = true, fixed = true },
				win = EGO_WIN,
				lose = VOLATILE,
			},
			{
				label = "Say no for the people who need you",
				hint = "Easier, if there's still someone to hold on to.",
				requires = { hasRelation = CLOSE },
				clash = { stat = "mind", foe = "Your own distortion", coins = 2, base = 7, coinPower = 3, ignoreSanity = true, fixed = true },
				win = EGO_WIN,
				lose = VOLATILE,
			},
			{
				label = "Turn away. You don't have to look.",
				hint = "No check. You keep yourself, and it costs you.",
				result = {
					sanity = 30,
					health = { -8, -4 },
					condition = "night_terrors",
					setFlags = { "heard_the_voice", "refused_the_voice" },
					chronicle = "refused_the_voice",
					dialogue = { { who = "carmen", line = { "You won't even look? ...That's all right. I'll be here.", "Still hiding. I understand. It's what everyone here does." } } },
					log = {
						"You shut your eyes and said no to all of it, the offer and the thing she was showing you both. It took weeks to come back from. You came back with nothing, and as yourself.",
						"You wouldn't look. You held on to the edge of the table and the sound of the street until she stopped talking. You lost most of a month to it. You didn't lose yourself.",
					},
				},
			},
		},
	},

	-- ════ SHIN AND MANG: only after the second Light ═══════════════════════════
	{
		id = "shin_first_ring",
		title = "A Ring of Wanting",
		art = "rooftop",
		text = {
			"You've held your heart still for long enough that tonight, when you think of the thing you want most and don't flinch from it, something answers. A ring, behind your shoulder, like a coal seen through smoke.",
			"It comes while you're breathing the way you've practised a thousand times. A thin burning circle at your back, the color of whatever you've been carrying longest. Mang. It hums with everything you resent.",
		},
		weight = 0,
		once = true,
		when = { trait = "shin", world = { era = "limbus" } },
		codex = "terms_shin",
		choices = {
			{ label = "Hold it steady", hint = "A Mental Strength check", clash = { stat = "mind", foe = "A ring of your own wanting", coins = 2, base = 4, coinPower = 3, fixed = true }, win = { addTrait = "mang_one", mind = 2, log = "It stayed. One ring. Every blow you throw now has what you want behind it. It also never quite stops humming." }, lose = { sanity = -8, schedule = { event = "shin_first_ring", inYears = 2 }, log = "It went out, and took the evening's calm with it. You'll need more stillness before it comes again." } },
			{ label = "Let it go. One heart is enough.", result = { sanity = 4, mind = 1, log = "You breathed out and it faded. Shin alone is more than most people ever have." } },
		},
	},
}
