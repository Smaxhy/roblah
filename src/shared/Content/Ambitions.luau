--[[
	Ambitions: goals a life works toward, three at a time. New ones are drawn as
	old ones are met, matched to age. Meeting one logs a celebration, adds to the
	life score, and applies its reward.

	Fields: id, name, desc, minAge, maxAge, weight (default 10), when (who can
	draw it), check (when it counts as met; same keys as Records), reward (a
	result), progress (for the HUD bar: { money = N } | { age = N } | { rank = N } |
	{ stat = "justice", target = N } | { tally = "clashesWon", target = N } |
	{ children = N }).
	Tallies: clashesWon, clashesLost, reckless, expeditions, ambitions, interactions.
]]

return {
	-- childhood
	{ id = "first_friend", name = "Someone in your corner", desc = "Make a friend.", minAge = 4, maxAge = 16, check = { when = { hasRelation = "friend" } }, reward = { sanity = 3, log = "Having a friend made the whole city smaller and safer." } },
	{ id = "book_learning", name = "Book learning", desc = "Reach 30 Temperance.", minAge = 6, maxAge = 18, check = { when = { min = { temperance = 30 } } }, progress = { stat = "temperance", target = 30 }, reward = { temperance = 2, log = "You can read a company ledger now, which is more than most adults." } },
	{ id = "scrapper", name = "Scrapper", desc = "Win 3 clashes.", minAge = 8, maxAge = 30, check = { tally = { clashesWon = 3 } }, progress = { tally = "clashesWon", target = 3 }, reward = { justice = 2, log = "Word got around: you don't back down." } },
	{ id = "steady_nerves", name = "Steady nerves", desc = "Reach 30 Prudence.", minAge = 8, maxAge = 25, check = { when = { min = { prudence = 30 } } }, progress = { stat = "prudence", target = 30 }, reward = { sanity = 3, log = "Things that used to frighten you just make you think now." } },
	{ id = "first_scrip", name = "First pocket money", desc = "Hold 50 scrip.", minAge = 6, maxAge = 15, check = { when = { min = { money = 50 } } }, progress = { money = 50 }, reward = { sanity = 2, log = "Fifty scrip, all yours. You counted it every night." } },

	-- youth and adult life
	{ id = "first_job", name = "Earn your keep", desc = "Get a job.", minAge = 14, maxAge = 45, check = { when = { anyCareer = true } }, reward = { wage = { 20, 40 }, log = "Your first proper wage. You spent some and hid the rest in your boot." } },
	{ id = "save_500", name = "Something put by", desc = "Hold 500 scrip at once.", minAge = 16, maxAge = 60, check = { when = { min = { money = 500 } } }, progress = { money = 500 }, reward = { sanity = 3, log = "A little money put by, for the first time. You slept better." } },
	{ id = "save_3000", name = "A real nest egg", desc = "Hold 3,000 scrip at once.", minAge = 20, maxAge = 75, check = { when = { min = { money = 3000 } } }, progress = { money = 3000 }, reward = { sanity = 4, log = "Three thousand scrip. People on your stair started asking you for advice." } },
	{ id = "promoted_twice", name = "Moving up", desc = "Reach rank 3 in any job.", minAge = 18, maxAge = 60, check = { when = { anyCareer = true, minRank = 3 } }, progress = { rank = 3 }, reward = { wage = { 40, 80 }, log = "Rank three. You have a desk, or a hook, or a key of your own now." } },
	{ id = "top_rank", name = "Top of the ladder", desc = "Reach rank 5 in any job.", minAge = 25, maxAge = 80, weight = 6, check = { when = { anyCareer = true, minRank = 5 } }, progress = { rank = 5 }, reward = { sanity = 6, log = "The top rank. Nobody above you but the weather." } },
	{ id = "charter_resident", name = "Behind the walls", desc = "Live in the Charter.", minAge = 18, maxAge = 70, when = { side = "gutters" }, check = { when = { side = "charter" } }, reward = { sanity = 4, log = "You live behind the walls now. The air smells different here." } },
	{ id = "fighter", name = "Hard to put down", desc = "Win 12 clashes.", minAge = 16, maxAge = 70, check = { tally = { clashesWon = 12 } }, progress = { tally = "clashesWon", target = 12 }, reward = { fortitude = 4, log = "Twelve fights won. You walk differently now." } },
	{ id = "expedition_one", name = "Out past the stairs", desc = "Finish an expedition.", minAge = 14, maxAge = 70, check = { tally = { expeditions = 1 } }, progress = { tally = "expeditions", target = 1 }, reward = { sanity = 3, log = "You went somewhere most people never go, and came back." } },
	{ id = "expedition_five", name = "Seasoned", desc = "Finish 5 expeditions.", minAge = 18, maxAge = 75, weight = 6, check = { tally = { expeditions = 5 } }, progress = { tally = "expeditions", target = 5 }, reward = { wage = { 60, 120 }, log = "Five expeditions. Crews ask for you by name." } },
	{ id = "people_person", name = "People person", desc = "Spend time with people 8 times.", minAge = 12, maxAge = 80, check = { tally = { interactions = 8 } }, progress = { tally = "interactions", target = 8 }, reward = { sanity = 4, log = "You kept up with people. They kept up with you." } },
	{ id = "parent", name = "Someone to raise", desc = "Take in a child.", minAge = 24, maxAge = 60, check = { minChildren = 1 }, progress = { children = 1 }, reward = { sanity = 5, log = "There's a small pair of boots by your door now." } },
	{ id = "big_family", name = "A full table", desc = "Raise three children.", minAge = 28, maxAge = 70, weight = 5, check = { minChildren = 3 }, progress = { children = 3 }, reward = { sanity = 6, log = "Three children at your table, all talking at once." } },
	{ id = "strong_body", name = "Built like a sluice gate", desc = "Reach 70 Fortitude.", minAge = 16, maxAge = 50, check = { when = { min = { fortitude = 70 } } }, progress = { stat = "fortitude", target = 70 }, reward = { justice = 2, log = "You could carry a coal sack up the switchback without stopping." } },
	{ id = "sharp_mind", name = "Sharp as a ledger", desc = "Reach 60 Temperance.", minAge = 16, maxAge = 70, check = { when = { min = { temperance = 60 } } }, progress = { stat = "temperance", target = 60 }, reward = { wage = { 30, 60 }, log = "People bring you their sums now, and pay you for the answers." } },
	{ id = "fair_hand", name = "A fair hand", desc = "Reach 60 Justice.", minAge = 16, maxAge = 70, check = { when = { min = { justice = 60 } } }, progress = { stat = "justice", target = 60 }, reward = { sanity = 3, log = "When there's a dispute on the stair, they send for you." } },
	{ id = "wanderer", name = "See the city", desc = "Move house twice.", minAge = 18, maxAge = 60, weight = 6, check = { minMoves = 2 }, reward = { prudence = 2, log = "You know more than one Ward from the inside now." } },
	{ id = "breach_hero", name = "Containment", desc = "Help contain a Tidewell breach.", minAge = 16, maxAge = 70, weight = 4, check = { when = { flags = { "contained_a_specimen" } } }, reward = { wage = { 80, 160 }, log = "The Institute sent a medal in a velvet box. It hums faintly." } },

	-- later life
	{ id = "elder", name = "Long in the tooth", desc = "Reach age 65.", minAge = 45, maxAge = 64, check = { when = { minAge = 65 } }, progress = { age = 65 }, reward = { sanity = 4, log = "Sixty-five. The stairs are steeper than they used to be, and so are you." } },
	{ id = "old_bones", name = "Very old bones", desc = "Reach age 80.", minAge = 62, maxAge = 79, check = { when = { minAge = 80 } }, progress = { age = 80 }, reward = { sanity = 6, log = "Eighty. Children come to look at you like a landmark." } },
	{ id = "line_of_three", name = "A family line", desc = "Be the third generation of your line.", minAge = 0, maxAge = 90, weight = 4, when = { flags = { "heir" } }, check = { minGeneration = 3 }, reward = { sanity = 4, log = "Three generations of your family have climbed these stairs." } },
}
