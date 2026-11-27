--[[
	More careers, merged into pack.careers: { order = { ids }, [id] = career }.
	Same format as the careers in init.luau.
		warden     the Tidewell Institute: keepers for the Remnants in the sealed vaults
		           under Glasswall (events in Events/Tidewell.luau)
		conductor  the Undertow Line: the Sluice Authority's sealed express cars through
		           the drowned aqueducts (events in Events/Conductor.luau)
	Career activities for both live in CareerActivities.luau.
]]

return {
	order = { "warden", "conductor" },

	warden = {
		name = "Tidewell Institute",
		desc = "Keep the living things the Institute dredges out of the Mere, in sealed vaults under Glasswall. Each one needs something different. The pay is very good, and nobody says why.",
		ranks = { "Night Porter", "Under-Keeper", "Keeper", "Vault Warden", "Director of the Vaults" },
		salary = { 80, 150, 270, 460, 820 },
		minAge = 18,
		requires = { min = { prudence = 25 } },
		promoteStat = "prudence",
		promoteAt = { 35, 50, 65, 80 }, -- Prudence needed to reach rank 2, 3, 4, 5
		yearsPerRank = 3,
		yearly = { sanity = -1 }, -- the vaults get into you
		hazard = {
			chance = 0.08,
			result = {
				fortitude = { -8, -3 },
				sanity = { -5, -2 },
				condition = "night_terrors",
				log = "A vault door failed for nine seconds on your shift. You held the corridor with a lamp and a whistle until it sealed again, and you haven't slept properly since.",
				cause = "Lost in the Tidewell vaults",
			},
		},
	},

	conductor = {
		name = "Undertow Line",
		desc = "Ride the Sluice Authority's sealed express cars through the drowned aqueducts under the city. Punch the tickets, keep the peace, and never open a door between stations.",
		ranks = { "Ticket Punch", "Carriage Guard", "Conductor", "Night Conductor", "Line Master" },
		salary = { 45, 90, 170, 300, 560 },
		minAge = 16,
		requires = { min = { justice = 20 } },
		promoteStat = "justice",
		promoteAt = { 30, 45, 60, 76 }, -- Justice needed to reach rank 2, 3, 4, 5
		yearsPerRank = 2,
		hazard = {
			chance = 0.07,
			result = {
				fortitude = { -9, -4 },
				sanity = { -3, -1 },
				condition = "broken_arm",
				log = "The car lurched on the long bend under Saltpan, and a sealed door caught your arm as it swung shut.",
				cause = "Lost in the Undertow tunnels",
			},
		},
	},
}
