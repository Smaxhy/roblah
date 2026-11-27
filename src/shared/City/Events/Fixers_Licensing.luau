--[[
	Becoming a Fixer: the childhood dream, unlicensed work, the Hana exam, and signing with an
	Office. Canon: docs/CANON.md 4.1 and 8.5 (Hana licenses; every Fixer belongs to an Office
	or an Association; a one-person Office counts).
	Office flags set here and used across the Fixer files:
		fx_office_hinge (Old Pell's Hinge Office), fx_office_brasshand (Brasshand Office),
		fx_office_own (your own one-person Office); fx_met_kasimir (Kasimir, who passed the same day; he becomes a rival later).
]]

local OFFICE_FLAGS = { "fx_office_hinge", "fx_office_brasshand", "fx_office_own" }

-- passing the exam: the license, the chronicle, and the Offices waiting outside
local function pass(log: string, extra: { [string]: any }?)
	local r = {
		setFlags = { "licensed_fixer", "fx_passed_exam" },
		sanity = 4,
		chronicle = "licensed_fixer",
		codex = "fx_lore_grades",
		trigger = "fx_exam_offers",
		log = log,
	}
	for k, v in extra or {} do
		r[k] = v
	end
	return r
end

local PELL = { kind = "mentor", name = "Pell Moraine", bond = 60, age = { 56, 64 } }

return {
	-- ── the dream ──
	{
		id = "fx_kid_coat",
		title = "Every Fixer's Dream",
		text = "A Fixer walks down your street in a long coat with a sword across her back, and the whole block goes quiet to let her pass. A Rat leaning on the noodle stall suddenly remembers somewhere else to lean. She buys a pork bun and pays exact change. You have never wanted to be anyone so badly.",
		weight = 14,
		once = true,
		tags = { "fixers" },
		when = { minAge = 7, maxAge = 13 },
		codex = "fx_lore_grades",
		choices = {
			{
				label = "Ask her what grade she is",
				result = { intelligence = 1, setFlags = { "fx_dream" }, log = "She laughed and said Grade 6, and that everybody starts at Grade 9. \"Learn the Taboos,\" she said. \"The exam always starts with the Taboos.\"" },
			},
			{
				label = "Follow her at a distance",
				clash = { stat = "mind", foe = "A Fixer who notices everything", coins = 1, base = 3, coinPower = 2 },
				win = { strength = 1, sanity = 2, setFlags = { "fx_dream" }, log = "You followed her three streets to a narrow Office with a hand-painted sign. She waved at you without turning around." },
				lose = { sanity = -1, setFlags = { "fx_dream" }, log = "She turned a corner and was gone. When you turned it, a Rat took your bun." },
			},
			{
				label = "Practice her walk all the way home",
				result = { strength = 2, sanity = 2, setFlags = { "fx_dream" }, log = "You practiced her walk all the way home. A neighbor asked if you'd hurt your leg." },
			},
		},
	},
	{
		id = "fx_unlicensed_offer",
		title = "No License Needed",
		text = "A man from a shabby outfit called Burrow Office offers you cash to watch a pawnshop door tonight. \"No license needed,\" he says, \"as long as nobody asks.\" Working as a Fixer without a Hana license is how plenty of Grade 9s started. It's also how some of them got caught, and never got a license at all.",
		weight = 10,
		cooldown = 5,
		tags = { "fixers", "backstreets" },
		when = { minAge = 14, maxAge = 30, side = "backstreets", notFlags = { "licensed_fixer" } },
		choices = {
			{
				label = "Take the job",
				hint = "Rats come for pawnshops at midnight.",
				clash = { stat = "strength", foe = "Pawnshop Rats", coins = 2, base = 3, coinPower = 2, fight = true, status = "bleed" },
				win = { wage = { 30, 60 }, strength = 1, setFlags = { "fx_unlicensed_work" }, codex = "fn_lore_rats", log = "Two Rats tried the pawnshop door at midnight. They tried somewhere else after that. The man paid in cash and forgot your name on purpose." },
				lose = { health = { -6, -2 }, wage = { 5, 15 }, setFlags = { "fx_unlicensed_work" }, log = "The Rats were quicker than you. The man paid you a little for the bruises and told you to keep quiet about where you got them.", cause = "Hurt on an unlicensed job" },
			},
			{
				label = "Wait for a real license",
				result = { mind = 2, sanity = 1, log = "You said no. He shrugged like he'd heard it before. The pawnshop was robbed that night anyway, by someone with fewer scruples." },
			},
			{
				label = "Ask him how licensing works",
				result = { intelligence = 2, setFlags = { "fx_dream" }, codex = "fx_lore_grades", log = "He laughed, then told you anyway: the exam hall, the fee, the practical bout. \"Don't cheat,\" he said. \"Hana always finds out.\"" },
			},
		},
	},

	-- ── the exam ──
	{
		id = "fx_exam_season",
		title = "Licensing Season",
		text = "Hana's posters are up on every lamppost: LICENSING EXAMS THIS MONTH. A written test, a practical bout, a fee of 25 Ahn. A line of hopefuls already curls around the old school hall, and Office Reps lean in doorways across the street, pretending not to watch it.",
		weight = 10,
		cooldown = 4,
		tags = { "fixers" },
		when = { minAge = 16, maxAge = 30, notFlags = { "licensed_fixer" } },
		codex = "fixers_hana",
		choices = {
			{
				label = "Join the line",
				hint = "25 Ahn",
				requires = { min = { money = 25 } },
				result = { money = -25, trigger = "fx_exam_hall", log = "You paid the fee and took a number. Number 212. The hall smelled of chalk and nerves." },
			},
			{
				label = "Study first, sit it next season",
				result = { intelligence = { 2, 3 }, mind = 1, setFlags = { "fx_dream" }, log = "You bought a secondhand primer and read it under a streetlight until the answers started to make sense." },
			},
			{
				label = "Hand out water to the line",
				result = { sanity = 3, log = "You handed out cups of water to strangers in the line. Three of them came back out licensed and waved their cards at you." },
			},
		},
	},
	{
		id = "fx_family_office",
		title = "The Family Office",
		text = "Your family's Office has a tradition for licensing season: the whole Office walks you to the exam hall. Somebody has polished the sign. Somebody else has written last year's answers inside your collar in tiny letters, which is cheating, and which everyone is very carefully not mentioning.",
		weight = 60,
		once = true,
		tags = { "fixers" },
		when = { minAge = 16, maxAge = 19, flags = { "fixer_blood" }, notFlags = { "licensed_fixer" } },
		choices = {
			{
				label = "Turn the collar inside out",
				result = { intelligence = 2, trigger = "fx_exam_hall", log = "You turned your collar inside out at the door of the hall. Someone at the back of the Office cheered." },
			},
			{
				label = "Keep the collar",
				result = { intelligence = 4, setFlags = { "fx_cheat_collar" }, trigger = "fx_exam_hall", log = "You kept the collar. It itched with guilt all morning." },
			},
			{
				label = "Say you don't want to be a Fixer",
				result = { sanity = -2, relationBond = { kind = "family", amount = -6 }, setFlags = { "fx_refused_family_office" }, log = "The walk home was very quiet. That night somebody re-hung the Office sign anyway, straighter than before." },
			},
		},
	},
	{
		id = "fx_exam_hall",
		title = "The Exam Hall",
		text = "The written test is forty questions long. Which Finger keeps a Book of Vengeance. What time the Sweepers rise. Which Taboo binds everyone during the Night. Then an examiner in a plain Hana coat calls numbers for the practical: one bout, inside a chalk circle, against her. You can feel your heartbeat in your teeth.",
		weight = 0,
		codex = "fixers_hana",
		choices = {
			{
				label = "Ace the written test",
				hint = "Intelligence check",
				clash = { stat = "intelligence", foe = "Forty questions", coins = 2, base = 4, coinPower = 3 },
				win = pass("You finished early and checked every answer twice. They printed your license while you watched: GRADE 9 FIXER, the lowest grade there is. You've never been prouder of anything."),
				lose = { sanity = -3, intelligence = 1, log = "You froze on the question about the Taboos and never thawed. The examiner said to come back next season." },
			},
			{
				label = "Win the practical bout",
				clash = { stat = "strength", foe = "A Hana examiner", coins = 2, base = 4, coinPower = 3, fight = true, status = "poise" },
				win = pass("You stayed inside the chalk circle and she didn't. The examiner shook your hand, and they printed your license while you caught your breath: GRADE 9 FIXER."),
				lose = { health = { -5, -2 }, sanity = -2, log = "The examiner put you on the floor three times, politely. \"Next season,\" she said, and helped you up." },
			},
			{
				label = "Slip the proctor an envelope",
				hint = "100 Ahn. Hana always finds out.",
				requires = { min = { money = 100 } },
				clash = { stat = "mind", foe = "An honest proctor", coins = 3, base = 5, coinPower = 3 },
				win = pass("The envelope vanished into a sleeve and your practical score appeared on the board. GRADE 9 FIXER, printed while you sweated.", {
					money = -100,
					setFlags = { "licensed_fixer", "fx_passed_exam", "fx_bought_license" },
					schedule = { event = "fx_hana_audit", inYears = 3 },
				}),
				lose = { money = -100, sanity = -4, setFlags = { "fx_exam_cheat_caught" }, log = "The proctor counted the envelope in front of everyone and wrote your number on a list. It was not a good list." },
			},
		},
	},
	{
		id = "fx_exam_offers",
		title = "Recruiters at the Door",
		text = "Outside the exam hall, the Office Reps stop pretending. Old Pell of Hinge Office, who runs two rooms above a noodle shop, offers you a desk and a fair cut. A man in a brass-buttoned coat from Brasshand Office offers more money and no questions. Behind them another new Grade 9, Kasimir, is loudly haggling over his signing fee.",
		weight = 0,
		codex = "fx_lore_offices",
		choices = {
			{
				label = "Sign with Hinge Office",
				result = { career = "fixer", setFlags = { "fx_office_hinge", "fx_met_kasimir" }, addRelation = PELL, log = "You shook Old Pell's hand. His Office smelled of broth and gun oil, and now it was yours too. Kasimir watched you sign and didn't look pleased." },
			},
			{
				label = "Sign with Brasshand Office",
				result = { career = "fixer", wage = { 30, 50 }, setFlags = { "fx_office_brasshand", "fx_met_kasimir" }, log = "Brasshand's Rep paid your signing fee in crisp notes and told you never to ask where the contracts came from. Kasimir had wanted that fee." },
			},
			{
				label = "Hang your own sign",
				hint = "150 Ahn for a back room and a sign",
				requires = { min = { money = 150 } },
				result = { career = "fixer", money = -150, setFlags = { "fx_office_own", "fx_met_kasimir" }, chronicle = "fx_office_founded", log = "You rented a back room, painted a sign that said {last} Office, and became the Rep of an Office of one. Kasimir called it a closet. It was a closet." },
			},
			{
				label = "Keep the license in your pocket",
				result = { sanity = 1, setFlags = { "fx_license_pocket" }, log = "You put the license in your coat and went home. It would keep, and so would the Offices." },
			},
		},
	},
	{
		id = "fx_office_placement",
		title = "Your Office",
		text = "Every licensed Fixer has to belong to an Office, and a Grade 9 doesn't get much say in which one. Two have a desk for you: Hinge Office, two rooms above a noodle shop where Old Pell writes the best job reports in the District, and Brasshand Office, loud, rich and fond of shortcuts. Or you could rent a back room and hang your own sign.",
		weight = 120,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", notFlags = OFFICE_FLAGS },
		codex = "fx_lore_offices",
		choices = {
			{
				label = "Hinge Office, above the noodle shop",
				result = { setFlags = { "fx_office_hinge", "fx_met_kasimir" }, addRelation = PELL, log = "Old Pell gave you the desk by the window and a stack of other people's job reports to read. Another new Grade 9, a sharp-elbowed boy named Kasimir, took the desk Pell had wanted to give you." },
			},
			{
				label = "Brasshand Office, the loud one",
				result = { wage = { 20, 40 }, setFlags = { "fx_office_brasshand", "fx_met_kasimir" }, log = "Brasshand paid a signing fee and handed you a brass pin. Kasimir, who signed the same week, wears his pin on the outside of his coat." },
			},
			{
				label = "A one-person Office of your own",
				hint = "150 Ahn",
				requires = { min = { money = 150 } },
				result = { money = -150, setFlags = { "fx_office_own" }, chronicle = "fx_office_founded", log = "You rented a back room and painted a sign: {last} Office. Rep, clerk, cleaner and the only Fixer on the payroll: you." },
			},
		},
	},
}
