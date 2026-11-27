--[[
	Today in the City, area A: ordinary days on the street. Each points at a weight-0 scene
	in Events/Life_Echoes.luau.
]]

return {
	order = { "bs_lock_day", "bs_watch_night", "bs_exam_day", "bs_moving_day" },
	bs_lock_day = { name = "Lock Day", desc = "The locksmiths have set up in the market square: new locks, old locks, and a picking competition with a prize.", event = "bs_daily_lock_day" },
	bs_watch_night = { name = "Watch Night", desc = "The neighborhood watch is short-handed. Grandpa Teo has a spare lamp and a hopeful face.", event = "bs_daily_watch_night" },
	bs_exam_day = { name = "Exam Day", desc = "The Wing's entrance exam is today. The examinee towns are walking to the hall in silence.", event = "bs_daily_exam_day" },
	bs_moving_day = { name = "Moving Day", desc = "Rents go up today, and half the street is moving house before the Night.", event = "bs_daily_moving_day" },
}
