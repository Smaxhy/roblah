--[[
	SAGA: THE WEAPON PASSED ON (ORIGINAL GAME CONTENT). A Hunter whose child awakens: the
	training, the first raid (as an adult: the card says they're old enough for a licence),
	the Gate the parent takes instead, and the weapon handed over. Roblox rule: the child is
	never shown hurt; every danger in this arc falls on the parent.

	Chain: sg_leg_01 > 02 > 03 > 04 > 05 > 06. Fate: fate_legacy.
]]

local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
-- every weapon the game has (Gear.luau builds them; read here so this never names a stale id)
local WEAPONS = {}
do
	local ok, list = pcall(function()
		return require(script.Parent.Parent:WaitForChild("Gear"))
	end)
	if ok and type(list) == "table" then
		for _, g in list do
			if type(g) == "table" and g.slot == "weapon" and type(g.id) == "string" then
				table.insert(WEAPONS, g.id)
			end
		end
	end
end

local function beat(e)
	e.weight = 0
	e.once = true
	local w = e.when or {}
	w.minAge = w.minAge or 18
	w.hasRelation = w.hasRelation or "child"
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
		id = "sg_leg_01",
		title = "The Reading",
		text = "Your child calls from the Association branch, half laughing, half shaking. They've awakened. The technician is still staring at the reader. They want you to come down right now, and you're already putting your coat on.",
		weight = 4,
		once = true,
		when = { minAge = 50, minYear = 4, form = HUNTERS, flags = { "licensed" }, hasRelation = "child", notFlags = { "world_rewritten" } },
		choices = {
			{ label = "Go down to the branch", result = { sanity = 2, setFlags = { "sgl_on" }, relationBond = { kind = "child", amount = 6 }, schedule = { event = "sg_leg_02", inYears = 1 }, log = "The reader said they were a Hunter. Your child looked at you as if you'd know what to do. You did, mostly." } },
			{ label = "Ask them to wait before they register", result = { setFlags = { "sgl_on", "sgl_wait" }, schedule = { event = "sg_leg_02", inYears = 1 }, log = "You asked them to wait a little before they registered. They agreed, with an expression you remember wearing yourself." } },
		},
	},
	beat({
		id = "sg_leg_02",
		title = "Fear Is a Muscle",
		text = "They want to train, and they want you to train them. You remember everything you got wrong, and every Hunter you knew who isn't here any more.",
		when = { flags = { "sgl_on" } },
		choices = {
			{ label = "Teach them caution first", result = { willpower = 2, setFlags = { "sgl_caution" }, schedule = { event = "sg_leg_03", inYears = 4 }, log = "Rule one: running is a plan. Rule two: nobody is braver than the Gate. You made them say both every morning." } },
			{ label = "Teach them to hit hard", result = { strength = 2, setFlags = { "sgl_strong" }, schedule = { event = "sg_leg_03", inYears = 4 }, log = "You taught them everything your arms know. They're faster than you were. You didn't tell them that." } },
			{ label = "Send them to the Association's academy", result = { money = -5, setFlags = { "sgl_academy" }, schedule = { event = "sg_leg_03", inYears = 4 }, log = "The academy taught them procedures. You taught them the rest at dinner." } },
		},
	}),
	beat({
		id = "sg_leg_03",
		title = "Their First Raid",
		text = "They're old enough for a licence now, and their first raid is on Saturday: an E-rank Gate, a public party, a raid leader you've never heard of. You are not invited. You've checked.",
		when = { flags = { "sgl_on" } },
		choices = {
			{ label = "Wait at the tape", result = { sanity = -2, relationBond = { kind = "child", amount = 6 }, schedule = { event = "sg_leg_04", inYears = 2 }, log = "You waited at the tape for four hours. They came out dusty and grinning and pretended to be annoyed to see you." } },
			{
				label = "Trust them, and go to work",
				clash = { stat = "willpower", foe = "Your phone", coins = 2, base = 6, coinPower = 3 },
				win = { willpower = 3, schedule = { event = "sg_leg_04", inYears = 2 }, log = "You didn't check your phone once. Twice. Eleven times. They texted a photo of a crystal at six: 'first one'." },
				lose = { sanity = -4, schedule = { event = "sg_leg_04", inYears = 2 }, log = "You checked your phone so often your own raid leader took it off you. They came home fine, with a crystal." },
			},
			{ label = "Sign on to the same raid as a porter", result = { sanity = 2, relationBond = { kind = "child", amount = -4 }, schedule = { event = "sg_leg_04", inYears = 2 }, log = "They saw you at the briefing and didn't speak to you for a week. You'd do it again." } },
		},
	}),
	beat({
		id = "sg_leg_04",
		title = "The Gate Instead",
		text = "Your child's party has been offered a raid a rank above them: good money, real danger. They're going to say yes; you can hear it in their voice. You could take it yourself, with your old party, before they ever sign.",
		tags = { "danger" },
		when = { flags = { "sgl_on" } },
		choices = {
			{
				label = "Take it yourself",
				hint = "A C-rank Gate.",
				requires = { form = HUNTERS },
				clash = { stat = "strength", foe = "A C-rank Gate", enemy = "gate_c", coins = 3, base = 13, coinPower = 5, fight = true, fixed = true },
				win = { strength = 2, money = { 10, 30 }, setFlags = { "sgl_took" }, schedule = { event = "sg_leg_05", inYears = 2 }, log = "You cleared it on Thursday. On Friday they found out, and were furious, and hugged you." },
				lose = { vitality = { -44, -20 }, sanity = -4, setFlags = { "sgl_took" }, schedule = { event = "sg_leg_05", inYears = 2 }, cause = "Killed on a raid taken in their child's place", log = "You cleared it, slowly, and limped home. They were furious, and they sat by your bed all night." },
			},
			{
				label = "Talk it through with them, and let them choose",
				clash = { stat = "charisma", foe = "A young Hunter who wants to prove something", coins = 2, base = 6, coinPower = 3 },
				win = { charisma = 2, schedule = { event = "sg_leg_05", inYears = 2 }, log = "They chose to wait a year. It was their choice, and that mattered more than the waiting." },
				lose = { sanity = -4, schedule = { event = "sg_leg_05", inYears = 2 }, log = "They went. They came back fine. You aged a year that weekend." },
			},
		},
	}),
	beat({
		id = "sg_leg_05",
		title = "The Weapon",
		text = "You're slower than you were. They aren't. The thing you've carried into every Gate for twenty years is lying on the table between you.",
		when = { flags = { "sgl_on" } },
		choices = {
			{
				label = "Give them your weapon",
				requires = if #WEAPONS > 0 then { hasGear = WEAPONS } else nil,
				result = { loseGear = "weapon", sanity = 6, relationBond = { kind = "child", amount = 12 }, setFlags = { "fate_legacy" }, schedule = { event = "sg_leg_06", inYears = 4 }, log = "You put it in their hands and told them its history, every nick in it. They listened as if it were the most important thing anyone had ever told them." },
			},
			{
				label = "Have one made for them",
				hint = "15 {currency}.",
				requires = { min = { money = 15 } },
				result = { money = -15, sanity = 4, relationBond = { kind = "child", amount = 8 }, setFlags = { "fate_legacy" }, schedule = { event = "sg_leg_06", inYears = 4 }, log = "A smith who works Gate iron made them one to match yours. They hung it on the wall for a week before they could bring themselves to use it." },
			},
			{ label = "Give them your notebooks instead", result = { intelligence = 1, sanity = 4, relationBond = { kind = "child", amount = 8 }, setFlags = { "fate_legacy" }, schedule = { event = "sg_leg_06", inYears = 4 }, log = "Twenty years of raid notes: every Gate, every mistake, every monster's habits. They said it was better than any weapon. You think they meant it." } },
		},
	}),
	beat({
		id = "sg_leg_06",
		title = "The Name Goes On",
		text = "Your child's raid party is on the evening news: a C-rank break contained in a market, nobody hurt. For half a second the camera catches what they carry on their back. You watch the clip nine times.",
		when = { flags = { "fate_legacy" } },
		result = { sanity = 8, log = "You called them. They said, 'I did it the way you taught me.' You said you knew." },
	}),
}
