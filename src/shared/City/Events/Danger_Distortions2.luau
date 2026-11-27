--[[
	MORE DISTORTIONS (v0.15, dz2_ ids): after the Light, anyone can Distort: the self bends around
	one feeling until something else stands where they stood. Each of these is one person and
	one feeling, and each can be fought, survived, or sometimes reached. Drawn as light, shadow
	and objects, never flesh. Library era on (the Limbus era too); Peccatula in the Limbus era.
	Fights here are hard, and losing one is often the end.
]]

local DZ = { "danger", "distortion" }
local AFTER = { era = { "library", "limbus" } }

local function dfight(foe: string, enemy: string, status: any?, hard: boolean?)
	return { stat = "strength", foe = foe, enemy = enemy, fight = true, coins = if hard then 4 else 3, base = if hard then 8 else 6, coinPower = if hard then 4 else 3, status = status }
end
local function mindchk(foe: string, hard: boolean?)
	return { stat = "mind", foe = foe, coins = if hard then 4 else 3, base = if hard then 8 else 6, coinPower = 3 }
end

return {
	{
		id = "dz2_queue",
		title = "The Queue",
		text = "There's a queue outside the shuttered ration office that never moves. It's been there a month. The people in it are very patient, and very still, and every morning it's one person longer.",
		weight = 4, cooldown = 10, tags = DZ,
		when = { minAge = 14, world = AFTER },
		choices = {
			{ label = "Find the front of it", clash = mindchk("A queue that wants you in it"), win = { mind = 2, sanity = -4, log = "At the front, a clerk's desk, and behind it something made of numbered tickets, still calling Next. You didn't take a ticket." }, lose = { sanity = -10, health = { -8, -4 }, condition = "night_terrors", log = "You took a ticket without meaning to. It took you three days to step out of line." } },
			{ label = "Pull out the newest one", clash = dfight("What the queue became", "passenger", { id = "sinking", potency = 2 }), win = { strength = 2, sanity = -3, log = "You hauled your neighbour out by the collar. The queue shuffled forward to fill the gap, all of it, at once." }, lose = { health = { -24, -14 }, sanity = -6, cause = "Pulled someone out of a Distortion's queue", log = "The queue doesn't let anyone out of line." } },
			{ label = "Never walk that way again", result = { sanity = -2, log = "You go the long way now. Some mornings you can hear it shuffle one step forward." } },
		},
	},
	{
		id = "dz2_apology",
		title = "The Man Who Apologised",
		text = "A man on your street has been apologising for nine days without stopping. Paper apologies pour from his sleeves, his pockets, his mouth, and drift down the street in a slow white flood. Anyone who reads one starts apologising too.",
		weight = 4, cooldown = 10, tags = DZ,
		when = { minAge = 14, world = AFTER },
		choices = {
			{ label = "Forgive him", clash = mindchk("A guilt as big as a street", true), win = { mind = 3, sanity = -3, setFlags = { "dz_distortion_survivor" }, log = "\"It's all right,\" you said. \"Whatever it was. It's all right.\" The paper stopped. He wept, and was a man, and then wasn't anything." }, lose = { sanity = -14, condition = "night_terrors", log = "You read one of the papers by accident. You apologised to your door for a week." } },
			{ label = "Burn the paper", clash = dfight("A flood of apologies", "binder", { id = "burn", potency = 2 }), win = { strength = 2, sanity = -2, log = "It burned like it had been waiting to. Behind the smoke, something folded itself up very small and went away." }, lose = { health = { -20, -12 }, condition = "burns", cause = "Set fire to a Distortion's flood of paper", log = "The paper burned. So did the street, a little. So did you." } },
			{ label = "Seal your windows", result = { sanity = -4, log = "Tape on every gap. Paper slid under the door anyway, one sheet a night. You never read them." } },
		},
	},
	{
		id = "dz2_tailor",
		title = "The Mirror Tailor",
		text = "A tailor's shop has opened where the old one closed, with suits in the window that move when you do. Customers go in to be measured and come out wearing coats of their own reflections, beautiful and slightly wrong, and then stop looking in mirrors at all.",
		weight = 3, cooldown = 12, tags = DZ,
		when = { minAge = 16, world = AFTER },
		choices = {
			{ label = "Break the mirrors", clash = dfight("The Mirror Tailor", "hollow_armor", { id = "rupture", potency = 2 }, true), win = { strength = 3, sanity = -4, setFlags = { "dz_distortion_survivor" }, log = "Every mirror in the shop broke at once. The coats on the customers' backs went to glass dust, and they all started crying with relief." }, lose = { health = { -30, -18 }, sanity = -6, cause = "Fought the Mirror Tailor", log = "It took your measurements with a hundred hands." } },
			{ label = "Let it measure you, and look away", clash = mindchk("A tape measure that sees you", true), win = { mind = 3, charisma = 1, log = "You never once looked in a mirror while it worked. The coat it gave you is just a coat. It sulked." }, lose = { sanity = -12, log = "You looked. The coat fits. You don't like how much you like it." } },
			{ label = "Warn the street", result = { charisma = 1, sanity = -2, log = "You stood outside and told everyone. Some listened. Some went in anyway, to see." } },
		},
	},
	{
		id = "dz2_keys",
		title = "Ninety-Nine Keys",
		text = "Your landlord has Distorted. You know because every lock in the building turns by itself at night, and in the morning everything you own has been moved one inch, carefully, so you'll know he was there. He's coming up the stairs now, jingling.",
		weight = 4, cooldown = 12, tags = DZ,
		when = { minAge = 16, world = AFTER },
		choices = {
			{ label = "Hold your door", clash = dfight("The Landlord of Ninety-Nine Keys", "doorkeeper", { id = "tremor", potency = 2 }, true), win = { strength = 3, sanity = -4, setFlags = { "dz_distortion_survivor" }, log = "You held the door until every key on his ring had broken in your lock. He sat down on the landing and became a pile of keys." }, lose = { health = { -32, -20 }, sanity = -6, cause = "Held a door against a Distorted landlord", log = "He had a key for you, too." } },
			{ label = "Pay the rent", requires = { min = { money = 100 } }, result = { money = -100, sanity = -3, log = "You slid it under the door. The jingling stopped. In the morning your things were back where you'd left them, which was worse." } },
			{ label = "Change the locks and move out", result = { money = -150, sanity = -2, log = "New flat, new street. The first night, one key turned in your new lock, very gently, and stopped." } },
		},
	},
	{
		id = "dz2_candles",
		title = "The Candle Widow",
		text = "An old woman on your block lights a candle for every person she's lost. Since the Light, she hasn't stopped. There are thousands now, and each one burns a memory from whoever walks past, to keep it warm.",
		weight = 3, cooldown = 12, tags = DZ,
		when = { minAge = 14, world = AFTER },
		choices = {
			{ label = "Light one for her", clash = mindchk("A grief that wants company"), win = { mind = 2, sanity = 2, log = "You lit one for her brother, and sat with her. The candles went out one by one, gently, until there was only a woman crying in an ordinary room." }, lose = { sanity = -10, condition = "grief", log = "You lit one, and it took your mother's face from you. You've got it back, mostly. Not her voice." } },
			{ label = "Put them out", clash = dfight("A room full of candles", "streetlight_eater", { id = "burn", potency = 2 }), win = { strength = 2, sanity = -4, log = "Breath by breath, wick by wick. At the last one, something with a hundred small flames for eyes looked at you, and went out too." }, lose = { health = { -20, -12 }, condition = "burns", cause = "Put out the Candle Widow's candles", log = "The candles did not want to go out." } },
			{ label = "Walk past quickly", result = { sanity = -3, log = "You walked past, eyes down. You can't remember now what you had for breakfast on your seventh birthday. You used to." } },
		},
	},
	{
		id = "dz2_choir",
		title = "The Glass Choir",
		text = "A choir rehearses in the hall on your street, and has for twenty years. Since the Light, they sing so beautifully that windows crack, then cups, then hearts. They're very proud. They're performing tonight.",
		weight = 3, cooldown = 12, tags = DZ,
		when = { minAge = 14, world = AFTER },
		choices = {
			{ label = "Stop the concert", clash = dfight("The Glass Choir", "watcher", { id = "tremor", potency = 3 }, true), win = { strength = 3, sanity = -4, setFlags = { "dz_distortion_survivor" }, log = "You smashed the conductor's stand on the final note. The choir stopped mid-breath, and shattered, all together, like one glass." }, lose = { health = { -28, -16 }, condition = "ringing", cause = "Stopped the Glass Choir mid-song", log = "The high note found you." } },
			{ label = "Sing back, badly", clash = mindchk("Twenty years of pride", true), win = { mind = 3, charisma = 1, log = "You sang loud and wrong. They faltered. Pride can't stand a bad note. They stopped to correct you, and forgot to start again." }, lose = { sanity = -10, condition = "ringing", log = "They sang you down. Your ears haven't been right since." } },
			{ label = "Stuff the street's ears with wax", result = { charisma = 1, sanity = -2, money = -30, log = "Wax for everyone on the street. The windows cracked all night. Nobody heard a thing." } },
		},
	},
	{
		id = "dz2_ledger",
		title = "The Collector's Ledger",
		text = "A Syndicate debt collector Distorted over his own ledger. Now he is the ledger, a walking book of debts with long arms, and he is collecting from everyone in it. Your name is on page forty, for a loan you paid back.",
		weight = 4, cooldown = 12, tags = DZ,
		when = { minAge = 18, side = "backstreets", world = AFTER },
		choices = {
			{ label = "Fight the ledger", clash = dfight("The Collector's Ledger", "binder", { id = "rupture", potency = 2 }, true), win = { strength = 3, money = 120, sanity = -3, setFlags = { "dz_distortion_survivor" }, log = "You tore out page forty, then every other page. Ahn spilled out of the spine like seeds. Everyone on the street got back what they'd paid." }, lose = { health = { -30, -18 }, cause = "Collected by a Distorted ledger", log = "It collected. With interest." } },
			{ label = "Show your receipt", clash = { stat = "intelligence", foe = "A ledger that never closes", coins = 3, base = 6, coinPower = 3 }, win = { intelligence = 2, log = "You held up the receipt. It read it for a long time, then crossed out your line, very neatly, and walked on." }, lose = { money = -80, health = { -10, -5 }, log = "It didn't recognise the receipt. It recognised your money." } },
			{ label = "Pay it again", requires = { min = { money = 80 } }, result = { money = -80, sanity = -3, log = "You paid a debt twice. It thanked you in a voice like a page turning." } },
		},
	},
	{
		id = "dz2_rust_garden",
		title = "The Rust Garden",
		text = "The old man who kept the roof garden has stopped coming down. Now the garden is coming down instead: iron flowers growing out of the gutters and down the walls, rooting into anything that stays still too long. The cat next door stayed still.",
		weight = 3, cooldown = 12, tags = DZ,
		when = { minAge = 14, world = AFTER },
		choices = {
			{ label = "Climb to the roof", clash = dfight("The gardener in the iron", "branches", { id = "bleed", potency = 2 }, true), win = { strength = 3, sanity = -4, setFlags = { "dz_distortion_survivor" }, log = "You found him at the heart of it, mostly flowers now. You kept moving. When you cut the last root, the whole garden rusted to powder in the wind." }, lose = { health = { -30, -18 }, cause = "Climbed into the Rust Garden", log = "You stopped, once, to catch your breath." } },
			{ label = "Keep everyone moving", clash = { stat = "speed", foe = "A garden that waits", coins = 3, base = 6, coinPower = 3 }, win = { speed = 2, charisma = 1, log = "You went door to door at a run: don't sit, don't sleep in the stairwell, keep walking. Everyone lived. It took a week." }, lose = { health = { -12, -6 }, log = "You sat down for one minute. It took a Fixer an hour to cut you free." } },
			{ label = "Sell the iron flowers", result = { money = 90, sanity = -4, log = "A Workshop paid well for them. You don't ask what they made." } },
		},
	},
	{
		id = "dz2_shadow",
		title = "The Long Shadow",
		text = "A man runs past you at dusk, terrified, with no shadow at all. Behind him, his shadow comes up the street on its own, long and thin and hungry, looking for someone else to be attached to.",
		weight = 4, cooldown = 10, tags = DZ,
		when = { minAge = 14, world = AFTER },
		choices = {
			{ label = "Stand in the light", clash = mindchk("A shadow that wants a person"), win = { mind = 2, sanity = -3, log = "Under the streetlamp, nowhere for a shadow to get in. It circled you all night, and at dawn it was gone, and so was the man." }, lose = { sanity = -10, condition = "distortion_signs", log = "It touched your own shadow. For a year yours moved a half-second late." } },
			{ label = "Fight it", clash = dfight("A shadow without a man", "night_stalker", { id = "sinking", potency = 2 }), win = { strength = 2, sanity = -4, log = "You tore it off the wall like old wallpaper. It went to nothing in your hands." }, lose = { health = { -22, -12 }, sanity = -6, cause = "Fought a shadow that had left its man", log = "You can't punch a shadow. It can do other things." } },
			{ label = "Take the man in", result = { charisma = 1, sanity = -3, log = "He slept on your floor, by the lamp, which you left on. In the morning he had a shadow again. It wasn't quite his." } },
		},
	},
	{
		id = "dz2_stall",
		title = "The Noodle Stall That Never Closes",
		text = "The noodle seller on the corner is feeding the whole street, for free, all night. Nobody who eats leaves. Forty people sit at a stall built for six, and the bowls keep coming, and the seller keeps smiling with too many teeth.",
		weight = 3, cooldown = 12, tags = DZ,
		when = { minAge = 14, world = AFTER },
		choices = {
			{ label = "Get the diners away", clash = { stat = "charisma", foe = "A kindness that won't stop", coins = 3, base = 6, coinPower = 3 }, win = { charisma = 2, sanity = -2, log = "One at a time, gently: your mother's waiting, your shift starts soon. When the last stool was empty, the stall folded itself up and was gone." }, lose = { sanity = -8, health = { -6, -3 }, log = "Somebody handed you a bowl. You came to two days later, very full and very frightened." } },
			{ label = "Kick the stall over", clash = dfight("The seller with too many teeth", "distortion", { id = "rupture", potency = 2 }), win = { strength = 2, sanity = -4, setFlags = { "dz_distortion_survivor" }, log = "The pots went over, and the seller went with them, into the steam, and the steam into the drain." }, lose = { health = { -24, -14 }, cause = "Kicked over a Distortion's noodle stall", log = "It was very upset about the pots." } },
			{ label = "Eat, carefully", clash = mindchk("One more bowl", true), win = { mind = 3, log = "One bowl, and you stood up. It looked so hurt. You'll never eat noodles that good again." }, lose = { die = "Ate at the noodle stall that never closes, and stayed", log = "One more bowl. Just one more. The stall is still there, some nights, and you're on a stool." } },
		},
	},
	{
		id = "dz2_cranes",
		title = "A Thousand Cranes",
		text = "A girl's grandfather folded a paper crane for every wish he never got. When he Distorted, he became them: a flock of a thousand paper cranes that cuts the air like razors, circling the block, looking for wishes to keep.",
		weight = 3, cooldown = 12, tags = DZ,
		when = { minAge = 16, world = AFTER },
		choices = {
			{ label = "Make a wish for him", clash = mindchk("A thousand unmade wishes", true), win = { mind = 3, sanity = 2, log = "You wished he'd rest. The flock landed, all at once, in the street, and was only paper." }, lose = { health = { -16, -8 }, sanity = -8, condition = "deep_cut", log = "The flock wanted a different wish." } },
			{ label = "Fight the flock", clash = dfight("A thousand paper cranes", "crow", { id = "bleed", potency = 3 }, true), win = { strength = 3, speed = 1, sanity = -3, setFlags = { "dz_distortion_survivor" }, log = "You burned them a hundred at a time. The last crane landed on your hand, and stayed folded." }, lose = { health = { -30, -18 }, condition = "deep_cut", cause = "Cut down by a flock of paper cranes", log = "Paper is sharper than it looks, a thousand times over." } },
			{ label = "Shelter the street indoors", result = { charisma = 1, sanity = -3, log = "Everyone in, shutters down. The cranes circled for three days and then flew west, toward somebody else's wishes." } },
		},
	},
	{
		id = "dz2_rain",
		title = "Rain Indoors",
		text = "It's raining inside the tenement across the road. Only inside: the windows stream, the stairs run, and the tenants stand in the downpour staring at the ceiling, waiting for it to stop. On the top floor someone is crying, and has been, since the Light.",
		weight = 3, cooldown = 12, tags = DZ,
		when = { minAge = 14, world = AFTER },
		choices = {
			{ label = "Climb to the top floor", clash = mindchk("A sorrow that fills a building", true), win = { mind = 3, sanity = -2, setFlags = { "dz_distortion_survivor" }, log = "You sat beside it in the flood and didn't say anything at all. After a long time the rain thinned, and stopped, and there was only an empty room, and sun." }, lose = { sanity = -14, health = { -10, -5 }, cause = "Climbed into the rain indoors", log = "You stood in the rain on the top floor for a day, waiting for it to stop. It didn't." } },
			{ label = "Carry the tenants out", clash = { stat = "strength", foe = "Stairs like a waterfall", coins = 3, base = 6, coinPower = 3 }, win = { strength = 2, charisma = 1, log = "Eleven people, one at a time, down six flights of rain. Outside, in the dry, every one of them burst into tears." }, lose = { health = { -16, -8 }, condition = "fever", log = "The stairs threw you down a flight. You got four out." } },
			{ label = "Call an Office", requires = { min = { money = 150 } }, result = { money = -150, rep = { fixers = 2 }, log = "The Office went in with umbrellas, which you thought was a joke. It wasn't. It was over by evening." } },
		},
	},
	{
		id = "dz2_echo_stairs",
		title = "The Echo in the Stairwell",
		text = "Say anything in the stairwell of your building and it says it back, a little later, a little changed. Say \"goodnight\" and it says \"good riddance\". Say a name, and it says the name of someone who's dead. Tonight it's started answering before you speak.",
		weight = 4, cooldown = 10, tags = DZ,
		when = { minAge = 12, world = AFTER },
		choices = {
			{ label = "Say nothing at all", clash = mindchk("Silence it can't use"), win = { mind = 2, log = "A week of silence on the stairs, the whole building, by agreement. It starved. The stairs are only stairs." }, lose = { sanity = -8, log = "You said \"shh\". It said it back, for a month, in your mother's voice." } },
			{ label = "Argue with it", clash = { stat = "intelligence", foe = "Your own voice, changed", coins = 3, base = 6, coinPower = 3 }, win = { intelligence = 2, sanity = -2, log = "You said things it couldn't twist: numbers, the alphabet, the price of rice. It gave up, sulking." }, lose = { sanity = -10, condition = "night_terrors", log = "It won the argument. It always would have. It had better material." } },
			{ label = "Take the fire escape", result = { speed = 1, sanity = -2, log = "Six floors of fire escape, twice a day, all winter. It talks to itself on the stairs now." } },
		},
	},
	{
		id = "dz2_peccatula",
		title = "Peccatula in the Market",
		text = "A swarm of Peccatula has come up from somewhere under the market: small, quick, wrong things, each one the size of a cat and the shape of a bad feeling. They're stripping the stalls, and the stallholders.",
		weight = 4, cooldown = 10, tags = DZ,
		when = { minAge = 14, world = { era = "limbus" } },
		choices = {
			{ label = "Fight them off the stalls", clash = dfight("A swarm of Peccatula", "peccatula", { id = "rupture", potency = 2 }, true), win = { strength = 3, wage = { 60, 140 }, sanity = -3, log = "Stall by stall, you drove them back down the drain. The stallholders paid you in whatever wasn't eaten." }, lose = { health = { -28, -16 }, cause = "Swarmed by Peccatula in the market", log = "There were more of them than there were of you, by a lot." } },
			{ label = "Get the stallholders out", clash = { stat = "speed", foe = "Peccatula, quick and many", coins = 3, base = 6, coinPower = 3 }, win = { speed = 2, charisma = 1, log = "You got everyone onto the roofs. The Peccatula ate the market and left, bloated and slow." }, lose = { health = { -16, -8 }, log = "You got most of them out. One followed you up the ladder." } },
			{ label = "Block the drain", clash = { stat = "intelligence", foe = "Where they're coming from", coins = 3, base = 6, coinPower = 3 }, win = { intelligence = 2, log = "A cart, a manhole cover, three sacks of sand. Nothing more came up. What was already up, you left to the Fixers." }, lose = { health = { -12, -6 }, log = "Wrong drain." } },
		},
	},
}
