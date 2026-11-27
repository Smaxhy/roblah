--[[
	Danger and horror (dz_): every District kills you its own way. Wings and Singularities
	follow CANON.md section 2; the incidents are original.
	Chains:
		dz_x_whistle -> dz_x_drain                  District 7: something Old G Corp left
		dz_x_room_shrinks -> (3 years) dz_x_room_lender   District 8: a loan from a Family
		dz_x_outskirts_job                          opens the Past the Last Wall expedition
]]

return {
	-- ── District 4: a branch under the street ──
	{
		id = "dz_x_basement",
		title = "Behind the Basement Wall",
		text = "The basement wall crumbled overnight. Behind it runs a corridor of white tile under green emergency lights: part of the L Corp branch buried under District 4. Something down there is walking.",
		weight = 4,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, district = "d4", world = { era = { "library", "limbus" } } },
		codex = "lc_lore_branches",
		choices = {
			{
				label = "Brick it back up",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A wall that wants to be open", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -3, intelligence = 1, log = "You bricked it up and painted it over. The walking stopped by spring." },
				lose = { sanity = -8, condition = "dz_terror", log = "In the morning the new bricks were stacked neatly on the floor, and the corridor lights were brighter." },
			},
			{
				label = "Go down with a lamp",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Whatever walks the branch", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { money = { 80, 200 }, sanity = -6, log = "You came back up with an armful of old L Corp safety manuals and a badge with a stranger's face. A collector paid well." },
				lose = { health = { -18, -8 }, sanity = -8, log = "Three corridors in, the lights went out. Something walked you back to the stairs, very close behind.", cause = "Met something in a buried L Corp branch" },
			},
			{ label = "Sell the way in to scavengers", result = { money = { 100, 250 }, sanity = -2, log = "A scavenger crew paid you for the key to your own basement. Two of the five came back up." } },
		},
	},

	-- ── District 7: what the Smoke War left ──
	{
		id = "dz_x_shell",
		title = "The Shell in the Rubble",
		text = "Kids found something in the rubble behind the old G Corp depot: a dark shell the size of a car, warm to the touch. Since Tuesday it has been ticking.",
		weight = 4,
		once = true,
		tags = { "danger" },
		when = { minAge = 13, district = "d7" },
		codex = "dz_lore_smoke_relics",
		choices = {
			{ label = "Clear the street", result = { sanity = -3, strength = 1, log = "Half the street left. On Friday the shell split, and what came out went down into the drains, never to be seen again, officially." } },
			{ label = "Sell it to a scrap dealer", result = { money = { 150, 300 }, sanity = -4, log = "The dealer paid well and towed it away. His yard has been very quiet since, and nobody goes in to check." } },
			{
				label = "Crack it open",
				clash = { stat = "strength", foe = "A Smoke War weapon, waking", coins = 3, base = 8, coinPower = 4, fight = true, status = { id = "rupture", potency = 2 } },
				win = { strength = 3, wage = { 150, 300 }, log = "What came out was half-formed and furious, and you finished it before it finished itself. A veterans' society paid for the shell." },
				lose = { health = { -22, -10 }, condition = "dz_maimed", log = "What came out was fully formed.", cause = "Opened a Smoke War weapon" },
			},
		},
	},
	{
		id = "dz_x_whistle",
		title = "The Old Whistle",
		text = "In your father's box of Smoke War things there's a G Corp whistle. Veterans say Old G Corp used them to call its decisive weapons. Lately, something in the drains under your street has started scratching.",
		weight = 10,
		once = true,
		when = { minAge = 16, flags = { "smoke_war_family" } },
		codex = "dz_lore_smoke_relics",
		choices = {
			{ label = "Blow it once", result = { sanity = -8, trigger = "dz_x_drain", log = "One short note, and the whole street went silent. Then, far below, something answered." } },
			{ label = "Bury it in the rubble lot", result = { sanity = 1, log = "You buried it deep. The scratching stopped by winter." } },
			{ label = "Sell it to a collector", result = { money = { 200, 400 }, sanity = -2, log = "A collector from another District paid far too much and wouldn't give his name. You hope he never blows it." } },
		},
	},
	{
		id = "dz_x_drain",
		title = "What Answered",
		text = "At midnight the drain grate in the street lifts by itself. Something comes up out of it, low and armored and much too large, and turns toward the sound it remembers.",
		weight = 0,
		codex = "dz_lore_smoke_relics",
		choices = {
			{
				label = "Blow it again, and command it",
				hint = "Mental Strength check. Very bad odds.",
				clash = { stat = "mind", foe = "A decisive weapon", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -12, setFlags = { "dz_unsurvivable" }, addTrait = "dz_dread_calm", log = "Three notes, the way the old manuals said, and it sank back down into the dark. You threw the whistle in after it." },
				lose = { die = "Called something up from the Smoke War", log = "It didn't remember you." },
			},
			{
				label = "Run and wake the street",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Something faster than it looks", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -6, log = "You hammered on every door, and by the time it reached your building the street was empty. It went back down at dawn." },
				lose = { health = { -20, -8 }, log = "It was faster than it looked.", cause = "Killed by something Old G Corp left in the drains" },
			},
			{
				label = "Fight it",
				clash = { stat = "strength", foe = "The thing from the drains", coins = 4, base = 9, coinPower = 4, fight = true, status = { id = "tremor", potency = 3 } },
				win = { strength = 4, wage = { 300, 600 }, setFlags = { "dz_unsurvivable" }, log = "It took until dawn and most of the street's furniture. G Corp sent a truck for what was left, and an envelope." },
				lose = { die = "Fought a Smoke War weapon in the street", log = "It had been built for exactly this." },
			},
			{ label = "Hide in the cellar", result = { sanity = -10, condition = "dz_terror", log = "It searched the street until dawn, calling with your father's whistle-note. Then it went back down." } },
		},
	},

	-- ── District 8: rooms that follow your fortune ──
	{
		id = "dz_x_room_shrinks",
		title = "The Walls Moved In",
		text = "In Hongyuan your room grows and shrinks with your fortune. You've lost money this year, and tonight you wake to the sound of the walls moving in, slowly, toward the bed.",
		weight = 4,
		once = true,
		tags = { "danger" },
		when = { minAge = 16, district = "d8", max = { money = 150 } },
		codex = "bs_lore_hongyuan_rooms",
		choices = {
			{
				label = "Brace the walls",
				hint = "Health check.",
				clash = { stat = "health", foe = "Two walls closing in", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -6, log = "You wedged the wardrobe between the walls and held it till dawn. In the morning your room was the size of a wardrobe." },
				lose = { health = { -18, -8 }, condition = "dz_maimed", log = "The wardrobe cracked first.", cause = "Crushed when a Hongyuan room shrank" },
			},
			{ label = "Sleep in the corridor", result = { sanity = -6, log = "You slept in the corridor for a month. The corridor shrank too, but slower." } },
			{ label = "Borrow from a Family lender", result = { money = 150, sanity = -2, schedule = { event = "dz_x_room_lender", inYears = 3 }, log = "The walls stopped where they were. The lender, a polite man from one of the Four Families, will want it back with interest." } },
		},
	},
	{
		id = "dz_x_room_lender",
		title = "The Lender Calls",
		text = "The polite man from the Four Families is at your door. \"Three hundred,\" he says. \"Or the room can settle the account itself.\" Behind you, the walls creak.",
		weight = 0,
		when = { district = "d8" },
		codex = "wg_lore_hcorp",
		choices = {
			{ label = "Pay him", hint = "300 Ahn.", requires = { min = { money = 300 } }, result = { money = -300, sanity = 2, log = "You paid, and he bowed. The walls eased back an inch, as if relieved." } },
			{
				label = "Ask for more time",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A Family's patience", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { money = -100, sanity = -2, log = "He took a hundred and a promise. The Four Families are very good at waiting." },
				lose = { health = { -18, -8 }, sanity = -6, log = "He shook his head and left. The walls didn't wait for him to reach the stairs.", cause = "Settled a Hongyuan debt the hard way" },
			},
			{ label = "Move out with nothing", result = { money = -100, sanity = -8, loseGear = true, log = "You walked out with the clothes you had on. Your room closed up behind you like a fist." } },
		},
	},

	-- ── District 11: the drones ──
	{
		id = "dz_x_drone",
		title = "The Drone Watches",
		text = "Rats left you hurt in a District 11 gutter. A K Corp drone glides down and hovers a meter above you, filming. It doesn't call anyone. It just watches, very closely.",
		weight = 3,
		once = true,
		tags = { "danger" },
		when = { minAge = 16, district = "d11", side = "backstreets" },
		codex = "wg_lore_kcorp",
		choices = {
			{
				label = "Crawl to the clinic",
				hint = "Health check.",
				clash = { stat = "health", foe = "Four blocks", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { health = { -10, -4 }, sanity = -4, log = "You crawled four blocks. The drone followed the whole way, filming." },
				lose = { health = { -18, -8 }, sanity = -6, log = "You got two blocks. The drone stayed until a clinic van came, and filmed that too.", cause = "Left in a gutter while a drone filmed" },
			},
			{ label = "Wave it away", result = { health = { -12, -6 }, sanity = -8, log = "It came closer. Later you heard K Corp pays very well for footage like yours, and doesn't say why.", cause = "Left in a gutter while a drone filmed" } },
			{
				label = "Stare into the lens",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Something behind the lens", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { health = { -8, -4 }, sanity = -10, mind = 3, log = "You stared into it until it backed away. For a second, behind the lens, you'd have sworn something was crying." },
				lose = { health = { -14, -6 }, sanity = -12, log = "It hovered there all night. You stopped being able to look away.", cause = "Left in a gutter while a drone filmed" },
			},
		},
	},

	-- ── District 14: the Hammers ──
	{
		id = "dz_x_inquisitors",
		title = "The Hammers Are Knocking",
		text = "N Corp's Inquisitors are going door to door on your street, hunting anyone with a prosthetic. They call it impurity. Your neighbor Henrik has a steel left hand.",
		weight = 4,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, district = "d14" },
		codex = "bs_lore_butter_street",
		choices = {
			{
				label = "Hide Henrik",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Inquisitors at the door", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -4, addRelation = { kind = "friend", name = "Henrik Vogt", bond = 65, age = { 35, 50 } }, log = "Henrik spent two days in your wardrobe while they knocked twice and moved on. He mends your shoes for free now." },
				lose = { health = { -18, -8 }, condition = "broken_arm", log = "They found him. They took their time with the one who hid him.", cause = "Hid a neighbor from the Inquisitors" },
			},
			{ label = "Keep your door shut", result = { sanity = -8, log = "They took Henrik at noon. Nobody on the street said his name again." } },
			{
				label = "Stand in their way",
				clash = { stat = "strength", foe = "An Inquisitor with a hammer", coins = 3, base = 8, coinPower = 4, fight = true, status = { id = "tremor", potency = 2 } },
				win = { strength = 3, addRelation = { kind = "friend", name = "Henrik Vogt", bond = 75, age = { 35, 50 } }, log = "You put the Inquisitor on the cobbles in front of the whole street, and they left. They'll be back for both of you." },
				lose = { health = { -22, -10 }, log = "The hammer came down.", cause = "Stood in the Inquisitors' way" },
			},
		},
	},

	-- ── District 16: space that bends ──
	{
		id = "dz_x_folded",
		title = "The Street Folded",
		text = "P Corp's buildings bend like rubber and stay safe inside. Outside is another matter: tonight the whole street folded in half like a sheet of paper, and you're in the crease.",
		weight = 3,
		once = true,
		tags = { "danger" },
		when = { minAge = 13, district = "d16" },
		choices = {
			{
				label = "Climb out along the fold",
				hint = "Health check.",
				clash = { stat = "health", foe = "A folded street", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -4, log = "You climbed the crease like a ladder and dropped out of it onto somebody's balcony." },
				lose = { health = { -18, -8 }, log = "The fold tightened.", cause = "Caught in a fold of P Corp space" },
			},
			{
				label = "Get inside a building",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "A door at a strange angle", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -2, log = "Inside it was perfectly safe and perfectly quiet, exactly as advertised. The street unfolded at dawn." },
				lose = { health = { -16, -6 }, log = "The door was on the ceiling by the time you reached it.", cause = "Caught in a fold of P Corp space" },
			},
			{ label = "Lie flat and wait", result = { sanity = -8, condition = "dz_terror", log = "You lay very flat for nine hours with the street pressed close above you like a lid." } },
		},
	},

	-- ── District 18: the packs ──
	{
		id = "dz_x_live_fire",
		title = "Live-Fire Exercise",
		text = "R Corp's Fourth Pack is running a live-fire exercise through the Backstreets: Rabbits in pairs, sweeping street by street. Nobody told the street. A Rabbit's visor turns toward you.",
		weight = 3,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, district = "d18", side = "backstreets" },
		codex = "wg_lore_rcorp",
		choices = {
			{
				label = "Hands up, stand still",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A Rabbit's visor", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -4, log = "The visor held on you for a long second. Then it moved on." },
				lose = { health = { -18, -8 }, log = "You flinched.", cause = "Caught in an R Corp live-fire exercise" },
			},
			{
				label = "Run for cover",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "A Rabbit pair", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = -3, speed = 1, log = "You were through the noodle shop's back door before the first burst." },
				lose = { health = { -20, -8 }, log = "Rabbits are trained for exactly this.", cause = "Caught in an R Corp live-fire exercise" },
			},
			{
				label = "Wave your work papers",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A clone with orders", coins = 2, base = 4, coinPower = 3, fixed = true },
				win = { sanity = -2, log = "\"Contractor,\" the Rabbit said into its radio, and waved you on. You weren't one." },
				lose = { health = { -14, -6 }, log = "It didn't read papers.", cause = "Caught in an R Corp live-fire exercise" },
			},
			{ label = "Lie flat in the gutter", result = { sanity = -6, health = { -5, -2 }, cause = "Caught in an R Corp live-fire exercise", log = "You lay in the gutter with your hands over your head while the exercise went over you." } },
		},
	},

	-- ── District 19: the hunters ──
	{
		id = "dz_x_hunters",
		title = "The Ch'unokkun",
		text = "Two men in wide hats are asking at the noodle stall about a family who ran from the King's Court years ago. They have your parents' names. The Ch'unokkun never stop hunting runaways.",
		weight = 10,
		once = true,
		tags = { "danger" },
		when = { minAge = 12, flags = { "runaway_family" } },
		choices = {
			{
				label = "Warn your family and hide",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Patient hunters", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -4, log = "You hid in a cellar for nine days. On the tenth the hats were gone from the noodle stall." },
				lose = { health = { -18, -8 }, sanity = -6, log = "They found the cellar on the third day.", cause = "Taken by the Ch'unokkun" },
			},
			{
				label = "Fight them",
				clash = { stat = "strength", foe = "Two Ch'unokkun", coins = 3, base = 8, coinPower = 4, fight = true, status = { id = "bleed", potency = 2 } },
				win = { strength = 3, sanity = -2, log = "They left without their hats. The Court will send more, but not this year." },
				lose = { health = { -22, -10 }, log = "They had done this many, many times.", cause = "Cut down by the Ch'unokkun" },
			},
			{ label = "Run to another District", hint = "80 Ahn.", requires = { min = { money = 80 } }, result = { money = -80, sanity = -4, log = "You were on a WARP train by dusk, and so was everyone you could warn." } },
		},
	},

	-- ── District 20: the Time Office ──
	{
		id = "dz_x_bag",
		title = "A Bag Under the Bench",
		text = "In the queue at the T Corp Time Office, someone has left a bag under the bench. It's ticking, which in District 20 could mean anything. A woman in a Yurodiviye scarf is walking away very fast.",
		weight = 3,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, district = "d20" },
		codex = "wg_lore_tcorp",
		choices = {
			{
				label = "Get everyone out",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "Ninety seconds", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { strength = 2, sanity = 2, log = "Thirty people were out on the steps when the windows blew. Not one of them was hurt." },
				lose = { health = { -18, -8 }, condition = "burns", log = "You were still in the doorway.", cause = "Caught in the Time Office blast" },
			},
			{
				label = "Carry it outside",
				hint = "Health check.",
				clash = { stat = "health", foe = "A ticking bag", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { strength = 3, sanity = -2, log = "You set it down in an empty square and ran, and it went at 10:04. T Corp sent you a letter about the paving." },
				lose = { health = { -22, -10 }, condition = "dz_maimed", log = "It went at 10:03.", cause = "Carried a Yurodiviye bomb a second too long" },
			},
			{ label = "Leave quietly", result = { sanity = -6, log = "You were two streets away when it went. You read the morning list twice." } },
		},
	},

	-- ── District 21: the Great Lake ──
	{
		id = "dz_x_lake_net",
		title = "What the Net Brought Up",
		text = "The fishing crew's net comes up heavy. Tangled in it, furious, is a Trash Crab the size of a cart with a rifle grown into one claw. It's already aiming.",
		weight = 4,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, district = "d21" },
		codex = "dz_lore_trash_crabs",
		choices = {
			{
				label = "Cut the net loose",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A tangled net", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -3, money = -20, log = "You cut it loose, catch and all. The captain docked your pay and shook your hand." },
				lose = { health = { -16, -8 }, log = "It fired as the net dropped.", cause = "Shot by a Trash Crab on a fishing boat" },
			},
			{
				label = "Fight it on deck",
				clash = { stat = "strength", foe = "A Trash Crab with a rifle", coins = 3, base = 7, coinPower = 4, fight = true, status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = { 150, 300 }, log = "You cracked its shell with a gaff hook. A U Corp Workshop bought the gun-claw for a small fortune." },
				lose = { health = { -22, -10 }, log = "It was quicker on deck than any crab should be.", cause = "Killed by a Trash Crab on a fishing deck" },
			},
			{
				label = "Dive overboard",
				hint = "Speed check. Very bad odds.",
				clash = { stat = "speed", foe = "The Great Lake", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -6, setFlags = { "dz_unsurvivable" }, log = "You swam to a buoy and hung on until the shooting stopped. The lake was very cold, and something large brushed your leg and let you go." },
				lose = { die = "Lost in the Great Lake", log = "The lake was very cold, and very deep, and not empty." },
			},
			{ label = "Duck behind the wheelhouse", result = { sanity = -6, money = -20, log = "You crouched behind the wheelhouse until the crab shot itself empty and the crew cut it loose. The captain docked everyone's pay." } },
		},
	},

	-- ── District 23: the WARP trains ──
	{
		id = "dz_x_passenger",
		title = "Something Left on the Train",
		text = "A man steps off the 7:40 WARP train and stops dead on the platform, looking at his own hands. Everyone else walks round him. He says he feels fine. He says it was quick. He cannot stop looking at his hands, and two cleanup agents at the far end have noticed.",
		weight = 4,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, district = "d23" },
		codex = "districts_w_corp",
		choices = {
			{ label = "Call the cleanup crew over", result = { money = 30, sanity = -5, log = "The crew was there in seconds, polite and quick. They walked him to a side door, talking kindly. They gave you thirty Ahn and a form saying you'd seen nothing." } },
			{
				label = "Ask him what's wrong",
				hint = "Mental Strength check. The agents are watching who he talks to.",
				clash = { stat = "mind", foe = "Two agents, walking this way", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { mind = 3, sanity = -4, log = "\"Nothing,\" he said. \"It was ten seconds. I just had the feeling I'd left something on the train. Something big.\" He laughed at himself and went to work. You were gone before the agents reached the bench." },
				lose = { health = { -16, -6 }, condition = "dz_hunted", cause = "Asked the wrong question on a WARP platform", log = "He never got to answer. The agents took him one way and you the other, and asked what he'd said to you until you had nothing left to tell them." },
			},
			{
				label = "Walk round him like everyone else",
				result = { sanity = -2, log = "You walked round him. At the top of the stairs you looked back. The platform was empty, and somebody was mopping where he'd stood." },
			},
		},
	},
	{
		id = "dz_x_ten_seconds",
		title = "Ten Seconds",
		text = "You take the WARP train across the City. It's ten seconds, they say. The doors close. The lights dim. Then the doors open on another platform, and the clock says ten seconds, and you feel fine. A little too fine, like a room somebody has tidied.",
		weight = 2,
		once = true,
		when = { minAge = 16, min = { money = 60 } },
		codex = "districts_w_corp",
		choices = {
			{
				label = "Try to remember the ride",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Ten seconds with nothing in them", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { mind = 2, sanity = -2, log = "There was nothing to remember: the lights dipped, and you were there. You decided that was all there was to it. It took you most of the day to decide." },
				lose = { sanity = -8, log = "There was nothing to remember, and you couldn't leave it alone. You had the feeling of a word on the tip of your tongue for a month." },
			},
			{
				label = "Check your pockets",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Everything exactly where you left it", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { intelligence = 2, sanity = -2, log = "Everything was where you'd put it, down to the ticket stub. Whatever W Corp does in ten seconds, it does it neatly." },
				lose = { sanity = -6, log = "Everything was where you'd put it. You checked again at home, and again that night, and couldn't have said what you were looking for." },
			},
			{ label = "Pay for First Class", hint = "400 Ahn. You sleep through it.", requires = { min = { money = 400 } }, result = { money = -400, sanity = 1, log = "First Class put you to sleep before the doors closed, and you woke rested, with a complimentary snack. It felt exactly the same as the cheap seats, only with a snack." } },
		},
	},

	-- ── the edge of the City ──
	{
		id = "dz_x_over_the_wall",
		title = "Prints the Size of Doors",
		text = "Dogs have been vanishing at the edge of the District. Last night something tall walked the length of the old wall, and this morning there are prints in the mud the size of doors.",
		weight = 2,
		once = true,
		tags = { "danger" },
		when = { minAge = 14, side = "backstreets" },
		codex = "dz_lore_outskirts",
		choices = {
			{
				label = "Join the night watch",
				clash = { stat = "strength", foe = "Something from the Outskirts", coins = 3, base = 7, coinPower = 4, fight = true, status = { id = "tremor", potency = 2 } },
				win = { strength = 3, wage = { 80, 200 }, log = "It came over the wall at two, and nine of you with lamps and hooks drove it back out. The District paid the watch in Ahn and noodles." },
				lose = { health = { -22, -10 }, log = "It came over the wall at two, and it hated you specifically.", cause = "Killed by something from the Outskirts" },
			},
			{ label = "Board up and stay in", result = { sanity = -5, money = -20, log = "You nailed boards over the windows. Something walked past twice that week, slowly, sniffing." } },
			{ label = "Chip in for Fixers", hint = "100 Ahn.", requires = { min = { money = 100 } }, result = { money = -100, sanity = -1, log = "The street hired a Zwei squad. The prints stopped at the wall." } },
		},
	},
	{
		id = "dz_x_outskirts_job",
		title = "A Job Past the Wall",
		text = "A Workshop Rep is offering 900 Ahn to anyone who'll go past the City wall into the Outskirts and bring back a crate from a crashed courier truck. She's paying a deposit up front. She doesn't expect to pay the rest.",
		weight = 2,
		once = true,
		when = { minAge = 18 },
		codex = "dz_lore_outskirts",
		choices = {
			{ label = "Take the job", result = { money = 100, setFlags = { "dz_outskirts_job" }, log = "She gave you a deposit, a hand-drawn map and a look you didn't like. The Outskirts run is yours whenever you're ready." } },
			{
				label = "Haggle for more",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A Rep who has heard it all", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { money = 200, setFlags = { "dz_outskirts_job" }, log = "You got the deposit doubled, and she seemed to respect it. The run is yours whenever you're ready." },
				lose = { sanity = -1, log = "She found someone cheaper. Nobody has seen him since." },
			},
			{ label = "Turn it down", result = { sanity = 1, log = "\"Sensible,\" she said, and meant it." } },
		},
	},
}
