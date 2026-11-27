--[[
	Titles, danger and horror (dz_). "Erased" sits near the top (the Head's sentence is final);
	the rest go just before "Saw the Light".
]]

return {
	{ id = "dz_title_erased", name = "Erased", desc = "The Head removed them, and everything connected to them.", check = { causeHas = "erased" }, before = "color" },
	{ id = "dz_title_unsurvivable", name = "Survived the Unsurvivable", desc = "Lived through the thing nobody lives through.", check = { when = { flags = { "dz_unsurvivable" } } }, before = "light" },
	{ id = "dz_title_door", name = "Opened the Door", desc = "Someone knocked at 3:13, and they answered.", check = { causeHas = "door at 3:13" }, before = "light" },
	{ id = "dz_title_swept", name = "Swept Away", desc = "Caught outside when the Night came.", check = { causeHas = "swept" }, before = "light" },
}
