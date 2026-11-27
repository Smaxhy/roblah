--[[
	Chronicle acts, danger and horror (dz_). Each act has an echo event in
	Events/Danger_Echoes.luau (when.chronicle), so one life's worst night reaches other lives.
]]

return {
	dz_act_distortion_loose = { text = "{name} ran from a Distortion in {district}. It's still out there.", announce = false, tone = "danger" },
	dz_act_claw_witness = { text = "{name} saw a Claw at work in {district}, and lived.", announce = true, tone = "strange" },
	dz_act_long_night = { text = "{name} crossed {district} during the Night with a sealed parcel, and delivered it.", announce = true, tone = "accent" },
	dz_act_outskirts = { text = "{name} came back from the Outskirts past {district}'s wall. Something followed.", announce = false, tone = "danger" },
	dz_act_number_nine = { text = "{name} walked out of Number Nine, Bellhouse Row. Nobody else ever has.", announce = true, tone = "strange" },
	dz_act_breach_held = { text = "{name} held a stairwell shut in {district} against something that got out of L Corp.", announce = false, tone = "danger" },
	dz_act_ring_escape = { text = "{name} walked out of a Ring exhibition in {district} before the doors locked.", announce = false, tone = "strange" },
}
