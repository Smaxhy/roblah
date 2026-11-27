--[[
	Quest scenes: the offers that start side quests (result.quest), and the
	scenes their steps schedule. See Content/Quests.luau.
]]

return {
	{
		id = "quest_ferryman_offer",
		title = "The Empty Ferry",
		text = "Brask's ferry has drifted into the Kelpmarket stairs with its lamp still lit and nobody at the oar. The harbormaster is asking anyone with sense to look into it. 'He's ferried this water forty years,' she says. 'He doesn't just fall in.'",
		once = true,
		tags = { "strange" },
		when = { minAge = 14, maxAge = 60 },
		choices = {
			{ label = "Say you'll look into it", result = { quest = "missing_ferryman", log = "You said you'd find out what happened to Brask." } },
			{ label = "Leave it to the Lantern Guild", result = { log = "You left it to the Guild. The ferry sat on the stairs for a month." } },
		},
	},
	{
		id = "quest_ferryman_return",
		title = "Brask Comes Home",
		text = "A year to the day after his ferry came back empty, Brask walks up the Kelpmarket stairs, soaked, thin, and smiling. He says he followed a light under the water and found a dry street down there, with a bakery still open.",
		weight = 0,
		tags = { "strange" },
		when = { flags = { "q_ferry_search" } },
		choices = {
			{ label = "Believe him", result = { setFlags = { "q_ferry_done" }, sanity = 3, log = "You believed him. He looked like a man who'd eaten very good bread." } },
			{ label = "Get him to a stitcher", result = { setFlags = { "q_ferry_done" }, prudence = 2, log = "You walked him to a stitcher. He hummed the whole way." } },
		},
	},

	-- ── Old Chalk (Saltpan, teens, needs a crew) ──
	{
		id = "quest_chalk_offer",
		title = "Old Chalk",
		text = "Old Chalk has hauled salt carts across the Saltworks pans for twenty years, a white pony gone whiter with salt. This week the foreman chalked SOLD on his stall door: the Foundry Row bellows-yards buy tired ponies to walk in circles in the dark. The stable boy says an old salt road runs through the crater wall to the Salt Flats, where the cutters pay well for a sledge pony, but nobody could lead a pony through it alone.",
		once = true,
		weight = 26,
		tags = { "quest", "youth", "saltpan" },
		when = { district = "saltpan", minAge = 13, maxAge = 18 },
		choices = {
			{ label = "Swear you'll get Chalk out", result = { quest = "old_chalk", log = "You fed Chalk the core of your apple and swore you'd get him out before the bellows-yard cart came." } },
			{ label = "Say goodbye to him", result = { sanity = -2, log = "You said goodbye to Chalk over the stall door. He blew salt dust into your hair, the way he always did." } },
		},
	},
	{
		id = "quest_chalk_letter",
		title = "Word from the White",
		text = "A year after the salt road, a sledge-runner from the Salt Flats brings you a letter in a hand that clearly hasn't written many. Chalk pulls the water sledge now, it says, and won't start in the mornings until somebody sings to him. At the bottom is a drawing of a pony in a straw hat.",
		weight = 0,
		tags = { "quest", "saltpan" },
		when = { flags = { "q_chalk_wait" }, notFlags = { "q_chalk_done" } },
		choices = {
			{ label = "Write back with all the news", result = { setFlags = { "q_chalk_done" }, sanity = 3, log = "You wrote back that the stable boy missed being bitten, though he'd never admit it, and that you'd sing to Chalk yourself next time you came." } },
			{ label = "Pin the drawing over your bed", result = { setFlags = { "q_chalk_done" }, sanity = 2, prudence = 1, log = "You pinned the pony in the straw hat over your bed, where it stayed for years." } },
		},
	},

	-- ── The Hundredth Step (Bellhollow, teens) ──
	{
		id = "quest_step_offer",
		title = "The Hundredth Step",
		text = "Every kid in Bellhollow knows the Counting Stair has ninety-nine steps, because every kid in Bellhollow has counted them. Tonight, coming home after the hundred bells rang midnight, you counted a hundred. The extra one was near the bottom, a little wetter than the rest, and it went down further than a step should.",
		once = true,
		weight = 26,
		tags = { "quest", "youth", "bellhollow", "strange" },
		when = { district = "bellhollow", minAge = 13, maxAge = 18 },
		choices = {
			{ label = "Count them again tomorrow night", result = { quest = "hundredth_step", log = "You went home the long way and lay awake counting to a hundred." } },
			{ label = "Never take that stair again", result = { prudence = 1, log = "You took the long way home every night after that, and never once counted." } },
		},
	},
	{
		id = "quest_step_midsummer",
		title = "A Hundred and One",
		text = "On Midsummer night you carry the new clapper down the hundredth step and hang it in the apprentice's silent bell. Back on the Counting Stair, the hundred bells of Bellhollow ring midnight, and then a hundred and first rings with them, small and clear, from somewhere under your feet. All along the stair, windows open and people lean out to listen.",
		weight = 0,
		tags = { "quest", "bellhollow", "strange" },
		when = { flags = { "q_step_wait" }, notFlags = { "q_step_done" } },
		choices = {
			{ label = "Count the stair one last time", result = { setFlags = { "q_step_done" }, sanity = 3, log = "You counted the stair one last time. Ninety-nine steps. On the eighty-first, someone had carved a tiny bell." } },
			{ label = "Ring along on the railing", result = { setFlags = { "q_step_done" }, justice = 1, sanity = 3, log = "You rang the iron railing with your knuckles in time with the hundred and first bell, and half the stair joined in with pot lids." } },
		},
	},

	-- ── The Old Sister (Lantern Guild, needs a crew) ──
	{
		id = "quest_sister_offer",
		title = "The Old Sister",
		text = "The Old Sister was the Lantern Guild's first diving bell, a brass bell as tall as a house, lowered on chains so divers could breathe at the bottom. Fifty years ago her chain parted in a storm, and she has sat on the floor of the Mere ever since. For the Guild's hundredth Lantern Night, the Captains want her raised, and they are choosing a crew.",
		once = true,
		weight = 16,
		tags = { "quest", "career", "diver" },
		when = { career = "diver", minAge = 17 },
		choices = {
			{ label = "Put your name forward", result = { quest = "old_sister", log = "You chalked your name on the Captains' board under OLD SISTER. Three other names were already there." } },
			{ label = "Leave it to the Deep Divers", result = { log = "You left the Old Sister to the Deep Divers. The board filled up without you." } },
		},
	},
	{
		id = "quest_sister_raising",
		title = "The Old Sister Comes Up",
		text = "On the Guild's hundredth Lantern Night the lift barges take the strain, the chains sing, and the Old Sister comes up out of the Mere streaming weed, enormous and green and gleaming in a thousand lanterns. Three old women stand at the front of the pier. The Lantern-Captain hands you the striker and nods at the bell.",
		weight = 0,
		tags = { "quest", "diver" },
		when = { flags = { "q_sister_wait" }, notFlags = { "q_sister_done" } },
		choices = {
			{ label = "Ring her once for the last crew", result = { setFlags = { "q_sister_done" }, sanity = 4, log = "You rang the Old Sister once. The whole Mere seemed to hear it, and every lantern on the water bobbed." } },
			{ label = "Hand the striker to the families", result = { setFlags = { "q_sister_done" }, justice = 2, sanity = 3, log = "You handed the striker to the three old women. They rang her together, and the whole pier went quiet." } },
		},
	},

	-- ── The Torn Page (Brine Kin mystery, two endings) ──
	{
		id = "quest_page_offer",
		title = "The Torn Page",
		text = "The great ledger of the Brine Kin lies open on its stand in the old counting-house, and a page has been cut out with a very sharp knife. It was the page for the Brackwater Steps: forty families, and every debt they owe the Kin. The Elder Kin looks at each cousin in turn, and then at you. 'Find my page,' she says, 'and the hand that cut it.'",
		once = true,
		weight = 16,
		tags = { "quest", "career", "brine" },
		when = { career = "brine", minAge = 15 },
		choices = {
			{ label = "Swear on the ledger", result = { quest = "torn_page", log = "You laid your hand flat on the great ledger and swore to find the page." } },
			{ label = "Say you can't read", result = { log = "You told the Elder you couldn't read. She didn't believe you, but she let it go, and she remembered." } },
		},
	},
	{
		id = "quest_page_answer",
		title = "The Elder's Answer",
		text = "The Elder Kin calls you to the counting-house at the turn of the year, with every cousin standing round the great ledger. The page is inside your shirt, and Mab Brackwater's name is in your mouth. 'Well, cousin?' says the Elder. 'My page, and whose hand?'",
		weight = 0,
		tags = { "quest", "brine" },
		when = { flags = { "q_page_decide" }, notFlags = { "q_page_done" } },
		choices = {
			{
				label = "Give her the page and Mab's name",
				result = {
					setFlags = { "q_page_returned", "q_page_done" },
					promote = true,
					sanity = -3,
					schedule = { event = "quest_page_favor", inYears = 2 },
					log = "You laid the page on the ledger and said Mab's name. The Elder sewed the page back in with her own needle, and by morning Mab Brackwater's boat was gone from the Steps.",
				},
			},
			{
				label = "Burn the page in the lamp",
				hint = "The Kin will remember.",
				result = {
					setFlags = { "q_page_burned", "q_page_done" },
					justice = 4,
					sanity = 3,
					condition = "marked",
					schedule = { event = "quest_page_steps", inYears = 2 },
					log = "You held the page to the counting-house lamp and let it burn. The Elder watched the ash fall for a long time. 'A lost page is a lost page,' she said at last. The cousins will not forget it.",
				},
			},
		},
	},
	{
		id = "quest_page_favor",
		title = "A Page of Your Own",
		text = "The Elder Kin sends for you and opens the great ledger to a fresh page with your name across the top. Beneath it, in her own hand, is a single line: OWED, ONE FAVOR, BY THE KIN. The Brackwater Steps page has been sewn back in so neatly you can hardly see the seam.",
		weight = 0,
		tags = { "quest", "brine" },
		when = { flags = { "q_page_returned" } },
		result = { wage = { 40, 80 }, prudence = 2, log = "The Kin paid you a favor's worth in scrip and a nod from every cousin on the docks. You thought about Mab's empty mooring more often than you expected to." },
	},
	{
		id = "quest_page_steps",
		title = "The Steps Remember",
		text = "The High Water came, the spill gate opened, and the Brackwater Steps went under to the second landing. But forty families owed the Kin nothing, so they had something left to rebuild with. When the water went down, someone painted a small lantern on your door, and nobody will say who.",
		weight = 0,
		tags = { "quest", "brine" },
		when = { flags = { "q_page_burned" } },
		result = { sanity = 5, addRelation = { kind = "friend", name = "Mab Brackwater", bond = 70, age = { 66, 76 } }, log = "Mab Brackwater came up your stairs with a pot of kelp tea and stayed all afternoon. Everyone on the Brackwater Steps knows your name now." },
	},

	-- ── The Dead Commissioner's Seal (Sluice Authority) ──
	{
		id = "quest_seal_offer",
		title = "A Standing Order",
		text = "A flood order crosses your desk for the next High Water: open the spill gate, put Anchor Court in the Silt under four feet of water, and keep the Terrace markets dry. It carries the seal of Commissioner Emrys Gale, who died thirty years ago. 'It's a standing order,' says the senior clerk, without looking at it. 'It stands.'",
		once = true,
		weight = 16,
		tags = { "quest", "career", "sluice" },
		when = { career = "sluice", minAge = 19 },
		choices = {
			{ label = "Pull the file on Anchor Court", result = { quest = "dead_seal", log = "You slid the order into your coat instead of the out-tray, and went down to the archive." } },
			{ label = "Stamp it and send it on", result = { sanity = -2, log = "You stamped it and sent it on. You didn't sleep well that week, or the week after." } },
		},
	},
	{
		id = "quest_seal_order_day",
		title = "Order Day",
		text = "The autumn storms push the Mere up the Terraces, and the order day comes round: the day the spill gate has opened on Anchor Court for thirty years. You stand at your office window while the whole Sluice house pretends not to watch you. The gate stays shut, and down in the Silt, Anchor Court's lamps stay lit.",
		weight = 0,
		tags = { "quest", "sluice" },
		when = { flags = { "q_seal_wait" }, notFlags = { "q_seal_done" } },
		choices = {
			{ label = "Go down to Anchor Court", result = { setFlags = { "q_seal_done" }, sanity = 4, log = "You walked down to Anchor Court in the rain. Every door was open and every lamp was lit, and nobody there knew who you were, which was exactly right." } },
			{ label = "Look into the other standing orders", result = { setFlags = { "q_seal_done" }, justice = 2, prudence = 1, log = "You started a memorandum on every other standing order under the gate and sent the first page up seven floors. Some memoranda come back down. You'd see." } },
		},
	},

	-- ── The Bell Garden (the Choir, elders) ──
	{
		id = "quest_bells_offer",
		title = "Ringing Under the Water",
		text = "On still nights you've begun to hear bells ringing under the water off the ferry steps, very softly, like hand bells wrapped in a blanket. The young Choristers hear nothing at all. The Still Voice takes your hands and says it's the Bellwrights' drowned bell garden, silent for sixty years. 'It's ringing for you,' she says. 'Go and listen.'",
		once = true,
		weight = 16,
		tags = { "quest", "career", "choir", "faith" },
		when = { career = "choir", minAge = 55 },
		choices = {
			{ label = "Go down to the water and listen", result = { quest = "bell_garden", log = "You told the Still Voice you'd go and listen. She looked very glad, and a little sad." } },
			{ label = "Ask her to sit with you instead", result = { sanity = 2, log = "You asked the Still Voice to sit with you instead. The bells didn't ring again, and you were half sorry." } },
		},
	},
	{
		id = "quest_bells_silence",
		title = "The End of a Silence",
		text = "A year to the night after the bells first rang for you, the whole Choir comes down to the ferry steps and sits behind you in the dark. The lost hand bell is cold in your lap, and the youngest Listener is holding your sleeve. Sixty years ago someone began a silence here and never finished it, and the Mere has been waiting, the way an audience waits.",
		weight = 0,
		tags = { "quest", "choir", "strange" },
		when = { flags = { "q_bells_wait" }, notFlags = { "q_bells_done" } },
		choices = {
			{ label = "Ring the seven strokes", result = { setFlags = { "q_bells_done" }, sanity = 5, log = "You rang the seven strokes across the water. When the last one faded, the whole Choir let out its breath at once, and somewhere under the Mere a long silence ended." } },
			{ label = "Give the bell to the youngest Listener", result = { setFlags = { "q_bells_done" }, prudence = 3, sanity = 4, log = "You put the bell in the youngest Listener's hands. She rang the seven strokes perfectly, and then an eighth, which nobody had taught her." } },
		},
	},

	-- ── Wick (family: your child and a baby lamp-eater) ──
	{
		id = "quest_wick_offer",
		title = "Something That Eats Light",
		text = "{child} comes home from the mudflats with their coat buttoned up wrong and something warm moving inside it: a baby lamp-eater no bigger than a mitten, soft and grey and blind, its feathery feelers turning toward the stove. {child} has already named it Wick. Lamp-eaters snuff every lantern they find. This one is purring.",
		once = true,
		weight = 14,
		tags = { "quest", "family", "child", "strange" },
		when = { hasRelation = "child", minAge = 24, maxAge = 50 },
		choices = {
			{ label = "Let {child} keep Wick, for now", result = { quest = "little_wick", log = "You found Wick an old teapot to sleep in, and {child} hugged you so hard you dropped the lid." } },
			{ label = "Take it back to the mudflats", result = { relationBond = { kind = "child", amount = -4 }, log = "You walked {child} back down to the mudflats and let the little grey thing go. {child} didn't speak to you for a week." } },
		},
	},
	{
		id = "quest_wick_visit",
		title = "A Visitor on Lantern Night",
		text = "On Lantern Night, as the paper lanterns drift out across the Mere, something as big as a dog climbs out of the water onto your stairs, grey and soft and blind. It walks straight to your lantern and snuffs it, very gently, the way you'd blow out a child's candle. Then it touches {child}'s hand with its feelers and goes back into the dark.",
		weight = 0,
		tags = { "quest", "family", "child", "strange" },
		when = { flags = { "q_wick_wait" }, notFlags = { "q_wick_done" }, hasRelation = "child" },
		choices = {
			{ label = "Light the lantern again for Wick", result = { setFlags = { "q_wick_done" }, sanity = 4, log = "You lit the lantern again and set it on the water for Wick. It drifted out into the dark and stayed lit for a very long time." } },
			{ label = "Leave it dark", result = { setFlags = { "q_wick_done" }, prudence = 2, sanity = 3, log = "You left the lantern dark. {child} said Wick would have wanted it that way, and was probably right." } },
		},
	},

	-- ── The Stolen Minutes (the Charter, two endings) ──
	{
		id = "quest_minutes_offer",
		title = "Four Minutes Fast",
		text = "The great clock over the Charter gate runs four minutes fast. You only noticed because the Bellhollow bells carry on the wind on still mornings, and the company clock always beats them. Every shift in the Gutters starts and ends by that clock, and four minutes a day, every day, for every worker in {district}, adds up to a great deal of somebody's life.",
		once = true,
		weight = 16,
		tags = { "quest", "charter" },
		when = { side = "charter", minAge = 18, maxAge = 65 },
		choices = {
			{ label = "Find out why", result = { quest = "stolen_minutes", log = "You set your pocket watch by the Bellhollow bells and started keeping notes." } },
			{ label = "Set your watch by the company", result = { sanity = -1, log = "You set your watch by the company clock like everybody else. It was easier, and that was the point." } },
		},
	},
	{
		id = "quest_minutes_visitor",
		title = "A Visitor from the Company",
		text = "A company secretary in a coat that has never been rained on calls at your door with an envelope. The Director knows what you took from the clock, she says pleasantly, would like it back, and is prepared to be generous. In the street below, the Gutters night shift is walking home by the company clock, four minutes late.",
		weight = 0,
		tags = { "quest", "charter" },
		when = { flags = { "q_minutes_decide" }, notFlags = { "q_minutes_done" } },
		choices = {
			{
				label = "Nail the ledger to the Charter gate",
				result = {
					setFlags = { "q_minutes_posted", "q_minutes_done" },
					justice = 5,
					sanity = 4,
					addRelation = { kind = "friend", name = "Corra Haskett", bond = 65 },
					log = "You nailed the ledger to the Charter gate under the clock, open at the last page. By noon the whole Gutters had read it, by the end of the week the clock kept perfect time, and a shift foreman named Corra Haskett came up to the gate to shake your hand in front of the guards.",
				},
			},
			{
				label = "Take the Director's envelope",
				result = {
					setFlags = { "q_minutes_sold", "q_minutes_done" },
					wage = { 200, 350 },
					gear = "company_greatcoat",
					sanity = -4,
					log = "You handed back the ledger and took the envelope, with a tailor's card for a company greatcoat tucked inside. By the end of the week the clock was running four minutes fast again, and now you know exactly whose minutes they are.",
				},
			},
		},
	},

	-- ── The Carousel Pact (Kelpmarket, elders) ──
	{
		id = "quest_pact_offer",
		title = "The Carousel Pact",
		text = "When you were eleven, five of you swore on the brass horses of the Kelpmarket carousel to meet there again when you were old. The next spring, the High Water took the fairground, carousel and all. Yesterday, at the bottom of the low tide, the carousel's striped roof came up out of the Silt. You are old now, and you count on your fingers who's left.",
		once = true,
		weight = 16,
		tags = { "quest", "elder", "kelpmarket" },
		when = { district = "kelpmarket", minAge = 58 },
		choices = {
			{ label = "Round up whoever's left", result = { quest = "old_pact", log = "You dug the old tin badge out of the drawer where it had waited fifty years, and went looking for the others." } },
			{ label = "Let the carousel be", result = { sanity = -1, log = "You let the carousel be, and watched its roof from the stairs until the tide came back and covered it." } },
		},
	},
	{
		id = "quest_pact_kept",
		title = "The Pact Kept",
		text = "A year after you found the tin, the three of you have kept the pact at every low tide: Pell with a bag of buns, Una in her good Charter coat, you with the whistle. Today a gang of Kelpmarket children has followed you down to the flats, five of them, hanging back and pretending not to listen.",
		weight = 0,
		tags = { "quest", "elder", "kelpmarket" },
		when = { flags = { "q_pact_wait" }, notFlags = { "q_pact_done" } },
		choices = {
			{ label = "Teach them the oath", result = { setFlags = { "q_pact_done" }, sanity = 4, addRelation = { kind = "friend", name = "Una Fairweather", bond = 70 }, log = "You taught them the oath word for word, and they swore it on your old horse with the chipped ear. Una cried, and said it was the wind." } },
			{ label = "Give them the whistle", result = { setFlags = { "q_pact_done" }, justice = 1, sanity = 3, addRelation = { kind = "friend", name = "Una Fairweather", bond = 70 }, log = "You gave the gang your whistle. They ran off across the flats blowing it, and Una said it was the most sensible thing you'd done in fifty years." } },
		},
	},

	-- ── Two Forges (Foundry Row Gutters) ──
	{
		id = "quest_forge_offer",
		title = "Two Forges",
		text = "The Drabb and Harrow forges on Anvil Lane have hated each other for three generations, over a debt nobody alive remembers. Last night a child from each forge went missing, Dov Drabb and Jessamy Harrow, both eleven, and each family says the other took theirs. By noon, men on both sides of the lane are holding hammers that aren't for iron.",
		once = true,
		weight = 16,
		tags = { "quest", "ward", "foundry" },
		when = { district = "foundry", side = "gutters", minAge = 18, maxAge = 65 },
		choices = {
			{ label = "Walk into the middle of the lane", result = { quest = "two_forges", log = "You walked into the middle of Anvil Lane and said you'd find both children. Both sides told you to hurry." } },
			{ label = "Keep your door shut", result = { sanity = -1, log = "You kept your door shut and your head down, and heard the shouting through the wall all night." } },
		},
	},
	{
		id = "quest_forge_table",
		title = "One Table",
		text = "A year after the children came down the crane, the Drabb and Harrow forges carry their tables out into Anvil Lane, set them end to end, and sit at them together, which nobody alive has ever seen. Dov and Jessamy sit at the join in the middle. When the plates are cleared, the two oldest smiths stand up at once, glare at each other, and sit back down.",
		weight = 0,
		tags = { "quest", "ward", "foundry" },
		when = { flags = { "q_forge_wait" }, notFlags = { "q_forge_done" } },
		choices = {
			{ label = "Raise a cup of kelp tea to Anvil Lane", result = { setFlags = { "q_forge_done" }, sanity = 4, log = "You raised a cup of kelp tea to Anvil Lane. Both forges raised theirs. Nobody mentioned the old debt, and nobody has since." } },
			{ label = "Ask what the old debt was", result = { setFlags = { "q_forge_done" }, prudence = 2, sanity = 3, log = "You asked what the old debt was. The two oldest smiths looked at each other for a long time, and neither of them could remember." } },
		},
	},
}
