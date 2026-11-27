--[[
	Today in the City: daily scenes about recruitment and Hana's board (writer: fc_ ids).
	Each points at a weight-0 event in Events/Factions_Rankings.luau.
]]

return {
	order = { "fc_recruiting_day", "fc_board_day" },
	fc_recruiting_day = { name = "Recruiting Day", desc = "Every faction in the District is hiring at once: Wings, Offices, and a very polite Soldato on the corner.", event = "fc_daily_recruit_day" },
	fc_board_day = { name = "Board Day", desc = "Hana posts the quarterly Fixer rankings. Every Office is poaching, and the noodle stall across the street is packed.", event = "fc_daily_board" },
}
