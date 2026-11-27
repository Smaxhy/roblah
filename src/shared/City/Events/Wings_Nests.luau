--[[
	Two Nests and their Wings: T Corp's District 20, where time is taxed and color is a
	privilege, and H Corp's Hongyuan in District 8, where your room grows and shrinks with
	your fortune and the Four Families rule (CANON 2, 8.3, 9.2).
	Careers: wg_tcorp (Class 1 Collection Staff .. Class 5 Audit Staff),
	         wg_hcorp (Household Servant .. Family Steward).
	CANON 12.2: Heishou contracts are "contracts", not leashes, and creature traits from a
	Bolus are cosmetic, with no surgery.
]]

return {
	-- ── T Corp ──
	{
		id = "wg_t_timepiece",
		title = "Your Timepiece",
		text = "T Corp issues you a timepiece: a heavy silver watch with no numbers, only a single hand and a second, smaller dial that shows a balance. Your balance. In District 20, time is something you can save, spend and owe, and the Collection Staff collect what's owed. Your supervisor checks that it's ticking and says, \"Never let anyone else wind it.\"",
		weight = 120,
		once = true,
		tags = { "wing", "tcorp" },
		when = { career = "wg_tcorp" },
		codex = "wg_lore_tcorp",
		choices = {
			{
				label = "Wind it every morning, exactly on time",
				result = { intelligence = 2, log = "You wind it every morning at six. The ticking has become the sound of your days. Some nights you wake up and can't hear it, and lie very still until you do." },
			},
			{
				label = "Put it in a drawer and never look at the balance",
				result = { sanity = 3, log = "You keep it in a drawer at work and never look at the second dial. Your colleagues think you're either very brave or very foolish. You've decided not to find out which." },
			},
			{
				label = "Watch other people's timepieces instead",
				result = { mind = 2, sanity = -1, log = "You learned to read a stranger's balance from across a room by the speed of the small dial. It's a useful skill in your line of work. It has ruined a lot of dinners." },
			},
		},
	},
	{
		id = "wg_t_collection",
		title = "A Collection",
		text = "Today's collection is an old clockmaker in the Backstreets of District 20, three years behind on his Time Tax. His shop smells of oil and brass. He knows why you're here. He sets down his tools and holds out his wrist, with its cheap timepiece, and says, \"How much will it be, then?\"",
		weight = 24,
		cooldown = 3,
		tags = { "wing", "tcorp" },
		when = { career = "wg_tcorp" },
		choices = {
			{
				label = "Collect what's owed",
				result = { paycheck = 0.2, sanity = -5, log = "You collected. He went gray in front of you, a little, the way they do. He thanked you for being quick about it. On your way out you saw the clock he'd been mending, and it was beautiful." },
			},
			{
				label = "Grant him an extension",
				hint = "A Mental Strength check: the Audit Staff read every report.",
				clash = { stat = "mind", foe = "The Audit Staff", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = 3, log = "You wrote up an extension with reasons the Audit Staff couldn't argue with. He paid it off a year later, early, and sent you a pocket clock that keeps perfect time." },
				lose = { sanity = -2, money = -40, log = "The Audit Staff found the extension and fined you for it. They sent another collector the next week. You didn't ask how it went." },
			},
			{
				label = "Pay part of it from your own balance",
				hint = "50 Ahn, converted.",
				requires = { min = { money = 50 } },
				result = { money = -50, sanity = 3, log = "You paid half from your own account. It isn't allowed, exactly, and it isn't forbidden. He wept. You told him to stop wasting time." },
			},
		},
	},
	{
		id = "wg_t_audit",
		title = "The Audit Staff",
		text = "The Class 5 Audit Staff are reviewing your team's collections this quarter, and everyone in the office treats them as if they outrank the building. They've found a pattern: one of your Class 1 staff, a young man named Arvo, has been quietly letting the poorest debtors slide. They want a name for the report.",
		weight = 30,
		once = true,
		tags = { "wing", "tcorp" },
		when = { career = "wg_tcorp", minRank = 4 },
		choices = {
			{
				label = "Give them Arvo's name",
				result = { promote = true, sanity = -5, log = "You gave them his name. Arvo was reassigned to the Collection Staff in the worst part of the Backstreets. You were noted as reliable. A promotion followed, quickly. You think about the poorest debtors more than you used to." },
			},
			{
				label = "Take the blame yourself",
				result = { sanity = 3, money = { -120, -60 }, log = "You said the pattern was your policy. The Audit Staff fined you heavily and noted your judgment as poor. Arvo still works for you. He has never once let you down." },
			},
			{
				label = "Show them the pattern was profitable",
				hint = "An Intelligence check: make the numbers say it.",
				clash = { stat = "intelligence", foe = "Class 5 Audit Staff", coins = 2, base = 6, coinPower = 3 },
				win = { promote = true, intelligence = 2, log = "You showed them, line by line, that the debtors Arvo let slide paid more in the end than they would have broken. The Audit Staff adopted it as policy. Arvo got a commendation. You got a promotion." },
				lose = { sanity = -3, log = "They didn't follow your numbers, or didn't want to. Arvo was reassigned anyway. Your report was marked \"creative\"." },
			},
		},
	},
	{
		id = "wg_t_scarf",
		title = "A Blue Scarf",
		text = "In District 20's monochrome Nest, color is a privilege that has to be paid for. Outside the gallery on the main square, a T Corp officer is writing a fine for a young painter who wore a blue scarf without a permit. Everything else on the street is gray. The scarf is very, very blue. She's not taking it off.",
		weight = 12,
		cooldown = 6,
		tags = { "tcorp" },
		when = { district = "d20", minAge = 10 },
		codex = "wg_lore_tcorp",
		choices = {
			{
				label = "Pay the fine for her",
				hint = "30 Ahn.",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = 4, log = "You paid it. The officer looked at you, and at the scarf, and wrote a receipt. The painter gave you a small painting a month later: the whole gray square, and one blue thread in it." },
			},
			{
				label = "Lend her your gray coat to cover it",
				result = { sanity = 2, intelligence = 1, log = "You put your coat around her shoulders. Gray on gray. The officer tore up the fine, annoyed. She gave the coat back the next day with a blue thread sewn into the lining." },
			},
			{
				label = "Walk on. The rules are the rules",
				result = { sanity = -2, log = "You walked on past the gray gallery and the gray fountain. You noticed for the first time that day how gray everything was." },
			},
		},
	},
	{
		id = "wg_t_debt",
		title = "Time Debt",
		text = "A letter from T Corp: your great-aunt, who died last spring, owed four years of Time Tax, and under District 20's rules the arrears pass to her family. You can pay in Ahn, at the official rate, or in time: the days will simply feel shorter, the letter explains, until the balance is cleared.",
		weight = 10,
		once = true,
		tags = { "tcorp" },
		when = { district = "d20", minAge = 18 },
		codex = "wg_lore_tcorp",
		choices = {
			{
				label = "Pay in Ahn",
				hint = "150 Ahn.",
				requires = { min = { money = 150 } },
				result = { money = -150, sanity = -1, log = "You paid it off in one painful transfer. The receipt came on heavy paper with a silver seal. You've kept it, out of spite." },
			},
			{
				label = "Pay in time",
				result = { health = -4, sanity = -4, log = "The days got shorter that year. You'd sit down to breakfast and it would be evening. You cleared the debt by winter, and you'll never get those hours back." },
			},
			{
				label = "Appeal",
				hint = "A Charisma check against T Corp's lawyers.",
				clash = { stat = "charisma", foe = "T Corp's appeals office", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 2, sanity = 3, log = "You found a clause: arrears don't pass to relatives born outside District 20. You were born in a Backstreets clinic two streets over the line. The debt was cancelled. The clerk looked almost impressed." },
				lose = { money = -60, sanity = -3, log = "Your appeal failed, and the appeal had a fee. You paid the rest in time." },
			},
		},
	},

	-- ── H Corp (Hongyuan) ──
	{
		id = "wg_h_first_household",
		title = "The Household",
		text = "You're a Household Servant now, in the house of one of Hongyuan's Four Families. The Family crest is stitched on your sleeve. The house has rules for everything: which corridors servants may use, how low to bow to which cousin, what to do if the building rearranges itself during dinner. The head retainer hands you a book of them. It is very thick.",
		weight = 120,
		once = true,
		tags = { "wing", "hcorp" },
		when = { career = "wg_hcorp" },
		codex = "wg_lore_hcorp",
		choices = {
			{
				label = "Learn every rule in the book",
				result = { intelligence = 2, mind = 1, log = "You learned them all in a month, including the one about bowing to a cousin who has been dead for nine years but still has a room. The head retainer noticed." },
			},
			{
				label = "Learn who actually runs the house",
				result = { mind = 2, log = "The book says the Family runs the house. The kitchen says the cook does. The cook says the building does. You've found all three to be true, depending on the day." },
			},
			{
				label = "Make a friend among the other servants",
				result = { sanity = 3, log = "You shared your lunch with the servant who sweeps the east stairs, which move. She showed you where they usually end up, which has saved you a lot of time." },
			},
		},
	},
	{
		id = "wg_h_evaluation",
		title = "The Hierarch's Evaluation",
		text = "A Family Hierarch Evaluation has been called: the Four Families will compete to choose the next Family Hierarch, and every house is choosing sides. A young candidate from your Family wants you close, as a guard, a tutor or a food taster, and two other Families have sent you polite letters with very large numbers in them.",
		weight = 30,
		once = true,
		tags = { "wing", "hcorp" },
		when = { career = "wg_hcorp", minRank = 2 },
		codex = "wg_lore_hcorp",
		choices = {
			{
				label = "Serve your candidate as a guard",
				result = { strength = 2, health = 1, promote = true, log = "You stood behind the candidate's chair for a year of dinners and walked a step ahead of them in every corridor. Nothing happened to them. In Hongyuan, during an Evaluation, that is a remarkable achievement." },
			},
			{
				label = "Serve your candidate as a tutor",
				result = { intelligence = 2, mind = 1, promote = true, log = "You taught the candidate history, accounts and which cousins to trust. They didn't win the Evaluation. They did come second, which nobody expected, and they've never forgotten who taught them." },
			},
			{
				label = "Take another Family's offer",
				result = { money = { 300, 500 }, sanity = -4, setFlags = { "wg_h_turncoat" }, log = "You took the largest number. In Hongyuan, people do. Your old Family hasn't said a word to you since, which in Hongyuan is louder than shouting." },
			},
		},
	},
	{
		id = "wg_h_room",
		title = "The Shrinking Room",
		text = "Your room in Hongyuan has shrunk again. You came home and the wall had moved in another hand's width, as it does whenever your savings fall. The bed now touches both walls. Next door, through the thin partition, your neighbor's room has grown; she had a good month.",
		weight = 12,
		cooldown = 6,
		tags = { "hcorp" },
		when = { district = "d8", minAge = 18, max = { money = 600 } },
		codex = "wg_lore_hcorp",
		choices = {
			{
				label = "Pay to grow it back",
				hint = "80 Ahn.",
				requires = { min = { money = 80 } },
				result = { money = -80, sanity = 3, log = "You paid, and the wall slid back overnight with a grinding sigh. Your bed has room on one side again. You lay there and enjoyed the gap." },
			},
			{
				label = "Learn to live small",
				result = { sanity = -2, intelligence = 2, log = "You folded everything you own into a box under the bed and learned to sleep diagonally. It's amazing what a person can do without." },
			},
			{
				label = "Ask your neighbor how she did it",
				result = { mind = 2, sanity = 1, log = "She told you: a contract with one of the Four Families, and a talent for being useful. She gave you a name. Her wall moved out another hand's width the next morning, for the introduction." },
			},
		},
	},
	{
		id = "wg_h_contract",
		title = "A Contract for Sale",
		text = "In the great hall of a Hongyuan house, a Heishou Pack Adept stands very straight while two Families trade her contract back and forth over tea. The Heishou are the Families' private fighters, bound by contracts the Families buy and sell. Buying a contract outright and tearing it up is allowed. It is very, very expensive. She isn't looking at anyone.",
		weight = 10,
		once = true,
		tags = { "hcorp" },
		when = { district = "d8", minAge = 18 },
		codex = "wg_lore_hcorp",
		choices = {
			{
				label = "Buy her contract and tear it up",
				hint = "600 Ahn.",
				requires = { min = { money = 600 } },
				result = { money = -600, sanity = 6, addRelation = { kind = "friend", name = "Shen Yuqi", bond = 70, age = { 22, 30 } }, log = "You paid, and tore the contract in half in front of both Families, which nobody in the hall had ever seen done. Her name was Shen Yuqi. She walked out of Hongyuan beside you and has never once let you pay for tea since." },
			},
			{
				label = "Start saving to buy it",
				result = { sanity = 1, setFlags = { "wg_saving_contract" }, log = "You asked the seller how long the contract would be on the market. Two years, maybe. You've started putting money aside. She doesn't know. You haven't decided whether to tell her." },
			},
			{
				label = "Look away",
				result = { sanity = -3, log = "You looked away like everyone else in the hall. The contract went to the house with the larger number. She went with it, very straight, not looking at anyone." },
			},
		},
	},
	{
		id = "wg_h_bolus",
		title = "A Bolus",
		text = "A Bolus clinic in the lower levels of Hongyuan, lit pink and very clean. H Corp's Boluses heal, the nurse explains, and some of them change you too: a creature's trait, neatly grafted on, no surgery at all. On the menu above the counter, between \"mends bones\" and \"clears lungs\", someone has written: \"cat's eyes, see in the dark.\"",
		weight = 10,
		once = true,
		tags = { "hcorp" },
		when = { district = "d8", minAge = 16 },
		codex = "wg_lore_hcorp",
		choices = {
			{
				label = "Take a healing Bolus",
				hint = "35 Ahn.",
				requires = { min = { money = 35 } },
				result = { money = -35, health = { 8, 14 }, cure = "any", log = "It tasted of ginger and something older. Overnight, every ache in you was gone, and an old scar on your knee had faded so much you had to look for it." },
			},
			{
				label = "Take one that changes you",
				hint = "60 Ahn.",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = -2, addTrait = "bolus_grafted", log = "You chose the cat's eyes. You woke up the next morning seeing the dark like dusk, with your pupils gone narrow and gold. People on the street look twice. You've stopped minding." },
			},
			{
				label = "Leave without taking anything",
				result = { sanity = 1, log = "You thanked the nurse and left. On the way out you passed three people with the same golden eyes, laughing together in the corridor." },
			},
		},
	},
	{
		id = "wg_h_steward",
		title = "The Steward's Choice",
		text = "As Chief Retainer of your Family's house, you run its money, its servants and its quiet favors. Tonight the Family asks for something new: a rival house has borrowed heavily from yours, and the Family wants you to call in the whole debt at once, before the rival's daughter's naming feast. It would ruin them in front of all Hongyuan.",
		weight = 30,
		once = true,
		tags = { "wing", "hcorp" },
		when = { career = "wg_hcorp", minRank = 4 },
		choices = {
			{
				label = "Call in the debt",
				result = { promote = true, paycheck = 0.3, sanity = -6, log = "You called it in. The rival house sold its east wing the next morning, and the building swallowed the rooms by evening. Your Family named you Steward of the house. The feast was cancelled." },
			},
			{
				label = "Negotiate a slower repayment the Family can boast about",
				hint = "A Charisma check: both houses have to save face.",
				clash = { stat = "charisma", foe = "Two proud houses", coins = 2, base = 6, coinPower = 3 },
				win = { promote = true, charisma = 2, sanity = 2, log = "You arranged it so the rival house repaid with interest and public thanks at the naming feast, and your Family looked generous in front of all Hongyuan. They made you Steward for it." },
				lose = { sanity = -4, log = "Neither house liked the terms. Both remembered who proposed them." },
			},
			{
				label = "Refuse",
				result = { sanity = 3, mind = 1, log = "You refused, politely, and offered your reasons. The Family didn't make you Steward. The rival house sent you a gift the day after the feast, anonymously, which everyone in Hongyuan knew about by noon." },
			},
		},
	},
}
