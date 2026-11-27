--[[
	World events for Fixers and the Fingers (server-wide, a few minutes long). The Thumb's
	crackdown and Hana's exams already live in WorldEvents/Core.luau; these add a Color passing
	through and the Middle settling a grudge. Start events are in Events/Fixers_Echoes.luau and
	Events/Fingers_Middle.luau.
]]

return {
	order = { "fx_we_color", "fn_we_vengeance" },

	fx_we_color = {
		name = "A Color in the District",
		headline = "A COLOR FIXER HAS BEEN SEEN",
		text = "Word spreads from Office to Office: one of Hana's Colors is passing through today. Contracts are being cancelled, Rats have vanished from the alleys, and every Fixer in the District is on their very best behavior.",
		minutes = 6,
		weight = 2,
		tone = "strange",
		tagWeights = { fixers = 3 },
		startEvent = "fx_world_color",
		endText = "The Color has moved on. The Offices reopen, and the Rats come back out, sheepishly.",
	},
	fn_we_vengeance = {
		name = "The Middle remembers",
		headline = "THE MIDDLE IS SETTLING A GRUDGE",
		text = "Siblings of the Middle are going street by street with a heavy book, reading names aloud. Shutters are coming down all over the Backstreets.",
		minutes = 7,
		weight = 3,
		tone = "danger",
		tagWeights = { fingers = 4, crime = 1.3 },
		startEvent = "fn_world_vengeance",
		endText = "The Siblings close their Books and go home. Somewhere, a line has been drawn through a name.",
	},
}
