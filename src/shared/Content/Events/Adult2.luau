--[[
	More adult life events: ages 18-59. Work, money, home, neighbors, the Kin,
	the Charter, Ward color, raising children, aging parents, health, the strange Mere.
	Threads:
		sponsored_jory      adult2_school_fees -> adult2_jory_returns (8 yrs)
		wrote_to_the_water  adult2_letter_below -> adult2_letter_reply (3 yrs)
		company_pension     adult2_company_pension -> elder2_pension_due (17 yrs, in Elder2)
		                    (pension_clause unlocks a choice in elder2_pension_due)
		kin_package         adult2_kin_package -> adult2_kin_package_called (3 yrs)
		                    (saw_gate_key unlocks a choice in the follow-up)
		child_origins       adult2_child_origins -> adult2_child_kin_found (3 yrs)
	Sets flags other files read: paid_inspector (world_dry_address), sluice_marked
	(world_marked_flood), brine_grudge (life_brine_grudge), worked_for_brine (elder_kin_remember).
	Events that name {corp} are gated to the company career or skip Drownside.
]]

return {
	-- Story threads ----------------------------------------------------------
	{
		id = "adult2_school_fees",
		title = "Chalk on the Stairwell",
		text = "Jory Kettering from two doors down is twelve years old and does sums in chalk on the stairwell wall faster than the Sluice clerks can do them on paper. The Authority's night school has offered him a place, if he can pay the forty {currency} entrance fee by the end of the month. His mother has been staring at the letter for a week, as if it might shrink.",
		weight = 8,
		once = true,
		tags = { "adult", "neighbors", "kindness", "study", "thread_jory" },
		when = { minAge = 22, maxAge = 50, side = "gutters", notFlags = { "sponsored_jory" } },
		choices = {
			{
				label = "Pay the fee yourself",
				hint = "40 scrip.",
				requires = { min = { money = 40 } },
				result = {
					money = -40,
					justice = 2,
					sanity = 3,
					setFlags = { "sponsored_jory" },
					schedule = { event = "adult2_jory_returns", inYears = 8 },
					log = "You paid Jory's fee and told his mother it was an old debt you owed the family. She knew it wasn't.",
				},
			},
			{
				label = "Pass a hat round the stairwell",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A stairwell of thin purses", coins = 2, base = 4, coinPower = 3 },
				win = {
					money = -10,
					justice = 3,
					sanity = 3,
					setFlags = { "sponsored_jory" },
					schedule = { event = "adult2_jory_returns", inYears = 8 },
					log = "You climbed every landing with a hat, put in the last ten {currency} yourself, and Jory started at the night school with a pencil behind each ear.",
				},
				lose = { sanity = -2, log = "You came back down the stairs with eleven {currency} and a button. Jory went to shovel coal at the Pumpworks instead." },
			},
			{
				label = "Tell him the pumps pay sooner",
				result = { prudence = 1, sanity = -2, log = "You told Jory the Pumpworks paid sooner than any school ever would. He nodded like a grown man, which was the worst part." },
			},
		},
	},
	{
		id = "adult2_jory_returns",
		title = "A Clerk on the Landing",
		text = "A young man in a Sluice clerk's coat is waiting on your landing with his hat in his hands, and it takes you a long moment to see the boy who did sums on the stairwell wall. Jory Kettering passed out of the night school third in his year. He has brought back the forty {currency} that got him in, folded very neatly, and he wants to know if there is anything else he can do for you.",
		weight = 0,
		once = true,
		tags = { "adult", "neighbors", "kindness", "sluice", "thread_jory" },
		when = { flags = { "sponsored_jory" } },
		choices = {
			{
				label = "Take the forty, and ask him to supper",
				result = {
					money = 40,
					sanity = 3,
					clearFlags = { "sponsored_jory" },
					addRelation = { kind = "friend", name = "Jory Kettering", bond = 60, age = { 19, 21 } },
					log = "You took the forty so he could stand up straight, and {newRelation} came to supper every month after, with news from the seventh floor.",
				},
			},
			{
				label = "Ask him to lose your address from the flood list",
				hint = "He could. He'd remember you asked.",
				requires = { side = "gutters" },
				result = {
					justice = -3,
					sanity = -1,
					clearFlags = { "sponsored_jory" },
					setFlags = { "paid_inspector" },
					log = "Jory drew a small star beside your address in the flood ledger, very neatly, and did not come up your stairs again.",
				},
			},
			{
				label = "Ask him to read every flood order twice",
				result = {
					justice = 3,
					sanity = 2,
					clearFlags = { "sponsored_jory" },
					addRelation = { kind = "friend", name = "Jory Kettering", bond = 50, age = { 19, 21 } },
					log = "You asked {newRelation} to read every flood order twice before it went upstairs. He said he already did, and you believed him.",
				},
			},
		},
	},
	{
		id = "adult2_letter_below",
		title = "A Letter for Edda Tarrant",
		text = "A letter has come under your door in the night, its paper soft and grey and smelling of the Mere. It is addressed in faded copperplate to Edda Tarrant, at your own rooms, and dated a hundred and twelve years ago, from a house on Chandlers' Row that has been underwater for a century. Inside is a single line: Is there still a light on upstairs?",
		weight = 4,
		once = true,
		tags = { "adult", "strange", "drowned_city", "thread_letter" },
		when = { minAge = 20, maxAge = 55, notFlags = { "wrote_to_the_water" } },
		choices = {
			{
				label = "Write back, and leave a lamp lit",
				result = {
					prudence = 1,
					sanity = -2,
					setFlags = { "wrote_to_the_water" },
					schedule = { event = "adult2_letter_reply", inYears = 3 },
					log = "You wrote back that yes, a light was still on, and left your lamp burning in the window all that winter.",
				},
			},
			{
				label = "Take it to the Choir",
				result = { prudence = 2, sanity = 2, log = "The Still Voice read the letter twice, folded it into a paper boat, and set it on the water without a word." },
			},
			{
				label = "Sell it to a Rim collector",
				result = { money = { 25, 60 }, sanity = -2, log = "A Rim collector of drowned curiosities paid well for the letter, then asked, too casually, whether any more had come." },
			},
			{
				label = "Burn it in the stove",
				result = { sanity = -1, log = "You burned the letter in the stove. It took a very long time to catch, and the room smelled of the Mere for a week." },
			},
		},
	},
	{
		id = "adult2_letter_reply",
		title = "A Reply from Below",
		text = "Three winters after you wrote back, a second letter comes under your door, as soft and grey as the first. This one is addressed to you, by name, in the same faded hand. It thanks you for the light, and says the street below has been very dark for a very long time. It asks, politely, whether you might come down and visit at the next Low Water.",
		weight = 0,
		once = true,
		tags = { "adult", "strange", "drowned_city", "thread_letter" },
		when = { flags = { "wrote_to_the_water" } },
		choices = {
			{
				label = "Keep the lamp lit, and stay upstairs",
				result = {
					prudence = 2,
					sanity = 3,
					clearFlags = { "wrote_to_the_water" },
					log = "You kept a lamp burning in your window every night after that, and no more letters came. It felt like a promise kept.",
				},
			},
			{
				label = "Go down at Low Water and knock",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "A drowned door on Chandlers' Row", coins = 3, base = 6, coinPower = 3 },
				win = {
					prudence = 3,
					sanity = 6,
					gear = "little_bell",
					clearFlags = { "wrote_to_the_water" },
					log = "You knocked on a drowned door on Chandlers' Row. Nobody answered, but on the step, left out for you, was a little brass bell that rang on its own.",
				},
				lose = {
					sanity = { -10, -6 },
					condition = "night_terrors",
					clearFlags = { "wrote_to_the_water" },
					log = "You knocked on a drowned door, and something on the other side knocked back, in time with your heart.",
				},
			},
			{
				label = "Write that the family has moved away",
				result = {
					justice = -1,
					sanity = -2,
					clearFlags = { "wrote_to_the_water" },
					log = "You wrote that the Tarrants had moved away and left no address. That night the lamp in your window went out on its own.",
				},
			},
		},
	},
	{
		id = "adult2_company_pension",
		title = "The Pension Book",
		text = "A smiling clerk from the top floor of {corp} is going desk to desk with a leather-bound book. For a hundred {currency} paid in now, the company promises you a pension when your eyes and hands give out, enough to keep a stove lit and a roof on. The book is thick with signatures. The clerk's own name, you notice, is not among them.",
		once = true,
		tags = { "adult", "career", "company", "money", "thread_pension" },
		when = { career = "company", minAge = 38, maxAge = 46, notFlags = { "company_pension" } },
		choices = {
			{
				label = "Sign and pay in",
				hint = "100 scrip.",
				requires = { min = { money = 100 } },
				result = {
					money = -100,
					prudence = 1,
					sanity = 2,
					setFlags = { "company_pension" },
					schedule = { event = "elder2_pension_due", inYears = 17 },
					log = "You paid in your hundred {currency} and signed the pension book under four hundred other names.",
				},
			},
			{
				label = "Read the small print, then sign",
				hint = "100 scrip. Temperance clash, medium-hard.",
				requires = { min = { money = 100 } },
				clash = { stat = "temperance", foe = "Nine pages of small print", coins = 2, base = 5, coinPower = 3 },
				win = {
					money = -100,
					temperance = 2,
					setFlags = { "company_pension", "pension_clause" },
					schedule = { event = "elder2_pension_due", inYears = 17 },
					log = "You read all nine pages, found clause nine, and copied it into your notebook before you signed.",
				},
				lose = { sanity = -2, log = "The small print ran to nine pages of old legal script. You put down the pen and kept your hundred." },
			},
			{
				label = "Keep your money where you can see it",
				result = { prudence = 2, log = "You kept your hundred {currency} and your doubts. The clerk wrote something small beside your name." },
			},
		},
	},
	{
		id = "adult2_kin_package",
		title = "Something to Keep Dry",
		text = "Long after midnight a Brine Kin cousin named Sorrel Rook comes up your stairs, dripping, with an oilskin bundle the size of a loaf. \"Keep it dry, keep it shut, and keep it under your floor, cousin,\" she says. \"Someone will come for it.\" She leaves thirty {currency} on your table and is gone before you can answer.",
		weight = 8,
		once = true,
		tags = { "adult", "brine", "crime", "thread_package" },
		when = { minAge = 18, maxAge = 55, side = "gutters", notFlags = { "kin_package", "brine_grudge" } },
		choices = {
			{
				label = "Hide it under the floorboards",
				result = {
					money = 30,
					prudence = 1,
					sanity = -1,
					setFlags = { "kin_package" },
					schedule = { event = "adult2_kin_package_called", inYears = 3 },
					log = "You hid the bundle under a loose floorboard and stopped sleeping on that side of the bed.",
				},
			},
			{
				label = "Open it, carefully",
				result = {
					money = 30,
					sanity = -2,
					setFlags = { "kin_package", "saw_gate_key" },
					schedule = { event = "adult2_kin_package_called", inYears = 3 },
					log = "Inside the oilskin was an iron key as long as your forearm, stamped with the Sluice seal. You wrapped it up again with shaking hands and hid it under the floor.",
				},
			},
			{
				label = "Carry it back to the Kin dock",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The Kin dock at midnight", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, sanity = 1, log = "You set the bundle and the thirty on an upturned boat at the Kin dock and explained, very politely, that your floor was full. The cousin on watch laughed." },
				lose = { sanity = -2, setFlags = { "brine_grudge" }, log = "You left the bundle on the Kin dock, and the Kin took it as the insult it sounded like." },
			},
			{
				label = "Hand it to a Sluice patrol",
				result = { money = { 40, 70 }, justice = 1, sanity = -2, setFlags = { "brine_grudge" }, log = "You handed the bundle to a Sluice patrol boat for a reward. By morning there was a chalk hook on your door." },
			},
		},
	},
	{
		id = "adult2_kin_package_called",
		title = "Someone Comes for It",
		text = "Three years on, two parties come for the bundle under your floor on the same wet night. Sorrel Rook is at your back window with two cousins and a shuttered lantern. At your front door a Sluice inspector in a wax coat is knocking, politely, with a patrol waiting behind him in the fog.",
		weight = 0,
		once = true,
		tags = { "adult", "brine", "crime", "thread_package" },
		when = { flags = { "kin_package" } },
		choices = {
			{
				label = "Pass it out the back window",
				result = {
					money = { 40, 80 },
					prudence = 2,
					sanity = 2,
					clearFlags = { "kin_package", "saw_gate_key" },
					log = "You passed the bundle out of the back window to Sorrel, and the Kin paid you for three years of bad sleep. The inspector found an empty floor.",
				},
			},
			{
				label = "Hand it to the inspector",
				result = {
					money = { 60, 110 },
					justice = 2,
					sanity = -2,
					setFlags = { "brine_grudge" },
					clearFlags = { "kin_package", "saw_gate_key" },
					log = "You gave the inspector the bundle, and he gave you a reward and a receipt. The Kin gave you a chalk hook on your door.",
				},
			},
			{
				label = "Throw it in the Mere between them",
				hint = "Justice clash, medium-hard.",
				clash = { stat = "justice", foe = "Two sets of hands at once", coins = 2, base = 5, coinPower = 3 },
				win = {
					justice = 2,
					sanity = 3,
					clearFlags = { "kin_package", "saw_gate_key" },
					log = "You ran out along the walkway and dropped the bundle into the deep water while both sides shouted. Neither of them could prove a thing.",
				},
				lose = {
					fortitude = { -8, -4 },
					sanity = -3,
					condition = "broken_arm",
					setFlags = { "brine_grudge" },
					clearFlags = { "kin_package", "saw_gate_key" },
					log = "Both sides caught you on the walkway at once. You came out of it with a broken arm and no friends at all.",
					cause = "Caught between the Kin and the Sluice",
				},
			},
			{
				label = "Sell the gate key to the Exchange",
				hint = "You know what it is.",
				requires = { flags = { "saw_gate_key" } },
				result = {
					money = { 200, 300 },
					justice = -3,
					sanity = -4,
					setFlags = { "brine_grudge", "sluice_marked" },
					clearFlags = { "kin_package", "saw_gate_key" },
					log = "You sold the gate key to an Exchange man through the back window and made enemies of everyone at once.",
				},
			},
		},
	},
	{
		id = "adult2_child_origins",
		title = "Before You",
		text = "{child} asks it at supper, between one spoonful and the next, the way you might ask about the weather: where did they come from, before you? The Foundling Steps keep a ledger of every child ever left on them, with a scrap of whatever they were wrapped in. {child} has put down their spoon and is looking at you very steadily.",
		once = true,
		tags = { "adult", "family", "child", "thread_origins" },
		when = { minAge = 26, maxAge = 55, hasRelation = "child", notFlags = { "child_origins" } },
		choices = {
			{
				label = "Take them to read the ledger",
				result = {
					prudence = 1,
					relationBond = { kind = "child", amount = 6 },
					setFlags = { "child_origins" },
					schedule = { event = "adult2_child_kin_found", inYears = 3 },
					log = "You took {child} to the Foundling Steps, and the matron found their page: a date, a scrap of blue wool, and a name nobody had ever used.",
				},
			},
			{
				label = "Tell them they came from this table",
				result = { sanity = 2, relationBond = { kind = "child", amount = 4 }, log = "You told {child} they came from this table, and these stairs, and you. They seemed to believe it, mostly." },
			},
			{
				label = "Change the subject",
				result = { sanity = -2, relationBond = { kind = "child", amount = -6 }, log = "You changed the subject. {child} finished their broth and never asked you again." },
			},
		},
	},
	{
		id = "adult2_child_kin_found",
		title = "A Scrap of Blue Wool",
		text = "An old net-mender named Odile Fenwick is standing at your door with a scrap of blue wool in one hand, the twin of the one in the Foundling ledger, and the matron's note with your address in the other. She lost her daughter to a High Water long ago, she says, and has been looking for the baby ever since. She does not want to take {child} away; she would only like to know them.",
		weight = 0,
		once = true,
		tags = { "adult", "family", "child", "thread_origins" },
		when = { flags = { "child_origins" }, hasRelation = "child" },
		choices = {
			{
				label = "Ask her in for supper",
				result = {
					sanity = 4,
					relationBond = { kind = "child", amount = 8 },
					clearFlags = { "child_origins" },
					addRelation = { kind = "friend", name = "Odile Fenwick", bond = 50, age = { 62, 72 } },
					log = "You asked {newRelation} in for supper, and {child} gained a grandmother who brought fish up the stairs every week.",
				},
			},
			{
				label = "Let {child} decide",
				result = {
					prudence = 2,
					relationBond = { kind = "child", amount = 10 },
					clearFlags = { "child_origins" },
					log = "You left it to {child}, who sat a long while and then went to the door alone. They came back an hour later and hugged you without a word.",
				},
			},
			{
				label = "Check her story first",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A story you need to be true", coins = 2, base = 4, coinPower = 3 },
				win = {
					prudence = 2,
					sanity = 3,
					relationBond = { kind = "child", amount = 6 },
					clearFlags = { "child_origins" },
					addRelation = { kind = "friend", name = "Odile Fenwick", bond = 50, age = { 62, 72 } },
					log = "Her story held at every step, down to the matron's own memory of the night. {newRelation} came to supper that week.",
				},
				lose = {
					sanity = -4,
					relationBond = { kind = "child", amount = -6 },
					clearFlags = { "child_origins" },
					log = "You questioned her so hard that she left in tears. She had been telling the truth, the matron said later.",
				},
			},
			{
				label = "Send her away",
				result = {
					sanity = -3,
					relationBond = { kind = "child", amount = -10 },
					clearFlags = { "child_origins" },
					log = "You told her she had the wrong door. {child} watched her go from the window and said nothing for a week.",
				},
			},
		},
	},

	-- Work ---------------------------------------------------------------------
	{
		id = "adult2_stoker_firebox",
		title = "The Firebox Door",
		text = "The door of the Number Three firebox has buckled in the heat and swung open on its hinge, and it will not latch. Every minute it hangs open the pressure drops, and somewhere up the Terraces a pump slows and the water creeps a little higher. The latch bar is glowing a dull cherry red. Your gloves are on the far side of the boiler room.",
		cooldown = 5,
		tags = { "adult", "career", "stoker", "danger" },
		when = { career = "stoker", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Slam it shut bare-handed",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The Number Three firebox", coins = 2, base = 4, coinPower = 3 },
				win = { paycheck = 0.2, fortitude = 1, sanity = 3, log = "You slammed the door and dropped the latch in one movement, and the gauge was climbing again before anyone noticed your hands." },
				lose = {
					fortitude = { -6, -3 },
					sanity = -2,
					condition = "burned_hands",
					log = "You got the door shut, and the latch bar left its shape across both your palms.",
					cause = "Burned at the Pumpworks",
				},
			},
			{
				label = "Wedge it with a shovel and a firebrick",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "A buckled hinge", coins = 2, base = 4, coinPower = 3 },
				win = { temperance = 2, prudence = 1, log = "You wedged the door with a shovel handle and a firebrick, and it held until the Valve Keeper came down with the long tongs." },
				lose = { money = { -15, -5 }, sanity = -2, log = "The shovel slid into the firebox, and the shift boss docked you for a new one." },
			},
			{
				label = "Run for your gloves",
				result = { money = { -12, -5 }, prudence = 1, log = "You ran for your gloves and shut the door properly, and the bosses docked you for the lost pressure." },
			},
		},
	},
	{
		id = "adult2_stoker_gauge",
		title = "Numbers on the Dial",
		text = "You have noticed that Teodor Drabb, the best Ash Hand on your shift, never reads the pressure gauge himself. He waits for someone else to call the number, then nods as if he had known it all along. Tonight you are alone with him when the needle starts to climb, and he looks at the dial, and then at you, like a man standing at the edge of a drop.",
		once = true,
		tags = { "adult", "career", "stoker", "kindness", "study" },
		when = { career = "stoker", minRank = 2, minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Teach him his numbers on the night shifts",
				result = {
					temperance = 2,
					justice = 2,
					sanity = 3,
					addRelation = { kind = "friend", name = "Teodor Drabb", bond = 55, age = { 24, 34 } },
					log = "You taught {newRelation} his numbers in chalk on the boiler casing, one shift at a time, and he never waited for anyone again.",
				},
			},
			{
				label = "Call the number aloud, as if to yourself",
				result = { justice = 1, sanity = 1, log = "You called the number aloud as if talking to yourself, and kept on doing it for as long as you shared a shift." },
			},
			{
				label = "Make him read it, right now",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The climbing needle", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, justice = 1, sanity = 2, log = "You stood beside him and made him read the needle out, digit by digit, until he had it. You bled the valve together with a turn to spare." },
				lose = {
					fortitude = { -6, -2 },
					sanity = -3,
					log = "He froze, you hesitated, and the safety valve blew steam across you both.",
					cause = "Scalded at the Pumpworks",
				},
			},
			{
				label = "Report him to the shift bosses",
				result = { paycheck = 0.1, justice = -3, sanity = -3, log = "You reported him, and the bosses moved Teodor to the coal yard. He still nodded to you on the stairs, which was worse." },
			},
		},
	},
	{
		id = "adult2_diver_apprentice",
		title = "Your First Wet Lantern",
		text = "The Guild has given you your first Wet Lantern to train: Yarrow Duskin, sixteen, all elbows and courage, who ties a better knot than you did at her age. Thirty feet down in the drowned tram depot, her line fouls on a rusted coupling. Through the green water you watch her lantern begin to swing in quick, frightened circles.",
		once = true,
		tags = { "adult", "career", "diver", "mentor", "danger" },
		when = { career = "diver", minRank = 3, minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Cut her free and bring her up on your rope",
				hint = "Justice clash, medium-hard.",
				clash = { stat = "justice", foe = "The drowned tram depot", coins = 2, base = 5, coinPower = 3 },
				win = {
					justice = 3,
					sanity = 4,
					promote = true,
					addRelation = { kind = "friend", name = "Yarrow Duskin", bond = 60, age = { 16, 17 } },
					log = "You cut {newRelation} free and brought her up on your own rope, and the whole Guild pier stood up when you surfaced.",
				},
				lose = {
					fortitude = { -10, -5 },
					sanity = -4,
					log = "You got her free, but the coupling took your rope instead, and it was Yarrow who brought you up.",
					cause = "Lost in the drowned tram depot",
				},
			},
			{
				label = "Hold her lantern steady and sign slow",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A frightened apprentice", coins = 2, base = 4, coinPower = 3 },
				win = {
					prudence = 3,
					sanity = 3,
					addRelation = { kind = "friend", name = "Yarrow Duskin", bond = 55, age = { 16, 17 } },
					log = "You held her lantern steady and signed slow, slow, slow until {newRelation} worked the knot free herself.",
				},
				lose = { sanity = -5, log = "She kicked loose in a panic and shot for the surface too fast. She lived, but she never dove again." },
			},
			{
				label = "Signal the rope crew to haul",
				result = { prudence = 1, sanity = -2, log = "You signaled the crew, and they hauled her up so hard the coupling tore her suit. She lived, and asked the Guild for a different teacher." },
			},
		},
	},
	{
		id = "adult2_sluice_petitioners",
		title = "The Petitioners' Bench",
		text = "Every morning the bench outside your office is full before the doors open: an old man with his roof deed wrapped in oilcloth, a girl with her little brother asleep on her shoulder, a whole row of Silt families asking for their addresses to come off the next flood list. You have time to hear perhaps three of them a day. The list goes upstairs at the end of the week.",
		cooldown = 6,
		tags = { "adult", "career", "sluice" },
		when = { career = "sluice", minRank = 2, minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Hear every one of them",
				result = {
					fortitude = -2,
					justice = 3,
					sanity = -3,
					log = "You heard every petition on the bench through your lunch and long after dark, and moved four addresses before the list went upstairs. There were forty-one.",
				},
			},
			{
				label = "Hear the ones with envelopes first",
				result = { money = { 40, 90 }, justice = -4, sanity = -3, log = "You heard the petitions with envelopes first. By the end of the week you had a good new coat and could not look at the bench." },
			},
			{
				label = "March the whole bench up to the seventh floor",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "The seventh floor", coins = 2, base = 5, coinPower = 3 },
				win = { justice = 4, sanity = 3, log = "You marched forty petitioners up to the seventh floor, and somebody signed a dozen of them just to empty the corridor." },
				lose = { money = { -30, -15 }, sanity = -3, log = "The seventh floor docked your pay for the disturbance and had the bench carried out of the corridor." },
			},
		},
	},
	{
		id = "adult2_brine_informant",
		title = "A Captain in the Fog",
		text = "A Sluice patrol boat has slid alongside yours in the fog with its big lamp shuttered. The captain knows your name, your cousins' names, and where the Kin keep the dry cellar under the old viaduct. \"Tell me which night the oil comes in,\" he says, \"and your page in my book stays clean. Refuse, and I start reading it aloud.\"",
		once = true,
		tags = { "adult", "career", "brine", "crime" },
		when = { career = "brine", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Refuse him",
				result = {
					prudence = 2,
					sanity = -2,
					setFlags = { "sluice_marked" },
					log = "You told the captain you had never heard of any oil. A week later your address was circled in red in the Sluice flood ledger.",
				},
			},
			{
				label = "Feed him the wrong night",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "The patrol captain", coins = 2, base = 5, coinPower = 3 },
				win = {
					paycheck = 0.3,
					prudence = 3,
					promote = true,
					log = "You fed him the wrong night, and his patrol sat in the fog while the oil came in somewhere else. The Elder Kin heard about it.",
				},
				lose = {
					fortitude = { -6, -2 },
					sanity = -4,
					setFlags = { "brine_grudge" },
					log = "The captain raided the wrong night, guessed who had lied to him, and made sure the Kin heard you had been talking.",
					cause = "Caught between the Kin and the Sluice",
				},
			},
			{
				label = "Give him the real night",
				result = {
					money = { 80, 140 },
					justice = -2,
					sanity = -5,
					quitCareer = true,
					condition = "marked",
					log = "You gave up the real night. The patrol seized the oil, the captain paid you, and the Kin took your oar and your name.",
				},
			},
		},
	},
	{
		id = "adult2_choir_steps",
		title = "The Steps Are Sold",
		text = "The Sluice Authority has sold the old ferry steps, where the Choir has sat facing the water for two hundred years, to a builder who wants them for a gate-house. Surveyors in yellow oilskins are hammering stakes between the Listeners. The Still Voice has not opened her eyes. Everyone else on the steps is looking at you.",
		once = true,
		tags = { "adult", "career", "choir", "faith" },
		when = { career = "choir", minRank = 2, minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Sit in silence until they give up",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The builder's deadline", coins = 3, base = 6, coinPower = 3 },
				win = {
					prudence = 4,
					sanity = 5,
					promote = true,
					log = "You sat among the stakes for forty days without a word. The builders, unnerved, went to build somewhere drier.",
				},
				lose = {
					fortitude = { -6, -2 },
					sanity = -4,
					log = "You sat until the frost got into your chest, and the gate-house went up around the Choir anyway.",
					cause = "Took a chill on the ferry steps",
				},
			},
			{
				label = "Empty your savings into the Choir's bowl",
				hint = "120 scrip.",
				requires = { min = { money = 120 } },
				result = { money = -120, justice = 2, sanity = 3, log = "You emptied your savings into the Choir's bowl, and the Listeners raised the rest a note at a time. The steps were bought back by spring." },
			},
			{
				label = "Lead the Choir to a new shore",
				result = { prudence = 2, sanity = -2, log = "You led the Choir to the old coal pier, which faced the same water and had no history at all. It took years to feel like anything." },
			},
		},
	},
	{
		id = "adult2_company_cuts",
		title = "A Third of Your People",
		text = "The board of {corp} wants a third of your people gone by the end of the quarter, and it wants you to choose who. The list is on your desk: eighteen names, in your own handwriting, from the last staff count. Down the corridor someone is laughing at a joke, not knowing yet.",
		once = true,
		tags = { "adult", "career", "company" },
		when = { career = "company", minRank = 3, minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Cut by the numbers",
				result = { paycheck = 0.25, justice = -3, sanity = -4, log = "You cut the six slowest by the ledger. The numbers were right, and you could not stop seeing the empty desks." },
			},
			{
				label = "Argue the board down",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The board of directors", coins = 3, base = 6, coinPower = 3 },
				win = { justice = 4, sanity = 4, promote = true, log = "You argued the board down to two names and a hiring freeze, and somehow walked out of the room promoted." },
				lose = { justice = 1, sanity = -5, log = "The board thanked you for your view, cut seven instead of six, and wrote your name down." },
			},
			{
				label = "Give up part of your salary to save two",
				hint = "A third of a year's pay.",
				result = { paycheck = -0.3, justice = 4, sanity = 2, log = "You signed away a third of your salary to keep two clerks on, and told nobody whose money it was." },
			},
		},
	},

	-- Money and home -----------------------------------------------------------
	{
		id = "adult2_pawnbroker",
		title = "The Pawnbroker on Gull Steps",
		text = "The rent is late, the stove is cold, and the pawnbroker on Gull Steps is standing in his doorway as if he has been waiting for you in particular. He has a jeweler's lens screwed into one eye and a ledger chained to his counter. \"Everything has a price,\" he says pleasantly. \"Let's see what you've got.\"",
		cooldown = 6,
		tags = { "adult", "money" },
		when = { minAge = 18, maxAge = 59, max = { money = 25 } },
		choices = {
			{
				label = "Pawn your tool",
				hint = "Needs a tool. You'll lose it.",
				requires = { hasGear = { "dock_knife", "hook_pole", "pocket_ledger", "tide_tables", "diving_lamp" } },
				result = { loseGear = "tool", money = { 25, 50 }, sanity = -2, log = "You pawned your tool and paid the rent. Your hands felt wrong for a month." },
			},
			{
				label = "Pawn your coat",
				hint = "Needs a coat. You'll lose it.",
				requires = { hasGear = { "oilskin", "dock_jacket", "company_greatcoat" } },
				result = { loseGear = "coat", money = { 30, 70 }, fortitude = -1, log = "You pawned your coat and spent the rest of the winter with your arms crossed." },
			},
			{
				label = "Pawn your charm",
				hint = "Needs a charm. You'll lose it.",
				requires = { hasGear = { "still_stone", "little_bell", "lantern_token" } },
				result = { loseGear = "charm", money = { 15, 35 }, sanity = -3, log = "You pawned your charm. He put it in his window, and you walked the long way round for a year to avoid it." },
			},
			{
				label = "Sell him a story instead",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "A pawnbroker who has heard every story", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 15, 30 }, sanity = 2, log = "You sold him the story of the drowned Mint, told so well that he paid for it and wrote it in his ledger." },
				lose = { sanity = -2, log = "He listened to the whole story, said he'd heard it told better last week, and showed you the door." },
			},
		},
	},
	{
		id = "adult2_inheritance",
		title = "A House in Drownside",
		text = "A Sluice registry clerk has tracked you down to tell you that a great-aunt you never met, Isolde Corwen, has died at ninety-one and left you everything she owned. That turns out to be a half-sunk stilt-house in Drownside, with a roof, a stove, a fine view of the Brine Kin docks, and thirty years of unpaid water-rates. The clerk slides a brass key across the counter on a loop of tarred string.",
		weight = 3,
		once = true,
		tags = { "adult", "money", "home" },
		when = { minAge = 20, maxAge = 55, notDistrict = "drownside" },
		choices = {
			{
				label = "Move in and make it yours",
				hint = "You'll move to Drownside.",
				result = {
					district = "drownside",
					money = { 30, 70 },
					sanity = 3,
					log = "You moved into your great-aunt's stilt-house in Drownside and found her savings in a tin behind the stove, with a note that said: about time.",
				},
			},
			{
				label = "Sell it to the Brine Kin",
				result = { money = { 60, 110 }, prudence = 1, log = "A Kin cousin bought the house sight unseen, water-rates and all, and paid you in notes that smelled of oranges." },
			},
			{
				label = "Haggle down the rates and sell it fair",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "Thirty years of water-rates", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 100, 160 }, temperance = 2, log = "You haggled the water-rates down to almost nothing and sold the house to a salvage family for a fair price." },
				lose = { money = { -40, -20 }, sanity = -2, log = "The water-rates turned out to have interest on the interest. You paid it and signed the house over to the Sluice." },
			},
			{
				label = "Keep only the key",
				result = { prudence = 1, sanity = 1, log = "You signed the house back to the Sluice, debts and all, and kept the brass key on its string for luck." },
			},
		},
	},
	{
		id = "adult2_rent_collector",
		title = "The Agent's Offer",
		text = "The landlord's agent stops you on the stairs with a friendly hand on your arm. Your rent will be forgiven for the year, he says, if you'll collect everyone else's for him: ten doors, every quarter, and a list of who comes up short. \"They'll open for you,\" he says. \"They never open for me.\"",
		weight = 8,
		once = true,
		tags = { "adult", "rent", "home", "neighbors" },
		when = { minAge = 20, maxAge = 59, side = "gutters" },
		choices = {
			{
				label = "Take the job",
				result = { money = { 30, 50 }, justice = -3, sanity = -3, log = "You collected rent from ten doors for a year. Your own was forgiven, and nobody on the landing wished you good morning again." },
			},
			{
				label = "Take it, and cover for the short doors",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The agent's own ledger", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 10, 20 }, justice = 2, sanity = 1, log = "You marked the short doors as paid and covered the gaps out of your own forgiven rent. It came out almost even, and the landing never knew." },
				lose = { money = { -40, -20 }, sanity = -3, log = "The agent checked your list against his own and charged you every missing note, with interest." },
			},
			{
				label = "Refuse, and tell the landing",
				result = { money = { -15, -5 }, justice = 3, sanity = 1, log = "You refused and told the whole landing what he'd asked. Your rent went up the next quarter, and every door on the landing opened for you after that." },
			},
		},
	},

	-- Neighbors and the Kin ------------------------------------------------------
	{
		id = "adult2_tide_neighbors",
		title = "New Neighbors",
		text = "A Tidetouched family has taken the empty rooms across your landing: a father with faint gill-lines at his throat, two quiet children who can hold their breath for a whole tram ride, and a grandmother who sleeps in a tin bath full of water. By the second week someone has chalked a fish on their door. By the third, a petition to have them put out of the building has reached yours.",
		weight = 8,
		once = true,
		tags = { "adult", "neighbors", "tidetouched" },
		when = { minAge = 18, maxAge = 59, side = "gutters" },
		choices = {
			{
				label = "Tear up the petition on the landing",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The landing's temper", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 4,
					sanity = 3,
					addRelation = { kind = "friend", bond = 50, age = { 30, 45 } },
					log = "You tore the petition in half in front of the whole landing. After that, {newRelation} from across the way brought you fish from the deep water every week.",
				},
				lose = { justice = 2, sanity = -3, log = "You tore up the petition, and by morning someone had chalked a fish on your door too." },
			},
			{
				label = "Scrub the chalk off their door",
				result = { justice = 2, sanity = 1, log = "You scrubbed the chalk off their door every morning until whoever was drawing it got tired first." },
			},
			{
				label = "Greet them the old way",
				hint = "Tidetouched only.",
				requires = { form = "tidetouched" },
				result = {
					justice = 1,
					sanity = 4,
					addRelation = { kind = "friend", bond = 55, age = { 30, 45 } },
					log = "You knocked and touched two fingers to your own throat. The grandmother in the tin bath laughed out loud, and {newRelation} asked you in.",
				},
			},
			{
				label = "Sign it to keep the peace",
				result = { justice = -4, sanity = -3, log = "You signed the petition to keep the peace. The family moved out in the spring, and the landing was very peaceful." },
			},
		},
	},
	{
		id = "adult2_witness",
		title = "What You Saw on the Pier",
		text = "In the fog at the end of the Lamp Street pier, you saw a Brine Kin cousin shove a Sluice tally clerk into the black water and stroll away whistling. The clerk was fished out alive, just. Now the Authority's inquiry wants a witness, the Kin want a quiet pier, and both of them know exactly where you live.",
		weight = 7,
		once = true,
		tags = { "adult", "crime", "brine", "danger" },
		when = { minAge = 18, maxAge = 59, side = "gutters" },
		choices = {
			{
				label = "Testify at the inquiry",
				result = { justice = 5, sanity = -2, condition = "marked", log = "You testified, and the cousin went to the Sluice cells. The Kin made very sure you knew they knew." },
			},
			{
				label = "Write it down in a borrowed hand",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "A handwriting the Kin might know", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 1, log = "You wrote what you saw in a careful, borrowed hand and slid it under the inquiry's door. Nobody ever came asking." },
				lose = { sanity = -3, setFlags = { "brine_grudge" }, log = "The Kin knew your handwriting from the stairwell rota. There was a chalk hook on your door by the end of the week." },
			},
			{
				label = "Tell the inquiry you saw only fog",
				result = { prudence = 1, justice = -3, sanity = -3, log = "You told the inquiry you had seen nothing but fog. Across the room, the clerk's eyes found you and stayed." },
			},
			{
				label = "Sell your silence to the Kin",
				result = { money = { 30, 60 }, justice = -4, sanity = -4, log = "A fold of notes and an orange appeared on your step. You kept the notes, and you couldn't help eating the orange." },
			},
		},
	},

	-- The Charter --------------------------------------------------------------
	{
		id = "adult2_charter_lease",
		title = "Three Generations of Good Character",
		text = "Every five years {corp} reviews the leases of those who bought their way inside the walls, and this year the review asks for three generations of good character, in writing, witnessed. Your parents were Gutters people, and so were theirs. The clerk sets your file on a tray marked PENDING, which in this building is a word with teeth.",
		once = true,
		tags = { "adult", "charter", "home" },
		when = { minAge = 20, maxAge = 59, side = "charter", notFlags = { "charter_born", "heir" }, notDistrict = { "drownside", "glasswall" } },
		choices = {
			{
				label = "Pay the character bond",
				hint = "150 scrip.",
				requires = { min = { money = 150 } },
				result = { money = -150, sanity = -1, log = "You paid the character bond, which the company assured you was refundable, in principle." },
			},
			{
				label = "Write yourself a better family",
				hint = "Temperance clash, medium-hard. Lose, and you're out.",
				clash = { stat = "temperance", foe = "The review clerk's eye", coins = 2, base = 5, coinPower = 3 },
				win = { temperance = 2, justice = -1, sanity = 2, log = "You wrote your grandparents into a family of modest Rim lamp merchants, and the clerk found them very convincing." },
				lose = {
					side = "gutters",
					sanity = -6,
					log = "The clerk compared your inks, closed your file, and sent two guards to help you carry your things down to the Gutters.",
				},
			},
			{
				label = "Tell the board the truth",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The review board", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 3, log = "You told the board exactly who your people were and what they had built with their hands. One director's mother had raked salt, and your lease was renewed." },
				lose = { money = { -90, -60 }, sanity = -4, log = "The board heard you out, renewed your lease on probation, and doubled your levy for the trouble." },
			},
		},
	},
	{
		id = "adult2_charter_clinic",
		title = "The Clinic Door",
		text = "A Gutters girl carrying a basket of laundry has slipped on the wet steps outside the Charter gate and struck her head on the stone, and now she can't stand. The Charter clinic is twenty steps away, all brass and white tile. Its doorman has seen the laundry basket and is shaking his head before you've opened your mouth.",
		cooldown = 6,
		tags = { "adult", "charter", "kindness" },
		when = { minAge = 18, maxAge = 59, side = "charter" },
		choices = {
			{
				label = "Pay her fee in advance",
				hint = "40 scrip.",
				requires = { min = { money = 40 } },
				result = { money = -40, justice = 3, sanity = 2, log = "You paid the clinic's fee in advance, and the doorman found that he could open the door after all." },
			},
			{
				label = "Argue with the doorman",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The clinic doorman", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 3, log = "You argued until a doctor came out to see what the noise was, and she carried the girl in herself." },
				lose = { money = -10, sanity = -3, log = "The doorman called the gate guards, who fined you for the noise and moved you both along." },
			},
			{
				label = "Carry her down to a Gutters stitcher",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "Four hundred stairs with a girl in your arms", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = 1, justice = 4, sanity = 2, log = "You carried her four hundred stairs down to a stitcher on the Terraces, who said you had made very good time." },
				lose = {
					fortitude = { -6, -2 },
					justice = 2,
					sanity = -1,
					log = "Your knee went halfway down. Two dockhands carried her the rest of the way, and you limped home behind them.",
					cause = "Fell on the switchback stairs",
				},
			},
			{
				label = "Walk on through the gate",
				result = { justice = -3, sanity = -2, log = "You walked on through the gate. When you looked back from the top of the steps, the basket was still there and the girl was not." },
			},
		},
	},

	-- Wards --------------------------------------------------------------------
	{
		id = "adult2_lampwick_oil",
		title = "Oil in the Cistern",
		text = "The cistern under your stairwell has started tasting of lamp oil. There is a rainbow skin on every bucket, and the children on the landing have headaches that won't go away. Everyone knows the Lamplight Company's storage tanks sit just uphill behind the Charter wall, and everyone knows the company will say otherwise.",
		once = true,
		tags = { "adult", "lampwick", "sickness" },
		when = { district = "lampwick", side = "gutters", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Set a bucket on a director's desk",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The Lamplight Company front office", coins = 3, base = 6, coinPower = 3 },
				win = {
					justice = 4,
					sanity = 4,
					relationBond = { kind = "all", amount = 3 },
					log = "You carried a bucket of stairwell water through the front office and set it on a director's desk. The tanks were relined by spring.",
				},
				lose = { money = { -25, -10 }, sanity = -4, log = "The front office tested your bucket, declared it perfectly safe, and billed you for the test." },
			},
			{
				label = "Haul clean water up from the spring",
				result = { fortitude = { -3, -1 }, justice = 3, sanity = 1, log = "You hauled clean water up from the Terraces spring for the whole stairwell, two buckets at a time, until your shoulders creaked." },
			},
			{
				label = "Skim off the oil and sell it",
				result = { wage = { 10, 20 }, justice = -2, sanity = -1, log = "You skimmed the oil off the cistern and sold it by the jar. It was, everyone agreed, very good oil." },
			},
		},
	},
	{
		id = "adult2_saltpan_pink_pans",
		title = "The Pink Pans",
		text = "Overnight, after a week of heat, the evaporation pans of Saltpan have turned pink: every one of them, as far as you can see, the color of the inside of a shell. The old rakers say it happens once in twenty years and means nothing but luck. Pink salt sells on the Rim for ten times the white, and the Saltworks foremen haven't noticed yet.",
		once = true,
		tags = { "adult", "saltpan", "strange", "money" },
		when = { district = "saltpan", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Rake a sack before the foremen come",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "A pan of hot pink brine", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 30, 60 }, sanity = 3, log = "You raked a sack of pink salt at dawn and sold it to a Rim confectioner who asked no questions at all." },
				lose = {
					fortitude = { -5, -2 },
					condition = "salt_cough",
					log = "You raked through the heat of the day with no cloth over your mouth, and the salt dust settled in your chest.",
					cause = "Salt lung",
				},
			},
			{
				label = "Fetch the children to see",
				result = { sanity = { 4, 6 }, log = "You fetched every child on your stair to see the pink pans, and they ran along the dykes shrieking until the foremen came." },
			},
			{
				label = "Tell the foremen first",
				result = { wage = { 5, 10 }, prudence = 1, justice = -1, log = "You told the foremen first. They gave you a few {currency} for your sharp eyes and raked the pink salt into company sacks by noon." },
			},
		},
	},
	{
		id = "adult2_glasswall_seeds",
		title = "Seeds in Her Hem",
		text = "Every evening Noor Vell comes down from her work in the Glaziers' greenhouses with her face perfectly blank and the hem of her coat a little heavier than it should be. On the Terraces roofs, where nothing has ever grown, there are suddenly tomatoes. Tonight a Charter guard is following her down the stairs at a careful distance, and she has just noticed.",
		once = true,
		tags = { "adult", "glasswall", "crime", "kindness" },
		when = { district = "glasswall", side = "gutters", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Fall in beside her and chatter",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A Charter guard", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 3,
					sanity = 3,
					addRelation = { kind = "friend", name = "Noor Vell", bond = 50, age = { 30, 45 } },
					log = "You fell in beside {newRelation} and chattered about nothing until the guard got bored. You had tomatoes all summer.",
				},
				lose = { money = { -20, -10 }, sanity = -3, log = "The guard stopped you both and turned out her hem. She lost her place, and you paid a fine for keeping bad company." },
			},
			{
				label = "Tell the guard",
				result = { wage = { 10, 20 }, justice = -4, sanity = -3, log = "You told the guard, and the Glaziers paid you a small reward. The rooftop tomatoes died that summer, one roof at a time." },
			},
			{
				label = "Keep walking",
				result = { sanity = -1, log = "You kept walking and didn't look back. The rooftops still had tomatoes the next week, so she must have managed." },
			},
		},
	},
	{
		id = "adult2_foundry_slag",
		title = "Slag Pickers",
		text = "At dawn the children of the Foundry Row Gutters pick over the Ironmongers' slag heaps for half-burned coal, which will keep a stove going all night if you're careful. This morning a yard guard has caught one of them by the collar, a boy called Fen with a sack bigger than he is, and is marching him toward the gatehouse where fines are written. Fen catches your eye as they pass.",
		cooldown = 6,
		tags = { "adult", "foundry", "crime", "kindness" },
		when = { district = "foundry", side = "gutters", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Pay his fine",
				hint = "20 scrip.",
				requires = { min = { money = 20 } },
				result = { money = -20, justice = 3, sanity = 2, log = "You paid Fen's fine at the gatehouse window and walked him home with his sack, because the coal was his." },
			},
			{
				label = "Say he's your nephew and you sent him",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A company yard guard", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 3, log = "You told the guard Fen was your nephew and you had sent him, which made him your problem. The guard decided he didn't want the problem." },
				lose = { money = { -30, -15 }, sanity = -2, log = "The guard believed you completely and wrote the fine out in your name, doubled for being old enough to know better." },
			},
			{
				label = "Show the children the back heap",
				result = { justice = 1, prudence = 1, log = "You showed the slag children the back heap behind the old furnace, where the guards never walked. They nodded to you on the stairs after that, like a fellow thief." },
			},
			{
				label = "Look away",
				result = { sanity = -2, log = "You looked away. Fen's face stayed with you longer than you expected." },
			},
		},
	},
	{
		id = "adult2_kelpmarket_blight",
		title = "Black Kelp",
		text = "In a single week the kelp on the floating farms has gone black and slick, raft after raft, and it smells like a drain. The Kelp & Net Company blames the Gutters farmhands and has stopped their pay. By the end of the month, for the first time anyone can remember, there are hungry people in Kelpmarket.",
		once = true,
		tags = { "adult", "kelpmarket", "hunger" },
		when = { district = "kelpmarket", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Row out with the burning crews",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The blighted rafts", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 10, 25 }, justice = 3, sanity = 2, log = "You rowed out with the burning crews and fired the black rafts before the blight could spread. The clean farms lived." },
				lose = {
					fortitude = { -7, -3 },
					sanity = -2,
					condition = "burned_hands",
					log = "A burning raft rolled under your boat, and you came home with your hands wrapped in wet sacking.",
					cause = "Burned on the kelp farms",
				},
			},
			{
				label = "Empty your shelves onto the landing",
				result = {
					money = { -30, -15 },
					justice = 4,
					sanity = 3,
					relationBond = { kind = "all", amount = 3 },
					log = "You emptied your shelves onto the landing and told everyone to take what they needed. The common pot never went cold.",
				},
			},
			{
				label = "Buy up dried kelp and sell it dear",
				result = { money = { 30, 70 }, justice = -5, sanity = -2, log = "You bought up every bale of dried kelp you could find and sold it back by the handful. You ate well that winter, and people noticed." },
			},
		},
	},
	{
		id = "adult2_bellhollow_casting",
		title = "The Casting Pit",
		text = "The Bellwrights are casting a new flood-warning bell, the biggest in thirty years, and by old custom anyone in Bellhollow may throw something into the bronze before it is poured: a thimble, a key, a name scratched on a scrap of tin. The casting pit glows like a sunset. People say that if you give the bell something you love, you will hear it ring true for the rest of your life.",
		once = true,
		tags = { "adult", "bellhollow", "faith" },
		when = { district = "bellhollow", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Give the bell your charm",
				hint = "Needs a charm. You'll lose it.",
				requires = { hasGear = { "still_stone", "little_bell", "lantern_token" } },
				result = { loseGear = "charm", prudence = 2, sanity = 6, log = "You threw your charm into the bronze. The first time the new bell rang the hour, you felt it in your teeth, and it was yours." },
			},
			{
				label = "Throw in a button off your coat",
				result = { sanity = 2, log = "You threw in a button off your coat. For years afterward you could have sworn the bell rang a little crooked, like the button." },
			},
			{
				label = "Help the founders pour",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The pouring ladle", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 15, 30 }, justice = 2, sanity = 3, log = "You held a pouring rope with the founders while the bronze ran gold into the mould, and they paid you like one of their own." },
				lose = {
					fortitude = { -6, -3 },
					sanity = -1,
					condition = "burned_hands",
					log = "A spatter of bronze caught your hands as the ladle tipped. The founders packed them in wet sand and sent you home.",
					cause = "Burned at the Bellhollow casting",
				},
			},
		},
	},
	{
		id = "adult2_drownside_barge",
		title = "The Barge School",
		text = "The only school in Drownside is the one Mira Stillman keeps on a half-sunk coal barge: thirty children, one slate each, and a roof of tarred sailcloth. This spring the barge sits a little lower in the water every morning, and Mira, who is seventy, has been bailing it out with a saucepan between lessons.",
		once = true,
		tags = { "adult", "drownside", "kindness" },
		when = { district = "drownside", minAge = 18, maxAge = 59 },
		choices = {
			{
				label = "Patch the hull yourself",
				hint = "Temperance clash, medium.",
				clash = { stat = "temperance", foe = "A rotten barge hull", coins = 2, base = 4, coinPower = 3 },
				win = {
					temperance = 2,
					justice = 3,
					sanity = 4,
					addRelation = { kind = "friend", name = "Mira Stillman", bond = 55, age = { 69, 71 } },
					log = "You patched the barge's seams with tar and salvage tin, and {newRelation} rang the school bell for you as if you'd won a prize.",
				},
				lose = {
					fortitude = { -6, -2 },
					sanity = -2,
					log = "You went under the barge to find the leak and came up with a mouthful of the Mere and no leak.",
					cause = "Drowned under the barge school",
				},
			},
			{
				label = "Pay a Kin crew to tow it ashore",
				hint = "50 scrip.",
				requires = { min = { money = 50 } },
				result = { money = -50, justice = 2, sanity = 2, log = "You paid a Kin crew to tow the barge up onto the mudbank, where it sat crooked and dry and the lessons went on." },
			},
			{
				label = "Teach a lesson while she bails",
				result = { temperance = 1, sanity = 3, log = "You taught thirty children the tide tables while Mira bailed, and six of them got it. You were absurdly proud." },
			},
		},
	},

	-- Family -------------------------------------------------------------------
	{
		id = "adult2_child_mudflats",
		title = "The Tide-Bell",
		text = "Low Water, and half the Gutters is out on the mudflats: children chasing crabs between the drowned chimneys, salvagers with sacks, and somewhere out among them, {child}. The tide-bell on the pier has just begun to ring. Out on the flats, when the Mere turns, the water comes back faster than anyone can run.",
		cooldown = 5,
		tags = { "adult", "family", "child", "low_water", "danger" },
		when = { minAge = 24, maxAge = 59, hasRelation = "child", world = { water = "low" } },
		choices = {
			{
				label = "Run out onto the flats",
				hint = "Justice clash, medium-hard.",
				clash = { stat = "justice", foe = "The turning tide", coins = 2, base = 5, coinPower = 3 },
				win = {
					justice = 2,
					sanity = 4,
					relationBond = { kind = "child", amount = 8 },
					log = "You ran out across the mud shouting {child}'s name, found them, and towed them home a step ahead of the water.",
				},
				lose = {
					fortitude = { -9, -4 },
					sanity = -3,
					relationBond = { kind = "child", amount = 4 },
					log = "You found {child}, but the tide found you both. You came home soaked to the neck, and {child} had to help you up the stairs.",
					cause = "Caught by the tide on the mudflats",
				},
			},
			{
				label = "Swing your lantern from the pier",
				result = { prudence = 2, relationBond = { kind = "child", amount = 3 }, log = "You swung your lantern from the end of the pier until {child} saw it and came back across the mud, laughing, holding up a crab." },
			},
			{
				label = "Trust them to know the tide",
				result = { sanity = -3, relationBond = { kind = "child", amount = 2 }, log = "You made yourself sit on the stairs and trust {child}. They came in an hour later with wet boots and wondered why you looked like that." },
			},
		},
	},
	{
		id = "adult2_child_bruised",
		title = "Standing in Front",
		text = "{child} comes home with a split lip and a torn collar and won't say why. It takes until supper to get it out of them: three bigger children were throwing stones at a Tidetouched boy by the pump, and {child} stood in front of him. Now the bigger children's mother is coming up your stairs, and she is not coming to apologize.",
		once = true,
		tags = { "adult", "family", "child", "tidetouched" },
		when = { minAge = 24, maxAge = 59, hasRelation = "child" },
		choices = {
			{
				label = "Stand in the doorway beside {child}",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "An angry mother on your landing", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 3,
					sanity = 3,
					relationBond = { kind = "child", amount = 10 },
					log = "You stood in the doorway beside {child} and told her exactly what her children had done. She went back down the stairs faster than she came up.",
				},
				lose = {
					money = { -10, -5 },
					sanity = -3,
					relationBond = { kind = "child", amount = 6 },
					log = "It turned into a shouting match the whole landing enjoyed. You paid for her son's torn coat, and {child} squeezed your hand under the table.",
				},
			},
			{
				label = "Make {child} apologize",
				result = { prudence = 1, sanity = -2, relationBond = { kind = "child", amount = -8 }, log = "You made {child} apologize for standing up to bullies. They did it very quietly, and looked at you differently after." },
			},
			{
				label = "Find the Tidetouched boy's family",
				result = { justice = 2, sanity = 2, relationBond = { kind = "child", amount = 5 }, log = "You and {child} went down to the pump to find the boy's family, and came home with a jar of eel stew and an invitation." },
			},
		},
	},
	{
		id = "adult2_mother_wandering",
		title = "{mother} on the Stairs",
		text = "A neighbor knocks at midnight: {mother} is out on the switchback stairs in her nightclothes, looking for a house that was pulled down twenty years ago. She knows your face tonight, but not your name. She is very polite to you, the way she was always polite to strangers.",
		once = true,
		tags = { "adult", "family", "mother" },
		when = { minAge = 30, maxAge = 59, hasRelation = "mother" },
		choices = {
			{
				label = "Move her in with you",
				result = {
					money = { -30, -15 },
					sanity = -2,
					relationBond = { kind = "mother", amount = 12 },
					log = "You moved {mother} into your rooms and learned to sleep with one ear open. Most mornings she knew you.",
				},
			},
			{
				label = "Walk her home the long way, and listen",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Twenty years that aren't there anymore", coins = 2, base = 4, coinPower = 3 },
				win = {
					prudence = 2,
					sanity = 4,
					relationBond = { kind = "mother", amount = 10 },
					log = "You walked {mother} up and down the stairs until dawn while she told you about the old house, and by the last landing she was calling you by name.",
				},
				lose = {
					sanity = -4,
					relationBond = { kind = "mother", amount = 2 },
					log = "You walked with {mother} until dawn, and she grew more frightened at every landing. Two neighbors helped you carry her home.",
				},
			},
			{
				label = "Pay someone on her landing to sit with her",
				hint = "50 scrip.",
				requires = { min = { money = 50 } },
				result = {
					money = -50,
					sanity = 1,
					relationBond = { kind = "mother", amount = 6 },
					log = "You paid a kind net-mender on {mother}'s landing to sit with her in the evenings, and came over whenever the trams allowed.",
				},
			},
			{
				label = "Ask the Choir's quiet house to take her",
				result = {
					prudence = 1,
					sanity = -3,
					relationBond = { kind = "mother", amount = -4 },
					log = "The Choir took {mother} into their quiet house by the water. She seemed content there, and you felt as if you'd given her away.",
				},
			},
		},
	},
	{
		id = "adult2_father_debt",
		title = "{father}'s Page",
		text = "A Brine Kin ledger-hand is sitting on your step, peeling an orange with a hooked knife. Your father, it seems, has been borrowing from the Kin for years to keep his rooms, and has told nobody. \"Family debts are family debts, cousin,\" she says, \"and {father} isn't getting any younger.\"",
		once = true,
		tags = { "adult", "family", "father", "brine" },
		when = { minAge = 25, maxAge = 59, hasRelation = "father" },
		choices = {
			{
				label = "Pay off his page",
				hint = "120 scrip.",
				requires = { min = { money = 120 } },
				result = { money = -120, sanity = 2, relationBond = { kind = "father", amount = 10 }, log = "You paid off {father}'s page in full. He never once mentioned it, but he stood a little straighter on the stairs." },
			},
			{
				label = "Take the debt on and row it off",
				result = {
					fortitude = { -8, -4 },
					sanity = -3,
					relationBond = { kind = "father", amount = 8 },
					setFlags = { "worked_for_brine" },
					log = "You took {father}'s page as your own and rowed Kin cargo through the drowned streets for a season until it was closed.",
					cause = "Worked to the bone on the Brine boats",
				},
			},
			{
				label = "Have it out with {father}",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Your father's pride", coins = 2, base = 4, coinPower = 3 },
				win = {
					money = { -60, -40 },
					prudence = 2,
					sanity = 1,
					relationBond = { kind = "father", amount = 6 },
					log = "You and {father} had it out at his table until he laughed and showed you where he'd hidden the repayments. You split the rest between you.",
				},
				lose = {
					sanity = -3,
					relationBond = { kind = "father", amount = -10 },
					log = "{father} shouted that his debts were his own business and shut the door on you. The ledger-hand left you an orange, which felt like sympathy.",
				},
			},
			{
				label = "Tell her it's his debt, not yours",
				result = { prudence = 1, sanity = -1, relationBond = { kind = "father", amount = -4 }, log = "You told the ledger-hand it was {father}'s debt, not yours. She wrote that down too." },
			},
		},
	},

	-- Health -------------------------------------------------------------------
	{
		id = "adult2_stitcher_frown",
		title = "The Stitcher's Frown",
		text = "You have had a cough since the autumn fogs, but it is the stitcher's face, more than the cough, that frightens you. She listens to your chest for a long time through a brass trumpet, then sits back. \"It's settling in,\" she says. \"Dry rooms, high up, and rest, or it stays.\"",
		weight = 8,
		cooldown = 8,
		tags = { "adult", "sickness" },
		when = { minAge = 25, maxAge = 59, side = "gutters" },
		choices = {
			{
				label = "Pay for a season at the Rim sanatorium",
				hint = "120 scrip.",
				requires = { min = { money = 120 } },
				result = { money = -120, fortitude = { 4, 8 }, sanity = 2, cure = "fog_lung", log = "You spent a season breathing dry air in the Rim sanatorium and came home with your lungs clear." },
			},
			{
				label = "Rent a dry attic for the winter",
				hint = "50 scrip.",
				requires = { min = { money = 50 } },
				result = { money = -50, fortitude = { 1, 3 }, prudence = 1, log = "You rented a dry attic high up the Terraces for the winter, and the cough loosened its grip by spring." },
			},
			{
				label = "Work through it",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The settling cough", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = -1, prudence = 2, log = "You worked through the winter with a scarf over your mouth, and the cough gave up before you did." },
				lose = { sanity = -2, condition = "fog_lung", log = "You worked through it, and it worked through you. The stitcher's word for it was fog lung." },
			},
		},
	},
	{
		id = "adult2_shouting_nights",
		title = "Waking Up Shouting",
		text = "For months now you have been waking in the dark with your own shout still hanging in the room. Your neighbors have stopped knocking on the wall to complain and started leaving things on your step instead: a candle stub, a bowl of broth, a smooth stone from the Choir's shore. The nights are getting longer.",
		cooldown = 3,
		tags = { "adult", "sickness", "mind" },
		when = { minAge = 18, maxAge = 59, hasCondition = "night_terrors" },
		choices = {
			{
				label = "Sit with the Choir at dawn",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The thing in your dreams", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 3, sanity = 4, cure = "night_terrors", log = "You sat with the Choir by the water every dawn for a season, and one morning you realized you had slept straight through." },
				lose = { sanity = -3, log = "You sat with the Choir until the long silences filled up with the same dream." },
			},
			{
				label = "Keep the stone by your pillow",
				hint = "Replaces any charm you carry.",
				result = { gear = "still_stone", sanity = 2, log = "You kept the Choir's smooth stone by your pillow and held it when you woke. Each time, your breathing came back a little sooner." },
			},
			{
				label = "Tell someone close what you see",
				hint = "Needs someone close.",
				requires = { hasRelation = { "friend", "sibling", "mother", "father", "mentor", "child" } },
				result = { sanity = 3, cure = "night_terrors", log = "You told someone close everything you saw at night, in plain daylight. Saying it out loud shrank it to its proper size." },
			},
			{
				label = "Keep a lamp lit all night",
				result = { money = -5, sanity = 1, log = "You kept a lamp burning all night and slept in short, bright pieces. It was better than the dark." },
			},
		},
	},

	-- The strange Mere ---------------------------------------------------------
	{
		id = "adult2_eel_run",
		title = "The Eel Run",
		text = "Once in a decade, on a still autumn night, the silt eels run. They come up out of the deep water in their thousands, pale as candle wax, pouring up the channels and over the low walkways, and the whole Silt turns out with buckets, nets and hooked poles. Eel skin fetches good money on the Rim. Eel teeth fetch a stitcher's bill.",
		weight = 5,
		once = true,
		tags = { "adult", "strange", "silt", "salvage", "danger" },
		when = { minAge = 18, maxAge = 59, side = "gutters" },
		choices = {
			{
				label = "Wade in with a net",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "Ten thousand silt eels", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 25, 60 }, justice = 2, sanity = 3, log = "You netted eels until your arms gave out and sold the skins on the Rim for a small fortune." },
				lose = {
					fortitude = { -9, -4 },
					sanity = -3,
					log = "An eel as long as a tram car came up the net and bit clean through your boot.",
					cause = "Bitten in the eel run",
				},
			},
			{
				label = "Work the run with your hooked pole",
				hint = "Needs a Hooked Pole.",
				requires = { hasGear = "hook_pole" },
				result = { wage = { 35, 70 }, justice = 1, log = "You worked the run from the top of the walkway with your hooked pole and never once got your feet wet." },
			},
			{
				label = "Sell hot broth to the eel-catchers",
				result = { wage = { 8, 18 }, temperance = 1, sanity = 2, log = "You sold hot broth from a cauldron at the top of the stairs all night, and nobody got bitten buying it." },
			},
			{
				label = "Bar the door",
				result = { prudence = 1, sanity = -1, log = "You barred your door and listened to the eels slither past on the walkway until dawn." },
			},
		},
	},
	{
		id = "adult2_lamp_in_mud",
		title = "A Lamp Still Burning",
		text = "Out on the Low Water mud, half buried beside a drowned lamppost, you find a Lantern Guild diving lamp, and it is still lit. Its brass is green with years and its oil is full. Scratched on the base, in a diver's careful capitals, is a name: IVER, DEEP DIVER.",
		once = true,
		tags = { "adult", "strange", "low_water", "salvage", "drowned_city" },
		when = { minAge = 18, maxAge = 59, world = { water = "low" } },
		choices = {
			{
				label = "Carry it to the Guild hall",
				result = {
					money = { 10, 25 },
					justice = 3,
					sanity = 3,
					log = "You carried the lamp to the Guild hall, where Iver's name was painted on the wall of the lost. The Captain hung his lamp beneath it, still burning, and paid you a finder's fee.",
				},
			},
			{
				label = "Keep it",
				result = { gear = "diving_lamp", sanity = -3, log = "You kept the lamp. It never ran short of oil, and on some nights it dimmed by itself, as if someone were passing." },
			},
			{
				label = "Set it on the water at dusk",
				result = { prudence = 2, sanity = 4, log = "You set the lamp on the water at dusk, and it drifted out toward the deep, still burning, until it went down where it wanted to." },
			},
			{
				label = "Follow the way its light is leaning",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "Where the light leans", coins = 2, base = 5, coinPower = 3 },
				win = { money = { 60, 140 }, sanity = 2, log = "You followed the lamp's leaning light across the mud to a drowned chandlery, and found the salvage Iver must have died reaching for." },
				lose = {
					fortitude = { -8, -3 },
					sanity = -5,
					log = "The light led you out across the mud toward the deep water, and you only turned back when the mud was at your waist.",
					cause = "Lost on the Low Water mud",
				},
			},
		},
	},
}
