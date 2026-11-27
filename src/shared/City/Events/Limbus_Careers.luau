--[[
	Working for Limbus Company: rank-specific stories for the LCCB, LCE and LCD.
	Writer D (lim_ ids). Careers: Careers/Limbus.luau. Canon notes: docs/CANON.md 7.1, 8.3.
	"Rank N only" = minRank N plus notFlags on the next rank's flag (rankFlags in the career).
]]

local ERA = { era = "limbus" }

return {
	-- ── LCCB, the Clearance Before Team ──
	{
		id = "lim_lccb_map_wrong",
		title = "The Map Says Empty",
		text = "Your first solo scouting job as a Preliminary Observer: a buried L Corp branch under a parking structure, marked EMPTY on the company map in someone's confident handwriting. Twenty meters down the access shaft, your lamp catches a containment door with its seal broken from the inside.",
		weight = 30,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lccb", notFlags = { "lim_lccb_r2" } },
		codex = "lim_departments",
		choices = {
			{
				label = "Go in and map it properly",
				hint = "Mental Strength check. Preliminary Observers die doing this.",
				clash = { stat = "mind", foe = "A dark containment wing", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.4, log = "You mapped the whole wing, marked three empty units and one that wasn't, and climbed out before whatever lived in it noticed you. Your report corrected the map in red. Your Assistant Manager read it twice and looked at you differently." },
				lose = { health = { -12, -5 }, sanity = -4, cause = "Lost scouting a buried branch", log = "Something in the dark noticed you first. You got out with your lamp and most of your nerve. The map still says EMPTY." },
			},
			{
				label = "Mark it UNSAFE and climb back out",
				result = { sanity = 1, mind = 1, log = "You wrote UNSAFE over EMPTY and climbed out. Your supervisor grumbled about lost time. A week later a Clearance Staff team went down with heavy gear, and came back with fewer people." },
			},
			{
				label = "Radio for a senior",
				result = { intelligence = 1, log = "You radioed up. A Senior Clearance Staff came down, looked at the door, said a word you've never heard a manager say, and walked you both out. \"Good call,\" she said. \"Most of you don't make it.\"" },
			},
		},
	},
	{
		id = "lim_lccb_kin_form",
		title = "Next of Kin",
		text = "Your onboarding packet for Preliminary Observation includes a form titled NEXT OF KIN (PRELIMINARY OBSERVATION) with a cheerful company logo and a box marked \"Preferred wording for the notification letter.\" The instructor tells the room it's a formality. Half the room is already writing.",
		weight = 20,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lccb", notFlags = { "lim_lccb_r2" } },
		choices = {
			{
				label = "Write the letter yourself",
				result = { mind = 2, sanity = -2, relationBond = { kind = "family", amount = 4 }, log = "You wrote it carefully, the way you'd want it read. Then you went home and said some of it out loud to your family instead, while you could." },
			},
			{
				label = "Write \"I'll be back\" in the box",
				result = { sanity = 3, strength = 1, log = "You wrote \"I'll be back\" and nothing else. The instructor read it, laughed, and said it was the third time this year. \"The other two were right,\" she added." },
			},
			{
				label = "Ask what happened to last year's class",
				result = { mind = 1, sanity = -3, codex = "lim_departments", log = "The instructor told you, honestly. Preliminary Observation is the cheapest, biggest section in the company for a reason. You looked around the room and started learning everyone's names." },
			},
		},
	},
	{
		id = "lim_lccb_logistics",
		title = "Crates Marked NOT A GOLDEN BOUGH",
		text = "You're running logistics for a dig site now. Your job is to get a sealed crate stenciled NOT A GOLDEN BOUGH from the branch to the company truck without anyone opening it, stealing it, or asking questions. A Workshop man at the fence offers you a year's wages for five minutes alone with the crate.",
		weight = 22,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lccb", minRank = 2 },
		codex = "lim_golden_boughs",
		choices = {
			{
				label = "Get it to the truck, by the book",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Three Districts of bad roads", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.5, setFlags = { "lim_bough_seen" }, log = "Two route changes, one checkpoint bribe you didn't pay, and a crate that glowed gold through its seams the whole way. It arrived sealed. You got a commendation and a headache." },
				lose = { sanity = -3, paycheck = -0.2, log = "The truck was late, the crate was fine, and the LCCA's After Team wrote you up for the delay. They wrote it in a tone." },
			},
			{
				label = "Take the Workshop man's offer",
				result = { money = { 600, 1200 }, sanity = -6, setFlags = { "lim_bough_seen", "lim_sold_a_peek" }, log = "Five minutes. He opened it, looked inside, closed it, and walked away with tears running down his face. He didn't take anything. You've never found out what he saw, and you think about it every night." },
			},
			{
				label = "Report the offer to security",
				result = { mind = 2, paycheck = 0.3, log = "Company security took him away, politely. Your supervisor added a line to your file: RELIABLE. It's the only adjective in it." },
			},
		},
	},
	{
		id = "lim_lccb_sweep",
		title = "Clearing the Corridor",
		text = "You lead a Clearance Staff team now. The corridor ahead is full of Peccatula: branch-like things with cracks of red light, Class 1 and 2, growing up through the old L Corp floor tiles. The bus arrives in two days. The corridor has to be clear by then.",
		weight = 22,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lccb", minRank = 3 },
		codex = "lim_peccatula",
		choices = {
			{
				label = "Lead from the front",
				clash = { stat = "strength", foe = "A corridor of Peccatula", coins = 3, base = 5, coinPower = 3, fight = true, status = "rupture" },
				win = { strength = 2, paycheck = 0.5, chronicle = "lim_peccatula_cleared", log = "You went first through every doorway, and your team came out of the corridor with all of its people. The red cracks went dark one after another behind you." },
				lose = { health = { -14, -6 }, sanity = -3, cause = "Lost clearing a corridor for the bus", log = "One of them was a Class 3 in the dark. Your team pulled you out and finished the job without you." },
			},
			{
				label = "Plan it room by room",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A corridor of Peccatula", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.4, chronicle = "lim_peccatula_cleared", log = "You mapped where they grew thickest and cut them off from the vents first. It took longer and nobody got hurt. Your team bought you a coffee you didn't have to share." },
				lose = { sanity = -4, log = "Your plan was good. The corridor didn't read it. You finished a day late and the LCCA's After Team made sure everyone knew." },
			},
		},
	},
	{
		id = "lim_lccb_ledger",
		title = "The Casualty Ledger",
		text = "As an Assistant Manager you keep the casualty ledger. This month, one of your Preliminary Observers, a quiet boy named Leon who always brought snacks for the night shift, went down into a branch and didn't come back up. The form for his family is on your desk. The company provides the wording.",
		weight = 25,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lccb", minRank = 4 },
		choices = {
			{
				label = "Go down and look for him",
				hint = "Health check. Managers aren't supposed to.",
				clash = { stat = "health", foe = "The branch that took him", coins = 3, base = 5, coinPower = 3 },
				win = { health = -4, sanity = 6, addRelation = { kind = "friend", name = "Leon Moreau", bond = 70, age = { 19, 23 } }, log = "You found him three levels down, behind a door that had sealed itself, out of water and very nearly out of hope. You carried him out. He still brings snacks for the night shift, and now he brings you some too." },
				lose = { health = { -14, -6 }, sanity = -6, cause = "Went down after a lost Preliminary Observer", log = "You went as far as anyone could. He wasn't there. You came back up alone and signed the form." },
			},
			{
				label = "Write to his family yourself",
				result = { mind = 2, sanity = -3, log = "You threw away the company wording and wrote three pages about the snacks, and the night shift, and how he laughed. His mother wrote back. You keep her letter in the ledger." },
			},
			{
				label = "Sign the form with the company wording",
				result = { paycheck = 0.3, sanity = -5, log = "You signed it. \"We regret to inform you.\" You signed eleven more that year. You stopped learning their names after the sixth, and then you hated yourself for it." },
			},
		},
	},
	{
		id = "lim_lccb_before_the_bus",
		title = "Before the Bus",
		text = "As LCCB Manager, you've had the branch cleared and mapped for a week. Tomorrow the bus arrives. Tonight an LCA special operations team turns up with new orders that undo half your work, and the LCCA's After Team is already complaining about the mess you'll leave them. Then an inspector from head office steps off the first transport with a clipboard, and asks for the person in charge.",
		weight = 30,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lccb", flags = { "lim_lccb_manager" } },
		codex = "lim_lcb",
		choices = {
			{
				label = "Defend your plan to the LCA",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "An LCA Team Leader", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.5, chronicle = "lim_lccb_manager", log = "You walked the LCA through every room. They backed down, which they never do. Inspector Maelys listened from the doorway without a word, and as she left she said, \"Adequate,\" which her driver later told you is the nicest thing she says." },
				lose = { sanity = -4, chronicle = "lim_lccb_manager", log = "The LCA overruled you. Inspector Maelys watched the whole argument with no expression at all. The next day the bus went in by your route anyway. Nobody said why." },
			},
			{
				label = "Hand the inspector your maps and get out of the way",
				result = { sanity = 2, chronicle = "lim_lccb_manager", codex = "lim_lcb", log = "Inspector Maelys took the maps, read them in the time it takes to breathe, and nodded once. \"Not your department,\" she said, when you asked what they were looking for. Two days later the bus left with a crate that glowed. You never saw who carried it aboard." },
			},
		},
	},
	{
		id = "lim_lccb_after_team",
		title = "The After Team",
		text = "The LCCA, the Clearance After Team, arrives to clean up after a dig you scouted. They wear better uniforms, earn more, and look at your muddy Before Team boots like something they'd scrape off theirs. Their lead hands you a list of everything you did wrong. It's long, and some of it is true.",
		weight = 16,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lccb" },
		codex = "lim_departments",
		choices = {
			{
				label = "Go through the list point by point",
				result = { intelligence = 2, sanity = -1, log = "You fixed the true parts and argued the rest. By the end the After Team lead was grudgingly calling you by your name instead of your section." },
			},
			{
				label = "Ask them to come down first next time",
				result = { strength = 1, sanity = 2, log = "\"Next time, you scout it.\" The silence was beautiful. Your whole section bought you noodles." },
			},
		},
	},

	-- ── LCE, the Enkephalin department ──
	{
		id = "lim_lce_sample",
		title = "Sample Jar Seven",
		text = "As a Lab Assistant you clean the specimen room. Jar Seven holds a Peccatulum cutting, Class 1, labeled IRAE in old-fashioned handwriting. It has never moved. Tonight, while you're wiping the glass, its red crack brightens, and it turns slowly toward you.",
		weight = 25,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lce", notFlags = { "lim_lce_r2" } },
		codex = "lim_peccatula",
		choices = {
			{
				label = "Write down exactly what it does",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A Peccatulum that has noticed you", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.4, log = "You logged every twitch for an hour. It only moved when you were angry about something. Your note became a footnote in a senior paper, credited to \"a Lab Assistant\". You know which one." },
				lose = { sanity = -5, condition = "night_terrors", log = "You wrote until your hand shook. It kept turning to face you, wherever you stood. You asked to be moved off nights." },
			},
			{
				label = "Call a researcher",
				result = { mind = 1, log = "The researcher came, looked at the jar, looked at you, and asked if you'd had a bad day. You had. \"That's what it eats,\" she said, and moved the jar to a room with no windows." },
			},
		},
	},
	{
		id = "lim_lce_gear_test",
		title = "Attunement Test",
		text = "You're on the E.G.O gear trials: a coat drawn from an Abnormality's core, with the LCE's Attunement Boost switched on. Each minute it fits better and hits harder. Each minute you think a little more in its words. The protocol says stop at Level 3. The dial goes to 7.",
		weight = 25,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lce", minRank = 2 },
		codex = "lim_attunement",
		choices = {
			{
				label = "Stop at Level 3",
				result = { intelligence = 2, paycheck = 0.3, log = "You stopped exactly at Level 3 and wrote it up. Your supervisor was disappointed and relieved in equal measure. The coat hummed for a while after you took it off, as if it were sulking." },
			},
			{
				label = "Push it to Level 5",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The coat's voice", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.6, gear = "lim_ego_coat", log = "At Level 5 you heard it clearly and didn't answer. Your data rewrote the safety tables, the lab let you keep a test coat, and a memo came down from head office asking how you'd done it." },
				lose = { sanity = -6, condition = "lim_attunement_strain", log = "At Level 5 you answered it. They pulled the coat off you mid-sentence, a sentence in a voice that wasn't yours." },
			},
			{
				label = "Fake the readings and go home",
				result = { sanity = 2, money = 40, setFlags = { "lim_faked_trial" }, log = "You wrote down numbers that looked right and went home early. Somewhere a safety table is wrong now, and it's your fault. You try not to think about who'll wear that coat next." },
			},
		},
	},
	{
		id = "lim_lce_regrade",
		title = "HE-5 or WAW-4?",
		text = "The LCE is re-grading an Abnormality recovered from a buried branch. L Corp called it HE. Limbus Company adds a number for the damage to expect in a fight, and your senior wants it graded HE-3 so it can go into the cheap storage wing. Your notes say HE-5, at least.",
		weight = 20,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lce", minRank = 2 },
		codex = "lim_risk_regrade",
		choices = {
			{
				label = "File it as HE-5",
				result = { mind = 2, sanity = 1, log = "You filed it as HE-5. Your senior didn't speak to you for a month. Then the cheap storage wing had a containment incident with something else entirely, and he brought you a coffee and said nothing about it." },
			},
			{
				label = "File it as HE-3, as asked",
				result = { paycheck = 0.4, sanity = -4, log = "You filed it as HE-3. It went into the cheap wing. Every time the sirens test, you hold your breath." },
			},
			{
				label = "Prove it on the test floor",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "An unhappy HE-class Abnormality", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 3, paycheck = 0.5, log = "You ran the containment trial yourself and the numbers spoke for you: HE-5, and a careful one. Your grade stood. So did you, which some people on that floor hadn't expected." },
				lose = { health = { -8, -3 }, sanity = -4, log = "The trial proved your point, loudly, all over the test floor. Nobody argued with the HE-5 after that. Nobody argued with your medical leave either." },
			},
		},
	},
	{
		id = "lim_lce_distortion_study",
		title = "Inflection Data",
		text = "The LCE holds a captured Distortion in a sealed observation room: a former schoolteacher who became something like a blackboard that writes by itself. Chief Researcher Hohenheim wants its Inflection Point recreated in controlled conditions, to see if Distortion can be predicted. The proposal is on your desk, waiting for a Senior Researcher's signature.",
		weight = 22,
		once = true,
		tags = { "limbus", "distortion" },
		when = { world = ERA, career = "limbus_lce", minRank = 3 },
		codex = "lim_inflection_point",
		choices = {
			{
				label = "Sign it",
				result = { paycheck = 0.6, sanity = -5, setFlags = { "lim_signed_hohenheim" }, log = "You signed it. The data was extraordinary. You were invited to present it at Headquarters. On the train home you kept thinking about the blackboard, which had written one word, over and over, the whole time: why." },
			},
			{
				label = "Rewrite it to study without recreating",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Chief Researcher Hohenheim's patience", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 3, sanity = 3, paycheck = 0.4, log = "Your rewrite got the same answers without putting the teacher through it again. Hohenheim read it, said \"Slower,\" and approved it anyway. Halfway through the study, the blackboard wrote a lesson plan." },
				lose = { sanity = -3, log = "Hohenheim rejected the rewrite in one line and gave the study to a researcher who would sign. You were moved to inventory for a year." },
			},
			{
				label = "Ask to talk to it first",
				result = { charisma = 3, sanity = -1, log = "They let you in for ten minutes. You asked the blackboard what it used to teach. It wrote, very slowly, a child's name. You went out and found the child, grown up, and asked them to visit. The study never happened. Nobody ever told you why." },
			},
		},
	},
	{
		id = "lim_lce_sapling",
		title = "Hohenheim's Request",
		text = "Chief Researcher Hohenheim calls you, a Lead Researcher, to a room you didn't know existed. Through the glass, something young and growing glows gold: Golden Boughs, grafted one onto another, into a single sapling. \"You'll be reporting on its growth,\" he says. \"To me. Only to me.\"",
		weight = 30,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, career = "limbus_lce", minRank = 4 },
		codex = "lim_sapling",
		choices = {
			{
				label = "Accept the assignment",
				result = { paycheck = 0.8, sanity = -4, setFlags = { "lim_bough_seen" }, addTrait = "lim_gold_eyes", log = "You measured it every morning for a year. Some mornings it had grown. Some mornings it had grown toward you. Your reports went to Hohenheim and nowhere else, and you started dreaming in gold." },
			},
			{
				label = "Ask what it's for",
				result = { mind = 2, setFlags = { "lim_bough_seen" }, log = "\"That isn't your department,\" Hohenheim said, quite pleasantly. \"It isn't mine either.\" He gave the assignment to someone else. You were never asked into that room again, and you were glad." },
			},
		},
	},

	-- ── LCD, the Distortion department ──
	{
		id = "lim_lcd_hotline",
		title = "Line Four",
		text = "As an LCD Case Clerk you answer Line Four, the public hotline. A woman says her father has been talking to the radiator. A man says his shadow left the room before he did. A child asks if Distortions can hear you through the phone. Your supervisor wants every call triaged in under two minutes.",
		weight = 25,
		once = true,
		tags = { "limbus", "distortion" },
		when = { world = ERA, career = "lim_lcd", notFlags = { "lim_lcd_r2" } },
		codex = "lim_distortion_stages",
		choices = {
			{
				label = "Triage by the stages, fast and exact",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Two hundred calls", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.4, log = "Incubation, Early, nothing, nothing, Early, Middle: send someone now. You caught a Middle stage in the first week that turned out to be one hour from Late. Your supervisor started routing the hard calls to you." },
				lose = { sanity = -4, log = "You sent a team to a radiator and nobody to the shadow. You heard about the shadow on the news." },
			},
			{
				label = "Take the child's call properly",
				result = { sanity = 4, mind = 1, log = "You told the child that Distortions can't hear through phones, and then you asked why they wanted to know. It was their big brother. You stayed on the line for forty minutes and sent a counselor, not a team. Your supervisor docked you for the time and didn't mean it." },
			},
		},
	},
	{
		id = "lim_lcd_inflection",
		title = "Find the Moment",
		text = "A Middle-stage case: a delivery driver whose van has started driving itself, always to the same address. His family is in the kitchen, terrified, and you have a notebook and maybe a day. Somewhere in his last year is the moment it tipped. The Inflection Point. Find it and you might end this without a fight.",
		weight = 25,
		once = true,
		tags = { "limbus", "distortion" },
		when = { world = ERA, career = "lim_lcd", minRank = 2 },
		codex = "lim_inflection_point",
		choices = {
			{
				label = "Interview everyone who knew him",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A Middle-stage Distortion", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.5, sanity = 4, setFlags = { "lim_distortion_survivor", "lim_talked_down" }, addTrait = "lim_talks_them_down", chronicle = "lim_talked_down", log = "The address was his old house, sold after his father died, the day he wasn't there to say goodbye. You drove him there. He sat in the van outside it and cried for an hour. When he got out, he was just a man again." },
				lose = { sanity = -5, log = "You ran out of day. The case went Late and the suppression team took over. In the report, your notes are on page three, under a heading that says INSUFFICIENT." },
			},
			{
				label = "Follow the van",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A van with no driver", coins = 2, base = 5, coinPower = 3 },
				win = { strength = 2, paycheck = 0.4, setFlags = { "lim_distortion_survivor" }, chronicle = "calmed_distortion", log = "You kept up with it across two Districts, to a house that had been sold years ago. You knocked. The new owners let him in for an hour. The van never drove itself again." },
				lose = { health = { -8, -3 }, sanity = -3, log = "The van lost you in the Backstreets, which is what the Backstreets are for. The suppression team found it at dawn." },
			},
		},
	},
	{
		id = "lim_lcd_moses",
		title = "Team Leader Moses",
		text = "The OSIR Team Leader, Moses, sends for you. He's precise, unhurried, and has a way of looking at a case file as if it were a conversation. He slides one across the desk: a whole street of people dreaming the same dream. \"Everyone else has looked at the dreamers,\" he says. \"Look at the street.\"",
		weight = 25,
		once = true,
		tags = { "limbus", "distortion" },
		when = { world = ERA, career = "lim_lcd", minRank = 3 },
		codex = "lim_inflection_point",
		choices = {
			{
				label = "Walk the street at night",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A street that dreams", coins = 3, base = 6, coinPower = 3 },
				win = { mind = 3, paycheck = 0.6, setFlags = { "lim_talked_down" }, chronicle = "lim_talked_down", log = "At 3:12, one minute before the Night, every window on the street lit up at once, pointed at an empty lot where a night shelter used to be. The shelter's old keeper was sleeping in a doorway three streets over. You brought her home. The dream stopped. Moses read your report and said, \"Good. Again.\"" },
				lose = { sanity = -6, condition = "night_terrors", log = "You walked the street until you were dreaming it too. Moses solved it himself the following week, and kindly never mentioned that you'd been one of the dreamers." },
			},
			{
				label = "Read every old record of the street",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Forty years of records", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 3, paycheck = 0.5, log = "In the records was a night shelter, closed the winter before the dreams began. You found the keeper and the funding, in that order. Moses signed off with one line: \"You looked at the street.\"" },
				lose = { sanity = -3, log = "The records were missing exactly the years you needed. Someone had removed them, carefully. Moses didn't seem surprised." },
			},
		},
	},
	{
		id = "lim_lcd_director",
		title = "Talk First, or Suppress First?",
		text = "As Case Director you set the policy for every LCD team in the region. Suppress-first closes cases faster and costs fewer staff. Talk-first saves more of the people inside the Distortions, sometimes, and costs more staff, sometimes. The board wants a number. The OSIR Team wants an answer.",
		weight = 30,
		once = true,
		tags = { "limbus", "distortion" },
		when = { world = ERA, career = "lim_lcd", flags = { "lim_lcd_director" } },
		choices = {
			{
				label = "Talk first, always",
				result = { sanity = 5, paycheck = 0.3, addTrait = "lim_talks_them_down", log = "You wrote the policy yourself: every case gets an investigator before it gets a weapon. The board hated it. In the first year, eleven people came back who wouldn't have. You keep their names on your wall." },
			},
			{
				label = "Suppress first, and fund the investigators anyway",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "The board's budget", coins = 3, base = 6, coinPower = 3 },
				win = { intelligence = 3, paycheck = 0.8, log = "You gave the board its fast numbers and hid the OSIR funding inside them. Both sides think you're on theirs. That's what directing turns out to be." },
				lose = { sanity = -5, paycheck = 0.4, log = "The board took the fast numbers and cut the funding. You signed the order. Your investigators stopped saying good morning." },
			},
		},
	},

	-- ── hiring: how a life finds its way into Limbus Company ──
	{
		id = "lim_lccb_offer",
		title = "Always Hiring",
		text = "A card arrives with a Limbus Company logo and muddy thumbprints on it. LIMBUS COMPANY, CLEARANCE BEFORE TEAM. PRELIMINARY OBSERVATION. ALWAYS HIRING. On the back, in pencil: \"You kept your head near a buried branch. We need that. Lowest pay in the company, I won't lie. - B.\"",
		weight = 0,
		when = { world = ERA, minAge = 18 },
		codex = "lim_departments",
		choices = {
			{
				label = "Join the Before Team",
				hint = "Your current job ends.",
				requires = { min = { health = 30, mind = 25 } },
				result = { career = "limbus_lccb", log = "You signed on as a Preliminary Observer. They gave you a lamp, a map that was probably wrong, and a form titled NEXT OF KIN." },
			},
			{
				label = "Keep the card, just in case",
				result = { mind = 1, log = "You put the card in your wallet behind your residence papers. Some nights you take it out and read the back again." },
			},
			{
				label = "Ask what happened to the last Preliminary Observer on your street",
				result = { sanity = -2, mind = 2, log = "B. wrote back the same week, honestly: he'd made Clearance Staff, then Senior, then retired to a Nest. \"The other three didn't,\" the letter added. You respected that." },
			},
		},
	},
	{
		id = "lim_lcd_offer",
		title = "Ezra's Card",
		text = "The OSIR investigator from your case sends a note in neat, small handwriting. \"You saw what we needed before we did. The LCD's Distortion department is always short of people who listen properly. I've put your name forward. You don't have to say yes. Most people shouldn't. - Ezra, OSIR Team.\"",
		weight = 0,
		when = { world = ERA, minAge = 18 },
		codex = "lim_inflection_point",
		choices = {
			{
				label = "Join the LCD",
				hint = "Your current job ends.",
				requires = { min = { mind = 30 } },
				result = { career = "lim_lcd", sanity = 2, log = "You started on Line Four, the public hotline, in a grey coat that was slightly too big. Ezra came by on your first day with a coffee and a notebook. \"Write everything down,\" she said. \"Especially the boring parts.\"" },
			},
			{
				label = "Write back that you'll think about it",
				result = { mind = 2, log = "You wrote that you'd think about it. She wrote back: \"Good. The ones who say yes straight away worry me.\"" },
			},
			{
				label = "Ask if there's a case you could help with first",
				result = { quest = "lim_q_inflection", mind = 1, log = "Ezra wrote back the same day with a street address and a time. \"A whole block is losing an hour every night. Bring a watch.\"" },
			},
		},
	},
}
