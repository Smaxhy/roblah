--[[
	Titles from the Wings and L Corp. Checked top to bottom when a life ends; the first that
	passes names the life. `before` places a title ahead of an existing one (Ribbons/Core.luau).
	Most go ahead of "Saw the Light", which nearly everyone alive in 978 earns.
	The Wing's ladder has seven ranks, so Class 5 and Director get their own titles ahead of
	Core's "director" (The Executive), which then names only the true Executives.
]]

return {
	{ id = "lc_title_truth", name = "The One Who Knew", desc = "Followed Lobotomy Corporation's secrets all the way down, and lived to understand the Light.", before = "manager", check = { when = { flags = { "lc_secret_whole_truth" } } } },
	{ id = "wg_title_director", name = "A Wing Director", desc = "One floor below the top of a Wing.", before = "director", check = { when = { career = "wing", flags = { "wg_director" }, notFlags = { "wg_executive" } } } },
	{ id = "wg_title_class_five", name = "Class 5", desc = "Rose to the top of a Wing's Classes.", before = "director", check = { when = { career = "wing", minRank = 5, notFlags = { "wg_director" } } } },
	{ id = "lc_title_captain", name = "Department Captain", desc = "The longest-serving Agent in an L Corp department.", before = "light", check = { when = { flags = { "lcorp_captain" } } } },
	{ id = "lc_title_scientist", name = "Just a Scientist", desc = "Turned down the corner office to stay at the bench.", before = "light", check = { when = { trait = "lc_true_scientist" } } },
	{ id = "wg_title_audit", name = "Audit Staff", desc = "Class 5 of T Corp's Time Collection; everyone stood up when they walked in.", before = "light", check = { when = { flags = { "wg_time_auditor" } } } },
	{ id = "wg_title_steward", name = "Steward of Hongyuan", desc = "Ran a great house for one of the Four Families.", before = "light", check = { when = { flags = { "wg_family_steward" } } } },
	{ id = "wg_title_cca", name = "Armored Cleanup Agent", desc = "Wore W Corp's CCA into the trains nobody else would board.", before = "light", check = { when = { trait = "wg_cca_certified" } } },
	{ id = "lc_title_veteran", name = "Face the Fear", desc = "Worked L Corp's containment units, lived through a breach, and walked out again.", before = "light", check = { when = { flags = { "lc_was_agent", "lc_breach_survivor" } } } },
}
