--[[
	SECOND STORIES: the chapters (Storylines/Second.luau has what each stands on).
	Five chapters each, counted in years from the day the story began: 0, 1, 3, 5, 7.
	The last chapter of each has three endings.

	Short on purpose: a line or two, then the choice. Checks here are `fixed`: they depend on
	your stats, not on your age.

	Nothing here names a thing that only exists in one age.
]]

local function chk(stat: string, foe: string, hard: boolean?)
	return { stat = stat, foe = foe, coins = if hard then 2 else 1, base = 3, coinPower = if hard then 2 else 3, fixed = true }
end
local function fight(foe: string, enemy: string, hard: boolean?)
	return { stat = "strength", foe = foe, enemy = enemy, fight = true, coins = 2, base = if hard then 4 else 3, coinPower = 2, fixed = true }
end

local GN, FP, TS, BH, PR, PT, S7, NT = "sl2_grade_nine", "sl2_fourth_pack", "sl2_ten_seconds", "sl2_borrowed_hours", "sl2_prescript", "sl2_portrait", "sl2_section_seven", "sl2_nest_ticket"

local function beat(story: string, year: number, e)
	e.story = story
	e.always = true
	e.once = true
	e.when = e.when or {}
	e.when.storyYear = year
	return e
end

return {
	-- ════ GRADE NINE ════════════════════════════════════════════════════════════
	beat(GN, 0, {
		id = "sl2_gn_report",
		title = "The Report",
		art = "office",
		text = "Your job report comes back from Hana with a grade it didn't earn. The handwriting on page three isn't yours.",
		choices = {
			{ label = "Ask the Rep", clash = chk("charisma", "A Rep who hasn't slept"), win = { charisma = 1, setFlags = { "sl2_gn_knows" }, goal = "The Rep rewrote your report. Ask what the Office needs it for.", log = "\"Sit down,\" said the Rep. \"And shut the door.\"" }, lose = { sanity = -2, goal = "Somebody rewrote your report. Nobody will say who.", log = "\"Hana must have liked it,\" the Rep said, and went back to the ledger." } },
			{ label = "Check the file copy", clash = chk("intelligence", "An Office's filing"), win = { intelligence = 1, setFlags = { "sl2_gn_knows" }, goal = "The Rep rewrote your report. Ask what the Office needs it for.", log = "Two versions in the drawer. The Rep's pen, the Rep's ink." }, lose = { goal = "Somebody rewrote your report. Nobody will say who.", log = "The file copy was gone. That told you something too." } },
			{ label = "Take the grade", result = { money = 20, sanity = -1, goal = "You kept a grade you didn't earn. It'll want paying for.", log = "A better grade is a better fee. You cashed it." } },
		},
	}),
	beat(GN, 1, {
		id = "sl2_gn_rep",
		title = "Three Desks",
		art = "office",
		text = "The Rep says it plainly: without one more good grade on the books, the Office loses its contracts by winter. Yours was the report that could be improved.",
		choices = {
			{ label = "Go along with it", result = { money = 60, sanity = -3, setFlags = { "sl2_gn_padded" }, goal = "Your grade is a lie the Office lives on. Hana audits in the spring.", log = "You signed the next one yourself. It gets easier, which is the problem." } },
			{ label = "Ask for the real jobs instead", result = { strength = 2, setFlags = { "sl2_gn_earned" }, goal = "You asked to earn it. The Rep found you the jobs nobody wanted.", log = "The Rep looked at you a long time. Then gave you the list from the bottom drawer." } },
			{ label = "Say you won't sign", result = { mind = 2, rep = { fixers = -4 }, goal = "You refused. The Office has until winter.", log = "\"Then we're both honest and out of work,\" the Rep said. Neither of you was sure it was a joke." } },
		},
	}),
	beat(GN, 3, {
		id = "sl2_gn_audit",
		title = "The Examiner",
		art = "office",
		text = "Hana sends an examiner. She reads three years of reports in an afternoon, then asks you to show her what a Fixer of your grade can do.",
		choices = {
			{ label = "Show her", clash = fight("A Hana examiner", "hana_examiner", true), win = { strength = 2, rep = { fixers = 8 }, setFlags = { "sl2_gn_proved" }, goal = "You stood up to Hana's examiner. Other Offices heard.", log = "She wrote one line, turned it round and let you read it: \"Grade stands.\"" }, lose = { health = { -8, -4 }, setFlags = { "sl2_gn_failed" }, goal = "The examiner marked you down. The Office is on notice.", log = "It took her less than a minute. She was polite about it." } },
			{ label = "Tell her all of it", clash = chk("mind", "A straight question", true), win = { mind = 2, setFlags = { "sl2_gn_proved" }, goal = "You told Hana the truth and kept your licence. The Rep didn't.", log = "She listened. She fined the Office and left your name off the fine." }, lose = { sanity = -4, setFlags = { "sl2_gn_failed" }, goal = "The examiner marked you down. The Office is on notice.", log = "You got halfway through and looked at the Rep. The examiner watched you do it." } },
			{ label = "Hold the Office's line", clash = chk("charisma", "Three years of paperwork", true), win = { charisma = 2, money = 80, setFlags = { "sl2_gn_padded" }, goal = "The lie held. It's a bigger lie now.", log = "She stamped it. On the stairs she said, \"I'll be back for the fourth year.\"" }, lose = { sanity = -3, setFlags = { "sl2_gn_failed" }, goal = "The examiner marked you down. The Office is on notice.", log = "She found the two versions of page three in under an hour." } },
		},
	}),
	beat(GN, 5, {
		id = "sl2_gn_offer",
		title = "A Bigger Door",
		art = "street",
		text = "An Office with forty desks sends a man in a good coat. He says a Fixer like you is wasted behind a door with chipped paint.",
		choices = {
			{ label = "Hear the number", result = { intelligence = 1, setFlags = { "sl2_gn_tempted" }, goal = "Forty desks want you. The Rep doesn't know yet.", log = "It was a large number. He let you say it back to him." } },
			{ label = "Tell the Rep first", result = { charisma = 1, sanity = 2, goal = "You told the Rep about the offer. The Rep said to think of yourself.", log = "\"Take it,\" the Rep said. \"I would.\" The Rep wouldn't, and you both knew." } },
			{ label = "Send him away", result = { mind = 1, rep = { fixers = 3 }, goal = "You sent the big Office away. Three desks it is.", log = "He left a card on the windowsill anyway. People like that always do." } },
		},
	}),
	beat(GN, 7, {
		id = "sl2_gn_end",
		title = "What the Grade Says",
		art = "office",
		text = "Seven years of reports with your name on them. Hana's letter is on the desk, and so is the card from the Office with forty desks.",
		choices = {
			{ label = "Stay, and make the grade true", result = { strength = 2, mind = 2, sanity = 4, storyEnd = "Three Desks: you stayed, and earned the grade somebody once wrote in for you", log = "The paint's still chipped. The contracts come in on their own now, and the reports are in your hand." } },
			{ label = "Take the bigger door", result = { money = 300, charisma = 2, sanity = -2, storyEnd = "Forty Desks: you left the Office that made you for one that pays", log = "Your desk is by a window. Nobody here has heard of the Rep. You send a card at New Year." } },
			{ label = "Write to Hana yourself", result = { mind = 3, rep = { fixers = 6 }, storyEnd = "Struck Off and Starting Over: you sent Hana the true reports, all seven years", log = "They took a grade off you and gave you a clean file. The Rep read the letter twice and shook your hand." } },
		},
	}),

	-- ════ THE FOURTH PACK ═══════════════════════════════════════════════════════
	beat(FP, 0, {
		id = "sl2_fp_tank",
		title = "The East Hall",
		art = "wing",
		text = "The tanks run the length of the hall. Every soldier has one. The label on the fourth from the door is your name, and the shape inside it is the right height.",
		choices = {
			{ label = "Ask the technician", clash = chk("charisma", "A technician on a long shift"), win = { intelligence = 1, goal = "It's a spare. \"Everyone has a spare.\" Find out how often they're used.", log = "\"It's your spare,\" she said, as if you'd asked where the canteen was." }, lose = { goal = "Nobody will tell you what's in the tank.", log = "\"Not your clearance,\" she said, and stood so you couldn't see the dial." } },
			{ label = "Put your hand on the glass", result = { mind = 1, sanity = -3, goal = "It's you in there. Find out how often they're used.", log = "It's warm. Whatever's in there has your hands." } },
			{ label = "Keep walking", result = { sanity = 1, goal = "You didn't look. You keep not looking.", log = "Parade was at six. You were on time." } },
		},
	}),
	beat(FP, 1, {
		id = "sl2_fp_brief",
		title = "See You Next Print",
		art = "wing",
		text = "Before the drop, the Rabbit beside you taps your helmet twice. \"See you next print.\" Everybody laughs. It's what they say.",
		choices = {
			{ label = "Say it back", result = { charisma = 1, sanity = -1, goal = "You said it back. It didn't feel like a joke.", log = "It came out easily. That bothered you more than the drop did." } },
			{ label = "Ask how many prints they're on", result = { intelligence = 1, mind = 1, goal = "The Rabbit beside you is on their sixth. They don't remember five of them.", log = "\"Six. I think. They don't tell you unless you ask.\" Then the doors opened." } },
			{ label = "Fight like it's the only one", clash = fight("Whatever the drop was for", "syndicate"), win = { strength = 2, goal = "You came back on your own feet. Not everyone did.", log = "You came back. You counted the ones who didn't, and then you saw them at breakfast." }, lose = { health = { -10, -5 }, goal = "You nearly found out what the tank is for.", log = "A medic got to you first. \"Close one,\" she said. \"Cheaper for everybody.\"" } },
		},
	}),
	beat(FP, 3, {
		id = "sl2_fp_gap",
		title = "The Missing Week",
		art = "clinic",
		text = "You wake in the infirmary feeling very well. The calendar says a week has gone. Your bunkmate tells a story about you that you don't remember being in.",
		choices = {
			{ label = "Ask what happened to you", result = { mind = 1, sanity = -4, setFlags = { "sl2_fp_printed" }, goal = "You're a reprint. The one before you is why you still have a bunk.", log = "\"You went back for the Reindeer,\" he said. \"The other you did. You got her out.\"" } },
			{ label = "Check the tank", result = { intelligence = 1, sanity = -3, setFlags = { "sl2_fp_printed" }, goal = "The tank's been refilled. You're a reprint.", log = "Fourth from the door. Full again, and the label was new." } },
			{ label = "Don't ask", result = { sanity = 2, goal = "A week is missing. You've decided that's fine.", log = "You felt very well. You went to parade." } },
		},
	}),
	beat(FP, 5, {
		id = "sl2_fp_other",
		title = "Two of You",
		art = "wing",
		text = "A filing error, they'll say later. Tonight there's someone at the end of the corridor with your face, your rank, and the same look on it that you've got.",
		choices = {
			{ label = "Talk", clash = chk("charisma", "Yourself", true), win = { charisma = 2, sanity = 2, setFlags = { "sl2_fp_met" }, goal = "There are two of you, and you've agreed which one answers at roll call.", log = "You both started the same sentence. It took an hour to stop doing that." }, lose = { sanity = -4, goal = "There are two of you. The Wing will notice.", log = "Neither of you would say which was the copy." } },
			{ label = "Fight", clash = fight("Someone with your training", "rcorp_rabbit", true), win = { strength = 2, sanity = -5, goal = "One of you walked back to the bunk. You think it was you.", log = "You know all your own openings. So did they." }, lose = { health = { -10, -5 }, sanity = -3, goal = "The other one took your bunk. You're the spare now.", log = "You woke in the infirmary. Somebody else answered to your name that morning." } },
			{ label = "Report it", result = { intelligence = 1, rep = { wings = 4 }, sanity = -2, goal = "You reported the error. In the morning there was one of you.", log = "They thanked you. In the morning there was one of you, and nobody said which." } },
		},
	}),
	beat(FP, 7, {
		id = "sl2_fp_end",
		title = "Roll Call",
		art = "wing",
		text = "Your contract with the Fourth Pack is up for renewal. The form has one line that matters: whether to keep a spare on file.",
		choices = {
			{ label = "Sign, and keep the spare", result = { strength = 2, money = 200, sanity = -2, storyEnd = "Next Print: you signed again, and stopped counting which one you are", log = "You tap the new ones on the helmet now. \"See you next print.\" They laugh. So do you." } },
			{ label = "Sign, and have the tank emptied", result = { mind = 3, sanity = 3, storyEnd = "The Only One: you stayed a soldier and had your spare let go", log = "The technician read the form twice. \"You know what that means.\" You did. That was the point." } },
			{ label = "Walk out of the gate", result = { quitCareer = true, mind = 2, sanity = 5, storyEnd = "Whichever One This Is: you left R Corp with one body and no backup", log = "Nobody stopped you. Somewhere behind you, fourth from the door, a label is being changed." } },
		},
	}),

	-- ════ TEN SECONDS ═══════════════════════════════════════════════════════════
	beat(TS, 0, {
		id = "sl2_ts_doors",
		title = "The Doors",
		art = "train",
		text = "The train pulls in on time. From the platform it was ten seconds. Your crew chief says, \"For them it wasn't,\" and opens the first carriage.",
		choices = {
			{ label = "Go in first", clash = fight("What a passenger became", "passenger"), win = { strength = 1, mind = 1, goal = "You cleared a carriage. Tomorrow the passengers walk off smiling.", log = "It had a ticket in what used to be a pocket. You didn't read it." }, lose = { health = { -8, -4 }, sanity = -3, goal = "The carriage nearly had you. Tomorrow the passengers walk off smiling.", log = "The chief pulled you out by the collar. \"Everybody's first one goes like that.\"" } },
			{ label = "Follow the chief", result = { intelligence = 1, sanity = -3, goal = "You watched how it's done. Tomorrow the passengers walk off smiling.", log = "You held the lamp. You learned where to look and where not to." } },
			{ label = "Read a ticket", result = { mind = 1, sanity = -5, setFlags = { "sl2_ts_read" }, goal = "You read a name. Tomorrow that name walks off the train smiling.", log = "Seat 14. A name, a destination. Everyone told you not to." } },
		},
	}),
	beat(TS, 1, {
		id = "sl2_ts_restored",
		title = "Have a Pleasant Journey",
		art = "train",
		text = "After the crew is done, the Wing does its part, and the passengers step off exactly as they got on. One of them stops to thank you for holding the door.",
		choices = {
			{ label = "Say \"You're welcome\"", result = { charisma = 1, sanity = -2, goal = "They don't remember. That's what the ticket price buys.", log = "She smiled. She'd been in there longer than you've been alive." } },
			{ label = "Ask how the ride was", result = { mind = 1, goal = "\"Quick,\" she said. \"You hardly notice.\"", log = "\"Quick. You hardly notice.\" She checked her watch against the station clock and was pleased." } },
			{ label = "Look for seat 14", requires = { flags = { "sl2_ts_read" } }, result = { mind = 2, sanity = -3, goal = "Seat 14 got off the train and bought a newspaper.", log = "A man with a briefcase. He bought a paper and complained about the price." } },
		},
	}),
	beat(TS, 3, {
		id = "sl2_ts_first_class",
		title = "The One Who Remembers",
		art = "underpass",
		text = "A man is waiting by the crew door. Expensive coat, hands that won't keep still. He says he rides twice a week, and lately he wakes up knowing things about corridors.",
		choices = {
			{ label = "Tell him what he's remembering", result = { mind = 2, sanity = -2, setFlags = { "sl2_ts_told" }, goal = "You told a passenger the truth. He's stopped riding. The Wing has noticed.", log = "He sat down on the kerb. After a while he asked how long. You told him that too." } },
			{ label = "Tell him it's only dreams", clash = chk("charisma", "A man who half knows", true), win = { charisma = 2, money = 50, goal = "He believed you. He tips the crew now.", log = "He wanted to believe it. He pressed money on you for the kindness." }, lose = { sanity = -3, goal = "He didn't believe you. He keeps coming back.", log = "\"You're a bad liar,\" he said. \"I'd know. I've had the time to practise.\"" } },
			{ label = "Report him to the Wing", result = { rep = { wings = 5 }, sanity = -4, goal = "You reported a passenger. He rides again, and doesn't recognise you.", log = "He rode the next morning. He held the door for you and didn't know your face." } },
		},
	}),
	beat(TS, 5, {
		id = "sl2_ts_ticket",
		title = "A Seat by the Window",
		art = "train",
		text = "Staff tickets come round once a year: one free ride, anywhere on the line. Ten seconds and you'd be in a District you've never seen.",
		choices = {
			{ label = "Ride", result = { mind = 2, sanity = -6, setFlags = { "sl2_ts_rode" }, goal = "You rode. You feel fine. You're told you would.", log = "The doors closed. The doors opened. Your crew were on the platform, not looking at you." } },
			{ label = "Give the ticket away", result = { charisma = 1, sanity = -2, goal = "You gave your ticket to someone who wanted it.", log = "A neighbour's cousin, off to see her mother. You told her it was quick. It is." } },
			{ label = "Tear it up", result = { mind = 1, sanity = 2, goal = "You tore up the ticket. The chief did the same, every year.", log = "The chief watched you do it and said nothing, and bought you breakfast." } },
		},
	}),
	beat(TS, 7, {
		id = "sl2_ts_end",
		title = "On Time",
		art = "train",
		text = "Seven years on the crew. The trains have never once been late, and there's a new hire by the door asking what's in the carriages.",
		choices = {
			{ label = "\"Don't read the tickets.\"", result = { mind = 2, strength = 2, storyEnd = "Crew Chief: you tell the new ones not to read the tickets", log = "You open the first carriage yourself. It's on time. It's always on time." } },
			{ label = "Tell them everything, then quit", result = { quitCareer = true, mind = 3, sanity = 4, storyEnd = "Platform Side: you left the cleanup crew and never rode the line", log = "You walk now. It takes four hours to cross the District. You count every one of them." } },
			{ label = "Ask for a transfer upstairs", clash = chk("intelligence", "W Corp's forms"), win = { intelligence = 2, money = 250, storyEnd = "Upstairs: you moved to the offices that set the timetable", log = "A desk, a window, a timetable. The numbers are very clean from up here." }, lose = { sanity = -2, storyEnd = "Crew Chief: you tell the new ones not to read the tickets", log = "They said the crew couldn't spare you. You went back down." } },
		},
	}),

	-- ════ BORROWED HOURS ════════════════════════════════════════════════════════
	beat(BH, 0, {
		id = "sl2_bh_arrears",
		title = "Arrears",
		art = "street",
		text = "The collector doesn't raise his voice. Two years signed over, interest unpaid. He can take it in Ahn today, or in time, which he has the equipment for.",
		choices = {
			{ label = "Pay in Ahn", requires = { min = { money = 80 } }, result = { money = -80, goal = "You paid this quarter's interest. There are a great many quarters.", log = "He counted it twice and gave you a receipt with the hour stamped on it." } },
			{ label = "Talk him into waiting", clash = chk("charisma", "A T Corp collector"), win = { charisma = 1, goal = "The collector gave you a month. He wrote down the minute it ends.", log = "\"One month,\" he said, and wrote the minute on his cuff." }, lose = { health = { -5, -3 }, goal = "The collector took it in time. You felt it.", log = "It didn't hurt. You were simply a little older when he closed the case." } },
			{ label = "Refuse", clash = fight("A T Corp collector", "tcorp_collector"), win = { strength = 1, rep = { wings = -6 }, goal = "You sent a T Corp collector away. They send a different one next.", log = "He picked up his hat. \"That's added to the account,\" he said." }, lose = { health = { -9, -5 }, goal = "The collector took it in time, and something for his trouble.", log = "You don't remember the next hour. He does: it's his now." } },
		},
	}),
	beat(BH, 1, {
		id = "sl2_bh_counter",
		title = "The Counter",
		art = "hall",
		text = "At the Time counter a clerk explains your options with a pencil. Sell more now and clear the interest. Or buy back what you sold, at four times the price.",
		choices = {
			{ label = "Sell another year", result = { money = 220, health = { -8, -5 }, sanity = -3, setFlags = { "sl2_bh_sold" }, goal = "You sold another year. The account is clear and you're tired.", log = "You stood up from the chair with money in your hand and grey at your temples." } },
			{ label = "Start buying it back", requires = { min = { money = 120 } }, result = { money = -120, mind = 1, setFlags = { "sl2_bh_buying" }, goal = "You've bought back one month. Twenty-three to go.", log = "One month, in a sealed envelope. It weighed nothing. You kept it in your coat." } },
			{ label = "Read the contract", clash = chk("intelligence", "T Corp's small print"), win = { intelligence = 2, setFlags = { "sl2_bh_clause" }, goal = "There's a clause: time lent to T Corp can be claimed back by blood. Find out whose you're owed.", log = "Clause nine. Time signed over by a parent can be claimed by the child. Yours signed too." }, lose = { sanity = -1, goal = "The contract is forty pages. You got to page six.", log = "The clerk took it back at closing. \"It's all standard.\"" } },
		},
	}),
	beat(BH, 3, {
		id = "sl2_bh_stopped",
		title = "A Stopped Street",
		art = "street",
		text = "Halfway down your street a neighbour stands mid-step with her shopping, not moving, not breathing. A T Corp seal is on her door. Repossessed.",
		choices = {
			{ label = "Pay her arrears", requires = { min = { money = 100 } }, result = { money = -100, charisma = 2, sanity = 4, setFlags = { "sl2_bh_paid_her" }, goal = "You paid a neighbour's time back. She finished her step.", log = "She finished the step, looked at the sky and asked why it was dark. You carried the shopping." } },
			{ label = "Stay with her till the collectors come", result = { mind = 2, sanity = -3, goal = "You waited with a stopped woman. The collectors moved her to a warehouse.", log = "They were careful with her. They're careful with everything they own." } },
			{ label = "Walk past, like everyone", result = { sanity = -2, goal = "You walked past. So will they, when it's you.", log = "Everyone on the street has a reason. You have one too." } },
		},
	}),
	beat(BH, 5, {
		id = "sl2_bh_vault",
		title = "Where It's Kept",
		art = "wing",
		text = "A warehouse clerk owes you a favor, or says so. He can get you eleven minutes alone on the floor where the District's hours are shelved, yours among them.",
		choices = {
			{ label = "Take yours back", clash = chk("speed", "Eleven minutes and a great many shelves", true), win = { speed = 2, health = { 6, 10 }, setFlags = { "sl2_bh_stole" }, goal = "You stole your own two years back. T Corp will count the shelves.", log = "Row forty, your own name. You felt them go back in on the stairs." }, lose = { sanity = -4, rep = { wings = -8 }, goal = "They caught you on the warehouse floor. It's on the account.", log = "The lights came on at minute nine." } },
			{ label = "Claim by clause nine", requires = { flags = { "sl2_bh_clause" } }, result = { intelligence = 2, health = { 4, 8 }, setFlags = { "sl2_bh_claimed" }, goal = "You claimed your parent's hours, by the book. T Corp paid.", log = "It took a morning and three stamps. They don't like it. They honoured it." } },
			{ label = "Leave it on the shelf", result = { mind = 2, goal = "You left your hours where they are. You know which row.", log = "You stood at the door and didn't go in. The clerk said most people don't." } },
		},
	}),
	beat(BH, 7, {
		id = "sl2_bh_end",
		title = "Closing the Account",
		art = "hall",
		text = "The clerk slides the last form across. Your account can close today, one way or another.",
		choices = {
			{ label = "Pay what's left", requires = { min = { money = 150 } }, result = { money = -150, sanity = 6, mind = 2, storyEnd = "Paid in Full: you bought every hour back, at T Corp's price", log = "A receipt with the minute stamped on it. You walked home slowly, because you could." } },
			{ label = "Sign the rest away", result = { money = 300, health = { -12, -8 }, storyEnd = "A Year Lighter: you sold what was left and called it even", log = "They gave you a good price. You look like your father did at this age. Older, a little." } },
			{ label = "Take a job behind the counter", result = { career = "wg_tcorp", intelligence = 2, storyEnd = "On T Corp's Clock: you went to work for the people you owed", log = "Staff don't pay interest. You turn the dial for other people now, and you're gentle about it." } },
		},
	}),

	-- ════ THE PRESCRIPT ═════════════════════════════════════════════════════════
	beat(PR, 0, {
		id = "sl2_pr_slip",
		title = "The Slip",
		art = "street",
		text = "The Messenger is very polite. The slip says: \"On the ninth, leave your door unlocked from dusk until morning.\" Nothing else.",
		choices = {
			{ label = "Do it", result = { mind = 1, sanity = -3, setFlags = { "sl2_pr_obeyed" }, goal = "You did what the slip said. Nothing came in. Another slip will.", log = "You sat up all night facing the door. Nothing came. In the morning the slip was gone from the table." } },
			{ label = "Lock it anyway", result = { sanity = 1, setFlags = { "sl2_pr_refused" }, goal = "You ignored a Prescript. The Index keeps count.", log = "You locked it twice. In the morning there was a second slip under it: \"Noted.\"" } },
			{ label = "Ask the Messenger why", clash = chk("charisma", "A Messenger of the Index"), win = { intelligence = 1, goal = "\"We don't write them,\" the Messenger said. \"We only carry them.\"", log = "\"Nobody knows why. That's rather what makes it a Prescript.\" She seemed sorry for you." }, lose = { goal = "The Messenger doesn't answer questions.", log = "She bowed and went to the next door." } },
		},
	}),
	beat(PR, 1, {
		id = "sl2_pr_second",
		title = "The Coat",
		art = "street",
		text = "A second slip: \"Give your coat to the first person who asks you for the time.\" It's the middle of winter. Before noon, a stranger asks you for the time.",
		choices = {
			{ label = "Hand it over", result = { health = { -4, -2 }, mind = 1, setFlags = { "sl2_pr_obeyed" }, goal = "Two Prescripts carried out. They're getting larger.", log = "He took it without surprise, as if he'd had a slip of his own." } },
			{ label = "Tell him the time and walk on", result = { sanity = -2, setFlags = { "sl2_pr_refused" }, goal = "You've refused the Index twice. A Proxy has your address.", log = "You were warm all the way home. There was a white coat at the end of your street." } },
			{ label = "Buy a cheap coat and give that", requires = { min = { money = 25 } }, result = { money = -25, intelligence = 1, goal = "You followed the letter of a Prescript. The Index hasn't said if that counts.", log = "The slip said \"your coat\". It's yours if you paid for it. You hope." } },
		},
	}),
	beat(PR, 3, {
		id = "sl2_pr_proxy",
		title = "The Proxy",
		art = "alley",
		text = "A Proxy of the Index is waiting on your stairs with a ledger. She reads out every slip you've been sent, and what you did about each.",
		choices = {
			{ label = "Answer for it", clash = chk("mind", "A Proxy's ledger", true), win = { mind = 2, goal = "The Proxy closed the ledger. \"Sufficient.\"", log = "She closed the ledger. \"Sufficient.\" Coming from them, that's warm." }, lose = { sanity = -5, goal = "The Proxy wasn't satisfied. The next slip will be a test.", log = "She underlined something. You weren't shown what." } },
			{ label = "Fight her", clash = fight("A Proxy of the Index", "index_proxy", true), win = { strength = 2, rep = { index = -15 }, setFlags = { "sl2_pr_refused" }, goal = "You beat a Proxy. Nobody does that twice.", log = "She picked up her ledger. \"It did not say this,\" she said, puzzled, and left." }, lose = { health = { -12, -6 }, goal = "The Proxy corrected you. The next slip will be a test.", log = "It was precise. She apologised for the stairs." } },
			{ label = "Ask what happens to people who obey", result = { intelligence = 1, goal = "\"They are spared the trouble of deciding,\" the Proxy said.", log = "\"They are spared the trouble of deciding.\" She meant it kindly." } },
		},
	}),
	beat(PR, 5, {
		id = "sl2_pr_cannot",
		title = "The One You Can't",
		art = "home",
		text = "The slip is longer this time. It names your neighbour across the landing, an hour, and says only: \"Do not warn them.\"",
		choices = {
			{ label = "Warn them", result = { charisma = 1, sanity = 3, rep = { index = -12 }, setFlags = { "sl2_pr_refused", "sl2_pr_warned" }, goal = "You warned your neighbour. They were gone by the hour. So is your standing with the Index.", log = "They left with one bag. They didn't thank you. There wasn't time." } },
			{ label = "Say nothing", result = { mind = 1, sanity = -8, setFlags = { "sl2_pr_obeyed" }, goal = "You said nothing. The landing is quiet now.", log = "You heard the hour come and go through the wall. In the morning the door across the landing was open." } },
			{ label = "Be on the landing at that hour", clash = fight("Whoever the hour was for", "index_proxy", true), win = { strength = 2, sanity = 2, rep = { index = -15 }, setFlags = { "sl2_pr_refused", "sl2_pr_warned" }, goal = "You stood on the landing. The Prescript went unfulfilled.", log = "The slip never said you couldn't be standing there." }, lose = { health = { -12, -6 }, sanity = -4, goal = "You stood on the landing. It wasn't enough.", log = "You woke on the stairs. The door across the landing was open." } },
		},
	}),
	beat(PR, 7, {
		id = "sl2_pr_end",
		title = "The Last Slip",
		art = "street",
		text = "The Messenger is older. So are you. The slip has one line: \"Choose.\" She waits, which they never do.",
		choices = {
			{ label = "Keep following them", result = { mind = 3, sanity = -3, storyEnd = "As Written: you did what the slips said, to the end", log = "It's restful, in its way. You haven't made a decision in years. You're not sure you'd know how." } },
			{ label = "Tear it in half", result = { strength = 2, sanity = 5, rep = { index = -10 }, storyEnd = "Unwritten: you tore up the last Prescript on your own doorstep", log = "The Messenger looked at the two halves for a long time. Then she bowed, lower than before." } },
			{ label = "Ask for the white coat", result = { career = "index", mind = 2, storyEnd = "A Proselyte's Whites: you joined the hand that had been writing to you", log = "They had a coat in your size. They'd had it for seven years." } },
		},
	}),

	-- ════ THE PORTRAIT ══════════════════════════════════════════════════════════
	beat(PT, 0, {
		id = "sl2_pt_sitting",
		title = "The First Sitting",
		art = "theater",
		text = "The Docent's studio is very clean. They ask you to sit, and to think of the worst day you can remember. \"Hold that. Yes. That.\"",
		choices = {
			{ label = "Sit for it", result = { money = 60, sanity = -3, mind = 1, setFlags = { "sl2_pt_sat" }, goal = "You sat for a Docent of the Ring. They want you back.", log = "Three hours. They paid in new notes and said you were \"very generous with it\"." } },
			{ label = "Ask to see their other work", clash = chk("intelligence", "A studio with a locked room"), win = { intelligence = 2, sanity = -2, goal = "You saw the Docent's other portraits. None of the sitters come back to visit.", log = "They were very good. Every one looked like the worst day of somebody's life." }, lose = { money = 30, goal = "The Docent showed you nothing and paid for your time.", log = "\"When yours is finished,\" they said, and paid you for coming." } },
			{ label = "Leave", result = { sanity = 2, goal = "You walked out of a Ring studio. They sent flowers.", log = "They sent flowers the next day, and a card: \"Whenever you're ready.\"" } },
		},
	}),
	beat(PT, 1, {
		id = "sl2_pt_sketch",
		title = "The Sketch",
		art = "theater",
		text = "They show you the charcoal study. It looks more like you than you do. People who've seen it have started looking at you oddly in the street.",
		choices = {
			{ label = "Sit again", result = { money = 90, sanity = -4, charisma = 1, setFlags = { "sl2_pt_sat" }, goal = "Second sitting done. You're a little harder to recognise, each time.", log = "You went home and your own mirror took a moment." } },
			{ label = "Ask for the sketch", clash = chk("charisma", "A Docent with a finished study", true), win = { charisma = 2, setFlags = { "sl2_pt_has_sketch" }, goal = "You have the sketch. The Docent wants it back for the exhibition.", log = "They wrapped it in tissue, slowly, like handing over a child." }, lose = { sanity = -2, goal = "The sketch stays in the studio.", log = "\"It isn't yours,\" they said gently. \"It's of you. That's different.\"" } },
			{ label = "Stop going", result = { mind = 1, goal = "You stopped going to the studio. The portrait isn't finished. They mind.", log = "A Student of the Ring started standing across from your door with a sketchbook." } },
		},
	}),
	beat(PT, 3, {
		id = "sl2_pt_exhibition",
		title = "The Exhibition",
		art = "hall",
		text = "It hangs in a white room, under a lamp. People stand in front of it for a long time. Some of them turn round and look at you, and step back.",
		choices = {
			{ label = "Stand beside it", result = { charisma = 2, sanity = -5, money = 120, goal = "You stood by your portrait all evening. They paid you an appearance fee.", log = "You could feel which one of you they preferred." } },
			{ label = "Take it off the wall", clash = fight("A Student of the Ring", "ring_artist", true), win = { strength = 2, rep = { ring = -15 }, setFlags = { "sl2_pt_took" }, goal = "You took your portrait out of a Ring exhibition. They're calling that part of the piece.", log = "You carried it home under your arm. The Docent applauded, which was the worst part." }, lose = { health = { -8, -4 }, sanity = -3, goal = "The Students wouldn't let you near it.", log = "\"Don't touch the art,\" a Student said, to the wrong one of you." } },
			{ label = "Leave before the speeches", result = { sanity = -1, mind = 1, goal = "You left your own exhibition early.", log = "Behind you somebody said, \"Is that the model? I thought they'd be taller.\"" } },
		},
	}),
	beat(PT, 5, {
		id = "sl2_pt_student",
		title = "Finishing Touches",
		art = "alley",
		text = "A Student of the Ring is on your landing with a case of tools. The Docent feels the piece is nearly complete. It only needs the original brought in line with it.",
		choices = {
			{ label = "Fight", clash = fight("A Student of the Ring", "ring_artist", true), win = { strength = 2, rep = { ring = -10 }, goal = "You sent the Student back to the studio with their case shut.", log = "The Student seemed more disappointed than hurt." }, lose = { health = { -12, -6 }, sanity = -4, condition = "deep_cut", goal = "The Student made a start. You got away before the second colour.", log = "You got out by the window. You'll carry the first line of it." } },
			{ label = "Talk them out of it", clash = chk("charisma", "An artist with a vision", true), win = { charisma = 2, goal = "You convinced the Student the piece is better unfinished.", log = "\"An open question,\" the Student said, slowly. \"Yes. The Docent will hate that.\" They left delighted." }, lose = { sanity = -4, goal = "The Student will be back with the Docent.", log = "\"I'll fetch the Docent,\" the Student said. \"They explain it better.\"" } },
			{ label = "Run", clash = chk("speed", "Four flights and a locked gate"), win = { speed = 2, goal = "You outran the Ring for one night.", log = "You know every roof on this street. The Student didn't." }, lose = { health = { -6, -3 }, sanity = -3, goal = "You got away, barely.", log = "The gate was locked. You went over it the hard way." } },
		},
	}),
	beat(PT, 7, {
		id = "sl2_pt_end",
		title = "The Frame",
		art = "theater",
		text = "The Docent has grown old waiting. The portrait is still on its easel, one corner bare. They hold the brush out to you. \"You finish it. You always should have.\"",
		choices = {
			{ label = "Finish it, as you are now", result = { charisma = 3, sanity = 4, storyEnd = "Signed: you painted the last corner of your own portrait, and it looks like you again", log = "You're no painter. It's the best part of the picture. The Docent wept, which they do easily." } },
			{ label = "Put your foot through it", result = { strength = 2, sanity = 6, rep = { ring = -10 }, storyEnd = "The Frame Is Empty: you destroyed the portrait the Ring made of you", log = "The Docent picked up the pieces. \"Second version,\" they said, already interested." } },
			{ label = "Leave it bare", result = { mind = 3, storyEnd = "Unfinished: you left your portrait with one corner unpainted, for good", log = "It hangs that way still. People ask what the blank corner means. Nobody has it right." } },
		},
	}),

	-- ════ SECTION SEVEN ═════════════════════════════════════════════════════════
	beat(S7, 0, {
		id = "sl2_s7_file",
		title = "The Empty Floor",
		art = "home",
		text = "Eleven rooms on one floor, and nobody in them. Plates on the tables. Coats on the hooks. A woman on the stairs says her son is one of the eleven.",
		choices = {
			{ label = "Knock on every other door", clash = chk("charisma", "A building that saw nothing"), win = { charisma = 1, setFlags = { "sl2_s7_lead" }, goal = "All eleven answered the same notice: paid work, a clinic, three days.", log = "The fourth floor remembered a notice on the board. Paid work. A clinic. Three days." }, lose = { goal = "Nobody in the building saw anything. Try the paper.", log = "Everybody was asleep, everybody was out. One door didn't open and the light was on." } },
			{ label = "Go through the rooms", clash = chk("intelligence", "Eleven rooms left in a hurry"), win = { intelligence = 1, setFlags = { "sl2_s7_lead" }, goal = "All eleven kept the same handbill: paid work, a clinic, three days.", log = "The same handbill in nine rooms out of eleven. Somebody had folded theirs very small." }, lose = { goal = "The rooms told you nothing. Try the neighbours.", log = "Eleven ordinary rooms. You don't yet know what ordinary is hiding." } },
			{ label = "Take her statement", result = { mind = 1, goal = "Her son went out for \"three days' work\" and didn't take his coat.", log = "\"Three days, he said. He didn't even take his coat.\" You wrote it down." } },
		},
	}),
	beat(S7, 1, {
		id = "sl2_s7_pattern",
		title = "The Same Notice",
		art = "office",
		text = "You pin up a map. This floor isn't the first. Four tenements in two Districts, all with the same handbill on the board the week before.",
		choices = {
			{ label = "Find the printer", clash = chk("intelligence", "A paper trail"), win = { intelligence = 2, setFlags = { "sl2_s7_address" }, goal = "The handbills were paid for by a clinic with a Wing's stamp on the door.", log = "A print shop, an invoice, an address. A clinic. A stamp you recognise." }, lose = { sanity = -1, goal = "The paper trail stops at a print shop that burned.", log = "The print shop burned last month. The owner sounded relieved." } },
			{ label = "Answer the notice yourself", result = { mind = 1, sanity = -2, setFlags = { "sl2_s7_address", "sl2_s7_inside" }, goal = "You answered the notice. You have an appointment and an address.", log = "A pleasant voice took your name and asked if you had family. You said no." } },
			{ label = "Ask Seven for the file", result = { charisma = 1, rep = { fixers = 2 }, goal = "The Seven Association has a file on this. It's thicker than yours and it's sealed.", log = "\"Where did you hear that name?\" the Section clerk asked. Then: \"Leave it with us.\" You didn't." } },
		},
	}),
	beat(S7, 3, {
		id = "sl2_s7_clinic",
		title = "The Clinic",
		art = "clinic",
		text = "A clean building on a dirty street. No sign. A guard at the door who is paid much too well to be guarding a clinic.",
		choices = {
			{ label = "Go through the guard", clash = fight("A very well paid guard", "wing_guard", true), win = { strength = 2, setFlags = { "sl2_s7_list" }, goal = "You got inside. There's a list, and the eleven are on it.", log = "Past the guard: a ward, eleven beds, and a clipboard on each." }, lose = { health = { -10, -5 }, goal = "The guard put you back on the street.", log = "He was good. He put you down gently, which was insulting." } },
			{ label = "Walk in like staff", clash = chk("charisma", "A front desk", true), win = { charisma = 2, setFlags = { "sl2_s7_list" }, goal = "You got inside. There's a list, and the eleven are on it.", log = "A white coat off a hook and a clipboard. Nobody stops a clipboard." }, lose = { sanity = -3, goal = "The front desk has your description now.", log = "\"I don't know your face,\" the nurse said, and reached under the desk." } },
			{ label = "Go over the back wall at shift change", clash = chk("speed", "A wall and ninety seconds", true), win = { speed = 2, setFlags = { "sl2_s7_list" }, goal = "You got inside. There's a list, and the eleven are on it.", log = "Ninety seconds. You were through the laundry door at eighty." }, lose = { health = { -6, -3 }, goal = "The wall has glass on top. Now you know.", log = "The wall had glass along the top. You found out with both hands." } },
		},
	}),
	beat(S7, 5, {
		id = "sl2_s7_list",
		title = "The List",
		art = "office",
		text = "You have it on your desk: names, dates, and a column headed OUTCOME. Most of the column says the same word. One name, near the bottom, is someone you know.",
		choices = {
			{ label = "Take it to Hana", result = { intelligence = 1, rep = { fixers = 6 }, setFlags = { "sl2_s7_filed" }, goal = "You filed the list with Hana. They thanked you and sealed it.", log = "The clerk read the first page, went white and fetched someone senior. You got a receipt." } },
			{ label = "Take it to the mother", result = { charisma = 1, sanity = -4, setFlags = { "sl2_s7_told" }, goal = "You told her what the column said next to her son's name.", log = "She read his line twice. Then she asked what the word meant, and you told her." } },
			{ label = "Go back for the ones still in beds", clash = fight("The clinic's night staff", "wing_guard", true), win = { strength = 2, sanity = 4, setFlags = { "sl2_s7_freed" }, goal = "You brought three people out of the clinic alive.", log = "Three could walk. You carried a fourth to the corner, and she walked the rest." }, lose = { health = { -12, -6 }, sanity = -3, goal = "You went back alone. It wasn't enough.", log = "They'd moved the beds. They were waiting for you instead." } },
		},
	}),
	beat(S7, 7, {
		id = "sl2_s7_end",
		title = "Case Closed",
		art = "office",
		text = "The clinic is an empty building now. Nobody was charged with anything. The file is still on your desk, and a new handbill went up on a board across the District this morning.",
		choices = {
			{ label = "Open a new file", result = { intelligence = 3, mind = 2, storyEnd = "Still Looking: you opened a second file the day the first one closed", log = "Same paper. Same wording. A different address. You pin it up beside the first." } },
			{ label = "Close it and take the fee", result = { money = 250, sanity = -3, storyEnd = "Sealed by Hana: you were paid, and the file was closed", log = "A good fee. The mother's share of it came back unopened." } },
			{ label = "Give the file to every board in the District", result = { charisma = 3, sanity = 4, rep = { wings = -8 }, storyEnd = "Pinned Up: you put the list on every notice board you could reach", log = "By evening every handbill in the District had a second sheet pinned over it. Yours." } },
		},
	}),

	-- ════ A TICKET TO THE NEST ══════════════════════════════════════════════════
	beat(NT, 0, {
		id = "sl2_nt_clerk",
		title = "Three Ways In",
		art = "checkpoint",
		text = "The clerk counts them on her fingers. A Wing job, which takes an examination. A sponsor inside, which takes a favor. Or papers, which take money and nerve.",
		choices = {
			{ label = "The examination", result = { intelligence = 1, setFlags = { "sl2_nt_exam" }, goal = "The Nest examination is in a year. Study.", log = "She gave you the reading list. It was four pages, both sides." } },
			{ label = "A sponsor", result = { charisma = 1, setFlags = { "sl2_nt_sponsor" }, goal = "You need someone inside the Nest to vouch for you. Find one who needs something.", log = "\"Somebody inside who'll sign for you. They'll want something. They always do.\"" } },
			{ label = "Papers", requires = { min = { money = 100 } }, result = { money = -100, sanity = -2, setFlags = { "sl2_nt_papers" }, goal = "You've paid for false papers. They'll be ready in a year.", log = "She didn't write a receipt. \"A year. Don't come back before.\"" } },
		},
	}),
	beat(NT, 1, {
		id = "sl2_nt_exam",
		title = "A Year of Evenings",
		art = "school",
		text = "The year went on reading lists, favors, or waiting. Tonight is the night it's supposed to pay.",
		choices = {
			{ label = "Sit the examination", clash = chk("intelligence", "Four pages, both sides", true), win = { intelligence = 2, setFlags = { "sl2_nt_passed" }, goal = "You passed. A Wing clerk's desk is waiting, past the gate.", log = "Passed. Not well, but the certificate doesn't say that." }, lose = { sanity = -3, goal = "You failed the examination. There are other ways in.", log = "Two marks short. The invigilator said, \"There's always next year,\" to the whole room." } },
			{ label = "Do the sponsor's favor", clash = chk("charisma", "A favor nobody else would do", true), win = { charisma = 2, setFlags = { "sl2_nt_passed" }, goal = "Your sponsor signed. Your name is on a list at the gate.", log = "It took a week and you'd rather not say what it was. They signed." }, lose = { sanity = -3, goal = "The favor went wrong. Your sponsor doesn't know you.", log = "They'd never heard of you, they said, through the door." } },
			{ label = "Collect the papers", requires = { flags = { "sl2_nt_papers" } }, result = { mind = 1, setFlags = { "sl2_nt_passed", "sl2_nt_false" }, goal = "You have papers that say you belong in the Nest. Don't let anyone look closely.", log = "Good work. A name that's nearly yours and a birthday that isn't." } },
		},
	}),
	beat(NT, 3, {
		id = "sl2_nt_gate",
		title = "The Checkpoint",
		art = "checkpoint",
		text = "The gate is shorter than you imagined. A guard, a lamp, a desk. On the other side the street is lit, and it's two in the morning.",
		choices = {
			{ label = "Hand over your papers", clash = chk("mind", "A guard reading slowly", true), win = { mind = 2, side = "nest", sanity = 4, setFlags = { "sl2_nt_in" }, goal = "You're in the Nest. The lights stay on all night.", log = "He read every line. Then he lifted the bar." }, lose = { sanity = -4, goal = "The guard sent you back. Try again another way.", log = "\"Not tonight,\" he said, and kept the papers." } },
			{ label = "Talk your way through", clash = chk("charisma", "A guard who's heard everything", true), win = { charisma = 2, side = "nest", sanity = 3, setFlags = { "sl2_nt_in" }, goal = "You're in the Nest. The lights stay on all night.", log = "By the end he was telling you about his daughter. The bar was already up." }, lose = { sanity = -3, goal = "The guard sent you back. Try again another way.", log = "He'd heard it. He'd heard a better version last week." } },
			{ label = "Turn round", result = { mind = 1, sanity = 1, goal = "You stood at the gate and went home.", log = "You stood there until the guard asked if you were lost. You said no, and you weren't." } },
		},
	}),
	beat(NT, 5, {
		id = "sl2_nt_inside",
		title = "Lit All Night",
		art = "nest",
		text = "Whichever side of the wall you're on, a letter comes from the other. Someone you grew up beside wants to know if you can get them through too.",
		choices = {
			{ label = "Help them", clash = chk("charisma", "A second favor at the same gate", true), win = { charisma = 2, sanity = 4, setFlags = { "sl2_nt_helped" }, goal = "You got someone else through the gate.", log = "You were at the gate at two in the morning, on the lit side this time." }, lose = { sanity = -3, money = { -60, -30 }, goal = "You tried to bring someone through. It cost you.", log = "The guard remembered you. That turned out to be a bad thing." } },
			{ label = "Send money instead", requires = { min = { money = 60 } }, result = { money = -60, sanity = 1, goal = "You sent money across the wall.", log = "You sent what you could. They wrote back, shorter than before." } },
			{ label = "Don't answer", result = { sanity = -3, mind = 1, goal = "You didn't answer the letter.", log = "You kept it in a drawer. You know exactly which drawer." } },
		},
	}),
	beat(NT, 7, {
		id = "sl2_nt_end",
		title = "A Door With a Real Lock",
		art = "nest",
		text = "Years on, you stand at the wall at the hour the Backstreets go quiet, and listen.",
		choices = {
			{ label = "Stay on the lit side", result = { side = "nest", sanity = 5, intelligence = 2, storyEnd = "A Door With a Real Lock: you made a life inside the Nest and kept it", log = "You sleep through three in the morning now. It took years. Some nights you still wake at ten past." } },
			{ label = "Go home", result = { side = "backstreets", sanity = 3, mind = 3, storyEnd = "Where You Were Born: you saw the Nest, and went back to the Backstreets by choice", log = "The clerk thought you were mad. Your old street set a place for you without being asked." } },
			{ label = "Take the clerk's job", result = { career = "nest_clerk", charisma = 2, storyEnd = "Three Ways In: you sit at the desk now, counting them off on your fingers", log = "A Wing job, a sponsor, or papers. You say it kindly. You leave out which one you used." } },
		},
	}),
}
