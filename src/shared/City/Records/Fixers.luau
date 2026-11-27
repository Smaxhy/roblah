--[[
	Records for Fixer and Syndicate lives. A list; see Records/Core.luau.
]]

return {
	{ id = "fx_rec_director", name = "Section Director", desc = "Lead a Section of an Association.", check = { when = { flags = { "fx_section_director" } } } },
	{ id = "fx_rec_own_sign", name = "Your Own Sign", desc = "Found a Fixer Office of your own.", check = { when = { flags = { "fx_office_own" } } } },
	{ id = "fx_rec_saw_color", name = "Saw a Color", desc = "Meet a Color Fixer face to face and live to tell it.", check = { when = { flags = { "fx_saw_color" } } } },
	{ id = "fx_rec_retired", name = "Hung Up the Coat", desc = "Retire from Fixer work alive.", check = { when = { flags = { "fx_retired" } } } },
	{ id = "fn_rec_capo_iiii", name = "Capo IIII", desc = "Reach the highest grade of Capo in the Thumb.", check = { when = { flags = { "fn_thumb_capo_iiii" } } } },
	{ id = "fn_rec_struck", name = "Struck from the Book", desc = "Have your name struck out of the Middle's Book of Vengeance.", check = { when = { trait = "fn_struck_from_book" } } },
	{ id = "fn_rec_ricardo", name = "Not Your Story", desc = "Watch Big Brother Oswin at work on the Great Lake, and live.", check = { when = { flags = { "fn_ricardo_witness" } } } },
	{ id = "fn_rec_not_worth_ink", name = "Not Worth the Ink", desc = "Be judged not worth a line in a Big Brother's Book.", check = { when = { trait = "fn_not_worth_the_ink" } } },
}
