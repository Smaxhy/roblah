--[[
	Childhood events: ages 1-12.
	Threads started here:
		music_box        -> odd_music_box_plays -> odd_music_box_source (Strange)
		flag_name_asked  -> youth_flag_answer (Youth)
		sat_with_choir   -> youth_choir_mentor (Youth)
]]

return {
	{
		id = "child_first_steps",
		title = "First Steps",
		text = "The floorboards are cold and damp under your palms. Across the room the door to the landing stands open, and past it the stairs drop away into fog and pump-thump. Behind you, a spoon clinks against a pot of kelp broth.",
		once = true,
		tags = { "childhood" },
		when = { minAge = 1, maxAge = 2 },
		choices = {
			{
				label = "Crawl toward the open door",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The landing stairs", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 2, 3 }, sanity = 1, log = "You crawled all the way to the top step and sat there, enormously pleased with yourself." },
				lose = { fortitude = { -3, -1 }, sanity = -1, log = "You bumped down three stairs before somebody caught you by the collar." },
			},
			{
				label = "Crawl toward the clinking spoon",
				result = { fortitude = { 1, 2 }, sanity = 2, log = "You pulled yourself up on a chair leg and were rewarded with warm broth." },
			},
			{
				label = "Sit still and listen",
				result = { prudence = { 1, 2 }, sanity = 1, log = "You sat very still and listened to the pumps, as if you were counting them." },
			},
		},
	},
	{
		id = "child_pump_lullaby",
		title = "The Pump Lullaby",
		text = "Every night the great pumps thump under the tenement, steady as a slow heart. Tonight one of them coughs and misses a beat, and the whole stairwell holds its breath. The silence is louder than the noise ever was. You are wide awake.",
		cooldown = 4,
		tags = { "childhood", "terraces" },
		when = { minAge = 2, maxAge = 5, side = "gutters" },
		choices = {
			{
				label = "Count until the thumping comes back",
				result = { prudence = { 1, 3 }, sanity = 1, log = "You counted in the dark until the rhythm came back and carried you off to sleep." },
			},
			{
				label = "Wail until somebody comes",
				result = { sanity = 2, relationBond = { kind = "family", amount = 3 }, log = "You wailed until a pair of tired arms came and rocked you through the quiet." },
			},
			{
				label = "Climb out of bed to find the noise",
				result = { justice = { 1, 2 }, fortitude = { -1, 0 }, log = "You were found at the bottom of the stairwell with your ear pressed to the wall." },
			},
		},
	},
	{
		id = "child_broth_next_door",
		title = "Broth Next Door",
		text = "Nobody is home, and nobody has been home since the morning tram. Across the landing, old Edda Penhallow has left her door open a crack. Kelp broth steams on her stove, and she is pretending very hard not to notice you.",
		once = true,
		tags = { "childhood", "friend" },
		when = { minAge = 3, maxAge = 8, side = "gutters" },
		choices = {
			{
				label = "Knock on her door",
				result = {
					addRelation = { kind = "friend", name = "Edda Penhallow", bond = 55, age = { 62, 75 } },
					sanity = 3,
					log = "{newRelation} fed you broth and let you sort her button tin until dark.",
				},
			},
			{
				label = "Wait on your own stairs",
				result = { prudence = 2, sanity = -1, log = "You waited on the cold stairs until the tram bell brought your family home." },
			},
		},
	},
	{
		id = "child_lost_in_fog",
		title = "Lost in the Fog",
		text = "The fog comes up off the Mere so thick you can't see your own boots. The rope bridge sways under you. Ahead, a tram bell rings. Behind, the water slaps at the stilts. You let go of the rail for one second, and now you can't find it.",
		cooldown = 4,
		tags = { "childhood", "fog" },
		when = { minAge = 4, maxAge = 9, side = "gutters" },
		choices = {
			{
				label = "Walk toward the tram bell",
				hint = "Prudence clash, easy.",
				clash = { stat = "prudence", foe = "The fog", coins = 1, base = 2, coinPower = 2 },
				win = { prudence = { 2, 3 }, sanity = 1, log = "You walked toward the bell one careful step at a time and came out on solid stairs." },
				lose = { fortitude = { -3, -1 }, sanity = -3, log = "You walked in circles for an hour and came home soaked to the knees." },
			},
			{
				label = "Sit down and shout",
				result = { sanity = -2, prudence = 1, log = "You shouted until a dockhand with a lantern found you and carried you home." },
			},
			{
				label = "Feel your way along the ropes",
				result = { temperance = { 1, 2 }, fortitude = { -2, -1 }, log = "You followed the ropes hand over hand and came home with rope burn on both palms." },
			},
		},
	},
	{
		id = "child_music_box",
		title = "The Box in the Mud",
		text = "The tide has pulled back from the stilts and left the mud shining. Half buried by the third post sits a brass box no bigger than your hand, green at the corners. When you lift it, something inside turns over like a sleeper and plays three notes.",
		once = true,
		weight = 8,
		tags = { "childhood", "silt", "thread_music_box" },
		when = { minAge = 6, maxAge = 12, side = "gutters" },
		choices = {
			{
				label = "Hide it under your pillow",
				result = { setFlags = { "music_box" }, temperance = 1, sanity = -1, log = "You hid the brass box under your pillow and told nobody it was there." },
			},
			{
				label = "Sell it at the salvage dock",
				result = { money = { 6, 15 }, log = "A salvage trader paid you a few {currency} for the box and gave you a strange look." },
			},
			{
				label = "Throw it back into the Mere",
				result = { prudence = 1, sanity = 2, log = "You threw the box back into the Mere. It played one more note as it sank." },
			},
		},
	},
	{
		id = "child_eel_dare",
		title = "The Eel Dare",
		text = "The dock kids have caught a silt eel in a crab trap. It is long and pale and very calm, watching you through the slats. Pell Drabb, who is nine and claims to be eleven, dares you to put your hand on its back.",
		once = true,
		tags = { "childhood", "silt", "danger" },
		when = { minAge = 8, maxAge = 12, side = "gutters" },
		choices = {
			{
				label = "Touch the eel",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "Silt eel", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 2, 4 }, sanity = 2, log = "You laid your palm on the eel's cold back, and the dock kids went quiet with respect." },
				lose = { fortitude = { -5, -2 }, sanity = -2, log = "The eel turned faster than you knew anything could. Your hand ached for a week." },
			},
			{
				label = "Flip the latch and let it go",
				result = { prudence = { 1, 2 }, justice = 1, log = "You opened the trap and the eel slid home into the water. The dock kids booed you." },
			},
			{
				label = "Walk away from the dare",
				result = { prudence = 1, sanity = -1, log = "You walked away from the dare and heard them laughing behind you all the way home." },
			},
		},
	},
	{
		id = "child_night_school",
		title = "The Night School Slate",
		text = "The night school meets in a pump shed on the fourth Terrace, warm from the boilers. Master Iver Tarrant chalks a long sum on the slate and taps it with a wet finger. Half the class is asleep. He is looking straight at you.",
		cooldown = 3,
		tags = { "childhood", "study" },
		when = { minAge = 6, maxAge = 11, side = "gutters" },
		choices = {
			{
				label = "Answer the sum",
				hint = "Temperance clash, easy.",
				clash = { stat = "temperance", foe = "The long sum", coins = 1, base = 2, coinPower = 2 },
				win = { temperance = { 2, 4 }, sanity = 1, log = "You answered the sum, and Master Tarrant gave you a stub of real chalk to keep." },
				lose = { temperance = 1, sanity = -2, log = "You got the sum wrong in front of everyone, then worked it out properly at home." },
			},
			{
				label = "Pretend to be asleep",
				result = { sanity = 1, log = "You pretended to sleep, and the warm shed soon made it true." },
			},
			{
				label = "Draw the pumps on your slate",
				result = { temperance = { 1, 2 }, log = "You drew the pumps on your slate, every valve, and the teacher let you finish." },
			},
		},
	},
	{
		id = "child_tram_step",
		title = "Riding the Step",
		text = "The tram grinds up the switchback with its bell clanging and its outside step wide open. Older kids ride the step for free, one hand on the brass rail and the other waving. The conductor is busy arguing with a woman about a goose.",
		cooldown = 3,
		tags = { "childhood", "terraces" },
		when = { minAge = 7, maxAge = 12, side = "gutters" },
		choices = {
			{
				label = "Ride the outside step",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The hairpin turn", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 2, 3 }, sanity = 3, log = "You rode the step all the way to the top Terrace with the wind in your teeth." },
				lose = { fortitude = { -6, -3 }, sanity = -1, log = "You lost your grip on the turn and landed in a heap of fishing nets." },
			},
			{
				label = "Help catch the goose",
				result = { prudence = { 1, 2 }, money = { 1, 4 }, log = "You caught the goose. The woman paid you a little {currency}, and the conductor let you ride inside." },
			},
			{
				label = "Walk the stairs instead",
				result = { fortitude = { 1, 2 }, log = "You walked the switchback stairs instead and counted every one of them." },
			},
		},
	},
	{
		id = "child_garden_gate",
		title = "At the Garden Gate",
		text = "A Silt kid is standing at your garden gate in a coat three sizes too big, staring at the greenhouse lamps. The guard hasn't noticed yet. Your lunch basket is heavy with bread, pears and a pot of honey you were told not to share.",
		once = true,
		tags = { "childhood", "rim", "friend" },
		when = { minAge = 6, maxAge = 12, side = "charter" },
		choices = {
			{
				label = "Pass the basket through the bars",
				result = {
					addRelation = { kind = "friend", name = "Wren Duskin", bond = 50, age = { 7, 12 } },
					justice = 2,
					sanity = 2,
					log = "You passed the basket through the bars. {newRelation} came back to the gate every week after that.",
				},
			},
			{
				label = "Call the guard",
				result = { justice = -2, sanity = -2, log = "You called the guard. The kid ran before you could see their face properly." },
			},
			{
				label = "Pretend you didn't see",
				result = { prudence = 1, sanity = -1, log = "You looked hard at the greenhouse until the kid went away." },
			},
		},
	},
	{
		id = "child_greenhouse_pane",
		title = "The Broken Pane",
		text = "Your ball sails over the hedge and through a pane of the orchid house with a sound like a dropped tray of glasses. The gardener's boy, Jory, is standing right next to the hole, holding a watering can and looking very guilty about nothing.",
		once = true,
		tags = { "childhood", "rim" },
		when = { minAge = 6, maxAge = 12, side = "charter" },
		choices = {
			{
				label = "Own up to it",
				result = { justice = { 1, 3 }, money = { -10, -5 }, log = "You owned up. Your allowance paid for the pane, and Jory saved you a cutting." },
			},
			{
				label = "Patch the pane before anyone looks",
				hint = "Temperance clash, easy.",
				clash = { stat = "temperance", foe = "The broken pane", coins = 1, base = 2, coinPower = 2 },
				win = { temperance = { 2, 3 }, sanity = 1, log = "You patched the pane with putty and a cut-down picture frame. Nobody ever noticed." },
				lose = { justice = -1, money = { -12, -6 }, log = "Your patch fell out in the first rain, and the cost came out of your allowance." },
			},
			{
				label = "Let Jory take the blame",
				result = { justice = -3, sanity = -2, log = "Jory was sent home without pay, and he never looked at you again." },
			},
		},
	},
	{
		id = "child_lantern_flag",
		title = "The Flag You Came In",
		text = "The old Lantern Guild flag you were found in hangs over your cot, faded to the color of weak broth. Tonight, in better light, you notice a line of tiny careful stitches along the hem. They spell part of a name. The rest has worn to loose thread.",
		once = true,
		weight = 14,
		tags = { "childhood", "foundling", "thread_flag" },
		when = { minAge = 8, maxAge = 12, flags = { "foundling" } },
		choices = {
			{
				label = "Take it to the Guild hall",
				result = {
					setFlags = { "flag_name_asked" },
					schedule = { event = "youth_flag_answer", inYears = 5 },
					prudence = 1,
					log = "A Guild clerk copied the stitches into a ledger and told you to come back when you were older.",
				},
			},
			{
				label = "Keep it to yourself",
				result = { sanity = 2, log = "You traced the stitches with one finger every night until you knew them by heart." },
			},
		},
	},
	{
		id = "child_window_bed",
		title = "The Window Bed",
		text = "There is one bed by the window, where light from the water lanterns ripples on the ceiling at night, and there are two of you who want it. {sibling} has already put a pillow on it. You have a pillow too.",
		once = true,
		tags = { "childhood", "family" },
		when = { minAge = 4, maxAge = 12, hasRelation = "sibling" },
		choices = {
			{
				label = "Share it, head to foot",
				result = { sanity = 2, relationBond = { kind = "sibling", amount = 6 }, log = "You slept head to foot with {sibling} and kicked each other all night, happily." },
			},
			{
				label = "Wrestle for it",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "Your sibling", coins = 1, base = 2, coinPower = 2 },
				win = { justice = 2, relationBond = { kind = "sibling", amount = -4 }, log = "You won the window bed, and {sibling} sulked about it for a week." },
				lose = { sanity = -2, log = "{sibling} pinned you in four seconds flat and kept the window bed." },
			},
			{
				label = "Let them have it",
				result = { prudence = 2, relationBond = { kind = "sibling", amount = 4 }, log = "You let {sibling} have the window and fell asleep listening to the water instead." },
			},
		},
	},
	{
		id = "child_double_shift",
		title = "After the Double Shift",
		text = "{mother} comes home from a double shift with soot in the creases of her hands. She sits down on the step inside the door and doesn't get up again. The broth on the stove has gone cold, and the lamp is nearly out of oil.",
		cooldown = 3,
		tags = { "childhood", "family" },
		when = { minAge = 4, maxAge = 11, hasRelation = "mother" },
		choices = {
			{
				label = "Warm the broth for her",
				result = { temperance = { 1, 2 }, relationBond = { kind = "mother", amount = 6 }, log = "You warmed the broth and held the bowl while {mother} fell asleep sitting up." },
			},
			{
				label = "Trim the lamp and sit with her",
				result = { prudence = { 1, 2 }, sanity = 2, relationBond = { kind = "mother", amount = 4 }, log = "You trimmed the wick and sat beside {mother} on the step without saying anything." },
			},
			{
				label = "Ask her for a story",
				result = { sanity = 3, relationBond = { kind = "mother", amount = 2 }, log = "{mother} told you, half asleep, about the year the cathedral roof came up." },
			},
		},
	},
	{
		id = "child_holding_breath",
		title = "Holding Your Breath",
		text = "{father} kneels by the dock ladder with his old Guild watch in one hand. The water below is green and cold and full of floating lantern light. \"Divers count,\" he says. \"Everyone else panics. Hold your breath and count with me.\"",
		once = true,
		weight = 14,
		tags = { "childhood", "family", "diver" },
		when = { minAge = 5, maxAge = 11, hasRelation = "father", flags = { "diver_blood" } },
		choices = {
			{
				label = "Go under and count",
				hint = "Fortitude clash, easy.",
				clash = { stat = "fortitude", foe = "The cold water", coins = 1, base = 2, coinPower = 2 },
				win = { fortitude = { 2, 4 }, justice = { 1, 2 }, relationBond = { kind = "father", amount = 4 }, log = "You counted to forty under the green water and came up grinning at {father}." },
				lose = { fortitude = { -2, -1 }, sanity = -1, log = "You came up at eleven, spluttering, and {father} laughed and wrapped you in his coat." },
			},
			{
				label = "Count for him from the dock",
				result = { prudence = 2, relationBond = { kind = "father", amount = 2 }, log = "You counted out loud from the dock while {father} went under. He came up on sixty." },
			},
		},
	},
	{
		id = "child_grey_watchers",
		title = "The Grey Watchers",
		text = "Down at the waterline a row of people in grey wool sit facing the Mere, perfectly still, while the fog moves around them. One of them, a woman with an unlit lantern in her lap, pats the wet stone beside her without turning her head.",
		once = true,
		tags = { "childhood", "choir" },
		when = { minAge = 6, maxAge = 12, side = "gutters" },
		choices = {
			{
				label = "Sit down beside her",
				result = { prudence = { 2, 3 }, sanity = 3, setFlags = { "sat_with_choir" }, log = "You sat with the Choir for an hour and heard nothing but water. It was enough." },
			},
			{
				label = "Skip a pebble across the water",
				result = { justice = 1, sanity = -2, log = "You skipped a pebble across the Mere, and every grey head turned to watch it sink." },
			},
			{
				label = "Run home and tell someone",
				result = { sanity = 1, log = "You ran home and told everyone about the grey people. Nobody was surprised." },
			},
		},
	},
}
