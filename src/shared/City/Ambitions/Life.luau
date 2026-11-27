--[[
	Ambitions, area A. The first three are a toddler's milestones: they fill the Goals panel
	at birth, celebrate the first years, and their rewards schedule the opening scenes of a
	life (Events/Life_Start.luau), so every new life gets its first cards in the first
	minutes. Each opening scene is gated so exactly one variant fits a life (origin, side).
]]

-- the first memory: one variant per origin and side (see Life_Start.luau)
local FIRST_MEMORY = {
	{ event = "bs_c_first_nest", inYears = 1 },
	{ event = "bs_c_first_backstreets", inYears = 1 },
	{ event = "bs_c_first_single", inYears = 1 },
	{ event = "bs_c_first_orphan", inYears = 1 },
	{ event = "bs_c_first_fixer", inYears = 1 },
	{ event = "bs_c_first_lcorp", inYears = 1 },
	{ event = "bs_c_first_veteran", inYears = 1 },
	{ event = "bs_c_first_runaway", inYears = 1 },
	{ event = "bs_c_first_hongyuan", inYears = 1 },
}

-- the second year: the rule everyone learns, and (two years on) the first friend
local THE_RULE = {
	{ event = "bs_c_rule_backstreets", inYears = 1 },
	{ event = "bs_c_rule_nest", inYears = 1 },
}

local FIRST_FRIEND = {
	{ event = "bs_c_bori_bread", inYears = 2 },
	{ event = "bs_c_nest_lotte", inYears = 2 },
}

-- count to three also re-queues the first memory, in case a life skipped it
local AGE_THREE = table.clone(FIRST_FRIEND)
for _, s in FIRST_MEMORY do
	table.insert(AGE_THREE, s)
end

return {
	{
		id = "bs_first_steps",
		name = "First steps",
		desc = "Walk across the room on your own.",
		minAge = 1,
		maxAge = 3,
		weight = 40,
		check = { when = { minAge = 1 } },
		reward = {
			health = 1,
			sanity = 2,
			schedule = FIRST_MEMORY,
			log = "You let go of the table leg and walked all the way to the door on your own. Everyone in the room clapped. Then you sat down, very hard.",
		},
	},
	{
		id = "bs_first_word",
		name = "First word",
		desc = "Say something everybody understands.",
		minAge = 2,
		maxAge = 4,
		weight = 40,
		check = { when = { minAge = 2 } },
		reward = {
			mind = 1,
			codex = "terms_ahn",
			schedule = THE_RULE,
			log = "Your first word was \"Ahn\". Nobody in the family could decide whether to be proud.",
		},
	},
	{
		id = "bs_count_three",
		name = "Count to three",
		desc = "Learn the most important number in the City.",
		minAge = 3,
		maxAge = 5,
		weight = 40,
		check = { when = { minAge = 3 } },
		reward = {
			mind = 1,
			schedule = AGE_THREE,
			log = "You learned to count to three. It's the first number anyone in the City teaches a child: three locks on the door, and home before three.",
		},
	},
	{
		id = "bs_own_shop",
		name = "A shop with a flat upstairs",
		desc = "Reach Owner (rank 4) in an ordinary trade: a diner, a Workshop, a clinic, an academy, a route, the records office or your own building.",
		minAge = 22,
		maxAge = 70,
		weight = 8,
		when = { career = { "diner", "workshop", "academy", "courier", "clinic", "nest_clerk", "landlord" } },
		check = { when = { career = { "diner", "workshop", "academy", "courier", "clinic", "nest_clerk", "landlord" }, minRank = 4 } },
		progress = { rank = 4 },
		reward = { sanity = 5, wage = { 60, 120 }, log = "Your name is on the door now. Not a big door, but yours, and the whole street knows it." },
	},
	{
		id = "bs_seventy",
		name = "Grow old in the City",
		desc = "Live to see seventy.",
		minAge = 45,
		maxAge = 69,
		weight = 6,
		check = { when = { minAge = 70 } },
		progress = { age = 70 },
		reward = { sanity = 6, log = "Seventy years in the City. The kids on the street call you \"grandmother\" or \"grandfather\" depending on the light, and you let them." },
	},
}
