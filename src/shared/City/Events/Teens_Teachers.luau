--[[
	Teens (tt_): a first teacher. Nobody in the City invents a way of fighting on their own.
	A discipline belongs to an Association, a Finger, a Wing, a lineage (Schools.luau), and a
	teenager gets one the way people really do: somebody who was trained there shows them the
	basics. `school = "<id>"` gives the school at mastery 1; past mastery 2 it's only taught
	inside the organisation, so a first teacher is also a first push toward a career.
	Every event needs `noStyle` (one teacher per life). Refusing is always an option, and a
	life with no discipline at eighteen is ordinary: most people in the City have none.
]]

return {
	{
		id = "tt_liu_gym",
		title = "The Gym With the Scorch Marks",
		art = "alley",
		text = "The gym under the laundry belongs to a man with burn scars to the elbows. He was Liu Association, South Section 5, until his knee went. He watches you hit the bag for a week before he says anything.",
		weight = 9,
		once = true,
		when = { noStyle = true, minAge = 13, maxAge = 17, side = "backstreets" },
		dialogue = { { who = "The gym owner", line = "You hit like you're angry at the bag. Liu doesn't hit angry. Liu hits together. Come back tomorrow." } },
		choices = {
			{ label = "Come back tomorrow", result = { school = "liu", health = 1, setFlags = { "knows_fixers" }, log = "He showed you how Liu moves: forward, with someone at your shoulder. The fire, he said, is Association property. Join if you want that." } },
			{ label = "Ask what it's like inside", result = { mind = 2, setFlags = { "knows_fixers" }, log = "He talked for an hour about Section 5: the heat, the jokes, the friends he buried. You listened to all of it." } },
			{ label = "Find another gym", result = { strength = 1, log = "You don't take orders from strangers. The other gym smelled worse and taught you less." } },
		},
	},
	{
		id = "tt_zwei_walk",
		title = "The Walk Home",
		art = "street",
		text = "An old woman in a faded blue coat walks the children of your street home before the Night. She was Zwei Association once. Tonight a man steps out of a doorway in front of her, and she doesn't slow down.",
		weight = 9,
		once = true,
		when = { noStyle = true, minAge = 12, maxAge = 16 },
		choices = {
			{ label = "Ask her how she did that", result = { school = "zwei", sanity = 1, setFlags = { "knows_fixers" }, log = "\"Feet,\" she said. \"It's all feet.\" She taught you to stand so that being hit was the other person's problem." } },
			{ label = "Walk at the back with her", result = { health = 2, mind = 1, log = "You took the back of the line all winter. Nobody stepped out of a doorway at you. You almost wished they would." } },
			{ label = "Thank her and go in", result = { sanity = 2, log = "You said thank you. She nodded once, the way people do who used to be paid for this." } },
		},
	},
	{
		id = "tt_lineage_bridge",
		title = "Under the Footbridge",
		art = "underpass",
		text = "A thin man sleeps under the footbridge with a long bundle wrapped in oilcloth. Every dawn he unwraps it and makes one cut in the air. Always the same cut. He has seen you watching.",
		weight = 6,
		once = true,
		when = { noStyle = true, minAge = 13, maxAge = 17 },
		dialogue = { { who = "The swordsman", line = "There were hundreds of us. Now it goes from one hand to the next, or it stops. Hold this. No. Lower." } },
		choices = {
			{
				label = "Hold the stick the way he shows you",
				clash = { stat = "mind", foe = "Your own breathing", coins = 1, base = 3, coinPower = 3 },
				win = { school = "blade_lineage", mind = 1, log = "One cut, a thousand times, with a stick. On the last morning he said the Blade Lineage would last one more lifetime, and left before you could answer." },
				lose = { mind = 1, sanity = -1, log = "You couldn't keep still long enough. He wrapped the bundle up again without a word." },
			},
			{ label = "Bring him something to eat", result = { sanity = 2, strength = 1, log = "You brought him bread. He ate half and left the rest on your step, wrapped in the same oilcloth." } },
			{ label = "Stop watching", result = { mind = 1, log = "Men with long bundles aren't your business. You took the other street for a month." } },
		},
	},
	{
		id = "tt_devyat_lodger",
		title = "The Lodger Upstairs",
		art = "home",
		text = "The room upstairs is rented by a courier in a red coat who is never home. Today she is, with her ankle in a splint and a parcel that has to be across the District by six.",
		weight = 8,
		once = true,
		when = { noStyle = true, minAge = 13, maxAge = 17 },
		choices = {
			{
				label = "Run it for her",
				clash = { stat = "health", foe = "The deadline", coins = 1, base = 3, coinPower = 3 },
				win = { school = "devyat", wage = { 10, 20 }, setFlags = { "knows_fixers" }, log = "You made it with a minute to spare. She paid you, and then she showed you how Devyat' gets through a crowd without touching it." },
				lose = { health = { -2, -1 }, wage = { 2, 5 }, setFlags = { "knows_fixers" }, log = "You were four minutes late. She went very quiet. Devyat' is never late, she said, and paid you anyway." },
			},
			{ label = "Ask what's in it", result = { mind = 2, log = "\"I don't know,\" she said. \"That's the job.\" She found somebody else to run it." } },
			{ label = "Close the door", result = { sanity = 1, log = "Not your parcel. You heard her on the stairs later, hopping." } },
		},
	},
	{
		id = "tt_dieci_reader",
		title = "A Key for a Book",
		art = "market",
		text = "A woman in a brown coat is buying every book the cart man has, and paying in keys. She says she's Dieci Association. She says she'll teach anyone who can tell her something she doesn't know.",
		weight = 7,
		once = true,
		when = { noStyle = true, minAge = 12, maxAge = 17 },
		choices = {
			{
				label = "Tell her something true about your street",
				clash = { stat = "intelligence", foe = "Everything she's read", coins = 1, base = 3, coinPower = 3 },
				win = { school = "dieci", intelligence = 1, setFlags = { "knows_fixers" }, log = "She hadn't known which stairwell floods. She wrote it down, and taught you how Dieci makes a fist around something it has learned." },
				lose = { intelligence = 1, log = "She already knew. She knew your street better than you did. She gave you a pamphlet out of pity." },
			},
			{ label = "Sell her your schoolbook", result = { money = 8, intelligence = -1, log = "She paid eight Ahn for a book you needed. You've regretted bigger things." } },
			{ label = "Keep walking", result = { mind = 1, log = "People who pay in keys want something. You kept walking." } },
		},
	},
	{
		id = "tt_seven_guide",
		title = "A Local Guide",
		art = "street",
		text = "A man in a grey suit has been asking the same three questions on your corner all morning. Seven Association, by the badge. He needs someone who knows which doors on this street have a back way out.",
		weight = 8,
		once = true,
		when = { noStyle = true, minAge = 13, maxAge = 17 },
		choices = {
			{ label = "Show him the back ways", result = { school = "seven", wage = { 8, 15 }, setFlags = { "knows_fixers" }, log = "You worked for him for a week. He paid by the day, and in the evenings he taught you to look at a person the way Seven does: for the weak place." } },
			{ label = "Send him the wrong way", result = { strength = 2, sanity = 1, log = "You sent him up a dead end. Whoever he was looking for owes you one and will never know it." } },
			{ label = "You don't know anything", result = { mind = 1, log = "\"I don't know\" is the safest sentence on your street. You said it three times." } },
		},
	},
	{
		id = "tt_kurokumo_corner",
		title = "The Dark Cloud on the Corner",
		art = "alley",
		text = "The Kurokumo Clan collects on your street on the first of the month. The Wakashu who does it is not much older than you, and bored. He has noticed you watching his sword hand.",
		weight = 8,
		once = true,
		when = { noStyle = true, minAge = 14, maxAge = 17, side = "backstreets" },
		dialogue = { { who = "The Wakashu", line = "You want to hold it. Everyone wants to hold it. Carry my bag for a month and I'll show you the draw." } },
		choices = {
			{ label = "Carry the bag", result = { school = "kurokumo", sanity = -2, setFlags = { "knows_syndicates" }, log = "You carried the bag. He showed you the draw. The shopkeepers stopped looking you in the eye, and that was part of the lesson too." } },
			{ label = "Say no, politely", result = { mind = 2, log = "You said no with your eyes down. He shrugged. The Clan has plenty of bag carriers." } },
			{ label = "Tell him what you think of the Clan", clash = { stat = "strength", foe = "A bored Wakashu", coins = 1, base = 4, coinPower = 3 },
				win = { strength = 3, sanity = 2, log = "He laughed, and then he stopped laughing, and then he left. He collects on the other side of the street now." },
				lose = { sanity = -3, mind = 1, log = "He didn't draw. He didn't need to. He looked at you until you looked down, and then he went on up the street." } },
		},
	},
	{
		id = "tt_cinq_second",
		title = "A Second for the Duel",
		art = "market",
		text = "Two people are going to settle a debt in the market square, the proper way. A Cinq Association duelist in a cape stands for one of them. Her second hasn't turned up, and the duel can't start without one.",
		weight = 7,
		once = true,
		when = { noStyle = true, minAge = 13, maxAge = 17 },
		choices = {
			{ label = "Step forward", result = { school = "cinq", sanity = 1, setFlags = { "knows_fixers" }, log = "You held her hat. It was over in one exchange. Afterward she showed you the stance, because a second ought to know what they're watching." } },
			{ label = "Watch from the crowd", result = { mind = 2, log = "You watched every step. You couldn't have said what you learned, only that you did." } },
			{ label = "Sell skewers to the crowd", result = { money = { 5, 14 }, intelligence = 1, log = "A duel draws a crowd, and a crowd gets hungry. You sold out before the first bow." } },
		},
	},
	{
		id = "tt_wcorp_coach",
		title = "The Youth League",
		art = "nest",
		text = "The Nest's youth league has a new coach: a W Corp Cleanup Agent on medical leave, who was told that children would be restful. She runs you until you can't feel your legs.",
		weight = 9,
		once = true,
		when = { noStyle = true, minAge = 12, maxAge = 16, side = "nest" },
		dialogue = { { who = "The coach", line = "Again. You have more than that. Everyone has more than that. Store it up, then spend it." } },
		choices = {
			{ label = "Store it up, then spend it", result = { school = "wcorp", health = 1, setFlags = { "knows_wings" }, log = "She taught you the Cleanup way: hold back, build, and let it all go at once. The charged gear, she said, stays on the train." } },
			{ label = "Ask what she cleans up", result = { mind = 1, sanity = -2, setFlags = { "knows_wings" }, log = "She looked at you for a long time. \"Carriages,\" she said. She didn't coach the next season." } },
			{ label = "Quit the league", result = { intelligence = 2, log = "You spent the season in the reading room instead. Your legs thanked you." } },
		},
	},
	{
		id = "tt_shi_tutor",
		title = "The Fencing Tutor",
		art = "nest",
		text = "Your family has hired a fencing tutor, as families here do. He is very quiet, very polite, and retired from the Shi Association, which nobody mentions at dinner.",
		weight = 8,
		once = true,
		when = { noStyle = true, minAge = 12, maxAge = 16, side = "nest" },
		choices = {
			{ label = "Take the lessons seriously", result = { school = "shi", mind = 1, setFlags = { "knows_fixers" }, log = "He taught you to wait. Most of fencing, it turned out, is waiting, and the rest is over before the other person knows." } },
			{ label = "Ask what he did before", result = { mind = 2, sanity = -1, log = "\"Contracts,\" he said, and corrected your grip. You didn't ask again." } },
			{ label = "Skip them", result = { strength = 1, sanity = 1, log = "You climbed out the window every Thursday. He never told your parents. He seemed to respect it." } },
		},
	},
}
