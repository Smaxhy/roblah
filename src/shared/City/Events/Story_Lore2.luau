--[[
	STORYLINES: Borrowed Coat (sl_coat), The Voice (sl_voice), The Prescript (sl_prescript).
	Storylines/Lore.luau.

	BORROWED COAT. Every Fixer's license is on Hana's register, and every Office keeps a job
	board. Ages: 1 the coat · 5 the tag · 8 Hana's letter · 11 the Office · 13 someone who knew ·
	15 the client · 17 the endings. Flags: sl_bc_wrote, sl_bc_slip, sl_bc_truth, sl_bc_client.

	THE VOICE. Only for lives born after 964: the Light comes when they're a child. Since the
	White Nights, people pushed to the brink hear something kind offer them what they gave up.
	Ages: 4 the song · 6 the box · (the White Nights, whatever your age) three bright days ·
	14 someone in the kitchen · 15 number twelve · 16 THE BRINK · 17 the endings.
	Flags: sl_vo_asked, sl_vo_knows_how, then one of sl_vo_ego / sl_vo_lost / sl_vo_heard.

	THE PRESCRIPT. The Index carries out Prescripts: orders on slips of paper that nobody admits
	to writing. Messengers deliver them. Proxies see to the ones that are ignored.
	Ages: 3 the door · 6 the bread · 9 the Messenger · 12 the one who didn't · 14 the one that
	costs · 16 THE LAST SLIP · 18 the endings.
	Flags: sl_ps_obeyed / sl_ps_bent / sl_ps_tore, then one of sl_ps_joined / sl_ps_ran / sl_ps_blank.
]]

local BC = "sl_coat"
local VO = "sl_voice"
local PS = "sl_prescript"
local AFTER = { "library", "limbus" }

return {
	-- ════ BORROWED COAT ═══════════════════════════════════════════════════════
	{
		id = "sl_bc_coat",
		story = BC,
		title = "The Coat",
		art = "home",
		text = "The foundling house keeps whatever a child arrives with in a box with their name on it. In yours there's one thing: a long grey coat, far too big, with a brass tag sewn inside the collar.",
		always = true,
		once = true,
		when = { minAge = 1, maxAge = 1 },
		choices = {
			{ label = "Sleep under it", result = { sanity = 2, log = "It smelled of rain and something like metal. You slept under it every night until you were too big for the cot." } },
			{ label = "Chew the tag", result = { strength = 1, log = "The brass had letters stamped in it. You left tooth marks across two of them. They're still there." } },
			{ label = "Scream when anyone moves it", result = { health = 1, sanity = 1, log = "The matron tried to wash it once. Once." } },
		},
	},
	{
		id = "sl_bc_tag",
		story = BC,
		title = "Six Letters and a Number",
		art = "home",
		text = "You can read now, so you read the tag. LANTERN OFFICE. Under it, a number with a lot of digits. The matron says that's a Fixer's license number, and that an association called Hana keeps a list of all of them.",
		always = true,
		once = true,
		when = { minAge = 5, maxAge = 5 },
		dialogue = { { who = "sl_matron", line = "Somebody carried you to this door in that coat, and left the coat. Fixers don't leave their coats." } },
		choices = {
			{ label = "Ask her to write to Hana", result = { mind = 2, setFlags = { "sl_bc_wrote", "knows_fixers" }, goal = "Somebody left you in a Fixer's coat. Find out whose it was.", log = "She wrote the letter in her good handwriting, and let you lick the stamp. Hana takes its time." } },
			{ label = "Wear it everywhere", result = { sanity = 2, strength = 1, setFlags = { "knows_fixers" }, goal = "Somebody left you in a Fixer's coat. Find out whose it was.", log = "It dragged on the ground behind you like a cape. The other children called you the Office. You didn't mind." } },
			{ label = "Hide it where nobody can take it", result = { mind = 1, setFlags = { "knows_fixers" }, goal = "Somebody left you in a Fixer's coat. Find out whose it was.", log = "Behind the boiler, in a flour sack. You checked on it every day." } },
		},
	},
	{
		id = "sl_bc_reply",
		story = BC,
		title = "A Letter from Hana",
		art = "office",
		text = "Three years, and Hana has answered. One line, typed. LICENSE STATUS: INACTIVE. OFFICE: DISSOLVED. FURTHER DETAILS ARE AVAILABLE TO CLIENTS. At the bottom somebody has added, in pencil, an address.",
		always = true,
		once = true,
		when = { minAge = 8, maxAge = 8 },
		choices = {
			{ label = "Go to the address", result = { health = 1, mind = 1, setFlags = { "sl_bc_address" }, goal = "The Lantern Office is boarded up. It's still there.", log = "Two rooms over a noodle stall, boards on the windows. The stall owner remembered: \"The tall one. Always paid. Never came back for her bowl.\"" } },
			{ label = "Start saving to be a client", result = { intelligence = 2, money = 5, goal = "Hana tells clients more. Clients pay.", log = "You put a coin in a jar. Hana's fee is three hundred. You were eight. You did the sum anyway." } },
			{ label = "Keep the pencil line and throw the rest away", result = { sanity = 1, strength = 1, setFlags = { "sl_bc_address" }, goal = "The Lantern Office is boarded up. It's still there.", log = "Somebody at Hana broke a rule for you with a pencil. You kept that part." } },
		},
	},
	{
		id = "sl_bc_office",
		story = BC,
		title = "Lantern Office",
		art = "office",
		text = "You're old enough to get a board off a window. Inside: two desks, a dead lamp, and a job board with one slip still pinned to it. ESCORT. ONE INFANT. TO THE FOUNDLING HOUSE, BEFORE THE NIGHT. PAID IN ADVANCE.",
		always = true,
		once = true,
		when = { minAge = 11, maxAge = 11 },
		choices = {
			{ label = "Take the slip", result = { sanity = -2, mind = 2, setFlags = { "sl_bc_slip" }, goal = "The last job on the board was you.", log = "You unpinned it and folded it into the coat's inside pocket. There was already a pin-shaped hole in the lining, exactly there." } },
			{ label = "Leave it pinned. Light the lamp", result = { sanity = 3, goal = "The last job on the board was you.", log = "You found oil in the desk and lit the lamp in the window. It burned all evening. People on the street looked up." } },
			{ label = "Read the rest of the board", result = { intelligence = 1, mind = 1, setFlags = { "sl_bc_slip" }, goal = "The last job on the board was you.", log = "Eleven jobs, all marked DONE in the same square handwriting. The twelfth isn't marked. It was done. You're the proof." } },
		},
	},
	{
		id = "sl_bc_hale",
		story = BC,
		title = "Someone Who Knew",
		art = "home",
		text = "A Grade 3 Fixer comes to the foundling house on other business. He's halfway through his tea when he sees the coat on its hook. He puts the cup down very carefully.",
		always = true,
		once = true,
		when = { minAge = 13, maxAge = 13 },
		dialogue = {
			{ who = "sl_hale", line = "Where did you get that." },
			{ who = "sl_hale", line = "She finished the job. Whatever else you hear, that's the part that's true. She finished it." },
		},
		choices = {
			{
				label = "Make him tell you the rest",
				clash = { stat = "strength", foe = "A Grade 3's silence", coins = 1, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = -3, setFlags = { "sl_bc_truth" }, goal = "She got you to the door at ten past three. Find out who paid her to.", log = "Her name was Marta Venn. She reached this door with you at ten past three, knocked, and turned back for the Office. It's a twenty-minute walk. The Night starts at 3:13." },
				lose = { sanity = -1, goal = "The Fixer knows what happened. He won't say it yet.", log = "He finished his tea and left a card. \"When you're older,\" he said. Everyone always says that." },
			},
			{ label = "Ask only her name", result = { sanity = 2, setFlags = { "sl_bc_name" }, goal = "Her name was Marta Venn. Find out who paid her.", log = "\"Marta Venn. Grade 6. Lantern Office was just her.\" He said it like a man reading a headstone." } },
			{ label = "Pour him more tea", result = { intelligence = 1, relationBond = { kind = "all", amount = 2 }, goal = "The Fixer knows what happened. He won't say it yet.", log = "You poured. His hand wasn't steady. He comes by every few months now, and never says why." } },
		},
	},
	{
		id = "sl_bc_client",
		story = BC,
		title = "Paid in Advance",
		art = "checkpoint",
		text = "The slip said PAID IN ADVANCE. Somebody hired a Fixer to carry you across the District before a Night. Hale has traced the payment as far as he can: it came out through a Nest checkpoint, in an envelope with no name.",
		always = true,
		once = true,
		when = { minAge = 15, maxAge = 15 },
		choices = {
			{
				label = "Follow it to the checkpoint",
				clash = { stat = "mind", foe = "A guard's memory", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = -2, setFlags = { "sl_bc_client" }, goal = "Somebody inside the walls paid to get you out. You know which gate.", log = "An old guard remembered: a young woman in a Wing uniform, shaking, with an envelope and a bundle. Feathers aren't allowed that kind of bundle. She went back in alone." },
				lose = { sanity = -1, goal = "The trail stops at the wall.", log = "The guard has been on that gate two years. The one before him retired. The wall keeps what it knows." },
			},
			{ label = "Let it stop at the wall", result = { sanity = 3, goal = "Whoever paid, paid. You're here.", log = "Somebody wanted you out and alive badly enough to pay a Fixer in advance. You decided that was all you needed from them." } },
		},
	},
	{
		id = "sl_bc_end",
		story = BC,
		title = "It Fits",
		art = "office",
		text = "You're seventeen, and the coat fits. Hale says Hana's licensing exam is open to anyone with a Fixer to sign for them, and that he'll sign. The lamp in the Lantern Office window has been dark for seventeen years.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17 },
		dialogue = { { who = "sl_hale", line = "Grade 9 is the bottom of everything. She started there too. Your choice." } },
		choices = {
			{
				label = "Sit Hana's exam in her coat",
				clash = { stat = "strength", foe = "Hana's licensing exam", coins = 2, base = 4, coinPower = 3 },
				win = { career = "fixer", sanity = 5, storyEnd = "Lantern Office, Reopened: there's a light in the window again", log = "Grade 9 Fixer. You pried the boards off, lit the lamp, and pinned a new slip on the board under hers. The twelfth one says DONE now, in your handwriting." },
				lose = { strength = 2, sanity = -2, storyEnd = "Next Year: you failed Hana's exam in a dead Fixer's coat, and signed up again", log = "You failed the practical. Hale said she'd failed it twice. You put your name down for the next sitting before you'd left the hall." },
			},
			{ label = "Stay and keep the foundling house door", result = { sanity = 5, intelligence = 2, relationBond = { kind = "all", amount = 8 }, storyEnd = "The Door She Reached: you answer it now", log = "Matron Oke is getting old, and the door still gets knocked on before the Night. You answer it. You hang every coat on a hook, in case." } },
			{ label = "Knock on the Nest gate and ask for her", requires = { flags = { "sl_bc_client" } }, result = { sanity = -2, strength = 3, storyEnd = "The Gate: you asked the wall for your mother by her uniform", log = "You stood at the checkpoint in a Fixer's coat and described a Feather seventeen years gone. They took your name. Three weeks later a letter came out through the gate with no name on it. You haven't opened it yet." } },
		},
	},

	-- ════ THE VOICE ═══════════════════════════════════════════════════════════
	{
		id = "sl_vo_song",
		story = VO,
		title = "The Line She Stops At",
		art = "home",
		text = "Your mother sings while she works. It's always the same song, and she always stops at the same line, in the middle, as if she's walked into a wall. Then she goes on with the dishes.",
		always = true,
		once = true,
		when = { minAge = 4, maxAge = 4 },
		choices = {
			{ label = "Sing the next line for her", result = { sanity = 1, relationBond = { kind = "family", amount = 6 }, setFlags = { "sl_vo_sang" }, log = "You made up the next line. It was about a dog. She laughed until she had to sit down, and then she was quiet for a while." } },
			{ label = "Ask why she stops", result = { mind = 1, log = "\"That's where I stopped wanting things,\" she said, and tapped your nose. \"Then I got you instead.\"" } },
			{ label = "Hum along", result = { intelligence = 1, sanity = 1, log = "You hummed. You know it to that line too, now. Neither of you knows the rest." } },
		},
	},
	{
		id = "sl_vo_box",
		story = VO,
		title = "The Box Under the Bed",
		art = "home",
		text = "There's a flat wooden box under your mother's bed. Inside: brushes, hard with old paint, and a folded letter with a seal you don't know. ADMISSION, it says at the top. The date is the year before you were born.",
		always = true,
		once = true,
		when = { minAge = 6, maxAge = 6 },
		choices = {
			{ label = "Ask her to paint something", result = { relationBond = { kind = "family", amount = 6 }, setFlags = { "sl_vo_asked" }, goal = "Your mother gave something up before you were born. She keeps it in a box.", log = "She painted a cat on the back of a rent notice. It took her four minutes and it was the best thing you'd ever seen. She put the box back." } },
			{ label = "Put it back exactly as it was", result = { mind = 2, goal = "Your mother gave something up before you were born. She keeps it in a box.", log = "You put it back to the inch. She knew anyway. She said nothing, and bought you a pencil that week." } },
			{ label = "Keep one brush", result = { strength = 1, sanity = 1, setFlags = { "sl_vo_brush" }, goal = "Your mother gave something up before you were born. She keeps it in a box.", log = "The smallest one. It's been in your pocket ever since. She's never asked for it back." } },
		},
	},
	{
		id = "sl_vo_light",
		story = VO,
		title = "Three Bright Days",
		art = "rooftop",
		text = "A light has come out of District 12 and covered the City. For three days nobody on your street is afraid of anything. Your mother carries the box up to the roof, opens it, and paints the whole stairwell wall while the neighbors watch.",
		always = true,
		once = true,
		when = { world = { era = "white_nights" } },
		choices = {
			{ label = "Hold the paint for her", result = { sanity = 6, relationBond = { kind = "family", amount = 10 }, setFlags = { "saw_white_nights", "sl_vo_held" }, goal = "Something came back with the Light. Not all of it left.", log = "She painted the street as it would look if nobody was tired. Then the dark days came, and she put the lid on the box, and she was calm about it. Too calm." } },
			{ label = "Run out into the light", result = { sanity = 8, setFlags = { "saw_white_nights" }, goal = "Something came back with the Light. Not all of it left.", log = "You ran the length of the District and nobody told you to come in. When the dark days came you found her on the stairs, smiling at the wall she'd painted." } },
			{ label = "Stay behind the shutters", result = { mind = 2, setFlags = { "saw_white_nights" }, goal = "Something came back with the Light. Not all of it left.", log = "You watched it through the slats. Through the floor you could hear your mother laughing on the roof, the way she must have laughed before you." } },
		},
	},
	{
		id = "sl_vo_kitchen",
		story = VO,
		title = "Someone in the Kitchen",
		art = "home",
		text = "Your mother is talking to someone in the kitchen. Her voice is easy, the way it almost never is. You look round the door. There's nobody there. Only her, and the box, open on the table.",
		always = true,
		once = true,
		when = { minAge = 14, maxAge = 14, world = { era = AFTER } },
		choices = {
			{ label = "Listen from the stairs", result = { mind = 2, sanity = -3, setFlags = { "knows_distortions" }, log = "You only heard her half of it. \"Yes. I'd like that. All of it? ...No more of this, then?\" She sounded like someone being offered a chair." } },
			{ label = "Walk in", result = { strength = 2, sanity = -2, setFlags = { "knows_distortions" }, relationBond = { kind = "family", amount = 4 }, log = "She stopped mid-word and smiled at you. \"Just thinking out loud.\" The kitchen was cold, the way a room is when someone has just left it." } },
			{ label = "Ask her who it is", result = { sanity = -2, mind = 1, setFlags = { "knows_distortions" }, log = "\"Someone kind,\" she said. \"She says I don't have to be tired any more.\" She said it the way you'd tell someone the time." } },
		},
	},
	{
		id = "sl_vo_twelve",
		story = VO,
		title = "Number Twelve",
		art = "street",
		text = "The man at number twelve lost his shop in the spring. This morning the stairwell is roped off, and there are Fixers on every landing. Whatever is in number twelve now, it isn't the man who lost his shop. One of the Fixers talks to the street.",
		always = true,
		once = true,
		when = { minAge = 15, maxAge = 15, world = { era = AFTER } },
		dialogue = {
			{ who = "sl_cordon_fixer", line = "They call it Distortion. It's people. People who went over an edge." },
			{ who = "sl_cordon_fixer", line = "They get calm first. They tell you someone finally understands them. If you see that, you come and find us." },
		},
		choices = {
			{ label = "Ask how you bring someone back", result = { mind = 2, setFlags = { "sl_vo_knows_how" }, goal = "She's calm. She says someone understands her. You know what that means now.", log = "\"Sometimes they hold on to somebody,\" the Fixer said. \"A face. A voice they know. That's all I've got, kid. It's not much.\"" } },
			{ label = "Tell her about your mother", result = { sanity = -4, setFlags = { "sl_vo_reported" }, goal = "She's calm. She says someone understands her. You know what that means now.", log = "She wrote your door number down. \"We'll watch it,\" she said. \"That's all we can do before. I'm sorry.\"" } },
			{ label = "Go home and say nothing", result = { sanity = -3, goal = "She's calm. She says someone understands her. You know what that means now.", log = "You went home. Your mother had made too much soup, and was humming, all the way through, past the line where she stops." } },
		},
	},
	{
		id = "sl_vo_brink",
		story = VO,
		title = "The Brink",
		art = "home",
		text = "Your mother is at the window with the box of old brushes open in her lap. The room is cold. She's nodding at something you can almost hear: a woman's voice, gentle, telling her she's carried enough. Her hands have started to look wrong, as if the light goes through them.",
		always = true,
		once = true,
		when = { minAge = 16, maxAge = 16, world = { era = AFTER } },
		choices = {
			{
				label = "Take her hands and sing the next line",
				clash = { stat = "mind", foe = "A kind voice", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = 6, relationBond = { kind = "family", amount = 20 }, setFlags = { "sl_vo_ego" }, goal = "She came back. Something came back with her.", log = "You sang the dog line. She looked at you, really at you, and the cold went out of the room. What she was holding when it was over was a brush, and it was made of light." },
				lose = { sanity = -12, killRelation = "mother", condition = "grief", setFlags = { "sl_vo_lost" }, goal = "She's gone. The Fixers have closed the stairwell.", log = "You sang it. She smiled at you, and thanked you for it, and went. The Fixers got you down the stairs. They didn't let you look back." },
			},
			{
				label = "Sing it the way she taught you to hold on",
				requires = { flags = { "sl_vo_knows_how" } },
				clash = { stat = "mind", foe = "A kind voice", coins = 3, base = 3, coinPower = 3 },
				win = { sanity = 6, relationBond = { kind = "family", amount = 20 }, setFlags = { "sl_vo_ego" }, goal = "She came back. Something came back with her.", log = "A face. A voice they know. You gave her both, and kept giving them until the room was warm. What she was holding when it was over was a brush, and it was made of light." },
				lose = { sanity = -12, killRelation = "mother", condition = "grief", setFlags = { "sl_vo_lost" }, goal = "She's gone. The Fixers have closed the stairwell.", log = "You did everything the Fixer said. She smiled at you, and thanked you for it, and went. The Fixers got you down the stairs. They didn't let you look back." },
			},
			{ label = "Run for the Fixers", result = { sanity = -8, killRelation = "mother", condition = "grief", setFlags = { "sl_vo_lost" }, goal = "She's gone. The Fixers have closed the stairwell.", log = "You were back with them in four minutes. They went up. You were kept on the pavement. One of them came down later and sat beside you and didn't say anything." } },
			{
				label = "Answer the voice yourself",
				clash = { stat = "strength", foe = "A kind voice", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -4, strength = 3, relationBond = { kind = "family", amount = 12 }, setFlags = { "sl_vo_heard" }, goal = "It left her alone. It knows your name now.", log = "\"She's not yours,\" you said to the empty room. It laughed, kindly, and said your name. Your mother blinked and asked why the window was open. It hasn't spoken to her since." },
				lose = { sanity = -12, killRelation = "mother", condition = "grief", setFlags = { "sl_vo_lost" }, goal = "She's gone. The Fixers have closed the stairwell.", log = "You shouted at nothing. Your mother patted your hand and told you it was all right, and went. The Fixers got you down the stairs." },
			},
		},
	},
	{
		id = "sl_vo_end_ego",
		story = VO,
		title = "What She Makes Now",
		art = "rooftop",
		text = "Your mother paints again. What she paints with doesn't need paint. People have started to come up the stairs to look, and yesterday one of them was from an Office, with a notebook.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17, flags = { "sl_vo_ego" } },
		choices = {
			{ label = "Stand at the top of the stairs", result = { strength = 3, sanity = 4, storyEnd = "Finished: your mother came back from the brink, and you were why", log = "Nobody gets past you with a notebook. She's painting the whole roof, a little each evening. She sings it all the way through." } },
			{ label = "Ask her to teach you", result = { intelligence = 3, sanity = 5, relationBond = { kind = "family", amount = 10 }, storyEnd = "Two Brushes: she's teaching you everything she gave up", log = "You started with the small brush you'd carried, if you'd kept it, or with a new one if not. She says you have her hands." } },
		},
	},
	{
		id = "sl_vo_end_lost",
		story = VO,
		title = "The Stairwell",
		art = "street",
		text = "The Fixers are done with your stairwell. One of them has left a card on the box, which they carried down for you. The wall your mother painted in the three bright days is still there. Nobody has had the heart to wash it.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17, flags = { "sl_vo_lost" } },
		choices = {
			{ label = "Take the card", result = { strength = 3, sanity = -2, setFlags = { "knows_fixers" }, storyEnd = "The Card: you went to work for the people who come afterward", log = "The Office takes Distortion work, and it needs people who can tell when someone's gone calm. You can tell. You knock on doors before it's too late, when you can." } },
			{ label = "Keep the box", result = { sanity = 4, intelligence = 2, storyEnd = "The Box: you kept what she gave up, and carried it", log = "You opened it. On top was a rent notice with a cat painted on the back. You've started using the brushes. You're not good yet." } },
			{ label = "Paint over the stopped line", result = { sanity = 5, mind = 2, storyEnd = "The Next Line: you finished the song on the stairwell wall", log = "You wrote the rest of the song on the wall under her painting. You had to make it up. It's about a dog." } },
		},
	},
	{
		id = "sl_vo_end_heard",
		story = VO,
		title = "It Knows Your Name",
		art = "night",
		text = "It talks to you now, on bad nights. It's never unkind. It reminds you what you gave up to stand in that kitchen, and how tired you are, and it offers to take all of it. Your mother is asleep in the next room, humming.",
		always = true,
		once = true,
		when = { minAge = 17, maxAge = 17, flags = { "sl_vo_heard" } },
		choices = {
			{ label = "\"No. Ask me next year.\"", result = { mind = 3, sanity = 3, storyEnd = "Unpersuaded: the voice asks you every year, and you keep saying no", log = "It took that well. It always does. You've made a habit of it: every year, on the same night, the same answer." } },
			{ label = "Tell your mother everything", result = { sanity = 6, relationBond = { kind = "family", amount = 15 }, storyEnd = "Out Loud: you and your mother say its offers to each other, so neither of you has to listen alone", log = "She held your face in both hands. \"Then we tell each other,\" she said. \"Every time. Out loud.\" It's much quieter when you say it out loud." } },
		},
	},

	-- ════ THE PRESCRIPT ═══════════════════════════════════════════════════════
	{
		id = "sl_ps_door",
		story = PS,
		title = "A Slip Under the Door",
		art = "home",
		text = "A folded slip of paper comes under your door in the morning. It's addressed to the household. PAINT THIS DOOR WHITE BEFORE THE NIGHT. Nobody asks who sent it. Somebody goes out to find white paint.",
		always = true,
		once = true,
		when = { minAge = 3, maxAge = 3 },
		choices = {
			{ label = "Put your hand in the wet paint", result = { strength = 1, setFlags = { "sl_ps_hand", "knows_syndicates" }, log = "One small white handprint, low on a white door. Nobody noticed until it had dried. It's still there." } },
			{ label = "Hold the tin", result = { intelligence = 1, setFlags = { "knows_syndicates" }, log = "You held the tin with both arms. By three the door was white. Nothing happened in the Night. That was the point." } },
			{ label = "Ask who it's from", result = { mind = 1, setFlags = { "knows_syndicates" }, log = "\"Nobody knows who writes them,\" you were told. \"There are people who see they're done. We don't want to meet those people.\"" } },
		},
	},
	{
		id = "sl_ps_bread",
		story = PS,
		title = "To the Child of the House",
		art = "home",
		text = "This one has your name on it, in ink. It's the first thing you've ever been sent. GIVE YOUR BREAD TO THE FIRST PERSON YOU MEET ON THE STAIRS. You have your bread in your hand. You were about to eat it.",
		always = true,
		once = true,
		when = { minAge = 6, maxAge = 6 },
		choices = {
			{ label = "Give all of it", result = { intelligence = 2, sanity = -1, setFlags = { "sl_ps_obeyed" }, goal = "Slips of paper tell your family what to do. So far they've been small.", log = "The first person on the stairs was the landlord, who is fat. You gave him your bread. He looked at the slip in your other hand, and took it very seriously." } },
			{ label = "Give half", result = { mind = 2, setFlags = { "sl_ps_bent" }, goal = "Slips of paper tell your family what to do. So far they've been small.", log = "It said bread. It didn't say all. You gave half and waited all day for something to happen. Nothing did. You remember that." } },
			{ label = "Eat it first", result = { strength = 2, health = 1, setFlags = { "sl_ps_tore" }, goal = "Slips of paper tell your family what to do. So far they've been small.", log = "You ate it on the top step. That week the family got a second slip, which you weren't shown, and you weren't allowed bread for a month." } },
		},
	},
	{
		id = "sl_ps_messenger",
		story = PS,
		title = "The Messenger",
		art = "street",
		text = "No slip today. A person in white is standing in your doorway instead, with a long sword in a white sheath, reading from a paper. THE HOUSEHOLD WILL NOT SPEAK ON THE SEVENTH DAY OF EACH MONTH. Then the Messenger waits.",
		always = true,
		once = true,
		when = { minAge = 9, maxAge = 9 },
		dialogue = {
			{ who = "sl_messenger", line = "Is it understood?" },
			{ who = "sl_messenger", line = "If it isn't done, a Proxy comes in my place. I only read. Proxies don't read." },
		},
		choices = {
			{ label = "Nod", result = { intelligence = 2, setFlags = { "knows_index" }, log = "Everyone nodded. The Messenger folded the paper in three and left it on the mat. The seventh was a very long day." } },
			{ label = "Ask who writes them", result = { mind = 2, sanity = -1, setFlags = { "knows_index" }, log = "\"I don't know,\" the Messenger said, quite pleasantly. \"Nobody in the Index does. That's why we can trust them.\"" } },
			{ label = "Look at the sword", result = { strength = 1, sanity = -1, setFlags = { "knows_index" }, log = "The Messenger saw you looking. \"It isn't for you,\" they said. \"Not today. Today I only read.\"" } },
		},
	},
	{
		id = "sl_ps_neighbor",
		story = PS,
		title = "The One Who Didn't",
		art = "alley",
		text = "The man across the landing got a slip last week and laughed at it. This morning his door is painted white, top to bottom, and nobody answers it. Your family's slip today says: TAKE IN WHAT THE NEIGHBOR LEFT. What he left is a caged bird, on his step.",
		always = true,
		once = true,
		when = { minAge = 12, maxAge = 12 },
		choices = {
			{ label = "Take the bird in", result = { sanity = -2, intelligence = 1, relationBond = { kind = "family", amount = 3 }, log = "It sings at night, on the seventh, when nobody else is allowed to. It doesn't know. You've never taught it better." } },
			{ label = "Knock on the white door", result = { strength = 2, sanity = -3, log = "You knocked. It swung open. The room was empty and clean, with every drawer shut, as if someone had been tidied away." } },
			{ label = "Ask what his slip said", result = { mind = 2, sanity = -1, log = "Nobody knew. It doesn't matter what it said, you were told. It matters that he laughed." } },
		},
	},
	{
		id = "sl_ps_cost",
		story = PS,
		title = "The One That Costs",
		art = "home",
		text = "It's addressed to you again. GIVE AWAY THE THING YOU WOULD LEAST LIKE TO. No more than that. It doesn't say what the thing is. It doesn't need to. You know exactly what it is, and so does the paper.",
		always = true,
		once = true,
		when = { minAge = 14, maxAge = 14 },
		choices = {
			{ label = "Give it away", result = { intelligence = 3, sanity = -5, setFlags = { "sl_ps_obeyed" }, goal = "The slips are getting heavier. The next one could ask for anything.", log = "You gave it to a child on the stairs, who didn't know what it was worth. You've never told anyone what it was. The paper knows." } },
			{
				label = "Give away something else, and lie",
				clash = { stat = "mind", foe = "Whoever reads the answers", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 3, setFlags = { "sl_ps_bent" }, goal = "The slips are getting heavier. The next one could ask for anything.", log = "You gave away your second-best thing with a very sad face. No slip came after. Either they can't tell, or they can, and they're keeping count." },
				lose = { sanity = -6, goal = "A Proxy has stood in your doorway once. There won't be a second warning.", log = "A Proxy stood in your doorway that evening for one full minute, said nothing, and left. The thing you'd kept was gone from under your bed in the morning." },
			},
			{ label = "Tear it up", result = { strength = 4, sanity = 2, setFlags = { "sl_ps_tore" }, goal = "You tore up a Prescript. Everyone on the landing saw the pieces.", log = "You tore it in four and dropped it down the stairwell. Your family didn't speak to you until the seventh, and then they weren't allowed to." } },
		},
	},
	{
		id = "sl_ps_last",
		story = PS,
		title = "The Last Slip",
		art = "night",
		text = "The Messenger is back, and for the first time hands the slip to you in person. It's short. COME TO THE INDEX. BRING NOTHING. \"It's rare,\" the Messenger says. \"It means the paper has noticed you. You have until the Night.\"",
		always = true,
		once = true,
		when = { minAge = 16, maxAge = 16 },
		dialogue = { { who = "sl_messenger", line = "I got one like it at your age. I don't remember what I wanted before. I'm told that's a mercy." } },
		choices = {
			{ label = "Go, and bring nothing", result = { intelligence = 3, sanity = -4, setFlags = { "sl_ps_joined" }, goal = "You went to the Index. At eighteen you take the white.", log = "You left your door open behind you and walked out with empty hands. A Proselyte doesn't own things. It's restful, they tell you, once you stop reaching for your pockets." } },
			{
				label = "Leave the District before the Night",
				clash = { stat = "mind", foe = "The Night, and the paper", coins = 2, base = 3, coinPower = 3 },
				win = { mind = 3, health = 1, setFlags = { "sl_ps_ran" }, goal = "You're somewhere the slips haven't found. Yet.", log = "You were across the District line by two. No slip came the next morning, for the first morning in thirteen years. You didn't know what to do with your hands." },
				lose = { sanity = -5, setFlags = { "sl_ps_joined" }, goal = "You ran, and the paper was there first. At eighteen you take the white.", log = "There was a slip waiting on the tram seat with your name on it. WRONG WAY. You got off at the next stop and walked to the Index with nothing." },
			},
			{ label = "Hand it back, unread past the first line", result = { strength = 3, sanity = 1, setFlags = { "sl_ps_blank" }, goal = "You gave a Prescript back. Nobody knows what happens now.", log = "The Messenger looked at the slip in their hand for a long time. \"That isn't one of the things people do,\" they said, and took it away, holding it as if it were hot." } },
		},
	},
	{
		id = "sl_ps_end_joined",
		story = PS,
		title = "The White",
		art = "hall",
		text = "A hall of people in white, and a table with one folded slip on it for each of them. Yours is the last. A Proxy holds out the white coat. Once it's on, the Proxy says, you'll never have to decide anything again.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_ps_joined" } },
		choices = {
			{ label = "Put it on", result = { career = "index", sanity = 4, storyEnd = "Proselyte: you stopped asking who writes them", log = "It's very quiet in your head now. You carry slips to doors. Sometimes a child asks who they're from, and you tell them the truth: you don't know." } },
			{ label = "Put it on, and keep one question", result = { career = "index", mind = 4, sanity = -2, storyEnd = "The Question: you serve the Index, and you're still looking for the hand that writes", log = "You do everything the paper says. And in the evenings you compare handwriting. Eleven years of slips. You think there are three writers. You've told no one." } },
		},
	},
	{
		id = "sl_ps_end_ran",
		story = PS,
		title = "Unaddressed",
		art = "train",
		text = "Two years in a District where nothing comes under the door. You have a room, a job, and a habit of checking the mat every morning. This morning there's a slip on it. It's blank on both sides.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_ps_ran" } },
		choices = {
			{ label = "Burn it", result = { strength = 3, sanity = 3, storyEnd = "Unaddressed: you live where the slips can't find you, so far", log = "It burned like ordinary paper. You moved rooms that week anyway. You're good at moving now." } },
			{ label = "Write on it yourself", result = { mind = 3, sanity = 5, storyEnd = "The Blank One: the last slip was empty, and you wrote your own", log = "You wrote STAY in your own hand, and pinned it over your door. It's the only Prescript you've ever agreed with." } },
		},
	},
	{
		id = "sl_ps_end_blank",
		story = PS,
		title = "No Slip",
		art = "home",
		text = "It's been two years since you handed a Prescript back. No Proxy came. No slip has come for you since, not one, though the rest of your family still gets theirs. On your landing they've started calling you the one the paper skips.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_ps_blank" } },
		choices = {
			{ label = "Do your family's slips for them", result = { intelligence = 3, sanity = 2, relationBond = { kind = "family", amount = 12 }, storyEnd = "The One the Paper Skips: you carry out your family's Prescripts so they don't have to", log = "It never said who had to do them. You paint the doors and give away the bread and keep the silences. Nobody has come to say you can't." } },
			{ label = "Ask the Messenger why", result = { mind = 4, sanity = -2, storyEnd = "Returned: a Prescript you gave back is still out there, unanswered", log = "\"It's still open,\" the Messenger said. \"The one you returned. Nobody's been told what to do about it. I think you may be the first thing the paper hasn't decided.\"" } },
		},
	},
}
