--[[
	Echoes (bl_ ids): another player's boss kill, raid or find reaches this life
	(when.chronicle; acts in Chronicle/Loot.luau). {actor} did it, in {actorDistrict}.
	Rumors, openings, consequences and grudges.
]]

return {
	-- a named terror is down
	{
		id = "bl_echo_boss_street",
		title = "The Street Celebrates",
		text = "Word from {actorDistrict}: {actor} brought down one of the named terrors that ran a whole block. The noodle stalls there are handing out free bowls with the story.",
		weight = 8,
		cooldown = 6,
		when = { chronicle = "bl_act_boss_slain", minAge = 10 },
		choices = {
			{ label = "Go and hear the story", result = { sanity = 3, log = "You queued for a free bowl and heard the story three ways. In every version, {actor} was taller." } },
			{ label = "Ask how it was done", result = { strength = 1, mind = 1, log = "A Fixer who was there drew it on a napkin for you: where to stand, when to move. You kept the napkin." } },
			{ label = "Wonder who fills the gap", result = { mind = 2, sanity = -1, log = "Somebody always moves into the space a terror leaves. You started watching for who." } },
		},
	},
	{
		id = "bl_echo_boss_gap",
		title = "The Gap It Left",
		text = "Since {actor} brought down that terror in {actorDistrict}, the turf it held is open, and every small Syndicate in the City wants it. Someone is hiring muscle to hold a corner.",
		weight = 6,
		cooldown = 8,
		tags = { "danger" },
		when = { chronicle = "bl_act_boss_slain", minAge = 16, side = "backstreets" },
		choices = {
			{
				label = "Hire on to hold it",
				hint = "A real fight. Three Syndicates want it.",
				clash = { stat = "strength", foe = "Syndicate muscle", coins = 3, base = 6, coinPower = 3, fight = true, status = { id = "rupture", potency = 1 } },
				win = { wage = { 80, 180 }, strength = 1, log = "You held the corner for a week. The Syndicate paid, then the Fixers came, and you left at the right moment." },
				lose = { health = { -16, -8 }, cause = "Caught in a Syndicate crossfire", log = "Three Syndicates wanted the corner, and you were standing on it." },
			},
			{
				label = "Sell maps of the turf",
				hint = "Mental Strength check. Know who's buying.",
				clash = { stat = "mind", foe = "Buyers with grudges", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 40, 90 }, mind = 1, log = "You sold the same map to three Syndicates, each with a different shortcut marked." },
				lose = { money = -20, sanity = -2, log = "A buyer found out about the other buyers. You paid them to forget it." },
			},
			{ label = "Stay out of it", result = { sanity = 1, log = "You stayed home and listened to the corner change hands four times in a month." } },
		},
	},
	-- the Ivory Verdict is beaten
	{
		id = "bl_echo_verdict",
		title = "The Verdict Is In",
		text = "The Ivory Verdict is beaten. {actor} did it, in {actorDistrict}, and Hana is pretending not to be relieved. Every Office in the City is reading the job report.",
		weight = 10,
		cooldown = 20,
		when = { chronicle = "bl_act_color_fallen", minAge = 12 },
		choices = {
			{ label = "Read the report yourself", result = { mind = 2, codex = "bl_lore_verdict", log = "A cousin had a copy. It ran nine pages, and the last line said only: she was polite about it." } },
			{
				label = "Take one of her old contracts",
				hint = "Licensed Fixers only. Strength check.",
				requires = { flags = { "licensed_fixer" } },
				clash = { stat = "strength", foe = "A contract meant for a Color", coins = 3, base = 7, coinPower = 3 },
				win = { wage = { 150, 300 }, strength = 1, log = "Her old clients needed someone new. You were new, and you were enough." },
				lose = { health = { -14, -6 }, cause = "Killed on a small contract", log = "Her clients were used to a Color. You were not one, yet." },
			},
			{ label = "Feel sorry for her", result = { sanity = 2, log = "Somebody should. You did, for a minute, over your noodles." } },
		},
	},
	-- the Lamplighter is put out
	{
		id = "bl_echo_lamps",
		title = "The Lamps Turn Back",
		text = "Since {actor} put out the Lamplighter in {actorDistrict}, the streetlamps there face the right way again. People are finding shadows they lost years ago, lying in gutters like dropped coats.",
		weight = 9,
		cooldown = 15,
		when = { chronicle = "bl_act_aleph_doused", minAge = 10 },
		choices = {
			{ label = "Help find the strays", result = { sanity = 3, codex = "bl_lore_lamplighter", log = "You found a small shadow under a bench and walked it to the lost-and-found tent. A grandmother there held its hand and cried." } },
			{ label = "Check your own", result = { sanity = -2, mind = 2, log = "You checked yours under a streetlamp, carefully. All there. You checked again anyway." } },
		},
	},
	-- something legendary came home
	{
		id = "bl_echo_collectors",
		title = "Collectors Circling",
		text = "Since {actor} came home to {actorDistrict} with something legendary, Nest collectors have been in the Backstreets with open wallets, asking everyone about named gear.",
		weight = 8,
		cooldown = 8,
		when = { chronicle = "bl_act_legendary_find", minAge = 14 },
		choices = {
			{
				label = "Sell them a story",
				hint = "Intelligence check. Make it sound true.",
				clash = { stat = "intelligence", foe = "A collector who has heard everything", coins = 2, base = 5, coinPower = 3 },
				win = { wage = { 60, 140 }, log = "You sold a collector a very good story about a sword you've never seen. He paid by the word." },
				lose = { money = -10, sanity = -2, log = "The collector knew the real story, and charged you for wasting his time, somehow." },
			},
			{ label = "Ask what they're after", result = { mind = 2, codex = "bl_lore_named_gear", log = "Named gear, a collector explained: weapons that belonged to someone the City feared. \"Never sold. Only taken.\"" } },
			{ label = "Go hunting yourself", result = { strength = 1, health = { -4, 0 }, log = "You spent a week poking into places people warned you about. You found a new scar and a taste for it." } },
		},
	},
	-- something unreal
	{
		id = "bl_echo_unreal",
		title = "Something Unreal",
		text = "A rumor from {actorDistrict}: {actor} found something with no grade at all. The Workshops say that's impossible. The Workshops are very interested.",
		weight = 10,
		cooldown = 20,
		when = { chronicle = "bl_act_unreal_find", minAge = 10 },
		choices = {
			{
				label = "Go and see it",
				hint = "Mental Strength check. Get to the front.",
				clash = { stat = "mind", foe = "A crowd a hundred deep", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = 3, codex = "bl_lore_named_gear", log = "You saw it for one second between shoulders. It didn't look like much. You thought about it for a year." },
				lose = { sanity = -2, log = "You saw the back of a Fixer's coat and a great many elbows." },
			},
			{ label = "Laugh it off", result = { sanity = 2, log = "Unreal. Sure. You've also heard the Head keeps a dog." } },
			{ label = "Train harder", result = { strength = 2, health = 1, sanity = -1, log = "If {actor} can find one, so can you. You trained until your hands stopped arguing." } },
		},
	},
	-- a crew cleared a raid
	{
		id = "bl_echo_crew_wanted",
		title = "Crew Wanted",
		text = "Since {actor}'s crew cleared the worst job on {actorDistrict}'s board, every crew in the City is recruiting. A notice on an Office door: ONE MORE. MUST BE ALIVE.",
		weight = 8,
		cooldown = 8,
		when = { chronicle = "bl_act_raid_cleared", minAge = 16 },
		choices = {
			{
				label = "Sign on for a run",
				hint = "Speed check. Keep up.",
				clash = { stat = "speed", foe = "A crew's hardest job", coins = 3, base = 6, coinPower = 3 },
				win = { wage = { 80, 160 }, book = "bl_book_drill_ledger", log = "The run went well. Your share was Ahn and a spare drill ledger." },
				lose = { health = { -16, -8 }, cause = "Killed on a crew job", log = "The run went badly. The crew carried you home and split your share." },
			},
			{ label = "Ask how they work together", result = { intelligence = 2, log = "The captain explained: whoever's best at a job fights it, and everyone else adds a coin. You wrote it down." } },
			{ label = "Start your own crew", result = { strength = 1, mind = 1, sanity = 2, log = "You pinned up your own notice. By morning someone had signed it in very large letters." } },
		},
	},
	-- someone outlasted the Foreman
	{
		id = "bl_echo_foreman",
		title = "Someone Outlasted the Foreman",
		text = "They're saying {actor} stayed outside all three waves in {actorDistrict}, with the Foreman itself, and walked in at 4:33. The night shelters are changing their rules over it.",
		weight = 9,
		cooldown = 15,
		tags = { "night" },
		when = { chronicle = "bl_act_outlasted_foreman", minAge = 10, side = "backstreets" },
		choices = {
			{
				label = "Ask {actor}'s neighbors how",
				hint = "Mental Strength check. They don't like to talk about it.",
				clash = { stat = "mind", foe = "Closed curtains", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, codex = "bl_lore_foreman", log = "Keep moving, they said. Never let it reach you. And don't look back at 4:33, because it will be looking." },
				lose = { sanity = -2, log = "Nobody on {actor}'s street would talk about it. They kept their curtains shut." },
			},
			{ label = "Volunteer at a shelter", result = { sanity = 3, intelligence = 1, log = "The shelter needed someone to watch the door between waves. You watched it. Nobody came, and that was the point." } },
			{ label = "Lock up earlier", result = { sanity = 2, log = "You started locking up at two. Then half past one." } },
		},
	},
	-- a crew won a reception
	{
		id = "bl_echo_gilt_spines",
		title = "Gilt Spines at the Market",
		text = "Since {actor}'s crew walked out of the Library with armfuls of books, gilt-edged volumes keep turning up at the night market in {actorDistrict}. Nobody asks whose lives are in them.",
		weight = 8,
		cooldown = 10,
		when = { world = { era = { "library", "limbus" } }, chronicle = "bl_act_reception_won", minAge = 12 },
		choices = {
			{
				label = "Buy one",
				hint = "900 Ahn.",
				requires = { min = { money = 900 }, noTrait = "bl_ab_emotion_level", noBook = "bl_book_guest" },
				result = { money = -900, book = "bl_book_guest", sanity = -2, log = "You bought one. It's a stranger's whole life, and every fight they won." },
			},
			{ label = "Ask who's in them", result = { mind = 1, sanity = -2, codex = "bl_lore_reception_crews", log = "A seller showed you a name on a spine. You didn't know it, and you were glad." } },
			{ label = "Walk past", result = { sanity = 1, log = "You walked past the stall. One of the books turned its spine toward you as you went." } },
		},
	},
}
