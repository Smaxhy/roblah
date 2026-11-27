--[[
	Today in the City: one daily event a day, the same everywhere, changing at 00:00 UTC.
	The activity "Today in the City" (daily = true) plays it once per player per day.
	Fields: name, desc (shown in the City panel), event (an event id, usually weight = 0).
]]

return {
	order = { "noodle_day", "job_board", "prescript_day", "warp_fares", "open_academy", "rat_season", "free_clinic", "book_swap" },
	noodle_day = { name = "Noodle Day", desc = "Every diner on the corner is competing for the best broth in the District. Judges wanted.", event = "daily_noodle_day" },
	job_board = { name = "The Job Board", desc = "A Fixer office has pinned a dozen small jobs to its board. First come, first paid.", event = "daily_job_board" },
	prescript_day = { name = "Slips of Paper", desc = "Small folded slips are turning up in pockets and under doors. Each one says exactly what to do.", event = "daily_prescript" },
	warp_fares = { name = "Cheap WARP Fares", desc = "W Corp is selling cut-price tickets today. Nobody asks why.", event = "daily_warp_fares" },
	open_academy = { name = "Open Academy Day", desc = "The Backstreets academies open their doors. Free lectures on the history of the Wings.", event = "daily_open_academy" },
	rat_season = { name = "Rat Season", desc = "The Rats are out in numbers. Shopkeepers are paying anyone who'll walk them home.", event = "daily_rat_season" },
	free_clinic = { name = "Free Clinic", desc = "A Nest charity is running a free clinic in the Backstreets for one day only.", event = "daily_free_clinic" },
	book_swap = { name = "Book Swap", desc = "A street market of old books, job reports and pamphlets. Some of them are about you.", event = "daily_book_swap" },
}
