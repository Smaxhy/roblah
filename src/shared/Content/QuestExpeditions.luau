--[[
	Expeditions that side quests send you on (gated by a quest flag in `when`).
	Same format as Content/Expeditions.luau: { order = { ids }, [id] = def }.
]]

return {
	order = {
		"cannery_pilings",
		"old_salt_road", -- Old Chalk (crew of 2+)
		"below_hundredth_step", -- The Hundredth Step
		"old_sister_dive", -- The Old Sister (crew of 2+)
		"brackwater_lofts", -- The Torn Page
		"order_drums", -- The Dead Commissioner's Seal
		"drowned_bell_garden", -- The Bell Garden
		"lamp_eater_roost", -- Wick
		"gate_clock", -- The Stolen Minutes
		"drowned_carousel", -- The Carousel Pact
		"dead_crane", -- Two Forges
	},

	cannery_pilings = {
		name = "The Cannery Pilings",
		desc = "The old cannery stands on rotten pilings over the Mere. Brask's ferry stopped here. At low water you can reach the walkways underneath.",
		kind = "mission",
		minAge = 14,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_ferry_search" } },
		start = "walkway",
		stages = {
			walkway = {
				title = "Under the Cannery",
				text = "The walkways under the cannery are slick and half-collapsed. Somewhere ahead, a lantern hook is knocking against a piling, over and over, like someone wants you to find it.",
				choices = {
					{ label = "Follow the knocking", next = "hook", result = { sanity = -1, log = "{crew} followed the knocking along the walkway." } },
					{ label = "Climb up into the cannery first", requires = { min = { fortitude = 30 } }, next = "hook", result = { log = "{crew} climbed into the cannery and came down at the far end." } },
				},
			},
			hook = {
				title = "Brask's Hook",
				text = "It's Brask's lantern hook, tied to a piling with a sailor's knot. Below it, wet footprints climb out of the water and walk up the piling into the dark. Something in the water is watching you read them.",
				tone = "strange",
				choices = {
					{ label = "Take the hook and back away slowly", hint = "Prudence clash.", clash = { stat = "prudence", foe = "The thing in the water", coins = 2, base = 4, coinPower = 3 }, win = { log = "{crew} backed away with the hook. Whatever was watching let you go." }, lose = { sanity = -4, fortitude = { -5, -2 }, log = "It came up out of the water to look at {champion} properly before it let you go." } },
					{ label = "Call Brask's name", result = { sanity = { -4, 4 }, log = "{crew} called his name. Very far below, very faintly, someone laughed." } },
				},
			},
		},
		success = { log = "You have Brask's hook. Now all you can do is wait." },
	},

	-- ── Old Chalk: a crew of friends leads an old pony through the crater wall ──
	old_salt_road = {
		name = "The Old Salt Road",
		desc = "A forgotten cart road runs from a dry culvert under the Saltworks pans, through the crater wall, out to the Salt Flats. It takes two to lead a pony through a tunnel: one at his head, and one with the lamp behind.",
		kind = "trip",
		minAge = 13,
		crew = { min = 2, max = 4 },
		length = 4,
		when = { flags = { "q_chalk_walk" }, notFlags = { "done_old_salt_road" } },
		start = "culvert",
		stages = {
			culvert = {
				title = "The Dry Culvert",
				text = "The culvert under Pan Nine is dry, as the carter promised, and just tall enough for a pony with his head down. Chalk plants his hooves at the mouth and looks at the dark the way old ponies look at bad ideas.",
				choices = {
					{ label = "Coax him in with an apple", next = "rockfall", result = { log = "{crew} walked backward into the dark holding out an apple, and Chalk followed it, grumbling." } },
					{ label = "Sing the carters' road song", hint = "The old carters taught it to you.", requires = { min = { prudence = 20 } }, next = "rockfall", result = { sanity = 2, log = "{crew} sang the carters' road song, and Chalk's ears came up. He knew it. He walked in on his own." } },
					{ label = "Try again another night", ["end"] = "retreat", result = { log = "{crew} led Chalk back to his stall to try again another night." } },
				},
			},
			rockfall = {
				title = "Inside the Crater Wall",
				text = "Halfway through the wall, the roof of the old road has come down in a slope of loose salt-rock. There's a path over the top as narrow as a plank, with a long drop on one side, and Chalk is trembling.",
				tone = "danger",
				choices = {
					{
						label = "Lead him over the top",
						hint = "Fortitude clash.",
						clash = { stat = "fortitude", foe = "The loose salt-rock", coins = 2, base = 4, coinPower = 3 },
						winNext = "mirror",
						loseNext = "mirror",
						win = { log = "{champion} took Chalk's head and walked him over one careful hoof at a time, talking the whole way." },
						lose = { fortitude = { -6, -2 }, sanity = -2, log = "The salt-rock slid under {champion}, and {crew} came down the far side in a heap with a very offended pony.", cause = "Fell on the old salt road" },
					},
					{
						label = "Dig out the old cart ruts underneath",
						hint = "Temperance clash.",
						clash = { stat = "temperance", foe = "The fallen roof", coins = 2, base = 4, coinPower = 3 },
						winNext = "mirror",
						loseNext = "mirror",
						win = { log = "{champion} found the old cart ruts under the rubble, and {crew} dug them clear, stone by stone." },
						lose = { fortitude = { -4, -1 }, log = "{crew} dug until your hands were raw with salt and squeezed Chalk through a gap that was really too small." },
					},
				},
			},
			mirror = {
				title = "The Salt Mirror",
				text = "Past the rockfall the road crosses a cave of white salt, smooth as glass, that throws your lamp back a thousand times. In every reflection Chalk is young again, black-maned, pulling a cart along a road that isn't there anymore. He stops to look for a long time.",
				tone = "strange",
				choices = {
					{ label = "Let him look", next = "flats", result = { sanity = 3, log = "{crew} let Chalk look for as long as he wanted. When he walked on, he walked like a younger pony." } },
					{ label = "Hurry him past", next = "flats", result = { prudence = 1, log = "{crew} hurried Chalk past the reflections. He kept looking back." } },
				},
			},
			flats = {
				title = "The White",
				text = "The road comes out of the crater wall into sunlight so bright it rings. The Salt Flats run white to the edge of the world, and a line of salt-cutters' sledges is coming toward you, their headwoman shading her eyes. Chalk lifts his head and smells the wind.",
				choices = {
					{ label = "Hand Chalk's rope to the headwoman", result = { sanity = 2, log = "{crew} handed Chalk's rope to the salt-cutters' headwoman. She looked at his teeth, then at you, and nodded once." } },
					{ label = "Ride him the last mile", hint = "Needs some nerve.", requires = { min = { justice = 20 } }, result = { sanity = 4, log = "{champion} rode Chalk the last mile across the salt, bareback and grinning, with the rest of you running behind." } },
				},
			},
		},
		success = { wage = { 10, 25 }, sanity = 3, log = "You rode the Undertow home that night smelling of salt and pony, and slept like a stone." },
		retreat = { log = "You led Chalk back to his stall. The bellows-yard cart hadn't come yet." },
	},

	-- ── The Hundredth Step: down the stair that isn't always there ──
	below_hundredth_step = {
		name = "Below the Hundredth Step",
		desc = "At midnight, sometimes, Bellhollow's Counting Stair has a hundred steps, and the extra one goes down between the stones. Something warm is lit at the bottom.",
		kind = "mission",
		minAge = 13,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_step_down" }, notFlags = { "done_below_hundredth_step" } },
		start = "stair",
		stages = {
			stair = {
				title = "The Narrow Stair",
				text = "The hundredth step leads to a stair so narrow your shoulders brush both walls. Through the stone you can hear every clock in Bellhollow ticking, hundreds of them, very slightly out of time with each other. The stair goes down further than the Counting Stair goes up.",
				choices = {
					{ label = "Count every step on the way down", next = "ropes", result = { prudence = 1, log = "{crew} counted every step down out loud. There were exactly a hundred." } },
					{ label = "Go down fast before it changes its mind", next = "ropes", result = { sanity = -1, log = "{crew} went down two steps at a time. Behind you, the ticking seemed to hurry too." } },
					{ label = "Go back up while you still can", ["end"] = "retreat", result = { log = "{crew} went back up. At the top, the Counting Stair had ninety-nine steps again." } },
				},
			},
			ropes = {
				title = "The Hall of Ropes",
				text = "At the bottom is a long hall hung with bell ropes, a hundred of them, each one vanishing up through the ceiling toward a tower somewhere above. They sway, though there's no wind. At the far end is a small door, and the ropes hang so close together that you'll have to pass between them to reach it.",
				tone = "strange",
				choices = {
					{
						label = "Slip through without touching a rope",
						hint = "Temperance clash.",
						clash = { stat = "temperance", foe = "A hundred bell ropes", coins = 2, base = 4, coinPower = 3 },
						winNext = "workshop",
						loseNext = "workshop",
						win = { log = "{champion} slid between the ropes like a cat, without a sound and without a single bell." },
						lose = { sanity = -2, log = "{champion} brushed a rope, and far overhead a single bell rang out over sleeping Bellhollow. There was nothing to do but run for the door." },
					},
					{ label = "Part them gently, one by one", next = "workshop", result = { sanity = -1, log = "{crew} parted the ropes one by one. Every one of them was warm, as if someone had only just let go." } },
				},
			},
			workshop = {
				title = "The Apprentice's Workshop",
				text = "Behind the door is a bell-maker's workshop, swept and lamplit, its tools laid out on the bench as if their owner stepped out a moment ago, two hundred years ago. In the middle hangs a small bell with no voice. Its clapper lies cracked on the bench beside a note in a boy's careful hand: Whoever counts a hundred, mend my bell.",
				choices = {
					{ label = "Take the cracked clapper", result = { log = "{crew} wrapped the cracked clapper in a scarf and started back up the hundred steps." } },
					{ label = "Tap the silent bell first", result = { sanity = { -3, 3 }, log = "{crew} tapped the silent bell with a fingernail. It made no sound, but every clock in Bellhollow stopped for one breath. Then you took the clapper and went." } },
				},
			},
		},
		success = { sanity = 2, log = "You came up the Counting Stair at dawn with a two-hundred-year-old clapper wrapped in your scarf. Behind you, the stair had ninety-nine steps." },
		retreat = { log = "You went home. The hundredth step stayed away for a week, then came back." },
	},

	-- ── The Old Sister: nobody dives that deep alone ──
	old_sister_dive = {
		name = "The Old Sister",
		desc = "Two hundred feet down off the end of Chandlers' Row sits the Old Sister, the Guild's first diving bell, waiting for new chains. The Guild's oldest rule is that nobody goes that deep alone.",
		kind = "dungeon",
		minAge = 16,
		crew = { min = 2, max = 4 },
		length = 3,
		when = { flags = { "q_sister_dive" }, notFlags = { "done_old_sister_dive" } },
		start = "line",
		stages = {
			line = {
				title = "Down the Shot Line",
				text = "The shot line drops straight off the barge into black water. At fifty feet the light turns green, at a hundred it's gone, and at a hundred and fifty your lamps are the only things in the world. Below you, something huge and brass catches the light and throws it back.",
				choices = {
					{ label = "Go down hand over hand", next = "nest", result = { fortitude = { -2, 0 }, log = "{crew} went down the shot line hand over hand, ears aching, lamps swinging." } },
					{ label = "Ride the lifting chain down", hint = "The old divers' way. Needs a steady head.", requires = { min = { prudence = 30 } }, next = "nest", result = { log = "{crew} rode the lifting chain down like a lift, steady and fast, the way the old divers did." } },
					{ label = "Signal the barge and go up", ["end"] = "retreat", result = { log = "{crew} signaled the barge and came up. The Old Sister would wait. She was good at it." } },
				},
			},
			nest = {
				title = "The Eel Nest",
				text = "The Old Sister sits in a field of soft silt, and the silt is moving. Silt eels have nested in her shadow, dozens of them, long and pale, and they don't like lamps. To shackle the chains, someone has to stand on her crown in the middle of them.",
				tone = "danger",
				choices = {
					{
						label = "Hold them off while the shackles go on",
						hint = "Justice clash.",
						clash = { stat = "justice", foe = "A nest of silt eels", coins = 2, base = 5, coinPower = 3 },
						winNext = "inside",
						loseNext = "inside",
						win = { log = "{champion} held the eels back with a hooked pole and a lamp while the others shackled the chains." },
						lose = { fortitude = { -8, -3 }, sanity = -2, log = "The eels came for the lamps and found {champion} instead. The chains went on anyway, and the crew hauled {champion} up under the bell, bitten and shaking.", cause = "Bitten at the Old Sister" },
					},
					{ label = "Douse the lamps and work by touch", next = "inside", result = { sanity = -3, log = "{crew} doused every lamp and shackled the chains in the dark by touch, while long cold things slid past your sleeves." } },
				},
			},
			inside = {
				title = "Inside the Old Sister",
				text = "You come up under her rim into the Old Sister's belly, and the air in there is dry. Four names are scratched into the brass beside the bench, and under them, in a steadier hand: WE WERE NOT AFRAID. TELL THEM.",
				tone = "strange",
				choices = {
					{ label = "Copy the names and go up", result = { log = "{crew} copied the four names onto a slate and signaled the barge. Nobody spoke on the way up." } },
					{ label = "Sit with them a minute", result = { sanity = { -2, 4 }, log = "{crew} sat on the old bench in the dry dark for a minute, where the last crew had sat. Then you copied the names and went up." } },
				},
			},
		},
		success = { wage = { 40, 90 }, sanity = 2, log = "You came up off Chandlers' Row with the chains fixed and four names on a slate. Every diver on the barge took off their cap." },
		retreat = { log = "You came up with the chains still on the barge. The Old Sister kept waiting." },
	},

	-- ── The Torn Page: the drowned net lofts under the Brackwater Steps ──
	brackwater_lofts = {
		name = "The Brackwater Net Lofts",
		desc = "Under the Brackwater Steps, the old net lofts have stood half-drowned since the last great High Water, with the nets still hanging from the rafters. The night the page was cut, a boatman saw a lantern moving in there.",
		kind = "dungeon",
		minAge = 15,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_page_search" }, notFlags = { "done_brackwater_lofts" } },
		start = "floor",
		stages = {
			floor = {
				title = "The Flooded Floor",
				text = "The lofts' ground floor is under four feet of black water, and old nets hang down into it from the rafters like curtains. Somewhere above, a loose shutter is knocking. Fresh scratches on a ladder show where someone light climbed up not long ago.",
				choices = {
					{ label = "Climb the scratched ladder", next = "nets", result = { log = "{crew} climbed the scratched ladder into the dark of the loft." } },
					{ label = "Wade through to the far stair", next = "nets", result = { fortitude = { -3, -1 }, log = "{crew} waded between the hanging nets through the black water, trying not to think about what might be tangled in them." } },
				},
			},
			nets = {
				title = "The Hanging Nets",
				text = "The upper loft is a maze of nets hung up to dry fifty years ago and never taken down. They're rotten, heavy and everywhere, and the floor between them is more hole than board. Something small and quick is moving through them.",
				tone = "danger",
				choices = {
					{
						label = "Cut a way through",
						hint = "Justice clash.",
						clash = { stat = "justice", foe = "The rotten nets", coins = 2, base = 4, coinPower = 3 },
						winNext = "rafters",
						loseNext = "rafters",
						win = { log = "{champion} cut a path through the nets with quick, clean strokes." },
						lose = { fortitude = { -5, -2 }, sanity = -1, log = "The rotten nets came down on {champion} in a heap, and it took a long, unpleasant minute to cut free.", cause = "Tangled in the Brackwater net lofts" },
					},
					{ label = "Follow the small quick thing", next = "rafters", result = { sanity = -1, log = "{crew} followed the rustling and found a family of loft rats who knew every safe board. You stepped where they stepped." } },
				},
			},
			rafters = {
				title = "In the Rafters",
				text = "Up in the rafters, wrapped in oilcloth and tied with net twine, is the page. Pinned to it is a note in an old, careful hand: PLEASE. NOT THIS YEAR. Through a hole in the floor below, the Mere is very quietly rising.",
				choices = {
					{ label = "Take the page and the note", result = { log = "{crew} took the page and the note and got out before the water reached the ladder." } },
					{ label = "Read the page first", result = { prudence = 2, sanity = -1, log = "{crew} read the page by lamplight: forty families, every debt, every name. Some of the debts were older than the children who owed them." } },
				},
			},
		},
		success = { sanity = 1, log = "You rowed back with the page inside your shirt. The handwriting on the note was familiar, and you couldn't think why." },
	},

	-- ── The Dead Commissioner's Seal: the clockwork under the spill gate ──
	order_drums = {
		name = "The Order Drums",
		desc = "Under the Ward's spill gate is the clockwork that carries out every standing order: brass drums, iron teeth, and the Mere pressing on the other side. Clerks aren't allowed down there. Clerks are the only ones who know where it is.",
		kind = "mission",
		minAge = 18,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_seal_gate" }, notFlags = { "done_order_drums" } },
		start = "door",
		stages = {
			door = {
				title = "The Engineers' Door",
				text = "The engineers' door is chained shut and painted NO CLERKS in red letters a foot high. Behind it, something enormous is ticking, slow as a heartbeat. The gate porter is asleep in his box with the key on a nail beside his ear.",
				choices = {
					{
						label = "Lift the key off its nail",
						hint = "Temperance clash.",
						clash = { stat = "temperance", foe = "The sleeping porter", coins = 1, base = 3, coinPower = 2 },
						winNext = "drums",
						loseNext = "culvert",
						win = { log = "{champion} lifted the key off its nail without a sound, and the porter snored on." },
						lose = { sanity = -1, log = "The porter woke, grumbled about clerks, and locked the key in his drawer, so {crew} went round by the culvert." },
					},
					{ label = "Go round by the overflow culvert", next = "culvert", result = { log = "{crew} went round to the overflow culvert, where the gate leaks." } },
				},
			},
			culvert = {
				title = "The Overflow Culvert",
				text = "The culvert runs right under the gate. Water jets through its seams in white feathers, and every few minutes the whole gate groans like a ship in a storm. A rusted grille blocks the way through to the drums.",
				tone = "danger",
				choices = {
					{
						label = "Force the grille",
						hint = "Fortitude clash.",
						clash = { stat = "fortitude", foe = "The rusted grille", coins = 2, base = 4, coinPower = 3 },
						winNext = "drums",
						loseNext = "drums",
						win = { log = "{champion} heaved the grille off its hinges, and the way through to the drums was open." },
						lose = { fortitude = { -6, -2 }, log = "The grille gave on the third heave and took {champion} down into the water with it, and {crew} came up into the drum hall coughing.", cause = "Drowned in the gate culvert" },
					},
					{ label = "Back out", ["end"] = "retreat", result = { log = "{crew} backed out of the culvert. Under the gate, the drums kept turning." } },
				},
			},
			drums = {
				title = "The Drum Hall",
				text = "The clockwork fills a hall as big as a chapel: brass drums studded with pins, each pin a standing order, each drum turning one notch every High Water. The Anchor Court pin is worn shiny. Someone has scratched a tiny house beside it, and thirty tally marks.",
				tone = "strange",
				choices = {
					{ label = "Pull the Anchor Court pin", result = { sanity = 2, log = "{crew} pulled the Anchor Court pin. The whole hall seemed to tick a little quieter." } },
					{ label = "Pull the pin and count the others", hint = "You might not like the number.", requires = { min = { prudence = 30 } }, result = { prudence = 2, sanity = -3, log = "{crew} pulled the pin, then counted the others: four hundred standing orders, most of them for the Silt. You carried the number home like a stone." } },
				},
			},
		},
		success = { log = "You came out of the gatehouse at dawn with a brass pin in your pocket and grease to the elbows." },
		retreat = { log = "You went home. Anchor Court's pin is still turning." },
	},

	-- ── The Bell Garden: iron trees under the water below Bellhollow ──
	drowned_bell_garden = {
		name = "The Drowned Bell Garden",
		desc = "Below Bellhollow, the Bellwrights once hung new bells from iron trees to weather. The garden went under sixty years ago, and the bells still sway in the current. At low tide, the tops of the iron trees come up.",
		kind = "mission",
		minAge = 12,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_bells_garden" }, notFlags = { "done_drowned_bell_garden" } },
		start = "trees",
		stages = {
			trees = {
				title = "The Iron Trees",
				text = "The tops of the iron trees stand out of the water like the masts of a sunken fleet, hung with green bells. Under the surface, more bells sway in the current, ringing too low to hear except through your feet. Somewhere out among them: seven strokes, over and over.",
				choices = {
					{ label = "Wade out along the old garden wall", next = "grove", result = { fortitude = { -2, 0 }, log = "{crew} waded out along the drowned garden wall, waist-deep, feeling for each stone with your feet." } },
					{ label = "Hire a punt from the Bellwrights' boathouse", hint = "10 scrip.", requires = { min = { money = 10 } }, next = "grove", result = { money = -10, log = "{crew} hired a flat punt from the Bellwrights' boathouse and poled out between the iron trees." } },
				},
			},
			grove = {
				title = "The Ringing Grove",
				text = "In the middle of the garden the bells are louder, and the iron branches are crowded with lamp-eaters, soft and grey and blind, clinging like wet moths. They all turn toward your lamp at once. Beyond them, the seven strokes go on.",
				tone = "strange",
				choices = {
					{
						label = "Shade the lamp and walk through them",
						hint = "Prudence clash.",
						clash = { stat = "prudence", foe = "The lamp-eaters in the branches", coins = 2, base = 4, coinPower = 3 },
						winNext = "bell",
						loseNext = "bell",
						win = { sanity = 2, log = "{champion} shaded the lamp and walked through them slowly, humming, and not one of them stirred." },
						lose = { sanity = -4, log = "The lamp-eaters came off the branches in a soft grey cloud and smothered the lamp, and {crew} went the rest of the way in the dark, counting strokes." },
					},
					{ label = "Go round the long way", next = "bell", result = { fortitude = { -3, -1 }, sanity = -1, log = "{crew} went the long way round the grove, through cold water and fallen bells, while the lamp-eaters watched." } },
				},
			},
			bell = {
				title = "The Seventh Stroke",
				text = "On the last iron tree hangs a small brass hand bell, the kind the Choir rings to end a long silence, ringing seven strokes in the current with nobody touching it. Its handle is wrapped in grey wool gone green. When you lift it from its hook, the whole garden falls silent.",
				choices = {
					{ label = "Ring the seventh stroke yourself", result = { sanity = 4, log = "{crew} rang the seventh stroke. Far out across the Mere, very faintly, every bell in the garden rang it back, and then the water was still." } },
					{ label = "Carry it home silent", result = { prudence = 2, log = "{crew} wrapped the little bell in a scarf and carried it home without a sound." } },
				},
			},
		},
		success = { sanity = 2, log = "You came home with the lost hand bell and the count of seven in your bones." },
	},

	-- ── Wick: taking a lamp-eater home to its roost ──
	lamp_eater_roost = {
		name = "The Lamp-Eaters' Roost",
		desc = "Under the Lampwick gasworks pier, where the old gas mains leak their glow into the water, lamp-eaters roost by the hundred. It's the one place in the Mere where there's always something to eat. Wick is going home, in a covered basket.",
		kind = "trip",
		minAge = 18,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_wick_roost" }, notFlags = { "done_lamp_eater_roost" } },
		start = "pier",
		stages = {
			pier = {
				title = "The Gasworks Pier",
				text = "The Lampwick gasworks pier runs out over the Silt on black iron legs, and underneath it the water glows a faint, sick green where the old mains leak. In his basket, Wick has gone very still, feelers pressed to the wicker, listening to a hum you can feel in your teeth.",
				choices = {
					{ label = "Carry the basket out along the pier", next = "dark", result = { log = "{crew} carried Wick out along the pier, step by careful step, toward the hum." } },
					{ label = "Row out underneath the pier", hint = "Needs strong arms.", requires = { min = { fortitude = 25 } }, next = "dark", result = { fortitude = { -2, 0 }, log = "{crew} rowed out between the iron legs, the water glowing green under the oars." } },
					{ label = "Take Wick home and try another night", ["end"] = "retreat", result = { log = "{crew} turned back. Wick sulked in his basket all the way home." } },
				},
			},
			dark = {
				title = "Lights Out",
				text = "Halfway out, Wick pushes his feelers through the wicker and snuffs your lamp, quick as a breath on a birthday candle. In the dark you can see the roost glowing ahead, and hear something big shifting in the water under the boards.",
				tone = "danger",
				choices = {
					{
						label = "Feel your way on in the dark",
						hint = "Prudence clash.",
						clash = { stat = "prudence", foe = "The dark under the pier", coins = 2, base = 4, coinPower = 3 },
						winNext = "roost",
						loseNext = "roost",
						win = { log = "{champion} felt the way along the rail, board by board, and the big thing in the water let you pass." },
						lose = { fortitude = { -5, -2 }, sanity = -2, log = "{champion} put a foot through a rotten board and had to scramble back up while something cold brushed past below.", cause = "Fell through the gasworks pier" },
					},
					{
						label = "Relight the lamp under your coat",
						hint = "Temperance clash.",
						clash = { stat = "temperance", foe = "A wet match and a hungry lamp-eater", coins = 1, base = 3, coinPower = 2 },
						winNext = "roost",
						loseNext = "roost",
						win = { log = "{champion} got the lamp lit under a coat, and Wick, outwitted, sulked." },
						lose = { sanity = -1, log = "Wick snuffed the match, and the next one, and the one after that, so {crew} went on in the dark." },
					},
				},
			},
			roost = {
				title = "The Roost",
				text = "Under the end of the pier, hanging from every beam and cable, are lamp-eaters: hundreds of them, grey and soft as dust, folded up like sleeping bats and humming all together. A big old one at the edge of the roost unfolds and turns its feelers toward the basket.",
				tone = "strange",
				choices = {
					{ label = "Open the basket and let Wick go", result = { sanity = 3, log = "{crew} opened the basket. Wick climbed out, touched each of your hands with his feelers, and went up into the roost to hang beside the big old one." } },
					{ label = "Wait for the old one to come for him", result = { prudence = 2, log = "{crew} waited, very still, until the big old lamp-eater climbed down, folded its feelers round Wick, and carried him up into the roost." } },
				},
			},
		},
		success = { sanity = 2, log = "You walked home along the gasworks pier with an empty basket, and every lamp you passed burned a little brighter." },
		retreat = { log = "You took Wick home again. He ate the hall lamp out of spite." },
	},

	-- ── The Stolen Minutes: inside the clock over the Charter gate ──
	gate_clock = {
		name = "The Gate Clock",
		desc = "The great clock over the Charter gate has four faces, a bell, and a door at the top of a spiral stair that the company keeps locked. The clock-winder comes on Tuesdays. It is not Tuesday.",
		kind = "mission",
		minAge = 18,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_minutes_tower" }, notFlags = { "done_gate_clock" } },
		start = "stair",
		stages = {
			stair = {
				title = "The Spiral Stair",
				text = "The spiral stair inside the gate tower climbs past the guardroom, where two company guards are arguing over a game of draughts, and on up into the ticking dark. The door at the top is locked. The clock-winder's spare key, everyone knows, lives under the third brass lamp.",
				choices = {
					{
						label = "Creep past the guardroom",
						hint = "Prudence clash.",
						clash = { stat = "prudence", foe = "Two bored company guards", coins = 2, base = 4, coinPower = 3 },
						winNext = "works",
						loseNext = "works",
						win = { log = "{champion} crept past the guardroom on the outside edges of the steps, where they don't creak." },
						lose = { sanity = -2, log = "A guard looked up and saw {crew}, and {champion} had to talk fast about the clock-winder sending you. He was too bored to argue." },
					},
					{ label = "Walk past as if you own the place", hint = "Only works if you live inside the walls.", requires = { side = "charter" }, next = "works", result = { log = "{crew} walked straight past the guardroom as if you owned the tower, and the guards stood up a little straighter." } },
				},
			},
			works = {
				title = "The Clockworks",
				text = "Behind the door, the clock's works fill the tower: wheels as big as cart wheels, a pendulum slow as breathing, and the four great faces seen from behind, backward and glowing. Bolted to the escapement is something that doesn't belong there, a brass governor with the company's seal, quietly nudging the hands along.",
				tone = "strange",
				choices = {
					{
						label = "Open the governor's case",
						hint = "Temperance clash.",
						clash = { stat = "temperance", foe = "The company governor", coins = 2, base = 4, coinPower = 3 },
						winNext = "ledger",
						loseNext = "ledger",
						win = { log = "{champion} found the screws hidden behind the seal and opened the case without stopping the clock." },
						lose = { fortitude = { -4, -1 }, log = "The pendulum swung back sooner than expected and knocked {champion} flat, but {crew} got the case open anyway." },
					},
					{ label = "Pry it open", next = "ledger", result = { sanity = -1, log = "{crew} pried the governor's case open with a lamp-hook. The clock missed a tick, and every clock in the Charter seemed to notice." } },
				},
			},
			ledger = {
				title = "Minutes Recovered",
				text = "Inside the governor's case is a little leather ledger, and every page is the same: a date, the words MINUTES RECOVERED, and a sum in red ink. Thirty years of pages. The last entry is this morning's, and the ink is still wet.",
				choices = {
					{ label = "Take the ledger", result = { log = "{crew} slipped the little ledger into a coat pocket and went back down the spiral stair." } },
					{ label = "Take the ledger and set the clock right", hint = "Needs a craftsman's hands.", requires = { min = { temperance = 30 } }, result = { justice = 2, log = "{crew} took the ledger, then set the hands back four minutes. Down at the gate, the guards checked their watches and looked very confused." } },
				},
			},
		},
		success = { log = "You came down out of the gate tower with thirty years of other people's minutes in your pocket." },
	},

	-- ── The Carousel Pact: out across the low-tide flats ──
	drowned_carousel = {
		name = "The Drowned Carousel",
		desc = "The Kelpmarket fairground went under in the High Water of your childhood. At the bottom of the lowest tides, the carousel's striped roof comes up out of the Silt, with the brass horses standing in the shallows underneath. You promised to meet there.",
		kind = "trip",
		minAge = 14,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_pact_carousel" }, notFlags = { "done_drowned_carousel" } },
		start = "flats",
		stages = {
			flats = {
				title = "The Flats",
				text = "The tide has pulled back further than anyone can remember, and the Kelpmarket flats are a mile of shining mud. Out at the edge of the water, the carousel's striped roof sits crooked in the Silt like a hat dropped from a great height. Your knees are not what they were.",
				choices = {
					{
						label = "Walk out across the mud",
						hint = "Fortitude clash.",
						clash = { stat = "fortitude", foe = "A mile of sucking mud", coins = 1, base = 3, coinPower = 2 },
						winNext = "horses",
						loseNext = "horses",
						win = { log = "{champion} found the old fairground path under the mud and walked it all the way out to the carousel without sinking past the ankle." },
						lose = { fortitude = { -4, -1 }, sanity = -1, log = "{crew} sank to the knee twice and came out the far side plastered in mud and laughing like children, which helped." },
					},
					{ label = "Pay a mud-sledge boy to pull you out", hint = "5 scrip.", requires = { min = { money = 5 } }, next = "horses", result = { money = -5, sanity = 2, log = "{crew} rode out across the flats on a mud-sledge, pulled by a boy who couldn't believe his luck." } },
				},
			},
			horses = {
				title = "The Brass Horses",
				text = "Under the crooked roof, the brass horses stand in a ring in knee-deep water, green and gleaming, their painted eyes still bright. They're smaller than you remember. When the wind crosses the roof, the old organ in the middle wheezes out three notes of the carousel tune, and you know the fourth.",
				tone = "strange",
				choices = {
					{ label = "Hum the fourth note", next = "pole", result = { sanity = 4, log = "{crew} hummed the fourth note without meaning to. The water round the horses shivered." } },
					{ label = "Find your old horse", next = "pole", result = { sanity = 2, log = "{crew} waded round the ring until you found your old horse, the one with the chipped ear, and put a hand on its neck." } },
				},
			},
			pole = {
				title = "The Brass Pole",
				text = "Under the brass pole in the middle of the carousel, where five children once buried it with a borrowed spoon, is a tin box, rusted shut. The tide has turned. The water is starting back across the flats, slowly, the way it always did.",
				choices = {
					{ label = "Open it right here", result = { sanity = 3, log = "{crew} pried the tin open on the carousel steps: two marbles, a whistle, five tin badges, and a note in five children's handwriting. IF YOU'RE READING THIS, WE CAME BACK." } },
					{ label = "Carry it home to open", result = { prudence = 1, log = "{crew} carried the tin home ahead of the tide and opened it over hot broth: two marbles, a whistle, five tin badges, and a note. IF YOU'RE READING THIS, WE CAME BACK." } },
				},
			},
		},
		success = { sanity = 3, log = "You came back across the flats ahead of the tide with a rusted tin box and mud to the knees, feeling about eleven." },
	},

	-- ── Two Forges: the dead crane at the bottom of Anvil Lane ──
	dead_crane = {
		name = "The Dead Crane",
		desc = "At the bottom of Anvil Lane stands the Ironmongers' old dock crane, dead for twenty years, its iron arm stretched out over the Mere. Children are forbidden to climb it, which is why children climb it. Two of them are up there now.",
		kind = "mission",
		minAge = 16,
		crew = { min = 1, max = 4 },
		length = 3,
		when = { flags = { "q_forge_crane" }, notFlags = { "done_dead_crane" } },
		start = "ladder",
		stages = {
			ladder = {
				title = "The Ladder",
				text = "The crane's ladder climbs the tower in rusted flights, a hundred feet up, with the wind off the Mere getting stronger at every landing. Two sets of small sooty handprints go up the rungs side by side, and a trail of breadcrumbs, as if somebody wanted to be followed eventually.",
				choices = {
					{
						label = "Climb steadily",
						hint = "Fortitude clash.",
						clash = { stat = "fortitude", foe = "A hundred feet of rusted ladder", coins = 2, base = 4, coinPower = 3 },
						winNext = "arm",
						loseNext = "arm",
						win = { log = "{champion} climbed steady and slow, one rusted rung at a time, and never once looked down." },
						lose = { fortitude = { -6, -2 }, sanity = -2, log = "A rung snapped under {champion}, and {crew} hung on by the hands in the wind until the shaking stopped, then climbed on.", cause = "Fell from the dead crane" },
					},
					{ label = "Call up to them first", next = "arm", result = { log = "{crew} called up the tower. After a long time, a small voice called back down: 'Only if you come up!'" } },
				},
			},
			arm = {
				title = "Along the Arm",
				text = "The crane's cab hangs at the far end of its iron arm, out over the Mere, swaying. The walkway along the arm is a single girder with a handrail on one side, and the wind is trying to take your coat.",
				tone = "danger",
				choices = {
					{
						label = "Walk the girder",
						hint = "Justice clash.",
						clash = { stat = "justice", foe = "The swaying girder", coins = 2, base = 4, coinPower = 3 },
						winNext = "cab",
						loseNext = "cab",
						win = { log = "{champion} walked the girder like a rope-dancer, arms out, all the way to the cab." },
						lose = { sanity = -3, log = "The arm lurched in a gust, and {crew} finished the walk on hands and knees, with the Mere very far below." },
					},
					{ label = "Edge along the handrail", next = "cab", result = { fortitude = { -2, 0 }, sanity = -1, log = "{crew} edged along the handrail hand over hand, slow as winter." } },
				},
			},
			cab = {
				title = "The Cab",
				text = "The crane cab is a den: two blankets, a lamp, a sack of bread, and a chalk line down the middle of the floor that both children have long since stopped paying attention to. Dov and Jessamy look up at you, sooty and defiant. 'We're not coming down,' says Jessamy, 'until they sit at one table.'",
				choices = {
					{ label = "Promise them one table", result = { justice = 2, log = "{crew} promised. Jessamy made you shake on it, twice, with a sooty hand, and then they let you walk them down." } },
					{ label = "Tell them how frightened their families are", result = { sanity = 2, log = "{crew} told them about the hammers in the lane. Dov went very quiet and picked up the lamp. 'Then promise,' said Jessamy, 'one table,' and {crew} did." } },
				},
			},
		},
		success = { sanity = 2, log = "You came down the dead crane with two sooty children, one on each side, and walked them down the middle of Anvil Lane." },
	},
}
