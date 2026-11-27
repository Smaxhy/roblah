--[[
	Traits, area A: earned in an ordinary life (none are pickable at creation).
	See Traits/Core.luau for the fields.
]]

return {
	order = { "bs_rat_instincts", "bs_workshop_hands", "bs_academy_graduate", "bs_alley_runner", "bs_door_keeper" },

	bs_rat_instincts = { name = "Rat Instincts", desc = "You ran with a Rat pack as a kid. You still fight like there are four of you behind you. +2 Strength, +1 base in fights.", category = "street", stats = { strength = 2 }, fight = { base = 1 } },
	bs_workshop_hands = { name = "Workshop Hands", desc = "Years at a Workshop bench. You can fix a lock, a coat or a prosthetic knee. +3 Intelligence, +1 base in Intelligence checks.", category = "craft", stats = { intelligence = 3 }, clash = { intelligence = { base = 1 } } },
	bs_academy_graduate = { name = "Academy Graduate", desc = "You finished a Backstreets academy, certificate and all. +4 Intelligence, +1 base in Mental Strength checks.", category = "mind", stats = { intelligence = 4 }, clash = { mind = { base = 1 } } },
	bs_alley_runner = { name = "Alley Runner", desc = "You know every shortcut, stairwell and rooftop in the District, and exactly how long each one takes. +1 base in Strength and Health checks.", category = "street", clash = { strength = { base = 1 }, health = { base = 1 } } },
	bs_door_keeper = { name = "Kept the Door", desc = "You once held a door open for strangers until the last second before 3:13. Something about it stayed with you, and with your family. +3 heads chance, +4 Sanity. Runs in the family.", category = "street", heads = 3, sanity = 4, inherit = true },
}
