--[[
	Ambitions of the Library and Distortion eras (writer D: lib_ / lim_ ids).
]]

return {
	{ id = "lib_amb_walk_out", name = "Sent home", desc = "Sign a Library invitation, and come home alive.", minAge = 16, maxAge = 60, weight = 6, when = { world = { era = "library" } }, check = { when = { flags = { "library_survivor" } } }, reward = { sanity = 4, log = "You signed, and the Library sent you home. Most people who sign are on a shelf." } },
	{ id = "lim_amb_bus", name = "The red bus", desc = "See Limbus Company's bus with your own eyes.", minAge = 12, maxAge = 75, weight = 8, when = { world = { era = "limbus" } }, check = { when = { flags = { "lim_saw_bus" } } }, reward = { sanity = 3, log = "You've seen it: a red bus with dark windows, engine ticking as it cools. Whoever rides it, the City steps round it." } },
	{ id = "lim_amb_bough", name = "Gold under the street", desc = "See a Golden Bough with your own eyes.", minAge = 14, maxAge = 80, weight = 6, when = { world = { era = "limbus" } }, check = { when = { flags = { "lim_bough_seen" } } }, reward = { mind = 2, log = "You've seen the gold light. Whatever Limbus Company wants with it, you'll never forget the color." } },
	{ id = "lim_amb_talk_down", name = "Bring one back", desc = "Talk a Distortion back from the edge.", minAge = 16, maxAge = 80, weight = 5, when = { world = { era = "limbus" } }, check = { when = { flags = { "lim_talked_down" } } }, reward = { sanity = 5, log = "Someone was nearly lost and you brought them back with nothing but words. You'll carry that the rest of your life, the good way." } },
	{ id = "lim_amb_manager", name = "Survive Preliminary Observation", desc = "Rise to Manager in Limbus Company's Before Team.", minAge = 20, maxAge = 70, weight = 6, when = { career = "limbus_lccb" }, check = { when = { flags = { "lim_lccb_manager" } } }, progress = { rank = 5 }, reward = { wage = { 100, 200 }, log = "From Preliminary Observer to Manager. Most of your training class never made it past the first year. You remember all their names." } },
}
