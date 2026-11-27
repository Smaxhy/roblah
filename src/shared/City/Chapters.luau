--[[
	CANTOS and INTERVALLOS: title cards when a life reaches each age (in rising order).
	A Canto is a chapter of the life; an Intervallo is a short interlude between two Cantos.
		{ age, num, title, line }  line: one short sentence under the title (optional).
	The UI shows "CANTO III" or "INTERVALLO II" above the title, so titles don't repeat it.
	Opening scenes: Events/Story_Chapters.luau (Cantos) and Events/Story_Intervallos.luau.
]]

return {
	-- (v0.12) every Canto has several titles and lines: each life gets its own pair (Sim:variant),
	-- so no two lives read the same chapter names. A storyline can still give its own lines.
	cantos = {
		{ age = 0, num = "I",
			title = { "The Uncounted", "The Small Name", "The First Ledger Line", "The Unremarked", "The Borrowed Breath", "The New Tenant" },
			line = { "One more child in the City. The City doesn't look up.", "Somewhere a clerk writes your name down, and spells it wrong.", "You arrive. The District doesn't notice. Somebody does.", "A new name in a building full of old ones.", "The City makes room for one more. It always does, and it never says how." } },
		{ age = 6, num = "II",
			title = { "The Unopened Door", "The Learned Rules", "The Early Curfew", "The Counted Steps", "The Locked Window" },
			line = { "Home before 3:13. Don't open the door. Don't ask why.", "You learn the rules before you learn why there are rules.", "Count the steps home. Be inside before the count runs out.", "There's a window you're not allowed to open. You know exactly where it is." } },
		{ age = 12, num = "III",
			title = { "The Street Noticing", "The First Errand", "The Watched Corner", "The Named Kid", "The Measured Look" },
			line = { "The street starts noticing you back.", "Somebody trusts you with an errand. That's how it starts.", "There's a corner where people stand and watch. Now they watch you.", "Shopkeepers know your name now. So do people you'd rather didn't." } },
		{ age = 16, num = "IV",
			title = { "The Fight Finding", "The Chosen Side", "The Sharpened Habit", "The Bruise Lesson", "The First Debt" },
			line = { "Everyone finds out how they fight. Most find out the hard way.", "Everyone picks a side. Not picking is a side too.", "What you do every day turns into what you're good at.", "Some lessons only take once." } },
		{ age = 20, num = "V",
			title = { "The Written Down", "The Signed Line", "The Opened File", "The Named Price", "The Kept Ledger" },
			line = { "Somebody is keeping track of you now.", "You sign things now. Things sign you back.", "There's a file with your name on it, in an office you'll never see.", "Everything has a price in the City. Now so do you." } },
		{ age = 30, num = "VI",
			title = { "The Collecting", "The Called-In Loan", "The Heavy Pockets", "The Settled Account", "The Weight Carried" },
			line = { "Everything the City gave you was a loan.", "The City lends you years. Then it sends someone to collect.", "You carry more now: keys, names, debts, people.", "You know what you're worth now, to the Ahn." } },
		{ age = 45, num = "VII",
			title = { "The Unforgetting", "The Long Memory", "The Known Alleys", "The Old Scars", "The Remembered Faces" },
			line = { "You know which alleys to avoid. The alleys know you too.", "You remember everyone who wronged you. Some of them remember you back.", "Every scar has a District and a year.", "Younger people ask you how things used to be. You tell them some of it." } },
		{ age = 60, num = "VIII",
			title = { "The Book Closing", "The Last Pages", "The Shelved Name", "The Final Lamp", "The Quiet Ending" },
			line = { "Every book ends. Somebody shelves it.", "The last pages are always shorter than you think.", "One day your name will be on a shelf somewhere. Not yet.", "The lamps go out one at a time. Yours is still lit." } },
	},
	intervallos = {
		{ age = 3, num = "I", title = "Long Noodles", line = "Don't bite them. Biting shortens your life. Everyone knows that." },
		{ age = 9, num = "II", title = "The Same Dream", line = "Thirty children dreamed it on the same night. No grown-up believed a word." },
		{ age = 14, num = "III", title = "The Dumpling Verdict", line = "Two dumpling stalls, one judge. The judge is fourteen." },
		{ age = 18, num = "IV", title = "Lost Property", line = "Everything you ever dropped in this District is in a drawer somewhere." },
		{ age = 25, num = "V", title = "A Capo's Day Off", line = "Even the Thumb has Sundays. They are very formal Sundays." },
		{ age = 37, num = "VI", title = "The Tenant Meeting", line = "Item one: the lock. Item two: who broke the lock." },
		{ age = 52, num = "VII", title = "The Green Door", line = "You dreamed it when you were nine. Somebody just dug it up." },
	},
}
