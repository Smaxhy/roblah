--[[
	Undertow Line career events (career "conductor"). The Sluice Authority's sealed
	express cars run on cables through the drowned aqueducts under every Ward, and out
	under the crater wall to the Salt Flats (see the expedition undertow_saltflats).
	Conductors punch tickets, keep the peace, and never open a door between stations.
	Ids and flags are prefixed cond_.

	Threads:
		cond_early_train (sets cond_rode_early) -> cond_early_again (3 yrs)
		cond_fare_dodgers can add a rival, Pellam Rook
	Also: cond_recruit (a job offer to anyone who isn't a conductor), cond_breach_freight
	(only during the breach_tidewell world event). cond_keeping_pace has a choice for
	tw_umber_free, set in Events/Tidewell.luau.
]]

return {
	-- Recruitment ------------------------------------------------------------
	{
		id = "cond_recruit",
		title = "Ticket Punches Wanted",
		text = "A Sluice Authority poster on the stairs down to Platform Nine: TICKET PUNCHES WANTED FOR THE UNDERTOW LINE. Good boots, a loud voice, no fear of the dark, or at least no showing it. A Line Master with a brass ticket punch on a chain is reading the poster too, and asks whether you've ever been underwater in an iron box.",
		weight = 3,
		once = true,
		tags = { "career", "recruit", "conductor" },
		when = { minAge = 16, maxAge = 40, career = { "none", "company", "stoker", "diver", "sluice", "brine", "choir", "warden" } },
		choices = {
			{
				label = "Take the brass punch",
				hint = "Needs some nerve. You'd start as a Ticket Punch.",
				requires = { min = { justice = 20 } },
				result = { career = "conductor", justice = 1, sanity = 1, log = "The Line Master hung the brass punch around your neck, and you rode your first shift through the drowned aqueducts with your heart in your mouth and your voice steady." },
			},
			{
				label = "Ride the line first",
				result = { prudence = 1, sanity = 2, log = "You bought a ticket and rode the Undertow end to end, watching the conductors. Not one of them looked out of a porthole the whole way." },
			},
			{
				label = "Take the stairs instead",
				result = { log = "You thanked the Line Master and took the stairs. You like your boxes dry." },
			},
		},
	},

	-- On the line --------------------------------------------------------------
	{
		id = "cond_fare_dodgers",
		title = "Two Without Tickets",
		text = "There are two fare dodgers on the 9:40 to the Salt Flats. One is Pellam Rook, who has ridden the Undertow for twenty years without once buying a ticket, and who tips his hat to every conductor who fails to catch him. The other is a Gutter girl of about nine, hiding under a seat with a loaf of bread for her brother, who cuts salt out on the Flats.",
		once = true,
		tags = { "career", "conductor", "rival" },
		when = { career = "conductor" },
		choices = {
			{
				label = "Catch Pellam Rook",
				hint = "Justice clash, medium. He's slippery.",
				clash = { stat = "justice", foe = "Pellam Rook", coins = 2, base = 4, coinPower = 3 },
				win = {
					paycheck = 0.2,
					justice = 2,
					addRelation = { kind = "rival", name = "Pellam Rook", bond = 25, age = { 45, 60 } },
					log = "You cornered {newRelation} between the third and fourth cars and punched his ticket in front of the whole carriage. He paid, laughing, and swore you'd never catch him twice.",
				},
				lose = { sanity = -2, log = "Rook slipped out of his coat, out of the car and off at Chandlers' Halt, and left you holding the coat. There was a ticket in the pocket. Unpunched." },
			},
			{
				label = "Pay the girl's fare yourself",
				result = { money = -5, justice = 2, sanity = 3, log = "You punched her a ticket and paid for it out of your own pocket. At the Salt Flats she ran down the platform to a boy with salt in his hair, and they both waved until the doors sealed." },
			},
			{
				label = "Put them both off at the next halt",
				result = { paycheck = 0.1, justice = -2, sanity = -3, log = "You put them both off at the next halt. Rook went cheerfully, as if it were a game. The girl didn't cry, which was worse." },
			},
			{
				label = "Look the other way",
				result = { sanity = 1, log = "You punched every ticket in the carriage except two, and watched the drowned streets go by the porthole." },
			},
		},
	},
	{
		id = "cond_lost_property",
		title = "The Lost Property Office",
		text = "The Undertow's lost property office is three rooms under Platform Nine that nobody has sorted in forty years. Umbrellas that are always wet. A birdcage with a song in it and no bird. A pocket watch that runs backward, and a little brass bell on a hook that rings, now and then, when nothing touches it. At the very back sits a locked steamer trunk stamped with the Line's crest.",
		cooldown = 6,
		tags = { "career", "conductor", "strange" },
		when = { career = "conductor" },
		choices = {
			{
				label = "Catalogue the lot",
				result = { temperance = { 2, 3 }, paycheck = 0.1, log = "You catalogued four hundred umbrellas, sixty-one left shoes and a wooden leg with a name carved on it, and the Authority sent down a note of thanks." },
			},
			{
				label = "Take the little bell home",
				hint = "Nobody has claimed it in forty years.",
				requires = { noGear = "little_bell" },
				result = { gear = "little_bell", sanity = 1, log = "You took the little bell home on its hook. It rang once on the stairs, as if it knew the way." },
			},
			{
				label = "Find the backward watch's owner",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Forty years of paperwork", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 2,
					sanity = 3,
					wage = { 20, 50 },
					log = "You traced the watch through forty years of claim slips to an old woman on the Terraces. She wound it, and it ran forward for the first time since her husband lost it, and she wouldn't let you leave without a reward.",
				},
				lose = { sanity = -2, log = "Forty years of claim slips led you to an address on Lamplighters' Street, which has been underwater for a century. The watch is still running backward." },
			},
			{
				label = "Open the locked trunk",
				hint = "Temperance clash, medium-hard.",
				clash = { stat = "temperance", foe = "The Line's old trunk", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 40, 90 }, log = "The lock gave. Inside, wrapped in oilcloth, were a conductor's uniform from the year the Line opened, a brass punch, and a bundle of old scrip the Authority was very glad to have back." },
				lose = { sanity = -5, log = "The lock gave. The trunk was full to the brim with black water, perfectly still, and none of it was leaking out. You closed the lid and pushed the trunk back where it was." },
			},
		},
	},
	{
		id = "cond_early_train",
		title = "The 6:14 Arrived at 6:13",
		text = "The 6:14 to Bellhollow Deep is twenty minutes down the Line, and you are its conductor. At 6:13, while you are still on Platform Nine with the doors open, the speaking-tube from Bellhollow Deep crackles: the 6:14 has just pulled in there, all passengers safe, and its conductor would like a word with you. The voice on the tube is yours.",
		once = true,
		tags = { "career", "conductor", "strange" },
		when = { career = "conductor" },
		choices = {
			{
				label = "Board and leave on time",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The minute before", coins = 3, base = 6, coinPower = 3 },
				win = {
					prudence = 3,
					sanity = 3,
					setFlags = { "cond_rode_early" },
					schedule = { event = "cond_early_again", inYears = 3 },
					log = "You punched every ticket and kept your eyes off the clock. At Bellhollow Deep the platform clock said 6:13, and someone in your coat nodded to you from the stairs and was gone before you could wave. The ride was perfectly ordinary, and a minute shorter than it had any right to be.",
				},
				lose = { sanity = -8, condition = "night_terrors", log = "For one long minute you were at both ends of the Line at once. You still can't say for certain which end you got off at." },
			},
			{
				label = "Hold the doors until 6:15",
				result = { prudence = 2, sanity = -2, log = "You held the doors until the clock said 6:15, just to be safe. When you reached Bellhollow Deep, nobody there remembered calling, and the platform clock had stopped at 6:13." },
			},
			{
				label = "Talk to yourself on the tube",
				result = { sanity = { -4, 4 }, log = "You picked up the speaking-tube. Your own voice, a little hoarse, said, \"Don't worry. It's a nice ride.\" Then the line went quiet, and stayed quiet." },
			},
			{
				label = "Report it to the stationmaster",
				result = { prudence = 1, sanity = -1, log = "The stationmaster wrote 'early again' in a ledger already half full of those two words, and told you to take the rest of the day off." },
			},
		},
	},
	{
		id = "cond_early_again",
		title = "Tomorrow's Ticket",
		text = "Three years after the 6:14 arrived before it left, a passenger on the same train holds out a ticket for punching. It has already been punched, in your pattern, and it is stamped with tomorrow's date. The passenger is wearing your coat and looking at you very kindly, the way you would look at someone you remember being.",
		weight = 0,
		once = true,
		tags = { "career", "conductor", "strange" },
		when = { career = "conductor", flags = { "cond_rode_early" } },
		choices = {
			{
				label = "Punch it again",
				result = { prudence = 2, sanity = { -2, 5 }, clearFlags = { "cond_rode_early" }, log = "You punched it again, right through the first hole. The passenger smiled, said \"Good. That's the last one,\" and was gone before the next halt." },
			},
			{
				label = "Ask what happens tomorrow",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "Your own answer", coins = 2, base = 5, coinPower = 3 },
				win = {
					prudence = 3,
					sanity = 4,
					clearFlags = { "cond_rode_early" },
					log = "\"Take the stairs tomorrow,\" you told yourself, and got off at Chandlers' Halt. The next day the 6:14 sat stalled for nine hours in the Long Tunnel, and you were at home on the stairs, eating a bun.",
				},
				lose = { sanity = -6, clearFlags = { "cond_rode_early" }, log = "You asked, and you answered. You have been trying to forget the answer ever since." },
			},
			{
				label = "Hand over your punch",
				result = {
					quitCareer = true,
					sanity = 5,
					clearFlags = { "cond_rode_early" },
					log = "You lifted the brass punch from around your neck and handed it over. Your other self took it gently and went on down the car punching tickets, and you got off at the next halt and walked home in the rain, oddly light.",
				},
			},
		},
	},
	{
		id = "cond_keeping_pace",
		title = "Something Keeping Pace",
		text = "Halfway through the Long Tunnel the car slows and the lamps flicker. Outside the starboard portholes, very close, something enormous is keeping pace with you in the dark. A Rim lady has started screaming, a stoker is praying under his breath, and a small boy has his face pressed to the glass, delighted.",
		cooldown = 5,
		tags = { "career", "conductor", "strange" },
		when = { career = "conductor" },
		choices = {
			{
				label = "Dim the lamps and calm the car",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A carriage full of panic", coins = 2, base = 4, coinPower = 3 },
				win = { paycheck = 0.2, prudence = 2, sanity = 2, log = "You dimmed the lamps, sat the Rim lady down, and talked the whole carriage through it in your best ticket-punching voice. Whatever it was lost interest and turned away into the deep." },
				lose = { fortitude = { -3, -1 }, sanity = -5, log = "The panic got ahead of you. Somebody pulled the brake, the car stopped dead in the tunnel, and the thing outside stopped too. It stayed there for an hour, looking in." },
			},
			{
				label = "Signal the driver to run for it",
				hint = "Justice clash, medium-hard.",
				clash = { stat = "justice", foe = "The thing in the tunnel", coins = 2, base = 5, coinPower = 3 },
				win = { paycheck = 0.15, justice = 2, log = "You hammered the run signal on the speaking-tube, and the driver opened her up. You came into Platform Nine four minutes early, and the Authority fined the driver for it." },
				lose = {
					fortitude = { -8, -4 },
					sanity = -2,
					condition = "broken_arm",
					log = "The car jumped its cable on the bend and threw everyone into the aisle. The thing outside was gone by the time the rescue barge came.",
					cause = "Lost in the Long Tunnel",
				},
			},
			{
				label = "Let the boy wave at it",
				result = { sanity = { -3, 6 }, log = "The boy waved. After a long moment, the thing outside turned away into the deep, slowly, the way you might turn away from a window you liked." },
			},
			{
				label = "Hum to it",
				hint = "Only if you've heard it hum before.",
				requires = { flags = { "tw_umber_free" } },
				result = { prudence = 2, sanity = 6, log = "You knew that shape. You hummed, low and slow, and the whole car buzzed as something enormous hummed back. It kept pace with you all the way to the Salt Flats, like an old friend walking you home." },
			},
		},
	},
	{
		id = "cond_stalled_car",
		title = "The Stalled Car",
		text = "The signal lamps in the Long Tunnel have gone red. Ahead of you, the 4:50 from the Salt Flats has come off its cable and is stalled in the black water with its lamps dying, and the speaking-tube is full of knocking. Your car is the only one close enough to reach it.",
		cooldown = 6,
		tags = { "career", "conductor", "rescue" },
		when = { career = "conductor", minRank = 2 },
		choices = {
			{
				label = "Couple up and tow it home",
				hint = "Temperance clash, medium-hard.",
				clash = { stat = "temperance", foe = "The dead cable", coins = 2, base = 5, coinPower = 3 },
				win = { promote = true, temperance = 2, sanity = 4, log = "You talked your driver through the old coupling drill, nose to nose with the 4:50 in the dark, and towed it home to Platform Nine with forty passengers singing inside it." },
				lose = { fortitude = { -6, -2 }, sanity = -3, log = "The coupling snapped twice. The Authority's rescue barge got everyone out at dawn, cold and furious, and you rode home with them, sharing a blanket with a goat." },
			},
			{
				label = "Walk the ledge to reach it",
				hint = "Fortitude clash, hard.",
				clash = { stat = "fortitude", foe = "The flooded ledge", coins = 3, base = 6, coinPower = 3 },
				win = { paycheck = 0.3, justice = 3, sanity = 3, log = "You walked the maintenance ledge with a lamp in your teeth and a rope on your belt, and led every passenger back along it to your car, one at a time, telling jokes." },
				lose = {
					fortitude = { -12, -6 },
					sanity = -3,
					condition = "broken_arm",
					log = "The ledge gave way under you halfway along. You spent the rest of the night in the water, holding on to a rusted bolt, until the barge came.",
					cause = "Drowned on the Long Tunnel ledge",
				},
			},
			{
				label = "Signal Platform Nine and wait",
				result = { prudence = 1, sanity = -3, log = "You signaled the platform and waited in the dark beside the dying lamps, knocking back on the speaking-tube every few minutes so they would know somebody was there." },
			},
		},
	},
	{
		id = "cond_wet_passenger",
		title = "A Stop for Lamplighters' Street",
		text = "Past midnight on the last car, a passenger in a soaking coat asks you very politely to let him off at Lamplighters' Street. Lamplighters' Street drowned a hundred years ago. There is no halt there now, only a bricked-up arch that the car passes at speed. His ticket is printed on paper that went out of use before your grandmother was born.",
		cooldown = 8,
		tags = { "career", "conductor", "strange", "drowned_city" },
		when = { career = "conductor", minRank = 2 },
		choices = {
			{
				label = "Stop at the bricked-up arch",
				hint = "Prudence clash, medium-hard. Never open a door between stations.",
				clash = { stat = "prudence", foe = "The rule about doors", coins = 2, base = 5, coinPower = 3 },
				win = { prudence = 3, sanity = 3, log = "You stopped at the arch and opened the door. Beyond it was a dry, gaslit platform full of people in old coats, waiting. He tipped his hat and stepped off, and the doors sealed behind him. On the way back, the arch was only bricks." },
				lose = {
					fortitude = { -6, -2 },
					sanity = -6,
					log = "You opened the door at the arch, and black water came in instead of a platform, knee-deep and very still, and then simply wasn't there. Neither was the passenger.",
					cause = "Drowned between stations",
				},
			},
			{
				label = "Tell him gently there's no such stop",
				result = { justice = 1, sanity = -2, log = "You told him gently. He nodded as if he'd been told before, and sat back down. At the next halt, his seat was empty and wet." },
			},
			{
				label = "Punch his ticket and sit with him",
				result = { prudence = 1, sanity = 2, log = "You punched his old ticket, which took the punch like new paper, and sat with him to the end of the line while he told you about the gaslights on Lamplighters' Street. He was gone before Platform Nine. You missed him a little." },
			},
		},
	},
	{
		id = "cond_doors",
		title = "Between Stations",
		text = "A man in a good coat is hauling at the handle of the sealed door between stations, shouting that he has to get off now, that he left something terribly important at the last halt. Outside the porthole is forty feet of black water. Every passenger in the car is looking at you, and at the handle, which has started to turn.",
		cooldown = 5,
		tags = { "career", "conductor" },
		when = { career = "conductor" },
		choices = {
			{
				label = "Get his hands off the handle",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "A man in a panic", coins = 2, base = 4, coinPower = 3 },
				win = { paycheck = 0.15, justice = 2, log = "You got your hands over his on the handle and held it shut to the next halt, talking to him the whole way. He had left his daughter's birthday cake on a bench. You helped him buy another." },
				lose = {
					fortitude = { -8, -3 },
					sanity = -2,
					condition = "broken_arm",
					log = "The handle turned a quarter before you stopped it. A sheet of black water came in at the seam before the door sealed again, and threw you into the luggage rack.",
					cause = "Drowned between stations",
				},
			},
			{
				label = "Talk him down",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A man in a panic", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, sanity = 2, log = "You sat down beside him and talked about nothing in particular: the weather, the trams, his daughter's birthday. After a while his hands let go of the handle on their own, and the whole carriage clapped at the next halt." },
				lose = { fortitude = { -3, -1 }, sanity = -4, log = "He wasn't listening. Two stokers had to sit on him until the next halt, and you caught an elbow in the eye for your trouble." },
			},
			{
				label = "Pull the emergency brake",
				result = { money = -15, sanity = -3, log = "You pulled the emergency brake. The car stopped dead in the dark, the man sat down on the floor, and the Authority fined you fifteen {currency} for the delay." },
			},
		},
	},
	{
		id = "cond_salt_storm",
		title = "Salt Storm at the Terminus",
		text = "A salt storm is blowing in across the Flats, white from the ground to the sky, and the last car home is due to seal its doors in ten minutes. Far out on the salt you can see a line of cutters' lanterns, still bobbing toward the terminus, a long way off.",
		cooldown = 5,
		tags = { "career", "conductor", "rescue" },
		when = { career = "conductor" },
		choices = {
			{
				label = "Hold the car for them",
				result = { money = -10, justice = 3, sanity = 3, log = "You held the car past its time with the doors open and salt blowing down the aisle, until the last cutter tumbled in. The Authority fined you ten {currency}. The cutters paid you back in salt." },
			},
			{
				label = "Go out and bring them in",
				hint = "Fortitude clash, medium-hard.",
				clash = { stat = "fortitude", foe = "The salt storm", coins = 2, base = 5, coinPower = 3 },
				win = { fortitude = 1, justice = 3, sanity = 4, wage = { 15, 35 }, log = "You went out into the white with a rope and a lantern and brought the cutters in one by one. They passed a hat around the car for you, and it came back heavy." },
				lose = {
					fortitude = { -8, -3 },
					sanity = -2,
					condition = "salt_cough",
					log = "The storm turned you round three times before you found the first lantern. You got them all in, in the end, but the salt got into your lungs and stayed there.",
					cause = "Lost in a salt storm",
				},
			},
			{
				label = "Seal the doors on time",
				result = { paycheck = 0.1, sanity = -3, log = "You sealed the doors on time. Through the rear porthole the lanterns kept coming for a while. You told yourself the terminus shed was sturdy, and that they would wait out the storm inside it." },
			},
		},
	},
	{
		id = "cond_charter_express",
		title = "The Charter Express",
		text = "The Gatewater Exchange wants a Charter Express: a morning train that runs Rim to Rim with no Gutter halts at all, so that its clerks need never share a carriage with the Silt. It has offered the Line a great deal of money, and you, as {rank}, a great deal more, if your name is on the new timetable by Friday. The Gutter halts carry nine thousand people a day.",
		once = true,
		tags = { "career", "conductor", "company" },
		when = { career = "conductor", minRank = 4 },
		choices = {
			{
				label = "Sign the new timetable",
				result = { paycheck = 0.5, promote = true, justice = -4, sanity = -5, log = "You signed. The Charter Express ran on time from the very first morning, and nine thousand people a day took the stairs instead." },
			},
			{
				label = "Refuse to sign",
				result = { justice = 4, sanity = 3, log = "You refused, politely and in writing. The Exchange took its money to the Sluice Authority, which is still thinking about it." },
			},
			{
				label = "Sign, then keep the Gutter halts",
				hint = "Temperance clash, medium-hard.",
				clash = { stat = "temperance", foe = "The Exchange's auditors", coins = 2, base = 5, coinPower = 3 },
				win = {
					paycheck = 0.5,
					justice = 3,
					sanity = 4,
					log = "You signed and banked the money, then wrote every Gutter halt back into the timetable as a 'signal stop'. The express stopped at all of them. The Exchange's clerks never once looked up from their papers.",
				},
				lose = { money = { -120, -60 }, justice = 1, sanity = -4, log = "The Exchange's auditors counted the stops. You paid back every note of the money with a fine on top, and the Gutter halts stayed in anyway." },
			},
		},
	},
	{
		id = "cond_breach_freight",
		title = "Sealed Freight from Glasswall",
		text = "The breach sirens are howling over Glasswall, and the Tidewell Institute has commandeered your car. Two keepers in rubber coats load a riveted tank into the baggage van and ask you to run it to the far end of the Line without stopping. Somewhere around the Saltpan bend, the tank starts to knock. Politely. Then it says your name.",
		cooldown = 2,
		tags = { "career", "conductor", "breach" },
		when = { career = "conductor", worldEvent = "breach_tidewell" },
		choices = {
			{
				label = "Don't answer, and run it through",
				hint = "Prudence clash, medium-hard. Don't say a word.",
				clash = { stat = "prudence", foe = "The voice in the baggage van", coins = 2, base = 5, coinPower = 3 },
				win = { paycheck = 0.4, prudence = 3, log = "You kept your eyes on the timetable and your mouth shut the whole way. At the end of the line the keepers took the tank off without a word, and pressed a fold of clean notes into your hand." },
				lose = { sanity = -7, condition = "night_terrors", log = "You didn't answer. But at the Saltpan bend you called the next halt out loud, from habit, and the tank called it back in your voice, at every halt, all the way to the end of the line." },
			},
			{
				label = "Make the keepers ride with it",
				result = { paycheck = 0.2, prudence = 1, sanity = -1, log = "You made the keepers ride in the baggage van with their tank. They sang to it the whole way, very badly, and it stopped knocking somewhere under Bellhollow." },
			},
			{
				label = "Uncouple the van on a siding",
				result = { money = -20, sanity = -3, log = "You uncoupled the baggage van on the Long Tunnel siding and left it there, knocking. The Institute fished it out later, and fined you twenty {currency} for the inconvenience." },
			},
		},
	},
}
