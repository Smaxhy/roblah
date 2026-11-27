--[[
	Today in the City: the daily scenes for Daily/LCorp.luau (weight = 0; the daily activity
	plays them). Written to work in any era and any District.
	Also the opening scenes of the world events in WorldEvents/LCorp.luau.
]]

return {
	-- ── daily ──
	{
		id = "lc_dly_green_kettle",
		title = "The Green Kettle's Birthday",
		text = "The Green Kettle, District 12's oldest teahouse, is pouring free tea for its birthday, and the owner says anyone who walks in from any District gets a cup. The walls are covered in photographs of L Corp staff in green lanyards, laughing at these same tables. Some of them look very young.",
		weight = 0,
		codex = "lc_lore_agents",
		choices = {
			{
				label = "Read the names under the photographs",
				result = { mind = 1, sanity = 1, log = "You read every name under every photograph. The owner told you which ones still come in. It wasn't many. She told you their favorite teas anyway." },
			},
			{
				label = "Tell a story at the long table",
				result = { sanity = { 3, 5 }, log = "You told a story at the long table, and someone told one back, and by the end the whole teahouse was laughing at something that happened to a stranger twenty years ago." },
			},
			{
				label = "Help in the kitchen for the afternoon",
				result = { wage = { 10, 25 }, intelligence = 1, log = "You washed cups for four hours. The owner paid you in Ahn and a tin of the house blend, and asked you to come back next year." },
			},
		},
	},
	{
		id = "wg_dly_inspection",
		title = "Inspection Day",
		text = "Inspectors in Wing uniforms are walking every Backstreets market today with tablets, checking stall permits and residence cards. Queues are forming outside the market gates. Down the street, a row of stalls hasn't seen them coming yet.",
		weight = 0,
		codex = "wg_lore_feathers",
		choices = {
			{
				label = "Show your papers and help the queue move",
				result = { intelligence = 1, sanity = 2, log = "You helped an old man find his residence card in a coat with eleven pockets. The queue moved. The inspector thanked you, which surprised you both." },
			},
			{
				label = "Run down the street and warn the stalls",
				hint = "A Mental Strength check: don't get caught doing it.",
				clash = { stat = "mind", foe = "An inspector with a tablet", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, log = "Every stall on the street had its papers on the counter by the time the inspectors arrived. A fruit seller gave you a bag of plums." },
				lose = { money = -15, sanity = -1, log = "An inspector saw you running and fined you for \"disruption\". The stalls still thanked you." },
			},
			{
				label = "Sign up as a temporary inspector for the day",
				result = { wage = { 20, 40 }, sanity = -2, log = "The Wing hires extra hands on inspection days. You checked papers for eight hours and wrote three fines. You'll remember the faces." },
			},
		},
	},
	{
		id = "wg_dly_time_audit",
		title = "The Time Audit",
		text = "T Corp's Collection Staff are out in every District today, silver timepieces ticking on their wrists, looking for Time Tax arrears from anyone who has ever spent a night in District 20. One of them is working your street with a ledger, and he's three doors away.",
		weight = 0,
		codex = "wg_lore_tcorp",
		choices = {
			{
				label = "Pay what he says you owe",
				result = { money = -15, sanity = 1, log = "You owed fifteen Ahn from a night in District 20 years ago, with interest. You paid. He thanked you for your punctuality, which felt like a joke." },
			},
			{
				label = "Argue the arithmetic",
				hint = "A Charisma check.",
				clash = { stat = "charisma", foe = "A T Corp ledger", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, log = "You found the error in his ledger: a night counted twice. He corrected it, sighing, and moved on to the next door. Your neighbors watched through their windows and cheered quietly." },
				lose = { money = -30, sanity = -2, log = "Your arithmetic was worse than his. The time you spent arguing, he pointed out, was also billable." },
			},
			{
				label = "Hide in the teahouse until he's gone",
				result = { sanity = 2, log = "You spent the afternoon in a teahouse with half the street. He passed by the window twice. You lost the afternoon anyway, which seemed fitting." },
			},
		},
	},

	-- ── world events: opening scenes ──
	{
		id = "lc_world_hiring_start",
		title = "L Corp Is Hiring Everywhere",
		text = "Every WARP platform and market in the City has an L Corp recruiting table today, under green posters: FACE THE FEAR, BUILD THE FUTURE. The recruiters offer relocation to District 12, a room near the facility, and a salary people say out loud and then go quiet about. The queues are long, and very silent.",
		weight = 0,
		when = { minAge = 14, world = { era = "wings" } },
		codex = "lcorp_abnormalities",
		choices = {
			{
				label = "Sign on as a Clerk",
				hint = "Moves you to District 12. Needs Health 25 and Mental Strength 25.",
				requires = { minAge = 18, notFlags = { "lcorp_employee" }, min = { health = 25, mind = 25 } },
				result = { district = "d12", career = "lcorp_agent", money = 60, codex = "lc_lore_agents", log = "You signed at the folding table and were on a WARP train to District 12 by evening, with a badge on a green lanyard and a key to a very small room under the tower." },
			},
			{
				label = "Ask about the research labs",
				hint = "Moves you to District 12. Needs Intelligence 38.",
				requires = { minAge = 18, notFlags = { "lcorp_employee" }, min = { intelligence = 38 } },
				result = { district = "d12", career = "lcorp_research", money = 60, codex = "lc_lore_risk_levels", log = "The recruiter's face lit up at the word research. By the end of the week you had a lab coat, a desk and a supervisor who told you to measure twice." },
			},
			{
				label = "Watch the recruiters work the crowd",
				result = { mind = 1, log = "You watched them for an hour. They never once used the word Abnormality. They said \"energy\" eleven times. You counted." },
			},
		},
	},
	{
		id = "lc_world_blackout_start",
		title = "The Green Lights Flicker",
		text = "Every light on your street flickers green, then dims to almost nothing. The radio says there's a problem at L Corp's facility and the City's energy supply is dipping in every District at once. In the dark, somebody's child is crying, and the old man upstairs is shouting that it's just like the last time.",
		weight = 0,
		when = { minAge = 8, world = { era = "wings" } },
		codex = "lc_lore_pe_boxes",
		choices = {
			{
				label = "Help the neighbors light their lamps",
				result = { sanity = 3, log = "You went door to door with matches and candles. By the time the lights came back, half the street was sitting together on the stairs, and nobody wanted to go in." },
			},
			{
				label = "Buy a black-market power cell",
				hint = "20 Ahn.",
				requires = { min = { money = 20 } },
				result = { money = -20, sanity = 1, log = "A man on the corner was selling off-brand green cells out of a sack before the lights had finished dimming. Yours ran your lamp all night. You didn't ask where it was from." },
			},
			{
				label = "Answer the call to come in",
				hint = "L Corp staff only.",
				requires = { career = { "lcorp_agent", "lcorp_research" } },
				result = { paycheck = 0.2, sanity = -3, setFlags = { "lc_breach_survivor" }, log = "Your badge buzzed: all staff to the facility. You worked through the night in emergency lighting while the gauge refilled, and walked home at dawn past streetlights coming back on one by one." },
			},
		},
	},
}
