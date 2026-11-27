--[[
	World events of the Library and Distortion eras (writer D: lib_ / lim_ ids).
	Each is gated to its era with `when`. Opening scenes: Events/Limbus_Daily.luau.
]]

return {
	order = { "lib_great_reception", "lim_bus_in_town" },

	lib_great_reception = {
		name = "A great reception",
		headline = "THE LIBRARY'S LIGHTS ARE ON ALL NIGHT",
		text = "A whole Association Section accepted their invitations at once. Every Floor of the tower in District 12 is lit, and the whole City is watching it.",
		minutes = 6,
		weight = 2,
		tone = "strange",
		when = { world = { era = "library" } },
		tagWeights = { library = 5 },
		startEvent = "lib_world_reception",
		endText = "At dawn the Library's lights go out one Floor at a time. Nobody comes out to say how it went.",
	},
	lim_bus_in_town = {
		name = "The bus is in town",
		headline = "A BUS THAT IS ALSO A TRAIN IS PARKED ACROSS THREE LANES",
		text = "Limbus Company's bus, Mephistopheles, has stopped in the City. LCCB scouts are everywhere, and the access tunnels down to the buried L Corp branches are open.",
		minutes = 7,
		weight = 3,
		tone = "strange",
		when = { world = { era = "limbus" } },
		tagWeights = { limbus = 4, bough = 4 },
		startEvent = "lim_world_bus",
		endText = "The bus pulls out faster than anything that size should. The tunnels are sealed by evening.",
	},
}
