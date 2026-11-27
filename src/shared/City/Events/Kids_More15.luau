--[[
	GROWING UP, more of it (v0.15, k15_ ids): the City arriving in a child's life a piece at a
	time, so that by eighteen the Thumb, the Fixers, the Night and the Wings are things you've
	seen and thought about, not names that turn up from nowhere. Children are never hurt here;
	the worst is a scraped knee and a fright.
]]

return {
	-- ── little ones ─────────────────────────────────────────────────────────
	{
		id = "k15_bowing_men",
		title = "The Men Who Bow",
		text = "Two men in good suits walk down your street, and every shopkeeper comes out to bow. One of the men bows back to the baker, exactly as deep. Your mother pulls you behind her skirt.",
		weight = 8,
		once = true,
		when = { minAge = 4, maxAge = 9, side = "backstreets" },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{ label = "Bow too", result = { charisma = 1, mind = 1, setFlags = { "k15_saw_thumb" }, log = "You bowed from behind your mother's skirt. One of the men saw, and bowed back to you, very slightly. Your mother didn't speak all the way home." } },
			{ label = "Ask who they are", result = { intelligence = 1, setFlags = { "k15_saw_thumb" }, log = "\"The Thumb,\" your mother whispered, later. \"You bow, you pay, you never say their names without the titles. Promise me.\" You promised." } },
			{ label = "Stare at their shoes", result = { luck = 1, log = "The shoes were so shiny you could see yourself. You decided you'd have shoes like that one day. Your mother said: not like that." } },
		},
	},
	{
		id = "k15_night_lesson",
		title = "The Rule About the Night",
		text = "Tonight your father sits you down with the clock. \"When both hands are here,\" he says, \"you're inside, and the door is locked, and you don't open it for anyone. Not for me. Not for anyone.\"",
		weight = 9,
		once = true,
		when = { minAge = 4, maxAge = 8, side = "backstreets" },
		choices = {
			{ label = "Ask why", result = { mind = 1, setFlags = { "knows_night" }, log = "\"The Sweepers,\" he said, and wouldn't say more. You practised locking the door until you could do it in the dark." } },
			{ label = "Promise", result = { sanity = 2, setFlags = { "knows_night" }, log = "You promised. He made you promise again. He'd never looked at you like that before." } },
			{ label = "Ask what happens if you don't", result = { mind = 2, sanity = -1, setFlags = { "knows_night" }, log = "He told you about a boy from his street, a long time ago. You never forgot it." } },
		},
	},
	{
		id = "k15_lost_cat",
		title = "The Cat on the Ledge",
		text = "The neighbour's cat is on the ledge outside your window, three floors up, crying. The neighbour is at work. The cat looks at you like you're the only grown-up in the building.",
		weight = 7,
		once = true,
		when = { minAge = 5, maxAge = 11 },
		choices = {
			{ label = "Coax it in with fish", clash = { stat = "charisma", foe = "A cat with opinions", coins = 1, base = 2, coinPower = 2 }, win = { charisma = 1, sanity = 3, log = "A sardine and twenty minutes of sweet talk. The neighbour brought you a whole tin of sardines that evening." }, lose = { sanity = 1, log = "It ate the fish and stayed on the ledge. It came in by itself at dusk, unimpressed by everyone." } },
			{ label = "Fetch a grown-up", result = { intelligence = 1, log = "The old man on four came with a broom and a lot of patience. The cat ignored both and came in anyway." } },
			{ label = "Climb out to get it", clash = { stat = "speed", foe = "A three-storey ledge", coins = 1, base = 3, coinPower = 2 }, win = { speed = 2, luck = 1, log = "You got it, and got back in, and nobody ever found out. The cat follows you everywhere now." }, lose = { health = { -2, -1 }, sanity = -2, log = "Your mother caught you halfway out the window. You've never been grabbed so hard in your life." } },
		},
	},
	{
		id = "k15_crow",
		title = "The Crow That Follows You",
		text = "A crow has started following you to school. It sits on the railings and watches. Today it left something on the windowsill: a button, a shiny one, from a coat you've never seen.",
		weight = 6,
		once = true,
		when = { minAge = 5, maxAge = 12 },
		choices = {
			{ label = "Leave it something back", result = { luck = 2, setFlags = { "k15_crow_friend" }, log = "You left it a bottle cap. The next day, another button. You have eleven now, all from the same coat." } },
			{ label = "Shoo it away", result = { sanity = -1, log = "It went. It came back the next day, and sat further away, and looked hurt." } },
			{ label = "Find the coat", clash = { stat = "intelligence", foe = "A button and a guess", coins = 1, base = 3, coinPower = 2 }, win = { intelligence = 2, log = "The buttons matched the coat of an old man who used to feed the crows, before he moved away. You wrote him a letter. He wrote back." }, lose = { log = "Nobody on the street had a coat with those buttons. Some mysteries are crows' business." } },
		},
	},
	{
		id = "k15_birthday_siren",
		title = "A Birthday With Sirens",
		text = "It's your birthday, and there's a cake, a small one, and a candle. Then the sirens start across the District, the long kind, and every light in the building goes out.",
		weight = 6,
		once = true,
		when = { minAge = 4, maxAge = 10 },
		choices = {
			{ label = "Blow out the candle anyway", result = { sanity = 3, luck = 1, log = "In the dark, with the sirens going, everyone sang very quietly. It was the best birthday you ever had, and you can't explain why." } },
			{ label = "Hide under the table", result = { mind = 1, sanity = -1, log = "Under the table with the cake, until the sirens stopped. Then cake, in the dark, with your fingers." } },
			{ label = "Ask what the sirens are", result = { intelligence = 1, log = "\"Something got out of somewhere,\" your mother said. \"Somewhere far away.\" She kept looking at the window." } },
		},
	},

	-- ── kids ────────────────────────────────────────────────────────────────
	{
		id = "k15_fixer_funeral",
		title = "A Fixer's Funeral",
		text = "A Fixer from your street is being buried. Her whole Office walks behind the coffin in their coats, and the street lines up to watch. Nobody cries except one Fixer at the back, who cries enough for everybody.",
		weight = 7,
		once = true,
		when = { minAge = 7, maxAge = 13 },
		choices = {
			{ label = "Ask how she died", result = { mind = 2, setFlags = { "k15_saw_funeral" }, log = "\"On a contract,\" the noodle man said. \"Most of them do. Nobody gets old in that coat.\" You thought about it for a long time." } },
			{ label = "Stand with the Office", result = { charisma = 1, sanity = -1, rep = { fixers = 2 }, setFlags = { "k15_saw_funeral" }, log = "You stood at the end of their line in your school coat. The crying Fixer put a hand on your head for a moment." } },
			{ label = "Decide you'll be a Fixer", result = { strength = 1, mind = 1, setFlags = { "k15_saw_funeral", "y15_fixer_tales" }, log = "You decided right there, at a funeral, that you'd wear the coat. Everybody who becomes a Fixer decides at a funeral." } },
		},
	},
	{
		id = "k15_rat_kindness",
		title = "The Rat Who Paid",
		text = "A Rat, a real one, with a knife and a scar, stops you on the way home. Your heart nearly stops. Then he gives you two Ahn and asks you to take a bowl of noodles to the old woman on the corner, because she won't take anything from him.",
		weight = 6,
		once = true,
		when = { minAge = 7, maxAge = 13, side = "backstreets" },
		choices = {
			{ label = "Take the noodles", result = { charisma = 1, sanity = 2, setFlags = { "k15_rat_friend" }, log = "The old woman took them, and asked who they were from, and you said a friend. She said she had a son, once, with a scar like that." } },
			{ label = "Ask why", result = { mind = 2, log = "\"She was my teacher,\" he said, and walked off fast before you could see his face." } },
			{ label = "Run", result = { speed = 1, sanity = -2, log = "You ran. You kept the two Ahn. You felt bad about it for a year." } },
		},
	},
	{
		id = "k15_wing_recruiter",
		title = "The Recruiter at School",
		text = "A woman from the Wing comes to your school with a stack of glossy leaflets. The best students, she says, could one day work in the Nest. She's looking at the front row. You're not in the front row.",
		weight = 7,
		once = true,
		when = { minAge = 9, maxAge = 14 },
		choices = {
			{ label = "Ask a question from the back", clash = { stat = "intelligence", foe = "A recruiter's attention", coins = 1, base = 3, coinPower = 2 }, win = { intelligence = 2, setFlags = { "k15_recruiter_noticed" }, log = "\"What happens to the ones who don't make it?\" She looked at you properly for the first time, and wrote your name down." }, lose = { charisma = 1, log = "She answered the question you didn't ask, beautifully, and moved on." } },
			{ label = "Take a leaflet home", result = { mind = 1, sanity = 1, log = "Your mother read it three times, and put it on the wall, and didn't say anything about it ever." } },
			{ label = "Throw the leaflet away", result = { mind = 1, log = "Everyone knows what the Nest takes. You'd rather keep it." } },
		},
	},
	{
		id = "k15_dare_gate",
		title = "The Dare at the Gate",
		text = "The older kids dare you to touch the Nest gate. It's guarded, and lit, and nobody from your street has ever been through it. Just touch it, they say, and run.",
		weight = 6,
		once = true,
		when = { minAge = 8, maxAge = 13, side = "backstreets" },
		choices = {
			{ label = "Do it", clash = { stat = "speed", foe = "A bored guard", coins = 1, base = 3, coinPower = 2 }, win = { speed = 2, charisma = 1, log = "You touched it, cold and smooth, and ran, and the guard just laughed. The big kids carried you home like a hero." }, lose = { sanity = -2, log = "The guard caught your collar, walked you home, and spoke to your mother. That was much worse than anything at the gate." } },
			{ label = "Dare them back", result = { charisma = 2, log = "\"You first.\" Nobody went. They let you into the gang anyway, for nerve." } },
			{ label = "Say no", result = { mind = 1, sanity = 1, log = "You said no and walked home. Some of them respected it, later." } },
		},
	},
	{
		id = "k15_broken_window",
		title = "The Broken Window",
		text = "A ball, a throw, a crash. The window belongs to a tailor who has never smiled. The other kids have already vanished. The tailor is coming out.",
		weight = 7,
		once = true,
		when = { minAge = 7, maxAge = 13 },
		choices = {
			{ label = "Own up", result = { charisma = 2, sanity = 1, money = -5, log = "You owned up. He made you sweep his shop for a month. On the last day, he smiled, once." } },
			{ label = "Run", clash = { stat = "speed", foe = "An angry tailor", coins = 1, base = 2, coinPower = 2 }, win = { speed = 1, sanity = -1, log = "You got away. You walk the long way round his shop now, every day." }, lose = { sanity = -2, money = -5, log = "Tailors are faster than they look. Your mother paid for the window. You paid for it differently." } },
			{ label = "Blame the ball", result = { luck = 1, log = "\"It was the ball,\" you said. He looked at you for a long time, and then laughed, which nobody had ever heard." } },
		},
	},
	{
		id = "k15_lamplighter_kid",
		title = "The Boy With the Workshop Arm",
		text = "A new boy at school has a Workshop arm, all brass and joints. The others won't sit with him. He's eating lunch alone and pretending not to care.",
		weight = 6,
		once = true,
		when = { minAge = 7, maxAge = 13 },
		choices = {
			{ label = "Sit with him", result = { charisma = 2, sanity = 2, addRelation = { kind = "friend", name = "Marek Dunaj", bond = 55, age = { 8, 12 } }, log = "His name was Marek. The arm could crack walnuts. By the end of the week everyone wanted to sit with you both." } },
			{ label = "Ask about the arm", result = { intelligence = 1, log = "\"A cart,\" he said. \"I was four.\" Then he showed you how the fingers worked, and you forgot to be careful." } },
			{ label = "Leave him be", result = { sanity = -1, log = "You sat with your usual table. You looked over a lot." } },
		},
	},
	{
		id = "k15_ampule_ad",
		title = "The Poster on the Wall",
		text = "A new poster on your street: a smiling family, a glowing vial, K Corp's name in green. Any wound, it says, overnight. Underneath, someone has written the price in chalk, and a question mark.",
		weight = 5,
		once = true,
		when = { minAge = 8, maxAge = 14 },
		choices = {
			{ label = "Ask how much it really is", result = { intelligence = 1, log = "More than your father makes in a year, the noodle man said. \"Overnight,\" he added. \"Only if you're rich overnight too.\"" } },
			{ label = "Draw a moustache on the family", result = { charisma = 1, sanity = 2, log = "A big one on the father, a small one on the baby. The whole street laughed for a week." } },
			{ label = "Dream about it", result = { mind = 1, log = "If you had one you'd give it to your grandmother for her hip. You think about that a lot." } },
		},
	},
	{
		id = "k15_scavenger_find",
		title = "Something in the Scrap",
		text = "Digging through a scrap heap you find a Fixer's badge: dented, an Office's crest on it, a name scratched off. Someone lost this, or left it, or didn't come back for it.",
		weight = 5,
		once = true,
		when = { minAge = 8, maxAge = 15 },
		choices = {
			{ label = "Take it to Hana", clash = { stat = "intelligence", foe = "Hana's front desk", coins = 1, base = 3, coinPower = 2 }, win = { intelligence = 1, rep = { fixers = 3 }, wage = { 10, 20 }, log = "The clerk looked it up. The Office paid you a finder's fee, and the Fixer's sister came to shake your hand." }, lose = { log = "The clerk took it and told you to run along. You never found out whose it was." } },
			{ label = "Keep it", result = { luck = 1, mind = 1, setFlags = { "k15_badge" }, log = "You keep it in a tin under your bed. Some nights you make up who it belonged to." } },
			{ label = "Put it back", result = { sanity = 1, log = "You put it back where you found it. Some things should be where they were left." } },
		},
	},

	-- ── teens ───────────────────────────────────────────────────────────────
	{
		id = "k15_first_offer",
		title = "The First Offer",
		text = "A man in a good coat stops you outside school. He's heard you're quick and quiet. There's a job: carry something across the District, no questions, fifty Ahn. More than your mother makes in a week.",
		weight = 7,
		once = true,
		when = { minAge = 13, maxAge = 17, side = "backstreets" },
		choices = {
			{ label = "Take it", clash = { stat = "speed", foe = "A parcel and twelve streets", coins = 2, base = 3, coinPower = 2 }, win = { wage = { 40, 60 }, speed = 1, rep = { rats = 3 }, setFlags = { "k15_ran_for_syndicate" }, log = "You delivered it. He paid. He said there'd be more. There will be." }, lose = { sanity = -3, health = { -3, -1 }, rep = { rats = -2 }, log = "Someone stopped you halfway and took it. The man in the good coat was very calm about it, which frightened you more." } },
			{ label = "Say no", result = { mind = 2, log = "He smiled, like he'd expected it, and said the offer stands. You walked home faster than usual." } },
			{ label = "Tell your mother", result = { charisma = 1, sanity = 1, log = "She went out and found him. You never knew what she said. He never stopped you again." } },
		},
	},
	{
		id = "k15_exam_season",
		title = "Exam Season",
		text = "Everybody your age is sitting the exams that decide where you go next: the Wing's tests, an Academy's scholarship, or nothing. Your friends are studying on the stairs by lamplight. You have one week.",
		weight = 8,
		once = true,
		when = { minAge = 14, maxAge = 17 },
		choices = {
			{ label = "Study every night", clash = { stat = "intelligence", foe = "The exam", coins = 2, base = 4, coinPower = 2 }, win = { intelligence = 3, setFlags = { "k15_exam_passed" }, log = "Top third. Not top ten, but top third. A letter came with a crest on it." }, lose = { intelligence = 1, sanity = -2, log = "You studied every night and froze on the day. There's always next year, they said. There isn't, always." } },
			{ label = "Study with your friends", result = { intelligence = 1, charisma = 2, sanity = 2, log = "You didn't learn much. You'll remember that week on the stairs for the rest of your life." } },
			{ label = "Skip it and work", result = { wage = { 15, 30 }, mind = 1, log = "You worked the week instead. The exams are for people who can afford to lose a week." } },
		},
	},
	{
		id = "k15_sparring_match",
		title = "The Sparring Match",
		text = "At the Fixer gym, a Grade 8 is looking for someone to spar with his nervous new apprentice. Everyone else is busy. The apprentice is your age, and shaking.",
		weight = 6,
		once = true,
		when = { minAge = 13, maxAge = 17 },
		choices = {
			{ label = "Spar with them", clash = { stat = "strength", foe = "A nervous apprentice", coins = 2, base = 3, coinPower = 2 }, win = { strength = 2, setFlags = { "y15_gym_kid" }, log = "You won, just. The Grade 8 nodded at you, and wrote something on a card." }, lose = { strength = 1, health = { -3, -1 }, charisma = 1, log = "They won, and stopped shaking. The Grade 8 thanked you for losing well. You hadn't meant to." } },
			{ label = "Let them win", result = { charisma = 2, sanity = 1, log = "You let them win, and they knew, and thanked you with their eyes. You're friends now." } },
			{ label = "Teach them a trick", result = { mind = 1, charisma = 1, log = "Feet first. You showed them. They were better than you by the end." } },
		},
	},
	{
		id = "k15_night_out",
		title = "Out Too Late",
		text = "You lost track of time at a friend's. The clock on the wall says ten to three. Your friend's mother is pale. \"You can't walk it,\" she says. \"Not now. Stay.\" Your own mother will be frantic.",
		weight = 6,
		once = true,
		when = { minAge = 12, maxAge = 17, side = "backstreets" },
		choices = {
			{ label = "Stay the night", result = { mind = 1, sanity = -1, log = "You stayed, on the floor. At 3:13 you heard it go past outside, and didn't breathe. Your mother hugged you so hard in the morning it hurt." } },
			{ label = "Run for it", clash = { stat = "speed", foe = "Ten minutes and six streets", coins = 2, base = 4, coinPower = 2 }, win = { speed = 2, sanity = -3, log = "Six streets in eight minutes. Your door locked behind you at 3:01. You were sick on the mat." }, lose = { sanity = -8, health = { -4, -2 }, log = "You were two streets out at three. You hid under a cart and saw something you'll never describe. You got home at dawn." } },
			{ label = "Send a message somehow", clash = { stat = "intelligence", foe = "No phone, no time", coins = 2, base = 3, coinPower = 2 }, win = { intelligence = 2, log = "A lamp in the window, flashed in the code your mother taught you. She flashed back. You both slept, a little." }, lose = { sanity = -2, log = "No way to tell her. You stayed, and she didn't sleep." } },
		},
	},
	{
		id = "k15_roof_sunset",
		title = "The View From the Roof",
		text = "On the roof with your oldest friend at sunset, the whole District below: the Nest's towers lit gold, the Backstreets going blue. Your friend says they're leaving, next year. Somewhere better. They don't know where.",
		weight = 5,
		once = true,
		when = { minAge = 14, maxAge = 17 },
		choices = {
			{ label = "Say you'll go too", result = { charisma = 1, sanity = 2, setFlags = { "k15_leaving_pact" }, log = "You shook on it, very seriously. Whether either of you goes, you'll always have shaken on it." } },
			{ label = "Ask them to stay", result = { charisma = 2, log = "They didn't answer. They didn't go, either, that year." } },
			{ label = "Say there's nowhere better", result = { mind = 2, sanity = -1, log = "They were quiet a long time. \"Then I'll make somewhere,\" they said. You hope they do." } },
		},
	},
	{
		id = "k15_apprentice_offer",
		title = "The Smith's Offer",
		text = "The Workshop smith you've been running parcels for wipes her hands and looks at you properly. \"You're careful,\" she says. \"Careful is rare. I could teach you. Five years, no pay, everything I know.\"",
		weight = 5,
		once = true,
		when = { minAge = 14, maxAge = 17 },
		choices = {
			{ label = "Accept", result = { intelligence = 2, strength = 1, setFlags = { "k15_smith_apprentice" }, log = "Five years. You started that afternoon, sweeping. By evening you were holding tongs." } },
			{ label = "Ask for pay", clash = { stat = "charisma", foe = "A smith who's never paid an apprentice", coins = 2, base = 4, coinPower = 2 }, win = { charisma = 2, intelligence = 1, setFlags = { "k15_smith_apprentice" }, log = "Five Ahn a week. She'd never paid anyone. She grumbled about it for five years." }, lose = { log = "\"No pay,\" she said. \"That's the price of everything I know.\" You said you'd think about it." } },
			{ label = "Decline", result = { mind = 1, log = "She shrugged and went back to the forge. \"Careful people always say no the first time.\"" } },
		},
	},
}
