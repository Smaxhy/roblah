--[[
	Conditions from Fixer work and the Fingers. { [id] = def }; see Conditions/Core.luau.
]]

return {
	fn_thumb_interest = {
		name = "Thumb Interest",
		years = 3,
		curable = false,
		desc = "-15 Ahn a year: the interest on what you owe the Thumb.",
		gainLog = "The Thumb's ledger now has a line with your name on it, and a small number that grows every year.",
		healLog = "The last of the interest was paid. A Soldato ruled a neat line through your name in the ledger.",
		yearly = { money = -15 },
	},
	fn_ring_subject = {
		name = "Studied by the Ring",
		years = 1,
		curable = false,
		desc = "-2 Sanity this year, -1 base in Mental Strength checks. A Docent of the Ring is watching you for a portrait.",
		gainLog = "A Docent of the Ring is studying you for a portrait. You keep seeing the same patient face at the edge of crowds.",
		healLog = "The Docent stopped following you. Somewhere in a gallery, a portrait of you is finished.",
		yearly = { sanity = -2 },
		clash = { mind = { base = -1 } },
		look = "shadows",
	},
	fx_knowledge_spent = {
		name = "Spent Knowledge",
		years = 3,
		curable = false,
		desc = "-1 base in Intelligence checks. Something you used to know is gone.",
		gainLog = "You spent a piece of what you know to win, the way Dieci does. There is a clean, quiet hole where it used to be.",
		healLog = "You learned enough new things to stop noticing the hole.",
		clash = { intelligence = { base = -1 } },
	},
}
