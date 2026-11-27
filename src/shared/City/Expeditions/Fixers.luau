--[[
	Expeditions for Fixers and the Fingers: a contract (an escort racing the Night), an Office
	raid (a crooked Office's ledger), and a Syndicate job (the Thumb's ammunition run, which also
	settles a debt to the Thumb and finishes a step of the apology quest).
	{ order = {...}, [id] = expedition }; see docs/CONTENT_GUIDE.md.
]]

return {
	order = { "fx_exp_night_escort", "fx_exp_office_raid", "fn_exp_ammo_run" },

	fx_exp_night_escort = {
		name = "A Contract: The Late Escort",
		kind = "mission",
		desc = "A jeweler needs a locked case carried across the District tonight and is paying licensed Fixers to walk her there. The route crosses Rat territory, a rival Office and, if you're slow, the Night, which arrives at 3:13 whether you're finished or not.",
		minAge = 16,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 4,
		when = { flags = { "licensed_fixer" } },
		start = "pickup",
		stages = {
			pickup = {
				title = "The Jeweler",
				text = "The jeweler is a nervous woman named Odile with a case chained to her wrist and a fresh crack in her shop window. She has hired {crew} to get her across the District to a buyer before the Night. \"Nobody knows what's in the case,\" she says, \"except, apparently, everyone.\"",
				choices = {
					{
						label = "Scout the route first",
						clash = { stat = "mind", foe = "A dozen ways across the District", coins = 2, base = 4, coinPower = 3 },
						win = { mind = 1, log = "{champion} found a route through two laundries and a shrine that the Rats never use." },
						lose = { sanity = -2, log = "Every route on the map had a Rat on it. {crew} picked the least bad one." },
						next = "alley",
					},
					{
						label = "Set off at once",
						result = { log = "{crew} set off at once, with Odile in the middle and the case under a coat." },
						next = "alley",
					},
				},
			},
			alley = {
				title = "Rats in the Alley",
				tone = "danger",
				text = "Halfway there, a pack of Rats steps out of an alley in front, and another behind. They aren't after Odile's purse. They know about the case. The one with the crowbar looks as if he's been waiting all day to use it.",
				choices = {
					{
						label = "Fight through",
						clash = { stat = "strength", foe = "Two packs of Rats", coins = 2, base = 5, coinPower = 3, fight = true, status = "bleed" },
						win = { strength = 1, log = "{champion} went through the front pack like a door. The back pack decided it had somewhere else to be." },
						lose = { health = { -7, -2 }, log = "The Rats landed a few blows before they scattered. The case stayed shut. Odile stayed upright, barely.", cause = "Fell escorting a client" },
						next = "rival",
					},
					{
						label = "Bluff them with a license",
						clash = { stat = "mind", foe = "Rats who've seen licenses before", coins = 2, base = 4, coinPower = 3 },
						win = { log = "{champion} held up a license and named a grade with total confidence. The Rats did the sums and melted away." },
						lose = { health = { -5, -2 }, log = "These Rats had seen licenses before. It took a scuffle to make the point." },
						next = "rival",
					},
				},
			},
			rival = {
				title = "Brasshand Wants the Client",
				text = "Near the bridge, three Fixers from Brasshand Office are waiting. They've heard about the case too, and they'd like Odile to switch Offices for the last half mile, for a fee she can pay later. Their Rep smiles at {crew} like a man who has never filed an honest report.",
				choices = {
					{
						label = "Talk them off the bridge",
						clash = { stat = "mind", foe = "A Brasshand Rep", coins = 2, base = 5, coinPower = 3 },
						win = { log = "{champion} reminded the Rep that Hana reads every report, including the ones about poaching clients. Brasshand stepped aside." },
						lose = { money = -30, log = "The talk cost a toll. Odile paid it, unhappily, and docked it from the fee." },
						next = "clock",
					},
					{
						label = "Push past them",
						clash = { stat = "strength", foe = "Three Brasshand Fixers", coins = 3, base = 5, coinPower = 3, fight = true, status = "rupture" },
						win = { strength = 1, log = "Brasshand learned that this client was taken." },
						lose = { health = { -7, -2 }, log = "Brasshand didn't win, exactly, but they made {crew} pay for the bridge.", cause = "Fell escorting a client" },
						next = "clock",
					},
				},
			},
			clock = {
				title = "2:58",
				tone = "danger",
				text = "The buyer's door is four streets away and the tower clock says 2:58. The Sweepers rise at 3:13. Odile is out of breath, and the case on her wrist is heavier than it looks. {crew} can run for the door, or shelter in the shrine on the corner and finish at dawn.",
				choices = {
					{
						label = "Run for the buyer's door",
						clash = { stat = "strength", foe = "The tower clock", coins = 2, base = 5, coinPower = 3 },
						win = { wage = { 40, 80 }, log = "{crew} reached the door at 3:09, with Odile and the case. The buyer paid a bonus for the drama." },
						lose = { health = { -8, -3 }, sanity = -4, log = "The first wave rose as the door opened. Everyone got inside. Not everyone stopped shaking.", cause = "Caught outside during the Night" },
						["end"] = "success",
					},
					{
						label = "Shelter in the shrine",
						result = { sanity = 2, log = "{crew} sheltered in the shrine with Odile while the waves passed. At dawn the case was delivered, late and intact." },
						["end"] = "success",
					},
				},
			},
		},
		success = { wage = { 120, 220 }, sanity = 2, codex = "fx_lore_reports", log = "Odile paid in full and wrote to your Office to say so, which made a very good line in the job report." },
		fail = { sanity = -3, log = "The contract fell apart. Odile hired someone else for the next one." },
		retreat = { sanity = -1, log = "{crew} brought Odile home. She paid a cancellation fee and locked her door three times." },
	},

	fx_exp_office_raid = {
		name = "Office Raid: Brasshand's Ledger",
		kind = "dungeon",
		desc = "Brasshand Office keeps a ledger of every shopkeeper it squeezes. A client has paid for that ledger to vanish from Brasshand's safe and turn up on Hana's desk. Getting it means going in through Brasshand's own front door after hours.",
		minAge = 18,
		cooldown = 4,
		crew = { min = 1, max = 4 },
		length = 4,
		when = { flags = { "licensed_fixer" } },
		start = "watch",
		stages = {
			watch = {
				title = "The Shift Change",
				text = "Brasshand Office fills a whole narrow building. From a noodle stall across the street, {crew} watch the shift change: Fixers out, hired muscle in, one light left burning on the top floor where the Rep keeps his safe.",
				choices = {
					{
						label = "Time the patrols",
						clash = { stat = "mind", foe = "Brasshand's routine", coins = 2, base = 4, coinPower = 3 },
						win = { mind = 1, log = "{champion} timed every patrol to the minute. There was a four-minute gap at the coal chute." },
						lose = { sanity = -1, log = "The patrols kept changing. {crew} would have to go in guessing." },
						next = "door",
					},
					{
						label = "Go in now",
						result = { log = "{crew} finished their noodles, paid, and crossed the street." },
						next = "door",
					},
				},
			},
			door = {
				title = "Hired Muscle",
				tone = "danger",
				text = "Brasshand has hired a Liu brawler to watch the front door, a big, cheerful man whose weapon has a fuel line running into the grip. He sees {crew}, sighs, and puts down his bun. \"I was having such a nice evening,\" he says.",
				choices = {
					{
						label = "Fight him at the door",
						clash = { stat = "strength", foe = "A Liu brawler", coins = 3, base = 5, coinPower = 3, fight = true, status = "burn" },
						win = { strength = 1, log = "{champion} got through the brawler and his incendiaries. He took it well, for a man who'd been set on fire by his own weapon." },
						lose = { health = { -8, -3 }, condition = "burns", log = "The brawler's weapon lit the doorway. {crew} got past him, singed.", cause = "Burned in an Office raid" },
						next = "floor",
					},
					{
						label = "Use the coal chute",
						clash = { stat = "intelligence", foe = "A very narrow coal chute", coins = 2, base = 4, coinPower = 3 },
						win = { log = "{crew} slid down the coal chute and came up in the boiler room, filthy and unseen." },
						lose = { health = { -4, -1 }, sanity = -2, log = "The chute was narrower than it looked. {crew} came out bruised, black with coal, and late." },
						next = "floor",
					},
				},
			},
			floor = {
				title = "The Office Floor",
				text = "The office floor is all desks and filing cabinets, and four Brasshand Fixers are working late, filing reports that don't match anything that happened. They look up at {crew}. One reaches for a sword, one for a pistol, and one, very sensibly, for the fire bell.",
				choices = {
					{
						label = "Fight across the office",
						clash = { stat = "strength", foe = "Four Brasshand Fixers", coins = 3, base = 6, coinPower = 3, fight = true, status = "rupture" },
						win = { strength = 1, log = "Desks went over, reports went everywhere, and the four Fixers went out a window onto the awning below." },
						lose = { health = { -9, -3 }, log = "Brasshand fought harder for its desks than anyone expected. {crew} reached the stairs, bruised but moving.", cause = "Fell in an Office raid" },
						next = "ledger",
					},
					{
						label = "Ring the fire bell first",
						clash = { stat = "mind", foe = "Four suspicious Fixers", coins = 2, base = 5, coinPower = 3 },
						win = { log = "{champion} rang the fire bell before they could. Brasshand's Fixers ran out into the street, shouting about fire, while {crew} went up." },
						lose = { sanity = -2, health = -3, log = "Nobody believed in the fire. They believed in {crew}. It took a scuffle on the stairs." },
						next = "ledger",
					},
				},
			},
			ledger = {
				title = "The Ledger",
				text = "The Rep's office smells of mint tea and fear. The ledger is in a heavy safe behind his desk. Through the window you can hear Brasshand's Fixers coming back up the street. There is time to do this well, or time to do it fast.",
				choices = {
					{
						label = "Crack the safe",
						clash = { stat = "intelligence", foe = "A Workshop safe", coins = 2, base = 5, coinPower = 3 },
						win = { intelligence = 1, log = "The safe opened on the third try. {crew} took the ledger and left everything else exactly where it was." },
						lose = { sanity = -2, log = "The safe beat {champion}. {crew} pried the ledger out through a hinge, which was loud, and worked." },
						["end"] = "success",
					},
					{
						label = "Carry the whole safe out",
						clash = { stat = "health", foe = "A very heavy safe", coins = 2, base = 5, coinPower = 3 },
						win = { health = 1, log = "{crew} carried the whole safe down four flights and out the back. The Rep came home to an empty wall." },
						lose = { health = { -6, -2 }, log = "The safe went down the stairs faster than {crew} did. The ledger survived. Everyone's backs did not." },
						["end"] = "success",
					},
				},
			},
		},
		success = { wage = { 200, 340 }, sanity = 2, chronicle = "fx_office_raided", log = "You delivered Brasshand's ledger to Hana in the morning. By the end of the week Brasshand had dropped two grades, and forty shopkeepers had their debts struck out." },
		fail = { sanity = -4, log = "The raid failed. Brasshand moved its ledger, and its Rep knows your face now." },
		retreat = { sanity = -1, log = "{crew} pulled out before it went wrong. The client wasn't happy, but everyone walked home." },
	},

	fn_exp_ammo_run = {
		name = "An Ammunition Run",
		kind = "mission",
		desc = "The Thumb needs crates of propellant rounds carried from a depot to a Capo's table across the District, and it hires outsiders who owe it a favor, or need the Ahn. Bullets are expensive. Losing one is not an option. Bowing badly is not an option either.",
		minAge = 16,
		cooldown = 3,
		crew = { min = 1, max = 3 },
		length = 4,
		when = { side = "backstreets" },
		start = "depot",
		stages = {
			depot = {
				title = "The Depot",
				text = "A Soldato Quarto hands {crew} six crates and a ledger to sign. Every round is numbered. Every number will be checked at the other end, by people who are very good at counting and very bad at forgiving.",
				choices = {
					{
						label = "Count every round",
						clash = { stat = "intelligence", foe = "Six crates of numbered rounds", coins = 2, base = 4, coinPower = 3 },
						win = { intelligence = 1, log = "{champion} counted every round and found the depot twelve short. The Soldato Quarto corrected the ledger and looked at {crew} with new respect." },
						lose = { sanity = -2, log = "{champion} lost count at four hundred and signed anyway. That would have to be someone else's problem." },
						next = "turf",
					},
					{
						label = "Sign and go",
						result = { log = "{crew} signed the ledger and lifted the crates. They were heavier than they looked, like everything the Thumb hands you." },
						next = "turf",
					},
				},
			},
			turf = {
				title = "Tin Crow Turf",
				tone = "danger",
				text = "The shortest route runs through streets held by the Tin Crows, a small Syndicate that exists by the Thumb's permission and resents it. Three Crows are lounging on the corner with knives, watching the crates with great interest.",
				choices = {
					{
						label = "Slip through the back alleys",
						clash = { stat = "mind", foe = "Crows on every corner", coins = 2, base = 5, coinPower = 3 },
						win = { log = "{crew} went through laundries, kitchens and one very surprised family's back room. The Crows never saw the crates." },
						lose = { sanity = -2, health = -2, log = "A Crow spotted {crew} in the last alley. It took a sprint and a dropped crate lid to get clear." },
						next = "toll",
					},
					{
						label = "Walk straight through",
						clash = { stat = "strength", foe = "Three Tin Crows", coins = 2, base = 5, coinPower = 3, fight = true, status = "bleed" },
						win = { strength = 1, log = "The Crows tried their luck. Then they tried running. The Thumb will hear about the attempt, and the Crows know it." },
						lose = { health = { -7, -2 }, log = "The Crows didn't get a single crate, but they got some of {crew}.", cause = "Cut down on a Thumb delivery" },
						next = "toll",
					},
				},
			},
			toll = {
				title = "The Kurokumo Bridge",
				text = "The only bridge across the canal is Kurokumo ground tonight. Two Wakashu in wave-patterned coats ask for a toll on Thumb cargo, which is either a misunderstanding or the first move in a very old argument between two very large Syndicates.",
				choices = {
					{
						label = "Pay the toll",
						result = { money = -30, log = "{crew} paid thirty Ahn. The Wakashu bowed. The Thumb will consider this a debt the Clan owes it, which is not {crew}'s problem." },
						next = "table",
					},
					{
						label = "Cite the Thumb's agreement, and bow",
						clash = { stat = "mind", foe = "Two proud Wakashu", coins = 2, base = 5, coinPower = 3 },
						win = { mind = 1, log = "{champion} named the agreement between the Thumb and the Clan, the right clause, and bowed exactly right. The Wakashu stepped aside." },
						lose = { money = -50, sanity = -2, log = "The Wakashu had never heard of the agreement, or chose not to have. The toll doubled." },
						next = "table",
					},
				},
			},
			table = {
				title = "The Capo's Table",
				text = "The crates go down in front of the Capo's table at last. He doesn't look at {crew}; a Capo doesn't look at couriers. A Soldato opens the ledger and begins to count. Everyone at the table watches to see how {crew} bow.",
				choices = {
					{
						label = "Bow exactly right",
						clash = { stat = "mind", foe = "A Capo's table", coins = 2, base = 4, coinPower = 3 },
						win = { setFlags = { "thumb_respect" }, sanity = 2, log = "One bow, the correct depth, eyes on the third button. The Capo moved one finger. The Soldati relaxed." },
						lose = { sanity = -3, log = "The bow was a little deep. A Soldato coughed. The Capo let it go, this once." },
						["end"] = "success",
					},
					{
						label = "Bow, and step back quickly",
						result = { log = "{crew} bowed and stepped back, out of the light. The count came out right. That was enough." },
						["end"] = "success",
					},
				},
			},
		},
		success = { wage = { 80, 160 }, clearFlags = { "fn_owes_thumb" }, cure = "fn_thumb_interest", removeTrait = "in_debt_to_the_thumb", codex = "fn_lore_thumb_ranks", log = "Every crate arrived. The Capo didn't look at you, which on the Thumb's streets is praise. Whatever you owed the Thumb, the Soldato with the ledger ruled it out." },
		fail = { sanity = -4, log = "The run failed. The Thumb is patient, and it has written down the number of every missing round." },
		retreat = { sanity = -2, log = "{crew} brought the crates back to the depot. The Soldato Quarto counted them, said nothing, and wrote something down." },
	},
}
