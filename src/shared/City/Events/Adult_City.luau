--[[
	Adult life in the City, mostly ages 18-35 (ad_c_). Talking scenes, checks, fights and
	follow-ups. Faction content is gated by the knows_ flags (docs/V08_SPEC.md).
	Faces: Cast/Adults.luau.

	Chains:
		ad_c_witness -> (2y) ad_c_witness_audit                Dalia's report, Hana's Assessor
		ad_c_hounds_arrive -> (1y) ad_f_hounds_visit            the Copper Hounds (Adult_Fights)
		ad_c_collector_kid -> (10y) ad_l_tomas_grown            Tomas, short this week (Adult_Late)
		ad_c_blade_offer -> (1y) ad_c_blade_hum -> ad_c_blade_back / ad_c_blade_sister
		ad_c_warp_job -> (1y) ad_c_warp_letter                  fourteen lines on a window
		ad_c_hedda_washing -> ad_c_hedda_sheets -> ad_c_hedda_white   a neighbor Distorts
		ad_c_imre_window -> (1y) ad_f_clan_window               (Adult_Fights)
		ad_c_kcorp_trial -> (2y) ad_c_kcorp_scar
		ad_c_rcorp_sibling -> (2y) ad_c_rcorp_home
		ad_c_prescript_door -> ad_c_prescript_night, or (1y) ad_c_proxies
		ad_c_prescript_sleep -> (1y) ad_c_fourteenth (+ ad_c_proxies if you woke them)
		ad_c_middle_laugh -> ad_c_middle_errand / ad_c_middle_book
		ad_c_thumb_credit -> (3y) ad_c_thumb_ledger
		ad_c_bf_invite -> ad_c_bf_dinner -> (1y) ad_c_bf_rudeness
		ad_c_platform_kid -> ad_l_raising_rules / _card / _late (Adult_Late)

	Flags others can reuse:
		ad_dalia_trust, ad_dalia_owes, ad_dalia_burned   how the Halfmoon Office sees you
		ad_hounds_paid, ad_hounds_defied                 the Copper Hounds' ledger
		ad_blade_owned                                   you own the Cinderbell blade
		ad_warp_rider                                    you rode a DELAYED WARP train
		ad_hedda_saved, ad_hedda_lost                    the laundress across the landing
		ad_middle_owes, ad_middle_done, ad_in_book       you and Big Sister Renata
		ad_ashgrave_friend, ad_ashgrave_insulted         the Ashgrave Family (Bloodfiends)
		ad_raising                                       you took in the girl from Platform Six
	Shared flags set here: fn_owes_thumb, thumb_respect, fn_thumb_disrespected, bf_knows,
	kept_invitation, lim_talked_down, lim_lccb_contact, lc_ego_lament, knows_wings, knows_lcorp.
]]

local AFTER = { era = { "library", "limbus" } }
local LIMBUS = { era = "limbus" }
local L_CORP_YEARS = { era = "wings" }

return {
	-- ── the Halfmoon Office: hired, even if you're not a Fixer ──
	{
		id = "ad_c_witness",
		title = "An Unaffiliated Witness",
		art = "office",
		text = "Hana won't file a job report without a signature from someone outside the Office. The Halfmoon Office's Rep has the report written already, and a pen held out.",
		weight = 10,
		once = true,
		tags = { "fixers" },
		when = { minAge = 18, maxAge = 34, flags = { "knows_fixers" } },
		codex = "fx_lore_reports",
		dialogue = {
			{ who = "ad_dalia", line = "Sign where it says witness. Ninety Ahn, and you never saw my face." },
			{ who = "ad_dalia", line = "It says Pim closed the contract. I did. He needs the grade more than I need the credit." },
		},
		choices = {
			{
				label = "Sign it",
				result = { money = 90, sanity = -3, setFlags = { "ad_signed_false", "ad_dalia_owes" }, schedule = { event = "ad_c_witness_audit", inYears = 2 }, log = "You signed. Pim made Grade 8 that quarter and bought the whole Office noodles. Dalia didn't eat hers." },
			},
			{
				label = "Write down what you saw",
				clash = { stat = "mind", foe = "Dalia's patience", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, money = 40, setFlags = { "ad_dalia_trust" }, log = "You wrote it straight. Dalia read it twice and paid you anyway. \"Hana will believe this one,\" she said. \"Annoying.\"" },
				lose = { sanity = -4, setFlags = { "ad_dalia_burned" }, log = "She tore your page in half and found a witness who read less carefully. Her Office stopped saying hello." },
			},
			{
				label = "Give the pen back",
				result = { sanity = 1, log = "You gave the pen back. She found a signature in the noodle queue within ten minutes, for forty Ahn." },
			},
		},
	},
	{
		id = "ad_c_witness_audit",
		title = "The Assessor's Questions",
		art = "office",
		text = "Pim died on his first Grade 8 contract. Hana's Assessor has your signature on the report that promoted him, and a second chair pulled out.",
		weight = 0,
		when = { flags = { "ad_signed_false" } },
		codex = "fixers_hana",
		dialogue = {
			{ who = "ad_imre", line = "You witnessed this closure. Describe the Fixer who closed it. Height will do, to begin." },
			{ who = "ad_imre", line = "Take your time. Hana has a great deal of it." },
		},
		choices = {
			{
				label = "Describe Pim",
				clash = { stat = "mind", foe = "An Assessor who reads faces", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = -4, setFlags = { "ad_dalia_owes" }, log = "You described a boy you'd met twice. Imre wrote it all down. The Halfmoon Office kept its license." },
				lose = { money = { -250, -150 }, sanity = -6, setFlags = { "ad_hana_liar" }, log = "Imre stopped writing halfway through your answer. The fine came on Hana letterhead, with a second page about lying." },
			},
			{
				label = "Tell her Dalia closed it",
				result = { strength = 2, sanity = -2, setFlags = { "ad_dalia_burned" }, clearFlags = { "ad_dalia_owes" }, log = "Hana suspended the Halfmoon Office for a year. Dalia passed you in the street and didn't look away. That was worse." },
			},
			{
				label = "Say you don't remember",
				result = { money = { -80, -40 }, sanity = -5, log = "\"Then your signature is worth nothing,\" Imre said, and charged you a filing fee for the wasted form." },
			},
		},
	},
	{
		id = "ad_c_muscle",
		title = "Stand Behind Me",
		art = "syndicate",
		text = "Dalia is collecting a debt from a Syndicate boss tonight, at his own table. She needs a body behind her chair that looks like it might do something.",
		weight = 10,
		once = true,
		tags = { "fixers", "crime" },
		when = { minAge = 18, maxAge = 35, flags = { "knows_fixers", "knows_syndicates" } },
		dialogue = {
			{ who = "ad_dalia", line = "Stand. Don't talk. If he reaches under the table, you're not furniture anymore." },
			{ who = "The Syndicate Boss", line = "Who's the coat rack? New hire? They look nervous. I like nervous." },
		},
		choices = {
			{
				label = "Stand still and look large",
				clash = { stat = "health", foe = "Two hours of being stared at", coins = 2, base = 4, coinPower = 3 },
				win = { health = 2, money = 120, log = "Two hours and one cramp, without a word. The debt was paid in full. Dalia said you had a good face for standing." },
				lose = { sanity = -5, money = 40, log = "Your knee started shaking in the first hour and the whole table watched it. Dalia paid you a third." },
			},
			{
				label = "Move when he reaches",
				clash = { stat = "strength", foe = "A Syndicate enforcer", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "syndicate", status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = 200, setFlags = { "ad_dalia_trust" }, log = "His hand never cleared the table. Dalia finished her sentence without turning round, then doubled your fee." },
				lose = { health = { -14, -6 }, sanity = -5, cause = "Stood behind the wrong chair", log = "He was faster than you. Dalia settled the debt over your head, as it turned out." },
			},
			{
				label = "Sell her terms to the boss",
				result = { money = 150, sanity = -5, setFlags = { "ad_dalia_burned" }, log = "The boss knew her number before she said it. Dalia worked out why by the second hour. She never said your name again." },
			},
		},
	},
	{
		id = "ad_c_bait",
		title = "Bait",
		art = "alley",
		text = "Rats have been robbing late walkers on Ninth Street. The Halfmoon Office needs someone who looks like easy money to walk it at one in the morning. They say they'll be close.",
		weight = 9,
		once = true,
		tags = { "fixers", "danger" },
		when = { minAge = 18, maxAge = 32, side = "backstreets", flags = { "knows_fixers", "knows_syndicates" } },
		choices = {
			{
				label = "Walk it",
				clash = { stat = "strength", foe = "A Rat boss and his pack", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "rat_boss", status = { id = "tremor", potency = 2 } },
				win = { strength = 3, money = 180, log = "Dalia's Fixers came out of the doorways on time, mostly. You kept the Rat boss's sledge as a souvenir." },
				lose = { health = { -18, -8 }, sanity = -4, cause = "Walked Ninth Street as bait", log = "The Fixers were close. Close is a long way at one in the morning." },
			},
			{
				label = "Walk it, run at the first shadow",
				clash = { stat = "speed", foe = "Ninth Street at one", coins = 2, base = 4, coinPower = 3 },
				win = { money = 80, sanity = -2, log = "You ran at the first shadow and led the pack straight into Dalia's doorway. Half the fee, all your teeth." },
				lose = { health = { -10, -4 }, sanity = -3, cause = "Ran from Rats on Ninth Street", log = "You ran at the first shadow. There was a second shadow." },
			},
			{
				label = "Tell her to send her junior",
				result = { sanity = -4, log = "She sent a kid from the Office called Lark. He came back with a split lip and the sledge, and asked why you'd said no." },
			},
		},
	},

	-- ── the Copper Hounds: turf and protection money ──
	{
		id = "ad_c_hounds_arrive",
		title = "New Owners",
		art = "street",
		text = "The old Syndicate's marks on your street have been painted over in copper. A woman with a pipe over her shoulder is going door to door with a ledger.",
		weight = 11,
		once = true,
		tags = { "crime", "backstreets" },
		when = { minAge = 18, maxAge = 40, side = "backstreets", flags = { "knows_syndicates" } },
		codex = "fn_lore_syndicates",
		dialogue = {
			{ who = "ad_amparo", line = "Copper Hounds. We own the street now. Same fee as the last lot, plus a little for the paint." },
			{ who = "ad_amparo", line = "Or tell me where the baker keeps his second till, and you pay half. I like giving people choices." },
		},
		choices = {
			{
				label = "Pay the fee",
				result = { money = { -70, -40 }, setFlags = { "ad_hounds_paid" }, log = "You paid. She wrote your name in copper ink and drew a little dog next to it." },
			},
			{
				label = "Tell her about the baker's till",
				result = { money = { -35, -20 }, sanity = -6, setFlags = { "ad_hounds_paid", "ad_sold_baker" }, log = "You told her. The bakery was shut for a week. When it opened, the baker charged you double and never said why." },
			},
			{
				label = "Refuse to her face",
				result = { strength = 2, setFlags = { "ad_hounds_defied" }, schedule = { event = "ad_f_hounds_visit", inYears = 1 }, log = "\"Refusing is a kind of payment too,\" she said, and drew something next to your door number." },
			},
		},
	},
	{
		id = "ad_c_collector_kid",
		title = "Short This Week",
		art = "alley",
		text = "Tomas, fifteen, collects the Copper Hounds' fee from your block. Tonight he's sitting on your step, counting the envelope for the fourth time.",
		weight = 11,
		once = true,
		tags = { "crime", "backstreets" },
		when = { minAge = 20, maxAge = 40, side = "backstreets", flags = { "ad_hounds_paid" } },
		dialogue = {
			{ who = "ad_tomas", line = "Eighty short. Somebody on four moved out and didn't tell me. Who moves out without telling the Hounds?" },
			{ who = "ad_tomas", line = "Jefe doesn't hit you. She just makes you stand there while she decides." },
		},
		choices = {
			{
				label = "Cover the eighty",
				hint = "80 Ahn.",
				requires = { min = { money = 80 } },
				result = { money = -80, sanity = 3, setFlags = { "ad_tomas_owes" }, schedule = { event = "ad_l_tomas_grown", inYears = 10 }, log = "You counted eighty into his envelope. He looked at you like you'd done a card trick, and ran." },
			},
			{
				label = "Tell him to run tonight",
				result = { strength = 1, sanity = -2, setFlags = { "ad_tomas_ran" }, log = "He ran for the WARP platform with the envelope. Two Hounds asked about him for a month. You'd never heard of a Tomas." },
			},
			{
				label = "Walk him to Amparo and vouch",
				clash = { stat = "charisma", foe = "Jefe Amparo's arithmetic", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, setFlags = { "ad_tomas_owes" }, schedule = { event = "ad_l_tomas_grown", inYears = 10 }, log = "You argued a moved-out tenant is the landlord's loss. Amparo laughed and sent two Hounds to see the landlord." },
				lose = { money = { -80, -60 }, sanity = -6, log = "Amparo heard all of it, then charged you the eighty and gave Tomas the den's floors to scrub for a year." },
			},
		},
	},
	{
		id = "ad_c_hounds_name",
		title = "Half Price",
		art = "syndicate",
		text = "Somebody keeps painting over the Copper Hounds' marks at night, and Amparo has worked out that you'd know who. You do: it's {friend}.",
		weight = 9,
		once = true,
		tags = { "crime" },
		when = { minAge = 18, maxAge = 40, flags = { "ad_hounds_paid" }, hasRelation = "friend" },
		dialogue = {
			{ who = "ad_amparo", line = "A name, and your fee's halved for a year. Nothing permanent happens to anyone. Paint costs money, that's all." },
		},
		choices = {
			{
				label = "Give her the name",
				result = { money = 60, sanity = -8, relationBond = { kind = "friend", amount = -30 }, setFlags = { "ad_sold_friend" }, log = "{friend} paid a year of fees in a week and moved two streets over. They found out who'd told. People always do." },
			},
			{
				label = "Give her a made-up name",
				clash = { stat = "mind", foe = "Amparo, who checks", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = -2, log = "You named a sign painter who left the District in spring. Amparo hunted him for a month and came back almost admiring." },
				lose = { money = { -120, -80 }, sanity = -5, setFlags = { "ad_hounds_defied" }, log = "The man you named had been dead three years. Amparo doubled your fee and drew two dogs by your door." },
			},
			{
				label = "Warn {friend}",
				result = { strength = 2, money = { -90, -60 }, relationBond = { kind = "friend", amount = 12 }, log = "You told {friend} to switch to whitewash and work earlier. Your own fee went up for being slow with names." },
			},
		},
	},
	{
		id = "ad_c_two_collectors",
		title = "Two Collectors",
		art = "street",
		text = "The Night Awls and the Copper Hounds both say they own your block this month. Each has sent a collector. They stand at opposite ends of the landing, not looking at each other.",
		weight = 10,
		cooldown = 6,
		tags = { "crime", "backstreets" },
		when = { minAge = 18, maxAge = 45, side = "backstreets", flags = { "knows_syndicates" }, world = { streets = "turf_war" } },
		choices = {
			{
				label = "Pay both",
				result = { money = { -140, -90 }, sanity = -3, log = "You paid both. Each collector watched you pay the other and wrote it down. The landlord called it a tax on stairs." },
			},
			{
				label = "Pay the Awls",
				result = { money = { -70, -50 }, setFlags = { "ad_hounds_defied" }, schedule = { event = "ad_f_hounds_visit", inYears = 1 }, log = "You paid the Awls. The Hounds' collector smiled at you, which was worse than anything he could have said." },
			},
			{
				label = "Get the block to hire an Office",
				clash = { stat = "mind", foe = "Forty frightened tenants", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, money = { -40, -20 }, setFlags = { "knows_fixers" }, log = "Forty tenants hired one Office, with a contract and receipts. Both collectors left the block the same week, offended." },
				lose = { money = { -120, -80 }, sanity = -4, log = "The tenants voted to pay both. Then they voted that you should be the one to tell the collectors." },
			},
		},
	},

	-- ── the Cinderbell blade ──
	{
		id = "ad_c_blade_offer",
		title = "The Unlucky Blade",
		art = "workshop",
		text = "At the back of the Cinderbell Workshop a long blade hangs on its own hook, tagged at sixty Ahn. Everything else on the wall costs three hundred.",
		weight = 10,
		once = true,
		when = { minAge = 18, maxAge = 35 },
		codex = "fx_lore_workshops",
		dialogue = {
			{ who = "ad_marten", line = "Three owners. All dead inside a year. None of them by bad luck, if you follow me." },
			{ who = "ad_marten", line = "Best steel I ever folded. I can't sell it to anyone I like." },
		},
		choices = {
			{
				label = "Buy it",
				hint = "60 Ahn.",
				requires = { min = { money = 60 } },
				result = { money = -60, gear = "long_blade", sanity = -3, setFlags = { "ad_blade_owned" }, schedule = { event = "ad_c_blade_hum", inYears = 1 }, log = "Marten wrapped it in oilcloth and didn't shake your hand. It was warm through the cloth all the way home." },
			},
			{
				label = "Pay him to melt it down",
				hint = "60 Ahn, and you work the bellows.",
				requires = { min = { money = 60 } },
				clash = { stat = "intelligence", foe = "A blade that won't melt", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 3, money = -60, sanity = 2, log = "You worked the bellows until the steel sagged and ran. Marten poured it into the canal. The water hissed for an hour." },
				lose = { money = -60, health = { -8, -4 }, condition = "burns", cause = "Burned at the Cinderbell forge", log = "The forge flared white. The blade came out of the coals without a mark on it. Your hands didn't." },
			},
			{
				label = "Leave it on its hook",
				result = { sanity = 1, log = "You left it. On your way out the blade swung on its hook, very slightly, though the door hadn't moved." },
			},
		},
	},
	{
		id = "ad_c_blade_hum",
		title = "3:05, Blade in Hand",
		art = "home",
		text = "You wake standing at your own door with the Cinderbell blade in your hand. The clock says 3:05. Your other hand is already on the second lock.",
		weight = 0,
		when = { flags = { "ad_blade_owned" } },
		choices = {
			{
				label = "Put it down",
				clash = { stat = "mind", foe = "A blade that wants a walk", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = -3, log = "You set it down one finger at a time and slept on the floor across the doorway. It didn't move. You checked." },
				lose = { sanity = -8, condition = "night_terrors", log = "You put it down. You woke at 3:05 the next night too, and the next, with it back in your hand." },
			},
			{
				label = "Sell it to the first Fixer",
				result = { money = { 180, 260 }, clearFlags = { "ad_blade_owned" }, loseGear = "long_blade", setFlags = { "ad_blade_sold" }, schedule = { event = "ad_c_blade_back", inYears = 1 }, log = "A Grade 7 paid you two hundred without haggling, which should have told you something." },
			},
			{
				label = "Keep it close and listen",
				result = { strength = 3, sanity = -6, setFlags = { "ad_blade_listened" }, schedule = { event = "ad_c_blade_sister", inYears = 2 }, log = "You started sleeping with it. Your hands got faster. By spring you'd stopped hearing the hum at all." },
			},
		},
	},
	{
		id = "ad_c_blade_back",
		title = "Back on the Table",
		art = "home",
		text = "The Cinderbell blade is lying on your kitchen table this morning, oilcloth and all. The Fixer who bought it was pulled out of the canal in spring, one boot on.",
		weight = 0,
		when = { flags = { "ad_blade_sold" } },
		result = { gear = "long_blade", sanity = -6, setFlags = { "ad_blade_owned" }, clearFlags = { "ad_blade_sold" }, schedule = { event = "ad_c_blade_sister", inYears = 2 }, log = "You didn't ask how it got in. By evening it was on your back again, and your old weapon was nowhere in the flat." },
	},
	{
		id = "ad_c_blade_sister",
		title = "Her Brother's Blade",
		art = "street",
		text = "A Fixer in a grey coat stops you outside the noodle stall and asks about the Cinderbell blade before she says hello. She has its first owner's face, older.",
		weight = 0,
		when = { flags = { "ad_blade_owned" } },
		dialogue = {
			{ who = "ad_odile", line = "Silvan Brask. First owner. He was holding that when they found him." },
			{ who = "ad_odile", line = "I'm not asking. I'm telling you I'll take it, and it would be nicer if you handed it over." },
		},
		choices = {
			{
				label = "Hand it over",
				result = { loseGear = "long_blade", clearFlags = { "ad_blade_owned" }, setFlags = { "ad_blade_gone" }, sanity = 4, log = "She held it like something asleep and walked off without a word. You slept through the night for the first time in years." },
			},
			{
				label = "Fight her for it",
				clash = { stat = "strength", foe = "Odile Brask, Grade 6", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "fixer", status = { id = "bleed", potency = 2 } },
				win = { strength = 3, money = { 60, 120 }, sanity = -4, setFlags = { "ad_blade_kept" }, log = "She went down hard and got up slower. \"Keep it, then,\" she said. \"It'll keep you.\"" },
				lose = { health = { -18, -8 }, sanity = -5, loseGear = "long_blade", clearFlags = { "ad_blade_owned" }, setFlags = { "ad_blade_gone" }, cause = "Fought a Fixer for a cursed blade", log = "You woke in the clinic with your hands empty and very light." },
			},
			{
				label = "Tell her what it does at 3:05",
				clash = { stat = "mind", foe = "A sister's grief", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, loseGear = "long_blade", clearFlags = { "ad_blade_owned" }, setFlags = { "ad_blade_gone" }, log = "She listened. The two of you took it to Marten's forge together and watched it finally run." },
				lose = { sanity = -6, log = "\"Everyone has a story about it,\" she said. \"Mine ends with it in my hands.\" She asked again every month." },
			},
		},
	},

	-- ── the WARP ──
	{
		id = "ad_c_warp_delay",
		title = "Please Stand Clear",
		art = "train",
		text = "The WARP train slid in on time and has stood at the platform for eleven minutes with its doors shut. The board says DELAYED. A cleanup crew in long coats went aboard at the far end, carrying long cases. Through the glass you can see the passengers sitting in their seats, perfectly still.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 45 },
		codex = "districts_w_corp",
		dialogue = {
			{ who = "ad_fenwick", line = "Thank you for waiting. Please stand clear while cleanup works. This will only take a moment." },
		},
		choices = {
			{
				label = "Wait with everyone else",
				result = { sanity = -2, setFlags = { "ad_warp_rider", "knows_wings" }, log = "The doors opened at last. Everyone stepped off looking exactly as they had when they boarded, and rather pleased with themselves. Not one of them knew there had been a delay." },
			},
			{
				label = "Get a look through the door",
				hint = "A fight, if the crew minds. They will mind.",
				clash = { stat = "strength", foe = "W Corp Cleanup Agents", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "wcorp_cleanup", status = { id = "charge", potency = 2 } },
				win = { strength = 2, intelligence = 1, sanity = -3, setFlags = { "ad_warp_rider", "knows_wings" }, log = "You got one look past an agent's shoulder before the door shut: rows of seats, and somebody mopping. That was all there was to see. Fenwick wrote down your face anyway." },
				lose = { health = { -18, -8 }, sanity = -5, setFlags = { "ad_warp_rider", "knows_wings" }, cause = "Got in the way of a WARP cleanup crew", log = "\"Please stand clear,\" Fenwick said again, very gently, from above you." },
			},
			{
				label = "Ask a passenger what kept them",
				result = { intelligence = 1, sanity = -3, setFlags = { "ad_warp_rider", "ad_warp_pointer", "knows_wings" }, log = "A man in a good hat checked his watch. \"Kept us? It was ten seconds. It's always ten seconds.\" By his watch he was right. Yours said eleven minutes. You walked home." },
			},
		},
	},
	{
		id = "ad_c_warp_job",
		title = "Car Nine",
		art = "train",
		text = "W Corp pays day hands to clear lost property out of the cars at the depot: gloves, umbrellas, one shoe. Behind a loose seat panel in car nine there's a letter that has been lying there a very long time.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 35, flags = { "knows_wings" } },
		codex = "wg_lore_cleanup",
		dialogue = {
			{ who = "ad_fenwick", line = "Personal items in the grey bags. Paper goes in the burner. Policy, I'm afraid. Nobody reads it." },
			{ who = "ad_fenwick", line = "A hundred and twenty a car. Gloves are on the rack." },
		},
		choices = {
			{
				label = "Bag it with the rest",
				result = { money = 120, sanity = -1, log = "You bagged it with the umbrellas. Fenwick checked the car with a little light and signed your chit." },
			},
			{
				label = "Copy it down first",
				hint = "Intelligence check, behind an agent's back.",
				clash = { stat = "intelligence", foe = "Fourteen lines and an agent's back", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, money = 120, setFlags = { "ad_warp_letter" }, schedule = { event = "ad_c_warp_letter", inYears = 1 }, log = "You copied fourteen lines onto your glove before Fenwick turned. It was addressed to Bettany, Pier Road, District 23." },
				lose = { money = -40, sanity = -2, log = "Fenwick took your glove and burned it without reading a word. He docked the glove from your pay." },
			},
			{
				label = "Hand it in, as you're told",
				result = { money = 160, mind = 1, sanity = -1, log = "You handed it in. W Corp paid a bonus for vigilance, and the letter went in the burner with the rest." },
			},
		},
	},
	{
		id = "ad_c_warp_letter",
		title = "Fourteen Lines",
		art = "street",
		text = "The woman who opens the door on Pier Road is grey-haired. The letter you copied says Bettany is seven.",
		weight = 0,
		when = { flags = { "ad_warp_letter" } },
		dialogue = {
			{ who = "Bettany", line = "My father wrote that on the WARP, on his way to an interview. Forty years ago. He was home for dinner, and he never could find it." },
		},
		choices = {
			{
				label = "Give her the glove",
				result = { sanity = 2, mind = 2, log = "Bettany read it twice at the door. Then she laughed at one line and asked you in for tea." },
			},
			{
				label = "Read it to her",
				result = { sanity = 4, strength = 1, log = "You read all fourteen lines on her step. At the last one Bettany said, \"He always spelled it like that,\" and shut the door gently." },
			},
			{
				label = "Say you have the wrong house",
				result = { sanity = -4, log = "You said sorry, wrong door. You kept the glove in a drawer for the rest of your life." },
			},
		},
	},

	-- ── Hedda: a neighbor starts to Distort ──
	{
		id = "ad_c_hedda_washing",
		title = "The Same Shirt",
		art = "home",
		text = "Hedda Lund runs the laundry across the landing. For a month she's washed one shirt every night, and steam comes under her door like fog off the canal.",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { minAge = 18, maxAge = 50, side = "backstreets", flags = { "knows_distortions" }, world = AFTER },
		codex = "lim_distortion_stages",
		dialogue = {
			{ who = "you", line = "Hedda, it's two in the morning." },
			{ who = "ad_hedda", line = "Aron's. He went to work for the Wing in spring. They sent his shirt back. Only his shirt." },
			{ who = "ad_hedda", line = "It won't come clean. You'd think a shirt would come clean." },
		},
		choices = {
			{
				label = "Sit with her a while",
				result = { sanity = -3, mind = 1, setFlags = { "ad_hedda_heard" }, schedule = { event = "ad_c_hedda_sheets", inYears = 1 }, log = "You sat on an upturned basket while she scrubbed. Her shadow on the wall scrubbed half a second behind her." },
			},
			{
				label = "Report her to a Fixer Office",
				result = { money = 150, sanity = -5, setFlags = { "ad_hedda_reported" }, schedule = { event = "ad_c_hedda_white", inYears = 1 }, log = "The Office paid a finder's fee for an early report and put her on a list. Lists are slow." },
			},
			{
				label = "Take your washing elsewhere",
				result = { sanity = 1, schedule = { event = "ad_c_hedda_white", inYears = 2 }, log = "You started using the laundry on Fifth. The steam under Hedda's door got thicker. You walked past it with your basket." },
			},
		},
	},
	{
		id = "ad_c_hedda_sheets",
		title = "Folding",
		art = "distortion",
		text = "The laundry room has no back wall now, only clean white sheets in rows, further than the building goes. Hedda is folding, and hands you a corner.",
		weight = 0,
		when = { flags = { "ad_hedda_heard" } },
		dialogue = {
			{ who = "ad_hedda", line = "Hold it straight. If we fold them all, he'll need one. He'll come home for his bed." },
		},
		choices = {
			{
				label = "Ask about the shirt's name tag",
				clash = { stat = "mind", foe = "Rows of white sheets", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = 4, setFlags = { "ad_hedda_saved", "lim_talked_down" }, chronicle = "calmed_distortion", addRelation = { kind = "friend", name = "Hedda Lund", bond = 70, age = { 44, 52 } }, log = "The tag said ARON in her own stitching. She held it and sat down on the floor, and the room had a back wall again." },
				lose = { sanity = -6, trigger = "ad_c_hedda_white", log = "She didn't hear the question. The sheets behind you were in rows now too." },
			},
			{
				label = "Fold until morning",
				clash = { stat = "health", foe = "A night of folding", coins = 2, base = 4, coinPower = 3 },
				win = { health = 2, sanity = -2, setFlags = { "ad_hedda_saved" }, log = "You folded until your arms shook. At dawn there were forty sheets, and Hedda was asleep on the pile, snoring." },
				lose = { sanity = -6, trigger = "ad_c_hedda_white", log = "Your arms gave out at the four hundredth sheet. Hedda looked at you as if you'd let him down." },
			},
			{
				label = "Back out and lock the door",
				result = { sanity = -4, schedule = { event = "ad_c_hedda_white", inYears = 1 }, log = "You backed out between the rows and locked her door from the outside. You didn't know who the lock was for." },
			},
		},
	},
	{
		id = "ad_c_hedda_white",
		title = "The White Room",
		art = "distortion",
		text = "The landing is white to the ceiling. Something tall moves through the steam in Hedda's apron, carrying a basket that never empties, and it has heard you.",
		weight = 0,
		when = { world = { era = { "library", "limbus" } }, notFlags = { "ad_hedda_saved" } },
		choices = {
			{
				label = "Fight it",
				clash = { stat = "strength", foe = "What Hedda became", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "distortion", status = { id = "sinking", potency = 2 } },
				win = { strength = 4, money = { 100, 200 }, sanity = -6, setFlags = { "ad_hedda_lost", "lim_distortion_survivor" }, chronicle = "fought_distortion", log = "It folded down into wet sheets and an apron. Hana paid the bounty to the first name on the report. Yours." },
				lose = { health = { -24, -12 }, sanity = -8, setFlags = { "ad_hedda_lost" }, cause = "Lost in a white room", log = "You woke on the stairs, soaked through. On the landing there was nothing but a basket." },
			},
			{
				label = "Say Aron's name",
				clash = { stat = "mind", foe = "A Distortion in an apron", coins = 3, base = 6, coinPower = 4 },
				win = { mind = 3, sanity = 2, setFlags = { "ad_hedda_saved", "lim_talked_down" }, chronicle = "calmed_distortion", log = "It stopped at his name. The steam fell like a sheet off a line, and Hedda was sitting in it, crying. A person again." },
				lose = { health = { -14, -6 }, sanity = -10, setFlags = { "ad_hedda_lost" }, cause = "Lost in a white room", log = "It didn't stop. The name meant something else to it now." },
			},
			{
				label = "Run for the street",
				result = { money = { -80, -40 }, sanity = -8, setFlags = { "ad_hedda_lost" }, log = "You ran with nothing. The building was condemned by noon. You never got your good coat back from the wash." },
			},
		},
	},

	-- ── E.G.O ──
	{
		id = "ad_c_ego_voice",
		title = "In Your Own Voice",
		art = "home",
		text = "Your E.G.O talks when you're tired. Tonight it's on about the Hounds' collector who kicked in Mrs. Baek's door last week.",
		weight = 10,
		cooldown = 8,
		when = { minAge = 18, maxAge = 55, form = "ego" },
		codex = "terms_ego",
		dialogue = {
			{ who = "Your E.G.O", line = "He'd fold like a deck chair. One visit. You'd sleep better. I know you would. I'm you." },
			{ who = "Your E.G.O", line = "Or keep smiling at him on the stairs. We both know how long you can do that." },
		},
		choices = {
			{
				label = "Pay the collector a visit",
				result = { strength = 3, sanity = -8, condition = "distortion_signs", log = "He moved off the street the next day. You couldn't remember the walk home, and your knuckles were someone else's." },
			},
			{
				label = "Tell it no, out loud",
				clash = { stat = "mind", foe = "Your own E.G.O", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 5, log = "You said no in the kitchen, out loud. It went quiet and stayed quiet for a season. You missed it, a little." },
				lose = { sanity = -6, condition = "distortion_signs", log = "You argued with it until 3:13. It won on points. Your shadow ran half a second late all week." },
			},
			{
				label = "Give it something smaller",
				result = { intelligence = 2, sanity = -2, log = "You let it break the collector's flowerpot instead. It sulked for a month. So did he." },
			},
		},
	},
	{
		id = "ad_c_ego_gear",
		title = "It Changes How You Talk",
		art = "home",
		text = "Since you started carrying E.G.O gear you talk slower, and you say \"we\" when you mean \"I\". Your friends have noticed. One of them has stopped visiting.",
		weight = 10,
		once = true,
		when = { minAge = 18, hasGear = { "lc_ego_penitence", "lc_ego_lament", "lc_ego_justitia", "lc_ego_lamp" } },
		codex = "lc_lore_ego_gear",
		choices = {
			{
				label = "Lock it away for a year",
				result = { sanity = 5, strength = -2, log = "You locked it in the wardrobe. You talked like yourself again by spring. Your friend came back and didn't mention it." },
			},
			{
				label = "Keep it on you",
				result = { strength = 2, sanity = -5, log = "You kept it. By winter you'd stopped hearing the \"we\". Everybody else still heard it." },
			},
			{
				label = "Wear it to see your friend",
				clash = { stat = "mind", foe = "A voice that isn't quite yours", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 3, log = "You talked to your friend for an hour without a single \"we\". It took everything you had. They put the kettle on." },
				lose = { sanity = -5, log = "\"We missed you,\" you said at the door. Your friend looked at the thing on your belt, then at you, and shut the door." },
			},
		},
	},
	{
		id = "ad_c_ego_salvage",
		title = "The Old Logo",
		art = "market",
		text = "A salvager from District 12 has a crate under her stall stamped with the old L Corp logo. On a bed of shredded files lie two pistols, one black and one white.",
		weight = 8,
		once = true,
		when = { minAge = 20, maxAge = 45, flags = { "knows_lcorp" }, world = AFTER },
		codex = "lc_lore_ego_gear",
		dialogue = {
			{ who = "The Salvager", line = "Real E.G.O. Off a dead Agent, before you ask. Four-fifty, and you never bought them from me." },
		},
		choices = {
			{
				label = "Buy them",
				hint = "450 Ahn.",
				requires = { min = { money = 450 } },
				result = { money = -450, gear = "lc_ego_lament", setFlags = { "lc_ego_lament" }, sanity = -3, log = "They were cold in the crate and warm in your hands. You started speaking more quietly that same afternoon." },
			},
			{
				label = "Tip off a retrieval Office",
				result = { money = 100, sanity = -4, log = "An Office paid a hundred for the tip. The salvager's stall was empty by evening. So was her crate." },
			},
			{
				label = "Walk on",
				result = { sanity = 1, log = "You walked on. Behind you the salvager laughed and shut the crate, and the pistols stopped looking at you." },
			},
		},
	},

	-- ── Hana's rankings ──
	{
		id = "ad_c_imre_window",
		title = "A Room With a View",
		art = "home",
		text = "Hana's Assessor has rented the room above yours for a week. She wants your window, which looks straight into the Kurokumo Clan's tea house.",
		weight = 9,
		once = true,
		tags = { "fixers" },
		when = { minAge = 20, maxAge = 40, side = "backstreets", flags = { "knows_fixers", "knows_fingers" } },
		codex = "fc_lore_board",
		dialogue = {
			{ who = "ad_imre", line = "Three Fixers on the District board are drawing Clan pay. Hana would like to know which three before the quarter ends." },
			{ who = "ad_imre", line = "Two hundred Ahn for the window. A camera. You'll be at work. You won't see a thing." },
		},
		choices = {
			{
				label = "Rent her the window",
				result = { money = 200, setFlags = { "ad_window_rented" }, schedule = { event = "ad_f_clan_window", inYears = 1 }, log = "Three Fixers fell off the board that quarter. The Clan's tea house closed its shutters on your side of the street." },
			},
			{
				label = "Ask for a cut of the bounty",
				clash = { stat = "mind", foe = "Hana's budget", coins = 2, base = 4, coinPower = 3 },
				win = { money = 350, setFlags = { "ad_window_rented" }, schedule = { event = "ad_f_clan_window", inYears = 1 }, log = "Imre paid three-fifty and called you a natural. From Hana, that is a warning." },
				lose = { money = 100, setFlags = { "ad_window_rented" }, schedule = { event = "ad_f_clan_window", inYears = 1 }, log = "She paid a hundred and wrote you down as a source who haggles. Hana writes everything down." },
			},
			{
				label = "Keep your curtains shut",
				result = { sanity = 1, log = "You said no. Imre thanked you and rented the window two doors down. The Clan never learned which window to visit." },
			},
		},
	},

	-- ── the Wings: layoffs, passes, ampules, packs ──
	{
		id = "ad_c_layoff_friend",
		title = "Restructuring",
		art = "nest",
		text = "The Wing cut three thousand Feathers in one morning, by letter, and {friend} was one. Their Nest residence ends with the job, in thirty days.",
		weight = 9,
		once = true,
		when = { minAge = 22, maxAge = 45, flags = { "knows_wings" }, hasRelation = "friend" },
		codex = "fc_lore_feathers",
		dialogue = {
			{ who = "{friend}", line = "They thanked me for eleven years on the same page as the eviction date. Very efficient page." },
			{ who = "{friend}", line = "I'm not asking to stay with you. I'm asking where you'd stay, if you were me." },
		},
		choices = {
			{
				label = "Give them your floor",
				result = { money = { -80, -40 }, sanity = 2, relationBond = { kind = "friend", amount = 15 }, log = "{friend} slept on your floor for a year and alphabetized your cupboards. They kept the Nest habit of thanking doors." },
			},
			{
				label = "Forge them thirty more days",
				clash = { stat = "intelligence", foe = "A Wing's residence stamp", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, relationBond = { kind = "friend", amount = 10 }, log = "Your stamp was good enough for a tired clerk. Thirty days became ninety, and {friend} found work inside the wall." },
				lose = { money = { -150, -90 }, sanity = -6, relationBond = { kind = "friend", amount = 5 }, log = "The clerk was not tired. {friend} was fined for your forgery and paid it without a word." },
			},
			{
				label = "Say they wouldn't last outside",
				result = { sanity = -4, relationBond = { kind = "friend", amount = -15 }, log = "You said they wouldn't last a month in the Backstreets. They took a room three streets away to prove you wrong." },
			},
		},
	},
	{
		id = "ad_c_nest_pass",
		title = "A Pass, Slightly Used",
		art = "checkpoint",
		text = "A laid-off Feather is selling her Nest residence pass for three hundred Ahn. It has her face on it and four months left. From far off, you look a little like her.",
		weight = 8,
		once = true,
		when = { minAge = 20, maxAge = 40, side = "backstreets", flags = { "knows_wings" } },
		codex = "bs_lore_nests",
		choices = {
			{
				label = "Buy it and walk in",
				hint = "300 Ahn.",
				requires = { min = { money = 300 } },
				clash = { stat = "mind", foe = "A checkpoint guard with good eyes", coins = 3, base = 5, coinPower = 3 },
				win = { money = -300, side = "nest", sanity = 2, setFlags = { "ad_false_pass" }, log = "The guard looked at the pass, then at you, then waved. You lived inside the wall under her name, and answered to it." },
				lose = { money = -300, sanity = -6, condition = "dz_hunted", log = "The guard kept the pass. A drone followed you home and stayed outside your window all season." },
			},
			{
				label = "Report her at the gate",
				result = { money = 50, sanity = -5, log = "The Wing paid fifty for the report and fined her the price of the pass. She'd been trying to make rent." },
			},
			{
				label = "Tell her to sell further off",
				result = { strength = 1, sanity = 1, log = "You told her the gate had a camera on the corner. She moved her table two streets back and gave you a Nest biscuit." },
			},
		},
	},
	{
		id = "ad_c_kcorp_trial",
		title = "Paid Trial",
		art = "clinic",
		text = "K Corp is paying three hundred Ahn a head to test a new ampule formula, and the line goes round the block. The woman at the table wears a half-mask.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 35, flags = { "knows_wings" } },
		codex = "wg_lore_kcorp",
		dialogue = {
			{ who = "ad_ludmila", line = "One dose and your body puts itself back the way it remembers being. The new formula remembers a little more." },
			{ who = "ad_ludmila", line = "Some volunteers recall injuries they've never had. They aren't your injuries. Sign here." },
		},
		choices = {
			{
				label = "Take the dose",
				result = { money = 300, health = 6, sanity = -6, setFlags = { "ad_ampule_memory" }, schedule = { event = "ad_c_kcorp_scar", inYears = 2 }, log = "You felt wonderful for a day. That night you dreamed of a staircase you'd never climbed, and falling down it." },
			},
			{
				label = "Sell your place to Old Kemal",
				result = { money = 100, sanity = -4, log = "Kemal paid a hundred for your place. He needed the three hundred. He came out with a limp he'd never had before." },
			},
			{
				label = "Leave the line",
				result = { mind = 1, log = "You stepped out of the line. Behind you it closed up at once, like water." },
			},
		},
	},
	{
		id = "ad_c_kcorp_scar",
		title = "A Scar You Don't Have",
		art = "home",
		text = "Two years on, the dream is always the same staircase, and a woman's hand on the rail that isn't yours. You know her ring. You know her stairwell is in District 11.",
		weight = 0,
		when = { flags = { "ad_ampule_memory" } },
		choices = {
			{
				label = "Go and find the stairwell",
				clash = { stat = "mind", foe = "A memory with no address", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 4, log = "You found it. A woman with that ring opened the door, leaning on a cane. You didn't say why you'd come. You carried her shopping up." },
				lose = { sanity = -6, log = "You walked District 11 for a week. Every stairwell was the right one until you climbed it." },
			},
			{
				label = "Pay K Corp to take it out",
				hint = "120 Ahn.",
				requires = { min = { money = 120 } },
				result = { money = -120, sanity = 3, mind = -2, log = "K Corp removed the memory for a fee, and a few others near it, to be safe. You don't know which." },
			},
			{
				label = "Live with it",
				result = { health = 2, sanity = -3, log = "You learned to take stairs the way she did: hand on the rail, one at a time. It saved your neck twice." },
			},
		},
	},
	{
		id = "ad_c_one_ampule",
		title = "One Ampule",
		art = "ruins",
		text = "In the rubble of the stairwell two people are still breathing: Mrs. Imai who sells buttons, and a Thumb Soldato in a pressed suit. You have one ampule on a cord.",
		weight = 11,
		once = true,
		when = { minAge = 35, maxAge = 60, hasGear = "ampule" },
		dialogue = {
			{ who = "thumb_soldato", line = "Five hundred Ahn, and the Thumb will owe you a courtesy. The old woman will live without it. Probably." },
		},
		choices = {
			{
				label = "Give it to Mrs. Imai",
				result = { loseGear = "ampule", sanity = 6, strength = 2, setFlags = { "ad_soldato_remembers" }, log = "She was up and complaining before the clinic arrived. The Soldato was carried off by his own people, looking at you." },
			},
			{
				label = "Give it to the Soldato",
				result = { loseGear = "ampule", money = 500, sanity = -8, setFlags = { "thumb_respect" }, log = "He stood up and paid you in full, with a bow. Mrs. Imai walked again by winter, with a stick." },
			},
			{
				label = "Keep it",
				result = { sanity = -10, log = "You kept it. Both of them lived, Mrs. Imai badly. You wore the ampule for years and never needed it." },
			},
		},
	},
	{
		id = "ad_c_kcorp_forget",
		title = "Sign Here to Forget",
		art = "checkpoint",
		text = "You saw a K Corp van take a man off the street outside the checkpoint, and so did the drone over your head. Now a polite woman in a half-mask is offering you a chair.",
		weight = 9,
		once = true,
		when = { minAge = 20, maxAge = 45, district = "d11", flags = { "knows_wings" } },
		codex = "wg_lore_kcorp",
		dialogue = {
			{ who = "ad_ludmila", line = "A short procedure. You lose this afternoon and nothing else. Two hundred Ahn for your trouble." },
			{ who = "ad_ludmila", line = "Declining is also an option. It's on page four. Nobody reads page four." },
		},
		choices = {
			{
				label = "Take the chair",
				result = { money = 200, sanity = 3, mind = -2, log = "You woke with two hundred Ahn and a sore neck, and spent the evening wondering why you'd bought a new umbrella." },
			},
			{
				label = "Pretend to go under",
				clash = { stat = "mind", foe = "K Corp's procedure", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, money = 200, setFlags = { "ad_kept_memory" }, log = "You kept your eyes heavy and your breathing slow, and left with the money and the afternoon. You never said his name aloud." },
				lose = { money = 200, sanity = -6, condition = "fx_knowledge_spent", log = "They noticed. They took the afternoon and a little extra, for the bother. You can't remember your old address." },
			},
			{
				label = "Read page four",
				result = { sanity = -4, condition = "dz_hunted", setFlags = { "ad_kept_memory" }, log = "Page four was a list of drone routes. Yours was added to it before you'd finished reading." },
			},
		},
	},
	{
		id = "ad_c_rcorp_billet",
		title = "Observation Post",
		art = "home",
		text = "Four soldiers in R Corp fatigues knock at six in the morning, wanting your front window for three days. They all have the same face.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 45, flags = { "knows_wings" } },
		codex = "wg_lore_rcorp",
		dialogue = {
			{ who = "rcorp_rabbit", line = "Rabbit Team, Fourth Pack. Contract target across the street. Per diem eighty Ahn. Keep your head below the sill." },
			{ who = "rcorp_rabbit", line = "The family in 4C has been advised to stay home. They have not been told why." },
		},
		choices = {
			{
				label = "Let them in",
				result = { money = 80, sanity = -6, log = "They were tidy and never sat down. On the third night the flat across the street went dark, and the Rabbits packed up by four." },
			},
			{
				label = "Get a note to 4C",
				clash = { stat = "mind", foe = "Four identical pairs of eyes", coins = 3, base = 5, coinPower = 3 },
				win = { strength = 2, sanity = 2, setFlags = { "ad_warned_4c" }, log = "You sent a note up with the milk. 4C was empty by the second night. The Rabbits logged the contract as complete anyway." },
				lose = { health = { -10, -4 }, sanity = -6, condition = "broken_arm", cause = "Warned an R Corp target", log = "The milk boy was a Rabbit. They were very polite about it. You spent the season in a cast." },
			},
			{
				label = "Bar the door",
				clash = { stat = "strength", foe = "Rabbit Team, Fourth Pack", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "rcorp_rabbit", status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = { 40, 90 }, sanity = -3, log = "They hadn't planned for a door that fought back. They set up across the street and left behind a crate of rations, which you sold." },
				lose = { health = { -18, -8 }, sanity = -5, cause = "Barred the door against R Corp", log = "They came in through the door and most of the frame. The per diem went on damages." },
			},
		},
	},
	{
		id = "ad_c_rcorp_sibling",
		title = "Signed Up",
		art = "wing",
		text = "{sibling} has signed an R Corp contract as a pack handler: eighteen months, triple pay, deployment in a week. Clause nine is about what gets sent home.",
		weight = 9,
		once = true,
		when = { minAge = 20, maxAge = 40, flags = { "knows_wings" }, hasRelation = "sibling" },
		dialogue = {
			{ who = "{sibling}", line = "It's handlers. We walk behind them. The clones do the dying. That's what they're hatched for." },
		},
		choices = {
			{
				label = "Buy out the contract",
				hint = "400 Ahn.",
				requires = { min = { money = 400 } },
				result = { money = -400, sanity = 3, relationBond = { kind = "sibling", amount = -10 }, log = "You paid the penalty clause. {sibling} didn't speak to you for a month, then asked to borrow money for rent." },
			},
			{
				label = "See them off",
				result = { sanity = -3, relationBond = { kind = "sibling", amount = 6 }, setFlags = { "ad_sibling_rcorp" }, schedule = { event = "ad_c_rcorp_home", inYears = 2 }, log = "You saw them off at the depot. They waved from a truck of identical faces, the only face that was different." },
			},
			{
				label = "Read clause nine aloud",
				clash = { stat = "mind", foe = "Triple pay", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, relationBond = { kind = "sibling", amount = 8 }, log = "You read it slowly, twice. {sibling} tore the contract up, which cost nothing, because they hadn't countersigned." },
				lose = { sanity = -4, setFlags = { "ad_sibling_rcorp" }, schedule = { event = "ad_c_rcorp_home", inYears = 2 }, log = "\"Every contract has a clause nine,\" {sibling} said, and went." },
			},
		},
	},
	{
		id = "ad_c_rcorp_home",
		title = "What Gets Sent Home",
		art = "home",
		text = "{sibling} is back from the R Corp contract early. They sit at your table turning a Rabbit's tags over in their hand.",
		weight = 0,
		when = { hasRelation = "sibling", flags = { "ad_sibling_rcorp" } },
		dialogue = {
			{ who = "{sibling}", line = "He had a number, not a name. I gave him one. He answered to it for six weeks." },
		},
		choices = {
			{
				label = "Ask what name",
				result = { sanity = 2, relationBond = { kind = "sibling", amount = 10 }, log = "\"Juno,\" they said. You hung the tags on the nail by the door, next to your keys." },
			},
			{
				label = "Don't ask",
				result = { sanity = -2, relationBond = { kind = "sibling", amount = 4 }, log = "You didn't ask. They slept on your floor and left the tags under the pillow in the morning." },
			},
			{
				label = "Help them claim the bonus",
				result = { money = 200, sanity = -3, log = "The bonus paid out for a contract completed with losses. {sibling} gave you half and never mentioned it again." },
			},
		},
	},

	-- ── the Index: tiny Prescripts ──
	{
		id = "ad_c_prescript_door",
		title = "Leave It Unlocked",
		art = "home",
		text = "A Proselyte of the Index in pale clothes is waiting on your landing with a slip of paper folded in four.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 50, flags = { "knows_index" } },
		codex = "fingers_index",
		dialogue = {
			{ who = "ad_wen", line = "It was written for you. I only carry them." },
			{ who = "ad_wen", line = "\"Tonight, leave your door unlocked until 3:10.\" That's all. They're never long." },
		},
		choices = {
			{
				label = "Do as it says",
				result = { sanity = -4, addTrait = "index_marked", chronicle = "fn_prescript_done", trigger = "ad_c_prescript_night", log = "At midnight you undid all three locks and sat facing the door with the lamp off." },
			},
			{
				label = "Lock up as usual",
				result = { sanity = -2, setFlags = { "ad_prescript_refused" }, schedule = { event = "ad_c_proxies", inYears = 1 }, log = "You did all three locks at eleven, as always. You heard her standing on the landing until nearly three." },
			},
			{
				label = "Say you never read it",
				clash = { stat = "mind", foe = "A Proselyte who watched you read", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, log = "\"I didn't read it,\" you said. She believed you, or decided to, and took it to someone who would." },
				lose = { sanity = -3, setFlags = { "ad_prescript_refused" }, schedule = { event = "ad_c_proxies", inYears = 1 }, log = "\"You read it,\" she said. \"Your lips moved.\" She wrote something on the back of the slip." },
			},
		},
	},
	{
		id = "ad_c_prescript_night",
		title = "3:09, Unlocked",
		art = "night",
		text = "At 3:09 your door opens and a young woman in a Middle jacket folds herself under your table. At 3:11 someone knocks.",
		weight = 0,
		when = { minAge = 18 },
		dialogue = {
			{ who = "The Big Brother", line = "Little Sister. I know you're in there. Family doesn't run. Open up, and we both get home." },
			{ who = "The Little Sister", line = "Don't. Please. He'll say it's family business. It is." },
		},
		choices = {
			{
				label = "Keep the door shut",
				result = { strength = 2, sanity = -3, setFlags = { "ad_hid_sister" }, log = "He knocked until 3:12, then ran. At dawn she left by the window and did your locks up behind her." },
			},
			{
				label = "Open the door",
				result = { sanity = -8, log = "He thanked you formally and took her home by the elbow. The Middle sent you a cake. You didn't eat it." },
			},
			{
				label = "Let him in too",
				clash = { stat = "mind", foe = "Two Siblings in one small room", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 3, sanity = 2, log = "You sat them at opposite ends of your table until 4:33. By dawn they were arguing about their mother. They left together, still arguing." },
				lose = { money = { -60, -30 }, sanity = -6, log = "They argued across your table for an hour, very quietly, the way families do. Neither would pay for the lamp." },
			},
		},
	},
	{
		id = "ad_c_proxies",
		title = "Unfulfilled",
		art = "street",
		text = "Two Index Proxies in pale coats are waiting outside your work, a year to the day after the slip. One holds a new slip, and the other a blade.",
		weight = 0,
		when = { flags = { "ad_prescript_refused" } },
		dialogue = {
			{ who = "index_proxy", line = "The Prescript was not fulfilled. That is rare. We have come to see why." },
		},
		choices = {
			{
				label = "Fight them",
				clash = { stat = "strength", foe = "Two Index Proxies", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "index_proxy", status = { id = "poise", potency = 2 } },
				win = { strength = 4, money = { 60, 140 }, sanity = -4, clearFlags = { "ad_prescript_refused" }, log = "They fell back in step, as if that were written too. The new slip blew off down the street. You didn't chase it." },
				lose = { health = { -18, -8 }, sanity = -6, condition = "broken_arm", clearFlags = { "ad_prescript_refused" }, cause = "Disobeyed a Prescript", log = "It was over before you'd finished deciding. They straightened their coats and left the new slip in your pocket." },
			},
			{
				label = "Read the new slip",
				result = { sanity = -5, addTrait = "index_marked", clearFlags = { "ad_prescript_refused" }, log = "\"Buy them both tea,\" it said. You did. They drank it standing up and left without a word. You had the slip framed." },
			},
			{
				label = "Run",
				clash = { stat = "speed", foe = "Proxies who walk faster than you run", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -3, clearFlags = { "ad_prescript_refused" }, log = "You ran through the market and out the far side. You haven't seen them since. You check." },
				lose = { health = { -12, -6 }, sanity = -4, clearFlags = { "ad_prescript_refused" }, cause = "Ran from the Index", log = "They were already waiting at the far end of the market." },
			},
		},
	},
	{
		id = "ad_c_prescript_sleep",
		title = "Do Not Wake Them",
		art = "home",
		text = "A slip is on your pillow in the Index's careful hand: \"On the morning of the fourteenth, do not wake {sibling}.\" {sibling} is staying with you that week, and has an early start.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 45, flags = { "knows_index" }, hasRelation = "sibling" },
		codex = "fn_lore_index",
		choices = {
			{
				label = "Let them sleep",
				result = { sanity = -3, addTrait = "index_marked", setFlags = { "ad_let_sleep" }, schedule = { event = "ad_c_fourteenth", inYears = 1 }, log = "You lay awake listening to their alarm ring out, and didn't move. They slept until ten." },
			},
			{
				label = "Wake them anyway",
				result = { strength = 2, setFlags = { "ad_woke_them", "ad_prescript_refused" }, schedule = { { event = "ad_c_fourteenth", inYears = 1 }, { event = "ad_c_proxies", inYears = 2 } }, log = "You woke them at six with tea, and they made their train. You burned the slip in the sink." },
			},
			{
				label = "Show {sibling} the slip",
				result = { mind = 1, relationBond = { kind = "sibling", amount = 6 }, setFlags = { "ad_let_sleep" }, schedule = { event = "ad_c_fourteenth", inYears = 1 }, log = "{sibling} read it and laughed, then stopped laughing. On the fourteenth they stayed in bed by their own choice." },
			},
		},
	},
	{
		id = "ad_c_fourteenth",
		title = "The Fourteenth",
		art = "train",
		text = "A year ago, on the fourteenth, {sibling} had an early WARP train to a job interview. Today you finally learn what happened to that train.",
		weight = 0,
		when = { hasRelation = "sibling" },
		codex = "wg_lore_train_states",
		choices = {
			{
				label = "Ask {sibling} about the ride",
				requires = { flags = { "ad_woke_them" } },
				result = { sanity = -8, relationBond = { kind = "sibling", amount = 8 }, log = "They were on it. It ran DELAYED. They've never said how long it felt. They take the stairs everywhere now." },
			},
			{
				label = "Look the train up",
				requires = { flags = { "ad_let_sleep" } },
				result = { sanity = 2, mind = 2, log = "It ran DELAYED. Cleanup worked it for nine hours. {sibling} still complains about the interview they slept through." },
			},
			{
				label = "Burn the clipping",
				result = { sanity = -2, log = "You burned the newspaper clipping in the sink, the same sink as the slip." },
			},
		},
	},

	-- ── the Middle ──
	{
		id = "ad_c_middle_laugh",
		title = "You Laughed",
		art = "diner",
		text = "At the noodle stall a Middle Little Brother with a very new haircut turns round on his stool. Somebody laughed, and he has decided it was you.",
		weight = 10,
		once = true,
		when = { minAge = 18, maxAge = 40, flags = { "knows_middle" } },
		codex = "fn_lore_book",
		dialogue = {
			{ who = "middle_sibling", line = "Something funny about my hair? Say it to my face. Say it to my Big Sister's face." },
			{ who = "ad_renata", line = "Little Brother says you laughed. I believe my family. What I don't know yet is what it costs." },
		},
		choices = {
			{
				label = "Apologize with a favor",
				result = { sanity = -3, setFlags = { "ad_middle_owes" }, schedule = { event = "ad_c_middle_errand", inYears = 1 }, log = "You bowed to the haircut and offered a favor. Renata accepted for the family. \"We'll call it in,\" she said." },
			},
			{
				label = "Say you laughed at the prices",
				clash = { stat = "mind", foe = "A Big Sister who's heard it all", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 2, log = "Renata studied the price board for a long moment, then laughed too. Little Brother had to sit back down." },
				lose = { sanity = -5, condition = "in_the_book", chronicle = "fn_written_in_book", setFlags = { "ad_in_book" }, schedule = { event = "ad_c_middle_book", inYears = 2 }, log = "\"Prices,\" she said, and opened a heavy book to write in it, slowly." },
			},
			{
				label = "Point at the man who laughed",
				result = { sanity = -6, setFlags = { "ad_pointed_middle" }, log = "You pointed at the man two stools down. He hadn't laughed either. His stall was shut by the end of the month." },
			},
		},
	},
	{
		id = "ad_c_middle_errand",
		title = "Family Errand",
		art = "street",
		text = "Renata calls in your favor: a parcel for a Little Brother on Kessel Street, which belongs to the Thumb this year. The parcel is heavy and rattles when you walk.",
		weight = 0,
		when = { flags = { "ad_middle_owes" } },
		dialogue = {
			{ who = "ad_renata", line = "Don't open it. Don't bow too low on Kessel Street. The Thumb takes a low bow as an offer." },
		},
		choices = {
			{
				label = "Bow through the checkpoint",
				clash = { stat = "charisma", foe = "A Soldato checking every bag", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, setFlags = { "ad_middle_done" }, clearFlags = { "ad_middle_owes" }, log = "Exactly the right depth, and you kept walking. The Little Brother signed for the parcel with his whole name." },
				lose = { money = { -120, -60 }, sanity = -5, setFlags = { "fn_thumb_disrespected" }, log = "Your bow was two ranks too deep. The Soldato fined you for impersonating a Capo's guest, and kept the parcel." },
			},
			{
				label = "Go round by the fire escapes",
				clash = { stat = "strength", foe = "Thumb Soldati on Kessel Street", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "thumb_soldato", status = { id = "burn", potency = 2 } },
				win = { strength = 3, money = { 60, 120 }, setFlags = { "ad_middle_done" }, clearFlags = { "ad_middle_owes" }, log = "They saw you on the fire escape. You saw them first. The Little Brother tipped you from the parcel: it was coins all along." },
				lose = { health = { -18, -8 }, sanity = -5, setFlags = { "fn_thumb_disrespected" }, cause = "Ran a parcel across Thumb ground", log = "The Thumb fires propellant rounds. You found that out from very close by." },
			},
			{
				label = "Open the parcel first",
				result = { sanity = -4, clearFlags = { "ad_middle_owes" }, setFlags = { "ad_in_book" }, condition = "in_the_book", schedule = { event = "ad_c_middle_book", inYears = 2 }, log = "Old coins and one photograph of you. You took it back to Renata. She wrote your name down without looking up." },
			},
		},
	},
	{
		id = "ad_c_middle_book",
		title = "The Book Is Open",
		art = "syndicate",
		text = "Renata finds you, as promised. She has the book under one arm and three Little Siblings behind her.",
		weight = 0,
		when = { flags = { "ad_in_book" } },
		dialogue = {
			{ who = "ad_renata", line = "Your name is on page ninety. I've read it aloud to the family twice. They've grown fond of hearing it." },
		},
		choices = {
			{
				label = "Face her",
				clash = { stat = "strength", foe = "Big Sister Renata", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "middle_big", status = { id = "rupture", potency = 3 } },
				win = { strength = 4, sanity = 2, cure = "in_the_book", clearFlags = { "ad_in_book" }, addTrait = "fn_struck_from_book", chronicle = "fn_struck_from_book", log = "She got up slowly and opened the book, and crossed out page ninety herself. \"Family respects a debt paid,\" she said." },
				lose = { health = { -24, -12 }, sanity = -8, cause = "Settled by the Middle", log = "The Little Siblings carried you home and laid you on your own bed, very politely. Your name is still on page ninety." },
			},
			{
				label = "Pay to be crossed out",
				hint = "400 Ahn.",
				requires = { min = { money = 400 } },
				result = { money = -400, sanity = -3, cure = "in_the_book", clearFlags = { "ad_in_book" }, log = "Four hundred Ahn and a bow. She crossed it out in red. \"Paid,\" she said. \"Close enough to forgiven, for us.\"" },
			},
			{
				label = "Ask Dalia to speak for you",
				hint = "150 Ahn.",
				requires = { flags = { "ad_dalia_trust" }, min = { money = 150 } },
				result = { money = -150, cure = "in_the_book", clearFlags = { "ad_in_book" }, log = "Dalia talked with Renata over tea for an hour. You were crossed out by evening. Dalia's invoice came the next morning." },
			},
			{
				label = "Take the WARP and run",
				result = { sanity = -8, schedule = { event = "ad_c_middle_book", inYears = 3 }, log = "You took the WARP two Districts over. Within a month Renata sent a postcard to your new address." },
			},
		},
	},

	-- ── the Thumb ──
	{
		id = "ad_c_thumb_corner",
		title = "A Capo on the Corner",
		art = "street",
		text = "Piero, the Soldato who collects on your street, stops at your door with a Capo wearing three bars on his pin. Piero's eyes are begging you to get this right.",
		weight = 10,
		once = true,
		when = { minAge = 18, maxAge = 45, flags = { "knows_thumb" } },
		codex = "fn_lore_thumb_ranks",
		dialogue = {
			{ who = "ad_piero", line = "Capo, this is the household I mentioned. Very punctual. Very respectful." },
			{ who = "thumb_capo", line = "Then let me see the respect." },
		},
		choices = {
			{
				label = "Bow for a Capo III",
				clash = { stat = "charisma", foe = "Three bars on a pin", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, setFlags = { "thumb_respect" }, log = "Exactly the right depth, exactly the right count. The Capo nodded once. Piero breathed for the first time in a minute." },
				lose = { money = { -150, -80 }, sanity = -5, setFlags = { "fn_thumb_disrespected" }, log = "A Capo II's bow, a rank too shallow. Piero paid the fine on the spot and added it to your tribute for a year." },
			},
			{
				label = "Let Piero do the talking",
				result = { sanity = -2, setFlags = { "ad_piero_favor" }, log = "You kept your head down and Piero talked for both of you. Afterwards he said, \"You owe me a small thing. I'll think of it.\"" },
			},
			{
				label = "Shake the Capo's hand",
				result = { strength = 2, sanity = -4, setFlags = { "fn_thumb_disrespected" }, chronicle = "defied_thumb", log = "You said good morning and held out your hand. The Capo looked at it until you put it away. Piero stayed away a week." },
			},
		},
	},
	{
		id = "ad_c_thumb_credit",
		title = "Courtesy Credit",
		art = "diner",
		text = "Piero buys you noodles, which he has never done, and slides an envelope along the counter: three hundred Ahn at the Thumb's very reasonable courtesy rate.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 40, flags = { "knows_thumb" }, notFlags = { "fn_owes_thumb" } },
		codex = "fingers_thumb",
		dialogue = {
			{ who = "ad_piero", line = "Everyone needs a little help. The Thumb only asks you repay it properly. On time, and in person." },
		},
		choices = {
			{
				label = "Take the envelope",
				result = { money = 300, setFlags = { "fn_owes_thumb", "ad_thumb_loan" }, condition = "fn_thumb_interest", addTrait = "in_debt_to_the_thumb", schedule = { event = "ad_c_thumb_ledger", inYears = 3 }, log = "You took it with both hands and said thank you twice. Piero wrote the date in a small black book." },
			},
			{
				label = "Decline in the proper words",
				clash = { stat = "mind", foe = "Refusing a gift correctly", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, setFlags = { "thumb_respect" }, log = "You declined in the form a Soldato uses to a Capo. Piero looked impressed and a little sad, and paid for the noodles." },
				lose = { sanity = -4, setFlags = { "fn_thumb_disrespected" }, log = "Your refusal was correct in every word but one. Piero paid for his noodles and left yours on the bill." },
			},
			{
				label = "Take it in someone else's name",
				result = { money = 300, sanity = -8, setFlags = { "ad_loan_other_name" }, log = "You gave the name of a tenant who'd moved away. Piero wrote it down. By spring her mother was getting very polite letters." },
			},
		},
	},
	{
		id = "ad_c_thumb_ledger",
		title = "On Time, In Person",
		art = "home",
		text = "Three years on, Piero is at your door with two Soldati and the small black book open at your page. The interest has its own column.",
		weight = 0,
		when = { flags = { "ad_thumb_loan" } },
		dialogue = {
			{ who = "ad_piero", line = "Four hundred and eighty. I'm sorry. I like you. This is the part where that doesn't count." },
		},
		choices = {
			{
				label = "Pay it in full",
				hint = "480 Ahn.",
				requires = { min = { money = 480 } },
				result = { money = -480, clearFlags = { "fn_owes_thumb", "ad_thumb_loan" }, removeTrait = "in_debt_to_the_thumb", cure = "fn_thumb_interest", setFlags = { "thumb_respect" }, log = "You counted it onto the table and said thank you twice. Piero struck the line out with a ruler." },
			},
			{
				label = "Work it off on ammo duty",
				result = { health = { -10, -4 }, sanity = -5, clearFlags = { "fn_owes_thumb", "ad_thumb_loan" }, removeTrait = "in_debt_to_the_thumb", cure = "fn_thumb_interest", cause = "Worked off a debt to the Thumb", log = "You carried propellant rounds for the Capi for a year to clear the line. Your shoulder never sat right again." },
			},
			{
				label = "Fight your way out",
				clash = { stat = "strength", foe = "Piero and two Soldati", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "thumb_soldato", status = { id = "burn", potency = 2 } },
				win = { strength = 3, sanity = -5, clearFlags = { "ad_thumb_loan" }, setFlags = { "fn_thumb_disrespected" }, chronicle = "fn_thumb_provoked", log = "Piero got up off your floor and straightened his tie. \"That was very rude,\" he said, and he sounded hurt." },
				lose = { health = { -18, -8 }, money = { -480, -300 }, sanity = -6, clearFlags = { "ad_thumb_loan" }, cause = "Fought the Thumb over a debt", log = "They took what was in the drawer and corrected the rest. Piero apologized on his way out." },
			},
		},
	},
	{
		id = "ad_c_thumb_seating",
		title = "The Seating Chart",
		art = "hall",
		text = "You've taken a night's work catering a Capo's retirement dinner: forty covers, white cloths. An hour before the guests arrive you see it. The seating chart puts a Capo I above a Capo III.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 55, flags = { "knows_thumb" } },
		choices = {
			{
				label = "Fix it before anyone sees",
				clash = { stat = "intelligence", foe = "Forty place cards and an hour", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, money = 150, setFlags = { "thumb_respect" }, log = "You rewrote forty cards in a steady hand. Nobody noticed, which in the Thumb is the highest praise there is." },
				lose = { money = { -60, -30 }, sanity = -6, log = "You ran out of time at card thirty-one. The Capo III sat where his card said and smiled all evening. Your boss shut the kitchen early." },
			},
			{
				label = "Let the junior waiter take it",
				result = { money = 80, sanity = -7, log = "The Capo III asked who'd laid the table. Everyone looked at the boy who'd laid the table. You kept your job." },
			},
			{
				label = "Tell the Soldato in charge",
				result = { mind = 1, sanity = -2, log = "You told the Soldato. He went white and fixed it himself, then told everyone he'd caught it. You let him." },
			},
		},
	},

	-- ── the Ring ──
	{
		id = "ad_c_ring_guard",
		title = "Stillness",
		art = "theater",
		text = "The Ring pays two hundred Ahn for a door guard at its exhibition \"Stillness\": twelve living models who must not move for twelve hours. In the ninth hour, one starts to cry.",
		weight = 9,
		once = true,
		when = { minAge = 20, maxAge = 40, flags = { "knows_ring" } },
		codex = "fn_lore_ring",
		dialogue = {
			{ who = "ad_lisandro", line = "She's spoiling the piece. Bring her round the back and I'll correct her. Gently. I'm told I'm gentle." },
		},
		choices = {
			{
				label = "Stay at the door",
				result = { money = 200, sanity = -8, log = "You stayed at the door. The Docent fetched her himself. The piece was much admired. There were eleven models at the close." },
			},
			{
				label = "Get her out the side door",
				clash = { stat = "strength", foe = "Ring Students in smocks", coins = 3, base = 5, coinPower = 3, fight = true, enemy = "ring_artist", status = { id = "bleed", potency = 2 } },
				win = { strength = 3, sanity = 2, setFlags = { "dz_ring_noticed" }, log = "You carried her out the side door and three Students came after you with palette knives. They went back in without them." },
				lose = { health = { -18, -8 }, sanity = -6, condition = "fn_ring_subject", cause = "Interrupted a Ring exhibition", log = "The Students walked you back inside. The Docent studied you all night, with real interest." },
			},
			{
				label = "Take her place on the plinth",
				clash = { stat = "health", foe = "Three hours of perfect stillness", coins = 3, base = 5, coinPower = 3 },
				win = { health = 3, money = 200, sanity = -2, log = "You held her pose for three hours without a twitch. The Docent called it the best part of the piece, and paid you as a model." },
				lose = { sanity = -8, condition = "fn_ring_subject", log = "Your knee went in the second hour. The Docent smiled and wrote down exactly how long you'd lasted." },
			},
		},
	},
	{
		id = "ad_c_ring_hands",
		title = "Your Mother's Hands",
		art = "home",
		text = "A Ring Student has watched {mother} at her work for a week. Today he knocks with a bowl of plaster and an offer: two hundred and fifty Ahn to cast her hands.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 55, flags = { "knows_ring" }, hasRelation = "mother" },
		dialogue = {
			{ who = "The Student", line = "Forty years of the same work. I want to show the work. Only the hands. She keeps them, obviously." },
			{ who = "{mother}", line = "He talks like a funeral. Two hundred and fifty is two hundred and fifty." },
		},
		choices = {
			{
				label = "Let her decide",
				result = { money = 250, sanity = -3, relationBond = { kind = "mother", amount = 4 }, log = "She sat for an hour and complained the whole time. In spring the hands were in a gallery, holding a bowl of real noodles." },
			},
			{
				label = "Send him away",
				result = { sanity = 2, relationBond = { kind = "mother", amount = -4 }, log = "You shut the door on the plaster. {mother} said she'd have liked the money, and the company." },
			},
			{
				label = "Ask what the piece is called",
				result = { mind = 2, sanity = -5, log = "\"Her Last Year of Work,\" he said. You asked how he knew. He showed you his notes on her cough." },
			},
		},
	},

	-- ── the Ashgrave Family ──
	{
		id = "ad_c_bf_invite",
		title = "An Invitation to Dine",
		art = "theater",
		text = "A card on heavy red paper: dinner at the old Palais theater, Thursday, eleven sharp. Ysolde of the Ashgrave Family requests the pleasure, and asks you not to bring garlic, as a joke.",
		weight = 8,
		once = true,
		when = { minAge = 20, maxAge = 50, form = "human", flags = { "knows_bloodfiends" } },
		codex = "bf_lore_bloodfiends",
		choices = {
			{
				label = "Go to dinner",
				result = { trigger = "ad_c_bf_dinner", log = "You wore your good coat and arrived at eleven sharp. The doors opened before you knocked." },
			},
			{
				label = "Send your regrets properly",
				result = { sanity = 1, setFlags = { "bf_knows" }, log = "You wrote back in your best hand. A hamper came a week later: \"Another time. There is always another time, for us.\"" },
			},
			{
				label = "Sell the card to a Hunter",
				result = { money = 220, sanity = -5, setFlags = { "ad_sold_ysolde", "bf_knows" }, schedule = { event = "ad_c_bf_rudeness", inYears = 1 }, log = "A Hunter in a long coat paid two hundred for the card and the address. He left on Thursday at half past ten." },
			},
		},
	},
	{
		id = "ad_c_bf_dinner",
		title = "Eleven Sharp",
		art = "theater",
		text = "The table is laid for two in the middle of the stage, and the food is excellent. Ysolde eats nothing, with a red bar in foil by her plate.",
		weight = 0,
		when = { form = "human" },
		codex = "bf_lore_hemobars",
		dialogue = {
			{ who = "ad_ysolde", line = "The Ashgrave keep the rooftops on your street now. The Syndicates have been told. They took it well, mostly." },
			{ who = "ad_ysolde", line = "I'd like a human to sit at the street meetings and speak for us. Someone people believe. I pay in quiet." },
		},
		choices = {
			{
				label = "Accept, with good manners",
				clash = { stat = "mind", foe = "Ashgrave table manners", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, money = 200, setFlags = { "ad_ashgrave_friend", "bf_knows" }, log = "You used the right fork and never asked what was under the silver dome. Your street was very quiet after that." },
				lose = { sanity = -6, setFlags = { "ad_ashgrave_insulted", "bf_knows" }, schedule = { event = "ad_c_bf_rudeness", inYears = 1 }, log = "You lifted the silver dome. It was empty. Ysolde put the lid back very gently and rang for your coat." },
			},
			{
				label = "Decline, and finish the meal",
				result = { sanity = 2, setFlags = { "bf_knows" }, log = "You said no. She said she'd thought you might, and you finished the meal arguing about WARP fares." },
			},
			{
				label = "Ask what happens if you refuse",
				result = { mind = 1, sanity = -4, setFlags = { "bf_knows" }, log = "\"You live,\" she said. \"Longer than you'd like, some days. That's the City's doing, not ours.\"" },
			},
		},
	},
	{
		id = "ad_c_bf_rudeness",
		title = "Rudeness Is Remembered",
		art = "rooftop",
		text = "Something lands on your roof at two in the morning, then something else. Red eyes at the skylight. The Ashgrave do not forget a guest, or a Hunter's coat.",
		weight = 0,
		when = { form = "human" },
		choices = {
			{
				label = "Meet them on the roof",
				clash = { stat = "strength", foe = "Ashgrave Kindred", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "bloodfiend", status = { id = "bleed", potency = 2 } },
				win = { strength = 4, sanity = -5, setFlags = { "ad_ashgrave_feud" }, log = "They left before 3:13 with torn coats and a grudge. Bloodfiends hold grudges a long time. So, it turns out, do you." },
				lose = { health = { -24, -12 }, sanity = -8, cause = "Taught manners by Bloodfiends", log = "They were very fast and very polite about it. You woke at noon, pale and cold, and couldn't get warm all winter." },
			},
			{
				label = "Apologize through the glass",
				clash = { stat = "charisma", foe = "An old grudge", coins = 3, base = 5, coinPower = 3 },
				win = { charisma = 2, sanity = 2, clearFlags = { "ad_ashgrave_insulted" }, log = "You apologized in full sentences. A long silence, then a soft tap: accepted. There was a hamper on the step." },
				lose = { sanity = -8, condition = "night_terrors", log = "They listened, then sat on your roof until 3:10, just so you'd know they could." },
			},
			{
				label = "Lie in the bath until dawn",
				result = { sanity = -10, log = "You lay in the empty bath until morning. Your skylight was spotless when you came out, which was worse." },
			},
		},
	},

	-- ── the Library ──
	{
		id = "ad_c_wrong_door",
		title = "Under the Wrong Door",
		art = "library",
		text = "A gilded envelope is under your door, addressed to Brannoch in 3B, a Grade 7 Fixer who has wanted one of these for a year. It smells of lilies and old paper.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 60, world = { era = "library" }, flags = { "knows_library" } },
		codex = "library_invitations",
		choices = {
			{
				label = "Slide it under his door",
				result = { sanity = -5, log = "You slid it under his door at midnight. At dawn he knocked to show you, glowing. He went that night. His door is still shut." },
			},
			{
				label = "Sell it to a Bookhunter",
				result = { money = { 400, 600 }, sanity = -6, log = "A Bookhunter paid five hundred and never asked whose it was. Brannoch still checks his mail every morning." },
			},
			{
				label = "Keep it in a drawer",
				result = { mind = 2, setFlags = { "kept_invitation" }, log = "You put it under the good spoons. Brannoch never knew. Some nights you take it out and read his name." },
			},
			{
				label = "Burn it",
				result = { sanity = 2, log = "It took a long time to catch. Brannoch got a Grade 6 posting that winter and moved away, still hoping." },
			},
		},
	},

	-- ── L Corp's years ──
	{
		id = "ad_c_lcorp_ration",
		title = "Four Hours of Power",
		art = "home",
		text = "L Corp's quota came in short this quarter, and the Backstreets get power four hours a day. The Nest across the wall is lit like a stage.",
		weight = 9,
		cooldown = 10,
		tags = { "backstreets" },
		when = { minAge = 18, maxAge = 50, side = "backstreets", world = L_CORP_YEARS },
		codex = "lcorp_enkephalin",
		choices = {
			{
				label = "Pay the generator fee",
				result = { money = { -70, -40 }, setFlags = { "knows_lcorp" }, log = "You paid. The landlord's generator ran on the roof every evening, louder than a train, and he bought a new coat." },
			},
			{
				label = "Tap the Nest line",
				clash = { stat = "intelligence", foe = "A Nest power line", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, money = { 40, 80 }, setFlags = { "knows_lcorp" }, log = "You ran a cable over the wall at 2 AM. Half the block had light that season, and paid you in noodles and coins." },
				lose = { health = { -10, -4 }, condition = "burns", setFlags = { "knows_lcorp" }, cause = "Tapped a Nest power line", log = "The Nest line was live in a way Backstreets lines never are. You lost your eyebrows and the use of your hands for a season." },
			},
			{
				label = "Give your hours to the clinic",
				result = { strength = 1, sanity = 4, setFlags = { "knows_lcorp" }, log = "You signed your four hours over to the clinic on Ninth and read by candle all season. The clinic didn't lose anyone to the dark." },
			},
		},
	},
	{
		id = "ad_c_lcorp_clerk",
		title = "What the Clerk Saw",
		art = "home",
		text = "Sola from downstairs is a clerk at Lobotomy Corporation. She comes home at noon, which she never does, and sits on the stairs holding her shoes.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 45, world = L_CORP_YEARS, flags = { "knows_lcorp" } },
		codex = "lcorp_abnormalities",
		dialogue = {
			{ who = "ad_sola", line = "We're not allowed to say what's in the units. So I won't. Something was out of one today, and it sang." },
			{ who = "A Journalist", line = "Two hundred Ahn for the name of anyone who works in that building. Nobody gets hurt. It's a story." },
		},
		choices = {
			{
				label = "Sell the journalist her name",
				result = { money = 200, sanity = -8, setFlags = { "ad_sold_sola" }, log = "The story ran with no names in it. Sola didn't come home the next week. A man from L Corp packed her things very carefully." },
			},
			{
				label = "Help her resign",
				clash = { stat = "mind", foe = "An L Corp contract", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 3, addRelation = { kind = "friend", name = "Sola", bond = 60, age = { 22, 30 } }, log = "You found the clause on notice periods. She left on full pay and took a job at a laundry. She slept like a stone." },
				lose = { sanity = -4, log = "There was a clause about resigning. It was longer than the contract. Sola went back on Monday." },
			},
			{
				label = "Sit with her, say nothing",
				result = { sanity = 2, log = "You sat on the stairs with her until the lights went off at ten. She hummed something you didn't know, then stopped." },
			},
		},
	},

	-- ── the Night, as an adult ──
	{
		id = "ad_c_room_for_one",
		title = "Room for One",
		art = "night",
		text = "3:11. Two people are hammering on your door: a Thumb Soldato who fined you last spring, and the Rat who robbed you on Fifth Street. Your room fits one more, and they hate each other.",
		weight = 9,
		cooldown = 10,
		tags = { "backstreets" },
		when = { minAge = 18, maxAge = 55, side = "backstreets", flags = { "knows_night", "knows_thumb" } },
		codex = "city_sweepers",
		choices = {
			{
				label = "Let the Soldato in",
				result = { money = { 60, 120 }, sanity = -6, setFlags = { "thumb_respect" }, log = "The Soldato stepped in and bowed. Outside, the hammering stopped at 3:13. In the morning he paid for your trouble." },
			},
			{
				label = "Let the Rat in",
				result = { strength = 1, sanity = -4, setFlags = { "fn_thumb_disrespected" }, log = "The Rat cried on your floor until dawn and swore he'd never rob anyone again. The Thumb noted which door hadn't opened." },
			},
			{
				label = "Let them both in",
				clash = { stat = "mind", foe = "A Soldato and a Rat in one room", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 3, sanity = 2, chronicle = "opened_door_night", log = "You sat between them on the floor until 4:33. Nobody spoke. They left in opposite directions, each owing you." },
				lose = { health = { -10, -4 }, money = { -60, -30 }, sanity = -4, cause = "Shared a room with enemies during the Night", log = "They fought in your kitchen in total silence until dawn. You couldn't put either out. Your table didn't make it." },
			},
		},
	},
	{
		id = "ad_c_until_255",
		title = "Until 2:55",
		art = "workshop",
		text = "A Nest client will pay triple if their order is finished tonight. Your boss has gone home. The clock says 1:40, and it's a twenty-minute walk to your door.",
		weight = 8,
		cooldown = 8,
		tags = { "backstreets" },
		when = { minAge = 18, maxAge = 40, side = "backstreets", career = { "workshop", "diner", "courier" }, flags = { "knows_night" } },
		choices = {
			{
				label = "Finish it",
				clash = { stat = "intelligence", foe = "An order and a clock", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.4, log = "Done at 2:41. You ran home past the shutters coming down and had your third lock turned at 3:02." },
				lose = { health = { -12, -6 }, sanity = -6, condition = "night_terrors", cause = "Ran home through the Night", log = "You finished at 3:04. You don't remember the run home. You woke inside with your shoes gone and the door locked." },
			},
			{
				label = "Go home at two, unfinished",
				result = { money = { -40, -20 }, log = "You left it half done. The client complained in writing, and your boss pinned the letter up with your name underlined." },
			},
			{
				label = "Finish late and sleep there",
				result = { health = -2, sanity = -4, paycheck = 0.3, log = "You finished at 3:30 and slept under the counter. Something tried the shop door twice in the third wave, very gently." },
			},
		},
	},

	-- ── rent and the landlord ──
	{
		id = "ad_c_pask_behind",
		title = "Three Months Behind",
		art = "home",
		text = "You're three months behind on rent, and Mr. Pask isn't angry. He has a proposal, and a crowbar for the old man in 5A, who is five months behind.",
		weight = 10,
		once = true,
		tags = { "backstreets" },
		when = { minAge = 18, maxAge = 35, side = "backstreets" },
		dialogue = {
			{ who = "ad_pask", line = "Help me clear 5A on Monday and we'll call your three months square. He's got a daughter in District 9. He'll be fine." },
		},
		choices = {
			{
				label = "Clear 5A with him",
				result = { money = 150, sanity = -8, setFlags = { "ad_cleared_5a" }, log = "The old man went without a fuss, which was worse. Pask called your three months square. The daughter in District 9 never wrote." },
			},
			{
				label = "Pay what you can",
				result = { money = { -160, -100 }, log = "You emptied the jar on the shelf and paid. Pask cleared 5A on Monday with somebody else's help." },
			},
			{
				label = "Stand with 5A",
				clash = { stat = "mind", foe = "A landlord with a crowbar", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, strength = 2, log = "On Monday you had forty neighbors on the landing. Pask put the crowbar away and wrote you both payment plans." },
				lose = { money = { -200, -120 }, sanity = -5, log = "Pask cleared 5A, then raised your rent for administration. The old man thanked you on the stairs anyway." },
			},
		},
	},

	-- ── the Associations ──
	{
		id = "ad_c_zwei_post",
		title = "Hold My Post",
		art = "street",
		text = "A Zwei Fixer guarding the clinic on Ninth grabs your sleeve. Her father is dying across the District, and her relief is two hours late.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 35, flags = { "knows_fixers" } },
		codex = "fx_lore_zwei",
		dialogue = {
			{ who = "zwei_fixer", line = "Wear my coat and stand here two hours. Look like a shield. Nobody tests Zwei." },
			{ who = "zwei_fixer", line = "If someone does test us, you're the shield. I'm sorry. I have to go." },
		},
		choices = {
			{
				label = "Wear the coat",
				clash = { stat = "strength", foe = "Two Hounds testing the Zwei", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "syndicate", status = { id = "tremor", potency = 1 } },
				win = { strength = 3, money = 120, setFlags = { "ad_zwei_owes" }, log = "Two Hounds tested the post at the ninety-minute mark and left with a story. She came back red-eyed and paid you double." },
				lose = { health = { -14, -6 }, sanity = -4, cause = "Stood a Zwei post without being Zwei", log = "The Hounds tested the post and found out it was you. She came back to a broken door and her coat on the step." },
			},
			{
				label = "Say no",
				result = { sanity = -3, log = "You said no. She stood her post until her relief came in the third hour. You never found out if she made it in time." },
			},
			{
				label = "Report her to her Section",
				result = { money = 80, sanity = -6, log = "Her Section paid eighty for the report and docked her a grade. She stood her post. Her father died without her." },
			},
		},
	},
	{
		id = "ad_c_shi_noodles",
		title = "You Saw It",
		art = "diner",
		text = "Last night you saw a Shi Fixer finish a contract in the alley behind your building. Tonight she's on the stool next to yours at the noodle stall, eating slowly.",
		weight = 8,
		once = true,
		when = { minAge = 18, maxAge = 45, flags = { "knows_fixers" } },
		codex = "fx_lore_shi",
		dialogue = {
			{ who = "shi_assassin", line = "Good broth here. I come for the broth. Sometimes for other things." },
			{ who = "shi_assassin", line = "What did you see last night?" },
		},
		choices = {
			{
				label = "\"Nothing. I was asleep.\"",
				clash = { stat = "mind", foe = "A Shi who watches mouths", coins = 3, base = 5, coinPower = 3 },
				win = { mind = 3, sanity = -3, log = "\"Good,\" she said, and paid for your bowl. You never saw her again, which is how you know it worked." },
				lose = { sanity = -6, condition = "dz_hunted", log = "She smiled and finished her broth. For a season you felt eyes on your neck every time you locked your door." },
			},
			{
				label = "Ask what silence costs",
				result = { money = 300, sanity = -6, setFlags = { "ad_shi_paid" }, log = "She slid three hundred Ahn under your bowl without looking at it. \"It costs that,\" she said. \"And it costs it forever.\"" },
			},
			{
				label = "Throw the broth and run",
				clash = { stat = "speed", foe = "A Shi Fixer", coins = 3, base = 6, coinPower = 4, fight = true, enemy = "shi_assassin", status = { id = "poise", potency = 3 } },
				win = { speed = 4, sanity = -6, condition = "dz_hunted", log = "Hot broth and luck. You were three streets off before she'd wiped her eyes. The Shi keep a list of lucky people." },
				lose = { health = { -24, -12 }, sanity = -8, cause = "Threw broth at a Shi Fixer", log = "She moved before the bowl left your hand. You woke in the clinic with your bill already paid." },
			},
		},
	},
	{
		id = "ad_c_seven_notes",
		title = "Seven Reads People",
		art = "diner",
		text = "A Seven Association investigator in grey glasses has taken the booth across from yours every morning for a week. Today he slides over a notebook with your neighbor's name on it.",
		weight = 8,
		once = true,
		when = { minAge = 35, maxAge = 55, flags = { "knows_fixers" } },
		codex = "fx_lore_seven",
		dialogue = {
			{ who = "seven_fixer", line = "When she leaves, when she comes back, who visits. Two hundred Ahn a week. It's only seeing. You do it already." },
		},
		choices = {
			{
				label = "Fill the notebook",
				result = { money = 400, sanity = -7, setFlags = { "ad_seven_notes" }, log = "You filled it for two weeks. In the third, your neighbor's flat was empty and very clean. Seven paid in full." },
			},
			{
				label = "Fill it with a boring life",
				clash = { stat = "mind", foe = "An investigator who checks", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 3, money = 200, log = "You wrote her a beautiful, dull life. Seven paid for one week and closed the file." },
				lose = { money = -100, sanity = -5, condition = "dz_hunted", log = "He checked. Seven always checks. He billed you for his wasted week and started a page about you." },
			},
			{
				label = "Warn your neighbor",
				result = { strength = 2, sanity = 1, log = "You told her about the man in the booth. She thanked you, and was gone the next day. She left you her plants." },
			},
		},
	},
	{
		id = "ad_c_devyat_parcel",
		title = "Forty Minutes",
		art = "street",
		text = "A Devyat' courier sits down hard on your step, grey in the face. His trunk is humming, and a voice inside it is counting down: forty minutes to the drop, three streets over.",
		weight = 8,
		once = true,
		when = { minAge = 18, maxAge = 40, flags = { "knows_fixers" } },
		codex = "fx_lore_devyat",
		dialogue = {
			{ who = "The Courier", line = "Poludnitsa. She doesn't care who carries it, only that it's on time. Please. They'll have my license." },
		},
		choices = {
			{
				label = "Run it there",
				clash = { stat = "speed", foe = "Three streets and a deadline", coins = 2, base = 4, coinPower = 3 },
				win = { speed = 2, money = 250, log = "You made the drop with ninety seconds to spare. The trunk said thank you in a woman's voice and paid you itself." },
				lose = { health = { -10, -4 }, sanity = -5, cause = "Ran a Devyat' trunk against the clock", log = "Four minutes late. The trunk got very hot, very fast. You dropped it in a rain barrel and ran." },
			},
			{
				label = "Open the trunk",
				result = { mind = 2, sanity = -6, log = "Inside was one envelope and a lot of humming dark. The voice stopped counting and said your name. You shut it." },
			},
			{
				label = "Call his Association",
				result = { sanity = -2, log = "A Devyat' Section van came in six minutes and took the trunk and the courier. They thanked you for the trunk." },
			},
		},
	},
	{
		id = "ad_c_exam_ring",
		title = "Exam Season",
		art = "school",
		text = "A man at the academy gates is recruiting stand-ins for Hana's license exam: sit it under someone else's name, pass, take four hundred Ahn. He swears Hana never checks faces.",
		weight = 8,
		once = true,
		when = { minAge = 18, maxAge = 30, flags = { "knows_fixers" }, notFlags = { "licensed_fixer" } },
		codex = "fixers_hana",
		choices = {
			{
				label = "Sit it as someone else",
				clash = { stat = "mind", foe = "Hana's examiners", coins = 3, base = 5, coinPower = 3 },
				win = { money = 400, mind = 2, sanity = -5, setFlags = { "ad_exam_standin" }, log = "You passed as Rudi Vass. Somewhere a Rudi Vass with no talent for it is a licensed Fixer now. You hope he's careful." },
				lose = { money = { -200, -100 }, sanity = -6, setFlags = { "ad_hana_banned" }, log = "Hana checks faces. Hana checks everything. You're banned from the exam for life, in writing, with a photograph." },
			},
			{
				label = "Report the man at the gate",
				result = { money = 100, sanity = -3, log = "Hana paid a hundred for the tip. The man was a student short of his fees. He sat the exam himself next year, and failed." },
			},
			{
				label = "Walk past",
				result = { sanity = 1, log = "You walked past. Behind you he was already talking to someone with a better memory and worse luck." },
			},
		},
	},

	-- ── the Distortion era ──
	{
		id = "ad_c_lccb_guide",
		title = "Local Guide Wanted",
		art = "ruins",
		text = "A Limbus Company Before Team needs a local who knows the old service tunnels, and one night pays a month's wages. Their last guide is on a poster by the door.",
		weight = 8,
		once = true,
		when = { minAge = 20, maxAge = 45, world = LIMBUS, flags = { "knows_limbus" } },
		codex = "lim_departments",
		dialogue = {
			{ who = "The Assistant Manager", line = "Preliminary Observation. You walk in front, we walk behind, we write down what happens. Mostly nothing happens." },
		},
		choices = {
			{
				label = "Guide them in",
				clash = { stat = "strength", foe = "Peccatula in the tunnels", coins = 2, base = 4, coinPower = 3, fight = true, enemy = "peccatula", status = { id = "rupture", potency = 2 } },
				win = { strength = 3, money = 280, setFlags = { "lim_lccb_contact" }, log = "Something with branches went for the lamp and you put it down. The Before Team wrote it all up and paid you in a sealed envelope." },
				lose = { health = { -14, -6 }, sanity = -6, setFlags = { "lim_lccb_contact" }, cause = "Guided a Limbus team into the tunnels", log = "The branches were faster in the dark. The Before Team wrote that down too." },
			},
			{
				label = "Sell them a map",
				clash = { stat = "intelligence", foe = "Twenty years of tunnels, from memory", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, money = 150, log = "You drew every turn you remembered. They came back with all their people and a crate, and sent you a card." },
				lose = { money = 50, sanity = -5, log = "You drew the tunnels as they were when you were twelve. Two turns had moved. They paid fifty, for the effort." },
			},
			{
				label = "Send them to Old Benno",
				result = { sanity = -4, log = "You sent them to Old Benno, who knew the tunnels better and needed the money more. His face went on the poster in spring." },
			},
		},
	},
	{
		id = "ad_c_lcd_bounty",
		title = "Three Signs Out of Seven",
		art = "street",
		text = "The LCD poster in the break room lists seven early signs of Distortion. Your coworker Magnus has three. He keeps calling the foreman by his dead father's name.",
		weight = 9,
		once = true,
		when = { minAge = 18, maxAge = 50, world = LIMBUS, anyCareer = true, flags = { "knows_distortions" } },
		codex = "lim_distortion_stages",
		choices = {
			{
				label = "Call the number on the poster",
				result = { money = 150, sanity = -6, setFlags = { "knows_limbus" }, log = "The LCD paid a reporting fee. Two people in grey coats took Magnus for observation at lunch. He waved from the van." },
			},
			{
				label = "Talk to him after the shift",
				clash = { stat = "charisma", foe = "A man at the edge", coins = 3, base = 5, coinPower = 3 },
				win = { charisma = 3, sanity = 3, setFlags = { "lim_talked_down" }, log = "You walked him home and let him talk about his father until 2 AM. By spring his shadow kept up with him." },
				lose = { sanity = -8, setFlags = { "knows_limbus" }, log = "He listened to all of it, nodding, and his shadow nodded a half-second later. On Monday the LCD came instead of Magnus." },
			},
			{
				label = "Keep your head down",
				result = { sanity = -3, log = "You kept your head down. So did everyone. In the end the foreman called it in, the day Magnus called him Dad to his face." },
			},
		},
	},

	-- ── a child on Platform Six ──
	{
		id = "ad_c_platform_kid",
		title = "Left on Platform Six",
		art = "train",
		text = "A girl of about seven is sitting on her suitcase on WARP Platform Six. Her parents came off a DELAYED train this morning and walked past her.",
		weight = 7,
		once = true,
		when = { minAge = 24, maxAge = 40, flags = { "knows_wings" }, notFlags = { "ad_raising" }, noRelation = "child" },
		codex = "wg_lore_train_states",
		dialogue = {
			{ who = "ad_fenwick", line = "W Corp is not a guardian service. The foundling house collects at five. I'll hold her till then. Policy, mostly." },
			{ who = "The Girl", line = "They said I was too big to be theirs. I'm not too big. I'm seven." },
		},
		choices = {
			{
				label = "Take her home",
				result = { addRelation = { kind = "child", age = { 7, 7 }, bond = 55 }, setFlags = { "parent", "ad_raising" }, money = { -60, -30 }, sanity = 5, schedule = { { event = "ad_l_raising_rules", inYears = 2 }, { event = "ad_l_raising_card", inYears = 5 }, { event = "ad_l_raising_late", inYears = 8 } }, log = "You carried the suitcase. She carried her own coat. She asked you to pick her a name nobody else had: {newRelation}." },
			},
			{
				label = "Find her parents",
				clash = { stat = "mind", foe = "Two strangers who used to be parents", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 3, log = "You found them at a hostel by the platform. They didn't know her. They took her anyway, carefully, like a parcel, and kept her." },
				lose = { sanity = -6, log = "You found the hostel. They'd taken the WARP again that morning, somewhere else. The foundling house came at five." },
			},
			{
				label = "Leave her with Fenwick",
				result = { sanity = -5, log = "You left her with Fenwick, who gave her his coat to sit on. You took the next train. She was still waving." },
			},
		},
	},

	-- ── short ones ──
	{
		id = "ad_c_tx_board",
		title = "Board Day",
		art = "diner",
		text = "The noodle stall radio reads out Hana's new board. A boy you sat beside at the academy is Grade 4 now. The cook turns it up for his name.",
		weight = 6,
		once = true,
		when = { minAge = 22, maxAge = 40, flags = { "knows_fixers" } },
		result = { sanity = 1, log = "You left an extra coin on the counter for luck. His, not yours." },
	},
	{
		id = "ad_c_tx_bell",
		title = "Tribute Bell",
		art = "street",
		text = "Every Tuesday a Soldato rings a little brass bell at the end of your street and everyone brings out an envelope. This Tuesday the Soldato is new, and rings it too fast.",
		weight = 6,
		once = true,
		when = { minAge = 18, maxAge = 50, side = "backstreets", flags = { "knows_thumb" } },
		result = { mind = 1, sanity = -1, log = "Nobody corrected him. The next Tuesday he rang it at the proper speed, with a bandage on one hand." },
	},
	{
		id = "ad_c_tx_power",
		title = "4:12",
		art = "street",
		text = "At 4:12 the power comes back all at once, every bulb in the street, and a radio blares in the middle of a song. The whole block cheers out of its windows.",
		weight = 6,
		once = true,
		when = { minAge = 18, maxAge = 50, side = "backstreets", world = L_CORP_YEARS },
		result = { sanity = 3, setFlags = { "knows_lcorp" }, log = "Down the street somebody shouted \"Thank you, L Corp!\" and somebody else threw a shoe at him." },
	},
	{
		id = "ad_c_tx_gutter",
		title = "In the Gutter",
		art = "street",
		text = "Something the size of a cat, with cracks of red light down its back, is drinking from the gutter. A kid with a broom is chasing it, and winning.",
		weight = 6,
		once = true,
		when = { minAge = 18, maxAge = 50, world = LIMBUS, flags = { "knows_distortions" } },
		codex = "lim_peccatula",
		result = { sanity = 1, log = "It went down the drain. The kid took a bow. An LCD van arrived twenty minutes later and fined the drain." },
	},
}
