--[[
	Titles for bosses, raids and finds (bl_ ids). "Unreal Find" sits above the Colors (it's
	rarer); the boss titles go just before "Saw the Light"; the common ones fall in just
	before the catch-all.
]]

return {
	{ id = "bl_title_unreal", name = "Unreal Find", desc = "Found something no Workshop could grade.", check = { when = { flags = { "bl_found_unreal" } } }, before = "color" },
	{ id = "bl_title_colorbreaker", name = "Colorbreaker", desc = "Beat the Ivory Verdict, a Color who kept her name.", check = { when = { flags = { "bl_slew_verdict" } } }, before = "light" },
	{ id = "bl_title_lights_out", name = "Lights Out", desc = "Put the Lamplighter, an ALEPH, back in its egg.", check = { when = { flags = { "bl_slew_lamplighter" } } }, before = "light" },
	{ id = "bl_title_shadow", name = "Kept Their Shadow", desc = "Faced the Lamplighter and held on to their own shadow.", check = { when = { flags = { "bl_held_lamplighter" } } }, before = "light" },
	{ id = "bl_title_foreman", name = "Four Thirty-Three", desc = "Outlasted the Foreman through all three waves of the Night.", check = { when = { flags = { "bl_outlasted_foreman" } } }, before = "light" },
	{ id = "bl_title_raid", name = "Raid Captain", desc = "Cleared a crew raid, shoulder to shoulder with other players.", check = { when = { flags = { "bl_raid_cleared" } } }, before = "light" },
	{ id = "bl_title_legendary", name = "Keeper of a Legend", desc = "Came home carrying something legendary.", check = { when = { flags = { "bl_found_legendary" } } }, before = "light" },
	{ id = "bl_title_trophy", name = "Boss Hunter", desc = "Beat one of the City's named terrors, and lived to tell it.", check = { when = { flags = { "bl_trophy" } } } },
	{ id = "bl_title_self_taught", name = "Self-Taught", desc = "Learned an ability from a book that teaches.", check = { when = { flags = { "bl_ab_learned" } } } },
}
