--[[
	SAGA: CAME OUT OF THE RED (ORIGINAL GAME CONTENT). A Red Gate on a training raid; the
	people who didn't come out; the cold that follows you home; and, years later, a second one.
	Red Gates are canon (they turn red once the raid is inside, nobody gets in or out until the
	boss dies, the reading taken before entry is wrong); this raid, its snow and every person
	here are the game's own. This is not canon's Red Gate and nobody from it is here.

	Chain: sg_red_01 > 02 > 03 > 04 > 05 (red again, still raiding) or 05q (at the tape, retired)
	> 06. Fates: fate_red_survivor, fate_red_twice; a death in one reads "Lost inside a Red
	Gate" (fate_lost_red).
]]

local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local LOST = "Lost inside a Red Gate"

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

local TO_05 = { { event = "sg_red_05", inYears = 2 }, { event = "sg_red_05q", inYears = 2 } }

return {
	{
		id = "sg_red_01",
		title = "The Gate Turns Red",
		text = "A training raid: a C-rank reading, a guild's rookies, a few veterans to keep them alive. Ten minutes in, the light behind you goes red, and the Gate you came through isn't there any more. Nobody outside can come in. Nobody inside can leave until the boss is dead. It's snowing.",
		weight = 3,
		once = true,
		tags = { "danger", "gate", "strange" },
		when = { chance = 0.4, minAge = 18, maxAge = 40, minYear = 3, form = { "hunter_d", "hunter_c", "hunter_b" }, flags = { "licensed" }, notFlags = { "world_rewritten" } },
		choices = {
			{
				label = "Push for the boss",
				hint = "The only way out is through it. The reading was wrong: this is B-rank at least.",
				clash = { stat = "strength", foe = "What a Red Gate hides", enemy = "gate_b", coins = 3, base = 20, coinPower = 6, fight = true, fixed = true },
				win = { strength = 3, willpower = 3, sanity = -8, setFlags = { "sgred_out" }, schedule = { event = "sg_red_02", inYears = 1 }, codex = { "lore_red" }, log = "You were there when the boss fell. The red went out of the sky and the way out opened. Fewer of you walked through it than had come in." },
				lose = { vitality = { -80, -36 }, sanity = -10, setFlags = { "sgred_out" }, schedule = { event = "sg_red_02", inYears = 1 }, codex = { "lore_red" }, cause = LOST, log = "You didn't reach the boss. Someone else did, while you lay in the snow." },
			},
			{
				label = "Keep the rookies alive",
				hint = "A cave, a fire, a watch rota. Wait for the strikers.",
				clash = { stat = "willpower", foe = "The cold and the dark", coins = 3, base = 12, coinPower = 4, fixed = true },
				win = { willpower = 4, charisma = 2, sanity = -6, setFlags = { "sgred_out" }, schedule = { event = "sg_red_02", inYears = 1 }, codex = { "lore_red" }, log = "You kept a fire going and eight rookies talking. When the way out opened, all eight walked through it." },
				lose = { vitality = { -60, -24 }, sanity = -10, setFlags = { "sgred_out" }, schedule = { event = "sg_red_02", inYears = 1 }, codex = { "lore_red" }, cause = LOST, log = "The cold found a way into the cave. Not everyone you were keeping walked out." },
			},
			{
				label = "Search for another way out",
				hint = "There isn't one. Everyone knows there isn't one.",
				clash = { stat = "luck", foe = "A Red Gate's walls", coins = 2, base = 10, coinPower = 4, fixed = true },
				win = { sanity = -8, setFlags = { "sgred_out" }, schedule = { event = "sg_red_02", inYears = 1 }, codex = { "lore_red" }, log = "There was no other way out. But the search kept you away from where the worst of it happened." },
				lose = { vitality = { -60, -24 }, sanity = -10, setFlags = { "sgred_out" }, schedule = { event = "sg_red_02", inYears = 1 }, codex = { "lore_red" }, cause = LOST, log = "You wandered too far from the others, and the snow covered your tracks." },
			},
		},
	},
	beat({
		id = "sg_red_02",
		title = "The Ones Who Didn't Come Out",
		text = "The guild holds a memorial for the raiders who didn't come out, and the families want to talk to the ones who did. A mother asks you, very quietly, whether her son was afraid.",
		when = { flags = { "sgred_out" } },
		choices = {
			{ label = "Tell her the truth", result = { willpower = 3, sanity = -6, setFlags = { "fate_red_survivor" }, schedule = { event = "sg_red_03", inYears = 1 }, log = "You told her he was afraid and he was brave, and that in there those weren't different things. She held your hand for a long time." } },
			{ label = "Tell her he wasn't", result = { charisma = 1, sanity = -4, setFlags = { "fate_red_survivor" }, schedule = { event = "sg_red_03", inYears = 1 }, log = "You told her he wasn't afraid. She knew you were being kind, and she was grateful anyway." } },
			{ label = "Don't go to the memorial", result = { sanity = -8, setFlags = { "fate_red_survivor", "sgred_avoid" }, schedule = { event = "sg_red_03", inYears = 1 }, log = "You sat in your car outside the hall for an hour and then drove home." } },
		},
	}),
	beat({
		id = "sg_red_03",
		title = "The Cold",
		text = "The frozen aisle at the supermarket. A winter morning. An open freezer at a friend's house. Anything cold, and you're back in the snow with the sky gone red. Your guild has noticed you flinch.",
		when = { flags = { "sgred_out" } },
		choices = {
			{ label = "See the Association's counsellor", result = { sanity = 8, setFlags = { "sgred_help" }, schedule = { event = "sg_red_04", inYears = 1 }, log = "She'd seen two other people from Red Gates. 'You're not broken,' she said. 'You're cold. There's a difference, and it's treatable.'" } },
			{ label = "Train through it", result = { willpower = 3, sanity = -4, schedule = { event = "sg_red_04", inYears = 1 }, log = "You took every winter Gate going until the cold was just cold again. Mostly." } },
			{ label = "Stop raiding", result = { quitCareer = true, sanity = 4, setFlags = { "sgred_quit" }, schedule = { event = "sg_red_04", inYears = 1 }, log = "You handed your raid gear back. It felt like failing and like breathing at the same time." } },
		},
	}),
	beat({
		id = "sg_red_04",
		title = "Thursdays",
		text = "There's a group that meets on Thursday nights in a community hall: people who came out of Red Gates. Not many, in the whole country. A man who was in one abroad, years ago. A Healer. A porter who was nineteen when it happened.",
		when = { flags = { "sgred_out" } },
		choices = {
			{ label = "Go on Thursdays", result = { sanity = 6, charisma = 1, setFlags = { "sgred_group" }, schedule = TO_05, log = "Nobody asks what it was like. Everybody knows. It's the only room where you don't have to explain." } },
			{ label = "Help run it", result = { charisma = 3, sanity = 4, setFlags = { "sgred_group" }, schedule = TO_05, log = "You make the barley tea and stack the chairs. People started coming because you were there." } },
			{ label = "Not for you", result = { sanity = -2, schedule = TO_05, log = "You kept it to yourself. That's a way of carrying it, too." } },
		},
	}),
	beat({
		id = "sg_red_05",
		title = "Red Again",
		text = "A routine raid. Your team, your rank, a Gate like a dozen you've cleared. Behind you, the light goes red. The rookie next to you hasn't understood yet. You have.",
		tags = { "danger", "gate", "strange" },
		when = { flags = { "sgred_out" }, form = HUNTERS, notFlags = { "sgred_quit" } },
		choices = {
			{
				label = "Lead them to the boss",
				hint = "You know what this is now. That's worth something.",
				clash = { stat = "strength", foe = "A second Red Gate", enemy = "gate_b", coins = 3, base = 22, coinPower = 6, fight = true, fixed = true },
				win = { strength = 3, willpower = 5, sanity = -6, setFlags = { "fate_red_twice" }, schedule = { event = "sg_red_06", inYears = 1 }, log = "The second time, you knew what to do, and you did it before anyone else had finished being afraid. Everyone walked out." },
				lose = { vitality = { -100, -44 }, sanity = -10, schedule = { event = "sg_red_06", inYears = 1 }, cause = LOST, log = "Knowing what it was didn't make it smaller." },
			},
			{
				label = "Keep them calm and keep them warm",
				clash = { stat = "willpower", foe = "The cold, again", coins = 3, base = 12, coinPower = 4, fixed = true },
				win = { willpower = 5, charisma = 3, sanity = -4, setFlags = { "fate_red_twice" }, schedule = { event = "sg_red_06", inYears = 1 }, log = "You lit a fire before anyone asked and told the rookies exactly what would happen, because you knew. They believed you. They all walked out." },
				lose = { vitality = { -60, -24 }, sanity = -12, schedule = { event = "sg_red_06", inYears = 1 }, cause = LOST, log = "The cold came for you first this time. The rookies kept you warm, in the end." },
			},
			{
				label = "Let the steadiest rookie lead, and guard the back",
				clash = { stat = "agility", foe = "Whatever follows a raid in the snow", coins = 3, base = 14, coinPower = 5, fight = true, fixed = true },
				win = { agility = 3, willpower = 3, setFlags = { "fate_red_twice" }, schedule = { event = "sg_red_06", inYears = 1 }, log = "You watched the dark behind them for two days. Nothing reached them. They'll never know how much of that was you." },
				lose = { vitality = { -60, -24 }, sanity = -10, schedule = { event = "sg_red_06", inYears = 1 }, cause = LOST, log = "Something reached the back of the line, where you were." },
			},
		},
	}),
	beat({
		id = "sg_red_05q",
		title = "At the Tape",
		text = "A Gate in your city turned red this morning with a rookie team inside. The families are at the tape, and someone from the guild has found your name and asked if you'll come and stand with them while they wait.",
		when = { flags = { "sgred_out", "sgred_quit" } },
		choices = {
			{ label = "Stand with them", result = { willpower = 3, sanity = -4, schedule = { event = "sg_red_06", inYears = 1 }, log = "You stood with them for nine hours and told them the only true thing you know: it can be survived. At dusk the red went out of the Gate, and seven people walked out of it." } },
			{ label = "You can't", result = { sanity = -6, schedule = { event = "sg_red_06", inYears = 1 }, log = "You watched the news with the sound off until it was over. Seven came out. You cried, and you don't know for whom." } },
		},
	}),
	beat({
		id = "sg_red_06",
		title = "The Other Part",
		text = "The Association's training school asks if you'll talk to its rookies about Red Gates. 'Not the procedures,' the instructor says. 'They have the procedures. The other part.'",
		when = { flags = { "fate_red_survivor" } },
		choices = {
			{ label = "Talk to them", result = { charisma = 3, sanity = 4, log = "You told them about the snow, and the fire, and the mother at the memorial. Nobody looked at their phone." } },
			{ label = "Decline", result = { sanity = 1, log = "You said you weren't ready. The instructor said the offer stayed open, and it has." } },
		},
	}),
}
