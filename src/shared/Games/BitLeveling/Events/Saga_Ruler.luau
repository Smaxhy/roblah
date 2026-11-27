--[[
	SAGA: A RULER'S VESSEL (NON-CANON). Every card here says so in its text. Only on the world
	line where the Gates were kept (flag world_line_kept), after the war, for a B-rank or above.

	Canon: the Rulers are beings of light, enemies of the Monarchs, who act through human
	hosts, and they were seen in the war. This arc's light, its plans and its cost are the
	game's own; no canon vessel or character appears, and nothing secret is revealed.

	Chain: sg_rul_01 > 02 > 03 > 04 > 05 > 06. Fate: fate_ruler_vessel.
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

local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local BURN = "Burned out hosting a Ruler (non-canon)"

return {
	{
		id = "sg_rul_01",
		title = "A Light That Speaks",
		text = "This world line kept its Gates (non-canon). In the war you saw lights in the sky that fought the things coming through. One of them has found you: a glow in your kitchen at three in the morning, warm and very old, speaking without a mouth. The Monarchs' remnants aren't finished, it says. It needs a body here to fight them with, and it's asking to borrow yours.",
		weight = 4,
		once = true,
		tags = { "strange" },
		when = { minAge = 20, minYear = 13, form = { "hunter_b", "hunter_a", "hunter_s" }, flags = { "world_line_kept", "licensed" }, notFlags = { "sg_kept_arc", "world_rewritten" } },
		choices = {
			{ label = "Lend it your body", hint = "(non-canon) A Ruler's vessel. It will cost something.", result = { strength = 4, sanity = -2, setFlags = { "sg_kept_arc", "sgru_on" }, schedule = { event = "sg_rul_02", inYears = 1 }, codex = { "lore_rulers" }, log = "(non-canon) You said yes. The light came into you like sunlight into water. You've never been so strong, or so crowded." } },
			{ label = "Ask what it will cost first", hint = "(non-canon)", result = { intelligence = 2, setFlags = { "sg_kept_arc", "sgru_on", "sgru_warned" }, schedule = { event = "sg_rul_02", inYears = 1 }, codex = { "lore_rulers" }, log = "(non-canon) It told you the truth: a human body was never built to carry it. You said yes anyway." } },
			{ label = "Refuse", result = { log = "It went out like a candle, without complaint. For years you wondered whether it found someone else." } },
		},
	},
	beat({
		id = "sg_rul_02",
		title = "Two in One Body",
		text = "There are hours you don't remember now (non-canon). You wake up on rooftops. Your hands know sword forms you never learned. The light is polite about it, in its way. It doesn't understand why you mind.",
		when = { flags = { "sgru_on" } },
		choices = {
			{ label = "Let it lead in a fight", result = { strength = 10, sanity = -6, setFlags = { "sgru_lead" }, schedule = { event = "sg_rul_03", inYears = 1 }, log = "(non-canon) You let it drive. You come back to yourself with the fight already over, and it always is." } },
			{
				label = "Set rules: you decide where it goes",
				clash = { stat = "willpower", foe = "Something much older than you", coins = 3, base = 16, coinPower = 5 },
				win = { willpower = 6, setFlags = { "sgru_partner" }, schedule = { event = "sg_rul_03", inYears = 1 }, log = "(non-canon) It agreed to your rules, and then, to its own surprise, it kept them." },
				lose = { sanity = -8, setFlags = { "sgru_lead" }, schedule = { event = "sg_rul_03", inYears = 1 }, log = "(non-canon) It agreed, and forgot, and agreed again." },
			},
			{
				label = "Ask it to wake your own mana further",
				hint = "(non-canon) B- and A-ranks only. A second awakening.",
				requires = { form = { "hunter_b", "hunter_a" } },
				result = { form = "hunter_s", sanity = -4, setFlags = { "sgru_awakened" }, schedule = { event = "sg_rul_03", inYears = 1 }, log = "(non-canon) It reached into your mana and turned something over. The Association's reader said S. The technician read it three times." },
			},
		},
	}),
	beat({
		id = "sg_rul_03",
		title = "The Remnants",
		text = "A remnant of the Monarchs' armies is massing behind a Gate on a coast (non-canon), and the light is restless. 'Now,' it says. 'With me.'",
		tags = { "danger" },
		when = { flags = { "sgru_on" }, form = HUNTERS },
		choices = {
			{
				label = "Fight with the light",
				clash = { stat = "strength", foe = "A Monarch's remnant army", enemy = "gate_s", coins = 4, base = 38, coinPower = 10, fight = true, fixed = true },
				win = { strength = 6, willpower = 4, schedule = { event = "sg_rul_04", inYears = 1 }, log = "(non-canon) You fought as one thing, and the remnant broke against you like a wave against a sea wall." },
				lose = { vitality = { -200, -90 }, sanity = -8, schedule = { event = "sg_rul_04", inYears = 1 }, cause = "Killed fighting the Monarchs' remnants (non-canon)", log = "(non-canon) The remnant broke, and so, for a while, did you." },
			},
			{ label = "Let the light fight alone, and watch", result = { strength = 4, sanity = -8, schedule = { event = "sg_rul_04", inYears = 1 }, log = "(non-canon) You watched your own body do things you couldn't. It won. It didn't feel like you had." } },
		},
	}),
	beat({
		id = "sg_rul_04",
		title = "What the Light Doesn't Count",
		text = "The light has a plan (non-canon): collapse a Gate on the remnant while it's still inside, and take a town of four thousand people with it. 'They will be gone either way,' it says, with total calm. 'This way, it ends.'",
		when = { flags = { "sgru_on" } },
		choices = {
			{
				label = "Refuse, and evacuate the town first",
				clash = { stat = "charisma", foe = "A town that won't believe you", coins = 3, base = 14, coinPower = 5 },
				win = { charisma = 4, willpower = 4, setFlags = { "sgru_humane" }, schedule = { event = "sg_rul_05", inYears = 1 }, log = "(non-canon) You got four thousand people out in nine hours. The light waited, puzzled, and then collapsed the Gate on an empty town." },
				lose = { sanity = -10, setFlags = { "sgru_humane" }, schedule = { event = "sg_rul_05", inYears = 1 }, log = "(non-canon) You got most of them out. Not all. The light didn't understand why you couldn't stop shaking." },
			},
			{
				label = "Overrule it, whatever it costs you",
				clash = { stat = "willpower", foe = "A will older than the Earth", coins = 3, base = 18, coinPower = 6 },
				win = { willpower = 8, setFlags = { "sgru_humane" }, schedule = { event = "sg_rul_05", inYears = 1 }, log = "(non-canon) You held it still inside you until it gave up the plan. It was the first time it had ever been told no." },
				lose = { vitality = { -60, -30 }, sanity = -8, setFlags = { "sgru_humane" }, schedule = { event = "sg_rul_05", inYears = 1 }, cause = BURN, log = "(non-canon) Fighting it from the inside burned you. You held on anyway, and the town was evacuated while you held." },
			},
			{ label = "Let it", result = { sanity = -20, setFlags = { "sgru_cold" }, schedule = { event = "sg_rul_05", inYears = 1 }, log = "(non-canon) You let it. The remnant was gone, and so was the town. The buses had got most people out, and you've spent every day since thinking about the word 'most'." } },
		},
	}),
	beat({
		id = "sg_rul_05",
		title = "The Burn",
		text = "Your body is failing in a way no Healer can name (non-canon): too hot, all the time, as if something is slowly burning you from the inside. The light admits what it is. A human body was never built to carry it. It has known that all along.",
		when = { flags = { "sgru_on" } },
		choices = {
			{ label = "Keep carrying it", result = { vitality = { -60, -30 }, setFlags = { "sgru_burn" }, schedule = { event = "sg_rul_06", inYears = 1 }, cause = BURN, log = "(non-canon) You kept carrying it. You started sleeping in a cold bath." } },
			{ label = "Ask it to leave after one last fight", result = { sanity = 2, schedule = { event = "sg_rul_06", inYears = 1 }, log = "(non-canon) It agreed. It sounded, for the first time, almost sorry." } },
			{ label = "Ask it to leave now", result = { vitality = 20, sanity = -4, setFlags = { "sgru_left" }, log = "(non-canon) It left. The world was colder and smaller, and yours. Somewhere the fight against the remnants went on without you." } },
		},
	}),
	beat({
		id = "sg_rul_06",
		title = "The Last Fight",
		text = "The last of the remnant's generals is coming through a Gate over the sea (non-canon): a thing the war's survivors still have nightmares about. The light is ready. So are you, as much as anyone could be.",
		tags = { "danger" },
		when = { flags = { "sgru_on" }, form = HUNTERS },
		choices = {
			{
				label = "Fight together, as one",
				clash = { stat = "strength", foe = "The remnant's last general", enemy = "gate_s", coins = 4, base = 42, coinPower = 11, fight = true, fixed = true },
				win = { willpower = 10, sanity = 10, setFlags = { "fate_ruler_vessel" }, log = "(non-canon) It fell into the sea. The light left you gently, the way a guest leaves a house, and said a word you think meant thank you." },
				lose = { vitality = { -260, -120 }, sanity = -10, setFlags = { "fate_ruler_vessel" }, cause = BURN, log = "(non-canon) The general fell, and the light was torn out of you as it went. You woke up a week later in a hospital, very human, very tired." },
			},
			{
				label = "Hold the general, and let the light finish it",
				clash = { stat = "vitality", foe = "The remnant's last general", enemy = "gate_s", coins = 4, base = 36, coinPower = 10, fight = true, fixed = true },
				win = { willpower = 8, sanity = 8, setFlags = { "fate_ruler_vessel" }, log = "(non-canon) You held it still for four seconds. That was all the light needed. Afterwards it left you, and you missed it more than you expected." },
				lose = { vitality = { -220, -100 }, sanity = -8, setFlags = { "fate_ruler_vessel" }, cause = BURN, log = "(non-canon) You held it, and the light finished it, and then left a body that had given everything it had." },
			},
		},
	}),
}
