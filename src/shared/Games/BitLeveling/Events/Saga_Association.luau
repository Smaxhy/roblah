--[[
	SAGA: THE ASSOCIATION (ORIGINAL GAME CONTENT). From a seat in a measurement van to the
	Surveillance Team or a Branch Director's desk, by way of a ring that under-reads Gates,
	sells their raid rights cheap and smuggles unsealed crystals out of them. The Association,
	its measurement teams, raid-right sales and Surveillance Team are canon; the ring, the
	branch and every person here are this game's own. No canon character is involved.

	Chain: sg_assoc_01 > 02 > 03 > 04 > 05f (field) or 05d (desk) > 06w (won) or 06l (lost)
	> 07. Then, on the non-canon world line only, sg_assoc_08 (the chairman's chair).
	Fates: fate_branch_director, fate_surveillance_legend, fate_assoc_chairman (non-canon).
]]

local MID_UP = { "hunter_c", "hunter_b", "hunter_a", "hunter_s" }

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

local TO_05 = { { event = "sg_assoc_05f", inYears = 1 }, { event = "sg_assoc_05d", inYears = 1 } }

return {
	{
		id = "sg_assoc_01",
		title = "The Measurement Team",
		text = "The Hunter Association is hiring for its Gate measurement teams: the people who drive the van to every new Gate, point the instruments at it and decide what rank it is. Every raid right in the city is sold on their number.",
		weight = 3,
		once = true,
		when = { minAge = 20, maxAge = 35, minYear = 2, min = { intelligence = 35 }, notFlags = { "sg_career_arc", "world_rewritten" } },
		choices = {
			{
				label = "Apply",
				hint = "You'd leave the work you do now.",
				result = { career = "assoc_staff", careerRank = 2, setFlags = { "sg_career_arc", "sga_on" }, schedule = { event = "sg_assoc_02", inYears = 1 }, codex = { "lore_rights" }, log = "You passed the exam and got a jacket with the Association's patch on it, a handheld reader and a seat in the van." },
			},
			{ label = "Not for you", result = { log = "You let someone else decide what rank the Gates are." } },
		},
	},
	beat({
		id = "sg_assoc_02",
		title = "A Number on a Form",
		text = "Your reader says B. You've measured two hundred Gates, and this one feels like A. Your supervisor looks at the screen, then at the guild truck already parked outside the tape, and says: 'Sign it as B.'",
		when = { flags = { "sga_on" } },
		choices = {
			{ label = "Sign it as read", result = { money = 2, sanity = -3, setFlags = { "sga_quiet" }, schedule = { event = "sg_assoc_03", inYears = 1 }, log = "You signed. The guild cleared it, barely, with two people in hospital. You told yourself the reader said B." } },
			{
				label = "Measure it again, properly",
				clash = { stat = "intelligence", foe = "A Gate that hides its rank", coins = 2, base = 8, coinPower = 3 },
				win = { intelligence = 2, setFlags = { "sga_honest" }, schedule = { event = "sg_assoc_03", inYears = 1 }, log = "Second reading, longer exposure: A. The guild truck left. An A-rank team came that evening and needed all of it." },
				lose = { sanity = -2, setFlags = { "sga_quiet" }, schedule = { event = "sg_assoc_03", inYears = 1 }, log = "The second reading said B too. You stopped trusting your gut, a little." },
			},
			{ label = "Refuse to sign, in writing", result = { willpower = 2, setFlags = { "sga_honest" }, schedule = { event = "sg_assoc_03", inYears = 1 }, log = "You refused, in writing. Your supervisor was moved to another branch a month later. Nobody said why." } },
		},
	}),
	beat({
		id = "sg_assoc_03",
		title = "The Pattern",
		text = "Going through old forms on a slow night, you notice something. The same branch, the same three small guilds: Gates under-read again and again, raid rights sold cheap. And from those raids, porters who stopped turning up for work. Not dead, the records say. Just gone.",
		when = { flags = { "sga_on" } },
		choices = {
			{
				label = "Take it to the Surveillance Team, and join it",
				hint = "Hunters only, C-rank and up. The team that polices Hunter crime.",
				requires = { form = MID_UP, flags = { "licensed" } },
				result = { career = "assoc_surveillance", setFlags = { "sga_field" }, schedule = { event = "sg_assoc_04", inYears = 1 }, codex = { "lore_kha" }, log = "You took your file to the Surveillance Team. They read it twice, then gave you a badge." },
			},
			{ label = "Build the case yourself, from the archive", result = { intelligence = 2, setFlags = { "sga_desk" }, schedule = { event = "sg_assoc_04", inYears = 1 }, log = "You started staying late. The archive is very quiet at night." } },
			{ label = "It isn't your job", result = { sanity = -2, setFlags = { "sga_dropped" }, log = "You closed the file. You think about the porters sometimes." } },
		},
	}),
	beat({
		id = "sg_assoc_04",
		title = "The Porter Who Came Back",
		text = "One of the missing porters is alive: an E-rank, hiding at a cousin's place in another city. He'll talk, if someone can promise him that the people he worked for won't find him. They made porters carry crystals out of Gates the Association never measured, he says, and the ones who asked questions were never hired again. Or seen.",
		when = { flags = { "sga_on" } },
		choices = {
			{
				label = "Promise him protection, and mean it",
				clash = { stat = "charisma", foe = "A frightened man", coins = 2, base = 7, coinPower = 3 },
				win = { charisma = 2, setFlags = { "sga_witness" }, schedule = TO_05, log = "He talked for six hours. You wrote until your hand cramped." },
				lose = { sanity = -3, schedule = TO_05, log = "He didn't believe you. He was gone by morning, but he'd left a list of names on the table." },
			},
			{
				label = "Pay for him to disappear somewhere safe",
				hint = "10 {currency}, out of your own pocket.",
				requires = { min = { money = 10 } },
				result = { money = -10, setFlags = { "sga_witness" }, schedule = TO_05, log = "A flat in a town with no Gates on record, a new phone, and a statement, signed." },
			},
			{
				label = "Lean on him",
				clash = { stat = "willpower", foe = "A man with nothing left to lose", coins = 2, base = 7, coinPower = 3 },
				win = { sanity = -3, setFlags = { "sga_witness" }, schedule = TO_05, log = "He talked. He also never looked at you again." },
				lose = { sanity = -2, schedule = TO_05, log = "He shut down completely. You had to do it the slow way." },
			},
		},
	}),
	beat({
		id = "sg_assoc_05f",
		title = "The Warehouse",
		text = "The trail ends at a cold-storage warehouse by the port: crates of mana crystals with no Association seal, and four Hunters guarding them who are not going to come quietly. Your team leader gives the word.",
		tags = { "danger" },
		when = { flags = { "sga_on", "sga_field" } },
		choices = {
			{
				label = "Go in first",
				hint = "B-rank rogues.",
				clash = { stat = "strength", foe = "The ring's guards", enemy = "rogue_hunter", coins = 3, base = 20, coinPower = 6, fight = true, fixed = true },
				win = { strength = 3, willpower = 2, promote = true, setFlags = { "sga_broken" }, schedule = { event = "sg_assoc_06w", inYears = 1 }, log = "Four arrests, six hundred unsealed crystals, and a ledger with names in it. Some of the names were very important." },
				lose = { vitality = { -80, -36 }, sanity = -4, setFlags = { "sga_escaped" }, schedule = { event = "sg_assoc_06l", inYears = 1 }, cause = "Killed raiding a black-market crystal warehouse", log = "They broke out through the loading bay. Two got away, with the ledger." },
			},
			{
				label = "Cut the power and the exits first",
				clash = { stat = "intelligence", foe = "A warehouse with too many doors", coins = 3, base = 14, coinPower = 4, fixed = true },
				win = { intelligence = 3, promote = true, setFlags = { "sga_broken" }, schedule = { event = "sg_assoc_06w", inYears = 1 }, log = "They came out of the dark one by one into a ring of flashlights. Nobody on your team got a scratch." },
				lose = { vitality = { -40, -16 }, setFlags = { "sga_escaped" }, schedule = { event = "sg_assoc_06l", inYears = 1 }, cause = "Killed raiding a black-market crystal warehouse", log = "You missed a door. They found it." },
			},
		},
	}),
	beat({
		id = "sg_assoc_05d",
		title = "The Ledger",
		text = "The money goes through a crystal broker, then a construction firm, then into the accounts of someone in your own branch's management. You can see the whole shape of it now. So, you suspect, can they.",
		when = { flags = { "sga_on", "sga_desk" } },
		choices = {
			{
				label = "Take it over their heads, to head office",
				clash = { stat = "intelligence", foe = "A file that keeps getting lost", coins = 2, base = 9, coinPower = 4 },
				win = { intelligence = 3, promote = true, setFlags = { "sga_broken" }, schedule = { event = "sg_assoc_06w", inYears = 1 }, log = "Head office read it on a Friday. On Monday the Surveillance Team was in your branch with boxes." },
				lose = { sanity = -4, setFlags = { "sga_escaped" }, schedule = { event = "sg_assoc_06l", inYears = 1 }, log = "Head office passed it back down to your branch for review. To them." },
			},
			{
				label = "Give it to a reporter",
				clash = { stat = "charisma", foe = "A newsroom that's heard it all", coins = 2, base = 8, coinPower = 3 },
				win = { charisma = 2, setFlags = { "sga_broken", "sga_leaked" }, schedule = { event = "sg_assoc_06w", inYears = 1 }, log = "It ran on the front page. The Association had to act, and it did, loudly." },
				lose = { sanity = -3, setFlags = { "sga_escaped" }, schedule = { event = "sg_assoc_06l", inYears = 1 }, log = "The reporter's editor killed the story. Someone at the branch heard about it." },
			},
		},
	}),
	beat({
		id = "sg_assoc_06w",
		title = "The Hearing",
		text = "The ring is broken: eleven licences revoked, a branch manager in custody, a guild officer facing charges. The hearing wants your testimony in public. Their lawyers will be there. So will the cameras.",
		when = { flags = { "sga_on", "sga_broken" } },
		choices = {
			{
				label = "Testify in public",
				clash = { stat = "charisma", foe = "Three very good lawyers", coins = 2, base = 8, coinPower = 3 },
				win = { charisma = 3, sanity = 3, promote = true, setFlags = { "sga_hero" }, schedule = { event = "sg_assoc_07", inYears = 1 }, log = "You answered every question twice, slowly. By the end the lawyers had stopped asking." },
				lose = { sanity = -5, schedule = { event = "sg_assoc_07", inYears = 1 }, log = "They took you apart for three hours. The verdict went your way anyway." },
			},
			{ label = "Testify from behind a screen", result = { sanity = 2, schedule = { event = "sg_assoc_07", inYears = 1 }, log = "Nobody saw your face. Everyone heard what you said." } },
		},
	}),
	beat({
		id = "sg_assoc_06l",
		title = "A Note on the Pillow",
		text = "Someone has been inside your apartment. Nothing is missing. On your pillow there's a note with your family's address on it, and nothing else.",
		tags = { "danger" },
		when = { flags = { "sga_on" } },
		choices = {
			{
				label = "Keep digging",
				clash = { stat = "intelligence", foe = "People who know where you sleep", coins = 3, base = 12, coinPower = 4 },
				win = { intelligence = 3, willpower = 3, setFlags = { "sga_broken" }, schedule = { event = "sg_assoc_06w", inYears = 1 }, log = "You found the last account. The Surveillance Team made the arrests the same night." },
				lose = { vitality = { -30, -12 }, sanity = -8, schedule = { event = "sg_assoc_07", inYears = 1 }, cause = "Killed by the crime ring they were investigating", log = "They came back, and this time you were home. A neighbour heard and called it in. The ring scattered before it could be caught." },
			},
			{ label = "Ask for protection and keep going", result = { sanity = -4, setFlags = { "sga_broken" }, schedule = { event = "sg_assoc_06w", inYears = 1 }, log = "The Surveillance Team put an agent in your stairwell for a year. The case went slower, and it went." } },
			{ label = "Let it go", result = { sanity = -8, setFlags = { "sga_dropped" }, log = "You transferred to a branch in another city. The ring went on without you." } },
		},
	}),
	beat({
		id = "sg_assoc_07",
		title = "The Branch",
		text = "The director of your branch is retiring, and the name going up the list is yours. It's a desk: budgets, measurement rotas, raid-right sales, and the final signature on every reading in the district. Or there's the field, where the rogues still are.",
		when = { flags = { "sga_on" } },
		choices = {
			{ label = "Take the director's chair", result = { career = "assoc_staff", careerRank = 5, intelligence = 2, setFlags = { "fate_branch_director" }, log = "Your name went on the door of the branch in {district}. The first thing you did was make every reading need two signatures." } },
			{
				label = "Stay in the field",
				hint = "Hunters only, C-rank and up.",
				requires = { form = MID_UP, flags = { "licensed" } },
				result = { career = "assoc_surveillance", careerRank = 4, willpower = 2, setFlags = { "fate_surveillance_legend" }, log = "You turned down the chair. The rogue Hunters of {district} learned your name instead." },
			},
		},
	}),
	{
		id = "sg_assoc_08",
		title = "The Chairman's Chair",
		text = "This world line kept its Gates (non-canon). Years after the war the Association is still rebuilding, and its chairman is stepping down. The board wants someone who has measured Gates, broken a ring and run a branch. They want you.",
		weight = 4,
		once = true,
		when = { minAge = 40, minYear = 14, flags = { "fate_branch_director", "world_line_kept" }, notFlags = { "world_rewritten" } },
		choices = {
			{ label = "Accept", hint = "(non-canon)", result = { charisma = 3, intelligence = 3, sanity = -2, setFlags = { "fate_assoc_chairman" }, log = "You became chairman of an Association that had buried more Hunters than it could count. You kept the two-signature rule, and added a few of your own." } },
			{ label = "Decline", result = { sanity = 3, log = "You recommended someone younger and went back to your branch." } },
		},
	},
}
