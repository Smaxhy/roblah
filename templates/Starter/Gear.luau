--[[
	GEAR: one item per slot (spec.gear.slots). Each:
		id, name, slot, price, minAge, desc, effect (the line the shop shows),
		clash = { <stat id> = { coins, base, coinPower } }, yearly = {...}, hazardGuard = 0.85,
		resist = { burn = 2 }, requires = {...}, look = { kind = "sword" | "knife" | "spear" |
		"axe" | "hammer" | "coat" | "jacket" | "book" | "stone" | "bell" | "token" | ..., color = {...} }
]]
return {
	{ id = "short_sword", name = "Short Sword", slot = "tool", price = 60, minAge = 14, desc = "Plain and sharp.", effect = "+2 base power in Strength fights", clash = { strength = { base = 2 } }, look = { kind = "sword" } },
	{ id = "padded_coat", name = "Padded Coat", slot = "coat", price = 80, desc = "Quilted canvas that has stopped a knife or two.", effect = "+1 base in Strength fights, bad years 15% less likely", clash = { strength = { base = 1 } }, hazardGuard = 0.85, look = { kind = "jacket", color = { 122, 98, 70 } } },
	{ id = "lucky_coin", name = "Lucky Coin", slot = "charm", price = 35, desc = "Heads every time. Almost.", effect = "+1 mood a year", yearly = { sanity = 1 }, look = { kind = "token" } },
}
