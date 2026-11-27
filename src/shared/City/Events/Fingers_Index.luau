--[[
	The Index: Prescripts on paper slips (and, for senior members, on a device), Proselytes
	training under Proxies, Messengers. Canon: docs/CANON.md 3.2 and 12.2 (Prescripts here are
	odd, harmless or ambiguous, never orders to hurt anyone).
	Flag fn_index_proxy (shared hook) is set on joining the Index (rankFlags[1]).
]]

return {
	-- ── anyone ──
	{
		id = "fn_index_kid_slip",
		title = "A Slip for a Kid",
		text = "On the way home from school, a stranger in a plain coat hands you a folded slip of paper and walks off without a word. The handwriting is very neat. \"At 4:12, give your lunch to the first dog you see. Then go home by the long road.\" You've heard of the Index and its Prescripts. You didn't know they gave them to kids.",
		weight = 12,
		once = true,
		tags = { "fingers" },
		when = { minAge = 8, maxAge = 15 },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Do exactly what it says",
				result = { sanity = 3, mind = 2, setFlags = { "fn_kid_prescript" }, chronicle = "fn_prescript_done", log = "At 4:12 a skinny dog trotted up to exactly where you stood. You gave it your lunch and took the long road home. On the short road, you heard later, the old stairs gave way at 4:20." },
			},
			{
				label = "Throw the slip away",
				result = { sanity = -2, log = "You dropped it in a gutter. All the way home you felt like someone was disappointed in you, specifically." },
			},
			{
				label = "Show it to a grown-up",
				result = { intelligence = 1, log = "The grown-up went pale, took the slip, and burned it in the stove. \"Never pick those up,\" they said, and wouldn't say why." },
			},
		},
	},
	{
		id = "fn_index_follower",
		title = "Your Name on a Slip",
		text = "For a week now, the same young woman in a plain coat has been somewhere on your street every time you look up. Today she leans an umbrella against your door just before it starts to rain. A slip of paper is tucked into the handle. It isn't for you, but it's about you: \"Follow them for one year. Keep them dry.\"",
		weight = 8,
		once = true,
		tags = { "fingers", "strange" },
		when = { minAge = 18, notFlags = { "fn_index_proxy" } },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Let her follow you",
				result = { sanity = 3, setFlags = { "fn_index_followed" }, schedule = { event = "fn_index_follower_end", inYears = 1 }, log = "You let her follow you. You weren't caught in the rain once that year. It was the strangest kindness of your life." },
			},
			{
				label = "Confront her",
				clash = { stat = "mind", foe = "A Proselyte's faith", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, setFlags = { "fn_index_followed" }, schedule = { event = "fn_index_follower_end", inYears = 1 }, log = "She said she didn't know why, and didn't need to. \"The Prescript knows,\" she said. Then she went back to following you, a little closer." },
				lose = { sanity = -3, log = "She wouldn't speak. She just looked at you, patiently, until you went back inside. In the morning she was gone." },
			},
			{
				label = "Try to lose her in the market",
				clash = { stat = "strength", foe = "A Proselyte with orders", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -2, log = "You lost her in the night market. The next morning she was waiting outside your door with the umbrella, looking reproachful. Then she was gone for good." },
				lose = { sanity = -1, setFlags = { "fn_index_followed" }, schedule = { event = "fn_index_follower_end", inYears = 1 }, log = "She was always one street ahead. It's hard to lose someone whose orders know where you'll be." },
			},
		},
	},
	{
		id = "fn_index_follower_end",
		title = "A Year to the Day",
		text = "A year to the day after the umbrella, the young woman in the plain coat knocks on your door for the first time. She hands you a small wrapped box and a last slip of paper, unfolded so you can read it: \"Thank them.\" She bows. \"My Prescript is complete,\" she says. \"Thank you.\"",
		weight = 0,
		when = { flags = { "fn_index_followed" } },
		choices = {
			{
				label = "Open the box",
				result = { gear = "lucky_sticker", sanity = 4, log = "Inside was a Wing's lucky sticker, the expensive kind. You never found out whether the Index chose it, or she did." },
			},
			{
				label = "Ask what happens to her now",
				result = { mind = 2, sanity = 2, log = "\"Another slip,\" she said, and smiled for the first time all year. \"There's always another slip.\" She walked off into the rain without an umbrella." },
			},
		},
	},
	{
		id = "fn_index_doubter",
		title = "The Doubting Proselyte",
		text = "A young Proselyte of the Index sits down beside you at the noodle stall and slides a slip across the counter. \"Tomorrow at noon, cut the red ribbon on the bridge,\" it reads. The bridge is where his little sister sells ribbons. \"Just once,\" he whispers, \"I want to not do one. Will you help me?\"",
		weight = 8,
		once = true,
		tags = { "fingers" },
		when = { minAge = 16, notFlags = { "fn_index_proxy" } },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Help him skip it",
				clash = { stat = "mind", foe = "The Index's Messengers", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 4, setFlags = { "fn_helped_doubter" }, log = "You kept him talking at the stall until 12:01. Nothing happened. Nothing at all. He cried with relief, and then with something harder to name." },
				lose = { sanity = -4, setFlags = { "fn_helped_doubter" }, log = "At 11:58 a Messenger sat down on his other side. The Proselyte got up and walked to the bridge without looking at you." },
			},
			{
				label = "Tell him to obey",
				result = { sanity = -3, mind = 1, log = "He nodded as if he'd known you would say it. At noon a red ribbon fell into the canal. His sister bought a new one that afternoon." },
			},
			{
				label = "Cut the ribbon yourself",
				result = { sanity = 1, chronicle = "fn_prescript_done", log = "You cut the ribbon at noon, so he wouldn't have to. Technically the Prescript was carried out. He didn't know whether to thank you or report you, so he did both." },
			},
		},
	},

	-- ── members ──
	{
		id = "fn_index_prescript",
		title = "Today's Prescript",
		text = "This morning's slip is waiting under your door, folded twice. \"Buy three oranges. Throw the second into the canal at 9:40. Give the third to a woman in a green hat.\" Proselytes who obey feel something like grace. Proselytes who don't carry the consequence, and nobody says what the consequence is.",
		weight = 26,
		cooldown = 2,
		tags = { "fingers" },
		when = { career = "index" },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Carry it out to the letter",
				clash = { stat = "intelligence", foe = "An absurdly specific morning", coins = 2, base = 4, coinPower = 3 },
				win = { addTrait = "fn_prescript_grace", chronicle = "fn_prescript_done", sanity = 3, log = "Second orange, 9:40, canal. The woman in the green hat took the third and said, \"Thank you, I was told to expect you.\" You felt light all day." },
				lose = { sanity = -3, log = "You threw the wrong orange. It probably doesn't matter. You'll never stop wondering if it mattered." },
			},
			{
				label = "Stay in bed",
				result = { sanity = -6, log = "You stayed in bed. Nothing happened that day, or the next. You keep waiting for the consequence, and the waiting is the consequence." },
			},
			{
				label = "Ask your Proxy what it means",
				result = { mind = 2, log = "Your Proxy looked at you as if you'd asked what water means. \"It means oranges,\" she said, \"and a canal, and a hat. What else would it mean?\"" },
			},
		},
	},
	{
		id = "fn_index_proxy_test",
		title = "Under a Proxy",
		text = "Your Proxy, a quiet woman named Ulrike, tests her Proselytes once a season. Today's test is a sparring bout in an empty warehouse, exactly eleven moves long, because her Prescript says eleven. Yours, she says, says only that you must still be standing at the end of the eleventh.",
		weight = 22,
		once = true,
		tags = { "fingers" },
		when = { career = "index", notFlags = { "fn_index_ranked_proxy" } },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Spar with her",
				clash = { stat = "strength", foe = "Proxy Ulrike", coins = 2, base = 5, coinPower = 3, fight = true, status = "poise" },
				win = { strength = 2, setFlags = { "fn_ulrike_approves" }, log = "On the eleventh move you were still standing, barely. Ulrike wrote something in a small book. \"Adequate,\" she said, which from a Proxy is a song." },
				lose = { health = { -6, -2 }, sanity = -1, log = "You were on the floor by the sixth move. Ulrike helped you up for each of the other five." },
			},
			{
				label = "Ask to see her Prescript",
				result = { mind = 2, sanity = -1, log = "She showed you: eleven moves, a time, your name. Seeing your name on a slip in someone else's hand made your stomach drop, and then, strangely, steady." },
			},
		},
	},
	{
		id = "fn_index_carry",
		title = "Carrying the Slips",
		text = "As a Proxy you carry Prescripts to the Proselytes now, slips sealed in plain envelopes. Tonight there are seven. You don't read them; nobody reads them. But the seventh envelope has your own name on the front, in handwriting you have never seen before.",
		weight = 20,
		cooldown = 4,
		tags = { "fingers" },
		when = { career = "index", flags = { "fn_index_ranked_proxy" }, notFlags = { "fn_index_messenger" } },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Deliver the six, then open yours",
				result = { sanity = -2, mind = 2, chronicle = "fn_prescript_done", log = "Six delivered. The seventh said: \"Rest tomorrow.\" You rested. It was the most frightening day off of your life." },
			},
			{
				label = "Open yours first",
				result = { sanity = -4, log = "It said: \"You opened this first.\" Nothing else. You delivered the other six with shaking hands." },
			},
			{
				label = "Hand yours to a Messenger, unopened",
				result = { promote = true, intelligence = 1, log = "The Messenger took it without a word. The next morning you were a Messenger yourself. Nobody explained, and you knew better than to ask." },
			},
		},
	},
	{
		id = "fn_index_device",
		title = "The Device",
		text = "Senior members of the Index don't get paper any more. Your Prescripts arrive on a small device now, glowing faintly, never wrong. Today's says only: \"Walk to the bridge. Wait.\" You've been waiting four hours. The screen hasn't changed. People are starting to stare.",
		weight = 18,
		once = true,
		tags = { "fingers" },
		when = { career = "index", flags = { "fn_index_messenger" } },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Keep waiting",
				clash = { stat = "mind", foe = "Faith", coins = 3, base = 5, coinPower = 3 },
				win = { addTrait = "fn_prescript_grace", sanity = 4, chronicle = "fn_prescript_done", log = "At hour six a child dropped a coin off the bridge, and you caught it before it hit the water. The device went dark, satisfied. So did you." },
				lose = { sanity = -5, log = "At midnight the device switched itself off. It never explained. You walked home wondering what you had missed." },
			},
			{
				label = "Walk away",
				result = { sanity = -3, log = "You walked away at hour five. Halfway home the device lit up with a single word: \"Noted.\"" },
			},
		},
	},
}
