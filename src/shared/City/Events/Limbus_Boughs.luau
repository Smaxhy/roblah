--[[
	Golden Boughs and the Mirror (983+). Writer D (lim_ ids).
	Canon notes: docs/CANON.md 7.4 (Boughs, the Mirror) and 7.8 (the Cantos by District).
	Each Bough site sits in the District of a Canto, and its gold light shows a piece of
	that Canto's Sinner, spoiler-light. Getting close triggers lim_bough_resonance.
	All of them set lim_bough_seen (shared hook).
]]

local ERA = { era = "limbus" }

-- the three ways a Bough site goes; each District's event words them its own way
local function tellScouts(log)
	return { wage = { 40, 120 }, setFlags = { "lim_bough_seen", "lim_lccb_contact" }, addTrait = "golden_bough_seeker", codex = "lim_golden_boughs", schedule = { event = "lim_lccb_offer", inYears = 1 }, log = log }
end
local function goDown(foe, winLog, loseLog)
	return {
		label = "Go down and look",
		hint = "Mental Strength check. Nobody knows what a Bough does to an ordinary person.",
		clash = { stat = "mind", foe = foe, coins = 2, base = 5, coinPower = 3 },
		win = { setFlags = { "lim_bough_seen", "lim_bough_found" }, chronicle = "lim_bough_found", trigger = "lim_bough_resonance", codex = "lim_golden_boughs", log = winLog },
		lose = { health = { -8, -3 }, sanity = -4, setFlags = { "lim_bough_seen" }, cause = "Went looking for a Golden Bough", log = loseLog },
	}
end
local function keepQuiet(log)
	return { mind = 2, sanity = -1, setFlags = { "lim_bough_seen" }, codex = "lim_golden_boughs", log = log }
end

return {
	-- what being close to a Bough does (triggered by any site's "go down")
	{
		id = "lim_bough_resonance",
		when = { world = { era = "limbus" } },
		title = "Resonance",
		text = "Up close, the Golden Bough is small: a twig of light no longer than your hand, growing out of nothing in the middle of an L Corp floor. The air around it hums. Then the floor tilts, and for a moment you're somewhere else, inside a stranger's worst day, seeing it the way they saw it. It is very clear. It is not yours.",
		weight = 0,
		codex = "lim_golden_boughs",
		choices = {
			{
				label = "Hold on to the memory",
				result = { addTrait = "lim_gold_eyes", condition = "lim_bough_echo", sanity = -3, log = "You held on until it let go of you. You came up out of the branch knowing how it felt to be someone else, and with a little of their skill in your hands. The LCCB scouts who found you wrapped you in a blanket and asked you to sign a form." },
			},
			{
				label = "Pull yourself out",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Someone else's memory", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 3, addTrait = "lim_gold_eyes", log = "You pulled back out of it like out of cold water. The Bough flickered, as if disappointed. You climbed out alone and told the first LCCB scout you found exactly where it was." },
				lose = { sanity = -6, condition = "lim_bough_echo", log = "It didn't let go when you wanted it to. You came out with a stranger's memory sitting in yours like a lodger, and it isn't leaving soon." },
			},
		},
	},

	-- ── the Bough sites, Canto by Canto ──
	{
		id = "lim_bough_d4",
		title = "Gold Under District 4",
		text = "The manhole at the end of your street has started glowing at night, a warm gold that leaks around the rim. District 4 is where the bus first stopped, people say, and under it is a buried L Corp branch. Everyone avoids the manhole. Lately you've been dreaming of a soldier waiting in a trench for a war to end.",
		weight = 12,
		once = true,
		tags = { "limbus", "bough" },
		when = { world = ERA, minAge = 14, district = "d4" },
		codex = "lim_golden_boughs",
		choices = {
			{ label = "Tell the LCCB scouts", result = tellScouts("Two Before Team scouts in muddy boots took your report very seriously, paid you a finder's fee and asked you not to dream about it so loudly. A week later the manhole was welded shut.") },
			goDown("The dark under District 4", "You lifted the cover and climbed down a ladder that went on longer than the street is deep. At the bottom, among broken L Corp signs, something small was glowing.", "The ladder ended in water and the glow moved away from you whenever you got close. You climbed back up soaked and shaking."),
			{ label = "Keep it to yourself", result = keepQuiet("You kept walking past it. Some nights you stood at your window and watched the gold breathe around the rim. You dreamed of the trench every night until the LCCB came.") },
		},
	},
	{
		id = "lim_bough_d11",
		title = "Gold Behind the Checkpoint",
		text = "K Corp's drones hover over one stretch of the Backstreets wall at night, all pointed at the same patch of pavement, where a crack glows gold. The bus came through District 11 twice, people say. Since the crack appeared, everyone on your block has the same dream: a pale man with wings that won't open, and a boy with a red mark on his hand.",
		weight = 12,
		once = true,
		tags = { "limbus", "bough" },
		when = { world = ERA, minAge = 14, district = "d11" },
		codex = "lim_golden_boughs",
		choices = {
			{ label = "Tell the LCCB scouts", result = tellScouts("The scouts thanked you, then argued with K Corp's drones for a week about whose crack it was. Limbus Company won. You don't know how. Nobody on your block dreams about wings anymore.") },
			goDown("The drones and the dark", "You waited for a gap in the drone patrol and pried up the paving stone. Below it, a staircase. Below that, an L Corp floor, and a light.", "A drone caught you on the paving stone and K Corp fined you for trespassing on its own wall. The crack had sealed by morning."),
			{ label = "Keep it to yourself", result = keepQuiet("You kept the dream to yourself. Wings that won't open. You think you understand the man in it now, a little, and you don't want anyone else to.") },
		},
	},
	{
		id = "lim_bough_d21",
		title = "Gold Under the Great Lake",
		text = "Fishermen on the Great Lake say there's a gold light under the water past the Stingray Portship's moorings, where a buried branch slid into the lake years ago. They won't fish there. They say that if you look into the light, you see a whaling ship called the Pequod, and a captain on its deck who won't stop staring at the horizon.",
		weight = 12,
		once = true,
		tags = { "limbus", "bough" },
		when = { world = ERA, minAge = 14, district = "d21" },
		codex = "lim_golden_boughs",
		choices = {
			{ label = "Tell the LCCB scouts", result = tellScouts("The Before Team hired a boat and a diver and paid you to row. The diver came up with a sealed case that glowed through the seams and didn't speak for the rest of the day.") },
			goDown("The cold water", "You rowed out at dawn and dove. The branch's roof was only a few meters down, and a hatch was open. Inside, past the dark, the light.", "The cold took your breath before you reached the light, and you came up gasping and turned for shore. The fishermen were right. You don't fish there either."),
			{ label = "Keep it to yourself", result = keepQuiet("You looked into the light once, from the end of the pier, and saw the captain on the deck, staring. You understood why nobody fishes there. You didn't tell anyone.") },
		},
	},
	{
		id = "lim_bough_d20",
		title = "Gold in the Grey",
		text = "In District 20 color is a privilege, taxed by T Corp like everything else. So everyone notices the alley where the cobbles have started to glow gold. T Corp's Collection Staff can't decide who to bill for it. Children who play near it come home talking about a manor on a windy hill, and a dark-haired boy who isn't allowed in.",
		weight = 12,
		once = true,
		tags = { "limbus", "bough" },
		when = { world = ERA, minAge = 14, district = "d20" },
		codex = "lim_golden_boughs",
		choices = {
			{ label = "Tell the LCCB scouts", result = tellScouts("The Before Team arrived before T Corp's auditors did, which in District 20 is a kind of miracle. They paid you in cash. Cash in District 20 comes with a Time Tax, but it was worth it.") },
			goDown("The glowing alley", "You pried up the brightest cobble. Underneath was a drain, and under the drain, an L Corp maintenance shaft lit gold all the way down.", "A T Corp Collector caught you prying up the cobbles and billed you for the time you'd wasted. It was a lot of time."),
			{ label = "Keep it to yourself", result = keepQuiet("You walked past the alley every day and let it be the one bit of color nobody could tax. The children kept talking about the boy on the hill.") },
		},
	},
	{
		id = "lim_bough_d16",
		title = "Gold Under the Spires",
		text = "Under P Corp's bending spires, on a lot that was empty last week, a theme park has opened overnight: banners, a castle, a carousel of iron horses. It closes the same way, overnight, and all that's left is a gold glow coming up through a crack in the tarmac and the faint sound of someone shouting about justice.",
		weight = 12,
		once = true,
		tags = { "limbus", "bough" },
		when = { world = ERA, minAge = 14, district = "d16" },
		codex = "lim_golden_boughs",
		choices = {
			{ label = "Tell the LCCB scouts", result = tellScouts("The scouts didn't seem surprised by the theme park at all, which was the most frightening part. They fenced the lot, paid you, and asked if you'd ridden the carousel. You hadn't. They looked relieved.") },
			goDown("The crack in the tarmac", "You squeezed through the crack into an L Corp service corridor. The walls were painted, badly, with knights and windmills. At the end of it, a light.", "The crack closed a little as you climbed in, as if it had changed its mind. You got out with scraped hands and the sound of a carousel in your ears."),
			{ label = "Keep it to yourself", result = keepQuiet("You kept away from the lot. At night, from your window, you could see the gold through the fence, and you could have sworn you heard someone shout \"Onward!\"") },
		},
	},
	{
		id = "lim_bough_d8",
		title = "Gold Inside Hongyuan",
		text = "Hongyuan shifts in the night, the way it does, and in the morning there's a new stairwell outside your room that goes down instead of up, lit gold from below. The air on the stairs smells like incense and old silk. Your neighbors swear they heard a young man laughing down there, very happily, and a woman counting sword strokes.",
		weight = 12,
		once = true,
		tags = { "limbus", "bough" },
		when = { world = ERA, minAge = 14, district = "d8" },
		codex = "lim_golden_boughs",
		choices = {
			{ label = "Tell the LCCB scouts", result = tellScouts("The Before Team got there an hour before the building shifted again and took the stairwell with it. They paid you for the hour. One of them was crying, quietly, and wouldn't say why.") },
			goDown("The stairs that go down", "You went down past forty landings, each one grander than the last, until the stairs ended in an L Corp floor with a red-lacquered door. Behind it, the light.", "The building shifted while you were halfway down, and the stairs went somewhere else. It took you two days to find your way home."),
			{ label = "Keep it to yourself", result = keepQuiet("You put a chair against the door to the stairs and told no one. By the next shift the stairs were gone. You still smell incense, sometimes, when you wake up.") },
		},
	},
	{
		id = "lim_bough_d14",
		title = "Gold Under Butter Street",
		text = "A pothole on Butter Street has been glowing gold for a week, and N Corp's Inquisitors have put a cordon round it and stand guard with their hammers, arguing about whether gold light is impure. At night, people on the street dream of a very large, very calm man waiting at a crossing where the light never changes.",
		weight = 12,
		once = true,
		tags = { "limbus", "bough" },
		when = { world = ERA, minAge = 14, district = "d14" },
		codex = "lim_golden_boughs",
		choices = {
			{ label = "Tell the LCCB scouts", result = tellScouts("The Before Team negotiated with the Inquisitors for three days, using very long words. In the end they got the pothole. You got a finder's fee and an Inquisitor's suspicious look every morning for a year.") },
			goDown("The Inquisitors' cordon", "You slipped through the cordon during the shift change and dropped into the pothole. It opened into an L Corp ventilation duct, and the duct opened into gold.", "A Kleinhammer Inquisitor caught you at the cordon and lectured you about purity for an hour with his hammer in his hand. You went home."),
			{ label = "Keep it to yourself", result = keepQuiet("You stayed away from the cordon. In the dream, the man at the crossing turned and asked if you follow the rules. You woke up before you could answer.") },
		},
	},

	-- ── buried branches and the Mirror ──
	{
		id = "lim_branch_hum",
		title = "The Floor Hums",
		text = "Your floor hums at night. Not loudly: a low, patient note, coming up through the boards from somewhere very far down, where an old L Corp branch was buried when the company fell. Tonight two people in muddy Limbus Company boots knock on your door and ask, politely, if they can listen to your floor.",
		weight = 10,
		once = true,
		tags = { "limbus" },
		when = { world = ERA, minAge = 16 },
		codex = "lcorp_fall",
		choices = {
			{
				label = "Let them listen",
				result = { wage = { 30, 70 }, setFlags = { "lim_lccb_contact" }, codex = "lim_departments", schedule = { event = "lim_lccb_offer", inYears = 1 }, log = "They lay on your floor with their ears to the boards for an hour, took notes, paid you, and left a card. LIMBUS COMPANY, CLEARANCE BEFORE TEAM. PRELIMINARY OBSERVATION. ALWAYS HIRING." },
			},
			{
				label = "Ask to go down with them",
				hint = "Health check.",
				clash = { stat = "health", foe = "A buried L Corp branch", coins = 2, base = 5, coinPower = 3 },
				win = { health = 1, wage = { 60, 140 }, setFlags = { "lim_lccb_contact", "lim_bough_seen" }, codex = "lim_golden_boughs", log = "You went down with them through three levels of dark L Corp corridor. At the bottom was nothing but a faint gold stain on the floor where something had been. \"Already taken,\" one of them said. \"Every time.\"" },
				lose = { health = { -10, -4 }, sanity = -3, cause = "Went down into a buried branch", log = "Two levels down, the floor gave way. The scouts got you out with a rope and a lot of swearing they apologized for. You don't ask to go down anymore." },
			},
			{
				label = "Tell them to go away",
				result = { sanity = 1, log = "You told them to go away. They did, politely. The humming didn't. You bought a thicker rug." },
			},
		},
	},
	{
		id = "lim_mirror_shard",
		title = "Another You",
		text = "A stall in the market sells shards of mirror, each one wrapped in cloth. \"Limbus Company tech,\" says the seller, which it almost certainly isn't. \"Look in it, see another you. The you from another world, who chose different.\" One shard is already unwrapped on the counter, and in it, very faintly, someone with your face is wearing a Fixer's coat.",
		weight = 9,
		once = true,
		tags = { "limbus", "strange" },
		when = { world = ERA, minAge = 14 },
		codex = "lim_mirror",
		choices = {
			{
				label = "Buy a shard and look properly",
				hint = "40 Ahn",
				requires = { min = { money = 40 } },
				result = { money = -40, strength = 3, sanity = -3, condition = "lim_mirror_lag", log = "At home you unwrapped it and looked for an hour. The other you was a Fixer, and good at it, and very tired. Something of the way they stood stayed with you. So did the feeling that your reflection is always slightly behind." },
			},
			{
				label = "Ask the seller where they really came from",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A seller with a story", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, codex = "lim_mirror", log = "Under pressure he admitted they were scrap from a bus that visited the District, swept out of a Limbus Company dumpster. \"Real enough to show you something,\" he said. \"Not real enough to hold it.\"" },
				lose = { money = -15, log = "He talked you into buying a cleaning cloth \"for the shards\". You don't own any shards." },
			},
			{
				label = "Walk away from the other you",
				result = { sanity = 2, log = "You walked away. Whoever that was, they made their choices and you made yours. You liked yours better for not having looked." },
			},
		},
	},
}
