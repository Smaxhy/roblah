--[[
	TECHNIQUES (v0.17): ways of fighting a teacher gives you (City/Trainers.luau) or an augment
	arm carries (Gear/Augments.luau). Each is an approach (pack.approaches): pick it when a fight
	starts, like Overpower or Outpace. A teacher's technique needs its flag (set when they
	teach it); an arm's needs the arm on.

	Who teaches what follows the schools (City/Schools.luau): an Association's technique is
	taught by its own instructors to its own members, in its own status (Liu burns, Seven
	ruptures, Shi and Cinq fight on Poise, Zwei and Öufi shake, Dieci sinks...). Teachers with
	no organisation behind them (a retired Fixer, a street hustler, a hermit past the Outskirts'
	edge) teach things that belong to nobody: footwork, a counter, nerve.

	Matchups follow the stat: Strength beats the Cunning and loses to the Quick, Speed beats
	Brutes and loses to the Cunning, Intelligence beats the Quick and loses to Brutes.
]]

local STR = { beats = "cunning", loses = "quick" }
local SPD = { beats = "brute", loses = "cunning" }
local INT = { beats = "quick", loses = "brute" }

local function tq(def, match)
	def.fightOnly = true
	if match then
		def.beats = match.beats
		def.loses = match.loses
	end
	return def
end

local T = {
	order = {
		-- from teachers with no organisation behind them
		"tq_counter", "tq_hook", "tq_step_inside", "tq_flurry", "tq_read_opening", "tq_gamblers_draw",
		"tq_still_mind", "tq_command", "tq_last_stand",
		-- from the schools' own instructors
		"tq_zwei_bulwark", "tq_liu_flame_palm", "tq_seven_marked", "tq_devyat_express", "tq_shi_one_breath",
		"tq_cinq_declared", "tq_dieci_weight", "tq_oufi_clause", "tq_thumb_volley", "tq_index_unbound",
		"tq_middle_line", "tq_ring_brush", "tq_kurokumo_draw", "tq_lineage_cut", "tq_hardblood_crown",
		"tq_wcorp_overcharge", "tq_kcorp_excision",
		-- carried by augment arms
		"arm_piston", "arm_blade", "arm_chain", "arm_furnace", "arm_carapace", "arm_rhino", "arm_grown", "arm_spring", "arm_needle",
	},

	-- ── nobody's: a retired Fixer, a street, a hermit ───────────────────────────
	tq_counter = tq({
		name = "Counter Stance", short = "Riposte · Guard",
		desc = "Fight with Strength from a low stance: the first clash you lose costs no coin, and every hit you take makes their next one weaker. A loss costs a third less.",
		stat = "strength", requires = { flags = { "tq_counter" } },
		abilities = { { id = "guard", potency = 1 }, { id = "riposte", potency = 1 } }, loss = 0.67,
		color = { 196, 160, 110 },
	}, STR),
	tq_hook = tq({
		name = "Breaking Hook", short = "Crush · wins +15%",
		desc = "Fight with Strength, all of it behind one hook: the first clash you win knocks a second coin out of them. Wins pay more.",
		stat = "strength", requires = { flags = { "tq_hook" } },
		clash = { base = 1 }, abilities = { { id = "crush", potency = 1 } }, gain = 1.15,
		color = { 220, 130, 80 },
	}, STR),
	tq_step_inside = tq({
		name = "Step Inside", short = "Quick · Reach",
		desc = "Fight with Speed and close the distance before they've set their feet: you strike first, and their first clash can't take a coin from you.",
		stat = "speed", requires = { flags = { "tq_step_inside" } },
		abilities = { { id = "quick", potency = 1 }, { id = "reach", potency = 1 } },
		color = { 110, 210, 200 },
	}, SPD),
	tq_flurry = tq({
		name = "Flurry", short = "Volley · +1 a heads",
		desc = "Fight with Speed, all hands: every heads hits harder, and your first clash hits much harder. Light blows, though: -1 power.",
		stat = "speed", requires = { flags = { "tq_flurry" } },
		clash = { base = -1, coinPower = 1 }, abilities = { { id = "volley", potency = 2 } },
		color = { 120, 220, 240 },
	}, SPD),
	tq_read_opening = tq({
		name = "Read the Opening", short = "Pierce 2 · coins -5%",
		desc = "Fight with Intelligence: you've watched three of their swings, and you know where the fourth leaves them open. Armor doesn't help them, and their coins land worse.",
		stat = "intelligence", requires = { flags = { "tq_read_opening" } },
		abilities = { { id = "pierce", potency = 2 } }, foeHeads = -5,
		color = { 130, 180, 240 },
	}, INT),
	tq_gamblers_draw = tq({
		name = "Long-Shot Draw", short = "Fight with Luck",
		desc = "Fight with Luck, of all things: you throw the first blow before you've decided to, and it lands where it lands. +2 power, and your first clash hits much harder.",
		stat = "luck", requires = { flags = { "tq_gamblers_draw" } },
		clash = { base = 2 }, abilities = { { id = "volley", potency = 1 } },
		color = { 150, 220, 110 },
	}),
	tq_still_mind = tq({
		name = "Still Mind", short = "Fight with Mental Strength",
		desc = "Fight with Mental Strength, no E.G.O, no voice: you stop being afraid and watch. The first clash you lose costs no coin, every hit you take makes their next one weaker, and a loss costs a fifth less.",
		stat = "mind", requires = { flags = { "tq_still_mind" } },
		abilities = { { id = "guard", potency = 1 }, { id = "riposte", potency = 1 } }, loss = 0.8,
		color = { 170, 130, 230 },
	}),
	tq_command = tq({
		name = "Command", short = "Charisma · their coins -10%",
		desc = "Fight with Charisma in a real fight, not to talk it down: a voice that tells them where to stand. Their coins land worse, and they hesitate before the first clash.",
		stat = "charisma", requires = { flags = { "tq_command" } },
		foeHeads = -10, abilities = { { id = "guard", potency = 1 } },
		color = { 230, 140, 190 },
	}),
	tq_last_stand = tq({
		name = "Last Stand", short = "Fight with Health · -8 HP",
		desc = "Fight with your Health: the body you've built is the weapon. +2 power and Crush. It costs 8 Health to fight like this, every time.",
		stat = "health", requires = { flags = { "tq_last_stand" } },
		clash = { base = 2 }, abilities = { { id = "crush", potency = 1 } }, healthCost = 8,
		costLog = "You fought with your whole body. Your whole body noticed.",
		color = { 214, 110, 100 },
	}),

	-- ── the schools' own (taught by their instructors to their members) ───────────
	tq_zwei_bulwark = tq({
		name = "Zwei Bulwark", short = "Guard 2 · Tremor 2",
		desc = "Zwei's oath in a stance: plant your feet in front of the client and let them break on you. Your first two lost clashes cost no coin, every heads shakes them, and a loss costs 40% less.",
		stat = "strength", requires = { flags = { "tq_zwei_bulwark" } },
		abilities = { { id = "guard", potency = 2 }, { id = "tremor", potency = 2 } }, loss = 0.6,
		color = { 214, 180, 92 },
	}, STR),
	tq_liu_flame_palm = tq({
		name = "Liu Flame Palm", short = "Burn 3 · Crush",
		desc = "A Liu combat art for close quarters: the gauntlet's fire goes into the palm strike. Every heads sets them burning, and the first clash you win knocks off a second coin.",
		stat = "strength", requires = { flags = { "tq_liu_flame_palm" } },
		clash = { base = 1 }, abilities = { { id = "burn", potency = 3 }, { id = "crush", potency = 1 } },
		color = { 236, 110, 40 },
	}, STR),
	tq_seven_marked = tq({
		name = "Seven Marked Thrust", short = "Rupture 3 · Pierce",
		desc = "Seven's investigators fence with a notebook in their head: find the weak point, mark it, go back to it. Every heads cracks them open wider, and armor doesn't help.",
		stat = "intelligence", requires = { flags = { "tq_seven_marked" } },
		abilities = { { id = "rupture", potency = 3 }, { id = "pierce", potency = 1 } },
		color = { 96, 200, 170 },
	}, INT),
	tq_devyat_express = tq({
		name = "Devyat' Express Delivery", short = "Rupture 2 · Quick · Reach",
		desc = "The parcel arrives on time, through whatever's in the way. You strike first, their first clash can't take a coin from you, and every heads opens them up.",
		stat = "speed", requires = { flags = { "tq_devyat_express" } },
		abilities = { { id = "rupture", potency = 2 }, { id = "quick", potency = 1 }, { id = "reach", potency = 1 } },
		color = { 110, 190, 160 },
	}, SPD),
	tq_shi_one_breath = tq({
		name = "Shi One Breath", short = "Poise 3 · Quick · all or nothing",
		desc = "Shi's quiet work: one breath, one cut, at the moment it can't miss. You strike first and every heads builds Poise. Wins pay 25% more; a loss hits 25% harder.",
		stat = "speed", requires = { flags = { "tq_shi_one_breath" } },
		abilities = { { id = "poise", potency = 3 }, { id = "quick", potency = 1 } }, gain = 1.25, loss = 1.25,
		color = { 210, 220, 240 },
	}, SPD),
	tq_cinq_declared = tq({
		name = "Cinq Declared Duel", short = "Poise 2 · Riposte",
		desc = "A Cinq duel by the book: the declaration, the stance, the exchange. Every heads builds Poise, and every hit you take makes their next one weaker.",
		stat = "speed", requires = { flags = { "tq_cinq_declared" } },
		clash = { base = 1 }, abilities = { { id = "poise", potency = 2 }, { id = "riposte", potency = 1 } },
		color = { 240, 220, 200 },
	}, SPD),
	tq_dieci_weight = tq({
		name = "Dieci Weighted Key", short = "Sinking 3 · Guard",
		desc = "Dieci spends what it knows. The key turns, and what you spend lands on their mind: their coins land heads less, and the first clash you lose costs no coin.",
		stat = "intelligence", requires = { flags = { "tq_dieci_weight" } },
		abilities = { { id = "sinking", potency = 3 }, { id = "guard", potency = 1 } },
		color = { 80, 110, 200 },
	}, INT),
	tq_oufi_clause = tq({
		name = "Öufi Clause, Read Aloud", short = "Mental Strength · Tremor 2 · Crush",
		desc = "Fight with Mental Strength. The clause is read out, the breach is named, and what follows is in the contract. Every heads shakes them; the first win knocks off a second coin.",
		stat = "mind", requires = { flags = { "tq_oufi_clause" } },
		abilities = { { id = "tremor", potency = 2 }, { id = "crush", potency = 1 } },
		color = { 190, 170, 120 },
	}),
	tq_thumb_volley = tq({
		name = "Thumb Propellant Volley", short = "Burn 2 · Volley 2",
		desc = "Manners first, then ammunition: a full cylinder of propellant rounds, fired exactly as ordered. Your first clash hits much harder and every heads burns.",
		stat = "strength", requires = { flags = { "tq_thumb_volley" } },
		abilities = { { id = "burn", potency = 2 }, { id = "volley", potency = 2 } },
		color = { 200, 70, 50 },
	}, STR),
	tq_index_unbound = tq({
		name = "Index Prescript, Unbound", short = "Charge 3 · Crush",
		desc = "Strength kept under lock until the Prescript calls for it. Charge builds every clash and goes out in one blow; the first win knocks off a second coin.",
		stat = "strength", requires = { flags = { "tq_index_unbound" } },
		abilities = { { id = "charge", potency = 3 }, { id = "crush", potency = 1 } },
		color = { 230, 230, 250 },
	}, STR),
	tq_middle_line = tq({
		name = "Middle: A Line in the Book", short = "Tremor 2 · Riposte",
		desc = "Every slight is written down, and every one goes into the swing. Every heads shakes them; every hit they land on you, they pay for on the next.",
		stat = "strength", requires = { flags = { "tq_middle_line" } },
		abilities = { { id = "tremor", potency = 2 }, { id = "riposte", potency = 1 } },
		color = { 170, 150, 140 },
	}, STR),
	tq_ring_brush = tq({
		name = "Ring Brushwork", short = "Charisma · Bleed 2 · Pierce",
		desc = "Fight with Charisma: a Student of the Ring makes the fight a canvas, and the other person brought the paint. Every heads makes them Bleed; armor doesn't help them.",
		stat = "charisma", requires = { flags = { "tq_ring_brush" } },
		abilities = { { id = "bleed", potency = 2 }, { id = "pierce", potency = 1 } },
		color = { 200, 60, 120 },
	}),
	tq_kurokumo_draw = tq({
		name = "Dark Cloud Draw", short = "Bleed 2 · Quick",
		desc = "The Kurokumo blade, drawn fast and sheathed slow. You strike first, and every heads makes them Bleed.",
		stat = "speed", requires = { flags = { "tq_kurokumo_draw" } },
		clash = { base = 1 }, abilities = { { id = "bleed", potency = 2 }, { id = "quick", potency = 1 } },
		color = { 90, 80, 110 },
	}, SPD),
	tq_lineage_cut = tq({
		name = "Blade Lineage: The One Cut", short = "Poise 2 · Pierce 2",
		desc = "One cut, practised until it's the only one you need. Every heads builds Poise, and nothing they wear turns it.",
		stat = "speed", requires = { flags = { "tq_lineage_cut" } },
		abilities = { { id = "poise", potency = 2 }, { id = "pierce", potency = 2 } },
		color = { 236, 236, 236 },
	}, SPD),
	tq_hardblood_crown = tq({
		name = "Hardblood Thorn Crown", short = "-10 HP · Bleed 3 · drink 5",
		desc = "An Elder's art: the blood hardens into thorns all round you at once. +2 power, every heads makes them Bleed, and every clash you win you drink 5 back. Costs 10 Health.",
		stat = "strength", requires = { flags = { "tq_hardblood_crown" }, form = "bloodfiend" },
		clash = { base = 2 }, healthCost = 10,
		abilities = { { id = "bleed", potency = 3 }, { id = "drink", potency = 5 } },
		costLog = "The thorns went back into you, most of them.",
		color = { 170, 20, 40 },
	}, STR),
	tq_wcorp_overcharge = tq({
		name = "W Corp Overcharge", short = "Charge 3 · Quick",
		desc = "Cleanup drill: run the stored power past its safe line and spend it all at once. You strike first; Charge builds every clash.",
		stat = "speed", requires = { flags = { "tq_wcorp_overcharge" } },
		abilities = { { id = "charge", potency = 3 }, { id = "quick", potency = 1 } },
		color = { 90, 170, 255 },
	}, SPD),
	tq_kcorp_excision = tq({
		name = "K Corp Excision", short = "Rupture 2 · drink 3",
		desc = "Excision Staff open up what the ampules are meant for, and the ampule in your own arm closes you back up: every clash you win, you heal 3 after the fight.",
		stat = "strength", requires = { flags = { "tq_kcorp_excision" } },
		abilities = { { id = "rupture", potency = 2 }, { id = "drink", potency = 3 } },
		color = { 120, 230, 140 },
	}, STR),

	-- ── augment arms (Gear/Augments.luau): the arm is the technique ───────────────
	arm_piston = tq({
		name = "Piston Drive", short = "Arm · Crush · Tremor 2",
		desc = "The piston in your forearm fires behind the punch. +2 power, the first win knocks off a second coin, and every heads shakes them.",
		stat = "strength", requires = { hasGear = "aug_piston" },
		clash = { base = 2 }, abilities = { { id = "crush", potency = 1 }, { id = "tremor", potency = 2 } },
		color = { 190, 190, 200 },
	}, STR),
	arm_blade = tq({
		name = "Concealed Edge", short = "Arm · Quick · Bleed 2",
		desc = "The forearm opens and the blade is already moving. You strike first, and every heads makes them Bleed.",
		stat = "speed", requires = { hasGear = "aug_blade" },
		clash = { base = 1 }, abilities = { { id = "quick", potency = 1 }, { id = "bleed", potency = 2 } },
		color = { 160, 170, 190 },
	}, SPD),
	arm_chain = tq({
		name = "Reel In", short = "Arm · Reach · Volley",
		desc = "The hook goes out on its chain and comes back with them on it. Their first clash can't take a coin from you, and your first hits much harder.",
		stat = "speed", requires = { hasGear = "aug_chain" },
		abilities = { { id = "reach", potency = 1 }, { id = "volley", potency = 2 } },
		color = { 150, 140, 130 },
	}, SPD),
	arm_furnace = tq({
		name = "Furnace Knuckle", short = "Arm · Burn 3 · +2 power",
		desc = "The vents in the arm glow before the punch lands. +2 power, and every heads sets them burning.",
		stat = "strength", requires = { hasGear = "aug_furnace" },
		clash = { base = 2 }, abilities = { { id = "burn", potency = 3 } },
		color = { 255, 130, 50 },
	}, STR),
	arm_carapace = tq({
		name = "Carapace Claw", short = "Arm · Guard 2 · Rupture 2",
		desc = "A Smoke War graft: chitin plates over the forearm, and a claw that opens. Your first two lost clashes cost no coin, and every heads cracks them open.",
		stat = "strength", requires = { hasGear = "aug_carapace" },
		clash = { base = 1 }, abilities = { { id = "guard", potency = 2 }, { id = "rupture", potency = 2 } },
		color = { 110, 120, 70 },
	}, STR),
	arm_rhino = tq({
		name = "Ram Gauntlet", short = "Arm · Charge 3 · Crush",
		desc = "Surplus powered armor, cut down to an arm and fitted. Charge builds every clash and goes out at once; the first win knocks off a second coin. +1 power.",
		stat = "strength", requires = { hasGear = "aug_rhino" },
		clash = { base = 1 }, abilities = { { id = "charge", potency = 3 }, { id = "crush", potency = 1 } },
		color = { 200, 120, 60 },
	}, STR),
	arm_grown = tq({
		name = "Regrowing Strike", short = "Arm · drink 4 · Guard",
		desc = "A K Corp arm, grown in a vat and grafted on: it heals as it hits. Every clash you win, you heal 4 after the fight, and the first clash you lose costs no coin.",
		stat = "strength", requires = { hasGear = "aug_grown" },
		abilities = { { id = "drink", potency = 4 }, { id = "guard", potency = 1 } },
		color = { 120, 220, 150 },
	}, STR),
	arm_spring = tq({
		name = "Coil Snap", short = "Arm · Quick · Reach",
		desc = "Springs wound tight in the forearm let go all at once. You strike first, and their first clash can't take a coin from you.",
		stat = "speed", requires = { hasGear = "aug_spring" },
		clash = { coinPower = 1 }, abilities = { { id = "quick", potency = 1 }, { id = "reach", potency = 1 } },
		color = { 200, 200, 150 },
	}, SPD),
	arm_needle = tq({
		name = "Nerve Needle", short = "Arm · Intelligence · Pierce 2 · Sinking",
		desc = "Fight with Intelligence: a surgeon's arm with a needle for the place where a nerve crosses a bone. Armor doesn't help them, and their coins land heads less.",
		stat = "intelligence", requires = { hasGear = "aug_needle" },
		abilities = { { id = "pierce", potency = 2 }, { id = "sinking", potency = 2 } },
		color = { 140, 200, 220 },
	}, INT),
}

return T
