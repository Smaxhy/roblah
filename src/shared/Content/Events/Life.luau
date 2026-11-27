--[[
	Adult life events: ages 18+, general and side-specific (Charter / Gutters).
	Threads:
		owes_brine_kin   life_brine_loan -> life_brine_due (4 yrs) -> brine_grudge -> life_brine_grudge
		paid_inspector   life_flood_list -> life_inspector_audit (3 yrs); sluice_marked -> world_silt_flood
		took_in_foundling life_foundling_follows (adds a child) -> fam_child_* events
]]

return {
	{
		id = "life_brine_loan",
		title = "A Loan from the Kin",
		text = "The rent is due, the stove is cold, and your boots let in the Mere. A Brine Kin ledger-hand named Dov Marrow sits down beside you at the noodle barge. \"Cousins help cousins,\" he says, laying out crisp notes. \"A hundred now. The ledger remembers the rest.\"",
		once = true,
		tags = { "life", "brine", "thread_brine_debt" },
		when = { minAge = 18, side = "gutters", max = { money = 60 }, notFlags = { "owes_brine_kin" } },
		choices = {
			{
				label = "Take the hundred",
				result = {
					money = 100,
					sanity = 2,
					setFlags = { "owes_brine_kin" },
					schedule = { event = "life_brine_due", inYears = 4 },
					log = "You took Dov Marrow's hundred {currency}. He wrote your name in the ledger in very neat letters.",
				},
			},
			{
				label = "Turn him down",
				result = { prudence = 2, sanity = -1, log = "You thanked Dov and went home cold, but your name stayed out of his book." },
			},
		},
	},
	{
		id = "life_brine_due",
		title = "The Ledger Remembers",
		text = "Four years on, Dov Marrow finds you on the tram platform as if he had only stepped away for a moment. He opens the ledger to your name. The hundred has grown teeth: two hundred and twenty {currency}. \"Cousins pay cousins,\" he says mildly.",
		weight = 0,
		once = true,
		tags = { "life", "brine", "thread_brine_debt" },
		choices = {
			{
				label = "Pay the ledger in full",
				hint = "220 scrip.",
				requires = { min = { money = 220 } },
				result = { money = -220, prudence = 2, clearFlags = { "owes_brine_kin" }, log = "You paid Dov to the last note and watched him draw a neat line through your name." },
			},
			{
				label = "Work it off on the night boats",
				result = {
					fortitude = { -10, -5 },
					sanity = -4,
					clearFlags = { "owes_brine_kin" },
					setFlags = { "worked_for_brine" },
					log = "You rowed Kin cargo through the drowned streets for a year until Dov closed your page.",
					cause = "Worked to the bone on the Brine boats",
				},
			},
			{
				label = "Refuse to pay",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Dov Marrow", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, clearFlags = { "owes_brine_kin" }, setFlags = { "brine_grudge" }, log = "You stared Dov down until he shut the ledger. The Kin never forget a refusal." },
				lose = {
					money = { -60, -30 },
					fortitude = { -6, -3 },
					clearFlags = { "owes_brine_kin" },
					setFlags = { "brine_grudge" },
					log = "Two cousins took your boots, your coat and every note in the house. Dov called it even.",
				},
			},
		},
	},
	{
		id = "life_brine_grudge",
		title = "Chalk on the Door",
		text = "Your door has a fresh chalk mark on it, the curled hook the Brine Kin leave for people who crossed them. Overnight someone has loosened two of the ropes holding up your walkway. The fog is full of oars that stop rowing whenever you look.",
		weight = 8,
		cooldown = 6,
		tags = { "life", "brine", "silt", "danger" },
		when = { minAge = 18, side = "gutters", flags = { "brine_grudge" } },
		choices = {
			{
				label = "Leave a peace offering",
				hint = "80 scrip.",
				requires = { min = { money = 80 } },
				result = { money = -80, sanity = 3, clearFlags = { "brine_grudge" }, log = "You left eighty {currency} in an oyster tin on the Kin dock. The chalk was gone by morning." },
			},
			{
				label = "Keep watch with a lamp",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Brine Kin cousins", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 3, sanity = 1, log = "You sat up three nights with a lamp, and the oars in the fog went elsewhere." },
				lose = {
					fortitude = { -8, -4 },
					sanity = -4,
					log = "The walkway gave way under you in the dark, and you spent a cold hour in the Mere.",
					cause = "Fell from a loosened walkway",
				},
			},
			{
				label = "Move up to the Terraces",
				hint = "120 scrip.",
				requires = { min = { money = 120 } },
				result = { money = -120, sanity = -1, clearFlags = { "brine_grudge" }, log = "You moved up to a Terraces room, where the Kin's chalk marks never seemed to reach." },
			},
		},
	},
	{
		id = "life_flood_list",
		title = "The Flood List",
		text = "A Sluice inspector in a wax coat is pacing your walkway with a measuring rod. Hollis Greaves, his badge says. \"High Water comes round sooner or later,\" he says. \"Some blocks get the gates and some get the flood. For sixty {currency}, I can misplace your address.\"",
		once = true,
		tags = { "life", "silt", "sluice", "thread_inspector" },
		when = { minAge = 18, side = "gutters" },
		choices = {
			{
				label = "Pay him the sixty",
				hint = "60 scrip.",
				requires = { min = { money = 60 } },
				result = {
					money = -60,
					justice = -2,
					setFlags = { "paid_inspector" },
					schedule = { event = "life_inspector_audit", inYears = 3 },
					log = "You paid Inspector Greaves, and he drew a little star beside your address.",
				},
			},
			{
				label = "Report him to the Authority",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The Sluice front desk", coins = 2, base = 4, coinPower = 3 },
				win = { justice = { 3, 5 }, log = "Your complaint climbed seven floors, and Greaves was sent to count buckets in the archive." },
				lose = { sanity = -3, setFlags = { "sluice_marked" }, log = "Your complaint vanished, and a week later your address was circled in red ink." },
			},
			{
				label = "Shut the door on him",
				result = { prudence = 1, log = "You shut the door on Inspector Greaves. He wrote something down and walked off whistling." },
			},
		},
	},
	{
		id = "life_inspector_audit",
		title = "The Inspector's Notebook",
		text = "Inspector Greaves has been arrested for selling dry addresses, and the Authority has his notebook. Your name is in it, with a little star. Two auditors in identical grey coats are waiting on your walkway, very politely, under matching umbrellas.",
		weight = 0,
		once = true,
		tags = { "life", "sluice", "thread_inspector" },
		choices = {
			{
				label = "Tell them the truth",
				result = { justice = { 2, 4 }, money = { -40, -20 }, clearFlags = { "paid_inspector" }, log = "You told the auditors everything. They fined you and thanked you for your honesty." },
			},
			{
				label = "Talk your way clear",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "Sluice auditors", coins = 2, base = 5, coinPower = 3 },
				win = { prudence = 3, clearFlags = { "paid_inspector" }, log = "You explained at length that the star meant nothing. They left more confused than they came." },
				lose = {
					money = { -90, -50 },
					sanity = -4,
					clearFlags = { "paid_inspector" },
					setFlags = { "sluice_marked" },
					log = "The auditors fined you double and circled your address in red for the next flood.",
				},
			},
			{
				label = "Give them your neighbors' names",
				result = { justice = -4, sanity = -3, clearFlags = { "paid_inspector" }, log = "You gave them three neighbors' names, and they let you go. The walkway went quiet after that." },
			},
		},
	},
	{
		id = "life_foundling_follows",
		title = "A Small Shadow",
		text = "All the way up from the docks, a child has been following you through the fog, keeping exactly ten steps back. They carry a lantern stub with no candle in it. When you stop at your door, they stop too, and sit down on the wet stone to wait.",
		once = true,
		weight = 8,
		tags = { "life", "child", "thread_foundling" },
		when = { minAge = 24, maxAge = 55, chance = 0.6 },
		choices = {
			{
				label = "Bring them inside",
				result = {
					addRelation = { kind = "child", age = { 4, 8 }, bond = 50 },
					sanity = 4,
					setFlags = { "parent", "took_in_foundling" },
					schedule = { event = "fam_child_trade", inYears = 9 },
					log = "You brought {newRelation} inside, and they slept curled around the empty lantern.",
				},
			},
			{
				label = "Walk them to the Foundling Steps",
				hint = "10 scrip.",
				requires = { min = { money = 10 } },
				result = { money = -10, justice = 2, sanity = 1, log = "You walked the child to the Foundling Steps and paid the matron to find them a warm cot." },
			},
			{
				label = "Shut the door",
				result = { sanity = -4, log = "You shut the door. In the morning the child and the lantern stub were gone." },
			},
		},
	},
	{
		id = "life_rival_again",
		title = "An Old Rival",
		text = "{rival} has done well for themselves and wants you to know it. They turn up at the noodle barge in a good coat, buy a bowl of broth for everyone except you, and ask loudly how your little life is going.",
		cooldown = 8,
		tags = { "life", "rival" },
		when = { minAge = 22, hasRelation = "rival" },
		choices = {
			{
				label = "Laugh it off",
				result = { prudence = 2, sanity = 1, relationBond = { kind = "rival", amount = 5 }, log = "You laughed along until {rival} ran out of things to say and sat down beside you." },
			},
			{
				label = "Challenge them to the stairs",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "Your rival", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 3, relationBond = { kind = "rival", amount = -5 }, log = "You raced {rival} up the switchbacks for old times' sake and won by a landing." },
				lose = { fortitude = -2, sanity = -3, log = "{rival} beat you up the switchbacks, then bought you a bowl of broth out of pity." },
			},
			{
				label = "Leave without eating",
				result = { sanity = -2, log = "You left your broth on the counter and walked home hungry and furious." },
			},
		},
	},
	{
		id = "life_rim_gala",
		title = "The Garden Gala",
		text = "The Penhallow garden gala glitters under a hundred glass lamps. Over iced lemon water, a Commissioner's nephew is telling a joke about the Silt, and everyone around him laughs on cue. Behind him, a Silt waiter with a tray of glasses has gone very still.",
		cooldown = 6,
		tags = { "life", "rim" },
		when = { minAge = 18, side = "charter" },
		choices = {
			{
				label = "Laugh along",
				result = { prudence = 1, justice = -2, sanity = -2, log = "You laughed on cue with everyone else, and the waiter's face stayed with you for days." },
			},
			{
				label = "Tell them what the Silt is like",
				requires = { flags = { "saw_the_silt" } },
				result = { justice = { 3, 4 }, sanity = 2, log = "You told the whole garden about fog, stilts and kelp broth until the joke died." },
			},
			{
				label = "Spill your glass on his shoes",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The Commissioner's nephew", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 2, sanity = 3, log = "You tipped your glass over his shoes so gracefully that everyone apologized to you." },
				lose = { money = { -40, -20 }, sanity = -2, log = "Your accident looked exactly like what it was, and you paid for his shoes." },
			},
		},
	},
	{
		id = "life_hail_on_glass",
		title = "Hail on the Glass",
		text = "A hailstorm rolls over the crater's lip and hammers the greenhouses like thrown gravel. Panes are cracking up and down the row. The old gardener, Piet Ambry, is out in it alone with a tarp, trying to save forty years of orange trees.",
		once = true,
		tags = { "life", "rim" },
		when = { minAge = 18, side = "charter" },
		choices = {
			{
				label = "Run out and help him",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The hailstorm", coins = 2, base = 4, coinPower = 3 },
				win = {
					fortitude = 2,
					sanity = 4,
					addRelation = { kind = "friend", name = "Piet Ambry", bond = 50, age = { 55, 70 } },
					log = "You held the tarp with {newRelation} until the hail passed. He saved you an orange every week.",
				},
				lose = { fortitude = { -7, -3 }, sanity = -1, log = "A falling pane sent you to a stitcher for the night, but most of the trees lived." },
			},
			{
				label = "Pay for new glass",
				hint = "100 scrip.",
				requires = { min = { money = 100 } },
				result = { money = -100, justice = 2, sanity = 2, log = "You paid for new panes up and down the row and told nobody it was you." },
			},
			{
				label = "Watch from the window",
				result = { sanity = -2, log = "You watched from the window as the orange trees went down one by one." },
			},
		},
	},
	{
		id = "life_rim_gate_papers",
		title = "Papers at the Gate",
		text = "At the Charter gate, the guards have stopped a Tidetouched delivery girl carrying your neighbor's laundry. Her skin is cool and faintly blue at the throat. Her papers are in order, and the guards are taking a very long time to notice that her papers are in order.",
		cooldown = 5,
		tags = { "life", "rim", "tidetouched" },
		when = { minAge = 18, side = "charter" },
		choices = {
			{
				label = "Vouch for her",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Charter gate guards", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 2, log = "You vouched for her so loudly and so long that the guards let her through to be rid of you." },
				lose = { money = { -20, -10 }, justice = 1, sanity = -3, log = "The guards fined you for obstruction and sent her back down the stairs anyway." },
			},
			{
				label = "Carry the basket in yourself",
				result = { justice = 2, sanity = 1, log = "You carried the basket through the gate yourself and brought her pay back out to her." },
			},
			{
				label = "Walk on by",
				result = { prudence = 1, sanity = -2, log = "You walked on through the gate and did not look back at the stairs." },
			},
		},
	},
	{
		id = "life_runaway_tram",
		title = "Runaway Tram",
		text = "A tram comes down the switchback with its brake shoes screaming and sparks spraying off the rail. The driver is hauling on a lever that does nothing at all. Below the next hairpin, the tarp market is packed shoulder to shoulder.",
		weight = 8,
		cooldown = 10,
		tags = { "life", "terraces", "danger" },
		when = { minAge = 18, side = "gutters" },
		choices = {
			{
				label = "Throw the siding switch",
				hint = "Justice clash, medium-hard.",
				clash = { stat = "justice", foe = "The runaway tram", coins = 2, base = 5, coinPower = 3 },
				win = { justice = { 4, 6 }, sanity = 4, money = { 20, 50 }, log = "You threw the switch and the tram ground to a stop in the sidings. The Tram Company paid a reward." },
				lose = {
					fortitude = { -12, -6 },
					sanity = -4,
					log = "The switch moved too late, and the tram clipped you on its way into the sidings.",
					cause = "Struck by a runaway tram",
				},
			},
			{
				label = "Shout the market clear",
				result = { prudence = { 2, 3 }, sanity = 1, log = "You shouted until the market scattered, and the tram jumped the rail into empty stalls." },
			},
			{
				label = "Get out of the way",
				result = { sanity = -3, log = "You flattened yourself against the wall and watched it scream past." },
			},
		},
	},
	{
		id = "life_market_hands",
		title = "Quick Hands",
		text = "Under the tarps of the Terraces market, a boy no older than ten slips his hand into a fishmonger's apron and comes out with a fold of {currency}. The fishmonger hasn't noticed. The boy has seen you see him, and he freezes.",
		cooldown = 6,
		tags = { "life", "terraces" },
		when = { minAge = 18, side = "gutters" },
		choices = {
			{
				label = "Catch his wrist",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The market pickpocket", coins = 1, base = 3, coinPower = 2 },
				win = { justice = 2, money = { 3, 8 }, log = "You caught the boy and returned the notes, and the fishmonger tipped you for your trouble." },
				lose = { sanity = -1, log = "The boy ducked under a tarp and was gone before you finished reaching." },
			},
			{
				label = "Wink and look away",
				result = { justice = -1, sanity = 1, log = "You looked away. The boy grinned at you and vanished into the crowd." },
			},
			{
				label = "Buy him a bowl of broth",
				hint = "5 scrip.",
				requires = { min = { money = 5 } },
				result = { money = -5, justice = 2, sanity = 3, log = "You bought the boy a bowl of broth, and he gave the notes back without being asked." },
			},
		},
	},
	{
		id = "life_leaning_house",
		title = "The Leaning House",
		text = "Your stilt-house has started leaning toward the water, a little more every week. The kettle slides off the stove on its own. A crack runs up the back wall, and at night the old pilings groan like ships in a sailor's story.",
		cooldown = 6,
		tags = { "life", "silt" },
		when = { minAge = 18, side = "gutters" },
		choices = {
			{
				label = "Brace the pilings yourself",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The rotten pilings", coins = 2, base = 4, coinPower = 3 },
				win = { temperance = { 3, 4 }, sanity = 2, log = "You braced the pilings with salvage timber, and the house stood up straight again." },
				lose = { fortitude = { -6, -3 }, money = { -20, -10 }, log = "Your brace slipped, the kettle went into the Mere, and you went in after it." },
			},
			{
				label = "Hire a piling crew",
				hint = "60 scrip.",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 2, log = "A piling crew drove two new posts in a single day and took sixty {currency} for it." },
			},
			{
				label = "Learn to live at an angle",
				result = { prudence = 1, sanity = -3, log = "You nailed the kettle to the stove and learned to live at an angle." },
			},
		},
	},
	{
		id = "life_boat_in_fog",
		title = "A Boat in the Fog",
		text = "Someone is calling out in the fog beyond the docks, an oar knocking against wood. A rowboat has lost the lamp line and is drifting toward the open Mere, where the deep water starts. Yours is the only lantern lit on this end of the pier.",
		cooldown = 5,
		tags = { "life", "silt", "rescue" },
		when = { minAge = 18, side = "gutters" },
		choices = {
			{
				label = "Swing your lantern and shout",
				result = { prudence = 2, justice = 1, sanity = 2, log = "You swung your lantern for an hour until the rowboat found its way to the pier." },
			},
			{
				label = "Row out after them",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The fog bank", coins = 2, base = 4, coinPower = 3 },
				win = {
					fortitude = 2,
					justice = 3,
					sanity = 4,
					addRelation = { kind = "friend", bond = 50, age = { 20, 40 } },
					log = "You rowed out and towed {newRelation} home, still clutching their one good oar.",
				},
				lose = {
					fortitude = { -8, -4 },
					sanity = -3,
					log = "You lost the pier, then the boat, then your bearings. Dawn found you on a mudbank.",
					cause = "Lost in the fog bank",
				},
			},
			{
				label = "Go back to bed",
				result = { sanity = -3, log = "You went back to bed, and the calling stopped some time before dawn." },
			},
		},
	},
	{
		id = "life_fever_season",
		title = "Fever Season",
		text = "Fever season climbs the stairs with the fog, the way it does every few years. Half the tenement is coughing. You wake with a hot forehead and aching joints, and the day's work is waiting for you whether you can stand or not.",
		cooldown = 8,
		tags = { "life", "sickness" },
		when = { minAge = 18 },
		choices = {
			{
				label = "Rest and lose the pay",
				result = { money = { -25, -10 }, fortitude = { -2, 0 }, sanity = 1, log = "You slept through the worst of it under three blankets and lost a fortnight's pay." },
			},
			{
				label = "Work through it",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "Fog fever", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = { -1, 0 }, prudence = 2, log = "You worked through the fever and came out the other side oddly proud of it." },
				lose = {
					fortitude = { -12, -6 },
					sanity = -3,
					log = "You collapsed on the stairs halfway through the day and woke up at a stitcher's.",
					cause = "Fog fever",
				},
			},
			{
				label = "See a stitcher",
				hint = "30 scrip.",
				requires = { min = { money = 30 } },
				result = { money = -30, fortitude = { 2, 4 }, log = "A stitcher gave you bitter tea and a hard look, and the fever broke in two days." },
			},
		},
	},
	{
		id = "life_good_year",
		title = "A Good Year",
		text = "Nothing goes wrong this year. The rent is paid on time. The pumps thump. The broth is hot. Someone on the tram laughs at something you say, and you laugh too. You keep waiting for the water to rise, and it never does.",
		weight = 6,
		cooldown = 6,
		tags = { "life", "calm" },
		when = { minAge = 18 },
		result = { sanity = { 3, 6 }, log = "You had a good, ordinary year, and you noticed it while it was happening." },
	},
}
