--[[
	Books: found in receptions, expeditions, boss fights and odd shops. Reading one (an
	activity that appears while you hold it) teaches its ability, a trait. Unread books pass
	to your heir. { order = {...}, [id] = { name, desc, rarity, trait, mastery } }.
	Every module in Books/ is merged; ids must be unique.
]]

return {
	order = { "book_shield_drills", "book_flame_forms", "book_blade_scroll", "book_case_files", "book_hardblood_primer", "book_pianist_score" },

	book_shield_drills = { name = "Zwei Shield Drills", desc = "A dog-eared Association manual. Stand your ground, then stand it better.", schools = { "zwei" }, rarity = "uncommon", trait = "ab_shield_stance" },
	book_flame_forms = { name = "Liu Flame Forms", desc = "Scorched pages of footwork that ends in fire.", schools = { "liu" }, rarity = "rare", trait = "ab_flame_forms" },
	book_blade_scroll = { name = "A Blade Lineage Scroll", desc = "Ink brushwork of a single cut, repeated a thousand times.", schools = { "blade_lineage" }, rarity = "epic", trait = "old_blade_lineage" },
	book_case_files = { name = "Seven's Case Files", desc = "Redacted reports with the method left in.", schools = { "seven" }, rarity = "uncommon", trait = "ab_investigator" },
	book_hardblood_primer = { name = "A Hardblood Primer", desc = "Written by a Bloodfiend, for Bloodfiends. The diagrams are unsettling.", schools = { "hardblood" }, rarity = "rare", trait = "ab_hardblood_forms" },
	book_pianist_score = { name = "A Torn Music Score", desc = "Notes nobody should play. Reading it steadies something in you anyway.", rarity = "legendary", trait = "ab_unshaken" },
}
