--[[
	Arcs (area A): the follow-ups that childhood choices schedule years ahead. Everything
	here is weight 0 and is reached only through `schedule`; each `when` is re-checked when
	it comes due, so an arc quietly ends if its people are gone or its flags don't fit.
		Bori        bread at 5 -> her pack at 11 -> a Fixer, a Syndicate boss or a Rat at 30
		Lotte       Nest prep school at 5 -> her scholarship at 13 -> a clerk or a teacher
		the boy     a wave through the Nest gate at 3 -> a porter at the checkpoint at 25
		Ottavio     the Fixer down the street -> his yard at 13 -> his debt at 26
		Kasimir     the academy rival -> a Capo, an auditor or a friend at 29
		Tamas       the boy with the camera -> erased, or a photographer at 26
		the poster  a boy-soldier's face in a veteran's box -> the man himself at 35
		Marisol     the Fixer who walked you home when you were lost -> a job at 15
		the baby    a neighbor's baby you ran for -> a courier at 18
		graduation  the academy at 6 -> a certificate at 16
]]

return {
	-- ── Bori ───────────────────────────────────────────────────────────────
	{
		id = "bs_c_bori_pack",
		title = "Bori's Pack",
		text = "Bori is eleven now and runs with a Rat pack: five kids who call themselves the Tin Cans, sleep in an old boiler room and eat whatever falls off the carts. She's their best thief. Tonight she's waiting on the bakery step, the way she used to. \"Come with us,\" she says. \"We look after our own. Nobody else does.\"",
		weight = 0,
		when = { side = "backstreets", flags = { "bs_bori_shared" }, maxAge = 15 },
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Run with the Tin Cans",
				result = {
					speed = 2,
					health = 1,
					setFlags = { "bs_rat_past", "bs_bori_pack" },
					schedule = { { event = "bs_y_tin_cans_job", inYears = 2 }, { event = "bs_a_bori_boss", inYears = 19 } },
					log = "You ran with the Tin Cans: rooftops, boiler rooms, stolen oranges, and always home before three, because Bori was strict about that. You were a Rat now. You were also, for the first time, part of something.",
				},
			},
			{
				label = "Get her a job at the noodle stall instead",
				hint = "Mental Strength check. Bori doesn't like being told what to do.",
				clash = { stat = "mind", foe = "Bori's pride", coins = 1, base = 2, coinPower = 2 },
				win = {
					sanity = 3,
					setFlags = { "bs_bori_saved", "bs_knows_mun" },
					schedule = { event = "bs_a_bori_fixer", inYears = 19 },
					log = "You talked Auntie Mun into hiring Bori to wash bowls. Bori complained for a month, then never missed a shift. She left the Tin Cans that winter, and she never once said thank you, which is how you knew.",
				},
				lose = {
					sanity = -2,
					setFlags = { "bs_bori_apart" },
					schedule = { event = "bs_a_bori_rat", inYears = 19 },
					log = "Bori laughed at you. \"Washing bowls? I make more in an hour than a bowl-washer makes in a week.\" She went back to the pack, and you saw her less after that.",
				},
			},
			{
				label = "Say no, and walk her home",
				result = {
					mind = 1,
					sanity = -1,
					setFlags = { "bs_bori_apart" },
					schedule = { event = "bs_a_bori_rat", inYears = 19 },
					log = "You said no. She shrugged as if it didn't matter, which is how you knew it did. After that you mostly saw her at a distance, always with the pack.",
				},
			},
		},
	},
	{
		id = "bs_c_bori_tax",
		title = "Bun Tax",
		text = "Five kids step out of an alley and block your way home. Rats: the youngest pack on the street, all elbows and borrowed knives. The one in front is a thin girl with a very still face. \"I remember you,\" says Bori. \"You had a bun once. Bun tax. Pay up.\"",
		weight = 0,
		when = { side = "backstreets", flags = { "bs_bori_refused" }, maxAge = 15 },
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Empty your pockets",
				requires = { min = { money = 5 } },
				result = { money = -5, sanity = -1, setFlags = { "bs_bori_apart" }, schedule = { event = "bs_a_bori_rat", inYears = 19 }, log = "You paid. Bori counted it twice and said \"Nice doing business.\" After that, the pack let you pass without a word." },
			},
			{
				label = "Shove your way through",
				clash = { stat = "strength", foe = "Five Rat kids", coins = 1, base = 2, coinPower = 2, fight = true },
				win = { strength = 2, setFlags = { "bs_bori_apart" }, schedule = { event = "bs_a_bori_rat", inYears = 19 }, log = "You shoved through and ran, and they didn't chase you far. Bori called after you: \"Not bad!\" It was the closest thing to respect you'd ever get from her." },
				lose = { health = { -6, -3 }, sanity = -2, setFlags = { "bs_bori_apart" }, schedule = { event = "bs_a_bori_rat", inYears = 19 }, log = "They sat on you and turned out your pockets. Bori didn't hit you. She just watched the whole time, which was worse.", cause = "Mugged by Rat kids" },
			},
			{
				label = "\"I'll bring you a bun. A whole one.\"",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A suspicious Rat", coins = 1, base = 2, coinPower = 2 },
				win = {
					sanity = 3,
					setFlags = { "bs_bori_apart", "bs_bori_bunfriend" },
					addRelation = { kind = "friend", name = "Bori", bond = 45, age = { 10, 12 } },
					schedule = { event = "bs_a_bori_rat", inYears = 19 },
					log = "You brought the bun the next morning, still warm. Bori stared at it for a long time. \"Huh,\" she said, and took it, and after that the Tin Cans called you \"Bun\" and walked you past the worse packs.",
				},
				lose = { sanity = -2, setFlags = { "bs_bori_apart" }, schedule = { event = "bs_a_bori_rat", inYears = 19 }, log = "\"Sure you will,\" said Bori, and took what was in your pockets anyway." },
			},
		},
	},
	{
		id = "bs_a_bori_fixer",
		title = "Half a Bun",
		text = "A Fixer in a long gray coat stops you in the street. There's a Grade 6 license clipped to her collar and a Workshop blade at her hip. It takes you a moment. Then she says, \"I still owe you half a bun,\" and you know her: Bori, from the bakery step, from Auntie Mun's sink.",
		weight = 0,
		when = { flags = { "bs_bori_saved" } },
		choices = {
			{
				label = "Buy her lunch",
				result = { sanity = 5, relationBond = { kind = "friend", amount = 10 }, log = "You bought her noodles at the stall where she used to wash bowls. She told you about her Office, her license exam (\"failed it twice, passed it angry\"), and a Night she'd rather not talk about. She paid, in the end. She insisted." },
			},
			{
				label = "Ask if her Office needs a hand",
				clash = { stat = "strength", foe = "A Rat pack holding a warehouse", coins = 2, base = 4, coinPower = 3, fight = true },
				win = { wage = { 100, 220 }, strength = 2, setFlags = { "bs_bori_worked" }, log = "Bori took you along on a warehouse job as backup. You held the side door while she cleared the floor. She split the fee down the middle, like a bun." },
				lose = { health = { -10, -4 }, wage = { 20, 50 }, log = "The warehouse job went sideways and you went down early. Bori got you out over her shoulder and paid you anyway. \"Half a bun,\" she said. \"Now we're even.\"", cause = "Killed backing up a Fixer" },
			},
			{
				label = "Ask about the Tin Cans",
				result = { mind = 2, sanity = -1, log = "\"Two are Fixers now,\" she said. \"One's a Soldato of the Thumb. He bows to me in the street, which is funny.\" She didn't say what happened to the other two, and you didn't ask." },
			},
		},
	},
	{
		id = "bs_a_bori_boss",
		title = "The Tin Cans Grew Up",
		text = "The Tin Cans aren't Rats anymore. They run out of a tea shop on the corner now: eleven members, a real name painted on the window, and the street pays them protection instead of the other way round. A boy you don't know comes to fetch you. Bori is behind the counter, older and sharper. \"You were a Tin Can,\" she says. \"Tin Cans don't pay.\"",
		weight = 0,
		when = { side = "backstreets", flags = { "bs_bori_pack" } },
		codex = "bs_lore_alley_grades",
		choices = {
			{
				label = "Accept, and thank her properly",
				result = { sanity = 3, money = { 40, 90 }, setFlags = { "bs_tin_can_protected" }, log = "You bowed exactly the right amount. Bori waved it off, embarrassed, and sent you home with a tin of tea and a promise that nobody on your stairs would ever be bothered. Nobody was." },
			},
			{
				label = "Ask her to let Auntie Mun's stall off too",
				hint = "Mental Strength check. Syndicate bosses don't like being asked for favors in front of their people.",
				clash = { stat = "mind", foe = "A boss's pride", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = 4, mind = 2, log = "Bori looked at you for a long moment, then laughed. \"She gave me my first bowl of noodles,\" she said. \"Fine. The stall's off the books.\" Auntie Mun never found out why her fee stopped coming." },
				lose = { sanity = -2, log = "\"Business is business,\" Bori said, and the tea shop went quiet. She still let you off. Not the stall." },
			},
			{
				label = "Say you'd rather pay, like everyone else",
				result = { strength = 2, mind = 1, log = "\"Like everyone else,\" Bori repeated, amused. She took your money and slipped it back into your coat pocket on your way out. You found it at home with a note: STILL A TIN CAN." },
			},
		},
	},
	{
		id = "bs_a_bori_rat",
		title = "A Very Still Face",
		text = "There's a Rat pack working your street: older than most Rats, tired, and mean with it. The one giving orders is a thin woman with a very still face. Bori. Twenty years of the Backstreets have worn her down to wire. She sees you, and doesn't look away.",
		weight = 0,
		when = { flags = { "bs_bori_apart" } },
		codex = "bs_lore_rats",
		choices = {
			{
				label = "\"Hey. Want a job?\"",
				requires = { anyCareer = true },
				clash = { stat = "intelligence", foe = "Twenty years of bad habits", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, setFlags = { "bs_bori_saved_late" }, log = "You got her a trial shift where you work. She was terrible at it for a month and good at it for ten years. The pack scattered. She never said thank you." },
				lose = { sanity = -2, log = "She laughed, not unkindly. \"Look at you. A job.\" She took the pack two streets over the next week. You think it was for your sake." },
			},
			{
				label = "Give her some Ahn",
				requires = { min = { money = 100 } },
				result = { money = -100, sanity = 2, log = "You pressed a hundred Ahn into her hand. She looked at it like it was a trick. Then she put it away, and the pack left your street for good." },
			},
			{
				label = "\"Hey, Bun.\"",
				requires = { flags = { "bs_bori_bunfriend" } },
				result = { sanity = 4, relationBond = { kind = "friend", amount = 12 }, log = "Something in her face moved, for the first time in twenty years. \"Hey, Bun,\" she said. You sat on the bakery step together until well after two, and then she walked you home, the way she used to." },
			},
			{
				label = "Walk past, like last time",
				result = { sanity = -3, log = "She let you pass. That night someone left a stale bun on your step. You never found out whether it was a joke." },
			},
		},
	},

	-- ── Lotte ──────────────────────────────────────────────────────────────
	{
		id = "bs_y_lotte_scholarship",
		title = "Lotte's Scholarship",
		text = "Lotte is top of the class for the eighth year running, and the Nest has cut the scholarship program anyway: \"budget review.\" She has until the end of the month to pay full fees or go back to the Backstreets for good. She tells you this in the library, very calmly, folding the letter smaller and smaller.",
		weight = 0,
		when = { flags = { "bs_lotte_friend" }, maxAge = 18 },
		choices = {
			{
				label = "Pay her fees out of your savings",
				requires = { min = { money = 120 } },
				result = { money = -120, sanity = 4, setFlags = { "bs_lotte_stayed" }, schedule = { event = "bs_a_lotte_clerk", inYears = 13 }, log = "You paid. Lotte refused, argued, refused again, and then cried in the library stacks where nobody could see. She stayed. She paid you back, eventually, to the Ahn." },
			},
			{
				label = "Help her win the merit exam",
				hint = "Intelligence check: you'd be coaching the best student in the school.",
				clash = { stat = "intelligence", foe = "The merit exam", coins = 2, base = 3, coinPower = 2 },
				win = { intelligence = 3, sanity = 3, setFlags = { "bs_lotte_stayed" }, schedule = { event = "bs_a_lotte_clerk", inYears = 13 }, log = "You quizzed her every night for a month. She won the merit place by a single point, and you both claimed the point." },
				lose = { sanity = -3, setFlags = { "bs_lotte_left" }, schedule = { event = "bs_a_lotte_teacher", inYears = 13 }, log = "She came second. Second wasn't enough. You walked her to the checkpoint on her last day, and she didn't look back, because she'd decided not to." },
			},
			{
				label = "Promise to write",
				result = { sanity = -2, mind = 1, setFlags = { "bs_lotte_left" }, schedule = { event = "bs_a_lotte_teacher", inYears = 13 }, log = "You promised to write. You did, for a while. Her letters came back smelling of steam and noodles, full of things you'd never seen." },
			},
		},
	},
	{
		id = "bs_a_lotte_clerk",
		title = "A Friend at the Records Office",
		text = "Lotte is a Senior Clerk at the Nest Records Office now, the first person from the Backstreets anyone there can remember promoting. She asks you to tea, then asks you, very quietly, to help with something: a Backstreets family's residence papers that \"keep getting lost\" on the way up the chain.",
		weight = 0,
		when = { flags = { "bs_lotte_stayed" } },
		codex = "bs_lore_nests",
		choices = {
			{
				label = "Help her walk the papers through",
				clash = { stat = "mind", foe = "Nest bureaucracy", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, mind = 2, log = "You vouched, signed, waited and smiled at the right people. The family moved inside the wall that spring. Lotte sent you a card with a pressed flower from their new window box." },
				lose = { sanity = -3, money = { -40, -10 }, log = "The papers got lost again, with a fine attached this time. Lotte paid it. \"Next year,\" she said. She meant it." },
			},
			{
				label = "Warn her she's taking a risk",
				result = { mind = 2, log = "\"I know,\" said Lotte. \"Somebody took one for me.\" She looked at you over her teacup until you looked away." },
			},
		},
	},
	{
		id = "bs_a_lotte_teacher",
		title = "Lotte's Chalkboard",
		text = "A letter in familiar handwriting, smelling of steam: Lotte runs a little academy in the Backstreets now, two rooms above a laundry, for kids whose families can't pay. She needs chalk, books, and a new lock for the door. \"You still owe me a letter,\" she writes. \"I'll take Ahn instead.\"",
		weight = 0,
		when = { flags = { "bs_lotte_left" } },
		choices = {
			{
				label = "Send money for books and a lock",
				requires = { min = { money = 80 } },
				result = { money = -80, sanity = 5, log = "You sent the money with a long letter. She wrote back with a drawing from every student, including one of you as a giant with a bag of Ahn. It's on your wall." },
			},
			{
				label = "Visit, and teach a class yourself",
				result = { intelligence = 2, sanity = 4, log = "You crossed the checkpoint on a day pass and taught twelve kids long division in a room that smelled of soap. Lotte stood at the back with her arms folded, grinning." },
			},
			{
				label = "Write back, and only write",
				result = { sanity = 1, log = "You wrote back. A long letter, finally. She replied with one line: \"Took you long enough.\"" },
			},
		},
	},

	-- ── the boy at the gate ────────────────────────────────────────────────
	{
		id = "bs_a_wall_boy",
		title = "Did You Wave?",
		text = "The porter who carries crates through the Nest checkpoint stops beside you, a Backstreets man with a day pass and a crooked grin. \"This is strange,\" he says. \"But about twenty years ago, a little Nest kid waved at me through these bars. I stuck my tongue out. Was that you?\"",
		weight = 0,
		when = { flags = { "bs_waved_wall" } },
		choices = {
			{
				label = "\"It was. Were you home before three?\"",
				result = {
					sanity = 5,
					addRelation = { kind = "friend", name = "Sunwoo Jang", bond = 55, age = { 24, 28 } },
					log = "\"Every single night,\" said the porter, Sunwoo, and laughed so hard the guards looked over. You had tea at the gate on his breaks for years after that.",
				},
			},
			{
				label = "Tip him and walk on",
				result = { money = -10, mind = 1, log = "You gave him ten Ahn and walked on before he could see your face. You weren't sure why. You thought about it all day." },
			},
		},
	},

	-- ── Ottavio ────────────────────────────────────────────────────────────
	{
		id = "bs_y_ottavio_yard",
		title = "Ottavio's Yard",
		text = "Ottavio stops you outside his shuttered Office, leaning on his cane. \"You've been watching the Fixer gym through the window. Don't. They'll teach you how to get hurt.\" He unlocks the gate to the little yard behind the Office. \"I'll teach you how not to.\"",
		weight = 0,
		when = { side = "backstreets", flags = { "bs_ottavio_known" }, maxAge = 19 },
		choices = {
			{
				label = "Train with him",
				result = {
					strength = 2,
					health = 1,
					mastery = 1,
					setFlags = { "bs_ottavio_student" },
					addRelation = { kind = "mentor", name = "Ottavio", bond = 60, age = { 48, 52 } },
					schedule = { event = "bs_a_ottavio_debt", inYears = 12 },
					log = "Every evening for a year, in the yard behind the Office: footwork, breathing, how to fall, and how to get up again before three. He never once said you were good. He started leaving the gate unlocked for you.",
				},
			},
			{
				label = "Ask him to teach you the rules instead",
				result = {
					mind = 3,
					addTrait = "knows_the_fingers",
					setFlags = { "bs_ottavio_student" },
					addRelation = { kind = "mentor", name = "Ottavio", bond = 55, age = { 48, 52 } },
					schedule = { event = "bs_a_ottavio_debt", inYears = 12 },
					codex = "fingers_thumb",
					log = "\"Smart,\" he said. He taught you the Five Fingers the way other kids learn sums: how a Soldato bows to a Capo, what a Middle tattoo means, why you never read a slip of paper that isn't yours. You would need every word of it.",
				},
			},
			{
				label = "Thank him, and say no",
				result = { sanity = 1, log = "You said no. \"Good,\" said Ottavio, and seemed to mean it. \"Most Fixers I knew should have said no.\"" },
			},
		},
	},
	{
		id = "bs_a_ottavio_debt",
		title = "Ottavio's Debt",
		text = "Ottavio sends for you, which he has never done. He's sitting in his dark Office with a letter on the desk. He's behind on the lease, the landlord sold the debt to the local Syndicate, and the Syndicate is very polite about it. \"Three hundred Ahn,\" he says. \"I'm not asking. I'm telling you why I'm moving.\"",
		weight = 0,
		when = { flags = { "bs_ottavio_student" }, hasRelation = "mentor" },
		choices = {
			{
				label = "Pay what you can",
				requires = { min = { money = 150 } },
				result = { money = -150, sanity = 4, setFlags = { "bs_ottavio_helped" }, gear = "fixer_coat", log = "You paid half. He didn't argue, which told you how bad it was. A week later a parcel came: his old Fixer's coat, mended, with a note. \"It never got me killed. Keep the habit.\"" },
			},
			{
				label = "Go and talk to the Syndicate yourself",
				hint = "Charisma check. Knowing the Fingers' rules helps.",
				clash = { stat = "charisma", foe = "A Soldato with a ledger", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 4, charisma = 2, setFlags = { "bs_ottavio_helped" }, log = "You bowed, used every right title, and reminded the Soldato that Ottavio had once pulled his Capo out of a burning building. The debt was \"restructured.\" Ottavio pretended to be annoyed you'd interfered." },
				lose = { money = { -60, -20 }, sanity = -3, log = "You said the wrong honorific once. The debt went up by your mistake. Ottavio paid it, and moved anyway, and never mentioned it again." },
			},
			{
				label = "Help him pack",
				result = { health = 1, sanity = -2, log = "You carried forty years of his life down three flights of stairs. He gave away almost everything. He kept the cane and a photograph of an Office full of people you'd never met." },
			},
		},
	},

	-- ── Kasimir ────────────────────────────────────────────────────────────
	{
		id = "bs_a_kasimir_capo",
		title = "Capo Kasimir",
		text = "The Thumb's collectors work your street this month, and the Capo leading them is someone you know: Kasimir, from the academy, the boy you once knocked flat in the yard. He's in a pressed suit now, with two Soldati behind him. He sees you. Everyone on the street waits to see how you'll address him.",
		weight = 0,
		when = { side = "backstreets", flags = { "bs_kasimir_fought" } },
		codex = "fingers_thumb",
		choices = {
			{
				label = "Bow, and say \"Capo\"",
				result = { charisma = 2, sanity = 1, setFlags = { "bs_kasimir_respected" }, log = "\"Capo,\" you said, and bowed exactly as low as his rank deserved. Something in his face relaxed. His Soldati skipped your door that month. \"For old times,\" he said, which from the Thumb is practically a hug." },
			},
			{
				label = "Say \"Hello, Kasimir\"",
				hint = "In the Thumb, a name said without its title is an insult. Mental Strength check.",
				clash = { stat = "mind", foe = "Capo Kasimir's patience", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 3, log = "His Soldati went very still. Kasimir stared at you, then laughed once, short. \"Only you,\" he said, \"and only once.\" He let it go. Nobody on the street ever forgot it." },
				lose = { health = { -10, -5 }, money = { -60, -20 }, condition = "broken_arm", log = "The street went silent. Kasimir didn't touch you. His Soldati corrected you on his behalf, politely, thoroughly. He watched with his hands behind his back.", cause = "Corrected by the Thumb" },
			},
			{
				label = "Invite him in for tea",
				result = { sanity = 2, money = { -30, -10 }, log = "To everyone's surprise he came in, alone. You drank tea and didn't talk about the academy. When he left, the contribution was smaller than your neighbors'. He'd paid the difference himself." },
			},
		},
	},
	{
		id = "bs_a_kasimir_feather",
		title = "Inspector Kasimir",
		text = "The Wing's audit notice comes with a name on it you haven't seen since the academy: K. Vogt, Class 3 Audit Staff. Kasimir, the boy you beat at every sum. He's waiting in a gray office with your file open, and he looks like he has been waiting for twenty years.",
		weight = 0,
		when = { flags = { "bs_kasimir_outsmarted" }, minAge = 24 },
		codex = "bs_lore_feathers",
		choices = {
			{
				label = "Out-sum him one more time",
				clash = { stat = "intelligence", foe = "Kasimir's audit", coins = 2, base = 5, coinPower = 3 },
				win = { money = { 40, 100 }, intelligence = 2, log = "You went through his figures line by line and found his mistake: a refund the Wing owed you. He signed it with a face like a closed door. Then, at the door, he said, \"Still faster than me,\" and almost smiled." },
				lose = { money = { -120, -40 }, sanity = -3, log = "He'd been practicing for twenty years. He found everything. He fined you, precisely and fairly, and you have never hated anyone so politely." },
			},
			{
				label = "Apologize for the academy",
				result = { sanity = 3, charisma = 1, money = { -30, -10 }, log = "You said you'd been an unbearable kid. Kasimir blinked. \"So was I,\" he said, and the fine came out at the smallest number the rules allowed." },
			},
		},
	},
	{
		id = "bs_a_kasimir_friend",
		title = "The Head Teacher",
		text = "The old academy on the corner has a new Head Teacher: Kasimir, the rival who became your friend over a split lunch in the yard. Teacher Imre has retired, the roof leaks, and Kasimir has an idea. \"Teach one evening class a week,\" he says. \"Bookkeeping. Locks. Anything. The kids need to see someone from our street who turned out fine.\"",
		weight = 0,
		when = { flags = { "bs_kasimir_peace" } },
		choices = {
			{
				label = "Take the class",
				result = { intelligence = 2, sanity = 5, setFlags = { "bs_taught_evenings" }, log = "You taught one evening a week for years. Some of your students became Fixers, one became a Feather, two became Rats. You taught them all the same rule: home before three." },
			},
			{
				label = "Fix the roof instead",
				requires = { min = { money = 100 } },
				result = { money = -100, sanity = 3, log = "You paid for the roof. Kasimir put a little brass plate by the door with your name on it, which you found horribly embarrassing and checked on every time you passed." },
			},
			{
				label = "Say you're too busy",
				result = { mind = 1, sanity = -1, log = "\"Sure,\" said Kasimir. He asked again every year. You kept meaning to say yes." },
			},
		},
	},

	-- ── Tamas ──────────────────────────────────────────────────────────────
	{
		id = "bs_c_tamas_gone",
		title = "The Empty Room",
		text = "Tamas's family lived on the fourth floor. Yesterday, there were shoes outside their door. Today the door is gone. Not broken: gone, as if the wall had always been there. You ask the neighbors about the Tamas family. They look at you kindly and say they don't know anyone by that name. They mean it.",
		weight = 0,
		when = { flags = { "bs_tamas_filmed" } },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Keep the marble he gave you",
				result = { sanity = -4, mind = 2, setFlags = { "bs_remembers_tamas" }, log = "You kept the glass marble he'd given you for helping with his camera. Nobody else remembers him. You do. You have never told anyone that you do." },
			},
			{
				label = "Stop asking",
				result = { sanity = -2, log = "You stopped asking. After a while you weren't sure there had ever been a fourth-floor door. That frightened you more than anything else in your childhood." },
			},
		},
	},
	{
		id = "bs_a_tamas_photographer",
		title = "Tamas Takes Your Picture",
		text = "A photographer is set up on the corner with a big brass camera, taking portraits for a few Ahn. He looks up, and it's Tamas, the boy who once wanted to film the Night. He grins. \"You,\" he says. \"Sit down. This one's free. You know why.\"",
		weight = 0,
		when = { flags = { "bs_tamas_saved" } },
		choices = {
			{
				label = "Sit for the portrait",
				result = { sanity = 5, log = "He took your picture in the late afternoon light, and packed up his camera at one o'clock sharp, as he does every day. \"Never after two,\" he said. \"Never ever.\" The photograph hangs by your door." },
			},
			{
				label = "Ask if he ever thinks about that night",
				result = { mind = 2, sanity = 2, log = "\"Every night at three,\" said Tamas. \"I lie in bed and think about the film I didn't make, and I'm so glad I'm lying in bed.\"" },
			},
		},
	},

	-- ── the poster in the box ──────────────────────────────────────────────
	{
		id = "bs_a_poster_face",
		title = "The Face on the Poster",
		text = "An old man runs the shoe-repair stall at the market. You've walked past it a hundred times. Today you look properly, and your stomach drops: it's the face from the poster in your father's box, the boy-soldier from the Smoke War, fifty years older. He notices you staring. \"Ah,\" he says quietly. \"You've seen one of those posters.\"",
		weight = 0,
		when = { flags = { "bs_poster_face" } },
		codex = "bs_lore_smoke_war",
		choices = {
			{
				label = "Ask him what it was like",
				result = { mind = 2, sanity = -3, setFlags = { "bs_heard_the_war" }, log = "He told you, a little. They drafted him young. They gave him a uniform and a name for the poster that wasn't his. He came home to a City that wouldn't let him through any Nest gate. \"That's all,\" he said, and went back to the shoe." },
			},
			{
				label = "Tell him about your father",
				result = { sanity = 3, log = "You told him about the box with two locks, and the fly at the window. He nodded the whole time. \"Tell him a corporal from the old G Corp lines says the war's over,\" he said. \"Tell him it's allowed.\"" },
			},
			{
				label = "Get your shoes fixed and say nothing",
				result = { money = -5, sanity = 1, log = "You got your shoes fixed. He did a beautiful job and charged you half. Neither of you mentioned the poster again, and you went back every year." },
			},
		},
	},

	-- ── Marisol, the Fixer who walked you home ─────────────────────────────
	{
		id = "bs_y_marisol",
		title = "The Woman in the Gray Coat",
		text = "A Fixer is pinning a notice to the board outside the Office on your street: PORTER WANTED, ONE JOB, GOOD PAY, NO QUESTIONS. It's the woman in the gray coat who walked you home when you were lost as a little kid. She's Grade 5 now, by the badge. She looks at you, then looks again. \"You got taller,\" says Marisol. \"Want a job?\"",
		weight = 0,
		when = { flags = { "bs_met_marisol" }, minAge = 14, maxAge = 22 },
		codex = "fixers_hana",
		choices = {
			{
				label = "Carry her gear on the job",
				clash = { stat = "health", foe = "Six flights and a heavy case", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 40, 90 }, health = 2, setFlags = { "bs_porter_for_fixer" }, log = "You hauled her case up six flights and waited on the landing while the job happened behind a door. She paid you double. \"Fixers who start as porters,\" she said, \"know what everything weighs.\"" },
				lose = { wage = { 15, 30 }, condition = "bs_bad_back", log = "You hauled the case up six flights and your back gave out on the fifth. She carried you and the case down. \"Lesson one,\" she said. \"Know what you can lift.\"" },
			},
			{
				label = "Ask her how to get a license",
				result = { strength = 2, mind = 1, setFlags = { "bs_fixer_advice" }, log = "\"Pass Hana's exam, join an Office, and keep your contracts in writing,\" said Marisol. \"Everybody forgets the third one. The ones who forget it work for free.\"" },
			},
		},
	},

	-- ── the baby next door ─────────────────────────────────────────────────
	{
		id = "bs_a_neighbor_baby",
		title = "Express Delivery",
		text = "A young courier in a reflective jacket knocks at your door with a parcel you didn't order: a tin of the good tea. \"You won't remember me,\" she says. \"I was the baby next door. You ran for the doctor at half past two. My mother tells that story every single holiday.\"",
		weight = 0,
		when = { flags = { "bs_neighbor_grateful" } },
		choices = {
			{
				label = "Invite her in",
				result = { sanity = 5, addRelation = { kind = "friend", name = "Yeseul", bond = 60, age = { 17, 19 } }, log = "Yeseul stayed for tea and told you about her route. After that, every parcel you ever sent across the District arrived early and for free, and she would not hear a word about it." },
			},
			{
				label = "Tell her you were just fast",
				result = { sanity = 3, strength = 1, log = "\"You were,\" she said. \"Mother says you were the fastest kid on the street.\" She saluted with two fingers and was gone down the stairs before you could argue." },
			},
		},
	},

	-- ── graduation ─────────────────────────────────────────────────────────
	{
		id = "bs_y_graduation",
		title = "Graduation Day",
		text = "Ten years of chalk dust, and today the academy on the corner hands out certificates: a sheet of good paper each, signed by Teacher Imre in his shaky hand. The families squeeze into the biggest room. Imre asks if any graduate would like to say a few words.",
		weight = 0,
		when = { flags = { "bs_academy_enrolled" }, notFlags = { "bs_academy_grad" } },
		choices = {
			{
				label = "Give a speech",
				hint = "Mental Strength check, in front of everyone you know.",
				clash = { stat = "mind", foe = "A room full of your neighbors", coins = 1, base = 3, coinPower = 2 },
				win = { sanity = 5, setFlags = { "bs_academy_grad" }, addTrait = "bs_academy_graduate", log = "You talked about Teacher Imre's chalk, the leaky roof, and the walk home before three. People laughed in the right places and cried in one. Imre shook your hand for a long time." },
				lose = { sanity = 1, setFlags = { "bs_academy_grad" }, addTrait = "bs_academy_graduate", log = "You forgot every word and said \"Thank you, everyone, be home before three\" and sat down. It got the biggest applause of the day." },
			},
			{
				label = "Thank Teacher Imre quietly",
				result = { sanity = 3, mind = 1, setFlags = { "bs_academy_grad" }, addTrait = "bs_academy_graduate", log = "You found Imre afterward, wiping the boards, and thanked him. \"Don't thank me,\" he said. \"Use it.\" He gave you a book about the Smoke War and told you to read it carefully." },
			},
			{
				label = "Skip the ceremony and go to work",
				result = { wage = { 15, 30 }, setFlags = { "bs_academy_grad" }, addTrait = "bs_academy_graduate", log = "You worked a shift instead. Teacher Imre left your certificate under your door, rolled up and tied with string, and a note: \"Proud of you anyway.\"" },
			},
		},
	},
}
