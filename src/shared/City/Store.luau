--[[
	The City's store. Open because Config.store.sellInFanPacks = true: the owner's call for a
	small private game. Prices are suggestions; set your own on the Creator Dashboard and
	paste each product or pass id into `id`.

	Two currencies:
		Robux   Lunacy packs, passes (forever) and looks: Roblox's purchase prompt.
		Lunacy  rolls, boosts and Light, bought in game (`lunacy = cost`). Lunacy also drips in
		        from playing: a daily gift, every finished life, every new Record. Talent
		        rerolls in the creator cost Lunacy too (server/Progress.luau).

	Family-name rolls (and Lunacy talent rerolls) are paid random items: their odds are shown
	before buying, and the server hides them from players whose Roblox policy restricts paid
	random items.
	`consumable` items can be bought again; passes last forever.
	Grant keys are explained in src/server/Store.luau.
]]

local ROLL_ODDS = "Common 60% · Uncommon 25% · Rare 10% · Epic 4% · Legendary 1%. Rare or better guaranteed within 10 rolls."
local PREMIUM_ODDS = "Rare 66.7% · Epic 26.7% · Legendary 6.7%. Never Common or Uncommon."

return {
	note = "Lunacy buys rolls, boosts and Light, and rerolls your talent in the creator. Rolls show their odds before you buy. Passes last forever.",
	items = {
		-- ── Lunacy (Robux) ──
		{ key = "lunacy_60", kind = "product", id = 0, price = 25, tier = "Lunacy", consumable = true, name = "60 Lunacy", desc = "Two talent rerolls, or a Second Wind.", grants = { "lunacy:60" } },
		{ key = "lunacy_250", kind = "product", id = 0, price = 89, tier = "Lunacy", consumable = true, name = "250 Lunacy", desc = "220 Lunacy, plus 30 free.", bonus = "+30 free", grants = { "lunacy:250" } },
		{ key = "lunacy_700", kind = "product", id = 0, price = 229, tier = "Lunacy", consumable = true, name = "700 Lunacy", desc = "600 Lunacy, plus 100 free.", bonus = "+100 free", grants = { "lunacy:700" } },
		{ key = "lunacy_1600", kind = "product", id = 0, price = 449, tier = "Lunacy", consumable = true, name = "1,600 Lunacy", desc = "1,300 Lunacy, plus 300 free. The best rate.", bonus = "Best value", grants = { "lunacy:1600" } },

		-- ── family names (Lunacy) ──
		{ key = "rolls_3", lunacy = 40, tier = "Family names", consumable = true, random = true, odds = ROLL_ODDS, name = "3 Family-Name Rolls", desc = "Three more spins for a family name. Rarer names carry a trait into every life.", grants = { "rolls:3" } },
		{ key = "rolls_12", lunacy = 130, tier = "Family names", consumable = true, random = true, odds = ROLL_ODDS, name = "12 Family-Name Rolls", desc = "Ten rolls, plus two free.", grants = { "rolls:12" } },
		{ key = "premium_1", lunacy = 75, tier = "Family names", consumable = true, random = true, odds = PREMIUM_ODDS, name = "Rare-or-Better Roll", desc = "One roll that can only land a Rare, Epic or Legendary name.", grants = { "premiumRolls:1" } },
		{ key = "premium_5", lunacy = 300, tier = "Family names", consumable = true, random = true, odds = PREMIUM_ODDS, name = "5 Rare-or-Better Rolls", desc = "Five rolls that can only land Rare or better.", grants = { "premiumRolls:5" } },

		-- ── boosts (Lunacy) ──
		{ key = "boost_heal", lunacy = 50, tier = "Boosts", consumable = true, name = "Second Wind", desc = "+40 Health, +15 Sanity, and every treatable injury or illness gone.", grants = { "boost:heal" } },
		{ key = "boost_ahn", lunacy = 60, tier = "Boosts", consumable = true, name = "A Fortune", desc = "2,000 Ahn for the life you're living.", grants = { "boost:ahn:2000" } },
		{ key = "boost_mastery", lunacy = 60, tier = "Boosts", consumable = true, name = "A Master's Lesson", desc = "+2 mastery in your fighting style (up to 5).", grants = { "boost:mastery:2" } },
		{ key = "light_6", lunacy = 45, tier = "Boosts", consumable = true, name = "6 Light", desc = "Light unlocks origins, modes and looks.", grants = { "light:6" } },
		{ key = "light_25", lunacy = 160, tier = "Boosts", consumable = true, name = "25 Light", desc = "Twenty Light, plus five free.", grants = { "light:25" } },

		-- ── passes (Robux, forever) ──
		{ key = "pass_trait", kind = "pass", id = 0, price = 149, tier = "Passes", name = "Extra Trait", desc = "Born with one extra trait, picked at random, in every life.", grants = { "perk:extraTrait" } },
		{ key = "pass_points", kind = "pass", id = 0, price = 149, tier = "Passes", name = "Born Gifted", desc = "+2 to every stat at birth, in every life.", grants = { "perk:bonusPoints" } },
		{ key = "pass_bloodline", kind = "pass", id = 0, price = 199, tier = "Passes", name = "Bloodline", desc = "Unlocks the Kindred mode and the Raised by a Family origin, with Kindred Garnet eyes and a Family Noble coat.", grants = { "origin:bf_family_raised", "eyes:bf_garnet", "outfit:bf_noble" } },
		{ key = "pass_vip", kind = "pass", id = 0, price = 399, tier = "Passes", name = "Wing VIP", desc = "Extra Trait and Born Gifted, plus: 2 more free talent rerolls and double Lunacy every day, a free family-name roll daily, +1 Light per life, a star in chat, the VIP coat and a platinum file card.", grants = { "perk:vip", "perk:extraTrait", "perk:bonusPoints", "outfit:vip_coat", "frame:platinum" } },

		-- ── looks (Robux) ──
		{ key = "look_ego", kind = "product", id = 0, price = 129, tier = "Looks", name = "E.G.O Wardrobe", desc = "Four coats in the colors of famous E.G.O: Penitence, Solemn Lament, Justitia and the Lamp.", grants = { "outfit:egolook_penitence", "outfit:egolook_lament", "outfit:egolook_justitia", "outfit:egolook_lamp" } },
		{ key = "look_frames", kind = "product", id = 0, price = 59, tier = "Looks", name = "File Card Set", desc = "Velvet, Ivory and Night-Blue frames for your file card.", grants = { "frame:velvet", "frame:ivory", "frame:nightblue" } },
		{ key = "look_dyes", kind = "product", id = 0, price = 39, tier = "Looks", name = "Rare Dyes", desc = "Silverlight and Bloodline Red hair.", grants = { "hairColor:silverlight", "hairColor:bloodred" } },
		{ key = "look_arms", kind = "product", id = 0, price = 79, tier = "Looks", name = "Signature Arms", desc = "Three signature weapons your character carries: a Gilded Katana, a Jade Halberd and an Obsidian Greatsword.", grants = { "weapon:gilded_katana", "weapon:jade_halberd", "weapon:obsidian_greatsword" } },
	},
}
