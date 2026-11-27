--[[
	Elder events: ages 60+.
	Reads worked_for_brine (Core / Life) in elder_kin_remember.
]]

return {
	{
		id = "elder_four_hundred_stairs",
		title = "Four Hundred Stairs",
		text = "The switchback stairs have grown longer, or your knees have grown older. Halfway up, you have to sit on a landing and watch the trams go by. A porter with a basket chair strapped to his back offers to carry you the rest of the way for two {currency}.",
		cooldown = 5,
		tags = { "elder", "terraces" },
		when = { minAge = 60, side = "gutters" },
		choices = {
			{
				label = "Pay the porter",
				hint = "2 scrip.",
				requires = { min = { money = 2 } },
				result = { money = -2, sanity = 2, log = "You rode up the stairs in a basket chair like a Rim duchess and enjoyed every step." },
			},
			{
				label = "Climb on, slowly",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The switchback stairs", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = 1, sanity = 3, log = "You climbed the rest on your own, one landing at a time, and nobody passed you." },
				lose = {
					fortitude = { -8, -4 },
					sanity = -2,
					log = "Your knee gave out on the third landing, and strangers carried you home.",
					cause = "Fell on the switchback stairs",
				},
			},
			{
				label = "Sit and watch the trams",
				result = { prudence = 1, sanity = 2, log = "You sat on the landing until sunset and watched the trams, and that was enough." },
			},
		},
	},
	{
		id = "elder_storyteller",
		title = "The Storyteller",
		text = "The neighborhood children have discovered that you remember the High Water of thirty years ago, and the Low Water before that, when the cathedral roof came up. They gather on your step after supper, sitting in a row like little Choristers, waiting for you to begin.",
		once = true,
		tags = { "elder", "friend" },
		when = { minAge = 62 },
		choices = {
			{
				label = "Tell them the true version",
				result = {
					prudence = 2,
					sanity = 4,
					addRelation = { kind = "friend", name = "Lark Underhill", bond = 45, age = { 8, 12 } },
					log = "You told them everything you remembered, and {newRelation} came back every night for more.",
				},
			},
			{
				label = "Make it better than it was",
				result = { temperance = 2, sanity = 5, log = "You told the stories bigger and kinder than they were, and the children believed every word." },
			},
			{
				label = "Send them home",
				result = { sanity = -2, log = "You sent the children home and sat on your step alone with your memories." },
			},
		},
	},
	{
		id = "elder_last_dive",
		title = "One Last Dive",
		text = "The Guild has found the old Mint at last, deep under Chandlers' Row, and only you still remember the way through its flooded counting halls. The young Lanterns are polite about your age. Your knees ache in the cold. The rope is waiting on the pier.",
		once = true,
		weight = 14,
		tags = { "elder", "diver", "danger" },
		when = { minAge = 60, career = "diver" },
		choices = {
			{
				label = "Lead the dive yourself",
				hint = "Justice clash, hard. You are not young.",
				clash = { stat = "justice", foe = "The flooded counting halls", coins = 3, base = 6, coinPower = 3 },
				win = { justice = 2, sanity = 6, money = { 150, 300 }, log = "You led the young Lanterns through the counting halls and brought up the Mint's lost ledgers." },
				lose = { die = "Lost on a last dive", log = "You went down into the counting halls one last time and did not come up." },
			},
			{
				label = "Draw them a map instead",
				result = { temperance = 3, sanity = 3, paycheck = 0.3, log = "You drew the young Lanterns a map from memory, every turn and every hazard." },
			},
			{
				label = "Hang up your lantern",
				result = { quitCareer = true, sanity = 4, log = "You hung your lantern on the Guild hall wall and walked home without looking back." },
			},
		},
	},
	{
		id = "elder_own_lantern",
		title = "Folding Your Own Lantern",
		text = "You have started folding your own Lantern Night lantern, a little each evening, the way the old folks do. The paper is good Rim paper. You have written your name on it in careful letters, and there is room underneath for whatever you want the water to remember.",
		once = true,
		tags = { "elder", "lantern_night" },
		when = { minAge = 65 },
		choices = {
			{
				label = "Write the names that mattered",
				result = { sanity = 5, relationBond = { kind = "all", amount = 5 }, log = "You filled the lantern with names until there was no paper left, and felt rich." },
			},
			{
				label = "Write down one good day",
				result = { prudence = 2, sanity = 4, log = "You wrote down one good day, all of it, in very small letters." },
			},
			{
				label = "Leave it blank",
				result = { prudence = 3, sanity = 1, log = "You left it blank. The water could decide for itself what to remember." },
			},
		},
	},
	{
		id = "elder_kin_remember",
		title = "The Kin Remember",
		text = "An Elder Kin you rowed for long ago arrives by boat with a crate of oranges and a ledger under her arm. She opens it to your old page. Every line is crossed out but one, and that one says, in faded ink: owed a favor.",
		once = true,
		weight = 14,
		tags = { "elder", "brine" },
		when = { minAge = 60, flags = { "worked_for_brine" } },
		choices = {
			{
				label = "Ask her to look after your family",
				requires = { hasRelation = { "child", "sibling" } },
				result = { sanity = 4, relationBond = { kind = "family", amount = 8 }, log = "You asked the Kin to look after your family when you were gone, and the Elder wrote it down." },
			},
			{
				label = "Ask for a boat ride over the city",
				result = { sanity = { 5, 8 }, log = "The Elder Kin rowed you over the drowned city at dusk and named every street below you." },
			},
			{
				label = "Tell her to cross it out",
				result = { justice = 3, prudence = 2, log = "You told her to cross out the last line. She did, and left you the oranges anyway." },
			},
		},
	},
	{
		id = "elder_long_winter",
		title = "The Long Winter",
		text = "This winter the fog never lifts, and the cold gets into the walls and stays. Your chest rattles like a loose pump valve. The young stitcher from downstairs knocks every morning to check you're still breathing, and pretends she just happened to be passing.",
		cooldown = 4,
		tags = { "elder", "sickness" },
		when = { minAge = 66 },
		choices = {
			{
				label = "Rest by the stove",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The long winter", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = 2, sanity = 3, log = "You got through the long winter by the stove, and the stitcher's visits became a habit." },
				lose = {
					fortitude = { -12, -8 },
					sanity = -2,
					log = "The winter settled in your chest and would not leave. The stitcher sat with you.",
					cause = "Died in the long winter",
				},
			},
			{
				label = "Pay the stitcher properly",
				hint = "40 scrip.",
				requires = { min = { money = 40 } },
				result = { money = -40, fortitude = { 4, 8 }, log = "You paid the stitcher for proper care, and she fussed you through to spring." },
			},
		},
	},
}
