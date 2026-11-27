--[[
	More talents (v0.18). Same rules as Talents.luau and Talents2.luau: one is dealt at birth by
	rarity, and each belongs to one of the seven sins. A talent is something a person is BORN
	with (a body, a temper, a kind of luck), never a technique an Association, a Finger or a
	Wing would own. This set leans on the stats the older talents barely touch: Speed, Charisma
	and Luck.
]]

return {
	order = {
		-- common
		"tal3_long_stride", "tal3_market_voice", "tal3_coin_sense", "tal3_light_sleeper", "tal3_thick_skull", "tal3_quick_hands",
		"tal3_warm_smile", "tal3_short_temper", "tal3_good_posture", "tal3_rain_walker", "tal3_gutter_eyes", "tal3_big_appetite",
		"tal3_good_with_names", "tal3_naps_anywhere", "tal3_quick_study",
		-- uncommon
		"tal3_sprinter", "tal3_charmer", "tal3_four_leaf", "tal3_nose_for_trouble", "tal3_iron_gut", "tal3_calm_under_fire",
		"tal3_reads_a_crowd", "tal3_born_proud", "tal3_quick_to_swing", "tal3_squirrel", "tal3_sad_songs", "tal3_big_bones",
		"tal3_chin_up",
		-- rare
		"tal3_a_blur", "tal3_golden_voice", "tal3_lucky_star", "tal3_thick_hide", "tal3_mirror_mind", "tal3_grim_focus",
		"tal3_perfect_form", "tal3_red_eyes", "tal3_answers_back", "tal3_alley_ghost", "tal3_iron_knuckles",
		-- epic
		"tal3_lightning_legs", "tal3_bell_voice", "tal3_fortunes_child", "tal3_walking_wall", "tal3_still_water",
		"tal3_born_in_a_fight", "tal3_magpie", "tal3_practice_perfect", "tal3_never_kneels",
		-- legendary
		"tal3_storm_step", "tal3_voice_people_follow", "tal3_charmed_life", "tal3_hard_to_kill", "tal3_red_temper",
		"tal3_thief_of_gifts", "tal3_deep_well",
		-- unreal
		"tal3_faster_than_night", "tal3_coin_always_lands", "tal3_mountain", "tal3_sorrow_blade", "tal3_red_hour",
	},

	-- ── Ordinary ──
	tal3_long_stride = { name = "Long Stride", desc = "You cover a street in the time it takes others to cross it. Speed grows 25% faster.", talent = "common", affinity = "lust", growth = { speed = 1.25 } },
	tal3_market_voice = { name = "Market Voice", desc = "You could sell noodles to a noodle cook. +3 Charisma, +1 base in Charisma checks.", talent = "common", affinity = "envy", stats = { charisma = 3 }, clash = { charisma = { base = 1 } } },
	tal3_coin_sense = { name = "Coin Sense", desc = "You can tell which way a coin will land, sometimes. +2 Luck, +2% heads chance.", talent = "common", affinity = "sloth", stats = { luck = 2 }, heads = 2 },
	tal3_light_sleeper = { name = "Wakes at a Whisper", desc = "You wake at the first footstep on the stairs. +1 base in Speed checks, -2 starting Sanity.", talent = "common", affinity = "gloom", clash = { speed = { base = 1 } }, sanity = -2 },
	tal3_thick_skull = { name = "Thick Skull", desc = "You've walked into a lot of door frames. +4 Health, and you take 5% less Health damage.", talent = "common", affinity = "gluttony", stats = { health = 4 }, toughness = 0.95 },
	tal3_quick_hands = { name = "Fast Fingers", desc = "The last biscuit is always yours. +2 Speed, +1 base in Speed checks.", talent = "common", affinity = "envy", stats = { speed = 2 }, clash = { speed = { base = 1 } } },
	tal3_warm_smile = { name = "Warm Smile", desc = "Strangers tell you their troubles at bus stops. Charisma grows 25% faster.", talent = "common", affinity = "lust", growth = { charisma = 1.25 } },
	tal3_short_temper = { name = "Short Temper", desc = "Your fists are quicker than your thinking. +1 base in fights, -2 starting Sanity.", talent = "common", affinity = "wrath", fight = { base = 1 }, sanity = -2 },
	tal3_good_posture = { name = "Good Posture", desc = "You stand like someone who's expected. +2 Charisma, +2 Mental Strength.", talent = "common", affinity = "pride", stats = { charisma = 2, mind = 2 } },
	tal3_rain_walker = { name = "Rain Walker", desc = "You like the rain. It's quieter when it rains. +6 starting Sanity.", talent = "common", affinity = "gloom", sanity = 6 },
	tal3_gutter_eyes = { name = "Gutter Eyes", desc = "You find Ahn in gutters other people walk straight past. Start with 140 extra Ahn, +2 Luck.", talent = "common", affinity = "envy", money = 140, stats = { luck = 2 } },
	tal3_big_appetite = { name = "Big Appetite", desc = "Seconds, then thirds. +3 Health, and Health grows 20% faster.", talent = "common", affinity = "gluttony", stats = { health = 3 }, growth = { health = 1.2 } },
	tal3_good_with_names = { name = "Good with Names", desc = "You never forget a face, or the name that goes with it. +2 Charisma, +1 base in Charisma checks.", talent = "common", affinity = "pride", stats = { charisma = 2 }, clash = { charisma = { base = 1 } } },
	tal3_naps_anywhere = { name = "Naps Anywhere", desc = "Bus seats, stairwells, standing up. +6 starting Sanity, +1% heads chance.", talent = "common", affinity = "sloth", sanity = 6, heads = 1 },
	tal3_quick_study = { name = "Read Once", desc = "Read it once, and it's yours. Intelligence grows 20% faster.", talent = "common", affinity = "lust", growth = { intelligence = 1.2 } },

	-- ── Promising ──
	tal3_sprinter = { name = "Sprinter", desc = "Nobody on your block has ever caught you. Speed grows 40% faster.", talent = "uncommon", affinity = "lust", growth = { speed = 1.4 } },
	tal3_charmer = { name = "Charmer", desc = "Doors open. Prices drop. +1 coin in Charisma checks.", talent = "uncommon", affinity = "lust", clash = { charisma = { coins = 1 } } },
	tal3_four_leaf = { name = "Four-Leaf", desc = "Found one in a crack in the pavement, aged five, and things went your way after. Luck grows 40% faster, +3% heads chance.", talent = "uncommon", affinity = "sloth", growth = { luck = 1.4 }, heads = 3 },
	tal3_nose_for_trouble = { name = "Nose for Trouble", desc = "You turn the corner a second before it happens. +1 coin in Speed checks.", talent = "uncommon", affinity = "envy", clash = { speed = { coins = 1 } } },
	tal3_iron_gut = { name = "Iron Gut", desc = "Backstreets food, Backstreets water, never a day off. +6 Health, and you take 12% less Health damage.", talent = "uncommon", affinity = "gluttony", stats = { health = 6 }, toughness = 0.88 },
	tal3_calm_under_fire = { name = "Calm Under Fire", desc = "Your hands are steadiest when everyone else's shake. +1 base in fights, +6 starting Sanity.", talent = "uncommon", affinity = "sloth", fight = { base = 1 }, sanity = 6 },
	tal3_reads_a_crowd = { name = "Reads a Crowd", desc = "You know which way a room will turn before it does. +1 base in Charisma and Mental Strength checks.", talent = "uncommon", affinity = "gloom", clash = { charisma = { base = 1 }, mind = { base = 1 } } },
	tal3_born_proud = { name = "Born Proud", desc = "You've never once asked for help, and it's worked so far. +1 base in Charisma and Intelligence checks.", talent = "uncommon", affinity = "pride", clash = { charisma = { base = 1 }, intelligence = { base = 1 } } },
	tal3_quick_to_swing = { name = "Quick to Swing", desc = "First punch, every time. +1 base in fights, +1 base in Speed checks.", talent = "uncommon", affinity = "wrath", fight = { base = 1 }, clash = { speed = { base = 1 } } },
	tal3_squirrel = { name = "Squirrel", desc = "You hide a little of everything for later. Start with 300 extra Ahn, +2 Luck.", talent = "uncommon", affinity = "envy", money = 300, stats = { luck = 2 } },
	tal3_sad_songs = { name = "Sings Sad Songs", desc = "It helps. Mental Strength grows 35% faster, +4 starting Sanity.", talent = "uncommon", affinity = "gloom", growth = { mind = 1.35 }, sanity = 4 },
	tal3_chin_up = { name = "Chin Up", desc = "You don't look away first. +3 Mental Strength, +1 base in Mental Strength checks.", talent = "uncommon", affinity = "pride", stats = { mind = 3 }, clash = { mind = { base = 1 } } },
	tal3_big_bones = { name = "Big Bones", desc = "You were a big baby and you kept going. +8 Health, and Strength grows 20% faster.", talent = "uncommon", affinity = "gluttony", stats = { health = 8 }, growth = { strength = 1.2 } },

	-- ── Gifted ──
	tal3_a_blur = { name = "A Blur", desc = "People describe you afterwards as a sort of smudge. +1 coin in Speed checks and fights that use it, +1 base in fights.", talent = "rare", affinity = "lust", clash = { speed = { coins = 1 } }, fight = { base = 1 } },
	tal3_golden_voice = { name = "Golden Voice", desc = "When you talk, people go quiet to hear it. +1 coin and +1 base in Charisma checks, and Charisma grows 30% faster.", talent = "rare", affinity = "lust", clash = { charisma = { coins = 1, base = 1 } }, growth = { charisma = 1.3 } },
	tal3_lucky_star = { name = "Born Under a Good Sign", desc = "Born under one, the midwife said, and she'd seen a lot of births. Luck grows 60% faster, +5% heads chance.", talent = "rare", affinity = "sloth", growth = { luck = 1.6 }, heads = 5 },
	tal3_thick_hide = { name = "Thick Hide", desc = "Bruises don't stay on you. +6 Health, and you take 25% less Health damage.", talent = "rare", affinity = "gluttony", stats = { health = 6 }, toughness = 0.75 },
	tal3_mirror_mind = { name = "Mirror Mind", desc = "Watch someone do it, then do it better. Speed, Charisma and Intelligence grow 35% faster.", talent = "rare", affinity = "envy", growth = { speed = 1.35, charisma = 1.35, intelligence = 1.35 } },
	tal3_grim_focus = { name = "Grim Focus", desc = "The worse it gets, the clearer you see. +1 coin in Mental Strength checks, +8 starting Sanity.", talent = "rare", affinity = "gloom", clash = { mind = { coins = 1 } }, sanity = 8 },
	tal3_perfect_form = { name = "Perfect Form", desc = "Everything you do looks like a lesson. +1 base in every clash, and every stat grows 15% faster.", talent = "rare", affinity = "pride", clash = { any = { base = 1 } }, growth = 1.15 },
	tal3_red_eyes = { name = "Red Eyes", desc = "Something takes over when you fight, and you don't remember all of it. +2 base and +1 power per heads in fights, -6 starting Sanity.", talent = "rare", affinity = "wrath", fight = { base = 2, coinPower = 1 }, sanity = -6 },
	tal3_answers_back = { name = "Answers Back", desc = "Hit you once and you hit back twice. +1 coin in fights, -2 starting Sanity.", talent = "rare", affinity = "wrath", fight = { coins = 1 }, sanity = -2 },
	tal3_iron_knuckles = { name = "Iron Knuckles", desc = "Your fists land like a shutter coming down. +1 coin in Strength checks, +1 base in fights.", talent = "rare", affinity = "wrath", clash = { strength = { coins = 1 } }, fight = { base = 1 } },
	tal3_alley_ghost = { name = "Alley Ghost", desc = "Here, then not. +1 coin in Speed checks, +3% heads chance.", talent = "rare", affinity = "envy", clash = { speed = { coins = 1 } }, heads = 3 },

	-- ── Prodigy ──
	tal3_lightning_legs = { name = "Lightning Legs", desc = "Couriers stop to watch you run. Speed grows 70% faster, +1 coin in Speed checks.", talent = "epic", affinity = "lust", growth = { speed = 1.7 }, clash = { speed = { coins = 1 } } },
	tal3_bell_voice = { name = "Voice Like a Bell", desc = "People remember what you said years later, word for word. +2 coins in Charisma checks, and Charisma grows 50% faster.", talent = "epic", affinity = "pride", clash = { charisma = { coins = 2 } }, growth = { charisma = 1.5 } },
	tal3_fortunes_child = { name = "Fortune's Child", desc = "The City's dice keep rolling your way. +10% heads chance, and Luck grows 50% faster.", talent = "epic", affinity = "sloth", heads = 10, growth = { luck = 1.5 } },
	tal3_walking_wall = { name = "Walking Wall", desc = "You take 40% less Health damage, +10 Health.", talent = "epic", affinity = "gluttony", toughness = 0.6, stats = { health = 10 } },
	tal3_still_water = { name = "Still Water", desc = "Nothing reaches the bottom of you. +2 coins in Mental Strength checks, +15 starting Sanity.", talent = "epic", affinity = "gloom", clash = { mind = { coins = 2 } }, sanity = 15 },
	tal3_born_in_a_fight = { name = "Born in a Fight", desc = "You came into the world swinging. +1 coin, +2 base and +1 potency in fights.", talent = "epic", affinity = "wrath", fight = { coins = 1, base = 2, potency = 1 } },
	tal3_magpie = { name = "Magpie", desc = "Bright things find their way to you, and so does everything else. Every stat grows 35% faster, start with 700 extra Ahn.", talent = "epic", affinity = "envy", growth = 1.35, money = 700 },
	tal3_never_kneels = { name = "Never Kneels", desc = "You get up. Every time. You take 10% less Health damage, +5 Mental Strength.", talent = "epic", affinity = "pride", toughness = 0.9, stats = { mind = 5 } },
	tal3_practice_perfect = { name = "Practice Makes Perfect", desc = "A thousand reps don't bore you. Your way of fighting is mastered 60% faster, and every stat grows 20% faster.", talent = "epic", affinity = "lust", masteryGrowth = 1.6, growth = 1.2 },

	-- ── One in a District ──
	tal3_storm_step = { name = "Storm Step", desc = "There and gone like weather. +2 coins in Speed checks, +1 coin in fights, and Speed grows 60% faster.", talent = "legendary", affinity = "lust", clash = { speed = { coins = 2 } }, fight = { coins = 1 }, growth = { speed = 1.6 } },
	tal3_voice_people_follow = { name = "A Voice People Follow", desc = "You say 'this way', and a street full of people goes this way. +2 coins in Charisma checks, +1 coin in Mental Strength checks, start with 800 extra Ahn.", talent = "legendary", affinity = "pride", clash = { charisma = { coins = 2 }, mind = { coins = 1 } }, money = 800 },
	tal3_charmed_life = { name = "Charmed Life", desc = "Things fall just short of you, every time. +14% heads chance, +15 starting Sanity.", talent = "legendary", affinity = "sloth", heads = 14, sanity = 15 },
	tal3_hard_to_kill = { name = "The Clinics Know Your Name", desc = "The clinics know your name and are always surprised to see you again. You take 50% less Health damage, and Health grows 60% faster.", talent = "legendary", affinity = "gluttony", toughness = 0.5, growth = { health = 1.6 } },
	tal3_red_temper = { name = "Red Temper", desc = "When it goes, it all goes. +2 coins and +3 base in fights, -10 starting Sanity.", talent = "legendary", affinity = "wrath", fight = { coins = 2, base = 3 }, sanity = -10 },
	tal3_thief_of_gifts = { name = "Thief of Gifts", desc = "Whatever anyone near you is good at, you're soon good at too. Every stat grows 70% faster, +5% heads chance.", talent = "legendary", affinity = "envy", growth = 1.7, heads = 5 },
	tal3_deep_well = { name = "Deep Well", desc = "You've never once run out of yourself. +30 starting Sanity, +1 coin in Mental Strength checks, and Mental Strength grows 80% faster.", talent = "legendary", affinity = "gloom", sanity = 30, clash = { mind = { coins = 1 } }, growth = { mind = 1.8 } },

	-- ── One in the City ──
	tal3_faster_than_night = { name = "Faster Than the Night", desc = "They say you could cross a District between the first bell and the second. +3 coins in Speed checks, +2 coins in fights, and every stat grows 30% faster.", talent = "unreal", affinity = "lust", clash = { speed = { coins = 3 } }, fight = { coins = 2 }, growth = 1.3 },
	tal3_coin_always_lands = { name = "The Coin Always Lands", desc = "Heads. Always heads. +22% heads chance in everything.", talent = "unreal", affinity = "sloth", heads = 22 },
	tal3_mountain = { name = "Mountain", desc = "You take 60% less Health damage, +25 Health. Things break on you.", talent = "unreal", affinity = "gluttony", toughness = 0.4, stats = { health = 25 } },
	tal3_sorrow_blade = { name = "Sorrow Like a Blade", desc = "Grief made you sharp instead of soft. +2 coins in Mental Strength checks and in fights, +30 starting Sanity.", talent = "unreal", affinity = "gloom", clash = { mind = { coins = 2 } }, fight = { coins = 2 }, sanity = 30 },
	tal3_red_hour = { name = "The Red Hour", desc = "There's an hour in every fight that belongs to you. +3 coins and +3 base in fights.", talent = "unreal", affinity = "wrath", fight = { coins = 3, base = 3 } },
}
