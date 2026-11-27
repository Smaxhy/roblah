--[[
	Chronicle acts for recruitment and the faction wars (writer: fc_ ids). Recorded by
	Events/Factions_*.luau and Expeditions/Factions.luau; every act has an echo event for
	other players in Events/Factions_Echoes.luau.
]]

return {
	fc_refused_thumb = { text = "{name} turned the Thumb down in {district}, to a Capo's face.", announce = false, tone = "danger" },
	fc_held_line = { text = "{name} held a street for one side of a faction war in {district}.", announce = false, tone = "danger" },
	fc_stood_between = { text = "{name} walked out between two Fingers' lines in {district} with empty hands, and the shooting stopped for an hour.", announce = true, tone = "good" },
	fc_turncoat = { text = "{name} changed sides in the middle of a faction war in {district}.", announce = false, tone = "danger" },
	fc_war_profiteer = { text = "{name} made a small fortune selling to both sides of a faction war in {district}.", announce = false, tone = "news" },
	fc_held_street = { text = "{name}'s crew kept a market open through a faction war in {district}, and everyone got home before three.", announce = true, tone = "good" },
	fc_tea_house_saved = { text = "{name}'s crew got forty families out of a burning street between the Liu and the Shi in {district}.", announce = true, tone = "good" },
	fc_depot_raided = { text = "{name}'s crew raided a Wing's forward depot in {district} while the Feathers clashed.", announce = true, tone = "danger" },
	fc_ranked_top = { text = "{name} climbed into the top ten on Hana's board in {district}.", announce = false, tone = "accent" },
	fc_crackdown_raid = { text = "{name} helped Hana shut down an unlicensed Office in {district}.", announce = false, tone = "news" },
	fc_family_terms = { text = "{name} carried terms between two Bloodfiend Families in {district}, and the rooftops went quiet.", announce = false, tone = "strange" },
}
