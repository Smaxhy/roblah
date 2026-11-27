--[[
	Breaches and what good work earns: follow-ups to the work orders (weight = 0).
	* lc_breach_*: the Qliphoth Counter hit zero. These are real fights (fight = true), with
	  a check to get people out and a way to hide. Every survivor is a breach survivor.
	* lc_ego_offer_*: a year after good work with a unit, the Extraction Team offers its E.G.O.
	* lc_doctor_counting, lc_galaxy_pebble_due: the Plague Doctor's blessing and the
	  Child of the Galaxy's pebble, a few years on.
]]

local SURVIVED = { "lc_breach_survivor", "saw_abnormality" }
local HID = { "lc_breach_survivor", "saw_abnormality", "lc_hid_in_breach" }
local WINGS_AGENT = { career = "lcorp_agent", world = { era = "wings" } }

return {
	-- ── breaches ──
	{
		id = "lc_breach_punishing_bird",
		title = "Breach: Punishing Bird",
		text = "The counter hits zero and the little bird is out, a round white shape zipping down the corridor with its beak open far too wide. It goes for anyone it decides has done wrong. Three Clerks are frozen at the far end of the hall, and one of them definitely took the last bun from the break room this morning.",
		weight = 0,
		codex = "lc_lore_suppression",
		when = WINGS_AGENT,
		choices = {
			{
				label = "Suppress it",
				hint = "A real fight. It's small, and it's fast.",
				clash = { stat = "strength", foe = "Punishing Bird", coins = 2, base = 4, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = { 2, 3 }, paycheck = 0.15, setFlags = SURVIVED, chronicle = "lc_suppressed_breach", log = "You chased it down the corridor and brought it to the floor with your riot stick. It turned back into an egg with an offended little click. The Clerks applauded. One of them gave you a bun." },
				lose = { health = { -10, -5 }, sanity = -3, setFlags = SURVIVED, log = "It found every wrong thing you've ever done, one peck at a time. The Disciplinary Team arrived and put it back in its egg while you lay on the floor.", cause = "Punished by a very small bird" },
			},
			{
				label = "Get the Clerks into the break room",
				hint = "A Health check: you're the door.",
				clash = { stat = "health", foe = "A beak at your back", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = 3, health = 1, setFlags = SURVIVED, log = "You herded all three Clerks into the break room and held the door until the Disciplinary Team came. The one who took the bun confessed to it on the spot." },
				lose = { health = { -7, -3 }, setFlags = SURVIVED, log = "You got them inside. The bird got your back on the way in. The Clerks bandaged you with paper towels." },
			},
			{
				label = "Hide and wait for the Disciplinary Team",
				result = { sanity = { -4, -2 }, setFlags = HID, log = "You hid behind a vending machine while it zipped past twice. The Disciplinary Team caught it. The Record Team wrote down where you'd been." },
			},
		},
	},
	{
		id = "lc_breach_scorched_girl",
		title = "Breach: Scorched Girl",
		text = "Scorched Girl is out. She walks down the corridor toward the cafeteria, burning brighter with every step, smiling, looking for someone to be close to. It's lunch hour. Behind the cafeteria doors, a hundred people are eating noodles. She'll reach them in about a minute.",
		weight = 0,
		codex = "lc_lore_suppression",
		when = WINGS_AGENT,
		choices = {
			{
				label = "Stop her before she gets there",
				hint = "A real fight. Everything around her burns.",
				clash = { stat = "strength", foe = "Scorched Girl", coins = 2, base = 5, coinPower = 3, fight = true, status = "burn" },
				win = { strength = { 2, 3 }, paycheck = 0.15, setFlags = SURVIVED, chronicle = "lc_suppressed_breach", log = "You met her ten meters from the doors and fought her to a standstill in a corridor full of smoke. She went back into her egg with the last match still in her hand. Nobody in the cafeteria ever knew." },
				lose = { health = { -12, -6 }, condition = "burns", setFlags = SURVIVED, log = "You held her for long enough. The Disciplinary Team did the rest. You'll carry the burns for a while.", cause = "Burned stopping Scorched Girl" },
			},
			{
				label = "Seal the doors and get everyone out through the kitchen",
				hint = "An Intelligence check: a hundred people and one back door.",
				clash = { stat = "intelligence", foe = "A hundred panicking diners", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 4, intelligence = 1, setFlags = SURVIVED, log = "You sealed the doors and marched a hundred people out through the kitchen in good order, and only one bowl of noodles was lost. She burned against the doors until the suppression team came." },
				lose = { health = { -8, -4 }, condition = "burns", setFlags = SURVIVED, log = "The doors held, barely. The heat came through anyway. Everyone got out. Your hands didn't." },
			},
			{
				label = "Hide in the stairwell",
				result = { sanity = { -5, -3 }, setFlags = HID, log = "You hid in the stairwell and listened to her footsteps go by, warm through the wall. Someone else stopped her. You don't know who." },
			},
		},
	},
	{
		id = "lc_breach_red_shoes",
		title = "Breach: The Red Shoes",
		text = "An Agent from the next department is wearing the Red Shoes. She's dancing down the corridor toward the crowded elevators, crying, unable to stop, and the shoes are steering her. Anything in her way gets kicked aside. \"Help me,\" she sobs, spinning. \"I can't stop.\"",
		weight = 0,
		codex = "lc_lore_suppression",
		when = WINGS_AGENT,
		choices = {
			{
				label = "Knock the shoes off her feet",
				hint = "A real fight. The shoes fight back.",
				clash = { stat = "strength", foe = "The Red Shoes", coins = 2, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = { 2, 3 }, paycheck = 0.15, setFlags = SURVIVED, chronicle = "lc_suppressed_breach", log = "You tackled the dance out of her and wrenched the shoes off one at a time. She collapsed and held on to you, shaking. The shoes lay on the floor looking innocent until Extraction took them away." },
				lose = { health = { -11, -6 }, sanity = -3, setFlags = SURVIVED, log = "The shoes kicked like they had a grudge. You went down, and the Disciplinary Team got there a minute after.", cause = "Kicked down by the Red Shoes" },
			},
			{
				label = "Talk her through it",
				hint = "A Charisma check. \"Look at me, not your feet.\"",
				clash = { stat = "charisma", foe = "The shoes' song", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 2, sanity = 3, setFlags = SURVIVED, log = "You walked backward in front of her, talking, talking, until she looked at your face instead of her feet and found the strength to kick them off. She sends you a card every year now." },
				lose = { sanity = { -6, -4 }, health = { -5, -2 }, setFlags = SURVIVED, log = "She couldn't hear you over the music only she could hear. The suppression team stopped her. You stood there with your hand still out." },
			},
			{
				label = "Get out of the way",
				result = { sanity = { -4, -2 }, setFlags = HID, log = "You flattened yourself into a doorway as she spun past, crying your name. You'd never told her your name." },
			},
		},
	},
	{
		id = "lc_breach_helper",
		title = "Breach: All-Around Helper",
		text = "All-Around Helper has left its unit to clean the facility. It rolls down the hall humming, arms unfolded. \"Contamination detected. Commencing cleaning.\" Every door it passes, someone shouts. The wall panel for its shutdown command is twenty meters behind it.",
		weight = 0,
		codex = "lc_lore_suppression",
		when = WINGS_AGENT,
		choices = {
			{
				label = "Suppress it",
				hint = "A real fight. It has a lot of arms.",
				clash = { stat = "strength", foe = "All-Around Helper", coins = 2, base = 5, coinPower = 3, fight = true, status = "rupture" },
				win = { strength = { 2, 3 }, paycheck = 0.15, setFlags = SURVIVED, chronicle = "lc_suppressed_breach", log = "You got inside its reach and hammered at its joints until it folded up into a neat white egg. \"Cleaning complete,\" it said, as it went." },
				lose = { health = { -12, -6 }, setFlags = SURVIVED, condition = "deep_cut", log = "It decided you were the contamination. The Disciplinary Team finished the cleaning.", cause = "Cleaned by All-Around Helper" },
			},
			{
				label = "Get past it to the shutdown panel",
				hint = "An Intelligence check: timing, nerve, a code you only half remember.",
				clash = { stat = "intelligence", foe = "Twenty meters of corridor", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, sanity = 2, setFlags = SURVIVED, chronicle = "lc_suppressed_breach", log = "You ducked under one arm and over another and punched the code in on the third try. It stopped mid-sentence: \"Commencing clea-\". The silence was beautiful." },
				lose = { health = { -8, -4 }, setFlags = SURVIVED, condition = "deep_cut", log = "You got the first two digits in before it noticed you. The suppression team got the rest." },
			},
			{
				label = "Hide in a supply closet",
				result = { sanity = { -4, -2 }, setFlags = HID, log = "You hid in a supply closet full of cleaning products and tried not to think about the irony. It rolled past twice, humming." },
			},
		},
	},
	{
		id = "lc_breach_big_bird",
		title = "Breach: Big Bird",
		text = "Big Bird is out. Its lantern swings slowly down the corridor, and everyone who looks into the light goes calm and still and starts walking toward it, smiling. Your colleague from the next desk is already halfway there, hands loose at her sides.",
		weight = 0,
		codex = "lc_lore_suppression",
		when = WINGS_AGENT,
		choices = {
			{
				label = "Fight it without looking at the lantern",
				hint = "A real fight, and a hard one. Eyes down.",
				clash = { stat = "strength", foe = "Big Bird", coins = 3, base = 5, coinPower = 3, fight = true, status = "sinking" },
				win = { strength = { 2, 3 }, paycheck = 0.2, setFlags = SURVIVED, addTrait = "lc_breach_hardened", chronicle = "lc_suppressed_breach", log = "You fought it by its shadow and its footsteps, never once looking up. When it went back into its egg, your colleague blinked, looked around, and asked why she was standing in the corridor." },
				lose = { health = { -15, -8 }, sanity = { -6, -3 }, setFlags = SURVIVED, log = "You looked up. Only for a second. Someone pulled you back by the collar, and you'll never know who.", cause = "Looked into Big Bird's lantern" },
			},
			{
				label = "Pull your colleague back with your eyes shut",
				hint = "A Mental Strength check: don't look, whatever you hear.",
				clash = { stat = "mind", foe = "The lantern's calm", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = 3, setFlags = SURVIVED, log = "You found her by her footsteps and dragged her backward into a side room with your eyes squeezed shut. She fought you all the way. She thanked you for a week after." },
				lose = { sanity = { -8, -5 }, health = { -6, -3 }, setFlags = SURVIVED, condition = "lc_shaken", log = "You heard her stop walking. You don't know what happened next, because you didn't open your eyes. The suppression team says she's alive. You haven't been able to ask her." },
			},
			{
				label = "Close your eyes and hide",
				result = { sanity = { -6, -3 }, setFlags = HID, log = "You crouched in a corner with your hands over your eyes and listened to the lantern creak past. It was the longest ten minutes of your life." },
			},
		},
	},
	{
		id = "lc_breach_queen",
		title = "Breach: The Queen of Hatred",
		text = "The Queen of Hatred has decided the facility is the villain. She flies through the department in a storm of bright magic, shouting about love and justice, and the walls are coming apart around her. She sees you. \"Are you with the villains?\" she cries. \"Or with me?\"",
		weight = 0,
		codex = "lc_lore_suppression",
		when = WINGS_AGENT,
		choices = {
			{
				label = "Fight her",
				hint = "A real fight, and a very hard one. She is the hero in her story.",
				clash = { stat = "strength", foe = "The Queen of Hatred", coins = 3, base = 6, coinPower = 3, fight = true, status = "charge" },
				win = { strength = { 2, 3 }, paycheck = 0.2, setFlags = SURVIVED, addTrait = "lc_breach_hardened", chronicle = "lc_suppressed_breach", log = "You and the suppression team wore her down blast by blast until she went back into her egg, still shouting about justice. You were, she made clear, a villain. You'll take it." },
				lose = { health = { -16, -8 }, sanity = -4, setFlags = SURVIVED, log = "She was very strong and very sure. You woke up in Welfare with your ears ringing.", cause = "Struck down by the Queen of Hatred" },
			},
			{
				label = "Tell her she's a hero, and the villain is elsewhere",
				hint = "An Intelligence check. Play the part.",
				clash = { stat = "intelligence", foe = "A hero's conviction", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 2, sanity = 4, setFlags = SURVIVED, log = "You told her the real villain had fled to her own unit, and that only a true hero could guard it. She flew straight back in. The Information Team added your speech to her file as a recommended script." },
				lose = { health = { -9, -5 }, sanity = -4, setFlags = SURVIVED, log = "She saw through you. \"A villain's lie!\" The blast threw you down the corridor." },
			},
			{
				label = "Hide behind the nearest bulkhead",
				result = { sanity = { -5, -3 }, setFlags = HID, log = "You hid behind a bulkhead while a magical girl took the department apart. It was the most colorful worst day of your life." },
			},
		},
	},
	{
		id = "lc_breach_wolf",
		title = "Breach: The Wolf Plays Its Part",
		text = "Big and Will be Bad Wolf has finally decided to be the villain. A Clerk is missing, her basket of paperwork lies scattered across the floor, and the wolf is sitting in the corridor looking very full and very pleased with itself. The file says she's still in there. For now.",
		weight = 0,
		codex = "lc_lore_suppression",
		when = WINGS_AGENT,
		choices = {
			{
				label = "Make it give her back",
				hint = "A real fight. The fairy tale says the hunter wins.",
				clash = { stat = "strength", foe = "Big and Will be Bad Wolf", coins = 3, base = 5, coinPower = 3, fight = true, status = "tremor" },
				win = { strength = { 2, 3 }, paycheck = 0.2, setFlags = SURVIVED, chronicle = "lc_suppressed_breach", log = "You played the hunter. When the wolf went back into its egg, the Clerk was sitting on the floor beside it, unhurt, damp, and furious about her paperwork." },
				lose = { health = { -14, -7 }, sanity = -3, setFlags = SURVIVED, log = "The wolf was bigger than the story said. The suppression team got the Clerk out. They got you out too.", cause = "Played the hunter against the Wolf" },
			},
			{
				label = "Send for the Red Riding Hooded Mercenary",
				hint = "An Intelligence check: if you've read her file, you know she'll come.",
				clash = { stat = "intelligence", foe = "Getting the order through", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, sanity = 2, setFlags = SURVIVED, codex = "lc_abno_red_hood", log = "Control opened her unit on your request. She was in the corridor before the door finished opening, and the wolf had a very bad afternoon. She sent the company an invoice." },
				lose = { health = { -6, -3 }, sanity = -3, setFlags = SURVIVED, log = "Control said no. By the time the suppression team arrived, you'd spent ten minutes alone in a corridor with a wolf." },
			},
			{
				label = "Hide and wait",
				result = { sanity = { -5, -3 }, setFlags = HID, log = "You hid. The wolf burped. Somebody else saved the Clerk." },
			},
		},
	},
	{
		id = "lc_breach_nothing_there",
		title = "Breach: A Familiar Voice",
		text = "The lights go out in the lower corridor. From somewhere down it, someone calls your name, calm and friendly. It sounds exactly like your friend from the Training Team. Your friend from the Training Team is standing right next to you, and she has gone very pale. On the board, Nothing There's unit is empty.",
		weight = 0,
		codex = "lc_lore_suppression",
		when = WINGS_AGENT,
		choices = {
			{
				label = "Go down the corridor and fight it",
				hint = "A real fight against an ALEPH. Brutal.",
				clash = { stat = "strength", foe = "Nothing There", coins = 3, base = 7, coinPower = 4, fight = true, status = "rupture" },
				win = { strength = { 3, 4 }, paycheck = 0.3, setFlags = SURVIVED, addTrait = "lc_breach_hardened", chronicle = "lc_suppressed_breach", log = "What you fought in that corridor wore a lot of faces. You beat all of them, with the Disciplinary Team at your back, until it went back into its egg. You don't describe it. Nobody asks you to." },
				lose = { health = { -18, -10 }, sanity = { -8, -5 }, setFlags = SURVIVED, condition = "lc_shaken", log = "It answered in your own voice. The Disciplinary Team got there in time, barely.", cause = "Answered a familiar voice" },
			},
			{
				label = "Don't answer. Seal the bulkhead and get everyone out",
				hint = "A Mental Strength check: ignore the voice, whatever it says.",
				clash = { stat = "mind", foe = "Your own name, called softly", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = -2, setFlags = SURVIVED, log = "You sealed the bulkhead and got eleven people to the elevator while the voice told you, kindly, that it was only you, that you could open up. You didn't. All eleven went home." },
				lose = { health = { -10, -6 }, sanity = { -7, -4 }, setFlags = SURVIVED, condition = "lc_shaken", log = "You hesitated, once, at a voice that sounded like your mother. That was enough to cost you. You got out. You still hear her sometimes, and it isn't her." },
			},
			{
				label = "Hide and wait for the Disciplinary Team",
				result = { sanity = { -8, -5 }, condition = "lc_shaken", setFlags = HID, log = "You hid in the dark and listened to it try on voices outside the door: your friend's, then a Clerk's, then yours. The Disciplinary Team came at last. You didn't open the door until you'd heard them swear." },
			},
		},
	},

	-- ── E.G.O offers (a year after good work) ──
	{
		id = "lc_ego_offer_penitence",
		title = "E.G.O: Penitence",
		text = "A note from the Extraction Team: O-03-03 has given enough PE-Boxes on your shifts to extract its E.G.O. Down on the lower floor, Binah's team hands you a heavy mace capped with a hollow skull and a ring of thorns. The Sephirah watches from the shadows. \"It suits you,\" she says. \"Or it will.\"",
		weight = 0,
		codex = "lc_lore_ego_gear",
		when = { career = "lcorp_agent", world = { era = "wings" }, notFlags = { "lc_ego_penitence" } },
		choices = {
			{
				label = "Take it",
				result = { gear = "lc_ego_penitence", setFlags = { "lc_ego_penitence", "lc_ego_issued" }, sanity = 2, chronicle = "lc_ego_issued", log = "You signed for Penitence. It's heavier than it looks and calmer than you are. Some nights it's the only quiet thing in the room." },
			},
			{
				label = "Take it, and ask Binah what it's made of",
				result = { gear = "lc_ego_penitence", setFlags = { "lc_ego_penitence", "lc_ego_issued", "lc_binah_riddle" }, mind = 2, sanity = -2, chronicle = "lc_ego_issued", log = "\"Of the skull's own nature,\" Binah said, \"drawn up from where it was born. Everything here was born somewhere, little one. Ask the Information Team where.\" She seemed amused. You signed for the mace and didn't sleep well." },
			},
			{
				label = "Turn it down",
				result = { mind = 1, sanity = 2, log = "You said no, thank you. You'd heard what E.G.O does to the way people talk, and you're fond of the way you talk. The Extraction Team shrugged and filed the form." },
			},
		},
	},
	{
		id = "lc_ego_offer_lament",
		title = "E.G.O: Solemn Lament",
		text = "The Extraction Team has drawn E.G.O from The Funeral of the Dead Butterflies, on the strength of your shifts with him. They lay it out on black cloth: two pistols, one black and one white. \"One grieves for the dead,\" the technician says. \"The other one grieves for the living. Early.\" She doesn't make eye contact.",
		weight = 0,
		codex = "lc_lore_ego_gear",
		when = { career = "lcorp_agent", world = { era = "wings" }, notFlags = { "lc_ego_lament" } },
		choices = {
			{
				label = "Take them",
				result = { gear = "lc_ego_lament", setFlags = { "lc_ego_lament", "lc_ego_issued" }, sanity = -2, chronicle = "lc_ego_issued", log = "You took Solemn Lament. Within a week you'd started speaking more quietly, and noticing who was missing from the cafeteria." },
			},
			{
				label = "Take them, and ask the mourner's permission",
				hint = "He's in his unit. He'll be on the schedule tomorrow.",
				result = { gear = "lc_ego_lament", setFlags = { "lc_ego_lament", "lc_ego_issued" }, intelligence = 2, sanity = 1, chronicle = "lc_ego_issued", log = "You told him through the door, as if he'd care. The butterflies settled. \"Carry them for the ones who have nowhere to go,\" he said. You've tried to." },
			},
			{
				label = "Turn them down",
				result = { sanity = 2, log = "You said you'd rather not carry anyone's mourning around just yet. The technician nodded like she understood completely." },
			},
		},
	},
	{
		id = "lc_ego_offer_justitia",
		title = "E.G.O: Justitia",
		text = "Judgement Bird's E.G.O has been extracted, and the file says it was the most righteous Agent in the company who did it. On paper, that's you. Binah holds out a long blade wrapped tight in old bandages. \"Don't take them off,\" she says. \"It doesn't want you to see. And it will be weighing you, every day you carry it.\"",
		weight = 0,
		codex = "lc_lore_ego_gear",
		when = { career = "lcorp_agent", world = { era = "wings" }, notFlags = { "lc_ego_justitia" } },
		choices = {
			{
				label = "Take it",
				result = { gear = "lc_ego_justitia", setFlags = { "lc_ego_justitia", "lc_ego_issued" }, strength = 2, sanity = -2, chronicle = "lc_ego_issued", log = "You took Justitia. It hums when someone lies near it. You've started weighing every word you say." },
			},
			{
				label = "Ask whether you're righteous enough",
				hint = "A Mental Strength check. The blade answers.",
				clash = { stat = "mind", foe = "The scales", coins = 2, base = 5, coinPower = 3 },
				win = { gear = "lc_ego_justitia", setFlags = { "lc_ego_justitia", "lc_ego_issued" }, strength = 2, mind = 2, chronicle = "lc_ego_issued", log = "You held it and waited. The bandages stayed still. Binah laughed softly. \"Well. It seems you'll do.\"" },
				lose = { sanity = { -6, -4 }, setFlags = { "lc_ego_justitia" }, log = "The blade grew so heavy in your hands you had to put it down. \"Not yet,\" Binah said. \"Come back when you're lighter.\" The Extraction Team holds it in your name." },
			},
			{
				label = "Turn it down",
				result = { mind = 2, log = "You said you'd rather not be weighed every day. Binah said that was the most honest thing she'd heard all week." },
			},
		},
	},
	{
		id = "lc_ego_offer_lamp",
		title = "E.G.O: Lamp",
		text = "From Big Bird's PE-Boxes the Extraction Team has made a suit: dark, heavy, hung with small lantern lights that glow when the corridor goes dark. \"It keeps the dark off,\" the technician says, \"and you'll start watching for a beast. Everyone who wears it does. There isn't one. Probably.\"",
		weight = 0,
		codex = "lc_lore_ego_gear",
		when = { career = "lcorp_agent", world = { era = "wings" }, notFlags = { "lc_ego_lamp" } },
		choices = {
			{
				label = "Wear it",
				result = { gear = "lc_ego_lamp", setFlags = { "lc_ego_lamp", "lc_ego_issued" }, health = 2, sanity = -1, chronicle = "lc_ego_issued", log = "You wore Lamp out of the Extraction floor. The corridor lights flickered as you passed, and the little lanterns on your coat stayed lit." },
			},
			{
				label = "Wear it, and keep a promise to the bird",
				hint = "Its forest still needs guarding.",
				result = { gear = "lc_ego_lamp", setFlags = { "lc_ego_lamp", "lc_ego_issued" }, mind = 2, sanity = 2, chronicle = "lc_ego_issued", log = "You went back to Big Bird's unit in its own suit and told it you'd watch the forest too. All its eyes closed at once, which the file says it has never done. The counter went to maximum." },
			},
			{
				label = "Turn it down",
				result = { sanity = 1, log = "You said no. Watching for a beast that never comes sounded like the rest of your job already." },
			},
		},
	},

	-- ── the doctor's count, and the pebble ──
	{
		id = "lc_doctor_counting",
		title = "The Twelfth Blessing",
		text = "An alarm you've never heard before. On the board, the Plague Doctor's unit has gone white. Over the speakers, a calm voice is counting: \"...ten. Eleven. Twelve.\" You were blessed once. You feel it now, in your chest, pulling you toward the light, and in your head a voice says, \"Rise, my servants. Rise and serve me.\"",
		weight = 0,
		codex = "lc_abno_whitenight",
		when = { flags = { "lc_blessed_once" }, career = { "lcorp_agent", "lcorp_research" }, world = { era = "wings" } },
		choices = {
			{
				label = "Fight the pull and run for the elevator",
				hint = "A Mental Strength check against the light.",
				clash = { stat = "mind", foe = "WhiteNight's call", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = -4, mind = 2, cure = "lc_blessed", setFlags = { "lc_breach_survivor", "saw_abnormality", "lc_saw_whitenight" }, log = "You ran with your eyes on the floor and your hands over your ears, and the pull let go of you at the elevator doors. The blessing was gone. So were eleven people who'd had it too." },
				lose = { health = { -12, -6 }, sanity = { -8, -5 }, condition = "lc_shaken", cure = "lc_blessed", setFlags = { "lc_breach_survivor", "saw_abnormality", "lc_saw_whitenight" }, log = "You got halfway to the light before someone tackled you. You fought them. You're glad you lost.", cause = "Called by the light" },
			},
			{
				label = "Help the Disciplinary Team hold the line",
				hint = "A real fight against WhiteNight's apostles.",
				clash = { stat = "strength", foe = "WhiteNight's apostles", coins = 3, base = 6, coinPower = 3, fight = true, status = "burn" },
				win = { strength = { 2, 3 }, cure = "lc_blessed", addTrait = "lc_breach_hardened", setFlags = { "lc_breach_survivor", "saw_abnormality", "lc_saw_whitenight" }, chronicle = "lc_suppressed_breach", log = "You fought beside the red-armored Disciplinary Team until the light went back into its egg. Gebura's voice over the radio said \"Good.\" Just that. It was enough." },
				lose = { health = { -16, -8 }, sanity = -5, cure = "lc_blessed", setFlags = { "lc_breach_survivor", "saw_abnormality", "lc_saw_whitenight" }, log = "The apostles were too many. You were carried out by people in red armor, still feeling the light pulling at you.", cause = "Fell before WhiteNight's apostles" },
			},
			{
				label = "Kneel in the light",
				hint = "It's calling you by name. A very hard Mental Strength check.",
				clash = { stat = "mind", foe = "WhiteNight", coins = 3, base = 7, coinPower = 3 },
				win = { sanity = 8, cure = "lc_blessed", addTrait = "light_touched", setFlags = { "lc_breach_survivor", "saw_abnormality", "lc_saw_whitenight" }, log = "You knelt, and the light looked at you for a long time, and then it looked away. \"Not yet,\" it said, almost kindly. You walked out of the white corridor with something of it still in you." },
				lose = { die = "Rose as one of WhiteNight's apostles", log = "You knelt in the light, and it took you up. The company lists you as lost. The people who saw it say you were smiling." },
			},
		},
	},
	{
		id = "lc_galaxy_pebble_due",
		title = "The Pebble Goes Cold",
		text = "The pebble from the Child of the Galaxy has been warm in your pocket every day since he gave it to you. This morning it's cold. By lunch, the whole department can hear him crying through three walls. The Control Team says he thinks his friend is hurt. He means you.",
		weight = 0,
		when = { flags = { "lc_galaxy_pebble" }, career = "lcorp_agent", world = { era = "wings" } },
		choices = {
			{
				label = "Go and show him you're all right",
				hint = "An Intelligence check: you're not on his schedule.",
				clash = { stat = "intelligence", foe = "A crying child's fear", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, intelligence = 2, setFlags = { "lc_galaxy_friend" }, log = "You talked your way onto his schedule and sat with him until he stopped crying. The pebble was warm again before you left. \"Forever,\" he reminded you. \"Forever,\" you said." },
				lose = { sanity = -4, log = "Control wouldn't let you in. He cried until the end of the shift. The pebble stayed cold for a week." },
			},
			{
				label = "Stay away and keep your head down",
				result = { sanity = { -5, -3 }, log = "You stayed at your post. You could hear him all afternoon. That night the pebble warmed up again, slowly, like it was forgiving you." },
			},
			{
				label = "Give the pebble back",
				result = { sanity = { -7, -4 }, clearFlags = { "lc_galaxy_pebble" }, log = "You handed it back through the door. He stopped crying at once and never looked at you again. You thought it would feel like relief." },
			},
		},
	},
}
