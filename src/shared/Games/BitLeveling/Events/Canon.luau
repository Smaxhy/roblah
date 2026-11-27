--[[
	THE CANON TIMELINE, LIVED. When a public event of the manhwa happens where a life is
	(pack.hunterWorld.canon: firsthand), the life gets one of these. The event is CANON; what
	the player does in it, and every person they meet, is ORIGINAL. Canon characters are
	never written as the player's friends, and never put where canon doesn't put them.
	Never drawn at random (weight 0).
]]

local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local HIGH = { "hunter_b", "hunter_a", "hunter_s" }

local function card(e)
	e.weight = 0
	e.when = { flags = { "hw_on_" .. e.id } }
	for _, c in e.choices or {} do
		local function clear(r)
			if r then
				r.clearFlags = r.clearFlags or {}
				table.insert(r.clearFlags, "hw_on_" .. e.id)
			end
		end
		clear(c.result)
		clear(c.win)
		clear(c.lose)
	end
	return e
end

return {
	card({
		id = "cn_first_gates",
		title = "The Day the Sky Opened",
		text = "It was on every channel at once. Over a city on the other side of the world, then over another, then on a street you know: a tear in the air, blue at the edges, perfectly still. Nobody knows what it is. The government says stay indoors. Your phone won't stop buzzing.",
		art = "street",
		tags = { "gate", "strange" },
		choices = {
			{ label = "Stay inside and watch the news", result = { sanity = -2, intelligence = 1, codex = { "lore_gates" }, log = "You watched the coverage until four in the morning. The experts didn't know anything either." } },
			{ label = "Go and look at the one nearby", hint = "Everyone's going. It's just standing there.", clash = { stat = "luck", foe = "Whatever is behind it", coins = 1, base = 3, coinPower = 2, fixed = true }, win = { willpower = 2, sanity = -3, codex = { "lore_gates" }, log = "You stood at the police line with a thousand other people and stared into it. It stared back, or felt like it did." }, lose = { vitality = { -10, -4 }, sanity = -5, codex = { "lore_gates" }, log = "The crowd surged when something moved inside it. You got knocked down in the rush.", cause = "Trampled the day the first Gates opened" } },
			{ label = "Call everyone you love", result = { charisma = 1, sanity = 1, codex = { "lore_gates" }, log = "You called your family one by one. Everyone was fine. Nobody believed it would last." } },
		},
	}),
	card({
		id = "cn_kamish",
		title = "The Dragon",
		text = "The Gate that opened near the coast read higher than anything the instruments had ever seen. It broke. What came out of it had wings, and the city's sky went orange. Over a hundred Hunters have gone to meet it. Everyone else is being told to drive inland and not stop.",
		art = "street",
		tags = { "gate", "danger" },
		choices = {
			{ label = "Drive inland with everyone else", clash = { stat = "luck", foe = "A highway full of panic", coins = 2, base = 5, coinPower = 3, fixed = true }, win = { sanity = -8, log = "Eleven hours in traffic with the sky burning behind you. You made it." }, lose = { vitality = { -40, -18 }, sanity = -10, log = "The road behind you didn't make it. You barely did.", cause = "Killed fleeing the first S-rank Dungeon Break" } },
			{ label = "Help the shelter wardens", hint = "Somebody has to keep the doors open and the lines moving.", clash = { stat = "willpower", foe = "A city's worth of fear", coins = 2, base = 7, coinPower = 3, fixed = true }, win = { charisma = 3, willpower = 3, sanity = -6, log = "You kept a shelter door moving for two days. When the news came that it was dead, the whole shelter went silent, then loud." }, lose = { vitality = { -30, -12 }, sanity = -10, log = "The shelter you were working in was too close.", cause = "Killed in the first S-rank Dungeon Break" } },
			{ label = "Go and fight it", hint = "Hunters only. It's beyond any rank there is.", requires = { form = HUNTERS }, clash = { stat = "strength", foe = "The dragon", enemy = "gate_s", coins = 5, base = 70, coinPower = 14, fight = true, fixed = true }, win = { strength = 10, willpower = 8, money = { 2000, 6000 }, sanity = -20, log = "You were there. You don't talk about it. Of everyone who went, only a few came back, and the world gave them a new name." }, lose = { vitality = { -900, -500 }, log = "You went to meet it with the others.", cause = "Killed fighting the dragon on the West Coast" } },
		},
	}),
	card({
		id = "cn_jeju_falls",
		title = "Jeju",
		text = "The S-rank Gate by the coast was supposed to be handled: the best raid team in the country went in this morning. At noon the emergency alert went off on every phone on the island. The raid failed. The Gate broke. Ants, the size of cars, faster than cars, are coming inland. The ferries and the planes are leaving, and there aren't enough of them.",
		art = "street",
		tags = { "gate", "danger" },
		choices = {
			{ label = "Get to the port", clash = { stat = "agility", foe = "The swarm", coins = 2, base = 6, coinPower = 3, fixed = true }, win = { sanity = -12, willpower = 2, log = "You got on the second-to-last ferry. From the deck you watched the island go quiet." }, lose = { vitality = { -90, -35 }, sanity = -14, log = "They reached the port road while you were still on it. A Hunter carried you onto the last ferry.", cause = "Killed in the fall of Jeju Island" } },
			{ label = "Get to the airport", clash = { stat = "luck", foe = "The last flights out", coins = 2, base = 6, coinPower = 3, fixed = true }, win = { sanity = -12, log = "The plane took off with people standing in the aisles. Nobody spoke the whole flight." }, lose = { vitality = { -90, -35 }, sanity = -14, log = "The last flight left without you. You hid in the terminal for a day until a military helicopter came.", cause = "Killed in the fall of Jeju Island" } },
			{ label = "Hold the evacuation route", hint = "Hunters only. Buy minutes for the buses. S-rank monsters.", requires = { form = HUNTERS }, clash = { stat = "strength", foe = "Jeju's ants", enemy = "gate_s", coins = 4, base = 40, coinPower = 11, fight = true, fixed = true }, win = { strength = 6, willpower = 6, charisma = 4, sanity = -14, log = "You held a road for forty minutes. Nine buses got through. You got on the last one." }, lose = { vitality = { -700, -300 }, log = "You held the road for as long as you could.", cause = "Killed holding the road on Jeju Island" } },
		},
	}),
	card({
		id = "cn_tokyo",
		title = "Giants in Shinjuku",
		text = "The S-rank Gate over the city was supposed to be held by a barrier until the foreign Hunters arrived. This morning the barrier failed. Giants, actual giants, are walking out of it into Shinjuku. Buildings are coming down. The evacuation order is for the whole city.",
		art = "street",
		tags = { "gate", "danger" },
		choices = {
			{ label = "Get underground and keep moving", clash = { stat = "agility", foe = "A city coming down", coins = 2, base = 5, coinPower = 3, fixed = true }, win = { sanity = -12, log = "You walked through the subway tunnels with ten thousand strangers and came up in a city that was still standing." }, lose = { vitality = { -70, -25 }, sanity = -14, log = "Your exit collapsed. Rescue teams pulled you out of the rubble two days later.", cause = "Killed in the Tokyo Dungeon Break" } },
			{ label = "Shelter where you are", clash = { stat = "luck", foe = "Giants' footsteps", coins = 2, base = 5, coinPower = 3, fixed = true }, win = { sanity = -14, log = "The footsteps came close twice. Then, later that day, they stopped. Someone on the radio said a Korean Hunter had arrived." }, lose = { vitality = { -80, -30 }, sanity = -14, log = "Your shelter was in the wrong street. Half the building came down around you.", cause = "Killed in the Tokyo Dungeon Break" } },
			{ label = "Join the defence line", hint = "Hunters only. S-rank monsters, and the city behind you.", requires = { form = HUNTERS }, clash = { stat = "strength", foe = "A giant", enemy = "gate_s", coins = 4, base = 42, coinPower = 11, fight = true, fixed = true }, win = { strength = 6, willpower = 6, money = { 300, 900 }, sanity = -12, log = "You held a street with Japanese Hunters you'd never met until help came. Some of them you'll never see again." }, lose = { vitality = { -700, -300 }, log = "The line broke where you were.", cause = "Killed defending Tokyo" } },
		},
	}),
	card({
		id = "cn_seoul_gate",
		title = "The Gate over Seoul",
		text = "It's bigger than the stadium. It's bigger than the district. It has been hanging over the city for days, slowly opening, and the readings are past anything the Association has numbers for. The whole of Seoul is being evacuated. The highways are already full.",
		art = "street",
		tags = { "gate", "danger", "strange" },
		choices = {
			{ label = "Leave with your family", result = { sanity = -8, log = "You packed what fit in the car and drove south with the whole city. You kept looking at it in the mirror." } },
			{ label = "Help at an evacuation point", clash = { stat = "charisma", foe = "Ten million frightened people", coins = 2, base = 10, coinPower = 4, fixed = true }, win = { charisma = 3, willpower = 2, sanity = -6, log = "You handed out water and wristbands for three days. You left on the last bus from your station." }, lose = { sanity = -12, vitality = { -12, -4 }, log = "You worked until you collapsed. Someone carried you onto a bus." } },
			{ label = "Report for duty", hint = "Hunters only. Every licensed Hunter in Korea has been called.", requires = { form = HUNTERS }, result = { willpower = 3, sanity = -6, setFlags = { "seoul_duty" }, log = "You reported to the Association's command post under it. Nobody there could tell you what was going to come out." } },
		},
	}),
	card({
		id = "cn_war",
		title = "Everywhere at Once",
		text = "Gates are opening in every country at the same hour: hundreds of them. Out of them come armies, not monsters, armies, with things leading them that speak. Every Hunter on Earth has been called up. Every civilian has been told to find shelter and stay there.",
		art = "street",
		tags = { "gate", "danger", "strange" },
		choices = {
			{ label = "Find shelter and stay there", clash = { stat = "luck", foe = "The war", coins = 1, base = 3, coinPower = 2, fixed = true }, win = { sanity = -12, codex = { "lore_war" }, log = "You spent the war in a basement with forty strangers and a radio. When it went quiet, nobody believed it for an hour." }, lose = { vitality = { -45, -15 }, sanity = -16, codex = { "lore_war" }, log = "The shelter took a hit. You were dug out on the third day.", cause = "Killed in the war at the end of the world" } },
			{ label = "Fight", hint = "Hunters only. Whatever your rank, this is the front.", requires = { form = HUNTERS }, clash = { stat = "strength", foe = "An army from the Gates", enemy = "gate_s", coins = 4, base = 36, coinPower = 10, fight = true, fixed = true }, win = { strength = 6, willpower = 8, money = { 200, 1200 }, sanity = -16, codex = { "lore_war" }, log = "You fought until there was nothing left to fight. You saw things in the sky you will never be able to describe to anyone." }, lose = { vitality = { -800, -300 }, codex = { "lore_war" }, log = "You fought.", cause = "Killed fighting in the war at the end of the world" } },
			{ label = "Keep a shelter running", hint = "Hunters only. Guard the people who can't fight.", requires = { form = HUNTERS }, clash = { stat = "vitality", foe = "Whatever finds the shelter", enemy = "gate_a", coins = 4, base = 22, coinPower = 8, fight = true, fixed = true }, win = { willpower = 6, charisma = 4, sanity = -10, codex = { "lore_war" }, log = "Two hundred people slept behind you for a week. All of them walked out." }, lose = { vitality = { -500, -200 }, codex = { "lore_war" }, log = "Something found the shelter.", cause = "Killed guarding a shelter in the war" } },
		},
	}),
	card({
		id = "cn_rewrite",
		title = "The World Is Rewritten",
		text = "It's over. Then, for one long moment, everything goes white, and you understand without knowing how that time is being turned back: to before the Gates, to a world where they never opened, where nobody will remember any of this. (CANON: the story ends this way. Choosing to stay is NOT canon; the game will say so.)",
		art = "street",
		tags = { "strange" },
		choices = {
			{
				label = "Let it happen (canon)",
				hint = "Your life goes on in a world that never had Gates. No rank, no Hunters. Nobody remembers. (Your years aren't turned back: a simplification.)",
				hwRewrite = true,
				result = { sanity = 10, codex = { "lore_rewrite" }, log = "You woke up on an ordinary morning. The sky was just the sky. You had the strangest feeling you'd forgotten something enormous." },
			},
			{
				label = "Stay on this world line (non-canon)",
				hint = "The Gates never close. From here on, this life is NOT the canon story; it's this game's own world line.",
				result = { setFlags = { "world_line_kept" }, sanity = -2, codex = { "lore_rewrite" }, log = "The white faded, and the Gates were still there. Whatever was supposed to happen didn't happen here. This world goes on." },
			},
		},
	}),
}
