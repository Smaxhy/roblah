--[[
	Lobotomy Corporation's secrets: discovery chains that end in the secret Archive entries
	(Lore/LCorp.luau): where the green comes from, the Well, who the Sephirot were, the same
	day, the Seed of Light, and what the White Nights were. Every secret sets lc_secret_seen.

	EMPLOYEES (agents and researchers): a chain over years, dig deeper or look away.
	  lc_sc1_floor (random) -> lc_sc2_archive -> lc_sc3_well -> lc_sc4_old_name
	  -> lc_sc5_same_day -> lc_sc6_light   (scheduled two years apart, while L Corp stands)
	  If the fall cuts the chain off, the lc_scr_* cards pick it up afterward from the same
	  flags (lc_sc_dig1..6), and lc_sc7_white_nights closes it once the Light has come.
	  Looking away (lc_sc_looked_away) ends it.
	OUTSIDERS near District 12: a leaked page, a clerk who talks too much, the retrieval team.
	  lc_so1_page (random) -> lc_so2_clerk -> lc_so3_retrieval -> lc_so4_after (after the fall)
]]

local EMPLOYED = { "lcorp_agent", "lcorp_research" }
local AFTER = { "white_nights", "library", "limbus" }
local SEEN = "lc_secret_seen"

return {
	-- ── the employees' chain, while L Corp stands ──
	{
		id = "lc_sc1_floor",
		title = "The Floor Below the Floor",
		text = "The east-wing elevator has one button with no number on it, below the Extraction floor. You've never seen anyone press it. Tonight, on your way out, the elevator stops there by itself. The doors open on a dark corridor, a low hum and a small sign: ARCHITECTURE. AUTHORIZED PERSONNEL ONLY. Then they close, and the elevator carries on up as if nothing happened.",
		weight = 22,
		once = true,
		tags = { "lcorp", "secret" },
		when = { career = EMPLOYED, minAge = 19, world = { era = "wings" }, notFlags = { "lc_sc_started" } },
		choices = {
			{
				label = "Write down what you saw, and start asking",
				result = { sanity = -1, setFlags = { "lc_sc_started", "lc_sc_dig1" }, schedule = { event = "lc_sc2_archive", inYears = 2 }, log = "You wrote it all down that night: the button, the sign, the hum. Then you started asking, carefully, one question at a time, of people who might know." },
			},
			{
				label = "Ask a Sephirah about it",
				result = { mind = 1, setFlags = { "lc_sc_started", "lc_sc_dig1" }, schedule = { event = "lc_sc2_archive", inYears = 2 }, codex = "lc_lore_sephirot", log = "Malkuth said there was no such floor. Yesod said it was not your concern. Netzach told you to go home and sleep. Three different answers to one question is an answer of its own." },
			},
			{
				label = "Forget it. Elevators break",
				result = { sanity = 2, setFlags = { "lc_sc_started", "lc_sc_looked_away" }, log = "Elevators break. You took the stairs for a month, and then you forgot about it, mostly. Some nights you still hear the hum." },
			},
		},
	},
	{
		id = "lc_sc2_archive",
		title = "The Oldest File",
		text = "Late one night in the Information Team's archive, you find it in a box with no code on it: a file older than the company. Lab notes in three different hands, from a research group working somewhere in the Backstreets. A list of names, most of them crossed out. And on the last page, a chart: the very first measurement of something the notes call Enkephalin.",
		weight = 0,
		when = { career = EMPLOYED, world = { era = "wings" }, flags = { "lc_sc_dig1" } },
		choices = {
			{
				label = "Read all of it",
				result = { sanity = -3, addTrait = "lc_knows_the_green", setFlags = { SEEN, "lc_sc_dig2" }, codex = "lc_secret_green", schedule = { event = "lc_sc3_well", inYears = 2 }, log = "You read until dawn. The notes talk about things drawn up out of human minds and given shape, and about the energy those things give off when they're tended. You understand the PE-Boxes now. You'll never look at a streetlight the same way." },
			},
			{
				label = "Read the first page and put it back",
				result = { sanity = -2, setFlags = { SEEN, "lc_sc_looked_away" }, codex = "lc_secret_green", log = "One page was enough to understand where the green comes from. You put the box back exactly where it was, and decided you didn't need the rest." },
			},
			{
				label = "Take it to Yesod, unopened",
				result = { mind = 2, paycheck = 0.15, setFlags = { "lc_sc_looked_away" }, log = "Yesod took the box without a word and held it a moment longer than he needed to. \"Thank you,\" he said, very quietly. The next day it was gone, and there was a bonus in your pay." },
			},
		},
	},
	{
		id = "lc_sc3_well",
		title = "Never Look Down",
		text = "An errand takes you down to the Extraction Team's floor. In the middle of the extraction room is a hatch in the floor, with a sign above it in big plain letters: NEVER LOOK DOWN. The technician on duty steps out for a moment. The hatch is open a hand's width, and from below comes a sound like the sea.",
		weight = 0,
		when = { career = EMPLOYED, world = { era = "wings" }, flags = { "lc_sc_dig2" } },
		choices = {
			{
				label = "Look down",
				hint = "The sign is very clear.",
				result = { sanity = { -12, -8 }, mind = 3, condition = "lc_shaken", setFlags = { SEEN, "lc_sc_dig3" }, codex = "lc_secret_well", schedule = { event = "lc_sc4_old_name", inYears = 2 }, log = "You looked. Below the hatch was everything: every face, every thought, every person who ever was or will be, all at once, very far down. You were back on your feet before the technician returned. You've never told anyone what you saw, because you don't have the words." },
			},
			{
				label = "Ask Binah what's down there",
				hint = "A Mental Strength check. She answers in riddles.",
				clash = { stat = "mind", foe = "Binah's riddles", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = -3, setFlags = { SEEN, "lc_sc_dig3" }, codex = "lc_secret_well", schedule = { event = "lc_sc4_old_name", inYears = 2 }, log = "\"The Well,\" Binah said, \"where everyone is, a little. Every Abnormality in this building was drawn up out of it. Don't look. You'd only see yourself.\" She seemed pleased you'd asked instead of looking." },
				lose = { sanity = -4, setFlags = { "lc_sc_dig3" }, schedule = { event = "lc_sc4_old_name", inYears = 2 }, log = "\"Down,\" Binah said, smiling, and nothing more, however you asked. The technician came back and closed the hatch. You still don't know." },
			},
			{
				label = "Close the hatch and leave",
				result = { sanity = 2, setFlags = { "lc_sc_looked_away" }, log = "You closed the hatch with your foot, without looking, and went back up. Some rules are written for a reason, and you didn't want to learn the reason." },
			},
		},
	},
	{
		id = "lc_sc4_old_name",
		title = "We",
		text = "Over coffee in the Welfare office, Chesed is talking about the old days. \"Back when we were all in the lab,\" he says, \"we drank much worse coffee than this.\" Then he stops, and his machine face doesn't move, and for a long moment the only sound is the coffee machine. There was no lab, officially. There was no \"we\".",
		weight = 0,
		when = { career = EMPLOYED, world = { era = "wings" }, flags = { "lc_sc_dig3" } },
		codex = "lc_lore_sephirot",
		choices = {
			{
				label = "Ask him who \"we\" were",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "A Sephirah's silence", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = -3, setFlags = { SEEN, "lc_sc_dig4" }, codex = "lc_secret_sephirot", schedule = { event = "lc_sc5_same_day", inYears = 2 }, log = "He looked at you for a long time. \"Friends,\" he said. \"Colleagues. Most of them are here, in a way.\" He said a name you didn't know, a human name, and then he asked you to leave, gently." },
				lose = { sanity = -2, setFlags = { "lc_sc_dig4" }, schedule = { event = "lc_sc5_same_day", inYears = 2 }, log = "\"A figure of speech,\" he said, and laughed, and poured you more coffee. He didn't meet your eyes for the rest of the evaluation." },
			},
			{
				label = "Tell him what you read in the oldest file",
				hint = "You know about the lab in the Backstreets.",
				requires = { flags = { "lc_secret_seen" } },
				result = { sanity = -4, setFlags = { SEEN, "lc_sc_dig4" }, codex = "lc_secret_sephirot", schedule = { event = "lc_sc5_same_day", inYears = 2 }, log = "You told him about the crossed-out names. He was quiet a long time. \"One of those was mine,\" he said at last. \"Don't cross it out again, will you?\"" },
			},
			{
				label = "Pretend you didn't hear",
				result = { sanity = 1, setFlags = { "lc_sc_looked_away" }, log = "You sipped your coffee and talked about the weather. He seemed grateful. You decided you were too." },
			},
		},
	},
	{
		id = "lc_sc5_same_day",
		title = "Tomorrow's Report",
		text = "Matthias Kell, the oldest Clerk on the Record Team, stops at your desk and lays a form in front of you: an incident report about a breach in the west corridor, in your handwriting, signed by you. It's dated tomorrow. \"Third one this year,\" he says quietly. \"You never remember. I always do.\"",
		weight = 0,
		when = { career = EMPLOYED, world = { era = "wings" }, flags = { "lc_sc_dig4" } },
		choices = {
			{
				label = "Ask him how long it's been happening",
				result = { sanity = -4, setFlags = { SEEN, "lc_sc_dig5" }, codex = "lc_secret_loop", schedule = { event = "lc_sc6_light", inYears = 2 }, log = "\"Since before you were hired,\" he said. \"Some days happen more than once here. The bad ones, mostly. The Manager tries them again until they come out right.\" He took the form back. \"Don't go to the west corridor tomorrow.\" You didn't. There was a breach there." },
			},
			{
				label = "Go to the west corridor tomorrow and see",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "A day you've already lived", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = -3, setFlags = { SEEN, "lc_sc_dig5", "lc_breach_survivor", "saw_abnormality" }, codex = "lc_secret_loop", schedule = { event = "lc_sc6_light", inYears = 2 }, log = "You stood in the west corridor at the time on the form, and the breach came exactly as written, and you were ready for it, because you'd written it. You got everyone out. That night, the form in your drawer was blank." },
				lose = { health = { -9, -5 }, sanity = -4, setFlags = { "lc_sc_dig5", "lc_breach_survivor", "saw_abnormality" }, schedule = { event = "lc_sc6_light", inYears = 2 }, log = "The breach came exactly as written, and you weren't ready, form or no form. Matthias visited you in Welfare. \"Next time,\" he said, which wasn't comforting." },
			},
			{
				label = "Tear it up",
				result = { sanity = -1, setFlags = { "lc_sc_looked_away" }, log = "You tore it up in front of him. He sighed, like someone who'd watched you do it before. Maybe he had." },
			},
		},
	},
	{
		id = "lc_sc6_light",
		title = "The Bottom of the Facility",
		text = "The button with no number. This time you've borrowed a badge that opens it, from a Clerk who owed you a favor and didn't ask why. The doors open on Architecture: a room so big you can't see its walls, and in the middle of it, very far away, something glowing like the first light of morning. The yield charts' missing stream ends here.",
		weight = 0,
		when = { career = EMPLOYED, world = { era = "wings" }, flags = { "lc_sc_dig5" } },
		choices = {
			{
				label = "Walk toward the light",
				result = { sanity = { 4, 8 }, setFlags = { SEEN, "lc_sc_dig6" }, codex = "lc_secret_seed", log = "You walked until your legs ached and the light filled the room. It was warm. It felt like being forgiven for something. You understood, then, what all the PE-Boxes were for, and what the company was really for, and you walked back to the elevator before anyone came." },
			},
			{
				label = "Look, and leave before anyone sees you",
				result = { sanity = -2, mind = 2, setFlags = { SEEN, "lc_sc_dig6" }, codex = "lc_secret_seed", log = "You looked for as long as you dared and then pressed the button to go up. In the elevator, you realized you were crying, and couldn't have said whether it was from fear or hope." },
			},
			{
				label = "Give the badge back and never come here again",
				result = { sanity = 1, setFlags = { "lc_sc_looked_away" }, log = "You pressed the button for the ground floor without stepping out. Whatever it was, it wasn't yours to see. You gave the Clerk her badge back and bought her lunch for a month." },
			},
		},
	},

	-- ── the same chain, picked up after the fall ──
	{
		id = "lc_scr_green",
		title = "An Old Notebook at the Green Kettle",
		text = "The Green Kettle, the teahouse where L Corp staff used to go after shifts, is full of former employees now, with nowhere else to be. An old Information Team archivist recognizes you, sits down, and pushes a stained notebook across the table. \"You were the one asking about the floor with no number,\" she says. \"You should have this. I'm tired of carrying it.\"",
		weight = 30,
		once = true,
		tags = { "lcorp", "secret" },
		when = { flags = { "lc_sc_dig1" }, notFlags = { "lc_sc_dig2", "lc_sc_looked_away" }, world = { era = AFTER } },
		choices = {
			{
				label = "Read it",
				result = { sanity = -3, addTrait = "lc_knows_the_green", setFlags = { SEEN, "lc_sc_dig2" }, codex = "lc_secret_green", log = "Notes from before the company, copied out of a file that no longer exists. Where the Abnormalities came from. What the green was made of. You finished your tea cold." },
			},
			{
				label = "Push it back across the table",
				result = { sanity = 2, setFlags = { "lc_sc_looked_away" }, log = "\"It's over,\" you said. \"Whatever it was.\" She looked at you with something like envy, and took the notebook home." },
			},
		},
	},
	{
		id = "lc_scr_well",
		title = "A Technician from Extraction",
		text = "At the Green Kettle, a man with a burn scar across one hand and a tremor in the other sits down at your table. He worked on the Extraction Team, he says, until the end. \"You've got that look,\" he says. \"The one that wants to know what was under the hatch. I'll tell you. Someone should know.\"",
		weight = 26,
		once = true,
		tags = { "lcorp", "secret" },
		when = { flags = { "lc_sc_dig2" }, notFlags = { "lc_sc_dig3", "lc_sc_looked_away" }, world = { era = AFTER } },
		choices = {
			{
				label = "Let him tell you",
				result = { sanity = -5, setFlags = { SEEN, "lc_sc_dig3" }, codex = "lc_secret_well", log = "He told you about the Well: a sea under every mind, and the company drawing things up out of it, and the one technician who looked down and was never the same. \"That was my brother,\" he said, and drank his tea." },
			},
			{
				label = "Tell him you'd rather not know",
				result = { sanity = 2, setFlags = { "lc_sc_looked_away" }, log = "He nodded slowly. \"That's the smart answer,\" he said. \"I wish I'd given it.\"" },
			},
		},
	},
	{
		id = "lc_scr_old_name",
		title = "Machines That Remembered",
		text = "A retired Welfare Team nurse holds court at the Green Kettle on Thursdays, telling stories about the Sephirot. Most of them are funny. Tonight, when the others have gone, she tells you one that isn't. \"They weren't only machines,\" she says. \"Chesed told me once. He'd been someone. They all had.\"",
		weight = 24,
		once = true,
		tags = { "lcorp", "secret" },
		when = { flags = { "lc_sc_dig3" }, notFlags = { "lc_sc_dig4", "lc_sc_looked_away" }, world = { era = AFTER } },
		choices = {
			{
				label = "Ask her who they'd been",
				result = { sanity = -3, setFlags = { SEEN, "lc_sc_dig4" }, codex = "lc_secret_sephirot", log = "\"People from a lab in the Backstreets,\" she said. \"Before the company. The ones who didn't make it. Somebody who did make it couldn't let them go.\" She finished her tea. \"Machines that think are a Taboo. I suppose that's why it all ended the way it did.\"" },
			},
			{
				label = "Change the subject",
				result = { sanity = 1, setFlags = { "lc_sc_looked_away" }, log = "You asked about her grandchildren instead. She looked relieved, and talked about them for an hour." },
			},
		},
	},
	{
		id = "lc_scr_same_day",
		title = "Matthias Remembers",
		text = "Matthias Kell, who was the oldest Clerk on the Record Team, still sits at the same table at the Green Kettle every afternoon, with a stack of old forms tied up in string. \"You were in the west corridor,\" he says when he sees you. \"The day of the big breach. All eleven times.\"",
		weight = 24,
		once = true,
		tags = { "lcorp", "secret" },
		when = { flags = { "lc_sc_dig4" }, notFlags = { "lc_sc_dig5", "lc_sc_looked_away" }, world = { era = AFTER } },
		choices = {
			{
				label = "Ask him what he means",
				result = { sanity = -4, setFlags = { SEEN, "lc_sc_dig5" }, codex = "lc_secret_loop", log = "He untied the string. Eleven incident reports for the same day, all in different hands, all slightly different. In the last one, nobody died. \"The Manager kept trying it,\" he said, \"until it came out right. Everybody forgot but me.\"" },
			},
			{
				label = "Tell him he's misremembering",
				result = { sanity = -1, setFlags = { "lc_sc_looked_away" }, log = "\"Maybe,\" he said, and tied the string up again. \"Everyone says that. Every time.\"" },
			},
		},
	},
	{
		id = "lc_scr_light",
		title = "What Was at the Bottom",
		text = "An old woman with an L Corp badge still on a cord around her neck has been asking around the Green Kettle for you by name. She worked on the Architecture Team, at the very bottom of the facility, and she's the last of them. \"You went looking for the floor with no number,\" she says. \"Do you want to know what you'd have found?\"",
		weight = 22,
		once = true,
		tags = { "lcorp", "secret" },
		when = { flags = { "lc_sc_dig5" }, notFlags = { "lc_sc_dig6", "lc_sc_looked_away" }, world = { era = AFTER } },
		choices = {
			{
				label = "Yes",
				result = { sanity = 3, setFlags = { SEEN, "lc_sc_dig6" }, codex = "lc_secret_seed", log = "\"A Light,\" she said. \"We were growing it. Every bit of the green the City didn't get went down to it. It was meant to heal everyone at once.\" She smiled. \"You saw what happened when it came out. Well. Some of what happened.\"" },
			},
			{
				label = "No. Let it stay buried",
				result = { sanity = 2, setFlags = { "lc_sc_looked_away" }, log = "\"Good,\" she said, to your surprise. \"I've wished I didn't know every day since.\" She bought your tea and left." },
			},
		},
	},
	{
		id = "lc_sc7_white_nights",
		title = "What the Light Was",
		text = "You were there for the White Nights, like everyone. You saw the pillar of light over District 12 and the three good days after, and the strange days that followed. Now you know about the Well, and the Sephirot, and the days that happened twice, and the Light at the bottom of the facility. Sitting by your window tonight, it all fits together at last.",
		weight = 60,
		once = true,
		tags = { "lcorp", "secret" },
		when = { flags = { "lc_sc_dig6" }, notFlags = { "lc_secret_whole_truth" }, world = { era = AFTER } },
		choices = {
			{
				label = "Write it all down",
				result = { mind = 3, sanity = 2, setFlags = { SEEN, "lc_secret_whole_truth" }, codex = "lc_secret_white_nights", log = "You wrote it out in plain words, the whole thing, start to end, and put the pages in a tin box under the floor. Someone, someday, should know what the company was for, and what it cost." },
			},
			{
				label = "Tell the regulars at the Green Kettle",
				result = { sanity = 4, setFlags = { SEEN, "lc_secret_whole_truth" }, codex = "lc_secret_white_nights", chronicle = "lc_truth_told", log = "You told them, over tea, the whole thing. Nobody laughed. One old Clerk cried. Afterward, people you didn't know started coming to the Green Kettle to hear it." },
			},
			{
				label = "Keep it to yourself",
				result = { sanity = -2, mind = 2, setFlags = { SEEN, "lc_secret_whole_truth" }, codex = "lc_secret_white_nights", log = "You kept it. It's heavy. You look at the people in the street sometimes, getting by in the City the Light left behind, and wonder which of them would want to know." },
			},
		},
	},
	{
		id = "lc_sc_notes",
		title = "The Bag of Notes",
		text = "The bag of observation logs you carried out of L Corp on the last day has been under your bed ever since. Collectors have started asking around about L Corp papers, and the people asking aren't all collectors. Tonight you finally open it, and on top is a memo you don't remember taking, from the Architecture Team, stamped FOR THE LIGHT.",
		weight = 40,
		once = true,
		tags = { "lcorp", "secret" },
		when = { flags = { "kept_lcorp_notes" }, world = { era = AFTER } },
		choices = {
			{
				label = "Read the Architecture memo",
				result = { sanity = -2, setFlags = { SEEN }, codex = "lc_secret_seed", log = "The memo was about a quota, of all things: how much of every day's energy had to go down to the bottom floor, to the Light, before any could go out to the City. It was signed with a name you didn't recognize." },
			},
			{
				label = "Sell the bag to the highest bidder",
				result = { money = { 600, 1200 }, sanity = -3, log = "A buyer in a long coat paid in cash and didn't count the pages. You never asked who they worked for. You've wondered since." },
			},
			{
				label = "Burn all of it",
				result = { sanity = 4, log = "You burned it in a bucket on the roof, page by page. The smoke was faintly green. You felt lighter than you had since the day you walked out." },
			},
		},
	},

	-- ── the outsiders' chain: near District 12, never employed ──
	{
		id = "lc_so1_page",
		title = "A Page in the Gutter",
		text = "A sheet of paper has blown into the gutter outside your door, soaked at one corner. The letterhead is Lobotomy Corporation's. It's an observation log, half of one, about something called O-02-56: a small bird, it says, which must not be handled. At the bottom, in someone's hurried pen: \"PB out again. 3 hurt. Do NOT tell the Manager it was Repression.\"",
		weight = 14,
		once = true,
		tags = { "lcorp", "secret" },
		when = { district = "d12", minAge = 12, world = { era = "wings" }, notFlags = { "lcorp_employee", "lc_so_started" } },
		choices = {
			{
				label = "Dry it off and keep it",
				result = { mind = 1, setFlags = { "lc_so_started", "lc_so_dig1" }, codex = "lc_abno_punishing_bird", schedule = { event = "lc_so2_clerk", inYears = 2 }, log = "You dried it on the radiator and read it ten times. A bird that punishes. Three hurt. You put it inside your only book and started looking at the L Corp tower differently." },
			},
			{
				label = "Sell it to the collector on Fourth Street",
				result = { money = { 30, 80 }, setFlags = { "lc_so_started" }, chronicle = "lc_log_leaked", log = "The collector on Fourth Street paid without haggling, which told you it was worth more. By the end of the month, copies of it were turning up in three Districts." },
			},
			{
				label = "Hand it in at the L Corp gate",
				result = { money = 20, mind = 1, setFlags = { "lc_so_started", "lc_so_reported" }, log = "The guard at the gate took it, read it, went pale, and gave you twenty Ahn and a lollipop from a drawer. \"You didn't read this,\" he said. You said you hadn't." },
			},
		},
	},
	{
		id = "lc_so2_clerk",
		title = "The Clerk Who Talks Too Much",
		text = "At the Green Kettle, where L Corp staff drink tea after their shifts, a Record Team Clerk named Teodor Wren has had the worst day of his life and has decided you're his new best friend. He's on his fourth pot of tea and his voice keeps getting louder. \"You want to know what we really make in there?\" he says. \"Do you? Nobody ever wants to know.\"",
		weight = 0,
		when = { flags = { "lc_so_dig1" }, world = { era = "wings" } },
		choices = {
			{
				label = "Order another pot, and listen",
				result = { sanity = -3, addTrait = "lc_knows_the_green", setFlags = { SEEN, "lc_so_dig2" }, codex = "lc_secret_green", schedule = { event = "lc_so3_retrieval", inYears = 1 }, log = "He told you everything he knew, which was more than a Clerk should. The green energy, the things in the units, where they come from: out of people. Out of what people feel. He fell asleep on the table. You paid for his tea and walked home under streetlights that looked very different." },
			},
			{
				label = "Stop him before he says too much",
				result = { sanity = 2, setFlags = { "lc_so_stopped" }, addRelation = { kind = "friend", name = "Teodor Wren", bond = 55, age = { 24, 34 } }, log = "You put a hand on his arm and told him he'd regret it in the morning. He stared at you, then laughed, then thanked you. He comes by your stall now and then, and never talks about work, and you've become friends." },
			},
			{
				label = "Report him to L Corp",
				result = { money = 40, sanity = -3, setFlags = { "lc_so_reported" }, log = "You reported him. L Corp paid you forty Ahn. Teodor was transferred to a branch in another District the next week. You saw his landlady crying on the steps." },
			},
		},
	},
	{
		id = "lc_so3_retrieval",
		title = "The Retrieval Team",
		text = "Two people in gray coats with small green L Corp badges are waiting outside your door when you get home. They're very polite. \"We understand,\" says the woman, \"that you have some company property. A page. And some things you heard at a teahouse.\" Her colleague is holding a clipboard. Your name is on it.",
		weight = 0,
		when = { flags = { "lc_so_dig2" }, world = { era = "wings" } },
		choices = {
			{
				label = "Hand over the page",
				result = { sanity = 1, setFlags = { "lc_so_dig3" }, log = "You gave them the page. They thanked you, and asked you to sign a form saying you'd never read it, and you signed it. They couldn't take back what Teodor told you. They didn't try." },
			},
			{
				label = "Talk your way out of it",
				hint = "A Charisma check: you've never seen a page in your life.",
				clash = { stat = "charisma", foe = "A polite retrieval officer", coins = 2, base = 5, coinPower = 3 },
				win = { charisma = 2, setFlags = { "lc_so_dig3", "lc_so_kept_page" }, log = "You were so convincingly confused that the woman apologized for wasting your time. The page is still inside your book. You moved the book, just in case." },
				lose = { money = { -80, -40 }, sanity = -4, setFlags = { "lc_so_dig3" }, log = "She smiled and waited until you stopped talking. Then her colleague found the page in thirty seconds. There was a fine. It was a large fine." },
			},
			{
				label = "Slam the door and go out the back window",
				hint = "A Strength check.",
				clash = { stat = "strength", foe = "Two gray coats", coins = 2, base = 4, coinPower = 3 },
				win = { strength = 2, setFlags = { "lc_so_dig3", "lc_so_kept_page" }, log = "You went out the back window with the page in your teeth and spent the night at a friend's. When you came home, they'd gone, and nobody came back. You're not sure that's good." },
				lose = { health = { -6, -3 }, money = -30, setFlags = { "lc_so_dig3" }, log = "The window was stuck. The woman in gray waited, politely, while you climbed back in." },
			},
		},
	},
	{
		id = "lc_so4_after",
		title = "What the Clerk Meant",
		text = "The White Nights came and went. L Corp is gone and its tower is a hole in the ground. You keep thinking about the Green Kettle, years ago, and the Clerk who said the City ran on something taken out of people. You think about the pillar of light. You find you can finally put the two together.",
		weight = 40,
		once = true,
		tags = { "lcorp", "secret" },
		when = { flags = { "lc_so_dig3" }, world = { era = AFTER } },
		choices = {
			{
				label = "Think it through to the end",
				result = { mind = 3, sanity = -2, setFlags = { SEEN }, codex = "lc_secret_white_nights", log = "Energy from people's minds, gathered for years and stored somewhere deep, and then let go all at once, as light. Meant to heal, maybe. You sat by the window until dawn, thinking about the three good days." },
			},
			{
				label = "Tell people what you know",
				result = { sanity = 2, setFlags = { SEEN }, codex = "lc_secret_white_nights", chronicle = "lc_truth_told", log = "You started telling people: at the market, at the diner, at the Green Kettle. Most didn't believe you. A few did, and came back to hear it again, and brought friends." },
			},
			{
				label = "Let it go. It's over",
				result = { sanity = 3, log = "You decided it was over, whatever it had been. You put the page in the stove at last. The Light came and went, and you're still here, and that will have to be enough." },
			},
		},
	},
}
