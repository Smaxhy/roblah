--[[
	Records for recruitment, the faction wars and Hana's board (writer: fc_ ids).
	A list; see Records/Core.luau. Crew expeditions set done_<id> on success.
]]

return {
	{ id = "fc_rec_winning_side", name = "On the Winning Side", desc = "Back the side that won a faction war, and collect.", check = { when = { flags = { "fc_war_won" } } } },
	{ id = "fc_rec_war_veteran", name = "Street-War Veteran", desc = "Fight in a faction war and walk out of it.", check = { when = { trait = "fc_war_veteran" } } },
	{ id = "fc_rec_turncoat", name = "Turned Coat", desc = "Change sides in the middle of a war.", check = { when = { trait = "fc_turncoat" } } },
	{ id = "fc_rec_both_sides", name = "Both Sides Paid", desc = "Sell to both sides of a war and get away with it.", check = { when = { trait = "fc_double_dealer" } } },
	{ id = "fc_rec_said_no", name = "No Thanks, Capo", desc = "Turn down the Thumb to a Capo's face.", check = { when = { flags = { "fc_refused_capo" } } } },
	{ id = "fc_rec_headhunted", name = "Headhunted", desc = "Be recruited by a Finger, an Association and a Wing in one life.", check = { when = { flags = { "fc_joined_finger", "fc_joined_assoc", "fc_joined_wing" } } } },
	{ id = "fc_rec_top_ten", name = "Top Ten", desc = "Reach the top ten on Hana's board.", check = { when = { flags = { "fc_rk_top_ten" } } } },
	{ id = "fc_rec_held_street", name = "Kept the Market Open", desc = "Hold the noodle market through a faction war with your crew.", check = { when = { flags = { "done_fc_exp_hold_street" } } } },
	{ id = "fc_rec_tea_house", name = "Out of the Fire", desc = "Get forty families out of a burning street between two Associations.", check = { when = { flags = { "done_fc_exp_tea_house" } } } },
	{ id = "fc_rec_depot", name = "Depot Raider", desc = "Raid a Wing's forward depot with your crew, and bring down its Rhino.", check = { when = { flags = { "done_fc_exp_depot" } } } },
	{ id = "fc_rec_spoils", name = "Spoils of War", desc = "End a life carrying a war spoil taken from the other side.", check = { when = { hasGear = { "fc_capo_revolver", "fc_vengeance_page", "fc_shi_needle", "fc_liu_ember_coat", "fc_rhino_plate" } } } },
}
