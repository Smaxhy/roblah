--[[
	STORYLINE: Collateral (Storylines/Core.luau, sl_collateral). The model storyline.
	Your father borrowed against you. Mr. Varga, the lender's clerk, inspects the collateral
	every birthday. The contract comes due at sixteen.

	Ages: 1 the tape · 4 inspection · 7 the bread tin · 9 forty Ahn · 11 sums · 13 the coat
	on the hook · 14 the offer · 16 DUE (the climax) · 18 what you are now · 20 what he
	asked for · 24 the audit (the endings).
	Every beat is `always` at its age, so the story never stalls. Flags carry the choices:
	sl_col_bit, sl_col_read, sl_col_saver, sl_col_pupil, sl_col_collector, sl_col_fixer,
	then one of sl_col_free / sl_col_owned / sl_col_runner / sl_col_signed.
]]

local S = "sl_collateral"

return {
	-- ── age 1: the loan ────────────────────────────────────────────────────
	{
		id = "sl_col_tape",
		story = S,
		title = "The Tape Measure",
		art = "home",
		text = "A man in a clean coat is in your kitchen. He wraps a tailor's tape around your arm, reads it, and writes a number in a small black book. Your father signs under the number.",
		always = true,
		once = true,
		when = { minAge = 1, maxAge = 1 },
		dialogue = {
			{ who = "sl_varga", line = "Healthy. Good lungs. That adds value." },
			{ who = "sl_varga", line = "Sixteen years, then. I'll look in every birthday. To check on the asset." },
		},
		choices = {
			{ label = "Grab the tape", result = { strength = 1, setFlags = { "knows_syndicates" }, log = "You held the tape in both fists. He let you keep hold of it until the ink dried." } },
			{ label = "Cry until he leaves", result = { sanity = -2, health = 1, setFlags = { "knows_syndicates" }, log = "You screamed. He waited, patient as a queue, and left when the signature was dry." } },
			{ label = "Stare at him", result = { mind = 1, setFlags = { "knows_syndicates" }, log = "You watched him the whole time. He wrote one more word in the book. You were too small to read it." } },
		},
	},

	-- ── age 4: inspection day ──────────────────────────────────────────────
	{
		id = "sl_col_inspection",
		story = S,
		title = "Inspection Day",
		art = "home",
		text = "It's your birthday, so Mr. Varga is here. He comes every year. He weighs you on a luggage scale and looks at your teeth with a little mirror.",
		always = true,
		once = true,
		when = { minAge = 4, maxAge = 4 },
		dialogue = {
			{ who = "sl_varga", line = "Open. Wider. Hm. Somebody has been eating sugar." },
			{ who = "sl_varga", line = "Don't frown, child. I brought you a ribbon. Assets get ribbons." },
		},
		choices = {
			{ label = "Say thank you for the ribbon", result = { intelligence = 1, sanity = 1, log = "You said thank you. He looked pleased and wrote \"polite\" in the black book." } },
			{ label = "Bite his finger", result = { strength = 2, sanity = 1, setFlags = { "sl_col_bit" }, log = "You bit him. He looked at the tooth marks, then at you, and wrote \"spirited\". Your father went grey." } },
			{ label = "Hide under the table", result = { mind = 1, sanity = -1, log = "He inspected you under the table instead. It took longer. He didn't seem to mind." } },
		},
	},

	-- ── age 7: the contract ────────────────────────────────────────────────
	{
		id = "sl_col_tin",
		story = S,
		title = "The Bread Tin",
		art = "home",
		text = "There's no bread in the bread tin. There's a folded paper with a red stamp, a number with a lot of zeroes, and your name. You can read your name now.",
		always = true,
		once = true,
		when = { minAge = 7, maxAge = 7 },
		choices = {
			{
				label = "Read all of it",
				clash = { stat = "mind", foe = "Small print", coins = 1, base = 2, coinPower = 2, fixed = true },
				win = { mind = 2, sanity = -3, setFlags = { "sl_col_read" }, goal = "The loan comes due when you turn sixteen. Find a way out.", log = "COLLATERAL: ONE (1) CHILD. DUE AT SIXTEEN. You read it twice. Then you put it back exactly how it was." },
				lose = { sanity = -2, goal = "The paper in the bread tin has your name on it. Find out why.", log = "Too many long words. But your name is on it, and so is the man with the tape." },
			},
			{ label = "Ask your father", result = { sanity = -2, setFlags = { "sl_col_read" }, goal = "The loan comes due when you turn sixteen. Find a way out.", log = "He sat down on the floor. \"It was for the clinic,\" he said. \"When you were born. I'll fix it before sixteen.\"", dialogue = { { who = "{father}", line = "Sixteen is a long way off. I'll have it paid. I promise." } } } },
			{ label = "Put it back and say nothing", result = { intelligence = 1, goal = "The paper in the bread tin has your name on it. Find out why.", log = "You closed the tin. That night you counted the locks on the door, and they didn't help." } },
		},
	},

	-- ── age 9: paying it down ──────────────────────────────────────────────
	{
		id = "sl_col_forty",
		story = S,
		title = "Forty Ahn",
		art = "street",
		text = "You've run errands all year. Forty Ahn in a sock. The debt in the black book grows faster than that every month, and you know it.",
		always = true,
		once = true,
		when = { minAge = 9, maxAge = 9 },
		choices = {
			{ label = "Put the sock in the bread tin", result = { money = -20, intelligence = 2, setFlags = { "sl_col_saver" }, log = "You left it on top of the contract. Your father found it and didn't speak for a whole evening." } },
			{ label = "Keep it. It's yours", result = { money = 20, strength = 1, log = "You kept your Ahn. It was the only thing in the flat nobody else had a number on." } },
			{
				label = "Look inside Varga's black book",
				clash = { stat = "strength", foe = "Mr. Varga's coat pocket", coins = 1, base = 3, coinPower = 2, fixed = true },
				win = { mind = 2, setFlags = { "sl_col_read" }, goal = "The loan comes due when you turn sixteen. Find a way out.", log = "Page forty: your name, your weight every birthday, and one word underlined twice. \"Promising.\"" },
				lose = { sanity = -3, log = "His hand closed on your wrist without him looking round. \"Ask,\" he said. \"I answer questions. I charge for theft.\"" },
			},
		},
	},

	-- ── age 11: Varga explains the City ────────────────────────────────────
	{
		id = "sl_col_sums",
		story = S,
		title = "Sums",
		art = "diner",
		text = "Mr. Varga buys you noodles and teaches you compound interest on a napkin. He says an educated asset is worth more. He seems to enjoy it.",
		always = true,
		once = true,
		when = { minAge = 11, maxAge = 11 },
		dialogue = {
			{ who = "sl_varga", line = "Everyone in the City is owed by someone. That's all the City is." },
			{ who = "sl_varga", line = "A Wing owns the District. A Finger owns my Syndicate. My Syndicate owns me. I hold your paper." },
			{ who = "sl_varga", line = "Find who holds the paper, child, and you know who to be afraid of." },
		},
		choices = {
			{ label = "Learn everything he teaches", result = { mind = 3, intelligence = 1, setFlags = { "sl_col_pupil", "knows_fingers", "knows_wings" }, log = "By spring you could do his sums faster than he could. He raised your valuation and bought you a pencil." } },
			{ label = "Ask who holds his paper", result = { mind = 1, strength = 1, setFlags = { "knows_fingers", "knows_wings" }, log = "He put his chopsticks down. \"The Thumb,\" he said quietly. \"And they don't weigh me on birthdays. Eat.\"" } },
			{ label = "Tip the noodles in his lap", result = { strength = 2, sanity = 2, setFlags = { "sl_col_bit", "knows_fingers" }, log = "He stood up dripping broth and added the cleaning bill to your account. It was worth every Ahn." } },
		},
	},

	-- ── age 13: the Night takes your father ────────────────────────────────
	{
		id = "sl_col_hook",
		story = S,
		title = "The Coat on the Hook",
		art = "night",
		text = "Your father went out at two to ask Varga for one more year. At 3:13 the street went quiet. It's 4:40 now. His other coat is still on the hook.",
		always = true,
		once = true,
		when = { minAge = 13, maxAge = 13 },
		choices = {
			{ label = "Wait at the window till morning", result = { sanity = -8, intelligence = 2, killRelation = "father", setFlags = { "knows_night", "sl_col_alone" }, goal = "He isn't coming back. The debt is yours now. Three years.", log = "Morning came. The street was clean, the way it always is after. He never came up the stairs." } },
			{ label = "Go down and look for him", result = { sanity = -10, health = -3, strength = 2, killRelation = "father", setFlags = { "knows_night", "sl_col_alone" }, goal = "He isn't coming back. The debt is yours now. Three years.", cause = "Went out after the Night", log = "You found his hat by the tram stop, brushed clean, set down neatly. Nothing else. Sweepers leave hats." } },
			{ label = "Go to Varga's door and hammer on it", result = { sanity = -7, strength = 3, killRelation = "father", setFlags = { "knows_night", "sl_col_alone", "sl_col_bit" }, goal = "He isn't coming back. The debt is yours now. Three years.", log = "Varga opened in his dressing gown. \"He left at ten to three,\" he said. \"I told him to run. I'm sorry.\" He sounded it.", dialogue = { { who = "sl_varga", line = "The debt doesn't die with him. I wish it did. Go home, child." } } } },
		},
	},

	-- ── age 14: three ways to deal with it ─────────────────────────────────
	{
		id = "sl_col_offer",
		story = S,
		title = "Three Doors",
		art = "office",
		text = "Two years left. You have a debt with your name on it and nobody to sign for you. There are three doors in this District for somebody like that.",
		always = true,
		once = true,
		when = { minAge = 14, maxAge = 14 },
		choices = {
			{ label = "Varga's door: collect for him", result = { money = 60, strength = 1, sanity = -4, setFlags = { "sl_col_collector" }, goal = "Collect for Varga until sixteen. Every Ahn comes off your number.", log = "Your first collection was a widow on Gable Street. She paid. You gave Varga the money and couldn't eat that night.", dialogue = { { who = "sl_varga", line = "You have the knack. People pay a child. It embarrasses them." } } } },
			{ label = "A Fixer Office: hire help", result = { money = -30, mind = 1, setFlags = { "sl_col_fixer", "knows_fixers" }, goal = "Nadia of Thimble Office will stand with you at sixteen. If you can pay her.", log = "Nadia, Grade 7, read the contract and whistled. \"Thirty Ahn retainer. When it comes due, I'll be there. Bring the rest.\"", dialogue = { { who = "sl_col_fixer", line = "A Fixer is a contract with legs, kid. Right now I'm yours. Don't waste it." } } } },
			{ label = "No door: train, and wait", result = { health = 2, strength = 2, goal = "Two years. Get strong enough that they can't carry you off.", log = "You ran the Hundred Stairs every morning and hit a sack of rice every night. Sixteen was coming either way." } },
		},
	},

	-- ── age 16: DUE ────────────────────────────────────────────────────────
	{
		id = "sl_col_due",
		story = S,
		title = "Due",
		art = "alley",
		text = "Your sixteenth birthday. No ribbon. Varga is at the door with the black book, and behind him are two men from the Syndicate with a sack. The contract says collateral.",
		always = true,
		once = true,
		when = { minAge = 16, maxAge = 16 },
		dialogue = {
			{ who = "sl_varga", line = "I am required to ask. Can you pay?" },
			{ who = "syndicate", line = "Hurry it up, clerk. The van's on a meter." },
		},
		choices = {
			{
				label = "Fight the men with the sack",
				clash = { stat = "strength", foe = "The Syndicate's collectors", enemy = "syndicate", coins = 2, base = 3, coinPower = 2, fight = true },
				win = { strength = 3, sanity = 4, setFlags = { "sl_col_free" }, goal = "You're free, and a Syndicate remembers your face.", log = "They hadn't expected the collateral to hit back. Varga closed the book. \"Defaulted, with prejudice,\" he said, almost smiling." },
				lose = { health = { -10, -5 }, sanity = -6, setFlags = { "sl_col_owned" }, goal = "You belong to the Syndicate until the number is worked off.", cause = "Taken as collateral", log = "The sack went over your head. It smelled of flour. The van's meter was still running." },
			},
			{ label = "Pay it. All of it", hint = "400 Ahn", requires = { min = { money = 400 } }, result = { money = -400, sanity = 6, intelligence = 2, setFlags = { "sl_col_free" }, goal = "Paid in full. Nobody holds your paper.", log = "You counted four hundred Ahn onto his black book. Varga stamped the page, tore it out and gave it to you. His hand shook." } },
			{ label = "\"Nadia. Now.\"", requires = { flags = { "sl_col_fixer" } }, result = { money = -40, sanity = 3, setFlags = { "sl_col_free" }, goal = "Free, and you owe a Fixer a favor. That's a better kind of debt.", log = "Nadia stepped out of the stairwell with her blade already drawn. The men with the sack remembered another appointment.", dialogue = { { who = "sl_col_fixer", line = "This contract was signed for a baby. Hana fines Offices for less. Walk away, gentlemen." } } } },
			{ label = "Sign on as Varga's apprentice", requires = { flags = { "sl_col_collector" } }, result = { money = 80, mind = 2, sanity = -5, setFlags = { "sl_col_signed" }, goal = "You work the black book now. The debt is a salary.", log = "Varga crossed out COLLATERAL and wrote EMPLOYEE. The men with the sack looked disappointed. You felt the pen in your hand for days." } },
			{ label = "Go out the window and run", result = { health = -2, speed = 2, district = "d21", setFlags = { "sl_col_runner" }, goal = "New District, no name. Stay ahead of the black book.", log = "Down the drainpipe, over the wall, and onto the last WARP train out on a ticket you'd kept folded in your shoe for a year. Ten seconds later you were in District 21 with nothing else." } },
		},
	},

	-- ── age 18: what you are now ───────────────────────────────────────────
	{
		id = "sl_col_after_free",
		story = S,
		title = "A Card in the Post",
		art = "home",
		text = "A birthday card with no stamp. Inside, in small neat writing: \"Eighteen. No inspection required. V.\" There's a ribbon in the envelope.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_col_free" } },
		choices = {
			{ label = "Keep the ribbon", result = { sanity = 3, log = "You tied it to the hook where his coat used to hang. It looked right there." } },
			{ label = "Send the card back unopened", result = { strength = 2, log = "You wrote RETURN TO LENDER across it. He sent another the next year anyway." } },
		},
	},
	{
		id = "sl_col_after_owned",
		story = S,
		title = "Asset",
		art = "syndicate",
		text = "Two years of carrying crates, standing at doors and not asking what's in the van. The number in the book goes down eleven Ahn a week. You've done the sum. It ends when you're forty.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_col_owned" } },
		choices = {
			{
				label = "Break the lock and go",
				clash = { stat = "strength", foe = "The night guard", enemy = "syndicate", coins = 2, base = 4, coinPower = 3, fight = true },
				win = { sanity = 6, strength = 2, clearFlags = { "sl_col_owned" }, setFlags = { "sl_col_runner" }, goal = "You're out. Stay ahead of the black book.", log = "You left the guard asleep against the crates and walked out through the loading door into the rain." },
				lose = { health = { -14, -7 }, sanity = -5, cause = "Caught escaping a Syndicate warehouse", log = "They added the guard's clinic bill to your number. Forty-three, now." },
			},
			{ label = "Keep your head down", result = { intelligence = 3, health = 1, sanity = -3, log = "You carried crates. You learned every door in the warehouse and which guard slept. Just in case." } },
			{ label = "Ask Varga for the collector's job", result = { money = 40, sanity = -3, clearFlags = { "sl_col_owned" }, setFlags = { "sl_col_signed" }, goal = "You work the black book now. The debt is a salary.", log = "\"I wondered when you'd ask,\" Varga said, and slid a second black book across the desk. It had your initials on it already." } },
		},
	},
	{
		id = "sl_col_after_runner",
		story = S,
		title = "The Wrong Name",
		art = "market",
		text = "You've been \"Ren from the fish stalls\" for two years. Today a stranger at the market says your real name, quietly, and holds up a small black book.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_col_runner" } },
		choices = {
			{
				label = "Lose him in the crowd",
				clash = { stat = "mind", foe = "A debt tracer", coins = 2, base = 3, coinPower = 2 },
				win = { mind = 2, sanity = 2, log = "Three stalls, a laundry line and a ferry queue later he was looking at the wrong back. You changed stalls anyway." },
				lose = { money = -40, sanity = -4, log = "He caught your sleeve. \"I'm only paid to find you,\" he said. \"Forty Ahn and I found somebody else.\" You paid." },
			},
			{ label = "Walk up and ask who sent him", result = { strength = 2, mind = 1, log = "\"A clerk called Varga,\" the tracer said. \"Not to bring you in. He wanted to know you were eating.\"" } },
		},
	},
	{
		id = "sl_col_after_signed",
		story = S,
		title = "The Tape Measure, Again",
		art = "home",
		text = "Your first loan of your own. A kitchen, a tired man, a baby on the table. Varga hands you the tape. You know what the number in the book is for.",
		always = true,
		once = true,
		when = { minAge = 18, maxAge = 18, flags = { "sl_col_signed" } },
		dialogue = {
			{ who = "sl_varga", line = "Measure the arm. Write it down. It's only a number, the first time." },
		},
		choices = {
			{ label = "Measure the arm", result = { money = 60, mind = 1, sanity = -8, setFlags = { "sl_col_lender" }, log = "The baby grabbed the tape in both fists. You let it hold on until the ink dried." } },
			{ label = "Write the loan without collateral", result = { money = -30, sanity = 5, strength = 2, setFlags = { "sl_col_soft" }, log = "You wrote UNSECURED and signed it yourself. Varga said nothing all the way down the stairs. Then: \"That comes out of your pay.\"" } },
			{ label = "Put the tape down and quit", result = { sanity = 6, strength = 3, clearFlags = { "sl_col_signed" }, setFlags = { "sl_col_free" }, quitCareer = true, goal = "You walked out of the black book. See if it lets you.", log = "You set the tape on the table next to the baby and left. Nobody followed. That worried you more." } },
		},
	},

	-- ── age 20: what he asked for ──────────────────────────────────────────
	{
		id = "sl_col_asked",
		story = S,
		title = "Ten to Three",
		art = "diner",
		text = "Varga is older. He asks you to the noodle counter where he taught you sums, and puts a folded paper on it. It's dated the night your father died.",
		always = true,
		once = true,
		when = { minAge = 20, maxAge = 20 },
		dialogue = {
			{ who = "sl_varga", line = "He didn't come to ask for a year. He came to swap. Himself for you." },
			{ who = "sl_varga", line = "I said no. A grown man is worth less than a child. That was the arithmetic. He left at ten to three." },
			{ who = "sl_varga", line = "I've kept this paper seven years. You should have it. Do what you like with me." },
		},
		choices = {
			{ label = "Take the paper. Leave", result = { sanity = 4, intelligence = 2, setFlags = { "sl_col_knows_swap" }, log = "His signature, your name, the word REFUSED in Varga's neat hand. You kept it in your coat for the rest of your life." } },
			{ label = "\"You could have said yes.\"", result = { strength = 3, sanity = -3, setFlags = { "sl_col_knows_swap", "sl_col_blames" }, log = "\"Yes,\" Varga said. \"I could have.\" He paid for the noodles and sat there a long time after you'd gone." } },
			{ label = "\"You told him to run. That counts.\"", result = { sanity = 5, mind = 1, setFlags = { "sl_col_knows_swap", "sl_col_forgave" }, log = "Varga took his glasses off and cleaned them for a long time. \"It doesn't,\" he said. \"But thank you.\"" } },
		},
	},

	-- ── age 24: the audit (the endings) ────────────────────────────────────
	{
		id = "sl_col_audit",
		story = S,
		title = "The Audit",
		art = "syndicate",
		text = "The Thumb is auditing Varga's Syndicate. Soft loans, a returned contract, a clerk who warns debtors. They want the black books by morning. Varga is on your doorstep, holding all forty of them.",
		always = true,
		once = true,
		when = { minAge = 24, maxAge = 24 },
		dialogue = {
			{ who = "sl_varga", line = "Every name in the District is in these. Yours was page forty." },
			{ who = "sl_varga", line = "I can't carry them and run. Somebody decides what happens to the paper. I'd rather it was you." },
		},
		choices = {
			{ label = "Burn every book", result = { sanity = 8, strength = 4, setFlags = { "sl_col_burned" }, storyEnd = "Paid in Full: you burned the black books and freed the District", log = "Forty books, one oil drum, the whole street warming its hands. By morning nobody in the District owed anybody. The Thumb noticed." } },
			{ label = "Keep the books. Run them properly", result = { money = 300, mind = 3, sanity = -4, setFlags = { "sl_col_lender" }, storyEnd = "The New Lender: you kept the black books and wrote your own terms", log = "You crossed out COLLATERAL on every page and wrote terms a person could pay. It was still a black book. It was yours now." } },
			{ label = "Hand Varga and the books to the Thumb", result = { money = 200, strength = 1, sanity = -8, setFlags = { "sl_col_sold_varga", "thumb_respect" }, storyEnd = "Arithmetic: you gave the clerk to the Thumb", log = "The Capo counted the books and didn't count Varga. \"Correct,\" he said, and paid you. Varga tipped his hat to you as they took him." } },
			{
				label = "Get Varga out of the District",
				clash = { stat = "strength", foe = "A Thumb Soldato at the tram stop", enemy = "thumb_soldato", coins = 3, base = 4, coinPower = 3, fight = true },
				win = { sanity = 7, strength = 3, setFlags = { "sl_col_saved_varga" }, storyEnd = "Unowned: you got the old clerk out and nobody holds your paper", log = "You put him on the night ferry with one book: the blank one. He waved the tape measure from the rail like a streamer." },
				lose = { health = { -18, -9 }, sanity = -6, cause = "Shot by the Thumb at the tram stop", storyEnd = "Refused: you stood between the Thumb and the clerk", log = "The Soldato was polite about it. Varga went with them so they'd stop. He left you page forty." },
			},
		},
	},
}
