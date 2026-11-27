--[[
	Records: achievements a finished life can earn, kept on the player's shelf.
	{ id, name, desc, check = { when = {...}, bornSide, minPeakMoney, minMoves, minChildren, heir, tally } }
	Every module in Records/ returns a list; ids must be unique across files.
]]

return {
	{ id = "old_bones", name = "Old Bones", desc = "Live to 80 in the City.", check = { when = { minAge = 80 } } },
	{ id = "gone_too_soon", name = "Gone Too Soon", desc = "Die before 25.", check = { when = { maxAge = 24 } } },
	{ id = "through_the_wall", name = "Through the Wall", desc = "Born in the Backstreets, died in a Nest.", check = { bornSide = "backstreets", when = { side = "nest" } } },
	{ id = "fell_from_the_nest", name = "Fell from the Nest", desc = "Born in a Nest, died in the Backstreets.", check = { bornSide = "nest", when = { side = "backstreets" } } },
	{ id = "grade_one", name = "Grade 1", desc = "Die a Grade 1 Fixer.", check = { when = { career = "fixer", minRank = 9 } } },
	{ id = "color", name = "A Color of the City", desc = "Be named a Color Fixer.", check = { when = { flags = { "color_fixer" } } } },
	{ id = "sottocapo", name = "Sottocapo", desc = "Die a Sottocapo of the Thumb.", check = { when = { career = "thumb", minRank = 9 } } },
	{ id = "big_sibling", name = "Big Brother", desc = "Reach Big Brother or Big Sister in the Middle.", check = { when = { career = "middle", minRank = 2 } } },
	{ id = "branch_manager", name = "The Manager", desc = "Run an L Corp branch.", check = { when = { flags = { "lcorp_manager" } } } },
	{ id = "head_of_research", name = "Head of Research", desc = "Lead L Corp's research.", check = { when = { flags = { "lcorp_head_research" } } } },
	{ id = "survived_white_nights", name = "Saw the Light", desc = "Live through the White Nights and Dark Days.", check = { when = { flags = { "saw_white_nights" } } } },
	{ id = "booked", name = "Invited", desc = "Accept an invitation to the Library and come back.", check = { when = { flags = { "library_survivor" } } } },
	{ id = "ego", name = "E.G.O", desc = "Manifest E.G.O at your breaking point.", check = { when = { form = "ego" } } },
	{ id = "heavy_purse", name = "Heavy Purse", desc = "Hold 10,000 Ahn at once.", check = { minPeakMoney = 10000 } },
	{ id = "wanderer", name = "Wanderer", desc = "Move four times in one life.", check = { minMoves = 4 } },
	{ id = "family_line", name = "Family Line", desc = "Take in two children.", check = { minChildren = 2 } },
	{ id = "carried_on", name = "Carried On", desc = "Finish a life as someone's heir.", check = { heir = true } },
	{ id = "not_alone", name = "Not Alone", desc = "Link lives with a friend.", check = { when = { flags = { "had_linked" } } } },
}
