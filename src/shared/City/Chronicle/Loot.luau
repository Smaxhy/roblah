--[[
	Chronicle acts for bosses, raids and finds (bl_ ids). Echo events for every act are in
	Events/Loot_Echoes.luau.
]]

return {
	bl_act_boss_slain = { text = "{name} brought down one of {district}'s named terrors.", announce = false, tone = "danger" },
	bl_act_color_fallen = { text = "{name} beat the Ivory Verdict, a rogue Color, in {district}.", announce = true, tone = "accent" },
	bl_act_aleph_doused = { text = "{name} put out the Lamplighter, an ALEPH loose in {district}.", announce = true, tone = "strange" },
	bl_act_legendary_find = { text = "{name} came home to {district} carrying something legendary.", announce = false, tone = "good" },
	bl_act_unreal_find = { text = "{name} found something Unreal in {district}. Nobody believes it.", announce = true, tone = "accent" },
	bl_act_raid_cleared = { text = "{name}'s crew cleared the worst job on {district}'s board.", announce = false, tone = "good" },
	bl_act_outlasted_foreman = { text = "{name} outlasted the Foreman through all three waves of the Night in {district}.", announce = true, tone = "strange" },
	bl_act_reception_won = { text = "{name}'s crew walked out of a Library reception with their arms full of books.", announce = true, tone = "accent" },
}
