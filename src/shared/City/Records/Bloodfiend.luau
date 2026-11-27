--[[
	Records for Bloodfiend lives.
]]

return {
	{ id = "bf_rec_kindred", name = "Kindred", desc = "Accept the Kindred's gift and become a Bloodfiend.", check = { when = { form = "bloodfiend" } } },
	{ id = "bf_rec_century", name = "A Century of Nights", desc = "Live to 100 as a Bloodfiend.", check = { when = { form = "bloodfiend", minAge = 100 } } },
	{ id = "bf_rec_steward", name = "Steward of the Family", desc = "Rise to the top of a Bloodfiend Family's service.", check = { when = { flags = { "bf_family_steward" } } } },
}
