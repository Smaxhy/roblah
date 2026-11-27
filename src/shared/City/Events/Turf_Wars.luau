--[[
	TURF WARS (v0.13): the streets of a Backstreets District, block by block (Engine/Turf.luau,
	City/Turf.luau, Activities/Turf.luau). How a life steps in, what the war asks of it, and
	what it costs to hold a street.
	Canon: in the Backstreets nobody keeps the peace but whoever is strongest; Syndicates and
	Rats fight over streets; the Fingers take a cut of whole Districts; the Thumb is formal and
	keeps ranks, the Middle repays every grudge, the Kurokumo Clan is old-fashioned and proud
	[LoR, Limbus]. The blocks, people and wars here are this game's own.
]]

local function check(stat: string, foe: string, base: number?)
	return { stat = stat, foe = foe, coins = 2, base = base or 4, coinPower = 3 }
end

return {
	{
		id = "turf_word",
		title = "Whose Street Is It",
		scene = { set = "street", kicker = "Your street", other = { name = "A Thumb Soldato", foe = "thumb_soldato" }, line = "\"Whose side will you be on, when it comes to it?\"" },
		text = "The noodle row under the overpass changed hands twice this month, and the laundry court three times. Everyone on your street pays someone, and nobody is sure who anymore. A Syndicate runner, a Thumb Soldato in a pressed suit and a Little Brother of the Middle have all been round this week, separately, asking whose side you'll be on when it comes to it.",
		weight = 5,
		once = true,
		tags = { "crime", "danger", "turf" },
		when = { minAge = 18, side = "backstreets", notFlags = { "turf_in" } },
		choices = {
			{ label = "Step in, for yourself", hint = "Take blocks under your own name. Everyone is your enemy.", result = { turfJoin = "crew", renown = 2, setFlags = { "turf_own_crew" }, log = "You told all three of them the same thing: you'd be on your own side. The Syndicate runner laughed. The Soldato didn't." } },
			{ label = "Step in under the Thumb's colours", hint = "Formal, ranked, and nobody touches the Thumb's people.", requires = { flags = { "knows_thumb" } }, result = { turfJoin = "thumb", rep = { thumb = 10, middle = -6 }, log = "The Soldato bowed very slightly and gave you a card with a Capo's name on it. \"Courtesy,\" he said, \"is everything.\"" } },
			{ label = "Step in with the Middle", hint = "The Middle's siblings stand by their own. And repay every slight.", requires = { flags = { "knows_middle" } }, result = { turfJoin = "middle", rep = { middle = 10, thumb = -6 }, log = "The Little Brother tied a yellow cord around your wrist. \"Now you're family,\" he said. \"Family settles family's debts.\"" } },
			{ label = "Stay out of it", result = { sanity = 1, log = "You paid whoever came round, and kept your head down, and the war went on around you." } },
		},
	},
	{
		id = "turf_clan_invite",
		title = "Tea with the Clan",
		text = "A Kurokumo Clan runner in a dark kimono-cut coat bows at your door and hands you a folded paper: an invitation to tea, from a Clan captain, about the streets. The Clan is old-fashioned. It remembers favors for generations, and slights for longer.",
		weight = 3,
		once = true,
		tags = { "crime", "turf" },
		when = { minAge = 18, side = "backstreets", flags = { "knows_kurokumo" }, notFlags = { "turf_in" } },
		choices = {
			{ label = "Join the Clan's side of the war", hint = "Old manners, long blades, and a captain who doesn't forget a favor.", result = { turfJoin = "kurokumo", rep = { kurokumo = 10 }, log = "The captain received you in a room with paper walls and poured the tea herself. You understood that this was a great honor and a great debt." } },
			{ label = "Drink the tea, and decline", result = { rep = { kurokumo = 2 }, sanity = 1, log = "You drank the tea properly, and declined properly, and the captain seemed to think better of you for both." } },
		},
	},
	{
		id = "turf_raid",
		title = "They Came for Your Block",
		text = "Word comes at midnight: someone is moving on one of your blocks, with numbers. The shopkeepers have pulled their shutters down, and the people who pay you for protection are waiting to see whether they bought any.",
		weight = 0,
		tags = { "crime", "danger", "turf" },
		choices = {
			{
				label = "Hold the block",
				clash = { stat = "strength", foe = "A crew who want your street", enemy = "syndicate", fight = true, coins = 3, base = 6, coinPower = 4 },
				win = { turfGuard = true, renown = { 3, 6 }, log = { "You held it. By morning the shutters were up and the noodle row smelled of broth again, and people nodded to you on the way past.", "They came with numbers. You came with a reason. The block is still yours.", "It was ugly and it was short. Your block, your rules, and now everyone remembers why." } },
				lose = { turfLose = 1, health = { -16, -6 }, cause = "A turf war", log = { "They took the block. You'll hear about it every time you walk past.", "You lost the block, and a good coat, and very nearly more." } },
			},
			{ label = "Pay them to go away", requires = { min = { money = 300 } }, result = { money = -300, turfGuard = true, log = "You paid. They went. Everyone saw you pay, which will cost more later." } },
			{ label = "Let the block go", result = { turfLose = 1, sanity = -2, log = "You let it go. The shopkeepers on that block will be paying someone else now, and they know you let them." } },
		},
	},
	{
		id = "turf_parley",
		title = "A Parley Under the Overpass",
		text = "Your rivals in the turf war want to talk: under the overpass, at noon, no weapons, one person each. A truce would mean a quiet year. Not having one would mean a loud one. Either way, everyone will be watching who leaves the overpass looking happier.",
		weight = 3,
		cooldown = 4,
		tags = { "crime", "turf" },
		when = { minAge = 19, side = "backstreets", flags = { "turf_in" } },
		choices = {
			{ label = "Agree to a truce", result = { turfGuard = true, sanity = 3, log = "A quiet year. You shook on it. Nobody counted their fingers afterwards, which is how you knew they meant it." } },
			{
				label = "Demand tribute instead",
				clash = check("charisma", "People who came to bargain, not to pay", 6),
				win = { money = { 400, 900 }, renown = 4, log = "They paid tribute for a quiet year. It was more than they wanted to and less than you asked, which is how a good bargain feels." },
				lose = { renown = -2, log = "They laughed, and walked away, and the war went on." },
			},
			{
				label = "Turn up armed",
				hint = "Take a block while they're talking. Nobody will trust you again.",
				clash = { stat = "speed", foe = "A parley that turns into an ambush", enemy = "syndicate", fight = true, coins = 3, base = 6, coinPower = 3 },
				win = { turfTake = 1, renown = 6, rep = { thumb = -4, middle = -4, kurokumo = -4 }, log = "You took a block before the parley had properly started. It worked. Nobody will meet you under the overpass again." },
				lose = { health = { -18, -8 }, renown = -3, cause = "A turf war", log = "They'd had the same idea, and more people." },
			},
		},
	},
	{
		id = "turf_call",
		title = "Your Side Calls You In",
		text = "The people whose colours you wear in the turf war are making a push tonight, and they want you at the front of it. If it works, the District's map changes by morning. If it doesn't, everyone who was at the front will be remembered for it.",
		weight = 3,
		cooldown = 3,
		tags = { "crime", "danger", "turf" },
		when = { minAge = 19, side = "backstreets", flags = { "turf_in" }, notFlags = { "turf_own_crew" } },
		choices = {
			{
				label = "Lead the push",
				clash = { stat = "strength", foe = "A District's worth of rivals", enemy = "syndicate", fight = true, coins = 3, base = 7, coinPower = 4 },
				win = { turfTake = 2, renown = 10, money = { 200, 500 }, log = "Two blocks changed hands by morning, both of them to you. Your side's people bought you breakfast and didn't let you pay." },
				lose = { health = { -22, -10 }, turfLose = 1, cause = "A turf war", log = "The push broke on the canal stairs. You held the line long enough for everyone to get out, which counts for something with your side, and nothing with your ribs." },
			},
			{ label = "Hold the rear", result = { turfGuard = true, renown = 2, log = "You held the rear and made sure nobody took a block behind your side's back. Not glorious. Necessary." } },
			{ label = "Say no", result = { renown = -3, sanity = 1, log = "You said no. Your side said nothing, which is worse, and remembered." } },
		},
	},
	{
		id = "turf_shopkeeper",
		title = "The Noodle Row Asks",
		text = "The woman who runs the noodle stall on your block, with the burns on both forearms and the best broth in the District, comes to you with a problem: Rats have started taking a second fee on your block, on top of yours. She's paying it. She won't for long.",
		weight = 3,
		cooldown = 3,
		tags = { "crime", "turf" },
		when = { minAge = 18, side = "backstreets", flags = { "turf_in" } },
		choices = {
			{
				label = "Have a word with the Rats",
				clash = { stat = "strength", foe = "Rats taking a second fee", enemy = "rat", fight = true, coins = 2, base = 5, coinPower = 3 },
				win = { renown = 4, sanity = 3, rep = { rats = -6 }, log = "The Rats stopped taking a second fee. The noodle stall started giving you a second bowl." },
				lose = { health = { -12, -4 }, renown = -2, cause = "A turf war", log = "There were more Rats than you'd been told. The stall still pays two fees. For now." },
			},
			{ label = "Cut her fee instead", result = { money = -150, sanity = 4, charisma = 1, log = "You halved her fee until the Rats were dealt with. Word went round the block that you're fair, which is worth more than the fee." } },
			{ label = "Tell her it's not your problem", result = { money = 80, sanity = -3, log = "She stopped making your broth the way she used to. Everyone on the block noticed." } },
		},
	},
	{
		id = "turf_all_held",
		title = "A Finger Notices",
		text = "You hold every block in the District now, and that kind of thing gets noticed by people who think in Districts. A courier brings an envelope with no name on it, only a fingerprint in red wax. The letter inside is polite. It congratulates you, and names a percentage.",
		weight = 6,
		once = true,
		tags = { "crime", "danger", "turf" },
		when = { minAge = 19, flags = { "turf_all" } },
		choices = {
			{ label = "Pay the Finger's share", result = { money = -1500, turfGuard = true, gear = "tf_district_ledger", log = "You paid. A week later a leather ledger arrived with every block in the District in it, and a note: Keep good books." } },
			{
				label = "Refuse, in writing",
				clash = { stat = "strength", foe = "What a Finger sends when you say no", enemy = "thumb_capo", fight = true, coins = 4, base = 9, coinPower = 5 },
				win = { renown = 25, impact = { kind = "hold" }, gear = "tf_district_ledger", log = "They sent someone very good. You were better. The District is yours, and everyone from here to the Nest has heard who said no to a Finger and lived." },
				lose = { turfLose = 3, health = { -30, -14 }, cause = "Saying no to a Finger", log = "They sent someone very good, and they were better. Half the District changed hands by morning." },
			},
			{ label = "Hand the District back to the Syndicates", result = { turfLose = 6, sanity = 6, money = { 1000, 2000 }, log = "You sold every block back, one by one, for a good price, and walked away from the turf war with clean hands. Nearly clean." } },
		},
	},
}
