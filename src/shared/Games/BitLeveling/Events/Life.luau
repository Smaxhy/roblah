--[[
	A LIFE, YEAR BY YEAR (ORIGINAL GAME CONTENT). Childhood and the teen years, before the
	Gates (when.maxYear = -1) and under them (when.minYear = 0). Gates and Hunters here are
	the world as canon describes it; every person and incident is this game's own.
]]

return {
	-- ── early childhood ──
	{ id = "lf_first_word", title = "First Word", text = "Your first word wasn't 'mum' or 'dad'. Your family argues about what it was for years.", weight = 6, once = true, when = { minAge = 1, maxAge = 2 }, result = { intelligence = 1, charisma = 1, log = "Your first word became a family legend." } },
	{ id = "lf_daycare", title = "The Daycare Fight", text = "A bigger kid at daycare took the red crayon. Every day. Today you want the red crayon.", weight = 6, when = { minAge = 3, maxAge = 6 },
		choices = {
			{ label = "Take it back", clash = { stat = "strength", foe = "The crayon thief", coins = 1, base = 2, coinPower = 2 }, win = { strength = 1, willpower = 1, log = "You took it back. Nobody took your crayons again." }, lose = { sanity = -2, log = "You ended up crying and the teacher gave you the blue one." } },
			{ label = "Share the box", result = { charisma = 2, addRelation = { kind = "friend", bond = 55, age = { 4, 6 } }, log = "You offered to share. By lunch the two of you were inseparable." } },
		} },
	{ id = "lf_grandma_stories", title = "Grandmother's Stories", text = "Your grandmother tells stories every night: ghosts in the mountains, tigers that talk, doors that open where no door should be.", weight = 5, once = true, when = { minAge = 3, maxAge = 8, maxYear = -1 }, result = { intelligence = 1, willpower = 1, log = "Years later you'd remember the one about the door, and get goosebumps." } },
	{ id = "lf_siren_drill", title = "The Siren Drill", text = "Kindergarten has a new drill. When the Gate siren goes, you hold hands, walk to the basement, and sing the counting song until the teacher says stop.", weight = 7, once = true, when = { minAge = 4, maxAge = 7, minYear = 0 },
		choices = {
			{ label = "Sing loudest", result = { charisma = 1, sanity = 1, log = "You sang loudest, and the little ones stopped crying." } },
			{ label = "Ask what a Gate is", result = { intelligence = 1, sanity = -1, codex = { "lore_gates" }, log = "The teacher said it was a door for bad things, and the Hunters close it. You didn't sleep well that night." } },
		} },
	{ id = "lf_hunter_toy", title = "A Hunter Figure", text = "Every kid in your class has a figure of a famous Hunter. You've been asking for one for a month.", weight = 6, when = { minAge = 5, maxAge = 10, minYear = 2 },
		choices = {
			{ label = "Keep asking", clash = { stat = "charisma", foe = "Your parents' budget", coins = 1, base = 3, coinPower = 2 }, win = { sanity = 3, log = "You got it for your birthday: a Hunter with a cape and a light-up sword." }, lose = { sanity = -1, log = "You got socks. You played Hunters with a stick instead." } },
			{ label = "Make your own", result = { intelligence = 1, sanity = 1, log = "You made a Hunter out of cardboard and tape. It had four swords." } },
		} },
	{ id = "lf_lost_market", title = "Lost at the Market", text = "One moment your mother's hand was there, the next it wasn't, and the market is enormous.", weight = 5, once = true, when = { minAge = 4, maxAge = 7 },
		choices = {
			{ label = "Stay where you are", result = { willpower = 1, log = "You stood still like you'd been told. She found you in ten minutes, crying harder than you were." } },
			{ label = "Ask a shopkeeper for help", result = { charisma = 1, log = "The fish seller put you on her counter and shouted until your mother came running." } },
		} },
	{ id = "lf_parent_late", title = "The Night Dad Was Late", text = "There was a Dungeon Break across the city and your father didn't come home from work. Your mother has had the TV on for hours.", weight = 5, once = true, when = { minAge = 5, maxAge = 12, minYear = 1, hasRelation = "father" },
		choices = {
			{ label = "Wait up with her", result = { willpower = 2, sanity = -3, log = "He walked in at three in the morning, grey with dust. His bus had been stopped behind a cordon. Your mother didn't let go of him for a long time." } },
			{ label = "Go to bed like she says", result = { sanity = -2, log = "You lay awake listening until you heard the door." } },
		} },
	{ id = "lf_school_first", title = "First Day of School", text = "A new building, a new uniform, thirty new faces.", weight = 7, once = true, when = { minAge = 6, maxAge = 7 },
		choices = {
			{ label = "Talk to the kid next to you", result = { charisma = 1, addRelation = { kind = "friend", bond = 50, age = { 6, 7 } }, log = "The kid next to you had the same pencil case. That settled it." } },
			{ label = "Read the books on the shelf", result = { intelligence = 2, log = "You'd finished half the classroom library by the end of term." } },
			{ label = "Race everyone at break time", result = { agility = 2, log = "You were the fastest in the year, and you made sure everyone knew." } },
		} },
	{ id = "lf_test", title = "The Big Test", text = "The class has a big test this week. Your parents have been talking about cram school.", weight = 7, cooldown = 3, when = { minAge = 8, maxAge = 17 },
		choices = {
			{ label = "Study every night", clash = { stat = "intelligence", foe = "The test", coins = 2, base = 4, coinPower = 2 }, win = { intelligence = 2, sanity = 1, log = "Top five in the class. Your mother put the paper on the fridge." }, lose = { intelligence = 1, sanity = -2, log = "You studied the wrong chapters." } },
			{ label = "Wing it", clash = { stat = "luck", foe = "The test", coins = 1, base = 5, coinPower = 2 }, win = { sanity = 2, log = "Somehow you passed. You told nobody how." }, lose = { sanity = -2, log = "You didn't pass. Your father went very quiet." } },
		} },
	{ id = "lf_stray", title = "The Stray", text = "A thin stray cat has been sleeping under the stairs of your building.", weight = 5, once = true, when = { minAge = 6, maxAge = 14 },
		choices = {
			{ label = "Feed it every day", result = { charisma = 1, sanity = 3, log = "It started waiting for you at the gate after school." } },
			{ label = "Leave it be", result = { log = "One day it was just gone." } },
		} },
	{ id = "lf_hunter_on_tv", title = "Hunters on TV", text = "There's a broadcast of a guild's raid team coming out of a Gate, filthy and grinning, carrying crates of glowing crystals.", weight = 6, cooldown = 4, when = { minAge = 7, maxAge = 15, minYear = 1 },
		choices = {
			{ label = "Decide you'll be a Hunter one day", result = { strength = 1, willpower = 1, setFlags = { "dreams_hunter" }, log = "You started doing push-ups every night. Just in case." } },
			{ label = "Decide you'll never go near one", result = { intelligence = 1, setFlags = { "dreams_safe" }, log = "You changed the channel." } },
		} },
	{ id = "lf_ordinary_summer", title = "The Long Summer", text = "Summer at your grandparents' in the countryside: rivers, insects, and nothing at all happening.", weight = 5, cooldown = 3, when = { minAge = 6, maxAge = 13, maxYear = -1 }, result = { vitality = 2, agility = 1, sanity = 3, log = "You came back brown and scraped and happy." } },
	{ id = "lf_countryside_gate", title = "No Summer This Year", text = "Your grandparents' village is inside an Association exclusion zone this summer: a Gate opened in the hills behind it. They're staying with you instead.", weight = 4, once = true, when = { minAge = 6, maxAge = 13, minYear = 1 }, result = { charisma = 1, sanity = -1, log = "Your grandfather spent the whole summer watching Gate news and muttering at it." } },
	{ id = "lf_bully", title = "The Bully", text = "An older kid has started waiting for you after school.", weight = 6, cooldown = 3, tags = { "danger" }, when = { minAge = 9, maxAge = 15 },
		choices = {
			{ label = "Stand up to them", clash = { stat = "strength", foe = "The older kid", coins = 2, base = 4, coinPower = 2, fight = true }, win = { strength = 2, willpower = 1, log = "They didn't wait for you after that." }, lose = { vitality = { -8, -3 }, sanity = -3, log = "You went home with a split lip and didn't say why.", cause = "Hurt in a schoolyard fight" } },
			{ label = "Take a different way home", result = { agility = 1, sanity = -1, log = "You found a long way round through the market. It took twenty minutes longer." } },
			{ label = "Tell a teacher", result = { charisma = 1, log = "The teacher called their parents. It got better, slowly." } },
		} },
	{ id = "lf_hunter_kid", title = "A Hunter's Kid", text = "A kid in your class has a parent who's a Hunter. They act like it makes them one too.", weight = 5, once = true, when = { minAge = 8, maxAge = 14, minYear = 3 },
		choices = {
			{ label = "Get them to tell stories", result = { intelligence = 1, addRelation = { kind = "friend", bond = 45, age = { 8, 14 } }, codex = { "lore_classes" }, log = "Their mum was a Tanker. They knew everything about raid formations, or said they did." } },
			{ label = "Tell them they're not special", clash = { stat = "charisma", foe = "A Hunter's kid with something to prove", coins = 1, base = 4, coinPower = 2 }, win = { charisma = 1, log = "The class laughed with you. They went quiet for a week." }, lose = { sanity = -2, log = "The class laughed at you instead." } },
		} },
	{ id = "lf_phone", title = "Your First Phone", text = "Your parents gave you a phone, mostly so the Gate alerts reach you.", weight = 6, once = true, when = { minAge = 9, maxAge = 13, minYear = 0 }, result = { intelligence = 1, log = "The first alert came three days later. It was for a Gate six districts away. You read it four times." } },

	-- ── the teen years ──
	{ id = "tn_club", title = "Clubs", text = "Every student has to join a club this year.", weight = 7, once = true, when = { minAge = 13, maxAge = 15 },
		choices = {
			{ label = "Athletics", result = { agility = 2, vitality = 1, log = "You were made for the 400 metres." } },
			{ label = "Judo", result = { strength = 2, willpower = 1, log = "You spent a year being thrown on a mat and loved every minute." } },
			{ label = "Science", result = { intelligence = 3, log = "You built a mana detector out of a radio. It didn't work. It was still the best project in the year." } },
			{ label = "Broadcasting", result = { charisma = 3, log = "You read the school news every morning. People started recognising your voice." } },
		} },
	{ id = "tn_awaken_friend", title = "Your Friend Awakened", text = "Your best friend didn't come to school for a week. When they came back, they could lift the teacher's desk with one hand. They're an E-rank, they say, and they're leaving school to work.", weight = 5, once = true, when = { minAge = 14, maxAge = 19, minYear = 0, hasRelation = "friend" },
		choices = {
			{ label = "Be happy for them", result = { charisma = 2, sanity = -1, log = "You hugged them. You didn't tell them how much it scared you." } },
			{ label = "Ask them what it felt like", result = { intelligence = 1, willpower = 1, codex = { "lore_awakening" }, log = "'Like being sick,' they said, 'and then being someone slightly different.'" } },
			{ label = "Tell them not to go into Gates", result = { willpower = 1, sanity = -2, log = "They laughed it off. You kept checking the raid news after that." } },
		} },
	{ id = "tn_exam_year", title = "The Exam Year", text = "This is the year. The university exam decides everything, or that's what everyone keeps telling you.", weight = 8, once = true, when = { minAge = 17, maxAge = 18 },
		choices = {
			{ label = "Study like your life depends on it", clash = { stat = "intelligence", foe = "The national exam", coins = 2, base = 8, coinPower = 3 }, win = { intelligence = 4, setFlags = { "uni_ready" }, log = "A top score. Your mother cried on the phone to every relative you have." }, lose = { intelligence = 2, sanity = -4, log = "Not good enough for the good schools. Not bad enough to be a disaster." } },
			{ label = "Don't take it", hint = "There's work. There are other ways.", result = { strength = 1, sanity = 2, setFlags = { "no_uni" }, log = "You skipped it. Your father didn't speak to you for a month." } },
		} },
	{ id = "tn_part_time", title = "A Part-Time Job", text = "The convenience store on the corner is hiring night shifts.", weight = 6, once = true, when = { minAge = 15, maxAge = 19 },
		choices = {
			{ label = "Take it", result = { money = 2, willpower = 1, sanity = -1, log = "Nights of instant noodles and empty aisles. The money was good for a kid." } },
			{ label = "No thanks", result = { log = "You kept your evenings." } },
		} },
	{ id = "tn_hunter_fan", title = "The Fan Meeting", text = "A famous C-rank Hunter is signing autographs at the mall. The queue goes round the block.", weight = 5, once = true, when = { minAge = 12, maxAge = 18, minYear = 3 },
		choices = {
			{ label = "Queue for three hours", result = { sanity = 3, log = "They signed your notebook and asked what you wanted to be. You said 'you', and they laughed, but nicely." } },
			{ label = "Skip it", result = { log = "Your friends showed you the photos." } },
		} },
	{ id = "tn_rumour_test", title = "The Awakening Rumour", text = "Someone at school swears you can make yourself awaken if you stand close enough to a Gate. Some kids are planning to sneak through a cordon on Saturday.", weight = 5, once = true, tags = { "danger" }, when = { minAge = 13, maxAge = 17, minYear = 1 },
		choices = {
			{ label = "Go with them", clash = { stat = "luck", foe = "A Gate cordon at night", coins = 2, base = 7, coinPower = 3, fixed = true }, win = { willpower = 2, sanity = -3, log = "A patrol officer caught you a hundred metres from the tape and drove you all home. Nobody awakened. (It doesn't work like that.)" }, lose = { vitality = { -20, -8 }, sanity = -6, log = "Something was already out of the Gate. You were lucky it was small.", cause = "Killed sneaking through a Gate cordon" } },
			{ label = "Tell them it doesn't work like that", result = { intelligence = 1, codex = { "lore_awakening" }, log = "Nobody listened. They didn't get past the police either." } },
		} },
	{ id = "tn_first_heartbreak", title = "Drifting Apart", text = "You and your oldest friend don't sit together any more. Nobody decided it. It just happened.", weight = 4, once = true, when = { minAge = 14, maxAge = 18, hasRelation = "friend" },
		choices = {
			{ label = "Try to fix it", clash = { stat = "charisma", foe = "Growing up", coins = 1, base = 4, coinPower = 2 }, win = { charisma = 2, relationBond = { kind = "friend", amount = 15 }, log = "You bought them tteokbokki after school, like when you were ten. It helped." }, lose = { sanity = -2, log = "It was awkward. You both pretended it wasn't." } },
			{ label = "Let it go", result = { willpower = 1, sanity = -1, log = "People change." } },
		} },
	{ id = "tn_gate_alert_class", title = "Lockdown", text = "The school's Gate siren goes off for real in the middle of maths. A Gate opened two streets away.", weight = 5, once = true, tags = { "danger" }, when = { minAge = 12, maxAge = 18, minYear = 1 },
		choices = {
			{ label = "Help the teacher keep everyone calm", result = { charisma = 2, willpower = 1, sanity = -1, log = "You led the counting song like you were five again. People laughed. It helped." } },
			{ label = "Watch from the window", result = { sanity = -2, codex = { "lore_rights" }, log = "You saw the Association van arrive, then a guild's truck, then four Hunters walk into it like it was a shop. Forty minutes later it closed." } },
		} },
	{ id = "tn_military_notice", title = "The Draft Letter", text = "The letter about military service has arrived.", weight = 4, once = true, when = { minAge = 18, maxAge = 20, form = "human" },
		choices = {
			{ label = "Serve now", result = { strength = 2, vitality = 2, willpower = 2, sanity = -2, log = "Two years of mud, discipline and Gate-cordon drills. You came out harder." } },
			{ label = "Defer it for school", result = { intelligence = 1, log = "You deferred. It'll come up again." } },
		} },
}
