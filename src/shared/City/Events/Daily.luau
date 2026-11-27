--[[
	Today in the City: the daily scenes (see Daily.luau). weight = 0: they only come from
	the daily activity. Keep them short, varied and worth coming back for.
]]

return {
	{
		id = "daily_noodle_day",
		title = "Noodle Day",
		text = "Every diner on the corner has a pot on the street and a hand-lettered sign. The old woman at the third stall waves you over: \"You. You look like you've eaten bad noodles. Judge for us.\"",
		weight = 0,
		choices = {
			{
				label = "Judge fairly",
				clash = { stat = "intelligence", foe = "Eleven very proud cooks", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, money = 20, log = "You named a winner and nobody threw anything. The winner paid you in noodles and a little Ahn." },
				lose = { sanity = 1, log = "Your verdict started a feud between two stalls. The noodles were good, though." },
			},
			{
				label = "Just eat",
				result = { sanity = { 3, 6 }, health = 1, log = "You ate a bowl from every stall and walked home very slowly." },
			},
		},
	},
	{
		id = "daily_job_board",
		title = "The Job Board",
		text = "A Fixer office has pinned its small jobs on a board outside: a lost cat, a debt to deliver, a shop that needs watching after dark. The Rep leans in the doorway. \"Grade doesn't matter for these. Showing up does.\"",
		weight = 0,
		choices = {
			{
				label = "Watch the shop till closing",
				clash = { stat = "strength", foe = "A pack of Rats", coins = 2, base = 4, coinPower = 3, fight = true },
				win = { wage = { 30, 70 }, strength = 1, log = "Three Rats tried the door at closing. They left faster than they came. The shopkeeper paid double." },
				lose = { health = { -8, -3 }, wage = { 10, 20 }, log = "The Rats got the till and some of you. The Rep paid you anyway, for showing up." },
			},
			{
				label = "Find the lost cat",
				clash = { stat = "mind", foe = "A cat that doesn't want to be found", coins = 2, base = 3, coinPower = 2 },
				win = { wage = { 20, 40 }, sanity = 3, log = "You found the cat asleep in a ventilation duct. The little girl who owned it cried. So did you, a bit." },
				lose = { sanity = -1, log = "The cat found you, scratched you, and left." },
			},
		},
	},
	{
		id = "daily_prescript",
		title = "A Slip of Paper",
		text = "A folded slip of paper is in your coat pocket. You didn't put it there. In neat handwriting: \"At noon, buy a red umbrella and give it to the third stranger who passes you.\"",
		weight = 0,
		codex = "fingers_index",
		choices = {
			{
				label = "Do exactly what it says",
				result = { money = -15, sanity = { 2, 6 }, mind = 2, log = "You gave the umbrella to the third stranger. She looked at it, then at you, and said \"Thank you. I was told to expect you.\" Then she walked away." },
			},
			{
				label = "Throw it away",
				result = { sanity = -2, log = "You threw the slip away. All day, you felt like someone was disappointed in you." },
			},
		},
	},
	{
		id = "daily_warp_fares",
		title = "Cheap WARP Fares",
		text = "W Corp is selling tickets at a fraction of the price today. The queue at the station is long, and nobody in it is asking why.",
		weight = 0,
		codex = "districts_w_corp",
		choices = {
			{
				label = "Ride to another District and back",
				result = { money = -20, sanity = { -2, 4 }, mind = 1, log = "You crossed the City and back before lunch. It felt like it took a lot longer than it did." },
			},
			{
				label = "Sell your place in the queue",
				result = { money = { 25, 45 }, log = "You sold your place to a man in a hurry. He looked relieved. Then he looked worried." },
			},
		},
	},
	{
		id = "daily_open_academy",
		title = "Open Academy Day",
		text = "The academy on your street has thrown its doors open. A tired old teacher is giving a free lecture on the history of the Wings, to an audience of four.",
		weight = 0,
		codex = "city_basics",
		choices = {
			{
				label = "Sit in on the lecture",
				result = { intelligence = { 2, 3 }, mind = 1, log = "You learned more about the Wings in an afternoon than in a year of rumors. The teacher looked delighted to have a fifth." },
			},
			{
				label = "Help the teacher set up",
				result = { sanity = 3, intelligence = 1, log = "You moved chairs and wrote on the board. The teacher gave you a book about the Smoke War and told you to read it carefully." },
			},
		},
	},
	{
		id = "daily_rat_season",
		title = "Rat Season",
		text = "The Rats are out in numbers tonight. The woman who runs the pharmacy is closing early and looking for someone to walk her and her takings home.",
		weight = 0,
		choices = {
			{
				label = "Walk her home",
				clash = { stat = "strength", foe = "A gang of Rats", coins = 3, base = 4, coinPower = 3, fight = true },
				win = { wage = { 25, 60 }, sanity = 3, log = "Five Rats stepped out of an alley. Four ran. The fifth will think hard before trying again." },
				lose = { health = { -10, -4 }, sanity = -2, log = "The Rats took her takings and your pride. She thanked you for trying.", cause = "Walked into a Rat pack" },
			},
			{
				label = "Lend her a lock and a whistle",
				result = { money = -10, sanity = 2, log = "You gave her your spare lock and an old whistle. She made it home fine." },
			},
		},
	},
	{
		id = "daily_free_clinic",
		title = "Free Clinic",
		text = "A charity from the Nest has set up tables in the Backstreets: ampules, bandages, a nurse with very clean shoes. The line is long, but it's moving.",
		weight = 0,
		choices = {
			{
				label = "Get patched up",
				result = { health = { 6, 12 }, cure = "any", log = "A nurse looked you over, fixed what she could, and didn't charge you a single Ahn." },
			},
			{
				label = "Help run the line",
				result = { sanity = 4, intelligence = 1, log = "You kept the line moving and the peace. The nurse with the clean shoes asked your name." },
			},
		},
	},
	{
		id = "daily_book_swap",
		title = "Book Swap",
		text = "A market of old books, bound job reports, and pamphlets about things nobody should have written down. A stallholder holds up a slim volume. \"This one's about someone from around here. Want to see?\"",
		weight = 0,
		choices = {
			{
				label = "Trade for the slim volume",
				result = { money = -10, mind = 2, sanity = { -2, 3 }, log = "It was a book about a Fixer from your District who died twenty years ago. It's very well written." },
			},
			{
				label = "Look for job reports",
				result = { strength = 1, intelligence = 1, log = "You found a bound set of Fixer job reports. Most of the mistakes in them were fatal. You took notes." },
			},
		},
	},
}
