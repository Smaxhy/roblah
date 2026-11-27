--[[
	Titles, area A. They go just before "Saw the Light", so a life that did one of these
	things is named for it rather than for living through the White Nights.
]]

return {
	{ id = "bs_title_night", name = "Walked Out of the Night", desc = "Caught outside when the Sweepers came, and walked home at dawn.", check = { when = { flags = { "bs_night_survivor" } } }, before = "light" },
	{ id = "bs_title_door", name = "The One Who Opened the Door", desc = "Held a door open for strangers until 3:12, and everyone inside saw the morning.", check = { when = { flags = { "bs_kept_door" } } }, before = "light" },
	{ id = "bs_title_pillar", name = "Pillar of the Street", desc = "Rose to the top of an ordinary trade, and still knew everyone's name.", check = { when = { flags = { "bs_ordinary_top" } } }, before = "light" },
}
