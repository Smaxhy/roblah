--[[
	More late-life events: ages 55+. Legacy, memory, mentoring the young, frailty,
	old friends and old rivals, heirlooms, retirement, and the long view of Undermere.
	Threads:
		company_pension     adult2_company_pension (Adult2) -> elder2_pension_due (17 yrs)
		                    (pension_clause, set by reading the small print, unlocks a choice)
		elder_apprentice    elder2_apprentice -> elder2_apprentice_trial (4 yrs)
	Logs on results that use killRelation name the person without a {token}, because the
	token would already point at the next living relation of that kind.
]]

return {
	-- Story threads ----------------------------------------------------------
	{
		id = "elder2_pension_due",
		title = "The Pension Comes Due",
		text = "Seventeen years after you signed the company's pension book, a letter in company grey finds you. The fund has been, in the letter's words, prudently restructured. Your pension will be paid as promised, at one third of the sum promised, in person, at the Rim offices, on the third floor, on the first morning of each quarter, between nine and a quarter past.",
		weight = 0,
		once = true,
		tags = { "elder", "company", "money", "thread_pension" },
		when = { flags = { "company_pension" } },
		choices = {
			{
				label = "Take the third and say thank you",
				result = {
					money = { 100, 150 },
					sanity = -1,
					clearFlags = { "company_pension", "pension_clause" },
					log = "You climbed to the third floor for your third of a pension, said thank you, and despised yourself a little on the way down.",
				},
			},
			{
				label = "Fight the restructuring",
				hint = "Temperance clash, hard.",
				clash = { stat = "temperance", foe = "The company's pension office", coins = 3, base = 6, coinPower = 3 },
				win = {
					money = { 300, 420 },
					justice = 2,
					sanity = 4,
					clearFlags = { "company_pension", "pension_clause" },
					log = "You found the page where the company had promised the full sum in its own ink, and they paid it to make you leave.",
				},
				lose = {
					money = { 40, 70 },
					sanity = -4,
					clearFlags = { "company_pension", "pension_clause" },
					log = "The pension office explained the restructuring to you very slowly, twice, and paid you a sliver for your patience.",
				},
			},
			{
				label = "Quote clause nine across the counter",
				hint = "You read the small print.",
				requires = { flags = { "pension_clause" } },
				result = {
					money = { 360, 450 },
					prudence = 2,
					sanity = 5,
					clearFlags = { "company_pension", "pension_clause" },
					log = "You quoted clause nine from memory across the counter, and the clerk went pale and paid you in full.",
				},
			},
			{
				label = "Sign it over to the clerks they let go",
				result = {
					justice = 4,
					sanity = 3,
					clearFlags = { "company_pension", "pension_clause" },
					log = "You signed your pension over to the old clerks the company had let go without one. They passed it round like bread.",
				},
			},
		},
	},
	{
		id = "elder2_apprentice",
		title = "A Notebook on Your Step",
		text = "A girl of thirteen from the landing below, Tamsin Ingram, has started sitting on your step every evening and asking questions: how to read a tide table, how to tie a knot that won't slip in wet rope, how you knew the water was rising that year before anyone else did. Her people work double shifts and are never home before dark. She has a notebook, a stub of pencil, and your name written at the top of the first page.",
		weight = 12,
		once = true,
		tags = { "elder", "mentor", "kindness", "thread_apprentice" },
		when = { minAge = 56, notFlags = { "elder_apprentice" } },
		choices = {
			{
				label = "Teach her everything you know",
				result = {
					prudence = 2,
					sanity = 4,
					addRelation = { kind = "friend", name = "Tamsin Ingram", bond = 55, age = 13 },
					setFlags = { "elder_apprentice" },
					schedule = { event = "elder2_apprentice_trial", inYears = 4 },
					log = "You taught {newRelation} everything you knew, one evening at a time, and she wrote all of it down, even the jokes.",
				},
			},
			{
				label = "Pay for her place at the night school",
				hint = "40 scrip.",
				requires = { min = { money = 40 } },
				result = { money = -40, justice = 2, sanity = 2, log = "You paid for Tamsin's place at the night school and told her to come back and teach you something. She did, every week." },
			},
			{
				label = "Tell her you're too old for questions",
				result = { sanity = -2, log = "You told her you were too old for questions. She stopped coming, and the step was colder than it had any right to be." },
			},
		},
	},
	{
		id = "elder2_apprentice_trial",
		title = "The Night Before the Trial",
		text = "Tamsin Ingram is seventeen now, and in the morning she takes the Lantern Guild's trial dive: one lantern, one rope, the drowned bell at the bottom of Chandlers' Row and back. She knocks on your door at midnight, white as paper, holding the notebook full of your words. She doesn't ask you anything. She just sits down.",
		weight = 0,
		once = true,
		tags = { "elder", "mentor", "diver", "thread_apprentice" },
		when = { flags = { "elder_apprentice" } },
		choices = {
			{
				label = "Sit up with her until dawn",
				result = {
					prudence = 1,
					sanity = 4,
					clearFlags = { "elder_apprentice" },
					log = "You sat up with Tamsin until dawn, telling her about your worst days, and she went to the pier laughing. She came up with the bell's mud on her hands.",
				},
			},
			{
				label = "Give her your own tool to carry down",
				hint = "Needs a tool. You'll give it away.",
				requires = { hasGear = { "dock_knife", "hook_pole", "pocket_ledger", "tide_tables", "diving_lamp" } },
				result = {
					loseGear = "tool",
					justice = 2,
					sanity = 6,
					clearFlags = { "elder_apprentice" },
					log = "You pressed your own old tool into her hands for luck. She carried it down to the drowned bell and back, and never gave it back, which was right.",
				},
			},
			{
				label = "Go down beside her",
				hint = "Fortitude clash, hard. You are not young.",
				clash = { stat = "fortitude", foe = "Chandlers' Row, at your age", coins = 3, base = 6, coinPower = 3 },
				win = {
					justice = 3,
					sanity = 7,
					clearFlags = { "elder_apprentice" },
					log = "You went down beside her one last time, and the two of you touched the drowned bell together. The Guild took her in on the spot.",
				},
				lose = {
					fortitude = { -12, -6 },
					sanity = -2,
					clearFlags = { "elder_apprentice" },
					log = "Halfway down your old lungs gave out, and it was Tamsin who brought you up. The Guild took her in for it, and she visited you every week.",
					cause = "Lost on a dive with an apprentice",
				},
			},
			{
				label = "Tell her not to go",
				result = {
					sanity = -3,
					clearFlags = { "elder_apprentice" },
					log = "You told Tamsin the Mere wasn't worth it. She went anyway, and passed, and took a long while to forgive you.",
				},
			},
		},
	},

	-- Family, friends and old rivals -----------------------------------------
	{
		id = "elder2_heirloom",
		title = "Everything on the Blanket",
		text = "{child} has come up the stairs to help you sort your things, and the two of you have spent the whole afternoon not saying why. Everything you own is spread across the bed; a whole life, it turns out, fits on one blanket. {child} keeps picking things up and setting them down very gently, as if they might break, or as if you might.",
		once = true,
		tags = { "elder", "family", "child", "legacy" },
		when = { minAge = 58, hasRelation = "child" },
		choices = {
			{
				label = "Promise them what you carry",
				hint = "Needs something worth passing on.",
				requires = {
					hasGear = {
						"dock_knife",
						"hook_pole",
						"pocket_ledger",
						"tide_tables",
						"diving_lamp",
						"oilskin",
						"dock_jacket",
						"company_greatcoat",
						"still_stone",
						"little_bell",
						"lantern_token",
					},
				},
				result = {
					sanity = 4,
					relationBond = { kind = "child", amount = 10 },
					log = "You told {child} that everything you carried would be theirs when you were done with it. They made you promise twice.",
				},
			},
			{
				label = "Write down the family stories",
				result = {
					temperance = 2,
					sanity = 4,
					relationBond = { kind = "child", amount = 8 },
					log = "You wrote down every family story you could remember, the true ones and the better ones, and gave {child} the book.",
				},
			},
			{
				label = "Tell them to take whatever they like",
				result = {
					prudence = 1,
					sanity = 2,
					relationBond = { kind = "child", amount = 6 },
					log = "You told {child} to take whatever they liked. They took a chipped cup you'd forgotten you owned, and wouldn't say why.",
				},
			},
			{
				label = "Put it all back in the drawer",
				result = {
					sanity = -2,
					relationBond = { kind = "child", amount = -3 },
					log = "You put everything back in the drawer and made tea instead. {child} let you, which was its own kind of kindness.",
				},
			},
		},
	},
	{
		id = "elder2_old_friend",
		title = "Every Tram in Undermere",
		text = "{friend} turns up at your door in their good coat with a fistful of tram tickets and a bag of hot buns. \"We're going to see all of it,\" they announce, \"while we can still argue about the way.\" Every Ward, every line, one tram after another until the rails run out. Your knees have opinions about this.",
		once = true,
		tags = { "elder", "friend" },
		when = { minAge = 60, hasRelation = "friend" },
		choices = {
			{
				label = "Ride every line",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "A whole day of trams and stairs", coins = 2, base = 4, coinPower = 3 },
				win = {
					prudence = 1,
					sanity = 7,
					relationBond = { kind = "friend", amount = 10 },
					log = "You and {friend} rode every tram line in Undermere in a single day and argued at every stop. It was the best day in years.",
				},
				lose = {
					fortitude = { -6, -3 },
					sanity = 3,
					relationBond = { kind = "friend", amount = 8 },
					log = "Your knees gave out before the fourth Ward. {friend} bought you a bun, and you watched the trams go by instead, which was nearly as good.",
					cause = "Worn out on a long day out",
				},
			},
			{
				label = "Ride to the end of your own line",
				result = { sanity = 4, relationBond = { kind = "friend", amount = 6 }, log = "You rode to the end of your own line and back with {friend} and talked about everyone you had both outlived." },
			},
			{
				label = "Stay in, and hear about it after",
				result = { sanity = 1, relationBond = { kind = "friend", amount = 2 }, log = "You stayed home. {friend} went alone and came back at dusk with a story from every Ward, most of them improved." },
			},
		},
	},
	{
		id = "elder2_rival_sends",
		title = "A Message from {rival}",
		text = "A boy brings a message up your stairs: {rival} is very ill in a room on the Terraces and has asked for you, by name. The two of you haven't spoken in years, except to win arguments. The boy waits on the landing with his cap in his hand, and you find, to your surprise, that your coat is already on.",
		once = true,
		tags = { "elder", "rival" },
		when = { minAge = 58, hasRelation = "rival" },
		choices = {
			{
				label = "Go, and make your peace",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Forty years of grudges", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 2,
					sanity = 6,
					killRelation = "rival",
					log = "You sat at your old rival's bedside and said the true things at last. They laughed, squeezed your hand, and were gone by morning.",
				},
				lose = {
					sanity = -3,
					killRelation = "rival",
					log = "You meant to make peace, and instead you had the old argument one last time. You were glad of it, later, which surprised you.",
				},
			},
			{
				label = "Go, and win one last argument",
				result = { prudence = 1, sanity = 3, killRelation = "rival", log = "You argued about the old days until the lamp burned down. You won, and you suspected they let you." },
			},
			{
				label = "Send the boy back with a note",
				result = { sanity = -2, killRelation = "rival", log = "You sent a note instead. The boy brought back an answer of one word, and you kept it in your coat for the rest of your life." },
			},
		},
	},

	-- Work's end -------------------------------------------------------------
	{
		id = "elder2_retirement",
		title = "They Give You a Clock",
		text = "After all these years, the bosses have decided it's time. There is a small ceremony at the end of the shift: a speech that gets your name nearly right, a cake with one corner already cut, and a brass carriage clock with a plaque. Somebody young is already standing at your old place, holding your tools wrong.",
		once = true,
		tags = { "elder", "career" },
		when = { minAge = 60, career = { "company", "stoker", "sluice" } },
		choices = {
			{
				label = "Take the clock and go",
				result = {
					paycheck = 0.5,
					sanity = 4,
					quitCareer = true,
					log = "You took the clock, the cake and a purse of half a year's pay, and walked home through the evening rush with nowhere to be.",
				},
			},
			{
				label = "Stay a season to train the young one",
				result = {
					paycheck = 0.25,
					temperance = 2,
					sanity = 3,
					quitCareer = true,
					log = "You stayed one more season to show the young one where everything was, and why. Then you took the clock home.",
				},
			},
			{
				label = "Refuse to go",
				hint = "Fortitude clash, medium-hard.",
				clash = { stat = "fortitude", foe = "The young ones at your old post", coins = 2, base = 5, coinPower = 3 },
				win = { justice = 2, sanity = 2, log = "You refused the clock and outworked the young ones for another year, out of spite and habit." },
				lose = {
					fortitude = { -6, -3 },
					sanity = -3,
					quitCareer = true,
					log = "You tried to keep up for one more season and went down at your post. They brought the clock to your sickbed.",
					cause = "Worked too long",
				},
			},
		},
	},
	{
		id = "elder2_pumpside_hand_talk",
		title = "Hand-Talk",
		text = "Forty years of the great pumps have taken most of your hearing, as they take everyone's in Pumpside, and like the rest of the old ones you talk with your hands now: the stokers' hand-talk, quick and wry and beautiful. The children on your stair can't follow it. They watch the old people laughing at the tram stop in perfect silence and look at you as if you're keeping a secret.",
		once = true,
		tags = { "elder", "pumpside", "mentor" },
		when = { district = "pumpside", minAge = 58 },
		choices = {
			{
				label = "Teach the children the hand-talk",
				result = { temperance = 1, sanity = 5, log = "You taught the children on your stair the old hand-talk, jokes first, as tradition demanded. Soon the whole landing was silent and laughing." },
			},
			{
				label = "Teach it to the new Ash Hands",
				result = { wage = { 10, 20 }, temperance = 2, log = "The Boilermakers paid you to teach hand-talk to the new Ash Hands, who would need it sooner than they knew." },
			},
			{
				label = "Speak for an old stoker at a hearing",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The Boilermakers' hearing", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 3, log = "You stood beside an old stoker at a Charter hearing and turned his hands into words, and he kept his pension." },
				lose = { sanity = -3, log = "You turned his hands into words as fast as you could, and the hearing listened politely and ruled against him anyway." },
			},
			{
				label = "Keep it among the old ones",
				result = { prudence = 1, sanity = 1, log = "You kept the hand-talk among the old ones. Some secrets are all that's left of a place." },
			},
		},
	},

	-- Frailty and memory -----------------------------------------------------
	{
		id = "elder2_kitchen_floor",
		title = "On the Kitchen Floor",
		text = "You don't remember falling, only the floor arriving, cold and close. Your hip is a bright, hot shout. The kettle is still whistling on the stove above you, and the pipe that runs through the wall to next door is just within reach, if you stretch.",
		cooldown = 6,
		tags = { "elder", "frailty" },
		when = { minAge = 64 },
		choices = {
			{
				label = "Bang on the pipe",
				result = {
					fortitude = { -4, -2 },
					sanity = 1,
					log = "You banged on the pipe with a spoon until the neighbor's boy burst through the door and ran for the stitcher.",
					cause = "A fall at home",
				},
			},
			{
				label = "Pull yourself up by the table leg",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "Your own two legs", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = 1, prudence = 1, sanity = 3, log = "You hauled yourself up by the table leg, took the kettle off, and sat down to shake with some dignity." },
				lose = {
					fortitude = { -8, -4 },
					sanity = -3,
					condition = "broken_arm",
					log = "The table tipped as you pulled on it. You lay there until morning with your wrist broken under you and the kettle boiled dry.",
					cause = "A fall at home",
				},
			},
			{
				label = "Lie still and wait",
				result = {
					fortitude = { -3, -1 },
					sanity = -4,
					log = "You lay still and counted tram bells until the neighbor wondered why the kettle hadn't stopped, and came to see.",
					cause = "A fall at home",
				},
			},
		},
	},
	{
		id = "elder2_lost_name",
		title = "The Name That Won't Come",
		text = "Halfway through a story on the landing, you reach for the name of someone you knew for forty years, someone who stood beside you through the worst High Water you ever saw, and it isn't there. You can see their face perfectly. You can hear their laugh. The children on your step are waiting for the end of the story.",
		once = true,
		tags = { "elder", "memory" },
		when = { minAge = 62 },
		choices = {
			{
				label = "Start a book of names",
				result = { prudence = 2, sanity = 3, log = "You bought a little ledger and began writing down every name you could still find, a few each night, with a line about each." },
			},
			{
				label = "Laugh, and give them a better name",
				result = { temperance = 1, sanity = 4, log = "You laughed, gave the children a splendid made-up name, and finished the story. They liked the new name better." },
			},
			{
				label = "Sit by the water until it comes back",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The dark water of memory", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 3, sanity = 5, log = "You sat by the water until the name floated up again on its own, and you said it out loud to the Mere so it would stay." },
				lose = { sanity = -5, log = "You sat by the water until dark, and the name stayed down. You never did find it again." },
			},
		},
	},
	{
		id = "elder2_tide_teacher",
		title = "Under the Pier",
		text = "A boy of twelve is crouched under the pier where you swim at dusk, holding his throat with both hands. You know the look: two pale lines opening at his neck, his breath going slow, the whole of the Gutters suddenly on the far side of something. Up on the stairs his family is calling his name. He hasn't answered.",
		once = true,
		tags = { "elder", "tidetouched", "strange", "mentor" },
		when = { minAge = 56, form = "tidetouched" },
		choices = {
			{
				label = "Take him down to see the green light",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The deep water, with a frightened boy", coins = 2, base = 4, coinPower = 3 },
				win = {
					prudence = 2,
					sanity = 6,
					addRelation = { kind = "friend", bond = 55, age = 12 },
					log = "You took {newRelation} down into the green light over the drowned rooftops, and he came up laughing for the first time in weeks.",
				},
				lose = { sanity = -3, log = "He panicked in the deep water and kicked for the surface. You got him up safely, but he wouldn't come near the water again for a year." },
			},
			{
				label = "Walk him up to his family",
				result = { justice = 2, sanity = 3, log = "You walked him up the stairs to his family and told them everything you wished someone had told yours. His mother listened to all of it." },
			},
			{
				label = "Show him the old greeting",
				result = { prudence = 1, sanity = 3, log = "You touched two fingers to your own throat, the old greeting. After a long moment, he did it back." },
			},
		},
	},

	-- Legacy and the long view -------------------------------------------------
	{
		id = "elder2_last_wishes",
		title = "Putting It in Writing",
		text = "A Sluice notary has come up to your rooms with a folding writing desk and a bored expression to take down your last wishes. He charges by the line. Your savings are in a tin under the floor, your few good things are in a drawer, and the notary has dipped his pen and is waiting for you to begin.",
		once = true,
		tags = { "elder", "legacy", "money" },
		when = { minAge = 62 },
		choices = {
			{
				label = "Leave everything to your family",
				hint = "Needs family.",
				requires = { hasRelation = { "child", "sibling" } },
				result = {
					money = -5,
					sanity = 3,
					relationBond = { kind = "family", amount = 6 },
					log = "You left everything to your family in plain words, four lines long, and paid the notary for every one.",
				},
			},
			{
				label = "Pay a share to the Foundling Steps now",
				hint = "100 scrip.",
				requires = { min = { money = 100 } },
				result = {
					money = -100,
					justice = 4,
					sanity = 4,
					log = "You paid a hundred {currency} to the Foundling Steps on the spot, so nobody could argue about it later. The notary looked almost moved.",
				},
			},
			{
				label = "Spend your lines on Lantern Night",
				result = { money = -3, prudence = 2, sanity = 2, log = "You spent your lines on Lantern Night instead: which paper, which pier, and who was to light it." },
			},
			{
				label = "Send the notary away",
				result = { sanity = 1, log = "You sent the notary away. Whoever found the tin could decide for themselves, and good luck to them." },
			},
		},
	},
	{
		id = "elder2_crater_lip",
		title = "From the Crater's Lip",
		text = "For the first time in years you climb, slowly, all the way up the Bellhollow public stair to the lookout at the crater's lip, the one place on the Rim where the gates never close. Below you the whole of Undermere falls away: ten Wards like the slices of a pie, the Terraces, the Silt, and the black Mere breathing in the middle. A young stranger leaning on the wall beside you asks which Ward is yours.",
		once = true,
		tags = { "elder", "memory" },
		when = { minAge = 60 },
		choices = {
			{
				label = "Point out everywhere you've lived",
				result = { prudence = 1, sanity = 5, log = "You pointed out every place you had ever lived, and the stranger listened to all of it, which you hadn't expected." },
			},
			{
				label = "Point out what used to be there",
				result = {
					temperance = 2,
					sanity = 3,
					log = "You pointed out everything that used to be there: the old ferry, the market before the fire, the street the Mere took. The stranger wrote some of it down.",
				},
			},
			{
				label = "Say nothing, and just look",
				result = { prudence = 2, sanity = 4, log = "You didn't answer. You just looked, for a long time, until the lamps came on in all ten Wards at once." },
			},
		},
	},
}
