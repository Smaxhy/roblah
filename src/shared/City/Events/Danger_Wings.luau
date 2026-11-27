--[[
	Danger and horror (dz_): the age of the Wings, when something occasionally got out of
	Lobotomy Corporation and into the Backstreets of District 12 (see dz_lore_overspill).
	Abnormalities come from CANON.md 5.9's gentler roster and are shown only by effect.
	Chain: dz_w_lantern -> dz_w_lantern_walk
]]

return {
	{
		id = "dz_w_lantern",
		title = "A Lantern in the Alley",
		text = "L Corp's sirens are howling again. A lantern hangs in the alley where nobody hung it, swaying a little. The longer you look at it, the more you want to walk toward it.",
		weight = 4,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, district = "d12", world = { era = "wings" } },
		codex = "dz_lore_overspill",
		choices = {
			{
				label = "Look away and go home",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A lantern that wants you", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -4, log = "You turned your head and walked home staring at your shoes. In the morning three people on your street were missing." },
				lose = { sanity = -4, trigger = "dz_w_lantern_walk", log = "You looked a moment too long." },
			},
			{
				label = "Smash it with a stone",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A swaying lantern", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { strength = 2, sanity = -2, log = "The lantern went out with a sound like a sigh. Somewhere far off, something very big turned its head." },
				lose = { sanity = -4, trigger = "dz_w_lantern_walk", log = "You missed. You looked at it to aim again, and that was the mistake." },
			},
			{
				label = "Drag your neighbor back",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A neighbor walking toward the light", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { strength = 2, sanity = -3, setFlags = { "dz_saw_breach" }, chronicle = "dz_act_breach_held", log = "Old Mr. Lim was already walking toward it. You tackled him into a doorway and held on until the sirens stopped." },
				lose = { sanity = -4, trigger = "dz_w_lantern_walk", log = "He was walking toward it, and so, a moment later, were you." },
			},
			{ label = "Shut your eyes and wait", result = { sanity = -6, log = "You stood with your eyes shut until the sirens stopped. When you opened them the lantern was gone, and so were the two people who'd been standing beside you." } },
		},
	},
	{
		id = "dz_w_lantern_walk",
		title = "Toward the Light",
		text = "You're walking toward the lantern and you can't stop. The alley is much longer than it should be. Behind the light, something enormous with a great many eyes is waiting, very patiently.",
		weight = 0,
		when = { world = { era = "wings" }, minAge = 14 },
		codex = "lc_abno_big_bird",
		choices = {
			{
				label = "Think of home",
				hint = "Mental Strength check. Your coins flip fair.",
				clash = { stat = "mind", foe = "The lantern's pull", coins = 2, base = 5, coinPower = 3, fixed = true, ignoreSanity = true },
				win = { sanity = -8, setFlags = { "dz_saw_breach" }, log = "You thought of your front door, the three locks, the smell of the stairwell, and your feet stopped. You walked home backwards." },
				lose = { die = "Followed a lantern into the dark", log = "The alley went on, and so did you." },
			},
			{
				label = "Grab a drainpipe and hold on",
				hint = "Health check.",
				clash = { stat = "health", foe = "The lantern's pull", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -6, health = { -6, -2 }, setFlags = { "dz_saw_breach" }, log = "You held the drainpipe until your hands went numb, and L Corp's suppression team walked past you toward the light.", cause = "Held on against the lantern" },
				lose = { health = { -18, -8 }, sanity = -10, condition = "dz_terror", log = "Your hands opened by themselves. An agent caught your collar ten steps from the light and threw you back the way you'd come.", cause = "Walked too close to Big Bird's lantern" },
			},
		},
	},
	{
		id = "dz_w_ember_girl",
		title = "The Girl Made of Embers",
		text = "Something has got out of L Corp. A girl made of ember and ash is walking down your street, looking in at windows. Wherever she stops, the curtains catch.",
		weight = 4,
		once = true,
		tags = { "danger" },
		when = { minAge = 13, district = "d12", world = { era = "wings" } },
		codex = "lc_abno_scorched_girl",
		choices = {
			{
				label = "Wet the curtains, keep still",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A girl at your window", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -4, log = "She looked in at you through the wet glass for a long minute, then moved on. The house next door burned to its frame." },
				lose = { health = { -18, -8 }, condition = "burns", log = "She stopped at your window.", cause = "Burned when something from L Corp stopped at the window" },
			},
			{
				label = "Lead her away from the school",
				clash = { stat = "strength", foe = "The Scorched Girl", coins = 3, base = 7, coinPower = 4, fight = true, status = { id = "burn", potency = 3 } },
				win = { strength = 3, wage = { 100, 200 }, setFlags = { "dz_saw_breach" }, chronicle = "dz_act_breach_held", log = "You led her six streets to the canal, where L Corp's agents were waiting. They paid you, and made you sign something." },
				lose = { health = { -22, -10 }, log = "She caught up.", cause = "Burned leading an Abnormality away from a school" },
			},
			{
				label = "Sit with her",
				hint = "Mental Strength check. Very bad odds. She only wants company.",
				clash = { stat = "mind", foe = "A girl who wants someone to stay", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = 6, setFlags = { "dz_unsurvivable", "dz_saw_breach" }, addTrait = "dz_dread_calm", log = "You sat on the curb beside her until she leaned on your shoulder and went out like a candle. The agents found you there, unburned, and didn't know what to write." },
				lose = { die = "Stayed close to the Scorched Girl", log = "You stayed close. She was so glad." },
			},
			{ label = "Run out the back", result = { money = { -60, -20 }, sanity = -6, log = "You ran out the back with nothing. Your street burned behind you, house by house, until the agents came." } },
		},
	},
	{
		id = "dz_w_teddy",
		title = "A Very Big Bear",
		text = "There's a teddy bear on the playground bench, as tall as a door, stitched and smiling. It holds its arms out to you. L Corp's sirens are going in the distance.",
		weight = 4,
		once = true,
		when = { minAge = 6, maxAge = 12, district = "d12", world = { era = "wings" } },
		codex = "lc_abno_teddy",
		choices = {
			{ label = "Run home", result = { sanity = -3, log = "You ran all the way home and told no one. The next day the bench was gone." } },
			{ label = "Walk closer", result = { sanity = -8, health = { -3, -1 }, condition = "night_terrors", log = "Its arms closed just as a grown-up yanked you back by the collar. It got your coat instead, and you never got it back." } },
			{ label = "Wave and back away", result = { sanity = -2, mind = 2, log = "You waved, and it waved back, slowly. You backed away until it was out of sight, the way they teach you." } },
		},
	},
	{
		id = "dz_w_ticket_booth",
		title = "A Ticket Booth in the Alley",
		text = "An old ticket booth stands in the alley behind the bathhouse, where yesterday there was a wall. The sign says ONE TICKET. Far below the street, a train whistle blows.",
		weight = 4,
		once = true,
		when = { minAge = 14, district = "d12", world = { era = "wings" } },
		codex = "lc_abno_hell_train",
		choices = {
			{ label = "Buy a ticket", result = { die = "Bought a ticket for the express train", log = "The train came through the wall at midnight, very fast and very bright." } },
			{ label = "Report it to L Corp", result = { wage = { 20, 50 }, sanity = -3, setFlags = { "dz_saw_breach" }, log = "Two agents in black suits came, looked at it for a long time, and paid you to forget the alley's name." } },
			{ label = "Walk away", result = { sanity = -2, log = "When you came back, there was a wall again, and a smell like a burned-out fuse." } },
		},
	},
	{
		id = "dz_w_green_crate",
		title = "The Glowing Crate",
		text = "A crate stamped with L Corp's logo has fallen off a truck into your alley. It glows green through the slats: Enkephalin cells, the fuel half the City runs on. By morning someone will come looking.",
		weight = 3,
		once = true,
		when = { minAge = 14, world = { era = "wings" } },
		codex = "lcorp_enkephalin",
		choices = {
			{ label = "Leave it alone", result = { sanity = -1, log = "A grey van came for it at dawn, and two men in suits asked every door on the alley what they'd seen. You'd seen nothing." } },
			{
				label = "Sell the cells",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A green-market buyer", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { money = { 200, 400 }, sanity = -3, log = "A green-market stall paid well and asked nothing. The cells are powering someone's whole building now." },
				lose = { health = { -16, -8 }, condition = "enkephalin_sick", log = "One of the cells was cracked. You carried it a long way before you noticed the glow on your hands.", cause = "Carried a leaking Enkephalin cell" },
			},
			{
				label = "Hide it and wait",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "An L Corp retrieval team", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { money = { 300, 500 }, sanity = -4, log = "They searched the alley for a week and gave up. You sold the cells one by one, over a year, very carefully." },
				lose = { health = { -18, -8 }, sanity = -4, log = "They found it in your cellar. They were not interested in explanations.", cause = "Caught with L Corp's property" },
			},
		},
	},
}
