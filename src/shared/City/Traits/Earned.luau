--[[
	EARNED TRAITS (v0.18, tr18_ ids): what a life grows into. Nobody picks these and no card
	hands them out: each comes by itself the year its `earn` holds (Engine/Feats.luau,
	earnTraits), with a line in that year's feed. The need keys are the feats' own: age, money,
	peakMoney, renown (grade), stat, anyStat, allStats, flags, episodes, cases, blocks, office,
	home, children, closeFriends, married, uniques, legendary, delves, form, careerTop, lives,
	clashes (won).
]]

return {
	order = {
		-- fighting
		"tr18_brawler", "tr18_veteran", "tr18_hundred_fights", "tr18_grey_wolf",
		-- standing
		"tr18_name_on_the_street", "tr18_feared", "tr18_legend_of_the_district", "tr18_top_of_the_ladder", "tr18_office_head",
		-- the work of a life
		"tr18_case_cracker", "tr18_turf_boss", "tr18_delver", "tr18_storyteller", "tr18_collector", "tr18_legendary_kit",
		-- money
		"tr18_saver", "tr18_old_money",
		-- people
		"tr18_streetwise", "tr18_beloved", "tr18_someone_to_come_home_to", "tr18_parent", "tr18_full_table", "tr18_old_family",
		-- years
		"tr18_homebody", "tr18_old_hand", "tr18_survivor", "tr18_old_kindred",
		-- a body and a mind past their limits
		"tr18_iron_body", "tr18_unreal_strength", "tr18_flash", "tr18_genius", "tr18_magnetic", "tr18_luck_of_the_damned",
		"tr18_unshakable", "tr18_well_rounded", "tr18_at_the_peak",
	},

	-- ── fighting ──
	tr18_brawler = { name = "Brawler", desc = "Fifteen fights won. You know how they go now. +1 base in fights.", earn = { clashes = 15 }, fight = { base = 1 } },
	tr18_veteran = { name = "Veteran", desc = "Sixty fights won. Your body moves before you tell it to. +1 coin in fights.", earn = { clashes = 60 }, fight = { coins = 1 } },
	tr18_hundred_fights = { name = "A Hundred and Fifty Fights", desc = "People step aside when you walk into a room. +2 base and +1 potency in fights.", earn = { clashes = 150 }, fight = { base = 2, potency = 1 } },
	tr18_grey_wolf = { name = "Grey Wolf", desc = "Old, and still fighting, and still winning. That's the dangerous kind. +2 base in fights, +3% heads chance.", earn = { age = 60, clashes = 40 }, fight = { base = 2 }, heads = 3 },

	-- ── standing ──
	tr18_name_on_the_street = { name = "A Name on the Street", desc = "Shopkeepers know who you are. +1 base in Charisma checks.", earn = { renown = 2 }, clash = { charisma = { base = 1 } } },
	tr18_feared = { name = "Feared", desc = "Some people cross the street when they see you. +1 base in fights and Charisma checks, -3 Sanity.", earn = { renown = 4 }, fight = { base = 1 }, clash = { charisma = { base = 1 } }, sanity = -3 },
	tr18_legend_of_the_district = { name = "Legend of the District", desc = "Children play at being you. +1 coin in every clash.", earn = { renown = 6 }, clash = { any = { coins = 1 } } },
	tr18_top_of_the_ladder = { name = "Top of the Ladder", desc = "You reached the top of your trade, and you know how you did it. +3 Charisma, +3 Intelligence.", earn = { careerTop = true }, stats = { charisma = 3, intelligence = 3 } },
	tr18_office_head = { name = "Runs an Office", desc = "Contracts, staff, rent, reputations: you hold it all together. +1 base in Charisma and Intelligence checks.", earn = { office = 3 }, clash = { charisma = { base = 1 }, intelligence = { base = 1 } } },

	-- ── the work of a life ──
	tr18_case_cracker = { name = "Case Cracker", desc = "Three cases closed. You see the thread everyone else misses. +1 coin in Intelligence checks.", earn = { cases = 3 }, clash = { intelligence = { coins = 1 } } },
	tr18_turf_boss = { name = "Turf Boss", desc = "Four blocks held. The street pays its respects. +1 base in fights, +3 Charisma.", earn = { blocks = 4 }, fight = { base = 1 }, stats = { charisma = 3 } },
	tr18_delver = { name = "Delver", desc = "Three times into the dark, three times back out. +1 base in Mental Strength checks, +3% heads chance.", earn = { delves = 3 }, clash = { mind = { base = 1 } }, heads = 3 },
	tr18_storyteller = { name = "Storyteller", desc = "Five stories seen to their end. People ask you to tell them again. +2 Charisma, +2 Intelligence.", earn = { episodes = 5 }, stats = { charisma = 2, intelligence = 2 } },
	tr18_collector = { name = "Collector", desc = "Three one-of-a-kind things on your shelves. +2% heads chance, +2 Luck.", earn = { uniques = 3 }, heads = 2, stats = { luck = 2 } },
	tr18_legendary_kit = { name = "Legendary Kit", desc = "You own something the City tells stories about. +3% heads chance.", earn = { legendary = 1 }, heads = 3 },

	-- ── money ──
	tr18_saver = { name = "Saver", desc = "You once held ten thousand Ahn and didn't spend it. +2 Intelligence, +2% heads chance.", earn = { peakMoney = 10000 }, stats = { intelligence = 2 }, heads = 2 },
	tr18_old_money = { name = "Old Money", desc = "A hundred thousand Ahn, once. The Nest's doormen nod at you now. +4 Charisma, +3% heads chance.", earn = { peakMoney = 100000 }, stats = { charisma = 4 }, heads = 3 },

	-- ── people ──
	tr18_streetwise = { name = "Streetwise", desc = "Grown up, and still charming the whole block. +1 base in Charisma checks, +2 Speed.", earn = { age = 21, stat = { charisma = 40 } }, clash = { charisma = { base = 1 } }, stats = { speed = 2 } },
	tr18_beloved = { name = "Beloved", desc = "Three people would cross the City for you. +1 base in Charisma checks, +6 Sanity.", earn = { closeFriends = 3 }, clash = { charisma = { base = 1 } }, sanity = 6 },
	tr18_someone_to_come_home_to = { name = "Someone to Come Home To", desc = "There's a light on when you get back. +6 Sanity, +2 Mental Strength.", earn = { married = true }, sanity = 6, stats = { mind = 2 } },
	tr18_parent = { name = "Parent", desc = "Somebody small depends on you now, and you have never been so careful. +6 Sanity, +2 Mental Strength.", earn = { children = 1 }, sanity = 6, stats = { mind = 2 } },
	tr18_full_table = { name = "A Full Table", desc = "Three children round the table, and the noise of them. +1 base in Mental Strength checks.", earn = { children = 3 }, clash = { mind = { base = 1 } } },
	tr18_old_family = { name = "Old Family", desc = "Three generations on the same streets. +2% heads chance, +200 Ahn.", earn = { lives = 3 }, heads = 2, money = 200 },

	-- ── years ──
	tr18_homebody = { name = "Homebody", desc = "Thirty, with a roof of your own and a kettle that's yours. +8 Sanity.", earn = { age = 30, home = true }, sanity = 8 },
	tr18_old_hand = { name = "Old Hand", desc = "Fifty years in the City. Very little surprises you. +1 base in Intelligence and Mental Strength checks.", earn = { age = 50 }, clash = { intelligence = { base = 1 }, mind = { base = 1 } } },
	tr18_survivor = { name = "Survivor", desc = "Seventy years in the City, which almost nobody manages. You take 10% less Health damage.", earn = { age = 70 }, toughness = 0.9 },
	tr18_old_kindred = { name = "Old Kindred", desc = "A hundred and twenty years old, and the Night is an old friend. +1 coin in fights, +10 Sanity.", earn = { form = "bloodfiend", age = 120 }, fight = { coins = 1 }, sanity = 10 },

	-- ── a body and a mind past their limits ──
	tr18_iron_body = { name = "Iron Body", desc = "150 Health. You take 10% less Health damage.", earn = { stat = { health = 150 } }, toughness = 0.9 },
	tr18_unreal_strength = { name = "Unreal Strength", desc = "150 Strength: doors are optional now. +1 coin in Strength checks and fights.", earn = { stat = { strength = 150 } }, clash = { strength = { coins = 1 } } },
	tr18_flash = { name = "Flash", desc = "150 Speed. +1 coin in Speed checks and fights.", earn = { stat = { speed = 150 } }, clash = { speed = { coins = 1 } } },
	tr18_genius = { name = "Brilliant", desc = "150 Intelligence. +1 coin in Intelligence checks.", earn = { stat = { intelligence = 150 } }, clash = { intelligence = { coins = 1 } } },
	tr18_magnetic = { name = "Magnetic", desc = "150 Charisma. +1 coin in Charisma checks.", earn = { stat = { charisma = 150 } }, clash = { charisma = { coins = 1 } } },
	tr18_luck_of_the_damned = { name = "Impossible Luck", desc = "150 Luck. +4% heads chance in everything.", earn = { stat = { luck = 150 } }, heads = 4 },
	tr18_unshakable = { name = "Unshakable", desc = "150 Mental Strength. +1 coin in Mental Strength checks.", earn = { stat = { mind = 150 } }, clash = { mind = { coins = 1 } } },
	tr18_well_rounded = { name = "Well-Rounded", desc = "Every stat past 80. +1 base in every clash.", earn = { allStats = 80 }, clash = { any = { base = 1 } } },
	tr18_at_the_peak = { name = "At the Peak", desc = "One stat at 250: past where most of the City stops counting. +1 coin in every clash.", earn = { anyStat = 250 }, clash = { any = { coins = 1 } } },
}
