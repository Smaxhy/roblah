--[[
	ACTIVITIES of this game's own (Base gives one per stat, healing, the shop, odd jobs, moving).
	Same shape as a card's choice, plus id, name, desc, category ("self" | "money" | "gear" |
	"people" | "home"), minAge, maxAge, cost, cooldown, when.
]]
return {
	{
		id = "st_fishing",
		category = "self",
		name = "Go fishing",
		desc = "A quiet river, a long afternoon.",
		minAge = 6,
		result = { sanity = { 2, 5 }, money = { 0, 12 }, log = "You fished all afternoon. Sometimes the fish even cooperated." },
	},
}
