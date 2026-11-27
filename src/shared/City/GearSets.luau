--[[
	GEAR SETS (v0.13): carry two pieces of one Workshop's line for its first bonus, all three
	for the full one (Engine/Sim.luau activeSets). A bonus can add clash bonuses, Speed, and
	capBonus (how far past 100 a stat may go).
]]

return {
	halvard = {
		name = "The Halvard Line",
		two = { desc = "+2 base in Strength clashes.", clash = { strength = { base = 2 } } },
		three = { desc = "+1 coin in Strength clashes. Strength can go 5 past its limit.", clash = { strength = { coins = 1 } }, capBonus = { strength = 5 } },
	},
	atelier = {
		name = "Atelier Logic",
		two = { desc = "+4 Speed in fights.", speed = 4 },
		three = { desc = "+1 coin in Strength clashes, +4 more Speed in fights.", clash = { strength = { coins = 1 } }, speed = 4 },
	},
	lantern = {
		name = "Lantern Row",
		two = { desc = "+2 base in Mental Strength clashes.", clash = { mind = { base = 2 } } },
		three = { desc = "+1 coin in Mental Strength clashes. Mental Strength can go 5 past its limit.", clash = { mind = { coins = 1 } }, capBonus = { mind = 5 } },
	},
	tailor = {
		name = "Marlowe & Daughters",
		two = { desc = "+2 base in Charisma clashes.", clash = { charisma = { base = 2 } } },
		three = { desc = "+1 coin in Charisma clashes. Charisma can go 5 past its limit.", clash = { charisma = { coins = 1 } }, capBonus = { charisma = 5 } },
	},
	archivist = {
		name = "The Archivist's Kit",
		two = { desc = "+2 base in Intelligence clashes.", clash = { intelligence = { base = 2 } } },
		three = { desc = "+1 coin in Intelligence clashes. Intelligence can go 5 past its limit.", clash = { intelligence = { coins = 1 } }, capBonus = { intelligence = 5 } },
	},
	swallow = {
		name = "Swallow",
		two = { desc = "+6 Speed in fights.", speed = 6 },
		three = { desc = "+6 more Speed in fights, +1 base in Speed clashes. Speed can go 5 past its limit.", speed = 6, clash = { speed = { base = 1 } }, capBonus = { speed = 5 } },
	},
	greywall = {
		name = "Greywall",
		two = { desc = "+2 base in Health clashes.", clash = { health = { base = 2 } } },
		three = { desc = "+1 coin in Health clashes, +1 base in Strength clashes.", clash = { health = { coins = 1 }, strength = { base = 1 } } },
	},
}
