--[[
	Conditions: injuries, illnesses and worse. Added by results (`condition = "id"`), treated at
	a clinic (`cure`) unless curable = false, or they fade after `years`.
	Fields: name, years, curable, desc, gainLog, healLog, yearly, clash, look ("bandaged",
	"pale", ...). Every module in Conditions/ returns { [id] = def }; ids must be unique.
]]

return {
	broken_arm = { name = "Broken Arm", years = 2, desc = "-1 coin in Strength clashes, -1 base in Intelligence clashes.", gainLog = "Your arm is broken. Ampules would fix it overnight, if you could afford one.", clash = { strength = { coins = -1 }, intelligence = { base = -1 } }, look = "cast" },
	deep_cut = { name = "Deep Cut", years = 1, desc = "Lose a little Health this year.", gainLog = "A deep cut that won't close properly.", yearly = { health = { -2, -1 } }, look = "bandaged" },
	burns = { name = "Burns", years = 2, desc = "-2 base in Intelligence clashes.", gainLog = "Your hands are burned and wrapped.", clash = { intelligence = { base = -2 } }, look = "bandaged" },
	smoke_lung = { name = "Smoke Lung", years = 3, desc = "Lose a little Health every year.", gainLog = "The cough settled in for good.", yearly = { health = { -2, -1 } }, look = "pale" },
	night_terrors = { name = "Night Terrors", years = 2, desc = "-2 Sanity a year, -1 base in Mental Strength clashes.", gainLog = "You started waking at 3:13 every night, listening for footsteps.", yearly = { sanity = -2 }, clash = { mind = { base = -1 } }, look = "shadows" },
	enkephalin_sick = { name = "Enkephalin Sickness", years = 2, desc = "-1 Health and -1 Sanity a year.", gainLog = "Too long near the green glow. You feel thin, like a page held up to the light.", yearly = { health = { -1, 0 }, sanity = -1 }, look = "pale" },
	distortion_signs = { name = "Signs of Distortion", years = 3, curable = false, desc = "-2 Sanity a year. Something inside wants out.", gainLog = "Your shadow moved a half-second late today. You told no one.", healLog = "The signs faded. Whatever it was, it settled back down.", yearly = { sanity = -2 }, look = "shadows" },
	grief = { name = "Grief", years = 1, curable = false, desc = "-2 Sanity this year.", gainLog = "Grief moved in and sat at the table.", healLog = "The grief eased into something you could carry.", yearly = { sanity = -2 }, look = "armband" },
	in_the_book = { name = "In the Book", years = 5, curable = false, desc = "-1 Sanity a year. Your name is in the Middle's Book of Vengeance.", gainLog = "Your name has been written in the Middle's Book of Vengeance. Everyone on the street knows.", healLog = "Somebody crossed your name out of the Book. You don't ask who paid for it.", yearly = { sanity = -1 }, look = "kinmark" },
}
