--[[
	Today in the City: daily scenes from writer D (lib_ / lim_ ids). The same event plays
	for every life in every era, so the scenes are written to work before and after the
	Light: odd, small, and a little uncanny. Events: Events/Limbus_Daily.luau.
]]

return {
	order = { "lim_clock_mender", "lib_lost_pages", "lim_gold_gutters" },
	lim_clock_mender = { name = "The Clock Mender", desc = "A clock mender has set up a stall on the corner. One of her clocks ticks like it's trying to say something.", event = "lim_daily_clocks" },
	lib_lost_pages = { name = "Pages in the Wind", desc = "Loose pages from somebody's life story are blowing down every street in the District.", eras = { "library", "limbus" }, event = "lib_daily_pages" },
	lim_gold_gutters = { name = "Gold in the Gutters", desc = "The street cleaners keep finding gold-glinting dust in the gutters. Nobody knows where it comes from.", eras = { "limbus" }, event = "lim_daily_gold" },
}
