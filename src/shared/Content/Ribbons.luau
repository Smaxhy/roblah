--[[
	Titles: every finished life gets one, shown on its lantern, the death screen
	and the leaderboards. Checked top to bottom; the first whose check passes wins.
	The last one has no check and catches everyone else.
	check uses the same keys as Records (when, bornSide, minPeakMoney, minPeakRank,
	minMoves, heir, causeHas, minChildren, minGeneration, tally).
]]

return {
	{ id = "drowned", name = "Claimed by the Mere", desc = "The water took them, in the end.", check = { when = { form = "drowned" } } },
	{ id = "surfaced", name = "The One Who Surfaced", desc = "Went to the bottom of themselves and came back holding something.", check = { when = { form = "surfaced" } } },
	{ id = "gilded", name = "The Gilded", desc = "Held more scrip than most Wards see in a year.", check = { minPeakMoney = 20000 } },
	{ id = "containment", name = "Specimen Hunter", desc = "Brought something terrible back into the Tidewell vaults.", check = { when = { flags = { "contained_a_specimen" } }, tally = { expeditions = 3 } } },
	{ id = "captain", name = "Lantern-Captain", desc = "Led the Lantern Guild down into the deep.", check = { when = { career = "diver", minRank = 5 } } },
	{ id = "director", name = "The Director", desc = "Ran a Ward's company from the top floor.", check = { when = { career = "company", minRank = 5 } } },
	{ id = "kin_elder", name = "Elder of the Kin", desc = "The Brine Kin answered to them.", check = { when = { career = "brine", minRank = 5 } } },
	{ id = "still_voice", name = "The Still Voice", desc = "Sang the city to sleep from the Choir's highest seat.", check = { when = { career = "choir", minRank = 4 } } },
	{ id = "gutter_royalty", name = "Gutter Royalty", desc = "Born on the bottom step, died behind the walls with money to spare.", check = { bornSide = "gutters", minPeakMoney = 5000, when = { side = "charter" } } },
	{ id = "crew_legend", name = "Crew Legend", desc = "Came back from more expeditions than anyone can count.", check = { tally = { expeditions = 8 } } },
	{ id = "undying", name = "The Undying", desc = "Outlived nearly everyone they ever knew.", check = { when = { minAge = 88 } } },
	{ id = "matriarch", name = "Head of the Family", desc = "Raised a table full of children.", check = { minChildren = 3 } },
	{ id = "line_keeper", name = "Keeper of the Line", desc = "A third generation or more of the same family.", check = { minGeneration = 3 } },
	{ id = "tidetouched", name = "Tidetouched", desc = "The Mere got into their blood and never left.", check = { when = { form = "tidetouched" } } },
	{ id = "brawler", name = "The Unbowed", desc = "Won fight after fight after fight.", check = { tally = { clashesWon = 40 } } },
	{ id = "reckless", name = "All Gas, No Brakes", desc = "Went in reckless more times than was wise.", check = { tally = { reckless = 15 } } },
	{ id = "wanderer", name = "The Wanderer", desc = "Never stayed in one Ward for long.", check = { minMoves = 4 } },
	{ id = "gone_soon", name = "Gone Too Soon", desc = "The city didn't give them long.", check = { when = { maxAge = 24 } } },
	{ id = "beloved", name = "Beloved", desc = "Kept close to the people who mattered.", check = { tally = { interactions = 25 } } },
	{ id = "long_life", name = "A Long, Full Life", desc = "Lived to see their hair go white.", check = { when = { minAge = 75 } } },
	{ id = "quiet", name = "A Quiet Life", desc = "Got up, went to work, came home. That's not nothing." },
}
