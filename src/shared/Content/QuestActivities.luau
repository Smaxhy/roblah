--[[
	Activities that side quests open up (usually gated by a quest flag in `when`).
	Same format as pack.activities.
]]

return {
	{
		id = "quest_ask_ferry",
		category = "people",
		name = "Ask about the empty ferry",
		desc = "Net-menders, eel-sellers, the night watch. Somebody saw something.",
		minAge = 14,
		when = { flags = { "q_ferry_ask" }, notFlags = { "q_ferry_clue" } },
		result = { setFlags = { "q_ferry_clue" }, clearFlags = { "q_ferry_ask" }, prudence = 1, log = "You bought three rounds of kelp tea and learned where Brask's ferry stopped last." },
	},

	-- ── Old Chalk ──
	{
		id = "quest_chalk_groom",
		category = "people",
		name = "Groom Old Chalk",
		desc = "A curry comb, a bucket of warm water and a great deal of patience. He bites.",
		minAge = 13,
		when = { flags = { "q_chalk_groom" }, notFlags = { "q_chalk_trusts" } },
		clash = { stat = "temperance", foe = "Old Chalk's temper", coins = 1, base = 2, coinPower = 2 },
		win = { setFlags = { "q_chalk_trusts" }, clearFlags = { "q_chalk_groom" }, temperance = 1, sanity = 2, log = "You brushed the salt out of Chalk's coat until it shone, and he leaned his whole weight against you, which in a pony means yes." },
		lose = { sanity = -1, log = "Chalk bit your sleeve, then your other sleeve, then stood on your foot until you went home." },
	},
	{
		id = "quest_chalk_carters",
		category = "people",
		name = "Ask the old carters about the salt road",
		desc = "The salt carts stopped using the old road before your parents were born. The men who drove them still sit on the same bench outside the Saltworks gate every afternoon.",
		minAge = 13,
		when = { flags = { "q_chalk_road" }, notFlags = { "q_chalk_map" } },
		result = { setFlags = { "q_chalk_map" }, clearFlags = { "q_chalk_road" }, prudence = 1, log = "You sat on the carters' bench all afternoon while four old men argued about a road none of them had walked in fifty years. In the end, they agreed on it." },
	},
	{
		id = "quest_chalk_crew",
		category = "people",
		name = "Ask {linked} to walk the salt road",
		desc = "It takes two to lead a pony through a tunnel. A linked friend who says yes can join your crew for the Old Salt Road.",
		minAge = 13,
		cooldown = 1,
		when = { linked = true, flags = { "q_chalk_walk" }, notFlags = { "done_old_salt_road" } },
		result = {
			sanity = 1,
			log = "You told {linked} all about Old Chalk, and {linked} said yes before you'd finished.",
			linked = { setFlags = { "q_chalk_walk" }, log = "{sender} asked you to help lead an old pony down the salt road to the Salt Flats. It's under Expeditions: The Old Salt Road." },
		},
	},

	-- ── The Hundredth Step ──
	{
		id = "quest_step_count",
		category = "self",
		name = "Count the stair at midnight",
		desc = "Ninety-nine steps, counted out loud, after the hundred bells ring midnight. Lose count and you start again at the top.",
		minAge = 13,
		when = { flags = { "q_step_count" }, notFlags = { "q_step_found" } },
		clash = { stat = "prudence", foe = "Losing count", coins = 1, base = 3, coinPower = 2 },
		win = { setFlags = { "q_step_found" }, clearFlags = { "q_step_count" }, prudence = 1, log = "You counted every step out loud, ninety-eight, ninety-nine, a hundred, and the hundredth step was there, wet and dark, going down." },
		lose = { sanity = -1, log = "You lost count somewhere in the seventies when a cat ran past, and had to go home and try again." },
	},
	{
		id = "quest_step_bellwright",
		category = "people",
		name = "Take the cracked clapper to the Bellwrights",
		desc = "A bronze clapper two hundred years old, cracked clean through. The Bellwrights' foundry casts a hundred bells a year.",
		minAge = 13,
		when = { flags = { "q_step_clapper" }, notFlags = { "q_step_recast" } },
		result = { setFlags = { "q_step_recast" }, clearFlags = { "q_step_clapper" }, temperance = 1, log = "The oldest Bellwright turned the clapper over in her hands for a long time, took off her spectacles, and said she'd recast it herself, for nothing, if you told her where you found it. You told her. She didn't laugh." },
	},

	-- ── The Old Sister ──
	{
		id = "quest_sister_charts",
		category = "self",
		name = "Study the Old Sister's charts",
		desc = "Fifty-year-old soundings, a storm log, and a chart drawn by a Captain whose hand was shaking.",
		minAge = 16,
		when = { flags = { "q_sister_charts" }, notFlags = { "q_sister_charted" } },
		result = { setFlags = { "q_sister_charted" }, clearFlags = { "q_sister_charts" }, temperance = 2, log = "You worked through the old soundings by lamplight until you could have drawn the bottom of the Mere with your eyes shut." },
	},
	{
		id = "quest_sister_crew",
		category = "people",
		name = "Ask {linked} to crew the Old Sister",
		desc = "The Captains want a crew of two or more for the Old Sister, and they'll take any steady hands you vouch for. A linked friend who agrees can join you.",
		minAge = 16,
		cooldown = 1,
		when = { linked = true, flags = { "q_sister_dive" }, notFlags = { "done_old_sister_dive" } },
		result = {
			sanity = 1,
			log = "You asked {linked} to crew the Old Sister with you. {linked} checked your knots twice and said yes.",
			linked = { setFlags = { "q_sister_dive" }, log = "{sender} vouched for you with the Lantern-Captains, and now you're on the Old Sister's dive crew. It's under Expeditions: The Old Sister." },
		},
	},
	{
		id = "quest_sister_families",
		category = "people",
		name = "Visit the last crew's families",
		desc = "Four names scratched inside a brass bell fifty years ago. Somebody should knock on their doors.",
		minAge = 16,
		when = { flags = { "q_sister_names" }, notFlags = { "q_sister_visited" } },
		result = { setFlags = { "q_sister_visited" }, clearFlags = { "q_sister_names" }, justice = 2, sanity = 2, log = "You knocked on three doors in the Gutters with your Guild cap in your hands. Three old women made you kelp tea, and one of them laughed and cried at the same time." },
	},

	-- ── The Torn Page ──
	{
		id = "quest_page_ask",
		category = "people",
		name = "Ask the cousins about the torn page",
		desc = "Every cousin owes every other cousin something. Somebody will trade what they saw.",
		minAge = 15,
		when = { flags = { "q_page_ask" }, notFlags = { "q_page_lead" } },
		clash = { stat = "prudence", foe = "Cousins who saw nothing", coins = 2, base = 4, coinPower = 3 },
		win = { setFlags = { "q_page_lead" }, clearFlags = { "q_page_ask" }, prudence = 1, log = "You forgave a boatman a small debt, and all at once he remembered a lantern moving in the drowned net lofts under the Brackwater Steps." },
		lose = { sanity = -2, log = "Every cousin you asked had been somewhere else that night, all of them together, and they all said so at once." },
	},
	{
		id = "quest_page_hand",
		category = "self",
		name = "Match the handwriting",
		desc = "PLEASE. NOT THIS YEAR. Every Ledger-hand in the Kin has written in the great ledger, and one of them wrote this.",
		minAge = 15,
		when = { flags = { "q_page_hand" }, notFlags = { "q_page_matched" } },
		clash = { stat = "temperance", foe = "Forty years of handwriting", coins = 2, base = 4, coinPower = 3 },
		win = { setFlags = { "q_page_matched" }, clearFlags = { "q_page_hand" }, temperance = 2, log = "You turned the great ledger's pages by lamplight until one careful hand jumped out at you. It had written half the book." },
		lose = { sanity = -1, log = "You turned the ledger's pages until your eyes swam. By midnight every hand looked like every other." },
	},
	{
		id = "quest_page_mab",
		category = "people",
		name = "Visit Mab Brackwater",
		desc = "An old Ledger-hand in a one-room stilt-house on the Brackwater Steps, with the best penmanship in the Silt and a very sharp knife.",
		minAge = 15,
		when = { flags = { "q_page_visit" }, notFlags = { "q_page_heard" } },
		result = { setFlags = { "q_page_heard" }, clearFlags = { "q_page_visit" }, prudence = 1, sanity = -1, log = "You sat in Mab Brackwater's stilt-house while she made kelp tea, and she told you everything without once looking away." },
	},

	-- ── The Dead Commissioner's Seal ──
	{
		id = "quest_seal_archive",
		category = "self",
		name = "Search the sealed archive",
		desc = "Thirty years of flood orders in the basement of the Sluice house, and a filing system only the dead understood.",
		minAge = 18,
		when = { flags = { "q_seal_archive" }, notFlags = { "q_seal_file" } },
		clash = { stat = "temperance", foe = "The Sluice filing system", coins = 2, base = 4, coinPower = 3 },
		win = { setFlags = { "q_seal_file" }, clearFlags = { "q_seal_archive" }, temperance = 2, log = "You found the original order behind a cabinet marked MISCELLANEOUS, WET." },
		lose = { sanity = -2, log = "You came up from the archive at midnight with ink to the elbows and nothing to show for it." },
	},
	{
		id = "quest_seal_petition",
		category = "people",
		name = "Petition the Commissioner",
		desc = "Seven floors up, one secretary, three forms in triplicate, and a Commissioner who signs things to make them go away.",
		minAge = 18,
		when = { flags = { "q_seal_sign" }, notFlags = { "q_seal_signed" } },
		clash = { stat = "prudence", foe = "The Commissioner's secretary", coins = 2, base = 4, coinPower = 3 },
		win = { setFlags = { "q_seal_signed" }, clearFlags = { "q_seal_sign" }, prudence = 2, log = "You sat on the secretary's bench for three days with your forms on your knees, until she gave up and sent you in." },
		lose = { sanity = -2, log = "The secretary lost your petition, then lost it again, then lost you. You'll have to start the forms over." },
	},

	-- ── The Bell Garden ──
	{
		id = "quest_bells_vigil",
		category = "self",
		name = "Sit the night vigil",
		desc = "Dusk to dawn on the ferry steps without a word. Old knees, cold stone, and bells under the water.",
		minAge = 50,
		when = { flags = { "q_bells_vigil" }, notFlags = { "q_bells_heard" } },
		clash = { stat = "prudence", foe = "The long cold night", coins = 2, base = 4, coinPower = 3 },
		win = { setFlags = { "q_bells_heard" }, clearFlags = { "q_bells_vigil" }, sanity = 3, log = "You sat until dawn without moving and counted every stroke the water rang, until you knew the count by heart." },
		lose = { sanity = -2, log = "The cold got into your knees by midnight, and you had to go home before the bells began." },
	},
	{
		id = "quest_bells_teach",
		category = "people",
		name = "Teach the youngest Listener",
		desc = "Seven strokes nobody alive remembers have to be remembered by somebody. The Choir's youngest Listener has a good ear and no patience at all.",
		minAge = 50,
		when = { flags = { "q_bells_teach" }, notFlags = { "q_bells_taught" } },
		result = { setFlags = { "q_bells_taught" }, clearFlags = { "q_bells_teach" }, temperance = 1, sanity = 3, log = "You taught the youngest Listener the seven strokes, slowly and patiently, until she could ring them with her eyes shut." },
	},

	-- ── Wick ──
	{
		id = "quest_wick_divers",
		category = "people",
		name = "Ask the old divers about lamp-eaters",
		desc = "Nobody knows lamp-eaters like the Lantern Guild, and nobody likes them less.",
		minAge = 20,
		when = { flags = { "q_wick_ask" }, notFlags = { "q_wick_fed" } },
		result = { setFlags = { "q_wick_fed" }, clearFlags = { "q_wick_ask" }, prudence = 1, log = "You asked three old divers on the Guild pier how to raise a lamp-eater. Two of them walked away. The third took off his cap, scratched his head, and told you everything." },
	},
	{
		id = "quest_wick_lamps",
		category = "people",
		name = "Keep Wick out of the stairwell lamps",
		desc = "Wick is the size of a cat now, and every lamp on the stairs goes out when he's hungry. The neighbors have noticed.",
		minAge = 20,
		when = { flags = { "q_wick_lamps" }, notFlags = { "q_wick_behaved" }, hasRelation = "child" },
		clash = { stat = "temperance", foe = "A hungry lamp-eater", coins = 1, base = 3, coinPower = 2 },
		win = { setFlags = { "q_wick_behaved" }, clearFlags = { "q_wick_lamps" }, relationBond = { kind = "child", amount = 5 }, log = "You and {child} built Wick a lamp of his own from a jam jar and a candle stub, and for a whole month he left the stairwell alone." },
		lose = { sanity = -2, log = "Wick got into the landing lamp while you weren't looking, and the whole stairwell spent the night in the dark, grumbling at your door." },
	},

	-- ── The Stolen Minutes ──
	{
		id = "quest_minutes_time",
		category = "self",
		name = "Time the company clock",
		desc = "A pocket watch set by the Bellhollow bells, a notebook, and a bench across from the Charter gate, every morning and every evening.",
		minAge = 18,
		when = { flags = { "q_minutes_time" }, notFlags = { "q_minutes_timed" } },
		result = { setFlags = { "q_minutes_timed" }, clearFlags = { "q_minutes_time" }, prudence = 1, log = "You sat on a bench across from the Charter gate every morning and evening for a month, comparing the company clock to the bells. The gate guards started saying good morning." },
	},
	{
		id = "quest_minutes_sum",
		category = "money",
		name = "Add up the stolen minutes",
		desc = "Thirty years, four minutes a day, every worker in the Gutters, at the company's own wage rates. Bring a lot of paper.",
		minAge = 18,
		when = { flags = { "q_minutes_sum" }, notFlags = { "q_minutes_summed" } },
		clash = { stat = "temperance", foe = "Thirty years of arithmetic", coins = 2, base = 4, coinPower = 3 },
		win = { setFlags = { "q_minutes_summed" }, clearFlags = { "q_minutes_sum" }, temperance = 2, log = "You added it up three times, and it came out the same each time: a number with more noughts than anything you'd ever written down." },
		lose = { sanity = -2, log = "You lost your place somewhere in the eleventh year and had to start again from the beginning." },
	},

	-- ── The Carousel Pact ──
	{
		id = "quest_pact_find",
		category = "people",
		name = "Look up the old crew",
		desc = "Five names you haven't said out loud in fifty years, the Kelpmarket ward rolls, and a great many stairs.",
		minAge = 55,
		when = { flags = { "q_pact_find" }, notFlags = { "q_pact_found" } },
		result = { setFlags = { "q_pact_found" }, clearFlags = { "q_pact_find" }, prudence = 1, sanity = -1, log = "You went through the Kelpmarket ward rolls name by name, climbed a great many stairs, and found out who was left." },
	},
	{
		id = "quest_pact_write",
		category = "people",
		name = "Write to Una in the Charter",
		desc = "Una went up to the Rim forty years ago. People who go up to the Rim don't always want to remember the Silt.",
		minAge = 55,
		when = { flags = { "q_pact_write" }, notFlags = { "q_pact_written" } },
		result = { setFlags = { "q_pact_written" }, clearFlags = { "q_pact_write" }, sanity = 2, log = "You wrote Una a letter with a carousel horse drawn in the corner, the way the five of you used to pass notes in the fish market, and sent it up to the Rim." },
	},

	-- ── Two Forges ──
	{
		id = "quest_forge_lane",
		category = "people",
		name = "Talk down Anvil Lane",
		desc = "Two forges, three generations, a great many hammers, and nobody who wants to be the first to put theirs down.",
		minAge = 18,
		when = { flags = { "q_forge_calm" }, notFlags = { "q_forge_quiet" } },
		clash = { stat = "prudence", foe = "Two angry forges", coins = 2, base = 4, coinPower = 3 },
		win = { setFlags = { "q_forge_quiet" }, clearFlags = { "q_forge_calm" }, justice = 2, log = "You stood in the middle of Anvil Lane and talked until the hammers went down, one by one, and somebody put a kettle on." },
		lose = { sanity = -2, fortitude = { -2, 0 }, log = "Nobody wanted to listen. You took a shove in the crowd, and the shouting went on all night." },
	},
}
