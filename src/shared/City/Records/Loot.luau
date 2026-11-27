--[[
	Records for bosses, raids, named gear and books (bl_ ids).
]]

local NAMED_WEAPONS = {
	"bl_verdict", "bl_courtesy", "bl_black_cloud", "bl_prescript", "bl_grudgebearer", "bl_lullaby",
	"bl_penance", "bl_stormgut", "bl_hoofbeat", "bl_pointille", "bl_snuffer",
}

return {
	{ id = "bl_rec_unreal", name = "Unreal Find", desc = "Find something no Workshop can grade.", check = { when = { flags = { "bl_found_unreal" } } } },
	{ id = "bl_rec_legendary", name = "Legendary Find", desc = "Come home with a legendary drop.", check = { when = { flags = { "bl_found_legendary" } } } },
	{ id = "bl_rec_trophy", name = "Named Terror", desc = "Beat one of the City's named terrors.", check = { when = { flags = { "bl_trophy" } } } },
	{ id = "bl_rec_colorbreaker", name = "Colorbreaker", desc = "Beat the Ivory Verdict.", check = { when = { flags = { "bl_slew_verdict" } } } },
	{ id = "bl_rec_shadow_kept", name = "Kept Your Shadow", desc = "Face the Lamplighter, an ALEPH, and keep your shadow.", check = { when = { flags = { "bl_held_lamplighter" } } } },
	{ id = "bl_rec_lights_out", name = "Lights Out", desc = "Put the Lamplighter back in its egg with a crew.", check = { when = { flags = { "bl_slew_lamplighter" } } } },
	{ id = "bl_rec_four_thirty_three", name = "4:33", desc = "Outlast the Foreman through all three waves of the Night.", check = { when = { flags = { "bl_outlasted_foreman" } } } },
	{ id = "bl_rec_raid", name = "Crew of Legend", desc = "Clear a crew raid with other players.", check = { when = { flags = { "bl_raid_cleared" } } } },
	{ id = "bl_rec_reception_crew", name = "Guests Who Won", desc = "Win a Library reception as a crew.", check = { when = { flags = { "bl_won_reception_crew" } } } },
	{ id = "bl_rec_self_taught", name = "Self-Taught", desc = "Learn an ability from a book that teaches.", check = { when = { flags = { "bl_ab_learned" } } } },
	{ id = "bl_rec_ironsong", name = "Ironsong Regular", desc = "Have a weapon re-tuned at Ironsong Atelier.", check = { when = { flags = { "bl_tuned_weapon" } } } },
	{ id = "bl_rec_named_weapon", name = "A Name in Hand", desc = "End a life carrying a named weapon.", check = { when = { hasGear = NAMED_WEAPONS } } },
}
