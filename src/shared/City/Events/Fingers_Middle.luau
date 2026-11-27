--[[
	The Middle: family, tattoos, the Book of Vengeance, Little/Big/Great Siblings, and what it
	means to have your name (or your neighbor's) written in the Book. Canon: docs/CANON.md 3.3;
	the Pilgrimage of Loyalty and the Book's Title/Section/Row layout come from Limbus text.
	Flags: fn_middle_grudge (shared hook: the Middle swore vengeance on you, always paired with
	the in_the_book condition and the fn_written_in_book act), fn_middle_favor (the family owes you).
]]

-- your name goes in the Book: the grudge, the condition, the news
local function inBook(log: string, extra: { [string]: any }?)
	local r = { setFlags = { "fn_middle_grudge" }, condition = "in_the_book", chronicle = "fn_written_in_book", sanity = -5, codex = "fn_lore_book", log = log }
	for k, v in extra or {} do
		r[k] = v
	end
	return r
end

local PALOMA = { kind = "mentor", name = "Paloma Ferrant", bond = 70, age = { 32, 42 } }

return {
	-- ── members ──
	{
		id = "fn_middle_tattoo",
		title = "The Family Mark",
		text = "You're a Little Sibling of the Middle now, and tonight you get your tattoo. Big Sister Paloma holds your hand the whole time and recites the creed while the needle works: the Middle remembers, and the Middle always pays its debts, in whichever form. When it's done, a dozen Siblings you've never met hug you like you've come home.",
		weight = 26,
		once = true,
		tags = { "fingers" },
		when = { career = "middle", notFlags = { "fn_middle_big" } },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Swear the creed back to her",
				result = { sanity = 5, addTrait = "middle_family", addRelation = PALOMA, log = "You swore it back, word for word. Big Sister Paloma pressed her forehead to yours and called you Little Sibling. You have more family now than you know what to do with." },
			},
			{
				label = "Ask what happens to Siblings who leave",
				result = { mind = 2, sanity = -2, log = "Big Sister Paloma stopped smiling for exactly as long as it took to say, \"Nobody leaves family.\" Then she smiled again, which was worse." },
			},
			{
				label = "Ask to hold the Book",
				result = { intelligence = 1, codex = "fn_lore_book", log = "She let you hold it for a moment: heavier than any book has a right to be, organized like a law code, every grudge filed by Title, Section, Row and Line." },
			},
		},
	},
	{
		id = "fn_middle_reading",
		title = "Reading the Sentence",
		text = "A Big Brother has hurt his reading hand, so tonight you read the sentence aloud. The man who stole from a Sibling's noodle stall is standing very still on the curb. You find the place in the Book: Title 3, Section 7, Row B, theft from a Sibling's livelihood. The punishment is written beside it in the Big Brother's careful hand.",
		weight = 22,
		once = true,
		tags = { "fingers" },
		when = { career = "middle", notFlags = { "fn_middle_big" } },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Read it exactly as written",
				result = { paycheck = 0.3, sanity = -4, setFlags = { "fn_middle_loyal" }, log = "You read the sentence in a clear voice, and the family carried it out. You don't remember the walk home." },
			},
			{
				label = "Read the lighter line below it",
				clash = { stat = "mind", foe = "A Big Brother who knows the Book by heart", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 2, setFlags = { "fn_middle_merciful" }, log = "You read Row C instead: repayment, with interest. The Big Brother looked at you for a long time, then nodded. \"Row C,\" he said. \"This once.\"" },
				lose = { health = { -5, -2 }, sanity = -5, log = "\"That's Row C,\" said the Big Brother, and took the Book back. You were disciplined for misreading. The man got Row B anyway." },
			},
			{
				label = "Ask the man why he did it",
				result = { mind = 2, sanity = -1, log = "He said his little brother was hungry. The Big Brother said the Middle understands family better than anyone, and that this was exactly why the Book exists." },
			},
		},
	},
	{
		id = "fn_middle_collect",
		title = "Collecting a Grudge",
		text = "The family collects a grudge tonight: an Office that cheated a Sibling and then laughed about it. Twenty Siblings, one street, one Office door. Your Big Sister puts you in the second row. \"The first row is for the ones who've done this before,\" she says. \"You watch, and you remember.\"",
		weight = 22,
		cooldown = 4,
		tags = { "fingers" },
		when = { career = "middle" },
		choices = {
			{
				label = "Push into the front row",
				clash = { stat = "strength", foe = "An Office of cornered Fixers", coins = 2, base = 5, coinPower = 3, fight = true, status = "rupture" },
				win = { strength = 2, paycheck = 0.3, log = "You went through the door second and came out first. Your Big Sister didn't say anything. She bought you noodles, which said everything." },
				lose = { health = { -10, -4 }, log = "The Fixers had been expecting the Middle for a week. You found out how well they'd prepared.", cause = "Collecting a grudge for the Middle" },
			},
			{
				label = "Hold the second row",
				result = { sanity = -3, mind = 1, log = "You held the street while the front row went in. It was over quickly. In the morning a Big Brother drew a neat line through one entry in his Book." },
			},
			{
				label = "Slip the Office a warning",
				hint = "Nobody leaves family. Nobody betrays it, either.",
				result = inBook("You slipped the Office a note and they fled before the family arrived. Someone saw you. Your name went into the Book that night, in your own Big Sister's handwriting.", { quitCareer = true }),
			},
		},
	},
	{
		id = "fn_middle_big",
		title = "Big Sibling",
		text = "You're a Big Sibling now, with a Book of your own chained at your waist and six Little Siblings who call you Big Sis or Big Bro without a trace of irony. The youngest, Tomasz, comes to you at midnight. He wants to leave the family and open a bakery, and he knows exactly what that means.",
		weight = 22,
		once = true,
		tags = { "fingers" },
		when = { career = "middle", flags = { "fn_middle_big" }, notFlags = { "fn_middle_great" } },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Help him leave, and write nothing",
				result = { sanity = 4, setFlags = { "fn_middle_let_go" }, log = "You walked him to the edge of the District yourself and told the family he'd been sent east. Your Book has one empty page you look at sometimes." },
			},
			{
				label = "Tell him family is forever",
				clash = { stat = "mind", foe = "A frightened Little Brother", coins = 2, base = 4, coinPower = 3 },
				win = { paycheck = 0.3, sanity = 1, log = "He stayed. He's your best Little Brother now, and he bakes bread for the whole family on Sundays." },
				lose = { sanity = -3, log = "He ran that night anyway. Somebody else wrote his name in their Book. It wasn't you, and that didn't help." },
			},
			{
				label = "Ask the Great Sister",
				result = { sanity = -2, mind = 2, log = "The Great Sister listened, then asked why you thought a Big Sibling needed to ask. You never forgot the question." },
			},
		},
	},
	{
		id = "fn_middle_pilgrimage",
		title = "The Pilgrimage of Loyalty",
		text = "No Big Sibling becomes a Great Sibling without a Pilgrimage of Loyalty: a long road through the Middle's branches across the City, paying respects to the senior Brothers and Sisters of every region and carrying their judgments home. It takes a year. Some come back changed. Some don't come back.",
		weight = 18,
		once = true,
		tags = { "fingers" },
		when = { career = "middle", flags = { "fn_middle_big" }, notFlags = { "fn_middle_great" }, minAge = 28 },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Set out",
				clash = { stat = "health", foe = "The road east and back", coins = 3, base = 5, coinPower = 3 },
				win = { promote = true, sanity = 4, log = "You came home a year later with dust on your boots and a blessing in your Book from every branch. They call you Great Sibling now." },
				lose = { health = { -11, -5 }, sanity = -4, log = "The road was longer than the year. You came home thinner, without the title, with a Book full of names who will remember you.", cause = "Lost on the Pilgrimage of Loyalty" },
			},
			{
				label = "Not yet",
				result = { sanity = 1, mind = 1, log = "You told the Great Sister you weren't ready. She said readiness is a kind of loyalty too, and gave you another year." },
			},
		},
	},
	{
		id = "fn_middle_great",
		title = "Great Sibling",
		text = "As a Great Sibling of the Middle you settle the grudges Big Siblings can't. Two Big Brothers have written the same man in their Books, for different reasons, and are glaring at each other across your table. The family is waiting to see whose grudge comes first.",
		weight = 200,
		once = true,
		tags = { "fingers" },
		when = { career = "middle", minRank = 3 },
		codex = "fn_lore_book",
		choices = {
			{
				label = "The older grudge comes first",
				result = { paycheck = 0.5, sanity = 2, log = "You ruled for the older grudge, by the Book. Both Brothers bowed. The younger one bowed slightly less." },
			},
			{
				label = "He pays both, in Ahn",
				result = { wage = { 200, 400 }, log = "You ruled that the man would pay both grudges in Ahn, with interest. He paid. Everyone pretended this was a very old tradition." },
			},
			{
				label = "Strike him from one Book",
				result = { sanity = 3, mind = 2, log = "You crossed him out of the younger Brother's Book with your own pen. Nobody had seen a Great Sibling cross something out before. Nobody argued." },
			},
		},
	},

	-- ── everyone else ──
	{
		id = "fn_neighbor_book",
		title = "A Name in the Book",
		text = "Your neighbor, Mrs. Halim, refused to sell a Little Sister of the Middle the last melon on her stall, because a regular had reserved it. This morning the Little Sister came back with a Big Brother, and a heavy book was opened on the melon table. Now Mrs. Halim's name is in the Book of Vengeance, and she is sitting on your stairs, shaking.",
		weight = 12,
		cooldown = 8,
		tags = { "fingers", "backstreets" },
		when = { minAge = 14, side = "backstreets", notFlags = { "fn_middle_member" } },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Hide her until it blows over",
				clash = { stat = "mind", foe = "Siblings searching door to door", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 3, setFlags = { "fn_hid_neighbor" }, log = "You hid her in your cupboard while two Siblings searched the building. They looked everywhere except the place she was. For now." },
				lose = inBook("They found her in your cupboard. They also found you. Two names went into the Book that day."),
			},
			{
				label = "Help her get the name struck out",
				result = { quest = "fn_q_strike_the_name", sanity = 2, log = "You told her names come out of the Book sometimes, if you do it right. You weren't sure that was true. You set out to find out." },
			},
			{
				label = "Stay out of it",
				result = { sanity = -4, log = "You closed your door. In the morning her stall was gone, and the street pretended it had never been there." },
			},
		},
	},
	{
		id = "fn_middle_little_brother",
		title = "Family of the Family",
		text = "{child}, whom you raised, comes home with a new tattoo climbing out of their collar: the Middle's mark. \"They're family,\" {child} says, \"and you're my family, so now you're family of the family.\" By evening every Sibling on the street greets you by name. Some of them have brought soup.",
		weight = 8,
		once = true,
		tags = { "fingers" },
		when = { minAge = 32, hasRelation = "child", side = "backstreets", notFlags = { "fn_middle_member" } },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Welcome the new family",
				result = { sanity = 3, addTrait = "middle_family", setFlags = { "fn_middle_favor" }, log = "Siblings fixed your door, carried your groceries, and stood outside your building during the Night. They also expected you at every family dinner, forever." },
			},
			{
				label = "Beg {child} to leave the Middle",
				clash = { stat = "charisma", foe = "Loyalty", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = -1, relationBond = { kind = "child", amount = 8 }, log = "{child} cried and stayed in the Middle, but promised never to bring the Book home. They kept that promise." },
				lose = { sanity = -4, relationBond = { kind = "child", amount = -15 }, log = "{child} said nobody leaves family, and that you of all people should understand that. They didn't visit for a year." },
			},
			{
				label = "Ask what it cost",
				result = { mind = 1, sanity = -1, log = "\"Nothing,\" {child} said. \"The Middle always pays its debts.\" You noticed they didn't say who pays them." },
			},
		},
	},
	{
		id = "fn_middle_spilled_tea",
		title = "Spilled Tea",
		text = "In a crowded teahouse you bump an elbow, and a Big Sister of the Middle ends up wearing her tea. The teahouse goes silent. She looks at the stain, then at you, then very slowly unhooks the chained book at her waist and begins turning pages, wetting a finger each time.",
		weight = 9,
		cooldown = 10,
		tags = { "fingers" },
		when = { minAge = 14, notFlags = { "fn_middle_member", "fn_middle_grudge" } },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Apologize and pay for the dress",
				hint = "80 Ahn",
				requires = { min = { money = 80 } },
				result = { money = -80, sanity = -1, log = "You apologized like it was a funeral and paid for the dress twice over. She stopped turning pages. \"Courtesy,\" she said, \"is also something the Middle remembers.\"" },
			},
			{
				label = "Apologize, very properly",
				clash = { stat = "charisma", foe = "A Big Sister with a Book", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 2, log = "Halfway through Title 14 she closed the Book. \"Accidents are Row Z,\" she said. \"Row Z is a warning.\" You have never been so glad to be in Row Z." },
				lose = inBook("She found the right page and wrote your name slowly, so you could watch every letter."),
			},
			{
				label = "Laugh it off",
				result = inBook("You laughed. She wrote your name in the Book before you'd finished. The whole teahouse heard the pen.", { sanity = -6 }),
			},
		},
	},
	{
		id = "fn_middle_hunt",
		title = "The Middle Remembers",
		text = "Three Siblings of the Middle wait at the end of your street, tattoos showing, one of them holding a photograph of you. Your name is in the Book, and the Book does not forget. They start walking toward you, unhurried, the way people walk when they know you have nowhere to go.",
		weight = 20,
		cooldown = 3,
		tags = { "fingers", "danger" },
		when = { flags = { "fn_middle_grudge" }, minAge = 12 },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Fight them in the street",
				clash = { stat = "strength", foe = "Three Siblings of the Middle", coins = 3, base = 5, coinPower = 3, fight = true, status = "tremor" },
				win = { strength = 2, sanity = -3, log = "You put all three on the pavement and ran. The Middle will send six next time. The Middle always sends more next time." },
				lose = { health = { -11, -5 }, sanity = -5, log = "The family collected. You woke in a clinic with the bill already paid and a note on the pillow: Title 4, Section 2, partly settled.", cause = "Collected by the Middle" },
			},
			{
				label = "Run, and keep running",
				result = { health = -2, sanity = -4, log = "You ran through the laundries and over the rooftops until they lost you. They didn't stop looking. They never stop looking." },
			},
			{
				label = "Ask for a mediator",
				result = { quest = "fn_q_strike_the_name", sanity = -2, log = "You asked for a mediator, the one word the Middle respects. They stopped. \"Find one,\" said the eldest. \"Quickly.\"" },
			},
			{
				label = "Pay what the family asks",
				hint = "250 Ahn",
				requires = { min = { money = 250 } },
				result = { money = -250, clearFlags = { "fn_middle_grudge" }, cure = "in_the_book", sanity = 3, log = "You paid. The eldest drew a line through your name in front of you. \"The Middle always pays its debts,\" she said. \"So should everyone.\"" },
			},
		},
	},

	{
		id = "fn_middle_elder",
		title = "The Family Keeps Its Own",
		text = "The Middle doesn't let its elders walk the streets on bad knees. Your Big Sister, who was a Little Sister when you met her, sits you down with soup. \"Let the young ones carry the Book,\" she says. \"You've carried it long enough. The family will carry you now.\"",
		weight = 25,
		cooldown = 4,
		tags = { "fingers" },
		when = { career = "middle", minAge = 58 },
		choices = {
			{
				label = "Let the family carry you",
				result = { quitCareer = true, sanity = 6, wage = { 150, 300 }, setFlags = { "fn_middle_elder", "fn_middle_favor" }, log = "You hung up your Book on a nail by the door. Little Siblings you'd never met brought groceries every week and called you Grandsibling." },
			},
			{
				label = "Teach the Little Siblings the Book",
				result = { paycheck = 0.3, sanity = 3, mind = 1, log = "You spent your days reading the Book aloud to Little Siblings, Title by Title, explaining which Rows matter. They listened like it was scripture." },
			},
			{
				label = "One more grudge first",
				result = { paycheck = 0.5, health = -3, sanity = -1, log = "There was one more name in your Book that you wanted to settle yourself. The family let you. It took longer than it used to." },
			},
		},
	},
	-- the Book quest's last step (Quests/Fixers.luau)
	{
		id = "fn_q_book_price",
		title = "In Whichever Form",
		text = "A Little Sister walks you to a noodle shop where a Big Sister of the Middle waits with the Book open. Your mediator sits beside her, nervous. \"The family will accept payment,\" the Big Sister says, \"in whichever form. Ahn. Service. Or a favor we collect later, at a time of our choosing.\"",
		weight = 0,
		when = { flags = { "fn_q_book_mediator" } },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Pay in Ahn",
				hint = "200 Ahn",
				requires = { min = { money = 200 } },
				result = { money = -200, setFlags = { "fn_q_book_paid" }, log = "You counted the Ahn out on the noodle table. She counted it again, twice, and closed the Book." },
			},
			{
				label = "Pay in service",
				clash = { stat = "strength", foe = "A family errand that goes wrong", coins = 2, base = 5, coinPower = 3, fight = true, status = "tremor" },
				win = { setFlags = { "fn_q_book_paid" }, strength = 1, log = "You spent a season running errands for the family, including one you will never describe. The Big Sister called the service satisfactory." },
				lose = { health = { -8, -3 }, setFlags = { "fn_q_book_paid" }, log = "The errand went badly, but you finished it. The family counted the bruises as part of the payment.", cause = "Paying a debt to the Middle" },
			},
			{
				label = "Owe them a favor",
				result = { setFlags = { "fn_q_book_paid", "fn_middle_favor_owed" }, sanity = -3, log = "\"A favor,\" she said, and wrote a new line in a different section of the Book. \"We'll be in touch.\" You know they will." },
			},
		},
	},

	-- world event opener (WorldEvents/Fixers.luau: fn_we_vengeance)
	{
		id = "fn_world_vengeance",
		title = "Shutters Down",
		text = "Siblings of the Middle are going street by street with a heavy book, reading names aloud. Shutters slam all down the block. A Little Brother knocks on your door to ask, very politely, whether anyone named in the Book is staying here. Behind you, your neighbor's cousin has gone very quiet.",
		weight = 0,
		codex = "fn_lore_book",
		choices = {
			{
				label = "Say nobody's here",
				clash = { stat = "mind", foe = "A polite Little Brother", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, log = "He looked past you for a long moment, then thanked you and moved on to the next door." },
				lose = inBook("He saw the cousin's shoes by your door. Now there are two names on that page."),
			},
			{
				label = "Hand the cousin over",
				result = { sanity = -6, log = "You stepped aside. The Little Brother thanked you warmly, like family. You couldn't look at your neighbor for a year." },
			},
			{
				label = "Invite the Little Brother in for tea",
				result = { sanity = 1, setFlags = { "fn_middle_favor" }, log = "He accepted, which surprised you both. He talked about his grandmother for an hour and forgot to search the flat." },
			},
		},
	},
}
