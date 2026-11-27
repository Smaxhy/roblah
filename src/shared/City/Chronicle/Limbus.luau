--[[
	Chronicle acts for the Library and Distortion eras (writer D: lib_ / lim_ ids).
	Each act has at least one echo event for other players (when = { chronicle = "act" }):
	see Events/Library_Echoes.luau and Events/Limbus_Echoes.luau.
	Tones: "news" (default), "good", "danger", "strange", "accent".
]]

return {
	-- the Library era
	lib_talked_out = { text = "{name} talked someone they love out of accepting an invitation to the Library.", announce = false, tone = "good" },
	lib_ensemble_heard = { text = "{name} heard a strange ensemble playing in {district} at night, and walked away whole.", announce = false, tone = "strange" },
	lib_book_returned = { text = "{name} carried a book from the Library home to the family of the person in it.", announce = true, tone = "good" },

	-- the Distortion era
	lim_talked_down = { text = "{name} talked a Distortion back from the edge in {district}.", announce = true, tone = "strange" },
	lim_bough_found = { text = "{name} found a Golden Bough buried under {district}.", announce = true, tone = "accent" },
	lim_peccatula_cleared = { text = "{name} cleared a nest of Peccatula out of an empty lot in {district}.", announce = false, tone = "good" },
	lim_lccb_manager = { text = "{name} made Manager in Limbus Company's Before Team, and is hiring.", announce = false, tone = "news" },
}
