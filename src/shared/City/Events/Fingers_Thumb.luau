--[[
	The Thumb: propriety, ranks (Soldato Primo to Sottocapo), contributions, debts, respect,
	and bullets as a threat. Canon: docs/CANON.md 3.1 and 8.6; the Introductory Manual, meals
	by station, ammunition duty, the Summit and the Padrino are from Limbus game text.
	Discipline stays offscreen ("corrected"), per section 12.
	Flags: fn_owes_thumb (shared hook: you owe the Thumb), fn_thumb_disrespected (a Capo has
	reason to remember you), thumb_respect (existing: the Thumb thinks well of you).
]]

local THUMB_DEBT = { setFlags = { "fn_owes_thumb" }, condition = "fn_thumb_interest", addTrait = "in_debt_to_the_thumb" }

local function debt(log: string)
	local r = table.clone(THUMB_DEBT)
	r.log = log
	return r
end

return {
	-- ── members ──
	{
		id = "fn_thumb_manual",
		title = "Page 1,271",
		text = "Your first week as a Soldato Primo, a Soldato Quarto drops a manual on your bunk. The Thumb Introductory Manual runs past a thousand pages: how to bow to each rank, where to stand, when you may eat. Primi eat last. Tonight you're assigned page 1,271: \"How to Encourage Your Juniors.\" You have no juniors.",
		weight = 26,
		once = true,
		tags = { "fingers" },
		when = { career = "thumb", notFlags = { "fn_thumb_capo" } },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Memorize it, word for word",
				clash = { stat = "intelligence", foe = "Page 1,271", coins = 2, base = 4, coinPower = 3 },
				win = { addTrait = "fn_knows_their_place", log = "You recited page 1,271 at inspection without a single error. The Soldato Quarto nodded, which is the Thumb's version of a parade." },
				lose = { intelligence = 1, sanity = -2, log = "You mixed up the bow for a Capo I with the bow for a Capo II. You ate even later than usual that week." },
			},
			{
				label = "Eat at your station without complaint",
				result = { health = -2, mind = 2, sanity = -1, log = "Primi eat when everyone else has finished. By the third day you'd stopped feeling hungry before your hour. The manual calls that growth." },
			},
			{
				label = "Ask a senior why the rules matter",
				clash = { stat = "mind", foe = "A Soldato Quarto's patience", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "\"Rules are what keep a Finger from becoming a mob,\" she said. \"Mobs get swept up. We don't.\" It was the most anyone had said to you all week." },
				lose = { health = { -5, -2 }, log = "Asking why is not on page 1,271. You learned that the uncomfortable way.", cause = "Corrected by the Thumb" },
			},
		},
	},
	{
		id = "fn_thumb_ammo_duty",
		title = "Ammunition Duty",
		text = "You've been promoted from cleaning propellant rounds to carrying them: ammunition delivery for the Capi, in the field. Right now the Capi are in a running fight three streets over with a Syndicate that forgot its manners. Your crate is heavy. Every round in it costs more than your boots.",
		weight = 24,
		cooldown = 4,
		tags = { "fingers" },
		when = { career = "thumb", notFlags = { "fn_thumb_capo" } },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Run the crate through the crossfire",
				clash = { stat = "strength", foe = "A Syndicate's stray gunfire", coins = 2, base = 4, coinPower = 3, fight = true, status = "burn" },
				win = { strength = 2, paycheck = 0.3, setFlags = { "fn_thumb_ammo_runner" }, log = "You slid the crate to the Capo's feet as his last magazine ran dry. He didn't look at you. That's how you knew it was perfect." },
				lose = { health = { -10, -4 }, condition = "deep_cut", log = "You delivered the crate, and then sat down very suddenly behind it.", cause = "Hit on ammunition duty" },
			},
			{
				label = "Take the long way, safe and late",
				result = { sanity = -2, setFlags = { "fn_thumb_late" }, log = "The crate arrived safe and four minutes late. The Capo counted the minutes out loud. You cleaned propellant rounds again for a month." },
			},
			{
				label = "Count the rounds before you go",
				clash = { stat = "intelligence", foe = "Six hundred rounds", coins = 2, base = 3, coinPower = 3 },
				win = { intelligence = 1, paycheck = 0.2, log = "You found the crate twelve rounds short and reported it before anyone could blame you. Somebody else cleans rounds now." },
				lose = { sanity = -2, log = "You lost count at four hundred and had to start again. The fight was over before you finished." },
			},
		},
	},
	{
		id = "fn_thumb_wrong_name",
		title = "Without the Title",
		text = "In the mess hall, a new Soldato Primo named Ettore says a Capo's name out loud, without the title, just as that Capo's own Soldato walks past. The room goes silent the way a street goes silent at 3:12. Ettore hasn't noticed yet. Everyone is looking at the floor, and some of them are looking at you.",
		weight = 20,
		once = true,
		tags = { "fingers" },
		when = { career = "thumb", notFlags = { "fn_thumb_capo" } },
		choices = {
			{
				label = "Finish his sentence with the title",
				clash = { stat = "mind", foe = "A room full of rules", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, setFlags = { "fn_saved_ettore" }, log = "You said \"...Capo Ottavia\" loudly, as if finishing his sentence for him. The Soldato walked on. Ettore paid for your meals for a month." },
				lose = { sanity = -3, log = "You weren't fast enough. Ettore wasn't at breakfast the next morning, or the one after." },
			},
			{
				label = "Report him by the book",
				result = { paycheck = 0.3, mind = 1, sanity = -4, addRelation = { kind = "rival", name = "Ettore Vasi", bond = 20 }, log = "You reported him exactly as page 412 describes, and were commended. Ettore came back a month later with his arm in a sling and never looked at you again." },
			},
			{
				label = "Look at the floor like everyone else",
				result = { sanity = -2, log = "You looked at the floor with everyone else. It's very easy to look at a floor. It's harder to stop remembering it." },
			},
		},
	},
	{
		id = "fn_thumb_capo",
		title = "Capo I",
		text = "You are a Capo now, with a table of your own and four Soldati who stand when you enter. The first test comes fast: your Soldato Secondo dropped a crate of propellant rounds on the stairs and three went off. Nobody was hurt. Several things were. The Soldati are watching to see what kind of Capo you are.",
		weight = 24,
		once = true,
		tags = { "fingers" },
		when = { career = "thumb", flags = { "fn_thumb_capo" }, notFlags = { "fn_thumb_capo_iiii" } },
		choices = {
			{
				label = "Discipline him by the book",
				result = { paycheck = 0.3, sanity = -3, setFlags = { "fn_thumb_strict" }, log = "You fined him a season's pay and put him back on cleaning duty. The other Soldati stood straighter after that. So did you, though it cost you something." },
			},
			{
				label = "Pay for the stairs yourself",
				hint = "100 Ahn",
				requires = { min = { money = 100 } },
				result = { money = -100, sanity = 3, setFlags = { "fn_thumb_kind" }, log = "You paid for the stairs out of your own pocket and told him to carry crates properly. Your Soldati would walk through fire for you now. Other Capi think you're soft." },
			},
			{
				label = "Have him copy page 1,271 by hand",
				result = { intelligence = 1, sanity = 1, log = "He copied \"How to Encourage Your Juniors\" forty times. By the end he could recite it, and he had stopped dropping things." },
			},
		},
	},
	{
		id = "fn_thumb_summit",
		title = "The Summit",
		text = "As a Capo IIII you sit at the Thumb Summit. The Padrino, the Capo dei capi, waits at the far end of a long table and says almost nothing. The boss of a small Syndicate that exists by the Thumb's permission stands up and asks why his crew must give up a street they were promised. The room stops breathing.",
		weight = 20,
		once = true,
		tags = { "fingers" },
		when = { career = "thumb", flags = { "fn_thumb_capo_iiii" } },
		codex = "fn_lore_syndicates",
		choices = {
			{
				label = "Say nothing",
				result = { sanity = -4, mind = 2, log = "You said nothing. Nobody said anything. By the end of the week his Syndicate had been purged, and the street was very quiet." },
			},
			{
				label = "Speak for him, very carefully",
				clash = { stat = "mind", foe = "The Padrino's silence", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = 2, paycheck = 0.5, setFlags = { "fn_summit_spoke" }, log = "You suggested, with every honorific in the manual, that the man was overcome with gratitude and had misspoken. The Padrino moved one finger. The man lived, and owes you forever." },
				lose = { health = { -8, -3 }, sanity = -6, log = "The Padrino looked at you for exactly one second. You were corrected that night, thoroughly and very politely.", cause = "Corrected by the Thumb" },
			},
			{
				label = "Claim his street for your Soldati",
				result = { wage = { 150, 300 }, sanity = -3, log = "When his Syndicate was purged, the street went to your Soldati. The fees from it pay for a great deal. You never walk down it." },
			},
		},
	},
	{
		id = "fn_thumb_sottocapo",
		title = "Sottocapo",
		text = "You are Sottocapo of the Thumb, the underboss who runs this whole area. Capi bow to you, and Soldati may not look at your face. Every shop, stall and small Syndicate on your streets pays its contribution into your ledger. Your streets will run on your rules now. Which rules?",
		weight = 300,
		once = true,
		tags = { "fingers" },
		when = { career = "thumb", minRank = 9 },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Every rule, to the letter",
				result = { paycheck = 0.5, chronicle = "fn_sottocapo", setFlags = { "fn_sottocapo_strict" }, log = "Your streets became the most orderly in the District. People bowed to your Soldati from across the road, and paid early." },
			},
			{
				label = "Fees people can actually pay",
				result = { sanity = 4, chronicle = "fn_sottocapo", setFlags = { "fn_sottocapo_fair" }, log = "You lowered the contributions and raised the penalties for Rats. The noodle stalls on your streets stayed open later than anywhere in the District." },
			},
			{
				label = "Raise every fee",
				result = { wage = { 400, 700 }, sanity = -4, chronicle = "fn_sottocapo", setFlags = { "fn_sottocapo_greedy" }, log = "The ledgers filled up. The streets emptied a little. Nobody said anything, by the rules." },
			},
		},
	},

	-- ── everyone else ──
	{
		id = "fn_thumb_contribution",
		title = "The Contribution",
		text = "The two Soldati come on the first of the month, always together, always polite. \"The contribution,\" says the senior one, \"for the protection of the street.\" This month it has gone up again, and you're short. Next door, the tailor is pretending to sweep so he can watch how you handle it.",
		weight = 14,
		cooldown = 4,
		tags = { "fingers", "crime", "backstreets" },
		when = { minAge = 18, side = "backstreets", notFlags = { "fn_thumb_member", "fn_owes_thumb" } },
		codex = "fingers_thumb",
		choices = {
			{
				label = "Pay, and thank them properly",
				hint = "40 Ahn",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 1, setFlags = { "thumb_respect" }, log = "You paid and bowed exactly as low as their ranks deserve. The senior one put a small, approving tick beside your name." },
			},
			{
				label = "Ask for a month's credit",
				result = debt("The senior Soldato wrote your name in a different column of the ledger. \"Of course,\" he said. \"The Thumb is patient. Interest is how it shows patience.\""),
			},
			{
				label = "Refuse",
				clash = { stat = "strength", foe = "Two Thumb Soldati", coins = 2, base = 5, coinPower = 3, fight = true, status = "burn" },
				win = { strength = 2, sanity = -2, chronicle = "defied_thumb", setFlags = { "fn_thumb_disrespected" }, log = "You drove them off your step, and the whole street saw. The Thumb will come back with a Capo, and the Capo will bring a rulebook." },
				lose = { health = { -10, -4 }, money = { -60, -20 }, condition = "broken_arm", log = "The Thumb does not tolerate refusals. They were very polite about explaining that.", cause = "Refused the Thumb's contribution" },
			},
		},
	},
	{
		id = "fn_thumb_diner_bow",
		title = "How Low to Bow",
		text = "A Capo of the Thumb walks into the diner where you're eating, and every customer stands. The pin on his lapel says Capo, but not which grade. The bow for a Capo I and the bow for a Capo III are different, and getting it wrong is an insult. He is looking at your table.",
		weight = 12,
		cooldown = 5,
		tags = { "fingers", "backstreets" },
		when = { minAge = 14, notFlags = { "fn_thumb_member" } },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Read his pin and bow exactly right",
				clash = { stat = "charisma", foe = "A Capo's lapel pin", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, setFlags = { "thumb_respect" }, addTrait = "fn_knows_their_place", log = "Three bars on the pin: Capo III. You bowed to exactly that depth. He nodded, sat, and paid for your noodles on his way out." },
				lose = { sanity = -4, setFlags = { "fn_thumb_disrespected" }, log = "You bowed as if to a Capo I. He looked at you for a long time. His Soldato wrote something down." },
			},
			{
				label = "Bow as low as you possibly can",
				result = { sanity = -1, charisma = 1, log = "You bowed so low your forehead nearly touched the table. A Soldato told you afterward that over-bowing is a kind of sarcasm, but the Capo let it go this time." },
			},
			{
				label = "Keep eating",
				hint = "That is a choice. The Thumb takes choices seriously.",
				result = { health = { -6, -2 }, sanity = -3, setFlags = { "fn_thumb_disrespected" }, log = "You kept eating. Two Soldati escorted you outside and corrected you in the alley. Your noodles were cold when they let you back in.", cause = "Corrected by the Thumb" },
			},
		},
	},
	{
		id = "fn_thumb_bullet",
		title = "Bullets Are Expensive",
		text = "You bump a Thumb Soldato in the market and knock his paper bag into a puddle. He draws his pistol, points it at your chest, then sighs and lowers it. \"Do you know what a propellant round costs?\" he asks. \"More than you. That's the only reason you're still talking.\"",
		weight = 10,
		cooldown = 6,
		tags = { "fingers", "crime" },
		when = { minAge = 12, side = "backstreets", notFlags = { "fn_thumb_member" } },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Apologize to his rank, correctly",
				clash = { stat = "charisma", foe = "A Soldato's temper", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, setFlags = { "thumb_respect" }, log = "\"Soldato Terzo, my apologies,\" you said, having read his collar. He blinked, holstered the pistol, and told you to watch your feet." },
				lose = { sanity = -3, log = "You guessed his rank too high. He was only a Secondo, so he took it as a compliment, and you got away with it." },
			},
			{
				label = "Pay for his groceries",
				hint = "20 Ahn",
				requires = { min = { money = 20 } },
				result = { money = -20, sanity = -1, log = "You bought him a new bag of groceries. He counted the change and handed you two Ahn back, precisely." },
			},
			{
				label = "Tell him to go ahead and shoot",
				clash = { stat = "strength", foe = "An insulted Soldato", coins = 2, base = 5, coinPower = 3, fight = true, status = "burn" },
				win = { strength = 2, chronicle = "defied_thumb", setFlags = { "fn_thumb_disrespected" }, log = "He didn't shoot. He swung. You won, and the whole market watched you win, which the Thumb will not forget." },
				lose = { health = { -10, -4 }, sanity = -3, log = "He decided you were worth one bullet after all, and was very careful where he put it.", cause = "Worth one Thumb bullet" },
			},
		},
	},
	{
		id = "fn_thumb_ledger",
		title = "The Ledger",
		text = "The Soldato with the ledger is on your stairs again, one finger resting on the line with your name. The interest has been doing what interest does. \"The Thumb is patient,\" he says. \"The Thumb is also exact. Today it would like to be exact with you.\"",
		weight = 30,
		cooldown = 2,
		tags = { "fingers" },
		when = { flags = { "fn_owes_thumb" } },
		choices = {
			{
				label = "Pay it all",
				hint = "150 Ahn",
				requires = { min = { money = 150 } },
				result = { money = -150, clearFlags = { "fn_owes_thumb" }, cure = "fn_thumb_interest", removeTrait = "in_debt_to_the_thumb", sanity = 4, log = "You paid every Ahn. He ruled a neat line through your name and thanked you for your punctuality." },
			},
			{
				label = "Work it off carrying crates",
				result = { health = { -6, -2 }, sanity = -2, clearFlags = { "fn_owes_thumb" }, cure = "fn_thumb_interest", removeTrait = "in_debt_to_the_thumb", log = "You carried crates of propellant rounds across three Districts for a week. He ruled out your line. Your shoulders still remember." },
			},
			{
				label = "Ask for more time",
				result = { condition = "fn_thumb_interest", sanity = -2, log = "He wrote a second, smaller number beside the first. \"Patience,\" he said, \"is billed monthly.\"" },
			},
			{
				label = "Run",
				clash = { stat = "speed", foe = "Soldati who know every alley", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = -3, log = "You lost them in the laundry quarter. You also lost the right to walk down half the streets you know." },
				lose = { health = { -10, -4 }, condition = "broken_arm", log = "They knew every alley you did, and three you didn't.", cause = "Ran from the Thumb's ledger" },
			},
		},
	},
	{
		id = "fn_thumb_provoke",
		title = "The Wrong Word",
		text = "Your friend Bruno has had a long day, and when a Capo's car splashes him at the curb, he shouts the Capo's name, plainly, without the title, along with an opinion about the Capo's tailoring. The car stops. The window rolls down. The Capo looks at Bruno, and then at you, standing next to him.",
		weight = 8,
		once = true,
		tags = { "fingers", "backstreets" },
		when = { minAge = 16, side = "backstreets", notFlags = { "fn_thumb_member" } },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Apologize for both of you, at length",
				clash = { stat = "charisma", foe = "A Capo who heard every word", coins = 3, base = 5, coinPower = 3 },
				win = { sanity = -2, setFlags = { "fn_thumb_disrespected" }, quest = "fn_q_apology", log = "You apologized until the Capo raised a hand. \"Your friend will make amends,\" he said. \"So will you, since you were standing there.\" A Soldato handed you a rulebook." },
				lose = { sanity = -4, setFlags = { "fn_thumb_disrespected" }, chronicle = "fn_thumb_provoked", quest = "fn_q_apology", log = "The Capo rolled the window up without a word. By morning the Thumb was collecting on every street in the District, and everyone knew whose fault it was." },
			},
			{
				label = "Grab Bruno and run",
				result = { sanity = -3, setFlags = { "fn_thumb_disrespected" }, chronicle = "fn_thumb_provoked", log = "You ran. The Thumb took that as agreement. By the end of the week they were going door to door, with your names on the reason line of every ledger." },
			},
			{
				label = "Step away from Bruno",
				result = { sanity = -6, log = "You stepped back and let the Soldati have him. Bruno came back a month later, corrected, and never spoke to you again." },
			},
		},
	},
	{
		id = "fn_thumb_lei_heng",
		title = "Do Not Look at That Man",
		text = "A huge man in a Thumb suit shoves through the Daguanyuan crowd, and even people in expensive clothes step aside and study their shoes. \"Capo IIII Qin Rui,\" someone breathes. \"Thumb East. Don't look at him. Don't say his name. People who were here when the Middle's Big Brother came through say this one is worse.\"",
		weight = 18,
		once = true,
		tags = { "fingers" },
		when = { district = "d8", minAge = 12, minYear = 1003, world = { era = "limbus" } },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Look at your shoes",
				result = { sanity = 1, mind = 1, log = "You studied your shoes until his footsteps were gone. They're very good shoes. You know them extremely well now." },
			},
			{
				label = "Sneak one look",
				clash = { stat = "mind", foe = "A Capo IIII's attention", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = -2, mind = 2, log = "You saw him for one second: a man who looked like a storm in a tailored suit. He didn't see you. You're almost sure." },
				lose = { sanity = -6, condition = "night_terrors", log = "He looked back, for a moment. Then he kept walking, and you started breathing again somewhere around the next street." },
			},
			{
				label = "Say his name without the title",
				hint = "A very bad idea.",
				result = { health = { -13, -6 }, sanity = -6, condition = "broken_arm", setFlags = { "fn_thumb_disrespected" }, log = "You said \"Qin Rui\". Three Soldati of the Thumb East corrected you before you finished the second word. Qin Rui never even turned around.", cause = "Said Qin Rui's name without his title" },
			},
		},
	},
	{
		id = "fn_thumb_crackdown_bow",
		title = "Everyone Is Very Polite",
		text = "The Thumb is collecting today, and every door on the street stands open with its owner beside it, bowing. The Soldati go door to door with ledgers. At the end of the street a Capo waits with his hands behind his back, watching how everyone bows. Your neighbor's little boy hasn't learned the bows yet.",
		weight = 30,
		cooldown = 2,
		tags = { "fingers" },
		when = { worldEvent = "thumb_crackdown", minAge = 12 },
		codex = "fn_lore_thumb_ranks",
		choices = {
			{
				label = "Teach the boy the bow, quickly",
				clash = { stat = "charisma", foe = "A six-year-old's attention span", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = 3, setFlags = { "thumb_respect" }, log = "He bowed like a tiny Soldato. The Capo smiled, very slightly, and moved the boy's family to the bottom of the ledger." },
				lose = { sanity = -2, log = "He waved at the Capo instead. His mother paid double. She didn't blame you, out loud." },
			},
			{
				label = "Pay and stand very still",
				hint = "30 Ahn",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = -1, mind = 1, log = "You paid and stood so still that a Soldato checked you were breathing. He approved." },
			},
			{
				label = "Pay for the whole row of doors",
				hint = "120 Ahn",
				requires = { min = { money = 120 } },
				result = { money = -120, sanity = 5, setFlags = { "thumb_respect" }, log = "You paid for the whole row. The Capo wrote \"generous\" beside your name, which on the Thumb's streets is almost a title." },
			},
		},
	},

	{
		id = "fn_thumb_retire",
		title = "An Honorable Retirement",
		text = "The Thumb honors its elders the way it does everything: by the rules. Your Capo has sent a formal letter on heavy paper, inviting you to retire with full ceremony. There would be a pension, a pin, and a seat at the back of every Summit you can still walk to. Refusing an honor is, technically, a kind of disrespect.",
		weight = 25,
		cooldown = 4,
		tags = { "fingers" },
		when = { career = "thumb", minAge = 58 },
		choices = {
			{
				label = "Accept the ceremony",
				result = { quitCareer = true, wage = { 200, 350 }, sanity = 5, setFlags = { "fn_thumb_retired" }, log = "Forty Soldati bowed to you at once, each at the correct depth for your rank. You wore the retirement pin to every noodle stall on the street for the rest of your life." },
			},
			{
				label = "Teach etiquette to the Primi",
				result = { paycheck = 0.3, sanity = 2, intelligence = 1, log = "You stayed on to teach the new Primi page 1,271. They're terrified of you. They bow beautifully." },
			},
			{
				label = "Politely decline, by the rules",
				clash = { stat = "mind", foe = "Declining an honor correctly", coins = 2, base = 4, coinPower = 3 },
				win = { paycheck = 0.4, log = "You declined in the exact form the manual prescribes for declining honors. Your Capo was impressed, and let you work another year." },
				lose = { sanity = -3, quitCareer = true, wage = { 100, 200 }, log = "You declined in the wrong form, which counted as accepting. You were retired anyway, with slightly less ceremony." },
			},
		},
	},
	-- the apology quest's last step (Quests/Fixers.luau)
	{
		id = "fn_q_apology_bow",
		title = "The Bow",
		text = "The Capo you offended is collecting on your street today, and the Soldato with the rulebook has told you exactly where to stand: two paces from the curb, eyes on the third button of the Capo's coat, never his face. Your bow must be exactly one degree deeper than his grade requires. Not two. Two would be sarcasm.",
		weight = 0,
		when = { flags = { "fn_q_apology_sent" } },
		choices = {
			{
				label = "Bow exactly right",
				clash = { stat = "charisma", foe = "One degree", coins = 2, base = 4, coinPower = 3 },
				win = { setFlags = { "fn_q_apology_done" }, sanity = 2, log = "One degree. The Capo looked at your bow, then at the Soldato with the rulebook, who nodded. The matter was closed." },
				lose = { sanity = -3, schedule = { event = "fn_q_apology_bow", inYears = 1 }, log = "Two degrees: sarcasm. The Soldato sighed and said there would be another collection next year." },
			},
			{
				label = "Bow, and bring a gift",
				hint = "80 Ahn",
				requires = { min = { money = 80 } },
				result = { money = -80, setFlags = { "fn_q_apology_done" }, log = "Your bow was approximately right. The gift, a box of the Capo's favorite candied chestnuts, was exactly right." },
			},
		},
	},
}
