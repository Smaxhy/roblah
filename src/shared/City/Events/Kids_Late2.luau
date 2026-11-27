--[[
	KIDS, LATE, part two (kl_): ages 7-12 inside the Nest, in particular Districts, and in
	particular families (origin flags). Backstreets street life is in Kids_Late.luau.
	Nest kids sit the academy entrance exam, have tutors, run wall drills, and learn about
	the Night from slides. District kids grow up next to whatever their Wing sells.
	Faces: Cast/Kids_Late.luau.

	Follow-ups (weight 0) at the end of this file:
		kl_nest_exam    -> kl_nest_old_paper  (the proctor hands back the paper he kept)
		kl_nest_tutor   -> kl_hesper_again    (the tutor in the checkpoint line)
		kl_nest_fence   -> kl_tobi_grown      (a parcel through the bars)
		kl_nest_answers -> kl_nest_audit      (the year of forty perfect scores)
]]

return {
	-- ── the Nest ───────────────────────────────────────────────────────────
	{
		id = "kl_nest_exam",
		title = "The Entrance Exam",
		art = "school",
		text = "The academy entrance exam is in a white hall with three hundred desks and one clock. Every desk has a numbered card that says NO TALKING.",
		weight = 14,
		once = true,
		when = { side = "nest", minAge = 9, maxAge = 11 },
		dialogue = {
			{ who = "kl_proctor_lind", line = "The rules are on the card. I will read them twice, because nobody listens the first time." },
			{ who = "kl_proctor_lind", line = "Ninety minutes. The Wing thanks you for your ambition. Begin." },
		},
		choices = {
			{
				label = "Work through every question",
				hint = "Intelligence check. Studying pays here.",
				clash = { stat = "intelligence", foe = "Ninety minutes of the Wing's questions", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					intelligence = 2,
					setFlags = { "knows_wings", "kl_nest_passed", "kl_nest_exam_sat" },
					schedule = { event = "kl_nest_old_paper", inYears = 5 },
					log = "You finished with four minutes left and checked everything twice. Your number went up in the top forty. The drive home was quiet and very happy.",
				},
				lose = {
					sanity = -4,
					setFlags = { "knows_wings", "kl_nest_failed", "kl_nest_exam_sat" },
					schedule = { event = "kl_nest_old_paper", inYears = 5 },
					log = "You froze on question nine and never got unstuck. Your number went up near the bottom. The letter home was polite and very short.",
				},
			},
			{
				label = "Do the easy ones first",
				result = {
					intelligence = 1,
					setFlags = { "knows_wings", "kl_nest_middle", "kl_nest_exam_sat" },
					schedule = { event = "kl_nest_old_paper", inYears = 5 },
					log = "Every easy question, then guesses. Your number came out exactly in the middle. Nobody at home knew what to say about the middle.",
				},
			},
			{
				label = "Help the kid next to you",
				result = {
					strength = 1,
					sanity = 2,
					setFlags = { "knows_wings", "kl_nest_helped", "kl_nest_exam_sat" },
					schedule = { event = "kl_nest_old_paper", inYears = 5 },
					log = "You slid your answer to question four an inch to the left. Proctor Lind saw, and turned his back for exactly one minute.",
				},
			},
		},
	},
	{
		id = "kl_nest_tutor",
		title = "Tutor Hesper",
		art = "nest",
		text = "Your new tutor comes in from the Backstreets on a work pass, three checkpoints each way. She teaches sums from the textbook, then closes it and teaches other things.",
		weight = 12,
		once = true,
		when = { side = "nest", minAge = 8, maxAge = 11 },
		dialogue = {
			{ who = "kl_hesper", line = "Page forty, the Wing's founding. Read it. Good. Now forget it, it's mostly wrong." },
			{ who = "kl_hesper", line = "I have to be back through the gate by eleven. Ask me something real." },
		},
		choices = {
			{
				label = "Ask about the Backstreets",
				result = {
					mind = 2,
					setFlags = { "knows_night", "kl_hesper_kept" },
					schedule = { event = "kl_hesper_again", inYears = 7 },
					log = "She told you about the Night with the textbook open on her lap, in case anyone came in.",
					dialogue = { { who = "kl_hesper", line = "Loud. Cheap. Good noodles. Home before three, or you're not home." } },
				},
			},
			{
				label = "Ask her to teach you properly",
				result = {
					intelligence = 2,
					setFlags = { "kl_hesper_kept" },
					schedule = { event = "kl_hesper_again", inYears = 7 },
					log = "She drilled you every Tuesday and Thursday until you could do the Wing's sums in your sleep.",
					dialogue = { { who = "kl_hesper", line = "Now you can pass anything they give you. Don't let it make you stupid." } },
				},
			},
			{
				label = "Repeat what she says at dinner",
				result = {
					sanity = -3,
					setFlags = { "kl_hesper_fired" },
					schedule = { event = "kl_hesper_again", inYears = 7 },
					log = "Your parents called the agency. Hesper didn't come on Thursday. Her pass was cancelled, the agency said, very politely.",
				},
			},
		},
	},
	{
		id = "kl_nest_wall_drill",
		title = "Wall Drill",
		art = "nest",
		text = "The wall-drill siren goes off during lunch. Shutters come down over every window and the teacher counts you twice. It's practice, she says, in case anything comes over the wall.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Hold perfectly still in line",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Twenty minutes of siren", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, log = "You held still for the whole twenty minutes. The teacher put a gold star by your name, the first anyone got for standing still." },
				lose = { sanity = -3, log = "You flinched every time the siren wound up. A drone came down the corridor to look at you, then went away, and the shutters went up." },
			},
			{
				label = "Ask what would come over",
				result = {
					mind = 1,
					sanity = -1,
					log = "Nobody asked anything else. On the way home you looked at the wall for a long time.",
					dialogue = { { who = "The Teacher", line = "Nothing, darling. That's why we practice." } },
				},
			},
			{
				label = "Peek through the shutter slats",
				result = { sanity = -2, setFlags = { "kl_peeked_drill" }, log = "Wing security walked the empty street in pairs, checking doors that were already locked. One of them looked straight at your slat." },
			},
		},
	},
	{
		id = "kl_nest_night_class",
		title = "Backstreets Studies",
		art = "school",
		text = "In Backstreets Studies the teacher shows two slides: a crowded noodle street, then the same street at 3:13, empty. The class has to say what changed.",
		weight = 14,
		once = true,
		when = { side = "nest", notFlags = { "knows_night" }, minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Say the people are gone",
				result = { mind = 2, sanity = -2, setFlags = { "knows_night" }, codex = "bs_lore_night_rules", log = "\"Correct,\" said the teacher, and clicked to the next slide, which was a graph." },
			},
			{
				label = "Say the street is cleaner",
				result = { intelligence = 1, setFlags = { "knows_night" }, log = "\"Also correct. The Sweepers are very thorough,\" said the teacher, and drew a tick next to your name." },
			},
			{
				label = "Ask where the people went",
				result = {
					mind = 1,
					sanity = -1,
					setFlags = { "knows_night" },
					log = "That night you lay awake till half past three, listening for something you couldn't hear through the wall.",
					dialogue = { { who = "The Teacher", line = "Home, if they were sensible. That's the lesson." } },
				},
			},
		},
	},
	{
		id = "kl_nest_ines",
		title = "Ines Calder",
		art = "school",
		text = "Ines Calder has been first in the class rankings every term since you were seven. Her mother waits at the gate at pickup, holding the list.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Beat her on the term test",
				hint = "Intelligence check. She has a tutor for everything.",
				clash = { stat = "intelligence", foe = "Ines Calder's average", coins = 1, base = 3, coinPower = 2, fixed = true },
				win = {
					intelligence = 2,
					sanity = 2,
					setFlags = { "kl_beat_ines" },
					addRelation = { kind = "rival", name = "Ines Calder", bond = 25, age = { 9, 12 } },
					log = "First, by half a mark. Ines came second for the first time in her life, and her mother made her hold the list at the gate.",
				},
				lose = {
					intelligence = 1,
					sanity = -4,
					addRelation = { kind = "rival", name = "Ines Calder", bond = 30, age = { 9, 12 } },
					log = "Second, by half a mark. Ines walked past your desk and tapped the list once, without looking at you.",
				},
			},
			{
				label = "Ask her to study together",
				result = {
					intelligence = 1,
					sanity = 2,
					addRelation = { kind = "friend", name = "Ines Calder", bond = 55, age = { 9, 12 } },
					log = "She said no, then yes, then made a timetable. She still came first. You came second, and she said that was the best place to be.",
				},
			},
			{
				label = "Stop reading the list",
				result = { sanity = 3, log = "You were fifteenth all year and slept like a stone. Your parents read the list for you, twice." },
			},
		},
	},
	{
		id = "kl_nest_yard_fight",
		title = "The Scholarship Girl",
		art = "school",
		text = "Cassius Vey's father is a Class 4 Feather, and every day at recess Cassius picks on the scholarship girl from the Backstreets. Today he's knocked her lunch tin into the fountain.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 8, maxAge = 11 },
		choices = {
			{
				label = "Push Cassius in after it",
				clash = { stat = "strength", foe = "Cassius Vey", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "bully" },
				win = {
					strength = 2,
					sanity = 2,
					setFlags = { "kl_yunhee_friend" },
					addRelation = { kind = "friend", name = "Yun-hee Seo", bond = 60, age = { 8, 11 } },
					log = "Cassius went in after the tin and came out shouting about his father's Class. Yun-hee sat with you at lunch every day after.",
				},
				lose = {
					health = { -4, -2 },
					sanity = -4,
					addRelation = { kind = "rival", name = "Cassius Vey", bond = 15, age = { 8, 11 } },
					log = "Cassius had lessons. A letter went home about conduct, with his father's Class underlined twice.",
				},
			},
			{
				label = "Fish out her lunch tin",
				result = {
					sanity = 1,
					addRelation = { kind = "friend", name = "Yun-hee Seo", bond = 50, age = { 8, 11 } },
					log = "You gave it back, wet. Her name was Yun-hee. She ate the soggy rice anyway, because it was food.",
				},
			},
			{
				label = "Tell the teacher",
				result = { mind = 1, sanity = -2, log = "The teacher wrote it down, then looked at the name she'd written and put the pen away." },
			},
		},
	},
	{
		id = "kl_nest_service_gate",
		title = "The Service Gate",
		art = "checkpoint",
		text = "Behind the school the cleaners go in and out through a service gate, and between shifts it stands open for four minutes. On the other side is the Backstreets.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 10, maxAge = 12 },
		choices = {
			{
				label = "Go through for an hour",
				hint = "Mental Strength check. Back before the next shift.",
				clash = { stat = "mind", foe = "The next shift change", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 1, sanity = 3, setFlags = { "kl_nest_slipped" }, log = "You bought a skewer with a Nest coin the man had never seen and got back in with the cleaners. Nobody counted you. You smelled of onions for a day." },
				lose = { sanity = -4, setFlags = { "kl_nest_slipped" }, log = "The gate shut with you on the wrong side. A cleaner sighed and walked you round to the main checkpoint, and your parents came with your papers." },
			},
			{
				label = "Watch through the gap",
				result = { mind = 1, sanity = 1, log = "Four minutes: a dog asleep on a noodle stall's step, and a boy carrying a ladder twice his height. Then the gate swung shut." },
			},
			{
				label = "Tell the cleaners it's open",
				result = {
					strength = 1,
					log = "The cleaners looked at each other.",
					dialogue = { { who = "The Oldest Cleaner", line = "We know. Don't tell anyone else." } },
				},
			},
		},
	},
	{
		id = "kl_nest_kitten",
		title = "Unregistered",
		art = "nest",
		text = "There's a kitten in the hedge by the wall. Nest pets need a permit and a chip, and this one has neither, just a lot of opinions.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 7, maxAge = 9 },
		choices = {
			{
				label = "Hide it in your room",
				hint = "Mental Strength check. The drones.",
				clash = { stat = "mind", foe = "The building's drones", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { sanity = 4, setFlags = { "kl_secret_kitten" }, log = "It lived in your wardrobe for a year and learned to go silent when the drones passed. You called it Permit." },
				lose = { sanity = -4, log = "On the second night a drone hovered at your window and blinked. A letter came. The kitten went to a Registered Facility, the letter said." },
			},
			{
				label = "Register it",
				requires = { min = { money = 20 } },
				result = { money = -20, sanity = 3, setFlags = { "kl_registered_cat" }, log = "The fee took every Ahn you had. The kitten got a chip and a collar with your address on it, and ignored both." },
			},
			{
				label = "Push it back through the fence",
				result = { mind = 1, sanity = -2, log = "It sat on the Backstreets side and looked at you like you'd done something unforgivable." },
			},
		},
	},
	{
		id = "kl_nest_work_day",
		title = "Family Day",
		art = "wing",
		text = "{father} takes you up the Wing's tower for Family Day. The lift climbs forty floors and stops, because the buttons above forty need a higher Class to light.",
		weight = 12,
		once = true,
		when = { side = "nest", flags = { "nest_born" }, hasRelation = "father", minAge = 8, maxAge = 11 },
		dialogue = {
			{ who = "{father}", line = "This is my desk. That's my window. Don't touch the window, it's Class 4." },
			{ who = "{father}", line = "One day you'll have a desk with a better window. That's how it works." },
		},
		choices = {
			{
				label = "Press a button above forty",
				result = { sanity = -2, setFlags = { "knows_wings", "kl_pressed_button" }, log = "It didn't light. A woman in a gray suit appeared from nowhere and asked {father} for his Class, politely, twice." },
			},
			{
				label = "Ask what he does all day",
				result = {
					mind = 1,
					setFlags = { "knows_wings" },
					log = "You watched him check forms for an hour. He was very good at it. Nobody told him so.",
					dialogue = { { who = "{father}", line = "Forms. Other people's forms. I check them." } },
				},
			},
			{
				label = "Look out the Class 4 window",
				result = { sanity = 2, setFlags = { "knows_wings" }, log = "From forty floors up the Backstreets were a gray carpet with steam coming off it. You looked for a person and couldn't find one." },
			},
		},
	},
	{
		id = "kl_nest_train_face",
		title = "The Train with Its Blinds Down",
		art = "nest",
		text = "Your tower stands so close to the WARP rail that the trains rattle your window: one every seven minutes, all night, each across the whole City in the time it takes to say your name twice. Tonight you notice that every blind in every car is pulled down. They always are.",
		weight = 8,
		once = true,
		when = { side = "nest", minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Wave anyway",
				result = { sanity = -2, setFlags = { "kl_saw_warp_face" }, log = "You waved at a wall of grey blinds going past faster than you could count them. Nobody waved back. Then the rail was empty." },
			},
			{
				label = "Close your own blind",
				result = { mind = 1, sanity = -1, log = "You didn't open it again for a month. The trains kept going past, one every seven minutes, all night." },
			},
			{
				label = "Ask your teacher about it at school",
				result = {
					mind = 1,
					codex = "districts_w_corp",
					log = "Your teacher said it twice, the second time to herself.",
					dialogue = { { who = "The Teacher", line = "The blinds are for the passengers' comfort, darling. It's only ten seconds." } },
				},
			},
		},
	},
	{
		id = "kl_nest_party_fixer",
		title = "The Bodyguard at the Party",
		art = "nest",
		text = "At Rosalind's tenth birthday there's a cake as tall as you and a Fixer in the corner, hired for the afternoon. He hasn't touched the cake. He hasn't sat down.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 8, maxAge = 11 },
		choices = {
			{
				label = "Ask to see his weapon",
				result = {
					strength = 1,
					setFlags = { "knows_fixers" },
					log = "The birthday kids decided you were the bravest one there. He decided you were the most annoying.",
					dialogue = { { who = "The Fixer", line = "No. It's in the coat. It stays in the coat. That's the job." } },
				},
			},
			{
				label = "Bring him a slice of cake",
				result = {
					sanity = 2,
					setFlags = { "knows_fixers" },
					log = "He ate it standing up, in four bites, without taking his eyes off the door.",
					dialogue = { { who = "The Fixer", line = "Grade 5. Twelve hours a day watching doors. Nobody brings me cake." } },
				},
			},
			{
				label = "Ask what a Grade is",
				result = {
					mind = 1,
					setFlags = { "knows_fixers" },
					codex = "fx_lore_grades",
					log = "By the end of the party everyone was ranking each other, and Rosalind was Grade 1 because it was her birthday.",
					dialogue = { { who = "The Fixer", line = "Nine's the bottom. One's the top. Five is the middle, where they hire you for birthdays." } },
				},
			},
		},
	},
	{
		id = "kl_nest_review",
		title = "Residence Review",
		art = "nest",
		text = "An inspector from the Wing is coming to review your family's residence. For one hour you're to sit straight and never, ever mention the leak in the bathroom.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Be perfect for an hour",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "An inspector with a clipboard", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, sanity = 1, log = "You sat straight and answered in full sentences. She wrote GOOD on her clipboard and underlined it. Your family breathed out for the first time all week." },
				lose = { sanity = -4, setFlags = { "kl_review_noted" }, log = "You said \"except the bathroom\" before you could stop. She wrote one word down. Your parents argued about what the word was for a month." },
			},
			{
				label = "Show her the leak",
				result = { strength = 1, sanity = -2, setFlags = { "kl_review_noted" }, log = "She thanked you and wrote it down. The Wing fixed the leak within a day, and raised the residence fee by nine percent." },
			},
			{
				label = "Hide under your bed",
				result = { mind = 1, sanity = -1, log = "The inspector looked into your room, saw a neat bed, and moved on. She never looked under it." },
			},
		},
	},
	{
		id = "kl_nest_fence",
		title = "The Boy at the Fence",
		art = "nest",
		text = "Where the Nest garden meets the wall there's a fence with bars a hand apart. A Backstreets boy has sat on the other side every afternoon this week, watching you eat lunch.",
		weight = 12,
		once = true,
		when = { side = "nest", minAge = 8, maxAge = 11 },
		dialogue = {
			{ who = "kl_tobi", line = "I'm Tobi. What's that, a peach?" },
			{ who = "kl_tobi", line = "Trade you. I've got a Sweeper story. A true one." },
		},
		choices = {
			{
				label = "Trade the peach for the story",
				result = {
					sanity = -2,
					setFlags = { "knows_night", "kl_tobi_friend" },
					schedule = { event = "kl_tobi_grown", inYears = 6 },
					log = "He ate the peach in four bites and told you about the Night. It was the best story you'd ever heard. You hoped it wasn't true.",
				},
			},
			{
				label = "Give him the peach for nothing",
				result = {
					sanity = 2,
					setFlags = { "kl_tobi_friend" },
					schedule = { event = "kl_tobi_grown", inYears = 6 },
					log = "He looked at you like you'd done something stupid, then ate it. He came back every afternoon for a year. You packed two lunches.",
				},
			},
			{
				label = "Call the gate guard",
				result = { mind = 1, sanity = -3, log = "By the time the guard came Tobi was gone. The next day he was back, further along the fence, watching someone else's lunch." },
			},
		},
	},
	{
		id = "kl_nest_dinner_news",
		title = "Reassigned",
		art = "nest",
		text = "On the dinner screen, the news reads out this week's reassigned Feathers. The fourth name is Mr. Osei from the ninth floor, who taught you to tie your shoes.",
		weight = 10,
		once = true,
		when = { side = "nest", hasRelation = "mother", minAge = 8, maxAge = 12 },
		dialogue = {
			{ who = "The News", line = "Reassigned with the Wing's thanks. Residence permits will transfer as appropriate." },
			{ who = "{mother}", line = "Eat your vegetables. Mr. Osei will be fine. Reassigned is fine." },
			{ who = "{mother}", line = "Who wants more rice?" },
		},
		choices = {
			{
				label = "Ask where reassigned is",
				result = {
					mind = 1,
					sanity = -2,
					setFlags = { "knows_wings" },
					log = "Mr. Osei's flat was empty by Friday. By Monday a new family lived there, with a boy who couldn't tie his shoes either.",
					dialogue = { { who = "{mother}", line = "Somewhere else, darling. Eat." } },
				},
			},
			{
				label = "Eat your vegetables",
				result = { sanity = 1, setFlags = { "knows_wings" }, log = "Nobody said Mr. Osei's name again. The news moved on to the weather inside the wall, which was fine, as always." },
			},
			{
				label = "Go and knock on his door",
				result = { strength = 1, sanity = -3, setFlags = { "knows_wings", "kl_osei_door" }, log = "The door was open. The flat was empty except for a pair of shoes by the mat, laces tied in a perfect double knot." },
			},
		},
	},
	{
		id = "kl_nest_answers",
		title = "The Answer Sheet",
		art = "school",
		text = "Pieter in the year above is selling next week's test answers for thirty Ahn, folded very small. Half the class has bought one already.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 10, maxAge = 12 },
		choices = {
			{
				label = "Buy the answers",
				requires = { min = { money = 30 } },
				result = {
					money = -30,
					intelligence = 1,
					setFlags = { "kl_bought_answers" },
					schedule = { event = "kl_nest_audit", inYears = 4 },
					log = "Every question right. So did half the class. The teachers looked at the results for a long time.",
				},
			},
			{
				label = "Study instead",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Next week's test", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, log = "You came seventh. The six above you had all bought answers. Two of them got caught, and you moved up to fifth." },
				lose = { intelligence = 1, sanity = -3, log = "Twenty-ninth. Everyone who bought answers came above you. You studied harder anyway, mostly out of spite." },
			},
			{
				label = "Tell the teacher",
				result = { strength = 1, sanity = -3, setFlags = { "kl_told_on_pieter" }, log = "Pieter moved to another academy. Half the class stopped talking to you, and the other half started sitting with you at lunch." },
			},
		},
	},
	{
		id = "kl_nest_buttons",
		title = "Seven Buttons",
		art = "school",
		text = "The academy uniform has exactly seven buttons, and inspection at the gate is in ten minutes. Yours has six. The seventh is somewhere between home and here.",
		weight = 8,
		once = true,
		when = { side = "nest", minAge = 7, maxAge = 9 },
		choices = {
			{
				label = "Sew on a borrowed one",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A needle and ten minutes", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, log = "You sewed on a button from your coat pocket, slightly the wrong white. The inspector counted seven and moved on." },
				lose = { sanity = -3, log = "You sewed it on upside down, through your own sleeve. The inspector counted to seven twice, slowly, and wrote your name down." },
			},
			{
				label = "Tell the inspector the truth",
				result = { strength = 1, sanity = -1, log = "\"Six,\" said the inspector, and wrote it down. \"Next time, seven.\" That was all, and it stayed with you all day." },
			},
			{
				label = "Hold your bag over the gap",
				result = { mind = 1, sanity = 1, log = "You stood very straight with your bag over the gap. The inspector looked at the bag, then at you, and moved on." },
			},
		},
	},
	{
		id = "kl_nest_career_day",
		title = "Career Day",
		art = "school",
		text = "Career Day at the academy: an R Corp officer with a shaved head, and a woman from the Hana Association who keeps checking her watch. Everyone gets one question.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 10, maxAge = 12 },
		choices = {
			{
				label = "Ask the officer how to join",
				result = {
					strength = 1,
					setFlags = { "knows_wings" },
					log = "He gave you a little tin rabbit badge. The teacher took it off you at the door.",
					dialogue = {
						{ who = "The Officer", line = "Sign at sixteen. We feed you, train you, send you out. Most come back." },
						{ who = "The Officer", line = "Most." },
					},
				},
			},
			{
				label = "Ask the Hana woman about Fixers",
				result = {
					mind = 1,
					setFlags = { "knows_fixers" },
					codex = "fixers_hana",
					log = "She left before the bell. Somebody said she was Grade 1. Somebody else said there was no such thing.",
					dialogue = { { who = "The Hana Clerk", line = "Whatever the contract says, within the law. Report filed by nine." } },
				},
			},
			{
				label = "Ask why nobody's from outside",
				result = { strength = 1, sanity = -1, log = "The teacher wrote your question on the board, under TOMORROW. It stayed there all year." },
			},
		},
	},
	{
		id = "kl_d20_long_day",
		title = "A Longer Day",
		art = "nest",
		text = "In T Corp's Nest your day is as long as your family's time account. Your deskmate Benedikt's family is rich in time, and he does his homework in the extra two hours.",
		weight = 12,
		once = true,
		when = { district = "d20", side = "nest", minAge = 8, maxAge = 12 },
		codex = "wg_lore_tcorp",
		dialogue = {
			{ who = "Benedikt", line = "You only get twenty-four? That's so sad. When do you read?" },
		},
		choices = {
			{
				label = "Ask what the extra hours are like",
				result = {
					mind = 1,
					sanity = -2,
					log = "You thought about him sitting in the stopped Nest for two hours every night. You didn't envy him as much after that.",
					dialogue = { { who = "Benedikt", line = "Quiet. Everyone else is stopped. I can hear the clocks thinking." } },
				},
			},
			{
				label = "Ask to borrow an hour",
				hint = "Mental Strength check. There are forms.",
				clash = { stat = "mind", foe = "Benedikt's father's accountant", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 1, sanity = 3, setFlags = { "kl_borrowed_hour" }, log = "He lent you one, on a form his father signed, at interest. You spent it reading under the covers. Best hour of the year." },
				lose = { sanity = -4, log = "A letter came from T Corp about an unlicensed transfer attempt. Your parents read it twice and didn't say anything for a day." },
			},
			{
				label = "Learn to work faster",
				result = { intelligence = 2, log = "You did sums at the dinner table and on the stairs. You were never rich enough for a longer day. You got fast instead." },
			},
		},
	},
	{
		id = "kl_nb_future",
		title = "Your Future, at Dinner",
		art = "nest",
		text = "At dinner the grown-ups are deciding your future again, across the table, as if you were the salt.",
		weight = 12,
		once = true,
		when = { side = "nest", flags = { "nest_born" }, hasRelation = "mother", minAge = 9, maxAge = 12 },
		dialogue = {
			{ who = "{mother}", line = "Class 3 by twenty-five, Class 4 by thirty. Then the bigger flat." },
			{ who = "Uncle Remy", line = "Class 4 is overrated. Look at me. Class 2, and I sleep." },
			{ who = "{mother}", line = "Remy, you sleep because nobody needs you." },
		},
		choices = {
			{
				label = "Say you want to be a Fixer",
				result = { strength = 1, sanity = -2, setFlags = { "knows_fixers", "kl_said_fixer" }, log = "The table went silent. Uncle Remy laughed into his soup. {mother} said, \"Pass the salt,\" and nobody passed it." },
			},
			{
				label = "Say you'll make Class 4",
				result = { intelligence = 1, sanity = 1, setFlags = { "kl_promised_class" }, log = "{mother} smiled for the rest of dinner. Uncle Remy looked at you like he was sorry for you." },
			},
			{
				label = "Ask Uncle Remy what he wanted",
				result = {
					mind = 1,
					sanity = 1,
					log = "He winked at you. {mother} changed the subject to the new lifts.",
					dialogue = { { who = "Uncle Remy", line = "Wanted? Nobody asked." } },
				},
			},
		},
	},

	-- ── Districts ──────────────────────────────────────────────────────────
	{
		id = "kl_d4_flyers",
		title = "Seven Offices, One Street",
		art = "office",
		text = "Office Row in District 4 has seven tiny Fixer offices fighting over the same clients, and all of them pay kids to hand out flyers. One Ahn per ten flyers.",
		weight = 12,
		once = true,
		when = { district = "d4", side = "backstreets", minAge = 7, maxAge = 11 },
		choices = {
			{
				label = "Hand out flyers for the cheapest",
				result = { money = 3, setFlags = { "knows_fixers" }, log = "Thirty flyers for the Bent Nail Office: ANY JOB, HALF PRICE. A man read one and laughed until he had to sit on a crate." },
			},
			{
				label = "Work for two offices at once",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Two Office reps who talk to each other", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 1, money = 8, setFlags = { "knows_fixers" }, log = "One stack in each hand, both rates. Nobody caught on. You learned what a Grade was, and that both offices lied about theirs." },
				lose = { sanity = -3, setFlags = { "knows_fixers" }, log = "The two reps met at the noodle stall and compared flyers. Both fired you, and one hired you back to spy on the other." },
			},
			{
				label = "Read one first",
				result = { mind = 1, setFlags = { "knows_fixers" }, codex = "fx_lore_offices", log = "GRADE 8 OFFICE. ALL WEAPONS GRADED. REPORTS FILED ON TIME. You didn't know what any of it meant. It sounded expensive." },
			},
		},
	},
	{
		id = "kl_d7_bug_jar",
		title = "The Beetle Jar",
		art = "street",
		text = "You've caught a green beetle as long as your thumb and put it in a jar to show the street. Old Mr. Haldor, who fought in the Smoke War, sees it and stops walking.",
		weight = 12,
		once = true,
		when = { district = "d7", notFlags = { "smoke_war_family" }, minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Show him up close",
				result = {
					sanity = -2,
					setFlags = { "kl_haldor_jar" },
					log = "He looked at it a long time. You'd never heard a grown-up say please to you like that.",
					dialogue = { { who = "Mr. Haldor", line = "Let it go. Far from here. Please." } },
				},
			},
			{
				label = "Let it go right away",
				result = { mind = 1, sanity = 1, log = "It flew off over the roofs. Mr. Haldor nodded at you once, and started walking again." },
			},
			{
				label = "Ask him why he stopped",
				result = {
					mind = 1,
					codex = "bs_lore_smoke_war",
					log = "He bought you a skewer, which he'd never done before, and didn't say anything else.",
					dialogue = {
						{ who = "Mr. Haldor", line = "Bugs remind me. That's all." },
						{ who = "Mr. Haldor", line = "In the war, G Corp made bigger ones. Much bigger." },
					},
				},
			},
		},
	},
	{
		id = "kl_d8_corridor",
		title = "The Corridor Race",
		art = "underpass",
		text = "In Hongyuan the corridors move when the money moves. The one outside your door is shortening right now, and the kids are racing to the far end before it closes.",
		weight = 12,
		once = true,
		when = { district = "d8", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Race",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A corridor that's getting shorter", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { speed = 2, sanity = 2, log = "You made it with a meter to spare. The corridor finished closing behind you with a soft click, like a book." },
				lose = { health = { -3, -2 }, sanity = -3, log = "You turned back halfway. Behind you the wall slid up to the doors and stopped. Your door was still there. The neighbors' wasn't." },
			},
			{
				label = "Watch from the doorway",
				result = { mind = 1, codex = "bs_lore_hongyuan_rooms", log = "A kid made it by turning sideways at the end. The old man next door said the family down there had had a bad year." },
			},
			{
				label = "Chalk a mark on the wall",
				result = { intelligence = 1, setFlags = { "kl_marked_wall" }, log = "In a week the corridor had moved past your mark twice and come back once. You started keeping a chart." },
			},
		},
	},
	{
		id = "kl_d11_tubes",
		title = "The Glass Tubes",
		art = "checkpoint",
		text = "Through a window by the K Corp checkpoint you can see a row of tall glass tubes. In each one a man in green stands with his eyes shut, and the kids dare each other to knock.",
		weight = 12,
		once = true,
		when = { district = "d11", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Knock on the window",
				result = { strength = 1, sanity = -4, setFlags = { "knows_wings" }, log = "You knocked twice. Every eye in every tube opened at once and looked at you. Then they closed again, together." },
			},
			{
				label = "Ask the checkpoint guard",
				result = {
					mind = 1,
					setFlags = { "knows_wings" },
					codex = "wg_lore_kcorp",
					log = "He didn't look at the window when he said it.",
					dialogue = {
						{ who = "The Guard", line = "Excision Staff. Off duty. They wait." },
						{ who = "The Guard", line = "Don't knock." },
					},
				},
			},
			{
				label = "Walk past without looking",
				result = { mind = 1, log = "You walked past like the grown-ups do. You could feel the window the whole way, like a cold spot." },
			},
		},
	},
	{
		id = "kl_d12_green_jar",
		title = "A Jar of Green",
		art = "wing",
		text = "Every night the L Corp tower glows faintly green over District 12. The kids say if you leave a jar open on the windowsill, by morning it's full of green light.",
		weight = 12,
		once = true,
		when = { district = "d12", world = { era = "wings" }, minAge = 7, maxAge = 11 },
		choices = {
			{
				label = "Leave a jar out",
				result = { sanity = -2, setFlags = { "knows_lcorp", "kl_green_jar" }, log = "In the morning the jar was empty, but the lid was warm. You kept it on the shelf with the lid on, just in case." },
			},
			{
				label = "Ask what they make in there",
				result = {
					mind = 1,
					setFlags = { "knows_lcorp" },
					codex = "lcorp_enkephalin",
					log = "She went back inside before you could ask what from.",
					dialogue = { { who = "A Neighbor", line = "Energy. Enkephalin, they call it. Lights half the City. Don't ask what from." } },
				},
			},
			{
				label = "Count the lit windows",
				result = { intelligence = 1, setFlags = { "knows_lcorp" }, log = "Every window on the tower was lit, all night, every night. You never once saw one go dark, or anyone in one." },
			},
		},
	},
	{
		id = "kl_d12_salvage",
		title = "Something That Glows",
		art = "ruins",
		text = "Since the tower fell, District 12's kids pick through the rubble for anything that still glows. You've found a green light tube, still lit. Three older kids say it's theirs.",
		weight = 12,
		once = true,
		when = { district = "d12", world = { era = { "library", "limbus" } }, minAge = 8, maxAge = 12 },
		codex = "bs_lore_d12_after",
		choices = {
			{
				label = "Fight for the tube",
				clash = { stat = "strength", foe = "Three salvage kids", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "street_kid" },
				win = { strength = 2, money = 12, log = "You held on and swung the tube like a sword, which was stupid, and it worked. A scrap dealer paid twelve Ahn for it, still lit." },
				lose = { health = { -4, -2 }, sanity = -3, log = "They took it. Walking away, the biggest one held it up, and it went out in his hand. He dropped it like it had bitten him." },
			},
			{
				label = "Give it to them",
				result = { mind = 1, sanity = -1, log = "They were fighting each other over it before you'd turned the corner." },
			},
			{
				label = "Throw it in the canal",
				result = { strength = 1, sanity = -2, log = "It sank, still glowing, and the water around it went very still. Nobody fished that stretch afterward." },
			},
		},
	},
	{
		id = "kl_d14_hammers",
		title = "Hammers on Butter Street",
		art = "street",
		text = "Three Inquisitors with small hammers on their belts are walking Butter Street slowly, looking at people's hands. Mrs. Kovač, who has a Workshop hand, has gone inside and pulled her shutter down.",
		weight = 12,
		once = true,
		when = { district = "d14", minAge = 8, maxAge = 12 },
		codex = "bs_lore_butter_street",
		choices = {
			{
				label = "Keep walking, eyes down",
				result = { mind = 1, log = "One of them stopped you and looked at your hands, front and back, then let you go. He smelled of polish." },
			},
			{
				label = "Knock on her shutter after",
				result = { strength = 1, sanity = 2, setFlags = { "kl_kovac_friend" }, log = "When they'd gone you knocked twice. She opened it a crack, saw it was you, and gave you a biscuit with her real hand." },
			},
			{
				label = "Ask them what they're looking for",
				result = {
					sanity = -3,
					log = "He held your hands up to the light for a long time, then smiled and set them back at your sides like a compliment.",
					dialogue = { { who = "An Inquisitor", line = "Impurity, child. Show me your hands. Ah. Pure." } },
				},
			},
		},
	},
	{
		id = "kl_d16_slide",
		title = "The Loop Slide",
		art = "street",
		text = "District 16's buildings bend without breaking, and last night the playground bent with them. The slide now loops back into itself like a ribbon.",
		weight = 12,
		once = true,
		when = { district = "d16", minAge = 7, maxAge = 11 },
		choices = {
			{
				label = "Ride it",
				hint = "Health check.",
				clash = { stat = "health", foe = "A slide that loops", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { health = 1, sanity = 3, log = "You came out the bottom laughing so hard you couldn't stand. You rode it forty times before the District straightened it." },
				lose = { health = { -3, -2 }, sanity = -3, log = "You came out the bottom dizzy and the wrong way up, with the sky under your feet for a second. You sat on a bench for an hour." },
			},
			{
				label = "Watch the older kids",
				result = { mind = 1, log = "One boy took two minutes to come out of a slide that takes ten seconds. He said it was nice in there." },
			},
			{
				label = "Report it to the building office",
				result = {
					intelligence = 1,
					log = "The clerk didn't look up from his form.",
					dialogue = { { who = "The Clerk", line = "Structurally, the slide is safe. Spatially is another department." } },
				},
			},
		},
	},
	{
		id = "kl_d18_rabbits",
		title = "Rabbits and Rhinos",
		art = "street",
		text = "Every kid in District 18 plays Rabbits and Rhinos, and nobody ever wants to be the Reindeer. Today a real Rabbit on leave is watching from a doorway.",
		weight = 12,
		once = true,
		when = { district = "d18", minAge = 8, maxAge = 12 },
		dialogue = {
			{ who = "A Rabbit on Leave", line = "Your formation's wrong. Rabbits don't bunch. Spread out. Further." },
			{ who = "A Rabbit on Leave", line = "Further than that. Good. Now nobody gets all of you at once." },
		},
		choices = {
			{
				label = "Do what he says",
				result = { strength = 2, setFlags = { "knows_wings" }, log = "You spread out and won every game that afternoon. He watched until dark, then walked back toward the barracks without saying goodbye." },
			},
			{
				label = "Ask him to play",
				result = { sanity = 2, setFlags = { "knows_wings" }, log = "He said no, then played one round as the Rhino and let you win. He laughed once, very loud, like it surprised him." },
			},
			{
				label = "Ask how many came back",
				result = {
					mind = 1,
					sanity = -3,
					setFlags = { "knows_wings" },
					codex = "wg_lore_rcorp",
					log = "Nobody wanted to play after that. You went home early.",
					dialogue = { { who = "A Rabbit on Leave", line = "More than last time." } },
				},
			},
		},
	},
	{
		id = "kl_d19_goat",
		title = "The Court's Goat",
		art = "street",
		text = "A goat with an S Corp brand on its ear has wandered out of the Nest farms and is eating your neighbor's washing. There's already a reward notice for it on the pole.",
		weight = 12,
		once = true,
		when = { district = "d19", minAge = 7, maxAge = 11 },
		choices = {
			{
				label = "Catch it",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A very determined goat", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { strength = 1, money = 15, log = "It took an hour, with the whole street watching. The Court's farmhand paid fifteen Ahn and called you \"subject,\" which you didn't like." },
				lose = { health = -2, sanity = -3, log = "The goat won, twice. A farmhand came, whistled once, and it walked over to him like it had always meant to." },
			},
			{
				label = "Hide it in the stairwell",
				result = { sanity = 2, setFlags = { "kl_hid_goat" }, log = "It lived in the stairwell for three days and ate a doormat. When two men from the Court came asking door to door, you let it out the back." },
			},
			{
				label = "Point the farmhands to it",
				result = { mind = 1, money = 5, log = "They gave you five Ahn of the fifteen, because you hadn't caught it, they said." },
			},
		},
	},
	{
		id = "kl_d20_describe",
		title = "What Orange Looks Like",
		art = "checkpoint",
		text = "A Nest boy in gray comes to the checkpoint fence every Sunday to look at the market. He's offered you one Ahn for every color you can describe to him.",
		weight = 12,
		once = true,
		when = { district = "d20", side = "backstreets", minAge = 8, maxAge = 12 },
		codex = "wg_lore_tcorp",
		choices = {
			{
				label = "Describe the fruit stall",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A boy who's never seen orange", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, money = 6, log = "Orange like the inside of a stove. Red like a shout. He paid six Ahn and wrote every word down." },
				lose = { sanity = -3, log = "You said orange was like orange. He waited. You couldn't think of anything else, and he went home with his Ahn." },
			},
			{
				label = "Show him your orange hat",
				result = { sanity = 2, log = "He looked at it through the bars for a full minute. Then he said thank you and went home without paying, which was fair." },
			},
			{
				label = "Ask what gray is like",
				result = {
					mind = 1,
					log = "He said it twice, like he was checking.",
					dialogue = { { who = "The Gray Boy", line = "Restful. Mother says it's restful." } },
				},
			},
		},
	},
	{
		id = "kl_d21_pier",
		title = "The Pier Got Shorter",
		art = "outskirts",
		text = "Overnight the Great Lake took the last twenty meters of the pier. The kids are daring each other to walk to the new end, where the boards stop over gray water.",
		weight = 12,
		once = true,
		when = { district = "d21", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Walk to the end",
				hint = "Mental Strength check. Boards that creak back.",
				clash = { stat = "mind", foe = "Boards that creak back", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, sanity = 1, log = "You walked to the last board and looked down. The water was too dark to see the pier going on underneath. Nobody laughed on the way back." },
				lose = { health = -2, sanity = -4, log = "A board dropped away under your heel and splashed somewhere far below. You crawled back. The lake made a sound like it was disappointed." },
			},
			{
				label = "Fish off the side instead",
				result = { intelligence = 1, money = 3, log = "You caught a tin can with something living in it. A man bought it off you for three Ahn and wouldn't say what for." },
			},
			{
				label = "Tell the harbor man",
				result = { mind = 1, log = "He put a rope across the pier and a sign that said NO. The next week the rope was gone too." },
			},
		},
	},
	{
		id = "kl_d23_sauce",
		title = "The Sauce Spy",
		art = "diner",
		text = "On District 23's Streets of Flavor, Chef Amadou pays you to stir his pot and keep your mouth shut. The chef across the road has just waved you over with a sweet.",
		weight = 12,
		once = true,
		when = { district = "d23", side = "backstreets", minAge = 8, maxAge = 12 },
		dialogue = {
			{ who = "Chef Galland", line = "Little one. What goes in Amadou's green sauce? Just the purple salt part." },
		},
		choices = {
			{
				label = "Lie about the recipe",
				hint = "Charisma check. He can taste a lie.",
				clash = { stat = "charisma", foe = "A chef who can taste a lie", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { charisma = 2, money = 5, log = "Lemon and fish bones, you said. He made terrible green sauce for a week, and Chef Amadou paid you double when he heard." },
				lose = { sanity = -3, log = "He tasted the lie before you'd finished. \"Lemon,\" he said. \"Amadou would never.\" He kept the sweet." },
			},
			{
				label = "Tell him the truth",
				result = { money = 10, sanity = -3, setFlags = { "kl_sold_recipe" }, log = "Ten Ahn for one ingredient. The next week his green sauce was better than Amadou's, and Amadou never found out why." },
			},
			{
				label = "Tell Chef Amadou",
				result = { strength = 1, money = 3, log = "Amadou laughed so hard he burned the onions, then sent you back with a fake recipe, written out, to sell for the sweet." },
			},
		},
	},
	{
		id = "kl_d23_vans",
		title = "The Gray Vans",
		art = "train",
		text = "Every morning at six, two gray vans with no windows park at the WARP platform, and people in long coats carry long cases inside. Nobody on the platform watches them, so you do.",
		weight = 12,
		once = true,
		when = { district = "d23", minAge = 9, maxAge = 12 },
		codex = "wg_lore_cleanup",
		choices = {
			{
				label = "Count the cases",
				result = { intelligence = 1, setFlags = { "knows_wings", "kl_counted_cases" }, log = "Six cases in, eight cases out. You asked a platform sweeper about the extra two. He said \"cleanup\" and swept somewhere else." },
			},
			{
				label = "Get close to a van",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A man in a long coat", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 1, sanity = -2, setFlags = { "knows_wings" }, log = "Close enough to read the side: W CORP CLEANUP, LEVEL 3 CREW. A woman in a coat looked at you and put a finger to her lips." },
				lose = { sanity = -4, setFlags = { "knows_wings" }, log = "A man in a long coat stepped in front of you and stayed there. He didn't say anything. You walked away backward." },
			},
			{
				label = "Ask the ticket seller",
				result = {
					mind = 1,
					setFlags = { "knows_wings" },
					log = "She shut her little window and put up a sign that said BACK SOON.",
					dialogue = { { who = "The Ticket Seller", line = "Trains get dirty. Somebody cleans them. You want a ticket? No? Then off." } },
				},
			},
		},
	},

	-- ── families ───────────────────────────────────────────────────────────
	{
		id = "kl_fd_bunk",
		title = "Bunk Count",
		art = "home",
		text = "At the Foundling House, Matron counts the bunks every night at 2:50 with a lamp. Tonight she counts twice. Bunk nine is empty, and you know where Nicu goes.",
		weight = 14,
		once = true,
		when = { flags = { "foundling" }, minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Tell her about the fence",
				result = { mind = 1, sanity = -2, setFlags = { "knows_night", "kl_fd_told" }, log = "Matron took the lamp and went. She came back at 3:11 holding Nicu by the wrist, and neither of them said a word about it, ever." },
			},
			{
				label = "Say nothing",
				result = { sanity = -4, setFlags = { "knows_night" }, log = "Nicu came in at dawn, white as paper, and never went out at night again. He never asked if you'd told. You hadn't." },
			},
			{
				label = "Climb into bunk nine",
				result = { strength = 1, sanity = -2, setFlags = { "knows_night" }, log = "You lay in bunk nine so the count came out right. Matron stopped at you, counted again, and wrote ALL PRESENT. She left the lamp on." },
			},
		},
	},
	{
		id = "kl_fd_birthday",
		title = "Pick a Birthday",
		art = "home",
		text = "Nobody knows when you were born, so the Foundling House lets you pick a day once you can write. Matron hands you the calendar and a pencil.",
		weight = 14,
		once = true,
		when = { flags = { "foundling" }, minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Pick the day you were found",
				result = { sanity = 2, setFlags = { "kl_fd_found_day" }, log = "Matron said it was the saddest choice anyone had ever made. She baked you a cake on it anyway, every year." },
			},
			{
				label = "Pick midsummer",
				result = { mind = 1, sanity = 2, log = "You picked midsummer, because dawn comes soonest after the Night. Matron said it was the cleverest reason she'd ever heard." },
			},
			{
				label = "Pick today",
				result = { sanity = 3, log = "Matron stuck a candle in a bun right there, and the whole Foundling House sang, badly." },
			},
		},
	},
	{
		id = "kl_fx_phone",
		title = "The Office Phone",
		art = "office",
		text = "Your parents are out on a job, and the Office phone has been ringing for five minutes. Nobody answers it but grown-ups. It rings again.",
		weight = 14,
		once = true,
		when = { flags = { "fixer_blood" }, minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Answer as the secretary",
				hint = "Mental Strength check. Use your deepest voice.",
				clash = { stat = "mind", foe = "A client who wants a grown-up", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = {
					mind = 2,
					setFlags = { "knows_fixers" },
					log = "You quoted a rate and wrote the job on the board. Your parents came home to a booked contract and didn't know whether to be proud.",
					dialogue = { { who = "A Client", line = "A retrieval. My mother's ring. What's your rate?" } },
				},
				lose = {
					sanity = -3,
					setFlags = { "knows_fixers" },
					log = "The client hung up. At dinner your parents found out why the contract went to the Office down the street.",
					dialogue = { { who = "A Client", line = "Is this a child? Is your Office run by a child?" } },
				},
			},
			{
				label = "Let it ring",
				result = { mind = 1, log = "It rang eleven times and stopped. In the morning someone said it had probably been a big job, and kept looking at the phone." },
			},
			{
				label = "Say nobody's home",
				result = { strength = 1, sanity = 1, log = "\"Call back after nine,\" you said. The client called back at nine exactly. You'd never felt so important." },
			},
		},
	},
	{
		id = "kl_fx_whetstone",
		title = "The Whetstone",
		art = "office",
		text = "The Office's good blade is laid out on the desk with a whetstone and a cloth. You're allowed to oil the guard. You are not allowed to touch the edge.",
		weight = 12,
		once = true,
		when = { flags = { "fixer_blood" }, minAge = 7, maxAge = 10 },
		choices = {
			{
				label = "Oil the guard, carefully",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A very sharp afternoon", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, log = "You oiled the guard until it shone and never went near the edge. Somebody checked it and nodded, which was a lot, at the Office." },
				lose = { sanity = -3, log = "You dropped the cloth, grabbed for it, and stopped an inch from the edge. You sat very still until somebody came in." },
			},
			{
				label = "Try holding it",
				result = { strength = 1, sanity = -1, log = "It was heavier than it looked, and it wanted to point somewhere. You put it down before it found somewhere." },
			},
			{
				label = "Go and play outside",
				result = { sanity = 1, log = "When you came back the blade was in its case, and the case was locked." },
			},
		},
	},
	{
		id = "kl_lc_long_hug",
		title = "Four in the Morning",
		art = "home",
		text = "{father} comes home from L Corp at four in the morning, which is after three, and nobody asks how. He doesn't take his coat off. He just holds on to you for a long time.",
		weight = 14,
		once = true,
		when = { flags = { "lcorp_family" }, district = "d12", world = { era = "wings" }, hasRelation = "father", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Hold on back",
				result = { sanity = 2, relationBond = { kind = "father", amount = 8 }, setFlags = { "knows_lcorp" }, log = "You stood in the hall in your pajamas until he let go. His coat smelled of nothing at all, like a very clean room." },
			},
			{
				label = "Ask what happened at work",
				result = {
					sanity = -3,
					setFlags = { "knows_lcorp" },
					log = "He went to bed without taking off his shoes.",
					dialogue = {
						{ who = "{father}", line = "Nothing. A quiet day. Everybody went home." },
						{ who = "{father}", line = "Almost everybody." },
					},
				},
			},
			{
				label = "Make him tea",
				result = { intelligence = 1, relationBond = { kind = "father", amount = 6 }, log = "Too much sugar, the way he makes it for you. He drank all of it standing up, still in his coat." },
			},
		},
	},
	{
		id = "kl_sw_medal",
		title = "The Medal",
		art = "street",
		text = "You've brought your father's war medal out to show the street. Anton from the bakery says Smoke War veterans are cursed, loud enough for everyone, and holds out his hand for it.",
		weight = 14,
		once = true,
		when = { flags = { "smoke_war_family" }, minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Fight him for saying it",
				clash = { stat = "strength", foe = "Anton from the bakery", coins = 1, base = 2, coinPower = 2, fixed = true, fight = true, enemy = "bully" },
				win = { strength = 2, sanity = 2, log = "Anton went home early. You had the medal back in its box before your father got in, and he never knew it had been out." },
				lose = { health = { -4, -2 }, sanity = -4, log = "Anton threw the medal in the canal. Your father found out. He didn't shout. He went and stood by the canal until dark." },
			},
			{
				label = "Put it back in your pocket",
				result = { mind = 1, sanity = -2, log = "Anton said that proved it. You walked home with your hand closed around the medal the whole way." },
			},
			{
				label = "Tell them what you know",
				result = { strength = 1, codex = "bs_lore_smoke_war", log = "The summer of flies, the little you knew. Nobody laughed. Anton went quiet and asked to hold the medal, and you let him." },
			},
		},
	},
	{
		id = "kl_rn_hats",
		title = "Two Tall Hats",
		art = "market",
		text = "Two men in tall black hats are walking slowly through the market, showing a drawing to every stall. {father} sees them and pulls you into a doorway without a word.",
		weight = 14,
		once = true,
		when = { flags = { "runaway_family" }, hasRelation = "father", minAge = 7, maxAge = 11 },
		choices = {
			{
				label = "Keep perfectly still",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Two men who look in doorways", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, setFlags = { "knows_fixers", "kl_rn_hid" }, log = "They passed close enough to touch. {father} breathed out only when they'd turned the corner. That night you moved to a different shed." },
				lose = { sanity = -4, setFlags = { "knows_fixers" }, log = "One of them stopped and looked straight at you, then at {father}. Then at the drawing again. He frowned, and walked on." },
			},
			{
				label = "Ask who they were, later",
				result = {
					mind = 1,
					setFlags = { "knows_fixers" },
					log = "He made you practice hiding in doorways every evening for a month.",
					dialogue = {
						{ who = "{father}", line = "Ch'unokkun. Fixers for the Court. They bring people back." },
						{ who = "{father}", line = "Whether they want to come or not." },
					},
				},
			},
			{
				label = "Go and look at the drawing",
				result = { sanity = -3, setFlags = { "kl_rn_drawing" }, log = "The stall they'd stopped at still had it. It was {father}, younger, in a Court collar. The stallholder said nothing and gave you an apple." },
			},
		},
	},
	{
		id = "kl_hy_string",
		title = "Measuring the Room",
		art = "home",
		text = "In Hongyuan your room is the size of your family's fortune. Once a month you measure it with a piece of string, and this month the string is too long by a hand.",
		weight = 14,
		once = true,
		when = { flags = { "hongyuan_family" }, minAge = 7, maxAge = 11 },
		codex = "bs_lore_hongyuan_rooms",
		choices = {
			{
				label = "Tell the family",
				result = { mind = 1, sanity = -3, log = "The grown-ups measured it themselves, twice. Then they cut the extra off the string, and nobody said anything at dinner." },
			},
			{
				label = "Cut the string yourself",
				result = { intelligence = 1, sanity = -1, setFlags = { "kl_cut_string" }, log = "You cut off a hand's length and measured again. Perfect. You did it every month after, and nobody noticed for a year." },
			},
			{
				label = "Move your bed to make room",
				result = { intelligence = 1, sanity = 1, log = "You pushed the bed against the wall and stood the chairs on the table. The room looked enormous. It wasn't." },
			},
		},
	},
	{
		id = "kl_bf_classmate",
		title = "Can I Come Over?",
		art = "theater",
		text = "A girl from the academy wants to come to your house after school. Your house is a shuttered theater, and your family sleeps until dark and takes a red tonic with dinner.",
		weight = 14,
		once = true,
		when = { flags = { "bf_family_raised" }, minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Invite her, before sundown",
				hint = "Mental Strength check. A curious classmate.",
				clash = { stat = "mind", foe = "A very curious classmate", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, setFlags = { "kl_bf_friend" }, addRelation = { kind = "friend", name = "Lise Arno", bond = 55, age = { 8, 12 } }, log = "You showed her the stage and the costume racks and had her out the door by six. She said your family must be rich, to sleep so much." },
				lose = { sanity = -4, log = "She found the curtain to the back rooms at five past six. A voice behind it said \"Good evening.\" She went home fast and didn't talk to you at school." },
			},
			{
				label = "Make an excuse",
				result = { mind = 1, sanity = -2, log = "You said your family was strict. She said hers was too, and asked you to hers instead. Her house had windows. You walked home fast." },
			},
			{
				label = "Ask the Family first",
				result = {
					sanity = 1,
					log = "Dinner was soup and bread, and everyone very polite. She said your family had the best manners she'd ever seen.",
					dialogue = { { who = "The Family's Steward", line = "Of course. Bring her to dinner. We'll eat early. We'll eat bread." } },
				},
			},
		},
	},

	-- ════ follow-ups (weight 0, ages 13-18) ════════════════════════════════
	{
		id = "kl_nest_old_paper",
		title = "The Paper He Kept",
		art = "school",
		text = "Proctor Lind is retiring, and he's handing back every entrance exam he ever kept. Yours is in a brown envelope with your number on it, from when you were ten.",
		weight = 0,
		when = { flags = { "kl_nest_exam_sat" }, minAge = 13, maxAge = 17 },
		dialogue = {
			{ who = "kl_proctor_lind", line = "I read every paper twice. Nobody believes that. I did." },
		},
		choices = {
			{
				label = "Read your own answers",
				requires = { flags = { "kl_nest_passed" } },
				result = { mind = 2, sanity = -2, log = "Neat and right and very careful. In the margin of the last page, in pencil: Will be fine. Will not be happy." },
			},
			{
				label = "Find where you froze",
				requires = { flags = { "kl_nest_failed" } },
				result = { sanity = 4, log = "Question nine. In the margin, in pencil: Not stupid. Frightened. Different thing." },
			},
			{
				label = "Look for question four",
				requires = { flags = { "kl_nest_helped" } },
				result = { strength = 1, sanity = 3, log = "Question four was blank. Beside it, in pencil: Answer given to neighbor. Correct. Marked correct." },
			},
			{
				label = "Read the note on the front",
				result = { mind = 1, sanity = 1, log = "On the front, in pencil: Did what was asked. You never worked out if that was praise." },
			},
		},
	},
	{
		id = "kl_hesper_again",
		title = "Hesper in the Line",
		art = "checkpoint",
		text = "At the Nest checkpoint you see Hesper again, older, in the line of people with work passes, holding her papers flat in both hands. She sees you too.",
		weight = 0,
		when = { minAge = 14, maxAge = 19 },
		choices = {
			{
				label = "Go and stand with her",
				result = {
					sanity = 3,
					log = "You stood in the line with her until the gate, an hour. She talked about page forty the whole time.",
					dialogue = { { who = "kl_hesper", line = "Look at you. Did you ever read page forty properly? Don't. It's still wrong." } },
				},
			},
			{
				label = "Say sorry",
				requires = { flags = { "kl_hesper_fired" } },
				result = {
					strength = 1,
					sanity = 2,
					log = "She squeezed your hand once, and then it was her turn at the gate.",
					dialogue = { { who = "kl_hesper", line = "You were nine. I knew the job. Nobody keeps a tutor who tells the truth." } },
				},
			},
			{
				label = "Ask about her night school",
				requires = { flags = { "kl_hesper_kept" } },
				result = { intelligence = 1, mind = 1, setFlags = { "kl_hesper_school" }, log = "She gave you an address above a noodle shop. CLASS AT NINE. BRING YOUR OWN CHAIR." },
			},
			{
				label = "Pretend you don't see her",
				result = { sanity = -3, log = "You looked at your shoes until the line moved. When you looked up she was through the gate, and she didn't look back." },
			},
		},
	},
	{
		id = "kl_tobi_grown",
		title = "A Parcel Through the Bars",
		art = "checkpoint",
		text = "Tobi is at the fence again, taller, in a courier's vest. He has a parcel for an address inside the wall and no pass to get it there.",
		weight = 0,
		when = { side = "nest", flags = { "kl_tobi_friend" }, minAge = 13, maxAge = 18 },
		dialogue = {
			{ who = "kl_tobi", line = "Still eat peaches? Good. One favor." },
			{ who = "kl_tobi", line = "Twenty steps to the post box on your side. Twenty steps, and I keep my job." },
		},
		choices = {
			{
				label = "Walk it to the post box",
				hint = "Mental Strength check. The drones.",
				clash = { stat = "mind", foe = "A drone on its rounds", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 2, sanity = 3, money = 10, log = "Twenty steps, one post box, no drone. Tobi pushed ten Ahn through the bars and wouldn't take it back." },
				lose = { sanity = -5, log = "A drone hovered over the post box and blinked at the parcel. You posted it anyway. A letter came about unregistered deliveries." },
			},
			{
				label = "Open it first",
				result = { mind = 1, sanity = -1, log = "A knitted hat, and a note: FOR MIRA IN 4C. I'M FINE. DON'T COME OUT. You tied the string back exactly and posted it." },
			},
			{
				label = "Say no",
				result = { sanity = -2, log = "He nodded like he'd expected it, and took the parcel back along the fence. He didn't come to that spot again." },
			},
		},
	},
	{
		id = "kl_nest_audit",
		title = "The Audit",
		art = "school",
		text = "The academy is auditing old test results. Your name is on a list of forty, for a perfect score you got when you were eleven.",
		weight = 0,
		when = { side = "nest", flags = { "kl_bought_answers" }, minAge = 13, maxAge = 17 },
		dialogue = {
			{ who = "The Auditor", line = "Forty perfect scores in one class. A remarkable year. We'd like to understand it." },
		},
		choices = {
			{
				label = "Confess",
				result = { strength = 2, sanity = -3, setFlags = { "kl_confessed" }, log = "You told them about Pieter and the thirty Ahn. They thanked you, wrote it down, and lowered every grade you'd had that year." },
			},
			{
				label = "Say you studied",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "An auditor with a calculator", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 2, log = "Twenty minutes about flash cards. The auditor put a tick by your name, then a question mark by the tick." },
				lose = { intelligence = -1, sanity = -5, setFlags = { "kl_audit_flagged" }, log = "He asked you question seven from that test. You didn't know it. He wrote one word by your name and thanked you for your time." },
			},
			{
				label = "Say everyone did it",
				result = { mind = 1, sanity = -2, log = "\"Yes,\" said the auditor. \"That's the problem.\" All forty of you lost the year's grades together, which was almost a comfort." },
			},
		},
	},
}
