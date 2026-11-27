--[[
	STORYLINES: the main story of a life. Every life that starts at birth gets exactly one,
	rolled at birth by `weight` among those whose `when` fits the family it was born into.
	Its beats are ordinary events (Events/Story_*.luau) with `story = "<id>"`.

	{
		id = "sl_collateral",         -- also set as a flag on the life
		name = "Collateral",          -- shown as YOUR STORY
		hook = "one or two short sentences: the premise, told to the player at birth",
		tone = "grim",                -- grim | tragic | strange | hopeful (colors the story band)
		weight = 10,
		when = { side = "backstreets" },   -- optional: who can be born into it
		goal = "the first objective",      -- shown in the Story tab until a beat changes it
		cantos = { [2] = "one line under Canto II's title for this story", ... },  -- optional
	}
	Every module in this folder returns a list like this one.
]]

return {
	{
		id = "sl_collateral",
		name = "Collateral",
		hook = "Your father borrowed from a Syndicate lender. He had one thing to put up against the loan. It was you.",
		tone = "grim",
		weight = 10,
		when = { side = "backstreets", hasRelation = "father" },
		goal = "Grow. Somebody is keeping count.",
		cantos = {
			[2] = "A man comes every birthday with a tape measure. He isn't family.",
			[3] = "The contract is in the bread tin. It has your name on it.",
			[4] = "It comes due at sixteen.",
			[5] = "Paper remembers.",
		},
	},
}
