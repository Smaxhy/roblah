--[[
	THE MIDDLE OF A LIFE, more of it (v0.15, m15_ ids): standalone cards for the years between
	twenty-two and fifty, when the City stops treating you as young. Work, rent, old friends,
	old debts, Syndicates, the Night, bad luck and good. Most have a hard edge: this is the
	part of life where people in the City die.
]]

local D = { "danger" }

return {
	{
		id = "m15_two_clients",
		title = "Two Clients",
		text = "Two people hire you the same week for the same job: find a missing ledger. One wants it returned. The other wants it burned. Both have paid in advance, and both are watching you.",
		weight = 6, cooldown = 10,
		when = { minAge = 22, maxAge = 55 },
		choices = {
			{ label = "Return it", clash = { stat = "intelligence", foe = "Who wants it worse", coins = 3, base = 5, coinPower = 3 }, win = { intelligence = 2, wage = { 100, 200 }, log = "Returned, quietly. The other client sent a note: next time, they'll hire first." }, lose = { health = { -16, -8 }, wage = { 50, 80 }, cause = "Took two clients' money for one job", log = "The other client found out. They expressed it." } },
			{ label = "Burn it", result = { wage = { 100, 200 }, sanity = -3, rep = { fixers = -2 }, log = "It burned. One client was very pleased. The other one is still looking for you." } },
			{ label = "Give both their money back", result = { money = -40, charisma = 2, rep = { fixers = 3 }, log = "You gave it all back, plus a little for their trouble. Word got round that you can't be bought twice." } },
		},
	},
	{
		id = "m15_layoff",
		title = "The Floor Is Closing",
		text = "The Wing is closing your whole floor of the factory. Three hundred people. There's a list of who gets transferred, and it's pinned up at noon. People are already crying in the toilets.",
		weight = 6, cooldown = 15, once = true,
		when = { minAge = 22, maxAge = 55, side = "nest" },
		choices = {
			{ label = "Make sure you're on the list", clash = { stat = "charisma", foe = "A supervisor with a list", coins = 3, base = 5, coinPower = 3 }, win = { charisma = 2, sanity = -2, log = "Your name went on the list. Someone else's came off. You know whose." }, lose = { money = -100, sanity = -6, log = "Not on the list. Six weeks to find something else, or lose the flat." } },
			{ label = "Organise the floor", clash = { stat = "charisma", foe = "Three hundred frightened people", coins = 3, base = 6, coinPower = 3 }, win = { charisma = 3, rep = { wings = -4 }, log = "You got the whole floor transferred together, to a worse floor. Nobody lost their flat. The Wing remembers your name now." }, lose = { rep = { wings = -6 }, sanity = -4, log = "They broke it up by Friday. Your name went to the top of a different list." } },
			{ label = "Leave before they decide", result = { money = -60, mind = 2, log = "You walked out before the list went up. It was the only choice you'd get to make." } },
		},
	},
	{
		id = "m15_rent_muscle",
		title = "The New Landlord",
		text = "The building has a new landlord, and the landlord has new rules, and the rules are explained by two men from a Syndicate who stand on the stairs. Rent is doubled. They're here for this month's.",
		weight = 6, cooldown = 10, tags = D,
		when = { minAge = 20, maxAge = 60, side = "backstreets" },
		choices = {
			{ label = "Pay", requires = { min = { money = 150 } }, result = { money = -150, sanity = -3, log = "You paid. They thanked you. They'll be back next month, and the month after." } },
			{ label = "Throw them down the stairs", clash = { stat = "strength", foe = "A Syndicate's rent collectors", enemy = "syndicate", fight = true, coins = 3, base = 6, coinPower = 3 }, win = { strength = 2, rep = { rats = 4 }, log = "Both of them, all six flights. The landlord sold the building that winter." }, lose = { health = { -24, -14 }, money = -150, cause = "Fought a Syndicate's rent collectors", log = "They took the rent, and the extra, for the trouble." } },
			{ label = "Get the tenants together", clash = { stat = "charisma", foe = "Forty tenants who are scared", coins = 3, base = 5, coinPower = 3 }, win = { charisma = 2, log = "Forty tenants on the stairs, all at once. The collectors counted them, and left, and the rent stayed where it was." }, lose = { money = -150, sanity = -2, log = "Half of them stayed in their flats. You paid with the rest." } },
		},
	},
	{
		id = "m15_workshop_fire",
		title = "The Workshop Fire",
		text = "The Workshop on your street goes up at dusk: a forge accident, a crate of something that shouldn't have been near a forge. The smiths are still inside. The fire is coming through the roof.",
		weight = 5, cooldown = 12, tags = D,
		when = { minAge = 18, maxAge = 60 },
		choices = {
			{ label = "Go in", clash = { stat = "strength", foe = "A burning Workshop", coins = 3, base = 6, coinPower = 3 }, win = { strength = 2, charisma = 2, sanity = 2, log = "Three smiths, one at a time, through the smoke. The last one wouldn't leave without her hammer. You carried both." }, lose = { health = { -28, -16 }, condition = "burns", cause = "Went into a burning Workshop", log = "You got one out. The roof came in on the second trip." } },
			{ label = "Organise a bucket line", clash = { stat = "charisma", foe = "A street in a panic", coins = 3, base = 5, coinPower = 3 }, win = { charisma = 2, log = "Forty people, forty buckets. The fire never reached the next building." }, lose = { sanity = -4, log = "Too slow. Two buildings burned." } },
			{ label = "Stay back", result = { sanity = -4, log = "You watched from across the road. Everyone did. Some of them still don't look at you." } },
		},
	},
	{
		id = "m15_rat_boss_friend",
		title = "Someone You Went to School With",
		text = "The new boss of the Rats on your street is someone you went to school with: the kid who shared their lunch with you every day for a year. They recognise you. They're smiling. They have twelve Rats behind them.",
		weight = 5, cooldown = 15, once = true,
		when = { minAge = 22, maxAge = 45, side = "backstreets" },
		choices = {
			{ label = "Ask them to leave the street alone", clash = { stat = "charisma", foe = "An old friend with new friends", coins = 3, base = 6, coinPower = 3 }, win = { charisma = 3, rep = { rats = 4 }, log = "\"For the lunches,\" they said. Your street is off-limits to the Rats. Every other street isn't." }, lose = { health = { -12, -6 }, sanity = -3, log = "\"That was a long time ago,\" they said. Their Rats explained how long." } },
			{ label = "Join them", result = { money = 200, rep = { rats = 8 }, sanity = -6, log = "Good money, and a friend again. You don't sleep as well, but you sleep in a better bed." } },
			{ label = "Challenge them", clash = { stat = "strength", foe = "The boss of the Rats", enemy = "rat_boss", fight = true, coins = 3, base = 7, coinPower = 3 }, win = { strength = 3, rep = { rats = -8 }, log = "One on one, in the alley behind the school. They yielded, and laughed, and cried a little, and left the street." }, lose = { health = { -26, -16 }, cause = "Challenged an old schoolfriend who ran the Rats", log = "They'd been practising, all these years." } },
		},
	},
	{
		id = "m15_black_ampule",
		title = "The Cheap Ampule",
		text = "A man in a doorway is selling K Corp ampules at a tenth of the price. The glow's a little off, a shade too green. Your wound from last month still hasn't closed.",
		weight = 5, cooldown = 10,
		when = { minAge = 18, maxAge = 70 },
		choices = {
			{ label = "Buy one", requires = { min = { money = 40 } }, clash = { stat = "luck", foe = "Whatever's really in it", coins = 3, base = 5, coinPower = 3 }, win = { money = -40, health = { 10, 20 }, log = "It worked. Mostly. Your arm itches at night and the scar glows faintly in the dark." }, lose = { money = -40, health = { -16, -8 }, condition = "fever", cause = "Took a counterfeit ampule", log = "It was not an ampule." } },
			{ label = "Report him to K Corp", result = { rep = { wings = 3 }, sanity = -1, log = "K Corp came in an hour, in white. The man in the doorway was never seen again, and neither were his customers' complaints." } },
			{ label = "Walk on", result = { mind = 1, log = "You walked on. The wound closed by itself, eventually, the slow way." } },
		},
	},
	{
		id = "m15_grudge_match",
		title = "The Grudge Match",
		text = "Someone you beat in a fight fifteen years ago has been training ever since. They've come to your street with a crowd of witnesses, and they want a rematch, now, in the open, where everyone can see.",
		weight = 5, cooldown = 12, tags = D,
		when = { minAge = 28, maxAge = 55 },
		choices = {
			{ label = "Accept", clash = { stat = "strength", foe = "Fifteen years of training", enemy = "fixer", fight = true, coins = 3, base = 7, coinPower = 3 }, win = { strength = 3, charisma = 1, log = "You won again. They sat in the road and laughed until they cried. \"Fifteen more years,\" they said." }, lose = { health = { -26, -16 }, cause = "Lost a grudge match fifteen years in the making", log = "Fifteen years was enough." } },
			{ label = "Decline in public", clash = { stat = "charisma", foe = "A crowd that wants a fight", coins = 3, base = 5, coinPower = 3 }, win = { charisma = 2, mind = 1, log = "\"You win,\" you said, loudly. \"You've always won.\" They didn't know what to do with that, and went home." }, lose = { sanity = -5, log = "The crowd jeered you all the way home. The story got worse every time it was told." } },
			{ label = "Ask them to tea instead", result = { charisma = 2, sanity = 2, log = "They stared. Then they came. You talked for five hours. You're friends now, more or less." } },
		},
	},
	{
		id = "m15_burned_out",
		title = "Running on Empty",
		text = "You haven't slept properly in a month. Your hands shake at work. This morning you forgot your own address for a whole minute on the tram. Something has to give.",
		weight = 6, cooldown = 8,
		when = { minAge = 24, maxAge = 60, max = { sanity = 20 } },
		choices = {
			{ label = "Take a week off", result = { money = -80, sanity = 8, health = { 2, 4 }, log = "A week of sleeping and noodles and nothing. You came back with an address and both hands." } },
			{ label = "Push through", clash = { stat = "mind", foe = "Your own limits", coins = 3, base = 6, coinPower = 3 }, win = { mind = 3, wage = { 50, 100 }, log = "You pushed through. You don't know how. You don't want to do it again." }, lose = { health = { -12, -6 }, sanity = -6, condition = "night_terrors", log = "Something gave. It was you." } },
			{ label = "Talk to someone", result = { charisma = 1, sanity = 5, log = "An old friend, a noodle stall, three hours. You didn't solve anything. You slept that night." } },
		},
	},
	{
		id = "m15_collapse",
		title = "The Building Next Door",
		text = "The tenement next door is coming down, by itself, a floor at a time. Dust and screaming. People are still on the upper floors, at the windows, and the stairs are already gone.",
		weight = 4, cooldown = 15, tags = D,
		when = { minAge = 18, maxAge = 60, side = "backstreets" },
		choices = {
			{ label = "Climb across from your roof", clash = { stat = "speed", foe = "A building falling down", coins = 3, base = 7, coinPower = 3 }, win = { speed = 2, charisma = 2, sanity = 2, log = "A plank between the roofs, nine people across it, one by one. The building fell five minutes after the last." }, lose = { health = { -30, -18 }, cause = "Climbed into a collapsing tenement", log = "The plank held. The roof didn't." } },
			{ label = "Hold the mattress below the windows", clash = { stat = "strength", foe = "People jumping", coins = 3, base = 6, coinPower = 3 }, win = { strength = 2, sanity = 1, log = "Six of you, one mattress, eleven jumps. Every one of them walked away." }, lose = { health = { -14, -8 }, sanity = -4, log = "Most of them. Not all of them." } },
			{ label = "Get your own family out", result = { sanity = -4, log = "Your own building was shaking too. You got your people out, and watched from the street." } },
		},
	},
	{
		id = "m15_syndicate_war",
		title = "Crossfire",
		text = "Two Syndicates have decided your street is the border between them. Tonight the border moved, twice. There's a man bleeding in your doorway who belongs to one of them, and the other one is coming up the street.",
		weight = 5, cooldown = 10, tags = D,
		when = { minAge = 18, maxAge = 60, side = "backstreets" },
		choices = {
			{ label = "Hide him", clash = { stat = "luck", foe = "A Syndicate searching doorways", coins = 3, base = 6, coinPower = 3 }, win = { luck = 2, rep = { rats = 3 }, log = "Under the floorboards, both of you, breathing quietly. They went past. He owes you his life, and says so, often." }, lose = { health = { -24, -14 }, cause = "Hid a man from a Syndicate", log = "They found the floorboards." } },
			{ label = "Close your door", result = { sanity = -6, log = "You closed it. You heard what happened in your doorway. You scrubbed the step in the morning." } },
			{ label = "Stand in the doorway", clash = { stat = "strength", foe = "A Syndicate crew", enemy = "syndicate", fight = true, coins = 3, base = 7, coinPower = 3 }, win = { strength = 3, rep = { rats = 2 }, log = "They looked at you, and at the man, and decided he wasn't worth it tonight." }, lose = { health = { -30, -18 }, cause = "Stood in a doorway in a Syndicate war", log = "They decided he was worth it." } },
		},
	},
	{
		id = "m15_inheritance",
		title = "A Letter About an Inheritance",
		text = "A very official letter: a distant relative has left you a flat in the Nest. All you have to do is come to an office in another District, alone, with your papers, tomorrow night.",
		weight = 5, cooldown = 12,
		when = { minAge = 22, maxAge = 60 },
		choices = {
			{ label = "Go", clash = { stat = "intelligence", foe = "A very official letter", coins = 3, base = 6, coinPower = 3 }, win = { intelligence = 2, mind = 1, log = "You noticed the stamp was wrong in the doorway, and turned round. Three people stepped out of the dark behind where you'd stopped." }, lose = { health = { -20, -12 }, money = -150, cause = "Answered a forged inheritance letter", log = "There was no flat. There were four people and a van." } },
			{ label = "Check with the Nest office", result = { intelligence = 2, log = "No relative, no flat, no office at that address. Someone on your street wasn't as careful. You heard." } },
			{ label = "Bin it", result = { mind = 1, log = "Nobody in your family has ever had a flat in the Nest. You'd remember." } },
		},
	},
	{
		id = "m15_wounded_fixer",
		title = "A Fixer at the Door",
		text = "A Fixer is slumped against your door at midnight, coat torn, a job gone wrong. She begs to come in. Somebody is following her, she says, and they're not far behind.",
		weight = 5, cooldown = 10, tags = D,
		when = { minAge = 18, maxAge = 60 },
		choices = {
			{ label = "Let her in", clash = { stat = "luck", foe = "Whoever's following her", coins = 3, base = 6, coinPower = 3 }, win = { luck = 1, rep = { fixers = 5 }, log = "They walked past your door twice and moved on. In the morning she left a card: a Grade 3's, with a note. Any favour, ever." }, lose = { health = { -24, -14 }, rep = { fixers = 3 }, cause = "Sheltered a Fixer on the run", log = "They didn't walk past." } },
			{ label = "Patch her up on the step", result = { intelligence = 1, health = { -4, -2 }, rep = { fixers = 2 }, log = "Bandages on the doorstep. She went on before they came. You heard them come. You'd closed the door." } },
			{ label = "Keep the door shut", result = { sanity = -4, log = "She knocked for a while. Then she stopped. In the morning there was a coat on the step." } },
		},
	},
	{
		id = "m15_ration_riot",
		title = "The Ration Line",
		text = "The ration line has been five hours, and the hatch has just slammed shut. Somebody shoves. Somebody shoves back. In a minute it'll be a crush, and there are children in the line.",
		weight = 4, cooldown = 12, tags = D,
		when = { minAge = 18, maxAge = 60, side = "backstreets" },
		choices = {
			{ label = "Get the children out", clash = { stat = "strength", foe = "A crowd turning into a crush", coins = 3, base = 6, coinPower = 3 }, win = { strength = 2, charisma = 2, sanity = 2, log = "Five children over the barrier, one at a time, into a doorway. Every one of them was home that night." }, lose = { health = { -16, -8 }, condition = "broken_ribs", log = "You got three out before the crowd took your feet." } },
			{ label = "Shout them down", clash = { stat = "charisma", foe = "Five hundred hungry people", coins = 3, base = 7, coinPower = 3 }, win = { charisma = 3, log = "\"Tomorrow! The hatch opens tomorrow!\" You didn't know that. They believed you. It did." }, lose = { health = { -10, -5 }, sanity = -3, log = "Nobody heard. It went the way crowds go." } },
			{ label = "Get out of the line", result = { sanity = -3, log = "You got out. You went hungry that week, and so did everyone, and some people worse." } },
		},
	},
	{
		id = "m15_back_alley_clinic",
		title = "The Back-Alley Surgeon",
		text = "The pain in your side has a name now, and the name costs two thousand Ahn at a K Corp clinic. A surgeon in the back of a laundry will do it for two hundred, tonight, on a table that's also for folding.",
		weight = 4, cooldown = 15,
		when = { minAge = 30, maxAge = 65 },
		choices = {
			{ label = "The laundry surgeon", requires = { min = { money = 200 } }, clash = { stat = "luck", foe = "A table that's also for folding", coins = 3, base = 6, coinPower = 3 }, win = { money = -200, health = { 8, 14 }, log = "She was good. Very good. Why she works in a laundry, you didn't ask." }, lose = { money = -200, health = { -24, -14 }, condition = "fever", cause = "Operated on in the back of a laundry", log = "Something went wrong with the folding." } },
			{ label = "The K Corp clinic", requires = { min = { money = 2000 } }, result = { money = -2000, health = { 20, 30 }, log = "Clean, white, painless, and two thousand Ahn. You were home by dinner." } },
			{ label = "Live with it", result = { health = { -8, -4 }, sanity = -2, condition = "smoke_lung", log = "You lived with it. It lived with you." } },
		},
	},
	{
		id = "m15_outskirts_letter",
		title = "A Letter From Past the Wall",
		text = "A letter arrives, water-stained, with no stamp, delivered by nobody. It's from a friend who went past the wall into the Outskirts ten years ago. It says: I found something. Come.",
		weight = 3, cooldown = 20, once = true,
		when = { minAge = 25, maxAge = 55 },
		choices = {
			{ label = "Go", clash = { stat = "strength", foe = "The Outskirts", enemy = "beast", fight = true, coins = 4, base = 7, coinPower = 3 }, win = { strength = 3, mind = 3, sanity = -4, log = "You found the place, a day past the wall. Your friend wasn't there. What they'd found was. You don't talk about it." }, lose = { health = { -32, -20 }, cause = "Answered a letter from the Outskirts", log = "The Outskirts aren't empty. That's the first thing you learn, and some people learn nothing else." } },
			{ label = "Write back", result = { mind = 2, sanity = -1, log = "You left a letter at the wall. Next month, another came back. It said: never mind. I'll come to you." } },
			{ label = "Burn it", result = { sanity = 1, log = "You burned it. You still know the words." } },
		},
	},
	{
		id = "m15_old_debt",
		title = "An Old Debt",
		text = "A woman you borrowed from when you were nineteen has found you. You paid her back, you thought. She has a ledger that says otherwise, and two sons who agree with the ledger.",
		weight = 5, cooldown = 12,
		when = { minAge = 26, maxAge = 60 },
		choices = {
			{ label = "Pay what the ledger says", requires = { min = { money = 120 } }, result = { money = -120, sanity = -2, log = "You paid twice for the same thing. She was very gracious about it." } },
			{ label = "Prove you paid", clash = { stat = "intelligence", foe = "A ledger with opinions", coins = 3, base = 5, coinPower = 3 }, win = { intelligence = 2, log = "You found the receipt, in a shoebox, nineteen years old. She tore the page out of the ledger in front of you." }, lose = { money = -120, health = { -8, -4 }, log = "You couldn't find the receipt. The sons helped you look, unhelpfully." } },
			{ label = "Deal with the sons", clash = { stat = "strength", foe = "Two large sons", enemy = "thug", fight = true, coins = 3, base = 6, coinPower = 3 }, win = { strength = 2, log = "They took the ledger home to their mother, and didn't come back." }, lose = { health = { -18, -10 }, money = -120, cause = "Argued with a moneylender's sons", log = "They had the ledger, and the argument." } },
		},
	},
	{
		id = "m15_abnormality_rumour",
		title = "Something in the Drains",
		text = "Since the last breach siren, something has been living in the drains under your street. It hums. Dogs won't walk past the gratings. L Corp says nothing escaped. L Corp always says nothing escaped.",
		weight = 4, cooldown = 12, tags = D,
		when = { minAge = 18, maxAge = 60, world = { era = "wings" } },
		choices = {
			{ label = "Go down with a lamp", clash = { stat = "mind", foe = "Something that hums", coins = 3, base = 7, coinPower = 3 }, win = { mind = 3, sanity = -4, log = "It was small and very frightened and it hummed louder when you came close. You left it alone. L Corp came for it the next week, quietly." }, lose = { health = { -20, -12 }, sanity = -10, condition = "enkephalin_sick", cause = "Went into the drains after an Abnormality", log = "It stopped humming when you saw it. That was worse." } },
			{ label = "Call L Corp", result = { rep = { lcorp = 2 }, sanity = -2, log = "They came, in their suits. They said nothing escaped. They were down there for six hours." } },
			{ label = "Seal the gratings", result = { strength = 1, sanity = -2, log = "Boards and bricks. The humming went on all winter, underneath, patient." } },
		},
	},
	{
		id = "m15_office_war",
		title = "The Office Across the Road",
		text = "Two Fixer Offices on your street have fallen out over a contract, and are settling it the way Offices do. Your window has been broken twice. Tonight one of them is on your roof.",
		weight = 4, cooldown = 12, tags = D,
		when = { minAge = 18, maxAge = 60 },
		choices = {
			{ label = "Tell them to take it elsewhere", clash = { stat = "charisma", foe = "Two Offices with a grudge", coins = 3, base = 6, coinPower = 3 }, win = { charisma = 2, rep = { fixers = 2 }, log = "They looked at each other, embarrassed, and took it two streets over. One of them paid for the window." }, lose = { health = { -14, -8 }, log = "They took it elsewhere, through you." } },
			{ label = "Report it to Hana", clash = { stat = "intelligence", foe = "Hana's paperwork", coins = 3, base = 5, coinPower = 3 }, win = { intelligence = 2, rep = { fixers = 1 }, log = "Hana fined both Offices. They both blamed you, and both left you alone, carefully." }, lose = { log = "Hana said it was a private matter between licensed parties. Your window disagreed." } },
			{ label = "Sell tea to both sides", result = { wage = { 30, 80 }, charisma = 1, log = "A flask, a tray, both sides of the road. Business was excellent for a week." } },
		},
	},
}
