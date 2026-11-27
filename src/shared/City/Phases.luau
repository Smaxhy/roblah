--[[
	PHASES (v0.13): a life changes shape as it goes (Engine/Feats.luau). On the year a life
	reaches a phase, a card says what this part of life is about and what has opened up.
]]

return {
	{
		id = "childhood",
		name = "Childhood",
		from = 0,
		line = "Small rooms and big streets. The City is a rumor told by grown-ups.",
		unlocks = { "Family", "Growing up" },
		color = { 150, 190, 220 },
	},
	{
		id = "youth",
		name = "Youth",
		from = 13,
		line = "You're old enough to be noticed. The City starts to notice back.",
		unlocks = { "Rivals", "Work on the side", "Nests, Offices and Syndicates take an interest" },
		color = { 140, 200, 160 },
	},
	{
		id = "making_a_name",
		name = "Making a Name",
		from = 18,
		line = "You're grown, by the City's count. Everything is open, and nothing is free.",
		unlocks = { "Careers and licences", "Turf wars in the Backstreets", "Cases", "Delves, when you find a way in", "A household of your own" },
		color = { 236, 196, 110 },
	},
	{
		id = "power",
		name = "Power",
		from = 32,
		line = "People who know your name want something from it. The big plays are open now.",
		unlocks = { "Deeds: Offices, Districts, Colors", "Rivals who've become friends", "The hardest feats" },
		color = { 222, 122, 90 },
	},
	{
		id = "legacy",
		name = "Legacy",
		from = 55,
		line = "Less of what you do is for you now. What you leave behind is the work.",
		unlocks = { "Apprentices", "Last contracts", "Endowments for the District", "An heir to carry it on" },
		color = { 190, 150, 220 },
	},
	-- (v0.17) lives that go on: a body the City couldn't wear out, a K Corp course, a Workshop
	-- body, or blood that only gets older
	{
		id = "long_life",
		name = "Long Life",
		from = 90,
		line = "Most of the people who knew your first name are gone. The City has changed around you twice. You're still here, and still dangerous.",
		unlocks = { "Being the oldest fighter in the District", "Young Fixers who come to test you", "Watching the City change" },
		color = { 170, 200, 210 },
	},
	{
		id = "ancient",
		name = "The Ancient",
		from = 150,
		line = "Nobody alive remembers you young. Families tell their fledglings about you. Districts have changed their names since you came to them.",
		unlocks = { "Elders who come to you for answers", "Hunters who heard the stories", "Blood older than the streets" },
		color = { 200, 60, 80 },
	},
}
