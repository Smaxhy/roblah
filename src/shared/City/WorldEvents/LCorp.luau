--[[
	World events from L Corp's world, in the age of the Wings. The core breach
	(abnormality_breach, with world_breach_sirens) is in WorldEvents/Core.luau; events in
	Events/LCorp_Outside.luau also roll while it's on. Opening scenes: Events/LCorp_Daily.luau.
	Fields: name, headline, text, minutes, weight, tone, district, when, tagWeights,
	startEvent, expedition, endText.
]]

return {
	order = { "lc_hiring_drive", "lc_blackout" },

	lc_hiring_drive = {
		name = "L Corp is hiring",
		headline = "LOBOTOMY CORPORATION IS HIRING",
		text = "Green posters are going up in every District: FACE THE FEAR, BUILD THE FUTURE. L Corp's recruiters are on every WARP platform, with relocation paid and a salary nobody believes.",
		minutes = 7,
		weight = 2,
		district = "d12",
		when = { world = { era = "wings" } },
		tagWeights = { lcorp = 2 },
		startEvent = "lc_world_hiring_start",
		endText = "The recruiters fold up their tables. The posters stay up for months.",
	},
	lc_blackout = {
		name = "The green lights flicker",
		headline = "THE GREEN LIGHTS ARE FLICKERING",
		text = "Something has gone wrong at L Corp's facility. The City's energy supply is dipping in every District at once, the streetlights are flickering green, and the radios are telling everyone to stay calm.",
		minutes = 6,
		weight = 2,
		tone = "strange",
		district = "d12",
		when = { world = { era = "wings" } },
		tagWeights = { lcorp = 2, ordeal = 4 },
		startEvent = "lc_world_blackout_start",
		endText = "The lights steady. L Corp issues a statement about routine maintenance. Nobody believes it.",
	},
}
