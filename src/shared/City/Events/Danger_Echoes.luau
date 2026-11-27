--[[
	Danger and horror (dz_): echoes. Each fires only after another player on the server has
	done the act (when.chronicle); {actor} and {actorDistrict} name them. One player's worst
	night becomes a rumor, a bounty or a new danger in someone else's life.
		dz_act_distortion_loose  -> dz_echo_loose
		dz_act_claw_witness      -> dz_echo_claw -> (1 year) dz_echo_blank
		dz_act_long_night        -> dz_echo_night_runner   (opens Eighty Minutes)
		dz_act_outskirts         -> dz_echo_followed       (can open Past the Last Wall)
		dz_act_number_nine       -> dz_echo_nine           (can open Number Nine)
		dz_act_breach_held       -> dz_echo_breach
		dz_act_ring_escape       -> dz_echo_ring
]]

return {
	{
		id = "dz_echo_loose",
		title = "Still Out There",
		text = "Fixers are pasting up warnings: the Distortion {actor} ran from in {actorDistrict} is still loose, and it's moving. Last night it was seen two streets from yours.",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { world = { era = { "library", "limbus" } }, chronicle = "dz_act_distortion_loose", minAge = 14 },
		codex = "terms_distortion",
		choices = {
			{ label = "Stay in after dark", result = { sanity = -3, money = -25, log = "You stayed in every night for a month and lost a little pay to it. The warnings came down in spring." } },
			{
				label = "Take the posted bounty",
				clash = { stat = "strength", foe = "A Distortion on the move", coins = 3, base = 8, coinPower = 4, fight = true, status = { id = "sinking", potency = 2 } },
				win = { strength = 3, wage = { 200, 400 }, setFlags = { "dz_distortion_survivor" }, log = "You found it in a closed cinema and finished what nobody else would. The bounty was real." },
				lose = { health = { -22, -10 }, log = "You found it. That was the problem.", cause = "Hunted a loose Distortion" },
			},
			{
				label = "Help evacuate the street",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Forty doors before dark", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = 2, intelligence = 2, log = "You knocked on forty doors before dark. When it came through the next night, the street was empty." },
				lose = { health = { -14, -5 }, sanity = -4, log = "It came through while you were still knocking.", cause = "Evacuating a street ahead of a Distortion" },
			},
		},
	},
	{
		id = "dz_echo_claw",
		title = "A Street Nobody Remembers",
		text = "The rumor is that {actor} saw a Claw at work in {actorDistrict}, and lived. Since then the noodle stall where {actor} used to eat has a new name, and nobody can remember the old one.",
		weight = 8,
		once = true,
		when = { chronicle = "dz_act_claw_witness", minAge = 12 },
		codex = "dz_lore_claws",
		choices = {
			{ label = "Keep your head down", result = { sanity = -2, mind = 1, log = "You stopped repeating the rumor, and so did everyone else, all at the same time." } },
			{
				label = "Ask questions",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A City that doesn't like questions", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { mind = 2, codex = "dz_lore_erased", log = "An old cook told you, very quietly, that the Head checks its work. Then she wiped the counter where you'd leaned, twice." },
				lose = { sanity = -6, condition = "dz_hunted", log = "You asked one person too many. A drone sat on your windowsill for a week." },
			},
			{ label = "Write it all down", result = { sanity = -2, setFlags = { "dz_wrote_it" }, schedule = { event = "dz_echo_blank", inYears = 1 }, log = "You wrote down everything you'd heard in a notebook and hid it under a floorboard." } },
		},
	},
	{
		id = "dz_echo_blank",
		title = "The Notebook",
		text = "You lift the floorboard to add a page. The notebook is where you left it. Every page is blank, and the pencil beside it has been sharpened.",
		weight = 0,
		when = { flags = { "dz_wrote_it" } },
		codex = "dz_lore_erased",
		choices = {
			{ label = "Burn it", result = { sanity = -4, clearFlags = { "dz_wrote_it" }, log = "You burned the blank notebook. You slept very badly, and then, after a while, fine." } },
			{
				label = "Write it all again",
				hint = "Mental Strength check. Very bad odds.",
				clash = { stat = "mind", foe = "Someone reading over your shoulder", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -8, setFlags = { "dz_unsurvivable" }, clearFlags = { "dz_wrote_it" }, log = "You wrote it all again, and in the morning the pages were still full. Someone, somewhere, decided to let you keep it." },
				lose = { die = "Erased for writing it down", log = "You wrote until three. By morning, nobody remembered your name either." },
			},
		},
	},
	{
		id = "dz_echo_night_runner",
		title = "Night Runner Wanted",
		text = "Word is {actor} carried a sealed parcel across {actorDistrict} during the Night, and delivered it. Now there's a card up at the courier office: NIGHT RUNNER WANTED. 1,000 AHN.",
		weight = 8,
		once = true,
		when = { chronicle = "dz_act_long_night", minAge = 18, side = "backstreets" },
		codex = "dz_lore_night_bargains",
		choices = {
			{ label = "Take the card down", result = { setFlags = { "dz_night_job" }, log = "A clerk handed you a sealed parcel and an address. \"Whenever you're ready,\" she said, \"but it must go during the Night.\"" } },
			{ label = "Ask how {actor} did it", result = { mind = 2, log = "Nobody knew. The clerk said only, \"They didn't stop, not once, not for anything.\"" } },
			{ label = "Walk past it", result = { sanity = 1, log = "You walked past the card every day for a month until someone took it down. You hope they're all right." } },
		},
	},
	{
		id = "dz_echo_followed",
		title = "Something Followed",
		text = "{actor} came back from the Outskirts past {actorDistrict}'s wall with a crate of salvage. Something followed. For three nights now, something tall has been walking the edge of your District too.",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { chronicle = "dz_act_outskirts", minAge = 14 },
		codex = "dz_lore_outskirts",
		choices = {
			{ label = "Keep inside after dark", result = { sanity = -4, log = "On the fourth night it went away, back out past the wall, carrying something." } },
			{
				label = "Hunt it with the watch",
				clash = { stat = "strength", foe = "Something from the Outskirts", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "tremor", potency = 2 } },
				win = { strength = 3, wage = { 150, 300 }, log = "Eleven of you went out with lamps and hooks. It went back over the wall, slower than it came." },
				lose = { health = { -22, -10 }, log = "Eleven of you went out with lamps.", cause = "Hunted something from the Outskirts" },
			},
			{ label = "Get a copy of the map", result = { setFlags = { "dz_outskirts_job" }, log = "You got a copy of {actor}'s map, hand-drawn, with one place circled and the word DON'T beside it. The Outskirts run is open to you now." } },
		},
	},
	{
		id = "dz_echo_nine",
		title = "Number Nine Moved",
		text = "{actor} walked out of Number Nine, Bellhouse Row, and the building didn't like it. This morning Number Nine is on your street, between the bakery and the laundry, where there was never a gap.",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { chronicle = "dz_act_number_nine", minAge = 14 },
		choices = {
			{ label = "Move away", hint = "100 Ahn.", requires = { min = { money = 100 } }, result = { money = -100, sanity = -3, log = "You moved, and your new street is fine. You check the gaps between buildings every morning anyway." } },
			{
				label = "Board up its door",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A door that opens from inside", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -2, intelligence = 2, log = "You and the baker nailed planks across the door. By spring Number Nine was gone again, and the bakery had its old wall back." },
				lose = { sanity = -10, condition = "dz_terror", log = "The planks were pulled off from the inside, neatly, and stacked on the step." },
			},
			{ label = "Go in", requires = { minAge = 16 }, result = { setFlags = { "dz_nine_open" }, sanity = -3, log = "You went home for a lamp, a rope and a coat. Number Nine will wait; it always does." } },
		},
	},
	{
		id = "dz_echo_breach",
		title = "Unusual Visitors",
		text = "{actor} held a stairwell shut in {actorDistrict} against something that got out of L Corp. Now L Corp is quietly paying Backstreets people to report \"unusual visitors\". There's a form.",
		weight = 8,
		once = true,
		when = { chronicle = "dz_act_breach_held", minAge = 14, world = { era = "wings" } },
		codex = "dz_lore_overspill",
		choices = {
			{ label = "Sign up as a watcher", result = { wage = { 30, 60 }, sanity = -3, log = "You got a whistle, a form and a number to call. You called it twice that year, and both times a van came." } },
			{ label = "Report the strange neighbor", result = { money = 40, sanity = -6, log = "You reported the man upstairs who hums at night, and a van came. He was just a man who hummed, and he doesn't live there any more." } },
			{ label = "Throw the form away", result = { sanity = 1, log = "Whatever comes up out of the shafts, you'd rather not be the one who knows about it." } },
		},
	},
	{
		id = "dz_echo_ring",
		title = "A Replacement Exhibit",
		text = "{actor} walked out of a Ring exhibition in {actorDistrict} before the doors locked, and now the exhibition is one piece short. A gilded invitation with your name on it arrives the next morning.",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { chronicle = "dz_act_ring_escape", minAge = 16 },
		codex = "fn_lore_ring",
		choices = {
			{ label = "Burn the invitation", result = { sanity = -3, setFlags = { "dz_ring_noticed" }, schedule = { event = "dz_f_commission", inYears = 1 }, log = "You burned it in the sink. The next morning a second one came, with a note: \"We'll come to you.\"" } },
			{ label = "Sell the invitation", result = { money = { 100, 200 }, sanity = -6, log = "A collector paid well for it. A week later you read his name on the morning list." } },
			{
				label = "Go, and count the exits",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A Docent's attention", coins = 2, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -6, chronicle = "dz_act_ring_escape", log = "You went, counted every exit, and left by the third at a stroll. Behind you, the doors locked." },
				lose = { sanity = -4, trigger = "dz_f_exhibition_locked", log = "The exits were all painted on." },
			},
		},
	},
}
