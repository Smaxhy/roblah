--[[
	SECOND STORIES, the third shelf: ten more stories that find a grown life (Storylines/
	Second3.luau has what each stands on). Five chapters each, counted in years from the day the
	story began (0, 1, 3, 5, 7); the last has three endings.

	Checks are `fixed`: your stats decide them, not your age. The fights in the later chapters
	are hard on purpose. Children in these stories are never hurt.
]]

local function chk(stat: string, foe: string, hard: boolean?)
	return { stat = stat, foe = foe, coins = if hard then 2 else 1, base = 3, coinPower = if hard then 2 else 3, fixed = true }
end
local function fight(foe: string, enemy: string, hard: boolean?)
	return { stat = "strength", foe = foe, enemy = enemy, fight = true, coins = if hard then 3 else 2, base = if hard then 5 else 3, coinPower = if hard then 3 else 2, fixed = true }
end

local MI, OO, PC, QT, CB = "sl2_missing", "sl2_old_office", "sl2_parcel", "sl2_quiet_tenant", "sl2_clean_books"
local CH, GB, PT, HD, LS = "sl2_changing", "sl2_grudge_book", "sl2_pit", "sl2_hand_me_down", "sl2_last_stop"

local function beat(story: string, year: number, e)
	e.story = story
	e.always = true
	e.once = true
	e.when = e.when or {}
	e.when.storyYear = year
	return e
end

return {
	-- ════ MISSING ═══════════════════════════════════════════════════════════════
	beat(MI, 0, {
		id = "sl3_mi_stairs",
		title = "On the Stairs",
		art = "home",
		text = "Mrs. Lenk from the flat below hasn't slept. Pia, eleven, sells paper flowers at the tram stop, and didn't come home before the Night. Nobody has knocked to say anything.",
		scene = { set = "stairs", title = "On the Stairs", line = "She's never late. She knows about the Night. She knows.", other = { name = "Mrs. Lenk", role = "from the flat below", pose = "sit" } },
		choices = {
			{ label = "Ask at the tram stop", clash = chk("charisma", "Stallholders who saw nothing"), win = { charisma = 1, setFlags = { "sl3_mi_lead" }, goal = "A stallholder saw Pia go with a boy in a red cap, before the hour.", log = "The noodle man remembered: a boy in a red cap, a friendly one. Pia went with him laughing." }, lose = { sanity = -2, goal = "Nobody at the tram stop saw anything. Nobody ever does.", log = "Nobody saw. People who see things in the Backstreets learn to stop." } },
			{ label = "Walk her route", clash = chk("intelligence", "Twelve streets and an alley"), win = { intelligence = 1, setFlags = { "sl3_mi_lead" }, goal = "You found a paper flower by a cellar door. Pia's.", log = "Under a cellar stair, a paper flower, still folded the way she folds them." }, lose = { goal = "You walked her route twice. The streets keep their secrets.", log = "Twice, slowly. Nothing but the usual." } },
			{ label = "Sit with Mrs. Lenk", result = { sanity = -1, charisma = 1, goal = "Mrs. Lenk isn't alone. Pia is still missing.", log = "You made tea she didn't drink. At noon she said thank you, and you both knew it wasn't enough." } },
		},
	}),
	beat(MI, 1, {
		id = "sl3_mi_red_cap",
		title = "The Red Caps",
		art = "alley",
		text = "The boy in the red cap belongs to a crew of children who pick pockets for a small Syndicate. They sleep in a warm cellar and get fed. Pia is with them, and she is fine, and she's not coming home.",
		choices = {
			{ label = "Talk to Pia", clash = chk("charisma", "An eleven-year-old who has decided"), win = { charisma = 2, setFlags = { "sl3_mi_talked" }, goal = "Pia will think about coming home. The Syndicate won't like that.", log = "\"Mama cries,\" she said. \"Here nobody cries. Here there's dinner.\" But she took your hand at the end." }, lose = { sanity = -3, goal = "Pia said no. She has a warm cellar and a crew. You have nothing to offer but home.", log = "She said no, very politely, the way her mother taught her." } },
			{ label = "Find the man who runs them", clash = chk("intelligence", "A Syndicate that hides its face"), win = { intelligence = 2, setFlags = { "sl3_mi_boss" }, goal = "You know who runs the Red Caps: a man called Brask, who doesn't like visitors.", log = "Brask. Runs four crews of children and a pawnshop. Never raises his voice, never needs to." }, lose = { health = { -6, -3 }, goal = "The Syndicate saw you asking. Ask more quietly next time.", log = "Two men walked you to the end of the alley and explained, briefly, about asking." } },
			{ label = "Tell Mrs. Lenk she's alive", result = { sanity = 2, charisma = 1, goal = "Pia's mother knows she's alive. That buys a little time.", log = "Mrs. Lenk sat down on the step and laughed, and then cried, and then asked where." } },
		},
	}),
	beat(MI, 3, {
		id = "sl3_mi_price",
		title = "Brask's Price",
		art = "syndicate",
		text = "Brask receives you in the back of his pawnshop, behind a counter of other people's watches. \"The Red Caps are fed and dry. If you want one back, you buy her contract. Three hundred Ahn.\"",
		choices = {
			{ label = "Pay", requires = { min = { money = 300 } }, result = { money = -300, sanity = 2, setFlags = { "sl3_mi_bought" }, goal = "You bought a child's contract from a Syndicate. Pia can come home, if she wants to.", log = "He wrote you a receipt. Nobody should ever be given a receipt for that." } },
			{ label = "Lean on him", clash = fight("Brask's two doormen", "syndicate", true), win = { strength = 2, rep = { rats = 3 }, setFlags = { "sl3_mi_forced" }, goal = "Brask let the contract go. He'll remember your face.", log = "Afterwards Brask tore the paper in half himself, carefully, and kept smiling." }, lose = { health = { -14, -8 }, cause = "Beaten in a Syndicate pawnshop", goal = "Brask's doormen threw you out into the rain. Pia's contract is still on his desk.", log = "You woke up in the gutter outside with your pockets turned out." } },
			{ label = "Report him to an Office", clash = chk("intelligence", "Hana's forms, and who reads them", true), win = { intelligence = 2, rep = { fixers = 3 }, setFlags = { "sl3_mi_office" }, goal = "An Office took the job. They'll be quick, and not gentle.", log = "Three Fixers took it on for what the street could raise. They asked which door, and nothing else." }, lose = { goal = "No Office will take a job that cheap.", log = "\"For forty Ahn?\" The rep laughed, not unkindly. \"Try the Rats.\"" } },
		},
	}),
	beat(MI, 5, {
		id = "sl3_mi_crew",
		title = "The Other Red Caps",
		art = "alley",
		text = "Pia comes to your door with three other children in red caps. Brask has a new crew to train, and these four are too old for pockets now. They have nowhere else to go.",
		choices = {
			{ label = "Take them in for the winter", result = { money = -60, charisma = 2, sanity = 3, setFlags = { "sl3_mi_kids" }, goal = "Four children who used to be Red Caps live in your flat. It's loud.", log = "Four mattresses, one stove, a rota for the washing up. They argue about everything and you've never slept better." } },
			{ label = "Find them work", clash = chk("charisma", "Shopkeepers who want references"), win = { charisma = 2, setFlags = { "sl3_mi_jobs" }, goal = "Four former pickpockets have honest jobs, and keep checking their own pockets.", log = "A bakery, a laundry, a cobbler, a tram depot. All four were early on their first day." }, lose = { sanity = -2, goal = "Nobody wants a Red Cap behind their counter.", log = "Every shop said the same thing in a different voice." } },
			{ label = "Take them to the Nest gate", clash = chk("luck", "A Nest that takes very few", true), win = { luck = 1, setFlags = { "sl3_mi_nest" }, goal = "One of them passed the Nest's test. The others didn't.", log = "One passed. She went through the gate without looking back, and the other three cheered her anyway." }, lose = { goal = "The gate turned them all away.", log = "\"Papers,\" said the guard, and that was the end of it." } },
		},
	}),
	beat(MI, 7, {
		id = "sl3_mi_end",
		title = "Paper Flowers",
		art = "street",
		text = "Pia is eighteen now, and has a stall of her own at the tram stop. On it, among the paper flowers, there's one that's folded wrong, on purpose. It's for you.",
		choices = {
			{ label = "Buy it", result = { charisma = 2, sanity = 5, storyEnd = "Found: Pia came home, and kept the stall, and kept the street", log = "She wouldn't take your money. You left it in the jar anyway." } },
			{ label = "Ask about the others", result = { intelligence = 1, mind = 2, sanity = 3, storyEnd = "The Red Caps: four children nobody looked for, looked for", log = "She told you where each of them is. One of them is a Fixer now, Grade 8, and terribly proud." } },
			{ label = "Go and see Brask", requires = { flags = { "sl3_mi_forced" } }, clash = fight("Brask, at last", "syndicate", true), win = { strength = 2, rep = { rats = 5 }, storyEnd = "No More Red Caps: Brask's pawnshop is a bakery now", log = "Brask packed his watches into a suitcase and left the District that night." }, lose = { health = { -18, -10 }, cause = "Went back for Brask", storyEnd = "Unfinished: Brask still runs his crews, and knows your name", log = "Brask was ready for you this time." } },
		},
	}),

	-- ════ THE OLD OFFICE ═════════════════════════════════════════════════════════
	beat(OO, 0, {
		id = "sl3_oo_lease",
		title = "The Lease",
		art = "office",
		text = "The Office above the tailor's is cheap because its last Fixer died on a job. Hana's clerk slides the lease across with a stack of contracts tied in string: paid, signed, unfinished.",
		choices = {
			{ label = "Read every contract", clash = chk("intelligence", "Eight years of a dead man's handwriting"), win = { intelligence = 2, setFlags = { "sl3_oo_read" }, goal = "Most of the contracts are small. One isn't: a client who paid in full, and is still waiting.", log = "Seven are lost dogs and late debts. The eighth is paid in full, for a great deal, to find a man." }, lose = { sanity = -2, goal = "The handwriting beat you. Somebody will come asking anyway.", log = "Half of it is shorthand only he could read. He can't, now." } },
			{ label = "Burn the lot", result = { sanity = 1, rep = { fixers = -3 }, setFlags = { "sl3_oo_burned" }, goal = "You burned a dead man's contracts. His clients don't know that yet.", log = "They went up fast. Paper that old wants to." } },
			{ label = "Hang your own sign", result = { charisma = 1, money = -20, goal = "Your name is on the door. The old contracts are in a drawer.", log = "Your name on the brass, his name still faintly under it where the polish couldn't reach." } },
		},
	}),
	beat(OO, 1, {
		id = "sl3_oo_client",
		title = "The Last Client",
		art = "office",
		text = "An old man climbs your stairs with a receipt eight years old. He paid this Office to find the man who burned his shop. \"The sign changed,\" he says. \"The contract didn't.\"",
		choices = {
			{ label = "Honour it", result = { mind = 2, rep = { fixers = 3 }, setFlags = { "sl3_oo_honour" }, goal = "You took on a dead man's contract. Find the arsonist.", log = "You shook his hand. It was the first time anyone had in a while, by the look on his face." } },
			{ label = "Refund what you can", requires = { min = { money = 100 } }, result = { money = -100, charisma = 1, goal = "You gave the old man back a hundred Ahn and an apology.", log = "He counted it, folded it, and said it wasn't the money. It never is." } },
			{ label = "Tell him the Office is new", clash = chk("charisma", "A man with a receipt"), win = { charisma = 1, goal = "He went. He'll come back next year with the same receipt.", log = "He nodded politely and went. He'll be back. They always come back." }, lose = { sanity = -2, rep = { fixers = -2 }, goal = "He told the whole street your Office doesn't keep its word.", log = "By evening the tailor downstairs wouldn't meet your eye." } },
		},
	}),
	beat(OO, 3, {
		id = "sl3_oo_arsonist",
		title = "The Arsonist",
		art = "alley",
		text = "The man who burned the old man's shop is a Fixer himself now, Grade 6, with an Office across the District. He knows who you are and why you've come. He meets you in an alley, alone, out of courtesy.",
		choices = {
			{ label = "Fight him", clash = fight("A Grade 6 with a burned conscience", "fixer", true), win = { strength = 3, rep = { fixers = 4 }, setFlags = { "sl3_oo_beat" }, goal = "You beat the arsonist. Hana will want to know why.", log = "He yielded on one knee and asked you to tell the old man he was sorry. You didn't promise." }, lose = { health = { -18, -10 }, cause = "Killed settling a dead man's contract", goal = "He beat you, and stepped over you, and left.", log = "\"Old contracts,\" he said, wiping his blade. \"Should've burned them.\"" } },
			{ label = "Bring Hana the proof", clash = chk("intelligence", "Evidence eight years cold", true), win = { intelligence = 2, rep = { fixers = 5 }, setFlags = { "sl3_oo_hana" }, goal = "Hana downgraded the arsonist's licence. The old man has his answer.", log = "A downgrade is a public thing. The whole District read his new grade by noon." }, lose = { goal = "The proof wasn't enough for Hana.", log = "\"Circumstantial,\" said the clerk, with satisfaction." } },
			{ label = "Hear his side", result = { mind = 2, sanity = -2, goal = "He burned the shop on a contract. Someone paid him. The contract had a name on it.", log = "\"It was a job,\" he said. \"Somebody paid me. You want the one who paid.\" He gave you a name." } },
		},
	}),
	beat(OO, 5, {
		id = "sl3_oo_audit",
		title = "Hana Comes Calling",
		art = "office",
		text = "Hana's clerk is back, in your chair, reading your files. \"Your predecessor was very sloppy,\" he says. \"I'm here to see whether you are too.\"",
		choices = {
			{ label = "Show your books", clash = chk("intelligence", "A Hana audit", true), win = { intelligence = 2, money = 80, setFlags = { "sl3_oo_clean" }, goal = "Your Office passed Hana's audit. The clerk was disappointed.", log = "He found one error, in your favour, and corrected it, and paid you, with visible pain." }, lose = { money = -80, goal = "You were fined. The clerk was pleased.", log = "A fine for every unfinished contract in the drawer. He'd counted them." } },
			{ label = "Charm him", clash = chk("charisma", "A clerk who has heard it all", true), win = { charisma = 2, goal = "The clerk left early, which for him is a compliment.", log = "He accepted a cup of tea, which nobody has seen him do." }, lose = { money = -40, goal = "Charm doesn't work on Hana. It's in their charter.", log = "He wrote \"attempted charm\" in the margin, and fined you for it." } },
			{ label = "Hand him the old files", result = { mind = 1, rep = { fixers = 2 }, goal = "Hana has the dead man's files. Your drawer is empty at last.", log = "He took them with real gratitude. Hana loves a complete file more than anything alive." } },
		},
	}),
	beat(OO, 7, {
		id = "sl3_oo_end",
		title = "Two Names on the Door",
		art = "office",
		text = "Seven years. The brass plate has your name on it, and under the polish, still, his. A young Fixer is at the door asking if you're taking on anyone.",
		choices = {
			{ label = "Take her on", result = { charisma = 2, sanity = 4, rep = { fixers = 4 }, storyEnd = "The Office: a dead man's sign, your name, and now a third", log = "She starts Monday. You gave her his old desk. It still has his knife marks." } },
			{ label = "Close the Office", result = { mind = 2, sanity = 3, money = 100, storyEnd = "Closed Book: you finished what he left, and let the lease go", log = "You returned the keys to Hana. The clerk shook your hand. That's never happened." } },
			{ label = "Keep it, alone", result = { strength = 2, intelligence = 1, storyEnd = "One Desk: the Office above the tailor's, still open, still yours", log = "You told her to come back when she's Grade 7. She said she would. She will." } },
		},
	}),

	-- ════ THE PARCEL ═════════════════════════════════════════════════════════════
	beat(PC, 0, {
		id = "sl3_pc_doorway",
		title = "In the Doorway",
		art = "street",
		text = "A courier falls into your doorway, grey with exhaustion, a parcel chained to his wrist. He presses a key into your hand and says an address in another District. Then he sleeps like the dead, though he isn't.",
		choices = {
			{ label = "Take the parcel", result = { mind = 1, setFlags = { "sl3_pc_took" }, goal = "You have a parcel and an address three Districts away. Don't open it.", log = "It's heavy for its size, and warm. Something inside ticks, very slowly." } },
			{ label = "Wake him up and argue", clash = chk("charisma", "A courier who won't wake"), win = { charisma = 1, setFlags = { "sl3_pc_took" }, goal = "He told you the fee: four hundred Ahn on delivery. And not to open it.", log = "\"Four hundred,\" he mumbled. \"On delivery. Don't open it. Don't let her buy it.\"" }, lose = { goal = "He slept through it. The parcel is yours now.", log = "He slept for eleven hours. When he woke, he was gone, and the parcel wasn't." } },
			{ label = "Shake it", clash = chk("luck", "A parcel that ticks"), win = { luck = 1, setFlags = { "sl3_pc_took" }, goal = "It ticks faster when you shake it. Don't shake it.", log = "It ticked faster. Then slower. You put it down very gently." }, lose = { health = { -6, -3 }, setFlags = { "sl3_pc_took" }, goal = "It bit you, somehow, through the paper. Don't shake it.", log = "Something inside it snapped at your fingers. Through the paper." } },
		},
	}),
	beat(PC, 1, {
		id = "sl3_pc_offer",
		title = "The Better Offer",
		art = "street",
		text = "A woman in sunglasses falls into step beside you on the way to the station. She knows about the parcel. She'll pay twice the fee, here and now, and the courier need never know.",
		scene = { set = "street", title = "The Better Offer", line = "Eight hundred, and you walk home. He'd never know. He'd never even wake up.", other = { name = "The woman with the better offer", role = "turns up wherever the parcel goes" } },
		choices = {
			{ label = "Sell", result = { money = 800, sanity = -4, rep = { fixers = -3 }, setFlags = { "sl3_pc_sold" }, goal = "You sold the parcel. The courier will wake up.", log = "She counted it out in new notes and walked off with the parcel under her arm, humming." } },
			{ label = "Refuse and run", clash = chk("speed", "A woman who doesn't run, and doesn't need to"), win = { speed = 2, goal = "You lost her in the crowd at the station. She'll find you again.", log = "Through the market, over a wall, onto the platform. She was waiting on the next one." }, lose = { health = { -8, -4 }, goal = "She caught up. She didn't take it. She just wanted you to know she could.", log = "She tapped your shoulder from behind and smiled, and let you go." } },
			{ label = "Ask what's inside", clash = chk("intelligence", "A buyer who likes questions"), win = { intelligence = 2, setFlags = { "sl3_pc_knows" }, goal = "It's a heart. A Workshop heart, for someone who's dying across the City.", log = "\"A heart,\" she said. \"Workshop-made. Somebody's waiting for it. Somebody else would rather they didn't.\"" }, lose = { goal = "She laughed and wouldn't say.", log = "\"Something you'd rather not know,\" she said. \"That's what all parcels are.\"" } },
		},
	}),
	beat(PC, 3, {
		id = "sl3_pc_district",
		title = "Three Districts Over",
		art = "checkpoint",
		text = "You've crossed two Districts. The third has a checkpoint, and the guards are searching parcels today. The ticking has got louder.",
		choices = {
			{ label = "Bluff through", clash = chk("charisma", "A checkpoint guard", true), win = { charisma = 2, goal = "Through the checkpoint. The address is three streets away.", log = "\"Medical,\" you said, which was true. The guard didn't want to know more." }, lose = { health = { -10, -5 }, money = -60, goal = "They searched you and fined you. You still have the parcel. Just.", log = "They opened your coat, not the parcel. You paid the fine and didn't argue." } },
			{ label = "Go under", clash = chk("speed", "A drainage tunnel under the wall", true), win = { speed = 2, goal = "Under the wall. The address is three streets away.", log = "Knee-deep and black. The parcel ticked the whole way, like it was counting." }, lose = { health = { -12, -6 }, condition = "fever", goal = "The tunnel nearly had you. The parcel's still dry.", log = "You came up coughing in a stranger's yard. The parcel was the only dry thing on you." } },
			{ label = "Wait for the shift change", result = { mind = 2, sanity = -2, goal = "You waited a day for a lazier guard. The ticking is slower now.", log = "A whole day. The ticking slowed. You don't know if that's good." } },
		},
	}),
	beat(PC, 5, {
		id = "sl3_pc_address",
		title = "The Address",
		art = "home",
		text = "The address is a clinic, closed. Inside, a man in a bed and a surgeon who wasn't expecting you. And behind you, on the stairs, the woman in sunglasses, with three Fixers.",
		choices = {
			{ label = "Hold the stairs", clash = fight("Three hired Fixers", "fixer", true), win = { strength = 3, rep = { fixers = 2 }, setFlags = { "sl3_pc_held" }, goal = "You held the stairs. Behind you the surgeon worked.", log = "You held the stairs for twenty minutes. Behind you, someone's new heart started." }, lose = { health = { -20, -12 }, cause = "Killed on a clinic stair, delivering a parcel", goal = "They got past you. The surgeon was faster than they were.", log = "They went over you. The surgeon was faster. You heard the heart start from the floor." } },
			{ label = "Talk her down", clash = chk("charisma", "A buyer with three Fixers", true), win = { charisma = 3, setFlags = { "sl3_pc_talked" }, goal = "She let it go. You don't know why.", log = "\"He's my brother,\" she said finally, about the man in the bed, and left." }, lose = { health = { -10, -6 }, goal = "Talking didn't work. The surgeon was faster anyway.", log = "Talking bought the surgeon four minutes. That turned out to be enough." } },
			{ label = "Hand the parcel over and go", result = { sanity = -3, money = 400, goal = "Delivered. You didn't stay to see who won.", log = "You put it on the bed and walked out past her. She let you." } },
		},
	}),
	beat(PC, 7, {
		id = "sl3_pc_end",
		title = "A Card in the Post",
		art = "home",
		text = "Seven years later a card comes, no return address. Inside, in a careful hand: I am still alive. Thank you for not opening it.",
		choices = {
			{ label = "Keep the card", result = { sanity = 5, charisma = 1, storyEnd = "Delivered: somewhere across the City, a stranger's heart is still ticking", log = "It's on your shelf. Some nights you'd swear it ticks." } },
			{ label = "Wonder about her", result = { intelligence = 2, mind = 2, storyEnd = "The Better Offer: you still don't know who she was, or who she was for", log = "You never found out. You've stopped wanting to, mostly." } },
			{ label = "Become a courier", result = { speed = 3, money = 100, storyEnd = "On the Road: you carry what can't be sent any other way, and never open it", log = "There's always something that needs carrying. You're good at not asking." } },
		},
	}),

	-- ════ THE QUIET TENANT ═══════════════════════════════════════════════════════
	beat(QT, 0, {
		id = "sl3_qt_groceries",
		title = "The Groceries",
		art = "home",
		text = "Old Mrs. Varga from upstairs carries four bags up six flights without stopping. When you offer to help she looks at you for a long moment, the way people look at the weather.",
		choices = {
			{ label = "Carry them anyway", result = { strength = 1, charisma = 1, setFlags = { "sl3_qt_known" }, goal = "Mrs. Varga lets you carry her groceries. There's a sword by her door.", log = "She let you. At her door you saw the sword: plain, long, very well looked after." } },
			{ label = "Ask about the sword", clash = chk("charisma", "An old woman who doesn't explain"), win = { charisma = 1, setFlags = { "sl3_qt_known" }, goal = "She was a Grade 1 Fixer. She doesn't say it like it matters.", log = "\"I was a Fixer,\" she said. \"Grade 1. A long time ago. Mind the third step.\"" }, lose = { goal = "She closed her door. Politely.", log = "\"It's a sword,\" she said, and closed the door." } },
			{ label = "Leave her be", result = { mind = 1, goal = "The old woman upstairs keeps to herself. So do you.", log = "Some people have earned being left alone." } },
		},
	}),
	beat(QT, 1, {
		id = "sl3_qt_lesson",
		title = "Feet First",
		art = "rooftop",
		text = "On the roof at dawn Mrs. Varga is doing forms with a broom handle, slowly, like water. She has seen you watching. \"Well? Come and do it wrong, then.\"",
		choices = {
			{ label = "Learn the forms", clash = chk("speed", "Forms slower than they look"), win = { speed = 2, strength = 1, setFlags = { "sl3_qt_student" }, goal = "Mrs. Varga is teaching you. Badly, she says. You're improving.", log = "\"Feet first. Everything else is feet.\" By the end of the month you fell down less." }, lose = { health = { -4, -2 }, goal = "She knocked you down eleven times. She says that's progress.", log = "Eleven times. \"Better than nine,\" she said, which made no sense." } },
			{ label = "Ask why she stopped", result = { mind = 2, sanity = 1, goal = "She stopped because she got old enough to. Most Fixers don't.", log = "\"I got old,\" she said. \"Most of us don't. That's the whole secret.\"" } },
			{ label = "Spar with her", clash = fight("A Grade 1 with a broom", "fixer", true), win = { strength = 3, speed = 1, goal = "You touched her once with the broom. She was delighted.", log = "Once, on the shoulder. She laughed so hard she had to sit down." }, lose = { health = { -6, -3 }, goal = "A broom handle hurts more than it should.", log = "She didn't seem to move. You were on your back anyway." } },
		},
	}),
	beat(QT, 3, {
		id = "sl3_qt_hunter",
		title = "The Young Fixer",
		art = "street",
		text = "A young Fixer with a red sidecut has been asking for Mrs. Varga by name. Beating an old Grade 1, even a retired one, would make a career. He's waiting downstairs.",
		choices = {
			{ label = "Meet him first", clash = fight("A young Fixer who wants a name", "fixer", true), win = { strength = 3, rep = { fixers = 3 }, setFlags = { "sl3_qt_turned" }, goal = "You beat him. He'll be back with friends.", log = "He went down hard and got up angrier. \"Not you,\" he said. \"Her.\"" }, lose = { health = { -16, -8 }, cause = "Killed defending an old Fixer's doorway", goal = "He went past you. Mrs. Varga met him on the stairs.", log = "He stepped over you. From the stairs, a single sound, and then him, coming back down slower." } },
			{ label = "Warn her", result = { mind = 1, sanity = -1, goal = "She knows. She asked you to make tea.", log = "\"I know,\" she said. \"Put the kettle on. This won't take long.\" It didn't." } },
			{ label = "Talk him out of it", clash = chk("charisma", "Ambition with a sword", true), win = { charisma = 2, goal = "He left. He'll be a better Fixer for it, or a dead one.", log = "\"Beat someone who wants to fight you,\" you said. He thought about it, and went." }, lose = { sanity = -2, goal = "He laughed and went up. It was over in a breath.", log = "He went up. You heard one sound. He came down holding his wrist, and didn't come back." } },
		},
	}),
	beat(QT, 5, {
		id = "sl3_qt_friends",
		title = "Old Friends",
		art = "alley",
		text = "It wasn't the young Fixer. It was who he talked to. Six men from an old grudge, from a job Mrs. Varga did thirty years ago, have come up the street at dusk.",
		choices = {
			{ label = "Stand beside her", clash = fight("Six men with a thirty-year grudge", "syndicate", true), win = { strength = 3, speed = 1, rep = { fixers = 4 }, setFlags = { "sl3_qt_stood" }, goal = "You and a retired Grade 1 held the street. They won't come back.", log = "Back to back. She was faster than all of them. You were nearly fast enough." }, lose = { health = { -22, -12 }, cause = "Fell beside a retired Grade 1", goal = "She finished it. You were down before the end.", log = "She stood over you until it was done, and then carried you up six flights." } },
			{ label = "Get her out of the District", clash = chk("intelligence", "A way out at dusk", true), win = { intelligence = 2, setFlags = { "sl3_qt_moved" }, goal = "Mrs. Varga is two Districts away, furious and alive.", log = "She complained the whole way. At the door of the new flat she hugged you, briefly, like a salute." }, lose = { goal = "She wouldn't go. She fought. She won, mostly.", log = "\"I'm not running from these,\" she said. She didn't." } },
			{ label = "Call an Office", requires = { min = { money = 200 } }, result = { money = -200, rep = { fixers = 2 }, goal = "An Office ended it before dark. Mrs. Varga is annoyed about the bill.", log = "Four Fixers, ten minutes. She insisted on paying you back in rice." } },
		},
	}),
	beat(QT, 7, {
		id = "sl3_qt_end",
		title = "The Sword by the Door",
		art = "home",
		text = "Mrs. Varga is very old now, and the stairs are hard. She has asked you up for tea, and the sword is lying across the table.",
		choices = {
			{ label = "Take the sword", result = { strength = 3, speed = 2, gear = "sl3_varga_sword", storyEnd = "The Sword by the Door: a Grade 1's blade, given, not taken", log = "\"Feet first,\" she said, and pushed it across the table. \"Everything else is feet.\"" } },
			{ label = "Ask her to keep it", result = { mind = 3, sanity = 5, storyEnd = "Tea Upstairs: you never took the sword, only the lessons", log = "\"Good,\" she said, and poured the tea. It was the first thing she'd ever said was good." } },
			{ label = "Ask her about the old days", result = { intelligence = 2, charisma = 2, sanity = 3, storyEnd = "The Old Days: you know more about the City's Fixers than any book", log = "Three hours of names, Offices and contracts. You wrote them down afterwards, all of them." } },
		},
	}),

	-- ════ CLEAN BOOKS ════════════════════════════════════════════════════════════
	beat(CB, 0, {
		id = "sl3_cb_hired",
		title = "The Laundry",
		art = "workshop",
		text = "Mr. Holm's laundry washes about twenty shirts a day and banks forty thousand Ahn a month. He wants someone to make those two numbers look like friends.",
		choices = {
			{ label = "Take the job", result = { money = 120, intelligence = 1, setFlags = { "sl3_cb_job" }, goal = "You keep a Syndicate's books now. Make the numbers friends.", log = "Very good pay, a desk with a lock, and a rule: never look in the back room." } },
			{ label = "Take it, and keep a copy", clash = chk("intelligence", "Two sets of books"), win = { intelligence = 2, money = 120, setFlags = { "sl3_cb_job", "sl3_cb_copy" }, goal = "You keep his books, and a second set in your mattress.", log = "Every night, a page copied in pencil. Insurance, of a kind." }, lose = { money = 60, setFlags = { "sl3_cb_job" }, goal = "You tried to copy the books. You think Holm noticed.", log = "Holm watched you lock your desk, and smiled, and said nothing." } },
			{ label = "Walk away", result = { mind = 1, goal = "You turned down a Syndicate's money. Holm doesn't hear that often.", log = "\"How unusual,\" said Holm, and let you go. He wrote something down as you went." } },
		},
	}),
	beat(CB, 1, {
		id = "sl3_cb_back_room",
		title = "The Back Room",
		art = "syndicate",
		text = "The back room door is open, just a crack, and inside is not washing. It's a ledger of names, and debts, and dates, and a list of who has been collected.",
		choices = {
			{ label = "Close the door", result = { mind = 1, sanity = -2, goal = "You didn't see anything. You'll keep not seeing it.", log = "You closed it gently and went back to the shirts. Twenty a day." } },
			{ label = "Read the list", clash = chk("intelligence", "A ledger in code"), win = { intelligence = 2, setFlags = { "sl3_cb_names" }, goal = "You know whose names are on Holm's list. One of them is your neighbour's.", log = "Names, debts, dates. One of them lives across the landing from you." }, lose = { health = { -6, -3 }, goal = "Holm caught you at the door. He was gentle about it, which was worse.", log = "\"Curiosity,\" said Holm softly, and closed the door on your fingers." } },
			{ label = "Warn your neighbour", result = { charisma = 1, sanity = 1, rep = { rats = -2 }, setFlags = { "sl3_cb_warned" }, goal = "Your neighbour left the District. Holm is wondering how he knew.", log = "He went that night. Holm asked the whole staff, very kindly, if anyone knew anything." } },
		},
	}),
	beat(CB, 3, {
		id = "sl3_cb_auditor",
		title = "The Auditor",
		art = "office",
		text = "Hana has sent an auditor: a woman with round glasses who reads ledgers the way other people read novels. She's going to read yours. Holm is watching you.",
		choices = {
			{ label = "Make the books pass", clash = chk("intelligence", "A Hana auditor", true), win = { intelligence = 3, money = 200, setFlags = { "sl3_cb_passed" }, goal = "The books passed. Holm gave you a bonus and a look.", log = "She closed the last ledger and sighed, impressed despite herself." }, lose = { sanity = -4, setFlags = { "sl3_cb_flagged" }, goal = "The auditor found something. Holm thinks it's your fault.", log = "Page forty. She circled one number in red, and Holm stopped smiling at you." } },
			{ label = "Slip her your copy", requires = { flags = { "sl3_cb_copy" } }, result = { intelligence = 2, rep = { fixers = 4 }, setFlags = { "sl3_cb_traded" }, goal = "Hana has your copy of the books. Now you wait.", log = "She took it without looking at you and finished her tea. \"Thank you for the biscuit.\"" } },
			{ label = "Call in sick", result = { mind = 1, money = -40, goal = "You weren't there. Holm noticed that too.", log = "You stayed home. Holm sent soup, and a man to watch you eat it." } },
		},
	}),
	beat(CB, 5, {
		id = "sl3_cb_holm",
		title = "Holm's Question",
		art = "syndicate",
		text = "Holm has the auditor's report on his desk and two men by the door. He asks you, very calmly, whose side you're on.",
		choices = {
			{ label = "His", clash = chk("charisma", "A Syndicate boss who already knows", true), win = { charisma = 2, money = 300, setFlags = { "sl3_cb_loyal" }, goal = "Holm believes you. For now. He's made you a partner.", log = "\"Partner,\" he said, and shook your hand, and didn't let go for a long time." }, lose = { health = { -16, -8 }, cause = "Answered a Syndicate boss wrong", goal = "Holm didn't believe you.", log = "He nodded to the men by the door, and went to wash his hands." } },
			{ label = "Your own", clash = fight("Holm's two men", "syndicate", true), win = { strength = 3, rep = { rats = 4 }, setFlags = { "sl3_cb_out" }, goal = "You walked out of Holm's office. Holm is packing.", log = "You left them on the floor. Holm was already putting ledgers in a suitcase." }, lose = { health = { -20, -12 }, cause = "Fought a Syndicate's doormen", goal = "You didn't get out the door.", log = "The door was further away than it looked." } },
			{ label = "Hana's", requires = { flags = { "sl3_cb_traded" } }, result = { rep = { fixers = 5 }, mind = 2, setFlags = { "sl3_cb_out" }, goal = "Hana's Fixers came through the door before Holm's men could move.", log = "\"Hana's,\" you said. The door opened behind you right on cue." } },
		},
	}),
	beat(CB, 7, {
		id = "sl3_cb_end",
		title = "Balanced",
		art = "office",
		text = "The laundry is a laundry again; it washes forty shirts a day now, and banks what forty shirts earn. You still keep books for a living. The numbers are friends.",
		choices = {
			{ label = "Open your own practice", result = { intelligence = 3, money = 150, storyEnd = "Clean Books: you keep honest ledgers now, for honest shops, and charge them less", log = "A small office, a good lamp, nine clients. You check the back rooms of all of them." } },
			{ label = "Work for Hana", result = { intelligence = 2, rep = { fixers = 5 }, storyEnd = "The Auditor's Desk: you read ledgers for Hana, and Syndicates dread your glasses", log = "You bought round glasses. You don't need them. They help." } },
			{ label = "Burn the copy", result = { mind = 3, sanity = 4, storyEnd = "Ashes: you burned the last copy of Holm's books, and the names with it", log = "Some of those names were people who'd paid. They deserved to be forgotten." } },
		},
	}),

	-- ════ CHANGING ═══════════════════════════════════════════════════════════════
	beat(CH, 0, {
		id = "sl3_ch_clock",
		title = "The Clock",
		art = "home",
		text = "Teodor hasn't slept in six days. He's taken his mantel clock apart and laid the pieces in a perfect circle on the floor. \"Listen,\" he says. \"It's thinking. It's thinking about me.\"",
		scene = { set = "room", title = "The Clock", line = "Listen. Can you hear it? It's thinking about me. It's been thinking about me for years.", other = { name = "Teodor", role = "grew up with you" } },
		choices = {
			{ label = "Put the clock back together", clash = chk("intelligence", "A clock in a hundred pieces"), win = { intelligence = 2, setFlags = { "sl3_ch_steady" }, goal = "You fixed the clock. Teodor slept for the first time in a week.", log = "It ticked again at three in the morning. Teodor sat down beside it, and slept." }, lose = { sanity = -3, goal = "The pieces won't go back. Teodor watched you try, smiling.", log = "One piece too many. Teodor said that's the piece that thinks." } },
			{ label = "Take him outside", clash = chk("charisma", "A friend who won't leave the clock"), win = { charisma = 2, setFlags = { "sl3_ch_steady" }, goal = "You walked Teodor around the block. He laughed once. That's something.", log = "Twice round the block, slowly. At the corner he laughed at a dog, like himself." }, lose = { sanity = -2, goal = "He wouldn't leave the clock.", log = "\"If I go, it'll stop,\" he said. You couldn't argue." } },
			{ label = "Go to the Association", result = { mind = 1, sanity = -2, setFlags = { "sl3_ch_reported" }, goal = "An Association Fixer has Teodor's name now, in a file of people who changed.", log = "The Fixer wrote his name down gently, in a thick file. \"Bring him in, if it gets worse.\"" } },
		},
	}),
	beat(CH, 1, {
		id = "sl3_ch_hands",
		title = "His Hands",
		art = "home",
		text = "Teodor's hands have started keeping time. His fingers tap, tap, tap, even asleep, and the furniture in his flat has begun to face him. He knows. He's frightened. He asks you to stay.",
		choices = {
			{ label = "Stay the night", clash = chk("mind", "A flat that watches", true), win = { mind = 2, sanity = -2, setFlags = { "sl3_ch_steady" }, goal = "You stayed. In the morning the chairs were facing the window again.", log = "You talked about being nine. Toward dawn his hands were still." }, lose = { sanity = -8, goal = "You ran at three in the morning. You heard the chairs turn.", log = "At three every chair in the room turned toward you at once. You were down the stairs before you knew it." } },
			{ label = "Find him work to do", clash = chk("intelligence", "A mind with nowhere to go"), win = { intelligence = 2, setFlags = { "sl3_ch_steady" }, goal = "Teodor is repairing watches for the stall downstairs. It helps.", log = "Forty broken watches. He fixed them all in a night, and slept all day, and woke up himself." }, lose = { sanity = -3, goal = "The work didn't help. The watches all stopped at the same time.", log = "Every watch he touched stopped at 3:13." } },
			{ label = "Bring the Fixer", requires = { flags = { "sl3_ch_reported" } }, result = { sanity = -4, mind = 2, setFlags = { "sl3_ch_watched" }, goal = "The Association is watching Teodor now. He knows you brought them.", log = "The Fixer looked at the chairs and said nothing. Teodor looked at you for a long time." } },
		},
	}),
	beat(CH, 3, {
		id = "sl3_ch_brink",
		title = "The Brink",
		art = "street",
		text = "At noon Teodor stands in the street and every clock on the block stops at once. People are backing away. His face isn't quite his face. He's still in there. He says your name.",
		choices = {
			{ label = "Hold on to him", clash = chk("mind", "Someone at the edge of Distorting", true), win = { mind = 3, sanity = -4, setFlags = { "sl3_ch_held" }, goal = "You held on. He came back. The clocks started again.", log = "You held his face in your hands and said his name until it was his again. Every clock on the block started." }, lose = { sanity = -10, setFlags = { "sl3_ch_gone" }, goal = "He let go of himself. Something else is standing where Teodor stood.", log = "His face finished changing. It was beautiful, in a way, like the inside of a watch." } },
			{ label = "Remind him who he is", clash = chk("charisma", "Someone at the edge of Distorting", true), win = { charisma = 3, sanity = -3, setFlags = { "sl3_ch_held" }, goal = "You talked him back. He doesn't remember the street.", log = "You told him about the roof when you were nine, the pigeon, the broken window. He laughed, and was himself." }, lose = { sanity = -10, setFlags = { "sl3_ch_gone" }, goal = "Your voice didn't reach him. Something else is standing where Teodor stood.", log = "He heard you. He smiled. He went anyway." } },
			{ label = "Get the street clear", clash = chk("speed", "A block full of people", true), win = { speed = 2, charisma = 1, setFlags = { "sl3_ch_gone" }, goal = "Nobody else was hurt. Teodor is gone. Something else stands in the street.", log = "You got forty people off the block. When you turned round he was taller, and ticking." }, lose = { health = { -12, -6 }, setFlags = { "sl3_ch_gone" }, goal = "You were too close when he changed.", log = "The air folded. You were on the ground with the stopped clocks." } },
		},
	}),
	beat(CH, 5, {
		id = "sl3_ch_after",
		title = "What Stands There",
		art = "street",
		when = { flags = { "sl3_ch_gone" }, world = { era = { "library", "limbus" } } },
		text = "The Distortion that was Teodor has made his block its own. Clock hands bloom on the walls. People walk through it and come out older. An Office has taken the contract. They want a guide who knew him.",
		choices = {
			{ label = "Guide them in", battle = "teodor_distorted", clash = { stat = "strength", foe = "The Distortion that was Teodor", enemy = "distortion", fight = true, coins = 3, base = 7, coinPower = 4, fixed = true, boss = true, status = { id = "sinking", potency = 2 } }, win = { strength = 3, mind = 2, sanity = -6, setFlags = { "sl3_ch_ended" }, goal = "It's over. The clocks on the block run normally again.", log = "At the end it turned toward you, and stopped ticking, and was still. The Office paid you. You gave it to his mother." }, lose = { health = { -26, -14 }, sanity = -8, cause = "Killed by a friend who had Distorted", goal = "The Office finished it. You were carried out.", log = "It knew you. That was the worst part. It was gentle, for a moment, before it wasn't." } },
			{ label = "Go in alone and talk to it", clash = chk("mind", "Something that remembers being Teodor", true), win = { mind = 4, sanity = -5, setFlags = { "sl3_ch_spoke" }, goal = "It let you go. It let the block go, too. It's gone somewhere, quietly.", log = "You sat on the pavement and talked about being nine. It listened. In the morning the block was empty." }, lose = { die = "Walked into a Distortion that had once been a friend", log = "You went in to talk to him. You were never seen again. The clocks on the block show the time you went in." } },
			{ label = "Let the Office do it", result = { sanity = -6, mind = 1, setFlags = { "sl3_ch_ended" }, goal = "An Office ended it. You didn't watch.", log = "You heard it from two streets away: every clock in the District struck at once, and then silence." } },
		},
	}),
	beat(CH, 5, {
		id = "sl3_ch_kept",
		title = "Still Ticking",
		art = "home",
		when = { notFlags = { "sl3_ch_gone" } },
		text = "Teodor is himself, mostly. He keeps a dozen clocks now and fixes the street's watches for free. Once a month his fingers start keeping time, and he calls you, and you come.",
		choices = {
			{ label = "Come, every time", result = { mind = 3, sanity = 2, setFlags = { "sl3_ch_kept" }, goal = "Teodor is still Teodor, because you keep coming.", log = "Every month, a call, and tea, and talk about being nine, until his hands are still." } },
			{ label = "Teach him to hold on himself", clash = chk("intelligence", "A habit for a mind at the edge"), win = { intelligence = 2, mind = 2, setFlags = { "sl3_ch_kept" }, goal = "Teodor has his own ways to hold on now. He calls less.", log = "A list on his wall, in your writing: your name, the roof, the pigeon. He reads it aloud when it's bad." }, lose = { sanity = -2, goal = "He still needs you. That's all right.", log = "He forgets the list. He doesn't forget your number." } },
			{ label = "Ask the Association for help", result = { mind = 1, rep = { fixers = 2 }, goal = "The Association checks on Teodor yearly. He hates it, and it helps.", log = "A Fixer visits once a year with a clipboard and a kind face. Teodor makes him tea." } },
		},
	}),
	beat(CH, 7, {
		id = "sl3_ch_end",
		title = "Stopped Clocks",
		art = "home",
		when = { world = { era = { "library", "limbus" } } },
		text = "There's a clock on your shelf that belonged to Teodor. It has never once kept the right time, and you've never once wanted it to.",
		choices = {
			{ label = "Wind it", requires = { flags = { "sl3_ch_kept" } }, result = { mind = 3, sanity = 6, storyEnd = "Still Ticking: Teodor stayed himself, because someone kept saying his name", log = "He came to dinner on Sunday. The clock was wrong all evening and nobody minded." } },
			{ label = "Let it stand", result = { mind = 4, sanity = 3, storyEnd = "Stopped Clocks: you lost a friend to the Light, and kept his clock", log = "It says 3:13. It's said 3:13 for years. You leave it." } },
			{ label = "Learn what Distortion is", result = { intelligence = 4, sanity = -2, storyEnd = "The File: you know more about people who change than anyone should", log = "The Association let you read their files. You read all of them. You check your own hands, some nights." } },
		},
	}),

	-- ════ THE GRUDGE BOOK ════════════════════════════════════════════════════════
	beat(GB, 0, {
		id = "sl3_gb_saw",
		title = "What You Saw",
		art = "alley",
		text = "Three men from a small Syndicate beat Little Brother Nino of the Middle in your alley, and you saw their faces. By morning the Middle is knocking on doors. By noon so are the three men.",
		choices = {
			{ label = "Tell the Middle", result = { rep = { middle = 5, rats = -4 }, setFlags = { "sl3_gb_told" }, goal = "You gave the Middle three names. Three men know you did.", log = "Big Sister Orsola wrote the names down in the Book, slowly, and thanked you like family." } },
			{ label = "Say nothing to anyone", result = { sanity = -3, mind = 1, setFlags = { "sl3_gb_quiet" }, goal = "You said nothing. Both sides are watching you.", log = "You said nothing. Both sides heard you say it." } },
			{ label = "Warn the three men", clash = chk("charisma", "Three men who'd rather you were quiet"), win = { charisma = 1, rep = { middle = -6, rats = 3 }, setFlags = { "sl3_gb_warned" }, goal = "The three men left the District. The Middle wants to know who warned them.", log = "They were gone by dark. The Middle came round asking who knew. Everyone knew." }, lose = { health = { -10, -5 }, goal = "They didn't want a warning. They wanted a witness gone.", log = "They thanked you for the warning, and then explained what happens to witnesses." } },
		},
	}),
	beat(GB, 1, {
		id = "sl3_gb_book",
		title = "Title 4, Section 2",
		art = "syndicate",
		text = "Big Sister Orsola reads you a line from the Book: an injury to a Sibling, Title 4, Section 2, Row C. The debt is paid by whoever is closest to it. You're closest.",
		choices = {
			{ label = "Ask what's owed", clash = chk("intelligence", "A law code of grudges"), win = { intelligence = 2, goal = "The Middle wants the three men brought to them. Not hurt. Brought.", log = "\"Brought,\" she said. \"We do the rest. The Book is very particular.\"" }, lose = { goal = "The Book is long. You understood that you owe something.", log = "Title, Section, Row, Line. You got lost at Row." } },
			{ label = "Refuse", clash = chk("mind", "Big Sister Orsola, smiling", true), win = { mind = 2, rep = { middle = -3 }, setFlags = { "sl3_gb_refused" }, goal = "You refused the Middle. Orsola wrote that down too.", log = "She wrote a new line, slowly. \"Refusal,\" she said. \"Title 9. You'll like Title 9.\"" }, lose = { health = { -8, -4 }, goal = "Refusing the Middle hurts. They were gentle about it, for them.", log = "Two Little Siblings walked you home, and explained Title 9 on the way." } },
			{ label = "Ask to be a Little Sibling", requires = { minAge = 18 }, result = { rep = { middle = 8 }, setFlags = { "sl3_gb_sibling" }, goal = "The Middle will take you in, if you bring the three men.", log = "Orsola's face lit up. \"Bring them,\" she said, \"and come home.\"" } },
		},
	}),
	beat(GB, 3, {
		id = "sl3_gb_three",
		title = "The Three Men",
		art = "street",
		text = "The three men have hired a Fixer to make the witness problem go away. You find out when the Fixer finds you.",
		choices = {
			{ label = "Fight the Fixer", clash = fight("A Fixer hired to close a witness", "fixer", true), win = { strength = 3, setFlags = { "sl3_gb_fixer_down" }, goal = "You beat the Fixer they hired. The three men are running out of money.", log = "The Fixer yielded and told you who'd paid. \"Not personal,\" he said. It never is." }, lose = { health = { -20, -12 }, cause = "Killed by a Fixer hired to silence a witness", goal = "The Fixer left you for dead. You weren't quite.", log = "He was very professional about it. You were lucky he was in a hurry." } },
			{ label = "Hide with the Middle", requires = { flags = { "sl3_gb_told" } }, result = { rep = { middle = 3 }, sanity = -2, goal = "The Middle hid you for a month. You owe them now, too.", log = "A month in a back room that smelled of noodles, surrounded by people who called you family." } },
			{ label = "Outbid them", requires = { min = { money = 250 } }, result = { money = -250, intelligence = 1, goal = "You paid the Fixer more to go away. He's an honest man, in his way.", log = "He counted it and put away his blade. \"I was never here,\" he said, and wasn't." } },
		},
	}),
	beat(GB, 5, {
		id = "sl3_gb_big",
		title = "Big Sister Orsola",
		art = "alley",
		text = "The Book is never closed. If you refused it, or warned the three men, Orsola has come to settle it herself, chain wrapped around her arm. If you helped, she's come to ask for one more thing.",
		choices = {
			{ label = "Face her", battle = "big_sister_orsola", clash = { stat = "strength", foe = "Big Sister Orsola of the Middle", enemy = "middle_big", fight = true, coins = 3, base = 7, coinPower = 4, fixed = true, boss = true, status = { id = "rupture", potency = 2 } }, win = { strength = 4, rep = { middle = -4 }, setFlags = { "sl3_gb_beat_big" }, chronicle = "bl_act_boss_slain", goal = "You beat a Big Sister of the Middle. The Book will have a new line for that.", log = "She went down laughing. \"Title 1,\" she said, from the ground. \"You're in Title 1 now. Congratulations.\"" }, lose = { health = { -28, -16 }, cause = "Paid a debt to the Middle in full", goal = "Orsola settled the line. You're alive because the Book said so.", log = "When it was over she checked the Book, carefully, and stopped exactly where it said to." } },
			{ label = "Do the one more thing", requires = { flags = { "sl3_gb_told" } }, result = { rep = { middle = 6 }, sanity = -3, setFlags = { "sl3_gb_done" }, goal = "You did the Middle a favour. The line is closed.", log = "You delivered a sealed envelope to a door. You didn't ask. The line was closed that night." } },
			{ label = "Recite the Book back to her", clash = chk("intelligence", "The Middle's own law, quoted", true), win = { intelligence = 3, rep = { middle = 4 }, setFlags = { "sl3_gb_done" }, goal = "You found a line in the Book that clears you. Orsola was delighted.", log = "Title 6, Section 1: a witness who brings the truth owes nothing. She pressed the Book to her forehead." }, lose = { health = { -12, -6 }, goal = "Wrong Title. She corrected you, physically.", log = "\"Title 6 is for siblings,\" she said, and showed you Title 2 instead." } },
		},
	}),
	beat(GB, 7, {
		id = "sl3_gb_end",
		title = "A Line in the Book",
		art = "syndicate",
		text = "Seven years on, your name is in the Middle's Book. Everyone's is, somewhere. The question is only which Title.",
		choices = {
			{ label = "Join the Middle", requires = { flags = { "sl3_gb_sibling" } }, result = { strength = 2, rep = { middle = 10 }, setFlags = { "fn_middle_member" }, storyEnd = "Little Sibling: the Middle remembers, and now it remembers you as family", log = "A tattoo, a creed, a dozen people hugging you like you've come home. Maybe you have." } },
			{ label = "Ask to see your line", result = { intelligence = 2, mind = 2, storyEnd = "Title, Section, Row and Line: you know exactly what the Middle thinks of you", log = "Orsola let you read it. It was longer than you expected, and fairer." } },
			{ label = "Leave the District", result = { speed = 2, sanity = 3, storyEnd = "Out of the Book's Reach: no District is, but this one is far enough", log = "Four Districts away, a Little Sister of the Middle sold you noodles and said she'd heard of you." } },
		},
	}),

	-- ════ THE PIT ════════════════════════════════════════════════════════════════
	beat(PT, 0, {
		id = "sl3_pt_first",
		title = "Sand",
		art = "arena",
		text = "The pit under the cannery is a ring of wet sand and a crowd on the stairs. The owner pays fighters from the door: twenty Ahn to fight, eighty to win. Your first opponent is a docker with a bad knee.",
		choices = {
			{ label = "Fight", clash = fight("A docker with a bad knee", "thug"), win = { strength = 2, money = 80, setFlags = { "sl3_pt_won1" }, goal = "You won your first fight in the pit. The owner wants you back.", log = "The crowd learned your name between the second punch and the third." }, lose = { health = { -10, -5 }, money = 20, goal = "You lost your first fight. The owner says you have potential.", log = "His bad knee wasn't that bad. The owner gave you twenty and a cloth for your face." } },
			{ label = "Watch first", clash = chk("intelligence", "Six fights in an evening"), win = { intelligence = 2, setFlags = { "sl3_pt_studied" }, goal = "You've learned the pit's rules. There aren't many.", log = "No weapons, no eyes, stop when the bell goes. The bell is often late." }, lose = { goal = "You watched. You learned the crowd shouts more than it sees.", log = "It all looked like noise. It's meant to." } },
			{ label = "Ask the champion's name", result = { mind = 1, goal = "The champion is called the Ox. He's never lost. Somebody will have to.", log = "The Ox. Four years unbeaten. He was sitting in the corner eating rice, very peacefully." } },
		},
	}),
	beat(PT, 1, {
		id = "sl3_pt_climb",
		title = "Up the Board",
		art = "arena",
		text = "Your name is on the chalkboard now, ninth of ten. Every fight is harder than the last, and the eighth is a former Rat with a long reach and no manners.",
		choices = {
			{ label = "Fight him straight", clash = fight("A former Rat with a long reach", "rat", true), win = { strength = 3, money = 120, setFlags = { "sl3_pt_climbing" }, goal = "Eighth on the board. The owner bought you dinner.", log = "He had reach. You had patience. The bell was late and it didn't matter." }, lose = { health = { -14, -8 }, condition = "broken_arm", goal = "He broke your arm. Ninth on the board, for now.", log = "The bell was late on purpose. The owner apologised, and didn't mean it." } },
			{ label = "Fight him smart", clash = { stat = "speed", foe = "A former Rat with a long reach", enemy = "rat", fight = true, coins = 3, base = 5, coinPower = 3, fixed = true }, win = { speed = 3, money = 120, setFlags = { "sl3_pt_climbing" }, goal = "Eighth on the board. You never let him touch you.", log = "Inside his reach and out again, forty times. He sat down from tiredness." }, lose = { health = { -12, -6 }, goal = "Too slow this time.", log = "You were fast. He was faster, once, which is all it takes." } },
			{ label = "Train another year", result = { strength = 1, speed = 1, goal = "You trained. The board waits.", log = "Rope, sand, stairs. The owner sent a note: the crowd misses you." } },
		},
	}),
	beat(PT, 3, {
		id = "sl3_pt_fix",
		title = "The Fix",
		art = "syndicate",
		text = "The owner pours you tea. Next week you fight the second on the board, and the second is supposed to win. Lose in the third round and there's five hundred in it. Win, and the Syndicate that owns the pit loses a great deal.",
		choices = {
			{ label = "Take the dive", result = { money = 500, sanity = -5, setFlags = { "sl3_pt_dived" }, goal = "You lost on purpose. The owner likes you now. You don't.", log = "Third round, a punch you could've slipped. The crowd booed. The owner paid in new notes." } },
			{ label = "Win anyway", clash = fight("The second on the board", "thug", true), win = { strength = 3, money = 150, rep = { rats = -4 }, setFlags = { "sl3_pt_defied" }, goal = "You won a fight you were paid to lose. The Syndicate is angry.", log = "You won in the second round. The owner stopped smiling and started counting." }, lose = { health = { -16, -10 }, goal = "You tried to win. You lost anyway, honestly. Nobody believes that.", log = "You lost honestly. The owner paid you the five hundred anyway, which was worse." } },
			{ label = "Tell the other fighter", result = { charisma = 2, setFlags = { "sl3_pt_told" }, goal = "You told your opponent about the fix. Now you're both in trouble.", log = "He listened, nodded, and shook your hand. \"Then let's both try,\" he said." } },
		},
	}),
	beat(PT, 5, {
		id = "sl3_pt_ox",
		title = "The Ox",
		art = "arena",
		text = "The board says it plainly now: you, and the Ox. Four years unbeaten. He shakes your hand before the bell, gently, and goes to his corner to eat the last of his rice.",
		scene = { set = "hall", title = "The Ox", line = "Good luck. I mean that. Nobody ever does.", other = { name = "The Ox", role = "champion of the pit" } },
		choices = {
			{ label = "Fight the Ox", battle = "the_ox", clash = { stat = "strength", foe = "The Ox, champion of the pit", enemy = "workshop_brute", fight = true, coins = 3, base = 7, coinPower = 4, fixed = true, boss = true, status = { id = "tremor", potency = 2 } }, win = { strength = 4, money = 600, setFlags = { "sl3_pt_champion" }, chronicle = "bl_act_boss_slain", goal = "You beat the Ox. You're the champion of the pit.", log = "He went down like a building, slowly. From the sand he laughed and held up your hand himself." }, lose = { health = { -30, -18 }, cause = "Fought the champion of a fighting pit", goal = "The Ox won. He sat with you until the doctor came.", log = "He was sorry. He kept saying so. He'd hit you exactly as hard as he had to." } },
			{ label = "Outlast him", clash = { stat = "speed", foe = "The Ox, champion of the pit", enemy = "workshop_brute", fight = true, coins = 3, base = 6, coinPower = 4, fixed = true, boss = true }, win = { speed = 4, money = 600, setFlags = { "sl3_pt_champion" }, chronicle = "bl_act_boss_slain", goal = "You outlasted the Ox. You're the champion of the pit.", log = "Twenty-two rounds. He sat down on the sand and couldn't get up, and grinned at you." }, lose = { health = { -26, -16 }, cause = "Fought the champion of a fighting pit", goal = "He caught you once. Once was plenty.", log = "Round nineteen. One punch. You woke up in his corner, eating his rice." } },
			{ label = "Walk out before the bell", result = { mind = 2, sanity = 2, goal = "You walked out of the pit. The crowd threw things. The Ox waved.", log = "You picked up your coat and went up the stairs. Behind you the Ox raised a hand, like he understood." } },
		},
	}),
	beat(PT, 7, {
		id = "sl3_pt_end",
		title = "After the Pit",
		art = "street",
		text = "The cannery is being knocked down for a Workshop. The pit is done. The Ox runs a noodle cart two streets away, and keeps the second stool for you.",
		choices = {
			{ label = "Take the stool", result = { charisma = 2, sanity = 6, storyEnd = "The Second Stool: two old fighters and a noodle cart", log = "He never asks about the fight. You never ask why he lost it, and you're fairly sure he did." } },
			{ label = "Open your own pit", requires = { flags = { "sl3_pt_champion" } }, result = { money = 300, strength = 2, rep = { rats = 4 }, storyEnd = "The New Pit: your rules, your sand, no fixes", log = "Your pit pays from the door and the bell is never late. The crowd is smaller. It's honest." } },
			{ label = "Teach kids to fight", result = { strength = 2, charisma = 2, mind = 1, storyEnd = "The Yard: you teach Backstreets kids the pit's one lesson, keep your feet", log = "Twelve kids, a yard, a rope. You teach them never to fight for anybody's money." } },
		},
	}),

	-- ════ THE HAND-ME-DOWN ═══════════════════════════════════════════════════════
	beat(HD, 0, {
		id = "sl3_hd_will",
		title = "The Will",
		art = "home",
		text = "A great-uncle you barely knew has left you a blade: a Workshop piece, plain, notched along the back. The name engraved on the tang isn't his. It's a famous one, if you know Fixers.",
		choices = {
			{ label = "Find out whose it was", clash = chk("intelligence", "A name thirty years old"), win = { intelligence = 2, setFlags = { "sl3_hd_name" }, goal = "The blade belonged to a Fixer who vanished thirty years ago, with a great many enemies.", log = "A Grade 1, thirty years gone. Your great-uncle was his second, it turns out. Nobody knew." }, lose = { goal = "Nobody will tell you whose name that is. Nobody wants to.", log = "Every Fixer you asked went quiet and changed the subject." } },
			{ label = "Hang it on the wall", result = { mind = 1, goal = "The blade is on your wall. Someone saw it through the window.", log = "It looks well, on the wall. A man in grey stood across the street for a while, looking at it." } },
			{ label = "Carry it", result = { strength = 2, setFlags = { "sl3_hd_carry" }, goal = "You carry a famous blade. People who know blades look twice.", log = "It balances like it was made for your hand. It wasn't. It was made for his." } },
		},
	}),
	beat(HD, 1, {
		id = "sl3_hd_smith",
		title = "The Old Smith",
		art = "workshop",
		text = "The Workshop that made the blade is still open, barely. The smith is very old, and goes pale when you unwrap it. \"I made that for him,\" she says. \"I told him not to take it to the Outskirts.\"",
		choices = {
			{ label = "Ask her to restore it", requires = { min = { money = 120 } }, result = { money = -120, strength = 2, setFlags = { "sl3_hd_restored" }, goal = "The blade is restored, as it was. The smith says that's dangerous.", log = "She worked three days without sleeping. It came back bright, and she wouldn't touch it again." } },
			{ label = "Ask about his enemies", clash = chk("charisma", "An old woman's memory"), win = { charisma = 2, setFlags = { "sl3_hd_warned" }, goal = "He had one enemy who mattered: a man who swore to break that blade.", log = "\"Just one that mattered,\" she said. \"He'll be old now. He won't have forgotten.\"" }, lose = { goal = "She wouldn't say. She asked you to leave.", log = "\"Some things should stay in the Outskirts,\" she said, and closed the shop early." } },
			{ label = "Ask her to break it", result = { mind = 2, sanity = 2, goal = "She wouldn't. \"It's not mine to break. Or yours.\"", log = "She laughed until she coughed. \"Break it? Nothing breaks that. That was the point.\"" } },
		},
	}),
	beat(HD, 3, {
		id = "sl3_hd_seeker",
		title = "The Man in Grey",
		art = "alley",
		text = "The man in grey is waiting in your alley, wearing half a mask. He's been looking for that blade for twenty years. He doesn't want it. He wants it broken, in front of him, by whoever carries it.",
		choices = {
			{ label = "Duel him", clash = { stat = "strength", foe = "The man in grey", enemy = "fixer", fight = true, coins = 3, base = 6, coinPower = 3, fixed = true, status = { id = "bleed", potency = 2 } }, win = { strength = 3, speed = 1, setFlags = { "sl3_hd_beat_seeker" }, goal = "You beat the man in grey. He'll be back. He said so, politely.", log = "He yielded, and bowed, and said he would come back when you were better. He meant it as praise." }, lose = { health = { -20, -12 }, cause = "Lost a duel over an inherited blade", goal = "He beat you, and couldn't break the blade either. He'll be back.", log = "He tried to break it on the cobbles while you watched. It didn't. He left without a word." } },
			{ label = "Ask him why", result = { mind = 2, intelligence = 1, setFlags = { "sl3_hd_story" }, goal = "The blade killed his brother, thirty years ago, on a contract. He wants it gone.", log = "\"My brother,\" he said. \"On a contract. Nothing personal, the Fixer said. It was personal to me.\"" } },
			{ label = "Give him the blade", result = { sanity = 2, mind = 1, setFlags = { "sl3_hd_given" }, goal = "You gave him the blade. He couldn't break it either.", log = "He tried, for an hour, with a hammer. Then he gave it back, and cried, and went home." } },
		},
	}),
	beat(HD, 5, {
		id = "sl3_hd_outskirts",
		title = "Where He Went",
		art = "outskirts",
		text = "There's a map in the hilt, it turns out, scratched in the steel under the wrapping: past the wall, into the Outskirts, a cross by a ruined tower. Where the blade's first owner went, and didn't come back from.",
		choices = {
			{ label = "Follow the map", clash = { stat = "strength", foe = "What lives in the Outskirts", enemy = "beast", fight = true, coins = 3, base = 7, coinPower = 4, fixed = true, boss = true }, win = { strength = 3, mind = 2, setFlags = { "sl3_hd_found" }, goal = "You found the tower, and what he left there: a scabbard, and a letter.", log = "The tower, the cross, a scabbard hanging on a nail. A letter: To whoever carries it. Don't." }, lose = { health = { -30, -18 }, cause = "Followed an old map into the Outskirts", goal = "The Outskirts turned you back, barely alive.", log = "You saw the tower, far off. You never got close. You crawled back through the wall." } },
			{ label = "Burn the map", result = { mind = 2, sanity = 3, goal = "You burned the map. Some places should stay lost.", log = "It took a long time to scratch it out. The steel is smooth there now." } },
			{ label = "Sell the map", result = { money = 400, sanity = -3, goal = "An expedition crew bought the map. You hope they're quick.", log = "Six of them, eager. Four came back. They didn't talk about it." } },
		},
	}),
	beat(HD, 7, {
		id = "sl3_hd_end",
		title = "The Name on the Tang",
		art = "workshop",
		text = "The old smith is dying, and has asked to see the blade one last time. She runs a thumb along the notches, one for each year it's been carried.",
		choices = {
			{ label = "Add your name", result = { strength = 3, gear = "sl3_old_blade", storyEnd = "Two Names on the Tang: his, and under it now, yours", log = "She engraved it herself, slowly, under his. \"He'd have liked you,\" she said." } },
			{ label = "Lay it with her", result = { mind = 3, sanity = 5, storyEnd = "Laid to Rest: the blade went into the ground with the woman who made it", log = "You put it in her hands. It was the right size for them. It always had been." } },
			{ label = "Give it to the man in grey", requires = { flags = { "sl3_hd_story" } }, result = { charisma = 2, sanity = 4, storyEnd = "Settled: you gave the blade to the man whose brother it killed", log = "He held it for a long time, and then hung it on his own wall, where he could see it." } },
		},
	}),

	-- ════ THE LAST STOP ══════════════════════════════════════════════════════════
	beat(LS, 0, {
		id = "sl3_ls_bus",
		title = "The Bus After the Last Bus",
		art = "bus",
		text = "You missed the last bus before the Night by a minute. Then another pulls up, lights on, doors open, empty but for one passenger at the back. The driver smiles. \"Going your way.\"",
		choices = {
			{ label = "Get on", clash = chk("mind", "A bus that runs in the Night", true), win = { mind = 2, sanity = -4, setFlags = { "sl3_ls_rode" }, goal = "The bus took you home. The driver knows your address now.", log = "It stopped outside your door, exactly. \"See you,\" the driver said. You didn't give him your address." }, lose = { sanity = -10, setFlags = { "sl3_ls_rode" }, goal = "You rode the Night bus. It took a long time. You don't remember the route.", log = "You got off at your door at dawn. The ride felt like ten minutes. Your watch says six hours." } },
			{ label = "Walk", clash = chk("speed", "Twenty streets in the Night", true), win = { speed = 2, sanity = -2, goal = "You ran home in the Night and made it. The bus followed, slowly, the whole way.", log = "It drove beside you at walking pace, doors open, the whole way. The driver waved at your door." }, lose = { health = { -16, -8 }, cause = "Caught outside in the Night", goal = "The Night caught you on the way. The bus picked you up after.", log = "Something in an alley. Then the bus, doors open, the driver tutting, helping you up the step." } },
			{ label = "Hide in a doorway", result = { sanity = -5, mind = 1, goal = "You hid till dawn. The bus waited outside the doorway all night.", log = "It idled at the curb until the sky went grey. Then it drove away, politely." } },
		},
	}),
	beat(LS, 1, {
		id = "sl3_ls_passenger",
		title = "The Passenger at the Back",
		art = "bus",
		text = "The bus comes for you whenever you're out late now. The passenger at the back is always there, in a mask. Tonight they move up a row, toward you.",
		choices = {
			{ label = "Talk to them", clash = chk("charisma", "A passenger who's been riding a long time"), win = { charisma = 2, setFlags = { "sl3_ls_talked" }, goal = "The passenger missed the last bus too, a long time ago.", log = "\"I missed the last bus,\" they said. \"In my grandmother's time. It's not so bad. It's very punctual.\"" }, lose = { sanity = -4, goal = "They didn't answer. They moved up another row.", log = "No answer. When you looked again they were a row closer." } },
			{ label = "Get off early", clash = chk("speed", "Doors that don't open early", true), win = { speed = 2, goal = "You got off two streets early. The driver looked hurt.", log = "You pulled the cord and jumped. The driver looked at you in the mirror like you'd been rude." }, lose = { sanity = -6, goal = "The doors didn't open until your stop. They never do.", log = "You pulled the cord eleven times. The bus stopped at your door, as always." } },
			{ label = "Stop going out at night", result = { mind = 2, money = -20, goal = "You're home before the Night, every night. The bus still drives past your window.", log = "It goes past at 3:13. Every night. You've started to wave." } },
		},
	}),
	beat(LS, 3, {
		id = "sl3_ls_route",
		title = "The Route",
		art = "bus",
		text = "Tonight the bus doesn't take you home. It takes a long route, through streets you don't know, past stops where people stand very still, and nobody gets on. The driver hums.",
		choices = {
			{ label = "Make him stop", clash = { stat = "strength", foe = "The night driver", enemy = "passenger", fight = true, coins = 3, base = 6, coinPower = 3, fixed = true }, win = { strength = 3, sanity = -4, setFlags = { "sl3_ls_stopped" }, goal = "You stopped the bus. You walked home in the grey before dawn.", log = "You hauled on the brake. The driver didn't fight, just looked sad. The doors opened on your street." }, lose = { health = { -18, -10 }, sanity = -8, cause = "Fought a driver who drives in the Night", goal = "He was stronger than he looked. The route went on.", log = "He put you back in your seat with one hand, kindly, and drove on." } },
			{ label = "Watch the stops", clash = chk("intelligence", "Stops on no map", true), win = { intelligence = 3, setFlags = { "sl3_ls_map" }, goal = "You've learned the Night bus's route. Everybody waiting at its stops missed a last bus.", log = "Every stop, someone waiting, very still. Every one of them missed the last bus once." }, lose = { sanity = -8, goal = "The route made no sense. It wasn't meant to.", log = "Left, left, left, left. You came out on your own street. That shouldn't be possible." } },
			{ label = "Sit with the passenger", requires = { flags = { "sl3_ls_talked" } }, result = { mind = 2, sanity = -2, setFlags = { "sl3_ls_friend" }, goal = "The passenger told you how to get off for good: you have to want to stay home.", log = "\"You have to want home more than you want to get there,\" they said. You're still thinking about it." } },
		},
	}),
	beat(LS, 5, {
		id = "sl3_ls_ticket",
		title = "A Ticket",
		art = "bus",
		text = "The driver offers you a ticket, at last: a real one, stamped, good forever. With it you'd never have to walk in the Night again. The passenger at the back shakes their head, very slightly.",
		choices = {
			{ label = "Take the ticket", clash = chk("mind", "Forever, punched", true), win = { mind = 3, sanity = -4, setFlags = { "sl3_ls_ticket" }, goal = "You have a ticket for the Night bus. You're not sure what it costs.", log = "It's warm in your pocket. It's never cold, even outside." }, lose = { die = "Took a ticket for the bus after the last bus, and rode it", log = "You took the ticket, and sat down, and the bus pulled away. It still runs. You're on it." } },
			{ label = "Tear it up", result = { mind = 3, sanity = 2, setFlags = { "sl3_ls_free" }, goal = "You tore up the Night bus's ticket. The driver was very upset.", log = "The driver stopped the bus and opened the doors and didn't look at you. You walked home in the Night and nothing touched you." } },
			{ label = "Give it to the passenger", requires = { flags = { "sl3_ls_friend" } }, result = { charisma = 2, sanity = 4, setFlags = { "sl3_ls_freed" }, goal = "You gave the passenger your ticket. They got off, at last.", log = "They took off their mask at the door. They had a kind face, and very old eyes. They walked home." } },
		},
	}),
	beat(LS, 7, {
		id = "sl3_ls_end",
		title = "3:13",
		art = "street",
		text = "It's been years. Some nights, at 3:13, you hear an engine idling outside, very patiently, and then moving on.",
		choices = {
			{ label = "Wave", result = { sanity = 4, mind = 2, storyEnd = "Punctual: the Night bus still comes by, and you still don't get on", log = "The driver waves back. He always does. He's very punctual." } },
			{ label = "Ride it one more time", requires = { flags = { "sl3_ls_ticket" } }, result = { mind = 4, sanity = -5, storyEnd = "Season Ticket: you ride the Night bus, sometimes, and it always brings you back", log = "It always brings you home. One day it won't. You know that. You ride anyway." } },
			{ label = "Warn the street", result = { charisma = 2, sanity = 3, storyEnd = "Home Before the Night: nobody on your street misses the last bus now", log = "You stand at the stop at a quarter to three, every night, and send people home." } },
		},
	}),
}
