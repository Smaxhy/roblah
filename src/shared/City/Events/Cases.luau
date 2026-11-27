--[[
	CASES (v0.13): how each case in City/Cases.luau opens, and how it ends. Working a case is
	on the DO tab ("Work the case", one per open case); the last clue brings its finale here.
	Canon: the Devyat' Association carries the City's deliveries; the Index lives by
	Prescripts and its Proxies carry them out; the Ring paints with its Docents; Hana licenses
	and commends Fixers [LoR, Limbus]. The people and the cases are this game's own.
]]

local function check(stat: string, foe: string, base: number?)
	return { stat = stat, foe = foe, coins = 2, base = base or 4, coinPower = 3 }
end

return {
	-- ── openings ──
	{
		id = "case_open_courier",
		title = "A Courier Never Arrived",
		scene = { set = "room", kicker = "At your door", other = { name = "A Devyat' clerk", foe = "devyat_courier" }, line = "\"A courier never arrived. Both of them want you to look.\"" },
		text = "A Devyat' Association clerk is waiting at your door, very upset in a very orderly way. One of their couriers left District 23 three weeks ago with a sealed trunk, and never reached the other end. The Association wants the trunk. The courier's family, who've come too, want the courier. Both will pay you to look.",
		weight = 3,
		once = true,
		tags = { "case", "fixers" },
		when = { minAge = 18, flags = { "knows_fixers" } },
		choices = {
			{ label = "Take the case", result = { caseOpen = "case_missing_courier", money = 100, log = "The clerk paid a retainer, to the Ahn, and gave you the courier's route on a card. The family gave you a photograph." } },
			{ label = "Recommend an Office", result = { rep = { fixers = 2 }, log = "You gave them the name of an Office that does this kind of thing. You hope they're good." } },
		},
	},
	{
		id = "case_open_prescripts",
		title = "Orders on the Doorsteps",
		text = "Little white cards have been turning up on doorsteps in your District, in the Index's style: one line each, an instruction, a time. People are doing what the cards say. The Index hasn't sent them, and when the Index finds out who has, it won't be gentle with the District. Somebody needs to find the forger first.",
		weight = 3,
		once = true,
		tags = { "case", "fingers" },
		when = { minAge = 18, flags = { "knows_index" } },
		choices = {
			{ label = "Find the forger", result = { caseOpen = "case_counterfeit_prescripts", log = "You collected seven of the cards from neighbors who were relieved to hand them over. Every one was perfect." } },
			{ label = "Burn any card that comes to you", result = { sanity = 1, log = "You burned the one that came to you without reading it. It's the only rule you've ever kept about the Index." } },
		},
	},
	{
		id = "case_open_doors",
		title = "Doors in Every Color",
		text = "Every night another door on your street is painted, beautifully, in one color: vermilion, cobalt, a green like old glass. Then the people behind it stop coming out. Their neighbors say they're fine. They can hear them in there, painting.",
		weight = 3,
		once = true,
		tags = { "case", "strange" },
		when = { minAge = 18, flags = { "knows_ring" } },
		choices = {
			{ label = "Look into it", result = { caseOpen = "case_painted_doors", log = "You knocked on the first painted door. Inside, someone called out that they were nearly finished, and to come back when they were." } },
			{ label = "Paint your own door first", result = { mind = 1, sanity = -2, log = "You painted your door a flat, ugly brown, in the hope that nobody with taste would bother with it. Nobody has, so far." } },
		},
	},
	{
		id = "case_open_branch",
		title = "Machinery Under the Floor",
		text = "The tenants in the building on the corner keep hearing machinery under the floor, every day at the same hour: a long grind, then a heavy click. The landlord says there's nothing down there but foundations. The building's oldest plans, which you find in the District office, say the foundations go down a very long way.",
		weight = 3,
		once = true,
		tags = { "case", "lcorp" },
		when = { minAge = 18, world = { era = { "library", "limbus" } } },
		choices = {
			{ label = "Take the plans and start digging", result = { caseOpen = "case_hollow_branch", log = "You borrowed the plans and didn't give them back. The clerk didn't notice. Nobody had asked for them in twenty years." } },
			{ label = "Leave it to the landlord", result = { log = "The grinding goes on, every day at the same hour. The tenants have started setting their clocks by it." } },
		},
	},
	{
		id = "case_open_auction",
		title = "A Name on the List of Lots",
		text = "Once a year, in a District nobody names, things that shouldn't exist are sold to people who shouldn't own them: the Quiet Auction. This year's catalogue is going round the Nest, and someone has slipped you a page of it. Lot nine is a person's contract. You know the name.",
		weight = 2,
		once = true,
		rare = true,
		tags = { "case", "nest" },
		when = { minAge = 25, renown = 3 },
		choices = {
			{ label = "Find the auction", result = { caseOpen = "case_quiet_auction", log = "You burned the page and memorized lot nine. Then you started asking quiet questions of people who answer them for money." } },
			{ label = "It isn't your business", result = { sanity = -3, log = "You told yourself it wasn't your business. You were wrong, and you'll know it every time you hear the name." } },
		},
	},

	-- ── finales ──
	{
		id = "case_courier_finale",
		title = "The Trunk",
		text = "The courier is alive, hiding in a laundry court with the trunk under the bed. They opened it, and they won't say what was inside, only that they couldn't deliver it, and couldn't give it back. \"You can take it,\" the courier says. \"Just don't open it. Please.\"",
		weight = 0,
		tags = { "case" },
		choices = {
			{ label = "Return the trunk, sealed, and the courier home", result = { caseClose = "case_missing_courier", money = { 600, 1100 }, rep = { fixers = 6 }, sanity = 4, gear = "cs_hana_commendation", log = "The Association took the trunk without opening it. The family took the courier home. Hana sent a commendation for the file, which nobody had asked for." } },
			{ label = "Let the courier go, and lose the trunk in the canal", result = { caseClose = "case_missing_courier", sanity = 6, rep = { fixers = -4 }, log = "You dropped it in the canal at three in the morning. It didn't sink for a long time. The courier left for another District that night, and wrote to you once, to say thank you." } },
			{ label = "Open it", clash = check("mind", "Whatever couldn't be delivered", 7), win = { caseClose = "case_missing_courier", mind = 3, limitBreak = { mind = 5 }, money = { 300, 600 }, log = "You opened it. You understood, immediately, why the courier couldn't deliver it. You delivered it anyway, and you were never quite the same, and in some ways better." }, lose = { caseClose = "case_missing_courier", sanity = -14, log = "You opened it. You understood, too late, why the courier hid." } },
		},
	},
	{
		id = "case_prescripts_finale",
		title = "The Print Shop",
		text = "The print shop is very clean. The forger is a tired man in ink-stained cuffs who was a Proxy of the Index once, and was cast out, and kept the habit. \"People are happier with instructions,\" he says, not looking up from the press. \"I was only giving them what the City took away.\"",
		weight = 0,
		tags = { "case", "fingers" },
		choices = {
			{ label = "Hand him over to the Index", result = { caseClose = "case_counterfeit_prescripts", rep = { index = 15 }, money = { 500, 900 }, sanity = -4, log = "The Index thanked you in a single line on a white card. You never saw the forger again. Nobody did." } },
			{ label = "Tell him to run", result = { caseClose = "case_counterfeit_prescripts", sanity = 3, gear = "cs_index_card", log = "He thanked you, packed a bag in four minutes, and left his last blank card on the press. You took it. You've never written on it." } },
			{ label = "Break the press, and him if he argues", clash = { stat = "strength", foe = "A former Proxy, cornered", enemy = "index_proxy", fight = true, coins = 3, base = 7, coinPower = 4 }, win = { caseClose = "case_counterfeit_prescripts", renown = 10, rep = { index = 6 }, log = "He argued. The press is scrap now, and the cards stopped coming the same night." }, lose = { health = { -20, -8 }, cause = "A forger of Prescripts", log = "He was still very good at what the Index taught him. You'll try again when you can stand." } },
		},
	},
	{
		id = "case_doors_finale",
		title = "The Painter",
		text = "The painter is in the last house on the street, finishing the door from the inside: a woman in a smock covered in every color you've seen on the street this year, who signs her name in the corner of each door, very small. It's a name from an old Ring exhibition catalogue. The painter in the catalogue died twelve years ago.",
		weight = 0,
		tags = { "case", "strange" },
		choices = {
			{ label = "Ask her to stop", clash = check("charisma", "An artist with one door left", 7), win = { caseClose = "case_painted_doors", sanity = 6, log = "She put down the brush. \"It's finished anyway,\" she said, and walked out of the house into the street, and was not there when you followed her. The people behind the painted doors came out the next morning, hungry and fine." }, lose = { sanity = -6, log = "She didn't hear you. She's still painting. You'll have to come back." } },
			{ label = "Burn the catalogue", result = { caseClose = "case_painted_doors", mind = 2, sanity = -3, log = "You burned the catalogue page with her name on it in the street. The paint on every door blistered at once. In the morning the doors were plain, and the people behind them came out, and none of them remember a thing." } },
			{ label = "Stop her by force", clash = { stat = "strength", foe = "A painter of the Ring", enemy = "ring_artist", fight = true, coins = 3, base = 7, coinPower = 4 }, win = { caseClose = "case_painted_doors", renown = 10, log = "When it was over, there was only a smock and a brush on the floor. The doors stayed painted. They're beautiful. People come from other Districts to see them." }, lose = { health = { -18, -8 }, sanity = -4, cause = "The Painted Doors", log = "She painted you, a little, on the way out. It took a month to wash off." } },
		},
	},
	{
		id = "case_branch_finale",
		title = "The Service Lift",
		text = "Behind the building's boiler, under twelve coats of paint, is a service lift with an old L Corp maintenance plate. It still works. Every day at the same hour the doors open, wait exactly one minute, and close. Today you're standing in front of them when they open.",
		weight = 0,
		tags = { "case", "lcorp" },
		choices = {
			{ label = "Step in", hint = "Down into whatever the branch was.", result = { caseClose = "case_hollow_branch", expedition = "dv_branch_laundromat", log = "You stepped in. The doors closed. The lift went down for a long time." } },
			{ label = "Report it to the Hana Association", result = { caseClose = "case_hollow_branch", renown = 8, money = { 500, 900 }, gear = "cs_hana_commendation", log = "Hana's people sealed the lift and took the plans, and paid for both. The grinding stopped. The tenants say the building feels lonely now." } },
			{ label = "Sell the location", result = { caseClose = "case_hollow_branch", money = { 1200, 2000 }, sanity = -4, log = "A salvage crew paid well for the location. You heard later that they went down, and you didn't hear anything after that." } },
		},
	},
	{
		id = "case_auction_finale",
		title = "Lot Nine",
		text = "The Quiet Auction is held in a ballroom with the windows painted black. The bidders wear masks, which seems unnecessary until you see who's under some of them. Lot nine comes up at midnight: a contract with a name on it, and the person whose name it is, standing very still at the side of the stage.",
		weight = 0,
		rare = true,
		tags = { "case", "nest" },
		choices = {
			{ label = "Outbid everyone", requires = { min = { money = 6000 } }, result = { caseClose = "case_quiet_auction", money = -6000, sanity = 8, addRelation = { kind = "friend", bond = 70 }, log = "You bid until the room went quiet, and kept bidding. Then you tore the contract up on the stage. Some of the masks applauded. You made a friend that night, for the rest of your life." } },
			{ label = "Take the contract in the confusion", clash = check("speed", "A ballroom full of very rich guards", 8), win = { caseClose = "case_quiet_auction", renown = 12, gear = "cs_auction_gavel", log = "The lights went out, which you'd arranged. When they came back on, lot nine, the contract and the auctioneer's gavel were gone, and so were you." }, lose = { health = { -22, -10 }, money = { -800, -300 }, cause = "The Quiet Auction", log = "The lights went out, which you'd arranged. The guards had arranged better." } },
			{ label = "Expose the auction to Hana", clash = check("charisma", "People who own the people who'd listen", 8), win = { caseClose = "case_quiet_auction", renown = 20, rep = { fixers = 10 }, log = "You gave Hana the guest list. The Quiet Auction hasn't been held since. Several Nests have very quietly changed hands." }, lose = { caseClose = "case_quiet_auction", sanity = -8, log = "Hana took your report, and thanked you, and did nothing. The auction went on. Lot nine was sold." } },
		},
	},
}
