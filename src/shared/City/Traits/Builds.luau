--[[
	Style traits: pickable traits that only work with their own fighting style (`style = id`).
	They're how a build comes together: a Tremor build takes Aftershock, a Poise build takes
	Measured Breath, and so on. Picked with the wrong style, they do nothing in a fight.
	The creator's build presets (pack.buildPresets in init.luau) pair each with a style.
]]

return {
	order = { "st_aftershock", "st_crack_open", "st_deep_cuts", "st_kindling", "st_undertow", "st_measured_breath", "st_capacitor" },

	st_aftershock = {
		name = "Aftershock",
		desc = "Tremor style only. Every blow keeps shaking after it lands: +1 Tremor potency and +1 power per heads in fights.",
		pick = true,
		category = "style",
		style = "tremor",
		fight = { potency = 1, coinPower = 1 },
	},
	st_crack_open = {
		name = "Crack Them Open",
		desc = "Rupture style only. You find the seam and widen it: +1 Rupture potency and +1 base in fights.",
		pick = true,
		category = "style",
		style = "rupture",
		fight = { potency = 1, base = 1 },
	},
	st_deep_cuts = {
		name = "Deep Cuts",
		desc = "Bleed style only. Wounds that don't close on their own: +1 Bleed potency and +1 base in fights.",
		pick = true,
		category = "style",
		style = "bleed",
		fight = { potency = 1, base = 1 },
	},
	st_kindling = {
		name = "Kindling",
		desc = "Burn style only. Everything you touch catches: +1 Burn potency and +1 base in fights.",
		pick = true,
		category = "style",
		style = "burn",
		fight = { potency = 1, base = 1 },
	},
	st_undertow = {
		name = "Undertow",
		desc = "Sinking style only. They feel the floor go out from under them: +1 Sinking potency and +1 power per heads in fights.",
		pick = true,
		category = "style",
		style = "sinking",
		fight = { potency = 1, coinPower = 1 },
	},
	st_measured_breath = {
		name = "Measured Breath",
		desc = "Poise style only. In, out, strike: +2 Poise potency in fights, so your crits come sooner.",
		pick = true,
		category = "style",
		style = "poise",
		fight = { potency = 2 },
	},
	st_capacitor = {
		name = "Capacitor",
		desc = "Charge style only. You hold more before you let go: +1 Charge potency and +1 base in fights.",
		pick = true,
		category = "style",
		style = "charge",
		fight = { potency = 1, base = 1 },
	},
}
