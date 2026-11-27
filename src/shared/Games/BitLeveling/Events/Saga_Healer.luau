--[[
	SAGA: THE HEALER'S OATH (ORIGINAL GAME CONTENT). A Healer who works a public Gate-injury
	ward for nothing, through a guild's money, an illness of the game's own ("Gate fever":
	NOT canon, and not the canon's Eternal Sleep), and the day there's mana for ten people
	and forty in the hall. Healers as a Hunter class are canon; everything else is the game's.

	Opens only for a licensed Healer (the engine's class flag, class_healer).
	Chain: sg_heal_01 > 02 > 03 > 04 > 05 > 06 > 07. Fate: fate_healer_legend.
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

return {
	{
		id = "sg_heal_01",
		title = "Sundays",
		text = "An old C-rank Healer runs the Gate-injury ward at a public hospital in {district} on her days off, for nothing. She watched you work at a raid. 'Hunter Healers cost more than most people earn in a year,' she says. 'So people go home with injuries we could fix in ten minutes. Come on Sundays.'",
		weight = 6,
		once = true,
		when = { minAge = 18, maxAge = 40, minYear = 2, form = HUNTERS, flags = { "class_healer", "licensed" }, notFlags = { "world_rewritten" } },
		choices = {
			{ label = "Come on Sundays", result = { charisma = 2, setFlags = { "sgh_on" }, schedule = { event = "sg_heal_02", inYears = 1 }, log = "You took the oath she makes everyone take. It's one sentence long: 'Nobody gets turned away for money.'" } },
			{ label = "Your mana is your living", result = { money = 3, log = "You told her you couldn't afford to. She said she'd heard that before, and that the ward would still be there." } },
		},
	},
	beat({
		id = "sg_heal_02",
		title = "Night Shift",
		text = "A Dungeon Break in the outer districts. By midnight there are forty people on the ward and two Healers. Your mana is nearly gone, and the next patient is a construction worker whose leg will never work properly again if nobody heals it tonight.",
		when = { flags = { "sgh_on" }, form = HUNTERS },
		choices = {
			{
				label = "Keep going past empty",
				clash = { stat = "willpower", foe = "An empty well of mana", coins = 2, base = 7, coinPower = 3 },
				win = { willpower = 3, charisma = 2, schedule = { event = "sg_heal_03", inYears = 1 }, log = "You healed him at four in the morning and slept on the floor of the supply room. He walked out on Tuesday." },
				lose = { vitality = { -24, -10 }, sanity = -4, schedule = { event = "sg_heal_03", inYears = 1 }, cause = "Collapsed from mana exhaustion on a hospital ward", log = "You fainted halfway through. The old Healer finished it, and then sat with you until you woke up." },
			},
			{ label = "Rest an hour, then try", result = { sanity = 1, intelligence = 1, schedule = { event = "sg_heal_03", inYears = 1 }, log = "An hour's sleep, then the leg. It took longer than it should have. It worked." } },
		},
	}),
	beat({
		id = "sg_heal_03",
		title = "The Contract",
		text = "A major guild wants an exclusive Healer for its strike teams. The money is more than you've earned in your life put together. The contract says 'exclusive'. It says it four times.",
		when = { flags = { "sgh_on" } },
		choices = {
			{ label = "Sign", result = { money = { 40, 90 }, sanity = -2, setFlags = { "sgh_guild" }, schedule = { event = "sg_heal_04", inYears = 1 }, log = "You signed. You still go on Sundays, quietly. Nobody at the guild has noticed yet." } },
			{ label = "Refuse, and stay with the ward", result = { willpower = 2, setFlags = { "sgh_ward" }, schedule = { event = "sg_heal_04", inYears = 1 }, log = "You turned it down. The old Healer pretended not to be pleased." } },
			{
				label = "Make them fund the ward",
				clash = { stat = "charisma", foe = "A guild's accountants", coins = 2, base = 9, coinPower = 4 },
				win = { money = { 20, 40 }, setFlags = { "sgh_funded" }, schedule = { event = "sg_heal_04", inYears = 1 }, log = "Exclusive on weekdays. Their money pays for a second Healer on the ward, and their logo is on the ward's door. You can live with that." },
				lose = { setFlags = { "sgh_ward" }, schedule = { event = "sg_heal_04", inYears = 1 }, log = "They laughed. You stayed with the ward." },
			},
		},
	}),
	beat({
		id = "sg_heal_04",
		title = "Gate Fever",
		text = "People living near Gates that broke years ago are falling ill: fevers that don't break, a tiredness that doesn't lift, a faint blue light at the back of the eyes. The papers call it Gate fever. (The game's own illness, not canon.) Healers can slow it. Nobody can cure it. The ward is full.",
		tags = { "danger" },
		when = { flags = { "sgh_on" } },
		choices = {
			{
				label = "Work the quarantine ward",
				clash = { stat = "vitality", foe = "Gate fever", coins = 2, base = 8, coinPower = 4 },
				win = { willpower = 3, setFlags = { "sgh_front" }, schedule = { event = "sg_heal_05", inYears = 1 }, log = "Twelve-hour shifts behind plastic sheeting. You never caught it. You started to think you might be the only one who wouldn't." },
				lose = { vitality = { -40, -18 }, sanity = -4, setFlags = { "sgh_front" }, schedule = { event = "sg_heal_05", inYears = 1 }, cause = "Died of Gate fever caught on the ward", log = "You caught it. You worked through it anyway, slower." },
			},
			{
				label = "Organise the city's Healers into shifts",
				clash = { stat = "charisma", foe = "Healers who charge by the hour", coins = 2, base = 8, coinPower = 3 },
				win = { charisma = 3, setFlags = { "sgh_network" }, schedule = { event = "sg_heal_05", inYears = 1 }, log = "Sixty Healers, a shared rota, and a group chat that never sleeps." },
				lose = { sanity = -3, setFlags = { "sgh_front" }, schedule = { event = "sg_heal_05", inYears = 1 }, log = "Half of them said yes. It was something." },
			},
			{
				label = "Find out what's causing it",
				clash = { stat = "intelligence", foe = "An illness nobody understands", coins = 2, base = 9, coinPower = 4 },
				win = { intelligence = 3, setFlags = { "sgh_lead" }, schedule = { event = "sg_heal_05", inYears = 1 }, log = "You marked every case on a map. Every one of them lived within a kilometre of an old crystal mine, abandoned after a break." },
				lose = { sanity = -2, setFlags = { "sgh_front" }, schedule = { event = "sg_heal_05", inYears = 1 }, log = "No pattern you could see. You went back to the ward." },
			},
		},
	}),
	beat({
		id = "sg_heal_05",
		title = "Ten Out of Forty",
		text = "Used carefully, your mana can hold back the fever in ten people today. There are forty in the hall: a guild's A-rank Hunter, whose guild will pay the ward anything; a bus driver; a nurse who caught it from her patients; a grandmother who keeps telling you to see the others first.",
		tags = { "danger" },
		when = { flags = { "sgh_on" } },
		choices = {
			{ label = "The sickest first", result = { willpower = 3, sanity = -6, schedule = { event = "sg_heal_06", inYears = 1 }, log = "You went bed by bed from the worst. You don't remember most of the faces. You remember the ones you didn't reach." } },
			{ label = "The ones you can surely save", result = { intelligence = 2, sanity = -6, schedule = { event = "sg_heal_06", inYears = 1 }, log = "You chose the ten you were sure of. It was the right answer, and it felt like the wrong one for years." } },
			{
				label = "Everyone, a little, whatever it costs you",
				clash = { stat = "vitality", foe = "Forty people and one Healer", coins = 3, base = 10, coinPower = 3 },
				win = { willpower = 5, charisma = 3, schedule = { event = "sg_heal_06", inYears = 1 }, log = "You stretched it across all forty. It shouldn't have worked. For one day, it did." },
				lose = { vitality = { -60, -25 }, sanity = -4, schedule = { event = "sg_heal_06", inYears = 1 }, cause = "Burned out their mana healing a ward", log = "You got to thirty-one before your legs went. The others held on until morning, and so did you." },
			},
			{ label = "Heal the A-rank first, and make the guild pay for five more Healers", result = { charisma = 1, sanity = -2, setFlags = { "sgh_network" }, schedule = { event = "sg_heal_06", inYears = 1 }, log = "You sent his guild an invoice that made their accountant call you. Five Healers arrived by evening." } },
		},
	}),
	beat({
		id = "sg_heal_06",
		title = "The Fever Breaks",
		text = "The Association has finally listened: old mines near broken Gates are leaking mana dust, and they're being sealed. New cases are falling. Your name is in the report, more often than you'd like.",
		when = { flags = { "sgh_on" } },
		choices = {
			{ label = "Train the next Healers", result = { charisma = 3, setFlags = { "sgh_teacher" }, schedule = { event = "sg_heal_07", inYears = 2 }, log = "You started a class on Saturdays, so that there would be more people for Sundays." } },
			{ label = "Go back to Sundays", result = { sanity = 4, schedule = { event = "sg_heal_07", inYears = 2 }, log = "You slept for most of a week. Then you went back to the ward." } },
		},
	}),
	beat({
		id = "sg_heal_07",
		title = "The Healer's Oath",
		text = "There are wards like the old Healer's in six cities now, and every Healer on them took the same one-sentence oath. A medical school wants to name its new building after you. The old Healer, long retired, sends you a note: 'Told you. Sundays.'",
		when = { flags = { "sgh_on" } },
		choices = {
			{ label = "Accept the honour", result = { charisma = 3, sanity = 6, setFlags = { "fate_healer_legend" }, log = "Your name went up on a building. You still work Sundays." } },
			{ label = "Ask them to name it after her", result = { willpower = 3, sanity = 8, setFlags = { "fate_healer_legend" }, log = "They named it after her. She called you to complain about it, and then she cried." } },
		},
	}),
}
