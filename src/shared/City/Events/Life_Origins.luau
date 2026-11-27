--[[
	Origins (area A): childhood and youth scenes for each origin's own life. Origins set flags
	in init.luau: foundling, fixer_blood, nest_born, lcorp_family, smoke_war_family,
	runaway_family, hongyuan_family. A single parent's life has a mother and no father; a
	Backstreets family has both. Weighted a little higher than the general childhood pool,
	since these scenes are what makes an origin feel like a different life.
]]

local ORIGIN_FLAGS = { "foundling", "fixer_blood", "smoke_war_family", "runaway_family", "hongyuan_family", "lcorp_family" }

return {
	-- ── a Fixer's kid ──────────────────────────────────────────────────────
	{
		id = "bs_o_fx_bad_job",
		title = "A Bad Job",
		text = "Your mother comes up the stairs from the Office at one in the morning holding her side, and sits down very carefully at the kitchen table. The job went wrong. It isn't finished, either: the client is expecting a report by nine, and a Fixer who misses a report loses the fee, and the grade.",
		weight = 18,
		once = true,
		when = { flags = { "fixer_blood" }, hasRelation = "mother", minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Help her clean and bind it",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "Shaking hands", coins = 1, base = 2, coinPower = 2 },
				win = { intelligence = 2, sanity = 1, log = "You boiled the water and held the lamp and wound the bandage exactly as she told you, tight but not too tight. She looked at your work and said, \"You'll be better at this than me.\" You weren't sure that was a good thing." },
				lose = { sanity = -2, intelligence = 1, log = "Your hands shook too much, and she finished it herself, one-handed, talking you through it so you'd know next time. There was a next time." },
			},
			{
				label = "Write the report while she dictates",
				result = { intelligence = 2, mind = 1, log = "She dictated and you wrote, in your best academy handwriting: date, client, contract number, what happened. You left out the part where she nearly died, because she told you to. The client paid in full." },
			},
			{
				label = "Run for the clinic doctor",
				hint = "Speed check: it's 1:10.",
				clash = { stat = "speed", foe = "The streets after one", coins = 1, base = 2, coinPower = 2 },
				win = { speed = 2, sanity = 2, log = "You ran for the clinic doctor, and she came, grumbling, with her bag. She stitched your mother at the kitchen table and was home herself by 2:30. Your mother was furious with you for going out. And proud." },
				lose = { sanity = -2, log = "The doctor wouldn't come out after one, and you came back empty-handed at quarter to two. Your mother pulled you inside, locked all three locks, and held on to you for a long time." },
			},
		},
	},
	{
		id = "bs_o_fx_first_contract",
		title = "Your First Contract",
		text = "Mrs. Szabo from across the street wants her cat found, and the Office is busy, so your father says it's yours: ten Ahn, a real job, your first. Before you can run out the door he stops you. \"Contract first,\" he says, handing you a sheet of paper. \"Always. No contract, no fee, no record.\"",
		weight = 16,
		once = true,
		when = { flags = { "fixer_blood" }, minAge = 9, maxAge = 13 },
		codex = "fixers_hana",
		choices = {
			{
				label = "Write the contract, then find the cat",
				hint = "Mental Strength check. The cat is clever.",
				clash = { stat = "mind", foe = "A clever cat", coins = 1, base = 2, coinPower = 2 },
				win = { wage = { 10, 15 }, mind = 2, setFlags = { "bs_first_contract" }, log = "You wrote the contract, got Mrs. Szabo's signature, and found the cat in the bakery's flour store, very white. Your father pinned your first contract up in the Office, next to the drawing of the sign." },
				lose = { mind = 1, setFlags = { "bs_first_contract" }, log = "You wrote a lovely contract and couldn't find the cat for three days. It came home on its own. Mrs. Szabo paid you anyway, \"for the paperwork,\" which your father said was the most Fixer thing that had ever happened." },
			},
			{
				label = "Skip the contract and just find it",
				result = { strength = 1, sanity = -1, log = "You found the cat in an hour. Mrs. Szabo said she'd never agreed to pay anything, and with no contract, she was right. Your father didn't say a word. He didn't have to." },
			},
		},
	},
	{
		id = "bs_o_fx_raid",
		title = "Office Raid",
		text = "A small Syndicate wants a name for itself, and the fastest way is to raid a Fixer Office. Tonight they've picked yours. Your parents are out on a job. Old Hyeon, the Office's only other Fixer, is seventy and has one good eye, and he's pushing a desk against the door. \"Ledger's in the safe,\" he says. \"Get it, or get behind something.\"",
		weight = 14,
		once = true,
		tags = { "danger" },
		when = { flags = { "fixer_blood" }, minAge = 12, maxAge = 17 },
		choices = {
			{
				label = "Hold the door with Hyeon",
				clash = { stat = "strength", foe = "Raiders at the Office door", coins = 2, base = 3, coinPower = 2, fight = true },
				win = { strength = 3, sanity = 2, setFlags = { "bs_held_the_office" }, log = "You and Old Hyeon held the door until the raiders decided a Hinge Office wasn't worth the trouble. When your parents came home they found the furniture broken and the two of you drinking tea on the stairs." },
				lose = { health = { -10, -4 }, sanity = -3, log = "They got through the door. Hyeon got you out the back window, and the raiders took the furniture and the sign. Your parents put the sign back up the next week, with your old drawing pinned under it.", cause = "Killed in an Office raid" },
			},
			{
				label = "Save the contract ledger",
				hint = "Mental Strength check: the safe, the code, and no time.",
				clash = { stat = "mind", foe = "A safe in the dark", coins = 1, base = 3, coinPower = 2 },
				win = { mind = 2, setFlags = { "bs_saved_ledger" }, log = "You got the safe open on the second try and went out the back with every contract the Office had ever signed. The raiders got furniture. The Office kept its clients, its record and its grade." },
				lose = { sanity = -2, log = "You couldn't remember the code. Hyeon opened it himself between swings and threw the ledger to you. You ran. It was the bravest thing you'd ever seen an old man do." },
			},
			{
				label = "Run for the neighborhood watch",
				result = { sanity = 1, speed = 1, log = "You went out the back and woke the whole street with the watch's whistle. A Syndicate raid with forty neighbors leaning out of their windows watching isn't much of a raid. They left." },
			},
		},
	},

	-- ── a veteran's child ──────────────────────────────────────────────────
	{
		id = "bs_o_vet_box",
		title = "The Box Under the Bed",
		text = "Your father is out, and the long metal box under his bed is open. You've never seen it open. Inside: a folded uniform with an insect stitched on the shoulder, three medals, a bundle of letters, and a rolled-up propaganda poster. A boy-soldier your age smiles out of it under the words THE FRONT NEEDS YOU.",
		weight = 18,
		once = true,
		when = { flags = { "smoke_war_family" }, minAge = 9, maxAge = 13 },
		codex = "bs_lore_smoke_war",
		choices = {
			{
				label = "Look at the poster for a long time",
				result = { mind = 2, sanity = -2, setFlags = { "bs_poster_face" }, schedule = { event = "bs_a_poster_face", inYears = 24 }, log = "You memorized the boy's face without meaning to: the chipped tooth, the cowlick, the smile someone had told him to smile. You rolled the poster up exactly as it had been. You never forgot that face." },
			},
			{
				label = "Read one of the letters",
				result = { mind = 1, sanity = -3, setFlags = { "bs_read_war_letter" }, log = "It was from your father to your grandmother, from the front. Most of it was about food. One line wasn't. You put it back and closed the box and sat on the bed until he came home." },
			},
			{
				label = "Close it without looking",
				result = { sanity = 2, setFlags = { "bs_vet_bond" }, log = "You closed it without looking and pushed it back under the bed. When your father came home, you told him it had been open. He looked at you for a long moment. \"Thank you,\" he said, and locked it." },
			},
		},
	},
	{
		id = "bs_o_vet_refused",
		title = "Refused",
		text = "After years of saving, your father has applied for Nest residence. He has the money, the papers, a clean record, and forty years of taxes paid. The letter comes on a Tuesday. REFUSED, it says, and one line underneath: applicant's record includes front-line service in the Smoke War.",
		weight = 16,
		once = true,
		when = { flags = { "smoke_war_family" }, hasRelation = "father", minAge = 8, maxAge = 14 },
		codex = "bs_lore_smoke_war",
		choices = {
			{
				label = "Sit with him",
				result = { sanity = 2, setFlags = { "bs_vet_bond" }, relationBond = { kind = "father", amount = 10 }, log = "You sat with {father} at the kitchen table until it got dark. He didn't say anything about the war. He said, \"Well, the Backstreets have better noodles,\" and you both laughed, and it nearly worked." },
			},
			{
				label = "Ask why the war still counts",
				result = { mind = 2, log = "\"Because it doesn't matter which side you were on,\" said {father}. \"Only that you were there. They want a City where nobody was there.\" He folded the letter into a very small square." },
			},
			{
				label = "Swear you'll get the family in yourself",
				result = { strength = 1, intelligence = 1, setFlags = { "bs_nest_dream" }, log = "You swore, at the table, that you'd get everyone through that wall someday. {father} looked at you sadly and didn't say what he was thinking, which was that he'd sworn the same thing once." },
			},
		},
	},
	{
		id = "bs_o_vet_flies",
		title = "Summer of Flies",
		text = "It's the hottest summer anyone can remember, and the flies are everywhere: in the markets, in the stairwells, buzzing against every window. Your father hasn't slept in a week. Last night he sat up in the kitchen with every light on and a rolled newspaper in his hand, very still, listening.",
		weight = 14,
		once = true,
		when = { flags = { "smoke_war_family" }, hasRelation = "father", minAge = 12, maxAge = 17 },
		choices = {
			{
				label = "Buy fly screens for every window",
				requires = { min = { money = 20 } },
				result = { money = -20, sanity = 3, relationBond = { kind = "father", amount = 8 }, log = "You spent your savings on fly screens and fitted them yourself. That night {father} slept for nine hours straight. In the morning he made you breakfast, which he hadn't done in years." },
			},
			{
				label = "Take him to the veterans' tea house",
				result = { mind = 2, sanity = 2, log = "There's a tea house behind the bathhouse where old men sit who don't talk about the war together. You walked {father} there. He came back at midnight, calmer than you'd seen him all summer, and never said a word about what they'd talked about." },
			},
			{
				label = "Sit up with him",
				result = { sanity = -1, health = 1, setFlags = { "bs_vet_bond" }, log = "You sat up with {father} in the kitchen with every light on, and swatted every fly before it reached him, until dawn. He didn't say thank you. He put his hand on your head on the way to bed, and kept it there a moment." },
			},
		},
	},

	-- ── runaways from the Court ────────────────────────────────────────────
	{
		id = "bs_o_run_headbands",
		title = "The Men With Headbands",
		text = "Two men in plain coats and painted headbands are going shop to shop down your street, showing an old drawing of a man and a woman. Ch'unokkun: Fixers from District 19's Court who hunt runaways. The faces in the drawing are your parents', twenty years younger. One of the men crouches down to your height. \"Have you seen these people?\"",
		weight = 18,
		once = true,
		tags = { "danger" },
		when = { flags = { "runaway_family" }, minAge = 6, maxAge = 11 },
		choices = {
			{
				label = "Shake your head and keep walking",
				hint = "Mental Strength check. Don't look at the drawing too long.",
				clash = { stat = "mind", foe = "A Ch'unokkun's eyes", coins = 1, base = 2, coinPower = 2 },
				win = { mind = 2, sanity = 1, log = "You looked at the drawing for exactly as long as a bored child would, shook your head, and walked on without hurrying. They moved on to the next shop. That night your parents held you for a very long time." },
				lose = { sanity = -3, setFlags = { "bs_chunokkun_close" }, log = "You looked at the drawing a moment too long. The man looked at you a moment too long back. That night your family moved, in the dark, to a room two streets away." },
			},
			{
				label = "Point them the wrong way",
				hint = "Intelligence check: tell a good lie.",
				clash = { stat = "intelligence", foe = "A Ch'unokkun's patience", coins = 1, base = 3, coinPower = 2 },
				win = { strength = 2, intelligence = 1, log = "You said you'd seen people like that at the docks, getting on a boat, and described the boat. They thanked you very politely and left for the docks. You were sick in an alley afterward, from fear, and very proud." },
				lose = { sanity = -3, setFlags = { "bs_chunokkun_close" }, log = "Your lie came out wrong. The man smiled, not kindly, and wrote something in a little book. Your family moved that night." },
			},
		},
	},
	{
		id = "bs_o_run_names",
		title = "Your Parents' Real Names",
		text = "Tonight, with the lamp very low, your parents tell you their real names: the ones the Court gave them, the ones on the Ch'unokkun's drawings. They served in the King's Court in District 19, in the Circle of Pi, the blood circle, where most of the Court's scientists and technicians work. They ran. They don't say from what.",
		weight = 16,
		once = true,
		when = { flags = { "runaway_family" }, minAge = 9, maxAge = 14 },
		choices = {
			{
				label = "Ask what they ran from",
				result = { mind = 2, sanity = -2, setFlags = { "bs_knows_court" }, log = "Your mother said, \"From being told what to make, and who to make it for.\" Your father said nothing. The lamp guttered. You understood that it was all they would ever tell you." },
			},
			{
				label = "Promise to keep the names secret",
				result = { mind = 1, sanity = 2, setFlags = { "bs_knows_court" }, log = "You promised. You never said those names aloud in your whole life, not once. Sometimes you whispered them into your pillow, so that somebody in the City still said them." },
			},
			{
				label = "Ask about the Court",
				result = { intelligence = 2, setFlags = { "bs_knows_court" }, log = "They told you about the three Circles, flesh, blood and bone, always at each other's throats, and the King above them, and the retainers who were never sure from one day to the next which of them was in favor. It sounded like a story. It wasn't." },
			},
		},
	},
	{
		id = "bs_o_run_list",
		title = "Your Name on a List",
		text = "An old woman from the Court who ran years before your parents comes to your door at midnight, out of breath. The Ch'unokkun have a new list, she says, and this time it has the runaways' children on it too. Your name. She has a cousin with a room in another District, and a WARP ticket she can't use.",
		weight = 14,
		once = true,
		tags = { "danger" },
		when = { flags = { "runaway_family" }, district = "d19", minAge = 14, maxAge = 18 },
		choices = {
			{
				label = "Take the ticket and go",
				result = { district = "d4", sanity = -3, setFlags = { "bs_fled_court" }, log = "You took the WARP ticket and the cousin's address in District 4. Your parents packed you a bag in silence. The train took ten seconds. You stood on the platform on the other side and felt, for the first time in your life, like nobody was looking for you." },
			},
			{
				label = "Stay, and get better at hiding",
				result = { mind = 3, sanity = -2, log = "You stayed. You learned to change your walk, your hair, the way you said your vowels. The Ch'unokkun walked past you twice that year and didn't look twice." },
			},
		},
	},

	-- ── a Hongyuan family ──────────────────────────────────────────────────
	{
		id = "bs_o_hy_corridor",
		title = "The Corridor Moved",
		text = "You went to the market three corridors from home, and when you came back the corridors had changed: Hongyuan rearranges itself, and today it rearranged you right out of your neighborhood. A Heishou Pack guard is standing at the junction, a young woman with long, soft ears that twitch at every sound. She's watching you try not to cry.",
		weight = 18,
		once = true,
		when = { flags = { "hongyuan_family" }, district = "d8", minAge = 5, maxAge = 10 },
		codex = "bs_lore_hongyuan_rooms",
		choices = {
			{
				label = "Ask the Heishou for help",
				result = { sanity = 3, setFlags = { "bs_met_heishou" }, log = "She crouched down and asked your family's room number, and her ears turned toward the right corridor before she did. She walked you home and said, \"Directions by landmark, not by turning. The turnings move.\" You never got lost again." },
			},
			{
				label = "Find your way by the landmarks Grandmother taught you",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A building that moves", coins = 1, base = 2, coinPower = 2 },
				win = { mind = 2, sanity = 2, log = "The red lantern, the tea shop with the bird, the stair that smells of ginger. You followed your grandmother's landmarks home, and she was so proud she told the whole floor." },
				lose = { sanity = -2, log = "The landmarks had moved too. You wandered for hours until a neighbor found you and walked you home. Your grandmother taught you new landmarks that night, the ones that never move." },
			},
		},
	},
	{
		id = "bs_o_hy_walls_ran",
		title = "The Walls Ran Away",
		text = "Your mother got a promotion. You find out the Hongyuan way: you wake up in the middle of the night because your bed is suddenly a long way from the wall. The room has grown. There's a new window. There's a whole new corner, empty and gleaming, that nobody has ever stood in.",
		weight = 16,
		once = true,
		when = { flags = { "hongyuan_family" }, district = "d8", minAge = 7, maxAge = 13 },
		codex = "bs_lore_hongyuan_rooms",
		choices = {
			{
				label = "Claim the new corner",
				result = { sanity = 4, log = "You dragged your blanket and your treasures into the new corner and declared it yours. Nobody argued. It was the first thing in your life that was only yours." },
			},
			{
				label = "Worry it will shrink again",
				result = { mind = 2, intelligence = 1, setFlags = { "bs_saver" }, log = "You didn't sleep in the new corner. You started saving your pocket money instead, in a jar, so the walls would never come back. Your grandmother called it \"guarding the room.\"" },
			},
		},
	},
	{
		id = "bs_o_hy_bolus",
		title = "A Bolus Stall",
		text = "A stall in the corridor market sells cheap, unlicensed Boluses, H Corp's body-changing medicine: one week of cat's whiskers, a month of fox ears, \"a tail for festival season.\" Half the kids in your corridor have tried one. The stallholder holds up a little green pill and winks. \"Five Ahn. Wears off. Probably.\"",
		weight = 14,
		once = true,
		when = { district = "d8", minAge = 12, maxAge = 17 },
		choices = {
			{
				label = "Try the fox ears",
				requires = { min = { money = 5 } },
				result = { money = -5, sanity = 3, log = "You had fox ears for a month. They were wonderful. You could hear the corridors moving at night, a long low grinding like a sleeping animal. When they faded, you missed that sound." },
			},
			{
				label = "Ask what \"probably\" means",
				result = { mind = 2, log = "\"Means mostly,\" said the stallholder, and showed you his left hand, which had a very small, very neat set of claws. \"Mostly is good odds in Hongyuan.\" You kept your five Ahn." },
			},
		},
	},

	-- ── an L Corp family, while the tower stands ───────────────────────────
	{
		id = "bs_o_lc_drill",
		title = "Siren Drill",
		text = "Every school in District 12 practices for the L Corp sirens: when they go, shutters down, everyone under the desks, nobody near a window, nobody leaves until the all-clear. Today it's a drill. Probably. The teacher's hands are shaking as she pulls the shutters, which they don't usually do in drills.",
		weight = 16,
		once = true,
		when = { district = "d12", world = { era = "wings" }, minAge = 6, maxAge = 11 },
		choices = {
			{
				label = "Help the little ones under the desks",
				result = { sanity = 2, mind = 1, log = "You got the three youngest kids under the big desk and told them a story about a cat until the all-clear. It was only a drill. The teacher said so twice, and the second time she cried." },
			},
			{
				label = "Peek through the gap in the shutters",
				result = { sanity = -3, mind = 1, log = "Through the gap: the street, empty, and far off, the L Corp tower, and a green light along its base you'd never seen before. Then the all-clear. Nobody ever said what the light was." },
			},
			{
				label = "Count the seconds until the all-clear",
				result = { intelligence = 2, log = "Eleven minutes and forty seconds. You told your parents at dinner. They looked at each other, and your father said, \"Good. That's a good number,\" and nobody explained." },
			},
		},
	},
	{
		id = "bs_o_lc_badge",
		title = "The Badge in the Drawer",
		text = "Looking for string in your parents' drawer, you find a Lobotomy Corporation badge that isn't theirs: a stranger's photo, a stranger's name, a department name you've never heard. Under it is a folded note in your mother's handwriting: \"Didn't come back. Kept it so somebody remembers.\"",
		weight = 16,
		once = true,
		when = { flags = { "lcorp_family" }, world = { era = "wings" }, minAge = 9, maxAge = 13 },
		choices = {
			{
				label = "Put it back exactly as it was",
				result = { mind = 2, sanity = -1, log = "You put it back exactly as it was and never mentioned it. But you learned the stranger's name, and sometimes you said it to yourself, so there'd be two people remembering." },
			},
			{
				label = "Ask your mother about them",
				requires = { hasRelation = "mother" },
				result = { sanity = 1, mind = 1, relationBond = { kind = "mother", amount = 8 }, log = "Your mother was quiet for a long time. Then she told you the stranger had made the best tea in the department and was afraid of cats. That was all she could tell you. It was enough to make them real." },
			},
		},
	},
	{
		id = "bs_o_lc_promise",
		title = "Hiring Season",
		text = "L Corp is hiring again. The posters are everywhere in District 12: good pay, a badge, a future, \"Face the Fear, Build the Future.\" Half your class is talking about applying the day they turn eighteen. At dinner, your parents put their chopsticks down at the same time and ask you to promise them something.",
		weight = 16,
		once = true,
		when = { flags = { "lcorp_family" }, world = { era = "wings" }, minAge = 14, maxAge = 17 },
		choices = {
			{
				label = "Promise you'll never apply",
				result = { sanity = 2, setFlags = { "bs_promised_no_lcorp" }, log = "You promised. They both let out a breath you hadn't known they were holding. Nobody said why. Nobody needed to." },
			},
			{
				label = "Ask them what they actually do there",
				result = { mind = 2, sanity = -2, log = "\"We keep the lights on,\" said your mother. \"For the whole City.\" Your father added, \"And we come home.\" He said it like a thing you have to say every day to make sure it stays true." },
			},
			{
				label = "Say it's your choice to make",
				result = { strength = 2, sanity = -1, log = "You said it was your choice. They looked at each other, and your mother said, \"It is.\" Then she got up and washed the dishes for a very long time." },
			},
		},
	},

	-- ── a foundling ────────────────────────────────────────────────────────
	{
		id = "bs_o_fd_house",
		title = "The Foundling House",
		text = "The foundling house is fourteen children, two rooms, one tired matron and a bell that rings at half past two every night, whether you're asleep or not, so nobody ever forgets. Matron Hesketh has a voice like a slammed door and has never once let a child be outside after three. Tonight she needs someone to help with the little ones.",
		weight = 18,
		once = true,
		when = { flags = { "foundling" }, minAge = 5, maxAge = 10 },
		choices = {
			{
				label = "Help put the little ones to bed",
				result = { intelligence = 2, sanity = 2, setFlags = { "bs_matron_helper" }, log = "You tucked in six small children and told them the rule the way the matron did: three locks, home before three, nobody gets left. Matron Hesketh watched from the door and said nothing, and gave you an extra blanket that winter." },
			},
			{
				label = "Make friends with the new kid",
				result = { sanity = 3, addRelation = { kind = "friend", name = "Pell", bond = 60, age = { 5, 9 } }, log = "The new kid, Pell, had arrived that morning with nothing but a shoe. You gave him your spare sock. You were best friends for the rest of your time in the foundling house, and wrote to each other for years after." },
			},
			{
				label = "Sneak out to see the street at two",
				result = { strength = 1, sanity = -2, log = "You slipped out at two to see what the street looked like at night. Matron Hesketh was waiting on the step when you came back at 2:20. She didn't shout. She just looked at the clock, and at you, and you never did it again." },
			},
		},
	},
	{
		id = "bs_o_fd_visiting_day",
		title = "Visiting Day",
		text = "Once a season, people come to the foundling house to take a child home. Today there's a big woman in a stained apron who smells of noodle broth and looks like she'd rather be anywhere else. She runs a stall nearby, the matron says. She keeps looking at you. \"That one,\" she says. \"The one who looks hungry.\"",
		weight = 16,
		once = true,
		when = { flags = { "foundling" }, minAge = 7, maxAge = 12 },
		choices = {
			{
				label = "Smile your best smile",
				hint = "Charisma check.",
				clash = { stat = "charisma", foe = "A very stern noodle cook", coins = 1, base = 2, coinPower = 2 },
				win = {
					sanity = 6,
					setFlags = { "bs_adopted_by_mun", "bs_knows_mun" },
					addRelation = { kind = "mother", name = "Mun", bond = 65, age = { 44, 50 } },
					log = "You smiled. She did not smile back. She said, \"Fine,\" and signed the papers, and took you home to a room above Auntie Mun's noodle stall, where you were fed every single day for the rest of your childhood. She never once said she loved you. She left the best bowl for you every night.",
				},
				lose = { sanity = -3, setFlags = { "bs_knows_mun" }, log = "Your smile came out wrong. She took another child home that day. But she came back to the foundling house every week after, with a pot of broth, and always gave you the first bowl." },
			},
			{
				label = "Tell her you're fine where you are",
				result = { strength = 1, health = 1, setFlags = { "bs_knows_mun" }, log = "You said you were fine. She snorted, and said, \"You're not, but you're honest.\" She came back every week with broth anyway, and you always got the first bowl." },
			},
		},
	},
	{
		id = "bs_o_fd_crest",
		title = "The Crest on the Collar",
		text = "You're old enough now to go looking. The coat you were found in still has its crest: a key inside a circle, stamped in old metal. Somebody, somewhere, wore this crest on purpose. Maybe a Fixer Office. Maybe someone who left you on that step, after a Night, and never came back.",
		weight = 18,
		once = true,
		when = { flags = { "foundling", "bs_coat_kept" }, minAge = 14, maxAge = 22 },
		choices = {
			{
				label = "Start asking the old Fixers",
				result = { mind = 1, quest = "bs_q_coat", log = "You decided to find out. You started with the oldest Fixers on the street, the ones who sit outside their Offices in the afternoon. You took the coat with you." },
			},
			{
				label = "Wear the coat, and let it be",
				result = { sanity = 3, log = "You decided you didn't need to know. You wore the coat that winter, and it fit, finally, and that was its own answer." },
			},
		},
	},

	-- ── a single parent ────────────────────────────────────────────────────
	{
		id = "bs_o_sp_double_shift",
		title = "2:50",
		text = "{mother} came home from her double shift at half past two and sat down at the kitchen table to take her shoes off, and fell asleep with one shoe on. It's 2:50. The front door has three locks. Only one of them is locked.",
		weight = 18,
		once = true,
		when = { side = "backstreets", hasRelation = "mother", noRelation = "father", notFlags = ORIGIN_FLAGS, minAge = 6, maxAge = 11 },
		choices = {
			{
				label = "Do the locks yourself",
				result = { mind = 2, sanity = 2, setFlags = { "bs_lock_turner" }, log = "You climbed on a chair and did the other two locks, in the right order, the way she did. Then you put a blanket over her. When she woke up at dawn she checked the locks, then looked at you for a long time, and then she cried a little and made you pancakes." },
			},
			{
				label = "Wake her up",
				result = { sanity = 1, relationBond = { kind = "mother", amount = 6 }, log = "You shook her awake and pointed at the door. She was up in a second, locking, checking, locking again, and then she sat down on the floor and pulled you into her lap and said she was sorry, over and over, which you didn't understand, because she hadn't done anything wrong." },
			},
		},
	},
	{
		id = "bs_o_sp_cough",
		title = "Mother's Cough",
		text = "{mother}'s cough has been getting worse all winter. She says it's the laundry steam, and nothing, and to stop fussing. The clinic would cost a week's wages. She won't go. Last night you heard her coughing in the kitchen at three in the morning, very quietly, so as not to wake you.",
		weight = 16,
		once = true,
		when = { side = "backstreets", hasRelation = "mother", noRelation = "father", notFlags = ORIGIN_FLAGS, minAge = 11, maxAge = 17 },
		choices = {
			{
				label = "Pay for the clinic out of your own savings",
				requires = { min = { money = 30 } },
				result = { money = -30, sanity = 4, relationBond = { kind = "mother", amount = 10 }, log = "You took her to the clinic and paid before she could argue. The doctor gave her a tonic and a lecture about laundry steam. By spring the cough was gone. She never mentioned the money. She mentioned you to everyone." },
			},
			{
				label = "Take extra work so she can cut a shift",
				result = { health = -2, wage = { 15, 30 }, sanity = 2, log = "You took every odd job on the street that winter so she could drop her second shift. She slept more. The cough eased. You were tired all the time, and you didn't mind." },
			},
			{
				label = "Make her the cook's ginger broth every night",
				requires = { flags = { "bs_knows_mun" } },
				result = { intelligence = 1, sanity = 3, log = "Auntie Mun taught you her ginger broth and wouldn't take a single Ahn for it. You made it every night. By spring the cough was gone, and your mother said it was the broth, and Auntie Mun said it was the care." },
			},
		},
	},

	-- ── a Backstreets family ───────────────────────────────────────────────
	{
		id = "bs_o_bf_laid_off",
		title = "Laid Off",
		text = "{father} worked twelve years for a Workshop that made parts for a Wing contractor. This morning the contractor cancelled the order, and by noon the Workshop had let half its people go. He comes home in the middle of the afternoon, which he has never done, and sits on the step outside instead of coming in.",
		weight = 14,
		once = true,
		when = { side = "backstreets", hasRelation = "father", notFlags = ORIGIN_FLAGS, minAge = 8, maxAge = 15 },
		choices = {
			{
				label = "Sit on the step with him",
				result = { sanity = 2, relationBond = { kind = "father", amount = 8 }, log = "You sat on the step with him and didn't say anything, and after a while he started telling you about the first part he ever made at that Workshop, a hinge, and how proud he'd been. He found work again in the spring." },
			},
			{
				label = "Find odd jobs to help out",
				result = { wage = { 10, 25 }, health = 1, log = "You found work carrying crates at the market every morning before school and put the Ahn on the kitchen table every evening. Nobody said anything about it. Everybody ate." },
			},
			{
				label = "Ask why the Wing gets to decide",
				result = { mind = 2, codex = "bs_lore_feathers", log = "\"Because the Wing owns the District,\" {father} said, \"and the District owns the contractor, and the contractor owned my job.\" He laughed, tiredly. \"Everyone in the City works for a Wing in the end. Most of us just don't get the badge.\"" },
			},
		},
	},
}
