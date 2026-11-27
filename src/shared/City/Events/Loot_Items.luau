--[[
	Named gear with a temper, books that teach, and the shop that sells them (bl_ ids).
	  - the Overpass Stacks: two shelves (Activities/Loot.luau triggers them). Which book is
	    for sale follows this year's streets: quiet, tense or turf war.
	  - item events: unique gear that wants something, or that someone wants back
	  - book finds: odd places a book that teaches turns up
	  - group events with a linked friend (another player): bounties and named terrors
]]

local UNIQUE_TOOLS = {
	"bl_verdict", "bl_courtesy", "bl_black_cloud", "bl_prescript", "bl_grudgebearer", "bl_lullaby",
	"bl_penance", "bl_stormgut", "bl_hoofbeat", "bl_pointille", "bl_snuffer",
	-- Ironsong re-tunes are one of a kind too
	"bl_tuned_quake", "bl_tuned_spear", "bl_tuned_knives", "bl_tuned_pyrojade", "bl_tuned_censer",
	"bl_tuned_katana", "bl_tuned_capacitor",
}

return {
	-- ── the Overpass Stacks ──
	{
		id = "bl_shop_front_table",
		title = "The Front Table",
		text = "Hollis's front table: drill cards, field notes and paper slips tied with string. He taps one book. \"That one's real,\" he says. \"This year, anyway.\"",
		weight = 0,
		codex = "bl_lore_overpass",
		choices = {
			{
				label = "Buy the spent Prescripts",
				hint = "220 Ahn. Stocked when the streets are quiet.",
				requires = { world = { streets = "quiet" }, noBook = "bl_book_prescripts", noTrait = "bl_ab_obedient_hands", min = { money = 220 } },
				result = { money = -220, book = "bl_book_prescripts", log = "You bought two hundred spent Prescripts tied with string. Hollis swore every one was carried out." },
			},
			{
				label = "Buy the Soldato's drill card",
				hint = "220 Ahn. Stocked when the streets are tense.",
				requires = { world = { streets = "tense" }, noBook = "bl_book_soldato_drill", noTrait = "bl_ab_propellant", min = { money = 220 } },
				result = { money = -220, book = "bl_book_soldato_drill", log = "You bought a Thumb drill card. Hollis asked you not to say where you got it, with real feeling." },
			},
			{
				label = "Buy the book of grudges",
				hint = "220 Ahn. Stocked when there's a turf war.",
				requires = { world = { streets = "turf_war" }, noBook = "bl_book_small_grudges", noTrait = "bl_ab_never_forget", min = { money = 220 } },
				result = { money = -220, book = "bl_book_small_grudges", log = "You bought a Middle sibling's pocket book of grudges. Hollis wouldn't say how he came by it." },
			},
			{
				label = "Read standing up",
				result = { intelligence = 1, sanity = 1, log = "You read a chapter standing up until Hollis coughed. Free knowledge, a little of it." },
			},
		},
	},
	{
		id = "bl_shop_back_room",
		title = "The Back Room",
		text = "Behind the curtain, Hollis keeps the real stock in a locked glass case. \"Not cheap,\" he says. \"Nothing that teaches is.\"",
		weight = 0,
		codex = "bl_lore_overpass",
		choices = {
			{
				label = "Buy the Docent's sketchbook",
				hint = "650 Ahn. On the shelf in quiet years.",
				requires = { world = { streets = "quiet" }, noBook = "bl_book_docent_sketches", noTrait = "bl_ab_critics_eye", min = { money = 650 } },
				result = { money = -650, book = "bl_book_docent_sketches", log = "You bought a Ring Docent's sketchbook. Forty studies of one face, each a little less like it." },
			},
			{
				label = "Buy the Wu gait scroll",
				hint = "650 Ahn. On the shelf in tense years.",
				requires = { world = { streets = "tense" }, noBook = "bl_book_wu_scroll", noTrait = "bl_ab_wu_gait", min = { money = 650 } },
				result = { money = -650, book = "bl_book_wu_scroll", log = "You bought a Heishou pack master's gait scroll. Half of it is about breathing." },
			},
			{
				label = "Buy the Kurokumo draw scroll",
				hint = "650 Ahn. On the shelf in turf wars.",
				requires = { world = { streets = "turf_war" }, noBook = "bl_book_kurokumo_scroll", noTrait = "bl_ab_cloud_draw", min = { money = 650 } },
				result = { money = -650, book = "bl_book_kurokumo_scroll", log = "You bought a Kurokumo scroll. One cut, brushed a thousand times. Hollis wrapped it in newspaper and looked at the door." },
			},
			{
				label = "Ask about downstairs",
				result = { sanity = -1, setFlags = { "bl_heard_binder" }, log = "\"The Binder's down there,\" Hollis said, and wouldn't say more. Then he did: \"The very best books. Bring a crew, or bring a will.\"" },
			},
		},
	},

	-- ── named gear with a temper ──
	{
		id = "bl_item_courtesy_tea",
		title = "Tea with Capo Vittore",
		text = "A Soldato delivers an invitation on a silver tray: Capo Vittore would like to take tea with the person who beat Tullio. It isn't the kind of invitation you decline.",
		weight = 8,
		once = true,
		when = { hasGear = "bl_courtesy", minAge = 18 },
		choices = {
			{
				label = "Go, and mind your manners",
				hint = "Mental Strength check. Thumb etiquette, start to finish.",
				clash = { stat = "mind", foe = "A Capo's tea table", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = 2, book = "bl_book_soldato_drill", log = "You used every honorific correctly, twice. The Capo laughed, said Tullio was getting slow, and gave you the Thumb's drill card." },
				lose = { loseGear = "bl_courtesy", sanity = -4, log = "You picked up the wrong cup. The Capo smiled very kindly and asked for Courtesy back." },
			},
			{
				label = "Return Courtesy with a bow",
				result = { loseGear = "bl_courtesy", wage = { 200, 350 }, sanity = 2, log = "You returned the revolver with both hands. The Capo paid you for your manners, which is rarer than paying for a gun." },
			},
			{
				label = "Don't go",
				result = { loseGear = "bl_courtesy", health = { -14, -8 }, cause = "Declined the Thumb's tea", log = "You didn't go. Tullio came instead, with two friends, to collect Courtesy and an apology." },
			},
		},
	},
	{
		id = "bl_item_cloud_wakashu",
		title = "Wakashu at the Corner",
		text = "Two Kurokumo Wakashu have stood at the end of your street for a week. Today they bow. \"Captain Seiran's blade,\" says the younger. \"We have been told to ask.\"",
		weight = 8,
		cooldown = 6,
		when = { hasGear = "bl_black_cloud" },
		choices = {
			{
				label = "Answer with the blade",
				hint = "A real fight. Two of them.",
				clash = { stat = "strength", foe = "Two Kurokumo Wakashu", coins = 3, base = 6, coinPower = 3, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 2, sanity = 1, log = "You answered. They bowed again, lower, and went to tell the Captain you said no." },
				lose = { loseGear = "bl_black_cloud", health = { -20, -10 }, cause = "Cut down by the Kurokumo", log = "They asked again, more firmly. Black Cloud went home to the Clan." },
			},
			{
				label = "Give it back",
				result = { loseGear = "bl_black_cloud", money = 250, sanity = 2, log = "You handed it over wrapped in silk. The Clan sent 250 Ahn and a note: the matter is closed." },
			},
			{
				label = "Tell them she can ask herself",
				hint = "Mental Strength check. Nobody makes a Captain ask twice.",
				clash = { stat = "mind", foe = "Kurokumo pride", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = 2, log = "They looked at each other, and left. You may have just made a Captain ask twice." },
				lose = { money = -100, log = "They charged you a storage fee, in Kurokumo terms, and left." },
			},
		},
	},
	{
		id = "bl_item_verdict_hum",
		title = "Verdict Hums",
		text = "A merchant swears the coat he's selling is Workshop-made. Verdict hums on your hip, a thin note like a held breath. It did the same the last time someone lied to you.",
		weight = 8,
		cooldown = 8,
		when = { hasGear = "bl_verdict" },
		choices = {
			{ label = "Call the lie", result = { money = { 30, 60 }, mind = 1, log = "You named the lie before he finished it. He paid you to keep your voice down." } },
			{ label = "Let it hum", result = { sanity = -2, intelligence = 1, log = "You let him finish. Verdict hummed all the way home, disappointed in you." } },
			{ label = "Ask Verdict what else it hears", result = { sanity = -4, mind = 2, log = "You held it to your ear that night. It hummed at every voice on the street but one." } },
		},
	},
	{
		id = "bl_item_lullaby_bell",
		title = "Ringing at 3:13",
		text = "Every night at 3:13, Lullaby rings on its own: once, small and cold. Tonight the neighbors are at your door. Their children can't sleep through it, and neither can they.",
		weight = 8,
		cooldown = 6,
		when = { hasGear = "bl_lullaby" },
		choices = {
			{ label = "Stuff it in a sock", result = { sanity = -2, log = "The sock helped, a little. The neighbors stopped knocking and started crossing the street." } },
			{ label = "Sell it to a collector", result = { loseGear = "bl_lullaby", wage = { 400, 700 }, sanity = 3, log = "A Nest collector paid very well and carried it off in a lead box. The first night, the silence was so loud you laughed." } },
			{
				label = "Ring it back",
				hint = "Mental Strength check. Answer it.",
				clash = { stat = "mind", foe = "Whatever it's calling", coins = 3, base = 7, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "You rang it back at 3:14. It was quiet the rest of the year, as if it had been heard." },
				lose = { sanity = -8, condition = "night_terrors", log = "You rang it back. Something on the stairs rang back too." },
			},
		},
	},
	{
		id = "bl_item_snuffer_shadow",
		title = "Your Shadow Comes Home",
		text = "One evening your shadow is waiting on the doorstep, long and thin, without you. It looks at Snuffer in your hand, then at you.",
		weight = 9,
		cooldown = 6,
		when = { hasGear = "bl_snuffer" },
		choices = {
			{ label = "Let it back in", result = { loseGear = "bl_snuffer", sanity = 10, log = "You set Snuffer down. Your shadow stepped back under your feet as if it had never left. The E.G.O was gone by morning." } },
			{ label = "Close the door on it", result = { sanity = -6, strength = 2, log = "You closed the door. It waited on the step all night. In the morning it was gone, and Snuffer was a little warmer." } },
			{
				label = "Ask it what it wants",
				hint = "Mental Strength check. It has been waiting a long time.",
				clash = { stat = "mind", foe = "Your own shadow", coins = 4, base = 8, coinPower = 4 },
				win = { sanity = 6, mind = 3, log = "It wanted to be asked. You talked until dawn, and it agreed to visit." },
				lose = { sanity = -10, condition = "distortion_signs", log = "It told you. You wish it hadn't." },
			},
		},
	},
	{
		id = "bl_item_mantle_thirst",
		title = "The Mantle Is Thirsty",
		text = "The Vesperine Mantle has been cold for a week, and its Hardblood lining has gone from red to brown. Elder Casimir's note said nothing about feeding it.",
		weight = 8,
		cooldown = 5,
		when = { hasGear = "bl_vesperine_mantle" },
		choices = {
			{
				label = "Feed it a Hemobar",
				hint = "40 Ahn.",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 1, log = "You laid a Hemobar on the lining overnight. In the morning the foil was empty and the mantle was warm." },
			},
			{ label = "Let it go thirsty", result = { health = -6, sanity = -3, log = "It stayed cold all winter, and so did you." } },
			{
				label = "Return it to the Family",
				requires = { noBook = "bl_book_vesperine", noTrait = "bl_ab_red_mend" },
				result = { loseGear = "bl_vesperine_mantle", book = "bl_book_vesperine", sanity = 3, log = "You left it at the Vesperine cellar door. The next night a book waited on your step: the Family's codex, a page marked." },
			},
		},
	},
	{
		id = "bl_item_penance_kleinhammers",
		title = "Penance Is Missed",
		text = "Three Kleinhammers of the Inquisition wait outside your building with small hammers and large certainty. \"Grosshammer Adelheid has prayed on it,\" says one. \"Penance is to come home.\"",
		weight = 8,
		cooldown = 6,
		when = { hasGear = "bl_penance" },
		choices = {
			{
				label = "Let Penance answer",
				hint = "A real fight. Three of them.",
				clash = { stat = "strength", foe = "Three Kleinhammers", coins = 3, base = 7, coinPower = 3, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 2, log = "Penance answered. The Kleinhammers went home without it, a little less certain of everything." },
				lose = { loseGear = "bl_penance", health = { -22, -12 }, cause = "Struck down by the Inquisition", log = "Penance went home, and you went to a clinic." },
			},
			{ label = "Give it up", result = { loseGear = "bl_penance", book = "bl_book_catechism", sanity = 2, log = "You handed it over. Out of gratitude, or recruitment, they gave you the Grosshammer's Catechism." } },
			{
				label = "Debate the doctrine",
				hint = "Mental Strength check. They love a debate.",
				clash = { stat = "mind", foe = "N Corp doctrine", coins = 3, base = 7, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "You argued that a hammer, being made, is itself impure. They went away to pray about it." },
				lose = { sanity = -6, log = "They took notes on your answers. Your name is on a list in District 14 now." },
			},
		},
	},
	{
		id = "bl_item_rustback_oil",
		title = "Rust Season",
		text = "The rain came early, and the Rustback Plate is seizing up. The joints grind when you lift your arms. Ironsong says it needs real Outskirts oil, which nobody sells.",
		weight = 7,
		cooldown = 5,
		when = { hasGear = "bl_rustback_plate" },
		choices = {
			{
				label = "Buy smuggled oil",
				hint = "120 Ahn.",
				requires = { min = { money = 120 } },
				result = { money = -120, log = "A smuggler had a jar of something black. The plate moved like a coat again." },
			},
			{ label = "Wear it stiff", result = { strength = -2, health = 2, log = "You wore it stiff all season: stronger, slower, and creaking." } },
			{
				label = "Render your own",
				hint = "Intelligence check. Scrap, a pot, a lot of smell.",
				clash = { stat = "intelligence", foe = "A pot of boiling scrap", coins = 3, base = 6, coinPower = 3 },
				win = { intelligence = 2, log = "You boiled scrap down into something oily and evil-smelling. It worked." },
				lose = { health = { -10, -4 }, cause = "Went scavenging past the fence", log = "You went to the fence for scrap. Something past the fence went for you." },
			},
		},
	},
	{
		id = "bl_item_match",
		title = "The Match Wants Lighting",
		text = "The Lamplighter's match is warmer than your hand tonight. Every streetlamp outside has turned to face your window, waiting.",
		weight = 7,
		cooldown = 8,
		when = { hasGear = "bl_lamplighter_match" },
		choices = {
			{ label = "Strike it", result = { loseGear = "bl_lamplighter_match", sanity = { -8, 6 }, mind = 3, log = "It lit with a sound like a breath. Every lamp on the street went out, then came back facing away. The match burned down to nothing." } },
			{
				label = "Keep it unlit",
				hint = "Intelligence check. Hold out until dawn.",
				clash = { stat = "intelligence", foe = "A match that wants lighting", coins = 3, base = 7, coinPower = 3 },
				win = { intelligence = 2, sanity = 2, log = "You held out until dawn. The lamps turned back, sulking." },
				lose = { sanity = -8, condition = "night_terrors", log = "You didn't strike it. You dreamed all night that you had." },
			},
		},
	},
	{
		id = "bl_item_bookmark",
		title = "The Page You Need",
		text = "The Librarian's Bookmark slipped itself into a cookbook, a tax manual and a child's storybook this week. Each time, it opened to a page about you.",
		weight = 7,
		cooldown = 8,
		when = { world = { era = { "library", "limbus" } }, hasGear = "bl_bookmark" },
		choices = {
			{ label = "Read what it shows you", result = { mind = 2, intelligence = 2, sanity = -3, log = "It showed you a page from the book you'll become. Most of it was good. You stopped before the end." } },
			{ label = "Lock it in a drawer", result = { sanity = 2, log = "You locked it in a drawer. By morning it was back in your pocket, looking innocent." } },
		},
	},
	{
		id = "bl_item_watch_ticks",
		title = "Ticking at 3:13",
		text = "The watch that stopped at 4:33 starts ticking at 3:13. Through the window you see a stranger still out on the street, frozen, looking for a door.",
		weight = 7,
		cooldown = 8,
		tags = { "night" },
		when = { hasGear = "bl_four_thirty_three", side = "backstreets" },
		choices = {
			{ label = "Open your door to them", result = { sanity = 3, health = { -6, 0 }, addRelation = { kind = "friend", bond = 50 }, log = "You opened your door and pulled them in. The watch stopped again at 4:33. {newRelation} still brings you bread every week." } },
			{
				label = "Hold the watch to the glass",
				hint = "Mental Strength check. Let the ticking guide them.",
				clash = { stat = "mind", foe = "The first wave", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = 2, log = "The ticking carried. The stranger turned toward it and found a shelter door two houses down." },
				lose = { sanity = -6, log = "They never heard it. In the morning the street was clean." },
			},
		},
	},
	{
		id = "bl_item_collector",
		title = "A Collector from the Nest",
		text = "A Nest collector in a spotless coat has heard about your one-of-a-kind weapon. \"I collect stories,\" he says, opening a case lined with velvet. \"Yours would sit beautifully here.\"",
		weight = 7,
		cooldown = 8,
		when = { hasGear = UNIQUE_TOOLS, minAge = 20 },
		codex = "bl_lore_named_gear",
		choices = {
			{ label = "Sell it", result = { loseGear = "tool", wage = { 1800, 3200 }, sanity = -2, log = "He paid in Nest notes, a fortune by Backstreets standards. The velvet case closed with a sound like a door." } },
			{
				label = "Lend it for his exhibition",
				hint = "Intelligence check. Make sure you get it back.",
				clash = { stat = "intelligence", foe = "A collector's contract", coins = 3, base = 6, coinPower = 3 },
				win = { wage = { 300, 500 }, log = "It sat behind glass for a season, and came back polished, with a fee." },
				lose = { loseGear = "tool", sanity = -6, log = "The exhibition closed early, and the collector moved Nests. Your weapon moved with him." },
			},
			{ label = "Refuse", result = { sanity = 2, log = "\"It isn't a story,\" you said. \"It's mine.\" He wrote that down, delighted." } },
		},
	},
	{
		id = "bl_item_copycats",
		title = "Knock-Offs",
		text = "A Workshop three streets over sells cheap copies of your one-of-a-kind weapon. They don't work. Two Fixers have already lost fights trusting them, and their friends blame you.",
		weight = 6,
		cooldown = 10,
		when = { hasGear = UNIQUE_TOOLS, minAge = 18 },
		choices = {
			{
				label = "Shut the Workshop down",
				hint = "A fight. The owner has a hammer.",
				clash = { stat = "strength", foe = "A Workshop owner with a hammer", coins = 3, base = 6, coinPower = 3, fight = true, status = { id = "tremor", potency = 1 } },
				win = { strength = 2, wage = { 80, 160 }, log = "You showed them the real one. The copies went into the furnace, and the Fixers' friends bought you noodles." },
				lose = { health = { -16, -8 }, cause = "Brawled over a knock-off", log = "The owner's hammer and opinions were both bigger than they looked." },
			},
			{ label = "Sell them a license", result = { wage = { 150, 300 }, sanity = -3, log = "You took a cut. The copies still don't work, but now they're official." } },
			{
				label = "Warn every Office",
				hint = "Mental Strength check. Make them believe you.",
				clash = { stat = "mind", foe = "A cheap price", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 2, mind = 1, log = "You told every Office on the street. The copies stopped selling within a week." },
				lose = { sanity = -3, log = "Nobody believed you. Everybody believed the price." },
			},
		},
	},

	-- ── books that turn up ──
	{
		id = "bl_find_satchel",
		title = "A Fixer's Satchel",
		text = "After the Night, a Fixer's satchel lies in the gutter where its owner didn't come back for it. Inside: a few Ahn, a broken lamp, and a book stamped by a night shelter.",
		weight = 6,
		cooldown = 15,
		when = { side = "backstreets", minAge = 12 },
		choices = {
			{ label = "Keep the book", result = { book = "bl_book_night_almanac", money = 20, sanity = -2, log = "You kept the book and the Ahn, and left the lamp. It seemed rude to take everything." } },
			{ label = "Return it to the shelter", result = { sanity = 3, wage = { 20, 50 }, codex = "bl_lore_doorkeeper", log = "The shelter's keeper paid a finder's fee and put the almanac back where it had been missing for a year." } },
			{ label = "Take it to the Fixer's Office", result = { mind = 1, money = 40, log = "The Office paid for the satchel and kept everything in it. They looked at you as if you might be next." } },
		},
	},
	{
		id = "bl_find_margins",
		title = "The Free Pile",
		text = "Your old academy is clearing out its storeroom. On the free pile sits a textbook with somebody brilliant's notes crammed into every margin, arguing with every page.",
		weight = 6,
		once = true,
		when = { minAge = 10, maxAge = 30 },
		choices = {
			{ label = "Take it home", result = { book = "bl_book_prodigy_margins", log = "You took it home. The margins argued with the textbook on every page, and won." } },
			{
				label = "Find whose notes they are",
				hint = "Mental Strength check. Old class lists, old addresses.",
				clash = { stat = "mind", foe = "Twenty years of class lists", coins = 2, base = 5, coinPower = 3 },
				win = { book = "bl_book_prodigy_margins", addRelation = { kind = "mentor", bond = 50 }, log = "The notes were {newRelation}'s, who keeps a Workshop's books now. They let you keep the textbook and started lending you others." },
				lose = { book = "bl_book_prodigy_margins", sanity = -1, log = "The trail ended at a District 12 address that isn't there anymore. You kept the book anyway." },
			},
			{ label = "Leave it for a kid who needs it", result = { sanity = 4, log = "You left it on top of the pile, open to the best page. A kid with a patched bag took it, reading as they walked." } },
		},
	},
	{
		id = "bl_find_gym",
		title = "The Gym Closes",
		text = "The old Fixer gym on your street is closing. The trainer, who has counted drills out loud for thirty years, is giving everything away, down to his drill ledger.",
		weight = 5,
		once = true,
		when = { minAge = 14, maxAge = 45 },
		choices = {
			{ label = "Ask for the ledger", result = { book = "bl_book_drill_ledger", sanity = 1, log = "He pressed it into your hands. \"Count out loud,\" he said. \"Always out loud.\"" } },
			{ label = "Buy the heavy bag", hint = "30 Ahn.", requires = { min = { money = 30 } }, result = { money = -30, health = 3, strength = 1, log = "You carried the heavy bag home up four flights. Your neighbors hear you counting every night." } },
			{ label = "Help him pack up", result = { health = 1, sanity = 3, book = "bl_book_drill_ledger", log = "You carried thirty years of gym down three flights. He bought you lunch and gave you the ledger anyway." } },
		},
	},
	{
		id = "bl_find_lcd_van",
		title = "A Broken-Down Van",
		text = "An LCD recruiting van has broken down on your street. While they wait for a tow, the recruiters are handing out field manuals to anyone who'll stand still.",
		weight = 6,
		once = true,
		when = { world = { era = "limbus" }, minAge = 12 },
		codex = "lim_departments",
		choices = {
			{ label = "Take a manual", result = { book = "bl_book_lcd_field", log = "You took a manual. Chapter one is called DON'T TOUCH THE RED BITS, and it's very short." } },
			{ label = "Help push the van", result = { health = 2, wage = { 20, 40 }, book = "bl_book_lcd_field", log = "You pushed the van three blocks to a garage. They paid you, and gave you a manual for your trouble." } },
			{ label = "Ask what the job pays", result = { mind = 1, sanity = -1, log = "They told you. Then they told you about the casualty rate, quieter. You took a leaflet." } },
		},
	},
	{
		id = "bl_find_bookhunter",
		title = "The Bookhunter's Sack",
		text = "A bookhunter named Corvin is back from the Library with a sack of gilt-edged books. \"Guests' books,\" he whispers. \"A whole life in each, every fight they ever won. Fifteen hundred.\"",
		weight = 6,
		once = true,
		when = { world = { era = "library" }, minAge = 16 },
		codex = "library_books",
		choices = {
			{
				label = "Buy one",
				hint = "1,500 Ahn.",
				requires = { min = { money = 1500 }, noTrait = "bl_ab_emotion_level" },
				result = { money = -1500, book = "bl_book_guest", sanity = -3, log = "You bought one. It's warm, and it's heavier than a book should be." },
			},
			{ label = "Ask where he got them", result = { mind = 1, sanity = -2, codex = "bl_lore_reception_crews", log = "\"A crew,\" Corvin said. \"They won. They couldn't carry everything.\" He wouldn't say what happened to the guests." } },
			{ label = "Walk on", result = { sanity = 2, log = "You walked on. Some things shouldn't be read for money." } },
		},
	},

	-- ── with a linked friend (another player) ──
	{
		id = "bl_linked_bounty",
		title = "Fifty-Fifty",
		text = "{linked} slaps a Hana bounty notice on the table: the Gutter King, a Rat boss with a crown of bottle caps and a lot of friends. URBAN MYTH, 400 Ahn. \"Two of us,\" {linked} says. \"Fifty-fifty.\"",
		weight = 8,
		cooldown = 6,
		tags = { "danger" },
		when = { linked = true, minAge = 16 },
		choices = {
			{
				label = "Take it together",
				hint = "A real fight. Your friend adds a coin.",
				clash = { stat = "strength", foe = "The Gutter King and friends", coins = 3, base = 7, coinPower = 3, fight = true, status = { id = "bleed", potency = 2 }, assist = true },
				win = { wage = { 150, 250 }, strength = 1, setFlags = { "bl_trophy" }, log = "You and {linked} took the Gutter King's crown apart cap by cap. Hana paid out in two envelopes.", linked = { wage = { 150, 250 }, strength = 1, log = "You and {sender} took down the Gutter King. Hana paid out in two envelopes." } },
				lose = { health = { -18, -10 }, cause = "Killed hunting a bounty", log = "The Gutter King had more friends than the notice said. You and {linked} limped home.", linked = { health = { -10, -4 }, log = "The Gutter King had more friends than the notice said. You and {sender} limped home." } },
			},
			{
				label = "Plan it properly first",
				hint = "Mental Strength check. Bottle caps rattle.",
				clash = { stat = "mind", foe = "The Gutter King's routine", coins = 2, base = 5, coinPower = 3, assist = true },
				win = { wage = { 60, 120 }, mind = 1, log = "You and {linked} waited until the Gutter King was alone, and Hana paid half for the arrest.", linked = { wage = { 60, 120 }, log = "{sender} planned the bounty down to the minute. It worked." } },
				lose = { sanity = -3, log = "While you planned, another crew took the bounty. {linked} hasn't let you forget it.", linked = { sanity = -2, log = "{sender} planned so long another crew took the bounty." } },
			},
			{ label = "Let {linked} go alone", result = { sanity = -2, log = "You said no. {linked} went alone, came back with half the bounty, and a look.", linked = { wage = { 60, 120 }, log = "{sender} wouldn't come, so you took on the Gutter King alone, and got half the bounty." } } },
		},
	},
	{
		id = "bl_linked_terror",
		title = "Back to Back",
		text = "A named terror is loose two streets from {linked}'s place tonight, and the Fixers are an hour out. {linked} is already lacing up. \"Back to back,\" they say. \"Like we practiced.\"",
		weight = 6,
		cooldown = 8,
		tags = { "boss", "danger" },
		when = { linked = true, minAge = 18 },
		choices = {
			{
				label = "Back to back",
				hint = "A real fight. Your friend adds a coin.",
				clash = { stat = "strength", foe = "A named terror", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "rupture", potency = 2 }, assist = true },
				win = { strength = 2, gear = "bl_half_coin", setFlags = { "bl_trophy" }, chronicle = "bl_act_boss_slain", log = "You and {linked} held it until it broke. Afterward you split a coin from its hoard, half each.", linked = { strength = 2, gear = "bl_half_coin", log = "You and {sender} brought down a named terror, back to back. You split a coin from its hoard, half each." } },
				lose = { health = { -26, -14 }, cause = "Fell back to back with a friend", log = "It broke you both apart. {linked} dragged you to a clinic.", linked = { health = { -14, -6 }, log = "The terror was too much. You dragged {sender} to a clinic." } },
			},
			{
				label = "Get the neighbors out",
				hint = "Intelligence check, together.",
				clash = { stat = "intelligence", foe = "A street of sleeping people", coins = 3, base = 6, coinPower = 3, assist = true },
				win = { sanity = 3, intelligence = 1, log = "You and {linked} cleared both streets before it arrived. The Fixers found nobody to save.", linked = { sanity = 3, log = "You and {sender} got both streets out before the terror arrived." } },
				lose = { health = { -12, -6 }, cause = "Caught evacuating a street", log = "It arrived early. You got most of them out.", linked = { health = { -8, -4 }, log = "It arrived early. You and {sender} got most of them out." } },
			},
			{ label = "Talk {linked} out of it", result = { sanity = -2, log = "You talked {linked} into waiting for the Fixers. They arrived an hour later, as promised.", linked = { sanity = -2, log = "{sender} talked you into waiting for the Fixers. It was a long hour." } } },
		},
	},
}
