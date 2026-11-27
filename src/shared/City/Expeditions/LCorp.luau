--[[
	Expeditions from the Wings: an L Corp suppression run (containment), a dive into a
	sealed L Corp branch after the fall (mission), and a Congested WARP train for W Corp's
	cleanup crews (mission). Solo or with a crew; the crew's best member fights each clash.
	A finished run sets done_<id> (lc_q_manuals waits on done_lc_exp_sealed_branch).
]]

return {
	order = { "lc_exp_suppression", "lc_exp_sealed_branch", "wg_exp_congested" },

	lc_exp_suppression = {
		name = "Suppression Team",
		kind = "containment",
		desc = "A WAW has breached on the third floor and the Disciplinary Team is pinned down below it. Control wants volunteers to hold the floor and get the Clerks out. Agents, Level 2 and up.",
		minAge = 18,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 4,
		when = { career = "lcorp_agent", minRank = 3, world = { era = "wings" } },
		start = "alarm",
		stages = {
			alarm = {
				title = "The Alarm",
				text = "Red lights on the third floor. Over the speakers, Malkuth is giving orders faster than anyone can follow them. The stairs are crowded with Clerks coming down. The service lift is empty, and it goes straight to the third floor, if it's still working.",
				tone = "danger",
				choices = {
					{ label = "Push up the stairs against the crowd", result = { health = { -3, -1 }, log = "{crew} fought up three flights of stairs against a river of Clerks." }, next = "corridor" },
					{
						label = "Take the service lift",
						hint = "An Intelligence check: the override code.",
						clash = { stat = "intelligence", foe = "A lift with a mind of its own", coins = 2, base = 4, coinPower = 3 },
						win = { log = "{champion} punched in the override and the lift went straight up. {crew} stepped out right beside the Clerks' room." },
						lose = { sanity = -2, log = "The lift stopped between floors for five long minutes. {crew} climbed out through the hatch." },
						winNext = "clerks",
						loseNext = "corridor",
					},
					{ label = "Stand down. Somebody else can go", ["end"] = "retreat", result = { sanity = -2, log = "{crew} stood down. Nobody said anything. The Record Team wrote it down." } },
				},
			},
			corridor = {
				title = "The Third-Floor Corridor",
				text = "The corridor lights are out. Something large is moving at the far end, and between you and it, a Clerk is crouched behind an overturned cart with her hands over her head. She sees your torch and stares at you without making a sound.",
				tone = "danger",
				choices = {
					{
						label = "Go and get the Clerk",
						hint = "A Health check: you'll be in the open.",
						clash = { stat = "health", foe = "Twenty meters in the open", coins = 2, base = 5, coinPower = 3 },
						win = { sanity = 2, log = "{champion} crossed the corridor in the dark, picked the Clerk up and carried her back without a sound." },
						lose = { health = { -8, -4 }, log = "{champion} got her back. Whatever was at the end of the corridor noticed on the way.", cause = "Fetching a Clerk in a breach" },
						next = "abno",
					},
					{ label = "Leave her hidden and push on", result = { sanity = -3, log = "{crew} whispered to her to stay put and went past. She did. You hope she still is." }, next = "abno" },
				},
			},
			clerks = {
				title = "The Clerks' Room",
				text = "Twelve Clerks are locked in the break room at the end of the floor, and they won't open the door for anyone, because the last voice that asked them to wasn't a person's. You have to convince them through the door that you're real.",
				choices = {
					{
						label = "Talk them out",
						hint = "A Mental Strength check.",
						clash = { stat = "mind", foe = "Twelve terrified Clerks", coins = 2, base = 4, coinPower = 3 },
						win = { sanity = 3, setFlags = { "lc_breach_survivor" }, log = "{champion} talked through the door about the cafeteria menu and the Record Team's handwriting until a Clerk laughed and opened it. All twelve went down the stairs alive." },
						lose = { sanity = -3, log = "They wouldn't open. {crew} left them behind a locked door, which is the safest place in the City, and went on." },
						next = "abno",
					},
				},
			},
			abno = {
				title = "The WAW",
				text = "It fills the end of the corridor: one of the facility's WAWs, loose and angry, and on its way to the stairs where the Clerks went down. The Disciplinary Team is still a floor away. It turns toward your torchlight.",
				tone = "danger",
				choices = {
					{
						label = "Suppress it",
						hint = "A real fight against a WAW.",
						clash = { stat = "strength", foe = "A breached WAW", coins = 3, base = 6, coinPower = 3, fight = true, status = "sinking" },
						win = { strength = 2, log = "{champion} led the charge, and between {crew} the WAW went down and back into its egg with a sound like a held breath let go." },
						lose = { health = { -14, -8 }, sanity = -4, log = "It was a WAW. {crew} learned what that means.", cause = "Suppressing a WAW" },
						winEnd = "success",
						loseEnd = "fail",
					},
					{
						label = "Hold it at the stairs until Disciplinary arrives",
						hint = "A Mental Strength check: steady nerves, ten minutes.",
						clash = { stat = "mind", foe = "Ten minutes in front of a WAW", coins = 2, base = 6, coinPower = 3 },
						win = { mind = 2, log = "{crew} held the stairwell with torches and riot sticks and nerve, and the red-armored Disciplinary Team came up behind it and finished it." },
						lose = { health = { -9, -5 }, sanity = -5, log = "Ten minutes was longer than {crew} had. The Disciplinary Team got there anyway, a little late." },
						winEnd = "success",
						loseEnd = "fail",
					},
				},
			},
		},
		success = { wage = { 60, 140 }, sanity = 2, setFlags = { "lc_breach_survivor", "saw_abnormality" }, chronicle = "lc_suppressed_breach", codex = "lc_lore_suppression", log = "The floor was quiet by evening. Control read {crew}'s names over every speaker in the facility, and the Clerks on the third floor took up a collection." },
		fail = { sanity = -4, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "The Disciplinary Team finished what {crew} started. Everyone who could walk walked out. Not everyone could." },
		retreat = { sanity = -1, log = "{crew} went back to the department and waited for the all-clear with everyone else." },
	},

	lc_exp_sealed_branch = {
		name = "The Sealed Branch",
		kind = "mission",
		desc = "Under the ruins of District 12, and District 4, lie the branches of Lobotomy Corporation, sealed since the fall. Scavengers go down for E.G.O, cells and old papers. Some of them come back. An old L Corp badge opens some of the doors.",
		minAge = 16,
		cooldown = 3,
		crew = { min = 1, max = 4 },
		length = 4,
		when = { district = { "d12", "d4" }, world = { era = { "library", "limbus" } } },
		start = "entrance",
		stages = {
			entrance = {
				title = "The Entrance",
				text = "A collapsed stairwell under a parking lot, and at the bottom a heavy door with the L Corp logo still on it, green paint peeling. There's a badge reader beside the door, somehow still lit. A ventilation shaft beside it goes down into the dark.",
				choices = {
					{ label = "Use your old L Corp badge", hint = "Ex-employees only.", requires = { flags = { "lcorp_employee" } }, result = { sanity = -1, log = "The reader blinked green. \"Welcome back,\" said a calm voice from a speaker that should have died years ago. The door opened." }, next = "lobby" },
					{
						label = "Climb down the ventilation shaft",
						hint = "A Health check.",
						clash = { stat = "health", foe = "A long dark shaft", coins = 2, base = 4, coinPower = 3 },
						win = { log = "{champion} went first and found the footholds. {crew} came down into the lobby covered in dust." },
						lose = { health = { -7, -3 }, log = "A rung gave way. {champion} landed hard in the lobby below.", cause = "Fell down a branch's ventilation shaft" },
						next = "lobby",
					},
					{ label = "Turn back", ["end"] = "retreat", result = { log = "{crew} looked at the door for a long time and went back up into the daylight." } },
				},
			},
			lobby = {
				title = "The Lobby",
				text = "The branch lobby is dark and dry and still. On one wall is the memorial: a long panel of names, employees who didn't clock out, the last few scratched in by hand. On the other wall, a map of the branch shows the safety office past the containment wing.",
				choices = {
					{ label = "Read the names on the wall", result = { sanity = -2, mind = 1, codex = "lc_lore_branches", log = "{crew} read every name by torchlight. It took a long time. Somebody had left a dried flower under the last one." }, next = "units" },
					{ label = "Go straight through the containment wing", result = { log = "{crew} skipped the wall and headed for the containment wing. Some things you read on the way out." }, next = "units" },
				},
			},
			units = {
				title = "The Containment Wing",
				text = "A long corridor of containment units, doors sealed. Almost all the boards outside them are dark. One isn't. Its Qliphoth Counter reads 1, and something behind that door is shuffling, waiting to be worked with, the way it was the day the branch went quiet.",
				tone = "danger",
				choices = {
					{
						label = "Do the work it wants, the way an Agent would",
						hint = "An Intelligence check. Ex-Agents know how.",
						clash = { stat = "intelligence", foe = "A unit that's waited years", coins = 2, base = 5, coinPower = 3 },
						win = { sanity = 2, setFlags = { "saw_abnormality" }, log = "{champion} worked the unit by the old procedure, by torchlight. The counter ticked up to 2. Behind the door, something settled. {crew} walked past it in silence." },
						lose = { sanity = -3, setFlags = { "saw_abnormality" }, log = "The counter clicked to 0." },
						winNext = "office",
						loseNext = "breach",
					},
					{
						label = "Creep past without a sound",
						hint = "A Mental Strength check.",
						clash = { stat = "mind", foe = "A door that's listening", coins = 2, base = 4, coinPower = 3 },
						win = { log = "{crew} got past every door without a sound. The shuffling behind the lit one stopped as you went by, and started again after." },
						lose = { sanity = -2, log = "Someone's boot scuffed the floor. The board flickered. The door began to open." },
						winNext = "office",
						loseNext = "breach",
					},
				},
			},
			breach = {
				title = "Something Still Down Here",
				text = "The door of the lit unit is open, and whatever was inside has been alone in the dark for years. It comes down the corridor toward your torches, faster than you'd like.",
				tone = "danger",
				choices = {
					{
						label = "Fight it",
						hint = "A real fight.",
						clash = { stat = "strength", foe = "A forgotten Abnormality", coins = 3, base = 5, coinPower = 3, fight = true, status = "rupture" },
						win = { strength = 2, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "{champion} drove it back into its unit and {crew} slammed the door. The board went dark. It'll be there for the next crew." },
						lose = { health = { -12, -6 }, sanity = -4, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "It drove {crew} back up the corridor and out of the branch.", cause = "Met something in a sealed branch" },
						winNext = "office",
						loseEnd = "fail",
					},
					{ label = "Run for the shaft", ["end"] = "retreat", result = { health = { -4, -1 }, sanity = -3, setFlags = { "saw_abnormality" }, log = "{crew} ran. It didn't follow past the lobby. Nobody looked back to see why." } },
				},
			},
			office = {
				title = "The Safety Office",
				text = "The safety office is untouched: a desk, a kettle, a calendar stopped on the last day. On the shelves, the branch's safety manuals in their green binders, and behind the desk a crate of old Enkephalin cells, still glowing faintly.",
				choices = {
					{ label = "Take the manuals", result = { sanity = 2, log = "{crew} packed every manual. The calendar on the wall had a birthday circled for the day after the last day." }, ["end"] = "success" },
					{ label = "Take the manuals and the cells", result = { money = { 60, 160 }, sanity = -2, log = "{crew} took the manuals and the cells. The cells were heavy, and warm, and sold well. You try not to think about what's in them." }, ["end"] = "success" },
				},
			},
		},
		success = { wage = { 30, 90 }, mind = 1, setFlags = { "lc_branch_dived" }, codex = "lc_lore_branches", log = "{crew} came up into daylight with the manuals and the dust of the old company on every coat. The Green Kettle bought the first round of tea." },
		fail = { sanity = -4, log = "{crew} got out of the branch alive, which is more than some crews can say." },
		retreat = { log = "{crew} came back up. The branch will be there tomorrow. It will always be there." },
	},

	wg_exp_congested = {
		name = "A Congested Train",
		kind = "mission",
		desc = "The board on Platform Nine says CONGESTED: a rare and dangerous threat aboard a WARP train that has just arrived. W Corp needs several Level 3 or 4 agents, or one in CCA armor, to clear it before the doors open. Cleanup Agents, Level 2 and up.",
		minAge = 18,
		cooldown = 2,
		crew = { min = 1, max = 3 },
		length = 3,
		when = { career = "wcorp_cleanup", minRank = 2 },
		start = "platform",
		stages = {
			platform = {
				title = "Platform Nine",
				text = "The train sits at the platform with its doors sealed and its windows fogged from the inside. The warning board flashes CONGESTED in amber. In the equipment bay behind you, a suit of Congestion Cleaning Armor stands on its rack, worth more than the station.",
				tone = "danger",
				choices = {
					{ label = "Suit up in the CCA", hint = "Level 4 and up, with top marks.", requires = { career = "wcorp_cleanup", minRank = 4 }, result = { addTrait = "wg_cca_certified", setFlags = { "wg_cca_worn" }, codex = "wg_lore_cleanup", log = "{champion} climbed into the CCA. The armor sealed with a hiss, the visor lit up, and for the first time in your career you felt bigger than the train." }, next = "carriage" },
					{ label = "Board with the crew as you are", result = { sanity = -1, codex = "wg_lore_cleanup", log = "No armor today. {crew} checked their batons, nodded to each other, and opened the first door." }, next = "carriage" },
					{ label = "Wait for a Level 5", ["end"] = "retreat", result = { log = "{crew} waited on the platform for a Level 5 crew, which is in the rules, and is what most people do." } },
				},
			},
			carriage = {
				title = "Carriage Three",
				text = "The passengers in Carriage Three have lived a very long time in the few seconds the trip took. They're calm, and gray, and some of them are humming the same tune. A few of them have stood up and are looking at you as if they've been waiting for you for years.",
				tone = "strange",
				choices = {
					{
						label = "Talk them back into their seats",
						hint = "A Mental Strength check.",
						clash = { stat = "mind", foe = "Passengers who lived too long", coins = 2, base = 5, coinPower = 3 },
						win = { sanity = 2, log = "{champion} talked to them about the station, the date, the price of tea, until one by one they sat down. One old man thanked you for reminding him what year it was." },
						lose = { sanity = { -6, -3 }, log = "One of them told {champion} exactly how long the trip had been, from inside. It's not a number you can forget." },
						next = "front",
					},
					{
						label = "Push through to the front car",
						hint = "A Health check.",
						clash = { stat = "health", foe = "A crowded carriage", coins = 2, base = 5, coinPower = 3 },
						win = { log = "{crew} shouldered through the carriage, gently, and got to the connecting door." },
						lose = { health = { -6, -3 }, log = "The passengers held on. Not hard. Just for a very long time." },
						next = "front",
					},
				},
			},
			front = {
				title = "The Front Car",
				text = "The threat is in the front car: something that was a passenger at the start of the trip and has had a very long time to become something else. It turns away from the window, where it's been watching the tunnel, and looks at you.",
				tone = "danger",
				choices = {
					{
						label = "Clear the car",
						hint = "A real fight. It has had a long time to get strong.",
						clash = { stat = "health", foe = "The thing in the front car", coins = 3, base = 6, coinPower = 3, fight = true, status = "tremor" },
						win = { health = 2, log = "{champion} took it down in the narrow car, panel by panel, until it stopped moving. The board on the platform flicked from CONGESTED to UNOBSTRUCTED." },
						lose = { health = { -14, -8 }, sanity = -4, log = "It had had a long time to get strong. {crew} held the door until a Level 5 crew came through.", cause = "Clearing a Congested train" },
						winEnd = "success",
						loseEnd = "fail",
					},
				},
			},
		},
		success = { wage = { 120, 260 }, sanity = 2, chronicle = "wg_cca_congested", codex = "wg_lore_train_states", log = "{crew} cleared the train. W Corp reopened Platform Nine with an apology for the delay, and only for the delay." },
		fail = { sanity = -4, log = "A Level 5 crew finished the job. {crew} filed the report nobody will read." },
		retreat = { log = "{crew} waited it out. A Level 5 crew cleared the train in twenty minutes and didn't say a word on the way past." },
	},
}
