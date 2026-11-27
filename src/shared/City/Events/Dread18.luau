--[[
	DREAD (v0.18, dr18_ ids): the City at its worst, sent at random to grown-ups (on top of the
	year's cards, now and then: pack.hardness.dread). Every one is a real fight or a real
	price, and the ones you win pay like it. Canon notes: docs/CANON.md 1.6 (Rats), 3.1-3.3 (the
	Thumb, the Index, the Middle), 3.7 (the Kurokumo Clan), 4.2 (Shi, Zwei, Cinq, Devyat'),
	6.4 (Distortions). Nobody named from canon appears.
	Chains (they become the life's focus: Engine/Focus.luau):
		dr18_shi_contract -> dr18_shi_client
		dr18_thumb_word -> (1 year) dr18_thumb_capo
		dr18_middle_book -> (1 year) dr18_middle_big
]]

local ADULT = 20

return {
	-- ── a contract on you ──
	{
		id = "dr18_shi_contract",
		title = "A Name on a Shi Contract",
		text = "Three Districts, three days, the same quiet woman at the edge of every crowd. On the fourth day a note is under your door, very neatly folded: the Shi Association has been paid, and it is sorry for the inconvenience.",
		weight = 2,
		dread = true,
		cooldown = 14,
		tags = { "danger", "crime" },
		art = "alley",
		when = { minAge = ADULT + 2 },
		codex = "fx_lore_shi",
		choices = {
			{
				label = "Meet her in the open",
				hint = "A Shi assassin. They don't miss twice.",
				clash = { stat = "strength", foe = "A Shi Association assassin", enemy = "shi_assassin", coins = 4, base = 11, coinPower = 5, fight = true, status = { id = "bleed", potency = 3 } },
				win = { strength = 4, speed = 2, money = { 2500, 6000 }, renown = 12, log = "She was very good. You were, for eleven seconds, better. Her contract fee was still in her coat, and nobody came to ask for it back." },
				lose = { health = { -29, -17 }, sanity = -6, log = "You never saw the second blade.", cause = "Killed on a Shi Association contract" },
			},
			{
				label = "Find out who paid for it",
				hint = "Intelligence check. Then you deal with them.",
				clash = { stat = "intelligence", foe = "A contract with no name on it", coins = 4, base = 10, coinPower = 4 },
				win = { trigger = "dr18_shi_client", log = "Three bribes and a forged receipt later you had it: who paid, how much, and the address where they sleep." },
				lose = { health = { -20, -9 }, sanity = -5, log = "Asking questions about a Shi contract is how they learn you know about it.", cause = "Killed asking about a Shi contract" },
			},
			{
				label = "Hire Zwei to stand over you",
				hint = "6,000 Ahn. The Zwei Association calls itself the client's shield.",
				requires = { min = { money = 6000 } },
				result = { money = -6000, sanity = -4, log = "Two Zwei Fixers walked you everywhere for a season, shields up, saying nothing. The contract lapsed. The note-folder never came back." },
			},
			{
				label = "Go to ground for a year",
				result = { money = { -1800, -900 }, sanity = -12, health = { -6, -3 }, log = "A rented room with no window, a different name, food through a hatch. When you came out, someone else had been killed instead, and you never found out who." },
			},
		},
	},
	{
		id = "dr18_shi_client",
		title = "The Client",
		text = "The one who paid the Shi Association to have you killed lives behind two guards and a very good door. Through the window you can see them eating dinner, as if it were any other night.",
		weight = 0,
		tags = { "danger", "crime" },
		art = "home",
		codex = "fx_lore_shi",
		choices = {
			{
				label = "Through the guards",
				clash = { stat = "strength", foe = "Two hired guards and a very good door", enemy = "fixer", coins = 4, base = 10, coinPower = 5, fight = true },
				win = { strength = 3, money = { 4000, 9000 }, renown = 10, setFlags = { "dr18_client_dealt" }, log = "The guards had been paid for a quiet night. The client paid for a great deal more than that, in cash, to make you go away. The contract was withdrawn by morning." },
				lose = { health = { -23, -12 }, log = "The door was better than you'd hoped.", cause = "Killed by the guards of the one who paid for their death" },
			},
			{
				label = "Knock, and talk",
				hint = "Charisma check. A contract can be bought back.",
				clash = { stat = "charisma", foe = "Someone who wants you dead", coins = 4, base = 10, coinPower = 4 },
				win = { charisma = 3, money = { 1500, 3500 }, sanity = 4, log = "It came down to an old grudge and a wrong name. The client cancelled the contract, paid a cancellation fee to the Shi, and paid you one for the trouble." },
				lose = { health = { -16, -6 }, sanity = -6, log = "They listened politely, and then the guards walked you down the stairs the fast way." },
			},
			{ label = "Leave a message on the door and go", result = { sanity = -4, renown = 4, log = "You left a knife in the door at eye height. The contract was withdrawn the next day. You never learned what they thought you'd do." } },
		},
	},

	-- ── the Thumb ──
	{
		id = "dr18_thumb_word",
		title = "A Word Out of Place",
		text = "You didn't bow. Or you bowed, but not low enough, to a man in a sharp suit with a rifle on his shoulder. The street goes quiet around you. \"Again,\" says the Thumb Soldato. \"Properly, this time.\"",
		weight = 2,
		dread = true,
		cooldown = 12,
		tags = { "danger", "crime" },
		art = "syndicate",
		when = { minAge = ADULT, side = "backstreets" },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Bow properly, and apologise",
				hint = "Charisma check. The Thumb punishes a single wrong word.",
				clash = { stat = "charisma", foe = "A Soldato's idea of manners", coins = 4, base = 9, coinPower = 4 },
				win = { sanity = -5, rep = { thumb = 2 }, log = "You bowed until your back hurt and called him Signore. He let you go with a lecture on the proper angle." },
				lose = { health = { -17, -8 }, condition = "broken_arm", rep = { thumb = -2 }, log = "He decided the apology was itself an insult, and taught you the difference with the stock of his rifle." },
			},
			{
				label = "Teach him some manners",
				hint = "Three Soldati, and the Thumb remembers.",
				clash = { stat = "strength", foe = "Three Thumb Soldati", enemy = "thumb_soldato", coins = 4, base = 11, coinPower = 5, fight = true, status = { id = "rupture", potency = 2 } },
				win = { strength = 4, money = { 1500, 4000 }, renown = 10, rep = { thumb = -8 }, schedule = { event = "dr18_thumb_capo", inYears = 1 }, log = "The street watched you put three Soldati on the ground. Someone took a picture. By evening, a Capo had seen it." },
				lose = { health = { -27, -16 }, rep = { thumb = -4 }, log = "They had rifles. You had opinions.", cause = "Shot by the Thumb for a word out of place" },
			},
			{
				label = "Pay the fine",
				hint = "2,500 Ahn for the insult.",
				requires = { min = { money = 2500 } },
				result = { money = -2500, sanity = -3, log = "Insults have a price list. You paid it in front of everyone, and the Soldato wrote you a receipt." },
			},
		},
	},
	{
		id = "dr18_thumb_capo",
		title = "The Capo Comes Himself",
		text = "A year on, a car with no plates waits outside your building. The man who gets out wears a Capo's pin and very good gloves, and two Soldati open the door for him. \"You embarrassed my men,\" he says. \"So now I am embarrassed. Let us fix it.\"",
		weight = 0,
		tags = { "danger", "crime" },
		art = "street",
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Fight the Capo",
				hint = "A Thumb Capo and his men. The richest fight you'll be offered this year.",
				clash = { stat = "strength", foe = "A Thumb Capo", enemy = "thumb_capo", coins = 5, base = 14, coinPower = 6, fight = true, status = { id = "rupture", potency = 3 } },
				win = { strength = 6, speed = 3, money = { 7000, 14000 }, renown = 30, rep = { thumb = -12 }, setFlags = { "dr18_beat_capo" }, log = "When it was over the Capo's gloves were on the pavement and his men were gone. His car had a case of Ahn in the back, which, by the rules of the street, was yours now." },
				lose = { health = { -39, -22 }, rep = { thumb = -6 }, log = "The Capo didn't raise his voice once.", cause = "Executed by a Thumb Capo" },
			},
			{
				label = "Offer to work off the debt",
				hint = "Charisma check. The Thumb respects a contract.",
				clash = { stat = "charisma", foe = "A Capo's patience", coins = 4, base = 12, coinPower = 5 },
				win = { money = { -3000, -1500 }, sanity = -6, rep = { thumb = 6 }, log = "You carried crates for the Thumb for six months, and bowed exactly right every single morning. The debt was struck from his book." },
				lose = { health = { -22, -12 }, sanity = -8, log = "He said he'd think about it, and then his men helped him think.", cause = "Beaten to death by the Thumb" },
			},
			{
				label = "Run, tonight",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A car with no plates", coins = 4, base = 12, coinPower = 5 },
				win = { speed = 3, money = { -2500, -1200 }, sanity = -8, log = "Out the back, over two roofs, onto the last train out of the District with only the clothes you wore. You started again somewhere the Capo had no men." },
				lose = { health = { -26, -13 }, log = "The car was faster.", cause = "Hunted down by the Thumb" },
			},
		},
	},

	-- ── the Index ──
	{
		id = "dr18_index_prescript",
		title = "Your Name on a Prescript",
		text = "A young Proselyte stands in your doorway with a slip of paper, reading it twice to be sure. Then he folds it away and looks at you with something close to apology. \"The Prescript names you,\" he says. \"I'm afraid it isn't specific about anything else.\"",
		weight = 2,
		dread = true,
		cooldown = 14,
		tags = { "danger", "crime" },
		art = "home",
		when = { minAge = ADULT },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Fight him in the doorway",
				clash = { stat = "strength", foe = "An Index Proselyte with a Prescript", enemy = "index_proselyte", coins = 4, base = 12, coinPower = 5, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 4, money = { 1800, 4500 }, renown = 14, rep = { index = -6 }, log = "He fought like someone who had never once been allowed to doubt. You won anyway. The Index sends another eventually; it always does. Not this year." },
				lose = { health = { -30, -17 }, log = "The Prescript was carried out exactly as written.", cause = "Killed by the Index to fulfil a Prescript" },
			},
			{
				label = "Ask to read the slip",
				hint = "Intelligence check. Prescripts are exact. Exact things have loopholes.",
				clash = { stat = "intelligence", foe = "The wording of a Prescript", coins = 4, base = 11, coinPower = 4 },
				win = { intelligence = 4, sanity = 3, log = "It named the tenant of this flat, as of a date last month. You'd moved in on the third. The Proselyte read it again, bowed, and went away to think." },
				lose = { health = { -20, -9 }, sanity = -6, log = "The wording was perfectly clear, and so was he.", cause = "Killed by the Index to fulfil a Prescript" },
			},
			{
				label = "Out the window",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A Proselyte who doesn't get tired", coins = 4, base = 12, coinPower = 5 },
				win = { speed = 3, sanity = -6, log = "You ran for two Districts. When you stopped he was gone: a Prescript has a deadline, and yours had passed." },
				lose = { health = { -25, -12 }, log = "He caught you on the fourth roof.", cause = "Killed by the Index to fulfil a Prescript" },
			},
		},
	},

	-- ── the Middle ──
	{
		id = "dr18_middle_book",
		title = "Written in the Book",
		text = "Somebody you once worked for crossed the Middle, and the Middle doesn't write down only one name. A Little Brother with the tattoos on his neck finds you at lunch. He's very polite about it. \"You're in the Book,\" he says. \"Sorry. Family business.\"",
		weight = 2,
		dread = true,
		cooldown = 14,
		tags = { "danger", "crime" },
		art = "diner",
		when = { minAge = ADULT },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Fight the Little Brothers",
				hint = "The Middle always pays its debts.",
				clash = { stat = "strength", foe = "Three Little Brothers of the Middle", enemy = "middle_sibling", coins = 4, base = 11, coinPower = 5, fight = true, status = { id = "bleed", potency = 3 } },
				win = { strength = 4, money = { 1200, 3500 }, renown = 10, rep = { middle = -10 }, schedule = { event = "dr18_middle_big", inYears = 1 }, log = "Three Little Brothers carried each other home. Somewhere a Big Sister wrote your name in the Book a second time, and underlined it." },
				lose = { health = { -29, -16 }, log = "They were very sorry about it, right to the end.", cause = "Killed by the Middle over someone else's grudge" },
			},
			{
				label = "Ask what would square it",
				hint = "Charisma check. The Book can be paid.",
				clash = { stat = "charisma", foe = "The Middle's Book of Vengeance", coins = 4, base = 11, coinPower = 4 },
				win = { money = { -3000, -1500 }, rep = { middle = 4 }, sanity = 2, log = "You paid your old boss's debt, with interest, and gave the Little Brother his address. Your name was crossed out in front of you, very carefully." },
				lose = { health = { -17, -8 }, sanity = -6, log = "He said only a Big Brother could decide that, and that this was a no." },
			},
			{
				label = "Give them who they really want",
				result = { sanity = -10, rep = { middle = 6 }, log = "You gave them your old boss's address and a key to the back door. Your name came out of the Book. You don't go to that part of the District any more." },
			},
		},
	},
	{
		id = "dr18_middle_big",
		title = "The Big Sister",
		text = "A year on, a woman with the Middle's tattoos all the way up to her jaw sits down across from you on the bus. \"My Little Brothers still can't lift their arms,\" she says. \"I'm here to take it out of you personally.\"",
		weight = 0,
		tags = { "danger", "crime" },
		art = "bus",
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Fight the Big Sister",
				hint = "A Big Sister of the Middle. Win, and they'll leave you be: it costs too much.",
				clash = { stat = "strength", foe = "A Big Sister of the Middle", enemy = "middle_big", coins = 5, base = 14, coinPower = 6, fight = true, status = { id = "bleed", potency = 4 } },
				win = { strength = 6, money = { 5000, 11000 }, renown = 28, setFlags = { "dr18_beat_big_sister" }, log = "The bus emptied at the next stop. When it was over she laughed, spat, and wrote you out of the Book herself: a debt that costs this much isn't worth collecting. Her purse went with you." },
				lose = { health = { -38, -21 }, log = "The Middle always pays its debts.", cause = "Killed by a Big Sister of the Middle" },
			},
			{
				label = "Get off at the next stop",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A Big Sister between you and the door", coins = 4, base = 13, coinPower = 5 },
				win = { speed = 3, sanity = -8, log = "You were through the doors as they closed. She watched you from the window, and waved." },
				lose = { health = { -26, -14 }, log = "The doors closed first.", cause = "Killed by a Big Sister of the Middle" },
			},
		},
	},

	-- ── the Kurokumo Clan ──
	{
		id = "dr18_kurokumo_fee",
		title = "The Clan Raises the Fee",
		text = "Four Kurokumo Wakashu in dark wavy coats, long swords in their sheaths, come into the place where you work. The boss goes white. The fee for protection has tripled, they say, and they will wait while everyone thinks about it.",
		weight = 2,
		dread = true,
		cooldown = 12,
		tags = { "danger", "crime" },
		art = "market",
		when = { minAge = ADULT, side = "backstreets" },
		codex = "fn_lore_kurokumo",
		choices = {
			{
				label = "Throw them out",
				hint = "Four Wakashu. The Clan feuds for years.",
				clash = { stat = "strength", foe = "Four Kurokumo Wakashu", enemy = "kurokumo", coins = 4, base = 11, coinPower = 5, fight = true, status = { id = "bleed", potency = 3 } },
				win = { strength = 4, money = { 2000, 5000 }, renown = 12, rep = { kurokumo = -10 }, log = "Four swords on the floor, four Wakashu in the street. The boss gave you a year's wages in an envelope and told you never to come back, for both your sakes." },
				lose = { health = { -29, -16 }, rep = { kurokumo = -4 }, log = "They never even raised their voices.", cause = "Cut down by the Kurokumo Clan" },
			},
			{
				label = "Get the whole street to refuse",
				hint = "Charisma check. One shop is a target; a street is a war.",
				clash = { stat = "charisma", foe = "A street too scared to stand up", coins = 4, base = 11, coinPower = 4 },
				win = { charisma = 4, renown = 16, rep = { kurokumo = -4 }, log = "Every shutter on the street came down at once. The Wakashu stood in the empty road for an hour, and then went back to tell someone. The fee stayed what it was." },
				lose = { health = { -17, -8 }, sanity = -6, log = "The street stayed open. You were the only one who'd said no." },
			},
			{ label = "Chip in for the fee", requires = { min = { money = 1800 } }, result = { money = -1800, sanity = -4, log = "Everyone chipped in. Your share was most of what you had." } },
		},
	},

	-- ── a Cinq duel ──
	{
		id = "dr18_cinq_glove",
		title = "The Glove",
		text = "A woman in a wide hat and a cape steps out of a crowd and drops a white glove at your feet. \"On behalf of my client, whom you wronged,\" says the Cinq Association duellist. \"Noon, the square. Or forfeit, and everyone will know.\"",
		weight = 2,
		dread = true,
		cooldown = 16,
		tags = { "danger" },
		art = "hall",
		when = { minAge = ADULT + 4 },
		codex = "fx_lore_cinq",
		choices = {
			{
				label = "Pick up the glove",
				hint = "A contract duel. The purse goes to the winner.",
				clash = { stat = "strength", foe = "A Cinq Association duellist", enemy = "cinq_duelist", coins = 4, base = 12, coinPower = 5, fight = true, status = { id = "poise", potency = 3 } },
				win = { strength = 5, speed = 2, money = { 3500, 8000 }, renown = 22, log = "Noon, the square, a ring of strangers. She bowed when it was over, handed you the purse, and told her client it was a matter of honour now settled." },
				lose = { health = { -32, -18 }, renown = -4, log = "It was a very honourable death, everyone agreed.", cause = "Fell in a Cinq contract duel" },
			},
			{
				label = "Hire a stand-in",
				hint = "5,000 Ahn. Contract duels allow a champion.",
				requires = { min = { money = 5000 } },
				result = { money = -5000, renown = -2, log = "Your champion won in nine seconds. It was the most expensive nine seconds you'll ever watch." },
			},
			{ label = "Forfeit", result = { renown = -8, sanity = -6, log = "You walked away from the glove. By evening the whole District had heard, and some of them laughed." } },
		},
	},

	-- ── Rats: nobody misses a Rat ──
	{
		id = "dr18_rat_pack",
		title = "Twenty Rats",
		text = "Not four Rats. Twenty, with pipes and stolen knives, all the bums from three alleys at once, and they've decided your block is theirs now. Nobody official is coming. Nobody ever comes for Rats, either way.",
		weight = 3,
		dread = true,
		cooldown = 10,
		tags = { "danger", "crime" },
		art = "alley",
		when = { minAge = 16, side = "backstreets" },
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Clear them out",
				hint = "They're weak, but there are twenty of them.",
				clash = { stat = "strength", foe = "Twenty Rats", enemy = "rat_boss", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 4, money = { 600, 1800 }, renown = 6, log = "By the end there were six Rats left, running. Nobody came asking about the rest. Nobody ever does. The block bought you dinner for a week." },
				lose = { health = { -21, -10 }, log = "Twenty is a lot of Rats.", cause = "Beaten to death by a pack of Rats" },
			},
			{
				label = "Hold the stairwell",
				hint = "Health check. One at a time, they're nothing.",
				clash = { stat = "health", foe = "A stairwell full of Rats", coins = 4, base = 9, coinPower = 4 },
				win = { health = { -5, -1 }, sanity = -2, money = { 200, 700 }, log = "They came up the stairs one at a time, which is how Rats lose. By dawn they'd gone, and left their knives behind." },
				lose = { health = { -17, -8 }, log = "They came up the stairs all at once." },
			},
			{ label = "Pay them to go somewhere else", result = { money = { -500, -200 }, sanity = -4, log = "They took the Ahn, went one street over, and did the same thing to someone else." } },
		},
	},

	-- ── a Distortion ──
	{
		id = "dr18_block_distorts",
		title = "The Block Distorts",
		text = "Your neighbour on the third floor has been crying for a week. Tonight it stops. The lights go, and then the stairwell is somewhere else: too long, too warm, full of something that used to be a person and is calling everyone by her name.",
		weight = 2,
		dread = true,
		cooldown = 18,
		tags = { "danger", "horror" },
		art = "distortion",
		when = { minAge = ADULT, world = { era = { "library", "limbus" } } },
		codex = "terms_distortion",
		choices = {
			{
				label = "Go up and end it",
				hint = "A Distortion. It can't be talked to.",
				clash = { stat = "strength", foe = "Your neighbour, Distorted", enemy = "distortion", coins = 4, base = 13, coinPower = 6, fight = true, status = { id = "sinking", potency = 3 } },
				win = { strength = 5, mind = 3, sanity = -8, renown = 18, money = { 1500, 4000 }, log = "It ended on the landing. In the morning the Association that came to look paid you a finder's fee, and asked a lot of questions you didn't have answers to." },
				lose = { health = { -32, -18 }, sanity = -10, log = "The stairs went on and on.", cause = "Killed by a Distortion in their own building" },
			},
			{
				label = "Get everyone out",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A building that has stopped being a building", coins = 4, base = 12, coinPower = 5 },
				win = { speed = 3, sanity = -4, renown = 12, log = "You went door to door in the dark, and every door you knocked on came out with you. The Distortion had the building to itself by dawn." },
				lose = { health = { -23, -12 }, sanity = -8, log = "The corridor was longer on the way back.", cause = "Lost in a Distorted building" },
			},
			{ label = "Out the window, alone", result = { health = { -9, -4 }, sanity = -14, log = "You climbed down the drainpipe and didn't look back. In the morning the building was quiet, and the Association said there was no one left to ask." } },
		},
	},

	-- ── a Devyat' courier ──
	{
		id = "dr18_courier_trunk",
		title = "A Courier's Trunk",
		text = "A Devyat' Association courier falls out of the sky, more or less, and lands in front of you with his trunk. He's out cold. The trunk is ticking. Down the street, six people with very fast shoes are running your way.",
		weight = 2,
		dread = true,
		cooldown = 16,
		tags = { "danger" },
		art = "street",
		when = { minAge = 18 },
		codex = "fx_lore_devyat",
		choices = {
			{
				label = "Stand over him until he wakes",
				hint = "Six thieves. The Devyat' Association is grateful in Ahn.",
				clash = { stat = "strength", foe = "Six trunk thieves", enemy = "thug", coins = 4, base = 10, coinPower = 5, fight = true },
				win = { strength = 4, money = { 3000, 7000 }, renown = 10, log = "The courier came round to six thieves asleep on the pavement and you sitting on his trunk. He made his deadline with four minutes to spare, and the Association paid you a bonus that made your eyes water." },
				lose = { health = { -23, -12 }, log = "Six was too many.", cause = "Killed defending a courier's trunk" },
			},
			{
				label = "Run the trunk to its address",
				hint = "Speed check. Couriers are almost never late.",
				clash = { stat = "speed", foe = "A deadline you don't know", coins = 4, base = 12, coinPower = 5 },
				win = { speed = 4, money = { 2500, 5500 }, log = "You made it with seconds to spare. The recipient signed for it without looking at you, and the Association tracked you down a week later with a fee and a job offer." },
				lose = { health = { -20, -9 }, sanity = -4, log = "The thieves had faster shoes." },
			},
			{ label = "Walk the other way", result = { sanity = -2, log = "You walked the other way. You heard later he made the deadline anyway. They almost always do." } },
		},
	},
	-- ── a Workshop's prototype ──
	{
		id = "dr18_prototype_loose",
		title = "A Prototype Gets Loose",
		text = "The Workshop at the end of your street has been building something for a Wing. Tonight it walks out through the wall on its own: three metres of scrap and pistons, very confused, and very, very strong.",
		weight = 2,
		dread = true,
		cooldown = 16,
		tags = { "danger" },
		art = "workshop",
		when = { minAge = 18 },
		codex = "bs_lore_workshops",
		choices = {
			{
				label = "Bring it down",
				hint = "It can't be talked to. The Workshop will pay to get it back in one piece, more or less.",
				clash = { stat = "strength", foe = "A Workshop prototype", enemy = "scrap_golem", coins = 4, base = 12, coinPower = 6, fight = true, status = { id = "tremor", potency = 3 } },
				win = { strength = 5, money = { 2500, 6500 }, renown = 12, log = "It went over like a falling building. The Workshop's master paid you for the parts you didn't break, and asked if you'd like to test the next one." },
				lose = { health = { -31, -17 }, log = "It didn't mean anything by it.", cause = "Crushed by a Workshop prototype" },
			},
			{
				label = "Find its off switch",
				hint = "Intelligence check. Every machine has one.",
				clash = { stat = "intelligence", foe = "Somebody else's wiring", coins = 4, base = 11, coinPower = 5 },
				win = { intelligence = 4, money = { 1500, 4000 }, log = "Behind a panel on its back, under a sticker that said DO NOT. It sat down in the road and went quiet. The Workshop paid you to keep it to yourself." },
				lose = { health = { -22, -10 }, log = "It wasn't that switch.", cause = "Crushed by a Workshop prototype" },
			},
			{ label = "Get the street indoors", result = { sanity = -4, renown = 4, log = "You banged on every door until the street was empty. The prototype wandered into the canal around dawn, and the Workshop pretended it had never existed." } },
		},
	},

	-- ── a file with your name on it ──
	{
		id = "dr18_sold_file",
		title = "Your File Was Sold",
		text = "The Seven Association gathers what it's paid to gather, and somebody paid for you: where you sleep, who you love, when you're alone. Now the file has been sold on, and the crew who bought it are waiting on your stairs.",
		weight = 2,
		dread = true,
		cooldown = 16,
		tags = { "danger", "crime" },
		art = "home",
		when = { minAge = ADULT + 2 },
		codex = "fx_lore_seven",
		choices = {
			{
				label = "Fight them on the stairs",
				clash = { stat = "strength", foe = "A crew with your whole life in a folder", enemy = "fixer", coins = 4, base = 11, coinPower = 5, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 4, money = { 2000, 5000 }, renown = 10, log = "They knew everything about you except how hard you'd fight. The folder burned nicely, and their wages went in your pocket." },
				lose = { health = { -29, -16 }, log = "They knew you'd come home at nine.", cause = "Killed by a crew who bought their file" },
			},
			{
				label = "Change everything the file says",
				hint = "Intelligence check. A file is only as good as it is true.",
				clash = { stat = "intelligence", foe = "Everything they know about you", coins = 4, base = 11, coinPower = 4 },
				win = { intelligence = 4, money = { -1200, -500 }, sanity = -4, log = "New room, new route, new hours, a new name on the door. When the crew came, they found a stranger who'd never heard of you." },
				lose = { health = { -20, -9 }, sanity = -6, log = "You changed everything except the one thing they were watching." },
			},
			{ label = "Hand them what they want", result = { money = { -2500, -1000 }, sanity = -10, log = "It turned out they only wanted money. It always does, until it doesn't." } },
		},
	},

	-- ── a bounty ──
	{
		id = "dr18_bounty",
		title = "A Bounty on Your Head",
		text = "Your face is on a contract board in a Fixer bar two Districts over, with a price under it that is honestly flattering. By the end of the week, three different Offices have taken the job.",
		weight = 2,
		dread = true,
		cooldown = 14,
		tags = { "danger" },
		art = "street",
		when = { minAge = ADULT + 4 },
		codex = "fx_lore_grades",
		choices = {
			{
				label = "Let them come, one Office at a time",
				hint = "Three Offices. Each one you beat makes the next one more careful.",
				clash = { stat = "strength", foe = "Three Fixer Offices on one contract", enemy = "fixer", coins = 5, base = 12, coinPower = 5, fight = true, status = { id = "rupture", potency = 2 } },
				win = { strength = 5, speed = 3, money = { 4000, 10000 }, renown = 26, log = "The first Office came in force, the second came carefully, and the third came to negotiate. In the end the client withdrew the bounty and paid the Offices' costs, and you took the rest of the money off the board yourself." },
				lose = { health = { -36, -20 }, log = "The third Office was the careful one.", cause = "Killed for a bounty" },
			},
			{
				label = "Find out who posted it",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A contract board's discretion", coins = 4, base = 12, coinPower = 4 },
				win = { intelligence = 4, renown = 10, money = { 1000, 3000 }, log = "The client was someone you'd embarrassed years ago. Once you showed up at their door, they found the money to cancel it, and a little more for you." },
				lose = { health = { -23, -12 }, log = "Asking at the bar told everyone which bar to wait outside.", cause = "Killed for a bounty" },
			},
			{ label = "Disappear for a year", result = { money = { -3000, -1200 }, sanity = -10, log = "You left the District with one bag. A year later the bounty expired, and someone else's face was on the board." } },
		},
	},
}
