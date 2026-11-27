--[[
	Titles of the Library and Distortion eras (writer D: lib_ / lim_ ids). Placed just
	before "Saw the Light", which almost every life of the default era earns, so a more
	specific story names the life first.
]]

return {
	{ id = "lib_title_general", name = "Victor of General Works", desc = "Came home from Roland's own Floor carrying a book.", check = { when = { flags = { "lib_won_general" } } }, before = "light" },
	{ id = "lim_title_manager", name = "Manager of the Before Team", desc = "Survived Preliminary Observation and rose to run the LCCB.", check = { when = { flags = { "lim_lccb_manager" } } }, before = "light" },
	{ id = "lim_title_case_director", name = "Case Director of the LCD", desc = "Decided how Limbus Company handles Distortions.", check = { when = { flags = { "lim_lcd_director" } } }, before = "light" },
	{ id = "lim_title_lead_researcher", name = "Lead Researcher of the LCE", desc = "Reported on the sapling to Hohenheim himself.", check = { when = { flags = { "lim_lce_lead" } } }, before = "light" },
	{ id = "lim_title_bough", name = "Gold-Finder", desc = "Found a Golden Bough under the City.", check = { when = { flags = { "lim_bough_found" } } }, before = "light" },
	{ id = "lim_title_talker", name = "The One Who Talks Them Down", desc = "Brought someone back from the edge of Distortion with words.", check = { when = { flags = { "lim_talked_down" } } }, before = "light" },
	{ id = "lim_title_passenger", name = "Passenger of Mephistopheles", desc = "Rode Limbus Company's bus for a day.", check = { when = { flags = { "lim_rode_bus" } } }, before = "light" },
	{ id = "lib_title_reception", name = "Walked Out with a Book", desc = "Won a reception in the Library.", check = { when = { flags = { "lib_won_reception" } } }, before = "light" },
}
