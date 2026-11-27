--[[
	Gear, area A: ordinary things ordinary people carry. See Gear/Core.luau for the fields.
]]

return {
	order = { "bs_tool_roll", "bs_courier_jacket", "bs_house_key" },

	bs_tool_roll = { name = "Apprentice's Tool Roll", slot = "tool", price = 50, minAge = 12, desc = "Pliers, files and a little hammer, rolled up in oilcloth. A Workshop gives one to every apprentice who lasts a month.", effect = "+1 base in Intelligence and Health checks", clash = { intelligence = { base = 1 }, health = { base = 1 } }, look = { kind = "hammer" } },
	bs_courier_jacket = { name = "Courier's Jacket", slot = "coat", price = 70, minAge = 12, desc = "Reflective stripes, a dozen pockets, and the route map stitched inside the collar.", effect = "+1 base in Strength checks, hazards 10% less likely", clash = { strength = { base = 1 } }, hazardGuard = 0.9, look = { kind = "jacket", color = { 200, 150, 60 } } },
	bs_house_key = { name = "Key on a String", slot = "charm", price = 25, desc = "Your own front-door key on a string around your neck. Every Backstreets kid gets one, sooner or later.", effect = "+1 base in Mental Strength checks", clash = { mind = { base = 1 } }, look = { kind = "token", color = { 190, 160, 90 } } },
}
