--[[
	Ordinary adult life (area A): rent, family, children growing up, friends and rivals,
	a neighbor's debt, moving District, illness and clinics, the street's own business.
	Recurring people: Auntie Mun (the noodle stall), Grandpa Teo (the watch), Ottavio
	(the Fixer down the street), Teodor Halas (next door), Grandmother Ilse (the shelter).
]]

return {
	-- ── home and rent ──────────────────────────────────────────────────────
	{
		id = "bs_a_rent_day",
		title = "Rent Day",
		text = "The landlord is going door to door with a new rent book and an apologetic face that isn't sorry at all. Rent is going up by a fifth: the Syndicate raised his fees, he says, and the Wing raised his taxes, and somebody has to pay for all of it, and that somebody lives on the third floor.",
		weight = 10,
		cooldown = 12,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 18, maxAge = 75 },
		choices = {
			{
				label = "Haggle",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A landlord with a new rent book", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 20, 50 }, charisma = 1, log = "You reminded him how many years you'd paid on time, how many of his tenants had already moved out, and how much a new tenant's three locks would cost him. Your rent stayed where it was." },
				lose = { money = { -40, -15 }, sanity = -2, log = "He had an answer for everything, and the answer was always the new number. You paid it." },
			},
			{
				label = "Offer to fix the building's locks instead",
				result = { intelligence = 2, money = { -15, -5 }, log = "You offered to fix every lock in the building in exchange for keeping the old rent. He thought about the locksmith's prices and agreed. You spent a month of evenings on your knees in stairwells." },
			},
			{
				label = "Pay without a word",
				result = { money = { -30, -10 }, mind = 1, log = "You paid without a word. Everyone on the street paid without a word. That's how the City works, your mother used to say, and she was usually right." },
			},
		},
	},
	{
		id = "bs_a_teodor",
		title = "Teodor's Debt",
		text = "Teodor Halas next door is sitting on the stairs at midnight with his head in his hands. He borrowed two hundred Ahn from the Thumb last winter, when his daughter was ill, and the Thumb wants it back by the end of next week, with every courtesy, or not at all. \"I don't know what 'or not at all' means,\" he says. \"I'm afraid I do.\"",
		weight = 9,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 20, maxAge = 65 },
		codex = "fingers_thumb",
		choices = {
			{
				label = "\"We'll find the money. And I'll pay it for you.\"",
				result = { sanity = 2, quest = "bs_q_teodor", log = "You told him you'd find it, and that you'd go to the Thumb's table yourself, because you knew the titles. He looked at you as if you'd said you could fly." },
			},
			{
				label = "Lend him what you can spare",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 3, log = "You gave him sixty Ahn, all you could spare. He found the rest from his cousins. He paid it on time, stammering every title, and the Thumb let it go. He fixed your door hinges every spring for the rest of his life." },
			},
			{
				label = "Tell him to go to the Middle instead",
				result = { mind = 1, sanity = -3, log = "You told him the Middle sometimes covers a family's debts. He went. The Thumb was paid. Teodor started wearing a long sleeve over a new tattoo, and called a stranger \"Big Brother,\" and stopped looking anyone in the eye." },
			},
		},
	},
	{
		id = "bs_a_move_offer",
		title = "A Letter From Another District",
		text = "A cousin you barely remember has written from another District. There's work there, a room above a shop, and nobody who knows your business. \"The WARP takes ten seconds,\" she writes. \"Starting over takes longer, but not as long as you'd think.\"",
		weight = 6,
		once = true,
		when = { minAge = 22, maxAge = 50 },
		choices = {
			{
				label = "Go to District 4",
				requires = { notDistrict = "d4" },
				result = { district = "d4", sanity = 2, log = "You took the WARP to District 4: noodle stalls, small Fixer Offices, academies, and Rats in the alleys, like home but with different Rats. Your cousin met you at the platform with a sign with your name spelled wrong." },
			},
			{
				label = "Go to District 16",
				requires = { notDistrict = "d16" },
				result = { district = "d16", sanity = 1, mind = 1, log = "You took the WARP to District 16, where the spires are taller than anywhere and the buildings bend without breaking. The first night, the street outside your window was in a slightly different place in the morning. You got used to it." },
			},
			{
				label = "Stay where your people are",
				result = { sanity = 3, log = "You wrote back and said thank you, and no. Your street was your street. Your cousin wrote again every year, and the offer always stood." },
			},
		},
	},
	{
		id = "bs_a_watch_join",
		title = "The Watch Needs You",
		text = "Grandpa Teo has walked your street with his lamp every night for thirty years, and his knees are finished. The neighborhood watch needs someone to take the late round: two o'clock to half past, every door, every old person home. He's standing at your door holding the lamp out, the way he did when you were small.",
		weight = 8,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 22, maxAge = 60, notFlags = { "bs_watch_member" } },
		codex = "bs_lore_watch",
		choices = {
			{
				label = "Take the lamp",
				result = { sanity = 4, strength = 1, setFlags = { "bs_watch_member" }, log = "You took the lamp. Every night after that, two o'clock to half past: every door, every old person home, every Rat shooed. You knew every name on the street within a month." },
			},
			{
				label = "Find someone younger for him",
				result = { mind = 2, log = "You found him a young dock worker with good knees and nothing to do at two in the morning. Grandpa Teo trained her for a year. She was better at it than either of you." },
			},
		},
	},
	{
		id = "bs_a_street_party",
		title = "The Street Party",
		text = "Once a year your street closes itself to carts and has a party: lanterns strung between the windows, every stall cooking, music from three radios at once, children everywhere. It starts at noon. It ends at one, sharp, with everybody counting down together, and everybody home by two.",
		weight = 8,
		cooldown = 8,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 16 },
		choices = {
			{
				label = "Cook for it",
				result = { intelligence = 1, sanity = 4, money = { -15, -5 }, log = "You made a huge pot of something and gave it away by the bowl until it was gone. Three people asked for the recipe. You told all three different things." },
			},
			{
				label = "Dance until the countdown",
				result = { health = 1, sanity = 5, log = "You danced to all three radios at once with your neighbors, the watch, two off-duty Fixers and a Soldato who was very bad at it. At one, the whole street counted down. You were home by half past, still humming." },
			},
			{
				label = "Help walk everyone home",
				result = { mind = 2, sanity = 3, log = "You spent the last hour walking the old people and the very small children home. By two, every door on the street was locked, and you stood in the empty street for a minute, listening to it being quiet." },
			},
		},
	},
	{
		id = "bs_a_tax_nothing",
		title = "Tax on Nothing",
		text = "A tax notice, on official paper: you owe inheritance tax on the estate of a great-aunt you've never heard of, in a District you've never visited. The estate, the notice says, was valued at nothing. The tax on nothing is three hundred Ahn.",
		weight = 6,
		once = true,
		when = { minAge = 28, maxAge = 70 },
		choices = {
			{
				label = "Fight it at the tax office",
				hint = "Mental Strength check: a full day in the queue, and the right forms.",
				clash = { stat = "mind", foe = "The tax office", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "You spent a whole day in the queue and found the clerk who could explain that nothing taxed at any rate is still nothing. She cancelled the notice. She also said, very quietly, that you were the first person to ask that year." },
				lose = { money = { -80, -40 }, sanity = -3, log = "You spent a whole day in the queue and came out owing a fee for the appeal, and a smaller tax on nothing. You framed the notice. It was the only thing your great-aunt ever left you." },
			},
			{
				label = "Pay it, to be safe",
				result = { money = { -60, -30 }, mind = 1, log = "You paid a reduced amount after a long negotiation, to be safe. In the City, unpaid taxes are the kind of thing the Head's arms come for. Your great-aunt, wherever she was, was not available for comment." },
			},
		},
	},
	{
		id = "bs_a_shop_meeting",
		title = "The Shopkeepers' Meeting",
		text = "The shopkeepers on your street meet in the back of the bathhouse, and tonight there's a vote. The Syndicate wants a bigger fee to protect the street. A small Fixer Office is offering to do it instead, under contract, for less, \"with receipts.\" Everyone's scared of the Syndicate's reaction. Everyone looks at you.",
		weight = 7,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 25, maxAge = 70 },
		codex = "bs_lore_alley_grades",
		choices = {
			{
				label = "Argue for the Fixer Office",
				hint = "Charisma check: you need the room on your side.",
				clash = { stat = "charisma", foe = "A room full of frightened shopkeepers", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, sanity = 3, money = { 20, 50 }, log = "You talked the room round. The street hired the Office, under contract, with receipts. The Syndicate sent a very polite letter of regret, and two Soldati to stand at the end of the street for a month, looking hurt. Then they moved on." },
				lose = { sanity = -3, money = { -30, -10 }, log = "The room voted for the Syndicate, out of fear. The fee went up. The Fixer Office's Rep shook your hand on the way out anyway. \"Next year,\" she said." },
			},
			{
				label = "Argue for paying the Syndicate",
				result = { charisma = 1, money = { -20, -10 }, log = "You argued for the Syndicate: better the protection you know. The room agreed, relieved. The street stayed quiet. The fee went up. Everyone knew it would." },
			},
		},
	},

	-- ── family ─────────────────────────────────────────────────────────────
	{
		id = "bs_a_doorstep",
		title = "On the Doorstep",
		text = "There's a child on your doorstep at dawn. Four, maybe five, wrapped in somebody's coat, asleep. They were here when the Night began, and they were here when it ended, and that means somebody put them in your doorway at 3:12 and ran. There's no note. There's a little wooden horse in their hand.",
		weight = 5,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 24, maxAge = 58 },
		choices = {
			{
				label = "Take them in",
				result = { sanity = 6, setFlags = { "parent" }, addRelation = { kind = "child", age = { 4, 5 }, bond = 60 }, log = "You took them in. They didn't say a word for a month and then never stopped talking. You named them {newRelation}, after nobody, so the name could be theirs." },
			},
			{
				label = "Take them to the foundling house",
				result = { sanity = -1, mind = 1, log = "You carried them to the foundling house, where Matron Hesketh took them without a word and gave them a bed by the stove. You visited every month. They always ran to the door." },
			},
		},
	},
	{
		id = "bs_a_child_school",
		title = "First Day at the Academy",
		text = "{child} starts at the academy on the corner today: new shoes, a bag that's far too big, and the rule repeated eleven times over breakfast. At the door, {child} stops, looks up at you, and asks the question every child asks: \"What if I'm not clever enough?\"",
		weight = 8,
		once = true,
		when = { hasRelation = "child", minAge = 26, maxAge = 60 },
		choices = {
			{
				label = "\"Then you'll be stubborn enough.\"",
				result = { sanity = 4, relationBond = { kind = "child", amount = 10 }, log = "{child} thought about that, very seriously, and walked in. At the end of the day, {child} came out covered in chalk and announced a plan to become the stubbornest student in the history of the academy." },
			},
			{
				label = "Walk them to their desk",
				result = { sanity = 3, relationBond = { kind = "child", amount = 6 }, log = "You walked {child} all the way to the desk, which was not allowed, and the teacher pretended not to see. When you looked back from the door, {child} was already talking to the kid at the next desk." },
			},
		},
	},
	{
		id = "bs_a_child_choice",
		title = "What They Want to Be",
		text = "{child} is grown, or nearly, and has made up their mind about a life, and has come to tell you rather than ask you. A Fixer's license. A Wing's exam. A Workshop apprenticeship. Something you'd have picked yourself, once, or something you'd have run from. They're watching your face very carefully.",
		weight = 8,
		once = true,
		when = { hasRelation = "child", minAge = 38, maxAge = 75 },
		choices = {
			{
				label = "Back them, whatever it is",
				result = { sanity = 4, relationBond = { kind = "child", amount = 12 }, log = "You said you'd back them, whatever it was. {child} let out a long breath, and then told you all of it, the whole plan, for three hours over tea. It was a good plan. Mostly." },
			},
			{
				label = "Tell them everything you know about it first",
				result = { mind = 2, relationBond = { kind = "child", amount = 6 }, log = "You told {child} everything you knew: the good parts, the bad parts, the parts nobody tells you. They listened to all of it, and went and did it anyway, better prepared. That was all you'd wanted." },
			},
			{
				label = "Ask them to wait a year",
				result = { relationBond = { kind = "child", amount = -6 }, mind = 1, log = "You asked {child} to wait a year. They did, angrily. Then they did it anyway. You were both right, in different ways, and it took a long time to say so." },
			},
		},
	},
	{
		id = "bs_a_parent_stairs",
		title = "Your Mother's Stairs",
		text = "{mother} lives on the fifth floor, and this winter the stairs have started winning. She's stopped going out except when she has to. She hasn't said anything, because she wouldn't, but the neighbor has: she sat on the third landing for an hour yesterday, getting her breath back.",
		weight = 8,
		once = true,
		when = { hasRelation = "mother", minAge = 30, maxAge = 60 },
		choices = {
			{
				label = "Move her in with you",
				result = { sanity = 3, money = { -30, -10 }, relationBond = { kind = "mother", amount = 12 }, log = "You moved her in, over her objections, which lasted almost a week. She rearranged your kitchen, criticized your locks, and was, for the first time in years, not alone." },
			},
			{
				label = "Pay for a ground-floor room near you",
				requires = { min = { money = 100 } },
				result = { money = -100, sanity = 2, relationBond = { kind = "mother", amount = 8 }, log = "You found her a ground-floor room two doors from yours and paid the first year. She said it was too much fuss. She sat outside it every afternoon in the sun, talking to everyone who passed." },
			},
			{
				label = "Visit every day to carry the shopping",
				result = { health = 1, sanity = 1, relationBond = { kind = "mother", amount = 6 }, log = "You went every day after work and carried the shopping up five floors. It took an hour each time, because she made you stay for tea. You complained about it, and would have given anything later to do it again." },
			},
		},
	},
	{
		id = "bs_a_sibling_trouble",
		title = "Your Sibling's Trouble",
		text = "{sibling} turns up at your door at one in the morning, out of breath, saying it's nothing, it's fine, can they stay the night. It is not nothing. {sibling} owes money to the wrong people, and the wrong people have a ledger with a very polite deadline in it.",
		weight = 8,
		once = true,
		when = { hasRelation = "sibling", minAge = 20, maxAge = 60 },
		choices = {
			{
				label = "Pay part of it",
				requires = { min = { money = 80 } },
				result = { money = -80, sanity = 1, relationBond = { kind = "sibling", amount = 10 }, log = "You paid part of it out of your savings, and {sibling} paid the rest over a year, every month, on time, which was the first time {sibling} had ever been on time for anything." },
			},
			{
				label = "Let them stay, and help them work it off",
				result = { health = -1, mind = 1, relationBond = { kind = "sibling", amount = 8 }, log = "{sibling} slept on your floor for three months and worked two jobs, and you made sure {sibling} went to both. The debt was paid. You were never so glad to get your floor back." },
			},
			{
				label = "Tell them they're on their own this time",
				result = { sanity = -3, relationBond = { kind = "sibling", amount = -10 }, log = "You said no. {sibling} left before three, without a word. It worked out, eventually, without you. You didn't talk for two years." },
			},
		},
	},
	{
		id = "bs_a_friend_shop",
		title = "A Friend's Shop",
		text = "{friend} has finally done it: a shop of their own, a narrow little place between the laundry and the locksmith, with a hand-painted sign and a bell over the door. Opening day. {friend} is terrified, and keeps rearranging the same shelf, and has asked you to be the first customer.",
		weight = 8,
		once = true,
		when = { hasRelation = "friend", minAge = 22, maxAge = 65 },
		choices = {
			{
				label = "Buy the most expensive thing in the shop",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = 4, relationBond = { kind = "friend", amount = 10 }, log = "You bought the most expensive thing in the shop, without looking at the price, while {friend} watched you with tears in their eyes. It was a lamp. It was a terrible lamp. It's still in your window." },
			},
			{
				label = "Bring the whole street to the opening",
				result = { sanity = 4, mind = 1, relationBond = { kind = "friend", amount = 8 }, log = "You went door to door and brought half the street. By noon there was a queue. By one, {friend} had sold out of everything and was sitting on the step laughing." },
			},
		},
	},
	{
		id = "bs_a_rival_old",
		title = "Your Rival, Older",
		text = "{rival} is at the bathhouse, three stools down, older than you remember, grayer, with a cough. You've spent years not speaking. {rival} catches your eye in the steam and, for the first time in all those years, nods.",
		weight = 8,
		once = true,
		when = { hasRelation = "rival", minAge = 35, maxAge = 75 },
		choices = {
			{
				label = "Nod back, and sit closer",
				result = { sanity = 4, relationBond = { kind = "rival", amount = 20 }, log = "You moved down two stools. Neither of you mentioned anything. You talked about the bathhouse's terrible new tiles for an hour, and it was the best conversation you'd had in years." },
			},
			{
				label = "Challenge them, one more time",
				hint = "Health check: who can stand the hottest pool longest.",
				clash = { stat = "health", foe = "A rival in the hot pool", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, relationBond = { kind = "rival", amount = 10 }, log = "You lasted three minutes longer in the hottest pool. {rival} got out first, red as a lobster, laughing so hard they had to sit down. \"Still,\" {rival} said. \"After all these years.\"" },
				lose = { sanity = 2, relationBond = { kind = "rival", amount = 10 }, log = "{rival} outlasted you by a minute and gloated for a week, and you didn't mind half as much as you'd expected." },
			},
		},
	},
	{
		id = "bs_a_mentor_advice",
		title = "Your Mentor's Advice",
		text = "{mentor} asks you to tea, which happens perhaps once a year and always means something. Today {mentor} pours, and waits, and then says: \"You're doing it the way I did it. That's the problem.\"",
		weight = 8,
		once = true,
		when = { hasRelation = "mentor", minAge = 25, maxAge = 60 },
		choices = {
			{
				label = "Ask what to change",
				result = { mind = 2, intelligence = 2, log = "{mentor} told you, at length, very specifically, with examples from your own life you'd hoped nobody had noticed. You were furious for a week. Then you changed it, and it worked." },
			},
			{
				label = "Tell them you'll do it your own way",
				result = { strength = 2, sanity = 2, log = "\"Good,\" said {mentor}, and seemed pleased. \"That was the right answer.\" You never found out if it had been a test." },
			},
		},
	},

	-- ── the body ───────────────────────────────────────────────────────────
	{
		id = "bs_a_cough",
		title = "The Cough That Stayed",
		text = "The cough you picked up in the autumn hasn't gone. It's worse in the mornings and worse in the damp, and the damp is everywhere in the Backstreets. The clinic down the street would see you for a week's wages. The Nest's hospital would see you for a month's, if they let you through the gate.",
		weight = 7,
		cooldown = 10,
		when = { minAge = 30, maxAge = 75 },
		choices = {
			{
				label = "Go to the clinic",
				requires = { min = { money = 30 } },
				result = { money = -30, health = { 4, 8 }, cure = "any", log = "Doctor Seraphine listened to your chest, sighed, and gave you a tonic, a lecture and a bill. By spring the cough was gone. The lecture stayed." },
			},
			{
				label = "Wait it out",
				result = { condition = "smoke_lung", sanity = -1, log = "You waited it out. It didn't go out. The cough settled into your chest like a lodger who doesn't pay rent and won't leave." },
			},
			{
				label = "Try the noodle stall's ginger broth",
				result = { sanity = 2, health = { 1, 3 }, log = "You drank the ginger broth from the noodle stall every night for a month. It didn't cure anything. You felt much better anyway, and the cough got bored and left in the spring." },
			},
		},
	},
	{
		id = "bs_a_bad_back",
		title = "Something You Shouldn't Have Lifted",
		text = "You lifted something you should have asked for help with: a wardrobe, a crate, a neighbor's motorbike. Something in your back went pop, very quietly, and now you're lying on the kitchen floor looking at the ceiling, listening to the street through the window.",
		weight = 6,
		once = true,
		when = { minAge = 35, maxAge = 70 },
		choices = {
			{
				label = "Shout for the neighbor",
				result = { condition = "bs_bad_back", sanity = 1, log = "The neighbor came, and helped you up, and made you tea, and told the whole building, so that for a month everyone carried everything for you and you hated it and were grateful." },
			},
			{
				label = "Get up on your own",
				hint = "Health check.",
				clash = { stat = "health", foe = "Your own back", coins = 2, base = 3, coinPower = 2 },
				win = { health = 1, log = "You got up, slowly, using the table and a great deal of language you'd never use in front of children. You were fine by the weekend. You asked for help with the next wardrobe." },
				lose = { condition = "bs_bad_back", sanity = -2, log = "You got halfway up and then lay back down for a while. Your back took three years to forgive you." },
			},
		},
	},

	-- ── the people who come back ───────────────────────────────────────────
	{
		id = "bs_a_mun_retires",
		title = "Auntie Mun's Pot",
		text = "Auntie Mun is retiring. She's been pulling noodles on the same corner since before your parents were born, and her hands have finally told her to stop. She wants the stall to go to someone who'll keep the pot going and the prices fair and close at one sharp. She's looking at you, over the steam.",
		weight = 14,
		once = true,
		when = { flags = { "bs_knows_mun" }, career = "diner", minRank = 2, notFlags = { "bs_diner_r4" } },
		choices = {
			{
				label = "Take the pot",
				result = { promote = true, sanity = 5, setFlags = { "bs_has_mun_pot" }, log = "She showed you the pot one last time, the way you'd show someone a family heirloom, and went home to sleep for a week. You were the stall now. Your first night, the regulars watched you like hawks. Your broth passed. Barely." },
			},
			{
				label = "Ask her to stay on, mornings only",
				result = { promote = true, sanity = 4, intelligence = 2, log = "She refused, and then came in every morning anyway \"just to check,\" and criticized everything, and stayed until noon. It was the best year the stall ever had." },
			},
		},
	},
	{
		id = "bs_a_ottavio_cane",
		title = "Ottavio's Cane",
		text = "Ottavio, the Fixer down the street who taught you in the yard behind his Office, is gone. His niece comes to your door with a long bundle wrapped in an old coat: his cane, the plain wooden one he leaned on for thirty years. \"He said you'd know what it was for,\" she says. You don't. Then you do.",
		weight = 14,
		once = true,
		when = { flags = { "bs_ottavio_student" }, noRelation = "mentor", minAge = 25 },
		choices = {
			{
				label = "Keep it by the door",
				result = { sanity = 3, mind = 2, log = "You kept it by your door. On bad nights you'd hold it, and remember: never call a Capo by his name, never touch a Middle tattoo, never read a slip of paper that isn't yours, and be home before three." },
			},
			{
				label = "Give it to a kid who needs a lesson",
				result = { sanity = 4, strength = 1, log = "You gave it to a boy on your street who'd started watching the Fixer gym through the window. \"They'll teach you to get hurt,\" you told him. \"I'll teach you not to.\" Ottavio would have laughed." },
			},
		},
	},
	{
		id = "bs_a_warp_ride",
		title = "Your First WARP Ride",
		text = "You promised yourself as a kid on the roof that you'd ride the WARP train someday. Today you're on the platform with a ticket that cost more than a month's rent, watching the silver train slide in without a sound. A W Corp attendant offers you the First Class upgrade: \"sleep through the journey, with complimentary snacks.\"",
		weight = 10,
		once = true,
		when = { flags = { "bs_warp_dream" }, minAge = 18, maxAge = 70 },
		codex = "districts_w_corp",
		choices = {
			{
				label = "Ride it awake, the ordinary way",
				result = { money = -40, sanity = 1, mind = 2, log = "The doors closed. The lights dipped. The doors opened on the far side of the City. That was all of it: ten seconds, and nothing in them to tell anyone about. You stood on the platform for a while anyway, feeling you'd been cheated of something, or spared it." },
			},
			{
				label = "Pay for First Class",
				requires = { min = { money = 200 } },
				result = { money = -200, sanity = 4, log = "You slept through it in a soft white pod with a little packet of very good biscuits, and woke up on the far side of the City, rested and baffled. The kid on the roof would have been thrilled. You were, a bit." },
			},
			{
				label = "Watch it leave, and keep the ticket",
				result = { sanity = 2, log = "At the last moment you stepped back, and watched it go, and kept the ticket in your wallet for the rest of your life. Some promises are better kept as promises." },
			},
		},
	},

	-- ── the coat on the doorstep (quest scene) ─────────────────────────────
	{
		id = "bs_q_coat_truth",
		title = "The Key-Cutter",
		text = "The key-cutter is an old woman with a jeweler's loupe and hands that never stop moving. She looks at the crest on your coat, then at your face, for a long time. \"Latch Office,\" she says. \"I was its Rep. There were four of us.\" She puts down the key she was cutting. \"One of mine was caught out, the night they found you. She didn't have time to get you home. She had time to get you to a door.\"",
		weight = 0,
		when = { flags = { "bs_q_coat_found" } },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Ask her name",
				result = { sanity = -2, mind = 2, setFlags = { "bs_q_coat_done", "bs_knows_coat" }, log = "She told you. A Grade 7 Fixer. Good at locks. Laughed too loudly. She wrapped you in her own coat at 3:12 and put you in the doorway of the foundling house, and turned around, and stood her ground in the street. That's all anyone knows." },
			},
			{
				label = "Ask if she was a good Fixer",
				result = { sanity = 3, setFlags = { "bs_q_coat_done", "bs_knows_coat" }, log = "\"The best of us,\" said the key-cutter. \"Not the strongest. The best.\" She cut you a key with the Latch crest on its bow, and wouldn't take a single Ahn for it." },
			},
		},
	},
}
