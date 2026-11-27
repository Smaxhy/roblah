--[[
	The climb from Grade 7 to Grade 1, and past it: Association recruiters, Open Contracts,
	hazard grades, Workshops, Butlers, Hana's review board, the Grade 1 news, a Color, and
	retirement. Color Fixers otherwise stay distant legends (the Red Mist only as a Smoke War
	story, the Indigo Elder on the Great Lake, the Purple Tear as a rumor).
	Grade gates use the fixer career's rank flags: fx_grade_seven (Grade 7+), fx_grade_five
	(Grade 5+), senior_fixer (Grade 3+), grade_one_fixer.
]]

local FIXER_CAREERS = { "fixer", "zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi", "hana" }

-- every Color result: the title, the news, a family-name roll for a big moment
local function color(epithet: string, log: string)
	return { addTrait = "color_fixer", chronicle = "fx_color", rolls = 1, sanity = 10, setFlags = { "fx_color_" .. epithet }, log = log }
end

return {
	-- ── Grade 7 and 6 ──
	{
		id = "fx_nest_escort",
		title = "A Feather Abroad",
		text = "A Nest client hires your Office to walk her from the checkpoint to a Backstreets address and back. She's a Feather, a Wing employee, in shoes that cost more than your rent, and she wants to know why the Backstreets smell like this. Halfway there, three Rats step out of an alley and look at her shoes.",
		weight = 22,
		cooldown = 5,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_grade_seven" }, notFlags = { "fx_grade_five" } },
		choices = {
			{
				label = "Step in front of her",
				clash = { stat = "strength", foe = "Three Rats with ambitions", coins = 2, base = 4, coinPower = 3, fight = true, status = "bleed" },
				win = { wage = { 70, 130 }, strength = 1, log = "Two Rats ran. The third apologized to the shoes. The Feather tipped you in Nest notes and asked for you by name next time." },
				lose = { health = { -8, -3 }, wage = { 30, 50 }, log = "You kept the Rats off her and on you. She paid in full and sent a clinic voucher, which was more than you expected from a Feather.", cause = "Fell escorting a Nest client" },
			},
			{
				label = "Take the long way around",
				clash = { stat = "mind", foe = "Streets that change by the hour", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 60, 100 }, log = "You took her through a laundry, a noodle kitchen and somebody's back garden. She arrived without a scratch, and with a new opinion of the Backstreets." },
				lose = { wage = { 20, 40 }, sanity = -3, log = "The long way got longer. You arrived after dark, and she complained to your Rep for an hour." },
			},
			{
				label = "Pay the Rats off with her money",
				result = { wage = { 50, 80 }, sanity = -1, log = "You told her the Backstreets have a toll. She paid it without blinking and added it to her expense report." },
			},
		},
	},
	{
		id = "fx_distortion_contract",
		title = "Graded Urban Myth",
		text = "Hana has graded a Distortion in a disused bathhouse as an Urban Myth, cheap enough for your Office to take. The client is the owner's son. He says the thing inside still hums his father's favorite song. It has turned the steam rooms into a maze that doesn't end where the building does.",
		weight = 20,
		cooldown = 6,
		tags = { "fixers", "distortion" },
		when = { career = "fixer", flags = { "fx_grade_seven" }, world = { era = { "library", "limbus" } } },
		codex = "fx_lore_hazards",
		choices = {
			{
				label = "Go in and end it",
				clash = { stat = "strength", foe = "The bathhouse Distortion", coins = 3, base = 5, coinPower = 3, fight = true, status = "sinking" },
				win = { wage = { 120, 220 }, strength = 2, sanity = -3, log = "Somewhere in the steam you found what was left of a man, humming. It ended. You wrote the report sitting on the bathhouse steps." },
				lose = { health = { -11, -5 }, sanity = -6, condition = "night_terrors", log = "The maze turned you around until you were back at the door with no idea how long you'd been inside.", cause = "Lost in a Distortion's maze" },
			},
			{
				label = "Hum the song back to it",
				hint = "People are still in there, sometimes.",
				clash = { stat = "mind", foe = "A humming Distortion", coins = 3, base = 5, coinPower = 3 },
				win = { wage = { 100, 180 }, sanity = 2, mind = 2, log = "You hummed his father's song back to it. The steam thinned. When it was over the son thanked you for the quiet, and you didn't know what to say." },
				lose = { sanity = -8, condition = "distortion_signs", log = "It hummed back. You caught yourself humming it for weeks." },
			},
			{
				label = "Pass it up to an Association",
				result = { wage = { 20, 40 }, mind = 1, sanity = -1, log = "You called in Zwei and took a finder's fee. The son looked at you like you'd sold his father. You told yourself it was the professional choice." },
			},
		},
	},
	{
		id = "fx_workshop_offer",
		title = "Under the Railway Arch",
		text = "Big-name Workshops won't take an order from an unknown Fixer, however much Ahn they wave. Thornback Workshop, three rooms and a forge under a railway arch, will. The smith offers a deal: a custom blade at cost, free sharpening for life, and your name on their posters when you get famous.",
		weight = 14,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_grade_seven" } },
		codex = "fx_lore_workshops",
		choices = {
			{
				label = "Take the deal",
				hint = "150 Ahn",
				requires = { min = { money = 150 } },
				result = { money = -150, gear = "long_blade", addTrait = "fx_workshop_sponsor", setFlags = { "fx_thornback" }, log = "Thornback forged you a blade with a thorn stamped on the guard. Every time you closed a contract, they got two new customers." },
			},
			{
				label = "Test their prototypes instead",
				clash = { stat = "strength", foe = "A prototype that bites back", coins = 2, base = 4, coinPower = 3 },
				win = { addTrait = "fx_workshop_sponsor", setFlags = { "fx_thornback" }, log = "You broke three prototypes and survived a fourth. The smith called you his favorite test subject and sharpens your blade for free." },
				lose = { health = { -4, -2 }, condition = "burns", log = "The prototype went off, politely, in your hands. The smith apologized and gave you a discount." },
			},
			{
				label = "Hold out for Old Boys or Mook",
				result = { mind = 1, setFlags = { "fx_big_name_wish" }, log = "You told the smith you'd wait for a big-name Workshop. He said they'd take your order the day you no longer needed one." },
			},
		},
	},
	{
		id = "fx_assoc_recruiter",
		title = "An Association Card",
		text = "A woman in a sharp Association coat leaves a card on your desk. \"We read your job reports,\" she says. \"Section 6 has openings. Association Fixers don't choose their jobs, and we pay accordingly.\" On the back, three Associations have pencilled offers: Zwei, Liu and Devyat'.",
		weight = 18,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_grade_seven" } },
		codex = "fx_lore_associations",
		choices = {
			{
				label = "Zwei: be the client's shield",
				requires = { min = { health = 40 } },
				result = { career = "zwei", codex = "fx_lore_zwei", log = "You traded your Office desk for a Zwei coat and a post in Section 6. The first thing they taught you was how to stand still while things hit you." },
			},
			{
				label = "Liu: fight crowds, with fire",
				requires = { min = { strength = 40 } },
				result = { career = "liu", codex = "fx_lore_liu", log = "The Liu gave you a weapon with a fuel line in the grip and a Section 6 badge. Your new squad bought you dinner, which no Office had ever done." },
			},
			{
				label = "Devyat': carry what must arrive",
				requires = { min = { intelligence = 35, health = 35 } },
				result = { career = "devyat", codex = "fx_lore_devyat", log = "Devyat' issued you a Courier Trunk bigger inside than out, and a quiet program called Poludnitsa that counts down every deadline in your ear." },
			},
			{
				label = "Stay with your Office",
				result = { sanity = 2, paycheck = 0.2, log = "You kept the card in a drawer. Your Rep noticed it there, and raised your cut a little." },
			},
		},
	},
	{
		id = "fx_assoc_recruiter_two",
		title = "A Heavier Card",
		text = "Another Association card, heavier paper this time. Three Associations want a Grade 5 who writes clean reports: Seven, who find things out; Shi, who take the quietest contracts in the City; and Cinq, who fight duels by contract. Each would start you in Section 6, which feels like a step down until you see the pay.",
		weight = 14,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_grade_five" } },
		codex = "fx_lore_associations",
		choices = {
			{
				label = "Seven: find out anything",
				requires = { min = { mind = 40 } },
				result = { career = "seven", codex = "fx_lore_seven", log = "Seven gave you a case file on your first day and a lecture on what 'whatever means the contract allows' really means." },
			},
			{
				label = "Shi: the quiet contracts",
				requires = { min = { strength = 45, mind = 35 } },
				result = { career = "shi", codex = "fx_lore_shi", log = "Shi didn't give you a badge. They gave you a name to remember and a rule: done right, done once." },
			},
			{
				label = "Cinq: duels by contract",
				requires = { min = { strength = 42 } },
				result = { career = "cinq", codex = "fx_lore_cinq", log = "Cinq fitted you for a cape and a hat, and taught you the correct way to throw a glove. There are four." },
			},
			{
				label = "Stay with your Office",
				result = { sanity = 2, paycheck = 0.2, log = "You framed the card instead. Clients liked seeing it on the wall." },
			},
		},
	},
	{
		id = "fx_assoc_recruiter_three",
		title = "Keys and Contracts",
		text = "Two Association Fixers wait in your Office's doorway, ignoring each other. One from Dieci wears brass keys on a ring like knuckles; she trades knowledge for strength and says you have plenty to trade. One from Öufi wears a gaudy hat and holds a contract already filled in, except for your signature.",
		weight = 10,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_grade_five" } },
		codex = "fx_lore_associations",
		choices = {
			{
				label = "Dieci: knowledge into strength",
				requires = { min = { intelligence = 45 } },
				result = { career = "dieci", codex = "fx_lore_dieci", log = "Dieci gave you a ring of keys and a list of things you might one day be asked to forget. You read it twice, to remember it while you could." },
			},
			{
				label = "Öufi: see contracts kept",
				requires = { min = { mind = 45 } },
				result = { career = "oufi", codex = "fx_lore_oufi", log = "You signed. The Öufi Fixer notarized your signature on the spot, which felt like being swallowed by a very polite whale." },
			},
			{
				label = "Send them both away",
				result = { sanity = 1, mind = 1, log = "They left together, still ignoring each other. You heard them arguing about jurisdiction all the way down the stairs." },
			},
		},
	},

	-- ── Grade 5 and 4 ──
	{
		id = "fx_open_contract",
		title = "An Open Contract",
		text = "Hana has posted an Open Contract for a threat graded Urban Legend: a nest of Outskirts monsters under an abandoned overpass at the edge of the District. Any licensed Fixer may take it. Half the Offices in the District are already racing for the overpass, and the reward would pay your rent for three years.",
		weight = 18,
		cooldown = 6,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_grade_five" } },
		codex = "fx_lore_hazards",
		choices = {
			{
				label = "Race the other Offices to it",
				clash = { stat = "speed", foe = "An Urban Legend under the overpass", coins = 3, base = 6, coinPower = 3, fight = true, status = "rupture" },
				win = { wage = { 300, 500 }, speed = 2, chronicle = "fx_open_contract", setFlags = { "fx_open_contract_won" }, log = "You reached the overpass first and walked out last. Hana's assessor counted the monsters twice and signed the contract closed." },
				lose = { health = { -13, -6 }, sanity = -4, log = "Three Offices reached the overpass. Two walked out. Yours was one of them, mostly.", cause = "Fell on Hana's Open Contract" },
			},
			{
				label = "Team up with two other Offices",
				clash = { stat = "mind", foe = "Three Reps and their egos", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 150, 260 }, chronicle = "fx_open_contract", setFlags = { "fx_open_contract_won" }, log = "Three Offices, one plan, one shared report. It was the most paperwork you'd ever done for a fight, and nobody died." },
				lose = { wage = { 40, 80 }, sanity = -3, log = "The alliance lasted until the first monster. Everyone ran a different way, and the contract went to somebody else." },
			},
			{
				label = "Sell your map of the nest",
				result = { wage = { 80, 140 }, mind = 1, log = "You'd mapped the overpass for a week. A Grade 2's Office bought the map, closed the contract, and mentioned you in their report." },
			},
		},
	},
	{
		id = "fx_own_sign",
		title = "Your Own Sign",
		text = "You've been a Grade 5 long enough that clients ask for you by name instead of by Office. Old Fixers say there comes a moment when you either hang your own sign or stay someone else's best Fixer forever. A landlord down the street has a ground-floor room with a good door and a window facing the noodle stalls.",
		weight = 16,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "fx_grade_five" }, notFlags = { "fx_office_own" } },
		codex = "fx_lore_offices",
		choices = {
			{
				label = "Start saving for your own Office",
				result = { quest = "fx_q_own_office", log = "You took down the landlord's number and started a jar labeled SIGN." },
			},
			{
				label = "Stay someone else's best Fixer",
				result = { paycheck = 0.4, sanity = 2, log = "You told your Rep you were staying. She raised your cut and stopped pretending she hadn't been worried." },
			},
			{
				label = "Ask your Rep to make you a partner",
				clash = { stat = "mind", foe = "Your Rep's pride", coins = 2, base = 5, coinPower = 3 },
				win = { paycheck = 0.6, setFlags = { "fx_office_partner" }, log = "Your Rep painted your name on the door under hers. It was smaller. It was there." },
				lose = { sanity = -3, log = "Your Rep laughed, then saw you weren't joking, and stopped. Things were awkward at the Office for a season." },
			},
		},
	},
	{
		id = "fx_apprentice",
		title = "A Kid at the Door",
		text = "A kid of about fourteen has waited outside your Office every morning for a week, holding a broom handle like a sword. Today they knock. \"I want to be a Fixer,\" they say. \"I want to be you.\" Their shoes have been mended more times than shoes are meant to be.",
		weight = 14,
		once = true,
		tags = { "fixers" },
		when = { career = FIXER_CAREERS, minAge = 30, flags = { "licensed_fixer" } },
		choices = {
			{
				label = "Take them on as your apprentice",
				result = { addRelation = { kind = "child", age = { 13, 15 }, bond = 60 }, setFlags = { "parent", "fx_apprentice" }, sanity = 4, log = "You handed {newRelation} a real practice sword and the worst job on the board. They thanked you for both, and moved into your spare room by winter." },
			},
			{
				label = "Pay their academy fees",
				hint = "60 Ahn",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 3, log = "You paid a year at the academy and wrote the teacher a note. The kid sends you their marks every spring, circled in red." },
			},
			{
				label = "Tell them the truth about the job",
				result = { mind = 1, sanity = -1, log = "You told them about the clinic beds and the Night and the friends who stopped answering. They listened to all of it and came back the next morning anyway." },
			},
		},
	},
	{
		id = "fx_butler_offer",
		title = "A Butler's Contract",
		text = "An old Nest family wants a Butler: a Fixer on a long contract to guard the estate, drive the children, and stand very still in doorways. The pay is steady and the contract runs until the family says otherwise. Plenty of high-grade Fixers retire into work like this. Leaving early is not done.",
		weight = 12,
		once = true,
		tags = { "fixers", "luxury" },
		when = { career = "fixer", flags = { "fx_grade_five" }, minAge = 35 },
		codex = "fx_lore_butlers",
		choices = {
			{
				label = "Sign the contract",
				result = { money = { 300, 500 }, setFlags = { "fx_butler" }, schedule = { event = "fx_butler_years", inYears = 10 }, log = "You signed in front of an Öufi notary and started walking to the Nest checkpoint every dawn. The family's youngest calls you Sir Fixer, and means it." },
			},
			{
				label = "Decline politely",
				result = { sanity = 1, log = "You thanked them and said you weren't ready to stand still in doorways yet. The family's lawyer looked almost relieved." },
			},
			{
				label = "Recommend a retiring friend",
				result = { wage = { 40, 80 }, log = "You recommended a Grade 3 with bad knees. The family paid you a finder's fee, and the Grade 3 sent you a jar of estate honey every winter." },
			},
		},
	},
	{
		id = "fx_butler_years",
		title = "Ten Years in Doorways",
		text = "Ten years into the Butler contract, you know which floorboards in the estate creak and which of the family's children lie about homework. The youngest asks why you never leave. The honest answer is in the contract: a Butler who walks out early brings bounty hunters and contract-enforcement Offices to their own door.",
		weight = 0,
		when = { flags = { "fx_butler" } },
		codex = "fx_lore_butlers",
		choices = {
			{
				label = "Stay to the end",
				result = { paycheck = 0.5, sanity = 2, log = "You stayed. The children grew up. One of them still writes to you every spring." },
			},
			{
				label = "Negotiate a quiet release",
				clash = { stat = "charisma", foe = "The family's lawyers and an Öufi notary", coins = 3, base = 5, coinPower = 3 },
				win = { clearFlags = { "fx_butler" }, money = { 200, 400 }, sanity = 4, log = "You walked away with a release, a bonus, and a letter saying you'd done nothing wrong. You framed the letter." },
				lose = { money = { -200, -100 }, sanity = -4, log = "The release cost you two years of savings in penalties. The family was very sorry about it, in writing." },
			},
			{
				label = "Walk out tonight",
				result = { clearFlags = { "fx_butler" }, sanity = 3, schedule = { event = "fx_butler_hunters", inYears = 1 }, log = "You walked out the servants' gate at midnight with one bag. You felt lighter than you had in ten years, and you checked behind you every block." },
			},
		},
	},
	{
		id = "fx_butler_hunters",
		title = "Contract Enforcement",
		text = "Two Fixers from a contract-enforcement Office are waiting on your stairs, holding a copy of your old Butler contract with the early-exit clause underlined in red. \"Nothing personal,\" says the taller one. \"Somebody paid for this, and the contract says somebody pays for it.\"",
		weight = 0,
		when = { minAge = 18 },
		choices = {
			{
				label = "Fight them on the stairs",
				clash = { stat = "strength", foe = "Two contract enforcers", coins = 3, base = 5, coinPower = 3, fight = true, status = "poise" },
				win = { strength = 2, sanity = 2, log = "You sent them back down the stairs with a message for whoever paid them. Nobody came after that." },
				lose = { health = { -11, -5 }, money = { -150, -60 }, log = "They collected the penalty, plus a little extra for the stairs.", cause = "Ran from a Butler's contract" },
			},
			{
				label = "Pay the penalty",
				result = { money = { -260, -160 }, sanity = -2, log = "You paid. The taller one gave you a receipt and said it was a pleasure doing business, and seemed to mean it." },
			},
		},
	},

	-- ── Grade 3 and 2 ──
	{
		id = "fx_hazard_review",
		title = "Grading a Threat",
		text = "Hana's hazard assessors want a senior Fixer's opinion. Something has been eating the streetlights in the warehouse quarter, one a night. The form asks a simple question: Urban Myth, Urban Legend, or Urban Plague? The grade decides who gets sent, and what it costs the people who live there.",
		weight = 16,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "senior_fixer" } },
		codex = "fx_lore_hazards",
		choices = {
			{
				label = "Go and look before you grade it",
				clash = { stat = "strength", foe = "The streetlight eater", coins = 3, base = 6, coinPower = 3, fight = true, status = "charge" },
				win = { wage = { 150, 260 }, mind = 2, log = "You went into the dark quarter with a lamp and came out without it. You graded it Urban Legend, and signed your name." },
				lose = { health = { -11, -5 }, sanity = -5, log = "It found you first. You graded it Urban Plague from a clinic bed, and nobody argued.", cause = "Investigating a hazard grade" },
			},
			{
				label = "Grade it high, to be safe",
				result = { paycheck = 0.3, sanity = -2, log = "You graded it Urban Plague. Zwei came in force, and the residents paid for it in fees for years." },
			},
			{
				label = "Grade it low, to keep it cheap",
				clash = { stat = "mind", foe = "The risk", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 80, 140 }, sanity = 2, log = "You graded it Urban Myth. A cheap Office handled it, and the residents could afford them. You were right, this time." },
				lose = { sanity = -8, log = "You graded it Urban Myth. The cheap Office that took it didn't come back. You still have the form." },
			},
		},
	},
	{
		id = "fx_hana_invitation",
		title = "A Letter from Hana",
		text = "The envelope carries Hana's seal. Inside is an invitation: Hana wants senior Fixers with clean records for its examiners. Licensing exams, grading reports, the occasional hazard review. You would be the one holding the clipboard, and every new Fixer in the District would learn your handwriting.",
		weight = 14,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "senior_fixer" } },
		codex = "fixers_hana",
		choices = {
			{
				label = "Accept",
				requires = { min = { mind = 45 } },
				result = { career = "hana", log = "You turned in your Office keys and picked up a Hana clipboard. At your first exam you caught three cheats and passed a kid who reminded you of yourself." },
			},
			{
				label = "Decline: you'd rather work",
				result = { sanity = 2, strength = 1, log = "You wrote back that you'd rather be graded than grade. Hana sent a polite reply, and filed your letter somewhere you'll never see." },
			},
			{
				label = "Recommend your old mentor",
				requires = { hasRelation = "mentor" },
				result = { relationBond = { kind = "mentor", amount = 15 }, sanity = 2, log = "You put your old mentor's name forward instead. They complained for a week and then wore the Hana coat everywhere." },
			},
		},
	},
	{
		id = "fx_grade_review",
		title = "The Review Board",
		text = "Hana has called you before a review board: three senior assessors, your entire stack of job reports, and one question. \"Why should the City trust you with Grade 1 work?\" Grade 1 jobs are the ones that end careers, Offices, and sometimes streets. There aren't many Grade 1 Fixers, and there is a reason.",
		weight = 30,
		cooldown = 3,
		tags = { "fixers" },
		when = { career = "fixer", minRank = 8, notFlags = { "grade_one_fixer" } },
		codex = "fx_lore_reports",
		choices = {
			{
				label = "Let the reports speak",
				requires = { trait = "fx_clean_reports" },
				result = { promote = true, sanity = 4, log = "The board read your reports in silence for an hour. Then the eldest assessor stamped the last page, and that was that." },
			},
			{
				label = "Answer them yourself",
				clash = { stat = "mind", foe = "Three Hana assessors", coins = 3, base = 6, coinPower = 3 },
				win = { promote = true, sanity = 3, log = "You told them about the jobs you'd turned down, not the ones you'd won. They exchanged a look, and the eldest one nodded." },
				lose = { sanity = -3, log = "They thanked you for your time and said the board would sit again next year." },
			},
			{
				label = "Ask for a practical instead",
				clash = { stat = "strength", foe = "A Hana Section Director", coins = 3, base = 7, coinPower = 3, fight = true, status = "poise" },
				win = { promote = true, strength = 2, log = "The Director tested you for six minutes and stopped. \"Enough,\" she said. \"I'd like to keep my Section.\"" },
				lose = { health = { -8, -3 }, sanity = -2, log = "She was everything a Hana Director is supposed to be. You woke up being told you'd done very well, for a Grade 2." },
			},
		},
	},

	-- ── Grade 1 ──
	{
		id = "fx_grade_one_news",
		title = "Grade 1",
		text = "Hana's letter is one line long: you are now a Grade 1 Fixer, as high as the scale goes. Your old Office throws a party you didn't ask for. Somebody's kid asks for your autograph on a noodle napkin. Rival Offices raise their prices to look serious, and clients lower their voices when they say your name.",
		weight = 300,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", minRank = 9 },
		codex = "fx_lore_colors",
		choices = {
			{
				label = "Celebrate with the ones who knew you at Grade 9",
				result = { sanity = 6, relationBond = { kind = "all", amount = 5 }, chronicle = "fx_grade_one", log = "You ate noodles with everyone who'd known you when you fetched the noodles. Somebody made a speech. Somebody cried. It was you." },
			},
			{
				label = "Raise your rates",
				result = { wage = { 200, 400 }, chronicle = "fx_grade_one", log = "You tripled your rates. The clients paid without blinking, and the rival Offices took down their prices." },
			},
			{
				label = "Go straight back to work",
				result = { strength = 2, chronicle = "fx_grade_one", log = "You read the letter, folded it, and took a contract that afternoon. People called it humble. It was mostly nerves." },
			},
		},
	},
	{
		id = "fx_upstart_duel",
		title = "Someone Wants Your Grade",
		text = "A Grade 2 with a brand-new Workshop blade challenges you in front of the job board, loud enough for the whole street to hear. If they beat a Grade 1 in front of witnesses, Hana will notice. If they lose, nobody will remember their name. They have clearly only thought about the first part.",
		weight = 14,
		cooldown = 6,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "grade_one_fixer" } },
		choices = {
			{
				label = "Accept the duel",
				clash = { stat = "strength", foe = "An ambitious Grade 2", coins = 3, base = 7, coinPower = 3, fight = true, status = "poise" },
				win = { strength = 1, sanity = 3, log = "You ended it in three moves and helped them up. Then you told them what they'd done wrong, which hurt more than the duel." },
				lose = { health = { -11, -5 }, sanity = -5, log = "You lost, in front of everyone. Hana didn't take your grade. The street took something anyway.", cause = "Lost a duel over a Grade 1 title" },
			},
			{
				label = "Walk away",
				result = { mind = 2, sanity = -1, log = "You walked away. Half the street called you a coward. The other half, the half with grades, understood." },
			},
			{
				label = "Offer to train them instead",
				result = { sanity = 2, intelligence = 1, log = "They were so surprised they forgot to be angry. They turned up at dawn the next day, with tea." },
			},
		},
	},
	{
		id = "fx_color_offer",
		title = "No Number, a Color",
		text = "A Hana courier hands you an envelope with no return address and a single sheet inside. It has no number on it. It has a color. Hana grants Colors to Fixers beyond the scale, perhaps one in a generation, and asks only that you choose the epithet the City will know you by from now on.",
		weight = 8,
		once = true,
		tags = { "fixers" },
		when = { career = "fixer", flags = { "grade_one_fixer" }, min = { strength = 75 } },
		codex = "fx_lore_colors",
		choices = {
			{
				label = "The Grey Vigil",
				result = color("grey", "From that day the City called you the Grey Vigil. Children in your old street played at being you, standing very still in doorways."),
			},
			{
				label = "The Verdant Ledger",
				result = color("green", "From that day the City called you the Verdant Ledger, for the reports. Every Grade 9 in the District bought a green notebook."),
			},
			{
				label = "The Amber Toll",
				result = color("amber", "From that day the City called you the Amber Toll, the price that troublemakers pay. Rats crossed whole Districts to avoid your street."),
			},
			{
				label = "Send the sheet back",
				result = { sanity = 4, mind = 3, setFlags = { "fx_refused_color" }, log = "You sent the sheet back unsigned. Hana had never been refused before. It wrote your name in a very different file." },
			},
		},
	},
	{
		id = "fx_retire",
		title = "Hanging Up the Coat",
		text = "Your knees tell you the weather before the radio does, and the last contract took a week to recover from instead of a night. Younger Fixers hold doors for you. Your Rep, or your Director, has started saying \"when you're ready\" in the tone that means now.",
		weight = 25,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = FIXER_CAREERS, minAge = 56 },
		choices = {
			{
				label = "Retire while you still can",
				result = { quitCareer = true, wage = { 150, 300 }, sanity = 6, setFlags = { "fx_retired" }, log = "You hung your coat on a hook by the door and left it there. The first Night you slept straight through, you woke up laughing." },
			},
			{
				label = "Teach at an academy instead",
				result = { career = "academy", sanity = 4, setFlags = { "fx_retired" }, log = "You started teaching licensing classes at a Backstreets academy. Your first lesson was the Taboos. Your second was why the first lesson matters." },
			},
			{
				label = "One more year",
				result = { paycheck = 0.4, health = -3, log = "One more year, you said. You've been saying that for a while." },
			},
		},
	},

	-- ── Colors, as legends ──
	{
		id = "fx_legend_red_mist",
		title = "The Red Mist",
		text = "An old veteran at the noodle stall tells the same story every winter: the Smoke War, a burning street, and a Fixer in red who walked through the smoke as if it were nothing. \"The Red Mist,\" he says. \"Strongest Fixer there ever was. A whole army stopped to watch her pass.\" She's been dead since before you were born. The story hasn't noticed.",
		weight = 6,
		once = true,
		tags = { "fixers" },
		when = { minAge = 10 },
		codex = "fx_lore_colors",
		choices = {
			{
				label = "Ask how she died",
				result = { mind = 1, sanity = 1, log = "\"Out past the wall, they say. Something the Head sent. Nobody saw it, so everybody tells it.\" He shrugged. \"She's an urban legend now. That's what the City does with people it couldn't beat.\"" },
			},
			{
				label = "Ask what a Color is",
				result = { intelligence = 1, setFlags = { "fx_dream" }, log = "Hana gives a Color to Fixers beyond Grade 1, he said: a color and a name the whole City calls you by. \"Every Fixer's dream. Every Fixer's nightmare, if they meet one on the wrong side.\"" },
			},
			{
				label = "Buy him another bowl",
				hint = "5 Ahn",
				requires = { min = { money = 5 } },
				result = { money = -5, sanity = 3, log = "He told you two more stories for the price of the bowl. At least one of them was true." },
			},
		},
	},
	{
		id = "fx_legend_indigo",
		title = "The Old Harpooner",
		text = "On the Great Lake docks, the harpooneers tell stories about the Indigo Elder: an old man in a small skiff who hunted the Marlin Whale and came back, which is why Hana made him a Color. They say he throws a harpoon faster than eyes can follow, and that the fog goes quiet when he's out fishing.",
		weight = 10,
		once = true,
		tags = { "fixers" },
		when = { district = "d21", minAge = 10 },
		codex = "fx_lore_colors",
		choices = {
			{
				label = "Ask how a sailor gets a license",
				result = { intelligence = 1, codex = "fx_lore_associations", log = "\"Sail one season on a whaler,\" a harpooneer said, \"and the Eight Association gives you a Grade 9 license for your trouble. If you come back.\"" },
			},
			{
				label = "Watch the fog for his skiff",
				result = { mind = 2, sanity = 2, setFlags = { "fx_saw_color" }, log = "You watched the fog for an hour. For a moment you saw a small boat with something huge lashed to the bow. Then the fog closed." },
			},
			{
				label = "Laugh at the stories",
				result = { sanity = -1, log = "A harpooneer looked at you the way people look at someone laughing about the Night. You stopped laughing." },
			},
		},
	},
	{
		id = "fx_legend_purple",
		title = "A Woman in Purple",
		text = "A tall woman in purple passes through the District, asking quiet questions at every Office and every clinic. Fixers who see her go pale and very polite. Someone whispers that she's the Purple Tear, a Color Fixer, and that she's searching for someone. Nobody knows who, and nobody wants to be the one she finds.",
		weight = 5,
		once = true,
		tags = { "fixers" },
		when = { minAge = 14, world = { era = { "library", "limbus" } } },
		codex = "fx_lore_colors",
		choices = {
			{
				label = "Answer her questions",
				clash = { stat = "mind", foe = "A Color's full attention", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 3, mind = 2, setFlags = { "fx_saw_color" }, log = "She asked about a name you'd never heard, thanked you, and pressed a coin into your hand for your time. The coin was purple." },
				lose = { sanity = -4, log = "You stammered so badly that she apologized for bothering you. You'll think about that apology for years." },
			},
			{
				label = "Stay out of her way",
				result = { mind = 1, sanity = -1, log = "You watched her from behind a noodle stall until she left the street. Your hands didn't stop shaking until evening." },
			},
			{
				label = "Warn every Office you know",
				result = { wage = { 10, 30 }, sanity = 1, log = "Half the Offices in the District closed for the day. The other half doubled their prices. Both paid you for the warning." },
			},
		},
	},
}
