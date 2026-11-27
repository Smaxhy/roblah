--[[
	Linked-friend events: another player, linked in the Friends tab, is online.
	{linked} names that friend. A result's `linked = {...}` lands in the friend's
	own life, where {sender} is your first name. Linked effects never use linked,
	die, schedule or trigger, and their fortitude hits stay small.
	The two rough events need both players to turn on Rough Play (linkedRough).
	None of these fire in the solo simulator.
	Sets brine_grudge (friend_rough_kin), read by life_brine_grudge.
]]

return {
	-- Warm ------------------------------------------------------------------
	{
		id = "friend_mud_compass",
		title = "Something for {linked}",
		text = "Turning over the mud at the waterline, you find a brass compass no bigger than a button, still swinging true under the grime. It is exactly the sort of thing {linked} collects and pretends not to. You could clean it up and send it over, or you could sell it at the salvage dock for a fair few {currency}.",
		cooldown = 6,
		tags = { "linked", "friend", "gift" },
		when = { linked = true, minAge = 8 },
		choices = {
			{
				label = "Clean it and send it to {linked}",
				result = {
					sanity = 2,
					log = "You polished the compass and sent it to {linked} with a note that said only: true north.",
					linked = { sanity = 3, log = "{sender} sent you a little brass compass from the mud, polished and still pointing true." },
				},
			},
			{
				label = "Sell it at the salvage dock",
				result = { money = { 10, 20 }, log = "You sold the compass at the salvage dock and did not mention it to {linked}." },
			},
			{
				label = "Keep it for yourself",
				result = { prudence = 1, sanity = 1, log = "You kept the compass in your pocket, and somehow it always pointed toward {linked}'s door." },
			},
		},
	},
	{
		id = "friend_name_day",
		title = "{linked}'s Name-Day",
		text = "It is {linked}'s name-day, and half of {district} knows it, because you have told everyone. There is a borrowed table outside your door, a pot of fish stew, and a cake that leans to one side like a Silt house. Somebody has strung paper lanterns over the door. All that is missing is a present.",
		cooldown = 5,
		tags = { "linked", "friend", "celebration" },
		when = { linked = true, minAge = 6 },
		choices = {
			{
				label = "Buy them a proper present",
				hint = "20 scrip.",
				requires = { min = { money = 20 } },
				result = {
					money = -20,
					sanity = 3,
					log = "You bought {linked} a good wool scarf, and they wore it all through supper.",
					linked = { sanity = 4, log = "{sender} threw you a name-day supper and gave you a good wool scarf." },
				},
			},
			{
				label = "Make up a song instead",
				result = {
					temperance = 1,
					sanity = 4,
					log = "You made up a song about {linked}, and the whole street learned the chorus by the third verse.",
					linked = { sanity = 3, log = "{sender} sang a terrible song about you at your name-day supper, and everyone joined in." },
				},
			},
			{
				label = "Let the cake be the present",
				result = {
					sanity = 2,
					log = "You let the leaning cake be the present, and {linked} laughed so hard it finally fell over.",
					linked = { sanity = 2, log = "{sender} threw you a name-day supper with a cake that leaned, and then fell over." },
				},
			},
		},
	},
	{
		id = "friend_two_spoons",
		title = "Broth and Two Spoons",
		text = "You have not been sleeping, and it shows. {linked} notices, the way friends do, and turns up on your stairs with a pot of kelp broth wrapped in a towel and two spoons in their coat pocket. They do not ask what is wrong. They just sit down on the step and start unwrapping the pot.",
		cooldown = 4,
		tags = { "linked", "friend", "comfort" },
		when = { linked = true, minAge = 12, max = { sanity = -8 } },
		choices = {
			{
				label = "Sit and eat with them",
				result = {
					sanity = { 6, 9 },
					log = "You ate broth on the step with {linked} until the pot was empty and the night felt shorter.",
					linked = { justice = 1, sanity = 2, log = "You sat on {sender}'s step with a pot of broth until they could breathe again." },
				},
			},
			{
				label = "Tell them everything",
				result = {
					prudence = 1,
					sanity = { 8, 12 },
					log = "You told {linked} everything, all of it, and they listened until the broth went cold.",
					linked = { prudence = 1, sanity = 1, log = "{sender} told you everything that was wrong, and you listened until the broth went cold." },
				},
			},
			{
				label = "Send them home",
				result = {
					sanity = -2,
					log = "You told {linked} you were fine and sent them home with the broth still warm.",
					linked = { sanity = -2, log = "{sender} said they were fine and sent you home with your broth. They were not fine." },
				},
			},
		},
	},
	{
		id = "friend_two_lanterns",
		title = "Two Lanterns",
		text = "Lantern Night, and {linked} meets you at the waterline with two paper lanterns already folded. One has their own careful handwriting on it. The other is blank. \"For whoever you are missing this year,\" they say, and hold it out with the stub of a pencil. Out on the Mere, the first lanterns are drifting.",
		cooldown = 6,
		tags = { "linked", "friend", "lantern_night", "comfort" },
		when = { linked = true, minAge = 8 },
		choices = {
			{
				label = "Write a name and float it",
				result = {
					prudence = 1,
					sanity = 6,
					log = "You wrote a name on the blank lantern and floated it beside {linked}'s until both were out of sight.",
					linked = { sanity = 4, log = "You floated lanterns with {sender} on Lantern Night and watched them drift out side by side." },
				},
			},
			{
				label = "Ask who theirs is for",
				result = {
					prudence = 1,
					sanity = 3,
					log = "You asked {linked} who their lantern was for, and they told you about someone you never met.",
					linked = { sanity = 5, log = "{sender} asked who your lantern was for, and you finally said the name out loud." },
				},
			},
			{
				label = "Leave the second one blank",
				result = {
					sanity = 2,
					log = "You floated the blank lantern with {linked}, and let the water decide who it was for.",
					linked = { sanity = 2, log = "{sender} floated a blank lantern beside yours, and neither of you said anything for a long time." },
				},
			},
		},
	},
	{
		id = "friend_rent_help",
		title = "{linked}'s Rent",
		text = "Over noodles on the barge, {linked} mentions, far too casually, that their landlord has found a new number for the rent. They laugh about it. They also order the cheapest bowl, wrap the bread for later, and keep glancing at their coat pocket, where you can see the corner of a nailed-up notice.",
		cooldown = 6,
		tags = { "linked", "friend", "money" },
		when = { linked = true, minAge = 18 },
		choices = {
			{
				label = "Cover the difference",
				hint = "40 scrip.",
				requires = { min = { money = 40 } },
				result = {
					money = -40,
					justice = 2,
					sanity = 2,
					log = "You paid forty {currency} toward {linked}'s rent and changed the subject every time they brought it up.",
					linked = { money = 40, sanity = 2, log = "{sender} paid forty {currency} toward your rent and refused to talk about it." },
				},
			},
			{
				label = "Argue the landlord down together",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A greedy landlord", coins = 2, base = 4, coinPower = 3 },
				win = {
					prudence = 2,
					justice = 2,
					log = "You and {linked} argued the landlord back to the old rent, and he looked genuinely hurt.",
					linked = { money = 20, sanity = 2, log = "{sender} helped you argue your landlord back down to the old rent." },
				},
				lose = {
					sanity = -2,
					log = "The landlord listened to you both, then raised the rent again for the inconvenience.",
					linked = { money = -10, sanity = -1, log = "{sender} argued with your landlord for you, and the rent somehow went up again." },
				},
			},
			{
				label = "Buy them a better bowl",
				hint = "5 scrip.",
				requires = { min = { money = 5 } },
				result = {
					money = -5,
					sanity = 1,
					log = "You bought {linked} a bowl with fish in it and pretended you had ordered two by mistake.",
					linked = { fortitude = 1, sanity = 1, log = "{sender} bought you a bowl with fish in it and claimed it was a mistake." },
				},
			},
		},
	},
	{
		id = "friend_stair_race",
		title = "Race You to the Top",
		text = "{linked} is waiting at the bottom of the switchback stairs, bouncing on their toes, and points up at the tram terminus four hundred steps above. \"Last one up is a silt eel,\" they say. The stairs are wet, the landings are crowded, and a porter with a basket chair is already shouting at both of you to mind yourselves.",
		cooldown = 5,
		tags = { "linked", "friend" },
		when = { linked = true, minAge = 8, maxAge = 50 },
		choices = {
			{
				label = "Race them",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "A friend on the stairs", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 2,
					sanity = 3,
					log = "You beat {linked} to the terminus by a landing and bought the broth anyway, out of kindness.",
					linked = { sanity = 2, log = "{sender} beat you up the switchback stairs by a landing, then bought you broth anyway." },
				},
				lose = {
					fortitude = -1,
					sanity = 2,
					log = "{linked} beat you to the top and called you a silt eel all the way through supper.",
					linked = { justice = 1, sanity = 3, log = "You beat {sender} up the switchback stairs and called them a silt eel for a week." },
				},
			},
			{
				label = "Walk up together instead",
				result = {
					fortitude = 1,
					sanity = 2,
					log = "You walked up the four hundred steps with {linked}, talking, and the stairs felt short.",
					linked = { sanity = 2, log = "You walked the switchback stairs with {sender}, talking the whole way up." },
				},
			},
			{
				label = "Ride the tram and wave",
				hint = "2 scrip.",
				requires = { min = { money = 2 } },
				result = {
					money = -2,
					sanity = 3,
					log = "You took the tram and waved at {linked} from the window at every single hairpin.",
					linked = { fortitude = 1, sanity = 1, log = "{sender} rode the tram past you on the stairs and waved at every hairpin, smugly." },
				},
			},
		},
	},

	-- Team-ups (assist: the friend adds a coin) -----------------------------
	{
		id = "friend_chandlery_run",
		title = "Two Sacks and a Rope",
		text = "Low Water has bared a drowned chandlery off the old viaduct, its shelves still stacked with brass fittings, and {linked} has turned up at your door with two sacks and a coil of rope. \"Nobody else has seen it yet,\" they say. \"One of us holds the rope. The other one goes in.\"",
		cooldown = 4,
		tags = { "linked", "friend", "salvage", "low_water" },
		when = { linked = true, minAge = 14, world = { water = "low" } },
		choices = {
			{
				label = "Go in together",
				hint = "Justice clash, hard. {linked} adds a coin.",
				clash = { stat = "justice", foe = "The drowned chandlery", coins = 3, base = 6, coinPower = 3, assist = true },
				win = {
					money = { 50, 120 },
					justice = 2,
					sanity = 3,
					log = "You and {linked} cleared the drowned chandlery shelf by shelf and split two full sacks of brass.",
					linked = { money = { 40, 90 }, sanity = 2, log = "You and {sender} cleared a drowned chandlery at Low Water and split two sacks of brass." },
				},
				lose = {
					fortitude = { -9, -4 },
					sanity = -3,
					log = "The chandlery roof came down as you went in, and {linked} hauled you out by the rope.",
					cause = "Crushed in a drowned chandlery",
					linked = { fortitude = -1, sanity = -2, log = "You hauled {sender} out of a collapsing chandlery by the rope, with nothing to show for it." },
				},
			},
			{
				label = "Hold the rope for them",
				result = {
					money = { 15, 40 },
					prudence = 1,
					log = "You held the rope while {linked} went in, and they paid you a fair share of what came out.",
					linked = {
						money = { 30, 70 },
						fortitude = { -3, 0 },
						log = "{sender} held the rope while you went into a drowned chandlery, and you came out with brass.",
					},
				},
			},
			{
				label = "Talk them out of it",
				result = {
					prudence = 2,
					log = "You talked {linked} out of the chandlery, and that night its roof fell in on its own.",
					linked = { prudence = 1, log = "{sender} talked you out of a salvage run, and that night the roof fell in without you." },
				},
			},
		},
	},
	{
		id = "friend_tenement_fire",
		title = "Fire on the Stairwell",
		text = "You and {linked} are coming home late when you see the glow in a third-floor window and hear the shouting start. A lamp has gone over in the tenement on the corner. The stairwell is filling with grey, and a woman at a window above is holding out a bundle and shouting a name nobody answers.",
		cooldown = 6,
		tags = { "linked", "friend", "danger" },
		when = { linked = true, minAge = 14 },
		choices = {
			{
				label = "Go up the stairs together",
				hint = "Fortitude clash, medium-hard. {linked} adds a coin.",
				clash = { stat = "fortitude", foe = "The tenement fire", coins = 2, base = 5, coinPower = 3, assist = true },
				win = {
					justice = 4,
					sanity = 4,
					log = "You and {linked} went up through the grey and came down with a family between you.",
					linked = { justice = 2, sanity = 3, log = "You and {sender} went into a burning tenement together and carried a family out." },
				},
				lose = {
					fortitude = { -10, -4 },
					sanity = -3,
					log = "The stairwell filled before you reached the top, and {linked} dragged you out coughing.",
					cause = "Caught in a tenement fire",
					linked = {
						fortitude = { -3, -1 },
						sanity = -2,
						log = "You dragged {sender} out of a burning stairwell, both of you coughing grey for a week.",
						cause = "Caught in a tenement fire",
					},
				},
			},
			{
				label = "Catch the bundle below",
				result = {
					justice = 3,
					sanity = 2,
					log = "You stood under the window and caught the bundle when it fell. It was a baby, furious and unhurt.",
					linked = { sanity = 2, log = "{sender} caught a baby dropped from a burning window, and you have never seen anyone look so frightened." },
				},
			},
			{
				label = "Run the bucket line",
				result = {
					prudence = 2,
					log = "You and {linked} ran the bucket line from the pump until the fire gave up the second floor.",
					linked = { fortitude = 1, prudence = 1, log = "You and {sender} worked a bucket line all night and saved the tenement's lower floors." },
				},
			},
		},
	},

	-- Rough Play (both players opted in) ------------------------------------
	{
		id = "friend_rough_savings_tin",
		title = "{linked}'s Savings Tin",
		text = "You are behind on everything, and you know exactly where {linked} keeps their savings: in a cocoa tin behind the loose brick by their stove, because they showed you once and laughed about it. They are out until dark. Their door has never had a proper lock. You are standing in front of it.",
		cooldown = 8,
		tags = { "linked", "rough", "crime" },
		when = { linkedRough = true, minAge = 14, max = { money = 30 } },
		choices = {
			{
				label = "Take a little",
				result = {
					money = 30,
					justice = -4,
					sanity = -3,
					log = "You took thirty {currency} from {linked}'s tin and put the brick back exactly as it was.",
					linked = { money = -30, sanity = -2, log = "Thirty {currency} went missing from your savings tin, and {sender} could not quite look at you." },
				},
			},
			{
				label = "Take all of it",
				hint = "Prudence clash, medium. A neighbor is watching.",
				clash = { stat = "prudence", foe = "A watchful neighbor", coins = 2, base = 4, coinPower = 3 },
				win = {
					money = 80,
					justice = -6,
					sanity = -5,
					log = "You emptied {linked}'s tin while their neighbor watched the wrong window.",
					linked = { money = -80, sanity = -4, log = "Someone emptied your savings tin. You heard later that {sender} had been seen on your stairs." },
				},
				lose = {
					justice = -3,
					sanity = -4,
					log = "{linked}'s neighbor caught you with your hand behind the brick and told {linked} everything.",
					linked = { sanity = -3, log = "Your neighbor caught {sender} with a hand behind your loose brick, and told you everything." },
				},
			},
			{
				label = "Walk away",
				result = { prudence = 1, justice = 2, sanity = 1, log = "You walked away from {linked}'s door and went hungry, which was easier than the other thing." },
			},
		},
	},
	{
		id = "friend_rough_kin",
		title = "The Kin Ask About {linked}",
		text = "A Brine Kin ledger-hand sits down across from you at the noodle barge and slides a fold of notes halfway over the table. \"{linked} owes the ledger,\" he says, \"and keeps moving their boat. You know where they tie up. Tell me, and these are yours, and you were never asked.\"",
		cooldown = 10,
		tags = { "linked", "rough", "brine", "crime" },
		when = { linkedRough = true, minAge = 16 },
		choices = {
			{
				label = "Sell them out",
				result = {
					money = 60,
					justice = -6,
					sanity = -5,
					log = "You told the ledger-hand where {linked} ties up, and pocketed the notes before he left.",
					linked = {
						money = { -60, -30 },
						fortitude = { -4, -1 },
						sanity = -3,
						log = "The Kin found your boat where only {sender} knew it was tied, and collected hard.",
						cause = "Collected on by the Brine Kin",
					},
				},
			},
			{
				label = "Warn {linked} instead",
				result = {
					justice = 3,
					sanity = -1,
					setFlags = { "brine_grudge" },
					log = "You warned {linked} that night, and by morning the Kin's chalk mark was on your door.",
					linked = { prudence = 2, sanity = 1, log = "{sender} warned you the Kin were asking, and you moved your boat before dawn." },
				},
			},
			{
				label = "Send him to the wrong pier",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A Brine Kin ledger-hand", coins = 2, base = 4, coinPower = 3 },
				win = {
					money = 60,
					prudence = 2,
					justice = 1,
					log = "You sent the ledger-hand to an empty pier, kept his notes, and warned {linked} for good measure.",
					linked = { prudence = 1, log = "{sender} sent the Kin chasing you to the wrong pier, and then warned you about it." },
				},
				lose = {
					fortitude = { -7, -3 },
					sanity = -3,
					setFlags = { "brine_grudge" },
					log = "The ledger-hand checked the pier, came back for you, and settled the difference.",
					cause = "Settled with the Brine Kin",
					linked = { sanity = -1, log = "{sender} lied to the Kin to protect you and paid for it on the barge steps." },
				},
			},
		},
	},
}
