--[[
	BOSSES fought in turns (Engine/Battle.luau): the boss rooms of Gates (ORIGINAL GAME CONTENT).

	Canon gives every Gate a boss whose death closes it (about an hour later), and a Red Gate
	that won't open until its boss is dead. These particular bosses are the game's own.

	Several per rank: a raid's boss room (Events/Incidents.luau hw_raid_<rank>) meets one of its
	rank's (RAID_BOSS there: 2 at E to B, 3 at A, 4 at S), and a Red Gate's throne one of the
	rank above the reading (RED_BOSS: a Red Gate reads one rank lower than it is). Friends on
	the server can join a boss fight.

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

	-- ══ the bestiary's family bosses (ORIGINAL bosses of canon-type and original families;
	-- Hunter/Bestiary). Tuned on the ones above: the same base, coins and health for their rank.
	-- None is a canon individual: the ice elf warchief is not the Red Gate's boss, the hive
	-- matron is not Jeju's queen, the demon noble is no demon lord of the story.

	-- ── E ──
	kobold_tunnel_boss = {
		name = "Kobold Tunnel-Boss", title = "Boss of a kobold mine", enemy = "foe_kobolds",
		hp = 100, coins = 2, base = 5, coinPower = 3, temper = "quick",
		cause = "Killed by a kobold tunnel-boss",
		moves = {
			{ id = "pick", name = "Pick", text = "swings a crystal-tipped pick at your knees", power = 6, weight = 10 },
			{ id = "cave_in", name = "Cave-in", text = "kicks out a prop, and the tunnel roof comes down on you", power = 5, weight = 6, target = "all", status = "tremor" },
		},
		phases = { { at = 0.4, line = "It whistles. The walls are full of kobolds.", base = 1, power = 2, moves = { { id = "swarm", name = "The Whole Shift", text = "sends every miner in the seam at you", power = 6, weight = 8, target = "all" } } } },
		barks = { start = { "*a whistle and the clatter of picks*" }, hurt = { "*a yelp*" }, phase = { "*the walls answer*" } },
	},

	-- ── D ──
	bone_captain = {
		name = "Bone Captain", title = "What a crypt Gate's guardroom keeps", enemy = "foe_undead_low",
		hp = 160, coins = 2, base = 9, coinPower = 4, temper = "cunning",
		cause = "Killed by a bone captain",
		moves = {
			{ id = "blade", name = "Notched Blade", text = "cuts with a sword that has killed a great many people", power = 9, weight = 10 },
			{ id = "rank", name = "Fall In", text = "raps its shield, and the skeletons lock into a line", power = 5, weight = 6, target = "all", status = "tremor" },
		},
		phases = { { at = 0.4, line = "The captain's bones pull themselves back together, a little wrong.", base = 2, power = 2 } },
		barks = { start = { "*bones rattling into line*" }, hurt = { "*a dry crack*" }, phase = { "*it stands up again*" } },
	},

	-- ── C ──
	elf_huntmaster = {
		name = "Forest Elf Huntmaster", title = "Boss of a forest Gate", enemy = "foe_forest_elves",
		hp = 230, coins = 3, base = 14, coinPower = 5, temper = "quick",
		cause = "Killed by a forest elf huntmaster",
		moves = {
			{ id = "arrow", name = "Heartseeker", text = "looses an arrow you only hear after it hits", power = 14, weight = 10, status = "bleed" },
			{ id = "volley", name = "Canopy Volley", text = "and the rangers in the trees fill the clearing with arrows", power = 7, weight = 6, target = "all" },
		},
		phases = { { at = 0.4, line = "The huntmaster drops the bow and draws two blades.", base = 3, power = 3, moves = { { id = "twin", name = "Twin Blades", text = "comes out of the trees with a blade in each hand", power = 12, weight = 8, status = "bleed" } } } },
		barks = { start = { "*a bowstring, somewhere above*" }, hurt = { "*a hiss through teeth*" }, phase = { "*leaves falling*" } },
	},

	-- ── B ──
	forge_lord = {
		name = "Forge-Lord of the Deep Hall", title = "Boss of a dwarven hall", enemy = "foe_dwarves",
		hp = 370, coins = 3, base = 24, coinPower = 6, temper = "brute",
		cause = "Killed by a dwarf forge-lord",
		moves = {
			{ id = "hammer", name = "Forge Hammer", text = "brings down a hammer that glows like a furnace", power = 20, weight = 10, heavy = true, status = "burn" },
			{ id = "wall", name = "Shield Wall", text = "and its axe-guards lock shields and drive forward", power = 10, weight = 6, target = "all", status = "tremor" },
		},
		phases = { { at = 0.4, line = "The forge-lord strikes the floor. The runes along the walls catch fire.", base = 4, power = 4, moves = { { id = "fire", name = "Rune-fire", text = "sets the whole hall burning", power = 13, weight = 7, target = "all", status = "burn" } } } },
		barks = { start = { "*silence, and an anvil ringing*" }, hurt = { "*a grunt behind the beard*" }, phase = { "*the forge roars*" } },
	},

	-- ── A ──
	ice_elf_warchief = {
		name = "Ice Elf Warchief", title = "What leads the hunt in a frozen Gate", enemy = "foe_ice_elves",
		hp = 620, coins = 4, base = 27, coinPower = 8, temper = "quick",
		cause = "Killed by an ice elf warchief",
		moves = {
			{ id = "axe", name = "Ice Axe", text = "swings an axe of blue ice in a flat, terrible arc", power = 28, weight = 10, status = "bleed" },
			{ id = "hunt", name = "The Hunt", text = "calls, and its hunters come out of the snow at all of you", power = 15, weight = 6, target = "all" },
		},
		phases = { { at = 0.4, line = "The warchief breathes on its axe, and frost runs up its arms.", base = 6, power = 6, moves = { { id = "nova", name = "Winter", text = "freezes the air in the whole cavern", power = 20, weight = 8, target = "all", status = "sinking" } } } },
		barks = { start = { "*the snow goes quiet*" }, hurt = { "*a word you don't know*" }, phase = { "*the cold deepens*" } },
	},
	hive_matron = {
		name = "Hive Matron", title = "What sits at the heart of an ant Gate", enemy = "foe_ants",
		hp = 640, coins = 4, base = 26, coinPower = 8, temper = "brute",
		cause = "Killed by a hive matron",
		moves = {
			{ id = "mandibles", name = "Mandibles", text = "closes mandibles that shear through armour", power = 29, weight = 10, heavy = true },
			{ id = "acid", name = "Acid Rain", text = "sprays acid across the whole nest chamber", power = 15, weight = 6, target = "all", status = "rupture" },
		},
		phases = { { at = 0.45, line = "The chamber walls open. Her guards come out of them.", base = 6, power = 6, moves = { { id = "guards", name = "Royal Guard", text = "sends her plated guards in", power = 21, weight = 8, target = "all", status = "bleed" } } } },
		barks = { start = { "*a sound like a thousand legs on stone*" }, hurt = { "*a shrill clicking*" }, phase = { "*the nest answers*" } },
	},
	dark_matriarch = {
		name = "Dark Elf Matriarch", title = "What rules a lightless Red Gate", enemy = "foe_dark_elves",
		hp = 600, coins = 4, base = 26, coinPower = 8, temper = "cunning",
		cause = "Taken by a dark elf matriarch in a Red Gate",
		moves = {
			{ id = "drain", name = "Drain", text = "draws the warmth out of you across the room", power = 26, weight = 10, status = "sinking" },
			{ id = "spiders", name = "Her Children", text = "lets her phase spiders loose among you", power = 15, weight = 6, target = "all", status = "bleed" },
		},
		phases = { { at = 0.4, line = "The torches go out. Only her eyes are left.", base = 6, power = 6 } },
		barks = { start = { "*a whisper behind you*" }, hurt = { "*a laugh, then not*" }, phase = { "*the dark comes in*" } },
	},

	-- ── S ──
	frost_jarl = {
		name = "Frost Giant Jarl", title = "Boss of a frozen S-rank Gate", enemy = "foe_giants",
		hp = 1080, coins = 4, base = 55, coinPower = 11, temper = "brute",
		cause = "Killed by a frost giant jarl",
		moves = {
			{ id = "axe", name = "Glacier Axe", text = "brings down an axe the size of a lorry", power = 44, weight = 10, heavy = true, status = "tremor" },
			{ id = "breath", name = "Winter's Breath", text = "breathes, and the whole field freezes", power = 25, weight = 6, target = "all", status = "sinking" },
		},
		phases = {
			{ at = 0.55, line = "The jarl roars, and its kin answer from the mountains.", base = 6, power = 6 },
			{ at = 0.25, line = "The jarl tears the frozen ground up in slabs.", base = 8, power = 8, moves = { { id = "avalanche", name = "Avalanche", text = "brings the mountainside down on everyone", power = 33, weight = 9, target = "all", status = "tremor" } } },
		},
		barks = { start = { "*footsteps you feel through the floor*" }, hurt = { "*a bellow that cracks the ice*" }, phase = { "*it stands taller*" } },
	},
	lich_archivist = {
		name = "The Lich of the Sunken Archive", title = "What waits at the bottom of a drowned crypt", enemy = "foe_undead_high",
		hp = 1000, coins = 4, base = 54, coinPower = 11, temper = "cunning",
		cause = "Unmade by a lich",
		moves = {
			{ id = "word", name = "Word of Ending", text = "speaks one word, and your strength goes out like a candle", power = 42, weight = 10, status = "sinking" },
			{ id = "raise", name = "Raise the Knights", text = "lifts a hand, and its grave knights stand up out of the water", power = 24, weight = 6, target = "all" },
		},
		phases = {
			{ at = 0.5, line = "The lich's crown burns blue. The water freezes solid.", base = 7, power = 7, moves = { { id = "frost", name = "Black Frost", text = "freezes the archive and everyone in it", power = 28, weight = 7, target = "all", status = "sinking" } } },
			{ at = 0.2, line = "It opens a book that should not be opened.", base = 8, power = 8 },
		},
		barks = { start = { "*pages turning, in the dark*" }, hurt = { "*a dry, cold laugh*" }, phase = { "*the crown burns*" } },
	},
	demon_noble = {
		name = "Demon Noble", title = "What commands a demon Gate's host", enemy = "foe_demons",
		hp = 1100, coins = 4, base = 55, coinPower = 11, temper = "brute",
		cause = "Killed by a demon noble",
		moves = {
			{ id = "sword", name = "Burning Greatsword", text = "swings a greatsword wrapped in fire", power = 44, weight = 10, heavy = true, status = "burn" },
			{ id = "host", name = "The Host", text = "points, and its soldiers come on in ranks", power = 25, weight = 6, target = "all" },
		},
		phases = {
			{ at = 0.55, line = "Its wings open. The banners in the hall catch fire.", base = 6, power = 6 },
			{ at = 0.25, line = "It calls the sky down.", base = 8, power = 8, moves = { { id = "meteor", name = "Meteor", text = "drops burning stone on all of you", power = 34, weight = 9, target = "all", status = "burn" } } },
		},
		barks = { start = { "*iron, fire, and a horn*" }, hurt = { "*a roar of pure contempt*" }, phase = { "*the sky goes red*" } },
	},
}

return BOSSES
