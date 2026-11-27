--[[
	Talents: every life is born with one random talent (pack.talents in init.luau sets the
	odds). The rarer the tier, the stronger it is; Unreal talents are absurd on purpose.
	Each talent belongs to one of the seven sins (pack.affinities). A life is dealt two sins
	at birth; a talent of one of them resonates (+3% heads), and a family's sins lean its
	next child's talent the same way. The rarity odds themselves never change.
	Fields as for traits, plus:
		talent = "tier"        which rarity tier it belongs to
		affinity = "sin"       wrath | lust | sloth | gluttony | gloom | pride | envy
		growth = n | { stat = n }   stats grow this much faster from activities and events
		masteryGrowth = n      fighting-style mastery grows this much faster
		toughness = n          you take this share of Health damage (0.8 = 20% less)
]]

return {
	order = {
		-- common
		"tal_quick_hands", "tal_book_smart", "tal_light_sleeper", "tal_thick_skin", "tal_calm", "tal_scrapper", "tal_penny", "tal_proud_bearing",
		-- uncommon
		"tal_fast_learner", "tal_drill_hound", "tal_hard_to_kill", "tal_good_eye", "tal_iron_body", "tal_short_fuse", "tal_unhurried", "tal_sticky_fingers",
		-- rare
		"tal_prodigy", "tal_status_savant", "tal_steel_nerves", "tal_veteran_blood", "tal_hot_blood", "tal_measured_pace", "tal_iron_stomach",
		-- epic
		"tal_genius", "tal_born_survivor", "tal_killers_eye", "tal_overdrive", "tal_eye_of_storm", "tal_melancholy_clarity", "tal_mirror_skill",
		-- legendary
		"tal_colors_spark", "tal_lucky_star", "tal_ego_seed", "tal_burning_grudge", "tal_dreamless", "tal_endless_appetite", "tal_born_to_rule",
		-- unreal
		"tal_red_mist_echo", "tal_black_silence", "tal_golden_bough", "tal_furnace_heart", "tal_devourer", "tal_abyss_gazer", "tal_stolen_crown",
	},

	-- ── Common ──
	tal_quick_hands = { name = "Quick Hands", desc = "Strength grows 25% faster.", talent = "common", affinity = "lust", growth = { strength = 1.25 } },
	tal_book_smart = { name = "Book Smart", desc = "Intelligence grows 25% faster.", talent = "common", affinity = "gloom", growth = { intelligence = 1.25 } },
	tal_light_sleeper = { name = "Light Sleeper", desc = "Mental Strength grows 25% faster.", talent = "common", affinity = "sloth", growth = { mind = 1.25 } },
	tal_thick_skin = { name = "Thick Skin", desc = "You take 10% less Health damage.", talent = "common", affinity = "gluttony", toughness = 0.9 },
	tal_calm = { name = "Calm Breather", desc = "+2% heads chance in every clash.", talent = "common", affinity = "sloth", heads = 2 },
	tal_scrapper = { name = "Scrapper", desc = "+1 base power in fights.", talent = "common", affinity = "wrath", fight = { base = 1 } },
	tal_penny = { name = "Penny Pincher", desc = "Start with 150 extra Ahn.", talent = "common", affinity = "envy", money = 150 },
	tal_proud_bearing = { name = "Proud Bearing", desc = "+1 base in Strength checks. People step aside.", talent = "common", affinity = "pride", clash = { strength = { base = 1 } } },

	-- ── Uncommon ──
	tal_fast_learner = { name = "Fast Learner", desc = "Every stat grows 20% faster.", talent = "uncommon", affinity = "pride", growth = 1.2 },
	tal_drill_hound = { name = "Drill Hound", desc = "Drilling your fighting style gives double mastery.", talent = "uncommon", affinity = "lust", masteryGrowth = 2 },
	tal_hard_to_kill = { name = "Hard to Kill", desc = "You take 20% less Health damage.", talent = "uncommon", affinity = "gluttony", toughness = 0.8 },
	tal_good_eye = { name = "Good Eye", desc = "+1 coin in Mental Strength checks.", talent = "uncommon", affinity = "gloom", clash = { mind = { coins = 1 } } },
	tal_iron_body = { name = "Iron Constitution", desc = "+8 Health, +1 base in Health checks.", talent = "uncommon", affinity = "gluttony", stats = { health = 8 }, clash = { health = { base = 1 } } },
	tal_short_fuse = { name = "Short Fuse", desc = "+1 power per heads in fights.", talent = "uncommon", affinity = "wrath", fight = { coinPower = 1 } },
	tal_unhurried = { name = "Unhurried", desc = "+4% heads chance in every clash, +5 starting Sanity.", talent = "uncommon", affinity = "sloth", heads = 4, sanity = 5 },
	tal_sticky_fingers = { name = "Sticky Fingers", desc = "Start with 300 extra Ahn. +2% heads chance.", talent = "uncommon", affinity = "envy", money = 300, heads = 2 },

	-- ── Rare ──
	tal_prodigy = { name = "Prodigy", desc = "Every stat grows 35% faster.", talent = "rare", affinity = "pride", growth = 1.35 },
	tal_status_savant = { name = "Status Savant", desc = "+1 potency to your style's status in fights.", talent = "rare", affinity = "envy", fight = { potency = 1 } },
	tal_steel_nerves = { name = "Steel Nerves", desc = "+6% heads chance, +10 starting Sanity.", talent = "rare", affinity = "gloom", heads = 6, sanity = 10 },
	tal_veteran_blood = { name = "Veteran's Blood", desc = "+1 coin in fights.", talent = "rare", affinity = "wrath", fight = { coins = 1 } },
	tal_hot_blood = { name = "Hot Blood", desc = "+1 power per heads and +1 potency in fights.", talent = "rare", affinity = "lust", fight = { coinPower = 1, potency = 1 } },
	tal_measured_pace = { name = "Measured Pace", desc = "You take 20% less Health damage. +1 base in Intelligence checks.", talent = "rare", affinity = "sloth", toughness = 0.8, clash = { intelligence = { base = 1 } } },
	tal_iron_stomach = { name = "Iron Stomach", desc = "You take 25% less Health damage. +10 Health.", talent = "rare", affinity = "gluttony", toughness = 0.75, stats = { health = 10 } },

	-- ── Epic ──
	tal_genius = { name = "Genius", desc = "Every stat grows 50% faster, and drilling gives double mastery.", talent = "epic", affinity = "pride", growth = 1.5, masteryGrowth = 2 },
	tal_born_survivor = { name = "Born Survivor", desc = "You take 35% less Health damage. +10 Health.", talent = "epic", affinity = "gluttony", toughness = 0.65, stats = { health = 10 } },
	tal_killers_eye = { name = "Killer's Eye", desc = "+1 coin and +1 potency in fights.", talent = "epic", affinity = "wrath", fight = { coins = 1, potency = 1 } },
	tal_overdrive = { name = "Overdrive", desc = "+1 coin in fights. Every stat grows 25% faster.", talent = "epic", affinity = "lust", fight = { coins = 1 }, growth = 1.25 },
	tal_eye_of_storm = { name = "Eye of the Storm", desc = "+8% heads chance in everything, +10 starting Sanity.", talent = "epic", affinity = "sloth", heads = 8, sanity = 10 },
	tal_melancholy_clarity = { name = "Melancholy Clarity", desc = "+2 coins in Mental Strength checks, +1 coin in Intelligence checks.", talent = "epic", affinity = "gloom", clash = { mind = { coins = 2 }, intelligence = { coins = 1 } } },
	tal_mirror_skill = { name = "Mirror Skill", desc = "+1 coin and +1 power per heads in fights. You learn by watching.", talent = "epic", affinity = "envy", fight = { coins = 1, coinPower = 1 } },

	-- ── Legendary ──
	tal_colors_spark = { name = "A Color's Spark", desc = "+1 coin, +2 base and +1 potency in fights. Stats grow 30% faster.", talent = "legendary", affinity = "lust", fight = { coins = 1, base = 2, potency = 1 }, growth = 1.3 },
	tal_lucky_star = { name = "Lucky Star", desc = "+10% heads chance in everything you do.", talent = "legendary", affinity = "envy", heads = 10 },
	tal_ego_seed = { name = "Knows Their Own Heart", desc = "+2 coins in Mental Strength checks and +15 starting Sanity. The edge is easier to face.", talent = "legendary", affinity = "gloom", clash = { mind = { coins = 2 } }, sanity = 15 },
	tal_burning_grudge = { name = "Burning Grudge", desc = "+2 base and +1 potency in fights. Strength grows 40% faster.", talent = "legendary", affinity = "wrath", fight = { base = 2, potency = 1 }, growth = { strength = 1.4 } },
	tal_dreamless = { name = "Dreamless Sleep", desc = "You take 30% less Health damage, +15 starting Sanity, +4% heads.", talent = "legendary", affinity = "sloth", toughness = 0.7, sanity = 15, heads = 4 },
	tal_endless_appetite = { name = "Endless Appetite", desc = "+2 base in fights, and you take 30% less Health damage.", talent = "legendary", affinity = "gluttony", fight = { base = 2 }, toughness = 0.7 },
	tal_born_to_rule = { name = "Born to Rule", desc = "+1 coin in every clash, fights and checks alike.", talent = "legendary", affinity = "pride", clash = { any = { coins = 1 } } },

	-- ── Unreal ──
	tal_red_mist_echo = { name = "Echo of the Red Mist", desc = "+2 coins, +3 base and +2 potency in fights, and you take 40% less Health damage.", talent = "unreal", affinity = "wrath", fight = { coins = 2, base = 3, potency = 2 }, toughness = 0.6 },
	tal_black_silence = { name = "A Color's Patience", desc = "+2 coins in every clash, and every stat grows 60% faster.", talent = "unreal", affinity = "sloth", clash = { any = { coins = 2 } }, growth = 1.6 },
	tal_golden_bough = { name = "The City's Favorite", desc = "+15% heads chance, half the Health damage, +20 starting Sanity.", talent = "unreal", affinity = "pride", heads = 15, toughness = 0.5, sanity = 20 },
	tal_furnace_heart = { name = "Heart of the Furnace", desc = "+2 coins and +2 potency in fights. Every stat grows 30% faster.", talent = "unreal", affinity = "lust", fight = { coins = 2, potency = 2 }, growth = 1.3 },
	tal_devourer = { name = "Devourer", desc = "Half the Health damage, +2 coins in Health checks, +20 Health.", talent = "unreal", affinity = "gluttony", toughness = 0.5, clash = { health = { coins = 2 } }, stats = { health = 20 } },
	tal_abyss_gazer = { name = "Abyss Gazer", desc = "+3 coins in Mental Strength checks, +20 starting Sanity, and every stat grows 30% faster.", talent = "unreal", affinity = "gloom", clash = { mind = { coins = 3 } }, sanity = 20, growth = 1.3 },
	tal_stolen_crown = { name = "Stolen Crown", desc = "+2 coins and +2 base in fights, and +10% heads chance.", talent = "unreal", affinity = "envy", fight = { coins = 2, base = 2 }, heads = 10 },
}
