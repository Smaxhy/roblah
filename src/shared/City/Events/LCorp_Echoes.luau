--[[
	Echoes: how other players' L Corp deeds reach this life (when = { chronicle = "act" }).
	{actor} is the player who did it, {actorDistrict} where. One or more echo for every act
	in Chronicle/LCorp.luau, and for the breach acts from Chronicle/Core.luau:
	fought_abnormality, lcorp_evacuated and saved_child_breach.
	The Wings' acts (wg_*) echo in Events/Wings_Echoes.luau.
]]

local WINGS = { era = "wings" }
local AFTER = { era = { "white_nights", "library", "limbus" } }

return {
	-- someone suppressed a breach
	{
		id = "lc_echo_suppressed",
		title = "The Corridor Held",
		text = "The story is all over the Green Kettle by evening: {actor} held a corridor inside L Corp against an escaped Abnormality until the Disciplinary Team arrived, and every Clerk on that floor went home tonight. People keep saying the name, like a lucky charm.",
		weight = 16,
		cooldown = 6,
		tags = { "lcorp" },
		when = { chronicle = "lc_suppressed_breach", minAge = 10, world = WINGS },
		choices = {
			{
				label = "Raise a cup of tea to {actor}",
				result = { sanity = 3, log = "You raised your cup with the rest of the teahouse. Somebody started a song. The Clerks at the corner table cried a little, and laughed, and ordered more tea." },
			},
			{
				label = "Ask an Agent how a suppression actually works",
				result = { mind = 2, codex = "lc_lore_suppression", log = "An off-duty Agent explained it on a napkin: hold the corridor, keep the Clerks alive, fight it until it goes back into its egg. \"{actor} did all three,\" she said. \"Most people manage one.\"" },
			},
			{
				label = "Think about joining L Corp yourself",
				hint = "District 12. Needs Health 25 and Mental Strength 25.",
				requires = { district = "d12", minAge = 18, notFlags = { "lcorp_employee" }, min = { health = 25, mind = 25 } },
				result = { career = "lcorp_agent", sanity = -1, codex = "lc_lore_agents", log = "You went to the recruiting table the next morning and said {actor}'s name. The recruiter smiled for the first time you'd ever seen. You start as a Clerk next week." },
			},
		},
	},
	-- someone's work order went wrong: a breach is loose in District 12
	{
		id = "lc_echo_caused",
		title = "Sirens, Again",
		text = "The L Corp sirens go up across District 12. Word runs ahead of them down the street: a work order went wrong for {actor}, and something is out of its unit. Shutters are slamming. A woman is calling a child's name from a balcony. Somewhere a few streets away, something is singing.",
		weight = 18,
		cooldown = 5,
		tags = { "lcorp", "breach", "danger" },
		when = { chronicle = "lc_caused_breach", district = "d12", minAge = 8, world = WINGS },
		choices = {
			{
				label = "Get the neighbors into the shelter",
				hint = "A Health check: you're the last one in.",
				clash = { stat = "health", foe = "The last minute before it arrives", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = 3, setFlags = { "lc_breach_survivor" }, log = "You got the whole stairwell into the basement, the child from the balcony included, and pulled the door shut as the singing came down the street." },
				lose = { health = { -8, -4 }, sanity = -3, setFlags = { "lc_breach_survivor", "saw_abnormality" }, log = "You got them in. You were last, and you were slow, and it was close enough to see.", cause = "Caught by a breach on the street" },
			},
			{
				label = "Lock your door and wait it out",
				result = { sanity = -2, setFlags = { "lc_breach_survivor" }, log = "You locked up and sat away from the window until the sirens stopped. You heard it go past. You didn't look. That's how you're still here." },
			},
			{
				label = "Go and see what it is",
				hint = "A real fight. You have no idea what it is.",
				clash = { stat = "strength", foe = "An escaped Abnormality", coins = 3, base = 5, coinPower = 3, fight = true, status = "sinking" },
				win = { strength = 2, sanity = -2, setFlags = { "lc_breach_survivor", "saw_abnormality" }, chronicle = "fought_abnormality", log = "You found it and kept it busy, two streets from a school, until L Corp's suppression team arrived. One of the Agents shook your hand. You didn't sleep for two nights." },
				lose = { health = { -14, -7 }, sanity = -6, setFlags = { "lc_breach_survivor", "saw_abnormality" }, condition = "night_terrors", log = "You found it. It found you back.", cause = "Went looking for a breach" },
			},
		},
	},
	-- someone held through an Ordeal: the City's lights flickered
	{
		id = "lc_echo_ordeal",
		title = "The Night the Lights Dimmed",
		text = "For an hour tonight, every light in the District flickers green and then nearly goes out. The radios say an Ordeal hit L Corp's facility and the energy lines dipped across the City. By morning they're saying {actor} held a corridor all the way through it, and that's why the lights came back.",
		weight = 14,
		cooldown = 6,
		tags = { "lcorp" },
		when = { chronicle = "lc_ordeal_held", minAge = 8, world = WINGS },
		codex = "lc_lore_ordeals",
		choices = {
			{
				label = "Light candles for the neighbors",
				result = { sanity = 3, log = "You went door to door with candles in the dark. The old man upstairs told you about the last time it happened, before you were born, and how long the dark lasted." },
			},
			{
				label = "Check on your family",
				requires = { hasRelation = { "mother", "father", "sibling", "child" } },
				result = { sanity = 2, relationBond = { kind = "family", amount = 5 }, log = "You crossed the dark streets to check on your family. Everyone was fine. You stayed the night anyway." },
			},
			{
				label = "Think about where the City's power really comes from",
				result = { mind = 2, sanity = -1, log = "One company in one District, and when it has a bad night the whole City dims. You'd never thought about it before. You find you can't stop." },
			},
		},
	},
	-- someone was issued E.G.O
	{
		id = "lc_echo_ego",
		title = "A Strange Coat on the Platform",
		text = "On the WARP platform, the crowd keeps a careful distance from one passenger: an L Corp Agent, people whisper, {actor}, wearing one of the Wing's suits, the kind people say is cut from something it keeps downstairs. It looks almost like ordinary clothes. Then it moves when the wearer doesn't, and you're certain, for a second, that it looked at you.",
		weight = 12,
		cooldown = 8,
		tags = { "lcorp" },
		when = { chronicle = "lc_ego_issued", minAge = 10, world = WINGS },
		choices = {
			{
				label = "Ask about the gear",
				result = { mind = 1, sanity = -1, codex = "lc_lore_ego_gear", log = "You asked. The Agent smiled, tiredly, and explained: a piece of what the Abnormality is, made into something you can wear. \"It changes how you talk,\" she said. \"I didn't use to say 'little one'.\"" },
			},
			{
				label = "Keep your distance like everyone else",
				result = { sanity = 1, log = "You kept to the far end of the platform and took the next train. You still remember exactly how the coat moved." },
			},
			{
				label = "Compliment it",
				result = { charisma = 1, sanity = -2, log = "\"Nice coat,\" you said. The coat answered. Not in words. The Agent apologized for it." },
			},
		},
	},
	-- someone was made Branch Manager
	{
		id = "lc_echo_manager",
		title = "Under New Management",
		text = "There's a new name on the hiring posters around District 12: one of L Corp's branches has a new Manager, {actor}, and the branch is taking on staff. The rumor at the Green Kettle is that this Manager walks the floors, knows the Clerks' names, and reads every file twice.",
		weight = 14,
		cooldown = 8,
		tags = { "lcorp" },
		when = { chronicle = "lc_made_manager", district = "d12", minAge = 18, world = WINGS, notFlags = { "lcorp_employee" } },
		choices = {
			{
				label = "Apply to the new Manager's branch",
				hint = "Needs Health 25 and Mental Strength 25.",
				requires = { min = { health = 25, mind = 25 } },
				result = { career = "lcorp_agent", codex = "lc_lore_manager", log = "You applied. The interview was short, and at the end of it the interviewer said, \"{actor} wants everyone told the same thing on day one: read the file, then read it again.\"" },
			},
			{
				label = "Ask the regulars what a Manager actually does",
				result = { mind = 2, codex = "lc_lore_manager", log = "\"Sits in a room full of screens,\" said a retired Clerk, \"and decides who goes where. That's all. That's everything.\"" },
			},
			{
				label = "Wish them luck and stay where you are",
				result = { sanity = 1, log = "You wished {actor} luck under your breath and walked on. Managers need it more than anyone." },
			},
		},
	},
	-- someone published a study
	{
		id = "lc_echo_published",
		title = "The New Procedure",
		text = "A new work procedure came down from the research division this morning, stapled to every unit's file: a study by {actor}, with one line in bold that changes how one of your units has to be worked. It's the opposite of what you've been doing for a year.",
		weight = 16,
		cooldown = 6,
		tags = { "lcorp" },
		when = { chronicle = "lc_research_published", career = "lcorp_agent", minRank = 2, world = WINGS },
		choices = {
			{
				label = "Follow the new procedure",
				result = { mind = 2, sanity = 2, log = "You did it the new way. The counter climbed higher than you'd ever seen it on that unit. You went home thinking about all the times you'd done it the old way." },
			},
			{
				label = "Stick to what's always worked",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "Old habits", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 1, log = "It worked the old way, this time. You read the study that night, carefully, and changed your mind." },
				lose = { health = { -7, -3 }, sanity = -3, log = "It didn't work the old way anymore. The study had been right. You read it in Welfare." },
			},
			{
				label = "Find the researcher and say thank you",
				result = { sanity = 3, intelligence = 1, log = "You went up to the research wing and found {actor}'s lab and said thank you. They seemed startled. Nobody from the floor had ever come up to say it." },
			},
		},
	},
	-- someone let an observation log loose
	{
		id = "lc_echo_leak",
		title = "A Page Going Round",
		text = "Copies of a page are going round {district}, passed hand to hand at the market and pinned up in the diner: half an L Corp observation log, about a small bird that must not be handled. It started, people say, with someone in {actorDistrict} called {actor}. The page ends mid-sentence.",
		weight = 12,
		cooldown = 8,
		tags = { "lcorp" },
		when = { chronicle = "lc_log_leaked", minAge = 10, world = WINGS },
		choices = {
			{
				label = "Read a copy",
				result = { mind = 1, sanity = -1, codex = "lc_abno_punishing_bird", log = "You read it twice. A bird that punishes. Three hurt. Do NOT tell the Manager it was Repression. You looked at the next bird you saw for a long time." },
			},
			{
				label = "Take down the copy in the diner",
				result = { sanity = 1, log = "You took it down and put it in the stove. The cook nodded. \"Bad luck,\" she said, \"reading about those things.\" By the next week there were two more." },
			},
		},
	},
	-- someone has been telling people what the White Nights were
	{
		id = "lc_echo_truth",
		title = "Someone Who Knows",
		text = "People are talking about {actor}, who used to have something to do with L Corp and now tells anyone who'll listen what the White Nights really were. Some people say it's nonsense. Some go back to hear it again, and come away very quiet.",
		weight = 14,
		cooldown = 8,
		tags = { "lcorp" },
		when = { chronicle = "lc_truth_told", minAge = 14, world = AFTER },
		choices = {
			{
				label = "Go and listen",
				result = { mind = 2, sanity = -2, setFlags = { "lc_heard_the_truth" }, codex = "lcorp_enkephalin", log = "You listened to {actor} for an hour in a back room full of strangers. Energy from people's minds. A light grown in the dark. You don't know how much you believe. Enough to stop sleeping well." },
			},
			{
				label = "Leave the past where it is",
				result = { sanity = 2, log = "You didn't go. The Light came and went, and the City is what it is now. You'd rather live in it than in the story of how it got this way." },
			},
		},
	},

	-- ── the core breach acts ──
	{
		id = "lc_echo_fought",
		title = "The One Who Held It Off",
		text = "Everyone on the street is talking about {actor}, an ordinary person from {actorDistrict}, who held an escaped Abnormality off with whatever came to hand until L Corp's suppression team arrived. No license, no Wing gear, nothing. Kids are playing the story in the alley, taking turns being the monster.",
		weight = 14,
		cooldown = 8,
		tags = { "lcorp" },
		when = { chronicle = "fought_abnormality", minAge = 8, world = WINGS },
		choices = {
			{
				label = "Join the kids' game and be the monster",
				result = { sanity = 3, health = 1, log = "You were the monster. You lost, to a seven-year-old with a broom handle, very dramatically. The whole alley cheered." },
			},
			{
				label = "Start training, just in case",
				result = { strength = 2, health = 1, log = "You went to the Fixer gym that week and asked for the class on getting out of the way. If {actor} could do it, maybe anybody could, for a minute." },
			},
			{
				label = "Ask what it was they fought",
				result = { mind = 1, sanity = -2, codex = "lcorp_abnormalities", log = "Nobody agreed on what it was. Everybody agreed it shouldn't have been outside. You looked at the L Corp tower differently on the way home." },
			},
		},
	},
	{
		id = "lc_echo_evacuated",
		title = "They Got Out",
		text = "A new neighbor moved in down the hall: a former L Corp Clerk, gray at the temples, who keeps a green lanyard on the hook by her door. She tells you she was one of a corridor full of staff who got out on L Corp's last day, because someone named {actor} came back for them. She says the name every morning, like a prayer.",
		weight = 14,
		cooldown = 10,
		tags = { "lcorp" },
		when = { chronicle = "lcorp_evacuated", minAge = 10, world = AFTER },
		choices = {
			{
				label = "Welcome her properly",
				result = { sanity = 3, addRelation = { kind = "friend", name = "Odette Krall", bond = 50, age = { 40, 55 } }, log = "You brought noodles and helped carry her boxes. Odette Krall has the neatest handwriting you've ever seen, and she's been the best neighbor you've ever had." },
			},
			{
				label = "Ask her about the last day",
				result = { mind = 2, sanity = -2, codex = "lcorp_fall", log = "She told you about the light, and the doors sealing one after another, and running down a corridor that was getting shorter. \"{actor} held the last door,\" she said. \"I never got to say thank you.\"" },
			},
			{
				label = "Give her some space",
				result = { sanity = 1, log = "You left her be. Some evenings you hear her through the wall, reading names off a list, one by one." },
			},
		},
	},
	{
		id = "lc_echo_child",
		title = "The Shelter Drill",
		text = "Since {actor} pulled a child out of the road in {actorDistrict} during the last breach, the parents on your street have decided every child needs to know the shelter drill: where to run, which doors lock, how to hide from something that hunts by sound. They need someone to teach it.",
		weight = 12,
		cooldown = 8,
		tags = { "lcorp" },
		when = { chronicle = "saved_child_breach", minAge = 14, world = WINGS },
		choices = {
			{
				label = "Teach the drill",
				result = { intelligence = 2, sanity = 3, log = "You taught every child on the street the drill: run, lock, hide, quiet. The smallest one practiced being quiet so seriously she fell asleep under the stairs." },
			},
			{
				label = "Fix the building's shelter door",
				hint = "20 Ahn for a new bolt.",
				requires = { min = { money = 20 } },
				result = { money = -20, mind = 2, log = "You bought a new bolt and fixed the shelter door yourself. Everyone in the building has tried it at least twice. It holds." },
			},
			{
				label = "Leave it to the parents",
				result = { sanity = -1, log = "You left it to the parents. When the next siren went, you saw the drill run on your street, perfectly, and wished you'd helped." },
			},
		},
	},
}
