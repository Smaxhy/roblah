--[[
	Later adult life (ad_l_), ages 35-50 and 50+: parents getting old, raising a child in the
	City, debts that come back, Smoke War veterans, the Head's Arbiters and Claws, and the
	people from Adult_City.luau years on. Faces: Cast/Adults.luau.

	Chains:
		ad_l_haldor_papers -> (2y) ad_l_haldor_night, (4y) ad_l_haldor_box
		ad_l_cosign -> (3y) ad_l_cosign_due
		ad_l_kurokumo_rent -> (1y) ad_l_clan_returns
		ad_l_arbiter_street, ad_l_claw_teahouse, ad_l_claw_signs   rare, and very dangerous
	Payoffs of Adult_City chains:
		ad_l_tomas_grown (ad_tomas_owes), ad_l_dalia_last (ad_dalia_trust),
		ad_l_dalia_flat (ad_dalia_owes), ad_l_middle_favor (ad_middle_done),
		ad_l_piero_retires (thumb_respect), ad_l_ysolde_old (ad_ashgrave_friend),
		ad_l_raising_rules / _card / _late (ad_raising: the girl from Platform Six)
	Flags others can reuse: ad_haldor_known, ad_cosigned, ad_middle_family, ad_waiver_signed.
]]

local AFTER = { era = { "library", "limbus" } }

return {
	-- ── people from earlier, years on ──
	{
		id = "ad_l_tomas_grown",
		title = "Tomas, Grown",
		art = "street",
		text = "Tomas is twenty-five and runs the Copper Hounds' east side. He's at your door with an envelope going the other way.",
		weight = 0,
		when = { flags = { "ad_tomas_owes" } },
		dialogue = {
			{ who = "ad_tomas", line = "Eighty Ahn, ten years ago. I worked out the interest. The Hounds' rate, not yours." },
			{ who = "ad_tomas", line = "Also, Jefe's retiring. I'm next. You'd be surprised who I listen to these days." },
		},
		choices = {
			{
				label = "Take the envelope",
				result = { money = 400, sanity = 2, log = "Four hundred. You tried to give half back. He was already halfway down the stairs, whistling." },
			},
			{
				label = "Ask him to drop your block's fee",
				result = { strength = 1, sanity = 4, setFlags = { "ad_block_free" }, log = "He thought about it for one breath. Your block paid nothing for as long as Tomas ran the east side." },
			},
			{
				label = "Ask him to get out",
				clash = { stat = "mind", foe = "A man who likes his job", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 5, log = "He laughed, then stopped. A year later he was running a courier route, legally and badly, whistling." },
				lose = { sanity = -3, log = "\"Out to where?\" he said, kindly. He left the envelope on your step anyway." },
			},
		},
	},
	{
		id = "ad_l_dalia_last",
		title = "Dalia's Last Job",
		art = "syndicate",
		text = "The Halfmoon Office is down to Dalia, grey at the temples now. A Syndicate boss owes her a life, and she's collecting it tonight.",
		weight = 12,
		once = true,
		when = { minAge = 35, maxAge = 55, flags = { "ad_dalia_trust" } },
		dialogue = {
			{ who = "ad_dalia", line = "Same job as the first time. Stand behind me. This time I might be the one who needs a witness." },
			{ who = "ad_dalia", line = "If it goes wrong, the Office is yours. It's a desk and a sign. Don't laugh." },
		},
		choices = {
			{
				label = "Stand behind her",
				clash = { stat = "strength", foe = "A Syndicate boss and his whole floor", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "syndicate", status = { id = "rupture", potency = 3 } },
				win = { strength = 4, money = 300, setFlags = { "ad_dalia_done" }, log = "You both walked out. She put the sign in your hands anyway. \"I'm retiring,\" she said. \"Someone has to keep the stupid sign.\"" },
				lose = { health = { -24, -12 }, sanity = -8, setFlags = { "ad_dalia_done" }, cause = "Stood behind Dalia Szabo one last time", log = "You carried her out, or she carried you. Neither of you remembers which. The Office closed that winter." },
			},
			{
				label = "Talk her out of it",
				clash = { stat = "charisma", foe = "Twenty years of Dalia", coins = 3, base = 5, coinPower = 3 },
				win = { charisma = 3, sanity = 4, setFlags = { "ad_dalia_done" }, log = "You talked until the noodles went cold. She didn't go. She opened a stall selling coats to Fixers and overcharged every one." },
				lose = { sanity = -6, setFlags = { "ad_dalia_done" }, log = "She went alone. In the morning the Halfmoon sign was propped against your door, with no note." },
			},
			{
				label = "Say you're too old for this",
				result = { sanity = -4, log = "\"So am I,\" she said, and went alone. She came back with a limp and a story she never finished telling." },
			},
		},
	},
	{
		id = "ad_l_dalia_flat",
		title = "Moving Day",
		art = "home",
		text = "Dalia sends her whole Office to your door, all three of them, to carry your furniture to a better flat she found. It's her way of paying for a signature.",
		weight = 8,
		once = true,
		when = { minAge = 30, maxAge = 60, flags = { "ad_dalia_owes" } },
		dialogue = {
			{ who = "ad_dalia", line = "Better locks and a landlord who's scared of me. Don't thank me. Thanking makes it a gift." },
		},
		choices = {
			{
				label = "Take the flat",
				result = { sanity = 4, money = 60, log = "The window shut properly and the landlord flinched at Dalia's name. Your rent went down and never came back up." },
			},
			{
				label = "Ask her about Pim",
				result = { mind = 1, sanity = -5, log = "\"Pim was going to die on some job,\" she said. \"I got him a better grade to do it at.\" She carried your lamp up herself." },
			},
		},
	},
	{
		id = "ad_l_piero_retires",
		title = "Piero Retires",
		art = "street",
		text = "Piero is retiring from the Thumb with full honors at Soldato Quarto, as high as he ever wanted. He's going door to door on your street to say goodbye properly.",
		weight = 10,
		once = true,
		when = { minAge = 40, maxAge = 65, flags = { "knows_thumb", "thumb_respect" } },
		dialogue = {
			{ who = "ad_piero", line = "Twenty-two years, never late. Never fired a round on this street. I'd like that on my stone." },
			{ who = "ad_piero", line = "The new man is very keen. Bow a little lower for him. Not too low." },
		},
		choices = {
			{
				label = "Bow to him, properly",
				result = { charisma = 1, sanity = 4, log = "A Soldato Quarto's bow, exactly, the last time. He bowed back deeper than the manual allows, and walked on." },
			},
			{
				label = "Ask him to tear out your page",
				requires = { flags = { "fn_owes_thumb" } },
				clash = { stat = "mind", foe = "A man's last day of duty", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 4, clearFlags = { "fn_owes_thumb", "ad_thumb_loan" }, cure = "fn_thumb_interest", removeTrait = "in_debt_to_the_thumb", log = "He found your page in the small black book and tore it out along the ruler. \"A retirement gift,\" he said. \"Mine, not yours.\"" },
				lose = { sanity = -3, log = "\"It isn't my book,\" he said, sadly. \"It never was. That's the point of the book.\"" },
			},
			{
				label = "Give him an umbrella",
				result = { money = { -40, -20 }, sanity = 3, setFlags = { "ad_piero_friend" }, log = "You gave him a good umbrella. He held it like a medal. A postcard came from the Nest with a drawing of it." },
			},
		},
	},
	{
		id = "ad_l_middle_favor",
		title = "Family Hides Family",
		art = "home",
		text = "Renata is at your door with a Little Brother who called a Capo by his first name. The Thumb is searching for him street by street, and she needs a week.",
		weight = 10,
		once = true,
		when = { minAge = 35, maxAge = 60, flags = { "ad_middle_done" } },
		dialogue = {
			{ who = "ad_renata", line = "You ran our parcel once. Family remembers. Now family asks." },
			{ who = "middle_sibling", line = "I said his name. That's all I did. I only said his name." },
		},
		choices = {
			{
				label = "Hide him for a week",
				clash = { stat = "mind", foe = "Soldati checking every flat", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, setFlags = { "ad_middle_family" }, log = "A Soldato stood in your kitchen for five minutes with the Little Brother in the flour sack. The Middle sends you a cake every year." },
				lose = { health = { -14, -6 }, sanity = -6, setFlags = { "fn_thumb_disrespected" }, cause = "Hid a Little Brother from the Thumb", log = "They found him in the flour. They corrected him on the stairs and you in the kitchen, very politely." },
			},
			{
				label = "Refuse her",
				result = { sanity = -3, log = "Renata nodded as if she'd expected it. \"Family doesn't hold a no against family,\" she said. She held it a little." },
			},
			{
				label = "Tell the Thumb where he is",
				result = { money = 250, sanity = -10, condition = "in_the_book", setFlags = { "thumb_respect" }, chronicle = "fn_written_in_book", log = "The Thumb paid two-fifty and thanked you formally. That same evening Renata wrote your name down, in red." },
			},
		},
	},
	{
		id = "ad_l_ysolde_old",
		title = "She Hasn't Aged",
		art = "home",
		text = "Ysolde knocks on your door for the first time in years, and you've gone grey. She looks exactly as she did at that dinner, and seems sorry about it.",
		weight = 12,
		once = true,
		when = { minAge = 50, flags = { "ad_ashgrave_friend" } },
		codex = "bf_lore_kindred",
		dialogue = {
			{ who = "ad_ysolde", line = "I came to say thank you while it still means something to both of us. The street meetings were very dull." },
			{ who = "ad_ysolde", line = "I'd like a keepsake. Something of yours. We're terrible at keeping faces." },
		},
		choices = {
			{
				label = "Give her a photograph",
				result = { sanity = 5, log = "You gave her the photo off your wall. She put it inside her coat, carefully, like a letter she meant to answer later." },
			},
			{
				label = "Ask her to remember your name",
				result = { mind = 1, sanity = 3, log = "She said it back three times, slowly, as if learning a language. \"There,\" she said. \"For as long as I'm around.\"" },
			},
			{
				label = "Ask her to go",
				result = { sanity = -2, log = "You said you didn't want to be remembered by someone who'd watched you get old. She said that was fair, and left a hamper anyway." },
			},
		},
	},

	-- ── Haldor and the Smoke War ──
	{
		id = "ad_l_haldor_papers",
		title = "Haldor's Papers",
		art = "checkpoint",
		text = "Haldor from the bathhouse is eighty and wants to die inside the Nest, where his daughter lives. The Wing refused him: his file says he fought in the Smoke War.",
		weight = 9,
		once = true,
		when = { minAge = 35, maxAge = 60 },
		codex = "bs_lore_smoke_war",
		dialogue = {
			{ who = "ad_haldor", line = "Both sides refuse us. Doesn't matter which one I was on. The paper only says 'veteran'." },
			{ who = "ad_haldor", line = "You've a good hand, my daughter says. You could make it say 'clerk'." },
		},
		choices = {
			{
				label = "Forge it",
				clash = { stat = "intelligence", foe = "A Wing records office", coins = 3, base = 5, coinPower = 3 },
				win = { intelligence = 3, sanity = 4, setFlags = { "ad_haldor_known", "ad_haldor_inside" }, schedule = { event = "ad_l_haldor_box", inYears = 4 }, log = "\"Supply clerk, never deployed.\" The Wing approved it in a week. He sent you a postcard of a very clean park." },
				lose = { money = { -200, -100 }, sanity = -6, setFlags = { "ad_haldor_known" }, schedule = { { event = "ad_l_haldor_night", inYears = 2 }, { event = "ad_l_haldor_box", inYears = 4 } }, log = "The records clerk had a cousin in the Smoke War. She fined you quietly and stamped REFUSED on Haldor's file twice." },
			},
			{
				label = "Speak for him at the board",
				clash = { stat = "mind", foe = "A residence board", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 3, setFlags = { "ad_haldor_known", "ad_haldor_inside" }, schedule = { event = "ad_l_haldor_box", inYears = 4 }, log = "You told the board about the bathhouse and the way he folds his towel. They let him in on probation. At eighty." },
				lose = { sanity = -4, setFlags = { "ad_haldor_known" }, schedule = { { event = "ad_l_haldor_night", inYears = 2 }, { event = "ad_l_haldor_box", inYears = 4 } }, log = "The board thanked you for your statement and refused him in the same sentence." },
			},
			{
				label = "Say the Backstreets are home",
				result = { sanity = -2, setFlags = { "ad_haldor_known" }, schedule = { { event = "ad_l_haldor_night", inYears = 2 }, { event = "ad_l_haldor_box", inYears = 4 } }, log = "\"Home,\" he said, and laughed until he coughed. He went back to folding his towel." },
			},
		},
	},
	{
		id = "ad_l_haldor_night",
		title = "Haldor at 3:05",
		art = "night",
		text = "At 3:05 you see Haldor from your window, in his bathhouse robe, standing at attention in the middle of the street. He's watching the WARP rail.",
		weight = 0,
		when = { flags = { "ad_haldor_known" }, notFlags = { "ad_haldor_inside" } },
		dialogue = {
			{ who = "ad_haldor", line = "They're sending the Lord of Flies tonight. Somebody has to hold the line. Go back to bed, kid." },
		},
		choices = {
			{
				label = "Go down and drag him in",
				clash = { stat = "health", foe = "An old soldier who won't move", coins = 3, base = 5, coinPower = 3 },
				win = { health = 2, sanity = -4, log = "You got him over your shoulder at 3:11. He fought you up three flights, then fell asleep on your floor, still saluting." },
				lose = { health = { -16, -8 }, sanity = -8, cause = "Went out for Haldor at 3:05", log = "At 3:13 you were in the street holding his robe. Only his robe. You got back in. You don't remember how." },
			},
			{
				label = "Shout an order from the window",
				clash = { stat = "mind", foe = "A war that never ended", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = -2, log = "You shouted \"Fall back!\" and his old unit number from the window. He turned smartly and marched indoors. He thanked you at breakfast." },
				lose = { sanity = -10, log = "He didn't know the number you shouted. He held his line. In the morning the street was very clean." },
			},
			{
				label = "Close the curtains",
				result = { sanity = -12, log = "You closed the curtains at 3:06 and sat with your back to the window for eighty minutes. The bathhouse put his towel in its window." },
			},
		},
	},
	{
		id = "ad_l_haldor_box",
		title = "Haldor's Box",
		art = "home",
		text = "Haldor left you a shoebox with his Old G Corp medal and a propaganda poster of a boy soldier with a gentle face. The note says: \"Sell the medal. Keep the boy.\"",
		weight = 0,
		when = { flags = { "ad_haldor_known" } },
		codex = "dz_lore_smoke_relics",
		choices = {
			{
				label = "Sell the medal",
				result = { money = { 300, 500 }, sanity = -2, log = "A collector paid four hundred and cried a little. You pinned the boy soldier above your stove." },
			},
			{
				label = "Keep them both",
				result = { sanity = 3, log = "You kept both in the box under your bed. Some nights you take the poster out. The boy looks less gentle every year." },
			},
			{
				label = "Show the poster around",
				requires = { world = { era = "limbus" } },
				result = { mind = 2, sanity = -3, setFlags = { "ad_saw_the_boy" }, log = "A tired man by a strange bus at the depot saw it and went very still. \"Where did you get that,\" he said, not quite a question." },
			},
		},
	},

	-- ── parents getting old ──
	{
		id = "ad_l_father_night",
		title = "Dad and the Night",
		art = "night",
		text = "{father} has started forgetting the stove, and which year it is. Tonight he's forgotten the rule. It's 2:50, and he's walking toward the market in his slippers.",
		weight = 9,
		once = true,
		tags = { "backstreets" },
		when = { minAge = 35, maxAge = 60, side = "backstreets", hasRelation = "father", flags = { "knows_night" } },
		choices = {
			{
				label = "Run after him",
				clash = { stat = "speed", foe = "Twenty minutes and his head start", coins = 2, base = 4, coinPower = 3 },
				win = { speed = 2, relationBond = { kind = "father", amount = 10 }, log = "You caught him at the market steps at 2:58 and walked him home arm in arm, talking about the weather like it was afternoon." },
				lose = { health = { -14, -6 }, sanity = -8, relationBond = { kind = "father", amount = 6 }, cause = "Went out for your father before the Night", log = "You found him at 3:09. You spent the Night together in a bathhouse doorway, holding hands like children." },
			},
			{
				label = "Pay the Night Office",
				hint = "250 Ahn.",
				requires = { min = { money = 250 } },
				result = { money = -250, sanity = -3, log = "The Office runner had him home by 3:01, angry and safe. The invoice listed him as \"one gentleman, retrieved.\"" },
			},
			{
				label = "Shout for the watch",
				result = { sanity = -3, relationBond = { kind = "father", amount = -4 }, log = "The watch's lamp found him at 2:57 and walked him back. In the morning you fitted a fourth lock on his door, inside." },
			},
		},
	},
	{
		id = "ad_l_father_debt",
		title = "What He Borrowed",
		art = "home",
		text = "{father} finally tells you: twenty years ago he borrowed from the Thumb to pay for your schooling, and he's been paying the interest ever since. There's still a principal.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 60, hasRelation = "father", flags = { "knows_thumb" }, notFlags = { "fn_owes_thumb" } },
		dialogue = {
			{ who = "{father}", line = "Don't look at me like that. You were bright. Bright children cost money. I'll pay it before I go." },
		},
		choices = {
			{
				label = "Pay the principal",
				hint = "500 Ahn.",
				requires = { min = { money = 500 } },
				result = { money = -500, sanity = 3, relationBond = { kind = "father", amount = 15 }, log = "You took it to the Thumb's office yourself. The Capo looked up the account and seemed almost sorry to close it." },
			},
			{
				label = "Move the debt to your name",
				result = { sanity = -3, setFlags = { "fn_owes_thumb" }, condition = "fn_thumb_interest", addTrait = "in_debt_to_the_thumb", relationBond = { kind = "father", amount = 10 }, log = "You signed it over to yourself in a Thumb office with very good chairs. {father} slept through the night for the first time in years." },
			},
			{
				label = "Let him keep paying",
				result = { sanity = -5, relationBond = { kind = "father", amount = -4 }, log = "You let him keep paying. He paid every month to the end, on time and in person." },
			},
		},
	},
	{
		id = "ad_l_mother_hip",
		title = "Her Hip",
		art = "clinic",
		text = "{mother} broke her hip on the fifth-floor stairs, and the clinic can set it in a year. A K Corp ampule would have her walking by Friday, for six hundred Ahn.",
		weight = 9,
		once = true,
		when = { minAge = 35, maxAge = 60, hasRelation = "mother" },
		dialogue = {
			{ who = "{mother}", line = "Six hundred? For a hip I've had my whole life? Spend it on something with a future." },
		},
		choices = {
			{
				label = "Buy the ampule",
				hint = "600 Ahn.",
				requires = { min = { money = 600 } },
				result = { money = -600, sanity = 3, relationBond = { kind = "mother", amount = 12 }, setFlags = { "knows_wings" }, log = "She walked out of the clinic on Friday, furious about the price, and climbed all five floors to prove a point." },
			},
			{
				label = "Sell her flat to pay for it",
				result = { sanity = -4, relationBond = { kind = "mother", amount = -10 }, log = "You sold her flat. She walked by Friday and moved into your back room. She never mentioned the flat." },
			},
			{
				label = "Let the clinic set it",
				result = { money = { -80, -50 }, sanity = -3, relationBond = { kind = "mother", amount = 4 }, log = "A year of a cot and a cane. On Sundays you carried her down five floors. She said the view was better than walking." },
			},
		},
	},
	{
		id = "ad_l_mother_letter",
		title = "Your Mother's Errand",
		art = "nest",
		text = "{mother} hands you an envelope for a retired Capo of the Thumb, whose table she cooked for twenty years. She won't say what's inside.",
		weight = 8,
		once = true,
		when = { minAge = 38, maxAge = 60, hasRelation = "mother", flags = { "knows_thumb" } },
		dialogue = {
			{ who = "{mother}", line = "Bow like a Soldato Secondo. No lower. He'd hate lower. And don't read it. I'll know." },
		},
		choices = {
			{
				label = "Deliver it with the right bow",
				clash = { stat = "charisma", foe = "A retired Capo's front door", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, sanity = 3, relationBond = { kind = "mother", amount = 8 }, log = "He read it in the doorway, then sat down on his own step. \"Tell her I accept,\" he said. She never told you what." },
				lose = { sanity = -4, log = "Your bow was a Soldato Primo's. He took the letter without a word. {mother} knew from your face." },
			},
			{
				label = "Read it first",
				result = { sanity = -5, relationBond = { kind = "mother", amount = -8 }, log = "Forty pages of apology for a burnt dinner in the year you were born. You resealed it and delivered it. She knew." },
			},
			{
				label = "Burn it",
				result = { sanity = -6, relationBond = { kind = "mother", amount = -15 }, log = "You burned it and said he'd taken it. She asked every week what he'd said, until she stopped asking." },
			},
		},
	},
	{
		id = "ad_l_father_bed",
		title = "A Bed Inside the Wall",
		art = "wing",
		text = "The Nest hospice has a bed for {father}: real doctors and a window on a park. It needs a sponsor, which means five years of service with the Wing, starting Monday.",
		weight = 8,
		once = true,
		when = { minAge = 40, maxAge = 60, side = "backstreets", hasRelation = "father", flags = { "knows_wings" } },
		dialogue = {
			{ who = "The Recruiter", line = "Five years as Class 1 staff. Your father keeps the bed as long as he needs it. We find it's rarely long." },
		},
		choices = {
			{
				label = "Sign the contract",
				result = { career = "wing", sanity = -2, relationBond = { kind = "father", amount = 12 }, log = "You signed. {father} got the bed and a view of a park. At your age you got a lanyard and a Class 1 badge." },
			},
			{
				label = "Pay for a private nurse",
				hint = "500 Ahn.",
				requires = { min = { money = 500 } },
				result = { money = -500, relationBond = { kind = "father", amount = 8 }, log = "A nurse came to the Backstreets flat every morning. {father} complained about her singing, and asked for her by name at the end." },
			},
			{
				label = "Keep him home yourself",
				result = { health = -3, sanity = -6, relationBond = { kind = "father", amount = 10 }, log = "You moved your bed into his room and slept in shifts with the Night for a year. He held your hand at 3:13, every time." },
			},
		},
	},
	{
		id = "ad_l_sibling_shadow",
		title = "Your Sibling's Shadow",
		art = "home",
		text = "{sibling}'s shop failed in spring and they've stopped sleeping. Tonight at dinner their shadow on the wall finishes its spoonful half a second after they do.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 60, hasRelation = "sibling", flags = { "knows_distortions" }, world = AFTER },
		codex = "lim_distortion_stages",
		dialogue = {
			{ who = "{sibling}", line = "I'm fine. Stop looking at the wall. Everyone looks at the wall now." },
		},
		choices = {
			{
				label = "Move them in with you",
				result = { money = { -100, -60 }, sanity = -4, relationBond = { kind = "sibling", amount = 12 }, log = "You gave them your bed and took the floor. Every night you checked the wall. By summer the shadow kept up." },
			},
			{
				label = "Report them early",
				result = { money = 150, sanity = -8, relationBond = { kind = "sibling", amount = -25 }, log = "The early-report fee was a hundred and fifty. {sibling} came back from observation a month later, cured, and never ate at your table again." },
			},
			{
				label = "Find what tipped them",
				clash = { stat = "mind", foe = "Your sibling's pride", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = 3, relationBond = { kind = "sibling", amount = 10 }, setFlags = { "lim_talked_down" }, log = "It was an unanswered letter from your mother, years old. You sat with them while they wrote back. The shadow caught up." },
				lose = { sanity = -6, relationBond = { kind = "sibling", amount = -6 }, log = "\"Stop managing me,\" they said, and left. Their shadow left a moment later." },
			},
		},
	},

	-- ── raising the girl from Platform Six ──
	{
		id = "ad_l_raising_rules",
		title = "Why 3:13",
		art = "home",
		text = "{child} is nine and asks why about everything. Tonight it's the Night: why 3:13, why the doors, why nobody is allowed to film it.",
		weight = 0,
		when = { hasRelation = "child", flags = { "ad_raising" } },
		dialogue = {
			{ who = "{child}", line = "Mika at school says the Sweepers are people who stayed out. Is that true? You can tell me. I'm nine." },
		},
		choices = {
			{
				label = "Tell the truth, carefully",
				result = { mind = 2, relationBond = { kind = "child", amount = 8 }, setFlags = { "ad_kid_told" }, log = "You told {child} what you knew, which wasn't much. That night they checked the locks twice, by themselves." },
			},
			{
				label = "Make it a gentler story",
				result = { sanity = 2, relationBond = { kind = "child", amount = 4 }, log = "You said the Sweepers clean the streets for the Head, very tidily, and hate being interrupted. True, as far as it goes." },
			},
			{
				label = "Say you'll tell them when they're older",
				result = { relationBond = { kind = "child", amount = -6 }, log = "{child} asked Mika's big brother instead, who knew a great many things, most of them wrong." },
			},
		},
	},
	{
		id = "ad_l_raising_card",
		title = "The Card in Their Coat",
		art = "home",
		text = "In {child}'s coat pocket you find a business card from the Halfmoon Office and seven Ahn in coins. {child} has been running messages for Fixers after school.",
		weight = 0,
		when = { hasRelation = "child", flags = { "ad_raising" } },
		dialogue = {
			{ who = "{child}", line = "It's just messages! Dalia says I'm the fastest runner she's got. She pays in Ahn AND lessons." },
		},
		choices = {
			{
				label = "Go and see Dalia",
				clash = { stat = "mind", foe = "A Rep who likes your kid", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, relationBond = { kind = "child", amount = 6 }, setFlags = { "ad_kid_runner", "knows_fixers" }, log = "Messages only, and home by six. {child} wrote it on the wall as a contract and made you both sign it." },
				lose = { sanity = -4, setFlags = { "ad_kid_runner", "knows_fixers" }, log = "Dalia talked rings round you. {child} kept running, and you kept finding coins in the wash." },
			},
			{
				label = "Forbid it",
				result = { relationBond = { kind = "child", amount = -10 }, log = "You forbade it. {child} stopped running for Dalia and started running for the laundry, which paid in soap." },
			},
			{
				label = "Put the card back",
				result = { sanity = -2, setFlags = { "ad_kid_runner" }, log = "You put the card back in the pocket. Most nights you heard {child} come in at six exactly, out of breath and proud." },
			},
		},
	},
	{
		id = "ad_l_raising_late",
		title = "3:06 and Not Home",
		art = "night",
		text = "It's 3:06 and {child} isn't home. They're fifteen and know the rule better than you do. The street outside has gone completely quiet.",
		weight = 0,
		when = { hasRelation = "child", flags = { "ad_raising" } },
		choices = {
			{
				label = "Go out and look",
				clash = { stat = "strength", foe = "The first wave", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "sweeper", status = { id = "sinking", potency = 2 } },
				win = { strength = 4, sanity = -6, relationBond = { kind = "child", amount = 15 }, log = "{child} was in the bathhouse doorway. You got you both inside as the first wave turned the corner. They held your sleeve till dawn." },
				lose = { health = { -24, -12 }, sanity = -10, cause = "Went out at 3:06 for your child", log = "{child} had been safe in the bathhouse since half past two. At dawn they found you on its step and pulled you in." },
			},
			{
				label = "Pay the Night Office",
				hint = "300 Ahn.",
				requires = { min = { money = 300 } },
				result = { money = -300, sanity = -6, relationBond = { kind = "child", amount = 6 }, log = "The Office runner brought {child} home at 3:11 from a friend's stairwell, with a fine and a lecture. You paid both." },
			},
			{
				label = "Wait by the door",
				result = { sanity = -12, relationBond = { kind = "child", amount = 4 }, log = "You sat with your hand on the lock for eighty minutes. {child} knocked at 4:34 and said sorry eleven times. You counted." },
			},
		},
	},

	-- ── children, any you have ──
	{
		id = "ad_l_child_waiver",
		title = "The Waiver",
		art = "checkpoint",
		text = "{child} passed a Wing's entrance exam: a Nest job and a Nest room. The last form is a waiver against Backstreets visitors, with your name already typed in.",
		weight = 8,
		once = true,
		when = { minAge = 42, maxAge = 60, side = "backstreets", hasRelation = "child", flags = { "knows_wings" } },
		dialogue = {
			{ who = "{child}", line = "It's only a form. I'll visit. They can't check everything." },
		},
		choices = {
			{
				label = "Sign the waiver",
				result = { sanity = -6, relationBond = { kind = "child", amount = 6 }, setFlags = { "ad_waiver_signed" }, log = "You signed in your best hand. {child} moved inside the wall and visited twice that year, in disguise, which was mostly a hat." },
			},
			{
				label = "Refuse to sign",
				result = { sanity = 2, relationBond = { kind = "child", amount = -12 }, log = "Without the waiver the offer lapsed. {child} took a Backstreets job and didn't speak to you until spring." },
			},
			{
				label = "Sign with a false address",
				clash = { stat = "mind", foe = "A Wing's paperwork", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 3, relationBond = { kind = "child", amount = 10 }, log = "You signed as your own landlord, at a flat that doesn't exist. Nobody checked. {child} visits every Sunday." },
				lose = { money = { -150, -80 }, sanity = -6, relationBond = { kind = "child", amount = -4 }, log = "The Wing checked. It fined you both and gave {child} the job anyway, on probation, with a note on file." },
			},
		},
	},
	{
		id = "ad_l_child_middle",
		title = "A New Big Sister",
		art = "home",
		text = "{child} comes home with a fresh Middle tattoo on their wrist and a new way of saying \"family\". Behind them on the landing stands Big Sister Renata.",
		weight = 7,
		once = true,
		when = { minAge = 40, maxAge = 60, hasRelation = "child", flags = { "knows_middle" } },
		codex = "fn_lore_middle",
		dialogue = {
			{ who = "ad_renata", line = "Your child has joined my family. That makes you family's family. We look after those." },
			{ who = "{child}", line = "It's done. You can be angry or you can come to dinner." },
		},
		choices = {
			{
				label = "Go to dinner",
				result = { sanity = 2, relationBond = { kind = "child", amount = 10 }, setFlags = { "ad_middle_family" }, log = "The Middle cooks enormous meals and remembers every birthday. Your name went into the other book, the one for gifts." },
			},
			{
				label = "Ask Renata to let them go",
				clash = { stat = "mind", foe = "Big Sister Renata", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, relationBond = { kind = "child", amount = -6 }, log = "\"Family doesn't hold anyone,\" Renata said, and released {child} with a bow. {child} took a month to forgive you." },
				lose = { sanity = -6, condition = "in_the_book", log = "\"You don't take family from family,\" she said gently, and wrote your name down, in the first book." },
			},
			{
				label = "Say nothing and watch",
				result = { sanity = -4, log = "{child} brought Little Siblings home on Sundays. They were polite and always hungry, and called you Elder Sibling." },
			},
		},
	},
	{
		id = "ad_l_amparo_kid",
		title = "The Other Parent",
		art = "home",
		text = "{child} knocked Jefe Amparo's nephew into the canal over a parking space for a cart. Now Amparo is at your kitchen table, turning your sugar bowl round and round.",
		weight = 8,
		once = true,
		tags = { "crime" },
		when = { minAge = 38, maxAge = 58, side = "backstreets", hasRelation = "child", flags = { "knows_syndicates" } },
		dialogue = {
			{ who = "ad_amparo", line = "Children. What can you do. Well. There are several things I can do. I'm here to see which one you'd like." },
		},
		choices = {
			{
				label = "Pay for his coat",
				result = { money = { -120, -80 }, sanity = -2, log = "You paid for the coat and the canal cleaning, and wrote an apology. Amparo had the apology framed." },
			},
			{
				label = "Make {child} apologize",
				result = { sanity = 1, relationBond = { kind = "child", amount = -10 }, log = "{child} apologized to the nephew through gritted teeth. He accepted through his. Amparo looked pleased with everyone." },
			},
			{
				label = "Say the nephew started it",
				clash = { stat = "mind", foe = "Amparo, who loves her nephew", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, relationBond = { kind = "child", amount = 8 }, log = "You had three witnesses from the cart rank. Amparo heard them out, then went home and had a word with her nephew, a loud one." },
				lose = { money = { -200, -120 }, sanity = -4, setFlags = { "ad_hounds_defied" }, log = "Your witnesses remembered differently once Amparo smiled at them. Your fee doubled for the year." },
			},
		},
	},

	-- ── debts ──
	{
		id = "ad_l_cosign",
		title = "Co-Signer",
		art = "office",
		text = "{sibling} wants to open a noodle stall, and the lender wants a second name on the paper. The lender is a Fixer Office that does collections. Its sign is a hook.",
		weight = 9,
		once = true,
		when = { minAge = 30, maxAge = 50, hasRelation = "sibling" },
		choices = {
			{
				label = "Co-sign",
				result = { relationBond = { kind = "sibling", amount = 10 }, setFlags = { "ad_cosigned" }, schedule = { event = "ad_l_cosign_due", inYears = 3 }, log = "You signed under {sibling}'s name. The stall opened in spring. The broth was thin and the queue was long." },
			},
			{
				label = "Lend it yourself, no paper",
				hint = "300 Ahn.",
				requires = { min = { money = 300 } },
				result = { money = -300, relationBond = { kind = "sibling", amount = 12 }, log = "You lent it yourself. The stall lasted two years. {sibling} paid back a hundred, and noodles for life." },
			},
			{
				label = "Refuse",
				result = { relationBond = { kind = "sibling", amount = -12 }, log = "You said no. {sibling} found another name, a cousin's. The stall opened anyway. The cousin stopped coming to dinner." },
			},
		},
	},
	{
		id = "ad_l_cosign_due",
		title = "The Hook Office",
		art = "home",
		text = "{sibling}'s stall closed in winter, and {sibling} took the WARP somewhere and stopped answering letters. The Hook Office has your name on the paper and a Fixer at your door.",
		weight = 0,
		when = { hasRelation = "sibling", flags = { "ad_cosigned" } },
		dialogue = {
			{ who = "fixer", line = "Six hundred, or the equivalent. We're flexible about the equivalent. Not about the six hundred." },
		},
		choices = {
			{
				label = "Pay it",
				hint = "600 Ahn.",
				requires = { min = { money = 600 } },
				result = { money = -600, sanity = -3, clearFlags = { "ad_cosigned" }, relationBond = { kind = "sibling", amount = -10 }, log = "You paid. A year later {sibling} sent a postcard from District 16, no return address, with a noodle bowl drawn on it." },
			},
			{
				label = "Fight the collector",
				clash = { stat = "strength", foe = "A Hook Office collector", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "fixer", status = { id = "bleed", potency = 2 } },
				win = { strength = 3, sanity = -3, clearFlags = { "ad_cosigned" }, setFlags = { "ad_hook_feud" }, log = "He left without the six hundred, limping. The Hook Office added his clinic bill to the debt and wrote to say so." },
				lose = { health = { -18, -8 }, money = { -400, -250 }, sanity = -5, clearFlags = { "ad_cosigned" }, cause = "Fought a Hook Office collector", log = "He collected the equivalent. The equivalent was most of what was in your flat." },
			},
			{
				label = "Give them the postmark",
				result = { sanity = -10, clearFlags = { "ad_cosigned" }, relationBond = { kind = "sibling", amount = -40 }, log = "You'd had a postcard. You gave the Hook Office the postmark, and they thanked you. {sibling} never sent another." },
			},
		},
	},
	{
		id = "ad_l_dieci_sale",
		title = "Knowledge for Sale",
		art = "market",
		text = "A Dieci Fixer with a ring of keys on her belt is buying knowledge for her Association, cash down. You know your trade better than anyone, and you owe money.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 60, flags = { "knows_fixers" } },
		codex = "fx_lore_dieci",
		dialogue = {
			{ who = "The Dieci Fixer", line = "I take it, you forget it. Everything you know about your work, for five hundred Ahn. Clean. No pain." },
		},
		choices = {
			{
				label = "Sell your trade",
				result = { money = 500, intelligence = -6, condition = "fx_knowledge_spent", log = "She touched a key to your forehead. Next morning you stood at your bench holding a tool, wondering what it was for." },
			},
			{
				label = "Sell her something smaller",
				clash = { stat = "mind", foe = "A buyer who knows value", coins = 2, base = 4, coinPower = 3 },
				win = { money = 180, sanity = -2, log = "You sold her the way your mother walked you to school. You can't remember it now. There was a bakery on it, you're told." },
				lose = { money = 60, condition = "fx_knowledge_spent", log = "She took more than you meant to sell. You can't recall the street you grew up on. Sixty Ahn." },
			},
			{
				label = "Keep what you know",
				result = { sanity = 2, log = "You kept it, and paid your debts the slow way, with your hands, knowing exactly what they were doing." },
			},
		},
	},
	{
		id = "ad_l_wing_letter",
		title = "Reduction",
		art = "wing",
		text = "The letter thanks you for your years as a Feather and ends your Nest residence in thirty days. Page two: keep your post if you name one colleague for reduction instead.",
		weight = 10,
		once = true,
		when = { minAge = 35, maxAge = 55, side = "nest", career = "wing" },
		codex = "fc_lore_feathers",
		choices = {
			{
				label = "Take the severance",
				result = { quitCareer = true, side = "backstreets", money = 400, sanity = -5, log = "Four hundred Ahn and thirty days. You moved to the Backstreets with two suitcases, and your badge went in a drawer." },
			},
			{
				label = "Name a colleague",
				result = { sanity = -12, setFlags = { "ad_named_colleague" }, log = "You wrote down a name. Her desk was next to yours. She cleared it on Friday and wished you luck, and meant it." },
			},
			{
				label = "Appeal to your Director",
				clash = { stat = "charisma", foe = "A Director with a quota", coins = 3, base = 5, coinPower = 3 },
				win = { charisma = 3, sanity = 2, log = "You showed him the numbers he'd never read. He kept you, and cut the department's flowers instead." },
				lose = { quitCareer = true, side = "backstreets", money = 200, sanity = -6, log = "The appeal took the thirty days. You left with half the severance and a letter thanking you for your enthusiasm." },
			},
		},
	},
	{
		id = "ad_l_kurokumo_rent",
		title = "The Fifth Raise",
		art = "street",
		text = "The Kurokumo Clan raised the protection fee on your street for the fifth year running. A Blade Lineage swordsman in a battered coat offers to make the Clan go away, for one meal a day, forever.",
		weight = 8,
		once = true,
		tags = { "crime" },
		when = { minAge = 35, maxAge = 60, anyCareer = true, flags = { "knows_fingers" } },
		codex = "fn_lore_blade_lineage",
		dialogue = {
			{ who = "The Swordsman", line = "One meal a day. I eat a lot. The Clan will come back with more swords. I like that part." },
		},
		choices = {
			{
				label = "Feed the swordsman",
				result = { money = { -60, -30 }, sanity = 2, setFlags = { "ad_salsu_fed" }, schedule = { event = "ad_l_clan_returns", inYears = 1 }, log = "He ate like three people and slept on the bench outside. The Clan's collector took one look at him and went away to think." },
			},
			{
				label = "Pay the Clan",
				result = { money = { -120, -80 }, sanity = -3, log = "You paid the fifth raise. The swordsman shrugged and offered his deal to the bakery, which took it." },
			},
			{
				label = "Sell him to the Clan",
				result = { money = 200, sanity = -8, log = "You told the Clan where he slept. They paid two hundred. He was gone by morning, and so was the bench." },
			},
		},
	},
	{
		id = "ad_l_clan_returns",
		title = "More Swords",
		art = "street",
		text = "The Kurokumo come back with six swords and a Captain. Your swordsman is on his bench finishing breakfast, and he looks delighted.",
		weight = 0,
		tags = { "crime" },
		when = { flags = { "ad_salsu_fed" } },
		dialogue = {
			{ who = "The Swordsman", line = "Finally. Stand behind me. No, beside me. It's more fun beside." },
			{ who = "kurokumo", line = "Old man. You've been eating on Clan ground." },
		},
		choices = {
			{
				label = "Stand beside him",
				clash = { stat = "strength", foe = "A Kurokumo Captain and his Wakashu", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "kurokumo", status = { id = "bleed", potency = 3 } },
				win = { strength = 4, money = { 100, 250 }, setFlags = { "ad_clan_gone" }, log = "It was over before your noodles went cold. The Clan never came back to your street. The swordsman wanted a second breakfast." },
				lose = { health = { -24, -12 }, sanity = -6, cause = "Stood with a swordsman against the Clan", log = "The swordsman won. You were part of what he had to step over to do it." },
			},
			{
				label = "Watch from the window",
				result = { sanity = -4, log = "It was short. Afterwards he knocked on your door and asked for his meal, with a bow." },
			},
			{
				label = "Run out with the back fees",
				result = { money = { -200, -120 }, sanity = -2, log = "You paid the Captain in the street. He sheathed his sword. The swordsman never ate your food again." },
			},
		},
	},
	{
		id = "ad_l_rival_office",
		title = "Your Rival's Sign",
		art = "office",
		text = "{rival}'s Fixer Office went under this quarter after one bad contract and a Hana audit. {rival} is at your door with the Office sign under their arm.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 55, hasRelation = "rival", flags = { "knows_fixers" } },
		dialogue = {
			{ who = "{rival}", line = "Don't. Don't say anything clever. I need work, and you're the only person who won't pretend to be sorry." },
		},
		choices = {
			{
				label = "Give them work",
				result = { sanity = 3, relationBond = { kind = "rival", amount = 20 }, log = "You put them to work at half the pay they'd have taken from anyone else. They were better at it than you. Neither of you said so." },
			},
			{
				label = "Buy the sign",
				hint = "100 Ahn.",
				requires = { min = { money = 100 } },
				result = { money = -100, relationBond = { kind = "rival", amount = -10 }, log = "You bought the sign for a hundred Ahn. It hangs in your hall. {rival} says hello to it out loud every time they pass." },
			},
			{
				label = "Shut the door",
				result = { sanity = -3, relationBond = { kind = "rival", amount = -15 }, log = "You shut the door. Through it, {rival} laughed, a real laugh. \"Good,\" they said. \"I'd have done the same.\"" },
			},
		},
	},

	-- ── the Head's Arbiters and Claws (rare) ──
	{
		id = "ad_l_arbiter_street",
		title = "Everyone Kneels",
		art = "street",
		text = "At noon the street goes silent: a woman in a long white coat is walking down the middle of it, and everyone she passes kneels. She stops in front of you.",
		weight = 3,
		once = true,
		when = { minAge = 30, maxAge = 70 },
		codex = "dz_lore_claws",
		dialogue = {
			{ who = "The Arbiter", line = "I'm looking for the Workshop with the green door. I'm told it repairs things that talk." },
		},
		choices = {
			{
				label = "Point the way",
				result = { sanity = -12, setFlags = { "dz_claw_witness" }, chronicle = "dz_act_claw_witness", log = "You pointed. She thanked you. By evening the green door was a brick wall, and nobody on the street had ever had a radio fixed there." },
			},
			{
				label = "Point the wrong way",
				clash = { stat = "mind", foe = "An Arbiter of the Head", coins = 4, base = 7, coinPower = 4 },
				win = { mind = 4, sanity = -10, addTrait = "dz_dread_calm", setFlags = { "dz_claw_witness" }, log = "She looked at you a long time and went the way you'd pointed. At the corner she turned, and came back the right way anyway." },
				lose = { die = "Lied to an Arbiter", log = "She didn't go the way you pointed." },
			},
			{
				label = "Say you don't know",
				clash = { stat = "mind", foe = "An Arbiter's patience", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -6, setFlags = { "dz_claw_witness" }, log = "\"Thank you anyway,\" she said, and asked the next person on their knees. By evening the green door was a brick wall." },
				lose = { sanity = -12, condition = "dz_terror", log = "\"You do know,\" she said, and touched your forehead with one finger. You told her everything, including things she hadn't asked." },
			},
		},
	},
	{
		id = "ad_l_claw_teahouse",
		title = "The Only Free Seat",
		art = "diner",
		text = "The teahouse is full, so a man in a long black coat sits at your table, and the room goes very still. {friend} is at the table by the window.",
		weight = 3,
		once = true,
		when = { minAge = 35, maxAge = 75, hasRelation = "friend" },
		codex = "dz_lore_erased",
		dialogue = {
			{ who = "The Claw", line = "Don't stand up. It draws attention." },
			{ who = "The Claw", line = "I'm here for the one by the window. You'll want to finish your tea first." },
		},
		choices = {
			{
				label = "Finish your tea",
				result = { sanity = -15, killRelation = "friend", setFlags = { "dz_claw_witness" }, chronicle = "dz_act_claw_witness", log = "When you looked up, the window table was empty and freshly wiped. Nobody else in the room remembered who had sat there." },
			},
			{
				label = "Knock the teapot over",
				clash = { stat = "strength", foe = "A Claw's reflexes", coins = 4, base = 7, coinPower = 4 },
				win = { strength = 4, sanity = -10, addTrait = "dz_dread_calm", setFlags = { "dz_claw_witness" }, log = "Tea everywhere. {friend} looked up at the coat and went out through the kitchen. The Claw sighed and paid for both teas." },
				lose = { die = "Got in the way of the Head's work", log = "The teapot never reached the floor." },
			},
			{
				label = "Leave without looking",
				result = { sanity = -10, killRelation = "friend", setFlags = { "dz_claw_witness" }, log = "You left your tea and walked out without looking at the window. You never went back to that teahouse." },
			},
		},
	},
	{
		id = "ad_l_claw_signs",
		title = "The Old Street Names",
		art = "street",
		text = "The District renamed every street on your block last year. Today two people in long coats are taking the old enamel signs off the walls and asking the oldest residents what they remember.",
		weight = 3,
		once = true,
		when = { minAge = 55 },
		codex = "dz_lore_taboos",
		dialogue = {
			{ who = "The Claw", line = "This street was never called Lantern Row. Please say so aloud. It helps." },
		},
		choices = {
			{
				label = "Say it was never Lantern Row",
				result = { sanity = -8, log = "You said it aloud. They thanked you and moved on to the next old person. By winter you weren't sure yourself." },
			},
			{
				label = "Say \"Lantern Row\"",
				clash = { stat = "strength", foe = "Two Claws and a list", coins = 3, base = 6, coinPower = 4 },
				win = { strength = 3, sanity = -6, addTrait = "dz_dread_calm", setFlags = { "dz_claw_witness" }, log = "\"Lantern Row,\" you said. The Claw looked at you for a while, then wrote something down. You keep one of the signs under your bed." },
				lose = { die = "Remembered the wrong street name", log = "They took your sign down too." },
			},
			{
				label = "Pretend to be deaf",
				clash = { stat = "intelligence", foe = "A Claw who has met deaf people", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -4, log = "You smiled and cupped your ear until they moved on. Your neighbor answered for you. She still talks about the street that never was." },
				lose = { sanity = -10, condition = "dz_terror", log = "\"You heard the question,\" she said. \"Everyone hears the question.\" You answered it." },
			},
		},
	},

	-- ── 50 and over ──
	{
		id = "ad_l_old_bones",
		title = "Old Bones",
		art = "market",
		text = "Two young Rats follow you out of the market, laughing about your bag and your knees. They think you're easy. Thirty years ago you'd have thought so too.",
		weight = 8,
		cooldown = 10,
		tags = { "danger", "backstreets" },
		when = { minAge = 50, maxAge = 75, side = "backstreets", flags = { "knows_syndicates" } },
		choices = {
			{
				label = "Hand them the bag",
				result = { money = { -60, -30 }, sanity = -3, log = "You handed it over. They were disappointed by the cabbages. One of them said sorry, which was new." },
			},
			{
				label = "Show them what old means",
				clash = { stat = "strength", foe = "Two young Rats", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "rat", status = { id = "bleed", potency = 1 } },
				win = { strength = 2, money = { 40, 80 }, sanity = 4, log = "The first one learned about your walking stick. The second ran. The stallholders clapped and gave you a free cabbage." },
				lose = { health = { -14, -6 }, sanity = -5, cause = "Stood up to Rats in old age", log = "Your knees were older than your temper. They took the bag and left you sitting on the curb." },
			},
			{
				label = "Whistle for the watch",
				clash = { stat = "mind", foe = "A whistle code forty years old", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 2, log = "You knew the watch's old whistle code. So did the watch. The Rats were gone in a minute." },
				lose = { money = { -60, -30 }, sanity = -4, log = "The watch had changed its code. Nobody came. The Rats took the bag, laughing." },
			},
		},
	},
	{
		id = "ad_l_young_fixer",
		title = "Your Old Name",
		art = "arena",
		text = "A Grade 7 Fixer half your age has heard you were good once. She wants to fight you in front of witnesses, because beating an old name looks good in a report.",
		weight = 8,
		once = true,
		when = { minAge = 50, maxAge = 70, flags = { "knows_fixers" }, min = { strength = 45 } },
		codex = "fx_lore_reports",
		dialogue = {
			{ who = "The Young Fixer", line = "Nothing personal. Hana reads reports. Yours would say retired. Mine would say promoted." },
		},
		choices = {
			{
				label = "Fight her",
				clash = { stat = "strength", foe = "A Grade 7 who wants a story", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "fixer", status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = { 60, 140 }, sanity = 4, log = "You put her on the ground in front of her own witnesses. She asked you to sign her report anyway. You signed it generously." },
				lose = { health = { -18, -8 }, sanity = -6, cause = "Fought a young Fixer for an old name", log = "She won, very graciously. She called you 'formidable' in her report, which was worse." },
			},
			{
				label = "Give her an old report to cite",
				result = { mind = 2, sanity = -2, log = "You gave her your best old report and told her to put your name in hers. She made Grade 6, and sends a card every board day." },
			},
			{
				label = "Refuse, loudly",
				result = { sanity = -4, log = "You refused. She called you a coward in front of the noodle stall. You went home and slept very well." },
			},
		},
	},
	{
		id = "ad_l_last_lease",
		title = "Thirty Years in 4B",
		art = "home",
		text = "You've lived in the same flat for thirty years. Mr. Pask's son has inherited the building, and he wants it empty by spring.",
		weight = 8,
		once = true,
		tags = { "backstreets" },
		when = { minAge = 55, side = "backstreets" },
		dialogue = {
			{ who = "Young Mr. Pask", line = "Six hundred to go quietly. My father always said you were his best tenant. That's why the offer's so high." },
		},
		choices = {
			{
				label = "Take the money",
				result = { money = 600, sanity = -6, log = "You took the six hundred and a room by the WARP depot. The new tenants painted over the height marks on the kitchen door." },
			},
			{
				label = "Fight the eviction",
				clash = { stat = "mind", foe = "A landlord's lawyer", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = 5, log = "Thirty years of rent receipts in a shoebox. The tribunal let you stay for life. Young Pask sends you a calendar every year, furious." },
				lose = { money = { -150, -80 }, sanity = -8, log = "You lost, and the move cost more than his six hundred would have. You took the height marks with you, on tracing paper." },
			},
			{
				label = "Ask for the basement flat",
				result = { money = { -40, -20 }, sanity = 2, log = "You moved down to the smallest flat in the building. Young Pask was so relieved he halved the rent. You hear the street better now." },
			},
		},
	},
	{
		id = "ad_l_ego_old",
		title = "It Doesn't Get Older",
		art = "home",
		text = "Your E.G.O hasn't aged a day, and your knees feel twice your age. Some mornings it gets up before you do, and you have to catch up with yourself.",
		weight = 9,
		once = true,
		when = { minAge = 50, form = "ego" },
		codex = "terms_ego",
		dialogue = {
			{ who = "Your E.G.O", line = "Let me do the stairs. Let me do the street. You can rest inside me. It's warm in here." },
		},
		choices = {
			{
				label = "Let it carry you",
				result = { health = 6, strength = 2, sanity = -8, log = "You let it do the stairs. Then the street. Then most things. The neighbors say you look wonderful. You're mostly asleep." },
			},
			{
				label = "Make it walk at your pace",
				clash = { stat = "mind", foe = "Yourself, younger", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = 5, log = "You told it to walk at your pace. It sulked, then matched you step for step, all the way to the market." },
				lose = { sanity = -6, condition = "distortion_signs", log = "It didn't wait. You found yourself at the top of the stairs with no memory of climbing them." },
			},
			{
				label = "Fold it away for good",
				result = { health = -4, strength = -2, sanity = 3, log = "You folded it away inside you like a good coat in summer. Your knees hurt more. Your dreams got quieter." },
			},
		},
	},
	{
		id = "ad_l_mentor_blade",
		title = "The Last Lesson",
		art = "workshop",
		text = "{mentor} is very old now and can't lift the blade they taught you with. They want it taken to a Workshop and broken, so nobody uses it badly.",
		weight = 9,
		once = true,
		when = { minAge = 50, hasRelation = "mentor" },
		dialogue = {
			{ who = "{mentor}", line = "Broken. I know you. You'll want to keep it. That's the last lesson: don't." },
		},
		choices = {
			{
				label = "Have it broken",
				result = { mind = 2, sanity = 3, relationBond = { kind = "mentor", amount = 10 }, log = "The smith broke it over the anvil in three pieces. You brought {mentor} the hilt. They held it like a hand." },
			},
			{
				label = "Keep it",
				result = { strength = 2, sanity = -3, relationBond = { kind = "mentor", amount = -10 }, log = "You told {mentor} it was done. It's wrapped in oilcloth in your wardrobe. You were always a bad student." },
			},
			{
				label = "Give it to a young Fixer",
				result = { sanity = 1, log = "You gave it to a Grade 9 with good hands and no money. She uses it well. {mentor} never found out. Probably." },
			},
		},
	},
	{
		id = "ad_l_will",
		title = "Who Gets the Keys",
		art = "office",
		text = "Your apprentice, your landlord's son and the Copper Hounds each want the keys to your shop when you're gone. A notary is waiting with three blank lines.",
		weight = 8,
		once = true,
		when = { minAge = 55, career = { "workshop", "diner", "clinic" } },
		choices = {
			{
				label = "Leave it to your apprentice",
				result = { sanity = 4, log = "You wrote her name in large letters. She cried, then asked how to bank the stove properly. You showed her." },
			},
			{
				label = "Sell it to the Hounds now",
				result = { money = { 500, 800 }, sanity = -6, log = "The Hounds paid well and early. They kept your sign over the door, and that was the worst part." },
			},
			{
				label = "Leave it to the street",
				result = { strength = 2, sanity = 3, log = "You left the keys to the street committee with rules about prices and closing by one. They ignored half the rules and kept the rest forever." },
			},
		},
	},
	{
		id = "ad_l_see_once",
		title = "Just Once",
		art = "night",
		text = "You're past sixty and have never seen a Sweeper. Tonight you've pulled a chair up to the window at 3:10, with the curtain open a finger's width.",
		weight = 7,
		once = true,
		tags = { "backstreets" },
		when = { minAge = 60, side = "backstreets", flags = { "knows_night" }, notFlags = { "bs_night_survivor" } },
		codex = "city_sweepers",
		choices = {
			{
				label = "Keep watching",
				clash = { stat = "mind", foe = "The first wave", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = -4, log = "You saw it. It didn't see you. You let the curtain fall at 3:14 and sat in the dark, smiling a little, which frightened you more." },
				lose = { sanity = -10, condition = "night_terrors", log = "It stopped under your window and turned its head up, slowly. You were in bed before you knew you'd moved." },
			},
			{
				label = "Close the curtain",
				result = { sanity = 2, log = "You closed it at 3:12 and went to bed, and slept like a child." },
			},
		},
	},
	{
		id = "ad_l_kid_at_window",
		title = "The Kid at the Window",
		art = "street",
		text = "A street kid has watched you work through the shop window every afternoon for a month. Today she's brought her own tools: a bent spoon and a borrowed screwdriver.",
		weight = 8,
		once = true,
		when = { minAge = 50, career = { "workshop", "diner", "clinic" } },
		choices = {
			{
				label = "Let her in and teach her",
				clash = { stat = "intelligence", foe = "Forty years of habits to explain", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, sanity = 5, log = "You taught her everything you'd been doing wrong for forty years first, so she wouldn't. She was faster than you by winter." },
				lose = { sanity = 2, log = "You were a terrible teacher. She learned anyway, mostly by watching you get it wrong." },
			},
			{
				label = "Give her your old tools",
				result = { money = { -40, -20 }, sanity = 4, log = "You gave her your first set, wrapped in a rag. She ran off without saying thank you. She came back to say it a year later." },
			},
			{
				label = "Pull the blind down",
				result = { sanity = -3, log = "You pulled the blind. She came back for a week, then stopped. The blind stayed down." },
			},
		},
	},

	-- ── short ones ──
	{
		id = "ad_l_tx_bow",
		title = "The Kids Don't Bow",
		art = "street",
		text = "Teenagers walk past the Thumb Soldato on your corner without bowing, laughing. The Soldato is about nineteen. He doesn't know what to do either.",
		weight = 6,
		once = true,
		when = { minAge = 50, flags = { "knows_thumb" } },
		result = { sanity = 2, log = "You bowed to him, properly, for all of them. He looked so relieved you nearly laughed." },
	},
	{
		id = "ad_l_tx_ten_seconds",
		title = "Ten Seconds",
		art = "rooftop",
		text = "You've lived under the WARP rail all your life. Today, for the first time, you count how long a train takes to cross the sky. Ten seconds. A whole City, in the time it takes to find your keys.",
		weight = 6,
		once = true,
		when = { minAge = 55 },
		result = { sanity = 2, log = "You waved at it, the way children do. Nobody waved back. The blinds are always down." },
	},
	{
		id = "ad_l_tx_ledger",
		title = "Retired, Grade Unchanged",
		art = "office",
		text = "Hana's new board lists you as RETIRED in small grey type, below the living. An envelope from the Association holds your license, stamped through with a neat hole.",
		weight = 7,
		once = true,
		when = { minAge = 55, career = "none", flags = { "licensed_fixer" } },
		codex = "fixers_hana",
		result = { sanity = 3, log = "You pinned the license over the stove, hole and all. Young Fixers who come by for advice always look at the hole first." },
	},
}
