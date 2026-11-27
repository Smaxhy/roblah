--[[
	Opening scenes for the world events (WorldEvents.luau): queued for everyone a world
	event reaches. More events can roll while one is on: when = { worldEvent = "id" }.
]]

return {
	{
		id = "world_breach_sirens",
		title = "Sirens Over District 12",
		text = "The L Corp sirens are a sound everyone in the City knows. Shutters slam down the whole street. A runner shouts that something got out of the facility, and it's coming this way. A child is standing frozen in the middle of the road.",
		weight = 0,
		codex = "lcorp_abnormalities",
		choices = {
			{
				label = "Grab the child and get inside",
				clash = { stat = "strength", foe = "Seconds", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 4, strength = 1, chronicle = "saved_child_breach", log = "You had the child behind a locked door before the street went dark. Their mother hasn't stopped thanking you." },
				lose = { health = { -10, -4 }, sanity = -4, log = "You got the child inside. Something got a piece of you first.", cause = "Caught in a containment breach" },
			},
			{
				label = "Bar the door and wait",
				result = { sanity = { -3, 0 }, mind = 1, log = "You waited behind the door until the sirens stopped. You didn't look out the window. Some people did." },
			},
			{
				label = "Go and see what it is",
				hint = "Curiosity is a kind of courage. It's also a fight.",
				clash = { stat = "strength", foe = "The escaped Abnormality", coins = 3, base = 6, coinPower = 3, fight = true, status = "sinking" },
				win = { sanity = -2, strength = 2, setFlags = { "saw_abnormality" }, codex = "lcorp_work_types", chronicle = "fought_abnormality", log = "You held it off long enough for L Corp's suppression team to arrive. An agent nodded at you. You'll remember that nod." },
				lose = { health = { -16, -8 }, sanity = -8, condition = "night_terrors", log = "You saw it. That was the mistake.", cause = "Met something from the vaults" },
			},
		},
	},
	{
		id = "world_long_night",
		title = "The Long Night",
		text = "3:13. The first wave of Sweepers comes up out of the ground early tonight, and the second follows too soon. There's a knock on your door: a neighbor caught outside, begging to be let in.",
		weight = 0,
		codex = "city_sweepers",
		choices = {
			{
				label = "Open the door",
				clash = { stat = "mind", foe = "The Night", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 5, addTrait = "survivor_of_the_night", chronicle = "opened_door_night", log = "You pulled them in a breath before the wave passed your door. Neither of you said a word until morning." },
				lose = { health = { -12, -5 }, sanity = -6, condition = "night_terrors", log = "Something came in with them. You both got out of the room, just.", cause = "Opened the door during the Night" },
			},
			{
				label = "Keep it locked",
				result = { sanity = { -6, -3 }, log = "You kept the door locked. The knocking stopped during the second wave. You didn't sleep." },
			},
			{
				label = "Talk them to a safer hiding spot",
				clash = { stat = "charisma", foe = "Panic", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, log = "You talked them through the gap under the door into the old coal cellar next door. They made it." },
				lose = { sanity = -4, log = "They couldn't hear you over the sound of the wave." },
			},
		},
	},
	{
		id = "world_thumb_collection",
		title = "A Polite Visit",
		text = "Two Soldati of the Thumb are at your door, in pressed suits, with a ledger. \"A small contribution,\" the senior one says, \"for the protection of the street.\" The junior one's hand rests on something under his jacket.",
		weight = 0,
		codex = "fingers_thumb",
		choices = {
			{
				label = "Pay, and thank them properly",
				result = { money = { -40, -15 }, sanity = 1, log = "You paid and bowed exactly as low as their rank deserved. The senior one seemed almost pleased." },
			},
			{
				label = "Use the right forms of address and haggle",
				requires = { trait = { "proper_manners", "knows_the_fingers" } },
				clash = { stat = "charisma", foe = "A Thumb Soldato", coins = 2, base = 4, coinPower = 3 },
				win = { money = { -10, -5 }, setFlags = { "thumb_respect" }, log = "You addressed them so correctly they halved the contribution, out of respect." },
				lose = { money = { -50, -30 }, sanity = -3, log = "You got one honorific wrong. The contribution went up." },
			},
			{
				label = "Shut the door in their faces",
				clash = { stat = "strength", foe = "Two Thumb Soldati", coins = 3, base = 5, coinPower = 3, fight = true, status = "burn" },
				win = { strength = 2, sanity = -2, addTrait = "in_debt_to_the_thumb", chronicle = "defied_thumb", log = "You drove them off your step. The whole street saw. The Thumb will be back, and they'll bring a Capo." },
				lose = { health = { -14, -6 }, money = { -60, -20 }, condition = "broken_arm", log = "The Thumb does not tolerate rudeness. They made that very clear.", cause = "Shut the door on the Thumb" },
			},
		},
	},
	{
		id = "world_distortion",
		title = "The Street That Changed",
		text = "The street you walk every day is wrong this morning. The shop signs say things that make your teeth hurt, and at the end of it something stands where Mr. Okafor's noodle stall used to be. It's crying. It sounds like him.",
		weight = 0,
		codex = "terms_distortion",
		choices = {
			{
				label = "Talk to it",
				hint = "Charisma check. People are still in there, sometimes.",
				clash = { stat = "charisma", foe = "A grieving Distortion", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = 4, charisma = 2, chronicle = "calmed_distortion", log = "You talked to it about the stall, the broth, his daughter. It stopped crying. When the Fixers came, it went quietly." },
				lose = { sanity = -8, condition = "distortion_signs", log = "It talked back. You'll hear it for a long time." },
			},
			{
				label = "Hold it off until the Fixers arrive",
				clash = { stat = "strength", foe = "A Distortion", coins = 3, base = 6, coinPower = 3, fight = true, status = "rupture" },
				win = { strength = 2, wage = { 30, 80 }, chronicle = "fought_distortion", log = "You kept it pinned at the end of the street until a Fixer office arrived. They paid you a finder's fee and didn't ask your name." },
				lose = { health = { -16, -8 }, sanity = -6, log = "It threw you through a window that wasn't there yesterday.", cause = "Fought a Distortion" },
			},
			{
				label = "Run",
				result = { sanity = -3, log = "You ran, and you didn't stop until the signs made sense again." },
			},
		},
	},
	{
		id = "world_invitation",
		title = "An Invitation",
		text = "An envelope of heavy cream paper is lying inside your door. It is addressed to you, in handwriting you don't recognize. Inside: an invitation to the Library. \"Whatever you desire most,\" it says, \"is waiting in a book.\"",
		weight = 0,
		codex = "library_invitations",
		choices = {
			{
				label = "Sign it",
				hint = "Signing takes you to the Library at once. Guests who lose become books. A hard fight.",
				clash = { stat = "strength", foe = "A Librarian's reception", coins = 4, base = 7, coinPower = 3, fight = true, status = "charge" },
				win = { money = { 300, 900 }, addTrait = "library_guest", setFlags = { "library_survivor" }, codex = "library_books", chronicle = "won_reception", log = "The Library set you back down inside your own door, carrying a book. It's about someone you don't know. It's the most valuable thing you own." },
				lose = { die = "Became a book in the Library", chronicle = "became_book", log = "You lost the reception. Somewhere on a shelf, there's a book about you now. People say it's well written." },
			},
			{
				label = "Burn it",
				result = { sanity = 2, log = "You burned the invitation in the sink. The smoke smelled like old paper and lilies." },
			},
			{
				label = "Keep it in a drawer, unopened",
				result = { mind = 2, setFlags = { "kept_invitation" }, log = "You put the invitation in a drawer. Some nights you take it out and look at it." },
			},
		},
	},
	{
		id = "world_hana_exams",
		title = "Licensing Day",
		text = "The Hana Association's examiners have set up in an old school hall. The line of would-be Fixers runs around the block. An examiner with a clipboard looks you up and down. \"Exam, or are you just watching?\"",
		weight = 0,
		when = { minAge = 16 },
		codex = "fixers_hana",
		choices = {
			{
				label = "Take the exam",
				requires = { career = "none" },
				clash = { stat = "strength", foe = "The Hana exam", coins = 2, base = 5, coinPower = 3 },
				win = { career = "fixer", sanity = 3, chronicle = "licensed_fixer", log = "You passed. They printed your license while you watched: Grade 9 Fixer. It's the lowest grade there is, and you've never been prouder of anything." },
				lose = { sanity = -3, log = "You failed the practical. The examiner said to come back next year, in a tone that suggested you wouldn't." },
			},
			{
				label = "Cheer on the people in line",
				result = { sanity = 2, log = "You handed out water and cheered for strangers. Three of them passed." },
			},
		},
	},
	{
		id = "world_warp_delay",
		title = "Three Seconds Late",
		text = "The WARP train pulled in on time and then stood three minutes with its doors shut, while W Corp cleanup agents went aboard with sealed cases. Now the passengers are walking off, checking their watches, perfectly cheerful.",
		weight = 0,
		codex = "districts_w_corp",
		choices = {
			{
				label = "Ask a passenger about the delay",
				clash = { stat = "intelligence", foe = "An agent, noticing you ask", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 1, intelligence = 1, log = "\"What delay?\" the old woman said, and showed you her watch. Ten seconds, door to door. You carried her bag to the stairs and said nothing about the platform clock." },
				lose = { sanity = -4, log = "\"What delay?\" the old woman said. Behind her a cleanup agent had stopped mopping and was looking at you, and went on looking until you left." },
			},
			{
				label = "Look into the carriage",
				result = { sanity = -3, setFlags = { "saw_warp_carriage" }, log = "You looked into the carriage before a cleanup agent turned you round by the shoulder. A wet floor, a smell of bleach, rows of empty seats. Whatever there had been to see, you were too late for it." },
			},
			{
				label = "Walk away",
				result = { log = "You decided to go about your day. Three minutes isn't long. You thought about them for a week." },
			},
		},
	},
}
