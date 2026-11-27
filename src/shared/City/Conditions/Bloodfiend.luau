--[[
	Conditions for Bloodfiend lives.
]]

return {
	bf_frayed = {
		name = "Frayed",
		years = 2,
		curable = false,
		desc = "-2 Sanity a year. The Thirst got too close.",
		gainLog = "The Thirst got too close. Some nights you can still taste the iron.",
		healLog = "The fraying settled. You trust yourself again, mostly.",
		yearly = { sanity = -2 },
	},
}
