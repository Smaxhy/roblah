--[[
	Titles: every finished life gets one (its book's title, the death screen, the
	rankings). Checked top to bottom; the first that passes wins. The last catches all.
]]

return {
	{ id = "distorted", name = "A Distortion", desc = "Went over the edge and became something the City sent Fixers after.", check = { when = { form = "distorted" } } },
	{ id = "book", name = "A Book in the Library", desc = "Accepted an invitation and became a book.", check = { causeHas = "book" } },
	{ id = "color", name = "A Color of the City", desc = "Hana gave them a Color. Every Fixer knew their name.", check = { when = { flags = { "color_fixer" } } } },
	{ id = "ego", name = "Wielder of E.G.O", desc = "Looked their own distortion in the eye and took hold of it.", check = { when = { form = "ego" } } },
	{ id = "manager", name = "The Manager", desc = "Ran an L Corp branch from the top.", check = { when = { flags = { "lcorp_manager" } } } },
	{ id = "head_research", name = "Head of Research", desc = "Led Lobotomy Corporation's research.", check = { when = { flags = { "lcorp_head_research" } } } },
	{ id = "sottocapo", name = "Sottocapo", desc = "Rose to the top of the Thumb in their District.", check = { when = { career = "thumb", minRank = 9 } } },
	{ id = "great_sibling", name = "Great Brother of the Middle", desc = "The Middle's family answered to them.", check = { when = { career = "middle", minRank = 3 } } },
	{ id = "maestro", name = "Maestro of the Ring", desc = "Founded a movement of their own.", check = { when = { career = "ring", minRank = 3 } } },
	{ id = "grade_one", name = "Grade 1 Fixer", desc = "As high as the scale goes.", check = { when = { career = "fixer", minRank = 9 } } },
	{ id = "director", name = "The Executive", desc = "Sat at the top of a Wing.", check = { when = { career = "wing", minRank = 5 } } },
	{ id = "light", name = "Saw the Light", desc = "Lived through the White Nights and Dark Days.", check = { when = { flags = { "saw_white_nights" } } } },
	{ id = "gilded", name = "Rich as a Nest", desc = "Held more Ahn than most Districts see in a year.", check = { minPeakMoney = 20000 } },
	{ id = "wall_climber", name = "Through the Wall", desc = "Born in the Backstreets, died in a Nest with money to spare.", check = { bornSide = "backstreets", minPeakMoney = 5000, when = { side = "nest" } } },
	{ id = "crew_legend", name = "Crew Legend", desc = "Came back from more expeditions than anyone can count.", check = { tally = { expeditions = 8 } } },
	{ id = "undying", name = "The Undying", desc = "Outlived nearly everyone they ever knew.", check = { when = { minAge = 88 } } },
	{ id = "family_head", name = "Head of the Family", desc = "Raised a table full of children.", check = { minChildren = 3 } },
	{ id = "line_keeper", name = "Keeper of the Line", desc = "A third generation or more of the same family.", check = { minGeneration = 3 } },
	{ id = "unbowed", name = "The Unbowed", desc = "Won fight after fight after fight.", check = { tally = { fightsWon = 25 } } },
	{ id = "reckless", name = "All Gas, No Brakes", desc = "Went in reckless more times than was wise.", check = { tally = { reckless = 15 } } },
	{ id = "wanderer", name = "The Wanderer", desc = "Never stayed in one District for long.", check = { minMoves = 4 } },
	{ id = "gone_soon", name = "Gone Too Soon", desc = "The City didn't give them long.", check = { when = { maxAge = 24 } } },
	{ id = "beloved", name = "Beloved", desc = "Kept close to the people who mattered.", check = { tally = { interactions = 25 } } },
	{ id = "long_life", name = "A Long, Full Life", desc = "Lived to see their hair go white.", check = { when = { minAge = 75 } } },
	{ id = "quiet", name = "A Quiet Life", desc = "Got up, went to work, came home before three. That's not nothing." },
}
