--[[
	Company career events: working for the company that holds your Ward's charter.
	All gated by when.career = "company", so {corp} always names a living company
	(the company career can't exist in Drownside).
	Threads:
		company_secret   company_second_ledger -> company_secret_out (2 yrs)
]]

return {
	{
		id = "company_quota_board",
		title = "The Quota Board",
		text = "The quota board at {corp} is a wall of slate in the main hall, and every Hireling and Clerk has a line on it in chalk. Yours is short again. Overseers walk past it twice a day with their hands behind their backs. This morning one of them stops, reads your line, and writes something down.",
		cooldown = 4,
		tags = { "career", "company" },
		when = { career = "company", minAge = 16 },
		choices = {
			{
				label = "Work nights to catch up",
				result = { paycheck = 0.2, fortitude = { -4, -1 }, sanity = -2, log = "You worked nights until your line on the board caught up with everyone else's." },
			},
			{
				label = "Adjust the chalk",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "The quota board", coins = 2, base = 4, coinPower = 3 },
				win = { paycheck = 0.15, justice = -1, sanity = 1, log = "You adjusted your line with a wet thumb and a steady hand, and nobody ever checked." },
				lose = { money = { -40, -20 }, sanity = -3, log = "An overseer caught you with chalk on your thumb and docked a month's pay for it." },
			},
			{
				label = "Ask why the quota rose",
				result = { prudence = 1, justice = 2, sanity = -1, log = "You asked why the quota rose, and an overseer explained it to you very slowly, twice." },
			},
		},
	},
	{
		id = "company_audit",
		title = "The Auditors Come Down",
		text = "Auditors from the top floor of {corp} have taken over the long room, three of them in identical grey, with a cart of ledgers and a jar of sharpened pencils. They are going desk by desk. They have reached the desk next to yours, and the clerk who sits there has gone the color of old paper.",
		cooldown = 6,
		tags = { "career", "company" },
		when = { career = "company", minAge = 18 },
		choices = {
			{
				label = "Let them check your books",
				hint = "Temperance clash, medium-hard.",
				clash = { stat = "temperance", foe = "The company auditors", coins = 2, base = 5, coinPower = 3 },
				win = { paycheck = 0.1, temperance = 2, sanity = 3, log = "The auditors found your books so clean that they used them to train the new clerks." },
				lose = { money = { -50, -25 }, sanity = -3, log = "The auditors found an error from your first year and charged you for it, with interest." },
			},
			{
				label = "Help the clerk next door",
				result = { fortitude = -2, justice = 3, sanity = -1, log = "You stayed late fixing your neighbor's ledgers, and the auditors found nothing on either desk." },
			},
			{
				label = "Point them at the next desk",
				result = { paycheck = 0.1, justice = -4, sanity = -2, log = "You mentioned the next desk's mistakes before they reached yours, and the clerk was gone by the week's end." },
			},
		},
	},
	{
		id = "company_directors_nephew",
		title = "The Director's Nephew",
		text = "A new Clerk has been given the desk beside yours, and everyone at {corp} knows he is a director's nephew before he has hung up his coat. His name is Bastian Wexley. He is pleasant, quick and careless, and he has already asked to see your ledgers, so that he can learn from the best.",
		once = true,
		tags = { "career", "company", "rival" },
		when = { career = "company", minAge = 18 },
		choices = {
			{
				label = "Outwork him",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "Bastian Wexley", coins = 2, base = 4, coinPower = 3 },
				win = {
					paycheck = 0.15,
					temperance = 2,
					sanity = 2,
					addRelation = { kind = "rival", name = "Bastian Wexley", bond = 20, age = { 20, 26 } },
					log = "You outworked {newRelation} every day for a year, and the overseers noticed who stayed late.",
				},
				lose = {
					sanity = -3,
					addRelation = { kind = "rival", name = "Bastian Wexley", bond = 15, age = { 20, 26 } },
					log = "{newRelation} presented your ledger method as his own, and the overseers were delighted.",
				},
			},
			{
				label = "Show him the ropes",
				result = {
					prudence = 1,
					sanity = 1,
					addRelation = { kind = "friend", name = "Bastian Wexley", bond = 40, age = { 20, 26 } },
					log = "You showed {newRelation} the ropes, and he turned out to be good company, if not good at ledgers.",
				},
			},
			{
				label = "Keep your ledgers locked",
				result = { prudence = 2, log = "You locked your ledgers in your drawer every night and wore the key around your neck." },
			},
		},
	},
	{
		id = "company_second_ledger",
		title = "The Second Ledger",
		text = "Filing late, you find a second ledger in the archive of {corp}, bound in plain board and shelved behind the first. Its columns match the floodgate schedules to the day. Some Gutters streets are marked to flood every High Water, and beside each one is a sum paid in by the Charter streets above.",
		once = true,
		tags = { "career", "company", "thread_secret" },
		when = { career = "company", minAge = 18, notFlags = { "company_secret" } },
		choices = {
			{
				label = "Copy a page",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The night archivist", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 2,
					sanity = -1,
					setFlags = { "company_secret" },
					schedule = { event = "company_secret_out", inYears = 2 },
					log = "You copied a page in pencil on the back of a tram ticket and walked out past the archivist.",
				},
				lose = { money = { -30, -15 }, sanity = -3, log = "The archivist caught you reading and fined you for being in the archive after hours." },
			},
			{
				label = "Put it back exactly",
				result = { prudence = 2, sanity = -2, log = "You put the ledger back exactly where it was and found you could not stop remembering it." },
			},
			{
				label = "Take it to your overseer",
				result = { paycheck = 0.2, justice = -2, sanity = -2, log = "Your overseer thanked you, locked the ledger away, and gave you a bonus for your discretion." },
			},
		},
	},
	{
		id = "company_secret_out",
		title = "The Page in Your Coat",
		text = "The copied page from the second ledger has been in your coat lining for two years, soft as cloth now. This spring {corp} has announced a new flood schedule, and a Gutters street you know is on it. A Sluice inspector, a newspaper printer and a Brine Kin cousin would each pay well for what you are carrying.",
		weight = 0,
		once = true,
		tags = { "career", "company", "thread_secret" },
		when = { career = "company", flags = { "company_secret" } },
		choices = {
			{
				label = "Take it to the printer",
				result = {
					money = { 20, 40 },
					justice = 5,
					sanity = 3,
					quitCareer = true,
					clearFlags = { "company_secret" },
					log = "The page ran on the front of the morning sheet, the schedule was withdrawn, and you were dismissed by noon.",
				},
			},
			{
				label = "Sell it back to a director",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "A company director", coins = 3, base = 6, coinPower = 3 },
				win = {
					money = { 150, 250 },
					justice = -3,
					promote = true,
					clearFlags = { "company_secret" },
					log = "You sold the page back to a director, who promoted you to keep you close.",
				},
				lose = {
					sanity = -5,
					quitCareer = true,
					clearFlags = { "company_secret" },
					log = "The director took the page, thanked you, and had guards walk you out through the gate.",
				},
			},
			{
				label = "Burn it",
				result = { prudence = 2, sanity = -3, clearFlags = { "company_secret" }, log = "You burned the page in your stove and watched the street's name curl up last." },
			},
		},
	},
	{
		id = "company_desk_upstairs",
		title = "A Desk Upstairs",
		text = "A desk one floor up at {corp} has come empty, the one with the window and the brass lamp, and the overseers are taking names. Every Clerk in the long room has started arriving early and leaving late. Somebody has left a polished apple on the empty desk, as if it were a shrine. Your name is not on the list yet.",
		cooldown = 5,
		tags = { "career", "company", "promotion" },
		when = { career = "company", minAge = 18 },
		choices = {
			{
				label = "Put your name forward",
				hint = "Temperance clash, medium-hard.",
				clash = { stat = "temperance", foe = "The other candidates", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, sanity = 4, log = "You put your name forward with a stack of perfect ledgers, and the desk upstairs was yours." },
				lose = { sanity = -3, log = "The desk went to someone with a better uncle, and you went back to the long room." },
			},
			{
				label = "Recommend a colleague",
				result = { justice = 2, sanity = 2, log = "You recommended the quiet clerk who did everyone's sums, and she got the window desk." },
			},
			{
				label = "Stay where you are",
				result = { prudence = 1, sanity = 1, log = "You stayed at your desk in the long room, where at least you knew where the draughts came from." },
			},
		},
	},
}
