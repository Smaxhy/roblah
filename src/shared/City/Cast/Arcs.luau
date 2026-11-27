--[[
	CAST for Events/Story_Arcs.luau and Story_Arcs2.luau: the recurring people of the eight
	long story arcs (childhood hook, payoff at 18-35). The pigeon keeper and Ottavio come from
	Cast/Core.luau. Titles stay vague while the player is a child, so a face never names a
	faction before the life has heard of it.
]]

return {
	-- The Open Contract (Dae and the Steam Ledger)
	{ id = "ar_dae", name = "Dae", names = { "Min", "Sol", "Ari" }, title = "Your cousin. Sleeps by the door", look = {
		skin = "sand", hair = "messy", hairColor = "ink", eyes = "brown", outfit = "hoodie", mark = "freckles", accessory = "none" } },
	{ id = "ar_dae_grown", name = "Dae", names = { "Min", "Sol", "Ari" }, title = "Contract 0447, the Steam Ledger", look = {
		skin = "sand", hair = "slick", hairColor = "ink", eyes = "brown", outfit = "night_coat", mark = "scar", accessory = "none" } },
	{ id = "ar_mott", name = "Clerk Mott", title = "Counts years for the Steam Ledger", look = {
		skin = "pallid", hair = "crop", hairColor = "charcoal", eyes = "grey", outfit = "office_jacket", accessory = "round_glasses" } },

	-- Not Before Sixteen (the letter)
	{ id = "ar_white", name = "The Man in White", title = "Delivers letters at noon", look = {
		skin = "fair", hair = "slick", hairColor = "snow", eyes = "grey", outfit = "index_whites", accessory = "glasses" } },
	{ id = "ar_imke", name = "Imke", title = "Sits behind you at the academy", look = {
		skin = "peach", hair = "braid", hairColor = "straw", eyes = "blue", outfit = "academy_uniform", accessory = "round_glasses" } },
	{ id = "ar_noemi", name = "Noemi", title = "Proxy of the Index", look = {
		skin = "olive", hair = "bob", hairColor = "charcoal", eyes = "light_gold", outfit = "index_whites", accessory = "scarf_grey" } },

	-- Valid Until Used (the pigeon keeper's ticket)
	{ id = "ar_vesna", name = "Vesna", title = "W Corp cleanup crew, Car 9", look = {
		skin = "umber", hair = "ponytail", hairColor = "snow", eyes = "aug_blue", outfit = "warp_conductor", accessory = "none" } },

	-- The Theater Next Door
	{ id = "ar_coralie", name = "Coralie", names = { "Maren", "Isaure", "Bettina" }, title = "Lives in the theater next door", look = {
		skin = "pallid", hair = "twintails", hairColor = "midnight", eyes = "bf_garnet", outfit = "bf_formal", accessory = "none" } },
	{ id = "ar_ysolde", name = "Madame Ysolde", title = "Sweeps the theater steps at dusk", look = {
		skin = "pallid", hair = "bun", hairColor = "snow", eyes = "bf_red", outfit = "bf_noble", accessory = "none" } },

	-- Chalk Faces
	{ id = "ar_pia", name = "Pia", names = { "Nell", "Ysolde", "Hana-rae" }, title = "Draws faces in chalk", look = {
		skin = "bronze", hair = "messy", hairColor = "rust", eyes = "green", outfit = "work_overalls", mark = "freckles", accessory = "headband" } },
	{ id = "ar_pia_grown", name = "Pia", names = { "Nell", "Ysolde", "Hana-rae" }, title = "Draws what's under the face", look = {
		skin = "bronze", hair = "ponytail", hairColor = "rust", eyes = "green", outfit = "ring_smock", mark = "freckles", accessory = "none" } },
	{ id = "ar_lisandro", name = "Docent Lisandro", title = "A Docent of the Ring", look = {
		skin = "porcelain", hair = "curls", hairColor = "lilac", eyes = "green", outfit = "ring_smock", accessory = "half_mask" } },

	-- Little Brother (the family debt)
	{ id = "ar_lasse", name = "Brother Lasse", names = { "Brother Aurel", "Brother Tam", "Brother Josef" }, title = "Calls your father Little Brother", look = {
		skin = "sand", hair = "crop", hairColor = "ink", eyes = "dark", outfit = "middle_jacket", mark = "family_tattoo", accessory = "none" } },
	{ id = "ar_jory", name = "Jory", names = { "Emery", "Robin", "Kit" }, title = "Keeps a notebook of grudges", look = {
		skin = "sand", hair = "spiky", hairColor = "ink", eyes = "dark", outfit = "streetwear", accessory = "none" } },
	{ id = "ar_jory_grown", name = "Jory", names = { "Emery", "Robin", "Kit" }, title = "Little Brother of the Middle", look = {
		skin = "sand", hair = "crop", hairColor = "ink", eyes = "dark", outfit = "middle_jacket", mark = "family_tattoo", accessory = "sunglasses" } },
	{ id = "ar_halla", name = "Big Sister Halla", title = "Keeps the Book of Vengeance", look = {
		skin = "umber", hair = "long", hairColor = "ash", eyes = "dark", outfit = "middle_jacket", mark = "family_tattoo", accessory = "round_glasses" } },

	-- A Name on the Tang (the Workshop apprentice)
	{ id = "ar_tibor", name = "Tibor", names = { "Laszlo", "Fenn", "Goran" }, title = "Apprentice at the corner Workshop", look = {
		skin = "amber", hair = "spiky", hairColor = "auburn", eyes = "hazel", outfit = "mechanic", accessory = "headband" } },
	{ id = "ar_tibor_grown", name = "Tibor", names = { "Laszlo", "Fenn", "Goran" }, title = "Tibor Works, the crooked T", look = {
		skin = "amber", hair = "crop", hairColor = "auburn", eyes = "hazel", outfit = "mechanic", mark = "scar", accessory = "glasses" } },
	{ id = "ar_grisel", name = "Master Grisel", title = "Owns the Workshop. Owes everyone", look = {
		skin = "olive", hair = "shorn", hairColor = "snow", eyes = "grey", outfit = "mechanic", accessory = "glasses" } },
	{ id = "ar_maren", name = "Maren", title = "Fixer. Carries your name", look = {
		skin = "deep", hair = "sidecut", hairColor = "charcoal", eyes = "amber", outfit = "fixer_coat", accessory = "earring", weapon = "blade" } },

	-- Three Red Stamps (the Hana exam)
	{ id = "ar_holm", name = "Examiner Holm", title = "Hana Association", look = {
		skin = "sand", hair = "slick", hairColor = "snow", eyes = "grey", outfit = "hana_formal", accessory = "glasses" } },
	{ id = "ar_marthe", name = "Marthe Brin", title = "Runs a noodle stall. Owes money", look = {
		skin = "honey", hair = "bun", hairColor = "ash", eyes = "brown", outfit = "diner_whites", accessory = "scarf_red" } },
}
