--[[
	Records from the Wings and L Corp: achievements a finished life can earn.
	The Manager and Head of Research records are in Records/Core.luau (branch_manager,
	head_of_research). Same format: { id, name, desc, check }.
]]

return {
	{ id = "lc_rec_breach_survivor", name = "Breach Survivor", desc = "Live through a containment breach.", check = { when = { flags = { "lc_breach_survivor" } } } },
	{ id = "lc_rec_captain", name = "Department Captain", desc = "Wear a Department Captain's armband at L Corp.", check = { when = { flags = { "lcorp_captain" } } } },
	{ id = "lc_rec_ego", name = "Issued E.G.O", desc = "Be issued E.G.O by L Corp's Extraction Team.", check = { when = { flags = { "lc_ego_issued" } } } },
	{ id = "lc_rec_scientist", name = "Just a Scientist", desc = "Choose the lab bench over the corner office.", check = { when = { trait = "lc_true_scientist" } } },
	{ id = "lc_rec_secret", name = "What the Green Is", desc = "Learn one of Lobotomy Corporation's secrets.", check = { when = { flags = { "lc_secret_seen" } } } },
	{ id = "lc_rec_whole_truth", name = "The Whole Truth", desc = "Follow L Corp's secrets all the way to the White Nights.", check = { when = { flags = { "lc_secret_whole_truth" } } } },
	{ id = "wg_rec_cca", name = "CCA Certified", desc = "Be trusted with W Corp's Congestion Cleaning Armor.", check = { when = { trait = "wg_cca_certified" } } },
	{ id = "wg_rec_executive", name = "The Top Floor", desc = "Become an Executive of your District's Wing.", check = { when = { flags = { "wg_executive" } } } },
	{ id = "wg_rec_audit", name = "Audit Staff", desc = "Rise to T Corp's Class 5 Audit Staff.", check = { when = { flags = { "wg_time_auditor" } } } },
	{ id = "wg_rec_steward", name = "Family Steward", desc = "Run a great house of Hongyuan.", check = { when = { flags = { "wg_family_steward" } } } },
}
