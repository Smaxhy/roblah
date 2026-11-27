--[[
	BOSSES fought in turns (Engine/Battle.luau): the boss rooms of Gates (ORIGINAL GAME CONTENT).

	Canon gives every Gate a boss whose death closes it (about an hour later), and a Red Gate
	that won't open until its boss is dead. These particular bosses are the game's own.

	Two per rank: the first is a raid's boss room (Events/Incidents.luau hw_raid_<rank>), the
	second waits at the end of a Red Gate whose real rank is that rank (hw_red_<rank-1>: a Red
	Gate reads one rank lower than it is). Friends on the server can join a boss fight.

	Tuned by headless fights (Engine/Battle): a Hunter of the boss's rank with middling stats
	(about a third of the rank's cap) and a plain weapon of that grade wins a solo boss room
	about half the time; a strong one nearly always; one rank under, almost never. Friends who
	join the fight tip it. A Red Gate's boss is fought one rank under by design: run if you must.
]]

local BOSSES = {
	-- ── E ────────────────────────────────────────────────────────────────
	goblin_chief = {
		name = "Goblin Chieftain", title = "Boss of an E-rank Gate", enemy = "gate_e",
		hp = 90, coins = 2, base = 6, coinPower = 3, temper = "quick",
		cause = "Killed by a goblin chieftain",
		moves = {
			{ id = "stab", name = "Rusty Spear", text = "lunges with a rusted spear", power = 6, weight = 10, status = "bleed" },
			{ id = "call", name = "Call the Pack", text = "shrieks, and goblins come out of every crack", power = 4, weight = 6, target = "all" },
		},
		phases = { { at = 0.4, line = "The chieftain drinks something glowing from a crystal flask.", base = 1, power = 2 } },
		barks = { start = { "*a shrill war cry*" }, hurt = { "*hissing*" }, phase = { "*it swells, grinning*" } },
	},
	bat_matriarch = {
		name = "Cave Bat Matriarch", title = "What a Red Gate's cave hides", enemy = "gate_e",
		hp = 110, coins = 2, base = 5, coinPower = 3, temper = "quick",
		cause = "Killed by a bat matriarch in a Red Gate",
		moves = {
			{ id = "dive", name = "Dive", text = "folds its wings and drops out of the dark", power = 7, weight = 10 },
			{ id = "shriek", name = "Shriek", text = "screams, and the cave screams back at you", power = 4, weight = 6, target = "all", status = "tremor" },
		},
		phases = { { at = 0.45, line = "The whole roof of the cave comes loose: it's bats, thousands, and they all answer her.", base = 1, power = 2, moves = { { id = "swarm", name = "The Colony", text = "sends the colony through you", power = 6, weight = 8, target = "all" } } } },
		barks = { start = { "*a whistle too high to hear*" }, hurt = { "*a chittering hiss*" }, phase = { "*the dark moves*" } },
	},

	-- ── D ────────────────────────────────────────────────────────────────
	brood_mother = {
		name = "Brood Mother", title = "Boss of a D-rank Gate", enemy = "gate_d",
		hp = 150, coins = 2, base = 11, coinPower = 4, temper = "cunning",
		cause = "Killed by a giant spider's brood mother",
		moves = {
			{ id = "fangs", name = "Venom Fangs", text = "sinks fangs as long as your forearm", power = 9, weight = 10, status = "bleed" },
			{ id = "web", name = "Web", text = "spits a sheet of web across the chamber", power = 5, weight = 6, target = "all", status = "sinking" },
		},
		phases = { { at = 0.4, line = "The egg sacs on the ceiling split. Her children come down on threads.", base = 2, power = 2, moves = { { id = "brood", name = "The Brood", text = "lets the hatchlings loose", power = 7, weight = 8, target = "all", status = "bleed" } } } },
		barks = { start = { "*clicking, from every wall*" }, hurt = { "*a wet hiss*" }, phase = { "*a thousand small legs*" } },
	},
	hob_captain = {
		name = "Hobgoblin Captain", title = "What a Red Gate's fort holds", enemy = "gate_d",
		hp = 170, coins = 3, base = 7, coinPower = 4, temper = "brute",
		cause = "Killed by a hobgoblin captain in a Red Gate",
		moves = {
			{ id = "pike", name = "Pike Line", text = "drives its pike through the gap in your guard", power = 10, weight = 10 },
			{ id = "drill", name = "Shield Wall", text = "barks an order, and its soldiers lock shields and push", power = 6, weight = 6, target = "all", status = "tremor" },
		},
		phases = { { at = 0.35, line = "The captain throws down its shield and takes its pike in both hands.", base = 3, power = 3 } },
		barks = { start = { "*a drilled, barked order*" }, hurt = { "*a grunt*" }, phase = { "*it charges*" } },
	},

	-- ── C ────────────────────────────────────────────────────────────────
	orc_warlord = {
		name = "Orc Warlord", title = "Boss of a C-rank Gate", enemy = "gate_c",
		hp = 220, coins = 3, base = 14, coinPower = 5, temper = "brute",
		cause = "Killed by an orc warlord",
		moves = {
			{ id = "cleave", name = "Cleaver", text = "brings down a cleaver the size of a door", power = 14, weight = 10, heavy = true },
			{ id = "roar", name = "War Roar", text = "roars, and the whole party flinches", power = 7, weight = 6, target = "all" },
		},
		phases = { { at = 0.35, line = "The warlord's eyes go red. It stops feeling pain.", base = 3, power = 3 } },
		barks = { start = { "*a guttural challenge*" }, hurt = { "*snarling*" }, phase = { "*it laughs*" } },
	},
	naga_matriarch = {
		name = "Naga Matriarch", title = "What a Red Gate's flooded temple keeps", enemy = "gate_c",
		hp = 250, coins = 3, base = 15, coinPower = 5, temper = "cunning",
		cause = "Drowned by a naga matriarch in a Red Gate",
		moves = {
			{ id = "trident", name = "Trident", text = "strikes with a trident of black coral", power = 14, weight = 10 },
			{ id = "coil", name = "Coil", text = "wraps you in a body as thick as a tree and squeezes", power = 11, weight = 7, status = "sinking" },
			{ id = "tide", name = "Black Tide", text = "raises the water in the temple to your chest", power = 7, weight = 5, target = "all" },
		},
		phases = { { at = 0.4, line = "She sings, and the water starts to pull.", base = 3, power = 3 } },
		barks = { start = { "*a low, sweet song*" }, hurt = { "*a hiss like a kettle*" }, phase = { "*the song changes key*" } },
	},

	-- ── B ────────────────────────────────────────────────────────────────
	frost_bear = {
		name = "Alpha Ice Bear", title = "Boss of a B-rank Gate", enemy = "gate_b",
		hp = 380, coins = 3, base = 23, coinPower = 6, temper = "brute",
		cause = "Killed by an alpha ice bear",
		moves = {
			{ id = "maul", name = "Maul", text = "rears up and comes down on you", power = 20, weight = 10, heavy = true, status = "bleed" },
			{ id = "blizzard", name = "Whiteout", text = "shakes the ceiling loose, and the cavern fills with ice", power = 10, weight = 5, target = "all" },
		},
		phases = { { at = 0.4, line = "Frost spreads across its fur like armour.", base = 4, power = 4 } },
		barks = { start = { "*a roar that shakes the ice*" }, hurt = { "*a pained bellow*" }, phase = { "*the cold deepens*" } },
	},
	wraith_lord = {
		name = "Wraith Lord", title = "What a Red Gate's crypt keeps", enemy = "gate_b",
		hp = 360, coins = 3, base = 26, coinPower = 6, temper = "cunning",
		cause = "Taken by a wraith lord in a Red Gate",
		moves = {
			{ id = "scythe", name = "Reaping", text = "draws a scythe through you that leaves no cut, only cold", power = 19, weight = 10 },
			{ id = "dread", name = "Dread", text = "opens its hood, and every one of you sees your own death", power = 9, weight = 6, target = "all", status = "sinking" },
		},
		phases = { { at = 0.4, line = "The lord splits into three. Two of them are lying.", base = 4, power = 4, moves = { { id = "phantoms", name = "Phantoms", text = "comes at you from three sides at once", power = 14, weight = 7, target = "all" } } } },
		barks = { start = { "*a whisper in a dead language*" }, hurt = { "*a sound like tearing silk*" }, phase = { "*three whispers*" } },
	},

	-- ── A ────────────────────────────────────────────────────────────────
	golem_lord = {
		name = "Golem Overlord", title = "Boss of an A-rank Gate", enemy = "gate_a",
		hp = 640, coins = 4, base = 28, coinPower = 8, temper = "cunning",
		cause = "Crushed by a golem overlord",
		moves = {
			{ id = "slam", name = "Mountain Fist", text = "brings both fists down", power = 30, weight = 10, heavy = true, status = "tremor" },
			{ id = "shards", name = "Shard Storm", text = "bursts apart into a storm of stone and reforms", power = 16, weight = 6, target = "all" },
		},
		phases = { { at = 0.3, line = "The core in its chest blazes orange. It's getting faster.", base = 6, power = 6 } },
		barks = { start = { "*stone grinding on stone*" }, hurt = { "*cracking*" }, phase = { "*a furnace roar*" } },
	},
	wyvern_queen = {
		name = "Wyvern Queen", title = "What a Red Gate's sky belongs to", enemy = "gate_a",
		hp = 600, coins = 4, base = 25, coinPower = 8, temper = "quick",
		cause = "Burned by a wyvern queen in a Red Gate",
		moves = {
			{ id = "talons", name = "Talons", text = "stoops out of the sky with talons like ploughs", power = 28, weight = 10, status = "bleed" },
			{ id = "sting", name = "Tail Sting", text = "whips a barbed tail across the party", power = 15, weight = 6, target = "all", status = "rupture" },
		},
		phases = { { at = 0.4, line = "She stops circling. Her throat lights up from the inside.", base = 6, power = 6, moves = { { id = "breath", name = "Firestorm", text = "breathes fire across the whole ridge", power = 22, weight = 8, target = "all", status = "burn" } } } },
		barks = { start = { "*a scream from very high up*" }, hurt = { "*a furious shriek*" }, phase = { "*the air starts to burn*" } },
	},

	-- ── S ────────────────────────────────────────────────────────────────
	dragonkin_tyrant = {
		name = "Dragon-kin Tyrant", title = "Boss of an S-rank Gate", enemy = "gate_s",
		hp = 1100, coins = 4, base = 55, coinPower = 11, temper = "brute",
		cause = "Killed by a dragon-kin tyrant",
		moves = {
			{ id = "jaws", name = "Jaws", text = "closes jaws that bite through armour plate", power = 44, weight = 10, heavy = true },
			{ id = "flame", name = "Black Flame", text = "breathes a fire that doesn't give light", power = 26, weight = 6, target = "all", status = "burn" },
			{ id = "wing", name = "Wingbeat", text = "beats its wings once, and the party is thrown down", power = 18, weight = 5, target = "all", status = "tremor" },
		},
		phases = {
			{ at = 0.55, line = "Its scales lift like a hackle. Under them, it's burning.", base = 6, power = 6 },
			{ at = 0.25, line = "It stops fighting like an animal. It starts fighting like something that has killed armies.", base = 8, power = 8, moves = { { id = "inferno", name = "Inferno", text = "turns the boss room into a furnace", power = 34, weight = 9, target = "all", status = "burn" } } },
		},
		barks = { start = { "*a roar you feel in your teeth*" }, hurt = { "*a hiss of steam from its wounds*" }, phase = { "*it rises*" } },
	},
	hollow_king = {
		name = "The Hollow King", title = "What waits on a Red Gate's throne", enemy = "gate_s",
		hp = 1000, coins = 4, base = 54, coinPower = 11, temper = "cunning",
		cause = "Unmade by the Hollow King in a Red Gate",
		moves = {
			{ id = "decree", name = "Decree", text = "points at you, and something in you obeys", power = 42, weight = 10 },
			{ id = "court", name = "The Court Rises", text = "lifts a hand, and the court's dead stand up from their seats", power = 24, weight = 6, target = "all", status = "sinking" },
		},
		phases = {
			{ at = 0.5, line = "The crown on the empty armour flares. The King stands.", base = 7, power = 7 },
			{ at = 0.2, line = "The throne room begins to fold in on itself.", base = 8, power = 8, moves = { { id = "collapse", name = "Collapse", text = "brings the hall down around everyone in it", power = 32, weight = 9, target = "all", status = "rupture" } } },
		},
		barks = { start = { "*a voice from inside empty armour*" }, hurt = { "*a hollow ringing*" }, phase = { "*the crown burns*" } },
	},
}

return BOSSES
