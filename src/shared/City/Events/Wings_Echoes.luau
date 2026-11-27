--[[
	Echoes of other players' deeds in the Wings (Chronicle/LCorp.luau): a Congested WARP
	train cleared, an R Corp team brought home. {actor} is who did it, {actorDistrict} where.
]]

return {
	{
		id = "wg_echo_cca",
		title = "Platform Nine Reopens",
		text = "The WARP station has a new poster up: W Corp thanks its Cleanup Agents for clearing a Congested train before the doors opened, and names one of them, {actor}. To celebrate, fares are cut for the week. The queue is long. Most of the people in it don't know what Congested means.",
		weight = 12,
		cooldown = 8,
		tags = { "warp" },
		when = { chronicle = "wg_cca_congested", minAge = 10 },
		codex = "wg_lore_train_states",
		choices = {
			{
				label = "Take a cheap ride to another District and back",
				hint = "10 Ahn.",
				requires = { min = { money = 10 } },
				result = { money = -10, sanity = 2, log = "You crossed the City and back for almost nothing. It took seconds. It felt longer. On the way home you read the poster again, and wondered what {actor} saw." },
			},
			{
				label = "Ask a Cleanup Agent what Congested means",
				result = { mind = 2, sanity = -1, codex = "wg_lore_cleanup", log = "She told you, in two sentences, and then went back to her coffee. You've watched the platform board instead of the doors ever since." },
			},
			{
				label = "Walk, this week",
				result = { health = 1, log = "You walked everywhere that week. It took hours. You didn't mind." },
			},
		},
	},
	{
		id = "wg_echo_pack",
		title = "The Pack Came Home",
		text = "There's a parade through the District 18 Backstreets: an R Corp team back from a contract nobody expected them to survive, every one of them, led by {actor}. The hatched soldiers march in perfect step. The human contractors wave. Someone has painted the soldiers' numbers on a banner, with names written underneath.",
		weight = 12,
		cooldown = 8,
		tags = { "rcorp" },
		when = { chronicle = "wg_pack_home", minAge = 8 },
		codex = "wg_lore_rcorp",
		choices = {
			{
				label = "Cheer them home",
				result = { sanity = 3, log = "You cheered until you were hoarse. One of the hatched soldiers looked straight at you and, very slightly, smiled. You didn't know they could." },
			},
			{
				label = "Sign up with R Corp",
				hint = "District 18. Needs Health 30 and Strength 25.",
				requires = { district = "d18", minAge = 17, min = { health = 30, strength = 25 } },
				result = { career = "rcorp", sanity = -1, log = "You followed the parade to the recruiting office and signed. \"Everyone does, after one of these,\" the recruiter said. \"Some of them come home.\"" },
			},
			{
				label = "Read the names on the banner",
				result = { mind = 1, sanity = 1, log = "Someone had given every hatched soldier a name. Small names, mostly, written in a hurry. You read every one." },
			},
		},
	},
}
