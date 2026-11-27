--[[
	Adult fights (ad_f_): the fight screen, a real foe, and real stakes on both sides.
	Numbers follow docs/V08_SPEC.md: medium 2/4/3, hard 3/5/3, deadly 3/6/4, boss 4/7/4.
	A lost fight costs Health {-14,-6} to {-24,-12}. Every fight has a way out that isn't one.
	Follow-ups from Adult_City.luau: ad_f_hounds_visit (the Copper Hounds), ad_f_clan_window
	(the Kurokumo find the camera). Faces: Cast/Adults.luau.
]]

local AFTER = { era = { "library", "limbus" } }

return {
	-- ── follow-ups ──
	{
		id = "ad_f_hounds_visit",
		title = "Late Fee",
		art = "home",
		text = "Two Copper Hounds are waiting on your landing with a pipe each and a copy of the ledger. Your name has a little dog drawn next to it.",
		weight = 0,
		tags = { "crime" },
		when = { flags = { "ad_hounds_defied" } },
		dialogue = {
			{ who = "syndicate", line = "Jefe says refusing is a kind of payment. She's come round to wanting the other kind." },
		},
		choices = {
			{
				label = "Fight them on the stairs",
				clash = { stat = "strength", foe = "Two Copper Hounds", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "syndicate", status = { id = "tremor", potency = 2 } },
				win = { strength = 3, money = { 40, 90 }, setFlags = { "ad_hounds_beaten" }, log = "They went down the stairs faster than they came up. Amparo crossed out the little dog and drew a bigger one." },
				lose = { health = { -14, -6 }, money = { -120, -60 }, sanity = -4, cause = "Refused the Copper Hounds", log = "They collected the late fee, and your door with it." },
			},
			{
				label = "Pay double",
				result = { money = { -140, -100 }, clearFlags = { "ad_hounds_defied" }, setFlags = { "ad_hounds_paid" }, log = "You paid double. They thanked you and corrected the ledger with a little copper pen." },
			},
			{
				label = "Give them the baker's till",
				result = { money = { -40, -20 }, sanity = -7, clearFlags = { "ad_hounds_defied" }, setFlags = { "ad_sold_baker", "ad_hounds_paid" }, log = "You told them where the baker kept his second till. They left you alone that year. The baker stopped opening on Tuesdays." },
			},
		},
	},
	{
		id = "ad_f_clan_window",
		title = "They Saw the Lens",
		art = "home",
		text = "The Kurokumo tea house knows which window the camera was in. A Wakashu with a long sheathed sword is sitting on your stairs, sharpening nothing.",
		weight = 0,
		tags = { "crime" },
		when = { flags = { "ad_window_rented" } },
		codex = "fn_lore_kurokumo",
		dialogue = {
			{ who = "kurokumo", line = "Three of ours lost their Hana grades. Somebody lent a camera a window. The Captain wants to meet the window." },
		},
		choices = {
			{
				label = "Fight him on the stairs",
				clash = { stat = "strength", foe = "A Kurokumo Wakashu", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "kurokumo", status = { id = "bleed", potency = 2 } },
				win = { strength = 3, money = { 80, 160 }, sanity = -3, log = "He drew first. You were still standing after. You sold his scabbard to a Workshop and moved to a back room." },
				lose = { health = { -18, -8 }, sanity = -6, cause = "Owned the wrong window", log = "The Wakashu sheathed his sword and stepped over you. The Captain sent flowers to the clinic. White ones." },
			},
			{
				label = "Blame Hana's Assessor",
				result = { sanity = -5, log = "You said a Hana Assessor rented it and you'd had no say. True, mostly. The Clan went to visit Imre. She had already moved." },
			},
			{
				label = "Pay the Clan's fee",
				result = { money = { -250, -150 }, sanity = -2, log = "You paid what he named. He bowed, which the Clan only does after money. You paid it on time every month after that." },
			},
		},
	},

	-- ── the street ──
	{
		id = "ad_f_last_tram",
		title = "Last Tram",
		art = "train",
		text = "Three men get on the last tram before midnight and stand at both doors. One starts at the front with an open sack, row by row.",
		weight = 9,
		cooldown = 8,
		tags = { "danger" },
		when = { minAge = 18, maxAge = 40, side = "backstreets" },
		choices = {
			{
				label = "Fill the sack",
				result = { money = { -90, -40 }, sanity = -3, log = "You put your wallet in the sack. The man said thank you. They got off at the canal, and the driver never turned round." },
			},
			{
				label = "Stop him at your row",
				clash = { stat = "strength", foe = "Tram robbers", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "thug", status = { id = "tremor", potency = 2 } },
				win = { strength = 3, money = { 60, 140 }, log = "He went over the seat-back and the other two went out the doors. The passengers pressed more on you than you'd have lost." },
				lose = { health = { -14, -6 }, money = { -120, -60 }, sanity = -4, cause = "Fought robbers on the last tram", log = "You woke at the depot with no wallet. The driver asked if you wanted a ticket for the morning." },
			},
			{
				label = "Pull the emergency brake",
				clash = { stat = "strength", foe = "A tram at full speed", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 1, sanity = 2, log = "The brake threw everyone off their feet, robbers included. You were first out of the door and first to the Zwei post." },
				lose = { health = { -10, -4 }, sanity = -3, cause = "Pulled the brake on the last tram", log = "The brake threw you into the pole. The robbers helped you up and took your wallet. One of them said thank you." },
			},
		},
	},
	{
		id = "ad_f_kurokumo_toll",
		title = "The Clan's Toll",
		art = "street",
		text = "You're pushing a handcart of stock down Sakura Lane, which belongs to the Kurokumo Clan. A Wakashu with a long sheathed sword steps into the road and names a toll.",
		weight = 9,
		cooldown = 8,
		tags = { "crime" },
		when = { minAge = 18, maxAge = 40, flags = { "knows_fingers" } },
		codex = "fn_lore_kurokumo",
		dialogue = {
			{ who = "kurokumo", line = "A tenth of the cart. Or the whole cart, and you, if you'd rather argue." },
		},
		choices = {
			{
				label = "Pay a tenth",
				result = { money = { -60, -30 }, sanity = -2, log = "He counted it carefully and stood aside with a bow. The toll was a tenth higher the next month." },
			},
			{
				label = "Push past him",
				clash = { stat = "strength", foe = "A Kurokumo Wakashu", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "kurokumo", status = { id = "bleed", potency = 2 } },
				win = { strength = 3, money = { 80, 180 }, sanity = -3, log = "You put the cart between you and him, and the cart won. Nobody on Sakura Lane named a toll to you that year." },
				lose = { health = { -18, -8 }, money = { -150, -80 }, cause = "Didn't pay the Clan's toll", log = "The Clan took the whole cart, as promised. They left you behind as an afterthought." },
			},
			{
				label = "Go the long way round",
				clash = { stat = "health", foe = "Six hills with a full cart", coins = 2, base = 4, coinPower = 3 },
				win = { health = 2, log = "Six hills took two hours, and you paid no toll. Your arms shook all evening." },
				lose = { health = { -8, -4 }, money = { -60, -30 }, cause = "Pushed a cart over six hills", log = "Halfway up the fourth hill the cart got away from you. Half your stock reached the bottom first." },
			},
		},
	},
	{
		id = "ad_f_inquisitor",
		title = "The Hammer's Knock",
		art = "street",
		text = "A man in a hooded robe with a small hammer on his belt is going door to door. He wants the flat of the Workshop man next to you, the one with the brass leg.",
		weight = 9,
		once = true,
		when = { minAge = 35, maxAge = 55, district = "d14", flags = { "knows_wings" } },
		dialogue = {
			{ who = "inquisitor", line = "Impurity is a mercy to remove. I only want the leg. He will thank us, after." },
		},
		choices = {
			{
				label = "Point at his door",
				result = { sanity = -8, log = "You pointed. The knocking next door went on a long time. He used a crutch after that, and never said good morning again." },
			},
			{
				label = "Say he moved away",
				clash = { stat = "mind", foe = "An Inquisitor's list", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "You said he'd moved to District 4. The Inquisitor crossed out a line and thanked you for your purity." },
				lose = { sanity = -5, log = "He checked the mailbox. The name was on it. He thanked you for your time and knocked next door." },
			},
			{
				label = "Stand in the hall",
				clash = { stat = "strength", foe = "A Kleinhammer Inquisitor", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "inquisitor", status = { id = "bleed", potency = 2 } },
				win = { strength = 3, money = { 40, 100 }, sanity = -2, log = "He went down the stairs hammer first. The man with the brass leg made you a new hinge for your door. It still works." },
				lose = { health = { -18, -8 }, sanity = -5, cause = "Stood between an Inquisitor and his list", log = "He was stronger than a small hammer looks. He thanked you for the exercise on his way past." },
			},
		},
	},
	{
		id = "ad_f_liu_sparring",
		title = "Three Minutes",
		art = "arena",
		text = "A Liu Fixer with a red braid and a gauntlet is offering a hundred and fifty Ahn to anyone on the street who can stay on their feet for three minutes. Her Section is bored, and so is she.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 32, flags = { "knows_fixers" } },
		codex = "fx_lore_liu",
		dialogue = {
			{ who = "liu_fixer", line = "Three minutes! Nobody's made two today. Come on. I'll only use one hand. The left one." },
		},
		choices = {
			{
				label = "Step into the circle",
				clash = { stat = "strength", foe = "A Liu Fixer, Section Six", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "liu_fixer", status = { id = "burn", potency = 2 } },
				win = { strength = 3, money = 150, mastery = 1, log = "Three minutes and change. She laughed and paid up, then spent an hour showing you what you'd done wrong, for free." },
				lose = { health = { -16, -8 }, sanity = -3, condition = "burns", cause = "Sparred with the Liu Association", log = "Two minutes and eleven seconds. She helped you up and said it was the best two minutes of her week." },
			},
			{
				label = "Ask her to teach you",
				clash = { stat = "intelligence", foe = "Liu footwork", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, mastery = 1, log = "She showed you the step that lets you face three people at once. You practiced it on your landing for a month." },
				lose = { health = -3, sanity = -2, log = "You fell over your own feet in the first step. Her whole Section clapped, warmly." },
			},
			{
				label = "Hold the coats",
				result = { money = 20, sanity = 2, log = "You held the coats and watched six people try. The Section fed everyone afterwards from a pot the size of a bath." },
			},
		},
	},
	{
		id = "ad_f_rat_tunnel",
		title = "The Underpass Toll",
		art = "underpass",
		text = "The underpass is the only way to work that doesn't add an hour. This month a Rat boss with a sledge has set up a toll in the middle of it, with a chair.",
		weight = 9,
		once = true,
		tags = { "danger", "backstreets" },
		when = { minAge = 18, maxAge = 35, side = "backstreets", flags = { "knows_syndicates" } },
		codex = "fn_lore_rats",
		dialogue = {
			{ who = "rat_boss", line = "Morning! Five Ahn for the tunnel. Ten if you look at the chair. It's a good chair." },
		},
		choices = {
			{
				label = "Pay the toll every day",
				result = { money = { -80, -50 }, sanity = -3, log = "You paid every morning for a month. He learned your name and started saying good morning. That was the worst part." },
			},
			{
				label = "Kick the chair over",
				clash = { stat = "strength", foe = "A Rat boss and his sledge", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "rat_boss", status = { id = "tremor", potency = 2 } },
				win = { strength = 3, money = { 60, 150 }, chronicle = "bs_act_rats_broken", log = "He went down on his own chair and the Rats scattered into the drains. The underpass was free by evening, and so was his toll jar." },
				lose = { health = { -18, -8 }, sanity = -4, cause = "Fought a Rat boss in the underpass", log = "The sledge was quicker than it looked. They left you sitting in the chair, as a sign." },
			},
			{
				label = "Go the long way",
				result = { health = -2, sanity = -2, log = "You added an hour each way all season. You learned every dog on the long road by name." },
			},
		},
	},
	{
		id = "ad_f_beast_outskirts",
		title = "Past the Last Wall",
		art = "outskirts",
		text = "A courier route pays triple for a run to a village past the last wall: two hours of rubble under a sky the wrong color. Something has been following the cart for the last mile.",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { minAge = 35, maxAge = 55 },
		codex = "dz_lore_outskirts",
		choices = {
			{
				label = "Turn and face it",
				clash = { stat = "strength", foe = "Something from the Outskirts", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "beast", status = { id = "bleed", potency = 2 } },
				win = { strength = 4, money = { 150, 300 }, setFlags = { "ad_outskirts_run" }, log = "It was bigger than the cart and far less patient. You came back through the wall with the delivery made and a tooth as long as your hand." },
				lose = { health = { -24, -12 }, sanity = -8, cause = "Killed past the last wall", log = "The villagers found you at the edge of their fields and carried you in. They kept the delivery, as payment." },
			},
			{
				label = "Whip the cart and run",
				clash = { stat = "speed", foe = "The last mile", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 80, 160 }, sanity = -4, log = "You ran the last mile flat out. The village gate slammed behind you. Whatever it was sat outside till morning." },
				lose = { health = { -14, -6 }, money = { -80, -40 }, cause = "Ran from something past the last wall", log = "The cart lost a wheel at the gate. You got in. The cart didn't." },
			},
			{
				label = "Cut the cargo loose",
				result = { money = { -150, -80 }, sanity = -2, log = "You cut the crates loose and drove. It stopped to sniff them. You'd delivered nothing, and you were alive." },
			},
		},
	},
	{
		id = "ad_f_pigeon_roof",
		title = "The Pigeon Keeper's Roof",
		art = "rooftop",
		text = "Carrion crows have found the pigeon coop on your roof. The Pigeon Keeper is up there in his slippers swinging a broom, and there are a lot more crows than broom.",
		weight = 8,
		once = true,
		when = { minAge = 18, maxAge = 50 },
		dialogue = {
			{ who = "pigeon_keeper", line = "They're after the squabs! Don't just stand there, you've got arms!" },
		},
		choices = {
			{
				label = "Grab the other broom",
				clash = { stat = "strength", foe = "A flock of carrion crows", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "crow", status = { id = "bleed", potency = 1 } },
				win = { strength = 2, money = 40, sanity = 4, log = "The crows went screaming off toward the WARP rail. He paid you in squab feathers, then in Ahn when you looked at him." },
				lose = { health = { -14, -6 }, sanity = -4, cause = "Fought crows on the roof", log = "The crows held the roof for the afternoon. You lost a hat and most of your dignity." },
			},
			{
				label = "Drum on the water tank",
				clash = { stat = "mind", foe = "Birds with good memories", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "You drummed on the tank like the morning bell. Every crow on the block left at once. So did the pigeons, for a day." },
				lose = { sanity = -3, log = "The crows enjoyed the drumming. They stayed for the whole concert." },
			},
			{
				label = "Fetch him downstairs",
				result = { sanity = -3, log = "You walked him down by the elbow while he told you exactly what he thought of you. The coop was empty by evening." },
			},
		},
	},
	{
		id = "ad_f_sweeper_late",
		title = "3:14",
		art = "night",
		text = "Your key snapped in the lock at 3:12. Now it's 3:14 and the street is red. At the far end something tall is moving the way water moves.",
		weight = 6,
		cooldown = 15,
		tags = { "danger", "backstreets" },
		when = { minAge = 18, maxAge = 60, side = "backstreets", flags = { "knows_night" } },
		codex = "city_sweepers",
		choices = {
			{
				label = "Hold the doorstep",
				clash = { stat = "strength", foe = "A Sweeper", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "sweeper", status = { id = "sinking", potency = 2 } },
				win = { strength = 4, sanity = -8, setFlags = { "bs_night_survivor" }, addTrait = "survivor_of_the_night", chronicle = "bs_act_night_walk", log = "It went back into the street in pieces that got up again. In the first quiet you went in through the window, and shook until noon." },
				lose = { health = { -24, -12 }, sanity = -10, cause = "Swept in the Night", log = "The third wave found you on the step. A neighbor dragged you in through a window. Nobody will say which one." },
			},
			{
				label = "Climb to the ledge",
				clash = { stat = "health", foe = "A wet ledge at 3:14", coins = 3, base = 5, coinPower = 3 },
				win = { health = 2, sanity = -6, setFlags = { "bs_night_survivor" }, log = "You hung on the ledge for eighty minutes while it searched below. Your arms gave out at 4:34, onto a quiet street." },
				lose = { health = { -16, -8 }, sanity = -6, condition = "broken_arm", cause = "Fell from a ledge in the Night", log = "You fell at 4:20. It had gone by then. Your arm hadn't." },
			},
			{
				label = "Knock on Mrs. Baek's door",
				clash = { stat = "mind", foe = "A neighbor who knows the rules", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -2, setFlags = { "bs_night_survivor" }, log = "You said the right words through the door and Mrs. Baek let you in at 3:15. Neither of you has mentioned it since." },
				lose = { health = { -14, -6 }, sanity = -10, cause = "Locked out in the Night", log = "Nobody opens at 3:14. You knew that. You spent the Night under the stairs, holding your breath at every wave." },
			},
		},
	},
	{
		id = "ad_f_breach",
		title = "Something From the Facility",
		art = "lcorp",
		text = "Every streetlight on your block flickers green at once. At the end of the road, something that was in an L Corp unit this morning is standing very still, listening.",
		weight = 6,
		once = true,
		tags = { "danger" },
		when = { minAge = 20, maxAge = 50, district = "d12", world = { era = "wings" }, flags = { "knows_lcorp" } },
		codex = "lc_lore_suppression",
		dialogue = {
			{ who = "lcorp_agent", line = "Civilian! Get indoors! No, wait. You. Can you hold a baton?" },
		},
		choices = {
			{
				label = "Take the baton",
				clash = { stat = "strength", foe = "An escaped Abnormality", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "abnormality", status = { id = "sinking", potency = 2 } },
				win = { strength = 4, money = { 150, 300 }, setFlags = { "saw_abnormality" }, chronicle = "fought_abnormality", log = "You held the corner until Suppression arrived. L Corp paid you, and asked you to sign a page about forgetting." },
				lose = { health = { -24, -12 }, sanity = -10, setFlags = { "saw_abnormality" }, cause = "Held a street against an Abnormality", log = "It looked at you, and you forgot how to stand. The Agent dragged you behind a cart and went back alone." },
			},
			{
				label = "Get people indoors",
				clash = { stat = "mind", foe = "A street full of panic", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = -2, setFlags = { "saw_abnormality" }, log = "You got the noodle stall and the whole bus queue into the bathhouse. Nobody looked out. Nobody needed to." },
				lose = { sanity = -8, condition = "lc_shaken", setFlags = { "saw_abnormality" }, log = "You looked at it while you were shouting. Only once. Once was enough to stay with you." },
			},
			{
				label = "Run",
				result = { sanity = -5, setFlags = { "saw_abnormality" }, log = "You ran. Everyone ran. By evening L Corp had issued a statement about a gas leak, and the lights were white again." },
			},
		},
	},
	{
		id = "ad_f_ordeal",
		title = "Why Were We Made",
		art = "market",
		text = "A machine with a lamp for a face has climbed out of the old L Corp branch under the market. It walks from stall to stall very slowly, asking the same question.",
		weight = 5,
		once = true,
		tags = { "danger" },
		when = { minAge = 35, maxAge = 60, world = AFTER, flags = { "knows_lcorp" } },
		codex = "lc_lore_ordeals",
		dialogue = {
			{ who = "ordeal", line = "WHY. WERE. WE. MADE." },
		},
		choices = {
			{
				label = "Fight it",
				clash = { stat = "strength", foe = "A Green Ordeal", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "ordeal", status = { id = "charge", potency = 2 } },
				win = { strength = 4, money = { 100, 250 }, log = "It came apart into gears and green light. A Workshop paid well for the lamp and hung it on the wall, unlit." },
				lose = { health = { -24, -12 }, sanity = -8, cause = "Asked why by a Green Ordeal", log = "It hit you very hard and very precisely, then leaned down and asked you why. You couldn't answer." },
			},
			{
				label = "Answer its question",
				clash = { stat = "mind", foe = "A machine that wants a reason", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = 4, log = "You told it it was made to be useful, like most people. It thought about that. Then it walked out of the market and sat down by the canal." },
				lose = { sanity = -8, log = "You told it nobody knows why anyone was made. It agreed with you. It took that very badly." },
			},
			{
				label = "Hide under the fish stall",
				result = { sanity = -6, log = "It asked the fishmonger why. The fishmonger said \"For money,\" and it left him alone." },
			},
		},
	},
	{
		id = "ad_f_kcorp_excision",
		title = "Unauthorized Use",
		art = "nest",
		text = "Your neighbor bought black-market ampules to fix his knee. Tonight two K Corp Excision Staff are at his door with green batons, and he's at yours, begging.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 55, district = "d11", flags = { "knows_wings" } },
		codex = "wg_lore_kcorp",
		dialogue = {
			{ who = "kcorp_staff", line = "Unauthorized ampule use detected at this address. Please step aside. This is an excision. You are not involved." },
		},
		choices = {
			{
				label = "Step aside",
				result = { sanity = -8, log = "You stepped aside. They took him, and the knee. In the morning his door had a new lock and a K Corp seal." },
			},
			{
				label = "Block the door",
				clash = { stat = "strength", foe = "K Corp Excision Staff", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "kcorp_staff", status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = { 40, 90 }, sanity = -3, condition = "dz_hunted", log = "They went down the stairs and called it in. He was across the District by dawn. A drone moved in outside your window." },
				lose = { health = { -18, -8 }, sanity = -6, cause = "Blocked a K Corp excision", log = "They excised you from the doorway first, very cleanly. You woke up healed, with a bill." },
			},
			{
				label = "Hide him in your bath",
				clash = { stat = "mind", foe = "Drones with heat cameras", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = 2, log = "You put him in a cold bath under ice from the noodle stall. The drones passed twice. He limped to the WARP at dawn." },
				lose = { money = { -200, -120 }, sanity = -6, log = "The drones saw him through the wall. K Corp fined you for harboring and itemized the bath." },
			},
		},
	},
	{
		id = "ad_f_seven_tail",
		title = "The Man Who Follows",
		art = "alley",
		text = "The same man in grey glasses has been two shops behind you for nine days. He's very good. You only noticed because he buys the same bread as you every day, and bins it.",
		weight = 8,
		once = true,
		when = { minAge = 20, maxAge = 40, flags = { "knows_fixers" } },
		codex = "fx_lore_seven",
		choices = {
			{
				label = "Corner him in the alley",
				clash = { stat = "strength", foe = "A Seven investigator", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "seven_fixer", status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = { 60, 120 }, log = "He came quietly once his glasses were off. The contract was your old landlord's, about a deposit. You kept his notebook." },
				lose = { health = { -14, -6 }, sanity = -4, cause = "Cornered a Seven investigator", log = "He'd read your file. He knew which way you'd swing. He left a card on your chest: \"Nothing personal. File updated.\"" },
			},
			{
				label = "Lead him on a long walk",
				clash = { stat = "intelligence", foe = "A trained tail", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, sanity = 2, log = "You walked him through four Districts and two WARP changes and lost him in a laundry. You never learned who'd paid." },
				lose = { sanity = -4, log = "When you got home he was waiting at your door, eating your bread." },
			},
			{
				label = "Buy him a tea and ask",
				result = { money = -10, mind = 2, log = "He took the tea and told you nothing, charmingly. He was gone the next morning, which you took as an answer." },
			},
		},
	},
	{
		id = "ad_f_wing_gate",
		title = "Wrong Side of the Gate",
		art = "checkpoint",
		text = "At the Nest gate a guard in a red visor is confiscating medicine bought inside the wall from anyone without a pass. The woman in front of you has her daughter's fever packets.",
		weight = 8,
		once = true,
		when = { minAge = 18, maxAge = 40, side = "backstreets", flags = { "knows_wings" } },
		codex = "bs_lore_nests",
		dialogue = {
			{ who = "wing_guard", line = "Nest goods stay in the Nest. Next. You. Pockets." },
		},
		choices = {
			{
				label = "Look at your shoes",
				result = { sanity = -5, log = "The guard dropped the packets in a bin with the others. The woman stood at the barrier until another guard moved her along." },
			},
			{
				label = "Grab the bin and run",
				clash = { stat = "speed", foe = "Wing Security", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "wing_guard", status = { id = "charge", potency = 2 } },
				win = { speed = 3, sanity = 2, condition = "dz_hunted", log = "You ran the bin into the Backstreets. Forty families got their medicine back. The Wing put your face on a list." },
				lose = { health = { -18, -8 }, sanity = -5, cause = "Ran from the Nest gate", log = "The guard had a baton that hummed. You woke on the Backstreets side, which was where you'd been heading anyway." },
			},
			{
				label = "Quote the Nest rules",
				clash = { stat = "mind", foe = "A guard who's heard it before", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "You quoted the rule by number: medicine for a minor is exempt. The guard checked his book for a long minute and gave the packets back." },
				lose = { money = { -60, -30 }, sanity = -4, log = "You quoted the wrong number. The guard fined you for obstruction and binned the packets anyway." },
			},
		},
	},
	{
		id = "ad_f_capo_boss",
		title = "Capo IIII",
		art = "diner",
		text = "A Capo IIII of the Thumb sits down across from you in the diner, uninvited, and lays his gloves on the table. Four Soldati stand behind him, very correctly.",
		weight = 6,
		once = true,
		when = { minAge = 35, maxAge = 60, flags = { "knows_thumb", "fn_thumb_disrespected" } },
		codex = "fn_lore_thumb_ranks",
		dialogue = {
			{ who = "thumb_capo", line = "Someone in this District has been rude to my family more than once. I came to see if it was a misunderstanding." },
			{ who = "thumb_capo", line = "It was not. Kneel, and this goes quickly. Stand, and it goes properly." },
		},
		choices = {
			{
				label = "Kneel",
				result = { money = { -300, -150 }, sanity = -10, clearFlags = { "fn_thumb_disrespected" }, setFlags = { "ad_knelt_capo" }, log = "You knelt on the diner floor. He took a fine large enough to have its own name. The Soldati stepped round your hands on the way out." },
			},
			{
				label = "Stand",
				clash = { stat = "strength", foe = "A Capo IIII of the Thumb", coins = 4, base = 7, coinPower = 4, fight = true, enemy = "thumb_capo", status = { id = "burn", potency = 3 } },
				win = { strength = 4, money = { 150, 300 }, gear = "fc_capo_revolver", setFlags = { "ad_beat_capo" }, chronicle = "fn_thumb_provoked", log = "He went down across the counter. You took his engraved revolver, because he'd have taken yours. Every Soldato in the District learned your face." },
				lose = { health = { -24, -12 }, sanity = -10, cause = "Stood up to a Capo IIII", log = "It went properly. You woke in the clinic. The Thumb had paid the bill. That was the message." },
			},
			{
				label = "Recite the formal apology",
				clash = { stat = "mind", foe = "Page 1,271 of the manual", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, clearFlags = { "fn_thumb_disrespected" }, setFlags = { "thumb_respect" }, log = "You recited a household's apology to a Capo IIII without one error. He put his gloves back on. \"A misunderstanding,\" he said." },
				lose = { money = { -200, -100 }, sanity = -8, log = "You stumbled on the third title. He let you finish, then charged you for his time, by the minute." },
			},
		},
	},
	{
		id = "ad_f_middle_siblings",
		title = "Family Pays Family's Debts",
		art = "alley",
		text = "Three Middle Little Siblings have {friend} backed against the laundry wall over a debt that was {friend}'s cousin's. They keep saying \"family\" like it's a bill.",
		weight = 8,
		once = true,
		when = { minAge = 18, maxAge = 35, flags = { "knows_middle" }, hasRelation = "friend" },
		codex = "fn_lore_middle",
		dialogue = {
			{ who = "middle_sibling", line = "Family pays family's debts. You family? Then you pay too. No? Then walk on, stranger." },
		},
		choices = {
			{
				label = "Pay the cousin's debt",
				hint = "Up to 150 Ahn.",
				requires = { min = { money = 150 } },
				result = { money = { -150, -90 }, relationBond = { kind = "friend", amount = 10 }, log = "You paid. The Siblings wrote you a receipt with a family seal, which nobody else on the street has." },
			},
			{
				label = "Wade in",
				clash = { stat = "strength", foe = "Three Middle Little Siblings", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "middle_sibling", status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = { 40, 80 }, relationBond = { kind = "friend", amount = 15 }, setFlags = { "ad_middle_grudge" }, log = "They ran, shouting that their Big Brother would hear of it. {friend} bought you noodles for a month. Their Big Brother did hear." },
				lose = { health = { -14, -6 }, sanity = -4, relationBond = { kind = "friend", amount = 8 }, cause = "Fought the Middle over a cousin's debt", log = "You and {friend} sat on the laundry step afterwards, sharing one wet rag and one bad mood." },
			},
			{
				label = "Walk on",
				result = { sanity = -6, relationBond = { kind = "friend", amount = -20 }, log = "You walked on. {friend} didn't call for a year, and when they did, it was to borrow money." },
			},
		},
	},
	{
		id = "ad_f_peccatula_pipes",
		title = "Something in the Pipes",
		art = "home",
		text = "The building's pipes have knocked for a week, and the water runs faintly red. In the basement, something with branches is curled round the boiler, growing.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 60, world = { era = "limbus" }, flags = { "knows_distortions" } },
		codex = "lim_peccatula",
		choices = {
			{
				label = "Go down with a shovel",
				clash = { stat = "strength", foe = "A Peccatulum", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "peccatula", status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = { 40, 100 }, log = "It came off the boiler hissing. You buried it in the coal bin, and the landlord knocked a month off your rent, in shock." },
				lose = { health = { -14, -6 }, sanity = -4, cause = "Fought a Peccatulum in the basement", log = "It got bigger when it was angry. You came up the stairs faster than you went down." },
			},
			{
				label = "Call the LCD",
				result = { money = { -60, -30 }, sanity = -2, setFlags = { "knows_limbus" }, log = "The LCD came in four hours and billed the building. Your share went on the rent. The water ran clear by Friday." },
			},
			{
				label = "Starve it out",
				clash = { stat = "intelligence", foe = "A week without the boiler", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, log = "You shut the boiler down and talked the building into cold baths for a week. It shriveled to a twig. You kept it in a jar." },
				lose = { health = -3, sanity = -4, log = "A week of cold water, and it moved into the walls. Everyone blamed you, and wore coats indoors." },
			},
		},
	},
	{
		id = "ad_f_distortion_market",
		title = "Market Day",
		art = "market",
		text = "In the middle of the market a fishmonger stops calling prices, all at once, and her stall folds up around her into a shape with scales and a hundred hands. Nobody moves.",
		weight = 6,
		cooldown = 10,
		tags = { "danger" },
		when = { minAge = 35, maxAge = 60, world = AFTER, flags = { "knows_distortions" } },
		codex = "terms_distortion",
		choices = {
			{
				label = "Fight it",
				clash = { stat = "strength", foe = "A Distortion in the market", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "distortion", status = { id = "sinking", potency = 2 } },
				win = { strength = 4, money = { 120, 260 }, setFlags = { "lim_distortion_survivor" }, chronicle = "fought_distortion", log = "You held it among the crates until an Office came. The Office took the bounty. The stallholders took up a collection for you." },
				lose = { health = { -24, -12 }, sanity = -8, setFlags = { "lim_distortion_survivor" }, cause = "Fought a Distortion on market day", log = "It closed its hundred hands. You woke under a tarpaulin. The market reopened on Thursday." },
			},
			{
				label = "Walk the crowd out",
				clash = { stat = "mind", foe = "A market that won't move", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = -2, log = "You walked backwards, talking softly, and the whole market walked with you. It never noticed you go." },
				lose = { sanity = -8, condition = "dz_terror", log = "Someone screamed. It noticed. You saw the next minute, and you'd rather not have." },
			},
			{
				label = "Ask her what she lost",
				clash = { stat = "mind", foe = "A grief with a hundred hands", coins = 3, base = 6, coinPower = 4 },
				win = { mind = 3, sanity = 3, setFlags = { "lim_talked_down" }, chronicle = "calmed_distortion", log = "\"The boat,\" it said in her voice. You said the boat was fine. It wasn't, but she believed you long enough to come back." },
				lose = { health = { -14, -6 }, sanity = -8, cause = "Spoke to a Distortion", log = "It told you what she'd lost. Then it showed you." },
			},
		},
	},
	{
		id = "ad_f_hunter_eyes",
		title = "Wrong Red Eyes",
		art = "alley",
		text = "A Hunter in a long coat follows you two streets and stops you under a lamp. He's looking at your red combat eyes, and his hand is under his coat.",
		weight = 9,
		once = true,
		when = { minAge = 20, maxAge = 45, form = "human", flags = { "augmented_eyes", "knows_bloodfiends" } },
		codex = "bf_lore_bloodfiends",
		dialogue = {
			{ who = "hunter", line = "Red eyes, out past midnight. Prove you're not Kindred. Quickly, please. It's been a long night." },
		},
		choices = {
			{
				label = "Show him your clinic papers",
				clash = { stat = "mind", foe = "A Hunter who's been lied to", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 1, log = "Your augmentation papers had a clinic stamp and a bad photo. He compared them a long time, then apologized and bought you noodles." },
				lose = { sanity = -6, condition = "dz_hunted", log = "He didn't trust Backstreets stamps. He let you go, and walked behind you every night for a season." },
			},
			{
				label = "Let him try",
				clash = { stat = "strength", foe = "A Hunter", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "hunter", status = { id = "bleed", potency = 2 } },
				win = { strength = 3, money = { 60, 140 }, log = "He came at you like a Bloodfiend, and you fought like one. He left convinced. You didn't correct him." },
				lose = { health = { -18, -8 }, sanity = -6, cause = "Mistaken for a Bloodfiend", log = "He found out you weren't Kindred the slow way. He left you at a clinic and paid for one night." },
			},
			{
				label = "Point him at real Kindred",
				requires = { flags = { "bf_knows" } },
				result = { money = 200, sanity = -8, setFlags = { "ad_sold_ysolde" }, log = "You told him which roofs the Ashgrave use. He paid two hundred and touched his hat. The rooftops went quiet that month." },
			},
		},
	},
	{
		id = "ad_f_workshop_robbery",
		title = "Robbery at Cinderbell",
		art = "workshop",
		text = "Two men in Workshop aprons are carrying racks of blades out of the Cinderbell Workshop at noon. Marten is sitting on the step, holding his own wrist.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 55 },
		codex = "bs_lore_workshops",
		dialogue = {
			{ who = "ad_marten", line = "Rival shop. They say I copied their maker's mark. I did, a bit. That's not the point." },
		},
		choices = {
			{
				label = "Stop them",
				clash = { stat = "strength", foe = "Workshop muscle", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "workshop_brute", status = { id = "tremor", potency = 2 } },
				win = { strength = 3, money = { 80, 160 }, setFlags = { "ad_marten_friend" }, log = "They dropped the racks and ran. Marten paid you out of the till, and gave you the name of a good clinic, just in case." },
				lose = { health = { -14, -6 }, sanity = -4, cause = "Stood in a Workshop doorway", log = "They hit you with the flat of a sword, which is still a sword. Marten patched you up with forge grease." },
			},
			{
				label = "Run for the Zwei post",
				result = { sanity = -1, log = "The Zwei came in twelve minutes and took statements. By evening the racks were in the rival shop's window." },
			},
			{
				label = "Help carry the racks",
				result = { money = 100, sanity = -7, setFlags = { "ad_robbed_marten" }, log = "You helped carry. They paid you a hundred and a wink. Marten watched your face from the step." },
			},
		},
	},
}
