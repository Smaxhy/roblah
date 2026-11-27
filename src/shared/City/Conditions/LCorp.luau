--[[
	Conditions from L Corp's units and the things that got out of them.
	Fields: name, years, curable, desc, gainLog, healLog, yearly, clash, look.
	Every module in Conditions/ returns { [id] = def }; ids must be unique.
]]

return {
	-- Fairy Festival: healing, and a reason never to visit another unit afterward
	lc_fairy_care = {
		name = "The Fairies' Care",
		years = 2,
		curable = false,
		desc = "+1 Health a year. The fairies are watching over you, and watching where you go.",
		gainLog = "Tiny wings hum by your ear wherever you go. The fairies have decided you're theirs.",
		healLog = "One morning the humming had stopped. The fairies had found someone else to care for.",
		yearly = { health = 1 },
	},
	-- the Plague Doctor's blessing (see lc_abno_plague_doctor, lc_abno_whitenight)
	lc_blessed = {
		name = "Blessed",
		years = 6,
		curable = false,
		desc = "+1 Sanity a year. Somewhere, a doctor is counting.",
		gainLog = "A great black wing rested on your shoulder, and a calm voice blessed you. You have never felt so well.",
		healLog = "The blessing faded. You realize you stopped hearing the counting a while ago.",
		yearly = { sanity = 1 },
	},
	-- what a bad day in a high-risk unit leaves behind
	lc_shaken = {
		name = "Shaken",
		years = 2,
		desc = "-1 Sanity a year, -1 base in Mental Strength checks.",
		gainLog = "You saw something in that unit you can't stop seeing. It's there when you close your eyes.",
		healLog = "One night you slept straight through. The thing from the unit had finally gone quiet.",
		yearly = { sanity = -1 },
		clash = { mind = { base = -1 } },
		look = "shadows",
	},
	-- the red shoes in a market stall (an outsider's Abnormality story)
	lc_red_shoes_longing = {
		name = "Longing for the Red Shoes",
		years = 3,
		curable = false,
		desc = "-1 Sanity a year. You keep thinking about a pair of red shoes.",
		gainLog = "You walked away from the stall. Your feet keep trying to walk you back.",
		healLog = "You passed a shoe shop today and felt nothing at all. It was wonderful.",
		yearly = { sanity = -1 },
	},
}
