--[[
	Gear: one item per slot (tool = weapon, coat = armor, charm). Bought at a workshop or
	given by results (`gear = "id"`). look.kind is drawn on the character.
	Fields:
		name, slot, price, minAge, desc, requires (conditions), look
		            (tool kinds: knife, pole, pistol, sword, katana, greatsword, spear, axe,
		             hammer, gauntlet, censer, book, lamp; look.color tints it)
		effect      the plain-words line shown everywhere (buffs, then debuffs)
		rarity      common | uncommon | rare | epic | legendary | unreal (shown in color)
		clash       { [stat] = { coins, base, coinPower } } in clashes on that stat
		fight       { coins, base, coinPower, potency } in fights only
		style       the item only works with this fighting style (its buffs and debuffs)
		heads       +/- heads chance in every clash
		resist      { [status] = n } lowers a foe's status potency by n in fights
		toughness   share of Health damage you take (0.85 = 15% less)
		hazardGuard yearly bad luck is this much as likely; yearly = { stat = n } every year
		unique      true: not sold (boss drops and rewards)
	Every module in Gear/ is merged; ids must be unique.
]]

return {
	order = {
		-- weapons
		"workshop_knife", "baton", "fixer_notebook", "job_reports", "workshop_hammer", "atelier_pistol", "long_blade", "mechanical_fist",
		"quake_hammer", "crack_spear", "bleeding_knives", "pyrojade_gauntlet", "drowned_censer", "steady_katana", "capacitor_baton",
		-- armor
		"padded_jacket", "fixer_coat", "fireproof_duster", "insulated_coat", "office_suit", "plated_vest", "workshop_armor",
		-- charms
		"office_badge", "lucky_sticker", "moonlight_stone", "ampule", "green_pendant",
	},

	-- ── weapons ──
	workshop_knife = { name = "Workshop Knife", slot = "tool", price = 40, minAge = 14, rarity = "common", desc = "A cheap, honest blade with a workshop's mark on the handle.", effect = "+2 base in Strength clashes.", clash = { strength = { base = 2 } }, look = { kind = "knife" } },
	baton = { name = "Steel Baton", slot = "tool", price = 55, minAge = 12, rarity = "common", desc = "Collapsible. Popular with people who'd rather not use a blade.", effect = "+1 power per heads in Strength clashes.", clash = { strength = { coinPower = 1 } }, look = { kind = "baton" } },
	fixer_notebook = { name = "Fixer's Notebook", slot = "tool", price = 45, rarity = "common", desc = "Names, debts, favors, and which streets to avoid after midnight.", effect = "+2 base in Intelligence clashes.", clash = { intelligence = { base = 2 } }, look = { kind = "book", color = { 70, 60, 50 } } },
	job_reports = { name = "Bound Job Reports", slot = "tool", price = 60, rarity = "common", desc = "Other Fixers' job reports, bound and annotated.", effect = "+1 coin in Mental Strength clashes.", clash = { mind = { coins = 1 } }, look = { kind = "book", color = { 120, 40, 40 } } },
	workshop_hammer = { name = "Workshop Hammer", slot = "tool", price = 180, minAge = 16, rarity = "uncommon", desc = "Built for breaking doors, and whoever stands behind them.", effect = "+2 base in Health clashes, +1 in Strength.", clash = { health = { base = 2 }, strength = { base = 1 } }, look = { kind = "hammer" } },
	atelier_pistol = { name = "Atelier Logic Pistol", slot = "tool", price = 260, minAge = 18, rarity = "uncommon", desc = "Atelier Logic makes good guns. Bullets are expensive.", effect = "+1 coin in Strength clashes. Debuff: ammunition costs 15 Ahn a year.", clash = { strength = { coins = 1 } }, yearly = { money = -15 }, look = { kind = "pistol" } },
	long_blade = { name = "Workshop Long Blade", slot = "tool", price = 320, minAge = 18, rarity = "rare", desc = "A proper Fixer's sword. Heavy, balanced, and noticed.", effect = "+2 base and +1 power per heads in Strength clashes.", clash = { strength = { base = 2, coinPower = 1 } }, look = { kind = "sword" } },
	mechanical_fist = { name = "Prosthetic Fist", slot = "tool", price = 400, minAge = 18, rarity = "rare", desc = "A workshop prosthetic. It hits like a falling sign.", effect = "+1 coin in Health and Strength clashes. Debuff: phantom pain, -1 Sanity a year.", clash = { health = { coins = 1 }, strength = { coins = 1 } }, yearly = { sanity = -1 }, look = { kind = "gauntlet" } },

	-- style weapons: big bonuses, but only with their own fighting style
	quake_hammer = { name = "Quake Hammer", slot = "tool", price = 380, minAge = 18, rarity = "rare", style = "tremor", desc = "A sledge with a ringing head. Every blow keeps shaking after it lands.", effect = "Tremor style only: +2 base and +1 Tremor potency in fights. Debuff: -2% heads (it's heavy).", fight = { base = 2, potency = 1 }, heads = -2, look = { kind = "maul" } },
	crack_spear = { name = "Crack-Point Spear", slot = "tool", price = 380, minAge = 18, rarity = "rare", style = "rupture", desc = "The point is shaped to find seams in armor, and widen them.", effect = "Rupture style only: +1 coin and +1 Rupture potency in fights.", fight = { coins = 1, potency = 1 }, look = { kind = "spear" } },
	bleeding_knives = { name = "Paired Bleeding Knives", slot = "tool", price = 220, minAge = 16, rarity = "uncommon", style = "bleed", desc = "Two short, cruel blades. The cuts don't close on their own.", effect = "Bleed style only: +1 Bleed potency and +1 power per heads in fights.", fight = { potency = 1, coinPower = 1 }, look = { kind = "daggers" } },
	pyrojade_gauntlet = { name = "Pyrojade Gauntlet", slot = "tool", price = 360, minAge = 18, rarity = "rare", style = "burn", desc = "A Liu-pattern gauntlet with a jade furnace in the palm.", effect = "Burn style only: +2 base and +1 Burn potency in fights. Debuff: the heat, -1 Sanity a year.", fight = { base = 2, potency = 1 }, yearly = { sanity = -1 }, look = { kind = "gauntlets" } },
	drowned_censer = { name = "Drowned Bell Censer", slot = "tool", price = 340, minAge = 18, rarity = "rare", style = "sinking", desc = "Swing it and the room feels deeper than it is.", effect = "Sinking style only: +1 Sinking potency in fights, +1 coin in Mental Strength clashes.", fight = { potency = 1 }, clash = { mind = { coins = 1 } }, look = { kind = "censer" } },
	steady_katana = { name = "Steady-Hand Katana", slot = "tool", price = 520, minAge = 18, rarity = "epic", style = "poise", desc = "Folded steel and a grip worn smooth by someone very patient.", effect = "Poise style only: +2 Poise potency in fights and +4% heads.", fight = { potency = 2 }, heads = 4, look = { kind = "katana" } },
	capacitor_baton = { name = "Capacitor Baton", slot = "tool", price = 240, minAge = 16, rarity = "uncommon", style = "charge", desc = "Hums when you hold it. Hums louder before it lets go.", effect = "Charge style only: +1 Charge potency and +1 base in fights.", fight = { potency = 1, base = 1 }, look = { kind = "baton" } },

	-- ── armor ──
	padded_jacket = { name = "Padded Jacket", slot = "coat", price = 60, minAge = 12, rarity = "common", desc = "Quilted and stitched with something that stops small blades.", effect = "+1 base in Health clashes. Resists Bleed 1.", clash = { health = { base = 1 } }, resist = { bleed = 1 }, look = { kind = "jacket", color = { 90, 80, 70 } } },
	fixer_coat = { name = "Fixer's Long Coat", slot = "coat", price = 120, minAge = 16, rarity = "uncommon", desc = "The coat says Fixer. Most people step around it.", effect = "+1 base in Strength and Health clashes. Bad luck 15% less likely.", clash = { strength = { base = 1 }, health = { base = 1 } }, hazardGuard = 0.85, look = { kind = "greatcoat", color = { 46, 44, 52 } } },
	fireproof_duster = { name = "Fireproof Duster", slot = "coat", price = 180, minAge = 16, rarity = "uncommon", desc = "Treated canvas that smells of chemicals. Liu Fixers hate it.", effect = "Resists Burn 2. +1 base in Health clashes.", resist = { burn = 2 }, clash = { health = { base = 1 } }, look = { kind = "greatcoat", color = { 120, 96, 60 } } },
	insulated_coat = { name = "Insulated Longcoat", slot = "coat", price = 200, minAge = 16, rarity = "uncommon", desc = "Rubber-lined. Shocks and shakes slide off.", effect = "Resists Tremor 1 and Charge 1.", resist = { tremor = 1, charge = 1 }, look = { kind = "greatcoat", color = { 40, 50, 60 } } },
	office_suit = { name = "Nest Office Suit", slot = "coat", price = 300, rarity = "uncommon", desc = "The cut tells the checkpoint guards you belong inside.", effect = "Bad luck 30% less likely. +1 Sanity a year.", requires = { side = "nest" }, hazardGuard = 0.7, yearly = { sanity = 1 }, look = { kind = "coat", color = { 34, 36, 44 } } },
	plated_vest = { name = "Plated Vest", slot = "coat", price = 380, minAge = 18, rarity = "rare", desc = "Steel plates sewn into canvas. Not subtle.", effect = "You take 15% less Health damage. Resists Bleed 1 and Rupture 1. Debuff: -1 base in Strength clashes.", toughness = 0.85, resist = { bleed = 1, rupture = 1 }, clash = { strength = { base = -1 } }, look = { kind = "jacket", color = { 70, 74, 80 } } },
	workshop_armor = { name = "Workshop Armor Weave", slot = "coat", price = 450, minAge = 18, rarity = "rare", desc = "Armored cloth from a Workshop. Expensive, ugly, worth it.", effect = "+2 base in Health clashes. You take 10% less Health damage. Bad luck 25% less likely. Debuff: -2% heads.", clash = { health = { base = 2 } }, toughness = 0.9, hazardGuard = 0.75, heads = -2, look = { kind = "greatcoat", color = { 60, 66, 70 } } },

	-- ── charms ──
	office_badge = { name = "Office Badge", slot = "charm", price = 50, rarity = "common", desc = "Proof you belong to a licensed Office. Some doors open; some people back off.", effect = "+1 base in Strength and Mental Strength clashes.", requires = { flags = { "licensed_fixer" } }, clash = { strength = { base = 1 }, mind = { base = 1 } }, look = { kind = "bell", color = { 190, 190, 200 } } },
	lucky_sticker = { name = "Lucky Sticker", slot = "charm", price = 70, rarity = "common", desc = "A Wing's sticker that's supposed to raise your luck. It might even work.", effect = "+3% heads. +1 Sanity a year.", heads = 3, yearly = { sanity = 1 }, look = { kind = "token", color = { 255, 214, 90 } } },
	moonlight_stone = { name = "Moonlight Stone", slot = "charm", price = 90, rarity = "uncommon", desc = "M Corp's stone. Hold it and the noise in your head goes quiet.", effect = "+2 base in Mental Strength clashes. Resists Sinking 2.", clash = { mind = { base = 2 } }, resist = { sinking = 2 }, look = { kind = "stone", color = { 200, 214, 255 } } },
	ampule = { name = "Spare HP Ampule", slot = "charm", price = 150, rarity = "rare", desc = "One K Corp ampule on a cord. For the worst day of your life.", effect = "You take 15% less Health damage. Bad luck 20% less likely.", toughness = 0.85, hazardGuard = 0.8, look = { kind = "token", color = { 96, 220, 160 } } },
	green_pendant = { name = "Green Glow Pendant", slot = "charm", price = 600, minAge = 18, rarity = "epic", desc = "A sliver of something from L Corp, sealed in glass. It's warm.", effect = "+6% heads and +1 base in every fight. Debuff: -2 Sanity a year.", requires = { flags = { "lcorp_employee" } }, heads = 6, fight = { base = 1 }, yearly = { sanity = -2 }, look = { kind = "token", color = { 110, 255, 140 } } },
}
