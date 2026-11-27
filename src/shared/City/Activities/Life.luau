--[[
	Activities, area A: the yearly menu of an ordinary life.
		little kids    watch the street, play in the alley, help at a noodle stall
		training       street drills that depend on your fighting style, and raise mastery
		study          cram for a Wing exam; do the street's sums (for the bookish)
		the street     walk with the neighborhood watch, volunteer at the night shelter,
		               teach the alley kids (needs mastery 3)
		quests         the steps of bs_q_coat and bs_q_teodor
]]

return {
	-- ── little kids ────────────────────────────────────────────────────────
	{
		id = "bs_act_window",
		category = "play",
		name = "Watch the street from the window",
		desc = "Noodle carts, Fixers, Rats, the lamps coming on. Everybody's business, from up here.",
		minAge = 2,
		when = { maxAge = 9 },
		result = { mind = { 1, 2 }, sanity = { 1, 3 }, log = "You watched the street from the window for hours: the noodle carts, the Fixers coming off jobs, two Rats arguing, the lamps going on one by one. You knew everyone's business by dinner." },
	},
	{
		id = "bs_act_alley_play",
		category = "play",
		name = "Play in the alley",
		desc = "Tag, kick-the-can, Sweepers and Sleepers. The big kids play rough.",
		minAge = 4,
		when = { maxAge = 12 },
		clash = { stat = "strength", foe = "The big kids' game", coins = 1, base = 2, coinPower = 2 },
		win = { strength = { 1, 3 }, health = { 0, 1 }, sanity = 2, log = "You won the big kids' game and they let you play again tomorrow. In the alley, that's a promotion." },
		lose = { health = -1, strength = 1, sanity = 1, log = "The big kids knocked you down in the first minute. You got up, which counts for more than they'd admit." },
	},
	{
		id = "bs_act_stall_help",
		category = "play",
		name = "Wash bowls at a noodle stall",
		desc = "A few Ahn, a free bowl, and all the gossip on the street. Out by one.",
		minAge = 7,
		when = { side = "backstreets", maxAge = 17 },
		result = { wage = { 4, 10 }, intelligence = { 1, 2 }, sanity = 1, setFlags = { "bs_knows_mun" }, log = "You washed bowls at Auntie Mun's stall until one o'clock and went home with a few Ahn, a full stomach and three pieces of gossip you weren't supposed to hear." },
	},

	-- ── training that depends on your style ────────────────────────────────
	{
		id = "bs_act_scrapyard",
		category = "self",
		name = "Break scrap at a Workshop yard",
		desc = "Heavy blows on old metal, for fighters who shake or crack what they hit. Raises mastery.",
		minAge = 12,
		cooldown = 1,
		when = { style = { "tremor", "rupture" } },
		result = { health = { 1, 2 }, strength = { 1, 2 }, mastery = { 0, 1 }, log = "You spent the evenings breaking scrap behind a Workshop: old engine blocks, a car door, a safe nobody could open. The smiths paid you in tea to keep going. Your {style} started landing like a dropped anvil." },
	},
	{
		id = "bs_act_rooftop",
		category = "self",
		name = "Breathing drills on the roof",
		desc = "Stillness, timing and nerve, for fighters who wait or drown their foe's nerve. Raises mastery.",
		minAge = 10,
		cooldown = 1,
		when = { style = { "poise", "sinking" } },
		result = { mind = { 1, 3 }, sanity = { 1, 3 }, mastery = { 0, 1 }, log = "Every dusk on the roof, among the pigeon lofts: breathe in for the length of a WARP train's crossing, out for twice that, until you could hear your own heartbeat over the street. Your {style} grew quiet and patient." },
	},
	{
		id = "bs_act_hundred_stairs",
		category = "self",
		name = "Run the Hundred Stairs at dawn",
		desc = "Speed and stamina, for fighters who build, burn or bleed their foe down. Raises mastery.",
		minAge = 12,
		cooldown = 1,
		when = { style = { "charge", "burn", "bleed" } },
		result = { health = { 1, 3 }, strength = { 1, 2 }, mastery = { 0, 1 }, log = "Every morning after the Night, up the Hundred Stairs and down again, faster each week, while the street was still clean. Your {style} got its legs." },
	},

	-- ── study ──────────────────────────────────────────────────────────────
	{
		id = "bs_act_exam_cram",
		category = "self",
		name = "Cram for a Wing exam",
		desc = "A cram class in an examinee town: the Wing's history, its numbers, its rules. Hard work, and it shows.",
		minAge = 12,
		cost = 10,
		when = { maxAge = 30 },
		clash = { stat = "intelligence", foe = "A practice exam", coins = 2, base = 3, coinPower = 2 },
		win = { intelligence = { 3, 5 }, mind = 1, sanity = -1, log = "You topped the practice exam at the cram school in the examinee town and earned a gold star on the board, which, at twenty-something, you were embarrassed to be proud of." },
		lose = { intelligence = { 1, 2 }, sanity = -2, log = "You failed the practice exam and stayed up all night redoing it. You learned more from the failing than from any star." },
	},
	{
		id = "bs_act_street_sums",
		category = "money",
		name = "Do the street's accounts",
		desc = "Shopkeepers bring you their ledgers and tax forms. For people with a head for numbers or books.",
		minAge = 14,
		when = { trait = { "ledger_head", "bookish", "bs_academy_graduate" } },
		result = { wage = { 10, 30 }, intelligence = { 1, 2 }, log = "Half the shopkeepers on the street brought you their account books and tax forms this year. You found the grocer forty Ahn he didn't know he had, and became the most popular person on the block." },
	},

	-- ── the street ─────────────────────────────────────────────────────────
	{
		id = "bs_act_watch_patrol",
		category = "city",
		name = "Walk a round with the neighborhood watch",
		desc = "Lamps, whistles, every door checked by half past two. Sometimes there are Rats.",
		minAge = 15,
		cooldown = 1,
		when = { side = "backstreets" },
		clash = { stat = "strength", foe = "Rats trying the shutters", coins = 2, base = 3, coinPower = 2, fight = true },
		win = { wage = { 10, 25 }, strength = 2, sanity = 2, setFlags = { "bs_watch_member" }, log = "You walked the late round with the watch and caught three Rats trying the pharmacy's shutters. They ran. The pharmacist gave the watch a box of bandages and you a nod." },
		lose = { health = { -6, -2 }, sanity = -1, setFlags = { "bs_watch_member" }, log = "The Rats didn't run this time. You finished the round anyway, every door checked, with a split lip and the watch's respect.", cause = "Beaten by Rats on watch" },
	},
	{
		id = "bs_act_shelter",
		category = "people",
		name = "Help out at a night shelter",
		desc = "Blankets, tea and a door that opens until 3:12. Grandmother Ilse always needs hands.",
		minAge = 14,
		cooldown = 2,
		when = { side = "backstreets" },
		result = { sanity = { 3, 5 }, mind = 1, log = "You helped Grandmother Ilse set out blankets at the Lamplight House and poured tea for strangers who'd misjudged the time. You were home yourself by half past two." },
	},
	{
		id = "bs_act_teach_kids",
		category = "people",
		name = "Teach the alley kids to fight",
		desc = "How to stand, how to fall, how to run. Needs mastery 3 in your style.",
		minAge = 20,
		cooldown = 2,
		when = { minMastery = 3 },
		result = { sanity = { 2, 4 }, strength = 1, wage = { 5, 15 }, log = "You taught a dozen alley kids how to stand, how to fall, and above all how to run. Your {style} looked good on small people. Two of their mothers brought you dumplings." },
	},

	-- ── quest steps ────────────────────────────────────────────────────────
	{
		id = "bs_qa_ask_crest",
		category = "city",
		name = "Ask about the crest",
		desc = "Take the coat round the old Fixers who sit outside their Offices in the afternoon.",
		when = { flags = { "bs_q_coat_ask" }, notFlags = { "bs_q_coat_asked" } },
		result = { setFlags = { "bs_q_coat_asked" }, mind = 1, log = "You showed the crest to every old Fixer on the street. Most shook their heads. The last one, an old woman with a cane, looked at it for a very long time." },
	},
	{
		id = "bs_qa_key_cutter",
		category = "city",
		name = "Visit the key-cutter",
		desc = "The last Rep of the Latch Office cuts keys at a stall in the market.",
		when = { flags = { "bs_q_coat_find" }, notFlags = { "bs_q_coat_found" } },
		result = { setFlags = { "bs_q_coat_found" }, trigger = "bs_q_coat_truth", log = "You found the stall at the back of the market, with a tiny crest painted on its sign: a key inside a circle." },
	},
	{
		id = "bs_qa_pay_debt",
		category = "money",
		name = "Pay Teodor's debt",
		desc = "Two hundred Ahn, paid at the Thumb's table with every correct title. A wrong word costs extra.",
		when = { flags = { "bs_q_teodor_pay" }, notFlags = { "bs_q_teodor_paid" }, min = { money = 200 } },
		clash = { stat = "mind", foe = "The Thumb's etiquette", coins = 2, base = 4, coinPower = 3 },
		win = { money = -200, mind = 2, setFlags = { "bs_q_teodor_paid" }, codex = "fingers_thumb", log = "You bowed to the exact depth for a Soldato Terzo, set the envelope down with both hands, and named Teodor's debt by its proper date. The Soldato counted it, stamped the ledger, and said, \"Respectfully settled.\"" },
		lose = { money = -240, sanity = -2, setFlags = { "bs_q_teodor_paid" }, codex = "fingers_thumb", log = "You used one wrong title, and the debt went up forty Ahn on the spot, as a lesson. You paid it. Teodor's name came out of the ledger all the same." },
	},
}
