--[[
	Scenes for the side quests in Quests/LCorp.luau.
	lc_q_agent_start starts "The Agent Who Didn't Come Home"; lc_q_agent_gate is its second step.
	"The Safety Manuals" starts from lc_remnant_tea (Events/LCorp_Outside.luau).
]]

return {
	{
		id = "lc_q_agent_start",
		title = "Eight Days",
		text = "Mrs. Halloran, who sells tea leaves on your street, hasn't opened her stall in three days. You find her sitting on her front step instead. Her daughter Ines works at L Corp, in the Disciplinary Team, and hasn't come home in eight days. \"Extended shifts,\" the company told her. \"Ines would have sent word. She always sends word.\"",
		weight = 14,
		once = true,
		tags = { "lcorp" },
		when = { district = "d12", minAge = 16, world = { era = "wings" }, notFlags = { "lcorp_employee" } },
		choices = {
			{
				label = "Say you'll ask around",
				result = { sanity = 1, quest = "lc_q_missing_agent", log = "You told her you'd find out what you could. She held your hand in both of hers and didn't say anything at all." },
			},
			{
				label = "Sit with her for a while",
				result = { sanity = 2, relationBond = { kind = "all", amount = 2 }, log = "You sat with her on the step until the streetlights came on, and then you walked her inside before the Night. You didn't promise anything. She seemed to understand why." },
			},
			{
				label = "Tell her the company is sure to send word",
				result = { sanity = -2, log = "\"Of course,\" she said. \"Of course.\" Her stall stayed shut for a month." },
			},
		},
	},
	{
		id = "lc_q_agent_gate",
		title = "The Night Guard",
		text = "Thursday night at the L Corp gate. The guard on the late shift is a broad woman with a tired face and an Agent's old Continued Service armband pinned to her guard coat. When you say Ines Halloran's name, she goes very still. Then she looks up at the camera on the gatepost, and back at you.",
		weight = 0,
		when = { flags = { "lc_q_agent_on" }, world = { era = "wings" } },
		choices = {
			{
				label = "Ask her straight, and wait",
				hint = "A Mental Strength check: she wants to tell you.",
				clash = { stat = "mind", foe = "A guard under a camera", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -1, setFlags = { "lc_q_agent_truth" }, codex = "lc_lore_suppression", log = "She walked you away from the camera and told you: a breach, a suppression that went wrong, a corridor sealed for a week. Ines was alive, in the Welfare Team's long-stay ward. \"Her mother can visit,\" she said. \"Tell her to ask for Chesed. Nobody ever asks for Chesed.\"" },
				lose = { sanity = -3, setFlags = { "lc_q_agent_truth" }, log = "\"Extended shifts,\" she said, loud enough for the camera, and handed you a folded note when she checked your papers. It said: ALIVE. WELFARE WARD. ASK FOR CHESED." },
			},
			{
				label = "Slip her a few Ahn for the truth",
				hint = "20 Ahn.",
				requires = { min = { money = 20 } },
				result = { money = -20, setFlags = { "lc_q_agent_truth" }, log = "She took the money, then gave it back. \"Keep it for her mother,\" she said, and told you: Ines was hurt in a breach, and alive, and in the Welfare ward, and nobody had thought to tell her family. \"Nobody ever does,\" she said." },
			},
			{
				label = "Climb the fence and look for yourself",
				hint = "A Strength check. The fence is warm.",
				clash = { stat = "strength", foe = "The L Corp fence", coins = 2, base = 5, coinPower = 3 },
				win = { strength = 2, setFlags = { "lc_q_agent_truth", "saw_abnormality" }, log = "You got over the fence and as far as a window into the Welfare ward before security found you. You saw her: Ines Halloran, bandaged, asleep, alive. They threw you out. It was worth it." },
				lose = { health = { -8, -4 }, money = -40, setFlags = { "lc_q_agent_truth" }, log = "Security caught you on the far side of the fence. They fined you, and the guard, sighing, told you the truth anyway as they walked you out: alive, Welfare ward, ask for Chesed." },
			},
		},
	},
}
