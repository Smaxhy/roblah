--[[
	Two more stories to be born into (Events/Story_Early.luau has the chapters).
	  The Sweepers' Hour     any age, Backstreets: Night in the Backstreets runs from 3:13 to 4:34,
	                         and what's outside then is swept. A family that counts heads.
	  What the Smoke Left    born into the Age of L Corp: the Smoke War is over, the Wing that
	                         lost it is gone, and your father breathed its smoke for years.
]]

return {
	{
		id = "sl_sweepers_hour",
		name = "The Sweepers' Hour",
		hook = "Every night at ten past three your mother locks the door and counts heads. The year you were born, the count came up one short.",
		tone = "grim",
		weight = 14,
		when = { side = "backstreets", hasRelation = "mother" },
		goal = "Be inside by ten past three. Every night.",
		cast = { { who = "{mother}", line = "Bolts the door at ten past three, and counts heads" }, "sl_sh_neighbour" },
	},
	{
		id = "sl_smoke_left",
		name = "What the Smoke Left",
		hook = "The Smoke War ended before you were born. Your father came home from it with a tin badge and a cough, and he's never said which side the badge was for.",
		tone = "tragic",
		weight = 18,
		when = { maxYear = 952, hasRelation = "father" },
		goal = "Your father coughs at night. Nobody talks about why.",
		cast = { { who = "{father}", line = "Came home from the Smoke War with a tin badge and a cough" } },
	},
}
