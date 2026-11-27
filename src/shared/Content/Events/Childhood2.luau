--[[
	Childhood events, second set: ages 1-12.
	Threads started here (follow-ups use weight = 0 and only arrive by schedule):
		kid2_odile_song     kid2_nursemaid_song -> teen2_odile_again (Youth2, 12 yrs)
		kid2_stairs_dog     kid2_stair_dog      -> kid2_dog_warning (3 yrs)
		kid2_asked_sallow   kid2_company_school -> teen2_old_teacher (Youth2, 6 yrs, adds mentor Mira Sallow)
		kid2_whistled_back  kid2_whistle_back   -> teen2_whistle_in_fog (Youth2, 7 yrs)
		kid2_greer_jump     kid2_stilt_jump     -> teen2_greer_rematch (Youth2, 5 yrs, adds Greer Ingram)
		kid2_twelve_knots   kid2_knot_lessons   -> teen2_twelfth_knot (Youth2, 5 yrs)
		kid2_bottle_sent    kid2_bottle_letter  -> teen2_bottle_reply (Youth2, 6 yrs, adds Jessamy Corwen)
]]

return {
	-- ── babies (1-4) ────────────────────────────────────────────────────────
	{
		id = "kid2_first_word",
		title = "Your First Word",
		text = "Faces lean over you in the lamplight, making the same shapes with their mouths again and again, as if you were a lock they could talk open. Outside, a tram bell clangs on the switchback. You have been saving up a word for weeks, and it is ready.",
		once = true,
		tags = { "childhood", "baby" },
		when = { minAge = 1, maxAge = 2 },
		choices = {
			{
				label = "Say \"lamp\"",
				result = { temperance = { 1, 2 }, sanity = 2, log = "You pointed at the lamp and said its name, and everyone cheered as if you had read a whole ledger aloud." },
			},
			{
				label = "Say \"no\"",
				result = { justice = { 1, 2 }, sanity = 1, log = "Your first word was \"no\". You said it to everyone, often, with enormous feeling." },
			},
			{
				label = "Say \"water\"",
				result = { prudence = { 1, 2 }, sanity = 1, log = "You looked at the window and said \"water\". Somebody laughed, and somebody else went very quiet." },
			},
		},
	},
	{
		id = "kid2_gull_sill",
		title = "The Gull on the Sill",
		text = "A grey gull as big as you lands on the sill of the stilt-house and looks in at your crust of bread with one cold yellow eye. It takes one step inside. There is nobody else in the room, and the gull knows it.",
		once = true,
		tags = { "childhood", "baby", "silt" },
		when = { minAge = 1, maxAge = 3, side = "gutters" },
		choices = {
			{
				label = "Hold out the crust",
				result = { prudence = 1, sanity = 3, log = "You held out your crust, and the gull took it as politely as a gull can. It came back every morning for a month." },
			},
			{
				label = "Grab its tail",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The gull", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 2, 3 }, sanity = 2, log = "You came away with a long grey tail feather. The gull went away with its pride in pieces." },
				lose = { fortitude = { -2, -1 }, sanity = -2, log = "The gull pecked your thumb, took the whole crust, and left you howling on the floor." },
			},
			{
				label = "Howl for help",
				result = { sanity = 1, relationBond = { kind = "family", amount = 3 }, log = "You howled until the whole stilt-house came running. The gull left with the crust anyway." },
			},
		},
	},
	{
		id = "kid2_nursemaid_song",
		title = "The Nursemaid's Song",
		text = "While your family dines downstairs under the gaslight, a nursemaid from the Gutters rocks your cradle. Her name is Odile, her hands smell of lye soap, and she is humming a Silt song your mother has asked her not to sing in this house: a lantern goes down, a lantern comes up.",
		once = true,
		weight = 12,
		tags = { "childhood", "baby", "rim", "thread_odile" },
		when = { minAge = 1, maxAge = 2, side = "charter", hasRelation = "mother" },
		choices = {
			{
				label = "Hold on to her finger",
				result = {
					setFlags = { "kid2_odile_song" },
					schedule = { event = "teen2_odile_again", inYears = 12 },
					prudence = 1,
					sanity = 3,
					log = "You held on to Odile's finger until you fell asleep, and the tune went down into you somewhere and stayed.",
				},
			},
			{
				label = "Hum along",
				result = {
					setFlags = { "kid2_odile_song" },
					schedule = { event = "teen2_odile_again", inYears = 12 },
					temperance = 1,
					sanity = 2,
					log = "You hummed along in a wobbly little drone, and Odile laughed so hard she had to put a hand over her mouth.",
				},
			},
			{
				label = "Cry for the gaslight",
				result = { justice = 1, sanity = -1, log = "You cried until the lamps were turned up. By the next week a different nursemaid rocked your cradle, one who didn't sing." },
			},
		},
	},
	{
		id = "kid2_thunder_night",
		title = "Thunder in the Crater",
		text = "A storm has come down into the crater and can't find its way out again. Thunder rolls from one wall to the other like barrels down a stair, and every flash turns the room white for a heartbeat: the table, the door, and a coat on its hook that looks exactly like a tall thin man.",
		once = true,
		tags = { "childhood", "baby" },
		when = { minAge = 2, maxAge = 4 },
		choices = {
			{
				label = "Count from flash to boom",
				result = { prudence = { 1, 2 }, sanity = 1, log = "You counted between each flash and its thunder, and the numbers got bigger until the storm belonged to some other Ward." },
			},
			{
				label = "Stare down the coat-man",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The coat on the hook", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 1, 2 }, sanity = 2, log = "You stared at the coat-man through three flashes until he gave up and turned back into a coat." },
				lose = { sanity = -3, log = "The coat-man grew taller with every flash. In the morning you were found asleep under the table, holding a spoon like a sword." },
			},
			{
				label = "Climb into a warm bed",
				requires = { hasRelation = { "mother", "father", "sibling" } },
				result = { sanity = 3, relationBond = { kind = "family", amount = 3 }, log = "You climbed into the nearest warm bed and slept through the rest of the storm with your cold feet on somebody's back." },
			},
		},
	},

	-- ── family ──────────────────────────────────────────────────────────────
	{
		id = "kid2_new_baby",
		title = "A New Baby",
		text = "The midwife comes up the stairs at midnight with her bag in one hand and her sleeves already rolled. You have been sent out to sit on the landing, and nobody has told you anything, which is how you know it is important. Through the door you can hear {mother} breathing hard, and the midwife talking low and steady, like someone coaxing a boat into its slip.",
		once = true,
		weight = 8,
		tags = { "childhood", "family" },
		when = { minAge = 3, maxAge = 9, hasRelation = "mother" },
		choices = {
			{
				label = "Wait on the landing",
				result = {
					addRelation = { kind = "sibling", age = 0, bond = 60 },
					prudence = { 1, 2 },
					log = "You waited on the cold landing until a thin, furious cry came through the door. Your new sibling, {newRelation}, had arrived.",
				},
			},
			{
				label = "Fetch hot water",
				result = {
					addRelation = { kind = "sibling", age = 0, bond = 55 },
					justice = { 1, 2 },
					relationBond = { kind = "mother", amount = 5 },
					log = "You ran kettles of hot water up and down four flights all night, and at dawn they let you hold {newRelation}.",
				},
			},
			{
				label = "Fall asleep on the stairs",
				result = {
					addRelation = { kind = "sibling", age = 0, bond = 65 },
					sanity = 3,
					log = "You fell asleep on the stairs and woke up a big sibling. {newRelation} was asleep too, and impossibly small.",
				},
			},
		},
	},
	{
		id = "kid2_fever_watch",
		title = "Fever in the Night",
		text = "{sibling} has the fog fever. Their face is as hot as a kettle lid, their breath rattles like a loose shutter, and the stitcher who was sent for still hasn't come. Somebody has to sit up through the night and keep the cloth cool.",
		once = true,
		tags = { "childhood", "family" },
		when = { minAge = 5, maxAge = 12, hasRelation = "sibling" },
		choices = {
			{
				label = "Sit up with the cloth",
				result = { prudence = { 2, 3 }, fortitude = -1, relationBond = { kind = "sibling", amount = 10 }, log = "You sat up all night wringing out the cloth in cold water. At dawn the fever broke, and {sibling} squeezed your hand without opening their eyes." },
			},
			{
				label = "Go and find the stitcher",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The night stairs", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 2, 3 }, relationBond = { kind = "sibling", amount = 6 }, log = "You ran down eleven flights in the dark and dragged the stitcher back by the sleeve. {sibling} was up and complaining in three days." },
				lose = { fortitude = { -3, -1 }, sanity = -2, relationBond = { kind = "sibling", amount = 3 }, log = "You slipped on the wet stairs and came home with skinned knees and no stitcher. The fever broke on its own, just before dawn." },
			},
			{
				label = "Pay for a Rim doctor",
				hint = "30 scrip.",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = 1, relationBond = { kind = "sibling", amount = 12 }, log = "You emptied your savings tin for a Rim doctor, who came in a closed carriage and left with all of it. {sibling} never forgot whose {currency} it was." },
			},
		},
	},

	-- ── growing up (any side) ───────────────────────────────────────────────
	{
		id = "kid2_lost_tooth",
		title = "A Tooth for the Mere",
		text = "Your first tooth comes out in a heel of hard bread. Everyone in Undermere knows what to do with a first tooth: you throw it in the Mere for the drowned, and in the morning they leave something on the step. Everyone also knows a diver on the docks who pays good {currency} for children's teeth, for luck.",
		once = true,
		tags = { "childhood", "custom" },
		when = { minAge = 5, maxAge = 8 },
		choices = {
			{
				label = "Throw it in the Mere",
				result = { prudence = 1, sanity = 3, log = "You threw your tooth into the Mere. In the morning there was a tiny white shell on the step, still wet." },
			},
			{
				label = "Sell it to the diver",
				result = { money = { 3, 6 }, sanity = -1, log = "A Wet Lantern paid you a few {currency} for the tooth and hung it on a string around his neck, next to eleven others." },
			},
			{
				label = "Keep it in a tin",
				result = { prudence = { 1, 2 }, log = "You kept the tooth in an old mustard tin under your bed, just in case the drowned came asking for it." },
			},
		},
	},
	{
		id = "kid2_wrong_tram",
		title = "The Wrong Tram",
		text = "The tram you climbed onto doesn't turn at the market. It keeps clanking on around the curve of the crater into a Ward you have never seen, where the roofs are a different color and people hurry in a different way. The conductor is asleep with his cap over his face.",
		once = true,
		tags = { "childhood", "tram" },
		when = { minAge = 5, maxAge = 9 },
		choices = {
			{
				label = "Ask a stranger the way",
				hint = "Prudence clash, easy.",
				clash = { stat = "prudence", foe = "A Ward full of strangers", coins = 1, base = 2, coinPower = 2 },
				win = { prudence = { 2, 3 }, sanity = 2, log = "A fishwife with a voice like a foghorn walked you to the right platform and paid your fare home herself." },
				lose = { fortitude = -1, sanity = -3, log = "You asked three strangers and got three different answers. It was dark before a Sluice clerk finally put you on the right tram." },
			},
			{
				label = "Ride it all the way around",
				result = { temperance = { 1, 2 }, sanity = 1, log = "You stayed on while the tram went all the way around the crater, through every Ward in Undermere, and got home at midnight knowing the whole loop by heart." },
			},
			{
				label = "Wake the conductor",
				result = { justice = 1, sanity = 2, log = "You woke the conductor. He grumbled, gave you a boiled sweet, and put you off at the right stop on the way back." },
			},
		},
	},
	{
		id = "kid2_kite_day",
		title = "Kite Day",
		text = "Once a year the wind comes up the crater walls strong enough to lift a kite, and the whole Ward climbs onto the roofs. Kites made of old tide tables, Sluice notices and somebody's best shirt dip and swing over the Mere. Yours is flying beautifully until it tangles with a red one belonging to a kid on the next roof.",
		once = true,
		tags = { "childhood", "festival", "friend" },
		when = { minAge = 6, maxAge = 10 },
		choices = {
			{
				label = "Reel in hard",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The red kite", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 2, 3 }, sanity = 2, log = "You hauled the red kite right out of the sky. Its owner shook a fist at you from the next roof, which was almost as good as a prize." },
				lose = { sanity = -2, log = "Your string snapped, and your kite sailed away over the Mere toward the drowned city without you." },
			},
			{
				label = "Climb across and untangle them",
				result = {
					addRelation = { kind = "friend", name = "Roan Hawley", bond = 50, age = { 6, 10 } },
					fortitude = -1,
					sanity = 3,
					log = "You climbed across the roof gutter and untangled the kites with {newRelation}. You flew them side by side until dark.",
				},
			},
			{
				label = "Let your kite go",
				result = { prudence = { 1, 2 }, justice = 1, log = "You let go of your string so the red kite could fly free. Yours sailed out over the Mere, and you watched it until it was only a speck." },
			},
		},
	},
	{
		id = "kid2_bottle_letter",
		title = "A Letter in a Bottle",
		text = "You have found a green glass bottle with its stopper still in, a scrap of clean paper, and a pencil stub worn down to the size of a bean. The Mere touches every Ward in Undermere. Somebody, somewhere along its shore, might fish your letter out.",
		once = true,
		weight = 12,
		tags = { "childhood", "thread_bottle" },
		when = { minAge = 7, maxAge = 11 },
		choices = {
			{
				label = "Write about your street",
				result = {
					setFlags = { "kid2_bottle_sent" },
					schedule = { event = "teen2_bottle_reply", inYears = 6 },
					temperance = 1,
					sanity = 2,
					log = "You wrote down everything about your street, signed your name, and threw the bottle as far out into the Mere as your arm would go.",
				},
			},
			{
				label = "Write down a secret",
				result = {
					setFlags = { "kid2_bottle_sent" },
					schedule = { event = "teen2_bottle_reply", inYears = 6 },
					prudence = 1,
					sanity = 3,
					log = "You wrote down a secret you had never told anyone, signed your name, and gave it to the Mere to keep.",
				},
			},
			{
				label = "Sell the bottle instead",
				result = { money = { 1, 3 }, log = "You sold the bottle to the rag-and-glass man for a few {currency}. Good green glass is good green glass." },
			},
		},
	},

	-- ── the water ───────────────────────────────────────────────────────────
	{
		id = "kid2_drowned_swing",
		title = "The Drowned Schoolyard",
		text = "Low Water has pulled back from a drowned schoolyard at the foot of the Terraces. Its railings are furred with weed, a slate on the wall still shows a sum nobody finished, and from the branch of a dead tree hangs a swing on green chains. It is moving very slightly, though there is no wind.",
		once = true,
		tags = { "childhood", "low_water", "strange" },
		when = { minAge = 6, maxAge = 12, world = { water = "low" } },
		choices = {
			{
				label = "Sit on the swing",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The drowned swing", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 2, 3 }, sanity = 1, log = "You swung higher and higher on the drowned swing until you could see the whole Silt. When you jumped off, it kept swinging a while without you." },
				lose = { fortitude = -1, sanity = -3, log = "The chains were colder than chains have any right to be. You let go halfway up and landed hard in the mud." },
			},
			{
				label = "Finish the sum on the slate",
				result = { temperance = { 2, 3 }, log = "You finished the drowned sum with a sliver of shell. Whoever had started it, a long time ago, had been getting it wrong." },
			},
			{
				label = "Stop the swing and go",
				result = { prudence = { 1, 2 }, sanity = 1, log = "You put a hand on the chain to stop it swinging, said sorry to nobody in particular, and went back up the stairs." },
			},
		},
	},
	{
		id = "kid2_flood_flotsam",
		title = "What the Flood Carries",
		text = "High Water has turned your row into a slow brown river, and everybody's belongings are floating past the window. A chair goes by, then a birdcage, then a wooden cradle, empty, turning in slow circles. You have a broom handle with a hook tied to the end, and a window that opens.",
		once = true,
		tags = { "childhood", "high_water", "silt" },
		when = { minAge = 5, maxAge = 11, side = "gutters", world = { water = "high" } },
		choices = {
			{
				label = "Hook the cradle",
				hint = "Temperance clash, easy.",
				clash = { stat = "temperance", foe = "The current", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 1, 2 }, sanity = 3, log = "You hooked the cradle and hauled it in. When the water went down, a family from the low row came looking for it and gave you a whole loaf for it." },
				lose = { fortitude = { -2, -1 }, sanity = -1, log = "The current tore the broom out of your hands, and you nearly went in after it. The cradle turned the corner and was gone." },
			},
			{
				label = "Fish out the birdcage",
				result = { temperance = 1, sanity = 3, log = "You fished the birdcage out of the flood. Inside was a soaked, furious finch, and it lived on your windowsill for years." },
			},
			{
				label = "Stay back from the window",
				result = { prudence = 2, sanity = -1, log = "You stayed back from the window like you were told and listened to things knocking against the stilts all night." },
			},
		},
	},

	-- ── the Gutters ─────────────────────────────────────────────────────────
	{
		id = "kid2_floodgate_game",
		title = "Floodgates",
		text = "The landing kids are playing Floodgates, chalked down the stairs like a map of the Silt. One kid plays the Sluice and stands on the top step deciding which squares get flooded, and anyone standing in a flooded square is out. Today, for the first time, they want you to be the Sluice.",
		once = true,
		tags = { "childhood", "rival" },
		when = { minAge = 5, maxAge = 9, side = "gutters" },
		choices = {
			{
				label = "Flood the kids who teased you",
				result = {
					addRelation = { kind = "rival", name = "Emrys Hale", bond = 30, age = { 6, 10 } },
					justice = { 1, 2 },
					sanity = 1,
					log = "You flooded every kid who had ever teased you. {newRelation} took it very personally and swore to be the Sluice next time.",
				},
			},
			{
				label = "Flood nobody at all",
				result = { justice = 2, sanity = -1, log = "You refused to flood anybody, so nobody was ever out and the game fell apart. A small girl at the bottom of the stairs looked at you as if you had worked a miracle." },
			},
			{
				label = "Flood your own square first",
				result = { prudence = 2, sanity = 2, log = "You flooded the square you were standing on. Everyone agreed you were the strangest Sluice they had ever had, and they let you play again." },
			},
		},
	},
	{
		id = "kid2_stair_dog",
		title = "A Dog Called Stairs",
		text = "A grey dog with one ear sleeps on the ninth landing of the switchback, and every kid on the Terraces calls it something different. Today it follows you down three landings, sits when you stop, and looks up at you as if it is still deciding what kind of person you are.",
		once = true,
		weight = 12,
		tags = { "childhood", "pet", "thread_stairs" },
		when = { minAge = 5, maxAge = 8, side = "gutters" },
		choices = {
			{
				label = "Share your bread with it",
				result = {
					setFlags = { "kid2_stairs_dog" },
					schedule = { event = "kid2_dog_warning", inYears = 3 },
					sanity = 4,
					log = "You split your bread with the dog. From then on it walked you home every evening and slept across your doorstep like a draft-stopper.",
				},
			},
			{
				label = "Give it a proper name",
				result = {
					setFlags = { "kid2_stairs_dog" },
					schedule = { event = "kid2_dog_warning", inYears = 3 },
					temperance = 1,
					prudence = 1,
					sanity = 2,
					log = "You named the dog Stairs, which everyone agreed was the only sensible name. It answered to it from the first day.",
				},
			},
			{
				label = "Shoo it away",
				result = { prudence = 1, sanity = -1, log = "You shooed the dog away. It went back up to the ninth landing and never looked at you again." },
			},
		},
	},
	{
		id = "kid2_dog_warning",
		title = "Stairs Won't Stop Barking",
		text = "In three years Stairs has never barked once, but tonight the old dog is barking at your door like a fire bell, tugging at your sleeve and backing toward the landing. Somewhere under the floorboards, a beam groans like a boat being pulled slowly apart.",
		weight = 0,
		once = true,
		tags = { "childhood", "pet", "danger", "thread_stairs" },
		when = { flags = { "kid2_stairs_dog" } },
		choices = {
			{
				label = "Bang on every door",
				result = { justice = { 2, 3 }, sanity = 3, relationBond = { kind = "family", amount = 4 }, log = "You banged on every door on the landing and had the whole stairwell out in the lane before the old stair came down. Stairs sat beside you, very pleased with itself." },
			},
			{
				label = "Follow Stairs down",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The sagging stair", coins = 1, base = 2, coinPower = 2 },
				win = { justice = { 2, 3 }, sanity = 4, log = "Stairs led you down to the coal store, where a neighbor's toddler had wandered in the dark. You carried her out a minute before the stair gave way." },
				lose = {
					fortitude = { -4, -2 },
					sanity = -2,
					condition = "broken_arm",
					log = "The stair dropped out from under you halfway down. Stairs dragged you clear by the collar, and your arm spent the season in a sling.",
					cause = "Fell when the old stair gave way",
				},
			},
			{
				label = "Hush the dog",
				result = { prudence = 1, sanity = -3, log = "You told Stairs to hush and went back to bed. At dawn the old stair came down with a roar, and only luck kept anyone from being on it." },
			},
		},
	},
	{
		id = "kid2_fish_bun",
		title = "The Fish Bun",
		text = "At the market a stallholder has a small boy by the collar and is shouting for the Sluice watch, a stolen fish bun squashed in the boy's fist. He can't be more than five. He isn't crying. He is looking straight at you, the way you look at a door you hope is unlocked.",
		once = true,
		tags = { "childhood", "market", "friend" },
		when = { minAge = 6, maxAge = 10, side = "gutters" },
		choices = {
			{
				label = "Pay for the bun",
				hint = "2 scrip.",
				requires = { min = { money = 2 } },
				result = {
					money = -2,
					justice = 1,
					addRelation = { kind = "friend", name = "Joss Pennock", bond = 55, age = { 4, 6 } },
					log = "You paid for the squashed bun, and the stallholder let go. {newRelation} followed you around for the rest of the year like a duckling.",
				},
			},
			{
				label = "Say the bun was yours",
				hint = "Prudence clash, easy.",
				clash = { stat = "prudence", foe = "The stallholder", coins = 1, base = 2, coinPower = 2 },
				win = { prudence = { 2, 3 }, justice = 1, log = "You swore the bun was yours and the boy was your cousin, so firmly that the stallholder ended up apologizing to you both." },
				lose = { temperance = 1, sanity = -2, log = "The stallholder knew a lie when he heard one, and he made you both sweep his stall until dark." },
			},
			{
				label = "Walk on",
				result = { prudence = 1, sanity = -2, log = "You looked away and walked on. You heard the watch whistle behind you, and you didn't turn around." },
			},
		},
	},
	{
		id = "kid2_whistle_back",
		title = "Something Whistles Back",
		text = "At the waterline you whistle the three-note call your neighbors use to find each other in the fog. From out on the black water, past the last stilt, the call comes back: the same three notes, perfectly, one beat late. There is no boat out there. There is nothing out there at all.",
		once = true,
		weight = 12,
		tags = { "childhood", "strange", "silt", "thread_whistle" },
		when = { minAge = 6, maxAge = 10, side = "gutters" },
		choices = {
			{
				label = "Whistle again",
				result = {
					setFlags = { "kid2_whistled_back" },
					schedule = { event = "teen2_whistle_in_fog", inYears = 7 },
					prudence = { 1, 2 },
					sanity = -2,
					log = "You whistled again, and it answered again, a little closer. You went home without telling anyone and lay awake listening to the water.",
				},
			},
			{
				label = "Run all the way home",
				result = { justice = 1, sanity = -2, log = "You ran home faster than you had ever run in your life and slept with the shutters latched for a week." },
			},
			{
				label = "Ask the Choir about it",
				result = { prudence = { 2, 3 }, sanity = 1, log = "A Choir woman on the steps heard you out and said, \"It's only lonely. Don't teach it any more of your tunes.\"" },
			},
		},
	},
	{
		id = "kid2_stilt_jump",
		title = "The Stilt Jump",
		text = "At low tide the Silt kids jump the gaps between the stilt-house walkways, and anyone who misses lands in the mud. The champion is Greer Ingram, who has a gap in her teeth and has never once landed in mud. She is standing on the far side of the widest gap with her arms folded, waiting to see what you'll do.",
		once = true,
		weight = 12,
		tags = { "childhood", "silt", "rival", "thread_greer" },
		when = { minAge = 8, maxAge = 11, side = "gutters" },
		choices = {
			{
				label = "Jump the widest gap",
				hint = "Justice clash, easy.",
				clash = { stat = "justice", foe = "The widest gap", coins = 1, base = 2, coinPower = 2 },
				win = {
					setFlags = { "kid2_greer_jump" },
					schedule = { event = "teen2_greer_rematch", inYears = 5 },
					justice = { 2, 4 },
					sanity = 3,
					log = "You cleared the widest gap with a hand's width to spare. Greer Ingram looked at you for a long moment and said, \"Again next year.\"",
				},
				lose = {
					setFlags = { "kid2_greer_jump" },
					schedule = { event = "teen2_greer_rematch", inYears = 5 },
					fortitude = { -2, -1 },
					sanity = -1,
					log = "You landed in mud up to your knees. Greer hauled you out, laughing, and said that at least you had legs.",
				},
			},
			{
				label = "Dare her to jump it backward",
				result = {
					setFlags = { "kid2_greer_jump" },
					schedule = { event = "teen2_greer_rematch", inYears = 5 },
					prudence = { 1, 2 },
					sanity = 2,
					log = "You dared Greer to jump it backward. She did, landed in mud for the first time in her life, and swore she would get you back for it.",
				},
			},
			{
				label = "Stick to the small gaps",
				result = { temperance = 1, sanity = 2, log = "You jumped the small gaps with the little kids and taught three of them how to land without losing a boot." },
			},
		},
	},
	{
		id = "kid2_knot_lessons",
		title = "Twelve Knots",
		text = "Isolde Kestle walked rope for the Hempen Company for fifty years, until her knees gave out. Now she sits on a crate at the foot of your stairs, tying and untying a length of tarred line without looking at it. \"Twelve knots,\" she says. \"One a week. Fetch my bread from the market, and they're yours.\"",
		once = true,
		weight = 12,
		tags = { "childhood", "friend", "thread_knots" },
		when = { minAge = 8, maxAge = 11, side = "gutters" },
		choices = {
			{
				label = "Learn all twelve",
				result = {
					setFlags = { "kid2_twelve_knots" },
					schedule = { event = "teen2_twelfth_knot", inYears = 5 },
					temperance = { 2, 3 },
					addRelation = { kind = "friend", name = "Isolde Kestle", bond = 50, age = { 68, 78 } },
					log = "You fetched {newRelation}'s bread for twelve weeks and learned twelve knots. The last one, she said, was for the day you needed it.",
				},
			},
			{
				label = "Learn only the fancy ones",
				result = { justice = 1, temperance = 1, sanity = 2, log = "You learned the three prettiest knots and showed them off on the docks until everyone was sick of them." },
			},
			{
				label = "Tie her bootlaces together",
				result = { justice = 1, sanity = 2, log = "You tied Isolde's bootlaces together while she dozed. She woke, looked down, and laughed until she had to wipe her eyes." },
			},
		},
	},

	-- ── the Charter ─────────────────────────────────────────────────────────
	{
		id = "kid2_party_conjurer",
		title = "The Conjurer on the Lawn",
		text = "The director's daughter is turning seven, and every Charter child in the Ward has been sent in stiff collars to watch a conjurer from the Gutters do tricks on the lawn. He is thin, and the elbows of his coat are patched with velvet. When his doves won't come out of the hat, the other children start pelting him with sugared almonds.",
		once = true,
		tags = { "childhood", "rim" },
		when = { minAge = 5, maxAge = 9, side = "charter", notDistrict = "drownside" },
		choices = {
			{
				label = "Throw an almond too",
				result = { justice = -2, sanity = 1, log = "You threw an almond too, and everyone laughed, and you laughed. It was years before you thought about his face." },
			},
			{
				label = "Clap for him, loudly",
				result = { justice = { 2, 3 }, sanity = -1, log = "You clapped as loudly as you could. A few children joined in, the doves came out after all, and the conjurer bowed to you and only you." },
			},
			{
				label = "Save him some cake",
				result = { justice = 1, temperance = { 1, 2 }, log = "You wrapped two slices of cake in a napkin and slipped them to him behind the hedge. In return he showed you exactly how the coin trick worked." },
			},
		},
	},
	{
		id = "kid2_company_school",
		title = "The Company School",
		text = "Portraits of old directors watch the company school from every wall, and most of the lessons are about them. Today Mistress Mira Sallow asks the class why the Silt floods every High Water and the Rim never does. The answer in your primer is \"because the Rim was prudent\". She is looking out of the window as she asks it.",
		once = true,
		weight = 12,
		tags = { "childhood", "rim", "study", "thread_sallow" },
		when = { minAge = 7, maxAge = 10, side = "charter", notDistrict = "drownside" },
		choices = {
			{
				label = "Recite the primer",
				result = { temperance = { 2, 3 }, log = "You recited the primer word for word and got a gold star on your slate. Mistress Sallow didn't look at you when she gave it." },
			},
			{
				label = "Ask her what she thinks",
				result = {
					setFlags = { "kid2_asked_sallow" },
					schedule = { event = "teen2_old_teacher", inYears = 6 },
					justice = { 1, 2 },
					prudence = 1,
					log = "You asked Mistress Sallow what she thought, and she told the class the truth about the floodgates for ten whole minutes. By the next week she was gone, and nobody would say where.",
				},
			},
			{
				label = "Look out of the window too",
				result = { prudence = { 1, 2 }, sanity = 1, log = "You looked out of the window too. Far below the wall the Silt lay grey under its fog, and for a moment you both looked at it." },
			},
		},
	},

	-- ── the Wards ───────────────────────────────────────────────────────────
	{
		id = "kid2_pumpside_hand_talk",
		title = "Hand-Talk",
		text = "Nobody in Pumpside can hear a word over the great pumps, so the stokers talk with their hands: a fist for steam, two fingers for the valve, a flat palm for stop. Pumpside kids learn it before they learn their letters. Today a Valve Keeper on her break is signing jokes at you through the ash-yard fence.",
		once = true,
		weight = 12,
		tags = { "childhood", "pumpside" },
		when = { district = "pumpside", minAge = 6, maxAge = 11 },
		choices = {
			{
				label = "Learn all of it",
				result = { temperance = { 2, 3 }, log = "You learned the whole of the stokers' hand-talk that summer, and could argue with anyone in Pumpside without making a sound." },
			},
			{
				label = "Sign back something cheeky",
				result = { justice = 1, sanity = 3, log = "You signed back the cheekiest thing you knew, which was that her boiler leaked. She laughed until the whole ash yard turned to look." },
			},
			{
				label = "Out-shout the pumps",
				hint = "Fortitude clash, easy.",
				clash = { stat = "fortitude", foe = "The Number Four Pump", coins = 1, base = 2, coinPower = 2 },
				win = { fortitude = { 1, 2 }, justice = 1, sanity = 2, log = "For one glorious second you were louder than the Number Four Pump, and the whole ash yard cheered with its hands." },
				lose = { fortitude = -1, sanity = -1, log = "You shouted until your throat was raw, and nobody heard a thing. Your voice came back three days later, hoarse and sulking." },
			},
		},
	},
	{
		id = "kid2_saltpan_stone_pickers",
		title = "The Stone Pickers",
		text = "The Saltworks pays Gutter children by the bucket to sit at the foot of the white heaps and pick grit out of the salt, one stone at a time. The salt is bright enough to make your eyes water, and it finds every scratch on your hands. The boy beside you says that if you hum, the day goes faster.",
		cooldown = 4,
		weight = 12,
		tags = { "childhood", "saltpan", "job" },
		when = { district = "saltpan", side = "gutters", minAge = 6, maxAge = 11 },
		choices = {
			{
				label = "Pick from dawn to dark",
				hint = "Fortitude clash, easy.",
				clash = { stat = "fortitude", foe = "The salt dust", coins = 1, base = 2, coinPower = 2 },
				win = { wage = { 5, 9 }, temperance = 1, log = "You picked stones from dawn to the last bell and walked home with a few {currency} and hands as white as a baker's." },
				lose = { wage = { 5, 9 }, condition = "salt_cough", log = "You picked stones from dawn to dark and went home with your pay and a dry white cough that wouldn't leave." },
			},
			{
				label = "Hum, then play in the heaps",
				result = { wage = { 1, 4 }, sanity = 3, log = "You hummed through the morning with the boy, then slid down the white heaps together until a foreman chased you off." },
			},
			{
				label = "Smuggle salt out in your boots",
				result = { justice = -1, prudence = 1, sanity = 1, relationBond = { kind = "family", amount = 4 }, log = "You walked out past the foreman with a lump of salt in each boot. The whole stairwell salted its fish with it for a month, and your feet stung for a week." },
			},
		},
	},
	{
		id = "kid2_glasswall_cullet",
		title = "Cullet Day",
		text = "Once a month the Glaziers' Charter tips its broken glass down a chute into the Gutters, and children in sacking mittens sift the heap for colored pieces to sell. Today, under a drift of green shards, you find a perfect round lens the size of a coin. Through it, the Charter wall looks close enough to touch.",
		once = true,
		tags = { "childhood", "glasswall", "study" },
		when = { district = "glasswall", side = "gutters", minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Keep the lens",
				result = { temperance = { 2, 3 }, sanity = 2, log = "You kept the lens and spent the whole winter looking at things through it: fish scales, frost, the weave of your own sleeve." },
			},
			{
				label = "Sell it to a peddler",
				result = { money = { 8, 15 }, log = "A peddler with a jeweler's eyepiece bought the lens on the spot and paid you more {currency} than you had ever held at once." },
			},
			{
				label = "Give it to the girl who saw it first",
				result = { justice = { 2, 3 }, sanity = 1, log = "You gave the lens to the smallest sifter, who had seen it a second before you did. She looked at you through it, solemn as a judge." },
			},
		},
	},
	{
		id = "kid2_bellhollow_counting_seat",
		title = "The Counting Seat",
		text = "Bellhollow's hundred bells are meant to strike every hour together, so the Bellwrights pay children to sit up in the towers and count the strokes from their neighbors, and the late towers get fined. Master Cyr Tolland gives you a blanket, a slate and the north window. The first bell is a long time coming.",
		once = true,
		weight = 12,
		tags = { "childhood", "bellhollow", "job" },
		when = { district = "bellhollow", minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Count every stroke till dawn",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The long night", coins = 1, base = 2, coinPower = 3 },
				win = { wage = { 5, 9 }, prudence = { 2, 3 }, log = "You counted every stroke from every tower until dawn. Master Tolland checked your slate twice and paid you double." },
				lose = { wage = { 1, 3 }, sanity = -1, log = "You fell asleep at three and woke to the dawn bells. Master Tolland paid you half and said everybody nods off the first time." },
			},
			{
				label = "Cover for the old east tower",
				result = { justice = { 1, 2 }, sanity = 2, log = "The old ringer in the east tower was always a beat late because her hands shook. You marked her on time every night, and the fines stopped coming." },
			},
			{
				label = "Ask to be paid in a bell",
				result = { gear = "little_bell", prudence = 1, log = "You asked for the little brass bell on the windowsill instead of your pay. Master Tolland laughed and let you have it." },
			},
		},
	},
	{
		id = "kid2_kelpmarket_bulb_boats",
		title = "The Bulb-Boat Race",
		text = "On First Cut, when the Kelp & Net Company harvests the season's first kelp, the children of Kelpmarket race boats made of kelp bulbs and stick masts down the farm channel. The whole market crowds the landing to shout. Your boat is lumpy and lopsided, and you love it completely.",
		once = true,
		weight = 12,
		tags = { "childhood", "kelpmarket", "festival" },
		when = { district = "kelpmarket", minAge = 5, maxAge = 10 },
		choices = {
			{
				label = "Race it to win",
				hint = "Temperance clash, easy.",
				clash = { stat = "temperance", foe = "Forty other bulb-boats", coins = 1, base = 2, coinPower = 2 },
				win = { temperance = { 2, 3 }, money = { 2, 5 }, sanity = 4, log = "Your lopsided boat caught a current nobody else saw and won by a length. The prize was a paper crown and a few {currency} twisted up in kelp paper." },
				lose = { sanity = -1, log = "Your boat rolled over at the first bend and sank with great dignity. The whole landing clapped anyway." },
			},
			{
				label = "Swap boats with the smallest racer",
				result = { justice = 2, sanity = 2, log = "You swapped boats with the smallest kid on the landing. Your lumpy boat came in third, and she shrieked the whole way down the channel." },
			},
			{
				label = "Sail it out to the open Mere",
				result = { prudence = 1, sanity = 3, log = "You let your boat go out past the farms into the open Mere. It never sank while you watched, and an old kelp-cutter said that meant a long life." },
			},
		},
	},
}
