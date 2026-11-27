--[[
	FEATS (v0.13): the long goals of a life (Engine/Feats.luau). Bronze ones most grown lives
	reach; silver takes a real life; gold takes a remarkable one; mythic is what the City tells
	stories about. A few break a limit (limitBreak): the stats of that life can climb past
	where they used to stop. Feats are kept on the server for every life you've lived.
	need keys: see Engine/Feats.luau.
]]

return {
	tiers = {
		bronze = { name = "Bronze", color = { 196, 142, 92 } },
		silver = { name = "Silver", color = { 196, 204, 214 } },
		gold = { name = "Gold", color = { 240, 196, 92 } },
		mythic = { name = "Mythic", color = { 222, 96, 140 } },
	},
	order = {
		-- bronze
		"ft_eighteen", "ft_licence", "ft_street_name", "ft_own_roof", "ft_four_thousand", "ft_first_block", "ft_first_case",
		"ft_old_enemy", "ft_into_dark", "ft_ten_wins", "ft_household", "ft_first_episode",
		-- silver
		"ft_myth", "ft_half_street", "ft_twenty_thousand", "ft_known_office", "ft_three_cases", "ft_fifty_wins", "ft_sixty",
		"ft_five_episodes", "ft_top_rank", "ft_full_table", "ft_all_fifty", "ft_five_delves", "ft_two_rivals", "ft_hundred_stat",
		-- gold
		"ft_nightmare", "ft_whole_district", "ft_hundred_thousand", "ft_great_office", "ft_every_case", "ft_past_ceiling",
		"ft_two_hundred_wins", "ft_ten_episodes", "ft_legendary", "ft_collector", "ft_eighty", "ft_third_generation", "ft_color",
		-- mythic
		"ft_star", "ft_impurity", "ft_all_hundred", "ft_past_every_limit", "ft_million", "ft_unbroken_line", "ft_streets_and_seat",
		"ft_every_episode",
	},

	-- ── bronze ──
	ft_eighteen = { name = "Made It to Eighteen", desc = "Grow up in the City. Not everyone does.", tier = "bronze", need = { age = 18 } },
	ft_licence = { name = "A Licence on the Wall", desc = "Get a Fixer's licence from the Hana Association.", tier = "bronze", need = { flags = { "licensed_fixer" } } },
	ft_street_name = { name = "Somebody on the Street", desc = "Reach the first renown grade.", tier = "bronze", need = { renown = 1 } },
	ft_own_roof = { name = "A Roof of Your Own", desc = "Buy a home.", tier = "bronze", need = { home = true } },
	ft_four_thousand = { name = "Four Thousand Ahn", desc = "Hold 4,000 Ahn at once.", tier = "bronze", need = { money = 4000 } },
	ft_first_block = { name = "A Block of Your Own", desc = "Take a block in a turf war.", tier = "bronze", need = { blocks = 1 } },
	ft_first_case = { name = "Case Closed", desc = "Close a case.", tier = "bronze", need = { cases = 1 } },
	ft_old_enemy = { name = "Old Enemies", desc = "Make a friend of a rival.", tier = "bronze", need = { flags = { "former_rival" } } },
	ft_into_dark = { name = "Into the Dark", desc = "Come back from a delve or an expedition.", tier = "bronze", need = { delves = 1 } },
	ft_ten_wins = { name = "Ten Wins", desc = "Win ten fights.", tier = "bronze", need = { clashes = 10 } },
	ft_household = { name = "One Door, Two Names", desc = "Share a household with someone.", tier = "bronze", need = { flags = { "has_partner" } } },
	ft_first_episode = { name = "A Story to Tell", desc = "See an episode through to its end.", tier = "bronze", need = { episodes = 1 } },

	-- ── silver ──
	ft_myth = { name = "Urban Myth", desc = "Be graded an Urban Myth by Hana.", tier = "silver", need = { renown = 3 } },
	ft_half_street = { name = "Half the Street", desc = "Hold three blocks of your District at once.", tier = "silver", need = { blocks = 3 } },
	ft_twenty_thousand = { name = "Twenty Thousand", desc = "Hold 20,000 Ahn at once.", tier = "silver", need = { money = 20000 } },
	ft_known_office = { name = "A Known Office", desc = "Grow your own Office to its third size.", tier = "silver", need = { office = 3 } },
	ft_three_cases = { name = "Three Files Closed", desc = "Close three cases in one life.", tier = "silver", need = { cases = 3 } },
	ft_fifty_wins = { name = "Fifty Wins", desc = "Win fifty fights.", tier = "silver", need = { clashes = 50 } },
	ft_sixty = { name = "Sixty Winters", desc = "Live to sixty.", tier = "silver", need = { age = 60 } },
	ft_five_episodes = { name = "Five Stories", desc = "See five episodes through.", tier = "silver", need = { episodes = 5 } },
	ft_top_rank = { name = "Top of the Ladder", desc = "Reach the highest rank of any career.", tier = "silver", need = { careerTop = true } },
	ft_full_table = { name = "A Full Table", desc = "Share a household and raise two children.", tier = "silver", need = { flags = { "has_partner" }, children = 2 } },
	ft_all_fifty = { name = "Rounded", desc = "Every stat but Health at 50 or more.", tier = "silver", need = { allStats = 50 } },
	ft_five_delves = { name = "Five Times Down", desc = "Come back from five delves or expeditions.", tier = "silver", need = { delves = 5 } },
	ft_two_rivals = { name = "No Hard Feelings", desc = "Close three friends at once, one of them an old rival.", tier = "silver", need = { flags = { "former_rival" }, closeFriends = 3 } },
	ft_hundred_stat = { name = "A Hundred", desc = "Bring any stat to 100.", tier = "silver", need = { anyStat = 100 } },

	-- ── gold ──
	ft_nightmare = { name = "Urban Nightmare", desc = "Be graded an Urban Nightmare. Wings keep a file on you.", tier = "gold", need = { renown = 6 }, limitBreak = { all = 5 }, reward = "Every stat can go 5 further." },
	ft_whole_district = { name = "The District Answers to You", desc = "Hold every block of your District at once.", tier = "gold", need = { blocks = 6 }, limitBreak = { strength = 10, charisma = 10 }, reward = "Strength and Charisma can go 10 further." },
	ft_hundred_thousand = { name = "A Hundred Thousand", desc = "Hold 100,000 Ahn at once.", tier = "gold", need = { money = 100000 } },
	ft_great_office = { name = "A Great Office of the City", desc = "Grow your own Office to its largest.", tier = "gold", need = { office = 5 }, limitBreak = { intelligence = 10, charisma = 5 }, reward = "Intelligence can go 10 further, Charisma 5." },
	ft_every_case = { name = "Every File Closed", desc = "Close every case the City has for you.", tier = "gold", need = { cases = 5 }, limitBreak = { intelligence = 10, mind = 10 }, reward = "Intelligence and Mental Strength can go 10 further." },
	ft_past_ceiling = { name = "Past the Ceiling", desc = "Bring any stat past 110.", tier = "gold", need = { anyStat = 110 } },
	ft_two_hundred_wins = { name = "Two Hundred Wins", desc = "Win two hundred fights.", tier = "gold", need = { clashes = 200 }, limitBreak = { strength = 10, speed = 10 }, reward = "Strength and Speed can go 10 further." },
	ft_ten_episodes = { name = "A Book of Stories", desc = "See ten episodes through.", tier = "gold", need = { episodes = 10 }, limitBreak = { all = 5 }, reward = "Every stat can go 5 further." },
	ft_legendary = { name = "Something Legendary", desc = "Own a legendary item.", tier = "gold", need = { legendary = 1 } },
	ft_collector = { name = "Collector", desc = "Own five unique items at once.", tier = "gold", need = { uniques = 5 } },
	ft_eighty = { name = "Eighty Years in the City", desc = "Live to eighty.", tier = "gold", need = { age = 80 } },
	ft_third_generation = { name = "Third Generation", desc = "Play the third life of one family.", tier = "gold", need = { lives = 3 } },
	ft_color = { name = "A Color of the City", desc = "Be named a Color by Hana.", tier = "gold", need = { flags = { "color_fixer" } }, limitBreak = { all = 40 }, reward = "Every stat can go 40 further." },

	-- ── mythic ──
	ft_star = { name = "Star of the City", desc = "Be one of the handful the whole City knows.", tier = "mythic", need = { renown = 7 } },
	ft_impurity = { name = "Impurity", desc = "Reach Hana's last grade.", tier = "mythic", need = { renown = 8 }, limitBreak = { all = 10 }, reward = "Every stat can go 10 further." },
	ft_all_hundred = { name = "Whole", desc = "Every stat but Health at 100 or more, in one life.", tier = "mythic", need = { allStats = 100 } },
	ft_past_every_limit = { name = "Past Every Limit", desc = "Bring any stat to 130.", tier = "mythic", need = { anyStat = 130 } },
	ft_million = { name = "A Million Ahn", desc = "Hold a million Ahn at once. The Head's tax collectors will want a word.", tier = "mythic", need = { money = 1000000 } },
	ft_unbroken_line = { name = "An Unbroken Line", desc = "Play the fifth life of one family.", tier = "mythic", need = { lives = 5 } },
	ft_streets_and_seat = { name = "Streets and a Seat", desc = "Hold every block of your District while running a great Office.", tier = "mythic", need = { blocks = 6, office = 5 } },
	ft_every_episode = { name = "Every Story", desc = "See fifteen episodes through in one life.", tier = "mythic", need = { episodes = 15 } },
}
