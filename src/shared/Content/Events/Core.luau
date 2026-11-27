--[[
	Core events: the engine fires some of these on its own (see pack.hooks).
	Keep these ids if you replace the content pack, or update pack.hooks.
]]

return {
	{
		id = "core_breaking_point",
		title = "Going Under",
		text = "There's no bottom to it anymore. Every sound in your head is water closing over a lantern. Somewhere far above you there's a surface, if you can still find it.",
		weight = 0,
		choices = {
			{
				label = "Hold on to who you are",
				hint = "Prudence clash. Your coins flip fair here.",
				clash = { stat = "prudence", foe = "The Undertow", coins = 2, base = 5, coinPower = 3, ignoreSanity = true },
				win = {
					form = "surfaced",
					sanity = 60,
					prudence = 5,
					setFlags = { "surfaced" },
					log = "You came up gasping, holding on to something new. You have Surfaced.",
				},
				lose = {
					form = "drowned",
					die = "Went under, and stayed there",
					log = "The Mere closed over you. Somewhere below, a new shape stands quietly in the deep water.",
				},
			},
			{
				label = "Hold on to the people who need you",
				hint = "Easier, if there's still someone to hold on to.",
				requires = { hasRelation = { "child", "mother", "father", "sibling", "friend", "mentor" } },
				clash = { stat = "prudence", foe = "The Undertow", coins = 1, base = 4, coinPower = 3, ignoreSanity = true },
				win = {
					form = "surfaced",
					sanity = 60,
					relationBond = { kind = "all", amount = 15 },
					setFlags = { "surfaced" },
					log = "You thought of their faces and kicked upward until you broke the surface. You have Surfaced.",
				},
				lose = {
					form = "drowned",
					die = "Went under, and stayed there",
					log = "Their faces went dim. The Mere closed over you.",
				},
			},
		},
	},
	{
		id = "core_debt_collector",
		title = "The Ledger Comes Due",
		text = "A Brine Kin boatman is sitting on your stairs, peeling an orange with a hooked knife. \"You're in the red, cousin. The Kin don't like red.\"",
		weight = 60,
		cooldown = 2,
		when = { minAge = 16, max = { money = -1 } },
		choices = {
			{
				label = "Work it off on the boats",
				result = { money = 45, fortitude = { -8, -4 }, sanity = -3, setFlags = { "worked_for_brine" }, log = "You spent a season rowing Brine Kin cargo through the drowned streets to clear your name." },
			},
			{
				label = "Talk your way out",
				clash = { stat = "prudence", foe = "Brine boatman", coins = 2, base = 3, coinPower = 3 },
				win = { money = 20, log = "You talked so long and so well that he forgave half of it just to make you stop." },
				lose = { money = -15, sanity = -4, log = "Your excuses only added interest." },
			},
			{
				label = "Throw him off the stairs",
				clash = { stat = "justice", foe = "Brine boatman", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, setFlags = { "brine_grudge" }, log = "He went down the stairs faster than he came up. The Kin will remember this." },
				lose = { fortitude = { -14, -8 }, money = -20, log = "He was better with the knife than with the orange.", cause = "Settled a debt the hard way" },
			},
		},
	},
}
