--[[
	The Library era (979-982): invitations, receptions, books, and the first Distortions.
	Writer D (lib_ ids). Canon notes: docs/CANON.md sections 1.4, 6 and 9.1.

	How the chapter runs:
	  - lib_streets_talk (adults) and lib_tower_dare (children) open the era for most lives.
	  - "Ask around" schedules an invitation next year. Which Floor it names depends on who
	    you are (Strength and Intelligence). SIGNING it is accepting: the guest is taken to the
	    Library there and then, from wherever they stand, in whatever District (nobody walks to
	    the Library, and nobody can find it from outside). That Floor's reception is a real
	    fight. Lose and you become a book; win and you are set back down where you signed.
	    The way out is not signing: once the name is on the line there is no door behind you.
	  - "Keep your people close" schedules someone you love getting an invitation.
	  - "Find the man hiring porters" opens the Bookhunters, and the crew reception
	    (Expeditions/Limbus.luau: lib_reception_crew).
	  - Books won, bought or lost come back as lib_book_you_took / lib_loved_book.
]]

local ERA = { era = "library" }

-- the four Floors an invitation can name; each set of conditions excludes the others
local INVITES = {
	{ event = "lib_invite_history", inYears = 1 },
	{ event = "lib_invite_literature", inYears = 1 },
	{ event = "lib_invite_language", inYears = 1 },
	{ event = "lib_invite_general", inYears = 1 },
}

-- what a guest who wins a reception carries out (merged into each win result)
local function won(extra)
	local r = {
		gear = "lib_library_book",
		addTrait = "library_guest",
		setFlags = { "library_survivor", "lib_book_owner", "lib_won_reception" },
		chronicle = "won_reception",
		schedule = { event = "lib_book_you_took", inYears = 1 },
	}
	for k, v in extra do
		if k == "setFlags" then
			for _, f in v do
				table.insert(r.setFlags, f)
			end
		else
			r[k] = v
		end
	end
	return r
end

return {
	-- ── openers ──
	{
		id = "lib_streets_talk",
		title = "Talk of the Tower",
		text = "Every diner in {district} has a theory about the Library. A Fixer swears his whole office got invitations. A woman at the noodle stall says the guests who lose become books, and the books sell for more than the guests ever earned. A man in a good coat is hiring hands for a crew that means to sign one together. Nobody talks about anything else.",
		weight = 400,
		once = true,
		tags = { "library" },
		when = { world = ERA, minAge = 16 },
		codex = "library_tower",
		choices = {
			{
				label = "Ask around about the invitations",
				hint = "Somewhere, an envelope has your name on it.",
				result = { mind = 1, setFlags = { "lib_curious" }, codex = "lib_floors", schedule = INVITES, log = "You asked everyone who would talk. By the end of the month you knew the names of three Floors, and you had the strange feeling that somewhere an envelope was being addressed to you." },
			},
			{
				label = "Find the man hiring porters",
				result = { trigger = "lib_bookhunters", log = "You found the man in the good coat at the back of the diner, counting Ahn into envelopes." },
			},
			{
				label = "Keep your head down and your people close",
				result = { sanity = 2, relationBond = { kind = "all", amount = 4 }, schedule = { { event = "lib_sibling_invited", inYears = 1 }, { event = "lib_friend_invited", inYears = 1 } }, log = "You stopped listening to talk about invitations and started having dinner with the people you love more often. If the Library wanted someone from your life, it would have to get past you." },
			},
		},
	},
	{
		id = "lib_tower_dare",
		title = "The Envelope Dare",
		text = "The kids on your street have a new dare. Write your name on an envelope, leave it on the windowsill overnight, and the Library will send you an invitation. Nobody has actually done it. Everybody's cousin has.",
		weight = 400,
		once = true,
		tags = { "library" },
		when = { world = ERA, minAge = 8, maxAge = 15 },
		codex = "library_tower",
		choices = {
			{
				label = "Write your name",
				result = { sanity = -1, setFlags = { "lib_wrote_name" }, schedule = { event = "lib_child_letter", inYears = 5 }, log = "You wrote your name in your best handwriting and left the envelope on the sill. In the morning it was gone. You didn't tell anyone that part." },
			},
			{
				label = "Refuse. You know better.",
				result = { mind = 2, log = "You told them the Library wasn't a game. They called you a coward for a week. Then a girl two streets over stopped coming to school, and nobody did the dare again." },
			},
			{
				label = "Tell the grown-ups about the dare",
				result = { intelligence = 1, relationBond = { kind = "family", amount = 5 }, log = "You told the grown-ups. They didn't laugh. That night every windowsill on the street was cleared, and somebody's father nailed one of them shut." },
			},
		},
	},

	-- ── invitations (scheduled by "Ask around"; the Floor depends on who you are) ──
	{
		id = "lib_invite_history",
		title = "Floor of History",
		text = "The envelope is cream, heavy, and addressed to you in a hand you've never seen. Inside: an invitation to the Library, signed with a single A. In smaller print at the bottom, someone has added: Floor of History. \"Whatever you desire most is waiting in a book.\"",
		weight = 0,
		when = { world = ERA, minAge = 16, max = { strength = 59, intelligence = 61 } },
		codex = "library_invitations",
		choices = {
			{
				label = "Sign it",
				hint = "Signing takes you to the Library at once. A reception is a real fight. Lose, and you become a book.",
				result = { setFlags = { "lib_invited" }, trigger = "lib_reception_history", log = "You put on your best coat, sat down at the table, and signed your name on the line. The room closed around you like a cover." },
			},
			{
				label = "Burn it",
				result = { sanity = { 2, 4 }, setFlags = { "lib_invited", "lib_declined" }, log = "You burned it in the sink. The smoke smelled like old paper and lilies, and you opened every window." },
			},
			{
				label = "Keep it in a drawer",
				result = { mind = 2, setFlags = { "lib_invited", "kept_invitation" }, log = "You put it in a drawer, under the good spoons. Some nights you take it out and read the small print again." },
			},
			{
				label = "Find a crew to go in with",
				hint = "Opens an expedition: A Reception, as a Crew.",
				result = { setFlags = { "lib_invited", "lib_crew_invited" }, codex = "lib_bookhunters", log = "An invitation that names a Floor is worth a crew. Within a week three Bookhunters had offered to go in with you, and one of them seemed almost sane." },
			},
		},
	},
	{
		id = "lib_invite_literature",
		title = "Floor of Literature",
		text = "The envelope is cream and heavy, addressed to you in careful, apologetic handwriting. An invitation to the Library, signed A. Below the signature: Floor of Literature. Someone has added, in a different hand, \"We look forward to your story.\"",
		weight = 0,
		when = { world = ERA, minAge = 16, max = { strength = 59 }, min = { intelligence = 62 } },
		codex = "library_invitations",
		choices = {
			{
				label = "Sign it",
				hint = "Signing takes you to the Library at once. A reception is a real fight. Lose, and you become a book.",
				result = { setFlags = { "lib_invited" }, trigger = "lib_reception_literature", log = "You read the invitation one last time and signed it. The ink was still wet when the room turned its page." },
			},
			{
				label = "Burn it",
				result = { sanity = { 2, 4 }, setFlags = { "lib_invited", "lib_declined" }, log = "You burned it. It took a long time to catch, as if it wanted to be read once more." },
			},
			{
				label = "Keep it in a drawer",
				result = { mind = 2, setFlags = { "lib_invited", "kept_invitation" }, log = "You put it in a drawer. It's the nicest letter anyone has ever written you, and the most dangerous." },
			},
			{
				label = "Find a crew to go in with",
				hint = "Opens an expedition: A Reception, as a Crew.",
				result = { setFlags = { "lib_invited", "lib_crew_invited" }, codex = "lib_bookhunters", log = "You asked around for people brave or broke enough to go in with you. You found three." },
			},
		},
	},
	{
		id = "lib_invite_language",
		title = "Floor of Language",
		text = "The envelope is cream and heavy, and the handwriting on it is sharp enough to cut. An invitation to the Library, signed A. Below it: Floor of Language. That's all. No promises, no flourish. Fixers who see it in your hand go quiet and find somewhere else to stand.",
		weight = 0,
		when = { world = ERA, minAge = 16, min = { strength = 60 }, max = { strength = 74 } },
		codex = "library_invitations",
		choices = {
			{
				label = "Sign it",
				hint = "Signing takes you to the Library at once. A hard reception. Lose, and you become a book.",
				result = { setFlags = { "lib_invited" }, trigger = "lib_reception_language", log = "You sharpened what needed sharpening, told nobody, and signed. Between one breath and the next, the floorboards under you were marble." },
			},
			{
				label = "Burn it",
				result = { sanity = { 2, 4 }, setFlags = { "lib_invited", "lib_declined" }, log = "You burned it. An old Fixer at the diner saw you do it and bought you dinner. \"Smartest thing I've seen all year,\" he said." },
			},
			{
				label = "Keep it in a drawer",
				result = { mind = 2, setFlags = { "lib_invited", "kept_invitation" }, log = "You put it in a drawer. It feels like a challenge you haven't answered yet." },
			},
			{
				label = "Find a crew to go in with",
				hint = "Opens an expedition: A Reception, as a Crew.",
				result = { setFlags = { "lib_invited", "lib_crew_invited" }, codex = "lib_bookhunters", log = "Word got around that you had an invitation that named Language. You had your pick of a crew." },
			},
		},
	},
	{
		id = "lib_invite_general",
		title = "General Works",
		text = "The envelope is cream and heavy. The invitation inside is signed A, like all of them, but below the signature someone has written two words in a tired, ordinary hand: General Works. And under that, smaller: \"Sorry about this. R.\"",
		weight = 0,
		when = { world = ERA, minAge = 16, min = { strength = 75 } },
		codex = "library_invitations",
		choices = {
			{
				label = "Sign it",
				hint = "Signing takes you to the Library at once. The hardest reception there is. Lose, and you become a book.",
				result = { setFlags = { "lib_invited" }, trigger = "lib_reception_general", log = "You read the apology twice. Then you signed anyway. Some people never learn, and some people are the best Fixers in the District." },
			},
			{
				label = "Burn it",
				result = { sanity = { 2, 4 }, setFlags = { "lib_invited", "lib_declined" }, log = "You burned it. Whoever R is, you have the feeling they were relieved." },
			},
			{
				label = "Keep it in a drawer",
				result = { mind = 2, setFlags = { "lib_invited", "kept_invitation" }, log = "You kept it. Nobody gets an apology from the Library. You want to know why you did." },
			},
			{
				label = "Find a crew to go in with",
				hint = "Opens an expedition: A Reception, as a Crew.",
				result = { setFlags = { "lib_invited", "lib_crew_invited" }, codex = "lib_bookhunters", log = "You didn't show anyone the apology. You just told them you had an invitation, and three Bookhunters signed on before you finished the sentence." },
			},
		},
	},

	-- ── receptions (real fights; triggered by accepting) ──
	{
		id = "lib_reception_history",
		when = { world = { era = "library" } },
		title = "The Floor of History",
		text = "You are standing in an entrance hall that smells of old paper, with the pen still in your hand. A tired man in a black suit reads your invitation and hands it back. \"Roland. I'm the assistant. History is up the stairs, and don't touch the shelves.\" Upstairs, a Librarian in a neat uniform is waiting with four assistants and a checklist. \"Welcome to the Library!\" says Malkuth, the Patron Librarian. She sounds nervous, and very eager. You look behind you for the way you came in. There are only shelves.",
		weight = 0,
		codex = "lib_receptions",
		choices = {
			{
				label = "Fight for the book you came for",
				hint = "A real fight. Lose, and you become a book.",
				clash = { stat = "strength", foe = "Malkuth, Patron Librarian of History", coins = 2, base = 5, coinPower = 3, fight = true, status = "charge" },
				win = won({ money = { 300, 700 }, codex = { "lib_receptions", "lib_patron_librarians" }, log = "Malkuth's assistants went down one by one, and then Malkuth herself, who looked more surprised than hurt. \"You win,\" she said, and meant it. Roland walked you back down to the entrance hall with the book under your arm. \"Mind the step,\" he said, and the step was your own." }),
				lose = { die = "Became a book on the Floor of History", chronicle = "became_book", log = "You lost. Malkuth thanked you, very sincerely, and something gentle and final closed over you like a cover. There is a new book on the Floor of History." },
			},
			{
				label = "Hold the line with the other guests",
				hint = "Three other guests came tonight. Lose, and you become a book.",
				clash = { stat = "health", foe = "The Assistant Librarians of History", coins = 3, base = 5, coinPower = 3, fight = true, status = "charge" },
				win = won({ money = { 200, 500 }, codex = { "lib_receptions", "lib_patron_librarians" }, log = "You stood shoulder to shoulder with three strangers and didn't give an inch. Two of them didn't make it. You and a Rat called Pim were shown out, each carrying a book. You never saw him again: his step home was in another District." }),
				lose = { die = "Became a book on the Floor of History, beside three strangers", chronicle = "became_book", log = "The line broke. Malkuth apologized to all four of you at once. Four new books went onto the shelf, side by side." },
			},
		},
	},
	{
		id = "lib_reception_literature",
		when = { world = { era = "library" } },
		title = "The Floor of Literature",
		text = "The pen is still in your hand, and the room is an entrance hall lined with books. A tired man in a black suit reads your invitation twice and points you up the stairs. \"Roland. Literature is Hod's floor. She's nice.\" A pause. \"It won't help you.\" Hod, the Patron Librarian, greets you with a little bow and an apology for what is about to happen. The shelves around her are full of stories that ended badly. There is no door behind you. You checked.",
		weight = 0,
		codex = "lib_receptions",
		choices = {
			{
				label = "Fight with everything you know",
				hint = "Mental Strength. Lose, and you become a book.",
				clash = { stat = "mind", foe = "Hod, Patron Librarian of Literature", coins = 2, base = 5, coinPower = 3, fight = true, status = "sinking" },
				win = won({ money = { 300, 700 }, codex = { "lib_receptions", "lib_patron_librarians" }, log = "Hod fought like she was apologizing with every blow, and lost like she wanted to apologize for that too. You were set down on your own doorstep with a book whose last chapter you're afraid to read." }),
				lose = { die = "Became a book on the Floor of Literature", chronicle = "became_book", log = "Hod said sorry, and meant it. Your story ends on a shelf full of stories that ended badly. It's a good one, she says." },
			},
			{
				label = "Read their moves like a page",
				hint = "Intelligence. Lose, and you become a book.",
				clash = { stat = "intelligence", foe = "The Floor of Literature", coins = 2, base = 5, coinPower = 3, fight = true, status = "sinking" },
				win = won({ money = { 300, 700 }, codex = { "lib_receptions", "lib_key_pages" }, log = "Every Librarian fought from pages, and pages can be read. By the third exchange you knew what each of them would do next. Hod looked almost proud of you when she fell." }),
				lose = { die = "Became a book on the Floor of Literature", chronicle = "became_book", log = "You read them perfectly, and it wasn't enough. Hod closed your book gently, the way you'd close one you meant to read again." },
			},
		},
	},
	{
		id = "lib_reception_language",
		when = { world = { era = "library" } },
		title = "The Floor of Language",
		text = "One moment the pen, the next an entrance hall. The tired man in the black suit who reads your invitation is called Roland, and his face does something complicated. \"Language. Gebura's floor. Don't make speeches, she won't listen to them.\" The Patron Librarian of Language is a tall woman with a red blade and no interest in greetings. Her assistants are already standing. You understand, now, why the invitation asked you to sign.",
		weight = 0,
		codex = "lib_receptions",
		choices = {
			{
				label = "Fight her head-on",
				hint = "A hard fight. Lose, and you become a book.",
				clash = { stat = "strength", foe = "Gebura, Patron Librarian of Language", coins = 3, base = 6, coinPower = 3, fight = true, status = "bleed" },
				win = won({ money = { 700, 1400 }, strength = 2, codex = { "lib_receptions", "lib_floor_language" }, log = "Nobody wins on the Floor of Language. You did. Gebura looked at you for a long moment, like she was reading a page she'd written herself years ago, and stepped aside. The book you were sent home with is heavy, and it hums." }),
				lose = { die = "Became a book on the Floor of Language", chronicle = "became_book", log = "Gebura didn't make a speech. Neither did you, in the end. Your book is on the Floor of Language now, among all the Fixers who came before." },
			},
			{
				label = "Stand your ground until she tires",
				hint = "Health. A hard fight. Lose, and you become a book.",
				clash = { stat = "health", foe = "Gebura, Patron Librarian of Language", coins = 3, base = 6, coinPower = 3, fight = true, status = "bleed" },
				win = won({ money = { 700, 1400 }, health = 2, codex = { "lib_receptions", "lib_floor_language" }, log = "She didn't tire. You just didn't fall, over and over, until even Gebura had to admit it. \"Fine,\" she said. That was all. You took the heaviest book on the shelf." }),
				lose = { die = "Became a book on the Floor of Language", chronicle = "became_book", log = "You stood your ground for longer than anyone had a right to. Then you didn't. Gebura shelved you herself." },
			},
		},
	},
	{
		id = "lib_reception_general",
		when = { world = { era = "library" } },
		title = "General Works",
		text = "The pen is still in your hand when a tired man in a black suit takes your invitation, reads it, and sighs. \"Roland. General Works. That's my floor.\" He walks you up himself, chatting about noodles. At the top of the stairs he stops, pulls on a pair of black gloves, and takes a hammer off a rack you could have sworn was empty. \"Nothing personal. I need the book.\" He is standing between you and the stairs. There was never a door.",
		weight = 0,
		codex = "lib_receptions",
		choices = {
			{
				label = "Fight the man in black",
				hint = "The hardest fight in the Library. Lose, and you become a book.",
				clash = { stat = "strength", foe = "Roland, of General Works", coins = 3, base = 7, coinPower = 3, fight = true, status = "rupture" },
				win = won({ money = { 1200, 2400 }, rolls = 1, setFlags = { "lib_won_general" }, codex = { "lib_receptions", "lib_black_silence" }, log = "Roland went through a hammer, a sword, two pistols and a weapon you had no name for. Then he stopped, breathing hard, and laughed once. \"She's going to hate this.\" He let you take a book. Every Fixer in the City will want to know how you came home from General Works." }),
				lose = { die = "Became a book in General Works", chronicle = "became_book", log = "Roland changed weapons faster than you could follow, and then it was over. \"Sorry,\" he said, and it sounded true. Your book is shelved in General Works, where he can keep an eye on it." },
			},
			{
				label = "Watch which weapon he reaches for",
				hint = "Mental Strength. The hardest fight in the Library. Lose, and you become a book.",
				clash = { stat = "mind", foe = "Roland, of General Works", coins = 3, base = 6, coinPower = 3, fight = true, status = "rupture" },
				win = won({ money = { 1200, 2400 }, rolls = 1, setFlags = { "lib_won_general" }, codex = { "lib_receptions", "lib_black_silence" }, log = "Every weapon on his rack came from a different Workshop, and every Workshop has a habit. You read them one by one. When he finally put the last one down he looked at you like a Fixer looks at a Fixer. \"Not bad.\" You took your book and didn't look back." }),
				lose = { die = "Became a book in General Works", chronicle = "became_book", log = "You read every weapon but the last one. Roland apologized again, quietly, and put your book on a shelf near his desk." },
			},
		},
	},
	{
		id = "lib_reception_pair",
		when = { world = { era = "library" } },
		title = "Two Guests",
		text = "You signed one under the other, and the entrance hall has room for you both. A tired man in a black suit reads both invitations and raises an eyebrow. \"Two at once. That's new.\" Upstairs a Floor of Librarians is waiting, polite as a funeral. The one you came with is pale, and very determined, and holding your sleeve. Neither of you can see a way back.",
		weight = 0,
		codex = "lib_receptions",
		choices = {
			{
				label = "Fight side by side",
				hint = "Lose, and you become a book.",
				clash = { stat = "strength", foe = "The Librarians of a Floor", coins = 2, base = 5, coinPower = 3, fight = true, status = "charge" },
				win = won({ money = { 250, 600 }, relationBond = { kind = "all", amount = 10 }, log = "You fought back to back, and every time one of you stumbled the other was already there. You were both sent home. You both carried a book. Neither of you has ever told anyone what happened on the stairs." }),
				lose = { die = "Became a book in the Library, side by side with someone they loved", chronicle = "became_book", log = "You fell together. Somewhere in the Library there are two books on the same shelf, leaning on each other." },
			},
			{
				label = "Shield them, whatever it costs",
				hint = "Health. Lose, and you become a book, but they go home.",
				clash = { stat = "health", foe = "The Librarians of a Floor", coins = 3, base = 5, coinPower = 3, fight = true, status = "charge" },
				win = won({ money = { 250, 600 }, relationBond = { kind = "all", amount = 12 }, log = "Nothing touched them. A great deal touched you. When it was over you were both set down on the same doorstep with a book each, and they wouldn't let go of your arm until morning." }),
				lose = { die = "Became a book in the Library so someone else could go home", chronicle = "became_book", log = "You held the Librarians off long enough. They were sent home. You weren't. Your book is short, and very brave." },
			},
		},
	},

	-- ── someone you love is invited (scheduled by "Keep your people close") ──
	{
		id = "lib_sibling_invited",
		title = "{sibling}'s Invitation",
		text = "{sibling} shows you an invitation with their name on it, holding it like it might fly away. \"It says the book I need is waiting for me,\" they say. \"Whatever I desire most. Think what we could do with that.\" They've already decided. You can see it.",
		weight = 0,
		when = { world = ERA, minAge = 14, hasRelation = "sibling" },
		codex = "library_invitations",
		choices = {
			{
				label = "Talk them out of it",
				hint = "Charisma check. If you fail, they sign anyway.",
				clash = { stat = "charisma", foe = "Their mind, made up", coins = 2, base = 4, coinPower = 3 },
				win = { relationBond = { kind = "sibling", amount = 15 }, sanity = 3, chronicle = "lib_talked_out", log = "You talked until it was nearly three. Then {sibling} tore the invitation in half, and in half again, and you both laughed at how badly your hands were shaking." },
				lose = { sanity = -3, trigger = "lib_sibling_vigil", log = "{sibling} listened, and nodded, and signed anyway." },
			},
			{
				label = "Go in with them",
				hint = "You'll face a reception together.",
				result = { setFlags = { "lib_invited" }, trigger = "lib_reception_pair", log = "If they were going, you were going. {sibling} cried a little, then pretended they hadn't." },
			},
			{
				label = "Let them sign, and wait",
				result = { trigger = "lib_sibling_vigil", log = "You held {sibling}'s sleeve while they wrote their name. Then you were holding nothing." },
			},
		},
	},
	{
		id = "lib_sibling_vigil",
		title = "The Empty Chair",
		text = "{sibling} signed at the kitchen table, and the chair was empty before the pen stopped rolling. You sit across from it with the lamp on. Hours go by. There is nothing you can do but wait.",
		weight = 0,
		when = { hasRelation = "sibling" },
		choices = {
			{
				label = "Keep watch until dawn",
				hint = "Nothing you do changes what happens inside. Your coins flip fair.",
				clash = { stat = "mind", foe = "The longest night", coins = 2, base = 4, coinPower = 3, ignoreSanity = true },
				win = { relationBond = { kind = "sibling", amount = 12 }, money = { 150, 400 }, setFlags = { "lib_family_survivor" }, log = "At dawn {sibling} was in the chair again, limping even sitting down, with a book under their arm. They sold it that winter and paid off every debt your family had. They never talk about the inside." },
				lose = { killRelation = { kind = "sibling", fate = "book" }, setFlags = { "lib_lost_someone" }, quest = "lib_q_book_home", codex = "library_books", schedule = { event = "lib_loved_book", inYears = 3 }, log = "Dawn came. The chair stayed empty. The invitation on the table was blank paper now." },
			},
			{
				label = "Ask the street who else signed tonight",
				hint = "Nothing you do changes what happens inside. Your coins flip fair.",
				clash = { stat = "intelligence", foe = "The longest night", coins = 2, base = 4, coinPower = 3, ignoreSanity = true },
				win = { relationBond = { kind = "sibling", amount = 12 }, money = { 150, 400 }, setFlags = { "lib_family_survivor" }, log = "A Fixer two doors down came back first, battered and silent. Then nobody for hours. Then {sibling}, in your own kitchen, carrying a book and grinning like an idiot. You've never been so angry at anyone you were so glad to see." },
				lose = { killRelation = { kind = "sibling", fate = "book" }, setFlags = { "lib_lost_someone" }, quest = "lib_q_book_home", codex = "library_books", schedule = { event = "lib_loved_book", inYears = 3 }, log = "Two people on your street came back that night, and neither of them had seen anyone like the person you described. By morning the invitation on the table was blank." },
			},
		},
	},
	{
		id = "lib_friend_invited",
		title = "{friend}'s Invitation",
		text = "{friend} slides an envelope across the diner table: cream paper, your friend's name on it, signed A. \"I'm going,\" they say. \"I've been stuck my whole life. This is the way out.\" They've ordered for both of you, which they only do when they've made up their mind.",
		weight = 0,
		when = { world = ERA, minAge = 14, hasRelation = "friend", noRelation = "sibling" },
		codex = "library_invitations",
		choices = {
			{
				label = "Talk them out of it",
				hint = "Charisma check. If you fail, they sign anyway.",
				clash = { stat = "charisma", foe = "Their mind, made up", coins = 2, base = 4, coinPower = 3 },
				win = { relationBond = { kind = "friend", amount = 15 }, sanity = 3, chronicle = "lib_talked_out", log = "You talked about every plan you'd ever made together, the stupid ones too. By the time the noodles went cold, {friend} had pushed the envelope back across the table to you. You burned it on the way home." },
				lose = { sanity = -3, trigger = "lib_friend_vigil", log = "{friend} heard you out, paid for dinner, and signed anyway." },
			},
			{
				label = "Go in with them",
				hint = "You'll face a reception together.",
				result = { setFlags = { "lib_invited" }, trigger = "lib_reception_pair", log = "\"Then I'm coming,\" you said. {friend} argued for an hour, and then gave up, and then looked more relieved than you'd ever seen them." },
			},
			{
				label = "Let them sign, and wait",
				result = { trigger = "lib_friend_vigil", log = "You told {friend} to come back. They said they would, and signed, and the booth across from you was empty." },
			},
		},
	},
	{
		id = "lib_friend_vigil",
		title = "The Empty Booth",
		text = "{friend} signed on the diner table, waved once, and wasn't there. The pen is still rocking. The cook has seen it before, and brings you tea you didn't order. You sit in the booth and wait.",
		weight = 0,
		when = { hasRelation = "friend" },
		choices = {
			{
				label = "Keep watch until dawn",
				hint = "Nothing you do changes what happens inside. Your coins flip fair.",
				clash = { stat = "mind", foe = "The longest night", coins = 2, base = 4, coinPower = 3, ignoreSanity = true },
				win = { relationBond = { kind = "friend", amount = 12 }, money = { 100, 300 }, setFlags = { "lib_family_survivor" }, log = "At dawn {friend} was sitting across from you again, white as paper, with a book under one arm. You split the money from the book. You never split anything else as carefully." },
				lose = { killRelation = { kind = "friend", fate = "book" }, setFlags = { "lib_lost_someone" }, quest = "lib_q_book_home", codex = "library_books", schedule = { event = "lib_loved_book", inYears = 3 }, log = "The sun came up. The booth stayed empty. You sat there until the cook told you, kindly, to go home." },
			},
			{
				label = "Ask the street who else signed tonight",
				hint = "Nothing you do changes what happens inside. Your coins flip fair.",
				clash = { stat = "intelligence", foe = "The longest night", coins = 2, base = 4, coinPower = 3, ignoreSanity = true },
				win = { relationBond = { kind = "friend", amount = 12 }, money = { 100, 300 }, setFlags = { "lib_family_survivor" }, log = "Three people from the street had signed that night. The third to come back was {friend}, carrying a book and laughing at nothing. You have never hugged anyone so hard in public." },
				lose = { killRelation = { kind = "friend", fate = "book" }, setFlags = { "lib_lost_someone" }, quest = "lib_q_book_home", codex = "library_books", schedule = { event = "lib_loved_book", inYears = 3 }, log = "Nobody who came back had seen them. By morning the envelope on the table held blank paper." },
			},
		},
	},

	-- ── the Bookhunters (from "Find the man hiring porters") ──
	{
		id = "lib_bookhunters",
		title = "The Bookhunters",
		text = "The man in the good coat works for Ines Ferro, a Grade 4 Fixer whose crew calls itself the Bookhunters. They rent a room over a noodle shop and wait for an invitation with every one of their names on it. \"One reception,\" Ines tells you, \"one book, and none of us ever works again. I need someone to carry the gear up and mind the room while we're gone. Pay up front.\"",
		weight = 0,
		codex = "lib_bookhunters",
		choices = {
			{
				label = "Carry the gear",
				result = { wage = { 80, 160 }, health = { -4, -1 }, setFlags = { "lib_porter" }, schedule = { event = "lib_bookhunters_return", inYears = 1 }, log = "You carried crates of gear up four flights and watched the Bookhunters sign, one after another. Then the room had six chairs and nobody in them." },
			},
			{
				label = "Sign on as a Bookhunter",
				hint = "Opens an expedition: A Reception, as a Crew.",
				requires = { min = { strength = 45 } },
				result = { strength = 1, setFlags = { "lib_crew_invited", "lib_invited" }, schedule = { event = "lib_bookhunters_return", inYears = 1 }, log = "Ines looked you over and said you'd do. When the crew's invitation came, there was a line on it with your name." },
			},
			{
				label = "Tell her she's out of her mind",
				result = { sanity = 2, schedule = { event = "lib_bookhunters_return", inYears = 1 }, log = "\"Probably,\" Ines said, and bought you a bowl of noodles anyway. \"If we come back, I'll tell you what it's like.\"" },
			},
		},
	},
	{
		id = "lib_bookhunters_return",
		title = "Ines Comes Back",
		text = "Ines Ferro comes back alone. She is thinner, she walks like something is still behind her, and there's a book with a gilt spine inside her coat. The rest of her crew is on a shelf now, she says, and laughs in a way that isn't laughing.",
		weight = 0,
		when = { minAge = 14 },
		choices = {
			{
				label = "Ask her what it's like inside",
				clash = { stat = "mind", foe = "What she saw", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, gear = "fixer_coat", codex = { "lib_floors", "lib_patron_librarians" }, log = "She told you all of it: the pen, the hall, the stairs, the Floors, the man in black who chats like a diner cook. Then she gave you her old coat. \"I'm not going back out in it,\" she said." },
				lose = { sanity = -3, log = "She opened her mouth to tell you, and nothing came out. She shook her head and left. You never saw her again." },
			},
			{
				label = "Buy the book she carried out",
				hint = "300 Ahn",
				requires = { min = { money = 300 } },
				result = { money = -300, gear = "lib_library_book", setFlags = { "lib_book_owner" }, schedule = { event = "lib_book_you_took", inYears = 1 }, codex = "lib_books_sold", log = "She sold it to you for three hundred. \"It's one of my crew,\" she said. \"I can't keep looking at it.\"" },
			},
			{
				label = "Help her find somewhere to sleep",
				result = { sanity = 3, intelligence = 1, addRelation = { kind = "friend", name = "Ines Ferro", bond = 55, age = { 30, 40 } }, log = "You found her a room above the noodle shop and checked on her every week. She started taking small jobs again. She never took another invitation." },
			},
		},
	},

	-- ── books ──
	{
		id = "lib_book_you_took",
		title = "The Library Book",
		text = "The Library book on your shelf has a name on its gilt spine: Jonas Halloran, Grade 6, of the Hook Office. You've read the first page a dozen times. It's written in his voice. It knows how he held a knife, and what he was afraid of, and who he was going to visit when he got back.",
		weight = 0,
		when = { world = { era = { "library", "limbus" } }, flags = { "lib_book_owner" } },
		codex = "library_books",
		choices = {
			{
				label = "Read it cover to cover",
				result = { addTrait = "lib_read_pages", sanity = -4, codex = "lib_key_pages", log = "You read it in one night. You learned how he fought, and how he lost. Some of it stayed in your hands. Some of it stayed in your dreams." },
			},
			{
				label = "Sell it to a collector",
				result = { money = { 900, 1800 }, loseGear = "lib_library_book", clearFlags = { "lib_book_owner" }, codex = "lib_books_sold", log = "A collector in a Nest suit paid more than you'd earned in years and handled the book like it might bite. Maybe it does." },
			},
			{
				label = "Find his family",
				result = { sanity = 8, loseGear = "lib_library_book", clearFlags = { "lib_book_owner" }, chronicle = "lib_book_returned", addRelation = { kind = "friend", name = "Mirae Halloran", bond = 60 }, log = "It took a month to find his sister, Mirae. She cried, then she made you tea, then she cried again. You visit her every year on the same day." },
			},
		},
	},
	{
		id = "lib_book_stall",
		title = "Gilt Spines",
		text = "A stall at the market is selling books from the Library: gilt spines, a name on every one, prices that make you laugh. The stallholder taps one. \"Grade 5 Fixer, this. Read it and you'll fight like her. This one, you'll know how to pick a Nest lock.\"",
		weight = 12,
		once = true,
		tags = { "library" },
		when = { world = { era = { "library", "limbus" } }, minAge = 14 },
		codex = "lib_books_sold",
		choices = {
			{
				label = "Buy the Fixer's book",
				hint = "350 Ahn",
				requires = { min = { money = 350 } },
				result = { money = -350, gear = "lib_library_book", setFlags = { "lib_book_owner" }, schedule = { event = "lib_book_you_took", inYears = 1 }, log = "You bought the one about the Fixer. It's warm. Books shouldn't be warm." },
			},
			{
				label = "Look for a name you know",
				clash = { stat = "mind", foe = "Two hundred names", coins = 2, base = 4, coinPower = 3 },
				win = { money = -40, sanity = 4, chronicle = "lib_book_returned", log = "Halfway down the second shelf: the old courier from your street, who never missed a delivery. You bought him for the price of a good meal and took him home to his daughter." },
				lose = { sanity = -3, log = "Every name was someone's. None of them were anyone you knew, and you left feeling like you'd walked through a cemetery with a price on every stone." },
			},
			{
				label = "Walk on",
				result = { mind = 1, log = "You walked on. Behind you, somebody started haggling over a person." },
			},
		},
	},
	{
		id = "lib_loved_book",
		title = "A Name You Know",
		text = "At the back of a Backstreets market, between a stall of second-hand prosthetics and a stall of lucky stickers, a man is selling books with gilt spines. One of them has a name on it that you haven't said out loud in years.",
		weight = 0,
		when = { minAge = 14, flags = { "lib_lost_someone" } },
		codex = "lib_books_sold",
		choices = {
			{
				label = "Buy it, whatever he asks",
				hint = "400 Ahn",
				requires = { min = { money = 400 } },
				result = { money = -400, gear = "lib_library_book", setFlags = { "lib_book_owner", "lib_found_their_book" }, clearFlags = { "lib_lost_someone" }, sanity = 8, chronicle = "lib_book_returned", log = "He asked for four hundred. You would have paid four thousand. You carried the book home against your chest and put it on the shelf by the window, where the light is good." },
			},
			{
				label = "Take it from him",
				clash = { stat = "strength", foe = "A book dealer's bodyguard", coins = 2, base = 5, coinPower = 3, fight = true },
				win = { strength = 1, gear = "lib_library_book", setFlags = { "lib_book_owner", "lib_found_their_book" }, clearFlags = { "lib_lost_someone" }, sanity = 6, chronicle = "lib_book_returned", log = "His bodyguard went over the stall and the dealer decided the book wasn't worth it. You walked home with it inside your coat, and nobody followed you." },
				lose = { health = { -12, -5 }, sanity = -4, cause = "Fought a dealer's bodyguard over a name", log = "His bodyguard was a real Fixer, and you weren't. When you got up, the stall was gone, and so was the book." },
			},
			{
				label = "Let it go. They aren't in a book.",
				result = { sanity = -3, mind = 3, clearFlags = { "lib_lost_someone" }, log = "You walked on. Whatever is in that book, it isn't them. You told yourself that all the way home, and most days now you believe it." },
			},
		},
	},

	-- ── the first Distortions ──
	{
		id = "lib_pianist_news",
		title = "The Streets of Music",
		text = "A Devyat' courier at the noodle stall is telling anyone who'll listen about District 9, the part they call the Streets of Music. A pianist there turned into something, he says, and gave a concert. Then he stops talking and stares into his bowl. \"Whole streets,\" he says. \"Just quiet.\"",
		weight = 25,
		once = true,
		tags = { "library", "distortion" },
		when = { world = ERA, minAge = 10 },
		choices = {
			{
				label = "Ask him what a Distortion is",
				result = { mind = 2, sanity = -2, setFlags = { "lib_heard_pianist" }, codex = { "lib_pianist", "lib_first_distortions" }, log = "He told you what he'd seen, which wasn't much, and what he'd heard, which was worse. You walked home humming nothing at all." },
			},
			{
				label = "Pay for his noodles and change the subject",
				result = { money = -5, sanity = 2, log = "You paid for his noodles and asked him about the best routes through District 9. He looked grateful. He told you to take the long way, always." },
			},
			{
				label = "Check on the people you love",
				result = { sanity = 1, relationBond = { kind = "all", amount = 5 }, setFlags = { "lib_heard_pianist" }, log = "That week you went round everyone you love and listened to them talk about nothing. If feelings can turn into monsters now, you wanted to know how theirs were doing." },
			},
		},
	},
	{
		id = "lib_ensemble_night",
		title = "Music at Two in the Morning",
		text = "Under your window, at two in the morning, an ensemble is playing: four strangers in blue coats, and a tall man conducting with a tuning fork. The street is empty. The music is beautiful, and it makes every feeling you have a little bigger than it was.",
		weight = 18,
		once = true,
		tags = { "library", "distortion", "strange" },
		when = { world = ERA, minAge = 12 },
		choices = {
			{
				label = "Shut the window and hum something else",
				result = { sanity = 1, mind = 2, log = "You shut the window and hummed an old noodle-shop jingle until the music outside gave up. In the morning there were five sets of footprints in the frost. They stopped in the middle of the street." },
			},
			{
				label = "Listen until it ends",
				result = { sanity = -8, strength = 2, log = "You listened. Every grudge you'd ever held sat up and looked around. When it ended you were standing at the door with your hand on the lock, and you didn't remember getting up." },
			},
			{
				label = "Follow them",
				hint = "Mental Strength check. Keep your head.",
				clash = { stat = "mind", foe = "The Reverberation Ensemble", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = -3, chronicle = "lib_ensemble_heard", codex = "lib_ensemble", log = "You followed them three streets and kept your head. At the last corner the conductor turned, smiled, and bowed to you like you were the only audience that mattered. Then they were gone. A Fixer you told about it went pale and said one word: Argalia." },
				lose = { sanity = -10, condition = "distortion_signs", log = "You followed the music until you forgot why. You came to on a stranger's doorstep at dawn with the tune still going, and it has never fully stopped." },
			},
			{
				label = "Recognize the music from the courier's story, and run",
				requires = { flags = { "lib_heard_pianist" } },
				result = { sanity = 2, codex = "lib_pianist", log = "It was the kind of music the courier from District 9 had described. You ran three streets before you let yourself stop. It was the right call. You're almost sure." },
			},
		},
	},
	{
		id = "lib_street_distortion",
		title = "The Tailor on the Third Floor",
		text = "Mrs. Baek, the tailor on the third floor, lost her son in the week of the White Nights. Since then she has been sewing his coat over and over, never finishing it. This morning her door is open, and what's inside is made of thread and needles and grief, and it is still sewing. The children from the second floor are on the stairs.",
		weight = 22,
		once = true,
		tags = { "library", "distortion", "danger" },
		when = { world = ERA, minAge = 14 },
		codex = "lib_first_distortions",
		choices = {
			{
				label = "Talk to her about her son",
				hint = "Charisma check. There's still someone in there.",
				clash = { stat = "charisma", foe = "Mrs. Baek's grief", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = 4, charisma = 2, setFlags = { "lim_distortion_survivor" }, chronicle = "calmed_distortion", log = "You talked about her son: his laugh, his terrible handwriting, the coat. The needles slowed. When the Fixers came she was sitting still, and she let them take her. You never found out where." },
				lose = { sanity = -8, condition = "distortion_signs", setFlags = { "lim_distortion_survivor" }, log = "She answered you in a voice made of thread. You got out. Some of it got in." },
			},
			{
				label = "Hold the stairs until the Fixers come",
				clash = { stat = "strength", foe = "The thing on the third floor", coins = 3, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = 2, wage = { 30, 80 }, setFlags = { "lim_distortion_survivor" }, chronicle = "fought_distortion", log = "You held the stairs with a broom handle and nerve until a two-person Fixer office arrived. They finished it. One of them looked at you and said, \"You've done this before.\" You hadn't." },
				lose = { health = { -14, -6 }, sanity = -5, cause = "Held the stairs against a Distortion", trigger = "lim_distortion_aftermath", log = "The thread caught you like a net and threw you down the stairs." },
			},
			{
				label = "Get the children out",
				clash = { stat = "intelligence", foe = "Panic on the stairs", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, setFlags = { "lim_distortion_survivor" }, log = "You got all six children down the fire escape and into the noodle shop across the street. Their parents never forgot it. Neither did the noodle shop." },
				lose = { sanity = -4, health = -3, setFlags = { "lim_distortion_survivor" }, log = "You got them out, mostly by carrying them, and twisted your knee on the last step. One of them still has nightmares about the sewing sound. So do you." },
			},
		},
	},

	-- ── children of the Library era ──
	{
		id = "lib_parent_invitation",
		title = "Behind the Flour Tin",
		text = "Behind the flour tin you find a cream envelope with {mother}'s name on it: an invitation to the Library. It's been opened, and read so many times that the folds have gone soft. Someone has underlined one line in pencil. \"Whatever you desire most is waiting in a book.\"",
		weight = 30,
		once = true,
		tags = { "library" },
		when = { world = ERA, minAge = 8, maxAge = 17, hasRelation = "mother" },
		codex = "library_invitations",
		choices = {
			{
				label = "Burn it before she can go",
				result = { sanity = 2, relationBond = { kind = "mother", amount = -6 }, chronicle = "lib_talked_out", log = "You burned it in the sink. {mother} found the ashes and didn't speak to you for two days. On the third day she held you for a long time and didn't explain." },
			},
			{
				label = "Ask her about it",
				result = { mind = 2, relationBond = { kind = "mother", amount = 8 }, setFlags = { "lib_mothers_reason" }, log = "She told you about your aunt, who vanished during the week of the White Nights. The invitation is in your aunt's handwriting. {mother} never went. She kept it because it's the last thing your aunt ever wrote." },
			},
			{
				label = "Put it back and say nothing",
				result = { trigger = "lib_parent_went", log = "You put it back exactly where it was. That night {mother} put on her good coat and took a pen out of the drawer." },
			},
		},
	},
	{
		id = "lib_parent_went",
		title = "The Night She Signed",
		text = "{mother} tucks you in wearing her good coat, which she never wears indoors. Through the crack of the door you watch her sit down at the table, smooth the cream paper flat, and pick up the pen.",
		weight = 0,
		when = { hasRelation = "mother" },
		choices = {
			{
				label = "Stay in bed and wait",
				hint = "Nothing you do changes what happens inside. Your coins flip fair.",
				clash = { stat = "mind", foe = "The longest night", coins = 2, base = 4, coinPower = 3, ignoreSanity = true },
				win = { relationBond = { kind = "mother", amount = 12 }, money = { 100, 300 }, setFlags = { "lib_family_survivor" }, log = "At dawn she was at the table again, with a book under her arm and a cut on her cheek. She came and sat down on the floor next to your bed without a word. She never told you what was in the book. She never needed another invitation." },
				lose = { killRelation = { kind = "mother", fate = "book" }, setFlags = { "lib_lost_someone" }, quest = "lib_q_book_home", codex = "library_books", schedule = { event = "lib_loved_book", inYears = 4 }, log = "She signed. In the morning her chair was pushed back and the paper was blank. Nobody came to tell you anything. Everyone on the street already knew what it meant." },
			},
			{
				label = "Run to the table",
				hint = "Speed check. Catch her hand before the pen touches the paper.",
				clash = { stat = "speed", foe = "Six steps and a pen", coins = 2, base = 4, coinPower = 3 },
				win = { relationBond = { kind = "mother", amount = 15 }, sanity = 3, chronicle = "lib_talked_out", log = "You got to the table before the pen touched the paper, and held her wrist with both hands and wouldn't let go. She looked at the invitation, and at you, for a long time. Then she put the pen down and carried you back to bed." },
				lose = { killRelation = { kind = "mother", fate = "book" }, sanity = -6, setFlags = { "lib_lost_someone" }, quest = "lib_q_book_home", codex = "library_books", schedule = { event = "lib_loved_book", inYears = 4 }, log = "You were two steps from the table when she finished her name. The pen rolled onto the floor. You called for her until a neighbour came and sat with you. She never came back." },
			},
		},
	},
	{
		id = "lib_child_letter",
		title = "In Your Own Handwriting",
		text = "There's an envelope inside your door, addressed in handwriting you recognize after a moment: your own, from when you were a child. The paper is cream and heavy. Inside is an invitation, signed A. Every line is blank except one: \"When you're older.\"",
		weight = 0,
		when = { minAge = 12, flags = { "lib_wrote_name" } },
		choices = {
			{
				label = "Keep it",
				result = { mind = 2, sanity = -2, setFlags = { "kept_invitation" }, codex = "lib_end", log = "You put it in a drawer with the other things you can't explain." },
			},
			{
				label = "Burn it",
				result = { sanity = 3, log = "It burned blue, then gold, then nothing. The smoke smelled like lilies." },
			},
			{
				label = "Write back",
				result = { intelligence = 1, sanity = 2, log = "You wrote \"I'm older now\" on the back and left it on the sill. In the morning it was gone. Nothing else happened. You were relieved, and a little disappointed." },
			},
		},
	},

	-- ── the end of the Library (the Distortion era begins) ──
	{
		id = "lib_last_light",
		title = "The Night the Library Let Go",
		text = "One night a pillar of light goes up over District 12 and comes down over the whole City like warm rain. You stand in it with your face turned up. You were inside the Library once, and it sent you home. Now there is nowhere left to be invited to.",
		weight = 300,
		once = true,
		tags = { "library" },
		when = { world = { era = "limbus" }, flags = { "library_survivor" } },
		codex = "lib_end",
		choices = {
			{
				label = "Let the light fall on you",
				result = { sanity = 6, log = "It felt like being forgiven for something you never did. In the morning the light was gone, and so was a weight you'd carried since the night of your reception." },
			},
			{
				label = "Take your invitation out of the drawer",
				result = { mind = 2, sanity = -2, log = "The paper was blank. Not faded: blank, as if nobody had ever written to you. Down the street, Bookhunters with nowhere left to hunt were selling their gear. You kept the paper anyway." },
			},
			{
				label = "Write down everything you remember about the inside",
				result = { intelligence = 3, codex = "lib_receptions", log = "You filled a whole notebook: the stairs, the shelves, Roland's terrible jokes. By the end you weren't sure which parts you remembered and which parts you needed to be true." },
			},
		},
	},
	{
		id = "lib_drawer_blank",
		title = "The Blank Invitation",
		text = "The invitation you kept in the drawer has gone blank. The paper is still heavy and cream, but the handwriting is gone, as if it had never been addressed to anyone. The Library it invited you to is gone too.",
		weight = 200,
		once = true,
		tags = { "library" },
		when = { world = { era = "limbus" }, flags = { "kept_invitation" } },
		codex = "lib_end",
		choices = {
			{
				label = "Keep it anyway",
				result = { mind = 2, sanity = 1, log = "You put it back in the drawer. Some invitations are worth keeping for the ones you didn't accept." },
			},
			{
				label = "Sell it to a collector of Library things",
				result = { money = { 60, 160 }, log = "A collector bought it, blank as it was. \"The paper,\" he said, turning it to the light. \"Nobody can make the paper.\"" },
			},
			{
				label = "Write a letter on it to someone you lost",
				result = { sanity = 5, clearFlags = { "kept_invitation" }, log = "You wrote a letter on the back to someone who's gone, and burned it. The smoke smelled like lilies. You felt lighter for days." },
			},
		},
	},
}
