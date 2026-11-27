--[[
	Youth, ages 12-17 (area A): the job board, a Workshop apprenticeship, the examinee
	towns and the Wing entrance exam, Rats and the way out, the neighborhood watch, the
	first wage. Several scenes offer a first ordinary job (a career) to anyone without one.
]]

return {
	-- ── Rats ────────────────────────────────────────────────────────────────
	{
		id = "bs_y_tin_cans_job",
		title = "The Big Job",
		text = "The Tin Cans have a plan. A Nest tourist comes to the night market every Friday with a fat purse and no sense, and Bori wants it. You're the lookout: watch for the neighborhood watch, whistle twice if they come. \"In and out by midnight,\" says Bori. \"Home well before three.\"",
		weight = 0,
		when = { flags = { "bs_bori_pack" }, maxAge = 18 },
		choices = {
			{
				label = "Keep watch",
				hint = "Strength check: eyes everywhere at once.",
				clash = { stat = "strength", foe = "A busy market and a nervous pack", coins = 1, base = 2, coinPower = 2 },
				win = { money = { 20, 40 }, sanity = -1, addTrait = "bs_rat_instincts", log = "You spotted the watch coming and whistled twice. The pack melted away with the purse. Your share bought you a coat. You learned to see a whole street at once, and you never really unlearned it." },
				lose = { health = { -5, -2 }, sanity = -3, addTrait = "bs_rat_instincts", log = "You whistled too late. The watch caught two of the Tin Cans, and Grandpa Teo walked them home to their families, which was the worst punishment of all. Bori didn't speak to you for a week. You learned to watch better." },
			},
			{
				label = "Talk Bori into a safer job",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "Bori's plan", coins = 1, base = 2, coinPower = 2 },
				win = { wage = { 15, 30 }, charisma = 2, log = "You found a Workshop that paid for crates unloaded before dawn, no questions asked. The Tin Cans grumbled and did it. It paid less than the purse would have and nobody went home in tears." },
				lose = { sanity = -2, log = "\"Safer,\" said Bori, \"is how you stay a Rat forever.\" They did the job without you. It went fine. You weren't sure how you felt about that." },
			},
			{
				label = "Quit the pack",
				result = { mind = 2, sanity = -2, addTrait = "bs_rat_instincts", log = "You told Bori you were out. She looked at you for a long time. \"Fine,\" she said. \"You were a good Can.\" You kept the habits: the exits, the pockets, the whole street at once." },
			},
		},
	},
	{
		id = "bs_y_rat_recruit",
		title = "The Drainpipe Kids",
		text = "A Rat pack called the Drainpipe Kids has been watching you from the stairwell. Their leader, a boy with one earring and a borrowed Workshop knife, finally steps out. \"You're quick, and you keep your mouth shut. We need one more. Rats eat together.\" He holds out half an orange.",
		weight = 8,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 12, maxAge = 15, notFlags = { "bs_rat_past" } },
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Take the orange",
				result = { strength = 2, money = { 10, 25 }, setFlags = { "bs_rat_past" }, log = "You took the orange. For two years you ran with the Drainpipe Kids: pickpocketing in the night market, sleeping on rooftops in summer, always home before three. You were a Rat, and it was the closest thing to a gang of brothers you'd ever had." },
			},
			{
				label = "Say no, politely",
				result = { mind = 1, log = "You said no, politely. He shrugged and ate the orange himself. \"Your loss,\" he said. They never bothered you after that. Rats respect a clean answer." },
			},
			{
				label = "Tell the watch about them",
				result = { sanity = -1, setFlags = { "bs_watch_kid" }, log = "You told Grandpa Teo where the Drainpipe Kids slept. He thanked you and said he'd \"have a word with their mothers.\" The pack broke up that winter. Two of them glared at you for years." },
			},
		},
	},
	{
		id = "bs_y_rat_way_out",
		title = "Noticed",
		text = "A man in a good coat has been watching your Rat pack work the market all week. Today he sits down next to you on the fountain. He's from a real Syndicate, the Stray Dogs, and they're looking for kids with fast hands. \"Rats get swept,\" he says. \"Dogs get fed. Think about it.\"",
		weight = 12,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", flags = { "bs_rat_past" }, minAge = 14, maxAge = 17 },
		choices = {
			{
				label = "Run one errand for the Stray Dogs",
				hint = "Speed check: a parcel, three streets, no questions.",
				clash = { stat = "speed", foe = "Three streets and a rival pack", coins = 1, base = 3, coinPower = 2 },
				win = { money = { 30, 60 }, setFlags = { "bs_syndicate_noticed" }, addTrait = "bs_rat_instincts", log = "You carried the parcel three streets without looking inside and without stopping. The man in the good coat paid you and said, \"There'll be more.\" There was. You had a choice to make, and you kept not making it." },
				lose = { health = { -6, -2 }, sanity = -2, log = "A rival pack jumped you on the second street and took the parcel. The Stray Dogs' man found you the next day and said, quite kindly, \"Stay a Rat, then.\"", cause = "Jumped by a rival pack" },
			},
			{
				label = "Get out of the life",
				result = { mind = 2, sanity = 2, addTrait = "bs_rat_instincts", log = "You told the pack you were done. Nobody stopped you: Rats don't, that's the one kind thing about them. You kept their tricks and lost their company, and some nights you missed them." },
			},
			{
				label = "Ask what happens to Rats who say no",
				result = { mind = 1, codex = "bs_lore_rats", log = "\"Nothing,\" said the man, standing up. \"That's the problem. Nothing ever happens to them, until the Night does.\" He left you the price of a bowl of noodles on the fountain's edge." },
			},
		},
	},

	-- ── first work ──────────────────────────────────────────────────────────
	{
		id = "bs_y_job_board",
		title = "The Job Board",
		text = "The Fixer office on the corner pins its small jobs on a board outside: work too cheap for a licensed Fixer and just right for a kid. Today: a lost cat (brown, angry), an old man who needs walking home from the bathhouse before two, and a debt reminder to deliver to a fourth-floor flat that has three locks and a reputation.",
		weight = 12,
		once = true,
		when = { minAge = 12, maxAge = 16 },
		choices = {
			{
				label = "Find the cat",
				hint = "Mental Strength check. The cat does not want to be found.",
				clash = { stat = "mind", foe = "A brown, angry cat", coins = 1, base = 2, coinPower = 2 },
				win = { wage = { 15, 30 }, sanity = 2, log = "You found the cat asleep in a laundry vent, extracted it with great loss of dignity, and returned it to a little girl who cried. The Office paid you and wrote your name on the board under REGULARS." },
				lose = { sanity = -1, log = "The cat found you first, scratched you comprehensively, and went home on its own. The Office paid the cat, presumably." },
			},
			{
				label = "Walk the old man home",
				result = { wage = { 10, 20 }, sanity = 3, mind = 1, log = "You walked old Mr. Szabo home from the bathhouse, very slowly, while he told you about every Office that had ever been on the corner. He was home by half past one. He tipped you a sweet from 960." },
			},
			{
				label = "Deliver the debt reminder",
				hint = "Intelligence check: you'll have to talk through the door.",
				clash = { stat = "intelligence", foe = "A voice behind three locks", coins = 1, base = 3, coinPower = 2 },
				win = { wage = { 20, 40 }, intelligence = 1, log = "You read the reminder through the door in your most official voice and slid it under. The voice behind the locks said \"Fine. Fine.\" The Office said you had a future in collections. You weren't sure that was a compliment." },
				lose = { sanity = -2, log = "The voice behind the door told you, at length, where you could put the reminder. You slid it under anyway and ran down four flights. The Office paid you half." },
			},
		},
	},
	{
		id = "bs_y_apprentice",
		title = "The Apprentice's Apron",
		text = "Master Ulrike of Brassfinch Workshop puts down her etching tool and looks at you over the top of her goggles. \"You've swept my floor for four years and asked a thousand questions. Most of them were good.\" She holds out a leather apron, and an oilcloth roll of tools. \"Apprentice. Three years. Pay's terrible. Want it?\"",
		weight = 16,
		once = true,
		when = { flags = { "bs_workshop_window" }, minAge = 13, maxAge = 17 },
		codex = "bs_lore_workshops",
		choices = {
			{
				label = "Put on the apron",
				requires = { career = "none", minAge = 14 },
				result = { career = "workshop", intelligence = 2, gear = "bs_tool_roll", log = "You put on the apron. It was too big. Master Ulrike said you'd grow into it, and that if you ever copied another Workshop's patented work she would personally hand you to the Claws. She was smiling. Mostly." },
			},
			{
				label = "Learn on weekends instead",
				result = { intelligence = 3, setFlags = { "bs_workshop_trained" }, addTrait = "bs_workshop_hands", gear = "bs_tool_roll", log = "You couldn't give her the weekdays, so you gave her every weekend for three years. She taught you to file, fold and etch, and to never, ever copy a mark that isn't yours." },
			},
			{
				label = "Thank her and say no",
				result = { mind = 1, sanity = -1, log = "You said no. Master Ulrike nodded and went back to her blade. \"The floor's still yours,\" she said. You kept sweeping it, now and then, for years." },
			},
		},
	},
	{
		id = "bs_y_workshop_offer",
		title = "Hands Wanted",
		text = "A hand-painted card in a Workshop window: HANDS WANTED, MUST NOT FAINT AT SPARKS. Inside, three smiths are arguing over a prosthetic arm that keeps waving at people. The youngest of them, sweating, spots you reading the card. \"Can you hold something very still for a very long time?\"",
		weight = 5,
		once = true,
		when = { minAge = 14, maxAge = 17, notFlags = { "bs_workshop_window" }, min = { intelligence = 18 } },
		codex = "bs_lore_workshops",
		choices = {
			{
				label = "Hold the arm still",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A friendly prosthetic arm", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 2, wage = { 10, 20 }, setFlags = { "bs_workshop_window" }, log = "You held it still for forty minutes while they rewired the wrist. It waved at you once at the end, gently, as if to say thanks. The smiths told you to come back tomorrow." },
				lose = { health = -2, sanity = 1, setFlags = { "bs_workshop_window" }, log = "It waved, and slapped you across the face, and the whole Workshop laughed until they cried. They told you to come back tomorrow anyway, if only for the entertainment." },
			},
			{
				label = "Sign on as an apprentice",
				requires = { career = "none" },
				result = { career = "workshop", intelligence = 1, log = "You signed on as an apprentice on the spot. The pay was terrible, the burns were frequent, and you loved it from the first day." },
			},
		},
	},
	{
		id = "bs_y_mun_job",
		title = "A Job at Auntie Mun's",
		text = "Auntie Mun's dishwasher has left for the Nest, the lucky thing, and the bowls are piling up. She looks at you over the steam the way she looks at noodles that need more salt. \"You. You've been eating here since you were small enough to sit on the counter. Time you washed something.\"",
		weight = 8,
		once = true,
		when = { side = "backstreets", flags = { "bs_knows_mun" }, minAge = 12, maxAge = 16 },
		choices = {
			{
				label = "Roll up your sleeves",
				requires = { career = "none" },
				result = { career = "diner", sanity = 2, log = "You started that night. The pay was bad, the regulars were worse, and you ate every single day. Auntie Mun shouted at you constantly, which, you learned, meant she liked you." },
			},
			{
				label = "Help out after school instead",
				result = { wage = { 10, 25 }, intelligence = 1, sanity = 2, log = "You washed bowls three evenings a week and went home before one. Auntie Mun paid you in Ahn and in gossip, and the gossip was worth more." },
			},
		},
	},
	{
		id = "bs_y_runner",
		title = "Runner Wanted",
		text = "Old Wendel runs the neighborhood courier route out of a shed by the bathhouse: letters, parcels, rent envelopes, things people would rather not carry themselves. His last runner went to the Devyat' Association, he says, as if that were a betrayal. \"You know the streets? Prove it. This goes to the tailor on Kettle Lane, and I'm timing you.\"",
		weight = 6,
		once = true,
		when = { minAge = 12, maxAge = 16 },
		choices = {
			{
				label = "Run it",
				hint = "Speed check against Wendel's watch.",
				clash = { stat = "speed", foe = "Old Wendel's stopwatch", coins = 1, base = 2, coinPower = 2 },
				win = { speed = 2, wage = { 5, 15 }, setFlags = { "bs_wendel_approved" }, log = "You were back in nine minutes with a signed receipt. Wendel looked at his watch, then at you, and said \"Hm,\" which from Old Wendel is a standing ovation." },
				lose = { speed = 1, log = "Seventeen minutes. Wendel sighed. \"The Devyat' would have had you shot,\" he said. \"I'll just have you practice.\" He gave you the route anyway." },
			},
			{
				label = "Ask for the job outright",
				requires = { career = "none" },
				result = { career = "courier", strength = 1, log = "You asked for the job. Wendel handed you a satchel and a map with half the streets crossed out. \"Those ones move,\" he said. \"Never late. Never curious. Home before three.\"" },
			},
		},
	},
	{
		id = "bs_y_clinic_hands",
		title = "The Clinic Needs Hands",
		text = "The back-alley clinic on your street is one doctor, two beds and a queue out the door. Doctor Seraphine hasn't slept since last Night, and she's just watched you calm a screaming kid in the queue by telling him a story about a cat. \"You,\" she says. \"Can you hold a lamp and not faint?\"",
		weight = 6,
		once = true,
		when = { minAge = 16, maxAge = 19, min = { intelligence = 26 } },
		choices = {
			{
				label = "Become her aide",
				requires = { career = "none" },
				result = { career = "clinic", intelligence = 2, sanity = -1, log = "You held the lamp. You didn't faint. By midnight you were rolling bandages and by morning you had a job. Doctor Seraphine taught you three things that first week: wash your hands, write everything down, and never promise anyone they'll be fine." },
			},
			{
				label = "Help for one night",
				result = { intelligence = 1, sanity = 2, wage = { 10, 20 }, log = "You held the lamp until the queue was gone, a little after one. Doctor Seraphine gave you a coin and an ampule-shaped sweet. \"Come back if you ever want a terrible job,\" she said." },
			},
		},
	},
	{
		id = "bs_y_records_intern",
		title = "The Records Office",
		text = "The Nest Records Office is hiring junior clerks: residence papers, checkpoint passes, tax files, all of it stamped and filed by hand. The notice says applicants must be steady, discreet, and \"untroubled by the requests of the public.\" The queue outside the office is mostly Backstreets families holding papers flat in both hands.",
		weight = 6,
		once = true,
		when = { minAge = 17, maxAge = 22, notDistrict = "d12", min = { mind = 22 } },
		codex = "bs_lore_nests",
		choices = {
			{
				label = "Apply",
				requires = { career = "none" },
				result = { career = "nest_clerk", mind = 1, log = "You were hired after an interview that was mostly about handwriting. Your first day, you stamped two hundred forms. Your second day, you noticed that the forms from the Backstreets went in a different tray. Nobody explained why." },
			},
			{
				label = "Help a family in the queue fill in their forms",
				result = { intelligence = 1, sanity = 3, log = "You spent the afternoon helping a family from the Backstreets fill in eleven pages of residence papers. They were refused anyway, the next week. They came to thank you for trying." },
			},
		},
	},
	{
		id = "bs_y_super_keys",
		title = "The Super's Keys",
		text = "Mr. Albescu, the building super, is retiring to his daughter's place in another District. Someone has to hold the keys: fix the locks, chase the rent, sweep the stairs, and make sure every door on every floor is shut by three. The landlord wants someone young and cheap. Mr. Albescu wants someone who knows the building. He holds out the ring of keys to you.",
		weight = 5,
		once = true,
		when = { side = "backstreets", minAge = 18, maxAge = 24 },
		choices = {
			{
				label = "Take the keys",
				requires = { career = "none" },
				result = { career = "landlord", mind = 1, log = "You took the ring of keys. There were forty-one of them and Mr. Albescu knew what every one opened, including three he wouldn't tell you about. \"You'll find out,\" he said. You did." },
			},
			{
				label = "Help him fix every lock before he goes",
				result = { intelligence = 2, sanity = 2, log = "You spent a week fixing every lock in the building with him. On his last night he showed you which stair creaks, which tenant pays late, and which door to knock on if you're ever caught outside." },
			},
		},
	},

	-- ── the Nest's ladders ──────────────────────────────────────────────────
	{
		id = "bs_y_examinee_town",
		title = "The Examinee Town",
		text = "Three streets over is an examinee town: cheap rooms, cram schools, and hundreds of tired young people studying for a Wing's entrance exam. Pass, and you're a Feather with a badge and a way through the wall. Your family has a little saved. Enough for a room and a year of cram classes, if you want it, and if everyone else goes without.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 13, maxAge = 16, notDistrict = "d12" },
		codex = "bs_lore_examinee",
		choices = {
			{
				label = "Go, and study",
				result = { intelligence = 4, sanity = -3, setFlags = { "bs_examinee" }, schedule = { event = "bs_y_wing_exam", inYears = 2 }, log = "You moved into a room the size of a wardrobe and studied sixteen hours a day with four hundred strangers doing the same. You learned the Wing's history, its rules, its numbers, and how to sleep sitting up." },
			},
			{
				label = "Study at home, for free",
				result = { intelligence = 2, setFlags = { "bs_examinee" }, schedule = { event = "bs_y_wing_exam", inYears = 2 }, log = "You borrowed the examinees' old textbooks and studied at the kitchen table by the streetlight. It was slower. Nobody went without. You liked that better." },
			},
			{
				label = "Say the Nest isn't for you",
				result = { mind = 1, sanity = 1, log = "You said the Nest wasn't for you. Your family argued about it for a week and then, quietly, seemed relieved. The savings went on a new lock and a winter coat." },
			},
		},
	},
	{
		id = "bs_y_wing_exam",
		title = "Entrance Exam",
		text = "The Wing's exam hall is the size of a station and silent as a church of clocks. Four thousand applicants, three hundred places. A Feather in a crisp uniform reads the rules aloud: no talking, no notes, no leaving before the bell, and anyone caught copying is disqualified \"permanently, from everything.\" The papers turn over.",
		weight = 0,
		when = { flags = { "bs_examinee" }, notDistrict = "d12", maxAge = 20 },
		codex = "bs_lore_feathers",
		choices = {
			{
				label = "Take the exam",
				hint = "Intelligence check. The hardest test in the District.",
				clash = { stat = "intelligence", foe = "The Wing entrance exam", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, setFlags = { "bs_passed_wing_exam" }, log = "Your number was on the board. You read it eleven times. Then you sat down on the steps of the exam hall and laughed until you cried. A Feather's life. The Wing would have a desk for you, if you wanted one." },
				lose = { sanity = -4, intelligence = 1, log = "Your number wasn't on the board. You read the whole board three times to be sure. On the walk home an old examinee told you he'd sat it nine times. You didn't know whether that was comforting." },
			},
			{
				label = "Walk out before the papers turn",
				result = { mind = 2, sanity = -1, log = "You looked at the four thousand bowed heads and stood up and walked out. A Feather called after you. You didn't stop until you were back in the Backstreets, and you never once regretted it, mostly." },
			},
		},
	},
	{
		id = "bs_y_nest_placement",
		title = "Placement Day",
		text = "Every Nest child sits the placement exam at fifteen. The results decide which track you'll take: Wing service, the Records Office, the trades, or \"other,\" which nobody in your class will say out loud. Your parents have hired a tutor, bought new pens, and stopped sleeping. You are the only calm person in the house.",
		weight = 12,
		once = true,
		when = { side = "nest", minAge = 14, maxAge = 16 },
		codex = "bs_lore_feathers",
		choices = {
			{
				label = "Aim for Wing service",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "The placement exam", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 3, sanity = 3, setFlags = { "bs_passed_wing_exam" }, log = "Wing service track. Your parents threw a party with people you'd never met. You stood in the middle of it holding your certificate and thinking about the boy behind the gate." },
				lose = { intelligence = 1, sanity = -2, setFlags = { "bs_records_track" }, log = "Records Office track. Your father said it was \"perfectly respectable\" six times at dinner. The Records Office decides who gets through the wall, you pointed out. He went quiet." },
			},
			{
				label = "Aim for the trades, on purpose",
				result = { health = 2, sanity = 2, log = "You answered the trades questions beautifully and the Wing questions badly, on purpose. Trades track. Your parents were devastated for a month. You started building things, and never stopped." },
			},
		},
	},

	-- ── the street at fifteen ───────────────────────────────────────────────
	{
		id = "bs_y_night_dare",
		title = "The Dare",
		text = "The older kids have a dare: stay out until three o'clock exactly, touch the Nest wall, and run home before 3:13. Thirteen minutes. Everyone says they've done it. Nobody you know has done it. Tonight they're daring you, and the whole stairwell is watching.",
		weight = 8,
		once = true,
		tags = { "night", "danger", "backstreets" },
		when = { side = "backstreets", minAge = 14, maxAge = 17 },
		codex = "city_sweepers",
		choices = {
			{
				label = "Do it",
				hint = "Strength check. Losing this one means being outside when the Night begins.",
				clash = { stat = "strength", foe = "Thirteen minutes", coins = 1, base = 3, coinPower = 2 },
				win = { strength = 2, sanity = 3, setFlags = { "bs_did_the_dare" }, log = "You touched the wall at three on the dot and ran. You were through your own door at 3:11, shaking, as the floor began to hum. The stairwell went wild. You never did it again, and you never told anyone how close it was." },
				lose = { trigger = "bs_n_out_wave1", log = "You touched the wall at three and ran, and a gate you'd counted on was chained shut. You heard the clock in the square strike the quarter. 3:13. Behind you, the ground began to hum." },
			},
			{
				label = "Refuse, loudly",
				result = { mind = 2, sanity = 1, log = "\"No,\" you said, loudly, so the whole stairwell heard. \"Being swept isn't brave.\" A few of the older kids laughed. One of them, you noticed, looked relieved." },
			},
			{
				label = "Talk the dare-master out of it",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A stairwell full of pride", coins = 1, base = 2, coinPower = 2 },
				win = { charisma = 2, sanity = 2, log = "You asked the dare-master, in front of everybody, which of his friends had actually done it. He couldn't name one. The dare died on the stairs, and nobody on your street tried it again that year." },
				lose = { sanity = -2, log = "He called you a coward and the stairwell agreed. Two kids went instead. Both made it back. Barely. You didn't sleep." },
			},
		},
	},
	{
		id = "bs_y_watch_patrol",
		title = "Walking With the Watch",
		text = "The neighborhood watch is short a pair of hands, and Grandpa Teo asks if you'll walk the late round with them: lamps, whistles, every door checked by half past two. Halfway down Kettle Lane, four Rats are trying the shutters of the pharmacy.",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 15, maxAge = 18 },
		codex = "bs_lore_watch",
		choices = {
			{
				label = "Run them off",
				clash = { stat = "speed", foe = "Four Rats at the pharmacy", coins = 2, base = 2, coinPower = 2, fight = true },
				win = { speed = 2, sanity = 3, setFlags = { "bs_watch_member" }, log = "You went in with the lamp swinging and the whistle going, and the Rats scattered into the dark. The pharmacist gave the watch a box of bandages. Grandpa Teo gave you the stick, which nobody had ever been given before." },
				lose = { health = { -8, -3 }, sanity = -1, setFlags = { "bs_watch_member" }, log = "One of the Rats was better than you, and you ended the night on the pharmacy step with a split lip. But the whistle had woken the street, and the Rats were gone. You walked with the watch every week after that.", cause = "Beaten by Rats on watch" },
			},
			{
				label = "Blow the whistle and wake the street",
				result = { mind = 1, sanity = 2, setFlags = { "bs_watch_member" }, log = "You blew the whistle until every shutter on Kettle Lane slammed open and a dozen neighbors in nightclothes leaned out shouting. The Rats left. Nobody fought. Grandpa Teo said that was the best kind of night." },
			},
		},
	},
	{
		id = "bs_y_friend_moves",
		title = "Moving Inside",
		text = "Your best friend's family finally got their Nest residence papers, after six years of applications. They're moving inside the wall next week. Your friend is thrilled and miserable at the same time and keeps saying \"it's only across the checkpoint,\" which everyone on the street knows is not \"only\" anything.",
		weight = 8,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 13, maxAge = 17 },
		codex = "bs_lore_nests",
		choices = {
			{
				label = "Help them carry everything to the checkpoint",
				result = { health = 2, sanity = 2, setFlags = { "bs_friend_in_nest" }, log = "You carried boxes to the checkpoint all day. At the gate, the guards checked every box twice and you not at all, because you weren't going in. Your friend waved from the other side of the bars. You waved back." },
			},
			{
				label = "Make them promise to write",
				result = { sanity = 1, mind = 1, setFlags = { "bs_friend_in_nest" }, log = "They promised. The letters came every month for a year, then every season, then on holidays. The paper got whiter and the handwriting got neater. You kept every one." },
			},
		},
	},
	{
		id = "bs_y_first_payday",
		title = "First Payday",
		text = "Your first real wage, counted out into your hand: more Ahn than you have ever held at once. On the walk home you pass the noodle stalls, the Workshop windows, a stall selling good boots, and your own front door, behind which your family has never once had enough.",
		weight = 8,
		once = true,
		when = { anyCareer = true, minAge = 13, maxAge = 18 },
		choices = {
			{
				label = "Give half to the family",
				requires = { hasRelation = { "mother", "father", "sibling" } },
				result = { money = -20, sanity = 4, relationBond = { kind = "family", amount = 8 }, log = "You put half of it on the kitchen table without a word. Nobody said anything either. Then everybody said something at once." },
			},
			{
				label = "Buy the good boots",
				result = { money = -15, health = 2, sanity = 2, log = "You bought the good boots. They lasted eleven years and carried you through things you couldn't have walked through in the old ones." },
			},
			{
				label = "Hide it in your boot and save it",
				result = { intelligence = 1, setFlags = { "bs_saver" }, log = "You hid it in your boot and walked home lopsided. It went in the jar under your bed with the first five Ahn you ever earned. The jar was getting heavy." },
			},
		},
	},
	{
		id = "bs_y_night_school",
		title = "Night School",
		text = "The academy on the corner runs evening classes for people who never got to go: bookkeeping, letters, the history of the Wings. You're the youngest in a room of tired adults. At the end of the year, anyone who passes the final gets a certificate, the same one the day students get.",
		weight = 8,
		once = true,
		when = { minAge = 16, maxAge = 24, notFlags = { "bs_academy_grad", "bs_academy_enrolled" }, min = { intelligence = 32 } },
		choices = {
			{
				label = "Sit the final",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "The final exam", coins = 1, base = 3, coinPower = 2 },
				win = { setFlags = { "bs_academy_grad" }, addTrait = "bs_academy_graduate", sanity = 4, log = "You passed. Teacher Imre handed you your certificate in front of a room of cheering dockhands and cooks, and shook your hand as if you were somebody." },
				lose = { intelligence = 2, sanity = -2, log = "You failed by four marks. Teacher Imre circled every mistake in red and wrote at the bottom: \"Next year. You're nearly there.\"" },
			},
			{
				label = "Help the adults with their reading",
				result = { intelligence = 2, sanity = 3, log = "You spent the year helping a fishmonger, a retired Rat and two grandmothers learn to read the Wing's notices. None of them passed the final. All of them could read their rent papers by the end." },
			},
		},
	},

	-- ── an L Corp family, after the fall ────────────────────────────────────
	{
		id = "bs_y_lcorp_after",
		title = "After the Tower",
		text = "Your parents don't work anymore. Nobody's parents on your street do. The L Corp tower stands dark over District 12, the badges are in a drawer, and the Syndicates have moved into the old Nest like it was always theirs. Some nights your mother sits at the window at three in the morning, looking toward where the light used to be.",
		weight = 15,
		once = true,
		when = { flags = { "lcorp_family" }, district = "d12", world = { era = { "library", "limbus" } }, minAge = 8, maxAge = 17 },
		codex = "bs_lore_d12_after",
		choices = {
			{
				label = "Sit with her",
				result = { sanity = 3, mind = 1, log = "You sat with her at the window. After a long time she said, \"We kept the lights on, you know. For the whole City.\" That was all she ever said about it, and it was a lot." },
			},
			{
				label = "Find work to keep the family going",
				result = { wage = { 15, 35 }, health = 1, log = "You found work hauling salvage out of the old Nest for a scrap dealer. It paid. Your parents didn't ask what the scrap was. Some of it still had the old logo on it." },
			},
			{
				label = "Ask what really happened",
				result = { mind = 2, sanity = -2, codex = "lcorp_fall", log = "\"There was a light,\" said your father. \"And then there wasn't a company.\" He put the badges back in the drawer and locked it. You heard him turn the key twice." },
			},
		},
	},
}
