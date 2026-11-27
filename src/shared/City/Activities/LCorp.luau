--[[
	Activities from L Corp's world: an Agent's extra work order, a researcher's evening
	shift on the logs, tea at the Green Kettle (District 12's teahouse, in every era), and
	the steps of the side quests in Quests/LCorp.luau.
	Fields: id, category, name, desc, minAge, cost, cooldown, when, result | clash + win + lose.
]]

return {
	{
		id = "lc_act_work_order",
		category = "money",
		name = "Pull an extra work order",
		desc = "Volunteer for one more unit on today's board. PE-Box bonuses are good. The units don't care that you're tired.",
		minAge = 18,
		cooldown = 1,
		when = { career = "lcorp_agent", minRank = 2, world = { era = "wings" } },
		clash = { stat = "mind", foe = "One more containment unit", coins = 2, base = 4, coinPower = 3 },
		win = { paycheck = 0.15, mind = { 1, 2 }, setFlags = { "saw_abnormality" }, log = "You took one more unit at the end of the day and did it by the book. The PE-Boxes came out green, and so did your bonus." },
		lose = { health = { -6, -2 }, sanity = { -4, -2 }, setFlags = { "saw_abnormality" }, log = "One more unit was one too many. You got out, but the counter dropped, and so did you, in the corridor outside.", cause = "One work order too many" },
	},
	{
		id = "lc_act_lab_shift",
		category = "money",
		name = "Work late on the observation logs",
		desc = "An evening in the lab writing up the day's logs. Careful work, a small bonus, and the hum of the facility below.",
		minAge = 18,
		cooldown = 1,
		when = { career = "lcorp_research", world = { era = "wings" } },
		result = { intelligence = { 1, 2 }, paycheck = 0.1, sanity = -1, log = "You wrote up the day's observation logs until the lab lights dimmed to night mode. Measure twice, write once." },
	},
	{
		id = "lc_act_green_kettle",
		category = "people",
		name = "Tea at the Green Kettle",
		desc = "District 12's teahouse, where L Corp people drink tea after their shifts, or used to. Somebody at the next table always has a story.",
		minAge = 10,
		cost = 5,
		when = { district = "d12" },
		result = { sanity = { 2, 4 }, mind = { 0, 1 }, log = "You drank tea at the Green Kettle under the old photographs and listened to the stories at the next table. Some of them were even true." },
	},
	-- quest steps
	{
		id = "lc_act_ask_agent",
		category = "people",
		name = "Ask about Ines Halloran",
		desc = "Ask at the Green Kettle whether anyone has seen Mrs. Halloran's daughter, the Agent who didn't come home.",
		minAge = 14,
		when = { flags = { "lc_q_agent_on" }, notFlags = { "lc_q_agent_clue" } },
		result = { setFlags = { "lc_q_agent_clue" }, sanity = -1, log = "You asked at every table in the Green Kettle. Most people looked away. One Clerk, eventually, didn't." },
	},
	{
		id = "lc_act_manuals",
		category = "people",
		name = "Hand out the old manuals",
		desc = "Take the L Corp safety manuals from behind the Green Kettle's counter to the scavenger crews at the Thursday meeting.",
		minAge = 14,
		when = { flags = { "lc_q_manuals_on" }, notFlags = { "lc_q_manuals_shelf" } },
		result = { setFlags = { "lc_q_manuals_shelf" }, sanity = 2, log = "You handed out every manual on the shelf and showed the crews which pages mattered: the work types, the exits, the rule about never looking down." },
	},
}
