--[[
	Traits. Players pick pack.traitPicks of the `pick = true` ones when they make a character;
	the rest are earned in life (results: addTrait) or come with a rare family name.
	Fields: name, desc, pick, category, stats (one-off), sanity, money, flags,
	clash = { [stat|"any"] = { coins, base, coinPower } }, fight = { potency, coins, base, coinPower },
	heads (+% in every clash), inherit (heirs get it). See docs/CONTENT_GUIDE.md.
]]

return {
	order = {
		-- body
		"iron_lungs", "quick_feet", "heavy_hands", "night_owl", "scarred_tough",
		-- mind
		"cold_reader", "steady_mind", "bookish", "prescript_minded", "grudge_keeper",
		-- craft
		"tinkerer", "ledger_head", "silver_tongue", "proper_manners", "street_cook",
		-- nerve
		"first_in", "unflinching", "duelist", "tremor_hands", "bleeder",
		"pyromaniac", "drowning_gaze", "patient_blade", "battery",
		-- the street
		"home_before_three", "knows_the_fingers", "rat_smart", "lucky_streak",
		-- where you come from
		"backstreets_born", "nest_manners", "augmented_eyes", "smoke_war_blood",
		-- earned in life
		"light_touched", "survivor_of_the_night", "library_guest", "bolus_grafted",
		"in_debt_to_the_thumb", "middle_family", "index_marked", "color_fixer",
		"golden_bough_seeker", "manager_material", "old_blade_lineage", "lcb_acquaintance",
	},

	-- ── body ──
	iron_lungs = { name = "Iron Lungs", desc = "Smoke, smog, dust: you breathe it and carry on. +6 Health.", pick = true, category = "body", stats = { health = 6 } },
	quick_feet = { name = "Quick Feet", desc = "You're gone before trouble turns around. +1 base in Strength checks and fights.", pick = true, category = "body", clash = { strength = { base = 1 } } },
	heavy_hands = { name = "Heavy Hands", desc = "When you hit something, it stays hit. +1 power per heads in fights.", pick = true, category = "body", fight = { coinPower = 1 } },
	night_owl = { name = "Night Owl", desc = "You've always slept badly and woken easily. +4 Mental Strength, +1 base in Mental Strength checks.", pick = true, category = "body", stats = { mind = 4 }, clash = { mind = { base = 1 } } },
	scarred_tough = { name = "Scarred and Tough", desc = "You've been hurt before and you'll be hurt again. +1 base in Health checks and fights.", pick = true, category = "body", clash = { health = { base = 1 } } },

	-- ── mind ──
	cold_reader = { name = "Cold Reader", desc = "You see lies before they're finished. +1 coin in Mental Strength checks.", pick = true, category = "mind", clash = { mind = { coins = 1 } } },
	steady_mind = { name = "Steady Mind", desc = "The City's horrors slide off you, mostly. +8 starting Sanity, +2 heads chance.", pick = true, category = "mind", sanity = 8, heads = 2 },
	bookish = { name = "Bookish", desc = "Academies, archives, job reports. +6 Intelligence.", pick = true, category = "mind", stats = { intelligence = 6 } },
	prescript_minded = { name = "Prescript-Minded", desc = "Give you an order and you follow it to the letter. +4 Mental Strength, +1 base in Intelligence checks.", pick = true, category = "mind", stats = { mind = 4 }, clash = { intelligence = { base = 1 } } },
	grudge_keeper = { name = "Grudge Keeper", desc = "You remember every slight, and you settle them. +1 potency in fights.", pick = true, category = "mind", fight = { potency = 1 } },

	-- ── craft ──
	tinkerer = { name = "Tinkerer", desc = "Locks, prosthetics, broken radios. +1 coin in Intelligence checks.", pick = true, category = "craft", clash = { intelligence = { coins = 1 } } },
	ledger_head = { name = "Ledger Head", desc = "Numbers make sense to you. You start with 120 extra Ahn and +3 Intelligence.", pick = true, category = "craft", money = 120, stats = { intelligence = 3 } },
	silver_tongue = { name = "Silver Tongue", desc = "You can talk a Rat out of a mugging. +1 base in Mental Strength and Intelligence checks.", pick = true, category = "craft", clash = { mind = { base = 1 }, intelligence = { base = 1 } } },
	proper_manners = { name = "Proper Manners", desc = "You always know who outranks whom, and act like it. Useful around the Thumb. +4 Mental Strength.", pick = true, category = "craft", stats = { mind = 4 }, flags = { "proper_manners" } },
	street_cook = { name = "Street Cook", desc = "You can make a meal out of anything. +5 Health, +3 Sanity.", pick = true, category = "craft", stats = { health = 5 }, sanity = 3 },

	-- ── nerve and fighting ──
	first_in = { name = "First In", desc = "When it starts, you're already moving. +1 coin in Strength fights.", pick = true, category = "nerve", fight = { coins = 0 }, clash = { strength = { coins = 1 } } },
	unflinching = { name = "Unflinching", desc = "Fear makes you calmer, not slower. +4 heads chance in everything.", pick = true, category = "nerve", heads = 4 },
	duelist = { name = "Duelist", desc = "One on one, you're dangerous. +2 base in fights.", pick = true, category = "nerve", fight = { base = 2 } },
	tremor_hands = { name = "Shaking Blows", desc = "Your hits rattle bones. +1 potency in fights, +3 Strength.", pick = true, category = "nerve", fight = { potency = 1 }, stats = { strength = 3 } },
	bleeder = { name = "Knife Habit", desc = "You go for the places that keep bleeding. +2 Strength, +1 power per heads in Strength fights.", pick = true, category = "nerve", stats = { strength = 2 }, clash = { strength = { coinPower = 1 } } },
	pyromaniac = { name = "Likes Fire", desc = "Lighters, matches, Liu weapons: you've always been drawn to flame. +1 potency in fights, -2 Sanity.", pick = true, category = "nerve", fight = { potency = 1 }, sanity = -2 },
	drowning_gaze = { name = "Heavy Stare", desc = "People lose their nerve when you look at them. +1 base in Mental Strength and Strength fights.", pick = true, category = "nerve", clash = { mind = { base = 1 } }, fight = { base = 1 } },
	patient_blade = { name = "Patient Blade", desc = "You wait for the opening, then take it. +3 heads chance, +2 Mental Strength.", pick = true, category = "nerve", heads = 3, stats = { mind = 2 } },
	battery = { name = "Battery", desc = "You start slow and finish loud. +1 coin in Health fights.", pick = true, category = "nerve", clash = { health = { coins = 1 } } },

	-- ── the street ──
	home_before_three = { name = "Home Before Three", desc = "You have never once been outside during the Night. +5 starting Sanity, +3 Mental Strength.", pick = true, category = "street", sanity = 5, stats = { mind = 3 } },
	knows_the_fingers = { name = "Knows the Fingers", desc = "You know the Five Fingers' rules by heart. +1 base in checks against Syndicates. +3 Strength.", pick = true, category = "street", stats = { strength = 3 }, flags = { "knows_the_fingers" }, clash = { any = { base = 0 } } },
	rat_smart = { name = "Rat Smart", desc = "You grew up dodging Rats and learned all their tricks. +1 base in Strength and Mental Strength checks.", pick = true, category = "street", clash = { strength = { base = 1 }, mind = { base = 1 } } },
	lucky_streak = { name = "Lucky Streak", desc = "Coins seem to like you. +5 heads chance, -3 Intelligence.", pick = true, category = "street", heads = 5, stats = { intelligence = -3 } },

	-- ── where you come from ──
	backstreets_born = { name = "Backstreets Born", desc = "You know which alleys to take and which never to. +4 Health, +2 Strength.", pick = true, category = "origin", stats = { health = 4, strength = 2 } },
	nest_manners = { name = "Nest Manners", desc = "You can pass a checkpoint like you own it. You start with 200 extra Ahn.", pick = true, category = "origin", money = 200 },
	augmented_eyes = { name = "Augmented Eyes", desc = "Red combat eyes from a Backstreets clinic. +1 coin in Strength fights, -3 Sanity.", pick = true, category = "origin", fight = { coins = 1 }, sanity = -3, flags = { "augmented_eyes" } },
	smoke_war_blood = { name = "Smoke War Blood", desc = "Your family fought in the Smoke War. Something of it came down to you. +3 Health, +1 base in fights. Runs in the family.", pick = true, category = "origin", stats = { health = 3 }, fight = { base = 1 }, inherit = true },

	-- ── earned in a life (not pickable) ──
	light_touched = { name = "Touched by the Light", desc = "You were in the White Nights and Dark Days, and something of the Light stayed with you. +2 heads chance.", heads = 2, inherit = true },
	survivor_of_the_night = { name = "Survived the Night", desc = "You were caught outside during the Night, and lived. +1 base in Health checks.", clash = { health = { base = 1 } } },
	library_guest = { name = "Returned from the Library", desc = "You were a guest of the Library and walked back out. +1 coin in Mental Strength checks.", clash = { mind = { coins = 1 } } },
	bolus_grafted = { name = "Bolus-Grafted", desc = "An H Corp Bolus changed something in you for good. +1 base in Health and Strength fights.", fight = { base = 1 }, clash = { health = { base = 1 } } },
	in_debt_to_the_thumb = { name = "In Debt to the Thumb", desc = "You owe the Thumb. They're very polite about it, for now. -1 Sanity's worth of worry, always.", heads = -2 },
	middle_family = { name = "Family of the Middle", desc = "The Middle calls you Little Sibling. They have your back, and your debts. Runs in the family.", fight = { potency = 1 }, inherit = true },
	index_marked = { name = "Received a Prescript", desc = "A slip of paper once told you what to do, and you did it. You've been calm ever since. +3 heads chance.", heads = 3 },
	color_fixer = { name = "A Color", desc = "Hana gave you a Color. Every Fixer knows your name. +1 coin and +1 potency in fights.", fight = { coins = 1, potency = 1 }, flags = { "color_fixer" } },
	golden_bough_seeker = { name = "Saw a Golden Bough", desc = "You once saw a Golden Bough up close. You think about it every day. +2 Mental Strength.", stats = { mind = 2 } },
	manager_material = { name = "Manager Material", desc = "L Corp saw something in you. +1 coin in Mental Strength and Intelligence checks.", clash = { mind = { coins = 1 }, intelligence = { coins = 1 } } },
	old_blade_lineage = { name = "Blade Lineage", desc = "You learned the sword from someone who learned it in S Corp's Court. +2 base in fights. Runs in the family.", fight = { base = 2 }, inherit = true },
	lcb_acquaintance = { name = "Met the Bus", desc = "You crossed paths with Limbus Company's bus and its strange passengers, and they remembered you. +2 heads chance.", heads = 2 },
}
