--[[
	Today in the City, from the Wings and L Corp's world. Same fields as Daily/Core.luau:
	name, desc (shown in the City panel), event (a weight = 0 event in Events/LCorp_Daily.luau).
	These work in every era and every District.
]]

return {
	order = { "lc_green_kettle_day", "wg_inspection_day", "wg_time_audit_day" },
	lc_green_kettle_day = { name = "The Green Kettle's Birthday", desc = "District 12's old teahouse, where L Corp people used to drink tea, is pouring free cups all day under its wall of photographs.", eras = { "library", "limbus" }, event = "lc_dly_green_kettle" },
	wg_inspection_day = { name = "Inspection Day", desc = "Inspectors in Wing uniforms are checking every stall permit and residence card in the Backstreets.", event = "wg_dly_inspection" },
	wg_time_audit_day = { name = "The Time Audit", desc = "T Corp's Collection Staff are out in every District, timepieces ticking, collecting Time Tax arrears.", event = "wg_dly_time_audit" },
}
