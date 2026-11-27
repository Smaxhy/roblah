--[[
	Office life, Grade 9 to Grade 6: first contracts, job reports, Hana's audits, the three
	Offices (Hinge, Brasshand, your own), the Night, and the people around Fixers.
	Arcs: Kasimir (exam rival -> bidding war -> years later, a Capo of the Thumb);
	Marisol (the Fixer upstairs -> a favor returned); padded reports -> Hana's audit.
]]

local FIXER_CAREERS = { "fixer", "zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi", "hana" }
local PELL = { kind = "mentor", name = "Pell Moraine", bond = 60, age = { 56, 64 } }
local KASIMIR = { kind = "rival", name = "Kasimir Thane", bond = 35 }
local MARISOL = { kind = "friend", name = "Marisol Quell", bond = 60 }
local KASIMIR_LATER = { event = "fx_kasimir_turned", inYears = 8 }
local MARISOL_LATER = { event = "fx_marisol_returns", inYears = 5 }

return {
	-- ── Grade 9 and 8 ──
	{
		id = "fx_first_contract",
		title = "Your First Contract",
		text = "Your first real contract is a Grade 9 job. A pawnbroker wants his strongbox back from a pack of Rats who took it last night. They're holed up in a laundry that never seems to wash anything. The fee is 60 Ahn, half up front. Your Rep says to bring back the box, then the job report, in that order.",
		weight = 40,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", notFlags = { "fx_grade_seven" } },
		codex = "fn_lore_rats",
		choices = {
			{
				label = "Walk in through the front",
				clash = { stat = "strength", foe = "A laundry full of Rats", coins = 2, base = 3, coinPower = 3, fight = true, status = "bleed" },
				win = { wage = { 50, 80 }, strength = 1, setFlags = { "fx_first_job_done" }, log = "Four Rats, one laundry, one strongbox. You walked out with the box and a story your Rep made you tell twice." },
				lose = { health = { -7, -3 }, wage = { 10, 20 }, setFlags = { "fx_first_job_done" }, log = "The Rats knew the laundry better than you did. You got the box back the next day, after the clinic.", cause = "Lost a Grade 9 contract to Rats" },
			},
			{
				label = "Watch the laundry until they sleep",
				clash = { stat = "mind", foe = "A long, cold stakeout", coins = 2, base = 3, coinPower = 3 },
				win = { wage = { 50, 70 }, mind = 1, setFlags = { "fx_first_job_done" }, log = "At four in the afternoon every Rat in the laundry was asleep. You lifted the box off a shelf and left a polite note." },
				lose = { sanity = -3, wage = { 15, 25 }, setFlags = { "fx_first_job_done" }, log = "You dozed off at the wrong moment. You found the strongbox in a gutter, empty, and the pawnbroker paid you for the box alone." },
			},
			{
				label = "Offer the Rats a cut",
				result = { wage = { 25, 35 }, intelligence = 1, sanity = 1, setFlags = { "fx_first_job_done", "fx_paid_rats" }, log = "They took 20 Ahn of your fee and handed over the box. The pawnbroker never asked how, and your report was vague about it." },
			},
		},
	},
	{
		id = "fx_report_first",
		title = "Eleven Pages",
		text = "Hana's job report form is eleven pages long. Page four asks what you did. Page nine asks what you would do differently. Page eleven asks you to sign that pages one to ten are true. Old Fixers say Hana reads every word. Young Fixers who don't believe them tend to stay young Fixers.",
		weight = 30,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", notFlags = { "fx_grade_seven" } },
		codex = "fx_lore_reports",
		choices = {
			{
				label = "Write it plainly, mistakes and all",
				clash = { stat = "intelligence", foe = "Eleven pages", coins = 2, base = 3, coinPower = 3 },
				win = { addTrait = "fx_clean_reports", setFlags = { "fx_honest_reports" }, log = "Your report came back with a small green stamp in the corner. Your Rep said she'd only ever seen three of those." },
				lose = { intelligence = 1, sanity = -1, log = "You wrote it plainly, and plainly badly. Hana sent it back with notes in the margins, in red." },
			},
			{
				label = "Make yourself sound better",
				result = { sanity = 1, setFlags = { "fx_padded_report" }, schedule = { event = "fx_hana_audit", inYears = 2 }, log = "You turned a lucky escape into a careful plan. It read beautifully. You tried not to think about who else would read it." },
			},
			{
				label = "Copy the layout of an old report",
				result = { intelligence = 2, mind = 1, log = "You borrowed a Grade 2's report from thirty years back and copied its layout line by line. It was the best-organized thing you'd ever written." },
			},
		},
	},
	{
		id = "fx_hana_audit",
		title = "Hana Reads Everything",
		text = "A Hana assessor visits your Office with one of your old reports in a folder. She has underlined the word \"carefully\" four times and clipped a statement from the other side of the story to the back. \"Your account,\" she says, \"and everyone else's account disagree. Explain.\"",
		weight = 0,
		when = { flags = { "licensed_fixer" } },
		codex = "fx_lore_reports",
		choices = {
			{
				label = "Admit it and pay the fine",
				result = { money = { -60, -30 }, mind = 1, sanity = -2, clearFlags = { "fx_padded_report", "fx_bought_license" }, log = "You admitted it. She fined you, closed the folder, and said honesty is the cheapest thing a Fixer can buy." },
			},
			{
				label = "Talk your way out",
				clash = { stat = "charisma", foe = "A Hana assessor", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 1, clearFlags = { "fx_padded_report", "fx_bought_license" }, log = "She heard the whole explanation, closed the folder, and said, \"Write better.\" You decided that was a compliment." },
				lose = { money = { -120, -60 }, sanity = -4, setFlags = { "fx_hana_reprimand" }, clearFlags = { "fx_padded_report", "fx_bought_license" }, log = "A formal reprimand went into your file. Associations read files." },
			},
			{
				label = "Offer her money to lose the folder",
				hint = "200 Ahn. Very risky.",
				requires = { min = { money = 200 } },
				clash = { stat = "mind", foe = "An incorruptible assessor", coins = 3, base = 6, coinPower = 3 },
				win = { money = -200, sanity = -2, clearFlags = { "fx_padded_report", "fx_bought_license" }, log = "The folder was lost in a filing accident. She never visited again, and you never slept quite easy about it." },
				lose = { money = -200, sanity = -6, setFlags = { "fx_hana_reprimand" }, log = "She wrote down the amount you offered, to the Ahn. The reprimand ran to a second page." },
			},
		},
	},
	{
		id = "fx_brasshand_job",
		title = "Brasshand's Way",
		text = "Brasshand Office takes every contract it's offered, including the ones other Offices turn down. Today's job: lean on a tailor who owes a client money. The Rep slides you the address. \"Grade 9s don't ask questions,\" he says. \"Grade 9s who don't ask questions become Grade 8s.\"",
		weight = 25,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_office_brasshand" } },
		choices = {
			{
				label = "Do it, but gently",
				result = { wage = { 40, 70 }, sanity = -4, setFlags = { "fx_brasshand_loyal" }, log = "You knocked over a rack of coats and raised your voice. The tailor paid. You couldn't eat that night." },
			},
			{
				label = "Warn the tailor instead",
				result = { sanity = 3, gear = "padded_jacket", setFlags = { "fx_brasshand_doubt" }, log = "You told the tailor to close up for a week. The Rep docked your pay and called you soft. The tailor sent you a quilted jacket with a note: for the soft one." },
			},
			{
				label = "Walk out and go to Hinge Office",
				result = { clearFlags = { "fx_office_brasshand" }, setFlags = { "fx_office_hinge" }, addRelation = PELL, log = "You left your brass pin on the Rep's desk and walked three streets to Hinge Office. Old Pell poured you broth and handed you the cases nobody else wanted." },
			},
		},
	},
	{
		id = "fx_hinge_pell",
		title = "Old Pell's Rules",
		text = "Old Pell has run Hinge Office for thirty years and never climbed past Grade 4, on purpose. Tonight he pours you broth and gives you his three rules: be home before three, never take a job you couldn't describe in a report, and never say a Capo's name without the title. \"The rest,\" he says, \"is paperwork.\"",
		weight = 25,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_office_hinge" } },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Ask why he never climbed higher",
				result = { mind = 2, sanity = 3, gear = "job_reports", relationBond = { kind = "mentor", amount = 10 }, log = "\"Grade 3s get Grade 3 jobs,\" he said. \"I like being alive.\" Then he gave you his bound volume of other people's job reports." },
			},
			{
				label = "Ask him to train you",
				result = { strength = 2, mastery = 1, health = -1, log = "He was faster at sixty than you were at anything. You went home sore, and better." },
			},
			{
				label = "Ask about the third rule",
				result = { mind = 2, intelligence = 1, log = "He told you about a Grade 7 who said a Capo's name plainly in a diner, years ago. \"Nobody's seen him since,\" Pell said. \"And that was the polite outcome.\"" },
			},
		},
	},
	{
		id = "fx_own_office_rent",
		title = "Rep, Clerk and Cleaner",
		text = "Your one-person Office is a rented back room with a sign you painted yourself. Rent is due, the job board is thin, and Hana's Office Credit Assessment Committee wants a quarterly statement in triplicate. Being your own Rep means being your own clerk, cook and guard.",
		weight = 22,
		cooldown = 3,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_office_own" } },
		codex = "fx_lore_offices",
		choices = {
			{
				label = "Take every small job going",
				result = { wage = { 35, 75 }, health = { -3, -1 }, sanity = -2, log = "You took every job on the board, including the lost cat. Especially the lost cat. The rent got paid." },
			},
			{
				label = "Spend the week on the Committee's forms",
				clash = { stat = "intelligence", foe = "The Credit Committee's forms", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 1, wage = { 30, 60 }, setFlags = { "fx_office_credit_good" }, log = "The Committee raised your Office's credit rating by one notch. Better clients started knocking." },
				lose = { money = -40, sanity = -2, log = "You filled the forms in the wrong order. The Committee fined you for creativity." },
			},
			{
				label = "Hire a kid to answer the door",
				hint = "60 Ahn",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 3, setFlags = { "fx_office_assistant" }, addRelation = { kind = "friend", name = "Dovi Patch", age = { 15, 17 }, bond = 55 }, log = "You hired a teenager named Dovi to sweep, answer the door and learn the reports. Dovi is already better at the reports than you." },
			},
		},
	},
	{
		id = "fx_night_overtime",
		title = "Before Three",
		text = "The job is nearly done: one client, one warehouse, one stubborn padlock. Then the tower clock across the street says 2:51. The Sweepers rise at 3:13. Your client is hammering at the padlock and refusing to leave without his crates.",
		weight = 16,
		cooldown = 4,
		tags = { "fixers", "night" },
		when = { career = FIXER_CAREERS, side = "backstreets", minAge = 16 },
		codex = "city_sweepers",
		choices = {
			{
				label = "Break the lock and run for it",
				clash = { stat = "speed", foe = "The tower clock", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 40, 80 }, log = "The lock gave at 3:02. You were both behind a door by 3:10 with the crates, breathing like bellows." },
				lose = { health = { -10, -4 }, sanity = -5, condition = "night_terrors", log = "You heard the first wave before you reached the door. You made it inside. Part of you is still out there, running.", cause = "Caught outside during the Night" },
			},
			{
				label = "Drag him to shelter, leave the crates",
				result = { wage = { 10, 20 }, mind = 1, sanity = -1, log = "He shouted about his crates the whole way. In the morning they were gone, and he was alive to complain about it." },
			},
			{
				label = "Shelter in the warehouse with him",
				clash = { stat = "mind", foe = "The Night", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 50, 90 }, sanity = 2, log = "You sat among the crates while the three waves passed outside. He told you about his daughter's school. He paid triple." },
				lose = { sanity = -7, condition = "night_terrors", log = "The warehouse doors held, barely. Neither of you spoke until dawn, and he never hired a Fixer again." },
			},
		},
	},

	-- the Office quest's last step (Quests/Fixers.luau)
	{
		id = "fx_q_first_client",
		title = "Your First Client",
		text = "The first client through your new door is an old man with a shopping bag and a problem: someone is selling copied keys to his building, and three neighbors have been robbed. He asked for you by name. He heard about your sign from the noodle stall, which apparently talks about you now.",
		weight = 0,
		when = { flags = { "fx_q_office_register" } },
		choices = {
			{
				label = "Take the case yourself",
				clash = { stat = "mind", foe = "A copied-key racket", coins = 2, base = 4, coinPower = 3 },
				win = { setFlags = { "fx_q_client_done" }, wage = { 60, 120 }, log = "You found the key copier in two days, had a long talk with him, and changed the old man's locks yourself. He told everyone." },
				lose = { setFlags = { "fx_q_client_done" }, wage = { 20, 40 }, sanity = -2, log = "The key copier got away, but the old man paid anyway and told everyone you'd tried harder than any Office ever had." },
			},
			{
				label = "Charge him nothing",
				result = { setFlags = { "fx_q_client_done" }, sanity = 4, log = "You did it for free. Within a month half his building were your clients, and they paid." },
			},
		},
	},

	-- ── the people around Fixers ──
	{
		id = "fx_hire_a_fixer",
		title = "Hiring a Fixer",
		text = "Someone has scratched at your lock three nights running and chalked the same mark on your door every morning. In the Backstreets a problem like this means one thing: hire a Fixer. The Office on the corner has a Grade 9 who is cheap and eager, and a Grade 5 who is neither.",
		weight = 10,
		cooldown = 6,
		tags = { "fixers", "backstreets" },
		when = { minAge = 18, side = "backstreets", notFlags = { "licensed_fixer" } },
		codex = "fx_lore_grades",
		choices = {
			{
				label = "Hire the cheap Grade 9",
				hint = "30 Ahn",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = 2, log = "The Grade 9 sat on your stairs for three nights with a steel baton and caught a Rat scouting the building. She wrote a nine-page report about it." },
			},
			{
				label = "Pay for the Grade 5",
				hint = "120 Ahn",
				requires = { min = { money = 120 } },
				result = { money = -120, sanity = 5, mind = 1, log = "The Grade 5 found the problem in an afternoon, dealt with it in an evening, and sent a very short report and a very long invoice." },
			},
			{
				label = "Handle it yourself",
				clash = { stat = "strength", foe = "A Rat with a crowbar", coins = 2, base = 4, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = 2, sanity = 2, log = "You waited behind the door with the lights off. The Rat with the crowbar learned something about doors." },
				lose = { health = { -6, -2 }, money = { -30, -10 }, log = "The Rat with the crowbar was better at this than you. He took your coat on the way out.", cause = "Mugged on your own stairs" },
			},
		},
	},
	{
		id = "fx_fixer_neighbor",
		title = "The Fixer Upstairs",
		text = "Your upstairs neighbor is a Grade 8 Fixer named Marisol who comes and goes at strange hours. Tonight she comes in holding her side and sits down on the stairs, because she can't manage the last flight. The clinic is four streets away. It's 2:40.",
		weight = 9,
		once = true,
		tags = { "fixers" },
		when = { minAge = 12, notFlags = { "licensed_fixer" } },
		choices = {
			{
				label = "Patch her up yourself",
				clash = { stat = "intelligence", foe = "A deep cut and shaking hands", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = 3, addRelation = MARISOL, schedule = MARISOL_LATER, log = "You cleaned it and bound it with a torn pillowcase, the way she told you to. She laughed at your knots and fell asleep on your floor." },
				lose = { sanity = -3, log = "You did what you could. She made it to the clinic at dawn, and didn't knock on your door again." },
			},
			{
				label = "Run for the clinic before three",
				clash = { stat = "speed", foe = "The clock", coins = 2, base = 3, coinPower = 3 },
				win = { money = -20, sanity = 4, addRelation = MARISOL, schedule = MARISOL_LATER, log = "You ran four streets and back with a medic and her bag, and locked the door at 3:05. Marisol said you were faster than half her Office." },
				lose = { health = { -5, -2 }, sanity = -3, log = "The clinic shutters were already down. You ran home with the first wave rising behind you and sat with her until dawn." },
			},
			{
				label = "Help her up the last flight",
				result = { sanity = 1, log = "You got her inside and both your doors locked. In the morning she knocked to say thank you, and that you should never, ever become a Fixer." },
			},
		},
	},
	{
		id = "fx_marisol_returns",
		title = "A Favor Returned",
		text = "Marisol, the Fixer from upstairs, is Grade 5 now, with a desk at a good Office across the District. She turns up with a parcel in brown paper and the same crooked grin. \"I owe you a night,\" she says. \"Fixers pay their debts. We just send invoices for everyone else's.\"",
		weight = 0,
		when = { hasRelation = "friend" },
		choices = {
			{
				label = "Open the parcel",
				result = { gear = "long_blade", sanity = 2, log = "Inside was her old Workshop long blade, cleaned and sharpened. \"I've got a better one now,\" she said. \"Don't tell it I said that.\"" },
			},
			{
				label = "Ask her to sponsor your exam",
				requires = { minAge = 16, notFlags = { "licensed_fixer" } },
				result = { trigger = "fx_exam_hall", log = "She walked you to the exam hall herself, paid the fee, and waited outside with two cups of tea." },
			},
			{
				label = "Ask her for work",
				requires = { flags = { "licensed_fixer" } },
				result = { wage = { 80, 160 }, log = "She passed you a contract her Office was too busy for. It paid better than anything on your street." },
			},
		},
	},

	-- ── Kasimir ──
	{
		id = "fx_rival_kasimir",
		title = "Kasimir Again",
		text = "Kasimir, who passed the exam the same day you did, is a Grade 6 now with a flashy one-person Office, and he has just bid half your price on a contract you've chased for a month. He waits outside to make sure you hear it from him. \"Nothing personal,\" he says. \"Everything's personal at Grade 6.\"",
		weight = 25,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_met_kasimir", "fx_grade_seven" } },
		choices = {
			{
				label = "Undercut him back",
				result = { wage = { 20, 40 }, sanity = -2, setFlags = { "fx_rival_kasimir" }, addRelation = KASIMIR, schedule = KASIMIR_LATER, log = "You dropped your price to almost nothing and won the contract. Kasimir smiled like he'd been hoping you would." },
			},
			{
				label = "Propose a partnership",
				clash = { stat = "mind", foe = "Kasimir's pride", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 100, 200 }, setFlags = { "fx_kasimir_partner" }, addRelation = { kind = "friend", name = "Kasimir Thane", bond = 55 }, log = "You split the contract and the fee and closed it in half the time. He still argued about the report." },
				lose = { sanity = -2, setFlags = { "fx_rival_kasimir" }, addRelation = KASIMIR, schedule = KASIMIR_LATER, log = "He laughed at the offer and took the contract. Now it really was personal." },
			},
			{
				label = "Settle it in the alley",
				clash = { stat = "strength", foe = "Kasimir, Grade 6", coins = 2, base = 5, coinPower = 3, fight = true, status = "rupture" },
				win = { wage = { 60, 120 }, strength = 2, setFlags = { "fx_rival_kasimir" }, addRelation = KASIMIR, schedule = KASIMIR_LATER, log = "You won. Kasimir withdrew his bid with a split lip and a grudging nod, and you both filed reports calling it a disagreement." },
				lose = { health = { -8, -3 }, setFlags = { "fx_rival_kasimir" }, addRelation = KASIMIR, schedule = KASIMIR_LATER, log = "He was better than you'd hoped. You lost the contract and a tooth.", cause = "Settled a bidding war the hard way" },
			},
			{
				label = "Report his price-cutting to Hana",
				clash = { stat = "intelligence", foe = "Hana's complaint forms", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 80, 140 }, setFlags = { "fx_rival_kasimir", "fx_kasimir_reported" }, addRelation = KASIMIR, schedule = KASIMIR_LATER, log = "Hana fined Kasimir and passed you the contract. He found out who had complained within a day." },
				lose = { money = -30, sanity = -1, log = "Hana found nothing it could prove. Kasimir sent you a thank-you card." },
			},
		},
	},
	{
		id = "fx_kasimir_turned",
		title = "A Capo You Know",
		text = "A Capo of the Thumb walks into the diner with two Soldati behind him, and it takes you a moment to recognize Kasimir under the pressed suit. Hana took his license years ago, he says, and the Thumb took him in. He is Capo II now, and the Soldati go silent when he speaks. He waits to see whether you'll use his title.",
		weight = 0,
		when = { flags = { "fx_rival_kasimir" }, side = "backstreets" },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "\"Capo Kasimir.\"",
				result = { sanity = 1, setFlags = { "thumb_respect" }, log = "He smiled for the first time in years. \"You always did know the rules,\" he said, and paid for your noodles." },
			},
			{
				label = "\"Kasimir.\"",
				clash = { stat = "mind", foe = "Two offended Soldati", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = -2, log = "Kasimir raised one finger and the Soldati sat back down. \"Old rivals get one,\" he said. \"One.\"" },
				lose = { health = { -6, -2 }, condition = "broken_arm", log = "The Soldati corrected you in the alley while Kasimir finished his tea. He didn't watch, which was its own kind of courtesy.", cause = "Corrected by the Thumb" },
			},
			{
				label = "Offer him a desk at your Office",
				requires = { career = "fixer" },
				result = { sanity = 2, relationBond = { kind = "rival", amount = 20 }, log = "He laughed so hard a Soldato had to fetch him water. Then he said no, and looked, for one second, like he meant yes." },
			},
		},
	},
}
