--[[
	Storylines that belong to an age of the City. Each can only be lived by someone born at the
	right time, so picking a time to be born changes which stories can find you.
	  Seven Days       a child when the Light comes: your father works nights for L Corp
	  The Invitation   the Age of the Library: an envelope keeps coming to your door
	  The Book         any age: your sister is written in the Middle's Book of Vengeance
	  A Quiet Heart    after the second Light: an old woman on the roof is teaching you to sit still
	Format: Storylines/Core.luau. Beats: Events/Story_Ages.luau.
]]

return {
	{
		id = "sl_seven_days",
		name = "Seven Days",
		hook = "Your father keeps the lamps lit on a floor of the L Corp tower. He says the Wing is building something for everyone. He comes home quieter every year.",
		tone = "strange",
		weight = 16,
		when = { minYear = 962, maxYear = 970, hasRelation = "father" },
		goal = "Your father works nights. Wait up for him.",
		cantos = {
			[2] = "There's a sealed envelope on the top shelf. You're not to touch it.",
			[3] = "Three days without a night.",
			[4] = "On the fourth morning, he wasn't home.",
			[5] = "Somebody has to keep a lamp lit.",
		},
	},
	{
		id = "sl_invitation",
		name = "The Invitation",
		hook = "An envelope came for your mother the year you were born: thick cream paper, her name in a hand nobody recognised. She burned it. It came back.",
		tone = "tragic",
		weight = 16,
		when = { minYear = 977, maxYear = 983, hasRelation = "mother" },
		goal = "Your mother keeps an envelope in the drawer. She says it's nothing.",
		cantos = {
			[2] = "It offers a book. Any book. The one you want most.",
			[3] = "A neighbour signed. His book is on a stall now.",
			[4] = "This one has your name on it.",
			[5] = "Nobody is made to sign.",
		},
	},
	{
		id = "sl_the_book",
		name = "The Book",
		hook = "Before you could walk, your sister broke a Little Sibling's nose. The Middle wrote it down. The Middle repays everything, in kind, and it's in no hurry.",
		tone = "grim",
		weight = 12,
		when = { side = "backstreets", hasRelation = "sibling" },
		goal = "There's a tally chalked on your wall. Nobody will tell you what it counts.",
		cantos = {
			[2] = "They come once a year to read the page aloud.",
			[3] = "The interest is paid in kind.",
			[4] = "A page can be struck out. It has a price.",
			[5] = "Family looks after family.",
		},
	},
	{
		id = "sl_quiet_heart",
		name = "A Quiet Heart",
		hook = "An old woman has sat on your roof every dawn since the second Light, facing where it rose, perfectly still. She's started leaving room on the mat.",
		tone = "hopeful",
		weight = 16,
		when = { minYear = 999 },
		goal = "There's an old woman on the roof at dawn. She doesn't move.",
		cantos = {
			[2] = "She says the first lesson is to sit. The second lesson is to sit.",
			[3] = "One feeling. Held still. That's all of it.",
			[4] = "A ring is a thing you want, kept from moving.",
			[5] = "It can't be hurried.",
		},
	},
}
