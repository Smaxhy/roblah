--[[
	Side quests for Fixers and the Fingers. { order = {...}, [id] = quest }; see
	docs/CONTENT_GUIDE.md. Steps open activities in Activities/Fixers.luau or schedule
	follow-up scenes (weight-0 events in the Events/Fixers_* and Events/Fingers_* files).
]]

return {
	order = { "fx_q_own_office", "fn_q_strike_the_name", "fn_q_apology" },

	fx_q_own_office = {
		name = "Your Own Sign",
		desc = "Found an Office of your own: save the deposit, register with Hana's Office Credit Assessment Committee, and land the first client who asks for you by name.",
		giver = "A landlord with a ground-floor room",
		expires = 8,
		steps = {
			{
				text = "Save 500 Ahn for the lease and the registration fee.",
				hint = "Hold 500 Ahn at once",
				check = { when = { min = { money = 500 } } },
				doneLog = "The jar labeled SIGN was full. The landlord shook your hand on a two-year lease.",
			},
			{
				text = "Register the Office with Hana's Office Credit Assessment Committee.",
				hint = "Activities: Register your Office with Hana",
				onStart = { setFlags = { "fx_q_office_register" } },
				check = { when = { flags = { "fx_office_registered" } } },
				doneLog = "The Committee stamped your forms in four places and gave your Office its first credit rating: modest, but yours.",
			},
			{
				text = "Land your first client.",
				hint = "Keep working. Word gets around.",
				onStart = { schedule = { event = "fx_q_first_client", inYears = 1 } },
				check = { when = { flags = { "fx_q_client_done" } } },
			},
		},
		reward = {
			wage = { 150, 300 },
			sanity = 6,
			setFlags = { "fx_office_own", "fx_office_rep" },
			clearFlags = { "fx_office_hinge", "fx_office_brasshand" },
			chronicle = "fx_office_founded",
			log = "You hung the sign yourself: {last} Office. You are its Rep, and the door has your name on it.",
		},
	},

	fn_q_strike_the_name = {
		name = "Strike the Name",
		desc = "A name is written in the Middle's Book of Vengeance, and the Middle never forgets. Getting a name struck out takes three things: knowing the grudge, a mediator the Middle respects, and paying the debt in whichever form the family names.",
		giver = "A Little Sister of the Middle, off duty",
		expires = 10,
		steps = {
			{
				text = "Find out exactly what the grudge is: the Title, Section, Row and Line.",
				hint = "Activities: Ask about the grudge",
				onStart = { setFlags = { "fn_q_book_ask" } },
				check = { when = { flags = { "fn_q_book_known" } } },
				doneLog = "You know the offense now, line by line, and the punishment written beside it.",
			},
			{
				text = "Find a mediator the Middle respects.",
				hint = "Activities: Seek a mediator",
				onStart = { setFlags = { "fn_q_book_seek" } },
				check = { when = { flags = { "fn_q_book_mediator" } } },
				doneLog = "Someone the Middle respects has agreed to speak for the name.",
			},
			{
				text = "Pay the debt, in whichever form the family names.",
				hint = "The family will send for you.",
				onStart = { schedule = { event = "fn_q_book_price", inYears = 1 } },
				check = { when = { flags = { "fn_q_book_paid" } } },
			},
		},
		reward = {
			cure = "in_the_book",
			clearFlags = { "fn_middle_grudge" },
			addTrait = "fn_struck_from_book",
			chronicle = "fn_struck_from_book",
			sanity = 8,
			codex = "fn_lore_book",
			log = "A Big Sister opened the Book, found the line, and drew a single neat stroke through the name. \"The Middle remembers,\" she said. \"It remembers this too.\"",
		},
	},

	fn_q_apology = {
		name = "A Proper Apology",
		desc = "You addressed a Capo of the Thumb without the proper respect. The Thumb accepts apologies, if they are made correctly: a letter in the right form, a favor done for the Soldati, and a bow at exactly the right depth.",
		giver = "A Soldato Quarto with a rulebook",
		expires = 6,
		steps = {
			{
				text = "Deliver a formal apology letter to the Capo's table.",
				hint = "Activities: Deliver the apology letter",
				onStart = { setFlags = { "fn_q_apology_letter" } },
				check = { when = { flags = { "fn_q_apology_sent" } } },
				doneLog = "The Capo's table accepted your letter. A Soldato corrected two commas and returned your pen.",
			},
			{
				text = "Do the Soldati a favor: carry a delivery of propellant rounds.",
				hint = "Expeditions: An Ammunition Run",
				check = { when = { flags = { "done_fn_exp_ammo_run" } } },
				doneLog = "Every crate arrived. The Soldati stopped glaring at you in the street.",
			},
			{
				text = "Bow before the Capo at the next collection.",
				hint = "The Thumb will send for you.",
				onStart = { schedule = { event = "fn_q_apology_bow", inYears = 1 } },
				check = { when = { flags = { "fn_q_apology_done" } } },
			},
		},
		reward = {
			clearFlags = { "fn_thumb_disrespected" },
			setFlags = { "thumb_respect" },
			addTrait = "fn_knows_their_place",
			sanity = 5,
			log = "The Capo accepted your apology with a nod precisely one degree deep. On the Thumb's streets, that is forgiveness.",
		},
	},
}
