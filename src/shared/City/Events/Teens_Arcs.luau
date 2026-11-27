--[[
	Teens, later (tn_a_): the payoffs, ages 18-22, of choices made at 13-17. Everything here
	is weight 0 and reached only through `schedule`; each `when` is re-checked when it comes
	due, so an arc quietly ends if its flags don't fit.
		tn_a_ferro_bench    Ferro & Daughter (tn_ferro_known)        a bench, or your own mark
		tn_a_kostya_trunk   the Lamp Street route (tn_kostya_route)   a Devyat' trial
		tn_a_bao_keys       the diner (tn_bao_job)                    a month with the keys
		tn_a_ilka_clinic    the clinic runner (tn_ilka_runner)        Ilka's own clinic
		tn_a_ines_exam      Coffee Money (tn_ines_known)              a sponsored Hana exam
		tn_a_matteo         the tin (tn_matteo_owes or tn_lost_tin)   who owes whom
		tn_a_renner         the scout (tn_scouted)                    a Wing offer letter
		tn_a_jun_office     the crew, nobody lost                     Jun's Grade 9 Office
		tn_a_jun_awls       the crew, Kip lost (tn_lost_kip)          Jun with the Night Awls
		tn_a_dasha_window   Dasha passed (tn_dasha_passed)            one residence application
		tn_a_dasha_laundry  Dasha failed (tn_dasha_failed)            her laundry cram class
		tn_a_kip_sister     Kip lost                                  his sister on a fire escape
		tn_a_oren           the scholarship kid (tn_oren_friend)      Oren at the Records window
		tn_a_celeste        the camera (tn_stopped_celeste)           Celeste's favor
		tn_a_sibling_home   a sibling out of the pack                 fifty Ahn in an envelope
		tn_a_sibling_canal  a sibling still in it (tn_sibling_still_rat)
		tn_a_soldato        the courtesy inspection (tn_bowed_right)  a Capo remembers
		tn_a_cadet          the Cadet Corps (tn_cadet)                a first posting
		tn_a_uncle          Dorin's uncle (tn_beat_nephew)            a five-year grudge
		tn_a_index_slip     the Proselyte (tn_told_proselyte)         your own words on a slip
		tn_a_fell_nest      out of the Nest (tn_fell_from_nest)       reapply, or don't
		tn_a_roster         the Junior Roster (tn_junior_roster)      your place in the Pack
]]

return {
	{
		id = "tn_a_ferro_bench",
		title = "The Second Bench",
		art = "workshop",
		text = "Old Ferro has stopped coming down to the Workshop. Lia runs it alone now, and she's cleared the second bench and hung your old apron on it.",
		dialogue = {
			{ who = "tn_lia", line = "Dad says you were the only kid who swept the corners. I need someone who sweeps the corners." },
		},
		weight = 0,
		when = { flags = { "tn_ferro_known" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Take the bench", requires = { career = "none", min = { intelligence = 22 } }, result = { career = "workshop", intelligence = 2, sanity = 3, setFlags = { "tn_lia_bench" }, log = "Lia painted FERRO & DAUGHTER & on the window and left a gap. \"When you've earned it,\" she said." } },
			{
				label = "Forge your own blade first",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Your first real blade", coins = 2, base = 3, coinPower = 2, fixed = true },
				win = { intelligence = 3, wage = { 40, 90 }, setFlags = { "tn_own_mark" }, log = "Three weeks, two failures, one blade. Lia stamped the Workshop's mark on it and let you stamp yours beside it." },
				lose = { intelligence = 1, sanity = -4, log = "It cracked in the quench. Lia hung it on the wall with the others, and said everyone's first one is up there." },
			},
			{ label = "Visit Ferro instead", result = { sanity = 4, mind = 1, log = "He was in a chair by the window, complaining about the rail. He asked if the corners were swept, and you said yes." } },
		},
	},
	{
		id = "tn_a_kostya_trunk",
		title = "A Letter for the Devyat'",
		art = "office",
		text = "Kostya hands you an envelope with a Devyat' seal he shouldn't still have. Inside is a signed letter of recommendation and a date for a trial run.",
		dialogue = {
			{ who = "tn_kostya", line = "Section 9 owes me a favor. You're the favor. Don't make me regret it in front of them." },
		},
		weight = 0,
		when = { flags = { "tn_kostya_route" }, minAge = 18, maxAge = 22 },
		choices = {
			{
				label = "Run the trial",
				hint = "Strength check. They time it to the second.",
				clash = { stat = "strength", foe = "A Devyat' trial route", coins = 2, base = 3, coinPower = 2, fixed = true },
				win = { strength = 3, wage = { 60, 120 }, setFlags = { "tn_devyat_trial", "knows_fixers" }, log = "Forty seconds under. The Section Director signed something and said a trunk would be waiting once you had a licence." },
				lose = { sanity = -5, setFlags = { "knows_fixers" }, log = "Nine seconds over. Kostya walked you home and said nine seconds was a very small number, which it isn't, to them." },
			},
			{ label = "Stay on the route with Kostya", result = { sanity = 3, wage = { 40, 80 }, log = "You tore the letter in half and gave him one half. You ran Lamp Street together until his knees went." } },
		},
	},
	{
		id = "tn_a_bao_keys",
		title = "Bao's Keys",
		art = "diner",
		text = "Bao is going to her sister's in another District for a month, the first time in thirty years. She isn't closing, though: she's holding out the keys.",
		dialogue = {
			{ who = "tn_bao", line = "Chairs up at half one. The envelope goes out on the last Thursday. Don't make me come back early." },
		},
		weight = 0,
		when = { flags = { "tn_bao_job" }, minAge = 18, maxAge = 22 },
		choices = {
			{
				label = "Run the diner for a month",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A month behind the counter", coins = 2, base = 3, coinPower = 2, fixed = true },
				win = { intelligence = 3, wage = { 60, 140 }, sanity = 3, setFlags = { "tn_ran_bao" }, log = "A month, no fires, and the envelope out on time. Bao counted the till twice and gave you the spare key for keeps." },
				lose = { sanity = -5, money = { -60, -20 }, log = "A pipe burst in week two and you closed for three days. Bao came back early, fixed it, and didn't say a word." },
			},
			{ label = "Tell her you can't", result = { mind = 1, sanity = -2, log = "She closed for the month instead. Her postcard said only: NOODLES HERE ARE WORSE." } },
		},
	},
	{
		id = "tn_a_ilka_clinic",
		title = "Two Cots and a Sign",
		art = "clinic",
		text = "Nurse Ilka finally has her own clinic: one room over a shoe shop, two cots, and a sign she painted herself. She needs an aide who can carry a box without running.",
		weight = 0,
		when = { flags = { "tn_ilka_runner" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Become her aide", requires = { career = "none", min = { intelligence = 30 } }, result = { career = "clinic", intelligence = 2, sanity = 2, log = "First day, you carried a box up the stairs without running. Ilka said you were overqualified." } },
			{ label = "Paint the sign properly", result = { intelligence = 1, sanity = 3, log = "Her letters leaned and yours didn't. She hung both, one above the other, and the street called it the Two Signs clinic." } },
			{ label = "Send her patients", result = { sanity = 2, mind = 1, setFlags = { "tn_ilka_free_stitches" }, log = "You sent every cut and fever you heard of. By winter she had a queue, and you had free stitches for life." } },
		},
	},
	{
		id = "tn_a_ines_exam",
		title = "Sponsored",
		art = "office",
		text = "Hana's licensing exams are next week, and Ines turns up at your door with a sponsorship form: Hinge Office, her signature, your name spelled right.",
		dialogue = {
			{ who = "tn_ines", line = "I spelled it right. That's how you know I mean it. The fee's paid, so you'd better pass." },
		},
		weight = 0,
		when = { flags = { "tn_ines_known" }, minAge = 18, maxAge = 22 },
		choices = {
			{
				label = "Sit the exam",
				hint = "Strength check. Hana's exam.",
				requires = { career = "none" },
				clash = { stat = "strength", foe = "Hana's licensing exam", coins = 2, base = 3, coinPower = 2, fixed = true },
				win = { career = "fixer", sanity = 4, setFlags = { "tn_hinge_office", "knows_fixers" }, log = "Grade 9, Hinge Office. Ines pinned the licence to your collar herself, said it was crooked, and fixed it." },
				lose = { sanity = -5, setFlags = { "knows_fixers" }, log = "You failed the written part by two questions. Ines kept the form and said next season." },
			},
			{ label = "Ask to carry for her instead", result = { wage = { 40, 90 }, strength = 2, setFlags = { "tn_ines_porter", "knows_fixers" }, log = "\"Porter only,\" she said. You carried and waited and watched for a year." } },
			{ label = "Say you've changed your mind", result = { mind = 1, sanity = -1, log = "Ines folded the form into her coat and said it would keep." } },
		},
	},
	{
		id = "tn_a_matteo",
		title = "Matteo Again",
		art = "syndicate",
		text = "Matteo still smiles, but there's a Smiling Faces pin on his lapel now instead of a tin under his arm. He sits down across from you like an appointment.",
		dialogue = {
			{ who = "tn_matteo", line = "Gable Street. You remember. I remember. The question is which of us is owed." },
		},
		weight = 0,
		when = { flags = { "tn_matteo_known" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "\"You owe me for that tin.\"", requires = { flags = { "tn_matteo_owes" } }, result = { wage = { 80, 160 }, sanity = 2, setFlags = { "tn_smiles_favor" }, log = "He paid in full, with interest he'd worked out himself. \"The Faces pay their debts,\" he said." } },
			{ label = "Pay off the tin", requires = { flags = { "tn_lost_tin" }, min = { money = 100 } }, result = { money = -100, sanity = 3, clearFlags = { "tn_lost_tin" }, log = "A hundred Ahn, and he tore the page out of his little book in front of you. It was a very small page." } },
			{
				label = "Work the tin off",
				requires = { flags = { "tn_lost_tin" } },
				clash = { stat = "strength", foe = "The Night Awls, again", coins = 2, base = 3, coinPower = 2, fight = true, enemy = "syndicate" },
				win = { strength = 3, clearFlags = { "tn_lost_tin" }, log = "The Night Awls were waiting again, and this time you went through them. Matteo tore out the page." },
				lose = { health = { -14, -6 }, sanity = -6, cause = "Ran one more errand for the Smiling Faces", log = "It went wrong exactly the way it went wrong the first time. Matteo sighed and wrote a second line under the first." },
			},
			{ label = "Walk out", result = { sanity = -3, log = "You walked out. Matteo finished his tea and paid for yours, which was the frightening part." } },
		},
	},
	{
		id = "tn_a_renner",
		title = "The Offer Letter",
		art = "wing",
		text = "A letter in a Wing envelope, addressed by hand: Renner from the Talent Office has kept your file for five years and would like to discuss a position.",
		dialogue = {
			{ who = "tn_renner", line = "Class 1 Staff. It's the bottom. Everyone starts at the bottom. Most people never get the letter." },
		},
		weight = 0,
		when = { flags = { "tn_scouted" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Accept the position", requires = { career = "none", min = { intelligence = 30 } }, result = { career = "wing", sanity = 3, setFlags = { "tn_renner_hire", "knows_wings" }, log = "You signed in Renner's office. He gave you a badge on a lanyard and said it opens doors, and the doors close behind you." } },
			{ label = "Ask about the others he found", result = { mind = 2, log = "Renner said some were Directors now and some were files. He didn't say which kind he thought you'd be." } },
			{ label = "Decline", result = { strength = 1, sanity = 1, log = "Renner closed the file gently, like a door on a sleeping room. \"It stays open,\" he said, and it didn't." } },
		},
	},
	{
		id = "tn_a_jun_office",
		title = "Red Mist Two",
		art = "office",
		text = "Jun got his licence: Grade 9, the smallest Office on the street, and a coat two sizes too big. He's painted RED MIST TWO on the door, very small, where nobody will see.",
		dialogue = {
			{ who = "tn_jun", line = "First contract's tomorrow. A warehouse, probably Rats. Want to come and hold the door?" },
		},
		weight = 0,
		when = { flags = { "tn_crew" }, notFlags = { "tn_lost_kip" }, minAge = 18, maxAge = 22 },
		choices = {
			{
				label = "Hold the door",
				clash = { stat = "strength", foe = "A warehouse full of Rats", coins = 2, base = 3, coinPower = 2, fight = true, enemy = "rat" },
				win = { strength = 3, wage = { 50, 110 }, setFlags = { "tn_jun_office" }, log = "You held the door and Jun cleared the floor, grinning. He split the fee down the middle, like the old crew jar." },
				lose = { health = { -14, -6 }, sanity = -5, wage = { 20, 40 }, cause = "Held a door for a Grade 9 friend", log = "The door didn't hold, and neither did you. Jun carried you to a clinic and filed the report himself." },
			},
			{ label = "Buy him a better coat", requires = { min = { money = 80 } }, result = { money = -80, sanity = 4, setFlags = { "tn_jun_office" }, log = "He wore it to every job for ten years, until it was worse than the old one." } },
			{ label = "Tell him to be careful", result = { sanity = 1, log = "\"Careful's for Grade 1s,\" Jun said. Then, quieter: \"Dasha said that too.\"" } },
		},
	},
	{
		id = "tn_a_jun_awls",
		title = "Jun, Later",
		art = "syndicate",
		text = "Jun collects for the Night Awls now, on your old street, and he doesn't go up on roofs anymore. He sees you and stops walking.",
		dialogue = {
			{ who = "tn_jun", line = "Don't. Whatever you're going to say about the hut. I hear it every night already." },
		},
		weight = 0,
		when = { flags = { "tn_lost_kip" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Buy him noodles", result = { sanity = 2, setFlags = { "tn_jun_fed" }, log = "You sat under the rail and ate without talking about anything. When he paid, his hands were shaking." } },
			{
				label = "Ask him to quit the Awls",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Jun's guilt", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 3, sanity = 4, setFlags = { "tn_jun_out" }, log = "It took all night. In the morning he took off the scarf, and you burned it together in a diner stove." },
				lose = { sanity = -5, log = "He asked what he was supposed to do instead, sit on a crate on a roof. Then he went back to work." },
			},
			{ label = "Visit Kip's mother with him", result = { sanity = -2, mind = 2, log = "She made tea for both of you and talked about Kip for two hours. Jun cried in the stairwell after, and you let him." } },
		},
	},
	{
		id = "tn_a_dasha_window",
		title = "Dasha's Window",
		art = "nest",
		text = "Dasha is Class 2 Staff at the Wing now, with a desk by a window over your old roof. She writes that she can push one residence application to the top of the pile.",
		dialogue = {
			{ who = "tn_dasha", line = "One. I can do one. I've thought about it for a year and I want it to be you. Don't make me pick again." },
		},
		weight = 0,
		when = { flags = { "tn_dasha_passed" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Let her push yours", requires = { side = "backstreets", min = { money = 150 } }, result = { money = -150, side = "nest", sanity = 4, setFlags = { "tn_dasha_papers" }, log = "The papers came through in nine days. Dasha met you at the gate in her Wing coat and walked you in like a guest." } },
			{ label = "Give it to Kip's family", requires = { flags = { "tn_lost_kip" } }, result = { sanity = 5, strength = 2, log = "Kip's mother and sister moved inside the wall that spring. Dasha didn't argue, because she'd hoped you would say it." } },
			{ label = "Give it to someone on the street", result = { sanity = 4, mind = 1, log = "You gave her the name of the family on the fourth floor with the twins. They went through in spring and left you their good pan." } },
		},
	},
	{
		id = "tn_a_dasha_laundry",
		title = "The Laundry Academy",
		art = "school",
		text = "Dasha never got the seat. She runs a cram class for Backstreets kids in the laundry where the crew used to meet, with the dryers on so nobody hears the answers.",
		weight = 0,
		when = { flags = { "tn_dasha_failed" }, minAge = 18, maxAge = 22 },
		choices = {
			{
				label = "Teach the maths night",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Twelve tired kids and long division", coins = 2, base = 3, coinPower = 2, fixed = true },
				win = { intelligence = 3, sanity = 4, setFlags = { "tn_laundry_teacher" }, log = "One of them got the seat. Dasha cried in the dryer aisle and blamed the steam." },
				lose = { intelligence = 1, sanity = -2, log = "Nobody got the seat that year. Dasha drew up a new timetable that same night." },
			},
			{ label = "Pay for the chalk and paper", requires = { min = { money = 60 } }, result = { money = -60, sanity = 3, log = "Chalk, paper and a second-hand clock. Dasha wrote your name on the wall under SPONSORS, the only name there." } },
			{ label = "Tell her to sit it again", result = { mind = 1, sanity = 1, log = "She said twenty was old for the exam. She didn't say no." } },
		},
	},
	{
		id = "tn_a_kip_sister",
		title = "Kip's Sister",
		art = "rooftop",
		text = "Kip's little sister Lin is eleven now, fast and always hungry, and following a crew of older kids up a fire escape at half past one.",
		weight = 0,
		when = { flags = { "tn_lost_kip" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Walk her home and teach her", result = { mind = 2, sanity = 4, setFlags = { "tn_lin_safe" }, log = "Home by two, and never the roof after two. She said it back to you twelve times, bored, perfectly." } },
			{
				label = "Go up and talk to the crew",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A crew that thinks it's grown up", coins = 1, base = 3, coinPower = 2 },
				win = { charisma = 3, sanity = 3, setFlags = { "tn_lin_safe" }, log = "You told them about a hut and a boy called Kip. They were all home by two that night, and most nights after." },
				lose = { sanity = -4, log = "They laughed at the old person on the fire escape. Lin didn't laugh, and she came down on her own." },
			},
		},
	},
	{
		id = "tn_a_oren",
		title = "Oren at the Window",
		art = "checkpoint",
		text = "Oren works a Records Office window at the checkpoint now, stamping residence papers. He sees you in the queue, and his stamp stops in the air.",
		dialogue = {
			{ who = "tn_oren", line = "Still have the shoes. Don't tell anyone. Do you need anything stamped? Anything at all?" },
		},
		weight = 0,
		when = { flags = { "tn_oren_friend" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Ask him for nothing", result = { sanity = 4, log = "You asked for nothing and talked for ten minutes while the queue grumbled. He waved at you every morning after." } },
			{ label = "Ask him to help a family", result = { sanity = 3, mind = 1, setFlags = { "tn_oren_stamped" }, log = "A Backstreets family with an expired sponsor letter. Oren read the rules twice and found section eleven, the grace clause." } },
			{ label = "Ask about the academy kids", result = { mind = 1, sanity = -1, log = "\"Celeste is an auditor now,\" he said, \"and the fencing team work for her. They still don't say hello.\"" } },
		},
	},
	{
		id = "tn_a_celeste",
		title = "The Favor",
		art = "nest",
		text = "Celeste is a Wing auditor now, very senior for her age, and she sends a car for you. Her office window faces the wall's old observation deck.",
		dialogue = {
			{ who = "tn_celeste", line = "You took a camera off me once. Later I found out what it would have cost my family. I don't like owing people." },
			{ who = "tn_celeste", line = "One favor. Pick it before I change my mind." },
		},
		weight = 0,
		when = { flags = { "tn_stopped_celeste" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "A clean record", result = { sanity = 3, mind = 2, setFlags = { "tn_clean_record" }, log = "She typed for a minute. Somewhere in the Wing, every demerit you ever had stopped existing." } },
			{ label = "Money", result = { wage = { 100, 200 }, log = "An envelope, counted out in front of you. \"Boring,\" she said, \"but honest.\"" } },
			{ label = "Nothing. We're even.", result = { strength = 2, sanity = 4, log = "She stared at you, then laughed, the first real laugh you'd ever heard from her. She sent you home in the car anyway." } },
		},
	},
	{
		id = "tn_a_sibling_home",
		title = "The Envelope",
		art = "home",
		text = "{sibling} turns up at your door with fifty Ahn in an envelope and a long story about the years since the canal.",
		weight = 0,
		when = { hasRelation = "sibling", notFlags = { "tn_sibling_still_rat" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Take the money", result = { money = 50, relationBond = { kind = "sibling", amount = 8 }, log = "You took it, because {sibling} needed you to. They looked lighter on the way out." } },
			{ label = "Push it back across the table", result = { sanity = 3, relationBond = { kind = "sibling", amount = 12 }, log = "You pushed it back and {sibling} pushed it back again. It went on for a while, and ended with noodles." } },
			{ label = "Ask about the old pack", result = { mind = 2, relationBond = { kind = "sibling", amount = 4 }, log = "Two were Fixers now, {sibling} said, one ran a Syndicate, and the rest got swept. \"I got out,\" they added." } },
		},
	},
	{
		id = "tn_a_sibling_canal",
		title = "Still at the Canal",
		art = "alley",
		text = "{sibling} still runs with the canal pack, older than the rest of them now, and thinner. They see you on the bridge and pretend not to.",
		weight = 0,
		when = { hasRelation = "sibling", flags = { "tn_sibling_still_rat" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Offer them a room", result = { sanity = 2, money = -30, relationBond = { kind = "sibling", amount = 15 }, log = "They slept on your floor for a month, then on a mattress for a year. Nobody from the canal came looking." } },
			{
				label = "Get them a job",
				hint = "Intelligence check.",
				requires = { anyCareer = true },
				clash = { stat = "intelligence", foe = "Years of canal habits", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 2, sanity = 4, relationBond = { kind = "sibling", amount = 15 }, log = "Your boss took them on for a trial week. They were terrible for a month and fine for a decade." },
				lose = { sanity = -4, log = "They lasted three days. On the fourth the pack whistled from the street, and they went." },
			},
			{ label = "Walk past", result = { sanity = -4, relationBond = { kind = "sibling", amount = -10 }, log = "You walked past. That night someone left a stolen orange on your step, and you knew who." } },
		},
	},
	{
		id = "tn_a_soldato",
		title = "A Capo Now",
		art = "street",
		text = "The Soldato who used to inspect your street wears a Capo's pin now. He stops in front of you exactly where he stopped years ago.",
		dialogue = {
			{ who = "thumb_capo", line = "You bowed correctly once, as a child. Nobody bows correctly as a child. I remembered." },
		},
		weight = 0,
		when = { flags = { "tn_bowed_right" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Bow, and say \"Capo\"", result = { charisma = 2, sanity = 2, setFlags = { "tn_capo_remembers" }, log = "Correct again. The Thumb's collectors skipped your door that month, and nobody on the street asked why." } },
			{ label = "Ask him for nothing", result = { strength = 1, mind = 1, log = "He said asking would have spoiled it, and moved on to the baker, who still gets it wrong." } },
			{
				label = "Ask what a Capo does",
				hint = "Mental Strength check. Careful.",
				clash = { stat = "mind", foe = "A Capo's patience", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 3, log = "He told you, in one long sentence, about rank and debt and manners. It was the most a Capo had ever said on your street." },
				lose = { sanity = -5, money = { -60, -30 }, log = "He looked at you like you'd spilled something. A fine arrived in the morning, beautifully written." },
			},
		},
	},
	{
		id = "tn_a_cadet",
		title = "First Posting",
		art = "wing",
		text = "Cadet Corps graduates get a first posting at eighteen. Instructor Valk hands out the envelopes herself, one at a time, without expression.",
		dialogue = {
			{ who = "tn_valk", line = "Checkpoint, tower or outer wall. I chose for each of you. Don't trade. I'll know." },
		},
		weight = 0,
		when = { flags = { "tn_cadet" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Take the posting", requires = { career = "none", min = { intelligence = 30 } }, result = { career = "wing", sanity = 2, setFlags = { "tn_cadet_posted", "knows_wings" }, log = "Checkpoint, it said, with the word underlined twice. You started on Monday." } },
			{ label = "Ask her why she chose it", result = { mind = 2, log = "\"Because you'll hate it,\" Valk said. \"People who hate a post do it properly.\"" } },
			{ label = "Hand the envelope back", result = { strength = 1, sanity = 1, log = "You gave it back unopened. Valk put it in her pocket and said it was a good one, which may have been a lie." } },
		},
	},
	{
		id = "tn_a_uncle",
		title = "The Uncle",
		art = "alley",
		text = "Dorin's uncle still runs the Rats by the canal, and he has a long memory for a short man. He steps out of a doorway with four of his pack behind him.",
		dialogue = {
			{ who = "rat_boss", line = "You put my nephew on the cobbles, five years ago. He still talks about it. Every dinner." },
		},
		weight = 0,
		when = { flags = { "tn_beat_nephew" }, minAge = 18, maxAge = 22 },
		choices = {
			{
				label = "Put the uncle down too",
				clash = { stat = "strength", foe = "The canal Rat boss", coins = 2, base = 3, coinPower = 2, fight = true, enemy = "rat_boss" },
				win = { strength = 4, wage = { 60, 140 }, setFlags = { "tn_beat_uncle" }, log = "The pack watched their boss sit down on the cobbles. Then they watched you walk away, and nobody followed." },
				lose = { health = { -14, -6 }, sanity = -6, money = { -60, -20 }, cause = "Settled a five-year grudge with a Rat boss", log = "The pack held you while he took your coat and your money. He said that made you even, and it didn't feel even." },
			},
			{
				label = "Apologize to Dorin",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A Rat boss's pride", coins = 1, base = 3, coinPower = 2 },
				win = { charisma = 3, sanity = 2, log = "You apologized to Dorin over dinner, in front of his uncle. Dorin cried, and the uncle poured you tea." },
				lose = { sanity = -5, money = { -40, -20 }, log = "The uncle said apologies on his street cost forty Ahn. You paid." },
			},
		},
	},
	{
		id = "tn_a_index_slip",
		title = "Your Own Words",
		art = "street",
		text = "A Messenger in a plain gray coat hands you a slip of paper and walks off. On it, in very neat handwriting, is what you told a Proselyte five years ago.",
		weight = 0,
		when = { flags = { "tn_told_proselyte" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Turn the slip over", result = { mind = 2, sanity = -2, setFlags = { "tn_index_noted" }, log = "On the back it said NOTED, CONTINUE. You don't know what it means, and you keep it in your wallet anyway." } },
			{
				label = "Follow the Messenger",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A Messenger who knows the streets", coins = 1, base = 3, coinPower = 2 },
				win = { strength = 2, setFlags = { "tn_index_noted" }, log = "Six streets, then a bakery. The Proselyte from years ago was behind the counter, older, kneading, and didn't look up." },
				lose = { sanity = -3, log = "He turned a corner and wasn't there. A second slip was stuck to the wall at eye height, and it said: Don't." },
			},
			{ label = "Burn it", result = { strength = 1, sanity = -1, log = "You burned it on the stove. The next morning a new slip was under the door with the same words, and the date." } },
		},
	},
	{
		id = "tn_a_fell_nest",
		title = "Reapply",
		art = "checkpoint",
		text = "Four years since your family came out through the gate with a hired cart. A letter says your old residence number is open for reapplication, for a fee.",
		weight = 0,
		when = { flags = { "tn_fell_from_nest" }, side = "backstreets", minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Pay and go back in", requires = { min = { money = 400 } }, result = { money = -400, side = "nest", sanity = 3, log = "Same gate, the other direction. The guard searched your bag on the way in too, which was fair." } },
			{ label = "Tear the letter up", result = { strength = 2, sanity = 2, log = "You tore it up and put it in the stove. Out here the Night comes every night, and you know your neighbors' names." } },
			{ label = "Keep it for later", result = { mind = 1, log = "You put it in the drawer with the residence papers that don't work anymore. It's a full drawer." } },
		},
	},
	{
		id = "tn_a_roster",
		title = "Your Place in the Pack",
		art = "wing",
		text = "A letter from R Corp: the place held for you on the Junior Roster is ready. Report to the recruiting office with your letter of intent and one bag.",
		weight = 0,
		when = { flags = { "tn_junior_roster" }, minAge = 18, maxAge = 22 },
		choices = {
			{ label = "Report for duty", requires = { career = "none" }, result = { career = "rcorp", strength = 2, sanity = -2, setFlags = { "tn_rabbit", "knows_wings" }, log = "One bag and a cot with a number stencilled on it. The sergeant remembered your face, which surprised you both." } },
			{ label = "Tear up the letter of intent", result = { mind = 1, sanity = 1, log = "You tore it up in front of the office. The door stayed open behind you, the way it always does." } },
			{
				label = "Ask for another year",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A sergeant with a quota", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 2, log = "He gave you a year and said the cot would be someone else's. You didn't go back for it." },
				lose = { sanity = -3, money = { -40, -20 }, log = "He said a letter of intent is a contract, and contracts have fees. You paid to walk out." },
			},
		},
	},
}
