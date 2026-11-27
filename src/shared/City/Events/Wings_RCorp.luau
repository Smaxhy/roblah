--[[
	R Corp (District 18): the Packs. Hatched soldiers, human contractors, and the three
	teams of every Pack: Rabbits, Reindeer, Rhinos (CANON 2, 8.3). The Fourth Pack under
	Nikolai is canon; the player's Pack is their own.
	Career rcorp ranks: 1 Contract Recruit, 2 Packmate, 3 Veteran Packmate, 4 Team Leader,
	5 Pack Commander.
]]

return {
	{
		id = "wg_r_team",
		title = "Rabbit, Reindeer or Rhino",
		text = "Every R Corp Pack has three teams, and every recruit is assigned to one in their first week. Rabbits do a bit of everything and do it fast. Reindeer are fitted with antlers that turn strength of mind into force. Rhinos are heavy assault, built to go through walls. The sergeant holds out three armbands and waits.",
		weight = 120,
		once = true,
		tags = { "wing", "rcorp" },
		when = { career = "rcorp" },
		codex = "wg_lore_rcorp",
		choices = {
			{
				label = "Rabbit",
				result = { strength = 2, intelligence = 1, setFlags = { "wg_rabbit" }, log = "You took the Rabbit armband. Rabbits run, scout, carry, fight, and run again. Most of the others on your team were hatched in the same batch, and they adopted you like a slightly slow sibling." },
			},
			{
				label = "Reindeer",
				result = { mind = 3, setFlags = { "wg_reindeer" }, log = "You took the Reindeer armband and spent a week in R Corp's fitting rooms. You came out with antlers that ache when it rains and hit like a truck when you're angry. You've learned to stay calm." },
			},
			{
				label = "Rhino",
				result = { health = 3, setFlags = { "wg_rhino" }, log = "You took the Rhino armband and a suit of armor heavier than you are. On your first drill, you went through a wall. On purpose. Mostly." },
			},
		},
	},
	{
		id = "wg_r_contract",
		title = "The Contract",
		text = "Your Pack has been sold to a client in another District for a month, and the client wants a warehouse cleared of someone else's Fixers. The briefing said six Fixers. There are twenty, and they knew you were coming. Your team is pinned in a loading bay, and the hatched soldiers beside you are waiting for orders, calmly, the way they always do.",
		weight = 22,
		cooldown = 3,
		tags = { "wing", "rcorp" },
		when = { career = "rcorp", minRank = 2 },
		choices = {
			{
				label = "Fight your way out",
				hint = "A real fight.",
				clash = { stat = "strength", foe = "Twenty Fixers who knew you were coming", coins = 3, base = 5, coinPower = 3, fight = true, status = "tremor" },
				win = { strength = 2, paycheck = 0.2, chronicle = "wg_pack_home", log = "You led the team out through the back of the bay and two streets of crossfire. Everyone came home: humans, hatched, all of them. The client paid in full and asked for your Pack by name next time." },
				lose = { health = { -14, -7 }, sanity = -3, log = "You got out. Not everyone did, and most of the ones who didn't were hatched, and R Corp's report counted them like equipment.", cause = "Fell on an R Corp contract" },
			},
			{
				label = "Hold the bay and call for the Rhinos",
				hint = "A Health check: hold until they come.",
				clash = { stat = "health", foe = "A long wait in a loading bay", coins = 2, base = 5, coinPower = 3 },
				win = { health = 2, paycheck = 0.15, chronicle = "wg_pack_home", log = "You held the bay for forty minutes, until the Rhinos came through the warehouse wall. Nobody was lost. The hatched soldiers saluted you afterward, which they don't do for everyone." },
				lose = { health = { -9, -5 }, sanity = -3, log = "You held. The Rhinos came. The bay will need a new roof, and you'll need a new shoulder." },
			},
			{
				label = "Pull your team out against orders",
				result = { sanity = 2, money = { -80, -30 }, log = "You pulled everyone out and ate the fine for breaking contract. R Corp docked your pay. Nobody on your team died. You'd do it again." },
			},
		},
	},
	{
		id = "wg_r_clone",
		title = "A Clone with a Name",
		text = "A hatched Rabbit from your team finds you behind the barracks at night. They've left their armband on their bunk. \"I want to leave,\" they say, very quietly. \"But I don't have a name. Hatched don't. Out there, you need a name.\" They look at you as if you're the only person in the District who could give them one.",
		weight = 18,
		once = true,
		tags = { "wing", "rcorp" },
		when = { career = "rcorp", minRank = 2 },
		codex = "wg_lore_rcorp",
		choices = {
			{
				label = "Give them a name",
				result = { sanity = 4, setFlags = { "wg_named_clone" }, addRelation = { kind = "friend", name = "Ilka", bond = 60, age = { 16, 20 } }, log = "You thought about it for a long time and said, \"Ilka.\" They said it back, twice, trying it out. Then they were gone over the wall before dawn. A year later, a card came from another District, signed Ilka, in careful letters." },
			},
			{
				label = "Help them over the wall, and let them choose their own",
				hint = "A Strength check: the patrols.",
				clash = { stat = "strength", foe = "R Corp's night patrol", coins = 2, base = 4, coinPower = 3 },
				win = { strength = 2, sanity = 3, setFlags = { "wg_named_clone" }, log = "You got them over the wall between patrols. On the other side, they turned and said, \"I'll pick one I like,\" and smiled for the first time. You never found out what they chose." },
				lose = { money = -50, sanity = -3, log = "The patrol caught you both at the wall. They were sent back to the Hatchery for \"assessment\". You were fined. You still think about it." },
			},
			{
				label = "Send them back to their bunk",
				result = { sanity = -4, log = "You told them to go back to bed before anyone saw. They went. The next morning, they were wearing their armband, and they never spoke to you again." },
			},
		},
	},
	{
		id = "wg_r_hatchery",
		title = "The Last Batch",
		text = "A technician from R Corp's Hatchery sits down next to you at a noodle stall in District 18, too tired to eat. The Hatchery runs on bought energy, she says, green energy from District 12, and the price has gone up again. This batch hatching now is the last one the budget allows this year. \"Two hundred,\" she says. \"After that, it's all contractors. People like you.\"",
		weight = 12,
		once = true,
		tags = { "rcorp" },
		when = { district = "d18", minAge = 16, world = { era = "wings" } },
		codex = "wg_lore_rcorp",
		choices = {
			{
				label = "Buy her a bowl of noodles and listen",
				result = { sanity = 2, mind = 1, log = "She talked about the batch the way people talk about their kids. Two hundred, all named by number. She knows every number. She ate, eventually." },
			},
			{
				label = "Ask why it all runs on L Corp's energy",
				result = { mind = 2, codex = "lc_lore_pe_boxes", log = "\"Everything does,\" she said. \"Half the Wings run on that green. Nobody makes it but them, and nobody asks them how.\" She laughed, not happily." },
			},
		},
	},
	{
		id = "wg_r_leader",
		title = "Team Leader",
		text = "You've been made Team Leader, which means a team of thirty: four humans and twenty-six hatched soldiers who will do exactly what you say. Your first contract briefing is tomorrow. Tonight, the hatched sergeant asks you, politely, how you want them to address you, and whether you'll be counting them as people or as equipment in your reports.",
		weight = 30,
		once = true,
		tags = { "wing", "rcorp" },
		when = { career = "rcorp", minRank = 4 },
		choices = {
			{
				label = "Count them as people",
				result = { sanity = 4, setFlags = { "wg_counts_people" }, log = "You wrote their numbers in your reports as names, every one, every time. Headquarters sent the reports back for correction twice. You didn't correct them. Your team would follow you anywhere now, and has." },
			},
			{
				label = "Count them the way R Corp does",
				result = { paycheck = 0.15, sanity = -3, log = "You filed the reports the R Corp way, with the hatched listed under equipment. It's the rule. The sergeant said \"Understood,\" and has said nothing else to you since that wasn't an order." },
			},
			{
				label = "Ask the sergeant what they'd prefer",
				result = { intelligence = 2, sanity = 2, log = "The sergeant thought about it for a long time. \"Nobody has ever asked,\" they said at last. \"Sergeant is fine. And people.\"" },
			},
		},
	},
}
