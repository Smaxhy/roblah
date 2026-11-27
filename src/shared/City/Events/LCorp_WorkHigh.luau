--[[
	L Corp work orders, WAW and ALEPH: veterans' work. WAW from rank 5 (Agent, Level 4),
	ALEPH from rank 6 (Agent, Level 5). Same shape as Events/LCorp_Work.luau: the four
	work types, the canon best work goes best, the rest are hard checks or worse.
	Also the Express Train to Hell, which isn't worked with but used.
]]

local INSTINCT = "Instinct trains Health"
local INSIGHT = "Insight trains Mental Strength"
local ATTACHMENT = "Attachment trains Intelligence"
local REPRESSION = "Repression trains Strength"

local WAW = { career = "lcorp_agent", minRank = 5, world = { era = "wings" } }
local ALEPH = { career = "lcorp_agent", minRank = 6, world = { era = "wings" } }

return {
	-- ── WAW ──
	{
		id = "lc_work_big_bird",
		title = "Work Order: Big Bird",
		text = "O-02-40 is a WAW. The unit has been made to look like a forest at night, and in the middle of it stands an enormous dark bird covered in eyes, holding a lantern in its beak. It's watching the trees for a beast. It looks at you, decides you're not the beast, and goes back to watching.",
		weight = 28,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = WAW,
		choices = {
			{
				label = "Instinct: groom its feathers",
				hint = INSTINCT,
				result = { health = { 2, 3 }, paycheck = 0.2, setFlags = { "lc_pe_big_bird" }, codex = "lc_abno_big_bird", schedule = { event = "lc_ego_offer_lamp", inYears = 1 }, log = "You groomed its dark feathers while it kept watch over your shoulder. It stood very still for you. The PE-Boxes came out green as forest light." },
			},
			{
				label = "Insight: clear the forest floor",
				hint = INSIGHT .. ". A Mental Strength check; don't look at the lantern.",
				clash = { stat = "mind", foe = "The lantern at the edge of your eye", coins = 2, base = 5, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_big_bird", log = "You raked the fake leaves with your eyes on your shoes the whole time. It approved, you think. The counter held." },
				lose = { sanity = { -6, -4 }, health = { -5, -3 }, codex = "lc_abno_big_bird", log = "You looked at the lantern. Just for a moment. You came to standing in front of its beak with no idea how you'd crossed the room." },
			},
			{
				label = "Attachment: promise to help it guard the forest",
				hint = ATTACHMENT,
				result = { charisma = { 2, 3 }, sanity = 2, paycheck = 0.2, setFlags = { "lc_pe_big_bird" }, codex = "lc_abno_big_bird", schedule = { event = "lc_ego_offer_lamp", inYears = 1 }, log = "You told it you'd watch for the beast too. Several of its eyes softened. You stood watch together in silence, and the PE-Boxes stacked up." },
			},
			{
				label = "Repression: drive it into a corner",
				hint = REPRESSION,
				result = {
					strength = 1,
					health = { -7, -4 },
					codex = "lc_abno_big_bird",
					chronicle = "lc_caused_breach",
					trigger = "lc_breach_big_bird",
					log = "You drove it back with the riot stick. It decided, slowly, that you might be the beast after all. Then it decided the beast might be out there, in the corridors, and it went to look.",
				},
			},
		},
	},
	{
		id = "lc_work_judgement_bird",
		title = "Work Order: Judgement Bird",
		text = "O-02-62 is a WAW: a long-necked bird with a bandage over its eyes, holding a pair of scales. As you step in, the scales tilt. They always tilt the same way. The file says that even the best work with it goes badly more often than not, and that one kind of work is worse than all the others.",
		weight = 26,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = WAW,
		choices = {
			{
				label = "Instinct: clean its feathers and scales",
				hint = INSTINCT .. ". A hard Health check.",
				clash = { stat = "health", foe = "The weight of the scales", coins = 2, base = 6, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_judgement_bird", log = "You cleaned the scales without touching the pans. The bird let you. You'll never know what it decided about you." },
				lose = { health = { -9, -5 }, sanity = -3, codex = "lc_abno_judgement_bird", log = "Your sleeve brushed one pan of the scales. The bird turned its bandaged face toward you and something very heavy pressed on your chest until you got out." },
			},
			{
				label = "Insight: tidy the unit, quickly, silently",
				hint = INSIGHT .. ". The safest work, and still a Mental Strength check.",
				clash = { stat = "mind", foe = "Judgement Bird's verdict", coins = 2, base = 4, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.22, setFlags = { "lc_pe_judgement" }, codex = "lc_abno_judgement_bird", schedule = { event = "lc_ego_offer_justitia", inYears = 1 }, log = "You worked fast and neat and said nothing at all, and when you finished the scales were very nearly level. The Extraction Team was impressed. So, you think, was the bird." },
				lose = { health = { -6, -3 }, sanity = -3, codex = "lc_abno_judgement_bird", log = "You knocked a mop handle against the wall. One small sound. The scales tipped hard, and you got out with your ears ringing." },
			},
			{
				label = "Attachment: say something kind to it",
				hint = ATTACHMENT .. ". A hard Charisma check.",
				clash = { stat = "charisma", foe = "A judge who has heard it all", coins = 2, base = 6, coinPower = 3 },
				win = { charisma = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_judgement_bird", log = "You told it you hoped it found someone innocent one day. Its head tilted. The counter went up, for once." },
				lose = { sanity = { -6, -4 }, codex = "lc_abno_judgement_bird", log = "It weighed your kindness and found it wanting. You don't know how you know that. You just do." },
			},
			{
				label = "Repression: take its scales away",
				hint = REPRESSION,
				result = { strength = 1, health = { -15, -8 }, sanity = { -6, -4 }, codex = "lc_abno_judgement_bird", log = "You reached for the scales. You don't remember the verdict, only the sentence. The Welfare Team spent a long time on you.", cause = "Judged by Judgement Bird" },
			},
		},
	},
	{
		id = "lc_work_queen_hatred",
		title = "Work Order: The Queen of Hatred",
		text = "O-01-04 is a WAW: a magical girl in a bright pink and white costume, striking a heroic pose in the middle of an empty unit. \"Have you come to report a villain?\" she asks eagerly. \"Anything? Anything at all?\" She looks like she hasn't saved anyone in a very long time, and it's eating at her.",
		weight = 26,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = WAW,
		choices = {
			{
				label = "Instinct: bring her a meal and tidy her costume",
				hint = INSTINCT .. ". A Health check.",
				clash = { stat = "health", foe = "A restless hero", coins = 2, base = 5, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_queen_hatred", log = "She ate standing up, ready to leap into action at any second. You mended her cape. She thanked you very formally, as one hero to another." },
				lose = { health = { -6, -3 }, sanity = -2, codex = "lc_abno_queen_hatred", log = "She jumped up at a noise in the corridor and knocked you flat. \"Sorry! I thought it was a villain!\"" },
			},
			{
				label = "Insight: straighten the unit and check her readings",
				hint = INSIGHT .. ". A Mental Strength check.",
				clash = { stat = "mind", foe = "Unstable magic", coins = 2, base = 5, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_queen_hatred", log = "Her readings were spiky but steady. You logged them while she told you about the villains she'd defeat one day." },
				lose = { health = { -5, -3 }, sanity = -3, codex = "lc_abno_queen_hatred", log = "A spark of her magic arced off the readings panel and into your hand. She was very apologetic." },
			},
			{
				label = "Attachment: tell her about her heroics",
				hint = ATTACHMENT .. ". Remind her who she is.",
				result = { charisma = { 2, 3 }, sanity = 2, paycheck = 0.2, codex = "lc_abno_queen_hatred", log = "You told her the City still talked about her. Every word was invented and she knew it and she glowed anyway. The PE-Boxes came out sparkling." },
			},
			{
				label = "Repression: tell her heroes aren't real",
				hint = REPRESSION,
				result = {
					strength = 1,
					sanity = -4,
					codex = "lc_abno_queen_hatred",
					chronicle = "lc_caused_breach",
					trigger = "lc_breach_queen",
					log = "Her face fell. Then it hardened. \"If there are no heroes,\" she said, \"then this whole place is the villain.\" The counter on the door spun to zero.",
				},
			},
		},
	},
	{
		id = "lc_work_wolf",
		title = "Work Order: Big and Will be Bad Wolf",
		text = "F-02-58 is a WAW: a huge gray wolf lying across its unit with its chin on its paws, sulking. \"Here we go,\" it says when it sees you. \"Another one who thinks I'm the villain. You know I've never once been asked my side of the story?\" There's a grandmother's shawl in the corner. You decide not to ask.",
		weight = 26,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = WAW,
		choices = {
			{
				label = "Instinct: bring it its dinner",
				hint = INSTINCT .. ". A Health check. It's always hungry.",
				clash = { stat = "health", foe = "A very large appetite", coins = 2, base = 5, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_wolf", log = "It ate the dinner and only looked at you thoughtfully once. You got out before it finished licking the bowl." },
				lose = { health = { -7, -4 }, sanity = -3, codex = "lc_abno_wolf", log = "It finished the dinner and looked at you, and licked its lips, and you ran. It laughed. It's a hard laugh to forget." },
			},
			{
				label = "Insight: tidy the unit",
				hint = INSIGHT .. ". A Mental Strength check.",
				clash = { stat = "mind", foe = "A wolf watching you work", coins = 2, base = 5, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_wolf", log = "You tidied around it while it critiqued your sweeping. The counter held." },
				lose = { sanity = { -5, -3 }, codex = "lc_abno_wolf", log = "You turned your back on it once. It was right behind you when you turned around again, smiling with all its teeth." },
			},
			{
				label = "Attachment: let it tell its side of the story",
				hint = ATTACHMENT .. ". It wants to be understood.",
				result = { charisma = { 2, 3 }, sanity = 2, paycheck = 0.2, codex = "lc_abno_wolf", log = "It talked for an hour about being cast as the villain in every story ever told. It was very reasonable about it. At the end it said, \"You're all right,\" and the PE-Boxes came out a deep, contented blue-green." },
			},
			{
				label = "Repression: put it in its place",
				hint = REPRESSION,
				result = {
					strength = 1,
					health = { -6, -3 },
					codex = "lc_abno_wolf",
					chronicle = "lc_caused_breach",
					trigger = "lc_breach_wolf",
					log = "You raised the riot stick. It sighed. \"Fine,\" it said. \"If that's the part you want me to play.\" It was out of the unit before the alarm finished its first note.",
				},
			},
		},
	},
	{
		id = "lc_work_snow_white",
		title = "Work Order: Snow White's Apple",
		text = "F-04-42 is a WAW: a single poisoned apple on a pedestal, green vines coiled around its base and creeping across the floor. It has been waiting for its prince for so long that the waiting has gone bad. The file has one line in red: \"Do not give it hope.\"",
		weight = 24,
		cooldown = 5,
		tags = { "lcorp", "work" },
		when = WAW,
		choices = {
			{
				label = "Instinct: polish the apple and water the vines",
				hint = INSTINCT .. ". A Health check.",
				clash = { stat = "health", foe = "Grasping vines", coins = 2, base = 5, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.1, codex = "lc_abno_snow_white", log = "The vines curled toward you as you worked. You kept moving. They never quite caught your ankle." },
				lose = { health = { -7, -4 }, codex = "lc_abno_snow_white", log = "A vine caught your ankle and held on while the apple considered you. You hacked the vine loose with a utility knife and got out." },
			},
			{
				label = "Insight: cut the vines back",
				hint = INSIGHT .. ". A Mental Strength check.",
				clash = { stat = "mind", foe = "Vines that grow back", coins = 2, base = 5, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_snow_white", log = "You cut the vines back to the base of the pedestal, and they stayed cut until you'd left the room. The counter held." },
				lose = { sanity = { -5, -3 }, health = -3, codex = "lc_abno_snow_white", log = "They grew back faster than you could cut them. You backed out of the unit with vines at your heels." },
			},
			{
				label = "Attachment: tell it the prince is still coming",
				hint = ATTACHMENT .. ". The file says not to give it hope.",
				result = { charisma = 1, health = { -13, -7 }, sanity = { -5, -3 }, codex = "lc_abno_snow_white", log = "It believed you. The vines surged up out of the floor with joy and wrapped you to the wall. The suppression team cut you down an hour later.", cause = "Tangled in Snow White's vines" },
			},
			{
				label = "Repression: cold, firm, by the book",
				hint = REPRESSION,
				result = { strength = { 2, 3 }, paycheck = 0.2, codex = "lc_abno_snow_white", log = "You worked it cold: no kindness, no talk, every procedure exact. It went on waiting, quietly. The PE-Boxes came out a sharp, bitter green." },
			},
		},
	},
	{
		id = "lc_work_knight_despair",
		title = "Work Order: The Knight of Despair",
		text = "O-01-73 is a WAW: a magical-girl knight in blue armor, a sword resting point-down in front of her. She looks up when you enter and studies you a long time. \"You look like someone who needs protecting,\" she says. \"I could protect you. I would protect you. Do you want me to?\"",
		weight = 24,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = WAW,
		choices = {
			{
				label = "Instinct: bring her rations and water",
				hint = INSTINCT .. ". She is a knight, not a hound.",
				result = { health = { -12, -7 }, sanity = -4, codex = "lc_abno_knight_despair", log = "\"I am not an animal to be fed,\" she said, and the sword rose on its own. You got out with your arm in ribbons and your pride in worse.", cause = "Insulted the Knight of Despair" },
			},
			{
				label = "Insight: tidy the unit and polish her shield",
				hint = INSIGHT .. ". A Mental Strength check.",
				clash = { stat = "mind", foe = "A knight's watchful eye", coins = 2, base = 5, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_knight_despair", log = "You polished the shield until she could see her face in it. She smiled, sadly, at whatever she saw." },
				lose = { sanity = -4, codex = "lc_abno_knight_despair", log = "You put the shield back crooked. She straightened it without a word, and the silence lasted the rest of your shift." },
			},
			{
				label = "Attachment: let her swear to protect you",
				hint = ATTACHMENT .. ". If she chooses you, look after yourself.",
				result = { charisma = { 2, 3 }, health = 3, sanity = 3, paycheck = 0.2, setFlags = { "lc_knight_chosen" }, codex = "lc_abno_knight_despair", log = "She knelt and swore to protect you, and a blessing settled over you like armor. Your shoulders feel lighter. The file says to be very careful now. If anything happens to you, she'll take it hard." },
			},
			{
				label = "Repression: order her to stand down",
				hint = REPRESSION .. ". A hard Strength check.",
				clash = { stat = "strength", foe = "The Knight of Despair", coins = 2, base = 6, coinPower = 3 },
				win = { strength = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_knight_despair", log = "She stood down, and looked at you like a disappointed older sister. The counter held, barely." },
				lose = { health = { -9, -5 }, sanity = -3, codex = "lc_abno_knight_despair", log = "She didn't stand down. Her sword stayed in the floor. You were somehow on the floor next to it anyway." },
			},
		},
	},
	{
		id = "lc_work_king_greed",
		title = "Work Order: The King of Greed",
		text = "O-01-64 is a WAW: a magical girl sealed inside a hard, glittering jewel shell. Through the facets you can see her eyes, following everything you carry. Your watch. Your badge. Your shoes. \"Oh,\" she says, \"that's nice. Is it for me?\" The file says veterans only, quickly, and never study her.",
		weight = 24,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = WAW,
		choices = {
			{
				label = "Instinct: feed her quickly and get out",
				hint = INSTINCT .. ". Veterans only. Quickly.",
				result = { health = { 2, 3 }, paycheck = 0.22, codex = "lc_abno_king_greed", log = "You set down the tray and were out before she finished saying \"more\". The PE-Boxes came out gold-flecked. You checked your pockets in the corridor; everything was still there." },
			},
			{
				label = "Insight: study her shell for the report",
				hint = INSIGHT .. ". The file says never.",
				result = { mind = 1, health = { -12, -7 }, sanity = -4, loseGear = true, codex = "lc_abno_king_greed", log = "You stayed to study her. She wanted your watch. Then your coat. Then you, and the shell began to open. The suppression team pulled you out, and some of what you'd carried in stayed behind.", cause = "Wanted by the King of Greed" },
			},
			{
				label = "Attachment: tell her she has enough",
				hint = ATTACHMENT .. ". A hard Charisma check.",
				clash = { stat = "charisma", foe = "Endless wanting", coins = 2, base = 6, coinPower = 3 },
				win = { charisma = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_king_greed", log = "For one second, inside the shell, she looked like she believed you. Then it passed. But the counter went up." },
				lose = { sanity = { -6, -4 }, money = { -40, -10 }, codex = "lc_abno_king_greed", log = "\"Enough?\" She laughed until the facets rang. You came out with an empty wallet and no memory of opening it." },
			},
			{
				label = "Repression: keep her shell sealed",
				hint = REPRESSION .. ". A Strength check.",
				clash = { stat = "strength", foe = "The King of Greed", coins = 2, base = 5, coinPower = 3 },
				win = { strength = { 2, 3 }, paycheck = 0.12, codex = "lc_abno_king_greed", log = "You checked every seal on her shell and tightened two. She sulked like a child denied a sweet. It's a sound you could live without." },
				lose = { health = { -7, -4 }, codex = "lc_abno_king_greed", log = "A seal you were checking popped, and the shell rolled over your foot on the way to the door. It stopped there. Just." },
			},
		},
	},
	{
		id = "lc_hell_train",
		title = "The Ticket Booth",
		text = "T-09-86, Express Train to Hell, is a WAW you don't work with: you use it. A silent clerk sits behind a ticket window with four lights above it. Two are lit. Agents come here to buy a ticket when they're hurt, and the more lights are on, the better a ticket does. When all four are lit, the train comes. Everyone knows to step back.",
		weight = 18,
		cooldown = 4,
		tags = { "lcorp", "work" },
		when = WAW,
		codex = "lc_abno_hell_train",
		choices = {
			{
				label = "Buy a ticket now, on two lights",
				result = { health = { 3, 6 }, sanity = 2, log = "The clerk slid a ticket under the glass without looking up. Your head cleared and your bruises eased. You walked away from the tracks." },
			},
			{
				label = "Wait for the third light",
				hint = "Your wounds close on three.",
				result = { health = { 6, 10 }, sanity = 3, cure = "any", log = "You waited on the bench for the third light, and bought your ticket, and the worst of the year closed over like it had never happened. You stepped back from the tracks anyway, out of respect." },
			},
			{
				label = "Wait for all four lights, for everyone's sake",
				hint = "Everyone in the facility feels it. Then you must step back in time: a Strength check.",
				clash = { stat = "strength", foe = "The train", coins = 2, base = 5, coinPower = 3 },
				win = { health = { 6, 10 }, sanity = 6, setFlags = { "lc_heard_the_horn", "saw_abnormality" }, log = "The fourth light came on. You bought the ticket and heard a horn far away, and every Agent in every department straightened up at once. Then you jumped back, and the train went through where you'd been standing, down a tunnel with no end." },
				lose = { health = { -16, -10 }, sanity = -6, setFlags = { "lc_heard_the_horn", "saw_abnormality" }, log = "You stepped back a moment late. The train didn't take you. It came close enough that it took something.", cause = "Too close to the tracks" },
			},
			{
				label = "Don't buy a ticket",
				result = { mind = 1, log = "You don't buy tickets for trains with no destination. You told the clerk so. The clerk didn't care." },
			},
		},
	},

	-- ── ALEPH ──
	{
		id = "lc_work_orchestra",
		title = "Work Order: The Silent Orchestra",
		text = "T-01-31 is an ALEPH. A conductor in a black tailcoat stands on a podium in front of an orchestra of empty chairs, baton raised, waiting. It turns its head toward you. It doesn't have a face, exactly. It seems delighted to have an audience. The Manager's voice in your earpiece says, very calmly, \"Do not let it begin.\"",
		weight = 24,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = ALEPH,
		choices = {
			{
				label = "Instinct: dust the chairs and music stands",
				hint = INSTINCT .. ". A hard Health check.",
				clash = { stat = "health", foe = "A rehearsal waiting to start", coins = 3, base = 6, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_orchestra", log = "You dusted every empty chair while it hummed to itself. The baton never fell. The PE-Boxes came out in perfect rows." },
				lose = { health = { -8, -5 }, sanity = { -7, -4 }, codex = "lc_abno_orchestra", log = "You knocked a music stand over. It took that as a downbeat. Two bars of the first movement played before the Manager cut the lights, and you heard them for a week." },
			},
			{
				label = "Insight: tune the stands and check the score",
				hint = INSIGHT .. ". A hard Mental Strength check.",
				clash = { stat = "mind", foe = "A score that reads you back", coins = 3, base = 6, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_orchestra", log = "You read the score without hearing it, which takes practice. The conductor seemed to appreciate a professional. The counter held." },
				lose = { sanity = { -9, -6 }, condition = "lc_shaken", codex = "lc_abno_orchestra", log = "You read one line of the score and heard it, in your own head, perfectly. You're still not sure it has stopped." },
			},
			{
				label = "Attachment: let it talk to you about music",
				hint = ATTACHMENT .. ". Veterans keep it company and keep it waiting.",
				result = { charisma = { 2, 3 }, sanity = 2, paycheck = 0.28, codex = "lc_abno_orchestra", log = "It told you, without words, about every symphony it had ever loved, and you listened, and you never once asked it to play. It was happy to wait for a better day. The PE-Boxes were enormous." },
			},
			{
				label = "Repression: take its baton away",
				hint = REPRESSION,
				result = { strength = 1, health = { -14, -8 }, sanity = { -10, -7 }, condition = "lc_shaken", codex = "lc_abno_orchestra", log = "You reached for the baton. It brought the baton down. The first movement began, calm and slow, and the Manager sealed the department while you lay listening on the floor.", cause = "Heard the Silent Orchestra play" },
			},
		},
	},
	{
		id = "lc_work_blue_star",
		title = "Work Order: Blue Star",
		text = "O-03-93 is an ALEPH. The unit looks empty, except for a small blue light hanging far away in the dark, much farther away than the back wall should allow. It's singing. The sound is so lovely you stop in the doorway. The Information Team's file begins: \"Do not answer it.\"",
		weight = 24,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = ALEPH,
		choices = {
			{
				label = "Instinct: check the unit's air and temperature",
				hint = INSTINCT .. ". A hard Health check.",
				clash = { stat = "health", foe = "A long walk toward the light", coins = 3, base = 6, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_blue_star", log = "You checked every reading with your back to the light. The song followed you to the door and stopped there, politely." },
				lose = { sanity = { -8, -5 }, health = -3, codex = "lc_abno_blue_star", log = "You found you'd walked ten steps toward it without deciding to. You walked back eleven, very slowly." },
			},
			{
				label = "Insight: keep the unit in order, and don't answer",
				hint = INSIGHT,
				result = { mind = { 2, 3 }, sanity = -1, paycheck = 0.28, codex = "lc_abno_blue_star", log = "You kept everything tidy and said nothing, while the star sang your name very softly. You didn't answer. Even the best work with it leaves you wanting to go back." },
			},
			{
				label = "Attachment: answer it",
				hint = ATTACHMENT .. ". The file says not to.",
				result = { charisma = 1, sanity = { -13, -9 }, health = { -6, -3 }, condition = "lc_shaken", setFlags = { "lc_star_called" }, codex = "lc_abno_blue_star", log = "You said hello. It was the happiest you have ever been. The Safety Team found you with both hands flat on the glass, humming, and put your name on the list of people who mustn't go near it again." },
			},
			{
				label = "Repression: shutter the window and work it blind",
				hint = REPRESSION .. ". A hard Strength check.",
				clash = { stat = "strength", foe = "A song through the shutters", coins = 3, base = 6, coinPower = 3 },
				win = { strength = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_blue_star", log = "You shuttered the light and worked by procedure. The song kept on through the steel. You finished, and you were proud you'd finished." },
				lose = { sanity = { -8, -5 }, codex = "lc_abno_blue_star", log = "You couldn't keep your hand off the shutter latch. The Control Team talked you out of the unit one sentence at a time." },
			},
		},
	},
	{
		id = "lc_work_nothing_there",
		title = "Work Order: Nothing There",
		text = "O-06-20 is an ALEPH. The unit is dark. Something in it says \"Good morning\" in a voice you know from the cafeteria. Its file is almost empty, on purpose. Under DESCRIPTION, the Information Team has written only: \"It copies. It learns. Keep it company and don't give it anything new to learn.\"",
		weight = 22,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = ALEPH,
		choices = {
			{
				label = "Instinct: set down its rations in the dark",
				hint = INSTINCT .. ". A hard Health check.",
				clash = { stat = "health", foe = "Something learning how you move", coins = 3, base = 6, coinPower = 3 },
				win = { health = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_nothing_there", log = "You set the rations down and backed out. In the corridor, you realized you'd been walking the way it walks. You stopped." },
				lose = { health = { -9, -5 }, sanity = { -6, -4 }, codex = "lc_abno_nothing_there", log = "It took the tray out of your hands the way you'd have taken it. It thanked you in your own voice. You didn't stop shaking until the next morning." },
			},
			{
				label = "Insight: inspect the unit with a torch",
				hint = INSIGHT .. ". A hard Mental Strength check.",
				clash = { stat = "mind", foe = "What the torch shows", coins = 3, base = 6, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_nothing_there", log = "You kept the torch low and looked only at the floor. Your report says \"unit in order\". It doesn't say anything else." },
				lose = { sanity = { -10, -6 }, condition = "lc_shaken", codex = "lc_abno_nothing_there", log = "You raised the torch. You won't describe it, and the Welfare Team has stopped asking you to." },
			},
			{
				label = "Attachment: keep it company and let it listen",
				hint = ATTACHMENT .. ". It likes to listen.",
				result = { charisma = { 2, 3 }, sanity = -3, paycheck = 0.3, codex = "lc_abno_nothing_there", log = "You told it the weather report and the cafeteria menu and nothing else, for an hour. It listened, very still. It learned nothing new. The PE-Boxes were enormous, and you went home and talked to nobody all evening." },
			},
			{
				label = "Repression: drive it into the back of the unit",
				hint = REPRESSION,
				result = {
					strength = 1,
					health = { -6, -3 },
					sanity = -4,
					codex = "lc_abno_nothing_there",
					chronicle = "lc_caused_breach",
					trigger = "lc_breach_nothing_there",
					log = "You drove it back into the dark. It learned how you swing a riot stick. Then it learned where the door was.",
				},
			},
		},
	},
	{
		id = "lc_work_whitenight",
		title = "Work Order: WhiteNight",
		text = "T-03-46 is an ALEPH. The unit is so bright you work with dark lenses over your eyes. In the middle of the light is a winged figure with a halo, and around it, very still, twelve figures in beaked masks. \"My servant,\" it says, in a voice that fills the room. \"Have you come to hear the word?\"",
		weight = 20,
		cooldown = 6,
		tags = { "lcorp", "work" },
		when = ALEPH,
		choices = {
			{
				label = "Instinct: tend to the apostles' needs",
				hint = INSTINCT .. ". Never Instinct.",
				result = { health = { -15, -9 }, sanity = { -9, -6 }, codex = "lc_abno_whitenight", log = "You stepped toward the apostles with water. The light turned on you like heat from an open furnace. The Welfare Team says you're lucky. You don't feel lucky.", cause = "Burned by WhiteNight's light" },
			},
			{
				label = "Insight: keep the unit in order",
				hint = INSIGHT .. ". A hard Mental Strength check.",
				clash = { stat = "mind", foe = "The light", coins = 3, base = 6, coinPower = 3 },
				win = { mind = { 2, 3 }, paycheck = 0.18, codex = "lc_abno_whitenight", log = "You kept the unit in order with your eyes on the floor and the lenses down. Twelve masks turned to follow you, all the way out." },
				lose = { sanity = { -8, -5 }, health = { -5, -3 }, codex = "lc_abno_whitenight", log = "You looked up. The lenses didn't help. You saw the light for a week whenever you closed your eyes." },
			},
			{
				label = "Attachment: listen to the word",
				hint = ATTACHMENT,
				result = { charisma = { 2, 3 }, sanity = -2, paycheck = 0.3, codex = "lc_abno_whitenight", log = "You knelt at a safe distance and listened to it speak of a new world coming. You didn't believe it. You didn't have to. It was content to be heard. The PE-Boxes came out white-green and blinding." },
			},
			{
				label = "Repression: firm, cold, by the book",
				hint = REPRESSION,
				result = { strength = { 2, 3 }, sanity = -2, paycheck = 0.3, codex = "lc_abno_whitenight", log = "You worked it the way the file says, firm and cold and without a word. \"You resist,\" it said. \"Good. The ones who resist are the most faithful in the end.\" You've thought about that a lot." },
			},
		},
	},
}
