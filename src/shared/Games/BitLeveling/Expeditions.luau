--[[
	GATE RAIDS you can choose to run (the DO tab): buy the raid rights from the Association,
	put a party together (solo or a crew), and go in stage by stage. ORIGINAL dungeons in the
	canon structure (raid rights, mining crews, a boss in the deepest chamber, the Gate
	closing about an hour after the boss dies). Costs and pay in million won.
]]
local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local function from(r)
	local out = {}
	for i = r, 6 do
		table.insert(out, HUNTERS[i])
	end
	return out
end

local function raid(def)
	local foe = def.foe
	return {
		name = def.name, kind = "dungeon", desc = def.desc,
		minAge = 16, cost = def.cost, cooldown = 1, open = true,
		when = { form = from(def.minRank), flags = { "licensed" } },
		crew = { min = 1, max = 4 }, length = 4, start = "entrance",
		stages = {
			entrance = {
				title = "The Gate",
				text = def.entrance,
				choices = {
					{ label = "Go in", result = { log = "{crew} went through the Gate." }, next = "tunnels" },
					{ label = "Sell the rights back", result = { log = "{crew} decided against it." }, ["end"] = "retreat" },
				},
			},
			tunnels = {
				title = "The Dungeon",
				text = def.tunnels,
				tone = "danger",
				choices = {
					{ label = "Fight through", clash = { stat = "strength", foe = def.monsters, enemy = foe, coins = def.coins, base = def.base, coinPower = def.power, fight = true, fixed = true }, win = { strength = 1, log = "{crew} cut a path to the deep chambers." }, lose = { vitality = def.hurt, log = "{crew} were pushed back, bleeding." }, winNext = "crystals", loseEnd = "fail" },
					{ label = "Scout a quieter route", clash = { stat = "agility", foe = "The dungeon's layout", coins = 2, base = math.floor(def.base * 0.7), coinPower = 3, fixed = true }, win = { agility = 1, log = "{crew} found a way round the worst of it." }, lose = { vitality = def.hurtSmall, log = "{crew} walked straight into a nest." }, winNext = "crystals", loseNext = "crystals" },
				},
			},
			crystals = {
				title = "The Deposit",
				text = "A vein of mana crystals glows in the wall. Electronics are dead in here; it's pickaxes or nothing.",
				choices = {
					{ label = "Mine it before the boss", clash = { stat = "luck", foe = "What the noise attracts", coins = 2, base = math.floor(def.base * 0.6), coinPower = 3, fixed = true }, win = { money = def.bonus, log = "{crew} filled two packs with crystal." }, lose = { vitality = def.hurtSmall, log = "The noise brought company." }, next = "boss" },
					{ label = "Leave it for the collection team", result = { log = "{crew} marked the vein and moved on." }, next = "boss" },
				},
			},
			boss = {
				title = "The Boss Room",
				text = def.bossText,
				tone = "danger",
				choices = {
					{ label = "Fight the boss", hint = "The boss of the Gate.", clash = { stat = "strength", foe = def.bossName, enemy = foe, coins = def.coins + 1, base = def.base + 3, coinPower = def.power + 1, fight = true, fixed = true, boss = true }, win = { strength = 2, willpower = 1, log = "The boss fell. An hour later the Gate began to close behind {crew}." }, lose = { vitality = def.hurt, log = "{crew} broke and ran.", cause = "Killed by a Gate boss" }, winEnd = "success", loseEnd = "fail" },
					{ label = "Pull out now", result = { log = "{crew} backed out of the boss room." }, ["end"] = "retreat" },
				},
			},
		},
		success = { money = def.pay, loot = { rank = def.minRank, chance = 0.85 }, log = "{crew} came out with the boss's core, a share of the crystals, and whatever the boss was guarding." },
		fail = { sanity = -4, log = "{crew} came out with nothing but wounds." },
		retreat = { log = "{crew} left the Gate to someone else." },
	}
end

return {
	order = { "raid_e", "raid_d", "raid_c", "raid_b", "raid_a" },
	raid_e = raid({ name = "E-rank Gate: Goblin Warren", minRank = 1, cost = 1, foe = "gate_e", monsters = "goblins", coins = 2, base = 4, power = 3, boss = "goblin_chief", bossName = "Goblin Chieftain",
		desc = "Cheap raid rights for a low-rank party. Goblins and a chieftain.", entrance = "{crew} bought the rights to a small Gate behind a bus depot. The Association's tag on it reads E.",
		tunnels = "Damp tunnels, the smell of animals, and chattering ahead.", bossText = "The chieftain sits on a throne of junk, a spear across its knees.",
		hurt = { -18, -6 }, hurtSmall = { -8, -2 }, bonus = { 1, 2 }, pay = { 2, 5 } }),
	raid_d = raid({ name = "D-rank Gate: Beetle Mine", minRank = 2, cost = 3, foe = "gate_d", monsters = "armoured beetles", coins = 2, base = 8, power = 4, boss = "goblin_chief", bossName = "The brood's guardian",
		desc = "An old mine full of armoured beetles. Good crystal.", entrance = "The Gate opened inside a disused quarry. The reading is D.",
		tunnels = "The walls click. Hundreds of shells catch your torchlight.", bossText = "Something huge is curled around the deepest deposit.",
		hurt = { -30, -12 }, hurtSmall = { -12, -4 }, bonus = { 2, 5 }, pay = { 5, 12 } }),
	raid_c = raid({ name = "C-rank Gate: Orc Stronghold", minRank = 3, cost = 8, foe = "gate_c", monsters = "orcs", coins = 3, base = 13, power = 5, boss = "orc_warlord", bossName = "Orc Warlord",
		desc = "A timber fortress full of orcs, and a warlord at the top.", entrance = "The Gate in the industrial park reads C. Inside, drums.",
		tunnels = "Palisades, watchtowers and orcs who know how to use them.", bossText = "The warlord stands in its hall with a cleaver taller than you.",
		hurt = { -50, -20 }, hurtSmall = { -20, -8 }, bonus = { 6, 14 }, pay = { 15, 35 } }),
	raid_b = raid({ name = "B-rank Gate: Frozen Cavern", minRank = 4, cost = 30, foe = "gate_b", monsters = "ice bears", coins = 3, base = 19, power = 6, boss = "frost_bear", bossName = "Alpha Ice Bear",
		desc = "Ice bears in a cavern that's always snowing.", entrance = "A B-rank Gate by the river. Frost is spreading out of it across the grass.",
		tunnels = "Snow underfoot, breath in clouds, and something big moving between the ice pillars.", bossText = "The alpha is twice the size of the others, and it has been waiting.",
		hurt = { -85, -36 }, hurtSmall = { -32, -12 }, bonus = { 20, 50 }, pay = { 60, 140 } }),
	raid_a = raid({ name = "A-rank Gate: Golem Ruins", minRank = 5, cost = 120, foe = "gate_a", monsters = "stone golems", coins = 4, base = 28, power = 8, boss = "golem_lord", bossName = "Golem Overlord",
		desc = "A sunken city of stone that gets up and walks. A guild-sized Gate.", entrance = "An A-rank Gate at a construction site. The guild that held the rights sold them on, quietly.",
		tunnels = "Statues that turn their heads as you pass.", bossText = "A golem the size of a building rises out of the central plaza.",
		hurt = { -140, -60 }, hurtSmall = { -50, -20 }, bonus = { 80, 200 }, pay = { 250, 600 } }),
}
