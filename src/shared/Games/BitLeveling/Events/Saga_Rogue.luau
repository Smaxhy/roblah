--[[
	SAGA: THE ROGUE HUNTER (ORIGINAL GAME CONTENT). Unreported Gates, unsealed crystals and a
	crew that leaves people behind; then the Surveillance Team. Raid rights, the licence and
	the Surveillance Team that polices Hunter crime are canon; the crew ("Moth" and the man in
	the good coat), the mana-suppression facility and every person here are this game's own.

	Chain: sg_rogue_01 > 02 > 03 > 04 > 05 (the warrant). From the warrant: 06 (the verdict)
	> 09 (released); or 07 (the witness) > 09r (a second licence); or 08 (on the run, the town)
	> 08b (found) > 06.
	Fates: fate_rogue_prison, fate_rogue_redeemed, and the death "killed by the Surveillance
	Team" (flag sgr_rogue + a cause naming the Surveillance Team).
]]

local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }

local function beat(e)
	e.weight = 0
	e.once = true
	local w = e.when or {}
	w.minAge = w.minAge or 18
	w.notFlags = w.notFlags or {}
	table.insert(w.notFlags, "world_rewritten")
	table.insert(w.notFlags, "done_" .. e.id)
	e.when = w
	local function mark(r)
		if r then
			r.setFlags = r.setFlags or {}
			table.insert(r.setFlags, "done_" .. e.id)
		end
	end
	mark(e.result)
	for _, c in e.choices or {} do
		mark(c.result)
		mark(c.win)
		mark(c.lose)
	end
	return e
end

local ARREST = "Killed resisting arrest by the Surveillance Team"

return {
	{
		id = "sg_rogue_01",
		title = "An Offer in a Car Park",
		text = "A man in a good coat finds you in the car park after a public raid. He knows your rank, your rent and what your last raid paid. 'There are Gates the Association never hears about,' he says. 'Small ones, out of the way. My crews clear them and sell the crystals quietly. No auction, no tax, no waiting a month for your share.'",
		weight = 4,
		once = true,
		when = { minAge = 19, maxAge = 40, minYear = 3, form = { "hunter_e", "hunter_d", "hunter_c", "hunter_b" }, flags = { "licensed" }, max = { money = 150 }, notFlags = { "sg_career_arc", "world_rewritten" } },
		choices = {
			{ label = "Hear him out", hint = "Going into a Gate without the raid rights is a crime.", result = { setFlags = { "sg_career_arc", "sgr_on" }, schedule = { event = "sg_rogue_02", inYears = 1 }, codex = { "lore_rights" }, log = "You took his card. You told yourself you were only curious." } },
			{ label = "Report him to the Surveillance Team", result = { willpower = 2, codex = { "lore_kha" }, log = "You gave them his description. They seemed to know him already." } },
			{ label = "Walk away", result = { log = "You walked to your car without looking back. Your rent was still due." } },
		},
	},
	beat({
		id = "sg_rogue_02",
		title = "The Ravine",
		text = "The Gate is in a ravine two hours from the nearest road: unreported, unmeasured. The crew is four Hunters with their licence numbers taped over. The leader, a B-rank who calls himself Moth, hands you a pick and a knife. 'In and out by dark.'",
		tags = { "danger" },
		when = { flags = { "sgr_on" }, form = HUNTERS },
		choices = {
			{
				label = "Go in",
				hint = "An unmeasured Gate. Moth says C-rank.",
				clash = { stat = "strength", foe = "An unreported Gate", enemy = "gate_c", coins = 3, base = 13, coinPower = 5, fight = true, fixed = true },
				win = { strength = 2, money = { 20, 45 }, sanity = -3, setFlags = { "sgr_rogue" }, schedule = { event = "sg_rogue_03", inYears = 1 }, log = "Your share was more than three months of public raids. You counted it twice in the car." },
				lose = { vitality = { -44, -20 }, sanity = -4, setFlags = { "sgr_rogue" }, schedule = { event = "sg_rogue_03", inYears = 1 }, cause = "Killed in an illegal Gate raid", log = "It went badly. Moth's crew patched you up in the back of a van and paid you half." },
			},
			{ label = "Back out at the last moment", result = { sanity = 2, willpower = 2, clearFlags = { "sgr_on" }, log = "You handed back the pick and walked two hours to the road. You never heard from the man in the good coat again." } },
		},
	}),
	beat({
		id = "sg_rogue_03",
		title = "The Shipment",
		text = "Moth wants you to drive a van of unsealed crystals through an Association checkpoint on the coast road. 'They never open the back for a Hunter,' he says. If they do, it's your licence, and your name on the charge.",
		when = { flags = { "sgr_on" } },
		choices = {
			{
				label = "Drive it",
				clash = { stat = "luck", foe = "A checkpoint officer", coins = 2, base = 6, coinPower = 3 },
				win = { money = { 25, 60 }, setFlags = { "sgr_deep" }, schedule = { event = "sg_rogue_04", inYears = 1 }, log = "The officer waved you through and asked for a selfie." },
				lose = { sanity = -6, setFlags = { "sgr_caught" }, schedule = { event = "sg_rogue_05", inYears = 1 }, log = "They opened the back. You were out on bail by evening, and you knew exactly what was coming." },
			},
			{ label = "Refuse this one", result = { sanity = 1, setFlags = { "sgr_doubt" }, schedule = { event = "sg_rogue_04", inYears = 1 }, log = "Moth shrugged and gave the van to someone else. He started watching you differently." } },
			{
				label = "Skim a crate for yourself",
				clash = { stat = "agility", foe = "Moth's count", coins = 2, base = 8, coinPower = 4 },
				win = { money = { 40, 90 }, setFlags = { "sgr_deep" }, schedule = { event = "sg_rogue_04", inYears = 1 }, log = "One crate, off the back, in a lay-by. Nobody noticed. You think nobody noticed." },
				lose = { vitality = { -44, -20 }, setFlags = { "sgr_deep" }, schedule = { event = "sg_rogue_04", inYears = 1 }, cause = "Killed by the crew they stole from", log = "Moth counted the crates. He didn't say anything. He didn't have to." },
			},
		},
	}),
	beat({
		id = "sg_rogue_04",
		title = "The Porter",
		text = "A job goes wrong in the second chamber. The crew's porter, a nineteen-year-old E-rank, is hurt and can't walk. Moth looks at the porter, then at the exit, then at you. 'A porter who goes to a hospital talks to the Association,' he says. 'We leave them.'",
		tags = { "danger" },
		when = { flags = { "sgr_on" }, form = HUNTERS },
		choices = {
			{
				label = "Carry the porter out",
				hint = "Through a C-rank dungeon, without the crew.",
				clash = { stat = "strength", foe = "The way out", enemy = "gate_c", coins = 3, base = 13, coinPower = 5, fight = true, fixed = true },
				win = { willpower = 3, setFlags = { "sgr_conscience" }, schedule = { event = "sg_rogue_05", inYears = 1 }, log = "You carried them three kilometres to a road and called an ambulance from a farmhouse. Moth's crew had already driven off." },
				lose = { vitality = { -44, -20 }, setFlags = { "sgr_conscience" }, schedule = { event = "sg_rogue_05", inYears = 1 }, cause = "Killed carrying a porter out of an illegal Gate", log = "You got the porter out. It cost you, and it was worth it." },
			},
			{ label = "Leave them", result = { sanity = -12, setFlags = { "sgr_cold" }, schedule = { event = "sg_rogue_05", inYears = 1 }, log = "You walked out behind Moth and didn't look back. An Association team found the porter two days later, alive, and very willing to talk." } },
			{
				label = "Turn on Moth",
				hint = "He's a B-rank, and he's been waiting for this.",
				clash = { stat = "strength", foe = "Moth", enemy = "rogue_hunter", coins = 3, base = 20, coinPower = 6, fight = true, fixed = true },
				win = { strength = 3, setFlags = { "sgr_conscience", "sgr_turned" }, schedule = { event = "sg_rogue_05", inYears = 1 }, log = "You put Moth down, tied him up with his own rope and carried the porter out. Then you called the Surveillance Team yourself." },
				lose = { vitality = { -80, -36 }, setFlags = { "sgr_conscience" }, schedule = { event = "sg_rogue_05", inYears = 1 }, cause = "Killed by their own crew", log = "Moth was faster. The porter crawled out and told the Association everything, including that you'd tried." },
			},
		},
	}),
	beat({
		id = "sg_rogue_05",
		title = "The Warrant",
		text = "Two Surveillance Team agents are in the lobby of your building, and a third is at the back stairs. Your phone has three missed calls from a number you don't know. You have perhaps two minutes.",
		tags = { "danger" },
		when = { flags = { "sgr_on" } },
		choices = {
			{ label = "Go down and turn yourself in", result = { setFlags = { "sgr_surrendered" }, schedule = { event = "sg_rogue_06", inYears = 1 }, log = "You walked down the stairs with your hands where they could see them." } },
			{
				label = "Offer to testify against the crew",
				hint = "Only if you have something true to tell them.",
				requires = { flags = { "sgr_conscience" } },
				result = { setFlags = { "sgr_witness" }, schedule = { event = "sg_rogue_07", inYears = 1 }, log = "You told them about the porter, and Moth, and the man in the good coat. They took notes for six hours." },
			},
			{
				label = "Run",
				hint = "They're A-rank, and they've done this before.",
				clash = { stat = "agility", foe = "The Surveillance Team", coins = 4, base = 26, coinPower = 7, fixed = true },
				win = { sanity = -6, setFlags = { "sgr_fugitive" }, schedule = { event = "sg_rogue_08", inYears = 2 }, log = "Out of a bathroom window, across two roofs and onto a night bus. You've been running ever since." },
				lose = { vitality = { -130, -60 }, setFlags = { "sgr_surrendered" }, schedule = { event = "sg_rogue_06", inYears = 1 }, cause = ARREST, log = "They caught you on the second roof." },
			},
			{
				label = "Fight your way out",
				clash = { stat = "strength", foe = "The Surveillance Team", coins = 4, base = 28, coinPower = 8, fight = true, fixed = true },
				win = { sanity = -10, setFlags = { "sgr_fugitive" }, schedule = { event = "sg_rogue_08", inYears = 2 }, log = "You got out. Nobody died. The charge sheet got a lot longer." },
				lose = { vitality = { -130, -60 }, setFlags = { "sgr_surrendered" }, schedule = { event = "sg_rogue_06", inYears = 1 }, cause = ARREST, log = "They were ready for exactly that." },
			},
		},
	}),
	beat({
		id = "sg_rogue_06",
		title = "The Verdict",
		text = "The court hears all of it: the unreported Gates, the unsealed crystals, the van on the coast road. Your licence is revoked. The judge is deciding how long you'll spend in a mana-suppression facility, where Hunters serve their sentences.",
		when = { flags = { "sgr_on" } },
		choices = {
			{ label = "Accept it", result = { quitCareer = true, clearFlags = { "licensed" }, setFlags = { "fate_rogue_prison" }, sanity = -10, money = -20, schedule = { event = "sg_rogue_09", inYears = 6 }, log = "Six years. The door of your cell was the thickest thing you'd ever seen." } },
			{
				label = "Ask the people you saved to speak for you",
				hint = "Only if there are some.",
				requires = { flags = { "sgr_saved_town" } },
				result = { quitCareer = true, clearFlags = { "licensed" }, setFlags = { "fate_rogue_redeemed" }, sanity = -2, schedule = { event = "sg_rogue_09r", inYears = 2 }, log = "Half the harbour town came on a bus and filled the gallery. Two years, suspended after one." },
			},
			{
				label = "Fight the charges",
				clash = { stat = "intelligence", foe = "The prosecution", coins = 2, base = 9, coinPower = 4 },
				win = { quitCareer = true, clearFlags = { "licensed" }, setFlags = { "fate_rogue_prison" }, sanity = -6, money = -10, schedule = { event = "sg_rogue_09", inYears = 3 }, log = "Your lawyer got it down to three years." },
				lose = { quitCareer = true, clearFlags = { "licensed" }, setFlags = { "fate_rogue_prison" }, sanity = -12, money = -30, schedule = { event = "sg_rogue_09", inYears = 8 }, log = "Eight years. The judge said you'd shown no remorse, and you hadn't, yet." },
			},
		},
	}),
	beat({
		id = "sg_rogue_07",
		title = "The Witness",
		text = "Moth's lawyers have spent a year trying to make you look like a liar. Tomorrow you testify. Tonight a car has been parked outside your building for three hours with its engine running.",
		when = { flags = { "sgr_on" } },
		choices = {
			{
				label = "Testify",
				clash = { stat = "willpower", foe = "Moth's lawyers", coins = 2, base = 8, coinPower = 3 },
				win = { willpower = 3, sanity = 4, setFlags = { "fate_rogue_redeemed" }, schedule = { event = "sg_rogue_09r", inYears = 2 }, log = "You told the court everything, including what you did. Moth got twelve years. You got probation." },
				lose = { sanity = -6, setFlags = { "fate_rogue_redeemed" }, schedule = { event = "sg_rogue_09r", inYears = 2 }, log = "You stumbled, and they went for it, and the porter's testimony carried it anyway." },
			},
			{ label = "Ask the Surveillance Team who's in the car", result = { sanity = 2, setFlags = { "fate_rogue_redeemed" }, schedule = { event = "sg_rogue_09r", inYears = 2 }, log = "It was theirs. They'd been guarding you for a month. You testified the next day, and it went the way the truth goes, eventually." } },
		},
	}),
	beat({
		id = "sg_rogue_08",
		title = "The Harbour Road",
		text = "You've been living under another name in a fishing town for two years. This morning a Gate opened on the harbour road. The nearest Association team is ninety minutes away. You're the only Hunter for fifty kilometres, and everyone knows the quiet stranger at the net shed is strong.",
		tags = { "danger" },
		when = { flags = { "sgr_on" }, form = HUNTERS },
		choices = {
			{
				label = "Clear it, and wait for the Surveillance Team",
				clash = { stat = "strength", foe = "A C-rank Gate on the harbour road", enemy = "gate_c", coins = 3, base = 13, coinPower = 5, fight = true, fixed = true },
				win = { willpower = 3, sanity = 2, setFlags = { "sgr_saved_town" }, schedule = { event = "sg_rogue_06", inYears = 1 }, log = "You cleared it, then sat on the harbour wall until the agents came, and held out your wrists." },
				lose = { vitality = { -44, -20 }, setFlags = { "sgr_saved_town" }, schedule = { event = "sg_rogue_06", inYears = 1 }, cause = "Killed defending a harbour town from a Gate", log = "You held it until the Association came. Then you held out your wrists." },
			},
			{
				label = "Clear it, and disappear again",
				clash = { stat = "strength", foe = "A C-rank Gate on the harbour road", enemy = "gate_c", coins = 3, base = 13, coinPower = 5, fight = true, fixed = true },
				win = { sanity = -4, schedule = { event = "sg_rogue_08b", inYears = 2 }, log = "You cleared it and were gone before anyone could thank you." },
				lose = { vitality = { -44, -20 }, schedule = { event = "sg_rogue_08b", inYears = 2 }, cause = "Killed defending a harbour town from a Gate", log = "You cleared it, barely, and limped out of town that night." },
			},
			{ label = "Stay hidden", result = { sanity = -10, schedule = { event = "sg_rogue_08b", inYears = 2 }, log = "You watched from the shed. The Association came at ninety-one minutes. Some of the houses on the harbour road were gone." } },
		},
	}),
	beat({
		id = "sg_rogue_08b",
		title = "The Knock",
		text = "The knock on the door is polite. Three Surveillance Team agents, one of them an A-rank, and a fourth on the roof across the street. 'It's over,' the A-rank says. 'Let's not make it worse.'",
		tags = { "danger" },
		when = { flags = { "sgr_on" } },
		choices = {
			{ label = "Go with them", result = { setFlags = { "sgr_surrendered" }, schedule = { event = "sg_rogue_06", inYears = 1 }, log = "You picked up your coat and went with them. It was almost a relief." } },
			{
				label = "Make a run for it",
				clash = { stat = "agility", foe = "The Surveillance Team", coins = 4, base = 26, coinPower = 7, fixed = true },
				win = { sanity = -10, setFlags = { "sgr_ghost" }, log = "You got away again. You'll be running for the rest of your days." },
				lose = { vitality = { -130, -60 }, setFlags = { "sgr_surrendered" }, schedule = { event = "sg_rogue_06", inYears = 1 }, cause = ARREST, log = "The agent on the roof was waiting for exactly that." },
			},
			{
				label = "Fight",
				clash = { stat = "strength", foe = "The Surveillance Team", coins = 4, base = 28, coinPower = 8, fight = true, fixed = true },
				win = { sanity = -12, setFlags = { "sgr_ghost" }, log = "You fought your way out of your own front door. Nobody will knock politely again." },
				lose = { vitality = { -130, -60 }, setFlags = { "sgr_surrendered" }, schedule = { event = "sg_rogue_06", inYears = 1 }, cause = ARREST, log = "Four agents, and they'd done this before." },
			},
		},
	}),
	beat({
		id = "sg_rogue_09",
		title = "Released",
		text = "The facility's door opens onto a street you don't recognise. You have a bag, a bus pass and no licence. Before you reach the bus stop, a car pulls up. It's someone from Moth's old crew. 'There's always work,' she says.",
		when = { flags = { "sgr_on", "fate_rogue_prison" } },
		choices = {
			{ label = "Get in", result = { money = { 10, 30 }, sanity = -6, setFlags = { "sgr_relapse" }, schedule = { event = "sg_rogue_08b", inYears = 2 }, log = "You got in. It was exactly like before, and worse." } },
			{ label = "Walk to the bus stop", result = { sanity = 4, willpower = 2, setFlags = { "sgr_straight" }, career = "construction", log = "You took the bus. You got a job with a crew rebuilding a block a Gate had flattened. It was honest, it was hard, and it was enough." } },
			{ label = "Go to the Association and ask how to earn a licence back", result = { willpower = 3, setFlags = { "sgr_straight" }, schedule = { event = "sg_rogue_09r", inYears = 3 }, log = "The clerk looked at your record for a long time. Then she gave you a form, and a list of conditions three pages long." } },
		},
	}),
	beat({
		id = "sg_rogue_09r",
		title = "A Second Licence",
		text = "The Association has reviewed your case: a probationary licence. Cordon duty, mining crews, every raid logged and checked for five years. The officer stamping it says, 'Most people we give these to come back in handcuffs. Don't.'",
		when = { flags = { "sgr_on" }, form = HUNTERS },
		result = { setFlags = { "licensed", "fate_rogue_redeemed" }, sanity = 6, willpower = 2, career = "collection_crew", log = "You didn't. Years later you started teaching rookies a class nobody else at the Association could: where the line is, and what it costs to cross it." },
	}),
}
