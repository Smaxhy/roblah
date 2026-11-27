--[[
	A GIFT THAT WAKES (v0.12; Engine/Talent.luau, pack.talentWake): a Gifted talent or better
	sleeps until a rolled age. The year it wakes, tal_wakes; then, for a Prodigy or better,
	whoever comes looking depends on when it woke:
	  early (4-7)  -> an academy offers a scholarship               (tal_scout_academy)
	  on time      -> an Office wants you the day you turn eighteen (tal_scout_office -> tal_office_due)
	  late (15-22) -> Hana's clerks notice a late bloomer           (tal_scout_hana)
	A prodigy starts further up than anyone else: Grade 8, not Grade 9. Nobody under eighteen
	takes a contract (Roblox: no children in fights).
]]

return {
	{
		id = "tal_wakes",
		title = "Something Wakes",
		text = {
			"It happens on an ordinary day. You do something you've never done before, and you do it as if you'd done it a thousand times. Everyone in the room goes quiet.",
			"Nobody taught you. Nobody had to. One afternoon it's simply there, like a light switched on in a room you didn't know you had.",
			"Your neighbor drops a jar and you've caught it before it falls a hand's width. Then you notice everyone staring, and you notice that you're not surprised at all.",
		},
		weight = 0,
		tags = { "strange" },
		choices = {
			{ label = "Lean into it", hint = "Use it every day.", result = { mind = 1, strength = { 0, 1 }, speed = { 0, 1 }, intelligence = { 0, 1 }, log = "You practiced it until it stopped being strange and started being yours." } },
			{ label = "Keep it quiet", hint = "The City notices gifts. That isn't always good.", result = { sanity = 3, luck = 1, log = "You learned to do it only when nobody was looking. It's still there. It'll keep." } },
		},
	},
	-- early: an academy wants you young
	{
		id = "tal_scout_academy",
		title = "A Letter From an Academy",
		text = "A teacher from a Nest academy came to watch you, on the word of somebody who'd seen what you can do. Now there's a letter on the kitchen table, on thick paper, offering you a place, a uniform and a scholarship. Your family has read it six times.",
		weight = 0,
		tags = { "school" },
		when = { maxAge = 15 },
		choices = {
			{
				label = "Take the scholarship",
				hint = "Classes with the Nest's children, paid for.",
				result = { setFlags = { "enrolled", "prodigy_scholar" }, intelligence = { 2, 3 }, charisma = 1, log = "You wore the uniform on the first day and felt like a costume. By the end of the year it fit." },
			},
			{ label = "Stay where you are", result = { sanity = 2, money = 30, log = "Your family needed you close. The academy sent a second letter, kinder than the first, and a small cheque for your trouble." } },
		},
	},
	-- on time: an Office wants you the day you turn eighteen
	{
		id = "tal_scout_office",
		title = "The Office Across the Street",
		text = "A Fixer from the Office across the street has been watching you since your gift woke. Today she knocks, polite as a Thumb Capo. \"Nobody signs anyone young,\" she says. \"But the day you're eighteen, there's a licence with your name on it, and you won't start at the bottom.\"",
		weight = 0,
		tags = { "fixers" },
		when = { maxAge = 17 },
		choices = {
			{
				label = "Shake on it",
				hint = "At 18: a Fixer's licence, starting at Grade 8.",
				result = { setFlags = { "prodigy_office_offer" }, schedule = { event = "tal_office_due", inYears = 1 }, log = "She shook your hand like an adult's and wrote your birthday in a small black book." },
			},
			{ label = "Say you'll think about it", result = { sanity = 1, log = "\"Think,\" she said. \"Thinking is good. The offer keeps a while.\"" } },
		},
	},
	{
		id = "tal_office_due",
		title = "A Licence With Your Name",
		text = "The Fixer from across the street kept her word. There's a licence on the Office counter with your name already typed in, and a coat that almost fits.",
		weight = 0,
		tags = { "fixers" },
		when = { minAge = 18, flags = { "prodigy_office_offer" }, notFlags = { "licensed_fixer" } },
		choices = {
			{
				label = "Sign as a Grade 8",
				hint = "Skip Grade 9 entirely.",
				result = { career = "fixer", careerRank = 2, renown = 8, clearFlags = { "prodigy_office_offer" }, log = "You signed. The other Grade 9s looked at your licence and then at you, and said nothing. Hana's clerk raised an eyebrow, once." },
			},
			{ label = "Not yet", result = { schedule = { event = "tal_office_due", inYears = 2 }, log = "\"Two years,\" she said, and put the licence back in the drawer." } },
			{ label = "Not ever", result = { clearFlags = { "prodigy_office_offer" }, sanity = 2, log = "She tore up the licence in front of you, not unkindly. \"Most people never get the choice,\" she said." } },
		},
	},
	-- late: Hana notices a late bloomer
	{
		id = "tal_scout_hana",
		title = "Hana's Clerk Takes a Note",
		text = "A Hana Association clerk in a pressed grey coat stops you in the street with a clipboard. \"Late bloomers are rare,\" she says, \"and Hana likes to know where the rare things are.\" She writes your name down in very small, very neat letters.",
		weight = 0,
		tags = { "fixers" },
		choices = {
			{
				label = "Ask what that means for you",
				result = { renown = 15, setFlags = { "prodigy_hana_noted" }, schedule = { event = "tal_hana_exam", inYears = 1 }, log = "\"It means that if you ever take the exam,\" she said, \"somebody will be paying attention.\"" },
			},
			{ label = "Ask her to forget it", result = { sanity = 2, log = "\"Hana doesn't forget,\" she said, and tore the page out anyway, and folded it into her pocket." } },
		},
	},
	{
		id = "tal_hana_exam",
		title = "An Invitation to the Exam",
		text = "A letter from Hana: an invitation to sit the licensing exam this season, fee waived. Underneath, in a different hand: \"We remember you.\"",
		weight = 0,
		tags = { "fixers" },
		when = { minAge = 18, flags = { "prodigy_hana_noted" }, notFlags = { "licensed_fixer" } },
		choices = {
			{
				label = "Sit the exam",
				clash = { stat = "mind", foe = "Hana's licensing exam", coins = 3, base = 8, coinPower = 3 },
				win = { career = "fixer", careerRank = 2, renown = 12, log = "You finished early. The proctor checked your paper twice, then stamped your licence Grade 8, which almost never happens." },
				lose = { career = "fixer", careerRank = 1, log = "You passed, just. Grade 9, like everyone else. The note at the bottom of your results said: \"Next time.\"" },
			},
			{ label = "Not this year", result = { schedule = { event = "tal_hana_exam", inYears = 2 }, log = "You kept the letter. Hana will write again. Hana always writes again." } },
		},
	},
}
