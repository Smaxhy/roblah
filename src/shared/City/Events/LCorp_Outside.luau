--[[
	L Corp from the outside, and after: lives that brush against Lobotomy Corporation
	without working there, cards that roll during the abnormality_breach world event, the
	"remnants" (ex-employees after the fall), and Abnormalities loose in the ruins.
	  The Green Kettle: a teahouse in District 12 where L Corp staff drink tea after shifts,
	  and, after the fall, where the remnants meet. It turns up across this pack.
	CANON 9.1 and 9.2 hooks: hiring season (a sibling), the green market, remnant meetings,
	inherited E.G.O, the lonely pebble, the red shoes, the fairy picnic, the Plague Doctor's
	blessing, the scales of judgment.
]]

local RUINS = { "library", "limbus" }
local EGO = { "lc_ego_penitence", "lc_ego_lament", "lc_ego_justitia", "lc_ego_lamp" }

return {
	-- ── growing up under the green tower ──
	{
		id = "lc_tower_glow",
		title = "The Green Tower",
		text = "From the roof of your building you can see the Lobotomy Corporation tower, lit green from top to bottom, humming. The older kids on your street have a dare: run up to the fence around the facility, touch it, and run back before a guard sees you. They say the fence is warm. They say you can hear something breathing on the other side.",
		weight = 22,
		once = true,
		tags = { "lcorp" },
		when = { district = "d12", minAge = 7, maxAge = 15, world = { era = "wings" } },
		codex = "lcorp_abnormalities",
		choices = {
			{
				label = "Take the dare",
				hint = "A Strength check: run fast.",
				clash = { stat = "strength", foe = "A guard with a whistle", coins = 1, base = 3, coinPower = 2 },
				win = { strength = 2, sanity = 2, log = "You touched the fence. It was warm. You were back on your street before the whistle finished, and the older kids looked at you differently for a whole summer." },
				lose = { sanity = -2, log = "The guard caught you by the collar, sighed, and walked you home. He told your family, very kindly, that the fence is there for a reason." },
			},
			{
				label = "Count the lights on the tower instead",
				result = { mind = 2, log = "You counted every light, every night, for a month. Some nights, a few floors near the bottom went dark all at once, and then came back. You never told anyone you'd noticed." },
			},
			{
				label = "Ask an adult what's inside",
				result = { intelligence = 1, sanity = -1, log = "\"Energy,\" said the woman at the noodle stall, and nothing else. \"Don't go near the fence.\" Everyone you asked said exactly the same thing, in exactly the same voice." },
			},
		},
	},
	{
		id = "lc_green_market",
		title = "The Green Market",
		text = "A stall at the night market is selling power cells with the Lobotomy Corporation logo half scraped off, glowing a soft green inside their glass. \"Off-brand Enkephalin,\" the stallholder says. \"Runs a lamp for a year. Runs a heater for a winter. Don't ask where they're from.\" A woman in a gray coat at the next stall is watching very carefully.",
		weight = 12,
		cooldown = 6,
		tags = { "lcorp" },
		when = { minAge = 14, world = { era = "wings" }, notFlags = { "lcorp_employee" } },
		choices = {
			{
				label = "Buy one for your lamp",
				hint = "15 Ahn.",
				requires = { min = { money = 15 } },
				result = { money = -15, sanity = 2, log = "You ran your lamp off it all year. Your room glowed a soft green every night, and you slept better than you had in years, and you tried not to wonder why." },
			},
			{
				label = "Warn the stallholder about the woman in gray",
				result = { sanity = 1, intelligence = 1, log = "You said it quietly. He looked once, swept the cells into a sack and was gone in thirty seconds. The woman in gray sighed and walked over to ask you a few polite questions." },
			},
			{
				label = "Point the woman in gray at the stall",
				result = { money = 25, sanity = -2, log = "She thanked you and gave you twenty-five Ahn from a company envelope. L Corp's retrieval officers had the stall packed up in five minutes. The stallholder looked at you as they led him away." },
			},
		},
	},
	{
		id = "lc_sibling_hired",
		title = "Hiring Season",
		text = "{sibling} has a job at Lobotomy Corporation. They come home with a badge on a green lanyard and a pay slip that makes everyone at the table go quiet, and they won't say what the job is. \"Safety rules,\" they say, grinning. \"Very strict ones.\" They want you to be happy for them.",
		weight = 24,
		once = true,
		tags = { "lcorp" },
		when = { district = "d12", minAge = 12, hasRelation = "sibling", world = { era = "wings" }, notFlags = { "lcorp_employee" } },
		choices = {
			{
				label = "Be happy for them",
				result = { sanity = 2, relationBond = { kind = "sibling", amount = 8 }, setFlags = { "lc_sibling_agent" }, schedule = { event = "lc_sibling_stranger", inYears = 2 }, log = "You hugged {sibling} and helped them pick a good lunchbox. They left before dawn every day after that, and came home after dark." },
			},
			{
				label = "Beg them not to take it",
				result = { sanity = -1, relationBond = { kind = "sibling", amount = -4 }, setFlags = { "lc_sibling_agent" }, schedule = { event = "lc_sibling_stranger", inYears = 2 }, log = "You begged. They laughed, then stopped laughing, then took it anyway. \"Someone has to keep the lights on,\" they said." },
			},
		},
	},
	{
		id = "lc_sibling_stranger",
		title = "{sibling} Comes Home Strange",
		text = "{sibling} has been at L Corp two years now. They flinch at birds. They won't eat apples, and they won't say why. They check the locks four times instead of twice, and sometimes at dinner they stop mid-sentence and stare at nothing, listening. Last week they asked if you'd ever heard a star sing.",
		weight = 0,
		when = { hasRelation = "sibling", flags = { "lc_sibling_agent" }, world = { era = "wings" } },
		choices = {
			{
				label = "Ask them what happens in there",
				hint = "A Mental Strength check: gently.",
				clash = { stat = "mind", foe = "A wall your sibling built", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -2, relationBond = { kind = "sibling", amount = 10 }, codex = "lcorp_work_types", schedule = { event = "lc_sibling_armband", inYears = 2 }, log = "They told you, a little. Four kinds of work. Things in rooms that like some kinds and hate others. They cried, once, and made you promise never to apply. You promised." },
				lose = { sanity = -2, relationBond = { kind = "sibling", amount = -3 }, schedule = { event = "lc_sibling_armband", inYears = 2 }, log = "\"Safety rules,\" they said, and went to bed early." },
			},
			{
				label = "Take them out for noodles and talk about anything else",
				result = { sanity = 3, relationBond = { kind = "sibling", amount = 8 }, schedule = { event = "lc_sibling_armband", inYears = 2 }, log = "You talked about everything except the job: the old neighborhood, a terrible film, a cat you both remembered. For two hours they looked like themselves." },
			},
		},
	},
	{
		id = "lc_sibling_armband",
		title = "The Armband",
		text = "{sibling} comes home with a new armband: Department Captain, the longest-serving Agent in their department. Everyone at the table cheers. {sibling} smiles, and keeps smiling, and goes to bed early. After that they stop talking about work altogether. They stop talking much at all.",
		weight = 0,
		when = { hasRelation = "sibling", flags = { "lc_sibling_agent" }, world = { era = "wings" } },
		choices = {
			{
				label = "Sit up with them that night",
				result = { sanity = 1, relationBond = { kind = "sibling", amount = 12 }, log = "You sat up with {sibling} in the dark until three, saying nothing. Before the Night came, they said, \"Everyone in my department is younger than me now. Everyone.\" Then they slept." },
			},
			{
				label = "Throw them a party anyway",
				result = { sanity = 2, relationBond = { kind = "family", amount = 5 }, log = "You threw the party. {sibling} came, and was kind to everyone, and left early. They kept the armband in a drawer and never wore it home again." },
			},
		},
	},
	{
		id = "lc_doctor_stranger",
		title = "A Stranger in a Beaked Mask",
		text = "A very tall figure in a black hat and a beaked mask stops you in the street, great black wings folded where its arms should be. \"Forgive me,\" it says, politely. \"I am looking for the tower. The world has caught a terrible disease, and I am told the people there might let me cure it.\" It studies you. \"You look unwell. I could bless you, if you like.\"",
		weight = 8,
		once = true,
		tags = { "lcorp" },
		when = { district = "d12", minAge = 10, world = { era = "wings" } },
		codex = "lc_abno_plague_doctor",
		choices = {
			{
				label = "Accept the blessing",
				result = { health = { 4, 8 }, sanity = 4, condition = "lc_blessed", setFlags = { "lc_met_doctor" }, log = "It touched your shoulder with one wing. Every ache you had went away. \"There,\" it said. \"Blessed.\" It walked off toward the tower, and you heard it say a number under its breath: \"One.\"" },
			},
			{
				label = "Point the way to the tower",
				result = { mind = 1, setFlags = { "lc_doctor_directions" }, log = "You pointed it toward the L Corp gate. It bowed, very low, and walked away down the middle of the street. Years later you'd read that a certain Abnormality had walked into the facility on its own, and you'd remember." },
			},
			{
				label = "Shut your door",
				result = { sanity = -1, log = "You shut your door and waited until its footsteps were gone. On the step in the morning, there was a single black feather. You didn't touch it." },
			},
		},
	},
	{
		id = "lc_doctor_bright",
		title = "Something Very Bright",
		text = "The White Nights. In the middle of the light that fills the City, you see a shape you remember from your childhood: very tall, with great wings, but brighter now, much brighter, with twelve figures in beaked masks behind it. It turns its head toward you across a whole District. You hear it, clear as a bell: \"One.\"",
		weight = 120,
		once = true,
		tags = { "lcorp" },
		when = { flags = { "lc_met_doctor" }, world = { era = { "white_nights", "library" } } },
		codex = "lc_abno_whitenight",
		choices = {
			{
				label = "Raise a hand back",
				result = { sanity = 6, addTrait = "light_touched", setFlags = { "saw_abnormality" }, log = "You raised your hand. It seemed pleased, the way a doctor is pleased with a patient who has done well. Then the light took it, and the shape was gone, and you felt the blessing settle into you for good." },
			},
			{
				label = "Look away",
				result = { sanity = -2, mind = 2, setFlags = { "saw_abnormality" }, log = "You looked away, and when you looked back it was gone. You've wondered ever since what would have happened if you'd held its gaze." },
			},
		},
	},

	-- ── while the breach sirens are going (world event abnormality_breach) ──
	{
		id = "lc_breach_basement",
		title = "The Basement Shelter",
		text = "The sirens from District 12 are still going. Your building's basement is the only shelter on the street, and forty neighbors are packed into it in the dark: children, a man with a birdcage, the noodle-stall woman with her pot. Something big just walked past overhead. Somebody starts to cry, and somebody else starts shouting at them to be quiet.",
		weight = 30,
		cooldown = 3,
		tags = { "breach" },
		when = { worldEvent = "abnormality_breach", minAge = 10, world = { era = "wings" } },
		choices = {
			{
				label = "Keep everyone calm",
				hint = "A Mental Strength check: forty frightened people in the dark.",
				clash = { stat = "mind", foe = "Forty frightened people", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 3, setFlags = { "lc_breach_survivor" }, log = "You got everyone sitting down, children in the middle, and talked low about nothing until the sirens stopped. The noodle-stall woman gave you a free bowl every week for a year." },
				lose = { sanity = -4, setFlags = { "lc_breach_survivor" }, log = "The shouting got worse until a little boy started screaming, and you all sat through the rest of it with your hands over your ears." },
			},
			{
				label = "Hold the basement door",
				hint = "A Health check.",
				clash = { stat = "health", foe = "Whatever is pushing on the door", coins = 2, base = 4, coinPower = 3 },
				win = { health = 2, sanity = 2, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "Something pushed on the door, once. You pushed back with three neighbors behind you. It went away. You never found out what it was." },
				lose = { health = { -8, -4 }, sanity = -3, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "It pushed harder than you could. The door held anyway, barely. Your shoulder didn't.", cause = "Holding a door against a breach" },
			},
			{
				label = "Sit in the corner and wait",
				result = { sanity = { -3, -1 }, setFlags = { "lc_breach_survivor" }, log = "You sat in the corner with your knees up and waited. It was the right thing to do. It was the longest hour of your life." },
			},
		},
	},
	{
		id = "lc_breach_agent_door",
		title = "An Agent at the Door",
		text = "Someone is pounding on your door: an L Corp Agent in a torn black suit, holding up a Clerk who can barely stand. \"Please,\" the Agent says. \"Ten minutes. It's two streets back and it's following the noise.\" Behind them, at the end of the street, the streetlights are going out one by one.",
		weight = 24,
		cooldown = 4,
		tags = { "breach" },
		when = { worldEvent = "abnormality_breach", minAge = 14, world = { era = "wings" }, notFlags = { "lcorp_employee" } },
		choices = {
			{
				label = "Let them in and bar the door",
				result = { sanity = 3, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You pulled them in and barred the door, and the three of you sat in the dark while something went past outside, slowly, sniffing. The Agent left you her card. \"If you ever need a job,\" she said. \"Or don't. Better if you don't.\"" },
			},
			{
				label = "Point them to the shelter two doors down",
				result = { sanity = -2, log = "You pointed. They ran. You heard the shelter door slam, and then the street went dark, and you sat behind your own door and listened." },
			},
			{
				label = "Go out and lead it away from them",
				hint = "A real fight. You have no idea what it is.",
				clash = { stat = "strength", foe = "Something from the vaults", coins = 3, base = 5, coinPower = 3, fight = true, status = "sinking" },
				win = { strength = 3, sanity = -2, setFlags = { "lc_breach_survivor", "saw_abnormality" }, chronicle = "fought_abnormality", log = "You banged a pot lid and ran, and it followed you for three streets until a suppression team cut it off. You couldn't describe it to them. They didn't ask you to." },
				lose = { health = { -14, -7 }, sanity = -6, setFlags = { "lc_breach_survivor", "saw_abnormality" }, condition = "lc_shaken", log = "It followed you. It caught you. The suppression team found you an hour later, alive, which they said was unusual.", cause = "Led a breach away from a stranger's door" },
			},
		},
	},

	-- ── after the fall: the remnants ──
	{
		id = "lc_remnant_tea",
		title = "The Remnants",
		text = "Every Thursday, the former employees of Lobotomy Corporation meet at the Green Kettle. Clerks, Agents, a researcher or two, a Captain who still wears the armband. They drink tea and swap news of who's still alive. The owner keeps a shelf of old L Corp safety manuals behind the counter, and scavengers keep offering to buy them.",
		weight = 22,
		once = true,
		tags = { "lcorp" },
		when = { flags = { "lcorp_employee" }, world = { era = RUINS } },
		choices = {
			{
				label = "Go every Thursday",
				result = { sanity = 4, setFlags = { "lc_remnant" }, log = "You went every Thursday after that. Somebody always brought news, and somebody always knew a name on it. It helped, more than you'd have guessed." },
			},
			{
				label = "Help keep the manuals out of the wrong hands",
				result = { sanity = 2, setFlags = { "lc_remnant" }, quest = "lc_q_manuals", log = "You told the owner you'd help. \"Some of the old branches are still sealed,\" she said, \"with manuals in them. People are going down there without them.\"" },
			},
			{
				label = "Stay away. That part of your life is over",
				result = { sanity = 1, mind = 1, log = "You never went. Sometimes you walk past the Green Kettle on a Thursday and hear laughter through the window, and you keep walking." },
			},
		},
	},
	{
		id = "lc_remnant_mirela",
		title = "Mirela at the Green Kettle",
		text = "Someone at the Green Kettle shouts your name across the room and waves a notebook full of drawings over her head. It's Mirela Dragan, who sat beside you at orientation a lifetime ago. She's older, with a limp and a new scar, and exactly as loud. \"You made it!\" she says. \"I knew you would. You always did the fairies last.\"",
		weight = 40,
		once = true,
		tags = { "lcorp" },
		when = { flags = { "lc_mirela_saved" }, notFlags = { "lc_mirela_lost" }, world = { era = RUINS } },
		choices = {
			{
				label = "Sit down and catch up",
				result = { sanity = 5, addRelation = { kind = "friend", name = "Mirela Dragan", bond = 75, age = { 26, 45 } }, log = "You talked until closing: who made it, who didn't, which Abnormalities you'd outlived. She still knows more trivia than anyone alive. You promised to meet every week, and you have." },
			},
			{
				label = "Ask about the people who didn't make it",
				result = { sanity = -1, mind = 2, addRelation = { kind = "friend", name = "Mirela Dragan", bond = 65, age = { 26, 45 } }, log = "She knew every name, and told you about each one, and you drank a cup of tea for every one of them. It was a long night. It was a good one." },
			},
		},
	},
	{
		id = "lc_remnant_limbus",
		title = "Limbus Company Wants You",
		text = "A man in a neat Limbus Company uniform finds you at the Green Kettle. His company is hiring people who know the inside of an L Corp branch: what the units looked like, how the doors worked, which Abnormalities liked which work. \"You'd be surprised,\" he says, \"how much of it is still down there.\"",
		weight = 24,
		once = true,
		tags = { "lcorp" },
		when = { flags = { "lcorp_employee" }, minAge = 24, maxAge = 60, world = { era = "limbus" } },
		codex = "limbus_company",
		choices = {
			{
				label = "Sign on with their Clearance Before Team",
				hint = "Scouting buried L Corp branches.",
				result = { career = "limbus_lccb", sanity = -2, log = "You signed on. Your first week, they sent you down into a sealed branch with a lamp and a map you'd have drawn better yourself. You knew the way. It felt like going home, and like going back into a unit." },
			},
			{
				label = "Ask about their research department",
				hint = "Needs Intelligence 38.",
				requires = { min = { intelligence = 38 } },
				result = { career = "limbus_lce", log = "Their research department, the LCE, took you on within a week. The labs looked so much like the old ones that you stopped in the doorway on your first morning." },
			},
			{
				label = "Turn him down",
				result = { sanity = 2, log = "\"I've been down there,\" you said. \"Once was enough.\" He left his card anyway. Everyone does." },
			},
		},
	},
	{
		id = "lc_remnant_dreams",
		title = "The Unit in Your Sleep",
		text = "Years after the fall, you still dream about the facility. Always the same corridor, the same door, the board outside with your name on it beside a unit you never worked. In the dream you always know which work it wants. Last night, for the first time, you opened the door.",
		weight = 14,
		cooldown = 8,
		tags = { "lcorp" },
		when = { flags = { "lc_was_agent" }, world = { era = RUINS } },
		choices = {
			{
				label = "Tell someone at the Green Kettle",
				result = { sanity = 4, log = "Half the table had the same dream. The other half had a different door. You laughed about it, which turned out to be the best thing you could have done." },
			},
			{
				label = "Write down which work it wanted",
				result = { mind = 2, sanity = -1, log = "You wrote it down: Attachment. You don't know why you're sure. You put the note in the drawer with your old badge." },
			},
			{
				label = "Go somewhere quiet and let it pass",
				result = { sanity = 2, log = "You sat on the roof until the dream wore off, and watched the City wake up, which it still does, every day, Light or no Light." },
			},
		},
	},
	{
		id = "lc_pebble_warm",
		title = "The Pebble Is Warm",
		text = "You've kept the pebble from the Child of the Galaxy all these years, through the fall and everything after. It went cold the day the facility sealed. This morning, holding it, you feel it: warm again, faintly, the way it was the day he gave it to you. Somewhere out there, he must still be keeping his end of the promise.",
		weight = 40,
		once = true,
		tags = { "lcorp" },
		when = { flags = { "lc_galaxy_friend" }, world = { era = RUINS } },
		codex = "lc_abno_galaxy",
		choices = {
			{
				label = "Keep it close",
				result = { sanity = 6, health = 4, log = "You put it on a cord around your neck. It's been warm ever since. On bad days, it's a little warmer." },
			},
			{
				label = "Go looking for him in the ruins",
				hint = "A Mental Strength check. District 12's ruins aren't safe.",
				clash = { stat = "mind", foe = "The ruins of District 12", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 8, setFlags = { "saw_abnormality" }, log = "You followed the warmth into the ruins until, at the edge of a collapsed stairwell, you saw a small barefoot figure against the dark, waving. Then it was gone. The pebble was very warm all the way home." },
				lose = { health = { -8, -4 }, sanity = -2, log = "The ruins were bigger than you remembered and full of things that weren't him. You came home cut and tired. The pebble was still warm. That was something." },
			},
		},
	},
	{
		id = "lc_ego_voice",
		title = "The E.G.O Has Opinions",
		text = "The E.G.O gear you carry has been in the family for a while now, and lately it's become clear that it has a personality of its own. You catch yourself using phrases you never used, standing the way someone else stood. At dinner, you said something about the weight of sins, and everybody stared.",
		weight = 16,
		once = true,
		tags = { "lcorp" },
		when = { hasGear = EGO, minAge = 14 },
		codex = "lc_lore_ego_gear",
		choices = {
			{
				label = "Listen to it for a while",
				result = { mind = 2, sanity = -2, log = "You let it talk, in a way, for a month. It knows things about its Abnormality nobody wrote down. You've started writing them down." },
			},
			{
				label = "Wrap it up and put it in a box",
				result = { sanity = 3, loseGear = true, log = "You wrapped it in a blanket and put it in a box under the stairs. You sound like yourself again. Some nights you can hear it, very faintly, disapproving." },
			},
			{
				label = "Sell it to a collector",
				result = { money = { 300, 600 }, sanity = 1, loseGear = true, log = "A collector paid you well and wrapped it in silk. As she left, you heard yourself say goodbye to it, out loud, in its own voice." },
			},
		},
	},

	-- ── Abnormalities loose in the ruins ──
	{
		id = "lc_ruins_pebble",
		title = "The Lonely Pebble",
		text = "In the rubble at the edge of the old L Corp grounds, a barefoot boy with enormous eyes and skin like the night sky is sitting on a broken pillar, swinging his legs. He holds out a small, smooth pebble. \"Will you keep this?\" he asks. \"Forever? Then we'll be friends. All my other friends had to go.\"",
		weight = 10,
		once = true,
		tags = { "lcorp", "abnormality" },
		when = { district = { "d12", "d4" }, minAge = 8, world = { era = RUINS } },
		codex = "lc_abno_galaxy",
		choices = {
			{
				label = "Take it and promise",
				result = { sanity = 4, setFlags = { "lc_galaxy_friend", "saw_abnormality" }, log = "It was warm in your hand. \"Forever,\" you said. He smiled so widely that, for a second, you saw stars. When you looked up again, the pillar was empty." },
			},
			{
				label = "Say you can't",
				result = { sanity = -3, setFlags = { "saw_abnormality" }, log = "His face fell. Somewhere very far above, a star went out, or you imagined it did. When you looked again, he was gone, and the rubble was cold." },
			},
		},
	},
	{
		id = "lc_ruins_red_shoes",
		title = "Red Shoes at the Market",
		text = "At a scavengers' market built in the ruins of District 12, a stall is selling things dug out of a sealed L Corp branch: badges, a riot stick, a cracked green cell. And on a velvet cloth at the end, a pair of red shoes, the most beautiful shoes you have ever seen. They're your size. The stallholder won't look at them.",
		weight = 10,
		once = true,
		tags = { "lcorp", "abnormality" },
		when = { district = { "d12", "d4" }, minAge = 12, world = { era = RUINS } },
		codex = "lc_abno_red_shoes",
		choices = {
			{
				label = "Try them on",
				hint = "A Mental Strength check against their pull.",
				clash = { stat = "mind", foe = "The Red Shoes", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = -2, setFlags = { "saw_abnormality" }, log = "You got one on and felt your whole body want to dance, and you tore it off before the other foot could follow. The stallholder covered them with the cloth. \"Thank you,\" she whispered. \"The last one didn't.\"" },
				lose = { health = { -8, -4 }, sanity = -4, condition = "lc_red_shoes_longing", setFlags = { "saw_abnormality" }, log = "You danced until dawn, through the market and out into the ruins and back. Someone cut the laces at sunrise. Your feet have never forgiven you. Neither has your heart." },
			},
			{
				label = "Walk away",
				result = { condition = "lc_red_shoes_longing", log = "You walked away. You walked back twice. The third time, the stall was gone." },
			},
			{
				label = "Tell the stallholder what they are",
				result = { sanity = 2, setFlags = { "saw_abnormality" }, log = "You told her about The Red Shoes. She went pale, wrapped them in three layers of sacking, and swore she'd drop them down the deepest hole in District 12. You hope she did." },
			},
		},
	},
	{
		id = "lc_ruins_fairies",
		title = "The Fairy Picnic",
		text = "In an empty lot near the old branch entrance, tiny winged fairies are having what looks like a picnic among the weeds. They notice you, and swirl up around your head, chattering, and one lands on your shoulder and pats your cheek. They seem to be offering something: protection, maybe. Care.",
		weight = 10,
		once = true,
		tags = { "lcorp", "abnormality" },
		when = { district = { "d12", "d4" }, minAge = 8, world = { era = RUINS } },
		codex = "lc_abno_fairy_festival",
		choices = {
			{
				label = "Accept their care",
				result = { health = 4, sanity = 2, condition = "lc_fairy_care", setFlags = { "saw_abnormality" }, log = "They hummed around you all the way home, and your bruises faded overnight. They're still around. You've learned never to go anywhere they don't want you to go." },
			},
			{
				label = "Thank them, and back away slowly",
				result = { mind = 2, setFlags = { "saw_abnormality" }, log = "You thanked them very politely and backed out of the lot one step at a time. They waved. You've read enough old L Corp papers to know why you were right to." },
			},
		},
	},
	{
		id = "lc_ruins_scales",
		title = "A Bird with Scales",
		text = "Ever since you started walking home through the ruins, there's been a bird. A long-necked bird with a bandage over its eyes and a pair of scales in its beak, perched on a broken streetlight. It's only there when you've told a lie that day. Today, you told a small one. It's watching you.",
		weight = 10,
		once = true,
		tags = { "lcorp", "abnormality" },
		when = { district = { "d12", "d4" }, minAge = 12, world = { era = RUINS } },
		codex = "lc_abno_judgement_bird",
		choices = {
			{
				label = "Go back and tell the truth",
				result = { sanity = 4, mind = 1, setFlags = { "saw_abnormality" }, log = "You went back and told the truth, which was embarrassing, and small, and fine. The streetlight was empty on the way home. It's been empty ever since, mostly." },
			},
			{
				label = "Walk past it, head down",
				result = { sanity = -4, setFlags = { "saw_abnormality" }, log = "You walked past it with your head down. The scales tipped. You felt it in your chest all night, heavy, the weight of a very small lie." },
			},
		},
	},
}
