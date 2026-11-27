--[[
	Ward events: two or three per Ward, gated by when.district (and sometimes side).
	Each Ward leans on its own company, trade, wealth, danger and quirks.
	Threads:
		gatewater_bond        ward_gatewater_bond -> ward_gatewater_bond_due (4 yrs)
		lampwick_tapped_main  ward_lampwick_stolen_light -> ward_lampwick_meter_men (2 yrs)
		drownside_strongbox   ward_drownside_strongbox -> ward_drownside_kin_ask (2 yrs)
		                      (some endings set brine_grudge, read by life_brine_grudge)
		glasswall_lens        ward_glasswall_lens unlocks a choice in ward_glasswall_board
]]

return {
	-- Gatewater (Ward 1): the Exchange, bonds, flood insurance --------------
	{
		id = "ward_gatewater_bond",
		title = "The Floodgate Bond",
		text = "On the Gatewater tram platform, an Exchange runner in a coat that has never been rained on is selling floodgate bonds from a leather case. Forty {currency} now, he says, and in four years the Exchange pays you back with interest, so long as the great gates hold. The gates have held for ninety years.",
		once = true,
		tags = { "ward", "gatewater", "money", "thread_bond" },
		when = { district = "gatewater", minAge = 18, notFlags = { "gatewater_bond" } },
		choices = {
			{
				label = "Buy a bond",
				hint = "40 scrip.",
				requires = { min = { money = 40 } },
				result = {
					money = -40,
					prudence = 1,
					setFlags = { "gatewater_bond" },
					schedule = { event = "ward_gatewater_bond_due", inYears = 4 },
					log = "You bought a floodgate bond and kept the stamped certificate flat under your mattress.",
				},
			},
			{
				label = "Haggle him down",
				hint = "20 scrip. Prudence clash, medium.",
				requires = { min = { money = 20 } },
				clash = { stat = "prudence", foe = "An Exchange bond runner", coins = 2, base = 4, coinPower = 3 },
				win = {
					money = -20,
					prudence = 2,
					setFlags = { "gatewater_bond" },
					schedule = { event = "ward_gatewater_bond_due", inYears = 4 },
					log = "You talked the runner down to twenty {currency}, and he sold you the bond to make you stop.",
				},
				lose = { sanity = -2, log = "The runner laughed, snapped his case shut and caught the next tram without you." },
			},
			{
				label = "Keep your money in your boot",
				result = { prudence = 1, log = "You kept your {currency} in your boot, where at least you could feel it." },
			},
		},
	},
	{
		id = "ward_gatewater_bond_due",
		title = "The Bond Comes Due",
		text = "A letter from the Gatewater Exchange finds you, sealed in grey wax. Your floodgate bond has matured. The gates held, the letter says, and the Exchange is delighted to pay you, less the handling fee, the stamp fee, and a fee for the letter you are holding. The sum at the bottom is circled twice.",
		weight = 0,
		once = true,
		tags = { "ward", "gatewater", "money", "thread_bond" },
		when = { flags = { "gatewater_bond" } },
		choices = {
			{
				label = "Cash it at the window",
				result = { money = { 50, 70 }, sanity = 1, clearFlags = { "gatewater_bond" }, log = "You cashed the bond at a marble window and counted the notes twice on the steps." },
			},
			{
				label = "Dispute the fees",
				hint = "Temperance clash, medium-hard.",
				clash = { stat = "temperance", foe = "The Exchange fee schedule", coins = 2, base = 5, coinPower = 3 },
				win = { money = { 90, 130 }, temperance = 2, clearFlags = { "gatewater_bond" }, log = "You found the clause that forbade fees on fees, and the clerk paid in full, sourly." },
				lose = { money = { 25, 35 }, sanity = -3, clearFlags = { "gatewater_bond" }, log = "The clerk found a fee for disputes, and your bond came out thinner than ever." },
			},
			{
				label = "Sign it over to the flood fund",
				result = { justice = 3, sanity = 2, clearFlags = { "gatewater_bond" }, log = "You signed the bond over to the Silt flood fund and felt lighter than the money." },
			},
		},
	},
	{
		id = "ward_gatewater_assessor",
		title = "The Assessor Calls",
		text = "An Exchange assessor stands in your doorway with a folding rule, measuring the brown line the last High Water left on your wall. Everyone in the Gatewater Gutters pays flood insurance to the Exchange, by law, every quarter. He measures twice, writes a number in his book, and frowns at it as if it owes him money.",
		cooldown = 6,
		tags = { "ward", "gatewater", "money" },
		when = { district = "gatewater", side = "gutters", minAge = 18 },
		choices = {
			{
				label = "Argue the claim line by line",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "An Exchange assessor", coins = 2, base = 5, coinPower = 3 },
				win = { money = { 40, 90 }, prudence = 2, log = "You argued every inch of the waterline until he paid out, mostly to end the visit." },
				lose = { money = -10, sanity = -3, log = "He charged you ten {currency} for the assessment and ruled the flood an act of weather." },
			},
			{
				label = "Walk him down the whole row",
				result = { money = { 10, 25 }, justice = 2, log = "You walked him down the whole row, wall by wall, and he paid every house a little." },
			},
			{
				label = "Sign whatever he writes",
				result = { money = { 5, 15 }, sanity = -1, log = "You signed his number without reading it, and it bought a single new chair." },
			},
		},
	},

	-- Lampwick (Ward 2): lamp oil, gaslight, rationing ----------------------
	{
		id = "ward_lampwick_ration",
		title = "The Oil Ration",
		text = "The Lamplight Company issues the Gutters one tin of lamp oil per household per month, and this month the tins are half full. Up on the Rim, the Charter glows like a lamp left burning in an empty room. Your stairwell is black from the third landing down, and old Agna Wexley is feeling her way along the wall.",
		cooldown = 4,
		tags = { "ward", "lampwick" },
		when = { district = "lampwick", side = "gutters" },
		choices = {
			{
				label = "Light the stairwell with yours",
				result = { fortitude = -1, justice = 2, sanity = 2, log = "You burned your ration on the stairwell lamp, and the whole building climbed by your light." },
			},
			{
				label = "Queue twice in a borrowed coat",
				hint = "Prudence clash, easy.",
				clash = { stat = "prudence", foe = "The ration clerk", coins = 1, base = 2, coinPower = 2 },
				win = { prudence = 1, sanity = 2, log = "You queued twice in your neighbor's coat and came home with two half-tins and a grin." },
				lose = { money = -5, sanity = -2, log = "The clerk knew the coat, if not the face, and fined you five {currency} for it." },
			},
			{
				label = "Buy oil at a Charter back door",
				hint = "15 scrip.",
				requires = { min = { money = 15 } },
				result = { money = -15, sanity = 1, log = "A Charter footman sold you good oil from a kitchen door, at three times the ration price." },
			},
		},
	},
	{
		id = "ward_lampwick_stolen_light",
		title = "A Line from the Main",
		text = "Your neighbor Merrit has found where the Charter's gas main runs under the wall, two feet beneath the coal yard. With a borrowed wrench, a length of salvage pipe and a steady hand, your whole stairwell could burn gaslight all night for nothing. Merrit has the wrench. Merrit does not have a steady hand.",
		once = true,
		tags = { "ward", "lampwick", "crime", "thread_gas" },
		when = { district = "lampwick", side = "gutters", minAge = 16, notFlags = { "lampwick_tapped_main" } },
		choices = {
			{
				label = "Tap the main yourself",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The Charter gas main", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 2,
					sanity = 4,
					setFlags = { "lampwick_tapped_main" },
					schedule = { event = "ward_lampwick_meter_men", inYears = 2 },
					log = "You tapped the main by feel, and that night your stairwell burned gold from top to bottom.",
				},
				lose = {
					fortitude = { -9, -4 },
					sanity = -2,
					log = "The joint hissed, then flared, and you lost your eyebrows and a month to the burns.",
					cause = "Burned tapping a gas main",
				},
			},
			{
				label = "Hold the lamp while Merrit works",
				result = {
					fortitude = { -3, 0 },
					justice = 1,
					sanity = 2,
					setFlags = { "lampwick_tapped_main" },
					schedule = { event = "ward_lampwick_meter_men", inYears = 2 },
					log = "You held the lamp while Merrit's hands shook, and the pipe held, and the stairwell lit up.",
				},
			},
			{
				label = "Talk Merrit out of it",
				result = { prudence = 2, log = "You talked Merrit out of it, and the stairwell stayed dark and legal." },
			},
		},
	},
	{
		id = "ward_lampwick_meter_men",
		title = "The Meter Men",
		text = "Two Lamplight meter men in leather aprons are following a pipe along the coal yard wall, tapping it with brass rods and listening. They reach the place where it turns toward your stairwell and stop. One of them takes out a notebook. The other looks up at your lit window and smiles without any warmth at all.",
		weight = 0,
		once = true,
		tags = { "ward", "lampwick", "crime", "thread_gas" },
		when = { district = "lampwick", side = "gutters", flags = { "lampwick_tapped_main" } },
		choices = {
			{
				label = "Swear you never touched it",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Lamplight meter men", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 3, sanity = 2, clearFlags = { "lampwick_tapped_main" }, log = "You swore so steadily that the meter men blamed the pipe on the last tenants and left." },
				lose = {
					money = { -70, -40 },
					sanity = -3,
					clearFlags = { "lampwick_tapped_main" },
					log = "They capped your pipe, billed you for two years of gaslight, and wrote your name down.",
				},
			},
			{
				label = "Pay for the gas you burned",
				hint = "50 scrip.",
				requires = { min = { money = 50 } },
				result = { money = -50, justice = 1, sanity = 1, clearFlags = { "lampwick_tapped_main" }, log = "You paid for the gas, and the meter men fitted a meter and left your stairwell lit." },
			},
			{
				label = "Cut the line before they reach it",
				result = { justice = -1, sanity = -2, clearFlags = { "lampwick_tapped_main" }, log = "You cut the pipe and packed the hole with mud, and the stairwell went dark again." },
			},
		},
	},

	-- Saltpan (Ward 3): salt, preserved food, cracked hands -----------------
	{
		id = "ward_saltpan_salt_lung",
		title = "Salt Lung",
		text = "The pan workers call it salt lung: a dry cough that tastes of the Mere and comes up white on your sleeve. You have had it since the evaporation season started. The Saltworks stitcher sees pan workers for free on the first of the month, and the queue for the first of the month starts the night before.",
		cooldown = 5,
		tags = { "ward", "saltpan", "sickness" },
		when = { district = "saltpan", side = "gutters", minAge = 14 },
		choices = {
			{
				label = "Queue all night for the stitcher",
				result = { fortitude = { 2, 5 }, sanity = -1, log = "You queued all night in the salt wind, and the stitcher gave you a tin of chest grease." },
			},
			{
				label = "Work the pans through it",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "Salt lung", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 8, 20 }, fortitude = -1, log = "You worked the pans through the cough, and it gave up before you did." },
				lose = {
					fortitude = { -10, -5 },
					sanity = -2,
					log = "The cough laid you flat on the pans, and two rakers carried you home in a barrow.",
					cause = "Salt lung",
				},
			},
			{
				label = "Wear a wet cloth over your mouth",
				result = { prudence = 1, fortitude = { 0, 1 }, log = "You worked with a wet rag tied over your mouth, and the old rakers nodded approvingly." },
			},
		},
	},
	{
		id = "ward_saltpan_noon_bonus",
		title = "The Noon Bonus",
		text = "The Saltworks foreman chalks a bonus on the board: ten {currency} to whoever rakes the most pans before the noon bell. Your hands are still split from last week, and the salt finds every crack. Beside you, an old raker named Una Saltry wraps her fingers in rag and says nothing, which means she intends to win.",
		cooldown = 5,
		tags = { "ward", "saltpan", "work" },
		when = { district = "saltpan", side = "gutters", minAge = 12, maxAge = 55 },
		choices = {
			{
				label = "Race Una for the bonus",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "Una Saltry", coins = 2, base = 4, coinPower = 3 },
				win = { money = 10, fortitude = -1, sanity = 3, log = "You beat Una by half a pan, and she shook your cracked hand with her cracked hand." },
				lose = { fortitude = { -3, -1 }, sanity = -1, log = "Una beat you by four pans and spent the bonus on hand salve for the whole row." },
			},
			{
				label = "Rake beside her and split it",
				result = {
					money = 5,
					sanity = 2,
					addRelation = { kind = "friend", name = "Una Saltry", bond = 45, age = { 55, 68 } },
					log = "You raked in step with {newRelation} and split the bonus down the middle.",
				},
			},
			{
				label = "Rake at your own pace",
				result = { fortitude = 1, prudence = 1, log = "You raked at your own pace and kept what skin was left on your palms." },
			},
		},
	},

	-- Glasswall (Ward 4): glass, lenses, an exclusive Charter ----------------
	{
		id = "ward_glasswall_lens",
		title = "The Great Lens",
		text = "Once a year the Glaziers' observatory opens its great lens to one child from the Gutters, chosen by a written paper set at the gate. The paper is long and the questions are strange: the weight of light, the color of distance, why the Mere looks black from the Rim. Forty children sit on the cold steps, chewing pencils.",
		once = true,
		tags = { "ward", "glasswall", "study" },
		when = { district = "glasswall", side = "gutters", minAge = 9, maxAge = 15 },
		choices = {
			{
				label = "Sit the paper",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The observatory paper", coins = 2, base = 4, coinPower = 3 },
				win = {
					temperance = { 3, 5 },
					sanity = 4,
					setFlags = { "glasswall_lens" },
					log = "You won the night at the great lens and counted stars until the astronomers sent you home.",
				},
				lose = { temperance = 1, sanity = -2, log = "You answered the weight of light wrongly and kept thinking about it for a year." },
			},
			{
				label = "Sell your place on the steps",
				result = { money = { 3, 8 }, log = "You sold your place on the steps to a cobbler's son for a few {currency}." },
			},
			{
				label = "Use the public telescope instead",
				result = { prudence = 1, sanity = 2, log = "You looked through the public telescope at the gate and saw one very bright star." },
			},
		},
	},
	{
		id = "ward_glasswall_board",
		title = "The Residence Board",
		text = "Every five years the Glaziers' residence board decides who may go on living behind the glass. You wait on a velvet bench in a corridor made entirely of windows while three examiners read your file aloud, with pauses. One of them is polishing a lens. None of them has looked at you yet.",
		cooldown = 5,
		tags = { "ward", "glasswall", "luxury" },
		when = { district = "glasswall", side = "charter", minAge = 20 },
		choices = {
			{
				label = "Answer every question perfectly",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "The residence board", coins = 2, base = 5, coinPower = 3 },
				win = { prudence = 2, sanity = 4, log = "You answered every question in the right order, and the board renewed you without comment." },
				lose = { money = { -90, -50 }, sanity = -4, log = "The board renewed you on probation and billed you for the extra paperwork." },
			},
			{
				label = "Tell them about the great lens",
				requires = { flags = { "glasswall_lens" } },
				result = { justice = 2, sanity = 5, log = "You told the board you first saw the stars from the Gutters steps, and one examiner smiled." },
			},
			{
				label = "Bring a gift of rare seeds",
				hint = "60 scrip.",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 2, log = "You brought the board a packet of rare seeds and were renewed before you sat down." },
			},
		},
	},

	-- Ropewalk (Ward 5): rope, nets, cable, and the accidents ---------------
	{
		id = "ward_ropewalk_long_shed",
		title = "The Long Shed",
		text = "The Hempen Company's long shed runs a quarter mile down the hill, and the rope walkers pace it backward all day, feeding hemp into the twist. Halfway down, a boy's sleeve has caught in the spinning strand. The wheel at the far end keeps turning. Nobody at the wheel can hear him over the whir. You can.",
		cooldown = 6,
		tags = { "ward", "ropewalk", "danger" },
		when = { district = "ropewalk", side = "gutters", minAge = 12 },
		choices = {
			{
				label = "Cut the strand",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The spinning strand", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 4, log = "You cut the strand with your net knife a breath before it dragged the boy into the twist." },
				lose = {
					fortitude = { -9, -4 },
					sanity = -3,
					log = "The strand whipped loose as you cut it, and you woke up on a pile of sacking.",
					cause = "Caught in the rope twist",
				},
			},
			{
				label = "Run for the wheel brake",
				result = { prudence = 2, sanity = 1, log = "You ran the whole length of the shed and threw your weight on the wheel brake." },
			},
			{
				label = "Shout until someone hears",
				result = { justice = 1, sanity = -3, log = "You shouted yourself hoarse until the wheel stopped, but the boy came away with a broken wrist." },
			},
		},
	},
	{
		id = "ward_ropewalk_accident_bell",
		title = "The Accident Bell",
		text = "The accident bell on the Ropewalk docks rings three or four times a week, and everyone in the Ward stops to count the strokes. Two strokes mean a crane. Three mean the water. Tonight it rings three times, and the woman who sells you bread every morning drops her basket and runs for the docks.",
		cooldown = 5,
		tags = { "ward", "ropewalk" },
		when = { district = "ropewalk", minAge = 14 },
		choices = {
			{
				label = "Run down to the docks",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The cold dock water", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 4, sanity = 3, log = "You went into the water off the third pier and came up with her son by the collar." },
				lose = {
					fortitude = { -8, -3 },
					sanity = -4,
					log = "You searched the black water under the pier until the dockhands pulled you out, alone.",
					cause = "Drowned off the Ropewalk docks",
				},
			},
			{
				label = "Take up a collection",
				result = { money = { -10, -5 }, justice = 2, sanity = 1, log = "You went door to door with a hat and raised a month's rent for her by morning." },
			},
			{
				label = "Mind her stall until she's back",
				result = { prudence = 1, sanity = -2, log = "You minded her bread stall until she came back very late and sat down without a word." },
			},
		},
	},

	-- Pumpside (Ward 6): the great pumps, noise and pride ------------------
	{
		id = "ward_pumpside_boiler_day",
		title = "Boiler Day",
		text = "Once a year the Boilermakers' Charter fires a new boiler for the great pumps, and the whole of Pumpside turns out to cheer it. There are brass bands nobody can hear, flags nobody can see through the steam, and a coal race on the gantry for anyone with a shovel and something to prove. You have both.",
		cooldown = 4,
		tags = { "ward", "pumpside", "festival" },
		when = { district = "pumpside", minAge = 14 },
		choices = {
			{
				label = "Enter the coal race",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The gantry coal race", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 15, 35 }, fortitude = 1, sanity = 4, log = "You out-shoveled the whole gantry, and half-deaf Pumpside cheered you by stamping its feet." },
				lose = { fortitude = { -4, -1 }, sanity = 1, log = "You came fifth, with blisters on your blisters, and someone gave you a ribbon anyway." },
			},
			{
				label = "Sell hot buns to the crowd",
				result = { wage = { 8, 18 }, temperance = 1, log = "You sold hot buns from a tray all afternoon and came home smelling of steam and sugar." },
			},
			{
				label = "Cheer from the rooftops",
				result = { sanity = { 3, 5 }, log = "You cheered the new boiler from a rooftop until you had no voice left to cheer with." },
			},
		},
	},
	{
		id = "ward_pumpside_quiet_night",
		title = "A Night Without Pumps",
		text = "The great pumps are down for a valve change, and for the first night in years Pumpside is silent. Nobody can sleep. Babies who have never heard quiet are screaming at it. Your own heart sounds enormous. Out on the street, neighbors stand in their nightclothes, talking in whispers they can finally hear.",
		cooldown = 8,
		tags = { "ward", "pumpside" },
		when = { district = "pumpside" },
		choices = {
			{
				label = "Go out and whisper with them",
				result = { prudence = 1, sanity = 4, log = "You whispered on the street with neighbors you had only ever shouted at, and learned their names." },
			},
			{
				label = "Help at the boilerhouse",
				hint = "Temperance clash, medium.",
				requires = { minAge = 14 },
				clash = { stat = "temperance", foe = "The jammed valve", coins = 2, base = 4, coinPower = 3 },
				win = { temperance = 3, wage = { 10, 25 }, log = "You held the lamp and then the wrench, and the pumps came back an hour early." },
				lose = {
					fortitude = { -6, -2 },
					log = "The valve kicked as it seated, and you went home with a hand wrapped in rag.",
					cause = "Crushed by a pump valve",
				},
			},
			{
				label = "Lie awake and listen",
				result = { prudence = 2, sanity = -1, log = "You lay awake listening to the Ward breathe, and the pumps woke you when they came back." },
			},
		},
	},

	-- Foundry Row (Ward 7): smog, sparks and short tempers -----------------
	{
		id = "ward_foundry_smog_week",
		title = "Smog Week",
		text = "The wind has died, and the smog from the Ironmongers' stacks has settled into the Foundry Row Gutters like a lid on a pot. Lamps burn brown at noon. Washing comes off the line greyer than it went on. Somewhere down the street, a child is coughing in a rhythm you have started counting without meaning to.",
		cooldown = 4,
		tags = { "ward", "foundry", "danger", "sickness" },
		when = { district = "foundry", side = "gutters" },
		choices = {
			{
				label = "Seal the windows with wet sheets",
				result = { fortitude = { -2, 0 }, prudence = 1, sanity = -1, log = "You hung wet sheets over every window and breathed through a damp sleeve for a week." },
			},
			{
				label = "Walk to work through it",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The Foundry smog", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 5, 15 }, fortitude = -1, log = "You walked to work through the brown air all week and kept your wages, if not your color." },
				lose = {
					fortitude = { -9, -4 },
					sanity = -2,
					log = "You collapsed coughing in a doorway halfway to work, and a stranger walked you home.",
					cause = "Choked in the Foundry smog",
				},
			},
			{
				label = "Take the child to a stitcher",
				hint = "30 scrip.",
				requires = { min = { money = 30 } },
				result = { money = -30, justice = 3, sanity = 2, log = "You carried the coughing child to a stitcher and paid for her tea and her rest." },
			},
		},
	},
	{
		id = "ward_foundry_quarrel",
		title = "Words at the Chain Shop",
		text = "Outside the chain shop, two smiths are arguing about a short-weighted coil, and on Foundry Row arguments end quickly. One has picked up a length of chain. The other has picked up his apprentice's hammer. The crowd is stepping back to give them room, the way people here always do. You are standing closest.",
		cooldown = 5,
		tags = { "ward", "foundry", "danger", "crime" },
		when = { district = "foundry", minAge = 15 },
		choices = {
			{
				label = "Step between them",
				hint = "Justice clash, medium-hard.",
				clash = { stat = "justice", foe = "Two angry smiths", coins = 2, base = 5, coinPower = 3 },
				win = { justice = 4, sanity = 3, log = "You stepped between them and talked fast, and both smiths put their iron down." },
				lose = {
					fortitude = { -11, -5 },
					sanity = -3,
					log = "You stepped between them a moment too late and woke up on the chain shop floor.",
					cause = "Caught in a Foundry Row quarrel",
				},
			},
			{
				label = "Weigh the coil on the shop scale",
				hint = "Needs a head for numbers.",
				requires = { min = { temperance = 30 } },
				result = { temperance = 1, justice = 2, log = "You weighed the coil in front of everyone and proved it short, and the quarrel became paperwork." },
			},
			{
				label = "Step back with the crowd",
				result = { prudence = 1, sanity = -3, log = "You stepped back with everyone else and heard the end of it from the next street." },
			},
		},
	},
	{
		id = "ward_foundry_sparks",
		title = "Spark Season",
		text = "When the Ironmongers run the big furnaces at night, sparks rise out of the stacks and drift down over the Gutters like slow orange snow. Most of them die in the air. One has landed in the tar paper on the roof across the lane, and a thin line of flame is walking toward the gutter. You are the only one awake.",
		cooldown = 5,
		tags = { "ward", "foundry", "danger" },
		when = { district = "foundry", side = "gutters", minAge = 10 },
		choices = {
			{
				label = "Climb across with a bucket",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The roof fire", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 3,
					sanity = 4,
					relationBond = { kind = "all", amount = 3 },
					log = "You climbed across with a bucket and beat the fire out with your coat before it spread.",
				},
				lose = {
					fortitude = { -9, -4 },
					sanity = -2,
					log = "The tar paper flared up in your face, and you fell back through a skylight.",
					cause = "Burned on a Foundry Row roof",
				},
			},
			{
				label = "Wake the whole lane",
				result = { prudence = 2, justice = 1, log = "You banged on every door in the lane, and a bucket line had it out in minutes." },
			},
			{
				label = "Close your shutters",
				result = { justice = -1, sanity = -3, log = "You closed your shutters and listened to the bucket line work without you." },
			},
		},
	},

	-- Kelpmarket (Ward 8): poor, loud and fed -------------------------------
	{
		id = "ward_kelpmarket_voice",
		title = "A Voice for the Stall",
		text = "Old Delphine Mosswood has sold fish under the same striped tarp for forty years, and this morning her voice is gone. She points at you, then at her stall, then at her throat. Across the aisle, the Harrow sisters are shouting their prices so loudly the gulls have moved to the next pier.",
		cooldown = 4,
		tags = { "ward", "kelpmarket", "market" },
		when = { district = "kelpmarket", minAge = 10 },
		choices = {
			{
				label = "Out-shout the Harrow sisters",
				result = { wage = { 6, 16 }, justice = 1, sanity = 1, log = "You out-shouted the Harrow sisters all morning and sold Delphine's stall bare by noon." },
			},
			{
				label = "Sing the prices instead",
				result = { wage = { 5, 12 }, temperance = 1, sanity = 4, log = "You sang the prices to a tune everyone knew, and half the market sang them back." },
			},
			{
				label = "Make her honey tea and mind the stall",
				result = {
					sanity = 2,
					addRelation = { kind = "friend", name = "Delphine Mosswood", bond = 50, age = { 60, 72 } },
					log = "You made {newRelation} honey tea and minded her stall, and she fed you fish for a month.",
				},
			},
		},
	},
	{
		id = "ward_kelpmarket_common_pot",
		title = "The Common Pot",
		text = "On the farm landing below the market there is a pot that never goes cold. Anyone can eat from it, and anyone who eats puts something in: a fish head, an onion, a fistful of kelp, a story if there is nothing else. You are hungry, and your pockets hold one bent spoon and a button.",
		cooldown = 5,
		tags = { "ward", "kelpmarket", "kindness" },
		when = { district = "kelpmarket", max = { money = 40 } },
		choices = {
			{
				label = "Pay with a story",
				result = { fortitude = 1, temperance = 1, sanity = { 3, 5 }, log = "You told the landing about the drowned cathedral, and they gave you a second bowl for the ending." },
			},
			{
				label = "Wash the pots instead",
				result = { fortitude = { 1, 2 }, prudence = 1, sanity = 2, log = "You scrubbed the landing's pots until your hands were raw and ate like a farmhand." },
			},
			{
				label = "Drop in the button",
				result = { justice = -1, sanity = 1, log = "You dropped the button in when nobody was looking, and the broth tasted of guilt." },
			},
		},
	},
	{
		id = "ward_kelpmarket_farm_storm",
		title = "Storm on the Farms",
		text = "A squall is coming across the Mere with a skirt of black rain under it, and the floating kelp farms are straining at their anchors. A Kelp & Net foreman is running down the landing, waving a fistful of {currency}, shouting for anyone who can row and hold a line. You can do both.",
		cooldown = 6,
		tags = { "ward", "kelpmarket", "danger" },
		when = { district = "kelpmarket", minAge = 14 },
		choices = {
			{
				label = "Row out and hold the anchor line",
				hint = "Fortitude clash, medium-hard.",
				clash = { stat = "fortitude", foe = "The squall", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 20, 45 }, fortitude = 1, justice = 2, log = "You held the anchor line through the squall, and the farm was still there in the morning." },
				lose = {
					fortitude = { -10, -4 },
					sanity = -3,
					log = "The line tore through your hands, and you swam back to the landing without the farm or the boat.",
					cause = "Lost off the kelp farms",
				},
			},
			{
				label = "Haul nets in on the landing",
				result = { wage = { 6, 14 }, fortitude = { -1, 0 }, log = "You hauled nets on the landing until the rain eased, soaked to the skin and paid for it." },
			},
			{
				label = "Get indoors",
				result = { prudence = 1, sanity = -1, log = "You got indoors and watched two farms drift past your window toward the open Mere." },
			},
		},
	},

	-- Bellhollow (Ward 9): bells, flood towers, the Choir -------------------
	{
		id = "ward_bellhollow_flat_bell",
		title = "The Flat Bell",
		text = "Every hour in Bellhollow, a hundred bells answer one another from a hundred towers. Tonight, at midnight, one of them rings flat, a low, sour note that hangs in the air long after the others stop. The Bellwrights say it is a cracked casting. The Choir, sitting by the water, says it is an answer. You can still hear it.",
		cooldown = 8,
		tags = { "ward", "bellhollow", "faith" },
		when = { district = "bellhollow", minAge = 10 },
		choices = {
			{
				label = "Climb the tower to find it",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The bell tower stairs", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 10, 25 }, justice = 2, sanity = 3, log = "You found the cracked bell by lantern light, and the Bellwrights paid you for spotting it." },
				lose = {
					fortitude = { -7, -3 },
					sanity = -2,
					log = "You slipped on the tower's worn stairs and spent the rest of the night counting bruises.",
					cause = "Fell in a bell tower",
				},
			},
			{
				label = "Sit with the Choir and listen",
				result = { prudence = 2, sanity = { -3, 3 }, log = "You sat with the Choir until dawn, and the flat note rang once more, from under the water." },
			},
			{
				label = "Stuff your ears and sleep",
				result = { sanity = 1, log = "You stuffed your ears with wool, slept like a stone, and dreamed of nothing." },
			},
		},
	},
	{
		id = "ward_bellhollow_warning_rope",
		title = "The Warning Rope Breaks",
		text = "High Water is coming up the Bellhollow channels faster than the tide tables promised, and the flood tower on your street should be ringing the warning. Its rope has snapped at the pulley, forty feet up. Below it, families on the low streets are still asleep, and the water is already over the first step.",
		cooldown = 3,
		tags = { "ward", "bellhollow", "high_water", "danger" },
		when = { district = "bellhollow", side = "gutters", minAge = 12, world = { water = "high" } },
		choices = {
			{
				label = "Climb up and ring it by hand",
				hint = "Justice clash, medium-hard.",
				clash = { stat = "justice", foe = "The flood tower", coins = 2, base = 5, coinPower = 3 },
				win = {
					justice = 4,
					sanity = 4,
					relationBond = { kind = "all", amount = 3 },
					log = "You climbed the tower and rang the warning by hand until the low streets were awake and climbing.",
				},
				lose = {
					fortitude = { -10, -4 },
					sanity = -3,
					log = "You fell from the tower's ladder into the rising water and were fished out at dawn.",
					cause = "Fell from a flood tower",
				},
			},
			{
				label = "Run the low streets banging pans",
				result = { fortitude = -1, justice = 3, sanity = 2, log = "You ran the low streets banging two pans together until every door was open." },
			},
			{
				label = "Fetch the Bellwrights' night crew",
				result = { prudence = 1, sanity = -2, log = "You fetched the night crew, and they came quickly, but the last houses on the channel still flooded." },
			},
		},
	},
	{
		id = "ward_bellhollow_procession",
		title = "The Silent Procession",
		text = "Once a year the Choir of Still Water walks every street in Bellhollow without a word, grey wool and unlit lanterns, from the highest tower to the waterline. For that one hour the Bellwrights stop every bell in the Ward. The silence comes down the hill toward your door like weather, and people step out to meet it.",
		cooldown = 5,
		tags = { "ward", "bellhollow", "faith", "choir" },
		when = { district = "bellhollow", minAge = 8 },
		choices = {
			{
				label = "Walk with them",
				result = { prudence = 2, sanity = 4, log = "You fell in at the back of the procession and walked to the water without a single word." },
			},
			{
				label = "Ask for a seat in the Choir",
				hint = "Needs a patient mind.",
				requires = { minAge = 12, career = "none", min = { prudence = 25 } },
				result = { career = "choir", sanity = 3, log = "At the waterline you asked the Still Voice for a seat, and she handed you an unlit lantern." },
			},
			{
				label = "Sell hot bread to the watchers",
				result = { wage = { 4, 10 }, justice = -1, log = "You sold hot bread to the watching crowd, and the silence made every sale feel loud." },
			},
		},
	},

	-- Drownside (Ward 10): no charter, no law, the best salvage -------------
	{
		id = "ward_drownside_strongbox",
		title = "A Wreck Company Strongbox",
		text = "The tide has pulled back from the old Wreck Company counting house, the one with the collapsed dome, and in the mud of its front hall you can see a strongbox with the company seal still bright on the lid. Brine Kin boats are working the far end of the street. Nobody has noticed it but you.",
		once = true,
		tags = { "ward", "drownside", "salvage", "danger", "thread_strongbox" },
		when = { district = "drownside", minAge = 14, notFlags = { "drownside_strongbox" } },
		choices = {
			{
				label = "Wade in and drag it out",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The sucking mud", coins = 2, base = 4, coinPower = 3 },
				win = {
					money = { 20, 45 },
					justice = 2,
					setFlags = { "drownside_strongbox" },
					schedule = { event = "ward_drownside_kin_ask", inYears = 2 },
					log = "You dragged the box home under a sack. Inside were old notes and a sealed ledger.",
				},
				lose = {
					money = -10,
					fortitude = { -8, -3 },
					sanity = -2,
					log = "The mud took you to the chest, and a Kin boat towed you out for a fee.",
					cause = "Drowned in the Drownside mud",
				},
			},
			{
				label = "Wave the Kin boats over",
				result = { money = { 10, 20 }, prudence = 1, log = "You waved the Kin over, and a cousin tipped you for your sharp eyes and good sense." },
			},
			{
				label = "Leave it to the mud",
				result = { sanity = 1, log = "You left the strongbox where it lay, and by evening the tide had covered it again." },
			},
		},
	},
	{
		id = "ward_drownside_kin_ask",
		title = "The Kin Come Asking",
		text = "A Brine Kin Ledger-hand is sitting on your step, turning a Wreck Company seal over in her fingers. \"Cousin,\" she says, \"a sealed ledger went missing from the counting house two years back. The Kin hold the old company's debts now. We would like our book.\"",
		weight = 0,
		once = true,
		tags = { "ward", "drownside", "brine", "thread_strongbox" },
		when = { flags = { "drownside_strongbox" } },
		choices = {
			{
				label = "Hand over the ledger",
				result = { money = { 10, 20 }, prudence = 1, sanity = 2, clearFlags = { "drownside_strongbox" }, log = "You handed over the ledger, and she paid you a finder's fee and called you cousin." },
			},
			{
				label = "Sell it to the Sluice first",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "A Brine Kin Ledger-hand", coins = 3, base = 6, coinPower = 3 },
				win = {
					money = { 80, 160 },
					justice = 2,
					clearFlags = { "drownside_strongbox" },
					setFlags = { "brine_grudge" },
					log = "You sold the ledger to a Sluice clerk before she could stop you. The Kin will remember.",
				},
				lose = {
					fortitude = { -8, -3 },
					sanity = -3,
					clearFlags = { "drownside_strongbox" },
					setFlags = { "brine_grudge" },
					log = "She took the ledger off you on the way to the Sluice office, and not gently.",
					cause = "Settled with the Brine Kin",
				},
			},
			{
				label = "Say you never found it",
				result = {
					prudence = 1,
					sanity = -2,
					clearFlags = { "drownside_strongbox" },
					setFlags = { "brine_grudge" },
					log = "She smiled, wrote one line in her own ledger, and left. The Kin remember a lie.",
				},
			},
		},
	},
	{
		id = "ward_drownside_kin_law",
		title = "Kin Law",
		text = "There is no court in Drownside, so disputes go to the Brine Kin. A cousin sits in judgment on an upturned boat at the end of your street, eating an orange, while two neighbors argue over a salvaged stove. You saw who pulled it out of the water first. Everyone knows you saw. The cousin points at you.",
		cooldown = 5,
		tags = { "ward", "drownside", "brine", "crime" },
		when = { district = "drownside", minAge = 12 },
		choices = {
			{
				label = "Tell the truth",
				result = { justice = 3, sanity = -1, log = "You told the truth, and the cousin gave the stove to the right neighbor. The other stopped speaking to you." },
			},
			{
				label = "Say what the cousin wants to hear",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The cousin's judgment", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 10, 25 }, prudence = 2, justice = -2, log = "You read the cousin's face and said what it wanted, and a few {currency} found your pocket." },
				lose = { money = { -20, -10 }, sanity = -2, log = "You guessed wrong about what the cousin wanted, and the Kin fined you for wasting their afternoon." },
			},
			{
				label = "Say you saw nothing",
				result = { prudence = 1, sanity = -2, log = "You said you saw nothing, so the cousin had the stove dropped back into the Mere." },
			},
		},
	},
}
