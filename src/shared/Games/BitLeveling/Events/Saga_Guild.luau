--[[
	SAGA: YOUR OWN GUILD (ORIGINAL GAME CONTENT). A Hunter founds a guild in a rented room
	and takes it, or fails to take it, to a tower. Guilds, raid rights, the Association's
	auctions and emergency Gates follow canon; the guild, its rival (the Ironvale Guild) and
	every person in it are this game's own. No canon guild is involved.

	Chain: sg_guild_01 (opener) > 02 > 03 > 04 > 05 > 06 > 07 (or 07x, the collapse) > 08.
	Follow-ups are weight 0 and reached only by `schedule`; each one re-checks its `when`.
	Fates: fate_guild_master, fate_guild_fell.
]]

local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local MID_UP = { "hunter_c", "hunter_b", "hunter_a", "hunter_s" }

-- a follow-up beat: never drawn at random, shown at most once (even if two paths schedule
-- it), and never in a world that was rewritten (there are no guilds there)
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

return {
	{
		id = "sg_guild_01",
		title = "A Guild of Your Own",
		text = "You've raided under other people's names for long enough. A registration form for a new guild is on your table: a name, a master, three licensed members and a fee to the Association. The fee is the easy part. The hard part is everything after.",
		weight = 4,
		once = true,
		when = { minAge = 24, maxAge = 45, minYear = 3, form = MID_UP, flags = { "licensed" }, notFlags = { "sg_career_arc", "world_rewritten" } },
		choices = {
			{
				label = "Found it with your own savings",
				hint = "50 {currency}. Nobody owns a piece of you.",
				requires = { min = { money = 50 } },
				result = { money = -50, setFlags = { "sg_career_arc", "sgg_on", "sgg_own" }, schedule = { event = "sg_guild_02", inYears = 1 }, codex = { "lore_rights" }, log = "You registered the {last} Guild in a rented room above a phone shop. Three members, one desk, and a sign you painted yourself." },
			},
			{
				label = "Take an investor's money",
				hint = "A crystal-trading firm will pay for everything. They'd like a say.",
				result = { money = 10, setFlags = { "sg_career_arc", "sgg_on", "sgg_investor" }, schedule = { event = "sg_guild_02", inYears = 1 }, codex = { "lore_rights" }, log = "The firm paid the fee, the rent and a year of salaries. Their man sits in on your meetings and takes notes." },
			},
			{ label = "Not yet", result = { log = "You put the form in a drawer. It's still there." } },
		},
	},
	beat({
		id = "sg_guild_02",
		title = "The First Gate",
		text = "The {last} Guild's first purchase: the raid rights to a C-rank Gate in an underpass. Your three members are looking at you the way you used to look at your old raid leaders. Now you're the one who has to be right.",
		tags = { "danger" },
		when = { flags = { "sgg_on" }, form = HUNTERS },
		choices = {
			{
				label = "Lead from the front",
				clash = { stat = "strength", foe = "A C-rank dungeon", enemy = "gate_c", coins = 3, base = 13, coinPower = 5, fight = true, fixed = true },
				win = { strength = 2, charisma = 2, money = { 10, 25 }, setFlags = { "sgg_rep" }, schedule = { event = "sg_guild_03", inYears = 1 }, log = "Nobody got hurt. You sold the crystals that night and paid everyone before you paid yourself. Word gets around about things like that." },
				lose = { vitality = { -44, -20 }, sanity = -4, setFlags = { "sgg_shaky" }, schedule = { event = "sg_guild_03", inYears = 1 }, cause = "Killed leading their guild's first raid", log = "You got everyone out, barely. One of the three handed in their notice the next week." },
			},
			{
				label = "Plan it to the minute",
				hint = "Maps, timings, a fallback for every chamber.",
				clash = { stat = "intelligence", foe = "A C-rank dungeon's layout", coins = 2, base = 10, coinPower = 4, fixed = true },
				win = { intelligence = 2, money = { 8, 20 }, setFlags = { "sgg_rep" }, schedule = { event = "sg_guild_03", inYears = 1 }, log = "It went exactly the way you drew it. Your members started calling you 'the planner', and they meant it kindly." },
				lose = { vitality = { -30, -12 }, sanity = -3, setFlags = { "sgg_shaky" }, schedule = { event = "sg_guild_03", inYears = 1 }, cause = "Killed leading their guild's first raid", log = "The third chamber wasn't on your map. You improvised. It was ugly." },
			},
			{
				label = "Hire a veteran to lead it",
				hint = "10 {currency}. Safe, and not quite yours.",
				requires = { min = { money = 10 } },
				result = { money = { -6, 4 }, schedule = { event = "sg_guild_03", inYears = 1 }, log = "The veteran did the job well, and made sure everyone knew whose job it had been." },
			},
		},
	}),
	beat({
		id = "sg_guild_03",
		title = "The Rookie",
		text = "A B-rank rookie, measured last month, is being chased by every guild in the city. They came to your open day anyway, because 'the big guilds put rookies on porter duty for a year'. The Ironvale Guild has offered them twice what you can.",
		when = { flags = { "sgg_on" } },
		choices = {
			{
				label = "Offer a real share and a real role",
				clash = { stat = "charisma", foe = "Ironvale's offer", coins = 2, base = 8, coinPower = 3 },
				win = { charisma = 2, setFlags = { "sgg_star" }, schedule = { event = "sg_guild_04", inYears = 2 }, log = "They signed with you, on the back of a takeaway menu, then properly the next day." },
				lose = { sanity = -2, schedule = { event = "sg_guild_04", inYears = 2 }, log = "They signed with Ironvale. They looked sorry about it." },
			},
			{
				label = "Match Ironvale's money",
				hint = "40 {currency}.",
				requires = { min = { money = 40 } },
				result = { money = -40, setFlags = { "sgg_star" }, schedule = { event = "sg_guild_04", inYears = 2 }, log = "You matched it. Your accountant made a noise you'd never heard a person make." },
			},
			{ label = "Let them go", result = { schedule = { event = "sg_guild_04", inYears = 2 }, log = "You wished them luck. You meant it, and it still stung." } },
		},
	}),
	beat({
		id = "sg_guild_04",
		title = "Ironvale",
		text = "The Ironvale Guild has started buying the raid rights to every Gate your team bids on, at a loss, a day before the auction closes. Someone is telling them your bids. Your members are getting restless: no Gates, no pay.",
		when = { flags = { "sgg_on" } },
		choices = {
			{
				label = "Outbid them",
				hint = "40 {currency}. See who blinks.",
				requires = { min = { money = 40 } },
				result = { money = -40, setFlags = { "sgg_held" }, schedule = { event = "sg_guild_05", inYears = 1 }, log = "You won three auctions in a row and lost money on all of them. Ironvale blinked first." },
			},
			{
				label = "Report it to the Association",
				clash = { stat = "intelligence", foe = "A pattern nobody wants to see", coins = 2, base = 9, coinPower = 4 },
				win = { intelligence = 2, setFlags = { "sgg_clean" }, schedule = { event = "sg_guild_05", inYears = 1 }, codex = { "lore_kha" }, log = "The Association found the pattern and fined Ironvale. Their bids got very ordinary, very fast." },
				lose = { sanity = -3, schedule = { event = "sg_guild_05", inYears = 1 }, log = "No proof. The Association thanked you for your report." },
			},
			{
				label = "Find the leak yourself",
				clash = { stat = "intelligence", foe = "Someone careful", coins = 2, base = 8, coinPower = 3 },
				win = { intelligence = 1, willpower = 1, setFlags = { "sgg_leak_found" }, schedule = { event = "sg_guild_05", inYears = 1 }, log = "You fed three different bids to three different people and watched which one Ironvale matched." },
				lose = { sanity = -2, schedule = { event = "sg_guild_05", inYears = 1 }, log = "You suspected everyone for a month. It did nothing for morale." },
			},
		},
	}),
	beat({
		id = "sg_guild_05",
		title = "The Leak",
		text = "Your vice-master puts a phone on your desk: months of messages, from someone inside the {last} Guild to an Ironvale officer. Your bids. Your raid schedule. The name on the account is someone who's been with you since the room above the phone shop.",
		when = { flags = { "sgg_on" } },
		choices = {
			{ label = "Talk to them alone, and give them a second chance", result = { charisma = 1, sanity = -3, setFlags = { "sgg_forgave" }, schedule = { event = "sg_guild_06", inYears = 1 }, log = "They cried. They said Ironvale had bought up their family's debts. You believed them, mostly." } },
			{ label = "Hand everything to the Association", result = { willpower = 2, setFlags = { "sgg_clean" }, schedule = { event = "sg_guild_06", inYears = 1 }, log = "The Surveillance Team took the phone and your statement. Ironvale's officer lost their licence. So did your founding member." } },
			{ label = "Bury it, to protect the guild's name", result = { sanity = -5, setFlags = { "sgg_buried" }, schedule = { event = "sg_guild_06", inYears = 1 }, log = "You moved them to a desk with no access to anything and told nobody why. The secret sat in the office like a smell." } },
			{
				label = "Buy out the investor who placed them",
				hint = "60 {currency}. The firm's man brought them in.",
				requires = { flags = { "sgg_investor" }, min = { money = 60 } },
				result = { money = -60, setFlags = { "sgg_free" }, clearFlags = { "sgg_investor" }, schedule = { event = "sg_guild_06", inYears = 1 }, log = "The firm had placed them. You paid the firm back every won, with interest, and changed the locks." },
			},
		},
	}),
	beat({
		id = "sg_guild_06",
		title = "Guild War",
		text = "It stops being about auctions. In a B-rank Gate your team held the rights to, Ironvale Hunters were waiting in the second chamber. Nobody admits anything. Two of your people are in hospital. Your members want an answer, and the city's guild forums are calling it a war.",
		tags = { "danger" },
		when = { flags = { "sgg_on" }, form = HUNTERS },
		choices = {
			{
				label = "Answer them in the field",
				hint = "B-rank Hunters, and they'll be ready.",
				clash = { stat = "strength", foe = "Ironvale's strike team", enemy = "rogue_hunter", coins = 3, base = 20, coinPower = 6, fight = true, fixed = true },
				win = { strength = 3, charisma = 2, setFlags = { "sgg_won" }, schedule = { event = "sg_guild_07", inYears = 1 }, log = "You met their strike team at the next Gate and made them leave it. Nobody died. Everybody understood." },
				lose = { vitality = { -80, -36 }, sanity = -6, setFlags = { "sgg_falling" }, schedule = { event = "sg_guild_07x", inYears = 1 }, cause = "Killed in a guild war", log = "Ironvale was ready for you." },
			},
			{
				label = "Take it to the Association",
				hint = "Only works if they already have something on Ironvale.",
				requires = { flags = { "sgg_clean" } },
				result = { intelligence = 1, setFlags = { "sgg_won" }, schedule = { event = "sg_guild_07", inYears = 1 }, log = "With the leak already on file, the Association didn't need convincing. Ironvale lost its raid rights for a year, and half its members." },
			},
			{
				label = "Hold your people together and keep working",
				clash = { stat = "willpower", foe = "A guild that wants to give up", coins = 3, base = 10, coinPower = 3 },
				win = { willpower = 3, charisma = 1, setFlags = { "sgg_won" }, schedule = { event = "sg_guild_07", inYears = 1 }, log = "You visited both of them in hospital every day and took every small Gate going. Ironvale ran out of money before you ran out of nerve." },
				lose = { sanity = -8, setFlags = { "sgg_falling" }, schedule = { event = "sg_guild_07x", inYears = 1 }, log = "People started leaving, one apologetic message at a time." },
			},
		},
	}),
	beat({
		id = "sg_guild_07",
		title = "The Emergency Gate",
		text = "The Association calls: an A-rank Gate is close to breaking beside a hospital, and the big guilds are all committed elsewhere. Take it, and the {last} Guild gets the tax break and the headlines. Fail, and there won't be a {last} Guild.",
		tags = { "danger" },
		when = { flags = { "sgg_on" }, form = HUNTERS },
		choices = {
			{
				label = "Take it",
				hint = "An A-rank boss room.",
				clash = { stat = "strength", foe = "An A-rank Gate", enemy = "gate_a", coins = 4, base = 28, coinPower = 8, fight = true, fixed = true },
				win = { strength = 4, charisma = 3, money = { 40, 120 }, setFlags = { "sgg_top" }, schedule = { event = "sg_guild_08", inYears = 2 }, log = "You cleared it with six hours to spare. The hospital sent the guild a cake shaped like a Gate. It was on the news for a week." },
				lose = { vitality = { -130, -60 }, sanity = -8, setFlags = { "sgg_falling" }, schedule = { event = "sg_guild_07x", inYears = 1 }, cause = "Killed leading an emergency A-rank raid", log = "A bigger guild had to come and finish it. The headlines were theirs." },
			},
			{
				label = "Take it with a coalition of small guilds",
				clash = { stat = "charisma", foe = "Five guild masters in one room", coins = 3, base = 10, coinPower = 4 },
				win = { charisma = 3, money = { 20, 60 }, setFlags = { "sgg_top" }, schedule = { event = "sg_guild_08", inYears = 2 }, log = "Five small guilds, one plan, your name at the top of it. You cleared it together, and the others still send you new-year cards." },
				lose = { sanity = -6, money = -10, setFlags = { "sgg_falling" }, schedule = { event = "sg_guild_07x", inYears = 1 }, log = "The coalition fell apart over who'd lead. The Gate went to someone else, and so did half your members." },
			},
			{ label = "Turn it down", result = { sanity = -2, schedule = { event = "sg_guild_08", inYears = 3 }, log = "You said your people weren't ready. It was true, and it cost you. The {last} Guild grew the slow way after that." } },
		},
	}),
	beat({
		id = "sg_guild_07x",
		title = "The Collapse",
		text = "Members leaving, raid rights going to other guilds, rent due on a floor you can't fill. The {last} Guild is dying, and everyone in it knows.",
		when = { flags = { "sgg_on" } },
		choices = {
			{ label = "Close it with dignity", result = { sanity = -4, willpower = 2, setFlags = { "fate_guild_fell" }, clearFlags = { "sgg_on" }, log = "You paid every member their last share, closed the account and took the sign down yourself." } },
			{
				label = "Put everything you have into saving it",
				hint = "30 {currency}, and a lot of luck.",
				requires = { min = { money = 30 } },
				clash = { stat = "luck", foe = "A guild's last month", coins = 2, base = 8, coinPower = 3 },
				win = { money = -30, sanity = 2, clearFlags = { "sgg_falling" }, schedule = { event = "sg_guild_08", inYears = 2 }, log = "A big contract came in the week your savings ran out. It worked, somehow. You never quite believed it." },
				lose = { money = -30, sanity = -6, setFlags = { "fate_guild_fell" }, clearFlags = { "sgg_on" }, log = "It wasn't enough. It was never going to be enough." },
			},
			{ label = "Fold it into a bigger guild", result = { money = { 10, 30 }, setFlags = { "fate_guild_fell" }, clearFlags = { "sgg_on" }, log = "The {last} Guild became a branch office of someone else's. You kept a desk, and the sign, which nobody else wanted." } },
		},
	}),
	beat({
		id = "sg_guild_08",
		title = "Guild Master",
		text = "The {last} Guild has a floor in a tower in {district} now, a waiting list of rookies and a seat on the city's guild council. A magazine wants to photograph you in front of your own sign.",
		when = { flags = { "sgg_on" } },
		choices = {
			{ label = "Lead it for the rest of your career", result = { charisma = 3, sanity = 5, setFlags = { "fate_guild_master" }, log = "You stopped raiding every Gate and started choosing which ones were worth your people. That turned out to be the harder job." } },
			{ label = "Give the field to your vice-master and keep the desk", result = { intelligence = 2, sanity = 6, setFlags = { "fate_guild_master" }, log = "Your vice-master leads the strike teams now. You do the auctions, the contracts and the funerals, and you're good at all three." } },
			{ label = "Keep going through the Gate first", result = { strength = 2, sanity = 2, setFlags = { "fate_guild_master" }, log = "Guild master on paper, first through the Gate in practice. Your vice-master despairs of you." } },
		},
	}),
	{
		id = "sg_guild_09",
		title = "The Last Briefing",
		text = "Your last raid briefing as guild master. The room is full of Hunters who weren't born when you painted the first sign above the phone shop.",
		weight = 4,
		once = true,
		when = { minAge = 58, flags = { "fate_guild_master" }, notFlags = { "world_rewritten" } },
		result = { sanity = 5, charisma = 1, log = "You went through the plan, wished them luck and told them to come home. They clapped. You pretended something was in your eye." },
	},
}
