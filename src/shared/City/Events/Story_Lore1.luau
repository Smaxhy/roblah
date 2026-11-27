--[[
	STORYLINES: Feather Fall (sl_feather_fall) and Courtesy (sl_courtesy). Storylines/Lore.luau.

	FEATHER FALL. A Wing's employees are its Feathers, and a Feather's family lives in the Nest
	only as long as the job lasts. Ages: 3 the badge · 7 the letter · 9 DISMISSED (the family
	is moved out to the Backstreets) · 10 the first Night · 12 the fence · 14 why · 17 the
	Wing's entrance exam · 18 the endings.
	Flags: sl_ff_books / sl_ff_photos / sl_ff_badge_kept, sl_ff_primer, sl_ff_proud / sl_ff_bitter,
	then one of sl_ff_passed / sl_ff_failed / sl_ff_stayed.

	COURTESY. The Thumb is the Finger of rank and manners: it collects from small shops, and a
	shop where a Soldato eats is a shop nobody else touches. Ages: 2 the bow · 5 the spoon ·
	8 lessons · 11 short · 13 the other collector · 15 THE OFFER · 17 the endings.
	Flags: sl_ct_polite / sl_ct_stared, sl_ct_pupil / sl_ct_hater, sl_ct_runner, sl_ct_told,
	then one of sl_ct_soldato / sl_ct_refused / sl_ct_insult.
]]

local FF = "sl_feather_fall"
local CT = "sl_courtesy"

return {
	-- ════ FEATHER FALL ════════════════════════════════════════════════════════
	{
		id = "sl_ff_badge",
		story = FF,
		title = "The Badge on the Hook",
		art = "nest",
		text = "A badge hangs on a hook by your front door, out of your reach. CLASS 3 STAFF. Every morning it goes out, and every evening it comes back. You've been told it's why the walls let you live here.",
		always = true,
		once = true,
		when = { minAge = 3, maxAge = 3 },
		choices = {
			{ label = "Drag a chair over and touch it", result = { strength = 1, setFlags = { "knows_wings" }, log = "It was cold and heavier than it looked. You got it back on the hook before anyone came. Almost straight." } },
			{ label = "Ask what Class 3 means", result = { mind = 1, setFlags = { "knows_wings" }, log = "\"It means there are two classes under us,\" you were told, \"and a great many over.\"" } },
			{ label = "Leave it alone", result = { intelligence = 1, setFlags = { "knows_wings" }, log = "You looked at it from the floor. It looked back, the way important things do." } },
		},
	},
	{
		id = "sl_ff_letter",
		story = FF,
		title = "Dinner, Late",
		art = "nest",
		text = "Dinner is two hours late and nobody says why. There's a letter on the table with the Wing's seal, face down. The badge is on the table next to it. It's never on the table.",
		always = true,
		once = true,
		when = { minAge = 7, maxAge = 7 },
		choices = {
			{
				label = "Read the letter upside down",
				clash = { stat = "mind", foe = "Small print", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, sanity = -2, goal = "Your family's place in the Nest is under review.", log = "PERFORMANCE REVIEW. RESIDENCE STATUS: PENDING. You didn't know \"pending\". You knew the face that went with it." },
				lose = { sanity = -1, goal = "Something is wrong at the Wing. Nobody will tell you what.", log = "Too many long words, upside down. But nobody was eating." },
			},
			{ label = "Ask what's wrong", result = { relationBond = { kind = "family", amount = 4 }, goal = "Something is wrong at the Wing. Nobody will tell you what.", log = "\"Nothing,\" they said, both at once, which is how you knew." } },
			{ label = "Eat quietly and go to bed", result = { intelligence = 1, sanity = 1, goal = "Something is wrong at the Wing. Nobody will tell you what.", log = "You ate everything on your plate. It seemed like the one thing you could do." } },
		},
	},
	{
		id = "sl_ff_notice",
		story = FF,
		title = "Notice of Dismissal",
		art = "checkpoint",
		text = "The Wing has let your family go. A dismissed Feather has three days to leave the Nest, and the guards at the checkpoint weigh the bags. One bag each. You get to choose what goes in yours.",
		always = true,
		once = true,
		when = { minAge = 9, maxAge = 9 },
		choices = {
			{ label = "Your schoolbooks", result = { side = "backstreets", intelligence = 2, sanity = -4, setFlags = { "sl_ff_books" }, goal = "You live outside the walls now. Be home before 3:13.", log = "You packed every book the academy gave you. The guard weighed the bag twice and let it through." } },
			{ label = "The family photographs", result = { side = "backstreets", sanity = -2, relationBond = { kind = "family", amount = 8 }, setFlags = { "sl_ff_photos" }, goal = "You live outside the walls now. Be home before 3:13.", log = "You took the photographs off the wall while nobody was looking. Somebody would want them later." } },
			{ label = "The badge", result = { side = "backstreets", strength = 2, sanity = -4, setFlags = { "sl_ff_badge_kept" }, goal = "You live outside the walls now. Be home before 3:13.", log = "The badge is Wing property. You put it in your sock. The guard never checked your socks." } },
		},
	},
	{
		id = "sl_ff_first_night",
		story = FF,
		title = "The First Night",
		art = "night",
		text = "Your new room has one window and three locks. The woman next door comes over at two with a hammer and shows your family how the shutters bar. At 3:13, she says, you don't open that door for anybody. Not even for her.",
		always = true,
		once = true,
		when = { minAge = 10, maxAge = 10 },
		choices = {
			{ label = "Watch the clock", result = { mind = 2, sanity = -2, setFlags = { "knows_night" }, log = "3:13. Something went down the street, sweeping. You counted to four thousand. At 4:34 the neighbor knocked twice to say it was over." } },
			{ label = "Help bar the shutters", result = { health = 1, strength = 1, setFlags = { "knows_night" }, relationBond = { kind = "family", amount = 4 }, log = "You held the bar while it was hammered home. In the Nest you never once wondered what the walls were for." } },
			{ label = "Ask when you're going home", result = { sanity = -3, setFlags = { "knows_night" }, log = "Nobody answered. That was the answer." } },
		},
	},
	{
		id = "sl_ff_fence",
		story = FF,
		title = "The Fence",
		art = "checkpoint",
		text = "Your old class is on a field trip to see the checkpoint from the inside. They stand at the fence in their uniforms. Ines, who sat next to you for three years, is close enough to touch.",
		always = true,
		once = true,
		when = { minAge = 12, maxAge = 12 },
		dialogue = { { who = "sl_ines", line = "We're not supposed to talk to... I mean. Hello. You got taller." } },
		choices = {
			{ label = "Ask her for the exam primer", result = { intelligence = 1, setFlags = { "sl_ff_primer" }, log = "She came back the next week alone, with the Wing's entrance primer under her coat, and passed it through the bars without a word." } },
			{ label = "Say hello like nothing happened", result = { sanity = 2, strength = 1, log = "You talked about the teacher's cat for a whole minute. Then her class moved on, and she looked back once." } },
			{ label = "Walk past", result = { mind = 2, sanity = -2, log = "You kept walking. It was easier for both of you. It didn't feel easier." } },
		},
	},
	{
		id = "sl_ff_why",
		story = FF,
		title = "What It Was For",
		art = "home",
		text = "Five years outside the walls, and tonight you finally ask it straight: what did the Wing dismiss your family for? The room goes quiet. Then you're told.",
		always = true,
		once = true,
		when = { minAge = 14, maxAge = 14 },
		choices = {
			{ label = "\"For refusing to sign something.\"", result = { strength = 3, setFlags = { "sl_ff_proud" }, goal = "The Wing's entrance exam is at seventeen. It's the only way back in.", log = "A report that wasn't true, a signature that was wanted on it, and a no. You'd lost a whole life for a no. You sat up straighter." } },
			{ label = "\"Nobody ever said.\"", result = { mind = 3, sanity = -2, setFlags = { "sl_ff_bitter" }, goal = "The Wing's entrance exam is at seventeen. It's the only way back in.", log = "A Director needed the numbers to add up, and a Class 3 was the difference. Nothing personal. That was the worst part." } },
			{ label = "\"It doesn't matter. Pass me the tea.\"", result = { sanity = 2, relationBond = { kind = "family", amount = 8 }, goal = "The Wing's entrance exam is at seventeen. It's the only way back in.", log = "You passed the tea. Some things a family keeps by not saying them." } },
		},
	},
	{
		id = "sl_ff_exam",
		story = FF,
		title = "The Entrance Exam",
		art = "wing",
		text = "The Wing tests anyone who can reach the hall: a thousand examinees, forty desks' worth of jobs. Pass, and you're a Feather. The examiner reads your name off the list, then reads it again more slowly.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17 },
		dialogue = { { who = "sl_examiner", line = "I knew a Class 3 by that name. Sit down. You have four hours, the same as everybody." } },
		choices = {
			{
				label = "Sit it",
				clash = { stat = "intelligence", foe = "The Wing's exam", coins = 2, base = 3, coinPower = 3 },
				win = { intelligence = 2, setFlags = { "sl_ff_passed" }, goal = "You passed. The Wing will send for you.", log = "You wrote until your hand cramped. Rank thirty-one of a thousand. Forty desks." },
				lose = { sanity = -4, setFlags = { "sl_ff_failed" }, goal = "You failed. There's another exam next year, and the year after.", log = "Rank two hundred and six. The examiner didn't look up when you handed it in." },
			},
			{
				label = "Sit it, with Ines's primer in your head",
				requires = { flags = { "sl_ff_primer" } },
				clash = { stat = "intelligence", foe = "The Wing's exam", coins = 3, base = 3, coinPower = 3 },
				win = { intelligence = 2, setFlags = { "sl_ff_passed" }, goal = "You passed. The Wing will send for you.", log = "Half the questions were in the primer, word for word. Rank nineteen. You owe her more than a hello." },
				lose = { sanity = -4, setFlags = { "sl_ff_failed" }, goal = "You failed. There's another exam next year, and the year after.", log = "You knew the primer by heart. They'd changed the paper. Rank one hundred and twelve." },
			},
			{ label = "Stand up and leave the hall", result = { strength = 3, sanity = 2, setFlags = { "sl_ff_stayed" }, goal = "You walked out of the Wing's exam. Decide what you are instead.", log = "You put the pen down on a blank page and walked out past a thousand people who'd have taken your desk." } },
		},
	},
	{
		id = "sl_ff_end_passed",
		story = FF,
		title = "The Checkpoint, Again",
		art = "checkpoint",
		text = "A letter with the Wing's seal. Class 1 Staff, residence for one. You're at the same checkpoint with one bag, going the other way. The guard doesn't weigh it.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_ff_passed" } },
		choices = {
			{ label = "Go in", result = { side = "nest", career = "wing", sanity = -4, storyEnd = "Feather: you went back inside the walls, alone", log = "You went in. Your room is clean and quiet and has no bars on the window. You send half your pay out through the gate on the first of the month." } },
			{ label = "Take the job. Sleep outside the walls", result = { career = "wing", sanity = 3, relationBond = { kind = "family", amount = 12 }, storyEnd = "Commuter: you work for the Wing and go home to the Backstreets", log = "You show your badge at the gate twice a day. The guards think you're mad. You're home before three every night." } },
			{ label = "Send the letter back unsigned", result = { strength = 4, sanity = 4, storyEnd = "Returned to Sender: you passed the Wing's exam and turned it down", log = "You proved you could. That turned out to be all you wanted from them." } },
		},
	},
	{
		id = "sl_ff_end_failed",
		story = FF,
		title = "Not on the List",
		art = "wing",
		text = "The names of the forty go up on the wall of the hall. You read the list three times. The examinee town outside is already packing up its stalls until next year.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_ff_failed" } },
		choices = {
			{ label = "Rent a bunk in the examinee town", result = { intelligence = 3, sanity = -3, money = -30, storyEnd = "Examinee: you'll sit the Wing's exam again, and again", log = "There are people in the examinee town on their eleventh try. They showed you where the cheap noodles are." } },
			{ label = "Take a porter's job at the gate", result = { health = 2, wage = { 20, 40 }, storyEnd = "The Gate: you carry other people's bags through the wall", log = "You carry bags in and bags out. You know every guard by name. You've never been past the yellow line." } },
			{ label = "Go home and tell them", result = { sanity = 3, relationBond = { kind = "family", amount = 12 }, storyEnd = "Outside: you stopped trying to get back in", log = "They weren't disappointed. That was the first time you understood they'd never wanted you to go back." } },
		},
	},
	{
		id = "sl_ff_end_stayed",
		story = FF,
		title = "Three Locks",
		art = "home",
		text = "You're eighteen in a room with one window and three locks, and you chose it. The neighbor who taught your family the shutters is getting old. Somebody has to hold the hammer on this floor.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_ff_stayed" } },
		choices = {
			{ label = "Take the hammer", result = { health = 2, strength = 2, sanity = 4, storyEnd = "Backstreets Born, the Second Time: you bar the shutters for the whole floor", log = "You do the rounds at two now. New families move in from inside the walls sometimes. You show them the bar." } },
			{ label = "Teach the floor's children their letters", result = { intelligence = 3, sanity = 3, setFlags = { "enrolled" }, storyEnd = "The Stairwell School: you teach what the academy taught you, for free", log = "Six children, one slate, and your old schoolbooks if you kept them. The Wing would call it unlicensed. The Wing isn't here." } },
			{ label = "Hang the badge by the door", requires = { flags = { "sl_ff_badge_kept" } }, result = { strength = 3, sanity = 5, storyEnd = "Class 3: the badge hangs by a door the Wing doesn't own", log = "It's Wing property, on a nail, in the Backstreets, by your door. Every evening it's still there." } },
		},
	},

	-- ════ COURTESY ════════════════════════════════════════════════════════════
	{
		id = "sl_ct_bow",
		story = CT,
		title = "The Man Who Never Pays",
		art = "diner",
		text = "On the first of every month a man in a pressed suit eats at your mother's counter. He folds his napkin into a square when he's done, and she hands him an envelope and bows. Not a nod. A bow, held.",
		always = true,
		once = true,
		when = { minAge = 2, maxAge = 2 },
		choices = {
			{ label = "Bow like she does", result = { charisma = 1, setFlags = { "sl_ct_polite", "knows_syndicates" }, log = "You bowed so low you fell over. The man didn't laugh. He inclined his head to you, exactly as far as you were worth." } },
			{ label = "Stare at him", result = { strength = 1, setFlags = { "sl_ct_stared", "knows_syndicates" }, log = "You stared until your mother turned your head for you with two fingers. He'd noticed. He notices everything." } },
			{ label = "Hide behind the counter", result = { mind = 1, setFlags = { "knows_syndicates" }, log = "You watched his shoes from behind the counter. They were the cleanest things in the District." } },
		},
	},
	{
		id = "sl_ct_spoon",
		story = CT,
		title = "The Wrong Spoon",
		art = "diner",
		text = "You're old enough to carry things to the counter now. You bring the man in the suit his soup, and the wrong spoon. The whole diner goes quiet. Your mother has stopped breathing.",
		always = true,
		once = true,
		when = { minAge = 5, maxAge = 5 },
		dialogue = {
			{ who = "sl_brandt", line = "This is a spoon for stirring. One eats with the other kind." },
			{ who = "sl_brandt", line = "Here, it's nothing. Where I work, the spoon would matter. Try again." },
		},
		choices = {
			{
				label = "Bring the right one and say sorry properly",
				clash = { stat = "intelligence", foe = "Getting it exactly right", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { intelligence = 2, setFlags = { "sl_ct_polite" }, log = "Right spoon, handle toward him, eyes down, \"I beg your pardon, sir.\" He ate the soup. Your mother started breathing." },
				lose = { money = -10, sanity = -1, log = "You brought a fork. He paid no attention to it at all, and the envelope was ten Ahn heavier that month." },
			},
			{ label = "Laugh", result = { strength = 1, money = -20, setFlags = { "sl_ct_stared" }, log = "You laughed. He waited until you'd finished. The envelope was twenty Ahn heavier that month, and nobody told you why." } },
			{ label = "Run to the kitchen", result = { mind = 1, sanity = -1, log = "You hid behind the rice sacks. Your mother took him the spoon herself, in both hands." } },
		},
	},
	{
		id = "sl_ct_lessons",
		story = CT,
		title = "Lessons in Manners",
		art = "diner",
		text = "Mr. Brandt comes on Thursdays now as well, when the diner's empty, and teaches you things. How to pour for someone above you. How far to bow to a Capo, and how much farther to a Sottocapo. Your mother can't tell him no.",
		always = true,
		once = true,
		when = { minAge = 8, maxAge = 8 },
		dialogue = { { who = "sl_brandt", line = "You think I don't pay. I pay by sitting here. Nobody else collects from a shop where a Soldato eats." } },
		choices = {
			{ label = "Learn all of it, perfectly", result = { intelligence = 3, setFlags = { "sl_ct_pupil", "knows_thumb" }, goal = "The diner pays the Thumb every month. Find out what that buys.", log = "By winter you could set a table for nine ranks without looking. He never said well done. He stopped correcting you, which is the same thing." } },
			{ label = "Learn it, and hate it", result = { intelligence = 1, strength = 2, setFlags = { "sl_ct_hater", "knows_thumb" }, goal = "The diner pays the Thumb every month. Find out what that buys.", log = "You learned every bow there is, and what each one costs the person making it. You practised them in the mirror with your teeth together." } },
			{ label = "Ask what happens to people with bad manners", result = { mind = 2, sanity = -2, setFlags = { "knows_thumb" }, goal = "The diner pays the Thumb every month. Find out what that buys.", log = "\"They're corrected,\" he said. \"Once.\" He folded his napkin into a square." } },
		},
	},
	{
		id = "sl_ct_short",
		story = CT,
		title = "Short",
		art = "diner",
		text = "Your mother was ill for most of the month. The envelope is light, and Mr. Brandt knows it before he picks it up. He holds it and looks at her for a long time.",
		always = true,
		once = true,
		when = { minAge = 11, maxAge = 11 },
		choices = {
			{ label = "Put your own savings on the counter", result = { money = -15, relationBond = { kind = "family", amount = 8 }, strength = 1, log = "Every coin you had, in a neat stack, the way he'd taught you to present things. He took the stack. He left one coin." } },
			{ label = "Offer to carry messages for him", result = { wage = { 5, 10 }, sanity = -2, setFlags = { "sl_ct_runner" }, log = "You run envelopes across the District on Thursdays now. They're sealed. You have never once looked. He'd know." } },
			{
				label = "Say nothing and hold his eye",
				clash = { stat = "mind", foe = "A Soldato's patience", coins = 1, base = 4, coinPower = 3 },
				win = { mind = 2, log = "He put the envelope in his coat. \"Once,\" he said. He meant it both ways." },
				lose = { money = -25, sanity = -3, log = "Two men came the next morning and carried the good stove out to a cart. They were very careful with the doorframe." },
			},
		},
	},
	{
		id = "sl_ct_other",
		story = CT,
		title = "The Other Collector",
		art = "alley",
		text = "A different man comes to the diner. No suit, no manners, three friends. He says this street pays him now. Your mother looks at the calendar on the wall. It's two days until Thursday.",
		always = true,
		once = true,
		when = { minAge = 13, maxAge = 13 },
		choices = {
			{ label = "Tell Mr. Brandt on Thursday", result = { sanity = -4, mind = 1, setFlags = { "sl_ct_told" }, log = "You told him over the soup. He thanked you. By Saturday the four of them weren't on your street, or on any street, and nobody asked." } },
			{ label = "Pay them quietly from the till", result = { money = -20, sanity = -1, log = "You paid twice that month. Brandt found out anyway. He always does. He said nothing, and the four men stopped coming." } },
			{
				label = "Stand in the door yourself",
				clash = { stat = "strength", foe = "Four men and no manners", coins = 2, base = 4, coinPower = 3 },
				win = { strength = 3, sanity = 2, log = "You stood in the doorway with a ladle and the best posture on the street. They decided it wasn't worth the noise. Brandt heard. He raised one eyebrow." },
				lose = { sanity = -3, money = -15, log = "They walked past you to the till, laughing. One of them patted your head. You remember which one." },
			},
		},
	},
	{
		id = "sl_ct_offer",
		story = CT,
		title = "A Place at the Table",
		art = "diner",
		text = "Mr. Brandt is a Capo now. He comes in on a Thursday with a second suit over his arm, in your size, and lays it on the counter between you and your mother.",
		always = true,
		once = true,
		when = { minAge = 15, maxAge = 15 },
		dialogue = {
			{ who = "sl_brandt", line = "Soldato Primo. The lowest seat at the table. I've had ten years to see your manners." },
			{ who = "sl_brandt", line = "The Thumb doesn't ask twice. Think of your mother before you answer. I have." },
		},
		choices = {
			{ label = "Put on the suit", result = { sanity = -3, setFlags = { "sl_ct_soldato" }, goal = "You said yes to the Thumb. At seventeen, you take your seat.", log = "It fit. Of course it fit. Your mother bowed to you that night without thinking, and then put her hand over her mouth." } },
			{
				label = "Refuse, with perfect courtesy",
				clash = { stat = "intelligence", foe = "The exact form of a refusal", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, strength = 2, setFlags = { "sl_ct_refused" }, goal = "You refused the Thumb, correctly. The diner still pays.", log = "You declined in the form he taught you for declining a superior: both hands, eyes down, the reason given as your own failing. He couldn't fault a syllable. He took the suit away." },
				lose = { sanity = -5, setFlags = { "sl_ct_insult" }, goal = "You insulted a Capo. Get your mother out of that diner.", log = "You got the bow right and the words wrong. \"Ah,\" he said, quite softly. The diner's contribution tripled from that Thursday." },
			},
			{ label = "Throw the suit on the floor", result = { strength = 4, sanity = 2, setFlags = { "sl_ct_insult" }, goal = "You insulted a Capo. Get your mother out of that diner.", log = "It was the rudest thing anyone had done in front of him in twenty years. He picked the suit up himself and brushed it off. That was worse than shouting." } },
		},
	},
	{
		id = "sl_ct_end_soldato",
		story = CT,
		title = "Primo",
		art = "syndicate",
		text = "A long table, a white cloth, forty people who all outrank you. Your seat is the one nearest the door. Before you sit, you're allowed one request of your Capo. It's the custom.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17, flags = { "sl_ct_soldato" } },
		choices = {
			{
				label = "\"The diner on my street never pays again.\"",
				clash = { stat = "mind", foe = "A Capo's arithmetic", coins = 2, base = 5, coinPower = 3 },
				win = { career = "thumb", sanity = 4, storyEnd = "The Diner That Doesn't Pay: you bought her freedom with your own", log = "Brandt considered it, and nodded. A Soldato's mother doesn't pay. You sat down. She has never thanked you, and you've never asked her to." },
				lose = { career = "thumb", sanity = -4, storyEnd = "Soldato: you took your seat, and the diner still pays", log = "\"A Primo doesn't set terms,\" he said. You sat down. She pays on the first of the month, and now it's you who collects." },
			},
			{ label = "Ask for nothing. Sit", result = { career = "thumb", intelligence = 3, sanity = -2, storyEnd = "Soldato: you took your place at the Thumb's table", log = "You sat. Asking for nothing is the best manners there is. Forty people noticed." } },
		},
	},
	{
		id = "sl_ct_end_free",
		story = CT,
		title = "The Last Envelope",
		art = "diner",
		text = "You're seventeen, and the diner pays the Thumb more every month. Your mother counts the till twice a night now. Something has to change, and it's going to have to be you who changes it.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17, notFlags = { "sl_ct_soldato" } },
		choices = {
			{ label = "Hire Zwei to stand at the door", requires = { min = { money = 60 } }, result = { money = -60, sanity = 3, setFlags = { "knows_fixers" }, storyEnd = "Under a Shield: a Zwei Fixer stands at the diner's door", log = "Protection is Zwei's whole trade, and a contract is a contract, even to the Thumb. It costs nearly what the envelope did. But nobody bows." } },
			{ label = "Move her out of the District overnight", result = { sanity = 2, money = -30, relationBond = { kind = "family", amount = 10 }, storyEnd = "Gone by Morning: you took your mother out of the Thumb's streets", log = "One cart, the good pots, and the long way round before the Night. The diner's still there, with somebody else's name on it. Brandt eats there on Thursdays." } },
			{ label = "Keep paying. Keep bowing", result = { intelligence = 3, sanity = -3, storyEnd = "The Counter: you stayed behind it, like her", log = "You hand him the envelope yourself now, and bow, and hold it. Your mother's knees aren't what they were. Somebody has to." } },
		},
	},
}
