--[[
	CAST: people who talk in dialogue scenes and get a face (pack.cast).
	{ id = "ottavio", name = "Ottavio", names = { "Benedek", "Lorcan", "Anselm" }, title = "Retired Grade 4 Fixer", look = { ... } }
	look uses Cosmetics ids (any option): skin, hair, hairColor, eyes, outfit, mark, accessory, weapon.
	Leave look out and the person gets a face made from their id.
	Every module in this folder returns a list like this one.
]]

return {
	{ id = "ottavio", name = "Ottavio", names = { "Benedek", "Lorcan", "Anselm" }, title = "Retired Grade 4 Fixer", look = { skin = "olive", hair = "slick", hairColor = "ash", eyes = "grey", outfit = "fixer_coat", mark = "scar", accessory = "none", weapon = "none" } },
	{ id = "pigeon_keeper", name = "The Pigeon Keeper", title = "Lives on the roof", look = { skin = "umber", hair = "cap", hairColor = "snow", eyes = "brown", outfit = "work_overalls", accessory = "scarf_grey" } },
}
