--[[
	STORYLINES of the ages (Storylines/Ages.luau). Lines given as lists are variants: each life is
	dealt one, so the same story doesn't read the same twice.

	SEVEN DAYS (born 962-970: a child when the Light comes in 978).
	  2 the night shift · 5 the badge · 7 the envelope · THE LIGHT (whatever your age) ·
	  the fourth morning · two years on: a coat · four years on: the endings.
	  Flags: sl_sd_read, sl_sd_went, sl_sd_kept.

	THE INVITATION (born 977-984: the Age of the Library, 979-1000).
	  2 the envelope · 5 the drawer · 8 what it offers · 11 a neighbour's book · 13 yours ·
	  15 THE DOOR · 17 the endings. Flags: sl_iv_read, sl_iv_burned, sl_iv_signed, sl_iv_out.

	THE BOOK (any age, Backstreets, a brother or sister).
	  2 the tally · 5 the reading · 8 in kind · 11 a Big Sibling's sweets · 13 the plan ·
	  15 THE PAGE · 17 the endings. Flags: sl_bk_paid, sl_bk_fought, sl_bk_joined.

	A QUIET HEART (born 999 on: after the second Light).
	  2 the roof · 5 the mat · 8 one feeling · 11 a ring · 13 the street · 15 THE STILLNESS ·
	  17 the endings. Flags: sl_qh_sat, sl_qh_shin, sl_qh_left.
]]

local SD = "sl_seven_days"
local IV = "sl_invitation"
local BK = "sl_the_book"
local QH = "sl_quiet_heart"
local AFTER = { "library", "limbus" }

return {
	-- ════ SEVEN DAYS ═══════════════════════════════════════════════════════════
	{
		id = "sl_sd_night_shift",
		story = SD,
		title = "The Night Shift",
		art = "home",
		text = {
			"Your father leaves at dusk with a tin of rice and a badge on a green cord. He works for the Wing, in the tower in District 12. He comes back when the birds start. That's all you know about it.",
			"Every evening the same: the tin, the green cord, the door. Your father keeps the lamps on a floor of the L Corp tower. In the morning he smells of something clean and cold, and he sleeps with his boots on.",
		},
		always = true,
		once = true,
		when = { minAge = 2, maxAge = 2, hasRelation = "father", world = { era = "wings" } },
		choices = {
			{ label = "Wait up at the window", result = { mind = 1, relationBond = { kind = "father", amount = 6 }, log = "You fell asleep on the sill. You woke in your bed, and the tin was washed and upside down by the basin." } },
			{ label = "Hide his boots so he can't go", result = { charisma = 1, sanity = 2, log = "He found them in the flour bin. He laughed for the first time that month, and went anyway." } },
			{ label = "Ask what's in the tower", result = { intelligence = 1, setFlags = { "knows_lcorp" }, log = "\"Lamps,\" he said. \"A great many lamps, and someone has to keep them lit.\" He didn't say what they were lighting." } },
		},
	},
	{
		id = "sl_sd_badge",
		story = SD,
		title = "The Badge",
		art = "home",
		text = {
			"Your father lets you hold his L Corp badge while he eats. It's heavier than it looks. On the back, stamped small: FACE THE FEAR, BUILD THE FUTURE.",
			"Your father's L Corp badge is on the table. There's a photograph of him on it that doesn't look like him, and a line of words on the back that he says every new employee has to say out loud.",
		},
		always = true,
		once = true,
		when = { minAge = 5, maxAge = 5, hasRelation = "father", world = { era = "wings" } },
		choices = {
			{ label = "Ask what the fear is", result = { mind = 2, sanity = -1, log = "He chewed for a long time. \"It's different for everyone,\" he said. \"That's rather the point of the place.\"" } },
			{ label = "Ask what the future is", result = { intelligence = 2, goal = "He says the Wing is building something for everyone. He won't say what.", log = "\"Something for everyone,\" he said. \"Not just the Nests. Everyone. I've seen the plans for one small part of it, and I keep the lamps on for that part.\"" } },
			{ label = "Put it on and march about", result = { charisma = 1, sanity = 2, relationBond = { kind = "father", amount = 5 }, log = "You were a Class 5 Manager for the length of the kitchen. He saluted you with his chopsticks." } },
		},
	},
	{
		id = "sl_sd_envelope",
		story = SD,
		title = "The Envelope",
		art = "home",
		text = {
			"Your father comes home early, which never happens, and puts a sealed envelope on the top shelf. If the sky ever does something it shouldn't, he says, open that. Not before. Then he sits at the table for an hour without taking his coat off.",
			"There's an envelope on the top shelf now, with wax on it. Your father says it's for a day he hopes won't come the way he thinks it will. He's started going in on his rest days.",
		},
		always = true,
		once = true,
		when = { minAge = 7, maxAge = 7, hasRelation = "father", world = { era = "wings" } },
		choices = {
			{ label = "Promise not to touch it", result = { mind = 2, relationBond = { kind = "father", amount = 6 }, setFlags = { "sl_sd_kept" }, goal = "There's a sealed envelope on the top shelf. Not before the sky changes.", log = "You promised. You looked at it every day for years, and you kept the promise, which surprised you both." } },
			{ label = "Steam it open while he sleeps", clash = { stat = "intelligence", foe = "Wax, steam and a creaking chair", coins = 1, base = 3, coinPower = 2, fixed = true }, win = { intelligence = 2, sanity = -3, setFlags = { "sl_sd_read" }, goal = "You've read it. On the fourth day it will go dark.", log = "One page. Stay inside. It will be light for three days. On the fourth it will go dark, and I am sorry. I will be at my lamps. You sealed it again and didn't sleep." }, lose = { relationBond = { kind = "father", amount = -8 }, sanity = -2, goal = "There's a sealed envelope on the top shelf. He moved it higher.", log = "The chair creaked. He didn't shout. He just moved it to a higher shelf and looked at you for a while." } },
			{ label = "Ask him what he's afraid of", result = { charisma = 2, sanity = -2, goal = "He says they've set a date. He won't say for what.", log = "\"That it works,\" he said. \"And that it doesn't. They've set a date.\"" } },
		},
	},
	{
		id = "sl_sd_light",
		story = SD,
		title = "The Sky Does Something",
		art = "lcorp",
		text = {
			"It's light at midnight. It's coming from District 12, from the tower, from the floors your father keeps lit. The whole street is outside in its nightclothes, and nobody is afraid. The envelope is on the top shelf.",
			"The night doesn't come. A pillar of light is standing on the L Corp tower and spreading over everything, and your father went to work at dusk the way he always does. The envelope has been waiting years for this.",
		},
		always = true,
		once = true,
		weight = 600,
		when = { world = { era = "white_nights" }, hasRelation = "father" },
		choices = {
			{ label = "Open the envelope", result = { mind = 2, sanity = -2, setFlags = { "saw_white_nights", "sl_sd_read" }, trigger = "sl_sd_fourth", goal = "Stay inside. On the fourth day it goes dark.", log = "Stay inside. It will be light for three days. On the fourth it will go dark, and I am sorry. I'll be at my lamps: somebody has to be. Look after each other. It was signed with his whole name, like a form." } },
			{ label = "Run to District 12 and find him", clash = { stat = "speed", foe = "A whole City standing in the road", coins = 2, base = 4, coinPower = 3 }, win = { speed = 2, sanity = 3, setFlags = { "saw_white_nights", "sl_sd_went" }, trigger = "sl_sd_fourth", goal = "You saw him at a window of the tower. He waved you home.", log = "You got as far as the Wing's fence. He was at a window on a high floor with a lamp in each hand. He saw you. He pointed home, twice, hard, and then he smiled." }, lose = { sanity = -3, health = { -5, -2 }, setFlags = { "saw_white_nights" }, trigger = "sl_sd_fourth", goal = "You never reached the tower.", log = "The crowd was a wall. Somebody carried you back on their shoulders, laughing, and you beat on their head the whole way." } },
			{ label = "Stand in it, with everyone", result = { sanity = { 6, 10 }, addTrait = "light_touched", setFlags = { "saw_white_nights" }, trigger = "sl_sd_fourth", goal = "For three days nobody on your street was afraid.", log = "This is what he was keeping lit. You understood it all at once, standing in the road with your face up. You forgot the envelope for three whole days." } },
		},
	},
	{
		id = "sl_sd_fourth",
		story = SD,
		title = "The Fourth Morning",
		art = "night",
		text = {
			"The light goes out like a hand closing. No sun behind it. Dark at noon, lamps that won't hold, and things in the street that weren't there when it was bright. Your father's tin is not by the basin.",
			"Three days, and then nothing: no light, no sun, four days of it. People say it was meant to last seven. Nobody can say why it didn't. Your father hasn't come home, and the tower in District 12 is the darkest thing in the dark.",
		},
		always = true,
		once = true,
		weight = 0,
		when = { world = { era = "white_nights" } },
		choices = {
			{ label = "Keep one lamp lit in the window, all four days", clash = { stat = "mind", foe = "Four days of dark", coins = 2, base = 4, coinPower = 3 }, win = { mind = 3, sanity = -3, setFlags = { "sl_sd_kept" }, schedule = { event = "sl_sd_coat", inYears = 2 }, goal = "He didn't come home. You kept a lamp lit.", log = "You trimmed the wick every hour by feel. Half the street found its way home by your window. He would have liked that. He didn't see it." }, lose = { sanity = { -10, -6 }, condition = "night_terrors", schedule = { event = "sl_sd_coat", inYears = 2 }, goal = "He didn't come home. The lamp went out on the third day.", log = "The oil ran out on the third day. You sat in the dark with your back to the door until the sun came back, ordinary, like an insult." } },
			{ label = "Go out and look for him", clash = { stat = "strength", foe = "What came out of District 12", coins = 2, base = 5, coinPower = 3, fight = true }, win = { strength = 2, sanity = -5, setFlags = { "sl_sd_went" }, schedule = { event = "sl_sd_coat", inYears = 2 }, goal = "The tower is sealed. He isn't on any list.", log = "You reached the fence by feel. The tower was sealing itself, floor by floor, with a sound like a breath going out. A clerk with no badge told you there were no lists. There would never be lists." }, lose = { health = { -14, -8 }, sanity = -8, condition = "night_terrors", schedule = { event = "sl_sd_coat", inYears = 2 }, cause = "Lost in the Dark Days", goal = "You never reached the tower.", log = "Something in the dark knew you were small. You got home. You don't remember how." } },
			{ label = "Stay inside, as he asked", requires = { flags = { "sl_sd_read" } }, result = { mind = 2, sanity = -4, relationBond = { kind = "family", amount = 8 }, schedule = { event = "sl_sd_coat", inYears = 2 }, goal = "You did what the letter said. He didn't come home.", log = "You did exactly what he wrote. Nobody in your rooms was lost. It was the hardest thing you have ever done, and nobody will ever know you did it." } },
		},
	},
	{
		id = "sl_sd_coat",
		story = SD,
		title = "Someone at the Door",
		art = "home",
		text = {
			"A man you don't know is on the landing with a folded coat over his arm. He was on your father's floor, he says. He's been two years finding the address. He can't stay long, and he can't come in.",
			"Two years on, a knock. A thin man in a coat too big for him is holding out another coat, folded square, with a green cord in the pocket. He says he worked the lamps beside your father, and that he owes him a walk across the City.",
		},
		dialogue = { { who = "sl_sd_colleague", line = { "He stayed. When the rest of us ran for the stairs, he stayed with the lamps. I thought someone ought to say so.", "They'll tell you nobody knows what happened in there. I know one thing that happened. He kept his floor lit to the end." } } },
		always = true,
		once = true,
		weight = 0,
		when = { world = { era = AFTER } },
		choices = {
			{ label = "Ask what the lamps were for", result = { intelligence = 2, sanity = -2, killRelation = "father", goal = "He kept his floor lit to the end. Nobody will say what for.", log = "\"For all of us,\" the man said. \"It was meant to be seven days. I don't know why it wasn't. I only know it was real for three, and your father was part of why.\" He left the coat." } },
			{ label = "Take the coat. Say thank you.", result = { charisma = 2, sanity = 3, killRelation = "father", goal = "You have his coat, and a green cord.", log = "It still smelled of that clean cold. You hung it on his hook. Neither of you could think of anything else to say, and the man seemed grateful for that." } },
			{ label = "Ask where the tower is now", result = { mind = 2, killRelation = "father", setFlags = { "sl_sd_went" }, goal = "There's a Library where the tower stood.", log = "\"Gone,\" he said. \"There's a Library there. Don't go near it. Whatever we were building, that isn't it.\"" } },
		},
	},
	{
		id = "sl_sd_end",
		story = SD,
		title = "A Lamp in the Window",
		art = "home",
		text = "Your father's coat fits you across the shoulders now. People on the street still say, when someone's late home: leave a lamp. They say it without knowing where it comes from. You know where it comes from.",
		always = true,
		once = true,
		when = { minAge = 16, world = { era = AFTER }, noRelation = "father" },
		choices = {
			{ label = "Keep a lamp lit, every night, for whoever's late", result = { sanity = 6, mind = 3, charisma = 2, storyEnd = "Lamplighter: you keep a lamp in the window for the whole street", log = "Every night at dusk. People set their step by it. You've never told them why, and somebody is always the last one home." } },
			{ label = "Go and dig where the tower stood", requires = { flags = { "sl_sd_went" } }, result = { strength = 3, sanity = -4, setFlags = { "kept_lcorp_notes" }, storyEnd = "The Dig: you went looking under District 12 for what he kept lit", log = "You found the floor. You're nearly sure it's the floor. There are lamp brackets on the wall, every one of them empty, and one tin, washed, upside down." } },
			{ label = "Burn the letter and let him rest", result = { sanity = 8, mind = 2, storyEnd = "Let It Lie: you stopped asking what the Light was for", log = "It was meant to be seven days and it was three. He was part of the three. You decided that was enough to know about a person." } },
		},
	},

	-- ════ THE INVITATION ═══════════════════════════════════════════════════════
	{
		id = "sl_iv_envelope",
		story = IV,
		title = "The Envelope",
		art = "home",
		text = {
			"It's on the table again. Thick cream paper, your mother's name in black ink. She burned the first one in the stove the week you were born. This one is exactly the same, down to a crease in the corner.",
			"Your mother takes an envelope out from under the door with two fingers, the way you'd lift a dead mouse. It's the third this year. They say the same thing every time, and she never reads past the first line.",
		},
		always = true,
		once = true,
		when = { minAge = 2, maxAge = 2, hasRelation = "mother", world = { era = "library" } },
		choices = {
			{ label = "Reach for it", result = { mind = 1, sanity = -1, log = "She moved it to the top of the cupboard so fast she knocked a cup off. She'd never been sharp with you before. She said sorry for an hour." } },
			{ label = "Watch her burn it", result = { intelligence = 1, setFlags = { "sl_iv_burned" }, log = "It burned blue at the edges. In the morning there was another one on the mat, and she stood looking at it with her coat half on." } },
			{ label = "Cry until she picks you up", result = { sanity = 3, relationBond = { kind = "mother", amount = 6 }, log = "She forgot the envelope for a whole evening. That, you'd work out later, was the most anyone ever managed." } },
		},
	},
	{
		id = "sl_iv_drawer",
		story = IV,
		title = "The Drawer",
		art = "home",
		text = {
			"Your mother has stopped burning the envelopes. There's a drawer in the kitchen that sticks, and when you get it open there are eleven envelopes inside, all the same, all unopened but one.",
			"The envelopes go in the bottom drawer now, under the tea towels. One of them has been opened and folded shut again very carefully, the way you fold a thing you intend to deny reading.",
		},
		always = true,
		once = true,
		when = { minAge = 5, maxAge = 5, hasRelation = "mother", world = { era = "library" } },
		choices = {
			{ label = "Read the open one", clash = { stat = "intelligence", foe = "Long words in a fine hand", coins = 1, base = 2, coinPower = 2, fixed = true }, win = { intelligence = 2, sanity = -2, setFlags = { "sl_iv_read" }, goal = "It offers a book. Any book. The one she wants most.", log = "You are cordially invited to the Library. Should you prevail, the book you desire is yours. You sounded out \"prevail\" and didn't know it. You understood \"desire\"." }, lose = { mind = 1, log = "The letters were too thin and too joined up. You put it back exactly as it was. She knew anyway." } },
			{ label = "Ask her what she'd want", result = { charisma = 2, relationBond = { kind = "mother", amount = 5 }, goal = "She says there's nothing she wants. She says it too fast.", log = "\"Nothing,\" she said. \"I've got you.\" She said it too fast, and then she looked at the drawer." } },
			{ label = "Shut the drawer", result = { mind = 2, sanity = 1, log = "It stuck, and then it shut. You've been good at shutting drawers ever since." } },
		},
	},
	{
		id = "sl_iv_offer",
		story = IV,
		title = "What It Offers",
		art = "market",
		text = {
			"People talk about the Library openly now. It asks what you want most and promises you a book about it: how to find someone, how to undo something, how to be what you were going to be. All you have to do is come, and win.",
			"The woman at the bread stall says her brother-in-law went. He wanted a book that would tell him where his daughter is. Hana calls the place a Myth, she says, and a Myth is a thing that takes people who don't believe in it.",
		},
		always = true,
		once = true,
		when = { minAge = 8, maxAge = 8, world = { era = "library" } },
		choices = {
			{ label = "Ask what happens if you lose", result = { intelligence = 2, sanity = -3, setFlags = { "saw_the_library" }, goal = "A guest who loses becomes a book. People say the books are very good.", log = "\"You become one,\" she said, wrapping the loaf. \"A book. They say they're very well written. They say you can tell who it was from the first page.\"" } },
			{ label = "Ask who has ever won", result = { charisma = 2, log = "Nobody at the stall could name one. A man said that proved nothing: a person who got the book they wanted most wouldn't come back to a bread stall to tell you about it." } },
			{ label = "Work out what your mother wants", result = { mind = 2, sanity = -2, relationBond = { kind = "mother", amount = 4 }, goal = "You think you know what book she'd ask for.", log = "You went through it like sums. What she had before you. What she stopped doing. By the time you got home you were fairly sure, and you were sorry you'd done the sum." } },
		},
	},
	{
		id = "sl_iv_neighbour",
		story = IV,
		title = "A Neighbour's Book",
		art = "market",
		text = {
			"Old Zofia's cart has a new book on it, bound in a brown you recognise: it's the color of the coat the man across the landing wore every day of your life. He signed his invitation in the spring. The first page is in his voice.",
			"There's a book on the handcart with a neighbour's name stamped in the spine. Not written by him. Him. He went to the Library in his good coat four months ago, and now he's three hundred pages and costs forty Ahn.",
		},
		always = true,
		once = true,
		when = { minAge = 11, maxAge = 11, world = { era = "library" } },
		choices = {
			{ label = "Read the first page", result = { intelligence = 2, sanity = -4, goal = "You read one page of him. It was all true.", log = "It began with the stairs he climbed every day and how he counted them. You shut it. It was the most honest thing you'd ever read, and he never said a word of it aloud while he lived." } },
			{ label = "Buy it, so nobody else does", requires = { min = { money = 40 } }, result = { money = -40, sanity = 2, charisma = 1, goal = "He's on your shelf. It seemed better than a stranger's.", log = "You put him on the shelf between the atlas and the cookery book. Your mother looked at the spine for a long moment and then turned it to face the wall." } },
			{ label = "Tell your mother what you saw", requires = { hasRelation = "mother" }, result = { mind = 2, relationBond = { kind = "mother", amount = 6 }, goal = "She says she'd never sign. She's stopped saying there's nothing she wants.", log = "\"I'd never,\" she said. And then, quieter, with her hands in the washing water: \"He wanted to know if his sister forgave him. I'd want to know that too, if I were him.\"" } },
		},
	},
	{
		id = "sl_iv_yours",
		story = IV,
		title = "Yours",
		art = "home",
		text = {
			"This envelope isn't for your mother. It has your name on it, in the same black hand, spelled the way only your family spells it. You haven't opened it and you already know what book it's going to offer.",
			"Thick cream paper, on your pillow. Your name. It knows your name. Whatever sends these has been reading this household for thirteen years, and today it turned the page to you.",
		},
		always = true,
		once = true,
		when = { minAge = 13, maxAge = 13, world = { era = "library" } },
		choices = {
			{ label = "Open it", result = { mind = 2, sanity = -4, setFlags = { "sl_iv_read" }, goal = "You know what book it would give you.", log = "It was right. That was the horror of it. It named the one thing, in six polite words, and offered it bound in cloth." } },
			{ label = "Burn it, the way she used to", result = { sanity = 3, mind = 1, setFlags = { "sl_iv_burned" }, goal = "You burned yours. It will come back.", log = "Blue at the edges. You watched it all the way down to nothing. There was another on the mat by morning, with the same crease in the corner." } },
			{ label = "Put it in the drawer with hers", result = { charisma = 1, relationBond = { kind = "mother", amount = 5 }, goal = "There are two names in the drawer now.", log = "She found it that night. Neither of you said anything. She put the kettle on and made two cups, which was her way of saying everything." } },
		},
	},
	{
		id = "sl_iv_door",
		story = IV,
		title = "The Pen",
		art = "home",
		text = {
			"Your mother has her good coat on, indoors, and one envelope is out of the drawer. She is sitting at the kitchen table with the invitation flat under one hand and a pen in the other. Everybody knows how it works: the moment the name is on the line, the chair is empty.",
			"The drawer is open. One envelope is on the kitchen table, smoothed flat, and your mother has her best shoes on to go nowhere. The pen is uncapped. There is a light coming off the paper, the same color as the stories of the White Nights.",
		},
		always = true,
		once = true,
		when = { minAge = 15, maxAge = 15, hasRelation = "mother", world = { era = "library" } },
		choices = {
			{
				label = "Say the one thing that will make her put the pen down",
				hint = "A Charisma check",
				clash = { stat = "charisma", foe = "The thing she wants most", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 3, sanity = 6, relationBond = { kind = "mother", amount = 20 }, setFlags = { "sl_iv_out" }, goal = "She put the pen down. The envelopes still come.", log = "You said you didn't need her to be anything she'd given up. Just home. She sat for a long time with the nib a finger's width off the paper. Then she tore it in half, and in half again, and the halves went in the stove." },
				lose = { sanity = -12, killRelation = { kind = "mother", fate = "book" }, condition = "grief", setFlags = { "sl_iv_signed" }, goal = "She signed. The chair is empty.", log = "She heard you. She smiled, and said she'd bring it back and read it to you, and wrote her name. The chair was empty before the pen stopped rolling." },
			},
			{
				label = "Sign under her name",
				hint = "It takes you with her. A fight inside the Library. Lose, and you stay.",
				clash = { stat = "strength", foe = "A Librarian", coins = 3, base = 7, coinPower = 3, fight = true },
				win = { strength = 3, sanity = -4, relationBond = { kind = "mother", amount = 20 }, setFlags = { "sl_iv_out", "saw_the_library" }, goal = "You both came home. Almost nobody does.", log = "You don't remember all of it. Shelves that went up out of sight, a woman with a face like a closed door, and then the kitchen again, and your mother's hand, and a book under her arm that she has never once opened." },
				lose = { die = "Became a book in the Library", log = "It was very well written. You could tell who it was from the first page." },
			},
			{ label = "Let her sign. It's hers to choose.", result = { mind = 4, sanity = -8, killRelation = { kind = "mother", fate = "book" }, condition = "grief", setFlags = { "sl_iv_signed" }, goal = "She signed. You let her.", log = "Nobody is made to sign. That's the cruelty of the thing, and you decided it applied to her too. You watched the pen all the way to the end of her name." } },
		},
	},
	{
		id = "sl_iv_end",
		story = IV,
		title = "The Shelf",
		art = "home",
		text = {
			"There's still an envelope with your name on the mat most mornings. You step over it the way other people step over a cat.",
			"The drawer in the kitchen still sticks. You know exactly how many envelopes are in it, and whose names.",
		},
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17, world = { era = "library" } },
		choices = {
			{ label = "Burn every one that comes, for good", result = { sanity = 6, mind = 3, storyEnd = "Unsigned: the invitations still come, and you've never opened another", log = "It's a habit now, like winding a clock. One a day, blue at the edges. The Library is very patient. So, it turns out, are you." } },
			{ label = "Find her book and bring it home", requires = { flags = { "sl_iv_signed" } }, result = { money = { -60, -20 }, sanity = 4, intelligence = 2, storyEnd = "The Book of Her: you found your mother's book on a handcart and carried it home", log = "It took a year of handcarts. The spine is the grey of her good coat. You've read the first chapter, the part before you. You're saving the rest." } },
			{ label = "Keep one envelope, in case", result = { mind = 2, sanity = -3, setFlags = { "lib_tempted" }, storyEnd = "In Case: there's one invitation in your drawer, unopened, with your name on it", log = "Just the one. Under the tea towels. You tell yourself it's a reminder. You've never been able to say of what." } },
			{ label = "Sit with your mother, and say nothing about it", requires = { flags = { "sl_iv_out" }, hasRelation = "mother" }, result = { sanity = 8, relationBond = { kind = "mother", amount = 10 }, storyEnd = "Two Cups: your mother is still at the kitchen table, and you've never spoken of it", log = "Two cups. She makes them without asking. Whatever book she wanted, she's decided she'd rather have the tea." } },
		},
	},

	-- ════ THE BOOK ═════════════════════════════════════════════════════════════
	{
		id = "sl_bk_tally",
		story = BK,
		title = "The Tally",
		art = "home",
		text = {
			"There are chalk marks on the wall by your door: one long stroke and a row of short ones. Your sister rubs them out with her sleeve every week. Every week, by morning, they're back.",
			"Someone keeps chalking a tally on your wall. One mark for the thing your sister did, and a small one beside it for every month it's gone unpaid. She won't tell you what it is. She keeps a bag packed.",
		},
		always = true,
		once = true,
		when = { minAge = 2, maxAge = 2, hasRelation = "sibling" },
		choices = {
			{ label = "Draw on the wall next to it", result = { sanity = 2, charisma = 1, log = "You added a sun and a dog. The next morning the tally was back, and someone had drawn a hat on your dog. That worried your sister more than anything." } },
			{ label = "Hold the rag while {sibling} scrubs", result = { relationBond = { kind = "sibling", amount = 8 }, mind = 1, log = "You were too small to reach. You held the bucket. She said you were a great help, and her hands were shaking." } },
			{ label = "Count the marks", result = { intelligence = 2, goal = "Twenty-six small marks. One for every month.", log = "Twenty-six small ones. You could only count to ten, so you did it in pieces. Somebody is keeping very careful track of something." } },
		},
	},
	{
		id = "sl_bk_reading",
		story = BK,
		title = "The Reading",
		art = "alley",
		text = {
			"Once a year a boy not much older than you stands under your window with a notebook and reads it out, loud enough for the street: the date, the alley, a Little Sibling's broken nose, and your sister's name. Then what's owed.",
			"It's the day they come to read the page. A child in a jacket of the Middle, serious as a clerk, announces to the whole stairwell what your sister did and what the Family is owed for it. Then he bows and goes.",
		},
		dialogue = { { who = "sl_bk_little", line = { "One nose, broken. Written the same day. The Middle always pays what's in the Book.", "It's nothing to do with you. You're not on the page. Not yet, anyway." } } },
		always = true,
		once = true,
		when = { minAge = 5, maxAge = 5, hasRelation = "sibling" },
		choices = {
			{ label = "Throw a shoe at him", result = { strength = 1, sanity = 2, rep = { middle = -3 }, goal = "You threw a shoe at the Middle. He wrote that down too.", log = "It hit him in the shoulder. He picked it up, looked at the size, and wrote in the notebook for some time. He left the shoe on the step, very politely." } },
			{ label = "Ask what the Book is", result = { intelligence = 2, setFlags = { "knows_middle" }, goal = "The Middle writes down every slight. It repays each one the same, and a little more.", log = "\"Everything anyone does to the Family,\" he said. \"We pay it back the same. And one more, for the trouble of keeping the Book.\" He seemed proud of the system." } },
			{ label = "Stand in front of {sibling}", result = { mind = 2, relationBond = { kind = "sibling", amount = 10 }, rep = { middle = 2 }, log = "You came up to her waist. The boy with the notebook looked at you for a while and wrote one more line. \"Family looks after family,\" he said. \"That's in the Book too.\"" } },
		},
	},
	{
		id = "sl_bk_kind",
		story = BK,
		title = "In Kind",
		art = "home",
		text = {
			"The interest on the page isn't paid in money. Your sister's cart is found with one wheel broken, exactly. Your window loses one pane. A Little Sibling's nose took a month to heal, so every month, something of yours is broken once.",
			"It's the Middle's arithmetic: what you did, done back, and then a little more, in small instalments, forever. This month it's the handle of the kettle. Nobody saw who. Nobody ever does.",
		},
		always = true,
		once = true,
		when = { minAge = 8, maxAge = 8, hasRelation = "sibling" },
		choices = {
			{ label = "Mend it yourself", result = { intelligence = 2, strength = 1, log = "Wire and a bent spoon. It pours crooked. Your sister says you'll be mending things your whole life at this rate, and she isn't joking." } },
			{ label = "Sit up and catch them at it", clash = { stat = "mind", foe = "A long night and a quiet Family", coins = 1, base = 3, coinPower = 3 }, win = { mind = 2, speed = 1, goal = "You saw who breaks things. He's nine. He apologised.", log = "A boy of about nine, with a small hammer and a list. He apologised to the kettle. He apologised to you. \"It's only what's written,\" he said, and did it anyway." }, lose = { sanity = -3, log = "You fell asleep against the door. In the morning there was a blanket over you that wasn't yours, and the kettle was broken." } },
			{ label = "Ask {sibling} why she did it", result = { charisma = 2, relationBond = { kind = "sibling", amount = 8 }, goal = "He was taking your milk money. She was eleven.", log = "\"He was taking your milk money,\" she said. \"You were a baby. I was eleven. I'd do it again.\" So it's your page too, really, and it always was." } },
		},
	},
	{
		id = "sl_bk_sweets",
		story = BK,
		title = "A Big Sibling's Sweets",
		art = "street",
		text = {
			"A man built like a doorway is sitting on your step, eating boiled sweets out of a paper bag. He holds the bag out. He has a book under his arm, and it's thicker than the boy's.",
			"A man too big for your step is sitting on it: a Big Sibling of the Middle, with a bag of sweets and all the time in the world, and he would like to talk to you about your sister, kindly.",
		},
		dialogue = { { who = "sl_bk_big", line = { "I like your family. You look after each other. That's all we are, you know. Just a bigger one.", "Eleven years on one page. That's a long time to owe. I'd like to see it closed. Wouldn't you?" } } },
		always = true,
		once = true,
		when = { minAge = 11, maxAge = 11, hasRelation = "sibling" },
		choices = {
			{ label = "Take a sweet", result = { charisma = 2, rep = { middle = 4 }, goal = "A Big Sibling says a page can be struck out. It has a price.", log = "Lemon. He told you there are three ways a page closes: it's paid, it's fought, or the one who owes becomes Family, and Family doesn't owe Family. He let you think about that." } },
			{ label = "Tell him to get off your step", result = { strength = 1, sanity = 2, rep = { middle = -4 }, log = "He got up, which took a while, and brushed the step off with his hand. \"That's fair,\" he said. \"It's your step.\" He wrote it down, standing." } },
			{ label = "Ask what she owes, exactly", result = { intelligence = 2, mind = 1, goal = "One nose. Eleven years of interest. And one more, for the Book.", log = "He read it to you, every line, the way you'd read a child a story. It took some time. At the end there was a total, and the total was a beating, a real one, and nobody's kettle." } },
		},
	},
	{
		id = "sl_bk_plan",
		story = BK,
		title = "The Bag by the Door",
		art = "train",
		text = {
			"Your sister has two tickets for the WARP train and a cousin in a District the Middle doesn't work. She's had the bag packed since before you could walk. She says tonight. She says they don't follow people across the City for a nose.",
			"Your sister has two tickets, bought with three years of her wages. Another District, a new name. She's shaking and she's smiling. The Book is very long, she says, and somewhere in it there must be pages they've stopped reading.",
		},
		always = true,
		once = true,
		when = { minAge = 13, maxAge = 13, hasRelation = "sibling" },
		choices = {
			{ label = "Go with her", clash = { stat = "speed", foe = "The Middle's watchers at the station", coins = 2, base = 5, coinPower = 3 }, win = { speed = 2, sanity = 3, district = "d23", relationBond = { kind = "sibling", amount = 12 }, rep = { middle = -6 }, goal = "A new District. The Book is long. It is not that long.", log = "You were through the barrier before the whistle. A new District, a cousin's floor. For almost a year, nothing of yours was broken." }, lose = { sanity = -5, money = { -30, -10 }, relationBond = { kind = "sibling", amount = 6 }, goal = "They were waiting on the platform. They were polite about it.", log = "A Little Sibling was sitting on your bag when you got there. He handed back the tickets, torn neatly in half. \"The page travels with you,\" he said. \"I'm sorry. I'd run too.\"" } },
			{ label = "Tell her running makes the page longer", result = { mind = 3, relationBond = { kind = "sibling", amount = -4 }, goal = "She stayed. She hasn't forgiven you for being right.", log = "You'd asked the Big Sibling, months ago. Running is written down as well. She sold the tickets at a loss and didn't speak to you for a month." } },
			{ label = "Stay, and send her alone", result = { sanity = -4, mind = 2, relationBond = { kind = "sibling", amount = 10 }, goal = "She's gone. The tally on the wall is yours now.", log = "One of you had to still be here, or they'd look. You waved her off and went home and stood by the wall. In the morning the chalk had your name beside it." } },
		},
	},
	{
		id = "sl_bk_page",
		story = BK,
		title = "The Page",
		art = "syndicate",
		text = {
			"It comes due. A Big Sibling and four Little ones, in the yard behind the dye works, with the Book open on a crate. Fifteen years of one page. He reads the total. He asks, as the Book requires, how the Family is to be paid.",
			"The yard behind the dye works. The Book is open at your family's page, and it's so worn the corner's gone. The Middle has come to close it tonight, one way or another, and it has come for whoever will stand for it.",
		},
		dialogue = { { who = "sl_bk_big", line = { "Paid, fought or Family. I don't mind which. I'd like to go home with the page struck out.", "It's been a long page. I've rather enjoyed your family. How do you want to finish it?" } } },
		always = true,
		once = true,
		when = { minAge = 15, maxAge = 15 },
		choices = {
			{
				label = "Pay it yourself, in kind",
				hint = "It will hurt, and it will be over.",
				result = { health = { -16, -9 }, sanity = -4, condition = "broken_arm", rep = { middle = 25 }, setFlags = { "sl_bk_paid" }, relationBond = { kind = "sibling", amount = 20 }, goal = "The page is struck out. It was done to you, by the Book.", log = "The same as was done, and one more for the Book. It was careful and it was fair and it was awful. Then he drew a line through the page with a ruler, and shook your good hand." },
			},
			{
				label = "Fight for the page",
				clash = { stat = "strength", foe = "A Big Sibling of the Middle", coins = 3, base = 7, coinPower = 3, fight = true, enemy = "middle_big" },
				win = { strength = 3, rep = { middle = -20 }, setFlags = { "sl_bk_fought" }, relationBond = { kind = "sibling", amount = 15 }, goal = "You won the yard. The page is longer now.", log = "He went down like a wall. From the ground he said it was a good fight and that he'd write it up fairly. The page you came to close is three pages now." },
				lose = { health = { -22, -12 }, rep = { middle = 15 }, setFlags = { "sl_bk_paid" }, cause = "Repaid by the Middle", goal = "They took it out of you. The page is closed.", log = "He paid the page off in one go, out of you. Afterwards he sat you against the crate and gave you a sweet. Lemon." },
			},
			{
				label = "Ask to be written in as Family",
				hint = "Family doesn't owe Family.",
				result = { career = "middle", rep = { middle = 30 }, sanity = -3, setFlags = { "sl_bk_joined" }, goal = "You're a Little Sibling of the Middle. The page is struck out.", log = "He looked pleased, as if you'd guessed a riddle. He tore the page out whole and gave it to you, and wrote your name in the front of the Book, where the Family is. Then he handed you a notebook of your own." },
			},
		},
	},
	{
		id = "sl_bk_end",
		story = BK,
		title = "What's Written",
		art = "home",
		text = "The wall by your door is clean. You find yourself looking at it some mornings, the way you'd check a tooth with your tongue.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17 },
		choices = {
			{ label = "Keep your own book, of kindnesses", requires = { flags = { "sl_bk_paid" } }, result = { sanity = 8, charisma = 3, storyEnd = "The Other Book: you keep a book of every kindness done to you, and you repay each one", log = "It's a small green notebook. Everything anyone's done for you, written the same day. You repay each one, and a little more, for the trouble." } },
			{ label = "Wait for the next reading", requires = { flags = { "sl_bk_fought" } }, result = { strength = 3, mind = 2, sanity = -4, storyEnd = "Three Pages: you beat a Big Sibling, and the Middle is in no hurry", log = "They come once a year and read all three pages under your window. You listen from the step. It's a good account, fairly written. He kept his word about that." } },
			{ label = "Read someone their page, gently", requires = { flags = { "sl_bk_joined" } }, result = { charisma = 3, mind = 2, sanity = -2, storyEnd = "Little Sibling: you read other families their pages now, and you're kind about it", log = "You stand under a window with a notebook. There's a small child at it, counting chalk marks. You read it slowly, so they'll understand, and you leave a sweet on the step." } },
			{ label = "Chalk the wall yourself: paid", result = { sanity = 5, mind = 2, storyEnd = "Paid: the page is closed, and you wrote so on your own wall", log = "One word, in your own hand, where the tally used to be. Nobody rubbed it out." } },
		},
	},

	-- ════ A QUIET HEART ════════════════════════════════════════════════════════
	{
		id = "sl_qh_roof",
		story = QH,
		title = "The Roof",
		art = "rooftop",
		text = {
			"Before the lamps are out, an old woman climbs to your roof, sits down on a rush mat facing District 12, and stops moving. Completely. Pigeons land on her. She's been doing it since the week the second Light went out, which is as long as you've been alive.",
			"There's a woman on the roof who doesn't move. Every dawn, one hour, facing the place the Light came from. The other children say she's a statue someone forgot. You've watched closely. She blinks, about once a minute.",
		},
		always = true,
		once = true,
		when = { minAge = 2, maxAge = 2, world = { era = "limbus" } },
		choices = {
			{ label = "Sit down next to her", result = { mind = 2, setFlags = { "sl_qh_sat" }, goal = "You sat on the roof for four whole breaths.", log = "You lasted four breaths. She didn't turn her head, but the mat had been moved over, the next day, to leave room." } },
			{ label = "Poke her", result = { charisma = 1, sanity = 2, log = "Nothing. You poked harder. One eye opened, looked at you with great interest, and shut again." } },
			{ label = "Watch from the stairs", result = { intelligence = 1, mind = 1, goal = "There's an old woman on the roof at dawn. She blinks once a minute.", log = "An hour is a very long time when you're two. You counted her blinks instead. Sixty-one." } },
		},
	},
	{
		id = "sl_qh_mat",
		story = QH,
		title = "Room on the Mat",
		art = "rooftop",
		text = {
			"The old woman on the roof speaks to you for the first time. The first lesson, she says, is to sit. You ask what the second lesson is. She says it's to sit.",
			"There's a second mat on the roof now, child-sized. The old woman who sits up there at dawn made it over the winter and never mentioned it. Sit, she says. That's all. If you want something more interesting, the street is full of it.",
		},
		dialogue = { { who = "sl_qh_teacher", line = { "Everyone has a heart that jumps about. You're going to teach yours to sit down.", "You'll hate this for about six years. Then you won't. Shall we?" } } },
		always = true,
		once = true,
		when = { minAge = 5, maxAge = 5, world = { era = "limbus" } },
		choices = {
			{ label = "Sit, every dawn, for a year", clash = { stat = "mind", foe = "An hour of sitting still", coins = 1, base = 3, coinPower = 3, fixed = true }, win = { mind = 3, setFlags = { "sl_qh_sat" }, goal = "You can sit for an hour. She says that's the alphabet.", log = "By the end of the year you could do the hour. She said that was the alphabet, and that next you'd learn a word." }, lose = { mind = 1, sanity = 1, goal = "You can sit for about as long as it takes to boil an egg.", log = "You fidgeted for a year. She said that was fine: fidgeting on a mat is still more than most people ever do." } },
			{ label = "Ask what it's for", result = { intelligence = 2, setFlags = { "knows_shin" }, goal = "She says there's a strength in a heart held still. It's new. It came with the Light.", log = "\"There's a strength in it now,\" she said. \"There didn't use to be. Since the seven days. A heart held still can do things. The fencing schools call it Shin. I call it sitting.\"" } },
			{ label = "Run off and play instead", result = { speed = 2, sanity = 2, log = "She watched you go without any expression at all. The small mat stayed out, in all weathers, for when you came back." } },
		},
	},
	{
		id = "sl_qh_feeling",
		story = QH,
		title = "One Feeling",
		art = "rooftop",
		text = {
			"The old woman on the roof has a word for today, and it turns out to be this: pick one feeling. Any one. The worst day you've had, the best. Hold it in front of you like a cup of water and don't let it move.",
			"Today's lesson on the roof: one feeling, held still. The old woman says most people's feelings carry them about like a cart with no driver. You're going to hold the reins of exactly one, for exactly one hour.",
		},
		always = true,
		once = true,
		when = { minAge = 8, maxAge = 8, world = { era = "limbus" } },
		choices = {
			{ label = "Hold the day you were happiest", result = { sanity = 5, mind = 2, goal = "You held a good day still for an hour. It didn't spoil.", log = "It was a day with soup in it. You held it for the whole hour and it didn't go off, the way good things usually do when you look straight at them." } },
			{ label = "Hold the thing you're most angry about", clash = { stat = "mind", foe = "Your own temper", coins = 2, base = 4, coinPower = 3 }, win = { mind = 3, strength = 1, goal = "You held your anger still. It's a lot heavier than it looks.", log = "It wanted to go somewhere. You didn't let it. At the end of the hour it was still exactly as angry, and it was sitting where you'd put it." }, lose = { sanity = -4, mind = 1, log = "It got away from you in the first ten minutes and you kicked the chimney. She waited until you'd finished and said: again tomorrow." } },
			{ label = "Ask what she holds", result = { charisma = 2, mind = 1, goal = "She holds a week, forty years ago. Three bright days and four dark.", log = "\"A week,\" she said. \"A long time ago. Three days I wasn't afraid, and four when I was. I've been holding it ever since. It's why I was ready when the second one came.\"" } },
		},
	},
	{
		id = "sl_qh_ring",
		story = QH,
		title = "A Ring",
		art = "rooftop",
		text = {
			"The old woman on the roof shows you, once. She breathes out, and there's a thin burning circle behind her shoulder, the color of an old bruise. The air hums. Then she lets it go and has to sit down, though she was sitting already.",
			"For the first time in nine years the old woman on the roof moves fast: one breath, and a ring of something like coal-light stands at her back. It lasts a count of three. She's grey in the face afterwards, and she says that's what it costs.",
		},
		dialogue = { { who = "sl_qh_teacher", line = { "That's Mang. One thing I want, held perfectly still, where I can lean on it. I have the one. I'm not strong enough for two.", "Every ring is nearly twice the weight of the last. The people with three don't smile much. Don't be in a hurry to be one of them." } } },
		always = true,
		once = true,
		when = { minAge = 11, maxAge = 11, world = { era = "limbus" } },
		codex = "terms_shin",
		choices = {
			{ label = "Ask what she wants", result = { charisma = 2, mind = 2, goal = "Her ring is a thing she wants and can't have. She leans on it anyway.", log = "\"To have been braver, the first time it went dark,\" she said. \"You can't have that. But you can stand on it.\"" } },
			{ label = "Ask to learn it now", result = { mind = 2, sanity = -2, goal = "She says no. She says ask again when you can hold your temper for an hour.", log = "\"No,\" she said, with real pleasure. \"You can't hold your own breakfast still. Ask me in four years.\"" } },
			{ label = "Help her down the stairs", result = { sanity = 3, relationBond = { kind = "all", amount = 3 }, charisma = 1, log = "She leaned on you the whole way and told you not to tell anyone. It was the first time you understood that she's old." } },
		},
	},
	{
		id = "sl_qh_street",
		story = QH,
		title = "The Street Below",
		art = "distortion",
		text = {
			"There's screaming in the street, the wrong kind. The cobbler's lost his shop and his son in one season, and something is happening to the air around him: doors opening onto the same wall, the smell of leather and glue, and a kind voice that isn't anyone's.",
			"A man on your street is at the end of his rope, and everyone can feel it: the lamps are bending toward him. He's nodding at someone nobody can see. The old woman is already on the stairs, faster than you've ever seen her move.",
		},
		always = true,
		once = true,
		when = { minAge = 13, maxAge = 13, world = { era = "limbus" } },
		codex = "terms_distortion",
		choices = {
			{
				label = "Go and sit down in front of him",
				hint = "A Mental Strength check",
				clash = { stat = "mind", foe = "A kind voice, speaking to somebody else", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = 4, charisma = 2, addTrait = "lim_talks_them_down", goal = "You sat down in front of a breaking man, and he sat down too.", log = "You did the only thing you know how to do. You sat. After a while, because there was nothing else in the street that made sense, he sat too. The lamps straightened. She said she couldn't have done it better, and you could tell it cost her to say so." },
				lose = { sanity = -8, health = { -8, -4 }, goal = "The Fixers came. She says you were right to try.", log = "You sat. He didn't. The street folded up around the two of you like a shoe box, and it took four Fixers to get you out of it." },
			},
			{ label = "Hold the door for the old woman", result = { speed = 1, mind = 2, sanity = -3, goal = "She talked him back. It took everything she had.", log = "She walked up to him as if he were a neighbour, which he was, and stood there being still at him until he remembered he was a person. Then she was sick in the gutter." } },
			{ label = "Run for the Fixers", result = { speed = 2, sanity = -4, setFlags = { "knows_fixers" }, goal = "The Fixers dealt with it. Nobody says what that means.", log = "They were there in six minutes. The street was put right by evening. The cobbler's shop has been boarded up since, and nobody on the street says his name." } },
		},
	},
	{
		id = "sl_qh_stillness",
		story = QH,
		title = "The Stillness",
		art = "rooftop",
		text = {
			"Ten years of dawns on the roof. The old woman says today you're going to hold the worst thing you have, for the whole hour, and that if you can, something will be different afterwards. She says she'll sit with you, and that she won't help.",
			"The old woman has laid the two mats side by side on the roof, facing District 12. Today, she says. The worst thing. Hold it like the cup of water. If your heart sits down and stays down, you'll know. Everybody knows when it happens.",
		},
		always = true,
		once = true,
		when = { minAge = 15, maxAge = 15, world = { era = "limbus" } },
		choices = {
			{
				label = "Hold it for the hour",
				hint = "A hard Mental Strength check. Ten years of sitting are in it.",
				clash = { stat = "mind", foe = "The worst thing you have, for an hour", coins = 3, base = 6, coinPower = 3 },
				win = { addTrait = "shin", mind = 4, sanity = 8, setFlags = { "sl_qh_shin", "knows_shin" }, chronicle = "learned_shin", goal = "Your heart sat down, and stayed down. Shin.", log = "Somewhere in the fortieth minute it stopped struggling. Not gone. Just sitting where you'd put it, as it will for the rest of your life. She cried, without moving at all." },
				lose = { mind = 2, sanity = -6, goal = "Not today. She says it took her until she was fifty.", log = "It got up and walked off with you in the fiftieth minute. She said she was fifty before hers stayed down, and that she'd expected nothing else, and that you were ahead of her by thirty-five years." },
			},
			{ label = "Tell her you're not ready", result = { mind = 2, sanity = 3, setFlags = { "sl_qh_sat" }, goal = "You'll know when. She says knowing that is most of it.", log = "\"Good,\" she said. \"The ones who think they're ready are the ones the voice gets.\" You sat an ordinary hour instead." } },
			{ label = "Tell her you're done with roofs", result = { strength = 2, speed = 2, sanity = -3, setFlags = { "sl_qh_left" }, goal = "You left the roof. The small mat is still out.", log = "Ten years, and you wanted a life that moved. She nodded. She didn't say you were wrong. She left your mat where it was." } },
		},
	},
	{
		id = "sl_qh_end",
		story = QH,
		title = "Dawn",
		art = "rooftop",
		text = "The old woman doesn't climb the stairs every day now. Some mornings there's only one of you up here, facing the place the Light came from.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17, world = { era = "limbus" } },
		choices = {
			{ label = "Sit. That's all.", requires = { flags = { "sl_qh_shin" } }, result = { sanity = 8, mind = 3, storyEnd = "Stillness: you sit on the roof at dawn, and your heart sits with you", log = "One hour. A child from the third floor has started watching from the stairs. You've been thinking about making a small mat." } },
			{ label = "Try for a ring", requires = { flags = { "sl_qh_shin" } }, clash = { stat = "mind", foe = "A ring of your own wanting", coins = 2, base = 6, coinPower = 3 }, win = { addTrait = "mang_one", mind = 2, sanity = -3, storyEnd = "One Ring: a thing you want stands at your back, held still", log = "It came the color of the thing you want most. It hums. You'll be tired for the rest of your life, a little, and you'll never be knocked down easily again." }, lose = { sanity = -8, storyEnd = "Not Yet: you reached for a ring, and it wasn't there", log = "It flickered and went. She'd told you not to hurry. You'll be a year putting your heart back where it was." } },
			{ label = "Keep sitting until it comes", requires = { flags = { "sl_qh_sat" } }, result = { mind = 4, sanity = 5, storyEnd = "Every Dawn: you're still sitting, and you're in no hurry", log = "She was fifty. You've got time. It can't be hurried, and you've stopped wanting to." } },
			{ label = "Come back up, and sit down", requires = { flags = { "sl_qh_left" } }, result = { mind = 3, sanity = 6, charisma = 1, setFlags = { "sl_qh_sat" }, storyEnd = "The Small Mat: you left the roof, and came back to it", log = "Two years of a life that moved, and one morning you climbed the stairs again. The small mat was still out. She moved over without opening her eyes." } },
			{ label = "Stay down in the street, for good", result = { strength = 2, speed = 2, charisma = 2, storyEnd = "The Street: you chose a life that moves", log = "You wave up at the roof when you pass. Sometimes one eye opens." } },
		},
	},
}
