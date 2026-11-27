--[[
	Books that teach (bl_ ids): boss drops, raid rewards, receptions, odd finds and the
	black-market bookshop under the overpass. Reading one teaches its ability (Traits/Abilities).
	{ order = {...}, [id] = { name, desc, rarity, trait, mastery } }
]]

return {
	order = {
		"bl_book_verdict_notes", "bl_book_kurokumo_scroll", "bl_book_soldato_drill", "bl_book_prescripts",
		"bl_book_small_grudges", "bl_book_lcd_field", "bl_book_night_almanac", "bl_book_suppression",
		"bl_book_vesperine", "bl_book_wu_scroll", "bl_book_catechism", "bl_book_outskirts_log",
		"bl_book_docent_sketches", "bl_book_lamplighter_log", "bl_book_prodigy_margins", "bl_book_drill_ledger",
		"bl_book_guest",
	},

	bl_book_verdict_notes = { schools = { "cinq" }, name = "The Ivory Verdict's Notebook", desc = "Footwork diagrams, one per duel, each signed with a date and a name.", rarity = "legendary", trait = "bl_ab_ivory_stance" },
	bl_book_kurokumo_scroll = { schools = { "kurokumo" }, name = "A Kurokumo Draw Scroll", desc = "One sheathed cut, brushed in ink a thousand times.", rarity = "epic", trait = "bl_ab_cloud_draw" },
	bl_book_soldato_drill = { schools = { "thumb" }, name = "A Soldato's Firing Drill", desc = "The Thumb's drill card for propellant rounds. Manners on the front, aim on the back.", rarity = "rare", trait = "bl_ab_propellant" },
	bl_book_prescripts = { schools = { "index" }, name = "A Bundle of Spent Prescripts", desc = "Two hundred paper slips, all carried out. Reading them in order is strangely calming.", rarity = "rare", trait = "bl_ab_obedient_hands" },
	bl_book_small_grudges = { schools = { "middle" }, name = "A Little Book of Grudges", desc = "A Middle sibling's pocket notebook. Every slight, dated and underlined.", rarity = "rare", trait = "bl_ab_never_forget" },
	bl_book_lcd_field = { name = "LCD Field Manual: Peccatula", desc = "Limbus Company's handbook for clearance crews. Chapter one: don't touch the red bits.", rarity = "uncommon", trait = "bl_ab_clearance" },
	bl_book_night_almanac = { name = "The Night Shelter Almanac", desc = "Forty years of a shelter keeper's notes: which doors open, which don't, and when.", rarity = "uncommon", trait = "bl_ab_night_sense" },
	bl_book_suppression = { name = "Suppression Manual, Violet Edition", desc = "L Corp's handbook for Midnight. Several pages are blank, and the blank ones are the worst.", rarity = "epic", trait = "bl_ab_suppression" },
	bl_book_vesperine = { schools = { "hardblood" }, name = "The Vesperine Codex", desc = "A Bloodfiend Family's book of Hardblood, older than three Wings.", rarity = "legendary", trait = "bl_ab_red_mend" },
	bl_book_wu_scroll = { name = "A Wu Branch Gait Scroll", desc = "A Heishou pack master's notes on the gallop. Half of it is breathing.", rarity = "epic", trait = "bl_ab_wu_gait" },
	bl_book_catechism = { name = "The Grosshammer's Catechism", desc = "N Corp's Inquisition, in questions and answers. The answers are all hammers.", rarity = "epic", trait = "bl_ab_nailwork" },
	bl_book_outskirts_log = { name = "An Outskirts Hunter's Log", desc = "A dead hunter's notes on things past the fence. The last page is unfinished.", rarity = "rare", trait = "bl_ab_beast_reader" },
	bl_book_docent_sketches = { schools = { "ring" }, name = "A Docent's Sketchbook", desc = "Forty studies of one face, each slightly less like the face.", rarity = "epic", trait = "bl_ab_critics_eye" },
	bl_book_lamplighter_log = { name = "The Lamplighter's Logbook", desc = "Every light it ever lit, and every shadow it collected. Your name is near the end.", rarity = "legendary", trait = "bl_ab_afterimage" },
	bl_book_prodigy_margins = { name = "A Prodigy's Margins", desc = "An academy textbook with somebody brilliant's notes in every margin.", rarity = "rare", trait = "bl_ab_quick_study" },
	bl_book_drill_ledger = { name = "A Gym's Drill Ledger", desc = "Thirty years of an old trainer's counts. Read it and your feet start counting too.", rarity = "uncommon", trait = "bl_ab_drill_rhythm", mastery = 1 },
	bl_book_guest = { name = "A Guest's Book", desc = "A book the Library let you take: a whole stranger's life, and every fight they won.", rarity = "legendary", trait = "bl_ab_emotion_level" },
}
