--[[
	Side events: everyday life on the Charter (walled, comfortable, watched) and in
	the Gutters (hard, dangerous, neighborly). They work in any Ward.
	Events that name {corp} skip Drownside, which has no living company.
	Reads charter_born (set by the engine for anyone born on the Charter side).
	Sets saw_the_silt (side_charter_wall_walk), read by life_rim_gala.
]]

return {
	-- The Charter -----------------------------------------------------------
	{
		id = "side_charter_curfew",
		title = "The Curfew Bell",
		text = "You are halfway up the stairs from a Gutters market when the curfew bell starts to ring. The Charter gate closes on the ninth stroke, and anyone caught outside after that sleeps outside, whatever their papers say. Above you, the guards are already swinging the great doors. The bell is on its fifth stroke.",
		cooldown = 5,
		tags = { "side", "charter" },
		when = { side = "charter", minAge = 12 },
		choices = {
			{
				label = "Run for the gate",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The curfew stairs", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = 1, sanity = 2, log = "You took the last flight three steps at a time and slid through as the bar came down." },
				lose = { fortitude = { -3, -1 }, justice = 1, sanity = -3, log = "The doors shut in your face, and you spent the night on the stairs with the people outside." },
			},
			{
				label = "Sleep in the Gutters tonight",
				result = { money = { -5, -2 }, justice = 2, sanity = -1, log = "You paid for a hammock in a Gutters boarding house and lay awake listening to the fog." },
			},
			{
				label = "Say your family name to the guards",
				requires = { flags = { "charter_born" } },
				result = { prudence = 1, justice = -1, sanity = 1, log = "You said your family name to the gate guard, and the small door opened as if by itself." },
			},
		},
	},
	{
		id = "side_charter_gala",
		title = "The Founders' Gala",
		text = "The founding gala of {corp} fills the glass hall above the Charter gardens. There are ices shaped like the great floodgates, a string quartet under a portrait of the first director, and talk of promotions in every corner. Nobody mentions the Gutters, very carefully. Your new shoes pinch.",
		cooldown = 5,
		tags = { "side", "charter", "luxury" },
		when = { side = "charter", notDistrict = "drownside", minAge = 16 },
		choices = {
			{
				label = "Work the room",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The gala crowd", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, sanity = 4, log = "You said the right things in the right order, and three directors learned your name." },
				lose = { money = { -30, -10 }, sanity = -3, log = "You said the wrong thing to a director's aunt and spent a fortune on apology flowers." },
			},
			{
				label = "Eat with the kitchen staff",
				result = { justice = 2, sanity = 3, log = "You slipped down to the kitchens and ate the good leftovers with the staff, who were funnier." },
			},
			{
				label = "Pledge to the flood fund, loudly",
				hint = "50 scrip.",
				requires = { min = { money = 50 } },
				result = { money = -50, justice = 1, sanity = 4, log = "You pledged fifty {currency} to the flood fund loudly enough for the whole hall to hear." },
			},
		},
	},
	{
		id = "side_charter_loyalty_book",
		title = "The Loyalty Book",
		text = "Once a year every household inside the walls signs the Loyalty Book of {corp} in the gatehouse square, under the eyes of the guards and the neighbors. The book is very old and very thick. You have never read the pages before the one you sign. A clerk holds out the pen, already dipped.",
		cooldown = 6,
		tags = { "side", "charter" },
		when = { side = "charter", notDistrict = "drownside", minAge = 18 },
		choices = {
			{
				label = "Sign with a flourish",
				result = { prudence = 1, justice = -1, sanity = 2, log = "You signed with a flourish, and the guards nodded at you on the street all year." },
			},
			{
				label = "Read the old pages first",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The company clerk", coins = 2, base = 4, coinPower = 3 },
				win = { temperance = 2, justice = 2, sanity = -1, log = "You read back forty pages and found what the company once promised the Gutters, in writing." },
				lose = { money = -20, sanity = -2, log = "The clerk fined you twenty {currency} for holding up the queue, and you signed regardless." },
			},
			{
				label = "Refuse to sign",
				result = { money = { -60, -30 }, justice = 3, sanity = -2, log = "You refused to sign, and the company doubled your residence levy before the week was out." },
			},
		},
	},
	{
		id = "side_charter_lamp_girl",
		title = "The Lamp Girl",
		text = "Every evening a girl from the Gutters comes through the service gate to light the lamps in your house, room by room, with a long brass taper. Her name is on a list somewhere. Her hands are spotted with small burns, old and new. Tonight she is late, and she is trying very hard not to cry.",
		once = true,
		tags = { "side", "charter", "luxury", "friend" },
		when = { side = "charter", minAge = 10 },
		choices = {
			{
				label = "Ask her what's wrong",
				result = {
					justice = 2,
					sanity = 2,
					addRelation = { kind = "friend", name = "Lowen Pellam", bond = 45, age = { 12, 16 } },
					log = "{newRelation} told you her mother was sick, and after that you lit the top floor yourself.",
				},
			},
			{
				label = "Pay her extra",
				hint = "20 scrip.",
				requires = { min = { money = 20 } },
				result = { money = -20, justice = 2, sanity = 1, log = "You pressed twenty {currency} into her burned hand and told her to go home early." },
			},
			{
				label = "Report her lateness",
				result = { justice = -3, sanity = -2, log = "You reported her lateness. A different girl came the next evening, and nobody said why." },
			},
		},
	},
	{
		id = "side_charter_wall_walk",
		title = "Walking the Wall",
		text = "At dusk the guards let residents walk the top of the Charter wall, a promenade of swept flagstones and potted lemon trees. From up here you watch the Gutters of {district} fall away down the Terraces in a slope of tin roofs and washing lines to the Silt, where the first fog lamps are being lit. It looks almost pretty from this height.",
		cooldown = 6,
		tags = { "side", "charter", "luxury" },
		when = { side = "charter", minAge = 14 },
		choices = {
			{
				label = "Count the lit windows",
				result = { prudence = 2, justice = 1, sanity = -2, log = "You counted lit windows until you lost count, and then you counted the dark ones." },
			},
			{
				label = "Look only at the sky",
				result = { justice = -1, sanity = 3, log = "You kept your eyes on the sky the whole walk, and it was a very beautiful sky." },
			},
			{
				label = "Go down and see it close",
				result = { fortitude = -1, justice = 2, sanity = -2, setFlags = { "saw_the_silt" }, log = "You walked down past the gate to the Silt and came back with fog in your good coat." },
			},
		},
	},
	{
		id = "side_charter_charity_supper",
		title = "The Charity Supper",
		text = "The Charter's charity supper is held every winter in aid of the Gutters, at forty {currency} a plate. Over roast fowl and candied lemon, the guests pledge sums to the flood fund and the Foundling Steps, and the pledges are read aloud between courses. Collecting them is someone else's job, and nobody at your table knows whose.",
		cooldown = 5,
		tags = { "side", "charter", "luxury" },
		when = { side = "charter", minAge = 18 },
		choices = {
			{
				label = "Pledge loudly, send nothing",
				result = { justice = -3, sanity = 2, log = "Your pledge got the loudest applause of the night, and nobody ever came to collect it." },
			},
			{
				label = "Carry your pledge down yourself",
				hint = "40 scrip.",
				requires = { min = { money = 40 } },
				result = { money = -40, justice = 4, sanity = 2, log = "You carried your pledge down to the Foundling Steps yourself, and the matron cried a little." },
			},
			{
				label = "Collect everyone's pledges",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The charity guests", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, justice = 4, sanity = 3, log = "You went door to door through the Charter with the pledge list and collected nearly every sum." },
				lose = { sanity = -3, log = "You knocked on forty doors with the pledge list and were not invited back to supper." },
			},
		},
	},
	{
		id = "side_charter_hot_water",
		title = "Hot Water from a Tap",
		text = "In your first winter inside the walls, hot water comes out of a brass tap whenever you turn it, without anyone carrying a single bucket up a single stair. You stand with your hand under it longer than you need to. Somewhere below the floors, someone is shoveling coal so that it stays hot.",
		once = true,
		tags = { "side", "charter", "luxury" },
		when = { side = "charter", minAge = 16, notFlags = { "charter_born" } },
		choices = {
			{
				label = "Take the longest bath of your life",
				result = { sanity = { 4, 6 }, log = "You took the longest bath of your life and came out pink, wrinkled and slightly ashamed." },
			},
			{
				label = "Find the boiler room",
				result = { prudence = 1, justice = 2, sanity = 1, log = "You found the boiler room and the two stokers in it, and brought them hot buns every week." },
			},
			{
				label = "Sneak a Gutters friend in to bathe",
				requires = { hasRelation = "friend" },
				result = { justice = 1, sanity = 3, relationBond = { kind = "friend", amount = 8 }, log = "You smuggled a friend from the Gutters through the service gate for a hot bath." },
			},
		},
	},
	{
		id = "side_charter_gate_pass",
		title = "A Pass at the Gate",
		text = "{mother} has come up from the Gutters to visit you, and the gate guards have put her in the pass queue with the laundry women and the coal boys. The queue is two hours long. She is standing in it with a cake wrapped in a cloth, pretending she does not mind, and minding very much.",
		cooldown = 8,
		tags = { "side", "charter", "family" },
		when = { side = "charter", minAge = 18, hasRelation = "mother", notFlags = { "charter_born" } },
		choices = {
			{
				label = "Wait in the queue with her",
				result = { sanity = 3, relationBond = { kind = "mother", amount = 8 }, log = "You stood in the pass queue beside {mother} for two hours and ate half the cake there." },
			},
			{
				label = "Buy her a standing pass",
				hint = "50 scrip.",
				requires = { min = { money = 50 } },
				result = { money = -50, sanity = 2, relationBond = { kind = "mother", amount = 6 }, log = "You bought {mother} a standing pass, and she kept it in her best purse like a medal." },
			},
			{
				label = "Argue with the guards",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Charter gate guards", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 2, sanity = 2, relationBond = { kind = "mother", amount = 5 }, log = "You argued until the guards waved {mother} through, and she pretended not to be proud of you." },
				lose = { money = -10, sanity = -3, relationBond = { kind = "mother", amount = -2 }, log = "The guards fined you for the scene, and {mother} went home with the cake still wrapped." },
			},
		},
	},

	-- The Gutters -----------------------------------------------------------
	{
		id = "side_gutters_new_landlord",
		title = "The New Landlord",
		text = "Your building in {zone} has been sold to a man nobody has seen, and his agent has nailed a new rent to every door. It is nearly double. The agent says the stairs will be repaired and the roof will be seen to. He said the same thing on the building next door, which has no stairs now.",
		cooldown = 8,
		tags = { "side", "gutters", "rent" },
		when = { side = "gutters", minAge = 18 },
		choices = {
			{
				label = "Pay the new rent",
				result = { money = { -40, -20 }, sanity = -2, log = "You paid the new rent and ate kelp broth without the fish for the rest of the year." },
			},
			{
				label = "Organize a rent strike",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The landlord's agent", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 4,
					sanity = 3,
					relationBond = { kind = "all", amount = 2 },
					log = "You got every door on the stairwell to hold out together, and the agent took the notices down.",
				},
				lose = { money = { -50, -30 }, sanity = -4, log = "The strike broke in a week, and the agent added the lost rent to your share." },
			},
			{
				label = "Sublet half your room",
				result = { money = { -10, 5 }, temperance = 1, sanity = -2, log = "You hung a curtain across your room and rented the far half to a snoring net-mender." },
			},
		},
	},
	{
		id = "side_gutters_stair_toll",
		title = "The Stair Toll",
		text = "A crew of older kids has strung a rope across the switchback stairs at the Gull Lane landing, and they are charging a toll to step over it. Two {currency} a head, more if you look like you can pay. The biggest one is twirling a cosh made from a sock full of sand, and grinning at you.",
		cooldown = 4,
		tags = { "side", "gutters", "crime", "danger" },
		when = { side = "gutters", minAge = 10 },
		choices = {
			{
				label = "Pay the toll",
				hint = "2 scrip.",
				requires = { min = { money = 2 } },
				result = { money = -2, sanity = -1, log = "You paid two {currency} to step over a rope, and the crew bowed you through like royalty." },
			},
			{
				label = "Step over without paying",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The stair crew", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 2, log = "You stepped over the rope and stared down the biggest one until the whole crew looked away." },
				lose = {
					money = { -8, -2 },
					fortitude = { -7, -3 },
					sanity = -2,
					log = "The sock of sand found the back of your head, and your pockets were lighter when you woke.",
					cause = "Beaten on the switchback stairs",
				},
			},
			{
				label = "Take the long way round",
				result = { fortitude = 1, sanity = -1, log = "You took the long way round by the coal chutes and arrived late, sooty and unrobbed." },
			},
		},
	},
	{
		id = "side_gutters_collapse",
		title = "The Floor Gives Way",
		text = "A tenement two doors down has folded in on itself in the night, one floor dropping onto the next like a stack of wet books. Dust is still rising off it in the lamplight. Neighbors are already pulling at beams with their bare hands, and from somewhere under the boards, a voice is calling out names. You are still in your nightclothes.",
		cooldown = 8,
		tags = { "side", "gutters", "danger" },
		when = { side = "gutters", minAge = 12 },
		choices = {
			{
				label = "Dig with your hands",
				hint = "Fortitude clash, medium-hard.",
				clash = { stat = "fortitude", foe = "The fallen tenement", coins = 2, base = 5, coinPower = 3 },
				win = { fortitude = -1, justice = 4, sanity = 3, log = "You dug until dawn beside strangers, and the voice under the boards came out alive." },
				lose = {
					fortitude = { -11, -5 },
					sanity = -4,
					log = "A beam shifted as you pulled at it, and the diggers had to dig you out too.",
					cause = "Crushed in a tenement collapse",
				},
			},
			{
				label = "Hold lanterns for the diggers",
				result = { justice = 2, sanity = -2, log = "You held a lantern over the diggers all night, and your arms shook long after it ended." },
			},
			{
				label = "Run for the Sluice rescue crew",
				result = { prudence = 2, sanity = -1, log = "You ran for the Sluice rescue crew, who came at noon with forms to fill in." },
			},
		},
	},
	{
		id = "side_gutters_pot_on_step",
		title = "A Pot on the Step",
		text = "You are down to your last few {currency}, and your cupboard is down to salt. This morning there is a pot on your step, wrapped in a towel to keep it warm, with no note. Kelp broth, a whole fish in it, and a heel of bread on the lid. Every door on the landing is shut.",
		cooldown = 6,
		tags = { "side", "gutters", "kindness" },
		when = { side = "gutters", minAge = 16, max = { money = 25 } },
		choices = {
			{
				label = "Eat, and return the pot full",
				result = { money = { -4, -2 }, fortitude = 1, sanity = 4, log = "You ate every drop and left the pot on the landing, full of the best broth you could manage." },
			},
			{
				label = "Find out who left it",
				result = {
					sanity = 3,
					addRelation = { kind = "friend", bond = 50, age = { 30, 60 } },
					log = "You knocked on every door until {newRelation} admitted it, and then you ate together.",
				},
			},
			{
				label = "Pass it to the family upstairs",
				result = { fortitude = -1, justice = 3, sanity = 2, log = "You carried the pot upstairs to the family with five children and went to bed hungry, but warm." },
			},
		},
	},
	{
		id = "side_gutters_thick_fog",
		title = "Fog Thick as Wool",
		text = "The fog comes up off the Mere so thick the trams have stopped and the lamplighters have given up. Down every lane, people are linking arms in long chains to find their way home, calling out street names as they pass each one. A chain shuffles past the doorway where you are sheltering, and an arm reaches out of the grey toward you.",
		cooldown = 4,
		tags = { "side", "gutters", "fog" },
		when = { side = "gutters", minAge = 8 },
		choices = {
			{
				label = "Take the arm",
				result = { sanity = 4, log = "You linked arms with strangers and called out street names all the way home, laughing by the end." },
			},
			{
				label = "Find your own way",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The fog", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 3, sanity = 1, log = "You counted stairs and landings in your head and came out exactly at your own door." },
				lose = {
					fortitude = { -8, -3 },
					sanity = -2,
					log = "You missed a turn in the grey and stepped off a landing into nothing.",
					cause = "Fell from the stairs in the fog",
				},
			},
			{
				label = "Wait it out in the doorway",
				result = { fortitude = -1, sanity = -1, log = "You waited in the doorway until the fog thinned at dawn, cold to the bone and quite alone." },
			},
		},
	},
	{
		id = "side_gutters_lean_month",
		title = "The Lean Month",
		text = "Bread has doubled since the last flood, and the fish carts have stopped coming up the stairs. Your stomach has learned a new sound. The Choir is ladling soup on the ferry steps every evening, and the queue goes back three landings. A boy on the stilts below is fishing with a bent nail and a thread.",
		cooldown = 6,
		tags = { "side", "gutters", "hunger" },
		when = { side = "gutters", minAge = 8, max = { money = 60 } },
		choices = {
			{
				label = "Queue for the Choir's soup",
				result = { fortitude = 1, prudence = 1, sanity = 1, log = "You queued three landings deep for the Choir's soup, and it was better than it had any right to be." },
			},
			{
				label = "Fish off the stilts at night",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The night water", coins = 1, base = 2, coinPower = 2 },
				win = { fortitude = 2, sanity = 2, log = "You fished off the stilts by lantern light and brought home three silver fish and a crab." },
				lose = { fortitude = { -5, -2 }, sanity = -2, log = "Something pale took your line and your lantern, and you went to bed hungrier than before." },
			},
			{
				label = "Sell your good coat",
				result = { money = { 10, 25 }, fortitude = -2, log = "You sold your good coat at the rag market and ate well for a fortnight, shivering." },
			},
		},
	},
	{
		id = "side_gutters_own_roof",
		title = "Fixing Your Own Roof",
		text = "The roof has been leaking over your bed since the autumn rains, and the landlord's answer is a bucket. Tonight the bucket is full by midnight. There is a sheet of salvage tin in the stairwell, a hammer you borrowed and never returned, and a ladder that is missing every third rung.",
		cooldown = 6,
		tags = { "side", "gutters" },
		when = { side = "gutters", minAge = 14 },
		choices = {
			{
				label = "Climb up and patch it",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The leaking roof", coins = 2, base = 4, coinPower = 3 },
				win = { temperance = 3, sanity = 4, log = "You patched the roof with salvage tin in the rain, and slept dry for the first time in months." },
				lose = {
					fortitude = { -8, -3 },
					sanity = -2,
					log = "The ladder lost another rung under you, and you came down faster than the rain.",
					cause = "Fell from a tenement roof",
				},
			},
			{
				label = "Pay a roofer",
				hint = "25 scrip.",
				requires = { min = { money = 25 } },
				result = { money = -25, sanity = 2, log = "A roofer with one eye fixed it in an hour and told you the whole building was rotten." },
			},
			{
				label = "Move the bed and add a bucket",
				result = { prudence = 1, sanity = -2, log = "You moved the bed, added a second bucket, and learned to sleep to the sound of dripping." },
			},
		},
	},
	{
		id = "side_gutters_eviction",
		title = "Furniture in the Rain",
		text = "The Pellams across the landing have been put out of their rooms, and everything they own is standing in the lane in the rain: a dresser, a cot, a birdcage with the bird still in it. The landlord's men are leaning on the wall. Ilse Pellam is holding the baby and staring at nothing, and you are the only neighbor who has come down.",
		cooldown = 8,
		tags = { "side", "gutters", "kindness" },
		when = { side = "gutters", minAge = 16 },
		choices = {
			{
				label = "Take them in",
				result = {
					money = { -25, -10 },
					justice = 4,
					sanity = 2,
					addRelation = { kind = "friend", name = "Ilse Pellam", bond = 55, age = { 25, 40 } },
					log = "You took the Pellams in for a season, and {newRelation} cooked for both families the whole time.",
				},
			},
			{
				label = "Carry their things to a cousin's",
				result = { fortitude = { -2, 0 }, justice = 2, sanity = 1, log = "You carried a dresser, a cot and a birdcage up two hundred stairs to a cousin's attic." },
			},
			{
				label = "Stand up to the landlord's men",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "The landlord's men", coins = 2, base = 5, coinPower = 3 },
				win = { prudence = 2, justice = 4, log = "You talked the landlord's men into a month's grace, and the Pellams carried everything back up." },
				lose = {
					fortitude = { -6, -2 },
					sanity = -3,
					log = "The landlord's men shoved you down the stairs, and the Pellams' birdcage went with you.",
					cause = "Thrown down the tenement stairs",
				},
			},
		},
	},
	{
		id = "side_gutters_night_watch",
		title = "Your Turn on Watch",
		text = "The Sluice patrols stopped coming this far down into Ward {wardNumber} years ago, so the stairwell keeps its own watch: one neighbor a night, a lamp, a whistle and a chair at the coal store door. Tonight is your turn. Near midnight you hear the coal store lock being worked, very quietly, from the inside.",
		cooldown = 6,
		tags = { "side", "gutters", "crime", "danger" },
		when = { side = "gutters", minAge = 16 },
		choices = {
			{
				label = "Throw the door open",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The coal thief", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 2, log = "You threw the door open on a coal thief, who dropped the sack and fled up the chute." },
				lose = {
					fortitude = { -7, -3 },
					sanity = -2,
					log = "The thief came out swinging a coal shovel, and you woke up with the sack gone.",
					cause = "Struck down at the coal store",
				},
			},
			{
				label = "Blow the whistle",
				result = { prudence = 2, sanity = 1, log = "You blew the whistle until the whole stairwell came down in nightshirts, and the thief fled." },
			},
			{
				label = "Leave a lamp by the door and wait",
				result = { justice = 1, sanity = -1, log = "You set the lamp by the door and waited. By morning the thief had gone, leaving a note that said sorry." },
			},
		},
	},
	{
		id = "side_gutters_blue_coat",
		title = "A Coat from the Crew",
		text = "The Lamp Street crew runs the stairs between the tram stop and the fish steps, and its members wear the same blue coats with the collars turned up. One of them, a lanky boy called Ferris Voss, holds a coat out to you on the landing. \"Fits you,\" he says. \"Comes with friends.\"",
		once = true,
		tags = { "side", "gutters", "crime" },
		when = { side = "gutters", minAge = 13, maxAge = 18 },
		choices = {
			{
				label = "Put on the coat",
				result = {
					money = { 10, 25 },
					justice = -2,
					sanity = 2,
					addRelation = { kind = "friend", name = "Ferris Voss", bond = 40, age = { 14, 19 } },
					log = "You wore the blue coat for a year, and {newRelation} made sure nobody on the stairs bothered you.",
				},
			},
			{
				label = "Say no, politely",
				result = { prudence = 2, sanity = -1, log = "You said no thank you, politely, and the crew let you pass, but they remembered your face." },
			},
			{
				label = "Throw it back at him",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The Lamp Street crew", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 3, log = "You threw the coat back at Ferris in front of the whole landing, and he laughed and let it go." },
				lose = {
					fortitude = { -6, -2 },
					sanity = -3,
					log = "The crew taught you about manners behind the fish steps, and you limped for a fortnight.",
					cause = "Beaten behind the fish steps",
				},
			},
		},
	},
}
