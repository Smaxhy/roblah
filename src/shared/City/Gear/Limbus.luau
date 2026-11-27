--[[
	Gear from the Library and Distortion eras (writer D: lib_ / lim_ ids).
	Look kinds: see Engine/Avatar.luau (tool: lamp, book...; coat: greatcoat...).
]]

return {
	order = { "lib_library_book", "lim_scout_lamp", "lim_ego_coat" },

	-- won in a reception (Events/Library_Era.luau). Only someone who carried one out can get it rebound.
	lib_library_book = {
		name = "A Book from the Library",
		slot = "tool",
		price = 250,
		desc = "A whole person, bound in gilt. You keep finding passages in it that you need. (Only someone who carried a book out of the Library can have one rebound.)",
		effect = "+1 coin in Intelligence clashes, +1 base in Mental Strength clashes",
		requires = { flags = { "lib_book_owner" } },
		clash = { intelligence = { coins = 1 }, mind = { base = 1 } },
		look = { kind = "book", color = { 214, 178, 92 } },
	},
	lim_scout_lamp = {
		name = "LCCB Scout Lamp",
		slot = "tool",
		price = 140,
		minAge = 16,
		desc = "A Before Team lamp with a gold filter, for reading the dark inside buried L Corp branches. Limbus Company sells off the old models.",
		effect = "+1 base in Mental Strength and Health clashes, hazards 10% less likely",
		requires = { world = { era = "limbus" } },
		clash = { mind = { base = 1 }, health = { base = 1 } },
		hazardGuard = 0.9,
		look = { kind = "lamp", color = { 236, 196, 96 } },
	},
	lim_ego_coat = {
		name = "Attuned E.G.O Coat",
		slot = "coat",
		price = 650,
		minAge = 18,
		desc = "LCE test gear, drawn from an Abnormality's core. It fits a little too well, and it hums when you're angry. Sold to company staff only.",
		effect = "+1 coin in Health clashes, +1 base in Strength clashes, -1 Sanity a year",
		requires = { flags = { "lim_limbus_staff" } },
		clash = { health = { coins = 1 }, strength = { base = 1 } },
		yearly = { sanity = -1 },
		look = { kind = "greatcoat", color = { 118, 32, 44 } },
	},
}
