--[[
	The research life at L Corp (career lcorp_research): Lab Assistant to Head of Research.
	Observation logs, Enkephalin yields, the encyclopedia, work-type studies and their
	ethics, a project of your own, and two colleagues:
	  Dr. Yoon Seo-ah, your supervisor, who measures everything twice;
	  Edvard Lind, the Analyst at the next desk, brilliant and in a hurry, who goes too far.
	Rank gates: 1 Lab Assistant, 3 Analyst, 4 Researcher, 6 Project Lead, 7 Head of Research.
]]

local LAB = { career = "lcorp_research", world = { era = "wings" } }
local OBSERVER = { career = "lcorp_research", minRank = 2, world = { era = "wings" } }
local ANALYST = { career = "lcorp_research", minRank = 3, world = { era = "wings" } }
local HEAD = { career = "lcorp_research", minRank = 7, world = { era = "wings" } }

return {
	{
		id = "lc_rs_first_log",
		title = "Your First Observation Log",
		text = "Your first assignment: eight hours behind thick glass, watching a ZAYIN do almost nothing, and writing down every bit of it. Your supervisor, Dr. Yoon Seo-ah, hands you a pen and says, \"Measure twice. Write once.\" At the next desk, an Analyst with ink on his cuffs, Edvard Lind, is already reading over your shoulder.",
		weight = 140,
		once = true,
		tags = { "lcorp", "research" },
		when = LAB,
		codex = "lcorp_work_types",
		choices = {
			{
				label = "Write exactly what you see, nothing more",
				result = { intelligence = 2, setFlags = { "lc_rs_honest", "lc_met_edvard" }, log = "Your log was eleven pages of nothing much happening, very precisely. Dr. Yoon read all of it and said, \"Good. Again tomorrow.\" Edvard said it was the most boring thing he'd ever read, admiringly." },
			},
			{
				label = "Write what Dr. Yoon seems to expect",
				result = { paycheck = 0.1, sanity = -1, setFlags = { "lc_met_edvard" }, log = "You wrote a tidy, sensible log that matched the last twenty. Dr. Yoon frowned at it for a long time. \"This is what you think I want,\" she said. \"Not what you saw.\"" },
			},
			{
				label = "Add a theory of your own at the end",
				result = { mind = 2, setFlags = { "lc_rs_theorist", "lc_met_edvard" }, log = "You added a page of guesses about why it turned toward the door every hour on the hour. Dr. Yoon crossed out half of it. Edvard copied the other half into his own notebook." },
			},
		},
	},
	{
		id = "lc_rs_yields",
		title = "Enkephalin Yields",
		text = "You've been given the yield charts: how much energy each unit gives off, by day and by work type. The totals don't add up. The PE-Boxes collected are more than the energy that leaves the facility for the City. Not by much. Every single day. Somewhere, a small steady stream goes down instead of out.",
		weight = 24,
		once = true,
		tags = { "lcorp", "research" },
		when = OBSERVER,
		codex = "lc_lore_pe_boxes",
		choices = {
			{
				label = "Recheck every figure",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "A year of numbers", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, setFlags = { "lc_rs_down_stream" }, log = "You rechecked a year of numbers. The stream is real: a little of every day's energy is routed down, below the lowest department, to somewhere the charts call ARCH. You drew a circle around it and didn't show anyone." },
				lose = { sanity = -2, log = "You got lost in the figures and couldn't find the gap again. It's still there. You just can't prove it." },
			},
			{
				label = "Report the gap to the Information Team",
				result = { mind = 1, paycheck = 0.08, setFlags = { "lc_rs_down_stream" }, log = "Yesod took your report, read it once, and thanked you for your diligence. \"Allocated to Architecture,\" he said, as if that explained anything. The gap is still in next month's charts." },
			},
			{
				label = "Round the numbers so the totals match",
				result = { paycheck = 0.12, sanity = -1, log = "You rounded. The charts looked much better. Dr. Yoon checked them and said nothing at all, which was worse than anything she could have said." },
			},
		},
	},
	{
		id = "lc_rs_encyclopedia",
		title = "The Encyclopedia",
		text = "The Information Team keeps an encyclopedia of every Abnormality in the facility, unlocked page by page as observations come in. Three TETH and HE entries are waiting on your desk, half written: an Agent's scribbled notes, a camera log, and a list of work results with the worst ones circled in red.",
		weight = 24,
		cooldown = 4,
		tags = { "lcorp", "research" },
		when = OBSERVER,
		choices = {
			{
				label = "Write them up carefully, every detail checked",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "Three half-written files", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.12, codex = { "lc_abno_fragment", "lc_abno_shy_look", "lc_abno_scarecrow" }, log = "You finished all three entries and checked every line against the camera logs. Agents will read them before they go in. Some of them will come back out because of what you wrote." },
				lose = { sanity = -2, codex = "lc_abno_fragment", log = "You got one done properly. The other two you'll have to start again, because Yesod sent them back covered in red." },
			},
			{
				label = "Interview the Agents who worked the units",
				result = { mind = 2, sanity = -2, codex = { "lc_abno_woodsman", "lc_abno_shy_look" }, log = "The Agents told you more than the notes did, and more than you wanted to know. You wrote it all down. You left out the parts where their hands shook." },
			},
			{
				label = "Finish them fast and move on",
				result = { paycheck = 0.08, codex = "lc_abno_scarecrow", log = "You got through one entry before lunch, and filed the rest as pending. Someone else will finish them, or nobody will." },
			},
		},
	},
	{
		id = "lc_rs_encyclopedia_high",
		title = "The WAW Files",
		text = "Your clearance has gone up, and with it the files you're allowed to read and write: WAW-level Abnormalities, the ones the company only sends veterans to. The Agents' notes on these are short. Some of them stop in the middle of a sentence.",
		weight = 22,
		cooldown = 5,
		tags = { "lcorp", "research" },
		when = { career = "lcorp_research", minRank = 4, world = { era = "wings" } },
		choices = {
			{
				label = "Finish the files, all of them",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "Notes that stop mid-sentence", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.15, codex = { "lc_abno_red_hood", "lc_abno_black_swan", "lc_abno_firebird", "lc_abno_king_greed" }, log = "You finished four WAW files. You finished the sentences too, where you could, from the camera footage. You didn't watch the footage twice." },
				lose = { sanity = { -5, -3 }, codex = "lc_abno_red_hood", log = "You watched the footage for one of the unfinished sentences. You understand now why it stopped." },
			},
			{
				label = "Ask the veterans to read your drafts",
				result = { mind = 2, codex = { "lc_abno_knight_despair", "lc_abno_snow_white" }, log = "Two Level 5 Agents read your drafts over tea and corrected them in a way no file ever had. \"She chooses one person,\" one said, tapping the Knight's page. \"Write that bigger.\"" },
			},
			{
				label = "Leave them for someone braver",
				result = { sanity = 2, log = "You put the WAW files back in the drawer for now. There will always be more files than researchers." },
			},
		},
	},
	{
		id = "lc_rs_work_study",
		title = "A Work-Type Study",
		text = "The encyclopedia entry for The Red Shoes still has one blank line: how it responds to Repression. Everyone suspects the answer. Nobody has measured it. Your study proposal is approved, on one condition: an Agent has to go in and do the work. A Level 2 Agent named Pell has volunteered for the overtime pay.",
		weight = 20,
		once = true,
		tags = { "lcorp", "research" },
		when = ANALYST,
		codex = "lc_abno_red_shoes",
		choices = {
			{
				label = "Run the study as approved",
				result = { paycheck = 0.2, mind = 1, sanity = { -7, -5 }, setFlags = { "lc_rs_ruthless" }, log = "You got your data. The line in the encyclopedia now says NEVER, in capitals, with a reference to your study. Pell is alive. He doesn't do overtime anymore, or much of anything." },
			},
			{
				label = "Test only the safe work types",
				result = { mind = 2, sanity = 1, setFlags = { "lc_rs_ethics" }, log = "You measured Attachment, Insight and Instinct, and wrote \"Repression: not tested, see file history\" in the blank. Dr. Yoon signed off on it without a word, and then bought you lunch." },
			},
			{
				label = "Refuse, and write a memo against tests like it",
				hint = "A Mental Strength check: the memo goes to Hod's policy team.",
				clash = { stat = "mind", foe = "Company policy", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = 3, setFlags = { "lc_rs_ethics", "lc_rs_memo" }, log = "Hod read your memo twice and changed the policy: no study may send an Agent into a known-bad work type. It's the first rule in the training manual with a researcher's name on it." },
				lose = { sanity = -3, setFlags = { "lc_rs_ethics" }, log = "Your memo was filed. Someone else ran the study the next month. You read the result in the encyclopedia." },
			},
		},
	},
	{
		id = "lc_rs_interviews",
		title = "Welfare Interviews",
		text = "Chesed's Welfare Team supplies the research division with transcripts of Agents talking after hard shifts: what they saw, what they felt, how they sleep. Your job is to find patterns in the fear. The transcripts are anonymized, mostly. You recognize one voice. It's someone you eat lunch with.",
		weight = 20,
		cooldown = 5,
		tags = { "lcorp", "research" },
		when = OBSERVER,
		choices = {
			{
				label = "Find the pattern",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "Two hundred frightened voices", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, paycheck = 0.12, codex = "lc_lore_virtues", log = "You found it: Agents fear less as their Virtues rise, but only for the units they've worked before. A new unit is a new fear, every time, at any level. Training adopted your chart." },
				lose = { sanity = { -5, -3 }, log = "You read so many transcripts the voices started to blur into one. It still talks to you, some nights." },
			},
			{
				label = "Ask Welfare to anonymize them properly",
				result = { intelligence = 2, sanity = 1, log = "You sent back the batch with a note. Chesed sent a new one with all the names, places and voices scrubbed, and a coffee voucher." },
			},
			{
				label = "Go and have lunch with the one you recognized",
				result = { sanity = 3, relationBond = { kind = "all", amount = 3 }, log = "You didn't mention the transcript. You just had lunch, and asked how they were, and listened. They talked for an hour. They said it was the first time anyone had asked." },
			},
		},
	},
	{
		id = "lc_rs_egg",
		title = "A New Egg",
		text = "An Abnormality egg arrives for classification, about the size of a person, warm to the touch, humming faintly. Until it's graded and coded, the research team gets to give it a working name. Edvard wants to call it something grand. Dr. Yoon says not to name it at all, and that you'll understand why later.",
		weight = 18,
		once = true,
		tags = { "lcorp", "research" },
		when = OBSERVER,
		choices = {
			{
				label = "Give it a real name",
				result = { sanity = 3, intelligence = 1, setFlags = { "lc_rs_named_one" }, log = "You named it Pip, because it was round. When it hatched and was graded and sent down to its unit, you checked its file every week. Dr. Yoon was right. You understand now." },
			},
			{
				label = "Give it a code and nothing else",
				result = { mind = 2, log = "You wrote a code on the tag and nothing else. Dr. Yoon nodded. Edvard called you heartless, and then quietly called it something grand anyway when he thought nobody could hear." },
			},
			{
				label = "Let Edvard name it",
				requires = { flags = { "lc_met_edvard" } },
				result = { sanity = 1, log = "He named it The Herald of the Unseen Dawn. It hatched into something small and grumpy. He was delighted anyway." },
			},
		},
	},
	{
		id = "lc_rs_edvard_idea",
		title = "Edvard's Idea",
		text = "Edvard catches you in the lab after hours with a notebook full of diagrams. \"Every Abnormality comes from somewhere,\" he says. \"The Extraction Team draws them up from it. If I could just look, during an extraction, once, I'd know where they come from.\" The Extraction Team's first rule is never to look. He knows. He doesn't care.",
		weight = 24,
		once = true,
		tags = { "lcorp", "research" },
		when = { career = "lcorp_research", minRank = 2, world = { era = "wings" }, flags = { "lc_met_edvard" } },
		choices = {
			{
				label = "Help him get onto the Extraction floor",
				result = { sanity = -2, setFlags = { "lc_edvard_helped" }, schedule = { event = "lc_rs_edvard_fell", inYears = 2 }, log = "You forged a work order and got him onto the Extraction floor during a night shift. He went in with his notebook. You waited by the door for an hour. He came out very quiet." },
			},
			{
				label = "Talk him out of it",
				hint = "A Charisma check. He's very sure.",
				clash = { stat = "charisma", foe = "Edvard's certainty", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 2, sanity = 2, setFlags = { "lc_edvard_safe" }, schedule = { event = "lc_rs_edvard_letter", inYears = 2 }, log = "You talked until the lab lights went to night mode. In the end he closed the notebook and said, \"Fine. Not yet.\" You took that as a win." },
				lose = { sanity = -3, setFlags = { "lc_edvard_alone" }, schedule = { event = "lc_rs_edvard_fell", inYears = 2 }, log = "He listened politely, thanked you, and went alone two weeks later. You heard about it from Dr. Yoon." },
			},
			{
				label = "Report him to the Record Team",
				result = { mind = 1, sanity = -2, setFlags = { "lc_edvard_safe", "lc_edvard_reported" }, schedule = { event = "lc_rs_edvard_letter", inYears = 2 }, log = "Hokma's team transferred him to a branch in another District within the week. He didn't say goodbye. You told yourself it was for his own good, and it probably was." },
			},
		},
	},
	{
		id = "lc_rs_edvard_fell",
		title = "Edvard Went Too Far",
		text = "Edvard is in the Welfare Team's long-stay ward. He looked down during an extraction, the Extraction Team says, and he hasn't been the same since. He sits by the window with his notebook open on the same page, smiling a little. When you come in, he looks up and says, \"It's so big. You'd understand, if you saw it.\"",
		weight = 0,
		when = { flags = { "lc_met_edvard" } },
		choices = {
			{
				label = "Sit with him for a while",
				result = { sanity = -4, condition = "grief", setFlags = { "lc_edvard_lost" }, log = "You sat with him all afternoon. He told you about a sea under everything, very calmly, and then forgot you were there. You visit every month. He's always glad to see you, for a minute." },
			},
			{
				label = "Read the page his notebook is open to",
				result = { sanity = -6, mind = 2, setFlags = { "lc_edvard_lost", "lc_well_hint" }, log = "It was a drawing of a well, very deep, and around the edges, in his tiny writing, over and over: every possibility of us. You closed the notebook. Your hands were shaking." },
			},
			{
				label = "Tell the Record Team your part in it",
				requires = { flags = { "lc_edvard_helped" } },
				result = { sanity = 2, money = -100, setFlags = { "lc_edvard_lost" }, log = "You told Hokma you'd forged the work order. He wrote it down, fined you, and said, \"Thank you for telling me,\" so kindly that it hurt more than the fine." },
			},
		},
	},
	{
		id = "lc_rs_edvard_letter",
		title = "A Letter from Edvard",
		text = "A letter arrives in the internal post, from a branch facility in another District. Edvard's handwriting, all slanted with hurry. He's running his own small lab there now, he writes, and the Abnormalities are no less strange for being further from headquarters. At the bottom: \"I still want to know where they come from. I'm just in less of a hurry.\"",
		weight = 0,
		when = { flags = { "lc_edvard_safe" } },
		choices = {
			{
				label = "Write back",
				result = { sanity = 3, addRelation = { kind = "friend", name = "Edvard Lind", bond = 60, age = { 24, 32 } }, log = "You wrote back that night, three pages. He answered in a week, four pages. You've been writing ever since." },
			},
			{
				label = "Keep the letter, and don't answer yet",
				result = { sanity = 1, mind = 1, log = "You kept the letter in your desk drawer. You read it again, some evenings. You'll answer it one day." },
			},
		},
	},
	{
		id = "lc_rs_ethics",
		title = "Do They Suffer?",
		text = "Hod's policy team is running a seminar for the research division, and the question on the board is: \"Do Abnormalities suffer in containment?\" Thirty researchers in a room, nobody wanting to go first. Hod looks around hopefully. Her gaze lands on you.",
		weight = 18,
		once = true,
		tags = { "lcorp", "research" },
		when = ANALYST,
		choices = {
			{
				label = "Say yes, and give your reasons",
				result = { intelligence = 2, sanity = -2, setFlags = { "lc_rs_ethics" }, log = "You talked about the Old Lady's loneliness and the Firebird waiting for hunters who never come. The room went very quiet. Hod wrote down every word, and the seminar ran an hour long." },
			},
			{
				label = "Say they're energy sources, and that's all",
				result = { paycheck = 0.1, sanity = -1, setFlags = { "lc_rs_cold" }, log = "You said it plainly: energy in, energy out. Half the room nodded with relief. The other half didn't look at you for the rest of the day." },
			},
			{
				label = "Ask what the company thinks people are",
				result = { mind = 2, setFlags = { "lc_rs_asked_people" }, log = "Silence. Then Hod laughed nervously and moved on to the next slide. Afterward, Dr. Yoon caught your elbow in the corridor. \"Good question,\" she said, very quietly. \"Don't ask it again in a room with cameras.\"" },
			},
		},
	},
	{
		id = "lc_rs_buyer",
		title = "A Buyer from K Corp",
		text = "A well-dressed researcher from K Corp sits down across from you at the Green Kettle, orders two teas, and slides a card across the table. K Corp would very much like L Corp's raw yield data, the kind that never leaves the facility. The number on the back of the card is more than you make in a year.",
		weight = 16,
		once = true,
		tags = { "lcorp", "research" },
		when = ANALYST,
		choices = {
			{
				label = "Sell it",
				result = { money = { 400, 700 }, sanity = -4, setFlags = { "lc_rs_sold_data" }, log = "You copied a month of yield data onto a drive and left it under a teacup. The money arrived as promised. You check over your shoulder in the corridors now." },
			},
			{
				label = "Refuse, politely",
				result = { mind = 2, log = "You slid the card back. He smiled like he'd expected it and paid for the tea. \"The offer stands,\" he said. You never saw him again." },
			},
			{
				label = "Report him to L Corp security",
				result = { paycheck = 0.2, setFlags = { "lc_rs_loyal" }, codex = "wg_lore_kcorp", log = "Security thanked you and gave you a bonus. The man from K Corp wasn't seen at the Green Kettle again. Neither was the teahouse's owner, for a while, which nobody explained." },
			},
		},
	},
	{
		id = "lc_rs_ordeal",
		title = "Ordeal in the Labs",
		text = "The Dawn of Green has reached the research wing: small boxy machines on thin legs, asking why they were made, coming down the corridor toward the labs. There are no Agents on this floor. There are six researchers, a year of samples in the cold store, and the only copy of this month's observation logs.",
		weight = 16,
		cooldown = 5,
		tags = { "lcorp", "research", "ordeal" },
		when = LAB,
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Barricade the lab door",
				hint = "A Health check.",
				clash = { stat = "health", foe = "The Dawn of Green", coins = 2, base = 4, coinPower = 3 },
				win = { health = 2, sanity = 2, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You and Dr. Yoon pushed every filing cabinet in the lab against the door and held it while the machines tapped and asked. The Disciplinary Team cleared the corridor an hour later." },
				lose = { health = { -8, -4 }, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "The barricade held, mostly. One machine got an arm through. It got you before the cabinets came down on it.", cause = "Holding the lab door" },
			},
			{
				label = "Get the samples into the deep store",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "A year of samples and five minutes", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.15, setFlags = { "lc_breach_survivor" }, log = "You saved every sample, in order, labels intact. The Head of Research mentioned it in a memo. Nobody remembers the memo, but you've kept it." },
				lose = { sanity = -3, setFlags = { "lc_breach_survivor" }, log = "You saved half the samples and dropped a tray of the other half. A year's work for two teams, on the floor." },
			},
			{
				label = "Save the observation logs and hide",
				result = { mind = 1, sanity = -2, setFlags = { "lc_breach_survivor" }, log = "You grabbed the logs and hid under a lab bench with them clutched to your chest. When it was over, they were the only copy left. Agents will be safer for it." },
			},
		},
	},
	{
		id = "lc_rs_project",
		title = "A Project of Your Own",
		text = "Analysts at L Corp are expected to propose a project of their own, and the research committee has approved your budget line. You have three ideas, and money for one: stronger containment glass with the Extraction Team, a course to steady new Agents' nerves with the Training Team, or a way to forecast Qliphoth Counters before they drop.",
		weight = 60,
		once = true,
		tags = { "lcorp", "research" },
		when = ANALYST,
		choices = {
			{
				label = "Stronger containment glass",
				result = { intelligence = 2, setFlags = { "lc_rs_project_glass" }, schedule = { event = "lc_rs_glass_result", inYears = 2 }, log = "You started on the glass with Binah's team, down on the lower floors. The work was slow and the samples kept cracking. The Extraction Team liked you anyway." },
			},
			{
				label = "A course to steady new Agents' nerves",
				result = { mind = 2, setFlags = { "lc_rs_project_course" }, schedule = { event = "lc_rs_course_result", inYears = 2 }, log = "You started on the course with Hod's Training Team. Hod was so excited she sent you three memos a day. Most of them had good ideas in them." },
			},
			{
				label = "Forecasting Qliphoth Counters",
				result = { intelligence = 1, mind = 1, setFlags = { "lc_rs_project_forecast" }, schedule = { event = "lc_rs_forecast_result", inYears = 2 }, codex = "lc_lore_qliphoth", log = "You started on the forecasts with the Information Team, in a corner of the archive Yesod cleared for you. He corrected your method four times in the first week. He was right four times." },
			},
		},
	},
	{
		id = "lc_rs_glass_result",
		title = "The Glass Holds",
		text = "Two years of cracked samples, and then one that doesn't crack. Your containment glass takes a full test from a TETH at zero counter and holds. Binah taps it with one finger and says, \"Clever. It drinks a little of what hits it.\" The glass, you realize, works partly because it's soaking up Enkephalin.",
		weight = 0,
		when = { career = "lcorp_research", world = { era = "wings" } },
		choices = {
			{
				label = "Publish it",
				result = { promote = true, setFlags = { "lc_rs_published" }, chronicle = "lc_research_published", log = "Your glass went into every new containment unit in the facility. Breaches through it dropped to almost nothing. You were promoted, and an Agent you'd never met stopped you in the corridor to shake your hand." },
			},
			{
				label = "Ask Binah where the green it drinks goes",
				result = { mind = 2, setFlags = { "lc_rs_published", "lc_binah_riddle" }, chronicle = "lc_research_published", log = "\"Where everything goes,\" she said. \"Down.\" You published anyway. The glass went into every new unit. You think about what she said more than you think about the glass." },
			},
		},
	},
	{
		id = "lc_rs_course_result",
		title = "The Course",
		text = "Your course for new Agents is ready: breathing drills, fear charts, the four Virtues explained in plain words, and a list of rules from veterans who lived. Hod wants to make it compulsory for every new hire in the facility. She also wants to put her own name on the cover next to yours, very large.",
		weight = 0,
		when = { career = "lcorp_research", world = { era = "wings" } },
		choices = {
			{
				label = "Share the cover with Hod",
				result = { promote = true, sanity = 3, setFlags = { "lc_rs_published" }, chronicle = "lc_research_published", log = "It went out with both your names on it, hers larger. Every new Agent in the facility takes it now. The first-year casualty rate fell, and kept falling." },
			},
			{
				label = "Insist on your name alone",
				hint = "A Mental Strength check: you're arguing with a Sephirah.",
				clash = { stat = "mind", foe = "Hod's feelings", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, setFlags = { "lc_rs_published" }, chronicle = "lc_research_published", log = "Hod agreed, a little hurt, and gave you the credit. The course went out under your name, and so did the promotion." },
				lose = { sanity = -3, setFlags = { "lc_rs_published" }, chronicle = "lc_research_published", log = "She agreed, and was so hurt about it that the whole Training Team stopped speaking to you. The course went out anyway. It saved people. It just didn't feel like much of a win." },
			},
		},
	},
	{
		id = "lc_rs_forecast_result",
		title = "The Forecast",
		text = "Your forecasting method works. Given a week of work results, it predicts which counters will drop and when, with an accuracy that makes the Control Team very interested. Malkuth wants it at once. Yesod wants another year of testing. In the corner of your chart is something you didn't expect: one unit, deep in Architecture, whose counter never moves at all.",
		weight = 0,
		when = { career = "lcorp_research", world = { era = "wings" } },
		choices = {
			{
				label = "Give it to the Control Team now",
				result = { promote = true, setFlags = { "lc_rs_published" }, chronicle = "lc_research_published", log = "Malkuth put it on every screen in Control within a week. Breaches fell by a third that year. She sent you a message with no exclamation marks at all, which you've framed." },
			},
			{
				label = "Test it another year, as Yesod says",
				result = { intelligence = 2, mind = 2, setFlags = { "lc_rs_published" }, chronicle = "lc_research_published", log = "Another year of testing found two flaws that would have killed people. You fixed them. When it went live, it worked. Yesod corrected one comma in your final report, and nothing else." },
			},
			{
				label = "Ask about the unit that never moves",
				result = { mind = 1, sanity = -2, setFlags = { "lc_rs_published", "lc_architecture_hint" }, log = "Yesod looked at the circle on your chart for a long time. \"That isn't an Abnormality,\" he said. \"Remove it from the forecast.\" You did. You kept a copy." },
			},
		},
	},
	{
		id = "lc_rs_scientist",
		title = "Just a Scientist",
		text = "The research committee offers you a fast track: project management, budgets, a corner office and a team of your own. Dr. Yoon took that offer once, she tells you, and spent ten years in meetings. \"Some people are meant to run labs,\" she says. \"Some people are meant to be in them. Only you know which.\"",
		weight = 30,
		once = true,
		tags = { "lcorp", "research" },
		when = { career = "lcorp_research", minRank = 3, world = { era = "wings" }, notFlags = { "lcorp_head_research" } },
		choices = {
			{
				label = "Take the fast track",
				result = { promote = true, sanity = -1, log = "You took the corner office. The view was very good. You found yourself standing at the lab windows on your way past, watching the people in white coats with something like envy." },
			},
			{
				label = "Stay at the bench. Just be a scientist",
				result = { addTrait = "lc_true_scientist", sanity = 4, setFlags = { "lc_stayed_scientist" }, log = "You said no thank you, and went back to your bench, and the work, which is the only part of this job you ever loved. Dr. Yoon brought you a cake with \"SCIENTIST\" written on it in icing." },
			},
			{
				label = "Ask for a team, but keep your bench",
				hint = "An Intelligence check: you'll be doing two jobs.",
				clash = { stat = "intelligence", foe = "Two jobs at once", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, intelligence = 2, log = "You got the team and kept the bench, and spent the next years doing both, badly at first and then very well. Your team calls it the lab with the open door." },
				lose = { sanity = -3, log = "You tried both and did neither well. In the end the committee chose for you, and gave the team to someone else." },
			},
		},
	},
	{
		id = "lc_rs_breakthrough",
		title = "Three in the Morning",
		text = "You've stayed in the lab so late that the City outside is deep in the Night, and the Sweepers are walking the Backstreets, and you're safe in here behind three security doors with a problem you've been stuck on for a month. You're very tired. You're very close.",
		weight = 18,
		cooldown = 4,
		tags = { "lcorp", "research" },
		when = { career = "lcorp_research", minRank = 2, world = { era = "wings" } },
		choices = {
			{
				label = "Keep going until it breaks",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "A month-old problem", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, intelligence = 1, sanity = 2, log = "At four in the morning it broke open, all at once, so simply you laughed out loud in the empty lab. Dr. Yoon read it at nine and went to the committee by ten. Promoted." },
				lose = { sanity = -3, health = -2, log = "At five in the morning you fell asleep on the bench. When you woke up, the idea was gone, and so was the feeling of being close." },
			},
			{
				label = "Go to sleep on the lab cot and try in the morning",
				result = { sanity = 2, mind = 1, log = "You slept four hours on the cot in the corner. In the morning, with tea, you saw what you'd been missing at three. Not a breakthrough. A good step." },
			},
		},
	},
	{
		id = "lc_rs_yoon_retires",
		title = "Dr. Yoon's Last Day",
		text = "Dr. Yoon Seo-ah is retiring after twenty-two years at the bench. She cleans out her desk without ceremony, and at the bottom of the last drawer she finds a thin notebook with a cracked green cover. She holds it for a moment, then holds it out to you. \"My first year here,\" she says. \"I wrote down some things I shouldn't have.\"",
		weight = 24,
		once = true,
		tags = { "lcorp", "research" },
		when = { career = "lcorp_research", minRank = 4, world = { era = "wings" } },
		choices = {
			{
				label = "Take the notebook",
				result = { mind = 2, setFlags = { "lc_yoon_notebook" }, codex = { "lc_abno_one_sin", "lc_abno_plague_doctor", "lc_abno_galaxy" }, log = "Her first-year notes were careful and curious and full of questions she'd crossed out. On the last page, alone: \"Where does the green go, after the City? Ask about ARCH.\" She had never asked. She'd left it for you." },
			},
			{
				label = "Ask her what she'd do differently",
				result = { sanity = 3, intelligence = 1, log = "\"Name fewer of them,\" she said. \"And come in later, and go home earlier, and measure twice.\" Then she hugged you, quickly, and walked out of the lab for the last time." },
			},
			{
				label = "Give her a send-off at the Green Kettle",
				hint = "30 Ahn.",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = 4, addRelation = { kind = "mentor", name = "Yoon Seo-ah", bond = 70, age = { 52, 58 } }, log = "The whole research division came. Edvard made a speech nobody understood. Dr. Yoon laughed until she cried. She told you to visit, and you have, every month." },
			},
		},
	},
	{
		id = "lc_rs_head_offer",
		title = "Head of Research",
		text = "The Head of Research is stepping down, and the committee is choosing between three Project Leads. You are one of them. The Head of Research sets the budget for every study in the facility and signs off on every experiment that sends an Agent into a unit. The Sephirot will answer your questions. Most of them.",
		weight = 50,
		cooldown = 3,
		tags = { "lcorp", "research" },
		when = { career = "lcorp_research", minRank = 6, world = { era = "wings" }, notFlags = { "lcorp_head_research" } },
		choices = {
			{
				label = "Take the chair",
				hint = "Needs Intelligence 55 and Mental Strength 40.",
				requires = { min = { intelligence = 55, mind = 40 } },
				result = { promote = true, sanity = 2, log = "The committee chose you. The Head of Research's office has a window onto the whole research wing and a filing cabinet that only opens for you. You read everything in it on the first night." },
			},
			{
				label = "Take it, with new rules for studies",
				hint = "You stood up for the Agents before. Needs Intelligence 50.",
				requires = { min = { intelligence = 50 }, flags = { "lc_rs_ethics" } },
				result = { promote = true, sanity = 4, log = "You took the chair on one condition: no study would ever again send an Agent into a known-bad work type. The committee agreed. The Agents heard about it before you'd unpacked." },
			},
			{
				label = "Turn it down and stay a scientist",
				result = { sanity = 3, addTrait = "lc_true_scientist", log = "You told the committee you'd rather keep your bench. They chose someone else, who was very good at budgets. You went back to the lab and stayed there." },
			},
		},
	},
	{
		id = "lc_rs_head_budget",
		title = "The Research Budget",
		text = "Your first budget as Head of Research. Three requests, money for two. Containment safety wants new alarms on every HE unit. The yield team wants to study Attachment work on the WAWs. And there's a sealed request from the Architecture Team, at the very bottom of the facility, for an amount larger than the other two together. It gives no reason.",
		weight = 40,
		cooldown = 3,
		tags = { "lcorp", "research" },
		when = HEAD,
		choices = {
			{
				label = "Fund safety and the yield study",
				result = { sanity = 2, paycheck = 0.15, log = "New alarms went up on every HE unit, and the yield study found a work schedule that raised output without raising breaches. The Architecture Team's request came back the next quarter, unchanged." },
			},
			{
				label = "Fund safety and Architecture",
				result = { mind = 2, sanity = -2, setFlags = { "lc_architecture_hint" }, log = "You funded Architecture without knowing why, because the request had Angela's seal on it. The alarms went up. Down at the bottom of the facility, something you'd paid for got a little brighter." },
			},
			{
				label = "Ask the Architecture Team what the money is for",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "A sealed request", coins = 2, base = 6, coinPower = 3 },
				win = { mind = 2, setFlags = { "lc_architecture_hint" }, log = "The reply came in a single line from headquarters: \"For the Light.\" Capital L. You funded safety and the yield study, and kept the reply in your filing cabinet." },
				lose = { sanity = -4, log = "Your question came back stamped DENIED, and the request went through anyway, over your head. You understood, then, how much of the facility you didn't run." },
			},
		},
	},
	{
		id = "lc_rs_head_proposal",
		title = "A Dangerous Proposal",
		text = "A team wants to study the Silent Orchestra's response to sound: they'd play it four bars of music, to see what it does. They've written a careful proposal with safety margins. As Head of Research, your signature decides whether it happens. Dr. Yoon's old warning is pinned above your desk: measure twice.",
		weight = 28,
		cooldown = 4,
		tags = { "lcorp", "research" },
		when = HEAD,
		codex = "lc_abno_orchestra",
		choices = {
			{
				label = "Approve it",
				result = { paycheck = 0.25, sanity = { -7, -4 }, setFlags = { "lc_rs_approved_orchestra" }, log = "It played back. Three bars in, the team cut the sound, as planned. They have the data. Two of them have the music, too, in their heads, and the Welfare Team can't get it out." },
			},
			{
				label = "Reject it",
				result = { mind = 2, sanity = 2, log = "You rejected it, with a note explaining why. The team was furious. A year later, a branch facility ran the same test without asking anyone. You read their report and slept badly." },
			},
			{
				label = "Redesign it: one note, not four bars",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "A careful redesign", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.15, setFlags = { "lc_rs_published" }, chronicle = "lc_research_published", log = "One note, through three layers of glass, for half a second. The conductor turned its head. That was all, and it was enough to rewrite half of its file. Nobody heard the music afterward." },
				lose = { sanity = -4, log = "Even one note was too much. The conductor raised its baton and held it there for six hours, while the whole department waited for it to come down. It didn't. Nobody slept." },
			},
		},
	},
}
