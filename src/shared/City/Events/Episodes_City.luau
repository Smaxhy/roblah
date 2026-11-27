--[[
	EPISODES: the City being the City (v0.13). See City/Episodes.luau.
	  ep_book_remembers   after the Library: a warm book at a stall, with a Fixer inside it
	  ep_war_medal        an old soldier of the Smoke War and a fallen Wing's medal
	  ep_kindred_supper   a Bloodfiend Family's supper, and its manners
	  ep_masterwork       a Workshop's new blade, carried for a year
	  ep_office_fire      your Office burns, and a rival Office signed it
	  ep_middle_debt      a debt to the Middle, owed by your household
	  ep_past_the_wall    someone from the Outskirts, with no papers
	  ep_borrowed_hour    District 20: an hour you don't remember, on a T Corp receipt
	  ep_following_light  the Backstreets at night: a streetlight that follows you
	  ep_rain_umbrellas   thirteen umbrellas on your doorstep
	Canon: the Library's guests became books, and its books outlived it; the Smoke War
	brought down District 12's Wing; Bloodfiend Families keep old manners; Workshops make
	the City's weapons; the Hana Association arbitrates between Offices; the Middle repays
	every grudge; the Outskirts lie past the City's walls; T Corp trades in time; the
	Backstreets at night belong to the Sweepers [LoR, Limbus]. Every person here is this
	game's own.
]]

local function check(stat: string, foe: string, base: number?)
	return { stat = stat, foe = foe, coins = 2, base = base or 4, coinPower = 3 }
end

return {
	-- ══ A Book That Remembers (after the Library) ═════════════════════════════
	{
		id = "ep_br_1",
		episode = "ep_book_remembers",
		step = 1,
		title = "Two Ahn a Book",
		text = "A stall under the overpass sells books by the armful, and one of them is warm. It's bound in plain grey cloth with no title, and the first page reads, in handwriting that shifts as you look at it: I was a Fixer. I went to the Library because the invitation said I'd find what I was looking for. The stallholder wants two Ahn for it.",
		weight = 3,
		once = true,
		tags = { "strange", "library" },
		when = { minAge = 14, world = { era = "limbus" } },
		choices = {
			{ label = "Buy it", requires = { min = { money = 2 } }, result = { money = -2, trigger = "ep_br_2", log = "The stallholder wrapped it in newspaper without looking at it. Some of the stallholders under the overpass won't touch those books at all." } },
			{ label = "Ask where it came from, then buy it", requires = { min = { money = 2 } }, result = { money = -2, intelligence = 1, trigger = "ep_br_2", log = "Scavengers bring them back from past the wall, the stallholder said, from where the Library was cast out. \"There's more of them every year. People.\" A shrug. \"Books, I mean.\"" } },
			{ label = "Leave it on the stall", result = { sanity = -1, episodeEnd = "You left a warm book on a cold stall.", log = "You left it. On the way home your hands were warm for no reason." } },
		},
	},
	{
		id = "ep_br_2",
		episode = "ep_book_remembers",
		step = 2,
		when = { world = { era = "limbus" } },
		title = "Reading",
		text = "The book reads like a memory you're having: a Grade 5 Fixer named Oskar Lind, a one-room Office, a sister called Greta who did the accounts, an invitation on very good paper, stairs going down between the shelves, and a Librarian who was kind about it. The pages get warmer the further you read. When you stop, your hands remember the weight of a sword you've never held.",
		weight = 0,
		tags = { "strange", "library" },
		choices = {
			{
				label = "Read on",
				hint = "His life, his skill, his last fight. All of it.",
				clash = check("mind", "Someone else's memories, all at once", 5),
				win = { strength = { 1, 3 }, limitBreak = { strength = 5 }, trigger = "ep_br_3", log = "You read until dawn. You know how Oskar Lind held a sword now. Your body knows it too." },
				lose = { sanity = -6, trigger = "ep_br_3", log = "You read until you couldn't remember which childhood was yours. It came back by morning. Mostly." },
			},
			{ label = "Close it and find his sister", result = { trigger = "ep_br_4", log = "You closed it on the first chapter. The Lind Office wasn't hard to find: one room over a print shop, two Districts over." } },
			{ label = "Sell it to a collector", result = { money = { 600, 1100 }, episodeEnd = "A collector of the Library's books paid well, and handled it with gloves.", log = "There are collectors of the Library's books now. This one paid well, wore gloves to take it, and didn't say what the gloves were for." } },
		},
	},
	{
		id = "ep_br_3",
		episode = "ep_book_remembers",
		step = 3,
		when = { world = { era = "limbus" } },
		title = "The Last Chapter",
		text = "The last chapter is the fight. You feel it as though you were there: the reception, a floor that was a story, the moment Oskar understood he had lost, and what he thought about then, which was his sister's handwriting in the ledger. The book's last line reads: Somebody tell Greta the books balanced.",
		weight = 0,
		tags = { "strange", "library" },
		choices = {
			{ label = "Find Greta Lind", result = { trigger = "ep_br_4", log = "The Lind Office wasn't hard to find: one room over a print shop, two Districts over." } },
			{ label = "Keep the book", result = { gear = "ep_lind_book", episodeEnd = "You kept Oskar Lind's book, and his sword arm.", log = "You kept it. Some nights you read the last chapter again, and lose with him, and wake up knowing something new about how." } },
		},
	},
	{
		id = "ep_br_4",
		episode = "ep_book_remembers",
		step = 4,
		when = { world = { era = "limbus" } },
		title = "The Lind Office",
		scene = { set = "room", kicker = "The Lind Office", other = { name = "Greta Lind", role = "who keeps the books", age = 46 }, line = "\"He went to find what he was looking for. Did he?\"" },
		text = "Greta Lind still does the accounts at the Lind Office, alone, for an Office with one name on the door and no Fixers. When you put the grey book on the desk, Greta doesn't touch it for a long time.",
		weight = 0,
		tags = { "library" },
		choices = {
			{ label = "Give Greta the book", result = { sanity = 8, charisma = 2, renown = 2, episodeEnd = "You gave Greta Lind her brother's book. She closed the ledger.", log = "Greta read the last line, and laughed, and cried, and closed the ledger for the first time in years." } },
			{ label = "Read Greta the last line, and keep the book", result = { sanity = 2, gear = "ep_lind_book", episodeEnd = "You read Greta the last line, and kept the book.", log = "\"The books balanced,\" Greta repeated. \"Of course they did. I did them.\" She told you to keep it. \"He'd want it used.\"" } },
			{ label = "Offer to work for the Lind Office", requires = { flags = { "licensed_fixer" } }, result = { wage = { 200, 400 }, renown = 5, setFlags = { "lind_office" }, episodeEnd = "The Lind Office has a Fixer again.", log = "Greta hired you on the spot, wrote your name in the ledger under her brother's, and gave you his old desk. The Lind Office has a Fixer again." } },
		},
	},

	-- ══ A Medal from the Smoke War ════════════════════════════════════════════
	{
		id = "ep_wm_1",
		episode = "ep_war_medal",
		step = 1,
		title = "The Old Soldier's Medal",
		scene = { set = "stairs", kicker = "Downstairs", other = { name = "Anselm Kral", role = "the old soldier downstairs", age = 78 }, line = "\"Keep it. My grandson would only sell it.\"" },
		text = "Old Anselm Kral downstairs fought in the Smoke War, on the side that lost, and never talks about it. Today Anselm presses a medal into your palm: black iron, with a wing worn smooth by a thumb, the seal of a Wing that doesn't exist anymore. \"Keep it,\" Anselm says. \"My grandson would only sell it.\"",
		weight = 3,
		once = true,
		tags = { "history" },
		when = { minAge = 12, world = { era = { "wings", "white_nights", "library" } } },
		choices = {
			{ label = "Keep it safe", result = { sanity = 1, schedule = { event = "ep_wm_2", inYears = 2 }, log = "You put it in the tin where you keep the things that matter, which until then had been mostly string." } },
			{ label = "Ask Anselm about the war", result = { intelligence = 1, mind = 1, setFlags = { "wm_heard" }, schedule = { event = "ep_wm_2", inYears = 2 }, log = "Anselm talked for three hours. About the smoke that didn't lift for a month, the Wing's tower going dark floor by floor, and the friends whose names Anselm still says every morning." } },
			{ label = "Give it back", result = { sanity = 2, episodeEnd = "You gave Anselm's medal back. Some things should stay with the person who earned them.", log = "Anselm looked at you for a long moment, then nodded, and pinned it back inside a coat that hadn't been worn in years." } },
		},
	},
	{
		id = "ep_wm_2",
		episode = "ep_war_medal",
		step = 2,
		title = "A Collector in Good Shoes",
		text = "Anselm Kral died in his sleep last winter. Now his grandson has come round, and so has a collector from the Nest in very good shoes, who knows exactly what a fallen Wing's medal is worth and opens at 3,000 Ahn.",
		weight = 0,
		tags = { "history" },
		choices = {
			{ label = "Sell to the collector", result = { money = { 3000, 4200 }, sanity = -3, episodeEnd = "The good shoes took Anselm's medal back to the Nest in a velvet box.", log = "The collector paid in clean notes and put the medal in a velvet box without looking at it again." } },
			{ label = "Give it to the grandson", result = { trigger = "ep_wm_3", log = "You told the collector it wasn't yours to sell, and held it out to the grandson." } },
			{ label = "Keep it", result = { gear = "ep_war_medal", episodeEnd = "You kept Anselm's medal, and have never once been tempted.", log = "You kept it. You've never once been tempted to sell, which surprises you, given everything." } },
		},
	},
	{
		id = "ep_wm_3",
		episode = "ep_war_medal",
		step = 3,
		title = "Pavel",
		text = "Pavel Kral turns his grandfather's medal over and over in his hands. \"He never told me any of it,\" Pavel says at last. \"Not one word, my whole life. I thought there was nothing to tell.\"",
		weight = 0,
		tags = { "history" },
		choices = {
			{ label = "Tell Pavel everything Anselm told you", requires = { flags = { "wm_heard" } }, result = { sanity = 6, meet = true, episodeEnd = "You told Pavel what his grandfather told you. The medal hangs on his door now.", log = "You told him all of it, the smoke and the tower and the names. Pavel hung the medal on his front door, where people can see it." } },
			{ label = "Say Anselm was proud of him", result = { charisma = 1, sanity = 4, episodeEnd = "You told Pavel his grandfather was proud of him. It might even have been true.", log = "It might even have been true. Pavel cried in the stairwell, and said thank you, and kept the medal in his breast pocket." } },
		},
	},

	-- ══ Supper with the Kindred ═══════════════════════════════════════════════
	{
		id = "ep_ks_1",
		episode = "ep_kindred_supper",
		step = 1,
		title = "An Invitation in Red Ink",
		text = "The invitation is on heavy card, in red ink that's very nearly brown, and it smells faintly of iron and old roses. The Morvaine Family requests the pleasure of your company at supper. Dress is formal. Manners are expected. Guests are, of course, guaranteed safe passage until the last course is cleared.",
		weight = 3,
		once = true,
		tags = { "bloodfiend", "strange" },
		when = { minAge = 18, form = "human", flags = { "knows_bloodfiends" }, notFlags = { "bf_sold_out" } },
		choices = {
			{ label = "Accept", result = { trigger = "ep_ks_2", log = "You wore your best coat. It wasn't good enough, and you knew it the moment the door opened." } },
			{ label = "Send regrets, politely", result = { rep = { bloodfiends = 2 }, episodeEnd = "You sent your regrets on good paper. A box of very fine chocolates came back.", log = "You sent your regrets on the best paper you could find. A week later a box of very fine chocolates arrived, with no card." } },
			{ label = "Show the card to the hunters", result = { money = { 300, 600 }, rep = { bloodfiends = -25 }, sanity = -2, episodeEnd = "You sold the invitation to the hunters.", log = "The hunters paid for the card and the address. Nobody was at the address when they got there. Someone had left a single red rose on the step." } },
		},
	},
	{
		id = "ep_ks_2",
		episode = "ep_kindred_supper",
		step = 2,
		title = "Supper",
		scene = { set = "hall", kicker = "The Hemobar's back room", other = { name = "The Morvaine Elder", foe = "bf_elder" }, line = "\"Manners first. Then supper.\"" },
		text = "The back room of the Hemobar is lit by candles and very quiet. Six Kindred in old-fashioned clothes sit at a long table, and the Elder at its head is perfectly polite and has not blinked once since you sat down. Your plate holds an ordinary supper, beautifully done. Every other glass at the table holds something darker. The conversation is about manners. It's always about manners.",
		weight = 0,
		tags = { "bloodfiend", "strange" },
		choices = {
			{
				label = "Mind every manner",
				clash = check("charisma", "A table where every rule matters", 6),
				win = { trigger = "ep_ks_3", log = "Every fork, every word, every pause. Down the table, a young Kindred mouthed \"impressive\" at another." },
				lose = { trigger = "ep_ks_slip", log = "Halfway through the third course, the table went silent." },
			},
			{
				label = "Ask the Elder what the Family wants",
				clash = check("mind", "The Elder's attention, all of it", 6),
				win = { trigger = "ep_ks_3", log = "The Elder smiled for the first time, which was not as reassuring as you'd hoped. \"Direct,\" she said. \"How refreshing. After the last course.\"" },
				lose = { trigger = "ep_ks_slip", log = "The Elder's smile didn't move at all. The table went silent." },
			},
			{ label = "Leave before the last course", result = { sanity = -4, rep = { bloodfiends = -10 }, episodeEnd = "You left before the last course, which ended the guarantee.", log = "You left before the last course, which ends the guarantee. You ran the whole way home, and nothing followed. Probably." } },
		},
	},
	{
		id = "ep_ks_3",
		episode = "ep_kindred_supper",
		step = 3,
		title = "The Elder's Offer",
		text = "When the last course is cleared, the Elder of the Morvaine Family touches a napkin to her mouth and says, \"You have lovely manners. The Family has a use for someone with manners who walks in daylight.\" The offer is a favor, owed both ways.",
		weight = 0,
		tags = { "bloodfiend" },
		choices = {
			{ label = "Accept the favor", result = { rep = { bloodfiends = 20 }, money = { 400, 800 }, setFlags = { "ks_favor" }, gear = "ep_kindred_pin", episodeEnd = "The Morvaine Family owes you a favor, and you owe it one.", log = "The Elder pinned a small red enamel rose to your collar herself. \"So the Kindred know you,\" she said. Both of you will collect, one day." } },
			{ label = "Decline, with thanks", result = { rep = { bloodfiends = 6 }, sanity = 2, episodeEnd = "You declined with the best manners you have. The Elder was, if anything, more pleased.", log = "You declined with the best manners you have. The Elder seemed, if anything, more pleased, and had you walked home by two Kindred carrying lanterns." } },
		},
	},
	{
		id = "ep_ks_slip",
		episode = "ep_kindred_supper",
		step = 3,
		title = "A Slip",
		text = "A wrong fork, or a wrong word, or a look at a glass held a moment too long. Nobody at the table moves. The Elder sets down her napkin. \"We did guarantee your safety until the last course,\" she says. \"The last course has not yet been served.\"",
		weight = 0,
		tags = { "bloodfiend", "danger" },
		choices = {
			{
				label = "Apologize, properly",
				clash = check("charisma", "Six Kindred, very offended", 7),
				win = { rep = { bloodfiends = 5 }, episodeEnd = "You apologized so well that a Kindred at the end of the table wrote it down.", log = "You apologized so well that a Kindred at the end of the table wrote it down to use later. The last course was a very good cake." },
				lose = { health = { -14, -6 }, sanity = -6, rep = { bloodfiends = -10 }, cause = "A Bloodfiend supper", episodeEnd = "You were shown out, very firmly.", log = "The last course was served very quickly after that, and two Kindred showed you out, holding your arms very firmly the whole way." },
			},
			{
				label = "Fight your way out",
				clash = { stat = "strength", foe = "The Morvaine Family, at supper", enemy = "bloodfiend", fight = true, coins = 3, base = 8, coinPower = 4 },
				win = { renown = 8, rep = { bloodfiends = -30 }, episodeEnd = "You fought your way out of a Bloodfiend supper. The Family will tell stories about it for a century.", log = "You fought your way out of a Bloodfiend supper, which the Morvaine Family will be telling stories about for a century, none of them flattering." },
				lose = { health = { -30, -15 }, rep = { bloodfiends = -20 }, cause = "A Bloodfiend supper", episodeEnd = "You lost a fight at a Bloodfiend supper, and were let go.", log = "You lost. They let you go, which was the most frightening part, and gave you a cake to take home." },
			},
		},
	},

	-- ══ The Workshop's Masterwork ═════════════════════════════════════════════
	{
		id = "ep_mw_1",
		episode = "ep_masterwork",
		step = 1,
		title = "A Commission",
		text = "A note arrives from the Halvard Workshop, which makes the blades half the Associations carry. They've made something new, and they want a Fixer with a name to carry it for a year and tell them the truth about it. The note is signed by the master herself. The fee: you keep it, if you're still standing at the end of the year.",
		weight = 2,
		once = true,
		rare = true,
		tags = { "fixers" },
		when = { minAge = 20, renown = 2, flags = { "licensed_fixer" } },
		choices = {
			{ label = "Accept the commission", result = { gear = "ep_masterwork_proto", schedule = { event = "ep_mw_2", inYears = 1 }, log = "The prototype came in a case lined with grey felt. It was lighter than it looked and heavier than it felt." } },
			{ label = "Ask what happened to the last one", result = { intelligence = 1, gear = "ep_masterwork_proto", schedule = { event = "ep_mw_2", inYears = 1 }, log = "\"There wasn't a last one,\" the courier said. \"There was a last three.\" You took it anyway." } },
			{ label = "Decline", result = { episodeEnd = "You declined the Halvard commission. You saw the blade a year later, on someone with a bigger name.", log = "You declined. A year later you saw the blade, finished, on a Fixer whose name was on every board." } },
		},
	},
	{
		id = "ep_mw_2",
		episode = "ep_masterwork",
		step = 2,
		title = "The Blade Has Opinions",
		text = "A year with the prototype. It is the best thing you have ever held, and it has opinions. It pulls toward the strongest thing in any room. It hums before a fight starts. Twice it has cut something you didn't swing at. The Halvard master wants your report.",
		weight = 0,
		tags = { "fixers" },
		choices = {
			{
				label = "Tell the truth: it's dangerous",
				clash = check("intelligence", "A master who doesn't like bad news", 5),
				win = { setFlags = { "mw_truth" }, trigger = "ep_mw_3", log = "The master listened to all of it, wrote three pages, and said, \"Good. Now come and show me.\"" },
				lose = { trigger = "ep_mw_3", log = "The master heard you out with her arms folded. \"Show me, then,\" she said." },
			},
			{ label = "Say it's perfect", result = { trigger = "ep_mw_3", log = "\"Perfect,\" you said. The master looked at the new scar on your hand and said, \"Show me, then.\"" } },
			{ label = "Keep it and disappear", result = { rep = { fixers = -10 }, episodeEnd = "You kept the prototype and stopped answering the Workshop's letters.", log = "You kept the prototype and stopped answering the Workshop's letters. The Halvard Workshop has a long memory and a short list, and you're on it." } },
		},
	},
	{
		id = "ep_mw_3",
		episode = "ep_masterwork",
		step = 3,
		title = "The Proving Yard",
		scene = { set = "hall", kicker = "The Halvard proving yard", other = { name = "A Cinq duelist", foe = "cinq_duelist" }, line = "\"Show me what it does. Then show me what you do.\"" },
		text = "The Halvard Workshop's proving yard is sand and stone and a ring of craftsmen with notebooks. Your opponent is a Cinq Association duelist who tests blades for a living and has never yet been cut by one. \"Show me what it does,\" says the master, \"and then show me what you do.\"",
		weight = 0,
		tags = { "fixers", "danger" },
		choices = {
			{
				label = "Prove the blade",
				clash = { stat = "strength", foe = "A Cinq Association duelist", enemy = "cinq_duelist", fight = true, coins = 3, base = 9, coinPower = 5 },
				win = { loseGear = "ep_masterwork_proto", gear = "ep_masterwork_blade", renown = 15, trigger = "ep_mw_4", log = "The duelist went down on the third pass and laughed from the sand. Around the yard, the notebooks were very busy." },
				lose = { health = { -22, -10 }, loseGear = "ep_masterwork_proto", cause = "The Halvard proving yard", episodeEnd = "The duelist won, and the master took the blade back. \"Now we know,\" she said.", log = "The duelist won. The master took the prototype back with a nod. \"Now we know,\" she said. The Workshop still sends you a card every year." },
			},
			{
				label = "Prove yourself: fight with your own weapon",
				hint = "Harder. The master would remember it.",
				clash = { stat = "strength", foe = "A Cinq Association duelist, at their best", enemy = "cinq_duelist", fight = true, coins = 4, base = 10, coinPower = 5 },
				win = { loseGear = "ep_masterwork_proto", gear = "ep_masterwork_blade", renown = 22, strength = { 1, 3 }, limitBreak = { strength = 5 }, trigger = "ep_mw_4", log = "You put the prototype down and won with your own weapon. The yard was silent. Then the master started, very slowly, to clap." },
				lose = { health = { -24, -12 }, loseGear = "ep_masterwork_proto", cause = "The Halvard proving yard", episodeEnd = "You lost on your own terms. The master respected that, and kept the blade.", log = "You lost on your own terms. The master respected that, said so, and kept the blade." },
			},
		},
	},
	{
		id = "ep_mw_4",
		episode = "ep_masterwork",
		step = 4,
		title = "The First of Its Line",
		text = "The Halvard master takes the prototype and hands you the finished blade in its place: the first of a line the Workshop will make for twenty years. Your name is cut into the steel, small, just above the guard.",
		weight = 0,
		rare = true,
		tags = { "fixers" },
		choices = {
			{ label = "Carry it", result = { sanity = 4, episodeEnd = "You carry the first Halvard Line blade, with your name in the steel.", log = "Fixers ask about it at every job. You tell them it's the first of its line, and watch them look at your name." } },
			{ label = "Let them name the line after you", result = { renown = 10, rep = { fixers = 6 }, episodeEnd = "The Halvard Workshop named a line of blades after you.", log = "The Workshop named the line after you. A year later you saw a kid in the Backstreets with a wooden copy of it." } },
		},
	},

	-- ══ The Office Fire ═══════════════════════════════════════════════════════
	{
		id = "ep_of_1",
		episode = "ep_office_fire",
		step = 1,
		title = "Smoke from the Second Floor",
		scene = { set = "street", kicker = "Your Office", line = "Smoke from the second floor. Your Fixers in their shirtsleeves, carrying out the files.", voice = "narrator" },
		text = "Your Office is on fire. By the time you get there the second floor is gone, and the street is full of your Fixers in their shirtsleeves carrying out what they can: licence frames, files, the kettle. Someone painted a mark on the door before it started. You know whose: Grey Hours, an Office that lost a contract to yours last spring.",
		weight = 3,
		once = true,
		tags = { "fixers", "danger" },
		when = { minAge = 24, office = true },
		choices = {
			{
				label = "Go in for the files",
				clash = check("speed", "A building coming down", 5),
				win = { renown = 3, trigger = "ep_of_2", log = "You came out with the contracts, the ledgers and the Office's licence under one arm, and your eyebrows mostly intact." },
				lose = { health = { -12, -4 }, money = { -500, -250 }, trigger = "ep_of_2", log = "You got half of it. The half you didn't get will take a year of paperwork to rebuild." },
			},
			{ label = "Count your people first", result = { sanity = 2, trigger = "ep_of_2", log = "Everyone was out. You counted twice, then a third time. The files burned. Your Fixers didn't." } },
		},
	},
	{
		id = "ep_of_2",
		episode = "ep_office_fire",
		step = 2,
		title = "Business Is Business",
		text = "Sefa Orun, head of Grey Hours, has sent a note: Business is business. No hard feelings. It's written on Grey Hours letterhead, which is either very stupid or very confident.",
		weight = 0,
		tags = { "fixers" },
		choices = {
			{
				label = "Take it to the Hana Association",
				hint = "Hana arbitrates between Offices.",
				clash = check("charisma", "Hana's arbiters, and Grey Hours' lawyer", 7),
				win = { money = { 800, 1500 }, renown = 8, rep = { fixers = 6 }, episodeEnd = "Hana ruled for you. Grey Hours paid for the new floor and lost its licence for a year.", log = "Hana's arbiters ruled for you. Grey Hours paid for the new second floor, and its licence was suspended for a year." },
				lose = { sanity = -4, episodeEnd = "Hana ruled there wasn't enough proof. Sefa Orun sent flowers.", log = "Hana ruled there wasn't enough proof. The next morning Sefa Orun sent flowers." },
			},
			{
				label = "Answer it the Backstreets way",
				clash = { stat = "strength", foe = "Grey Hours, all of it", enemy = "fixer", fight = true, coins = 3, base = 8, coinPower = 4 },
				win = { renown = 12, rep = { fixers = -4 }, trigger = "ep_of_3", log = "You went to Grey Hours' door with everyone who'd carried files out of the fire. It was over in an evening." },
				lose = { health = { -24, -10 }, money = -800, cause = "A feud between Offices", episodeEnd = "Grey Hours won the feud. Your Office rebuilt, slowly.", log = "Grey Hours was ready for you. Your Office rebuilt, slowly, and you don't walk down their street." },
			},
			{ label = "Rebuild, bigger", requires = { min = { money = 2000 } }, result = { money = -2000, officeSize = 1, renown = 6, episodeEnd = "You rebuilt with three floors instead of two, and hung the burnt door in the new lobby.", log = "You rebuilt with three floors instead of two and hung the burnt door on the lobby wall, where every client can see it." } },
		},
	},
	{
		id = "ep_of_3",
		episode = "ep_office_fire",
		step = 3,
		title = "Terms",
		text = "Sefa Orun comes to what's left of your Office alone, unarmed, with one hand bandaged. \"You've made your point,\" Sefa says. \"Grey Hours would like to discuss terms. Or a merger. Your pick.\"",
		weight = 0,
		tags = { "fixers" },
		choices = {
			{ label = "A merger", result = { officeSize = 1, renown = 6, addRelation = { kind = "friend", name = "Sefa Orun", bond = 40 }, episodeEnd = "Grey Hours is part of your Office now, and Sefa Orun runs its night desk.", log = "Grey Hours moved its desks into your rebuilt floors. Sefa Orun runs the night desk and is very good at it, which is annoying." } },
			{ label = "Terms: they pay for everything", result = { money = { 1500, 2500 }, episodeEnd = "Grey Hours paid for everything, to the last kettle.", log = "Grey Hours paid for everything, to the last kettle. Sefa signed with the bandaged hand." } },
			{ label = "Rivals, then", result = { addRelation = { kind = "rival", name = "Sefa Orun", bond = 20 }, renown = 4, episodeEnd = "You and Sefa Orun are rivals now, properly.", log = "\"Rivals, then,\" Sefa said, and held out the good hand. You shook it. It's been a very productive rivalry." } },
		},
	},

	-- ══ A Debt to the Middle ══════════════════════════════════════════════════
	{
		id = "ep_md_1",
		episode = "ep_middle_debt",
		step = 1,
		title = "Yellow Paint on the Door",
		text = "Someone in your household insulted a Little Brother of the Middle at a noodle counter, loudly, and now there's a mark on your door in the Middle's yellow paint: a debt, owed by the household. The Middle keeps a ledger of every grudge, and pays every one back.",
		weight = 3,
		once = true,
		tags = { "danger", "crime" },
		when = { minAge = 16, side = "backstreets", flags = { "knows_middle" } },
		choices = {
			{ label = "Go and settle it yourself", result = { trigger = "ep_md_2", log = "You found the Little Brother at the same noodle counter. Of course you did." } },
			{ label = "Scrub the paint off", result = { sanity = -2, schedule = { event = "ep_md_2", inYears = 1 }, log = "You scrubbed it off. It was back the next morning, neater." } },
		},
	},
	{
		id = "ep_md_2",
		episode = "ep_middle_debt",
		step = 2,
		title = "Threefold",
		scene = { set = "alley", kicker = "The yard behind the noodle counter", other = { name = "Gennaro, of the Middle", foe = "middle_sibling" }, line = "\"A slight is repaid threefold.\"" },
		text = "The Little Brother is called Gennaro, and is very young and very serious about this. \"A slight is repaid threefold,\" Gennaro recites, as if from a card. \"Three slights, owed by the household. Unless someone stands for the household in the yard, and settles it there.\"",
		weight = 0,
		tags = { "danger", "crime" },
		choices = {
			{
				label = "Stand for the household",
				clash = { stat = "strength", foe = "Gennaro, of the Middle", enemy = "middle_sibling", fight = true, coins = 3, base = 6, coinPower = 3 },
				win = { rep = { middle = 8 }, renown = 4, trigger = "ep_md_3", log = "You stood in the yard and settled it. Gennaro got up, bowed, and painted a neat line through the mark on your door." },
				lose = { health = { -16, -6 }, rep = { middle = 2 }, cause = "A debt to the Middle", episodeEnd = "You stood for your household and lost, and the debt was settled anyway.", log = "You lost. The Middle counted it as settled all the same: you stood, and that was the point." },
			},
			{
				label = "Quote the Middle's own rules back",
				hint = "A slight repaid by a slight. Nobody said what kind.",
				clash = check("intelligence", "A rulebook recited by heart", 6),
				win = { rep = { middle = 4 }, sanity = 3, trigger = "ep_md_3", log = "You argued that your household's three slights could be repaid by three apologies, which are also slights, to the one making them. Gennaro thought about it for a full minute, then agreed." },
				lose = { money = -600, episodeEnd = "Gennaro was not moved, and the household paid.", log = "Gennaro was not moved by your argument. The household paid, threefold, in Ahn." },
			},
			{ label = "Pay threefold", requires = { min = { money = 600 } }, result = { money = -600, rep = { middle = 2 }, episodeEnd = "You paid threefold, and the Middle crossed you out of the ledger.", log = "You paid. Gennaro wrote out a receipt, very formally, and crossed your household out of the ledger." } },
		},
	},
	{
		id = "ep_md_3",
		episode = "ep_middle_debt",
		step = 3,
		title = "A Big Sister Notices",
		text = "A Big Sister of the Middle comes to your door a week later: tall, in the yellow scarf, with a face that has settled a great many debts. \"Gennaro says you stood properly,\" the Big Sister says. \"The Middle remembers people who stand properly, for good or for ill. Today, for good.\"",
		weight = 0,
		tags = { "crime" },
		choices = {
			{ label = "Accept the Middle's good word", result = { rep = { middle = 12 }, setFlags = { "md_good_word" }, episodeEnd = "The Middle remembers you, for good.", log = "From then on, Little Brothers nodded to you in the street. Nobody painted anything on your door again." } },
			{ label = "Ask to be left out of the ledger altogether", result = { sanity = 2, episodeEnd = "You asked the Middle to forget you. It never forgets, but it agreed to pretend.", log = "\"The Middle never forgets,\" the Big Sister said. \"But it can be polite.\"" } },
		},
	},

	-- ══ Someone from Past the Wall ════════════════════════════════════════════
	{
		id = "ep_pw_1",
		episode = "ep_past_the_wall",
		step = 1,
		title = "A Stranger in the Stairwell",
		scene = { set = "stairs", kicker = "Your stairwell", other = { name = "Wren", role = "from past the wall", pose = "sit", age = 22 }, line = "\"Is it always this loud in here?\"" },
		text = "There's someone sleeping in your stairwell who doesn't look like anyone from the City: sunburned in a way the City's light can't do, boots stitched from something that isn't leather, and a small plant in a tin held against their chest. Their name is Wren, and Wren has come over the wall from the Outskirts, with no papers at all.",
		weight = 3,
		once = true,
		tags = { "strange" },
		when = { minAge = 16 },
		choices = {
			{ label = "Take Wren in", result = { trigger = "ep_pw_2", log = "Wren ate everything you put on the table, very fast, and then fell asleep sitting up." } },
			{ label = "Leave food, and leave it there", result = { sanity = 1, episodeEnd = "You left food in the stairwell. In the morning there was a pressed flower where the plate had been.", log = "In the morning the plate was clean and there was a pressed flower on it, a kind you've never seen in the City." } },
			{ label = "Tell the Wing's guards", result = { money = { 80, 160 }, sanity = -4, episodeEnd = "You reported someone without papers. The guards paid the bounty.", log = "The guards came quickly and paid the bounty for someone without papers. You didn't ask where they took Wren." } },
		},
	},
	{
		id = "ep_pw_2",
		episode = "ep_past_the_wall",
		step = 2,
		title = "Papers",
		text = "Without papers, Wren can't work, rent, see a clinic or be found dead in a way anyone has to write down. With papers, Wren is a person. A forger two streets over does good papers for 500 Ahn. A clerk at the District office does real ones for whoever can talk them into it.",
		weight = 0,
		tags = { "strange" },
		choices = {
			{ label = "Pay the forger", requires = { min = { money = 500 } }, result = { money = -500, trigger = "ep_pw_3", log = "The papers were very good. Wren's new name was Wren, which the forger said was the first time anyone had asked to keep their own." } },
			{
				label = "Talk the clerk into real papers",
				clash = check("charisma", "A District office, at closing time", 6),
				win = { trigger = "ep_pw_3", log = "The clerk stamped them, sighed, and said, \"I didn't see where you came from, and I'm not going to.\"" },
				lose = { money = -100, trigger = "ep_pw_3", log = "The clerk refused, then quietly told you which forger was best. It cost less than it would have." },
			},
		},
	},
	{
		id = "ep_pw_3",
		episode = "ep_past_the_wall",
		step = 3,
		title = "What Grows Out There",
		text = "Wren stays a season, works at the noodle row, and learns the City fast. On the last night, Wren tells you what the Outskirts are like: the long winds, the things that hunt, how to find water, how to sleep without sleeping. Then Wren holds out the plant in its tin.",
		weight = 0,
		tags = { "strange" },
		choices = {
			{ label = "Take the plant", result = { gear = "ep_outskirts_sprig", episodeEnd = "Wren went back over the wall. The plant grows on your windowsill, in no light at all.", log = "Wren went back over the wall the next morning. The plant grows on your windowsill, in no light at all, and the room smells of somewhere else." } },
			{ label = "Learn everything Wren knows", result = { health = { 3, 6 }, mind = 2, speed = 1, limitBreak = { speed = 5 }, episodeEnd = "Wren taught you how to live past the wall, and went back to it.", log = "You stayed up all night learning how the Outskirts work. Your body remembers some of it already. Wren left at dawn, waving once." } },
			{ label = "Ask Wren to stay", clash = check("charisma", "Someone who misses the sky", 5), win = { meet = true, sanity = 6, episodeEnd = "Wren stayed in the City, with papers and a job and a friend.", log = "Wren stayed. The plant lives on Wren's windowsill now, two floors down from yours." }, lose = { sanity = 2, gear = "ep_outskirts_sprig", episodeEnd = "Wren went home, and left you the plant.", log = "\"I can't,\" Wren said. \"There's no sky here.\" Wren left the plant on your step." } },
		},
	},

	-- ══ The Hour That Went Missing (District 20) ══════════════════════════════
	{
		id = "ep_bh_1",
		episode = "ep_borrowed_hour",
		step = 1,
		title = "A Receipt in Your Pocket",
		text = "You went to sleep at eleven and woke at eleven, an hour later, standing fully dressed at your own front door with wet shoes. In your coat pocket is a T Corp receipt: TIME LOANED: 1 HOUR. REPAYMENT DUE IN ONE YEAR, WITH INTEREST. You don't remember the hour. You don't remember borrowing it.",
		weight = 3,
		once = true,
		tags = { "strange" },
		when = { minAge = 16, district = "d20" },
		choices = {
			{ label = "Find out what you did with it", result = { trigger = "ep_bh_2", log = "Wet shoes, a receipt, and a smell of rain on a night it didn't rain in District 20. It was a start." } },
			{ label = "Burn the receipt", result = { sanity = -2, schedule = { event = "ep_bh_3", inYears = 1 }, log = "You burned it. The ash smelled of clock oil." } },
		},
	},
	{
		id = "ep_bh_2",
		episode = "ep_borrowed_hour",
		step = 2,
		title = "What You Did With It",
		text = "It takes you a month. A noodle cook saw you running at a quarter past eleven. A clinic nurse remembers a stranger who carried in an old courier hit by a cart and left without giving a name. The courier is alive, and very much wants to thank whoever it was.",
		weight = 0,
		tags = { "strange" },
		choices = {
			{ label = "Tell the courier it was you", result = { sanity = 6, charisma = 1, meet = true, schedule = { event = "ep_bh_3", inYears = 1 }, log = "The courier cried and bought you dinner. You still don't remember it. But it was you." } },
			{ label = "Let it stay a stranger's kindness", result = { sanity = 4, mind = 1, schedule = { event = "ep_bh_3", inYears = 1 }, log = "You left it as a stranger's kindness. It seemed like what the stranger would have wanted." } },
		},
	},
	{
		id = "ep_bh_3",
		episode = "ep_borrowed_hour",
		step = 3,
		title = "Repayment",
		scene = { set = "street", kicker = "District 20", other = { name = "A T Corp collector", foe = "tcorp_collector" }, line = "\"One hour, borrowed. Two hours, owed.\"" },
		text = "On the day, to the minute, a T Corp collector in a grey coat with brass buttons is waiting at your door with a ledger. \"One hour, borrowed,\" the collector says. \"Two hours, owed. Interest. The Corporation accepts repayment in time, or in Ahn at the day's rate.\"",
		weight = 0,
		tags = { "strange" },
		choices = {
			{ label = "Repay in time", hint = "Two hours of your life, gone.", result = { health = { -6, -3 }, sanity = -2, episodeEnd = "You paid T Corp back two hours of your life. You'll never know which two.", log = "The collector touched your wrist with something cold. You'll never know which two hours they took. That's the worst part, and the collector knew it." } },
			{ label = "Repay in Ahn", requires = { min = { money = 600 } }, result = { money = -600, episodeEnd = "You paid for your hour in Ahn, at the day's rate.", log = "The day's rate was outrageous. The collector stamped the receipt PAID and wished you a long and well-managed life." } },
			{
				label = "Dispute the interest",
				clash = check("intelligence", "T Corp's terms and conditions", 7),
				win = { intelligence = 2, episodeEnd = "You found the clause, and T Corp waived the interest.", log = "You found the clause. The collector read it twice, then crossed out the interest with a small, pained line and took back one hour, gently." },
				lose = { health = { -9, -4 }, sanity = -3, episodeEnd = "You disputed it and lost, and T Corp took three hours instead.", log = "You lost the argument, which had a fee. T Corp took three hours instead of two." },
			},
		},
	},

	-- ══ The Streetlight That Follows (the Backstreets at night) ═══════════════
	{
		id = "ep_fl_1",
		episode = "ep_following_light",
		step = 1,
		title = "One Light On",
		text = "Walking home late, you notice that the streetlight above you is always the only one lit. Behind you the street goes dark, lamp by lamp. Ahead of you it's dark too, until you reach the next lamp, and it comes on. It's ten to three. In twenty minutes the Backstreets belong to the Night, and to the Sweepers.",
		weight = 3,
		once = true,
		tags = { "night", "strange", "danger" },
		when = { minAge = 12, side = "backstreets" },
		choices = {
			{ label = "Follow where it lights next", result = { trigger = "ep_fl_2", log = "The next lamp came on to the left, down an alley you'd never take. You took it." } },
			{ label = "Run home", clash = check("speed", "Twenty minutes and a long way", 4), win = { episodeEnd = "You ran home, and the light came with you to your door, and went out.", log = "The light kept up the whole way, and went out the moment your door closed." }, lose = { health = { -8, -3 }, sanity = -4, episodeEnd = "You ran home late, and something in the dark kept pace.", log = "You made it home after three. Something swept past your door all night, very slowly." } },
		},
	},
	{
		id = "ep_fl_2",
		episode = "ep_following_light",
		step = 2,
		title = "Where It Leads",
		scene = { set = "alley", kicker = "Two minutes past three", other = { name = "An old courier", role = "stuck out after hours", age = 64 }, line = "\"The shutter's jammed. Help me, or run.\"" },
		text = "The light leads you to a dead end, where an old courier is trying, very quietly, to get a jammed shutter open with one good arm. It's two minutes past three. Down the street, in the dark, there is a sound like a broom on wet stone, and it's coming closer.",
		weight = 0,
		tags = { "night", "danger" },
		choices = {
			{
				label = "Force the shutter",
				clash = check("strength", "A shutter rusted shut", 5),
				win = { trigger = "ep_fl_3", log = "The shutter gave. You both went through, and pulled it down behind you, as the sound reached the alley mouth." },
				lose = { health = { -10, -4 }, trigger = "ep_fl_3", log = "It took too long. You both went through as something reached the alley mouth, and it touched your coat on the way in." },
			},
			{
				label = "Stand in the light and face the street",
				clash = { stat = "strength", foe = "The Sweepers", enemy = "sweeper", fight = true, coins = 3, base = 7, coinPower = 4 },
				win = { renown = 8, trigger = "ep_fl_3", log = "You stood in the only light on the street and the Sweepers stopped at its edge. Then, one by one, they went back into the dark." },
				lose = { health = { -26, -12 }, cause = "The Night in the Backstreets", trigger = "ep_fl_3", log = "They didn't stop at the light's edge. The courier got the shutter open, and pulled you in." },
			},
		},
	},
	{
		id = "ep_fl_3",
		episode = "ep_following_light",
		step = 3,
		title = "Lamp Glass",
		text = "In the morning the street is clean, the way it always is. The courier is gone, with a thank-you scratched into the shutter. And the streetlight at the end of the alley, the one that lit you there, is broken: a perfect round hole in its glass, and the pieces in a neat pile at its foot.",
		weight = 0,
		tags = { "strange" },
		choices = {
			{ label = "Keep a piece of the glass", result = { gear = "ep_lamp_glass", episodeEnd = "You keep a piece of the streetlight's glass. It's warm at night.", log = "It's warm at night, and on the very worst nights it glows, a little." } },
			{ label = "Leave it be", result = { sanity = 4, luck = 1, episodeEnd = "You left the glass where it lay. The light never followed you again.", log = "The light never followed you again. Some nights you miss it." } },
		},
	},

	-- ══ Thirteen Umbrellas ════════════════════════════════════════════════════
	{
		id = "ep_ru_1",
		episode = "ep_rain_umbrellas",
		step = 1,
		title = "An Umbrella on the Step",
		text = "It's raining, and there's an umbrella on your doorstep: black, steel-ribbed, very good, with a paper tag tied to the handle that says, in old-fashioned handwriting, For when you need it. It rains again on Thursday. There's a second umbrella. By the end of the season there are twelve, lined up in your hall like a guard.",
		weight = 3,
		once = true,
		tags = { "strange" },
		when = { minAge = 14 },
		choices = {
			{ label = "Wait for the thirteenth", result = { trigger = "ep_ru_2", log = "You stopped sleeping on rainy nights. You wanted to see who left them." } },
			{ label = "Give them away to people out in the rain", result = { sanity = 5, charisma = 1, episodeEnd = "You gave twelve good umbrellas away in the rain. The thirteenth never came.", log = "You gave them all away to people caught out in the rain. The thirteenth never came. Maybe that was the point." } },
		},
	},
	{
		id = "ep_ru_2",
		episode = "ep_rain_umbrellas",
		step = 2,
		title = "The Thirteenth",
		scene = { set = "stairs", kicker = "Four in the morning", other = { name = "The umbrella-maker", role = "in a waxed coat", age = 80 }, line = "\"My shop was on this street, before the street was here.\"" },
		text = "The thirteenth comes at four in the morning, carried by an old umbrella-maker in a waxed coat who walks right up your stairs as though invited. Its tag reads Return them all. \"My shop was on this street,\" the umbrella-maker says, \"before the street was here. I've been finishing my orders.\"",
		weight = 0,
		tags = { "strange" },
		choices = {
			{ label = "Ask who the orders were for", result = { mind = 1, trigger = "ep_ru_3", log = "\"Everyone who lived on this street,\" the umbrella-maker said. \"There were thirteen. You're the only one left who'll open the door.\"" } },
			{ label = "Close the door", result = { sanity = -3, episodeEnd = "You closed the door. In the morning all thirteen umbrellas were gone.", log = "You closed the door. In the morning all thirteen umbrellas were gone, and the hall smelled of wax." } },
		},
	},
	{
		id = "ep_ru_3",
		episode = "ep_rain_umbrellas",
		step = 3,
		title = "Return Them All",
		text = "The umbrella-maker waits, dripping, very patient. \"Return them all,\" the tag says. Twelve umbrellas in your hall, and a thirteenth in a pale old hand held out to you.",
		weight = 0,
		tags = { "strange" },
		choices = {
			{ label = "Return all thirteen", result = { sanity = 8, luck = 2, episodeEnd = "You returned all thirteen. The street was quiet afterward, in a good way.", log = "The umbrella-maker took them all, bowed, and walked down your stairs into the rain, and was not there at the bottom. The street has been quiet since, in a good way." } },
			{ label = "Keep the thirteenth", result = { gear = "ep_thirteenth_umbrella", sanity = -2, episodeEnd = "You returned twelve, and kept the thirteenth.", log = "The umbrella-maker looked at you for a long time, then nodded. \"Then it's yours,\" the umbrella-maker said, \"for when you need it.\"" } },
		},
	},
}
