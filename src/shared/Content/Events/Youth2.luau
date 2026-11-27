--[[
	Youth events, second set: ages 13-17.
	Follow-ups to threads from Childhood2 (weight = 0, they only arrive by schedule):
		kid2_odile_song    -> teen2_odile_again    (adds friend Odile Vell)
		kid2_greer_jump    -> teen2_greer_rematch  (adds Greer Ingram as rival or friend)
		kid2_twelve_knots  -> teen2_twelfth_knot
		kid2_bottle_sent   -> teen2_bottle_reply   (adds friend Jessamy Corwen)
		kid2_whistled_back -> teen2_whistle_in_fog
		kid2_asked_sallow  -> teen2_old_teacher    (adds mentor Mira Sallow)
	Ties into existing threads:
		teen2_sealed_envelope (lose) sets sluice_marked  -> world_marked_flood (World)
		teen2_drownside_parcel (lose) sets brine_grudge  -> life_brine_grudge (Life)
]]

return {
	-- ── follow-ups from childhood ───────────────────────────────────────────
	{
		id = "teen2_odile_again",
		title = "The Song at the Gate",
		text = "In the pass queue at the service gate, an old woman with a laundry basket on her hip is humming to herself. You know the tune before you know why: a lantern goes down, a lantern comes up. When she sees your face she stops, and looks at you the way people look at a house they used to live in.",
		weight = 0,
		once = true,
		tags = { "youth", "rim", "friend", "thread_odile" },
		when = { flags = { "kid2_odile_song" } },
		choices = {
			{
				label = "Ask if she is Odile",
				result = {
					addRelation = { kind = "friend", name = "Odile Vell", bond = 60, age = { 58, 70 } },
					sanity = 4,
					log = "It was Odile. She told you that you used to hold her finger so tight it went white, and {newRelation} came by the gate every week after that.",
				},
			},
			{
				label = "Walk her past the queue",
				result = { justice = { 2, 3 }, sanity = 2, log = "You took her basket and walked her straight past the queue on your family's name. The sergeant didn't dare say a word, and she laughed the whole way up the hill." },
			},
			{
				label = "Hum the next line",
				result = { prudence = 2, sanity = 2, log = "You hummed the next line. She smiled, picked up her basket and went through the gate, and you never did learn her name." },
			},
		},
	},
	{
		id = "teen2_greer_rematch",
		title = "Greer Ingram, Again",
		text = "Greer Ingram is waiting at the top of the fish steps, taller now, with the same gap in her teeth and a coil of dock rope over one shoulder. \"{first},\" she says. \"Five years I've been practicing. All seven rope bridges of the Silt, there and back, and first to ring the fish-market bell wins.\"",
		weight = 0,
		once = true,
		tags = { "youth", "rival", "thread_greer" },
		when = { flags = { "kid2_greer_jump" } },
		choices = {
			{
				label = "Race her",
				hint = "Justice clash.",
				clash = { stat = "justice", foe = "Greer Ingram", coins = 2, base = 3, coinPower = 2 },
				win = {
					addRelation = { kind = "rival", name = "Greer Ingram", bond = 35, age = { 13, 17 } },
					justice = { 3, 4 },
					sanity = 3,
					log = "You rang the bell a breath before {newRelation} did. She shook your hand hard and said next time it would be the cathedral roof.",
				},
				lose = {
					addRelation = { kind = "rival", name = "Greer Ingram", bond = 30, age = { 13, 17 } },
					fortitude = { -3, -1 },
					sanity = -1,
					log = "{newRelation} beat you by a whole bridge and rang the bell twice, slowly, while you hauled yourself up the last rope.",
				},
			},
			{
				label = "Ask her to work the docks with you",
				result = {
					addRelation = { kind = "friend", name = "Greer Ingram", bond = 50, age = { 13, 17 } },
					wage = { 6, 14 },
					sanity = 3,
					log = "You said you'd rather earn something than race. {newRelation} looked surprised, then pleased, and the two of you hauled cargo together all summer, keeping count of who carried more.",
				},
			},
			{
				label = "Tell her you're done with dares",
				result = { prudence = 1, sanity = -1, log = "You told Greer you were done with dares. She shrugged, said you'd gotten boring, and went off to find someone who wasn't." },
			},
		},
	},
	{
		id = "teen2_twelfth_knot",
		title = "The Twelfth Knot",
		text = "A cargo net swings loose from a dock crane and knocks a stevedore clean off the pier. He is hanging from the edge by one hand with black water slapping at his boots, everyone is shouting for a rope, and there is one coiled at your feet. Old Isolde's twelfth knot comes back into your hands before you have even thought of it.",
		weight = 0,
		once = true,
		tags = { "youth", "danger", "docks", "thread_knots" },
		when = { flags = { "kid2_twelve_knots" } },
		choices = {
			{
				label = "Tie the twelfth knot",
				hint = "Temperance clash.",
				clash = { stat = "temperance", foe = "Shaking hands", coins = 1, base = 3, coinPower = 2 },
				win = { temperance = { 2, 3 }, justice = 2, sanity = 4, money = { 8, 15 }, log = "You tied the twelfth knot, a loop that couldn't slip, and three dockhands hauled him up by it. The foreman pressed a fistful of {currency} on you and asked who had taught you." },
				lose = { temperance = 1, sanity = -3, log = "Your hands shook, and the knot came apart on the first pull. A dockhand with a boat hook got him out in the end, soaked and shaking." },
			},
			{
				label = "Go in after him",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The cold Mere", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = 2, justice = { 2, 3 }, sanity = 3, log = "You went in after him and kept his head above the water until the dockhands got a line to you both." },
				lose = {
					fortitude = { -8, -4 },
					sanity = -3,
					log = "The cold closed over your head like a lid. The dockhands pulled you both out, and you lay coughing on the planks for an hour.",
					cause = "Drowned off the end of the pier",
				},
			},
			{
				label = "Run for the boat hook",
				result = { prudence = 2, sanity = 1, log = "You ran for the boat hook on the crane post, and the dockhands fished him out with it. Nobody remembered who had fetched it, but you did." },
			},
		},
	},
	{
		id = "teen2_bottle_reply",
		title = "A Bottle Comes Back",
		text = "A Sluice post-runner finds you on the stairs, holding a green glass bottle and wearing a puzzled face. It's your bottle, the one you gave to the Mere years ago, fished out on the far side of the crater. Your old letter is gone, and in its place is a reply addressed to the name you signed, from someone called Jessamy Corwen.",
		weight = 0,
		once = true,
		tags = { "youth", "friend", "thread_bottle" },
		when = { flags = { "kid2_bottle_sent" } },
		choices = {
			{
				label = "Write back tonight",
				result = {
					addRelation = { kind = "friend", name = "Jessamy Corwen", bond = 55, age = { 13, 17 } },
					temperance = 1,
					sanity = 4,
					log = "You wrote back that same night, and letters went back and forth by post-runner for years. {newRelation} became the friend you knew best and had never met.",
				},
			},
			{
				label = "Ride across the crater to find them",
				hint = "5 scrip.",
				requires = { min = { money = 5 } },
				result = {
					addRelation = { kind = "friend", name = "Jessamy Corwen", bond = 65, age = { 13, 17 } },
					money = -5,
					justice = 1,
					sanity = 5,
					log = "You rode the tram around the crater with the letter in your fist and found {newRelation} mending nets on a landing. You talked until the last tram home.",
				},
			},
			{
				label = "Keep the letter, but don't answer",
				result = { prudence = 1, sanity = 1, log = "You kept the letter in a tin and read it now and then, but you never quite found the words to answer it." },
			},
		},
	},
	{
		id = "teen2_whistle_in_fog",
		title = "Three Notes in the Fog",
		text = "The fog is so thick on the rope bridge that you can't see the rail under your own hand, and the bridge has started to sway in a way you don't like. Then, from somewhere out over the water, comes a whistle: three notes, the old fog call, one beat late. You have heard it once before, when you were small.",
		weight = 0,
		once = true,
		tags = { "youth", "strange", "fog", "thread_whistle" },
		when = { flags = { "kid2_whistled_back" } },
		choices = {
			{
				label = "Follow the whistle",
				result = { prudence = { 2, 3 }, sanity = 2, gear = "lantern_token", log = "You followed the three notes step by careful step and came out on solid stone. On the top stair lay a brass token, wet and warm, stamped with a lantern." },
			},
			{
				label = "Whistle back",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The thing in the fog", coins = 1, base = 3, coinPower = 2 },
				win = { prudence = 2, sanity = 4, log = "You whistled back, and the answer came from just ahead, then ahead again, leading you home like a hand on your sleeve. You never saw what was whistling." },
				lose = { fortitude = -1, sanity = -5, log = "You whistled back, and the answer came from right beside your ear. You ran blind across the bridge and didn't stop until you reached your own door." },
			},
			{
				label = "Hold on and wait for morning",
				result = { fortitude = { -2, -1 }, prudence = 1, log = "You held on to the swaying bridge until the fog lifted at dawn. The whistling stopped at midnight, and you were glad, and a little sorry." },
			},
		},
	},
	{
		id = "teen2_old_teacher",
		title = "Mistress Sallow's Night School",
		text = "An unsigned note in your coat pocket leads you down to a net loft on the third Terrace, where someone is teaching dock children their letters by the light of one lamp. It is Mistress Sallow, thinner and greyer, with chalk to her elbows. She puts the chalk down when she sees you. \"I wondered which one of you would come.\"",
		weight = 0,
		once = true,
		tags = { "youth", "study", "mentor", "thread_sallow" },
		when = { flags = { "kid2_asked_sallow" } },
		choices = {
			{
				label = "Ask her to teach you",
				requires = { noRelation = "mentor" },
				result = {
					addRelation = { kind = "mentor", name = "Mira Sallow", bond = 55, age = { 45, 58 } },
					temperance = { 3, 4 },
					justice = 1,
					log = "You came down the Terraces every week after that. {newRelation} taught you the true history of the floodgates, and the arithmetic of who gets wet.",
				},
			},
			{
				label = "Teach the little ones with her",
				result = { justice = { 2, 3 }, temperance = 1, sanity = 3, log = "You stayed until midnight teaching six dock children their letters, and walked home up the Terraces feeling taller than the wall." },
			},
			{
				label = "Leave money for lamp oil",
				hint = "20 scrip.",
				requires = { min = { money = 20 } },
				result = { money = -20, justice = 1, sanity = 2, log = "You left twenty {currency} under the chalk box for lamp oil and slates. She pretended not to see you do it." },
			},
		},
	},

	-- ── anywhere ────────────────────────────────────────────────────────────
	{
		id = "teen2_dropped_purse",
		title = "The Purse on the Tram",
		text = "Someone has left a purse on the tram seat beside you: soft leather, a Charter crest, and so full the clasp won't close. Through the gap you can count at least fifty {currency}. The tram is packed, and nobody is looking at you.",
		once = true,
		tags = { "youth", "money" },
		when = { minAge = 13, maxAge = 17 },
		choices = {
			{
				label = "Find the owner",
				result = { justice = { 2, 3 }, money = 5, sanity = 2, log = "You followed the crest to a Charter tea-house and returned the purse. The owner counted every note, then tipped you five {currency} as if it hurt her." },
			},
			{
				label = "Keep it",
				result = { money = { 45, 60 }, justice = -3, sanity = -2, log = "You kept the purse. You spent the {currency} slowly, and somehow never enjoyed a single note of it." },
			},
			{
				label = "Hand it in at the Sluice office",
				result = { prudence = 2, log = "You handed the purse in at the Sluice office. The clerk thanked you and put it in a drawer, and you had a feeling it would stay there." },
			},
		},
	},
	{
		id = "teen2_sealed_envelope",
		title = "The Sealed Envelope",
		text = "A Sluice clerk on the tram platform pays you five {currency} to run a sealed envelope down to the gatehouse on the Silt, and to be quick about it. Halfway down the stairs the seal comes loose on its own. Inside is a list of Silt addresses, every one circled in red: the rows that will flood first when the gates open.",
		once = true,
		tags = { "youth", "sluice" },
		when = { minAge = 14, maxAge = 17 },
		choices = {
			{
				label = "Deliver it, seal pressed down",
				result = { money = 6, prudence = 1, sanity = -2, log = "You pressed the seal back down and delivered the envelope. The gatehouse clerk tipped you another note and never looked up." },
			},
			{
				label = "Warn the circled rows first",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The gatehouse clerks", coins = 1, base = 3, coinPower = 2 },
				win = { money = 5, justice = { 3, 4 }, sanity = 3, log = "You knocked on every circled door before you delivered the envelope. When High Water came, those families were already up the stairs with their bedding." },
				lose = { money = 5, justice = 2, sanity = -2, setFlags = { "sluice_marked" }, log = "You warned every circled door, but a gatehouse clerk saw you doing it. A week later your own address was on a list, circled in red." },
			},
			{
				label = "Drop it in the Mere",
				result = { money = 5, justice = 1, sanity = 1, log = "You dropped the envelope off a rope bridge and watched it sink. They would write the list again by morning, but the morning would be late." },
			},
		},
	},
	{
		id = "teen2_ghost_tram",
		title = "The Midnight Tram",
		text = "On the lowest platform, the old tram line runs straight down a slipway into the Mere, the way it has since the old city drowned. Tonight, waiting there after midnight, you hear a tram bell ring twice from under the water, the way a tram rings before it stops. Beside you, the rusted route board rattles round to a stop nobody has used in a hundred years: Market Cross.",
		once = true,
		tags = { "youth", "strange" },
		when = { minAge = 13, maxAge = 17 },
		choices = {
			{
				label = "Wait at the edge",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The drowned tram", coins = 1, base = 3, coinPower = 2 },
				win = { prudence = { 2, 3 }, sanity = 2, log = "When the bell went quiet, a tram ticket lay on the platform edge, wet and perfectly printed, for one ride to Market Cross. You kept it." },
				lose = { sanity = -5, condition = "night_terrors", log = "Something bright and slow came up the line toward the platform lamps, and you ran before you could see it properly. You haven't slept well since." },
			},
			{
				label = "Shout the name of your own stop",
				result = { justice = { 1, 2 }, sanity = -2, log = "You shouted the name of your own stop into the dark. The bell stopped at once, and the water went as flat as glass." },
			},
			{
				label = "Walk away without looking back",
				result = { prudence = 1, sanity = -1, log = "You walked away without looking back. Behind you the bell rang once more, very softly, like a question." },
			},
		},
	},

	-- ── the Gutters ─────────────────────────────────────────────────────────
	{
		id = "teen2_lantern_season",
		title = "Lantern Season",
		text = "In the weeks before Lantern Night, every table in the Gutters disappears under paper, paste and split cane. Families who can't write pay a little to have their dead's names painted on the side, and Charter folk pay five times as much for lanterns somebody else folded.",
		once = true,
		tags = { "youth", "festival", "job" },
		when = { minAge = 13, maxAge = 17, side = "gutters" },
		choices = {
			{
				label = "Fold lanterns all night",
				result = { wage = { 10, 20 }, temperance = 1, fortitude = -1, log = "You folded lanterns until your fingers were stiff with paste, and sold every one of them on the ferry steps." },
			},
			{
				label = "Paint names for those who can't write",
				result = { wage = { 3, 8 }, temperance = { 1, 2 }, justice = 1, sanity = 3, log = "You painted names on lanterns for a week, every letter careful. An old man asked you to paint his wife's name twice, so that she would be sure to hear it." },
			},
			{
				label = "Sell at the Charter gate",
				result = { wage = { 20, 35 }, justice = -1, sanity = -2, log = "You sold lanterns at the Charter gate for five times what they were worth. A lady bought ten and asked if you could paint on any names she liked, so long as they were nobody's." },
			},
		},
	},
	{
		id = "teen2_sibling_coal",
		title = "Caught in the Coal Yard",
		text = "{sibling} comes home black to the elbows, with a company guard's whistle still shrieking somewhere down the hill. They were caught filling a sack in the company coal yard and got away, mostly. Tomorrow the guard is going door to door with a description, and he wants a name.",
		once = true,
		tags = { "youth", "family", "crime" },
		when = { minAge = 13, maxAge = 17, side = "gutters", hasRelation = "sibling" },
		choices = {
			{
				label = "Take the blame",
				result = { fortitude = { -3, -1 }, justice = { 2, 3 }, relationBond = { kind = "sibling", amount = 15 }, log = "You told the guard it was you, and worked off the fine shoveling company coal for a month. {sibling} carried your water up the stairs for a year after." },
			},
			{
				label = "Lie to the guard",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The coal-yard guard", coins = 1, base = 3, coinPower = 2 },
				win = { prudence = { 2, 3 }, relationBond = { kind = "sibling", amount = 8 }, log = "You looked the guard in the eye and described a kid from three Wards over, right down to the boots. He thanked you and went away." },
				lose = { justice = -1, sanity = -3, relationBond = { kind = "sibling", amount = 2 }, log = "The guard looked past you at the black handprints on the door frame and wrote your family name in his book." },
			},
			{
				label = "Make them own up",
				result = { justice = 1, prudence = 1, relationBond = { kind = "sibling", amount = -10 }, log = "You walked {sibling} down to the guard post yourself. They worked off the fine in a month of shoveling and barely spoke to you the whole time." },
			},
		},
	},
	{
		id = "teen2_pigeon_loft",
		title = "The Pigeon Loft",
		text = "Old Emrys Thimble keeps forty pigeons in a loft on the tenement roof, and they carry messages for anyone who pays: market prices, Sluice notices, a mother's word to a son across the crater. His legs won't manage the roof ladder anymore. He holds out the key and tells you the birds already know your face.",
		once = true,
		tags = { "youth", "pet", "job" },
		when = { minAge = 13, maxAge = 16, side = "gutters" },
		choices = {
			{
				label = "Keep the loft for him",
				result = { wage = { 8, 16 }, prudence = { 2, 3 }, sanity = 3, log = "You kept Emrys's loft all year, feeding, cleaning and carrying, and learned every bird by the color of its eyes." },
			},
			{
				label = "Raise a bird of your own",
				result = { temperance = { 2, 3 }, sanity = 2, log = "You raised a grey squab of your own and taught it to fly home from the tram terminus. It came back every time, which was more than most people did." },
			},
			{
				label = "Sell the birds to a fancier",
				result = { money = { 15, 30 }, justice = -3, sanity = -3, log = "You sold Emrys's birds to a Charter fancier and told him a lamp-eater had got into the loft. He believed you, which was worse." },
			},
		},
	},
	{
		id = "teen2_tutor_chair",
		title = "The Tutor's Chair",
		text = "A Charter family has hired you to come up through the service gate twice a week and teach their son his sums, because his last three tutors quit. Teodor Vane is twelve, bored and very rich, and he has already told you that his father could have your whole stairwell flooded. The pay is better than the docks.",
		once = true,
		tags = { "youth", "rim", "job", "study" },
		when = { minAge = 14, maxAge = 17, side = "gutters", min = { temperance = 20 } },
		choices = {
			{
				label = "Teach him properly",
				hint = "Temperance clash.",
				clash = { stat = "temperance", foe = "A bored rich boy", coins = 1, base = 3, coinPower = 2 },
				win = { wage = { 20, 35 }, temperance = { 2, 3 }, log = "You taught Teodor long division as the arithmetic of floodgates, and by spring he was asking his father questions his father didn't like." },
				lose = { wage = { 8, 15 }, sanity = -2, log = "Teodor learned nothing except new ways to make tutors quit. You lasted one season and took your pay." },
			},
			{
				label = "Do his sums for him",
				result = { wage = { 25, 40 }, justice = -1, sanity = -1, log = "You did Teodor's sums for him, and he paid you extra to keep quiet. You both knew he was learning nothing." },
			},
			{
				label = "Show him the Silt",
				result = { wage = { 5, 10 }, justice = { 2, 3 }, sanity = 1, log = "You walked Teodor down to the Silt docks one afternoon to see where the floodwater goes. You were dismissed the next day, and he wrote you a letter anyway." },
			},
		},
	},
	{
		id = "teen2_tidetouched_gate",
		title = "Not Through This Gate",
		text = "The night school has been invited through the Charter gate to see the glass gardens, once, as a kindness, and your class is lined up in clean collars. The guard waves you through, and the next kid, and then stops Fen Marlow, who sits beside you every night, and points at the faint gill-lines on her neck. \"Not the Tidetouched,\" he says. \"Rules.\"",
		once = true,
		tags = { "youth", "friend", "rim" },
		when = { minAge = 13, maxAge = 17, side = "gutters", form = "human", notDistrict = "drownside" },
		choices = {
			{
				label = "Stay outside with Fen",
				result = {
					addRelation = { kind = "friend", name = "Fen Marlow", bond = 60, age = { 13, 17 } },
					justice = 1,
					sanity = 2,
					log = "You stepped back out through the gate and sat on the wall with {newRelation}, and the two of you made up what the gardens looked like until the lamps came on.",
				},
			},
			{
				label = "Argue with the guard",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The gate sergeant", coins = 2, base = 3, coinPower = 2 },
				win = {
					addRelation = { kind = "friend", name = "Fen Marlow", bond = 55, age = { 13, 17 } },
					prudence = 2,
					justice = 2,
					log = "You argued until the teacher was ashamed enough to argue too, and the sergeant let {newRelation} through just to be rid of you both.",
				},
				lose = { justice = 1, sanity = -2, log = "The sergeant listened to every word and then shut the gate on both of you. You walked Fen home, and she didn't say much." },
			},
			{
				label = "Go in with the others",
				result = { temperance = 1, sanity = -2, log = "You went in with the others. The glass gardens were beautiful, and afterward you could remember almost nothing about them except the gate." },
			},
		},
	},

	-- ── the Charter ─────────────────────────────────────────────────────────
	{
		id = "teen2_company_exam",
		title = "The Placement Examination",
		text = "Every child inside the walls sits the placement examination of {corp} once, in a long hall of silent desks under three proctors. The score decides which desk you will sit at for the rest of your life. Across the aisle, Ossa Dunmore has a page of answers rolled up inside her pen.",
		once = true,
		tags = { "youth", "rim", "study" },
		when = { minAge = 14, maxAge = 15, side = "charter", notDistrict = "drownside" },
		choices = {
			{
				label = "Sit it honestly",
				hint = "Temperance clash.",
				clash = { stat = "temperance", foe = "The placement examination", coins = 2, base = 3, coinPower = 2 },
				win = { temperance = { 3, 5 }, sanity = 3, log = "You sat it honestly and placed in the first row of desks. Your score was read aloud in the gatehouse square." },
				lose = { temperance = 1, sanity = -3, log = "You sat it honestly and placed in the middle rows, below three children who had bought their answers." },
			},
			{
				label = "Copy from Ossa's pen",
				result = {
					addRelation = { kind = "rival", name = "Ossa Dunmore", bond = 25, age = { 14, 15 } },
					temperance = 1,
					justice = -2,
					log = "You copied from Ossa's rolled-up page and placed one row above her. {newRelation} knew, and she has been waiting to pay you back ever since.",
				},
			},
			{
				label = "Tell the proctor",
				result = {
					addRelation = { kind = "rival", name = "Ossa Dunmore", bond = 15, age = { 14, 15 } },
					justice = 2,
					sanity = -1,
					log = "You raised your hand and told the proctor. {newRelation} was marched out of the hall, and her family has not spoken to yours since.",
				},
			},
		},
	},
	{
		id = "teen2_missing_spoon",
		title = "The Missing Spoon",
		text = "A silver spoon has gone from the sideboard, and the housekeeper has decided it was Nell Garrick, the scullery girl from the Gutters who has scrubbed your family's pots since she was ten. Nell is standing in the hall with her coat already on. You know exactly where the spoon is: behind the greenhouse, where you used it to dig up a bulb and forgot it.",
		once = true,
		tags = { "youth", "rim" },
		when = { minAge = 13, maxAge = 16, side = "charter" },
		choices = {
			{
				label = "Fetch it and own up",
				result = { justice = { 2, 3 }, sanity = 1, log = "You fetched the spoon from behind the greenhouse and owned up in front of everyone. Nell kept her place, and you were kept indoors for a month." },
			},
			{
				label = "Slip Nell your allowance",
				hint = "30 scrip.",
				requires = { min = { money = 30 } },
				result = { money = -30, justice = 1, sanity = -1, log = "You couldn't make yourself confess, but you pressed thirty {currency} into Nell's hand at the service gate. She took it without a word." },
			},
			{
				label = "Say nothing",
				result = { justice = -3, sanity = -3, log = "You said nothing. Nell went down the hill with her coat buttoned to the chin, and the grass grew up over the spoon behind the greenhouse." },
			},
		},
	},

	-- ── the Wards ───────────────────────────────────────────────────────────
	{
		id = "teen2_ropewalk_cable",
		title = "Greasing the Great Cable",
		text = "The Hempen Company's great harbor cable runs from the Ropewalk docks out to a drowned tower in the Mere, as thick as your waist. Once a year it has to be greased end to end, and the company pays Gutter kids who are light enough to walk it with a bucket. The foreman says nobody has fallen yet this year. It is only spring.",
		once = true,
		weight = 12,
		tags = { "youth", "ropewalk", "danger", "job" },
		when = { district = "ropewalk", side = "gutters", minAge = 14, maxAge = 17 },
		choices = {
			{
				label = "Walk the whole cable",
				hint = "Justice clash.",
				clash = { stat = "justice", foe = "The great cable", coins = 2, base = 3, coinPower = 2 },
				win = { wage = { 25, 45 }, justice = { 2, 3 }, sanity = 3, log = "You walked the great cable all the way to the drowned tower and back with a bucket of grease, and the foreman paid you double for the far end." },
				lose = {
					wage = { 5, 10 },
					fortitude = { -6, -3 },
					sanity = -2,
					log = "Your boot slid on fresh grease halfway out, and you went into the cold Mere. The safety boat fished you out, and the foreman paid you for the half you'd done.",
					cause = "Fell from the great cable",
				},
			},
			{
				label = "Grease the near end only",
				result = { wage = { 10, 18 }, fortitude = -1, log = "You greased the near end, where a fall only meant mud, and took a near-end wage for it." },
			},
			{
				label = "Row the safety boat",
				result = { wage = { 6, 12 }, prudence = 2, log = "You took the oars of the safety boat and spent the day watching the walkers above you. You fished out two of them laughing, and one crying." },
			},
		},
	},
	{
		id = "teen2_gatewater_counting_room",
		title = "The Counting Room",
		text = "Under the Gatewater Exchange, in a basement where the great floodgates hum through the walls, rows of young counters sort {currency} notes for the bond ledgers. Tonight, tallying the Gutters' flood insurance, you notice that one Silt row has been charged twice this quarter. The supervisor is asleep at his high desk.",
		once = true,
		weight = 12,
		tags = { "youth", "gatewater", "job" },
		when = { district = "gatewater", minAge = 14, maxAge = 17 },
		choices = {
			{
				label = "Correct the ledger quietly",
				hint = "Temperance clash.",
				clash = { stat = "temperance", foe = "The bond ledger", coins = 1, base = 3, coinPower = 2 },
				win = { wage = { 8, 15 }, temperance = { 2, 3 }, justice = 2, log = "You corrected the ledger so neatly that nobody ever noticed. Forty Silt households paid only once that quarter and never knew why." },
				lose = { wage = { 4, 8 }, sanity = -3, log = "Your correction wouldn't balance. The supervisor woke up, frowned at your figures, and changed everything back." },
			},
			{
				label = "Wake the supervisor",
				result = { wage = { 10, 15 }, prudence = 1, sanity = -1, log = "You woke the supervisor and showed him. He thanked you, docked a junior clerk's pay for the mistake, and left the double charge exactly where it was." },
			},
			{
				label = "Pocket the difference",
				result = { money = { 20, 35 }, justice = -3, sanity = -2, log = "You slid the difference into your boot. Nobody ever checked, which taught you something about the Exchange you would rather not have known." },
			},
		},
	},
	{
		id = "teen2_lampwick_taper",
		title = "The Lamplighter's Round",
		text = "The Lamplight Company hires Gutter kids to walk the Charter streets at dusk with a brass taper and a can of oil, lighting two hundred lamps before the curfew bell. By the end of your round there is always oil left in the can. Down in your own stairwell, the lamps have been dark since the ration was cut.",
		once = true,
		weight = 12,
		tags = { "youth", "lampwick", "job" },
		when = { district = "lampwick", side = "gutters", minAge = 13, maxAge = 17 },
		choices = {
			{
				label = "Hand back every drop",
				result = { wage = { 12, 20 }, prudence = 1, log = "You lit all two hundred lamps and handed back every drop of oil. The foreman marked you down as reliable, which counts for something in Lampwick." },
			},
			{
				label = "Carry the leftovers home",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The meter men", coins = 1, base = 3, coinPower = 2 },
				win = { wage = { 12, 20 }, justice = 1, sanity = 3, log = "Every night you carried the leftover oil home in a tin flask and lit the stairwell lamps, and the whole stairwell knew who to thank." },
				lose = { wage = { 4, 8 }, sanity = -3, log = "A meter man smelled the oil on your coat and took you off the round. You never saw the last week's pay." },
			},
			{
				label = "Light your own stair first",
				result = { wage = { 6, 12 }, justice = 2, sanity = 2, log = "Every night you lit the dead lamps on your own stair before you started the round. You ran late, the foreman docked you, and you didn't care." },
			},
		},
	},
	{
		id = "teen2_foundry_anvil",
		title = "Hammer-Song",
		text = "On Foundry Row the smiths keep time with a work-song, three hammer blows to a line, and the whole street rings with it from dawn to dark. Old Yarrow Flint's striker is down with the smog cough, and she holds out a hammer heavier than your arm. \"Keep the beat,\" she says. \"Miss it, and I hit my thumb, and then you'll be sorry.\"",
		once = true,
		weight = 12,
		tags = { "youth", "foundry", "job" },
		when = { district = "foundry", minAge = 14, maxAge = 17 },
		choices = {
			{
				label = "Strike for her",
				hint = "Fortitude clash.",
				clash = { stat = "fortitude", foe = "The hammer-song", coins = 2, base = 3, coinPower = 2 },
				win = { wage = { 10, 20 }, fortitude = { 2, 3 }, temperance = 1, log = "You kept the beat all day and half the night, until your arms were singing too. Yarrow paid you and asked if you'd come back." },
				lose = { wage = { 3, 6 }, fortitude = -2, condition = "burned_hands", log = "You missed the beat, the iron slipped, and a spray of sparks caught your hands. Yarrow bandaged them herself and said everybody does it once." },
			},
			{
				label = "Learn the song first",
				result = { temperance = { 2, 3 }, prudence = 1, log = "You asked to learn the song before the hammer. Yarrow sang you all forty verses, and some of them, it turned out, were about her." },
			},
			{
				label = "Forge a knife of your own",
				result = { gear = "dock_knife", temperance = 1, log = "In the evenings Yarrow let you use the forge, and you hammered out a dock knife of your own: short, ugly and honest." },
			},
		},
	},
	{
		id = "teen2_drownside_parcel",
		title = "A Parcel for the Kin",
		text = "A Brine Kin boatman is sitting on your step, peeling an orange with his thumbnail. \"Cousin,\" he says, \"a parcel needs to cross the channel to the old counting house by dark, and the Sluice launch is watching the boats. Nobody watches a kid on the rope bridges.\" The parcel is small, heavy and sewn shut.",
		once = true,
		tags = { "youth", "drownside", "brine", "crime" },
		when = { district = "drownside", minAge = 14, maxAge = 17 },
		choices = {
			{
				label = "Carry it across",
				hint = "Justice clash.",
				clash = { stat = "justice", foe = "The Sluice launch", coins = 1, base = 3, coinPower = 2 },
				win = { wage = { 20, 40 }, justice = 2, log = "You carried the parcel over four rope bridges with the Sluice launch idling below, and handed it to a cousin who already knew your name." },
				lose = { sanity = -4, setFlags = { "brine_grudge" }, log = "The Sluice launch hailed you, and you dropped the parcel into the channel and ran. The Kin were very polite about it, which was the frightening part." },
			},
			{
				label = "Pick the stitches and look",
				result = { wage = { 15, 25 }, prudence = 2, sanity = -1, log = "You picked the stitches and looked inside: old Wreck Company ledger pages, every one covered in names. You sewed it shut again and carried it anyway." },
			},
			{
				label = "Turn him down",
				result = { prudence = 1, sanity = -1, log = "You told the cousin no. He finished his orange, thanked you for your time, and wrote something in a small book." },
			},
		},
	},
}
