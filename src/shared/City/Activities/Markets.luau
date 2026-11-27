--[[
	Where to spend money (category "spend"): each opens a market (Markets.luau). Browsing is
	free, and buying never costs an action.
]]
return {
	{ id = "mk_overpass", category = "spend", name = "Walk the Overpass Market", desc = "Forty stalls under the old overpass. What's on the tables changes with the streets and with whatever the City is going through.", minAge = 10, market = "overpass" },
	{ id = "mk_kcorp", category = "spend", name = "Visit a K Corp pharmacy", desc = "HP ampules that heal you past whole, check-ups, and regeneration courses. Cheapest in District 11.", minAge = 12, market = "kcorp" },
	{ id = "mk_fixer_desk", category = "spend", name = "Hire a Fixer", desc = "Walk into an Office and hire someone: an escort, a bodyguard, a tutor, a go-between for a grudge.", minAge = 14, market = "fixer_desk" },
	{ id = "mk_letting", category = "spend", name = "See a letting agent", desc = "Buy a home of your own: a steel door, a safehouse, a houseboat, a whole building. It's yours until you sell it.", minAge = 16, market = "letting" },
	{ id = "mk_prosthetics", category = "spend", name = "See a prosthetics surgeon", desc = "Steel forearms, sprung knees, clockwork eyes: permanent, expensive, and frowned on in District 14.", minAge = 18, market = "prosthetics" },
}
