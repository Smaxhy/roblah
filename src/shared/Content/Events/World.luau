--[[
	World-state events: the Mere's water level and Lantern Night.
	Reads flags from other threads:
		sluice_marked (Life/Careers)       -> world_marked_flood
		lantern_for_calla (Youth)          -> world_lantern_night
		mentor_lost (Careers)              -> world_lantern_night
]]

return {
	{
		id = "world_low_salvage",
		title = "The Streets Come Up",
		text = "Low Water. Overnight the Mere has pulled back a whole street's depth, and the drowned city lies steaming in the morning light: roofs, chimneys, a tram line running down into the deep. Half the Silt is already out on the mud with sacks, ropes and lanterns.",
		weight = 14,
		cooldown = 2,
		tags = { "world", "low_water", "salvage" },
		when = { minAge = 12, world = { water = "low" } },
		choices = {
			{
				label = "Go out with a sack",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "Silt eels in the mud", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 30, 100 }, sanity = 2, log = "You came back from the drowned street with a sack of brass, glass and somebody's good spoons." },
				lose = {
					fortitude = { -10, -5 },
					sanity = -3,
					log = "An eel came out of a chimney pot at you, and you came home with nothing but the bite.",
					cause = "Bitten in the shallows",
				},
			},
			{
				label = "Sell rope and oil to the salvagers",
				result = { money = { 15, 35 }, temperance = 1, log = "You sold rope and lamp oil to the salvagers from a barrow and never got your boots wet." },
			},
			{
				label = "Watch from the stairs",
				result = { prudence = 1, sanity = 1, log = "You watched the drowned street steam in the sun from the safety of the stairs." },
			},
		},
	},
	{
		id = "world_low_cathedral",
		title = "The Cathedral Rises",
		text = "This Low Water is the lowest in forty years. The drowned cathedral has come all the way up, rose window and all, dripping weed. Its great doors stand open on a nave full of black water and empty pews. Something inside is ringing softly, though there is no wind.",
		weight = 4,
		once = true,
		tags = { "world", "low_water", "drowned_city", "danger" },
		when = { minAge = 16, maxAge = 60, world = { water = "low" }, chance = 0.2 },
		choices = {
			{
				label = "Go into the nave with a lantern",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The drowned nave", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = 4, money = { 80, 200 }, log = "You walked the drowned nave with your lantern held high and carried out the altar silver." },
				lose = { fortitude = { -4, -1 }, sanity = { -12, -8 }, log = "Your lantern went out halfway down the nave, and the ringing came from right beside you." },
			},
			{
				label = "Climb the tower and ring the bell",
				hint = "Justice clash, brutal. People have died trying.",
				requires = { min = { justice = 50 } },
				clash = { stat = "justice", foe = "The weed-slick tower", coins = 4, base = 8, coinPower = 4 },
				win = { justice = { 6, 8 }, sanity = 6, money = { 40, 80 }, log = "You climbed the drowned tower and rang the bell, and the whole crater heard it." },
				lose = { die = "Fell from the drowned cathedral", log = "You were three rungs from the bell when the weed gave way beneath your hands." },
			},
			{
				label = "Row sightseers out to the window",
				result = { money = { 20, 50 }, log = "You rowed sightseers out to the rose window for a few {currency} a head." },
			},
		},
	},
	{
		id = "world_low_street_sign",
		title = "A Sign with Your Name",
		text = "As the water drops, a street sign rises out of the mud by the old viaduct, its enamel crusted with tiny shells. You scrape it clean with your thumb. It reads {last} Street. Beyond it, a row of drowned doorways stands open, one with a brass knocker.",
		cooldown = 6,
		tags = { "world", "low_water", "drowned_city" },
		when = { minAge = 14, world = { water = "low" } },
		choices = {
			{
				label = "Knock with the brass knocker",
				result = { prudence = 1, sanity = { -6, -3 }, log = "You knocked on the drowned door. Something inside knocked back, twice, politely." },
			},
			{
				label = "Pry the sign loose and keep it",
				result = { temperance = 1, sanity = 2, log = "You pried the sign loose and hung it over your door. Nobody could tell you where it came from." },
			},
			{
				label = "Search the open doorways",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "The drowned doorways", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 40, 90 }, log = "You searched the drowned doorways and came away with a whole household's worth of brass." },
				lose = { fortitude = { -7, -3 }, sanity = -2, log = "The mud took you to the hips in the third doorway, and a stranger pulled you out." },
			},
		},
	},
	{
		id = "world_silt_flood",
		title = "High Water",
		text = "High Water. The Mere climbs the stilts a hand's width an hour, and the Sluice gates upstream stay shut. Walkways go under one by one. A neighbor's goats are bleating on a roof, and somewhere down the row a baby is crying. The water is at your door.",
		weight = 18,
		cooldown = 2,
		tags = { "world", "high_water", "silt", "danger" },
		when = { minAge = 8, side = "gutters", world = { water = "high" }, notFlags = { "sluice_marked", "paid_inspector" } },
		choices = {
			{
				label = "Help the neighbors up the stairs",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The rising water", coins = 2, base = 4, coinPower = 3 },
				win = { justice = { 3, 5 }, sanity = 4, relationBond = { kind = "all", amount = 4 }, log = "You carried two children and a goat up the switchbacks, then went back down for more." },
				lose = {
					fortitude = { -10, -5 },
					sanity = -4,
					log = "The current took your legs on the third trip, and you lost a long, cold hour.",
					cause = "Swept off a walkway in High Water",
				},
			},
			{
				label = "Save your own things",
				result = { money = { -15, -5 }, prudence = 1, sanity = -2, log = "You saved your bedding and your tin of {currency}, and lost everything else to the Mere." },
			},
			{
				label = "Rent a room up on the Terraces",
				hint = "100 scrip.",
				requires = { min = { money = 100 } },
				result = { money = -100, sanity = 1, log = "You paid a Terraces landlord double rent and watched your old row go under from the stairs." },
			},
		},
	},
	{
		id = "world_marked_flood",
		title = "Circled in Red",
		text = "Your address was circled in red, and this High Water the Authority opens Gate Nine a day early. The water comes up your stairs in a single night. A Sluice launch goes past your window with its lamp lit, and does not slow down.",
		weight = 20,
		once = true,
		tags = { "world", "high_water", "silt", "sluice" },
		when = { minAge = 18, side = "gutters", world = { water = "high" }, flags = { "sluice_marked" } },
		choices = {
			{
				label = "Swim for the Terraces stairs",
				hint = "Fortitude clash, hard.",
				clash = { stat = "fortitude", foe = "The Gate Nine surge", coins = 3, base = 6, coinPower = 3 },
				win = { fortitude = 2, sanity = 2, clearFlags = { "sluice_marked" }, log = "You swam the flooded row to the Terraces stairs and climbed out shaking, but whole." },
				lose = {
					fortitude = { -12, -6 },
					sanity = -5,
					clearFlags = { "sluice_marked" },
					log = "The surge from Gate Nine rolled you under twice before you caught a piling.",
					cause = "Drowned in the Gate Nine surge",
				},
			},
			{
				label = "Wait it out on the roof",
				result = { money = { -40, -20 }, sanity = -6, clearFlags = { "sluice_marked" }, log = "You spent three days on your roof watching your things float away down the row." },
			},
		},
	},
	{
		id = "world_dry_address",
		title = "The Star by Your Address",
		text = "High Water, and the Sluice gates open on every row but yours. Your walkway stays dry, a little island in the flood. Across the channel your neighbors are sitting on their roofs with their bedding, and one of them is looking straight at your dry windows.",
		weight = 20,
		once = true,
		tags = { "world", "high_water", "silt", "thread_inspector" },
		when = { minAge = 18, side = "gutters", world = { water = "high" }, flags = { "paid_inspector" } },
		choices = {
			{
				label = "Row your neighbors over",
				result = { money = { -20, -10 }, justice = 4, sanity = 2, log = "You rowed your neighbors over to your dry rooms and fed them until the water went down." },
			},
			{
				label = "Keep the curtains closed",
				result = { justice = -2, sanity = -5, log = "You kept the curtains closed for a week and listened to the flood next door." },
			},
		},
	},
	{
		id = "world_stair_refugees",
		title = "People on the Stairs",
		text = "The Silt is under water again, and the switchback stairs are full of people sitting on bundles in the rain: a grandmother with a cage of chickens, two boys sharing one coat. A Sluice clerk is walking up and down, telling everyone to move along.",
		cooldown = 3,
		tags = { "world", "high_water", "terraces", "rim" },
		when = { minAge = 16, world = { water = "high" } },
		choices = {
			{
				label = "Take a family into your rooms",
				result = {
					money = { -40, -20 },
					justice = 4,
					sanity = 3,
					addRelation = { kind = "friend", bond = 45, age = { 25, 45 } },
					log = "You took a flooded family in until the water went down, and {newRelation} never forgot it.",
				},
			},
			{
				label = "Hand out broth",
				hint = "15 scrip.",
				requires = { min = { money = 15 } },
				result = { money = -15, justice = 2, sanity = 3, log = "You carried pots of kelp broth up and down the stairs until the rain stopped." },
			},
			{
				label = "Tell the clerk to leave them be",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A Sluice clerk", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 2, log = "You argued with the clerk until he gave up and went to bother the tram queue instead." },
				lose = { justice = 1, sanity = -3, log = "The clerk took down your name, and the families were moved along anyway." },
			},
		},
	},
	{
		id = "world_lantern_night",
		title = "Lantern Night",
		text = "Lantern Night. All along the waterline people kneel to set paper lanterns on the Mere, one for every name it has taken. The pumps stop for the only hour of the year. In the hush you can hear the paper rustle as the lanterns drift out over the drowned city.",
		weight = 8,
		cooldown = 5,
		tags = { "world", "lantern_night" },
		when = { minAge = 4 },
		choices = {
			{
				label = "Float Calla Hollin's lantern",
				requires = { flags = { "lantern_for_calla" } },
				result = { prudence = 2, sanity = 6, clearFlags = { "lantern_for_calla" }, log = "You set Calla Hollin's lantern on the water and watched it drift out toward Gull Street." },
			},
			{
				label = "Float a lantern for Hesper",
				requires = { flags = { "mentor_lost" } },
				result = { sanity = 6, clearFlags = { "mentor_lost" }, log = "You floated a lantern for Hesper Coldwater, and the divers on the Guild pier bowed their heads." },
			},
			{
				label = "Float one for everyone",
				result = { sanity = 4, relationBond = { kind = "all", amount = 3 }, log = "You floated a lantern for everyone the Mere had taken, and one more for whoever came next." },
			},
		},
	},
	{
		id = "world_lanterns_go_out",
		title = "The Lanterns Go Out",
		text = "Halfway through Lantern Night, the paper lanterns far out on the Mere start going dark, a row at a time, from the deep water inward. People on the shore stop talking. Lamp-eaters, someone whispers. The last of the lanterns are drifting toward the bank, toward you.",
		weight = 5,
		cooldown = 8,
		tags = { "world", "lantern_night", "lamp_eaters" },
		when = { minAge = 6, chance = 0.5 },
		choices = {
			{
				label = "Shield the nearest lanterns",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Lamp-eaters", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 2, sanity = 5, log = "You cupped your hands around the nearest lanterns until the dark moved on. Seven stayed lit." },
				lose = { sanity = { -8, -4 }, log = "Every lantern went out in front of you, and the cold off the water went right through you." },
			},
			{
				label = "Relight them from your own wick",
				result = { temperance = 2, sanity = 2, log = "You relit lanterns from your own wick and set them out again, one after another." },
			},
			{
				label = "Back away from the water",
				result = { prudence = 1, sanity = -3, log = "You backed away from the water and watched the dark come in." },
			},
		},
	},
}
