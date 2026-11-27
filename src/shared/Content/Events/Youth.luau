--[[
	Youth events: ages 13-19.
	Threads:
		flag_name_asked (Childhood) -> youth_flag_answer -> lantern_for_calla / found_calla_lantern
		sat_with_choir (Childhood)  -> youth_choir_mentor (adds mentor Sorrel Stillman)
		youth_stair_race            -> adds rival Garrow Saltry
		youth_rim_tram              -> saw_the_silt (read by life_rim_gala)
]]

return {
	{
		id = "youth_flag_answer",
		title = "The Guild Remembers",
		text = "The Guild clerk has gone grey, but she remembers you. She opens a ledger to a page marked with a ribbon: Calla Hollin, diver, lost the year you were found, last seen near the drowned orphanage on Gull Street. Someone has drawn a tiny lantern beside the name.",
		weight = 0,
		once = true,
		tags = { "youth", "foundling", "thread_flag" },
		choices = {
			{
				label = "Dive to Gull Street",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The drowned orphanage", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = { 2, 3 },
					sanity = 5,
					setFlags = { "found_calla_lantern" },
					log = "You found a Guild lantern in the orphanage doorway with her name scratched into the brass.",
				},
				lose = {
					fortitude = { -9, -4 },
					sanity = -4,
					log = "The current in Gull Street turned you around twice. You came up with nothing but cold.",
					cause = "Lost in the drowned orphanage",
				},
			},
			{
				label = "Fold a lantern with her name",
				result = { prudence = { 1, 2 }, sanity = 4, setFlags = { "lantern_for_calla" }, log = "You folded a paper lantern with her name on it and kept it safe for Lantern Night." },
			},
			{
				label = "Close the ledger gently",
				result = { prudence = 2, sanity = 1, log = "You closed the ledger gently. Knowing her name was enough, for now." },
			},
		},
	},
	{
		id = "youth_choir_mentor",
		title = "The Woman by the Water",
		text = "The woman from the waterline is still there, years later, with the same unlit lantern in her lap. Her name is Sorrel Stillman, and she is a Cantor of the Choir. \"You sat well, once,\" she says. \"Most people fidget. I could teach you to listen.\"",
		once = true,
		weight = 14,
		tags = { "youth", "choir", "mentor" },
		when = { minAge = 13, maxAge = 16, flags = { "sat_with_choir" }, noRelation = "mentor", notFlags = { "guild_mentor" } },
		choices = {
			{
				label = "Learn to listen",
				result = {
					addRelation = { kind = "mentor", name = "Sorrel Stillman", bond = 55, age = { 50, 65 } },
					prudence = { 3, 5 },
					sanity = 3,
					log = "{newRelation} taught you to sit through a whole tide without moving once.",
				},
			},
			{
				label = "Tell her you're busy",
				result = { sanity = -1, log = "You told her you were busy. She nodded as if she had expected nothing else." },
			},
		},
	},
	{
		id = "youth_stair_race",
		title = "The Switchback Race",
		text = "Every spring the kids race the switchback stairs from the waterline to the tram terminus: four hundred steps and two tunnels. The favorite is Garrow Saltry, who has won twice and makes sure everyone remembers. He looks you over at the starting line and laughs.",
		once = true,
		tags = { "youth", "rival" },
		when = { minAge = 13, maxAge = 17, side = "gutters" },
		choices = {
			{
				label = "Race him",
				hint = "Justice clash.",
				clash = { stat = "justice", foe = "Garrow Saltry", coins = 2, base = 3, coinPower = 2 },
				win = {
					justice = { 3, 5 },
					sanity = 4,
					addRelation = { kind = "rival", name = "Garrow Saltry", bond = 20, age = { 14, 18 } },
					log = "You beat {newRelation} by a stair and a half. He promised everyone he would get you back.",
				},
				lose = {
					fortitude = { -3, -1 },
					sanity = -2,
					addRelation = { kind = "rival", name = "Garrow Saltry", bond = 25, age = { 14, 18 } },
					log = "{newRelation} beat you by a whole landing and waved down at you from the top.",
				},
			},
			{
				label = "Run your own pace",
				result = { fortitude = { 2, 3 }, prudence = 1, log = "You ran your own race, finished in the middle, and could still breathe at the top." },
			},
			{
				label = "Hand out water at the top",
				result = { prudence = 1, sanity = 2, log = "You handed out cups of water at the terminus and learned everybody's name." },
			},
		},
	},
	{
		id = "youth_cathedral_bell",
		title = "Ring the Drowned Bell",
		text = "Low Water has brought the drowned cathedral's roof up out of the Mere, slick with weed. Its bell tower leans over the water like a tired old man. Your friends dare each other to swim out and ring the bell. Nobody has. Everybody is looking at you.",
		once = true,
		tags = { "youth", "low_water", "danger" },
		when = { minAge = 13, maxAge = 18, world = { water = "low" } },
		choices = {
			{
				label = "Swim out and ring it",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The leaning tower", coins = 2, base = 4, coinPower = 3 },
				win = { justice = { 3, 5 }, sanity = 4, money = { 5, 20 }, log = "You rang the drowned bell once, and the whole Silt heard it. You pried loose a brass pin to sell." },
				lose = {
					fortitude = { -8, -4 },
					sanity = -3,
					log = "The cold took your legs halfway out, and your friends hauled you back by the collar.",
					cause = "Drowned under the leaning tower",
				},
			},
			{
				label = "Borrow a boat and row out together",
				result = { temperance = 2, sanity = 2, log = "You rowed out with three friends and rang the bell together, laughing the whole way." },
			},
			{
				label = "Say no and mean it",
				result = { prudence = { 2, 3 }, log = "You said no, and kept saying it until everyone went home dry." },
			},
		},
	},
	{
		id = "youth_one_umbrella",
		title = "Under One Umbrella",
		text = "Rain drives sideways across the tram platform, and the shelter is packed with Sluice clerks who won't budge. A kid your age with ink on their fingers holds an umbrella out over both of you. \"Noor Fenwick,\" they say. \"Half this umbrella for half that bun.\"",
		once = true,
		tags = { "youth", "friend" },
		when = { minAge = 13, maxAge = 17 },
		choices = {
			{
				label = "Trade half the bun",
				result = {
					addRelation = { kind = "friend", name = "Noor Fenwick", bond = 55, age = { 13, 17 } },
					sanity = 3,
					log = "You split the bun with {newRelation} and missed two trams talking about everything.",
				},
			},
			{
				label = "Keep your bun and get wet",
				result = { fortitude = -1, sanity = -1, log = "You kept your bun and got soaked to the bone waiting for the tram." },
			},
		},
	},
	{
		id = "youth_friend_in_red",
		title = "A Friend in the Red",
		text = "{friend} turns up at your door after dark with a Brine Kin chalk mark on their coat. They owe forty {currency} for a boat ride they insist was meant to be free. The cousins come collecting tomorrow, and {friend} can't stop shaking.",
		cooldown = 6,
		tags = { "youth", "friend", "brine" },
		when = { minAge = 14, maxAge = 19, hasRelation = "friend" },
		choices = {
			{
				label = "Pay it for them",
				hint = "40 scrip.",
				requires = { min = { money = 40 } },
				result = { money = -40, sanity = 1, relationBond = { kind = "friend", amount = 12 }, log = "You paid {friend}'s debt in a dockside office that smelled of tar and oranges." },
			},
			{
				label = "Go with them to talk to the cousins",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Brine Kin cousin", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 3, relationBond = { kind = "friend", amount = 8 }, log = "You talked the cousins down to a day of mending nets, which you did together." },
				lose = { money = -15, sanity = -3, relationBond = { kind = "friend", amount = 3 }, log = "The cousins listened politely and wrote your name in the ledger beside {friend}'s." },
			},
			{
				label = "Tell them it isn't your problem",
				result = { sanity = -2, relationBond = { kind = "friend", amount = -10 }, log = "You closed the door on {friend}, and heard them sit on your stairs for a long time." },
			},
		},
	},
	{
		id = "youth_first_wage",
		title = "The First Wage",
		text = "Your first real wage comes in a brown envelope, the {currency} notes still smelling of the Sluice Authority's press. It is a thin envelope, and it is more than you have ever held at once. All the way home you keep touching your pocket.",
		once = true,
		tags = { "youth", "money" },
		when = { minAge = 14, maxAge = 19, anyCareer = true },
		choices = {
			{
				label = "Put it on the family table",
				requires = { hasRelation = { "mother", "father", "sibling" } },
				result = { sanity = 3, relationBond = { kind = "family", amount = 8 }, log = "You put the envelope on the family table, and nobody said anything for a while." },
			},
			{
				label = "Save every note",
				result = { money = { 10, 25 }, prudence = 2, log = "You hid the notes in a tin under the floorboards and felt rich for a month." },
			},
			{
				label = "Buy broth for the whole dock",
				result = { sanity = { 4, 6 }, justice = 1, log = "You bought hot broth for everyone on the dock, and the dock remembered it." },
			},
		},
	},
	{
		id = "youth_own_room",
		title = "A Room of Your Own",
		text = "The apartment has gotten smaller, or you have gotten bigger. A notice on the tram post offers a Terraces room with a window and a lock. Down at the docks, a Silt landlady rents hammocks in a stilt-house for almost nothing. Home is still home, for now.",
		once = true,
		tags = { "youth", "family", "move" },
		when = { minAge = 17, maxAge = 19, hasRelation = { "mother", "father" } },
		choices = {
			{
				label = "Take the Terraces room",
				hint = "60 scrip.",
				requires = { min = { money = 60 } },
				result = { money = -60, side = "gutters", sanity = 3, log = "You carried your things to a little Terraces room with a lock of its own." },
			},
			{
				label = "Take a Silt hammock",
				result = { side = "gutters", fortitude = -1, sanity = 1, log = "You moved into a Silt hammock and learned to sleep through the fog horns." },
			},
			{
				label = "Stay home a while longer",
				result = { money = { 5, 15 }, relationBond = { kind = "family", amount = 5 }, log = "You stayed home a while longer and saved the {currency} you would have spent on rent." },
			},
		},
	},
	{
		id = "youth_mudlark_crew",
		title = "The Mudlark Crew",
		text = "A crew of Silt kids works the mudflats under the old viaduct, pulling up spoons, buttons and brass fittings whenever the water draws back. Their leader, a sharp girl called Tamsin Rook, says they could use someone with quick hands. The pay is whatever you find.",
		once = true,
		tags = { "youth", "silt", "friend" },
		when = { minAge = 13, maxAge = 17, side = "gutters" },
		choices = {
			{
				label = "Join the crew for a season",
				hint = "Temperance clash.",
				clash = { stat = "temperance", foe = "The sucking mud", coins = 2, base = 3, coinPower = 2 },
				win = {
					money = { 15, 40 },
					temperance = 2,
					addRelation = { kind = "friend", name = "Tamsin Rook", bond = 45, age = { 14, 18 } },
					log = "You worked the flats with {newRelation}'s crew and came out with a pocket full of brass.",
				},
				lose = { fortitude = { -5, -2 }, money = { 3, 8 }, log = "The mud took one of your boots and most of your nerve, but you kept a few buttons." },
			},
			{
				label = "Turn her down",
				result = { prudence = 1, log = "You turned Tamsin down and watched the crew work from the viaduct rail." },
			},
		},
	},
	{
		id = "youth_lamp_bench",
		title = "The Lamp-Maker's Bench",
		text = "Old Brann Kettering mends Lantern Guild lamps in a workshop no wider than a tram car. His eyes are going. He needs someone to trim wicks, grind glass and solder seams, and he pays in broth, advice and the occasional {currency}.",
		once = true,
		tags = { "youth", "mentor", "craft" },
		when = { minAge = 14, maxAge = 19, side = "gutters", noRelation = "mentor", notFlags = { "guild_mentor" } },
		choices = {
			{
				label = "Learn the bench properly",
				result = {
					temperance = { 3, 5 },
					money = { 5, 15 },
					addRelation = { kind = "mentor", name = "Brann Kettering", bond = 50, age = { 60, 72 } },
					log = "You spent a year at {newRelation}'s bench and came away able to fix any lamp in the Guild.",
				},
			},
			{
				label = "Just sweep up for a few weeks",
				result = { money = { 4, 10 }, log = "You swept glass dust for a few weeks and took your pay in {currency} and broth." },
			},
		},
	},
	{
		id = "youth_rim_tram",
		title = "The Tram Down",
		text = "Your tutor is ill, and for once nobody is watching you. The tram to the lower tiers leaves from the foot of the garden steps every hour, bell ringing. You have heard the Silt smells of wet rope and kelp broth. You have never been wet in your life.",
		once = true,
		tags = { "youth", "rim" },
		when = { minAge = 13, maxAge = 17, side = "charter", flags = { "charter_born" } },
		choices = {
			{
				label = "Ride it all the way down",
				result = { justice = { 2, 3 }, prudence = 1, sanity = -2, setFlags = { "saw_the_silt" }, log = "You rode all the way to the Silt docks and stood in the fog until your shoes were ruined." },
			},
			{
				label = "Ride as far as the market",
				result = { temperance = 1, sanity = 1, log = "You rode to the Terraces market, bought a paper twist of salted kelp, and came home." },
			},
			{
				label = "Stay in the garden",
				result = { prudence = 1, sanity = -1, log = "You stayed in the garden and watched the tram go down without you." },
			},
		},
	},
}
