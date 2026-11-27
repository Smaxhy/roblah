--[[
	Family names: rolled with earned rolls (never sold). Odds are shown to the player.
	Higher tiers carry a trait for every life with the name. The names come from
	docs/CANON.md section 10.2: original, in the City's mixed style, and checked against the
	games' text so none of them belongs to a canon character. `flavor` is shown on a roll.
]]

return {
	pityAt = 10,
	pityTier = "rare",
	tiers = {
		{ id = "common", name = "Common", weight = 60, color = { 190, 190, 196 }, desc = "An ordinary name. Nobody looks twice." },
		{ id = "uncommon", name = "Uncommon", weight = 25, color = { 120, 200, 140 }, desc = "A name people half-recognize: a shop, a small office, a street." },
		{ id = "rare", name = "Rare", weight = 10, color = { 100, 160, 240 }, trait = "backstreets_born", desc = "A respected Backstreets lineage. Comes with Backstreets Born." },
		{ id = "epic", name = "Epic", weight = 4, color = { 180, 110, 240 }, trait = "smoke_war_blood", desc = "A Feather dynasty, an Association elite or old money. Comes with Smoke War Blood, which runs in the line." },
		{ id = "legendary", name = "Legendary", weight = 1, color = { 255, 196, 80 }, trait = "old_blade_lineage", desc = "A near-myth. Comes with Blade Lineage." },
	},
	names = {
		common = {
			"Varga", "Okafor", "Brandt", "Moreau", "Seong", "Nakai", "Ruan", "Petrov", "Castell", "Halloran",
			"Ruiz", "Lindgren", "Kovac", "Ferro", "Dumont", "Baek", "Hoshida", "Tran", "Molnar", "Weller",
			"Szabo", "Orlandi", "Pyo", "Grieve", "Vondra", "Ilic", "Lacroix", "Haas", "Chae", "Albrecht",
			"Ostrowski", "Quiroga",
		},
		uncommon = {
			"Vasquez-Lim", "Steinhauer", "Morov", "Takamine", "Marchetti", "Kiyomura", "Falkenrath", "Hollisworth",
			"Szymczak", "Bellamy-Roux", "Dragomir", "Nakagawa-Reyes", "Volkhova", "Varhelyi", "Montclair",
			"Seo-Hartmann", "Quennell", "Lazarev", "Benedetti", "Ionescu", "Tsukahara", "Galloway",
		},
		rare = {
			"Halvorsen-Kim", "Castellane", "Ozols", "Kagetsu", "Varnaev", "Delmonte", "Wrenfield", "Seomun",
			"Lindqvist", "Adeyemi", "Fontaine-Ruiz", "Krzanowski", "Hoshikawa", "Valecourt",
		},
		epic = {
			"Rothwen", "Saint-Aubry", "Arcturo", "Valdereich", "Kozakura", "Marchbanks", "Vyshenko", "Heliodor",
			"Thornquist", "Bramleigh", "Seravin", "Ludovici",
		},
		legendary = { "Aurelle", "Nachtigall", "Eisenreich", "Solenne", "Valmonde", "Ilyrin" },
	},
	flavor = {
		["Halvorsen-Kim"] = "Three generations of couriers, and not one late delivery.",
		["Castellane"] = "Founders of a tiny dueling school whose rulebook proxies still swear by.",
		["Ozols"] = "Smiths whose spear hafts still turn up in pawnshops a century later.",
		["Kagetsu"] = "Former court retainers from a Nest that exiled them; now unbeatable bookkeepers.",
		["Varnaev"] = "Shield-for-hire Fixers whose front door has never been forced.",
		["Delmonte"] = "Restaurateurs who outlasted three turf wars by feeding every side.",
		["Wrenfield"] = "Street doctors; half the old scars in their District carry their stitching.",
		["Seomun"] = "Keepers of a night shelter that has opened its doors before 3:13 for forty years.",
		["Lindqvist"] = "Clockmakers who fix timepieces no Wing would admit to selling.",
		["Adeyemi"] = "Investigators who once sold a single file for the price of a Nest flat.",
		["Fontaine-Ruiz"] = "A Butler house that has served one estate for eighty years.",
		["Krzanowski"] = "Former Wing clerks who kept the old safety manuals when everyone else burned theirs.",
		["Hoshikawa"] = "Ex-members of a strict Syndicate who still flinch at paper slips.",
		["Valecourt"] = "A Workshop line known for blades that are never sold, only gifted.",
		["Rothwen"] = "Four generations of Wing platform chiefs; their badge opens doors money can't.",
		["Saint-Aubry"] = "Old Nest money that once bankrolled a Wing hopeful, and lost.",
		["Arcturo"] = "Two branches, each producing Section Directors, and never on speaking terms.",
		["Valdereich"] = "Said to have held a technology patent before a Wing bought them out.",
		["Kozakura"] = "A family that has sat on a Nest's governing board since before anyone's grandparents.",
		["Marchbanks"] = "Accountants to several Syndicates at once, and somehow still alive.",
		["Vyshenko"] = "A Workshop dynasty whose engraved weapon rings are status symbols.",
		["Heliodor"] = "Jewelers to Color Fixers. Their gems are said to sit in more than one famous hilt.",
		["Thornquist"] = "Their grandfather was pardoned by the Head's agents, and no one knows why.",
		["Bramleigh"] = "Their family archive has outlived two Wings.",
		["Seravin"] = "A lineage of master modifiers that Workshop Fixers apprentice under.",
		["Ludovici"] = "Patrons of avant-garde galleries that open only by invitation.",
		["Aurelle"] = "A Color once rose from this line, and the City says the title waits for the next.",
		["Nachtigall"] = "In Backstreets legend, the family whose lamp stays lit through the Night, untouched.",
		["Eisenreich"] = "Founders of a Wing whose letter was lost in the Smoke War.",
		["Solenne"] = "Survivors of the White Nights and Dark Days who claim the Light spoke their name.",
		["Valmonde"] = "Rumored couriers to the Head itself. Nobody can prove it, and nobody tries.",
		["Ilyrin"] = "Every generation produces exactly one child who never Distorts, whatever happens to them.",
	},
}
