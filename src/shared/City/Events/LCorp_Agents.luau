--[[
	The L Corp agent life, Clerk to Department Captain: getting hired, the Clerk years,
	Agent life, the Sephirot (spoiler-light), Continued Service and the Record Team's
	reviews, and two colleagues who come back across a career:
	  Mirela Dragan, hired the same day as you, who knows every Abnormality rumor;
	  Hyun-woo Baek, a Level 4 veteran with a Continued Service armband.
	Rank gates: rank 1 Clerk (notFlags lc_was_agent), 2 Agent L1, 4 L3, 6 L5, 7 Captain.
	Ordeals, Captains and Branch Managers are in Events/LCorp_Command.luau.
]]

local AGENT = { career = "lcorp_agent", minRank = 2, world = { era = "wings" } }
local CLERK = { career = "lcorp_agent", world = { era = "wings" }, notFlags = { "lc_was_agent" } }

return {
	-- ── getting hired ──
	{
		id = "lc_hiring_season",
		title = "L Corp Is Hiring",
		text = "Green posters on every wall in the District: FACE THE FEAR, BUILD THE FUTURE. Under the Lobotomy Corporation logo, a salary figure that makes the people at the bus stop laugh out loud, then go quiet. Two recruiters in pressed suits sit at a folding table with a queue in front of them. Nobody in the queue is talking.",
		weight = 18,
		cooldown = 4,
		tags = { "lcorp" },
		when = { district = "d12", minAge = 18, maxAge = 36, world = { era = "wings" }, notFlags = { "lcorp_employee" } },
		codex = "lcorp_abnormalities",
		choices = {
			{
				label = "Join the queue for a Clerk's job",
				hint = "Needs Health 25 and Mental Strength 25. Clerks become Agents.",
				requires = { min = { health = 25, mind = 25 } },
				result = { career = "lcorp_agent", sanity = -1, codex = "lc_lore_agents", log = "The recruiter stamped your form without reading it and handed you a badge on a green lanyard. \"Orientation is tomorrow,\" she said. \"Don't be late. Lateness is a bad sign, in this job.\"" },
			},
			{
				label = "Ask about the research labs",
				hint = "Needs Intelligence 35.",
				requires = { min = { intelligence = 35 } },
				result = { career = "lcorp_research", codex = "lc_lore_risk_levels", log = "The second recruiter perked up. \"A scientist! Observation logs, energy yields, the encyclopedia.\" She gave you a lab badge and a thick pamphlet. The pamphlet had no pictures." },
			},
			{
				label = "Ask what happened to the last person in the job",
				result = { mind = 1, sanity = -1, log = "\"Promoted,\" the recruiter said, a little too fast. The man behind you in the queue left. You thought about leaving too." },
			},
			{
				label = "Walk past the posters",
				result = { sanity = 1, log = "You walked past. The posters followed you down the street, one every ten meters, and the salary figure stayed in your head all week." },
			},
		},
	},
	{
		id = "lc_family_interview",
		title = "The Family Business",
		text = "Your parents have set up an interview for you at L Corp without asking. \"It's a good company,\" your mother says, for the hundredth time. Neither of them has ever told you what they do there. They've never missed a day, and they've never once talked about work at dinner.",
		weight = 70,
		once = true,
		tags = { "lcorp" },
		when = { flags = { "lcorp_family" }, minAge = 18, maxAge = 24, world = { era = "wings" }, notFlags = { "lcorp_employee" } },
		choices = {
			{
				label = "Go to the interview for a Clerk's job",
				hint = "Needs Health 25 and Mental Strength 25.",
				requires = { min = { health = 25, mind = 25 } },
				result = { career = "lcorp_agent", relationBond = { kind = "family", amount = 8 }, codex = "lc_lore_agents", log = "The interviewer knew your family name and didn't ask you a single question about yourself. You started the next week. Your parents were so proud they forgot to look worried." },
			},
			{
				label = "Ask for a place in the research labs",
				hint = "Needs Intelligence 35.",
				requires = { min = { intelligence = 35 } },
				result = { career = "lcorp_research", relationBond = { kind = "family", amount = 8 }, codex = "lc_lore_risk_levels", log = "You asked for the labs. Your father let out a breath you hadn't known he was holding. \"Good,\" he said. \"Good. Further from the units.\"" },
			},
			{
				label = "Ask them what they actually do there",
				result = { mind = 2, setFlags = { "lc_asked_parents" }, codex = "lc_lore_departments", log = "They looked at each other for a long time. \"We keep the lights on,\" your mother said at last. That night you heard them talking in the kitchen, low, about a unit that had gone quiet." },
			},
			{
				label = "Refuse and make your own way",
				result = { sanity = 3, relationBond = { kind = "family", amount = -6 }, setFlags = { "lc_refused_family" }, log = "You said no. Your mother didn't speak to you for a week. Your father, quietly, told you he was glad." },
			},
		},
	},
	{
		id = "lc_recruiter",
		title = "A Recruiter from District 12",
		text = "A woman in a clean suit with green trim is handing out cards outside the WARP station. Lobotomy Corporation is recruiting far from home this year, she says: relocation paid, a room near the facility, and a salary she writes on the back of the card instead of saying out loud.",
		weight = 4,
		cooldown = 8,
		tags = { "lcorp" },
		when = { notDistrict = "d12", minAge = 18, maxAge = 30, world = { era = "wings" }, notFlags = { "lcorp_employee" } },
		choices = {
			{
				label = "Take the relocation and a Clerk's badge",
				hint = "Moves you to District 12. Needs Health 25 and Mental Strength 25.",
				requires = { min = { health = 25, mind = 25 } },
				result = { district = "d12", career = "lcorp_agent", money = 60, codex = "lc_lore_agents", log = "You signed on the station steps. By the end of the week you lived in District 12, under the green glow of the L Corp tower, with a badge on a green lanyard and a key to a very small room." },
			},
			{
				label = "Ask whether the labs are hiring too",
				hint = "Moves you to District 12. Needs Intelligence 38.",
				requires = { min = { intelligence = 38 } },
				result = { district = "d12", career = "lcorp_research", money = 60, codex = "lc_lore_risk_levels", log = "They were. The recruiter seemed relieved to have found someone who could read. You moved to District 12 with two bags and a lab coat in your size." },
			},
			{
				label = "Ask why they're recruiting so far from home",
				result = { mind = 1, sanity = -1, log = "\"Growth,\" she said, smiling. Her smile didn't move when she said it. You kept the card in your wallet for years." },
			},
			{
				label = "Take a card and walk on",
				result = { sanity = 1, log = "You took a card to be polite. You looked at the number on the back more often than you'd admit." },
			},
		},
	},

	-- ── the Clerk years ──
	{
		id = "lc_clerk_orientation",
		title = "Orientation",
		text = "Orientation is in a white room on the Training Team's floor. The Sephirah of the Training Team, Hod, is a slender robot with a gentle voice who is clearly thrilled to see you. The safety video is mostly diagrams of people running. The new hire beside you, a woman with a notebook full of drawings, leans over and whispers, \"Want to know which units actually kill people?\"",
		weight = 140,
		once = true,
		tags = { "lcorp" },
		when = CLERK,
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Take careful notes",
				result = { intelligence = 2, setFlags = { "lc_met_mirela" }, codex = "lc_lore_agents", log = "You took four pages of notes. Hod beamed at you. The woman with the notebook, Mirela Dragan, copied all four pages and added drawings of the Abnormalities in the margins." },
			},
			{
				label = "Ask Hod about the Abnormalities",
				result = { mind = 2, setFlags = { "lc_met_mirela" }, codex = "lc_lore_risk_levels", log = "Hod was so happy someone had asked a question that she talked for twenty minutes about risk levels. The woman beside you, Mirela Dragan, whispered corrections the whole time. Most of them were right." },
			},
			{
				label = "Trade rumors with the woman beside you",
				result = { sanity = 2, setFlags = { "lc_met_mirela", "lc_mirela_friend" }, codex = "lcorp_work_types", log = "Her name was Mirela Dragan, and she knew more Abnormality trivia than the Information Team. You missed the whole safety video. You came out with a friend and a list of units to avoid." },
			},
		},
	},
	{
		id = "lc_clerk_alarm",
		title = "Clerks Without Agents",
		text = "The alarm goes off at a quarter past ten, and every Agent on your floor is out on a work order. It's just the Clerks: you, twelve others, and a coffee machine. Somebody screams. Somebody else starts climbing into a filing cabinet. The corridor speaker is saying something calm that nobody can hear.",
		weight = 30,
		cooldown = 4,
		tags = { "lcorp" },
		when = CLERK,
		choices = {
			{
				label = "Keep the room calm",
				hint = "A Mental Strength check: twelve panicking Clerks.",
				clash = { stat = "mind", foe = "Twelve panicking Clerks", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 3, setFlags = { "lc_breach_survivor", "lc_calm_clerk" }, log = "You got everyone under the desks in rows, lights off, and talked in a low voice until the all-clear. The Record Team noted it. So did twelve Clerks, who brought you pastries for a month." },
				lose = { sanity = { -6, -3 }, setFlags = { "lc_breach_survivor" }, log = "The panic won. Somebody broke the coffee machine. You spent the alarm holding a door shut that nothing was trying to open." },
			},
			{
				label = "Hide under your desk",
				result = { sanity = { -4, -2 }, setFlags = { "lc_breach_survivor" }, log = "You hid under your desk with your hands over your ears until the all-clear. Every Clerk on the floor did the same. Nobody mentions it, ever." },
			},
			{
				label = "Run for the elevator",
				hint = "A Speed check: the elevator is past the containment corridor.",
				clash = { stat = "speed", foe = "The containment corridor", coins = 2, base = 4, coinPower = 3 },
				win = { speed = 2, setFlags = { "lc_breach_survivor" }, log = "You made the elevator, and you held the door for three others. You didn't see what was in the corridor. You heard it." },
				lose = { health = { -9, -4 }, sanity = -3, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You ran right into it. You don't know what it was. The Agents who came back for you said you were lucky it was only a TETH.", cause = "Ran into a breach" },
			},
		},
	},
	{
		id = "lc_record_team",
		title = "The Record Team",
		text = "Hokma's Record Team writes down everything every employee does, all day. Contracts and promotions are decided from what it writes. The Sephirah of Record, an old-fashioned robot who talks like somebody's grandfather, has asked to see every form you've filed this month. He is reading them very slowly.",
		weight = 22,
		cooldown = 5,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", world = { era = "wings" }, notFlags = { "lcorp_captain" } },
		codex = "lc_lore_departments",
		choices = {
			{
				label = "File everything perfectly, from now on",
				hint = "An Intelligence check. Good records get people promoted.",
				clash = { stat = "intelligence", foe = "A mountain of forms", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, promote = true, setFlags = { "lc_good_records" }, log = "You redid a month of forms in a weekend. Hokma read them all, very slowly, and wrote one line in your file. A week later, you were promoted." },
				lose = { intelligence = 1, sanity = -2, log = "You redid a month of forms in a weekend and got the dates wrong on half of them. Hokma was very kind about it, which was worse." },
			},
			{
				label = "Bring the Record Team's Clerks a box of pastries",
				hint = "15 Ahn.",
				requires = { min = { money = 15 } },
				result = { money = -15, sanity = 1, setFlags = { "lc_record_favor" }, log = "The Record Team's Clerks were very grateful. Records, they told you, are a matter of emphasis. You weren't sure what that meant. You'll find out at promotion time." },
			},
			{
				label = "Let the forms speak for themselves",
				result = { sanity = 1, mind = 1, log = "You let Hokma read in peace. He hummed over your file like a man reading a long, sad novel, and told you to take care of yourself." },
			},
		},
	},
	{
		id = "lc_clerk_transfer",
		title = "A Transfer Form",
		text = "The Manager is short of Agents. A form appears in every Clerk's inbox: volunteers for Agent training, Level 1, effective immediately. The pay doubles. The paragraph about risk is printed in very small type. Mirela, at the desk across from yours, has already signed hers.",
		weight = 45,
		once = true,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minAge = 19, world = { era = "wings" }, notFlags = { "lc_was_agent" } },
		choices = {
			{
				label = "Sign it",
				result = { promote = true, sanity = -2, log = "You signed. A week later you had a black suit, a riot stick and a schedule full of codes you didn't recognize yet. Mirela shook your hand like you'd both joined something." },
			},
			{
				label = "Stay a Clerk",
				result = { sanity = 3, mind = 1, log = "You stayed at your desk. The Clerks who stayed with you looked at the empty desks a lot that year, but you all got to go home every night." },
			},
			{
				label = "Ask for a place in the labs instead",
				hint = "Needs Intelligence 35.",
				requires = { min = { intelligence = 35 } },
				result = { career = "lcorp_research", log = "You asked for the research division instead. The Manager's office approved it in a day, which told you how many people asked." },
			},
		},
	},

	-- ── Agent life ──
	{
		id = "lc_first_uniform",
		title = "The Standard Uniform",
		text = "Netzach's Safety Team issues you a black suit and a standard riot stick. The Sephirah of Safety gives the emergency briefing lying back in his chair with his eyes half closed. Afterward, an older Agent with a Continued Service armband stops you in the corridor. \"Hyun-woo Baek. Level 4,\" he says. \"One rule, rookie: read the file. Then read it again.\"",
		weight = 140,
		once = true,
		tags = { "lcorp" },
		when = AGENT,
		codex = "lc_lore_virtues",
		choices = {
			{
				label = "Learn the emergency plan by heart",
				result = { mind = 2, setFlags = { "lc_met_baek" }, codex = "lc_lore_suppression", log = "You learned every exit, every shelter and every code. Baek quizzed you in the elevator and nodded at the answers. Netzach, you're fairly sure, slept through the whole thing." },
			},
			{
				label = "Drill with the riot stick until your arms ache",
				result = { strength = 2, setFlags = { "lc_met_baek" }, log = "You drilled until your shoulders burned. Baek watched for a while, then fixed your grip without a word." },
			},
			{
				label = "Book a Welfare Team appointment in advance",
				result = { sanity = 3, setFlags = { "lc_met_baek" }, log = "Chesed's Welfare Team booked you in for the month after next. \"Smart,\" Baek said, when you told him. \"Most people wait until they need it.\"" },
			},
		},
	},
	{
		id = "lc_quota_day",
		title = "Quota Day",
		text = "The facility is behind on its energy quota, and the Control Team has been shouting about it over the speakers since dawn. Malkuth, the Sephirah of Control, is giving three orders at once. Work orders keep appearing on the board with your name on them. The day doesn't end until the quota is filled.",
		weight = 28,
		cooldown = 3,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 2, world = { era = "wings" }, notFlags = { "lcorp_captain" } },
		codex = "lc_lore_pe_boxes",
		choices = {
			{
				label = "Take every extra order they'll give you",
				result = { paycheck = 0.2, sanity = { -4, -2 }, health = { -3, 0 }, log = "You worked until your legs shook and the PE-Boxes stacked up green behind you. The quota filled at a quarter to midnight. Your bonus was very good. You don't remember the last four hours." },
			},
			{
				label = "Stick to your own schedule, carefully",
				result = { mind = 2, log = "You worked your own units, carefully, and ignored the shouting. Malkuth called you \"lazy\" over the speaker. Nobody on your schedule got hurt." },
			},
			{
				label = "Help Mirela get through her list",
				requires = { flags = { "lc_met_mirela" }, notFlags = { "lc_mirela_lost" } },
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "Two lists and one afternoon", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, sanity = 3, setFlags = { "lc_mirela_friend" }, log = "You split her list with her and finished both by ten. She bought you noodles at the Green Kettle and talked Abnormality trivia until they closed." },
				lose = { sanity = -2, health = -2, log = "You both finished late and exhausted. She thanked you anyway, too tired to say much else." },
			},
		},
	},
	{
		id = "lc_meltdown",
		title = "Qliphoth Meltdown",
		text = "The facility gauge fills at two in the afternoon, and alarms go off on five units at once. Qliphoth Meltdown. Your assigned unit is down the left corridor. Next door, an HE unit's alarm is flashing too, and through the window you can see a Clerk who went in to fix a light and is now standing very still.",
		weight = 26,
		cooldown = 3,
		tags = { "lcorp" },
		when = AGENT,
		codex = "lc_lore_qliphoth",
		choices = {
			{
				label = "Run to your assigned unit",
				hint = "An Intelligence check: the work has to be done now, and done right.",
				clash = { stat = "intelligence", foe = "A meltdown alarm", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.12, log = "You got to your unit and did the work fast and clean, and the alarm stopped. Two of the five didn't. You heard about them at dinner." },
				lose = { health = { -6, -3 }, sanity = -3, log = "You fumbled the work under the alarm, and the unit let you know it. The counter held, just." },
			},
			{
				label = "Go and get the Clerk out",
				hint = "A Health check. It's an HE.",
				clash = { stat = "health", foe = "An HE unit in meltdown", coins = 2, base = 5, coinPower = 3 },
				win = { health = 2, sanity = 4, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You went in, took the Clerk by both shoulders and walked her out backward without looking at what she'd been staring at. She hasn't stopped thanking you." },
				lose = { health = { -10, -5 }, sanity = -4, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You got her out. It cost you. The Welfare Team stitched you up and told you that you'd done a brave and stupid thing.", cause = "Went into a meltdown for a Clerk" },
			},
			{
				label = "Hold your post and keep the corridor clear",
				result = { mind = 1, sanity = -2, log = "You held the corridor and waved people past and did exactly what the emergency plan said. It was the right call. It didn't feel like one." },
			},
		},
	},
	{
		id = "lc_level_review",
		title = "The Record Team's Assessment",
		text = "Your yearly assessment. The Record Team tests one Virtue of your choosing in front of a panel, and promotion depends on the result. Hokma sits at the end of the table with a pen. \"Pick whichever you're proudest of,\" he says. \"Everyone does.\"",
		weight = 26,
		cooldown = 3,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 2, world = { era = "wings" }, notFlags = { "lcorp_captain" } },
		codex = "lc_lore_virtues",
		choices = {
			{
				label = "Health: the endurance course",
				hint = "A Health check for promotion.",
				clash = { stat = "health", foe = "The endurance course", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, health = 1, log = "You finished the course with the panel watching and didn't stop once. Hokma wrote a single word. You were promoted the following week." },
				lose = { health = -2, sanity = -2, log = "You didn't finish. Hokma wrote something kind and unhelpful in your file." },
			},
			{
				label = "Mental Strength: the fear test",
				hint = "A Mental Strength check for promotion.",
				clash = { stat = "mind", foe = "A simulated breach", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, mind = 1, log = "They played you the recordings, and the lights went red, and something that sounded like a breach came down the hall. You kept your hands steady on the clipboard. Promoted." },
				lose = { sanity = { -4, -2 }, log = "You knew it was a simulation and your hands shook anyway. Next year, Hokma said." },
			},
			{
				label = "Intelligence: the timed work order",
				hint = "An Intelligence check for promotion.",
				clash = { stat = "intelligence", foe = "A stopwatch", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, intelligence = 1, log = "Every step of the procedure, right and fast, with a stopwatch ticking on the table. The panel looked at each other. Promoted." },
				lose = { sanity = -2, log = "You were thirty seconds over. In a real unit, Hokma said gently, thirty seconds is a long time." },
			},
			{
				label = "Strength: the suppression drill",
				hint = "A Strength check for promotion.",
				clash = { stat = "strength", foe = "The Disciplinary Team's drill", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, strength = 1, log = "You went through the Disciplinary Team's drill like you'd been born holding a riot stick. Gebura watched from the gallery and nodded once. Promoted." },
				lose = { health = -2, sanity = -2, log = "A Disciplinary Agent put you on the mat three times. \"Again next year,\" she said, helping you up." },
			},
		},
	},
	{
		id = "lc_continued_service",
		title = "Continued Service",
		text = "You've been in the same department long enough to earn a Continued Service armband and a title on your badge: Steadfast. The same week, a transfer form arrives. Disciplinary, Welfare and Extraction all want experienced Agents. A transfer means a fresh start, and it means giving up your seniority and the armband.",
		weight = 40,
		once = true,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 4, world = { era = "wings" } },
		codex = "lc_lore_agents",
		choices = {
			{
				label = "Stay in your department",
				result = { addTrait = "lc_steadfast_veteran", setFlags = { "lc_department_loyal" }, sanity = 2, log = "You stayed. They pinned the armband on in the cafeteria, and the Clerks clapped, and you felt, for the first time, like the facility was yours a little." },
			},
			{
				label = "Transfer to the Disciplinary Team",
				result = { strength = 3, setFlags = { "lc_disciplinary" }, log = "You transferred to the most hardcore department in the facility. The red armor took some getting used to. The suppression drills took longer." },
			},
			{
				label = "Transfer to the Welfare Team",
				result = { sanity = 5, cure = "any", setFlags = { "lc_welfare" }, log = "You transferred to Welfare, where Chesed runs things in his shirtsleeves with a coffee cup in his hand. You learned to patch people up, and the patching did you some good too." },
			},
			{
				label = "Transfer to the Extraction Team",
				result = { mind = 2, setFlags = { "lc_extraction_team" }, codex = "lc_lore_ego_gear", log = "You transferred down to the lower floors, where Binah's team makes E.G.O and repairs the walls. Your new supervisor gave you one rule before anything else: when you're near the extraction room, never look down." },
			},
		},
	},

	-- ── the Sephirot ──
	{
		id = "lc_seph_malkuth",
		title = "Malkuth Has Orders",
		text = "Malkuth, the Sephirah of the Control Team, is in your earpiece giving you three orders at once: get to the east corridor, check the west unit, and bring her a status report she could read on her own cameras. She is very good at her job and very sure everyone else is bad at theirs.",
		weight = 16,
		cooldown = 6,
		tags = { "lcorp" },
		when = AGENT,
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Do all three, in order",
				result = { intelligence = 2, health = -1, log = "You ran east, then west, then upstairs with a report. Malkuth said \"Finally,\" which from her is warm praise." },
			},
			{
				label = "Ask her, politely, which one matters most",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "Malkuth's temper", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "There was a long pause. \"Nobody ever asks,\" she said, sounding almost pleased. \"The east corridor.\" She's been slightly nicer to you ever since." },
				lose = { sanity = -3, log = "\"ALL of them matter,\" she said, loudly enough that the whole department heard. You got a note in your file." },
			},
			{
				label = "Switch your earpiece off for five minutes",
				result = { sanity = 3, strength = 1, setFlags = { "lc_malkuth_grudge" }, log = "Five glorious minutes of silence. Malkuth noticed. Malkuth notices everything. She hasn't forgotten." },
			},
		},
	},
	{
		id = "lc_seph_yesod",
		title = "Red Ink",
		text = "Your observation report comes back from the Information Team covered in red ink. Yesod, the Sephirah of Information, has corrected your spelling, your grammar, two of your measurements, and the way you dotted an i. At the bottom: \"See me.\" He is waiting in the archive, among a thousand files.",
		weight = 16,
		cooldown = 6,
		tags = { "lcorp" },
		when = AGENT,
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Rewrite it properly",
				result = { intelligence = 2, setFlags = { "lc_yesod_respect" }, log = "You rewrote it twice. Yesod read it, adjusted his glasses, and said \"Acceptable.\" You didn't know a machine could make a word sound like a medal." },
			},
			{
				label = "Argue one of the measurements",
				hint = "A Charisma check. You're fairly sure you were right.",
				clash = { stat = "charisma", foe = "Yesod's certainty", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 2, sanity = 2, setFlags = { "lc_yesod_respect" }, log = "You were right. Yesod checked it three times and then corrected the file, in red, under your name. It's the most satisfying thing that's happened to you all year." },
				lose = { sanity = -2, log = "You were wrong. He showed you why, in detail, for an hour." },
			},
			{
				label = "Ask him what the oldest file in the archive is",
				result = { mind = 1, setFlags = { "lc_archive_hint" }, log = "Yesod went very still. \"Older than the company,\" he said. Then he handed back your report and asked you to leave, and he has never mentioned it again." },
			},
		},
	},
	{
		id = "lc_seph_netzach",
		title = "The Safety Briefing",
		text = "It's the quarterly safety briefing, and Netzach, the Sephirah of the Safety Team, is meant to give it. He is slumped in his chair at the front of the room with his eyes closed. Thirty Agents are waiting. The emergency plans are in a folder on his lap.",
		weight = 14,
		cooldown = 6,
		tags = { "lcorp" },
		when = AGENT,
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Wake him up",
				result = { mind = 1, sanity = 1, log = "He opened one eye, gave the whole briefing in ninety seconds, flawlessly, and went back to sleep. Every word of it was useful. That's the annoying part." },
			},
			{
				label = "Pick up the folder and give the briefing yourself",
				hint = "An Intelligence check: thirty people and somebody else's notes.",
				clash = { stat = "intelligence", foe = "Thirty bored Agents", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, setFlags = { "lc_netzach_favor" }, log = "You gave the briefing. You were good at it. At the end Netzach said, without opening his eyes, \"You do it from now on,\" and so you have, every quarter since." },
				lose = { sanity = -2, log = "You lost your place twice and someone laughed. Netzach woke up, said \"Page four,\" and went back to sleep." },
			},
			{
				label = "Let him sleep and read the plans on your own",
				result = { mind = 2, log = "You read the plans quietly in the back row while he slept. You think he appreciated it. It's hard to tell with Netzach." },
			},
		},
	},
	{
		id = "lc_seph_hod",
		title = "Hod Wants to Know",
		text = "Hod, the Sephirah of the Training Team, catches you after a shift with a clipboard and a hopeful voice. She's redesigning the training program and wants your honest opinion of it. She very much wants you to like it. She has, you can see, already rewritten it six times.",
		weight = 14,
		cooldown = 6,
		tags = { "lcorp" },
		when = AGENT,
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Give her your honest opinion",
				hint = "A Mental Strength check: honest, and kind.",
				clash = { stat = "mind", foe = "Hurting a robot's feelings", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, setFlags = { "lc_hod_trust" }, log = "You told her the truth gently, and she wrote down every word. The new program was much better. She thanked you in front of everyone, which you could have done without." },
				lose = { sanity = -2, log = "You were honest. She was crushed. She spent the next week being so nice to you that it hurt." },
			},
			{
				label = "Tell her it's wonderful",
				result = { sanity = 2, intelligence = 1, log = "Her whole frame seemed to relax. \"Really?\" she said. You said really. The program didn't get any better, but she did seem happier." },
			},
			{
				label = "Volunteer to help teach the new hires",
				result = { intelligence = 3, setFlags = { "lc_hod_trust", "lc_teacher" }, log = "You spent your evenings teaching rookies the rules that keep you alive. You were better at it than you expected. Some of them are still alive because of it." },
			},
		},
	},
	{
		id = "lc_seph_chesed",
		title = "Coffee with Chesed",
		text = "The Welfare Team calls you in for a \"routine mental evaluation.\" Chesed, the Sephirah of Welfare, has his sleeves rolled up and a cup of coffee in each hand. He offers you one. \"You've been on some hard units this year,\" he says. \"How are you sleeping?\"",
		weight = 16,
		cooldown = 5,
		tags = { "lcorp" },
		when = AGENT,
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Tell him about the nightmares",
				result = { sanity = { 5, 8 }, cure = "lc_shaken", log = "You told him everything. He listened, and refilled your coffee, and gave you three days off and a number to call. You slept through the night for the first time in months." },
			},
			{
				label = "Tell him you're fine",
				result = { sanity = -1, mind = 1, log = "\"Of course you are,\" he said, kindly, and wrote something down. He knew. He let you go anyway, and put you on his list to check on." },
			},
			{
				label = "Ask him about the coffee",
				result = { sanity = 3, intelligence = 1, log = "He talked about coffee beans for twenty minutes with real joy. By the end you'd forgotten what you came in worried about, which, you suspect, was the point." },
			},
		},
	},
	{
		id = "lc_seph_gebura",
		title = "The Disciplinary Team",
		text = "The Disciplinary Team trains in a gym with red mats and very few rules. Its Sephirah, Gebura, stands at the edge in armor the color of a warning light, watching. She fights, they say, like someone who remembers doing it for a living. She points at you. \"You. Spar.\"",
		weight = 16,
		cooldown = 6,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 3, world = { era = "wings" } },
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Step onto the mat",
				hint = "A sparring match with a Disciplinary Agent.",
				clash = { stat = "strength", foe = "A Disciplinary Agent", coins = 2, base = 5, coinPower = 3, fight = true },
				win = { strength = { 2, 3 }, sanity = 2, setFlags = { "lc_gebura_noticed" }, log = "You put him on the mat twice. Gebura said nothing for a long moment, then: \"Again. Tomorrow.\" She's been watching your record since." },
				lose = { health = { -6, -3 }, strength = 1, log = "He put you on the mat four times. Gebura helped you up herself. \"Better than most,\" she said. You'll take it." },
			},
			{
				label = "Ask her where she learned to fight",
				result = { mind = 1, setFlags = { "lc_gebura_hint" }, log = "She looked at her own armored hands for a long time. \"Somewhere red,\" she said finally, and turned back to the mats." },
			},
			{
				label = "Decline politely",
				result = { sanity = 1, log = "You said you had a work order. She looked at you like she knew exactly how true that was, and let you go." },
			},
		},
	},
	{
		id = "lc_seph_tiphereth",
		title = "A Question of Uniforms",
		text = "The Tiphereth twins of Central Command, who supervise every department and are very particular about their outfits, have stopped you in the hallway with two fabric swatches. They're redesigning the Central Command uniforms and can't agree. They both look at you. They both expect to win.",
		weight = 12,
		cooldown = 8,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 3, world = { era = "wings" } },
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Pick the dark green",
				result = { sanity = 2, log = "One twin cheered. The other sulked for a month and inspected your department twice as often." },
			},
			{
				label = "Pick the pale gold",
				result = { sanity = 2, log = "One twin cheered. The other sulked for a month and inspected your department twice as often. It was the other twin this time." },
			},
			{
				label = "Say they'd both look perfect in either",
				hint = "An Intelligence check: diplomacy.",
				clash = { stat = "intelligence", foe = "Two very particular supervisors", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, sanity = 3, log = "They looked at each other and agreed, for once, that you had excellent taste. Your department's inspections got noticeably gentler." },
				lose = { sanity = -2, log = "They agreed you had no taste whatsoever. It was the first thing they'd agreed on in years." },
			},
		},
	},

	-- ── Mirela Dragan ──
	{
		id = "lc_mirela_fairies",
		title = "Mirela's Fairies",
		text = "Mirela comes out of the Fairy Festival unit glowing, with a little cloud of fairies humming around her head. \"The Fairies' Care!\" she says. \"They chose me!\" She checks her schedule. \"And I've got a TETH next. I'll be invincible.\" She starts down the corridor toward the TETH units.",
		weight = 30,
		once = true,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 2, world = { era = "wings" }, flags = { "lc_met_mirela" }, notFlags = { "lc_mirela_lost" } },
		choices = {
			{
				label = "Tell her what happened to you",
				hint = "You've been there.",
				requires = { flags = { "lc_fairy_lesson" } },
				result = { sanity = 3, setFlags = { "lc_mirela_saved", "lc_mirela_friend" }, log = "You told her about the fairies following you into the next unit. She went pale and swapped her schedule on the spot. \"I owe you,\" she said. You've never let her forget it." },
			},
			{
				label = "Talk her out of it",
				hint = "A Charisma check. She's very excited.",
				clash = { stat = "charisma", foe = "Mirela's excitement", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, setFlags = { "lc_mirela_saved", "lc_mirela_friend" }, codex = "lc_abno_fairy_festival", log = "You stood in front of her until she agreed to read the rest of the fairies' file. When she got to the high-clearance part, she sat down on the floor. She swapped her schedule." },
				lose = { sanity = -3, setFlags = { "lc_mirela_lost" }, schedule = { event = "lc_mirela_memorial", inYears = 1 }, log = "She laughed and told you not to worry so much, and went into the TETH unit. The fairies went in with her." },
			},
			{
				label = "Report it to the Safety Team",
				result = { sanity = 1, setFlags = { "lc_mirela_saved" }, log = "Netzach reassigned her without opening his eyes. Mirela didn't speak to you for a month. Then she read the rest of the file, and brought you a cake." },
			},
			{
				label = "Let her go; she knows the units better than you",
				result = { setFlags = { "lc_mirela_lost" }, schedule = { event = "lc_mirela_memorial", inYears = 1 }, log = "She did know them better than you. You told yourself that for a long time afterward." },
			},
		},
	},
	{
		id = "lc_mirela_memorial",
		title = "A Name on the Wall",
		text = "There is a wall in the lobby where the company puts the names of employees who didn't clock out. This morning, a maintenance worker added one more: MIRELA DRAGAN. Somebody has already left a drawing of a fairy at the foot of the wall. Her locker hasn't been emptied yet.",
		weight = 0,
		when = { flags = { "lc_mirela_lost" } },
		choices = {
			{
				label = "Leave her favorite snack by the wall",
				result = { sanity = 2, condition = "grief", log = "You left a bag of the salted plums she always ate. By evening there were six more bags. She'd shared them with everyone." },
			},
			{
				label = "Take her notebook from her locker before it's emptied",
				result = { mind = 2, condition = "grief", setFlags = { "lc_mirela_notebook" }, codex = { "lc_abno_fragment", "lc_abno_shy_look", "lc_abno_scarecrow", "lc_abno_woodsman", "lc_abno_red_hood" }, log = "Her notebook was full of drawings of Abnormalities you'd never worked, with notes in tiny writing: what they like, what they hate, what to never do. You've kept it. You read a page before every new unit." },
			},
			{
				label = "Find Baek and tell him",
				requires = { flags = { "lc_met_baek" } },
				result = { sanity = 3, condition = "grief", relationBond = { kind = "all", amount = 4 }, log = "Baek listened, then took you to the Green Kettle and sat with you until closing. He told you about every name on that wall he'd known. There were a lot of them." },
			},
		},
	},
	{
		id = "lc_mirela_captaincy",
		title = "One Armband",
		text = "The department's Captain is moving up to Central Command, and the armband goes to the longest-serving Agent. That's you or Mirela, by a matter of days, and the Record Team is still counting. She finds you at the Green Kettle. \"Whoever gets it,\" she says, \"no hard feelings. Mostly.\"",
		weight = 40,
		once = true,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 6, world = { era = "wings" }, flags = { "lc_mirela_saved" }, notFlags = { "lcorp_captain" } },
		choices = {
			{
				label = "Tell the Record Team to give it to her",
				result = { sanity = 4, setFlags = { "lc_mirela_captain", "lc_mirela_friend" }, log = "You told Hokma she'd earned it. He wrote that down too. Mirela wore the armband like it might fly away, and made you her second the same afternoon." },
			},
			{
				label = "Make your case to the Record Team",
				hint = "A Charisma check: count every day.",
				clash = { stat = "charisma", foe = "The Record Team's arithmetic", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, log = "You'd served four days longer, it turned out, counting a weekend you'd forgotten you worked. Mirela was the first to shake your hand, and she meant it, mostly." },
				lose = { sanity = -2, setFlags = { "lc_mirela_captain" }, log = "She'd served three days longer. She was very gracious about it, for about a week." },
			},
			{
				label = "Suggest she transfer and take a Captaincy elsewhere",
				hint = "A Mental Strength check: everyone wins, if it works.",
				clash = { stat = "mind", foe = "Two departments' paperwork", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, setFlags = { "lc_mirela_captain", "lc_mirela_friend" }, log = "The Welfare Team needed a Captain too. Mirela took it, and you took yours, and you had a joint celebration at the Green Kettle that the owner still talks about." },
				lose = { sanity = -3, log = "She thought you were trying to get rid of her. It took a month of apologies to fix." },
			},
		},
	},

	-- ── Hyun-woo Baek ──
	{
		id = "lc_baek_retires",
		title = "Baek's Last Shift",
		text = "Hyun-woo Baek is retiring after nineteen years, which nobody in the facility can remember anyone doing. He spends his last shift walking the corridors, saying goodbye to the Clerks by name. At the end of it he finds you, and takes off his Continued Service armband.",
		weight = 30,
		once = true,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 4, world = { era = "wings" }, flags = { "lc_met_baek" } },
		choices = {
			{
				label = "Take the armband",
				result = { addTrait = "lc_steadfast_veteran", sanity = 2, log = "\"Read the file,\" he said, pinning it on you. \"Then read it again.\" He walked out of the lobby without looking back, which is the only way anyone has ever done it." },
			},
			{
				label = "Ask him how he lasted nineteen years",
				result = { mind = 3, codex = { "lc_abno_firebird", "lc_abno_black_swan", "lc_abno_king_greed" }, log = "\"I never volunteered,\" he said. \"I never looked at anything twice. And I read every file twice.\" He gave you his own notes on the three WAWs he'd outlived. They're the most useful thing you own." },
			},
			{
				label = "Throw him a farewell at the Green Kettle",
				hint = "40 Ahn.",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 5, addRelation = { kind = "mentor", name = "Hyun-woo Baek", bond = 65, age = { 48, 54 } }, log = "Half the facility came. Baek cried, once, quietly, when the Clerks sang. He gave you his home address on a napkin. \"Come by,\" he said. \"Tell me who's still alive.\"" },
			},
		},
	},
}
