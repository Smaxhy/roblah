--[[
	Records of the Library and Distortion eras (writer D: lib_ / lim_ ids).
]]

return {
	{ id = "lib_rec_shelved", name = "Well Written", desc = "End a life as a book in the Library.", check = { causeHas = "became a book" } },
	{ id = "lib_rec_general", name = "General Works", desc = "Win a reception on Roland's own Floor.", check = { when = { flags = { "lib_won_general" } } } },
	{ id = "lim_rec_survivor", name = "Still Standing", desc = "Live through a Distortion.", check = { when = { flags = { "lim_distortion_survivor" } } } },
	{ id = "lim_rec_talked_down", name = "Talked Down", desc = "Talk a Distortion back from the edge.", check = { when = { flags = { "lim_talked_down" } } } },
	{ id = "lim_rec_bough_seen", name = "Gold-Touched", desc = "See a Golden Bough.", check = { when = { flags = { "lim_bough_seen" } } } },
	{ id = "lim_rec_bough_found", name = "Bough-Finder", desc = "Find a Golden Bough yourself.", check = { when = { flags = { "lim_bough_found" } } } },
	{ id = "lim_rec_lccb_manager", name = "Before Team Manager", desc = "Rise from Preliminary Observer to LCCB Manager.", check = { when = { flags = { "lim_lccb_manager" } } } },
	{ id = "lim_rec_case_director", name = "Case Director", desc = "Direct the LCD's cases.", check = { when = { flags = { "lim_lcd_director" } } } },
}
