--[[
	PEOPLE AND THE PARTY (BitLeveling: ORIGINAL GAME CONTENT, run by Engine/Party.luau).

	Everyone a life meets can be bonded with: family, friends, the neighbour two floors down,
	the Hunters from the raid team, the survivors of a break, the guild you found, the
	Association's technicians, the saga's own people. And up to four of them can be asked to
	follow you into the Gates, as your party. They say yes or no in their own words.

	What's here (Spec.luau plugs it in; nothing here is canon):
		interactions   what you can do with one person: talk, share a meal, ask about their
		               past, train together, spar, give a gift, raid a Gate together, ask to be
		               friends, ask them to join your party, part ways (spec.people.interactions)
		met            who a life meets in this world (spec.people.met: acquaintances)
		party          the party's rules and words (pack.party): gifts, likes, the lines people
		               say by personality, the backstories people are made of, the cast of
		               people the saga cards introduce, and which card introduces whom
		cards          the party's own cards: a memorial, a betrayal, someone leaving or asking
		               to join (spec.events)

	Canon characters never join anyone's party and are never in this file: the cast below are
	the game's own people, in the game's own stories. Children are never asked into a party
	(nobody under 16 is), and nobody in it is hurt on the page in any detail.
]]

local HW = require(script.Parent.Parent.Parent:WaitForChild("Engine"):WaitForChild("HunterWorld"))

local RANKS = HW.RANKS
local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }

local M = {}

-- ── what you do with one person ────────────────────────────────────────────
-- (`party` names what Engine/Party does with it; `sort` puts it after the kit's own)
M.interactions = {
	-- the kit's evening together, as a talk: you learn what they like, and sometimes they say so
	spend_time = {
		name = "Talk",
		desc = "Ask {rel} how they really are, and listen to the answer. You might learn what they like.",
		party = "talk",
		cooldown = 1,
		result = { bond = { 5, 10 }, sanity = { 1, 3 }, log = "You and {rel} talked for an hour about everything and nothing." },
		logs = {
			mother = "You sat with your mother, {rel}, while she watched the Gate report and told you which reporters she trusts.",
			father = "You walked your father, {rel}, to the corner shop and back. He told the story about the first Gates he always tells. You let him.",
			sibling = "You and {rel} stayed up arguing about which guild would take the next big raid, like you were kids again.",
			child = "You took {rel} out for something sweet and let them tell you everything about their week.",
			friend = "You and {rel} sat on the riverside steps and talked until the street lamps came on.",
			mentor = "{rel} walked you through an old raid report and told you which parts were true.",
			rival = "You and {rel} called an uneasy truce over coffee. It held, mostly.",
			acquaintance = "You and {rel} got talking properly for the first time. You have more in common than a street.",
		},
	},
	bl_meal = {
		name = "Share a meal",
		desc = "Your treat: a barbecue place, a noodle stall, somewhere with a table between you. People say more over food.",
		party = "meal",
		sort = 6.1,
		cost = 1,
		cooldown = 1,
		minAge = 10,
		result = { bond = { 6, 12 }, sanity = { 2, 4 }, log = "You and {rel} ate far too much and talked about nothing that mattered, which mattered." },
		logs = {
			mother = "You took your mother, {rel}, to the place she likes and she ordered for both of you, like always.",
			father = "You and your father, {rel}, shared a grill and argued about whether the meat was done.",
			sibling = "You and {rel} split a plate of dumplings and fought over the last one.",
			friend = "You and {rel} found a stall by the river and ate standing up, laughing at something you've both already forgotten.",
			mentor = "{rel} ate slowly and told you about the first raid team they ever led, and what happened to it.",
			rival = "You and {rel} ate in silence for a while, and then not.",
			acquaintance = "You and {rel} shared a table at the noodle shop and found out you grew up four streets apart.",
		},
	},
	bl_past = {
		name = "Ask about their past",
		desc = "Some things people only tell you when you're close enough.",
		party = "past",
		sort = 6.2,
		minAge = 12,
		relMinAge = 14,
		cooldown = 1,
		result = { bond = { 2, 4 }, log = "{rel} told you something they don't tell many people." },
	},
	bl_train = {
		name = "Train together",
		desc = "A morning at the gym or along the river path. You'll pick up what they're good at.",
		party = "train",
		sort = 6.3,
		minAge = 12,
		relMinAge = 12,
		relMaxAge = 70,
		cooldown = 1,
		result = { bond = { 3, 6 }, sanity = { 0, 2 }, log = "You and {rel} trained until neither of you could lift your arms." },
	},
	bl_spar = {
		name = "Spar",
		desc = "Hunter against Hunter in the Association's practice hall. Nobody gets hurt on purpose.",
		party = "spar",
		hunter = true,
		sort = 6.4,
		minAge = 16,
		relMinAge = 16,
		relMaxAge = 64,
		cooldown = 1,
		-- (the clash is this person's own numbers: Engine/Party.optionFor)
		clash = { stat = "strength", foe = "{rel}", coins = 2, base = 4, coinPower = 3, fixed = true },
		win = { bond = { 3, 6 }, strength = { 1, 2 }, agility = { 0, 1 }, log = "You put {rel} on the mat twice. They laughed the second time and asked for a third." },
		lose = { bond = { 2, 4 }, willpower = { 0, 1 }, sanity = -1, log = "{rel} put you on the mat so fast you didn't see it. They helped you up and showed you how." },
	},
	bl_gift = {
		name = "Give a gift",
		desc = "Something they'd like, if you know what that is. Something they can't stand, if you guess wrong.",
		party = "gift",
		sort = 6.5,
		minAge = 8,
		result = { bond = { 3, 8 }, log = "You gave {rel} a gift." },
	},
	bl_raid = {
		name = "Raid a Gate together",
		desc = "Buy the rights to a small Gate between the two of you and clear it.",
		party = "raid",
		hunter = true,
		sort = 6.6,
		minAge = 16,
		relMinAge = 16,
		relMaxAge = 64,
		cooldown = 1,
		-- (the Gate is the weaker of the two of you: Engine/Party.optionFor)
		clash = { stat = "strength", foe = "A Gate's monsters", coins = 2, base = 4, coinPower = 3, fight = true, fixed = true, party = { rank = 1, kind = "raid" } },
		win = { sanity = 1, strength = { 1, 2 }, bond = { 5, 9 }, log = "You and {rel} cleared it before lunch and sold the crystals on the way home." },
		lose = { sanity = -4, bond = { 1, 3 }, log = "It went wrong in the second chamber. {rel} got you out.", cause = "Killed raiding a Gate with a friend" },
	},
	bl_befriend = {
		name = "Ask to be friends",
		desc = "You've been more than strangers for a while now. Say so.",
		kinds = { "acquaintance" },
		minBond = 45,
		sort = 6.7,
		result = { befriend = true, bond = { 4, 8 }, sanity = 2, log = "You told {rel} you were glad you'd met. They said, 'Took you long enough.' Friends, then." },
	},
	bl_ask = {
		name = "Ask them to join your party",
		desc = "Up to four people can follow you into the Gates. They'll say yes or no, and mean it.",
		party = "ask",
		member = false,
		sort = 6.8,
		minAge = 16,
		relMinAge = 16,
		cooldown = 1,
		result = { log = "You asked {rel} to join your party." },
	},
	bl_dismiss = {
		name = "Part ways",
		desc = "Let them leave the party, on good terms if you can.",
		party = "dismiss",
		member = true,
		sort = 6.9,
		actions = 0,
		result = { log = "You and {rel} parted ways." },
	},
}

-- ── who a life meets (acquaintances: spec.people.met) ──────────────────────────
-- (rank: 0 for someone who never awakened, a letter, a { low, high } range, or "near" yours)
M.met = {
	{ text = "a neighbour from two floors down" },
	{ text = "the family across the landing's eldest", when = { minAge = 12 } },
	{ text = "a kid from the next apartment", when = { maxAge = 15 } },
	{ text = "someone from your class", when = { maxAge = 17 } },
	{ text = "a classmate whose older sister is a Hunter", when = { minAge = 9, maxAge = 17 } },
	{ text = "someone you sat next to in the school's Gate drill", when = { minAge = 8, maxAge = 17 } },
	{ text = "the owner of the convenience store on your corner", when = { minAge = 12 }, rank = 0, age = { 35, 64 }, work = "Runs the corner shop" },
	{ text = "a regular at the noodle shop you eat at", when = { minAge = 16 } },
	{ text = "a delivery rider who knows every shortcut in the district", when = { minAge = 16 }, rank = 0, work = "Delivery rider" },
	{ text = "someone from the Gate-injury ward's waiting room", when = { minAge = 16 } },
	{ text = "a volunteer from the district's shelter", when = { minAge = 16 } },
	{ text = "a coworker", when = { anyCareer = true } },
	{ text = "a coworker who eats lunch alone", when = { anyCareer = true } },
	{ text = "a porter on your collection crew", when = { career = "collection_crew" }, rank = 1, work = "Porter" },
	{ text = "a raider you keep seeing on the public raid board", when = { career = "freelance_hunter" }, hunter = true, rank = "near" },
	{ text = "a colleague from the guild's strike team", when = { career = { "guild_hunter", "elite_guild" } }, rank = "near", work = "Guild Hunter" },
	{ text = "a guild officer who noticed you at a briefing", when = { career = { "guild_hunter", "elite_guild" } }, rank = { 4, 5 }, age = { 32, 50 }, work = "Guild officer" },
	{ text = "a measurement technician from the Association branch", when = { career = { "assoc_staff", "assoc_surveillance" } }, rank = 0, work = "Gate measurement technician" },
	{ text = "an agent from the Surveillance Team", when = { career = { "assoc_staff", "assoc_surveillance" } }, rank = { 3, 5 }, work = "Surveillance Team agent" },
	{ text = "an officer from your precinct", when = { career = "police" }, rank = 0, work = "Police officer" },
	{ text = "a paramedic from the next ambulance crew", when = { career = "paramedic" }, rank = 0, work = "Paramedic" },
	{ text = "a Hunter you keep seeing at the gym", when = { minAge = 16, form = HUNTERS }, rank = "near" },
	{ text = "a Healer who patched you up after a raid", when = { minAge = 16, form = HUNTERS }, rank = "near", class = "healer" },
	{ text = "a rookie who asked you about their first raid", when = { minAge = 18, form = HUNTERS }, rank = { 1, 2 }, age = { 18, 24 } },
	{ text = "a retired Hunter who runs the gym on your street", when = { minAge = 16 }, rank = { 2, 4 }, age = { 52, 66 }, work = "Retired Hunter, runs a gym" },
	{ text = "an Association clerk who processes licences", when = { minAge = 16, form = HUNTERS }, rank = 0, work = "Association clerk" },
	{ text = "a crystal trader who works the tape at Gates", when = { minAge = 18 }, rank = 0, work = "Crystal trader", traits = { "greedy" } },
}

-- ── the party's words ─────────────────────────────────────────────────────
-- what people say (Engine/Party.line): the roster's own lines first, else these by
-- personality ({first} is you)
local LINES = {
	greet = {
		any = { "Good to see you, {first}.", "You look tired. Gate work?", "Sit down, sit down. Have you eaten?" },
		brave = { "Heard there's a C-rank open by the river. Just saying.", "If you're ever going somewhere nobody else will, call me first." },
		cautious = { "Did you check the break forecast before you came out? I always check.", "You're in one piece. Good. Keep it that way." },
		greedy = { "Crystal prices are up three percent. I check every morning.", "If you hear about a Gate nobody's bid on yet, I owe you a coffee." },
		loyal = { "Whatever it is, I'm on your side. Then you can tell me what it is.", "I kept the evening free. I always keep it free for you." },
		proud = { "I cleared two Gates this week. You?", "Don't tell anyone you saw me tired." },
		kind = { "Did you eat? You never eat when you're worried.", "I brought the spare umbrella. It's going to rain." },
		reckless = { "I went into a Gate with no Healer yesterday. It was fine! Mostly.", "Life's short. Gates are shorter." },
		cold = { "...You're here.", "Say what you came to say." },
		cheerful = { "{first}! I was just thinking about you!", "Guess what I found at the night market. No, guess." },
		ambitious = { "One more good raid and the big guilds start calling. Watch.", "I'm going to be on the news one day. For the right reasons." },
		honest = { "I'll be straight with you: you look terrible. What happened?", "I don't do small talk. How are you, really?" },
		scheming = { "Funny running into you. Funny how that keeps happening.", "I hear things. Some of them are even about you." },
	},
	accept = {
		any = { "Yeah. Yeah, I'm in.", "I thought you'd never ask." },
		brave = { "Finally. Point me at something big.", "I go in first. That's the deal." },
		cautious = { "...All right. But we do it properly: briefings, exits, a Healer.", "I'll come. And I'll be the one who says when we leave." },
		greedy = { "For that share? Done.", "Pay on time and I'm yours." },
		loyal = { "You didn't even have to ask. But I'm glad you did.", "Wherever you go in, I go in." },
		proud = { "Fine. Try to keep up.", "I'll join. Don't make me regret it." },
		kind = { "Someone has to make sure you come home. Okay.", "I'm in. Promise me we look after each other." },
		reckless = { "Yes! When do we start? Today? Let's start today.", "Finally, something interesting." },
		cold = { "Fine.", "...I'll come." },
		cheerful = { "A party! We need a name. And matching jackets.", "Oh, this is going to be so good." },
		ambitious = { "Your name and mine on the same raid reports? I like the sound of that.", "This is a step up. For both of us." },
		honest = { "I'll join. I'll also tell you when you're wrong. That's the deal.", "Yes. No conditions, no secrets." },
		scheming = { "Of course. Partners.", "I'd be delighted. Really." },
	},
	refuse = {
		any = { "I'm sorry. I can't.", "Not right now. Ask me again some other time." },
		brave = { "Not with this lot. I'd end up carrying the whole raid.", "When you're ready to go first, ask me again." },
		cautious = { "Your last few Gates... no. I want to live to be old.", "I've seen what happens to parties like yours. No." },
		greedy = { "The money's not there. Come back when it is.", "Guild contracts pay better. Sorry, it's business." },
		loyal = { "I've got people relying on me already. I don't leave them.", "Ask me when I know you better. Then I'll never leave." },
		proud = { "Follow you? You'd be following me.", "I don't take orders from someone I outrank." },
		kind = { "I can't, I'm sorry. My family needs me in one piece.", "Please don't be upset. It's not you." },
		reckless = { "Your raids sound boring. No offence.", "I want somewhere wilder than that." },
		cold = { "No.", "Not interested." },
		cheerful = { "Oh no, I hate saying no! But no. Sorry!", "Maybe next year? I'm swamped!" },
		ambitious = { "I've got bigger offers on the table. No hard feelings.", "When your name opens more doors than mine, call me." },
		honest = { "Honestly? I don't think you're ready to lead. Not yet.", "No. I'd rather tell you that now than let you down later." },
		scheming = { "Hmm. What's in it for me, exactly? Think about it and come back.", "Let me keep my options open." },
	},
	battle = {
		any = { "That's how it's done.", "Everyone still on their feet? Good." },
		brave = { "Did you see that? Again! Let's go again!", "First in, last out. That's us." },
		cautious = { "We got lucky on the left. Next time we cover it.", "Everyone check yourselves. All of you." },
		greedy = { "Look at the size of that crystal.", "Count it twice. Then count it again." },
		loyal = { "I had your back. I'll always have your back.", "We did that together." },
		proud = { "You're welcome.", "Not bad. For you." },
		kind = { "Is anyone hurt? Let me see.", "We all came out. That's what matters." },
		reckless = { "Ha! Was that it? I'd barely started!", "Next one, a rank up. Come on." },
		cold = { "Done.", "...Adequate." },
		cheerful = { "We were amazing. We were amazing!", "Group photo! Come on, everyone in!" },
		ambitious = { "That'll look good on the report.", "A few more like that and the Association will know our name." },
		honest = { "We won, but you rushed the door. Let's talk about it.", "Good fight. Not perfect." },
		scheming = { "Interesting how that boss dropped exactly what we needed.", "I'll handle the paperwork. Leave it to me." },
	},
	hurt = {
		any = { "I'm fine. I'm fine. Just give me a minute.", "Go on. I'll catch up." },
		brave = { "It's a scratch. Let's keep going.", "Don't you dare carry me out." },
		cautious = { "I told you. I told you that corridor was wrong.", "Get me to the Healer. Please." },
		greedy = { "Who's paying for the Healer? Not me.", "This had better be worth it." },
		loyal = { "You'd better be okay. Are you okay?", "Leave me if you have to. Don't leave the others." },
		proud = { "Don't look at me like that.", "This never happened." },
		kind = { "Is everyone else all right?", "Tell my family I'm fine. Even if I'm not." },
		reckless = { "Ha... that one hurt. Worth it.", "Next time I'll dodge. Probably." },
		cold = { "...It's nothing.", "Keep moving." },
		cheerful = { "Ow. Okay. I'm still smiling, see?", "At least I get a cool scar out of it." },
		ambitious = { "I can't be out for long. Not now.", "This sets me back months." },
		honest = { "That was my fault. I wasn't watching.", "It's bad. I won't pretend it isn't." },
		scheming = { "Remember who took that hit for the party.", "I'll be fine. I always land on my feet." },
	},
	farewell = {
		any = { "Take care of yourself out there.", "It was good. All of it. Thank you." },
		brave = { "Don't stop going in first. Promise me.", "If you ever need a front line, call." },
		cautious = { "Please be careful. I mean it.", "I'll sleep better. I'm sorry." },
		greedy = { "Business is business. No hard feelings.", "If the pay ever changes, you know my number." },
		loyal = { "I'll always come if you call. Always.", "This doesn't end anything." },
		proud = { "You'll miss me. Everyone does.", "I outgrew this. You'll understand one day." },
		kind = { "Eat properly. Sleep. Call your family.", "I'm going to worry about you anyway." },
		reckless = { "See you in the next Gate, maybe!", "It was fun while it lasted!" },
		cold = { "Goodbye.", "...Stay alive." },
		cheerful = { "This isn't goodbye! We're getting dinner next week!", "I'm going to cry. I'm already crying." },
		ambitious = { "The next time you see my name, it'll be on the news.", "This is where our paths split. For now." },
		honest = { "It's the right thing. For both of us.", "I don't regret a day of it." },
		scheming = { "Until next time, partner.", "Funny how things work out." },
	},
	gift = {
		any = { "You remembered! I can't believe you remembered.", "Oh. Oh, this is perfect." },
		brave = { "Ha! You know me too well.", "I'll take this into the next Gate with me." },
		cautious = { "You didn't have to... but thank you.", "I'll keep it somewhere safe." },
		greedy = { "Now that's a gift. You can visit more often.", "Is this real? This is real." },
		loyal = { "I'll keep it forever. I mean that.", "This means more than you know." },
		proud = { "...I suppose it's acceptable. Thank you.", "Hm. Good taste. Surprising." },
		kind = { "You're too kind to me. Come here.", "I'm going to think of you every time I use it." },
		reckless = { "Brilliant! Can I use it right now?", "Best. Gift. Ever." },
		cold = { "...Thank you.", "Hm. It's good." },
		cheerful = { "I love it. I love it so much!", "Oh my gosh. You're the best." },
		ambitious = { "This is exactly what I needed.", "I'll put it to good use. Watch." },
		honest = { "I actually love this. I'm not just saying it.", "You've been paying attention. Thank you." },
		scheming = { "How thoughtful. I'll remember it.", "What a lovely surprise. What's the occasion?" },
	},
}

-- what people are made of, when the game's roster doesn't have them (Engine/Party.backstory):
-- where they come from, where they were when the sky opened, their rank (or none), what they
-- want, and what they don't tell people. Told a line at a time, as the bond grows.
local BACKSTORY = {
	origin = {
		mother = { "When I was your age, the hardest thing in the world was getting the bus on time. I wanted more than that for you. I didn't know what more would look like." },
		father = { "I worked the same job for twenty years so you'd never have to think about money. I'm not sure it worked. I'd do it again." },
		sibling = { "You won't remember, but you used to follow me everywhere. Into the kitchen. Into trouble. I never minded." },
		child = { "When I was little I thought you could fix anything. You mostly could. I still think that, a bit." },
		friend = { "My family moved every year when I was a kid. You're the first friend I didn't have to say goodbye to.", "I was the new kid in a class that already had its friends. You were the only one who saved me a seat." },
		mentor = { "I trained the year the Association opened its first academy. Forty of us. Eleven still raid." },
		rival = { "I've been measuring myself against you since the day we met. I'm not proud of it. I'm not going to stop, either." },
		any = {
			"I grew up by the port. My mother sold fish and my father fixed engines, and neither of them ever sat down.",
			"I grew up above a laundry. Everything I owned smelled of steam and soap until I was eighteen.",
			"My grandmother raised me in a flat so small we took turns standing up. She was the strongest person I've ever met, and she never awakened.",
			"I grew up in the outer districts, where the buses stop at ten and everybody knows whose kid you are.",
			"My parents ran a stationery shop. I can still tell you the price of every pen in it.",
		},
	},
	gates = {
		adult = { "I was at work when the first Gate opened. We watched it on the office television and somebody laughed, because it looked fake.", "The day the sky tore, I was driving. Everyone pulled over at once, all down the motorway, and nobody said a word." },
		teen = { "I was fifteen when the Gates came. School closed for a month. We thought it was the best thing that had ever happened.", "I was in class when the alert went off. Our teacher locked the door and sang to us so we wouldn't hear the sirens." },
		child = { "I was small when the Gates came. I only remember my father carrying me down eleven flights of stairs.", "I don't remember a world without Gates. Just a blue light, and everyone being very quiet." },
		after = { "I was born after the Gates. People talk about 'before' like it's a country I've never been to.", "My first word was apparently 'siren'. My mother still won't laugh about it." },
	},
	awakened = {
		fighter = { "I awakened in a gym, mid-lift. The bar bent in my hands and the whole room went silent.", "The first time I held a real blade, my hands knew what to do before I did." },
		mage = { "I awakened in my sleep. I woke up and the curtains were on fire, and I'd done it.", "Mana feels like a second heartbeat. I spent a year learning not to listen to it." },
		assassin = { "I awakened during an exam. The room went slow and I could hear everyone's pens. I finished first.", "People stop seeing me when I want them to. It started as a game. It isn't one now." },
		tanker = { "I awakened when a sign fell off a building. I caught it. I didn't mean to catch it.", "I was always the big one. Then I awakened, and being big became a job." },
		ranger = { "I could always see further than other people. After I awakened, I could see further than anyone.", "I awakened on a hike. A rockfall, and I just knew where every stone would land." },
		healer = { "I awakened holding my grandmother's hand in a hospital. She went home the next day.", "The first person I healed was a stranger on a bus. I didn't know I could until it was done." },
		any = { "The Association's reader went quiet for a second when I put my hand on it. Then it printed a letter, and my life changed." },
	},
	rank = {
		E = { "E-rank. People hear that and their faces do something polite. I've stopped minding. Mostly.", "E-rank means you work harder than everyone and get paid less. I know. I do it anyway." },
		D = { "D-rank: enough to be useful, not enough to be famous. It's honest work.", "D-rank. I'm the one the raid plans call 'support', and the one who's always there." },
		C = { "C-rank. The guilds call me by name now. It still feels strange.", "C-rank. Strong enough to lead the small raids, and to see how big the big ones are." },
		B = { "B-rank. A strike team got built around me. That's a lot of people's lives to be the middle of.", "B-rank. Guilds send cars for me now. I still take the bus when I can." },
		A = { "A-rank. There are a few hundred of us in the country, and the Association phones us first. I don't sleep well.", "A-rank. People expect me to be fearless. I've just learned where to keep the fear." },
		S = { "S-rank. Everyone wants something from you when you're S-rank. You're one of the few who doesn't.", "S-rank. The news follows me home. I've started using the back door of my own building." },
	},
	unawakened = { "I never awakened. I waited for years, and then one day I noticed I'd stopped waiting.", "No rank, no licence. I'm one of the people the cordons are for, and I'm all right with that.", "Everyone in my family awakened except me. You learn to make yourself useful in other ways." },
	want = {
		brave = { "What I want is to be the one who walks into the room nobody else will. And walks out again." },
		cautious = { "I want to be old. That's it. Old, on a bench, complaining about the weather." },
		greedy = { "I want enough money that I never have to think about money again. Is that so strange?" },
		loyal = { "I want the people I care about to still be here in ten years. Everything else is extra." },
		proud = { "I want my name on something that lasts. A guild, a record, a building." },
		kind = { "I want to be the reason somebody's family gets them back." },
		reckless = { "I want to see what's at the bottom of the deepest Gate. Everyone says don't. That's the point." },
		cold = { "I don't want much. Quiet. A door that locks." },
		cheerful = { "I want to open a little restaurant one day, after all this. You'd eat free." },
		ambitious = { "I want to be ranked, written about and remembered. In that order." },
		honest = { "I want a world where the Gate readings are true, and the people who fake them are caught." },
		scheming = { "What I want? Leverage. Everyone has a price, and I like to know it." },
		any = { "I want a quiet year. Just one." },
	},
	secret = {
		brave = { "I'm terrified every time. Every single time. I go first so I don't have to watch." },
		cautious = { "I froze once, on my first raid. Someone else got hurt covering for me. That's why I count the exits." },
		greedy = { "I send half of everything to my parents. They think I'm doing far better than I am." },
		loyal = { "I left a party once, years ago. They went into a Gate without me and didn't come out. I don't leave any more." },
		proud = { "I failed my first licence test. Twice. Nobody knows that. Now you do." },
		kind = { "I couldn't help my brother when he needed it. Everyone I help since then, I'm helping him a little." },
		reckless = { "My Healer says one more bad hit and that's it for me. I haven't told anyone else." },
		cold = { "I used to be the loud one. Then I lost a party in a Gate, and the loud part didn't come out with me." },
		cheerful = { "Some nights I sit in the car outside my building for an hour before I can go in. Then I put my face back on." },
		ambitious = { "I took a raid I knew was above us, for the money and the name. Two people got hurt. I tell myself they'd have gone anyway." },
		honest = { "I signed one false reading, years ago, when I was scared of losing my job. I've been trying to make up for it ever since." },
		scheming = { "I sold a party's raid schedule once, to a rival guild. It paid for my mother's operation. I'd do it again, and I hate that." },
		any = { "I keep a list of everyone I've seen go into a Gate and not come out. It's long." },
	},
}

-- the gains of training with someone, by what they are (Engine/Party trainResult)
local TRAIN_LOGS = {
	fighter = "{rel} ran you through blade drills until your arms shook, then showed you how to stop wasting your swing.",
	mage = "{rel} made you sit still and feel the mana in the room for an hour. It was the hardest hour of your week.",
	assassin = "{rel} taught you to move through a crowd without touching anyone. You touched everyone. They were patient.",
	tanker = "{rel} put a shield on your arm and leaned on it until you learned where your feet go.",
	ranger = "{rel} took you up to the hills and taught you to see the thing that moves before it moves.",
	healer = "{rel} taught you how to breathe through a hit, and how to keep going when your body says stop.",
	civilian = "You and {rel} ran the river path at dawn, every morning for a month, until it stopped being hard.",
}

-- presents (Engine/Party: a gift a person likes is one whose `words` are in one of their likes)
local GIFTS = {
	{ id = "g_letter", name = "a long handwritten letter", price = 0, words = { "letters", "handwritten letters", "writing" }, desc = "Costs nothing but an evening." },
	{ id = "g_street", name = "street food from the night market", price = 1, words = { "street food", "night markets", "snacks", "tteokbokki" }, desc = "Skewers, fishcakes and something on a stick nobody can name." },
	{ id = "g_spicy", name = "a box of the hottest fire noodles", price = 1, words = { "spicy food", "spicy", "noodles", "ramyeon" }, desc = "A dare in a box." },
	{ id = "g_cake", name = "a cake from the good bakery", price = 1, words = { "sweets", "cake", "desserts", "bakery" }, desc = "The one with the queue round the block." },
	{ id = "g_coffee", name = "a bag of good coffee beans", price = 1, words = { "coffee" }, desc = "From the roaster by the station." },
	{ id = "g_tea", name = "a tin of green tea", price = 1, words = { "tea", "green tea" }, desc = "First harvest, hand-picked." },
	{ id = "g_book", name = "a novel you think they'll love", price = 1, words = { "books", "reading", "novels" }, desc = "With a note on the first page." },
	{ id = "g_comics", name = "a full run of a comic series", price = 2, words = { "comics", "webtoons", "manga" }, desc = "All forty volumes, in a box." },
	{ id = "g_game", name = "a new game for their console", price = 2, words = { "video games", "games", "gaming" }, desc = "The one everyone's talking about." },
	{ id = "g_board", name = "a new board game", price = 2, words = { "board games", "strategy" }, desc = "For four players. You know who'd play." },
	{ id = "g_records", name = "an old vinyl record you found", price = 2, words = { "music", "records", "vinyl", "jazz", "songs" }, desc = "From a shop that smells of dust." },
	{ id = "g_film", name = "two tickets to an old film at the revival cinema", price = 1, words = { "old films", "films", "movies", "cinema" }, desc = "Black and white, on a real screen." },
	{ id = "g_plant", name = "a potted plant for their window", price = 1, words = { "plants", "gardening" }, desc = "Hard to kill. Hopefully." },
	{ id = "g_flowers", name = "a bunch of flowers", price = 1, words = { "flowers" }, desc = "From the stall outside the hospital." },
	{ id = "g_cat", name = "an absurdly fancy toy for their cat", price = 1, words = { "cats", "cat" }, desc = "It has feathers and a bell." },
	{ id = "g_dog", name = "a bag of treats for their dog", price = 1, words = { "dogs", "dog" }, desc = "The good ones." },
	{ id = "g_fruit", name = "a box of perfect fruit", price = 2, words = { "fruit", "peaches", "tangerines" }, desc = "Each one wrapped in its own paper." },
	{ id = "g_puzzle", name = "a thousand-piece puzzle of the night sky", price = 1, words = { "puzzles", "stargazing", "stars" }, desc = "Nine hundred of the pieces are black." },
	{ id = "g_sketch", name = "a sketchbook and good pencils", price = 1, words = { "drawing", "art", "sketching", "painting" }, desc = "Thick paper. Soft leads." },
	{ id = "g_singing", name = "a night at the singing rooms", price = 1, words = { "karaoke", "singing" }, desc = "Two hours, a tambourine, no mercy." },
	{ id = "g_baseball", name = "two seats at the baseball", price = 2, words = { "baseball", "sports" }, desc = "Behind first base." },
	{ id = "g_football", name = "a signed football shirt", price = 4, words = { "football", "sports" }, desc = "Framed, if they want." },
	{ id = "g_map", name = "a framed old map of the city", price = 3, words = { "maps", "history", "old things" }, desc = "From before the Gates, with streets that aren't there any more." },
	{ id = "g_knife", name = "a proper chef's knife", price = 3, words = { "cooking", "home cooking", "kitchens" }, desc = "Hand-forged. Wrapped in cloth." },
	{ id = "g_gym", name = "a year at a Hunter gym", price = 3, words = { "training", "gym", "exercise", "sparring" }, desc = "The one with the reinforced floors." },
	{ id = "g_whetstone", name = "a master-made whetstone", price = 4, words = { "good weapons", "weapons", "blades", "swords", "knives" }, desc = "The kind smiths keep for themselves." },
	{ id = "g_rod", name = "a good fishing rod", price = 5, words = { "fishing", "the sea", "rivers" }, desc = "Carbon, light as a pencil." },
	{ id = "g_boots", name = "a pair of Gate-grade boots", price = 6, words = { "good boots", "boots", "running", "hiking" }, desc = "Monster-hide soles. They'll outlast you." },
	{ id = "g_salve", name = "a jar of Healer-made recovery salve", price = 6, words = { "first aid", "medicine", "healing" }, desc = "For the bruises nobody admits to." },
	{ id = "g_camera", name = "a secondhand film camera", price = 8, words = { "photography", "photos", "cameras" }, desc = "It still has half a roll in it." },
	{ id = "g_inn", name = "a weekend at a mountain inn", price = 12, words = { "the mountains", "mountains", "hiking", "quiet mornings", "hot springs" }, desc = "No signal. No Gates on record." },
	{ id = "g_pendant", name = "a pendant cut from a mana crystal", price = 20, words = { "crystals", "jewellery", "pretty things" }, desc = "It glows faintly blue in the dark." },
}

-- what people like and can't stand, when the roster doesn't say (each person gets three and two)
local LIKES = {
	"street food", "spicy food", "home cooking", "sweets", "coffee", "green tea", "old films", "music", "books", "comics",
	"video games", "board games", "the sea", "the mountains", "plants", "cats", "dogs", "running", "training", "good weapons",
	"good boots", "maps", "puzzles", "photography", "drawing", "cooking", "night markets", "baseball", "football", "fishing",
	"stargazing", "flowers", "handwritten letters", "karaoke", "fruit", "quiet mornings",
}
local DISLIKES = {
	"being lied to", "loud crowds", "show-offs", "waiting", "the cold", "being late", "spicy food", "sweets", "flowers",
	"gossip", "guild politics", "paperwork", "hospitals", "insects", "small talk", "being pitied", "the dark", "cats",
}

-- ── the people the saga cards introduce (the same shape as Roster.luau's NPCs) ───────
local CAST = {
	{
		id = "npc_sg_sunhee_moon", first = "Sunhee", last = "Moon", rank = "C", class = "healer",
		role = "the old Healer who runs the Gate-injury ward on Sundays",
		personality = { "kind", "honest", "loyal" },
		likes = { "green tea", "handwritten letters", "plants" },
		dislikes = { "guild contracts", "people who skip meals" },
		backstory = {
			"I was a nurse for thirty years before the Gates. I awakened at fifty-one, in the middle of a night shift. Imagine my surprise.",
			"C-rank. The guilds offered me more money than I'd earned in my whole life. I told them I already had a ward.",
			"My son was a porter, the kind nobody writes about. He was hurt in a Gate, and the guild's Healer charged more than we had.",
			"He walked again, eventually. The ward is for everyone else's son.",
			"The oath is one sentence long because I'm too old to remember two.",
		},
		lines = {
			greet = { "Have you eaten? Sit. Eat first, then tell me.", "My Sunday Healer. Come in, the kettle's on." },
			accept = { "At my age? ...Oh, why not. Somebody has to keep you all in one piece." },
			refuse = { "My place is the ward, dear. Ask me again when it can run without me. It can't." },
			farewell = { "Come on Sundays. Even if you're not healing. Just come." },
			gift = { "You remembered. Nobody remembers what old ladies like." },
		},
		recruit = { difficulty = 4 },
	},
	{
		id = "npc_sg_hyunwoo_jeon", first = "Hyunwoo", last = "Jeon",
		role = "the construction worker whose leg you healed on the night shift",
		personality = { "cheerful", "loyal" },
		likes = { "baseball", "spicy food", "fishing" },
		dislikes = { "hospitals", "waiting" },
		backstory = {
			"I've built half the towers in the outer districts. You can't see my work. It's all inside the walls.",
			"The night of the break I was carrying a woman down a stairwell when the ceiling came in. I don't remember the rest.",
			"The doctor said I'd never walk right again. Then you came in at four in the morning, grey as paper, and I walked out on Tuesday.",
			"I go to the ward on Sundays now and fix whatever's broken. Doors, chairs, the lift. It's the only way I know how to say thank you.",
		},
		lines = {
			greet = { "My Healer! Come here, let me look at you.", "Still walking. Every day, still walking." },
			accept = { "If you need someone to carry the crystals, I've got two good legs. Thanks to you." },
			refuse = { "Me, in a Gate? I build things, I don't fight them. But I'd carry your bags anywhere." },
		},
	},
	{
		id = "npc_sg_taeho_yoon", first = "Taeho", last = "Yoon", rank = "D", class = "tanker",
		role = "one of the founding members of your guild",
		personality = { "loyal", "cheerful", "brave" },
		likes = { "home cooking", "football", "dogs" },
		dislikes = { "guild politics", "the cold" },
		backstory = {
			"I moved furniture before I awakened. Pianos, fridges, wardrobes up nine flights. Turns out that's good training for holding a shield.",
			"D-rank. The big guilds never called back. You did.",
			"My mum still thinks I work in a warehouse. I'll tell her when we're famous.",
			"The first time I held a line I was so scared I sang. Out loud. The whole raid heard. They still call me Choir.",
			"I'd follow you into anything. I think you know that. I just wanted to say it.",
		},
		lines = {
			greet = { "Boss! I brought kimbap. There's enough for everyone.", "Morning, boss. Shield's polished." },
			accept = { "You don't even need to ask. Where's the shield?" },
			refuse = { "Not this one, boss. My mum's in hospital this month." },
			battle = { "Shield's still up! Everyone behind me!" },
			hurt = { "I'm okay! I'm okay. Is the shield okay?" },
			farewell = { "You'll always have a Tanker. Just call." },
			gift = { "You got me this? Boss. Boss, I'm going to cry." },
		},
		recruit = { difficulty = 1 },
	},
	{
		id = "npc_sg_ara_seo", first = "Ara", last = "Seo", rank = "C", class = "mage",
		role = "one of the founding members of your guild",
		personality = { "ambitious", "honest" },
		likes = { "books", "coffee", "maps" },
		dislikes = { "show-offs", "being late" },
		backstory = {
			"I was top of my class at university. Physics. Then the Gates opened and physics stopped being true.",
			"I awakened during a lecture and set fire to the projector. They still use my name as a warning.",
			"C-rank. Not bad, not brilliant. I hate not being brilliant.",
			"I joined your guild because it's small enough that what I do counts. Big guilds bury people like me.",
			"One day I'm going to be the first Mage who can read a Gate's real rank from outside it. Write that down.",
		},
		lines = {
			greet = { "You're late. Three minutes. I timed it.", "I rewrote the raid plan. Don't argue, it's better." },
			accept = { "Fine. But I write the raid plans." },
			refuse = { "Your plan has a hole in it the size of a boss room. Fix it and ask me again." },
			battle = { "Textbook. Mostly my textbook." },
			farewell = { "Don't let anyone else write your plans." },
		},
		recruit = { difficulty = 2 },
	},
	{
		id = "npc_sg_junho_bae", first = "Junho", last = "Bae", rank = "D", class = "ranger",
		role = "one of the founding members of your guild",
		personality = { "cautious", "scheming" },
		likes = { "puzzles", "fishing", "quiet mornings" },
		dislikes = { "loud crowds", "being lied to" },
		backstory = {
			"I grew up by a reservoir. My father taught me to sit still for four hours and wait for one fish. Good training for a Ranger.",
			"I awakened at twenty-six. Late. People treat you like you snuck in.",
			"My family's restaurant failed the year the Gates came. The debts outlived the restaurant.",
			"Someone bought those debts last year. I don't know who. I get letters. Very polite ones.",
			"If I ever do something you can't forgive, I want you to know it wasn't because I didn't care.",
		},
		lines = {
			greet = { "Morning. Quiet one today. I like the quiet ones." },
			accept = { "...All right. Yes. Thank you for trusting me." },
			refuse = { "I can't. Not now. It's complicated." },
			farewell = { "I'm sorry. For everything I didn't tell you." },
		},
		recruit = { difficulty = 2 },
	},
	{
		id = "npc_sg_haneul_ryu", first = "Haneul", last = "Ryu", rank = "B", class = "assassin",
		role = "the B-rank rookie who signed with your guild",
		personality = { "proud", "ambitious", "reckless" },
		likes = { "street food", "video games", "running" },
		dislikes = { "being treated like a rookie", "paperwork" },
		backstory = {
			"I was measured last month. B-rank. The reader made a noise the technician had never heard.",
			"Before that I was a courier. Fastest in the district. Nobody ever caught me, not even the traffic cameras.",
			"Every big guild wanted me on porter duty for a year 'to learn the ropes'. I don't carry other people's crystals.",
			"My older brother was a Hunter. D-rank. He was lost in a Gate that was measured wrong. That's the only thing I'm scared of.",
			"Rank's fixed. Reputation isn't. I'm going to be the most famous B-rank in the country.",
		},
		lines = {
			greet = { "Took you long enough. What are we clearing?" },
			accept = { "Finally. Someone who doesn't want me carrying boxes." },
			refuse = { "You're slower than me. I don't follow slower." },
			battle = { "Did anyone even see that? Too fast, right?" },
			farewell = { "Don't get comfortable without me." },
		},
		recruit = { difficulty = 3, minRank = "C" },
	},
	{
		id = "npc_sg_eunji_park", first = "Eunji", last = "Park", rank = "B", class = "fighter",
		role = "your guild's vice-master, who found the leak",
		personality = { "loyal", "honest", "cautious" },
		likes = { "green tea", "old films", "cats" },
		dislikes = { "being lied to", "guild politics" },
		backstory = {
			"I was a police officer for eight years. I awakened during an arrest. The man I was holding just stopped struggling.",
			"B-rank. I could have gone to a big guild. I wanted to work somewhere I could see every name on the board.",
			"I keep a notebook of every raid we've run. Who went in, who came out. Every name.",
			"When I found the leak, I sat in my car for an hour before I came up to your office. I didn't want it to be true.",
			"If you ever want to know whose side I'm on, read the notebook. You're on every page.",
		},
		lines = {
			greet = { "Master. The board's updated. Two new Gates, both ours if we want them." },
			accept = { "I've been at your side since the room above the phone shop. Of course." },
			refuse = { "Someone has to run the guild while you're inside. Ask me another time." },
		},
		recruit = { difficulty = 1 },
	},
	{
		id = "npc_sg_dohyun_kang", first = "Dohyun", last = "Kang", rank = "D", class = "fighter",
		role = "a rookie you kept alive inside a Red Gate",
		personality = { "cheerful", "brave" },
		likes = { "comics", "spicy food", "karaoke" },
		dislikes = { "the cold", "snow" },
		backstory = {
			"It was my second raid ever. A training raid. They said it would be boring.",
			"When the light went red, I thought someone was playing a joke. Then it started snowing.",
			"You kept a fire going and made us talk. You asked me about my favourite comic for an hour.",
			"I still can't look at snow. My little sister threw a snowball at me last winter and I hid behind a car.",
			"I'm going to be the kind of Hunter who keeps the rookies talking. Like you did.",
		},
		lines = {
			greet = { "Hey! It's warm today. I checked." },
			accept = { "Me? In your party? Yes! Yes, obviously, yes!" },
			hurt = { "It's fine, it's fine, it's not even cold." },
		},
		recruit = { difficulty = 1 },
	},
	{
		id = "npc_sg_sora_jin", first = "Sora", last = "Jin", rank = "B", class = "tanker",
		role = "a veteran who pushed for the boss with you inside a Red Gate",
		personality = { "brave", "cold", "honest" },
		likes = { "the mountains", "green tea", "running" },
		dislikes = { "small talk", "gossip" },
		backstory = {
			"Fifteen years on the front line. Twelve guilds. I'm the one they send with the rookies.",
			"I don't talk about my first Red Gate. That was my second.",
			"The rookies think I don't remember their names. I remember every one.",
			"Some of them didn't come out. I carried two as far as the throne room. That's all I'll say.",
			"You fought beside me in there. That's the only reason I'm telling you any of this.",
		},
		lines = {
			greet = { "...You.", "Still standing. Good." },
			accept = { "I'll take the front. Don't argue." },
			refuse = { "I've buried enough parties. Not yet." },
		},
		recruit = { difficulty = 3 },
	},
	{
		id = "npc_sg_yerin_oh", first = "Yerin", last = "Oh", rank = "D", class = "healer",
		role = "the Healer who started the Thursday group for Red Gate survivors",
		personality = { "kind", "cautious" },
		likes = { "plants", "handwritten letters", "sweets" },
		dislikes = { "the cold", "loud crowds" },
		backstory = {
			"I was a ward nurse before I awakened. Now I'm a ward nurse with mana.",
			"My Red Gate was abroad, on an exchange raid. Three days inside. Forty minutes outside.",
			"I ran out of mana on the second day. After that I just held people's hands.",
			"I started the Thursday group because I needed it, and nobody else had.",
			"I keep the hall's spare key on the same ring as my house key. That's how important it is.",
		},
		lines = {
			greet = { "You came. I'm glad you came.", "There's barley tea. There's always barley tea." },
			accept = { "Someone has to keep you warm in there. All right." },
			refuse = { "The group needs me on Thursdays. I can't risk not coming back." },
		},
		recruit = { difficulty = 2 },
	},
	{
		id = "npc_sg_marcus_walker", first = "Marcus", last = "Walker", rank = "A", class = "ranger",
		role = "a man from the Thursday group, who came out of a Red Gate abroad",
		personality = { "cold", "honest", "cautious" },
		likes = { "stargazing", "maps", "coffee" },
		dislikes = { "small talk", "show-offs" },
		backstory = {
			"I raided in the States for nine years. Bureau contracts. Good money, bad sleep.",
			"My Red Gate read D. Inside it was a forest that didn't end.",
			"I came here because nobody here knew me as the guy who walked out alone.",
			"A-rank. I still shoot every morning, in case. I've never said in case of what.",
			"The group's the first place I've said any of this out loud. You're the second.",
		},
		lines = {
			greet = { "Hey.", "Clear skies tonight. Good for the stars." },
			accept = { "One more party. Last one. Don't make me watch it end." },
			refuse = { "I'm done with parties. It's not you." },
		},
		recruit = { difficulty = 4 },
	},
	{
		id = "npc_sg_jiwoo_han", first = "Jiwoo", last = "Han",
		role = "the measurement technician you share the Association's van with",
		personality = { "honest", "cheerful" },
		likes = { "coffee", "board games", "baseball" },
		dislikes = { "paperwork", "being late" },
		backstory = {
			"I drive the van. I also read the Gates, but people mostly remember the van.",
			"I've measured over four hundred Gates. I can tell a C from a B by the hum before the reader beeps.",
			"My father was on the country's first measurement team. They didn't have readers yet. They had a counter and a lot of hope.",
			"Every reading I sign, I think about who's going to walk into it on my number.",
			"If anyone ever asks me to sign a reading I don't believe, I'll quit. I made my dad that promise.",
		},
		lines = {
			greet = { "Van's warm, coffee's hot, reader's charged. Let's go measure something." },
			refuse = { "In a Gate? I measure them from the outside, thanks. That's the whole point of me." },
		},
	},
	{
		id = "npc_sg_kyungho_shin", first = "Kyungho", last = "Shin", rank = "B", class = "fighter",
		role = "an agent from the Association's Surveillance Team",
		personality = { "honest", "cold", "brave" },
		likes = { "old films", "running", "coffee" },
		dislikes = { "being lied to", "guild politics" },
		backstory = {
			"The Surveillance Team polices Hunters. That means the people I arrest can usually lift a car.",
			"I joined because of a guild that sold a porter's safety for a cheap raid right. I never found out who signed it.",
			"B-rank. Enough to bring most of them in. Not enough to be safe doing it.",
			"I don't have many friends. It's hard, when your job is suspecting everyone.",
			"You brought that file in with shaking hands and didn't let go of it. That's why I trust you.",
		},
		lines = {
			greet = { "Agent. Anything I should know about?" },
			accept = { "Off the books? No. On the books, with a report after every raid? Yes." },
			refuse = { "The Team comes first. That's not going to change." },
		},
		recruit = { difficulty = 3 },
	},
	{
		id = "npc_sg_siwoo_jang", first = "Siwoo", last = "Jang", rank = "E", class = "fighter",
		role = "the missing porter who came back to testify",
		personality = { "cautious", "loyal" },
		likes = { "comics", "quiet mornings", "cats" },
		dislikes = { "loud crowds", "unmeasured Gates" },
		backstory = {
			"I was a porter. You carry the crystals, you mine the walls, you don't ask what Gate it is.",
			"They took us into Gates the Association never saw. Paid cash. Told us not to talk.",
			"My friend Daeho asked a question once. He wasn't hired again. I haven't heard from him since.",
			"I hid at my cousin's for a year. I jumped every time a car slowed down outside.",
			"You kept your promise. I didn't think anybody kept promises any more.",
		},
		lines = {
			greet = { "Oh. It's you. Good. Come in, quick." },
			accept = { "A licensed party? Registered raids? ...Yes. Yes, please." },
			refuse = { "I can't go back in. Not yet. I'm sorry." },
		},
		recruit = { difficulty = 2 },
	},
	{
		id = "npc_sg_moth", first = "Moth", last = "", rank = "B", class = "assassin",
		role = "the leader of an unlicensed crew that raids unreported Gates",
		personality = { "scheming", "greedy", "cold" },
		likes = { "night markets", "good weapons", "maps" },
		dislikes = { "the Surveillance Team", "being lied to" },
		backstory = {
			"Moth's not my name. Names are for people who want to be found.",
			"I had a licence once. B-rank, a real guild. They kept three-quarters of everything I brought out.",
			"The Association measures a Gate, sells the rights and takes its cut. I just skip the middle.",
			"Everyone I work with thinks they're different from me. They're not. They're just newer.",
			"You'll leave. They all leave. I don't hold it against anyone.",
		},
		lines = {
			greet = { "Well. Look who it is.", "Got a minute? I've always got a job." },
			accept = { "Your party? Sure. Just don't ask where I go on weekends." },
			refuse = { "I don't do licensed. You know that." },
		},
		recruit = { difficulty = 3, wantsPay = 40 },
	},
	{
		id = "npc_sg_nari_kwon", first = "Nari", last = "Kwon", rank = "E", class = "healer",
		role = "the porter you carried out of an unreported Gate",
		personality = { "kind", "loyal", "cheerful" },
		likes = { "sweets", "drawing", "dogs" },
		dislikes = { "the dark", "being left behind" },
		backstory = {
			"I was nineteen and broke. A porter job with cash pay sounded like a dream.",
			"I didn't know the Gate wasn't registered. I didn't know any of it.",
			"When my leg went, I heard Moth say 'we leave them'. I'll never forget how calm he sounded.",
			"You carried me three kilometres. I counted the steps to stay awake. Four thousand and something.",
			"I'm training to be a real Hunter now. Licensed. I want to be the one who carries people out.",
		},
		lines = {
			greet = { "Hi! Hi. Sorry. I always get excited when it's you." },
			accept = { "Really? Me? I'll be so good, I promise. I'll carry everything." },
			hurt = { "It's okay. Nobody's leaving anyone. Right?" },
		},
		recruit = { difficulty = 1 },
	},
	{
		id = "npc_sg_dongha_oh", first = "Dongha", last = "Oh", rank = "C", class = "tanker",
		role = "the sergeant of the standing line of Tankers in the industrial zone",
		personality = { "loyal", "honest", "cold" },
		likes = { "fishing", "green tea", "baseball" },
		dislikes = { "show-offs", "waiting" },
		backstory = {
			"Twenty years on the line in this zone. Before it was a line, it was me and two others.",
			"The city calls it a standing line of Tankers. We call it the Wall, because that's what we are.",
			"I've seen eleven breaks on these streets. I've seen what gets through when the Wall has a gap.",
			"My shield's on its fourth face. The first three are in a case in my flat.",
			"You stand like you mean it. That's rarer than rank.",
		},
		lines = {
			greet = { "Shift's in ten. Stand up straight." },
			accept = { "The Wall can spare me for a raid or two. Don't tell the others." },
			refuse = { "My place is the line. It'll always be the line." },
		},
		recruit = { difficulty = 3 },
	},
	{
		id = "npc_sg_hayoung_song", first = "Hayoung", last = "Song", rank = "D", class = "tanker",
		role = "the rookie Tanker who asked you to teach them to stand",
		personality = { "brave", "reckless", "cheerful" },
		likes = { "running", "street food", "football" },
		dislikes = { "waiting", "being told no" },
		backstory = {
			"My dad was a firefighter. He used to say somebody has to walk toward it.",
			"I awakened at eighteen. D-rank Tanker, and too light, everyone says. I eat four meals a day. It doesn't help.",
			"I watched the Wall hold on the news when I was fourteen. I've wanted to stand there ever since.",
			"I'm faster than any Tanker you've met. That's my trick. I get there first.",
			"Thank you for not telling me to find another life. Everyone else did.",
		},
		lines = {
			greet = { "Teacher! Watch this, I've been practising the stance." },
			accept = { "Yes! I'll be the shield. I'll be the best shield." },
			battle = { "Did you see me hold? Did you see?" },
		},
		recruit = { difficulty = 1 },
	},
	{
		id = "npc_sg_kwangsu_ahn", first = "Kwangsu", last = "Ahn",
		role = "the old man from the noodle shop, who cooked for the basement shelter",
		personality = { "kind", "cheerful" },
		likes = { "home cooking", "baseball", "old films" },
		dislikes = { "people who skip meals", "waste" },
		backstory = {
			"Forty years in the same shop. Same stock pot. Don't tell the health inspector.",
			"When the first Gate opened down the street, I kept the shop open. Somebody had to feed the police.",
			"My sister ran the till with me for thirty years. I still put two bowls out at closing.",
			"That night in the basement I made noodles for forty people on a camping stove. Best service of my life.",
			"You built that shelter. I just fed it. Don't let anyone tell it the other way round.",
		},
		lines = {
			greet = { "Sit, sit. The broth's been going since five." },
			refuse = { "At my age, the only Gate I'm going through is the shop's back door." },
		},
	},
	{
		id = "npc_sg_ren_sato", first = "Ren", last = "Sato",
		role = "the delivery rider who ran into your building's basement off the road",
		personality = { "reckless", "cheerful" },
		likes = { "street food", "video games", "music" },
		dislikes = { "traffic", "waiting" },
		backstory = {
			"I came here from Osaka to study and stayed for the delivery money. It's good money if you're fast and a little reckless.",
			"I ran into your basement with something maybe ten metres behind my scooter.",
			"I still had the order, by the way. Cold noodles. Delivered at six in the morning. Five stars.",
			"My parents want me to come home. I keep saying next year.",
			"I know every alley in this district. If you ever need a way out, I'm your way out.",
		},
		lines = {
			greet = { "Hey! I've got twelve minutes before my next drop. Talk fast." },
			refuse = { "I'd love to, but I don't have a rank. I've just got a scooter." },
		},
	},
	{
		id = "npc_sg_haeun_cho", first = "Haeun", last = "Cho",
		role = "the technician who measured the Gate behind the old market",
		personality = { "honest", "cautious" },
		likes = { "books", "green tea", "plants" },
		dislikes = { "being lied to", "guild politics" },
		backstory = {
			"I measured the Gate behind the market on day one. It read B. I filed it on day one.",
			"On day two my supervisor said the reader must have been faulty. On day three, he told me what to write.",
			"Nine people. I've read their names every morning since.",
			"Meeting you in that car park was the bravest thing I've ever done. My hands didn't stop shaking for a week.",
			"If it all comes out, I'll lose my job. I've decided that's all right.",
		},
		lines = {
			greet = { "Not here. Let's walk." },
			refuse = { "I'm not a Hunter. I just read the numbers. And now I tell the truth about them." },
		},
	},
	{
		id = "npc_sg_arjun_sharma", first = "Arjun", last = "Sharma", rank = "D", class = "ranger",
		role = "the D-rank escort who stood by your tripod when the Gate opened",
		personality = { "cold", "honest", "greedy" },
		likes = { "stargazing", "the mountains", "coffee" },
		dislikes = { "small talk", "show-offs" },
		backstory = {
			"I take escort contracts. Researchers, film crews, surveyors. People who need to be near a Gate without being in one.",
			"I grew up in Mumbai. Came here for a guild that folded six months later. Stayed for the work.",
			"D-rank. Calm is worth more than rank in this job. Panicked Hunters get clients hurt.",
			"I don't talk much because the first sign of a Gate is a sound, and you can't hear it if you're talking.",
			"Your box hummed before the Gate opened. I've never seen anything do that. I'd like to see it again.",
		},
		lines = {
			greet = { "Contract or company?" },
			accept = { "Standard rate, standard share. Then yes." },
		},
		recruit = { difficulty = 2, wantsPay = 3 },
	},
	{
		id = "npc_sg_elena_reyes", first = "Elena", last = "Reyes", rank = "A", class = "mage",
		role = "one of the Hunters on your team after the war (non-canon)",
		personality = { "brave", "ambitious", "honest" },
		likes = { "music", "books", "the sea" },
		dislikes = { "being called an asset", "politicians" },
		backstory = {
			"(non-canon) I came over with the relief teams after the war, from a country that lost most of its Hunters in it.",
			"A-rank. Before the war there were forty of us at home. Now I can count us on two hands.",
			"I lost my whole raid team in the last week of the war. I was the one who'd planned the route.",
			"People keep calling us strategic assets. I have a name, and a mother who calls every Sunday.",
			"When the Gates stop, if they ever stop, I'm going to teach music to children. I mean it.",
		},
		lines = {
			greet = { "Another S-rank on the board this morning. Ready?" },
			accept = { "Of course. Who else is there?" },
		},
		recruit = { difficulty = 3, minRank = "A" },
	},
	{
		id = "npc_sg_yui_tanaka", first = "Yui", last = "Tanaka", rank = "D", class = "mage",
		role = "one of the five who made it back through the black door",
		personality = { "cautious", "cold" },
		likes = { "puzzles", "green tea", "cats" },
		dislikes = { "the dark", "the cold" },
		backstory = {
			"I was the one holding the torch when it caught the door. I wonder every day what would have happened if I'd looked the other way.",
			"D-rank Mage. I make light, mostly. In there, the light didn't reach.",
			"I ran back through the gap and didn't look back. I'm sorry I didn't look back.",
			"I sleep with every light in the flat on. My electricity bill is a disaster.",
			"The investigators asked what I saw. I told them the truth: nothing. That's what frightens me.",
		},
		lines = {
			greet = { "...Hi. The lights are on in here. Good." },
			refuse = { "No more doors. I'm sorry. No more doors." },
		},
		recruit = { difficulty = 3 },
	},
}

-- which card introduces whom (Engine/Party.afterChoice): the choices it happens on, whether
-- the clash had to be won, how close you start out, and how old they are
local CAST_MEET = {
	sg_heal_01 = { { roster = "npc_sg_sunhee_moon", role = "the old Healer who runs the Gate-injury ward on Sundays", kind = "mentor", choice = 1, bond = { 48, 58 }, age = { 61, 66 } } },
	sg_heal_02 = {
		{ roster = "npc_sg_hyunwoo_jeon", role = "the construction worker whose leg you healed on the night shift", choice = 1, won = true, bond = { 50, 62 }, age = { 30, 46 } },
		{ roster = "npc_sg_hyunwoo_jeon", role = "the construction worker whose leg you healed on the night shift", choice = 2, bond = { 44, 56 }, age = { 30, 46 } },
	},
	sg_guild_01 = {
		{ roster = "npc_sg_taeho_yoon", role = "one of the three founding members of your guild", kind = "friend", choice = { 1, 2 }, bond = { 46, 56 }, age = { 22, 30 } },
		{ roster = "npc_sg_ara_seo", role = "one of the three founding members of your guild", kind = "friend", choice = { 1, 2 }, bond = { 40, 50 }, age = { 23, 29 } },
		{ roster = "npc_sg_junho_bae", role = "one of the three founding members of your guild", kind = "friend", choice = { 1, 2 }, bond = { 40, 50 }, age = { 27, 34 } },
	},
	sg_guild_03 = {
		{ roster = "npc_sg_haneul_ryu", role = "the B-rank rookie who signed with your guild", kind = "friend", choice = 1, won = true, bond = { 40, 50 }, age = { 19, 22 } },
		{ roster = "npc_sg_haneul_ryu", role = "the B-rank rookie who signed with your guild", kind = "friend", choice = 2, bond = { 32, 42 }, age = { 19, 22 } },
	},
	sg_guild_05 = { { roster = "npc_sg_eunji_park", role = "your guild's vice-master, who found the leak", kind = "friend", bond = { 56, 66 }, age = { 28, 40 } } },
	sg_red_01 = {
		{ roster = "npc_sg_sora_jin", role = "a veteran who pushed for the boss with you inside a Red Gate", choice = 1, won = true, bond = { 40, 50 }, age = { 36, 46 } },
		{ roster = "npc_sg_dohyun_kang", role = "a rookie you kept alive inside a Red Gate", kind = "friend", choice = 2, won = true, bond = { 50, 62 }, age = { 19, 23 } },
	},
	sg_red_04 = {
		{ roster = "npc_sg_yerin_oh", role = "the Healer who started the Thursday group for Red Gate survivors", kind = "friend", choice = { 1, 2 }, bond = { 42, 52 }, age = { 30, 42 } },
		{ roster = "npc_sg_marcus_walker", role = "a man from the Thursday group, who came out of a Red Gate abroad", choice = { 1, 2 }, bond = { 32, 42 }, age = { 44, 54 } },
	},
	sg_assoc_01 = { { roster = "npc_sg_jiwoo_han", role = "the measurement technician you share the Association's van with", choice = 1, bond = { 34, 44 }, age = { 24, 36 } } },
	sg_assoc_03 = { { roster = "npc_sg_kyungho_shin", role = "an agent from the Association's Surveillance Team", choice = 1, bond = { 30, 40 }, age = { 30, 42 } } },
	sg_assoc_04 = {
		{ roster = "npc_sg_siwoo_jang", role = "the missing porter who came back to testify", choice = 1, won = true, bond = { 46, 56 }, age = { 21, 28 } },
		{ roster = "npc_sg_siwoo_jang", role = "the missing porter who came back to testify", choice = 2, bond = { 40, 50 }, age = { 21, 28 } },
	},
	sg_rogue_02 = { { roster = "npc_sg_moth", role = "the leader of an unlicensed crew that raids unreported Gates", kind = "rival", choice = 1, bond = { 22, 32 }, age = { 34, 44 } } },
	sg_rogue_04 = {
		{ roster = "npc_sg_nari_kwon", role = "the porter you carried out of an unreported Gate", kind = "friend", choice = 1, won = true, bond = { 58, 70 }, age = { 19, 19 } },
		{ roster = "npc_sg_nari_kwon", role = "the porter you carried out of an unreported Gate", kind = "friend", choice = 3, won = true, bond = { 58, 70 }, age = { 19, 19 } },
	},
	sg_wall_01 = { { roster = "npc_sg_dongha_oh", role = "the sergeant of the standing line of Tankers in the industrial zone", kind = "mentor", choice = 1, bond = { 34, 44 }, age = { 44, 52 } } },
	-- (the card adds the rookie itself, as a friend: they become this person)
	sg_wall_03 = { { roster = "npc_sg_hayoung_song", role = "the rookie Tanker who asked you to teach them to stand", kind = "friend", choice = 1, adopt = true } },
	sg_shel_01 = {
		{ roster = "npc_sg_kwangsu_ahn", role = "the old man from the noodle shop, who cooked for the basement shelter", choice = 1, bond = { 40, 50 }, age = { 64, 72 } },
		{ roster = "npc_sg_ren_sato", role = "the delivery rider who ran into your building's basement off the road", choice = 1, bond = { 34, 44 }, age = { 21, 26 } },
	},
	sg_rep_02 = { { roster = "npc_sg_haeun_cho", role = "the technician who measured the Gate behind the old market", choice = 1, won = true, bond = { 36, 46 }, age = { 28, 38 } } },
	sg_res_03 = { { roster = "npc_sg_arjun_sharma", role = "the D-rank escort who stood by your tripod when the Gate opened", choice = 1, bond = { 30, 40 }, age = { 29, 38 } } },
	sg_nat_01 = { { roster = "npc_sg_elena_reyes", role = "one of the Hunters on your team after the war (non-canon)", choice = 1, bond = { 36, 46 }, age = { 30, 40 } } },
	sg_hol_01 = {
		{ roster = "npc_sg_yui_tanaka", role = "one of the five who made it back through the black door", choice = { 1, 2 }, won = true, bond = { 44, 54 }, age = { 22, 30 } },
	},
}

-- how to draw someone (client/UI/PartySheet with Hunter/Looks): a Hunter wears their class's
-- outfit for their rank; these say what everyone else wears, by the words of what they do
local PRESETS = {
	civilian = { "office", "salaryman", "shopkeeper", "chef", "streetwear", "runner", "winter", "hanbok_day" },
	young = { "student", "sailor_student", "streetwear", "runner" },
	byWords = {
		{ words = { "surveillance" }, preset = "surveillance" },
		{ words = { "measurement", "technician", "measured" }, preset = "assoc_field" },
		{ words = { "clerk", "licences" }, preset = "assoc_agent" },
		{ words = { "researcher", "lab" }, preset = "assoc_research" },
		{ words = { "porter", "collection", "miner" }, preset = "collector" },
		{ words = { "noodle", "chef", "cook", "cooked" }, preset = "chef" },
		{ words = { "corner shop", "stall", "trader" }, preset = "shopkeeper" },
		{ words = { "rider", "courier" }, preset = "runner" },
		{ words = { "office", "accountant", "coworker" }, preset = "office" },
		{ words = { "class", "classmate", "school" }, preset = "student" },
		{ words = { "guild officer", "vice-master" }, preset = "commander" },
		{ words = { "strike team" }, preset = "striker" },
		{ words = { "rookie", "recruit" }, preset = "guild_recruit" },
	},
}

-- the party's own cards (Engine/Party.queueCard): about one person, who is {rel}
local CARDS = {
	memorial = "pt_memorial",
	betray = "pt_betray_", -- (one a rank: pt_betray_E .. pt_betray_S, the hunt is as hard as they are)
	leave_pay = "pt_leave_pay",
	leave_doubt = "pt_leave_doubt",
	leave_offer = "pt_leave_offer",
	leave_own = "pt_leave_own",
	seek = "pt_seek",
}

M.party = {
	max = 4, -- party members, besides you
	minAge = 16, -- you can lead a party from 16
	relMinAge = 16, -- nobody younger is asked into one
	retireAge = 62,
	baseOdds = 0.3,
	rosterMeet = 0.14, -- a year's chance of meeting someone from the game's roster
	tiers = { 15, 30, 44, 58, 70, 84 }, -- the bond the 1st, 2nd... line of a backstory needs
	presets = PRESETS,
	gifts = GIFTS,
	likes = LIKES,
	dislikes = DISLIKES,
	lines = LINES,
	backstory = BACKSTORY,
	trainLogs = TRAIN_LOGS,
	cards = CARDS,
	cast = CAST,
	castMeet = CAST_MEET,
}

-- what spec.people takes
M.people = { interactions = M.interactions, met = M.met }

-- ── the cards ──────────────────────────────────────────────────────────────
local function partyCard(e)
	e.weight = 0
	e.partyCard = true
	e.when = { flags = { "pt_on_" .. e.id } }
	e.tags = e.tags or { "people" }
	return e
end

M.cards = {
	partyCard({
		id = "pt_memorial",
		title = "For {rel}",
		text = "The party's room is too quiet. {relName}'s jacket is still on its hook by the door, and somebody has left a cup of barley tea on the bench under it. The others keep looking at you, as if you're supposed to know what to say.",
		art = "home",
		choices = {
			{ label = "Say something for them", hint = "Their name, and three true things about them.", result = { sanity = 2, charisma = 1, partyLoyalty = { 3, 6 }, log = "You said {rel}'s name, and three true things about them. Nobody looked at the floor after that." } },
			{ label = "Visit their family", hint = "Bring something. Answer what they ask.", result = { money = -2, sanity = 1, willpower = 1, partyLoyalty = { 4, 8 }, log = "{rel}'s family made you tea and asked what the last day was like. You told them the parts they could carry." } },
			{ label = "Go straight back to work", hint = "The Gates don't wait.", result = { sanity = -3, willpower = 2, partyLoyalty = { -4, -1 }, log = "You took the next Gate that same week. The others followed you in. Nobody said anything about it, which said a lot." } },
		},
	}),
	partyCard({
		id = "pt_leave_pay",
		title = "{rel} wants paying",
		text = "{relName} catches you after a raid, not quite meeting your eyes. 'I've got rent too,' they say. 'The retainer we agreed. I can't keep coming in on promises.'",
		art = "street",
		choices = {
			{ label = "Pay what you owe, and next year up front", hint = "Their retainer, all of it.", result = { partyPay = 1, bond = { 2, 4 }, log = "You paid it on the spot. {rel} let out a breath they'd been holding for months." } },
			{
				label = "Ask for one more year on trust",
				hint = "They like you. Is it enough?",
				clash = { stat = "charisma", foe = "{rel}'s patience", coins = 2, base = 6, coinPower = 3, fixed = true },
				win = { loyalty = { 4, 8 }, bond = 2, log = "'One more year,' {rel} said. 'Because it's you.'" },
				lose = { partyLeave = true, bond = { -8, -4 }, log = "{rel} shook their head and handed back the party jacket." },
			},
			{ label = "Let them go", hint = "You can't pay them. You know it.", result = { partyLeave = true, bond = { -3, 0 }, sanity = -1, log = "You told {rel} you understood. You did. It didn't make it easier." } },
		},
	}),
	partyCard({
		id = "pt_leave_doubt",
		title = "{rel} has doubts",
		text = "{relName} has been quiet since the last Gate. Tonight, on the steps outside the Association branch, they finally say it: 'I'm not sure I believe in this party any more. In where you're taking us.'",
		art = "night",
		choices = {
			{
				label = "Talk it through, honestly",
				hint = "No promises you can't keep.",
				clash = { stat = "charisma", foe = "{rel}'s doubts", coins = 2, base = 7, coinPower = 3, fixed = true },
				win = { loyalty = { 10, 16 }, bond = { 4, 8 }, log = "You talked until the street lamps came on. {rel} said they'd stay, and you believed them." },
				lose = { partyLeave = true, bond = { -4, -1 }, log = "{rel} listened to all of it, and left anyway." },
			},
			{ label = "Offer them a bigger share", hint = "Five points more of every take.", result = { partyShare = 0.05, loyalty = { 8, 12 }, log = "A bigger share. {rel} took it, and didn't quite look happy about it." } },
			{ label = "Tell them they're free to go", hint = "With your thanks.", result = { partyLeave = true, bond = { 2, 5 }, log = "You told {rel} they were free to go, with your thanks. They hugged you on the steps." } },
		},
	}),
	partyCard({
		id = "pt_leave_offer",
		title = "A better offer",
		text = "A bigger guild has offered {relName} a strike-team place: a real salary, a Healer on every raid, their name on the board in the lobby. They've come to tell you before they decide. That's something.",
		art = "office",
		choices = {
			{ label = "Match it", hint = "8 now, and a bigger share from here on.", requires = { min = { money = 8 } }, result = { money = -8, partyShare = 0.04, loyalty = { 8, 12 }, log = "You matched it. {rel} looked at you for a long moment and said, 'You really want me here.' You did." } },
			{
				label = "Remind them who had their back",
				hint = "Every Gate you walked out of together.",
				clash = { stat = "charisma", foe = "A better offer", coins = 3, base = 8, coinPower = 3, fixed = true },
				win = { loyalty = { 10, 15 }, bond = { 3, 6 }, log = "{rel} turned the guild down the next morning. They didn't say why. They didn't have to." },
				lose = { partyLeave = true, bond = { -4, -2 }, log = "{rel} took the offer. They sent a photo from their first raid with the new guild. You didn't answer for a week." },
			},
			{ label = "Wish them well", hint = "They'd be good there.", result = { partyLeave = true, bond = { 4, 8 }, sanity = 1, log = "You told {rel} to take it. They were going to be good there. You meant every word." } },
		},
	}),
	partyCard({
		id = "pt_leave_own",
		title = "{rel}'s own reasons",
		text = "{relName} wants to talk somewhere quiet. Their family needs them closer to home, their knees ache in the cold, they've been dreaming about Gates. It's all true, and none of it is about you.",
		art = "home",
		choices = {
			{
				label = "Ask them to stay one more season",
				hint = "Just one.",
				clash = { stat = "charisma", foe = "{rel}'s reasons", coins = 2, base = 6, coinPower = 3, fixed = true },
				win = { loyalty = { 8, 12 }, log = "'One more season,' {rel} said, and smiled for the first time in weeks." },
				lose = { partyLeave = true, bond = { 1, 3 }, log = "{rel} stayed for one last raid, then hung the party jacket on the hook by the door." },
			},
			{ label = "Let them go, with your blessing", hint = "They've earned it.", result = { partyLeave = true, bond = { 4, 8 }, sanity = 1, log = "You helped {rel} carry their gear down to the car. They said they'd call. They did, for years." } },
		},
	}),
	partyCard({
		id = "pt_seek",
		title = "Someone wants in",
		text = "{relName} has heard about your party: who you've brought home, and what you've cleared. They find you after a raid and ask, straight out, whether there's room for one more.",
		art = "street",
		choices = {
			{ label = "Welcome them", hint = "They're asking you. No odds to beat.", result = { partyJoin = true, bond = { 4, 8 }, log = "You shook on it. {rel} grinned like they'd already won something." } },
			{ label = "Not right now", hint = "There'll be other years.", result = { bond = { -3, -1 }, log = "{rel} nodded and said they understood. They'd ask again." } },
		},
	}),
}

-- the betrayal: one card a rank, because hunting someone down is as hard as they are
local BETRAY_HURT = { { -12, -5 }, { -22, -9 }, { -36, -16 }, { -60, -26 }, { -100, -46 }, { -180, -80 } }
-- (built a piece at a time: one constructor this deep inside a loop trips the Luau VM)
local function betrayCard(r: number): any
	local L = RANKS[r]
	local foe = HW.foe(r)
	local huntClash = { stat = "strength", foe = "{relName}", coins = foe.coins, coinPower = foe.coinPower, fight = true, fixed = true }
	huntClash.base = math.max(1, math.floor(foe.base * 0.85 + 0.5))
	huntClash.party = { rank = r, kind = "city" }
	local hunt = {
		label = "Hunt them down",
		hint = "They're " .. L .. "-rank, and they'll know you're coming. Your party comes with you.",
		clash = huntClash,
		win = { partyRecover = 0.7, charisma = 1, sanity = -1, log = "You found {rel} two cities over. You didn't have to say anything. They gave most of it back, and you never saw them again." },
		lose = { vitality = BETRAY_HURT[r], sanity = -4, log = "You found {rel}. They were ready for you.", cause = "Killed going after a party member who betrayed them" },
	}
	local reportIt = {
		label = "Report them to the Surveillance Team",
		hint = "Paperwork, and patience.",
		clash = { stat = "intelligence", foe = "The paperwork", coins = 2, base = 4 + r, coinPower = 3, fixed = true },
		win = { partyRecover = 0.4, log = "The Surveillance Team froze {rel}'s accounts within the month. You got back what was left." },
		lose = { sanity = -2, log = "The report went onto a pile with a great many other reports." },
	}
	local letGo = { label = "Let it go", hint = "The party is watching how you take it.", result = { sanity = -3, willpower = 2, partyLoyalty = { 2, 5 }, log = "You let it go. The rest of the party watched how you took it, and stayed closer for it." } }
	local card = {
		id = "pt_betray_" .. L,
		title = "Gone, and the money with them",
		text = "{relName} didn't come to the briefing. By noon the party's account was lighter by a sum you checked three times, and their phone was off. A " .. L .. "-rank Hunter who doesn't want to be found is very hard to find.",
		art = "night",
		tags = { "people", "danger" },
	}
	card.choices = { hunt, reportIt, letGo }
	return partyCard(card)
end
for r = 1, 6 do
	-- (into a local first: table.insert(t, f()) with this call traps Lune's Luau VM)
	local card = betrayCard(r)
	M.cards[#M.cards + 1] = card
end

return M
