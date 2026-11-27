--[[
	Ordinary careers (area A): two or three scenes per rank band for every ladder in
	Careers/Ordinary.luau, so staying small is a story and climbing to the top is too.
		rank 1     career = id, notFlags = { "bs_<id>_r2" }
		ranks 2-3  career = id, minRank = 2, notFlags = { "bs_<id>_r4" }
		ranks 4-5  career = id, minRank = 4
	(the workshop's flags are bs_workshop_r2 / bs_workshop_r4). The scenes that hand over
	the top rank skip anyone already there (bs_ordinary_top).
]]

local function band(id, which)
	if which == 1 then
		return { career = id, notFlags = { "bs_" .. id .. "_r2" } }
	elseif which == 2 then
		return { career = id, minRank = 2, notFlags = { "bs_" .. id .. "_r4" } }
	end
	return { career = id, minRank = 4 }
end

return {
	-- ── Workshop ───────────────────────────────────────────────────────────
	{
		id = "bs_k_ws_first_burn",
		title = "First Burn",
		text = "The forge spits a coal straight onto the back of your hand. It's your first real burn, and the whole Workshop has stopped to see what the new apprentice does about it. The Master Smith keeps hammering, but slower.",
		weight = 12,
		once = true,
		when = band("workshop", 1),
		choices = {
			{
				label = "Keep working",
				hint = "Health check.",
				clash = { stat = "health", foe = "A very hot coal", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 2, sanity = 1, log = "You flicked the coal off and kept filing. The Master Smith grunted and went back to full speed. That night somebody left burn salve on your bench without a word." },
				lose = { condition = "burns", sanity = -1, log = "You yelped, dropped the file and knocked over a bucket of quench oil. Everyone laughed. Then the Master Smith wrapped your hand himself and showed you the scars on his own: \"Everyone's first one is stupid.\"" },
			},
			{
				label = "Ask how not to get burned",
				result = { intelligence = 2, mind = 1, log = "\"You don't,\" said the Master Smith. \"You get burned less.\" He showed you how to stand, where to put your off hand, and how to read the forge's color. You got burned less." },
			},
		},
	},
	{
		id = "bs_k_ws_patent",
		title = "Somebody Else's Mark",
		text = "A customer slides a drawing across the counter: an Atelier Logic pistol, every part measured. \"Copy it,\" he says. \"Same quality, a third of the price, nobody's the wiser.\" Every useful design in the City is somebody's patent, and patents belong to the Head. The Master Smith is out until tomorrow.",
		weight = 12,
		once = true,
		when = band("workshop", 1),
		codex = "bs_lore_workshops",
		choices = {
			{
				label = "Refuse",
				result = { mind = 2, log = "You slid the drawing back. He shrugged and tried the next Workshop down the street. Three months later that Workshop had a letter nailed to its door, and then it didn't have a door." },
			},
			{
				label = "Do it, quietly",
				result = { money = { 60, 120 }, setFlags = { "bs_copied_patent" }, log = "You built it at night with the shutters down. It was a good copy. You were proud of it for exactly one week, and then you started noticing every stranger who looked through the Workshop window." },
			},
			{
				label = "Ask what he wants it for",
				result = { mind = 1, sanity = -1, log = "\"For a friend in the Thumb,\" he said. \"A Capo. Who'd be very grateful.\" You told him to come back when the Master Smith was in. He didn't come back." },
			},
		},
	},
	{
		id = "bs_k_ws_your_mark",
		title = "Your Mark",
		text = "You're good enough now to sign your own work. Every Workshop piece carries a maker's mark, a little picture etched by the guard or the grip, and Fixers choose their gear by it. The Master Smith hands you a blank steel tag. \"Whatever you put on there,\" she says, \"you'll be putting on everything you make until you die.\"",
		weight = 12,
		once = true,
		when = band("workshop", 2),
		choices = {
			{
				label = "A key with a bird on it",
				result = { intelligence = 2, sanity = 2, setFlags = { "bs_has_mark" }, log = "A key with a little bird perched on the bow. It took you a week to get right. The first Fixer who bought a knife with it came back for a second one, and said the mark felt lucky." },
			},
			{
				label = "Three locks in a row",
				result = { intelligence = 1, mind = 1, sanity = 2, setFlags = { "bs_has_mark" }, log = "Three little locks in a row. Every Backstreets customer understood it at once, and every Nest customer asked what it meant, and you liked both." },
			},
			{
				label = "Your initials, plainly",
				result = { intelligence = 2, setFlags = { "bs_has_mark" }, log = "Just your initials, very neat. \"Brave,\" said the Master Smith. \"If it breaks, they'll know whose fault it was.\" It never broke." },
			},
		},
	},
	{
		id = "bs_k_ws_letter",
		title = "A Warning Letter",
		text = "A letter is nailed to the Workshop door this morning, on heavy paper with a seal nobody wants to touch: a formal warning for patent infringement, the first of three. It names the pistol you copied. It lists your profits from it to the last Ahn. It says the second letter will be the last before \"enforcement.\"",
		weight = 14,
		once = true,
		when = { career = "workshop", flags = { "bs_copied_patent" } },
		codex = "bs_lore_workshops",
		choices = {
			{
				label = "Pay back every Ahn, today",
				result = { money = { -160, -80 }, mind = 2, clearFlags = { "bs_copied_patent" }, log = "You paid the whole fine at the patent office before noon, with interest. The clerk stamped it and said, \"Very sensible.\" You never copied anything again, not even a doodle." },
			},
			{
				label = "Confess to the Master Smith",
				result = { money = { -80, -40 }, sanity = -2, clearFlags = { "bs_copied_patent" }, log = "She paid half the fine out of the Workshop's money and took the other half out of your wages for a year. \"Everyone's first one is stupid,\" she said. \"Don't have a second.\"" },
			},
		},
	},
	{
		id = "bs_k_ws_custom",
		title = "A Custom Order",
		text = "A Grade 3 Fixer has come to the Workshop with a problem: her prosthetic arm was built for a weapon she doesn't carry anymore. She wants it rebuilt, balanced for a long blade, in two weeks, for a job she won't describe. She's offering a lot of Ahn. She's offering it to you, specifically, because of your mark.",
		weight = 12,
		once = true,
		when = band("workshop", 2),
		choices = {
			{
				label = "Take the order",
				hint = "Intelligence check. The hardest thing you've built.",
				clash = { stat = "intelligence", foe = "A Grade 3 Fixer's prosthetic arm", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 200, 380 }, intelligence = 2, setFlags = { "bs_famous_work" }, log = "You rebuilt the arm in thirteen days and didn't sleep for four of them. She swung the blade once, nodded, and paid double. Her whole Office ordered from you after that." },
				lose = { money = { 40, 80 }, sanity = -3, log = "You finished it on time and it was good, but not right; the balance was off by a hair. She paid what she'd promised and never came back. You thought about that hair for years." },
			},
			{
				label = "Tell her it needs a better smith",
				result = { mind = 2, sanity = 1, log = "You sent her to the best smith you knew. She came back a month later to say the advice had been right, and ordered a simple knife from you, as a thank-you, which was the best kind of order." },
			},
		},
	},
	{
		id = "bs_k_ws_inherit",
		title = "The Keys to the Workshop",
		text = "The Master Smith is retiring. Her hands shake too much for etching now, and she wants to spend her mornings sleeping in. She puts the Workshop's keys on your bench, and the ledger, and the patent papers in their oilcloth. \"The name stays,\" she says. \"Everything else is yours to ruin.\"",
		weight = 14,
		once = true,
		when = { career = "workshop", minRank = 4, notFlags = { "bs_ordinary_top" } },
		choices = {
			{
				label = "Keep the old name over the door",
				result = { promote = true, sanity = 4, log = "You kept the name over the door and added nothing but your mark, small, in the corner of the window. Old customers kept coming because of the name. New ones came because of the mark." },
			},
			{
				label = "Ask her to stay on, part-time",
				result = { promote = true, intelligence = 2, sanity = 3, log = "She said no three times and yes the fourth. She came in two mornings a week to criticize your etching and drink your tea. The Workshop was never better." },
			},
		},
	},
	{
		id = "bs_k_ws_signature",
		title = "A Blade Everyone Knows",
		text = "A famous Fixer has been carrying one of your blades for a year, and now everyone knows your mark. Two rival Workshops have already tried to buy the design. A third has simply copied it, badly, and is selling it two streets over with a smudged version of your mark on the guard.",
		weight = 12,
		once = true,
		when = band("workshop", 3),
		codex = "bs_lore_workshops",
		choices = {
			{
				label = "File a patent complaint",
				result = { money = { 120, 260 }, mind = 2, log = "You filed the complaint with the patent office. The copier got their first letter, then their second. They paid you everything they'd made, plus a fine, and sent a very polite apology card." },
			},
			{
				label = "Sell the design to the best bidder",
				result = { money = { 400, 800 }, sanity = -2, log = "You sold the design for a fortune. A year later the City was full of your blade with someone else's mark on it, and you couldn't walk down a street without seeing it." },
			},
			{
				label = "Give a free blade to a young Fixer",
				result = { sanity = 5, setFlags = { "bs_gifted_blade" }, log = "You made one more of your best blade and gave it to a Grade 9 Fixer from your street who couldn't afford a decent knife. She carried it for thirty years. People still ask her about the mark." },
			},
		},
	},

	-- ── Backstreets Diner ──────────────────────────────────────────────────
	{
		id = "bs_k_dn_rush",
		title = "The Midnight Rush",
		text = "At midnight the Fixers come off their jobs and every one of them wants noodles at once. Forty bowls, two burners, and the cook is shouting orders at you as if you were three people. The last bowl has to be out by one, because everyone has to be home by three.",
		weight = 12,
		once = true,
		tags = { "backstreets" },
		when = band("diner", 1),
		choices = {
			{
				label = "Keep up",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Forty bowls before one", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 2, wage = { 10, 25 }, log = "You kept up. Forty bowls, not one wrong. At five to one the cook looked at the empty order rail, then at you, and silently handed you a bowl of the good broth." },
				lose = { sanity = -2, intelligence = 1, log = "You dropped two bowls and sent a Grade 6 Fixer a soup with no noodles in it. He ate it anyway, very slowly, staring at you. The cook said you'd get faster. You did." },
			},
			{
				label = "Ask the Fixers about their jobs",
				result = { mind = 2, sanity = 1, log = "You learned more about the City in one rush than in a year at school: which Offices pay late, which Syndicates are fighting, which streets to avoid on Thursdays. Fixers will tell a dishwasher anything." },
			},
		},
	},
	{
		id = "bs_k_dn_closing",
		title = "Closing Time",
		text = "12:50. The last customers have gone and you're counting the till when the bell over the door rings. Three Rats come in out of the rain, dripping and grinning, and one of them flips the sign to CLOSED behind him.",
		weight = 12,
		once = true,
		tags = { "danger", "backstreets" },
		when = band("diner", 1),
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Grab the big ladle",
				clash = { stat = "strength", foe = "Three Rats in the rain", coins = 2, base = 3, coinPower = 2, fight = true },
				win = { strength = 2, sanity = 2, log = "You came over the counter with the big ladle, and the first Rat found out what a soup ladle can do. They left faster than they came. The owner bought a second ladle and hung it behind the till, \"for staff use.\"" },
				lose = { health = { -8, -3 }, money = { -30, -10 }, log = "They got the till and you got a black eye. The owner said the till was insured and you weren't, and to never do that again, and gave you the next night off.", cause = "Beaten by Rats at closing time" },
			},
			{
				label = "Hand over the till and serve them soup",
				result = { money = { -20, -5 }, sanity = 1, mind = 1, log = "You handed over the till and then, because they were soaked, ladled out three bowls of the leftover broth. They ate it in silence. Two weeks later the till money came back under the door in an envelope, mostly." },
			},
		},
	},
	{
		id = "bs_k_dn_regular",
		title = "The Regular",
		text = "Old Mr. Dragan has come in every night for eleven years: 12:40, one bowl, extra scallions, out the door at one o'clock sharp. Tonight it's 12:55 and his stool is empty. The cook keeps glancing at it. So do you.",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { career = "diner" },
		choices = {
			{
				label = "Take a bowl to his flat",
				result = { sanity = 4, log = "You ran a bowl up to his flat with extra scallions. He had a fever and hadn't wanted to bother anyone. You went every night that week. When he came back to his stool, he left a tip for the first time in eleven years." },
			},
			{
				label = "Ask the street if anyone's seen him",
				result = { mind = 2, sanity = 2, log = "Half the street knew where he lived and the other half knew his daughter. By two, the daughter was with him and the whole block knew he was ill. The Backstreets are bad at many things. Not this." },
			},
		},
	},
	{
		id = "bs_k_dn_broth",
		title = "The Broth",
		text = "You're running the kitchen now, and the broth is yours to make: the thing every regular judges the whole diner by. Everyone has a theory. Bones for two days. A spoonful of last year's pot. Something nobody will tell you about.",
		weight = 12,
		once = true,
		when = band("diner", 2),
		choices = {
			{
				label = "Ask Auntie Mun for her secret",
				requires = { flags = { "bs_knows_mun" } },
				result = { intelligence = 3, sanity = 3, setFlags = { "bs_mun_broth" }, log = "Auntie Mun made you swear on the three locks of your door, then told you. It was much simpler than you'd imagined, and much more work. Your broth was never the same again, in the best way." },
			},
			{
				label = "Experiment until it's right",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A broth that won't behave", coins = 2, base = 3, coinPower = 3 },
				win = { intelligence = 2, wage = { 20, 50 }, log = "After a month of terrible broth, you got it. The regulars noticed before you told them. The queue started forming at eleven." },
				lose = { sanity = -2, intelligence = 1, log = "A month of experiments and the regulars were openly bringing their own broth in jars. You went back to the old recipe in disgrace. Next year, maybe." },
			},
		},
	},
	{
		id = "bs_k_dn_fee",
		title = "The Fee Goes Up",
		text = "The Syndicate's collector comes for the diner's protection fee with a new number written in the ledger, a much bigger number. \"Times are tense,\" he says, politely, as if the times were nothing to do with him. The owner looks at you: you're the one who talks to people.",
		weight = 12,
		once = true,
		tags = { "backstreets" },
		when = band("diner", 2),
		codex = "bs_lore_alley_grades",
		choices = {
			{
				label = "Negotiate, with perfect manners",
				hint = "Charisma check. Proper manners help a lot.",
				clash = { stat = "charisma", foe = "A collector with a ledger", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, money = { 20, 40 }, log = "You poured him tea, asked after his Capo's health by the correct title, and pointed out how many of his people ate here for free. The new number got smaller. He left a tip." },
				lose = { money = { -60, -30 }, sanity = -2, log = "You used the wrong title once. The number went up a little more. He was very polite about it." },
			},
			{
				label = "Pay it",
				result = { money = { -50, -20 }, mind = 1, log = "You paid. The owner raised the price of a bowl by one Ahn and put a little sign up explaining why. Nobody complained. Everybody understood." },
			},
		},
	},
	{
		id = "bs_k_dn_critic",
		title = "A Critic From the Nest",
		text = "A food writer from the Nest has come down on a day pass with a notebook, a very clean coat and a reputation for ruining restaurants in a single paragraph. She orders the house noodles. The whole kitchen is staring at you.",
		weight = 10,
		once = true,
		when = band("diner", 2),
		choices = {
			{
				label = "Cook the best bowl of your life",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A Nest critic's palate", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 60, 140 }, sanity = 4, log = "She ate every noodle and wrote for ten minutes without looking up. The paragraph came out the next week. Nest people started coming down on day passes just to queue outside your door." },
				lose = { sanity = -3, log = "She wrote one line: \"Earnest.\" The regulars framed it and hung it by the door, in solidarity, which made it worse and better at the same time." },
			},
			{
				label = "Serve her exactly what the regulars get",
				result = { sanity = 2, mind = 1, log = "You served her the same bowl as the dock workers next to her, no garnish, no fuss. She wrote that it was \"the most honest meal in the City.\" You had no idea whether that was good." },
			},
		},
	},
	{
		id = "bs_k_dn_second_shop",
		title = "A Second Shop",
		text = "The bakery two streets over is closing; the baker is moving to her son's in another District. The shop has a good oven, a flat upstairs and a front window on a busy corner. She'd rather sell it to someone from the street than to a stranger. She'd rather sell it to you.",
		weight = 14,
		once = true,
		when = { career = "diner", minRank = 4, notFlags = { "bs_ordinary_top" } },
		choices = {
			{
				label = "Buy it",
				requires = { min = { money = 250 } },
				result = { money = -250, promote = true, sanity = 4, log = "You bought it. Now there were two of your kitchens on two corners, and then, within a few years, three. People started calling you a restaurateur, which you thought was hilarious." },
			},
			{
				label = "Take on the baker's staff instead",
				result = { promote = true, sanity = 2, money = { -80, -40 }, log = "You couldn't buy the shop, so you hired the baker's two apprentices and opened a bread counter in the corner of your own diner. The bread did better than the noodles. You had two businesses under one roof." },
			},
		},
	},
	{
		id = "bs_k_dn_on_the_house",
		title = "On the House",
		text = "It's been a hard year on your street: a turf war, two bad Nights, rent going up everywhere. Tonight, standing in your own kitchen, you have a thought that will cost you a week's takings. A sign in the window: EVERYTHING ON THE HOUSE TONIGHT. CLOSING AT ONE AS USUAL.",
		weight = 12,
		once = true,
		tags = { "backstreets" },
		when = band("diner", 3),
		choices = {
			{
				label = "Put up the sign",
				result = { money = { -150, -80 }, sanity = 8, chronicle = "bs_act_free_noodles", log = "The queue went round the block. You fed dock workers, Rats, two off-duty Soldati, a Grade 2 Fixer, a family from the Nest who'd got lost, and every grandmother on the street. Everyone was home by three. Nobody forgot it." },
			},
			{
				label = "Feed the neighborhood watch, quietly",
				result = { money = { -40, -20 }, sanity = 4, log = "You fed the neighborhood watch for free, every night, for a year, and didn't put up any sign at all. Grandpa Teo's lamp seemed to hang a little longer outside your window on its rounds." },
			},
		},
	},
	{
		id = "bs_k_dn_parley",
		title = "Neutral Ground",
		text = "Two Syndicates on your street have been sharpening knives at each other for a month, and somebody has suggested a parley, on neutral ground, over food. They want your diner, after closing, tomorrow. Nobody asks whether you want it. They just ask what time.",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = band("diner", 3),
		choices = {
			{
				label = "Host it, and serve the best food of your life",
				hint = "Mental Strength check: seat everyone exactly by rank.",
				clash = { stat = "mind", foe = "Two Syndicates at one table", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 120, 240 }, mind = 2, sanity = 3, log = "You seated everyone in the right order, poured for the senior side first, and kept the bowls coming. They shook hands at 12:40. Both sides paid. The street was quiet for a year." },
				lose = { money = { -80, -20 }, sanity = -4, log = "You seated one Capo a place too low. The parley ended early, nobody touched their food, and your front window was mysteriously broken the next week. Then repaired, the week after, with an apology." },
			},
			{
				label = "Refuse, politely",
				result = { mind = 1, sanity = -1, log = "You said the diner was for eating, not for deciding things. They took the parley to a tea house instead. It went badly. Everyone said it would have gone better at yours." },
			},
		},
	},

	-- ── Academy ────────────────────────────────────────────────────────────
	{
		id = "bs_k_ac_first_class",
		title = "Your First Class",
		text = "Thirty-one children, one chalkboard, one broken window patched with a Wing billboard. This is your class. A boy at the back is already asleep. A girl at the front has her hand up before you've said a word. \"Are you a real teacher,\" she asks, \"or just a big kid?\"",
		weight = 12,
		once = true,
		when = band("academy", 1),
		choices = {
			{
				label = "Win them over",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Thirty-one children", coins = 2, base = 3, coinPower = 2 },
				win = { intelligence = 2, sanity = 3, log = "You taught them the rule first, the way somebody once taught you: three locks, home before three. Then long division, which went less well. By the end of the week the girl at the front called you Teacher without being told." },
				lose = { sanity = -2, intelligence = 1, log = "By lunch the boy at the back had woken up and organized a revolt. You survived the week. In the second week, you learned their names, and things got much better." },
			},
			{
				label = "Answer her honestly",
				result = { mind = 2, sanity = 2, log = "\"A big kid,\" you said, \"who studied.\" She thought about that very seriously, and nodded, and wrote it down. She was the best student you ever had." },
			},
		},
	},
	{
		id = "bs_k_ac_rat_kid",
		title = "The Rat in the Back Row",
		text = "One of your students has started falling asleep in class, with scraped knuckles and new boots he can't have paid for. Everyone knows what it means: he's running with a Rat pack at night. He's twelve. He's good at sums. He looks at you like he's waiting to be thrown out.",
		weight = 12,
		once = true,
		when = band("academy", 1),
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Keep him after class and talk",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A boy who has heard every lecture", coins = 1, base = 3, coinPower = 2 },
				win = { sanity = 4, charisma = 2, log = "You didn't lecture him. You asked him to help you mark the younger kids' sums, for a few Ahn. He came every evening. By spring he'd stopped going out at night. He never said why." },
				lose = { sanity = -2, log = "He listened politely and went out that night anyway. You kept his seat for him. He came back to it in the winter, thinner, quieter, and stayed." },
			},
			{
				label = "Talk to his mother",
				requires = { flags = { "bs_rat_past" } },
				result = { sanity = 3, strength = 1, log = "You told his mother something you'd never told anyone at the academy: that you ran with the Rats too, at his age, and what it had cost you. She listened. The boy stopped going out. He hated you for a month, and then didn't." },
			},
		},
	},
	{
		id = "bs_k_ac_exam_season",
		title = "Exam Season",
		text = "Six of your students are sitting the Wing entrance exam this spring. Their families have saved for years. Every night after classes you keep the lamp lit until one, going over the Wing's history, its numbers, its rules, until the words stop meaning anything to any of you.",
		weight = 12,
		once = true,
		when = band("academy", 2),
		codex = "bs_lore_examinee",
		choices = {
			{
				label = "Tutor them every night",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "The Wing entrance exam", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, intelligence = 2, log = "Two of the six passed. Two Feathers from your little academy above the laundry. Their families brought you so many dumplings you had to give half of them to the watch." },
				lose = { sanity = -3, intelligence = 2, log = "None of the six passed. You sat with each family in turn. In the autumn, five of the six came back to try again, and asked for you by name." },
			},
			{
				label = "Teach them to sleep, too",
				result = { sanity = 3, mind = 1, log = "You sent them home at eleven every night with a rule: sleep is study. One of them passed. All six of them were still smiling at the end, which you decided counted for something." },
			},
		},
	},
	{
		id = "bs_k_ac_fixer_prep",
		title = "Fixer Prep",
		text = "Half the parents on your street want the same thing now: a class that gets their kids through the Hana Association's licensing exam. A Fixer's license is a way out, they say, and Fixers earn. The Head Teacher has asked you to design the class. You know what Fixers' lives are like.",
		weight = 10,
		once = true,
		when = band("academy", 2),
		codex = "fixers_hana",
		choices = {
			{
				label = "Teach it, honestly",
				result = { intelligence = 2, strength = 1, sanity = 2, log = "You taught the exam, and you taught the rest: contracts in writing, never take a job you don't understand, the Night doesn't care about your grade. Three of your students got licenses. All three are still alive, which is the number you're proudest of." },
			},
			{
				label = "Teach bookkeeping for Offices instead",
				result = { intelligence = 3, log = "You taught them how an Office really runs: contracts, taxes, reports for Hana. Two became Fixers. Five became the people Fixers can't run an Office without. Both were good outcomes." },
			},
		},
	},
	{
		id = "bs_k_ac_inspection",
		title = "The Inspector",
		text = "An inspector from the Wing's education office is coming to decide whether your academy keeps its license. He'll want lesson plans, attendance books, fire exits, and a reason why the broken window is patched with one of the Wing's own billboards.",
		weight = 10,
		once = true,
		when = band("academy", 2),
		choices = {
			{
				label = "Prepare everything perfectly",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A Wing inspector", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 3, log = "Every book was in order. He found nothing. At the door he looked at the billboard in the window, and you could have sworn he almost laughed. The license came through for five years." },
				lose = { money = { -60, -20 }, sanity = -2, log = "He found three things, fined you for two, and wrote \"window\" in his report with a question mark. You fixed the window. You kept the billboard on the wall inside, for morale." },
			},
			{
				label = "Let the students show him round",
				result = { sanity = 4, intelligence = 1, log = "The girl from your first class, now fourteen, gave him the tour. He was outmatched in four minutes. The license came through, with a note on the file: \"Students articulate.\"" },
			},
		},
	},
	{
		id = "bs_k_ac_own_academy",
		title = "Your Own Academy",
		text = "There's an empty floor above the laundry on your street: three rooms, good light, a landlord who used to be your student. It would make a small academy of your own, with your own rules and your own name on the door. It would take every Ahn you've saved, and some you haven't.",
		weight = 14,
		once = true,
		when = { career = "academy", minRank = 4, notFlags = { "bs_ordinary_top" } },
		choices = {
			{
				label = "Open it",
				requires = { min = { money = 200 } },
				result = { money = -200, promote = true, sanity = 6, chronicle = "bs_act_academy", log = "You opened it in the spring. Eleven students, one chalkboard, one cat that came with the building. On the first morning you taught them the rule, the way you were taught it." },
			},
			{
				label = "Open it with the parents' help",
				hint = "Intelligence check: you'll need everyone to chip in.",
				clash = { stat = "intelligence", foe = "A whole street's savings", coins = 2, base = 4, coinPower = 3 },
				win = { money = -60, promote = true, sanity = 6, chronicle = "bs_act_academy", log = "Every family on the street gave something: Ahn, a desk, a box of chalk, a lock for the door. The academy opened in the spring, and it belonged to all of them, and you ran it." },
				lose = { sanity = -2, log = "Not enough families could spare anything this year. You kept the empty floor's key anyway. Next year, you told yourself, and meant it." },
			},
		},
	},
	{
		id = "bs_k_ac_old_student",
		title = "An Old Student",
		text = "Someone is waiting outside the academy after classes: a grown adult in a good coat, nervously turning their hat in their hands. It takes you a moment. Twenty years ago they were a kid in your back row who couldn't sit still. \"You probably don't remember me,\" they say. You do.",
		weight = 12,
		once = true,
		when = band("academy", 3),
		choices = {
			{
				label = "Ask what became of them",
				result = { sanity = 6, log = "A Feather, Class 3, with a family and a flat inside the wall. They'd come to say one thing: \"You said I wasn't stupid. Nobody else ever said that.\" Then they enrolled their daughter." },
			},
			{
				label = "Put them to work for an afternoon",
				result = { sanity = 4, intelligence = 1, log = "You handed them a stick of chalk and the youngest class. They were terrible at it, and loved it, and came back every month to teach one lesson about what they do for a living." },
			},
		},
	},
	{
		id = "bs_k_ac_fund",
		title = "The Scholarship Fund",
		text = "Every year, the same thing: a bright kid from a no-fee street who can't pay the fees. Every year you let one or two in for free and pay for it out of your own pocket. This year your bookkeeper has an idea. A fund, with your name on it. Families who've done well could add to it.",
		weight = 10,
		once = true,
		when = band("academy", 3),
		choices = {
			{
				label = "Start the fund with your own savings",
				requires = { min = { money = 150 } },
				result = { money = -150, sanity = 7, setFlags = { "bs_scholarship_fund" }, log = "You started it with a hundred and fifty Ahn of your own. Within five years, the old students had made it ten times bigger. Nobody bright on your street was ever turned away again." },
			},
			{
				label = "Ask the old students to start it",
				result = { sanity = 4, mind = 1, log = "You wrote to every old student you could find. A Feather, two Fixers, a clinic doctor and a Rat who'd done surprisingly well each sent something. It was a small fund. It was enough for three kids a year." },
			},
		},
	},

	-- ── Backstreets Courier ────────────────────────────────────────────────
	{
		id = "bs_k_cr_route",
		title = "Learning the Route",
		text = "Old Wendel's route map is a lie, he tells you cheerfully on your first day: half the streets on it have moved, closed, been bought by Syndicates or been swept away. \"The real route,\" he says, tapping his head, \"is in here. Get it into yours by Friday.\"",
		weight = 12,
		once = true,
		when = band("courier", 1),
		choices = {
			{
				label = "Run it until you know it",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Streets that change their minds", coins = 1, base = 3, coinPower = 2 },
				win = { speed = 2, health = 1, addTrait = "bs_alley_runner", log = "You ran the route eleven times by Friday and drew your own map in the margins of his. Wendel looked at it for a long time and said, \"That stair's new.\" It was. You'd found it." },
				lose = { health = -2, speed = 1, log = "You got lost in the fish market twice and delivered a love letter to a Syndicate office by mistake. It was not a love letter after all. Wendel paid for the confusion and made you run it again." },
			},
			{
				label = "Ask the old couriers at the bathhouse",
				result = { mind = 2, log = "The retired couriers at the bathhouse told you everything for the price of a few cups of tea: the short cuts, the long cuts, the cuts you only take once. Your route was never the same after that." },
			},
		},
	},
	{
		id = "bs_k_cr_parcel",
		title = "Don't Look Inside",
		text = "The parcel is small, heavy, wrapped in black paper and addressed to a fourth-floor flat in a building you don't like. It's warm. It's faintly humming. Every courier knows the rule: never late, never curious. You've been carrying it for ten minutes and it hasn't stopped humming.",
		weight = 12,
		once = true,
		when = band("courier", 1),
		choices = {
			{
				label = "Deliver it, and don't ask",
				result = { wage = { 15, 30 }, mind = 1, log = "You delivered it. A hand took it through a door opened two inches. The humming stopped as soon as the door closed. You were paid double, by someone you never saw. You never asked." },
			},
			{
				label = "Look inside",
				result = { sanity = -5, mind = 2, log = "You peeled back one corner of the black paper. Inside was a small green glow and a smell like a hospital. You wrapped it back up very fast and delivered it with your hands shaking. You never told anyone, and you never looked again." },
			},
			{
				label = "Take it back to Wendel",
				result = { sanity = 1, log = "You took it back. Wendel looked at it, looked at you, and delivered it himself, in record time. \"Smart,\" he said afterward. \"But next time, smart and on time.\"" },
			},
		},
	},
	{
		id = "bs_k_cr_ambush",
		title = "Ambush on Kettle Lane",
		text = "Halfway down Kettle Lane, four Rats step out of a doorway with the casual confidence of people who know couriers carry Ahn. One of them is holding a length of pipe. Your satchel has the week's rent envelopes for half the street in it.",
		weight = 12,
		once = true,
		tags = { "danger", "backstreets" },
		when = band("courier", 1),
		codex = "bs_lore_rats",
		choices = {
			{
				label = "Fight for the satchel",
				clash = { stat = "strength", foe = "Four Rats on Kettle Lane", coins = 2, base = 3, coinPower = 2, fight = true },
				win = { strength = 2, sanity = 2, log = "You swung the satchel, then your fists, then the satchel again. They ran. Every rent envelope arrived on time, and the street started tipping you." },
				lose = { health = { -10, -4 }, money = { -40, -10 }, log = "They got two envelopes and you got a cracked rib. Wendel paid the street back out of his own pocket and yours, and bought you a jacket with a high collar.", cause = "Mugged on a delivery" },
			},
			{
				label = "Outrun them over the roofs",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Four Rats and a long way round", coins = 2, base = 3, coinPower = 2 },
				win = { speed = 1, health = 1, log = "You went up a drainpipe and across three roofs and came down behind the bakery, two streets ahead of them. The rent arrived on time. Wendel wrote ROOFS on your map with a little star." },
				lose = { health = { -4, -2 }, condition = "bs_sprained_ankle", log = "You made it to the roofs and came down on the wrong side of a gutter. The satchel was safe. Your ankle was not." },
			},
		},
	},
	{
		id = "bs_k_cr_deadline",
		title = "A 2:40 Delivery",
		text = "A medicine parcel has to reach a clinic on the far side of the District by three, or a patient there won't see morning. It's 2:40. Every courier in the shed has said no. The clinic's runner is standing in the doorway with tears in her eyes. Twenty minutes there, and you'll have to get home after.",
		weight = 12,
		once = true,
		tags = { "night", "backstreets" },
		when = { career = "courier", minRank = 2, side = "backstreets" },
		choices = {
			{
				label = "Run it",
				hint = "Speed check. Losing means being outside at 3:13.",
				clash = { stat = "speed", foe = "Twenty minutes and the whole District", coins = 2, base = 4, coinPower = 3 },
				win = { speed = 2, sanity = 5, wage = { 40, 80 }, log = "You delivered it at 2:58 and the clinic doctor kept you there behind her locks till dawn. The patient lived. The clinic sent the courier shed a cake every year after, with your name on it in icing." },
				lose = { trigger = "bs_n_out_wave1", log = "You delivered it at 3:06. The patient would live. You wouldn't make it home: the clinic's door had already been locked, and at 3:13 the ground began to hum." },
			},
			{
				label = "Find a rider who knows a faster way",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A shed full of frightened couriers", coins = 2, base = 3, coinPower = 3 },
				win = { mind = 2, sanity = 3, log = "You remembered a kid on your crew who lived next door to the clinic. She ran it from her own front door and was back inside by 2:51. You split the fee with her." },
				lose = { sanity = -4, log = "Nobody knew a faster way. The runner took the parcel herself. You never found out whether she made it, and you never stopped wondering." },
			},
		},
	},
	{
		id = "bs_k_cr_devyat",
		title = "The Devyat' Courier",
		text = "A Devyat' Association courier sits down next to you at the noodle stall: pressed coat, a dimensional Courier Trunk at her feet no bigger than a lunchbox that holds who knows what. She's been watching your route. \"You're never late,\" she says. \"The Ninth Association likes people who are never late.\"",
		weight = 10,
		once = true,
		when = band("courier", 2),
		choices = {
			{
				label = "Ask how to join",
				result = { strength = 2, setFlags = { "bs_devyat_hopeful" }, log = "\"Get a Fixer's license first,\" she said. \"Then come and see us. Bring your legs.\" She told you about the trunks and the AI inside them, Poludnitsa, that pushes a courier faster when a deadline is close. Missing a Devyat' deadline, she said, is not something people do twice." },
			},
			{
				label = "Tell her the route needs you",
				result = { sanity = 3, mind = 1, log = "\"The route needs me,\" you said, and she smiled like she'd expected it. \"Then be the best courier the route ever had,\" she said, and paid for your noodles." },
			},
		},
	},
	{
		id = "bs_k_cr_route_book",
		title = "Wendel's Route Book",
		text = "Old Wendel's knees have finally won. He calls you into the shed and hands you his route book: forty years of moving streets, secret stairs, which doors open after two, which Syndicates tip and which don't. \"The shed's yours to run,\" he says. \"Don't let it get slow.\"",
		weight = 14,
		once = true,
		when = { career = "courier", minRank = 2, notFlags = { "bs_courier_r4" } },
		choices = {
			{
				label = "Take the book",
				result = { promote = true, sanity = 4, log = "You took the book. That night you read the whole thing by lamplight. Half of it was routes. The other half was notes about people: who was lonely, who was ill, whose letters to carry first. You understood the job properly for the first time." },
			},
			{
				label = "Ask him to keep the book and teach the kids",
				result = { promote = true, intelligence = 2, sanity = 3, log = "Wendel kept the book and sat in the shed every morning teaching your new runners. They were terrified of him. They were never, ever late." },
			},
		},
	},
	{
		id = "bs_k_cr_buy_route",
		title = "The Route Is For Sale",
		text = "The company that owns the courier licenses for your part of the District is selling up. The route, the shed, the licenses, the right to the name: all of it, to whoever pays. A Syndicate has already made an offer. So has a Nest company that has never once run a delivery before three.",
		weight = 14,
		once = true,
		when = { career = "courier", minRank = 4, notFlags = { "bs_ordinary_top" } },
		choices = {
			{
				label = "Buy it yourself",
				requires = { min = { money = 300 } },
				result = { money = -300, promote = true, sanity = 6, chronicle = "bs_act_route_owner", log = "You outbid the Syndicate by thirty Ahn and the Nest company by spite. The route was yours: every street, every stair, every door that opens after two. Your first rule as owner: every rider is home before three, delivery or no delivery." },
			},
			{
				label = "Buy it with your riders, together",
				hint = "Intelligence check: everyone puts in what they can.",
				clash = { stat = "intelligence", foe = "A route's price and a crew's savings", coins = 2, base = 4, coinPower = 3 },
				win = { money = -100, promote = true, sanity = 6, chronicle = "bs_act_route_owner", log = "Every rider put in what they had. Together it was enough. The route belonged to the people who ran it, and you ran them, and nothing on it arrived late ever again." },
				lose = { sanity = -3, log = "It wasn't enough. The Nest company won. Within a year they'd lost half the riders and asked you, very politely, to come and run it for them." },
			},
		},
	},
	{
		id = "bs_k_cr_thumb_account",
		title = "A Delivery Account",
		text = "A Capo of the Thumb wants your route to carry his letters: regular, discreet, very well paid. Nobody on your street will think worse of you, exactly. But everyone will know, and the Syndicate across the market will be watching who your riders deliver to.",
		weight = 10,
		once = true,
		when = band("courier", 3),
		codex = "fingers_thumb",
		choices = {
			{
				label = "Take the account, with proper respect",
				result = { money = { 150, 300 }, mind = 1, sanity = -1, log = "You took it, and addressed every letter with every correct title, and your riders learned to bow to the right people. The money paid for new jackets. The other Syndicate's people stopped tipping." },
			},
			{
				label = "Decline: the route carries for everyone",
				hint = "Mental Strength check. A Capo doesn't like being told no.",
				clash = { stat = "mind", foe = "A Capo's pride", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 3, log = "You told him the route carries for everyone, him included, at the same price as the grandmother on the fourth floor. He thought about it, and laughed, and paid the grandmother's price. He became your best customer." },
				lose = { money = { -80, -30 }, sanity = -3, log = "He didn't like it. For a month your riders found their tires slashed and their bags opened. Then it stopped, without explanation, the way these things do." },
			},
		},
	},

	-- ── Back-Alley Clinic ──────────────────────────────────────────────────
	{
		id = "bs_k_cl_night_shift",
		title = "Before Three",
		text = "Between midnight and three the clinic fills up: Fixers off bad jobs, Rats who lost, a child with a fever, a grandmother who just wants someone to talk to. Doctor Seraphine is with a patient behind the curtain. The waiting room is yours, and so is the decision about who goes first.",
		weight = 12,
		once = true,
		when = band("clinic", 1),
		choices = {
			{
				label = "Sort them by who's worst",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A full waiting room", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 2, sanity = 2, log = "You sorted the room like you'd been doing it for years: the child first, then the Fixer with the bad cut, then the rest. Everyone was seen and on their way home by half past two. Doctor Seraphine said, \"Again tomorrow.\"" },
				lose = { sanity = -3, intelligence = 1, log = "You put a Fixer with a quiet, serious injury behind three loud ones. Doctor Seraphine caught it in time. Afterward she showed you how to look for the quiet ones. You never missed one again." },
			},
			{
				label = "Talk with the grandmother",
				result = { sanity = 3, charisma = 1, log = "You sat with the grandmother while everyone else was seen. She didn't need anything. She had just been alone for a long time. She came back every week after that, and brought the waiting room cakes." },
			},
		},
	},
	{
		id = "bs_k_cl_ampule",
		title = "The Price List",
		text = "A father has carried his son in with a badly broken leg. One K Corp ampule on the shelf would fix it overnight. The father reads the price on the shelf, then reads it again, and sits down very slowly on the bench by the door.",
		weight = 12,
		once = true,
		when = band("clinic", 1),
		choices = {
			{
				label = "Set the leg the old way",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A clean break and a scared kid", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 2, sanity = 2, log = "You set it the old way, splint and strap, while the boy squeezed his father's hand. It would heal straight. It would take months. The father thanked you with three jars of pickled radish." },
				lose = { sanity = -2, log = "It took two tries and a lot of shouting. It would heal, mostly straight. Doctor Seraphine checked your work and said nothing, which was kind." },
			},
			{
				label = "Pay for the ampule yourself",
				requires = { min = { money = 100 } },
				result = { money = -100, sanity = 5, log = "You paid for the ampule out of your own wages and told the father the clinic had a discount for boys who were brave. By morning the leg had remembered being whole. You told nobody, and the whole street knew in a week." },
			},
		},
	},
	{
		id = "bs_k_cl_bolus",
		title = "An Unlicensed Bolus",
		text = "A young man wants a Bolus procedure, the H Corp medicine that changes bodies: he wants cat's ears, for his act at the night market. He has a gray-market Bolus in a tin and enough Ahn for the fee. It's not legal. It's not exactly illegal either, in the Backstreets. It's not something the clinic has ever done.",
		weight = 10,
		once = true,
		when = band("clinic", 1),
		choices = {
			{
				label = "Refuse",
				result = { mind = 2, log = "You refused. He went to a cheaper place two Districts over. When he came back his ears were lopsided and one of them only heard music. He asked you, sheepishly, if you could help. You could, a little." },
			},
			{
				label = "Do it carefully",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A gray-market Bolus", coins = 2, base = 3, coinPower = 3 },
				win = { money = { 60, 120 }, intelligence = 1, log = "It went perfectly. He had the best ears in the night market, soft and gray and very expressive. Half his act was now just people asking to see the ears." },
				lose = { money = { 20, 40 }, sanity = -3, log = "It worked, but the ears came out spotted like a leopard's. He loved them. You did not sleep well." },
			},
		},
	},
	{
		id = "bs_k_cl_crossfire",
		title = "The Clinic in the Crossfire",
		text = "Two Syndicates are fighting over the streets around the clinic, and both sides are bringing their wounded to your door. Every other clinic in the District has pulled its shutters down. A Soldato is sitting on one bench and a Rat from the other side is on the next, and they are both looking at you.",
		weight = 14,
		once = true,
		tags = { "danger", "backstreets" },
		when = { career = "clinic", minRank = 2, world = { streets = { "turf_war", "tense" } } },
		choices = {
			{
				label = "Stay open, for everyone",
				hint = "Mental Strength check: nobody fights in your clinic.",
				clash = { stat = "mind", foe = "A turf war in your waiting room", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, mind = 2, wage = { 60, 140 }, chronicle = "bs_act_clinic_open", log = "You stayed open every day of the turf war, and you made one rule: nobody fights in the clinic. Somehow, both sides kept it. When it was over, both Syndicates paid their bills in full, and left you alone for twenty years." },
				lose = { health = { -8, -3 }, sanity = -4, chronicle = "bs_act_clinic_open", log = "You stayed open, and one night the war came inside. Nobody died. The clinic needed a new window and you needed stitches of your own. You opened again the next morning.", cause = "Caught in a turf war at the clinic" },
			},
			{
				label = "Close the shutters like everyone else",
				result = { sanity = -4, mind = 1, log = "You pulled the shutters down. Through them, all week, you heard people knocking. When it was over, nobody blamed you. You blamed you." },
			},
		},
	},
	{
		id = "bs_k_cl_inspection",
		title = "License Day",
		text = "The clinic's license is up for renewal, and the inspector who's come is famous for closing back-alley clinics over a single missing form. He's going through your medicine cabinet, very precisely, writing down every label.",
		weight = 10,
		once = true,
		when = band("clinic", 2),
		choices = {
			{
				label = "Walk him through every record",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A famously strict inspector", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "Every record was there, every ampule counted, every form signed. He found nothing and seemed almost disappointed. The license came through. Doctor Seraphine framed it and said you were the most boring person she'd ever met, as a compliment." },
				lose = { money = { -80, -30 }, sanity = -2, log = "He found two missing signatures and a cabinet label in the wrong color. Fine, warning, a follow-up visit. You stayed up three nights fixing everything." },
			},
			{
				label = "Ask him why he became an inspector",
				result = { sanity = 2, mind = 1, log = "He stopped writing. His sister, he said, had gone to a back-alley clinic with no records, and nobody could tell him what they'd done. He renewed your license that afternoon and stayed for tea." },
			},
		},
	},
	{
		id = "bs_k_cl_teaching",
		title = "Steady Hands",
		text = "Doctor Seraphine has decided you're ready to learn the things she's never let you do: the stitches that have to hold, the injuries that look small and aren't, the patients you have to send to a Nest hospital no matter what it costs them. \"Tonight,\" she says, rolling up her sleeves, \"you do it, and I watch.\"",
		weight = 12,
		once = true,
		when = band("clinic", 2),
		choices = {
			{
				label = "Do it",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Your first real stitches", coins = 2, base = 3, coinPower = 3 },
				win = { intelligence = 3, sanity = 2, log = "Your hands didn't shake until afterward. Doctor Seraphine checked every stitch and said, \"Those will hold.\" It was the best thing anyone had ever said to you." },
				lose = { intelligence = 2, sanity = -2, log = "She took over halfway through, gently, without a word. Afterward she made you practice on a leather glove every night for a month. The second time, your stitches held." },
			},
			{
				label = "Ask about the ones she couldn't save",
				result = { mind = 3, sanity = -2, log = "She told you about some of them, sitting on the clinic step at one in the morning. \"You'll have your own,\" she said. \"Write them down. Remember their names. Then open the next morning anyway.\"" },
			},
		},
	},
	{
		id = "bs_k_cl_inherit",
		title = "The Clinic Is Yours",
		text = "Doctor Seraphine has hung up her coat. Thirty-five years of Nights and turf wars and fevers, and she wants to sleep past noon for the rest of her life. She leaves you the clinic, the patient books, the ampule cabinet's key, and one instruction: \"Be open when nobody else is.\"",
		weight = 14,
		once = true,
		when = { career = "clinic", minRank = 4, notFlags = { "bs_ordinary_top" } },
		choices = {
			{
				label = "Keep her name on the sign",
				result = { promote = true, sanity = 5, log = "You kept her name on the sign and put yours under it, smaller. She came by once a week to criticize your stitching and was secretly delighted every time." },
			},
			{
				label = "Hire two new aides on your first day",
				result = { promote = true, intelligence = 2, sanity = 3, money = { -60, -30 }, log = "You hired two aides from the street on your first day as owner: a former Rat with steady hands and a girl who'd been your patient as a child. The clinic was open longer than ever." },
			},
		},
	},
	{
		id = "bs_k_cl_free_day",
		title = "Free Clinic Day",
		text = "Once a year, you've decided, the clinic will be free: every patient, every bandage, every ampule you can afford to give away. The queue starts at dawn and goes round three blocks. Somewhere in it are the Rat who robbed your aide last winter and the Capo whose Soldati broke your window.",
		weight = 12,
		once = true,
		when = band("clinic", 3),
		choices = {
			{
				label = "Treat everyone, in order",
				result = { money = { -150, -80 }, sanity = 8, log = "You treated everyone in the order they'd queued. The Rat said thank you. The Capo waited in line like everyone else, and when his turn came he paid for the whole day, and you let him." },
			},
			{
				label = "Treat the children first",
				result = { money = { -100, -50 }, sanity = 6, log = "Children first, all day. The grown-ups in the queue didn't complain once. By the end, you'd seen two hundred children, and the street had the healthiest winter anyone could remember." },
			},
		},
	},
	{
		id = "bs_k_cl_shadow",
		title = "The Patient's Shadow",
		text = "Your patient is a quiet woman whose family died in a fire last spring. She came in for a cough. While you're listening to her chest, you notice her shadow on the wall moving half a second after she does. She notices you noticing. People call it the start of a Distortion: feelings grown too big for a person to hold.",
		weight = 10,
		once = true,
		when = { career = "clinic", minRank = 2, world = { era = { "library", "limbus" } } },
		codex = "terms_distortion",
		choices = {
			{
				label = "Talk with her, as long as it takes",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A grief that's starting to change shape", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 4, charisma = 2, log = "You closed the clinic for the afternoon and talked with her until the streetlights came on: her family, the fire, what came after. When she left, her shadow left with her, on time. She came back every week. It stayed on time." },
				lose = { sanity = -5, log = "She listened, and thanked you, and her shadow stayed half a second behind. You gave her the address of a Fixer office that handles these things gently. You hope they were gentle." },
			},
			{
				label = "Give her a Moonlight Stone to hold",
				requires = { hasGear = "moonlight_stone" },
				result = { loseGear = "moonlight_stone", sanity = 3, log = "You pressed your own Moonlight Stone into her hand. The noise in her head went quiet enough for her to cry, finally. Her shadow caught up with her before she left." },
			},
		},
	},

	-- ── Nest Records Office ────────────────────────────────────────────────
	{
		id = "bs_k_nc_two_trays",
		title = "Two Trays",
		text = "There are two trays on every desk at the Records Office: one for residence applications from inside the Nest, one for applications from the Backstreets. The first tray is processed every morning. The second tray is processed \"when there's time.\" Your tray from the Backstreets is three months deep.",
		weight = 12,
		once = true,
		when = band("nest_clerk", 1),
		codex = "bs_lore_nests",
		choices = {
			{
				label = "Ask your supervisor why",
				result = { mind = 2, sanity = -1, log = "\"Policy,\" said your supervisor, which in the Records Office is a complete sentence. He moved you to a desk with no second tray. You found out later that it was meant as a kindness." },
			},
			{
				label = "Work through the second tray at lunch",
				result = { intelligence = 2, sanity = 3, setFlags = { "bs_clerk_conscience" }, log = "You worked through the Backstreets tray every lunch hour for a year. Nobody thanked you. Eleven families got their papers a season early. They never knew your name." },
			},
		},
	},
	{
		id = "bs_k_nc_the_queue",
		title = "The Queue",
		text = "A woman from the Backstreets has been in the queue since four in the morning, the earliest anyone can safely leave home. Her son's checkpoint pass has expired and his job is inside the wall. Your window closes in five minutes. She has every form but one, and that one has to come from a different office.",
		weight = 12,
		once = true,
		when = band("nest_clerk", 1),
		choices = {
			{
				label = "Fetch the form from the other office yourself",
				hint = "Strength check: four floors in five minutes.",
				clash = { stat = "strength", foe = "Four floors and a closing window", coins = 1, base = 3, coinPower = 2 },
				win = { sanity = 4, strength = 1, log = "You ran four floors, charmed a clerk on her lunch break, and stamped the pass at the stroke of closing. The woman held it flat in both hands like an offering and didn't say anything at all." },
				lose = { sanity = -2, log = "The other office had closed early. You wrote her a note to come straight to your window tomorrow and skip the queue. It's the only rule you broke that year." },
			},
			{
				label = "Tell her to come back with the form",
				result = { mind = 1, sanity = -3, log = "You told her to come back with the form. She nodded, folded her papers very carefully, and walked out into the Backstreets. You never saw her again in your queue." },
			},
		},
	},
	{
		id = "bs_k_nc_veteran",
		title = "The Veteran's File",
		text = "A Nest residence application lands on your desk from an old man with a perfect record: no debts, no fines, forty years of taxes paid on time. And one line, in the old army register: Smoke War, front-line service. The rule is clear. Any record of fighting in the war, on any side, means refusal.",
		weight = 12,
		once = true,
		when = band("nest_clerk", 2),
		codex = "bs_lore_smoke_war",
		choices = {
			{
				label = "Refuse it, as the rule says",
				result = { mind = 1, sanity = -4, log = "You stamped it refused. The old man came to your window to collect the letter himself. He read it, nodded, and said, \"Thank you for reading it properly.\" That was worse than anything else he could have said." },
			},
			{
				label = "Send it up with a note asking for an exception",
				hint = "Mental Strength check. Nobody asks for exceptions.",
				clash = { stat = "mind", foe = "A rule older than the Records Office", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 6, mind = 2, setFlags = { "bs_clerk_conscience" }, log = "Your note went up four floors and came back down with a single word in red: GRANTED. Nobody could remember the last time it had happened. The old man moved in at eighty-one." },
				lose = { sanity = -2, money = { -40, -10 }, log = "Your note came back with a fine and a warning about \"sentiment in processing.\" The application was refused. You kept a copy of it in your drawer for the rest of your career." },
			},
		},
	},
	{
		id = "bs_k_nc_envelope",
		title = "An Envelope on the Desk",
		text = "There's an envelope on your desk this morning, under a permit application from a Backstreets shopkeeper who wants to open a second shop just inside the wall. The envelope is thick. It has no name on it. The application has a small mistake that would normally send it back for six months.",
		weight = 10,
		once = true,
		when = band("nest_clerk", 2),
		choices = {
			{
				label = "Send the envelope back",
				result = { mind = 2, sanity = 1, log = "You sent the envelope back with a note explaining the mistake and how to fix it in a week instead of six months. The shopkeeper came in, fixed it, and got her permit. She sent you a cake instead, which you could accept." },
			},
			{
				label = "Keep it, and fix the mistake yourself",
				result = { money = { 100, 200 }, sanity = -3, setFlags = { "bs_took_envelope" }, log = "You kept it. You fixed the mistake. Nobody ever found out. You thought about that envelope every time a drone floated past your window, for years." },
			},
		},
	},
	{
		id = "bs_k_nc_registrar",
		title = "The Registrar's Signature",
		text = "As Registrar, your signature is the last one on every residence decision in the District's Nest. Today you're handed the year's quota: how many Backstreets families may be admitted. The number is very small. The tray of applications is very deep.",
		weight = 12,
		once = true,
		when = band("nest_clerk", 3),
		codex = "bs_lore_nests",
		choices = {
			{
				label = "Argue for a bigger number",
				hint = "Charisma check, before the Nest's governing board.",
				clash = { stat = "charisma", foe = "The Nest's governing board", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 6, charisma = 2, setFlags = { "bs_clerk_conscience" }, log = "You argued for an hour with figures, records and the names of twenty families. The board doubled the number, grudgingly, \"as a trial.\" The trial was never ended." },
				lose = { sanity = -3, log = "The board listened politely and kept the number. You chose the families yourself, every one, and signed each letter by hand, the refusals too." },
			},
			{
				label = "Choose the families by who has waited longest",
				result = { sanity = 2, mind = 1, log = "You took the oldest applications first: people who had been waiting since before you were born. One of them was a woman you'd turned away at your window years ago. She didn't recognize you. You recognized her." },
			},
		},
	},
	{
		id = "bs_k_nc_vanished",
		title = "A File That Isn't There",
		text = "A whole family's records vanished from the Records Office overnight: residence papers, tax files, birth certificates, everything. Your colleagues look at the empty drawer and say they don't remember the family. You do. You processed their papers yourself. People say this is what happens when the Head acts on something.",
		weight = 10,
		once = true,
		when = { career = "nest_clerk", minRank = 3 },
		choices = {
			{
				label = "Say nothing, ever",
				result = { mind = 2, sanity = -4, log = "You said nothing. You stopped processing anything to do with that street for a while, out of something that wasn't quite fear. Years later you still knew their names. You never wrote them down." },
			},
			{
				label = "Keep the one copy you have, hidden",
				result = { sanity = -2, setFlags = { "bs_kept_erased_file" }, log = "You had a carbon copy of one form in your own desk. You took it home and hid it behind a loose brick. Nothing happened. You never looked at it again, and you never threw it away." },
			},
		},
	},
	{
		id = "bs_k_nc_chief",
		title = "Chief Registrar",
		text = "The Chief Registrar is retiring, and the board wants a successor who has never caused trouble. Your file says you've caused a little. Your file also says your section processes more applications, with fewer mistakes, than any other in the building. They've called you upstairs.",
		weight = 14,
		once = true,
		when = { career = "nest_clerk", minRank = 4, notFlags = { "bs_ordinary_top" } },
		choices = {
			{
				label = "Promise them efficiency",
				result = { promote = true, mind = 2, sanity = 1, log = "You promised them efficiency, and gave it to them. You also, very quietly, abolished the second tray. It took the board two years to notice. By then, nobody could remember why there had been one." },
			},
			{
				label = "Tell them about the second tray",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The Nest's governing board", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, sanity = 5, log = "You told them exactly what the second tray was costing the Nest: workers, taxes, goodwill. They made you Chief Registrar to fix it. You did." },
				lose = { sanity = -3, log = "They thanked you for your candor and gave the job to someone who had never caused trouble. You kept your desk, and your second tray, and your opinions." },
			},
		},
	},

	-- ── Landlord ───────────────────────────────────────────────────────────
	{
		id = "bs_k_ll_lock_rounds",
		title = "Lock Rounds",
		text = "Every night at two you walk the building: every floor, every door, every lock. Tonight, on the fifth floor, Mrs. Halloran's third lock is broken and she's been too embarrassed to say. She's eighty-four. It's 2:05.",
		weight = 12,
		once = true,
		tags = { "backstreets" },
		when = band("landlord", 1),
		choices = {
			{
				label = "Fix it before three",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A forty-year-old lock", coins = 1, base = 3, coinPower = 2 },
				win = { intelligence = 2, sanity = 3, log = "You had it apart and back together by 2:40, with a new spring from your own toolbox. Mrs. Halloran made you tea at 2:45, which you drank very fast, and was home safe, and so were you." },
				lose = { sanity = -1, log = "You couldn't fix it in time, so you nailed a bar across the inside of her door and promised a locksmith in the morning. She sat up all night anyway. The locksmith came at seven." },
			},
			{
				label = "Sit with her through the Night",
				result = { sanity = 2, mind = 1, log = "You sat in her kitchen through the whole Night, door shut, bar across it, talking about her old shop, the price of fish, the Night she was born. The locksmith came at seven. She told everyone in the building." },
			},
		},
	},
	{
		id = "bs_k_ll_late_rent",
		title = "Late Rent",
		text = "The family in 3B is two months behind. The father lost his job at a Workshop that closed; the mother is doing double shifts at a laundry. The owner of the building wants them out by the end of the week and wants you to tell them.",
		weight = 12,
		once = true,
		when = band("landlord", 1),
		choices = {
			{
				label = "Talk the owner into a payment plan",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A landlord who has heard it all", coins = 1, base = 3, coinPower = 2 },
				win = { charisma = 2, sanity = 4, log = "You got them six months to catch up, a little at a time. They caught up in five. The father found work at another Workshop and fixed every squeaky hinge in the building for free, forever." },
				lose = { sanity = -4, log = "The owner wouldn't budge. You helped them move their things to a cousin's place before Friday's Night, and carried the heaviest boxes yourself." },
			},
			{
				label = "Pay a month yourself",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 3, log = "You paid a month yourself and told the owner they'd scraped it together. The family never knew. You found a box of the mother's laundry soap on your doorstep every month for a year anyway." },
			},
		},
	},
	{
		id = "bs_k_ll_extension",
		title = "Just One More Floor",
		text = "The building's flat roof is wasted space, a builder tells you. One more floor, cheap and quick, and you could rent four more rooms by spring. A permit from the Nest's office would cost a fortune and take a year. \"Nobody bothers with permits,\" he says. \"Well. Nobody bothers until the Sweepers do.\"",
		weight = 12,
		once = true,
		when = band("landlord", 2),
		codex = "bs_lore_night_rules",
		choices = {
			{
				label = "Pay for the permit and wait",
				requires = { min = { money = 150 } },
				result = { money = -150, mind = 2, wage = { 60, 120 }, log = "You paid, and waited a year, and built it properly. It's still there. Every morning after the Night, you looked up and checked, just in case." },
			},
			{
				label = "Build it without a permit",
				result = { money = { 80, 160 }, setFlags = { "bs_illegal_floor" }, log = "You built it in eight weeks. You rented the new rooms as storage, never as homes, because you weren't a fool. One morning in autumn the new floor was simply gone, swept clean down to the old roof, and so was everything stored in it. You'd known. You'd done it anyway." },
			},
			{
				label = "Leave the roof as a roof",
				result = { sanity = 2, log = "You left the roof alone, and put chairs and a few pots of herbs up there. On summer evenings the tenants sat out until one, watching the WARP trains. It was the best decision you ever made as a landlord." },
			},
		},
	},
	{
		id = "bs_k_ll_fixer_tenant",
		title = "A Fixer Upstairs",
		text = "A Grade 5 Fixer wants to rent the big room on the top floor: pays a year in advance, quiet, polite, carries a long case up and down the stairs at odd hours. The other tenants are nervous. Fixers bring trouble. Fixers also mean nobody tries anything on a building with a Fixer in it.",
		weight = 10,
		once = true,
		when = band("landlord", 2),
		choices = {
			{
				label = "Rent it to her",
				result = { money = { 100, 200 }, sanity = 2, log = "You rented it to her. Twice that year, trouble came looking for her; twice it left again, faster. The Rats stopped trying the building's doors entirely. The tenants grumbled and slept better." },
			},
			{
				label = "Rent it to a family instead",
				result = { sanity = 3, mind = 1, log = "You rented it to a family with four kids who'd been waiting a year for something bigger. The building got louder and happier. The Fixer found a room two streets over and waved at you on the stairs sometimes." },
			},
		},
	},
	{
		id = "bs_k_ll_block",
		title = "The Block",
		text = "The two buildings either side of yours are for sale: their owner is old and tired and wants to move somewhere without stairs. Buy them and you'd own the whole block, every door, every lock, every rent book. A Syndicate has made an offer too. So has a company from the Nest.",
		weight = 14,
		once = true,
		when = { career = "landlord", minRank = 3, notFlags = { "bs_landlord_r4" } },
		choices = {
			{
				label = "Buy them",
				requires = { min = { money = 200 } },
				result = { money = -200, promote = true, sanity = 3, log = "You outbid them both. Now you owned the block, and on your first night as owner you walked every floor of all three buildings, checking every lock, until a quarter to three." },
			},
			{
				label = "Buy one, and put the tenants on the board of the other",
				result = { money = { -100, -60 }, promote = true, mind = 2, log = "You bought one building and helped the other's tenants buy theirs together, with you as manager. The Syndicate was furious. The Nest company didn't understand what had happened." },
			},
		},
	},
	{
		id = "bs_k_ll_shelter_floor",
		title = "A Room for the Night",
		terms = { "The Night" },
		text = "Every few weeks someone knocks on your building's front door after three, caught outside, begging. The rules say you can open it: it's your door. Most landlords never do. You have an empty ground-floor room. You could keep it ready, with blankets, and a rule: the front door opens until 3:12.",
		weight = 12,
		once = true,
		tags = { "backstreets" },
		when = band("landlord", 3),
		choices = {
			{
				label = "Make it a night shelter",
				result = { money = { -60, -30 }, sanity = 6, addTrait = "bs_door_keeper", setFlags = { "bs_kept_door" }, chronicle = "bs_act_shelter", log = "You turned the ground floor into a night shelter and kept the front door open until 3:12, every night, yourself. Strangers slept on your floor in rows. Every one of them saw the morning." },
			},
			{
				label = "Give the room to a family instead",
				result = { money = { 30, 60 }, sanity = 1, log = "You rented it to a family. Sometimes, after three, you still heard knocking at the front door. You told yourself you couldn't save everyone, which was true, and didn't help." },
			},
		},
	},
	{
		id = "bs_k_ll_street",
		title = "Street Owner",
		text = "The last two buildings on your street are coming up for sale, and with them, if you buy, the whole street will be yours: every door from the bakery to the bathhouse. Owning a street means something in the Backstreets. It means the Syndicates come to you first, and so do the neighbors.",
		weight = 14,
		once = true,
		when = { career = "landlord", minRank = 4, notFlags = { "bs_ordinary_top" } },
		choices = {
			{
				label = "Buy the street",
				requires = { min = { money = 300 } },
				result = { money = -300, promote = true, sanity = 5, log = "You bought the street. On your first morning as its owner you had every lock checked, every stair light fixed, and a lamp put up at each end that stays lit until four. People started calling it by your family name." },
			},
			{
				label = "Buy it with the neighbors' savings, as a cooperative",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A whole street's worth of opinions", coins = 2, base = 4, coinPower = 3 },
				win = { money = -100, promote = true, sanity = 6, log = "It took eleven meetings and one shouting match about the bins. In the end the street belonged to everybody on it, and they made you its owner on paper, because somebody had to sign." },
				lose = { sanity = -2, log = "The meetings collapsed over the question of whose stairwell got fixed first. A company from the Nest bought the buildings. You managed them for the company, and kept every lock in order anyway." },
			},
		},
	},
}
