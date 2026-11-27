--[[
	Events that only happen during world events (see Content/WorldEvents.luau).
	Each world event queues its startEvent for everyone playing; the rest roll
	normally while it's on, boosted by its tagWeights.
	Sets: survived_breach, saw_the_thing (breach); lantern_night (festival).
]]

return {
	-- ── containment breach at the Tidewell Institute ──
	{
		id = "breach_sirens",
		title = "The Tidewell Sirens",
		text = "The sirens over Glasswall rise and fall, and every shutter on the street slams down at once. A runner shouts that something got out of the Institute's lower vaults. Nobody knows what it looks like. Everybody knows not to be outside when it comes past.",
		weight = 0,
		tags = { "breach", "danger" },
		choices = {
			{ label = "Bar the door and wait it out", result = { sanity = -3, log = "You sat behind a barred door all night, listening to the sirens move from street to street." } },
			{
				label = "Help the neighbors get inside",
				hint = "Justice clash. You'll be out in the open.",
				clash = { stat = "justice", foe = "The empty street", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, setFlags = { "survived_breach" }, log = "You pulled three families off the street before the shutters closed. One of them still sends you bread." },
				lose = { fortitude = { -10, -5 }, setFlags = { "survived_breach" }, condition = "night_terrors", log = "Something passed the end of the street while you were out there. You didn't see it. You felt it look at you.", cause = "Caught outside during the Tidewell breach" },
			},
			{ label = "Follow the sound to see it", hint = "Curiosity is a kind of courage.", requires = { min = { prudence = 25 } }, result = { sanity = -6, prudence = { 2, 4 }, setFlags = { "saw_the_thing" }, log = "You saw it, two streets away, folding itself through a drain grate. You will never be able to describe it properly." } },
		},
	},
	{
		id = "breach_thing_in_stairwell",
		title = "Something in the Stairwell",
		text = "The stairwell light has gone out, and the dark at the bottom of it is wet and breathing. The Institute's posters say: do not run, do not look directly at it, do not let it hear your name.",
		cooldown = 2,
		tags = { "breach", "danger", "strange" },
		when = { worldEvent = "breach_tidewell", minAge = 8 },
		choices = {
			{ label = "Walk past it, eyes on the floor", hint = "Prudence clash.", clash = { stat = "prudence", foe = "The thing in the stairwell", coins = 2, base = 5, coinPower = 3 }, win = { sanity = -2, prudence = { 1, 3 }, log = "You walked past it with your eyes on your shoes. It let you go. You don't know why." }, lose = { sanity = -8, condition = "night_terrors", log = "It said your name back to you, in your mother's voice." } },
			{ label = "Go back up and take the long way", result = { sanity = -1, log = "You took the long way, all eleven flights of it. Your legs shook for an hour." } },
		},
	},
	{
		id = "breach_evacuation_tram",
		title = "The Last Evacuation Tram",
		text = "The Institute is running free trams up to the Rim while the breach lasts. The last one is leaving, packed to the doors, and an old man with a birdcage is still running for it.",
		cooldown = 3,
		tags = { "breach" },
		when = { worldEvent = "breach_tidewell", minAge = 10 },
		choices = {
			{ label = "Hold the door for him", result = { sanity = 4, justice = { 1, 2 }, log = "You held the door with your whole body. He made it, birdcage and all, and the whole tram cheered." } },
			{ label = "Take his place", result = { sanity = -2, log = "You got the last space. You didn't look back at the platform." } },
		},
	},
	{
		id = "breach_institute_bounty",
		title = "The Institute Wants Witnesses",
		text = "A Tidewell clerk with a clipboard and a gas mask is paying for sightings. Where, when, how big, what color the air went. Accurate reports only.",
		cooldown = 3,
		tags = { "breach" },
		when = { worldEvent = "breach_tidewell", minAge = 12, flags = { "saw_the_thing" } },
		choices = {
			{ label = "Tell them exactly what you saw", result = { wage = { 30, 60 }, sanity = -2, log = "You told the clerk everything. They wrote it down without blinking and paid you in fresh notes." } },
			{ label = "Ask what it actually is", result = { sanity = -4, prudence = { 1, 2 }, log = "The clerk looked at you for a long time and then said, very kindly, that you don't want to know." } },
		},
	},
	{
		id = "breach_shutters_market",
		title = "Shutters Down at the Market",
		text = "The market shutters came down mid-sale. Half the stalls are locked with their goods inside, and the stall-keepers are trying to get them open before anyone else does.",
		cooldown = 2,
		tags = { "breach", "crime" },
		when = { worldEvent = "breach_tidewell", minAge = 12 },
		choices = {
			{ label = "Help the stall-keepers", result = { sanity = 2, wage = { 5, 15 }, log = "You helped pry the shutters back up. The fish-seller gave you a whole smoked eel for your trouble." } },
			{ label = "Help yourself", result = { money = { 20, 50 }, sanity = -3, justice = { -3, -1 }, log = "Nobody was watching. You told yourself that was the same as nobody minding." } },
		},
	},

	-- ── Lantern Night ──
	{
		id = "festival_lanterns",
		title = "Lantern Night",
		text = "Paper lanterns are going out over the Mere by the thousand, one for every name the water took. The Choir is singing from the rooftops, and someone has pressed a lantern and a stub of chalk into your hands.",
		weight = 0,
		tags = { "faith" },
		choices = {
			{ label = "Write a name on it and let it go", result = { sanity = 6, setFlags = { "lantern_night" }, log = "You wrote a name on the paper and let it go. It drifted out past the cathedral spire with all the others." } },
			{ label = "Sell lanterns to the crowd", result = { wage = { 20, 45 }, log = "You sold lanterns from a crate until your voice gave out." } },
			{ label = "Sing with the Choir", result = { sanity = 4, prudence = { 1, 2 }, log = "You sang from a rooftop with strangers until the last lantern went out." } },
		},
	},
	{
		id = "festival_free_tram",
		title = "Free Trams Tonight",
		text = "On Lantern Night the trams run free, and the whole city rides them in circles just to see the lights from every Ward.",
		cooldown = 2,
		tags = { "faith", "friend" },
		when = { worldEvent = "lantern_festival", minAge = 6 },
		result = { sanity = 4, log = "You rode the free tram all night, from the Rim down to the water and back, with your face against the glass." },
	},

	-- ── the Great Low Tide ──
	{
		id = "lowtide_streets",
		title = "Streets Under the Water",
		text = "The Mere has pulled back off a whole drowned street. There are shop signs still hanging, doors still shut, and people already running down the stairs with sacks.",
		weight = 0,
		tags = { "salvage" },
		choices = {
			{ label = "Join the rush", hint = "Fortitude clash. Others want it too.", clash = { stat = "fortitude", foe = "The crowd on the stairs", coins = 2, base = 4, coinPower = 3 }, win = { wage = { 40, 90 }, log = "You came back up with a brass shop bell and a box of old coins." }, lose = { fortitude = { -6, -2 }, log = "You were shoved off the stairs into the mud and came back with nothing but a twisted ankle." } },
			{ label = "Watch from the railing", result = { sanity = 2, prudence = { 1, 2 }, log = "You watched the city's old bones come up out of the water. It was the strangest, quietest thing you've seen." } },
		},
	},
	{
		id = "lowtide_old_house",
		title = "Your Great-Grandmother's Street",
		text = "Your family always said they came from a street that drowned. With the water this low, you can read the street sign.",
		once = true,
		tags = { "salvage", "strange" },
		when = { worldEvent = "great_low_tide", minAge = 10 },
		choices = {
			{ label = "Find the house", result = { sanity = 5, setFlags = { "found_old_house" }, log = "You found the house. The door was swollen shut, but your family's name was still carved on the step." } },
			{ label = "Leave it to the water", result = { sanity = 1, log = "You decided some things are better remembered than visited." } },
		},
	},

	-- ── Fog Week ──
	{
		id = "fog_door",
		title = "A Knock in the Fog",
		text = "The fog is so thick you can't see the end of your own arm. Someone knocks on your door, three times, slowly. Then again.",
		weight = 0,
		tags = { "strange", "danger" },
		choices = {
			{ label = "Don't answer", result = { sanity = -2, log = "You didn't answer. The knocking moved on to the next door, and then the next." } },
			{ label = "Open the door", hint = "Prudence clash.", clash = { stat = "prudence", foe = "Whatever is knocking", coins = 2, base = 4, coinPower = 3 }, win = { sanity = 3, log = "It was a lost child from three floors up. You walked them home with your hand on the railing the whole way." }, lose = { sanity = -7, log = "There was no one there. There were wet footprints leading in." } },
		},
	},
	{
		id = "fog_cough_week",
		title = "The Fog Cough",
		text = "Half the street is coughing. The stitchers are charging double and the broth sellers triple.",
		cooldown = 2,
		tags = { "danger" },
		when = { worldEvent = "fog_week", minAge = 4 },
		choices = {
			{ label = "Stay in and seal the windows", result = { sanity = -2, log = "You sealed the windows with wet rags and waited it out." } },
			{ label = "Work anyway", result = { wage = { 15, 30 }, fortitude = { -5, -2 }, log = "You worked through the fog for the overtime and coughed for a month." } },
		},
	},

	-- ── the Great Strike ──
	{
		id = "strike_picket",
		title = "The Picket Line",
		text = "The stokers have linked arms across the Pumpworks gate. The company's hired men are coming down the stairs with clubs, and the water is already over the lowest step.",
		weight = 0,
		tags = { "company", "crime" },
		choices = {
			{ label = "Stand with the stokers", hint = "Justice clash.", clash = { stat = "justice", foe = "The company's hired men", coins = 2, base = 5, coinPower = 3 }, win = { sanity = 4, justice = { 2, 3 }, setFlags = { "stood_with_strikers" }, log = "The line held. The hired men went back up the stairs, and the stokers sang the whole way after them." }, lose = { fortitude = { -10, -4 }, condition = "broken_arm", log = "A club came down on your arm, and the line broke around you.", cause = "Beaten on the picket line" } },
			{ label = "Carry food to the picket", result = { money = -10, sanity = 3, log = "You carried pots of broth down to the line. Nobody asked which side you were on." } },
			{ label = "Stay well away", result = { log = "You took the long way round and kept your head down." } },
		},
	},
}
