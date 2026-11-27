--[[
	SECOND STORIES, the second shelf: four more that can find anyone (Storylines/Second2.luau
	has what each stands on). Same shape as Story_Second.luau: five chapters, counted in years
	from the day the story began (0, 1, 3, 5, 7), and the last has three endings.

	Short on purpose. Checks are `fixed`: your stats decide them, not your age.
	Nothing here names a thing that only exists in one age.
]]

local function chk(stat: string, foe: string, hard: boolean?)
	return { stat = stat, foe = foe, coins = if hard then 2 else 1, base = 3, coinPower = if hard then 2 else 3, fixed = true }
end
local function fight(foe: string, enemy: string, hard: boolean?)
	return { stat = "strength", foe = foe, enemy = enemy, fight = true, coins = 2, base = if hard then 4 else 3, coinPower = 2, fixed = true }
end

local AR, CN, CF, AM = "sl2_the_arm", "sl2_canard", "sl2_company_flat", "sl2_ampoule"

local function beat(story: string, year: number, e)
	e.story = story
	e.always = true
	e.once = true
	e.when = e.when or {}
	e.when.storyYear = year
	return e
end

return {
	-- ════ THE ARM ═══════════════════════════════════════════════════════════════
	beat(AR, 0, {
		id = "sl2_ar_fitting",
		title = "The Fitting",
		art = "workshop",
		text = "An accident took your left hand: a loading shutter, a wet night, nobody's fault. A workshop two streets over makes new ones.",
		choices = {
			{ label = "Buy one on instalments", result = { strength = 2, money = -30, setFlags = { "sl2_ar_debt" }, goal = "You owe a workshop eleven payments on your own arm.", log = "It closes harder than the old one did. The receipt has a serial number, and your name under it." } },
			{ label = "Pay for the good one", requires = { min = { money = 150 } }, result = { strength = 3, money = -150, goal = "The best arm the workshop makes. It's better than the one you were born with.", log = "Paid in full. The owner polished the knuckles herself and walked you to the door." } },
			{ label = "A used one, from a stall", clash = chk("luck", "A stall with no name"), win = { strength = 2, money = -10, setFlags = { "sl2_ar_used" }, goal = "Your arm had an owner before you. It still has their habits.", log = "Cheap, and it works. Some evenings the fingers drum a tune you don't know." }, lose = { strength = 1, money = -10, health = { -4, -2 }, setFlags = { "sl2_ar_used" }, goal = "Your arm had an owner before you. It still has their habits.", log = "Cheap, and it pinches where it joins. Some evenings the fingers drum a tune you don't know." } },
		},
	}),
	beat(AR, 1, {
		id = "sl2_ar_cart",
		title = "What It Can Lift",
		art = "street",
		text = "A cart has gone over in the road with a man's leg under it. Six people can't shift it. Your new arm doesn't know that it can't, either.",
		choices = {
			{ label = "Lift", clash = chk("strength", "A loaded cart"), win = { strength = 1, charisma = 1, sanity = 2, goal = "You lifted a cart off a man. The street knows about the arm now.", log = "It came up like a lid. The man looked at your hand before he looked at his leg." }, lose = { health = { -5, -2 }, goal = "The arm could lift it. The rest of you couldn't.", log = "The arm held. Your shoulder is still the one you were born with, and it told you so." } },
			{ label = "Show them where to push", clash = chk("intelligence", "Six people pushing the wrong way"), win = { intelligence = 1, charisma = 1, goal = "You got a cart off a man, and nobody saw the arm.", log = "\"Not up. Over.\" It went over. Nobody noticed which hand you pointed with." }, lose = { sanity = -2, goal = "They got the cart up in the end, without you.", log = "Nobody listens to someone standing with a hand in a pocket." } },
			{ label = "Keep your hand in your pocket", result = { mind = 1, sanity = -2, goal = "You hid the arm. Someone else got the cart up.", log = "They got it up, in the end. You stood there knowing you could have done it alone." } },
		},
	}),
	beat(AR, 3, {
		id = "sl2_ar_offer",
		title = "The Second Offer",
		art = "workshop",
		text = "The workshop owner turns your wrist over like a jeweller. \"The left's better than the right now. You'll have noticed. I can make them match.\"",
		choices = {
			{ label = "Make them match", requires = { min = { money = 80 } }, result = { strength = 3, money = -80, sanity = -3, setFlags = { "sl2_ar_more" }, goal = "Two arms from a workshop. She has mentioned legs.", log = "You can open a stuck door with two fingers. You can't feel the handle." } },
			{ label = "Ask where it stops", clash = chk("charisma", "A workshop owner's patter"), win = { intelligence = 1, mind = 1, goal = "\"It stops when you run out of money, or out of you.\" Decide which comes first.", log = "She shrugged. \"It stops when you run out of money, or out of you. I've seen both.\"" }, lose = { money = -15, goal = "You went in with a question and came out with a service plan.", log = "You came out with a service plan and no answer." } },
			{ label = "Just the oiling, thanks", result = { mind = 1, sanity = 1, goal = "One arm. You're holding the line there.", log = "She oiled the joint and didn't charge. \"You'll be back,\" she said, kindly enough." } },
		},
	}),
	beat(AR, 5, {
		id = "sl2_ar_gate",
		title = "At the Gate",
		art = "checkpoint",
		text = "At a Nest checkpoint the man ahead of you is all workshop: arms, legs, the plate of his chest. The guard doesn't raise his voice. A full-body job doesn't go through. That's the rule.",
		choices = {
			{ label = "Speak up for him", clash = chk("charisma", "A guard with a rule", true), win = { charisma = 2, sanity = 2, goal = "You argued a man through a gate for an hour. The guard looked at your hand as you left.", log = "\"Visitor's pass. One hour,\" said the guard, and wrote your name down as well." }, lose = { rep = { wings = -2 }, goal = "The rule held. The guard wrote your name down too.", log = "\"And how much of you is original?\" the guard asked. You didn't have a good answer." } },
			{ label = "Ask him if it was worth it", result = { mind = 2, goal = "\"Ask me when I'm cold,\" he said. He never is.", log = "\"Ask me when I'm cold,\" he said. \"I never am. Some mornings I'd like to be.\"" } },
			{ label = "Look at your own hand", result = { intelligence = 1, sanity = -2, goal = "There's a line somewhere between you and him. You don't know where it runs.", log = "You tried to work out where the rule begins. Nobody at the gate could tell you." } },
		},
	}),
	beat(AR, 7, {
		id = "sl2_ar_end",
		title = "What's Yours",
		art = "workshop",
		text = "Seven years of oil and adjustments. The workshop keeps your measurements on a card, all of them, with a pencilled price beside each.",
		choices = {
			{ label = "Stop at what you have", result = { mind = 2, sanity = 4, storyEnd = "This Far: you kept the arm, and everything else you were born with", log = "She tore the card in half and gave you your half. \"Most people don't,\" she said." } },
			{ label = "Book the next fitting", result = { strength = 3, speed = 1, sanity = -4, storyEnd = "Mostly Workshop: stronger every year, and less of you to be strong", log = "Legs in the spring. You're never tired now. You miss it a little, the way you'd miss weather." } },
			{ label = "Have it taken off", result = { mind = 3, sanity = 2, storyEnd = "One-Handed: you gave the arm back, and learned to do without", log = "She unbolted it without a word and set it on the shelf with the others. Your sleeve ties neatly now." } },
		},
	}),

	-- ════ A CANARD ══════════════════════════════════════════════════════════════
	beat(CN, 0, {
		id = "sl2_cn_graded",
		title = "Graded",
		art = "alley",
		text = "Something in the drain on your street takes a crate of fish, then a bicycle. Hana's clerk grades the report without looking up: Canard. No Office gets out of bed for a Canard.",
		choices = {
			{ label = "Pool the street's money", clash = chk("charisma", "Forty neighbours"), win = { charisma = 1, setFlags = { "sl2_cn_fund" }, goal = "The street has a jar with 90 Ahn in it. A Grade 9 might come for that.", log = "A jar on the noodle counter, a list of names on the wall. Ninety Ahn by Friday." }, lose = { goal = "Nobody will pay for a rumour.", log = "\"It's a drain,\" they said. \"Drains make noises.\"" } },
			{ label = "Go and look", clash = chk("speed", "A drain at night"), win = { speed = 1, intelligence = 1, setFlags = { "sl2_cn_seen" }, goal = "You've seen it. It's bigger than a Canard.", log = "Wet, and longer than the drain should hold. It looked back at you." }, lose = { health = { -5, -2 }, sanity = -2, goal = "You went to look at the drain. You came back faster.", log = "You saw the grating lift. You were home before it dropped." } },
			{ label = "Board the drain over", result = { strength = 1, goal = "You nailed boards over the drain. By morning something had stacked them.", log = "Six boards and a box of nails. In the morning they were stacked by the kerb, neatly." } },
		},
	}),
	beat(CN, 1, {
		id = "sl2_cn_nine",
		title = "The Grade Nine",
		art = "street",
		text = "A Grade 9 Fixer takes the job for what the street can pay: new coat, borrowed sword. She goes down at dusk. At dawn she climbs out with half a sword. \"That's no Canard. Tell Hana.\"",
		choices = {
			{ label = "Report it again", clash = chk("intelligence", "A Hana form in triplicate"), win = { intelligence = 1, setFlags = { "sl2_cn_myth" }, goal = "Hana regraded it: Urban Myth. Now it costs more than the street has.", log = "Regraded: Urban Myth. The clerk smiled. \"Good news. Now it's expensive.\"" }, lose = { sanity = -2, goal = "Hana still says Canard.", log = "Wrong form. Then the right form, in the wrong ink. It's still a Canard." } },
			{ label = "Ask her to teach you", result = { strength = 1, speed = 1, goal = "A Grade 9 showed you how to hold what's left of a sword.", log = "\"Feet first,\" she said. \"Everything else is feet.\" She left the half-sword with you." } },
			{ label = "Pay her anyway", requires = { min = { money = 30 } }, result = { money = -30, charisma = 1, rep = { fixers = 3 }, goal = "You paid a Fixer for telling the truth. Word of that gets round.", log = "She tried to give it back twice. Fixers remember who pays when a job goes badly." } },
		},
	}),
	beat(CN, 3, {
		id = "sl2_cn_underpass",
		title = "Under the Road",
		art = "underpass",
		text = "It has moved to the underpass. People who cross after dark come out the far side missing something small: a shoe, a watch, an hour.",
		choices = {
			{ label = "Walk through with a lamp", clash = chk("mind", "The dark under the road", true), win = { mind = 2, setFlags = { "sl2_cn_seen" }, goal = "It doesn't like being looked at. That's worth knowing.", log = "You held the lamp up and didn't look away. It drew back along the wall, slowly, like a tide." }, lose = { sanity = -5, goal = "You crossed the underpass. You're missing an hour.", log = "You remember going in. You remember the far side. Your watch says there was more." } },
			{ label = "Leave something for it", result = { luck = 1, money = -15, setFlags = { "sl2_cn_fed" }, goal = "You left it a crate of fish. It knows your step now.", log = "A crate of fish at the edge of the dark. In the morning the crate was by the wall, empty and upright." } },
			{ label = "Put up a sign and go round", result = { intelligence = 1, sanity = 1, goal = "The street goes the long way now. It adds ten minutes.", log = "UNDERPASS SHUT. Somebody added, in chalk: BY WHAT." } },
		},
	}),
	beat(CN, 5, {
		id = "sl2_cn_office",
		title = "A Real Office",
		art = "street",
		text = "An Office comes at last: three Fixers and a clerk with a clipboard. Their price is the whole jar, and a guide who knows the thing. Everyone on the street looks at you.",
		choices = {
			{ label = "Lead them in", clash = fight("The thing under the road", "drain_thing", true), win = { strength = 2, rep = { fixers = 5 }, setFlags = { "sl2_cn_gone" }, goal = "It's gone. The street is quiet in a way it wasn't before.", log = "It was over quickly, once there were four of you and lamps. The clerk wrote one word." }, lose = { health = { -10, -5 }, setFlags = { "sl2_cn_gone" }, goal = "The Office finished it without you. You saw most of it from the ground.", log = "It went for the one who knew it. They got it off you. The clerk wrote one word." } },
			{ label = "Tell them what it hates", result = { intelligence = 2, setFlags = { "sl2_cn_driven" }, goal = "They drove it off with lamps. It went down the main sewer, toward someone else's street.", log = "Lamps, held steady, no shouting. It left by the main sewer. That's another street's drain." } },
			{ label = "Send them home", clash = chk("charisma", "An Office that's been paid", true), win = { charisma = 2, money = 40, setFlags = { "sl2_cn_fed" }, goal = "You sent the Office home. The thing under the road is the street's now.", log = "\"On your head,\" the clerk said, and gave back half the jar." }, lose = { setFlags = { "sl2_cn_driven" }, goal = "They went in anyway. It left by the main sewer.", log = "They'd been paid. They went in with lamps, and it left by the main sewer." } },
		},
	}),
	beat(CN, 7, {
		id = "sl2_cn_end",
		title = "On the Books",
		art = "office",
		text = "Hana's clerk has the file open at the last page. It wants one line and a signature, and the street has decided both are yours.",
		choices = {
			{ label = "Write \"Closed\"", result = { strength = 1, intelligence = 2, sanity = 3, storyEnd = "Case Closed: a Canard that cost one street its savings, written off in a line", log = "One line. The clerk blotted it and reached for the next file. It was thicker." } },
			{ label = "Write \"Open, under watch\"", result = { mind = 3, rep = { fixers = 4 }, storyEnd = "The Watch: you took a lamp down to the underpass every night, in case", log = "Every night, a lamp, ten minutes. Nothing has come. That's what a watch is for." } },
			{ label = "Write \"No such thing\"", result = { luck = 2, charisma = 1, sanity = 4, storyEnd = "No Such Thing: the file says nothing was ever under the road. You leave fish out on Fridays anyway", log = "The file says there was never anything there. You leave a crate out on Fridays all the same." } },
		},
	}),

	-- ════ THE COMPANY FLAT ══════════════════════════════════════════════════════
	beat(CF, 0, {
		id = "sl2_cf_notice",
		title = "The Notice",
		art = "nest",
		text = "A notice under every door on your floor: the Wing is \"reviewing residency\". Everyone knows what it means. Nobody says it in the lift.",
		choices = {
			{ label = "Read the small print", clash = chk("intelligence", "Nine pages of small print"), win = { intelligence = 1, setFlags = { "sl2_cf_knows" }, goal = "One flat in five on your floor will be emptied by spring. Find out how they choose.", log = "Page seven: one in five. Page eight: the criteria, which are blank." }, lose = { sanity = -2, goal = "Your Wing is deciding who stays in the Nest.", log = "You read it three times. It says nothing, at length." } },
			{ label = "Ask the floor warden", clash = chk("charisma", "A warden who likes being asked"), win = { charisma = 1, setFlags = { "sl2_cf_knows" }, goal = "One flat in five on your floor will be emptied by spring. Find out how they choose.", log = "\"One in five,\" the warden said, pleased to know. \"I couldn't say which.\"" }, lose = { goal = "Your Wing is deciding who stays in the Nest.", log = "\"I'm sure it doesn't concern people like you,\" the warden said, and made a note." } },
			{ label = "Be seen being useful", result = { charisma = 1, sanity = -2, goal = "You're being useful where the warden can see.", log = "So is everyone else. The stairs have never been so well swept." } },
		},
	}),
	beat(CF, 1, {
		id = "sl2_cf_boxes",
		title = "The Neighbour's Boxes",
		art = "nest",
		text = "The family across the hall is carrying boxes to the lift. Their door plate is already unscrewed. The father asks if you'd sign a paper saying he was a good neighbour.",
		choices = {
			{ label = "Sign it", result = { charisma = 1, sanity = 2, rep = { wings = -2 }, setFlags = { "sl2_cf_signed" }, goal = "You signed for a neighbour the Wing has finished with. That's on file now.", log = "He folded it into his coat like money. It won't help him. You both knew, and you signed." } },
			{ label = "Carry boxes instead", result = { strength = 1, sanity = -1, goal = "You carried their boxes and didn't sign.", log = "Eleven boxes. At the lift he shook your hand and didn't ask again." } },
			{ label = "Close your door", result = { mind = 1, sanity = -3, goal = "You closed your door. You can still hear the lift.", log = "You stood behind the door until the lift went down. It took four trips." } },
		},
	}),
	beat(CF, 3, {
		id = "sl2_cf_review",
		title = "The Review",
		art = "wing",
		text = "Your turn. A reviewer with a soft voice has your whole file. She asks, pleasantly, what you would say you are for.",
		choices = {
			{ label = "Give her numbers", clash = chk("intelligence", "A reviewer with your file", true), win = { intelligence = 2, setFlags = { "sl2_cf_kept" }, goal = "You passed the review. The flat is yours until the next one.", log = "She checked each figure against her own. They matched. She seemed faintly disappointed." }, lose = { sanity = -3, setFlags = { "sl2_cf_warned" }, goal = "You're on notice. Two years to become worth a flat.", log = "\"Those are last year's,\" she said gently, and ticked a box." } },
			{ label = "Make her like you", clash = chk("charisma", "A reviewer with your file", true), win = { charisma = 2, setFlags = { "sl2_cf_kept" }, goal = "You passed the review. The flat is yours until the next one.", log = "By the end she'd told you which floor not to move to. That's worth more than the tick." }, lose = { sanity = -3, setFlags = { "sl2_cf_warned" }, goal = "You're on notice. Two years to become worth a flat.", log = "She smiled the whole way through. She smiles at everyone." } },
			{ label = "Tell her the truth", clash = chk("mind", "A reviewer with your file", true), win = { mind = 2, setFlags = { "sl2_cf_kept" }, goal = "You told the reviewer you didn't know what you were for. She kept you.", log = "\"I don't know,\" you said. She wrote for a long time. \"Nobody's said that today.\"" }, lose = { sanity = -4, setFlags = { "sl2_cf_warned" }, goal = "You're on notice. Two years to become worth a flat.", log = "\"I don't know,\" you said. \"No,\" she agreed, and ticked a box." } },
		},
	}),
	beat(CF, 5, {
		id = "sl2_cf_upstairs",
		title = "Somebody Else's Flat",
		art = "nest",
		text = "A flat two floors up has come free. Bigger than yours, with a window on the lit side. You know whose it was. The warden says it's yours if your name goes down today.",
		choices = {
			{ label = "Put your name down", result = { charisma = 1, money = 40, sanity = -4, setFlags = { "sl2_cf_took" }, goal = "You moved into a flat you watched someone lose.", log = "Their curtain hooks are still up. You've left them. You're not sure why." } },
			{ label = "Stay where you are", result = { mind = 2, sanity = 1, goal = "You turned down the bigger flat. The warden made a note of that too.", log = "\"Suit yourself,\" said the warden. It was gone by evening." } },
			{ label = "Ask where they went", clash = chk("intelligence", "An address nobody kept"), win = { intelligence = 1, mind = 1, setFlags = { "sl2_cf_found" }, goal = "They're in the Backstreets by the checkpoint, where they can still see the lights.", log = "Second street past the checkpoint. From their window you can see your floor." }, lose = { sanity = -2, goal = "Nobody kept an address for them. Nobody does.", log = "\"We don't keep those,\" said the warden. \"What would we do with them?\"" } },
		},
	}),
	beat(CF, 7, {
		id = "sl2_cf_end",
		title = "Residency",
		art = "checkpoint",
		text = "Another notice under the door, seven years after the first. You know the wording by heart now. You also know the way to the checkpoint.",
		choices = {
			{ label = "Keep your head down", result = { intelligence = 2, money = 150, sanity = -2, storyEnd = "A Good Tenant: you kept the flat by never once being the one they noticed", log = "You've outlasted three wardens. None of them could have told you apart from the door." } },
			{ label = "Stand for floor warden", result = { charisma = 3, mind = 1, storyEnd = "The Warden: you took the job of choosing, so that someone on the floor would do it kindly", log = "You keep the forwarding addresses now. It's against the rules. There's a drawer of them." } },
			{ label = "Hand the key back", result = { side = "backstreets", mind = 3, sanity = 5, storyEnd = "Past the Gate: you gave the key back before anyone asked for it", log = "The guard checked the form twice. Nobody hands one in. The street outside was dark, and it was yours." } },
		},
	}),

	-- ════ THE AMPOULE ═══════════════════════════════════════════════════════════
	beat(AM, 0, {
		id = "sl2_am_hands",
		title = "The Stitcher's Hands",
		art = "clinic",
		text = "The stitcher who has sewn up half your street put both hands through a window, getting a neighbour out of a fire. One K Corp ampoule would mend them. It costs what she earns in four years.",
		choices = {
			{ label = "Start a collection", clash = chk("charisma", "A street with nothing spare"), win = { charisma = 1, setFlags = { "sl2_am_fund" }, goal = "The street has 140 Ahn towards an ampoule. It costs 900.", log = "Everyone she ever stitched put in. That's most of the street. It came to 140." }, lose = { sanity = -1, goal = "An ampoule costs 900 Ahn. The street has kind words.", log = "Everyone was very sorry. Sorry doesn't cost anything." } },
			{ label = "Ask what else there is", clash = chk("intelligence", "Backstreet medicine"), win = { intelligence = 1, setFlags = { "sl2_am_copy" }, goal = "There are copies: workshop-made, a tenth of the price. Nobody will say what's in them.", log = "A tenth of the price, from a stall by the market. The man who told you wouldn't use one himself." }, lose = { goal = "An ampoule costs 900 Ahn. If there's a cheap way, nobody will tell you.", log = "\"There's K Corp's, and there's hoping,\" the other stitcher said." } },
			{ label = "Sit with her", result = { mind = 1, sanity = 1, setFlags = { "sl2_am_learning" }, goal = "She's teaching you to stitch, since she can't. \"In case,\" she says.", log = "She can't hold the needle, so she talks, and you hold it. Your first seam was a disgrace." } },
		},
	}),
	beat(AM, 1, {
		id = "sl2_am_stall",
		title = "A Tenth of the Price",
		art = "market",
		text = "A stall sells ampoules with the K Corp mark printed slightly crooked. The seller swears by them. He would.",
		choices = {
			{ label = "Buy one", requires = { min = { money = 90 } }, clash = chk("luck", "A crooked label", true), win = { money = -90, charisma = 1, setFlags = { "sl2_am_better" }, goal = "The copy worked, more or less. She can hold a cup. Not a needle.", log = "Her left hand closes now. The right one shakes. \"Better than it was,\" she says, and means it." }, lose = { money = -90, sanity = -3, goal = "The copy was coloured water. You paid 90 Ahn for it.", log = "Coloured water. She thanked you anyway, which was the worst part." } },
			{ label = "Have it tested first", clash = chk("intelligence", "A workshop chemist"), win = { intelligence = 1, money = -10, goal = "It's coloured water. You saved 90 Ahn and bought nothing.", log = "The chemist held it to the light and laughed. \"I can sell you that by the bucket.\"" }, lose = { money = -10, goal = "The chemist couldn't tell. Nor can you.", log = "\"Might be. Might not,\" said the chemist, and charged you for the opinion." } },
			{ label = "Walk on", result = { mind = 1, goal = "Real or nothing. 900 Ahn.", log = "He called a lower price after you. Then a lower one." } },
		},
	}),
	beat(AM, 3, {
		id = "sl2_am_counter",
		title = "District 11",
		art = "wing",
		text = "K Corp's counter is as clean as a plate. The clerk is kind. The price is the price. There's a staff rate, if you'd like an application form.",
		choices = {
			{ label = "Pay what you have, ask for credit", requires = { min = { money = 150 } }, clash = chk("charisma", "A kind clerk with a fixed price", true), win = { money = -150, charisma = 1, setFlags = { "sl2_am_real" }, goal = "You have a real ampoule, and a payment book from K Corp.", log = "She went to ask someone. She came back with a form, an ampoule and a payment book." }, lose = { goal = "K Corp doesn't give credit to your address.", log = "She was so sorry. She had a leaflet about saving." } },
			{ label = "Take the form", result = { intelligence = 1, setFlags = { "sl2_am_form" }, goal = "A K Corp job would get the staff rate. It would also get you.", log = "Nine pages. Question four asks how you feel about confidentiality." } },
			{ label = "Try the loading dock", clash = fight("K Corp's dock staff", "kcorp_staff", true), win = { speed = 2, rep = { wings = -6 }, setFlags = { "sl2_am_real" }, goal = "You have a real ampoule. K Corp counts its crates.", log = "One ampoule, off the dock and out of the gate, with two of them behind you as far as the checkpoint." }, lose = { health = { -8, -4 }, rep = { wings = -3 }, goal = "K Corp's dock staff don't give credit either.", log = "They were very quick, and they didn't call anyone. They didn't need to." } },
		},
	}),
	beat(AM, 5, {
		id = "sl2_am_docker",
		title = "The Docker at Number Nine",
		art = "clinic",
		text = "A docker is carried in off the scaffolding with his arm badly cut. The stitcher can't hold a needle. She looks at you. \"I'll talk. You sew.\"",
		choices = {
			{ label = "Sew, the way she tells you", clash = chk("intelligence", "Her voice and your hands", true), win = { intelligence = 2, sanity = 2, setFlags = { "sl2_am_sewed" }, goal = "You sewed a man up with her voice in your ear. He'll work again.", log = "\"Smaller. Smaller. There.\" Forty stitches. She checked every one and found two to complain about." }, lose = { sanity = -4, goal = "Your hands shook too much. She finished it herself, and it cost her.", log = "She took the needle off you with what's left of her hands. Nobody could watch her do it." } },
			{ label = "Use the ampoule on him", requires = { flags = { "sl2_am_real" } }, result = { charisma = 2, sanity = 2, clearFlags = { "sl2_am_real" }, setFlags = { "sl2_am_gave" }, goal = "The ampoule went to a docker with three children. She told you to.", log = "\"Him,\" she said, before you'd asked. His arm closed like a book. Her hands didn't." } },
			{ label = "Keep it for her", requires = { flags = { "sl2_am_real" } }, result = { mind = 1, sanity = -3, clearFlags = { "sl2_am_real" }, setFlags = { "sl2_am_better", "sl2_am_whole" }, goal = "Her hands are whole. She hasn't thanked you for it.", log = "You used it on her while she was still arguing. She sewed him up herself, perfectly, and didn't speak to you for a month." } },
			{ label = "Run for the other stitcher", clash = chk("speed", "Nine streets"), win = { speed = 1, goal = "You fetched the stitcher from nine streets over. She charged double.", log = "Nine streets there, nine back, carrying her bag. She charged double and did half as neat a job." }, lose = { sanity = -3, goal = "The other stitcher was out. The docker kept the arm. Just.", log = "Out on a call. By the time you got back she'd done it herself, with her hands like that." } },
		},
	}),
	beat(AM, 7, {
		id = "sl2_am_end",
		title = "The Clinic",
		art = "clinic",
		text = "The stitcher is pulling the clinic's shutter down for the night, slowly, with the heels of her hands. She says the street will want somebody, after her.",
		choices = {
			{ label = "Take up the needle", result = { intelligence = 2, charisma = 1, sanity = 3, storyEnd = "The Street's Stitcher: her hands gave out, and yours had learned", log = "She sits by the door and criticises. Your seams are nearly as small as hers were." } },
			{ label = "Keep the jar going", result = { charisma = 2, luck = 1, sanity = 2, storyEnd = "The Jar: a street that saves, ten Ahn at a time, for the next ampoule", log = "It's on the noodle counter, with a lid. It'll be years. It's the street's, and nobody has touched it." } },
			{ label = "Fill in K Corp's form", result = { career = "kcorp", intelligence = 1, sanity = -3, storyEnd = "Staff Rate: you went to work for the people who set the price", log = "Staff rate is a third off. You bought hers in your second year. Question four still applies." } },
		},
	}),
}
