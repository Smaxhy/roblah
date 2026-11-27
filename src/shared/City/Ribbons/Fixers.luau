--[[
	Titles for Fixer and Syndicate lives. Rank titles go before "light" (Saw the Light, which
	nearly every early life earns), so a career that defined a life names it; the plain
	"Licensed Fixer" sits at the default spot, just before the catch-all.
]]

return {
	{ id = "fx_title_director", name = "Association Director", desc = "Led a Section of one of the twelve Associations.", check = { when = { flags = { "fx_section_director" } } }, before = "light" },
	{ id = "fn_title_capo", name = "Capo of the Thumb", desc = "Had a table of their own, and Soldati who stood when they entered.", check = { when = { flags = { "fn_thumb_capo" } } }, before = "light" },
	{ id = "fn_title_big_sibling", name = "Big Sibling of the Middle", desc = "Carried a Book of Vengeance, and a family.", check = { when = { flags = { "fn_middle_big" } } }, before = "light" },
	{ id = "fn_title_docent", name = "Docent of the Ring", desc = "Wore a Docent's ring and judged other people's art.", check = { when = { flags = { "fn_ring_docent" } } }, before = "light" },
	{ id = "fn_title_proxy", name = "Proxy of the Index", desc = "Carried the Prescripts, and never asked who wrote them.", check = { when = { flags = { "fn_index_ranked_proxy" } } }, before = "light" },
	{ id = "fx_title_rep", name = "Rep of Their Own Office", desc = "Hung their own sign and kept it up.", check = { when = { flags = { "fx_office_own" } } }, before = "light" },
	{ id = "fn_title_in_book", name = "Still in the Book", desc = "Died with their name in the Middle's Book of Vengeance.", check = { when = { hasCondition = "in_the_book" } }, before = "light" },
	{ id = "fn_title_ricardo", name = "Watched a Big Brother Work", desc = "Was there on the Great Lake when Oswin read out the sins.", check = { when = { flags = { "fn_ricardo_witness" } } }, before = "light" },
	{ id = "fx_title_fixer", name = "A Licensed Fixer", desc = "Carried a Hana license, and used it.", check = { when = { flags = { "licensed_fixer" } } } },
}
