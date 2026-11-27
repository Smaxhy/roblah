--[[
	Chronicle acts, area A: ordinary lives that reach other players on the server.
	Each act has at least one echo event in Events/Life_Echoes.luau (when.chronicle).
]]

return {
	bs_act_night_walk = { text = "{name} was caught outside during the Night in {district}, and walked home at dawn.", announce = true, tone = "danger" },
	bs_act_shelter = { text = "{name} kept a night shelter's door open in {district} until 3:12. Everyone inside saw the morning.", announce = false, tone = "good" },
	bs_act_rats_broken = { text = "{name} broke up a pack of Rats in the tunnels under {district}.", announce = false, tone = "news" },
	bs_act_route_owner = { text = "{name} now owns the courier route through {district}. Nothing on it arrives late.", announce = false, tone = "good" },
	bs_act_free_noodles = { text = "{name} fed the whole street for free in {district}, on the house.", announce = false, tone = "good" },
	bs_act_recorded_night = { text = "{name} recorded the Night in {district}. By morning, nobody on the street could remember them.", announce = true, tone = "strange" },
	bs_act_academy = { text = "{name} opened an academy in {district}. The first class has eleven students and one chalkboard.", announce = false, tone = "good" },
	bs_act_clinic_open = { text = "{name} kept a Backstreets clinic open all through a turf war in {district}.", announce = false, tone = "good" },
}
