--[[
	SECOND STORIES, the second shelf (act = 2; chapters in Events/Story_Second2.luau).
	Three of these can find anyone, so two lives rarely get the same adult stories.

	Each stands on something that is true of the City in every age:
	  The Arm            Workshops build prosthetics as readily as weapons, and sell them on
	                     instalments. A body that is all workshop isn't let into a Nest
	  A Canard           Hana grades every threat: Canard, Urban Myth, Urban Legend, Urban
	                     Plague, Urban Nightmare, Star of the City. The grade is the price,
	                     and nobody takes a job at the bottom of the scale
	  The Company Flat   a Nest is for a Wing's own people. Stop being useful to the Wing and
	                     the flat goes with the job
	  The Ampoule        K Corp of District 11 sells ampoules that mend nearly any wound,
	                     at K Corp's price
]]

return {
	{
		id = "sl2_the_arm",
		act = 2,
		name = "The Arm",
		hook = "You lost a hand. A workshop will sell you a better one, and then tell you what else could be better.",
		tone = "strange",
		weight = 10,
		goal = "You need a hand. Three people are selling.",
		cast = { "sl2_ar_owner", "sl2_ar_man" },
	},
	{
		id = "sl2_canard",
		act = 2,
		name = "A Canard",
		hook = "Something lives in the drain on your street. Hana has graded it too small for any Fixer to bother with.",
		tone = "strange",
		weight = 10,
		goal = "Hana says the thing in your drain is a Canard. Nobody is coming.",
		cast = { "sl2_cn_nine", "sl2_cn_clerk" },
	},
	{
		id = "sl2_company_flat",
		act = 2,
		name = "The Company Flat",
		hook = "Your flat in the Nest belongs to the Wing. So does the question of who lives in it.",
		tone = "grim",
		weight = 16,
		when = { side = "nest" },
		goal = "A notice came under the door. Read it.",
		cast = { "sl2_cf_warden", "sl2_cf_reviewer" },
	},
	{
		id = "sl2_ampoule",
		act = 2,
		name = "The Ampoule",
		hook = "The stitcher who sews up your street has ruined her hands. One K Corp ampoule would mend them.",
		tone = "hopeful",
		weight = 10,
		goal = "A K Corp ampoule costs 900 Ahn. Find a way, or another way.",
		cast = { "sl2_am_stitcher", "sl2_am_clerk" },
	},
}
