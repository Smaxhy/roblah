--[[
	Titles for faction lives (writer: fc_ ids). The war titles go before "light" (Saw the
	Light, which most early lives earn), so a war that defined a life names it.
]]

return {
	{ id = "fc_title_war_hero", name = "Hero of the Street War", desc = "Won their own battle in a faction war, and backed the side that won it.", check = { when = { flags = { "fc_war_won" }, trait = "fc_war_veteran" } }, before = "light" },
	{ id = "fc_title_turncoat", name = "The Turncoat", desc = "Changed sides in the middle of a war, and lived with it.", check = { when = { trait = "fc_turncoat" } }, before = "light" },
	{ id = "fc_title_profiteer", name = "Sold to Both Sides", desc = "Made a fortune out of other people's war.", check = { when = { trait = "fc_double_dealer" } }, before = "light" },
	{ id = "fc_title_market", name = "Keeper of the Market", desc = "Held a noodle market open through a war, so everyone got home before three.", check = { when = { flags = { "done_fc_exp_hold_street" } } }, before = "light" },
	{ id = "fc_title_top_ten", name = "A Name on Hana's Board", desc = "Climbed into the top ten of Hana's board, and stayed there.", check = { when = { trait = "fc_ranked_name" } }, before = "light" },
	{ id = "fc_title_recruit", name = "Everyone's Recruit", desc = "Every faction in the City wanted them, and several got them.", check = { when = { flags = { "fc_joined_finger", "fc_joined_assoc" } } } },
}
