--[[
	The Night in the Backstreets (area A). Every night at 3:13 the Sweepers rise along the
	Nest's edge and march through the Backstreets for eighty minutes, in three waves with
	about ten minutes of quiet between. Recording the Night and breaking into a home are
	City Taboos, so a locked home is the safest place in the City. Canon: CANON.md 1.5,
	and the Sweepers' own pages in Library of Ruina.

	Caught outside (a chain, same year, through `trigger`):
		bs_n_out_start -> bs_n_out_wave1 -> bs_n_out_quiet -> bs_n_out_last -> bs_n_out_dawn
	Other scenes can drop you into the chain at the first wave (a lost dare, a snapped key,
	a door held open too long). Surviving sets bs_night_survivor.
	Tags: "night" (the Long Night world event makes these likelier), "danger", "backstreets".
]]

local NIGHT_FLAGS = { "bs_n_hidden", "bs_n_helped" }

return {
	-- ── caught outside ─────────────────────────────────────────────────────
	{
		id = "bs_n_out_start",
		title = "2:58",
		text = "You're three streets from home when you hear the clock over the pharmacy: it's 2:58. You lost track of time. The street is already empty, every shutter down, every door locked twice. Somewhere a dog has stopped barking. Fifteen minutes.",
		weight = 3,
		once = true,
		tags = { "night", "danger", "backstreets" },
		when = { side = "backstreets", minAge = 15, maxAge = 70 },
		codex = "city_sweepers",
		choices = {
			{
				label = "Run for home",
				hint = "Speed check against the clock.",
				clash = { stat = "speed", foe = "Fifteen minutes", coins = 1, base = 3, coinPower = 2 },
				win = { speed = 1, sanity = 2, log = "You ran like you were eight years old again and got your door shut at 3:12, as the floor began to hum. You sat with your back against it, laughing and shaking, until the first wave had passed." },
				lose = { trigger = "bs_n_out_wave1", log = "A gate you always cut through had been chained shut. You doubled back. Halfway down the next street, the clock in the square struck the quarter, and the ground began to hum." },
			},
			{
				label = "Bang on the nearest door",
				hint = "Intelligence check: talk a stranger into opening up, fast.",
				clash = { stat = "intelligence", foe = "A frightened stranger behind three locks", coins = 1, base = 3, coinPower = 2 },
				win = { sanity = 3, addRelation = { kind = "friend", bond = 50, age = { 60, 74 } }, log = "An old voice asked three questions through the door, and you answered all three right. The locks turned. You spent the Night on {newRelation}'s kitchen floor, drinking tea in the dark and not talking, and it was the strangest friendship of your life." },
				lose = { trigger = "bs_n_out_wave1", log = "Nobody opened. Nobody ever opens after 3:00, and you'd have done the same. Behind you, the ground began to hum." },
			},
			{
				label = "Get under the fish market's stone counters",
				result = { mind = 1, setFlags = { "bs_n_hidden" }, trigger = "bs_n_out_wave1", log = "You crawled under the long stone counters of the fish market, as far back as you could get, and pressed yourself into the cold. At 3:13 the ground began to hum." },
			},
		},
	},
	{
		id = "bs_n_out_wave1",
		title = "The First Wave",
		text = "The hum becomes a tremor, and the tremor becomes a sound like a great crowd walking. They come up the street from the direction of the Nest: figures, dozens, then hundreds, all moving the same way at the same slow pace, filling the road from wall to wall like water. Behind them, the street is clean. They're here. You're outside.",
		weight = 0,
		tags = { "night" },
		when = { side = "backstreets" },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Hold perfectly still in the shadows",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The first wave", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = -3, trigger = "bs_n_out_quiet", log = "You didn't breathe. They passed close enough to touch, close enough to hear them murmuring in pieces, \"sweeping... ahead... without stopping...\" and none of them turned. Then the street was empty." },
				lose = { health = { -10, -5 }, sanity = -5, trigger = "bs_n_out_quiet", log = "One of them brushed past you and the cold went right through your coat into your bones. You tore free and ran, and somehow the wave let you go. You don't know why.", cause = "Swept away in the Night" },
			},
			{
				label = "Stand your ground",
				hint = "A real fight. They say the Sweepers only pass those strong enough to stand.",
				clash = { stat = "health", foe = "The first wave of Sweepers", coins = 3, base = 6, coinPower = 3, fight = true },
				win = { strength = 3, sanity = -2, setFlags = { "bs_stood_ground" }, trigger = "bs_n_out_quiet", log = "You planted your feet and fought the ones that reached you, and the strangest thing happened: the rest stepped around you, the way water goes around a stone, and walked on." },
				lose = { health = { -16, -8 }, sanity = -6, trigger = "bs_n_out_quiet", log = "You fought, and there were too many, and you went down. When you could see again the wave was past, and you were alive, and you could not understand why.", cause = "Swept away in the Night" },
			},
			{
				label = "Get to the doorway behind the laundry vent",
				requires = { flags = { "bs_knows_doorways" } },
				result = { sanity = -2, mind = 2, trigger = "bs_n_out_quiet", log = "The secret doorway from your childhood game, behind the laundry's steam vent. You'd kept it a secret all these years. You folded yourself into it, and the wave went by in front of you, and none of them looked in. It turned out to matter." },
			},
			{
				label = "Stay under the stone counter",
				requires = { flags = { "bs_n_hidden" } },
				result = { sanity = -4, mind = 1, trigger = "bs_n_out_quiet", log = "You stayed pressed into the cold under the counter while their feet went past at the height of your eyes. Hundreds of them. It took nine minutes. You counted every second." },
			},
		},
	},
	{
		id = "bs_n_out_quiet",
		title = "Ten Minutes",
		text = "The wave is past. The street is empty, wet and very clean: the posters are gone, the bins are gone, a shop's illegal awning is simply gone. You have about ten minutes before the second wave rises. Then you hear it: an old man in a doorway down the street, trying to stand up on a bad leg. He was caught out too.",
		weight = 0,
		tags = { "night" },
		when = { side = "backstreets" },
		choices = {
			{
				label = "Run for home now",
				hint = "Speed check: ten minutes, three streets.",
				clash = { stat = "speed", foe = "The quiet between waves", coins = 2, base = 3, coinPower = 2 },
				win = { sanity = 1, trigger = "bs_n_out_dawn", log = "You ran, and made your own door before the second wave rose, and locked it with hands that didn't feel like yours. The rest of the Night happened on the other side of it." },
				lose = { trigger = "bs_n_out_last", log = "You made it two streets before the ground started humming again, ahead of you this time. You had to stop. You had to hide. The second wave was coming." },
			},
			{
				label = "Help the old man",
				hint = "Health check: you'll be carrying him.",
				clash = { stat = "health", foe = "A heavy old man and very little time", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = 4, setFlags = { "bs_n_helped" }, trigger = "bs_n_out_last", log = "You got his arm over your shoulders and half-carried him into an alcove under a bridge before the second wave rose. He gripped your sleeve and said, \"Thank you, thank you,\" over and over, very quietly." },
				lose = { health = { -6, -3 }, setFlags = { "bs_n_helped" }, trigger = "bs_n_out_last", log = "He was heavier than he looked and your back screamed, but you got him into an alcove under the bridge just as the ground began to hum again." },
			},
			{
				label = "Find a better hiding place",
				result = { mind = 1, setFlags = { "bs_n_hidden" }, trigger = "bs_n_out_last", log = "You found a coal chute behind a bakery and slid inside, feet first, into the dark. It smelled of soot and old bread. It was perfect. At the edge of hearing, the ground began to hum." },
			},
		},
	},
	{
		id = "bs_n_out_last",
		title = "The Second and Third Waves",
		text = "The second wave comes, and passes, and the quiet after it is shorter than you expected, and then the third wave rises, the longest. Eighty minutes, the old people always say. You stop believing in time somewhere in the middle of it.",
		weight = 0,
		tags = { "night" },
		when = { side = "backstreets" },
		choices = {
			{
				label = "Hold on",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The last two waves", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -4, trigger = "bs_n_out_dawn", log = "You held on. You thought about your door, your bed, a bowl of noodles, anything. The waves went past, and past, and then didn't come again." },
				lose = { health = { -10, -5 }, sanity = -6, condition = "night_terrors", trigger = "bs_n_out_dawn", log = "The third wave found you. You don't remember all of it. You remember the cold, and the murmuring, and wrenching yourself out of it again and again until it was over.", cause = "Swept away in the Night" },
			},
			{
				label = "Stand your ground",
				hint = "A real fight, the hardest of your life.",
				clash = { stat = "health", foe = "The third wave of Sweepers", coins = 3, base = 6, coinPower = 3, fight = true },
				win = { strength = 3, health = 2, setFlags = { "bs_stood_ground" }, trigger = "bs_n_out_dawn", log = "You stood in the middle of the street and did not move, and they parted around you like a river around a pillar, wave after wave, and none of them came back for you." },
				lose = { health = { -16, -8 }, sanity = -6, trigger = "bs_n_out_dawn", log = "You fought until you couldn't, and then you curled up against a wall and waited to be swept. It didn't happen. It was the longest hour of your life.", cause = "Swept away in the Night" },
			},
			{
				label = "Stay hidden, and count",
				requires = { flags = { "bs_n_hidden" } },
				result = { sanity = -5, mind = 2, trigger = "bs_n_out_dawn", log = "You stayed in your hiding place and counted, the way you did as a child: one wave, quiet, two waves, quiet, three. Then nothing. Then birds." },
			},
			{
				label = "Keep the old man talking",
				requires = { flags = { "bs_n_helped" } },
				result = { sanity = 2, trigger = "bs_n_out_dawn", log = "You kept him talking in a whisper: his grandchildren, his old shop, the Night he was born. He kept you talking back. Neither of you looked at the street. It was, somehow, not the worst hour of your life." },
			},
		},
	},
	{
		id = "bs_n_out_dawn",
		title = "Dawn",
		text = "Then it's over. The last wave sinks back into the ground along the Nest wall, the hum fades out of the stones, and the birds start up as if nothing happened. The streets are cleaner than you have ever seen them. You walk home through them slowly, like someone who has been away for a very long time.",
		weight = 0,
		tags = { "night" },
		result = {
			sanity = 3,
			mind = 2,
			setFlags = { "bs_night_survivor" },
			clearFlags = NIGHT_FLAGS,
			addTrait = "survivor_of_the_night",
			codex = "bs_lore_sweepers",
			chronicle = "bs_act_night_walk",
			log = "You were caught outside during the Night, and you lived. The whole street knew by noon. Old people you'd never met stopped you to shake your hand and asked you, very quietly, what they had said to you.",
		},
	},

	-- ── the rules, and the people who forget them ──────────────────────────
	{
		id = "bs_n_last_customer",
		title = "The Last Customer",
		text = "It's 2:44. The noodle stall is closing and the owner is stacking stools, but one customer won't go: a well-dressed man from the Nest, out on a day pass, haggling over the price of a bowl as if he has all the time in the world. He doesn't seem to know what time it is. Or what that means.",
		weight = 5,
		cooldown = 15,
		tags = { "night", "backstreets" },
		when = { side = "backstreets", minAge = 16 },
		choices = {
			{
				label = "Walk him to the checkpoint, fast",
				hint = "Strength check: twenty-nine minutes.",
				clash = { stat = "strength", foe = "A slow man and a long way", coins = 1, base = 3, coinPower = 2 },
				win = { sanity = 3, money = { 20, 60 }, log = "You took his arm and walked him to the Nest checkpoint at a pace he complained about the whole way. The guards let him through at 3:05. He tipped you generously, in a daze. Then you ran home, and made it." },
				lose = { sanity = -3, log = "He wouldn't hurry. You got him to the checkpoint at 3:10 and ran, and slammed your own door at 3:12 with your heart in your throat. He never knew how close it was. He never came back, either." },
			},
			{
				label = "Let him sleep on your floor",
				result = { sanity = 2, money = { 30, 80 }, log = "You took him home and told him to sit down, be quiet and not look out the window. At 3:13 the floor hummed and he finally understood. In the morning he gave you every Ahn in his wallet and left without a word." },
			},
			{
				label = "Tell the owner to leave him",
				result = { sanity = -4, log = "\"Not your problem,\" you said, and the owner agreed, and you both went home. In the morning the stall was there, swept spotless, and the stool he'd been sitting on was gone." },
			},
		},
	},
	{
		id = "bs_n_footage",
		title = "Night Footage",
		text = "A collector from the Nest has been asking around your building. He'll pay three thousand Ahn for one thing: real footage of the Night. The Sweepers, the waves, the empty streets. \"From your own window,\" he says, \"perfectly safe.\" Recording the Night is a City Taboo, one of the Head's own laws. He knows that. He's counting on you not caring.",
		weight = 3,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 20, maxAge = 65 },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Refuse",
				result = { mind = 2, sanity = 1, log = "You said no and shut the door. A week later the collector's office in the Nest was empty, the sign was gone, and the shopkeeper next door said there had never been an office there." },
			},
			{
				label = "Warn the neighbors about him",
				result = { mind = 1, sanity = 2, relationBond = { kind = "all", amount = 3 }, log = "You went door to door and told everyone in the building not to touch his money. Nobody did. Your neighbors brought you dumplings for a week, which in the Backstreets is how you say \"you may have saved my life.\"" },
			},
			{
				label = "Do it. Three thousand Ahn.",
				hint = "Only someone at the very end of their rope would. This is a City Taboo, and the Head's arms don't hold trials.",
				requires = { max = { sanity = -20, money = 300 } },
				result = { chronicle = "bs_act_recorded_night", die = "Erased for recording the Night", log = "You set up the camera in the window at 3:10. At 3:13 you pressed the button. In the morning your door was gone, and so was your name, and nobody on the street could remember who had lived there." },
			},
		},
	},
	{
		id = "bs_n_lamplight",
		title = "The Lamplight House",
		text = "Grandmother Ilse has run the Lamplight House for forty years: a night shelter with one rule, that the door opens to anyone until 3:12 and not one second after. Tonight she needs a second pair of hands. By 3:05 the floor is full of strangers. At 3:11 there's a knock, and a voice, and footsteps running toward the door from far down the street.",
		weight = 5,
		cooldown = 12,
		tags = { "night", "backstreets" },
		when = { side = "backstreets", minAge = 16 },
		choices = {
			{
				label = "Hold the door until the last second",
				hint = "Mental Strength check: it must be shut by 3:13.",
				clash = { stat = "mind", foe = "The last second", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = 5, addTrait = "bs_door_keeper", setFlags = { "bs_kept_door" }, chronicle = "bs_act_shelter", log = "You held the door, and counted, and the runner came through it at 3:12 and fell flat on the floor, and you slammed it shut and turned all three locks. Grandmother Ilse put her hand on your shoulder and said nothing at all, which was everything." },
				lose = { health = { -6, -3 }, sanity = -4, addTrait = "bs_door_keeper", setFlags = { "bs_kept_door" }, log = "You held it too long. The runner made it in, but something cold came through the gap with the last of the night air before you got it shut. Everyone inside lived. You didn't sleep for days." },
			},
			{
				label = "Run out and drag them in",
				hint = "Speed check. If you're too slow, you're the one outside.",
				clash = { stat = "speed", foe = "Twenty meters and two minutes", coins = 2, base = 3, coinPower = 2 },
				win = { speed = 2, sanity = 5, addTrait = "bs_door_keeper", setFlags = { "bs_kept_door" }, chronicle = "bs_act_shelter", log = "You sprinted out, grabbed a girl with a courier's satchel by the collar, and hauled her back in through the door with seconds to spare. Grandmother Ilse locked it behind you and called you a fool and hugged you, in that order." },
				lose = { trigger = "bs_n_out_wave1", log = "You got the girl through the door. Grandmother Ilse had to shut it before you could follow. Its locks turned at 3:13 exactly, with you on the wrong side of them." },
			},
			{
				label = "Keep the door shut",
				result = { sanity = -5, mind = 1, log = "\"Rule's a rule,\" you said, and kept it shut at 3:11, a minute early. The knocking stopped during the first wave. Grandmother Ilse didn't say anything. She didn't ask you back." },
			},
		},
	},
	{
		id = "bs_n_snapped_key",
		title = "The Key Snaps",
		text = "2:52. You're on your own doorstep, nearly home, and your key snaps off in the lock. You stare at the half in your hand. The stairwell light flickers. Twenty-one minutes.",
		weight = 3,
		once = true,
		tags = { "night", "danger", "backstreets" },
		when = { side = "backstreets", minAge = 16, maxAge = 70 },
		choices = {
			{
				label = "Pick the lock",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Your own three locks", coins = 2, base = 3, coinPower = 2 },
				win = { intelligence = 2, sanity = 1, log = "Hairpin, the snapped key, and very steady breathing. The third lock gave at 3:07. You've carried a spare key on a string ever since." },
				lose = { trigger = "bs_n_out_wave1", log = "The broken key jammed the third lock for good. You tried every door on the landing. Nobody opened after three. At 3:13 the stairwell light went out and the ground began to hum." },
			},
			{
				label = "Use your tool roll",
				requires = { hasGear = "bs_tool_roll" },
				result = { intelligence = 1, sanity = 2, log = "Your apprentice's tool roll had a little pick and an extractor in it, for exactly this. You had the broken half out and the door open by 2:58. Master Ulrike would have been proud, and slightly disappointed it took six minutes." },
			},
			{
				label = "Knock for the neighbor",
				hint = "Mental Strength check: they have to believe it's you.",
				clash = { stat = "mind", foe = "A neighbor who doesn't open after two", coins = 1, base = 3, coinPower = 2 },
				win = { sanity = 2, relationBond = { kind = "all", amount = 2 }, log = "You told the neighbor through the door exactly what you'd had for dinner last week, since she'd been nosy about it. She opened up. You spent the Night on her sofa and paid for a locksmith in the morning." },
				lose = { trigger = "bs_n_out_wave1", log = "\"Nice try,\" said the voice behind the door. \"Everybody says they're the neighbor.\" At 3:13 the stairwell light went out and the ground began to hum." },
			},
		},
	},
	{
		id = "bs_n_telescope",
		title = "The Telescope",
		text = "Your neighbor in the Nest has bought a brass telescope and pointed it over the wall at the Backstreets. He's invited friends round for 3:13, \"to see the Night with our own eyes, perfectly legal, nothing recorded.\" Peeking at the Night isn't exactly recording. It isn't exactly not, either.",
		weight = 4,
		once = true,
		tags = { "night" },
		when = { side = "nest", minAge = 18, maxAge = 70 },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Go, and look",
				result = { sanity = -5, mind = 1, setFlags = { "bs_saw_sweepers" }, log = "Through the telescope: a gray tide in the Backstreets, moving street by street, and the streets coming out clean behind it. Everyone laughed nervously. You didn't. Three weeks later the neighbor moved away very suddenly, and his flat was let to someone new." },
			},
			{
				label = "Stay home, with the curtains shut",
				result = { mind = 2, sanity = 1, log = "You stayed home with the curtains shut. Three weeks later the neighbor moved away very suddenly. Nobody in the building could say where." },
			},
			{
				label = "Tell him it's a bad idea",
				hint = "Mental Strength check: Nest people don't like being told.",
				clash = { stat = "mind", foe = "Your neighbor's curiosity", coins = 2, base = 3, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "You told him what Backstreets people say about the Night and the Claws. He laughed, and then stopped, and put the telescope away in a cupboard. He stayed in the building for twenty more years." },
				lose = { sanity = -2, log = "He laughed at you. Three weeks later he moved away very suddenly, and his telescope was the only thing left in the empty flat." },
			},
		},
	},
	{
		id = "bs_n_morning_after",
		title = "After the Night",
		terms = { "The Night" },
		text = "You're up early, and the street is the way it only is at dawn: scrubbed clean, the night's posters gone, a stall someone forgot to pack away simply missing, and in the gutter by the bakery, one good shoe. Just the one. People step around it on their way to work and don't look down.",
		weight = 5,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 10 },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Ask around about the shoe",
				result = { mind = 2, sanity = -3, log = "Nobody knew whose it was. Somebody's, said the baker, gently. Somebody who thought they had time. By noon the shoe was gone too." },
			},
			{
				label = "Leave it, and go to work",
				result = { sanity = -1, intelligence = 1, log = "You stepped around it like everyone else. You thought about it all day. The next night you were home by two." },
			},
			{
				label = "Look for the missing stall",
				result = { mind = 1, sanity = -2, log = "Where the stall had been, the pavement was paler, as if it had been scrubbed down to the stone. The stallholder was there, alive, staring at the clean square. He'd left it out to save time packing. \"Just once,\" he kept saying." },
			},
		},
	},
	{
		id = "bs_n_missing_floor",
		title = "The Missing Floor",
		text = "Your landlord built a new floor on top of the building last spring, cheap, quick, and without a permit. He rented it out as storage. This morning there is no new floor. The roof is the old roof again, wet and clean, as if the extra floor had been a rumor. The landlord is standing in the street, looking up, holding a ledger.",
		weight = 4,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 14 },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Ask what was stored up there",
				result = { mind = 1, sanity = -1, log = "\"Nothing important,\" he said. \"Furniture. A few boxes.\" Then, quieter: \"The Sweepers take anything built without papers. Everybody knows that. I knew that.\" He tore the page out of his ledger." },
			},
			{
				label = "Check your own room is still there",
				result = { sanity = 1, log = "You ran upstairs. Your room was there, every inch, with its legal permit pinned behind the door where your parents had always kept it. You looked at the permit for a long time." },
			},
		},
	},
}
