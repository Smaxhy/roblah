-- Faces for the third shelf of adult stories (Storylines/Second3.luau). Known by what they are
-- to you; the Story tab shows them with the line under `title`.
local function face(skin, hair, hairColor, eyes, outfit, accessory, weapon)
	return { skin = skin, hair = hair, hairColor = hairColor, eyes = eyes, outfit = outfit, accessory = accessory or "none", weapon = weapon or "none" }
end

return {
	-- Missing
	{ id = "sl3_mi_mother", name = "Mrs. Lenk", title = "From the flat below. Hasn't slept", look = face("olive", "bun", "chestnut", "brown", "work_overalls", "scarf_grey") },
	{ id = "sl3_mi_pia", name = "Pia Lenk", title = "Eleven. Sells paper flowers at the tram stop", look = face("olive", "braid", "chestnut", "brown", "hoodie") },
	-- The Old Office
	{ id = "sl3_oo_clerk", name = "The Hana clerk", title = "Has the dead Fixer's file. Likes you less every visit", look = face("fair", "slick", "ash", "grey", "hana_formal", "glasses") },
	{ id = "sl3_oo_client", name = "The last client", title = "Paid in full, eight years ago. Still waiting", look = face("umber", "crop", "snow", "brown", "night_coat") },
	-- The Parcel
	{ id = "sl3_pc_courier", name = "The courier", title = "Fell in your doorway. Gave you the key", look = face("sand", "messy", "ink", "dark", "streetwear", "headband") },
	{ id = "sl3_pc_buyer", name = "The woman with the better offer", title = "Turns up wherever the parcel goes", look = face("porcelain", "bob", "platinum", "light_gold", "nest_blazer", "sunglasses") },
	-- The Quiet Tenant
	{ id = "sl3_qt_fixer", name = "Old Mrs. Varga", title = "Upstairs. Grade 1, once. Sleeps with a sword", look = face("peach", "bun", "snow", "grey", "fixer_coat", "none", "blade") },
	{ id = "sl3_qt_hunter", name = "The young Fixer", title = "Wants to be the one who beat her", look = face("bronze", "sidecut", "crimson", "amber", "fixer_coat", "none", "blade") },
	-- Clean Books
	{ id = "sl3_cb_boss", name = "Mr. Holm", title = "Owns a laundry that washes very little", look = face("fair", "slick", "ink", "grey", "night_coat", "sunglasses", "revolver") },
	{ id = "sl3_cb_auditor", name = "The auditor", title = "Hana's. Reads ledgers for fun", look = face("honey", "bob", "auburn", "green", "hana_formal", "round_glasses") },
	-- Changing
	{ id = "sl3_ch_teodor", name = "Teodor", title = "Grew up with you. Can hear his clock thinking", look = face("sand", "messy", "umber", "hazel", "work_overalls") },
	{ id = "sl3_ch_fixer", name = "The Fixer from the Association", title = "Has a file of people who changed", look = face("deep", "crop", "charcoal", "dark", "seven_style", "glasses", "sword_cane") },
	-- The Grudge Book
	{ id = "sl3_gb_big", name = "Big Sister Orsola", title = "Of the Middle. Reads the Book aloud", look = face("umber", "braid", "ink", "dark", "middle_jacket", "none", "middle_chain") },
	{ id = "sl3_gb_little", name = "Little Brother Nino", title = "Of the Middle. Was beaten on your street", look = face("sand", "crop", "ink", "dark", "middle_jacket") },
	-- The Pit
	{ id = "sl3_pt_owner", name = "The pit owner", title = "Pays from the door. Never fights", look = face("amber", "shorn", "charcoal", "brown", "night_coat", "big_shades") },
	{ id = "sl3_pt_champion", name = "The Ox", title = "Champion of the pit. Undefeated in four years", look = face("bronze", "shorn", "ash", "amber", "work_overalls", "none", "maul") },
	-- The Hand-Me-Down
	{ id = "sl3_hd_smith", name = "The old smith", title = "Made the blade. Remembers who carried it", look = face("bronze", "ponytail", "snow", "green", "workshop_apron", "headband") },
	{ id = "sl3_hd_seeker", name = "The man in grey", title = "Has been looking for the blade for twenty years", look = face("pallid", "long", "ash", "grey", "night_coat", "half_mask", "blade") },
	-- The Last Stop
	{ id = "sl3_ls_driver", name = "The night driver", title = "Drives the bus after the last bus", look = face("pallid", "crop", "ink", "light_gold", "cleanup_jumpsuit", "fedora") },
	{ id = "sl3_ls_rider", name = "The passenger at the back", title = "Has been riding for a long time", look = face("porcelain", "long", "lilac", "grey", "night_coat", "mask") },
}
