--[[
	Bloodfiends (Limbus Company, Canto VII), as a path a player can choose.

	Canon: Bloodfiends are an old, blood-dependent people organized in Families, each led by an
	Elder (a First Kindred) from a Nest. A Bloodfiend can turn a human into a new Bloodfiend, a
	Kindred, and may make at most two in a lifetime. A Child must never turn against their
	Parent. La Manchaland, an amusement park in District 16 built and staffed by Bloodfiends, put
	its Kindred on Hemobars (an artificial blood substitute); some of them starved on it.

	Ways in: help Livia of the Morvaine Family (an original Family) and she offers the gift
	later; at the edge of death; through La Manchaland's staff (Limbus era); raised by a Family
	(the Bloodline origin), asked once at 18. A human who knows can also knock (Activities).
	Life as Kindred: the Thirst (Sanity drains a little every year; Hemobars refill it), hunters,
	the Family's service and its Taboo, rival Families, two Kindred in a lifetime, outliving
	everyone. Roblox-safe: a Bloodfiend here never feeds on a person. Hemobars, the Family's
	cellar, or going without.
]]

return {
	-- ── ways in ──
	{
		id = "bf_meet_night",
		title = "Red Eyes in the Rain",
		text = "Past midnight, under a broken awning, a woman in a very good coat is backed against the wall by three Rats with pipes. She isn't afraid. Her eyes are red, and she looks embarrassed more than anything, like someone caught without an umbrella.",
		weight = 3,
		once = true,
		when = { minAge = 18, maxAge = 55, form = "human", notFlags = { "bf_knows" } },
		codex = "bf_lore_bloodfiends",
		choices = {
			{
				label = "Step in",
				hint = "A real fight.",
				clash = { stat = "strength", foe = "Three Rats with pipes", coins = 2, base = 4, coinPower = 3, fight = true },
				win = {
					strength = 2,
					sanity = 2,
					setFlags = { "bf_knows" },
					addRelation = { kind = "friend", name = "Livia Morvaine", bond = 45, age = { 30, 36 } },
					schedule = { event = "bf_gift_offer", inYears = 2 },
					log = "The Rats ran. The woman straightened her coat. \"How gallant. Livia, of the Morvaine Family.\" She pressed a card into your hand. It was warm, and it smelled faintly of cherries and iron.",
				},
				lose = { health = { -10, -5 }, setFlags = { "bf_knows" }, log = "You went down under the pipes. When you looked up, the Rats were gone and the woman was shaking the rain off her shoes. \"That was kind,\" she said. \"Stupid. But kind.\"", cause = "Beaten in an alley" },
			},
			{
				label = "Shout that the Night is close",
				hint = "Mental Strength check. Rats fear the Sweepers more than anything.",
				clash = { stat = "mind", foe = "Rats", coins = 1, base = 4, coinPower = 3 },
				win = { sanity = 2, setFlags = { "bf_knows" }, log = "\"It's ten to three!\" you shouted. It wasn't. The Rats scattered anyway. The woman with red eyes nodded at you, once, and was gone." },
				lose = { sanity = -2, log = "They didn't believe you. When you looked back, the alley was empty, and none of those Rats ever bothered that street again." },
			},
			{ label = "Keep walking", result = { sanity = -1, log = "You kept walking. Behind you, the alley went very quiet, very fast." } },
		},
	},
	{
		id = "bf_gift_offer",
		title = "The Kindred's Gift",
		text = "Livia of the Morvaine Family unwraps a Hemobar and doesn't eat it. \"I'll be plain. The Families are older than the Wings. We heal, we last, and we are always a little thirsty. Hemobars keep us decent. Each of us may make two Kindred in a whole life, and I have made none.\" She holds out her wrist like a contract. \"I'm offering. You can say no, and I won't ask twice.\"",
		weight = 0,
		when = { minAge = 18, form = "human" },
		codex = "bf_lore_kindred",
		choices = {
			{
				label = "Accept the gift",
				hint = "Become a Bloodfiend: quick to heal, slow to age, strong in a fight, and thirsty for good.",
				result = {
					form = "bloodfiend",
					addTrait = "bf_hardblood",
					health = 15,
					sanity = -4,
					setFlags = { "bf_turned", "bf_knows" },
					chronicle = "bf_turned",
					codex = { "bf_lore_hemobars", "bf_lore_hardblood" },
					trigger = "bf_first_thirst",
					log = "A sting at the wrist, then a warmth like a fever breaking. The world got louder, sharper, redder. Livia smiled. \"Welcome to the Morvaine Family, Kindred.\"",
				},
			},
			{ label = "Not yet", result = { sanity = 1, schedule = { event = "bf_gift_offer", inYears = 6 }, log = "\"Not yet,\" you said. Livia nodded as if she'd expected it. \"The offer keeps. So do I.\"" } },
			{ label = "Never", result = { sanity = 2, setFlags = { "bf_refused" }, log = "\"Never,\" you said. She put the foil away. \"Then we're friends, and that's rarer.\" She kept her word." } },
			{
				label = "Sell her address to a Fixer Office",
				hint = "A bounty, and a Family that remembers.",
				result = { money = { 300, 600 }, sanity = -6, rep = { bloodfiends = -50 }, condition = "bf_hunted_family", setFlags = { "bf_refused", "bf_informer", "bf_sold_out" }, schedule = { event = "bf_hunt_fledgling", inYears = 1 }, log = "You sold the address. The Office paid well. A week later the shuttered theater was empty, and someone had left a single red foil wrapper on your doorstep." },
			},
		},
	},
	{
		id = "bf_last_breath",
		title = "At the Edge",
		text = "You're not getting up from this one; you can tell by how calm everyone looks. Then the clinic's back door opens and someone with red eyes sits by the bed. \"I can't fix this,\" says Livia. \"But I can make it not matter. You know the price.\"",
		weight = 60,
		once = true,
		when = { minAge = 18, form = "human", flags = { "bf_knows" }, notFlags = { "bf_refused" }, max = { health = 15 } },
		codex = "bf_lore_kindred",
		choices = {
			{
				label = "Take the gift and live",
				result = {
					form = "bloodfiend",
					addTrait = "bf_hardblood",
					health = 45,
					sanity = -6,
					cure = "any",
					setFlags = { "bf_turned" },
					chronicle = "bf_turned",
					codex = { "bf_lore_hemobars", "bf_lore_hardblood" },
					trigger = "bf_first_thirst",
					log = "A sting at the wrist. The pain went out like a lamp. By morning you were sitting up and asking the nurse, very politely, to close the blinds.",
				},
			},
			{ label = "Let it end as yourself", result = { sanity = 6, setFlags = { "bf_refused" }, log = "\"No,\" you said. Livia held your hand anyway, and stayed until the light came up." } },
		},
	},
	{
		id = "bf_family_question",
		title = "The Family's Question",
		text = "On your eighteenth birthday the Elder's Hand of the Family that raised you sets two things on the table: a Hemobar in red foil, and a WARP ticket to anywhere in the City. \"We fed you, schooled you and kept you safe, and never asked for anything. Now we ask one thing, once. Will you be Kindred?\"",
		weight = 200,
		once = true,
		always = true, -- every Family child is asked in their eighteenth year
		when = { minAge = 18, maxAge = 25, form = "human", flags = { "bf_family_raised" } },
		codex = "bf_lore_kindred",
		choices = {
			{
				label = "Take the red foil",
				hint = "Become a Bloodfiend, and join the Family's service.",
				result = {
					form = "bloodfiend",
					addTrait = "bf_hardblood",
					career = "bf_family",
					setFlags = { "bf_turned" },
					chronicle = "bf_turned",
					codex = { "bf_lore_hemobars", "bf_lore_hardblood" },
					trigger = "bf_first_thirst",
					log = "You took the red foil. The Elder's Hand smiled with all her teeth for the first time in eighteen years. \"Welcome home.\"",
				},
			},
			{ label = "Take the ticket", result = { money = 200, addTrait = "bf_family_friend", setFlags = { "bf_refused" }, log = "You took the ticket. Nobody argued. The Family threw you a farewell dinner, and you were the only one who ate." } },
		},
	},
	{
		id = "bf_lamancha_ticket",
		title = "A Ticket to La Manchaland",
		text = "A glossy flyer under your door: LA MANCHALAND, an amusement park in District 16, \"built and staffed entirely by our own people.\" A free ticket is stapled to the corner. The castle on the flyer is the color of dried roses.",
		weight = 6,
		once = true,
		when = { world = { era = "limbus" }, minAge = 10 },
		codex = "bf_lore_lamancha",
		choices = {
			{
				label = "Go",
				result = { sanity = 6, setFlags = { "bf_lamancha_visited", "bf_knows" }, schedule = { event = "bf_lamancha_staff", inYears = 1 }, log = "The rides were wonderful and the staff were perfect: polite, red-eyed, always smiling. You rode the carousel twice. On the way out, a woman in the ticket booth said \"Come back soon\" like she meant it a little too much." },
			},
			{ label = "Give the ticket to a kid on your street", result = { sanity = 3, log = "The kid came back with a balloon and a story about a castle made of something red and hard as glass." } },
			{ label = "Throw it away", result = { mind = 1, log = "Free tickets come from somewhere. You put it in the stove." } },
		},
	},
	{
		id = "bf_lamancha_staff",
		title = "Hungry Staff",
		text = "La Manchaland has closed its gates \"for maintenance.\" The woman from the ticket booth finds you in {district}, thinner, her smile gone. \"They put all of us on Hemobars,\" she says. \"Some of us can't live on them. You don't have anything... red?\"",
		weight = 0,
		when = { world = { era = "limbus" } },
		codex = "bf_lore_hemobars",
		choices = {
			{ label = "Buy her a box of Hemobars", requires = { min = { money = 60 } }, result = { money = -60, sanity = 3, log = "You bought her a box. She ate one standing up and cried. \"It's not enough,\" she said. \"But it's something.\"" } },
			{ label = "Take her to your Family", requires = { flags = { "bf_family_member" } }, result = { sanity = 5, log = "You took her to the cellar. The Morvaines don't care for La Manchaland, but they don't let anyone starve on their streets." } },
			{
				label = "Ask about the gift",
				hint = "Become a Bloodfiend.",
				requires = { form = "human", minAge = 18, notFlags = { "bf_refused" } },
				result = {
					form = "bloodfiend",
					addTrait = "bf_hardblood",
					setFlags = { "bf_turned" },
					chronicle = "bf_turned",
					codex = { "bf_lore_kindred", "bf_lore_hardblood" },
					trigger = "bf_first_thirst",
					log = "You asked. She looked at you for a long moment, then held out her wrist. \"Then we'll both be living on Hemobars.\"",
				},
			},
			{ label = "Back away", result = { sanity = -3, log = "You backed away. She didn't follow. Later you heard the park was in trouble, and you didn't ask what kind." } },
		},
	},

	-- ── life as Kindred ──
	{
		id = "bf_first_thirst",
		title = "The First Night",
		text = "Everything smells of iron now: the coins in your pocket, the rain, the neighbor coming up the stairs. Your heart beats slow and loud. A note in neat red ink: \"One Hemobar a day until it settles. Never go to bed thirsty.\"",
		weight = 0,
		when = { form = "bloodfiend" },
		choices = {
			{ label = "Do exactly what the note says", result = { sanity = 8, mind = 2, log = "One Hemobar a day, like medicine. By the end of the week the smell of iron was just a smell." } },
			{
				label = "Prove you can go without",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The Thirst", coins = 2, base = 5, coinPower = 3, ignoreSanity = true },
				win = { sanity = 4, mind = 4, log = "You went three days without and learned exactly how far you can push it. Then you ate three Hemobars in a row." },
				lose = { sanity = -8, log = "On the second night you found yourself standing outside the neighbor's door with no memory of the stairs. You went home, ate every Hemobar you had, and shook until dawn." },
			},
		},
	},
	{
		id = "bf_thirst",
		title = "The Thirst",
		text = "It's been too long since your last Hemobar. In the stairwell a neighbor nicks a finger on a loose nail, and the whole world narrows to one thin red line.",
		weight = 30,
		cooldown = 2,
		when = { form = "bloodfiend", max = { sanity = -5 } },
		choices = {
			{
				label = "Walk away. Now.",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The Thirst", coins = 2, base = 5, coinPower = 3, ignoreSanity = true },
				win = { money = -60, sanity = 6, mind = 2, log = "You walked out into the rain and kept walking until your hands stopped shaking. Then you bought six Hemobars and ate them on a bench." },
				lose = { sanity = -6, condition = "bf_frayed", log = "You don't remember the next hour. You woke in your own bed with an empty Hemobar box and the neighbor's door untouched. You checked it three times." },
			},
			{ label = "Buy Hemobars at any price", requires = { min = { money = 80 } }, result = { money = -80, sanity = 12, log = "The all-night clinic keeps a box under the counter for people like you. It cost triple. You didn't haggle." } },
			{
				label = "Go to the Family",
				requires = { flags = { "bf_family_member" } },
				result = { sanity = 12, setFlags = { "bf_owes_family" }, schedule = { event = "bf_family_favor", inYears = 1 }, log = "The cellar door opened before you knocked. Nobody said anything. Someone will, later." },
			},
		},
	},
	{
		id = "bf_hunters",
		title = "A Contract With Your Description",
		text = "A Fixer Office has taken a contract on \"a red-eyed individual\" in {district}, and the description fits you down to the coat. Three of them are asking questions at the noodle stall on your corner.",
		weight = 7,
		cooldown = 6,
		when = { form = "bloodfiend", minAge = 18 },
		choices = {
			{
				label = "Meet them head-on",
				hint = "A real fight. Hardblood against steel and fire.",
				clash = { stat = "strength", foe = "A Fixer Office's hunters", coins = 3, base = 6, coinPower = 3, fight = true, status = "burn" },
				win = { money = { 100, 250 }, sanity = -2, strength = 2, chronicle = "bf_hunters_repelled", log = "Your blood came up as a blade and their torches went out one by one. They left the contract on the counter, unsigned." },
				lose = { health = { -30, -18 }, sanity = -6, condition = "burns", log = "They knew what they were doing. You got out through a window with your coat on fire and didn't stop running until dawn.", cause = "Hunted down by Fixers" },
			},
			{
				label = "Go to ground for a season",
				hint = "Strength check: get out before they get close.",
				clash = { stat = "strength", foe = "The hunters' net", coins = 2, base = 5, coinPower = 3 },
				win = { money = -80, sanity = -3, log = "You lived out of a WARP station locker for a season and came back when the contract expired." },
				lose = { money = -120, health = { -12, -6 }, log = "They nearly had you at the station. You lost a coat, a bag and a lot of sleep.", cause = "Hunted down by Fixers" },
			},
			{ label = "Pay the Office to look elsewhere", requires = { min = { money = 300 } }, result = { money = -300, log = "Offices are businesses. You paid the business. The contract found a different red-eyed individual, in a different District." } },
		},
	},
	{
		id = "bf_shortage",
		title = "Hemobar Shortage",
		text = "Every clinic in {district} is out of Hemobars. Somebody bought up the whole supply, and the street price just tripled.",
		weight = 6,
		cooldown = 5,
		when = { form = "bloodfiend" },
		choices = {
			{ label = "Pay the street price", requires = { min = { money = 150 } }, result = { money = -150, sanity = 4, log = "You paid. The seller had red eyes too, and wouldn't meet yours." } },
			{ label = "Ration what you have", result = { sanity = -7, mind = 2, log = "Half a Hemobar a day for a month. You learned to count your own heartbeats." } },
			{ label = "Ask the Family", requires = { flags = { "bf_family_member" } }, result = { sanity = 5, setFlags = { "bf_owes_family" }, log = "The Family keeps a cellar for exactly this. The Elder's Hand wrote your name in a ledger." } },
		},
	},
	{
		id = "bf_family_favor",
		title = "The Family Calls In a Favor",
		text = "A note on your door in red ink: the Family helped you, and now it needs a crate carried across two Districts before the Night. No questions. No peeking.",
		weight = 0,
		when = { form = "bloodfiend" },
		choices = {
			{
				label = "Carry the crate",
				hint = "Strength check: beat the clock.",
				clash = { stat = "strength", foe = "The 3:13 deadline", coins = 2, base = 5, coinPower = 3 },
				win = { money = { 100, 200 }, clearFlags = { "bf_owes_family" }, log = "You made it with four minutes to spare. The crate held Hemobars for a Family two Districts over that had been going hungry." },
				lose = { health = { -12, -6 }, sanity = -4, clearFlags = { "bf_owes_family" }, log = "You made it, barely, with the first wave already walking. You heard them pass the door you hid behind.", cause = "Caught outside during the Night" },
			},
			{ label = "Pay off the favor instead", requires = { min = { money = 200 } }, result = { money = -200, clearFlags = { "bf_owes_family" }, log = "You paid. The Family accepts money, but it remembers who sends money instead of coming." } },
		},
	},
	{
		id = "bf_taboo",
		title = "The Taboo",
		text = "Livia, who made you Kindred, gives you an order: a family won't sell a building the Morvaines want, and they're to be \"persuaded\" before the Night. Among the Kindred there is one rule older than the rest: a Child does not turn against their Parent.",
		weight = 8,
		once = true,
		when = { career = "bf_family", minRank = 2 },
		codex = "bf_lore_kindred",
		choices = {
			{ label = "Obey", result = { money = { 200, 400 }, sanity = -10, promote = true, log = "You persuaded them. They moved out. You told yourself it was business, and the Family promoted you for telling it well." } },
			{
				label = "Find another way",
				hint = "Mental Strength check: a deal everyone can live with.",
				clash = { stat = "mind", foe = "Your Parent's patience", coins = 2, base = 6, coinPower = 3 },
				win = { sanity = 4, promote = true, log = "You found them a better flat across the District, and the Family a better building down the street. Livia laughed. \"Clever Child.\"" },
				lose = { sanity = -5, log = "Your clever plan satisfied nobody. Livia didn't punish you. She just stopped asking you to do things." },
			},
			{ label = "Refuse, and break the Taboo", result = { quitCareer = true, sanity = 3, setFlags = { "bf_taboo_broken" }, clearFlags = { "bf_family_member" }, log = "You said no. The cellar was locked to you after that, and Livia's seat at the noodle stall stayed empty for years." } },
		},
	},
	{
		id = "bf_rival_family",
		title = "Another Family's Kindred",
		text = "Kindred of a rival Family are drinking Hemobars on Morvaine streets, which is a declaration in a language older than the Wings. The Elder's Hand sends you to answer it.",
		weight = 7,
		cooldown = 5,
		when = { career = "bf_family" },
		choices = {
			{
				label = "Answer in Hardblood",
				hint = "A real fight.",
				clash = { stat = "strength", foe = "Rival Kindred", coins = 3, base = 6, coinPower = 3, fight = true, status = "bleed" },
				win = { promote = true, sanity = -2, log = "Blood met blood, briefly. They left. You came back with a new title." },
				lose = { health = { -20, -10 }, sanity = -4, log = "They were older than you, and it showed. You'll heal. You always do.", cause = "Fell in a quarrel between Families" },
			},
			{
				label = "Talk terms",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "An old Family's pride", coins = 2, base = 6, coinPower = 3 },
				win = { money = { 150, 300 }, log = "You agreed on streets, hours and a fee. Families are old enough to prefer paperwork." },
				lose = { sanity = -4, log = "The talks went nowhere. The rival Kindred went somewhere: your favorite noodle stall, every night." },
			},
		},
	},
	{
		id = "bf_two_in_a_life",
		title = "Two in a Lifetime",
		text = "{friend} is dying of a slow illness, the kind clinics shrug at. You could save them the way you were saved. A Bloodfiend may make only two Kindred in a whole life.",
		weight = 6,
		cooldown = 10,
		when = { form = "bloodfiend", minAge = 25, hasRelation = "friend", notFlags = { "bf_made_two" } },
		codex = "bf_lore_kindred",
		choices = {
			{ label = "Offer them the gift", requires = { notFlags = { "bf_made_one" } }, result = { setFlags = { "bf_made_one" }, relationBond = { kind = "friend", amount = 25 }, sanity = 5, log = "You asked. {friend} said yes. Now someone in the City wakes up thirsty because of you, and thanks you for it anyway." } },
			{ label = "Offer them the gift (your second, and last)", requires = { flags = { "bf_made_one" } }, result = { setFlags = { "bf_made_two" }, relationBond = { kind = "friend", amount = 25 }, sanity = 3, log = "Your second Kindred, and your last. You'll never be able to do this again, for anyone." } },
			{ label = "Let them go as they are", result = { killRelation = "friend", condition = "grief", mind = 2, log = "You sat with them to the end and kept your gift to yourself. You still don't know if that was a kindness." } },
		},
	},
	{
		id = "bf_checkpoint",
		title = "The Checkpoint Scanner",
		text = "The Nest checkpoint has a new scanner. It reads your eyes, your pulse and your blood, and the guard frowns at the screen for a very long time.",
		weight = 5,
		cooldown = 6,
		when = { form = "bloodfiend", minAge = 16 },
		choices = {
			{
				label = "Smile and wait",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "The guard's suspicion", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 2, log = "\"Machine's acting up again,\" the guard said, and waved you through." },
				lose = { money = -100, sanity = -3, log = "Two hours in a side room and a \"processing fee\" later, you were through. The guard kept your name." },
			},
			{ label = "Turn around", result = { sanity = -1, log = "You went back to the Backstreets. Some doors aren't worth the questions." } },
		},
	},
	{
		id = "bf_everyone_ages",
		title = "Everyone Gets Old But You",
		text = "At a reunion of your old academy class, everyone has grey hair and bad knees. Someone jokes that you must keep a portrait in an attic. You laugh a beat too late.",
		weight = 10,
		once = true,
		when = { form = "bloodfiend", minAge = 60 },
		choices = {
			{ label = "Keep showing up for them", result = { relationBond = { kind = "all", amount = 10 }, sanity = -2, log = "You kept going to every reunion until there was no one left to go, and then you kept going to the graves." } },
			{ label = "Move to a new District under a new name", result = { sanity = 3, setFlags = { "bf_new_name" }, log = "You let them think you'd moved away and died. It was easier on everyone but you." } },
			{ label = "Write it all down", result = { intelligence = 3, sanity = 2, log = "You started writing down everyone you'd ever known, in order, before you could forget them. The notebooks filled a shelf." } },
		},
	},
	{
		id = "bf_old_blood",
		title = "Old Blood",
		text = "Fifty years of Hemobars, Family errands and nights you'd rather not remember, and your blood has changed. It hardens faster now. It remembers things.",
		weight = 12,
		once = true,
		when = { form = "bloodfiend", minAge = 75 },
		choices = {
			{ label = "Use it", result = { addTrait = "bf_old_blood", strength = 2, log = "Old Blood: your Hardblood comes as fast as thought. Younger Kindred step aside on the stairs." } },
			{ label = "Fear it a little", result = { addTrait = "bf_old_blood", mind = 3, sanity = -2, log = "Old Blood. You can feel the years in it, and you wonder how many more it wants." } },
		},
	},

	-- ── echoes: another player's deed reaches this life ──
	{
		id = "bf_echo_turned",
		title = "Red-Eyed Rumors",
		text = "Word from {actorDistrict}: {actor} has been seen buying Hemobars at an all-night clinic, and doesn't go out in daylight much anymore.",
		weight = 8,
		cooldown = 6,
		when = { chronicle = "bf_turned", minAge = 12 },
		choices = {
			{ label = "Good for them, honestly", result = { sanity = 2, setFlags = { "bf_knows" }, log = "A long life, quick healing, a Family. You've heard worse deals." } },
			{ label = "Check your locks", result = { mind = 1, log = "You checked your locks. Then you remembered the Taboo: nobody enters a home uninvited during the Night, Bloodfiend or not." } },
			{ label = "Ask them how it's done", requires = { form = "human", minAge = 18, notFlags = { "bf_refused" } }, result = { setFlags = { "bf_knows" }, log = "{actor} just gave you an address and a time. \"Knock after dark. Say I sent you.\"" } },
		},
	},
	{
		id = "bf_echo_hunters",
		title = "The Office That Came Back Empty",
		text = "A Fixer Office in {actorDistrict} took a contract on a Bloodfiend: {actor}. The Office is closed this week \"for repairs.\"",
		weight = 7,
		cooldown = 6,
		when = { chronicle = "bf_hunters_repelled", minAge = 12 },
		choices = {
			{ label = "Steer clear of that District for a while", result = { mind = 1, sanity = 1, log = "You took the long way around {actorDistrict} for a season." } },
			{ label = "Apply at the Office: they're hiring", requires = { minAge = 18 }, result = { wage = { 20, 50 }, strength = 1, log = "They were hiring. Nobody wanted to talk about why." } },
		},
	},
	{
		id = "bf_echo_lost",
		title = "Lost to the Thirst",
		text = "Fixers swept a block in {actorDistrict} last night. The story going round is that {actor}, a Bloodfiend, went too long without a Hemobar.",
		weight = 7,
		cooldown = 6,
		when = { chronicle = "bf_lost", minAge = 12 },
		choices = {
			{ label = "Leave Hemobars at the night shelter, just in case", result = { money = -20, sanity = 3, log = "You left a box of Hemobars at the night shelter with a note: for whoever needs them." } },
			{ label = "Be glad it wasn't your block", result = { sanity = -1, log = "You were glad. You weren't proud of it." } },
		},
	},
}
