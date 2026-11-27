--[[
	Side quests of the Library and Distortion eras. Writer D (lib_ / lim_ ids).
	  lib_q_book_home   started when someone you love becomes a book (the vigils in
	                    Events/Library_Era.luau); ends when you bring their book home.
	  lim_q_inflection  started by Ezra's offer (lim_lcd_offer); an OSIR case on your block.
	Quest activities: Activities/Limbus.luau.
]]

return {
	order = { "lib_q_book_home", "lim_q_inflection" },

	lib_q_book_home = {
		name = "Bring Them Home",
		desc = "Someone you love went into the Library and became a book. Books travel: winners carry them out, sellers sell them on. Somewhere in the City, theirs is waiting.",
		giver = "Yourself",
		expires = 12,
		steps = {
			{
				text = "Search the book markets for their name.",
				hint = "Activities: Search the book markets",
				onStart = { setFlags = { "lib_q_searching" } },
				check = { when = { flags = { "lib_q_clue" } } },
				doneLog = "A Bookhunter at a District 12 stall remembers the name. The book changed hands last month. It's still in the City.",
			},
			{
				text = "Wait for the book to surface, and bring it home.",
				hint = "A seller will turn up. Have Ahn ready, or nerve.",
				check = { when = { flags = { "lib_found_their_book" } } },
				doneLog = "Their book is home, on the shelf by the window.",
			},
		},
		reward = { sanity = 6, mind = 2, log = "You brought them home. You don't read the book. Some evenings you sit next to it and tell it about your day, and that's enough." },
	},

	lim_q_inflection = {
		name = "The Missing Hour",
		desc = "A block in the Backstreets loses the same hour every night: the clocks jump, and nobody remembers it. The LCD's OSIR Team wants a local to help find the Inflection Point before it spreads.",
		giver = "Ezra, OSIR Team",
		expires = 6,
		steps = {
			{
				text = "Knock on doors on the block where the hour goes missing.",
				hint = "Activities: Knock on doors for the OSIR Team",
				onStart = { setFlags = { "lim_qi_open" } },
				check = { when = { flags = { "lim_qi_heard" } } },
				doneLog = "Everyone on the block started losing the hour on the same night: the night the late radio show they all listened to went off the air for good.",
			},
			{
				text = "Walk the block at 3:12, one minute before the Night, and see where the hour goes.",
				hint = "Activities: Walk the block at 3:12",
				onStart = { setFlags = { "lim_qi_walk" } },
				check = { when = { flags = { "lim_qi_found" } } },
				doneLog = "At 3:12 every radio on the block crackled on by itself, tuned to a dead station. Ezra wrote it down: Inflection Point found.",
			},
		},
		reward = { mind = 3, sanity = 4, addTrait = "lim_talks_them_down", setFlags = { "lim_talked_down", "lim_distortion_survivor" }, chronicle = "lim_talked_down", log = "You found the old radio host in a room above a laundry, not sleeping, talking to a microphone that wasn't plugged in. The LCD found him a transmitter for one last show. The whole block listened. The missing hour came back, and he's been sleeping since." },
	},
}
