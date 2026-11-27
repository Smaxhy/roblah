--[[
	Danger and horror (dz_): the Head, its Claws and its Eye, and the Taboos of the City.
	The Head's sentences have no appeal; what's left is luck, manners and paperwork.
	Chains:
		dz_h_machine -> (1 year) dz_h_claws_came -> (2-4 years) dz_h_eye_visit
		             -> (1 year) dz_h_claws_for_you   if you helped build it
		dz_h_brought_back -> (1 year) dz_h_erasure_day
]]

return {
	{
		id = "dz_h_machine",
		title = "The Machine That Asked",
		text = "Jun, the repair kid upstairs, shows you the little robot he built from scrap. It asks your name, then asks why it was made. Building a machine that thinks is a Taboo.",
		weight = 2,
		once = true,
		when = { minAge = 12 },
		codex = "dz_lore_taboos",
		choices = {
			{
				label = "Tell him to scrap it",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A boy who loves his robot", coins = 2, base = 4, coinPower = 3, fixed = true },
				win = { sanity = -3, log = "He cried and took it apart in front of you, bolt by bolt. He never spoke to you again, and he lived." },
				lose = { sanity = -2, setFlags = { "dz_machine_known" }, schedule = { event = "dz_h_claws_came", inYears = 1 }, log = "He said he'd think about it. He didn't." },
			},
			{ label = "Keep his secret", result = { sanity = 1, setFlags = { "dz_machine_known" }, schedule = { event = "dz_h_claws_came", inYears = 1 }, log = "You promised, and the robot thanked you. It had lovely manners." } },
			{ label = "Help him improve it", hint = "+3 Intelligence. Dangerous.", result = { intelligence = 3, setFlags = { "dz_machine_helper" }, schedule = { event = "dz_h_claws_for_you", inYears = 1 }, log = "You spent the winter teaching it chess. It beat you in March." } },
		},
	},
	{
		id = "dz_h_claws_came",
		title = "The Top Floor",
		text = "There was no sound in the night. In the morning the top floor is empty: no door, no Jun, no name on the mailbox. His mother tells you she never had a son.",
		weight = 0,
		when = { flags = { "dz_machine_known" } },
		codex = "dz_lore_claws",
		choices = {
			{ label = "Keep the bolt he gave you", result = { sanity = -4, setFlags = { "dz_remembers", "dz_bolt" }, codex = "dz_lore_erased", schedule = { event = "dz_h_eye_visit", inYears = 4 }, log = "You kept the little bolt in your pocket. You're the only one on the street who remembers his name." } },
			{ label = "Throw it in the canal", result = { sanity = -2, log = "You threw the bolt in the canal, and in a year you couldn't remember his face. That's how it works." } },
			{
				label = "Ask around",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A street that has forgotten", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -4, setFlags = { "dz_remembers" }, codex = "dz_lore_erased", schedule = { event = "dz_h_eye_visit", inYears = 4 }, log = "Nobody remembered, but one old man went white and closed his shutters. That was answer enough." },
				lose = { sanity = -6, condition = "dz_hunted", setFlags = { "dz_remembers" }, schedule = { event = "dz_h_eye_visit", inYears = 2 }, log = "You asked too many people. Somebody, somewhere, wrote it down." },
			},
		},
	},
	{
		id = "dz_h_claws_for_you",
		title = "A Long Coat on the Stairs",
		text = "The top floor is empty this morning: no door, no Jun. And a figure in a long coat is standing on your stairs, in no hurry at all, looking at the chessboard through your open door.",
		weight = 0,
		when = { flags = { "dz_machine_helper" } },
		codex = "dz_lore_claws",
		choices = {
			{
				label = "Burn the chessboard",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Every trace of it", coins = 2, base = 4, coinPower = 3, fixed = true },
				win = { sanity = -12, setFlags = { "dz_claw_witness" }, clearFlags = { "dz_machine_helper" }, chronicle = "dz_act_claw_witness", log = "The board was in the stove before it reached your landing. It looked at the ashes for a long time, and went away." },
				lose = { die = "Erased by the Head", log = "You missed one piece: a white knight, under the bed." },
			},
			{
				label = "Run",
				hint = "Speed check. Nobody outruns a Claw.",
				clash = { stat = "speed", foe = "A Claw", coins = 4, base = 10, coinPower = 4, fixed = true },
				win = { sanity = -15, setFlags = { "dz_unsurvivable", "dz_claw_witness" }, clearFlags = { "dz_machine_helper" }, condition = "dz_hunted", chronicle = "dz_act_claw_witness", log = "You went out of the window and kept going for three Districts, and it let you. You don't know why, and that's worse." },
				lose = { die = "Erased by a Claw", log = "It was already at the bottom of the stairs." },
			},
			{
				label = "Tell the truth and beg",
				hint = "Charisma check. Very bad odds.",
				clash = { stat = "charisma", foe = "A sentence with no appeal", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -10, setFlags = { "dz_unsurvivable", "dz_claw_witness" }, clearFlags = { "dz_machine_helper" }, addTrait = "dz_dread_calm", chronicle = "dz_act_claw_witness", log = "You told it everything: the chess, the winter, the boy. It listened, then took the chessboard and left you." },
				lose = { die = "Erased by the Head", log = "It listened politely. Then it did its work." },
			},
		},
	},
	{
		id = "dz_h_eye_visit",
		title = "A Woman With an Eye Pin",
		text = "A polite woman with a small eye pinned to her lapel stops you outside your building. \"Did you ever know a boy called Jun?\" Her notebook is already open.",
		weight = 0,
		when = { flags = { "dz_remembers" } },
		codex = "dz_lore_erased",
		choices = {
			{
				label = "\"Never heard of him.\"",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The Eye", coins = 3, base = 7, coinPower = 3, fixed = true },
				win = { sanity = -6, clearFlags = { "dz_remembers" }, log = "She studied your face for a long time, then closed the notebook. \"Good,\" she said, \"keep it that way.\"" },
				lose = { die = "Erased for remembering", log = "She wrote one line in her notebook. By evening, nobody remembered you either." },
			},
			{
				label = "\"He was my friend.\"",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "The Eye", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = 3, setFlags = { "dz_claw_witness" }, clearFlags = { "dz_remembers" }, chronicle = "dz_act_claw_witness", log = "\"Someone should remember,\" she said, surprised, and tore the page out for you. You still have it, and it's blank." },
				lose = { sanity = -15, condition = "dz_hunted", clearFlags = { "dz_remembers" }, log = "\"Thank you,\" she said, and wrote it down. You have felt watched every day since." },
			},
			{ label = "Hand her the bolt", requires = { flags = { "dz_bolt" } }, result = { sanity = 4, mind = -3, clearFlags = { "dz_remembers", "dz_bolt" }, log = "She took the bolt and thanked you. By morning you couldn't have said why you ever carried it." } },
			{ label = "Walk away without a word", requires = { notFlags = { "dz_bolt" } }, result = { sanity = -8, condition = "dz_hunted", log = "You walked away, and she didn't follow. She didn't need to." } },
		},
	},
	{
		id = "dz_h_camera",
		title = "The Camera Next Door",
		text = "3:09. Through the wall you hear your neighbor setting up a camera at his window. Footage of the Night sells for a fortune, and recording it is a Taboo of the City.",
		weight = 2,
		once = true,
		tags = { "danger" },
		when = { minAge = 16, side = "backstreets" },
		codex = "dz_lore_taboos",
		choices = {
			{
				label = "Stop him before 3:13",
				hint = "Strength check. Breaking in after 3:13 is a Taboo too.",
				clash = { stat = "strength", foe = "Four minutes and a locked door", coins = 2, base = 4, coinPower = 3, fixed = true },
				win = { sanity = 2, strength = 2, log = "You were through his door at 3:11 with the camera in your hands. He hated you for a week, and he's alive to." },
				lose = { sanity = -10, codex = "dz_lore_erased", log = "At 3:12 you were still working his lock, so you backed away, because after 3:13 breaking in is a Taboo too. In the morning his door was gone." },
			},
			{ label = "Pull the covers over your head", result = { sanity = -8, codex = "dz_lore_erased", log = "At 3:40 the wall went quiet. In the morning there was plaster where his door had been, and nobody remembered him but you." } },
			{
				label = "Leave the building now",
				hint = "Strength check. It's nearly the Night.",
				clash = { stat = "strength", foe = "Four minutes", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { sanity = -6, money = -60, log = "You reached a night shelter at 3:12 and paid what they asked. When you came home, the building had one floor fewer." },
				lose = { health = { -20, -8 }, log = "You were on the front steps when the ground began to hum.", cause = "Swept away fleeing a Taboo" },
			},
		},
	},
	{
		id = "dz_h_brought_back",
		title = "Back From the Dead",
		text = "Mrs. Oh's brother died in the spring. Tonight he's sitting at her window again, exactly as before, staring at nothing. Everyone on the street knows what bringing back the dead means.",
		weight = 2,
		once = true,
		when = { minAge = 16 },
		codex = "dz_lore_taboos",
		choices = {
			{ label = "Move out this week", hint = "100 Ahn.", requires = { min = { money = 100 } }, result = { money = -100, sanity = -3, log = "You moved across the District. A month later Mrs. Oh's building was gone, and the lot was for sale." } },
			{
				label = "Knock and look closer",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A man who came back", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -8, mind = 2, codex = "dz_lore_erased", log = "He looked at you and didn't know his own name. You went home and packed that night." },
				lose = { sanity = -10, condition = "dz_hunted", schedule = { event = "dz_h_erasure_day", inYears = 1 }, log = "He followed you home, and stood under your window every night after." },
			},
			{ label = "Stay and say nothing", result = { sanity = -4, schedule = { event = "dz_h_erasure_day", inYears = 1 }, log = "You kept your head down and your curtains shut. So did everyone." } },
		},
	},
	{
		id = "dz_h_erasure_day",
		title = "Four in the Afternoon",
		text = "The Claws come for Mrs. Oh's building at four in the afternoon, without a sound. You live next door, and the Head is thorough.",
		weight = 0,
		codex = "dz_lore_claws",
		choices = {
			{
				label = "Show them your papers",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A Claw's patience", coins = 2, base = 5, coinPower = 3, fixed = true },
				win = { sanity = -8, setFlags = { "dz_claw_witness" }, chronicle = "dz_act_claw_witness", log = "Lease, work permit, rent receipts, all in order. The Claw read every page, handed them back, and moved on." },
				lose = { health = { -18, -8 }, condition = "dz_maimed", log = "One stamp was out of date.", cause = "Erased over an out-of-date stamp" },
			},
			{
				label = "Out the back, now",
				hint = "Strength check.",
				clash = { stat = "strength", foe = "The Head's thoroughness", coins = 3, base = 7, coinPower = 3, fixed = true },
				win = { sanity = -10, setFlags = { "dz_claw_witness" }, chronicle = "dz_act_claw_witness", log = "You went over the back wall with nothing. When you looked back there was a gap in the street, and then there wasn't." },
				lose = { die = "Erased along with a Taboo next door", log = "You were halfway down the back stairs when the stairs stopped being there." },
			},
			{
				label = "Hide in the boiler room",
				hint = "Mental Strength check. Very bad odds.",
				clash = { stat = "mind", foe = "A long coat in the corridor", coins = 4, base = 9, coinPower = 4, fixed = true },
				win = { sanity = -12, setFlags = { "dz_claw_witness", "dz_unsurvivable" }, chronicle = "dz_act_claw_witness", log = "Footsteps stopped outside the boiler room door for exactly one minute, then went on. You came out at midnight into a building with half its tenants." },
				lose = { die = "Erased along with a Taboo next door", log = "The boiler room door opened." },
			},
			{ label = "Sit very still and wait", result = { sanity = -15, condition = "dz_terror", log = "They walked through your flat and out the other side without looking at you. You don't know why, and you never will." } },
		},
	},
	{
		id = "dz_h_eye_looks",
		title = "The Eye Looks Back",
		terms = { "The Head" },
		text = "A Nest tax letter: you underpaid last year by three Ahn. The letter is polite. The drone that has followed you for a week is polite too.",
		weight = 4,
		once = true,
		when = { minAge = 18, side = "nest" },
		codex = "dz_lore_claws",
		choices = {
			{ label = "Pay it, with interest", result = { money = { -90, -40 }, sanity = -2, log = "Three Ahn, plus the fine, plus the fee for the fine. The drone left that afternoon." } },
			{
				label = "Appeal it",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "Nest tax law", coins = 3, base = 6, coinPower = 3, fixed = true },
				win = { money = 12, charisma = 2, log = "You won, and got twelve Ahn back for their trouble. The clerk looked at you as if you'd done something brave." },
				lose = { money = { -300, -150 }, sanity = -6, condition = "dz_hunted", log = "You lost. The drone came back, and brought a friend." },
			},
			{ label = "Ignore it", result = { money = { -400, -200 }, sanity = -8, log = "Men in grey came to your door with a new figure and a very old rulebook." } },
		},
	},
}
