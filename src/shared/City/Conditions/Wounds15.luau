-- (v0.15) Harder fights leave more behind: wounds from bosses and from the Night.
return {
	broken_ribs = { name = "Broken Ribs", years = 2, desc = "-1 coin in Speed clashes. Lose a little Health this year.", gainLog = "Two ribs, maybe three. Breathing is a negotiation.", clash = { speed = { coins = -1 } }, yearly = { health = { -2, -1 } }, look = "bandaged" },
	fever = { name = "Fever", years = 1, desc = "-1 base in every clash this year.", gainLog = "A fever from bad water, or bad air. The room tilts.", clash = { strength = { base = -1 }, speed = { base = -1 }, intelligence = { base = -1 }, mind = { base = -1 } }, look = "pale" },
	propellant_scar = { name = "Propellant Scar", years = 4, curable = false, desc = "-1 base in Charisma clashes. People who know the Thumb know what made it.", gainLog = "A Thumb round left a scar that won't fade, the shape of a thumbprint.", clash = { charisma = { base = -1 } }, look = "bandaged" },
	ringing = { name = "Ringing Ears", years = 2, desc = "-1 base in Mental Strength clashes, -1 Sanity a year.", gainLog = "Something rang inside your skull, and hasn't quite stopped.", clash = { mind = { base = -1 } }, yearly = { sanity = -1 }, look = "shadows" },
}
