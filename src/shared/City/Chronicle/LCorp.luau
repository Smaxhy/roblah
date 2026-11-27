--[[
	Chronicle acts from the Wings and L Corp: deeds that reach other players on the server.
	Echo events (when = { chronicle = "act" }) live in Events/LCorp_Echoes.luau and
	Events/Wings_Echoes.luau. Tones: "news" (default), "good", "danger", "strange", "accent".
]]

return {
	lc_suppressed_breach = { text = "{name} suppressed an escaped Abnormality inside L Corp's facility.", announce = false, tone = "good" },
	lc_caused_breach = { text = "A work order went wrong for {name} at L Corp. Something is out of its unit in {district}.", announce = false, tone = "danger" },
	lc_ordeal_held = { text = "{name} held a corridor through an Ordeal at L Corp.", announce = false, tone = "danger" },
	lc_ego_issued = { text = "{name} was issued E.G.O by L Corp's Extraction Team.", announce = false, tone = "accent" },
	lc_made_manager = { text = "{name} was made Branch Manager at Lobotomy Corporation.", announce = true, tone = "accent" },
	lc_research_published = { text = "{name} published an L Corp study that changed how a whole unit is worked.", announce = false, tone = "good" },
	lc_log_leaked = { text = "{name} let an L Corp observation log loose in {district}.", announce = false, tone = "strange" },
	lc_truth_told = { text = "{name} has been telling people what the White Nights really were.", announce = false, tone = "strange" },
	wg_cca_congested = { text = "{name} cleared a Congested WARP train in District 23 before the doors opened.", announce = true, tone = "good" },
	wg_pack_home = { text = "{name} brought an R Corp team home from a contract nobody expected them to survive.", announce = false, tone = "good" },
}
