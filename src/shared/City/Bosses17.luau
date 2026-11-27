--[[
	EXTREME BOSSES (v0.17): turn-based battles (Engine/Battle.luau) built for lives whose stats
	have gone past every ordinary limit: 250 to 400. Normal bosses have a base of 8 or 9; these
	have 19 to 25, five or six coins, Health in the thousands, three phases, and moves that hit
	for half a strong body's Health. Bring friends.

	The canon behind them: the Night in the Backstreets and its Sweepers; the Index's ranks
	(Proselyte, Proxy, Messenger) and its Prescripts; Hana's Colors, the strongest Fixers; Hana's
	threat grades up to Star of the City; the Head's Claws, sent where the City's rules are
	broken; L Corp's ALEPH-class Abnormalities and their breaches. Every one of these people
	and things is this game's own: no canon character appears.
	Fields as City/Bosses.luau. `hp` is for one fighter; every friend who joins adds 60%.
]]

return {
	night_sweepers = {
		name = "The Night's Sweepers", title = "the Night in the Backstreets", enemy = "sweeper",
		hp = 1100, coins = 5, base = 19, coinPower = 9, temper = "quick",
		cause = "Swept up in the Night",
		moves = {
			{ id = "hook", name = "Hook and Line", text = "hooks you from the dark and pulls", power = 38, weight = 10 },
			{ id = "sweep", name = "Sweep the Street", text = "come down the street in a line, all of them", power = 30, weight = 7, target = "all" },
			{ id = "collect", name = "The Collection", text = "close in from every side at once", power = 88, weight = 4, heavy = true, base = 3 },
		},
		phases = {
			{ at = 0.6, line = "More of them come out of the dark, as many as there were, and then more. The street lamps are going out one by one.", base = 2, power = 8,
				moves = { { id = "lamps", name = "Lamps Out", text = "put out the last lamp and come for whoever was under it", power = 60, weight = 6, base = 2 } } },
			{ at = 0.25, line = "The clock on the tower says 3:59. They don't slow down. They never slow down.", base = 3, coinPower = 1, power = 12,
				moves = { { id = "last_minute", name = "The Last Minute", text = "spend the last minute of the Night on you", power = 120, weight = 5, heavy = true, base = 4, coins = 1 } } },
		},
		barks = { start = { "(They don't speak. The hooks do.)" }, hurt = { "(One of them stops, looks at you, and goes on.)", "(The line closes up again.)" }, phase = { "(More of them, out of the dark.)" } },
	},

	index_messenger_ex = {
		name = "A Messenger of the Index", title = "carrying a Prescript with your name", enemy = "index_messenger",
		hp = 1300, coins = 5, base = 21, coinPower = 10, temper = "cunning",
		cause = "Delivered to, by a Messenger of the Index",
		moves = {
			{ id = "delivered", name = "The Prescript, Delivered", text = "reads the line and carries it out", power = 45, weight = 10 },
			{ id = "proxies", name = "Proxies Follow", text = "signals, and two Proxies step in from the street", power = 32, weight = 6, target = "all" },
			{ id = "written", name = "As It Was Written", text = "does exactly what the Prescript says, all of it", power = 100, weight = 4, heavy = true, base = 3 },
		},
		phases = {
			{ at = 0.6, line = "The Messenger turns the Prescript over. There's more on the back. \"Ah,\" it says. \"Thoroughly, then.\"", base = 2, power = 10,
				moves = { { id = "thoroughly", name = "Thoroughly", text = "carries out the back of the Prescript, too", power = 70, weight = 6, base = 2 } } },
			{ at = 0.25, line = "Unbound: the strength the Index keeps locked comes out of the Messenger all at once, and the street cracks under its feet.", base = 4, coinPower = 1, power = 14,
				moves = { { id = "unbound", name = "Unbound", text = "lets go of everything the Prescript kept locked", power = 130, weight = 5, heavy = true, base = 4, coins = 1 } } },
		},
		barks = { start = { "A letter. For you. It was always going to be for you." }, hurt = { "The Prescript did not mention this.", "Hm. Noted." }, phase = { "There's more on the back." } },
	},

	color_umber = {
		name = "The Umber Lantern", title = "a Color of the City", enemy = "color_umber",
		hp = 1600, coins = 6, base = 23, coinPower = 11, temper = "cunning",
		cause = "Ended by the Umber Lantern, a Color",
		moves = {
			{ id = "swing", name = "Lantern Swing", text = "swings the heavy lantern on its chain", power = 48, weight = 10 },
			{ id = "patience", name = "A Color's Patience", text = "waits for the one mistake, and takes it", power = 36, weight = 7, base = 2 },
			{ id = "light", name = "Umber Light", text = "opens the lantern's shutter on all of you", power = 80, weight = 4, heavy = true, target = "all", base = 2 },
		},
		phases = {
			{ at = 0.66, line = "The Lantern opens its shutter. The light inside is the color of old brass, and everything it touches slows.", base = 2, power = 10,
				moves = { { id = "slow_light", name = "Slow Light", text = "holds you in the lantern's light and steps in", power = 70, weight = 6, base = 2 } } },
			{ at = 0.33, line = "\"You're good,\" says the Umber Lantern. \"I'm better. That's all a Color is.\" The lantern goes out. That's worse.", base = 3, coinPower = 1, power = 14,
				moves = { { id = "last_contract", name = "The Last Contract", text = "finishes the contract the way it was taken: personally", power = 130, weight = 5, heavy = true, base = 4, coins = 1 } } },
		},
		barks = { start = { "Nothing personal. It's a contract, and I took it." }, hurt = { "There it is. That's why they paid so much.", "Good. Again." }, phase = { "Let's not waste the evening." } },
	},

	clocktower_distortion = {
		name = "The Stopped Clocktower", title = "a Distortion graded Star of the City", enemy = "clocktower",
		hp = 1800, coins = 5, base = 22, coinPower = 11, temper = "brute",
		cause = "Stopped, by the Clocktower",
		moves = {
			{ id = "strike", name = "Every Clock Strikes", text = "strikes every hour at once, and the sound is a wall", power = 40, weight = 8, target = "all" },
			{ id = "hands", name = "The Hands Come Round", text = "sweeps its iron hands across the square", power = 55, weight = 10 },
			{ id = "stopped", name = "Stopped Time", text = "stops the moment you're in, and keeps you in it", power = 110, weight = 4, heavy = true, base = 3 },
		},
		phases = {
			{ at = 0.6, line = "The Clocktower's face cracks. Behind it is another face, younger, and it's crying in ticks.", base = 2, power = 10,
				moves = { { id = "pendulum", name = "The Pendulum", text = "lets the great pendulum fall through the square", power = 75, weight = 6, base = 2 } } },
			{ at = 0.3, line = "Every clock in the District starts running backwards. For a moment you're nine years old, and then you're not, and it's still here.", base = 3, coinPower = 1, power = 14,
				moves = { { id = "midnight", name = "Midnight, Forever", text = "rings midnight, and holds it", power = 135, weight = 5, heavy = true, base = 4, coins = 1 } } },
		},
		barks = { start = { "(Every clock in the square strikes thirteen.)" }, hurt = { "(A gear the size of a door falls out of it, and it doesn't notice.)", "(It ticks faster.)" }, phase = { "(The clocks run backwards.)" } },
	},

	head_claw = {
		name = "A Claw of the Head", title = "sent where the City's rules are broken", enemy = "claw",
		hp = 2600, coins = 6, base = 27, coinPower = 13, temper = "cunning",
		cause = "Corrected by a Claw of the Head",
		moves = {
			{ id = "enforce", name = "Enforcement", text = "steps through your guard as if it weren't there", power = 60, weight = 10 },
			{ id = "taboo", name = "Taboo", text = "names what you've done, and everyone near you pays for it", power = 45, weight = 6, target = "all" },
			{ id = "verdict", name = "The Head's Verdict", text = "delivers the Head's verdict, in person", power = 140, weight = 4, heavy = true, base = 4 },
		},
		phases = {
			{ at = 0.6, line = "The Claw stops, and tilts its head, as if listening to someone far away. Then it takes off its gloves.", base = 2, power = 12,
				moves = { { id = "ungloved", name = "Ungloved", text = "uses its hands", power = 85, weight = 6, base = 3 } } },
			{ at = 0.3, line = "\"Interesting,\" says the Claw, which is the first thing it has said. The air around it bends.", base = 4, coinPower = 1, power = 16,
				moves = { { id = "correction", name = "Correction", text = "corrects you, the way the Head corrects the City", power = 150, weight = 5, heavy = true, base = 5, coins = 1 } } },
		},
		barks = { start = { "(It doesn't speak. It doesn't need to.)" }, hurt = { "(It looks at the wound with mild curiosity.)" }, phase = { "Interesting." } },
	},

	last_hunter = {
		name = "Aurek Thane, the Last Hunter", title = "who has hunted old blood for forty years", enemy = "legend_hunter",
		hp = 1400, coins = 5, base = 21, coinPower = 10, temper = "quick",
		cause = "Hunted down by Aurek Thane",
		moves = {
			{ id = "bolt", name = "Consecrated Bolt", text = "puts a bolt exactly where your blood is thinnest", power = 46, weight = 10 },
			{ id = "chain", name = "Chain Net", text = "throws a weighted net of chain over all of you", power = 30, weight = 6, target = "all" },
			{ id = "oath", name = "The Old Oath", text = "says the hunters' oath under his breath, and means every word", power = 105, weight = 4, heavy = true, base = 3 },
		},
		phases = {
			{ at = 0.6, line = "Thane drops the crossbow and draws the long knife his teacher gave him. \"Forty years,\" he says. \"I've been looking for you for forty years.\"", base = 2, power = 10,
				moves = { { id = "knife", name = "Teacher's Knife", text = "comes in close with his teacher's knife", power = 72, weight = 6, base = 2 } } },
			{ at = 0.25, line = "Thane is hurt and doesn't care. Neither did his teacher. Neither did hers.", base = 3, coinPower = 1, power = 14,
				moves = { { id = "last_oath", name = "The Last of the Oath", text = "spends everything he has left in one strike", power = 125, weight = 5, heavy = true, base = 4, coins = 1 } } },
		},
		barks = { start = { "The stories said you were old. They didn't say you'd be polite." }, hurt = { "Ha. They didn't lie about that either.", "Again." }, phase = { "Forty years." } },
	},

	aleph_breach = {
		name = "An ALEPH-class Breach", title = "out of containment", enemy = "aleph",
		hp = 1000, coins = 5, base = 18, coinPower = 8, temper = "brute",
		cause = "Lost in an ALEPH-class breach",
		moves = {
			{ id = "notice", name = "It Notices You", text = "turns all of its attention on the corridor", power = 28, weight = 8, target = "all" },
			{ id = "reach", name = "Containment Failure", text = "reaches through the wall where the wall used to be", power = 42, weight = 10 },
			{ id = "aleph", name = "ALEPH", text = "does the thing that got it classified", power = 88, weight = 4, heavy = true, base = 3 },
		},
		phases = {
			{ at = 0.6, line = "The facility's alarms change pitch. Somewhere a manager is shouting codes. It doesn't care about codes.", base = 2, power = 8,
				moves = { { id = "spread", name = "It Spreads", text = "fills the next department, and the next", power = 56, weight = 6, base = 2 } } },
			{ at = 0.25, line = "The lights go red. The Qliphoth meltdown counter on the wall reads a number nobody has seen before.", base = 2, coinPower = 1, power = 10,
				moves = { { id = "meltdown", name = "Meltdown", text = "takes the whole department with it", power = 100, weight = 5, heavy = true, base = 3 } } },
		},
		barks = { start = { "(The containment unit's door is open. It shouldn't be.)" }, hurt = { "(It flickers.)" }, phase = { "(The alarms change pitch.)" } },
	},
}
