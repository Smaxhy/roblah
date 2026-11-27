--[[
	GEAR (ORIGINAL items in the canon economy: Hunters buy weapons and armour made from monster
	materials and mana crystals). Prices in million won. Slots: weapon, armor, charm.
]]
local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }

-- every weapon at every rarity (Hunter/Weapons.luau: 61 weapons x 3 stars x shiny or not)
local Weapons = require(script.Parent.Parent.Parent:WaitForChild("Hunter"):WaitForChild("Weapons"))

local list = {
	{ id = "gw_raid_vest", name = "Raid Vest", slot = "armor", price = 4, minAge = 16, rarity = "common", desc = "Kevlar, pouches, an Association patch. Stops a goblin's knife.", effect = "15% less damage taken.", toughness = 0.85, requires = { form = HUNTERS }, look = { kind = "jacket", color = { 60, 66, 76 } } },
	{ id = "gw_bear_coat", name = "Ice Bear Hide Coat", slot = "armor", price = 30, minAge = 18, rarity = "rare", desc = "Warm, tough, and a little terrifying to look at.", effect = "25% less damage taken; Mana Burn is weaker.", toughness = 0.75, resist = { burn = 1 }, requires = { form = HUNTERS }, look = { kind = "coat", color = { 230, 232, 236 } } },
	{ id = "gw_plate", name = "Golem-Plate Armour", slot = "armor", price = 120, minAge = 20, rarity = "epic", desc = "Stone-grey plates cut from an A-rank golem. A Tanker's dream.", effect = "35% less damage taken, +2 base in Vitality fights. Debuff: -1 Agility a year.", toughness = 0.65, clash = { vitality = { base = 2 } }, yearly = { agility = -1 }, requires = { form = { "hunter_b", "hunter_a", "hunter_s" } }, look = { kind = "coat", color = { 120, 124, 130 } } },
	{ id = "gw_jacket", name = "Good Winter Jacket", slot = "armor", price = 1, minAge = 10, rarity = "common", desc = "Not armour. Warm, though.", effect = "Bad years 10% less likely.", hazardGuard = 0.9, look = { kind = "jacket", color = { 40, 50, 70 } } },
	{ id = "gw_alert_band", name = "Gate Alert Band", slot = "charm", price = 1, minAge = 8, rarity = "common", desc = "Buzzes on your wrist when a Gate opens nearby.", effect = "Bad years 15% less likely.", hazardGuard = 0.85, look = { kind = "token" } },
	{ id = "gw_crystal_charm", name = "Crystal Charm", slot = "charm", price = 6, minAge = 14, rarity = "uncommon", desc = "A sliver of mana crystal on a cord. Hunters swear it steadies their nerve.", effect = "+2 Composure a year, +3% heads.", yearly = { sanity = 2 }, heads = 3, look = { kind = "stone", color = { 90, 170, 255 } } },
	{ id = "gw_healing_potion", name = "Healer's Draught", slot = "charm", price = 10, minAge = 16, rarity = "rare", desc = "A Healer's work in a bottle: one emergency, once a year.", effect = "+6 Vitality a year.", yearly = { vitality = 6 }, look = { kind = "bell" } },
}
for _, item in Weapons.gearList() do
	table.insert(list, item)
end
return list
