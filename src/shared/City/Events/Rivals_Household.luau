--[[
	RIVALS AND HOUSEHOLDS (v0.13). A rival can stay a rival for life, or become the best
	friend you have: their bad year, a contract you both want, an enemy you share. And a
	household made a marriage (Config.marriage) has years of its own. Never romance: family,
	work, a table, and the District's register. {rival} and {partner} are the first of each.
]]

local function check(stat: string, foe: string, base: number?)
	return { stat = stat, foe = foe, coins = 2, base = base or 4, coinPower = 3 }
end

return {
	-- ── rivals ──
	{
		id = "rv_bad_year",
		title = "Your Rival's Bad Year",
		text = "{rival} is having the worst year of their life. The job went, then the savings went with it, and now {rival} is sleeping on a bench in the courier depot. Everyone on the street knows. Everyone is waiting to see what you do about it.",
		weight = 3,
		once = true,
		tags = { "people" },
		when = { minAge = 16, hasRelation = "rival" },
		choices = {
			{ label = "Help, quietly", requires = { min = { money = 300 } }, result = { money = -300, relationBond = { kind = "rival", amount = 20 }, sanity = 3, setFlags = { "rv_helped" }, log = "You paid a month's rent on a room for {rival} through a landlord who swore never to say who. {rival} found out in a week. Of course." } },
			{ label = "Rub it in", result = { renown = 2, sanity = -2, relationBond = { kind = "rival", amount = -10 }, log = "You walked past the courier depot every morning, whistling. It felt good for about four days." } },
			{
				label = "Offer {rival} work",
				hint = "Swallow your pride, or theirs.",
				clash = check("charisma", "A rival with nothing left but pride", 5),
				win = { reconcile = true, sanity = 4, log = "{rival} said no, twice, then yes. Six months later you can't remember how you ever worked without them." },
				lose = { relationBond = { kind = "rival", amount = -4 }, log = "\"I'd rather sleep in the depot,\" {rival} said, and meant it, and did." },
			},
		},
	},
	{
		id = "rv_same_contract",
		title = "The Same Contract",
		text = "You and {rival} have both been hired for the same job, by a client who thought it would be efficient. Whoever finishes it gets paid. Whoever doesn't gets laughed at by everyone who hears the story, which will be everyone.",
		weight = 3,
		cooldown = 5,
		tags = { "people", "work" },
		when = { minAge = 18, hasRelation = "rival" },
		choices = {
			{
				label = "Race {rival} for it",
				clash = check("speed", "A rival who wants it as badly as you do", 6),
				win = { wage = { 200, 500 }, renown = 3, relationBond = { kind = "rival", amount = -3 }, log = "You finished it four minutes before {rival} did, and you'll be telling people about those four minutes for years." },
				lose = { sanity = -3, relationBond = { kind = "rival", amount = 2 }, log = "{rival} finished first, by four minutes, and bought you a bowl of noodles out of the fee, which was unbearable." },
			},
			{ label = "Split it with {rival}", result = { wage = { 100, 250 }, relationBond = { kind = "rival", amount = 12 }, log = "You did it together, and split the fee down the middle. It went better than either of you will ever admit." } },
		},
	},
	{
		id = "rv_common_enemy",
		title = "An Enemy You Share",
		scene = { set = "alley", kicker = "Midnight", other = { rel = "rival", role = "your rival, with a crowbar" }, line = "\"I hate this. But I hate them more.\"" },
		text = "A Syndicate has started leaning on you and {rival} both, the same week, the same way: fees, threats, a broken window each. {rival} turns up at your door at midnight with a crowbar and an expression you've never seen before. \"I hate this,\" {rival} says, \"but I hate them more.\"",
		weight = 3,
		once = true,
		tags = { "people", "danger", "crime" },
		when = { minAge = 16, side = "backstreets", hasRelation = "rival" },
		choices = {
			{
				label = "Fight them together",
				clash = { stat = "strength", foe = "A Syndicate that picked the wrong two people", enemy = "syndicate", fight = true, coins = 3, base = 5, coinPower = 3 },
				win = { reconcile = true, renown = 6, log = "Back to back, it turned out, you and {rival} fight like you've been practicing for years. Which, in a way, you have." },
				lose = { health = { -16, -6 }, relationBond = { kind = "rival", amount = 10 }, cause = "A Syndicate", log = "You lost, together. {rival} carried you home, complaining the whole way." },
			},
			{ label = "Tell {rival} to handle their own", result = { relationBond = { kind = "rival", amount = -8 }, money = -150, log = "You paid your fee and {rival} fought theirs. {rival} won, which is somehow the worst outcome for you." } },
		},
	},

	-- ── a marriage's years ──
	{
		id = "hh_anniversary",
		title = "Years on the Register",
		text = "It's been years since you and {partner} turned a household into a marriage at the District office. {partner} has, alarmingly, remembered the exact date, and is waiting for you to have remembered too.",
		weight = 3,
		cooldown = 6,
		tags = { "people", "home" },
		when = { minAge = 24, flags = { "married" }, hasRelation = "partner" },
		choices = {
			{ label = "Dinner somewhere with tablecloths", requires = { min = { money = 120 } }, result = { money = -120, relationBond = { kind = "partner", amount = 10 }, sanity = 5, log = "Tablecloths, a candle, and a waiter who called you both by name. {partner} pretended not to be impressed for exactly one course." } },
			{ label = "Cook the meal from the wedding", result = { relationBond = { kind = "partner", amount = 12 }, sanity = 4, log = "You cooked the dumplings from the wedding meal. They were worse than the wedding's. {partner} ate them all." } },
			{ label = "You forgot", result = { relationBond = { kind = "partner", amount = -8 }, sanity = -2, log = "You forgot. {partner} didn't say anything, which was much worse than if they had." } },
		},
	},
	{
		id = "hh_partner_offer",
		title = "{partner}'s Big Chance",
		text = "{partner} has been offered the job of a lifetime, in another District: better pay, a title, a desk with a window. It would mean starting again somewhere new, or a long commute, or {partner} saying no. {partner} hasn't said anything yet. They're waiting for you.",
		weight = 3,
		once = true,
		tags = { "people", "home" },
		when = { minAge = 24, hasRelation = "partner" },
		choices = {
			{ label = "Tell {partner} to take it", result = { relationBond = { kind = "partner", amount = 14 }, money = { 200, 600 }, sanity = 3, log = "{partner} took it. The commute is terrible. {partner} comes home happy every night, and the household is better off for it." } },
			{ label = "Ask {partner} to stay", clash = check("charisma", "A desk with a window", 5), win = { relationBond = { kind = "partner", amount = 4 }, log = "{partner} stayed, and said it was an easy choice, and you've never been sure that was true." }, lose = { relationBond = { kind = "partner", amount = -10 }, money = { 200, 600 }, log = "{partner} took the job anyway, and you've both had to get used to that." } },
		},
	},
	{
		id = "hh_two_families",
		title = "Both Families, One Table",
		text = "{partner} has invited both your families to dinner, at your table, on the same evening. There are not enough chairs. There are definitely not enough opinions to go round; there are far too many.",
		weight = 3,
		once = true,
		tags = { "people", "home" },
		when = { minAge = 22, flags = { "married" }, hasRelation = "partner" },
		choices = {
			{ label = "Keep the peace", clash = check("charisma", "Two families and one table", 6), win = { relationBond = { kind = "partner", amount = 10 }, sanity = 6, log = "Nobody argued about anything important, and the important arguments were kept for the stairwell. By dessert, someone's aunt was teaching someone's cousin a card trick." }, lose = { sanity = -4, relationBond = { kind = "partner", amount = 2 }, log = "By the second course it was one family's manners against the other's, and nobody won. {partner} laughed about it for a week." } },
			{ label = "Cook enough for an army", result = { money = -80, health = 1, sanity = 4, relationBond = { kind = "partner", amount = 6 }, log = "You cooked so much that nobody had a mouth free to argue with. It's a strategy. It worked." } },
		},
	},
}
