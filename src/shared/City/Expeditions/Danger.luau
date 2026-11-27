--[[
	Expeditions, danger and horror (dz_): three runs nobody should take, with real deaths and
	real pay. Each is opened by an event, not listed for everyone:
		dz_ex_long_night    "Eighty Minutes": a parcel across the District during the Night
		                    (flag dz_night_job: dz_n_parcel, dz_echo_night_runner)
		dz_ex_outskirts     "Past the Last Wall": salvage from beyond the City wall
		                    (flag dz_outskirts_job: dz_x_outskirts_job, dz_echo_followed)
		dz_ex_number_nine   "Number Nine, Bellhouse Row": into a Location-type Distortion
		                    (flag dz_nine_open: dz_d_nine_gone, dz_echo_nine)
	`die` here ends every life in the crew, so it sits only behind very bad odds or a climax.
	Tokens: {crew}, {crewNames}, {champion}.
]]

return {
	order = { "dz_ex_long_night", "dz_ex_outskirts", "dz_ex_number_nine" },

	dz_ex_long_night = {
		name = "Eighty Minutes",
		kind = "mission",
		desc = "Carry a sealed parcel across the District during the Night, from 3:13 until the third wave has passed. Nobody does this. That's why it pays a thousand Ahn.",
		minAge = 18,
		cost = 0,
		cooldown = 6,
		crew = { min = 1, max = 2 },
		length = 6,
		when = { side = "backstreets", flags = { "dz_night_job" } },
		start = "door",
		stages = {
			door = {
				title = "3:05, Your Own Door",
				text = "{crew} stand inside the door with the parcel. Eight minutes until the Sweepers rise. Once you step out, the only doors that open are the ones you can pay for or beg.",
				choices = {
					{ label = "Step out", result = { log = "{crew} stepped out and locked the door behind." }, next = "first_wave" },
					{ label = "Not tonight", result = { log = "{crew} put the parcel back on the shelf. It will still be there tomorrow night." }, ["end"] = "retreat" },
				},
			},
			first_wave = {
				title = "3:13, the First Wave",
				text = "They rise out of the ground along the Nest wall and come up the street toward {crew}: wall to wall, slow, silent, and spotless behind.",
				tone = "danger",
				choices = {
					{
						label = "Under a delivery van",
						hint = "Mental Strength check.",
						clash = { stat = "mind", foe = "The first wave", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { sanity = -4, log = "{crew} lay flat under the van while the first wave flowed past on both sides." },
						lose = { health = { -22, -12 }, sanity = -6, log = "One of them stopped beside the van and bent down to look.", cause = "Swept away under a delivery van" },
						next = "quiet",
					},
					{
						label = "Up the fire escape",
						hint = "Health check.",
						clash = { stat = "health", foe = "A rusted ladder", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { sanity = -3, log = "{champion} hauled everyone up onto the rooftops as the wave arrived." },
						lose = { health = { -20, -10 }, condition = "broken_arm", log = "The ladder came away from the wall at the second landing.", cause = "Fell from a fire escape during the Night" },
						winNext = "rooftops",
						loseNext = "quiet",
					},
					{
						label = "Stand still in the open",
						hint = "Mental Strength check. Very bad odds.",
						clash = { stat = "mind", foe = "Three hundred Sweepers", coins = 4, base = 9, coinPower = 4, fixed = true },
						win = { sanity = -10, setFlags = { "dz_unsurvivable" }, log = "{crew} stood in the middle of the street, and the first wave parted around them like water round a stone." },
						lose = { die = "Stood still in the open as the first wave came", log = "The first wave didn't part." },
						winNext = "quiet",
						loseEnd = "fail",
					},
				},
			},
			rooftops = {
				title = "The Rooftops",
				text = "From up here you can see three slow rivers of figures moving through the District. The roofs run out at the canal, one long gap short of the next block.",
				choices = {
					{
						label = "Jump the gap",
						hint = "Strength check.",
						clash = { stat = "strength", foe = "A long gap in the dark", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { strength = 1, log = "{champion} made the jump and caught the others' hands. The canal was behind them." },
						lose = { health = { -22, -12 }, log = "Short. A laundry line caught {champion} on the way down, and then didn't.", cause = "Fell between rooftops during the Night" },
						winNext = "green_door",
						loseNext = "quiet",
					},
					{ label = "Climb down and go round", result = { sanity = -2, log = "{crew} climbed down into the quiet between waves." }, next = "quiet" },
				},
			},
			quiet = {
				title = "Ten Minutes of Quiet",
				text = "The first wave has passed. A man is curled in a doorway, alive, his ankle twisted. Across the street a shutter is up a hand's width: \"Two hundred, and you can wait out the second wave.\"",
				choices = {
					{
						label = "Carry the man with you",
						hint = "Health check.",
						clash = { stat = "health", foe = "A grown man and ten minutes", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { sanity = 4, strength = 2, log = "{crew} got him behind a locked stairwell door. It cost three minutes, and it was worth it." },
						lose = { health = { -14, -6 }, sanity = -4, log = "He was heavier than he looked, and the ground was already humming.", cause = "Carried a stranger between the waves" },
						next = "second_wave",
					},
					{ label = "Leave him", result = { sanity = -8, log = "{crew} left him in the doorway. Nobody looked back." }, next = "second_wave" },
					{ label = "Pay the shopkeeper", hint = "200 Ahn.", requires = { min = { money = 200 } }, result = { money = -200, sanity = -2, log = "{crew} paid, and waited out the second wave on a shop floor, listening to it pass." }, next = "green_door" },
				},
			},
			second_wave = {
				title = "3:43, the Second Wave",
				text = "The second wave comes from the other way, faster, and {crew} are on the canal bridge with nowhere to go but over or under.",
				tone = "danger",
				choices = {
					{
						label = "Hang under the bridge",
						hint = "Health check.",
						clash = { stat = "health", foe = "Ten minutes holding on", coins = 3, base = 7, coinPower = 3, fixed = true },
						win = { sanity = -6, log = "{crew} hung from the girders over black water while the second wave crossed above." },
						lose = { health = { -24, -12 }, sanity = -6, log = "Hands slipped. The canal was very cold.", cause = "Fell into the canal during the second wave" },
						next = "green_door",
					},
					{
						label = "Sprint across",
						hint = "Strength check.",
						clash = { stat = "strength", foe = "The second wave", coins = 3, base = 7, coinPower = 3, fixed = true },
						win = { strength = 1, sanity = -3, log = "{crew} made the far side with the wave a stone's throw behind." },
						lose = { die = "Caught on the canal bridge in the second wave", log = "The wave reached the middle of the bridge at the same moment you did." },
						winNext = "green_door",
						loseEnd = "fail",
					},
				},
			},
			green_door = {
				title = "The Green Door",
				text = "The address at last: a narrow house with a green door. Nobody answers the knock. The third wave is ten minutes off.",
				choices = {
					{
						label = "Knock the agreed pattern",
						hint = "Mental Strength check.",
						clash = { stat = "mind", foe = "A frightened household", coins = 2, base = 5, coinPower = 3, fixed = true },
						win = { log = "Three, two, three. A bolt slid back." },
						lose = { sanity = -4, log = "No answer. The ground began to hum." },
						winNext = "inside",
						loseNext = "third_wave",
					},
					{ label = "Break the door in", hint = "It's the Night. Breaking in is a Taboo.", result = { die = "Broke into a home during the Night", log = "The green door gave. Something much worse than the Sweepers noticed." }, ["end"] = "fail" },
					{ label = "Wait on the step", result = { sanity = -4, log = "{crew} sat on the step with the parcel and waited." }, next = "third_wave" },
				},
			},
			third_wave = {
				title = "4:03, the Third Wave",
				text = "The third wave turns into the street. {crew} press into the porch of the green door, and there is nowhere else to go.",
				tone = "danger",
				choices = {
					{
						label = "Make yourself small",
						hint = "Mental Strength check.",
						clash = { stat = "mind", foe = "The third wave", coins = 3, base = 7, coinPower = 3, fixed = true },
						win = { sanity = -8, log = "The third wave passed the porch close enough to touch. Then the door opened behind {crew}." },
						lose = { die = "Swept away on a stranger's porch", log = "The third wave filled the porch." },
						winNext = "inside",
						loseEnd = "fail",
					},
					{
						label = "Hold the parcel to the window",
						hint = "Intelligence check.",
						clash = { stat = "intelligence", foe = "Someone deciding", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { log = "A face at the window saw the name on the parcel, and the door flew open." },
						lose = { health = { -24, -12 }, sanity = -8, log = "The door opened at the last second, but not before the wave reached the step.", cause = "Swept away on a stranger's porch" },
						next = "inside",
					},
				},
			},
			inside = {
				title = "Delivered",
				text = "An old man takes the parcel, reads the name on it, and sits down hard on his own stairs. \"I'd forgotten,\" he says. \"I'd forgotten I ever had a grandson.\"",
				choices = {
					{ label = "Sit with him until dawn", result = { sanity = 4, codex = "dz_lore_erased", log = "{crew} sat with him on the stairs until the third wave passed and the birds started." }, ["end"] = "success" },
				},
			},
		},
		success = { money = 1000, sanity = 4, gear = "dz_night_token", addTrait = "dz_night_ears", clearFlags = { "dz_night_job" }, chronicle = "dz_act_long_night", codex = "dz_lore_knock", log = "{crew} walked home through a spotless street at dawn. The client paid a thousand Ahn, and wept." },
		fail = { sanity = -6, clearFlags = { "dz_night_job" }, log = "The parcel never arrived. Somewhere in the District, a name stayed forgotten." },
		retreat = { sanity = -1, log = "{crew} stayed home. The parcel waits on the shelf." },
	},

	dz_ex_outskirts = {
		name = "Past the Last Wall",
		kind = "mission",
		desc = "A Workshop wants a crate back from a courier truck that crashed in the Outskirts, beyond the City wall. Out there the monsters aren't Abnormalities, and nobody made them. They just hate people.",
		minAge = 18,
		cost = 30,
		cooldown = 6,
		crew = { min = 1, max = 4 },
		length = 5,
		when = { flags = { "dz_outskirts_job" } },
		start = "gate",
		stages = {
			gate = {
				title = "The Last Wall",
				text = "The City ends at a wall of old concrete with a Zwei post at the gap. Past it the land is flat and grey to the horizon. The Zwei guard looks at {crew}'s map and laughs, not unkindly.",
				choices = {
					{ label = "Pay the toll", hint = "60 Ahn.", requires = { min = { money = 60 } }, result = { money = -60, log = "The guard took the toll and wrote {crewNames} in a ledger. \"So we know who to list,\" he said." }, next = "fields" },
					{
						label = "Climb the wall at night",
						hint = "Health check.",
						clash = { stat = "health", foe = "The City wall", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { log = "{crew} went over the wall at midnight and dropped into the grey." },
						lose = { health = { -18, -8 }, log = "{champion} came down badly on the far side.", cause = "Fell from the City wall" },
						next = "fields",
					},
				},
			},
			fields = {
				title = "The Grey Fields",
				text = "Past the wall the ground is dead and the sky is the wrong color. Something big is pacing {crew} just beyond the lamplight, matching their speed exactly.",
				tone = "danger",
				choices = {
					{
						label = "Keep walking, don't run",
						hint = "Mental Strength check.",
						clash = { stat = "mind", foe = "Something pacing you", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { sanity = -4, log = "{crew} kept the same pace for an hour. At the dry riverbed, it lost interest." },
						lose = { sanity = -6, log = "A foot slipped on loose stone. It stopped pacing and started running." },
						winNext = "truck",
						loseNext = "ambush",
					},
					{
						label = "Turn and face it",
						clash = { stat = "strength", foe = "An Outskirts monster", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "tremor", potency = 2 } },
						win = { strength = 3, sanity = -2, log = "It came at the lamp and {champion} met it. It went back into the grey, limping, and didn't come again." },
						lose = { health = { -26, -14 }, log = "It hit like a falling building, and then it was gone, and so was the lamp.", cause = "Killed by an Outskirts monster" },
						next = "truck",
					},
				},
			},
			ambush = {
				title = "It Hates You",
				text = "It comes out of the grey at a run, taller than a streetlamp, and there is nothing in the way it moves but hatred. {crew} have about four seconds.",
				tone = "danger",
				choices = {
					{
						label = "Stand and fight",
						clash = { stat = "strength", foe = "An Outskirts monster", coins = 4, base = 9, coinPower = 4, fight = true, status = { id = "tremor", potency = 3 } },
						win = { strength = 3, log = "{champion} brought it down in the dust. Nobody spoke for a long time." },
						lose = { health = { -30, -16 }, log = "It went through {crew} like a wave.", cause = "Killed by an Outskirts monster" },
						next = "truck",
					},
					{
						label = "Scatter and run",
						hint = "Strength check.",
						clash = { stat = "strength", foe = "A monster at full speed", coins = 3, base = 7, coinPower = 3, fixed = true },
						win = { sanity = -6, log = "{crew} scattered into a dry gully, and it chose the wrong one to follow." },
						lose = { health = { -26, -14 }, log = "It chose the right one.", cause = "Run down in the Outskirts" },
						winNext = "truck",
						loseEnd = "fail",
					},
				},
			},
			truck = {
				title = "The Courier Truck",
				text = "The truck lies on its side in the riverbed with the crate still strapped in. The driver's seat is empty, but the radio is on, playing a voice {crew} know, asking for help.",
				choices = {
					{
						label = "Cut the crate loose",
						hint = "Intelligence check.",
						clash = { stat = "intelligence", foe = "Rusted straps", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { log = "{champion} had the crate free in ten minutes. The radio said thank you." },
						lose = { health = { -14, -6 }, sanity = -4, log = "The straps took an hour. The voice on the radio got closer the whole time.", cause = "Lingered too long at a wreck in the Outskirts" },
						next = "home",
					},
					{
						label = "Turn off the radio",
						hint = "Mental Strength check.",
						clash = { stat = "mind", foe = "A voice you know", coins = 3, base = 7, coinPower = 3, fixed = true },
						win = { sanity = 2, mind = 2, log = "{champion} switched it off. Out in the grey, something stopped walking." },
						lose = { sanity = -15, condition = "dz_terror", log = "The radio was off. The voice kept going." },
						next = "home",
					},
				},
			},
			home = {
				title = "The Wall on the Horizon",
				text = "The City wall is a dark line on the horizon. Behind {crew} something is following, and it's getting closer.",
				tone = "danger",
				choices = {
					{
						label = "Run for the gap",
						hint = "Strength check.",
						clash = { stat = "strength", foe = "A long run with a crate", coins = 3, base = 7, coinPower = 3, fixed = true },
						win = { strength = 1, log = "{crew} reached the Zwei post with the crate and their lungs on fire. The guard crossed their names out of his ledger." },
						lose = { health = { -24, -12 }, log = "It caught up a stone's throw from the wall. The Zwei guard's rifle drove it off, eventually.", cause = "Caught a stone's throw from the City wall" },
						winEnd = "success",
						loseEnd = "success",
					},
					{ label = "Drop the crate and run", result = { sanity = -4, log = "{crew} dropped the crate and ran, and it stopped to look at the crate. That was enough." }, ["end"] = "retreat" },
					{
						label = "Turn and hold it off",
						clash = { stat = "strength", foe = "The thing that followed", coins = 4, base = 9, coinPower = 4, fight = true, status = { id = "tremor", potency = 3 } },
						win = { strength = 4, setFlags = { "dz_unsurvivable" }, log = "{crew} fought it to a standstill under the grey sky, and it went back. Nobody has ever seen one go back." },
						lose = { die = "Turned to fight in the Outskirts", log = "It didn't go back." },
						winEnd = "success",
						loseEnd = "fail",
					},
				},
			},
		},
		success = { money = 800, sanity = 2, gear = "dz_outskirts_fang", addTrait = "dz_scar_tissue", clearFlags = { "dz_outskirts_job" }, chronicle = "dz_act_outskirts", codex = "dz_lore_outskirts", log = "The Rep counted the crate's contents twice and paid in full. \"You came back,\" she said. \"I'll have to rethink my rates.\"" },
		fail = { sanity = -6, log = "{crew} never brought the crate home. It's still out there, and so is the deposit." },
		retreat = { sanity = -2, log = "{crew} came back through the wall with nothing but their lives. The Rep was not surprised." },
	},

	dz_ex_number_nine = {
		name = "Number Nine, Bellhouse Row",
		kind = "dungeon",
		desc = "Go up into Number Nine after the one who went in: past the fourth-floor landing, to wherever the building keeps the people it takes.",
		minAge = 16,
		cost = 0,
		cooldown = 5,
		crew = { min = 1, max = 3 },
		length = 5,
		when = { flags = { "dz_nine_open" } },
		start = "lobby",
		stages = {
			lobby = {
				title = "The Lobby",
				text = "The lift has been broken for twenty years. The stairs go up into the dark. Somewhere above, a kettle is whistling.",
				choices = {
					{ label = "Take the stairs", result = { log = "{crew} started up the stairs, counting." }, next = "landing" },
					{
						label = "Try the broken lift",
						hint = "Intelligence check.",
						clash = { stat = "intelligence", foe = "A lift that shouldn't work", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { sanity = -4, log = "The lift doors opened by themselves. It went up for a very long time, then let {crew} out on the fifth floor." },
						lose = { health = { -22, -12 }, log = "The lift dropped. It dropped further than the building is tall.", cause = "Fell down the lift shaft of Number Nine" },
						winNext = "fifth",
						loseNext = "landing",
					},
				},
			},
			landing = {
				title = "The Fourth-Floor Landing",
				text = "The fourth-floor landing goes on and on, doors on both sides, every one numbered 9. Behind one of them, someone is calling for help in a voice {crew} know.",
				tone = "danger",
				choices = {
					{
						label = "Open the door with the voice",
						hint = "Mental Strength check. Very bad odds.",
						clash = { stat = "mind", foe = "The voice behind the door", coins = 4, base = 9, coinPower = 4, fixed = true },
						win = { sanity = -10, setFlags = { "dz_unsurvivable" }, log = "{champion} opened the door on the voice, and it was a frightened neighbor who'd been lost for a week. The building let her go." },
						lose = { die = "Opened the wrong door in Number Nine", log = "There was nothing behind the door but more landing, and then not even that." },
						winNext = "fifth",
						loseEnd = "fail",
					},
					{
						label = "Walk on to the far stairs",
						hint = "Health check.",
						clash = { stat = "health", foe = "A landing with no end", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { sanity = -4, log = "Hours of doors. Then, suddenly, stairs." },
						lose = { sanity = -14, health = { -10, -4 }, log = "{crew} walked until the doors started to repeat, and then until they started to watch.", cause = "Walked the fourth-floor landing too long" },
						next = "fifth",
					},
					{
						label = "Chalk every door",
						hint = "Intelligence check.",
						clash = { stat = "intelligence", foe = "A building that cheats", coins = 2, base = 6, coinPower = 3, fixed = true },
						win = { intelligence = 2, log = "{champion} chalked every door until, at the ninetieth, the marks began appearing ahead of them. That door was the way up." },
						lose = { sanity = -8, log = "The chalk marks vanished behind them as fast as they made them." },
						next = "fifth",
					},
				},
			},
			fifth = {
				title = "The Fifth Floor",
				text = "The fifth floor is one kitchen, over and over: the same table, the same kettle whistling on the same stove. In the last kitchen, someone sits with their back to {crew}.",
				choices = {
					{
						label = "Say their name",
						hint = "Mental Strength check.",
						clash = { stat = "mind", foe = "Someone the building kept", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { sanity = 2, log = "They turned round, still themselves, mostly, and came with {crew}." },
						lose = { sanity = -18, condition = "dz_terror", log = "They turned round. It was {champion}'s face." },
						next = "heart",
					},
					{
						label = "Turn off every kettle",
						hint = "Intelligence check.",
						clash = { stat = "intelligence", foe = "A hundred kettles", coins = 3, base = 6, coinPower = 3, fixed = true },
						win = { intelligence = 2, log = "One by one, {crew} turned off the kettles. In the silence, a small door opened at the back of the last kitchen." },
						lose = { health = { -16, -8 }, condition = "burns", log = "Every kettle boiled over at once.", cause = "Scalded in the kitchens of Number Nine" },
						next = "heart",
					},
				},
			},
			heart = {
				title = "The Small Room",
				text = "Behind the last door is a child's bedroom, very small, with a nightlight. This is where it started. A child's voice asks {crew} to stay, just for tonight, just forever.",
				tone = "danger",
				choices = {
					{
						label = "Promise to come back",
						hint = "Mental Strength check. Very bad odds.",
						clash = { stat = "mind", foe = "A promise it will hold you to", coins = 4, base = 8, coinPower = 4, fixed = true },
						win = { sanity = 6, setFlags = { "dz_unsurvivable" }, log = "\"Promise?\" it asked, and {champion} promised, and meant it. The nightlight went out, and the building let everyone go." },
						lose = { die = "Stayed forever in Number Nine", log = "It believed the promise so completely that it couldn't let you go." },
						winEnd = "success",
						loseEnd = "fail",
					},
					{
						label = "Break the nightlight",
						clash = { stat = "strength", foe = "The heart of Number Nine", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "sinking", potency = 3 } },
						win = { strength = 3, log = "The nightlight broke, and the whole building screamed, and then it was only a building with five floors and a broken lift." },
						lose = { health = { -28, -16 }, sanity = -10, log = "The room fought back with everything the building had ever taken.", cause = "Fought the heart of Number Nine" },
						winEnd = "success",
						loseEnd = "fail",
					},
					{ label = "Back out the way you came", result = { sanity = -10, log = "{crew} backed out of the little room and ran down a staircase that finally, mercifully, ended." }, ["end"] = "retreat" },
				},
			},
		},
		success = { wage = { 200, 400 }, sanity = 4, gear = "dz_nine_key", setFlags = { "dz_nine_escaped" }, clearFlags = { "dz_nine_open" }, chronicle = "dz_act_number_nine", codex = "dz_lore_number_nine", book = "book_pianist_score", log = "{crew} came down into daylight with the one who went in. On the bottom step lay a torn music score nobody had seen before. The neighbors took up a collection." },
		fail = { sanity = -8, log = "Number Nine kept what it had. It always does." },
		retreat = { sanity = -4, log = "{crew} got out. Number Nine is still there, and the voice is still calling." },
	},
}
