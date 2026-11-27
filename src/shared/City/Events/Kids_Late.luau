--[[
	KIDS, LATE (kl_): ages 7-12 in the Backstreets. Errands for coins, first friends and
	rivals, a sibling to look after, a stray dog, the roof and the WARP trains, the wrong
	block, stealing or not, the laundry's back room, the Fixer across the street, the Wing
	on a screen, and the Night as a kid who knows the rules and is curious anyway.
	The City arrives in steps: kids hear rumors and see things from a distance. Events set
	knows_syndicates / knows_fixers / knows_wings / knows_night when a kid learns something
	real, and require them when a scene assumes the kid already knows.
	Faces: Cast/Kids_Late.luau. Nest, District and origin scenes: Kids_Late2.luau.

	Scheduled kid scenes (weight 0, kept next to the scene that plants them):
		kl_juno_bolts -> kl_juno_depot (3 years), kl_fixer_window -> kl_dalia_diner (1),
		kl_wicks_offer -> kl_wicks_envelope (1), kl_crows_bread -> kl_crow_gifts (1)

	Follow-ups (weight 0) at the end of this file:
		kl_pak_change    -> kl_pak_job       (Mr. Pak remembers who gave back the change)
		kl_garza_letter  -> kl_garza_son     (the son comes home from the Pack)
		kl_pawn_watch    -> kl_watch_back    (the watch is still in the window)
		kl_juno_depot    -> kl_juno_rides    (Juno rides the WARP train)
		kl_teodor_toll   -> kl_teodor_grown  (Teodor in a Rat's jacket)
		kl_sibling_shoes -> kl_sibling_repays
		kl_dog_stairs    -> kl_dog_door (a year on), kl_dog_old
		kl_crow_gifts    -> kl_crow_door     (what the crows' key opens)
		kl_wallet_gutter -> kl_card_asked    (the Feather comes looking for her card)
		kl_wicks_offer   -> kl_wicks_door    (the Wicks want more)
		kl_dalia_diner   -> kl_dalia_call    (the Fixer's card)
		kl_exam_van      -> kl_exam_hall     (the Feather entrance exam)
		kl_flashlight    -> kl_yeva_meets    (the girl with the flashlight)
]]

return {
	-- ── errands and coins ──────────────────────────────────────────────────
	{
		id = "kl_pak_change",
		title = "Too Much Change",
		art = "street",
		text = "Mr. Pak hands you change for a ten. You paid with a five.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 10 },
		dialogue = {
			{ who = "kl_pak", line = "Count it in front of me, kid. Everybody counts in front of me." },
			{ who = "kl_pak", line = "No, don't count it. The radio's on. Go." },
		},
		choices = {
			{
				label = "Give back the extra five",
				result = {
					intelligence = 1,
					sanity = 1,
					setFlags = { "kl_pak_honest" },
					schedule = { event = "kl_pak_job", inYears = 6 },
					log = "You slid five Ahn back across the counter. Mr. Pak looked at it for a long time, then wrote your name on the back of a receipt.",
					dialogue = { { who = "kl_pak", line = "My nephew wouldn't have done that. My nephew is a Rat." } },
				},
			},
			{
				label = "Pocket it and go",
				result = { money = 5, setFlags = { "kl_pak_kept" }, log = "You walked out five Ahn richer. Mr. Pak recounted his till that night, and after that he watched your hands." },
			},
			{
				label = "Say he short-changed you",
				hint = "Mental Strength check. Lying to a shopkeeper.",
				clash = { stat = "mind", foe = "Mr. Pak's memory", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 1, money = 10, setFlags = { "kl_pak_kept" }, log = "You said he owed you five more, with a straight face, and he paid it. You had fifteen Ahn and a stomachache all the way home." },
				lose = { sanity = -4, setFlags = { "kl_pak_banned" }, log = "\"I gave you a ten for a five,\" he said slowly. \"Out. Send somebody taller next time.\"" },
			},
		},
	},
	{
		id = "kl_sasha_parcels",
		title = "Eleven Parcels",
		art = "street",
		text = "Sasha the courier is sitting on your front step with his shoes off and eleven parcels beside him. He holds up a coin.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 11 },
		dialogue = {
			{ who = "kl_sasha", line = "Two Ahn a flight. Building nine, top floor. Don't let the old lady see you're a kid." },
			{ who = "kl_sasha", line = "She tips couriers. She doesn't tip kids. Nobody tips kids." },
		},
		choices = {
			{
				label = "Run them all up",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Nine flights, no lift", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { speed = 1, health = 1, money = 14, log = "Nine flights, eleven doors. The old lady squinted at you and tipped anyway. Sasha kept the tip and paid you fourteen." },
				lose = { health = { -4, -2 }, sanity = -3, log = "Your legs quit on the seventh floor. Sasha found you sitting on parcel six and finished the job himself, sighing like an old man." },
			},
			{
				label = "Ask for half up front",
				result = {
					mind = 1,
					money = 4,
					log = "He paid four up front and ran the parcels up himself, laughing.",
					dialogue = { { who = "kl_sasha", line = "You'll do fine. Somebody's going to hate you for it." } },
				},
			},
			{
				label = "Shake a parcel first",
				result = { mind = 1, sanity = -3, setFlags = { "kl_shook_parcel" }, log = "Something inside tapped back. Sasha took that parcel off you very gently and carried it up himself." },
			},
		},
	},
	{
		id = "kl_drain_coin",
		title = "The Coin in the Grate",
		art = "alley",
		text = "A ten-Ahn coin jumps out of your hand and drops through the storm grate. You can see it down there on a ledge, just past arm's reach.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Fish for it with gum on a string",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A slippery ledge", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, money = 10, log = "It took two hours and all the gum on the street. You got it. You'd never been so proud of anything." },
				lose = { sanity = -3, log = "The coin slid off the ledge into the dark. You heard it land a long way down. Then you heard something pick it up." },
			},
			{
				label = "Climb down after it",
				hint = "Health check.",
				clash = { stat = "health", foe = "The drain ladder", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { health = 1, strength = 1, money = 10, log = "The ladder went down further than the street was deep. You grabbed the coin and didn't look along the tunnel. Something down there hummed." },
				lose = { health = { -4, -2 }, sanity = -3, log = "A rung gave. You hung there until the laundry man hauled you out by the collar and told you what lives under grates. He wasn't sure either." },
			},
			{
				label = "Leave it",
				result = { mind = 1, log = "You left it. By morning someone had pried the grate open, and the coin was gone." },
			},
		},
	},
	{
		id = "kl_queue_place",
		title = "Holding a Place",
		art = "clinic",
		text = "Mrs. Oduya pays you six Ahn to hold her place in the clinic line from five in the morning. At seven, a man in a good coat steps in front of you like you're a lamppost.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Let him",
				result = { money = 6, sanity = -1, log = "Mrs. Oduya came at eight, saw the coat, and paid you anyway. \"Coats like that,\" she said, and didn't finish." },
			},
			{
				label = "Tell him to go to the back",
				hint = "Strength check. He isn't used to kids.",
				clash = { stat = "strength", foe = "A man in a good coat", coins = 1, base = 3, coinPower = 2, fixed = true },
				win = { strength = 2, money = 8, log = "You said it loud enough for the whole line, and the whole line agreed. He went to the back. Mrs. Oduya paid you eight." },
				lose = { money = 6, sanity = -4, log = "He looked down at you until you looked away, and stayed exactly where he was. Mrs. Oduya saw the doctor an hour later than she should have." },
			},
			{
				label = "Sell him your spot",
				result = { money = 15, sanity = -3, setFlags = { "kl_sold_spot" }, log = "He paid fifteen without blinking. You went to the back of the line and held that place for Mrs. Oduya until noon. She never found out." },
			},
		},
	},
	{
		id = "kl_garza_letter",
		title = "Read It Slow",
		art = "home",
		text = "Old Mr. Garza can't read, so he pays you a coin a letter. Today's envelope has an R Corp stamp, and it's about his son in the Pack.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 11 },
		dialogue = {
			{ who = "kl_garza", line = "Read it slow. I want to hear it twice." },
		},
		choices = {
			{
				label = "Read it exactly as written",
				result = {
					mind = 1,
					sanity = -2,
					setFlags = { "knows_wings", "kl_garza_truth" },
					schedule = { event = "kl_garza_son", inYears = 5 },
					log = "Contract extended four years, no leave. He listened twice, folded the letter into a square and paid you two coins instead of one.",
				},
			},
			{
				label = "Say his son's coming home soon",
				hint = "Mental Strength check. He watches faces.",
				clash = { stat = "mind", foe = "A man who watches faces", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 1, sanity = 1, setFlags = { "knows_wings", "kl_garza_lie" }, schedule = { event = "kl_garza_son", inYears = 5 }, log = "You said soon. He smiled all week and bought the whole stairwell tea." },
				lose = {
					sanity = -4,
					setFlags = { "knows_wings", "kl_garza_truth" },
					schedule = { event = "kl_garza_son", inYears = 5 },
					log = "Halfway through, your voice went wrong. Mr. Garza took the letter back and held it out to you again.",
					dialogue = { { who = "kl_garza", line = "Again. The real one." } },
				},
			},
			{
				label = "Say the ink's too smudged",
				result = { intelligence = 1, sanity = -1, setFlags = { "knows_wings" }, log = "He took it to the tax clerk on the corner, who read it out to him in the street, loudly, for free." },
			},
		},
	},
	{
		id = "kl_birthday_bun",
		title = "A Candle Stub",
		art = "home",
		text = "There's no money for a cake this year. {mother} comes home at two with a bun from the stall and a candle stub pushed into the middle of it.",
		weight = 10,
		once = true,
		when = { side = "backstreets", hasRelation = "mother", minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Make a wish",
				result = { sanity = 3, log = "The stub went out on the first try. {mother} said that meant it would come true. She didn't ask what it was." },
			},
			{
				label = "Split it with {mother}",
				result = { sanity = 2, relationBond = { kind = "mother", amount = 6 }, log = "You cut it in half with the bread knife. She said she wasn't hungry, then ate her half in two bites." },
			},
			{
				label = "Keep the candle",
				result = { mind = 1, setFlags = { "kl_kept_candle" }, log = "You ate the bun and kept the stub in your pocket. Years later you lit it once, during a Night, for about a minute." },
			},
		},
	},
	{
		id = "kl_pawn_watch",
		title = "The Watch in the Window",
		art = "market",
		text = "In the pawnshop window, between a cracked visor and a cello, is {father}'s brass pocket watch. {father} said it was out being repaired.",
		weight = 10,
		once = true,
		when = { side = "backstreets", hasRelation = "father", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Start saving to buy it back",
				result = { intelligence = 1, setFlags = { "kl_watch_saving" }, schedule = { event = "kl_watch_back", inYears = 5 }, log = "You started a jar and went to look at the watch every week. The pawnbroker started dusting it before you came." },
			},
			{
				label = "Tell {father} you saw it",
				result = { sanity = -2, relationBond = { kind = "father", amount = 4 }, log = "{father} went quiet, then said the rent had been due. Neither of you mentioned it again." },
			},
			{
				label = "Ask the pawnbroker to hold it",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A pawnbroker's patience", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					setFlags = { "kl_watch_saving" },
					schedule = { event = "kl_watch_back", inYears = 5 },
					log = "He'd hold it, he said, if you swept his floor every Sunday. You swept. He held it.",
					dialogue = { { who = "The Pawnbroker", line = "Ninety Ahn. Your father had till spring. You've got as long as you keep sweeping." } },
				},
				lose = { sanity = -3, log = "\"Everybody asks,\" he said. By spring the watch was gone, and you looked for it in every window for years." },
			},
		},
	},

	-- ── first friends and rivals ───────────────────────────────────────────
	{
		id = "kl_juno_bolts",
		title = "Lucky Bolts",
		art = "street",
		text = "A girl from the fourth floor is selling bolts from a bucket on the stairs. Her sign says LUCKY BOLTS 1 AHN.",
		weight = 14,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 9 },
		dialogue = {
			{ who = "kl_juno", line = "They're lucky. They fell off the WARP rail. I watched them fall." },
			{ who = "kl_juno", line = "Okay, one fell off the WARP rail. I don't know which one, so they're all lucky." },
		},
		choices = {
			{
				label = "Buy one",
				requires = { min = { money = 1 } },
				result = {
					money = -1,
					sanity = 2,
					setFlags = { "kl_juno_friend" },
					schedule = { event = "kl_juno_depot", inYears = 3 },
					addRelation = { kind = "friend", name = "Juno Petrak", bond = 55, age = { 7, 10 } },
					log = "She said it was probably the WARP one. You kept it in your pocket for years, just in case.",
				},
			},
			{
				label = "Help her sell them",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A street that doesn't want bolts", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					intelligence = 1,
					money = 5,
					setFlags = { "kl_juno_friend" },
					schedule = { event = "kl_juno_depot", inYears = 3 },
					addRelation = { kind = "friend", name = "Juno Petrak", bond = 60, age = { 7, 10 } },
					log = "You moved the bucket to the clinic line and said the bolts were good for waiting. You sold ten. Juno split it to the Ahn.",
				},
				lose = {
					sanity = -3,
					setFlags = { "kl_juno_friend" },
					schedule = { event = "kl_juno_depot", inYears = 3 },
					addRelation = { kind = "friend", name = "Juno Petrak", bond = 45, age = { 7, 10 } },
					log = "You sold none together. She said it was the street's fault and walked you home anyway.",
				},
			},
			{
				label = "Tell her bolts aren't lucky",
				result = {
					mind = 1,
					setFlags = { "kl_juno_friend" },
					schedule = { event = "kl_juno_depot", inYears = 3 },
					addRelation = { kind = "friend", name = "Juno Petrak", bond = 45, age = { 7, 10 } },
					log = "She gave you one for free, to prove it. You argued about it for years.",
					dialogue = { { who = "kl_juno", line = "Everything's lucky if it falls from high enough." } },
				},
			},
		},
	},
	{
		id = "kl_juno_depot",
		title = "The Depot Fence",
		art = "train",
		text = "Juno has found a hole in the WARP depot fence where you can watch the trains come in. She's been there every night this week.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_juno_friend" }, minAge = 10, maxAge = 12 },
		dialogue = {
			{ who = "kl_juno", line = "The doors open and everybody gets off slow. Like their legs forgot how." },
			{ who = "kl_juno", line = "It's ten seconds across the City. How do your legs forget in ten seconds?" },
		},
		choices = {
			{
				label = "Go and watch with her",
				hint = "Mental Strength check. There's a guard.",
				clash = { stat = "mind", foe = "A depot guard with a flashlight", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 1, sanity = -2, setFlags = { "kl_juno_dream" }, schedule = { event = "kl_juno_rides", inYears = 5 }, log = "A man stepped off the train, looked at his own hands, and sat down on the platform. Juno wrote it in her notebook." },
				lose = { sanity = -3, setFlags = { "kl_juno_dream" }, schedule = { event = "kl_juno_rides", inYears = 5 }, log = "The flashlight found you both. You ran, and the guard didn't bother following. Juno laughed all the way home. You didn't." },
			},
			{
				label = "Give her your First Class stub",
				requires = { flags = { "kl_ticket_stub" } },
				result = {
					sanity = 3,
					setFlags = { "kl_juno_dream", "kl_juno_ticket" },
					clearFlags = { "kl_ticket_stub" },
					schedule = { event = "kl_juno_rides", inYears = 5 },
					log = "She held the stub up to the depot lights like it was real.",
					dialogue = { { who = "kl_juno", line = "First Class. I'm going to ride it, and I'll tell you everything." } },
				},
			},
			{
				label = "Tell her to stop going",
				result = {
					mind = 1,
					log = "She went anyway, for another month. Then she stopped, and never said why.",
					dialogue = { { who = "kl_juno", line = "You sound like my dad." } },
				},
			},
		},
	},
	{
		id = "kl_teodor_toll",
		title = "Teodor's Corner",
		art = "street",
		text = "Teodor is eleven and has decided the corner by the bakery is his. Kids who don't pay go round by the canal, which takes twenty minutes.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 10 },
		dialogue = {
			{ who = "kl_teodor", line = "One Ahn. It's a toll. Tolls are legal, my uncle says." },
		},
		choices = {
			{
				label = "Pay the toll",
				requires = { min = { money = 1 } },
				result = { money = -1, sanity = -2, setFlags = { "kl_teodor_known" }, schedule = { event = "kl_teodor_grown", inYears = 6 }, log = "You paid. He bit the coin like he'd seen it done on a screen and waved you through." },
			},
			{
				label = "Fight him for the corner",
				hint = "A fight. He's older.",
				clash = { stat = "strength", foe = "Teodor", coins = 1, base = 3, coinPower = 2, fixed = true, fight = true, enemy = "bully" },
				win = {
					strength = 2,
					money = 6,
					setFlags = { "kl_teodor_known", "kl_teodor_beaten" },
					addRelation = { kind = "rival", name = "Teodor Brask", bond = 20, age = { 11, 12 } },
					schedule = { event = "kl_teodor_grown", inYears = 6 },
					log = "He went over backward into the bakery's flour sacks and came up white. The corner was free. So was his toll money, in the flour.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -3,
					setFlags = { "kl_teodor_known" },
					addRelation = { kind = "rival", name = "Teodor Brask", bond = 20, age = { 11, 12 } },
					schedule = { event = "kl_teodor_grown", inYears = 6 },
					log = "He was bigger and he'd done this before. You went the canal way for a month, and he waved at you from his corner every time.",
				},
			},
			{
				label = "Go round by the canal",
				result = { health = 1, setFlags = { "kl_teodor_known" }, schedule = { event = "kl_teodor_grown", inYears = 6 }, log = "Twenty minutes each way. By summer half the street went the canal way with you, and Teodor's corner went broke." },
			},
		},
	},
	{
		id = "kl_new_kid",
		title = "The New Kid on Fourth",
		art = "street",
		text = "The new kid on Fourth Street talks like he's from District 7 and keeps his coat buttoned to the neck in summer. Three kids have his cap and are throwing it over his head.",
		weight = 10,
		once = true,
		when = { side = "backstreets", notDistrict = "d7", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Get his cap back",
				clash = { stat = "strength", foe = "Three kids and a cap", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "bully" },
				win = {
					strength = 2,
					setFlags = { "kl_matyas_friend" },
					addRelation = { kind = "friend", name = "Matyas Lenz", bond = 60, age = { 8, 12 } },
					log = "You came out of it with the cap and his name, Matyas. He didn't say thank you. He walked home next to you, which was the same thing.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -3,
					setFlags = { "kl_matyas_friend" },
					addRelation = { kind = "friend", name = "Matyas Lenz", bond = 50, age = { 8, 12 } },
					log = "They kept the cap. Matyas said in Seven it would have been six against three. You weren't sure that was a joke.",
				},
			},
			{
				label = "Laugh with the others",
				result = { sanity = -3, setFlags = { "kl_laughed_matyas" }, log = "He looked right at you while you laughed. He got the cap back eventually, and never once looked at you again." },
			},
			{
				label = "Ask him where he's from",
				result = {
					mind = 1,
					codex = "bs_lore_d7",
					log = "The cap kids got bored and wandered off. He wiped the cap on his coat and put it back on very straight.",
					dialogue = { { who = "Matyas", line = "Seven. My father was in the war. So we're not allowed in any Nest." } },
				},
			},
		},
	},
	{
		id = "kl_friend_tin",
		title = "The Biscuit Tin",
		art = "alley",
		text = "{friend} takes you to a gap between two buildings, too narrow for grown-ups, and pulls out a biscuit tin full of the best things ever found.",
		weight = 10,
		once = true,
		when = { side = "backstreets", hasRelation = "friend", minAge = 8, maxAge = 12 },
		dialogue = {
			{ who = "{friend}", line = "Don't touch the badge. The badge is the best one." },
			{ who = "{friend}", line = "It's a real Fixer's. Grade Nine. I found it on the steps after a Night." },
		},
		choices = {
			{
				label = "Hold the badge",
				result = { sanity = -2, setFlags = { "knows_fixers" }, log = "It was heavier than it looked, and the name on the back was scratched off. Grade Nine is the worst grade. You both held it like the best." },
			},
			{
				label = "Add your best marble to the tin",
				result = { sanity = 3, relationBond = { kind = "friend", amount = 8 }, setFlags = { "kl_shared_tin" }, log = "{friend} looked at your marble for a long time, then set it next to the badge. That was where the best things went." },
			},
			{
				label = "Say you should give it back",
				result = {
					mind = 1,
					setFlags = { "knows_fixers" },
					log = "Neither of you knew. You put it back in the tin and shut the lid very gently.",
					dialogue = { { who = "{friend}", line = "Give it back to who?" } },
				},
			},
		},
	},

	-- ── brothers and sisters ───────────────────────────────────────────────
	{
		id = "kl_sibling_shoes",
		title = "Socks on the Stairs",
		art = "street",
		text = "{sibling} comes up the stairs in socks. A kid from the canal blocks took the shoes, and he's wearing them right now by the fish market, two sizes too big.",
		weight = 10,
		once = true,
		when = { side = "backstreets", hasRelation = "sibling", minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Go and get them back",
				clash = { stat = "strength", foe = "The kid in the stolen shoes", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = {
					strength = 2,
					relationBond = { kind = "sibling", amount = 8 },
					setFlags = { "kl_sibling_defended" },
					schedule = { event = "kl_sibling_repays", inYears = 6 },
					log = "You walked into the fish market and walked out with the shoes. {sibling} didn't say anything to you, and told everyone else for years.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -3,
					relationBond = { kind = "sibling", amount = 6 },
					setFlags = { "kl_sibling_defended" },
					schedule = { event = "kl_sibling_repays", inYears = 6 },
					log = "He kept the shoes. You came home with your own, barely. {sibling} sat with you on the stairs until it got dark.",
				},
			},
			{
				label = "Buy them back",
				requires = { min = { money = 5 } },
				result = { money = -5, relationBond = { kind = "sibling", amount = 4 }, log = "Five Ahn for shoes that were already yours. He counted it twice. {sibling} said you got robbed, and you had." },
			},
			{
				label = "Make cardboard shoes",
				result = { intelligence = 1, sanity = 2, relationBond = { kind = "sibling", amount = 5 }, log = "Cardboard and laundry tape. They lasted four days, and {sibling} wore them like they came from the Nest." },
			},
		},
	},
	{
		id = "kl_sibling_sleepwalk",
		title = "3:05",
		art = "home",
		text = "You wake because {sibling} is standing at the front door in the dark, eyes open, hand on the first lock. The clock says 3:05.",
		weight = 10,
		once = true,
		when = { side = "backstreets", hasRelation = "sibling", flags = { "knows_night" }, minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Hold on and don't let go",
				hint = "Health check.",
				clash = { stat = "health", foe = "A sleepwalker who wants the door", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { health = 1, sanity = -2, relationBond = { kind = "sibling", amount = 6 }, log = "You held on until 3:40. {sibling} woke up on the floor next to you, cross, and didn't believe a word of it." },
				lose = { health = { -3, -2 }, sanity = -4, log = "{sibling} had two locks open before the grown-ups woke. The third held. The door got a fourth lock the next day, up high." },
			},
			{
				label = "Wake the whole house",
				result = { mind = 1, sanity = -1, log = "Everyone woke up shouting, and {sibling} woke up crying without knowing why. The door got a fourth lock the next day." },
			},
			{
				label = "Say the rule in {sibling}'s ear",
				result = { mind = 1, sanity = 1, relationBond = { kind = "sibling", amount = 4 }, log = "\"Home before three. We're home.\" The hand let go of the lock. You both slept on the floor by the door until morning." },
			},
		},
	},
	{
		id = "kl_sibling_lamp",
		title = "The Hall Lamp",
		art = "home",
		text = "You and {sibling} were playing ball on the stairs, and now the landlord's hall lamp is in pieces. He's coming up. You can hear his keys.",
		weight = 8,
		once = true,
		when = { side = "backstreets", hasRelation = "sibling", minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Say it was you",
				result = { strength = 1, relationBond = { kind = "sibling", amount = 6 }, log = "He made you sweep the stairs for a month. {sibling} brought you a bun every Sunday you did it." },
			},
			{
				label = "Blame the wind",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A landlord who has heard everything", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, log = "You said the window was open and the wind came in hard. He looked at the shut window for a while, then laughed and fixed it himself." },
				lose = { sanity = -3, log = "\"The wind,\" he said. He put the lamp on the rent. Your family paid it and looked at you both for a week." },
			},
			{
				label = "Say it was {sibling}",
				result = { sanity = -1, relationBond = { kind = "sibling", amount = -10 }, log = "You pointed. {sibling} swept the stairs for a month and didn't speak to you for most of it." },
			},
		},
	},

	-- ── a dog, a yard dog, the crows ───────────────────────────────────────
	{
		id = "kl_dog_stairs",
		title = "A Dog Under the Stairs",
		art = "alley",
		text = "There's a gray dog under the stairs with one ear and a collar with no tag. It doesn't beg. It watches the street door like it's waiting for someone.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Share your lunch with it",
				result = {
					sanity = 3,
					setFlags = { "kl_dog" },
					schedule = { { event = "kl_dog_door", inYears = 1 }, { event = "kl_dog_old", inYears = 7 } },
					log = "You gave him half your bun. He was there the next day, and the next. You called him Tuesday, because that's when he came.",
				},
			},
			{
				label = "Keep him on the roof",
				result = {
					intelligence = 1,
					sanity = 2,
					setFlags = { "kl_dog", "kl_dog_roof" },
					schedule = { { event = "kl_dog_door", inYears = 1 }, { event = "kl_dog_old", inYears = 7 } },
					log = "No dogs in the flat, so Tuesday lived on the roof in a crate with your old blanket. He barked at every WARP train that went over.",
				},
			},
			{
				label = "Leave him be",
				result = { mind = 1, log = "After a week the space under the stairs was empty. You looked there every morning anyway." },
			},
		},
	},
	{
		id = "kl_dog_strays",
		title = "Three Strays and Tuesday",
		art = "alley",
		text = "Three big strays have Tuesday backed into the corner behind the fish market. He's too old to run, or too stubborn.",
		weight = 10,
		once = true,
		when = { side = "backstreets", flags = { "kl_dog" }, minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Wade in with a broom",
				clash = { stat = "strength", foe = "Three fish-market strays", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "beast" },
				win = { strength = 2, sanity = 2, log = "You swung the broom the way the watch swings its stick. The strays decided the fish market had better corners. Tuesday walked home very proud." },
				lose = { health = { -4, -2 }, sanity = -3, log = "The strays didn't care about the broom. A fishmonger came out with a hose and ended it for everyone. You walked home soaked, Tuesday beside you." },
			},
			{
				label = "Throw them the scrap bucket",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Three hungry noses", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, log = "You grabbed the fishmonger's scrap bucket and threw it the other way. Three strays chose dinner. Tuesday chose you." },
				lose = { health = -2, sanity = -3, log = "The scraps landed at your own feet. The fishmonger came out with a hose and ended it for everyone." },
			},
			{
				label = "Yell for help",
				result = { sanity = -1, log = "Half the market came out and the strays went. Tuesday looked at you like you'd cheated, which you had." },
			},
		},
	},
	{
		id = "kl_scrap_dog",
		title = "The Yard Dog",
		art = "ruins",
		text = "Behind the scrap yard there's a pile where kids find copper, three Ahn a fistful. There's also the yard's dog, the size of a door, in a Workshop collar.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Go for the copper anyway",
				hint = "A fight. The dog is big.",
				clash = { stat = "strength", foe = "The yard dog", coins = 1, base = 3, coinPower = 2, fixed = true, fight = true, enemy = "beast" },
				win = { strength = 2, money = { 8, 12 }, log = "It came at you and you didn't move, and it stopped. You walked out with both fists full while it watched you go, thinking it over." },
				lose = { health = { -5, -3 }, sanity = -3, log = "You went over the fence with nothing. Your sleeve stayed on the other side. The dog kept it." },
			},
			{
				label = "Bribe it with a sausage end",
				requires = { min = { money = 2 } },
				result = { intelligence = 1, money = 4, log = "The dog took the sausage end like a bribe, which it was. You filled your pockets while it ate. Workshop dogs know a deal." },
			},
			{
				label = "Come back at dawn",
				result = { mind = 1, money = 3, log = "At dawn the dog was asleep and so was the yard man. One fistful. Three Ahn. Enough." },
			},
		},
	},
	{
		id = "kl_crows_bread",
		title = "The Crows on Pipe Street",
		art = "alley",
		text = "The crows on Pipe Street remember faces. Four of them are sitting on the wall between you and home, and you're carrying the bread.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Charge them",
				clash = { stat = "strength", foe = "Four Pipe Street crows", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "crow" },
				win = { strength = 1, sanity = 2, log = "You ran at them flapping and yelling, and they left, offended. You got the bread home. They never forgot your face." },
				lose = { health = -2, sanity = -3, log = "They took the bread in pieces, very organized about it. You went home with the empty paper bag and a story nobody believed." },
			},
			{
				label = "Throw them the heel of the loaf",
				result = { sanity = 2, setFlags = { "kl_crow_fed" }, schedule = { event = "kl_crow_gifts", inYears = 1 }, log = "They let you pass. The next morning there was a bottle cap on your windowsill, polished." },
			},
			{
				label = "Go the long way",
				result = { mind = 1, log = "You went round by the laundry. The crows followed you the whole way, wall to wall, taking turns." },
			},
		},
	},
	{
		id = "kl_crow_gifts",
		title = "Gifts From Pipe Street",
		art = "rooftop",
		text = "You've fed the Pipe Street crows for a year, and they leave things on your sill now, mostly buttons. This morning it's a brass key on a tag that says 9.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_crow_fed" }, minAge = 8, maxAge = 11 },
		choices = {
			{
				label = "Keep the key",
				result = { sanity = 1, setFlags = { "kl_crow_key" }, schedule = { event = "kl_crow_door", inYears = 5 }, log = "You hung it on a string round your neck. The crows watched you do it, like that had been the idea." },
			},
			{
				label = "Hand it in at the watch post",
				result = { mind = 1, log = "The watch post dropped it in a drawer with a hundred other keys. The crows left nothing for a month." },
			},
			{
				label = "Leave them something back",
				result = { sanity = 3, log = "You left a shiny button on the sill. By noon it was gone, and two crows sat on your railing watching your window like guards." },
			},
		},
	},

	-- ── the wrong block ────────────────────────────────────────────────────
	{
		id = "kl_wrong_block",
		title = "The Wrong Block",
		art = "alley",
		text = "Your shortcut came out on a street you don't know. Every lamppost has the same hook painted on it in white, and everyone on the stoops has stopped talking.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 11 },
		codex = "bs_lore_alley_grades",
		choices = {
			{
				label = "Walk like you live here",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A street that knows its own", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, setFlags = { "knows_syndicates" }, log = "You walked slow and turned left like you meant it. Nobody stopped you. The hooks meant a Syndicate's street, an older kid told you later." },
				lose = { sanity = -4, setFlags = { "knows_syndicates" }, log = "A woman on a stoop asked whose kid you were and didn't like the answer. Two boys walked you to the last hook and pointed." },
			},
			{
				label = "Pay a kid to walk you out",
				requires = { min = { money = 2 } },
				result = {
					money = -2,
					setFlags = { "knows_syndicates" },
					log = "A girl with a hook drawn on the back of her hand took two Ahn and walked you to the edge of it.",
					dialogue = { { who = "A Girl With a Hook", line = "Don't cut through here. This street's ours. Yours is the one with no paint." } },
				},
			},
			{
				label = "Run",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Eleven streets you don't know", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { speed = 1, health = 1, setFlags = { "knows_syndicates" }, log = "You ran until the lampposts were plain again, then until they were yours." },
				lose = { health = -2, sanity = -3, setFlags = { "knows_syndicates" }, log = "You ran into a dead end with a hook on the wall. A man in a coat watched you come back out. He didn't have to say anything." },
			},
		},
	},
	{
		id = "kl_late_far",
		title = "2:21",
		art = "alley",
		text = "The clock over the dye works says 2:21. You're on the wrong side of the canal, and home is twenty-five minutes away if you walk.",
		weight = 10,
		once = true,
		when = { side = "backstreets", flags = { "knows_night" }, minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Run the main road",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "Twenty-five minutes of road", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 2, sanity = -2, log = "You were up the stairs by 2:50 with your lungs on fire. Nobody at home asked where you'd been. They just held on." },
				lose = { health = -3, sanity = -5, log = "You took the wrong turn at the bridge. You got in at 3:09, and the floor was already humming under your feet." },
			},
			{
				label = "Knock on a stranger's door",
				result = { sanity = -3, setFlags = { "kl_stranger_night" }, log = "An old man let you in without a word and sat you on his kitchen chair till dawn. At six he opened the door and nodded at the street." },
			},
			{
				label = "Find the nearest watch lamp",
				result = { mind = 1, log = "The watch on that side walked you to the bridge with their lamps and handed you to the watch on yours, like a parcel." },
			},
		},
	},

	-- ── the roof and the trains ────────────────────────────────────────────
	{
		id = "kl_roof_count",
		title = "Counting Trains",
		art = "rooftop",
		text = "You and Mina from the third floor are on the roof counting WARP trains. One every seven minutes, a line of light that's there and then isn't.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		dialogue = {
			{ who = "Mina", line = "My cousin says if you look right at one, you see faces in the windows." },
			{ who = "Mina", line = "Old faces. Even the kids are old." },
		},
		choices = {
			{
				label = "Count them till one o'clock",
				result = { intelligence = 1, setFlags = { "kl_train_counter" }, log = "Forty-one. You chalked it on the water tank. A week later someone had written 43 under it, and the week after that, 46." },
			},
			{
				label = "Look for the faces",
				result = { mind = 1, sanity = -4, setFlags = { "kl_saw_faces" }, log = "On the twelfth train you saw one at a window, looking straight back at you. Then the light was gone. You stayed off the roof for a while." },
			},
			{
				label = "Climb the water tank",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A ladder with missing rungs", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 2, sanity = 1, log = "From the top of the tank the rail ran straight across the City like a ruler. You stayed until your hands went numb." },
				lose = { health = { -3, -2 }, sanity = -3, log = "The fourth rung was missing and so was the fifth. You came down faster than you went up. Mina laughed until she cried." },
			},
		},
	},
	{
		id = "kl_ticket_stub",
		title = "First Class",
		art = "rooftop",
		text = "A WARP ticket stub blows onto your roof and sticks in a puddle. First Class, District 23 to District 4. It cost more than your building.",
		weight = 8,
		once = true,
		when = { side = "backstreets", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Keep it",
				result = { sanity = 2, setFlags = { "kl_ticket_stub" }, log = "You dried it on the sill and kept it in a shoebox. FIRST CLASS, in silver. You read it most nights, like a letter." },
			},
			{
				label = "Sell it to the stamp man",
				result = { money = 8, log = "The stamp collector on Fifth paid eight Ahn and put it in a book with a hundred others, all First Class. He wouldn't say why." },
			},
			{
				label = "Take it to the platform",
				result = {
					sanity = -2,
					setFlags = { "kl_ticket_stub" },
					codex = "districts_w_corp",
					log = "The platform guard laughed so hard he had to sit down. He gave it back, though.",
					dialogue = { { who = "The Platform Guard", line = "Keep it, kid. Closest you'll get." } },
				},
			},
		},
	},
	{
		id = "kl_roof_super",
		title = "The Super's Flashlight",
		art = "rooftop",
		text = "The super catches you on the roof with his flashlight. The door's been padlocked since spring, so you came up through the laundry vent.",
		weight = 8,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		dialogue = {
			{ who = "The Super", line = "Roof's closed. Insurance. What are you doing up here at midnight?" },
		},
		choices = {
			{
				label = "Say you're checking the pigeons",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A super who has heard it all", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					setFlags = { "kl_roof_key" },
					log = "He looked at the empty pigeon loft for a long time. Then he gave you the padlock key.",
					dialogue = { { who = "The Super", line = "Pigeons. Lock it after. Don't fall off." } },
				},
				lose = { sanity = -3, log = "\"The pigeons left in spring,\" he said. He walked you down to your door and knocked on it." },
			},
			{
				label = "Tell him about the trains",
				result = {
					intelligence = 1,
					sanity = 2,
					log = "He switched off the flashlight and watched three trains go over with you.",
					dialogue = { { who = "The Super", line = "Twenty years I've had this roof. Never once looked up." } },
				},
			},
			{
				label = "Run past him",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A super with long arms", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { speed = 1, log = "You were down the stairs before he turned round. The padlock got a second padlock. You found a second vent." },
				lose = { health = -2, sanity = -3, log = "He caught your collar on the third step and carried you down to your door like a sack of laundry." },
			},
		},
	},

	-- ── taking things ──────────────────────────────────────────────────────
	{
		id = "kl_peach_stall",
		title = "Nest Peaches",
		art = "market",
		text = "The fruit stall has Nest peaches today, four Ahn each, every one wrapped in tissue paper. The stallholder is arguing about weights with his back to you.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Take one",
				hint = "Strength check. Quick hands.",
				clash = { stat = "strength", foe = "A stallholder with eyes in his back", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 1, sanity = 3, setFlags = { "kl_stole_peach" }, log = "You were round the corner before he finished his sentence. Best peach of your life. You ate some of the tissue paper by accident." },
				lose = { intelligence = 1, sanity = -3, setFlags = { "kl_stole_peach" }, log = "He had your sleeve before you'd moved. You unloaded his crates all Saturday to pay it off. At the end he gave you the peach anyway." },
			},
			{
				label = "Buy one",
				requires = { min = { money = 4 } },
				result = {
					money = -4,
					sanity = 3,
					log = "You peeled the tissue off like a present.",
					dialogue = { { who = "The Stallholder", line = "Good, right? They grow them in a building. No rain ever touches them." } },
				},
			},
			{
				label = "Ask what makes them Nest peaches",
				result = { mind = 1, log = "\"The price,\" he said, and went back to arguing." },
			},
		},
	},
	{
		id = "kl_clinic_cabinet",
		title = "The Unlocked Cabinet",
		art = "clinic",
		text = "{mother} has had a fever for four days. The clinic's medicine cabinet is unlocked, and the old woman at the desk is asleep with her mouth open.",
		weight = 10,
		once = true,
		when = { side = "backstreets", hasRelation = "mother", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Take the fever bottle",
				hint = "Mental Strength check. Quiet feet.",
				clash = { stat = "mind", foe = "A creaky floorboard", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 1, sanity = 2, relationBond = { kind = "mother", amount = 6 }, setFlags = { "kl_took_medicine" }, log = "You were out with the bottle before her next snore. {mother}'s fever broke by Friday. You never said where it came from." },
				lose = {
					sanity = -3,
					log = "The board went off like a shot. The old woman woke, looked at you, then at the bottle, and sighed.",
					dialogue = { { who = "The Clinic Keeper", line = "Put it back. Bring her in tomorrow. I'll put it on account." } },
				},
			},
			{
				label = "Wake her and ask",
				result = {
					intelligence = 1,
					relationBond = { kind = "mother", amount = 4 },
					log = "You swept the clinic every day for a week. She gave you the bottle on the first day, before you'd swept anything.",
					dialogue = { { who = "The Clinic Keeper", line = "Twenty Ahn, or a week of sweeping. Sweeping it is." } },
				},
			},
			{
				label = "Sit with {mother} instead",
				result = { sanity = -2, relationBond = { kind = "mother", amount = 8 }, log = "You changed the cold cloth every hour. On the fifth day the fever broke on its own. She said you did it. You knew you hadn't." },
			},
		},
	},
	{
		id = "kl_wallet_gutter",
		title = "A Wallet From the Nest",
		art = "street",
		text = "There's a wallet in the gutter: real leather, forty Ahn, and a Wing ID card with a tired woman's photo. FEATHER, CLASS 2, it says, over the name Margit Sorel.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Hand it in at the checkpoint",
				result = { mind = 1, money = 5, setFlags = { "knows_wings" }, log = "The guard counted the money in front of you, forty, and gave you five of it like a tip. He kept the rest. You watched him do it." },
			},
			{
				label = "Keep the money, bin the wallet",
				result = { money = 40, sanity = -2, setFlags = { "knows_wings", "kl_kept_wallet" }, log = "Forty Ahn. You hid it in four places. You thought about the woman in the photo for a week, then less." },
			},
			{
				label = "Hand it in, but keep the card",
				result = {
					sanity = 1,
					setFlags = { "knows_wings", "kl_feather_card" },
					schedule = { event = "kl_card_asked", inYears = 6 },
					log = "The checkpoint took the wallet. The card went in your shoebox. You looked up what Class 2 meant, and it wasn't much.",
				},
			},
		},
	},
	{
		id = "kl_sticker_stall",
		title = "Genuine Luck",
		art = "market",
		text = "A market stall sells Wing luck stickers, seventy Ahn each, under glass. The laundry kids are daring you to get one out of the case.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 9, maxAge = 12 },
		dialogue = {
			{ who = "The Stallholder", line = "Genuine Singularity. Stick one on, your luck goes up. The Wing guarantees it." },
			{ who = "The Stallholder", line = "I just own the glass." },
		},
		choices = {
			{
				label = "Slip one out of the case",
				hint = "Intelligence check. Quiet fingers.",
				clash = { stat = "intelligence", foe = "A glass lid that squeaks", coins = 1, base = 3, coinPower = 2, fixed = true },
				win = { intelligence = 1, sanity = 2, gear = "lucky_sticker", setFlags = { "knows_wings", "kl_stole_sticker" }, log = "The lid didn't squeak. You stuck it inside your shoe where nobody would see. Your luck went up. You decided it had." },
				lose = { sanity = -4, setFlags = { "knows_wings" }, log = "The lid squeaked. He laid his hand flat on the glass over yours and said nothing until the laundry kids had all run off." },
			},
			{
				label = "Buy a fake one for two Ahn",
				requires = { min = { money = 2 } },
				result = { money = -2, sanity = 2, setFlags = { "knows_wings" }, log = "Two stalls down, a man sold you a sticker that was clearly a jam-jar label. You wore it anyway. Nobody could prove it didn't work." },
			},
			{
				label = "Walk away",
				result = { mind = 1, setFlags = { "knows_wings" }, log = "The laundry kids called you scared. One of them tried it that afternoon. You heard about it from his mother, at length." },
			},
		},
	},

	-- ── the people who take the envelopes ──────────────────────────────────
	{
		id = "kl_loose_brick",
		title = "The Loose Brick",
		art = "street",
		text = "Every Friday the shopkeepers on your street slide an envelope under the same loose brick by the drainpipe. By morning the brick is back and the envelopes are gone.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 10 },
		codex = "bs_lore_alley_grades",
		choices = {
			{
				label = "Stay up and watch",
				hint = "Mental Strength check. Stay awake.",
				clash = { stat = "mind", foe = "Sleep", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, setFlags = { "knows_syndicates", "kl_saw_collector" }, log = "At one o'clock a woman in a long coat lifted the brick and set it back exactly. Then she looked up at your window." },
				lose = { sanity = -3, setFlags = { "knows_syndicates" }, log = "You fell asleep at midnight. In the morning there was a sweet on your windowsill, still in its wrapper." },
			},
			{
				label = "Lift the brick first",
				result = { sanity = -3, setFlags = { "knows_syndicates", "kl_lifted_brick" }, log = "Eleven envelopes, each with a little hook drawn on the corner. You put the brick back fast and didn't sleep." },
			},
			{
				label = "Ask the grocer what it's for",
				result = {
					mind = 1,
					setFlags = { "knows_syndicates" },
					log = "\"Protection,\" he said. You asked from who. He thought about it.",
					dialogue = { { who = "The Grocer", line = "From the people who take the envelopes." } },
				},
			},
		},
	},
	{
		id = "kl_wicks_offer",
		title = "The Back Room",
		art = "syndicate",
		text = "The laundry has a back room with a red lamp, and the woman who runs it has asked for you by name. Kids who go in come out with coins.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 10, maxAge = 12 },
		dialogue = {
			{ who = "kl_velka", line = "You're quick, I hear. Quiet too. Quick and quiet is worth money." },
			{ who = "kl_velka", line = "Envelopes, here to there. You don't open them. The Wicks pay on time." },
			{ who = "kl_velka", line = "Ask anyone. The Wicks always pay on time." },
		},
		choices = {
			{
				label = "Take the job",
				result = {
					money = 15,
					sanity = -1,
					setFlags = { "knows_syndicates", "kl_wicks_runner" },
					schedule = { { event = "kl_wicks_envelope", inYears = 1 }, { event = "kl_wicks_door", inYears = 4 } },
					log = "You ran Aunt Velka's envelopes every Saturday, always paid on time. You never opened one. You thought about it every time.",
				},
			},
			{
				label = "Ask what's in the envelopes",
				result = {
					mind = 1,
					setFlags = { "knows_syndicates" },
					log = "She didn't offer the job again. She did nod to you in the street after that, and the other kids noticed.",
					dialogue = { { who = "kl_velka", line = "Paper. Some of it's money. Some of it's names." } },
				},
			},
			{
				label = "Say your family won't let you",
				result = {
					sanity = 1,
					setFlags = { "knows_syndicates", "kl_wicks_refused" },
					log = "She gave you a sweet anyway. You didn't eat it.",
					dialogue = { { who = "kl_velka", line = "Families. I have one of those. A big one." } },
				},
			},
		},
	},
	{
		id = "kl_wicks_envelope",
		title = "A Heavy Envelope",
		art = "alley",
		text = "This week's envelope is thick, and two boys from the canal blocks have been walking behind you since the laundry. They're older. They know what you carry.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_wicks_runner" }, minAge = 11, maxAge = 13 },
		choices = {
			{
				label = "Turn round and fight",
				hint = "A fight. There are two of them.",
				clash = { stat = "strength", foe = "Two canal boys", coins = 1, base = 3, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = { strength = 2, money = 10, log = "You went first, which they weren't ready for, and they ran. Aunt Velka heard about it before you got there and paid you double." },
				lose = {
					health = { -5, -3 },
					sanity = -4,
					setFlags = { "kl_wicks_lost" },
					log = "They took the envelope. Aunt Velka listened to all of it and patted your cheek.",
					dialogue = { { who = "kl_velka", line = "That's a debt now, little one. Not yours. Theirs." } },
				},
			},
			{
				label = "Lose them in the market",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "Two boys who know the market", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 1, money = 5, log = "In one side of the fish market and out the back of the noodle row. They were still looking at the fish." },
				lose = { sanity = -4, setFlags = { "kl_wicks_lost" }, log = "They caught you behind the noodle row and took it. Aunt Velka didn't shout. That was worse." },
			},
			{
				label = "Hand it over",
				result = { sanity = -3, setFlags = { "kl_wicks_lost" }, log = "They took it without a word. Aunt Velka crossed your name off the Saturday list and wrote theirs on another list." },
			},
		},
	},
	{
		id = "kl_under_counter",
		title = "Under the Counter",
		art = "street",
		text = "You're buying rice at Mr. Pak's when two men in long coats come in and flip the sign to CLOSED. Mr. Pak pushes you down behind the counter with his foot.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		dialogue = {
			{ who = "A Man in a Coat", line = "Pak. The rate went up. You heard?" },
			{ who = "kl_pak", line = "I heard. I'm paying. I'm always paying. Look at me, paying." },
		},
		choices = {
			{
				label = "Hold perfectly still",
				hint = "Mental Strength check. There's rice dust.",
				clash = { stat = "mind", foe = "A sneeze", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, setFlags = { "knows_syndicates" }, log = "Eleven minutes with your nose full of rice dust. When they'd gone, Mr. Pak gave you the rice for free and asked you to forget it." },
				lose = {
					sanity = -4,
					setFlags = { "knows_syndicates" },
					log = "You sneezed. One of them crouched and looked at you under the counter for a long moment. Then they left.",
					dialogue = { { who = "A Man in a Coat", line = "Bless you." } },
				},
			},
			{
				label = "Peek at their coats",
				result = { sanity = -3, setFlags = { "knows_syndicates", "kl_saw_hooks" }, log = "Both coats had a little hook stitched inside the collar. One of them saw your eye in the gap and smiled. You stayed down after that." },
			},
		},
	},

	-- ── the Fixer across the street ────────────────────────────────────────
	{
		id = "kl_fixer_window",
		title = "Across the Street",
		art = "street",
		text = "From your window you watch a woman in a gray coat wait in the rain for two hours. She goes into the pawnshop and three men run out. Then she walks out slowly and looks up at your window.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Duck",
				result = { sanity = -2, setFlags = { "knows_fixers" }, log = "You counted to a hundred under the sill. She was gone. At dinner you described the coat, and everybody said \"Fixer\" at once." },
			},
			{
				label = "Wave",
				result = { sanity = 1, setFlags = { "knows_fixers", "kl_dalia_seen" }, schedule = { event = "kl_dalia_diner", inYears = 1 }, log = "She looked at you for a second, then lifted two fingers off her sleeve, which might have been a wave, and went round the corner." },
			},
			{
				label = "Write down everything",
				result = { intelligence = 1, setFlags = { "knows_fixers", "kl_dalia_seen" }, schedule = { event = "kl_dalia_diner", inYears = 1 }, codex = "fx_lore_reports", log = "The coat, the two hours, the men. Later you learned it was called a job report, and that you'd done it wrong." },
			},
		},
	},
	{
		id = "kl_dalia_diner",
		title = "The Woman in the Gray Coat",
		art = "diner",
		text = "The woman in the gray coat is at the diner counter, eating dumplings left-handed with her right hand in her pocket. She sees you and pats the stool next to her.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_dalia_seen" }, minAge = 9, maxAge = 13 },
		dialogue = {
			{ who = "kl_dalia", line = "You're the window. Second floor, yellow curtain." },
			{ who = "kl_dalia", line = "Dalia, Thimble Office. Grade Seven, which beats Eight. I've got ten minutes." },
		},
		choices = {
			{
				label = "Ask about the pawnshop",
				result = {
					mind = 1,
					setFlags = { "knows_fixers" },
					log = "She paid for your dumplings. The receipt said THIMBLE OFFICE: CLIENT ENTERTAINMENT.",
					dialogue = { { who = "kl_dalia", line = "A client wanted something back. I got it back. The rest is paperwork." } },
				},
			},
			{
				label = "Ask how to become a Fixer",
				result = {
					strength = 1,
					setFlags = { "knows_fixers", "kl_dalia_card" },
					schedule = { event = "kl_dalia_call", inYears = 5 },
					codex = "fixers_hana",
					log = "She wrote a number on a napkin, then thought better of it and gave you a proper card.",
					dialogue = {
						{ who = "kl_dalia", line = "Pass Hana's tests, find an Office, file your reports on time. Most people die of the reports." },
						{ who = "kl_dalia", line = "Call if you need a Fixer. Not if you want to be one." },
					},
				},
			},
			{
				label = "Ask about her right hand",
				result = {
					sanity = -2,
					setFlags = { "knows_fixers" },
					codex = "fx_lore_workshops",
					log = "She took it out of her pocket. Workshop steel, brass at the knuckles, very clean.",
					dialogue = { { who = "kl_dalia", line = "Cheaper than the old one. And it doesn't get cold." } },
				},
			},
		},
	},
	{
		id = "kl_fixer_cards",
		title = "Color Cards",
		art = "street",
		text = "This summer every kid on the street draws Fixer cards, a famous Fixer on the front and made-up numbers on the back. Brannigan's Red Mist is worth six of anyone else's.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 10 },
		codex = "fx_lore_colors",
		dialogue = {
			{ who = "Brannigan", line = "She's real. My uncle saw her. All red, and the fight was over before it started." },
			{ who = "Brannigan", line = "Grade? She doesn't have a grade. She's a Color. That's above grades." },
		},
		choices = {
			{
				label = "Trade six cards for the Red Mist",
				result = { sanity = 2, setFlags = { "knows_fixers", "kl_red_mist_card" }, log = "Brannigan's Red Mist was mostly red crayon. You kept her in your shirt pocket all summer, and she came out of the wash pink." },
			},
			{
				label = "Draw a better one",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Brannigan's red crayon", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, setFlags = { "knows_fixers" }, log = "Yours had the coat and the sword and the right amount of red. Brannigan offered nine cards for it. You said no." },
				lose = { sanity = -3, setFlags = { "knows_fixers" }, log = "Your Red Mist looked like a tomato holding a stick. Brannigan laughed so hard he dropped his whole stack." },
			},
			{
				label = "Say Colors are made up",
				result = {
					mind = 1,
					setFlags = { "knows_fixers" },
					log = "You didn't know. Nobody on the street knew, and you all argued about it until dark.",
					dialogue = { { who = "Brannigan", line = "Then who's the Black Silence? Go on. Who?" } },
				},
			},
		},
	},
	{
		id = "kl_puppet_show",
		title = "The Puppet Show",
		art = "market",
		text = "A puppeteer in the market is doing The Fixer Who Walked Home at 3:13. The Fixer has a tin sword. The Sweeper is a sock with a lamp inside it.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 9 },
		choices = {
			{
				label = "Watch to the end",
				result = { sanity = 3, setFlags = { "knows_fixers" }, log = "The Fixer walked home through all three waves and knocked on her own door at dawn. A grown-up behind you said \"That's not how it goes\" and left." },
			},
			{
				label = "Ask the puppeteer if it's true",
				result = {
					mind = 1,
					setFlags = { "knows_fixers", "knows_night" },
					log = "He packed the Sweeper sock away very carefully, like it might mind.",
					dialogue = {
						{ who = "The Puppeteer", line = "Somebody did it once. I've been telling it for thirty years." },
						{ who = "The Puppeteer", line = "Nobody's done it since. That's why it's a show." },
					},
				},
			},
			{
				label = "Put a coin in the hat",
				requires = { min = { money = 1 } },
				result = { money = -1, sanity = 2, setFlags = { "knows_fixers" }, log = "He made the Fixer bow to you. Just you. For a whole day you felt like a client." },
			},
		},
	},

	-- ── the Wing, from down here ───────────────────────────────────────────
	{
		id = "kl_noodle_screen",
		title = "The Parade on the Screen",
		art = "diner",
		text = "The noodle shop's screen is showing the Wing's parade inside the Nest, rows of Feathers in white on a street that shines. The cook turns the sound off.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 11 },
		codex = "bs_lore_feathers",
		dialogue = {
			{ who = "The Cook", line = "Every year they march, and every year it's on my screen. I didn't buy a screen for marching." },
		},
		choices = {
			{
				label = "Ask him to turn the sound on",
				result = {
					sanity = 1,
					setFlags = { "knows_wings" },
					log = "You watched the whole parade in silence. Without the music it looked like a lot of people walking very carefully.",
					dialogue = { { who = "The Cook", line = "No." } },
				},
			},
			{
				label = "Count the Feathers",
				result = { intelligence = 1, setFlags = { "knows_wings" }, log = "Three hundred and twelve. You decided you'd be number three hundred and thirteen. Then you thought about that number, and changed your mind." },
			},
			{
				label = "Ask why he hates it",
				result = {
					mind = 1,
					setFlags = { "knows_wings" },
					log = "He put a free egg in your noodles and didn't explain it.",
					dialogue = {
						{ who = "The Cook", line = "My brother passed their exam. Class 1. Nine years I haven't seen him." },
						{ who = "The Cook", line = "He sends a card every year. Very nice card." },
					},
				},
			},
		},
	},
	{
		id = "kl_exam_van",
		title = "The Recruiting Van",
		art = "street",
		text = "A white van with the Wing's logo is parked by the academy, giving out pencils and leaflets: FEATHER ENTRANCE EXAM, PREPARATION BEGINS AT TWELVE.",
		weight = 10,
		once = true,
		when = { side = "backstreets", flags = { "knows_wings" }, minAge = 10, maxAge = 12 },
		dialogue = {
			{ who = "The Recruiter", line = "Every child in the District may sit the exam. Every child. It says so on the leaflet." },
		},
		choices = {
			{
				label = "Take a leaflet and a pencil",
				result = { intelligence = 1, setFlags = { "kl_exam_leaflet" }, schedule = { event = "kl_exam_hall", inYears = 4 }, log = "You kept the leaflet flat under your mattress and read the sample questions at night. Some of them you could answer." },
			},
			{
				label = "Ask if anyone here ever passed",
				result = {
					mind = 1,
					sanity = -1,
					log = "She checked a list for a long time, then gave you three pencils instead of one.",
					dialogue = { { who = "The Recruiter", line = "Of course. I'm sure. I'd have to check." } },
				},
			},
			{
				label = "Take ten pencils and sell them",
				result = { strength = 1, money = 8, log = "You sold eight at the academy door for an Ahn each and kept two. The leaflet wrapped a bun." },
			},
		},
	},
	{
		id = "kl_cut_feather",
		title = "The Badge on the Sweater",
		art = "street",
		text = "Mr. Fenwick on the fifth floor used to be a Feather. He still wears the badge on his sweater, and the older kids salute him when he goes past.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 9, maxAge = 12 },
		dialogue = {
			{ who = "Mr. Fenwick", line = "Class 3. Eleven years inside the wall. Then my Class got cut." },
			{ who = "Mr. Fenwick", line = "The whole Class. Everyone in it, one letter, same morning." },
		},
		choices = {
			{
				label = "Salute him properly",
				result = { strength = 1, sanity = -1, setFlags = { "knows_wings" }, log = "You saluted, straight and serious. He saluted back perfectly, then went up the stairs very slowly." },
			},
			{
				label = "Ask what it was like inside",
				result = {
					mind = 1,
					setFlags = { "knows_wings" },
					codex = "wg_lore_feathers",
					log = "He talked for an hour. Most of it was about the lifts.",
					dialogue = { { who = "Mr. Fenwick", line = "Quiet. You could hear the drones. I never once thought about three o'clock." } },
				},
			},
			{
				label = "Tell the older kids to stop",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "Four bigger kids", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 2, setFlags = { "knows_wings" }, log = "They stopped, mostly because it was funny. Mr. Fenwick gave you an old Nest coin with the Wing's face on it." },
				lose = { sanity = -3, setFlags = { "knows_wings" }, log = "They saluted you too, after that. Mr. Fenwick said it was kind of you. He took the badge off a week later." },
			},
		},
	},

	-- ── the Night, for a kid who knows the rules ───────────────────────────
	{
		id = "kl_night_petra",
		title = "Petra Came Home at Dawn",
		art = "street",
		text = "Petra from the fifth floor was out past three last night. She came home at dawn with her shoes in her hand, and the whole building is talking in low voices.",
		weight = 14,
		once = true,
		when = { side = "backstreets", notFlags = { "knows_night" }, minAge = 7, maxAge = 9 },
		choices = {
			{
				label = "Ask her what she heard",
				result = {
					mind = 1,
					sanity = -3,
					setFlags = { "knows_night" },
					log = "She didn't say anything else, then or ever. At dinner your family went over the rules again, slowly, like you were new.",
					dialogue = { { who = "Petra", line = "Walking. Lots of walking. Then nothing. Then walking again." } },
				},
			},
			{
				label = "Ask what happens at three",
				result = { mind = 2, setFlags = { "knows_night" }, codex = "bs_lore_night_rules", log = "At 3:13 the Sweepers come, they said, and whoever's outside gets cleaned off the street. Petra was lucky. Nobody's lucky twice." },
			},
			{
				label = "Give her your sweet",
				result = { sanity = 2, setFlags = { "knows_night" }, log = "She held it without eating it. That night you checked the locks yourself, all of them, twice." },
			},
		},
	},
	{
		id = "kl_shutter_gap",
		title = "The Gap in the Shutter",
		art = "night",
		text = "The shutter in your room has a gap exactly one finger wide. It's 3:12, everyone else is asleep, and the floor has started to hum.",
		weight = 12,
		once = true,
		when = { side = "backstreets", flags = { "knows_night" }, minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Listen, but don't look",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Your own curiosity", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, setFlags = { "kl_counts_waves" }, log = "Eyes shut, you counted. Three waves, ten quiet minutes between each. By morning you knew exactly what the Night sounded like." },
				lose = { sanity = -4, setFlags = { "kl_looked" }, log = "You lasted until the second wave. Then you looked. You don't remember the rest, and you never asked anyone what you'd seen." },
			},
			{
				label = "Look",
				result = { mind = 1, sanity = -5, setFlags = { "kl_looked" }, log = "The street, red under the lamp, and tall shapes walking it slowly in a line. Behind them the street was clean. You taped the gap in the morning." },
			},
			{
				label = "Stuff a sock in the gap",
				result = { mind = 1, sanity = 1, log = "You pulled the blanket over your head. Around the third wave you fell asleep with your hand still on the sock." },
			},
		},
	},
	{
		id = "kl_one_shoe",
		title = "One Shoe",
		art = "street",
		text = "The morning after the Night there's one shoe in the middle of the street, cleaner than anything else on it. The kids stand around it in a circle. Nobody touches it.",
		weight = 10,
		once = true,
		when = { side = "backstreets", flags = { "knows_night" }, minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Pick it up",
				result = { strength = 1, sanity = -4, setFlags = { "kl_touched_shoe" }, log = "It was dry and still a little warm. You set it on the nearest step. By noon it was gone, and nobody in that building would talk about it." },
			},
			{
				label = "Kick it into the gutter",
				result = { strength = 1, sanity = -2, log = "The circle broke up fast. An old woman on a balcony shook her head at you every morning for a year." },
			},
			{
				label = "Fetch the grocer",
				result = { mind = 1, log = "The grocer looked at it and took his cap off. Then he carried it to the watch post in both hands, like it was heavy." },
			},
		},
	},
	{
		id = "kl_one_foot",
		title = "One Foot Out",
		art = "night",
		text = "The older kids' dare: at 3:12, open the front door, put one foot over the step, then pull it back and lock up before 3:13. Danek says he's done it. Danek says you won't.",
		weight = 10,
		once = true,
		when = { side = "backstreets", flags = { "knows_night" }, minAge = 10, maxAge = 12 },
		choices = {
			{
				label = "Do it",
				hint = "Strength check. One minute.",
				clash = { stat = "strength", foe = "The last minute before 3:13", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 2, sanity = -2, setFlags = { "kl_one_foot" }, log = "Foot out. The air was cold and very still. Foot in, three locks, 3:12 and fifty seconds. You lay awake till dawn, grinning at the ceiling." },
				lose = { sanity = -5, setFlags = { "kl_one_foot" }, log = "Your hand shook on the third lock. You got it shut as the floor started to hum. You didn't grin about it, and you didn't tell Danek." },
			},
			{
				label = "Refuse",
				result = { mind = 1, sanity = 1, log = "You told Danek no, and Danek told everybody. Everybody already knew Danek was lying." },
			},
			{
				label = "Say you did it",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Danek's questions", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, log = "You described the cold air and the stillness, which you'd made up. Danek went pale and nodded. You were both lying, and you both knew it." },
				lose = { sanity = -4, log = "Danek asked what it smelled like. You didn't know. Danek did, and he went very quiet." },
			},
		},
	},
	{
		id = "kl_slow_clock",
		title = "Four Minutes Slow",
		art = "home",
		text = "You've noticed the kitchen clock is four minutes slow. The whole family sets its night by it, and nobody else has noticed.",
		weight = 10,
		once = true,
		when = { side = "backstreets", flags = { "knows_night" }, minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Fix it yourself",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A stubborn little knob", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, sanity = 1, log = "You set it by the radio's time signal. That night everyone was home four minutes early, and nobody knew why they felt better." },
				lose = { sanity = -3, log = "You turned the wrong knob and the clock stopped dead. Nobody in the flat slept until it was going again." },
			},
			{
				label = "Tell everyone at dinner",
				result = { mind = 1, sanity = 1, log = "Everyone checked their watches against it and went quiet. That week someone bought a second clock." },
			},
			{
				label = "Go to bed four minutes early",
				result = { mind = 1, sanity = -1, setFlags = { "kl_secret_clock" }, log = "You never told anyone. You went to bed four minutes early every night for years, and checked the locks on the way." },
			},
		},
	},
	{
		id = "kl_flashlight",
		title = "Signals",
		art = "night",
		text = "3:40, between the first and second waves. In the window across the street that's always dark, somebody is flicking a flashlight: three short, three long, then nothing.",
		weight = 10,
		once = true,
		when = { side = "backstreets", flags = { "knows_night" }, minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Flash your lamp back",
				result = { sanity = -2, setFlags = { "kl_signals" }, schedule = { event = "kl_yeva_meets", inYears = 4 }, log = "Three flicks. After a long pause the flashlight answered, slower. After that you talked in light every Night, between the first and second waves." },
			},
			{
				label = "Write down the pattern",
				result = { intelligence = 1, setFlags = { "kl_signals" }, schedule = { event = "kl_yeva_meets", inYears = 4 }, log = "In an academy library book you found it: the first half of a call for help. The second half never came." },
			},
			{
				label = "Close the curtain",
				result = { mind = 1, sanity = 1, log = "You lay down with your back to the window. The light kept going until the second wave, then stopped." },
			},
		},
	},
	{
		id = "kl_fourth_wave",
		title = "The Fourth Wave",
		art = "night",
		text = "You've counted the waves every Night for a month: always three, ten minutes apart. Tonight, an hour after the third, the floor starts humming again.",
		weight = 8,
		once = true,
		when = { side = "backstreets", flags = { "knows_night" }, minAge = 10, maxAge = 12 },
		choices = {
			{
				label = "Count it",
				result = { mind = 2, sanity = -5, setFlags = { "kl_fourth_wave" }, log = "Four. You counted it twice. At breakfast you told everyone, and they said you'd dreamed it, very quickly, all at once." },
			},
			{
				label = "Wake someone",
				result = { sanity = -3, log = "By the time anyone woke, it had stopped. They said it was the pipes. The pipes had never hummed before, and they never did again." },
			},
			{
				label = "Pillow over your head",
				result = { sanity = -1, log = "You didn't count it. You never counted the waves again, and you slept better than you had all month." },
			},
		},
	},

	-- ── school, or the window of one ───────────────────────────────────────
	{
		id = "kl_window_student",
		title = "The Back Window",
		art = "school",
		text = "You don't go to the academy on the corner. It costs. But the classroom's back window opens onto the alley, and the teacher talks loud.",
		weight = 10,
		once = true,
		when = { side = "backstreets", notFlags = { "bs_academy_enrolled" }, minAge = 7, maxAge = 9 },
		choices = {
			{
				label = "Listen at the window every day",
				result = { intelligence = 2, setFlags = { "kl_window_student" }, log = "You learned your letters from the alley, one shout at a time. One day there was a chair by the window, on the inside. Nobody mentioned it." },
			},
			{
				label = "Climb in and sit at the back",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A teacher who counts heads", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 1, mind = 1, setFlags = { "kl_window_student" }, log = "When she counted heads she got one too many, looked at you, and counted again until it came out right." },
				lose = { sanity = -3, log = "She counted heads first thing and got one too many. She walked you out by the hand and gave you a pencil at the door." },
			},
			{
				label = "Work instead",
				result = { health = 1, money = 6, log = "You carried crates for the grocer while the academy kids did sums. Six Ahn, and you could count them just fine." },
			},
		},
	},
	{
		id = "kl_times_tables",
		title = "Twelve Twelves",
		art = "school",
		text = "The academy teacher keeps a jar of lemon sweets on her desk. Anyone who can say the times tables to twelve twelves without stopping gets one. Nobody has since spring.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 10 },
		choices = {
			{
				label = "Try now",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Eleven sevens", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, sanity = 2, log = "Twelve twelves, a hundred and forty-four. The room clapped. You saved half the sweet for the walk home." },
				lose = { intelligence = 1, sanity = -3, log = "You got stuck on eleven sevens like everyone. That night you said them to the ceiling until you fell asleep." },
			},
			{
				label = "Practice for a month first",
				result = {
					intelligence = 2,
					log = "A month of numbers at the ceiling. When you finally tried, you got the sweet.",
					dialogue = { { who = "The Teacher", line = "Took you long enough. Take two." } },
				},
			},
			{
				label = "Help the slowest kid practice",
				result = { intelligence = 1, sanity = 2, addRelation = { kind = "friend", name = "Minh Tran", bond = 55, age = { 8, 10 } }, log = "You drilled Minh every lunch. He got the sweet before you did, and gave you half." },
			},
		},
	},
	{
		id = "kl_copy_homework",
		title = "Copying",
		art = "school",
		text = "You forgot the sums homework, and the teacher collects it in five minutes. Your deskmate is holding hers out under the desk without looking at you.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Copy it fast",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Five minutes and bad handwriting", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 1, log = "Every sum in four minutes, including the same three wrong ones. The teacher noticed. She just moved your desks apart." },
				lose = { sanity = -3, log = "The teacher held both papers up to the window together. Every number matched, down to the tea ring." },
			},
			{
				label = "Tell the teacher you forgot",
				result = {
					strength = 1,
					log = "She gave you a zero and an extra page.",
					dialogue = { { who = "The Teacher", line = "Cheaper than lying. Remember the price." } },
				},
			},
			{
				label = "Say the Night took it",
				hint = "Mental Strength check.",
				requires = { flags = { "knows_night" } },
				clash = { stat = "mind", foe = "A teacher who lives on your street", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					sanity = 1,
					log = "You'd left it on the windowsill, you said, and the Night took it. She looked at you for a long time.",
					dialogue = { { who = "The Teacher", line = "That's the best one this year. Sit down." } },
				},
				lose = {
					sanity = -3,
					log = "She didn't even look up.",
					dialogue = { { who = "The Teacher", line = "The Sweepers don't take homework off windowsills. Sit down, and do it twice." } },
				},
			},
		},
	},
	{
		id = "kl_streetlight_study",
		title = "Studying by the Streetlight",
		art = "street",
		text = "The power's out on your block again and there's a test tomorrow. The only light is the streetlight outside, and it's 1:10.",
		weight = 10,
		once = true,
		when = { side = "backstreets", flags = { "knows_night" }, minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Study on the curb until two",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Tired eyes", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, log = "You read on the curb until two, then ran up with the book. The next day you knew every answer, and fell asleep on question three." },
				lose = { intelligence = 1, sanity = -3, log = "The words started swimming at half past one. In the morning you remembered the streetlight better than the book." },
			},
			{
				label = "Hold the book to the window",
				result = { intelligence = 1, mind = 1, log = "You caught the edge of the light, enough for two pages. Two pages was a pass, barely." },
			},
			{
				label = "Sleep and hope",
				result = { sanity = 2, log = "You slept. You passed by one mark, and never told anyone how." },
			},
		},
	},

	-- ── the street ─────────────────────────────────────────────────────────
	{
		id = "kl_walnut_man",
		title = "The Walnut Man",
		art = "market",
		text = "A man in the market has a Workshop hand, all steel joints, and he cracks walnuts for kids. One squeeze each. He's never charged anyone.",
		weight = 8,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Ask to hold the hand",
				result = {
					sanity = 2,
					log = "He unscrewed it and gave it to you. It was heavy and still warm from his arm.",
					dialogue = { { who = "The Walnut Man", line = "Don't wave it at anyone. People get ideas." } },
				},
			},
			{
				label = "Ask what it cost",
				result = {
					mind = 1,
					codex = "fx_lore_workshops",
					log = "He did the sum again on his fingers, the real ones.",
					dialogue = { { who = "The Walnut Man", line = "Eleven hundred Ahn, and the old hand. The old hand was free, so I'm ahead." } },
				},
			},
			{
				label = "Ask if it hurts",
				result = {
					sanity = -1,
					log = "He cracked you a second walnut while he thought about it.",
					dialogue = { { who = "The Walnut Man", line = "Only when it rains. The part that isn't there hurts. Go figure." } },
				},
			},
		},
	},
	{
		id = "kl_neon_o",
		title = "Sitting in the O",
		art = "street",
		text = "The sign over the dumpling house says SUNNY DUMPLINGS in buzzing yellow, and the older kids sit inside the big O at night. You can reach it from the fire escape. Almost.",
		weight = 8,
		once = true,
		when = { side = "backstreets", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Jump for the O",
				hint = "Speed check. A climb.",
				clash = { stat = "speed", foe = "The gap to the O", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { speed = 2, sanity = 2, setFlags = { "kl_sat_in_o" }, log = "You sat in the O with your legs hanging and the whole street gone yellow and small. You stayed until the sign switched off at one." },
				lose = { health = { -3, -2 }, sanity = -3, log = "You missed by a hand. The dumpling man caught the back of your shirt and set you down in the street like a sack of flour." },
			},
			{
				label = "Watch the older kids do it",
				result = { mind = 1, log = "One of them slipped and hung off the S by one hand, laughing. You went home and practiced jumping on the stairs." },
			},
			{
				label = "Ask the dumpling man for the key",
				result = { intelligence = 1, sanity = 2, log = "He gave you the roof key and a job: change the dead bulb in the second U. Afterward you sat on the roof above the sign, which was better." },
			},
		},
	},
	{
		id = "kl_copper_wire",
		title = "Copper Wire",
		art = "ruins",
		text = "A collapsed block by the canal still has copper wire in its walls, two Ahn a meter. You've pulled four meters when the canal kids turn up. Their rubble, they say.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Fight for the wire",
				clash = { stat = "strength", foe = "The canal kids", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = { strength = 2, money = 8, log = "You held on and they let go first. Eight Ahn at the scrap man's. The canal kids watched you cash it, taking notes." },
				lose = { health = { -4, -2 }, sanity = -3, log = "They took the wire and your gloves. The scrap man saw you come in empty-handed and gave you one Ahn for nothing, which was worse." },
			},
			{
				label = "Split it with them",
				result = { money = 4, sanity = 1, setFlags = { "kl_canal_kids" }, log = "Down the middle. Their leader, a girl called Ruth who never blinked, said you could come back." },
			},
			{
				label = "Leave it",
				result = { mind = 1, log = "You left. The next week the rest of the block came down, with the wire still in it." },
			},
		},
	},
	{
		id = "kl_roof_war",
		title = "Whose Roof",
		art = "rooftop",
		text = "The kids from Building 11 have laid a plank across the gap and taken your roof. They've put up a flag, which is a shirt on a broom.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Take the roof back",
				clash = { stat = "strength", foe = "Building 11's roof gang", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = { strength = 2, sanity = 2, log = "You pulled their shirt down and ran your own up, which was cleaner. Building 11 took their plank home. You kept the broom." },
				lose = { health = { -4, -2 }, sanity = -3, log = "They held the roof all summer. You had to ask permission to go up on your own building, which was the worst part." },
			},
			{
				label = "Offer to share it",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Building 11's pride", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, sanity = 2, log = "The plank stayed. By August there were two flags and one long game, and nobody remembered whose roof it had been." },
				lose = { sanity = -3, log = "They said sharing was what losers said. You went down the stairs while they cheered." },
			},
			{
				label = "Pull their plank in",
				result = { strength = 1, sanity = -1, log = "You pulled it in while they were at the far edge. They were stuck on your roof until their mothers came. Your building called you a hero." },
			},
		},
	},

	-- ════ follow-ups (weight 0, ages 13-18) ════════════════════════════════
	{
		id = "kl_pak_job",
		title = "Mr. Pak's Receipt",
		art = "street",
		text = "Mr. Pak still has the receipt with your name on the back, pinned above his till. He's getting old, and the shop needs someone who counts in front of him.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_pak_honest" }, minAge = 13, maxAge = 17 },
		dialogue = {
			{ who = "kl_pak", line = "Five Ahn you gave back. I wrote it down. I write everything down." },
			{ who = "kl_pak", line = "Mornings, six to noon. Twelve Ahn a week, and you count in front of me." },
		},
		choices = {
			{
				label = "Take the job",
				result = { intelligence = 2, money = 12, setFlags = { "kl_pak_staff" }, log = "You opened the shop at six every morning. Mr. Pak watched you count the till the first week. After that he watched the radio." },
			},
			{
				label = "Ask for fifteen",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Mr. Pak's ledger", coins = 1, base = 3, coinPower = 2 },
				win = {
					mind = 2,
					money = 15,
					setFlags = { "kl_pak_staff" },
					log = "He wrote fifteen in the ledger and underlined it twice.",
					dialogue = { { who = "kl_pak", line = "Good. Somebody honest should be expensive." } },
				},
				lose = { money = 12, sanity = -4, setFlags = { "kl_pak_staff" }, log = "\"Twelve,\" he said, \"and I'll forget you asked.\" He didn't forget. He mentioned it every payday." },
			},
			{
				label = "Say no thanks",
				result = { sanity = 1, log = "He nodded and took the receipt down from above the till. He put it in his wallet instead." },
			},
		},
	},
	{
		id = "kl_garza_son",
		title = "Mr. Garza's Son",
		art = "street",
		text = "Mr. Garza's son came home from the Pack this week. He sits on the step beside his father all day, very still, and doesn't look at anyone's face.",
		weight = 0,
		when = { side = "backstreets", minAge = 13, maxAge = 17 },
		dialogue = {
			{ who = "kl_garza", line = "This is the kid who read me your letters. Say hello." },
		},
		choices = {
			{
				label = "Sit with them",
				result = { mind = 1, sanity = 2, log = "You sat on the step until dark. Nobody said anything. When you got up, the son said thank you, to the street." },
			},
			{
				label = "Admit you lied about the letter",
				requires = { flags = { "kl_garza_lie" } },
				result = {
					strength = 1,
					sanity = 3,
					log = "Mr. Garza laughed for the first time in a week.",
					dialogue = { { who = "kl_garza", line = "I knew. I just liked hearing it." } },
				},
			},
			{
				label = "Ask the son about the Pack",
				result = { sanity = -4, setFlags = { "knows_wings" }, codex = "wg_lore_rcorp", log = "He thought about it for a long time and said \"loud.\" Then he went inside, and Mr. Garza followed him." },
			},
		},
	},
	{
		id = "kl_watch_back",
		title = "The Brass Watch",
		art = "market",
		text = "The pawnbroker is old now. The brass watch is still in his window, with a ticket on it in your handwriting: SOLD, NEARLY.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_watch_saving" }, minAge = 13, maxAge = 17 },
		dialogue = {
			{ who = "The Pawnbroker", line = "Sixty. I knocked off thirty for the sweeping. Don't tell anyone I can count backward." },
		},
		choices = {
			{
				label = "Pay the sixty",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 6, setFlags = { "kl_watch_home" }, log = "You took the watch home and wound it. It ran four minutes slow, like it always had. Nobody fixed that." },
			},
			{
				label = "Pay what you have",
				requires = { min = { money = 20 } },
				result = { money = -20, sanity = 3, setFlags = { "kl_watch_home" }, log = "He took twenty and pushed the watch across the counter. \"Sweep on Sunday,\" he said. You did, for another year." },
			},
			{
				label = "Leave it in the window",
				result = { sanity = -2, log = "You left it there. When the pawnshop finally closed, the watch went with everything else, to someone you'll never meet." },
			},
		},
	},
	{
		id = "kl_juno_rides",
		title = "Ten Seconds",
		art = "train",
		text = "Juno saved five years for a WARP ticket there and back. You wait at the platform, and the return train pulls in twenty seconds after she left.",
		weight = 0,
		when = { flags = { "kl_juno_dream" }, minAge = 14, maxAge = 19 },
		dialogue = {
			{ who = "kl_juno", line = "{first}! It's quick. It's so quick. The lights dipped and I was there." },
			{ who = "kl_juno", line = "Why are you looking at me like that? I've been gone twenty seconds." },
		},
		choices = {
			{
				label = "Walk her home",
				result = { sanity = 1, relationBond = { kind = "friend", amount = 6 }, log = "Juno talked the whole way about the far platform, which looks exactly like this one. Five years of saving for twenty seconds, and she'd do it again." },
			},
			{
				label = "Ask what it was like",
				result = {
					mind = 1,
					sanity = -1,
					log = "Juno frowned at the question, then shrugged it off and showed you the stub.",
					dialogue = { { who = "kl_juno", line = "Like nothing. I had the oddest feeling getting off, though. Like I'd been about to say something." } },
				},
			},
			{
				label = "Ask about First Class",
				requires = { flags = { "kl_juno_ticket" } },
				result = {
					mind = 1,
					sanity = 1,
					log = "She kept the stub in her shoe for years.",
					dialogue = { { who = "kl_juno", line = "Do I look like First Class? They get a pod and biscuits. I got a seat and a strap. Same ten seconds." } },
				},
			},
		},
	},
	{
		id = "kl_teodor_grown",
		title = "The Toll Went Up",
		art = "street",
		text = "Teodor is grown now, in a Rat's jacket two sizes too big, back on the bakery corner with three friends. He sees you before you see him.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_teodor_known" }, minAge = 13, maxAge = 18 },
		dialogue = {
			{ who = "kl_teodor", line = "Look who it is. The toll went up." },
			{ who = "kl_teodor", line = "Ten Ahn. Inflation. My uncle explained it." },
		},
		choices = {
			{
				label = "Pay ten",
				requires = { min = { money = 10 } },
				result = { money = -10, sanity = -3, setFlags = { "knows_syndicates" }, log = "You paid. He didn't bite this one. Rats don't bite coins, he said. Only kids do." },
			},
			{
				label = "Fight him",
				hint = "A fight. He brought friends.",
				clash = { stat = "strength", foe = "Teodor and his pack", coins = 2, base = 3, coinPower = 2, fight = true, enemy = "rat" },
				win = { strength = 3, money = { 10, 30 }, setFlags = { "knows_syndicates", "kl_teodor_done" }, log = "Back into the flour sacks, like old times. His friends laughed until he took the jacket off and walked home in his shirt." },
				lose = { health = { -8, -4 }, sanity = -5, setFlags = { "knows_syndicates" }, cause = "Beaten on the bakery corner", log = "His friends held your arms while he took the ten, and the rest. \"Inflation,\" he said again, walking off." },
			},
			{
				label = "Ask him about the jacket",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Teodor's pride", coins = 1, base = 3, coinPower = 2 },
				win = {
					mind = 2,
					sanity = 2,
					setFlags = { "knows_syndicates" },
					log = "He looked at the jacket like he'd never seen it, and let you pass for free.",
					dialogue = { { who = "kl_teodor", line = "It's my uncle's. He's not using it anymore." } },
				},
				lose = { sanity = -4, setFlags = { "knows_syndicates" }, log = "\"It fits fine,\" he said, and his friends laughed until he made them stop. The toll went to twenty, just for you." },
			},
		},
	},
	{
		id = "kl_sibling_repays",
		title = "Good Boots",
		art = "home",
		text = "{sibling} turns up at your door with a paper bag. Inside is a pair of good boots with a Workshop stitch on the heel.",
		weight = 0,
		when = { hasRelation = "sibling", flags = { "kl_sibling_defended" }, minAge = 13, maxAge = 19 },
		dialogue = {
			{ who = "{sibling}", line = "Your size. I asked around. Don't ask what they cost, I'll only lie." },
		},
		choices = {
			{
				label = "Put them on",
				result = { health = 2, sanity = 4, relationBond = { kind = "sibling", amount = 8 }, log = "They fit. You wore them until the soles went through, and then you had them resoled, twice." },
			},
			{
				label = "Ask what they cost anyway",
				result = {
					mind = 1,
					sanity = 2,
					relationBond = { kind = "sibling", amount = 6 },
					log = "{sibling} grinned. You wore them every day after that.",
					dialogue = { { who = "{sibling}", line = "Fish market prices. Same kid, actually. He works there now." } },
				},
			},
		},
	},
	{
		id = "kl_dog_door",
		title = "Scratching",
		art = "night",
		text = "3:09. Somebody left the street door open and Tuesday got out, and now he's back. You can hear him scratching at it, four floors down.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_dog", "knows_night" }, minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Run down and let him in",
				hint = "Speed check. Four floors, four minutes.",
				clash = { stat = "speed", foe = "Four floors and four minutes", coins = 1, base = 3, coinPower = 2, fixed = true },
				win = { speed = 2, sanity = 1, log = "Down four floors in the dark, door open, dog in, door shut, back up. 3:12. Tuesday licked your ear like he'd done you a favor." },
				lose = { sanity = -5, log = "You froze on the second landing. At 3:13 the scratching stopped. In the morning Tuesday was asleep on the step, fine, smelling of nothing." },
			},
			{
				label = "Stay in bed",
				result = { sanity = -4, log = "The scratching stopped at 3:13. In the morning he was on the step, wagging, like nothing had happened. You never found out where he went." },
			},
			{
				label = "Wake a grown-up",
				result = { mind = 1, sanity = -2, log = "Nobody would go down. Somebody held you by the shoulders until it was over. Tuesday was on the step at dawn, wagging." },
			},
		},
	},
	{
		id = "kl_dog_old",
		title = "Old Tuesday",
		art = "home",
		text = "Tuesday is old now, gray all over and deaf on the side with no ear. Every night at half past two he lies across the door until everyone is home.",
		weight = 0,
		when = { flags = { "kl_dog" }, minAge = 14, maxAge = 18 },
		choices = {
			{
				label = "Sit up with him",
				result = { sanity = 4, log = "You sat on the floor with his head on your foot and counted everyone in for him. When the last lock turned, he sighed and slept." },
			},
			{
				label = "Carry him up to the roof",
				result = { health = 1, sanity = 3, log = "He didn't bark at the trains anymore. He watched them go over one after another, like he'd forgiven them." },
			},
			{
				label = "Buy him a proper bed",
				requires = { min = { money = 15 } },
				result = { money = -15, sanity = 4, log = "A real dog bed, with a cushion. He dragged it to the door so he could keep watch and be comfortable at the same time." },
			},
		},
	},
	{
		id = "kl_crow_door",
		title = "Number Nine, Pipe Street",
		art = "office",
		text = "The crows' key fits the shutter of number nine, Pipe Street, shut since before you were born. Inside is a Fixer office under twenty years of dust, the calendar stopped on a Tuesday.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_crow_key" }, minAge = 13, maxAge = 18 },
		choices = {
			{
				label = "Take the notebook off the desk",
				result = { mind = 1, gear = "fixer_notebook", setFlags = { "knows_fixers" }, log = "Debts and street names in neat pencil. The last entry said: Pipe St crows. Feed them. They watch the door." },
			},
			{
				label = "Read the contract board",
				result = { mind = 2, sanity = -3, setFlags = { "knows_fixers" }, log = "Every contract on the board was marked done except one, pinned in the middle. It had your street's name on it." },
			},
			{
				label = "Lock it up and leave",
				result = { sanity = 2, log = "You locked the shutter and left the key on your sill. By morning the crows had taken it up onto the roof for good." },
			},
		},
	},
	{
		id = "kl_card_asked",
		title = "Margit Sorel",
		art = "street",
		text = "A woman in a gray coat is going door to door on your street with a photo of herself, years younger. It's Margit Sorel, from the card in your shoebox.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_feather_card" }, minAge = 13, maxAge = 19 },
		dialogue = {
			{ who = "Margit Sorel", line = "My Class was cut and they lost my file. That card is the only proof I was ever inside." },
			{ who = "Margit Sorel", line = "Somebody on this street has it. Somebody always has it." },
		},
		choices = {
			{
				label = "Give her the card",
				result = { sanity = 4, money = 20, log = "She held it in both hands and paid you twenty Ahn she didn't have. A month later she was back behind the wall, Class 1." },
			},
			{
				label = "Sell it back to her",
				hint = "Mental Strength check. Name a price.",
				clash = { stat = "mind", foe = "A woman with nothing left to bargain with", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 2, money = 45, sanity = -3, log = "Forty-five Ahn. She paid it in small coins, counting out loud, and didn't look at you once." },
				lose = { money = 10, sanity = -5, log = "She heard the price and started to cry, very quietly, at your door. You let her have it for ten and felt like a Rat for a year." },
			},
			{
				label = "Say you never had it",
				result = { mind = 1, sanity = -4, log = "She thanked you and moved on to the next door. The card stayed in your shoebox. You couldn't look at it, and couldn't throw it away." },
			},
		},
	},
	{
		id = "kl_wicks_door",
		title = "Watch the Door",
		art = "syndicate",
		text = "Aunt Velka hasn't forgotten you. Tonight she wants someone at the laundry's back door during a meeting, to knock twice if a suit comes down the street.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_wicks_runner" }, minAge = 13, maxAge = 18 },
		dialogue = {
			{ who = "kl_velka", line = "You've grown. Still quick? Still quiet?" },
			{ who = "kl_velka", line = "Fifty Ahn for one evening. You've never held fifty Ahn." },
		},
		choices = {
			{
				label = "Stand at the door",
				hint = "Mental Strength check. A long evening.",
				clash = { stat = "mind", foe = "A long quiet evening", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 2, money = 50, setFlags = { "kl_wicks_made" }, log = "Nobody in a suit came. You got fifty Ahn and a nod from three people you'd never seen. The Wicks knew your name now." },
				lose = { money = 25, sanity = -5, setFlags = { "kl_wicks_made" }, log = "A suit did come, and you knocked late. The meeting ended in a hurry and the laundry shut for a month. She paid you half." },
			},
			{
				label = "Say you're done with errands",
				result = {
					sanity = 2,
					log = "She gave you a sweet like you were nine. You still didn't eat it.",
					dialogue = { { who = "kl_velka", line = "Everybody's done eventually. Some of you get to say so." } },
				},
			},
			{
				label = "Tell the neighborhood watch",
				result = { strength = 2, sanity = -4, setFlags = { "kl_wicks_crossed" }, log = "The watch thanked you and did nothing. The Wicks knew by morning, and the laundry stopped taking your family's washing." },
			},
		},
	},
	{
		id = "kl_dalia_call",
		title = "The Card in the Drawer",
		art = "office",
		text = "A man has stood across from your building for three nights, watching your window. You still have Dalia's card, so you call it.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_dalia_card" }, minAge = 13, maxAge = 18 },
		dialogue = {
			{ who = "kl_dalia", line = "Thimble Office. ... Oh. The window. You got tall." },
			{ who = "kl_dalia", line = "Client rate for windows is twenty, paid after. I'll be there by midnight." },
		},
		choices = {
			{
				label = "Pay her rate",
				requires = { min = { money = 20 } },
				result = { money = -20, sanity = 4, setFlags = { "knows_fixers", "kl_dalia_client" }, log = "She stood next to him under the lamp for ten minutes, talking. He left and didn't come back. She said he'd had the wrong window." },
			},
			{
				label = "Ask her to show you how",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Dalia's patience", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 2, strength = 1, setFlags = { "knows_fixers", "kl_dalia_student" }, log = "She made you watch, then made you write it up. A proper job report. You did it right this time, and she kept the copy." },
				lose = { sanity = -4, setFlags = { "knows_fixers" }, log = "\"Not on a client's time,\" she said, and sent you upstairs. From the window you saw nothing worth writing down." },
			},
			{
				label = "Handle it yourself",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A man under a lamp", coins = 1, base = 3, coinPower = 2 },
				win = { strength = 2, setFlags = { "knows_fixers" }, log = "You went down and asked what he wanted. He said he had the wrong building and left fast. Dalia called back to say she was proud, and billed you five." },
				lose = { health = { -6, -4 }, sanity = -5, setFlags = { "knows_fixers" }, cause = "Went down to ask a stranger what he wanted", log = "He didn't like being asked. You got back inside with your coat torn, and Dalia came anyway." },
			},
		},
	},
	{
		id = "kl_exam_hall",
		title = "Four Hundred Desks",
		art = "school",
		text = "The Feather entrance exam is in a hall just inside the checkpoint. You still have the leaflet, and the pencil. Four hundred kids and one loud clock.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_exam_leaflet" }, minAge = 13, maxAge = 18 },
		choices = {
			{
				label = "Sit the exam",
				hint = "Intelligence check. Years of reading at night.",
				clash = { stat = "intelligence", foe = "The Wing's exam", coins = 2, base = 3, coinPower = 2 },
				win = { intelligence = 3, sanity = 4, setFlags = { "knows_wings", "kl_exam_passed" }, log = "You passed, three hundred and eighty-sixth of four hundred. They pinned your number to the gate anyway, in among the Nest kids." },
				lose = { intelligence = 1, sanity = -5, setFlags = { "knows_wings" }, log = "You ran out of time on the last page. Your number wasn't on the gate. You kept the pencil, out of spite." },
			},
			{
				label = "Help the kid beside you",
				result = { strength = 1, sanity = 2, setFlags = { "knows_wings" }, log = "He was stuck on page one and shaking. You slid your paper an inch his way. Neither of you passed. He bought you noodles after." },
			},
			{
				label = "Walk out before it starts",
				result = { mind = 1, sanity = 1, log = "You looked at the four hundred desks and left before the clock started. The checkpoint guard stamped you back out without a word." },
			},
		},
	},
	{
		id = "kl_yeva_meets",
		title = "The Dark Window",
		art = "street",
		text = "The girl from the dark window finally comes down in daylight: Yeva, your age, holding the same flashlight. She's been awake every Night since she was eight.",
		weight = 0,
		when = { side = "backstreets", flags = { "kl_signals" }, minAge = 13, maxAge = 17 },
		dialogue = {
			{ who = "kl_yeva", line = "Three short, three long. I never learned the rest. The battery always died first." },
			{ who = "kl_yeva", line = "You were the only one who ever looked back." },
		},
		choices = {
			{
				label = "Teach her the rest",
				result = {
					intelligence = 1,
					sanity = 3,
					setFlags = { "kl_yeva_friend" },
					addRelation = { kind = "friend", name = "Yeva Hallett", bond = 65, age = { 13, 17 } },
					log = "You taught her the whole signal on the stairs. That Night she sent it start to finish, and you answered, and then you both slept.",
				},
			},
			{
				label = "Ask why she stays awake",
				result = {
					mind = 2,
					setFlags = { "kl_yeva_friend" },
					addRelation = { kind = "friend", name = "Yeva Hallett", bond = 60, age = { 13, 17 } },
					log = "After that you took turns, her Nights and yours.",
					dialogue = { { who = "kl_yeva", line = "Somebody should count them for the street. Might as well be me." } },
				},
			},
			{
				label = "Buy her new batteries",
				requires = { min = { money = 3 } },
				result = {
					money = -3,
					sanity = 4,
					setFlags = { "kl_yeva_friend" },
					addRelation = { kind = "friend", name = "Yeva Hallett", bond = 70, age = { 13, 17 } },
					log = "She looked at the batteries like nobody had given her anything in years. That Night her light didn't go out once.",
				},
			},
		},
	},
}
