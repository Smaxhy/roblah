--[[
	Ambitions from the Wings and L Corp. Same format as Ambitions/Core.luau:
	id, name, desc, minAge, maxAge, weight, when (who can draw it), check, progress, reward.
]]

return {
	{
		id = "lc_amb_level_three",
		name = "Level 3",
		desc = "Reach Agent, Level 3 at L Corp.",
		minAge = 18,
		maxAge = 45,
		weight = 14,
		when = { career = "lcorp_agent" },
		check = { when = { career = "lcorp_agent", minRank = 4 } },
		progress = { rank = 4 },
		reward = { mind = 2, sanity = 2, log = "Level 3. The HE units are on your board now, and the rookies have started asking you which files to read twice." },
	},
	{
		id = "lc_amb_captain",
		name = "The Captain's Armband",
		desc = "Become a Department Captain at L Corp.",
		minAge = 20,
		maxAge = 60,
		weight = 10,
		when = { career = "lcorp_agent", minRank = 3 },
		check = { when = { flags = { "lcorp_captain" } } },
		progress = { rank = 7 },
		reward = { sanity = 5, intelligence = 2, log = "The armband is yours. The longest-serving Agent in the department: a lot of people didn't get to be that." },
	},
	{
		id = "lc_amb_publish",
		name = "Publish",
		desc = "Publish a study of your own at L Corp.",
		minAge = 18,
		maxAge = 50,
		weight = 14,
		when = { career = "lcorp_research" },
		check = { when = { flags = { "lc_rs_published" } } },
		reward = { intelligence = 2, sanity = 3, log = "Your name is on a study that Agents read before they go into a unit. Somewhere in the facility, someone is safer because of you." },
	},
	{
		id = "wg_amb_class_five",
		name = "Class 5",
		desc = "Reach Class 5 in your District's Wing.",
		minAge = 20,
		maxAge = 65,
		weight = 10,
		when = { career = "wing" },
		check = { when = { career = "wing", minRank = 5 } },
		progress = { rank = 5 },
		reward = { money = 150, sanity = 3, log = "Class 5. People in the office stand up a little straighter when you walk past, and you've stopped noticing." },
	},
}
