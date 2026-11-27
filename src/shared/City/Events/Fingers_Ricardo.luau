--[[
	Big Brother Oswin of the Middle (docs/CANON.md 3.4, checked against the Limbus English
	game text). The player is a bystander or a hired hand in his world, never the hero.
	District 21, the Great Lake, Canto V:
		fn_ricardo_stickers  he buys kitty stickers for his personal safe (original scene)
		-> fn_ricardo_safe (a year later) the safe is emptied by strangers off a bus-ship; in it,
		   the Stingray Portship salon coupon; Little Brothers go door to door
		-> fn_ricardo_boat   the gaudiest boat in the harbor, a deckhand job
		-> fn_ricardo_sins   Title 8, Section 20, Row A, Line 6; his canon introduction
		-> fn_ricardo_elder  the Indigo Elder's harpoon; "the Middle remembers"
		-> fn_ricardo_ride   the ride back; his hair in the fog
		-> fn_ricardo_repaid (two years later) the Middle pays its debts, in whichever form
	District 8, Hongyuan, "Nocturnal Sweeping":
		fn_ricardo_werner -> fn_ricardo_sweeping (Werner, three waves, the launch into the skyline)
	Anywhere, later: fn_ricardo_rumor. Violence stays offscreen (section 12).
]]

local LATER = { event = "fn_ricardo_safe", inYears = 1 }

-- your name goes into his Book
local function inBook(log: string, extra: { string }?)
	local flags = { "fn_middle_grudge" }
	for _, f in extra or {} do
		table.insert(flags, f)
	end
	return { setFlags = flags, condition = "in_the_book", chronicle = "fn_written_in_book", sanity = -6, codex = "fn_lore_book", log = log }
end

-- every way of watching the sins read aloud is witnessing Oswin at work
local function witness(r)
	r.chronicle = "fn_ricardo_witness"
	r.trigger = "fn_ricardo_elder"
	r.setFlags = r.setFlags or { "fn_ricardo_witness" }
	return r
end

return {
	-- ── the Great Lake ──
	{
		id = "fn_ricardo_stickers",
		title = "Colorful Kitty Stickers",
		text = "The stationery stall where you work on the Great Lake docks sells stickers by the sheet. Today a very large man buys every kitty sticker you have: the pink ones, the striped ones, the ones in tiny hats. He wears sunglasses, though the Lake fog is thick enough to chew. Tattoos climb out of his collar, and a heavy old book hangs from his belt on a chain.",
		weight = 40,
		once = true,
		tags = { "fingers" },
		when = { district = "d21", minAge = 12, minYear = 1002, world = { era = "limbus" } },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Ask what they're for",
				result = { wage = { 20, 40 }, sanity = 1, setFlags = { "fn_ricardo_seen" }, schedule = LATER, log = "\"My personal safe,\" he said. \"Everyone has different tastes, like the many colorful Lakes of the Great Lake.\" He tipped you and left, whistling." },
			},
			{
				label = "Compliment his hair",
				clash = { stat = "charisma", foe = "A Big Brother's standards", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 40, 80 }, sanity = 3, setFlags = { "fn_ricardo_seen", "fn_ricardo_liked" }, schedule = LATER, log = "He lowered his sunglasses. \"You see it,\" he said. \"Most people only see the sunglasses.\" Then he explained the luscious world and the bristly world for twenty minutes, and tipped very well." },
				lose = { sanity = -3, setFlags = { "fn_ricardo_seen" }, schedule = LATER, log = "You said his hair looked tidy. He winced as if you'd stepped on his foot. \"Tidy,\" he repeated, and left without his change." },
			},
			{
				label = "Say kitty stickers are for kids",
				hint = "He has a Book. Choose your words.",
				clash = { stat = "mind", foe = "A Big Brother's patience", coins = 3, base = 6, coinPower = 3 },
				win = { addTrait = "fn_not_worth_the_ink", setFlags = { "fn_ricardo_seen" }, schedule = LATER, log = "He opened the Book, found a page, wet his finger, looked at you over his sunglasses, and closed it again. \"Not worth the ink,\" he said. You have never been so glad to be insulted." },
				lose = inBook("\"Disrespect for differing tastes,\" he said, writing slowly. \"That's a whole Section.\" He paid for the stickers anyway. Exact change.", { "fn_ricardo_seen" }),
			},
		},
	},
	{
		id = "fn_ricardo_safe",
		title = "Whose Safe Was That?",
		text = "News runs along the docks faster than the ferries. Strangers whose bus turned into a ship roughed up the Twinhook Pirates' clubhouse, and on the way out one of them emptied a small safe covered in kitty stickers. In it, people say, was a coupon for five hours of personal hair care from the director of the finest salon on the Stingray Portship. Now Little Brothers of the Middle are going door to door with a photograph.",
		weight = 0,
		when = { district = "d21" },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Tell them where the strangers went",
				result = { setFlags = { "fn_middle_favor" }, trigger = "fn_ricardo_boat", log = "You'd seen the strangers' ship heading into the fog toward the old L Corp drilling ship. The Little Brother wrote it down and thanked you like family. Then he asked if you knew anyone with a boat." },
			},
			{
				label = "Say you saw nothing",
				result = { sanity = -1, log = "You said you saw nothing. The Little Brother looked sad for you, as if you'd missed something important. Later, you decided you had." },
			},
			{
				label = "Laugh: all this for a coupon?",
				clash = { stat = "mind", foe = "A loyal Little Brother", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 1, log = "He pretended not to hear, which was the kindest thing anyone did for you all year. \"Don't ever let Big Bro hear you say that,\" he whispered." },
				lose = inBook("He wrote your name on the back of the photograph. \"For Big Bro,\" he said. \"He keeps a whole Section for people who say 'just a coupon'.\""),
			},
			{
				label = "Ask after the man in sunglasses",
				requires = { flags = { "fn_ricardo_liked" } },
				result = { trigger = "fn_ricardo_boat", log = "\"Big Bro Oswin,\" the Little Brother said proudly. \"He remembers you. He says you have eyes.\" Then he asked if you knew anyone with a boat." },
			},
		},
	},
	{
		id = "fn_ricardo_boat",
		title = "The Gaudiest Boat in the Harbor",
		text = "The Little Brothers have hired the gaudiest pleasure boat in the harbor, because Big Bro says an entrance matters, and they need a deckhand who knows the fog lanes out to the sunken L Corp drilling ship. At the end of the pier stands Oswin, a Big Brother of the Middle, sunglasses on in the gray. A Little Brother holds a speaker over his head, thumping dance music.",
		weight = 0,
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Take the job and steer",
				clash = { stat = "intelligence", foe = "The Great Lake's fog lanes", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 150, 250 }, setFlags = { "fn_ricardo_boat_hand" }, trigger = "fn_ricardo_sins", log = "You took the gaudy boat through the fog lanes without a scrape. Oswin posed at the bow the whole way, fixing his hair in the spray." },
				lose = { wage = { 80, 120 }, sanity = -3, setFlags = { "fn_ricardo_boat_hand" }, trigger = "fn_ricardo_sins", log = "You took two wrong lanes. Oswin said the delay was building suspense, and wrote nothing down. Probably." },
			},
			{
				label = "Point the way, stay on the pier",
				result = { wage = { 30, 50 }, sanity = -2, log = "You pointed the way and watched the gaudy boat vanish into the fog, music thumping. An hour later a shockwave rolled across the Lake and rattled every window on the docks. You never learned the rest." },
			},
			{
				label = "Say you have a bad cold",
				result = { sanity = -3, log = "You coughed, unconvincingly. Oswin said he would remember that you had a cold. You're still not sure what that means." },
			},
		},
	},
	{
		id = "fn_ricardo_sins",
		title = "The Sins, Read Aloud",
		text = "Out of the fog rises a buried L Corp branch's drilling ship, and on it a battered crew of strangers who keep getting back up. Oswin lifts the chained Book, wets a finger and finds it: Title 8, Section 20, Row A, Line 6. Hair Salon Coupons. Complete and total extermination of all involved parties. \"My name's Oswin,\" he tells them. \"Let it be the last thing you remember. Memories are important, after all.\" Then he leaps.",
		weight = 0,
		codex = "fn_lore_book",
		choices = {
			{
				label = "Hold the boat steady, head down",
				clash = { stat = "intelligence", foe = "Shockwaves across the water", coins = 2, base = 5, coinPower = 3 },
				win = witness({ sanity = -3, log = "You held the boat steady while the drilling ship shook. Every time the strangers got back up, Oswin laughed and clapped. Every time, they got back up." }),
				lose = witness({ health = { -7, -2 }, sanity = -5, log = "A shockwave threw you into the rail. From the deck you watched him clap like a child at a puppet show." }),
			},
			{
				label = "Watch the fight",
				result = witness({ sanity = -7, mind = 2, log = "You watched. He fought the way other people dance, laughing, inventing new ways to knock the same people down. At one point he suggested something called clock bashing. You didn't want to know." }),
			},
			{
				label = "Get between him and the strangers",
				hint = "He is a Big Brother of the Middle. This is not your story.",
				clash = { stat = "strength", foe = "Oswin, Big Brother of the Middle", coins = 4, base = 9, coinPower = 4, fight = true, status = { id = "rupture", potency = 3 } },
				win = witness({ strength = 3, sanity = 2, setFlags = { "fn_ricardo_witness", "fn_ricardo_amused" }, log = "For one exchange, somehow, you held him. He laughed and clapped. \"A deckhand! Look at that!\" Then he stepped around you as if you were furniture, and went back to the people in his Book." }),
				lose = witness({ health = { -12, -6 }, sanity = -6, cause = "Got between Oswin and his Book", log = "He didn't stop smiling. You woke in the bottom of the boat with fog in your face and no memory of the last minute, which you decided was a mercy." }),
			},
		},
	},
	{
		id = "fn_ricardo_elder",
		title = "A Bell in the Fog",
		text = "It goes on for a long time. Then a solemn sound tolls through the fog, and a small skiff glides out of it: one old figure at the oar, a harpoon too big for any person lashed to the bow. Oswin goes very still. The old man throws. You never see it fly, only the Big Brother down on one knee, wounded at the shoulder, the harpoon line pulled tight.",
		weight = 0,
		codex = "fx_lore_colors",
		choices = {
			{
				label = "Get the boat ready to leave",
				result = { trigger = "fn_ricardo_ride", log = "You started the engine before anyone told you to. Behind you Oswin was saying something about Colors and the Marlin Whale, and the old man was saying he was only after a fish that got away." },
			},
			{
				label = "Stare at the old man",
				result = { mind = 3, sanity = -2, setFlags = { "fx_saw_color" }, trigger = "fn_ricardo_ride", log = "The Indigo Elder, people told you later: a Color Fixer who hunted the Marlin Whale. He looked at your gaudy boat, and at you, with mild interest, as if you were weather." },
			},
		},
	},
	{
		id = "fn_ricardo_ride",
		title = "The Ride Back",
		text = "Oswin comes aboard holding his shoulder and swearing over the water: \"The Middle remembers! And the Middle always pays its debts, in whichever form!\" Then he sits down heavily in the stern, and the Lake fog begins, very slowly, to frizz his hair. He touches it. He makes a small, terrible sound. Every Little Brother aboard looks at you.",
		weight = 0,
		codex = "fn_lore_ricardo",
		choices = {
			{
				label = "Hand him a dry towel for his hair",
				result = { sanity = 3, setFlags = { "fn_ricardo_towel" }, schedule = { event = "fn_ricardo_repaid", inYears = 2 }, log = "He wrapped his hair before his shoulder. \"You,\" he said, very quietly, \"understand priorities.\" He didn't say another word all the way back." },
			},
			{
				label = "Steer, and say nothing",
				result = { wage = { 100, 200 }, log = "You steered and said nothing. At the pier he tipped you without looking, a thick fold of Ahn, and walked into the fog with his Little Brothers, the music quieter now." },
			},
			{
				label = "Mention that the fog makes it bristly",
				clash = { stat = "mind", foe = "A wounded Big Brother's mood", coins = 3, base = 6, coinPower = 3 },
				win = { addTrait = "fn_not_worth_the_ink", log = "He stared at you over his sunglasses, then laughed, a terrible laugh, all the way back to the docks. \"Not worth the ink,\" he said, wiping his eyes. \"Not even today.\"" },
				lose = inBook("He opened the Book with his good arm and wrote with great care. \"Remarks on the bristly,\" he said. \"Title 1. I keep Title 1 for special people.\""),
			},
		},
	},
	{
		id = "fn_ricardo_repaid",
		title = "For the Towel",
		text = "A Little Brother you've never met brings a parcel to your door: a jar of the most expensive hair oil sold on the Stingray Portship, and an envelope thick with Ahn. The note inside is in big, careful handwriting. \"For the towel. The Middle always pays its debts. R.\" There is a tiny kitty sticker on the envelope.",
		weight = 0,
		when = { flags = { "fn_ricardo_towel" } },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Keep it all",
				result = { wage = { 250, 400 }, sanity = 5, setFlags = { "fn_middle_favor" }, log = "You kept the Ahn and the oil. Your hair has never been so luscious. Strangers seem to sense it." },
			},
			{
				label = "Send back a thank-you note",
				result = { wage = { 250, 400 }, sanity = 3, mind = 1, setFlags = { "fn_middle_favor" }, log = "You wrote a thank-you note in your best handwriting. The Little Brother read it, teared up, and promised to deliver it personally. Courtesy, too, is something the Middle remembers." },
			},
		},
	},

	-- ── District 8, Hongyuan: "Nocturnal Sweeping" ──
	{
		id = "fn_ricardo_werner",
		title = "A Brother from the South",
		text = "A Little Brother of the Middle named Werner stops you in a Hongyuan corridor that was a staircase yesterday. He's guiding a Big Brother from the south through H Corp, they're lost, and the Big Brother is hunting a band of coupon thieves. Behind him, a man in sunglasses studies his reflection in a shop window, setting one strand of hair back in place.",
		weight = 30,
		once = true,
		tags = { "fingers" },
		when = { district = "d8", minAge = 12, minYear = 1003, world = { era = "limbus" } },
		codex = "fn_lore_middle",
		choices = {
			{
				label = "Draw them a map",
				clash = { stat = "intelligence", foe = "A building that moves overnight", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 2, setFlags = { "fn_werner_helped", "fn_ricardo_seen" }, trigger = "fn_ricardo_sweeping", log = "You drew Werner a map of the parts of Hongyuan that hadn't moved in a week. He hugged you. The Big Brother nodded at you, which Werner said was a very big deal." },
				lose = { sanity = -1, setFlags = { "fn_ricardo_seen" }, trigger = "fn_ricardo_sweeping", log = "Your map was right this morning. By the afternoon the corridor had become a balcony. Werner thanked you anyway." },
			},
			{
				label = "Compliment the Big Brother's hair",
				clash = { stat = "charisma", foe = "Oswin's standards", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 40, 90 }, sanity = 3, setFlags = { "fn_ricardo_seen", "fn_ricardo_liked" }, trigger = "fn_ricardo_sweeping", log = "He turned from the window. \"Finally,\" he said. \"Someone in the east with eyes.\" He lectured you on the luscious and the bristly for ten minutes and tipped like a Wing." },
				lose = { sanity = -3, setFlags = { "fn_ricardo_seen" }, trigger = "fn_ricardo_sweeping", log = "\"Neat?\" he said. \"Neat?\" Werner hurried him away before he could reach for the Book." },
			},
			{
				label = "Insult his hair, to see what happens",
				hint = "Someone in Hongyuan holds the record: fifteen seconds.",
				result = inBook("He opened the Book before you'd finished the sentence and wrote, slowly, with trembling hands. \"Sixteen seconds,\" he said. \"Not a record. The record is fifteen.\" Werner looked at you with deep pity.", { "fn_ricardo_seen" }),
			},
		},
	},
	{
		id = "fn_ricardo_sweeping",
		title = "Three Waves and a Big Brother",
		text = "Past 3:13 that night, dance music thumps through your locked shutters, and then the Sweepers come. Across the street an inn has melted into something that isn't a home any more, and the waves pour into it. Through a gap in the shutters you watch a Big Brother of the Middle and his Siblings hold their ground beside a strange bus. Wave one. Wave two. Then the building beside them shifts.",
		weight = 0,
		when = { district = "d8" },
		codex = "city_sweepers",
		choices = {
			{
				label = "Keep watching through the gap",
				clash = { stat = "mind", foe = "The Night", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 5, setFlags = { "fn_ricardo_launched" }, codex = "fn_lore_ricardo", log = "The building rose at a slant and launched the Big Brother into the skyline. \"MARK MY WORDS,\" he roared, getting smaller, \"THIS IS ALSO GOING IN THE BOOKS!\" Below, Werner wailed, \"BIG BROOOOO!\" You laughed until the third wave passed." },
				lose = { sanity = -6, condition = "night_terrors", log = "Something in the second wave turned toward your shutters, and you stopped watching. You heard a voice go up and up into the sky, and someone wailing for his Big Bro." },
			},
			{
				label = "Get away from the window",
				result = { sanity = -2, log = "You lay on the floor until the third wave passed. In the morning the inn was gone, and four streets away a building had a dent in it the exact shape of a Big Brother." },
			},
			{
				label = "Let Werner in when he knocks",
				result = { sanity = 3, setFlags = { "fn_middle_favor", "fn_ricardo_launched" }, codex = "fn_lore_ricardo", log = "In the third wave someone knocked: Werner, separated from his Siblings, crying for his Big Bro. You let him in; opening your own door is no Taboo. The Middle, he told you at dawn, never forgets a door." },
			},
		},
	},

	-- ── anywhere, afterward ──
	{
		id = "fn_ricardo_rumor",
		title = "The Coupon Saga",
		text = "At the noodle stall a courier from the south is telling the story everyone has heard some version of: a Big Brother of the Middle whose salon coupon was stolen on the Great Lake, who chased the thieves across the City, held off the Sweepers, and was punched into the skyline by a building. The whole stall is laughing. A Little Sister at the next table is not.",
		weight = 4,
		once = true,
		tags = { "fingers" },
		when = { minAge = 12, minYear = 1004, world = { era = "limbus" }, notFlags = { "fn_ricardo_seen" } },
		codex = "fn_lore_book",
		choices = {
			{
				label = "Laugh along",
				clash = { stat = "mind", foe = "A Little Sister's hearing", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 4, log = "You laughed quietly enough. The Little Sister glared at the courier instead and wrote something down. Not your name. You checked." },
				lose = { sanity = -3, log = "The Little Sister caught your eye mid-laugh. You stopped laughing. She smiled, which was worse, and went back to her noodles." },
			},
			{
				label = "Keep a straight face",
				result = { mind = 2, sanity = 1, log = "You kept a perfectly straight face. The Little Sister noticed and nodded to you on her way out. Courtesy is something the Middle remembers too." },
			},
		},
	},
}
