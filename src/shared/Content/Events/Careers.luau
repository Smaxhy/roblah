--[[
	Career events. Recruitment events let the player join; the rest are gated by when.career.
	Threads:
		guild_mentor     job_diver_mentor -> job_diver_lesson (2 yrs) -> job_diver_line_slack (3 yrs)
		                 -> mentor_saved / mentor_lost (read by world_lantern_night)
		took_gate_bribe  job_sluice_bribe -> job_sluice_audit (3 yrs)
		found_calla_lantern (Youth) unlocks a choice in job_recruit_guild
]]

return {
	-- Recruitment ------------------------------------------------------------
	{
		id = "job_recruit_docks",
		title = "Hiring on the Docks",
		text = "Two people are hiring on the Silt docks this morning. A Pumpworks foreman with soot to the elbows wants ash hands for the boiler rooms: steady pay, no questions. Further along, a Brine Kin cousin leans on a skiff and says a quiet boat can always use another oar.",
		cooldown = 4,
		tags = { "career", "recruit", "stoker", "brine" },
		when = { minAge = 14, side = "gutters", career = "none" },
		choices = {
			{
				label = "Sign on at the Pumpworks",
				result = { career = "stoker", fortitude = 1, log = "You signed the Pumpworks ledger with a sooty thumb and went down to the boilers." },
			},
			{
				label = "Take the oar with the Kin",
				result = { career = "brine", prudence = 1, log = "You took the oar, and the cousin called you cousin from that day on." },
			},
			{
				label = "Keep looking",
				result = { prudence = 1, log = "You thanked them both and kept looking for something that suited you better." },
			},
		},
	},
	{
		id = "job_recruit_guild",
		title = "The Lantern Trial",
		text = "The Lantern Guild holds its trials off the end of the Guild pier: one lantern, one rope, one dive to the drowned bell at the bottom of Chandlers' Row and back. A Lantern-Captain with a weathered face checks your knots and says nothing at all.",
		cooldown = 5,
		tags = { "career", "recruit", "diver" },
		when = { minAge = 16, career = "none" },
		choices = {
			{
				label = "Take the trial dive",
				hint = "Needs some nerve and some lungs. Justice clash, medium.",
				requires = { min = { justice = 20, fortitude = 20 } },
				clash = { stat = "justice", foe = "The trial dive", coins = 2, base = 4, coinPower = 3 },
				win = { career = "diver", justice = 2, sanity = 3, log = "You touched the drowned bell and came up with your lantern still lit. The Guild took you in." },
				lose = { fortitude = { -6, -3 }, sanity = -3, log = "You came up early and gasping, with your lantern dark. The Captain said to try next year." },
			},
			{
				label = "Carry Calla Hollin's lantern down",
				requires = { flags = { "found_calla_lantern" }, min = { justice = 20, fortitude = 20 } },
				result = { career = "diver", justice = 2, sanity = 5, log = "You carried Calla Hollin's lantern to the bell and back. Nobody said a word, and you were in." },
			},
			{
				label = "Watch the others dive",
				result = { prudence = 1, log = "You watched the others dive from the pier and counted how long each one stayed down." },
			},
		},
	},
	{
		id = "job_recruit_sluice",
		title = "The Clerks' Examination",
		text = "The Sluice Authority's examination hall smells of ink, wet umbrellas and nerves. Two hundred hopefuls bend over the same paper: tide tables, gate ratios, and a long question about which district floods first. The proctor's clock ticks louder than the pumps.",
		cooldown = 4,
		tags = { "career", "recruit", "sluice" },
		when = { minAge = 18, career = "none" },
		choices = {
			{
				label = "Sit the examination",
				hint = "Needs schooling. Temperance clash, medium.",
				requires = { min = { temperance = 35 } },
				clash = { stat = "temperance", foe = "The examination paper", coins = 2, base = 4, coinPower = 3 },
				win = { career = "sluice", temperance = 2, log = "You answered every question, even the cruel one, and were sworn in as a Junior Clerk." },
				lose = { temperance = 1, sanity = -3, log = "You froze on the flooding question and handed in half a paper, promising yourself next year." },
			},
			{
				label = "Leave before it starts",
				result = { sanity = 1, log = "You walked out before the proctor turned the clock, and felt lighter on the stairs." },
			},
		},
	},
	{
		id = "job_recruit_choir",
		title = "A Seat by the Water",
		text = "At dusk the Choir of Still Water gathers on the old ferry steps, grey wool and unlit lanterns, facing the Mere. A Chorister makes room for you on the bottom step. \"Sit as long as you like,\" she says. \"The only rule is quiet.\"",
		cooldown = 5,
		tags = { "career", "recruit", "choir" },
		when = { minAge = 12, career = "none" },
		choices = {
			{
				label = "Take the seat and stay",
				hint = "Needs a patient mind.",
				requires = { min = { prudence = 25 } },
				result = { career = "choir", sanity = 4, log = "You sat with the Choir until the stars came out, and came back every night after." },
			},
			{
				label = "Sit a while, then go home",
				result = { prudence = 1, sanity = 2, log = "You sat with them for a while, then went home with your head pleasantly empty." },
			},
		},
	},

	-- Pumpworks (stoker) -----------------------------------------------------
	{
		id = "job_stoker_valve",
		title = "The Number Six Valve",
		text = "The Number Six valve is shuddering in its housing, and the pressure needle is creeping into the red. The Valve Keeper is two levels up and not answering the speaking tube. The whole boiler room is looking at you, and the floor is getting hot.",
		cooldown = 4,
		tags = { "career", "stoker", "danger" },
		when = { career = "stoker" },
		choices = {
			{
				label = "Bleed the valve by hand",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The Number Six valve", coins = 2, base = 4, coinPower = 3 },
				win = { paycheck = 0.25, sanity = 3, log = "You wrestled the valve open and bled the pressure off. The Chief Stoker bought you broth." },
				lose = {
					fortitude = { -10, -5 },
					sanity = -2,
					log = "The valve spat steam across your arms before it gave. You spent a month in bandages.",
					cause = "Scalded at the Pumpworks",
				},
			},
			{
				label = "Run for the Valve Keeper",
				result = { prudence = 2, log = "You took the stairs three at a time and dragged the Valve Keeper down by his sleeve." },
			},
			{
				label = "Clear the boiler room",
				result = { justice = 1, sanity = 1, log = "You cleared the boiler room, and when the valve blew, nobody was standing in front of it." },
			},
		},
	},
	{
		id = "job_stoker_walkout",
		title = "The Walkout",
		text = "An Ash Hand fainted at the coal chute yesterday, and the shift bosses docked his pay for the lost hour. Tonight the stokers are talking low around the boilers. If enough of you put your shovels down at dawn, the pumps stop, and the Terraces start getting wet.",
		cooldown = 8,
		tags = { "career", "stoker" },
		when = { career = "stoker", minAge = 16 },
		choices = {
			{
				label = "Put your shovel down with them",
				result = { justice = { 3, 4 }, money = { -20, -10 }, sanity = 2, log = "You put your shovel down at dawn. The bosses gave in by noon, and the boy got his hour back." },
			},
			{
				label = "Keep the fires fed",
				result = { paycheck = 0.15, justice = -1, sanity = -3, log = "You kept the fires fed through the walkout. The bosses paid extra, and the others stopped talking to you." },
			},
			{
				label = "Speak to the Chief Stoker",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The Chief Stoker", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 3, justice = 2, promote = true, log = "You talked the Chief round before dawn. The docked pay came back, and so did a promotion." },
				lose = { money = { -15, -5 }, sanity = -3, log = "The Chief heard you out, then docked your pay as well, for the cheek." },
			},
		},
	},
	{
		id = "job_stoker_old_chief",
		title = "The Old Chief",
		text = "Orrin Ashby has been Chief Stoker for thirty years and can tell a sick pump by the sound of its cough. He catches you listening to the Number Two boiler with your eyes closed. \"Good,\" he says. \"Most never learn to hear it. Come in early tomorrow.\"",
		once = true,
		tags = { "career", "stoker", "mentor" },
		when = { career = "stoker", minAge = 15, noRelation = "mentor", notFlags = { "guild_mentor" } },
		choices = {
			{
				label = "Come in early",
				result = {
					addRelation = { kind = "mentor", name = "Orrin Ashby", bond = 55, age = { 58, 68 } },
					fortitude = 2,
					temperance = { 2, 3 },
					log = "You came in early every day for a year, and {newRelation} taught you the voice of every pump.",
				},
			},
			{
				label = "Keep to yourself",
				result = { prudence = 1, log = "You kept your head down and your shovel moving, and Ashby left you alone." },
			},
		},
	},

	-- Lantern Guild (diver) --------------------------------------------------
	{
		id = "job_diver_mentor",
		title = "The Lantern Who Watched",
		text = "Hesper Coldwater is a Lantern of the Guild, with rope calluses thick as boot leather and forty years of dives behind her. She has been watching you come up from the water all season. \"You panic quietly,\" she says. \"That's the good kind. Dive with me.\"",
		once = true,
		weight = 12,
		tags = { "career", "diver", "mentor", "thread_mentor" },
		when = { career = "diver", noRelation = "mentor", notFlags = { "guild_mentor" } },
		choices = {
			{
				label = "Dive on her rope",
				result = {
					addRelation = { kind = "mentor", name = "Hesper Coldwater", bond = 55, age = { 50, 62 } },
					justice = 2,
					setFlags = { "guild_mentor" },
					schedule = { event = "job_diver_lesson", inYears = 2 },
					log = "You started diving on {newRelation}'s rope, and she started correcting everything you did.",
				},
			},
			{
				label = "Keep diving alone",
				result = { prudence = 1, sanity = -1, log = "You thanked Hesper and kept diving alone. She watched you come up, every time." },
			},
		},
	},
	{
		id = "job_diver_lesson",
		title = "Reading the Dark",
		text = "Hesper Coldwater takes you down Chandlers' Row without a lantern. In the black water she taps your shoulder: once for left, twice for down, three times for still. Something long and pale slides past, a hand's width from your face, and keeps on going.",
		weight = 0,
		once = true,
		tags = { "career", "diver", "mentor", "thread_mentor" },
		when = { hasRelation = "mentor" },
		choices = {
			{
				label = "Stay perfectly still",
				hint = "Prudence clash, medium.",
				requires = { career = "diver" },
				clash = { stat = "prudence", foe = "Something long and pale", coins = 2, base = 4, coinPower = 3 },
				win = {
					prudence = 3,
					justice = 3,
					promote = true,
					relationBond = { kind = "mentor", amount = 10 },
					schedule = { event = "job_diver_line_slack", inYears = 3 },
					log = "You stayed still until it passed. Hesper told the Guild you were ready, and they agreed.",
				},
				lose = {
					fortitude = { -8, -4 },
					sanity = -4,
					relationBond = { kind = "mentor", amount = 4 },
					schedule = { event = "job_diver_line_slack", inYears = 3 },
					log = "You flinched, it bit, and Hesper hauled you up the rope by your belt.",
					cause = "Bitten in Chandlers' Row",
				},
			},
			{
				label = "Signal to go up",
				result = {
					sanity = 1,
					relationBond = { kind = "mentor", amount = 2 },
					schedule = { event = "job_diver_line_slack", inYears = 3 },
					log = "You signaled up, and Hesper took you back to the surface without a word of complaint.",
				},
			},
		},
	},
	{
		id = "job_diver_line_slack",
		title = "The Rope Comes Up",
		text = "Word comes up the Guild pier at dusk. Hesper Coldwater went down alone into the deep end of Chandlers' Row this morning, chasing a rumor of the old Mint. Her rope came up an hour ago with nothing on the end of it. A lantern goes down, a lantern comes up.",
		weight = 0,
		once = true,
		tags = { "career", "diver", "mentor", "thread_mentor" },
		when = { hasRelation = "mentor" },
		choices = {
			{
				label = "Go down after her",
				hint = "Justice clash, hard. The deep end is no place to go alone.",
				clash = { stat = "justice", foe = "The deep end of Chandlers' Row", coins = 3, base = 6, coinPower = 3 },
				win = {
					justice = { 3, 5 },
					sanity = 5,
					relationBond = { kind = "mentor", amount = 20 },
					clearFlags = { "guild_mentor" },
					setFlags = { "mentor_saved" },
					log = "You found Hesper in an air pocket under the Mint's roof and brought her up with her lantern lit.",
				},
				lose = {
					fortitude = { -12, -6 },
					sanity = -8,
					killRelation = "mentor",
					clearFlags = { "guild_mentor" },
					setFlags = { "mentor_lost" },
					log = "You searched until your own lamp failed and came up alone. Hesper's lantern never did.",
					cause = "Lost searching Chandlers' Row",
				},
			},
			{
				label = "Keep a lantern lit on the pier",
				result = {
					prudence = 2,
					sanity = -6,
					killRelation = "mentor",
					clearFlags = { "guild_mentor" },
					setFlags = { "mentor_lost" },
					log = "You kept a lantern burning at the end of the pier all night. Hesper's never came up.",
				},
			},
		},
	},
	{
		id = "job_diver_lamp_eaters",
		title = "Lamps Going Out",
		text = "Forty feet down in the drowned market, your lantern starts to dim, though the oil is full. Then the lanterns of the divers around you go out one by one, like someone walking along a row of candles. Something down here is eating the light.",
		cooldown = 4,
		tags = { "career", "diver", "lamp_eaters", "danger" },
		when = { career = "diver" },
		choices = {
			{
				label = "Shutter your lamp and climb blind",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Lamp-eaters", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 3, sanity = 2, paycheck = 0.2, log = "You shuttered your lamp, climbed the rope by feel, and brought two lost divers up with you." },
				lose = { fortitude = { -5, -2 }, sanity = { -8, -4 }, log = "You climbed blind with something brushing your face the whole way. You still dream about it." },
			},
			{
				label = "Swing your lantern at them",
				hint = "Justice clash, hard.",
				clash = { stat = "justice", foe = "Lamp-eaters", coins = 3, base = 6, coinPower = 3 },
				win = { justice = 4, sanity = -2, money = { 30, 80 }, log = "You swung your lantern through them until they scattered, then finished the salvage alone." },
				lose = {
					fortitude = { -12, -6 },
					sanity = -6,
					log = "They swarmed the light and snuffed it, and you came up the rope half drowned.",
					cause = "Lost in the dark with the lamp-eaters",
				},
			},
			{
				label = "Drop the salvage and surface",
				result = { fortitude = { -4, -2 }, sanity = -2, log = "You dropped your salvage bag and surfaced fast, and your ears rang for a week." },
			},
		},
	},
	{
		id = "job_diver_set_table",
		title = "A Table Still Set",
		text = "Behind a drowned door on Lamplighters' Street you find a dining room still laid for dinner: six places, silver gone green, a tureen with its lid on. The chairs are pushed back as if everyone stood up at once. Nothing has touched it in a hundred years.",
		cooldown = 5,
		tags = { "career", "diver", "drowned_city" },
		when = { career = "diver" },
		choices = {
			{
				label = "Bag the silver",
				result = { money = { 60, 140 }, sanity = -4, log = "You bagged the silver and sold it on the Rim. The six empty chairs followed you for weeks." },
			},
			{
				label = "Lift the tureen lid",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "What waits under the lid", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, money = { 20, 50 }, log = "Under the lid was a sealed book of names, and the Choir paid you well to bury it." },
				lose = { sanity = { -10, -6 }, log = "Under the lid was only water, black and very still, and it looked back at you." },
			},
			{
				label = "Leave it as you found it",
				result = { prudence = 2, sanity = 2, log = "You closed the drowned door gently and marked the house on your chart as taken." },
			},
		},
	},
	-- Sluice Authority -------------------------------------------------------
	{
		id = "job_sluice_flood_order",
		title = "The Flood Order",
		text = "A flood order lands on your desk with three signatures already on it. At the next High Water, Gate Nine opens and the Brackwater Steps take the overflow so the Terraces markets stay dry. Four hundred Silt addresses are listed. Yours is the last stamp it needs.",
		cooldown = 5,
		tags = { "career", "sluice" },
		when = { career = "sluice" },
		choices = {
			{
				label = "Stamp it",
				result = { paycheck = 0.2, justice = -2, sanity = { -6, -3 }, log = "You stamped the order and filed it. The four hundred addresses followed you home." },
			},
			{
				label = "Misfile it",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "The Gatewarden", coins = 2, base = 5, coinPower = 3 },
				win = { justice = 4, sanity = 3, log = "You filed the order under a long-dead commissioner's name, and nobody found it for years." },
				lose = { justice = 2, money = { -40, -20 }, sanity = -2, log = "The Gatewarden found the order in your drawer and docked your pay for it." },
			},
			{
				label = "Warn the Brackwater Steps",
				result = { justice = { 3, 4 }, prudence = -1, sanity = 2, log = "You copied the addresses and slipped them under the door of the Brackwater Steps chapel." },
			},
		},
	},
	{
		id = "job_sluice_bribe",
		title = "An Envelope from the Rim",
		text = "A Rim steward in a beautiful coat leaves an envelope on your desk and does not sit down. Inside are two hundred {currency} and a gate schedule with one line changed in pencil. If Gate Four opens a day late, his employer's cellars stay dry and a Terraces street floods.",
		once = true,
		tags = { "career", "sluice", "thread_bribe" },
		when = { career = "sluice" },
		choices = {
			{
				label = "Pocket it and change the line",
				result = {
					money = 200,
					justice = -4,
					sanity = -3,
					setFlags = { "took_gate_bribe" },
					schedule = { event = "job_sluice_audit", inYears = 3 },
					log = "You changed the line in your best handwriting and slid the envelope into your coat.",
				},
			},
			{
				label = "Hand it up the chain",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Office politics", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, promote = true, log = "You handed the envelope up the chain, and the chain was grateful. You were promoted within the season." },
				lose = { justice = 1, sanity = -3, log = "Your superior pocketed the envelope himself and moved you to a desk beside the drains." },
			},
			{
				label = "Send it back untouched",
				result = { justice = 2, log = "You returned the envelope with the schedule untouched and a very polite note." },
			},
		},
	},
	{
		id = "job_sluice_audit",
		title = "The Auditors Arrive",
		text = "Three years after the envelope, the Authority's auditors come calling with a cart of ledgers and no appointment. They are working backward through every gate schedule ever changed in pencil. They are very thorough, and they have found yours.",
		weight = 0,
		once = true,
		tags = { "career", "sluice", "thread_bribe" },
		choices = {
			{
				label = "Confess and resign",
				requires = { career = "sluice" },
				result = {
					quitCareer = true,
					money = { -150, -100 },
					justice = 3,
					sanity = 2,
					clearFlags = { "took_gate_bribe" },
					log = "You confessed, paid back what you could, and walked out of the Authority with your name.",
				},
			},
			{
				label = "Bluff it out",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The Authority auditors", coins = 3, base = 6, coinPower = 3 },
				win = { prudence = 3, clearFlags = { "took_gate_bribe" }, log = "You met every question with a dull, correct answer until the auditors moved on, bored." },
				lose = {
					money = { -200, -120 },
					justice = -2,
					sanity = -6,
					clearFlags = { "took_gate_bribe" },
					setFlags = { "sluice_marked" },
					log = "The auditors matched your pencil to your pen and fined you deep into the red.",
				},
			},
			{
				label = "Pay it back quietly",
				result = { money = { -220, -200 }, sanity = -2, clearFlags = { "took_gate_bribe" }, log = "You paid the envelope back with interest, and the auditors closed the file without a word." },
			},
		},
	},
	{
		id = "job_sluice_gate_jam",
		title = "Gate Nine Sticks",
		text = "A storm is pushing the Mere up the Brackwater Steps, and Gate Nine has jammed halfway, its great iron teeth grinding on a drowned tram car. The engineers are arguing over blueprints older than they are. From the gallery, you can see exactly what's wrong.",
		cooldown = 5,
		tags = { "career", "sluice", "danger" },
		when = { career = "sluice" },
		choices = {
			{
				label = "Climb down and free it",
				hint = "Temperance clash, medium-hard.",
				clash = { stat = "temperance", foe = "Gate Nine", coins = 2, base = 5, coinPower = 3 },
				win = { temperance = 3, sanity = 2, promote = true, log = "You talked the crane crew through it and freed the gate by hand. The Authority promoted you." },
				lose = {
					fortitude = { -9, -4 },
					sanity = -2,
					log = "The tram car shifted while you were standing on it, and you rode it into the floodwater.",
					cause = "Lost at Gate Nine",
				},
			},
			{
				label = "Point it out to the engineers",
				result = { prudence = 1, justice = 1, log = "You pointed out the tram car, and an engineer took the credit with a grateful nod." },
			},
			{
				label = "Write a careful report",
				result = { temperance = 1, sanity = -1, log = "You wrote a careful report. Somebody read it the week after the storm passed." },
			},
		},
	},

	-- Brine Kin ----------------------------------------------------------------
	{
		id = "job_brine_night_run",
		title = "The Night Run",
		text = "Tonight's run is twelve crates of untaxed lamp oil, rowed under the viaduct, through the drowned Exchange and up to a Terraces warehouse before dawn. Sluice patrol boats are out, sweeping the water with their big lamps. Your oarlocks are wrapped in rag to keep them quiet.",
		cooldown = 3,
		tags = { "career", "brine" },
		when = { career = "brine" },
		choices = {
			{
				label = "Slip past the patrol",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Sluice patrol boat", coins = 2, base = 4, coinPower = 3 },
				win = { paycheck = 0.3, prudence = 2, sanity = 1, log = "You slid under the patrol lamps like a shadow and delivered every crate dry." },
				lose = { money = { -40, -15 }, fortitude = { -6, -2 }, sanity = -2, log = "A patrol lamp caught you, so you dumped the crates and swam home through the Exchange." },
			},
			{
				label = "Take the long way through the Quiet",
				result = { paycheck = 0.3, sanity = { -6, -3 }, log = "You took the long way, past the shapes standing in the deep water. None of them moved." },
			},
			{
				label = "Wait for proper fog",
				result = { paycheck = 0.1, prudence = 1, log = "You waited three nights for proper fog and made the run late, but safe." },
			},
		},
	},
	{
		id = "job_brine_collection",
		title = "Collecting for the Ledger",
		text = "The Ledger-hand sends you to collect from a net-mender on Gull Steps who owes the Kin thirty {currency}. Her stilt-house is one room. Her grandson is asleep under the nets. She has the thirty in a jar, and it is clearly everything she has.",
		cooldown = 5,
		tags = { "career", "brine" },
		when = { career = "brine" },
		choices = {
			{
				label = "Take the jar",
				result = { money = { 5, 10 }, justice = -3, sanity = -4, log = "You took the jar. She thanked you for being gentle about it, which was worse." },
			},
			{
				label = "Pay it from your own pocket",
				hint = "30 scrip.",
				requires = { min = { money = 30 } },
				result = { money = -30, justice = 3, sanity = 3, log = "You paid her thirty yourself and told the Ledger-hand she had paid in full." },
			},
			{
				label = "Cook the ledger",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The Ledger-hand's eye", coins = 2, base = 4, coinPower = 3 },
				win = { temperance = 3, justice = 2, sanity = 2, log = "You rewrote her page so neatly that the debt seemed to have been paid last spring." },
				lose = { money = { -30, -15 }, sanity = -3, log = "The Ledger-hand spotted the fresh ink and took the thirty out of your share instead." },
			},
		},
	},
	{
		id = "job_brine_other_family",
		title = "Another Family's Boat",
		once = true,
		text = "A boat from the Brackwater family is working your cousins' stretch of the drowned streets, bold as brass, under a green lantern. Their oarsman, Kell Brackwater, is younger than you and grinning. He raises an oar in greeting, which is not friendly at all.",
		tags = { "career", "brine", "rival" },
		when = { career = "brine" },
		choices = {
			{
				label = "Run them off the stretch",
				hint = "Justice clash, medium-hard.",
				clash = { stat = "justice", foe = "Brackwater boat crew", coins = 2, base = 5, coinPower = 3 },
				win = {
					justice = { 3, 4 },
					paycheck = 0.2,
					addRelation = { kind = "rival", name = "Kell Brackwater", bond = 15, age = { 16, 24 } },
					log = "You ran the Brackwater boat off your stretch, and {newRelation} shouted that he'd remember your face.",
				},
				lose = {
					fortitude = { -10, -5 },
					sanity = -3,
					addRelation = { kind = "rival", name = "Kell Brackwater", bond = 20, age = { 16, 24 } },
					log = "{newRelation}'s crew tipped you into the water and towed your boat away for a laugh.",
					cause = "Caught under the viaduct",
				},
			},
			{
				label = "Share the stretch and split the take",
				result = {
					prudence = 2,
					paycheck = 0.1,
					addRelation = { kind = "friend", name = "Kell Brackwater", bond = 35, age = { 16, 24 } },
					log = "You split the salvage with {newRelation}'s boat and found he told good stories.",
				},
			},
			{
				label = "Report it to the Elder Kin",
				result = { prudence = 1, sanity = -1, log = "You told the Elder Kin, who said they would handle it. You never asked how." },
			},
		},
	},

	-- Choir of Still Water -----------------------------------------------------
	{
		id = "job_choir_long_silence",
		title = "The Long Silence",
		text = "The Still Voice calls a long silence: three days on the ferry steps with no speaking, a bowl of broth at dusk, and the Mere breathing in front of you. On the second night, very faintly, from somewhere under the water, you hear a bell.",
		cooldown = 5,
		tags = { "career", "choir" },
		when = { career = "choir" },
		choices = {
			{
				label = "Keep the silence to the end",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The long silence", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = { 3, 4 }, sanity = 4, promote = true, log = "You kept the silence for three days, and the Still Voice raised you a rank without a word." },
				lose = { sanity = { -8, -4 }, log = "By the third morning you were talking to the bell, and the Choristers led you home." },
			},
			{
				label = "Whisper to the Chorister beside you",
				result = { justice = 1, sanity = 1, log = "You whispered about the bell to the Chorister beside you. She nodded as if she knew." },
			},
			{
				label = "Slip away at midnight",
				result = { prudence = -1, sanity = 2, log = "You slipped off the steps at midnight and ate kelp buns in a doorway, ashamed and happy." },
			},
		},
	},
	{
		id = "job_choir_drowned_hymn",
		title = "The Drowned Hymn",
		text = "A Cantor wakes you before dawn. For nine nights the Choir has heard singing under the Mere, a hymn nobody has sung in two hundred years. She presses a pencil and a stack of damp paper into your hands. \"Write down what you hear.\"",
		cooldown = 6,
		tags = { "career", "choir", "drowned_city" },
		when = { career = "choir", minRank = 2 },
		choices = {
			{
				label = "Write down the hymn",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The drowned hymn", coins = 2, base = 4, coinPower = 3 },
				win = { temperance = 3, sanity = 2, paycheck = 0.25, log = "You wrote down every note, and the Choir sang it on the ferry steps for the first time in centuries." },
				lose = { temperance = 1, sanity = { -7, -3 }, log = "The notes kept changing as you wrote, and your pages filled up with tide tables." },
			},
			{
				label = "Cover your ears",
				result = { prudence = -1, sanity = 1, log = "You put your hands over your ears and went back to sleep. The singing did not stop." },
			},
		},
	},
	{
		id = "job_choir_vigil",
		title = "Sitting with the Family",
		text = "A Silt family asks the Choir to sit with them. Their son went out on a salvage raft three days ago and hasn't come back. All they ask is someone on their walkway to watch the water with them, so they don't have to watch it alone.",
		cooldown = 5,
		tags = { "career", "choir", "silt" },
		when = { career = "choir" },
		choices = {
			{
				label = "Sit the night with them",
				result = {
					prudence = 2,
					justice = 2,
					sanity = -2,
					addRelation = { kind = "friend", bond = 45, age = { 16, 30 } },
					log = "You sat all night on the family's walkway. In the morning, {newRelation} brought you broth.",
				},
			},
			{
				label = "Row out and search",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The open Mere", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 4, sanity = 5, log = "You found the boy clinging to a drowned chimney at dawn and rowed him home." },
				lose = { fortitude = { -7, -3 }, sanity = -4, log = "You searched until the oars blistered your hands and came back with nothing." },
			},
		},
	},
}
