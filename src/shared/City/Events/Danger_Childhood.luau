--[[
	Danger and horror (dz_): childhood. Children get the dread, never the death: every scene
	here is survivable, and a couple of them come back for you as an adult.
	Chain: dz_k_tall_man -> (20 years) dz_k_tall_return   whether you lied to him decides it
	(Other kid scenes live with their themes: dz_n_knock_kid, dz_n_floor_hums, dz_n_hush,
	dz_d_nine_dare, dz_d_playground, dz_w_teddy, dz_f_doll.)
]]

return {
	{
		id = "dz_k_tall_man",
		title = "The Man Who Asks the Time",
		text = "Every evening on the way home, a very tall man in a long coat asks you the time. He never has a watch. Every evening he's a little taller.",
		weight = 5,
		once = true,
		when = { minAge = 6, maxAge = 12 },
		choices = {
			{ label = "Tell him the truth", result = { sanity = -2, setFlags = { "dz_tall_truth" }, schedule = { event = "dz_k_tall_return", inYears = 20 }, log = "\"Thank you,\" he said, every evening, and tipped a hat he wasn't wearing." } },
			{ label = "Lie to him", result = { sanity = -4, setFlags = { "dz_tall_lie" }, schedule = { event = "dz_k_tall_return", inYears = 20 }, log = "You said nine when it was six. He looked at you a long moment and said, \"No, it isn't.\"" } },
			{ label = "Tell a grown-up", result = { sanity = 1, log = "A grown-up walked you home every evening for a month, and you never saw him again. They never asked what he looked like, as if they already knew." } },
		},
	},
	{
		id = "dz_k_tall_return",
		title = "He Asks the Time Again",
		text = "A very tall man in a long coat stops you in the street. \"What time is it?\" he asks, exactly the way he did when you were small. You check. It's 3:11.",
		weight = 0,
		when = { minAge = 18 },
		choices = {
			{ label = "\"It's 3:11.\"", requires = { flags = { "dz_tall_truth" } }, result = { sanity = -4, addTrait = "dz_night_ears", log = "He nodded and held open the door beside him: a stranger's stairwell. It was enough." } },
			{
				label = "\"It's 3:11.\"",
				hint = "Mental Strength check. You lied to him once.",
				requires = { flags = { "dz_tall_lie" } },
				clash = { stat = "mind", foe = "A man who remembers", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -6, log = "\"Better,\" he said, and held a stranger's door open for you. You went through it at 3:12." },
				lose = { die = "Kept talking to a tall man until 3:13", log = "\"No,\" he said kindly, \"it's 3:13.\" And it was." },
			},
			{
				label = "Run",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Two minutes", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -4, log = "You made your own door at 3:13 exactly, and heard him laughing three streets away." },
				lose = { health = { -18, -8 }, log = "The street went on longer than it should have.", cause = "Ran from a tall man at 3:11" },
			},
		},
	},
	{
		id = "dz_k_drill",
		title = "Caught-Outside Drill",
		text = "At the academy, Teacher Oh makes everyone practice: if you're ever caught outside, find a doorway, face the wall, and don't breathe loud. Min-jun laughs. Teacher Oh doesn't.",
		weight = 5,
		once = true,
		when = { minAge = 6, maxAge = 10, side = "backstreets" },
		codex = "dz_lore_night_bargains",
		choices = {
			{ label = "Practice until it's perfect", result = { mind = 3, sanity = -1, log = "You practiced in the hallway at home every night for a month. Your parents watched and didn't say anything." } },
			{ label = "Laugh with Min-jun", result = { sanity = 1, log = "Teacher Oh kept you both after class and told you about her sister. Neither of you laughed again." } },
		},
	},
	{
		id = "dz_k_late_home",
		title = "2:58, and No Key",
		text = "Your mother works late at the diner, and she's always home by half past two. Tonight it's 2:58, and the key hasn't turned in the lock.",
		weight = 5,
		once = true,
		when = { minAge = 6, maxAge = 12, side = "backstreets", hasRelation = "mother" },
		choices = {
			{ label = "Wait by the door", result = { sanity = -5, relationBond = { kind = "mother", amount = 6 }, log = "You sat against the door and counted until the key turned at 3:12. She held you until you both stopped shaking." } },
			{ label = "Go and look for her", result = { sanity = -7, strength = 2, relationBond = { kind = "mother", amount = 10 }, log = "You were halfway down the stairs when she came running up them. She carried you the rest of the way, and didn't let go until morning." } },
			{ label = "Light every lamp", result = { sanity = -3, mind = 1, log = "You lit every lamp in the flat so she'd see it from the street, and she did. She was home at 3:09, and never worked late again." } },
		},
	},
	{
		id = "dz_k_morning_list",
		title = "A Name You Know",
		text = "On the way to school there's a fresh sheet on the notice board, the morning list. Third name down is your deskmate's older brother.",
		weight = 5,
		once = true,
		when = { minAge = 8, maxAge = 13, side = "backstreets" },
		codex = "dz_lore_morning_lists",
		choices = {
			{ label = "Sit with your deskmate", result = { sanity = -3, addRelation = { kind = "friend", bond = 60 }, log = "You didn't say anything all day, just sat next to {newRelation}. It turned out that was the right thing." } },
			{ label = "Pretend you didn't see", result = { sanity = -4, log = "You walked past the board. You kept walking past it, every morning, for a very long time." } },
		},
	},
}
