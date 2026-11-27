--[[
	YOUR DISTRICT: places you can only go because of where you live. Every Wing's District has
	its own: the Great Lake in U Corp's, the Time counters in T Corp's, the ampule clinics in
	K Corp's. Move, and the list changes with you.

	All of them are in the "district" category and gated by when.district. Risky ones are a
	clash with a win and a lose. Fields: see the activities in init.luau.
]]

local AFTER = { "library", "limbus" }

return {
	-- ════ District 4 · D Corp: an ordinary District, with an L Corp branch under it ════
	{
		id = "d4_office_row",
		category = "district",
		name = "Read the boards on Office Row",
		desc = "Forty small Fixer Offices on one street, and every one of them pins its odd jobs outside. Half an afternoon here is worth a season anywhere else.",
		minAge = 12,
		when = { district = "d4" },
		result = { intelligence = { 1, 2 }, charisma = { 0, 1 }, wage = { 4, 14 }, setFlags = { "knows_fixers" }, log = "You carried a ladder for one Office and a message for another, and learned what six of them charge." },
	},
	{
		id = "d4_listen_branch",
		category = "district",
		name = "Listen at the branch grating",
		desc = "There's a grating in the square that hums. Everyone knows what's under it. Nobody has seen the door.",
		minAge = 10,
		when = { district = "d4" },
		cooldown = 1,
		clash = { stat = "mind", foe = "What hums under District 4", coins = 2, base = 4, coinPower = 3 },
		win = { mind = { 2, 3 }, setFlags = { "knows_lcorp" }, log = "You lay with your ear on the iron for an hour. It isn't machinery. It's closer to breathing, and it's slow." },
		lose = { sanity = { -6, -3 }, log = "Something under the grating stopped humming while you were listening, as if it had noticed. You haven't been back." },
	},

	-- ════ District 7 · G Corp: built on the Smoke War ════
	{
		id = "d7_veterans",
		category = "district",
		name = "Sit with the Smoke War veterans",
		desc = "They keep a bench by the canal. They don't talk about the war, mostly. But they talk around it, and that teaches you things.",
		minAge = 10,
		when = { district = "d7" },
		result = { mind = { 1, 2 }, charisma = { 1, 2 }, sanity = { -1, 1 }, log = "An old woman showed you how to tell which way a street will run if you have to leave it in a hurry. She didn't say where she learned." },
	},
	{
		id = "d7_ruins",
		category = "district",
		name = "Pick through old G Corp's ruins",
		desc = "The old Wing's works are fenced, and the fence is mostly holes. There is still good metal in there. There is still other stuff in there, too.",
		minAge = 12,
		when = { district = "d7" },
		cooldown = 1,
		clash = { stat = "speed", foe = "What the war left in the ruins", coins = 2, base = 4, coinPower = 3 },
		win = { wage = { 14, 40 }, speed = { 1, 2 }, log = "A sack of copper fittings and a clean way out. Something clicked behind you the whole way, like too many legs on tile." },
		lose = { health = { -10, -5 }, sanity = -3, log = "You got out. Your sack didn't, and neither did the skin off one shin." },
	},

	-- ════ District 8 · H Corp: Hongyuan ════
	{
		id = "d8_bolus",
		category = "district",
		name = "Buy a Bolus from the apothecary",
		desc = "H Corp's medicine. One kind knits you up. The other kind, the apothecary says, should only be taken by people who are sure who they are.",
		minAge = 16,
		cost = 45,
		when = { district = "d8" },
		cooldown = 1,
		result = { health = { 10, 16 }, strength = { 0, 1 }, sanity = { -3, -1 }, log = "It tasted of iron and old tea. You felt wonderful for a week, and for a day in the middle of it you weren't quite sure whose hands those were." },
	},
	{
		id = "d8_daguanyuan",
		category = "district",
		name = "Walk the shifting halls",
		desc = "Hongyuan rearranges itself around fortune. Walk it with your eyes open and you learn who's rising, who's falling, and whose rooms got smaller overnight.",
		minAge = 10,
		when = { district = "d8" },
		result = { charisma = { 1, 2 }, intelligence = { 1, 2 }, luck = { 0, 1 }, log = "A corridor that was a courtyard yesterday. You learned three families' luck from the size of their doors." },
	},

	-- ════ District 11 · K Corp: ampules and checkpoints ════
	{
		id = "d11_ampule",
		category = "district",
		name = "Queue at the ampule clinic",
		desc = "K Corp's HP Ampules: one dose and the body remembers being whole. The queue is four hours. Nobody in it asks how the ampules are made.",
		minAge = 8,
		cost = 60,
		when = { district = "d11" },
		cooldown = 1,
		result = { health = { 22, 32 }, cure = "any", log = "A cold line up the arm, and then everything that hurt simply didn't. The nurse checked your face against a list before she let you leave." },
	},
	{
		id = "d11_checkpoint",
		category = "district",
		name = "Talk your way through a checkpoint",
		desc = "The drones read your face. The guards read everything else. Practice here and no gate in the City will worry you.",
		minAge = 12,
		when = { district = "d11" },
		clash = { stat = "charisma", foe = "K Corp checkpoint staff", coins = 2, base = 4, coinPower = 3 },
		win = { charisma = { 2, 3 }, rep = { wings = 3 }, log = "A nod, a first name, the right complaint about the weather. The barrier went up before you'd finished the sentence." },
		lose = { sanity = -3, money = { -20, -8 }, rep = { wings = -3 }, log = "A fine for loitering in a scanning zone. The drone followed you for two streets." },
	},

	-- ════ District 12 · L Corp, and after it the Library ════
	{
		id = "d12_visitor_floor",
		category = "district",
		name = "Tour the L Corp visitor floor",
		desc = "The Wing lets the public see one floor: a model of the tower, a film about clean energy, and a gift shop. Face the Fear, Build the Future.",
		minAge = 8,
		cost = 5,
		when = { district = "d12", world = { era = "wings" } },
		cooldown = 2,
		result = { intelligence = { 1, 2 }, sanity = { 0, 2 }, rep = { lcorp = 2 }, setFlags = { "knows_lcorp" }, log = "The film didn't say where the energy comes from. A man in a suit watched everyone watching it. You bought a pencil with the logo on." },
	},
	{
		id = "d12_scavenge",
		category = "district",
		name = "Scavenge the dark tower's edge",
		desc = "No Wing has claimed District 12. The ground around where L Corp stood is full of things that fell out of it, and some of them are worth money.",
		minAge = 14,
		when = { district = "d12", world = { era = AFTER } },
		cooldown = 1,
		clash = { stat = "luck", foe = "The ruins of District 12", coins = 1, base = 2, coinPower = 2, fixed = true },
		win = { wage = { 30, 90 }, luck = { 0, 1 }, log = "A green-stained canister, still sealed, and a badge with half a name. A man at the market paid for both without asking where." },
		lose = { health = { -8, -3 }, sanity = { -4, -2 }, log = "The thing you picked up was warm, and it had been waiting for someone to pick it up. You dropped it and ran." },
	},
	{
		id = "d12_watch_library",
		category = "district",
		name = "Watch who goes into the Library",
		desc = "From the last standing wall you can see its doors. Guests arrive in their best coats, holding their invitations like tickets.",
		minAge = 12,
		when = { district = "d12", world = { era = "library" } },
		cooldown = 1,
		result = { mind = { 1, 3 }, sanity = { -3, -1 }, setFlags = { "saw_the_library" }, log = "Eleven went in today. You counted. You stayed until the lamps came on, and you didn't count anyone coming out." },
	},

	-- ════ District 14 · N Corp: Canned Experience ════
	{
		id = "d14_canned",
		category = "district",
		name = "Open a can of Experience",
		desc = "N Corp tins what other people have lived. A year of carpentry. A summer by a sea you've never seen. It keeps, and it isn't yours.",
		minAge = 14,
		cost = 50,
		when = { district = "d14" },
		cooldown = 1,
		result = { intelligence = { 2, 4 }, sanity = { -4, -2 }, log = "For an afternoon you knew how to plane a door, and you missed a workshop you've never stood in. The knowing stayed. So did a little of the missing." },
	},
	{
		id = "d14_butter_street",
		category = "district",
		name = "Keep your head down on Butter Street",
		desc = "The Nail and the Hammer come down this street looking for impurity. The people who live here have a way of being overlooked, and it can be learned.",
		minAge = 8,
		when = { district = "d14" },
		result = { mind = { 1, 2 }, speed = { 0, 1 }, sanity = { 0, 2 }, log = "Eyes on your shoes, hands where they can be seen, and never the first or the last through a door. They walked past you twice." },
	},

	-- ════ District 16 · P Corp: bending spires ════
	{
		id = "d16_spires",
		category = "district",
		name = "Climb a bending spire",
		desc = "P Corp's buildings fold like rubber and can't fall down. The view from the top moves. Children here race up them.",
		minAge = 10,
		when = { district = "d16" },
		clash = { stat = "speed", foe = "A spire that bends", coins = 2, base = 4, coinPower = 3 },
		win = { speed = { 2, 3 }, sanity = { 1, 3 }, log = "It leaned out over the next street with you on it and leaned back. From the top, you could see four Districts and the Lake." },
		lose = { health = { -7, -3 }, sanity = -2, log = "The stair you were on was somewhere else when your foot came down. It doesn't break you. It does bruise." },
	},
	{
		id = "d16_street_fair",
		category = "district",
		name = "Find tonight's street",
		desc = "Some nights the streets here aren't where you left them, and a fair turns up on one that wasn't there. Finding it is half luck and half asking.",
		minAge = 8,
		when = { district = "d16" },
		cooldown = 1,
		result = { luck = { 0, 2 }, charisma = { 1, 2 }, sanity = { 2, 4 }, money = { -8, -2 }, log = "Lanterns, a carousel of iron horses, a woman selling maps that are only right until morning. You bought one anyway." },
	},

	-- ════ District 18 · R Corp: armies for hire ════
	{
		id = "d18_recruit_course",
		category = "district",
		name = "Run the recruits' course",
		desc = "The Fourth Pack leaves its training yard open on rest days, to see who turns up. Walls, wire, a pit. A sergeant with a stopwatch pretends not to watch.",
		minAge = 13,
		when = { district = "d18" },
		clash = { stat = "speed", foe = "The Fourth Pack's course", coins = 2, base = 5, coinPower = 3 },
		win = { speed = { 2, 3 }, strength = { 1, 2 }, rep = { wings = 2 }, log = "You came in under the recruits' time. The sergeant wrote something down and didn't tell you what." },
		lose = { health = { -6, -2 }, strength = { 0, 1 }, log = "You went off the wall at the top. The sergeant said most people do, the first time, and that the first time is free." },
	},
	{
		id = "d18_march_out",
		category = "district",
		name = "Watch a Pack march out",
		desc = "They go by the thousand, in step, Rabbits and Reindeer and Rhinos. The whole District lines the road. Fewer come back, and those come back quietly.",
		minAge = 6,
		when = { district = "d18" },
		cooldown = 1,
		result = { mind = { 1, 2 }, sanity = { -2, 1 }, setFlags = { "knows_wings" }, log = "You counted ranks until you lost the number. A woman next to you was counting too, for one face in particular." },
	},

	-- ════ District 19 · S Corp: a King, a Court, and fields ════
	{
		id = "d19_harvest",
		category = "district",
		name = "Work the harvest",
		desc = "S Corp feeds half the City. At harvest every hand in the Backstreets is hired, paid by the basket, and watched by a retainer on a horse.",
		minAge = 10,
		when = { district = "d19" },
		result = { strength = { 1, 3 }, health = { 0, 1 }, wage = { 8, 22 }, log = "Twelve baskets by sundown. The retainer rode past and tapped your shoulder with his crop, which here means well done." },
	},
	{
		id = "d19_blade_drill",
		category = "district",
		name = "Watch the old swordsmen drill",
		desc = "The Blade Lineage started in these Backstreets. A few of its old hands still practice in a walled yard at dawn, and they don't chase children off the wall.",
		minAge = 8,
		when = { district = "d19" },
		result = { speed = { 1, 2 }, mind = { 1, 2 }, log = "One cut, a hundred times, and every time the same. You went home and tried it with a broom until someone told you to stop." },
	},

	-- ════ District 20 · T Corp: time, sold and taxed ════
	{
		id = "d20_sell_time",
		category = "district",
		name = "Sell a month at the Time counter",
		desc = "T Corp buys time. You sit in a chair, a clerk turns a dial, and you stand up with money in your hand and a month you won't get back.",
		minAge = 16,
		when = { district = "d20" },
		cooldown = 1,
		result = { money = { 70, 130 }, health = { -4, -2 }, sanity = -2, log = "It didn't hurt. You were simply a little more tired, afterwards, than someone your age should be. The clerk said most people come back." },
	},
	{
		id = "d20_colour",
		category = "district",
		name = "Stand at the edge of the Nest and look at the color",
		desc = "The Nest here is grey. Color is a privilege T Corp sells. From one footbridge in the Backstreets you can see a single red awning, and people queue to stand there.",
		minAge = 6,
		when = { district = "d20" },
		result = { sanity = { 2, 5 }, mind = { 0, 1 }, log = "Red. You'd forgotten how loud it is. You stood there until the man behind you coughed." },
	},

	-- ════ District 21 · U Corp: the Great Lake ════
	{
		id = "d21_great_lake",
		category = "district",
		name = "Go out on the Great Lake",
		desc = "A day boat from the Backstreets docks, out past the buoys where the water goes dark. The whalers say the Lake is bigger than the City. They say other things about it too.",
		minAge = 10,
		cost = 8,
		when = { district = "d21" },
		cooldown = 1,
		clash = { stat = "health", foe = "The Great Lake", coins = 2, base = 4, coinPower = 3 },
		win = { health = { 1, 3 }, sanity = { 3, 6 }, luck = { 0, 1 }, log = "No walls, in any direction. Something very large passed under the boat and kept going, and the old man at the tiller touched his cap to it." },
		lose = { health = { -9, -4 }, sanity = { -4, -2 }, log = "The weather came down in a minute. You bailed with your hat for three hours, and the Lake kept the oar." },
	},
	{
		id = "d21_whaler_deck",
		category = "district",
		name = "Sign on for a day on a whaler",
		desc = "The whalers will take anyone who can pull a rope. Day wage, a share if the hunt comes off, and no questions if it doesn't.",
		minAge = 14,
		when = { district = "d21" },
		cooldown = 1,
		clash = { stat = "strength", foe = "A day's work on a whaler", coins = 2, base = 5, coinPower = 3 },
		win = { strength = { 2, 3 }, wage = { 20, 55 }, rep = { rats = 2 }, log = "You held the line when the thing ran. The harpooner bought you supper and showed you the scar the last one left him." },
		lose = { health = { -10, -5 }, wage = { 4, 10 }, log = "The line took the skin off both palms. They paid you for the day anyway, in small coins, and put you ashore." },
	},
	{
		id = "d21_portship",
		category = "district",
		name = "Watch the Stingray Portship dock",
		desc = "U Corp's rich arrive by Portship: a floating Nest with its own weather. You can watch it come in from the fish market, if you don't mind the smell.",
		minAge = 6,
		when = { district = "d21" },
		result = { charisma = { 0, 1 }, intelligence = { 1, 2 }, sanity = { 1, 3 }, log = "Gangways came down like drawbridges. Someone on the top deck dropped a glove, and three men in the market fought over it." },
	},

	-- ════ District 23 · W Corp: the WARP trains ════
	{
		id = "d23_platform",
		category = "district",
		name = "Watch the WARP platform",
		desc = "Across the City in seconds. The passengers step off bright and rested. The cleanup crews go in afterwards with the blinds down, and come out grey.",
		minAge = 8,
		when = { district = "d23" },
		result = { mind = { 1, 2 }, intelligence = { 0, 1 }, sanity = { -2, 0 }, setFlags = { "knows_wings" }, log = "You watched nine trains. Every passenger smiled the same smile, getting off, as if they'd all slept well in the same bed." },
	},
	{
		id = "d23_streets_of_flavor",
		category = "district",
		name = "Eat on the Streets of Flavor",
		desc = "The best food in the City, and a reputation nobody will explain to you. The rule the locals give is: eat at the stalls with a queue, and never ask what's special today.",
		minAge = 10,
		cost = 12,
		when = { district = "d23" },
		cooldown = 1,
		clash = { stat = "luck", foe = "Choosing a stall on the Streets of Flavor", coins = 1, base = 1, coinPower = 2, fixed = true },
		win = { sanity = { 4, 7 }, health = { 1, 3 }, charisma = { 0, 1 }, log = "Dumplings you'll think about for years. The cook asked where you were from and seemed pleased it was nearby." },
		lose = { sanity = { -5, -2 }, health = { -3, -1 }, log = "The stall had no queue, and you found out why about halfway through the bowl. You left the money on the counter and didn't run until the corner." },
	},
}
