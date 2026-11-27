--[[
	Story arcs, part 2 (prefix ar_). Same rules as Story_Arcs.luau: a childhood hook, then
	weight-0 follow-ups reached by `schedule` (and one `trigger`), keyed on the arc's own
	flags. Ending flags are ar_<arc>_end_<how>. Cast: Cast/Arcs.luau.

	Chalk Faces (ar_ch_)         7-10 Pia draws everyone on the street, old. A Student of
	                                  the Ring notices at 15. Payoff 22-25: Pia paints shop
	                                  signs, becomes a Maestro, or you take the smock.
	Little Brother (ar_md_)      6-10 A tattooed man brings your father cake (he paid for
	                                  your fever). At 14 the Middle wants its favor; letting
	                                  your father go costs his life. Payoff 21-25: join the
	                                  family, get struck from the Book, or stay in it.
	A Name on the Tang (ar_bl_)  7-10 Tibor's first blade carries your name. It's sold for
	                                  rent, and a Fixer makes the name famous. Payoff 22-25:
	                                  the blade, the forge, or both blades on his wall.
	Three Red Stamps (ar_hx_)    4-8  Your mother's Hana card, FAILED three times. At 16 the
	                                  same examiner sets you the same practical, the same
	                                  debtor. Payoff 16-22: licensed, released, or failed.
]]

-- Little Brother: both versions of the favor (father alive / father gone) are scheduled;
-- whichever `when` fits plays. They share their outcomes.
local function favor()
	return { { event = "ar_md_favor", inYears = 5 }, { event = "ar_md_alone", inYears = 5 } }
end
local function corner()
	return { stat = "strength", foe = "Men who want the door", coins = 1, base = 3, coinPower = 2, fight = true, enemy = "thug" }
end
local function cornerWin()
	return {
		strength = 3,
		setFlags = { "ar_md_kept", "knows_middle" },
		schedule = { event = "ar_md_good", inYears = 3 },
		log = "Two men wanted the door, and neither got it. You ran home at 2:58, and Lasse was waiting on your step with a cake.",
	}
end
local function cornerLose()
	return {
		health = { -8, -4 },
		sanity = -5,
		setFlags = { "ar_md_owed", "knows_middle" },
		schedule = { event = "ar_md_bad", inYears = 3 },
		log = "Somebody got through the door. You got home at 3:05 through a window, shaking, and Lasse said nothing at all.",
		cause = "Stood a corner for the Middle",
	}
end
local function paidLasse()
	return {
		money = -60,
		setFlags = { "ar_md_kept", "knows_middle" },
		schedule = { event = "ar_md_good", inYears = 3 },
		log = "Lasse looked at the notes as if you'd spat on the table, then took them. \"Money is how strangers pay,\" he said.",
	}
end
local function refusedLasse()
	return {
		strength = 2,
		sanity = -3,
		setFlags = { "ar_md_owed", "knows_middle" },
		chronicle = "fn_written_in_book",
		schedule = { event = "ar_md_bad", inYears = 3 },
		log = "Lasse took out a heavy book and wrote your name in it, slowly, like a child learning letters.",
	}
end

-- Three Red Stamps: the practical's outcomes, and the epilogue two years on
local function home()
	return { event = "ar_hx_home", inYears = 2 }
end
local function passedPractical()
	return {
		strength = 3,
		career = "fixer",
		chronicle = "licensed_fixer",
		setFlags = { "ar_hx_end_licensed", "ar_hx_passed" },
		schedule = home(),
		log = "You walked her to the branch through two collectors. Holm stamped your card PASSED without looking up: Grade 9 Fixer.",
	}
end
local function failedPractical()
	return {
		health = { -14, -6 },
		sanity = -5,
		setFlags = { "ar_hx_end_failed", "ar_hx_stamped" },
		schedule = home(),
		log = "The collectors took her their way while you were on the floor. Holm stamped your card FAILED, just once.",
		cause = "Fought Syndicate collectors",
	}
end

return {
	-- ── Chalk Faces ─────────────────────────────────────────────────────────
	{
		id = "ar_ch_chalk",
		title = "Chalk Faces",
		art = "street",
		text = "A girl named Pia draws faces on the pavement outside the noodle stall with stolen chalk. Every face belongs to somebody on the street, and every one is right.",
		weight = 11,
		once = true,
		when = { minAge = 7, maxAge = 10 },
		dialogue = {
			{ who = "ar_pia", line = "Sit. Don't smile, smiling's hard. You've got a sad nose, did you know?" },
			{ who = "ar_pia", line = "I'm doing you old. Everybody wants to see themselves old. Nobody says thanks after." },
		},
		choices = {
			{
				label = "Sit very still",
				clash = { stat = "intelligence", foe = "An itch on your nose", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					intelligence = 2,
					sanity = 2,
					setFlags = { "ar_ch_on" },
					schedule = { event = "ar_ch_wall", inYears = 3 },
					log = "She drew you at sixty, tired around the eyes. You looked at it a long time, and when it rained that night you were glad.",
				},
				lose = {
					sanity = -3,
					setFlags = { "ar_ch_on" },
					schedule = { event = "ar_ch_wall", inYears = 3 },
					log = "You sneezed. She drew you sneezing, at sixty, and said it was the truest one she'd done all week.",
				},
			},
			{
				label = "Ask her to draw someone gone",
				result = {
					mind = 1,
					sanity = -2,
					setFlags = { "ar_ch_on" },
					schedule = { event = "ar_ch_wall", inYears = 3 },
					log = "You described a face you missed. She drew it from your words and got the ears wrong, and you didn't tell her.",
				},
			},
			{
				label = "Swipe her chalk from the academy",
				result = {
					strength = 1,
					sanity = 1,
					setFlags = { "ar_ch_on" },
					schedule = { event = "ar_ch_wall", inYears = 3 },
					log = "You brought her a whole box and she held it like a weapon. \"Now I can do the whole street,\" she said, and did.",
				},
			},
		},
	},
	{
		id = "ar_ch_wall",
		title = "Washing Day",
		art = "alley",
		text = "Pia has covered the whole alley wall with faces. The laundry boys are filling buckets to wash them off, because one of the faces is one of them, crying.",
		weight = 0,
		when = { flags = { "ar_ch_on" } },
		dialogue = {
			{ who = "bully", line = "I don't cry. That's not me. Wash it." },
			{ who = "ar_pia", line = "It's you on Tuesday. I was there on Tuesday." },
		},
		choices = {
			{
				label = "Kick over their buckets",
				clash = { stat = "strength", foe = "Laundry boys with buckets", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "bully" },
				win = {
					strength = 2,
					schedule = { event = "ar_ch_student", inYears = 5 },
					log = "Four buckets went down the drain. The crying face stayed up all summer, and the boy it was walked the long way round it.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -3,
					schedule = { event = "ar_ch_student", inYears = 5 },
					log = "They soaked you and the wall. Next morning Pia drew it all again, plus you, soaked and furious.",
				},
			},
			{
				label = "Hold a tarp over the wall",
				clash = { stat = "health", foe = "Four buckets of grey water", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					health = 2,
					sanity = 1,
					schedule = { event = "ar_ch_student", inYears = 5 },
					log = "You held the tarp until their arms gave out. The faces stayed, and Pia added a new one: you, holding a tarp.",
				},
				lose = {
					sanity = -3,
					schedule = { event = "ar_ch_student", inYears = 5 },
					log = "The tarp tore. Pia didn't cry; she started the wall over at the bottom left corner.",
				},
			},
			{
				label = "Ask Pia to draw him laughing",
				result = {
					mind = 1,
					schedule = { event = "ar_ch_student", inYears = 5 },
					log = "She drew him laughing. He stood in front of it a long time, and then washed it off himself, very carefully.",
				},
			},
		},
	},
	{
		id = "ar_ch_student",
		title = "A Student of the Ring",
		art = "market",
		text = "Someone in a paint-stiff smock has watched Pia draw at the market for three days. Today he crouches over her chalk face of you and studies it like a doctor reading a chart.",
		weight = 0,
		when = { flags = { "ar_ch_on" } },
		codex = "fn_lore_ring",
		dialogue = {
			{ who = "ring_artist", line = "She draws what's under the face. Most people only manage the face." },
			{ who = "ring_artist", line = "I'm a Student of the Ring. Yes, the Finger. My Docent would like to see more. Of her, and of you." },
			{ who = "ar_pia_grown", line = "A real gallery. With walls. Nobody washes walls in a gallery." },
		},
		choices = {
			{
				label = "Tear up his card",
				result = {
					strength = 1,
					sanity = -2,
					setFlags = { "knows_ring", "knows_fingers" },
					schedule = { event = "ar_ch_gallery", inYears = 3 },
					log = "You tore it in half. He smiled and gave Pia another from a whole pocketful.",
				},
			},
			{
				label = "Ask what the Ring makes",
				clash = { stat = "mind", foe = "A Student's sales pitch", coins = 1, base = 3, coinPower = 2 },
				win = {
					mind = 3,
					setFlags = { "knows_ring", "knows_fingers" },
					schedule = { event = "ar_ch_gallery", inYears = 3 },
					log = "\"Studies,\" he said, \"of people who hold still for a very long time.\" You understood enough, and Pia didn't want to.",
				},
				lose = {
					sanity = -4,
					setFlags = { "knows_ring", "knows_fingers" },
					schedule = { event = "ar_ch_gallery", inYears = 3 },
					log = "\"Art,\" he said, and that was all you got. Pia was already holding his card in both hands.",
				},
			},
			{
				label = "Tell Pia to go",
				result = {
					sanity = 1,
					setFlags = { "knows_ring", "knows_fingers" },
					schedule = { event = "ar_ch_gallery", inYears = 3 },
					log = "You told her to go. She hugged you so hard that the chalk broke in her pocket.",
				},
			},
		},
	},
	{
		id = "ar_ch_gallery",
		title = "The Unveiling",
		art = "hall",
		text = "Pia's first show is in a Ring gallery: forty mannequins, one for each face on your old street. The forty-first is blank, and exactly your height.",
		weight = 0,
		when = { flags = { "ar_ch_on" } },
		dialogue = {
			{ who = "ar_lisandro", line = "She's very good. She needs one living study. A year, holding still. We pay well." },
			{ who = "ar_pia_grown", line = "It's only sitting. You used to sit for chalk. Please. They'll let me stay if you do." },
		},
		choices = {
			{
				label = "Sit for the year",
				result = {
					money = { 150, 300 },
					mind = 2,
					sanity = -8,
					setFlags = { "ar_ch_ring" },
					schedule = { event = "ar_ch_maestro", inYears = 4 },
					log = "You held still for a year in a white room. Pia drew you every day, and she stopped talking to you around March.",
				},
			},
			{
				label = "Walk Pia out of there",
				clash = { stat = "strength", foe = "The Docent's Students", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "ring_artist" },
				win = {
					strength = 3,
					setFlags = { "ar_ch_out" },
					schedule = { event = "ar_ch_signs", inYears = 4 },
					log = "You walked Pia out past forty mannequins of your street. The Docent only applauded, which was worse.",
				},
				lose = {
					health = { -14, -6 },
					sanity = -6,
					setFlags = { "ar_ch_ring" },
					schedule = { event = "ar_ch_maestro", inYears = 4 },
					log = "You woke on the gallery steps. Through the door you could see the forty-first mannequin, and it had a face now.",
					cause = "Thrown out of a Ring gallery",
				},
			},
			{
				label = "Leave her to it",
				result = {
					sanity = -4,
					setFlags = { "ar_ch_end_left" },
					log = "You left her among the mannequins. On the way out you passed your own face, unfinished, on a plinth.",
				},
			},
		},
	},
	{
		id = "ar_ch_signs",
		title = "Two Ahn a Letter",
		art = "street",
		text = "Pia paints shop signs now, two Ahn a letter. On the anniversary of the gallery she chalks your face outside the noodle stall again, old, the way she first did.",
		weight = 0,
		when = { flags = { "ar_ch_out" } },
		dialogue = {
			{ who = "ar_pia_grown", line = "You've nearly caught up with the drawing. Sad nose and everything." },
			{ who = "ar_pia_grown", line = "The Ring still writes. They say I'm wasting a gift. I say I'm wasting it on purpose." },
		},
		choices = {
			{
				label = "Sit for her one more time",
				result = {
					sanity = 6,
					setFlags = { "ar_ch_end_free" },
					addRelation = { kind = "friend", name = "Pia", bond = 75, age = { 22, 26 } },
					log = "You sat until the chalk ran out. It rained that night, and in the morning she drew it again.",
				},
			},
			{
				label = "Hire her to paint your door",
				hint = "20 Ahn",
				requires = { min = { money = 20 } },
				result = {
					money = -20,
					sanity = 4,
					setFlags = { "ar_ch_end_free" },
					addRelation = { kind = "friend", name = "Pia", bond = 70, age = { 22, 26 } },
					log = "She painted {first} over your door, with a tiny sad nose hidden in the curl of one letter.",
				},
			},
		},
	},
	{
		id = "ar_ch_maestro",
		title = "Maestro",
		art = "hall",
		text = "A card in white ink: Pia has founded a movement of her own. Her first gallery is one room with one mannequin in it, and it's you, at sixty.",
		weight = 0,
		when = { flags = { "ar_ch_ring" } },
		dialogue = {
			{ who = "ar_pia_grown", line = "Maestro Pia. They let me name the movement. I called it Sad Nose. Nobody laughed." },
			{ who = "ar_pia_grown", line = "Stand next to it. I want to see which of you is right." },
		},
		choices = {
			{
				label = "Stand next to it",
				result = {
					mind = 3,
					sanity = -4,
					setFlags = { "ar_ch_end_maestro" },
					log = "You stood beside yourself at sixty for an hour while people in masks took notes. Pia cried at the back, quietly, for the art.",
				},
			},
			{
				label = "Ask her to come home",
				clash = { stat = "mind", foe = "A Maestro's conviction", coins = 3, base = 5, coinPower = 3 },
				win = {
					mind = 2,
					sanity = 6,
					setFlags = { "ar_ch_end_free" },
					addRelation = { kind = "friend", name = "Pia", bond = 70, age = { 22, 26 } },
					log = "She locked the gallery at sundown and came to the noodle stall in her smock. She drew the cook, and it was right.",
				},
				lose = {
					sanity = -6,
					setFlags = { "ar_ch_end_maestro" },
					log = "\"This is home,\" she said, and meant the white room. She sent you the mannequin's left hand as a keepsake.",
				},
			},
			{
				label = "Become her Student",
				hint = "Join the Ring.",
				result = {
					sanity = -3,
					career = "ring",
					setFlags = { "ar_ch_end_student" },
					log = "You put on the smock. She taught you to draw what's under the face, and you stopped sleeping well.",
				},
			},
		},
	},

	-- ── Little Brother ──────────────────────────────────────────────────────
	{
		id = "ar_md_cake",
		title = "Cake on a Tuesday",
		art = "home",
		text = "A man with tattooed knuckles brings {father} a cake and calls him Little Brother, though they aren't brothers. {father} thanks him in a voice you've never heard him use.",
		weight = 11,
		once = true,
		when = { side = "backstreets", minAge = 6, maxAge = 10, hasRelation = "father" },
		dialogue = {
			{ who = "ar_lasse", line = "This is the one? The clinic one? Look at that. Worth every Ahn." },
			{ who = "ar_lasse", line = "Eat, little one. In the family, cake is a promise. Ask your father." },
			{ who = "{father}", line = "Say thank you to Brother Lasse. Then go to your room." },
		},
		choices = {
			{
				label = "Eat the cake",
				result = {
					health = 1,
					sanity = 2,
					setFlags = { "ar_md_on" },
					schedule = { event = "ar_md_notebook", inYears = 3 },
					log = "It was the best cake you'd ever had. {father} didn't touch his slice, and left it on the windowsill like an offering.",
				},
			},
			{
				label = "Ask what \"the clinic one\" means",
				result = {
					mind = 1,
					sanity = -2,
					setFlags = { "ar_md_on" },
					schedule = { event = "ar_md_notebook", inYears = 3 },
					log = "\"You had a fever as a baby. Clinics cost money, and family doesn't,\" {father} said, and cut the cake very small.",
				},
			},
			{
				label = "Go to your room",
				result = {
					sanity = -1,
					setFlags = { "ar_md_on" },
					schedule = { event = "ar_md_notebook", inYears = 3 },
					log = "Through the door you heard them both laugh, then only Lasse. The cake went stale on the table.",
				},
			},
		},
	},
	{
		id = "ar_md_notebook",
		title = "The Little Book",
		art = "school",
		text = "Jory, Brother Lasse's son, carries a notebook with BOOK OF VENGEANCE written on the cover in marker. Today he writes your name in it, because you sat in his seat.",
		weight = 0,
		when = { flags = { "ar_md_on" } },
		dialogue = {
			{ who = "ar_jory", line = "The family remembers. My dad says. So I remember. You're in the book now." },
			{ who = "ar_jory", line = "Unless you pay. Lunch, for a week. That's how family works." },
		},
		choices = {
			{
				label = "Take the book off him",
				clash = { stat = "strength", foe = "Jory and his book", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = {
					strength = 2,
					schedule = favor(),
					log = "You got the book and crossed yourself out in red. Jory cried, then wrote you back in at home, bigger.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -3,
					schedule = favor(),
					log = "He kept the book and underlined your name twice. At recess everyone called you the Indebted.",
				},
			},
			{
				label = "Pay him a week of lunches",
				result = {
					health = -1,
					mind = 2,
					schedule = favor(),
					log = "A week of lunches. He crossed you out neatly and wrote PAID, and was very fair about it, which was the frightening part.",
				},
			},
			{
				label = "Start a book of your own",
				result = {
					strength = 1,
					sanity = 2,
					setFlags = { "ar_md_book" },
					schedule = favor(),
					log = "You wrote JORY on the first page of a notebook of your own. You were in each other's books for six years.",
				},
			},
		},
	},
	{
		id = "ar_md_favor",
		title = "The Favor",
		art = "home",
		text = "Brother Lasse is back after eight years, without a cake, because the Middle needs a favor. {father} sits very straight at the table and doesn't look at you.",
		weight = 0,
		when = { flags = { "ar_md_on" }, hasRelation = "father" },
		codex = "fn_lore_middle",
		dialogue = {
			{ who = "ar_lasse", line = "A corner on Pig-iron Street, two until five to three. Nobody goes in the door behind you." },
			{ who = "ar_lasse", line = "That's all. A man stands at a corner. The Middle remembers a man who stands." },
			{ who = "{father}", line = "I'll go. I'll be home by 2:55. Don't look at the kid, Lasse. I said I'll go." },
		},
		choices = {
			{ label = "Go in his place", clash = corner(), win = cornerWin(), lose = cornerLose() },
			{
				label = "Let him go",
				result = {
					sanity = -8,
					killRelation = "father",
					setFlags = { "ar_md_lost", "knows_middle" },
					schedule = { event = "ar_md_owes_you", inYears = 3 },
					log = "You waited by the door with your shoes on. At 2:56 someone knocked three times, and it was Lasse, holding his hat.",
				},
			},
			{ label = "Pay Lasse instead", hint = "60 Ahn", requires = { min = { money = 60 } }, result = paidLasse() },
			{ label = "Say the family can't have him", result = refusedLasse() },
		},
	},
	{
		id = "ar_md_alone",
		title = "Inheritance",
		art = "home",
		text = "Brother Lasse is back after eight years, without a cake. Your father is gone, and the Middle has come about his debt.",
		weight = 0,
		when = { flags = { "ar_md_on" }, noRelation = "father" },
		codex = "fn_lore_middle",
		dialogue = {
			{ who = "ar_lasse", line = "He owed a corner. One night at a corner. Now you owe it. That's inheritance, little one." },
			{ who = "ar_lasse", line = "Pig-iron Street, two until five to three. Nobody goes in the door behind you." },
		},
		choices = {
			{ label = "Stand the corner", clash = corner(), win = cornerWin(), lose = cornerLose() },
			{ label = "Pay Lasse instead", hint = "60 Ahn", requires = { min = { money = 60 } }, result = paidLasse() },
			{ label = "Say you owe him nothing", result = refusedLasse() },
		},
	},
	{
		id = "ar_md_good",
		title = "The Good Column",
		art = "home",
		text = "Jory is a Little Brother of the Middle now, with his father's knuckles. He comes up your stairs with a cake and a little book, the real kind, held shut.",
		weight = 0,
		when = { flags = { "ar_md_kept" } },
		dialogue = {
			{ who = "ar_jory_grown", line = "You kept your word. The family wrote it down, in the good column." },
			{ who = "ar_jory_grown", line = "Big Sister Halla wants you. Family, properly, tattoo and everything. I said I'd ask nicely." },
		},
		choices = {
			{
				label = "Take the tattoo",
				hint = "Join the Middle.",
				result = {
					sanity = 2,
					career = "middle",
					setFlags = { "ar_md_end_family" },
					log = "Halla did the tattoo herself, between your knuckles. \"Little Sibling,\" she said, and from then on everyone did.",
				},
			},
			{
				label = "Eat the cake and say no",
				clash = { stat = "mind", foe = "The family's feelings", coins = 2, base = 4, coinPower = 3 },
				win = {
					mind = 3,
					sanity = 3,
					setFlags = { "ar_md_end_free" },
					log = "Jory crossed something out and wrote SQUARE. \"Family anyway,\" he said, and took the rest of the cake home.",
				},
				lose = {
					sanity = -5,
					schedule = { event = "ar_md_halla", inYears = 4 },
					log = "Jory went quiet and wrote something small in the other column. \"Big Sister will want to talk,\" he said.",
				},
			},
			{
				label = "Show him your old notebook",
				requires = { flags = { "ar_md_book" } },
				result = {
					sanity = 5,
					setFlags = { "ar_md_end_free" },
					log = "He laughed until he had to sit on your stairs. He crossed his name out of your book, and you crossed yours out of his.",
				},
			},
		},
	},
	{
		id = "ar_md_bad",
		title = "Line Forty-One",
		art = "home",
		text = "Jory is a Little Brother of the Middle now. He comes up your stairs with two more Little Siblings behind him and a heavy book, open at your page.",
		weight = 0,
		when = { flags = { "ar_md_owed" } },
		codex = "fn_lore_book",
		dialogue = {
			{ who = "ar_jory_grown", line = "Line forty-one. A favor not kept. The family remembers. I'm sorry. I'm not." },
			{ who = "middle_sibling", line = "Pay in kind, sibling. We don't take Ahn from people in the book." },
		},
		choices = {
			{
				label = "Fight them on the stairs",
				clash = { stat = "strength", foe = "Three Little Siblings", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "middle_sibling" },
				win = {
					strength = 3,
					sanity = -2,
					schedule = { event = "ar_md_halla", inYears = 4 },
					log = "Three Little Siblings went down your stairs faster than they came up. Jory picked up the book and said, \"That goes in too.\"",
				},
				lose = {
					health = { -16, -8 },
					sanity = -6,
					schedule = { event = "ar_md_halla", inYears = 4 },
					log = "They were thorough, and polite about it. Jory wrote ONE INSTALLMENT and left a cake on the step.",
					cause = "Collected by the Middle",
				},
			},
			{
				label = "Stand the corner for a month",
				clash = { stat = "health", foe = "Thirty nights on Pig-iron Street", coins = 2, base = 4, coinPower = 3 },
				win = {
					health = 3,
					setFlags = { "ar_md_end_free" },
					chronicle = "fn_struck_from_book",
					log = "Thirty nights, two until five to three. On the last one Jory struck your line out in front of you.",
				},
				lose = {
					health = { -8, -4 },
					sanity = -5,
					schedule = { event = "ar_md_halla", inYears = 4 },
					log = "On the ninth night somebody got through the door. The family wrote that down too.",
				},
			},
			{
				label = "Ask to see their Big Sister",
				result = {
					mind = 2,
					schedule = { event = "ar_md_halla", inYears = 4 },
					log = "\"Bold,\" said Jory, shutting the book. \"She'll see you, but the Middle is never soon.\"",
				},
			},
		},
	},
	{
		id = "ar_md_owes_you",
		title = "The Middle Pays Its Debts",
		art = "home",
		text = "Brother Lasse comes up your stairs on the anniversary, alone, with the heavy book under his arm. He opens it at a page with his own name on it.",
		weight = 0,
		when = { flags = { "ar_md_lost" } },
		dialogue = {
			{ who = "ar_lasse", line = "The family sent your father to a corner, and the corner kept him. So now the family owes." },
			{ who = "ar_lasse", line = "I wrote myself in. Line one. The Middle always pays, in whichever form. Name the form." },
		},
		choices = {
			{
				label = "Take his place in the family",
				hint = "Join the Middle.",
				result = {
					sanity = 2,
					career = "middle",
					setFlags = { "ar_md_end_family" },
					log = "Lasse did the tattoo himself and cried the whole time without stopping work. \"Little Sibling,\" he said.",
				},
			},
			{
				label = "Make him pay in Ahn",
				result = {
					money = { 250, 300 },
					sanity = -4,
					setFlags = { "ar_md_end_free" },
					log = "He paid in an envelope tied with black ribbon. \"Strangers' money, and you chose it,\" he said.",
				},
			},
			{
				label = "Keep the debt open",
				result = {
					mind = 3,
					sanity = 2,
					setFlags = { "ar_md_end_kept" },
					log = "\"Open, then,\" said Lasse. Every year on that night a cake appeared on your step, and nobody ever bothered your door.",
				},
			},
		},
	},
	{
		id = "ar_md_halla",
		title = "The Middle Remembers",
		art = "syndicate",
		text = "Big Sister Halla keeps her Book of Vengeance on a chain at her hip and her reading glasses on another round her neck. She finds your page without looking.",
		weight = 0,
		when = { flags = { "ar_md_on" } },
		dialogue = {
			{ who = "ar_halla", line = "Little Brother Lasse wrote you in. His son kept you in. That's a great deal of family attention." },
			{ who = "ar_halla", line = "There's a way out of every book. Usually it's the front door, with us." },
		},
		choices = {
			{
				label = "Join the family",
				hint = "Join the Middle.",
				result = {
					sanity = 1,
					career = "middle",
					setFlags = { "ar_md_end_family" },
					log = "Halla tore your page out and handed it to you. \"Family doesn't owe family,\" she said, and did the tattoo herself.",
				},
			},
			{
				label = "Ask her to strike your name",
				clash = { stat = "mind", foe = "A Big Sister's memory", coins = 3, base = 5, coinPower = 3 },
				win = {
					mind = 4,
					sanity = 5,
					setFlags = { "ar_md_end_free" },
					chronicle = "fn_struck_from_book",
					log = "She struck the line with a ruler and blew on the ink. \"Lasse will sulk, so let him,\" she said.",
				},
				lose = {
					sanity = -6,
					setFlags = { "ar_md_end_kept" },
					log = "She closed the book on your page. \"Kept,\" she said, and you have checked over your shoulder every day since.",
				},
			},
			{
				label = "Fight your way out",
				clash = { stat = "strength", foe = "Big Sister Halla", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "middle_big" },
				win = {
					strength = 4,
					setFlags = { "ar_md_end_free" },
					chronicle = "fn_struck_from_book",
					log = "Halla got up off the floor and struck your line herself. \"Nobody's done that in nine years,\" she said, almost proud.",
				},
				lose = {
					health = { -24, -12 },
					sanity = -8,
					setFlags = { "ar_md_end_kept" },
					log = "She didn't hurry. When it was over she wrote one more line under yours, in very small letters.",
					cause = "Fought a Big Sister of the Middle",
				},
			},
		},
	},

	-- ── A Name on the Tang ──────────────────────────────────────────────────
	{
		id = "ar_bl_first",
		title = "Every First Blade",
		art = "workshop",
		text = "Tibor, the apprentice at the Workshop on the corner, lets you sit on an upturned bucket and watch. He's thirteen and making his first blade, which so far is mostly sparks.",
		weight = 11,
		once = true,
		when = { minAge = 7, maxAge = 10 },
		dialogue = {
			{ who = "ar_tibor", line = "Every first blade gets a name scratched on the tang. For luck. Master Grisel says." },
			{ who = "ar_tibor", line = "You're the only one who watches, so it's yours. Spell it. Slow. I'm bad at letters." },
		},
		choices = {
			{
				label = "Spell your name for him",
				result = {
					sanity = 3,
					setFlags = { "ar_bl_on" },
					schedule = { event = "ar_bl_scrap", inYears = 3 },
					log = "He scratched it in crooked capitals. Your name was on a blade, and you thought about it every night for a month.",
				},
			},
			{
				label = "Work the bellows",
				clash = { stat = "intelligence", foe = "A forge that wants more air", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					intelligence = 2,
					setFlags = { "ar_bl_on" },
					schedule = { event = "ar_bl_scrap", inYears = 3 },
					log = "You kept the fire white all afternoon. Master Grisel looked over once and said \"Huh,\" which from Grisel is a medal.",
				},
				lose = {
					sanity = -3,
					setFlags = { "ar_bl_on" },
					schedule = { event = "ar_bl_scrap", inYears = 3 },
					log = "The fire went orange, then red, and Tibor's blade came out wavy. He scratched your name on it anyway.",
				},
			},
			{
				label = "Tell him to use his own name",
				result = {
					mind = 1,
					setFlags = { "ar_bl_on" },
					schedule = { event = "ar_bl_scrap", inYears = 3 },
					log = "\"My name's for my last blade,\" he said, like he'd read it somewhere. He scratched yours on instead.",
				},
			},
		},
	},
	{
		id = "ar_bl_scrap",
		title = "The Scrapyard Dog",
		art = "ruins",
		text = "Grisel can't pay for good steel, so Tibor sends you through the fence of the scrapyard behind the tram depot. There's a cart spring in there, and a dog that has lived on nobody's scraps for years.",
		weight = 0,
		when = { flags = { "ar_bl_on" } },
		dialogue = {
			{ who = "ar_tibor", line = "Leaf spring, long as your arm. Don't look the dog in the eye. Or do. I forget which." },
		},
		choices = {
			{
				label = "Stare the dog down",
				clash = { stat = "strength", foe = "The scrapyard dog", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "beast" },
				win = {
					strength = 2,
					schedule = { event = "ar_bl_sold", inYears = 4 },
					log = "The dog backed off into the tires. You came through the fence with the spring, and Tibor looked at you like you were a Fixer.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -3,
					schedule = { event = "ar_bl_sold", inYears = 4 },
					log = "You came back over the fence with nothing and a torn sleeve. Tibor said he'd remembered: it was the other one.",
				},
			},
			{
				label = "Throw it your lunch",
				result = {
					health = -1,
					sanity = 2,
					schedule = { event = "ar_bl_sold", inYears = 4 },
					log = "The dog took your lunch and let you take the spring. You went back every week with half a lunch, and it never bit.",
				},
			},
			{
				label = "Go over on the crane arm",
				clash = { stat = "health", foe = "A rusted crane arm", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					health = 2,
					schedule = { event = "ar_bl_sold", inYears = 4 },
					log = "You went over on the crane arm and dropped in behind the dog, which never saw you. Tibor had the spring red-hot by dinner.",
				},
				lose = {
					sanity = -3,
					schedule = { event = "ar_bl_sold", inYears = 4 },
					log = "The crane arm groaned and the dog woke up. You went home the long way, with nothing but rust on your hands.",
				},
			},
		},
	},
	{
		id = "ar_bl_sold",
		title = "Sold for the Rent",
		art = "workshop",
		text = "Your blade is gone from its hook: Grisel sold it to a Fixer for the rent. Tibor hasn't spoken to him in three days, and the forge is cold.",
		weight = 0,
		when = { flags = { "ar_bl_on" } },
		codex = "fx_lore_workshops",
		dialogue = {
			{ who = "ar_grisel", line = "Forty Ahn and the lease paid. Fixers buy lucky first blades. It's a whole superstition with them." },
			{ who = "ar_tibor", line = "It had a name on it. You don't sell a name. He sold a name." },
			{ who = "ar_grisel", line = "Names are cheap, boy. Steel's dear. Light the forge." },
		},
		choices = {
			{
				label = "Help Tibor make a better one",
				clash = { stat = "intelligence", foe = "A blade that won't come out straight", coins = 1, base = 3, coinPower = 2 },
				win = {
					intelligence = 3,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_bl_maren", inYears = 4 },
					log = "A month of nights on the bellows, and the second blade came out straight. He didn't name it yet, he said.",
				},
				lose = {
					sanity = -4,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_bl_maren", inYears = 4 },
					log = "It came out wavy and cracked in the quench. Tibor threw it in the scrap bin, and the crack rang all night.",
				},
			},
			{
				label = "Learn where steel cracks",
				requires = { noStyle = true },
				result = {
					strength = 2,
					style = "rupture",
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_bl_maren", inYears = 4 },
					log = "Tibor showed you how a crack runs through steel, and where to hit to open it. You fight like Rupture now: every hit opens the next.",
				},
			},
			{
				label = "Find out which Fixer bought it",
				result = {
					mind = 2,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_bl_maren", inYears = 4 },
					log = "Grisel's ledger said MAREN, GRADE 8. You copied it onto your hand, and it took a week to wash off.",
				},
			},
			{
				label = "Tell Tibor to let it go",
				result = {
					sanity = 1,
					setFlags = { "knows_fixers", "ar_bl_end_let_go" },
					log = "\"It was only a name,\" you said. Tibor lit the forge, and he never scratched a name on anything again.",
				},
			},
		},
	},
	{
		id = "ar_bl_maren",
		title = "Your Name in Her Hand",
		art = "street",
		text = "The Fixer Maren is Grade 6 now, and her blade is famous on three streets. People call it by the name scratched on its tang: {first}.",
		weight = 0,
		when = { flags = { "ar_bl_on" } },
		dialogue = {
			{ who = "ar_maren", line = "{first}? Like my blade? Funny. It's a lucky name. Eleven jobs, never lost one." },
			{ who = "ar_maren", line = "Sell it to the kid it's named for? That's the luckiest thing I ever heard. No." },
		},
		choices = {
			{
				label = "Win it off her in the yard",
				clash = { stat = "strength", foe = "Maren, Grade 6", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "fixer" },
				win = {
					strength = 3,
					setFlags = { "ar_bl_won" },
					schedule = { event = "ar_bl_mark", inYears = 4 },
					log = "She went down in the chalk circle, laughing. \"Lucky name,\" she said, and handed it over hilt first.",
				},
				lose = {
					health = { -14, -6 },
					sanity = -5,
					schedule = { event = "ar_bl_mark", inYears = 4 },
					log = "She beat you with your own name and was very nice about it, which made it so much worse.",
					cause = "Lost a duel to a Fixer",
				},
			},
			{
				label = "Buy it back",
				hint = "200 Ahn",
				requires = { min = { money = 200 } },
				result = {
					money = -200,
					setFlags = { "ar_bl_won" },
					schedule = { event = "ar_bl_mark", inYears = 4 },
					log = "She counted the two hundred twice and said it was the first time the blade had ever lost money.",
				},
			},
			{
				label = "Ask what she's done with it",
				clash = { stat = "mind", foe = "A Fixer's job stories", coins = 2, base = 4, coinPower = 3 },
				win = {
					mind = 3,
					sanity = 2,
					schedule = { event = "ar_bl_mark", inYears = 4 },
					log = "Escorts, mostly, and one job she won't talk about. \"It's a good name, and I kept it clean,\" she said.",
				},
				lose = {
					sanity = -5,
					schedule = { event = "ar_bl_mark", inYears = 4 },
					log = "She told you about the one job she won't talk about. You wished she hadn't.",
				},
			},
		},
	},
	{
		id = "ar_bl_mark",
		title = "Tibor Works",
		art = "workshop",
		text = "Tibor has a Workshop of his own now, with a mark on everything he makes: a crooked T, on purpose. He wipes his hands and lifts something long and wrapped down from the wall.",
		weight = 0,
		when = { flags = { "ar_bl_on" } },
		dialogue = {
			{ who = "ar_tibor_grown", line = "First blade was yours. Last one's mine. This is neither. Middle blades never get a name." },
			{ who = "ar_tibor_grown", line = "I put yours on it anyway. Properly this time. I learned my letters." },
		},
		choices = {
			{
				label = "Take the blade",
				hint = "A Workshop Long Blade.",
				result = {
					sanity = 4,
					gear = "long_blade",
					setFlags = { "ar_bl_end_blade" },
					addRelation = { kind = "friend", name = "Tibor", bond = 70, age = { 27, 31 } },
					log = "Your name ran down the tang in clean capitals. It was the best thing you had ever held.",
				},
			},
			{
				label = "Ask to work his forge",
				hint = "Join the Workshop trade.",
				result = {
					intelligence = 2,
					career = "workshop",
					setFlags = { "ar_bl_end_forge" },
					addRelation = { kind = "friend", name = "Tibor", bond = 70, age = { 27, 31 } },
					log = "He put you on the bellows on day one, like old times. Within a year your mark sat beside his.",
				},
			},
			{
				label = "Hang both blades on his wall",
				requires = { flags = { "ar_bl_won" } },
				result = {
					mind = 2,
					sanity = 6,
					setFlags = { "ar_bl_end_wall" },
					addRelation = { kind = "friend", name = "Tibor", bond = 75, age = { 27, 31 } },
					log = "The wavy first blade and the straight new one hang over his forge. When customers ask, he tells them your name.",
				},
			},
		},
	},

	-- ── Three Red Stamps ────────────────────────────────────────────────────
	{
		id = "ar_hx_card",
		title = "Three Red Stamps",
		art = "home",
		text = "At the bottom of {mother}'s sewing box, under the buttons, is a card with her face on it, younger, scar and all. HANA ASSOCIATION runs across the top, and three red stamps across the photo all say FAILED.",
		weight = 10,
		once = true,
		when = { minAge = 4, maxAge = 8, hasRelation = "mother", notFlags = { "fixer_blood" } },
		dialogue = {
			{ who = "{mother}", line = "That's your aunt. She looked like me. Put it back, the buttons go on top." },
			{ who = "{mother}", line = "Hana makes the Fixers. Your aunt was never a Fixer. Buttons on top, I said." },
		},
		choices = {
			{
				label = "Put the buttons back on top",
				result = {
					sanity = 1,
					setFlags = { "ar_hx_on" },
					schedule = { event = "ar_hx_yard", inYears = 4 },
					log = "You put the buttons back on top. Every few months after, you checked under them to see if the card was still your aunt.",
				},
			},
			{
				label = "Say Aunt has the same scar",
				clash = { stat = "mind", foe = "A mother's story", coins = 1, base = 1, coinPower = 2, fixed = true },
				win = {
					mind = 1,
					sanity = 2,
					setFlags = { "ar_hx_on" },
					schedule = { event = "ar_hx_yard", inYears = 4 },
					log = "She sat down on the bed. \"Fine, me, three times, and don't tell the neighbors, they think it was twice.\"",
				},
				lose = {
					sanity = -3,
					setFlags = { "ar_hx_on" },
					schedule = { event = "ar_hx_yard", inYears = 4 },
					log = "\"Aunts get scars too,\" she said, and took the box away, buttons and all.",
				},
			},
			{
				label = "Write PASSED on your hand",
				result = {
					sanity = 2,
					setFlags = { "ar_hx_on" },
					schedule = { event = "ar_hx_yard", inYears = 4 },
					log = "You wrote PASSED on the back of your hand in pen and showed her. She laughed until she had to sit on the floor.",
				},
			},
		},
	},
	{
		id = "ar_hx_yard",
		title = "Failed Three Times",
		art = "school",
		text = "A big kid in the academy yard has found out about the card, because everybody's mothers talk. He's telling the whole yard, with FAILED written on his forehead in red crayon.",
		weight = 0,
		when = { flags = { "ar_hx_on" } },
		codex = "fixers_hana",
		dialogue = {
			{ who = "bully", line = "Three times! Hana doesn't fail dogs three times! Your mama's a FAILED!" },
			{ who = "bully", line = "My uncle's Grade 8. Passed first go. He says she cried in the hall." },
		},
		choices = {
			{
				label = "Wipe it off his forehead",
				clash = { stat = "strength", foe = "The big kid with the crayon", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "bully" },
				win = {
					strength = 2,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_hx_file", inYears = 4 },
					log = "You wiped it off with your sleeve, the hard way. Nobody said FAILED near you again that year.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -4,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_hx_file", inYears = 4 },
					log = "He wrote FAILED on your forehead too. You walked home with it, and somebody washed it off without asking.",
				},
			},
			{
				label = "Ask him what Hana actually does",
				result = {
					mind = 2,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_hx_file", inYears = 4 },
					log = "He didn't know, past licenses. You read about the Hana Association in the academy book room until they locked it.",
				},
			},
			{
				label = "Say she failed on purpose",
				result = {
					strength = 1,
					sanity = 1,
					setFlags = { "knows_fixers" },
					schedule = { event = "ar_hx_file", inYears = 4 },
					log = "\"On purpose,\" you said, with no idea why you said it. The yard went quiet, the way yards do before a fight.",
				},
			},
		},
	},
	{
		id = "ar_hx_file",
		title = "Candidate File",
		art = "office",
		text = "Hana keeps a branch archive above a stationery shop, open to the public on Thursdays for two hours. A clerk with ink to the elbows asks whose file you want, and why.",
		weight = 0,
		when = { flags = { "ar_hx_on" } },
		dialogue = {
			{ who = "The Archive Clerk", line = "Family name? Year? Hana keeps everyone. Especially the ones it didn't want." },
			{ who = "The Archive Clerk", line = "Files over twenty years old need a fee or a reason. Reasons are cheaper. Mostly." },
		},
		choices = {
			{
				label = "Give him a reason",
				clash = { stat = "mind", foe = "An archive clerk's rules", coins = 1, base = 3, coinPower = 2 },
				win = {
					mind = 3,
					setFlags = { "ar_hx_read" },
					schedule = { event = "ar_hx_exam", inYears = 4 },
					log = "The file said she was sent to retrieve a debtor named Marthe Brin and let her go. Examiner Holm had written: LACKS RESOLVE.",
				},
				lose = {
					sanity = -4,
					schedule = { event = "ar_hx_exam", inYears = 4 },
					log = "\"Not a reason,\" said the clerk, and wrote your name in a book of people who had asked.",
				},
			},
			{
				label = "Pay the fee",
				hint = "30 Ahn",
				requires = { min = { money = 30 } },
				result = {
					money = -30,
					setFlags = { "ar_hx_read" },
					schedule = { event = "ar_hx_exam", inYears = 4 },
					log = "Three pages for thirty Ahn. The last said Examiner Holm had failed her for releasing the debtor, Marthe Brin.",
				},
			},
			{
				label = "Ask your mother instead",
				requires = { hasRelation = "mother", noStyle = true },
				result = {
					strength = 1,
					style = "poise",
					setFlags = { "ar_hx_taught" },
					schedule = { event = "ar_hx_exam", inYears = 4 },
					log = "She pushed the table to the wall and showed you how to wait, then move once. You fight like Poise now: patient, then sudden.",
				},
			},
		},
	},
	{
		id = "ar_hx_exam",
		title = "Examiner Holm",
		art = "school",
		text = "It's licensing season. The examiner for the practical is old now, with a cane and a Hana pin, and he stops at your name on his list and reads it twice.",
		weight = 0,
		when = { flags = { "ar_hx_on" } },
		dialogue = {
			{ who = "ar_holm", line = "{last}. I failed a {last} once. Three times. Good hands. No resolve." },
			{ who = "ar_holm", line = "The practical's a debtor retrieval, same as hers. Same debtor, as it happens. Hana doesn't waste a debtor." },
			{ who = "ar_holm", line = "Bring her to the branch by dark. Or don't, and we'll both learn something." },
		},
		choices = {
			{
				label = "Take the address",
				result = {
					sanity = -1,
					setFlags = { "ar_hx_practical" },
					trigger = "ar_hx_stall",
					log = "You took the address. He watched you go the way he must have watched her.",
				},
			},
			{
				label = "Say Marthe's name before he does",
				requires = { flags = { "ar_hx_read" } },
				result = {
					mind = 3,
					sanity = 2,
					setFlags = { "ar_hx_practical" },
					trigger = "ar_hx_stall",
					log = "His eyebrows went up a long way. \"So you've read the file, and you know how it ended last time,\" he said.",
				},
			},
			{
				label = "Ask why the same debtor",
				clash = { stat = "mind", foe = "Examiner Holm's grudge", coins = 2, base = 4, coinPower = 3 },
				win = {
					mind = 3,
					setFlags = { "ar_hx_practical" },
					trigger = "ar_hx_stall",
					log = "\"Because I want to know if it's in the blood,\" he said. \"Go on, prove me wrong either way.\"",
				},
				lose = {
					sanity = -5,
					setFlags = { "ar_hx_practical" },
					trigger = "ar_hx_stall",
					log = "\"A practical is practical,\" he said, and wrote something next to your name that you couldn't read upside down.",
				},
			},
			{
				label = "Walk out of the exam",
				result = {
					sanity = 2,
					setFlags = { "ar_hx_end_walked" },
					log = "You walked out past forty candidates into a nice afternoon. For once, nobody wrote anything down.",
				},
			},
		},
	},
	{
		id = "ar_hx_stall",
		title = "Marthe's Stall",
		art = "market",
		text = "Marthe Brin is old now and runs a noodle stall at the edge of the market. Two Syndicate collectors are already eating at her counter; they've waited on her debt longer than Hana has.",
		weight = 0,
		when = { flags = { "ar_hx_practical" } },
		dialogue = {
			{ who = "ar_marthe", line = "You've got her face. The Hana girl. She let me go, and I bought this stall with the head start." },
			{ who = "syndicate", line = "Hana's kid? Good. Take her in, or we take her our way. Our way's quicker." },
			{ who = "ar_marthe", line = "Sit down, either way. Noodles first. Nobody gets retrieved hungry at my stall." },
		},
		choices = {
			{
				label = "Walk her to Hana through them",
				clash = { stat = "strength", foe = "Two Syndicate collectors", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "syndicate" },
				win = passedPractical(),
				lose = failedPractical(),
			},
			{
				label = "Fight the way she taught you",
				requires = { flags = { "ar_hx_taught" } },
				clash = { stat = "strength", foe = "Two Syndicate collectors", coins = 2, base = 3, coinPower = 3, fight = true, enemy = "syndicate" },
				win = passedPractical(),
				lose = failedPractical(),
			},
			{
				label = "Stall them while she runs",
				clash = { stat = "mind", foe = "Two collectors who've heard it all", coins = 2, base = 4, coinPower = 3 },
				win = {
					mind = 3,
					sanity = 5,
					setFlags = { "ar_hx_end_released", "ar_hx_stamped" },
					schedule = home(),
					log = "You kept the collectors at the counter with a long story while she went out the back. Holm stamped your card FAILED.",
				},
				lose = {
					sanity = -6,
					setFlags = { "ar_hx_end_failed", "ar_hx_stamped" },
					schedule = home(),
					log = "They saw through it and went after her. You paid for her noodles, and Holm stamped your card FAILED without a word.",
				},
			},
			{
				label = "Pay off her debt",
				hint = "400 Ahn. Hana counts it.",
				requires = { min = { money = 400 } },
				result = {
					money = -400,
					career = "fixer",
					chronicle = "licensed_fixer",
					setFlags = { "ar_hx_end_paid", "ar_hx_passed" },
					schedule = home(),
					log = "You paid four hundred Ahn at the Hana counter in her name. Holm stamped PASSED, slowly, and said, \"That's a third way.\"",
				},
			},
		},
	},
	{
		id = "ar_hx_home",
		title = "Four Stamps",
		art = "home",
		text = "{mother} has the sewing box open on the table when you get home. Your card from the exam lies next to hers, under the lamp.",
		weight = 0,
		when = { flags = { "ar_hx_on" }, hasRelation = "mother" },
		dialogue = {
			{ who = "{mother}", line = "Holm's still alive, then. Still writing in that tiny hand." },
			{ who = "{mother}", line = "I heard about Marthe. The whole market heard. Sit down." },
		},
		choices = {
			{
				label = "Show her the PASSED stamp",
				requires = { flags = { "ar_hx_passed" } },
				result = {
					sanity = 5,
					relationBond = { kind = "mother", amount = 10 },
					log = "She held your card under the lamp a long time. Then she put it in the sewing box, under the buttons, with hers.",
				},
			},
			{
				label = "Show her the FAILED stamp",
				requires = { flags = { "ar_hx_stamped" } },
				result = {
					sanity = 6,
					relationBond = { kind = "mother", amount = 12 },
					log = "She laughed until she had to sit down. \"Four between us,\" she said, \"and that's a family record.\"",
				},
			},
			{
				label = "Ask why she let Marthe go",
				result = {
					mind = 2,
					sanity = 2,
					log = "\"She told me what she'd cook first if she got away,\" she said. \"Noodles, and she was right about the noodles.\"",
				},
			},
		},
	},
}
