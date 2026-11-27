--[[
	BOSS DROPS (v0.15): what the big bosses (Events/Bosses_Fingers.luau) and the third shelf of
	adult stories (Events/Story_Second3.luau) leave in your hands. One of a kind; never sold.
]]

return {
	order = {
		"b15_brandimarte_revolver", "b15_ferrante_greatsword", "b15_ugo_chain", "b15_sereno_slip", "b15_amadeo_palette",
		"b15_sayo_blade", "b15_rhino_plate", "b15_bell_clapper", "b15_hostess_ribbon", "sl3_varga_sword", "sl3_old_blade",
	},

	b15_brandimarte_revolver = {
		name = "Brandimarte's Revolver", slot = "tool", rarity = "legendary", unique = true, keep = true,
		desc = "A Capo's revolver, given kneeling with both hands, as a beaten Capo must. Chambered for propellant rounds. The Thumb would very much like it back.",
		effect = "+1 coin and +3 base in Strength clashes. Your rounds burn. Strength can go 5 past its limit.",
		clash = { strength = { coins = 1, base = 3 } }, capBonus = { strength = 5 }, ability = { id = "burn", potency = 2 },
		look = { kind = "pistol", color = { 70, 60, 54 } },
	},
	b15_ferrante_greatsword = {
		name = "The Sottocapo's Blade", slot = "tool", rarity = "legendary", unique = true, keep = true,
		desc = "Lucrezia Ferrante's greatsword, with a propellant charge in the guard that drives every swing. She bowed when she gave it to you, exactly as deep as the Manual says.",
		effect = "+1 coin, +4 base and +1 per-heads power in Strength clashes. Burns. Strength can go 10 past its limit.",
		clash = { strength = { coins = 1, base = 4, coinPower = 1 } }, capBonus = { strength = 10 }, ability = { id = "burn", potency = 3 },
		look = { kind = "greatsword", color = { 160, 60, 40 } },
	},
	b15_ugo_chain = {
		name = "Big Brother Ugo's Chain", slot = "tool", rarity = "epic", unique = true, keep = true,
		desc = "Twice round the fist, the way the Middle wears it. Every Big Sibling who sees it will know exactly whose it was, and exactly which Title you're in.",
		effect = "+3 base in Strength clashes. Every blow you land opens the next wider (Rupture).",
		clash = { strength = { base = 3 } }, ability = { id = "rupture", potency = 2 },
		look = { kind = "chain", color = { 110, 110, 120 } },
	},
	b15_sereno_slip = {
		name = "A Prescript That Was Wrong", slot = "charm", rarity = "epic", unique = true, keep = true,
		desc = "Proxy Sereno's Prescript, folded small. Step eleven never happened. He gave it to you wondering, and the Index has never forgiven either of you.",
		effect = "+2 base in Intelligence and Mental Strength clashes. +1 Sanity a year.",
		clash = { intelligence = { base = 2 }, mind = { base = 2 } }, yearly = { sanity = 1 },
		look = { kind = "token", color = { 232, 230, 220 } },
	},
	b15_amadeo_palette = {
		name = "Amadeo's Palette", slot = "charm", rarity = "epic", unique = true, keep = true,
		desc = "A Docent's palette, every colour crusted on it, one of them not paint. He said the best pieces are always unfinished, and meant you.",
		effect = "+2 base in Charisma clashes, +1 coin in Speed clashes. Your cuts don't close (Bleed).",
		clash = { charisma = { base = 2 }, speed = { coins = 1 } }, ability = { id = "bleed", potency = 2 },
		look = { kind = "token", color = { 200, 120, 160 } },
	},
	b15_sayo_blade = {
		name = "Captain Sayo's Blade", slot = "tool", rarity = "legendary", unique = true, keep = true,
		desc = "A Kurokumo Captain's blade, sheath and all, given after one draw you survived. It's never been drawn slowly.",
		effect = "+1 coin and +3 base in Speed clashes, +5 Speed in fights. Bleed. Speed can go 10 past its limit.",
		clash = { speed = { coins = 1, base = 3 } }, speed = 5, capBonus = { speed = 10 }, ability = { id = "bleed", potency = 3 },
		look = { kind = "katana", color = { 30, 30, 36 } },
	},
	b15_rhino_plate = {
		name = "A Plate of the Rhino", slot = "coat", rarity = "legendary", unique = true, keep = true,
		desc = "One plate of R Corp's Rhino armour, cut down into something a person can wear. It's still warm some mornings, which nobody can explain.",
		effect = "You take 25% less Health damage. Resists Tremor 2. -1 coin in Speed clashes.",
		toughness = 0.75, resist = { tremor = 2 }, clash = { speed = { coins = -1 } },
		look = { kind = "greatcoat", color = { 80, 84, 92 } },
	},
	b15_bell_clapper = {
		name = "The Bellringer's Clapper", slot = "charm", rarity = "epic", unique = true, keep = true,
		desc = "The clapper of the last bell, cracked through. When it's quiet you can hear, very faintly, every word the Bellringer kept, giving itself back.",
		effect = "+3 base in Mental Strength clashes. Resists Sinking 2. -1 Sanity a year.",
		clash = { mind = { base = 3 } }, resist = { sinking = 2 }, yearly = { sanity = -1 },
		look = { kind = "bell", color = { 170, 140, 70 } },
	},
	b15_hostess_ribbon = {
		name = "The Hostess's Ribbon", slot = "charm", rarity = "epic", unique = true, keep = true,
		desc = "Left on the chandelier hook when the party ended. It's the colour of the last dance, and it never comes untied.",
		effect = "+2 base in Charisma clashes, +1 Luck. +2 Sanity a year.",
		clash = { charisma = { base = 2 } }, luck = 1, yearly = { sanity = 2 },
		look = { kind = "token", color = { 230, 120, 150 } },
	},
	sl3_varga_sword = {
		name = "Mrs. Varga's Sword", slot = "tool", rarity = "legendary", unique = true, keep = true,
		desc = "A retired Grade 1's sword: plain, long, perfectly kept. She pushed it across the table and said: feet first. Everything else is feet.",
		effect = "+1 coin and +2 base in Strength and Speed clashes. Riposte.",
		clash = { strength = { coins = 1, base = 2 }, speed = { coins = 1, base = 2 } }, ability = { id = "riposte", potency = 2 },
		look = { kind = "sword", color = { 210, 210, 216 } },
	},
	sl3_old_blade = {
		name = "The Hand-Me-Down", slot = "tool", rarity = "legendary", unique = true, keep = true,
		desc = "A Workshop blade with two names on the tang: a Grade 1's, thirty years gone, and under it now, yours. Nothing breaks it. That was the point.",
		effect = "+3 base and +1 per-heads power in Strength clashes. Strength can go 5 past its limit.",
		clash = { strength = { base = 3, coinPower = 1 } }, capBonus = { strength = 5 }, ability = { id = "guard", potency = 2 },
		look = { kind = "sword", color = { 180, 170, 150 } },
	},
}
