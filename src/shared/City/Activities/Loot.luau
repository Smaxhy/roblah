--[[
	Activities for loot (bl_ ids):
	  - the Overpass Stacks, a black-market bookshop. A Mental Strength check decides which shelf
	    Hollis shows you; which book is on it depends on how the streets are this year.
	  - Ironsong Atelier, which re-tunes a Workshop style weapon into a unique one. One
	    activity per weapon, and each only shows while you carry that weapon, so the menu
	    holds at most one of them.
]]

local function retune(from: string, to: string, weapon: string, cost: number, log: string)
	return {
		id = "bl_act_tune_" .. from,
		category = "gear",
		name = "Re-tune your " .. weapon .. " at Ironsong",
		desc = "Master Tuner Oriane re-tunes it to ring for its style alone: a unique weapon, stronger than anything for sale. " .. cost .. " Ahn.",
		minAge = 16,
		cost = cost,
		cooldown = 1,
		when = { hasGear = from },
		result = { gear = to, setFlags = { "bl_tuned_weapon" }, codex = "bl_lore_ironsong", log = log },
	}
end

return {
	{
		id = "bl_act_overpass_books",
		category = "city",
		name = "Browse the Overpass Stacks",
		desc = "Hollis sells books under the overpass that no Wing would let out. The stock changes with the streets, and some of it is real.",
		minAge = 12,
		cooldown = 1,
		clash = { stat = "mind", foe = "Hollis's forgeries", coins = 2, base = 5, coinPower = 3 },
		win = { codex = "bl_lore_overpass", trigger = "bl_shop_back_room", log = "You spotted every fake on the front table. Hollis, impressed, lifted the curtain to the back room." },
		lose = { codex = "bl_lore_overpass", trigger = "bl_shop_front_table", log = "Hollis steered you to the front table, where the honest books are cheap and the cheap books are mostly honest." },
	},

	retune("quake_hammer", "bl_tuned_quake", "Quake Hammer", 350, "Oriane listened to the hammer for an hour before she touched it. When she handed it back, it rang at the pitch of whatever it struck."),
	retune("crack_spear", "bl_tuned_spear", "Crack-Point Spear", 350, "Oriane split the point like a tuning fork. It hummed in your hand all the way home."),
	retune("bleeding_knives", "bl_tuned_knives", "Bleeding Knives", 250, "Oriane balanced the pair against each other until they sang when they crossed."),
	retune("pyrojade_gauntlet", "bl_tuned_pyrojade", "Pyrojade Gauntlet", 350, "Oriane fitted a second jade furnace in the knuckles and tuned it to the first. Now they roar in harmony."),
	retune("drowned_censer", "bl_tuned_censer", "Drowned Bell Censer", 350, "Oriane lowered its note by an octave. The whole Workshop felt deeper when she tested it."),
	retune("steady_katana", "bl_tuned_katana", "Steady-Hand Katana", 600, "Oriane re-folded the blade over three days. It hums now at the pitch of a held breath."),
	retune("capacitor_baton", "bl_tuned_capacitor", "Capacitor Baton", 250, "Oriane rewound it with finer wire. It hums a chord now, louder just before it lets go."),
}
