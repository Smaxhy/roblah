--[[
	HARD YEARS: the trial each crisis opens with (pack.crises in init.luau names them). A trial
	is a real choice: fight it (hard, and harder for the year itself: Engine adds the crisis's
	foeBase to every fight), find another way (a check), or pay a price and get through.
	Winning a hard year is worth a lot: stats, standing, a name people say.
]]

local WON = { "cr_won_a_hard_year" }

return {
	{
		id = "cr_turf",
		title = "Whose Street Is This",
		art = "street",
		text = "Two Syndicates have been circling {district} all year, and tonight they've picked your street to settle it. Shutters are down. A crew with red armbands is going door to door, asking which side each door is on.",
		weight = 0,
		tags = { "danger" },
		choices = {
			{
				label = "Stand in the street and say: neither",
				hint = "A hard fight. Win, and the street remembers who stood up.",
				clash = { stat = "strength", foe = "A Syndicate crew with red armbands", enemy = "syndicate", fight = true, coins = 3, base = 6, coinPower = 3 },
				win = { strength = 3, mind = 2, sanity = 4, money = { 100, 250 }, rep = { rats = -10 }, setFlags = WON, log = "You stood in the street and they came at you, and they went back the way they came. By morning both Syndicates knew the name of the street, and yours." },
				lose = { health = { -24, -12 }, sanity = -6, money = { -120, -40 }, cause = "Stood alone against a Syndicate crew", log = "They went through you to get to the doors. The street picked a side that night, and it wasn't yours." },
			},
			{
				label = "Get your neighbours out through the back courts",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Streets full of armbands", coins = 3, base = 6, coinPower = 3 },
				win = { speed = 3, charisma = 2, sanity = 3, setFlags = WON, log = "You took eleven families out over the back courts while the armbands knocked on empty doors. Nobody on your street forgets who knew the way." },
				lose = { health = { -12, -5 }, sanity = -5, log = "You got some of them out. The rest had to pick a side at the door." },
			},
			{ label = "Pick a side and pay its fee", result = { money = { -260, -140 }, sanity = -4, rep = { rats = 5 }, log = "You paid the red armbands. They painted a mark on your door. It's a safe mark, this year." } },
		},
	},
	{
		id = "cr_collection",
		title = "The Collection Year",
		art = "syndicate",
		text = "The Thumb has declared a Collection Year in {district}: every debt, every favour, every slight, collected at once. A Soldato with a ledger is on your stairs, very politely, with two more behind him.",
		weight = 0,
		tags = { "danger" },
		choices = {
			{
				label = "Refuse, and mean it",
				hint = "A fight against the Thumb. They don't forget.",
				clash = { stat = "strength", foe = "Soldati of the Thumb", enemy = "thumb_soldato", fight = true, coins = 3, base = 7, coinPower = 3 },
				win = { strength = 3, mind = 3, sanity = 2, rep = { thumb = -25 }, setFlags = WON, log = "They didn't collect. They went back down the stairs with their ledger shut, and the whole District heard by evening that somebody had said no to the Thumb and was still standing." },
				lose = { health = { -26, -14 }, money = { -300, -150 }, sanity = -6, rep = { thumb = -10 }, cause = "Refused the Thumb in a Collection Year", log = "They collected, and then they collected for the refusal." },
			},
			{
				label = "Bow exactly right, and negotiate",
				hint = "Charisma check. The Thumb respects manners.",
				clash = { stat = "charisma", foe = "A Soldato's ledger", coins = 3, base = 6, coinPower = 3 },
				win = { charisma = 3, sanity = 2, money = { -80, -30 }, rep = { thumb = 10 }, setFlags = WON, log = "The bow was the right depth and the words were the right words. The Soldato crossed out half the page and thanked you for your courtesy." },
				lose = { money = { -220, -120 }, sanity = -4, log = "The bow was a little shallow. It cost you." },
			},
			{ label = "Pay the whole page", result = { money = { -400, -250 }, sanity = -3, rep = { thumb = 8 }, log = "You paid every line. The Soldato bowed. It was the most expensive bow you've ever been given." } },
		},
	},
	{
		id = "cr_winter",
		title = "A Hard Winter",
		art = "home",
		text = "The cold came early to {district} and stayed. Coal costs three times what it did. The clinic is full of coughs, and there's a sound in your own chest you don't like.",
		weight = 0,
		choices = {
			{
				label = "Work through it",
				hint = "Health check. It's a long winter.",
				clash = { stat = "health", foe = "The longest winter in years", coins = 3, base = 6, coinPower = 3 },
				win = { health = 4, mind = 2, money = { 60, 140 }, setFlags = WON, log = "You worked every shift through the cold and came out of it harder than you went in." },
				lose = { health = { -22, -10 }, sanity = -4, cause = "A hard winter", log = "The cough got into your chest and stayed there until spring." },
			},
			{ label = "Spend what it takes on coal and a clinic", result = { money = { -280, -160 }, health = 2, sanity = 2, log = "Coal, a doctor, and a lot of soup. You came through it warm, and poor." } },
			{
				label = "Share your stove with the floor",
				hint = "Charisma check. Twenty people, one stove.",
				clash = { stat = "charisma", foe = "Twenty cold neighbours and one stove", coins = 3, base = 6, coinPower = 3 },
				win = { charisma = 3, sanity = 5, setFlags = WON, log = "Twenty people slept around your stove all winter. Nobody on your floor died. People still bring you things, years later." },
				lose = { health = { -10, -4 }, sanity = -3, log = "Twenty people, one stove, and arguments every night. Everyone lived. Nobody's speaking." },
			},
		},
	},
	{
		id = "cr_contract",
		title = "A Contract on Your Name",
		art = "office",
		text = "A Fixer you've never met sits down across from you at the noodle counter and tells you, very calmly, that somebody has paid an Office to end you this year. She isn't taking the contract. Someone else already has.",
		weight = 0,
		tags = { "danger" },
		choices = {
			{
				label = "Wait for them, and be ready",
				hint = "A hard fight with a professional.",
				clash = { stat = "strength", foe = "The Fixer who took the contract", enemy = "fixer", fight = true, coins = 3, base = 7, coinPower = 3 },
				win = { strength = 3, speed = 2, mind = 2, rep = { fixers = 10 }, setFlags = WON, log = "They came on a Thursday. You were ready on Thursday. The Office returned the fee and sent a note saying it was nothing personal. You framed the note." },
				lose = { health = { -28, -14 }, sanity = -6, cause = "A Fixer's contract", log = "They came on a Wednesday." },
			},
			{
				label = "Find out who paid, and why",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A paper trail through three Offices", coins = 3, base = 7, coinPower = 3 },
				win = { intelligence = 4, sanity = 3, setFlags = WON, log = "You found the name, and the reason, and a counter-offer the Office liked better. The contract was torn up in front of you." },
				lose = { health = { -14, -6 }, sanity = -5, log = "You found a name. It was the wrong name. The real one is still out there." },
			},
			{ label = "Leave the District for the year", result = { money = { -300, -180 }, sanity = -4, log = "A rented room in another District, a different name on the door. In spring the contract expired, unpaid." } },
		},
	},
	{
		id = "cr_sweep",
		title = "The Wing Sweeps the Wall",
		art = "nest",
		text = "The Wing has decided the Backstreets against its wall are a security problem. Armoured staff are clearing the blocks nearest the Nest, door by door, and your block is next on the list.",
		weight = 0,
		tags = { "danger" },
		when = { side = "backstreets" },
		choices = {
			{
				label = "Hold your block's door",
				hint = "A fight against Wing security. They're well armed.",
				clash = { stat = "strength", foe = "Wing security clearing the block", enemy = "wing_guard", fight = true, coins = 3, base = 7, coinPower = 3 },
				win = { strength = 3, health = 3, sanity = 3, setFlags = WON, log = "They found the block harder to clear than the paperwork said, and moved the line a street further back. Your block is still there." },
				lose = { health = { -24, -12 }, money = { -160, -60 }, sanity = -5, cause = "Held a door against the Wing", log = "They cleared the block. You were cleared with it." },
			},
			{
				label = "Find the paperwork that saves the block",
				hint = "Intelligence check. Wings run on forms.",
				clash = { stat = "intelligence", foe = "The Wing's clearance orders", coins = 3, base = 7, coinPower = 3 },
				win = { intelligence = 4, charisma = 2, setFlags = WON, log = "A zoning form from forty years ago, a stamp nobody had cancelled, and a clerk who couldn't argue with it. The sweep went round your block." },
				lose = { money = { -120, -60 }, sanity = -4, log = "The form you found had been cancelled. You moved one street over, with what you could carry." },
			},
			{ label = "Move before they come", result = { money = { -180, -90 }, sanity = -3, log = "You moved one street over before the sweep, with what you could carry. It's smaller. It's yours." } },
		},
	},
	{
		id = "cr_distortions",
		title = "The Year of Distortions",
		art = "distortion",
		text = "It's been a bad year for minds in {district}. Three people on your street have turned into something already, and tonight the fourth is your neighbour from two floors down. You can hear it on the stairs.",
		weight = 0,
		tags = { "danger" },
		when = { world = { era = { "library", "limbus" } } },
		choices = {
			{
				label = "Meet it on the stairs",
				hint = "A fight with a Distortion.",
				clash = { stat = "strength", foe = "Your neighbour, Distorted", enemy = "distortion", fight = true, coins = 3, base = 7, coinPower = 3 },
				win = { strength = 3, mind = 3, sanity = -2, setFlags = WON, log = "You held it on the landing until the Fixers came. The building lived. You'll remember what it said on the stairs." },
				lose = { health = { -26, -12 }, sanity = -8, cause = "A Distortion on the stairs", log = "It went through you on its way to the street." },
			},
			{
				label = "Talk to whoever is left inside it",
				hint = "Mental Strength check. Some of them can still hear you.",
				clash = { stat = "mind", foe = "What your neighbour is becoming", coins = 3, base = 7, coinPower = 3 },
				win = { mind = 4, sanity = 4, setFlags = { "cr_won_a_hard_year", "lim_talked_down" }, chronicle = "lim_talked_down", log = "You said their name until they heard it. They came back, most of the way. They sat on the stairs and cried, and so did you." },
				lose = { sanity = -10, health = { -10, -4 }, log = "They didn't hear you. Something else did." },
			},
			{ label = "Bar the door and wait for the Fixers", result = { sanity = -5, log = "You barred the door and listened to the stairs all night. The Fixers came at dawn. You still listen to the stairs." } },
		},
	},
	{
		id = "cr_long_night",
		title = "The Nights Run Long",
		art = "night",
		text = "Something is wrong with the Night in {district} this year. The Sweepers come early and stay late, and twice now they've tried doors. Tonight you're caught across the District when the clocks start running down to 3:13.",
		weight = 0,
		tags = { "danger" },
		choices = {
			{
				label = "Run for home",
				hint = "Speed check. Twelve streets and nine minutes.",
				clash = { stat = "speed", foe = "Twelve streets and nine minutes", coins = 3, base = 7, coinPower = 3 },
				win = { speed = 4, sanity = 2, setFlags = WON, log = "You made your own door with the street going quiet behind you. You've never run like that, and you never will again." },
				lose = { health = { -20, -10 }, sanity = -8, log = "You didn't make it home. You made someone else's cellar, and you don't know whose." },
			},
			{
				label = "Knock until someone lets you in",
				hint = "Charisma check. Nobody opens a door after three.",
				clash = { stat = "charisma", foe = "Doors that don't open after three", coins = 3, base = 7, coinPower = 3 },
				win = { charisma = 3, sanity = 3, setFlags = WON, log = "The fourth door opened. An old woman let you sleep under her table, and fed you in the morning, and never asked your name." },
				lose = { sanity = -8, health = { -14, -6 }, log = "No door opened. You spent the Night in a coal bin, very quiet, listening." },
			},
			{ label = "Pay a Fixer Office to escort you", result = { money = { -240, -140 }, sanity = -2, log = "The Office charged Night rates. Worth every Ahn." } },
		},
	},
	{
		id = "cr_debts",
		title = "Everything Comes Due",
		art = "office",
		text = "It's all coming due at once: the rent, a loan you'd half forgotten, a favour someone wants back. The man from the lending house is very sorry, and has brought two colleagues who aren't.",
		weight = 0,
		choices = {
			{
				label = "Talk them into another year",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A lending house that's out of patience", coins = 3, base = 7, coinPower = 3 },
				win = { charisma = 3, intelligence = 2, setFlags = WON, log = "Another year, at the old rate. The lender shook your hand and said you'd have made a good lender." },
				lose = { money = { -350, -200 }, sanity = -4, log = "They took what they could carry, and a promise for the rest." },
			},
			{
				label = "Show his colleagues the door",
				hint = "A fight, and a lending house that will remember it.",
				clash = { stat = "strength", foe = "A lender's colleagues", enemy = "syndicate", fight = true, coins = 3, base = 7, coinPower = 3 },
				win = { strength = 3, sanity = 2, setFlags = WON, log = "His colleagues left by the stairs, quickly. The debt didn't go away. The visits did." },
				lose = { health = { -22, -10 }, money = { -300, -150 }, cause = "Fought a lending house's collectors", log = "His colleagues were better at doors than you." },
			},
			{ label = "Pay it all", result = { money = { -500, -300 }, sanity = 2, log = "You paid everything. You're poor and free, which is a kind of rich." } },
		},
	},
	{
		id = "cr_old_enemy",
		title = "An Old Enemy",
		art = "alley",
		text = "Someone you crossed a long time ago has done well for themselves, and has spent the year buying up everything you depend on: your landlord, your usual stall, the clinic's debts. Tonight they're waiting at the end of your street, alone, smiling.",
		weight = 0,
		tags = { "danger" },
		when = { minAge = 36 },
		choices = {
			{
				label = "Settle it, here",
				hint = "A hard fight. They've had years to get ready.",
				clash = { stat = "strength", foe = "An old enemy who got ready", enemy = "fixer", fight = true, coins = 3, base = 8, coinPower = 3 },
				win = { strength = 3, mind = 3, sanity = 5, setFlags = WON, log = "It's settled. Whatever they bought, they sold again within the month." },
				lose = { health = { -28, -14 }, sanity = -6, cause = "An old enemy", log = "It's settled, their way." },
			},
			{
				label = "Outthink them, the long way",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Years of somebody else's planning", coins = 3, base = 8, coinPower = 3 },
				win = { intelligence = 4, money = { 200, 500 }, setFlags = WON, log = "You bought their debts, quietly, one at a time, and then you called them in. They left the District by the WARP with one bag." },
				lose = { money = { -400, -200 }, sanity = -5, log = "They thought of it first. They usually did." },
			},
			{ label = "Apologise, after all these years", result = { charisma = 2, sanity = 4, log = "You apologised. They stopped smiling. After a long time they said it was too late, and then, at the corner, that it wasn't." } },
		},
	},
}
