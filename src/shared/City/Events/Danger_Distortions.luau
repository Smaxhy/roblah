--[[
	Danger and horror (dz_): Distortions, Peccatula and places that have gone wrong, from the
	Dark Days on. Distortions are drawn as light, shadow and objects, never flesh.
	Chains:
		dz_d_lamplighter -> dz_d_lamplighter_comes      break its lamps and it comes to you
		dz_d_laundry -> (1 year) dz_d_laundry_grown     a Peccatulum nobody dealt with
		dz_d_brink -> (1-2 years) dz_d_brink_night      a friend at the edge
		dz_d_nine_dare (a kid) ... dz_d_nine_friend -> (1 year) dz_d_nine_gone
		                                                opens the Number Nine expedition
]]

return {
	-- ── the Dark Days and the first Distortions ──
	{
		id = "dz_d_dark_days",
		title = "The Song in the Street",
		text = "The light has gone strange. At noon a crowd walks down your street singing a song nobody taught them, and people step out of their doors to join it.",
		weight = 8,
		once = true,
		when = { minAge = 8, world = { era = "white_nights" } },
		codex = "city_white_nights",
		choices = {
			{
				label = "Cover your ears",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The song", coins = 2, base = 4, coinPower = 3, fixed = true },
				win = { sanity = -4, log = "You pressed your hands over your ears until the street was empty. Nobody who joined the song came back." },
				lose = { sanity = -12, condition = "dz_terror", log = "You hummed it for a year afterward, under your breath, without meaning to." },
			},
			{
				label = "Pull a neighbor back",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A neighbor who wants to go", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { strength = 2, sanity = -2, addRelation = { kind = "friend", name = "Ilse Marlow", bond = 55, age = { 30, 50 } }, log = "You hauled Mrs. Varga back by her coat and held on until it passed. She brings you soup every winter now." },
				lose = { sanity = -8, log = "She shook you off, smiling, and went. Her door is still open." },
			},
			{
				label = "Go out and listen",
				hint = "Mental Strength check. Very bad odds.",
				requires = { minAge = 18 },
				clash = { stat = "mind", foe = "The song", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -10, setFlags = { "dz_unsurvivable" }, addTrait = "dz_dread_calm", log = "You stood in the street and let the song wash past you, every word. When it was gone, you were still there." },
				lose = { die = "Walked away with the singing crowd in the Dark Days", log = "You stepped out to listen, and joined the song. By evening the street was empty." },
			},
		},
	},
	{
		id = "dz_d_first_one",
		title = "The First One on Your Street",
		text = "Nobody had a word for it yet. The baker's son stopped speaking on Monday. On Thursday something tall and quiet was standing in the bakery, wearing his apron.",
		weight = 5,
		once = true,
		tags = { "danger" },
		when = { minAge = 12, world = { era = "library" } },
		codex = "lib_first_distortions",
		choices = {
			{ label = "Lock the door and wait", result = { sanity = -6, log = "Three Fixers went in at dusk, and two came out. The bakery has been shut ever since." } },
			{
				label = "Call to him through the window",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "What the baker's son became", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -2, mind = 2, setFlags = { "dz_distortion_survivor" }, log = "You called his name, and for a moment it was only a frightened boy. Then the Fixers arrived." },
				lose = { health = { -16, -8 }, sanity = -8, log = "It came to the window.", cause = "Called out to one of the first Distortions" },
			},
			{
				label = "Help the Fixers corner it",
				clash = { stat = "strength", foe = "The baker's son", coins = 3, base = 7, coinPower = 4, fight = true, status = { id = "rupture", potency = 2 } },
				win = { strength = 3, wage = { 80, 180 }, log = "You held the back door. When it was over, the Fixers paid you and wouldn't look at you." },
				lose = { health = { -22, -10 }, log = "You held the back door. It came out the back door.", cause = "Killed helping Fixers corner a Distortion" },
			},
		},
	},

	-- ── mid-street ──
	{
		id = "dz_d_bus_stop",
		title = "Laughing at the Bus Stop",
		text = "The woman beside you at the bus stop has been laughing for ten minutes. Her shadow laughs half a second late. Then her umbrella opens by itself, full of a light that hurts to look at.",
		weight = 3,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, world = { era = { "library", "limbus" } } },
		codex = "terms_distortion",
		choices = {
			{
				label = "Run",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A Distortion waking up", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -4, chronicle = "dz_act_distortion_loose", log = "You ran and didn't look back. By the time the Fixers came, the bus stop was empty." },
				lose = { health = { -18, -8 }, sanity = -8, condition = "dz_terror", log = "The light caught you three steps out.", cause = "Caught by a Distortion at a bus stop" },
			},
			{
				label = "Talk her down",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "The thing she's becoming", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = 2, charisma = 3, setFlags = { "dz_distortion_survivor" }, log = "You asked her name and kept asking until the umbrella closed. She sat down on the bench and cried like a person." },
				lose = { health = { -14, -6 }, sanity = -12, log = "She stopped laughing and looked at you. That was worse.", cause = "Talked to a Distortion too long" },
			},
			{
				label = "Fight it",
				clash = { stat = "strength", foe = "The Laughing Umbrella", coins = 3, base = 8, coinPower = 4, fight = true, status = { id = "sinking", potency = 2 } },
				win = { strength = 3, wage = { 120, 260 }, setFlags = { "dz_distortion_survivor" }, chronicle = "fought_distortion", log = "You brought it down before it finished becoming. The Fixers paid you a finder's fee and didn't ask how." },
				lose = { health = { -22, -10 }, sanity = -8, log = "It had finished becoming.", cause = "Fought a Distortion at a bus stop" },
			},
			{ label = "Freeze and stare at the ground", result = { sanity = -10, condition = "dz_terror", log = "You stared at your shoes until the bus came. When you looked up, the bench was empty except for her umbrella." } },
		},
	},
	{
		id = "dz_d_lamplighter",
		title = "The Lamplighter",
		text = "Every night at two, something tall walks your street and lights the dead lamps. Whoever stands under one at the third bell is still standing there in the morning, very still.",
		weight = 2,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, world = { era = "limbus" } },
		codex = "lim_distortion_stages",
		choices = {
			{ label = "Keep off the lamps", result = { sanity = -4, money = -25, log = "You took the long way home for a year and lost a little pay to it. The people under the lamps were gone by spring." } },
			{
				label = "Smash the lamps",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "Nine iron lamps", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { strength = 2, trigger = "dz_d_lamplighter_comes", log = "You broke every lamp on the street before midnight." },
				lose = { health = { -12, -5 }, condition = "burns", log = "The glass was hot as a stove, and the lamps still lit.", cause = "Burned by a Distortion's lamp" },
			},
			{
				label = "Pay Fixers to end it",
				hint = "200 Ahn.",
				requires = { min = { money = 200 } },
				result = { money = -200, sanity = 2, log = "Two Fixers from a Grade 5 Office took the job, and one came back. The lamps stayed dark." },
			},
		},
	},
	{
		id = "dz_d_lamplighter_comes",
		title = "It Comes for Its Lamps",
		text = "At two the tall thing comes up the street and finds its lamps in pieces. It turns its head, slowly, toward your window, and starts toward your door.",
		weight = 0,
		when = { minAge = 14 },
		choices = {
			{
				label = "Meet it in the street",
				clash = { stat = "strength", foe = "The Lamplighter", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "burn", potency = 2 } },
				win = { strength = 3, wage = { 200, 400 }, setFlags = { "dz_distortion_survivor" }, chronicle = "fought_distortion", log = "You put it down under its own broken lamps. At dawn it was a thin old man with a match in his hand." },
				lose = { health = { -22, -12 }, log = "It lit you like a lamp.", cause = "Fought the Lamplighter" },
			},
			{
				label = "Bar the door",
				hint = "Health check.",
				clash = { stat = "health", foe = "Something at the door", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -6, log = "It leaned on your door until the hinges groaned, then left. It isn't the Night yet, so it doesn't have to obey the Night's rules." },
				lose = { health = { -18, -8 }, sanity = -6, condition = "dz_maimed", log = "The door held. The window didn't.", cause = "The Lamplighter came through the window" },
			},
			{ label = "Out the back and run", result = { sanity = -6, chronicle = "dz_act_distortion_loose", log = "You ran across three streets of rooftops and slept in a laundry. Your street has new lamps now." } },
		},
	},
	{
		id = "dz_d_stairs",
		title = "More Stairs Than Yesterday",
		text = "Your building has ninety-six stairs. You've been climbing for twenty minutes. Below you, someone is climbing too, at exactly your pace.",
		weight = 2,
		once = true,
		tags = { "danger" },
		when = { minAge = 13, world = { era = { "library", "limbus" } } },
		codex = "lim_inflection_point",
		choices = {
			{
				label = "Keep climbing",
				hint = "Health check.",
				clash = { stat = "health", foe = "The stairs", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -5, log = "Your door, at last, somewhere past step four hundred. In the morning there were ninety-six again." },
				lose = { health = { -16, -8 }, sanity = -8, log = "You climbed until your legs gave out, and slept on a landing that wasn't there in the morning.", cause = "Lost on a staircase that kept going" },
			},
			{
				label = "Turn around",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Whoever is behind you", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -8, mind = 3, setFlags = { "dz_distortion_survivor" }, log = "It was you, ten steps down and ten seconds behind. You both stepped aside, and the stairs were ninety-six again." },
				lose = { sanity = -15, condition = "dz_terror", log = "There was nobody there. The footsteps kept coming anyway." },
			},
			{ label = "Sit down and wait", result = { sanity = -6, condition = "dz_terror", log = "You sat on the step until the building let you go. It took until morning, and a little longer." } },
		},
	},
	{
		id = "dz_d_choir",
		title = "The Choir in Unit 4",
		text = "The music teacher in Unit 4 hasn't come out in a month. Her students still go in every evening, and the singing has got into the walls. Your hands keep time with it now, without you.",
		weight = 2,
		once = true,
		when = { minAge = 13, world = { era = { "library", "limbus" } } },
		codex = "lim_distortion_stages",
		choices = {
			{ label = "Move out", hint = "120 Ahn.", requires = { min = { money = 120 } }, result = { money = -120, sanity = -2, log = "You moved across the District. Some nights you still catch yourself humming it." } },
			{
				label = "Go in and break the song",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A song with no end", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = 2, mind = 3, setFlags = { "dz_distortion_survivor" }, log = "You sang it wrong on purpose, loudly, until the rhythm broke. She looked up from the piano, human and crying, and the students woke one by one." },
				lose = { sanity = -18, health = { -10, -4 }, log = "You sang along until morning. You can't remember stopping.", cause = "Sang with the choir in Unit 4" },
			},
			{ label = "Call the Fixers", result = { sanity = -5, log = "A Fixer Office that takes Distortion work came in the afternoon. They carried out the piano and nothing else." } },
		},
	},
	{
		id = "dz_d_wrong_door",
		title = "One Number Off",
		text = "Every door on your street is one number off tonight. Your key fits the wrong one. Inside, a family you've never met looks up from dinner, smiling, and pulls out a chair for you.",
		weight = 2,
		once = true,
		tags = { "danger" },
		when = { minAge = 16, world = { era = "limbus" } },
		codex = "lim_inflection_point",
		choices = {
			{
				label = "Back out slowly",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A family that isn't there", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -6, setFlags = { "dz_distortion_survivor" }, log = "You backed out and shut the door, and the numbers were right by morning. The kids won't play in front of that house." },
				lose = { sanity = -14, condition = "dz_terror", log = "They kept smiling while you fumbled with the lock. You slept in a doorway until 2:50 and ran home." },
			},
			{
				label = "Sit down and play along",
				hint = "Mental Strength check. Very bad odds.",
				clash = { stat = "mind", foe = "A family that wants you to stay", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -12, setFlags = { "dz_unsurvivable" }, addTrait = "dz_dread_calm", log = "You ate their soup and laughed at their jokes until dawn, when the house folded away around you. You woke on the pavement, full." },
				lose = { die = "Sat down to dinner in a house that wasn't there", log = "The soup was very good. Your street has one more house now." },
			},
			{ label = "Try the next door", result = { sanity = -4, log = "The next door was yours, one number off. You checked all three locks twice and didn't sleep." } },
		},
	},

	-- ── Peccatula ──
	{
		id = "dz_d_laundry",
		title = "Something in the Laundry",
		text = "The laundromat on your corner has been shut a week. Tonight its door is open, and something beast-shaped, made of tangled shadow, is curled up in the dryers, breathing.",
		weight = 2,
		once = true,
		tags = { "danger" },
		when = { minAge = 13, world = { era = "limbus" } },
		codex = "lim_peccatula",
		choices = {
			{
				label = "Back away slowly",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A Peccatulum waking up", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -3, log = "It watched you all the way to the corner, and didn't follow. Not that night." },
				lose = { health = { -16, -8 }, sanity = -6, log = "You stepped on a coat hanger.", cause = "Brought down by a Peccatulum in a laundromat" },
			},
			{ label = "Report it to Limbus Company", result = { wage = { 30, 60 }, sanity = -2, schedule = { event = "dz_d_laundry_grown", inYears = 1 }, log = "An LCCB scout took your statement and paid a finder's fee. Nobody came to deal with it." } },
			{
				label = "Burn it out",
				clash = { stat = "strength", foe = "A Peccatulum", coins = 3, base = 7, coinPower = 3, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 2, wage = { 60, 140 }, log = "It burned like wet laundry and screamed like a kettle. The owner gave you free washes for life." },
				lose = { health = { -20, -8 }, log = "It wasn't asleep.", cause = "Fought a Peccatulum in a laundromat" },
			},
		},
	},
	{
		id = "dz_d_laundry_grown",
		title = "The Laundry Has Grown",
		text = "Nobody came for the thing in the laundromat. Now the block smells of wet ash, three neighbors have stopped coming home, and the laundromat's windows breathe in and out.",
		weight = 0,
		when = { world = { era = "limbus" } },
		codex = "lim_peccatula",
		choices = {
			{ label = "Move out tonight", hint = "80 Ahn.", requires = { min = { money = 80 } }, result = { money = -80, sanity = -3, log = "You packed one bag and left the rest. A month later a Fixer crew burned the block down to its frames." } },
			{
				label = "Join the block's hunting party",
				clash = { stat = "strength", foe = "A Class 2 Peccatulum", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "bleed", potency = 3 } },
				win = { strength = 3, wage = { 150, 300 }, setFlags = { "dz_distortion_survivor" }, log = "Six of you went in with crowbars and lamp oil. Four came out, and you were one of them." },
				lose = { health = { -22, -12 }, log = "Six of you went in.", cause = "Hunted a Peccatulum that had grown" },
			},
			{ label = "Stay and keep your head down", result = { sanity = -8, health = { -8, -3 }, condition = "dz_terror", log = "You heard it moving in the walls all year. You never walked past the laundromat again.", cause = "Lived beside a growing Peccatulum" } },
		},
	},
	{
		id = "dz_d_playground",
		title = "Something on the Swings",
		text = "Something is sitting on the playground swings at dusk. It's shaped a little like a dog and a little like a coat thrown over a chair, and it's watching you.",
		weight = 4,
		once = true,
		when = { minAge = 6, maxAge = 13, world = { era = { "library", "limbus" } } },
		codex = "lim_peccatula",
		choices = {
			{ label = "Walk home, don't run", result = { sanity = -3, mind = 2, log = "It watched you all the way to the corner. You didn't run, because running makes them chase." } },
			{ label = "Run", result = { sanity = -4, health = { -3, -1 }, log = "You ran and fell and ran again, and it didn't follow. Your knees were scraped for a week." } },
			{ label = "Throw a stone at it", result = { sanity = -6, strength = 1, log = "The stone went straight through it, and it got up off the swing. A grown-up had you indoors by the collar before it took a step." } },
		},
	},

	-- ── a friend at the edge ──
	{
		id = "dz_d_brink",
		title = "{friend} Isn't Sleeping",
		text = "{friend} hasn't slept in nine days. They say their shadow argues with them at night, and it's starting to win.",
		weight = 2,
		once = true,
		when = { minAge = 16, hasRelation = "friend", world = { era = { "library", "limbus" } } },
		codex = "lim_distortion_stages",
		choices = {
			{ label = "Stay with them", result = { sanity = -6, setFlags = { "dz_brink_stayed" }, schedule = { event = "dz_d_brink_night", inYears = 1 }, log = "You slept on their floor for a month. Some nights you heard the shadow too." } },
			{ label = "Pay for a clinic", hint = "150 Ahn.", requires = { min = { money = 150 } }, result = { money = -150, sanity = -1, schedule = { event = "dz_d_brink_night", inYears = 2 }, log = "The clinic gave them a quiet bed for a week and a Moonlight Stone to hold. It helped, for a while." } },
			{ label = "Keep your distance", result = { sanity = -2, schedule = { event = "dz_d_brink_night", inYears = 1 }, log = "You stopped answering their calls. You told yourself it was for the best." } },
		},
	},
	{
		id = "dz_d_brink_night",
		title = "The Night It Wins",
		text = "{friend} calls at midnight and says nothing, just breathes. When you get there the door is open and the room is the wrong shape. Something in the corner still has their voice.",
		weight = 0,
		when = { hasRelation = "friend", world = { era = { "library", "limbus" } } },
		codex = "lim_distortion_stages",
		choices = {
			{
				label = "Say their name until they hear",
				hint = "Mental Strength check. You stayed with them; it helps.",
				requires = { flags = { "dz_brink_stayed" } },
				clash = { stat = "mind", foe = "Your friend's distortion", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = 4, relationBond = { kind = "friend", amount = 20 }, setFlags = { "dz_distortion_survivor" }, log = "You said their name four hundred times. On the four hundred and first, they said yours back." },
				lose = { killRelation = "friend", health = { -18, -8 }, sanity = -10, condition = "grief", log = "It answered in their voice, and then it stopped using it.", cause = "Killed by a friend who Distorted" },
			},
			{
				label = "Say their name until they hear",
				hint = "Mental Strength check.",
				requires = { notFlags = { "dz_brink_stayed" } },
				clash = { stat = "mind", foe = "Your friend's distortion", coins = 3, base = 7, coinPower = 3, fixed = true },
				win = { sanity = 4, relationBond = { kind = "friend", amount = 20 }, setFlags = { "dz_distortion_survivor" }, log = "You said their name until your voice went. At dawn they said yours back, small and scared and human." },
				lose = { killRelation = "friend", health = { -18, -8 }, sanity = -10, condition = "grief", log = "It answered in their voice, and then it stopped using it.", cause = "Killed by a friend who Distorted" },
			},
			{ label = "Run and call the Fixers", result = { killRelation = "friend", sanity = -12, condition = "grief", log = "You ran, and a Fixer crew came at dawn. They didn't let you see what they carried out." } },
			{
				label = "Fight it",
				clash = { stat = "strength", foe = "Your friend's distortion", coins = 4, base = 8, coinPower = 4, fight = true, status = { id = "sinking", potency = 2 } },
				win = { killRelation = "friend", strength = 2, sanity = -8, condition = "grief", log = "You won; that's the word for it. You've never found a worse one." },
				lose = { killRelation = "friend", health = { -22, -12 }, log = "You couldn't hit it properly. It still had their face.", cause = "Killed by a friend who Distorted" },
			},
		},
	},

	-- ── Number Nine, Bellhouse Row ──
	{
		id = "dz_d_nine_dare",
		title = "The Fourth-Floor Dare",
		text = "Number Nine, Bellhouse Row is two streets from yours. The kids dare each other to go up it: nobody who goes past the fourth-floor landing comes down the same day. They're all looking at you.",
		weight = 4,
		once = true,
		when = { minAge = 9, maxAge = 13 },
		choices = {
			{ label = "Refuse", result = { sanity = -1, mind = 1, log = "They called you a coward for a week. Then the Kim twins went up on a Saturday and came down on Tuesday, and nobody called you anything again." } },
			{
				label = "Climb to the landing",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The fourth-floor landing", coins = 1, base = 3, coinPower = 2, fixed = true },
				win = { sanity = -3, setFlags = { "dz_nine_heard" }, log = "From the landing you heard someone on the fifth floor calling your name. You ran down so fast you lost a shoe." },
				lose = { sanity = -6, condition = "night_terrors", setFlags = { "dz_nine_heard" }, log = "The landing went on much longer than a landing should. You came down crying, and nobody laughed." },
			},
			{ label = "Go past the landing", result = { sanity = -10, condition = "dz_terror", setFlags = { "dz_nine_heard" }, log = "You came down two days later with your pockets full of old keys. You couldn't say where you'd been." } },
		},
	},
	{
		id = "dz_d_nine_friend",
		title = "{friend} Found a Cheap Flat",
		text = "{friend} has found a flat with rent too cheap to be true: Number Nine, Bellhouse Row, fourth floor. They're thrilled. The kids on that street won't walk past the building.",
		weight = 3,
		once = true,
		when = { minAge = 18, hasRelation = "friend" },
		choices = {
			{
				label = "Talk them out of it",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A friend who loves a bargain", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = 2, relationBond = { kind = "friend", amount = 6 }, log = "You found them a worse flat for more money. They forgave you, eventually." },
				lose = { setFlags = { "dz_nine_friend" }, schedule = { event = "dz_d_nine_gone", inYears = 1 }, log = "They laughed at you. \"It's a building.\"" },
			},
			{
				label = "Tell them what you heard there",
				hint = "You went up as a kid.",
				requires = { flags = { "dz_nine_heard" } },
				result = { sanity = -2, relationBond = { kind = "friend", amount = 10 }, log = "You told them about the landing, and the voice, and the shoe. They went very pale and didn't sign." },
			},
			{ label = "Help them move in", result = { setFlags = { "dz_nine_friend" }, schedule = { event = "dz_d_nine_gone", inYears = 1 }, log = "You helped carry the boxes up. The fourth-floor landing was longer than it should have been." } },
		},
	},
	{
		id = "dz_d_nine_gone",
		title = "The Door on the Fourth Floor",
		text = "Nobody has seen {friend} in a month. Their door on the fourth floor of Number Nine stands open. From somewhere above, higher than the building goes, someone calls for help in their voice.",
		weight = 0,
		when = { hasRelation = "friend", flags = { "dz_nine_friend" } },
		choices = {
			{ label = "Go up after them", result = { setFlags = { "dz_nine_open" }, sanity = -4, log = "You went home for a lamp, a rope and a coat. Number Nine will be there when you're ready; it always is." } },
			{ label = "Pay Fixers to go in", hint = "300 Ahn.", requires = { min = { money = 300 } }, result = { money = -300, sanity = -6, killRelation = "friend", condition = "grief", log = "Two Fixers went up, and one came down with your friend's coat over his arm. He wouldn't say anything else." } },
			{ label = "Walk away", result = { sanity = -10, killRelation = "friend", condition = "grief", log = "You walked away. Some nights you still hear your name, from very high up." } },
		},
	},
}
