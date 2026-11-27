--[[
	Conditions from the Distortion era (writer D: lim_ ids). See Conditions/Core.luau for fields.
]]

return {
	lim_attunement_strain = {
		name = "Attunement Strain",
		years = 2,
		desc = "-1 Sanity a year, -1 base in Mental Strength clashes. E.G.O gear tuned itself to you, and you to it.",
		gainLog = "The test gear's voice is still in your head. You caught yourself using its words at dinner.",
		healLog = "The gear's voice finally went quiet. Your words are your own again.",
		yearly = { sanity = -1 },
		clash = { mind = { base = -1 } },
		look = "shadows",
	},
	lim_bough_echo = {
		name = "A Memory Not Yours",
		years = 2,
		curable = false,
		desc = "+1 base in Intelligence clashes, -1 Sanity a year. Someone else's memory is living in yours, and it brought a skill.",
		gainLog = "You remember a childhood you never had, very clearly: a cold room, a song, a pair of hands that knew how to fix things.",
		healLog = "The borrowed memory faded, and took its little skill with it.",
		yearly = { sanity = -1 },
		clash = { intelligence = { base = 1 } },
		look = "pale",
	},
	lim_mirror_lag = {
		name = "Mirror Lag",
		years = 1,
		desc = "-2 Sanity this year. Your reflection is half a second late.",
		gainLog = "Your reflection waved a moment after you did. You stopped looking in shop windows.",
		healLog = "Your reflection keeps up with you again. You check, sometimes.",
		yearly = { sanity = -2 },
		look = "shadows",
	},
}
