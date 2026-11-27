--[[
	Danger and horror (dz_): the Fingers at their worst. Violence stays offscreen: the Thumb
	"corrects", the Middle "settles", the Ring makes mannequins, the Index's Prescripts are
	ambiguous rather than orders to harm.
	Chains:
		dz_f_prescript -> (1 year) dz_f_proxies          ignore a Prescript and the Index comes
		dz_f_exhibition -> dz_f_exhibition_locked / (2 years) dz_f_commission
		dz_f_middle_tea, dz_f_thumb_interest             for lives that crossed the Middle or owe the Thumb
]]

return {
	-- ── the Index ──
	{
		id = "dz_f_prescript",
		title = "A Prescript With Your Name",
		text = "A slip under your door, in the Index's careful hand: \"Prescript: at 2:40 tonight, bring {friend} to the old laundry on Ninth. Do not tell them why.\" You don't know why either.",
		weight = 2,
		once = true,
		tags = { "danger" },
		when = { minAge = 16, hasRelation = "friend" },
		codex = "fn_lore_index",
		choices = {
			{ label = "Obey the Prescript", result = { sanity = -12, killRelation = "friend", addTrait = "index_marked", log = "Your friend walked into the laundry at 2:40, laughing at a joke you'd told. The Messenger thanked you and closed the door." } },
			{
				label = "Warn them and run",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Index Proxies", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = -4, money = -60, log = "You both slept in another District for a month, and the Index seemed to lose interest. Seemed to." },
				lose = { health = { -18, -8 }, killRelation = "friend", log = "They were waiting at the station. You got away; your friend didn't.", cause = "Ran from the Index" },
			},
			{ label = "Burn the slip", result = { sanity = -3, schedule = { event = "dz_f_proxies", inYears = 1 }, log = "You burned it in the sink and told no one. Nothing happened, for a while." } },
		},
	},
	{
		id = "dz_f_proxies",
		title = "Two Proxies",
		text = "Two Index Proxies are waiting on your stairs in pale coats, perfectly polite. \"You did not come,\" says the taller. \"The Prescript must still be fulfilled.\"",
		weight = 0,
		when = { minAge = 16 },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Fight them",
				clash = { stat = "strength", foe = "Two Index Proxies", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "poise", potency = 2 } },
				win = { strength = 3, sanity = -4, setFlags = { "dz_unsurvivable" }, log = "You won. They bowed, both of them, and left a fresh slip on your step: \"Prescript: forget this.\"" },
				lose = { die = "Fulfilled a Prescript, one way or another", log = "The Prescript was fulfilled." },
			},
			{
				label = "Ask what it says now",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The Index's patience", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -6, mind = 3, log = "The taller one unfolded a new slip: \"Prescript: let this one go.\" They left without another word." },
				lose = { health = { -16, -8 }, condition = "dz_maimed", log = "They explained the Prescript to you, carefully, at length.", cause = "Corrected by the Index" },
			},
			{ label = "Run, and keep running", result = { sanity = -8, condition = "dz_hunted", money = { -120, -40 }, log = "You left the District with what you could carry. Pale coats turned up at your new building twice that year." } },
		},
	},

	-- ── the Ring ──
	{
		id = "dz_f_exhibition",
		title = "A Private Exhibition",
		text = "A gilded card invites you to a Ring exhibition in the old cannery. Two hundred mannequins all face the door. One is wearing your neighbor's coat, and your neighbor has been missing a week.",
		weight = 2,
		once = true,
		tags = { "danger" },
		when = { minAge = 16 },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "Leave before the doors lock",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A Docent's attention", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -5, chronicle = "dz_act_ring_escape", log = "You smiled at the Docent and strolled out. The doors locked behind you, and you heard them." },
				lose = { sanity = -4, trigger = "dz_f_exhibition_locked", log = "You turned for the door. It was already closing." },
			},
			{ label = "Look closer at the coat", result = { sanity = -10, setFlags = { "dz_ring_noticed" }, schedule = { event = "dz_f_commission", inYears = 2 }, log = "The mannequin's face was smooth and blank and very carefully made. The Docent noticed you noticing, and wrote something down." } },
			{
				label = "Praise the work",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A Docent who knows flattery", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { money = 150, sanity = -4, log = "You talked about composition until the Docent glowed. She gave you a signed sketch, which sold for 150 Ahn and gave the buyer nightmares." },
				lose = { sanity = -6, setFlags = { "dz_ring_noticed" }, schedule = { event = "dz_f_commission", inYears = 2 }, log = "\"You have a good eye,\" she said. \"And a good face.\"" },
			},
		},
	},
	{
		id = "dz_f_exhibition_locked",
		title = "The Doors Lock",
		text = "The cannery doors lock with a sound like a held breath. The lights go red. All two hundred mannequins have turned, very slightly, to face you.",
		weight = 0,
		when = { minAge = 16 },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "Break a window",
				hint = "Health check.",
				clash = { stat = "health", foe = "Reinforced glass", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -6, chronicle = "dz_act_ring_escape", log = "Third try. You went out through the glass and ran until the cannery was a light behind you." },
				lose = { health = { -18, -8 }, condition = "deep_cut", log = "The glass held. The Students didn't hurry.", cause = "Did not leave the exhibition" },
			},
			{
				label = "Stand still among them",
				hint = "Mental Strength check. Very bad odds.",
				clash = { stat = "mind", foe = "Two hundred mannequins", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -14, setFlags = { "dz_unsurvivable" }, addTrait = "dz_dread_calm", chronicle = "dz_act_ring_escape", log = "You stood like one of them until dawn while the Students walked past you nine times. When the cleaners came, you walked out with them." },
				lose = { die = "Became part of a Ring exhibition", log = "You stood very still. It was exactly what they wanted." },
			},
			{
				label = "Fight your way out",
				clash = { stat = "strength", foe = "Ring Students", coins = 3, base = 8, coinPower = 4, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 3, chronicle = "dz_act_ring_escape", log = "You went through three Students and a Fauvist installation to reach the loading door." },
				lose = { health = { -22, -10 }, log = "There were more Students than mannequins.", cause = "Fought the Ring in its own gallery" },
			},
			{ label = "Hide behind the coat racks", result = { sanity = -12, condition = "dz_terror", loseGear = "coat", log = "You hid behind the coat racks until the cleaners came at dawn. Your own coat is in the exhibition now." } },
		},
	},
	{
		id = "dz_f_commission",
		title = "A Commission",
		text = "A Ring Docent is at your door with a sketchbook. \"I'm making a piece called Patience,\" she says. \"You'd be perfect. I'll only need to watch you for a year.\"",
		weight = 0,
		when = { minAge = 16, flags = { "dz_ring_noticed" } },
		codex = "fn_lore_ring",
		choices = {
			{ label = "Agree, and be watched", result = { sanity = -16, money = 300, condition = "dz_hunted", clearFlags = { "dz_ring_noticed" }, log = "She watched you for a year: eating, sleeping, crying once. The piece won a prize, and she sent you the money and a sketch of it, which you burned." } },
			{
				label = "Refuse her",
				clash = { stat = "strength", foe = "A Docent and her Students", coins = 3, base = 7, coinPower = 4, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 2, sanity = -4, clearFlags = { "dz_ring_noticed" }, log = "Her Students came that night, and you were waiting. She sent a note: \"A shame; you'd have been my best work.\"" },
				lose = { health = { -22, -10 }, log = "Her Students came that night.", cause = "Refused a Ring commission" },
			},
			{ label = "Leave the District", hint = "150 Ahn.", requires = { min = { money = 150 } }, result = { money = -150, sanity = -6, clearFlags = { "dz_ring_noticed" }, log = "You took the WARP train that night with one bag. Some days you still check crowds for a sketchbook." } },
		},
	},
	{
		id = "dz_f_doll",
		title = "A Doll With Your Face",
		text = "There's a doll on your doorstep in a little coat like yours. Its face is your face, painted very carefully.",
		weight = 3,
		once = true,
		when = { minAge = 8, maxAge = 12 },
		codex = "fn_lore_ring",
		choices = {
			{ label = "Burn it", result = { sanity = -3, log = "You burned it in the yard. It took a long time to catch." } },
			{ label = "Keep it", result = { sanity = -5, setFlags = { "dz_ring_noticed" }, schedule = { event = "dz_f_commission", inYears = 12 }, log = "You kept it on your shelf, facing the wall. Some mornings it was facing the room." } },
			{ label = "Show a grown-up", result = { sanity = -1, log = "The grown-ups went very quiet and moved the whole family across the District that week." } },
		},
	},

	-- ── the Thumb ──
	{
		id = "dz_f_thumb_discipline",
		title = "Discipline",
		text = "Round the corner, a Thumb Capo is disciplining a Soldato for a missed bow. The Capo stops, and looks up at you. You weren't supposed to see this.",
		weight = 2,
		once = true,
		tags = { "danger", "crime" },
		when = { minAge = 14, side = "backstreets" },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Bow, low and long",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A Capo's sense of propriety", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { charisma = 2, sanity = -3, log = "You held the bow until your back ached. \"Rare manners, these days,\" said the Capo, and waved you on." },
				lose = { health = { -14, -6 }, condition = "broken_arm", sanity = -4, log = "Not low enough. The Capo corrected your posture himself.", cause = "Didn't bow low enough to a Capo" },
			},
			{
				label = "Run",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Thumb pistols", coins = 3, base = 7, coinPower = 3 },
				win = { sanity = -4, condition = "dz_hunted", log = "You were round two corners before the first shot. The Thumb asked after you on your street for a month." },
				lose = { health = { -20, -8 }, log = "The Thumb's people are famous for their guns. Now you know why.", cause = "Ran from the Thumb" },
			},
			{
				label = "Offer to pay his fine",
				hint = "120 Ahn.",
				requires = { min = { money = 120 } },
				result = { money = -120, sanity = -2, addRelation = { kind = "friend", name = "Soldato Pietro", bond = 50, age = { 18, 26 } }, log = "You asked, very respectfully, to pay the boy's fine, and the Capo laughed and took it. The Soldato never forgot." },
			},
			{ label = "Kneel on the cobbles", result = { sanity = -8, log = "You knelt with your eyes down until he had finished. He stepped round you on the way out, which was the point." } },
		},
	},
	{
		id = "dz_f_thumb_interest",
		title = "The Interest",
		text = "A Thumb Soldato in a pressed suit opens a ledger. \"Your debt has been accruing interest, which is only proper.\" Two more Soldati are already standing in your room.",
		weight = 8,
		once = true,
		tags = { "danger", "crime" },
		when = { minAge = 16, flags = { "fn_owes_thumb" } },
		codex = "fingers_thumb",
		choices = {
			{ label = "Pay what you can", requires = { min = { money = 1 } }, result = { money = { -250, -100 }, sanity = -3, log = "You paid everything you had and a little you didn't. The Soldato thanked you for your courtesy." } },
			{
				label = "Ask for time, properly",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Thumb etiquette", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { mind = 2, log = "You used every honorific you knew, in the right order, and he granted you a season. From the Thumb, that is a gift." },
				lose = { health = { -16, -8 }, condition = "broken_arm", log = "You used the wrong honorific. The interest was collected in another form.", cause = "Corrected by the Thumb over a debt" },
			},
			{
				label = "Refuse to pay",
				hint = "Mental Strength check. Very bad odds.",
				clash = { stat = "mind", foe = "The Thumb's sense of propriety", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -10, setFlags = { "dz_unsurvivable" }, log = "You refused so courteously, in such perfect form, that the Soldato bowed and left to consult his Capo. He never came back." },
				lose = { die = "Refused the Thumb its interest", log = "You told them no. The Thumb is very polite about the word no, once." },
			},
		},
	},

	-- ── the Middle ──
	{
		id = "dz_f_middle_block",
		title = "The Whole Block",
		text = "A shopkeeper on your block laughed at a Middle Little Brother's haircut. By morning the whole block is written in the Book of Vengeance, your door included.",
		weight = 2,
		once = true,
		tags = { "danger", "crime" },
		when = { minAge = 16, side = "backstreets" },
		codex = "fn_lore_book",
		choices = {
			{ label = "Leave before they come", hint = "100 Ahn.", requires = { min = { money = 100 } }, result = { money = -100, sanity = -4, log = "You were across the District by dusk. When you went back for your things, the block was very quiet and very tidy." } },
			{
				label = "Hide in the cellar",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The Middle's thoroughness", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -8, log = "You heard them go door to door above you, polite and thorough. They missed the cellar, which they don't usually." },
				lose = { health = { -18, -8 }, condition = "in_the_book", log = "They found the cellar. A Big Sister read your name aloud from the Book before they began.", cause = "Paid the Middle's debt for someone else" },
			},
			{
				label = "Beg the Big Sister",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A Big Sister of the Middle", coins = 3, base = 7, coinPower = 3, fixed = true },
				win = { sanity = -2, charisma = 2, log = "You knelt in the street and apologized for a man you'd never spoken to. She struck your name out with one line: \"The Middle remembers manners too.\"" },
				lose = { sanity = -6, condition = "in_the_book", log = "She listened politely, then wrote your name a second time." },
			},
		},
	},
	{
		id = "dz_f_middle_tea",
		title = "Tea in Your Kitchen",
		text = "A Little Sister of the Middle is sitting in your kitchen when you get home. She's made tea in your pot. \"Big Brother sends his regards,\" she says. \"He remembers.\"",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { minAge = 16, flags = { "fn_middle_grudge" } },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Sit and hear her terms",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The Middle's terms", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { money = { -300, -150 }, sanity = -4, log = "The terms were a great deal of money and an apology in writing. You paid, and it isn't over; it's paused." },
				lose = { health = { -20, -8 }, sanity = -6, log = "You said one wrong word. She finished her tea first.", cause = "Settled with the Middle over tea" },
			},
			{
				label = "Go out the window",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "Little Brothers on the stairs", coins = 3, base = 7, coinPower = 3 },
				win = { sanity = -6, condition = "dz_hunted", log = "Two floors down a drainpipe and gone. They'll be back; the Middle always comes back." },
				lose = { health = { -20, -8 }, log = "Her Little Brothers were waiting at the bottom of the drainpipe.", cause = "Ran from the Middle" },
			},
			{
				label = "Draw on her",
				clash = { stat = "strength", foe = "A Little Sister of the Middle", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 3, condition = "in_the_book", log = "She left limping, and your name is underlined twice now." },
				lose = { die = "Drew on the Middle in your own kitchen", log = "She was faster. The tea was still warm." },
			},
		},
	},
}
