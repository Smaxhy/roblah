--[[
	CAST for the adult City events (Events/Adult_City.luau, Adult_Fights.luau, Adult_Late.luau).
	Ids start with ad_. Recurring people who talk get a face here.
]]

return {
	-- the Halfmoon Office and Hana
	{ id = "ad_dalia", name = "Dalia Szabo", title = "Rep of the Halfmoon Office", look = {
		skin = "olive", hair = "bob", hairColor = "ash", eyes = "grey", outfit = "office_jacket", mark = "scar", accessory = "glasses", weapon = "blade" } },
	{ id = "ad_imre", name = "Assessor Imre", title = "Hana Association, rankings desk", look = {
		skin = "honey", hair = "slick", hairColor = "silverlight", eyes = "amber", outfit = "hana_formal", accessory = "monocle" } },
	{ id = "ad_odile", name = "Odile Brask", title = "Grade 6 Fixer", look = {
		skin = "fair", hair = "ponytail", hairColor = "chestnut", eyes = "grey", outfit = "fixer_coat", mark = "scar", weapon = "blade" } },

	-- the street: Syndicates, the Thumb, the Middle, the Index
	{ id = "ad_amparo", name = "Jefe Amparo", title = "Boss of the Copper Hounds", look = {
		skin = "bronze", hair = "sidecut", hairColor = "ember", eyes = "amber", outfit = "night_coat", mark = "ink", accessory = "earring", weapon = "pipe" } },
	{ id = "ad_tomas", name = "Tomas", names = { "Viktor", "Ander", "Joaquim" }, title = "Collects for the Copper Hounds", look = {
		skin = "olive", hair = "messy", hairColor = "ink", eyes = "brown", outfit = "rat_jacket", mark = "freckles" } },
	{ id = "ad_piero", name = "Piero", names = { "Anton", "Ciro", "Halvard" }, title = "Thumb Soldato, collects on your street", look = {
		skin = "peach", hair = "slick", hairColor = "ink", eyes = "dark", outfit = "thumb_suit", accessory = "fedora", weapon = "revolver" } },
	{ id = "ad_renata", name = "Big Sister Renata", title = "Big Sister of the Middle", look = {
		skin = "umber", hair = "braid", hairColor = "ink", eyes = "dark", outfit = "middle_jacket", mark = "family_tattoo", accessory = "sunglasses", weapon = "knuckles" } },
	{ id = "ad_wen", name = "Wen", title = "Proselyte of the Index", look = {
		skin = "fair", hair = "crop", hairColor = "platinum", eyes = "grey", outfit = "index_whites" } },
	{ id = "ad_lisandro", name = "Docent Lisandro", title = "Docent of the Ring", look = {
		skin = "pallid", hair = "curls", hairColor = "lilac", eyes = "green", outfit = "ring_smock", accessory = "mask" } },

	-- neighbors
	{ id = "ad_hedda", name = "Hedda Lund", title = "Runs the laundry across the landing", look = {
		skin = "fair", hair = "bun", hairColor = "straw", eyes = "blue", outfit = "work_overalls", accessory = "scarf_grey" } },
	{ id = "ad_pask", name = "Mr. Pask", title = "Your landlord", look = {
		skin = "sand", hair = "cap", hairColor = "ash", eyes = "brown", outfit = "streetwear", accessory = "glasses" } },
	{ id = "ad_haldor", name = "Haldor", names = { "Benno", "Ragnar", "Osric" }, title = "Smoke War veteran, bathhouse regular", look = {
		skin = "sand", hair = "shorn", hairColor = "snow", eyes = "grey", outfit = "work_overalls", mark = "scar", accessory = "scarf_red" } },
	{ id = "ad_sola", name = "Sola", title = "L Corp clerk, lives downstairs", look = {
		skin = "olive", hair = "bob", hairColor = "chestnut", eyes = "brown", outfit = "lcorp_suit" } },
	{ id = "ad_marten", name = "Marten Gale", title = "Rep of the Cinderbell Workshop", look = {
		skin = "amber", hair = "crop", hairColor = "charcoal", eyes = "hazel", outfit = "mechanic", mark = "scar", accessory = "round_glasses", weapon = "sledge" } },

	-- the Wings and stranger company
	{ id = "ad_fenwick", name = "Agent Fenwick", title = "W Corp Cleanup, Level 3", look = {
		skin = "pallid", hair = "slick", hairColor = "midnight", eyes = "aug_blue", outfit = "warp_conductor" } },
	{ id = "ad_ludmila", name = "Ludmila", title = "K Corp Class 2 Outreach Staff", look = {
		skin = "porcelain", hair = "ponytail", hairColor = "mint", eyes = "green", outfit = "nest_suit", accessory = "half_mask" } },
	{ id = "ad_ysolde", name = "Ysolde Ashgrave", title = "Of the Ashgrave Family", look = {
		skin = "pallid", hair = "long", hairColor = "bloodred", eyes = "bf_garnet", outfit = "bf_formal" } },
}
