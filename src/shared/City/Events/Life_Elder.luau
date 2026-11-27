--[[
	Elder life (area A): retirement, grandchildren, what you leave behind, the street that
	changed, and a last good day. Several scenes look back at a life's own flags: the bread
	girl, Auntie Mun's broth, a Night survived, the White Nights.
]]

return {
	{
		id = "bs_e_retire",
		title = "Hanging Up the Apron",
		text = "Your hands have started to tell you things in the mornings, and none of it is good news. The younger people at work have stopped asking whether you need help, and started just helping. Somebody, gently, has asked whether you've thought about stopping.",
		weight = 10,
		once = true,
		when = { anyCareer = true, minAge = 60, maxAge = 78 },
		choices = {
			{
				label = "Retire, and sleep past dawn for once",
				result = { quitCareer = true, sanity = 5, health = 2, log = "You stopped. The first morning, you woke at the usual time out of habit, and lay there listening to the street, and went back to sleep. It was the most luxurious thing you had ever done." },
			},
			{
				label = "Hand everything to a younger one, and teach them",
				result = { quitCareer = true, sanity = 4, intelligence = 1, log = "You chose your successor carefully and spent your last season teaching them everything, including the things nobody writes down. On your last day they gave you a cake shaped very badly like your workplace. You kept a piece in a tin for a year." },
			},
			{
				label = "Keep working: work is what keeps you going",
				result = { health = -2, sanity = 2, log = "\"I'll stop when I'm dead,\" you said, and went back to work, slower, prouder, and much more critical of everyone else's technique." },
			},
		},
	},
	{
		id = "bs_e_grandchildren",
		title = "Grandchildren",
		text = "{child}'s children come to visit: three of them, loud, sticky, and convinced that you are the oldest and most interesting person alive. The smallest has climbed into your lap and is demanding a story, \"a true one, from the old days, a scary one but not too scary.\"",
		weight = 10,
		once = true,
		when = { hasRelation = "child", minAge = 58, maxAge = 92 },
		choices = {
			{
				label = "Teach them the rule",
				result = { sanity = 5, relationBond = { kind = "child", amount = 6 }, log = "You taught them the rule the way it was taught to you: three locks, home before three, and nobody gets left outside. The smallest made you say it eleven times. Then all three said it together, very loud, and you laughed until you had to sit down." },
			},
			{
				label = "Tell them a true story",
				result = { sanity = 4, mind = 1, log = "You told them a true story from when you were small, with the scary parts made smaller and the funny parts made bigger. By the end, they wanted it again. You told it again. It got a little better each time, which is how old stories work." },
			},
			{
				label = "Give the smallest your old key on a string",
				requires = { hasGear = "bs_house_key" },
				result = { loseGear = "bs_house_key", sanity = 6, log = "You took the key on a string from around your neck and put it around the smallest one's neck. \"Home before three,\" you said. The child held it in both hands like the most important thing in the City, which, that afternoon, it was." },
			},
		},
	},
	{
		id = "bs_e_what_you_leave",
		title = "What You Leave",
		text = "You've started thinking about what happens to your things when you're gone: the savings in the tin, the tools, the recipes in your head, the routes, the names of who to trust on your street. {child} says not to be morbid. You say you're being practical. You're both a little right.",
		weight = 9,
		once = true,
		when = { hasRelation = "child", minAge = 62, maxAge = 92 },
		choices = {
			{
				label = "Write everything down for {child}",
				result = { intelligence = 2, sanity = 4, relationBond = { kind = "child", amount = 8 }, log = "You wrote it all down in a notebook over a whole winter: recipes, routes, which landlord lies, which Syndicate collector has a sick mother, which stair creaks. You gave it to {child}, who read it in one night and called you at two in the morning, crying a little." },
			},
			{
				label = "Leave something to the academy on the corner",
				requires = { min = { money = 100 } },
				result = { money = -100, sanity = 5, log = "You left a hundred Ahn to the academy on the corner, for chalk and for one kid a year who can't pay. They put your name on a little card by the door. Nobody you know reads it. You don't mind." },
			},
			{
				label = "Tell {child} the things you never said",
				result = { sanity = 6, relationBond = { kind = "child", amount = 12 }, log = "You told {child} the things you'd never said out loud, at the kitchen table, slowly. Neither of you remembers exactly what was said. You both remember that it was said." },
			},
		},
	},
	{
		id = "bs_e_three_good_days",
		title = "Three Good Days",
		text = "Some evening light through the window reminds you of it again: the White Nights, when the light came out of the L Corp tower and covered the City, and for a few days nobody died, and people walked outside at three in the morning and laughed. Then the light went strange. A child on your street is asking you what it was like.",
		weight = 10,
		once = true,
		when = { flags = { "saw_white_nights" }, minAge = 50 },
		codex = "city_white_nights",
		choices = {
			{
				label = "Tell them about the good days",
				result = { sanity = 5, log = "You told them about the good days: strangers hugging in the street, the Night that didn't come, a Thumb Soldato giving away his coat. The child didn't believe a word of it. You didn't blame them. You'd seen it, and you barely did." },
			},
			{
				label = "Tell them about the days after",
				result = { mind = 2, sanity = -2, log = "You told them, carefully, about the days after: the light going wrong, the tower going dark, the City not knowing what it was anymore. The child listened very seriously. \"Will it happen again?\" \"No,\" you said. You hoped it was true." },
			},
		},
	},
	{
		id = "bs_e_awake_313",
		title = "Awake at 3:13",
		text = "You wake up in the night, the way old people do, and look at the clock: 3:13. The floor begins to hum, faintly, the way it has every night of your life. Outside, the crowd begins to walk. You lie in the dark and listen, and notice, with some surprise, that you aren't afraid of it anymore.",
		weight = 9,
		once = true,
		tags = { "night" },
		when = { side = "backstreets", minAge = 65 },
		choices = {
			{
				label = "Listen to all three waves",
				result = { sanity = 4, mind = 1, log = "You listened to all three waves, the way you did as a child, counting. One. Quiet. Two. Quiet. Three. Then the birds, the first ones, the brave ones. You fell asleep smiling, which you would never have expected." },
			},
			{
				label = "Get up and check the locks, one more time",
				result = { sanity = 2, log = "You got up and checked the locks: one, two, three, all locked, as they had been every night for seventy years. You went back to bed. Some habits are not habits. They're prayers." },
			},
		},
	},
	{
		id = "bs_e_teahouse",
		title = "The Old Folks' Table",
		text = "There's a table at the back of the tea house where the old people of your street sit every afternoon: a board game with chipped pieces, very strong tea, and gossip so detailed that the neighborhood watch occasionally comes to consult it. Today there's an empty chair, and they've saved it for you.",
		weight = 9,
		once = true,
		when = { minAge = 62 },
		choices = {
			{
				label = "Sit and play",
				result = { sanity = 5, log = "You sat and played and lost and gossiped and won and argued about a move from forty years ago. You came back every afternoon. It was, you realized after a month, the best company you'd ever had." },
			},
			{
				label = "Bring the gossip up to date",
				result = { sanity = 4, mind = 1, log = "You brought news from the bathhouse, the clinic and the market, and were immediately the most valuable person at the table. By the end of the week, you knew everything about everyone on the street, including several things that hadn't happened yet." },
			},
		},
	},
	{
		id = "bs_e_names_in_paper",
		title = "The Names in the Paper",
		text = "These days you read the back pages of the paper first, the list of names. Most weeks you know one or two. This week you know four, and one of them is a kid you used to play Sweepers and Sleepers with in the street, seventy years ago, who you haven't thought about in fifty.",
		weight = 8,
		once = true,
		when = { minAge = 68 },
		choices = {
			{
				label = "Go to the farewell",
				result = { sanity = 2, mind = 1, log = "You went. There were six people there, and you were the only one who'd known the kid in the street. You told the family about the game, and the doorway behind the laundry. They hadn't known. They thanked you for giving them something they hadn't had." },
			},
			{
				label = "Cut out the name and keep it",
				result = { sanity = 1, intelligence = 1, log = "You cut out the name and put it in the tin with the others. The tin was getting full. You looked at it for a while, and then made tea, and decided that a full tin was a life with a lot of people in it." },
			},
		},
	},
	{
		id = "bs_e_stairs",
		title = "Five Floors",
		text = "Your flat is on the fifth floor, and the stairs, which never used to be anything, have become the main event of your day. Going down takes you ten minutes. Coming up takes twenty, and a rest on the third landing. The landlord has a ground-floor room coming free.",
		weight = 9,
		once = true,
		when = { minAge = 70 },
		choices = {
			{
				label = "Take the ground-floor room",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 2, health = 2, log = "You moved down. You missed the view, and the roof, and the pigeons. You gained a window onto the street, and now everyone who passes says good morning, and you know everyone's business by noon. It was, on balance, an improvement." },
			},
			{
				label = "Keep climbing",
				hint = "Health check.",
				clash = { stat = "health", foe = "Five floors of stairs", coins = 2, base = 3, coinPower = 2 },
				win = { health = 2, sanity = 2, log = "You kept climbing, out of pure stubbornness, and your legs kept up, out of pure surprise. The neighbors started timing you. You got slower and prouder every year." },
				lose = { condition = "bs_bad_back", sanity = -1, log = "You kept climbing until the day you sat down on the third landing and couldn't get up for an hour. A neighbor carried your shopping. After that, everybody carried your shopping, and you let them." },
			},
		},
	},
	{
		id = "bs_e_street_changed",
		title = "The Street You Grew Up On",
		text = "You go back to the street where you grew up, for no particular reason. It's changed: the laundry's a Workshop now, the academy on the corner has a new sign, a Syndicate you've never heard of has its name over the bathhouse. But the bakery is still there, and its step, and a thin child sitting on it, watching people go in and out.",
		weight = 9,
		once = true,
		when = { side = "backstreets", minAge = 60 },
		choices = {
			{
				label = "Buy two buns and give the child one",
				result = { sanity = 6, log = "You bought two sweet buns and sat on the step and gave the child one. The child ate it in four bites and watched you eat yours like it was a show. You thought about a girl called Bori for the rest of the day." },
			},
			{
				label = "Walk the old shortcuts",
				result = { sanity = 3, mind = 1, log = "You walked the old shortcuts, slowly: the gap behind the bathhouse, the stair that cuts two streets, the doorway behind the laundry vent, still there. Your legs were slower. The street was the same street, underneath." },
			},
		},
	},
	{
		id = "bs_e_clinic_knows",
		title = "The Clinic Knows Your Name",
		text = "The clinic down the street has been run by three doctors in your lifetime, and you've been a patient of all of them. The new one is the grandchild of the first. She knows your whole history from the old patient books: every stitch, every fever, every year. \"You're our longest patient,\" she says. \"That deserves a discount.\"",
		weight = 9,
		once = true,
		when = { minAge = 65 },
		choices = {
			{
				label = "Let her look you over",
				result = { health = { 6, 12 }, cure = "any", sanity = 2, log = "She looked you over, fixed what she could, and wrote it all in the old book under her grandmother's handwriting. On the way out she said you'd outlive her. You told her that was the plan." },
			},
			{
				label = "Tell her about her grandmother",
				result = { sanity = 4, log = "You told her about her grandmother, who once stitched your knee at the kitchen table at two in the morning, and who swore so creatively that you'd learned three new words. The new doctor laughed until she cried. She'd never known that." },
			},
		},
	},
	{
		id = "bs_e_broth",
		title = "Auntie Mun's Broth",
		text = "Auntie Mun is long gone, but you still make her broth, from memory, the way she taught you or the way you watched her. A young neighbor has smelled it through the wall and knocked, very shyly, to ask what it is. She's eleven, thin, and looks hungry, and nosy.",
		weight = 10,
		once = true,
		when = { flags = { "bs_knows_mun" }, minAge = 58 },
		choices = {
			{
				label = "\"Hungry, or nosy?\"",
				result = { sanity = 7, log = "\"Both,\" she said. You fed her a bowl and then showed her how it's done: bones for two days, the secret, and closing time at one, sharp. She came back the next week, and the next. You realized you were Auntie Mun now. It was the best thing that had ever happened to you." },
			},
			{
				label = "Give her a bowl and the recipe",
				result = { sanity = 5, intelligence = 1, log = "You gave her a bowl and wrote the recipe out for her in your best handwriting, including the secret, which you had never once written down. She took it home in both hands like an offering." },
			},
		},
	},
	{
		id = "bs_e_night_story",
		title = "The Night You Walked Home",
		text = "The kids on your street have heard that you were caught outside during the Night, once, and walked home at dawn. They've been daring each other for a week to ask you about it. Finally, the bravest one does: \"What did they say to you? The Sweepers. What did they say?\"",
		weight = 10,
		once = true,
		when = { flags = { "bs_night_survivor" }, minAge = 50 },
		codex = "bs_lore_sweepers",
		choices = {
			{
				label = "Tell them the truth",
				result = { mind = 2, sanity = 1, log = "\"They said they were sweeping,\" you said, \"and that they wouldn't stop.\" The kids waited for more. \"That's all. They don't care about you. That's the scariest part.\" Every one of them was home by two that night. Their mothers thanked you." },
			},
			{
				label = "\"Be home before three, and you'll never have to find out.\"",
				result = { sanity = 3, log = "You looked at each of them in turn and said it, the old rule, in the voice your own family used. They were disappointed, and then, walking home at one, very glad." },
			},
		},
	},
	{
		id = "bs_e_last_good_day",
		title = "A Last Good Day",
		text = "You wake up and everything is easy, for once: your knees, your breath, the light on the wall. It's one of those days old people get sometimes, nobody knows why. You have a whole day, and nothing you have to do with it.",
		weight = 12,
		once = true,
		when = { minAge = 74 },
		choices = {
			{
				label = "Eat noodles at the old stall",
				result = { sanity = 8, health = 1, log = "You went to the noodle stall on the corner, the one that's been there since before you were born, and ate slowly, extra scallions, and talked to the cook about nothing at all until it was time to go home before three. It was a perfect day." },
			},
			{
				label = "Sit on the roof and watch the City",
				result = { sanity = 8, mind = 1, log = "You climbed to the roof, which took a while, and sat among the pigeon lofts all afternoon watching the WARP trains cross the sky and the Backstreets light up window by window. It was the same view you'd had as a child. It was still the most beautiful thing you'd ever seen, and it was still free." },
			},
			{
				label = "Visit everyone you love",
				requires = { hasRelation = { "child", "sibling", "friend", "mother", "father" } },
				result = { sanity = 9, relationBond = { kind = "all", amount = 10 }, log = "You visited everyone, one by one, all day, and didn't tell any of them why. You didn't know why yourself. You just wanted to see their faces. You were home by two, with every lock checked, and you slept very well." },
			},
		},
	},
}
