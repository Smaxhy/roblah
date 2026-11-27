--[[
	Expeditions of the Library and Distortion eras. Writer D (lib_ / lim_ ids).
	  lib_reception_crew  The Library, 979-982: a crew takes one invitation in together.
	                      Opened by an invitation's "Find a crew" or by signing on with the
	                      Bookhunters (flag lib_crew_invited). Losing the last act makes books.
	  lim_bough_dig       A Before Team dig into a buried L Corp branch for a Golden Bough.
	                      Opened by contact with the LCCB (flag lim_lccb_contact).
	Format: docs/CONTENT_GUIDE.md (Expeditions). Tokens: {crew}, {crewNames}, {champion}.
]]

return {
	order = { "lib_reception_crew", "lim_bough_dig" },

	lib_reception_crew = {
		name = "A Reception, as a Crew",
		kind = "dungeon",
		desc = "One invitation, a crew to share it. The Library likes crews: more books. Sign it together and the Library takes you all at once. Win, and every one of you is sent home with a book. Lose, and every one of you becomes one. The only way out is not signing.",
		minAge = 16,
		cooldown = 99,
		crew = { min = 1, max = 4 },
		length = 4,
		when = { world = { era = "library" }, flags = { "lib_crew_invited" } },
		start = "door",
		stages = {
			door = {
				title = "The Pen",
				text = "One invitation on the table, a line at the bottom for every name. Everybody knows how it works: write yours and you are taken, from wherever you stand, and nobody has found the place by walking. The room is very quiet. Last chance to change your minds.",
				tone = "strange",
				choices = {
					{ label = "Sign, one after another", next = "stacks", result = { codex = "lib_roland", log = "{crew} signed in turn, and the room emptied a chair at a time. Then an entrance hall that smelled of old paper, and a tired man in a black suit counting heads. \"Roland. Assistant. A crew, is it? She likes crews.\" He didn't say why. \"Natural Sciences. Up the stairs.\"" } },
					{ label = "Put the pen down", ["end"] = "retreat", result = { log = "{crew} looked at the line for a long time, and nobody wrote on it." } },
				},
			},
			stacks = {
				title = "The Assistant Librarians",
				text = "The Floor of Natural Sciences is all glass cases and green light, and between the shelves the Assistant Librarians are waiting, four of them, smiling politely. The first act of the reception begins without anyone saying so.",
				tone = "danger",
				choices = {
					{
						label = "Fight through the assistants",
						clash = { stat = "strength", foe = "The Assistant Librarians", coins = 2, base = 5, coinPower = 3, fight = true, status = "charge" },
						win = { strength = 1, log = "{champion} broke the assistants' line, and {crew} pushed through to the center of the Floor." },
						lose = { health = { -8, -3 }, sanity = -3, log = "The assistants drove {crew} back between the shelves." },
						winNext = "twins",
						loseNext = "pushed_back",
					},
					{
						label = "Hold together and outlast them",
						clash = { stat = "health", foe = "The Assistant Librarians", coins = 2, base = 5, coinPower = 3, fight = true, status = "charge" },
						win = { health = 1, log = "{crew} held together until the assistants gave ground, one by one." },
						lose = { health = { -8, -3 }, sanity = -3, log = "{crew} held as long as anyone could. Then the line broke." },
						winNext = "twins",
						loseNext = "pushed_back",
					},
				},
			},
			pushed_back = {
				title = "Pushed Back to the Stairs",
				text = "{crew} ends up against the top of the stairs, bruised, with the assistants closing in very politely. The stairs go down to a hall with no door in it. Up ahead, the Floor is waiting.",
				tone = "danger",
				choices = {
					{
						label = "Regroup and go again",
						clash = { stat = "health", foe = "The Assistant Librarians", coins = 2, base = 5, coinPower = 3, fight = true, status = "charge" },
						win = { log = "{champion} rallied everyone, and {crew} went back in, and this time the assistants gave way." },
						lose = { die = "Became a book on the Floor of Natural Sciences", chronicle = "became_book", log = "The assistants closed over {crew} the way a cover closes. There are new spines on the shelf, in order of height." },
						winNext = "twins",
						loseEnd = "fail",
					},
					{
						label = "Go back in behind your best",
						clash = { stat = "strength", foe = "The Assistant Librarians", coins = 2, base = 5, coinPower = 3, fight = true, status = "charge" },
						win = { log = "{champion} went first and didn't stop, and the assistants folded, politely, to either side." },
						lose = { die = "Became a book on the Floor of Natural Sciences", chronicle = "became_book", log = "{champion} went first, and it wasn't enough. The Floor has a new row of books." },
						winNext = "twins",
						loseEnd = "fail",
					},
				},
			},
			twins = {
				title = "Tiphereth",
				text = "Two Patron Librarians step down from the Floor's high desk together: identical, except that one is scowling and one is smiling. \"Tiphereth,\" says the smiling one. \"Both of us,\" says the scowling one. This is the last act. Win it and you are sent home with books. Lose it and you stay as them.",
				tone = "danger",
				choices = {
					{
						label = "All of you, at once",
						hint = "The last act. Lose, and you all become books.",
						clash = { stat = "strength", foe = "Tiphereth, Patron Librarians of Natural Sciences", coins = 3, base = 6, coinPower = 3, fight = true, status = "poise" },
						win = { log = "The scowling twin fell first, and the smiling one stopped smiling, and then it was over. \"Fine,\" they said together. \"Take your books.\"" },
						lose = { die = "Became a book on the Floor of Natural Sciences", chronicle = "became_book", log = "The twins fought like one person with four hands. Afterward they shelved {crew} side by side, carefully, in order of height." },
						winEnd = "success",
						loseEnd = "fail",
					},
					{
						label = "Split them up",
						hint = "Intelligence. The last act. Lose, and you all become books.",
						clash = { stat = "intelligence", foe = "Tiphereth, apart", coins = 3, base = 5, coinPower = 3, fight = true, status = "poise" },
						win = { log = "{champion} drew the scowling one off into the stacks, and apart, the twins were only very, very good. It was enough." },
						lose = { die = "Became a book on the Floor of Natural Sciences", chronicle = "became_book", log = "The twins were never apart, not really. Two books for each of them, and new spines on the shelf for {crew}." },
						winEnd = "success",
						loseEnd = "fail",
					},
				},
			},
		},
		success = {
			wage = { 300, 700 },
			gear = "lib_library_book",
			addTrait = "library_guest",
			setFlags = { "library_survivor", "lib_book_owner", "lib_won_reception" },
			chronicle = "won_reception",
			codex = { "lib_receptions", "lib_patron_librarians" },
			schedule = { event = "lib_book_you_took", inYears = 1 },
			log = "At dawn {crew} were back in the room where they had signed, every one of {crew} carrying a book with a gilt spine. The last thing anyone heard in the Library was Roland saying, \"Huh.\"",
		},
		fail = { log = "The Floor of Natural Sciences has new spines on its shelves." },
		retreat = { sanity = -1, log = "The invitation went back in its envelope, unsigned, and by morning it was blank. {crew} went home alive and empty-handed, which in the Library era counts as a good night." },
	},

	lim_bough_dig = {
		name = "A Golden Bough Dig",
		kind = "mission",
		desc = "A Before Team dig into a buried L Corp branch, after a Golden Bough. The map is in three colors of pencil. Two of them are wrong.",
		minAge = 18,
		cooldown = 3,
		crew = { min = 1, max = 4 },
		length = 5,
		when = { world = { era = "limbus" }, flags = { "lim_lccb_contact" } },
		start = "shaft",
		stages = {
			shaft = {
				title = "The Access Shaft",
				text = "An LCCB access shaft under a District street: a winch, a ladder, and a draft coming up from below that smells of old Enkephalin, green and sweet. Down there is a branch L Corp buried when it fell. Somewhere in it, the scouts think, a Bough.",
				choices = {
					{ label = "Climb down", next = "units", result = { log = "{crew} climbed down into the dark, one lamp each." } },
					{
						label = "Lower a lamp first and read the dark",
						clash = { stat = "mind", foe = "What the lamp shows", coins = 2, base = 4, coinPower = 3 },
						win = { mind = 1, log = "{champion} read the shadows and picked the safe side of every corridor before anyone set foot in it." },
						lose = { sanity = -2, log = "The lamp went out halfway down. {crew} climbed down anyway, slower." },
						next = "units",
					},
					{ label = "Leave it to the professionals", ["end"] = "retreat", result = { log = "{crew} decided the professionals could have it." } },
				},
			},
			units = {
				title = "Containment Units",
				text = "Old L Corp containment units line the corridor, their doors hanging open, their nameplates scratched off. In one of them, alone on the floor, sits an egg: pale, whole, and the size of a child. It has a faint, patient warmth to it.",
				tone = "strange",
				choices = {
					{ label = "Leave the egg alone", next = "bough", result = { log = "{crew} walked past the egg very quietly. It didn't move. Probably." } },
					{ label = "Mark it for the LCE", next = "bough", result = { mind = 1, codex = "lcorp_abnormalities", log = "{crew} chalked the door: ABNORMALITY EGG, DO NOT DISTURB, LCE ONLY. The LCE pays a bounty for those." } },
					{
						label = "Carry it out",
						clash = { stat = "intelligence", foe = "A very heavy, very warm egg", coins = 2, base = 5, coinPower = 3 },
						win = { wage = { 80, 200 }, log = "{champion} carried it like a sleeping child all the way to the winch. The LCE paid well, and asked very carefully if anyone had talked to it." },
						lose = { health = { -8, -3 }, sanity = -4, log = "Halfway down the corridor the egg cracked, just slightly, and something inside looked out. {crew} put it down very carefully and backed away." },
						next = "bough",
					},
				},
			},
			bough = {
				title = "The Gold Light",
				text = "At the end of the lowest corridor, gold light spills under a door. Between {crew} and the door, Peccatula have grown up through the floor tiles: thin, branch-like things with cracks of red light, Class 2, turning slowly to face the lamps.",
				tone = "danger",
				choices = {
					{
						label = "Cut a path to the door",
						clash = { stat = "strength", foe = "Peccatula Irae, Class 2", coins = 2, base = 5, coinPower = 3, fight = true, status = "rupture" },
						win = { strength = 1, log = "{champion} cut a path through the red cracks, and {crew} reached the door." },
						lose = { health = { -10, -4 }, sanity = -3, log = "The branches closed around {crew} like a hand." },
						winNext = "resonance",
						loseNext = "pinned",
					},
					{
						label = "Find the vent they grow from and choke it",
						clash = { stat = "intelligence", foe = "Peccatula Irae, Class 2", coins = 2, base = 5, coinPower = 3 },
						win = { intelligence = 1, log = "{champion} found the vent feeding them and jammed it shut. The red cracks dimmed, one by one, and {crew} walked through." },
						lose = { sanity = -3, log = "There was no vent, or there were twenty. The branches turned to watch {crew} search." },
						winNext = "resonance",
						loseNext = "pinned",
					},
				},
			},
			pinned = {
				title = "Pinned Down",
				text = "{crew} is backed into a dead containment unit with the Peccatula filling the corridor outside. The winch is two levels up. The radio has one bar.",
				tone = "danger",
				choices = {
					{
						label = "Fight your way to the winch",
						clash = { stat = "health", foe = "A corridor full of branches", coins = 2, base = 5, coinPower = 3, fight = true, status = "rupture" },
						win = { log = "{champion} led the way, and {crew} reached the winch, battered, with the gold light still glowing behind." },
						lose = { health = { -8, -4 }, log = "{crew} reached the winch, just. Nobody was carrying anything gold." },
						winNext = "resonance",
						loseEnd = "fail",
					},
					{ label = "Radio the scouts", ["end"] = "retreat", result = { log = "The radio crackled, and someone with a very calm voice said, \"Stay where you are.\" Twenty minutes later an LCCB crew had cut the corridor clear with a winch and a great deal of swearing, and walked {crew} out." } },
				},
			},
			resonance = {
				title = "Resonance",
				text = "Behind the door, in the middle of an empty room, a twig of gold light grows out of nothing. The air hums. As {crew} steps closer the floor tilts, and for a moment everyone is somewhere else: inside one stranger's worst day, seeing it the way they did.",
				tone = "strange",
				choices = {
					{ label = "Hold on to the memory", next = "out", result = { addTrait = "lim_gold_eyes", condition = "lim_bough_echo", sanity = -3, log = "{crew} held on until it let go. Everyone came out of it knowing something about a stranger that nobody should know." } },
					{
						label = "Pull back and seal the Bough's case",
						clash = { stat = "mind", foe = "Someone else's memory", coins = 2, base = 4, coinPower = 3 },
						win = { mind = 2, log = "{champion} pulled everyone back out of it and sealed the Bough in its case without looking." },
						lose = { sanity = -5, condition = "lim_bough_echo", log = "It didn't let go when {crew} wanted it to. The case got sealed in the end, with shaking hands." },
						next = "out",
					},
				},
			},
			out = {
				title = "Up the Shaft",
				text = "The winch groans. Daylight, or what passes for it in the Backstreets, grows overhead. In the case, the Bough glows through the seams like something breathing.",
				choices = {
					{ label = "Climb out into the light", ["end"] = "success", result = { log = "{crew} climbed out with the case. The LCCB scouts waiting at the top went very quiet when they saw it." } },
				},
			},
		},
		success = { wage = { 200, 450 }, setFlags = { "lim_bough_seen", "lim_bough_found" }, chronicle = "lim_bough_found", codex = "lim_golden_boughs", log = "Limbus Company paid {crew} a dig bonus and took the Bough away in a sealed truck to Headquarters. Nobody would say what it's for." },
		fail = { health = { -8, -3 }, sanity = -5, cause = "Lost on a Golden Bough dig", log = "{crew} came up the shaft with nothing but bruises and the memory of gold light." },
		retreat = { sanity = -2, log = "{crew} came back up without the Bough. The scouts wrote it down and didn't blame anyone, out loud." },
	},

}
