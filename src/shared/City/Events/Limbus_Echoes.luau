--[[
	Echoes: how one player's deed in the Distortion era reaches other lives on the server.
	Writer D (lim_ ids). Each fires for OTHER players after someone records the act
	(when = { chronicle = "act" }); {actor} and {actorDistrict} name who and where.
	Acts: Chronicle/Limbus.luau (lim_*) and Chronicle/Core.luau (calmed_distortion,
	fought_distortion, distorted, manifested_ego).
]]

local ERA = { era = "limbus" }

return {
	-- ── core acts ──
	{
		id = "lim_echo_calmed",
		title = "The Listening Circle",
		text = "{actor} talked a Distortion down in {actorDistrict}, and since then the people who saw it meet once a week in the back of a noodle shop to talk about their feelings before the feelings get too big. Somebody has started a circle on your street too. There's tea, and nobody is allowed to interrupt.",
		weight = 14,
		once = true,
		tags = { "distortion" },
		when = { chronicle = "calmed_distortion", world = { era = { "library", "limbus" } }, minAge = 12 },
		codex = "terms_distortion",
		choices = {
			{
				label = "Go every week",
				result = { sanity = 6, cure = "distortion_signs", log = "You went every week for a year. Mostly you listened. Once you talked, for twenty minutes, about something you'd never told anyone, and afterward your shadow kept up with you better." },
			},
			{
				label = "Run the tea urn",
				result = { intelligence = 2, sanity = 3, addRelation = { kind = "friend", name = "Talia Szabo", bond = 50 }, log = "You ran the tea urn, which meant you heard everything and had to say nothing. Talia Szabo, who started the circle, said you were the best tea person they'd ever had. You became friends over the washing up." },
			},
			{
				label = "Roll your eyes at it",
				result = { strength = 1, sanity = -2, log = "You rolled your eyes at the whole thing. Then one bad night you went, and sat at the back, and didn't say a word, and felt better. You still roll your eyes, in public." },
			},
		},
	},
	{
		id = "lim_echo_fought",
		title = "The Street {actor} Held",
		text = "Everyone has heard how {actor} held a Distortion off in {actorDistrict} until the Fixers came. Now every Fixer office in the City wants locals who'll do the same: hold, delay, shout for help. A Rep is going door to door on your street with a clipboard and a bag of whistles.",
		weight = 12,
		once = true,
		tags = { "distortion" },
		when = { chronicle = "fought_distortion", world = { era = { "library", "limbus" } }, minAge = 16 },
		choices = {
			{
				label = "Sign up as a street warden",
				result = { wage = { 30, 70 }, strength = 2, setFlags = { "lim_street_warden" }, log = "You took a whistle and a laminated card with the Office's number. On the card, under WHAT TO DO, it says: hold, delay, shout. Under that, someone has written in pen: \"and run, mostly.\"" },
			},
			{
				label = "Buy a better lock instead",
				result = { money = -30, sanity = 3, log = "You bought the best lock on the street, then a second one. You sleep better. You hope you never have to find out if that's foolish." },
			},
			{
				label = "Ask the Rep what happened to the last wardens",
				result = { mind = 2, sanity = -2, log = "She told you the truth, which you respected, and then she told you the numbers, which you didn't like. She left you a whistle anyway. \"For your own street,\" she said." },
			},
		},
	},
	{
		id = "lim_echo_distorted",
		title = "What {actor} Became",
		text = "The news from {actorDistrict}: {actor} went over the edge, and now there's a Distortion where they were. Fixers have closed off three streets. People who knew them keep telling stories about them in the past tense, and then stopping, because nobody is sure that's right yet.",
		weight = 12,
		cooldown = 15,
		tags = { "distortion" },
		when = { world = { era = { "library", "limbus" } }, chronicle = "distorted", minAge = 12 },
		codex = "terms_distortion",
		choices = {
			{
				label = "Leave a lamp lit in your window for them",
				result = { sanity = 2, mind = 1, log = "You lit a lamp in the window for {actor}, like the old Backstreets custom for someone lost to the Night. Across the street, someone else did the same. By midnight half the street had." },
			},
			{
				label = "Check on the people closest to you",
				result = { sanity = 1, relationBond = { kind = "all", amount = 6 }, log = "If it could happen to {actor}, it could happen to anyone. You spent the week calling, visiting, asking how people really were. Some of the answers worried you. All of them mattered." },
			},
			{
				label = "Help the Fixers clear the streets",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "Three streets of panic", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 30, 90 }, strength = 2, log = "You knocked on doors ahead of the Fixers and got people out before the cordon closed. A Fixer gave you a share of the contract fee and told you that {actor} hadn't hurt anyone who'd left." },
				lose = { health = -5, sanity = -4, log = "You got too close. You didn't see it, only felt it, like the street tilting. A Fixer dragged you back behind the cordon by your collar." },
			},
		},
	},
	{
		id = "lim_echo_ego",
		title = "It Can Be Done",
		text = "Word is all over the City: {actor}, in {actorDistrict}, reached the very edge, looked their own Distortion in the eye, and came back holding E.G.O. People are queuing outside their door. Not for autographs. They want to know how.",
		weight = 12,
		cooldown = 15,
		when = { world = { era = { "library", "limbus" } }, chronicle = "manifested_ego", minAge = 12 },
		codex = "terms_ego",
		choices = {
			{
				label = "Take hope from it",
				result = { sanity = 6, log = "You didn't need to meet {actor}. Just knowing it could be done made the edge feel less like an ending. You told everyone you love the story, and watched it land." },
			},
			{
				label = "Write down what people say they said",
				result = { mind = 3, log = "You filled a notebook with what people swore {actor} had told them: look at it, don't look away, hold on to someone. Most of it contradicts the rest. All of it sounds true." },
			},
			{
				label = "Join the queue and ask them yourself",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A queue around the block", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 4, cure = "distortion_signs", log = "You got two minutes with {actor}. They said: \"It wants you to look away. Don't.\" You thought about that every bad night after, and it helped every time." },
				lose = { sanity = -1, log = "The queue went round three blocks. By the time you reached the door, {actor} had gone to bed. You went home with nothing but the waiting, which taught you something too." },
			},
		},
	},

	-- ── my acts ──
	{
		id = "lim_echo_talked_down",
		title = "People Like {actor}",
		text = "After {actor} talked a Distortion back from the edge in {actorDistrict}, the LCD put posters up all over the City: WE NEED LISTENERS. The OSIR Team is hiring investigators who can find an Inflection Point before it's too late. The poster has a phone number, and a quote from {actor}.",
		weight = 14,
		once = true,
		tags = { "limbus", "distortion" },
		when = { chronicle = "lim_talked_down", world = ERA, minAge = 12 },
		codex = "lim_inflection_point",
		choices = {
			{
				label = "Apply to the LCD",
				hint = "Join Limbus Company's Distortion department.",
				requires = { minAge = 18, min = { mind = 35 } },
				result = { career = "lim_lcd", sanity = 2, log = "You called the number. Two weeks later you had a grey coat, a notebook and a desk on Line Four. The poster's quote is pinned above it: \"I just listened.\"" },
			},
			{
				label = "Learn the early signs",
				result = { mind = 2, codex = "lim_distortion_stages", log = "You learned the stages from the back of the poster: bad sleep, a late shadow, things that rearrange. You started noticing them everywhere, which was frightening, and useful." },
			},
			{
				label = "Call someone you've been worried about",
				result = { sanity = 3, relationBond = { kind = "all", amount = 5 }, log = "You called someone you'd been worried about for months. You didn't fix anything. You listened. At the end they said, \"Thanks for calling,\" in a voice that meant more than that." },
			},
		},
	},
	{
		id = "lim_echo_bough",
		title = "Dig Fever",
		text = "{actor} found a Golden Bough under {actorDistrict}, and now everyone with a shovel thinks they're next. Picks and lamps cost three times what they did, people are digging up their own cellars, and LCCB scouts go from site to site telling everyone to stop.",
		weight = 14,
		once = true,
		tags = { "limbus", "bough" },
		when = { chronicle = "lim_bough_found", world = ERA, minAge = 14 },
		codex = "lim_golden_boughs",
		choices = {
			{
				label = "Sell your tools to the diggers",
				result = { wage = { 40, 100 }, log = "You sold an old shovel, a lamp and a crowbar for more than you paid for your bed. You felt a bit bad. Not that bad." },
			},
			{
				label = "Dig up your own cellar",
				hint = "Health check.",
				clash = { stat = "health", foe = "Your own cellar floor", coins = 2, base = 5, coinPower = 3 },
				win = { money = { 30, 80 }, health = -2, log = "Three days of digging found no Bough, but it did find a crate of old L Corp parts that a Workshop bought off you. Your landlord is still angry about the floor." },
				lose = { health = { -7, -3 }, sanity = -2, log = "The floor gave way into the cellar below, which belonged to someone else. They were not pleased. Neither was your back." },
			},
			{
				label = "Help the scouts calm the diggers down",
				result = { mind = 2, setFlags = { "lim_lccb_contact" }, schedule = { event = "lim_lccb_offer", inYears = 1 }, log = "You walked with the LCCB scouts from cellar to cellar, telling people the Boughs are deep and the floors are thin. One of the scouts took your name for the Before Team's list." },
			},
		},
	},
	{
		id = "lim_echo_peccatula",
		title = "The Lot Is a Market Again",
		text = "Since {actor} cleared a nest of Peccatula out of an empty lot in {actorDistrict}, the idea has caught on: neighbors with shovels on a Saturday morning, and a market on the cleared ground by evening. Your street has an overgrown lot of its own, and the branches in it have started to glow.",
		weight = 12,
		once = true,
		tags = { "limbus", "distortion" },
		when = { chronicle = "lim_peccatula_cleared", world = ERA, minAge = 12 },
		codex = "lim_peccatula",
		choices = {
			{
				label = "Organize a clearing",
				hint = "A fight. They're only Class 1.",
				clash = { stat = "health", foe = "Peccatula Morositatis, Class 1", coins = 2, base = 4, coinPower = 3, fight = true, status = "sinking" },
				win = { sanity = 3, wage = { 20, 60 }, chronicle = "lim_peccatula_cleared", log = "Twelve neighbors, six shovels, one very long Saturday. The blue cracks went dark by noon. By evening there were three stalls and a man selling skewers, and somebody's grandmother cried." },
				lose = { health = { -8, -3 }, sanity = -3, log = "The branches were heavier than they looked and much sadder to be near. You called the LCE in the end, and they cleared it with tongs and pity." },
			},
			{
				label = "Run a stall at the new market",
				result = { wage = { 20, 60 }, sanity = 2, log = "Somebody else cleared the lot and you sold noodles on it. It counts. Everyone was hungry after the clearing." },
			},
			{
				label = "Call the LCE",
				result = { wage = { 10, 30 }, codex = "lim_peccatula", log = "The LCE paid you a small bounty and took the branches away in a van marked SAMPLES. The lot stayed empty, which is better than glowing." },
			},
		},
	},
	{
		id = "lim_echo_lccb_manager",
		title = "{actor} Is Hiring",
		text = "{actor} made Manager in Limbus Company's Before Team, and their recruiters are in your District: PRELIMINARY OBSERVATION. LOW PAY. HIGH RISK. A MANAGER WHO WAS ONE OF YOU. It's the most honest recruiting poster you've ever seen.",
		weight = 12,
		once = true,
		tags = { "limbus" },
		when = { chronicle = "lim_lccb_manager", world = ERA, minAge = 16 },
		codex = "lim_departments",
		choices = {
			{
				label = "Sign up",
				hint = "Join Limbus Company's Before Team.",
				requires = { minAge = 18, min = { health = 30, mind = 25 } },
				result = { career = "limbus_lccb", log = "You signed up. The recruiter shook your hand and said {actor} reads every application personally, and prefers the honest ones." },
			},
			{
				label = "Ask about the casualty rate",
				result = { mind = 2, log = "The recruiter told you the casualty rate, exactly, without blinking. \"The Manager says you deserve to know.\" You went home and thought about it for a long time." },
			},
			{
				label = "Tell them it's a terrible pitch",
				result = { sanity = 2, log = "\"It's working, though,\" the recruiter said, pointing at the queue. It was." },
			},
		},
	},
}
