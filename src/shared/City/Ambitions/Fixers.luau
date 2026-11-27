--[[
	Ambitions for Fixers and the Fingers. A list; see Ambitions/Core.luau for the format.
]]

local ASSOCIATIONS = { "zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi", "hana" }

return {
	{ id = "fx_amb_license", name = "Licensed", desc = "Get a Hana Fixer's license.", minAge = 14, maxAge = 40, when = { notFlags = { "licensed_fixer" } }, check = { when = { flags = { "licensed_fixer" } } }, reward = { sanity = 3, log = "A Fixer's license, with your name on it. Grade 9, the lowest there is. You carry it everywhere." } },
	{ id = "fx_amb_grade_three", name = "A Respected Fixer", desc = "Reach Grade 3 as an Office Fixer.", minAge = 20, maxAge = 70, weight = 8, when = { career = "fixer" }, check = { when = { career = "fixer", minRank = 7 } }, progress = { rank = 7 }, reward = { paycheck = 0.5, log = "Grade 3. Rival Offices stop undercutting you and start inviting you to dinner." } },
	{ id = "fx_amb_section_three", name = "Section 3", desc = "Rise to Section 3 in an Association.", minAge = 20, maxAge = 70, weight = 8, when = { career = ASSOCIATIONS }, check = { when = { career = ASSOCIATIONS, minRank = 4 } }, progress = { rank = 4 }, reward = { paycheck = 0.5, log = "Section 3. Fixers who were stuck in Section 4 for years look at you differently now." } },
	{ id = "fn_amb_capo", name = "A Table of Your Own", desc = "Become a Capo of the Thumb.", minAge = 18, maxAge = 70, weight = 8, when = { career = "thumb" }, check = { when = { career = "thumb", minRank = 5 } }, progress = { rank = 5 }, reward = { paycheck = 0.5, log = "Capo. Soldati stand when you enter, and the noodle stall saves you the good table." } },
	{ id = "fn_amb_struck", name = "Out of the Book", desc = "Get your name struck out of the Middle's Book of Vengeance.", minAge = 14, maxAge = 80, weight = 12, when = { flags = { "fn_middle_grudge" } }, check = { when = { notFlags = { "fn_middle_grudge" } } }, reward = { sanity = 6, log = "Your name is out of the Book. You walked past a Sibling of the Middle today and didn't flinch." } },
}
