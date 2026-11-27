--[[
	STRANGE THINGS (v0.17, str17_ ids): encounters with the new creatures (Engine/Creatures17):
	the City's urban legends, and one Distortion. Adults only; nobody young is hurt.
	Distortions only exist after the Light (eras library and limbus).
]]

local function fight(stat: string, foe: string, enemy: string, coins: number, base: number, power: number)
	return { stat = stat, foe = foe, enemy = enemy, fight = true, coins = coins, base = base, coinPower = power }
end

return {
	{
		id = "str17_spider_doll",
		title = "The Doll on the Stairs",
		art = "home",
		weight = 6,
		cooldown = 15,
		tags = { "strange", "danger" },
		when = { minAge = 16 },
		text = "The antique shop under your building sold an old porcelain doll last week. Tonight it's back, on the stairs, on six long thin legs, tilting its head at your door. Everyone in the building has heard it on the landings. Nobody has opened a door.",
		choices = {
			{ label = "Open the door and deal with it", clash = fight("speed", "The Spider Doll", "doll_spider", 3, 7, 3), win = { speed = 3, renown = 6, setFlags = { "str17_doll" }, log = "It was fast. You were faster. In the morning the shop owner found the doll back on its shelf, in pieces, and closed the shop for good." }, lose = { health = { -14, -6 }, sanity = -6, log = "It got past you into the stairwell and up to the roof, giggling. It hasn't come down. Everyone takes the lift now." } },
			{ label = "Wedge the door and wait for morning", result = { sanity = -4, log = "It tapped on your door with one leg until four. Then it stopped. In the morning there were tiny holes in the paint all the way up the stairs." } },
		},
	},
	{
		id = "str17_drift_jelly",
		title = "Something Drifting Down the Street",
		art = "street",
		weight = 5,
		cooldown = 15,
		tags = { "strange" },
		when = { minAge = 16 },
		text = "After the rain, a glowing bell the size of a car is drifting down your street at head height, trailing threads of light. It's very beautiful. The threads have caught a delivery bicycle, and the courier, and they aren't letting go.",
		choices = {
			{ label = "Cut the courier loose", clash = fight("strength", "A Drifting Jelly", "drift_jelly", 3, 6, 3), win = { strength = 2, charisma = 2, renown = 5, log = "You cut him loose, thread by thread. It stung like nettles. The jelly drifted on, unbothered, toward the next street." }, lose = { health = { -12, -6 }, log = "The threads caught you too. You both got loose eventually. You both glowed faintly for a week." } },
			{ label = "Talk him through getting loose", clash = { stat = "intelligence", foe = "Threads that tighten when you pull", coins = 2, base = 6, coinPower = 3 }, win = { intelligence = 3, log = "Don't pull. Turn. Slide. He was out in a minute, shaking. The jelly never noticed." }, lose = { sanity = -3, log = "It took an hour. The jelly drifted off with his bicycle." } },
			{ label = "Watch it go by", result = { sanity = 3, log = "You watched it light up the wet street, slowly, all the way to the end. The courier got loose on his own. The City is strange, and sometimes it's lovely." } },
		},
	},
	{
		id = "str17_patchwork",
		title = "The Patchwork Man",
		art = "distortion",
		weight = 5,
		cooldown = 18,
		tags = { "strange", "danger" },
		when = { minAge = 18, world = { era = { "library", "limbus" } } },
		text = "The tailor on the corner Distorted last night. What stands in his shop window now is very big, stitched together out of every bolt of cloth he had, with button eyes and one enormous fist. It keeps trying to fit people for suits. It doesn't take no for an answer.",
		choices = {
			{ label = "Fight it", clash = fight("strength", "The Patchwork Man", "stitched_giant", 4, 8, 3), win = { strength = 3, renown = 10, setFlags = { "str17_patchwork" }, log = "It came apart at the seams, literally. Under all the cloth there was a tape measure, still holding its place." }, lose = { health = { -24, -12 }, cause = "Measured by a Distortion", log = "It measured you, very thoroughly. You got away with a perfectly fitted jacket and two broken ribs." } },
			{ label = "Let it measure you and slip away", clash = { stat = "speed", foe = "A fitting you can't refuse", coins = 3, base = 7, coinPower = 3 }, win = { speed = 3, log = "Arms out, turn, the tape round your chest, and you were gone through the back of the shop before it finished writing the number down." }, lose = { health = { -10, -5 }, log = "It noticed. It doesn't like customers who leave before the fitting." } },
			{ label = "Call the Office down the road", result = { money = -40, sanity = -2, log = "The Office sent three Fixers and a bill. The shop is empty now. Somebody left flowers on the step for the tailor." } },
		},
	},
	{
		id = "str17_eye_mound",
		title = "The Many Eyes in the Cistern",
		art = "underpass",
		weight = 4,
		cooldown = 20,
		tags = { "strange", "danger" },
		when = { minAge = 18, side = "backstreets" },
		text = "The water's been bad for a week, so you went down into the old cistern with a lamp to see why. Something is sitting in the dark at the bottom: a mound, and on the mound, eyes on stalks, and every one of them opens as your lamp comes round.",
		choices = {
			{ label = "Fight it in the dark", clash = fight("mind", "The Many-Eyed Mound", "eye_mound", 4, 8, 3), win = { mind = 4, renown = 8, log = "You fought it without looking at it, which is the only way. The water ran clean by morning." }, lose = { sanity = -12, health = { -10, -4 }, log = "You looked. You shouldn't have looked. You're not sure how you got back up the ladder." } },
			{ label = "Back up the ladder slowly", result = { sanity = -5, log = "You backed up the ladder one rung at a time. Every eye followed you. You've bought bottled water since." } },
		},
	},
	{
		id = "str17_bloom",
		title = "The Flower in the Greenhouse",
		art = "nest",
		weight = 4,
		cooldown = 20,
		tags = { "strange" },
		when = { minAge = 16 },
		text = "A Nest greenhouse has been selling cuttings of a prize flower, and a cutting found its way to your street. It's taller than you now, and it smiles. The neighbourhood cats have gone missing one by one, then come back, very well fed and very nervous.",
		choices = {
			{ label = "Dig it up", clash = fight("strength", "The Smiling Bloom", "smiling_bloom", 3, 7, 3), win = { strength = 2, sanity = 3, renown = 5, log = "It didn't like being dug up. You didn't like digging. The roots went down further than the building does." }, lose = { health = { -12, -6 }, log = "It smiled wider and you found yourself on your back in the soil. You'll try again with a bigger shovel." } },
			{ label = "Water it and see what happens", result = { luck = 2, sanity = -2, log = "It loved the water. It smiled at you every morning after that, and it never did anything to you. You're not sure that's better." } },
		},
	},
	{
		id = "str17_scrap",
		title = "The Junkyard Stood Up",
		art = "workshop",
		weight = 5,
		cooldown = 15,
		tags = { "strange", "danger" },
		when = { minAge = 16, side = "backstreets" },
		text = "The scrapyard at the end of the road has been humming for three nights. Tonight a fridge, a television, two drainpipes and a shopping cart stood up together and walked out of the gate. The television is showing a test pattern. It's looking for something.",
		choices = {
			{ label = "Take it apart", clash = fight("strength", "The Scrap Golem", "scrap_golem", 3, 8, 3), win = { strength = 3, money = 60, log = "It came apart into what it was made of. You sold the copper. The television kept showing the test pattern for a day, then a weather report from forty years ago." }, lose = { health = { -16, -8 }, log = "It shoved you into a skip and went on looking. It found what it wanted, an old radio, and sat down with it in the road." } },
			{ label = "Find what it's looking for", clash = { stat = "intelligence", foe = "What a scrap heap wants", coins = 2, base = 7, coinPower = 3 }, win = { intelligence = 3, luck = 2, log = "An old radio, in the bottom of a skip. You put it in its claw. It sat down, turned the dial, and fell apart, peacefully, to a song nobody's played in years." }, lose = { log = "You guessed wrong three times. It wandered off toward the next District." } },
		},
	},
}
