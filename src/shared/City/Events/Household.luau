--[[
	A HOUSEHOLD OF YOUR OWN (v0.12): life with a household partner (relationKinds.partner,
	the "Ask them to share a household" interaction). Roblox-safe on purpose: two names on a
	District's household register, chores, rent, the locks at 3:13, a child taken in from the
	foundling house. Never romance, and never another player.
]]

return {
	{
		id = "hh_p_first_year",
		title = "The First Year Under One Roof",
		text = "It turns out {partner} hangs the keys on a nail by the door, and you've always thrown them in a bowl. It turns out this matters a great deal to both of you.",
		weight = 8,
		once = true,
		tags = { "home", "people" },
		when = { hasRelation = { "partner" }, minAge = 20 },
		choices = {
			{ label = "Use the nail", result = { relationBond = { kind = "partner", amount = 6 }, sanity = 2, log = "You hung the keys on the nail. {partner} pretended not to notice, and was very pleased." } },
			{ label = "Buy a second bowl", result = { relationBond = { kind = "partner", amount = 4 }, sanity = 3, log = "Two bowls by the door now, side by side. It's the most sensible thing either of you has ever done." } },
			{ label = "Keep throwing them in the bowl", result = { relationBond = { kind = "partner", amount = -4 }, log = "The keys are in the bowl. {partner} moves them to the nail every night. Neither of you says anything." } },
		},
	},
	{
		id = "hh_p_locks",
		title = "Whose Turn for the Locks",
		text = "It's ten to three. The Night starts at 3:13, and somebody has to check every lock in the flat twice. {partner} is already asleep. You're almost certain it's their turn.",
		weight = 7,
		cooldown = 4,
		tags = { "home", "night" },
		when = { hasRelation = { "partner" } },
		choices = {
			{ label = "Check them yourself", result = { relationBond = { kind = "partner", amount = 5 }, mind = 1, log = "Six locks, twice each. You got back into bed at 3:12 and lay listening to the street go quiet." } },
			{ label = "Wake {partner}", result = { relationBond = { kind = "partner", amount = -3 }, sanity = 1, log = "{partner} checked them grumbling, and checked them very thoroughly, out of spite." } },
		},
	},
	{
		id = "hh_p_job_offer",
		title = "A Job Across the City",
		text = "{partner} has been offered work in another District: better pay, worse hours, a long way from here. \"We'd have to move,\" they say. \"Both of us, or neither.\"",
		weight = 5,
		once = true,
		tags = { "home", "work" },
		when = { hasRelation = { "partner" }, minAge = 24 },
		choices = {
			{ label = "Move together", hint = "A new District, and their better pay.", result = { district = "random", money = { 200, 400 }, relationBond = { kind = "partner", amount = 10 }, log = "You packed the whole flat into nine crates and a borrowed cart. The new place has a window that faces east." } },
			{ label = "Ask them to stay", clash = { stat = "charisma", foe = "A very good offer", coins = 2, base = 5, coinPower = 3 }, win = { relationBond = { kind = "partner", amount = 4 }, log = "{partner} turned it down, and didn't hold it against you, mostly." }, lose = { relationBond = { kind = "partner", amount = -12 }, sanity = -3, log = "{partner} stayed. You both know what it cost. Neither of you mentions it." } },
		},
	},
	{
		id = "hh_p_hurt",
		title = "A Knock From the Clinic",
		text = "A runner from a back-alley clinic is at your door: {partner} was caught in a fight that wasn't theirs on the way home. They'll be fine, the runner says, if somebody pays for the good ampules.",
		weight = 4,
		cooldown = 6,
		tags = { "home", "danger" },
		when = { hasRelation = { "partner" }, minAge = 20 },
		choices = {
			{ label = "Pay for the good ampules", requires = { min = { money = 250 } }, result = { money = -250, relationBond = { kind = "partner", amount = 12 }, sanity = 1, log = "You paid without counting. {partner} was home in two days, complaining about the clinic's tea." } },
			{ label = "Pay what you can", result = { money = -60, relationBond = { kind = "partner", amount = 4 }, sanity = -2, log = "The cheap ampules worked, slowly. {partner} limped for a season, and never once blamed you." } },
		},
	},
	{
		id = "hh_p_foundling",
		title = "The Foundling House Asks",
		text = "The foundling house on your street is full again after a bad Night. The matron knows you and {partner} by name. \"There's a child here who needs a door with good locks,\" she says. \"Yours has good locks.\"",
		weight = 4,
		once = true,
		tags = { "home", "family" },
		when = { hasRelation = { "partner" }, minAge = 25, maxAge = 55 },
		choices = {
			{ label = "Take the child in, together", result = { addRelation = { kind = "child", age = { 4, 9 }, bond = 60 }, setFlags = { "parent" }, relationBond = { kind = "partner", amount = 8 }, sanity = 5, log = "{newRelation} came home with you that evening, holding both your hands and saying nothing at all until the soup." } },
			{ label = "Give the house what you can spare", result = { money = -80, sanity = 2, log = "You left an envelope with the matron. She knew what it meant, and didn't make you say it." } },
		},
	},
	{
		id = "hh_p_old",
		title = "Still Under One Roof",
		text = "Years now, the two of you. {partner} still hangs the keys on the nail. You still check the locks twice. Some evenings neither of you says anything at all, and that's the best part.",
		weight = 6,
		once = true,
		tags = { "home", "people" },
		when = { hasRelation = { "partner" }, minAge = 50 },
		choices = {
			{ label = "Tell them what the years were like", result = { relationBond = { kind = "partner", amount = 10 }, sanity = 6, log = "You told {partner} everything you'd never quite said. They listened, and then told you theirs." } },
			{ label = "Just sit together", result = { sanity = 5, relationBond = { kind = "partner", amount = 6 }, log = "You sat by the window until the streetlights came on. It was enough. It was always enough." } },
		},
	},
}
