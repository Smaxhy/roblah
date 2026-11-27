--[[
	Strange events: the drowned city, lamp-eaters, the Quiet, and the Tidetouched.
	Threads:
		music_box (Childhood) -> odd_music_box_plays -> music_box_answered -> odd_music_box_source (Low Water)
		odd_the_quiet -> odd_quiet_closer (3 yrs)
		tide_stage1 / tide_stage2   odd_tide_cold -> odd_tide_lines -> odd_tide_call (form = "tidetouched")
]]

return {
	{
		id = "odd_music_box_plays",
		title = "It Plays at Night",
		text = "The brass box from the mud has started playing on its own. Always after midnight, always the same slow, patient tune, like someone humming while they wait. The tune has more notes than the box has teeth. Tonight it stops halfway through, as if it's listening.",
		once = true,
		weight = 14,
		tags = { "strange", "thread_music_box" },
		when = { minAge = 10, flags = { "music_box" } },
		choices = {
			{
				label = "Hum the rest of the tune",
				result = { prudence = 2, sanity = { -4, -2 }, setFlags = { "music_box_answered" }, log = "You hummed the rest of the tune. Far below the floor and the Mere, something hummed back." },
			},
			{
				label = "Wrap it up and sleep elsewhere",
				result = { sanity = -1, log = "You wrapped the box in three blankets and slept in the kitchen for a month." },
			},
			{
				label = "Sell it to a Rim collector",
				result = { money = { 40, 90 }, sanity = 1, clearFlags = { "music_box" }, log = "A Rim collector paid well for the box. You heard it playing in his coat as he left." },
			},
		},
	},
	{
		id = "odd_music_box_source",
		title = "The House with the Tune",
		text = "Low Water, and out on the mudflats you hear it: your music box's tune, coming from a drowned house half out of the water with its door hanging open. The box in your pocket is playing along, one beat behind. The two tunes are trying to meet.",
		once = true,
		weight = 16,
		tags = { "strange", "low_water", "thread_music_box" },
		when = { minAge = 12, flags = { "music_box_answered" }, world = { water = "low" } },
		choices = {
			{
				label = "Carry the box inside",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The house with the tune", coins = 3, base = 6, coinPower = 3 },
				win = {
					prudence = 3,
					sanity = 8,
					clearFlags = { "music_box", "music_box_answered" },
					log = "You set the box on a drowned mantel beside its twin, and they finished the tune together.",
				},
				lose = {
					sanity = { -12, -8 },
					clearFlags = { "music_box", "music_box_answered" },
					log = "The door swung shut behind you. When you found your way out, your pocket was empty.",
				},
			},
			{
				label = "Throw the box through the door",
				result = { sanity = 3, clearFlags = { "music_box", "music_box_answered" }, log = "You threw the box through the open door. The tune stopped mid-note, all over the Silt." },
			},
			{
				label = "Walk away fast",
				result = { sanity = -3, log = "You walked away fast, and the tune followed you up the stairs, one beat behind." },
			},
		},
	},
	{
		id = "odd_bridge_dark",
		title = "Dark on the Bridge",
		text = "Halfway across the rope bridge to the salvage docks, the lamps strung along the handrail start going out ahead of you. One, then the next, then the next, coming your way. There is no wind at all. Your own lantern flickers as if it's frightened.",
		cooldown = 5,
		tags = { "strange", "silt", "lamp_eaters" },
		when = { minAge = 10, side = "gutters" },
		choices = {
			{
				label = "Hide your lantern under your coat",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Lamp-eaters", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = { 2, 3 }, sanity = 1, log = "You hid the flame under your coat and stood still until the dark had gone past you." },
				lose = { sanity = { -7, -4 }, log = "Something brushed past you in the dark, cold and soft as wet paper." },
			},
			{
				label = "Run for the far end",
				hint = "Justice clash.",
				clash = { stat = "justice", foe = "The swaying bridge", coins = 2, base = 3, coinPower = 2 },
				win = { justice = 2, sanity = 1, log = "You ran the swaying bridge flat out and reached the docks with your lantern still lit." },
				lose = {
					fortitude = { -6, -3 },
					sanity = -2,
					log = "You slipped on the wet planks and spent the night in the dark with a twisted ankle.",
					cause = "Fell from the rope bridge",
				},
			},
			{
				label = "Blow out your own lantern",
				result = { prudence = 1, sanity = -2, log = "You blew out your lantern and crossed by touch, and nothing bothered you at all." },
			},
		},
	},
	{
		id = "odd_the_quiet",
		title = "The Quiet",
		text = "From the end of the pier, in the clear water past the drop-off, you see them again: the Quiet. A dozen people-shaped shapes stand on the drowned street below, faces turned up toward the light. They never move. Tonight there is one more of them than last year.",
		once = true,
		weight = 8,
		tags = { "strange", "silt", "the_quiet" },
		when = { minAge = 14, side = "gutters" },
		choices = {
			{
				label = "Count them carefully",
				result = {
					prudence = 2,
					sanity = -3,
					schedule = { event = "odd_quiet_closer", inYears = 3 },
					log = "You counted thirteen, and told yourself you had miscounted last year.",
				},
			},
			{
				label = "Shine your lantern down at them",
				result = {
					justice = 1,
					sanity = { -6, -3 },
					schedule = { event = "odd_quiet_closer", inYears = 3 },
					log = "You shone your lantern down at them. Every face was already turned toward it.",
				},
			},
			{
				label = "Look away and go home",
				result = { sanity = 1, log = "You looked away, walked home, and did not count them again." },
			},
		},
	},
	{
		id = "odd_quiet_closer",
		title = "A Little Closer",
		text = "One of the Quiet is standing in the shallows by the pier where you counted them, waist-deep, close enough to see the slope of its shoulders under the water. Nobody saw it move. It has stopped looking up at the light. It is facing the stairs to your door.",
		weight = 0,
		once = true,
		tags = { "strange", "the_quiet" },
		choices = {
			{
				label = "Leave a lantern lit for it",
				result = { prudence = 2, sanity = 2, log = "You left a lantern burning on the pier every night. One morning the shallows were empty." },
			},
			{
				label = "Ask the Choir to sit with it",
				result = { sanity = { 2, 4 }, log = "Three Choristers sat facing it all night. By dawn it stood further out than before." },
			},
			{
				label = "Wade out and stand beside it",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The Quiet", coins = 3, base = 6, coinPower = 3 },
				win = { prudence = 4, sanity = 6, log = "You waded out and stood beside it until sunrise. After that, it was only a statue." },
				lose = { sanity = { -14, -10 }, log = "You waded out and stood beside it, and for a long time afterward you could not stop standing still." },
			},
		},
	},
	{
		id = "odd_tide_cold",
		title = "Cold Hands",
		text = "You wake up cold, though the stove is lit and the blankets are thick. Your hands stay cool as river stones all day. At the noodle barge you hold your breath to finish a joke and forget to let it out. Nobody else is counting. You are.",
		once = true,
		weight = 3,
		tags = { "strange", "tidetouched", "thread_tide" },
		when = { minAge = 14, maxAge = 45, side = "gutters", form = "human", chance = 0.3 },
		choices = {
			{
				label = "Go and sit in the shallows",
				result = {
					fortitude = 2,
					sanity = 2,
					setFlags = { "tide_stage1" },
					schedule = { event = "odd_tide_lines", inYears = 2 },
					log = "You sat in the shallows until dusk, and the cold water felt warmer than the air.",
				},
			},
			{
				label = "See a stitcher",
				hint = "30 scrip.",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = 1, log = "The stitcher listened to your chest for a long time and charged you thirty {currency} for a shrug." },
			},
			{
				label = "Wear two coats and ignore it",
				result = {
					prudence = 1,
					setFlags = { "tide_stage1" },
					schedule = { event = "odd_tide_lines", inYears = 3 },
					log = "You wore two coats all winter and told everyone it was the fog.",
				},
			},
		},
	},
	{
		id = "odd_tide_lines",
		title = "Lines at the Throat",
		text = "Two faint lines have appeared on each side of your neck, pale as chalk marks. In the washbasin they open very slightly, and the water tastes of the Mere. On the docks, an old Tidetouched boatman sees them and touches two fingers to his own throat in greeting.",
		weight = 0,
		once = true,
		tags = { "strange", "tidetouched", "thread_tide" },
		choices = {
			{
				label = "Ask the boatman what comes next",
				result = {
					prudence = 2,
					sanity = 1,
					setFlags = { "tide_stage2" },
					schedule = { event = "odd_tide_call", inYears = 2 },
					log = "The boatman told you what comes next, slowly, in a voice like wet rope.",
				},
			},
			{
				label = "Hide them under a high collar",
				result = {
					sanity = -3,
					setFlags = { "tide_stage2" },
					schedule = { event = "odd_tide_call", inYears = 2 },
					log = "You bought high collars and stopped going near basins, mirrors and puddles.",
				},
			},
			{
				label = "Sit with the Choir in the dry chapel",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The pull of the Mere", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, sanity = 4, clearFlags = { "tide_stage1" }, log = "You sat with the Choir in their dry chapel for a season, and the lines faded to nothing." },
				lose = {
					sanity = -4,
					setFlags = { "tide_stage2" },
					schedule = { event = "odd_tide_call", inYears = 2 },
					log = "You sat with the Choir for a whole season, but the lines only deepened.",
				},
			},
		},
	},
	{
		id = "odd_tide_call",
		title = "The Mere Calls",
		text = "You can hear the Mere all the time now, under the pumps and the tram bells: a slow breathing that matches your own. Your skin is cool, your breath comes slow, and dry air scratches your throat. Tonight the water at the foot of the stairs laps the bottom step, waiting.",
		weight = 0,
		once = true,
		tags = { "strange", "tidetouched", "thread_tide" },
		choices = {
			{
				label = "Wade in and let the change finish",
				result = {
					form = "tidetouched",
					fortitude = { 4, 6 },
					sanity = -2,
					clearFlags = { "tide_stage1", "tide_stage2" },
					log = "You waded in up to your chin and let the Mere in. You walked out Tidetouched, and calm.",
				},
			},
			{
				label = "Fight the pull",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The pull of the Mere", coins = 3, base = 6, coinPower = 3 },
				win = {
					prudence = 4,
					sanity = 3,
					clearFlags = { "tide_stage1", "tide_stage2" },
					log = "You turned your back on the water and climbed the stairs. By spring your hands were warm again.",
				},
				lose = {
					form = "tidetouched",
					sanity = -6,
					clearFlags = { "tide_stage1", "tide_stage2" },
					log = "You fought it for a year and lost. One morning you woke Tidetouched, breathing slow.",
				},
			},
		},
	},
	{
		id = "odd_tide_swim",
		title = "Breathing Below",
		text = "You can stay under for an hour now, longer if you're calm. Down in the drowned streets the light is green and slow, and the silt eels ignore you like one of their own. Last week a Rim gate guard spat at your feet. Down here, nobody minds what you are.",
		cooldown = 5,
		tags = { "strange", "tidetouched" },
		when = { minAge = 14, form = "tidetouched" },
		choices = {
			{
				label = "Salvage where no diver can reach",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The deep streets", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 50, 120 }, sanity = 2, log = "You salvaged a drowned jeweler's shop that no lantern diver had ever reached." },
				lose = { fortitude = { -7, -3 }, sanity = -3, log = "Even you could not stay down long enough. You came up dizzy and empty-handed." },
			},
			{
				label = "Guide a lost diver home",
				result = { justice = 3, sanity = 3, log = "You found a lost Guild diver in the dark and led them up toward the light." },
			},
			{
				label = "Just drift for a while",
				result = { sanity = { 4, 6 }, log = "You drifted in the green light above the drowned rooftops until you felt like yourself." },
			},
		},
	},
}
