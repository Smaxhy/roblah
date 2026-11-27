--[[
	Echoes (area A): what other players' deeds do to your life. Each fires only when someone
	else on the server has done the act (when.chronicle); {actor} and {actorDistrict} name
	them. Then the daily scenes (weight 0) for Daily/Life.luau.
]]

return {
	-- ── echoes of area A's acts ────────────────────────────────────────────
	{
		id = "bs_echo_night_walk",
		title = "The One Who Walked Home",
		text = "The whole noodle stall is talking about it: {actor} was caught outside during the Night in {actorDistrict}, and walked home at dawn. The old men at the counter say it's impossible. The cook says her grandmother did it once. A boy at the end of the counter asks you what you'd do if it happened to you.",
		weight = 12,
		once = true,
		when = { chronicle = "bs_act_night_walk", minAge = 10 },
		codex = "city_sweepers",
		choices = {
			{
				label = "\"Be home before three, so it never does.\"",
				result = { mind = 2, sanity = 1, log = "The whole counter nodded. The boy looked disappointed, and then, walking home at one o'clock sharp, a little relieved." },
			},
			{
				label = "\"Stand your ground. That's what the old Fixers say.\"",
				result = { strength = 2, sanity = -1, log = "\"They pass the ones strong enough to stand,\" you said, the way you'd heard it. The boy's eyes went very wide. You hoped he never had to find out." },
			},
			{
				label = "Ask how {actor} did it",
				result = { mind = 1, codex = "bs_lore_night_rules", log = "Nobody knew. Everybody had a theory. The one you remembered came from the cook: \"They had somewhere to get home to. That's half of it.\"" },
			},
		},
	},
	{
		id = "bs_echo_shelter",
		title = "Twelve Strangers on a Floor",
		text = "A courier at the bakery is telling anyone who'll listen: she got caught out last week in {actorDistrict}, at 3:09, and a stranger called {actor} held a shelter's door open for her until the last second. \"I didn't even know their name until morning,\" she says. \"I'd have been swept.\"",
		weight = 12,
		once = true,
		when = { chronicle = "bs_act_shelter", minAge = 12 },
		choices = {
			{
				label = "Collect blankets for the shelters on your street",
				result = { money = -15, sanity = 4, log = "You went door to door and collected thirty blankets for the night shelter on your street. Grandmother Ilse at the Lamplight House counted them twice and gave you a key to the back door." },
			},
			{
				label = "Tell your neighbors your door opens until 3:12",
				result = { sanity = 3, mind = 1, setFlags = { "bs_door_pledge" }, log = "You told everyone on your landing: if they're ever caught out, knock, and you'll open until 3:12. Nobody knocked that year. Everyone on the landing slept a little better anyway." },
			},
		},
	},
	{
		id = "bs_echo_rats_scattered",
		title = "Two Rats on the Stairs",
		text = "Since {actor} broke up the Rat pack in the tunnels under {actorDistrict}, its kids have scattered across the City. Two of them have turned up on your stairs: twelve, maybe thirteen, soaking wet, trying very hard to look dangerous and failing.",
		weight = 12,
		once = true,
		tags = { "backstreets" },
		when = { chronicle = "bs_act_rats_broken", minAge = 16, side = "backstreets" },
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Feed them",
				result = { money = -10, sanity = 4, log = "You fed them noodles on the stairs and didn't ask anything. The next week they were carrying crates for the grocer. The week after that, one of them was at the academy door." },
			},
			{
				label = "Walk them to the neighborhood watch",
				result = { mind = 2, sanity = 1, log = "You walked them to Grandpa Teo, who looked at them over his lamp and said, \"Hungry?\" The watch found them a cousin in the next street. Nobody pressed charges against two wet kids." },
			},
			{
				label = "Run them off",
				result = { speed = 1, sanity = -2, log = "You ran them off your stairs. They went without a word, the way Rats do. You saw one of them again a year later in a better coat, with a worse pack." },
			},
		},
	},
	{
		id = "bs_echo_route_parcel",
		title = "Early Delivery",
		text = "A parcel you weren't expecting until next week arrives this morning, carried by a rider in a reflective jacket on {actor}'s route out of {actorDistrict}. She won't take a tip. \"New owner's rules,\" she says. \"Never late, never curious, never paid twice. And every rider's home before three.\"",
		weight = 10,
		once = true,
		when = { chronicle = "bs_act_route_owner", minAge = 12 },
		choices = {
			{
				label = "Ask if the route is hiring",
				requires = { career = "none", minAge = 12 },
				result = { career = "courier", strength = 1, log = "She was. You started on Monday, on {actor}'s route, with a satchel, a map with half the streets crossed out, and a rule you already knew." },
			},
			{
				label = "Send a thank-you note back on the route",
				result = { sanity = 3, log = "You sent a note back to {actor} on the same route. It arrived early, of course. You got a reply the next day: a single line, \"Glad it came on time.\"" },
			},
		},
	},
	{
		id = "bs_echo_free_noodles",
		title = "Why Don't You Do That?",
		text = "Word has reached your corner: {actor} fed the whole street for free in {actorDistrict}, every bowl on the house, everyone home by three. Now every diner owner in your neighborhood is being asked, by every regular, why they don't do the same. Your local cook is in a very bad mood about it.",
		weight = 12,
		once = true,
		when = { chronicle = "bs_act_free_noodles", minAge = 8 },
		choices = {
			{
				label = "Organize a free night on your own street",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 5, log = "You chipped in, and so did the grocer, the baker and three Soldati who were embarrassed into it. Your street had its own free night. It wasn't as big as {actor}'s. It was yours." },
			},
			{
				label = "Defend your cook",
				result = { mind = 1, sanity = 2, log = "\"She feeds us every day,\" you told the regulars, \"and her prices haven't gone up in six years.\" The cook heard. Your bowl had extra scallions for a month." },
			},
		},
	},
	{
		id = "bs_echo_erased",
		title = "A Name You Can't Hold",
		text = "There's a rumor going round the market that someone in {actorDistrict} recorded the Night. Someone called... you heard the name a moment ago. {actor}? The woman who told you is already frowning, as if she can't remember what she was saying. The name keeps sliding off your mind like water off a window.",
		weight = 10,
		once = true,
		when = { chronicle = "bs_act_recorded_night", minAge = 10 },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Write the name down, quickly",
				result = { mind = 2, sanity = -3, setFlags = { "bs_remembers_erased" }, log = "You wrote \"{actor}\" on the back of your hand. By evening you had no idea who it was, only that you had written it, and that it had been important. You didn't wash it off for three days." },
			},
			{
				label = "Let it go",
				result = { sanity = 1, log = "You let it go. By the time you got home you couldn't have said what the rumor was about. Only that you'd checked your curtains twice that night, and didn't know why." },
			},
		},
	},
	{
		id = "bs_echo_academy",
		title = "Evening Classes",
		text = "A notice on the bathhouse wall: {actor} has opened a new academy in {actorDistrict}, and it takes evening students for almost nothing: letters, bookkeeping, the history of the Wings, \"and the rules that keep you alive.\" Underneath, in pencil, someone has written: IT'S GOOD.",
		weight = 10,
		once = true,
		when = { chronicle = "bs_act_academy", minAge = 12 },
		choices = {
			{
				label = "Take an evening class",
				result = { money = -10, intelligence = 3, log = "You made the long trip to {actorDistrict} once a week for a season, always back by one, and learned bookkeeping in a room with eleven other tired people. It was worth every Ahn." },
			},
			{
				label = "Pass the notice on to someone who needs it",
				result = { sanity = 3, log = "You copied the notice out and pinned it to your own street's board, next to the job board. Three kids from your street went. One of them sent you a letter in very careful handwriting." },
			},
		},
	},
	{
		id = "bs_echo_clinic",
		title = "The Clinic That Stayed Open",
		text = "A courier patched up in {actorDistrict} is showing everyone her stitches: neat, small, perfect. \"Turf war,\" she says. \"Every clinic in the District shut its shutters except one. {actor}'s. They treated both sides and wouldn't let anyone fight in the waiting room.\"",
		weight = 10,
		once = true,
		when = { chronicle = "bs_act_clinic_open", minAge = 12 },
		choices = {
			{
				label = "Go there to get patched up",
				requires = { min = { money = 20 } },
				result = { money = -20, health = { 6, 12 }, cure = "any", log = "You made the trip to {actorDistrict} and sat in {actor}'s waiting room behind a dock worker and a Thumb Soldato who said good evening to each other. The clinic fixed what the year had broken." },
			},
			{
				label = "Send them a box of bandages",
				result = { money = -10, sanity = 3, log = "You sent a box of bandages with a courier. It came back empty a month later, with a note: \"Used every one. Thank you.\"" },
			},
		},
	},

	-- ── an echo of a core act: the open door ───────────────────────────────
	{
		id = "bs_echo_open_door",
		title = "The Door That Opened",
		text = "Everyone on your stairs is arguing about the same story: during the Night in {actorDistrict}, {actor} opened their own door to let a stranger in, and lived. Opening a door during the Night is allowed; it's your door. Almost nobody does it. \"Brave,\" says the woman on the third floor. \"Mad,\" says her brother.",
		weight = 12,
		once = true,
		when = { chronicle = "opened_door_night", minAge = 10 },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "\"Brave.\"",
				result = { sanity = 2, strength = 1, setFlags = { "bs_door_pledge" }, log = "\"Brave,\" you said. You found yourself checking, that night, how fast your own locks turned. Fast enough, you decided, if it ever came to it." },
			},
			{
				label = "\"Mad.\"",
				result = { mind = 2, log = "\"Mad,\" you said. \"Lucky and mad.\" The brother nodded. His sister looked at you both for a long time and said, \"Somebody opened theirs for me once.\"" },
			},
			{
				label = "Ask what happened to the stranger",
				result = { sanity = 3, log = "Nobody knew for sure. The best version of the story, the one you decided to believe, was that the stranger moved in next door to {actor} and the two of them have tea every night at 3:13." },
			},
		},
	},

	-- ── Today in the City (Daily/Life.luau) ────────────────────────────────
	{
		id = "bs_daily_lock_day",
		title = "Lock Day",
		text = "Once a year the locksmiths of the District set up their tables in the market square: new locks, old locks, locks from Workshops with famous marks, and a competition for the fastest picking. A grandmother with a tray of keys on strings is selling \"a key for every child who hasn't got one yet.\"",
		weight = 0,
		choices = {
			{
				label = "Enter the lock-picking competition",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Forty locks and a stopwatch", coins = 2, base = 3, coinPower = 2 },
				win = { wage = { 30, 70 }, intelligence = 2, log = "You picked forty locks in under ten minutes and won a prize, a commemorative lock nobody could pick, and the respect of three old Workshop smiths." },
				lose = { intelligence = 1, sanity = 1, log = "You got stuck on lock twelve and laughed about it with a Grade 6 Fixer who got stuck on lock eleven." },
			},
			{
				label = "Buy a key on a string",
				requires = { min = { money = 25 } },
				result = { money = -25, gear = "bs_house_key", sanity = 2, log = "You bought a key on a string from the grandmother. She threaded it herself and hung it round your neck. \"Home before three,\" she said, like a blessing." },
			},
			{
				label = "Buy a better third lock for your door",
				requires = { min = { money = 15 } },
				result = { money = -15, mind = 2, sanity = 2, log = "You bought a solid Workshop lock and fitted it that afternoon. Three locks, one of them good. You slept better than you had in months." },
			},
		},
	},
	{
		id = "bs_daily_watch_night",
		title = "Watch Night",
		text = "The neighborhood watch is short-handed tonight: half its members have the fever going round. Grandpa Teo is standing at the corner with a spare lamp, a whistle, and a hopeful expression. \"One round,\" he says. \"Every door, before half past two.\"",
		weight = 0,
		codex = "bs_lore_watch",
		choices = {
			{
				label = "Walk the round with him",
				clash = { stat = "strength", foe = "Rats at the pharmacy shutters", coins = 2, base = 3, coinPower = 2, fight = true },
				win = { strength = 2, sanity = 3, log = "You caught three Rats trying the pharmacy shutters and sent them running with the lamp swinging and the whistle going. Grandpa Teo said you'd make a fine watchman. Then he said it again, louder, to the whole street." },
				lose = { health = { -6, -2 }, sanity = 1, log = "The Rats were faster than you and took a swing on the way past. You finished the round anyway, every door, with a fat lip. Grandpa Teo walked you home last.", cause = "Beaten by Rats on watch" },
			},
			{
				label = "Walk the old people home instead",
				result = { sanity = 4, mind = 1, log = "You walked seven old people home from the bathhouse, the tea house and the market, one by one, slowly. All of them were inside by two. Three of them gave you sweets. One gave you advice you'll never forget." },
			},
		},
	},
	{
		id = "bs_daily_exam_day",
		title = "Exam Day",
		text = "It's the Wing's entrance exam today, and the examinee towns have emptied into the streets: thousands of tired young people in their best clothes walking to the exam hall in silence, some of them mouthing dates and numbers to themselves. A boy sits down on the curb beside you, white as paper. \"I can't remember anything,\" he says.",
		weight = 0,
		codex = "bs_lore_examinee",
		choices = {
			{
				label = "Quiz him on the way to the hall",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A whole year of cramming", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 2, sanity = 3, log = "You quizzed him all the way to the hall, and he got every answer, and the color came back into his face. You never found out if he passed. You decided he did." },
				lose = { sanity = 1, log = "You asked him the wrong questions and he got more nervous. At the hall doors he laughed, suddenly, and said, \"At least I'm not as bad as you.\" He walked in standing straighter." },
			},
			{
				label = "Sell tea to the examinees",
				result = { wage = { 20, 50 }, log = "You set up a tea stand on the corner by the exam hall. You sold out by nine. Half the examinees paid you with their last coins and their best wishes." },
			},
		},
	},
	{
		id = "bs_daily_moving_day",
		title = "Moving Day",
		text = "It's the day the landlords raise the rents, and half the street is moving: boxes on every staircase, handcarts in every alley, children carrying lamps, and everyone keeping one eye on the clock, because nobody wants to be carrying a wardrobe down the street at three in the morning.",
		weight = 0,
		choices = {
			{
				label = "Help a family get moved before the Night",
				hint = "Health check: four flights, one wardrobe.",
				clash = { stat = "health", foe = "A wardrobe and four flights of stairs", coins = 2, base = 3, coinPower = 2 },
				win = { health = 2, sanity = 3, wage = { 10, 25 }, log = "You and the family got everything moved by half past one: the wardrobe, the beds, the grandmother, the cat. They paid you in dumplings and a promise to help when it's your turn." },
				lose = { condition = "bs_bad_back", sanity = 1, log = "The wardrobe won on the third landing. You got it there in the end, and the family got home by two, and your back reminded you about it for three years." },
			},
			{
				label = "Haggle down your own rent",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A landlord on rent day", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 20, 50 }, charisma = 1, log = "You reminded the landlord how many years you'd paid on time and how many tenants were moving out today. Your rent stayed where it was." },
				lose = { money = { -20, -10 }, log = "The landlord had a reply for everything. Your rent went up like everyone else's." },
			},
		},
	},
}
