--[[
	Records, danger and horror (dz_): the nights nobody should have lived through.
]]

return {
	{ id = "dz_rec_unsurvivable", name = "Survived the Unsurvivable", desc = "Live through something nobody lives through.", check = { when = { flags = { "dz_unsurvivable" } } } },
	{ id = "dz_rec_eighty_minutes", name = "Eighty Minutes", desc = "Carry a parcel across a District during the Night, and deliver it.", check = { when = { flags = { "done_dz_ex_long_night" } } } },
	{ id = "dz_rec_past_the_wall", name = "Past the Last Wall", desc = "Go out into the Outskirts and come back.", check = { when = { flags = { "done_dz_ex_outskirts" } } } },
	{ id = "dz_rec_number_nine", name = "Number Nine", desc = "Walk out of Number Nine, Bellhouse Row.", check = { when = { flags = { "dz_nine_escaped" } } } },
	{ id = "dz_rec_witness", name = "Witness", desc = "See the Claws at work, and live.", check = { when = { flags = { "dz_claw_witness" } } } },
	{ id = "dz_rec_never_was", name = "Never Was", desc = "Be erased by the Head.", check = { causeHas = "erased" } },
}
