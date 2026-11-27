--[[
	THE STORE (server/Store.luau). Honest by design: no fake timers or scarcity, and odds shown
	before anything random. Prices are Robux suggestions; paste each product or pass id (from the
	Creator Dashboard) into `id`. Grant keys: "lunacy:<n>" (the premium currency, whatever meta.premiumName calls it),
	"perk:extraTrait", "perk:bonusPoints", "perk:vip", "outfit:<id>", "frame:<id>", "light:<n>"...
]]
return {
	note = "Gems buy boosts and looks. Passes last forever.",
	items = {
		{ key = "gems_60", kind = "product", id = 0, price = 25, tier = "Gems", consumable = true, name = "60 Gems", desc = "A little something.", grants = { "lunacy:60" } },
		{ key = "gems_250", kind = "product", id = 0, price = 89, tier = "Gems", consumable = true, name = "250 Gems", desc = "220 Gems, plus 30 free.", bonus = "+30 free", grants = { "lunacy:250" } },
		{ key = "pass_gifted", kind = "pass", id = 0, price = 149, tier = "Passes", name = "Born Gifted", desc = "+2 to every stat at birth, in every life.", grants = { "perk:bonusPoints" } },
		{ key = "boost_heal", lunacy = 50, tier = "Boosts", consumable = true, name = "Second Wind", desc = "+40 Health, +15 Mood, and every treatable injury gone.", grants = { "boost:heal" } },
	},
}
