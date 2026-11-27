--[[
	BOSSES FOR TURN-BASED BATTLES (v0.16; Engine/Battle.luau). An event choice with
	`battle = "<id>"` fights one of these over several turns instead of one clash.

	  name, title, enemy    who it is, and the foe whose look it wears (Foes.luau)
	  hp                    Health for one fighter (each friend who joins adds 60% more)
	  coins, base, coinPower, temper   what a strike has to beat when the move is aimed at you
	  moves                 { id, name, text, power, weight, target = "one" | "all", heavy,
	                          base / coins / coinPower (harder to clash against), condition }
	                        `power` is the Health it takes before the City's lethality
	  phases                { at = share of Health left, line, base, coinPower, power, moves }
	  barks                 start / hurt / phase lines
	  cause                 what a fighter it kills died of
]]

return {
	-- ── the Thumb ─────────────────────────────────────────────────────────────
	capo_brandimarte = {
		name = "Capo Aurelio Brandimarte", title = "Capo of the Thumb", enemy = "thumb_capo",
		hp = 170, coins = 3, base = 8, coinPower = 3, temper = "cunning",
		cause = "Shot by Capo Brandimarte of the Thumb",
		moves = {
			{ id = "round", name = "Propellant Round", text = "loads one round, and fires it", power = 9, weight = 10, condition = "burns" },
			{ id = "manners", name = "A Lesson in Manners", text = "corrects your posture with the revolver's butt", power = 6, weight = 8 },
			{ id = "salute", name = "Three-Round Salute", text = "fires three rounds, one for each of you", power = 7, weight = 5, target = "all" },
		},
		phases = {
			{ at = 0.5, line = "Brandimarte loosens his tie. \"Enough etiquette.\" He loads two rounds at once.", base = 1, power = 2,
				moves = { { id = "double", name = "Two Rounds, One Breath", text = "fires two propellant rounds, point blank", power = 13, weight = 8, heavy = true, base = 2, condition = "propellant_scar" } } },
		},
		barks = { start = { "Kneel, and this goes quickly." }, hurt = { "You have no manners. But you have something.", "Again, then." }, phase = { "Enough etiquette!" } },
	},
	sottocapo_ferrante = {
		name = "Sottocapo Lucrezia Ferrante", title = "Sottocapo of the Thumb", enemy = "thumb_capo",
		hp = 265, coins = 3, base = 9, coinPower = 4, temper = "cunning",
		cause = "Answered for a Capo, to the Sottocapo of the Thumb",
		moves = {
			{ id = "cut", name = "Propellant Cut", text = "swings, and the charge in the guard drives the blade", power = 10, weight = 10, condition = "burns" },
			{ id = "bow", name = "The Correct Bow", text = "bows exactly as deep as the Manual says, and steps in", power = 7, weight = 7 },
			{ id = "sweep", name = "Sweep the Room", text = "turns in a full circle, blade out", power = 8, weight = 5, target = "all" },
		},
		phases = {
			{ at = 0.6, line = "Ferrante fires the charge in her guard. The blade glows like a furnace door.", base = 1, power = 2,
				moves = { { id = "furnace", name = "Furnace Door", text = "brings the burning blade down", power = 14, weight = 8, heavy = true, base = 2, condition = "burns" } } },
			{ at = 0.25, line = "\"I will not lose to someone without a title.\" She stops bowing.", base = 2, coinPower = 1, power = 3,
				moves = { { id = "no_title", name = "Without a Title", text = "stops bowing and simply kills", power = 18, weight = 6, heavy = true, base = 3, coins = 1 } } },
		},
		barks = { start = { "Etiquette demands an answer. I am the answer." }, hurt = { "Correct form. Incorrect result.", "Hm." }, phase = { "Page one thousand four hundred and two." } },
	},

	-- ── the Middle ────────────────────────────────────────────────────────────
	big_brother_ugo = {
		name = "Big Brother Ugo", title = "Big Brother of the Middle", enemy = "middle_big",
		hp = 195, coins = 3, base = 8, coinPower = 3, temper = "brute",
		cause = "Settled by Big Brother Ugo of the Middle",
		moves = {
			{ id = "chain", name = "Chain Swing", text = "swings the chain twice round and lets it go", power = 9, weight = 10, condition = "broken_ribs" },
			{ id = "embrace", name = "Family Embrace", text = "hugs you, hard enough to creak", power = 7, weight = 7 },
			{ id = "siblings", name = "Little Ones!", text = "calls the Little Siblings in to help", power = 6, weight = 5, target = "all" },
		},
		phases = {
			{ at = 0.5, line = "Ugo hands the Book to a Little Sister. \"Write this down. Title 1.\" He takes off his coat.", base = 1, power = 2,
				moves = { { id = "title_one", name = "Title 1, Section 1", text = "brings the whole chain down at once", power = 14, weight = 8, heavy = true, base = 2, condition = "broken_ribs" } } },
		},
		barks = { start = { "You hurt my little ones. That's a new Line." }, hurt = { "Good! Good. The Book likes a fight.", "Ha!" }, phase = { "Title 1, sibling!" } },
	},
	big_sister_orsola = {
		name = "Big Sister Orsola", title = "Big Sister of the Middle", enemy = "middle_big",
		hp = 170, coins = 3, base = 8, coinPower = 3, temper = "brute",
		cause = "Paid a debt to the Middle in full",
		moves = {
			{ id = "chain", name = "Chain Lash", text = "lashes out with the chain on her arm", power = 9, weight = 10 },
			{ id = "read", name = "Read the Line Aloud", text = "reads your Line aloud, and every word lands", power = 6, weight = 6 },
		},
		phases = {
			{ at = 0.5, line = "Orsola closes the Book. \"Let's do this the old way.\"", base = 1, power = 2,
				moves = { { id = "old_way", name = "The Old Way", text = "wraps the chain round both fists", power = 13, weight = 8, heavy = true, base = 2 } } },
		},
		barks = { start = { "Title 3, Section 4. Don't take it personally." }, hurt = { "Ooh. That's going in the Book." } },
	},

	-- ── the Index ─────────────────────────────────────────────────────────────
	proxy_sereno = {
		name = "Proxy Sereno", title = "Proxy of the Index", enemy = "index_proxy",
		hp = 185, coins = 3, base = 8, coinPower = 3, temper = "quick",
		cause = "Cut down at step ten of a Prescript",
		moves = {
			{ id = "step", name = "Step Ten", text = "performs step ten, exactly as written", power = 9, weight = 10, condition = "deep_cut" },
			{ id = "read", name = "Rereads the Slip", text = "rereads the Prescript, and moves as if he already knew", power = 6, weight = 6 },
			{ id = "cuts", name = "Steps Eleven and Twelve", text = "two cuts, one for each of you", power = 7, weight = 5, target = "all" },
		},
		phases = {
			{ at = 0.5, line = "Sereno folds the slip away. \"Step thirteen is not written. I will improvise.\"", base = 1, coinPower = 1, power = 2,
				moves = { { id = "unwritten", name = "The Unwritten Step", text = "does something no Prescript has ever asked of him", power = 14, weight = 8, heavy = true, base = 2, condition = "deep_cut" } } },
		},
		barks = { start = { "It is not personal. It is written." }, hurt = { "That was not on the slip.", "Interesting." }, phase = { "Step thirteen." } },
	},

	-- ── the Ring ──────────────────────────────────────────────────────────────
	docent_amadeo = {
		name = "Docent Amadeo", title = "Docent of the Ring", enemy = "ring_docent",
		hp = 170, coins = 3, base = 8, coinPower = 3, temper = "quick",
		cause = "Made into a piece by a Docent of the Ring",
		moves = {
			{ id = "stroke", name = "Broad Stroke", text = "sweeps the long brush across you like a blade", power = 9, weight = 10, condition = "deep_cut" },
			{ id = "study", name = "A Study", text = "circles you, sketching, and strikes where the light falls", power = 7, weight = 7 },
			{ id = "palette", name = "The Whole Palette", text = "flings every colour at once", power = 7, weight = 5, target = "all" },
		},
		phases = {
			{ at = 0.5, line = "Amadeo laughs with real joy. \"You're fighting back! The composition changes!\"", base = 1, power = 2,
				moves = { { id = "masterwork", name = "Masterwork", text = "begins his masterpiece, on you", power = 14, weight = 8, heavy = true, base = 2, condition = "deep_cut" } } },
		},
		barks = { start = { "Art is what's left when you take away everything that isn't." }, hurt = { "Wonderful! Again!", "That line was perfect." }, phase = { "The composition changes!" } },
	},

	-- ── the Kurokumo Clan ─────────────────────────────────────────────────────
	captain_sayo = {
		name = "Captain Sayo", title = "Captain of the Kurokumo Clan", enemy = "kurokumo",
		hp = 160, coins = 3, base = 9, coinPower = 3, temper = "quick",
		cause = "Drew against a Captain of the Kurokumo Clan",
		moves = {
			{ id = "draw", name = "The Draw", text = "draws and sheathes before you see it", power = 10, weight = 10, condition = "deep_cut" },
			{ id = "feint", name = "Feint", text = "moves her hand, and doesn't draw, and you flinch", power = 5, weight = 6 },
		},
		phases = {
			{ at = 0.5, line = "Sayo lets her coat fall from her shoulders. She has stopped being bored.", base = 1, coinPower = 1, power = 2,
				moves = { { id = "one_draw", name = "One Draw", text = "the draw she keeps for people worth it", power = 15, weight = 7, heavy = true, base = 2 } } },
		},
		barks = { start = { "You've ruined my evening. Draw." }, hurt = { "Hm.", "Better than my Wakashu." }, phase = { "Now I'm interested." } },
	},

	-- ── R Corp ────────────────────────────────────────────────────────────────
	rcorp_rhino = {
		name = "The Rhino", title = "R Corp heavy unit", enemy = "rcorp_rhino",
		hp = 230, coins = 3, base = 8, coinPower = 4, temper = "brute",
		cause = "Charged down by R Corp's Rhino",
		moves = {
			{ id = "charge", name = "Charge", text = "lowers its head and comes through", power = 11, weight = 10, condition = "broken_ribs" },
			{ id = "hammer", name = "Hammer", text = "brings the hammer off its back", power = 9, weight = 8 },
			{ id = "quake", name = "Stamp", text = "stamps, and the street shakes everyone off their feet", power = 6, weight = 5, target = "all" },
		},
		phases = {
			{ at = 0.5, line = "The Rhino's armour vents steam. \"Rhino engaging, full output.\"", base = 1, power = 3,
				moves = { { id = "full", name = "Full Output", text = "charges at full output, through a wall to get to you", power = 15, weight = 8, heavy = true, base = 2, condition = "broken_ribs" } } },
		},
		barks = { start = { "Hostile confirmed. Rhino engaging." }, hurt = { "Damage noted.", "Continuing." }, phase = { "Full output." } },
	},

	-- ── Distortions ───────────────────────────────────────────────────────────
	the_bellringer = {
		name = "The Bellringer", title = "A Distortion", enemy = "distortion",
		hp = 185, coins = 3, base = 8, coinPower = 3, temper = "brute",
		cause = "Rung silent by the Bellringer",
		moves = {
			{ id = "peal", name = "Peal", text = "rings, and the sound hits like a hammer", power = 8, weight = 10, condition = "ringing" },
			{ id = "toll", name = "Toll for Everyone", text = "every bell swings at once", power = 7, weight = 6, target = "all", condition = "ringing" },
			{ id = "take", name = "Takes a Word", text = "takes the last thing you said, and the strength with it", power = 6, weight = 5 },
		},
		phases = {
			{ at = 0.5, line = "The great bell at its heart begins to swing.", base = 1, power = 2,
				moves = { { id = "great_bell", name = "The Great Bell", text = "rings the great bell", power = 13, weight = 8, heavy = true, base = 2, target = "all", condition = "ringing" } } },
		},
		barks = { start = { "Say something. Anything. I'll keep it for you." }, hurt = { "Ring. Ring. Ring.", "That was a good word." }, phase = { "LISTEN." } },
	},
	the_hostess = {
		name = "The Hostess", title = "A Distortion", enemy = "distortion",
		hp = 185, coins = 3, base = 8, coinPower = 3, temper = "cunning",
		cause = "Kept forever at the Hostess's party",
		moves = {
			{ id = "thread", name = "A Thread", text = "finds your wrist with a thread, and pulls", power = 8, weight = 10 },
			{ id = "dance", name = "One More Dance", text = "makes the whole room dance, whether it wants to or not", power = 7, weight = 6, target = "all" },
			{ id = "guests", name = "The Guests", text = "sends a guest to take your hand", power = 6, weight = 5 },
		},
		phases = {
			{ at = 0.5, line = "The Hostess lowers herself from the ceiling, smiling, every thread taut.", base = 1, power = 2,
				moves = { { id = "never_ends", name = "It Never Ends", text = "draws every thread at once", power = 13, weight = 8, heavy = true, base = 2 } } },
		},
		barks = { start = { "Stay. Everyone stays." }, hurt = { "You're ruining the party!", "Don't go. Don't go." }, phase = { "The party never has to end." } },
	},
	teodor_distorted = {
		name = "What Teodor Became", title = "A Distortion", enemy = "distortion",
		hp = 170, coins = 3, base = 8, coinPower = 3, temper = "brute",
		cause = "Killed by a friend who had Distorted",
		moves = {
			{ id = "hands", name = "Clock Hands", text = "sweeps the long clock hands across the street", power = 9, weight = 10, condition = "deep_cut" },
			{ id = "time", name = "Stopped Time", text = "stops the clocks, and you with them", power = 6, weight = 6 },
		},
		phases = {
			{ at = 0.5, line = "For a moment it looks at you with Teodor's face. Then every clock on the block strikes at once.", base = 1, power = 2,
				moves = { { id = "strike", name = "Every Clock Strikes", text = "strikes the hour with everything it has", power = 13, weight = 8, heavy = true, base = 2, target = "all" } } },
		},
		barks = { start = { "Listen. It's thinking about you." }, hurt = { "Tick.", "It's nine. Do you remember being nine?" }, phase = { "Every clock." } },
	},

	-- ── the pit ───────────────────────────────────────────────────────────────
	the_ox = {
		name = "The Ox", title = "Champion of the pit", enemy = "workshop_brute",
		hp = 185, coins = 3, base = 8, coinPower = 3, temper = "brute",
		cause = "Fought the champion of a fighting pit",
		moves = {
			{ id = "hook", name = "The Hook", text = "throws the hook that ended forty fights", power = 9, weight = 10, condition = "broken_ribs" },
			{ id = "clinch", name = "Clinch", text = "wraps you up and leans on you", power = 6, weight = 6 },
		},
		phases = {
			{ at = 0.5, line = "The Ox grins for the first time in four years. The crowd goes silent.", base = 1, power = 2,
				moves = { { id = "everything", name = "Everything He Has", text = "stops holding back", power = 13, weight = 8, heavy = true, base = 2, condition = "broken_ribs" } } },
		},
		barks = { start = { "Good luck. I mean that." }, hurt = { "Ha! Good one.", "Again." }, phase = { "Alright. Alright!" } },
	},
}
