--[[
	SAGA: NATIONAL LEVEL (NON-CANON). Every card here says so in its text. Only on the world
	line where the Gates were kept (flag world_line_kept), after the war, for an S-rank.

	Canon has five National Level Hunters, the survivors of the dragon on the US West Coast;
	this arc never names one, never says what became of any of them, and never puts a canon
	character anywhere. "What's left of the armies that came through in the war" is this
	world line's own invention.

	Chain: sg_nat_01 > 02 > 03 > 04 > 05 > 06. Fate: fate_national_level.
]]

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

local S_HURT = "Killed in an S-rank raid after the war (non-canon)"

return {
	{
		id = "sg_nat_01",
		title = "Who's Left",
		text = "This world line kept its Gates (non-canon). The war is over, and the Gates are still opening. Too many of the world's strongest Hunters died in it. The Association's director puts it plainly: there are S-rank Gates coming that nobody left in the country can take. Except, possibly, you.",
		weight = 5,
		once = true,
		when = { minAge = 20, minYear = 13, form = "hunter_s", flags = { "world_line_kept", "licensed" }, notFlags = { "sg_kept_arc", "world_rewritten" } },
		choices = {
			{ label = "Take them", hint = "(non-canon)", result = { setFlags = { "sg_kept_arc", "sgn_on" }, schedule = { event = "sg_nat_02", inYears = 1 }, log = "(non-canon) You said yes. Your phone hasn't stopped ringing since." } },
			{ label = "Stay with your own work", result = { log = "You said the country had other S-ranks. It had fewer than it used to." } },
		},
	},
	beat({
		id = "sg_nat_02",
		title = "The Gate Nobody Else Can Take",
		text = "An S-rank Gate over a reservoir that supplies half a city (non-canon). Your team is the best the country has left, and every one of them is looking at you.",
		tags = { "danger" },
		when = { flags = { "sgn_on" }, form = "hunter_s" },
		choices = {
			{
				label = "Lead it",
				clash = { stat = "strength", foe = "An S-rank Gate", enemy = "gate_s", coins = 4, base = 42, coinPower = 11, fight = true, fixed = true },
				win = { strength = 8, charisma = 4, money = { 300, 900 }, schedule = { event = "sg_nat_03", inYears = 1 }, log = "You cleared it in a day. The city never lost its water. The papers ran your face above the fold for the first time." },
				lose = { vitality = { -240, -110 }, sanity = -8, schedule = { event = "sg_nat_03", inYears = 1 }, cause = S_HURT, log = "You cleared it, at a cost you carried out on a stretcher." },
			},
			{
				label = "Plan it with the team, slowly",
				clash = { stat = "intelligence", foe = "An S-rank Gate's clock", coins = 3, base = 24, coinPower = 7, fixed = true },
				win = { intelligence = 6, money = { 200, 600 }, schedule = { event = "sg_nat_03", inYears = 1 }, log = "Six days of planning, four hours of raid. Nobody was hurt. Everybody noticed." },
				lose = { vitality = { -120, -50 }, sanity = -6, schedule = { event = "sg_nat_03", inYears = 1 }, cause = S_HURT, log = "The plan was good. The Gate didn't follow it." },
			},
		},
	}),
	beat({
		id = "sg_nat_03",
		title = "The World Calls",
		text = "Another country's S-rank Gate is close to breaking, and its own Hunters are gone (non-canon). Its government calls yours. Yours calls you.",
		tags = { "danger" },
		when = { flags = { "sgn_on" }, form = "hunter_s" },
		choices = {
			{
				label = "Go",
				clash = { stat = "strength", foe = "An S-rank Gate abroad", enemy = "gate_s", coins = 4, base = 42, coinPower = 11, fight = true, fixed = true },
				win = { strength = 6, charisma = 5, money = { 500, 1500 }, setFlags = { "sgn_abroad" }, schedule = { event = "sg_nat_04", inYears = 1 }, log = "You flew in at dawn and cleared it by dusk. A city whose name you couldn't pronounce named a street after you." },
				lose = { vitality = { -240, -110 }, sanity = -8, schedule = { event = "sg_nat_04", inYears = 1 }, cause = S_HURT, log = "You held it until their reserves arrived. Then you slept for a week in a foreign hospital." },
			},
			{
				label = "Send your best team, and guard home",
				clash = { stat = "charisma", foe = "A team going without you", coins = 3, base = 14, coinPower = 5 },
				win = { charisma = 4, schedule = { event = "sg_nat_04", inYears = 1 }, log = "They did it without you. You were prouder than if you'd gone." },
				lose = { sanity = -8, schedule = { event = "sg_nat_04", inYears = 1 }, log = "They cleared it, and not all of them came home. You should have gone." },
			},
		},
	}),
	beat({
		id = "sg_nat_04",
		title = "A Weapon or a Person",
		text = "Three governments have made offers (non-canon): citizenship, a residence, a budget the size of a small country's, if you'll sign as a strategic asset and go where they say, when they say. Your own government reminds you, politely, where you were born.",
		when = { flags = { "sgn_on" } },
		choices = {
			{ label = "Sign with your own country", result = { money = { 200, 600 }, setFlags = { "sgn_state" }, schedule = { event = "sg_nat_05", inYears = 2 }, log = "You signed. You have a driver now, and a schedule somebody else writes." } },
			{ label = "Stay independent", result = { willpower = 4, setFlags = { "sgn_free" }, schedule = { event = "sg_nat_05", inYears = 2 }, log = "You told them all that you'd go where the Gates were worst, and nobody could buy the order." } },
			{
				label = "Demand a treaty: S-rank Gates answered wherever they open",
				clash = { stat = "charisma", foe = "Three governments", coins = 3, base = 16, coinPower = 6 },
				win = { charisma = 6, setFlags = { "sgn_treaty" }, schedule = { event = "sg_nat_05", inYears = 2 }, log = "It took a year of meetings. The treaty has your name in its first line." },
				lose = { sanity = -6, schedule = { event = "sg_nat_05", inYears = 2 }, log = "They agreed with everything you said and signed nothing." },
			},
		},
	}),
	beat({
		id = "sg_nat_05",
		title = "The Remnant",
		text = "What's left of the armies that came through in the war has been gathering behind one Gate in the far north (non-canon): leaderless, enormous, and getting ready. The world's top Hunters are going in together. You've been asked to go in first.",
		tags = { "danger" },
		when = { flags = { "sgn_on" }, form = "hunter_s" },
		choices = {
			{
				label = "Go in first",
				clash = { stat = "strength", foe = "The war's last army", enemy = "gate_s", coins = 4, base = 46, coinPower = 12, fight = true, fixed = true },
				win = { strength = 10, willpower = 8, money = { 800, 2400 }, schedule = { event = "sg_nat_06", inYears = 1 }, log = "You broke its front line in the first hour, and the others poured through the gap you made. It was over in three days." },
				lose = { vitality = { -280, -130 }, sanity = -12, schedule = { event = "sg_nat_06", inYears = 1 }, cause = "Killed fighting the war's last remnant (non-canon)", log = "It was over in three days. You don't remember the third." },
			},
			{
				label = "Hold the Gate's mouth so nothing gets out",
				clash = { stat = "vitality", foe = "Everything trying to get out", enemy = "gate_s", coins = 4, base = 40, coinPower = 10, fight = true, fixed = true },
				win = { willpower = 10, charisma = 4, money = { 600, 1800 }, schedule = { event = "sg_nat_06", inYears = 1 }, log = "Nothing got past you for three days. The others did the rest." },
				lose = { vitality = { -260, -120 }, sanity = -10, schedule = { event = "sg_nat_06", inYears = 1 }, cause = "Killed fighting the war's last remnant (non-canon)", log = "Three things got past you. Three, out of all of it." },
			},
		},
	}),
	beat({
		id = "sg_nat_06",
		title = "National Level",
		text = "At the International Guild Conference, the world's Hunter agencies make it official (non-canon): there are new National Level Hunters, and your name is on the list. At the airport afterwards, a kid asks for your autograph, then asks whether you're scared of anything.",
		when = { flags = { "sgn_on" } },
		choices = {
			{ label = "Tell the truth", result = { charisma = 4, sanity = 6, setFlags = { "fate_national_level" }, log = "'Everything,' you said. 'Every time.' The kid thought about it and decided that was all right." } },
			{ label = "Say no", result = { charisma = 2, sanity = 3, setFlags = { "fate_national_level" }, log = "'No,' you said, and signed their notebook. You were lying, and you think they knew." } },
		},
	}),
}
