--[[
	EXPEDITIONS: dungeons, missions and trips, played stage by stage (Engine/Expedition.luau).
	A run's tier (I to V) comes from its strongest clash: harder runs pay more on success.
		name, desc, kind = "dungeon" | "mission" | "trip", minAge, cost, cooldown,
		crew = { min, max }, length, when, start = "<first stage>", open = true (listed for all),
		stages = { [id] = { title, text, tone, choices = { { label, hint, result | clash + win
		                    + lose, next | winNext | loseNext, end | winEnd | loseEnd } } } },
		success, fail, retreat (results at the end)
]]
return {
	order = { "old_mine" },
	old_mine = {
		name = "The Old Mine",
		kind = "dungeon",
		desc = "The mine above town closed twenty years ago. Something is still digging down there.",
		minAge = 16, cost = 0, cooldown = 3, open = true,
		crew = { min = 1, max = 3 },
		length = 3,
		start = "entrance",
		stages = {
			entrance = {
				title = "The Entrance",
				text = "{crew} light lamps at the mouth of the mine. The air coming up is warm.",
				choices = {
					{ label = "Go in", result = { log = "{crew} went in." }, next = "tunnels" },
					{ label = "Not today", result = { log = "{crew} turned back." }, ["end"] = "retreat" },
				},
			},
			tunnels = {
				title = "The Tunnels",
				text = "The tunnels fork. Something big moved through here recently.",
				tone = "danger",
				choices = {
					{ label = "Follow the tracks", clash = { stat = "strength", foe = "Something in the tunnels", enemy = "rat_king", coins = 3, base = 6, coinPower = 3, fight = true }, win = { strength = 2, log = "{crew} drove it off." }, lose = { health = { -16, -6 }, log = "It drove {crew} back." }, winNext = "vault", loseEnd = "fail" },
					{ label = "Take the quiet fork", clash = { stat = "smarts", foe = "A maze of tunnels", coins = 2, base = 5, coinPower = 3 }, win = { smarts = 1, log = "{crew} found a way around." }, lose = { sanity = -3, log = "{crew} got lost for a day." }, winNext = "vault", loseNext = "vault" },
				},
			},
			vault = {
				title = "The Old Vault",
				text = "At the bottom: the old payroll vault, its door hanging open.",
				choices = {
					{ label = "Take what's left", result = { log = "{crew} filled their packs." }, ["end"] = "success" },
				},
			},
		},
		success = { money = { 200, 500 }, log = "{crew} came back up with the mine's last payroll." },
		fail = { sanity = -4, log = "{crew} came back up with nothing but bruises." },
		retreat = { log = "The mine will still be there." },
	},
}
