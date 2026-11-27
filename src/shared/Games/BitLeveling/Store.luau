--[[
	THE STORE. BitLeveling is a non-commercial fan game (spec fanWork = true), so the Robux
	store is OFF unless Config.store.sellInFanPacks is switched on, which is the owner's call
	and not recommended for someone else's IP. What's here can be earned with Mana in play.
	Honest by design: no timers, no fake scarcity, odds before anything random.
]]
return {
	note = "Crystals buy small boosts. Nothing here changes your Hunter rank: rank is rolled, never sold.",
	items = {
		{ key = "boost_heal", lunacy = 50, tier = "Boosts", consumable = true, name = "Healer's Visit", desc = "+40 Vitality, +15 Composure, and every treatable injury gone.", grants = { "boost:heal" } },
	},
}
