--[[
	SAGA: THE WALL (ORIGINAL GAME CONTENT). A Tanker who holds a standing line in front of an
	industrial zone where Gates keep opening, until the body says no. Tankers as a Hunter class
	and Dungeon Breaks are canon; the line, the zone and every person here are the game's own.

	Opens only for a licensed Tanker (the engine's class flag, class_tanker), C-rank and up.
	Chain: sg_wall_01 > 02 > 03 > 04 > 05 > 06 (retire) or > 07 (one more stand).
	Fates: fate_the_wall; a death on the line (flag sgw_line, cause "...gate line") is the
	Last Stand.
]]

local MID_UP = { "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local LINE = "Killed holding the gate line"

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
		id = "sg_wall_01",
		title = "The Line",
		text = "There's an industrial zone in {district} where Gates keep opening, three or four a year, on the same few streets. The city wants a standing line of Tankers there: shields, armour, and the job of being the thing a Dungeon Break runs into first.",
		weight = 6,
		once = true,
		when = { minAge = 20, maxAge = 40, minYear = 3, form = MID_UP, flags = { "class_tanker", "licensed" }, notFlags = { "world_rewritten" } },
		choices = {
			{ label = "Volunteer for the line", result = { willpower = 2, setFlags = { "sgw_line" }, schedule = { event = "sg_wall_02", inYears = 1 }, log = "You got a locker, a radio and a spot on a map with your name written on it." } },
			{ label = "Someone else's job", result = { log = "You let the line be someone else's." } },
		},
	},
	beat({
		id = "sg_wall_02",
		title = "First Break",
		text = "A C-rank Gate on the line breaks at shift change. Behind you a factory's night shift is still coming out of the gates: two hundred people walking towards the thing you're standing in front of.",
		tags = { "danger" },
		when = { flags = { "sgw_line" }, form = HUNTERS },
		choices = {
			{
				label = "Hold the line",
				clash = { stat = "vitality", foe = "A C-rank Dungeon Break", enemy = "gate_c", coins = 3, base = 13, coinPower = 5, fight = true, fixed = true },
				win = { willpower = 3, strength = 1, schedule = { event = "sg_wall_03", inYears = 1 }, log = "You held for eleven minutes. The night shift got out. Your shield arm didn't work properly for a week." },
				lose = { vitality = { -44, -20 }, sanity = -4, schedule = { event = "sg_wall_03", inYears = 1 }, cause = LINE, log = "The line bent around you. It didn't break, quite." },
			},
			{
				label = "Fall back and funnel them into one street",
				clash = { stat = "intelligence", foe = "A break with three ways out", coins = 2, base = 10, coinPower = 4, fixed = true },
				win = { intelligence = 2, schedule = { event = "sg_wall_03", inYears = 1 }, log = "You gave ground on purpose and made it come to you down one narrow street. The assault team said it was the cleanest containment they'd seen." },
				lose = { vitality = { -30, -12 }, schedule = { event = "sg_wall_03", inYears = 1 }, cause = LINE, log = "It didn't take the street you gave it." },
			},
		},
	}),
	beat({
		id = "sg_wall_03",
		title = "The Rookie with the Shield",
		text = "A D-rank Tanker of twenty has been hanging around the line's locker room for weeks. 'Teach me to stand like you,' they say. They're too light, too fast, and too brave.",
		when = { flags = { "sgw_line" } },
		choices = {
			{ label = "Teach them", result = { charisma = 2, setFlags = { "sgw_student" }, addRelation = { kind = "friend", bond = 60, age = { 19, 22 } }, schedule = { event = "sg_wall_04", inYears = 1 }, log = "You taught them the first rule of the line: you don't hold it alone." } },
			{ label = "Tell them to find another life", result = { sanity = -1, schedule = { event = "sg_wall_04", inYears = 1 }, log = "They came back the next week anyway. You still said no." } },
		},
	}),
	beat({
		id = "sg_wall_04",
		title = "The Body Keeps Count",
		text = "The line's Healer looks at your spine on the scan for a long time. 'Mana heals the breaks,' she says. 'It doesn't heal the bending. Ten more years of this and you'll walk with a cane. Maybe five.'",
		when = { flags = { "sgw_line" } },
		choices = {
			{ label = "Keep holding", result = { willpower = 3, vitality = -8, setFlags = { "sgw_stubborn" }, schedule = { event = "sg_wall_05", inYears = 1 }, cause = "Worn out holding the gate line", log = "You thanked her and went back on shift. She wrote something on your file you weren't meant to see." } },
			{ label = "Cut back to half shifts", result = { sanity = 3, money = -3, schedule = { event = "sg_wall_05", inYears = 1 }, log = "Half shifts. You hated every hour you weren't there." } },
			{
				label = "Pay for the best Healers in the country",
				hint = "30 {currency}.",
				requires = { min = { money = 30 } },
				result = { money = -30, vitality = { 15, 30 }, schedule = { event = "sg_wall_05", inYears = 1 }, log = "Three A-rank Healers, six sessions. You stood up straight for the first time in years." },
			},
		},
	}),
	beat({
		id = "sg_wall_05",
		title = "The Big One",
		text = "An A-rank Gate breaks inside the zone at noon. The assault teams are twenty minutes out. Between the break and a hospital full of patients who can't be moved, there's the line, and you are the middle of it.",
		tags = { "danger" },
		when = { flags = { "sgw_line" }, form = HUNTERS },
		choices = {
			{
				label = "Hold for twenty minutes",
				hint = "A-rank monsters.",
				clash = { stat = "vitality", foe = "An A-rank Dungeon Break", enemy = "gate_a", coins = 4, base = 28, coinPower = 8, fight = true, fixed = true },
				win = { willpower = 5, charisma = 3, setFlags = { "sgw_held" }, schedule = { event = "sg_wall_06", inYears = 1 }, log = "Twenty-two minutes. When the assault teams arrived the street was wrecked, and the hospital didn't have a broken window." },
				lose = { vitality = { -130, -60 }, sanity = -6, setFlags = { "sgw_held" }, schedule = { event = "sg_wall_06", inYears = 1 }, cause = LINE, log = "You held until you couldn't stand, and then a little longer. The hospital stood." },
			},
			{
				label = "Hold it with your student beside you",
				requires = { flags = { "sgw_student" } },
				clash = { stat = "vitality", foe = "An A-rank Dungeon Break", enemy = "gate_a", coins = 3, base = 22, coinPower = 7, fight = true, fixed = true },
				win = { willpower = 4, charisma = 4, setFlags = { "sgw_held" }, schedule = { event = "sg_wall_06", inYears = 1 }, log = "Two shields, one line. Your student never once stepped back, and neither did you." },
				lose = { vitality = { -90, -40 }, sanity = -6, setFlags = { "sgw_held" }, schedule = { event = "sg_wall_06", inYears = 1 }, cause = LINE, log = "You took the hit meant for them. You'd do it again." },
			},
			{
				label = "Hold the hospital doors instead",
				clash = { stat = "willpower", foe = "Whatever gets past the street", coins = 3, base = 12, coinPower = 4, fixed = true },
				win = { willpower = 4, schedule = { event = "sg_wall_06", inYears = 1 }, log = "Three things got past the street. None of them got past you." },
				lose = { vitality = { -60, -24 }, schedule = { event = "sg_wall_06", inYears = 1 }, cause = LINE, log = "One of them got past you. The hospital's own guards finished it." },
			},
		},
	}),
	beat({
		id = "sg_wall_06",
		title = "Honours",
		text = "The city gives you a medal, and the line's commander gives you a choice: retire with full honours and a pension, or another five years. 'Nobody would blame you,' she says. 'Nobody's held it longer.'",
		when = { flags = { "sgw_line" } },
		choices = {
			{ label = "Retire", result = { sanity = 8, setFlags = { "fate_the_wall" }, log = "You hung your shield in the locker room. The rookies touch it for luck on the way out." } },
			{
				label = "Hand the line to your student",
				requires = { flags = { "sgw_student" } },
				result = { sanity = 8, charisma = 2, setFlags = { "fate_the_wall" }, log = "You gave your student your radio and your spot on the map. They held it the next week, and the week after." },
			},
			{ label = "Five more years", result = { willpower = 2, setFlags = { "sgw_stubborn" }, schedule = { event = "sg_wall_07", inYears = 2 }, log = "The commander didn't argue. She'd known what you'd say." } },
		},
	}),
	beat({
		id = "sg_wall_07",
		title = "The Last Stand",
		text = "Your knees went last winter, and you held the line anyway. Today a B-rank break comes down the zone's main street, and you can feel your body deciding, separately from you, that it's done.",
		tags = { "danger" },
		when = { flags = { "sgw_line" }, form = HUNTERS },
		choices = {
			{
				label = "Hold anyway",
				clash = { stat = "vitality", foe = "A B-rank Dungeon Break", enemy = "gate_b", coins = 3, base = 20, coinPower = 6, fight = true, fixed = true },
				win = { willpower = 4, setFlags = { "fate_the_wall" }, log = "You held it. Afterwards you sat down on the kerb and couldn't get up, and you knew. You retired that week, a legend on a cane." },
				lose = { vitality = { -120, -60 }, setFlags = { "fate_the_wall" }, cause = "Fell holding the gate line", log = "You held until you couldn't. Then the young ones held it for you." },
			},
			{ label = "Step back, and let the ones you trained hold it", result = { sanity = 4, setFlags = { "fate_the_wall" }, log = "You stepped back. Three Tankers you'd trained held it without you. That had been the whole point, all along." } },
		},
	}),
}
