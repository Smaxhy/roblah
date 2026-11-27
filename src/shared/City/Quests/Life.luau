--[[
	Side quests, area A.
		bs_q_coat     a foundling looks for the Office whose crest was on the coat they were found in
		bs_q_teodor   a neighbor's debt to the Thumb, paid properly
	Quest activities are in Activities/Life.luau; the coat's last scene is in Events/Life_Adult.luau.
]]

return {
	order = { "bs_q_coat", "bs_q_teodor" },

	bs_q_coat = {
		name = "The Coat on the Doorstep",
		desc = "You were found after a Night, wrapped in a Fixer's coat with a crest on the collar: a key inside a circle. Find out whose it was.",
		giver = "The coat",
		expires = 12,
		steps = {
			{
				text = "Ask the old Fixers on your street about the crest.",
				hint = "Activities: Ask about the crest",
				onStart = { setFlags = { "bs_q_coat_ask" } },
				check = { when = { flags = { "bs_q_coat_asked" } } },
				doneLog = "An old Fixer squinted at the crest for a long time. \"Latch Office,\" she said. \"Closed twenty years ago. Its last Rep cuts keys in the market now.\"",
			},
			{
				text = "Find the key-cutter in the market.",
				hint = "Activities: Visit the key-cutter",
				onStart = { setFlags = { "bs_q_coat_find" } },
				check = { when = { flags = { "bs_q_coat_found" } } },
				doneLog = "The key-cutter's stall has the crest painted small on its sign: a key inside a circle.",
			},
			{
				text = "Hear what she has to tell you.",
				check = { when = { flags = { "bs_q_coat_done" } } },
			},
		},
		reward = { sanity = 6, mind = 2, gear = "fixer_coat", log = "You know whose coat it was now. You had it mended at a Workshop, and the crest polished, and you wear it on the coldest days. It finally fits." },
	},

	bs_q_teodor = {
		name = "Teodor's Debt",
		desc = "Your neighbor Teodor owes the Thumb two hundred Ahn and has a week. Raise it, then pay it the only way the Thumb accepts: properly.",
		giver = "Teodor, next door",
		expires = 8,
		steps = {
			{
				text = "Raise two hundred Ahn.",
				hint = "Hold 200 Ahn at once",
				check = { when = { min = { money = 200 } } },
				doneLog = "You have the money. Now it has to be paid properly, which with the Thumb is the hard part.",
			},
			{
				text = "Pay the debt at the Thumb's table, with every correct title.",
				hint = "Activities: Pay Teodor's debt",
				onStart = { setFlags = { "bs_q_teodor_pay" } },
				check = { when = { flags = { "bs_q_teodor_paid" } } },
			},
		},
		reward = {
			sanity = 5,
			addRelation = { kind = "friend", name = "Teodor Halas", bond = 75, age = { 40, 55 } },
			log = "Teodor wept on your doorstep, which embarrassed you both. He fixed your locks, your stairs and your radio for the rest of his life, and never let you pay for a single thing.",
		},
	},
}
