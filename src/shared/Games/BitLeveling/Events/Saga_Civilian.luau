--[[
	SAGAS OF PEOPLE WITHOUT A RANK (ORIGINAL GAME CONTENT). Four arcs for lives that fight the
	Gate world with something other than mana:
		THE STORY THEY BURIED   a reporter (or a witness) and a guild's cover-up   sg_rep_*
		THE SHELTER KEEPER      basements, doors and a radio net                   sg_shel_*
		CRYSTAL TYCOON          a van at the tape, then a refinery, then more      sg_tyc_*
		THE EARLY WARNING       a box that hums before a Gate opens                sg_res_*
	Mana crystals, raid rights, measurement and the Association are canon; every guild,
	person, shelter and invention here is the game's own. A life runs one of these at most.
	Fates: fate_reporter_truth, fate_shelter_founder, fate_tycoon, fate_detector, and
	fate_civilian_hero (set by the reporter's and the shelter keeper's endings).
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

return {
	-- ── THE STORY THEY BURIED ───────────────────────────────────────────
	{
		id = "sg_rep_01",
		title = "The Tip",
		text = "An anonymous email to your work account: 'Ask why the Gate behind the old market in {district} was measured three days late. Ask who owned the raid rights. Ask how many people were in the building when it broke.'",
		weight = 5,
		once = true,
		when = { minAge = 22, maxAge = 55, minYear = 3, career = "reporter", notFlags = { "sg_civ_arc", "world_rewritten" } },
		choices = {
			{ label = "Start asking", result = { setFlags = { "sg_civ_arc", "sgrep_on" }, schedule = { event = "sg_rep_02", inYears = 1 }, log = "You opened a new file. On the first page you wrote: who owned the rights?" } },
			{ label = "Pass it to the news desk and forget it", result = { log = "The news desk forgot it too." } },
		},
	},
	{
		id = "sg_rep_01b",
		title = "What You Saw",
		text = "You were there the week the Gate behind the old market in {district} broke. You saw a guild truck parked at the tape for two days before it did, and nobody go in. The official report says the Gate was found the morning it broke.",
		weight = 3,
		once = true,
		when = { minAge = 20, maxAge = 55, minYear = 3, form = "human", min = { charisma = 30 }, notFlags = { "sg_civ_arc", "world_rewritten" } },
		choices = {
			{ label = "Write it down and take it to a newspaper", result = { setFlags = { "sg_civ_arc", "sgrep_on" }, schedule = { event = "sg_rep_02", inYears = 1 }, log = "An editor at a small paper read your notes twice and said, 'Keep going. We'll print it if it holds.'" } },
			{ label = "Let it go", result = { log = "Everyone saw something that week." } },
		},
	},
	beat({
		id = "sg_rep_02",
		title = "The Records",
		text = "Measurement records are public, in theory. In practice the branch clerk tells you the file you want is 'being digitised', and will be for some time. The guild that held the raid rights has a very good lawyer and a very new tower.",
		when = { flags = { "sgrep_on" } },
		choices = {
			{
				label = "Find someone at the branch who'll talk",
				clash = { stat = "charisma", foe = "People who want to keep their jobs", coins = 2, base = 7, coinPower = 3 },
				win = { charisma = 2, setFlags = { "sgrep_records" }, schedule = { event = "sg_rep_03", inYears = 1 }, log = "A technician who'd measured it met you in a car park. She'd read it on day one, and been told to file it on day three." },
				lose = { sanity = -2, schedule = { event = "sg_rep_03", inYears = 1 }, log = "Nobody would talk. You kept going without them." },
			},
			{ label = "File a formal request and wait", result = { intelligence = 1, setFlags = { "sgrep_records" }, schedule = { event = "sg_rep_03", inYears = 2 }, log = "It took eleven months. The file arrived with half its pages blacked out, and the half that wasn't was enough." } },
			{
				label = "Go through the guild's own filings",
				clash = { stat = "intelligence", foe = "Four hundred pages of filings", coins = 2, base = 7, coinPower = 3 },
				win = { intelligence = 2, setFlags = { "sgrep_records" }, schedule = { event = "sg_rep_03", inYears = 1 }, log = "On page three hundred and twelve: the guild had a second, bigger Gate booked the same week. It had made the market Gate wait." },
				lose = { sanity = -2, schedule = { event = "sg_rep_03", inYears = 1 }, log = "Four hundred pages of nothing. Probably on purpose." },
			},
		},
	}),
	beat({
		id = "sg_rep_03",
		title = "A Visit",
		text = "A man from the guild's legal department visits your office with a box of pastries and an envelope. 'A consulting fee,' he says. 'For your expertise. We'd simply ask that you consult with us before publishing anything inaccurate.'",
		when = { flags = { "sgrep_on" } },
		choices = {
			{ label = "Take the envelope", result = { money = { 15, 40 }, sanity = -8, setFlags = { "sgrep_sold" }, log = "You took it. The file went in a drawer. You don't read the news about that guild any more." } },
			{ label = "Refuse", result = { willpower = 2, schedule = { event = "sg_rep_04", inYears = 1 }, log = "You gave him back the envelope. You kept the pastries. They were very good pastries." } },
			{
				label = "Refuse, with your phone recording",
				clash = { stat = "charisma", foe = "A careful lawyer", coins = 2, base = 8, coinPower = 3 },
				win = { charisma = 2, setFlags = { "sgrep_tape" }, schedule = { event = "sg_rep_04", inYears = 1 }, log = "He said far more than a lawyer should. You have all of it." },
				lose = { sanity = -2, schedule = { event = "sg_rep_04", inYears = 1 }, log = "He noticed the phone and said nothing at all." },
			},
		},
	}),
	beat({
		id = "sg_rep_04",
		title = "The Families",
		text = "Nine people died when the Gate behind the market broke. Their families were told it was nobody's fault, by people who seemed very sure. Now you're on their doorsteps, asking them to go through it again.",
		when = { flags = { "sgrep_on" } },
		choices = {
			{
				label = "Listen, for as long as they want to talk",
				clash = { stat = "willpower", foe = "Nine families' grief", coins = 2, base = 6, coinPower = 3 },
				win = { charisma = 2, sanity = -4, setFlags = { "sgrep_families" }, schedule = { event = "sg_rep_05", inYears = 1 }, log = "You sat in nine living rooms and drank a great deal of barley tea. They gave you photographs. They gave you permission." },
				lose = { sanity = -8, schedule = { event = "sg_rep_05", inYears = 1 }, log = "Some of them shut the door. You don't blame them." },
			},
			{ label = "Only the ones who reach out to you", result = { sanity = -2, schedule = { event = "sg_rep_05", inYears = 1 }, log = "Two of them called. It was enough to know you were right." } },
		},
	}),
	beat({
		id = "sg_rep_05",
		title = "Publish",
		text = "It's ready. The editor has read it three times and keeps saying 'the lawyers' in a small voice. The guild has already announced it will sue anyone who repeats 'false claims'.",
		when = { flags = { "sgrep_on" } },
		choices = {
			{
				label = "Publish everything",
				clash = { stat = "charisma", foe = "A guild's legal department", coins = 2, base = 9, coinPower = 4 },
				win = { charisma = 3, setFlags = { "sgrep_out" }, schedule = { event = "sg_rep_06", inYears = 1 }, log = "It went out at six in the morning. By noon it was on every channel." },
				lose = { money = -15, sanity = -6, setFlags = { "sgrep_out" }, schedule = { event = "sg_rep_06", inYears = 1 }, log = "The guild sued. The story stayed up." },
			},
			{
				label = "Publish it with the families' names on it",
				requires = { flags = { "sgrep_families" } },
				result = { charisma = 2, setFlags = { "sgrep_out" }, schedule = { event = "sg_rep_06", inYears = 1 }, log = "Nine names, nine photographs. Nobody could call it a rumour after that." },
			},
			{ label = "Put it online yourself, and let it spread", hint = "Slower. Nobody can kill a story that's everywhere.", result = { charisma = 1, sanity = -3, setFlags = { "sgrep_out" }, schedule = { event = "sg_rep_06", inYears = 2 }, log = "You posted all of it, documents and all, on a Tuesday night. By the weekend it was everywhere, and the guild's lawyers didn't know whom to sue." } },
			{ label = "Sit on it", result = { sanity = -10, setFlags = { "sgrep_sold" }, log = "You told yourself you'd publish it when it was safer. It has never been safer." } },
		},
	}),
	beat({
		id = "sg_rep_06",
		title = "The Inquiry",
		text = "The Association opens a public inquiry into how the Gate behind the market was measured. The guild's raid rights are suspended. A law is drafted: every Gate reading, published within the hour. People have started calling it by your name.",
		when = { flags = { "sgrep_on", "sgrep_out" } },
		result = { charisma = 3, sanity = 8, setFlags = { "fate_reporter_truth", "fate_civilian_hero" }, log = "The families sent you a photograph of the nine, together, from before. You keep it on your desk." },
	}),

	-- ── THE SHELTER KEEPER ──────────────────────────────────────────────
	{
		id = "sg_shel_01",
		title = "The Basement",
		text = "A break in the next street last night. Forty people spent it in your building's old basement: families, the old man from the noodle shop, a delivery rider who ran in off the road. All forty walked out in the morning. On the way upstairs you wonder why every block doesn't have a room like that.",
		weight = 4,
		once = true,
		when = { minAge = 21, maxAge = 60, minYear = 3, form = "human", notFlags = { "sg_civ_arc", "world_rewritten" } },
		choices = {
			{ label = "Start fixing the basement up", result = { money = -5, setFlags = { "sg_civ_arc", "sgs_on" }, schedule = { event = "sg_shel_02", inYears = 1 }, log = "A steel door, water, blankets, a radio, and a list of everyone on the block with a phone number. It took three months of weekends." } },
			{ label = "Write to the district office", result = { intelligence = 1, log = "They wrote back to say that your concerns had been noted." } },
		},
	},
	beat({
		id = "sg_shel_02",
		title = "Whose Job Is It?",
		text = "The district office says shelters are the Association's business. The Association says they're the district's. Meanwhile your basement is the only one in four streets, and three other buildings have asked you how you did it.",
		when = { flags = { "sgs_on" } },
		choices = {
			{
				label = "Make the district office pay for it",
				clash = { stat = "charisma", foe = "A district budget meeting", coins = 2, base = 8, coinPower = 3 },
				win = { charisma = 2, money = 5, setFlags = { "sgs_funded" }, schedule = { event = "sg_shel_03", inYears = 1 }, log = "You brought forty signatures and the old man from the noodle shop, who shouted. They found a budget." },
				lose = { sanity = -3, schedule = { event = "sg_shel_03", inYears = 1 }, log = "Nothing. You'd do it yourselves, then." },
			},
			{ label = "Do it yourselves", result = { money = -8, strength = 1, schedule = { event = "sg_shel_03", inYears = 1 }, log = "Your neighbours brought tools. Three more basements by winter." } },
		},
	}),
	beat({
		id = "sg_shel_03",
		title = "The Night It Mattered",
		text = "The sirens go at two in the morning: a B-rank break, three streets away and coming this way. Your phone is lighting up with people from four blocks heading for your shelters. Someone has to stand at the door and get them in before it's sealed.",
		tags = { "danger" },
		when = { flags = { "sgs_on" } },
		choices = {
			{
				label = "Stand at the door",
				clash = { stat = "willpower", foe = "A break three streets away", coins = 2, base = 8, coinPower = 4, fixed = true },
				win = { willpower = 4, charisma = 2, setFlags = { "sgs_held" }, schedule = { event = "sg_shel_04", inYears = 1 }, log = "You counted them in: two hundred and six. You sealed the door at 2:41. Everyone you counted walked out in the morning." },
				lose = { vitality = { -40, -15 }, sanity = -6, setFlags = { "sgs_held" }, schedule = { event = "sg_shel_04", inYears = 1 }, cause = "Killed keeping a shelter door open in a Dungeon Break", log = "Something reached the street before the last of them reached the door. You got them in. You got hurt doing it." },
			},
			{
				label = "Run the radio and send people to the nearest shelter",
				clash = { stat = "intelligence", foe = "Four blocks of panic", coins = 2, base = 7, coinPower = 3, fixed = true },
				win = { intelligence = 3, setFlags = { "sgs_held" }, schedule = { event = "sg_shel_04", inYears = 1 }, log = "You sent every caller to a door that was open. Not one shelter was over capacity." },
				lose = { sanity = -4, schedule = { event = "sg_shel_04", inYears = 1 }, log = "The radio net jammed for ten minutes at the worst time. You'll never stop thinking about those ten minutes." },
			},
		},
	}),
	beat({
		id = "sg_shel_04",
		title = "The Logo",
		text = "After the night of the break, everyone wants to help. A big guild offers to pay for twenty shelters across the city. They'd like their logo on every door, and the shelters called by their name.",
		when = { flags = { "sgs_on" } },
		choices = {
			{ label = "Take the money", result = { money = 10, sanity = -1, setFlags = { "sgs_network" }, schedule = { event = "sg_shel_05", inYears = 1 }, log = "Twenty doors with a guild's logo on them. Twenty basements that weren't there before." } },
			{
				label = "Raise it from the neighbourhoods instead",
				clash = { stat = "charisma", foe = "A city that's tired of asking", coins = 2, base = 9, coinPower = 3 },
				win = { charisma = 3, setFlags = { "sgs_network" }, schedule = { event = "sg_shel_05", inYears = 1 }, log = "Bake sales, street concerts and a lot of very small donations. Twenty-three shelters, nobody's logo on any of them." },
				lose = { sanity = -3, setFlags = { "sgs_network" }, schedule = { event = "sg_shel_05", inYears = 1 }, log = "Eight shelters, not twenty. Eight more than before." },
			},
		},
	}),
	beat({
		id = "sg_shel_05",
		title = "The Network",
		text = "There are shelters in a dozen districts now, run by volunteers who've never met. When the next big break comes they'll need to talk to each other: who's full, who has a Healer, which streets are clear.",
		when = { flags = { "sgs_on" } },
		choices = {
			{
				label = "Build a radio network",
				clash = { stat = "intelligence", foe = "Forty different radios", coins = 2, base = 8, coinPower = 3 },
				win = { intelligence = 3, setFlags = { "sgs_radio" }, schedule = { event = "sg_shel_06", inYears = 1 }, log = "One channel, one map, a call sign for every door." },
				lose = { sanity = -2, setFlags = { "sgs_radio" }, schedule = { event = "sg_shel_06", inYears = 1 }, log = "It took twice as long as you'd hoped. It worked in the end." },
			},
			{ label = "Train a warden for every shelter", result = { charisma = 2, willpower = 2, setFlags = { "sgs_radio" }, schedule = { event = "sg_shel_06", inYears = 1 }, log = "Every Saturday for a year, a different hall, the same lesson: count them in, seal the door, keep them calm." } },
		},
	}),
	beat({
		id = "sg_shel_06",
		title = "The Shelter Keeper",
		text = "The district office, the one that said shelters weren't its business, now prints your shelter map on the back of every evacuation leaflet. Three other cities have copied it. On the door of the first basement, someone has painted your name.",
		when = { flags = { "sgs_on" } },
		result = { charisma = 2, sanity = 8, setFlags = { "fate_shelter_founder", "fate_civilian_hero" }, log = "You left the paint where it was. You still check the water in the first basement every month." },
	}),
	{
		id = "sg_shel_war",
		title = "The Shelters Hold",
		text = "The war. Gates in every country at once, armies in the streets. Your shelters are full, and the radio net is the only thing in the city still working the way it's supposed to.",
		weight = 8,
		once = true,
		tags = { "danger" },
		when = { minYear = 12, maxYear = 12, flags = { "sgs_on", "monarch_war" }, notFlags = { "world_rewritten" } },
		choices = {
			{
				label = "Run the net from the first basement",
				clash = { stat = "willpower", foe = "The war", coins = 2, base = 9, coinPower = 4, fixed = true },
				win = { willpower = 4, sanity = -6, setFlags = { "fate_civilian_hero" }, codex = { "lore_war" }, log = "For four days you sent people to doors that were open and away from streets that weren't. When it ended, the count from the shelters was the best in the city." },
				lose = { vitality = { -40, -15 }, sanity = -10, setFlags = { "fate_civilian_hero" }, codex = { "lore_war" }, cause = "Killed in the war at the end of the world", log = "The first basement took a hit on the third day. The net kept running from the second one." },
			},
			{ label = "Hand the net to the wardens and stay with your block", result = { sanity = -8, charisma = 2, codex = { "lore_war" }, log = "You sat with your neighbours in the dark and told them, every hour, what the radio said. Every hour it was a little better." } },
		},
	},

	-- ── CRYSTAL TYCOON ──────────────────────────────────────────────────
	{
		id = "sg_tyc_01",
		title = "The Collection Point",
		text = "Low-rank Hunters come out of Gates with a few crystals each and sell them to whoever's at the tape, for whatever they're offered. The power companies pay three times as much, if you have the paperwork. You have a van, a trading licence application and an idea.",
		weight = 3,
		once = true,
		when = { minAge = 20, maxAge = 50, minYear = 2, min = { intelligence = 35 }, notFlags = { "sg_civ_arc", "world_rewritten" } },
		choices = {
			{
				label = "Set up at the tape",
				hint = "10 {currency} to start.",
				requires = { min = { money = 10 } },
				result = { money = -10, setFlags = { "sg_civ_arc", "sgt_on" }, schedule = { event = "sg_tyc_02", inYears = 1 }, codex = { "lore_crystals" }, log = "Fair prices, paid on the spot, a receipt for everything. E-rank Hunters started looking for your van." },
			},
			{ label = "Not a business for you", result = { log = "Someone else bought a van." } },
		},
	},
	beat({
		id = "sg_tyc_02",
		title = "The Refinery",
		text = "A failing factory in the outer districts is for sale. With the right equipment, crystals could be cut and graded there, and graded crystals sell for double. It would take everything you have, and a loan.",
		when = { flags = { "sgt_on" } },
		choices = {
			{
				label = "Buy it",
				clash = { stat = "luck", foe = "The first year of a business", coins = 2, base = 6, coinPower = 3 },
				win = { money = { 20, 60 }, setFlags = { "sgt_refinery" }, schedule = { event = "sg_tyc_03", inYears = 1 }, log = "The first graded batch sold in an hour. You framed the receipt." },
				lose = { money = -20, sanity = -4, setFlags = { "sgt_refinery" }, schedule = { event = "sg_tyc_03", inYears = 1 }, log = "The first year nearly broke you. The second one didn't." },
			},
			{ label = "Partner with a guild instead", result = { money = { 10, 25 }, setFlags = { "sgt_partner" }, schedule = { event = "sg_tyc_03", inYears = 1 }, log = "A mid-size guild sells you its whole haul at a fixed price. Steady, safe, and their name on half your contracts." } },
		},
	}),
	beat({
		id = "sg_tyc_03",
		title = "No Papers",
		text = "A supplier offers you crystals at half price: no Association seal, no record of which Gate they came out of. 'Everybody does it,' he says. You know some of them came out of Gates nobody was supposed to be in.",
		when = { flags = { "sgt_on" } },
		choices = {
			{ label = "Buy them", result = { money = { 30, 80 }, sanity = -4, setFlags = { "sgt_dirty" }, schedule = { event = "sg_tyc_04", inYears = 1 }, log = "You bought them and mixed them in with the sealed stock. Nobody could tell. You could." } },
			{ label = "Refuse, and report him", result = { willpower = 2, setFlags = { "sgt_clean" }, schedule = { event = "sg_tyc_04", inYears = 1 }, codex = { "lore_kha" }, log = "The Surveillance Team thanked you. Your list of suppliers got a lot shorter." } },
			{ label = "Refuse quietly", result = { setFlags = { "sgt_clean" }, schedule = { event = "sg_tyc_04", inYears = 1 }, log = "You said no thank you and showed him out." } },
		},
	}),
	beat({
		id = "sg_tyc_04",
		title = "The Crash",
		text = "A huge deposit of crystals has been found in a Gate abroad, and the price has halved in a week. Your warehouse is full of stock worth half what you paid for it.",
		when = { flags = { "sgt_on" } },
		choices = {
			{
				label = "Hold, and wait it out",
				clash = { stat = "luck", foe = "A falling market", coins = 2, base = 7, coinPower = 3 },
				win = { money = { 40, 120 }, schedule = { event = "sg_tyc_05", inYears = 1 }, log = "The price came back, as you'd guessed. You bought half the market on the way down." },
				lose = { money = { -60, -20 }, sanity = -6, schedule = { event = "sg_tyc_05", inYears = 1 }, log = "It kept falling. You held on, and it cost you." },
			},
			{ label = "Sell before it falls further", result = { money = -20, schedule = { event = "sg_tyc_05", inYears = 1 }, log = "You took the loss and slept at night." } },
			{
				label = "Find new buyers: crystal power for whole districts",
				clash = { stat = "intelligence", foe = "Power companies that don't take meetings", coins = 2, base = 8, coinPower = 4 },
				win = { money = { 60, 150 }, intelligence = 2, setFlags = { "sgt_power" }, schedule = { event = "sg_tyc_05", inYears = 1 }, log = "Cheap crystals, a district's heating contract, and a ten-year deal. The crash made you." },
				lose = { money = -15, schedule = { event = "sg_tyc_05", inYears = 1 }, log = "Nobody was buying anything that month." },
			},
		},
	}),
	beat({
		id = "sg_tyc_05",
		title = "The Auditors",
		text = "After a black-market ring was broken up, the Association's auditors are going through every crystal trader in the country, seal by seal. They'll be at your refinery on Monday.",
		when = { flags = { "sgt_on" } },
		choices = {
			{
				label = "Open the books",
				requires = { flags = { "sgt_clean" } },
				result = { money = { 20, 50 }, setFlags = { "sgt_ready" }, schedule = { event = "sg_tyc_06", inYears = 1 }, log = "They found nothing, and said so in writing. Half the industry's buyers moved their contracts to you that month." },
			},
			{
				label = "Hide the unsealed stock",
				requires = { flags = { "sgt_dirty" } },
				clash = { stat = "luck", foe = "The auditors", coins = 2, base = 9, coinPower = 4 },
				win = { sanity = -4, setFlags = { "sgt_ready" }, schedule = { event = "sg_tyc_06", inYears = 1 }, log = "They missed it. You will never sleep properly again." },
				lose = { money = { -120, -50 }, sanity = -10, setFlags = { "sgt_ruined" }, log = "They found it. The fines took almost everything, and the business with them." },
			},
			{
				label = "Confess before they find it",
				requires = { flags = { "sgt_dirty" } },
				result = { money = { -50, -20 }, willpower = 2, setFlags = { "sgt_ready" }, schedule = { event = "sg_tyc_06", inYears = 1 }, log = "The fine was enormous. Your name was still worth something after it." },
			},
		},
	}),
	beat({
		id = "sg_tyc_06",
		title = "Crystal Tycoon",
		text = "Your crystals light a fifth of the city. Your refineries run in three countries. A business magazine puts you on its cover under the headline 'The Crystal Kingdom', which you hate.",
		when = { flags = { "sgt_on", "sgt_ready" } },
		choices = {
			{ label = "Expand again", result = { money = { 150, 400 }, sanity = -2, setFlags = { "fate_tycoon" }, log = "Two more countries, a fourth refinery and a tower downtown. You don't remember the last day off." } },
			{ label = "Pay your workers like Hunters", result = { money = { 60, 150 }, charisma = 3, sanity = 4, setFlags = { "fate_tycoon" }, log = "Every refinery worker got a raise and raid-grade safety gear. The magazine called it reckless. Your staff called it the first time anyone had treated the job as dangerous." } },
			{ label = "Fund the shelters and the Healers' wards", result = { money = { 40, 100 }, sanity = 6, setFlags = { "fate_tycoon" }, log = "Your name is on the back wall of a lot of basements now, in very small letters, which is how you wanted it." } },
		},
	}),

	-- ── THE EARLY WARNING ───────────────────────────────────────────────
	{
		id = "sg_res_01",
		title = "Found Too Late",
		text = "The worst breaks come from Gates nobody found: in forests, up mountains, in buildings nobody goes into. The Association's readers measure a Gate once it's there. You've been studying the readings from the hours before Gates appear, and you think there's something in them.",
		weight = 4,
		once = true,
		when = { minAge = 21, maxAge = 55, minYear = 3, min = { intelligence = 45 }, notFlags = { "sg_civ_arc", "world_rewritten" } },
		choices = {
			{ label = "Start building something", result = { setFlags = { "sg_civ_arc", "sgres_on" }, schedule = { event = "sg_res_02", inYears = 1 }, log = "You turned your spare room into a lab. The neighbours have opinions about the humming." } },
			{ label = "Publish the idea and let someone else try", result = { intelligence = 1, log = "Your paper was cited twice. Nobody built anything." } },
		},
	},
	beat({
		id = "sg_res_02",
		title = "The Prototype",
		text = "The prototype is a box of crystal wafers and wire that hums when it's pointed at the sky. Most of the time it hums at nothing. Twice now, it has hummed hours before a Gate opened less than a kilometre away.",
		when = { flags = { "sgres_on" } },
		choices = {
			{
				label = "Refine it, alone",
				clash = { stat = "intelligence", foe = "Noise in the readings", coins = 2, base = 9, coinPower = 4 },
				win = { intelligence = 3, schedule = { event = "sg_res_03", inYears = 1 }, log = "You found the frequency that only moved before a Gate. The box stopped humming at nothing." },
				lose = { money = -5, sanity = -3, schedule = { event = "sg_res_03", inYears = 1 }, log = "A year of false alarms. Then, finally, a pattern." },
			},
			{ label = "Take it to a university lab", result = { intelligence = 2, setFlags = { "sgres_shared" }, schedule = { event = "sg_res_03", inYears = 1 }, log = "Three graduate students and a professor who wouldn't stop saying 'remarkable'. It went faster with them." } },
		},
	}),
	beat({
		id = "sg_res_03",
		title = "Field Test",
		text = "The prototype has been humming at the same hillside for three days. If you're right, a Gate is about to open there. If you're right, you need to be close enough to measure it when it does.",
		tags = { "danger" },
		when = { flags = { "sgres_on" } },
		choices = {
			{
				label = "Hire a D-rank Hunter as an escort",
				hint = "5 {currency}.",
				requires = { min = { money = 5 } },
				result = { money = -5, setFlags = { "sgres_proven" }, schedule = { event = "sg_res_04", inYears = 1 }, log = "It opened at 4:12 in the morning, eighty metres from your tripod. Your escort was very calm about it." },
			},
			{
				label = "Go alone",
				clash = { stat = "luck", foe = "A Gate opening in the dark", coins = 2, base = 6, coinPower = 3, fixed = true },
				win = { willpower = 2, setFlags = { "sgres_proven" }, schedule = { event = "sg_res_04", inYears = 1 }, log = "It opened right where the box said it would. You got the reading and drove away very fast." },
				lose = { vitality = { -30, -12 }, setFlags = { "sgres_proven" }, schedule = { event = "sg_res_04", inYears = 1 }, cause = "Killed field-testing a Gate detector", log = "You got the reading. Then you got too close." },
			},
			{
				label = "Ask the Association to watch with you",
				clash = { stat = "charisma", foe = "An Association that's heard it before", coins = 2, base = 7, coinPower = 3 },
				win = { charisma = 2, setFlags = { "sgres_proven" }, schedule = { event = "sg_res_04", inYears = 1 }, log = "Two technicians sat in your car for three days eating your snacks. When it opened, they stopped laughing." },
				lose = { setFlags = { "sgres_proven" }, schedule = { event = "sg_res_04", inYears = 1 }, log = "They didn't come. It opened anyway, and you have the footage." },
			},
		},
	}),
	beat({
		id = "sg_res_04",
		title = "Who Owns the Warning",
		text = "A major guild offers to buy the detector outright: exclusive rights, so it can buy the raid rights to Gates before anyone else knows they exist. The Association offers a fraction of the money, and a promise to put it everywhere.",
		when = { flags = { "sgres_on" } },
		choices = {
			{ label = "Sell to the guild", result = { money = { 80, 200 }, sanity = -6, setFlags = { "sgres_sold" }, log = "You sold it. The guild's profits went up. The number of Gates found too late didn't go down." } },
			{ label = "Give it to the Association", result = { money = { 10, 30 }, setFlags = { "sgres_public" }, schedule = { event = "sg_res_05", inYears = 1 }, log = "The Association ordered three thousand of them. The guild sent you a very cold letter." } },
			{ label = "Publish the design for free", result = { intelligence = 2, setFlags = { "sgres_public" }, schedule = { event = "sg_res_05", inYears = 1 }, log = "You put every diagram online. Within a year there were detectors on rooftops in forty countries." } },
		},
	}),
	beat({
		id = "sg_res_05",
		title = "Three in the Morning",
		text = "A detector on a rooftop in {district} goes off at three in the morning: something big, in a residential block, in about two hours. The Association has to decide whether to wake ten thousand people on the word of a box you built.",
		when = { flags = { "sgres_on" } },
		choices = {
			{
				label = "Tell them to evacuate now",
				clash = { stat = "charisma", foe = "A duty officer who wants a second reading", coins = 2, base = 8, coinPower = 3 },
				win = { charisma = 2, setFlags = { "sgres_saved" }, schedule = { event = "sg_res_06", inYears = 1 }, log = "They evacuated. At 5:04 an A-rank Gate opened in the courtyard of an empty apartment block." },
				lose = { sanity = -6, setFlags = { "sgres_saved" }, schedule = { event = "sg_res_06", inYears = 1 }, log = "They waited for a second reading, got it at 4:30 and moved fast. Most people were out in time." },
			},
			{ label = "Trust the protocol you wrote", result = { intelligence = 2, setFlags = { "sgres_saved" }, schedule = { event = "sg_res_06", inYears = 1 }, log = "You'd written the protocol for exactly this. They followed it to the letter, and the block was empty when the Gate opened." } },
		},
	}),
	beat({
		id = "sg_res_06",
		title = "The Early Warning",
		text = "Gate detectors are on rooftops, in phones and on every Association van. The number of Gates found only when they break has fallen by more than half. The engineering students who visit your lab call the little box by your name.",
		when = { flags = { "sgres_on", "sgres_public" } },
		result = { intelligence = 3, sanity = 8, setFlags = { "fate_detector" }, log = "You keep the first prototype on your desk. Every so often it still hums at nothing, and you smile." },
	}),
}
