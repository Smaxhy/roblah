--[[
	DELVES (v0.13): places found in the world, each with its own purpose and shape, told as
	cards in your feed (no menu). Found through their entrance cards (Entrances.luau), they then
	stay under Places you know on the DO tab.
	  purpose   exploration, survival, investigation, escort, salvage, negotiation, escape, compliance
	Lore: L Corp's branches and their posted work rules, Abnormality units and Qliphoth counters,
	the Training Team and Clerks (Lobotomy Corporation); the Night from 3:13 to 4:34; Hongyuan's
	rooms that follow a fortune (District 8); the Great Lake and its whalers (District 21); the
	Ring's exhibitions (presented Roblox-safe as eerie installations); Index Prescripts.
	Violence implied only (Roblox Moderate).
]]

return {
	order = { "dv_branch_laundromat", "dv_open_day", "dv_thirteenth_floor", "dv_escort_feather", "dv_lake_wreck", "dv_hongyuan_audit", "dv_ring_gallery", "dv_prescript" },

	-- ── an abandoned branch, run by its own posted rules ─────────────────────
	dv_branch_laundromat = {
		name = "The Branch Under the Laundromat",
		kind = "dungeon",
		purpose = "exploration",
		depthWord = "Depth",
		desc = "A forgotten branch of old L Corp under a twenty-four-hour laundromat. Its rules are still posted on the walls, and some of what they were written for is still down there.",
		minAge = 16,
		cooldown = 4,
		crew = { min = 1, max = 3 },
		length = 5,
		when = { world = { era = { "library", "limbus" } }, notDistrict = "d12" },
		start = "hatch",
		stages = {
			hatch = {
				title = "Behind the Dryers",
				text = "Behind the last row of dryers, a service hatch with an old L Corp plate screwed to it. The warm air from the machines stops at the hatch as if it's been told to. Below, a ladder, and a smell like a hospital that closed years ago.",
				choices = {
					{ label = "Climb down", next = "foyer", result = { log = "The ladder was cold. Every rung was dry. Somebody had kept this place dry for a long time." } },
					{ label = "Close the hatch and go home", ["end"] = "retreat", result = { log = "You put the hatch back and went home, and you dreamed of ladders." } },
				},
			},
			foyer = {
				title = "The Work Orders",
				text = "A small foyer, a dead clock, and on the wall a laminated sheet: WORK GUIDELINES, UNIT B-3. Half the lines have been scratched out by a fingernail. The ones that are left: 'If the lights flicker, do not look at the unit.' 'Never enter alone after a Clerk has screamed.' 'It likes to be thanked.'",
				choices = {
					{ label = "Learn the rules by heart", hint = "An Intelligence check.", clash = { stat = "intelligence", foe = "A half-scratched sheet", coins = 2, base = 3, coinPower = 2 },
						win = { setFlags = { "dv_rule_lights", "dv_rule_thanks" }, log = "You read it until you could say it with your eyes shut." }, lose = { setFlags = { "dv_rule_lights" }, log = "You got the first rule. The rest blurred." }, next = "records" },
					{ label = "Skip the sheet", next = "records", result = { log = "Rules were for the people who used to work here." } },
				},
			},
			records = {
				title = "The Manager's Desk",
				text = "An office with the door off its hinges. The manager's log is open on the desk at the last page. The handwriting gets larger as it goes. Under the desk, a locked drawer marked LOCKER CODES.",
				choices = {
					{ label = "Read the last page of the log", result = { sanity = -2, mind = 1, codex = "lc_lore_branches", log = "\"Day 41. The lights keep flickering. Nobody looks anymore. That's how we've lived this long.\"" }, next = "hall" },
					{ label = "Force the drawer", hint = "A Strength check.", clash = { stat = "strength", foe = "A drawer that was built to stay shut", coins = 2, base = 4, coinPower = 3 },
						win = { setFlags = { "dv_locker_code" }, log = "The drawer gave. Inside: a card with six numbers and a smiley face drawn by someone very tired." }, lose = { health = { -4, -2 }, log = "The drawer held. Your wrist didn't." }, next = "hall" },
				},
			},
			hall = {
				title = "Unit B-3",
				text = "The containment corridor. One board is still lit: UNIT B-3, QLIPHOTH COUNTER 2. As you pass, the lights flicker, off, on, off. Something behind the door shifts its weight toward the glass.",
				tone = "danger",
				choices = {
					{ label = "Do not look at the unit", hint = "You know the rule.", requires = { flags = { "dv_rule_lights" } }, next = "locker", result = { sanity = 2, log = "You kept your eyes on your boots. The lights came back. The counter still read 2." } },
					{ label = "Thank it, out loud", hint = "You read that it likes to be thanked.", requires = { flags = { "dv_rule_thanks" } }, next = "locker", result = { sanity = 3, luck = 1, log = "\"Thank you,\" you said, to a door. The counter ticked up to 3. Something behind the glass seemed pleased." } },
					{ label = "Look", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "What's behind the glass", coins = 3, base = 5, coinPower = 3 },
						win = { sanity = -3, setFlags = { "saw_abnormality" }, log = "You looked. You wish you hadn't. You kept walking." }, lose = { sanity = -8, setFlags = { "saw_abnormality" }, log = "You looked, and the counter clicked to 0." }, winNext = "locker", loseNext = "breach" },
				},
			},
			breach = {
				title = "The Counter at Zero",
				text = "The unit door slides open on its own, politely. What comes out was never meant to be out, and it has been alone a very long time.",
				tone = "danger",
				choices = {
					{ label = "Fight your way to the stairs", clash = { stat = "strength", foe = "A forgotten Abnormality", enemy = "abnormality", coins = 3, base = 6, coinPower = 3, fight = true, status = "rupture" },
						win = { renown = 8, log = "You drove it back into the dark and didn't stop running until the dryers." }, lose = { health = { -20, -10 }, cause = "Lost in a forgotten L Corp branch", log = "You got out. Not all of you got out the same." }, winNext = "locker", loseEnd = "fail" },
					{ label = "Run for the ladder", hint = "A Speed check.", clash = { stat = "speed", foe = "Something that never needed to run", coins = 3, base = 5, coinPower = 3 },
						win = { log = "You made the ladder and the hatch and the street, and the laundromat was full of people folding shirts." }, lose = { health = { -12, -6 }, log = "It caught your coat. You left the coat." }, ["end"] = "retreat" },
				},
			},
			locker = {
				title = "The E.G.O Locker",
				text = "At the end of the corridor, the safety team's locker room. One locker has a keypad, still glowing. Through the vents you can see a suit hanging inside: E.G.O, the kind an Agent wore to walk into a unit and come back out.",
				choices = {
					{ label = "Punch in the code", hint = "You found the codes.", requires = { flags = { "dv_locker_code" } }, ["end"] = "success", result = { gear = "dv_branch_ego_suit", sanity = 2, log = "The keypad chimed. The suit was cold and fit you like it had been waiting." } },
					{ label = "Pry it open", hint = "A Strength check.", clash = { stat = "strength", foe = "An L Corp locker", coins = 3, base = 5, coinPower = 3 },
						win = { gear = "dv_branch_badge", log = "The suit had rotted on its hanger. The badge clipped to it hadn't." }, lose = { health = { -5, -2 }, log = "The locker won. You took the stairs back up empty-handed." }, ["end"] = "success" },
				},
			},
		},
		success = { renown = 10, setFlags = { "dv_branch_done" }, log = "You climbed out behind the dryers. Nobody in the laundromat looked up." },
		fail = { sanity = -4, log = "You came up through the hatch at dawn and sat on the curb for a long time." },
		retreat = { sanity = -1, log = "Some branches are better left sealed." },
	},

	-- ── a recruitment day that goes wrong (the age of L Corp) ────────────────
	dv_open_day = {
		name = "Recruitment Day at the Facility",
		kind = "containment",
		purpose = "survival",
		depthWord = "Hour",
		desc = "Lobotomy Corporation is hiring. A day in District 12 with the Training Team: the lobby, the briefing, a window into a containment unit, and whatever happens when the alarms go.",
		minAge = 16,
		maxAge = 34,
		cooldown = 99,
		crew = { min = 1, max = 3 },
		length = 5,
		when = { world = { era = "wings" }, notFlags = { "lcorp_employee" } },
		start = "lobby",
		stages = {
			lobby = {
				title = "The Lobby",
				text = "A white lobby the size of a station, and a queue of applicants holding their papers like shields. A woman from the Training Team hands out visitor badges. Over the doors: FACE THE FEAR, BUILD THE FUTURE.",
				choices = {
					{ label = "Introduce yourself properly", hint = "A Charisma check.", clash = { stat = "charisma", foe = "A tired Training Team officer", coins = 2, base = 3, coinPower = 2 },
						win = { setFlags = { "dv_open_noticed" }, log = "She wrote your name on her clipboard and underlined it." }, lose = { log = "She nodded at you the way she'd nodded at three hundred people." }, next = "briefing" },
					{ label = "Stand at the back and watch", next = "briefing", result = { mind = 1, log = "You watched who was nervous, and who was pretending not to be." } },
				},
			},
			briefing = {
				title = "The Briefing",
				text = "A lecture hall. The Training Team's slides: risk levels from ZAYIN to ALEPH, the four kinds of work, and why you always, always read a unit's guidelines before you go in. A man in the front row asks what happens if you don't. The officer clicks to the next slide.",
				choices = {
					{ label = "Take careful notes", hint = "An Intelligence check.", clash = { stat = "intelligence", foe = "A very fast lecture", coins = 2, base = 4, coinPower = 3 },
						win = { setFlags = { "dv_open_notes" }, intelligence = 1, log = "You filled six pages. One line you underlined twice: 'Clerks evacuate. Agents suppress. Everyone else hides.'" }, lose = { log = "The slides went past faster than your pen." }, next = "window" },
					{ label = "Ask the question everyone's thinking", next = "window", result = { charisma = 1, log = "\"What's the survival rate?\" you asked. The officer smiled. \"Higher than in the Backstreets.\" Nobody laughed." } },
				},
			},
			window = {
				title = "The Observation Window",
				text = "The tour stops at a pane of thick glass. Behind it, a containment unit, and something sitting very still in the middle of the room. A Clerk explains that it's a TETH, mostly harmless if you follow its rules. It turns its head and looks at the glass. At you.",
				tone = "danger",
				choices = {
					{ label = "Hold its gaze", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "Something looking back", coins = 2, base = 4, coinPower = 3 },
						win = { setFlags = { "saw_abnormality" }, mind = 2, log = "You held it until it looked away first. The Clerk made a note." }, lose = { sanity = -5, setFlags = { "saw_abnormality" }, log = "You looked away first. It kept looking for the rest of the tour, through the walls." }, next = "alarm" },
					{ label = "Look at the floor like the sign says", next = "alarm", result = { sanity = 1, log = "There was a sign. You read signs. That's going to matter." } },
				},
			},
			alarm = {
				title = "The Alarm",
				text = "The lights turn red. A calm voice from the speakers: a containment breach on this floor, all visitors to the shelter. The Clerks start running in the wrong direction, toward the noise, to help. An Agent in a black suit pushes past you the other way.",
				tone = "danger",
				choices = {
					{ label = "Get the other applicants to the shelter", hint = "A Charisma check.", clash = { stat = "charisma", foe = "Thirty people panicking", coins = 3, base = 5, coinPower = 3 },
						win = { renown = 6, setFlags = { "dv_open_hero" }, log = "You got them moving, then running, then through the shelter door, and you counted them twice." }, lose = { sanity = -4, log = "You got most of them. Most is a word you'll think about." }, next = "debrief" },
					{ label = "Follow the Agent and help", hint = "A real fight.", clash = { stat = "strength", foe = "A breached TETH", enemy = "abnormality", coins = 3, base = 5, coinPower = 3, fight = true, status = "bleed" },
						win = { renown = 10, setFlags = { "dv_open_hero", "saw_abnormality" }, strength = 1, log = "The Agent looked at you, at your visitor badge, and back at you. \"Not bad,\" she said." }, lose = { health = { -18, -8 }, cause = "Caught in a breach on recruitment day", log = "The Agent dragged you out by the collar." }, next = "debrief" },
					{ label = "Hide, the way the slide said", hint = "You took notes.", requires = { flags = { "dv_open_notes" } }, next = "debrief", result = { sanity = 2, log = "You hid. It passed. That's what the slide said would happen, and it did." } },
				},
			},
			debrief = {
				title = "The Debrief",
				text = "Afterward, the Training Team officer finds you in the shelter, clipboard in hand. Her hair is a mess. She looks at the list, at you, and back at the list.",
				choices = {
					{ label = "Ask about the job", ["end"] = "success", result = { setFlags = { "lc_open_day_offer" }, rep = { lcorp = 8 }, log = "\"Come back next week,\" she said. \"Bring this.\" She signed the back of your visitor badge." } },
					{ label = "Say you've seen enough", ["end"] = "success", result = { sanity = 2, log = "\"That's the right answer for most people,\" she said, and she meant it kindly." } },
				},
			},
		},
		success = { gear = "dv_visitor_badge", log = "You walked out of the facility with a visitor badge you never handed back." },
		fail = { sanity = -4, log = "They walked you out of the facility early, with a pamphlet and a look you didn't like." },
		retreat = { log = "You slipped out through the visitors' gate before anyone could ask your name." },
	},

	-- ── the floor that isn't there ───────────────────────────────────────────
	dv_thirteenth_floor = {
		name = "The Thirteenth Floor",
		kind = "dungeon",
		purpose = "investigation",
		depthWord = "Floor",
		desc = "A tenement with twelve floors, and a lift that stops at thirteen. A tenant who went up last month hasn't come down.",
		minAge = 14,
		cooldown = 99,
		crew = { min = 1, max = 3 },
		length = 5,
		when = {},
		start = "lift",
		stages = {
			lift = {
				title = "The Lift",
				text = "The lift has buttons for one to twelve. Someone has drawn a thirteenth on the wall in pencil. You press it with your thumb, and the lift, after a long, thinking pause, goes up.",
				choices = {
					{ label = "Count the floors as you rise", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "A count that keeps slipping", coins = 2, base = 4, coinPower = 3 },
						win = { setFlags = { "dv13_counted" }, log = "Eleven. Twelve. Twelve. Thirteen. You kept count. The count kept you." }, lose = { sanity = -3, log = "You lost count at nine, and again at nine." }, next = "corridor" },
					{ label = "Close your eyes until it stops", next = "corridor", result = { log = "It stopped. You opened them." } },
				},
			},
			corridor = {
				title = "Thirteen",
				text = "A corridor exactly like every other floor's, except the doors are numbered 1301, 1301, 1301. A radio is playing behind one of them: a weather report for a day that already happened. On the floor, a trail of chalk arrows, drawn by somebody who wanted to be found.",
				choices = {
					{ label = "Follow the chalk arrows", next = "room", result = { log = "The arrows went round a corner the corridor didn't have." } },
					{ label = "Knock on the door with the radio", hint = "A Charisma check.", clash = { stat = "charisma", foe = "Whoever is listening to the weather", coins = 2, base = 5, coinPower = 3 },
						win = { setFlags = { "dv13_radio" }, log = "A voice said the date through the door. It was last month's. \"Tell them I'm fine,\" it said. \"Tell them I'm nearly done.\"" }, lose = { sanity = -4, log = "The radio stopped. Everything stopped. Then it started again, from the beginning." }, next = "room" },
				},
			},
			room = {
				title = "Your Own Front Door",
				text = "At the end of the arrows: a door that is exactly your front door, scuff marks and all. Through the keyhole you can see your own kitchen, and somebody sitting at your table, eating your soup. They wave at the keyhole.",
				tone = "danger",
				choices = {
					{ label = "Don't go in. Keep looking for the tenant", next = "tenant", result = { sanity = 2, log = "It wasn't your door. It wasn't your soup. You kept saying that until you believed it." } },
					{ label = "Go in", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "A kitchen that is almost yours", coins = 3, base = 6, coinPower = 3 },
						win = { setFlags = { "dv13_kitchen" }, mind = 2, log = "You went in, sat down across from them, and said, \"This isn't yours.\" They looked hurt, and then they weren't there." }, lose = { sanity = -9, log = "You sat down and had some soup. It was very good. You don't remember leaving." }, next = "tenant" },
				},
			},
			tenant = {
				title = "The Missing Tenant",
				text = "You find the tenant in a stairwell that goes only up: a woman in a dressing gown, sitting on the steps with a notebook, counting. She's been counting the stairs for a month. She's nearly at the end, she says.",
				choices = {
					{ label = "Bring her back down with you", hint = "A Charisma check.", clash = { stat = "charisma", foe = "A count that isn't finished", coins = 2, base = 5, coinPower = 3 },
						win = { setFlags = { "dv13_rescued" }, meet = "the tenant you brought down from the thirteenth floor", log = "She closed the notebook. \"I'll finish it another time,\" she said, and took your hand on the stairs." }, lose = { sanity = -3, log = "She wouldn't come. She gave you the notebook instead." }, next = "exit" },
					{ label = "Help her finish the count", hint = "An Intelligence check.", clash = { stat = "intelligence", foe = "Stairs that go up forever", coins = 3, base = 5, coinPower = 3 },
						win = { setFlags = { "dv13_rescued", "dv13_count_done" }, meet = "the tenant who finished counting the stairs", luck = 1, log = "The count came out even. The stairwell sighed and was an ordinary stairwell, and you were on the twelfth floor." }, lose = { sanity = -6, log = "The count came out odd. It always comes out odd." }, next = "exit" },
				},
			},
			exit = {
				title = "Down",
				text = "The lift is waiting with its doors open, patient as a dog. The pencilled 13 on the wall has been rubbed out.",
				choices = {
					{ label = "Press 1 and don't look back", ["end"] = "success", result = { log = "The lift went down. It went down for a long time. Then it was the ground floor, and the radio was playing today's weather." } },
					{ label = "Press 13 again", hint = "Something to keep?", requires = { flags = { "dv13_counted" } }, ["end"] = "success", result = { gear = "dv_thirteen_key", sanity = -2, log = "The lift went up again, and then didn't. A key was in the button panel where the thirteen had been. You took it." } },
				},
			},
		},
		success = { renown = 6, setFlags = { "dv13_done" }, log = "The building has twelve floors. Everyone says so." },
		fail = { sanity = -6, log = "The lift let you out on the ground floor, eventually. You took the stairs for a year." },
		retreat = { sanity = -1, log = "You pressed the button for the lobby and kept your eyes on the numbers all the way down." },
	},

	-- ── an escort against the clock ──────────────────────────────────────────
	dv_escort_feather = {
		name = "A Feather, Lost at Night",
		kind = "mission",
		purpose = "escort",
		depthWord = "Street",
		desc = "A Feather from the Nest has got lost in the Backstreets at two in the morning and is offering a great deal of money to be walked back to the wall before 3:13.",
		minAge = 18,
		cooldown = 3,
		crew = { min = 1, max = 3 },
		length = 4,
		when = { side = "backstreets" },
		start = "client",
		stages = {
			client = {
				title = "The Client",
				text = "He's in a coat that costs more than your building, standing under a dead streetlight with a map upside down. \"I'll pay double,\" he says, before you've said anything. It's 2:06. The wall is forty minutes away, if nothing goes wrong.",
				choices = {
					{ label = "The canal path: fast, and dark", hint = "A Speed check.", clash = { stat = "speed", foe = "The canal path at night", coins = 2, base = 4, coinPower = 3 },
						win = { setFlags = { "dve_fast" }, log = "You made good time. He complained about his shoes the whole way." }, lose = { health = { -5, -2 }, log = "He slipped. You caught him. The canal caught your hat." }, next = "stall" },
					{ label = "Through the market: slow, and lit", next = "stall", result = { log = "Slower, but lit. He bought a skewer from every stall still open." } },
				},
			},
			stall = {
				title = "Noodles at 2:31",
				text = "He stops dead in front of a noodle stall that's packing up. He has never had Backstreets noodles. He would like some. Now. It is 2:31.",
				choices = {
					{ label = "Buy him a bowl, fast", next = "toll", result = { money = -10, charisma = 1, log = "He ate it in four minutes and said it was the best thing he had ever tasted. He was probably right." } },
					{ label = "Tell him the Night doesn't wait for noodles", hint = "A Charisma check.", clash = { stat = "charisma", foe = "A man who has never been told no", coins = 2, base = 5, coinPower = 3 },
						win = { setFlags = { "dve_fast" }, log = "He sulked, but he walked." }, lose = { log = "He ate the noodles anyway. You stood there counting minutes." }, next = "toll" },
				},
			},
			toll = {
				title = "The Toll",
				text = "Three Rats have strung a chain across the alley to the wall. \"Toll,\" says the biggest one, looking at the coat. It's 2:52.",
				tone = "danger",
				choices = {
					{ label = "Pay the toll out of the fee", next = "wall", result = { money = -40, log = "They took the money and the coat's buttons." } },
					{ label = "Clear the alley", clash = { stat = "strength", foe = "Three Rats with a chain", enemy = "rat", coins = 3, base = 4, coinPower = 3, fight = true, status = "bleed" },
						win = { renown = 4, log = "The chain went in the canal, and the Rats after it." }, lose = { health = { -12, -6 }, log = "You got him through. You left some skin on the chain." }, next = "wall" },
					{ label = "Take the rooftops instead", hint = "A Speed check.", clash = { stat = "speed", foe = "Wet rooftops", coins = 3, base = 5, coinPower = 3 },
						win = { setFlags = { "dve_fast" }, log = "You hauled him over three roofs and down a drainpipe. He'll tell that story at every dinner for a year." }, lose = { health = { -8, -4 }, log = "The drainpipe came off the wall. So did you." }, next = "wall" },
				},
			},
			wall = {
				title = "The Wall at 3:09",
				text = "The Nest's gate, white and lit, and a guard who doesn't open for anyone after three. It's 3:09. The Feather is out of breath and very, very grateful.",
				choices = {
					{ label = "Talk the guard into opening", hint = "A Charisma check.", clash = { stat = "charisma", foe = "A Wing's gate guard", coins = 2, base = 5, coinPower = 3 },
						win = { rep = { wings = 6 }, gear = "dv_feather_pin", log = "The gate opened a crack. The Feather pressed his pin into your hand as he went through. \"Come and see me,\" he said. You won't, but it was nice." }, lose = { sanity = -3, log = "The guard wouldn't. You got him into a stairwell with a lock and waited out the Night together." }, ["end"] = "success" },
					{ label = "Get him inside anywhere, fast", ["end"] = "success", result = { sanity = -2, log = "A doorway, a lock, two strangers breathing in the dark until 4:34." } },
				},
			},
		},
		success = { wage = { 300, 600 }, renown = 5, log = "He paid in the morning, double, as promised, in an envelope that smelled of the Nest." },
		fail = { sanity = -5, log = "It was 3:13. You were outdoors." },
		retreat = { log = "You turned back before the Night started. Someone else will have to get the Feather home." },
	},

	-- ── salvage on the Great Lake ────────────────────────────────────────────
	dv_lake_wreck = {
		name = "A Wreck in the Fog",
		kind = "trip",
		purpose = "salvage",
		depthWord = "Fathom",
		desc = "A Portship tender went down in the fog off the fish market, and every salvage crew on the Great Lake knows what it was carrying. You know a fisherman with a diving bell.",
		minAge = 18,
		cooldown = 3,
		crew = { min = 1, max = 4 },
		length = 4,
		when = { district = "d21" },
		start = "boat",
		stages = {
			boat = {
				title = "The Fog",
				text = "The fisherman's boat noses out into fog so thick the bow vanishes. He steers by the sound of the buoys and the smell of the water. Somewhere out there, other engines: whalers, also listening.",
				choices = {
					{ label = "Read the water with him", hint = "An Intelligence check.", clash = { stat = "intelligence", foe = "Fog and current", coins = 2, base = 4, coinPower = 3 },
						win = { setFlags = { "dvl_first" }, log = "You found the oil slick before anyone else did." }, lose = { log = "You went round in a circle twice. The whalers didn't." }, next = "bell" },
					{ label = "Kill the engine and listen", next = "bell", result = { luck = 1, log = "In the silence you heard the wreck's bell, ringing on the bottom with the current." } },
				},
			},
			bell = {
				title = "The Diving Bell",
				text = "The diving bell is a brass pot with a window and a hose. Inside it smells of rust and somebody's lunch. The fisherman cranks you down into green dark, and the wreck comes up out of the murk to meet you: a white hull on its side, its hatch open.",
				tone = "danger",
				choices = {
					{ label = "Go into the hold", hint = "A Health check: the cold and the pressure.", clash = { stat = "health", foe = "Cold water and a long hose", coins = 3, base = 5, coinPower = 3 },
						win = { setFlags = { "dvl_hold" }, log = "The hold was full of crates sealed in wax. You took the one with the Portship's crest." }, lose = { health = { -10, -5 }, log = "The cold got into your bones before you got into the hold." }, next = "whalers" },
					{ label = "Search the cabin instead", hint = "A Luck check.", clash = { stat = "luck", foe = "Whatever the cabin kept", coins = 2, base = 4, coinPower = 3 },
						win = { money = { 150, 400 }, log = "The captain's strongbox, still locked, still heavy." }, lose = { log = "Somebody had got to the cabin first, years ago." }, next = "whalers" },
				},
			},
			whalers = {
				title = "The Whalers",
				text = "When you come up, a whaling boat is alongside, harpoons out, crew grinning. \"Salvage law,\" their captain says, \"is whoever's biggest.\"",
				tone = "danger",
				choices = {
					{ label = "Hand over half and keep the peace", next = "below", result = { money = -60, log = "They took half, and a fish, and left laughing." } },
					{ label = "Fight for it", clash = { stat = "strength", foe = "A whaling crew", enemy = "whaler", coins = 3, base = 5, coinPower = 3, fight = true, status = "bleed" },
						win = { renown = 6, log = "Their captain went in the lake. His crew went in after him, to fetch him." }, lose = { health = { -14, -7 }, money = -80, log = "They took everything and left you the fog." }, next = "below" },
					{ label = "Bluff: say it's Portship property", hint = "A Charisma check.", clash = { stat = "charisma", foe = "A suspicious whaler", coins = 2, base = 5, coinPower = 3 },
						win = { log = "\"Portship?\" The captain spat, and turned his boat away. Nobody on the Lake wants that trouble." }, lose = { sanity = -2, money = -40, log = "He didn't believe you, but he only took a little." }, next = "below" },
				},
			},
			below = {
				title = "Something Below",
				text = "As you start for shore, the fisherman goes quiet and points at the water. Something long is passing under the boat, slowly, for a very long time.",
				tone = "danger",
				choices = {
					{ label = "Stay perfectly still", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "Something passing under", coins = 3, base = 5, coinPower = 3 },
						win = { mind = 2, log = "It passed. You didn't breathe for a minute. The fisherman crossed himself in a way you'd never seen." }, lose = { sanity = -6, log = "You moved. It noticed. It decided you weren't worth it, and that was worse." }, ["end"] = "success" },
					{ label = "Gun the engine for shore", hint = "A Speed check.", clash = { stat = "speed", foe = "A wake that isn't yours", coins = 3, base = 6, coinPower = 3 },
						win = { log = "You beat it to the pier. Probably it wasn't racing." }, lose = { health = { -10, -4 }, log = "The wake swamped the boat. You swam the last of it." }, ["end"] = "success" },
				},
			},
		},
		success = { wage = { 200, 500 }, gear = "dv_lake_harpoon", setFlags = { "dvl_done" }, log = "The crate held a Portship harpoon, oiled and perfect. The fisherman wouldn't take a share. \"Bad luck,\" he said, and wouldn't say more." },
		fail = { sanity = -4, log = "The Lake kept the wreck, and nearly kept you. You came ashore cold to the bone." },
		retreat = { log = "You rowed back while the water was still calm. The wreck can wait for someone braver." },
	},

	-- ── a fight won by argument (District 8) ─────────────────────────────────
	dv_hongyuan_audit = {
		name = "The Room Audit",
		kind = "mission",
		purpose = "negotiation",
		depthWord = "Corridor",
		desc = "In Hongyuan a room follows its owner's fortune. A steward has come to measure yours, and your family's room is about to get smaller unless someone argues it bigger.",
		minAge = 16,
		cooldown = 5,
		crew = { min = 1, max = 2 },
		length = 4,
		when = { district = "d8" },
		start = "summons",
		stages = {
			summons = {
				title = "The Summons",
				text = "A steward's card under the door: an appointment, today, at an office somewhere in Hongyuan. The corridors to it shift while you walk them, the way they do when a family's fortune is under review.",
				choices = {
					{ label = "Learn the corridors' habits", hint = "An Intelligence check.", clash = { stat = "intelligence", foe = "Corridors that move", coins = 2, base = 4, coinPower = 3 },
						win = { setFlags = { "dvh_early" }, log = "You arrived early, which in Hongyuan is a kind of argument in itself." }, lose = { log = "You arrived late and out of breath, which is also an argument, a bad one." }, next = "steward" },
					{ label = "Bring the family's ledgers", next = "steward", result = { setFlags = { "dvh_ledgers" }, log = "Three ledgers, tied with string, under your arm." } },
				},
			},
			steward = {
				title = "The Steward",
				text = "A narrow man behind a desk that grows as he talks. \"Your family's worth has fallen,\" he says. \"The room will be adjusted.\" He picks up a pen made of something that used to be alive.",
				choices = {
					{ label = "Argue from the ledgers", hint = "You brought them.", requires = { flags = { "dvh_ledgers" } }, next = "counter", result = { intelligence = 1, log = "You read him three years of your family's work, line by line, until he put the pen down." } },
					{ label = "Argue from who your family knows", hint = "A Charisma check.", clash = { stat = "charisma", foe = "A steward who has heard everything", coins = 3, base = 5, coinPower = 3 },
						win = { log = "You mentioned a name. He paused, and the desk stopped growing." }, lose = { sanity = -3, log = "He wrote something down. The room behind you got a little darker." }, next = "counter" },
				},
			},
			counter = {
				title = "The Counteroffer",
				text = "\"A compromise,\" the steward says. \"The room stays. In exchange, a member of your family serves a year in the steward's office.\" He looks at you, specifically.",
				choices = {
					{ label = "Refuse, and hold your ground", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "A very patient man", coins = 3, base = 6, coinPower = 3 },
						win = { setFlags = { "dvh_won" }, log = "You said no, and kept saying it, and at the end he smiled as if you'd passed something." }, lose = { sanity = -4, money = -100, log = "He wore you down. The fee was smaller than the room, at least." }, ["end"] = "success" },
					{ label = "Pay instead", hint = "250 Ahn.", requires = { min = { money = 250 } }, ["end"] = "success", result = { money = -250, log = "Money talks in Hongyuan. It talked." } },
				},
			},
		},
		success = { sanity = 4, rep = { wings = 3 }, gear = "dv_steward_seal", log = "When you got home the room was bigger by a window. Your family stood in front of it for an hour." },
		fail = { sanity = -4, log = "The audit found you, instead of the other way round. You left Hongyuan with fewer friends." },
		retreat = { log = "You closed the ledgers and went home before anyone noticed they had been opened." },
	},

	-- ── an exhibition you are invited to (the Ring) ──────────────────────────
	dv_ring_gallery = {
		name = "The Exhibition",
		kind = "dungeon",
		purpose = "escape",
		depthWord = "Room",
		desc = "A gilt invitation from the Ring, with your name in a beautiful hand. Nobody turns down the Ring. The trick is leaving.",
		minAge = 18,
		cooldown = 99,
		crew = { min = 1, max = 2 },
		length = 5,
		when = { flags = { "knows_ring" } },
		start = "hall",
		stages = {
			hall = {
				title = "The First Room",
				text = "A white gallery, silent, and guests in masks drifting from piece to piece. The first installation is a room full of stopped clocks, every one at a different time. A Docent in a long coat watches you look at it, notebook open.",
				choices = {
					{ label = "Look properly, and say what you see", hint = "An Intelligence check.", clash = { stat = "intelligence", foe = "A Docent's attention", coins = 2, base = 5, coinPower = 3 },
						win = { setFlags = { "dvr_seen" }, log = "\"Every clock stopped when someone left,\" you said. The Docent wrote it down, pleased." }, lose = { sanity = -3, log = "You said it was nice. The Docent's pen stopped." }, next = "dolls" },
					{ label = "Keep moving, eyes down", next = "dolls", result = { log = "You moved like a guest who belonged. Mostly." } },
				},
			},
			dolls = {
				title = "The Second Room",
				text = "A room of mannequins dressed as people you almost recognise: a neighbour, a teacher, someone from the noodle stall. One of them is wearing your coat. The exit sign over the far door is lit, then it isn't.",
				tone = "danger",
				choices = {
					{ label = "Walk through without touching anything", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "Faces you almost know", coins = 3, base = 5, coinPower = 3 },
						win = { log = "You made it through without touching a sleeve." }, lose = { sanity = -7, log = "You touched the one in your coat. It was warm." }, next = "artist" },
					{ label = "Take your coat back off the mannequin", next = "artist", result = { setFlags = { "dvr_coat" }, sanity = -2, log = "You took it back. Something in the room noticed it was missing a piece." } },
				},
			},
			artist = {
				title = "The Artist",
				text = "In the third room the artist is working. They look up from a canvas and their whole face lights up. \"You,\" they say. \"You have exactly the right silhouette.\" Behind them, the only door out.",
				tone = "danger",
				choices = {
					{ label = "Flatter the work and back toward the door", hint = "A Charisma check.", clash = { stat = "charisma", foe = "An artist's interest", coins = 3, base = 6, coinPower = 3 },
						win = { setFlags = { "dvr_out" }, log = "You talked about their use of negative space until you were standing in it, at the door." }, lose = { sanity = -4, log = "They wanted to show you the next room. They insisted." }, winEnd = "success", loseNext = "back" },
					{ label = "Run for the door", clash = { stat = "speed", foe = "An artist who doesn't like to be left", enemy = "ring_artist", coins = 3, base = 6, coinPower = 3, fight = true, status = "bleed" },
						win = { renown = 8, log = "You were through the door before the brush hit the floor." }, lose = { health = { -16, -8 }, cause = "Didn't leave the Ring's exhibition", log = "The door was further than it looked." }, winEnd = "success", loseNext = "back" },
				},
			},
			back = {
				title = "The Back Room",
				text = "The back room is where finished pieces wait to be hung. There are a great many of them. There's a service door, and a frame with nothing in it, exactly your size.",
				tone = "danger",
				choices = {
					{ label = "Take the empty frame and go out the service door", ["end"] = "success", result = { gear = "dv_empty_frame", sanity = -4, log = "You took the frame so nobody could put anything in it. Outside it was raining, and you have never been so glad of rain." } },
					{ label = "Break the frame first", hint = "A Strength check.", clash = { stat = "strength", foe = "A very good frame", coins = 2, base = 5, coinPower = 3 },
						win = { renown = 6, log = "The frame broke. Somewhere in the building, someone screamed at the loss of it." }, lose = { health = { -6, -3 }, log = "The frame held. You left it there, empty, and that will have to do." }, ["end"] = "success" },
				},
			},
		},
		success = { renown = 10, rep = { ring = -6 }, setFlags = { "dvr_done" }, log = "You walked out of the Ring's exhibition. Not many people can say it." },
		fail = { sanity = -8, log = "You got out of the gallery with paint on your hands that wasn't there when you went in." },
		retreat = { log = "You walked out of the gallery without looking at the last room. Good." },
	},

	-- ── a Prescript, carried out to the letter (the Index) ───────────────────
	dv_prescript = {
		name = "A Prescript in Your Mailbox",
		kind = "mission",
		purpose = "compliance",
		depthWord = "Instruction",
		desc = "A letter in your mailbox, sealed, unsigned, and very precise. The Index's Prescripts are to be carried out exactly. The Index does not say what happens if they aren't.",
		minAge = 16,
		cooldown = 6,
		crew = { min = 1, max = 1 },
		length = 4,
		when = { flags = { "knows_index" } },
		start = "letter",
		stages = {
			letter = {
				title = "The Letter",
				text = "'At 2:00 in the afternoon, carry a black umbrella to the third bench of the square in your District. It will not be raining. Wait for a man without a hat. Give him the umbrella. Do not speak. Walk home by the long way.'",
				choices = {
					{ label = "Do exactly as it says", next = "bench", result = { setFlags = { "dvp_obedient" }, log = "You bought a black umbrella. It was not raining. You carried it anyway." } },
					{ label = "Ignore it", ["end"] = "retreat", result = { sanity = -3, rep = { index = -6 }, log = "You threw the letter away. You kept seeing the envelope in the bin for days." } },
				},
			},
			bench = {
				title = "The Third Bench",
				text = "2:00. The square, the third bench, and a man sitting on it who is wearing a hat. He's waiting for someone. He looks at your umbrella with great interest.",
				choices = {
					{ label = "Keep waiting for a man without a hat", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "The wrong man, waiting", coins = 2, base = 5, coinPower = 3 },
						win = { setFlags = { "dvp_exact" }, log = "You waited. At 2:40 the man with the hat left, and a man without one sat down." }, lose = { sanity = -3, log = "You almost handed it to him. You caught yourself, barely." }, next = "silence" },
					{ label = "Give the umbrella to the man with the hat", ["end"] = "fail", result = { log = "He took it, smiled, and opened it, though it wasn't raining." } },
				},
			},
			silence = {
				title = "Do Not Speak",
				text = "The man without a hat takes the umbrella and asks you, very politely, what time it is. He waits for an answer. Everyone on the square seems to be waiting for one.",
				tone = "danger",
				choices = {
					{ label = "Say nothing", hint = "A Mental Strength check.", clash = { stat = "mind", foe = "A question, asked nicely", coins = 3, base = 5, coinPower = 3 },
						win = { setFlags = { "dvp_silent" }, log = "You said nothing. He nodded as if you'd answered, and left with the umbrella." }, lose = { sanity = -5, log = "\"Twenty to three,\" you said, before you could stop yourself. He wrote it down." }, winNext = "home", loseEnd = "fail" },
				},
			},
			home = {
				title = "The Long Way Home",
				text = "The long way home goes past a noodle stall your friend runs. They wave you over. Your feet are tired. The short way is right there.",
				choices = {
					{ label = "Take the long way, all of it", ["end"] = "success", result = { log = "You took the long way. It was three hours. The Index, somewhere, made a mark in a book." } },
					{ label = "Stop for noodles", ["end"] = "fail", result = { sanity = 2, log = "The noodles were very good. You didn't think about the letter until the next one came." } },
				},
			},
		},
		success = { rep = { index = 14 }, renown = 6, gear = "dv_black_umbrella", log = "A week later, a second envelope: no instructions, only a black umbrella, very fine, and a card that said 'Correct.'" },
		fail = { rep = { index = -10 }, sanity = -4, condition = "dz_hunted", log = "A week later, a second envelope. You haven't opened it." },
		retreat = { log = "You put the card back in its envelope and the envelope in a drawer, and didn't follow it." },
	},
}
