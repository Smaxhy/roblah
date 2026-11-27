--[[
	REPRISALS: what comes for you when a faction holds a grudge (Reputation.luau).

	None of these are rolled like ordinary events (weight = 0). Once a year, a faction whose
	standing with you is at its `grudge` or worse may queue one. The worse the standing, the surer.
	Every one of them offers a way to pay the debt down, a way to fight it, and a way to make it
	worse. Some aren't aimed at you.

	Violence is implied, never shown; nobody under 18 is the target.
]]

local FAMILY = { "mother", "father", "sibling", "child", "friend", "mentor" }

return {
	-- ════ THE THUMB: propriety, and a ledger ═══════════════════════════════════
	{
		id = "rep_thumb_correction",
		title = "A Correction",
		art = "alley",
		text = {
			"Two Soldati in pressed suits are waiting at the end of your street. They don't block it. They stand so that the only way past is between them.",
			"A man in a pressed suit falls into step beside you. A second one is already behind. Neither is in any hurry, and neither is the street, which has emptied.",
		},
		dialogue = { { who = "thumb_soldato", line = { "You raised a hand to the Thumb. We are here to correct the account.", "There is an entry against your name. We've come to close it. Politely, if you allow it." } } },
		weight = 0,
		cooldown = 2,
		when = { minAge = 16, maxRep = { thumb = -20 } },
		choices = {
			{
				label = "Kneel, and take the correction",
				hint = "It will hurt. It will also be over.",
				result = { health = { -14, -8 }, sanity = -4, rep = { thumb = 12 }, condition = "broken_arm", log = "You knelt. It was done formally, in order of rank, and they thanked you for your cooperation before they left. The entry is smaller now." },
			},
			{
				label = "Pay the insult's weight in Ahn",
				hint = "300 Ahn",
				requires = { min = { money = 300 } },
				result = { money = -300, rep = { thumb = 15 }, log = "The older one counted it twice, wrote a receipt, and bowed exactly as low as the sum deserved." },
			},
			{
				label = "Fight them both",
				clash = { stat = "strength", foe = "Two Thumb Soldati", coins = 3, base = 6, coinPower = 3, fight = true, enemy = "thumb_soldato" },
				win = { strength = 2, sanity = -2, rep = { thumb = -15 }, log = "You put both of them on the cobbles. One of them, from the ground, took out a small book and wrote something in it." },
				lose = { health = { -22, -12 }, condition = "broken_arm", rep = { thumb = 6 }, cause = "Corrected by the Thumb", log = "They were thorough, and then they were finished, and they stepped over you on the way out." },
			},
		},
	},
	{
		id = "rep_thumb_ledger",
		title = "An Entry in the Ledger",
		art = "home",
		text = {
			"A card is nailed to your door: heavy paper, black edge. One line in a careful hand: your name, a sum, and a date by which respect is to be paid.",
			"Your landlord won't meet your eyes. Someone in a good suit came by, he says, and asked what you earn, where you eat, and who you love. He wrote the answers down.",
		},
		weight = 0,
		cooldown = 3,
		when = { minAge = 16, maxRep = { thumb = -20 } },
		choices = {
			{ label = "Pay what the card says", hint = "200 Ahn", requires = { min = { money = 200 } }, result = { money = -200, rep = { thumb = 10 }, log = "You left it at the tailor's that everyone knows isn't a tailor's. Nobody thanked you. The card was gone from your door by morning." } },
			{
				label = "Go and apologise in person, properly",
				hint = "A Charisma check. Every bow is graded.",
				clash = { stat = "charisma", foe = "A Capo's patience", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 2, rep = { thumb = 18 }, log = "The right bow, the right title, eyes down until spoken to. The Capo let you stand there for an hour and then said the matter was closed." },
				lose = { health = { -10, -5 }, sanity = -4, rep = { thumb = -5 }, log = "You used the wrong title. A Soldato explained the difference with the back of his hand, twice, and showed you the door." },
			},
			{ label = "Tear the card off the door", result = { sanity = 2, rep = { thumb = -10 }, log = "It felt good for about a day." } },
		},
	},
	{
		id = "rep_thumb_family",
		title = "They Went to Your Family",
		art = "home",
		text = {
			"The Thumb doesn't always collect from the one who owes. A man in a pressed suit has called on someone you love, taken tea, and admired how easily a home like theirs could burn.",
			"Someone you love has had a visitor. He was very polite. He left a black-edged card on their table and said he'd come back for an answer.",
		},
		weight = 0,
		cooldown = 4,
		when = { minAge = 16, maxRep = { thumb = -30 }, hasRelation = FAMILY },
		choices = {
			{
				label = "Go to the Thumb and offer yourself instead",
				result = { health = { -18, -10 }, sanity = -6, rep = { thumb = 20 }, relationBond = { kind = "all", amount = 8 }, condition = "broken_arm", log = "They accepted the substitution. It was done to you, by the book, and the card was returned to you with the debt struck through." },
			},
			{
				label = "Get them out of the District tonight",
				hint = "A Speed check",
				clash = { stat = "speed", foe = "The Thumb's watchers", coins = 2, base = 5, coinPower = 3 },
				win = { money = { -120, -60 }, sanity = -2, relationBond = { kind = "all", amount = 12 }, log = "A handcart, a night train, a cousin three Districts over. By the time the suit came back for his answer, the rooms were empty." },
				lose = { killRelation = "sibling", sanity = -14, condition = "grief", rep = { thumb = 10 }, log = "They were watching the station. The Thumb considers the matter settled now. That's the word they used. Settled." },
			},
			{
				label = "Stand in their doorway when he comes back",
				clash = { stat = "strength", foe = "A Thumb Capo", coins = 3, base = 7, coinPower = 3, fight = true, enemy = "thumb_capo" },
				win = { strength = 2, rep = { thumb = -20 }, relationBond = { kind = "all", amount = 15 }, log = "He left without his hat. You have made an enemy of a family, he said from the stairs. You already had." },
				lose = { health = { -24, -14 }, killRelation = "mother", sanity = -12, condition = "grief", cause = "Killed in a Thumb reprisal", log = "You weren't enough. He said he regretted the necessity, and he sounded as if he meant it." },
			},
		},
	},
	{
		id = "rep_thumb_capo",
		title = "A Capo Has Taken an Interest",
		art = "office",
		text = "A car you could never afford is idling outside your building. The back window comes down a hand's width. This is what it looks like when the Thumb stops sending Soldati.",
		dialogue = { { who = "thumb_capo", line = "You've killed men of mine. I don't hold it against you. I simply can't allow it to have happened." } },
		weight = 0,
		once = true,
		when = { minAge = 18, maxRep = { thumb = -50 } },
		choices = {
			{
				label = "Get in the car",
				hint = "A Charisma check, for your life",
				clash = { stat = "charisma", foe = "A Thumb Capo", coins = 3, base = 6, coinPower = 3 },
				win = { rep = { thumb = 35 }, sanity = -6, setFlags = { "thumb_owes_service" }, log = "You talked for an hour. You'll owe the Thumb a service, he said, and you'll know it when it's asked. The car let you out where it found you." },
				lose = { health = { -30, -18 }, rep = { thumb = 15 }, cause = "Taken for a drive by the Thumb", log = "The car let you out somewhere else, later, and not kindly." },
			},
			{
				label = "Run",
				clash = { stat = "speed", foe = "The Thumb's men", coins = 3, base = 6, coinPower = 3 },
				win = { speed = 2, sanity = -4, log = "Over the wall, through the laundry, down the coal chute. You'll have to move, and soon." },
				lose = { health = { -26, -14 }, rep = { thumb = 10 }, cause = "Run down by the Thumb", log = "There was a second car." },
			},
			{
				label = "Draw first",
				clash = { stat = "strength", foe = "A Thumb Capo", coins = 4, base = 7, coinPower = 3, fight = true, enemy = "thumb_capo" },
				win = { strength = 3, rep = { thumb = -25 }, chronicle = "killed_a_capo", log = "Nobody in this District has done that in thirty years. Everybody will have heard by morning, and so will the Thumb." },
				lose = { die = "Killed by a Capo of the Thumb", log = "He didn't get out of the car." },
			},
		},
	},

	-- ════ THE INDEX: a Prescript with your name on it ═══════════════════════════
	{
		id = "rep_index_slip",
		title = "A Prescript, For You",
		art = "street",
		text = {
			"A Messenger in white is standing at your door with an envelope. There's no anger in it. The Index doesn't hold grudges. It only carries out what's written.",
			"Someone has slid a slip of paper under your plate at the noodle stall. White paper. Your name. One instruction, and a time.",
		},
		dialogue = { { who = "index_messenger", line = { "It's addressed to you. I don't know what it says. I never do.", "The will of the Prescript. Please read it before the hour written on the back." } } },
		weight = 0,
		cooldown = 2,
		when = { minAge = 16, maxRep = { index = -20 } },
		choices = {
			{ label = "Do what it says", hint = "It asks for something that costs you", result = { money = { -80, -30 }, sanity = -5, rep = { index = 14 }, log = "It told you to give away the thing in your left pocket to the first person who asked the time. You did. It was your pay." } },
			{
				label = "Read it for a way around the words",
				hint = "An Intelligence check",
				clash = { stat = "intelligence", foe = "The wording of a Prescript", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, rep = { index = 8 }, log = "It said to give up what you hold dearest in your left hand. You held a pebble. The Messenger watched, and wrote nothing down, and left." },
				lose = { sanity = -6, rep = { index = -6 }, log = "There wasn't a way around it. There was a Proxy at the end of the street, waiting to see if you'd find one." },
			},
			{ label = "Burn it unread", result = { sanity = 3, rep = { index = -12 }, log = "It burned like any paper. Unfulfilled Prescripts are noted, and seen to." } },
		},
	},
	{
		id = "rep_index_proxy",
		title = "A Proxy at Your Door",
		terms = { "Proxy" },
		art = "alley",
		text = "A Prescript you ignored has been reissued, and this one isn't addressed to you. It's addressed to the person holding the blade.",
		dialogue = { { who = "index_proxy", line = "It was written. I am sorry that it was written about you." } },
		weight = 0,
		cooldown = 3,
		when = { minAge = 18, maxRep = { index = -30 } },
		choices = {
			{
				label = "Fight the Proxy",
				clash = { stat = "strength", foe = "An Index Proxy", coins = 3, base = 7, coinPower = 3, fight = true, enemy = "index_proxy" },
				win = { strength = 2, rep = { index = -10 }, log = "The Proxy looked at the slip again, lying on its back. The Prescript did not say this, it said, and seemed almost glad." },
				lose = { health = { -26, -14 }, rep = { index = 20 }, cause = "A Prescript, carried out", log = "As written." },
			},
			{
				label = "Ask what would satisfy the Prescript",
				hint = "A Charisma check",
				clash = { stat = "charisma", foe = "An Index Proxy", coins = 2, base = 6, coinPower = 3 },
				win = { rep = { index = 22 }, sanity = -4, log = "It only says that your debt be ended, the Proxy said slowly. It doesn't say how. You walked a Prescript across the District for them, unread, and were even." },
				lose = { health = { -18, -8 }, rep = { index = 12 }, log = "The Prescript was quite specific, it turned out." },
			},
			{ label = "Run, and don't stop in this District", clash = { stat = "speed", foe = "An Index Proxy", coins = 2, base = 6, coinPower = 3 }, win = { speed = 2, sanity = -3, log = "You outran what was written, for now." }, lose = { health = { -20, -10 }, rep = { index = 15 }, cause = "A Prescript, carried out", log = "It was written that you'd run." } },
		},
	},
	{
		id = "rep_index_loved",
		title = "The Prescript Named Someone Else",
		art = "home",
		text = "A Messenger has delivered a slip to someone you love. They've read it. They won't tell you what it says, and they've started putting their affairs in order.",
		weight = 0,
		cooldown = 5,
		when = { minAge = 18, maxRep = { index = -40 }, hasRelation = FAMILY },
		choices = {
			{ label = "Take the slip and carry it out yourself", hint = "It was always meant for you", result = { health = { -16, -8 }, sanity = -8, rep = { index = 25 }, relationBond = { kind = "all", amount = 10 }, log = "The Index doesn't care whose hands. You did what it said. They never learned what it cost you, and you made sure of that." } },
			{
				label = "Hide them where a Messenger can't find them",
				clash = { stat = "intelligence", foe = "The Index", coins = 3, base = 6, coinPower = 3 },
				win = { intelligence = 2, money = { -100, -40 }, relationBond = { kind = "all", amount = 12 }, log = "A different name, a different District, a room with no letterbox. Prescripts need an address." },
				lose = { killRelation = "friend", sanity = -14, condition = "grief", rep = { index = 20 }, log = "There was a letterbox. There's always a letterbox." },
			},
			{ label = "Do nothing. It isn't your Prescript.", result = { killRelation = "friend", sanity = -16, condition = "grief", rep = { index = 20 }, log = "They did what it said. It said to walk out past the wall at three in the morning. You weren't told until after." } },
		},
	},

	-- ════ THE MIDDLE: the Book of Vengeance ═════════════════════════════════════
	{
		id = "rep_middle_book",
		title = "The Book of Vengeance",
		art = "alley",
		text = {
			"A Little Sibling of the Middle is reading aloud from a notebook outside your door: the date, the street, and exactly what you did to one of theirs. Then what's owed for it.",
			"There's a tally chalked on your wall. The Middle writes down every slight and repays each one, the same, and then a little more.",
		},
		dialogue = { { who = "middle_sibling", line = { "You touched one of us. It's in the Book. We always pay what's in the Book.", "Big Brother says an eye is an eye, and then one more for the trouble." } } },
		weight = 0,
		cooldown = 2,
		when = { minAge = 16, maxRep = { middle = -15 } },
		choices = {
			{ label = "Let them take what's owed", result = { health = { -12, -6 }, rep = { middle = 14 }, log = "The same as you gave, and one more. Then the Sibling crossed out the line and wished you a good evening, and meant it." } },
			{
				label = "Offer something the Family wants more",
				hint = "A Charisma check",
				clash = { stat = "charisma", foe = "A Middle Sibling's sums", coins = 2, base = 5, coinPower = 3 },
				win = { money = { -90, -40 }, rep = { middle = 20 }, log = "A favor outweighs a bruise, by the Book's own arithmetic. They wrote the favor down too. They'll collect it." },
				lose = { health = { -14, -8 }, rep = { middle = 6 }, log = "The Book doesn't take substitutes. They explained this at length." },
			},
			{
				label = "Fight them off",
				clash = { stat = "strength", foe = "Middle Little Siblings", coins = 3, base = 6, coinPower = 3, fight = true, enemy = "middle_sibling" },
				win = { strength = 2, rep = { middle = -14 }, log = "You won. The last one standing wrote that down as well, before he limped off to fetch someone bigger." },
				lose = { health = { -20, -10 }, rep = { middle = 10 }, cause = "Repaid by the Middle", log = "Paid in full, one of them said, and it was." },
			},
		},
	},
	{
		id = "rep_middle_same",
		title = "A Big Sibling Calls",
		art = "street",
		text = "The Little Siblings told someone. He fills your doorway. He has a book too, a thicker one, and he's found your page.",
		dialogue = { { who = "middle_big", line = "My little ones told me about you. I don't mind what you did. I mind that it isn't paid." } },
		weight = 0,
		cooldown = 3,
		when = { minAge = 18, maxRep = { middle = -35 } },
		choices = {
			{
				label = "Stand your ground",
				clash = { stat = "strength", foe = "A Middle Big Sibling", coins = 3, base = 8, coinPower = 3, fight = true, enemy = "middle_big" },
				win = { strength = 3, rep = { middle = -20 }, log = "He went down like a wall coming in. The whole Family will come now, he said. He wasn't boasting. He was telling you the rule." },
				lose = { health = { -28, -16 }, rep = { middle = 18 }, cause = "Repaid by a Big Sibling of the Middle", log = "He paid the page off in one go." },
			},
			{ label = "Ask to work the debt off for the Family", hint = "A year of their errands", result = { sanity = -6, money = { -60, -20 }, rep = { middle = 30 }, log = "He thought about it, and tore your page out, and wrote your name in a different book. You carry things for the Middle now, when they ask." } },
			{ label = "Go out the window", clash = { stat = "speed", foe = "A Middle Big Sibling", coins = 2, base = 5, coinPower = 3 }, win = { speed = 2, log = "He's strong. He isn't quick." }, lose = { health = { -22, -12 }, rep = { middle = 12 }, cause = "Caught by the Middle", log = "He was quick enough." } },
		},
	},
	{
		id = "rep_middle_family",
		title = "In Kind",
		art = "home",
		text = "The Middle repays in kind. You hurt one of their family. So the Book has a line in it now about one of yours.",
		weight = 0,
		cooldown = 5,
		when = { minAge = 18, maxRep = { middle = -45 }, hasRelation = FAMILY },
		choices = {
			{ label = "Go to them and take it yourself", result = { health = { -20, -12 }, sanity = -6, rep = { middle = 28 }, condition = "broken_arm", log = "The Middle respects that, more than almost anything. They did it to you instead, and a Big Sibling shook your hand afterwards with the good one." } },
			{
				label = "Guard their door every night this season",
				clash = { stat = "strength", foe = "The Middle's errand", coins = 3, base = 7, coinPower = 3, fight = true, enemy = "middle_big" },
				win = { strength = 2, sanity = -4, rep = { middle = -10 }, relationBond = { kind = "all", amount = 14 }, log = "They came on the ninth night. You were awake. They're still owed, the Book says. So are you, now." },
				lose = { health = { -22, -12 }, killRelation = "father", sanity = -14, condition = "grief", rep = { middle = 25 }, log = "You couldn't be at two doors. The Book has a line through it now." },
			},
			{ label = "Pay a blood price in Ahn", hint = "500 Ahn", requires = { min = { money = 500 } }, result = { money = -500, rep = { middle = 30 }, log = "There's a price in the Book for everything. A Big Sibling counted it, nodded, and drew the line through." } },
		},
	},

	-- ════ THE RING: you'd make a fine subject ═══════════════════════════════════
	{
		id = "rep_ring_portrait",
		title = "Someone Has Been Sketching You",
		art = "theater",
		text = {
			"There are drawings of you pasted along your street. Your face, your walk, the way you hold your shoulders. They're very good. In each one, something has been improved.",
			"A student of the Ring has been following you with a sketchbook. Today she asked you, very earnestly, to hold still.",
		},
		weight = 0,
		cooldown = 3,
		when = { minAge = 16, maxRep = { ring = -20 } },
		choices = {
			{ label = "Tear them all down", result = { sanity = -3, rep = { ring = -6 }, log = "There were more the next morning. Better ones." } },
			{
				label = "Find the student and break her brushes",
				clash = { stat = "strength", foe = "A Ring Student", coins = 2, base = 5, coinPower = 3, fight = true, enemy = "ring_artist" },
				win = { strength = 1, rep = { ring = -10 }, sanity = 2, log = "She cried about the brushes. Then she looked at your hands, thoughtfully, as if they'd given her an idea." },
				lose = { health = { -16, -8 }, sanity = -8, rep = { ring = 12 }, log = "You held still after all. She finished the sketch." },
			},
			{ label = "Sit for a portrait, and get it over with", hint = "A Mental Strength check", clash = { stat = "mind", foe = "Being looked at by the Ring", coins = 2, base = 5, coinPower = 3 }, win = { mind = 2, rep = { ring = 18 }, log = "Three hours. She said you were a difficult subject and she meant it kindly. The drawings stopped." }, lose = { sanity = -12, rep = { ring = 14 }, condition = "night_terrors", log = "You saw the finished piece. You wish you hadn't." } },
		},
	},
	{
		id = "rep_ring_exhibit",
		title = "An Invitation to an Exhibition",
		art = "theater",
		text = "A card on thick cream paper: the Ring requests your presence at an opening. You are listed in the programme. Not as a guest.",
		weight = 0,
		once = true,
		when = { minAge = 18, maxRep = { ring = -40 } },
		choices = {
			{ label = "Don't go, and move house", result = { money = { -150, -60 }, sanity = -4, log = "A new street, a new lock. You check the walls for drawings every morning." } },
			{
				label = "Go, and wreck the exhibition",
				clash = { stat = "strength", foe = "A Docent of the Ring", coins = 3, base = 8, coinPower = 3, fight = true, enemy = "ring_artist" },
				win = { strength = 3, rep = { ring = -15 }, chronicle = "wrecked_exhibit", log = "The critics called it the most honest piece of the season. The Ring was not amused, which the critics also noted." },
				lose = { die = "Exhibited by the Ring", log = "You were the centrepiece. The reviews were excellent." },
			},
		},
	},

	-- ════ SYNDICATES, CLANS AND THE STREET ══════════════════════════════════════
	{
		id = "rep_kurokumo_wave",
		title = "The Dark Wave",
		art = "alley",
		text = "It's raining, which is when the Kurokumo Clan settles its accounts. Three Wakashu with long blades are standing under the one working streetlight, and they've left you a gap to walk through.",
		weight = 0,
		cooldown = 3,
		when = { minAge = 16, maxRep = { kurokumo = -20 } },
		choices = {
			{ label = "Walk through, and bow to the eldest", hint = "A Charisma check", clash = { stat = "charisma", foe = "Kurokumo manners", coins = 2, base = 5, coinPower = 3 }, win = { rep = { kurokumo = 16 }, log = "He looked at the bow for a long time, and at the rain, and stepped aside." }, lose = { health = { -16, -8 }, rep = { kurokumo = 6 }, condition = "deep_cut", log = "Not low enough." } },
			{
				label = "Fight in the rain",
				clash = { stat = "strength", foe = "Kurokumo Wakashu", coins = 3, base = 7, coinPower = 3, fight = true, enemy = "kurokumo", status = "bleed" },
				win = { strength = 2, rep = { kurokumo = -12 }, log = "Three blades in the gutter and the streetlight still working. The Clan will send an older brother." },
				lose = { health = { -24, -12 }, condition = "deep_cut", rep = { kurokumo = 12 }, cause = "Cut down by the Kurokumo Clan", log = "They cleaned their blades on your coat." },
			},
			{ label = "Take the long way home, for good", result = { sanity = -3, speed = 1, log = "You know every roof between your door and the market now." } },
		},
	},
	{
		id = "rep_syndicate_shop",
		title = "The Place You Eat",
		art = "street",
		text = {
			"The noodle stall you eat at every week has a boarded window and a new sign: closed until a certain customer settles up. The owner won't look at you.",
			"Your landlord has had visitors. Your rent has doubled, he says, for as long as certain people are unhappy with you. He's sorry. He has children.",
		},
		weight = 0,
		cooldown = 2,
		when = { minAge = 14 },
		choices = {
			{ label = "Pay for the window, and the insult", hint = "120 Ahn", requires = { min = { money = 120 } }, result = { money = -120, sanity = -2, rep = { rats = 8, kurokumo = 8 }, log = "The window went back in. The owner gave you a bowl on the house and asked you, gently, to eat somewhere else for a while." } },
			{ label = "Find who did it", clash = { stat = "strength", foe = "Syndicate Enforcers", coins = 2, base = 5, coinPower = 3, fight = true, enemy = "syndicate" }, win = { strength = 1, sanity = 2, rep = { rats = -6 }, log = "They'll think twice about that stall. They'll think harder about you." }, lose = { health = { -16, -8 }, money = { -40, -10 }, log = "There were more of them than the owner said." } },
			{ label = "Eat somewhere else", result = { sanity = -3, log = "The other stall isn't as good. Nothing about this year is." } },
		},
	},
	{
		id = "rep_rats_alley",
		title = "Every Rat Knows Your Face",
		art = "alley",
		text = {
			"The alley is too quiet. Then it isn't: six of them, from both ends, with pipes and a crowbar and the particular grin of people who've been told a name.",
			"A kid whistles twice from a rooftop as you pass. By the corner there's a pack of Rats in your way, and the one in front is wearing your old coat.",
		},
		weight = 0,
		cooldown = 2,
		when = { minAge = 12, maxRep = { rats = -25 } },
		choices = {
			{ label = "Run", clash = { stat = "speed", foe = "A pack of Rats", coins = 2, base = 4, coinPower = 3 }, win = { speed = 2, log = "Rats are quick. You know the roofs better." }, lose = { health = { -16, -8 }, money = { -40, -10 }, cause = "Cornered by Rats", log = "They took their time, and your shoes." } },
			{ label = "Take the biggest one first", clash = { stat = "strength", foe = "A pack of Rats", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "rat_boss" }, win = { strength = 2, rep = { rats = 10 }, log = "The rest remembered somewhere they had to be. Rats respect exactly one thing." }, lose = { health = { -20, -10 }, money = { -50, -10 }, cause = "Beaten by Rats", log = "Six is a lot." } },
			{ label = "Pay the toll, with interest", hint = "60 Ahn", requires = { min = { money = 60 } }, result = { money = -60, rep = { rats = 12 }, log = "Rats don't hold grudges anybody's willing to pay for." } },
		},
	},

	-- ════ FIXERS, WINGS, FAMILIES ═══════════════════════════════════════════════
	{
		id = "rep_fixers_contract",
		title = "A Contract With Your Description",
		art = "office",
		text = "Someone has paid an Office to deal with you. It isn't personal. There's a slip on a job board somewhere with your height, your street, and a fee beside it.",
		dialogue = { { who = "fixer", line = { "Nothing personal. You're a Grade 7 job and I've got rent.", "You're on a board. I took the slip. That's all this is." } } },
		weight = 0,
		cooldown = 3,
		when = { minAge = 18, maxRep = { fixers = -25 } },
		choices = {
			{ label = "Buy the contract out", hint = "250 Ahn", requires = { min = { money = 250 } }, result = { money = -250, rep = { fixers = 14 }, log = "A Fixer will always take the better fee. She tore the slip in half and gave you a receipt." } },
			{ label = "Fight the Fixer", clash = { stat = "strength", foe = "A Fixer on contract", coins = 3, base = 7, coinPower = 3, fight = true, enemy = "fixer" }, win = { strength = 2, rep = { fixers = -8 }, log = "She'll report the job as above its grade. The next slip will have a bigger number on it." }, lose = { health = { -26, -14 }, cause = "Killed on contract by a Fixer", log = "Grade 7 was about right." } },
			{ label = "Talk to her about who paid", hint = "A Charisma check", clash = { stat = "charisma", foe = "A Fixer's professionalism", coins = 2, base = 5, coinPower = 3 }, win = { charisma = 2, rep = { fixers = 10 }, log = "Offices don't name clients. She named the street the client lives on, which isn't the same thing, technically." }, lose = { health = { -14, -6 }, log = "She's a professional." } },
		},
	},
	{
		id = "rep_fixers_blacklist",
		title = "Your Name on a List",
		art = "office",
		text = "Doors that used to open are staying shut. Somewhere your name has gone onto a list: jobs you won't be offered, counters you won't be served at, people who've been told not to know you.",
		weight = 0,
		cooldown = 3,
		when = { minAge = 18 },
		choices = {
			{ label = "Take worse work for a while", result = { money = { -80, -30 }, sanity = -4, log = "You carried crates for a season under somebody else's name." } },
			{ label = "Find who keeps the list, and reason with them", hint = "A Charisma check", clash = { stat = "charisma", foe = "A clerk with a list", coins = 2, base = 5, coinPower = 3 }, win = { charisma = 2, rep = { fixers = 10, limbus = 10 }, log = "Lists are kept by clerks. Clerks have rent. Your name moved from one page to another." }, lose = { sanity = -5, log = "The clerk added a note beside your name." } },
		},
	},
	{
		id = "rep_wings_gate",
		title = "The Gates Know Your Face",
		art = "nest",
		text = "A Wing doesn't send anyone after you. It simply stops letting you in. The checkpoint reads your face, and the guard's hand moves to something under the desk.",
		weight = 0,
		cooldown = 2,
		when = { minAge = 16 },
		choices = {
			{ label = "Turn around before he decides", result = { sanity = -3, log = "The Backstreets don't have gates. That's the best and worst thing about them." } },
			{ label = "Bribe the shift", hint = "150 Ahn", requires = { min = { money = 150 } }, result = { money = -150, rep = { wings = 10, lcorp = 10 }, log = "A flag on a file can be moved to another file. It costs what a guard makes in a month." } },
			{ label = "Force the checkpoint", clash = { stat = "strength", foe = "Wing Security", coins = 3, base = 7, coinPower = 3, fight = true, enemy = "wing_guard" }, win = { strength = 2, rep = { wings = -15, lcorp = -15 }, log = "You're through. You're also on every camera a Wing owns." }, lose = { health = { -24, -12 }, condition = "broken_arm", cause = "Shot at a Nest checkpoint", log = "They're trained for exactly this." } },
		},
	},
	{
		id = "rep_wings_audit",
		title = "An Audit",
		art = "nest",
		text = "A Wing settles its grudges with paperwork. A notice has come: back taxes on a residence you never held, a fine for a permit that doesn't exist, and a date.",
		weight = 0,
		cooldown = 3,
		when = { minAge = 18 },
		choices = {
			{ label = "Pay it", hint = "200 Ahn", requires = { min = { money = 200 } }, result = { money = -200, rep = { wings = 12, lcorp = 12 }, log = "The stamp on the receipt was very small and very final." } },
			{ label = "Contest it, form by form", hint = "An Intelligence check", clash = { stat = "intelligence", foe = "A Wing's paperwork", coins = 3, base = 6, coinPower = 3 }, win = { intelligence = 2, rep = { wings = 6 }, log = "Fourteen forms. You found the clause they'd hoped you wouldn't. Somebody in an office had to initial a retraction." }, lose = { money = { -260, -140 }, sanity = -4, log = "There was a fee for contesting it." } },
			{ label = "Ignore it", result = { rep = { wings = -8, lcorp = -8 }, sanity = 2, log = "The next notice was printed in red." } },
		},
	},
	{
		id = "rep_family_night",
		title = "The Families Remember",
		art = "theater",
		text = "Bloodfiends don't hurry. One of a Family has been standing across from your window every night this week, perfectly still, in evening dress. Tonight there's a note under your door, in a very old hand.",
		weight = 0,
		cooldown = 4,
		when = { minAge = 18, maxRep = { bloodfiends = -20 } },
		choices = {
			{ label = "Answer the note, with every courtesy", hint = "A Charisma check", clash = { stat = "charisma", foe = "A Family's etiquette", coins = 2, base = 6, coinPower = 3 }, win = { charisma = 2, rep = { bloodfiends = 20 }, log = "They value a well-turned apology above almost anything, having heard so many bad ones. The window stayed empty after that." }, lose = { health = { -14, -6 }, sanity = -6, rep = { bloodfiends = 4 }, log = "Your phrasing gave offence. It was explained to you, slowly." } },
			{ label = "Go out and face it", clash = { stat = "strength", foe = "A Bloodfiend of the Family", coins = 3, base = 8, coinPower = 3, fight = true, enemy = "bloodfiend", status = "bleed" }, win = { strength = 3, rep = { bloodfiends = -15 }, log = "It left the way mist leaves. They have a great deal of time, the note had said. You believe it." }, lose = { health = { -28, -16 }, sanity = -8, cause = "Taken by a Family", log = "It was very polite about it." } },
			{ label = "Sleep somewhere with a lot of people", result = { sanity = -5, money = { -40, -15 }, log = "A crowded bunkhouse, a lit stairwell. They prefer not to be seen working." } },
		},
	},
}
