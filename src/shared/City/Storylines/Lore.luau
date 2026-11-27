--[[
	Storylines grounded in how the City works (docs/CANON.md). Each one is built on something
	a fan would recognise as true of the setting:
	  Feather Fall   a Wing employee who is dismissed loses the Nest with the job
	  Courtesy       the Thumb collects from small shops, and cares about manners above all
	  Borrowed Coat  Fixers, Offices, Hana's register, and what a finished job costs
	  The Voice      after the White Nights, people at the brink hear a kind voice (born after 964)
	  The Prescript  the Index carries out orders nobody admits to writing
	Format: Storylines/Core.luau. Beats: Events/Story_Lore1.luau, Story_Lore2.luau.
]]

return {
	{
		id = "sl_feather_fall",
		name = "Feather Fall",
		hook = "Your family lives inside the walls because of a badge on a hook by the door. A Wing can take a badge back.",
		tone = "tragic",
		weight = 12,
		when = { side = "nest", hasRelation = { "mother", "father" } },
		goal = "Grow up inside the walls. Don't touch the badge.",
		cantos = {
			[2] = "The badge on the hook says Class 3. Everything you have hangs on it.",
			[3] = "Three days' notice. One bag each.",
			[4] = "The only way back in is the Wing's own exam.",
			[5] = "Walls have two sides.",
		},
	},
	{
		id = "sl_courtesy",
		name = "Courtesy",
		hook = "Your mother's diner pays the Thumb on the first of every month. The man who collects has decided to teach you manners.",
		tone = "grim",
		weight = 12,
		when = { side = "backstreets", hasRelation = "mother", noRelation = "father" },
		goal = "Learn to bow the way your mother does.",
		cantos = {
			[2] = "A man in a pressed suit eats at the counter. He never pays.",
			[3] = "In the Thumb, the spoon would matter.",
			[4] = "They don't make an offer twice.",
			[5] = "Manners are what you owe.",
		},
	},
	{
		id = "sl_coat",
		name = "Borrowed Coat",
		hook = "You were left at a foundling house door wrapped in a Fixer's coat. Nobody ever came back for the coat.",
		tone = "hopeful",
		weight = 14,
		when = { noRelation = { "mother", "father" } },
		goal = "Keep the coat. It's the only thing that came with you.",
		cantos = {
			[2] = "There's a brass tag in the collar, with a number on it.",
			[3] = "Hana keeps a register of every license. It doesn't give out names.",
			[4] = "The last job on the board was you.",
			[5] = "It fits now.",
		},
	},
	{
		id = "sl_voice",
		name = "The Voice",
		hook = "Your mother gave up everything she wanted so you could eat. One day something kind will tell her she can have it back.",
		tone = "tragic",
		weight = 16,
		when = { minYear = 965, hasRelation = "mother" },
		goal = "Your mother stops singing at the same line every time.",
		cantos = {
			[2] = "For three days nobody on your street was afraid.",
			[3] = "She's talking to someone in the kitchen. There's nobody there.",
			[4] = "They get calm first.",
			[5] = "Somebody has to finish the song.",
		},
	},
	{
		id = "sl_prescript",
		name = "The Prescript",
		hook = "Slips of paper come under your family's door. Each one says exactly what to do. So far they've been small.",
		tone = "strange",
		weight = 9,
		when = { side = "backstreets" },
		goal = "Do what the paper says.",
		cantos = {
			[2] = "The first one addressed to you asks for your bread.",
			[3] = "A Messenger reads them aloud now, to be sure.",
			[4] = "The next one could ask for anything.",
			[5] = "Nobody knows who writes them.",
		},
	},
}
