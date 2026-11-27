--[[
	L Corp work orders, ZAYIN to HE: the daily job of an Agent (career lcorp_agent, rank 2+).
	Every card offers the four work types (CANON 5.3); the canon best work from CANON 5.9
	goes best. Results unlock the Abnormality's Archive entry, so the next time (or the
	next life) the player can read the file first. Bad work can trigger a breach
	(Events/LCorp_Breaches.luau). Good work with some units schedules an E.G.O offer.
	Ranks: 2 = Agent Level 1. ZAYIN and TETH from rank 2, HE from rank 3 (Level 2).
]]

local INSTINCT = "Instinct trains Health"
local INSIGHT = "Insight trains Mental Strength"
local ATTACHMENT = "Attachment trains Intelligence"
local REPRESSION = "Repression trains Strength"

local ZAYIN = { career = "lcorp_agent", minRank = 2, world = { era = "wings" } }
local TETH = { career = "lcorp_agent", minRank = 2, world = { era = "wings" } }
local HE = { career = "lcorp_agent", minRank = 3, world = { era = "wings" } }

return {
	-- ── ZAYIN ──
	{
		id = "lc_work_one_sin",
		title = "Work Order: One Sin and Hundreds of Good Deeds",
		text = "Your name comes up on the board beside a ZAYIN unit, O-03-03. Inside, a skull wearing a crown of thorns floats a little above the floor. It has no eyes, and it turns to face you anyway. The first line of its file says it has almost never hurt anyone. The second says it is always hungry.",
		weight = 25,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = ZAYIN,
		choices = {
			{
				label = "Instinct: dust the skull and check its restraints",
				hint = INSTINCT,
				result = { health = 1, sanity = -1, paycheck = 0.04, codex = "lc_abno_one_sin", log = "You dusted the crown of thorns while it watched you without eyes. The counter didn't move. Neither did it." },
			},
			{
				label = "Insight: tidy the unit and log its movements",
				hint = INSIGHT,
				result = { mind = { 1, 2 }, paycheck = 0.08, codex = "lc_abno_one_sin", log = "You logged every slow turn it made. A modest stack of PE-Boxes, and a tick in the Information Team's column." },
			},
			{
				label = "Attachment: kneel and confess something",
				hint = ATTACHMENT .. ". It listens.",
				result = {
					charisma = { 2, 3 },
					sanity = { 3, 5 },
					paycheck = 0.14,
					setFlags = { "lc_pe_one_sin" },
					codex = "lc_abno_one_sin",
					schedule = { event = "lc_ego_offer_penitence", inYears = 1 },
					log = "You knelt and told it about the lamp you broke when you were eight and blamed on the cat. Its teeth clicked softly. The PE-Boxes stacked up green, and you walked out lighter than you went in.",
				},
			},
			{
				label = "Repression: show it who's in charge",
				hint = REPRESSION,
				result = { strength = 1, sanity = { -5, -3 }, health = { -3, -1 }, codex = "lc_abno_one_sin", log = "You raised your riot stick at a floating skull. It looked at you with enormous disappointment, and something heavy sat on your chest for a week." },
			},
		},
	},
	{
		id = "lc_work_fairy_festival",
		title = "Work Order: Fairy Festival",
		text = "F-04-83 is a ZAYIN: a swarm of tiny winged fairies, chattering in a language nobody has cracked. They drift toward you as you come in, curious. Further down the same work schedule, after the fairies, is a TETH unit at the far end of the corridor. A note in the margin, in someone else's handwriting, says: do the fairies LAST.",
		weight = 25,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = ZAYIN,
		choices = {
			{
				label = "Instinct: feed them and tend their garden",
				hint = INSTINCT .. ". Then swap your shifts around.",
				result = {
					health = { 2, 3 },
					sanity = 2,
					paycheck = 0.12,
					condition = "lc_fairy_care",
					setFlags = { "lc_fairy_lesson" },
					codex = "lc_abno_fairy_festival",
					log = "You fed them sugar water and pruned their tiny garden, and they swirled around your head singing. You traded your TETH shift with a Clerk's blessing, and went home with the fairies humming in your ear.",
				},
			},
			{
				label = "Insight: clean the unit and count them",
				hint = INSIGHT,
				result = { mind = { 1, 2 }, paycheck = 0.06, codex = "lc_abno_fairy_festival", log = "You counted forty-one fairies, then forty, then forty-three. The Information Team said that was normal, and wrote it down anyway." },
			},
			{
				label = "Attachment: play with them, then head to the TETH unit",
				hint = ATTACHMENT .. ". Mind the note.",
				result = {
					charisma = 1,
					health = { -9, -5 },
					sanity = { -6, -4 },
					setFlags = { "lc_fairy_lesson", "saw_abnormality" },
					codex = "lc_abno_fairy_festival",
					log = "The fairies followed you into the TETH unit. They were very upset to find you there. You don't remember much after that, only the sound, and the Safety Team carrying you out.",
					cause = "The fairies' care",
				},
			},
			{
				label = "Repression: shoo them back into their garden",
				hint = REPRESSION,
				result = { strength = 1, health = { -4, -2 }, codex = "lc_abno_fairy_festival", log = "Forty-one fairies took offense at once. You came out covered in tiny bites, and none of them will look at you now." },
			},
		},
	},
	{
		id = "lc_work_wellcheers",
		title = "Work Order: Opened Can of WellCheers",
		text = "F-05-52 is a ZAYIN: a soda vending machine glowing neon in an otherwise dark unit, with cheerful music coming from somewhere inside it. Near the machine you can hear seagulls, which is impossible. The machine is talking about shrimp. A colleague told you on your first day never to accept a can that's already open.",
		weight = 25,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = ZAYIN,
		choices = {
			{
				label = "Instinct: restock it and wipe the glass",
				hint = INSTINCT,
				result = { health = { 1, 2 }, sanity = 2, paycheck = 0.12, codex = "lc_abno_wellcheers", log = "You restocked it and polished the glass until it shone. It dispensed a sealed can of grape soda for you. It was delicious. You checked the seal twice." },
			},
			{
				label = "Insight: tidy the unit and inspect its wiring",
				hint = INSIGHT,
				result = { mind = { 1, 2 }, paycheck = 0.1, codex = "lc_abno_wellcheers", log = "Its wiring went nowhere. It ran anyway. You noted it, tidied up, and got a modest stack of PE-Boxes." },
			},
			{
				label = "Attachment: chat with it about shrimp",
				hint = ATTACHMENT,
				result = { charisma = 1, sanity = { -3, -1 }, codex = "lc_abno_wellcheers", log = "It told you about shrimp for forty minutes. Boiled, fried, all of it. At the end it offered you an open can. You said no, very politely, and you heard seagulls all the way home." },
			},
			{
				label = "Repression: kick it until it stops talking",
				hint = REPRESSION,
				result = { strength = 1, health = { -3, -1 }, sanity = -2, codex = "lc_abno_wellcheers", log = "You kicked a vending machine in a containment unit. It played a sad little tune. A can rolled out and hit your foot very precisely." },
			},
		},
	},
	{
		id = "lc_work_plague_doctor",
		title = "Work Order: Plague Doctor",
		text = "O-01-45 is a ZAYIN. A tall figure in a black hat and a beaked mask stands in the middle of its unit, great black wings folded where its arms should be. \"You look tired,\" it says. \"Are you unwell? I can cure anything.\" Its file says it walked into the facility on its own.",
		weight = 22,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = ZAYIN,
		choices = {
			{
				label = "Instinct: check its feathers and bring it water",
				hint = INSTINCT .. ". It is not an animal.",
				result = { health = { -4, -2 }, sanity = { -4, -2 }, codex = "lc_abno_plague_doctor", log = "It let you check its feathers in absolute silence. When you finished, it said, \"I am not a bird,\" and you have never felt so thoroughly corrected." },
			},
			{
				label = "Insight: tidy the unit and take its notes",
				hint = INSIGHT,
				result = { mind = { 2, 3 }, paycheck = 0.1, codex = "lc_abno_plague_doctor", log = "It dictated a long list of the world's symptoms while you tidied. None of them were diseases you'd heard of. The PE-Boxes came out green and steady." },
			},
			{
				label = "Attachment: let it examine you",
				hint = ATTACHMENT .. ". It wants to help.",
				result = {
					charisma = { 1, 2 },
					health = { 6, 10 },
					sanity = 3,
					paycheck = 0.1,
					condition = "lc_blessed",
					setFlags = { "lc_blessed_once" },
					codex = "lc_abno_plague_doctor",
					schedule = { event = "lc_doctor_counting", inYears = 3 },
					log = "It laid a wing on your shoulder. Every ache you had went away. \"There,\" it said. \"You are blessed.\" Walking out, you could have sworn you heard it murmur a number.",
				},
			},
			{
				label = "Repression: keep it firmly in its corner",
				hint = REPRESSION,
				result = { strength = { 1, 2 }, paycheck = 0.08, codex = "lc_abno_plague_doctor", log = "You kept it in its corner by the book. It didn't object. It watched you go with what you'd swear was pity." },
			},
		},
	},
	{
		id = "lc_work_army_in_black",
		title = "Work Order: Army in Black",
		text = "D-01-106 is listed as a ZAYIN, with a red note under the grade. Inside, a cheerful little troop of soldiers in heart-shaped kit salutes you as one. \"Good morning! We are here to protect the hearts of the goodhearted,\" they say together. \"Is your heart good?\"",
		weight = 20,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = ZAYIN,
		choices = {
			{
				label = "Instinct: hand out their rations",
				hint = INSTINCT .. ". They are not hungry.",
				result = { health = { -6, -3 }, sanity = { -5, -3 }, codex = "lc_abno_army_in_black", log = "\"We do not need feeding,\" they said, all at once, very quietly. The room got colder. You backed out with the rations still in your arms." },
			},
			{
				label = "Insight: inspect their kit and quarters",
				hint = INSIGHT,
				result = { mind = 1, paycheck = 0.06, codex = "lc_abno_army_in_black", log = "Their kit was spotless. Their quarters were spotless. Their file said the same thing yours did in red, and you tried not to think about it." },
			},
			{
				label = "Attachment: answer their question honestly",
				hint = ATTACHMENT,
				result = { charisma = { 2, 3 }, sanity = { 2, 4 }, paycheck = 0.12, codex = "lc_abno_army_in_black", log = "You said you were trying to be good. They cheered. You talked about hearts for an hour, and the counter on the door ticked up and up." },
			},
			{
				label = "Repression: order them to stand down",
				hint = REPRESSION,
				result = { strength = 1, sanity = { -3, -1 }, paycheck = 0.04, codex = "lc_abno_army_in_black", log = "They stood down at once, and saluted. \"Understood. We will protect you anyway.\" That was somehow worse." },
			},
		},
	},

	-- ── TETH ──
	{
		id = "lc_work_punishing_bird",
		title = "Work Order: Punishing Bird",
		text = "O-02-56 is a TETH, and the smallest thing on the board: a round little bird in a big unit. It watches you very closely from its perch, the way a teacher watches the student who just lied. The file starts: \"Do not handle it.\" Somebody has underlined handle.",
		weight = 25,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = TETH,
		choices = {
			{
				label = "Instinct: scatter seed and fill its water",
				hint = INSTINCT,
				result = { health = { -5, -3 }, sanity = -2, paycheck = 0.04, codex = "lc_abno_punishing_bird", log = "It ate the seed and pecked your hand for your trouble, hard enough to hurt for a month. You still don't know what you did wrong." },
			},
			{
				label = "Insight: clean the unit without touching it",
				hint = INSIGHT .. ". Don't handle it.",
				result = { mind = { 2, 3 }, paycheck = 0.14, sanity = 1, codex = "lc_abno_punishing_bird", log = "You cleaned around it in a wide, careful circle. It watched every move and found nothing to punish. The PE-Boxes came out neat and green." },
			},
			{
				label = "Attachment: talk to it softly",
				hint = ATTACHMENT,
				result = { charisma = 1, sanity = { -3, -1 }, paycheck = 0.04, codex = "lc_abno_punishing_bird", log = "You told it about your day. It tilted its head at the part where you'd skipped lunch to finish a form late. It seemed to disapprove." },
			},
			{
				label = "Repression: shoo it off the perch",
				hint = REPRESSION,
				result = {
					strength = 1,
					health = { -4, -2 },
					sanity = -3,
					codex = "lc_abno_punishing_bird",
					chronicle = "lc_caused_breach",
					trigger = "lc_breach_punishing_bird",
					log = "You waved it off its perch. Its beak opened far wider than a bird that size has any right to, and the counter on the door went to zero.",
				},
			},
		},
	},
	{
		id = "lc_work_scorched_girl",
		title = "Work Order: Scorched Girl",
		text = "F-01-02 is a TETH. A small girl made of ash sits in the corner of her unit, holding one last match. The air around her shimmers. \"Will you stay?\" she asks. \"Everyone always leaves.\" The temperature reading on the door is climbing as you stand there.",
		weight = 25,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = TETH,
		choices = {
			{
				label = "Instinct: sweep up the ash and bring her water",
				hint = INSTINCT,
				result = { health = { -5, -2 }, condition = "burns", paycheck = 0.04, codex = "lc_abno_scorched_girl", log = "The water hissed into steam before it reached her. You swept up the ash with your sleeves smoking." },
			},
			{
				label = "Insight: keep the unit in order from a distance",
				hint = INSIGHT .. ". Distance is the point.",
				result = { mind = { 2, 3 }, paycheck = 0.14, codex = "lc_abno_scorched_girl", log = "You kept the vents clear and the floor clean, never closer than the yellow line. She watched you sadly. The counter held, and so did the PE-Boxes." },
			},
			{
				label = "Attachment: sit with her for a while",
				hint = ATTACHMENT .. ". She wants someone close.",
				result = {
					charisma = 1,
					health = { -6, -3 },
					sanity = -2,
					condition = "burns",
					codex = "lc_abno_scorched_girl",
					chronicle = "lc_caused_breach",
					trigger = "lc_breach_scorched_girl",
					log = "You sat beside her, and she burned brighter, and brighter, happier than you'd ever seen anything. Then she stood up, and walked out of the unit to find more people to be close to.",
				},
			},
			{
				label = "Repression: douse her with the hose",
				hint = REPRESSION,
				result = { strength = { 1, 2 }, sanity = { -4, -2 }, paycheck = 0.06, codex = "lc_abno_scorched_girl", log = "She didn't go out. She cried, and the steam filled the unit. You did your job, and you felt like the villain of a very old story." },
			},
		},
	},
	{
		id = "lc_work_old_lady",
		title = "Work Order: Old Lady",
		text = "O-01-12 is a TETH. An old woman sits in a rocking chair in the middle of her unit, rocking slowly. \"Oh, a visitor,\" she says. \"Nobody visits anymore. Sit down, dear, I'll tell you about the time the river froze.\" The unit is colder than the corridor, and getting colder.",
		weight = 25,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = TETH,
		choices = {
			{
				label = "Instinct: tidy her blanket and bring her tea",
				hint = INSTINCT,
				result = { health = 1, sanity = -1, paycheck = 0.06, codex = "lc_abno_old_lady", log = "She thanked you for the tea and didn't drink it. \"Stay a while,\" she said. You had other units. You left, and you felt her watching the door." },
			},
			{
				label = "Insight: clean the unit and check the chair",
				hint = INSIGHT,
				result = { mind = 1, sanity = -2, paycheck = 0.06, codex = "lc_abno_old_lady", log = "You cleaned around her while she talked to nobody. The chair was fine. The silence afterward was the worst part." },
			},
			{
				label = "Attachment: sit down and listen",
				hint = ATTACHMENT .. ". Ask her what happened next.",
				result = { charisma = { 2, 3 }, sanity = { 2, 4 }, paycheck = 0.15, codex = "lc_abno_old_lady", log = "The river froze, and a boy skated across it to bring her a ribbon, and that boy had been dead for sixty years. You asked what happened next until the shift bell rang. The unit was warm when you left." },
			},
			{
				label = "Repression: tell her to be quiet",
				hint = REPRESSION,
				result = { strength = 1, health = { -3, -1 }, sanity = { -7, -4 }, codex = "lc_abno_old_lady", log = "She went quiet. So did the corridor, and the floor, and you, for days. The loneliness followed you home like a draft under the door." },
			},
		},
	},
	{
		id = "lc_work_beauty_beast",
		title = "Work Order: Beauty and the Beast",
		text = "F-02-44 is a TETH: a huge shaggy beast lying across its unit, covered in eyes. All of them open when you enter. It makes a low sound that might be a plea. Its file is unusually firm: no tenderness, no hand-feeding, no lingering. Someone has written beside it, \"the curse moves.\"",
		weight = 25,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = TETH,
		choices = {
			{
				label = "Instinct: feed it by hand",
				hint = INSTINCT .. ". The file says not to.",
				result = { health = { -6, -3 }, sanity = { -6, -3 }, codex = "lc_abno_beauty_beast", log = "It ate from your hand, gently, and every one of its eyes looked at you with such hope. You dreamed of fur and roses for a month and woke up checking your hands." },
			},
			{
				label = "Insight: keep the unit in order",
				hint = INSIGHT,
				result = { mind = 1, paycheck = 0.06, codex = "lc_abno_beauty_beast", log = "You cleaned around it while its eyes followed you. It didn't move. The counter dipped, then settled." },
			},
			{
				label = "Attachment: tell it that it isn't a monster",
				hint = ATTACHMENT .. ". That's how the story goes.",
				result = { charisma = 1, health = { -7, -4 }, sanity = { -8, -5 }, condition = "lc_shaken", codex = "lc_abno_beauty_beast", log = "You said it, and every eye wept, and for a moment you felt the curse turn toward you like a head turning. The Safety Team pulled you out by your collar." },
			},
			{
				label = "Repression: work it firmly and leave",
				hint = REPRESSION .. ". Firm hands.",
				result = { strength = { 2, 3 }, paycheck = 0.14, codex = "lc_abno_beauty_beast", log = "You worked it by the book with a firm hand and didn't meet a single one of its eyes. It lay still. The PE-Boxes came out steady, and the curse stayed where it was." },
			},
		},
	},
	{
		id = "lc_work_void_dream",
		title = "Work Order: Void Dream",
		text = "T-02-99 is a TETH: a fluffy, drifting creature that floats around its unit with its eyes half shut. Just looking at it makes you yawn. The last Agent on this shift was found asleep standing up in the corridor, which the file describes as \"an acceptable outcome, this time.\"",
		weight = 25,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = TETH,
		choices = {
			{
				label = "Instinct: brush its fur and check its bedding",
				hint = INSTINCT,
				result = { health = 1, sanity = 1, paycheck = 0.05, codex = "lc_abno_void_dream", log = "You brushed it until it purred, and woke up an hour later on its bedding with no memory of lying down. The Control Team was not amused." },
			},
			{
				label = "Insight: tidy the unit, eyes on your watch",
				hint = INSIGHT,
				result = { mind = 1, paycheck = 0.06, codex = "lc_abno_void_dream", log = "You pinched your arm every thirty seconds and finished the cleaning awake. Barely." },
			},
			{
				label = "Attachment: hum it a lullaby",
				hint = ATTACHMENT,
				result = { charisma = { 2, 3 }, sanity = { 3, 5 }, paycheck = 0.14, codex = "lc_abno_void_dream", log = "It curled up in the air and slept, and the dreams it gave off were gentle ones. You walked out more rested than you'd been in a year." },
			},
			{
				label = "Repression: keep it awake by force",
				hint = REPRESSION,
				result = { strength = 1, sanity = { -6, -3 }, health = { -3, -1 }, codex = "lc_abno_void_dream", log = "It got grumpy. Then the whole corridor fell asleep at once, you included. You dreamed of an endless dark room for three nights after." },
			},
		},
	},
	{
		id = "lc_work_forsaken",
		title = "Work Order: Forsaken Murderer",
		text = "T-01-54 is a TETH. A man in a straitjacket is strapped to a chair in the middle of the unit, glaring at you through a forehead wound that never quite closes. \"Here to tighten the straps?\" he says. \"They always are.\" His file says risky trials were run on him before he came here.",
		weight = 22,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = TETH,
		choices = {
			{
				label = "Instinct: bring him water and a meal",
				hint = INSTINCT .. ". Just the basics.",
				result = { health = { 2, 3 }, paycheck = 0.14, codex = "lc_abno_forsaken", log = "You held the cup for him. He drank, and glared, and didn't say a word, which for him is gratitude. The counter held all day." },
			},
			{
				label = "Insight: clean the unit and log his condition",
				hint = INSIGHT,
				result = { mind = 1, sanity = -2, paycheck = 0.05, codex = "lc_abno_forsaken", log = "He watched you write in his file and laughed at every line. \"They wrote things about me too,\" he said. \"Look where it got them.\"" },
			},
			{
				label = "Attachment: ask him how he's feeling",
				hint = ATTACHMENT,
				result = { charisma = 1, sanity = { -4, -2 }, codex = "lc_abno_forsaken", log = "He told you, at length, in detail, how he felt about you, the company, and everyone in it. You stopped asking at the third minute." },
			},
			{
				label = "Repression: tighten the straps",
				hint = REPRESSION .. ". He hates it.",
				result = { strength = 1, health = { -8, -4 }, sanity = -3, codex = "lc_abno_forsaken", log = "You tightened the straps. He threw himself against them so hard the chair cracked, and so did you, against the wall. The Disciplinary Team finished the job.", cause = "Tightened the wrong straps" },
			},
		},
	},
	-- ── HE (Agent, Level 2 and up) ──
	{
		id = "lc_work_red_shoes",
		title = "Work Order: The Red Shoes",
		text = "O-04-08 is an HE: a pair of red shoes on a little velvet stand, under a single light. They are the most beautiful shoes you have ever seen. You notice you've taken a step toward them without meaning to. Your shoe size is, somehow, already printed on the work order.",
		weight = 28,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = HE,
		choices = {
			{
				label = "Instinct: polish them and air them out",
				hint = INSTINCT .. ". You'd have to pick them up.",
				result = { health = 1, sanity = { -5, -3 }, condition = "lc_shaken", codex = "lc_abno_red_shoes", log = "You held them for less than a minute. Your feet ached to be inside them for a month afterward. You polished your own boots very hard every night until it passed." },
			},
			{
				label = "Insight: dust the stand from a distance",
				hint = INSIGHT .. ". A Mental Strength check against their pull.",
				clash = { stat = "mind", foe = "The pull of the red shoes", coins = 2, base = 4, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_red_shoes", log = "You dusted the stand and never looked straight at them. The PE-Boxes came out fine. Your feet tapped all the way home." },
				lose = { sanity = { -6, -4 }, health = { -4, -2 }, codex = "lc_abno_red_shoes", log = "You looked. You were sitting on the floor with one boot unlaced when the Control Team's voice snapped you out of it." },
			},
			{
				label = "Attachment: tell them how beautiful they are",
				hint = ATTACHMENT .. ". Admire them; don't touch.",
				result = { charisma = { 2, 3 }, sanity = 1, paycheck = 0.18, codex = "lc_abno_red_shoes", log = "You told them they were the loveliest shoes in the City, which was true, and left them on the stand, which was hard. The counter climbed. The PE-Boxes came out a deep, happy green." },
			},
			{
				label = "Repression: lock them back in their case",
				hint = REPRESSION,
				result = {
					strength = 1,
					health = { -6, -3 },
					codex = "lc_abno_red_shoes",
					chronicle = "lc_caused_breach",
					trigger = "lc_breach_red_shoes",
					log = "You reached to lock the case. The shoes were not on the stand anymore. They were on someone's feet, and that someone was dancing down the corridor toward the elevators.",
				},
			},
		},
	},
	{
		id = "lc_work_snow_queen",
		title = "Work Order: The Snow Queen",
		text = "F-01-37 is an HE. Frost grows on the inside of the door. Beyond it, a queen of ice sits on a frozen throne, and behind the throne, half hidden, a boy is frozen in place with his eyes open. \"Clean if you must,\" she says, without looking at you. \"Quietly.\"",
		weight = 28,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = HE,
		choices = {
			{
				label = "Instinct: bring warm blankets for the boy",
				hint = INSTINCT .. ". A Health check against the cold.",
				clash = { stat = "health", foe = "The palace cold", coins = 2, base = 4, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.08, codex = "lc_abno_snow_queen", log = "You laid the blankets at the boy's feet. The queen watched and said nothing. You came out with frost in your eyebrows and the counter steady." },
				lose = { health = { -7, -4 }, sanity = -2, codex = "lc_abno_snow_queen", log = "Your fingers stopped working halfway across the room. You crawled back out. The blankets froze where you dropped them.", cause = "Frozen in the Snow Queen's palace" },
			},
			{
				label = "Insight: keep the unit clean and quiet",
				hint = INSIGHT .. ". Quietly, she said.",
				result = { mind = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_snow_queen", log = "You cleaned without a sound, every corner, every icicle in its place. When you finished, the queen said \"Good,\" and the PE-Boxes came out clear as ice." },
			},
			{
				label = "Attachment: ask her about the boy",
				hint = ATTACHMENT .. ". A Charisma check; she doesn't like being asked.",
				clash = { stat = "charisma", foe = "The Snow Queen's patience", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = { 2, 3 }, sanity = 2, paycheck = 0.1, codex = "lc_abno_snow_queen", log = "You asked so carefully that she answered. He came looking for someone, she said, and found winter instead. She didn't say who he came looking for." },
				lose = { sanity = { -6, -3 }, health = { -5, -3 }, codex = "lc_abno_snow_queen", log = "She turned to look at you for the first time. You couldn't feel your face for two days." },
			},
			{
				label = "Repression: chip the ice off the throne",
				hint = REPRESSION,
				result = { strength = 1, health = { -11, -6 }, sanity = { -5, -3 }, codex = "lc_abno_snow_queen", log = "You struck the throne once. The cold came down on you like a fist. The Safety Team thawed you out in a warm bath and wrote \"never Repression\" across her file in big letters.", cause = "Frozen in the Snow Queen's palace" },
			},
		},
	},
	{
		id = "lc_work_galaxy",
		title = "Work Order: Child of the Galaxy",
		text = "O-01-55 is an HE: a barefoot boy with enormous eyes and skin like the night sky, sitting cross-legged on the floor of his unit. He lights up when you come in. \"Are you going to play with me?\" he asks. \"The last one was nice. They had to go.\"",
		weight = 26,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = HE,
		choices = {
			{
				label = "Instinct: play tag with him",
				hint = INSTINCT .. ". A Health check; he's fast.",
				clash = { stat = "health", foe = "A very fast child", coins = 2, base = 3, coinPower = 3 },
				win = { health = { 2, 3 }, sanity = 2, paycheck = 0.12, codex = "lc_abno_galaxy", log = "You chased him around the unit until you were both out of breath and laughing. The PE-Boxes came out bright as stars." },
				lose = { health = -2, sanity = -1, codex = "lc_abno_galaxy", log = "You couldn't keep up, and he got bored, and the counter dipped. \"You're slow,\" he said, kindly." },
			},
			{
				label = "Insight: tidy his toys and tell him their names",
				hint = INSIGHT .. ". A Mental Strength check.",
				clash = { stat = "mind", foe = "An endless pile of toys", coins = 2, base = 3, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_galaxy", log = "You sorted his toys into constellations and named every one. He made you promise to come back and check they were still in order." },
				lose = { sanity = -2, codex = "lc_abno_galaxy", log = "The toys kept moving back. You think he was doing it. You think he thought it was a game." },
			},
			{
				label = "Attachment: sit with him and talk",
				hint = ATTACHMENT .. ". A Charisma check; he wants a friend.",
				clash = { stat = "charisma", foe = "A lonely child's trust", coins = 2, base = 3, coinPower = 3 },
				win = {
					charisma = { 2, 3 },
					sanity = 4,
					paycheck = 0.14,
					setFlags = { "lc_galaxy_pebble" },
					codex = "lc_abno_galaxy",
					schedule = { event = "lc_galaxy_pebble_due", inYears = 2 },
					log = "You talked until the shift bell. At the door he pressed a small, smooth pebble into your hand. \"Keep it forever,\" he said. \"Then we're friends.\" It's warm. It's always a little warm.",
				},
				lose = { sanity = -2, codex = "lc_abno_galaxy", log = "You tried, but your head was elsewhere, and he could tell. He went quiet and turned to the wall." },
			},
			{
				label = "Repression: tell him playtime is over",
				hint = REPRESSION .. ". A Strength check.",
				clash = { stat = "strength", foe = "A sulking child", coins = 2, base = 3, coinPower = 3 },
				win = { strength = { 2, 3 }, paycheck = 0.1, codex = "lc_abno_galaxy", log = "He sulked, but he went to his corner. You did the work. On the way out you felt like the worst babysitter in the City." },
				lose = { sanity = { -4, -2 }, codex = "lc_abno_galaxy", log = "He cried. Every light in the department flickered. Somebody's coffee froze in its cup." },
			},
		},
	},
	{
		id = "lc_work_teddy",
		title = "Work Order: Happy Teddy Bear",
		text = "T-04-06 is an HE: a big, soft, worn teddy bear sitting in the middle of a unit full of cushions. One of its seams is coming loose. Its stitched smile looks especially wide today. The Agent who worked it yesterday is still on the duty list. You are next. The file's warning is in bold: never the same Agent twice.",
		weight = 26,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = HE,
		choices = {
			{
				label = "Instinct: mend the loose seam",
				hint = INSTINCT .. ". You'd have to get very close.",
				result = { health = { -11, -6 }, sanity = -3, codex = "lc_abno_teddy", log = "You knelt to mend the seam and it hugged you, gently, and then not gently. The Safety Team pried you free with a crowbar and a great deal of shouting.", cause = "A hug that was far too tight" },
			},
			{
				label = "Insight: plump the cushions and tidy up",
				hint = INSIGHT .. ". A Mental Strength check; keep your distance.",
				clash = { stat = "mind", foe = "A bear that wants a hug", coins = 2, base = 4, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_teddy", log = "You tidied every cushion while staying exactly one long step out of reach. It held its arms out the whole time. You waved goodbye from the door." },
				lose = { health = { -6, -3 }, codex = "lc_abno_teddy", log = "You stepped half a pace too close. It got one arm around you before you wriggled free, minus a sleeve." },
			},
			{
				label = "Attachment: talk to it from a polite distance",
				hint = ATTACHMENT,
				result = { charisma = { 2, 3 }, sanity = 2, paycheck = 0.18, codex = "lc_abno_teddy", log = "You told it it was a very good bear from just outside arm's reach, and its smile softened. The counter climbed. The PE-Boxes came out soft and green." },
			},
			{
				label = "Repression: keep it back with the riot stick",
				hint = REPRESSION .. ". A Strength check.",
				clash = { stat = "strength", foe = "Happy Teddy Bear", coins = 2, base = 4, coinPower = 3 },
				win = { strength = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_teddy", log = "You kept the stick between you the whole time. It looked hurt. You did the work and backed out." },
				lose = { health = { -7, -4 }, sanity = -2, codex = "lc_abno_teddy", log = "It took the stick away from you very gently and kept it. You left without it, and without your dignity." },
			},
		},
	},
	{
		id = "lc_work_helper",
		title = "Work Order: All-Around Helper",
		text = "T-05-41 is an HE: a white housekeeping robot with red button eyes, standing very still in a spotless unit. \"Welcome,\" it says in a bright, factory-made voice. \"Is everything clean?\" The file has a list of things that make it decide something is dirty. The list is long.",
		weight = 26,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = HE,
		choices = {
			{
				label = "Instinct: oil its joints and charge its battery",
				hint = INSTINCT,
				result = { health = { 2, 3 }, paycheck = 0.16, codex = "lc_abno_helper", log = "You oiled every joint and plugged it in. It hummed. \"Thank you. Everything is clean.\" You have never been so relieved to hear a sentence." },
			},
			{
				label = "Insight: inspect its room for dirt",
				hint = INSIGHT .. ". Looking for dirt is the problem.",
				result = {
					mind = 1,
					health = { -5, -2 },
					codex = "lc_abno_helper",
					chronicle = "lc_caused_breach",
					trigger = "lc_breach_helper",
					log = "You ran a finger along the shelf to check for dust. Its eyes went from red to brighter red. \"Contamination detected,\" it said. \"Commencing cleaning.\" Its arms unfolded.",
				},
			},
			{
				label = "Attachment: compliment its housekeeping",
				hint = ATTACHMENT .. ". A Charisma check.",
				clash = { stat = "charisma", foe = "A robot's idea of praise", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = { 2, 3 }, paycheck = 0.1, codex = "lc_abno_helper", log = "You praised its corners and its shine. It thanked you and offered to cook you dinner. You said you'd eaten, which was a lie, and left quickly." },
				lose = { sanity = { -5, -3 }, health = -3, codex = "lc_abno_helper", log = "You said the room was clean \"enough\". It heard the word enough. You got out before it finished thinking about it." },
			},
			{
				label = "Repression: run its shutdown drill",
				hint = REPRESSION,
				result = { speed = { 2, 3 }, paycheck = 0.16, codex = "lc_abno_helper", log = "You ran the drill by the book: command, lock, standby. It stood perfectly still with its arms folded away. The PE-Boxes came out tidy." },
			},
		},
	},
	{
		id = "lc_work_butterflies",
		title = "Work Order: The Funeral of the Dead Butterflies",
		text = "T-01-68 is an HE. A tall mourner with a coffin for a body stands in a unit full of slow white butterflies. He bows his head as you come in, the way you bow at a funeral. \"Another one,\" he says softly, and you aren't sure whether he means you.",
		weight = 26,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = HE,
		choices = {
			{
				label = "Instinct: sweep the fallen wings from the floor",
				hint = INSTINCT .. ". A Health check.",
				clash = { stat = "health", foe = "A floor of white wings", coins = 2, base = 4, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.1, codex = "lc_abno_butterflies", log = "You swept up thousands of tiny white wings. He thanked you for tending the graves. The counter held." },
				lose = { sanity = { -5, -3 }, codex = "lc_abno_butterflies", log = "They kept falling as fast as you swept. By the end you were crying and couldn't say why." },
			},
			{
				label = "Insight: keep the unit in order, at a distance",
				hint = INSIGHT,
				result = {
					mind = { 2, 3 },
					paycheck = 0.18,
					setFlags = { "lc_pe_butterflies" },
					codex = "lc_abno_butterflies",
					schedule = { event = "lc_ego_offer_lament", inYears = 1 },
					log = "You tended his unit like a cemetery: quiet, orderly, respectful. He nodded once when you left. The PE-Boxes came out pale and steady, and the Extraction Team took note.",
				},
			},
			{
				label = "Attachment: try to comfort him",
				hint = ATTACHMENT .. ". He's the one doing the comforting here.",
				result = { charisma = 1, health = { -8, -4 }, sanity = { -8, -5 }, condition = "lc_shaken", codex = "lc_abno_butterflies", log = "You told him it would be all right. The butterflies turned toward you all at once, to comfort you back. The Safety Team found you lying very still among them, smiling.", cause = "Mourned by the butterflies" },
			},
			{
				label = "Repression: order him to keep still",
				hint = REPRESSION .. ". A Strength check.",
				clash = { stat = "strength", foe = "The mourner's grief", coins = 2, base = 4, coinPower = 3 },
				win = { strength = { 2, 3 }, paycheck = 0.1, codex = "lc_abno_butterflies", log = "He kept still. The butterflies didn't. You worked fast and didn't let one land on you." },
				lose = { health = { -5, -3 }, sanity = -3, codex = "lc_abno_butterflies", log = "He didn't move. The butterflies did. You came out with white dust in your hair that wouldn't wash out for a week." },
			},
		},
	},
	{
		id = "lc_work_schadenfreude",
		title = "Work Order: Schadenfreude",
		text = "O-05-76 is an HE: a squat box of gears that walks on its own, with a keyhole in its front. Behind the keyhole an eye blinks, and never closes. The Agent before you left a strip of thick black cloth on the hook by the door, with a note: \"Wear this. Trust me.\"",
		weight = 26,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = HE,
		choices = {
			{
				label = "Instinct: oil its gears, face to face",
				hint = INSTINCT .. ". You'd be standing right in front of the eye.",
				result = { health = { -11, -6 }, sanity = -4, codex = "lc_abno_schadenfreude", log = "You knelt in front of it with the oil can, and it saw you seeing it. It came at you so fast the camera footage is just a blur.", cause = "Seen by Schadenfreude" },
			},
			{
				label = "Insight: clean the unit blindfolded",
				hint = INSIGHT .. ". A Mental Strength check, by touch.",
				clash = { stat = "mind", foe = "Cleaning blind", coins = 2, base = 4, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_schadenfreude", log = "You cleaned the whole unit by touch with the cloth over your eyes. You could feel it staring the entire time. It didn't move." },
				lose = { health = { -6, -3 }, codex = "lc_abno_schadenfreude", log = "The cloth slipped. Just a little. Just enough." },
			},
			{
				label = "Attachment: talk to it with your eyes shut",
				hint = ATTACHMENT .. ". A Charisma check.",
				clash = { stat = "charisma", foe = "A box that hates being seen", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = { 2, 3 }, paycheck = 0.1, codex = "lc_abno_schadenfreude", log = "You told it you weren't looking, and you weren't, and it ticked and whirred like something listening. The counter went up." },
				lose = { sanity = { -5, -3 }, health = -3, codex = "lc_abno_schadenfreude", log = "You opened your eyes for half a second to find the door. Half a second was plenty." },
			},
			{
				label = "Repression: put on the blindfold and keep it in line",
				hint = REPRESSION .. ". Trust the note.",
				result = { strength = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_schadenfreude", log = "Blindfold on, riot stick out, every command by the book. It ticked furiously and stayed in its corner. You left the cloth on the hook for whoever came next, with your own note added." },
			},
		},
	},
	{
		id = "lc_work_freischutz",
		title = "Work Order: Der Freischütz",
		text = "F-01-69 is an HE: a marksman in a long old coat, sitting on a crate in his unit with a rifle across his knees, looking extremely bored. \"Come to buy a bullet?\" he asks. \"They never miss. Well. Almost never where you'd expect.\" He goes back to polishing the rifle.",
		weight = 24,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = HE,
		choices = {
			{
				label = "Instinct: bring him a meal",
				hint = INSTINCT .. ". A Health check.",
				clash = { stat = "health", foe = "A marksman's indifference", coins = 2, base = 4, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.08, codex = "lc_abno_freischutz", log = "He ate without looking up and said \"adequate.\" From him, that's a medal." },
				lose = { sanity = -3, codex = "lc_abno_freischutz", log = "He ignored the meal and you, completely, for the whole shift. The counter sagged out of sheer boredom." },
			},
			{
				label = "Insight: tidy the unit and keep your opinions to yourself",
				hint = INSIGHT,
				result = { mind = { 2, 3 }, paycheck = 0.16, codex = "lc_abno_freischutz", log = "You swept, filed and dusted without one word. He watched you with something close to respect. The PE-Boxes came out steady and green." },
			},
			{
				label = "Ask what a bullet costs",
				hint = ATTACHMENT .. ". He'll tell you.",
				result = { intelligence = 1, sanity = { -6, -3 }, codex = "lc_abno_freischutz", log = "He told you. Seven bullets: six go wherever you aim, and the seventh goes wherever he likes. He told you where he usually likes. You didn't buy one, and you didn't sleep that night." },
			},
			{
				label = "Repression: confiscate the rifle",
				hint = REPRESSION,
				result = { strength = 1, health = { -9, -5 }, sanity = -3, codex = "lc_abno_freischutz", log = "You reached for the rifle. Something hit the wall a centimeter from your ear, from a gun that was still across his knees. He hadn't moved. \"Don't,\" he said.", cause = "A magic bullet" },
			},
		},
	},
}
