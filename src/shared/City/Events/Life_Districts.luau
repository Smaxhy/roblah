--[[
	District flavor (area A): at least four scenes for each District, built on what canon
	says it is known for (docs/CANON.md section 2). District 7 stays vague on purpose: only
	the old G Corp's fall in the Smoke War is known. District 12 is street life only (the L
	Corp workplace belongs to the Wings writer). District 23's food culture is left out.
	Every scene is `once`; some depend on the era.
]]

local LATE = { "library", "limbus" }

return {
	-- ── District 4 (D Corp): an ordinary District, with something buried under it ──
	{
		id = "bs_d4_office_row",
		title = "Office Row",
		text = "Your street in District 4 has seven tiny Fixer Offices on it, all fighting for the same clients. This week one has a sign saying PAY FOR ONE REQUEST, GET ONE FREE. The one across the road has answered with ALL WEAPONS GRADED, FREE UPGRADE TO TOP GRADE. Neither sign mentions the small print.",
		weight = 9,
		once = true,
		when = { district = "d4", minAge = 14 },
		codex = "fixers_hana",
		choices = {
			{
				label = "Hire one to find your lost bag",
				requires = { min = { money = 20 } },
				result = { money = -20, sanity = 2, mind = 1, log = "You hired the one-for-one Office to find your bag. They found it in a day, and then used your free second request to \"find\" a bag you'd never lost, and charged you for its return." },
			},
			{
				label = "Help an Office repaint its sign",
				result = { wage = { 15, 30 }, intelligence = 1, log = "You repainted the sign for the smallest Office on the street, a one-person outfit with a Rep who'd been a Grade 8 Fixer for nine years. Her new sign said only: HONEST PRICES. She got three clients that week." },
			},
			{
				label = "Read the small print for your neighbors",
				result = { mind = 2, sanity = 1, log = "You read the small print aloud on the steps of your building to anyone who'd listen. The free request only covered requests of the lowest grade. The free upgrade was to a used weapon. Two Offices stopped saying good morning to you." },
			},
		},
	},
	{
		id = "bs_d4_two_stalls",
		title = "Two Stalls, One Corner",
		text = "Your corner in District 4 has two noodle stalls ten steps apart, run by two old men who used to be best friends and haven't spoken in nineteen years. Each one has offered you a free bowl for life if you'll say, in front of witnesses, that his broth is the better one.",
		weight = 9,
		once = true,
		when = { district = "d4", side = "backstreets", minAge = 10 },
		choices = {
			{
				label = "Eat at both, and say nothing",
				result = { sanity = 3, health = 1, log = "You ate at both every week and praised neither. Both old men respected it, grudgingly. Both gave you extra scallions to try and tip you over. You've never eaten so well." },
			},
			{
				label = "Get them talking again",
				hint = "Mental Strength check: nineteen years is a long time.",
				clash = { stat = "mind", foe = "Nineteen years of silence", coins = 2, base = 3, coinPower = 3 },
				win = { sanity = 5, mind = 2, log = "You found out what the fight had been about: a borrowed pot, never returned. You returned the pot, which was still in the second stall's back room. The two old men looked at it for a long time, and then at each other, and then started arguing about broth like it was nineteen years ago." },
				lose = { sanity = -1, log = "You mentioned the other stall's name. Both old men went silent and served you very small portions for a month." },
			},
		},
	},
	{
		id = "bs_d4_academy_street",
		title = "Academy Street",
		text = "District 4's Backstreets have more academies than anywhere you know: a whole street of them, each in two rooms above a shop. Today is open day, and every teacher is out on the pavement with a little table, calling out subjects like stallholders: \"Bookkeeping! Wing history! Fixer theory, Hana-approved!\"",
		weight = 9,
		once = true,
		when = { district = "d4", minAge = 8, maxAge = 24 },
		choices = {
			{
				label = "Sit in on Fixer theory",
				result = { strength = 2, mind = 1, codex = "fixers_hana", log = "A retired Grade 5 Fixer drew the Hana grading scale on a chalkboard and spent an hour on the difference between a Grade 9 and a Grade 8. \"About forty jobs,\" she said. \"And not dying on any of them.\"" },
			},
			{
				label = "Sit in on bookkeeping",
				result = { intelligence = 3, log = "You learned double-entry bookkeeping from a man who'd done the accounts for three different Syndicates at once and was, somehow, still alive. He said the secret was neat handwriting." },
			},
			{
				label = "Sit in on Wing history",
				result = { intelligence = 1, mind = 2, codex = "bs_lore_smoke_war", log = "The history teacher spent the whole hour on the Smoke War and kept getting quieter. At the end, she said, \"That's what the books say,\" and nothing else, and everyone understood what she meant." },
			},
		},
	},
	{
		id = "bs_d4_humming",
		title = "The Humming Floor",
		text = "Since the White Nights, some buildings in District 4 hum at night: a low note in the floor, too deep to hear, easy to feel. People say there's something of L Corp's buried under the District, sealed when the company fell. Your building is one of the humming ones. Tonight the hum is louder.",
		weight = 9,
		once = true,
		when = { district = "d4", minAge = 10, world = { era = LATE } },
		codex = "lcorp_fall",
		choices = {
			{
				label = "Put your ear to the floor",
				result = { sanity = -4, mind = 2, setFlags = { "bs_heard_the_hum" }, log = "Under the hum, very faint, something like footsteps in a corridor far below, walking a route they'd walked a thousand times. Then a door. Then nothing. You didn't put your ear to the floor again." },
			},
			{
				label = "Ask the landlord about the basement",
				result = { mind = 1, log = "The landlord said the basement had been bricked up since before his time, \"by order,\" and that the order hadn't said whose. He changed the subject to rent." },
			},
			{
				label = "Get a rug and stop thinking about it",
				result = { sanity = 2, money = -10, log = "You bought the thickest rug in the market and put it over the spot. The hum was still there. You just didn't have to feel it. In the City, that counts as a solution." },
			},
		},
	},

	-- ── District 7 (G Corp): an old war, a new Wing ──
	{
		id = "bs_d7_ruins",
		title = "The Fenced Ruins",
		text = "Behind your street in District 7 there's a stretch of old ruins behind a fence nobody has fixed in years: the old G Corp, the kids say, from before the new Wing. Everyone dares everyone to go in. Today the dare is yours. Through the gap in the fence you can see broken concrete, a rusted gate, and a faded painted insect on a wall.",
		weight = 9,
		once = true,
		when = { district = "d7", minAge = 8, maxAge = 16 },
		codex = "bs_lore_d7",
		choices = {
			{
				label = "Go in, just a little way",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "Ruins that don't want visitors", coins = 1, base = 2, coinPower = 2 },
				win = { strength = 1, mind = 1, setFlags = { "bs_d7_insignia" }, log = "You went in as far as the rusted gate and found, in the dust, a little brass badge with a beetle on it. You took it home and hid it. When your grandfather saw it a year later, he went pale and asked where you'd found it, and then said, \"Keep it hidden.\"" },
				lose = { health = { -4, -2 }, sanity = -2, log = "A floor gave way under your foot and you scraped your leg badly getting out. The kids called you brave. You didn't feel brave. You felt like the ruins had noticed you." },
			},
			{
				label = "Say no, and mean it",
				result = { mind = 2, log = "You said no. An old man watching from a window nodded at you, very slightly, as if you'd passed a test he'd once failed." },
			},
		},
	},
	{
		id = "bs_d7_teahouse",
		title = "The Tea House of Old Men",
		text = "There's a tea house in District 7 where the old men sit who don't talk about the war. They don't talk about much else, either. They play a slow board game with chipped pieces and drink very strong tea. Today, an empty chair, and one of them pushes it toward you with his foot.",
		weight = 9,
		once = true,
		when = { district = "d7", minAge = 25 },
		codex = "bs_lore_smoke_war",
		choices = {
			{
				label = "Sit, and say nothing",
				result = { sanity = 4, mind = 2, log = "You sat for two hours and lost three games and nobody said anything about anything. When you got up to leave, the old man who'd pushed the chair said, \"Thursday,\" and you came back on Thursday, for years." },
			},
			{
				label = "Ask what the insect patches mean",
				result = { mind = 2, sanity = -3, log = "The table went quiet. Finally the oldest of them said, \"Units,\" and turned a sleeve so you couldn't see his. \"Names we were given. We don't use them.\" You didn't ask again. They let you come back anyway." },
			},
		},
	},
	{
		id = "bs_d7_new_paint",
		title = "The New Paint",
		text = "The new G Corp is painting over the old murals in District 7's Backstreets: faded war pictures of marching columns and wings and banners, nobody remembers whose. A painting crew in Wing overalls has reached the wall at the end of your street, and an old veteran with a stick is standing in front of it, not moving.",
		weight = 9,
		once = true,
		when = { district = "d7", minAge = 12 },
		codex = "bs_lore_d7",
		choices = {
			{
				label = "Stand with the old man",
				result = { strength = 2, sanity = 2, log = "You stood beside him. Then a grocer did, and two kids, and a woman with a pram. The painting crew's foreman looked at the little crowd, shrugged, and painted the next wall instead. The mural's still there, flaking." },
			},
			{
				label = "Ask him what the mural shows",
				result = { mind = 2, codex = "bs_lore_smoke_war", log = "\"The side that lost,\" he said. \"Which is to say, all of us.\" He let the painters through after that. He'd only wanted someone to ask." },
			},
			{
				label = "Help the painters",
				result = { wage = { 10, 25 }, sanity = -1, log = "You picked up a brush and helped. The war went under a coat of clean pale green. The old man watched the whole time and didn't say a word, and you kept feeling his eyes on your back for days." },
			},
		},
	},
	{
		id = "bs_d7_buzzing",
		title = "The Buzzing Summer",
		text = "Every few summers, District 7 has a night when the air over the old ruins fills with buzzing: moths, beetles, flies, a cloud of them, nobody knows why. The young people come out to watch. The old people go inside and shut the windows and don't come out until it stops. Tonight is one of those nights.",
		weight = 9,
		once = true,
		when = { district = "d7", minAge = 8 },
		choices = {
			{
				label = "Watch with the young people",
				result = { sanity = 2, setFlags = { "bs_saw_the_swarm" }, log = "It was beautiful, actually: a living cloud turning over the ruins, glittering in the streetlights. A friend whispered the old stories, the Moth Princess, the Lord of Flies, and laughed. You laughed too. You noticed you were the only ones laughing who were over twenty." },
			},
			{
				label = "Go inside with the old people",
				result = { mind = 2, log = "You went inside and shut the windows, and sat with your neighbor, an old veteran, while he gripped the arms of his chair until the buzzing stopped. He said, afterward, \"Thank you for coming in,\" and nothing else." },
			},
		},
	},

	-- ── District 8 (H Corp): Hongyuan ──
	{
		id = "bs_d8_room_shrinks",
		title = "The Wall Came Closer",
		text = "You wake up with your nose almost touching the wall. In Hongyuan your room is exactly as big as your fortune, and your fortune has been shrinking. The wardrobe has had to go into the corridor. The window is now in the corner of the ceiling.",
		weight = 9,
		once = true,
		when = { district = "d8", minAge = 18, max = { money = 120 } },
		codex = "bs_lore_hongyuan_rooms",
		choices = {
			{
				label = "Sell something to buy back a wall",
				result = { money = 30, sanity = -1, log = "You sold your good coat at the corridor market. Overnight, the wall slid back a hand's width. You slept better, and colder." },
			},
			{
				label = "Laugh, and sleep diagonally",
				result = { sanity = 2, mind = 1, log = "You laughed, rearranged everything diagonally, and slept with your feet in the doorway. In Hongyuan, everyone has a shrinking-room story. Yours became a good one." },
			},
		},
	},
	{
		id = "bs_d8_room_grows",
		title = "The Walls Ran Away",
		text = "You've done well this year, and Hongyuan has noticed: overnight your room grew by half, with a new window and a corner you've never stood in. In the morning, a messenger in a Family's colors is waiting in your new doorway with a very polite invitation to a banquet.",
		weight = 9,
		once = true,
		when = { district = "d8", minAge = 20, min = { money = 1500 } },
		codex = "bs_lore_hongyuan_rooms",
		choices = {
			{
				label = "Go to the banquet",
				hint = "Mental Strength check: one of the Four Families is courting you.",
				clash = { stat = "mind", foe = "A Family's hospitality", coins = 2, base = 4, coinPower = 3 },
				win = { money = { 100, 250 }, mind = 2, log = "You said all the right things to all the right people and promised nothing. You came home with a business contract, a very nice teapot, and the feeling of having walked across a floor full of knives without being cut." },
				lose = { money = { -150, -50 }, sanity = -3, log = "You agreed to something over the third course that turned out, in writing, to be a loan to the Family at a rate nobody would agree to sober. You were sober. Your room shrank a little." },
			},
			{
				label = "Decline politely, and enjoy the corner",
				result = { sanity = 3, log = "You sent a beautiful note declining, and spent the evening sitting in your new corner with tea, looking out of your new window at the moving corridors of Hongyuan." },
			},
		},
	},
	{
		id = "bs_d8_leash",
		title = "A Contract for Sale",
		text = "At the corridor auction house, between the furniture and the paintings, today's lot is a Heishou Adept's contract: the leash, they call it here, the right to command a fighter of the Packs. The Adept stands beside the auctioneer with his eyes on the floor. He used to walk your corridor at night. He always said good evening.",
		weight = 9,
		once = true,
		when = { district = "d8", minAge = 20 },
		choices = {
			{
				label = "Buy the contract, and tear it up",
				requires = { min = { money = 400 } },
				result = { money = -400, sanity = 8, setFlags = { "bs_freed_heishou" }, log = "You bid until everyone else stopped, signed for it, and tore it in half on the auction house floor. The Adept looked at the pieces for a long time. Then he bowed to you, very low, and walked out free. He still walks your corridor at night. He still says good evening." },
			},
			{
				label = "Start a fund with the corridor",
				hint = "Intelligence check: everyone chips in.",
				clash = { stat = "intelligence", foe = "A corridor's spare change", coins = 2, base = 4, coinPower = 3 },
				win = { money = -60, sanity = 6, setFlags = { "bs_freed_heishou" }, log = "Forty families in your corridor put in what they could. It was just enough. He was free by evening, and the whole corridor had dinner together, which had never happened before." },
				lose = { money = -20, sanity = -3, log = "It wasn't enough. A Family bought the contract. The next week a new Heishou walked your corridor at night, and didn't say good evening." },
			},
			{
				label = "Look away",
				result = { sanity = -4, log = "You looked away. A Family bought his contract for a little more than a good wardrobe. You never saw him again." },
			},
		},
	},
	{
		id = "bs_d8_daguanyuan",
		title = "Guard at the Garden",
		text = "One of the Four Families is holding a banquet in the great garden at the heart of Hongyuan, and needs extra guards on the outer gate: one night, very good pay, and a uniform you have to give back. The rule is simple. Nobody comes through the gate without an invitation. Nobody.",
		weight = 8,
		once = true,
		when = { district = "d8", minAge = 18, maxAge = 50 },
		choices = {
			{
				label = "Take the job",
				hint = "Mental Strength check: a very long night at a very important gate.",
				clash = { stat = "mind", foe = "A gate the whole of Hongyuan wants through", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 80, 160 }, mind = 2, log = "You turned away a merchant, a Fixer, two rival Family cousins and a very convincing man in a fake moustache. At dawn the Family's steward paid you double and asked if you were free next month." },
				lose = { wage = { 20, 40 }, sanity = -3, log = "You let one cousin through who should not have been let through. There was a scene. Nobody was hurt, exactly. You were paid for half a night and asked not to come back." },
			},
			{
				label = "Decline: Family business stays Family business",
				result = { mind = 1, sanity = 1, log = "You declined. The next morning everybody in the corridor market was whispering about what had happened at the gate that night. You were very glad you hadn't been there." },
			},
		},
	},

	-- ── District 11 (K Corp): checkpoints, drones, ampules ──
	{
		id = "bs_d11_clean_street",
		title = "The Cleanest Street",
		text = "District 11's streets are the cleanest in the City. The drones see to that. Today you dropped a sweet wrapper on the pavement without thinking, and a drone has stopped in the air right in front of your face, blinking, waiting.",
		weight = 9,
		once = true,
		when = { district = "d11", minAge = 6, maxAge = 14 },
		choices = {
			{
				label = "Pick it up and apologize to the drone",
				result = { charisma = 2, sanity = 1, log = "You picked it up and said sorry to the drone, out loud. It blinked once, green, and floated off. You told your friends you'd been forgiven by K Corp. Nobody could prove you hadn't." },
			},
			{
				label = "Stare it down",
				result = { strength = 1, sanity = -2, log = "You stared at it. It stared back. After a long minute a second drone arrived. Your family got a fine in the post, very politely worded, with a photograph of you staring." },
			},
		},
	},
	{
		id = "bs_d11_footage",
		title = "The Footage Office",
		text = "There's an office in District 11 that pays very well for street footage: not the Night, never the Night, just daytime clips of \"dramatic moments.\" Accidents. Arguments. People crying. The clerk at the counter flips through what people bring in and pays the most for the saddest ones, and doesn't say why.",
		weight = 9,
		once = true,
		when = { district = "d11", minAge = 16 },
		choices = {
			{
				label = "Sell them a clip of a sad moment",
				result = { money = { 60, 140 }, sanity = -4, log = "You sold them a clip of an old woman crying outside the checkpoint. They paid more than a week's wages for it. You couldn't stop thinking about where the clip went, or who was watching it, or why." },
			},
			{
				label = "Ask the clerk what it's for",
				result = { mind = 2, sanity = -1, log = "\"Research,\" said the clerk, and smiled the kind of smile that is a locked door. \"For the ampules. Everyone benefits.\" She didn't say how sadness helps anyone heal. You didn't sell anything." },
			},
			{
				label = "Walk out",
				result = { sanity = 1, log = "You walked out. On the way home, you noticed how many drones were filming, very quietly, every street corner where people tended to argue." },
			},
		},
	},
	{
		id = "bs_d11_wrong_memories",
		title = "Back From Healing",
		text = "Your neighbor went into the Nest last month after an accident, for the full K Corp treatment: the body restored to how it remembers being whole. She's back, and she's fine, and she's perfect. But she's started calling her daughter by a different name, and she doesn't remember the accident at all, or the month before it.",
		weight = 9,
		once = true,
		when = { district = "d11", minAge = 16 },
		choices = {
			{
				label = "Help her daughter remind her",
				result = { sanity = 2, mind = 1, log = "You and her daughter sat with her every evening going through old photographs. Some of it came back. Some of it didn't. She learned her daughter's name again, and said it more often than before, as if to keep it." },
			},
			{
				label = "Ask at the checkpoint what happened",
				result = { mind = 2, sanity = -2, log = "The checkpoint clerk read your question, looked at you, and said the treatment was \"within normal parameters,\" and that you should be very glad your neighbor was healthy. You were. You were also very careful, after that, about what you asked K Corp." },
			},
		},
	},
	{
		id = "bs_d11_missing_tuesday",
		title = "The Missing Tuesday",
		text = "You wake up on Wednesday. You're sure of it, because the paper says so. You're less sure what happened to Tuesday. There's a note on your kitchen table, in your own handwriting, that you don't remember writing: DON'T ASK. IT WAS FINE.",
		weight = 8,
		once = true,
		when = { district = "d11", minAge = 18 },
		choices = {
			{
				label = "Don't ask",
				result = { sanity = 1, mind = 1, log = "You didn't ask. You put the note in a drawer. Sometimes you took it out and read it, in your own handwriting, and were almost sure it was right." },
			},
			{
				label = "Ask anyway",
				result = { sanity = -4, mind = 2, log = "You asked your neighbors, your workplace, the clinic. Everybody had had a perfectly normal Tuesday. Nobody had seen you. The more you asked, the more people looked at you kindly, and you stopped." },
			},
		},
	},

	-- ── District 12 (L Corp): while the tower stands, and after ──
	{
		id = "bs_d12_green_market",
		title = "The Green Market",
		text = "A stall at the night market in District 12 is selling power cells under the table: little glass canisters glowing green, with the L Corp logo half scratched off. Enkephalin, the stallholder whispers, the company's own energy, \"run a lamp for a year.\" Real or not, everyone knows L Corp sends retrieval teams after anything with its name on it.",
		weight = 9,
		once = true,
		when = { district = "d12", minAge = 16, world = { era = "wings" } },
		choices = {
			{
				label = "Buy one for your lamp",
				requires = { min = { money = 20 } },
				result = { money = -20, sanity = -2, setFlags = { "bs_green_cell" }, log = "It ran your lamp all year with a soft green light that made the whole room feel like it was underwater. In the spring, two people in plain suits knocked on every door on your street, asking politely about \"lost company property.\" You'd already dropped it in the canal." },
			},
			{
				label = "Ask where they came from",
				result = { mind = 2, log = "The stallholder looked at you for a long moment, then packed up his table in about nine seconds and was gone. The next night there was a different stall in the same spot, selling socks." },
			},
			{
				label = "Walk away fast",
				result = { sanity = 1, mind = 1, log = "You walked away fast. Three days later the stallholder was gone, and the stall, and the whole little alley it had been in was being repaved by a crew in company overalls." },
			},
		},
	},
	{
		id = "bs_d12_billboard",
		title = "Face the Fear",
		text = "The biggest billboard in District 12 shows an L Corp agent in a crisp suit, looking bravely into a bright future: FACE THE FEAR, BUILD THE FUTURE. Every kid on your street plays \"agents\" in the alley: one kid is the scary thing in the box, and the agents have to go in and \"do the work\" and come out again.",
		weight = 9,
		once = true,
		when = { district = "d12", minAge = 6, maxAge = 13, world = { era = "wings" } },
		choices = {
			{
				label = "Be the agent",
				result = { strength = 1, sanity = 1, log = "You were the agent. You went into the cardboard box, did the work, which mostly involved shouting, and came out again to cheers. A woman walking past in a real L Corp coat stopped, watched, and walked on without a word." },
			},
			{
				label = "Be the thing in the box",
				result = { mind = 1, sanity = -1, log = "You were the thing in the box. You decided the thing in the box was lonely, and wanted the agents to stay and talk. The other kids found this very unsettling and stopped playing. You thought about it for years." },
			},
		},
	},
	{
		id = "bs_d12_sirens",
		title = "When the Sirens Go",
		text = "The L Corp sirens go off at noon: a sound every child in District 12 knows in their bones. Shutters slam all down the street. You're out at the market, and the stranger next to you, a visitor from another District, has no idea what's happening and is standing in the middle of the road, staring at the tower.",
		weight = 9,
		once = true,
		tags = { "danger" },
		when = { district = "d12", minAge = 12, world = { era = "wings" } },
		choices = {
			{
				label = "Pull the stranger into a doorway",
				result = { sanity = 2, strength = 1, log = "You grabbed the stranger's arm and pulled them into the bakery's doorway as the shutter came down. Twenty minutes later, the all-clear. False alarm, the radio said. The stranger shook your hand for a long time." },
			},
			{
				label = "Run for home",
				hint = "Speed check.",
				clash = { stat = "speed", foe = "Every shutter on the street coming down", coins = 2, base = 3, coinPower = 2 },
				win = { speed = 1, log = "You made your own door before the last shutter fell. The all-clear came at 12:31. On the radio, L Corp apologized for the inconvenience, and only for the inconvenience." },
				lose = { sanity = -3, health = { -3, -1 }, log = "Every door on your route was already shut. You spent twenty minutes crouched behind a market stall with your hands over your ears. It was a false alarm. It didn't feel like one." },
			},
		},
	},
	{
		id = "bs_d12_salvage",
		title = "Salvage",
		text = "Since L Corp fell, half of District 12 makes its living digging: through the old Nest, the collapsed offices, the rubble around the dark tower, for anything with the old logo that a collector somewhere will pay for. A crew of scavengers is short a pair of hands today. \"Good money,\" says their leader. \"Mind the floors.\"",
		weight = 9,
		once = true,
		tags = { "danger" },
		when = { district = "d12", minAge = 16, world = { era = LATE } },
		codex = "bs_lore_d12_after",
		choices = {
			{
				label = "Dig with them",
				hint = "Health check.",
				clash = { stat = "health", foe = "Old floors and falling concrete", coins = 2, base = 3, coinPower = 3 },
				win = { money = { 60, 140 }, health = 1, log = "You dug for a week and found a box of unused L Corp stationery, a coffee mug that said WORLD'S OKAYEST CLERK, and a clipboard with half a safety manual on it. The collectors paid a fortune for all of it, especially the mug." },
				lose = { health = { -8, -3 }, money = { 10, 30 }, log = "A floor gave way and you went through it into a dark room full of old filing cabinets. The crew pulled you out by the collar. You went home bruised with twenty Ahn and a very bad feeling about that room.", cause = "Crushed in the ruins of District 12" },
			},
			{
				label = "Buy something they found",
				requires = { min = { money = 15 } },
				result = { money = -15, sanity = 1, log = "You bought a little brass armband from their table: CONTINUED SERVICE, it said, with a number. Somebody had worn it for a long time. You kept it in a drawer, and sometimes wondered who." },
			},
		},
	},
	{
		id = "bs_d12_fallen_nest",
		title = "The Fallen Nest",
		text = "Inside what used to be L Corp's Nest, a Syndicate's collector is going door to door among the families who stayed: former Feathers, mostly, with good furniture and no Wing to protect them anymore. A woman who used to work in the tower's offices is counting out her protection fee with hands that won't stop shaking.",
		weight = 9,
		once = true,
		when = { district = "d12", minAge = 18, world = { era = LATE } },
		codex = "bs_lore_d12_after",
		choices = {
			{
				label = "Help her read the collector's ledger",
				result = { mind = 2, money = { 10, 30 }, log = "You read the ledger over her shoulder and found she'd been charged twice. You pointed it out, very politely, using every correct title. The collector checked, and corrected it, and the woman gave you a jar of good tea she'd brought from the tower." },
			},
			{
				label = "Tell her about the neighborhood watch",
				result = { sanity = 2, mind = 1, codex = "bs_lore_watch", log = "You told her about the watch on your street: locals with lamps, cheap, nobody's Syndicate. She'd never heard of such a thing. Inside the Nest, she said, nobody had ever had to look after anybody. She started one herself, that spring." },
			},
		},
	},

	-- ── District 14 (N Corp): Butter Street, and the Hammer ──
	{
		id = "bs_d14_butter_street",
		title = "Nobody Minds",
		text = "On Butter Street, nobody minds what you do as long as it doesn't touch their day. Today you're carrying a very large and very strange object home through the market, and not a single person has asked you about it. A man even held a door open without looking up from his paper.",
		weight = 9,
		once = true,
		when = { district = "d14", minAge = 10 },
		codex = "bs_lore_butter_street",
		choices = {
			{
				label = "Enjoy being left alone",
				result = { sanity = 4, log = "It was restful, being nobody's business. You understood, suddenly, why people moved to Butter Street from much more interesting places." },
			},
			{
				label = "Wonder what everyone else is carrying",
				result = { mind = 2, sanity = 1, log = "You started noticing: a woman with a birdcage full of clocks, a man with a sword wrapped in a rug, two children with a sack that moved. Nobody looked at any of them either. Butter Street, you decided, was the strangest ordinary place in the City." },
			},
		},
	},
	{
		id = "bs_d14_hammer_knock",
		title = "The Hammer's Knock",
		text = "Your neighbor Jurek has joined the Inquisitors, N Corp's armored zealots who hunt what they call impurity. He's only a Kleinhammer, the lowest grade, and his hammer is small. But he's started looking at your neighbors in a new way, as if he's weighing them. Today he knocked on your door to ask, very politely, whether you have any prosthetics.",
		weight = 9,
		once = true,
		when = { district = "d14", minAge = 18 },
		choices = {
			{
				label = "Talk to him the way you used to",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A new zealot's certainty", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 4, charisma = 2, log = "You made him tea, the way he likes it, and talked about the old days, his mother, the noodle stall. Somewhere in the second pot he started crying. He left the Inquisitors that winter and never said why. He still knocks, now and then. For tea." },
				lose = { sanity = -3, log = "He listened politely and wrote something in a small black notebook. He was a Mittelhammer by spring, with a bigger hammer and a colder look, and he stopped knocking." },
			},
			{
				label = "Answer his question, and shut the door",
				result = { mind = 1, sanity = -2, log = "\"No,\" you said, which was true, and shut the door. You heard him knock on the next one. You turned the radio up." },
			},
		},
	},
	{
		id = "bs_d14_memory_reel",
		title = "A Memory Reel",
		text = "At a stall on Butter Street, a woman sells Canned Experience from the Grand Magasin Sisyphe: little film reels that let you watch a memory as if you were there. Someone's first snow. Someone's best day. Someone's worst. The labels only say whose memory it is, in code. \"Pick one,\" she says. \"Five Ahn.\"",
		weight = 9,
		once = true,
		when = { district = "d14", minAge = 16 },
		choices = {
			{
				label = "Watch a happy one",
				requires = { min = { money = 5 } },
				result = { money = -5, sanity = 4, log = "You watched someone's first day by the sea: wind, salt, a parent's hand, a sky so wide it hurt. When it ended you were back on Butter Street, and for a moment you missed a sea you had never seen." },
			},
			{
				label = "Ask whose memories they are",
				result = { mind = 2, sanity = -2, log = "\"Customers',\" said the woman. \"They sell them to the Grand Magasin when they need the money.\" She paused. \"They don't remember them after.\" You looked at the reels for a long time, and bought none." },
			},
		},
	},
	{
		id = "bs_d14_photographer",
		title = "Twenty-One Kinds of Photographer",
		text = "District 14 has more photographers than anywhere: portrait men, evidence clerks, catalogue snappers, people who photograph debts for the Syndicates and people who photograph lost cats for Offices. A portrait studio on your corner needs an assistant for a season. The pay is decent. The one rule is pinned over the darkroom door: NO CAMERA OUT AFTER 2:00. EVER.",
		weight = 9,
		once = true,
		when = { district = "d14", minAge = 15, maxAge = 40 },
		choices = {
			{
				label = "Take the job",
				result = { wage = { 30, 70 }, intelligence = 2, log = "You spent a season in the studio: babies, grandparents, Fixers who wanted to look dangerous, a Soldato who wanted to look kind. Every night at 1:45 the photographer locked every camera in an iron cabinet and checked it twice." },
			},
			{
				label = "Sit for a portrait instead",
				requires = { min = { money = 10 } },
				result = { money = -10, sanity = 3, log = "You sat for a portrait in your best coat. The photographer told you to think of someone you love, and then said, \"No, really think,\" and took the picture. It's the only one of you that looks like you." },
			},
		},
	},

	-- ── District 16 (P Corp): spires, and buildings that bend ──
	{
		id = "bs_d16_bending",
		title = "The Building That Bent",
		text = "A crane on the building site next door swings loose and hits your building at the fourth floor. You feel it, in your bones: the whole tower leans, slowly, like a reed in the wind, and folds a little, and then straightens up again. Nobody inside is hurt. Not a cup broken. The crane operator is sitting on the pavement with his head in his hands.",
		weight = 9,
		once = true,
		when = { district = "d16", minAge = 8 },
		choices = {
			{
				label = "Find out who designed the building",
				result = { mind = 2, log = "The building's plaque said only: P CORP SPATIAL SAFETY STANDARD, and a date before your grandmother was born. Nobody at the P Corp office would say who had designed the original. \"It was always like this,\" said the clerk. It wasn't. Something had been, first." },
			},
			{
				label = "Check on the crane operator",
				result = { sanity = 3, log = "You sat with him on the pavement. \"Everyone's fine,\" you said. \"The building bent.\" He started laughing, and couldn't stop, and then he was crying, and then he went home. The building is still standing, slightly smug." },
			},
		},
	},
	{
		id = "bs_d16_street_moved",
		title = "Your Street Moved",
		text = "Some nights in District 16, P Corp adjusts the space between buildings, and in the morning the streets are not quite where they were. Today your walk to work has a new corner in it, and a street you've never seen, and a bakery that wasn't there yesterday and claims to have been there forty years.",
		weight = 9,
		once = true,
		when = { district = "d16", minAge = 14 },
		choices = {
			{
				label = "Try the new bakery",
				result = { sanity = 3, money = -5, log = "The bakery's buns were excellent. The baker insisted she'd always been there, and showed you photographs of herself as a girl behind the same counter. The next week, the street moved again, and the bakery was gone. You still think about those buns." },
			},
			{
				label = "Learn the new way to work",
				result = { mind = 2, log = "You learned the new way in a week. Old District 16 people navigate by spires, not streets, you found out: the spires never move. You started doing the same." },
			},
		},
	},
	{
		id = "bs_d16_spires",
		title = "The Tallest Spire",
		text = "District 16's spires are the tallest in the City: you have to bend your neck all the way back to see the tops, and on cloudy days you can't see them at all. Today the clouds have lifted, and for the first time in your life you can see the very top of the tallest one, glinting.",
		weight = 9,
		once = true,
		when = { district = "d16", minAge = 6, maxAge = 14 },
		choices = {
			{
				label = "Stare until you're dizzy",
				result = { sanity = 3, log = "You stared until you fell over backward onto the pavement, and lay there looking up, laughing, while people stepped around you. You decided someday you'd stand at the top. Someone, after all, had to." },
			},
			{
				label = "Count the windows to the top",
				result = { intelligence = 2, log = "You counted four hundred and eleven windows before you lost your place. You started again the next clear day. You were still counting, on and off, when you were grown." },
			},
		},
	},
	{
		id = "bs_d16_flyers",
		title = "The Station Walls",
		text = "The walls and pillars of the WARP station in District 16 are covered in flyers, top to bottom, layer on layer: jobs, rooms, lost cats, a choir, a lot of HAVE YOU SEEN THIS PERSON with photographs. A woman is trying to pin a new one up, and there isn't a single bare inch left.",
		weight = 9,
		once = true,
		when = { district = "d16", minAge = 12 },
		choices = {
			{
				label = "Help her find a place for it",
				result = { sanity = 2, mind = 1, log = "You found her a place by taking down three flyers for things that had obviously already happened. Hers was a HAVE YOU SEEN. Her brother. You looked at every face on the train home." },
			},
			{
				label = "Read the oldest flyers, at the bottom",
				result = { mind = 2, sanity = -2, log = "Under everything, yellowed and stiff, were flyers older than you: rooms to let, a Fixer Office's grand opening, a HAVE YOU SEEN gone yellow with years. Somebody had never taken it down. Somebody had never stopped hoping, or never come back to check." },
			},
		},
	},

	-- ── District 18 (R Corp): the Packs ──
	{
		id = "bs_d18_recruiters",
		title = "The Office That Never Closes",
		text = "R Corp's recruiting office in District 18 never closes, not even during the Night, though nobody can get to it then. Posters fill its windows: the Rabbits, the Reindeer, the Rhinos, the Fourth Pack marching. A recruiter at the door with a clipboard and a very straight back looks you up and down. \"Fit. Young. Bored. You'll do.\"",
		weight = 9,
		once = true,
		when = { district = "d18", minAge = 17, maxAge = 28 },
		choices = {
			{
				label = "Sign up",
				requires = { career = "none", min = { health = 30, strength = 25 } },
				result = { career = "rcorp", strength = 1, log = "You signed. The recruiter stamped your papers without reading them. \"Report at dawn,\" he said. \"Rabbits, Reindeer or Rhinos, they'll decide. Don't worry about choosing. Worry about coming back.\"" },
			},
			{
				label = "Ask how many come back",
				result = { mind = 2, log = "The recruiter's back got even straighter. \"Enough,\" he said, which was not a number. On the way home you passed the memorial wall by the station, and started counting, and stopped." },
			},
			{
				label = "Walk on",
				result = { sanity = 1, log = "You walked on. Behind you, the recruiter was already saying \"Fit. Young. Bored\" to the next person, in exactly the same voice." },
			},
		},
	},
	{
		id = "bs_d18_a_name",
		title = "A Soldier Without a Name",
		text = "A young R Corp soldier is sitting on the step of your building in a Rabbit team jacket with the patches torn off. He has the same face as half the soldiers in the parade last month. He says he walked away from the Pack, and he'll be found soon, and before that he'd like one thing. \"Would you give me a name? A real one. Mine is a number.\"",
		weight = 9,
		once = true,
		when = { district = "d18", minAge = 18 },
		choices = {
			{
				label = "Give him a name",
				result = { sanity = 5, setFlags = { "bs_named_a_rabbit" }, log = "You thought about it for a long time, and gave him your grandfather's name. He said it over and over, quietly, like tasting something. He thanked you and walked away into the Backstreets. You never saw him again. You hope he kept it." },
			},
			{
				label = "Hide him for the night",
				hint = "Mental Strength check: the Pack is looking.",
				clash = { stat = "mind", foe = "The Pack's search", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 4, mind = 1, log = "You hid him in your back room while the Pack's searchers went door to door. They didn't look twice at you. At dawn he was gone, with a coat of yours and a name of his own." },
				lose = { sanity = -4, log = "The searchers found him in your back room within an hour. He went with them quietly. At the door he said, \"Thank you for trying,\" and you couldn't answer." },
			},
		},
	},
	{
		id = "bs_d18_homecoming",
		title = "The Pack Comes Home",
		text = "The Fourth Pack is marching back into District 18 after a contract: the Rabbits in front, the Reindeer with their antlers, the Rhinos in heavy armor at the back. The whole District lines the street to watch. You notice that everyone is counting, quietly, under their breath, and that the counts are coming out low.",
		weight = 9,
		once = true,
		when = { district = "d18", minAge = 8 },
		choices = {
			{
				label = "Cheer as loudly as you can",
				result = { sanity = 2, strength = 1, log = "You cheered until your voice went. A Rhino at the back, a huge armored shape, lifted one hand very slightly as he passed you. You decided that was for you. It might have been." },
			},
			{
				label = "Count with everyone else",
				result = { mind = 2, sanity = -2, log = "You counted. Everyone counted. Nobody said the number aloud afterward. At the memorial wall by the station, that evening, people were adding names, and some of the names were the same name, again and again." },
			},
		},
	},
	{
		id = "bs_d18_hatchery_tech",
		title = "The Last Hatching",
		text = "Your neighbor works nights as a technician at R Corp's Hatchery, where the Pack's soldiers come from. She's never once talked about her work. Tonight, on the stairs at one, she says, to nobody in particular, that this hatching is the last one the energy allowance will cover this year, and she has to pick which ones.",
		weight = 8,
		once = true,
		when = { district = "d18", minAge = 18 },
		choices = {
			{
				label = "Sit with her on the stairs",
				result = { sanity = 2, mind = 1, log = "You sat with her until a quarter to two and didn't ask anything. When she got up to go in, she said, \"I'll pick the ones who'd have liked a name.\" You didn't know what that meant. You think you do now." },
			},
			{
				label = "Ask what she means, \"pick\"",
				result = { mind = 2, sanity = -3, log = "She looked at you as if she'd only just noticed you were there. \"Nothing,\" she said. \"I'm tired.\" She went inside. She moved to another District that spring, without saying goodbye." },
			},
		},
	},

	-- ── District 19 (S Corp): the King's farms, the Court, and runaways ──
	{
		id = "bs_d19_harvest",
		title = "Harvest Week",
		text = "S Corp is the City's farm, and at harvest the Nest hires half of District 19's Backstreets to work its fields and pens: dawn to dusk, buses at five, home before one. The overseers are from the King's Court and expect to be bowed to. The pay is a week's rent in a day.",
		weight = 9,
		once = true,
		when = { district = "d19", minAge = 12, maxAge = 55 },
		choices = {
			{
				label = "Work the harvest",
				hint = "Health check.",
				clash = { stat = "health", foe = "Dawn to dusk in the King's fields", coins = 2, base = 3, coinPower = 2 },
				win = { wage = { 40, 90 }, health = 2, log = "You worked the whole week and came home with brown arms and a week's rent for every day. The overseer said you bowed adequately. In the Court, that is high praise." },
				lose = { wage = { 15, 30 }, condition = "bs_bad_back", log = "Your back gave out on the fourth day. You were sent home with half pay and a lecture from an overseer about the weakness of Backstreets stock." },
			},
			{
				label = "Sell water to the harvest workers",
				result = { wage = { 20, 40 }, sanity = 2, log = "You hauled water to the field edges and sold it by the cup at half the overseers' price. By the end of the week, the workers were saving you a seat on the bus." },
			},
		},
	},
	{
		id = "bs_d19_runaway",
		title = "A Runaway at the Door",
		text = "There's a woman at your door at midnight in a technician's smock from the Court, the Circle of Pi by its color, with no shoes and very little time. \"They'll come,\" she says. \"The Ch'unokkun. Tonight or tomorrow. I only need a place until the Night is over.\" Hiding a runaway from the Court is something District 19 people do, and don't talk about.",
		weight = 9,
		once = true,
		tags = { "danger" },
		when = { district = "d19", minAge = 18 },
		choices = {
			{
				label = "Hide her",
				hint = "Mental Strength check: the Ch'unokkun are good at this.",
				clash = { stat = "mind", foe = "Ch'unokkun at the door", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 5, setFlags = { "bs_hid_runaway" }, log = "You hid her under the floorboards of the back room. The headband men came at dawn, asked their questions, looked at your face for a long time, and left. She stayed a month and then vanished one morning, leaving a thank-you note and a recipe from the Court." },
				lose = { sanity = -5, money = { -80, -30 }, log = "They found her under the floor. They took her, quietly, and fined you for \"harboring,\" very politely. You never found out her name." },
			},
			{
				label = "Give her shoes, money and directions",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = 3, log = "You gave her your spare shoes, thirty Ahn and directions to a WARP station that doesn't check papers closely. She ran. You'll never know if she made it. You decided she did." },
			},
			{
				label = "Close the door",
				result = { sanity = -4, log = "You closed the door. In the morning, two men with painted headbands were walking down your street, slowly, looking at every window. You didn't look at yours." },
			},
		},
	},
	{
		id = "bs_d19_old_salsu",
		title = "The Old Swordsman",
		text = "An old man sits by the canal in District 19 every afternoon, sharpening a long sword that's older than he is. He was a Salsu of the Blade Lineage once, people say, a swordsman who left the King's Court with nothing but his blade. Today he looks up and catches you watching. \"You want to know why we left,\" he says. It isn't a question.",
		weight = 9,
		once = true,
		when = { district = "d19", minAge = 12 },
		choices = {
			{
				label = "Ask him why",
				result = { mind = 2, strength = 1, log = "\"Because the Court told us who to cut,\" he said, \"and stopped telling us why.\" He went back to sharpening. \"A blade should have a reason. That's all.\" You came back to the canal often after that, and he never said another word about it, and taught you to sharpen a knife properly." },
			},
			{
				label = "Ask to see the sword",
				result = { strength = 2, log = "He held it up so it caught the light, and for a second it looked like water standing up. \"Don't touch,\" he said. \"It remembers things.\" He put it away. You thought about that sword for years." },
			},
		},
	},
	{
		id = "bs_d19_circles",
		title = "Three Circles at the Market",
		text = "At the District 19 market, two Court servants are arguing at a stall over the last basket of good apples: a retainer of Sal, the flesh circle, and a retainer of Ppyeo, the bone circle. Both are shouting about precedence. Both have guards. The stallholder is looking at you, the only other customer, for help.",
		weight = 9,
		once = true,
		when = { district = "d19", minAge = 16 },
		choices = {
			{
				label = "Suggest they split the basket",
				hint = "Mental Strength check: Court precedence is a minefield.",
				clash = { stat = "mind", foe = "Two Circles' pride", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, money = { 10, 30 }, log = "You suggested, very humbly, that the King himself would want both Circles to have apples. Neither could argue with the King. They split the basket. The stallholder slipped you an apple and a wink." },
				lose = { sanity = -3, log = "You suggested splitting the basket, and both retainers turned on you for presuming. You left without apples, with a scolding in two Circles' styles at once." },
			},
			{
				label = "Buy the apples yourself and leave",
				requires = { min = { money = 10 } },
				result = { money = -10, strength = 1, sanity = 2, log = "You bought the basket while they were shouting and walked off with it. Behind you the argument changed direction entirely. You gave the apples to the neighborhood watch." },
			},
		},
	},

	-- ── District 20 (T Corp): time and color ──
	{
		id = "bs_d20_blue_scarf",
		title = "A Blue Scarf",
		text = "In T Corp's Nest, everything is black, white and gray, because color is a privilege permitted only to those with power. You've worn your grandmother's blue scarf through the checkpoint by mistake. A Collector in gray stops you on the street, looks at the scarf, and takes out a fine book.",
		weight = 9,
		once = true,
		when = { district = "d20", minAge = 10 },
		choices = {
			{
				label = "Pay the fine",
				result = { money = { -40, -15 }, mind = 1, log = "You paid. He wrote you a receipt in gray ink. You folded the scarf into your coat pocket, where it was legal, and walked on through the gray streets with a blue secret against your heart." },
			},
			{
				label = "Explain it was your grandmother's",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A T Corp Collector", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, log = "He listened to the whole story. Then he closed the fine book, looked around very carefully, and said, \"Pocket,\" and walked away. You saw him again years later, and he nodded at your pocket." },
				lose = { money = { -60, -30 }, sanity = -2, log = "\"Sentiment,\" he said, \"is not a permit,\" and doubled it." },
			},
		},
	},
	{
		id = "bs_d20_time_tax",
		title = "Time Tax",
		text = "A letter from T Corp, in gray ink: your late grandfather's Time Tax was never fully paid, and in District 20 an unpaid tax on time passes to the family. The amount is large. The letter explains, helpfully, that it can be paid in Ahn, or settled in time, \"at the standard rate of withdrawal.\"",
		weight = 9,
		once = true,
		when = { district = "d20", minAge = 20 },
		choices = {
			{
				label = "Pay it in Ahn",
				result = { money = { -120, -60 }, mind = 1, log = "You paid it in Ahn, every last one, rather than find out what \"settled in time\" meant. The receipt was gray. Your grandfather would have been furious and relieved." },
			},
			{
				label = "Appeal it",
				hint = "Charisma check: T Corp's tax office has very long days.",
				clash = { stat = "charisma", foe = "T Corp's tax office", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 2, sanity = 2, log = "You found the one clause in the time code about debts older than the debtor's death, and argued it until the clerk ran out of day. The debt was written off. On the way out, you noticed the clerk's day seemed to be lasting much longer than yours." },
				lose = { money = { -150, -80 }, sanity = -4, log = "The appeal took what felt like a week and was, by the clock, an afternoon. You lost, and paid, and walked out into the gray street feeling oddly older." },
			},
		},
	},
	{
		id = "bs_d20_timepiece",
		title = "A Timepiece, Cheap",
		text = "In District 20, everyone needs a timepiece: a citizen's watch from T Corp that holds your balance of time. People born outside the District can hardly ever get one legally. A man in a doorway in the Backstreets opens his coat: a dozen of them, gleaming, \"good as real, cheaper than real.\"",
		weight = 9,
		once = true,
		when = { district = "d20", minAge = 16 },
		choices = {
			{
				label = "Buy one",
				requires = { min = { money = 80 } },
				result = { money = -80, sanity = -2, setFlags = { "bs_forged_timepiece" }, log = "You bought one. It ticked beautifully. It ran fast on Tuesdays and slow on Fridays, and once, for an afternoon, it ran backward, and you had a very strange afternoon. You never quite trusted your own days again." },
			},
			{
				label = "Walk on",
				result = { mind = 2, log = "You walked on. A week later the doorway was empty, and the man's photograph was on a T Corp notice: WANTED FOR TIME FRAUD. Under it, in small print, the penalty, which was measured in years, literally." },
			},
		},
	},
	{
		id = "bs_d20_yurodiviye",
		title = "The Saint's People",
		text = "In District 20's Backstreets, the Yurodiviye run a soup line out of an old warehouse. They used to help the poor, people say, before they started mostly talking about remaking the City. Tonight there's soup, and a man in a plain coat standing on a crate, talking about \"the right moment\" and \"the Saint,\" to anyone eating.",
		weight = 9,
		once = true,
		when = { district = "d20", side = "backstreets", minAge = 16 },
		choices = {
			{
				label = "Eat the soup, skip the speech",
				result = { sanity = 2, health = 1, log = "The soup was good. The speech was long. You left before the end and nobody stopped you. A girl at the door pressed a pamphlet into your hand anyway. It was mostly about waiting." },
			},
			{
				label = "Ask him what the right moment is",
				result = { mind = 2, sanity = -1, log = "\"You'll know,\" he said, delighted to be asked, and talked for another hour without saying. Afterward, an old woman in the soup line told you the Yurodiviye used to fix roofs. \"Now,\" she said, \"they fix the future. Roofs were more useful.\"" },
			},
		},
	},

	-- ── District 21 (U Corp): the Great Lake ──
	{
		id = "bs_d21_trash_crab",
		title = "Trash Crabs",
		text = "There's a Trash Crab on the dock in District 21: one of the Great Lake's scavenging crabs, as big as a dog, wearing an old kettle as a shell and clacking a claw made partly of fork. Trash Crabs collect rubbish and wear it as armor. This one has noticed your sandwich.",
		weight = 9,
		once = true,
		when = { district = "d21", minAge = 5, maxAge = 14 },
		choices = {
			{
				label = "Give it the sandwich",
				result = { sanity = 3, log = "You gave it the sandwich. It ate it with great dignity, and then, to your delight, attached your sandwich paper to its kettle with a click. You saw it on the dock for years after, wearing your paper." },
			},
			{
				label = "Run",
				hint = "Speed check: it's faster than it looks.",
				clash = { stat = "speed", foe = "A Trash Crab", coins = 1, base = 2, coinPower = 2 },
				win = { speed = 2, log = "You ran, and it chased you to the end of the dock, then lost interest and went back to its kettle. You told everyone you'd fought a Trash Crab. You had, technically, raced one." },
				lose = { health = { -3, -1 }, log = "It caught up with you, pinched your ankle with the fork claw, took the sandwich and left. A fisherman laughed so hard he nearly fell off the pier." },
			},
		},
	},
	{
		id = "bs_d21_tuning_fork",
		title = "The Shipwright's Fork",
		text = "A shipwright in the Great Lake harbor has a U Corp resonance tuning fork, the District's own strange tool: strike it, and two unlike things become one thing, as if they had always been that way. She's fused a lantern into a mast and a net into a sail. She looks at your coat, and at the tool in your hand, and grins. \"I could make those one thing.\"",
		weight = 9,
		once = true,
		when = { district = "d21", minAge = 16 },
		choices = {
			{
				label = "Let her try",
				requires = { min = { money = 40 } },
				result = { money = -40, intelligence = 2, sanity = -2, setFlags = { "bs_fused_coat" }, log = "She struck the fork. There was a sound you felt in your teeth, and your coat and your tool were one thing, as if they always had been: a pocket that was a toolbox, a sleeve that was a sheath. It works beautifully. It's slightly warm, all the time." },
			},
			{
				label = "Ask what else she's fused",
				result = { mind = 2, log = "She showed you: a door fused with a dog's bed, a teapot fused with a clock, a pistol fused with the claw of a Trash Crab, which twitched. \"Some things don't want to be one thing,\" she said. \"You can usually tell afterward.\"" },
			},
		},
	},
	{
		id = "bs_d21_portship",
		title = "A Season on the Portship",
		text = "The Stingray Portship, U Corp's great floating luxury port, is hiring Backstreets hands for the season: porters, waiters, deck cleaners. Rich passengers, enormous tips, and a famous hair salon on the upper deck that people from every District queue for. The work is long. The view of the Great Lake is the best in the City.",
		weight = 9,
		once = true,
		when = { district = "d21", minAge = 16, maxAge = 45 },
		choices = {
			{
				label = "Sign on for the season",
				hint = "Intelligence check: the rich are very particular.",
				clash = { stat = "intelligence", foe = "Very particular passengers", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 80, 180 }, intelligence = 1, log = "You carried luggage for people whose luggage had luggage, smiled until your face hurt, and came home with a season's tips and the memory of the sun going down over the Great Lake from the top deck. It almost made up for the passengers." },
				lose = { wage = { 30, 60 }, sanity = -2, log = "A passenger complained that you'd looked at her hat. You were moved to the engine deck for the rest of the season. The pay was worse and the company was better." },
			},
			{
				label = "Just go and look at the lake",
				result = { sanity = 4, log = "You took the ferry out to the Portship's public deck and looked at the Great Lake for an afternoon: storms on the horizon, a whaling ship's sails, the water going on forever. It was free. It was the best thing in the District." },
			},
		},
	},
	{
		id = "bs_d21_coupon",
		title = "The Salon Coupon",
		text = "In the lost-and-found box of the ferry office, under a stack of umbrellas, you find a gold-edged coupon: five hours of personal hair care with the director of the famous salon on the Stingray Portship. That afternoon, a man in sunglasses with a heavy book chained at his waist walks into the ferry office, very slowly, asking everyone if they have seen \"a certain coupon.\"",
		weight = 6,
		once = true,
		when = { district = "d21", minAge = 16, world = { era = "limbus" } },
		choices = {
			{
				label = "Hand it over at once, with every courtesy",
				result = { sanity = 3, mind = 2, log = "You handed it over with a bow, both hands, saying you'd found it and kept it safe. He took off his sunglasses, turned the coupon over twice, and handed it back. \"Not mine. Mine had a kitty sticker.\" Then, a little quieter: \"Honest, though. How rare.\" He put the sunglasses back on and left. Your name, you're fairly sure, went in the good part of the book." },
			},
			{
				label = "Pretend you've never seen it",
				hint = "Mental Strength check. He has a book for people who lie to him.",
				clash = { stat = "mind", foe = "A man with a Book of Vengeance", coins = 3, base = 5, coinPower = 3 },
				win = { money = { 200, 400 }, sanity = -4, log = "He looked at you for a very long time through the sunglasses, and moved on. You sold the coupon that night to a Nest woman for a fortune, and didn't sleep for a month, and kept looking over your shoulder for years." },
				lose = { condition = "in_the_book", sanity = -6, log = "He smiled, opened the heavy book at his waist, and wrote something down with a great flourish, reading it aloud in a grand old voice. Lying to a Big Brother of the Middle, it turns out, is an entry all by itself. He didn't even take the coupon. It wasn't his. Everyone in the ferry office stepped away from you." },
			},
		},
	},

	-- ── District 23 (W Corp): the WARP trains ──
	{
		id = "bs_d23_platform",
		title = "The Platform",
		text = "You like to sit at the end of the WARP platform in District 23 and watch the trains: in, out, ten seconds across the City and back. Today an old man stepping off the train stops, looks around at the station, and sits down hard on the bench next to you. \"Silly,\" he says. \"For a moment I couldn't think where I was.\"",
		weight = 9,
		once = true,
		when = { district = "d23", minAge = 6, maxAge = 16 },
		codex = "districts_w_corp",
		choices = {
			{
				label = "Help him find his family",
				result = { sanity = 3, mind = 1, log = "You walked the old man up and down the platform until a woman ran to him, calling, \"Grandfather!\" He patted her face and said the ride was over before he'd sat down. She gave you a sweet for your trouble." },
			},
			{
				label = "Ask him what the ride is like",
				result = { mind = 2, sanity = -1, log = "\"Like nothing,\" the old man said. \"You sit down, the lights dip, you stand up.\" He frowned at his ticket for a while. \"Forty years I've ridden it. I couldn't tell you one thing about the inside.\"" },
			},
		},
	},
	{
		id = "bs_d23_cleanup_neighbor",
		title = "The Man With the Sealed Case",
		text = "Your neighbor in District 23 is a W Corp cleanup agent. He leaves at odd hours with a sealed case and comes back with the same case, and once, only once, you passed him on the stairs on the way home and he was shaking so badly he couldn't get his key in the lock. He's never said a word about the work. Tonight he's standing at his door, key in hand, not moving.",
		weight = 9,
		once = true,
		when = { district = "d23", minAge = 16 },
		choices = {
			{
				label = "Open the door for him",
				result = { sanity = 2, mind = 1, log = "You took the key, gently, and opened his door, and he went in without a word. The next day there was a tin of very good biscuits outside your door, the First Class kind, with a note: \"Thanks. Take the stairs when you can.\"" },
			},
			{
				label = "Ask what he cleans",
				result = { mind = 2, sanity = -2, log = "He looked at you for a long time. \"Lost property,\" he said. Then, quieter: \"Don't ask me again. One night I'd answer, and then you'd be somebody who knows.\" He had moved out by the end of the month." },
			},
		},
	},
	{
		id = "bs_d23_ticket_booth",
		title = "The Ticket Booth",
		text = "W Corp needs ticket clerks for the District 23 station: a glass booth, a stamp, prices nobody can afford, and a rule printed on a card behind the glass: NEVER ANSWER QUESTIONS ABOUT THE JOURNEY. A woman at the window is asking you, very quietly, whether it's true what they say about long trips.",
		weight = 9,
		once = true,
		when = { district = "d23", minAge = 16, maxAge = 45 },
		codex = "districts_w_corp",
		choices = {
			{
				label = "Follow the rule: sell her the ticket",
				result = { wage = { 30, 60 }, mind = 1, sanity = -2, log = "\"It's a very quick journey, madam,\" you said, as trained, and stamped her ticket. You worked the booth for a season and said those words four thousand times. By the end you almost believed them." },
			},
			{
				label = "Tell her to buy First Class",
				result = { wage = { 15, 30 }, sanity = 2, log = "\"If you can,\" you said, very quietly, \"sleep through it.\" She looked at you, and understood, and paid for First Class with money she'd clearly been saving for something else. You were moved off the booth the next week." },
			},
		},
	},
	{
		id = "bs_d23_wayfarer",
		title = "Cheap Portals",
		text = "Since the recent trouble with the WARP trains, a new company called Wayfarer has been opening Portals all over District 23: step through a glowing frame, step out somewhere else. The cheap Portals have \"minor side effects,\" according to the small print. The expensive ones don't. Nobody at Wayfarer will say why.",
		weight = 9,
		once = true,
		when = { district = "d23", minAge = 16, world = { era = "limbus" } },
		choices = {
			{
				label = "Take a cheap Portal",
				result = { money = -10, sanity = -3, mind = 1, log = "You stepped through and out on the other side of the District in a heartbeat. You felt fine. Your shadow was a different shape for a week, and your left boot was on your right foot, and you were sure you'd put them on properly." },
			},
			{
				label = "Pay for an expensive one",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 1, log = "The expensive Portal was quiet, smooth, and smelled faintly of flowers. You stepped out exactly as yourself. Afterward you wondered what, exactly, the extra fifty Ahn had paid to keep." },
			},
			{
				label = "Walk",
				result = { health = 1, sanity = 1, log = "You walked. It took most of the afternoon. You were exactly yourself the whole way, which in District 23 is no small thing." },
			},
		},
	},
}
