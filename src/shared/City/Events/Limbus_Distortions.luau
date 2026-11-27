--[[
	The Distortion era (983+): Distortions by stage, talking one down or fighting it,
	a neighbor at the brink, Location-type Distortions, Peccatula, and the Fixers and
	Limbus Company departments who handle them. Writer D (lim_ ids).
	Canon notes: docs/CANON.md sections 1.3, 7.1 and 9.1 ("The brink").

	The neighbor arc follows the stages (CANON 1.3): Incubation (lim_neighbor_signs),
	Early (lim_neighbor_early), Late (lim_neighbor_late). Listening early makes the
	talk-down easy later; looking away makes it a fight.
]]

local ERA = { era = "limbus" }

return {
	-- shared: a lost Distortion fight you lived through (triggered, so it never runs for the dead)
	{
		id = "lim_distortion_aftermath",
		when = { world = { era = { "library", "limbus" } } },
		title = "Still Standing",
		text = "You wake up in a Backstreets clinic with a Fixer's business card tucked into your bandages. The Distortion is gone. You are not.",
		weight = 0,
		result = { sanity = -2, setFlags = { "lim_distortion_survivor" }, log = "You lived through a Distortion. The card said: \"For next time. Ten percent off.\"" },
	},

	-- ── the neighbor at the brink ──
	{
		id = "lim_neighbor_signs",
		title = "The Clockmaker Downstairs",
		text = "Oskar Lindgren, the clockmaker downstairs, has stopped sleeping. Every night he repairs the same clock, and every morning it still doesn't run. Yesterday his shadow moved half a second after he did. He laughed it off. The laugh was too big for the room.",
		weight = 22,
		once = true,
		tags = { "distortion" },
		when = { world = ERA, minAge = 14 },
		codex = "lim_distortion_stages",
		choices = {
			{
				label = "Sit with him and listen",
				result = { sanity = -1, intelligence = 1, setFlags = { "lim_oskar_heard" }, schedule = { event = "lim_neighbor_early", inYears = 2 }, log = "You sat in his shop until midnight. The clock belonged to his daughter, who moved to a Nest and stopped writing. He fixes it so he'll have something to send her. You promised to come back." },
			},
			{
				label = "Call the LCD hotline",
				hint = "Limbus Company's Distortion department.",
				result = { schedule = { event = "lim_neighbor_lcd", inYears = 1 }, log = "You called the number on the Limbus Company poster at the end of the street. A calm voice took his name and asked what time his shadow had been late. You hadn't thought to check." },
			},
			{
				label = "Mind your own business",
				result = { sanity = 1, setFlags = { "lim_oskar_ignored" }, schedule = { event = "lim_neighbor_early", inYears = 2 }, log = "Everyone in the City has a bad year. You nodded to him on the stairs and kept walking." },
			},
		},
	},
	{
		id = "lim_neighbor_early",
		title = "Clocks Running Backwards",
		text = "Every clock in Oskar's shop runs backwards now, and the stairwell smells of oil and old paper. He stops you on the landing to ask what day it is, and when you tell him he shakes his head. \"No,\" he says, very politely. \"I don't think so.\" This is the Early stage. There is still a person in there.",
		weight = 0,
		when = { world = ERA, minAge = 14 },
		codex = "lim_distortion_stages",
		choices = {
			{
				label = "Talk about his daughter's clock",
				hint = "You know what he's carrying.",
				requires = { flags = { "lim_oskar_heard" } },
				result = { sanity = 5, setFlags = { "lim_distortion_survivor", "lim_talked_down" }, addTrait = "lim_talks_them_down", chronicle = "lim_talked_down", codex = "lim_inflection_point", addRelation = { kind = "friend", name = "Oskar Lindgren", bond = 70, age = { 50, 62 } }, log = "You told him the clock didn't need to run for her to want it. You helped him wrap it and post it to the Nest that night. In the morning his clocks ran forward again. The LCD called it an Inflection Point, resolved. Oskar calls it the day you came back." },
			},
			{
				label = "Find where it started",
				hint = "Mental Strength check. Find the Inflection Point.",
				clash = { stat = "mind", foe = "Oskar's backwards clocks", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = 4, setFlags = { "lim_distortion_survivor", "lim_talked_down" }, addTrait = "lim_talks_them_down", chronicle = "lim_talked_down", codex = "lim_inflection_point", addRelation = { kind = "friend", name = "Oskar Lindgren", bond = 60, age = { 50, 62 } }, log = "It took you three nights of questions to find it: a letter from his daughter he'd never opened. You read it to him. It said she missed him. The clocks stopped, then started again, forwards." },
				lose = { sanity = -4, schedule = { event = "lim_neighbor_late", inYears = 1 }, log = "Every question you asked, he answered with the time. The wrong time. You went upstairs and couldn't sleep either." },
			},
			{
				label = "Get him to the LCD",
				result = { trigger = "lim_neighbor_lcd", log = "You walked him to the Limbus Company office yourself. He held your arm on the stairs like an old man, and the whole way he kept asking what day it was." },
			},
			{
				label = "Find somewhere else to sleep for a while",
				result = { money = -40, sanity = -2, schedule = { event = "lim_neighbor_late", inYears = 1 }, log = "You stayed with a friend across the District. You told yourself it was for a week. You knew it wasn't." },
			},
		},
	},
	{
		id = "lim_neighbor_late",
		title = "The Shop Full of Ticking",
		text = "There is no clockmaker in the shop downstairs anymore. There is a shape of gears and pendulums that fills the room from wall to wall, ticking in a hundred rhythms at once, and the stairwell outside skips seconds when you climb it. It still wears his apron. It still keeps the shop's hours.",
		weight = 0,
		when = { world = ERA, minAge = 14 },
		codex = "lim_distortion_stages",
		choices = {
			{
				label = "Talk to it anyway",
				hint = "Charisma check. Late stage: nobody comes back from this, but it can be calmed.",
				clash = { stat = "charisma", foe = "What Oskar became", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = 2, setFlags = { "lim_distortion_survivor" }, chronicle = "calmed_distortion", log = "You told it about the daughter in the Nest and the clock that didn't need to run. The ticking slowed until it was one rhythm. When the LCD came, it let them lead it out like a man leaving his shop at closing time." },
				lose = { sanity = -8, condition = "distortion_signs", setFlags = { "lim_distortion_survivor" }, log = "It answered in a hundred clocks at once. You lost an hour on the stairs and you still don't know where it went." },
			},
			{
				label = "Fight it before it spreads",
				clash = { stat = "strength", foe = "A Distortion of gears", coins = 3, base = 6, coinPower = 3, fight = true, status = "tremor" },
				win = { strength = 2, wage = { 60, 140 }, setFlags = { "lim_distortion_survivor" }, chronicle = "fought_distortion", log = "You broke its rhythm one pendulum at a time until the ticking stopped. The Fixers who arrived late paid you a finder's fee and swept up the gears. You kept one. You don't know why." },
				lose = { health = { -16, -7 }, sanity = -6, cause = "Fought the Distortion in the clock shop", trigger = "lim_distortion_aftermath", log = "Time skipped. When it started again you were at the bottom of the stairs, and something in you was broken." },
			},
			{
				label = "Call in your Limbus Company plan",
				hint = "You pay for Distortion management.",
				requires = { flags = { "lim_suppression_plan" } },
				result = { sanity = -2, setFlags = { "lim_distortion_survivor" }, codex = "lim_departments", log = "Three LCD agents arrived in eleven minutes, thanked you for being a valued customer, and sealed the shop. They were very professional. You would have liked them to be sad." },
			},
			{
				label = "Get the building out and call the Fixers",
				result = { sanity = -4, setFlags = { "lim_distortion_survivor" }, log = "You knocked on every door and got everyone out into the street. A Fixer office handled the rest. It took them most of the night, and nobody on the street talked about Oskar afterward." },
			},
		},
	},
	{
		id = "lim_neighbor_lcd",
		title = "The LCD Takes the Case",
		text = "Two investigators from Limbus Company's LCD arrive in grey coats, carrying notebooks instead of weapons. OSIR Team, they say: On-site Investigative Reasoning. \"Every Distortion has an Inflection Point,\" the older one tells you. \"The moment it tipped. You know him. Help us find it.\"",
		weight = 0,
		when = { world = ERA },
		codex = "lim_inflection_point",
		choices = {
			{
				label = "Tell them everything you've noticed",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A case file with three pages missing", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 4, setFlags = { "lim_distortion_survivor", "lim_talked_down" }, chronicle = "lim_talked_down", addRelation = { kind = "friend", name = "Oskar Lindgren", bond = 55, age = { 50, 62 } }, schedule = { event = "lim_lcd_offer", inYears = 1 }, log = "The broken clock, the daughter in the Nest, the letters he stopped opening. The older investigator wrote it all down and nodded. \"That's it.\" Oskar came home a month later, thin and embarrassed, with a clock that runs." },
				lose = { sanity = -5, log = "You told them what you could. It wasn't enough. They took Oskar for \"observation\". His shop has a new tenant now, who doesn't know why the neighbors look at him like that." },
			},
			{
				label = "Ask what happens to him if they can't",
				result = { mind = 2, sanity = -3, codex = "lim_distortion_stages", log = "\"Then we manage it,\" the investigator said. \"That's the business.\" They took Oskar for observation. You never found out what managing meant." },
			},
		},
	},

	-- ── Distortions in the street ──
	{
		id = "lim_distortion_alley",
		title = "Something in the Alley",
		text = "The alley behind the noodle shop is full of envelopes, thousands of them, drifting like snow that falls up. In the middle stands something that used to be a courier: wheels where its feet should be, a satchel that breathes. It is sorting the envelopes, very fast, and crying. It hasn't seen you yet.",
		weight = 14,
		cooldown = 12,
		tags = { "distortion", "danger" },
		when = { world = ERA, minAge = 14 },
		codex = "terms_distortion",
		choices = {
			{
				label = "Talk to it about the deliveries",
				hint = "Charisma check. Some of them still answer.",
				clash = { stat = "charisma", foe = "A Distortion of envelopes", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = 4, charisma = 2, setFlags = { "lim_distortion_survivor" }, chronicle = "calmed_distortion", log = "You asked whose letters they were. It told you, all of them, every name. When it ran out of names it sat down in the envelopes and stopped moving, and the LCD found it like that an hour later." },
				lose = { sanity = -7, condition = "distortion_signs", setFlags = { "lim_distortion_survivor" }, log = "It handed you an envelope with your own name on it. You didn't open it. You still haven't. It's still in your pocket." },
			},
			{
				label = "Fight it before it gets to the street",
				clash = { stat = "strength", foe = "A Distortion of envelopes", coins = 3, base = 5, coinPower = 3, fight = true, status = "rupture" },
				win = { strength = 2, wage = { 40, 110 }, setFlags = { "lim_distortion_survivor" }, chronicle = "fought_distortion", log = "You kept it in the alley until a Fixer office arrived. When it was over the envelopes were just paper. A Fixer pressed some Ahn into your hand and told you to get a real weapon." },
				lose = { health = { -14, -6 }, sanity = -5, cause = "Fought a Distortion in an alley", trigger = "lim_distortion_aftermath", log = "Its wheels came at you faster than anything has a right to move." },
			},
			{
				label = "Call in your Limbus Company plan",
				hint = "You pay for Distortion management.",
				requires = { flags = { "lim_suppression_plan" } },
				result = { sanity = -1, setFlags = { "lim_distortion_survivor" }, log = "You called the number on your plan card. LCD agents had the alley sealed in nine minutes and sent you a satisfaction survey the next morning." },
			},
			{
				label = "Back away slowly",
				result = { sanity = -3, log = "You backed out of the alley one step at a time. You took the long way to work for a year." },
			},
		},
	},
	{
		id = "lim_location_distortion",
		title = "The Fourteenth Floor",
		text = "Your building has thirteen floors. At night, lately, the stairs keep going: a fourteenth floor, then a fifteenth, with doors that open onto rooms from other buildings. A woman in a grey LCD coat is sitting on the stairs with a notebook. \"Ezra, OSIR Team,\" she says. \"This is a Location-type Distortion. The building is the Distortion. I need someone who knows how it used to be.\"",
		weight = 12,
		once = true,
		tags = { "distortion", "strange" },
		when = { world = ERA, minAge = 16 },
		codex = "lim_distortion_stages",
		choices = {
			{
				label = "Help her map it",
				hint = "Intelligence check. Find the Inflection Point.",
				clash = { stat = "intelligence", foe = "A building that keeps changing", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 2, sanity = 3, setFlags = { "lim_distortion_survivor", "lim_talked_down" }, chronicle = "lim_talked_down", codex = "lim_inflection_point", schedule = { event = "lim_lcd_offer", inYears = 1 }, log = "You drew every floor you knew, and Ezra drew every floor you didn't. The extra floors all led back to one room on the ninth: an old man's flat, packed for a move nobody had let him make. The LCD found him somewhere to go. The stairs stopped at thirteen." },
				lose = { sanity = -5, condition = "night_terrors", log = "You opened a door on the fifteenth floor that led into your own kitchen, from the wrong side. Ezra pulled you back. You didn't sleep in the building again." },
			},
			{
				label = "Stay with a friend until it's over",
				result = { money = -30, sanity = 1, log = "You slept on a friend's floor for a month. When you came back the building had thirteen floors and a new landlord, and nobody would say what happened to the old one." },
			},
			{
				label = "Climb to the top floor",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Floor after floor", coins = 3, base = 6, coinPower = 3 },
				win = { mind = 3, sanity = -2, setFlags = { "lim_distortion_survivor" }, codex = "lim_inflection_point", log = "On the twenty-second floor there was a roof garden that doesn't exist, and an old man watering it. He looked up and said, \"I didn't want to leave.\" You told Ezra. She closed her notebook. \"Thank you. That's the whole case.\"" },
				lose = { sanity = -8, health = -4, log = "The stairs went on longer than you could. You woke up on the ground floor at dawn with your shoes worn through." },
			},
		},
	},

	-- ── Peccatula ──
	{
		id = "lim_peccatula_lot",
		title = "Branches in the Empty Lot",
		text = "Something is growing in the empty lot at the end of your street: thin, branch-like things the height of a child, with cracks in them that glow a dull red. They turn to watch people walk past. A notice from Limbus Company on the fence says PECCATULUM, CLASS 1. DO NOT FEED. The fence is two feet high.",
		weight = 14,
		once = true,
		tags = { "distortion" },
		when = { world = ERA, minAge = 12 },
		codex = "lim_peccatula",
		choices = {
			{
				label = "Clear them out while they're small",
				hint = "A fight. They're only Class 1. For now.",
				clash = { stat = "health", foe = "Peccatula Irae, Class 1", coins = 2, base = 4, coinPower = 3, fight = true, status = "rupture" },
				win = { health = 1, wage = { 30, 90 }, chronicle = "lim_peccatula_cleared", log = "You and two neighbors went in with shovels and a lot of nerve. The red cracks went dark one by one. An LCE researcher paid you for the branches by the kilo." },
				lose = { health = { -10, -4 }, sanity = -3, cause = "Cut down by Peccatula", schedule = { event = "lim_peccatula_grown", inYears = 2 }, log = "One of them was bigger than it looked. You limped out of the lot and left the rest of them growing." },
			},
			{
				label = "Report it to the LCE",
				result = { wage = { 20, 50 }, codex = "lim_departments", log = "An LCE team came with a van and very long tongs. They paid you a small bounty and left you a pamphlet called \"Living With Peccatula\"." },
			},
			{
				label = "Leave it alone",
				result = { sanity = -1, schedule = { event = "lim_peccatula_grown", inYears = 2 }, log = "You crossed to the other side of the street, like everyone else. The branches watched you go." },
			},
		},
	},
	{
		id = "lim_peccatula_grown",
		title = "Class 2",
		text = "The branches in the lot are taller than the fence now, and the red cracks have spread into the pavement. The notice says CLASS 2. A Fixer office has been hired to clear it, and its Rep is looking for anyone local who knows the lot. \"Daily rate,\" she says. \"Don't touch the red bits.\"",
		weight = 0,
		when = { world = ERA, minAge = 12 },
		codex = "lim_peccatula",
		choices = {
			{
				label = "Join the clearing crew",
				clash = { stat = "strength", foe = "Peccatula Irae, Class 2", coins = 3, base = 5, coinPower = 3, fight = true, status = "rupture" },
				win = { strength = 2, wage = { 70, 160 }, chronicle = "lim_peccatula_cleared", log = "It took a whole day. By dusk the lot was ash and broken branches, and the street came out to watch the Rep hammer a SOLD sign into the ground." },
				lose = { health = { -14, -6 }, sanity = -3, cause = "Cut down clearing Peccatula", log = "A branch you thought was dead wasn't. The Fixers finished the job without you." },
			},
			{
				label = "Show them the way in and stay back",
				result = { wage = { 20, 40 }, mind = 1, log = "You showed the Rep the gap in the back fence and the drain the roots were following. She paid you a guide's fee and told you to go home." },
			},
			{
				label = "Move to another street",
				result = { money = -40, sanity = 2, log = "You found a room three streets over. You can still see the red glow from your window, but only if you look." },
			},
		},
	},

	-- ── Fixers and companies against Distortions ──
	{
		id = "lim_fixer_distortion_job",
		title = "Graded: Urban Myth",
		text = "Hana has graded a Distortion in the Backstreets as an Urban Myth, and your Office has taken the contract. It was a baker, the briefing says, and now it's an oven the size of a shop that walks. The Rep looks at you over the file. \"You're on it.\"",
		weight = 14,
		cooldown = 8,
		tags = { "distortion", "fixers" },
		when = { world = ERA, flags = { "licensed_fixer" }, minAge = 16 },
		codex = "lib_hazard_grades",
		choices = {
			{
				label = "Take point",
				clash = { stat = "strength", foe = "An Urban Myth Distortion", coins = 3, base = 6, coinPower = 3, fight = true, status = "burn" },
				win = { strength = 2, wage = { 150, 350 }, setFlags = { "lim_distortion_survivor" }, chronicle = "fought_distortion", log = "You went in first and came out last. The Rep filed the report with your name at the top, which is how Hana notices you." },
				lose = { health = { -16, -7 }, sanity = -4, wage = { 40, 80 }, cause = "Killed on a Distortion contract", trigger = "lim_distortion_aftermath", log = "It was hotter than the briefing said. The Office finished the job and paid you a share for the burns." },
			},
			{
				label = "Find its Inflection Point first",
				hint = "Mental Strength check. Talk to the people who knew the baker.",
				clash = { stat = "mind", foe = "An Urban Myth Distortion", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 2, wage = { 120, 280 }, setFlags = { "lim_distortion_survivor", "lim_talked_down" }, addTrait = "lim_talks_them_down", chronicle = "calmed_distortion", codex = "lim_inflection_point", log = "Her bakery had been sold out from under her the day before she distorted. You brought the old sign from the new owner's bins and set it where it could see. It cooled. The Office got the full fee, and nobody got hurt." },
				lose = { sanity = -5, wage = { 40, 90 }, log = "You talked to everyone who knew her and found nothing. The rest of the Office did it the loud way." },
			},
			{
				label = "Pass on this one",
				result = { sanity = 1, money = -20, log = "You passed. The Rep docked you for the briefing and gave the job to someone hungrier. You heard later it went badly." },
			},
		},
	},
	{
		id = "lim_distortion_spotter",
		title = "Spotters Wanted",
		text = "A Fixer office has pinned a notice to the noodle shop door: SPOTTERS WANTED. A Distortion was seen near the canal last week, and the Office wants eyes on the street every night until it shows itself again. Pay by the night. Bring a whistle.",
		weight = 12,
		once = true,
		tags = { "distortion" },
		when = { world = ERA, minAge = 16 },
		choices = {
			{
				label = "Take the night shifts",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Long nights by the canal", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 50, 120 }, mind = 2, setFlags = { "lim_distortion_survivor" }, log = "On the ninth night you saw it, blew the whistle, and ran exactly the way they told you to. The Office handled the rest and paid you a bonus." },
				lose = { wage = { 20, 50 }, sanity = -5, condition = "night_terrors", log = "Nothing came, every night, until you started hearing it come anyway. You quit after two weeks." },
			},
			{
				label = "Sell them a map of the canal streets",
				result = { wage = { 20, 40 }, intelligence = 1, log = "You drew them every back alley, drain and footbridge on the canal. The Rep studied it like a battle plan and paid you more than you asked." },
			},
			{
				label = "Leave it to the professionals",
				result = { sanity = 1, log = "You left it to the professionals and locked your door an hour earlier than usual." },
			},
		},
	},
	{
		id = "lim_suppression_plan",
		title = "Distortion Management, Door to Door",
		text = "A cheerful man in a Limbus Company jacket is selling Distortion management door to door. \"For a small yearly fee, our LCD will respond to any Distortion in your building within the hour. Peace of mind!\" His brochure has a picture of a smiling family and, in very small print, a list of what counts as a Distortion.",
		weight = 10,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, minAge = 20 },
		codex = "lim_departments",
		choices = {
			{
				label = "Sign up",
				hint = "120 Ahn. Some Distortion events get a safer way out.",
				requires = { min = { money = 120 } },
				result = { money = -120, setFlags = { "lim_suppression_plan" }, sanity = 3, log = "You signed. He gave you a card with a number on it and a sticker for your door. The sticker says PROTECTED BY LIMBUS COMPANY. Your neighbors' doors don't have one." },
			},
			{
				label = "Read the small print out loud",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A practiced salesman", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, codex = "lim_departments", log = "\"Distortions arising from the customer's own emotional state are not covered,\" you read. He smiled and moved on to the next door very quickly." },
				lose = { money = -10, log = "He talked you out of reading it and into buying a pamphlet. You don't remember agreeing." },
			},
			{
				label = "Shut the door",
				result = { sanity = 1, log = "You shut the door. Through it, you heard him start his speech again for your neighbor, word for word." },
			},
		},
	},

	-- ── the edge, from the inside ──
	{
		id = "lim_your_own_signs",
		title = "Your Shadow Is Late",
		text = "You notice it while brushing your teeth: your shadow on the bathroom wall moves a half-second after you do. Your feelings have been too big lately, and too loud. The LCD posters on every corner have a list of early signs. You have three of them.",
		weight = 20,
		cooldown = 10,
		tags = { "distortion" },
		when = { world = ERA, minAge = 16, max = { sanity = -15 } },
		codex = "lim_distortion_stages",
		choices = {
			{
				label = "See an LCD counselor",
				hint = "80 Ahn",
				requires = { min = { money = 80 } },
				result = { money = -80, sanity = 12, cure = "distortion_signs", codex = "lim_inflection_point", log = "The counselor asked when it started, and kept asking until you knew. Saying it out loud was like setting down a box you'd carried so long you forgot it was heavy. Your shadow keeps up now." },
			},
			{
				label = "Tell someone you love",
				requires = { hasRelation = { "mother", "father", "sibling", "child", "friend", "mentor" } },
				result = { sanity = 9, relationBond = { kind = "all", amount = 6 }, log = "You told them everything, badly, at the kitchen table. They didn't know what to say, so they made dinner and stayed. It helped more than any poster said it would." },
			},
			{
				label = "Keep it to yourself",
				result = { mind = 2, sanity = -3, condition = "distortion_signs", log = "You told no one. You started leaving the bathroom light off." },
			},
		},
	},
	{
		id = "lim_distortion_rumors",
		title = "What the Noodle Stall Says",
		text = "The noodle stall knows everything about Distortions, all of it contradictory. Don't say a Distortion's old name or it hears you. LCD agents can smell feelings. A Distortion can't cross running water, or can only cross running water. The old woman who runs the stall says one thing is true: \"They all started as somebody nobody was listening to.\"",
		weight = 8,
		once = true,
		tags = { "distortion" },
		when = { world = ERA, minAge = 10 },
		choices = {
			{
				label = "Ask what she means",
				result = { mind = 2, codex = "lim_distortion_stages", log = "She told you about her nephew, who stopped talking a year before he distorted, and how everyone had said he was just quiet. Then she gave you an extra egg and changed the subject." },
			},
			{
				label = "Argue about the running water",
				result = { sanity = 3, log = "You spent an hour arguing about running water with a retired Fixer and a schoolteacher. Nobody won. It was the best evening you'd had in a month." },
			},
			{
				label = "Go and listen to somebody",
				result = { sanity = 2, relationBond = { kind = "all", amount = 4 }, log = "You went home and called someone you hadn't spoken to in too long, and mostly listened. They sounded surprised, then glad." },
			},
		},
	},
	{
		id = "lim_distortion_drill",
		title = "Distortion Drill",
		text = "Your school runs a Distortion drill. When the bell rings three times, the teacher explains, everyone leaves the room in a line, quietly, \"even if the Distortion is me.\" She says it brightly, like it's a joke. Nobody laughs. Then the bell rings three times.",
		weight = 14,
		once = true,
		tags = { "distortion" },
		when = { world = ERA, minAge = 6, maxAge = 15 },
		codex = "terms_distortion",
		choices = {
			{
				label = "Do exactly as you were told",
				result = { mind = 2, log = "You were first in line and didn't look back. The teacher gave you a sticker. You felt strange about the sticker for a long time." },
			},
			{
				label = "Ask the teacher if she's all right",
				result = { intelligence = 1, sanity = 2, log = "After the drill you asked her if she was all right. She looked at you for a moment, then said, \"Better now,\" and let you clean the blackboard, which was the highest honor in that classroom." },
			},
			{
				label = "Make the whole class laugh in the line",
				result = { sanity = 3, strength = 1, log = "You did the teacher's voice saying \"even if the Distortion is me\" and the whole line cracked up. You got a detention. The teacher laughed too, afterward, when she thought nobody could see." },
			},
		},
	},
}
