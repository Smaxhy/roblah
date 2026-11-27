--[[
	Childhood, ages 4-12 (area A): the City taught through play. The rules of the Night,
	the Nest wall, the WARP line, Rats, the Fixer down the street, the academy, your first
	Ahn, a Workshop window, a Wing's billboard. Every event is `once`; several open arcs
	that pay off years later (see Life_Arcs.luau). Origin-specific scenes are in
	Life_Origins.luau, District scenes in Life_Districts.luau.
]]

return {
	-- ── the City, seen small ───────────────────────────────────────────────
	{
		id = "bs_c_warp_train",
		title = "The Train Across the Sky",
		text = "From the roof of your building you can see the WARP line: a silver rail laid straight across the City, above everything. A train flashes along it and is gone before you can blink. A whole train. Gone. The old man who keeps pigeons up here says a ticket costs more than your family makes in a season, and that the trip takes ten seconds. \"For the people watching,\" he adds.",
		weight = 14,
		once = true,
		when = { minAge = 4, maxAge = 9 },
		choices = {
			{
				label = "Promise yourself you'll ride it someday",
				result = { sanity = 2, setFlags = { "bs_warp_dream" }, log = "You promised the sky you'd ride it someday. The pigeon man said everybody promises that. He said it like he'd promised it too, a long time ago." },
			},
			{
				label = "Ask what he means, \"for the people watching\"",
				result = { mind = 1, sanity = -1, codex = "districts_w_corp", log = "He took a long time to answer. \"Ask somebody who's ridden it,\" he said, \"and watch their face when they tell you it was quick.\"" },
			},
			{
				label = "Race the next train along the roof",
				result = { speed = 1, health = 1, log = "You ran the length of the roof as the next train went over. It beat you by about a whole roof. You were furious for a day and practiced for a month." },
			},
		},
	},
	{
		id = "bs_c_checkpoint",
		title = "The Checkpoint Line",
		text = "{mother} has a day's work cleaning offices inside the Nest, and nobody could watch you, so you're in the checkpoint line with her. Everyone in the line holds their papers the same way: flat, in both hands, like an offering. The guard at the gate has two guns and a very clean face.",
		weight = 12,
		once = true,
		when = { side = "backstreets", hasRelation = "mother", minAge = 5, maxAge = 10 },
		codex = "bs_lore_nests",
		choices = {
			{
				label = "Stand perfectly still",
				result = { mind = 2, log = "You stood so still the guard noticed and nodded at you, the way you'd nod at a well-behaved dog. {mother} squeezed your hand all the way through." },
			},
			{
				label = "Ask the guard why he needs two guns",
				result = { sanity = 2, gear = "lucky_sticker", log = "The guard laughed, actually laughed, and peeled a shiny Wing sticker off his clipboard for you. \"For luck,\" he said. \"You'll need it out there.\" {mother} didn't let go of your hand until you were through." },
			},
			{
				label = "Look through the gate at the clean streets",
				result = { sanity = -1, setFlags = { "bs_nest_dream" }, log = "Inside, the streets were so clean they shone, and nobody was in a hurry. You looked back at the line of tired people with their papers, and decided, without telling anyone, that one day you'd live on the clean side." },
			},
		},
	},
	{
		id = "bs_c_ottavio",
		title = "The Fixer Down the Street",
		text = "Ottavio sits outside his shuttered Office every afternoon with a cane across his knees. He was a Fixer, a good one, Grade 4 for twenty years, until a job took his knee and gave him a lot of free time. He has a story for every scar. Today a gang of kids is daring each other to ask about the long one on his neck.",
		weight = 14,
		once = true,
		when = { side = "backstreets", minAge = 6, maxAge = 10 },
		choices = {
			{
				label = "Ask him about the scar",
				result = {
					strength = 1,
					mind = 1,
					setFlags = { "bs_ottavio_known" },
					schedule = { event = "bs_y_ottavio_yard", inYears = 6 },
					codex = "fingers_thumb",
					log = "\"A Thumb Soldato,\" he said, \"and I called him by his first name.\" He let that sit. \"Never call a Capo by his name. Never touch a Middle tattoo. Never read a slip of paper that isn't yours.\" You repeated it all the way home until it stuck.",
				},
			},
			{
				label = "Ask him how to become a Fixer",
				result = {
					strength = 1,
					setFlags = { "bs_ottavio_known", "bs_fixer_dream" },
					schedule = { event = "bs_y_ottavio_yard", inYears = 6 },
					codex = "fixers_hana",
					log = "\"Pass the Hana Association's exam, join an Office, and don't die,\" he said. \"The third part is the hard one.\" You asked how he'd managed it. \"Mostly,\" he said, \"by being home before three.\"",
				},
			},
			{
				label = "Ask if he's ever been out during the Night",
				result = {
					mind = 1,
					sanity = -1,
					setFlags = { "bs_ottavio_known" },
					schedule = { event = "bs_y_ottavio_yard", inYears = 6 },
					log = "He went quiet for a long time. \"Once,\" he said. \"I stood my ground. That's the only thing they let past.\" He didn't tell any more stories that day, and the other kids blamed you.",
				},
			},
		},
	},
	{
		id = "bs_c_first_ahn",
		title = "Your First Ahn",
		text = "Mr. Szamos at the hardware stall needs a box of hinges carried up to a third-floor flat. It's heavy and the stairs are steep, and when you come back down he presses a coin into your hand. Five Ahn. Your first real money. It's still warm from his pocket.",
		weight = 14,
		once = true,
		when = { minAge = 6, maxAge = 10 },
		codex = "terms_ahn",
		choices = {
			{
				label = "Save it in a jar",
				result = { money = 5, intelligence = 1, setFlags = { "bs_saver" }, log = "You put it in a jar under your bed. You checked it every night, the way the grown-ups checked the locks." },
			},
			{
				label = "Buy a skewer from the cart",
				result = { sanity = 3, log = "You bought a skewer of something grilled and ate it standing up, like a grown-up with money. It was the best thing you had ever tasted, and you knew exactly what it had cost." },
			},
			{
				label = "Ask if he has another job",
				result = { money = 12, health = 1, setFlags = { "bs_hustler" }, log = "You asked for more work. Mr. Szamos laughed and handed you a broom. By sundown you had twelve Ahn and very dusty knees, and a regular Saturday job." },
			},
		},
	},
	{
		id = "bs_c_academy",
		title = "The Academy on the Corner",
		text = "The academy on the corner takes new students every spring: three rooms, two teachers, one cat. It costs, so not every kid on the street goes. Teacher Imre, a stooped man with chalk on every sleeve, is giving the new ones a little test at the door: count backward from twenty, and say the rule.",
		weight = 30,
		once = true,
		when = { side = "backstreets", minAge = 6, maxAge = 8 },
		choices = {
			{
				label = "Take the test",
				hint = "Intelligence check. Teacher Imre is very patient.",
				clash = { stat = "intelligence", foe = "Counting backward from twenty", coins = 1, base = 1, coinPower = 2 },
				win = {
					intelligence = 2,
					setFlags = { "bs_academy_enrolled" },
					schedule = { { event = "bs_c_kasimir", inYears = 3 }, { event = "bs_y_graduation", inYears = 10 } },
					log = "You counted backward from twenty without a mistake and said \"home before three\" so loudly the cat left the room. Teacher Imre wrote your name in his big book.",
				},
				lose = {
					intelligence = 1,
					setFlags = { "bs_academy_enrolled" },
					schedule = { { event = "bs_c_kasimir", inYears = 3 }, { event = "bs_y_graduation", inYears = 10 } },
					log = "You got stuck at eleven. Teacher Imre wrote your name in the big book anyway. \"Eleven is a fine place to start,\" he said.",
				},
			},
			{
				label = "Say you'd rather work",
				result = { money = 5, health = 1, setFlags = { "bs_no_academy" }, log = "You said you'd rather earn. Teacher Imre nodded as if he'd heard it a thousand times. \"The door's open in the evenings,\" he said. You walked past it every day." },
			},
		},
	},
	{
		id = "bs_c_kasimir",
		title = "The Best Student",
		text = "Kasimir Vogt is the best student at the academy and makes sure everyone knows it. His uncle is a Soldato of the Thumb, so nobody argues with him. Today he has taken your seat by the window, and your pencil, and he's waiting to see what you'll do about it.",
		weight = 0,
		when = { flags = { "bs_academy_enrolled" }, maxAge = 14 },
		choices = {
			{
				label = "Beat him at the sums test",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Kasimir's sums", coins = 1, base = 2, coinPower = 2 },
				win = {
					intelligence = 2,
					setFlags = { "bs_kasimir_rival", "bs_kasimir_outsmarted" },
					addRelation = { kind = "rival", name = "Kasimir Vogt", bond = 25, age = { 9, 10 } },
					schedule = { event = "bs_a_kasimir_feather", inYears = 20 },
					log = "You finished the sums first, every answer right. Kasimir finished second and stared at the back of your head until the bell. He kept staring for the next seven years.",
				},
				lose = {
					intelligence = 1,
					sanity = -1,
					setFlags = { "bs_kasimir_rival", "bs_kasimir_outsmarted" },
					addRelation = { kind = "rival", name = "Kasimir Vogt", bond = 20, age = { 9, 10 } },
					schedule = { event = "bs_a_kasimir_feather", inYears = 20 },
					log = "He beat you by one sum and told the whole yard. You started studying at night by the light from the street, just to beat him next time. You did, eventually. He never forgave you.",
				},
			},
			{
				label = "Take your seat back, in the yard",
				clash = { stat = "strength", foe = "Kasimir Vogt", coins = 1, base = 2, coinPower = 2, fight = true },
				win = {
					strength = 2,
					setFlags = { "bs_kasimir_rival", "bs_kasimir_fought" },
					addRelation = { kind = "rival", name = "Kasimir Vogt", bond = 15, age = { 9, 10 } },
					schedule = { event = "bs_a_kasimir_capo", inYears = 20 },
					log = "You knocked him flat in the yard in front of everyone. He got up, brushed off his good coat and said, very quietly, \"You'll remember this.\" Kids from your street still talk about it.",
				},
				lose = {
					health = { -4, -2 },
					setFlags = { "bs_kasimir_rival", "bs_kasimir_fought" },
					addRelation = { kind = "rival", name = "Kasimir Vogt", bond = 15, age = { 9, 10 } },
					schedule = { event = "bs_a_kasimir_capo", inYears = 20 },
					log = "He'd had lessons. You hadn't. He sat on your back and explained, very politely, the order of things. You never forgot the explanation.",
				},
			},
			{
				label = "Offer to share the window seat",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Kasimir's pride", coins = 1, base = 2, coinPower = 2 },
				win = {
					sanity = 3,
					setFlags = { "bs_kasimir_peace" },
					addRelation = { kind = "friend", name = "Kasimir Vogt", bond = 55, age = { 9, 10 } },
					schedule = { event = "bs_a_kasimir_friend", inYears = 20 },
					log = "He was so surprised that he said yes. You shared the window seat for seven years, and your lunch, and eventually your secrets. His uncle sent you a sweet every holiday.",
				},
				lose = {
					sanity = -1,
					setFlags = { "bs_kasimir_rival", "bs_kasimir_outsmarted" },
					addRelation = { kind = "rival", name = "Kasimir Vogt", bond = 20, age = { 9, 10 } },
					schedule = { event = "bs_a_kasimir_feather", inYears = 20 },
					log = "\"Share?\" said Kasimir, as if you'd suggested something absurd. He kept the seat. You kept the grudge.",
				},
			},
		},
	},
	{
		id = "bs_c_tamas_camera",
		title = "The Camera",
		text = "Tamas from the fourth floor found a broken camera in a skip and fixed it himself. Tonight he's going to climb to the roof and film the Night, the Sweepers, all of it, and sell the film to a collector in the Nest for a fortune. \"Nobody's ever done it,\" he says. You know why. Recording the Night is a City Taboo, one of the Head's own laws, and nobody breaks those twice.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Talk him out of it",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "Tamas's big idea", coins = 1, base = 2, coinPower = 2 },
				win = { charisma = 2, setFlags = { "bs_tamas_saved" }, schedule = { event = "bs_a_tamas_photographer", inYears = 16 }, log = "You told him everything you'd ever heard about the Taboos and the Claws, and a few things you made up. He went pale. He kept the camera, but he packed it away every night at one o'clock sharp." },
				lose = { sanity = -1, setFlags = { "bs_tamas_filmed" }, schedule = { event = "bs_c_tamas_gone", inYears = 1 }, log = "He laughed at you. \"You sound like my grandmother.\" That night, from your bed, you heard someone climbing the fire escape at five past three." },
			},
			{
				label = "Grab the camera and hide it",
				hint = "Strength check. He's bigger than you.",
				clash = { stat = "strength", foe = "Tamas's grip", coins = 1, base = 2, coinPower = 2 },
				win = { strength = 1, sanity = -1, setFlags = { "bs_tamas_saved" }, schedule = { event = "bs_a_tamas_photographer", inYears = 16 }, log = "You grabbed it and ran, and hid it inside the dead stove in the basement. He didn't speak to you for a month. Years later, out of nowhere, he said thank you." },
				lose = { setFlags = { "bs_tamas_filmed" }, schedule = { event = "bs_c_tamas_gone", inYears = 1 }, log = "He held on, and he was bigger. That night, from your bed, you heard someone climbing the fire escape at five past three." },
			},
			{
				label = "Tell his grandmother",
				result = { sanity = 1, setFlags = { "bs_tamas_saved" }, schedule = { event = "bs_a_tamas_photographer", inYears = 16 }, log = "His grandmother took the camera away and didn't give it back until he was twenty. He called you a snitch until he was twenty, too." },
			},
			{
				label = "Say nothing",
				result = { sanity = -2, setFlags = { "bs_tamas_filmed" }, schedule = { event = "bs_c_tamas_gone", inYears = 1 }, log = "It wasn't your business. That night, from your bed, you heard someone climbing the fire escape at five past three." },
			},
		},
	},
	{
		id = "bs_c_billboard",
		title = "The Billboard",
		text = "A new billboard has gone up over the market, three stories tall: a smiling Feather in a crisp uniform with the {corp} badge on her chest, and the words A FEATHER'S LIFE IS A GOOD LIFE. Underneath, smaller: entrance exams every spring. Somebody has already drawn a mustache on her, very high up. Nobody knows how.",
		weight = 12,
		once = true,
		when = { minAge = 7, maxAge = 12, notDistrict = "d12" },
		choices = {
			{
				label = "Learn the slogan by heart",
				result = { intelligence = 1, mind = 1, setFlags = { "bs_wing_dream" }, codex = "bs_lore_feathers", log = "A Feather's life is a good life. A badge, a wage, a room inside the wall. You said it to yourself all the way home. It sounded like a door you could walk through, if you studied hard enough." },
			},
			{
				label = "Work out how the mustache got up there",
				result = { strength = 1, setFlags = { "bs_climber" }, log = "It took you a week: the drainpipe, the ledge, the back of the sign's frame. You never climbed it yourself. Knowing that you could was enough. The mustache stayed up for a year." },
			},
			{
				label = "Ask a grown-up what Feathers really do",
				result = { mind = 2, codex = "bs_lore_feathers", log = "\"Whatever the Wing says,\" said the old man at the newspaper stand. \"Good money, though. Good money. Nobody from this street ever passed the exam, mind.\" He said it like a dare." },
			},
		},
	},
	{
		id = "bs_c_rat_mugging",
		title = "Rats in the Alley",
		text = "Three older kids step out of the alley by the laundry and spread out across the path, the way Rats do. The biggest holds out his hand. \"Shopping money. And the bag.\" You're carrying the family's groceries and the change, and nobody else is on the street.",
		weight = 12,
		once = true,
		tags = { "danger", "backstreets" },
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Fight",
				clash = { stat = "strength", foe = "Three Rat kids", coins = 1, base = 2, coinPower = 2, fight = true },
				win = { strength = 2, sanity = 1, log = "You swung the grocery bag like a hammer. A tin of beans did the rest. They ran. You got home with dented groceries and a reputation." },
				lose = { health = { -6, -3 }, sanity = -2, log = "They took the bag and the change and left you sitting in a puddle. The family went without that week. Nobody blamed you, which was worse.", cause = "Mugged by Rats" },
			},
			{
				label = "Run the long way round",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "Three pairs of longer legs", coins = 1, base = 2, coinPower = 2 },
				win = { strength = 1, health = 1, log = "You ran the long way round, through the fish market and over the wall behind the laundry. They gave up at the fish market. Rats hate the fish market." },
				lose = { health = { -3, -1 }, sanity = -2, log = "They caught you at the wall and took the change. They let you keep the groceries. \"We're not animals,\" said the big one." },
			},
			{
				label = "Talk to them like a grown-up",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "Three suspicious Rats", coins = 1, base = 2, coinPower = 2 },
				win = { charisma = 2, log = "You told them the groceries were for old Mrs. Halas upstairs, whose nephew was a Big Brother of the Middle. It wasn't true. They didn't want to find out, and melted back into the alley." },
				lose = { sanity = -2, log = "\"Nice try,\" said the big one, and took the change. They left the groceries. Rats can't cook." },
			},
			{
				label = "Hand it over",
				result = { sanity = -2, mind = 1, log = "You handed over the change. They let you keep the groceries, and the big one even said thanks. You walked home shaking, and from that night on you took the long way." },
			},
		},
	},
	{
		id = "bs_c_workshop_window",
		title = "The Workshop Window",
		text = "Brassfinch Workshop has a big front window, and in it, every afternoon, a woman in a leather apron with one mechanical arm etches a maker's mark into a new blade: a little bird with a key in its beak. Sparks, steam, the smell of hot oil. You've been watching for an hour. So has she, it turns out. She taps on the glass and points at the broom.",
		weight = 12,
		once = true,
		when = { minAge = 8, maxAge = 12 },
		codex = "bs_lore_workshops",
		choices = {
			{
				label = "Go in and pick up the broom",
				result = { intelligence = 2, setFlags = { "bs_workshop_window" }, log = "You swept the floor of Brassfinch Workshop until it shone. Master Ulrike paid you in scrap metal and let you stay and watch. You came back every day after that." },
			},
			{
				label = "Keep watching from outside",
				result = { intelligence = 1, mind = 1, setFlags = { "bs_workshop_window" }, log = "You watched from the window every day for a year. You learned how a blade is folded, how a mark is etched, and that Master Ulrike hums when a piece is going well." },
			},
			{
				label = "Pocket a scrap from the bin out back",
				result = { strength = 1, money = 3, setFlags = { "bs_workshop_window" }, log = "You took a bright offcut from the bin behind the shop and sold it. The next day there was a sign on the bin: TAKE ONE, BUT ASK. You asked. She said yes, and that you owed her a floor." },
			},
		},
	},
	{
		id = "bs_c_fever",
		title = "Half Past Two",
		text = "The neighbor is banging on your door at half past two in the morning. Her baby has a fever and won't stop crying, and the clinic doctor lives six streets away. Everyone knows the clock: forty-three minutes until the Night. The grown-ups are arguing about who should go. You're the fastest kid on the street.",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Run for the doctor",
				hint = "Speed check. You have until 3:13.",
				clash = { stat = "speed", foe = "Six wet streets", coins = 1, base = 2, coinPower = 2 },
				win = { speed = 2, sanity = 3, setFlags = { "bs_neighbor_grateful" }, schedule = { event = "bs_a_neighbor_baby", inYears = 18 }, log = "You ran the six streets in a time nobody believed and hammered on the doctor's door. You were both inside the neighbor's flat by five past three. The baby lived. The doctor told you never, ever to do that again." },
				lose = { health = { -3, -1 }, sanity = -3, condition = "bs_sprained_ankle", setFlags = { "bs_neighbor_grateful" }, schedule = { event = "bs_a_neighbor_baby", inYears = 18 }, log = "You fell on the wet steps and limped the rest of the way. You got the doctor, and got back at 3:11 with the floor already humming. The baby lived. You didn't sleep for two nights." },
			},
			{
				label = "Run to Auntie Mun's for her fever syrup",
				requires = { flags = { "bs_knows_mun" } },
				result = { sanity = 3, mind = 1, setFlags = { "bs_neighbor_grateful" }, schedule = { event = "bs_a_neighbor_baby", inYears = 18 }, log = "Auntie Mun lived two streets away and kept a bottle of fever syrup for exactly this. You were back in eight minutes. The baby was asleep before three. The neighbor never forgot it." },
			},
			{
				label = "Hold the baby while they argue",
				result = { sanity = 1, charisma = 1, log = "You held the baby and hummed while the grown-ups argued. Somewhere in the arguing she fell asleep, and the fever broke by morning. Everyone gave you the credit. You took it." },
			},
		},
	},
	{
		id = "bs_c_lost",
		title = "Lost",
		text = "One moment you're holding a grown-up's hand in the night market, the next you're holding nothing. The crowd is a forest of legs and shopping bags, and every alley looks the same. Somewhere, a clock strikes one. You're small, it's late, and the Backstreets are very big.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 7 },
		choices = {
			{
				label = "Ask the woman in the gray coat",
				result = { sanity = 2, setFlags = { "bs_met_marisol" }, schedule = { event = "bs_y_marisol", inYears = 10 }, log = "The woman in the long gray coat had a Fixer's badge and a tired face. She asked your street, sighed, and walked you home without letting go of your hand. At your door she said, \"That one's free. Don't tell anyone,\" and was gone." },
			},
			{
				label = "Climb up and look for your building",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A wobbly stack of crates", coins = 1, base = 1, coinPower = 2 },
				win = { strength = 1, health = 1, log = "You climbed a stack of crates and spotted your building's crooked water tank above the roofs. You followed it home like a star, and were in bed by two, very proud." },
				lose = { health = -2, sanity = -2, log = "The crates fell over and so did you. A stallholder picked you up, dusted you off and bellowed your description down the market until your family came running." },
			},
			{
				label = "Follow the smell of Auntie Mun's broth",
				requires = { flags = { "bs_knows_mun" } },
				result = { sanity = 3, log = "You followed your nose three streets to Auntie Mun's stall. She fed you while someone ran for your family. It was, you maintain to this day, the best night of your childhood." },
			},
			{
				label = "Sit down and wait",
				result = { mind = 1, sanity = -1, log = "You sat on the curb and didn't move, just as you'd been taught. It took an hour. Your family found you there, white-faced, and held on to you all the way home." },
			},
		},
	},
	{
		id = "bs_c_cat",
		title = "The Cat With a Collar",
		text = "There's a cat under the stairs. Not a street cat: a fat, glossy cat with a velvet collar and a little brass tag. The address on the tag is inside the Nest. The cat looks at you as if you work for it.",
		weight = 10,
		once = true,
		when = { minAge = 4, maxAge = 10 },
		choices = {
			{
				label = "Take it back to its address",
				result = { money = 15, mind = 1, log = "You carried the cat all the way to the address on the tag. The owner gave you fifteen Ahn and a long, suspicious look. The cat gave you nothing. It had already forgotten you." },
			},
			{
				label = "Keep it",
				result = { sanity = 4, setFlags = { "bs_had_cat" }, log = "You kept it. You named it Capo, because it acted like one. It ate better than you did and slept on your face. It was the best year of your childhood." },
			},
			{
				label = "Give it a better name and let it go",
				result = { sanity = 2, log = "You named it Sir Velvet and let it go. It came back to your stairs every afternoon for years, glossy and fat, belonging to someone else and visiting you." },
			},
		},
	},
	{
		id = "bs_c_awake_313",
		title = "3:13",
		text = "You wake up in the dark and don't know why. Then you feel it: the floor is humming, faintly, like a held note. The clock in the hall says 3:13. Outside, far away and getting closer, there's a sound like a great crowd walking slowly, without talking. Everyone else in the house is asleep.",
		weight = 12,
		once = true,
		tags = { "night" },
		when = { side = "backstreets", minAge = 4, maxAge = 9 },
		codex = "city_sweepers",
		choices = {
			{
				label = "Hide under the blanket",
				result = { sanity = 1, log = "You pulled the blanket over your head and held your breath as long as you could, and then again, and again. The sound went past. Twice more it came back. Then the birds started, and you had never been so glad to hear birds." },
			},
			{
				label = "Count the waves",
				result = { mind = 2, codex = "bs_lore_night_rules", log = "One wave. Quiet: ten minutes, you counted every second. Two. Quiet. Three. Then nothing, all the way to morning. At breakfast you told everyone: three waves. They looked at you strangely and asked who had told you." },
			},
			{
				label = "Creep to the window",
				result = { sanity = -4, mind = 1, setFlags = { "bs_saw_sweepers" }, log = "Through the gap in the shutters, under the streetlight: figures. Lots of them, walking all the same way, slow as water, and the street behind them was clean. One of them turned its head toward your window. You don't remember getting back into bed." },
			},
		},
	},
	{
		id = "bs_c_street_game",
		title = "Sweepers and Sleepers",
		text = "The street's favorite game: one kid is the Sweeper and counts to three hundred and thirteen with their eyes shut, and everyone else has to be inside a doorway before the count ends. Anyone caught in the open is \"swept\" and has to be the next Sweeper. The grown-ups hate this game. That's half the fun.",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 5, maxAge = 10 },
		choices = {
			{
				label = "Be the Sweeper",
				result = { strength = 1, health = 1, log = "You counted to three hundred and thirteen and stomped down the street making the noise everyone imagines the Sweepers make. You swept four kids. An old woman on a balcony told you to stop, in a voice that wasn't joking." },
			},
			{
				label = "Find the best doorway",
				result = { mind = 1, setFlags = { "bs_knows_doorways" }, log = "You found a doorway nobody else knew about, behind the laundry's steam vent. Nobody swept you all summer. You kept that doorway a secret for years, which turned out to matter." },
			},
			{
				label = "Say it isn't a game",
				result = { sanity = 1, mind = 1, log = "You said the Night wasn't a game, and the others called you a baby. That evening the old woman from the balcony gave you a sweet. \"You're right,\" she said, \"and don't you ever forget it.\"" },
			},
		},
	},
	{
		id = "bs_c_alley_grades",
		title = "Which Street?",
		text = "The kids from Lantern Row won't play with the kids from your street. Their street pays the Kurokumo Clan for protection, so they get lamps that work and fewer Rats. Yours doesn't. \"You're a no-fee street,\" says their leader, a girl in a new coat. \"Your lot probably get swept.\"",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 7, maxAge = 11 },
		codex = "bs_lore_alley_grades",
		choices = {
			{
				label = "Challenge them to a race",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Lantern Row's fastest kid", coins = 1, base = 2, coinPower = 2 },
				win = { speed = 2, sanity = 2, log = "You raced their fastest kid from the laundry to the bakery and won by a whole shopfront. After that, Lantern Row played with your street. Mostly." },
				lose = { sanity = -2, speed = 1, log = "Their fastest kid beat you by a mile, in her new shoes. Your street lost the bragging rights for a whole year, and you trained every morning to get them back." },
			},
			{
				label = "Make friends with one of them anyway",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A street's worth of pride", coins = 1, base = 2, coinPower = 2 },
				win = { sanity = 3, addRelation = { kind = "friend", name = "Hyun-woo Baek", bond = 55, age = { 8, 11 } }, log = "There was a boy at the back, Hyun-woo, who didn't care about fees. You traded marbles. By winter you were walking each other home, his street one night, yours the next." },
				lose = { sanity = -1, log = "One of them wanted to be friends. His big sister dragged him home by the collar." },
			},
			{
				label = "Shrug: protection isn't everything",
				result = { mind = 1, log = "\"My street has the watch,\" you said, \"and we know every doorway.\" It didn't sound like much. It turned out to be worth more than lamps." },
			},
		},
	},
	{
		id = "bs_c_fee_day",
		title = "Fee Day",
		text = "Once a month a man in a pressed suit comes to the grocer downstairs for the protection fee: a Soldato of the Thumb, very polite, with a ledger. Today the grocer has a cold and sends you down with the envelope. There's a right way to hand it over. You're not completely sure what it is.",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		codex = "fingers_thumb",
		choices = {
			{
				label = "Bow exactly as deep as his rank",
				hint = "Charisma check. The Thumb cares about this more than about the money.",
				clash = { stat = "charisma", foe = "Thumb etiquette", coins = 1, base = 3, coinPower = 2 },
				win = { addTrait = "proper_manners", log = "You bowed to the exact depth, held out the envelope in both hands and called him \"Soldato\" without looking at his face. He paused. \"Who taught you?\" \"Nobody,\" you said. He seemed to find that very impressive." },
				lose = { sanity = -2, charisma = 1, log = "You bowed too deep, which is also wrong. He corrected your posture with two fingers, kindly, the way you'd straighten a picture frame. \"Next time,\" he said." },
			},
			{
				label = "Hand it over and run",
				result = { speed = 1, sanity = -1, log = "You shoved the envelope at him and fled. Behind you, you heard him sigh: the sigh of a man who has seen a great deal of rudeness and filed all of it." },
			},
			{
				label = "Ask him what the money is for",
				result = { mind = 1, codex = "bs_lore_alley_grades", log = "\"So that nothing happens to your grocer,\" he said, \"because of us, or because of anyone else.\" He thought about it. \"Mostly because of us.\" You found the honesty oddly comforting." },
			},
		},
	},
	{
		id = "bs_c_watch_lamp",
		title = "The Watch Goes By",
		text = "Every night at two, the neighborhood watch walks your street: four locals with lamps, whistles and one good stick between them. They check doors, walk old people home and shoo the Rats. Tonight the oldest of them, a retired baker everyone calls Grandpa Teo, holds out his lamp. \"Want to carry it to the corner?\"",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		codex = "bs_lore_watch",
		choices = {
			{
				label = "Carry the lamp",
				result = { sanity = 3, setFlags = { "bs_watch_kid" }, log = "You carried the lamp to the corner and back, very carefully, while Grandpa Teo knocked on doors and asked after everybody's knees. He let you do it every Friday after that." },
			},
			{
				label = "Ask what they do if they meet a Syndicate",
				result = { mind = 2, setFlags = { "bs_watch_kid" }, log = "\"Say good evening,\" said Grandpa Teo, \"and go the other way.\" He winked. \"We're not heroes. We're neighbors with lamps. That's better.\"" },
			},
			{
				label = "Ask for the stick",
				result = { strength = 1, log = "\"When you're older,\" said the woman with the stick, and handed you the whistle instead. You blew it once, and every window on the street opened. You were not given the whistle again." },
			},
		},
	},
	{
		id = "bs_c_mun",
		title = "Auntie Mun's",
		text = "Auntie Mun's noodle stall is a counter, four stools and a pot older than the street. She feeds half the block, takes no nonsense, and closes at one o'clock sharp, Night or no Night. You've been watching her pull noodles for ten minutes, and she has noticed. \"You,\" she says. \"Hungry, or nosy?\"",
		weight = 12,
		once = true,
		tags = { "backstreets" },
		when = { side = "backstreets", minAge = 5, maxAge = 10, notFlags = { "bs_knows_mun" } },
		choices = {
			{
				label = "\"Hungry.\"",
				result = { sanity = 3, health = 1, setFlags = { "bs_knows_mun" }, log = "She fed you a bowl and refused your Ahn. \"You'll pay me back by growing,\" she said. You came back the next week, and the next. You were growing." },
			},
			{
				label = "\"Nosy.\"",
				result = { intelligence = 2, setFlags = { "bs_knows_mun" }, log = "\"Good,\" she said, and showed you how to pull noodles: fold, stretch, slap, fold. Yours were terrible. She ate them anyway. \"Character,\" she said." },
			},
			{
				label = "Offer to wash bowls",
				result = { money = 5, intelligence = 1, setFlags = { "bs_knows_mun", "bs_mun_helper" }, log = "You washed bowls for an hour, and she paid you five Ahn and a bowl. You came back every weekend after that. She called you \"my staff\" to the customers." },
			},
		},
	},
	{
		id = "bs_c_rooftop",
		title = "The Highest Roof",
		text = "You've finally climbed to the top of the tallest building on the street, past the pigeon lofts and the water tanks. From up here you can see the whole District: the Nest wall glittering in the middle, the WARP line cutting the sky, the Backstreets crowding in on every side like a sea, and your own window, very small.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 9, maxAge = 12 },
		choices = {
			{
				label = "Find the Nest's tallest tower",
				result = { mind = 1, sanity = 2, setFlags = { "bs_nest_dream" }, log = "You found the tallest tower inside the wall and decided you'd stand on top of it someday. You didn't tell anyone. You looked for it from every roof after that, like a compass." },
			},
			{
				label = "Watch the sun go down over the Backstreets",
				result = { sanity = 4, log = "The sun went down orange over a million roofs, and the Backstreets lit up window by window. It was the most beautiful thing you had ever seen, and it was yours, and it was free." },
			},
			{
				label = "Count every Fixer office by its sign",
				result = { intelligence = 2, log = "You counted eleven Fixer offices, three Workshops, two academies and one sign you couldn't read. You drew a map that night. It was wrong in lots of places. You kept it anyway." },
			},
		},
	},
	{
		id = "bs_c_ampule",
		title = "Ampules Aren't Cheap",
		text = "You fell off the laundry roof and your arm is bent the way arms don't bend. The clinic doctor has a green K Corp ampule in her cabinet that would fix it overnight. She also has a price list. Your family looks at the price list for a long time.",
		weight = 8,
		once = true,
		when = { minAge = 6, maxAge = 12 },
		choices = {
			{
				label = "Let her set it the old way",
				result = { condition = "broken_arm", sanity = -2, health = 1, log = "She set it the old way, with a splint and a strap and a lot of shouting, most of it yours. It took months. You learned to write with your other hand." },
			},
			{
				label = "Pay for it with your savings jar",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 2, log = "You emptied your jar onto the counter: every Ahn you'd ever saved. It was enough for half an ampule, and half was enough. Overnight your arm remembered being whole, and so did you." },
			},
			{
				label = "Ask how the ampule works",
				result = { mind = 2, condition = "broken_arm", log = "\"Your body remembers being whole,\" said the doctor, \"and the ampule reminds it.\" You asked how the ampule knows. Nobody outside District 11 knows, she said, and in District 11 they don't ask. Then she set your arm the old way." },
			},
		},
	},
	{
		id = "bs_c_pigeons",
		title = "The Pigeon Keeper",
		text = "Old Halbrand keeps pigeons on the roof and sends messages by bird for half a courier's price. \"Faster than the roads, cheaper than a WARP ticket, and they never read the letters.\" One of his birds has a hurt wing. He looks at you. \"Have you got small, careful hands?\"",
		weight = 8,
		once = true,
		when = { minAge = 6, maxAge = 11 },
		choices = {
			{
				label = "Help bind the wing",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A frightened bird", coins = 1, base = 1, coinPower = 2 },
				win = { intelligence = 2, sanity = 2, setFlags = { "bs_pigeon_friend" }, log = "You held the bird while he bound the wing, and it didn't struggle. A month later it flew again. Halbrand let you send one message a year, free. You saved them for important things." },
				lose = { sanity = -1, intelligence = 1, log = "The bird panicked, and so did you. Halbrand bound the wing himself, kindly. \"Careful hands take practice,\" he said, and gave you a feather." },
			},
			{
				label = "Ask how the birds know the way",
				result = { mind = 1, sanity = 1, log = "\"Same way you do,\" said Halbrand. \"They know where home is, and they want to be there before three.\"" },
			},
			{
				label = "Ask if a bird could fly into the Nest",
				result = { mind = 1, codex = "bs_lore_nests", log = "\"Nothing gets through the wall without papers,\" he said. \"Not even birds.\" You thought he was joking. You watched for a whole afternoon. He wasn't." },
			},
		},
	},
	{
		id = "bs_c_tax_man",
		title = "The Tax Collector",
		text = "A tax collector comes down your street with a clerk and a guard, door by door, reading from a list. Everyone pays, even the people who can't. When they reach your door the clerk reads out a number, and your family goes quiet in a way you've never heard before.",
		weight = 8,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Bring out your savings jar",
				requires = { min = { money = 10 } },
				result = { money = -10, sanity = 2, log = "You came out with your savings jar. The collector looked at it, then at you, and wrote something on his list. \"Paid,\" he said, and took exactly what was in it. Your family never forgot that, in a good way and a bad way at once." },
			},
			{
				label = "Watch the clerk do the sums",
				result = { intelligence = 2, sanity = -1, log = "You watched the clerk's pencil and saw him add one line twice. You said so. He turned red. The collector checked, fixed it, and looked at you for a long moment. \"Bright one,\" he said. It was not a compliment." },
			},
			{
				label = "Hide in the back room",
				result = { mind = 1, sanity = -2, log = "You hid in the back room and listened through the door. Your family paid. Nobody ate much that month, and nobody talked about why." },
			},
		},
	},
	{
		id = "bs_c_sibling_shortcuts",
		title = "Shortcuts",
		text = "{sibling} has decided you're finally old enough to learn the most important skill in the Backstreets: how to get home from anywhere before three, without a map, without asking anyone, and without meeting a single Rat.",
		weight = 10,
		once = true,
		when = { side = "backstreets", hasRelation = "sibling", minAge = 6, maxAge = 12 },
		choices = {
			{
				label = "Follow {sibling} everywhere",
				result = { mind = 1, strength = 1, relationBond = { kind = "sibling", amount = 8 }, setFlags = { "bs_knows_shortcuts" }, log = "{sibling} showed you the gap behind the bathhouse, the stair that cuts two streets, the roof you can cross if you don't look down. You got home from anywhere after that, and {sibling} never let you forget who taught you." },
			},
			{
				label = "Race {sibling} home",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A sibling who knows every shortcut", coins = 1, base = 2, coinPower = 2 },
				win = { speed = 2, relationBond = { kind = "sibling", amount = 4 }, log = "You took a shortcut {sibling} hadn't shown you yet, and won by a whole staircase. {sibling} demanded to know where you'd learned it. You never told." },
				lose = { speed = 1, relationBond = { kind = "sibling", amount = 6 }, log = "{sibling} was waiting on the doorstep when you got there, eating your share of the dumplings. \"Lesson one,\" said {sibling}. \"Don't race the teacher.\"" },
			},
		},
	},
	{
		id = "bs_c_smoke_sky",
		title = "When the Sky Was Smoke",
		text = "Old Mrs. Halas upstairs is the oldest person you know. She says that when she was a girl, during the Smoke War, the sky over the City was brown for years and children were drafted the way you're sent to the academy. Today she's sorting buttons and seems in the mood to talk.",
		weight = 8,
		once = true,
		when = { minAge = 6, maxAge = 12, notFlags = { "smoke_war_family" } },
		codex = "bs_lore_smoke_war",
		choices = {
			{
				label = "Ask what the war was about",
				result = { mind = 2, log = "\"Wings,\" she said. \"Wings wanting more than they had. That's what every war is about.\" She sorted three more buttons. \"Don't let anyone tell you there was a right side.\"" },
			},
			{
				label = "Ask if she was scared",
				result = { sanity = 1, intelligence = 1, log = "\"Every day,\" she said. \"And then one day it stopped, and everyone acted like it never happened.\" She gave you a brass button with a beetle on it. \"Proof,\" she said." },
			},
			{
				label = "Help her sort the buttons",
				result = { intelligence = 2, sanity = 1, log = "You sorted buttons with her all afternoon and she told you nothing about the war, and everything about her sister, who ran a hat shop and was never once late for anything." },
			},
		},
	},
	{
		id = "bs_c_fixer_gym",
		title = "The Fixer Gym",
		text = "There's a Fixer gym on the corner: one room, a heavy bag, and a sign that says NO RATS, NO EXCEPTIONS. Off-duty Fixers knock each other down in there for fun. The owner, a huge woman with a prosthetic jaw, catches you peering through the window. \"Floor needs sweeping,\" she says. \"Sweepers get a free lesson.\"",
		weight = 10,
		once = true,
		when = { minAge = 8, maxAge = 12 },
		choices = {
			{
				label = "Sweep, then take the lesson",
				result = { strength = 2, health = 1, setFlags = { "bs_gym_kid" }, log = "You swept every inch, then got knocked down by a Grade 8 Fixer forty times in a row. On the forty-first you stayed up. The whole gym cheered. You were sore for a week and back the next Saturday." },
			},
			{
				label = "Just watch how they move",
				result = { mind = 1, strength = 1, log = "You watched them for an hour: how the good ones barely moved, and how the loud ones always lost. You copied it in your room that night and knocked over a lamp." },
			},
			{
				label = "Ask what NO RATS means",
				result = { mind = 1, codex = "bs_lore_rats", log = "\"Means no Rats,\" said the owner. \"Learn to fight in here and use it out there on decent people? No.\" She looked you up and down. \"You're not a Rat. Yet. Sweep the floor.\"" },
			},
		},
	},

	-- ── Nest childhood ─────────────────────────────────────────────────────
	{
		id = "bs_c_nest_window_show",
		title = "The Window Show",
		text = "On Friday evenings your parents' friends come round, and everyone sits by the big window with tea to watch the Backstreets below. They point at the crowds and the stalls and the little lights, and laugh, and guess at what people are fighting about. At one o'clock the lights down there start going out. \"Here's the good part,\" someone says.",
		weight = 12,
		once = true,
		when = { side = "nest", minAge = 6, maxAge = 11 },
		codex = "bs_lore_nests",
		choices = {
			{
				label = "Watch with them",
				result = { mind = 1, sanity = -1, log = "You watched the lights go out, street by street, until the whole Backstreets was dark and still. The grown-ups clapped. You didn't know why, and you didn't ask, and you didn't sleep well." },
			},
			{
				label = "Go to your room",
				result = { sanity = 1, mind = 1, log = "You said you were tired and went to your room. You could still hear them laughing through the wall. You decided you never wanted to find it funny." },
			},
			{
				label = "Ask if the people down there know they're being watched",
				result = { mind = 2, setFlags = { "bs_saw_backstreets" }, log = "The room went quiet. \"Of course they do, darling,\" said your mother's friend. \"They watch us too.\" You looked out at the dark Backstreets, and for a second you were sure someone down there was looking straight back." },
			},
		},
	},
	{
		id = "bs_c_nest_drone",
		title = "The Drone That Followed You",
		text = "A Nest surveillance drone has been following you home from school all week, always three meters behind, blinking. You haven't done anything wrong. You don't think you've done anything wrong. Everyone at school says drones only follow people who've done something wrong.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Wave at it",
				result = { sanity = 2, log = "You waved at it every day. On Friday it stopped following you. A neighbor's door had a notice on it the next morning, and the neighbor was gone. You never found out if those two things were connected." },
			},
			{
				label = "Lose it in the gardens",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A patient drone", coins = 1, base = 2, coinPower = 2 },
				win = { strength = 2, setFlags = { "bs_nest_wary" }, log = "You lost it in the hedge maze behind the gardens. It hovered at the exit for an hour. You went out the other side, feeling like the cleverest person in the Nest. Your parents got a letter." },
				lose = { sanity = -2, log = "It followed you into the hedge maze and out again, blinking. When you got home there was a letter for your parents about \"unusual movement patterns.\"" },
			},
			{
				label = "Write HELLO in chalk on the pavement",
				result = { sanity = 1, intelligence = 1, log = "You wrote HELLO in big chalk letters. The drone hovered over it for a long time. The next morning the chalk was gone and the pavement was cleaner than it had ever been." },
			},
		},
	},
	{
		id = "bs_c_nest_cleaner",
		title = "The Cleaner's Son",
		text = "The woman who cleans your family's flat comes in from the Backstreets on a work pass, and today she's brought her son, because there was nobody to watch him. He's your age. He looks at your room as if it were a museum. His mother tells him not to touch anything, and to be ready to leave at noon: the checkpoint queue takes hours.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 5, maxAge = 10 },
		choices = {
			{
				label = "Show him your toys",
				result = { sanity = 3, log = "You showed him everything. He showed you how to make a whistle out of a grass blade, which nobody in the Nest knew how to do. At noon he left with a toy car in his pocket that you'd made him take." },
			},
			{
				label = "Ask him about the Night",
				result = { mind = 2, codex = "city_sweepers", log = "\"You hear them,\" he said, \"like a crowd going past. Then it's morning.\" He shrugged. \"You get used to it. You don't have it here?\" You realized you'd never once heard the Night. You'd never once had to." },
			},
			{
				label = "Pretend he isn't there",
				result = { intelligence = 1, sanity = -2, log = "You read your book and pretended he wasn't there. He sat by the door all morning with his hands in his lap. When he left, you felt like you'd failed a test nobody had told you about." },
			},
		},
	},
	{
		id = "bs_c_nest_rankings",
		title = "Class Rankings",
		text = "The rankings go up on the school board every term: every child in your year, numbered from first to last. In the Nest everybody knows that Class rankings now mean Feather Classes later. Your parents will see the list tonight. Your name is near the middle, and the middle is not where anyone in your family has ever been.",
		weight = 10,
		once = true,
		when = { side = "nest", minAge = 8, maxAge = 12 },
		codex = "bs_lore_feathers",
		choices = {
			{
				label = "Study every night until the next list",
				result = { intelligence = 3, sanity = -2, log = "You studied until your eyes ached, every night, all term. The next list had you in the top ten. Your parents framed it. You kept seeing the middle of the list when you closed your eyes." },
			},
			{
				label = "Find out who's ranked last",
				result = { mind = 1, sanity = 2, log = "Last was a quiet boy who drew birds in the margins of everything. You sat with him at lunch. His birds were better than anything on the board." },
			},
			{
				label = "Tell your parents the list doesn't matter",
				result = { strength = 1, sanity = 1, log = "You said it at dinner. Your father put down his fork very carefully. \"In the Nest,\" he said, \"the list is the only thing that matters.\" He wasn't angry. He was frightened, which was worse." },
			},
		},
	},
	{
		id = "bs_c_nest_daypass",
		title = "A Day Pass",
		text = "You've saved up for a Backstreets day pass, the kind tourists from the Nest buy for the night markets. The rule printed on the back is very clear: back through the checkpoint by one o'clock, or the pass is void and so, the clerk says cheerfully, are you. It's eleven. The market is loud and wonderful and smells of everything.",
		weight = 8,
		once = true,
		when = { side = "nest", minAge = 10, maxAge = 14 },
		codex = "bs_lore_backstreets",
		choices = {
			{
				label = "Try every stall, and watch the time",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A market that doesn't want you to leave", coins = 1, base = 2, coinPower = 2 },
				win = { sanity = 4, setFlags = { "bs_saw_backstreets" }, log = "Skewers, dumplings, a puppet show, a man who juggled knives and swore in four languages. You were back at the checkpoint at 12:51, sticky and happy. The guard looked at your face and almost smiled." },
				lose = { sanity = -3, money = { -30, -10 }, setFlags = { "bs_saw_backstreets" }, log = "You lost track of time and got to the checkpoint at 1:04. They let you in, eventually, after a fine, a lecture and a phone call to your parents that you will remember on your deathbed." },
			},
			{
				label = "Follow a Backstreets kid to the best stall",
				result = { sanity = 3, mind = 1, log = "A Backstreets kid charged you two Ahn to show you the best dumpling stall in the District. It really was the best. She walked you back to the checkpoint by half past twelve and charged you two more." },
			},
		},
	},
}
