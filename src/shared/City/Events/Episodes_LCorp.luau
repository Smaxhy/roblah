--[[
	EPISODES: Lobotomy Corporation, alive and buried (v0.13). See City/Episodes.luau.
	  ep_intercom          after the fall: a branch's intercom still pages an agent who never
	                       clocked out on the last day
	  ep_sealed_unit       after the fall: a containment unit behind a flooded wall, and the
	                       four kinds of work
	  ep_agent_next_door   the Age of L Corp: the neighbor who works for the Wing
	  ep_energy_crates     the Age of L Corp: an energy freight truck on its side
	Canon: L Corp powered the City with Enkephalin drawn from Abnormalities through Instinct,
	Insight, Attachment and Repression work; a Qliphoth counter falling to 0 meant a breach;
	risk classes ran ZAYIN to ALEPH; its branches were buried when it fell [Lobotomy
	Corporation, LoR, Limbus]. Every person and every unit here is this game's own.
]]

local function check(stat: string, foe: string, base: number?)
	return { stat = stat, foe = foe, coins = 2, base = base or 4, coinPower = 3 }
end

return {
	-- ══ The Voice in the Intercom ═════════════════════════════════════════════
	{
		id = "ep_ic_1",
		episode = "ep_intercom",
		step = 1,
		title = "A Page in the Wall",
		text = "At ten past two every night, a voice comes through the vent above your bed: calm, polite, a little tinny. \"Agent Mirela Voss, please report to the Welfare Team. Agent Voss, your work order is waiting.\" Nobody in your building is called Voss. The building went up after the Light, on top of something older.",
		weight = 3,
		once = true,
		tags = { "strange", "lcorp" },
		when = { minAge = 14, world = { era = { "library", "limbus" } } },
		choices = {
			{ label = "Follow the voice down", hint = "Down past the boiler, where it's louder.", result = { trigger = "ep_ic_2", log = "You took a torch and the building's spare keys, and went down past the boiler room, where the voice was louder." } },
			{ label = "Tape over the vent", result = { sanity = 1, episodeEnd = "You taped over the vent and never found out who was being paged.", log = "Three layers of tape. The voice still comes through, a little quieter, at ten past two." } },
			{ label = "Tell the landlord", result = { money = 40, episodeEnd = "The landlord had the vent welded shut.", log = "The landlord had the vent welded shut and knocked a little off your rent for the trouble, which is the most generous thing anyone in the building has ever seen him do." } },
		},
	},
	{
		id = "ep_ic_2",
		episode = "ep_intercom",
		step = 2,
		when = { world = { era = { "library", "limbus" } } },
		title = "The Hatch Behind the Boiler",
		scene = { set = "facility", kicker = "Behind the boiler", line = "A ladder down into green light. At the bottom, a terminal still running.", voice = "narrator" },
		text = "Behind the boiler, under a sheet of rust, is a hatch with the old L Corp emblem stamped into it, and a plate: BRANCH FACILITY · WELFARE TEAM · MAINTENANCE ACCESS. A ladder goes down into green emergency light. At the bottom a terminal is still running, with one employee file open: Agent Mirela Voss. Status: ON SHIFT. The shift began on the old L Corp's last day.",
		weight = 0,
		tags = { "strange", "lcorp" },
		choices = {
			{
				label = "Read the whole file",
				clash = check("intelligence", "Twenty years of corrupted records", 3),
				win = { intelligence = { 1, 2 }, setFlags = { "ic_read" }, trigger = "ep_ic_3", log = "Mirela Voss: Welfare Team, three years' service, commended twice for calm under pressure. Last work order: Attachment work, ZAYIN unit, ten minutes. Never logged as finished." },
				lose = { sanity = -3, trigger = "ep_ic_3", log = "Most of the file is noise now. One line comes through clean, over and over: AGENT VOSS, PLEASE CONFIRM TODAY'S WORK." },
			},
			{ label = "Answer the page", hint = "\"Agent Voss reporting.\"", result = { mind = 1, sanity = -2, setFlags = { "ic_answered" }, trigger = "ep_ic_3", log = "You leaned into the terminal's microphone and said it. The green light brightened all down the corridor, like a building waking up." } },
			{ label = "Pull the plug", result = { money = { 80, 160 }, sanity = -1, episodeEnd = "You pulled the plug on a terminal that had waited twenty years. The paging stopped.", log = "The boards and the copper sold well. The paging stopped. Some nights, at ten past two, you still listen for it." } },
		},
	},
	{
		id = "ep_ic_3",
		episode = "ep_intercom",
		step = 3,
		when = { world = { era = { "library", "limbus" } } },
		title = "Today's Work",
		text = "The cursor blinks: AGENT VOSS, PLEASE CONFIRM TODAY'S WORK. Down the hall, past a door that no longer closes, is a containment unit with a ZAYIN plate. Nothing is inside it that you can see. The work order says: Attachment work, ten minutes.",
		weight = 0,
		tags = { "strange", "lcorp" },
		choices = {
			{
				label = "Do the work",
				hint = "Ten minutes, with whatever is in there.",
				clash = check("mind", "An empty room that is listening", 4),
				win = { trigger = "ep_ic_4", log = "You sat by the empty unit and talked to nothing about the weather, the neighbors, the noodle place on the corner. Ten minutes exactly." },
				lose = { sanity = -5, trigger = "ep_ic_4", log = "Halfway through, something in the empty unit started talking back in your own voice. You stayed the ten minutes anyway." },
			},
			{ label = "Log Agent Voss out", hint = "Type SHIFT ENDED.", result = { sanity = 4, gear = "ep_voss_badge", episodeEnd = "You clocked out Agent Mirela Voss, twenty years late.", log = "The terminal said THANK YOU FOR YOUR WORK TODAY and turned itself off. In the drawer under it was a Welfare Team badge with a photograph of a tired, kind face." } },
			{ label = "Take the core to Hana", hint = "The Hana Association pays for records of the old L Corp.", result = { money = { 400, 700 }, renown = 4, sanity = -2, episodeEnd = "Hana's archivists took the core and the file, and paid well.", log = "Hana's archivists took the terminal's core in a padded case. Somewhere far away, someone with a clerk's patience is reading about Agent Voss tonight." } },
		},
	},
	{
		id = "ep_ic_4",
		episode = "ep_intercom",
		step = 4,
		when = { world = { era = { "library", "limbus" } } },
		title = "Thank You for Your Work Today",
		text = "When you come back, the screen says: WORK RESULT: GOOD. ENERGY COLLECTED: 0. THANK YOU, AGENT VOSS. Then, smaller, as if typed by a hand and not a machine: Is it over? Did we do it? Behind you, something in the empty unit settles, like a held breath let go.",
		weight = 0,
		tags = { "strange", "lcorp" },
		choices = {
			{ label = "Type: It's over.", result = { sanity = 6, mind = 2, gear = "ep_voss_badge", episodeEnd = "You told the facility it was over. The lights went out floor by floor.", log = "The green light went out floor by floor, very slowly, like someone walking through the building turning off lamps. The badge in the drawer was warm." } },
			{ label = "Type: Not yet.", hint = "Keep the shift going. You'd be the one it pages.", result = { mind = 3, sanity = -4, limitBreak = { mind = 5 }, setFlags = { "ic_kept_shift" }, episodeEnd = "You told it not yet. Now it pages you, at ten past two.", log = "Now the voice pages you, by name, at ten past two. You go down most nights and do ten minutes of work for no one. You don't know why it helps. It does." } },
		},
	},

	-- ══ The Sealed Unit ═══════════════════════════════════════════════════════
	{
		id = "ep_su_1",
		episode = "ep_sealed_unit",
		step = 1,
		title = "A Plate That Reads TETH",
		text = "The spring floods took out a wall in the canal tunnels, and behind it is a corridor nobody has walked since the old L Corp fell. The salvagers who found it came back up without their foreman. Now they're selling the map for 200 Ahn to anyone who wants to see what's down there: a containment unit, door still sealed, with a plate that reads TETH.",
		weight = 3,
		once = true,
		tags = { "strange", "lcorp", "danger" },
		when = { minAge = 18, world = { era = { "library", "limbus" } } },
		choices = {
			{ label = "Buy the map", requires = { min = { money = 200 } }, result = { money = -200, trigger = "ep_su_2", log = "The map was drawn on the back of a noodle menu. It was very accurate." } },
			{ label = "Ask what happened to the foreman", result = { sanity = -1, intelligence = 1, episodeEnd = "You asked about the foreman, and decided you'd heard enough.", log = "The foreman went in to see what was behind the glass. The salvagers waited an hour, then sealed the tunnel with planks and left. Nobody has gone back for him." } },
			{ label = "Tell the Hana Association", result = { renown = 3, money = 60, rep = { fixers = 3 }, episodeEnd = "Hana sealed the tunnel again, with a better wall.", log = "Hana sent a team and a cordon. By morning the tunnel had a new wall, a warning painted on it, and a small reward for you in an envelope." } },
		},
	},
	{
		id = "ep_su_2",
		episode = "ep_sealed_unit",
		step = 2,
		when = { world = { era = { "library", "limbus" } } },
		title = "The Counter",
		scene = { set = "facility", kicker = "The canal tunnels", other = { name = "The thing in the TETH unit", foe = "abnormality" }, line = "It turns toward the glass when you step close.", voice = "narrator" },
		text = "The door is sealed, but the observation window still works. Inside, in red light, something sits very still in a corner, about the size of a coat hung on a hook. When you step close to the glass, it turns toward you. Beside the door a work panel is still lit: INSTINCT · INSIGHT · ATTACHMENT · REPRESSION. Above it, a counter reads 1.",
		weight = 0,
		tags = { "strange", "lcorp", "danger" },
		choices = {
			{ label = "Insight work: clean the unit", hint = "Careful, methodical. Intelligence.", clash = check("intelligence", "A unit with rules nobody wrote down", 5), win = { trigger = "ep_su_3", log = "You worked the panel's cleaning arms slowly, the way the faded instructions said. The thing in the corner watched every movement." }, lose = { trigger = "ep_su_breach", log = "You did it in the wrong order. The counter clicked down to 0." } },
			{ label = "Attachment work: talk to it", hint = "Keep it company. Charisma.", clash = check("charisma", "Something lonely and very old", 5), win = { trigger = "ep_su_3", log = "You talked through the intercom about nothing much. It moved closer to the glass, slowly, and stayed there." }, lose = { trigger = "ep_su_breach", log = "Something in your voice was wrong for it. The counter clicked down to 0." } },
			{ label = "Repression work: use the shock prod", hint = "Make it behave. Strength.", clash = check("strength", "A thing that doesn't like being told", 5), win = { trigger = "ep_su_3", log = "You worked the prod through the hatch until it went back to its corner and stayed there." }, lose = { trigger = "ep_su_breach", log = "It took the prod off you through the hatch. The counter clicked down to 0." } },
			{ label = "Leave before the counter drops", result = { sanity = 1, episodeEnd = "You left the counter at 1. Whatever is in there is still waiting for someone to do it right.", log = "You backed away from the glass. It watched you all the way to the end of the corridor." } },
		},
	},
	{
		id = "ep_su_3",
		episode = "ep_sealed_unit",
		step = 3,
		when = { world = { era = { "library", "limbus" } } },
		title = "A Cell of Green Light",
		text = "The counter clicks up to 2. Under the panel a drawer slides open with a hiss, and in it is a glass cell no bigger than your hand, full of slow green light. Enkephalin: what the old L Corp ran the City on. It's warm, and it hums when you hold it, the same note the thing in the unit hums.",
		weight = 0,
		tags = { "strange", "lcorp" },
		choices = {
			{ label = "Sell it to a Workshop", result = { money = { 900, 1600 }, episodeEnd = "A Workshop paid more than you'd made all year, and asked nothing.", log = "A Workshop paid more than you'd made all year and asked no questions, which is how you knew it was worth more." } },
			{ label = "Keep it", result = { gear = "ep_enkephalin_cell", episodeEnd = "You kept the cell. It hums on your shelf at night.", log = "It sits on your shelf and hums at night, and you sleep better than you have in years, which worries you." } },
			{ label = "Come back and do the work again", hint = "Every week, done right. A job for a company that doesn't exist.", result = { mind = 2, intelligence = 2, money = { 300, 500 }, setFlags = { "su_worker" }, episodeEnd = "For a year you were the only employee of a company that didn't exist.", log = "You went back every week for a year, did the work right and sold the cells quietly. The counter never dropped. Some weeks it went up to 3, and you were stupidly proud of that." } },
		},
	},
	{
		id = "ep_su_breach",
		episode = "ep_sealed_unit",
		step = 3,
		when = { world = { era = { "library", "limbus" } } },
		title = "Qliphoth Meltdown",
		text = "Every light in the corridor turns red at once, and a calm recorded voice you will never forget says: Qliphoth counter depleted. Containment breach in progress. Please evacuate. The door to the unit opens.",
		weight = 0,
		tags = { "strange", "lcorp", "danger" },
		choices = {
			{
				label = "Fight it in the corridor",
				clash = { stat = "strength", foe = "The thing from the TETH unit", enemy = "abnormality", fight = true, coins = 3, base = 7, coinPower = 4 },
				win = { renown = 8, strength = { 1, 3 }, gear = "ep_breach_hook", episodeEnd = "You put the thing from the TETH unit back where it came from, and kept the hook.", log = "It ended with the thing back in its unit and the door shut on it, and you holding an old L Corp suppression hook you'd pulled off the wall. You kept the hook." },
				lose = { health = { -26, -12 }, sanity = -8, cause = "A containment breach in a sunken branch", episodeEnd = "You got out, and sealed the tunnel behind you.", log = "You got out, barely, and dragged the salvagers' planks across the tunnel behind you. Whatever is down there is down there." },
			},
			{
				label = "Run for the flood gate",
				clash = { stat = "speed", foe = "Something faster than it looks", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = -4, speed = 1, episodeEnd = "You ran, and shut the flood gate on it.", log = "You ran faster than you knew you could and pulled the flood gate shut. It hit the other side once, very hard, and then never again." },
				lose = { health = { -16, -8 }, sanity = -4, cause = "A containment breach in a sunken branch", episodeEnd = "You ran, and shut the flood gate on it, late.", log = "It caught you once on the way out. You shut the flood gate anyway." },
			},
		},
	},

	-- ══ The Agent Next Door (the Age of L Corp) ═══════════════════════════════
	{
		id = "ep_an_1",
		episode = "ep_agent_next_door",
		step = 1,
		title = "The Neighbor's Badge",
		scene = { set = "stairs", kicker = "Across the landing", other = { name = "Ilse Brandt", role = "your neighbor, an agent", pose = "sit", age = 27 }, line = "Ilse turns the badge over, and over, and doesn't look up.", voice = "narrator" },
		text = "Ilse Brandt, across the landing, works for L Corp. Everyone knows, because of the badge, and because of the hours: out before six, home after nine, never once a rest day. Tonight Ilse is sitting on the stairs outside your door with the badge in both hands, staring at it like it belongs to someone else.",
		weight = 3,
		once = true,
		tags = { "lcorp" },
		when = { minAge = 12, world = { era = { "wings", "white_nights" } } },
		choices = {
			{ label = "Sit down next to Ilse", result = { sanity = 1, trigger = "ep_an_2", log = "You sat down. Ilse moved over to make room without looking up." } },
			{ label = "Bring two cups of tea", result = { charisma = 1, trigger = "ep_an_2", log = "Ilse held the cup and didn't drink it, but held it like it helped." } },
			{ label = "Close your door quietly", result = { sanity = -1, episodeEnd = "You never asked. A month later there was a new name across the landing.", log = "You closed the door. A month later there was a new name on the door across the landing, and new hours." } },
		},
	},
	{
		id = "ep_an_2",
		episode = "ep_agent_next_door",
		step = 2,
		when = { world = { era = { "wings", "white_nights" } } },
		title = "Work Talk",
		text = "Ilse Brandt talks in a language you half understand: counters, work results, a department that lost three agents this week and got three new ones the next morning. \"They gave me a suit today,\" Ilse says. \"It's made from something we keep downstairs. It fits like it was waiting for me.\"",
		weight = 0,
		tags = { "lcorp" },
		choices = {
			{
				label = "Tell Ilse to quit",
				clash = check("charisma", "A contract, and the pay that comes with it", 6),
				win = { setFlags = { "an_quit" }, schedule = { event = "ep_an_3q", inYears = 2 }, log = "Ilse said you were right, and that it wouldn't be easy, and that the Corporation doesn't like people leaving. Then said it again, more quietly, like a promise." },
				lose = { schedule = { event = "ep_an_3", inYears = 1 }, log = "\"I can't,\" Ilse said. \"You don't understand what it pays. Or what it costs to leave.\"" },
			},
			{ label = "Ask what's downstairs", result = { intelligence = 1, sanity = -2, setFlags = { "knows_lcorp" }, schedule = { event = "ep_an_3", inYears = 1 }, log = "Ilse told you, a little. You didn't sleep. Some things are better as rumors." } },
			{ label = "Just listen", result = { sanity = 2, schedule = { event = "ep_an_3", inYears = 1 }, log = "You listened until the streetlights went off at three. Ilse went in, and said thank you through the door." } },
		},
	},
	{
		id = "ep_an_3",
		episode = "ep_agent_next_door",
		step = 3,
		when = { world = { era = { "wings", "white_nights" } } },
		title = "Nobody Came Home",
		text = "The door across the landing hasn't opened in a week. On the eighth day an L Corp clerk in a neat black suit knocks on yours. \"You're listed as Agent Brandt's emergency contact,\" the clerk says, holding out an envelope and a small cardboard box. \"Our condolences. The Corporation is grateful for the agent's service.\" The clerk doesn't say what happened. The clerk never does.",
		weight = 0,
		tags = { "lcorp" },
		choices = {
			{ label = "Take the envelope and the box", result = { money = { 400, 700 }, sanity = -4, mind = 2, gear = "ep_brandt_badge", episodeEnd = "Ilse kept a photograph of the two of you on the stairs. You keep the badge.", log = "In the box: a cheap pen, a photograph of you and Ilse on the stairs that you didn't know anyone took, and the badge. Some days the badge is heavier than it looks." } },
			{
				label = "Ask the clerk what happened",
				clash = check("charisma", "A Corporation smile", 6),
				win = { intelligence = 1, sanity = -6, money = { 400, 700 }, episodeEnd = "The clerk told you more than a clerk should. Some nights you wish you hadn't asked.", log = "The clerk looked at you for a long moment, then told you, quietly, more than a clerk should. You wish, some nights, that you hadn't asked." },
				lose = { money = { 400, 700 }, sanity = -2, episodeEnd = "The clerk only said the sentence again.", log = "The clerk smiled the same smile and said the same sentence again, word for word. Then once more." },
			},
			{ label = "Refuse the Corporation's money", result = { sanity = 1, rep = { lcorp = -4 }, episodeEnd = "You told the clerk to keep the Corporation's money.", log = "You told the clerk to keep it. The clerk wrote that down in a small black book, thanked you, and left." } },
		},
	},
	{
		id = "ep_an_3q",
		episode = "ep_agent_next_door",
		step = 3,
		when = { world = { era = { "wings", "white_nights" } } },
		title = "A Postcard from District 8",
		text = "A postcard, two years on. On the front, a terrible painting of a lake. On the back, in Ilse Brandt's tidy work handwriting: I quit. I sleep now. I still dream about the suit some nights. Thank you for telling me to go.",
		weight = 0,
		tags = { "lcorp" },
		choices = {
			{ label = "Pin it over your bed", result = { sanity = 8, charisma = 1, episodeEnd = "Ilse quit, and lived. It's the only story about L Corp you know that ends that way.", log = "It's still there, the terrible lake. It's the only story you know about L Corp that ends with someone sleeping." } },
			{ label = "Write back", result = { sanity = 5, meet = true, episodeEnd = "You wrote back. You've been writing back ever since.", log = "You wrote back. Ilse wrote back. It's been years, and neither of you has missed one." } },
		},
	},

	-- ══ Twelve Crates of Light (the Age of L Corp) ════════════════════════════
	{
		id = "ep_ec_1",
		episode = "ep_energy_crates",
		step = 1,
		title = "The Freight Truck",
		scene = { set = "street", kicker = "The bottom of your street", other = { name = "Three Rats", foe = "rat" }, line = "The crates glow green through their slats.", voice = "narrator" },
		text = "An L Corp energy freight truck has gone over on its side at the bottom of your street, and the crates in the back glow through their slats: green, steady, warm on your face from twenty steps away. The driver is stuck in the cab, shouting for someone to call the Corporation. Three Rats are already walking towards the crates, not hurrying.",
		weight = 3,
		once = true,
		tags = { "danger", "crime", "lcorp" },
		when = { minAge = 14, side = "backstreets", world = { era = { "wings", "white_nights" } } },
		choices = {
			{
				label = "Get the driver out",
				clash = check("strength", "A cab door folded shut", 5),
				win = { sanity = 4, renown = 3, rep = { lcorp = 8 }, episodeEnd = "You got the driver out. L Corp's retrieval team counted every crate.", log = "You got the driver out before the Rats got the crates open. L Corp's retrieval team arrived nine minutes later, counted every crate, and gave you a card with a number you never needed." },
				lose = { health = { -6, -2 }, sanity = -2, episodeEnd = "You couldn't shift the door. The retrieval team did.", log = "You couldn't shift the door. The driver talked to you the whole time you tried, very calmly, about their children. The retrieval team got them out in the end." },
			},
			{
				label = "Grab a crate before the Rats do",
				clash = check("speed", "Three Rats who also want a crate", 5),
				win = { trigger = "ep_ec_2", log = "You got one. It was heavier than it looked and warmer than it should have been, and you didn't stop running until your own door." },
				lose = { health = { -10, -4 }, rep = { rats = -6 }, episodeEnd = "The Rats got there first, and weren't in a sharing mood.", log = "The Rats got there first. They weren't in a sharing mood, and they made the point twice." },
			},
			{ label = "Watch from the window", result = { sanity = -1, episodeEnd = "You watched until the retrieval team came.", log = "You watched from the window until L Corp's retrieval team came, and stopped watching when you saw how they dealt with the Rats." } },
		},
	},
	{
		id = "ep_ec_2",
		episode = "ep_energy_crates",
		step = 2,
		when = { world = { era = { "wings", "white_nights" } } },
		title = "A Crate Under the Bed",
		text = "The crate hums. In the dark it lights your whole room green, and you've started dreaming about long white corridors you've never walked down. Two people want it. A Syndicate fence will pay four figures and ask nothing. And this morning a woman in a black L Corp suit stood at the corner for an hour, looking up at your window.",
		weight = 0,
		tags = { "crime", "lcorp" },
		choices = {
			{ label = "Sell it to the fence", result = { money = { 1200, 2200 }, rep = { lcorp = -15 }, setFlags = { "ec_sold" }, schedule = { event = "ep_ec_3", inYears = 1 }, log = "The fence paid in a paper bag and told you to move house. You didn't." } },
			{ label = "Give it back", result = { rep = { lcorp = 10 }, money = 150, sanity = 2, episodeEnd = "You gave it back. L Corp thanked you for saving it the stairs.", log = "The woman in the black suit took the crate, handed you a finder's fee in an envelope, and said, \"We'd have found it either way. Thank you for saving us the stairs.\"" } },
			{ label = "Keep it", result = { mind = 2, sanity = -4, setFlags = { "ec_kept" }, schedule = { event = "ep_ec_3", inYears = 1 }, log = "You kept it under the bed. The dreams got longer. You started to know the corridors." } },
		},
	},
	{
		id = "ep_ec_3",
		episode = "ep_energy_crates",
		step = 3,
		when = { world = { era = { "wings", "white_nights" } } },
		title = "Retrieval",
		text = "L Corp's retrieval team is very polite. There are four of them on your landing, in black suits that don't crease, and the one in front holds a list. \"We're collecting a lost delivery,\" says the one with the list. \"We know you have it, or had it. Either way, the Corporation would like to discuss it.\"",
		weight = 0,
		tags = { "danger", "lcorp" },
		choices = {
			{
				label = "Fight them on the stairs",
				clash = { stat = "strength", foe = "An L Corp retrieval team", enemy = "lcorp_agent", fight = true, coins = 3, base = 8, coinPower = 4 },
				win = { renown = 10, rep = { lcorp = -25 }, money = { 200, 400 }, episodeEnd = "You won on the stairs, which nobody does. L Corp sent a bill instead of a second team.", log = "You won on the stairs, which nobody does. L Corp sent a bill instead of a second team. You never paid it, and nobody ever came to collect, which is somehow worse." },
				lose = { health = { -25, -12 }, money = -600, cause = "An L Corp retrieval team", episodeEnd = "They were very good at stairs.", log = "They were very good at stairs. They took the crate, and the cost of their time, and left the door on its hinges." },
			},
			{
				label = "Talk your way out",
				clash = check("charisma", "A list, and the people who keep it", 7),
				win = { rep = { lcorp = 4 }, episodeEnd = "The one with the list crossed your name off, very neatly.", log = "You talked for an hour. At the end of it the one with the list crossed your name off, very neatly, and the team left the way it had come." },
				lose = { money = -800, episodeEnd = "They took what it was worth out of your savings, to the Ahn.", log = "They listened politely, then took what it was worth out of your savings, to the Ahn, and left a receipt." },
			},
			{ label = "Pay for it", requires = { min = { money = 1000 } }, result = { money = -1000, episodeEnd = "You paid the Corporation for its light. They gave you a receipt.", log = "You paid the Corporation for its light. They gave you a receipt with the Wing's seal on it. You keep it in a drawer, for some reason." } },
		},
	},
}
