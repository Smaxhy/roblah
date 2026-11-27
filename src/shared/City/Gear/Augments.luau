--[[
	AUGMENT ARMS (v0.17): the "arm" slot. In the City a body is something you can have worked
	on: Workshops fit mechanical arms, K Corp's clinics grow them, and back-alley clinics in
	the Backstreets graft what nobody else will. An arm replaces your left arm on your figure
	(Engine/Avatar.luau draws it), raises the ceiling of what it's built for, and carries its
	own way of fighting (City/Techniques.luau, arm_*: pick it when a fight starts).

	Canon behind them: G Corp's soldiers came home from the Smoke War with insect grafts
	(Limbus, Gregor); K Corp's regeneration science grows flesh back; R Corp's 4th Pack fights
	in powered armor (the Rhino Team). The Workshops and clinics named here are this game's own.
]]

return {
	order = { "aug_spring", "aug_blade", "aug_chain", "aug_needle", "aug_piston", "aug_furnace", "aug_carapace", "aug_rhino", "aug_grown" },

	aug_spring = {
		name = "Spring-Coil Arm", slot = "arm", price = 1500, minAge = 18, rarity = "uncommon",
		desc = "A cheap Workshop prosthetic: a steel forearm with springs wound tight inside. Fast, loud, and it squeaks in the rain.",
		effect = "Coil Snap: a way of fighting with Speed (strike first, Reach). +1 per-heads power in Speed clashes. Speed can go 15 past its limit.",
		clash = { speed = { coinPower = 1 } }, capBonus = { speed = 15 },
		look = { kind = "arm_spring", color = { 150, 150, 140 }, trim = { 200, 180, 90 } },
		buyLog = "A week in a Workshop bed, and an arm that's yours but isn't. It squeaks when you flex it. The fitter says that's normal.",
	},
	aug_blade = {
		name = "Hidden-Blade Forearm", slot = "arm", price = 2200, minAge = 18, rarity = "rare",
		desc = "A slim black forearm that opens along its length. The blade inside is folded, sharpened, and very patient.",
		effect = "Concealed Edge: a way of fighting with Speed (strike first, Bleed 2). +1 base in Speed clashes. Speed can go 20 past its limit.",
		clash = { speed = { base = 1 } }, capBonus = { speed = 20 },
		look = { kind = "arm_blade", color = { 40, 40, 46 }, trim = { 200, 205, 215 } },
		buyLog = "The fitter showed you how to open it, and then how not to open it by accident. The second lesson took longer.",
	},
	aug_chain = {
		name = "Reel-Chain Arm", slot = "arm", price = 1900, minAge = 18, rarity = "uncommon",
		desc = "A Workshop arm with a chain wound round a drum in the forearm, and a hook on the end. Good for rooftops. Better for people on rooftops.",
		effect = "Reel In: a way of fighting with Speed (Reach, Volley 2). +1 base in Speed clashes. Speed can go 15 past its limit.",
		clash = { speed = { base = 1 } }, capBonus = { speed = 15 },
		look = { kind = "arm_chain", color = { 90, 86, 80 }, trim = { 170, 160, 150 } },
	},
	aug_needle = {
		name = "Surgeon's Needle Arm", slot = "arm", price = 1800, minAge = 20, rarity = "rare",
		desc = "A clinic's arm, all fine joints and one long needle, built for a hand that never shakes. Some surgeons fight with them. Some fighters became surgeons.",
		effect = "Nerve Needle: a way of fighting with Intelligence (Pierce 2, Sinking 2). +2 base in Intelligence clashes. Intelligence can go 20 past its limit.",
		clash = { intelligence = { base = 2 } }, capBonus = { intelligence = 20 },
		look = { kind = "arm_needle", color = { 210, 215, 220 }, trim = { 120, 200, 220 } },
	},
	aug_piston = {
		name = "Workshop Piston Arm", slot = "arm", price = 2400, minAge = 18, rarity = "rare",
		desc = "Steel from shoulder to knuckle, with a piston in the forearm that fires behind every punch. You can hear it from across the street.",
		effect = "Piston Drive: a way of fighting with Strength (+2 power, Crush, Tremor 2). +2 base in Strength clashes. Strength can go 25 past its limit.",
		clash = { strength = { base = 2 } }, capBonus = { strength = 25 },
		look = { kind = "arm_piston", color = { 150, 152, 160 }, trim = { 204, 162, 72 } },
		buyLog = "The fitter fired the piston once on the bench to show you. It put a dent in the bench. You paid.",
	},
	aug_furnace = {
		name = "Furnace Knuckle Arm", slot = "arm", price = 2800, minAge = 18, rarity = "epic",
		desc = "Dark iron, with vents along the forearm that glow orange before the punch lands. You'll never be cold again. You'll never hold anything plastic again either.",
		effect = "Furnace Knuckle: a way of fighting with Strength (+2 power, Burn 3). +1 base and +1 per-heads power in Strength clashes. Strength can go 25 past its limit.",
		clash = { strength = { base = 1, coinPower = 1 } }, capBonus = { strength = 25 },
		look = { kind = "arm_furnace", color = { 50, 44, 42 }, trim = { 255, 130, 40 }, glow = true },
	},
	aug_carapace = {
		name = "Smoke War Carapace Arm", slot = "arm", price = 3200, minAge = 20, rarity = "epic",
		desc = "A G Corp graft from the Smoke War: chitin plates, a claw that opens, and a nerve that never quite stops twitching. A Backstreets clinic does them quietly, for people who won't ask where the arm came from.",
		effect = "Carapace Claw: a way of fighting with Strength (Guard 2, Rupture 2). +2 base in Strength clashes, +15 maximum Health. Strength can go 30 past its limit. -2 Charisma: people stare.",
		requires = { side = "backstreets" },
		clash = { strength = { base = 2 }, charisma = { base = -2 } }, capBonus = { strength = 30 }, maxHealth = 15,
		look = { kind = "arm_carapace", color = { 70, 82, 50 }, trim = { 150, 160, 90 } },
		buyLog = "The clinic was a back room behind a noodle shop. The surgeon was very good, and very quiet. The arm twitched once when you woke up, and then it was yours.",
	},
	aug_rhino = {
		name = "R Corp Surplus Gauntlet", slot = "arm", price = 4200, minAge = 20, rarity = "epic",
		desc = "A powered gauntlet off a Rhino Team suit, cut down and fitted as a whole arm by a Workshop that won't say how it got one. It hums when it charges.",
		effect = "Ram Gauntlet: a way of fighting with Strength (Charge 3, Crush). +1 coin in Strength fights. Strength can go 35 past its limit.",
		fight = { coins = 1 }, capBonus = { strength = 35 },
		look = { kind = "arm_rhino", color = { 180, 110, 60 }, trim = { 60, 60, 66 }, glow = true },
	},
	aug_grown = {
		name = "K Corp Grown Arm", slot = "arm", price = 5200, minAge = 20, rarity = "legendary",
		desc = "Not a machine: an arm grown in a K Corp vat and grafted on at a Nest clinic. Paler than you, stronger than you, and it closes its own cuts.",
		effect = "Regrowing Strike: a way of fighting with Strength (drink 4, Guard). +25 maximum Health, +2 Health every year. Strength and Health hold better: Strength can go 20 past its limit.",
		requires = { side = "nest" },
		capBonus = { strength = 20 }, maxHealth = 25, yearly = { health = 2 },
		look = { kind = "arm_grown", color = { 226, 214, 204 }, trim = { 120, 230, 150 }, glow = true },
		buyLog = "Three days in a white room, and an arm that healed the needle mark before they'd taken the needle out.",
	},
}
