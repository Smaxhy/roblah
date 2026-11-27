--[[
	The Wings come recruiting: one card per Wing career, for people living in that Wing's
	District (CANON 8.3). The first-rank flag of each career (rankFlags[1]) keeps the card
	away from people who already work there, or did.
]]

return {
	{
		id = "wg_recruit_wing",
		title = "The Wing Is Hiring",
		terms = { "Wing" },
		text = "{corp} has posted its yearly intake at the Nest gate: Class 1 Staff, good pay, a badge that opens the staff gate, and a path upward through the Classes for anyone with results. The queue for the entrance exam goes twice around the square. Most of the people in it are wearing their best clothes.",
		weight = 12,
		cooldown = 5,
		tags = { "wing" },
		when = { notDistrict = "d12", minAge = 16, maxAge = 30, notFlags = { "wg_feather" } },
		codex = "wg_lore_feathers",
		choices = {
			{
				label = "Sit the exam",
				hint = "From the Nest: Intelligence 30.",
				requires = { side = "nest", min = { intelligence = 30 } },
				result = { career = "wing", sanity = 1, log = "You passed the exam, and {corp} gave you a badge that says Class 1. Your family framed the letter." },
			},
			{
				label = "Sit the exam from the Backstreets",
				hint = "From the Backstreets: Intelligence 45.",
				requires = { side = "backstreets", min = { intelligence = 45 } },
				result = { career = "wing", sanity = 2, log = "From the Backstreets, you need twice the marks to get half the notice. You got them. {corp} gave you a Class 1 badge, and the guards at the gate learned your name." },
			},
			{
				label = "Ask a Feather in the queue what it's really like",
				result = { mind = 1, codex = "wg_lore_feathers", log = "\"Good pay,\" he said. \"Good badge. And you'll never quite belong to yourself again.\" Then he was called in for his interview, and smiled for the examiners." },
			},
			{
				label = "Walk past the queue",
				result = { sanity = 1, log = "You walked past the queue and the gate and the clean white Nest walls, and went to work somewhere that doesn't own you." },
			},
		},
	},
	{
		id = "wg_recruit_kcorp",
		title = "Rescue Staff Wanted",
		text = "A K Corp drone is hovering over the District 11 market, projecting a notice onto the wall: Class 1 Rescue Staff wanted, for street duty with a kit of ampules. Training in a week. Below the projection, a K Corp officer in spotless white is taking names. The queue is short, and everyone in it is very clean.",
		weight = 14,
		cooldown = 5,
		tags = { "kcorp" },
		when = { district = "d11", minAge = 18, maxAge = 34, notFlags = { "wg_kcorp_staff" } },
		codex = "wg_lore_kcorp",
		choices = {
			{
				label = "Give the officer your name",
				hint = "Needs Intelligence 32.",
				requires = { min = { intelligence = 32 } },
				result = { career = "kcorp", log = "The officer scanned your eyes, took a drop of your blood, and handed you a white armband: Class 1. \"The numbers go up,\" she said. \"Not everyone's do.\"" },
			},
			{
				label = "Ask what Class 1 actually does",
				result = { mind = 1, log = "\"Rescue,\" she said. \"Wherever the ambulances won't go. You'll carry three ampules and a lot of decisions.\" She looked at you. \"Mostly the decisions.\"" },
			},
			{
				label = "Walk on",
				result = { sanity = 1, log = "You walked on. The drone followed you for half a block, then lost interest." },
			},
		},
	},
	{
		id = "wg_recruit_wcorp",
		title = "Cleanup Crews Wanted",
		text = "A notice on the WARP station wall in District 23: Cleanup Agents wanted, Level 1, good pay, no experience needed, strong stomach preferred. A crew is coming off a shift as you read it, and none of them are talking. One of them looks at you reading the notice and shakes her head, very slightly.",
		weight = 14,
		cooldown = 5,
		tags = { "warp" },
		when = { district = "d23", minAge = 18, maxAge = 34, notFlags = { "wg_warp_crew" } },
		codex = "wg_lore_cleanup",
		choices = {
			{
				label = "Sign on",
				hint = "Needs Health 30.",
				requires = { min = { health = 30 } },
				result = { career = "wcorp_cleanup", log = "You signed on at the station office and were given a gray uniform, a mop and a sealed case you weren't to open until your first run. Level 1." },
			},
			{
				label = "Ask the woman who shook her head",
				result = { mind = 1, sanity = -1, log = "\"They tell you on your first run,\" the woman said. \"After that you can't be untold. Think about whether you want to be somebody who knows.\" She went home by the stairs." },
			},
			{
				label = "Walk away",
				result = { sanity = 1, log = "You walked away from the notice. You still ride the trains. You look at the cleanup crews differently now." },
			},
		},
	},
	{
		id = "wg_recruit_rcorp",
		title = "The Recruiting Office",
		text = "R Corp's recruiting office in District 18 never closes. Through the window you can see a sergeant at a desk, and behind him a poster of a Pack marching out by the thousand: Rabbits, Reindeer and Rhinos. Contract soldiers are paid by the month and better by the contract. The sergeant waves you in as if he's been expecting you.",
		weight = 14,
		cooldown = 5,
		tags = { "rcorp" },
		when = { district = "d18", minAge = 17, maxAge = 32, notFlags = { "wg_pack_member" } },
		codex = "wg_lore_rcorp",
		choices = {
			{
				label = "Sign a contract",
				hint = "Needs Health 30 and Strength 25.",
				requires = { min = { health = 30, strength = 25 } },
				result = { career = "rcorp", log = "You signed. The sergeant shook your hand, stamped your contract, and told you which barracks to report to. \"Most of your Pack were hatched,\" he said. \"Be nice to them. They notice.\"" },
			},
			{
				label = "Ask how many come back",
				result = { mind = 1, sanity = -1, log = "He thought about it honestly, which you respected. \"More than you'd think,\" he said. \"Fewer than the poster.\"" },
			},
			{
				label = "Keep walking",
				result = { sanity = 1, log = "You kept walking. Behind you, the office lights stayed on, the way they always do." },
			},
		},
	},
	{
		id = "wg_recruit_tcorp",
		title = "Collection Staff Wanted",
		text = "A gray notice on a gray wall in District 20: T Corp is taking on Class 1 Collection Staff. Applicants must be punctual, discreet, and able to stand in a doorway while someone pays what they owe in hours and days. The notice has a small silver timepiece printed at the bottom, ticking, somehow.",
		weight = 14,
		cooldown = 5,
		tags = { "tcorp" },
		when = { district = "d20", minAge = 18, maxAge = 34, notFlags = { "wg_time_collector" } },
		codex = "wg_lore_tcorp",
		choices = {
			{
				label = "Apply",
				hint = "Needs Mental Strength 32.",
				requires = { min = { mind = 32 } },
				result = { career = "wg_tcorp", log = "The interview took exactly eleven minutes. At the end, they issued you a timepiece and a ledger, and told you that you would be collecting from people very like your neighbors. You were." },
			},
			{
				label = "Ask what happens to people who can't pay",
				result = { mind = 1, sanity = -2, log = "\"Everyone can pay,\" said the clerk at the desk, without looking up. \"Everyone has time.\" You thought about that all the way home." },
			},
			{
				label = "Leave it",
				result = { sanity = 1, log = "You left the notice ticking on its wall. On the way home, you noticed how many people check their timepieces when a collector passes." },
			},
		},
	},
	{
		id = "wg_recruit_hcorp",
		title = "A Great House Needs Servants",
		text = "A herald from one of Hongyuan's Four Families is reading a notice at a crossroads that wasn't here yesterday: the house needs servants, honest and quick, and promises that service well done will be rewarded with space. In Hongyuan, space is everything. A small crowd is already pushing forward.",
		weight = 14,
		cooldown = 5,
		tags = { "hcorp" },
		when = { district = "d8", minAge = 16, maxAge = 30, notFlags = { "wg_hongyuan_servant" } },
		codex = "wg_lore_hcorp",
		choices = {
			{
				label = "Push forward and offer your service",
				hint = "Needs Intelligence 30.",
				requires = { min = { intelligence = 30 } },
				result = { career = "wg_hcorp", log = "The herald looked you over, asked you three questions about etiquette, and handed you a sleeve badge with the Family's crest. Your room grew by a hand's width that night." },
			},
			{
				label = "Ask which Family it is",
				result = { mind = 1, log = "The herald told you, and the crowd went a little quieter. Everyone in Hongyuan knows which Families are rising this year. You learned something just from their faces." },
			},
			{
				label = "Slip away before the crossroads moves",
				result = { sanity = 1, log = "You slipped away. By evening the crossroads had moved somewhere else, and the herald with it." },
			},
		},
	},
}
