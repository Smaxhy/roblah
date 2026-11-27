--[[
	Earned traits from the Library and Distortion eras (writer D: lib_ / lim_ ids).
	None are pickable at creation: each one comes out of a story (see the event noted).
	Fields: see Traits/Core.luau.
]]

return {
	order = {
		"lib_read_pages", "lim_talks_them_down", "lim_bus_passenger", "lim_gold_eyes",
		"lim_second_wings", "lim_knight_errant", "lim_by_the_rules", "lim_steady_keel", "lim_light_heart",
	},

	-- the Library: a book you won and read closely (lib_book_you_took)
	lib_read_pages = { name = "Read the Pages", desc = "You read a Library book so closely that a few of its Combat Pages stayed with you. +1 potency in fights, +2 Strength.", stats = { strength = 2 }, fight = { potency = 1 } },
	-- a Distortion talked back from the edge (lim_neighbor arc, lim_distortion_alley, LCD cases)
	lim_talks_them_down = { name = "Talks Them Down", desc = "You talked a Distortion back from the edge once. People at the brink listen to your voice. +1 coin in Mental Strength checks.", clash = { mind = { coins = 1 } } },
	-- (from before v0.12, when a life could ride the bus; kept so older lives still read right)
	lim_bus_passenger = { name = "A Long Bus Ride", desc = "You once took a ride you shouldn't have. Nothing has frightened you as much since, including the driving. +3 heads chance.", heads = 3 },
	-- close to a Golden Bough (the Bough sites, the dig)
	lim_gold_eyes = { name = "Gold in the Eyes", desc = "You stood close to a Golden Bough and saw a memory that wasn't yours. +2 heads chance, +3 Mental Strength.", heads = 2, stats = { mind = 3 } },

	-- (from before v0.12, when a life could meet the Sinners; kept so older lives still read right)
	lim_second_wings = { name = "Second Wings", desc = "A quiet man on a rooftop asked if you would fly once more, and you did. +2 heads chance, +1 base in Mental Strength checks.", heads = 2, clash = { mind = { base = 1 } } },
	lim_knight_errant = { name = "Knight-Errant", desc = "You swore an oath of justice to someone who wanted to be a Fixer more than anything, and you kept it. +3 Strength, +1 base in fights.", stats = { strength = 3 }, fight = { base = 1 } },
	lim_by_the_rules = { name = "By the Rules", desc = "A very literal man taught you to read every rule to its last word. +4 Intelligence, +1 base in Intelligence checks.", stats = { intelligence = 4 }, clash = { intelligence = { base = 1 } } },
	lim_steady_keel = { name = "Steady Keel", desc = "A sailor who survived the Great Lake taught you to keep your head when the water rises. +4 Mental Strength, +1 base in Health checks.", stats = { mind = 4 }, clash = { health = { base = 1 } } },
	lim_light_heart = { name = "Light Heart", desc = "A rich boy from Hongyuan taught you that life goes on even when things flunk. +6 Sanity, +1 base in Intelligence checks.", sanity = 6, clash = { intelligence = { base = 1 } } },
}
