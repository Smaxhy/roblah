--[[
	FOUND (v0.13): what delves, episodes, turf wars and cases leave in your hands. Never sold
	(unique); most can be sold back to a Workshop from your stash for what they're worth,
	except the ones marked keep. Fields: see Gear/Core.luau, plus capBonus (how far past 100
	a stat may go while you carry it) and set (Gear/Arsenal.luau: the sets).
]]

return {
	order = {
		-- from delves
		"dv_branch_ego_suit", "dv_branch_badge", "dv_visitor_badge", "dv_thirteen_key", "dv_feather_pin",
		"dv_lake_harpoon", "dv_steward_seal", "dv_empty_frame", "dv_black_umbrella",
		-- from episodes
		"ep_voss_badge", "ep_enkephalin_cell", "ep_breach_hook", "ep_brandt_badge", "ep_lind_book", "ep_war_medal",
		"ep_kindred_pin", "ep_masterwork_proto", "ep_masterwork_blade", "ep_outskirts_sprig", "ep_lamp_glass",
		"ep_thirteenth_umbrella",
		-- from the long game
		"tf_district_ledger", "cs_hana_commendation", "cs_index_card", "cs_auction_gavel",
	},

	-- ── from delves ──
	dv_branch_ego_suit = {
		name = "A Branch Agent's Suit", slot = "coat", rarity = "epic", unique = true,
		desc = "From a locker in a buried branch of the old L Corp: an agent's suit, cut from something the branch once kept downstairs. It's cold, and it fits like it was waiting.",
		effect = "You take 15% less Health damage. +2 base in Mental Strength clashes. Resists Sinking 2. Debuff: -1 Sanity a year.",
		toughness = 0.85, clash = { mind = { base = 2 } }, resist = { sinking = 2 }, yearly = { sanity = -1 },
		look = { kind = "greatcoat", color = { 40, 62, 54 } },
	},
	dv_branch_badge = {
		name = "A Branch Employee's Badge", slot = "charm", rarity = "rare", unique = true,
		desc = "A laminated badge from a buried branch, photo faded to a pale smudge. Some old doors in the City still open for it.",
		effect = "+1 base in Intelligence and Mental Strength clashes.",
		clash = { intelligence = { base = 1 }, mind = { base = 1 } },
		look = { kind = "token", color = { 120, 210, 150 } },
	},
	dv_visitor_badge = {
		name = "A Recruitment Day Visitor Badge", slot = "charm", rarity = "uncommon", unique = true,
		desc = "From the Wing of District 12's open day. You were supposed to hand it back at the gate. You didn't.",
		effect = "+2 base in Charisma clashes. Bad luck 10% less likely.",
		clash = { charisma = { base = 2 } }, hazardGuard = 0.9,
		look = { kind = "token", color = { 230, 230, 236 } },
	},
	dv_thirteen_key = {
		name = "The Thirteenth Key", slot = "charm", rarity = "rare", unique = true,
		desc = "It was in the lift panel where the button for a floor that doesn't exist used to be. It doesn't fit any lock you've tried.",
		effect = "+3% heads. +2 base in Mental Strength clashes. Debuff: -1 Sanity a year.",
		heads = 3, clash = { mind = { base = 2 } }, yearly = { sanity = -1 },
		look = { kind = "token", color = { 170, 150, 110 } },
	},
	dv_feather_pin = {
		name = "A Feather's Pin", slot = "charm", rarity = "rare", unique = true,
		desc = "A Wing employee's lapel pin, pressed into your hand at a Nest gate. Guards look at it, then at you, differently.",
		effect = "+2 base in Charisma clashes. Bad luck 15% less likely.",
		clash = { charisma = { base = 2 } }, hazardGuard = 0.85,
		look = { kind = "token", color = { 240, 214, 140 } },
	},
	dv_lake_harpoon = {
		name = "Portship Harpoon", slot = "tool", rarity = "epic", unique = true,
		desc = "Oiled and perfect, from a crate the Great Lake gave back. Made for things much bigger than people.",
		effect = "+1 coin and +2 base in Strength clashes.",
		clash = { strength = { coins = 1, base = 2 } }, ability = { id = "pierce", potency = 1 },
		look = { kind = "harpoon", color = { 150, 170, 180 } },
	},
	dv_steward_seal = {
		name = "A Steward's Seal", slot = "charm", rarity = "rare", unique = true,
		desc = "A Nest steward's brass seal. It stamps a mark the District office never questions.",
		effect = "+2 base in Intelligence clashes. +1 Sanity a year.",
		clash = { intelligence = { base = 2 } }, yearly = { sanity = 1 },
		look = { kind = "bell", color = { 200, 170, 90 } },
	},
	dv_empty_frame = {
		name = "The Empty Frame", slot = "charm", rarity = "epic", unique = true,
		desc = "A gilt frame from a gallery the Ring used, small enough for a pocket. You took it so nobody could put anything in it.",
		effect = "+2 base in Mental Strength clashes. Resists Sinking 3. Debuff: -1 Sanity a year.",
		clash = { mind = { base = 2 } }, resist = { sinking = 3 }, yearly = { sanity = -1 },
		look = { kind = "token", color = { 214, 180, 90 } },
	},
	dv_black_umbrella = {
		name = "A Correct Umbrella", slot = "tool", rarity = "epic", unique = true,
		desc = "Very fine and very black, sent by the Index with a card that said 'Correct.' The ribs are steel. The handle is heavier than it needs to be.",
		effect = "+2 base in Strength clashes, +1 coin in Mental Strength clashes. You take 10% less Health damage.",
		clash = { strength = { base = 2 }, mind = { coins = 1 } }, toughness = 0.9,
		look = { kind = "umbrella", color = { 24, 24, 30 } },
	},

	-- ── from episodes ──
	ep_voss_badge = {
		name = "Agent Voss's Badge", slot = "charm", rarity = "rare", unique = true, keep = true,
		desc = "A Welfare Team badge with a photograph of a tired, kind face. The facility clocked her out because you asked it to.",
		effect = "+2 base in Mental Strength clashes. +1 Sanity a year.",
		clash = { mind = { base = 2 } }, yearly = { sanity = 1 },
		look = { kind = "token", color = { 150, 220, 170 } },
	},
	ep_enkephalin_cell = {
		name = "A Cell of Enkephalin", slot = "charm", rarity = "epic", unique = true,
		desc = "A glass cell of slow green light, warm in the hand. It hums the same note as the thing that made it.",
		effect = "+1 coin in Mental Strength clashes, +2 base in Intelligence clashes. Mental Strength can go 5 past its limit. Debuff: -2 Sanity a year.",
		clash = { mind = { coins = 1 }, intelligence = { base = 2 } }, capBonus = { mind = 5 }, yearly = { sanity = -2 },
		look = { kind = "stone", color = { 110, 230, 150 } },
	},
	ep_breach_hook = {
		name = "Suppression Hook", slot = "tool", rarity = "epic", unique = true,
		desc = "Pulled off the wall of a sunken corridor during a breach. Built for holding things that should be in their units.",
		effect = "+3 base in Strength clashes.",
		clash = { strength = { base = 3 } }, ability = { id = "rupture", potency = 2 },
		look = { kind = "glaive", color = { 180, 60, 50 } },
	},
	ep_brandt_badge = {
		name = "Ilse's Badge", slot = "charm", rarity = "rare", unique = true, keep = true,
		desc = "An agent's badge from the Wing of District 12, returned in a cardboard box with a photograph of the two of you on the stairs.",
		effect = "+1 base in Mental Strength and Health clashes. Bad luck 10% less likely.",
		clash = { mind = { base = 1 }, health = { base = 1 } }, hazardGuard = 0.9,
		look = { kind = "token", color = { 200, 200, 190 } },
	},
	ep_lind_book = {
		name = "Oskar Lind's Book", slot = "tool", rarity = "epic", unique = true, keep = true,
		desc = "Grey cloth, no title, always a little warm. A Grade 5 Fixer's whole life is in it, and his sword arm is in you.",
		effect = "+2 base in Strength and Intelligence clashes. Strength can go 5 past its limit.",
		clash = { strength = { base = 2 }, intelligence = { base = 2 } }, capBonus = { strength = 5 },
		look = { kind = "book", color = { 140, 140, 136 } },
	},
	ep_war_medal = {
		name = "A Fallen Wing's Medal", slot = "charm", rarity = "epic", unique = true,
		desc = "Black iron, with a wing worn smooth by an old soldier's thumb. The Wing it belonged to is gone. The medal isn't.",
		effect = "+1 coin in Health clashes, +1 base in Strength clashes. +1 Sanity a year.",
		clash = { health = { coins = 1 }, strength = { base = 1 } }, yearly = { sanity = 1 },
		look = { kind = "token", color = { 60, 60, 66 } },
	},
	ep_kindred_pin = {
		name = "The Morvaine Rose", slot = "charm", rarity = "rare", unique = true,
		desc = "A small red enamel rose, pinned to your collar by a Bloodfiend Elder. Kindred know what it means.",
		effect = "+2 base in Charisma clashes. Resists Bleed 2.",
		clash = { charisma = { base = 2 } }, resist = { bleed = 2 },
		look = { kind = "token", color = { 180, 30, 50 } },
	},
	ep_masterwork_proto = {
		name = "Halvard Prototype", slot = "tool", rarity = "epic", unique = true, keep = true,
		desc = "The Halvard Workshop's new blade, lent for a year. It pulls toward the strongest thing in any room.",
		effect = "+2 base and +1 per-heads power in Strength clashes, +4 Speed in fights. Debuff: -1 Sanity a year.",
		clash = { strength = { base = 2, coinPower = 1 } }, speed = 4, yearly = { sanity = -1 },
		look = { kind = "sword", color = { 200, 206, 214 } },
	},
	ep_masterwork_blade = {
		name = "Halvard Line, No. 1", slot = "tool", rarity = "legendary", unique = true, keep = true, set = "halvard",
		desc = "The first of a line of blades the Halvard Workshop will make for twenty years. Your name is cut into the steel just above the guard.",
		effect = "+1 coin, +2 base and +1 per-heads power in Strength clashes, +5 Speed in fights. Strength can go 10 past its limit.",
		clash = { strength = { coins = 1, base = 2, coinPower = 1 } }, speed = 5, capBonus = { strength = 10 }, ability = { id = "riposte", potency = 2 },
		look = { kind = "sword", color = { 236, 214, 150 } },
	},
	ep_outskirts_sprig = {
		name = "A Sprig from Past the Wall", slot = "charm", rarity = "rare", unique = true,
		desc = "A plant in a tin that grows in no light at all. The room it's in smells of somewhere far away.",
		effect = "+1 Health a year. Bad luck 15% less likely.",
		yearly = { health = 1 }, hazardGuard = 0.85,
		look = { kind = "stone", color = { 130, 190, 110 } },
	},
	ep_lamp_glass = {
		name = "Lamp Glass", slot = "charm", rarity = "rare", unique = true,
		desc = "A curved piece of a streetlight that once followed you home. It's warm at night. On the worst nights it glows.",
		effect = "+4% heads. Bad luck 10% less likely.",
		heads = 4, hazardGuard = 0.9,
		look = { kind = "stone", color = { 250, 236, 170 } },
	},
	ep_thirteenth_umbrella = {
		name = "The Thirteenth Umbrella", slot = "tool", rarity = "epic", unique = true,
		desc = "Black, steel-ribbed, waxed by hand, from a shop that was on your street before your street was there. For when you need it.",
		effect = "+2 base in Strength and Health clashes. You take 12% less Health damage.",
		clash = { strength = { base = 2 }, health = { base = 2 } }, toughness = 0.88,
		look = { kind = "umbrella", color = { 30, 30, 40 } },
	},

	-- ── from the long game ──
	tf_district_ledger = {
		name = "The District Ledger", slot = "charm", rarity = "legendary", unique = true, keep = true,
		desc = "Every block of the District, every shop and every debt, in one leather book. Whoever holds it is owed.",
		effect = "+2 base in Charisma and Intelligence clashes. +150 Ahn a year. Charisma can go 5 past its limit.",
		clash = { charisma = { base = 2 }, intelligence = { base = 2 } }, yearly = { money = 150 }, capBonus = { charisma = 5 },
		look = { kind = "book", color = { 110, 70, 40 } },
	},
	cs_hana_commendation = {
		name = "Hana Commendation", slot = "charm", rarity = "epic", unique = true,
		desc = "A brass medal from the Hana Association, for a case properly closed. Clerks sit up straighter when they see it.",
		effect = "+2 base in Intelligence clashes, +1 coin in Charisma clashes.",
		clash = { intelligence = { base = 2 }, charisma = { coins = 1 } },
		look = { kind = "bell", color = { 214, 190, 120 } },
	},
	cs_index_card = {
		name = "A Blank Prescript", slot = "charm", rarity = "epic", unique = true,
		desc = "A forger's last card: Index stock, never written on. Nobody knows what it would make people do.",
		effect = "+1 coin in Intelligence clashes. +3% heads. Debuff: -1 Sanity a year.",
		clash = { intelligence = { coins = 1 } }, heads = 3, yearly = { sanity = -1 },
		look = { kind = "token", color = { 236, 240, 248 } },
	},
	cs_auction_gavel = {
		name = "The Quiet Gavel", slot = "tool", rarity = "legendary", unique = true,
		desc = "The auctioneer's gavel from the Quiet Auction. It has closed a great many sales of things that shouldn't exist.",
		effect = "+1 coin in Charisma clashes, +3 base in Strength clashes. Charisma can go 5 past its limit.",
		clash = { charisma = { coins = 1 }, strength = { base = 3 } }, capBonus = { charisma = 5 }, ability = { id = "crush", potency = 1 },
		look = { kind = "hammer", color = { 90, 60, 40 } },
	},
}
