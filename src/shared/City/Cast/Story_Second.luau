-- Faces for the stories that find you as an adult (Storylines/Second.luau, Second2.luau) and
-- one for the Sweepers' Hour. They're known by what they are to you, so they have no other
-- names: the Story tab shows them with the line under `title`.
local function face(skin, hair, hairColor, eyes, outfit, accessory, weapon)
	return { skin = skin, hair = hair, hairColor = hairColor, eyes = eyes, outfit = outfit, accessory = accessory or "none", weapon = weapon or "none" }
end

return {
	-- Grade Nine
	{ id = "sl2_gn_rep", name = "The Rep", title = "Runs your Office from three desks", look = face("olive", "bun", "charcoal", "hazel", "office_jacket", "glasses") },
	{ id = "sl2_gn_examiner", name = "The examiner", title = "Hana's. Reads three years in an afternoon", look = face("fair", "slick", "ash", "grey", "hana_formal", "monocle") },
	-- The Fourth Pack
	{ id = "sl2_fp_tech", name = "The technician", title = "Keeps the tanks in the east hall", look = face("sand", "ponytail", "ink", "dark", "lab_coat", "round_glasses") },
	{ id = "sl2_fp_rabbit", name = "The Rabbit beside you", title = "On a sixth print. Remembers one", look = face("bronze", "shorn", "ash", "amber", "pack_fatigues") },
	-- Ten Seconds
	{ id = "sl2_ts_chief", name = "The crew chief", title = "Opens the first carriage", look = face("umber", "crop", "snow", "brown", "cleanup_jumpsuit") },
	{ id = "sl2_ts_rider", name = "The man who remembers", title = "Rides twice a week. Knows the corridors", look = face("pallid", "slick", "chestnut", "blue", "evening_jacket") },
	-- Borrowed Hours
	{ id = "sl2_bh_collector", name = "The collector", title = "T Corp's. Takes it in Ahn, or in time", look = face("peach", "crop", "charcoal", "grey", "nest_suit", "fedora") },
	{ id = "sl2_bh_clerk", name = "The counter clerk", title = "Explains your options with a pencil", look = face("honey", "bob", "auburn", "green", "nest_blazer", "glasses") },
	-- The Prescript (the Messenger is in Cast/Story_Lore.luau)
	{ id = "sl2_pr_proxy", name = "The Proxy", title = "Of the Index. Keeps a ledger of your slips", look = face("porcelain", "long", "ink", "dark", "index_whites", "none", "index_blade") },
	-- The Portrait
	{ id = "sl2_pt_docent", name = "The Docent", title = "Of the Ring. Admires your face", look = face("pallid", "bun", "snow", "amber", "ring_smock", "round_glasses") },
	{ id = "sl2_pt_student", name = "A Student of the Ring", title = "Carries the Docent's tools", look = face("sand", "messy", "rust", "hazel", "ring_smock") },
	-- Section Seven
	{ id = "sl2_s7_mother", name = "The woman on the stairs", title = "Her son is one of the eleven", look = face("deep", "braid", "charcoal", "brown", "work_overalls", "scarf_grey") },
	{ id = "sl2_s7_guard", name = "The clinic's guard", title = "Paid much too well for a clinic", look = face("fair", "shorn", "straw", "blue", "hired_guard", "sunglasses") },
	-- A Ticket to the Nest
	{ id = "sl2_nt_clerk", name = "The Nest clerk", title = "Counts the ways in on her fingers", look = face("amber", "bob", "ink", "dark", "nest_blazer") },
	{ id = "sl2_nt_guard", name = "The checkpoint guard", title = "A lamp, a desk, a bar across the road", look = face("olive", "crop", "umber", "hazel", "hired_guard") },
	-- The Arm
	{ id = "sl2_ar_owner", name = "The workshop owner", title = "Has all your measurements on a card", look = face("bronze", "ponytail", "rust", "green", "workshop_apron", "headband") },
	{ id = "sl2_ar_man", name = "The man at the gate", title = "All workshop. Never cold", look = face("pallid", "shorn", "ash", "grey", "mechanic", "half_mask") },
	-- A Canard
	{ id = "sl2_cn_nine", name = "The Grade 9", title = "New coat, borrowed sword", look = face("honey", "ponytail", "chestnut", "brown", "fixer_coat", "none", "blade") },
	{ id = "sl2_cn_clerk", name = "Hana's clerk", title = "Grades it without looking up", look = face("peach", "slick", "charcoal", "dark", "hana_formal", "glasses") },
	-- The Company Flat
	{ id = "sl2_cf_warden", name = "The floor warden", title = "Makes a note of everything", look = face("fair", "bun", "ash", "blue", "nest_formal", "round_glasses") },
	{ id = "sl2_cf_reviewer", name = "The reviewer", title = "A soft voice, and your whole file", look = face("umber", "bob", "ink", "amber", "nest_suit") },
	-- The Ampoule
	{ id = "sl2_am_stitcher", name = "The stitcher", title = "Has sewn up half your street", look = face("deep", "bun", "snow", "brown", "street_medic", "headband") },
	{ id = "sl2_am_clerk", name = "K Corp's clerk", title = "Kind. The price is the price", look = face("porcelain", "bob", "mint", "green", "nest_blazer") },
	-- The Sweepers' Hour
	{ id = "sl_sh_neighbour", name = "The old woman next door", title = "Chalks a line across her step", look = face("sand", "bun", "snow", "grey", "work_overalls", "scarf_red") },
}
