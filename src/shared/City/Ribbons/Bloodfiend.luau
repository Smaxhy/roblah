--[[
	Titles for Bloodfiend lives (placed before the E.G.O title).
]]

return {
	{ id = "bf_title_steward", name = "Steward of the Family", desc = "Rose to the top of a Bloodfiend Family's service.", check = { when = { flags = { "bf_family_steward" } } }, before = "ego" },
	{ id = "bf_title_kindred", name = "Kindred of the Night", desc = "Took the Kindred's gift, and lived on Hemobars and nerve.", check = { when = { form = "bloodfiend" } }, before = "ego" },
}
