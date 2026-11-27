--[[
	Records, area A: ordinary lives worth a shelf.
]]

return {
	{ id = "bs_rec_night", name = "Out After Three", desc = "Be caught outside during the Night, and live to see the morning.", check = { when = { flags = { "bs_night_survivor" } } } },
	{ id = "bs_rec_top_street", name = "Top of the Street", desc = "Reach the top of an ordinary trade: Restaurateur, Workshop Rep, Academy Owner, Route Owner, Clinic Owner, Chief Registrar or Street Owner.", check = { when = { flags = { "bs_ordinary_top" } } } },
	{ id = "bs_rec_gutter_up", name = "Out of the Gutter", desc = "Run with the Rats as a kid, and one day hold 5,000 Ahn at once.", check = { when = { flags = { "bs_rat_past" } }, minPeakMoney = 5000 } },
	{ id = "bs_rec_kept_door", name = "Kept the Door", desc = "Hold a night shelter's door open for strangers until the last second before 3:13.", check = { when = { flags = { "bs_kept_door" } } } },
}
