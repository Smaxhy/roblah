--[[
	Side quests from L Corp's world. Steps open a quest activity (Activities/LCorp.luau),
	a scheduled scene (Events/LCorp_Quests.luau) or an expedition (Expeditions/LCorp.luau).
	Fields: name, desc, giver, expires, steps = { text, hint, onStart, check, doneLog }, reward.
]]

return {
	order = { "lc_q_missing_agent", "lc_q_manuals" },

	-- the age of the Wings, District 12: a neighbor's daughter didn't come home
	lc_q_missing_agent = {
		name = "The Agent Who Didn't Come Home",
		desc = "Mrs. Halloran's daughter Ines is an L Corp Agent, and she hasn't come home in eight days. The company says she's on extended shifts. Mrs. Halloran doesn't believe it.",
		giver = "Mrs. Halloran, who sells tea leaves on your street",
		expires = 6,
		steps = {
			{
				text = "Ask around the Green Kettle, the teahouse where L Corp staff go after their shifts.",
				hint = "Activities: Ask about Ines Halloran",
				onStart = { setFlags = { "lc_q_agent_on" } },
				check = { when = { flags = { "lc_q_agent_clue" } } },
				doneLog = "A Clerk at the Green Kettle remembered Ines: Disciplinary Team, the one in red armor who always tipped. \"Ask at the gate,\" he said, \"on a Thursday. The night guard is her friend.\"",
			},
			{
				text = "Go to the L Corp gate on a Thursday night and ask the guard.",
				hint = "It will take some time to catch the right shift.",
				onStart = { schedule = { event = "lc_q_agent_gate", inYears = 1 } },
				check = { when = { flags = { "lc_q_agent_truth" } } },
				doneLog = "You know what happened to Ines Halloran now, one way or another.",
			},
		},
		reward = { sanity = 4, mind = 2, relationBond = { kind = "all", amount = 3 }, log = "You went back to Mrs. Halloran's stall and told her what you'd learned. She listened without a word, then pressed a tin of her best tea into your hands, and wouldn't take it back." },
	},

	-- after the fall: keep the old safety manuals out of the wrong hands
	lc_q_manuals = {
		name = "The Safety Manuals",
		desc = "The owner of the Green Kettle keeps a shelf of Lobotomy Corporation's old safety manuals, and scavengers keep going down into the sealed branches without them. She wants them handed out, and she wants the ones still sealed underground brought up.",
		giver = "The owner of the Green Kettle",
		expires = 8,
		steps = {
			{
				text = "Take the manuals from behind the Green Kettle's counter and hand them out at the Thursday meeting.",
				hint = "Activities: Hand out the old manuals",
				onStart = { setFlags = { "lc_q_manuals_on" } },
				check = { when = { flags = { "lc_q_manuals_shelf" } } },
				doneLog = "Every scavenger crew at the Thursday meeting went home with a manual. One of them came back the next week just to say it had worked.",
			},
			{
				text = "Go down into a sealed L Corp branch and bring up the manuals left in its safety office.",
				hint = "Expeditions: The Sealed Branch",
				check = { when = { flags = { "done_lc_exp_sealed_branch" } } },
				doneLog = "You came up out of the branch with a box of manuals, damp and smelling of the dark, but readable.",
			},
		},
		reward = { sanity = 5, mind = 2, setFlags = { "lc_manuals_saved" }, log = "The owner of the Green Kettle stamped every manual with a little green kettle and gave them away free to anyone going down. Fewer crews have gone missing since. She named a tea after you." },
	},
}
