--[[
	The Kurokumo Clan, the Blade Lineage, Rats, small Syndicates, and the Finger Bow-Bell.
	Canon: docs/CANON.md 1.6, 3.7 and 8.6. Kurokumo: protection fees, strict obedience with rare
	exceptions, the feud with the Blade Lineage; the Lineage: Salsu and Mentors, out of S Corp.
	Arc: a Salsu named Ha-eun (fn_met_salsu) -> two years later, lessons -> old_blade_lineage.
]]

local HAEUN_LATER = { event = "fn_blade_mentor", inYears = 2 }

return {
	-- ── the Kurokumo Clan ──
	{
		id = "fn_kurokumo_fee",
		title = "The Clan's Fee",
		text = "Two young men in dark coats patterned like waves, long swords sheathed at their hips, come into the shop at closing time. The Kurokumo Clan's protection fee has gone up again, the third time in three years. Across the road a woman with a plain sword on her back is watching through the window, and she doesn't look like a customer.",
		weight = 11,
		cooldown = 5,
		tags = { "fingers", "crime", "backstreets" },
		when = { minAge = 16, maxAge = 65, side = "backstreets", notFlags = { "fn_kurokumo_member" } },
		codex = "fn_lore_kurokumo",
		choices = {
			{
				label = "Pay the Kurokumo",
				hint = "50 Ahn",
				requires = { min = { money = 50 } },
				result = { money = -50, sanity = -1, log = "You paid. The taller Wakashu counted it twice and bowed exactly as deep as a fee deserves. The woman across the road walked away." },
			},
			{
				label = "Wave the woman over",
				clash = { stat = "strength", foe = "Two Kurokumo Wakashu", coins = 2, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { sanity = 3, setFlags = { "fn_met_salsu" }, schedule = HAEUN_LATER, codex = "fn_lore_blade_lineage", log = "She drew; you grabbed a broom. The Wakashu left with their pride in pieces. The woman bowed and said her name was Ha-eun, a Salsu of the Blade Lineage." },
				lose = { health = { -8, -3 }, money = { -60, -20 }, log = "She was magnificent. You weren't. The Wakashu took double from you for the trouble.", cause = "Cut down in a Kurokumo feud" },
			},
			{
				label = "Pull the shutters down",
				result = { sanity = -3, setFlags = { "fn_kurokumo_grudge" }, log = "You pulled the shutters down in their faces. In the morning someone had carved a small wave into your door." },
			},
		},
	},
	{
		id = "fn_kurokumo_rounds",
		title = "Collection Rounds",
		text = "Collection rounds: twelve shops, twelve envelopes, one Captain waiting at the end of the street to count them. The eleventh shop is a dumpling stall where an old man and his granddaughter are counting coins very slowly, because there aren't enough of them.",
		weight = 24,
		cooldown = 3,
		tags = { "fingers" },
		when = { career = "kurokumo", notFlags = { "fn_kurokumo_captain" } },
		codex = "fn_lore_kurokumo",
		choices = {
			{
				label = "Take what's owed",
				result = { paycheck = 0.3, sanity = -4, setFlags = { "fn_kurokumo_strict" }, log = "You took the envelope, short as it was, and made up the difference with their week's dumplings. The Captain approved. The granddaughter didn't look at you." },
			},
			{
				label = "Cover the difference yourself",
				hint = "40 Ahn",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 3, log = "You slipped your own Ahn into their envelope. The Captain counted twelve full envelopes and nodded. The granddaughter brings you a dumpling every round now." },
			},
			{
				label = "Ask the Captain for an exception",
				clash = { stat = "mind", foe = "Strict obedience", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 2, log = "\"Rare exceptions,\" the Captain said, \"are the Clan's business, not yours.\" Then he made one." },
				lose = { health = { -5, -2 }, sanity = -2, log = "The Captain explained obedience to you behind the stall, briefly and thoroughly." },
			},
		},
	},
	{
		id = "fn_kurokumo_order",
		title = "An Order from Above",
		text = "You're a Captain of the Kurokumo Clan now, with Wakashu of your own. An order comes down: a Blade Lineage swordsman has opened a little practice hall on your streets, and the Clan wants it gone by morning. Your Wakashu are already checking their sword cords. The old feud is older than all of you.",
		weight = 20,
		once = true,
		tags = { "fingers" },
		when = { career = "kurokumo", flags = { "fn_kurokumo_captain" } },
		codex = "fn_lore_blade_lineage",
		choices = {
			{
				label = "Lead the raid on the hall",
				clash = { stat = "strength", foe = "A Salsu in his practice hall", coins = 3, base = 6, coinPower = 3, fight = true, status = "poise" },
				win = { paycheck = 0.5, strength = 2, log = "The hall was empty by morning, as ordered. The swordsman walked out alive, as you made sure. Nobody asked about that part." },
				lose = { health = { -9, -3 }, sanity = -3, log = "The Salsu held his hall against your whole squad, then left it anyway, bowing. Your Wakashu talk about it in whispers.", cause = "Cut down in a Kurokumo feud" },
			},
			{
				label = "Warn the swordsman first",
				result = { sanity = 3, setFlags = { "fn_kurokumo_mercy" }, log = "You sent him a note. By midnight the hall was empty. The Clan got what it asked for, and nobody had to draw." },
			},
			{
				label = "Refuse the order",
				clash = { stat = "mind", foe = "The Clan's patience", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = 4, log = "You told your superior the Clan's honor didn't need one small practice hall. He let it go, a rare exception. He'll remember it." },
				lose = { quitCareer = true, sanity = -5, setFlags = { "fn_kurokumo_grudge" }, log = "Refusing was not one of the rare exceptions. You were struck from the Clan's ledgers by dawn, and your sword cord was cut in front of your Wakashu." },
			},
		},
	},
	{
		id = "fn_kurokumo_retire",
		title = "Laying Down the Blade",
		text = "Your sword feels heavier every winter, and the Wakashu you trained are Captains now. The Clan has a quiet custom for members who last this long, which is rare: you hand your blade to a Captain at the shrine, bow, and walk out of the Clan's ledgers with nothing owed either way.",
		weight = 25,
		cooldown = 4,
		tags = { "fingers" },
		when = { career = "kurokumo", minAge = 56 },
		choices = {
			{
				label = "Hand over the blade",
				result = { quitCareer = true, sanity = 5, wage = { 120, 240 }, setFlags = { "fn_kurokumo_retired" }, log = "You handed your blade to a Captain you'd once carried home after a feud. He bowed lower than he had to. You walked home lighter by exactly one sword." },
			},
			{
				label = "Keep the blade a while longer",
				result = { paycheck = 0.4, health = -2, log = "You kept your blade. The young ones give you the easy streets now, and pretend it's an honor." },
			},
		},
	},

	-- ── the Blade Lineage ──
	{
		id = "fn_salsu_bridge",
		title = "A Salsu on the Bridge",
		text = "A swordsman in a worn coat sits cross-legged in the middle of the footbridge, sword across his knees, and asks every passerby the same thing: \"A bout? Just to first touch.\" Most people take the long way around. He seems happy either way. His grip on the sword is the Blade Lineage's, people say.",
		weight = 6,
		once = true,
		tags = { "fingers" },
		when = { minAge = 16, maxAge = 60 },
		codex = "fn_lore_blade_lineage",
		choices = {
			{
				label = "Accept the bout",
				clash = { stat = "strength", foe = "A wandering Salsu", coins = 2, base = 5, coinPower = 3, fight = true, status = "poise" },
				win = { strength = 2, setFlags = { "fn_met_salsu" }, schedule = HAEUN_LATER, log = "You touched his sleeve first, somehow. He laughed like a bell. \"There's a woman you should meet,\" he said, and wrote down a name: Ha-eun." },
				lose = { health = { -5, -2 }, sanity = 1, log = "He touched your collar before you'd finished drawing. He apologized, and showed you what you'd done wrong. It was everything." },
			},
			{
				label = "Sit down and talk with him",
				result = { charisma = 2, sanity = 2, log = "He told you about S Corp's Court, and the masters who walked out of it, and a feud with a Clan in dark coats. Then he asked about you, and listened." },
			},
			{
				label = "Take the long way around",
				result = { sanity = -1, intelligence = 1, log = "You took the long way. From the next bridge you could see him, still sitting, still smiling, waiting for somebody braver." },
			},
		},
	},
	{
		id = "fn_blade_mentor",
		title = "The Lineage",
		text = "Ha-eun the Salsu finds you two years later, thinner, with a new scar and the same easy smile. The Blade Lineage barely exists any more, she says: a few masters, a few students, a way of holding a sword. Her own Mentor came out of S Corp's Court. \"I could teach you,\" she says. \"It doesn't pay. It never pays.\"",
		weight = 0,
		when = { flags = { "fn_met_salsu" }, minAge = 14 },
		codex = "fn_lore_blade_lineage",
		choices = {
			{
				label = "Learn the sword from her",
				clash = { stat = "strength", foe = "A Salsu's patience", coins = 2, base = 5, coinPower = 3 },
				win = { addTrait = "old_blade_lineage", strength = 2, log = "She taught you to wait, and then to move once. A year later you could cut a falling leaf without thinking. She said that was the first lesson." },
				lose = { strength = 1, health = -3, log = "You learned enough to know how much you didn't know. She said that was the first lesson, too, and left you a practice sword." },
			},
			{
				label = "Ask about the feud",
				result = { mind = 2, codex = "fn_lore_kurokumo", log = "\"Old,\" she said. \"Older than me. They remember every day of it. So do we.\" She showed you how to tell a Kurokumo sword cord from across a street." },
			},
			{
				label = "Thank her, and decline",
				result = { sanity = 2, log = "She shrugged, bought you both a bowl of noodles, and was gone before you'd finished yours. She left the bill paid." },
			},
		},
	},

	-- ── Rats ──
	{
		id = "fn_rat_toll",
		title = "The Toll",
		text = "Three Rats have started standing at the corner on your way to school. They call it a toll: five Ahn, or your lunch, or your shoes. They're older than you, but not by much, and one of them used to live on your street before his family lost their room. He won't look you in the eye.",
		weight = 14,
		cooldown = 3,
		tags = { "danger", "backstreets" },
		when = { minAge = 10, maxAge = 17, side = "backstreets" },
		codex = "fn_lore_rats",
		choices = {
			{
				label = "Pay the toll",
				hint = "5 Ahn",
				requires = { min = { money = 5 } },
				result = { money = -5, sanity = -2, log = "You paid. They let you through. It was the most expensive five Ahn you ever spent, and you spent it every day for a month." },
			},
			{
				label = "Fight your way past",
				clash = { stat = "strength", foe = "Three Rats on a corner", coins = 2, base = 3, coinPower = 2, fight = true },
				win = { strength = 2, sanity = 2, log = "You put the biggest one on the pavement and kept walking. The toll was over, for you." },
				lose = { health = { -5, -2 }, sanity = -2, log = "They took your lunch, your coins and your left shoe. You walked to school lopsided." },
			},
			{
				label = "Talk to the one from your street",
				clash = { stat = "charisma", foe = "A boy who's ashamed", coins = 2, base = 3, coinPower = 2 },
				win = { sanity = 3, log = "You asked after his little sister, by name. He let you pass, and the next day he wasn't on the corner any more." },
				lose = { sanity = -2, log = "He shoved you and said he didn't know you. He said it too loudly to mean it." },
			},
			{
				label = "Take the long way",
				result = { intelligence = 1, health = -1, log = "The long way added twenty minutes and a bridge. You learned the name of every shop on it." },
			},
		},
	},
	{
		id = "fn_rat_pack",
		title = "Rats at Closing Time",
		text = "A pack of Rats has been hitting shops on your street at closing time, five or six of them with pipes and borrowed knives. Tonight they walk into the place where you're buying dinner. The owner freezes behind the counter. The Rats look at you, decide you're a customer, and start with your wallet.",
		weight = 10,
		cooldown = 5,
		tags = { "danger", "backstreets" },
		when = { minAge = 16, maxAge = 62, side = "backstreets" },
		codex = "fn_lore_rats",
		choices = {
			{
				label = "Fight them",
				clash = { stat = "strength", foe = "A pack of Rats", coins = 2, base = 4, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = 2, sanity = 2, wage = { 10, 30 }, log = "You put the first Rat through a stack of chairs, and the rest remembered urgent business elsewhere. The owner fed you free for a month." },
				lose = { health = { -7, -2 }, money = { -40, -10 }, log = "There were more of them than you'd counted. They took your wallet and the till.", cause = "Mugged by Rats" },
			},
			{
				label = "Hand over the wallet",
				result = { money = { -40, -15 }, sanity = -2, log = "You handed it over. They took the Ahn and threw the wallet back, which was almost polite, for Rats." },
			},
			{
				label = "Bluff that you're a Fixer",
				requires = { notFlags = { "licensed_fixer" } },
				clash = { stat = "charisma", foe = "Rats who can read a bluff", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, log = "\"Grade 6, Hinge Office,\" you said. The Rats looked at each other and left. The owner asked for your card. You don't have one." },
				lose = { health = { -6, -2 }, money = { -40, -20 }, log = "\"Show us the license,\" said the smallest Rat. You couldn't." },
			},
			{
				label = "Show them your license",
				requires = { flags = { "licensed_fixer" } },
				result = { sanity = 2, strength = 1, log = "You put your Fixer's license on the counter without a word. The Rats remembered they had places to be. The owner refused to let you pay." },
			},
		},
	},

	-- ── small Syndicates ──
	{
		id = "fn_small_gang",
		title = "With the Thumb's Permission",
		text = "A new Syndicate called the Copper Kites has painted kites on every lamppost on your street. Their Gangleader, a nineteen-year-old with a copper earring, goes door to door announcing new fees, and that the Kites hold this street with the Thumb's permission. You remember her from the academy. She was very good at sums.",
		weight = 9,
		once = true,
		tags = { "fingers", "crime", "backstreets" },
		when = { minAge = 18, side = "backstreets" },
		codex = "fn_lore_syndicates",
		choices = {
			{
				label = "Pay the Kites",
				hint = "30 Ahn",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = -1, log = "You paid. The Gangleader wrote you a receipt with a little kite drawn on it, which was more than the Thumb ever did." },
			},
			{
				label = "Ask to see the Thumb's permission",
				clash = { stat = "mind", foe = "A Gangleader's bluff", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, setFlags = { "fn_kites_bluff_called" }, log = "She didn't have it. By the end of the month the Thumb had heard, and the kites on the lampposts were painted over." },
				lose = { sanity = -3, money = -20, log = "She had it: a single page with a Capo's stamp. She let you read it twice, then raised your fee for the trouble." },
			},
			{
				label = "Offer to do the Kites' books",
				result = { wage = { 30, 60 }, intelligence = 1, setFlags = { "fn_kites_books" }, log = "You did their sums. They were terrible at sums. The Gangleader paid in Ahn, and in a promise that your door would never be touched." },
			},
		},
	},
	{
		id = "fn_bow_bell_week",
		title = "The Quiet Week",
		text = "For one week every Finger in the District is on its best behavior. The Thumb's Soldati walk without their pistols. The Middle's Siblings keep their Books closed. Even the Index's Messengers look nervous. A Soldato buying noodles tells you, beaming, that it's the week of the Finger Bow-Bell. He says it the way children say holiday.",
		weight = 5,
		once = true,
		tags = { "fingers" },
		when = { minAge = 14 },
		codex = "fn_lore_bow_bell",
		choices = {
			{
				label = "Enjoy the quiet",
				result = { sanity = 5, log = "You walked home after midnight for the first time in your life, well before three. Nothing happened. It was the strangest, sweetest week the District ever had." },
			},
			{
				label = "Keep your stall open late",
				result = { wage = { 40, 90 }, log = "You kept your stall open late every night that week. Every Finger in the District came to buy noodles, very politely." },
			},
			{
				label = "Try to find the summit",
				clash = { stat = "mind", foe = "Five Fingers' discretion", coins = 3, base = 6, coinPower = 3 },
				win = { mind = 3, sanity = -3, log = "You found the building: five cars outside, five drivers who wouldn't look at each other. You left before anyone noticed you. You hope." },
				lose = { sanity = -5, health = { -4, -1 }, log = "A quiet person you never saw stepped out of a doorway and walked you, very gently, back to your own street. You never saw their face." },
			},
		},
	},
}
