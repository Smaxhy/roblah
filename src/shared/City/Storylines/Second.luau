--[[
	SECOND STORIES (act = 2). The story you were born into ends around seventeen. After that
	another finds you: one whose `when` fits the life you've made (your job, your District, or
	just being someone the City has noticed). Its chapters count years from the day it began
	(when.storyYear = 0, 1, 3, 5, 7 in Events/Story_Second.luau).

	Each stands on something that is true of the City in every age:
	  Grade Nine         Hana licenses Fixers and grades them, 9 up to 1, from their job reports
	  The Fourth Pack    R Corp's soldiers are printed from a backup; a loss is a reprint
	  Ten Seconds        a WARP ride is ten seconds outside and far longer inside; W Corp's
	                     cleanup crews go in, and then the passengers are put back as they were
	  Borrowed Hours     in District 20, T Corp collects time, and sells it
	  The Prescript      the Index hands out Prescripts; Messengers deliver, Proxies see to them
	  The Portrait       the Ring makes its art out of people
	  Section Seven      the Seven Association deals in information
	  A Ticket to the Nest   a Nest is for a Wing's own people; everyone else stops at the gate
]]

local FIXERS = { "fixer", "zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi" }

return {
	{
		id = "sl2_grade_nine",
		act = 2,
		name = "Grade Nine",
		hook = "Hana grades you from your job reports. Somebody has been improving yours.",
		tone = "grim",
		weight = 14,
		when = { career = FIXERS },
		goal = "Your last report came back graded too well. Find out why.",
		cast = { "sl2_gn_rep", "sl2_gn_examiner" },
	},
	{
		id = "sl2_fourth_pack",
		act = 2,
		name = "The Fourth Pack",
		hook = "R Corp prints its soldiers. There's a tank in the east hall with your name on it, and something in it.",
		tone = "strange",
		weight = 30,
		when = { career = "rcorp" },
		goal = "There's a tank with your name on it. Don't look. Or look.",
		cast = { "sl2_fp_tech", "sl2_fp_rabbit" },
	},
	{
		id = "sl2_ten_seconds",
		act = 2,
		name = "Ten Seconds",
		hook = "A WARP ride takes ten seconds. You're on the crew that goes in when the doors won't open.",
		tone = "strange",
		weight = 30,
		when = { career = "wcorp_cleanup" },
		goal = "First carriage tomorrow. They say don't read the tickets.",
		cast = { "sl2_ts_chief", "sl2_ts_rider" },
	},
	{
		id = "sl2_borrowed_hours",
		act = 2,
		name = "Borrowed Hours",
		hook = "In District 20 everything is paid for in time. You signed two years over to T Corp when you were young. The account's in arrears.",
		tone = "grim",
		weight = 26,
		when = { district = "d20" },
		goal = "A T Corp collector is coming about your account.",
		cast = { "sl2_bh_collector", "sl2_bh_clerk" },
	},
	{
		id = "sl2_prescript",
		act = 2,
		name = "The Prescript",
		hook = "A Messenger of the Index puts a slip in your hand: your name, a time, and a thing to do.",
		tone = "strange",
		weight = 10,
		goal = "The slip says to leave your door unlocked on the ninth.",
		cast = { "sl_messenger", "sl2_pr_proxy" },
	},
	{
		id = "sl2_portrait",
		act = 2,
		name = "The Portrait",
		hook = "A Docent of the Ring says you have a remarkable face, and that it would be a shame to waste it.",
		tone = "tragic",
		weight = 8,
		goal = "A Docent wants you to sit for a portrait. They pay well.",
		cast = { "sl2_pt_docent", "sl2_pt_student" },
	},
	{
		id = "sl2_section_seven",
		act = 2,
		name = "Section Seven",
		hook = "A whole floor of a tenement is empty: plates on the tables, coats on the hooks. A woman wants her son found.",
		tone = "grim",
		weight = 12,
		when = { career = { "seven", "fixer", "zwei" } },
		goal = "Eleven people gone from one floor. Start with what they had in common.",
		cast = { "sl2_s7_mother", "sl2_s7_guard" },
	},
	{
		id = "sl2_nest_ticket",
		act = 2,
		name = "A Ticket to the Nest",
		hook = "Past the checkpoint the streets are lit all night. A clerk says there's a way in, for someone who can pay or pass.",
		tone = "hopeful",
		weight = 12,
		when = { side = "backstreets" },
		goal = "A Nest clerk says there are three ways in. Ask what they are.",
		cast = { "sl2_nt_clerk", "sl2_nt_guard" },
	},
}
