--[[
	Story arcs, part 1 (prefix ar_). Each arc opens with a childhood hook (weight 10-14, once)
	and runs on `schedule` follow-ups (weight 0) into adulthood. A follow-up re-checks its
	`when` when it comes due, so every part keys only on the arc's own flags. Ending flags are
	ar_<arc>_end_<how>; choices that set one without a schedule close the arc early.
	Cast: Cast/Arcs.luau (plus ottavio and pigeon_keeper from Cast/Core.luau).

	The Open Contract (ar_oc_)   6-9  Dae goes out at 2:40 and never knocks. Ottavio pins a
	                                  7-Ahn card on his board, a stub in Dae's coat names the
	                                  Steam Ledger, and Ottavio's drawer holds a second card.
	                                  Payoff 20-23: Dae comes home, stays a clerk, or the
	                                  Ledger's books burn.
	Not Before Sixteen (ar_ix_)  5-7  A man in white delivers a letter "not before sixteen".
	                                  It's a Prescript. Payoff 23-25: you're handed a child's
	                                  letter to deliver, read, or burn.
	Valid Until Used (ar_wt_)    5-9  The pigeon keeper's unused WARP ticket and the letters
	                                  he sends to Car 9. Payoff 19-23: ride it, send it to
	                                  his daughter, walk him to the train, or sell it.
	The Theater Next Door (ar_th_) 4-8 Coralie in the ticket booth never grows up. Payoff
	                                  20-24: the Family's gift, a friendship, or a goodbye.
]]

return {
	-- ── The Open Contract ───────────────────────────────────────────────────
	{
		id = "ar_oc_knocks",
		title = "Two Knocks",
		art = "night",
		text = "Your cousin Dae sleeps on a mat by the door and works nights at the steam laundry. At 2:40 he pulls on his good coat, the one with your crooked patch on the elbow.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 6, maxAge = 9, notFlags = { "foundling" } },
		codex = "city_sweepers",
		dialogue = {
			{ who = "ar_dae", line = "Lock all three behind me. I'll knock twice, like always." },
			{ who = "ar_dae", line = "It's medicine for the landlady. Ten minutes. Stop looking at me like that." },
		},
		choices = {
			{
				label = "Lock up and wait by the door",
				result = {
					sanity = -3,
					setFlags = { "ar_oc_on", "knows_night" },
					schedule = { event = "ar_oc_seven", inYears = 1 },
					log = "You did all three locks and sat with your back to the door. At 3:13 the street went red, and nobody knocked.",
				},
			},
			{
				label = "Hold on to his sleeve",
				clash = { stat = "mind", foe = "Dae, with his mind made up", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 1,
					sanity = 2,
					setFlags = { "ar_oc_on", "ar_oc_ticket", "knows_night" },
					schedule = { event = "ar_oc_seven", inYears = 1 },
					log = "He stayed till 2:50 and gave you his laundry ticket to mind. Then he went, and he never knocked.",
				},
				lose = {
					sanity = -4,
					setFlags = { "ar_oc_on", "knows_night" },
					schedule = { event = "ar_oc_seven", inYears = 1 },
					log = "He took your fingers off his sleeve one at a time, gently. At 3:13 the street went red, and he never knocked.",
				},
			},
			{
				label = "Watch the street from the window",
				result = {
					mind = 1,
					sanity = -2,
					setFlags = { "ar_oc_on", "ar_oc_van", "knows_night" },
					schedule = { event = "ar_oc_seven", inYears = 1 },
					log = "At 2:51 a laundry van stopped under the lamp, and Dae climbed into the front. At 3:13 the window went red and you hid under the sill.",
				},
			},
		},
	},
	{
		id = "ar_oc_seven",
		title = "Seven Ahn",
		art = "office",
		text = "The whole street says the Night took Dae, and says it kindly. You carry your savings jar to old Ottavio, the Fixer with the empty contract board, and his hand shakes when you say the name.",
		weight = 0,
		when = { flags = { "ar_oc_on" } },
		dialogue = {
			{ who = "ottavio", line = "Seven Ahn and a button. That's a lost-cat price, kid." },
			{ who = "ottavio", line = "Out at 2:40, never knocked. What does his face do when he lies?" },
			{ who = "ottavio", line = "Everybody says the Night. The Night is very convenient for everybody." },
		},
		choices = {
			{
				label = "Pay him the whole jar",
				hint = "7 Ahn",
				requires = { min = { money = 7 } },
				result = {
					money = -7,
					sanity = 2,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_oc_coat", inYears = 4 },
					log = "He pinned a card dead center that said FIND DAE, and gave you back the button. \"Fixers don't take buttons.\"",
				},
			},
			{
				label = "Promise to pay when you're big",
				result = {
					sanity = 1,
					setFlags = { "knows_fixers", "ar_oc_owes" },
					schedule = { event = "ar_oc_coat", inYears = 4 },
					log = "\"Fixers take promises, at interest,\" he said, and pinned up a card: FIND DAE, 7 AHN OWED.",
				},
			},
			{
				label = "Tell him about the laundry van",
				requires = { flags = { "ar_oc_van" } },
				result = {
					mind = 2,
					setFlags = { "knows_fixers", "ar_oc_saw" },
					schedule = { event = "ar_oc_coat", inYears = 4 },
					log = "\"The Night doesn't drive vans,\" Ottavio said. He opened his desk drawer and shut it again without taking anything out.",
				},
			},
			{
				label = "Ask why his hand shook",
				clash = { stat = "mind", foe = "An old Fixer's straight face", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					setFlags = { "knows_fixers", "ar_oc_saw" },
					schedule = { event = "ar_oc_coat", inYears = 4 },
					log = "His drawer was open a crack. Inside lay a second card in someone else's handwriting, and you could read one word: DAE.",
				},
				lose = {
					sanity = -3,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_oc_coat", inYears = 4 },
					log = "\"Old hands shake,\" he said, and shut the drawer with his knee. He pinned your card up without looking at it.",
				},
			},
		},
	},
	{
		id = "ar_oc_coat",
		title = "The Crooked Patch",
		art = "market",
		text = "A boy at the night market is wearing Dae's good coat. You'd know that patch anywhere, because you sewed it crooked.",
		weight = 0,
		when = { flags = { "ar_oc_on" } },
		dialogue = {
			{ who = "street_kid", line = "Laundry sold it. Unclaimed a whole year, that's the rule. Everybody knows the rule." },
			{ who = "street_kid", line = "Your cousin? Then your cousin should've come and claimed it." },
		},
		choices = {
			{
				label = "Take it off his back",
				clash = { stat = "strength", foe = "The boy in Dae's coat", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = {
					strength = 2,
					setFlags = { "ar_oc_stub" },
					schedule = { event = "ar_oc_drawer", inYears = 3 },
					log = "You got the coat back. Sewn into the lining was a stub from something called the Steam Ledger: contract 0447, ten years.",
				},
				lose = {
					health = { -5, -2 },
					sanity = -4,
					setFlags = { "ar_oc_stub" },
					schedule = { event = "ar_oc_drawer", inYears = 3 },
					log = "He kept the coat, but he tore a stub out of its lining and threw it at you like trash: Steam Ledger, contract 0447.",
					cause = "Fought over a coat at the night market",
				},
			},
			{
				label = "Show him Dae's laundry ticket",
				requires = { flags = { "ar_oc_ticket" } },
				result = {
					mind = 2,
					setFlags = { "ar_oc_stub" },
					schedule = { event = "ar_oc_drawer", inYears = 3 },
					log = "He read the ticket twice and handed the coat over like it was hot. In the lining was a stub: Steam Ledger, contract 0447.",
				},
			},
			{
				label = "Go and get Ottavio",
				result = {
					sanity = -1,
					setFlags = { "ar_oc_stub", "ar_oc_owes" },
					schedule = { event = "ar_oc_drawer", inYears = 3 },
					log = "Ottavio limped over and paid the boy out of his own pocket. He kept the stub from the lining and added the coat to your bill.",
				},
			},
			{
				label = "Let him keep it",
				result = {
					sanity = 1,
					setFlags = { "ar_oc_end_coat" },
					log = "It fit him better than it ever fit Dae. You asked Ottavio to take your card down, and he said he'd think about it.",
				},
			},
		},
	},
	{
		id = "ar_oc_drawer",
		title = "The Other Card",
		art = "office",
		text = "Ottavio reads the stub twice under his lamp. Then he opens the drawer he always keeps shut and lays a second card beside yours.",
		weight = 0,
		when = { flags = { "ar_oc_stub" } },
		codex = "fn_lore_syndicates",
		dialogue = {
			{ who = "ottavio", line = "Same week as yours, same price. Different job." },
			{ who = "ottavio", line = "Yours says find him. His says don't let anyone. He paid first, kid. In my trade that matters." },
			{ who = "ottavio", line = "The Steam Ledger buys family debts. Then it buys the oldest boy in the family, ten years at a time." },
		},
		choices = {
			{
				label = "Tear up Dae's card",
				result = {
					strength = 2,
					sanity = -2,
					setFlags = { "ar_oc_hunt", "knows_syndicates" },
					schedule = { event = "ar_oc_ledger", inYears = 3 },
					log = "You tore it in four, and Ottavio pinned yours back up. \"Then I'm working for you,\" he said.",
				},
			},
			{
				label = "Make him tell you the rest",
				clash = { stat = "mind", foe = "A promise Ottavio made", coins = 1, base = 3, coinPower = 2 },
				win = {
					mind = 3,
					setFlags = { "ar_oc_hunt", "knows_syndicates" },
					schedule = { event = "ar_oc_ledger", inYears = 3 },
					log = "\"The big laundry on Ninth, and his ten years run out in three,\" he said, looking older. \"I never told you that.\"",
				},
				lose = {
					sanity = -5,
					setFlags = { "ar_oc_hunt", "knows_syndicates" },
					schedule = { event = "ar_oc_ledger", inYears = 3 },
					log = "He wouldn't say. But he left the drawer unlocked when he went to make tea, and the stub had an address on the back.",
				},
			},
			{
				label = "Say you saw that card years ago",
				requires = { flags = { "ar_oc_saw" } },
				result = {
					mind = 2,
					sanity = 2,
					setFlags = { "ar_oc_hunt", "knows_syndicates" },
					schedule = { event = "ar_oc_ledger", inYears = 3 },
					log = "\"Then you've been patient longer than me,\" he said, and wrote an address on the back of your card: NINTH STREET.",
				},
			},
			{
				label = "Pin both cards side by side",
				result = {
					mind = 1,
					sanity = 2,
					setFlags = { "ar_oc_end_open", "knows_syndicates" },
					log = "Both cards stayed open, side by side. Ottavio said some contracts close by never being finished, and you let him have that one.",
				},
			},
		},
	},
	{
		id = "ar_oc_ledger",
		title = "Contract 0447",
		art = "syndicate",
		text = "Dae's ten years end tonight, and the Steam Ledger's big laundry hisses behind its red door. A clerk with a ledger counts at the door while Dae folds sheets behind him.",
		weight = 0,
		when = { flags = { "ar_oc_hunt" } },
		dialogue = {
			{ who = "ar_mott", line = "Zero-four-four-seven. Ten years, yes, and eleven months of interest. Interest doesn't sleep." },
			{ who = "ar_dae_grown", line = "Ottavio sent you. Of course he did. Go home before the Night." },
			{ who = "ar_dae_grown", line = "Eleven months is nothing. I've done a hundred and twenty." },
		},
		choices = {
			{
				label = "Walk him out the red door",
				clash = { stat = "strength", foe = "The Steam Ledger's door men", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "syndicate" },
				win = {
					strength = 3,
					setFlags = { "ar_oc_freed" },
					schedule = { event = "ar_oc_closed", inYears = 3 },
					log = "You walked out with Dae and his folding hands, and nobody at the red door stood up again until you'd gone.",
				},
				lose = {
					health = { -14, -6 },
					sanity = -5,
					setFlags = { "ar_oc_stayed" },
					schedule = { event = "ar_oc_clerk", inYears = 3 },
					log = "You woke on the pavement at 2:30. Dae had carried you out himself, and then he went back in.",
					cause = "Beaten at the Steam Ledger's door",
				},
			},
			{
				label = "Pay the eleven months",
				hint = "150 Ahn",
				requires = { min = { money = 150 } },
				result = {
					money = -150,
					sanity = 3,
					setFlags = { "ar_oc_freed" },
					schedule = { event = "ar_oc_closed", inYears = 3 },
					log = "The clerk counted twice and wrote PAID in a hand nicer than his face. Dae never said thank you, but he carried your bag home.",
				},
			},
			{
				label = "Ask Dae what he wants",
				clash = { stat = "mind", foe = "Ten years of a straight face", coins = 2, base = 4, coinPower = 3 },
				win = {
					mind = 3,
					sanity = 2,
					setFlags = { "ar_oc_freed" },
					schedule = { event = "ar_oc_closed", inYears = 3 },
					log = "\"I want to stop being a sad story people tell,\" he said, and walked out with you. The clerk wrote LATE in the margin.",
				},
				lose = {
					sanity = -5,
					setFlags = { "ar_oc_stayed" },
					schedule = { event = "ar_oc_clerk", inYears = 3 },
					log = "\"Eleven months, then I'll knock twice,\" he said, and went back to the sheets. He'd said that once before.",
				},
			},
			{
				label = "Leave him to his sheets",
				result = {
					sanity = -3,
					setFlags = { "ar_oc_end_left" },
					log = "You left him folding. At the corner you looked back once, and the red door was already shut.",
				},
			},
		},
	},
	{
		id = "ar_oc_closed",
		title = "Closing the Card",
		art = "office",
		text = "Ottavio's lease is up and his Office is closing for good, so Dae came to help carry boxes. Your card is still pinned dead center, and Dae takes the other one down and turns it over.",
		weight = 0,
		when = { flags = { "ar_oc_freed" } },
		dialogue = {
			{ who = "ar_dae_grown", line = "Read the back. Go on. He only ever told you half." },
			{ who = "ar_dae_grown", line = "Don't let anyone near the kid. Seven Ahn a year. I paid it every year out of the laundry." },
			{ who = "ottavio", line = "Two contracts on one family. I'd never do it again. I'd do it again tomorrow." },
		},
		choices = {
			{
				label = "Write CLOSED on your card",
				result = {
					sanity = 6,
					setFlags = { "ar_oc_end_home" },
					addRelation = { kind = "sibling", name = "Dae", bond = 70, age = { 29, 33 } },
					log = "You wrote CLOSED and the date. Dae took the room behind the old Office, and he still sleeps by the door.",
				},
			},
			{
				label = "Pay Ottavio his seven Ahn",
				hint = "7 Ahn",
				requires = { flags = { "ar_oc_owes" }, min = { money = 7 } },
				result = {
					money = -7,
					sanity = 8,
					setFlags = { "ar_oc_end_home" },
					addRelation = { kind = "sibling", name = "Dae", bond = 75, age = { 29, 33 } },
					log = "\"Interest,\" Ottavio said, and kept one coin and pushed back six. Dae laughed for the first time in years.",
				},
			},
			{
				label = "Ask Ottavio to teach Dae the trade",
				result = {
					mind = 2,
					sanity = 4,
					setFlags = { "ar_oc_end_home" },
					addRelation = { kind = "sibling", name = "Dae", bond = 70, age = { 29, 33 } },
					log = "\"He counts, and Fixers who count live,\" Ottavio said. Dae carried the contract board home on his back.",
				},
			},
		},
	},
	{
		id = "ar_oc_clerk",
		title = "Seven Ahn a Year",
		art = "office",
		text = "On the last day of Ottavio's Office, a man in a Steam Ledger coat waits by the board with his hat in his hands. It's Dae, a clerk now, with a ledger of his own.",
		weight = 0,
		when = { flags = { "ar_oc_stayed" } },
		dialogue = {
			{ who = "ar_dae_grown", line = "They made me a clerk. Turns out I'm good at counting other people's years." },
			{ who = "ar_dae_grown", line = "Turn my card over. Don't let anyone near the kid. I paid him every year, and he did the job." },
			{ who = "ar_dae_grown", line = "Don't come to the laundry. Come to the noodle stall. Thursdays." },
		},
		choices = {
			{
				label = "Go on Thursdays",
				result = {
					sanity = 4,
					setFlags = { "ar_oc_end_ledger" },
					addRelation = { kind = "friend", name = "Dae", bond = 55, age = { 29, 33 } },
					log = "You went on Thursdays for years. He paid for the noodles out of a ledger he never let you read.",
				},
			},
			{
				label = "Close the card yourself",
				result = {
					strength = 1,
					mind = 1,
					setFlags = { "ar_oc_end_ledger" },
					log = "You wrote CLOSED across FIND DAE and gave it to him. He filed it in his ledger, between two other people's years.",
				},
			},
			{
				label = "Burn the Ledger's books",
				clash = { stat = "strength", foe = "The Steam Ledger's night shift", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "syndicate" },
				win = {
					strength = 4,
					sanity = 2,
					setFlags = { "ar_oc_end_burned" },
					addRelation = { kind = "friend", name = "Dae", bond = 65, age = { 29, 33 } },
					log = "The Ledger's books burned for an hour, four hundred contracts with them. Dae watched with his hands in his pockets.",
				},
				lose = {
					health = { -20, -10 },
					sanity = -6,
					setFlags = { "ar_oc_end_ledger" },
					log = "The books didn't burn. Dae dragged you out the back before the night shift was done with you, and never mentioned it.",
					cause = "Caught burning a Syndicate's books",
				},
			},
		},
	},

	-- ── Not Before Sixteen ──────────────────────────────────────────────────
	{
		id = "ar_ix_letter",
		title = "A Letter for You",
		art = "home",
		text = "A man in very white clothes knocks at noon, which nobody does. He bows and hands you an envelope with your whole name on it, in handwriting so neat it looks printed.",
		weight = 11,
		once = true,
		when = { minAge = 5, maxAge = 7 },
		dialogue = {
			{ who = "ar_white", line = "For {first} {last}. Not before sixteen." },
			{ who = "ar_white", line = "Don't fold it. It doesn't like being folded." },
			{ who = "ar_white", line = "No, I won't come in. I have eleven more today." },
		},
		choices = {
			{
				label = "Hide it under your mattress",
				result = {
					sanity = 1,
					setFlags = { "ar_ix_on" },
					schedule = { event = "ar_ix_boy", inYears = 5 },
					log = "You hid it flat under the mattress, the way he said. You slept on your own name for years.",
				},
			},
			{
				label = "Hold it up to the lamp",
				clash = { stat = "intelligence", foe = "A very thick envelope", coins = 1, base = 1, coinPower = 2, fixed = true },
				win = {
					intelligence = 1,
					sanity = 2,
					setFlags = { "ar_ix_on" },
					schedule = { event = "ar_ix_boy", inYears = 5 },
					log = "Through the paper you made out two words: CANAL BRIDGE. You didn't know what they meant, only that they were about you.",
				},
				lose = {
					sanity = -3,
					setFlags = { "ar_ix_on" },
					schedule = { event = "ar_ix_boy", inYears = 5 },
					log = "All you could see was your own name from the back, which looked wrong, like a face in a spoon.",
				},
			},
			{
				label = "Drop it in the stove",
				result = {
					mind = 1,
					sanity = -2,
					setFlags = { "ar_ix_on" },
					schedule = { event = "ar_ix_boy", inYears = 5 },
					log = "It wouldn't catch. You fished it out with the tongs, warm and perfect, and slid it under your mattress.",
				},
			},
		},
	},
	{
		id = "ar_ix_boy",
		title = "Somebody Paid Me",
		art = "home",
		text = "You come home early and a boy you don't know is lifting your mattress. He has your envelope in one hand and a slip of paper in the other, and he looks as scared as you.",
		weight = 0,
		when = { flags = { "ar_ix_on" } },
		dialogue = {
			{ who = "street_kid", line = "I'm not stealing! A lady paid me thirty Ahn to fetch a letter off the fourth floor." },
			{ who = "street_kid", line = "She said if I mess it up, that's fine too. Who pays you to mess up?" },
		},
		choices = {
			{
				label = "Wrestle it back",
				clash = { stat = "strength", foe = "A boy with your letter", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = {
					strength = 2,
					schedule = { event = "ar_ix_hand", inYears = 4 },
					log = "He ran and dropped his slip: \"Fetch the letter from the fourth floor. If you fail, that is also correct.\"",
				},
				lose = {
					health = { -4, -2 },
					sanity = -3,
					schedule = { event = "ar_ix_hand", inYears = 4 },
					log = "He got away with it. That night it was back under your door, flat and dry, with a slip pinned on: \"Not yet.\"",
				},
			},
			{
				label = "Ask who the lady was",
				clash = { stat = "mind", foe = "A frightened boy", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					schedule = { event = "ar_ix_hand", inYears = 4 },
					log = "\"Plain coat, white gloves, never says her name.\" He put your letter on the bed very carefully and climbed out the window.",
				},
				lose = {
					sanity = -3,
					schedule = { event = "ar_ix_hand", inYears = 4 },
					log = "He wouldn't say. He laid the letter on your bed like it might bite, and climbed out the window.",
				},
			},
			{
				label = "Let him take it",
				result = {
					mind = 1,
					sanity = -2,
					schedule = { event = "ar_ix_hand", inYears = 4 },
					log = "You let him. In the morning it was back under your door, flat and dry, with a slip pinned on: \"Mind the corners.\"",
				},
			},
		},
	},
	{
		id = "ar_ix_hand",
		title = "Prescript Hand",
		art = "school",
		text = "Imke, who sits behind you at the academy, sees the envelope in your bag and goes very quiet. She knows the handwriting, and so does everyone in her family.",
		weight = 0,
		when = { flags = { "ar_ix_on" } },
		codex = "fn_lore_index",
		dialogue = {
			{ who = "ar_imke", line = "That's Prescript hand. Nobody else does an s like that, all the way round." },
			{ who = "ar_imke", line = "The Index. One of the Five Fingers. My uncle got a slip at ten, and then he didn't live with us anymore." },
			{ who = "ar_imke", line = "Uncle says a Prescript for a kid is rare. He'd pay a lot. Don't tell him I said." },
		},
		choices = {
			{
				label = "Sell it to her uncle",
				result = {
					money = { 40, 60 },
					sanity = -4,
					setFlags = { "ar_ix_end_sold", "knows_index", "knows_fingers" },
					log = "He paid in old notes and bowed to the envelope. You felt light for a week, and then you didn't.",
				},
			},
			{
				label = "Ask her uncle what it means",
				clash = { stat = "mind", foe = "A Proselyte who won't look at you", coins = 1, base = 3, coinPower = 2 },
				win = {
					mind = 3,
					setFlags = { "knows_index", "knows_fingers" },
					schedule = { event = "ar_ix_sixteen", inYears = 2 },
					log = "He held it like it was hot. \"Open it on time, because late is a kind of no,\" he said.",
				},
				lose = {
					sanity = -4,
					setFlags = { "knows_index", "knows_fingers" },
					schedule = { event = "ar_ix_sixteen", inYears = 2 },
					log = "He wouldn't speak to you. Imke said he cried afterward, which he never does, and that you shouldn't come again.",
				},
			},
			{
				label = "Make Imke swear to forget it",
				result = {
					mind = 1,
					sanity = 1,
					setFlags = { "knows_index", "knows_fingers" },
					schedule = { event = "ar_ix_sixteen", inYears = 2 },
					log = "She swore on her uncle, which she said counted double. Then she drew you a map to the Index teahouse, just in case.",
				},
			},
		},
	},
	{
		id = "ar_ix_sixteen",
		title = "Not Before Sixteen",
		art = "street",
		text = "You're {age}, and the envelope opens like any other. One slip inside: \"At 4:12 on the first rain of autumn, give your umbrella to the woman on the canal bridge. Do not ask her name.\"",
		weight = 0,
		when = { flags = { "ar_ix_on" } },
		dialogue = {
			{ who = "ar_imke", line = "That's it? An umbrella? My uncle had to sit in a bakery for a whole day and not buy anything." },
			{ who = "ar_imke", line = "First rain's Thursday. My aunt's knees say so, and her knees are never wrong." },
		},
		choices = {
			{
				label = "Give her the umbrella",
				result = {
					mind = 1,
					sanity = 3,
					setFlags = { "ar_ix_obeyed" },
					chronicle = "fn_prescript_done",
					schedule = { event = "ar_ix_return", inYears = 3 },
					log = "At 4:12 it rained. She took the umbrella without looking at you, and you walked home soaked and lighter.",
				},
			},
			{
				label = "Give it, and ask her name",
				clash = { stat = "mind", foe = "The one rule on the slip", coins = 2, base = 3, coinPower = 2 },
				win = {
					mind = 2,
					setFlags = { "ar_ix_obeyed", "ar_ix_named" },
					schedule = { event = "ar_ix_return", inYears = 3 },
					log = "\"Noemi,\" she said, and then, very quietly, \"You weren't supposed to.\" She took the umbrella anyway.",
				},
				lose = {
					sanity = -5,
					setFlags = { "ar_ix_obeyed" },
					schedule = { event = "ar_ix_return", inYears = 3 },
					log = "She looked at you as if you'd dropped something valuable in the canal. Then she took the umbrella and was gone in the rain.",
				},
			},
			{
				label = "Keep your umbrella up",
				result = {
					strength = 1,
					sanity = -2,
					setFlags = { "ar_ix_defied" },
					schedule = { event = "ar_ix_late", inYears = 3 },
					log = "At 4:12 it rained. You stood on the bridge under your umbrella while the woman beside you got very wet, very patiently.",
				},
			},
			{
				label = "Burn the slip",
				result = {
					sanity = -3,
					setFlags = { "ar_ix_defied" },
					schedule = { event = "ar_ix_late", inYears = 3 },
					log = "This time it burned like any paper. You felt watched for a week, and you were.",
				},
			},
		},
	},
	{
		id = "ar_ix_return",
		title = "Returned Dry",
		art = "street",
		text = "The woman from the canal bridge is waiting outside your building in the rain, holding your umbrella closed. She has a slip of her own, folded twice.",
		weight = 0,
		when = { flags = { "ar_ix_obeyed" } },
		dialogue = {
			{ who = "ar_noemi", line = "My Prescript said carry it three years and return it dry. It's dry. I've been very careful." },
			{ who = "ar_noemi", line = "I carried the man in white's bag the day he brought your letter. I've had your name in my pocket since." },
			{ who = "ar_noemi", line = "This slip says you may come with me. May. I've never had a may before." },
		},
		choices = {
			{
				label = "Go with her",
				hint = "Join the Index.",
				result = {
					sanity = 2,
					career = "index",
					setFlags = { "ar_ix_joined" },
					schedule = { event = "ar_ix_errand", inYears = 4 },
					log = "You followed her into the rain and left the umbrella on the step. The Index gave you a plain coat and your first slip that night.",
				},
			},
			{
				label = "Call her Noemi",
				requires = { flags = { "ar_ix_named" } },
				result = {
					mind = 1,
					sanity = 4,
					schedule = { event = "ar_ix_errand", inYears = 4 },
					log = "She flinched as if you'd pressed a bruise. Then she came up for tea, and drank it standing.",
				},
			},
			{
				label = "Ask who writes the slips",
				clash = { stat = "mind", foe = "A Proxy's faith", coins = 2, base = 4, coinPower = 3 },
				win = {
					mind = 3,
					schedule = { event = "ar_ix_errand", inYears = 4 },
					log = "\"Nobody writes them. They're found, like your letter was,\" she said, and left the umbrella on your step.",
				},
				lose = {
					sanity = -5,
					schedule = { event = "ar_ix_errand", inYears = 4 },
					log = "She smiled as if you'd asked what color water is, and walked off. The umbrella was on your step, dry.",
				},
			},
			{
				label = "Take it and shut the door",
				result = {
					sanity = 1,
					schedule = { event = "ar_ix_errand", inYears = 4 },
					log = "You took it and shut the door. Through the glass you watched her bow to the door, and go.",
				},
			},
		},
	},
	{
		id = "ar_ix_late",
		title = "Late Is a Kind of No",
		art = "alley",
		text = "Two people in plain white coats wait at the bottom of your stairs. One holds a closed umbrella, and the other holds a slip with your name on it in the round hand.",
		weight = 0,
		when = { flags = { "ar_ix_defied" } },
		dialogue = {
			{ who = "index_proxy", line = "The Prescript was not carried out. We are here to carry it out." },
			{ who = "ar_noemi", line = "Just give me an umbrella. Any umbrella. That's all it ever was. Please." },
		},
		choices = {
			{
				label = "Hand her your umbrella",
				result = {
					sanity = 2,
					chronicle = "fn_prescript_done",
					schedule = { event = "ar_ix_errand", inYears = 4 },
					log = "You gave her an umbrella three years late. The other Proxy wrote it in a tiny book, and she bowed as if it still counted.",
				},
			},
			{
				label = "Fight your way up the stairs",
				clash = { stat = "strength", foe = "Two Index Proxies", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "index_proxy" },
				win = {
					strength = 3,
					sanity = -2,
					setFlags = { "ar_ix_end_struck" },
					log = "They went down on the landing and stayed down until you'd locked the door. In the morning your name was crossed off their slip.",
				},
				lose = {
					health = { -16, -8 },
					sanity = -6,
					schedule = { event = "ar_ix_errand", inYears = 4 },
					log = "You woke on the landing without your umbrella. Somewhere across the District, a Prescript had been carried out.",
					cause = "Fought the Index over an umbrella",
				},
			},
			{
				label = "Shut the door on them",
				result = {
					sanity = -6,
					schedule = { event = "ar_ix_errand", inYears = 4 },
					log = "They waited on your stairs for nine days, in shifts. On the tenth you went down and handed over the umbrella.",
				},
			},
		},
	},
	{
		id = "ar_ix_errand",
		title = "Eleven More Today",
		art = "home",
		text = "A slip comes under your door in the round hand. Pinned to it is a flat white envelope addressed to a six-year-old on the fourth floor, three streets over.",
		weight = 0,
		when = { flags = { "ar_ix_on" } },
		dialogue = {
			{ who = "ar_white", line = "My knees are finished. You know the way. Noon, never later." },
			{ who = "ar_white", line = "Don't read it. I never read a single one. Well. One." },
		},
		choices = {
			{
				label = "Deliver it at noon",
				result = {
					mind = 2,
					sanity = 2,
					setFlags = { "ar_ix_end_messenger" },
					chronicle = "fn_prescript_done",
					log = "You knocked at noon and said the child's whole name. They looked up at you the way you once looked at him.",
				},
			},
			{
				label = "Deliver it and report back",
				hint = "Index members only.",
				requires = { career = "index" },
				result = {
					sanity = 2,
					promote = true,
					setFlags = { "ar_ix_end_messenger" },
					chronicle = "fn_prescript_done",
					log = "You delivered it at noon and reported at one. Your Proxy moved your name to a different page of the book.",
				},
			},
			{
				label = "Read it first",
				result = {
					mind = 3,
					sanity = -6,
					setFlags = { "ar_ix_end_read" },
					log = "You read it on the stairs and delivered it anyway, at noon. You never told anyone what a six-year-old had been asked to do.",
				},
			},
			{
				label = "Burn it",
				result = {
					strength = 2,
					sanity = -4,
					setFlags = { "ar_ix_end_refused" },
					log = "It caught at once, as if it had been waiting to. Nobody ever came about it, and that was the worst part.",
				},
			},
		},
	},

	-- ── Valid Until Used ────────────────────────────────────────────────────
	{
		id = "ar_wt_ticket",
		title = "The Ticket in the Seed Tin",
		art = "rooftop",
		text = "Halbrand the pigeon keeper lets you scoop seed while the WARP trains cross overhead. At the bottom of the tin, under the seed, lies a train ticket with a gold edge.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 5, maxAge = 9 },
		codex = "districts_w_corp",
		dialogue = {
			{ who = "pigeon_keeper", line = "Put that back. That's my girl's. Vesna's." },
			{ who = "pigeon_keeper", line = "Second Class, the 5:10 out. Valid until used. She's coming back for it any day now." },
			{ who = "pigeon_keeper", line = "Birds come back, and so do girls. Scoop, don't stare." },
		},
		choices = {
			{
				label = "Bury it under the seed again",
				result = {
					sanity = 2,
					setFlags = { "ar_wt_on" },
					schedule = { event = "ar_wt_letters", inYears = 3 },
					log = "You buried it under the seed. He patted the tin twice, like a dog that had done well.",
				},
			},
			{
				label = "Ask where Vesna went",
				result = {
					mind = 1,
					setFlags = { "ar_wt_on" },
					schedule = { event = "ar_wt_letters", inYears = 3 },
					log = "\"She's a Feather in District 23, very important,\" he told the pigeons. The pigeons didn't believe him either.",
				},
			},
			{
				label = "Slip it into your sock",
				clash = { stat = "intelligence", foe = "A pigeon keeper's eyes", coins = 1, base = 1, coinPower = 2, fixed = true },
				win = {
					intelligence = 2,
					sanity = 2,
					setFlags = { "ar_wt_on" },
					schedule = { event = "ar_wt_letters", inYears = 3 },
					log = "You looked at it under the blanket every night for a week, and then put it back. He never knew, you think.",
				},
				lose = {
					sanity = -3,
					setFlags = { "ar_wt_on" },
					schedule = { event = "ar_wt_letters", inYears = 3 },
					log = "He held out his hand without looking. You put the ticket in it, and he didn't speak to you for a month.",
				},
			},
		},
	},
	{
		id = "ar_wt_letters",
		title = "Return to Sender",
		art = "rooftop",
		text = "Every spring Halbrand ties a letter to his fastest bird, and every spring it comes back the same day with the letter still sealed. This year he asks you to tie the knot.",
		weight = 0,
		when = { flags = { "ar_wt_on" } },
		dialogue = {
			{ who = "pigeon_keeper", line = "Tighter. The rail makes them nervous. W Corp owns the sky up there. The Wings own everything else." },
			{ who = "pigeon_keeper", line = "Address? Car 9. That's all. She'll be in Car 9." },
			{ who = "pigeon_keeper", line = "Don't look at me like I'm daft. Birds find people. They found this roof, and so did you." },
		},
		choices = {
			{
				label = "Tie the knot and let it fly",
				result = {
					intelligence = 1,
					sanity = 2,
					setFlags = { "knows_wings" },
					schedule = { event = "ar_wt_thieves", inYears = 4 },
					log = "It flew at the rail and was back in an hour, sealed. He put it in the tin with the others, thirty-one of them.",
				},
			},
			{
				label = "Read one of the old letters",
				clash = { stat = "mind", foe = "Thirty-one sealed letters", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					setFlags = { "knows_wings", "ar_wt_read" },
					schedule = { event = "ar_wt_thieves", inYears = 4 },
					log = "It said: I had my foot on the step, then the doors closed, I'm sorry. Every letter in the tin was signed Papa.",
				},
				lose = {
					sanity = -3,
					setFlags = { "knows_wings" },
					schedule = { event = "ar_wt_thieves", inYears = 4 },
					log = "He caught you with a thumb under the seal. \"Those are hers,\" he said, and took the tin downstairs.",
				},
			},
			{
				label = "Tell him she isn't coming",
				result = {
					mind = 1,
					sanity = -4,
					setFlags = { "knows_wings", "ar_wt_end_told" },
					log = "He didn't argue. He fed the birds and said nothing, and the next spring he tied the knot himself.",
				},
			},
		},
	},
	{
		id = "ar_wt_thieves",
		title = "Pigeon Thieves",
		art = "rooftop",
		text = "A pack of Rat kids comes up the fire stairs at dusk with sacks, because pigeons sell for two Ahn each at the market. Halbrand is down at the clinic, and the loft door is open.",
		weight = 0,
		when = { flags = { "ar_wt_on" } },
		dialogue = {
			{ who = "street_kid", line = "Two Ahn a bird. Forty birds. Do the sums, roof kid." },
			{ who = "street_kid", line = "And whatever's in that tin. Old men keep the good stuff in tins." },
		},
		choices = {
			{
				label = "Stand in the loft door",
				clash = { stat = "strength", foe = "Rat kids with sacks", coins = 1, base = 3, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = {
					strength = 2,
					health = 1,
					setFlags = { "knows_syndicates" },
					schedule = { event = "ar_wt_platform", inYears = 4 },
					log = "They went back down the fire stairs with empty sacks. Halbrand counted forty birds when he got home, and then he counted you twice.",
				},
				lose = {
					health = { -6, -3 },
					sanity = -4,
					setFlags = { "knows_syndicates" },
					schedule = { event = "ar_wt_platform", inYears = 4 },
					log = "They got away with eleven birds. They never found the tin, and Halbrand said that was what mattered.",
					cause = "Fought pigeon thieves on a roof",
				},
			},
			{
				label = "Sit on the tin",
				result = {
					sanity = -2,
					setFlags = { "knows_syndicates" },
					schedule = { event = "ar_wt_platform", inYears = 4 },
					log = "They took eleven birds while you sat on the tin with your eyes shut. Halbrand said eleven was a fair price for the tin.",
				},
			},
			{
				label = "Whistle the whole loft up",
				clash = { stat = "intelligence", foe = "Forty nervous pigeons", coins = 1, base = 3, coinPower = 2, fixed = true },
				win = {
					intelligence = 2,
					sanity = 2,
					setFlags = { "knows_syndicates" },
					schedule = { event = "ar_wt_platform", inYears = 4 },
					log = "Forty birds went up at once, and the Rat kids stood in a storm of feathers holding empty sacks. By dark every bird was home.",
				},
				lose = {
					sanity = -4,
					setFlags = { "knows_syndicates" },
					schedule = { event = "ar_wt_platform", inYears = 4 },
					log = "Half the loft went up. The Rat kids took six of the slow ones, and Halbrand said their names to you at dinner.",
				},
			},
			{
				label = "Hold the sacks open for them",
				result = {
					money = 20,
					sanity = -5,
					setFlags = { "knows_syndicates", "ar_wt_end_birds" },
					log = "They paid you twenty Ahn. Halbrand came home to an empty loft and didn't ask, because he didn't have to.",
				},
			},
		},
	},
	{
		id = "ar_wt_platform",
		title = "Car 9",
		art = "train",
		text = "You take Halbrand's thirty-fifth letter to the WARP platform yourself. Car 9 of the 5:10 rolls in sealed, and a cleanup crew in long coats waits to go in first.",
		weight = 0,
		when = { flags = { "ar_wt_on" } },
		dialogue = {
			{ who = "ar_vesna", line = "Platform's closed until the car's clean. Behind the yellow line, please." },
			{ who = "ar_vesna", line = "Car 9? Who told you to ask for Car 9?" },
		},
		choices = {
			{
				label = "Say Halbrand's name",
				clash = { stat = "mind", foe = "A cleanup agent on shift", coins = 2, base = 4, coinPower = 3 },
				win = {
					mind = 3,
					setFlags = { "ar_wt_met_vesna" },
					schedule = { event = "ar_wt_valid", inYears = 3 },
					log = "She read the letter twice through her visor. \"Tell him I'm well,\" she said. \"Tell him I can't say more than that. The birds were right about me.\"",
				},
				lose = {
					sanity = -5,
					schedule = { event = "ar_wt_valid", inYears = 3 },
					log = "\"Lots of old men on lots of roofs,\" she said, and went into Car 9. You carried the letter home.",
				},
			},
			{
				label = "Duck under the barrier",
				clash = { stat = "speed", foe = "A W Corp cleanup agent", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "wcorp_cleanup" },
				win = {
					speed = 3,
					schedule = { event = "ar_wt_valid", inYears = 3 },
					log = "You got as far as the door of Car 9. Inside it was spotless: a wet floor, a smell of bleach, forty empty seats. Whatever the crew had come to clean, you were too late to see it.",
				},
				lose = {
					health = { -14, -6 },
					sanity = -5,
					schedule = { event = "ar_wt_valid", inYears = 3 },
					log = "They put you back behind the yellow line, firmly, and filed a delay report with your name on it.",
					cause = "Removed from a WARP platform",
				},
			},
			{
				label = "Move when the rail hums",
				requires = { noStyle = true },
				clash = { stat = "strength", foe = "A W Corp cleanup agent", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "wcorp_cleanup" },
				win = {
					strength = 3,
					style = "charge",
					schedule = { event = "ar_wt_valid", inYears = 3 },
					log = "You waited for the 5:10 to set the rail humming and moved when it peaked. You fight like Charge now: build it up, then let go.",
				},
				lose = {
					health = { -14, -6 },
					sanity = -5,
					schedule = { event = "ar_wt_valid", inYears = 3 },
					log = "You moved on the hum, and she moved first. They put you back behind the yellow line and filed a delay report.",
					cause = "Removed from a WARP platform",
				},
			},
			{
				label = "Leave the letter on a bench",
				result = {
					sanity = -1,
					schedule = { event = "ar_wt_valid", inYears = 3 },
					log = "You left it on the bench with CAR 9 written on it. When the car was clean, the letter was gone.",
				},
			},
		},
	},
	{
		id = "ar_wt_valid",
		title = "Valid Until Used",
		art = "home",
		text = "Halbrand can't climb to the roof anymore, so you bring the tin down to his room. He digs out the gold-edged ticket and presses it into your hand.",
		weight = 0,
		when = { flags = { "ar_wt_on" } },
		dialogue = {
			{ who = "pigeon_keeper", line = "It's mine. It was always mine. She used hers." },
			{ who = "pigeon_keeper", line = "I had my foot on the step. Ten seconds, they said. She went through the doors, and I stood there, and they closed." },
			{ who = "pigeon_keeper", line = "Valid until used. Use it, or don't. Just don't put it back in the tin." },
		},
		choices = {
			{
				label = "Ride the 5:10",
				hint = "Moves you to District 23.",
				result = {
					mind = 2,
					intelligence = 2,
					sanity = -2,
					district = "d23",
					setFlags = { "ar_wt_end_rode" },
					log = "The ride took ten seconds, and there was nothing in them. You stepped off in District 23 with his letter in your hand, and stood on the platform where she works, waiting for a face you'd know.",
				},
			},
			{
				label = "Send it to Vesna by bird",
				requires = { flags = { "ar_wt_met_vesna" } },
				result = {
					sanity = 6,
					setFlags = { "ar_wt_end_vesna" },
					log = "You tied it to his fastest bird. Next morning Vesna came up the stairs in a grey W Corp coat, and sat with him until the light went.",
				},
			},
			{
				label = "Walk him to the platform",
				requires = { flags = { "ar_wt_read" } },
				result = {
					mind = 2,
					sanity = 3,
					setFlags = { "ar_wt_end_halbrand" },
					log = "He put one foot on the step, then the other. The doors of Car 9 closed behind him.",
				},
			},
			{
				label = "Sell it at the W Corp window",
				result = {
					money = { 200, 300 },
					sanity = -4,
					setFlags = { "ar_wt_end_sold" },
					log = "The clerk paid face value plus thirty years of interest. Halbrand never asked, and he fed the birds until spring.",
				},
			},
		},
	},

	-- ── The Theater Next Door ───────────────────────────────────────────────
	{
		id = "ar_th_booth",
		title = "The Girl in the Ticket Booth",
		art = "theater",
		text = "The shuttered theater next door has a ticket booth with a cracked glass window. After dark, well before three, a girl your size sits in it and waves at you.",
		weight = 11,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 8, notFlags = { "bf_family_raised" } },
		dialogue = {
			{ who = "ar_coralie", line = "I'm Coralie. We don't sell tickets. Mama says nobody comes to plays anymore." },
			{ who = "ar_coralie", line = "What's the sun like? Is it hot like soup or hot like a stove?" },
		},
		choices = {
			{
				label = "Say it's hot like soup",
				result = {
					sanity = 2,
					setFlags = { "ar_th_on" },
					schedule = { event = "ar_th_stones", inYears = 3 },
					log = "\"Soup,\" she said, very seriously, and wrote it in a notebook full of other people's answers.",
				},
			},
			{
				label = "Bring her a jar of sun",
				result = {
					intelligence = 1,
					sanity = 3,
					setFlags = { "ar_th_on" },
					schedule = { event = "ar_th_stones", inYears = 3 },
					log = "You left a jar on the sill all afternoon and screwed the lid on fast. She held it to her cheek and said it was still warm.",
				},
			},
			{
				label = "Ask why she never comes out",
				result = {
					mind = 1,
					setFlags = { "ar_th_on" },
					schedule = { event = "ar_th_stones", inYears = 3 },
					log = "\"Allergies,\" she said, too fast, the way grown-ups say it. Then she asked you to come back tomorrow, same time.",
				},
			},
		},
	},
	{
		id = "ar_th_stones",
		title = "Stones at the Theater",
		art = "theater",
		text = "The big kids from the laundry block are throwing stones at the theater doors. Somebody has chalked a word on the steps that you're not allowed to say.",
		weight = 0,
		when = { flags = { "ar_th_on" } },
		dialogue = {
			{ who = "bully", line = "They only come out at night. That means something. My brother says it means something." },
			{ who = "ar_coralie", line = "Don't. Mama says if we answer the door, we have to move again." },
		},
		choices = {
			{
				label = "Take their stones away",
				clash = { stat = "strength", foe = "The laundry-block kids", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "bully" },
				win = {
					strength = 2,
					setFlags = { "ar_th_stood" },
					schedule = { event = "ar_th_dinner", inYears = 3 },
					log = "You took a pocketful of stones off them and dropped them down the drain. Coralie clapped behind the glass without a sound.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -3,
					setFlags = { "ar_th_stood" },
					schedule = { event = "ar_th_dinner", inYears = 3 },
					log = "They chased you off the steps and kept throwing. That night somebody washed the chalk off, and you never saw who.",
				},
			},
			{
				label = "Lie that a Fixer lives there",
				clash = { stat = "mind", foe = "Kids who want a reason", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					setFlags = { "ar_th_stood" },
					schedule = { event = "ar_th_dinner", inYears = 3 },
					log = "\"She's a Grade 2 and she hates noise,\" you said, and they dropped the stones. Coralie laughed so hard behind the glass she had to sit down.",
				},
				lose = {
					sanity = -4,
					setFlags = { "ar_th_stood" },
					schedule = { event = "ar_th_dinner", inYears = 3 },
					log = "\"Liar,\" they said, correctly, and threw another. It cracked the booth glass, and Coralie wasn't in the booth anymore.",
				},
			},
			{
				label = "Scrub the chalk off the steps",
				result = {
					intelligence = 1,
					sanity = 1,
					setFlags = { "ar_th_stood" },
					schedule = { event = "ar_th_dinner", inYears = 3 },
					log = "When they got bored and left, you scrubbed the word off the steps with your sleeve. The booth light blinked twice.",
				},
			},
			{
				label = "Throw one too",
				result = {
					sanity = -5,
					setFlags = { "ar_th_end_stones" },
					log = "Your stone hit the ticket booth. Coralie watched you through the crack, and the next night the booth was boarded up.",
				},
			},
		},
	},
	{
		id = "ar_th_dinner",
		title = "Dinner on the Stage",
		art = "theater",
		text = "Coralie's family asks you to dinner on the stage, under one lamp, with a whole roast and nine kinds of pickle. Nobody else at the table eats a thing.",
		weight = 0,
		when = { flags = { "ar_th_stood" } },
		dialogue = {
			{ who = "ar_ysolde", line = "Eat. We ate earlier. Now: who on this street keeps a dog? Who keeps a gun?" },
			{ who = "ar_coralie", line = "Mama asks everybody that. It's like how other mamas ask about school." },
		},
		choices = {
			{
				label = "Eat everything",
				result = {
					health = 2,
					sanity = 3,
					schedule = { event = "ar_th_red", inYears = 4 },
					log = "You ate until you couldn't. Madame Ysolde watched you chew the way other people watch a fire.",
				},
			},
			{
				label = "Answer her questions",
				clash = { stat = "mind", foe = "Madame Ysolde's questions", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					setFlags = { "ar_th_trusted" },
					schedule = { event = "ar_th_red", inYears = 4 },
					log = "You told her about the landlord's dog and the Fixer on the fifth floor. She thanked you like a client.",
				},
				lose = {
					sanity = -4,
					schedule = { event = "ar_th_red", inYears = 4 },
					log = "You named the wrong building for the dog. She knew, and passed you the pickles anyway.",
				},
			},
			{
				label = "Ask why nobody's eating",
				result = {
					mind = 1,
					schedule = { event = "ar_th_red", inYears = 4 },
					log = "\"Diet,\" said all four of them at once. Coralie kicked you under the table, very gently.",
				},
			},
		},
	},
	{
		id = "ar_th_red",
		title = "Still Eight",
		art = "theater",
		text = "You're {age} now, and Coralie still sits in the booth after dark, still eight years old. Tonight the streetlight catches her eyes, and they're red.",
		weight = 0,
		when = { flags = { "ar_th_stood" } },
		codex = "bf_lore_bloodfiends",
		dialogue = {
			{ who = "ar_coralie", line = "You got tall. I don't. That's the whole secret, mostly." },
			{ who = "ar_coralie", line = "We're a Family. We drink the red foil bars. Never people. Mama would die of shame, if she could." },
			{ who = "ar_coralie", line = "You're going to tell someone. Everybody does, around now." },
		},
		choices = {
			{
				label = "Keep her secret",
				result = {
					sanity = 3,
					setFlags = { "knows_bloodfiends", "ar_th_kept" },
					schedule = { event = "ar_th_hunter", inYears = 3 },
					log = "You swore on the crack in the glass, which she said was binding for her kind. You still don't know if she was joking.",
				},
			},
			{
				label = "Ask how old she really is",
				clash = { stat = "mind", foe = "A girl with decades of practice lying", coins = 1, base = 3, coinPower = 2 },
				win = {
					mind = 3,
					setFlags = { "knows_bloodfiends", "ar_th_kept" },
					schedule = { event = "ar_th_hunter", inYears = 3 },
					log = "\"Fifty-one, eight on the outside,\" she said. \"Don't tell Mama I told you, she's a hundred and ninety.\"",
				},
				lose = {
					sanity = -5,
					setFlags = { "knows_bloodfiends", "ar_th_kept" },
					schedule = { event = "ar_th_hunter", inYears = 3 },
					log = "\"Eight,\" she said, and kept saying it until you stopped asking. Her notebook of other people's answers had a lot of pages.",
				},
			},
			{
				label = "Ask Madame Ysolde instead",
				requires = { flags = { "ar_th_trusted" } },
				result = {
					mind = 2,
					sanity = 2,
					setFlags = { "knows_bloodfiends", "ar_th_kept" },
					schedule = { event = "ar_th_hunter", inYears = 3 },
					log = "Ysolde told you what they are, the way a client reads back a contract. Then she told you what happens to neighbors who talk.",
				},
			},
			{
				label = "Tell the landlord",
				result = {
					sanity = -5,
					setFlags = { "knows_bloodfiends", "ar_th_end_told" },
					log = "By spring the theater was empty and the booth glass was swept up. Someone left a red foil wrapper on your step.",
				},
			},
		},
	},
	{
		id = "ar_th_hunter",
		title = "A Contract for the Theater",
		art = "street",
		text = "A woman in a long greatcoat is asking around the block about the shuttered theater. She shows everyone a contract with its address on it, and a number with a lot of zeros.",
		weight = 0,
		when = { flags = { "ar_th_kept" } },
		dialogue = {
			{ who = "hunter", line = "Red eyes, and never at the market. You live next door. You've seen them." },
			{ who = "hunter", line = "Point at the door and I split the fee with you. A third. That's a generous third." },
		},
		choices = {
			{
				label = "Lie to her face",
				clash = { stat = "charisma", foe = "A Hunter who reads faces", coins = 2, base = 4, coinPower = 3 },
				win = {
					charisma = 3,
					sanity = 2,
					setFlags = { "ar_th_saved" },
					schedule = { event = "ar_th_gift", inYears = 3 },
					log = "\"Night-shift bakers, very boring,\" you said. She wrote it down and took her contract two Districts over.",
				},
				lose = {
					sanity = -6,
					schedule = { event = "ar_th_gift", inYears = 3 },
					log = "She smiled at your lie and went to knock. You ran round the back to warn them, and the booth was already dark.",
				},
			},
			{
				label = "Stand in the theater door",
				clash = { stat = "strength", foe = "A Hunter with a contract", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "hunter" },
				win = {
					strength = 3,
					setFlags = { "ar_th_saved" },
					schedule = { event = "ar_th_gift", inYears = 3 },
					log = "She left with her contract folded very small. In the booth, somebody small applauded without a sound.",
				},
				lose = {
					health = { -14, -6 },
					sanity = -5,
					schedule = { event = "ar_th_gift", inYears = 3 },
					log = "She stepped over you on the steps. Inside she found an empty theater and a note: THANK YOU, NEIGHBOR.",
					cause = "Stood between a Hunter and a door",
				},
			},
			{
				label = "Run round the back to warn them",
				result = {
					mind = 1,
					sanity = -1,
					schedule = { event = "ar_th_gift", inYears = 3 },
					log = "You banged on the stage door until Ysolde opened it. When the Hunter knocked out front, the theater was all dust and a CLOSED sign.",
				},
			},
			{
				label = "Take the third",
				result = {
					money = { 150, 250 },
					sanity = -8,
					setFlags = { "ar_th_end_sold" },
					log = "You pointed. The theater was empty by dawn, and somebody had scratched one word into the booth glass: NEIGHBOR.",
				},
			},
		},
	},
	{
		id = "ar_th_gift",
		title = "The Family Moves On",
		art = "theater",
		text = "The Family is leaving the theater; a dozen years in one place is long for them. Madame Ysolde asks you in as a guest for the first time and sets a red foil bar on the table between you.",
		weight = 0,
		when = { flags = { "ar_th_kept" } },
		dialogue = {
			{ who = "ar_ysolde", line = "You kept the door. Families remember a door kept." },
			{ who = "ar_ysolde", line = "I may make two Kindred in my life. I've made one. I'm offering you the other." },
			{ who = "ar_coralie", line = "Don't. Then you'll stop too, and I liked watching you grow." },
		},
		choices = {
			{
				label = "Take the red foil",
				hint = "Become a Bloodfiend.",
				result = {
					health = 10,
					sanity = -4,
					form = "bloodfiend",
					addTrait = "bf_hardblood",
					chronicle = "bf_turned",
					trigger = "bf_first_thirst",
					setFlags = { "ar_th_end_kindred" },
					log = "A sting at the wrist, then a warmth like a fever breaking. Coralie looked away while Ysolde said, \"Welcome, Kindred.\"",
				},
			},
			{
				label = "Stay human, and stay friends",
				result = {
					sanity = 4,
					addTrait = "bf_family_friend",
					addRelation = { kind = "friend", name = "Coralie", bond = 70, age = { 56, 60 } },
					setFlags = { "ar_th_end_friend" },
					log = "Ysolde bowed as if you'd paid her. Coralie writes every year from somewhere new, in the same round child's hand.",
				},
			},
			{
				label = "Ask for the theater",
				requires = { flags = { "ar_th_saved" } },
				result = {
					mind = 2,
					sanity = 3,
					setFlags = { "ar_th_end_theater" },
					log = "Ysolde signed the theater over to you in red ink, unpaid bills and all. Coralie left her notebook of answers in the booth.",
				},
			},
			{
				label = "Carry their trunks to the van",
				result = {
					health = 1,
					mind = 2,
					setFlags = { "ar_th_end_gone" },
					log = "You loaded trunks until 2:50 and watched the van go. You kept the key to the ticket booth.",
				},
			},
		},
	},
}
