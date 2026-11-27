--[[
	Yearly activities of the Library and Distortion eras. Writer D (lib_ / lim_ ids).
	Two everyday ones per era, and the steps of the side quests in Quests/Limbus.luau.
]]

return {
	{
		id = "lib_tower_watch",
		category = "city",
		name = "Watch the tower from a rooftop",
		desc = "From the roofs at the edge of District 12 you can see the Library's windows light up, one Floor at a time, when a reception starts.",
		minAge = 10,
		cooldown = 1,
		when = { world = { era = "library" } },
		result = { mind = { 1, 3 }, sanity = { -2, 0 }, codex = "lib_floors", log = "You watched the Library from a District 12 rooftop until three windows lit up in a row. Somebody in there was having the worst night of their life. You went home before the Night." },
	},
	{
		id = "lim_hotline_volunteer",
		category = "people",
		name = "Volunteer on the LCD hotline",
		desc = "Line Four, Limbus Company's public Distortion hotline, takes volunteers. Mostly you listen. Sometimes you're the only one who does.",
		minAge = 16,
		cooldown = 1,
		when = { world = { era = "limbus" } },
		clash = { stat = "mind", foe = "A caller at the edge", coins = 2, base = 4, coinPower = 3 },
		win = { mind = 2, sanity = 2, log = "A man called at two in the morning to say his shadow had stopped following him. You kept him talking until the counselor arrived. In the morning he called back to say it was there again, a bit behind." },
		lose = { sanity = -3, log = "The caller hung up mid-sentence. You never found out what happened. You think about it most nights." },
	},
	{
		id = "lim_dig_shift",
		category = "money",
		name = "Haul for a Golden Bough dig",
		desc = "The Before Team pays day rates to haul rubble out of buried L Corp branches. Hard work, low pay, and every now and then, a glimpse of gold.",
		minAge = 16,
		cooldown = 1,
		when = { world = { era = "limbus" } },
		result = { wage = { 25, 70 }, health = { -3, -1 }, setFlags = { "lim_lccb_contact" }, log = "You hauled rubble out of an L Corp access shaft all day for the LCCB. Near the end of the shift, the dark at the bottom of the shaft flickered gold, just once." },
	},

	-- side quest steps
	{
		id = "lib_book_markets",
		category = "city",
		name = "Search the book markets",
		desc = "Ask at every stall that sells Library books for one name.",
		when = { flags = { "lib_q_searching" }, notFlags = { "lib_q_clue" } },
		result = { sanity = -1, setFlags = { "lib_q_clue" }, schedule = { event = "lib_loved_book", inYears = 1 }, log = "You asked at every gilt-spined stall in three Districts. At the last one, a Bookhunter stopped smiling when you said the name, and told you to come back next year." },
	},
	{
		id = "lim_qi_doors",
		category = "people",
		name = "Knock on doors for the OSIR Team",
		desc = "Ask everyone on the block when they first lost the hour.",
		when = { flags = { "lim_qi_open" }, notFlags = { "lim_qi_heard" } },
		clash = { stat = "mind", foe = "A block that doesn't remember", coins = 2, base = 4, coinPower = 3 },
		win = { mind = 1, setFlags = { "lim_qi_heard" }, log = "You knocked on forty doors and wrote down forty answers, and they all pointed at the same night." },
		lose = { sanity = -2, log = "Nobody could remember when it started, which was the point. You'll have to try again." },
	},
	{
		id = "lim_qi_walk",
		category = "city",
		name = "Walk the block at 3:12",
		desc = "One minute before the Night. Watch where the missing hour goes, then get indoors fast.",
		when = { flags = { "lim_qi_walk" }, notFlags = { "lim_qi_found" } },
		clash = { stat = "mind", foe = "3:12 in the morning", coins = 2, base = 5, coinPower = 3 },
		win = { setFlags = { "lim_qi_found" }, log = "You watched every radio on the block switch itself on at 3:12, and you were through your own door before the first wave of the Night." },
		lose = { health = { -6, -2 }, sanity = -3, cause = "Caught out at 3:13", log = "You were watching the windows when you should have been watching the time. You heard the first wave rising behind you, and ran." },
	},
}
