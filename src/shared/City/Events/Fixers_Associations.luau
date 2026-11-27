--[[
	Association careers, rank by rank. Every Association has an early-Section event (Sections 6-4,
	notFlags fx_section_three) and a senior one (Section 3 and up, or a Director's). Canon:
	docs/CANON.md 4.2 and 8.5; Öufi as contract enforcers and "transfers between regions can
	be promotions" follow Limbus game text. Foe statuses follow the factions' Limbus kits:
	Zwei tremor, Liu burn, Seven rupture, Shi poise, Cinq poise, Kurokumo bleed.
]]

return {
	-- ── Zwei ──
	{
		id = "fx_zwei_street",
		title = "A Street to Hold",
		text = "Zwei has taken a shield contract for a whole street for a year, and your Section 6 squad is the shield. You stand at the north end in your heavy coat while shops open behind you. On the third night, a Kurokumo crew in wave-patterned coats walks up to see how thick the shield is.",
		weight = 24,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = "zwei", notFlags = { "fx_section_three" } },
		codex = "fx_lore_zwei",
		choices = {
			{
				label = "Hold the line",
				clash = { stat = "health", foe = "A Kurokumo crew testing the line", coins = 2, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { health = 2, paycheck = 0.3, log = "You didn't move. They hit you, and you didn't move. At dawn the crew left, and the street's shopkeepers brought your squad breakfast for a week." },
				lose = { health = { -9, -3 }, log = "The line bent. It didn't break. Your Section Director called it acceptable, which in Zwei is a medal.", cause = "Fell holding the line" },
			},
			{
				label = "Talk them down",
				clash = { stat = "charisma", foe = "A Kurokumo Captain's pride", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, log = "You explained, politely, what a Zwei contract costs to break. The Captain did the sums and bowed out." },
				lose = { sanity = -3, log = "Talking wasn't what they'd come for. Your squad held anyway, without you at the front." },
			},
			{
				label = "Signal the Section for backup",
				result = { sanity = 1, paycheck = 0.1, log = "Section 5 arrived in four minutes. The Kurokumo left in two. Your report said \"de-escalated,\" and your Director let it." },
			},
		},
	},
	{
		id = "fx_zwei_border",
		title = "The Border Post",
		text = "Section 3 takes the hard postings, and yours is a border post at the very edge of the District, where the streetlights stop and the Outskirts begin. Things that are not Abnormalities, and that nobody made, come out of the dark there, and they hate people. Zwei's contract says nothing gets past the post.",
		weight = 20,
		once = true,
		tags = { "fixers", "danger" },
		when = { career = "zwei", flags = { "fx_section_three" } },
		codex = "fx_lore_zwei",
		choices = {
			{
				label = "Hold the post",
				clash = { stat = "health", foe = "Something from the Outskirts", coins = 3, base = 6, coinPower = 3, fight = true, status = "rupture" },
				win = { health = 2, paycheck = 0.5, log = "It came three times in one night. It didn't get past. In the morning you found claw marks on your coat and none on the street." },
				lose = { health = { -11, -4 }, sanity = -4, log = "It got past you once, and the Section caught it. The scar runs from your collar to your sleeve.", cause = "Fell at a Zwei border post" },
			},
			{
				label = "Light every lamp you have",
				clash = { stat = "intelligence", foe = "A long night with too few lamps", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.3, log = "You rigged every lamp at the post into a wall of light. The things in the dark circled until dawn and went home hungry." },
				lose = { sanity = -5, log = "The lamps went out one by one. You stood in the dark until morning, listening." },
			},
		},
	},
	{
		id = "fx_zwei_director",
		title = "Whose Shield",
		text = "As a Section Director of Zwei you decide where the shields stand. A rich client wants your whole Section guarding his warehouses this month. The street next to them, all families and noodle stalls, has no contract at all, and a Syndicate war is coming down it. Zwei is the client's shield. Only the client's.",
		weight = 18,
		once = true,
		tags = { "fixers" },
		when = { career = "zwei", flags = { "fx_section_director" } },
		codex = "fx_lore_zwei",
		choices = {
			{
				label = "Guard the warehouses, as contracted",
				result = { paycheck = 0.6, sanity = -5, log = "Your Section guarded the warehouses perfectly. You watched the next street through the warehouse windows all week, and didn't sleep." },
			},
			{
				label = "Stretch the line to cover both",
				clash = { stat = "health", foe = "Half a Section, two streets", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = 4, health = 1, log = "You thinned the line until it covered the families too, and somehow it held. The client never noticed. The street did." },
				lose = { sanity = -3, paycheck = -0.2, log = "The thin line held the families' street and lost a warehouse. The client sued Zwei. Zwei docked you." },
			},
		},
	},

	-- ── Liu ──
	{
		id = "fx_liu_five",
		title = "Five at Once",
		text = "Anyone can fight one person. The Liu Association trains its Fixers to fight several, and today's contract is a dock brawl where a client's porters are outnumbered by hired thugs. Your Section 6 squad strolls in eating buns. Five of the thugs pick you, specifically, and your weapon's fuel line hisses.",
		weight = 24,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = "liu", notFlags = { "fx_section_three" } },
		codex = "fx_lore_liu",
		choices = {
			{
				label = "Take all five",
				clash = { stat = "strength", foe = "Five hired thugs", coins = 3, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = 2, paycheck = 0.3, log = "Five came at you; five went into the harbor, slightly on fire. Your squad finished their buns and applauded." },
				lose = { health = { -9, -3 }, condition = "burns", log = "Two of the five, you handled. The other three, and your own incendiary, handled you.", cause = "Killed in an Association brawl" },
			},
			{
				label = "Fight back to back with the squad",
				clash = { stat = "mind", foe = "A brawl with no shape", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "The Liu fight like a family dinner: loud, crowded, everyone covering everyone. You came out of it laughing." },
				lose = { sanity = -2, health = -3, log = "You lost the squad in the smoke and fought half the brawl alone. Afterward they bought you dinner to apologize." },
			},
			{
				label = "Offer the thugs a bun",
				result = { sanity = 3, intelligence = 1, log = "You offered the nearest thug a bun. He was so confused that the brawl stopped. Your Section Director called it very Liu of you." },
			},
		},
	},
	{
		id = "fx_liu_section_four",
		title = "Stuck in Section 4",
		text = "You've been in Liu's Section 4 for years. Good fights, good squad, and no promotion, while younger Fixers pass you on the way to Section 3. The other day you noticed something about how the Section moves in a crowd fight, a better way to rotate who takes the front. It might be nothing. It might be your way up.",
		weight = 20,
		once = true,
		tags = { "fixers" },
		when = { career = "liu", minRank = 3, notFlags = { "fx_section_three" } },
		codex = "fx_lore_associations",
		choices = {
			{
				label = "Pitch the idea to your Director",
				clash = { stat = "charisma", foe = "A Director who has heard every idea", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, sanity = 4, log = "Your Director tried the rotation in the next brawl. It worked. A month later you were in Section 3, and the rotation had your name on it." },
				lose = { sanity = -3, log = "Your Director said it was a good idea that Section 2 had tried years ago. You went back to Section 4 and kept noticing things." },
			},
			{
				label = "Keep your head down and fight",
				result = { strength = 2, paycheck = 0.2, log = "You kept fighting and said nothing. It's not a bad life in Section 4. It's just a long one." },
			},
		},
	},
	{
		id = "fx_liu_director",
		title = "The Liu Way",
		text = "As a Liu Section Director, your Section is known for two things: winning crowd fights and taking long tea breaks in the middle of them. A Director from another Association's Section, sharing your contract, says that is unprofessional and wants your Section under his command for the rest of the job.",
		weight = 18,
		once = true,
		tags = { "fixers" },
		when = { career = "liu", flags = { "fx_section_director" } },
		codex = "fx_lore_liu",
		choices = {
			{
				label = "Pour him a cup of tea",
				clash = { stat = "mind", foe = "A very serious Director", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = 4, paycheck = 0.3, log = "He drank the tea, then a second cup. By the third he was laughing at a story about a burning boat. The contract went beautifully." },
				lose = { sanity = -2, log = "He poured the tea on the ground. Your Section finished the job anyway, cheerfully, and filed a very polite complaint." },
			},
			{
				label = "Win the fight first, argue later",
				clash = { stat = "strength", foe = "The rest of the job", coins = 3, base = 6, coinPower = 3, fight = true, status = "tremor" },
				win = { strength = 2, paycheck = 0.5, log = "Your Section won the fight before he finished giving orders. He never mentioned tea breaks again." },
				lose = { health = { -9, -3 }, log = "The job went badly for everyone. In the report, both Directors blamed the weather.", cause = "Killed in an Association brawl" },
			},
		},
	},

	-- ── Seven ──
	{
		id = "fx_seven_case",
		title = "A Case in Three Districts",
		text = "Your Section 6 case file: a ledger clerk who walked out of his office in one District, bought a WARP ticket in another, and was last seen in a third. His employer wants to know where he is, why he left, and what he took, by whatever means the contract allows. The file is thin. Seven doesn't do thin files.",
		weight = 24,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = "seven", notFlags = { "fx_section_three" } },
		codex = "fx_lore_seven",
		choices = {
			{
				label = "Follow the paper trail",
				clash = { stat = "intelligence", foe = "Three Districts of paperwork", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.3, log = "Ticket stubs, a pawn receipt, a rented room. You found him in a week, alive and frightened, with a ledger that proved his employer was a thief." },
				lose = { sanity = -2, log = "The trail went cold at a WARP station. You wrote a very thorough report about a very cold trail." },
			},
			{
				label = "Tail his only friend",
				clash = { stat = "strength", foe = "A friend who knows he's followed", coins = 2, base = 4, coinPower = 3 },
				win = { strength = 2, paycheck = 0.3, log = "The friend led you straight to him without ever looking back. You felt bad about that for exactly one report." },
				lose = { health = { -5, -2 }, sanity = -1, log = "The friend noticed you on the second day and introduced you to a very hard wall." },
			},
			{
				label = "Buy the answer from an informant",
				hint = "60 Ahn",
				requires = { min = { money = 60 } },
				result = { money = -60, paycheck = 0.3, mind = 1, log = "An informant sold you the address for sixty Ahn and a promise that you'd never met. Seven reimbursed you. Eventually." },
			},
		},
	},
	{
		id = "fx_seven_secret",
		title = "What the Client Wanted",
		text = "The case was routine until it wasn't. The missing shipment your client wanted traced was moving through a Wing's back door, under a label that doesn't exist, toward a Nest that officially has no such warehouse. You have the proof in your coat. Seven finds things out; it doesn't promise you'll be glad it did.",
		weight = 18,
		once = true,
		tags = { "fixers" },
		when = { career = "seven", flags = { "fx_section_three" } },
		codex = "fx_lore_seven",
		choices = {
			{
				label = "Report everything to the client",
				result = { paycheck = 0.6, sanity = -3, setFlags = { "fx_seven_knows" }, log = "You reported everything. The client paid triple and asked you to forget it. You've never been able to." },
			},
			{
				label = "Bury the part about the Wing",
				result = { sanity = 2, mind = 2, log = "You reported the shipment and left out the Wing. Your Section Director read the report, looked at you, and approved it without a word." },
			},
			{
				label = "Sell a copy on the side",
				clash = { stat = "mind", foe = "A Wing that notices things", coins = 3, base = 6, coinPower = 3 },
				win = { wage = { 300, 500 }, sanity = -3, log = "A buyer in another District paid a fortune for the copy. You still check your door twice before the Night." },
				lose = { health = { -10, -4 }, sanity = -6, condition = "night_terrors", log = "The buyer was the Wing. They took the copy, and something else you can't name, and let you go.", cause = "Knew too much" },
			},
		},
	},

	-- ── Devyat' ──
	{
		id = "fx_devyat_deadline",
		title = "The Deadline",
		text = "The package is due across the District in forty minutes, and Poludnitsa, the quiet helper program in your Courier Trunk, has started counting down in your ear. A rival courier outfit has blocked the bridge, and the long way passes a street the locals say has been wrong for years. Devyat' is never late.",
		weight = 24,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = "devyat", notFlags = { "fx_section_three" } },
		codex = "fx_lore_devyat",
		choices = {
			{
				label = "Go straight through the blockade",
				clash = { stat = "strength", foe = "A rival courier crew", coins = 2, base = 5, coinPower = 3, fight = true, status = "charge" },
				win = { strength = 2, paycheck = 0.3, log = "You went through them like they were a puddle. Delivered with ninety seconds to spare. Poludnitsa said nothing, which is how it says well done." },
				lose = { health = { -8, -3 }, paycheck = 0.1, log = "You got through, eventually, and delivered with four seconds to spare. You don't remember the last street.", cause = "Lost racing a Devyat' deadline" },
			},
			{
				label = "Take the wrong street",
				clash = { stat = "mind", foe = "A street that isn't where it was", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.3, log = "You kept your eyes on the Trunk's compass and nowhere else. The street tried to turn you around. It failed. Delivered early." },
				lose = { sanity = -5, log = "The street turned you around three times. You delivered on time, somehow, and threw up behind the client's building." },
			},
			{
				label = "Let Poludnitsa push you",
				result = { health = -4, paycheck = 0.4, log = "You gave the helper program full control of your pace. Your legs moved faster than they should be able to. Delivered early. Your legs still haven't forgiven you." },
			},
		},
	},
	{
		id = "fx_devyat_trunk",
		title = "What Goes in the Trunk",
		text = "A well-dressed client wants a delivery to another District, urgently, discreetly, and in your Courier Trunk, which is bigger inside than out. The delivery is his nephew, who is in trouble with the wrong people. The rules Hana and Devyat' wrote after a story nobody repeats are clear: no people in dimensional containers. Ever.",
		weight = 18,
		once = true,
		tags = { "fixers" },
		when = { career = "devyat", flags = { "fx_section_three" } },
		codex = "fx_lore_devyat",
		choices = {
			{
				label = "Refuse, and explain why",
				result = { mind = 2, sanity = 1, log = "You told him the story nobody repeats. He went pale, thanked you, and bought the nephew a WARP ticket instead." },
			},
			{
				label = "Escort the nephew on foot instead",
				clash = { stat = "health", foe = "Three Districts with the wrong people behind you", coins = 3, base = 5, coinPower = 3 },
				win = { paycheck = 0.5, sanity = 3, log = "You walked him across three Districts with the wrong people a street behind. He arrived alive, and on time. Devyat' is never late." },
				lose = { health = { -9, -3 }, sanity = -2, log = "The wrong people caught up in the second District. The nephew got away. You got a clinic bed.", cause = "Lost racing a Devyat' deadline" },
			},
			{
				label = "Report the client to Hana",
				result = { paycheck = 0.2, sanity = -2, log = "You reported him. Hana fined him heavily. The nephew's name turned up in a different District's news a month later. You don't know what it meant." },
			},
		},
	},

	-- ── Shi ──
	{
		id = "fx_shi_contract",
		title = "A Quiet Contract",
		text = "Shi's Section 6 hands you a contract card with one name on it: an enforcer who has been breaking shopkeepers' hands across three streets for a Syndicate that pays him well. Association Fixers don't choose their jobs. The contract says neutralize the threat, quietly, tonight, and leave no question about who wanted it done.",
		weight = 22,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = "shi", notFlags = { "fx_section_three" } },
		codex = "fx_lore_shi",
		choices = {
			{
				label = "Carry it out, done once",
				clash = { stat = "strength", foe = "A Syndicate enforcer and his guards", coins = 3, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = 2, paycheck = 0.4, sanity = -2, log = "It was over before his guards understood it had begun. The shopkeepers on three streets opened late the next morning, and didn't know why they felt lighter." },
				lose = { health = { -10, -4 }, sanity = -3, log = "His guards were better than the file said. You got out. The contract went to someone in Section 5.", cause = "Lost on a Shi contract" },
			},
			{
				label = "Find a way without a fight",
				clash = { stat = "mind", foe = "A Shi Director's patience", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.2, log = "You arranged for his own Syndicate to find his private ledger. He left the District that night. Your Director called it inelegant, and accepted it." },
				lose = { sanity = -4, paycheck = -0.1, log = "Your Director said Shi takes the job it is paid for, not a cleverer one. You were docked and sent back out." },
			},
		},
	},
	{
		id = "fx_shi_name",
		title = "The Name on the Card",
		text = "Section 3 contracts come in sealed envelopes. Tonight's has a name you know: a Fixer you trained beside years ago, who has made very powerful enemies. Shi doesn't take questions about its clients. It doesn't take refusals either. Your old friend is eating noodles three streets away, with their back to the door.",
		weight = 18,
		once = true,
		tags = { "fixers" },
		when = { career = "shi", flags = { "fx_section_three" } },
		codex = "fx_lore_shi",
		choices = {
			{
				label = "Do the job",
				clash = { stat = "strength", foe = "A Fixer who taught you half of what you know", coins = 3, base = 6, coinPower = 3, fight = true, status = "poise" },
				win = { paycheck = 0.6, sanity = -10, log = "It was done right, and done once. You didn't eat noodles for a year." },
				lose = { health = { -11, -4 }, sanity = -6, log = "They saw you coming, because they taught you how you'd come. They let you walk away. You've wondered why ever since.", cause = "Lost on a Shi contract" },
			},
			{
				label = "Warn them and take the penalty",
				result = { sanity = 2, paycheck = -0.5, setFlags = { "fx_shi_disgrace" }, log = "You sat down across the table and said one word. They left through the kitchen. Shi docked you a year's pay and never gave you a sealed envelope again." },
			},
			{
				label = "Ask your Director to reassign it",
				clash = { stat = "mind", foe = "Shi's rules", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = -2, log = "Your Director reassigned it without a word. You never learned what happened. You decided that was a kindness." },
				lose = { sanity = -6, quitCareer = true, log = "Your Director said a Fixer who can't take a contract is not a Fixer of Shi. You handed in your card that night." },
			},
		},
	},

	-- ── Cinq ──
	{
		id = "fx_cinq_glove",
		title = "The Thrown Glove",
		text = "A merchant's honor has been insulted at a dinner party, and the merchant would rather not risk his own neck. Your client's rival has hired a duelist of his own. The rival's proxy throws a white glove at your feet in the square, the Western way. A small crowd gathers to watch two Cinq Fixers in big hats bow to each other.",
		weight = 24,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = "cinq", notFlags = { "fx_section_three" } },
		codex = "fx_lore_cinq",
		choices = {
			{
				label = "Pick up the glove",
				clash = { stat = "strength", foe = "A rival house's duelist", coins = 3, base = 5, coinPower = 3, fight = true, status = "poise" },
				win = { strength = 2, paycheck = 0.4, log = "First touch to you, and the second. The rival's proxy bowed, the crowd applauded, and your client's honor was restored at a reasonable hourly rate." },
				lose = { health = { -8, -3 }, sanity = -2, log = "You lost on the third touch. Your client's honor took a blow. So did you, several.", cause = "Fell in a contract duel" },
			},
			{
				label = "Negotiate a draw",
				clash = { stat = "charisma", foe = "Two clients' egos", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 2, paycheck = 0.3, log = "You and the other proxy agreed on a draw at first touch, staged beautifully. Both clients went home certain they'd won." },
				lose = { sanity = -3, log = "Your client refused a draw. The duel happened anyway, at midnight, worse tempered." },
			},
		},
	},
	{
		id = "fx_cinq_east",
		title = "East or West",
		text = "Cinq's Eastern branch has asked for you. The Western Fixers throw gloves and wear capes and big hats; the Eastern ones announce their name and affiliation before a duel, fight hand to hand, and wear Virescent Pyrojade bangles whose green flame burns only what the wearer chooses. A transfer between regions can be a promotion.",
		weight = 18,
		once = true,
		tags = { "fixers" },
		when = { career = "cinq", flags = { "fx_section_three" } },
		codex = "fx_lore_cinq",
		choices = {
			{
				label = "Transfer East",
				result = { promote = true, gear = "fx_pyrojade_bangle", sanity = 3, log = "You learned to say your name and affiliation like a vow. The Eastern branch fitted you with a Pyrojade bangle and a promotion, in that order." },
			},
			{
				label = "Stay West, cape and all",
				result = { paycheck = 0.4, strength = 1, log = "You kept your cape and your glove. The Western branch took it as loyalty, and paid you like it." },
			},
		},
	},

	-- ── Dieci ──
	{
		id = "fx_dieci_trade",
		title = "Knowledge into Strength",
		text = "A Dieci contract has gone bad: you're cornered in a stairwell by three hired fighters, and your keys are the only weapon you have. Dieci gear can turn something you know into strength, and what you spend is gone for good. You can feel your mind offering things up: your grandmother's recipe, the streets of your childhood, a language.",
		weight = 22,
		cooldown = 5,
		tags = { "fixers" },
		when = { career = "dieci", notFlags = { "fx_section_three" } },
		codex = "fx_lore_dieci",
		choices = {
			{
				label = "Spend a memory",
				result = { strength = 3, intelligence = -3, condition = "fx_knowledge_spent", paycheck = 0.3, log = "You gave up the recipe. The keys in your fist hit like a falling sign, and the stairwell was clear. You'll never taste that soup again, and you can't remember why that hurts." },
			},
			{
				label = "Fight with what you have",
				clash = { stat = "strength", foe = "Three hired fighters in a stairwell", coins = 3, base = 5, coinPower = 3, fight = true, status = "tremor" },
				win = { strength = 2, paycheck = 0.3, log = "You won with your fists and your keys and nothing else. You kept every memory you came in with." },
				lose = { health = { -9, -3 }, log = "You held on to your memories and lost the fight. You remember it all, in detail.", cause = "Fell on a Dieci contract" },
			},
			{
				label = "Retreat up the stairs",
				result = { sanity = -2, intelligence = 1, log = "You retreated to the roof and waited them out. The contract failed. You still know everything you knew this morning." },
			},
		},
	},
	{
		id = "fx_dieci_saint",
		title = "Their Own Kind of Saint",
		text = "Dieci's Section 3 keeps an old woman in a quiet room, and the Fixers speak of her as their Saint. She has traded almost everything she ever knew for strength, over a long life, and now she knows very little. She is peaceful. Today she has asked to see you, and you don't know what she still remembers.",
		weight = 16,
		once = true,
		tags = { "fixers" },
		when = { career = "dieci", flags = { "fx_section_three" } },
		codex = "fx_lore_dieci",
		choices = {
			{
				label = "Ask her what she kept",
				result = { mind = 3, sanity = 3, log = "\"Only the important things,\" she said, and held your hand. She couldn't tell you what they were. You understood anyway." },
			},
			{
				label = "Tell her something worth keeping",
				result = { intelligence = 2, sanity = 4, log = "You told her about the best day of your life. She listened like it was the first story ever told. Next week she remembered it, and nothing else." },
			},
		},
	},

	-- ── Öufi ──
	{
		id = "fx_oufi_observe",
		title = "The First and Final Warning",
		text = "You sit between two parties in a cold, silent contract chamber, the Öufi Association's observer, in a gaudy hat with your axe-bladed weapon across your knees. Every word spoken here can be used for or against them. Halfway through, one party slams the table and calls the contract a lie. The other party looks at you.",
		weight = 24,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = "oufi", notFlags = { "fx_section_three" } },
		codex = "fx_lore_oufi",
		choices = {
			{
				label = "Give the first and final warning",
				clash = { stat = "mind", foe = "An angry signatory", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.3, log = "You said it once, in the formal words. He sat down. The contract was signed and notarized, and both parties left alive and bound." },
				lose = { sanity = -4, trigger = "fx_oufi_enforce", log = "He didn't sit down. There is no second warning." },
			},
			{
				label = "Read the disputed clause aloud",
				clash = { stat = "intelligence", foe = "Forty pages of clauses", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.3, log = "You found the clause, read it slowly, and showed him he'd agreed to it in front of a notary. He signed, sulking." },
				lose = { sanity = -2, trigger = "fx_oufi_enforce", log = "You read the wrong clause. He laughed, and reached for the contract to tear it." },
			},
		},
	},
	{
		id = "fx_oufi_enforce",
		title = "Enforcing the Contract",
		text = "A contract notarized by the Öufi Association is carried out, whatever it takes. The angry party has grabbed the contract to tear it, and his two bodyguards are stepping forward from the wall. Your instructions are printed on the back of every Öufi warrant card: breach after the final warning means enforcement.",
		weight = 0,
		when = { career = "oufi" },
		codex = "fx_lore_oufi",
		choices = {
			{
				label = "Enforce it",
				clash = { stat = "strength", foe = "A contract breaker and his bodyguards", coins = 3, base = 5, coinPower = 3, fight = true, status = "tremor" },
				win = { strength = 2, paycheck = 0.3, sanity = -3, log = "The contract was carried out, as notarized. You filled in the enforcement form afterward, in triplicate, and went on to your next appointment." },
				lose = { health = { -9, -3 }, sanity = -2, log = "The bodyguards were very good. The Öufi Section that came to collect you was better. The contract was carried out anyway.", cause = "Enforcing an Öufi contract" },
			},
			{
				label = "Call the Section and hold the door",
				result = { paycheck = 0.1, sanity = -1, log = "You held the door until your Section arrived. Nobody left the chamber unbound. Your Director said a good observer knows when to observe." },
			},
		},
	},
	{
		id = "fx_oufi_will",
		title = "Executor of the Will",
		text = "The Öufi Association is executor of a rich man's will, and you read it aloud in his manor, in front of a family who hated him and each other. The will leaves everything to a name nobody in the room recognizes. A cousin stands up and announces that the will is a forgery, and that nobody is leaving until it's burned.",
		weight = 18,
		once = true,
		tags = { "fixers", "luxury" },
		when = { career = "oufi", flags = { "fx_section_three" } },
		codex = "fx_lore_oufi",
		choices = {
			{
				label = "Finish reading the will",
				clash = { stat = "mind", foe = "A room full of heirs", coins = 3, base = 6, coinPower = 3 },
				win = { mind = 2, paycheck = 0.5, log = "You read the will to its last line while the cousin shouted. Then you gave the final warning. He sat down. The unknown heir got everything." },
				lose = { sanity = -4, health = -3, log = "The reading turned into a brawl among the heirs. Your Section restored order. The will was executed exactly as written, eventually." },
			},
			{
				label = "Find the unknown heir first",
				clash = { stat = "intelligence", foe = "A name in an old ledger", coins = 2, base = 5, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.4, sanity = 2, log = "The heir was the dead man's cook, who'd fed him for forty years. She cried when you told her. The family tried not to." },
				lose = { sanity = -2, log = "You couldn't find the heir. The will waits in Öufi's vault, unexecuted, and Öufi hates nothing more." },
			},
		},
	},

	-- ── Hana ──
	{
		id = "fx_hana_proctor",
		title = "Proctoring the Exam",
		text = "You proctor the licensing exam now, from the front of the old school hall. Two hundred hopefuls, forty questions, one practical bout each. In the third row, five candidates are breathing in the same rhythm, which is how you know a cheating ring is passing answers. In the front row, a kid with mended shoes is about to fail honestly.",
		weight = 24,
		cooldown = 4,
		tags = { "fixers" },
		when = { career = "hana", notFlags = { "fx_section_director" } },
		codex = "fixers_hana",
		choices = {
			{
				label = "Break the cheating ring",
				clash = { stat = "mind", foe = "A practiced cheating ring", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.3, log = "You found the signal: pencil taps on the third beat. Five candidates were banned for life. The hall went very quiet, and very honest." },
				lose = { sanity = -2, log = "You couldn't prove it. Five people who shouldn't be Fixers walked out with Grade 9 licenses. You wrote their numbers down." },
			},
			{
				label = "Ask the kid one more question",
				result = { sanity = 4, log = "You gave the kid a practical question instead of a written one: \"It's 3:05. What do you do?\" They answered perfectly. They passed. You watched them hold the license like it was made of glass." },
			},
			{
				label = "Write an impossible bonus question",
				result = { intelligence = 2, sanity = 1, log = "You asked which Finger's Bow-Bell rings in which month. Nobody knew. The cheating ring's answers were all wrong, and so were they." },
			},
		},
	},
	{
		id = "fx_hana_downgrade",
		title = "A Downgrade",
		text = "Your assessment downgraded an Office from Grade 5 to Grade 6: padded reports, a client who never got her money back. Today its Rep is at the Hana counter with the report in one hand, a weapon on his hip, and two of his Fixers behind him. \"Let's discuss the assessment,\" he says. The clerks have quietly left.",
		weight = 20,
		cooldown = 5,
		tags = { "fixers" },
		when = { career = "hana", minRank = 2 },
		codex = "fx_lore_reports",
		choices = {
			{
				label = "Discuss it, by the rules",
				clash = { stat = "mind", foe = "An angry Rep", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 2, paycheck = 0.3, log = "You walked him through every padded line of his own reports. By the end, he was apologizing. The downgrade stood." },
				lose = { trigger = "fx_hana_counter", sanity = -2, log = "He stopped listening at the second line. His hand went to his hip." },
			},
			{
				label = "Restore the grade, quietly",
				result = { sanity = -5, wage = { 50, 100 }, log = "You restored his grade. He thanked you and left an envelope. You're not sure, now, which of those was worse." },
			},
		},
	},
	{
		id = "fx_hana_counter",
		title = "Across the Hana Counter",
		text = "The Rep draws, and so do his two Fixers, in the middle of the Hana Association's own licensing office. It's a very stupid thing to do. That doesn't make it less dangerous. You are a Hana assessor, and Hana assessors are high-grade Fixers first.",
		weight = 0,
		when = { career = "hana" },
		choices = {
			{
				label = "Remind them what Hana is",
				clash = { stat = "strength", foe = "An Office Rep and two of his Fixers", coins = 3, base = 6, coinPower = 3, fight = true, status = "rupture" },
				win = { strength = 2, paycheck = 0.4, log = "It took nine seconds. The Rep lost his license, his Office, and his grade, in that order. The clerks came back in and applauded." },
				lose = { health = { -10, -4 }, log = "You held them until Hana's Section arrived, which is to say long enough. The Rep will not be a Fixer again.", cause = "Assessed a dangerous Office" },
			},
		},
	},
	{
		id = "fx_hana_color_vote",
		title = "A Color Nomination",
		text = "As a Hana Section Director you sit on the committee that considers Colors, and today a name is on the table: a Grade 1 who single-handedly held a District together through a bad year. Colors are granted maybe once in a generation. The committee is split. Your vote decides it.",
		weight = 18,
		once = true,
		tags = { "fixers" },
		when = { career = "hana", flags = { "fx_section_director" } },
		codex = "fx_lore_colors",
		choices = {
			{
				label = "Vote yes",
				result = { sanity = 4, log = "You voted yes. A week later the whole City knew a new Color. The Fixer sent you nothing, because they never found out, which is how it should be." },
			},
			{
				label = "Vote no",
				result = { mind = 3, sanity = -1, log = "You voted no. A Color is a weight, you told the committee, not a medal, and they weren't ready to carry it. You hope you were right." },
			},
		},
	},
}
