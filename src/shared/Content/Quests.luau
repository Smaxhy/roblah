--[[
	Side quests: multi-step stories. An event or activity starts one with
	result = { quest = "id" }. Each step says what to do; it's done when its
	`check` passes (same keys as Records: when, tally...). A step's onStart result
	runs when the step begins: set a flag that opens an activity or expedition,
	schedule a scene, add a person. Finishing applies `reward`.

	Expeditions set the flag done_<expeditionId> when they succeed, so a step can
	wait on one: check = { when = { flags = { "done_my_expedition" } } }.

	Where the pieces live: offer events in Content/Events (any module), quest
	activities in Content/QuestActivities.luau, quest expeditions in
	Content/QuestExpeditions.luau.

	Fields: name, desc, giver (flavor), expires (years before it's lost), steps =
	{ { text, hint, check, onStart, doneLog } }, reward.
]]

return {
	order = {
		"missing_ferryman",
		"old_chalk",
		"hundredth_step",
		"old_sister",
		"torn_page",
		"dead_seal",
		"bell_garden",
		"little_wick",
		"stolen_minutes",
		"old_pact",
		"two_forges",
	},

	missing_ferryman = {
		name = "The Missing Ferryman",
		desc = "Old Brask's ferry drifted into the Kelpmarket stairs with its lamp lit and nobody aboard.",
		giver = "The Kelpmarket harbormaster",
		expires = 6,
		steps = {
			{
				text = "Ask around the Kelpmarket docks about the empty ferry.",
				hint = "Activities: Ask about the empty ferry",
				onStart = { setFlags = { "q_ferry_ask" }, log = "The harbormaster gave you Brask's last route, scrawled on a bun wrapper." },
				check = { when = { flags = { "q_ferry_clue" } } },
				doneLog = "A net-mender saw Brask's ferry stop at the old cannery pilings, after dark.",
			},
			{
				text = "Search the old cannery pilings at low water.",
				hint = "Expeditions: The Cannery Pilings",
				onStart = { setFlags = { "q_ferry_search" } },
				check = { when = { flags = { "done_cannery_pilings" } } },
				doneLog = "You found Brask's lantern hook, and a trail of wet footprints going up, not down.",
			},
			{
				text = "Wait for word of Brask.",
				hint = "It'll come within a year.",
				onStart = { schedule = { event = "quest_ferryman_return", inYears = 1 } },
				check = { when = { flags = { "q_ferry_done" } } },
			},
		},
		reward = { wage = { 80, 150 }, sanity = 4, addRelation = { kind = "friend", name = "Brask Coldwater", bond = 75, age = { 60, 70 } }, log = "Brask pressed a carved float into your hand. 'For the ferry you'll own someday.'" },
	},

	-- ── Saltpan, teens, needs a crew: an old pony and a forgotten road ──
	old_chalk = {
		name = "Old Chalk",
		desc = "The Saltworks sold its old cart pony to the Foundry Row bellows-yards. A forgotten salt road runs through the crater wall to the Salt Flats, if you can find it and friends to walk it with.",
		giver = "The Saltworks stable boy",
		expires = 10,
		steps = {
			{
				text = "Win Old Chalk's trust in the salt stables.",
				hint = "Activities: Groom Old Chalk",
				onStart = { setFlags = { "q_chalk_groom" }, log = "The stable boy showed you where the curry comb was hidden. 'He bites,' he said. 'Mostly me.'" },
				check = { when = { flags = { "q_chalk_trusts" } } },
				doneLog = "By the end of the week, Chalk followed you down the stable row without a halter, and bit the stable boy twice.",
			},
			{
				text = "Find the old salt road through the crater wall.",
				hint = "Activities: Ask the old carters about the salt road",
				onStart = { setFlags = { "q_chalk_road" } },
				check = { when = { flags = { "q_chalk_map" } } },
				doneLog = "An old carter drew the salt road on the back of your hand in lamp-black: in at the dry culvert under Pan Nine, through the crater wall, and out onto the white.",
			},
			{
				text = "Lead Chalk down the old salt road with a crew of friends.",
				hint = "Expeditions: The Old Salt Road. Needs a crew of 2 to 4; you can ask a linked friend from Activities.",
				onStart = { setFlags = { "q_chalk_walk" } },
				check = { when = { flags = { "done_old_salt_road" } } },
				doneLog = "Chalk walked out of the crater wall into the sunlight of the Salt Flats, sneezed twice, and started eating a salt-cutter's hat.",
			},
			{
				text = "Wait for word from the Salt Flats.",
				hint = "It'll come within a year.",
				onStart = { setFlags = { "q_chalk_wait" }, schedule = { event = "quest_chalk_letter", inYears = 1 } },
				check = { when = { flags = { "q_chalk_done" } } },
			},
		},
		reward = {
			wage = { 30, 60 },
			fortitude = 3,
			sanity = 5,
			gear = "oilskin",
			addRelation = { kind = "friend", name = "Ilse Marrow", bond = 60, age = { 40, 55 } },
			log = "Ilse Marrow, the salt-cutters' headwoman, sent a purse for the pony, an oilskin for the road, and a standing invitation to come out to the white whenever you liked.",
		},
	},

	-- ── Bellhollow, teens: the stair that sometimes has a hundred steps ──
	hundredth_step = {
		name = "The Hundredth Step",
		desc = "Bellhollow's Counting Stair has ninety-nine steps. At midnight, sometimes, it has a hundred, and the extra one goes down.",
		giver = "The Counting Stair",
		expires = 6,
		steps = {
			{
				text = "Count the Counting Stair at midnight until the hundredth step comes back.",
				hint = "Activities: Count the stair at midnight",
				onStart = { setFlags = { "q_step_count" } },
				check = { when = { flags = { "q_step_found" } } },
				doneLog = "There it was again: step eighty-one, wet and dark, and below it a narrow stair going down between the stones, lit by something warm.",
			},
			{
				text = "Go down the hundredth step.",
				hint = "Expeditions: Below the Hundredth Step",
				onStart = { setFlags = { "q_step_down" } },
				check = { when = { flags = { "done_below_hundredth_step" } } },
				doneLog = "Under the Counting Stair is a bell-maker's workshop two hundred years old, with a bell that has no voice and a note: Whoever counts a hundred, mend my bell.",
			},
			{
				text = "Get the cracked clapper recast.",
				hint = "Activities: Take the cracked clapper to the Bellwrights",
				onStart = { setFlags = { "q_step_clapper" } },
				check = { when = { flags = { "q_step_recast" } } },
				doneLog = "The oldest Bellwright recast the clapper in bright new bronze and gave it back wrapped in your scarf. 'Hang it at Midsummer,' she said. 'That's when he'd have rung it.'",
			},
			{
				text = "Hang the new clapper on Midsummer night.",
				hint = "Midsummer comes round within the year.",
				onStart = { setFlags = { "q_step_wait" }, schedule = { event = "quest_step_midsummer", inYears = 1 } },
				check = { when = { flags = { "q_step_done" } } },
			},
		},
		reward = {
			temperance = 3,
			sanity = 4,
			gear = "little_bell",
			addRelation = { kind = "mentor", name = "Wynn Tolley", bond = 55, age = { 66, 78 } },
			log = "Wynn Tolley, the oldest Bellwright, cast you a little bell from the leftover bronze and said you could sweep her foundry any time you liked. On nights when nothing touches it, the bell rings.",
		},
	},

	-- ── Lantern Guild, needs a crew: raising the Guild's first diving bell ──
	old_sister = {
		name = "The Old Sister",
		desc = "The Lantern Guild's first diving bell has sat on the bottom of the Mere for fifty years. The Captains want her raised for the Guild's hundredth Lantern Night.",
		giver = "The Lantern-Captains",
		expires = 10,
		steps = {
			{
				text = "Study the Old Sister's charts in the Guild hall.",
				hint = "Activities: Study the Old Sister's charts",
				onStart = { setFlags = { "q_sister_charts" } },
				check = { when = { flags = { "q_sister_charted" } } },
				doneLog = "The charts put the Old Sister two hundred feet down off the end of Chandlers' Row, sitting upright in the silt like a bell on a shelf.",
			},
			{
				text = "Dive with a crew and shackle new lifting chains to the Old Sister.",
				hint = "Expeditions: The Old Sister. Needs a crew of 2 to 4; you can ask a linked friend from Activities.",
				onStart = { setFlags = { "q_sister_dive" } },
				check = { when = { flags = { "done_old_sister_dive" } } },
				doneLog = "New chains are shackled to the Old Sister's crown. Inside her, the air was dry, and four names were scratched into the brass beside the bench.",
			},
			{
				text = "Find the families of the Old Sister's last crew.",
				hint = "Activities: Visit the last crew's families",
				onStart = { setFlags = { "q_sister_names" } },
				check = { when = { flags = { "q_sister_visited" } } },
				doneLog = "Three of the four names still have family in the Gutters, and all three want to be on the pier when she comes up.",
			},
			{
				text = "Wait for the Guild's hundredth Lantern Night.",
				hint = "It comes within a year.",
				onStart = { setFlags = { "q_sister_wait" }, schedule = { event = "quest_sister_raising", inYears = 1 } },
				check = { when = { flags = { "q_sister_done" } } },
			},
		},
		reward = {
			promote = true,
			gear = "diving_lamp",
			wage = { 60, 120 },
			sanity = 4,
			log = "The Lantern-Captains hung the Old Sister in the Guild hall and gave you a lamp from her own rack. A lantern went down, and fifty years later, a lantern came up.",
		},
	},

	-- ── Brine Kin mystery, two endings: who cut the Brackwater Steps page? ──
	torn_page = {
		name = "The Torn Page",
		desc = "Someone cut the Brackwater Steps page out of the Brine Kin's great ledger. The Elder Kin wants it back, and the hand that cut it.",
		giver = "The Elder Kin",
		expires = 8,
		steps = {
			{
				text = "Ask the cousins who was near the ledger the night it was cut.",
				hint = "Activities: Ask the cousins about the torn page",
				onStart = { setFlags = { "q_page_ask" } },
				check = { when = { flags = { "q_page_lead" } } },
				doneLog = "A boatman saw a lantern moving in the drowned net lofts under the Brackwater Steps the night the page went missing. Nobody has used those lofts since the High Water took them.",
			},
			{
				text = "Search the drowned net lofts under the Brackwater Steps.",
				hint = "Expeditions: The Brackwater Net Lofts",
				onStart = { setFlags = { "q_page_search" } },
				check = { when = { flags = { "done_brackwater_lofts" } } },
				doneLog = "You found the page in the rafters, dry in an oilcloth packet. Pinned to it was a note in an old, careful hand: PLEASE. NOT THIS YEAR.",
			},
			{
				text = "Match the handwriting on the note to a hand in the great ledger.",
				hint = "Activities: Match the handwriting",
				onStart = { setFlags = { "q_page_hand" } },
				check = { when = { flags = { "q_page_matched" } } },
				doneLog = "The hand that wrote PLEASE wrote half the great ledger: Mab Brackwater, Ledger-hand for forty years, born on the Brackwater Steps.",
			},
			{
				text = "Hear Mab Brackwater out.",
				hint = "Activities: Visit Mab Brackwater",
				onStart = { setFlags = { "q_page_visit" } },
				check = { when = { flags = { "q_page_heard" } } },
				doneLog = "Mab didn't deny it. The Sluice will open the spill gate onto the Brackwater Steps next High Water, she said, and the Kin will still collect from forty families about to lose everything. 'I wrote those debts down,' she said. 'I can cut them out.'",
			},
			{
				text = "Give the Elder Kin your answer: the page and Mab's name, or ashes.",
				hint = "She'll call for you within the year.",
				onStart = { setFlags = { "q_page_decide" }, schedule = { event = "quest_page_answer", inYears = 1 } },
				-- both endings set q_page_done (and q_page_returned or q_page_burned)
				check = { when = { flags = { "q_page_done" } } },
			},
		},
		reward = {
			wage = { 50, 100 },
			prudence = 3,
			gear = "pocket_ledger",
			log = "After that winter, the cousins went quiet when you walked into a room, which in the Kin is a kind of respect. You started keeping a pocket ledger of your own: every debt, every favor, every name.",
		},
	},

	-- ── Sluice Authority: a standing order nobody living signed ──
	dead_seal = {
		name = "The Dead Commissioner's Seal",
		desc = "Every High Water, a standing order sealed by a Commissioner thirty years dead floods Anchor Court in the Silt. Nobody living will say who keeps sending it.",
		giver = "Your own in-tray",
		expires = 8,
		steps = {
			{
				text = "Pull the original order from the sealed archive.",
				hint = "Activities: Search the sealed archive",
				onStart = { setFlags = { "q_seal_archive" } },
				check = { when = { flags = { "q_seal_file" } } },
				doneLog = "The original order drowns Anchor Court to keep a Charter vault dry, and it was sealed the night Commissioner Gale died. Nobody has signed it since. Something in the gatehouse sends it out anyway.",
			},
			{
				text = "Get into the gatehouse and find what keeps sending the order.",
				hint = "Expeditions: The Order Drums",
				onStart = { setFlags = { "q_seal_gate" } },
				check = { when = { flags = { "done_order_drums" } } },
				doneLog = "The standing order is a brass pin on a turning drum under the gate, and now it's in your pocket. To make it stick, the change needs a living signature.",
			},
			{
				text = "Get a living Commissioner to countersign the change.",
				hint = "Activities: Petition the Commissioner",
				onStart = { setFlags = { "q_seal_sign" } },
				check = { when = { flags = { "q_seal_signed" } } },
				doneLog = "The Commissioner signed without reading it, which is how most things in the Sluice Authority get done, good and bad.",
			},
			{
				text = "Wait for the order day.",
				hint = "It comes round with the autumn storms.",
				onStart = { setFlags = { "q_seal_wait" }, schedule = { event = "quest_seal_order_day", inYears = 1 } },
				check = { when = { flags = { "q_seal_done" } } },
			},
		},
		reward = {
			promote = true,
			justice = 3,
			wage = { 60, 120 },
			gear = "tide_tables",
			log = "The Authority promoted you to make the paperwork go away, and you kept Commissioner Gale's sea-stained tide tables from the archive. Anchor Court sent a cake up to the Sluice house with your name on it. The senior clerk ate half.",
		},
	},

	-- ── the Choir, elders: the drowned bell garden rings again ──
	bell_garden = {
		name = "The Bell Garden",
		desc = "Silent for sixty years, the Bellwrights' drowned bell garden has started ringing again, and only you can hear it.",
		giver = "The Still Voice",
		expires = 6,
		steps = {
			{
				text = "Sit a night vigil by the water and learn what the bells are ringing.",
				hint = "Activities: Sit the night vigil",
				onStart = { setFlags = { "q_bells_vigil" } },
				check = { when = { flags = { "q_bells_heard" } } },
				doneLog = "By dawn you had it: not a tune but a count, the same seven strokes over and over, the way the Choir rings the end of a long silence.",
			},
			{
				text = "Go out to the drowned bell garden.",
				hint = "Expeditions: The Drowned Bell Garden",
				onStart = { setFlags = { "q_bells_garden" } },
				check = { when = { flags = { "done_drowned_bell_garden" } } },
				doneLog = "The ringing was a Choir hand bell, lost sixty years ago, still ringing the end of a silence nobody had finished.",
			},
			{
				text = "Teach the seven strokes to the Choir's youngest Listener.",
				hint = "Activities: Teach the youngest Listener",
				onStart = { setFlags = { "q_bells_teach" } },
				check = { when = { flags = { "q_bells_taught" } } },
				doneLog = "The youngest Listener learned the seven strokes in an afternoon, then rang them on a teacup with a spoon until everyone begged her to stop.",
			},
			{
				text = "Ring the end of the silence on the anniversary night.",
				hint = "It comes round within the year.",
				onStart = { setFlags = { "q_bells_wait" }, schedule = { event = "quest_bells_silence", inYears = 1 } },
				check = { when = { flags = { "q_bells_done" } } },
			},
		},
		reward = {
			promote = true,
			gear = "still_stone",
			sanity = 6,
			prudence = 2,
			log = "The Still Voice gave you a smooth stone from the Choir's shore, the kind only Cantors carry. On still nights you can still hear the bell garden, very faintly, ringing nothing at all.",
		},
	},

	-- ── family: your child adopts a baby lamp-eater ──
	little_wick = {
		name = "Wick",
		desc = "{child} has adopted a baby lamp-eater named Wick. Lamp-eaters snuff every light they find, and Wick is growing.",
		giver = "Your child",
		expires = 8,
		steps = {
			{
				text = "Find out how to look after a lamp-eater.",
				hint = "Activities: Ask the old divers about lamp-eaters",
				onStart = { setFlags = { "q_wick_ask" } },
				check = { when = { flags = { "q_wick_fed" } } },
				doneLog = "A thimble of lamp oil a night, said the old divers, and the last flicker of a snuffed candle for a treat. Wick slept in the teapot, and grew.",
			},
			{
				text = "Help {child} keep Wick out of the neighbors' lamps.",
				hint = "Activities: Keep Wick out of the stairwell lamps",
				onStart = { setFlags = { "q_wick_lamps" } },
				check = { when = { flags = { "q_wick_behaved" } } },
				doneLog = "By spring Wick was the size of a dog, and no jam-jar lamp in the Gutters could feed him. It was time for Wick to go home.",
			},
			{
				text = "Take Wick to the lamp-eaters' roost under the Lampwick gasworks pier.",
				hint = "Expeditions: The Lamp-Eaters' Roost",
				onStart = { setFlags = { "q_wick_roost" } },
				check = { when = { flags = { "done_lamp_eater_roost" } } },
				doneLog = "Wick went up into the roost among a hundred others, grey and soft and humming, and didn't look back. Your child did, all the way home.",
			},
			{
				text = "Wait for Lantern Night.",
				hint = "It comes once a year.",
				onStart = { setFlags = { "q_wick_wait" }, schedule = { event = "quest_wick_visit", inYears = 1 } },
				check = { when = { flags = { "q_wick_done" } } },
			},
		},
		reward = {
			relationBond = { kind = "child", amount = 12 },
			sanity = 5,
			prudence = 2,
			gear = "lantern_token",
			log = "In the morning there was a brass token on your step, stamped with a lantern and warm to the touch: the sort of shiny thing a lamp-eater might carry a very long way to give somebody.",
		},
	},

	-- ── the Charter, two endings: the company clock runs four minutes fast ──
	stolen_minutes = {
		name = "The Stolen Minutes",
		desc = "The company clock over the Charter gate runs four minutes fast, and every shift in the Gutters runs by it.",
		giver = "The Bellhollow bells",
		expires = 8,
		steps = {
			{
				text = "Time the company clock against the Bellhollow bells.",
				hint = "Activities: Time the company clock",
				onStart = { setFlags = { "q_minutes_time" } },
				check = { when = { flags = { "q_minutes_timed" } } },
				doneLog = "Four minutes fast at the start of every shift and four minutes slow at the end of it, every day, for thirty years. That isn't a broken clock. That's a ledger.",
			},
			{
				text = "Climb the gate clock tower and see what's been done to it.",
				hint = "Expeditions: The Gate Clock",
				onStart = { setFlags = { "q_minutes_tower" } },
				check = { when = { flags = { "done_gate_clock" } } },
				doneLog = "Bolted inside the clock was a brass governor with the company's seal, and a little leather ledger of minutes recovered, thirty years of them, totaled in red at the bottom of every page.",
			},
			{
				text = "Add up what the stolen minutes are worth.",
				hint = "Activities: Add up the stolen minutes",
				onStart = { setFlags = { "q_minutes_sum" } },
				check = { when = { flags = { "q_minutes_summed" } } },
				doneLog = "Thirty years of four minutes a day, for every worker in the Gutters, comes to more scrip than the company spends on its glasshouses, its guards and its Director's carriage put together.",
			},
			{
				text = "Decide what to do with the minutes ledger.",
				hint = "Someone will come asking for it within the year.",
				onStart = { setFlags = { "q_minutes_decide" }, schedule = { event = "quest_minutes_visitor", inYears = 1 } },
				-- both endings set q_minutes_done (and q_minutes_posted or q_minutes_sold)
				check = { when = { flags = { "q_minutes_done" } } },
			},
		},
		reward = {
			temperance = 3,
			prudence = 2,
			sanity = 2,
			log = "Whatever anyone said about it afterward, you never again heard the company clock strike without counting.",
		},
	},

	-- ── Kelpmarket, elders: a promise made on a carousel sixty years ago ──
	old_pact = {
		name = "The Carousel Pact",
		desc = "Five children swore to meet on the Kelpmarket carousel when they were old. Then the High Water took it. Now its roof shows at low tide, and you're old.",
		giver = "Your eleven-year-old self",
		expires = 6,
		steps = {
			{
				text = "Find out who's left of the old crew.",
				hint = "Activities: Look up the old crew",
				onStart = { setFlags = { "q_pact_find" } },
				check = { when = { flags = { "q_pact_found" } } },
				doneLog = "Of the five who swore, three are left: you, Pell Shadwell, who lives two streets over and still cheats at everything, and Una Fairweather, who went up to the Charter forty years ago and never came back down.",
			},
			{
				text = "Write to Una Fairweather in the Charter.",
				hint = "Activities: Write to Una in the Charter",
				onStart = { setFlags = { "q_pact_write" } },
				check = { when = { flags = { "q_pact_written" } } },
				doneLog = "Una wrote back by return in a shaky hand: 'I've kept my badge. Of course I'm coming. Tell Pell he still owes me a bun.'",
			},
			{
				text = "Get the old crew out to the drowned carousel at low tide.",
				hint = "Expeditions: The Drowned Carousel",
				onStart = { setFlags = { "q_pact_carousel" } },
				check = { when = { flags = { "done_drowned_carousel" } } },
				doneLog = "The three of you sat on the carousel steps with the tin box open between you, and for an hour nobody was old at all.",
			},
			{
				text = "Keep the pact.",
				hint = "The low tides come round again within the year.",
				onStart = { setFlags = { "q_pact_wait" }, schedule = { event = "quest_pact_kept", inYears = 1 } },
				check = { when = { flags = { "q_pact_done" } } },
			},
		},
		reward = {
			sanity = 6,
			prudence = 2,
			addRelation = { kind = "friend", name = "Pell Shadwell", bond = 80 },
			log = "Pell Shadwell still cheats at everything and still owes Una a bun. He's at your door every low tide, and most days in between.",
		},
	},

	-- ── Foundry Row Gutters: two feuding forges and two missing children ──
	two_forges = {
		name = "Two Forges",
		desc = "A child from each of two feuding forges on Anvil Lane has gone missing, and each family blames the other. Find them before the hammers come out.",
		giver = "Anvil Lane",
		expires = 6,
		steps = {
			{
				text = "Keep the two forges from coming to blows while you search.",
				hint = "Activities: Talk down Anvil Lane",
				onStart = { setFlags = { "q_forge_calm" } },
				check = { when = { flags = { "q_forge_quiet" } } },
				doneLog = "With the lane quiet for one night, a coal-runner told you what she'd seen: two kids with a lamp and a sack of bread, climbing the dead crane at the bottom of Anvil Lane.",
			},
			{
				text = "Climb the dead crane and talk the children down.",
				hint = "Expeditions: The Dead Crane",
				onStart = { setFlags = { "q_forge_crane" } },
				check = { when = { flags = { "done_dead_crane" } } },
				doneLog = "Dov and Jessamy had run away together, on purpose. They only came down because you promised them one thing: that both their families would sit at one table.",
			},
			{
				text = "Wait for Anvil Lane to keep the children's bargain.",
				hint = "It'll take them most of a year to get round to it.",
				onStart = { setFlags = { "q_forge_wait" }, schedule = { event = "quest_forge_table", inYears = 1 } },
				check = { when = { flags = { "q_forge_done" } } },
			},
		},
		reward = {
			wage = { 40, 80 },
			justice = 3,
			sanity = 4,
			gear = "dock_knife",
			addRelation = { kind = "friend", name = "Jessamy Harrow", bond = 65, age = { 12, 13 } },
			log = "The Drabbs forged the blade and the Harrows made the handle: a short, ugly, honest knife, the first thing the two forges ever made together. Jessamy Harrow carved your initials in it, badly.",
		},
	},
}
