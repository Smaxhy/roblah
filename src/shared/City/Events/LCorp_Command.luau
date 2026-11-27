--[[
	L Corp under pressure, and from the top: Ordeals (CANON 5.6) by rank, the Department
	Captain's decisions (staffing, who works on what), the road to Branch Manager, and the
	Manager's own cards (quotas, hiring, a new egg, the Midnight of White).
	Rank gates: Ordeals from rank 2 (Dawn) to Captain (Midnight); Captain = rank 7
	(flag lcorp_captain), Branch Manager = rank 8 (flag lcorp_manager).
	lc_fall_catchup closes the job for anyone the White Nights' cards missed.
]]

local ORDEAL_HELD = { "lc_breach_survivor", "saw_abnormality" }
local CAPTAIN = { career = "lcorp_agent", minRank = 7, world = { era = "wings" }, notFlags = { "lcorp_manager" } }
local MANAGER = { career = "lcorp_agent", minRank = 8, world = { era = "wings" } }

return {
	-- ── Ordeals ──
	{
		id = "lc_ordeal_green_dawn",
		title = "The Dawn of Green: Doubt",
		text = "The gauge fills, and instead of a meltdown the lights turn green. Small boxy machines on thin legs pour out of a supply elevator into your corridor, dozens of them, and they're asking a question in flat little voices, over and over: \"Why were we made? Why were we made?\" They aren't waiting for an answer before they attack.",
		weight = 18,
		cooldown = 5,
		tags = { "lcorp", "ordeal" },
		when = { career = "lcorp_agent", minRank = 2, world = { era = "wings" } },
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Fight them back into the elevator",
				hint = "A real fight. There are a lot of them.",
				clash = { stat = "strength", foe = "The Dawn of Green", coins = 2, base = 4, coinPower = 3, fight = true, status = "tremor" },
				win = { strength = { 2, 3 }, paycheck = 0.12, setFlags = ORDEAL_HELD, chronicle = "lc_ordeal_held", log = "You and two other Agents held the corridor with riot sticks until the last little machine stopped asking. The silence afterward was very loud." },
				lose = { health = { -9, -4 }, setFlags = ORDEAL_HELD, log = "They swarmed you. You fought until the Disciplinary Team got there, and then you sat down hard.", cause = "Overrun by the Dawn of Green" },
			},
			{
				label = "Get the Clerks into the shelter",
				hint = "A Health check.",
				clash = { stat = "health", foe = "Thin metal legs", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, setFlags = ORDEAL_HELD, log = "You got every Clerk on the floor into the shelter and held the door. The machines tapped on it for an hour, asking. Nobody answered." },
				lose = { health = { -7, -3 }, setFlags = ORDEAL_HELD, log = "You got them in. You were the last one through, and the slowest." },
			},
			{
				label = "Answer their question",
				hint = "A Mental Strength check. Do you know why anything was made?",
				clash = { stat = "mind", foe = "Why were we made?", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = 2, setFlags = ORDEAL_HELD, log = "You told them, \"To find out.\" They stopped, all of them, and stood there thinking about it long enough for the Disciplinary Team to arrive. You still don't know where the answer came from." },
				lose = { sanity = { -6, -3 }, setFlags = ORDEAL_HELD, log = "You opened your mouth and had nothing. Neither did they. You think about that more than the fight." },
			},
		},
	},
	{
		id = "lc_ordeal_amber_dawn",
		title = "The Dawn of Amber: The Perfect Food",
		text = "At lunch, the cafeteria floor cracks. Small burrowing things with round, hungry mouths come up through the tiles, chewing through table legs and dropped trays and anything else they can reach. Somebody's still eating. Somebody's standing on a chair, screaming. The floor hatches to the lower levels are all wide open.",
		weight = 18,
		cooldown = 5,
		tags = { "lcorp", "ordeal" },
		when = { career = "lcorp_agent", minRank = 2, world = { era = "wings" } },
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Fight them off",
				hint = "A real fight.",
				clash = { stat = "strength", foe = "The Dawn of Amber", coins = 2, base = 4, coinPower = 3, fight = true, status = "rupture" },
				win = { strength = { 2, 3 }, paycheck = 0.12, setFlags = ORDEAL_HELD, chronicle = "lc_ordeal_held", log = "You fought them table by table until the last one burrowed back down. The cafeteria served lunch again the next day. You brought your own." },
				lose = { health = { -9, -4 }, setFlags = ORDEAL_HELD, condition = "deep_cut", log = "There were more of them than there were of you. The suppression team arrived just as you ran out of table to stand on.", cause = "Swarmed by the Dawn of Amber" },
			},
			{
				label = "Run for the floor hatches and seal them",
				hint = "An Intelligence check: four hatches, one minute.",
				clash = { stat = "intelligence", foe = "Four open hatches", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, sanity = 2, setFlags = ORDEAL_HELD, log = "You sealed the hatches one by one and cut off the swarm. The ones already up were easy work for the Agents after that." },
				lose = { health = { -6, -3 }, setFlags = ORDEAL_HELD, log = "You got three hatches shut. The fourth one was busy." },
			},
			{
				label = "Get everyone up onto the tables",
				result = { sanity = { -3, -1 }, setFlags = ORDEAL_HELD, log = "You got everyone up onto the tables and stood on yours with a tray in both hands until it was over. It worked. It looked ridiculous. It worked." },
			},
		},
	},
	{
		id = "lc_ordeal_crimson_noon",
		title = "The Noon of Crimson: The Harmony of Skin",
		text = "Drums, then laughter. A circus troupe in red comes marching through the department, grinning very wide, tooting horns, juggling things that aren't balls. Anyone who stops to watch the parade starts to clap along, and then to march with it. Three Clerks are already in step.",
		weight = 16,
		cooldown = 5,
		tags = { "lcorp", "ordeal" },
		when = { career = "lcorp_agent", minRank = 3, world = { era = "wings" } },
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Break up the parade",
				hint = "A real fight. They are always smiling.",
				clash = { stat = "strength", foe = "The Noon of Crimson", coins = 2, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = { 2, 3 }, paycheck = 0.15, setFlags = ORDEAL_HELD, chronicle = "lc_ordeal_held", log = "You broke the parade apart, drum by drum, until the last clown stopped laughing. The Clerks woke up in the middle of the corridor with sore hands and no memory of clapping." },
				lose = { health = { -11, -6 }, sanity = -3, setFlags = ORDEAL_HELD, log = "The troupe closed around you, laughing. You don't remember the next part, only the drums.", cause = "Joined the parade of the Noon of Crimson" },
			},
			{
				label = "Pull the Clerks out of step",
				hint = "A Mental Strength check: don't listen to the drums.",
				clash = { stat = "mind", foe = "The drums", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = 3, setFlags = ORDEAL_HELD, log = "You grabbed them one at a time and talked them out of the rhythm, loudly, about nothing. Tax forms. Lunch. The price of noodles on Fourth Street. It worked on all three." },
				lose = { sanity = { -6, -3 }, setFlags = ORDEAL_HELD, log = "You caught yourself clapping. You stopped. It took a while for your hands to stop wanting to." },
			},
			{
				label = "Cover your ears and get out of the way",
				result = { sanity = { -4, -2 }, setFlags = ORDEAL_HELD, log = "You flattened yourself against the wall with your hands over your ears while the parade went past, grinning at you. The Disciplinary Team stopped it two corridors later." },
			},
		},
	},
	{
		id = "lc_ordeal_violet_noon",
		title = "The Noon of Violet: Grant Us Love",
		text = "Tall violet monoliths appear in the corridors without arriving, humming. They are trying, very hard, to understand the people around them, and every time they try, everyone nearby gets a splitting headache. A Clerk is kneeling in front of one, nose bleeding, trying to explain to it what a sandwich is.",
		weight = 15,
		cooldown = 5,
		tags = { "lcorp", "ordeal" },
		when = { career = "lcorp_agent", minRank = 4, world = { era = "wings" } },
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Bring the monolith down",
				hint = "A real fight. Your head will be pounding the whole time.",
				clash = { stat = "strength", foe = "The Noon of Violet", coins = 2, base = 5, coinPower = 3, fight = true, status = "sinking" },
				win = { strength = { 2, 3 }, paycheck = 0.15, setFlags = ORDEAL_HELD, chronicle = "lc_ordeal_held", log = "You hit it until it stopped humming and folded away into nowhere. The Clerk thanked you and asked, very seriously, if you knew what a sandwich was." },
				lose = { health = { -8, -4 }, sanity = { -6, -3 }, setFlags = ORDEAL_HELD, log = "It tried to understand you, in detail. You woke up in Welfare with the worst headache of your life.", cause = "Understood by the Noon of Violet" },
			},
			{
				label = "Think about nothing at all and pull the Clerk away",
				hint = "A Mental Strength check: give it nothing to understand.",
				clash = { stat = "mind", foe = "Being understood", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, setFlags = ORDEAL_HELD, log = "You emptied your head the way the Welfare Team teaches and walked the Clerk away. The monolith hummed, puzzled, at the space where you'd been." },
				lose = { sanity = { -7, -4 }, setFlags = ORDEAL_HELD, condition = "lc_shaken", log = "You tried to think of nothing and thought of your whole life at once. It understood all of it. You wish it hadn't." },
			},
			{
				label = "Evacuate the department",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "A department full of headaches", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, sanity = 1, setFlags = ORDEAL_HELD, log = "You got the department out by the service stairs, one aching head at a time. The monoliths kept trying to understand an empty room." },
				lose = { sanity = -4, health = -3, setFlags = ORDEAL_HELD, log = "The stairs were full of people with the same idea. Everyone got out, eventually, slowly." },
			},
		},
	},
	{
		id = "lc_ordeal_indigo_noon",
		title = "The Noon of Indigo: The Sweepers",
		terms = { "Sweepers" },
		text = "Every Backstreets kid knows this sound. Tall figures in long coats come up out of the lower levels, quiet, unhurried, sweeping the corridors clean. The Night has come into the facility at noon. The shutters on your department are still open, and the Clerks are staring at the door like it's 3:12.",
		weight = 15,
		cooldown = 5,
		tags = { "lcorp", "ordeal" },
		when = { career = "lcorp_agent", minRank = 4, world = { era = "wings" } },
		codex = { "lc_lore_ordeals", "city_sweepers" },
		choices = {
			{
				label = "Hold the corridor against them",
				hint = "A real fight. Nobody fights the Sweepers on purpose.",
				clash = { stat = "strength", foe = "The Sweepers", coins = 3, base = 5, coinPower = 3, fight = true, status = "sinking" },
				win = { strength = { 2, 3 }, paycheck = 0.18, setFlags = ORDEAL_HELD, addTrait = "lc_breach_hardened", chronicle = "lc_ordeal_held", log = "You held the corridor against the Sweepers, which nobody in the Backstreets will believe. They went back down eventually, unhurried, as if they'd just been passing through." },
				lose = { health = { -14, -7 }, sanity = -4, setFlags = ORDEAL_HELD, log = "They swept around you like water around a stone. Mostly around.", cause = "Swept away by the Noon of Indigo" },
			},
			{
				label = "Get the shutters down",
				hint = "A Health check: they're heavy, and you're in a hurry.",
				clash = { stat = "health", foe = "Heavy shutters", coins = 2, base = 5, coinPower = 3 },
				win = { health = 2, sanity = 3, setFlags = ORDEAL_HELD, log = "You hauled the shutters down with seconds to spare. A locked room is a sanctuary; every Clerk in there knew it. Nobody spoke until the sweeping sound was gone." },
				lose = { health = { -8, -4 }, setFlags = ORDEAL_HELD, log = "You got them down, but your arm was in the way of the last one." },
			},
			{
				label = "Do what you'd do at home: lock up and stay quiet",
				result = { sanity = { -3, -1 }, mind = 1, setFlags = ORDEAL_HELD, log = "You pulled the Clerks into the supply room, locked it, and sat in the dark the way you've sat every night of your life. They swept past. It's the Night. You know how the Night works." },
			},
		},
	},
	{
		id = "lc_ordeal_green_dusk",
		title = "The Dusk of Green: Where We Must Reach",
		text = "Something huge is climbing up the elevator shaft: a machine building itself as it goes, wheels and pistons and arms, trying to reach the top of the facility. Every floor it passes goes dark. It's two floors below yours, and the department's power junction is right beside the shaft.",
		weight = 16,
		cooldown = 5,
		tags = { "lcorp", "ordeal" },
		when = { career = "lcorp_agent", minRank = 5, world = { era = "wings" } },
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Meet it at the shaft",
				hint = "A real fight, and a hard one.",
				clash = { stat = "strength", foe = "The Dusk of Green", coins = 3, base = 6, coinPower = 3, fight = true, status = "charge" },
				win = { strength = { 2, 3 }, paycheck = 0.2, setFlags = ORDEAL_HELD, addTrait = "lc_breach_hardened", chronicle = "lc_ordeal_held", log = "You met it at the shaft with everything your department had and took it apart arm by arm as it climbed. It never reached your floor. It never reached the top." },
				lose = { health = { -15, -8 }, sanity = -4, setFlags = ORDEAL_HELD, log = "It climbed past you. Someone above stopped it. You were carried out of the shaft on a stretcher.", cause = "Crushed by the Dusk of Green" },
			},
			{
				label = "Cut the power at the junction",
				hint = "An Intelligence check: the right switches, in the dark.",
				clash = { stat = "intelligence", foe = "The power junction", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 2, sanity = 2, setFlags = ORDEAL_HELD, log = "You cut the shaft's power three seconds before it reached you. It stopped climbing, confused, and the Disciplinary Team took it apart where it hung." },
				lose = { health = { -8, -4 }, sanity = -2, setFlags = ORDEAL_HELD, log = "You threw the wrong switch, then the right one, and the shock threw you across the room." },
			},
			{
				label = "Evacuate up the stairs",
				result = { sanity = { -4, -2 }, setFlags = ORDEAL_HELD, log = "You got your department up the stairs ahead of it. It reached your floor a minute after you'd left. You watched the dark climb past the window." },
			},
		},
	},
	{
		id = "lc_ordeal_midnight",
		title = "The Midnight of Green: Helix of the End",
		text = "Midnight. A tower of machines is rising through the center of the facility, through every floor at once, and every department is fighting for its life. Your department is the last line between the tower and the Clerks' shelter. Your Agents are looking at you. You're the Captain. This is what the armband is for.",
		weight = 22,
		cooldown = 6,
		tags = { "lcorp", "ordeal" },
		when = { career = "lcorp_agent", minRank = 7, world = { era = "wings" } },
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Lead the attack yourself",
				hint = "A real fight against a Midnight Ordeal. Brutal.",
				clash = { stat = "strength", foe = "The Midnight of Green", coins = 4, base = 7, coinPower = 3, fight = true, status = "charge" },
				win = { strength = { 3, 4 }, paycheck = 0.3, setFlags = { "lc_breach_survivor", "saw_abnormality", "lc_held_midnight" }, addTrait = "lc_breach_hardened", chronicle = "lc_ordeal_held", log = "You led your Agents into the tower and tore its middle out, and it came down through the floors like a falling street. In the morning, the Manager's voice said your department's name over every speaker in the building." },
				lose = { health = { -18, -10 }, sanity = -6, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You led the attack and fell in it. Your Agents held the shelter without you, the way you'd trained them.", cause = "Fell leading the line at Midnight" },
			},
			{
				label = "Rotate your Agents and hold the shelter door",
				hint = "A hard Mental Strength check: keep everyone in the fight, and alive.",
				clash = { stat = "mind", foe = "A night that won't end", coins = 3, base = 6, coinPower = 3 },
				win = { mind = 3, sanity = 2, setFlags = { "lc_breach_survivor", "saw_abnormality", "lc_held_midnight", "lc_captain_fair" }, chronicle = "lc_ordeal_held", log = "You held the shelter door all night, rotating your Agents in and out so nobody fought longer than they could bear. Dawn came. The Clerks walked out of the shelter one by one, and every one of them shook your hand." },
				lose = { sanity = { -8, -5 }, health = { -8, -4 }, setFlags = { "lc_breach_survivor", "saw_abnormality" }, condition = "lc_shaken", log = "The door held. Not everyone in front of it did. You'll be writing letters for a week." },
			},
			{
				label = "Evacuate your department through the lower tunnels",
				hint = "An Intelligence check: get everyone out before the tunnels close.",
				clash = { stat = "intelligence", foe = "Collapsing tunnels", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 2, sanity = 1, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You got every one of your people out through the tunnels. Headquarters wrote you up for abandoning the line. Every family in your department sent you a letter." },
				lose = { health = { -9, -5 }, sanity = -4, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "The tunnels came down behind the last of you. You were the last of you." },
			},
		},
	},

	-- ── the Department Captain ──
	{
		id = "lc_captain_armband",
		title = "The Captain's Armband",
		text = "Your department's Captain, Odile Marchetti, is moving up to Central Command after eleven years. By company rule the armband goes to the longest-serving Agent in the department who has passed seven days. The Record Team is counting. On paper, that should be you, unless you transferred somewhere along the way.",
		weight = 40,
		cooldown = 3,
		tags = { "lcorp" },
		when = { career = "lcorp_agent", minRank = 6, world = { era = "wings" }, notFlags = { "lcorp_captain" } },
		codex = "lc_lore_agents",
		choices = {
			{
				label = "Take the armband",
				hint = "You stayed in your department. It's yours.",
				requires = { flags = { "lc_department_loyal" } },
				result = { promote = true, sanity = 3, log = "Odile pinned it on you herself. \"They'll look at you differently now,\" she said. \"Try to deserve it.\" Then she went upstairs and never came back down." },
			},
			{
				label = "Ask the Record Team to count your days again",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "The Record Team's ledger", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, log = "Hokma counted every day you'd ever served, slowly, aloud, in front of the whole department. You won by nine. Odile shook your hand and gave you her pen." },
				lose = { sanity = -2, log = "Someone had served eleven days longer. The armband went to them, and you held the door for them on their first day." },
			},
			{
				label = "Let someone else have it",
				result = { sanity = 3, mind = 1, log = "You stepped aside. A Captain's armband is a target, Baek always said. You went home on time that night and slept well." },
			},
		},
	},
	{
		id = "lc_captain_first_day",
		title = "Captain",
		text = "You wear the Captain's armband to the morning briefing for the first time. Your department's Agents are standing in a row, and you realize every one of them is waiting to hear what you'll say. Some of them are older than you. Two of them were hired last week and look terrified.",
		weight = 120,
		once = true,
		tags = { "lcorp" },
		when = CAPTAIN,
		choices = {
			{
				label = "Tell them the only rule that matters",
				result = { intelligence = 2, sanity = 2, setFlags = { "lc_captain_fair" }, log = "\"Read the file,\" you said. \"Then read it again. And nobody here volunteers for anything without telling me first.\" One of the rookies wrote it on his hand." },
			},
			{
				label = "Take the hardest unit on today's board yourself",
				result = { strength = 2, health = -2, setFlags = { "lc_captain_brave" }, log = "You put your own name next to the WAW on the board before anyone else could. Nobody said anything. Everybody noticed." },
			},
			{
				label = "Learn every Agent's name and Virtues before lunch",
				result = { mind = 2, setFlags = { "lc_captain_names" }, log = "By lunch you knew every one of them: their names, their Virtues, which units they'd survived. It will matter, the first time you have to choose who goes where." },
			},
		},
	},
	{
		id = "lc_captain_staffing",
		title = "Who Works on What",
		text = "Tomasz Weil, a Level 1 Agent six weeks into the job, wants the HE unit on today's board. \"I'm ready, Captain,\" he says. He isn't. He's brave, and quick, and he has read the file once. The Manager has left the assignment to you.",
		weight = 30,
		cooldown = 4,
		tags = { "lcorp" },
		when = CAPTAIN,
		choices = {
			{
				label = "Give him the ZAYIN and take the HE yourself",
				result = { sanity = 1, health = { -3, 0 }, log = "He sulked. You worked the HE. At the end of the day he came and thanked you, because the HE had done to you what it would have done to him." },
			},
			{
				label = "Let him try the HE with you shadowing",
				hint = "An Intelligence check: let him learn, and be ready.",
				clash = { stat = "intelligence", foe = "A rookie's first HE", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, sanity = 3, setFlags = { "lc_rookie_grew", "lc_captain_fair" }, log = "You stood at his shoulder and said almost nothing, and he did it right. He'll be a Captain one day. You'll be able to say you knew him when." },
				lose = { health = { -6, -3 }, sanity = -3, log = "It went wrong halfway through and you pulled him out by his collar. You both lived. He's read the file six times since." },
			},
			{
				label = "Give him the HE on his own. He has to learn",
				result = { sanity = { -5, -3 }, setFlags = { "lc_captain_harsh" }, log = "He came back. He came back changed, and quieter, and he doesn't ask for the hard units anymore. You tell yourself it's a lesson. Some days you believe it." },
			},
		},
	},
	{
		id = "lc_captain_clerks",
		title = "Clerk Benefits",
		text = "A meltdown at lunch. Your Agents are scattered across five units, and the department's Clerks are trapped in the break room at the end of a corridor where a TETH is loose. Officially, the Clerks are a department bonus: as long as enough of them survive, the department works better. Unofficially, you know all of their names.",
		weight = 26,
		cooldown = 4,
		tags = { "lcorp" },
		when = CAPTAIN,
		codex = "lc_lore_agents",
		choices = {
			{
				label = "Go and get them yourself",
				hint = "A real fight with a loose TETH.",
				clash = { stat = "strength", foe = "A loose TETH", coins = 2, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = 2, sanity = 4, setFlags = { "lc_breach_survivor", "saw_abnormality" }, chronicle = "lc_suppressed_breach", log = "You went down the corridor alone, put the TETH back in its egg, and opened the break room door. Twelve Clerks came out. You've never been prouder of a number." },
				lose = { health = { -10, -5 }, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You got there. You got them out. It got you on the way back.", cause = "Fetching the Clerks" },
			},
			{
				label = "Pull two Agents off their units to escort them",
				hint = "A Mental Strength check: which two units can wait?",
				clash = { stat = "mind", foe = "Five units and two Agents", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "You picked the two units that could wait, and you picked right. The Clerks came out in a line between two riot sticks, and the units held." },
				lose = { sanity = -4, paycheck = -0.1, log = "One of the units couldn't wait after all. The Clerks got out. The quota took the hit, and headquarters noticed." },
			},
			{
				label = "Tell them to lock the door and wait",
				result = { sanity = -3, log = "You told them over the radio to lock the door and stay quiet. The door held. They waited three hours. None of them has looked at you quite the same since." },
			},
		},
	},
	{
		id = "lc_captain_double_shifts",
		title = "Double Shifts",
		text = "The Control Team wants your department on double shifts for the rest of the month: the quota is behind across the whole facility. Malkuth's message is short and has three exclamation marks. Your Agents are already exhausted, and exhausted Agents make mistakes in containment units.",
		weight = 24,
		cooldown = 4,
		tags = { "lcorp" },
		when = CAPTAIN,
		codex = "lc_lore_pe_boxes",
		choices = {
			{
				label = "Run the double shifts",
				result = { paycheck = 0.25, sanity = { -5, -3 }, setFlags = { "lc_captain_harsh" }, log = "You ran them. The quota filled. Two of your Agents went to Welfare and one didn't come back to work. Malkuth sent a message with one exclamation mark, which is her version of gratitude." },
			},
			{
				label = "Push back on Malkuth",
				hint = "A Mental Strength check against the Control Team.",
				clash = { stat = "mind", foe = "Malkuth", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = 3, log = "You walked up to Control and laid it out: tired Agents, bad work, breaches, worse quota. Malkuth stared at you for a full minute. Then she cut the order to one extra shift a week." },
				lose = { sanity = -4, log = "Malkuth heard you out and doubled the order. \"Captains,\" she said, \"are replaceable.\"" },
			},
			{
				label = "Rotate the worst units so nobody works two in a row",
				result = { intelligence = 2, sanity = -1, setFlags = { "lc_captain_fair" }, log = "You rebuilt the whole schedule by hand so nobody pulled two hard units back to back. It took three nights. Nobody went to Welfare that month." },
			},
		},
	},
	{
		id = "lc_captain_locker",
		title = "The Empty Locker",
		text = "One of your Agents didn't clock out last night. The memorial wall in the lobby has a new name on it this morning, and the locker in your department has a name tag and a photograph of a family taped inside the door. The company will send the family a form letter. You're the Captain. You could go yourself.",
		weight = 22,
		cooldown = 4,
		tags = { "lcorp" },
		when = CAPTAIN,
		choices = {
			{
				label = "Visit the family yourself",
				result = { intelligence = 2, sanity = -3, setFlags = { "lc_captain_kind" }, log = "You sat at their kitchen table for two hours. You told them the truth, as much of it as you could. Their youngest asked if her mother had been brave. You said yes. It was true." },
			},
			{
				label = "Let the form letter go",
				result = { sanity = -1, log = "The form letter went out. It was well written. You signed it, with your own name, which was the least you could do. You knew it was the least." },
			},
			{
				label = "Start a collection for the family",
				hint = "60 Ahn.",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 2, relationBond = { kind = "all", amount = 3 }, log = "You put in sixty and passed the jar. By evening it was full. You took it to the family with the photograph from the locker, and they kept you for dinner." },
			},
		},
	},
	{
		id = "lc_manager_offer",
		title = "A Branch of Your Own",
		text = "A letter from headquarters, sealed in green wax. One of L Corp's branch facilities needs a Manager, and the Record Team has put forward a short list of Captains. Your name is on it. A Branch Manager sits above the departments, decides who works on what, and never goes down into the units again. The last one is described in the letter as \"retired\".",
		weight = 50,
		cooldown = 3,
		tags = { "lcorp" },
		when = CAPTAIN,
		codex = { "lc_lore_manager", "lc_lore_branches" },
		choices = {
			{
				label = "Accept the branch",
				hint = "Needs Mental Strength 50 and Intelligence 45.",
				requires = { min = { mind = 50, intelligence = 45 } },
				result = { promote = true, sanity = 2, chronicle = "lc_made_manager", log = "You signed. A week later you sat down in a control room above a hundred containment units with a hundred cameras on a hundred screens, and every Agent in the building was yours to send." },
			},
			{
				label = "Accept, if you can bring your own Captains",
				hint = "Needs Mental Strength 45, and people who'd follow you.",
				requires = { min = { mind = 45 }, flags = { "lc_captain_fair" } },
				result = { promote = true, sanity = 4, chronicle = "lc_made_manager", log = "Headquarters agreed, which surprised everyone. Your old department came with you, the Clerks included. On your first day as Branch Manager, they had already rearranged the break room the way you liked it." },
			},
			{
				label = "Ask what happened to the last Manager",
				result = { mind = 2, setFlags = { "lc_asked_last_manager" }, log = "Nobody would say. Hokma, eventually, said that the last Manager had \"asked too many questions about the bottom floor,\" and then seemed to wish he hadn't said it." },
			},
			{
				label = "Decline. You belong on the floor",
				result = { sanity = 3, addTrait = "lc_steadfast_veteran", log = "You wrote back that your place was on the floor with your Agents. Headquarters didn't reply. Your department threw you a party anyway." },
			},
		},
	},

	-- ── the Branch Manager ──
	{
		id = "lc_mgr_first_day",
		title = "The Control Room",
		text = "Your control room sits above the whole branch: a wall of screens, one for every corridor and every containment unit. A calm assistant's voice from headquarters says, \"Good morning, Manager. Today's energy quota has been sent to your terminal.\" Below you, a hundred Agents are waiting to be told what to do.",
		weight = 140,
		once = true,
		tags = { "lcorp" },
		when = MANAGER,
		codex = "lc_lore_manager",
		choices = {
			{
				label = "Walk every department before you sit down",
				result = { health = 1, sanity = 3, setFlags = { "lc_mgr_walked" }, log = "You walked every floor and shook every hand, Clerks first. The Agents talked about it for weeks: a Manager who came downstairs. It's the last time you'll do it." },
			},
			{
				label = "Read every Abnormality file in the branch",
				result = { mind = 2, codex = { "lc_abno_army_in_black", "lc_abno_fragment", "lc_abno_shy_look", "lc_abno_scarecrow", "lc_abno_woodsman", "lc_abno_firebird", "lc_abno_red_hood", "lc_abno_king_greed" }, log = "You read every file, twice, before you sent anyone anywhere. It took three days. The Information Team said nobody had done that in years." },
			},
			{
				label = "Meet your Captains",
				result = { intelligence = 2, setFlags = { "lc_mgr_captains" }, log = "You met your Captains in the control room, one by one, and asked each what they needed. Two of them cried. Nobody had asked them before." },
			},
		},
	},
	{
		id = "lc_mgr_quota",
		title = "The Quota",
		text = "Headquarters has raised your branch's energy quota again. The figure on your terminal would mean every Agent working every unit on the board, twice, including the WAWs. The calm voice from headquarters says it understands this is challenging. It does not say it's optional.",
		weight = 40,
		cooldown = 2,
		tags = { "lcorp" },
		when = MANAGER,
		codex = "lc_lore_pe_boxes",
		choices = {
			{
				label = "Push the Agents to hit it",
				result = { paycheck = 0.3, sanity = { -6, -4 }, log = "You hit the quota. On the screens, you watched what it cost. The memorial wall in the lobby got longer, and headquarters sent a note of congratulations." },
			},
			{
				label = "Work it smarter: the right Agent on the right unit",
				hint = "An Intelligence check: the whole board, perfectly.",
				clash = { stat = "intelligence", foe = "Headquarters' quota", coins = 2, base = 6, coinPower = 3 },
				win = { paycheck = 0.2, sanity = 3, intelligence = 2, log = "You rebuilt the board so every Agent worked the unit that suited their Virtues best, and the PE-Boxes came out faster than they had in years. Quota filled. Nobody new on the wall." },
				lose = { sanity = -4, paycheck = -0.1, log = "It was a beautiful plan. One unit didn't read it. You missed the quota by a day and spent the next week explaining why." },
			},
			{
				label = "Argue with headquarters",
				hint = "A Charisma check.",
				clash = { stat = "charisma", foe = "The calm voice", coins = 3, base = 5, coinPower = 3 },
				win = { charisma = 2, sanity = 2, log = "You laid out the breach rates and the numbers until the calm voice said it would \"review the figure\". The new quota was lower. You'll never know what it cost to lower it." },
				lose = { sanity = { -6, -4 }, log = "\"Managers,\" the calm voice said, \"are chosen for their results.\" The quota stood. So did the implication." },
			},
		},
	},
	{
		id = "lc_mgr_hiring",
		title = "Hiring Day",
		text = "Your branch has a batch of LOB points to spend: on new Agents, or on raising the Virtues of the ones you already have. The hiring list has three rookies with Virtues of almost nothing, and one veteran from a branch that closed, who costs as much as the three together and won't say why the branch closed.",
		weight = 32,
		cooldown = 3,
		tags = { "lcorp" },
		when = MANAGER,
		codex = "lc_lore_agents",
		choices = {
			{
				label = "Hire the three rookies",
				result = { paycheck = 0.1, sanity = -2, log = "You hired three rookies. You assigned them ZAYINs and TETHs and checked on them every hour on the screens. Two made it to Level 2. You stopped checking on the third." },
			},
			{
				label = "Hire the veteran",
				result = { sanity = 2, mind = 1, setFlags = { "lc_mgr_veteran" }, log = "You hired the veteran. She worked the hard units without a word and never once talked about the branch she'd come from. Your breach rate fell by half." },
			},
			{
				label = "Spend it all on your own Agents' Virtues",
				result = { intelligence = 2, sanity = 1, log = "You spent every point on training the Agents you already had. Fewer hands on the board, but steadier ones. Your Captains approved. Headquarters didn't." },
			},
		},
	},
	{
		id = "lc_mgr_egg",
		title = "A New Egg",
		text = "Headquarters is sending your branch a new Abnormality, still in its egg. The paperwork grades it ALEPH. It would nearly double your branch's energy output, if your Agents can work it. The containment unit is ready. The paperwork is waiting for your signature, and the Information Team hasn't profiled it yet.",
		weight = 28,
		cooldown = 4,
		tags = { "lcorp" },
		when = MANAGER,
		codex = "lc_lore_risk_levels",
		choices = {
			{
				label = "Sign for it",
				result = { paycheck = 0.4, sanity = { -6, -3 }, setFlags = { "lc_mgr_aleph" }, log = "You signed. The egg arrived on a cart pulled by six Clerks who wouldn't look at it. Your output doubled within a month. So did your nightmares." },
			},
			{
				label = "Have the Information Team profile it first",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "An unknown egg", coins = 2, base = 5, coinPower = 3 },
				win = { paycheck = 0.25, mind = 2, log = "Yesod's team profiled it for a month before you let anyone near it. By the time you did, you knew which work it liked. Not one Agent was hurt learning it." },
				lose = { sanity = -4, health = -2, log = "The profiling went wrong on day three. The egg's unit was fine. The profiling team wasn't, quite." },
			},
			{
				label = "Refuse it",
				result = { mind = 2, sanity = 2, log = "You sent it back unopened. Headquarters noted your caution in a tone that made caution sound like a fault. Another branch took it. You heard what happened there." },
			},
		},
	},
	{
		id = "lc_mgr_claw",
		title = "The Midnight of White: The Claw",
		text = "Every screen in your control room goes white at once. On the one that comes back first, a figure in a long white coat is walking down your main corridor, and the doors are opening ahead of it without being asked. You know what it is from stories: the Claw, the Head's own enforcer. It stops under a camera and looks straight up into it. \"Where are the machines?\" it asks.",
		weight = 18,
		once = true,
		tags = { "lcorp", "ordeal" },
		when = MANAGER,
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Seal the departments and wait it out",
				hint = "A hard Mental Strength check: one hour, one door at a time.",
				clash = { stat = "mind", foe = "The Claw", coins = 3, base = 6, coinPower = 3 },
				win = { mind = 3, sanity = -3, setFlags = { "lc_claw_seen", "lc_breach_survivor" }, log = "You sealed every door in the order the emergency plan never imagined, and watched it walk your corridors for an hour, opening some. Then it left, as if it had found what it came for. Nobody has ever told you what that was." },
				lose = { health = { -14, -8 }, sanity = { -8, -5 }, setFlags = { "lc_claw_seen", "lc_breach_survivor" }, condition = "lc_shaken", log = "One door didn't seal. It came up the stairs to the control room and stood in the doorway, and looked at you, and then it left. You don't know why you're alive.", cause = "Met the Claw" },
			},
			{
				label = "Get everyone out through the lower tunnels",
				hint = "An Intelligence check.",
				clash = { stat = "intelligence", foe = "A hundred people and one hour", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 3, sanity = 2, setFlags = { "lc_claw_seen", "lc_breach_survivor" }, log = "You got your whole branch out through the tunnels while it walked the halls above. When you came back in the morning, nothing was broken, and something was missing from the bottom floor." },
				lose = { sanity = { -7, -4 }, health = -4, setFlags = { "lc_claw_seen", "lc_breach_survivor" }, log = "Most of them got out. Most." },
			},
			{
				label = "Go down and face it",
				hint = "A real fight against the Head's enforcer. Almost nobody survives this.",
				clash = { stat = "strength", foe = "The Claw", coins = 4, base = 8, coinPower = 4, fight = true, status = "poise" },
				win = { strength = 4, sanity = 4, addTrait = "lc_breach_hardened", setFlags = { "lc_claw_seen", "lc_breach_survivor", "lc_fought_claw" }, log = "You went down and stood in its way, and somehow, impossibly, it was the Claw that stepped back. It looked at you a long time. \"Noted,\" it said, and left. You will never tell anyone how." },
				lose = { die = "Stood in the Claw's way", log = "You went down to face it. The cameras show you standing in its path, and then they show the corridor empty." },
			},
		},
	},
	{
		id = "lc_mgr_wall",
		title = "Names on the Wall",
		text = "Every branch has a memorial wall, and as Manager you sign the order for every name that goes up on yours. This week there are three. One of them was a Clerk who should never have been on that floor; she was there because of the schedule you approved. The maintenance worker is waiting at the door with the order form.",
		weight = 24,
		cooldown = 4,
		tags = { "lcorp" },
		when = MANAGER,
		choices = {
			{
				label = "Sign it, and change the Clerk schedules",
				result = { intelligence = 2, sanity = -3, setFlags = { "lc_mgr_changed_rules" }, log = "You signed, and then you rewrote every Clerk's schedule in the branch so none of them would ever be on a containment floor again. Headquarters complained about the Clerk Benefits. You didn't change it back." },
			},
			{
				label = "Sign it and go back to work",
				result = { sanity = { -5, -3 }, mind = 1, log = "You signed it. You had a quota. The screens don't stop because someone is on the wall. You told yourself that until you believed it." },
			},
			{
				label = "Go down and put her name up yourself",
				result = { sanity = 2, health = -1, relationBond = { kind = "all", amount = 3 }, log = "You went down with the maintenance worker and held the ladder. The Clerks on that floor watched you do it. You'd forgotten how far down the lobby is from the control room." },
			},
		},
	},

	-- ── after the fall: the job ends ──
	{
		id = "lc_fall_catchup",
		title = "The Badge That Opens Nothing",
		text = "Lobotomy Corporation is gone. The tower is dark, the facility has sealed itself and sunk, and the badge on your green lanyard doesn't open anything anymore. For a while you kept going to the gate out of habit. Today there's no gate, only a hole full of rubble and a few others like you, standing in the rain.",
		weight = 900,
		once = true,
		tags = { "lcorp" },
		when = { career = { "lcorp_agent", "lcorp_research" }, world = { era = { "library", "limbus" } } },
		codex = "lcorp_fall",
		choices = {
			{
				label = "Take off the badge and look for other work",
				result = { quitCareer = true, sanity = -2, log = "You took off the badge and put it in a drawer. You still have it. Everyone who worked there still has theirs." },
			},
			{
				label = "Find the others who used to work there",
				result = { quitCareer = true, sanity = 2, setFlags = { "lc_remnant" }, log = "You found them at the Green Kettle, the teahouse where everyone used to go after a shift. Half the old regulars were there, with nothing to do but drink tea and remember the safety rules. You started going every week." },
			},
		},
	},
}
