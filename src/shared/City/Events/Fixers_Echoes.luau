--[[
	Echoes: one player's deed reaching other players' lives on the same server
	(when = { chronicle = "act" }; {actor} and {actorDistrict} name who and where).
	Every act in Chronicle/Fixers.luau has an echo here, plus the core acts
	licensed_fixer and defied_thumb. Also: the daily scenes (Daily/Fixers.luau) and the
	Color world event's opener (WorldEvents/Fixers.luau).
]]

return {
	-- ── echoes of Fixer deeds ──
	{
		id = "fx_echo_licensed",
		title = "A New Grade 9",
		text = "A courier brings the news to the noodle stall: {actor} has passed Hana's licensing exam in {actorDistrict}. Grade 9, the lowest grade there is, and everyone who has ever wanted to be a Fixer is quietly doing the sums on their own chances. The stall owner says he always knew {actor} would make it. He says that about everyone.",
		weight = 10,
		cooldown = 6,
		tags = { "fixers" },
		when = { chronicle = "licensed_fixer", minAge = 10 },
		choices = {
			{
				label = "Sit the exam yourself",
				hint = "25 Ahn",
				requires = { minAge = 16, notFlags = { "licensed_fixer" }, min = { money = 25 } },
				result = { money = -25, trigger = "fx_exam_hall", log = "If {actor} could pass it, so could you. You paid the fee that afternoon." },
			},
			{
				label = "Send them a lucky charm",
				hint = "10 Ahn",
				requires = { min = { money = 10 } },
				result = { money = -10, sanity = 2, log = "You sent {actor} a cheap lucky charm by courier. Every Grade 9 needs one. Most need several." },
			},
			{
				label = "Remember your own exam day",
				requires = { flags = { "licensed_fixer" } },
				result = { sanity = 3, log = "You remembered your own exam: the chalk circle, the forty questions, your heartbeat in your teeth. You raised your tea to {actor}, and to Grade 9s everywhere." },
			},
			{
				label = "Shrug it off",
				result = { mind = 1, log = "One more Grade 9 in a City full of them. Still, you found yourself reading the job boards on the way home." },
			},
		},
	},
	{
		id = "fx_echo_grade_one",
		title = "A Grade 1 in the City",
		text = "Word is on every job board: {actor} has been promoted to Grade 1 Fixer in {actorDistrict}, as high as the scale goes. Offices are raising their prices to look serious. Kids are practicing a walk they think is {actor}'s. Somebody at the noodle stall swears they knew {actor} back when {actor} fetched the noodles.",
		weight = 18,
		cooldown = 6,
		tags = { "fixers" },
		when = { chronicle = "fx_grade_one", minAge = 8 },
		codex = "fx_lore_grades",
		choices = {
			{
				label = "Raise a cup of tea to them",
				result = { sanity = 2, log = "You raised a cup of tea to a Fixer you've never met, and so did everyone at the stall. It felt as if the whole street had won something." },
			},
			{
				label = "Ask how they did it",
				result = { strength = 1, intelligence = 1, setFlags = { "fx_dream" }, log = "The answer, according to six different people, was clean job reports, no shortcuts, and being home before three. You wrote all three down." },
			},
			{
				label = "Undercut every Office in sight",
				requires = { career = "fixer" },
				result = { wage = { 40, 80 }, log = "With every Office raising its prices to keep up with a Grade 1, you lowered yours. Clients lined up around the block." },
			},
		},
	},
	{
		id = "fx_echo_color",
		title = "A New Color",
		text = "Hana has granted a new Color, and the name is {actor}, of {actorDistrict}. It happens maybe once in a generation. Every Office in the City is talking about nothing else, Rats are moving out of {actorDistrict} by the dozen, and the old Fixers at the noodle stall are arguing about whether the new Color is better than the Red Mist was.",
		weight = 25,
		cooldown = 10,
		tags = { "fixers" },
		when = { chronicle = "fx_color", minAge = 8 },
		codex = "fx_lore_colors",
		choices = {
			{
				label = "Join the argument",
				result = { sanity = 3, log = "You argued for an hour about a Fixer you'll probably never meet. Everyone lost the argument. Everyone had a wonderful time." },
			},
			{
				label = "Go and see the new Color",
				requires = { minAge = 14 },
				clash = { stat = "mind", foe = "A crowd of a thousand fans", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 4, setFlags = { "fx_saw_color" }, log = "You caught a glimpse across a crowded square: {actor}, perfectly ordinary, buying a bun. Somehow that made it better." },
				lose = { health = -3, sanity = -1, log = "You were jostled by a crowd of Grade 9s and saw only a coat, far away. It was a very good coat." },
			},
			{
				label = "Sit the exam this year",
				requires = { minAge = 16, notFlags = { "licensed_fixer" } },
				result = { intelligence = 2, setFlags = { "fx_dream" }, log = "If {actor} could become a Color, you could at least become a Grade 9. You bought an exam primer that night." },
			},
		},
	},
	{
		id = "fx_echo_new_office",
		title = "A New Sign",
		text = "A new Fixer Office has opened in {actorDistrict}: {actor}'s, with a hand-painted sign and a staff of one. Word travels between Districts the way it always does, through couriers and noodle stalls. Clients are curious, rival Offices are nervous, and someone has already tried to undercut {actor}'s prices.",
		weight = 12,
		cooldown = 6,
		tags = { "fixers" },
		when = { chronicle = "fx_office_founded", minAge = 14 },
		codex = "fx_lore_offices",
		choices = {
			{
				label = "Send a congratulations note",
				result = { sanity = 2, log = "You sent a note by Devyat' courier: congratulations on the sign. A note came back: thanks, and do you know anyone who's good at paperwork?" },
			},
			{
				label = "Ask if they're hiring",
				requires = { flags = { "licensed_fixer" } },
				result = { wage = { 30, 70 }, log = "{actor} was hiring. You took a contract they were too busy for, and it paid fairly, which is rarer than it should be." },
			},
			{
				label = "Think about your own sign",
				requires = { career = "fixer" },
				result = { sanity = 1, setFlags = { "fx_office_dream" }, log = "If {actor} could hang a sign, so could you. You started a jar labeled SIGN." },
			},
		},
	},
	{
		id = "fx_echo_office_raided",
		title = "The Ledger Came Out",
		text = "Everyone in the Backstreets is talking about it: {actor}'s crew raided a crooked Office in {actorDistrict} and walked out with the ledger it used to squeeze shopkeepers. The names in that ledger are free now. The Office's Fixers are on the street, angry and looking for work, or for someone to blame.",
		weight = 12,
		cooldown = 6,
		tags = { "fixers", "backstreets" },
		when = { chronicle = "fx_office_raided", minAge = 14 },
		choices = {
			{
				label = "Hire one of the out-of-work Fixers",
				hint = "60 Ahn",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 2, log = "You hired one to watch your door for a season. He was very good, very grateful, and never once mentioned the ledger." },
			},
			{
				label = "Check if your name was in it",
				clash = { stat = "mind", foe = "Rumors and copies of copies", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, wage = { 20, 60 }, log = "Your name had been in it, for a debt you'd forgotten. It isn't any more. Someone you've never met did you a very good turn." },
				lose = { sanity = -2, log = "Nobody could tell you anything for certain. You checked your locks twice that night, just in case." },
			},
			{
				label = "Keep clear of the angry Fixers",
				result = { mind = 1, log = "You took the long way home for a month. Angry Fixers with nothing to do are worse weather than rain." },
			},
		},
	},
	{
		id = "fx_echo_open_contract",
		title = "The Overpass Is Quiet",
		text = "The Open Contract is closed: {actor} cleared out the Urban Legend under the overpass in {actorDistrict}, and Hana has posted the result on every job board in the City. Escort prices on that road have dropped, the overpass is quiet, and a salvage crew is already selling what the monsters left behind.",
		weight = 12,
		cooldown = 6,
		tags = { "fixers" },
		when = { chronicle = "fx_open_contract", minAge = 12 },
		codex = "fx_lore_hazards",
		choices = {
			{
				label = "Buy a shell from the salvage crew",
				hint = "30 Ahn",
				requires = { min = { money = 30 } },
				result = { money = -30, wage = { 40, 80 }, log = "You bought a polished monster shell for thirty Ahn. A Workshop paid you double for it the next morning." },
			},
			{
				label = "Take the cheaper escort work",
				requires = { flags = { "licensed_fixer" } },
				result = { wage = { 40, 90 }, log = "With the overpass safe, escort jobs on that road were easy money. You took three." },
			},
			{
				label = "Hear the story from the crew",
				result = { sanity = 2, mind = 1, log = "The crew told you how {actor} did it. The story grew with every bowl of noodles. By the end there were twice as many monsters." },
			},
		},
	},

	-- ── echoes of the Fingers ──
	{
		id = "fn_echo_thumb_provoked",
		title = "Because Someone Was Rude",
		text = "The Thumb is collecting on your street a month early, and there's an extra line in every ledger. The Soldati explain it politely: in {actorDistrict}, someone named {actor} was rude to a Capo, and the Thumb is reminding the whole City how manners work. The senior Soldato taps the extra line. \"Courtesy,\" he says, \"is everyone's business.\"",
		weight = 25,
		cooldown = 5,
		tags = { "fingers", "backstreets" },
		when = { chronicle = "fn_thumb_provoked", minAge = 14, side = "backstreets", notFlags = { "fn_thumb_member" } },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Pay the extra line",
				hint = "30 Ahn",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = -1, log = "You paid for someone else's rudeness with exact change and a bow. The Soldato thanked you for your understanding." },
			},
			{
				label = "Ask for credit",
				result = { setFlags = { "fn_owes_thumb" }, condition = "fn_thumb_interest", addTrait = "in_debt_to_the_thumb", log = "The Soldato wrote your name in the credit column, with {actor}'s rudeness on the reason line. Interest, he said, is how the Thumb shows patience." },
			},
			{
				label = "Bow correctly and ask to be excused",
				clash = { stat = "charisma", foe = "A Soldato's ledger", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, setFlags = { "thumb_respect" }, log = "You bowed to exactly the right depth for a Soldato Quarto and asked to be excused from someone else's lesson. He was so impressed he crossed out the extra line." },
				lose = { money = -40, sanity = -2, log = "You bowed to the depth for a Soldato Terzo. He was a Quarto. The extra line doubled." },
			},
		},
	},
	{
		id = "fn_echo_defied",
		title = "The Door That Shut",
		text = "Everyone heard what {actor} did in {actorDistrict}: shut a door in the faces of two Thumb Soldati, in front of the whole street. Some people call it brave. The Thumb says nothing, which is louder. Today a Capo is walking your street, slowly, looking at doors. Yours is open. He looks at it.",
		weight = 16,
		cooldown = 6,
		tags = { "fingers", "backstreets" },
		when = { chronicle = "defied_thumb", minAge = 12, side = "backstreets" },
		codex = "fingers_thumb",
		choices = {
			{
				label = "Bow, and keep the door open",
				result = { sanity = -1, setFlags = { "thumb_respect" }, log = "You bowed and kept your door wide open until he'd passed. He nodded. On the Thumb's streets, doors that stay open are noticed." },
			},
			{
				label = "Close it, very politely",
				clash = { stat = "mind", foe = "A Capo's attention", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = 2, log = "You closed it so politely, with such a perfect bow, that he could find nothing to object to. You'd made a choice and got away with it. Like {actor}, almost." },
				lose = { health = { -6, -2 }, setFlags = { "fn_thumb_disrespected" }, log = "He came back and asked, very politely, whether you were a friend of {actor}'s. Your answer was not polite enough.", cause = "Corrected by the Thumb" },
			},
			{
				label = "Pay the street's contribution early",
				hint = "40 Ahn",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 1, log = "You paid a week early, in an envelope, with a perfect bow. The Capo noted it, and your street was spared the lesson {actor} had earned." },
			},
		},
	},
	{
		id = "fn_echo_written",
		title = "Asking About a Name",
		text = "Two Little Siblings of the Middle are going stall to stall with a photograph, asking about someone named {actor}, whose name was written into a Book of Vengeance in {actorDistrict}. They're polite. They're thorough. They ask you twice. \"The Middle remembers,\" one says, folding the photo away. \"It also remembers who helped.\"",
		weight = 16,
		cooldown = 6,
		tags = { "fingers" },
		when = { chronicle = "fn_written_in_book", minAge = 12, notFlags = { "fn_middle_member" } },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Say you've never heard the name",
				result = { sanity = -1, log = "You said you'd never heard of {actor}, which was true. They thanked you and wrote your name down anyway, in a different section. The helpful section, you hope." },
			},
			{
				label = "Tell them what you've heard",
				result = { sanity = -2, setFlags = { "fn_middle_favor" }, log = "You told them the rumors: a District, a street, a noodle stall. They thanked you warmly, like family. You felt warm and slightly ill." },
			},
			{
				label = "Warn {actor} by courier",
				hint = "15 Ahn",
				requires = { minAge = 16, min = { money = 15 } },
				result = { money = -15, sanity = 3, setFlags = { "fn_warned_actor" }, log = "You paid a Devyat' courier to carry two words to {actor}: they're asking. You'll never know if it arrived. Devyat' is never late, so it probably did." },
			},
		},
	},
	{
		id = "fn_echo_struck",
		title = "It Can Be Done",
		text = "The story is going around every teahouse: {actor}'s name was struck out of the Middle's Book of Vengeance. Struck out. Nobody can remember the last time it happened. People whose families have lived for years under a name in the Book are asking how {actor} did it, in low voices, with the door closed.",
		weight = 14,
		cooldown = 8,
		tags = { "fingers" },
		when = { chronicle = "fn_struck_from_book", minAge = 12 },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Find out how",
				result = { mind = 2, log = "A mediator the Middle respects, a debt paid in whichever form, and a Big Sister who decided it was enough. You wrote it all down, just in case." },
			},
			{
				label = "Start on your own name",
				requires = { flags = { "fn_middle_grudge" } },
				result = { quest = "fn_q_strike_the_name", sanity = 3, log = "If {actor} could do it, so could you. You started asking, very politely, who the Middle respects." },
			},
			{
				label = "Tell everyone on your stairs",
				result = { sanity = 3, log = "You told everyone on your stairs. An old woman whose family has been in the Book for years cried, and then made everyone soup." },
			},
		},
	},
	{
		id = "fn_echo_ricardo",
		title = "Rumors from the Lake",
		text = "A dockhand back from District 21 swears it's true, because {actor} was there and saw it: a Big Brother of the Middle in sunglasses, a stolen hair salon coupon, a Book of Vengeance read aloud on the Great Lake, and an old harpooner who came out of the fog. Everyone laughs at the coupon part. Then everyone stops laughing at the harpoon part.",
		weight = 12,
		cooldown = 10,
		tags = { "fingers" },
		when = { chronicle = "fn_ricardo_witness", minAge = 10 },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Laugh at the coupon part",
				clash = { stat = "mind", foe = "Somebody's Little Sister, listening", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, log = "You laughed, quietly. Nobody from the Middle was close enough to hear. You checked twice." },
				lose = { sanity = -2, log = "A woman with a tattoo on her wrist turned around at the next table. You stopped laughing. She smiled and turned back." },
			},
			{
				label = "Ask about the harpooner",
				result = { mind = 1, codex = "fx_lore_colors", log = "\"The Indigo Elder,\" the dockhand said, \"the Color who hunted the Marlin Whale. He wasn't there for the Big Brother. He was there to fish.\"" },
			},
		},
	},
	{
		id = "fn_echo_prescript",
		title = "Somebody Followed a Slip",
		text = "At exactly noon, a stranger in a plain coat hands you an umbrella, bows, and walks away. Later you hear it was {actor}, of {actorDistrict}, carrying out a Prescript of the Index to the letter. It doesn't rain that day. It rains the next day, hard, and you are the only dry person on your street.",
		weight = 10,
		cooldown = 8,
		tags = { "fingers", "strange" },
		when = { chronicle = "fn_prescript_done", minAge = 8 },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Keep the umbrella",
				result = { sanity = 3, log = "You kept the umbrella by your door. Some mornings you pick it up for no reason, and on those mornings it always rains." },
			},
			{
				label = "Pass it to the next stranger",
				result = { sanity = 2, mind = 1, log = "You handed it to the next stranger you passed. She looked at it, then at you, and said, \"Thank you. I was told to expect you.\"" },
			},
		},
	},
	{
		id = "fn_echo_sottocapo",
		title = "New Rules",
		text = "There's a new Sottocapo of the Thumb in {actorDistrict}: {actor}. The news travels the way Thumb news always travels, by Soldati with ledgers. On every Thumb street in the City, Soldati are rehearsing the new honorific, and anyone with business in {actorDistrict} is practicing a slightly deeper bow.",
		weight = 14,
		cooldown = 8,
		tags = { "fingers" },
		when = { chronicle = "fn_sottocapo", minAge = 12 },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Learn the new honorific",
				result = { mind = 1, setFlags = { "thumb_respect" }, log = "You learned the honorific by heart and used it once, correctly, in front of a Soldato. He looked at you as if you'd done a magic trick." },
			},
			{
				label = "Ask a Soldato about the new rules",
				clash = { stat = "mind", foe = "A Soldato's patience", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 1, log = "He told you everything: fees, bows, opening hours. You wrote it all down. That alone made him like you." },
				lose = { sanity = -2, log = "He told you that asking about the rules was itself against the rules. That seemed unfair. It was." },
			},
			{
				label = "Send the new Sottocapo a gift",
				requires = { career = "thumb" },
				result = { paycheck = 0.2, setFlags = { "thumb_respect" }, log = "You sent a gift with a perfect letter of congratulations. A Capo you'd never met nodded at you the next week." },
			},
		},
	},
	{
		id = "fn_echo_maestro",
		title = "An Invitation in Black",
		text = "Black cards are sliding under doors all over the City: an invitation to the first gallery of a new movement of the Ring, founded by {actor} of {actorDistrict}. The card is beautiful. The address is a laundry. Everyone who opens one says they won't go, and some of them are lying.",
		weight = 10,
		cooldown = 10,
		tags = { "fingers", "strange" },
		when = { chronicle = "fn_maestro", minAge = 14 },
		codex = "fn_lore_ring",
		choices = {
			{
				label = "Go to the opening",
				result = { sanity = -4, intelligence = 3, log = "You went. You won't describe it. You've seen the world slightly differently ever since, the way {actor} wanted." },
			},
			{
				label = "Burn the card",
				result = { sanity = 2, log = "You burned the card in the sink. The ash made a pattern on the steel. You decided it didn't." },
			},
		},
	},

	-- ── Today in the City (Daily/Fixers.luau) ──
	{
		id = "fx_daily_open_contract",
		title = "Open Contract Day",
		text = "Hana has posted an Open Contract on every job board in the District: a swarm of Trash Crabs crawled up out of the drains and into the market. Any licensed Fixer may take it, and Offices are racing each other through the stalls. Everyone else can carry gear, run messages, or sell tea to the Fixers.",
		weight = 0,
		codex = "fx_lore_hazards",
		choices = {
			{
				label = "Take the contract",
				requires = { flags = { "licensed_fixer" } },
				clash = { stat = "strength", foe = "A swarm of Trash Crabs", coins = 2, base = 4, coinPower = 3, fight = true, status = "rupture" },
				win = { wage = { 60, 120 }, strength = 1, log = "You cleared the fish market end to end. Hana's assessor counted the shells and signed your share." },
				lose = { health = { -6, -2 }, wage = { 10, 20 }, log = "The crabs were faster than they looked. You got paid for the ones you caught." },
			},
			{
				label = "Carry gear for an Office",
				result = { wage = { 20, 40 }, health = { -2, 0 }, log = "You carried a Grade 4's spare weapons all afternoon. She paid you, and let you hold the good sword." },
			},
			{
				label = "Sell tea to the Fixers",
				result = { wage = { 15, 35 }, sanity = 2, log = "You sold tea from a cart behind the Fixers' lines. Everyone was too busy to haggle." },
			},
		},
	},
	{
		id = "fn_daily_courtesy",
		title = "Courtesy Inspection",
		text = "The Thumb is inspecting manners on its streets today. Soldati stand at every corner with clipboards, marking bows: the depth, the timing, eyes on the third button, never the face. People who score well get their contribution lowered. People who don't get a lesson. A little girl in front of you is practicing on a lamppost.",
		weight = 0,
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Bow perfectly",
				clash = { stat = "charisma", foe = "A Soldato's clipboard", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, setFlags = { "thumb_respect" }, log = "Full marks. The Soldato stamped your hand with a tiny thumbprint, which on the Thumb's streets is practically a medal." },
				lose = { sanity = -2, money = -10, log = "Eyes on the second button. The Soldato sighed and fined you ten Ahn for imprecision." },
			},
			{
				label = "Help the little girl practice",
				result = { sanity = 3, intelligence = 1, log = "You showed her the depth and the timing. She scored higher than you did. The Soldato gave her a sweet." },
			},
		},
	},
	{
		id = "fn_daily_family_dinner",
		title = "Family Dinner",
		text = "The Middle is throwing a dinner in the square for its Siblings and their neighbors: long tables, enormous pots, a Big Brother ladling soup with his Book of Vengeance chained at his waist. Everyone is invited. Refusing an invitation from the Middle is, technically, a slight, and the Middle remembers slights.",
		weight = 0,
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Eat, and thank the cooks",
				result = { sanity = 4, health = 1, setFlags = { "fn_middle_favor" }, log = "You ate three bowls and thanked every cook by name. A Little Sister wrote your name in a notebook. Not the Book, she promised. The nice notebook." },
			},
			{
				label = "Help serve",
				result = { sanity = 3, intelligence = 1, setFlags = { "fn_middle_favor" }, log = "You ladled soup until your arms ached. A Big Brother called you Little Sibling by accident, then decided he meant it." },
			},
			{
				label = "Politely decline",
				clash = { stat = "mind", foe = "A Big Brother's hospitality", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 1, log = "You declined so graciously that the Big Brother sent a bowl home with you anyway." },
				lose = { sanity = -3, log = "\"No?\" said the Big Brother, reaching for his Book. Then he laughed. \"Joking. Mostly.\" You ate two bowls." },
			},
		},
	},

	-- ── the Color world event's opener (WorldEvents/Fixers.luau) ──
	{
		id = "fx_world_color",
		title = "A Color Passes Through",
		text = "Every Fixer in the District has gone quiet at once. Word is that a Color Fixer is passing through today, and nobody knows which one, or why. Office Reps are cancelling contracts. A Grade 2 you know is polishing his weapon with shaking hands. At the end of your street, a figure in a long coat stops to buy a bun.",
		weight = 0,
		codex = "fx_lore_colors",
		choices = {
			{
				label = "Pay for their bun",
				clash = { stat = "mind", foe = "A Color's full attention", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 5, setFlags = { "fx_saw_color" }, log = "They took the bun, thanked you, and asked how your day was going. You told them. They listened. Then they were gone, and the whole street breathed out." },
				lose = { sanity = -3, log = "Your hand shook so badly you dropped the coins. The Color picked them up, paid for the bun themselves, and gave you the change." },
			},
			{
				label = "Stay inside until they've gone",
				result = { mind = 1, sanity = -1, log = "You watched through the shutters until the coat turned the corner. Everyone on the street did the same." },
			},
			{
				label = "Ask for an autograph",
				result = { sanity = 3, log = "They signed your notebook with a name that wasn't a color at all. \"That's the real one,\" they said. \"Don't tell Hana.\"" },
			},
		},
	},
}
