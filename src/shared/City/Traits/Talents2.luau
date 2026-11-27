--[[
	More talents (v0.9). Same rules as Talents.luau: one is dealt at birth by rarity, and each
	belongs to one of the seven sins. A talent is something a person is BORN with: a body, a
	temper, a kind of luck. Nothing here is a technique an Association, a Finger or a Wing
	would own (those are schools: Schools.luau), and nothing depends on the age a life is
	born into.
]]

return {
	order = {
		-- common
		"tal2_stair_legs", "tal2_night_eyes", "tal2_steady_pour", "tal2_loud_laugh", "tal2_counts", "tal2_hollow_leg", "tal2_quiet_feet",
		"tal2_haggler", "tal2_stubborn", "tal2_early_riser",
		-- uncommon
		"tal2_rat_luck", "tal2_never_lost", "tal2_old_soul", "tal2_clean_hands", "tal2_heavy_sleeper", "tal2_good_ear", "tal2_long_fuse",
		"tal2_lenders_memory", "tal2_workshop_hands", "tal2_crow_friend",
		-- rare
		"tal2_cold_blood", "tal2_wall_reader", "tal2_bargain_tongue", "tal2_second_breath", "tal2_perfect_recall", "tal2_spite", "tal2_soft_step",
		"tal2_big_heart", "tal2_fever_proof",
		-- epic
		"tal2_born_313", "tal2_unbreakable", "tal2_natural_duelist", "tal2_silver_spoon", "tal2_reads_people", "tal2_wont_stay_down",
		"tal2_one_look", "tal2_clear_head",
		-- legendary
		"tal2_untouched", "tal2_the_knack", "tal2_iron_will", "tal2_wolf_hunger", "tal2_quiet_storm", "tal2_everyones_friend",
		-- unreal
		"tal2_star_of_the_city", "tal2_no_fear", "tal2_takes_everything",
	},

	-- ── Ordinary ──
	tal2_stair_legs = { name = "Stairwell Legs", desc = "Ten floors, no lift, every day of your life. Health grows 25% faster.", talent = "common", affinity = "gluttony", growth = { health = 1.25 } },
	tal2_night_eyes = { name = "Night Eyes", desc = "You see well in bad light. +1 base in Mental Strength checks.", talent = "common", affinity = "gloom", clash = { mind = { base = 1 } } },
	tal2_steady_pour = { name = "Steady Pour", desc = "Your hands don't shake. +1 base in Intelligence checks.", talent = "common", affinity = "sloth", clash = { intelligence = { base = 1 } } },
	tal2_loud_laugh = { name = "Loud Laugh", desc = "It's hard to stay miserable near you, even for you. +6 starting Sanity.", talent = "common", affinity = "lust", sanity = 6 },
	tal2_counts = { name = "Counts Everything", desc = "Steps, coins, exits. Start with 100 extra Ahn, +2 Intelligence.", talent = "common", affinity = "envy", money = 100, stats = { intelligence = 2 } },
	tal2_hollow_leg = { name = "Hollow Leg", desc = "You can eat anything and it stays down. +5 Health.", talent = "common", affinity = "gluttony", stats = { health = 5 } },
	tal2_quiet_feet = { name = "Quiet Feet", desc = "People don't hear you come in. +1 base in Strength checks.", talent = "common", affinity = "envy", clash = { strength = { base = 1 } } },
	tal2_haggler = { name = "Born Haggler", desc = "You've never paid the first price. Start with 180 extra Ahn.", talent = "common", affinity = "pride", money = 180 },
	tal2_stubborn = { name = "Stubborn", desc = "You don't know when you're beaten. +1 base in Health checks.", talent = "common", affinity = "wrath", clash = { health = { base = 1 } } },
	tal2_early_riser = { name = "Early Riser", desc = "Up before the Sweepers have gone. +3 Mental Strength, +2% heads chance.", talent = "common", affinity = "sloth", stats = { mind = 3 }, heads = 2 },

	-- ── Promising ──
	tal2_rat_luck = { name = "Rat's Luck", desc = "Things miss you by an inch. +5% heads chance in every clash.", talent = "uncommon", affinity = "envy", heads = 5 },
	tal2_never_lost = { name = "Never Lost", desc = "You always know which way home is. +1 coin in Mental Strength checks, +4 starting Sanity.", talent = "uncommon", affinity = "gloom", clash = { mind = { coins = 1 } }, sanity = 4 },
	tal2_old_soul = { name = "Old Soul", desc = "You were a serious baby. Mental Strength and Intelligence grow 25% faster.", talent = "uncommon", affinity = "gloom", growth = { mind = 1.25, intelligence = 1.25 } },
	tal2_clean_hands = { name = "Clean Hands", desc = "Careful by nature. +1 coin in Intelligence checks.", talent = "uncommon", affinity = "pride", clash = { intelligence = { coins = 1 } } },
	tal2_heavy_sleeper = { name = "Heavy Sleeper", desc = "You sleep through the Night, every night. +10 starting Sanity.", talent = "uncommon", affinity = "sloth", sanity = 10 },
	tal2_good_ear = { name = "Good Ear", desc = "You hear the thing behind you. +1 coin in Strength checks.", talent = "uncommon", affinity = "lust", clash = { strength = { coins = 1 } } },
	tal2_long_fuse = { name = "Long Fuse", desc = "Slow to anger, and worse for it when you get there. +2 base in fights.", talent = "uncommon", affinity = "wrath", fight = { base = 2 } },
	tal2_lenders_memory = { name = "Lender's Memory", desc = "You remember every debt, in both directions. Start with 250 extra Ahn, +1 base in Mental Strength checks.", talent = "uncommon", affinity = "envy", money = 250, clash = { mind = { base = 1 } } },
	tal2_workshop_hands = { name = "Clever Hands", desc = "Things come apart and go back together for you. Intelligence grows 40% faster.", talent = "uncommon", affinity = "lust", growth = { intelligence = 1.4 } },
	tal2_crow_friend = { name = "Crows Like You", desc = "Nobody knows why. They bring you things. +3% heads chance, start with 120 extra Ahn.", talent = "uncommon", affinity = "gluttony", heads = 3, money = 120 },

	-- ── Gifted ──
	tal2_cold_blood = { name = "Cold Blood", desc = "Your pulse doesn't change. +1 coin in fights when it matters, +5 starting Sanity.", talent = "rare", affinity = "sloth", fight = { coins = 1 }, sanity = 5 },
	tal2_wall_reader = { name = "Reads a Room", desc = "You know who's in charge before anyone speaks. +1 coin and +1 base in Mental Strength checks.", talent = "rare", affinity = "gloom", clash = { mind = { coins = 1, base = 1 } } },
	tal2_bargain_tongue = { name = "Bargain Tongue", desc = "Start with 500 extra Ahn. +1 coin in Intelligence checks.", talent = "rare", affinity = "envy", money = 500, clash = { intelligence = { coins = 1 } } },
	tal2_second_breath = { name = "Second Breath", desc = "You get up one more time than you should be able to. You take 25% less Health damage.", talent = "rare", affinity = "gluttony", toughness = 0.75 },
	tal2_perfect_recall = { name = "Perfect Recall", desc = "You forget nothing, which isn't always a gift. Every stat grows 30% faster. -4 starting Sanity.", talent = "rare", affinity = "pride", growth = 1.3, sanity = -4 },
	tal2_spite = { name = "Pure Spite", desc = "You'd rather lose a hand than lose. +2 base and +1 power per heads in fights.", talent = "rare", affinity = "wrath", fight = { base = 2, coinPower = 1 } },
	tal2_soft_step = { name = "Dancer's Balance", desc = "You've never fallen in your life. +1 coin in Strength checks, +2% heads chance.", talent = "rare", affinity = "lust", clash = { strength = { coins = 1 } }, heads = 2 },
	tal2_big_heart = { name = "Big Heart", desc = "It takes a great deal to make you despair. +14 starting Sanity, +3% heads chance.", talent = "rare", affinity = "lust", sanity = 14, heads = 3 },
	tal2_fever_proof = { name = "Never Ill", desc = "Not once. +12 Health, and you take 15% less Health damage.", talent = "rare", affinity = "gluttony", stats = { health = 12 }, toughness = 0.85 },

	-- ── Prodigy ──
	tal2_born_313 = { name = "Born at 3:13", desc = "You came in the minute the Night began, and it has left you alone since. +2 coins in Mental Strength checks, +12 starting Sanity.", talent = "epic", affinity = "gloom", clash = { mind = { coins = 2 } }, sanity = 12 },
	tal2_unbreakable = { name = "Unbreakable", desc = "You take 40% less Health damage.", talent = "epic", affinity = "gluttony", toughness = 0.6 },
	tal2_natural_duelist = { name = "Natural Duelist", desc = "Nobody taught you. +1 coin and +2 base in fights.", talent = "epic", affinity = "pride", fight = { coins = 1, base = 2 } },
	tal2_silver_spoon = { name = "Silver Spoon", desc = "Money finds you. Start with 900 extra Ahn, +4% heads chance.", talent = "epic", affinity = "envy", money = 900, heads = 4 },
	tal2_reads_people = { name = "Reads People", desc = "You see what someone will do before they've decided. +1 coin in every check that isn't a fight.", talent = "epic", affinity = "gloom", clash = { mind = { coins = 1 }, intelligence = { coins = 1 }, strength = { coins = 1 }, health = { coins = 1 } } },
	tal2_wont_stay_down = { name = "Won't Stay Down", desc = "You take 30% less Health damage, and Health grows 50% faster.", talent = "epic", affinity = "wrath", toughness = 0.7, growth = { health = 1.5 } },
	tal2_one_look = { name = "One Look", desc = "See a thing done once and you can do it. Every stat grows 45% faster.", talent = "epic", affinity = "envy", growth = 1.45 },
	tal2_clear_head = { name = "Clear Head", desc = "+9% heads chance in everything.", talent = "epic", affinity = "sloth", heads = 9 },

	-- ── One in a District ──
	tal2_untouched = { name = "Untouched", desc = "The City has never managed to leave a mark on you. You take 45% less Health damage, +10 starting Sanity.", talent = "legendary", affinity = "sloth", toughness = 0.55, sanity = 10 },
	tal2_the_knack = { name = "The Knack", desc = "Whatever it is, you're good at it by the second try. Every stat grows 60% faster.", talent = "legendary", affinity = "pride", growth = 1.6 },
	tal2_iron_will = { name = "Iron Will", desc = "+25 starting Sanity, +2 coins in Mental Strength checks. It takes a very great deal to bring you to the edge.", talent = "legendary", affinity = "gloom", sanity = 25, clash = { mind = { coins = 2 } } },
	tal2_wolf_hunger = { name = "Wolf's Hunger", desc = "You fight like something that hasn't eaten. +1 coin, +2 base and +1 power per heads in fights.", talent = "legendary", affinity = "gluttony", fight = { coins = 1, base = 2, coinPower = 1 } },
	tal2_quiet_storm = { name = "Quiet Storm", desc = "Calm until the moment you aren't. +1 coin and +2 potency in fights, +5% heads chance.", talent = "legendary", affinity = "wrath", fight = { coins = 1, potency = 2 }, heads = 5 },
	tal2_everyones_friend = { name = "Everyone's Friend", desc = "People open doors for you and don't know why. +1 coin in Mental Strength and Intelligence checks, start with 600 extra Ahn, +10 starting Sanity.", talent = "legendary", affinity = "lust", clash = { mind = { coins = 1 }, intelligence = { coins = 1 } }, money = 600, sanity = 10 },

	-- ── One in the City ──
	tal2_star_of_the_city = { name = "A Star of the City", desc = "Hana has a word for people like you, and it isn't a compliment. +2 coins, +2 base and +2 potency in fights, and every stat grows 40% faster.", talent = "unreal", affinity = "pride", fight = { coins = 2, base = 2, potency = 2 }, growth = 1.4 },
	tal2_no_fear = { name = "Never Learned Fear", desc = "+18% heads chance in everything, +25 starting Sanity.", talent = "unreal", affinity = "lust", heads = 18, sanity = 25 },
	tal2_takes_everything = { name = "Takes Everything", desc = "+2 coins in every clash, and you start with 1,500 extra Ahn. The City gives you things. Nobody has asked what it wants back.", talent = "unreal", affinity = "envy", clash = { any = { coins = 2 } }, money = 1500 },
}
