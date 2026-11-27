--[[
	SAGA: THE HOLLOW DOOR (ORIGINAL GAME CONTENT). A double dungeon of the game's own (NOT the
	Cartenon Temple: no statues, no commandments, nothing that chooses anyone, no System), and
	the cold that seems to have noticed you at the bottom of it.

	On the canon line it stays ambiguous: fear, residual mana, a dream about a door. Nothing
	in the world could know more, so no card says more. Only on the NON-CANON world line, after
	the war, does the cold speak (sg_hol_05), and then it leads into the Monarch paths
	(Saga_Monarch.luau). If the world is rewritten, it simply never finds you (sg_hol_quiet).

	Chain: sg_hol_01 > 02 > 03 > 04; then sg_hol_05 (non-canon line) or sg_hol_quiet
	(rewritten world). Fates: fate_double_survivor (flag dd_survivor), fate_hollow_shut, and
	through sg_hol_05 the Monarch fates.
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

local DD = "Killed in a Double Dungeon"

return {
	{
		id = "sg_hol_01",
		title = "The Second Door",
		text = "A D-rank cave, nearly cleared. Then a torch catches a doorway at the back of the boss room that wasn't on anyone's map: smooth black stone, too regular, too cold. Beyond it a corridor slopes down into a dark the light doesn't reach. The raid leader says the words nobody wants to hear: double dungeon. (The game's own: not the Cartenon Temple, and nothing in here chooses anyone.)",
		weight = 3,
		once = true,
		tags = { "danger", "gate", "strange" },
		when = { chance = 0.4, minAge = 18, maxAge = 45, minYear = 2, maxYear = 11, form = { "hunter_e", "hunter_d", "hunter_c" }, flags = { "licensed" }, notFlags = { "world_rewritten" } },
		choices = {
			{
				label = "Go through with the others",
				hint = "What's down there doesn't read like D-rank.",
				clash = { stat = "agility", foe = "The hall at the bottom", coins = 3, base = 14, coinPower = 5, fixed = true },
				win = { willpower = 4, intelligence = 2, sanity = -12, setFlags = { "dd_survivor", "sgho_on" }, schedule = { event = "sg_hol_02", inYears = 1 }, codex = { "lore_double" }, log = "At the bottom was a hall with no ceiling you could see, and something in it that moved like the dark itself. Five of you came back up. You don't remember how." },
				lose = { vitality = { -50, -24 }, sanity = -14, setFlags = { "dd_survivor", "sgho_on" }, schedule = { event = "sg_hol_02", inYears = 1 }, codex = { "lore_double" }, cause = DD, log = "You came back up. Most of the party didn't." },
			},
			{
				label = "Hold the doorway so the way back stays open",
				clash = { stat = "vitality", foe = "A door that wants to close", coins = 3, base = 12, coinPower = 4, fixed = true },
				win = { willpower = 3, sanity = -8, setFlags = { "dd_survivor", "sgho_on" }, schedule = { event = "sg_hol_02", inYears = 1 }, codex = { "lore_double" }, log = "The black stone tried to close on you for an hour. You didn't let it. Five people ran back through the gap you kept." },
				lose = { vitality = { -40, -18 }, sanity = -10, setFlags = { "dd_survivor", "sgho_on" }, schedule = { event = "sg_hol_02", inYears = 1 }, codex = { "lore_double" }, cause = DD, log = "The door closed. You were on the right side of it, just." },
			},
			{ label = "Turn back now", result = { sanity = -6, codex = { "lore_double" }, log = "You turned back. Behind you, the black door closed on everyone who'd gone through. Three came out two days later, and would not say what they'd seen." } },
		},
	},
	beat({
		id = "sg_hol_02",
		title = "The Debrief",
		text = "The Association's investigators ask the same questions for three days. Officially it was 'a dungeon anomaly'. You answer everything except the one thing you can't explain: at the bottom, in the dark, something cold seemed to turn its attention on you, the way a person notices a moth. And then it let you go. Maybe it was the fear.",
		when = { flags = { "sgho_on" } },
		choices = {
			{ label = "Tell the investigators about it", result = { sanity = 3, setFlags = { "sgho_told" }, schedule = { event = "sg_hol_03", inYears = 1 }, log = "They wrote 'post-traumatic perception' on the form and gave you a counsellor's number. That helped more than you expected." } },
			{ label = "Keep it to yourself", result = { sanity = -3, setFlags = { "sgho_secret" }, schedule = { event = "sg_hol_03", inYears = 1 }, log = "You told them about the hall, and the dark, and the people who didn't come back. You didn't tell them that part." } },
		},
	}),
	beat({
		id = "sg_hol_03",
		title = "Frost in Summer",
		text = "It's August, and some mornings there are frost ferns on the inside of your bedroom window. Only your window. On bad nights you dream of the black door, and of something on the other side of it, waiting with a patience that isn't human.",
		when = { flags = { "sgho_on" } },
		choices = {
			{
				label = "Push it away",
				clash = { stat = "willpower", foe = "The dream", coins = 2, base = 8, coinPower = 4 },
				win = { willpower = 4, setFlags = { "sgho_resist" }, schedule = { event = "sg_hol_04", inYears = 2 }, log = "You learned to wake up, breathe, and put the dream down like a heavy box. The frost came less often." },
				lose = { sanity = -6, setFlags = { "sgho_open" }, schedule = { event = "sg_hol_04", inYears = 2 }, log = "It kept coming back. A part of you started waiting for it." },
			},
			{ label = "Listen to it", result = { sanity = -4, setFlags = { "sgho_open" }, schedule = { event = "sg_hol_04", inYears = 2 }, log = "You lay still and listened. It didn't speak. It only waited." } },
			{ label = "Ask a mana researcher to measure your room", result = { intelligence = 2, setFlags = { "sgho_resist" }, schedule = { event = "sg_hol_04", inYears = 2 }, log = "She found a faint residual mana on you, 'like the cold off a freezer door', from the dungeon. Her explanation was boring and very comforting." } },
		},
	}),
	beat({
		id = "sg_hol_04",
		title = "The Door in the Dream",
		text = "The dream is always the same now: the black door, a little closer every time, and on the other side of it the cold attention, almost a voice. Tonight the door is open a crack.",
		when = { flags = { "sgho_on" } },
		choices = {
			{
				label = "Close it",
				clash = { stat = "willpower", foe = "A door that wants to be open", coins = 2, base = 9, coinPower = 4 },
				win = { willpower = 4, sanity = 6, setFlags = { "fate_hollow_shut" }, clearFlags = { "sgho_open" }, log = "You put your shoulder to it in the dream and shut it. You woke up warm for the first time in years." },
				lose = { sanity = -6, setFlags = { "sgho_open" }, log = "It wouldn't close. You woke up with frost in your hair." },
			},
			{ label = "Leave it open", result = { sanity = -4, setFlags = { "sgho_open" }, log = "You left it open. Nothing came through. Not yet." } },
		},
	}),
	{
		id = "sg_hol_05",
		title = "The Voices Behind the Door",
		text = "This world line kept its Gates, and from here this life is the game's own story (non-canon). After the war, the cold behind the door finally speaks. It isn't one voice. It's several, very far away, each like a king calling for a servant who never came. The ones who wore their crowns are dead. What they were is still looking for somewhere to live, and it has known your name since the black door.",
		weight = 6,
		once = true,
		tags = { "strange" },
		when = { minAge = 18, minYear = 13, flags = { "dd_survivor", "sgho_open", "world_line_kept" }, notFlags = { "sg_kept_arc", "fate_hollow_shut", "world_rewritten" } },
		choices = {
			{ label = "Answer the cold", hint = "(non-canon) A dead Monarch's power, looking for a vessel.", result = { sanity = -4, setFlags = { "sg_kept_arc", "sgm_any", "sgm_sillad_1" }, schedule = { event = "sg_mon_sillad_02", inYears = 1 }, log = "(non-canon) The cold said its name was Sillad, the Frost Monarch, King of the Snow Folk, and that it had been patient for a very long time." } },
			{ label = "Answer the hunger", hint = "(non-canon) A dead Monarch's power, looking for a vessel.", result = { sanity = -4, setFlags = { "sg_kept_arc", "sgm_any", "sgm_rakan_1" }, schedule = { event = "sg_mon_rakan_02", inYears = 1 }, log = "(non-canon) The hunger said its name was Rakan, the Monarch of Fangs, King of Beasts, and that it was tired of waiting." } },
			{ label = "Answer the hum", hint = "(non-canon) A dead Monarch's power, looking for a vessel.", result = { sanity = -4, setFlags = { "sg_kept_arc", "sgm_any", "sgm_querehsha_1" }, schedule = { event = "sg_mon_querehsha_02", inYears = 1 }, log = "(non-canon) The hum said its name was Querehsha, the Monarch of Plagues, Queen of Insects, and that you need never be alone again." } },
			{ label = "Shut every door", result = { willpower = 5, sanity = 4, setFlags = { "sg_kept_arc", "fate_hollow_shut" }, clearFlags = { "sgho_open" }, log = "You refused all of them, out loud, in an empty room. The voices went quiet, and stayed quiet." } },
		},
	},
	{
		id = "sg_hol_quiet",
		title = "Warm Mornings",
		text = "In this world there were never any Gates. You've never been inside one. And yet for years you kept a jumper by the bed in summer, out of a habit you couldn't explain. This morning you notice you haven't needed it for a long time.",
		weight = 6,
		once = true,
		when = { flags = { "dd_survivor", "world_rewritten" }, notFlags = { "fate_hollow_shut" } },
		result = { sanity = 6, setFlags = { "fate_hollow_shut" }, log = "Whatever it was, it never found you here." },
	},
}
