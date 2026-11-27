--[[
	Abilities learned from books (Books/). Earned, never picked.
]]

return {
	order = { "ab_shield_stance", "ab_flame_forms", "ab_investigator", "ab_hardblood_forms", "ab_unshaken" },

	ab_shield_stance = { name = "Shield Stance", desc = "Zwei footwork, for Zwei-trained feet: +1 base in fights, and you take 10% less Health damage.", fight = { base = 1 }, toughness = 0.9 },
	ab_flame_forms = { name = "Flame Forms", desc = "Burn style only: +1 Burn potency and +1 base in fights.", style = "burn", fight = { potency = 1, base = 1 } },
	ab_investigator = { name = "Investigator's Eye", desc = "+1 coin in Mental Strength checks.", clash = { mind = { coins = 1 } } },
	ab_hardblood_forms = { name = "Hardblood Forms", desc = "+1 coin in fights. Bloodfiends learn it best, but anyone can try.", fight = { coins = 1 } },
	ab_unshaken = { name = "Unshaken", desc = "+8% heads chance and +10 Sanity.", heads = 8, sanity = 10 },
}
