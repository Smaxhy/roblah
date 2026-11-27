--[[
	Chronicle acts for Fixers, the Associations and the Fingers. A result `chronicle = "act"`
	records the deed for the server; echo events (when = { chronicle = "act" }) carry it into
	other players' lives, with {actor} and {actorDistrict} naming who did it and where.
	Each act below has at least one echo event in Events/Fixers_Echoes.luau.
]]

return {
	fx_grade_one = { text = "{name} was promoted to Grade 1 Fixer in {district}. As high as the scale goes.", announce = true, tone = "accent" },
	fx_color = { text = "{name} was granted a Color by the Hana Association. Every Fixer in the City knows the name now.", announce = true, tone = "accent" },
	fx_office_founded = { text = "{name} hung the sign of a new Fixer Office in {district}.", announce = false, tone = "good" },
	fx_office_raided = { text = "{name}'s crew raided a rival Office in {district} and walked out with its ledger.", announce = false, tone = "danger" },
	fx_open_contract = { text = "{name} closed one of Hana's Open Contracts in {district}: a threat graded Urban Legend.", announce = true, tone = "good" },
	fn_thumb_provoked = { text = "{name} was rude to a Capo of the Thumb in {district}. The Thumb is collecting on every street.", announce = true, tone = "danger" },
	fn_written_in_book = { text = "{name}'s name was written into the Middle's Book of Vengeance in {district}.", announce = false, tone = "danger" },
	fn_struck_from_book = { text = "{name}'s name was struck out of the Middle's Book of Vengeance. It can be done.", announce = false, tone = "good" },
	fn_ricardo_witness = { text = "{name} saw Big Brother Oswin of the Middle at work on the Great Lake, and lived to tell it.", announce = true, tone = "strange" },
	fn_prescript_done = { text = "{name} carried out a Prescript of the Index in {district}, exactly as written.", announce = false, tone = "strange" },
	fn_sottocapo = { text = "{name} was made Sottocapo of the Thumb in {district}. New rules on every street.", announce = true, tone = "danger" },
	fn_maestro = { text = "{name} founded a new movement of the Ring. Its first gallery opens by invitation only.", announce = true, tone = "strange" },
	deed_legend_hunted = { text = "{name} hunted down an Urban Legend in {district}, and Hana paid the bounty.", announce = true, tone = "accent" },
	deed_capo_beaten = { text = "{name} took a street from a Capo of the Thumb in {district}.", announce = true, tone = "accent" },
	deed_finger_driven = { text = "{name} drove a Finger's branch out of {district}.", announce = true, tone = "accent" },
	deed_became_color = { text = "Hana has granted {name} a Color.", announce = true, tone = "accent" },
}
