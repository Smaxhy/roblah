--[[
	Chronicle acts for Bloodfiends: deeds the whole server hears about. Echo events for other
	players are in Events/Bloodfiend.luau.
]]

return {
	bf_turned = { text = "{name} accepted the Kindred's gift in {district}, and became a Bloodfiend.", announce = true, tone = "strange" },
	-- (v0.12) Events/Bloodfiend_Hunt.luau
	bf_hand_beaten = { text = "{name} stood against a Bloodfiend Family's Elder's Hand in {district}, and is still standing.", announce = true, tone = "danger" },
	bf_elder_withdrew = { text = "A Bloodfiend Elder came for {name} in {district} in person, and left again. Nobody knows why.", announce = true, tone = "strange" },
	bf_hunters_repelled = { text = "{name}, a Bloodfiend, sent a Fixer Office's hunters home empty-handed in {district}.", announce = false, tone = "danger" },
	bf_lost = { text = "{name}, a Bloodfiend, was lost to the Thirst in {district}. Fixers swept the block.", announce = true, tone = "danger" },
}
