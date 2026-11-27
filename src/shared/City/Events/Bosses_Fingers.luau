--[[
	BIG BOSSES (v0.15, b15_ ids): fights in phases, against the people who run the City's
	streets. Each starts with an approach card (a way out is always offered: pay, talk, kneel,
	run); fighting through the boss's people triggers the second card, the boss itself, at once
	(`trigger`). The boss fights are not `fixed`: the older and better-known you are, the harder
	they hit. Losing a boss fight is often fatal.

	Bosses are this game's own people with canon ranks:
	  the Thumb       Soldati, a Capo (rounds burn), the Sottocapo above the Capi
	  the Middle      Little Siblings, a Big Brother who reads the Book (rupture)
	  the Index       Proselytes, a Proxy carrying out a Prescript to the letter
	  the Ring        Students, a Docent who wants you in the exhibition (bleed)
	  the Kurokumo    Wakashu, a Captain of the Clan (bleed)
	  R Corp          a Rabbit team, then the Rhino, in a Wing operation (tremor)
	  Distortions     the Bellringer and the Hostess, after the Light (library era on)
	Winning drops a unique piece (Gear/Bosses15.luau) and records a chronicle act that other
	players on the server hear about (Events/Bosses_Echoes.luau).
]]

local BOSS = { "boss", "danger" }

local function crew(foe: string, enemy: string, stat: string?, status: any?)
	return { stat = stat or "strength", foe = foe, enemy = enemy, fight = true, coins = 3, base = 6, coinPower = 3, status = status }
end
local function boss(foe: string, enemy: string, status: any?)
	return { stat = "strength", foe = foe, enemy = enemy, fight = true, coins = 3, base = 8, coinPower = 5, status = status, boss = true }
end

return {
	-- ════ THE THUMB: a Capo's collection ═══════════════════════════════════════
	{
		id = "b15_thumb_collection",
		title = "Contribution Day",
		text = "Capo Aurelio Brandimarte of the Thumb has taken your street under his protection. Three Soldati go door to door collecting the contribution, in order of rank, bowing at each threshold. Yours is the next door.",
		weight = 4,
		cooldown = 12,
		tags = BOSS,
		when = { minAge = 20, side = "backstreets", notFlags = { "fn_thumb_member", "b15_slew_brandimarte" } },
		codex = "fn_lore_thumb_ranks",
		scene = { set = "street", time = "night", title = "Contribution Day", line = "The Capo's protection is a privilege. Privileges are paid for. In full, with gratitude.", other = { name = "Soldato Terzo of the Thumb", foe = "thumb_soldato" } },
		choices = {
			{
				label = "Refuse, and fight the Soldati",
				hint = "A hard fight, and then the Capo himself.",
				clash = crew("Three Soldati of the Thumb", "thumb_soldato", "strength", { id = "burn", potency = 1 }),
				win = { strength = 2, rep = { thumb = -12 }, trigger = "b15_thumb_capo", log = "The third Soldato went down still bowing. Then a car door opened at the end of the street." },
				lose = { health = { -22, -12 }, condition = "burns", rep = { thumb = -4 }, cause = "Refused the Thumb's contribution", log = "Propellant rounds don't miss twice. They took the contribution from your pockets, politely." },
			},
			{ label = "Pay the contribution", hint = "200 Ahn, with gratitude.", requires = { min = { money = 200 } }, result = { money = -200, rep = { thumb = 3 }, sanity = -2, log = "You paid in both hands, with a bow. The Soldato thanked you for your gratitude." } },
			{
				label = "Recite the Capo's titles",
				hint = "Mental Strength check. Every honorific, in order.",
				clash = { stat = "mind", foe = "Thumb etiquette", coins = 3, base = 6, coinPower = 3 },
				win = { mind = 2, rep = { thumb = 4 }, log = "Every title, every honorific. The Soldato was so moved he halved the contribution." },
				lose = { health = { -12, -6 }, money = -100, condition = "broken_arm", log = "One title out of order. The correction was physical, and the contribution doubled." },
			},
			{ label = "Kneel and plead", result = { sanity = -6, money = -60, log = "You knelt on the stones. They took what was in your pockets and told the street you'd knelt." } },
		},
	},
	{
		id = "b15_thumb_capo",
		title = "Capo Brandimarte",
		text = "Capo Aurelio Brandimarte steps out of the car, fastens his gloves and looks at his Soldati on the ground, and then at you, with something close to respect. He loads three propellant rounds, one at a time.",
		weight = 0,
		tags = BOSS,
		scene = { set = "street", time = "night", title = "Capo Brandimarte", kicker = "The Thumb", line = "You have no manners. But you have something. Kneel, and I will remember it kindly.", other = { name = "Capo Aurelio Brandimarte", foe = "thumb_capo" } },
		choices = {
			{
				label = "Fight the Capo", battle = "capo_brandimarte",
				hint = "A boss of the Thumb. His rounds burn.",
				clash = boss("Capo Aurelio Brandimarte", "thumb_capo", { id = "burn", potency = 3 }),
				win = { strength = 4, gear = "b15_brandimarte_revolver", rep = { thumb = -30 }, setFlags = { "b15_slew_brandimarte", "bl_trophy", "ec_killed_a_capo" }, chronicle = "killed_a_capo", log = "He knelt at last, by the rules of his own family, and offered his revolver with both hands. The Thumb will never forget your face." },
				lose = { health = { -40, -24 }, condition = "burns", cause = "Shot by Capo Brandimarte of the Thumb", log = "Three rounds, three shots. He stepped over you and straightened his gloves." },
			},
			{ label = "Kneel now", result = { sanity = -8, money = -300, rep = { thumb = -6 }, log = "You knelt. He took three hundred Ahn and a promise, and his Soldati carried each other to the car." } },
			{
				label = "Run",
				hint = "Speed check, against propellant rounds.",
				clash = { stat = "speed", foe = "A Capo's aim", coins = 3, base = 7, coinPower = 3 },
				win = { speed = 2, rep = { thumb = -8 }, log = "You were round the corner before the second round. The third hit the wall where your head had been." },
				lose = { health = { -26, -14 }, condition = "burns", cause = "Shot running from a Capo of the Thumb", log = "You were quick. Propellant is quicker." },
			},
		},
	},
	{
		id = "b15_thumb_sottocapo",
		title = "The Sottocapo",
		text = "A Capo of the Thumb is dead and his name was on your hands. Sottocapo Lucrezia Ferrante, who runs every Capo in this part of the City, has come herself. She doesn't bring Soldati. She doesn't need them.",
		weight = 6,
		cooldown = 30,
		once = true,
		tags = BOSS,
		when = { minAge = 22, flags = { "b15_slew_brandimarte" }, notFlags = { "b15_slew_ferrante" } },
		scene = { set = "alley", time = "night", title = "The Sottocapo", kicker = "The Thumb", line = "Brandimarte was a fool, but he was our fool. Etiquette demands an answer. I am the answer.", other = { name = "Sottocapo Lucrezia Ferrante", foe = "thumb_capo" } },
		choices = {
			{
				label = "Fight the Sottocapo", battle = "sottocapo_ferrante",
				hint = "One of the strongest people on these streets.",
				clash = { stat = "strength", foe = "Sottocapo Lucrezia Ferrante", enemy = "thumb_capo", fight = true, coins = 4, base = 9, coinPower = 5, status = { id = "burn", potency = 4 }, boss = true },
				win = { strength = 5, speed = 2, gear = "b15_ferrante_greatsword", rep = { thumb = -20 }, setFlags = { "b15_slew_ferrante", "bl_trophy" }, chronicle = "b15_act_sottocapo", limitBreak = { strength = 5 }, log = "She lowered her blade and bowed, exactly as deep as the Manual says for a superior. Then she gave it to you, and walked away from the Thumb." },
				lose = { health = { -60, -36 }, cause = "Answered for a Capo, to the Sottocapo of the Thumb", log = "It was over in four movements. She bowed over you, correctly." },
			},
			{
				label = "Offer a formal apology",
				hint = "Charisma check, by the Thumb's own Manual.",
				clash = { stat = "charisma", foe = "The Thumb Introductory Manual, page 1,402", coins = 4, base = 8, coinPower = 3 },
				win = { charisma = 3, rep = { thumb = 10 }, setFlags = { "b15_slew_ferrante" }, log = "A formal apology, to the page and the comma. She accepted it. \"The debt is settled,\" she said, \"and so are you.\"" },
				lose = { health = { -30, -18 }, condition = "burns", cause = "Apologized incorrectly to the Thumb", log = "Page 1,402 has a footnote. You missed it." },
			},
			{ label = "Leave the District", result = { money = -400, sanity = -6, rep = { thumb = -4 }, log = "You left that night with one bag. The Thumb has long memories and short reach, mostly." } },
		},
	},

	-- ════ THE MIDDLE: a Big Brother reads the Book ═════════════════════════════
	{
		id = "b15_middle_vengeance",
		title = "Your Name in the Book",
		text = "Somebody you knew wronged a Sibling of the Middle, and you stood next to them once. That's enough. Four Little Siblings wait at the end of your street with chains, smiling like family.",
		weight = 4,
		cooldown = 12,
		tags = BOSS,
		when = { minAge = 20, side = "backstreets", notFlags = { "fn_middle_member", "b15_slew_ugo" } },
		codex = "fn_lore_book",
		scene = { set = "alley", time = "night", title = "Your Name in the Book", line = "Title 3, Section 4, Row F. You're a Line now, sibling. Don't take it personally.", other = { name = "A Little Sister of the Middle", foe = "middle_sibling" } },
		choices = {
			{
				label = "Fight the Siblings",
				hint = "A hard fight, and then a Big Brother.",
				clash = crew("Four Little Siblings of the Middle", "middle_sibling", "strength", { id = "rupture", potency = 1 }),
				win = { strength = 2, rep = { middle = -12 }, trigger = "b15_middle_big", log = "The fourth Sibling went down laughing. Behind them, a very large man was closing a very large book." },
				lose = { health = { -22, -12 }, condition = "broken_ribs", rep = { middle = -4 }, cause = "Settled a Line for the Middle", log = "Chains, and laughter, and then the Line was paid." },
			},
			{
				label = "Argue the Book",
				hint = "Intelligence check. Find a Title that clears you.",
				clash = { stat = "intelligence", foe = "The Middle's law", coins = 3, base = 6, coinPower = 3 },
				win = { intelligence = 2, rep = { middle = 4 }, log = "Title 6, Section 1: a bystander owes nothing. They checked twice, touched the page to their foreheads, and left." },
				lose = { health = { -14, -8 }, log = "Wrong Title. The Siblings explained the right one, at length, with chains." },
			},
			{ label = "Pay the Line", requires = { min = { money = 180 } }, result = { money = -180, rep = { middle = 2 }, log = "The Middle always pays its debts, in whichever form. You paid yours in Ahn, and they wrote it down." } },
		},
	},
	{
		id = "b15_middle_big",
		title = "Big Brother Ugo",
		text = "Big Brother Ugo hands the Book to a Little Sister, cracks his knuckles, and wraps his chain twice round his fist. He looks sad about it. \"You hurt my little ones,\" he says. \"That's a new Line.\"",
		weight = 0,
		tags = BOSS,
		scene = { set = "alley", time = "night", title = "Big Brother Ugo", kicker = "The Middle", line = "Title 1, Section 1, Row A. The oldest Line there is. Somebody hurt family.", other = { name = "Big Brother Ugo", foe = "middle_big" } },
		choices = {
			{
				label = "Fight Big Brother Ugo", battle = "big_brother_ugo",
				hint = "A boss of the Middle. Every blow he lands makes the next worse.",
				clash = boss("Big Brother Ugo", "middle_big", { id = "rupture", potency = 3 }),
				win = { strength = 4, gear = "b15_ugo_chain", rep = { middle = -25 }, setFlags = { "b15_slew_ugo", "bl_trophy" }, chronicle = "b15_act_big_brother", log = "He went down to one knee and laughed, and unwound the chain, and gave it to you. \"Title 1 for you, sibling. The whole family will know your name.\"" },
				lose = { health = { -40, -24 }, condition = "broken_ribs", cause = "Settled by Big Brother Ugo of the Middle", log = "He was gentle about it, for the Middle. He checked the Book before he stopped." },
			},
			{ label = "Ask to join the family", requires = { minAge = 18 }, result = { rep = { middle = 6 }, sanity = -4, setFlags = { "fn_middle_grudge" }, log = "He stared, then hugged you so hard your ribs creaked. \"Little Sibling! Then the Line is family business.\"" } },
			{
				label = "Run",
				hint = "Speed check. The Middle never forgets a face.",
				clash = { stat = "speed", foe = "A family that never forgets", coins = 3, base = 7, coinPower = 3 },
				win = { speed = 2, rep = { middle = -10 }, log = "You got away. Your face is in the Book now, drawn by a Little Sister, very well." },
				lose = { health = { -24, -14 }, cause = "Caught running from the Middle", log = "The Middle has a lot of family, and all of them were on the next street." },
			},
		},
	},

	-- ════ THE INDEX: a Proxy's Prescript ═══════════════════════════════════════
	{
		id = "b15_index_prescript",
		title = "Written",
		text = "Three Proselytes of the Index stand in your doorway in white, reading from a slip. The Prescript says: at the seventh hour, the one who opens this door is to be taken to the Proxy. You opened the door.",
		weight = 4,
		cooldown = 12,
		tags = BOSS,
		when = { minAge = 20, notFlags = { "fn_index_member", "b15_slew_sereno" } },
		codex = "fn_lore_index",
		scene = { set = "stairs", time = "night", title = "Written", line = "It is not personal. It is written. Nothing written is personal.", other = { name = "A Proselyte of the Index", foe = "index_proselyte" } },
		choices = {
			{
				label = "Fight the Proselytes",
				hint = "A hard fight, and then the Proxy.",
				clash = crew("Three Proselytes of the Index", "index_proselyte", "strength", { id = "bleed", potency = 1 }),
				win = { strength = 2, rep = { index = -12 }, trigger = "b15_index_proxy", log = "The last Proselyte fell and read the slip again from the floor, puzzled. Then the Proxy came up the stairs." },
				lose = { health = { -22, -12 }, rep = { index = -4 }, cause = "Taken as the Prescript said", log = "They took you to the Proxy, exactly as written. The Proxy let you go, exactly as written. It took a week." },
			},
			{
				label = "Shut the door before the hour",
				hint = "Speed check. The Prescript said the seventh hour.",
				clash = { stat = "speed", foe = "A clock", coins = 3, base = 6, coinPower = 3 },
				win = { speed = 2, log = "You shut it at six minutes to. At the hour they read the slip, looked at the closed door, and left, satisfied." },
				lose = { health = { -12, -6 }, log = "A minute late. They were very apologetic about it, in their way." },
			},
			{
				label = "Read the slip yourself",
				hint = "Intelligence check. Prescripts are exact.",
				clash = { stat = "intelligence", foe = "A Prescript's wording", coins = 3, base = 6, coinPower = 3 },
				win = { intelligence = 2, rep = { index = 3 }, log = "\"The one who opens this door.\" You hadn't. The wind had. They conferred, and agreed, and bowed." },
				lose = { sanity = -4, health = { -10, -5 }, log = "The wording was exact. So were they." },
			},
		},
	},
	{
		id = "b15_index_proxy",
		title = "Proxy Sereno",
		text = "Proxy Sereno of the Index climbs your stairs reading his own Prescript, a long one, folded many times. He doesn't look up. \"Step nine,\" he reads. \"The one who was to be taken resists. Step ten: so does the Proxy.\"",
		weight = 0,
		tags = BOSS,
		scene = { set = "stairs", time = "night", title = "Proxy Sereno", kicker = "The Index", line = "Step ten. I have never once failed a step. I would rather not start with you.", other = { name = "Proxy Sereno", foe = "index_proxy" } },
		choices = {
			{
				label = "Fight the Proxy", battle = "proxy_sereno",
				hint = "A boss of the Index. Every cut opens wider.",
				clash = boss("Proxy Sereno", "index_proxy", { id = "bleed", potency = 3 }),
				win = { strength = 3, speed = 2, gear = "b15_sereno_slip", rep = { index = -25 }, setFlags = { "b15_slew_sereno", "bl_trophy" }, chronicle = "b15_act_prescript", log = "He stopped at step eleven, which had never happened, and looked at the slip for a long time. Then he gave it to you. \"It was wrong,\" he said, wonderingly." },
				lose = { health = { -40, -24 }, condition = "deep_cut", cause = "Cut down at step ten of a Prescript", log = "Step ten, step eleven, step twelve. He completed them all, and folded the slip, and left." },
			},
			{
				label = "Ask what step twelve says",
				hint = "Charisma check. Proxies love their slips.",
				clash = { stat = "charisma", foe = "A Proxy's devotion", coins = 3, base = 7, coinPower = 3 },
				win = { charisma = 3, rep = { index = 6 }, setFlags = { "b15_slew_sereno" }, log = "\"Step twelve: the Proxy explains step twelve.\" He did, for an hour. At the end the Prescript was complete, and so was he." },
				lose = { health = { -28, -16 }, condition = "deep_cut", cause = "Interrupted a Proxy of the Index", log = "Step twelve said not to be interrupted." },
			},
			{ label = "Go with him", result = { sanity = -10, health = { -10, -4 }, rep = { index = 4 }, log = "You went where the Prescript said, for a week. You remember very little, and all of it in order." } },
		},
	},

	-- ════ THE RING: a Docent's exhibition ══════════════════════════════════════
	{
		id = "b15_ring_exhibition",
		title = "An Invitation to the Exhibition",
		text = "A card on your pillow, in beautiful handwriting: Docent Amadeo of the Ring requests the honour of your presence, as a piece. Two of his Students are already in your kitchen, sketching you.",
		weight = 4,
		cooldown = 12,
		tags = BOSS,
		when = { minAge = 20, notFlags = { "fn_ring_member", "b15_slew_amadeo" } },
		codex = "fn_lore_ring",
		scene = { set = "room", time = "night", title = "An Invitation", line = "Hold still. The light on your face right now is perfect. It won't last. Nothing does. That's the point.", other = { name = "A Student of the Ring", foe = "ring_artist" } },
		choices = {
			{
				label = "Fight the Students",
				hint = "A hard fight, and then the Docent.",
				clash = crew("Two Students of the Ring", "ring_artist", "strength", { id = "bleed", potency = 1 }),
				win = { strength = 2, rep = { ring = -12 }, trigger = "b15_ring_docent", log = "The Students went down still sketching. Then someone applauded slowly from your doorway." },
				lose = { health = { -22, -12 }, condition = "deep_cut", rep = { ring = -4 }, cause = "Sketched by the Ring", log = "They finished the sketch. It's very good. You'll carry the marks of it." },
			},
			{
				label = "Criticize their technique",
				hint = "Intelligence check. Artists can't stand it.",
				clash = { stat = "intelligence", foe = "Two touchy artists", coins = 3, base = 6, coinPower = 3 },
				win = { intelligence = 2, rep = { ring = 3 }, log = "\"The proportions are timid.\" They argued with each other for an hour, and left to start again." },
				lose = { health = { -14, -8 }, log = "They took the criticism very personally, with brushes." },
			},
			{ label = "Climb out the window", result = { speed = 1, sanity = -4, log = "Three floors down a drainpipe. When you came back the kitchen was painted, beautifully, all over." } },
		},
	},
	{
		id = "b15_ring_docent",
		title = "Docent Amadeo",
		text = "Docent Amadeo of the Ring is wearing an apron spotted with every colour, and holding a brush as long as a sword. He walks around you twice, appraising. \"You're wasted as a person,\" he says warmly. \"Let me show you what you could be.\"",
		weight = 0,
		tags = BOSS,
		scene = { set = "room", time = "night", title = "Docent Amadeo", kicker = "The Ring", line = "Art is what's left when you take away everything that isn't. Let's take away everything.", other = { name = "Docent Amadeo", foe = "ring_docent" } },
		choices = {
			{
				label = "Fight the Docent", battle = "docent_amadeo",
				hint = "A boss of the Ring. His cuts don't close.",
				clash = boss("Docent Amadeo", "ring_docent", { id = "bleed", potency = 3 }),
				win = { strength = 3, mind = 2, gear = "b15_amadeo_palette", rep = { ring = -25 }, setFlags = { "b15_slew_amadeo", "bl_trophy" }, chronicle = "b15_act_exhibition", log = "He sat down on your floor and looked at you with real delight. \"Unfinished,\" he said. \"The best pieces always are.\" He left you his palette." },
				lose = { health = { -40, -24 }, condition = "deep_cut", cause = "Made into a piece by a Docent of the Ring", log = "He was an artist. He took his time. He signed his work." },
			},
			{
				label = "Offer to model, on your terms",
				hint = "Charisma check. He'll want to negotiate.",
				clash = { stat = "charisma", foe = "A Docent's ego", coins = 3, base = 7, coinPower = 3 },
				win = { charisma = 3, rep = { ring = 6 }, setFlags = { "b15_slew_amadeo" }, log = "You sat for a portrait, in paint only, for six hours. It hangs in a gallery now. You look tired in it." },
				lose = { health = { -26, -14 }, sanity = -6, log = "He agreed to your terms, and then improved them." },
			},
			{ label = "Burn his brushes", result = { sanity = -4, rep = { ring = -10 }, health = { -10, -4 }, log = "You threw them in the stove. He screamed like you'd killed someone, and left weeping. He'll be back with better ones." } },
		},
	},

	-- ════ THE KUROKUMO CLAN: a Captain's duel ══════════════════════════════════
	{
		id = "b15_kurokumo_wakashu",
		title = "The Clan's Toll",
		text = "The Kurokumo Clan has taken the street with the tea houses. Four Wakashu in black coats stand at the corner with their hands on their hilts, waiting for anyone who walks past without lowering their eyes.",
		weight = 4,
		cooldown = 12,
		tags = BOSS,
		when = { minAge = 20, side = "backstreets", notFlags = { "fn_kurokumo_member", "b15_slew_sayo" } },
		codex = "fn_lore_kurokumo",
		scene = { set = "street", time = "night", title = "The Clan's Toll", line = "Eyes down, or draw. Those are the two ways to walk this street.", other = { name = "A Wakashu of the Kurokumo Clan", foe = "kurokumo" } },
		choices = {
			{
				label = "Meet their eyes",
				hint = "A hard fight, and then their Captain.",
				clash = crew("Four Kurokumo Wakashu", "kurokumo", "speed", { id = "bleed", potency = 1 }),
				win = { speed = 2, rep = { kurokumo = -12 }, trigger = "b15_kurokumo_captain", log = "The last Wakashu sheathed his blade before he fell, out of habit. Somewhere above you, a door slid open." },
				lose = { health = { -22, -12 }, condition = "deep_cut", rep = { kurokumo = -4 }, cause = "Met the Kurokumo's eyes", log = "They were faster. They usually are. They let you live, to teach the street." },
			},
			{ label = "Lower your eyes", result = { sanity = -3, rep = { kurokumo = 2 }, log = "You lowered your eyes and walked on. Behind you, one of them laughed, quietly." } },
			{
				label = "Bow, correctly",
				hint = "Mental Strength check. The Clan notices form.",
				clash = { stat = "mind", foe = "The Clan's eye for form", coins = 3, base = 6, coinPower = 3 },
				win = { mind = 2, rep = { kurokumo = 5 }, log = "A correct bow, held correctly. The Wakashu bowed back, a fraction, which they never do." },
				lose = { health = { -12, -6 }, log = "Too shallow. They corrected you with the flat of a blade." },
			},
		},
	},
	{
		id = "b15_kurokumo_captain",
		title = "Captain Sayo",
		text = "Captain Sayo of the Kurokumo Clan comes down from the tea house balcony without hurrying, her coat on her shoulders, her blade still sheathed. She looks at her Wakashu, then at you. \"You've ruined my evening. Draw.\"",
		weight = 0,
		tags = BOSS,
		scene = { set = "street", time = "night", title = "Captain Sayo", kicker = "The Kurokumo Clan", line = "One draw. If you're still standing when I sheathe it, the street is yours tonight.", other = { name = "Captain Sayo", foe = "kurokumo" } },
		choices = {
			{
				label = "Draw against the Captain", battle = "captain_sayo",
				hint = "A boss of the Clan. One draw decides it.",
				clash = { stat = "speed", foe = "Captain Sayo", enemy = "kurokumo", fight = true, coins = 3, base = 8, coinPower = 5, status = { id = "bleed", potency = 3 }, boss = true },
				win = { speed = 4, strength = 1, gear = "b15_sayo_blade", rep = { kurokumo = -25 }, setFlags = { "b15_slew_sayo", "bl_trophy" }, chronicle = "b15_act_kurokumo", log = "You were still standing when she sheathed it. She looked at the cut on her own sleeve for a long moment, and then gave you the blade, sheath and all." },
				lose = { health = { -42, -26 }, condition = "deep_cut", cause = "Drew against a Captain of the Kurokumo Clan", log = "You never saw her draw. You saw her sheathe it." },
			},
			{ label = "Refuse to draw", result = { sanity = -6, rep = { kurokumo = -6 }, health = { -10, -4 }, log = "She looked at you with complete contempt and walked back up to her tea. That was worse than the blade." } },
			{
				label = "Challenge her to wait",
				hint = "Mental Strength check. Who moves first loses.",
				clash = { stat = "mind", foe = "A Captain's patience", coins = 4, base = 8, coinPower = 3 },
				win = { mind = 4, rep = { kurokumo = 8 }, setFlags = { "b15_slew_sayo" }, log = "Neither of you moved for an hour. At dawn she laughed, the only time anyone has heard it, and bought you tea." },
				lose = { health = { -30, -18 }, cause = "Lost a waiting duel with the Kurokumo", log = "You blinked. That was enough." },
			},
		},
	},

	-- ════ R CORP: a Wing operation ═════════════════════════════════════════════
	{
		id = "b15_rcorp_operation",
		title = "Inside the Operation Zone",
		text = "R Corp has declared your block an operation zone. A Rabbit team is sweeping it street by street, and anyone still inside when they reach a door is counted as hostile. You're still inside.",
		weight = 3,
		cooldown = 14,
		tags = BOSS,
		when = { minAge = 20, notFlags = { "b15_slew_rhino" } },
		scene = { set = "street", time = "night", title = "Operation Zone", line = "Zone is hot. Civilians are hostiles. Clear it.", other = { name = "An R Corp Rabbit", foe = "rcorp_rabbit" } },
		choices = {
			{
				label = "Fight your way out",
				hint = "A hard fight, and then whatever they send next.",
				clash = crew("An R Corp Rabbit team", "rcorp_rabbit", "speed", { id = "rupture", potency = 1 }),
				win = { speed = 2, rep = { wings = -10 }, trigger = "b15_rcorp_rhino", log = "The Rabbits fell back in good order, calling it in. The ground began to shake." },
				lose = { health = { -24, -14 }, cause = "Counted as a hostile in an R Corp operation", log = "Rabbits are quick. You were counted, and processed, and left in the road." },
			},
			{
				label = "Hide until they pass",
				hint = "Luck check.",
				clash = { stat = "luck", foe = "A thorough sweep", coins = 3, base = 6, coinPower = 3 },
				win = { luck = 2, log = "In a chimney, for nine hours. They swept every room but that one." },
				lose = { health = { -18, -10 }, cause = "Found hiding in an R Corp operation zone", log = "They found you on the second pass. They're very thorough." },
			},
			{ label = "Surrender with your hands up", result = { sanity = -8, health = { -8, -4 }, money = -100, log = "They processed you, fined you, and let you go three days later with a number written on your hand." } },
		},
	},
	{
		id = "b15_rcorp_rhino",
		title = "The Rhino",
		text = "The Rhino comes round the corner on foot, which is worse than anything with wheels: an R Corp soldier in armour the size of a shop front, a hammer on its back, a team callsign painted on its chest. It lowers its head.",
		weight = 0,
		tags = BOSS,
		scene = { set = "street", time = "night", title = "The Rhino", kicker = "R Corp", line = "Hostile confirmed. Rhino engaging.", other = { name = "The Rhino", foe = "rcorp_rhino" } },
		choices = {
			{
				label = "Fight the Rhino", battle = "rcorp_rhino",
				hint = "A boss of R Corp. Every hit shakes you apart.",
				clash = boss("The Rhino", "rcorp_rhino", { id = "tremor", potency = 3 }),
				win = { strength = 4, gear = "b15_rhino_plate", rep = { wings = -20 }, setFlags = { "b15_slew_rhino", "bl_trophy" }, chronicle = "b15_act_rhino", log = "It went down like a building and lay there, armour ticking as it cooled. The team pulled out. They left a plate of its armour in the road." },
				lose = { health = { -44, -28 }, condition = "broken_ribs", cause = "Charged down by R Corp's Rhino", log = "It didn't swing the hammer. It didn't need to." },
			},
			{
				label = "Lead it into a building",
				hint = "Intelligence check. It's heavy.",
				clash = { stat = "intelligence", foe = "A very heavy soldier", coins = 3, base = 7, coinPower = 3 },
				win = { intelligence = 3, rep = { wings = -8 }, log = "Through a shop, onto a floor that couldn't hold it. It went into the cellar, and stayed." },
				lose = { health = { -30, -18 }, cause = "Cornered by R Corp's Rhino", log = "The floor held. You'd been sure it wouldn't." },
			},
			{ label = "Lie flat and wait", result = { sanity = -10, luck = 1, log = "It walked past you, a foot from your head, and on down the street. You lay there until dawn." } },
		},
	},

	-- ════ DISTORTIONS: the Bellringer and the Hostess (after the Light) ══════════
	{
		id = "b15_bellringer_peal",
		title = "The Peal",
		text = "Every bell on your block rang at once at noon: shop bells, bicycle bells, the school bell. Now they ring every hour, and each time they do, someone on the block forgets the last thing they said. The ringing is coming from the old tram tower.",
		weight = 4,
		cooldown = 14,
		tags = BOSS,
		when = { minAge = 18, world = { era = { "library", "limbus" } }, notFlags = { "b15_slew_bellringer" } },
		codex = "lib_first_distortions",
		choices = {
			{
				label = "Climb the tower",
				hint = "A hard fight with what rings for it, and then the Bellringer.",
				clash = crew("Peals that took a shape", "peccatula", "mind", { id = "tremor", potency = 1 }),
				win = { mind = 2, sanity = -4, trigger = "b15_bellringer", log = "You fought your way up a stair of ringing. At the top, something was pulling ropes that weren't there." },
				lose = { health = { -20, -10 }, sanity = -10, cause = "Climbed the Bellringer's tower", log = "Halfway up, the bells rang, and you forgot why you'd come, and fell." },
			},
			{ label = "Stuff your ears and leave", result = { sanity = -6, money = -40, log = "Wax in your ears and a bag on your back. Behind you the whole block was standing in the street, saying nothing at all." } },
			{
				label = "Fetch an Office",
				hint = "Charisma check. Distortion contracts are expensive.",
				clash = { stat = "charisma", foe = "Offices that don't want this job", coins = 3, base = 6, coinPower = 3 },
				win = { charisma = 2, rep = { fixers = 3 }, log = "An Office went up the tower at dusk. The bells stopped at midnight. Two Fixers came down." },
				lose = { sanity = -5, log = "Nobody would take it. The bells rang all week." },
			},
		},
	},
	{
		id = "b15_bellringer",
		title = "The Bellringer",
		when = { world = { era = { "library", "limbus" } } },
		text = "It was a bell-founder once. Now it is a tower inside the tower: a body hung with bells, each one shaped like a mouth that has just finished a word. It turns toward you, and every bell begins to swing.",
		weight = 0,
		tags = BOSS,
		scene = { set = "facility", time = "night", title = "The Bellringer", kicker = "A Distortion", line = "Say something. Anything. I'll keep it for you. I keep all of them.", other = { name = "The Bellringer", creature = { shape = "lamp", color = { 150, 120, 60 }, eye = { 250, 230, 160 }, seed = "bellringer", name = "The Bellringer" } } },
		choices = {
			{
				label = "Fight the Bellringer", battle = "the_bellringer",
				hint = "A Distortion. Every peal shakes you apart.",
				clash = { stat = "strength", foe = "The Bellringer", enemy = "distortion", fight = true, coins = 3, base = 8, coinPower = 5, status = { id = "tremor", potency = 3 }, boss = true },
				win = { strength = 3, mind = 3, sanity = -6, gear = "b15_bell_clapper", setFlags = { "b15_slew_bellringer", "bl_trophy", "dz_distortion_survivor" }, chronicle = "b15_act_bellringer", log = "The last bell cracked. For a moment there was a person there, kneeling, very tired, and then only bells. The block remembered everything at once." },
				lose = { health = { -40, -24 }, sanity = -12, cause = "Rung silent by the Bellringer", log = "The bells rang. You forgot how to stand, and then how to breathe." },
			},
			{
				label = "Say its name",
				hint = "Mental Strength check. If anyone remembers it.",
				clash = { stat = "mind", foe = "What's left of a bell-founder", coins = 4, base = 8, coinPower = 3 },
				win = { mind = 4, sanity = -4, setFlags = { "b15_slew_bellringer", "dz_distortion_survivor" }, chronicle = "b15_act_bellringer", log = "You'd found it on an old shop sign: Benedek Hale, Bells. You said it. Every bell went still, and so did it." },
				lose = { sanity = -16, health = { -20, -10 }, cause = "Spoke to the Bellringer", log = "It took the name from your mouth before you finished it, and kept it." },
			},
			{ label = "Cut the ropes and run", result = { speed = 1, sanity = -8, health = { -12, -6 }, log = "You cut what ropes you could reach and ran. The bells rang slower all week, and then started again." } },
		},
	},
	{
		id = "b15_hostess_party",
		title = "The Invitation on the Door",
		text = "An invitation is pinned to every door in the building: a party, tonight, top floor, everyone welcome. Nobody on the top floor has been seen for a month. Music is already playing. Your neighbours are going up, dressed in their best, smiling.",
		weight = 4,
		cooldown = 14,
		tags = BOSS,
		when = { minAge = 18, world = { era = { "library", "limbus" } }, notFlags = { "b15_slew_hostess" } },
		choices = {
			{
				label = "Go up and stop it",
				hint = "A hard fight with the guests, and then the Hostess.",
				clash = crew("Guests who can't stop dancing", "puppet", "strength", { id = "sinking", potency = 1 }),
				win = { strength = 2, sanity = -4, trigger = "b15_hostess", log = "You cut the guests' strings one by one; they sat down where they were and slept. At the end of the room, the Hostess stopped the music." },
				lose = { health = { -18, -10 }, sanity = -10, cause = "Danced at the Hostess's party", log = "Someone took your hand for a dance, and you couldn't let go for a very long time." },
			},
			{
				label = "Keep your neighbours downstairs",
				hint = "Charisma check. They want to go.",
				clash = { stat = "charisma", foe = "Neighbours who want to dance", coins = 3, base = 6, coinPower = 3 },
				win = { charisma = 2, sanity = -2, log = "You kept six of them in your flat all night playing cards. Upstairs the music played until dawn, and then stopped, sulking." },
				lose = { sanity = -8, log = "They went up anyway, laughing. The music got louder." },
			},
			{ label = "Burn the invitations", result = { sanity = -3, log = "You burned every invitation in the building. In the morning they were back, re-addressed, with your name on top." } },
		},
	},
	{
		id = "b15_hostess",
		title = "The Hostess",
		when = { world = { era = { "library", "limbus" } } },
		text = "The Hostess was a woman who threw the best parties on the street, once, and was so afraid of them ending. Now she is tall and pale and smiling, strung from the ceiling like a chandelier, and every guest is a puppet on one of her threads. \"You're early,\" she says. \"Nobody's ever early.\"",
		weight = 0,
		tags = BOSS,
		scene = { set = "hall", time = "night", title = "The Hostess", kicker = "A Distortion", line = "Stay. Everyone stays. The party never has to end now.", other = { name = "The Hostess", creature = { shape = "doll", color = { 230, 220, 230 }, eye = { 240, 90, 120 }, seed = "hostess", name = "The Hostess" } } },
		choices = {
			{
				label = "Fight the Hostess", battle = "the_hostess",
				hint = "A Distortion. Her threads drag you under.",
				clash = { stat = "strength", foe = "The Hostess", enemy = "distortion", fight = true, coins = 3, base = 8, coinPower = 5, status = { id = "sinking", potency = 3 }, boss = true },
				win = { strength = 3, mind = 2, sanity = -6, gear = "b15_hostess_ribbon", setFlags = { "b15_slew_hostess", "bl_trophy", "dz_distortion_survivor" }, chronicle = "b15_act_hostess", log = "The threads went slack all at once. The guests woke up on the floor, yawning, asking what time it was. She was gone. A ribbon was left on the chandelier hook." },
				lose = { health = { -38, -24 }, sanity = -14, cause = "Kept forever at the Hostess's party", log = "A thread found your wrist. Then another. The music was lovely. It never stopped." },
			},
			{
				label = "Tell her the party's over",
				hint = "Mental Strength check. She knows. She's afraid.",
				clash = { stat = "mind", foe = "A fear the size of a ballroom", coins = 4, base = 8, coinPower = 3 },
				win = { mind = 4, sanity = -3, setFlags = { "b15_slew_hostess", "dz_distortion_survivor" }, chronicle = "b15_act_hostess", log = "\"It was a lovely party,\" you said. \"Everyone had a wonderful time. It's time to go home.\" She cried, and let go of every thread." },
				lose = { sanity = -16, health = { -18, -10 }, cause = "Told the Hostess the party was over", log = "\"It's never over,\" she said, and turned up the music." },
			},
			{ label = "Dance, and look for the door", result = { speed = 1, sanity = -10, log = "Three dances, two doors that weren't, and then a real one. You fell down the stairs into morning." } },
		},
	},
}
