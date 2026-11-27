--[[
	Feathers: life inside your District's own Wing (career "wing", company = true; {corp}
	names it), from Class 1 Staff to Executive, and the Wing as outsiders meet it.
	Ranks: 1 Class 1 Staff, 2 Class 2, 3 Class 3 Specialist, 4 Class 4, 5 Class 5 Auditor,
	6 Director, 7 Executive. District 12 has no Wing of this kind, so these skip it.
]]

local FEATHER = { career = "wing" }

return {
	{
		id = "wg_feather_badge",
		title = "Class 1",
		text = "{corp} issues you a badge with your photograph, a barcode and two words: Class 1. It opens the staff gate in the Nest wall, the one with no queue. Your supervisor, a Class 4 woman who never seems to blink, explains that the numbers count upward and that nobody she knows has ever started anywhere but the bottom.",
		weight = 120,
		once = true,
		tags = { "wing" },
		when = FEATHER,
		codex = "wg_lore_feathers",
		choices = {
			{
				label = "Walk through the staff gate for the first time",
				result = { sanity = 3, log = "You walked past the long queue at the Nest checkpoint and through the staff gate, and the guard nodded at you like you belonged. You thought about that nod all week." },
			},
			{
				label = "Ask how people get to Class 2",
				result = { intelligence = 2, log = "\"Results,\" she said. \"And the right people noticing your results. Mostly the second one.\" She gave you a list of the right people. It was short." },
			},
			{
				label = "Ask what happens to Feathers who want to leave",
				result = { mind = 2, sanity = -1, log = "She blinked, for the first time. \"A feather doesn't fall from the Wing of its own will,\" she said, like she was reading it off a card. Then she changed the subject." },
			},
		},
	},
	{
		id = "wg_feather_numbers",
		title = "The Numbers",
		text = "Your section is behind its quarterly numbers, and a Class 5 Auditor is coming down from the top floor on Friday. Your section chief has quietly asked everyone to \"tidy\" their figures before then. You know exactly what tidy means. So does everyone else at the long table, and nobody is looking up.",
		weight = 22,
		cooldown = 4,
		tags = { "wing" },
		when = { career = "wing", minRank = 2 },
		choices = {
			{
				label = "Tidy your figures like everyone else",
				result = { paycheck = 0.15, sanity = -3, setFlags = { "wg_tidied" }, log = "You tidied. The Auditor passed your section with a nod. Your chief bought everyone lunch. You can't remember what you ate." },
			},
			{
				label = "Tell the Auditor the truth",
				hint = "A Mental Strength check. Auditors don't love surprises.",
				clash = { stat = "mind", foe = "A Class 5 Auditor", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, setFlags = { "wg_honest_feather" }, log = "You laid it out plainly. The Auditor listened without expression, then wrote your name on a card and put it in her pocket. A month later you were promoted, and your chief was transferred to a smaller office." },
				lose = { sanity = -4, log = "The Auditor thanked you, filed it, and did nothing. Your section knows it was you. Lunch has been very quiet ever since." },
			},
			{
				label = "Leave your figures as they are and say nothing",
				result = { mind = 1, sanity = -1, log = "Your numbers stayed honest and bad. The Auditor circled them in red without comment. You slept fine." },
			},
		},
	},
	{
		id = "wg_feather_cut",
		title = "The Department Cut",
		text = "{corp} is cutting a department to make the year's numbers, and it's yours or the one across the hall. The decision is being made upstairs this week. The people across the hall have families too, and one of them brought cakes for your birthday.",
		weight = 18,
		cooldown = 5,
		tags = { "wing" },
		when = { career = "wing", minRank = 2 },
		choices = {
			{
				label = "Make the case for your department",
				hint = "An Intelligence check: a better report than theirs.",
				clash = { stat = "intelligence", foe = "The department across the hall", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.1, sanity = -2, log = "Your report was better. Your department stayed. You helped carry the other department's desks out on Monday, and the woman who brought the cakes didn't look at you." },
				lose = { sanity = -4, money = -60, log = "Theirs was better. Your department was folded into theirs, at a lower Class, and your pay with it." },
			},
			{
				label = "Suggest merging the two, quietly, to someone upstairs",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "The people upstairs", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = 3, log = "Someone upstairs liked the idea and took credit for it. Nobody was cut. You'll never get the credit. You'll take it." },
				lose = { sanity = -3, log = "Someone upstairs liked the idea, took credit for it, and cut both departments anyway. You were moved sideways into a filing room." },
			},
			{
				label = "Let it happen and keep your head down",
				result = { sanity = -2, log = "It was the other department. You helped them carry their desks out, and kept your head down, and felt every bit of it." },
			},
		},
	},
	{
		id = "wg_feather_leave",
		title = "A Feather Doesn't Fall",
		terms = { "Feather" },
		text = "You've decided you want out of {corp}. HR hands you a copy of your contract with one clause highlighted: an early-exit fee, calculated from your Class and your years. It's a lot of Ahn. The HR clerk lowers her voice. \"Most people pay it in installments,\" she says. \"For about twenty years.\"",
		weight = 12,
		cooldown = 8,
		tags = { "wing" },
		when = { career = "wing", minRank = 3, minAge = 25 },
		codex = "wg_lore_feathers",
		choices = {
			{
				label = "Pay the fee and walk out",
				hint = "300 Ahn.",
				requires = { min = { money = 300 } },
				result = { money = -300, quitCareer = true, sanity = 5, log = "You paid it in one go and handed in your badge. Walking out through the public gate, in the queue with everyone else, you felt lighter than you had in years." },
			},
			{
				label = "Stay. For now",
				result = { sanity = -2, mind = 1, log = "You put the contract in a drawer. You take it out sometimes and look at the clause. The fee goes up every year." },
			},
			{
				label = "Ask about a transfer to another office instead",
				result = { intelligence = 1, sanity = 1, log = "A transfer was possible, it turned out, at the same Class, in a quieter office on a lower floor. It's not out. It's further from the top, which some days is the same thing." },
			},
		},
	},
	{
		id = "wg_feather_director",
		title = "A Director's Chair",
		text = "A Director's seat has opened in {corp}, and you're one of three Class 5 staff being considered. The Executives want someone who understands that the Wing comes first, before staff, before friends, before Backstreets complaints. Over dinner, one of them asks you what you'd do if your own section stood in the way of the numbers.",
		weight = 30,
		once = true,
		tags = { "wing" },
		when = { career = "wing", minRank = 5 },
		choices = {
			{
				label = "Give them the answer they want",
				result = { promote = true, sanity = -4, setFlags = { "wg_wing_first" }, log = "\"The Wing comes first,\" you said, and meant it enough. You were a Director by the end of the month. Your old section sent flowers. You didn't recognize half the names on the card." },
			},
			{
				label = "Tell them your section is the Wing",
				hint = "A Mental Strength check. Bold, at this table.",
				clash = { stat = "mind", foe = "The Executives' dinner", coins = 2, base = 6, coinPower = 3 },
				win = { promote = true, sanity = 3, log = "There was a silence, and then the oldest Executive laughed and said it had been a long time since anyone at that table said something interesting. You were a Director by spring." },
				lose = { sanity = -3, log = "Nobody laughed. Another candidate got the chair. You were thanked for your candor, in writing." },
			},
			{
				label = "Withdraw your name",
				result = { sanity = 2, log = "You withdrew. You had seen what Directors' days looked like. Class 5 was high enough to see the top and far enough to sleep at night." },
			},
		},
	},
	{
		id = "wg_feather_executive",
		title = "The Top Floor",
		text = "As a Director of {corp}, you've been invited to the top floor for the first time: the Executives' floor, where the Wing's real decisions are made over tea in a room with no windows. Today's question is whether to raise the Nest's residence fee. It would push four thousand families back out into the Backstreets.",
		weight = 30,
		once = true,
		tags = { "wing" },
		when = { career = "wing", minRank = 6 },
		choices = {
			{
				label = "Vote for the raise",
				result = { promote = true, money = { 200, 400 }, sanity = -6, log = "The raise passed. You were offered a seat at the table permanently the next quarter: an Executive. From the top floor, you can't see the Nest gates at all." },
			},
			{
				label = "Argue for a smaller raise, phased in",
				hint = "A Charisma check.",
				clash = { stat = "charisma", foe = "Four thousand families' fate", coins = 2, base = 6, coinPower = 3 },
				win = { promote = true, sanity = 2, log = "You argued for a year-long phase and a hardship exemption, and you won both, and somehow they liked you more for it. An Executive, by the next quarter. Some families stayed who wouldn't have." },
				lose = { sanity = -4, log = "They passed the full raise over your objection, and noted the objection. You stayed a Director. Four thousand families moved." },
			},
			{
				label = "Vote no and say why",
				result = { sanity = 3, mind = 1, log = "You voted no, alone. The raise passed anyway. You were never invited back to the top floor, and you've slept well every night since." },
			},
		},
	},
	-- outsiders meet the Wing
	{
		id = "wg_inspection",
		title = "A Feather's Inspection",
		text = "Inspectors from {corp} are walking the Backstreets market today in clean uniforms, checking stall permits against a tablet. Ahead of you, old Mr. Ferro's permit for his knife-sharpening stall expired a week ago. He's been sharpening knives on this corner for forty years. The inspector is already writing.",
		weight = 14,
		cooldown = 5,
		tags = { "wing" },
		when = { side = "backstreets", notDistrict = "d12", minAge = 12, notFlags = { "wg_feather" } },
		codex = "wg_lore_feathers",
		choices = {
			{
				label = "Talk to the inspector for him",
				hint = "A Charisma check.",
				clash = { stat = "charisma", foe = "A Feather with a tablet", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, sanity = 3, log = "You talked about forty years and a renewal form already in the post until the inspector, sighing, gave him a week's grace. Mr. Ferro sharpened your knife for free for the rest of his life." },
				lose = { sanity = -2, log = "The inspector wrote the fine anyway, and added a line about obstruction. Mr. Ferro paid it, and thanked you, and closed early." },
			},
			{
				label = "Help him pay the fine",
				hint = "25 Ahn.",
				requires = { min = { money = 25 } },
				result = { money = -25, sanity = 2, log = "You paid half and he paid half. The inspector looked faintly disappointed not to have anything else to write." },
			},
			{
				label = "Keep walking",
				result = { sanity = -1, log = "You kept walking. When you came back past, the stall was shuttered and Mr. Ferro was sitting on the curb, counting his coins twice." },
			},
		},
	},
}
