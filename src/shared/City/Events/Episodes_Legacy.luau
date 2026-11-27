--[[
	LEGACY (v0.13): the late part of a life, when what you leave matters more than what you
	take. Two episodes (the last contract, an apprentice) and the deeds of a long life: a seat
	at the table, an endowment for the District, memoirs, and handing over the keys.
	Canon: Hana grades Fixers and calls the Offices together; Associations and Offices train
	the next generation [LoR, Limbus]. Everyone here is this game's own.
]]

local function check(stat: string, foe: string, base: number?)
	return { stat = stat, foe = foe, coins = 2, base = base or 4, coinPower = 3 }
end

return {
	-- ══ The Last Contract ═════════════════════════════════════════════════════
	{
		id = "ep_lc_1",
		episode = "ep_last_contract",
		step = 1,
		title = "A Contract for the Old",
		scene = { set = "room", kicker = "Your door", other = { name = "A Hana clerk", role = "with a grey folder", age = 40 }, line = "\"You don't have to. Nobody would think less of you.\"" },
		text = "Hana keeps a short list of contracts it only offers to Fixers who have lived long enough to have nothing left to prove. A clerk brings one to your door in person, in a grey folder with no name on it. \"You don't have to,\" the clerk says. \"Nobody would think less of you.\" The folder is very thin. The fee is very large.",
		weight = 4,
		once = true,
		rare = true,
		tags = { "fixers", "danger" },
		when = { minAge = 56, flags = { "licensed_fixer" } },
		choices = {
			{ label = "Open the folder", result = { trigger = "ep_lc_2", log = "One page. A place, a time, and a single word where the target's name should be: Unresolved." } },
			{ label = "Send it back unopened", result = { sanity = 4, episodeEnd = "You sent the last contract back unopened. Hana understood.", log = "You sent it back unopened. A week later Hana sent a card thanking you for your years of service, signed by someone very senior." } },
		},
	},
	{
		id = "ep_lc_2",
		episode = "ep_last_contract",
		step = 2,
		title = "Unresolved",
		text = "The place is a warehouse at the edge of the District that three Offices have gone into this year and none have come out of in one piece. Whatever is inside has been there a long time and has learned from every Fixer who tried. Your knees hurt on the stairs. Your hands don't shake at all.",
		weight = 0,
		tags = { "fixers", "danger" },
		choices = {
			{
				label = "Do it the way you always have",
				clash = { stat = "strength", foe = "The last job", enemy = "fixer", fight = true, coins = 4, base = 10, coinPower = 5 },
				win = { money = { 3000, 6000 }, renown = 30, trigger = "ep_lc_3", log = "It took the whole night and everything you knew. In the morning the warehouse was quiet, and you walked out of it on your own feet." },
				lose = { health = { -40, -20 }, sanity = -8, cause = "The last contract", episodeEnd = "The last contract was one too many. You came out, and never went back to work.", log = "You came out of it, which is more than the other three Offices managed, and you never took another job." },
			},
			{
				label = "Do it with everything you've learned",
				hint = "Clever, slow, patient. Intelligence.",
				clash = { stat = "intelligence", foe = "Something that learned from every Fixer before you", coins = 3, base = 9, coinPower = 4 },
				win = { money = { 3000, 6000 }, renown = 26, intelligence = 2, trigger = "ep_lc_3", log = "You didn't fight it. You waited, and watched, and found the one thing three Offices missed. It was over before dawn." },
				lose = { health = { -30, -14 }, sanity = -10, cause = "The last contract", episodeEnd = "The last contract was one too many. You came out, and never went back to work.", log = "It had learned from Fixers who thought the way you think, too. You got out. You didn't take another job." },
			},
		},
	},
	{
		id = "ep_lc_3",
		episode = "ep_last_contract",
		step = 3,
		title = "After",
		text = "Hana stamps the contract RESOLVED. Your name goes on the board for a week, and Fixers a third your age stop you in the street to shake your hand. There's an envelope from Hana, too, with one question on a card inside: are you done?",
		weight = 0,
		rare = true,
		tags = { "fixers" },
		choices = {
			{ label = "Hang up the coat", result = { sanity = 10, setFlags = { "retired_fixer" }, quitCareer = true, episodeEnd = "You finished on the last contract, and hung up the coat for good.", log = "You hung the coat on a hook by the door and didn't take it down again. Some mornings you look at it with your tea." } },
			{ label = "Not yet", hint = "The body is old. The limits aren't.", result = { limitBreak = { all = 5 }, mind = 2, episodeEnd = "You told Hana you weren't done. Hana believed you.", log = "You wrote NOT YET on the card and sent it back. Hana took you off the short list, and put you on a shorter one." } },
		},
	},

	-- ══ An Apprentice ═════════════════════════════════════════════════════════
	{
		id = "ep_ap_1",
		episode = "ep_apprentice",
		step = 1,
		title = "Someone at the Door",
		scene = { set = "stairs", kicker = "Your door", other = { name = "A young hopeful", role = "with a letter of reference", age = 17 }, line = "\"I want to learn. From you.\"" },
		text = "A young person of about seventeen is waiting at your door, holding a letter of reference from someone who owes you a favor. \"I want to learn,\" the newcomer says. \"From you. Not from an Association, not from a Section. From you.\"",
		weight = 4,
		once = true,
		tags = { "people" },
		when = { minAge = 45, renown = 3 },
		choices = {
			{ label = "Take them on", result = { addRelation = { kind = "apprentice", age = 17, bond = 45 }, schedule = { event = "ep_ap_2", inYears = 2 }, log = "You said yes before you'd thought about it, which is how you knew it was right. Your apprentice moved into the spare room with one bag and a very old sword." } },
			{ label = "Send them to an Association", result = { rep = { fixers = 2 }, episodeEnd = "You sent the young hopeful to an Association, with a good word.", log = "You wrote them a letter to an Association you respect. Years later you saw the name on a grade list, quite high up." } },
		},
	},
	{
		id = "ep_ap_2",
		episode = "ep_apprentice",
		step = 2,
		when = { hasRelation = "apprentice" },
		title = "The First Real Job",
		text = "Two years in, your apprentice, {apprentice}, has a first real job: a Syndicate debt collection that might turn into a fight, and probably will. {apprentice} asks you not to come. You can see in their face that they half mean it.",
		weight = 0,
		tags = { "people" },
		choices = {
			{ label = "Let {apprentice} go alone", clash = check("mind", "Waiting by the door", 5), win = { relationBond = { kind = "apprentice", amount = 12 }, mind = 1, schedule = { event = "ep_ap_3", inYears = 3 }, log = "You waited by the door all night. {apprentice} came home at dawn, bruised and grinning, with the whole debt." }, lose = { relationBond = { kind = "apprentice", amount = 4 }, sanity = -4, schedule = { event = "ep_ap_3", inYears = 3 }, log = "{apprentice} came home with half the debt and a broken wrist, and wouldn't look at you for a week. Then asked for the next one." } },
			{ label = "Follow, and stay out of sight", result = { relationBond = { kind = "apprentice", amount = 6 }, speed = 1, schedule = { event = "ep_ap_3", inYears = 3 }, log = "You followed at a distance and only stepped in once. {apprentice} pretended not to notice, and thanked you at dinner." } },
			{ label = "Go together", result = { relationBond = { kind = "apprentice", amount = 8 }, strength = 1, schedule = { event = "ep_ap_3", inYears = 3 }, log = "You went together. {apprentice} did most of it. You did the part where people decide not to argue." } },
		},
	},
	{
		id = "ep_ap_3",
		episode = "ep_apprentice",
		step = 3,
		when = { hasRelation = "apprentice" },
		title = "Better Than You Were",
		text = "{apprentice} took a grade from Hana this spring, a better one than you had at that age. Tonight {apprentice} sits across your kitchen table with a cup going cold and says, \"I want to carry it on. Your name, your work. If you'll let me.\"",
		weight = 0,
		rare = true,
		tags = { "people" },
		choices = {
			{ label = "Hand over the keys", result = { renown = 10, sanity = 8, setFlags = { "apprentice_heir" }, relationBond = { kind = "apprentice", amount = 15 }, episodeEnd = "Your apprentice carries your name on now.", log = "You gave {apprentice} the keys, and the sword, and the ledger, and the worst of your stories. Your name will go on a while after you." } },
			{ label = "Tell {apprentice} to make their own name", result = { charisma = 2, sanity = 6, relationBond = { kind = "apprentice", amount = 10 }, episodeEnd = "Your apprentice went off to make a name of their own.", log = "\"Make your own,\" you said. \"Mine's got too many debts in it.\" {apprentice} laughed, and cried, and did." } },
		},
	},

	-- ══ the deeds of a long life (single cards) ═══════════════════════════════
	{
		id = "lg_seat_table",
		title = "A Seat at the Table",
		text = "Hana is calling the District's Offices together, and for the first time the invitation has your name on it: not to stand at the back, but to sit at the table, where the District's future gets argued over bad coffee in the mornings. Everyone at the table has a vote, and an Office behind it.",
		weight = 3,
		once = true,
		rare = true,
		tags = { "fixers" },
		when = { minAge = 40, renown = 5 },
		choices = {
			{ label = "Speak for the Backstreets", clash = check("charisma", "A table of people who all want something", 7), win = { renown = 12, impact = { kind = "safety", amount = 2, text = "{name} spoke for the Backstreets at Hana's table." }, rep = { fixers = 6 }, log = "You talked about the Backstreets the way people who live there talk about them. Two Offices changed their vote. The District will be a little safer for it." }, lose = { renown = 4, sanity = -3, log = "You spoke well, and lost the vote by one. Afterward three Fixers you didn't know shook your hand." } },
			{ label = "Speak for the Offices", result = { renown = 8, money = { 600, 1200 }, rep = { fixers = 10 }, log = "You argued for the Offices, and won, and the Offices remembered who won it for them." } },
			{ label = "Listen, and say nothing", result = { intelligence = 2, mind = 1, log = "You said nothing all morning and learned more about how the District really works than in thirty years of living in it." } },
		},
	},
	{
		id = "lg_endowment",
		title = "An Endowment",
		text = "You have more Ahn than one life needs, and the District has a clinic that turns people away at night, an academy with no roof on its east wing, and a soup kitchen that runs out by noon. A clerk from the District office has drawn up the papers. All it needs is a name, and a number.",
		weight = 3,
		once = true,
		tags = { "money" },
		when = { minAge = 50, min = { money = 20000 } },
		choices = {
			{ label = "Fund the night clinic", result = { money = -12000, renown = 15, sanity = 6, impact = { kind = "safety", amount = 2, text = "{name} paid for a night clinic in {district}." }, setFlags = { "endowed_clinic" }, log = "The night clinic has your name over its door now. On the first night it stayed open, it turned nobody away." } },
			{ label = "Put a roof on the academy", result = { money = -10000, renown = 12, sanity = 5, impact = { kind = "prosperity", amount = 2, text = "{name} put a roof on the academy in {district}." }, setFlags = { "endowed_academy" }, log = "The academy's east wing has a roof, and a plaque, and two hundred more children in it every morning." } },
			{ label = "Keep it for the family", result = { sanity = 1, log = "You put the papers in a drawer. The money stays where it is, for whoever comes after you." } },
		},
	},
	{
		id = "lg_memoirs",
		title = "Memoirs",
		text = "A small press in the Nest wants your memoirs. They've offered good money and an editor who doesn't flinch. You've been writing in the evenings anyway, mostly the parts you'd never say out loud.",
		weight = 3,
		once = true,
		tags = { "self" },
		when = { minAge = 62, renown = 3 },
		choices = {
			{ label = "Tell all of it", result = { money = { 1500, 3000 }, renown = 10, sanity = 4, log = "It sold well, and badly in the places that mattered: three people you wrote about stopped speaking to you, and a dozen strangers wrote to say thank you." } },
			{ label = "Tell the good parts", result = { money = { 800, 1600 }, renown = 6, sanity = 6, log = "It's a kind book. People give it as a gift. You're prouder of it than you thought you'd be." } },
			{ label = "Burn the pages", result = { sanity = 8, mind = 2, log = "You burned them in the kitchen sink one page at a time. Some things are only yours." } },
		},
	},
}
