--[[
	R6 LOOKS: every option the R6 character creator offers (pure data, no Instances).
	The same table is read by the creator (client), checked by the server (anything not in
	here is refused), and drawn by Hunter/R6Rig.luau on both sides.

	A look (saved per player as profile.Data.r6):
		{ skin, face, eyes, brows, hair, hairDye, top, topColor, trim, bottom, bottomColor,
		  shoes, gloves, armor, armorColor, weapon, extra, build, marks, eyeGlow, headwear,
		  back, backColor, aura, accessories }
	Every field is an option id below (colors are palette ids); `accessories` is a list of up to
	MAX_ACCESSORIES ids from Hunter/Accessories.luau, one per body slot. R6 has no body scaling,
	so `build` only changes how thick the clothes sit, never the rig.
	(Old saves had `gloves = true/false`: Looks.clean turns them into "gloves"/"none".)

	The flags on TOPS, BOTTOMS, SHOES, GLOVES, ARMOR, HEADWEAR and BACK are read by R6Rig to
	draw them. Two more flags are for picking:
		civ = true     a civilian can wear it (Looks.random { civilian = true } only picks these)
		cls = "a,b"    the Hunter classes it suits (Looks.random { class = "mage" } prefers these)
		combat = true  (HEADWEAR, BACK) gear a civilian never wears

	HAIR: Roblox's own free hair accessories (creator id 1; ids from the catalog, see
	tools/hair/roblox_hairs.json). The server loads each one with InsertService the first
	time someone wears it and keeps a copy in ReplicatedStorage for the previews. If one ever
	fails to load, the rig draws a block hair in its place (`fallback`).
]]

local Looks = {}

Looks.SKIN = {
	{ id = "porcelain", name = "Porcelain", color = { 255, 232, 214 } },
	{ id = "fair", name = "Fair", color = { 246, 214, 186 } },
	{ id = "light", name = "Light", color = { 234, 196, 160 } },
	{ id = "warm", name = "Warm Beige", color = { 220, 176, 136 } },
	{ id = "honey", name = "Honey", color = { 204, 154, 108 } },
	{ id = "olive", name = "Olive", color = { 186, 146, 102 } },
	{ id = "tan", name = "Tan", color = { 168, 120, 82 } },
	{ id = "bronze", name = "Bronze", color = { 142, 98, 64 } },
	{ id = "umber", name = "Umber", color = { 112, 74, 48 } },
	{ id = "deep", name = "Deep", color = { 86, 56, 38 } },
	{ id = "ebony", name = "Ebony", color = { 62, 42, 30 } },
	{ id = "classic", name = "Classic Yellow", color = { 245, 205, 48 } },
}

-- the palette every piece of clothing and every dye is picked from
Looks.PALETTE = {
	{ id = "black", name = "Black", color = { 24, 24, 28 } },
	{ id = "charcoal", name = "Charcoal", color = { 52, 54, 60 } },
	{ id = "slate", name = "Slate", color = { 88, 96, 108 } },
	{ id = "ash", name = "Ash Grey", color = { 150, 152, 158 } },
	{ id = "silver", name = "Silver", color = { 196, 200, 208 } },
	{ id = "white", name = "White", color = { 236, 236, 232 } },
	{ id = "ivory", name = "Ivory", color = { 240, 230, 206 } },
	{ id = "cream", name = "Cream", color = { 222, 206, 172 } },
	{ id = "sand", name = "Sand", color = { 200, 180, 140 } },
	{ id = "khaki", name = "Khaki", color = { 176, 160, 116 } },
	{ id = "tan", name = "Tan", color = { 186, 142, 96 } },
	{ id = "bronze", name = "Bronze", color = { 160, 108, 56 } },
	{ id = "brown", name = "Brown", color = { 98, 66, 42 } },
	{ id = "rust", name = "Rust", color = { 150, 66, 36 } },
	{ id = "orange", name = "Orange", color = { 230, 120, 40 } },
	{ id = "gold", name = "Gold", color = { 214, 172, 72 } },
	{ id = "red", name = "Red", color = { 214, 52, 52 } },
	{ id = "crimson", name = "Crimson", color = { 160, 28, 36 } },
	{ id = "wine", name = "Wine", color = { 102, 22, 40 } },
	{ id = "pink", name = "Pink", color = { 232, 140, 176 } },
	{ id = "lavender", name = "Lavender", color = { 176, 156, 226 } },
	{ id = "violet", name = "Violet", color = { 110, 60, 170 } },
	{ id = "plum", name = "Plum", color = { 84, 38, 86 } },
	{ id = "shadow", name = "Shadow Purple", color = { 50, 26, 80 } },
	{ id = "midnight", name = "Midnight", color = { 16, 20, 44 } },
	{ id = "navy", name = "Navy", color = { 26, 36, 72 } },
	{ id = "royal", name = "Royal Blue", color = { 46, 84, 190 } },
	{ id = "denim", name = "Denim", color = { 62, 92, 140 } },
	{ id = "mana", name = "Mana Blue", color = { 70, 150, 255 } },
	{ id = "sky", name = "Sky", color = { 140, 196, 240 } },
	{ id = "teal", name = "Teal", color = { 30, 130, 130 } },
	{ id = "mint", name = "Mint", color = { 150, 220, 190 } },
	{ id = "forest", name = "Forest", color = { 40, 84, 52 } },
	{ id = "olive", name = "Olive Drab", color = { 96, 100, 56 } },
}

Looks.HAIR_DYES = {
	{ id = "natural", name = "Natural (as made)" },
	{ id = "jet", name = "Jet Black", color = { 18, 18, 22 } },
	{ id = "dark_brown", name = "Dark Brown", color = { 58, 38, 26 } },
	{ id = "chestnut", name = "Chestnut", color = { 110, 64, 36 } },
	{ id = "auburn", name = "Auburn", color = { 140, 52, 32 } },
	{ id = "blonde", name = "Blonde", color = { 222, 190, 122 } },
	{ id = "ash_blonde", name = "Ash Blonde", color = { 196, 184, 160 } },
	{ id = "silver", name = "Silver", color = { 210, 212, 218 } },
	{ id = "white", name = "White", color = { 240, 240, 240 } },
	{ id = "navy", name = "Midnight Blue", color = { 30, 40, 90 } },
	{ id = "red", name = "Red", color = { 180, 30, 40 } },
	{ id = "pink", name = "Pink", color = { 236, 150, 186 } },
	{ id = "violet", name = "Violet", color = { 120, 70, 180 } },
	{ id = "teal", name = "Teal", color = { 40, 150, 150 } },
}

-- Roblox-made hair accessories (asset ids) with a block-hair fallback
Looks.HAIR = {
	{ id = 0, name = "Bald / shaved", fallback = "none" },
	{ id = 63690008, name = "Pal Hair", fallback = "messy" },
	{ id = 451220849, name = "Lavender Updo", fallback = "bun" },
	{ id = 451221329, name = "True Blue Hair", fallback = "long" },
	{ id = 9243992729, name = "Short and Sleek", fallback = "crop" },
	{ id = 9244021842, name = "Side Part", fallback = "slick" },
	{ id = 3814474927, name = "Cool Side Shave", fallback = "sidecut" },
	{ id = 376524487, name = "Spiked Hair", fallback = "spiky" },
	{ id = 376526888, name = "Straight Hair", fallback = "long" },
	{ id = 7193442167, name = "Pony Tail", fallback = "ponytail" },
	{ id = 7193448258, name = "Wavy Middle Part", fallback = "long" },
	{ id = 9174355709, name = "Sideswept Dreads", fallback = "braid" },
	{ id = 3814476174, name = "Long Braids", fallback = "braid" },
	{ id = 6993754725, name = "Straight Bangs", fallback = "bob" },
	{ id = 9244089488, name = "Medium Middle Part", fallback = "bob" },
	{ id = 9174354743, name = "Top Knot", fallback = "bun" },
	{ id = 7193450455, name = "Curly Afro", fallback = "curls" },
	{ id = 7193401217, name = "Short Fringe", fallback = "crop" },
	{ id = 9174353649, name = "Surfer", fallback = "messy" },
	{ id = 7193405096, name = "Curly Fade", fallback = "curls" },
	{ id = 376527350, name = "High Ponytail", fallback = "ponytail" },
	{ id = 376548738, name = "Charmer Hair", fallback = "slick" },
	{ id = 7193454569, name = "Braided Hair", fallback = "braid" },
	{ id = 7193452166, name = "Short Curls", fallback = "curls" },
	{ id = 62234425, name = "Classic Short Hair", fallback = "crop" },
	{ id = 2956239660, name = "Long Flowing Hair", fallback = "long" },
	{ id = 20573078, name = "Shaggy", fallback = "messy" },
	{ id = 16972690019, name = "Atomic Hairdo", fallback = "spiky" },
	{ id = 26658141, name = "Messy Hair", fallback = "messy" },
	{ id = 11913660, name = "Pigtails", fallback = "twintails" },
	{ id = 398672920, name = "Manga Hero Hair", fallback = "spiky" },
	{ id = 16630147, name = "Long Glossy Hair", fallback = "long" },
	{ id = 323476364, name = "Scene Hair", fallback = "bob" },
	{ id = 32278814, name = "Trecky Hair", fallback = "slick" },
	{ id = 21635620, name = "Samurai Hair", fallback = "bun" },
	{ id = 1772372988, name = "Long and Straight", fallback = "long" },
	{ id = 1708329071, name = "Action Ponytail", fallback = "ponytail" },
	{ id = 16131017, name = "Mullet", fallback = "messy" },
	{ id = 20372960, name = "Bed Hair", fallback = "messy" },
	{ id = 158066100, name = "Master Fighter", fallback = "spiky" },
	{ id = 3814450142, name = "Tall Spikes", fallback = "spiky" },
	{ id = 12819292, name = "Long Loose Hair", fallback = "long" },
	{ id = 295456068, name = "Dreamy Hair", fallback = "long" },
	{ id = 2397724806, name = "Count's Widow Peak", fallback = "slick" },
	{ id = 13477818, name = "Neat Short Hair", fallback = "crop" },
	{ id = 498747460, name = "Bowl Cut", fallback = "crop" },
	{ id = 212967757, name = "Chestnut Style", fallback = "bob" },
}

-- the face is drawn on the head (no decal ids to go missing): eyes, brows, mouth
Looks.FACE = {
	{ id = "calm", name = "Calm" },
	{ id = "focused", name = "Focused" },
	{ id = "smile", name = "Smile" },
	{ id = "grin", name = "Grin" },
	{ id = "stern", name = "Stern" },
	{ id = "tired", name = "Tired" },
	{ id = "fierce", name = "Fierce" },
	{ id = "soft", name = "Soft" },
}
Looks.EYES = {
	{ id = "brown", name = "Brown", color = { 70, 44, 28 } },
	{ id = "dark", name = "Near Black", color = { 24, 20, 20 } },
	{ id = "hazel", name = "Hazel", color = { 120, 96, 50 } },
	{ id = "green", name = "Green", color = { 60, 130, 80 } },
	{ id = "blue", name = "Blue", color = { 60, 110, 200 } },
	{ id = "grey", name = "Grey", color = { 120, 126, 136 } },
	{ id = "amber", name = "Amber", color = { 200, 140, 40 } },
	{ id = "violet", name = "Violet", color = { 130, 80, 190 } },
}
Looks.BROWS = {
	{ id = "straight", name = "Straight" },
	{ id = "arched", name = "Arched" },
	{ id = "thick", name = "Thick" },
	{ id = "thin", name = "Thin" },
	{ id = "angled", name = "Angled" },
	{ id = "none", name = "None" },
}

--[[ what's worn on the torso (and sleeves): each style is a set of shells over the R6 parts.
	sleeves  none | short | long | rolled | bell | layered | wide | puffy | mail
	the rest are pieces R6Rig.dressTop adds (open, collar = true|high|flare|fur|sailor|
	mandarin|hanbok|rib, hood, belt = true|rope|sash|pouches, tails = knee|ankle|tatter,
	robe = knee|long|split, runes, mantle, stole, surcoat, lamellar, straps, ...) ]]
Looks.TOPS = {
	-- everyday
	{ id = "tee", name = "T-shirt", group = "Everyday", civ = true, sleeves = "short" },
	{ id = "graphic_tee", name = "Gate-Print Tee", group = "Everyday", civ = true, sleeves = "short", print = true },
	{ id = "longsleeve", name = "Long Sleeve", group = "Everyday", civ = true, sleeves = "long" },
	{ id = "tank", name = "Tank Top", group = "Everyday", civ = true, sleeves = "none" },
	{ id = "turtleneck", name = "Turtleneck", group = "Everyday", civ = true, sleeves = "long", highNeck = true },
	{ id = "hoodie", name = "Hoodie", group = "Everyday", civ = true, cls = "assassin", sleeves = "long", hood = true, pocket = true, strings = true },
	{ id = "sleeveless_hoodie", name = "Sleeveless Hoodie", group = "Everyday", civ = true, sleeves = "none", hood = true, pocket = true },
	{ id = "tracksuit", name = "Tracksuit Jacket", group = "Everyday", civ = true, sleeves = "long", stripes = true, zips = true, collar = "mandarin" },
	{ id = "windbreaker", name = "Colour-Block Windbreaker", group = "Everyday", civ = true, sleeves = "long", colorblock = true, zips = true, collar = "mandarin" },
	{ id = "varsity", name = "Varsity Jacket", group = "Everyday", civ = true, sleeves = "long", sleeveTrim = true, collar = "rib", rib = true, buttons = "single", letter = true },
	{ id = "puffer", name = "Puffer Jacket", group = "Everyday", civ = true, sleeves = "puffy", bulk = true, bands = true, collar = "mandarin", zips = true },
	{ id = "cardigan", name = "Cardigan", group = "Everyday", civ = true, sleeves = "long", open = true, shirt = "white", buttons = "edge" },
	{ id = "apron", name = "Shop Apron", group = "Everyday", civ = true, sleeves = "short", apron = true },
	{ id = "chef", name = "Chef's Jacket", group = "Everyday", civ = true, sleeves = "long", buttons = "double", collar = "mandarin", cuffs = "trim" },
	-- coats and jackets
	{ id = "jacket", name = "Bomber Jacket", group = "Coats", civ = true, sleeves = "long", open = true, collar = true, rib = true },
	{ id = "leather", name = "Leather Jacket", group = "Coats", civ = true, cls = "fighter,assassin", sleeves = "long", open = true, collar = true, zips = true, leather = true },
	{ id = "coat", name = "Long Coat", group = "Coats", civ = true, cls = "fighter,mage", sleeves = "long", open = true, collar = true, tails = "knee" },
	{ id = "trench", name = "Trench Coat", group = "Coats", civ = true, cls = "ranger", sleeves = "long", open = true, collar = true, tails = "knee", belt = true },
	{ id = "fur_coat", name = "Hunter's Fur-Collar Coat", group = "Coats", cls = "fighter,ranger,tanker", sleeves = "long", open = true, collar = "fur", tails = "knee", belt = true, cuffs = "fur", bulk = true },
	{ id = "raid_coat", name = "Raid Leader's Coat", group = "Coats", cls = "fighter,tanker", sleeves = "long", buttons = "double", epaulettes = true, collar = "mandarin", tails = "knee", belt = true, cuffs = "trim", bulk = true },
	{ id = "duster", name = "Gate Duster", group = "Coats", cls = "ranger,assassin", sleeves = "long", open = true, collar = true, tails = "ankle", mantle = "short", belt = "pouches" },
	-- uniforms
	{ id = "suit", name = "Suit Jacket", group = "Uniforms", civ = true, sleeves = "long", open = true, tie = true, collar = true },
	{ id = "waistcoat", name = "Waistcoat & Shirt", group = "Uniforms", civ = true, sleeves = "long", waistcoat = true, tie = true },
	{ id = "office_shirt", name = "Office Shirt & Tie", group = "Uniforms", civ = true, sleeves = "rolled", shirtBody = true, tie = true, collar = true },
	{ id = "uniform", name = "School Uniform", group = "Uniforms", civ = true, sleeves = "long", tie = true, collar = true },
	{ id = "blazer", name = "School Blazer", group = "Uniforms", civ = true, sleeves = "long", open = true, shirt = "white", tie = true, crest = true },
	{ id = "sailor", name = "Sailor-Collar Uniform", group = "Uniforms", civ = true, sleeves = "long", collar = "sailor", cuffs = "trim" },
	{ id = "assoc", name = "Association Blazer", group = "Uniforms", sleeves = "long", open = true, tie = true, badge = true, collar = true },
	{ id = "assoc_field", name = "Association Field Jacket", group = "Uniforms", sleeves = "long", pockets = true, armband = true, badge = true, collar = "mandarin", zips = true, belt = "pouches", bulk = true },
	{ id = "assoc_officer", name = "Association Officer's Coat", group = "Uniforms", sleeves = "long", buttons = "double", epaulettes = true, badge = true, collar = true, tails = "knee", belt = true, cuffs = "trim" },
	{ id = "guild", name = "Guild Uniform", group = "Uniforms", cls = "fighter", sleeves = "long", collar = true, emblem = true, belt = true },
	{ id = "guild_fighter", name = "Guild Uniform: Vanguard", group = "Uniforms", cls = "fighter", sleeves = "long", collar = "mandarin", emblem = true, belt = "sash", bracers = true, sidePanel = true },
	{ id = "guild_mage", name = "Guild Uniform: Arcanist", group = "Uniforms", cls = "mage", sleeves = "bell", collar = "high", emblem = "circle", robe = "knee", belt = "sash", runes = "small" },
	{ id = "guild_assassin", name = "Guild Uniform: Shadow", group = "Uniforms", cls = "assassin", sleeves = "long", collar = "high", straps = true, wraps = true, emblem = true, belt = "sash" },
	{ id = "guild_tank", name = "Guild Uniform: Bulwark", group = "Uniforms", cls = "tanker", sleeves = "long", quilt = true, emblem = "big", collar = "mandarin", bulk = true, belt = true },
	{ id = "guild_ranger", name = "Guild Uniform: Pathfinder", group = "Uniforms", cls = "ranger", sleeves = "rolled", hood = true, emblem = true, pockets = true, belt = "pouches" },
	{ id = "guild_healer", name = "Guild Uniform: Mender", group = "Uniforms", cls = "healer", sleeves = "long", stole = true, emblem = "cross", collar = "mandarin", tails = "knee", cuffs = "trim" },
	-- robes
	{ id = "robe", name = "Mage's Robe", group = "Robes", cls = "mage", sleeves = "bell", robe = "long", hood = true, belt = "sash", runes = "small" },
	{ id = "battle_robe", name = "Battle-Mage Robe", group = "Robes", cls = "mage", sleeves = "long", bracers = true, robe = "split", mantle = "plate", belt = "pouches", runes = true, collar = "mandarin" },
	{ id = "archmage", name = "Archmage Robe", group = "Robes", cls = "mage", sleeves = "layered", robe = "long", collar = "high", belt = "sash", runes = true, mantle = true },
	{ id = "priest", name = "Priest's Vestments", group = "Robes", cls = "healer", sleeves = "bell", robe = "long", stole = true, emblem = "sun", collar = "mandarin" },
	{ id = "monk", name = "Monk's Robe", group = "Robes", cls = "healer,fighter", sleeves = "wide", wrap = true, robe = "long", belt = "rope", kesa = true },
	{ id = "travel_robe", name = "Hooded Travelling Robe", group = "Robes", cls = "mage,ranger", sleeves = "long", robe = "long", hood = true, cloak = true, belt = "pouches" },
	{ id = "sorcerer", name = "Sorcerer's Coat", group = "Robes", cls = "mage", sleeves = "long", cuffs = "rune", open = true, shirt = "col", collar = "flare", tails = "ankle", runes = true },
	{ id = "ritual", name = "Ritual Robe", group = "Robes", cls = "mage,healer", sleeves = "bell", robe = "long", tabard = true, hood = true, belt = "sash", runes = "column" },
	{ id = "summoner", name = "Summoner's Robe", group = "Robes", cls = "mage", sleeves = "layered", robe = "long", collar = "high", emblem = "circle", belt = "rope", runes = "small" },
	-- combat wear
	{ id = "tactical", name = "Tactical Shirt", group = "Combat", cls = "ranger,tanker", sleeves = "long", pockets = true },
	{ id = "jerkin", name = "Padded Jerkin", group = "Combat", cls = "fighter,tanker,ranger", sleeves = "long", quilt = true, collar = "mandarin", belt = true },
	{ id = "gi", name = "Martial Gi", group = "Combat", civ = true, cls = "fighter", sleeves = "wide", wrap = true, belt = "rope" },
	{ id = "brawler_vest", name = "Brawler's Vest", group = "Combat", cls = "fighter", sleeves = "none", vest = true, wraps = true, belt = "sash" },
	{ id = "knight_surcoat", name = "Knight's Surcoat", group = "Combat", cls = "tanker,fighter", sleeves = "mail", surcoat = "diamond", belt = true },
	{ id = "templar", name = "Holy Tabard", group = "Combat", cls = "healer,tanker", sleeves = "mail", surcoat = "cross", belt = true, mantle = true },
	{ id = "lamellar", name = "Lamellar Coat", group = "Combat", cls = "fighter,tanker", sleeves = "long", lamellar = true, collar = "mandarin" },
	{ id = "assassin_garb", name = "Assassin's Garb", group = "Combat", cls = "assassin", sleeves = "long", wraps = true, straps = true, collar = "high", belt = "sash", sidePanel = true },
	{ id = "shadow_cloak", name = "Shadow Cloak-Coat", group = "Combat", cls = "assassin", sleeves = "long", collar = "high", tails = "tatter", hood = true, straps = true, runes = "small" },
	{ id = "ranger_leathers", name = "Ranger Leathers", group = "Combat", cls = "ranger", sleeves = "rolled", vest = true, laces = true, bracers = true, belt = "pouches", hood = true },
	{ id = "medic", name = "Healer's Coat", group = "Combat", civ = true, cls = "healer", sleeves = "long", open = true, collar = true, tails = "knee", cross = true, pockets = true },
	-- traditional (Korean hanbok-inspired)
	{ id = "hanbok", name = "Hanbok Jacket", group = "Traditional", civ = true, sleeves = "wide", collar = "hanbok", cuffs = "white" },
	{ id = "durumagi", name = "Hanbok Overcoat", group = "Traditional", civ = true, cls = "mage,healer", sleeves = "wide", collar = "hanbok", robe = "long", cuffs = "white" },
}
Looks.BOTTOMS = {
	{ id = "jeans", name = "Jeans", civ = true, seams = true },
	{ id = "slacks", name = "Slacks", civ = true, crease = true },
	{ id = "cargo", name = "Cargo Pants", civ = true, cls = "ranger,tanker,fighter", pockets = true },
	{ id = "joggers", name = "Joggers", civ = true, cls = "assassin", cuffs = true },
	{ id = "track_pants", name = "Track Pants", civ = true, stripes = true, cuffs = true },
	{ id = "shorts", name = "Shorts", civ = true, short = true },
	{ id = "ripped", name = "Ripped Jeans", civ = true, rips = true, seams = true },
	{ id = "wide", name = "Wide Trousers", civ = true, cls = "fighter", wide = true },
	{ id = "baji", name = "Hanbok Trousers", civ = true, wide = true, ties = true },
	{ id = "hakama", name = "Hakama", civ = true, cls = "fighter", hakama = true },
	{ id = "skirt", name = "Pleated Skirt", civ = true, skirt = "pleat" },
	{ id = "long_skirt", name = "Long Skirt", civ = true, cls = "healer", skirt = "long" },
	{ id = "tactical_skirt", name = "Tactical Skirt", cls = "assassin,ranger", skirt = "pleat", pockets = true },
	{ id = "tactical_pants", name = "Tactical Pants", cls = "tanker,ranger,fighter", pockets = true, kneepads = true, holster = true },
	{ id = "leather_pants", name = "Laced Leather Trousers", cls = "fighter,assassin,mage", laces = true, leather = true },
	{ id = "breeches", name = "Ranger Breeches", cls = "ranger", straps = true, leather = true },
	{ id = "wrapped", name = "Wrapped Trousers", cls = "assassin", wraps = true },
	{ id = "robe_skirt", name = "Robe Skirt", cls = "mage,healer", robe = "ankle" },
	{ id = "long_robe", name = "Long Robe Hem", cls = "mage,healer", robe = "floor" },
	{ id = "split_robe", name = "Split Robe over Trousers", cls = "mage,fighter", robe = "split" },
	{ id = "armored", name = "Armored Greaves", cls = "tanker,fighter", plates = true },
	{ id = "armored_skirt", name = "Armored Skirt", cls = "tanker,fighter", tassets = true },
	{ id = "plate_legs", name = "Full Plate Legs", cls = "tanker", plates = true, cuisses = true },
	{ id = "chain_skirt", name = "Mail Skirt", cls = "tanker,healer", mail = true },
}
Looks.SHOES = {
	{ id = "sneakers", name = "Sneakers", civ = true },
	{ id = "hightops", name = "High-Top Sneakers", civ = true, high = true },
	{ id = "runners", name = "Running Shoes", civ = true, trimSole = true },
	{ id = "dress", name = "Dress Shoes", civ = true, cls = "healer" },
	{ id = "loafers", name = "Loafers", civ = true, low = true, loafer = true },
	{ id = "sandals", name = "Sandals", civ = true, low = true },
	{ id = "geta", name = "Wooden Clogs", civ = true, low = true, wood = true },
	{ id = "boots", name = "Combat Boots", civ = true, cls = "fighter,ranger,tanker", tall = true },
	{ id = "knee_boots", name = "Tall Riding Boots", civ = true, cls = "ranger,mage,fighter", knee = true },
	{ id = "tabi", name = "Split-Toe Wraps", cls = "assassin", tabi = true },
	{ id = "curled", name = "Pointed Mage Shoes", cls = "mage,healer", curled = true },
	{ id = "sabatons", name = "Armored Sabatons", cls = "tanker", tall = true, metal = true },
	{ id = "greaves", name = "Greaved War Boots", cls = "tanker,fighter", knee = true, metal = true },
}
-- on the hands (old saves: `gloves = true` is "gloves", false is "none")
Looks.GLOVES = {
	{ id = "none", name = "Bare hands", civ = true },
	{ id = "gloves", name = "Black Gloves", civ = true },
	{ id = "leather", name = "Leather Gloves", civ = true, cls = "fighter,ranger" },
	{ id = "fingerless", name = "Fingerless Gloves", civ = true, cls = "assassin,ranger" },
	{ id = "work", name = "Work Gloves", civ = true },
	{ id = "silk", name = "White Formal Gloves", civ = true, cls = "healer" },
	{ id = "medical", name = "Medical Gloves", civ = true, cls = "healer" },
	{ id = "wraps", name = "Hand Wraps", cls = "fighter,assassin" },
	{ id = "long", name = "Long Gloves", cls = "mage,assassin" },
	{ id = "mage", name = "Rune Gloves", cls = "mage" },
	{ id = "bracers", name = "Leather Bracers", cls = "ranger,fighter" },
	{ id = "gauntlets", name = "Plate Gauntlets", cls = "tanker,fighter" },
	{ id = "claws", name = "Clawed Gauntlets", cls = "assassin" },
}
-- Hunter gear over the clothes (the look only; real gear is bought in a life)
Looks.ARMOR = {
	{ id = "none", name = "No armor" },
	{ id = "vest", name = "Raid Vest", cls = "ranger,tanker" },
	{ id = "harness", name = "Strap Harness", cls = "assassin,ranger" },
	{ id = "leather_armor", name = "Leather Cuirass", cls = "ranger,assassin,fighter" },
	{ id = "shadow_leather", name = "Shadow Leathers", cls = "assassin" },
	{ id = "archer_guard", name = "Archer's Guard", cls = "ranger" },
	{ id = "mage_bracers", name = "Mage's Rune Bracers", cls = "mage" },
	{ id = "cloak", name = "Shoulder Cloak", cls = "mage,ranger" },
	{ id = "pauldrons", name = "Pauldrons", cls = "fighter" },
	{ id = "single_pauldron", name = "War Pauldron", cls = "fighter" },
	{ id = "breastplate", name = "Breastplate", cls = "fighter,healer" },
	{ id = "chainmail", name = "Chainmail", cls = "tanker,healer" },
	{ id = "brigandine", name = "Riveted Brigandine", cls = "fighter,tanker" },
	{ id = "scale", name = "Scale Armor", cls = "fighter,tanker" },
	{ id = "plate", name = "Plate Cuirass", cls = "fighter,tanker" },
	{ id = "heavy", name = "Tank Armor", cls = "tanker" },
	{ id = "full_plate", name = "Full Plate", cls = "tanker" },
	{ id = "holy_plate", name = "Gilded Holy Plate", cls = "healer,tanker" },
	{ id = "spiked", name = "Spiked Plate", cls = "fighter,tanker" },
	{ id = "dragon_scale", name = "Dragon-Scale Armor", cls = "fighter" },
	{ id = "bone", name = "Trophy Bone Armor", cls = "fighter,assassin" },
}
-- the weapon a look carries in the creator: the workshop weapons (★). A life's own weapon,
-- whatever its rarity, replaces it in the city (Hunter/Weapons.luau)
local Weapons = require(script.Parent:WaitForChild("Weapons"))
local Accessories = require(script.Parent:WaitForChild("Accessories"))
Looks.Accessories = Accessories
Looks.MAX_ACCESSORIES = 4
Looks.WEAPONS = { { id = "none", name = "Unarmed" } }
for _, w in Weapons.list do
	if w.price then
		table.insert(Looks.WEAPONS, { id = w.id, name = w.name, family = w.family })
	end
end
-- on the face and around the neck (coversFace: hides part of the face on purpose)
Looks.EXTRAS = {
	{ id = "none", name = "Nothing", civ = true },
	{ id = "glasses", name = "Glasses", civ = true },
	{ id = "round_glasses", name = "Round Glasses", civ = true },
	{ id = "shades", name = "Sunglasses", civ = true, coversFace = true },
	{ id = "monocle", name = "Monocle", civ = true },
	{ id = "visor", name = "Tactical Visor", cls = "ranger,tanker" },
	{ id = "eyepatch", name = "Eyepatch", coversFace = true },
	{ id = "mask", name = "Face Mask", civ = true, coversFace = true },
	{ id = "medical", name = "Medical Mask", civ = true, coversFace = true },
	{ id = "half_mask", name = "Raider's Half Mask", cls = "assassin", coversFace = true },
	{ id = "demon_mask", name = "Demon Half Mask", cls = "assassin,fighter", coversFace = true },
	{ id = "face_veil", name = "Face Veil", cls = "assassin,healer", coversFace = true },
	{ id = "respirator", name = "Respirator", cls = "tanker", coversFace = true },
	{ id = "gaiter", name = "Neck Gaiter", civ = true, cls = "ranger,assassin" },
	{ id = "scarf", name = "Scarf", civ = true },
	{ id = "headband", name = "Headband", civ = true, cls = "fighter" },
	{ id = "cap", name = "Cap", civ = true },
	{ id = "beanie", name = "Beanie", civ = true },
	{ id = "earpiece", name = "Association Earpiece" },
	{ id = "headset", name = "Headset Mic", civ = true },
	{ id = "earrings", name = "Earrings", civ = true },
	{ id = "crystal_earring", name = "Mana-Crystal Earring", cls = "mage" },
	{ id = "ear_cuffs", name = "Ear Cuffs", civ = true },
	{ id = "choker", name = "Choker", civ = true },
	{ id = "necklace", name = "Pendant", civ = true, cls = "healer,mage" },
	{ id = "bead_necklace", name = "Bead Necklace", civ = true, cls = "healer" },
	{ id = "dog_tags", name = "Dog Tags", civ = true, cls = "tanker,fighter" },
	{ id = "lanyard", name = "ID Lanyard", civ = true },
	{ id = "bandage", name = "Bandaged Cheek", civ = true },
	{ id = "nose_band", name = "Nose Bandage", civ = true },
}

-- marks on the face: scars a Gate left, freckles, paint (drawn on the face plate)
Looks.MARKS = {
	{ id = "none", name = "None" },
	{ id = "scar_eye", name = "Scar Over the Eye" },
	{ id = "scar_cheek", name = "Cheek Scar" },
	{ id = "scar_nose", name = "Scar Across the Nose" },
	{ id = "scar_cross", name = "Crossed Scar" },
	{ id = "scar_lip", name = "Split-Lip Scar" },
	{ id = "claw", name = "Claw Marks" },
	{ id = "burn", name = "Burn Scar" },
	{ id = "freckles", name = "Freckles" },
	{ id = "beauty", name = "Beauty Mark" },
	{ id = "blush", name = "Blush" },
	{ id = "dark_circles", name = "Dark Circles" },
	{ id = "war_paint", name = "War Paint" },
	{ id = "tear", name = "Tear Mark" },
	{ id = "mana_veins", name = "Mana Veins (glow)", glow = true },
}
-- eyes that shine with mana (a glow drawn over the irises, unlit)
Looks.EYE_GLOW = {
	{ id = "none", name = "No glow" },
	{ id = "blue", name = "Mana Blue", color = { 90, 180, 255 } },
	{ id = "red", name = "Red", color = { 255, 60, 60 } },
	{ id = "gold", name = "Gold", color = { 255, 200, 70 } },
	{ id = "violet", name = "Violet", color = { 180, 110, 255 } },
	{ id = "green", name = "Green", color = { 110, 255, 150 } },
	{ id = "white", name = "White", color = { 235, 245, 255 } },
}
-- on the head, over the hair (some cover it; coversFace: a closed helm, on purpose)
Looks.HEADWEAR = {
	{ id = "none", name = "Nothing", civ = true },
	{ id = "bandana", name = "Bandana", civ = true, cls = "fighter,ranger" },
	{ id = "headphones", name = "Headphones", civ = true },
	{ id = "hairpin", name = "Crystal Hairpin", civ = true, cls = "mage,healer" },
	{ id = "ribbon", name = "Hair Ribbon", civ = true },
	{ id = "bucket_hat", name = "Bucket Hat", civ = true, hidesHair = true },
	{ id = "beret", name = "Beret", civ = true },
	{ id = "fur_hat", name = "Fur Hat", civ = true, hidesHair = true },
	{ id = "gat", name = "Scholar's Gat", civ = true, cls = "mage" },
	{ id = "sedge_hat", name = "Wanderer's Straw Hat", civ = true, cls = "ranger,assassin" },
	{ id = "festival_mask", name = "Festival Mask (worn aside)", civ = true },
	{ id = "hardhat", name = "Mining Hard Hat", civ = true, hidesHair = true },
	{ id = "goggles", name = "Hunter Goggles", cls = "ranger,tanker" },
	{ id = "officer_cap", name = "Association Officer's Cap", hidesHair = true },
	{ id = "feather_cap", name = "Feathered Ranger Cap", cls = "ranger", hidesHair = true },
	{ id = "mage_hat", name = "Mage's Hat", cls = "mage" },
	{ id = "circlet", name = "Mana Circlet", cls = "mage,healer" },
	{ id = "tiara", name = "Silver Tiara", cls = "healer,mage" },
	{ id = "crown", name = "Raid King's Crown", cls = "fighter,tanker" },
	{ id = "spectral_crown", name = "Spectral Crown (glow)", cls = "mage", combat = true },
	{ id = "halo", name = "Mana Halo (glow)", cls = "healer", combat = true },
	{ id = "healer_veil", name = "Healer's Veil", cls = "healer" },
	{ id = "hood", name = "Hood Up", cls = "ranger,assassin,mage", hidesHair = true, combat = true },
	{ id = "cowl", name = "Deep Cowl", cls = "mage,assassin", hidesHair = true, combat = true },
	{ id = "assassin_wrap", name = "Assassin's Wrap", cls = "assassin", hidesHair = true, combat = true, coversFace = true },
	{ id = "horns", name = "Demon Horns", cls = "fighter,assassin", combat = true },
	{ id = "raid_helmet", name = "Raid Helmet", cls = "tanker,ranger", hidesHair = true, combat = true },
	{ id = "half_helm", name = "Open Half-Helm", cls = "tanker,fighter", hidesHair = true, combat = true },
	{ id = "kabuto", name = "Lamellar Helm", cls = "fighter,tanker", hidesHair = true, combat = true },
	{ id = "winged_helm", name = "Winged Helm", cls = "tanker,healer", hidesHair = true, combat = true },
	{ id = "horned_helm", name = "Horned Helm", cls = "fighter,tanker", hidesHair = true, combat = true },
	{ id = "spiked_helm", name = "Spiked War Helm", cls = "fighter", hidesHair = true, combat = true },
	{ id = "knight_helm", name = "Knight's Helm", cls = "tanker", hidesHair = true, combat = true, coversFace = true },
}
-- on the back (combat: never on a civilian)
Looks.BACK = {
	{ id = "none", name = "Nothing", civ = true },
	{ id = "pack", name = "Raid Pack", civ = true, cls = "ranger,tanker" },
	{ id = "school_bag", name = "School Bag", civ = true },
	{ id = "guitar_case", name = "Instrument Case", civ = true },
	{ id = "medic_pack", name = "Medic Pack", civ = true, cls = "healer" },
	{ id = "scrolls", name = "Scroll Case", civ = true, cls = "mage,healer" },
	{ id = "long_scarf", name = "Long Trailing Scarf", civ = true, cls = "assassin,fighter" },
	{ id = "crystal_crate", name = "Crystal Crate", civ = true },
	{ id = "cape", name = "Cape", cls = "fighter,mage" },
	{ id = "long_cape", name = "Commander's Cape", cls = "fighter,tanker" },
	{ id = "half_cape", name = "Duelist's Half Cape", cls = "fighter,assassin" },
	{ id = "tattered", name = "Tattered Cape", cls = "assassin,fighter" },
	{ id = "hooded_cloak", name = "Hooded Cloak", cls = "ranger,mage" },
	{ id = "fur_cape", name = "Fur Mantle Cape", cls = "fighter,tanker" },
	{ id = "banner", name = "Guild Banner", combat = true },
	{ id = "quiver", name = "Quiver", cls = "ranger", combat = true },
	{ id = "bow", name = "Bow on the Back", cls = "ranger", combat = true },
	{ id = "spear", name = "Spear on the Back", cls = "ranger,fighter", combat = true },
	{ id = "sheath", name = "Back Sheath", cls = "fighter", combat = true },
	{ id = "twin_sheaths", name = "Crossed Twin Sheaths", cls = "assassin", combat = true },
	{ id = "greatsword", name = "Greatsword on the Back", cls = "fighter", combat = true },
	{ id = "shield", name = "Back Shield", cls = "tanker", combat = true },
	{ id = "round_shield", name = "Round Shield", cls = "tanker", combat = true },
	{ id = "tower_shield", name = "Tower Shield", cls = "tanker", combat = true },
	{ id = "staff", name = "Staff on the Back", cls = "mage", combat = true },
	{ id = "grimoire", name = "Chained Grimoire", cls = "mage", combat = true },
	{ id = "lantern", name = "Spirit Lantern", cls = "healer", combat = true },
	{ id = "rune_ring", name = "Floating Rune Circle (glow)", cls = "mage", combat = true },
	{ id = "mana_wings", name = "Mana Wings (glow)", cls = "healer,mage", combat = true },
	{ id = "shadow_wings", name = "Shadow Wings (glow)", cls = "assassin", combat = true },
}
-- mana around the body: particles and a light (the rank's colour, or one you pick)
Looks.AURA = {
	{ id = "none", name = "No aura" },
	{ id = "rank", name = "My Rank's Colour" },
	{ id = "mana", name = "Mana Blue", color = { 90, 170, 255 } },
	{ id = "crimson", name = "Crimson", color = { 255, 60, 70 } },
	{ id = "violet", name = "Violet", color = { 170, 100, 255 } },
	{ id = "gold", name = "Gold", color = { 255, 200, 80 } },
	{ id = "frost", name = "Frost", color = { 170, 230, 255 } },
	{ id = "verdant", name = "Verdant", color = { 110, 230, 130 } },
	{ id = "ember", name = "Ember", color = { 255, 130, 50 } },
	{ id = "void", name = "Void", color = { 70, 44, 110 } },
}
-- the colour of each rank (Spec forms), for the Rank aura: 0 unawakened, 1 E .. 6 S
Looks.RANK_COLORS = {
	[0] = { 200, 200, 210 },
	{ 150, 160, 170 }, { 120, 200, 150 }, { 110, 170, 255 }, { 190, 120, 255 }, { 255, 170, 70 }, { 255, 90, 90 },
}
Looks.RANK_LETTERS = { [0] = "-", "E", "D", "C", "B", "A", "S" }

-- the Hunter classes (the creator's class tabs, "wear your class", the class dice): the colours
-- each wears best, and the weapon families it fights with
Looks.CLASSES = {
	{ id = "fighter", name = "Fighter", color = { 230, 90, 70 }, tops = { "black", "charcoal", "crimson", "brown", "slate", "wine", "navy" }, trims = { "gold", "red", "orange", "silver", "mana" }, metals = { "slate", "silver", "charcoal", "black", "crimson" }, weapons = { sword = true, katana = true, greatsword = true, axe = true, axes = true, cleaver = true, gauntlets = true } },
	{ id = "mage", name = "Mage", color = { 120, 150, 255 }, tops = { "navy", "shadow", "violet", "royal", "midnight", "plum", "white" }, trims = { "gold", "mana", "violet", "silver", "sky" }, metals = { "gold", "silver", "navy", "shadow" }, weapons = { staff = true, wand = true, orb = true, tome = true } },
	{ id = "assassin", name = "Assassin", color = { 170, 100, 230 }, tops = { "black", "charcoal", "shadow", "midnight", "wine" }, trims = { "violet", "crimson", "red", "silver", "lavender" }, metals = { "black", "charcoal", "shadow" }, weapons = { dagger = true, daggers = true, rapier = true, claws = true } },
	{ id = "tanker", name = "Tanker", color = { 120, 170, 200 }, tops = { "slate", "olive", "charcoal", "navy", "brown", "wine" }, trims = { "gold", "orange", "mana", "silver" }, metals = { "slate", "silver", "gold", "charcoal" }, weapons = { shield = true, hammer = true, mace = true, halberd = true } },
	{ id = "ranger", name = "Ranger", color = { 110, 200, 120 }, tops = { "forest", "olive", "brown", "khaki", "tan", "teal" }, trims = { "khaki", "gold", "tan", "orange", "cream" }, metals = { "brown", "olive", "bronze", "forest" }, weapons = { bow = true, crossbow = true, spear = true } },
	{ id = "healer", name = "Healer", color = { 240, 220, 140 }, tops = { "white", "ivory", "cream", "teal", "sky", "royal" }, trims = { "gold", "teal", "mana", "white", "pink" }, metals = { "gold", "silver", "white", "ivory" }, weapons = { censer = true, rod = true } },
}
-- the creator's preset shelves
Looks.CATEGORIES = {
	{ id = "fighter", name = "Fighter" },
	{ id = "mage", name = "Mage" },
	{ id = "assassin", name = "Assassin" },
	{ id = "tanker", name = "Tanker" },
	{ id = "ranger", name = "Ranger" },
	{ id = "healer", name = "Healer" },
	{ id = "association", name = "Association" },
	{ id = "guild", name = "Guild" },
	{ id = "civilian", name = "Civilian" },
	{ id = "iconic", name = "Iconic" },
}

--[[ whole outfits in one click (the creator's PRESETS tab). A preset sets the whole outfit
	(anything it doesn't name is taken off: OUTFIT_BLANK) and leaves who you are (skin, face,
	hair, marks) alone unless it names them. `cat` is its shelf, `rank` the rank it's for. ]]
Looks.PRESETS = {
	-- FIGHTER: E to S
	{ id = "fighter_e", acc = { "acc_recruit_belt" }, cat = "fighter", rank = "E", name = "E-Rank Recruit", desc = "A padded jerkin, a shortsword, and everything to prove.", look = { top = "jerkin", topColor = "brown", trim = "tan", bottom = "cargo", bottomColor = "charcoal", shoes = "boots", gloves = "leather", armor = "none", armorColor = "brown", back = "pack", backColor = "olive", weapon = "shortsword" } },
	{ id = "brawler", acc = { "acc_red_tassel", "acc_brawler_bracer" }, cat = "fighter", rank = "D", name = "Martial Fighter", desc = "A gi, wraps on the hands, an ember in the fists.", look = { top = "gi", topColor = "white", trim = "black", bottom = "hakama", bottomColor = "black", shoes = "geta", armor = "none", headwear = "bandana", gloves = "wraps", aura = "ember", marks = "scar_cheek", weapon = "iron_knuckles" } },
	{ id = "fighter_c", acc = { "acc_orc_tusk_amulet", "acc_ember_bracelet" }, cat = "fighter", rank = "C", name = "Vanguard", desc = "Leather, one war pauldron and a crystal blade.", look = { top = "leather", topColor = "black", trim = "red", bottom = "leather_pants", bottomColor = "black", shoes = "knee_boots", gloves = "fingerless", armor = "single_pauldron", armorColor = "silver", back = "sheath", backColor = "black", weapon = "crystal_longsword", extra = "dog_tags" } },
	{ id = "fighter_a", acc = { "acc_titan_grip", "acc_blood_ruby_ring" }, cat = "fighter", rank = "A", name = "Blademaster", desc = "Fur collar, riveted brigandine, a scarf that's been through fire.", look = { top = "fur_coat", topColor = "charcoal", trim = "gold", bottom = "breeches", bottomColor = "black", shoes = "greaves", gloves = "leather", armor = "brigandine", armorColor = "crimson", back = "long_scarf", backColor = "crimson", weapon = "plain_katana", aura = "rank" } },
	{ id = "fighter_s", acc = { "acc_dragonheart", "acc_warlord_brooch" }, cat = "fighter", rank = "S", name = "Red Gate Warlord", desc = "Dragon scale, a crimson cape and eyes that don't blink.", look = { top = "raid_coat", topColor = "black", trim = "gold", bottom = "plate_legs", bottomColor = "black", shoes = "greaves", gloves = "gauntlets", armor = "dragon_scale", armorColor = "crimson", back = "long_cape", backColor = "crimson", headwear = "crown", weapon = "crystal_longsword", aura = "crimson", eyeGlow = "red" } },
	-- MAGE
	{ id = "mage_e", acc = { "acc_apprentice_ring", "acc_chalk_pouch" }, cat = "mage", rank = "E", name = "Apprentice", desc = "A travelling robe, a wand and a case of notes.", look = { top = "travel_robe", topColor = "brown", trim = "khaki", bottom = "slacks", bottomColor = "brown", shoes = "boots", armor = "none", back = "scrolls", backColor = "brown", weapon = "apprentice_wand" } },
	{ id = "mage", acc = { "acc_quartz_earring" }, cat = "mage", rank = "D", name = "Mage", desc = "The robe, the hat, the staff, and mana in the eyes.", look = { top = "robe", topColor = "navy", trim = "gold", bottom = "slacks", bottomColor = "navy", shoes = "curled", armor = "none", headwear = "mage_hat", back = "scrolls", backColor = "brown", eyeGlow = "blue", aura = "mana", weapon = "mana_staff" } },
	{ id = "mage_c", acc = { "acc_floating_shard", "acc_ink_bracelet" }, cat = "mage", rank = "C", name = "Battle-Mage", desc = "Plated mantle, rune bracers, a split robe for running.", look = { top = "battle_robe", topColor = "navy", trim = "mana", bottom = "leather_pants", bottomColor = "black", shoes = "knee_boots", gloves = "mage", armor = "mage_bracers", armorColor = "slate", back = "grimoire", backColor = "brown", weapon = "focus_orb", eyeGlow = "blue" } },
	{ id = "mage_a", acc = { "acc_twin_orbs", "acc_archmage_seal", "acc_frostglass_pendant" }, cat = "mage", rank = "A", name = "Archmage", desc = "Layered sleeves, embroidered runes, a circle that turns behind you.", look = { top = "archmage", topColor = "shadow", trim = "gold", bottom = "long_robe", bottomColor = "violet", shoes = "curled", armor = "none", headwear = "circlet", back = "rune_ring", backColor = "violet", weapon = "mana_staff", aura = "violet", eyeGlow = "violet" } },
	{ id = "mage_s", acc = { "acc_starcore_amulet", "acc_archmage_seal", "acc_void_prism" }, cat = "mage", rank = "S", name = "Starcaller", desc = "A sorcerer's coat, a crown of light. The sky listens.", look = { top = "sorcerer", topColor = "midnight", trim = "sky", bottom = "long_robe", bottomColor = "navy", shoes = "curled", gloves = "long", armor = "mage_bracers", armorColor = "silver", headwear = "spectral_crown", back = "rune_ring", backColor = "sky", weapon = "mana_staff", aura = "mana", eyeGlow = "blue" } },
	-- ASSASSIN
	{ id = "assassin_e", acc = { "acc_shadow_wrap", "acc_black_stud" }, cat = "assassin", rank = "E", name = "Shadow Initiate", desc = "Dark hoodie, a gaiter up, one steel dagger.", look = { top = "hoodie", topColor = "charcoal", trim = "violet", bottom = "joggers", bottomColor = "black", shoes = "hightops", gloves = "fingerless", armor = "none", extra = "gaiter", weapon = "steel_dagger" } },
	{ id = "assassin", acc = { "acc_smoke_pouch" }, cat = "assassin", rank = "D", name = "Assassin", desc = "Dark wraps, light feet, a blade across the back.", look = { top = "hoodie", topColor = "black", trim = "violet", bottom = "joggers", bottomColor = "black", shoes = "sneakers", armor = "harness", armorColor = "black", headwear = "assassin_wrap", back = "sheath", backColor = "black", eyeGlow = "violet", build = "slim", weapon = "twin_stilettos" } },
	{ id = "assassin_c", acc = { "acc_knife_belt", "acc_hidden_blade" }, cat = "assassin", rank = "C", name = "Night Blade", desc = "Wrapped and strapped, a cowl, twin blades crossed.", look = { top = "assassin_garb", topColor = "black", trim = "crimson", bottom = "wrapped", bottomColor = "black", shoes = "tabi", gloves = "wraps", armor = "shadow_leather", armorColor = "charcoal", headwear = "cowl", back = "twin_sheaths", backColor = "black", weapon = "twin_stilettos" } },
	{ id = "assassin_a", acc = { "acc_venom_fang_ring", "acc_night_moth", "acc_eclipse_earring" }, cat = "assassin", rank = "A", name = "Silent Fang", desc = "Guild shadow-cut, a demon mask, venom on the kris.", look = { top = "guild_assassin", topColor = "shadow", trim = "violet", bottom = "wrapped", bottomColor = "black", shoes = "tabi", gloves = "claws", armor = "shadow_leather", armorColor = "black", extra = "demon_mask", back = "twin_sheaths", backColor = "shadow", weapon = "spider_kris", eyeGlow = "violet" } },
	{ id = "assassin_s", acc = { "acc_nightfall_eye", "acc_void_blades", "acc_eclipse_earring" }, cat = "assassin", rank = "S", name = "Nightfall", desc = "A coat of tatters and shadow wings. You saw nothing.", look = { top = "shadow_cloak", topColor = "black", trim = "violet", bottom = "wrapped", bottomColor = "black", shoes = "tabi", gloves = "claws", armor = "none", headwear = "cowl", back = "shadow_wings", backColor = "black", weapon = "spider_kris", aura = "void", eyeGlow = "violet" } },
	{ id = "rogue", acc = { "acc_venom_vial" }, cat = "assassin", rank = "B", name = "Rogue Hunter", desc = "Leather, a half mask, a red glow nobody trusts.", look = { top = "leather", topColor = "black", trim = "red", bottom = "ripped", bottomColor = "charcoal", shoes = "boots", armor = "harness", armorColor = "crimson", extra = "half_mask", back = "tattered", backColor = "black", eyeGlow = "red", aura = "crimson", marks = "scar_eye" } },
	-- TANKER
	{ id = "tank_e", acc = { "acc_iron_band", "acc_oak_charm" }, cat = "tanker", rank = "E", name = "Shieldbearer", desc = "A padded jerkin, a raid vest and a police-surplus shield.", look = { top = "jerkin", topColor = "olive", trim = "khaki", bottom = "cargo", bottomColor = "olive", shoes = "boots", gloves = "work", armor = "vest", armorColor = "olive", headwear = "half_helm", back = "round_shield", backColor = "olive", weapon = "riot_shield", build = "broad" } },
	{ id = "tank", acc = { "acc_steel_buckle" }, cat = "tanker", rank = "C", name = "Tanker", desc = "Heavy armor and a shield on the back.", look = { top = "tactical", topColor = "olive", trim = "orange", bottom = "armored", bottomColor = "olive", shoes = "sabatons", armor = "heavy", armorColor = "slate", headwear = "knight_helm", back = "shield", backColor = "slate", build = "broad" } },
	{ id = "tank_c", acc = { "acc_shield_pin", "acc_golem_core" }, cat = "tanker", rank = "C", name = "Bulwark", desc = "Guild quilting under a plate cuirass, a tower shield on the back.", look = { top = "guild_tank", topColor = "slate", trim = "orange", bottom = "tactical_pants", bottomColor = "charcoal", shoes = "greaves", gloves = "gauntlets", armor = "plate", armorColor = "slate", headwear = "raid_helmet", back = "tower_shield", backColor = "slate", weapon = "iron_mace", build = "broad" } },
	{ id = "tank_a", acc = { "acc_aegis_brooch", "acc_mountain_ring" }, cat = "tanker", rank = "A", name = "Iron Fortress", desc = "A knight's surcoat over full plate. Nothing gets past.", look = { top = "knight_surcoat", topColor = "navy", trim = "silver", bottom = "plate_legs", bottomColor = "charcoal", shoes = "sabatons", gloves = "gauntlets", armor = "full_plate", armorColor = "silver", headwear = "knight_helm", back = "tower_shield", backColor = "navy", weapon = "stonebreaker", build = "broad" } },
	{ id = "tank_s", acc = { "acc_unbroken_heart", "acc_fortress_sigil" }, cat = "tanker", rank = "S", name = "Aegis Titan", desc = "Gilded full plate, a winged helm, a wall of gold.", look = { top = "lamellar", topColor = "wine", trim = "gold", bottom = "plate_legs", bottomColor = "wine", shoes = "sabatons", gloves = "gauntlets", armor = "full_plate", armorColor = "gold", headwear = "winged_helm", back = "long_cape", backColor = "wine", weapon = "tower_shield", aura = "gold", eyeGlow = "gold", build = "broad" } },
	{ id = "frost_knight", acc = { "acc_titanhide_mantle" }, cat = "tanker", rank = "A", name = "Frost Knight", desc = "Silver plate, horned helm, frost on the breath.", look = { top = "guild", topColor = "silver", trim = "mana", bottom = "armored", bottomColor = "silver", shoes = "sabatons", armor = "heavy", armorColor = "silver", headwear = "horned_helm", back = "long_cape", backColor = "navy", aura = "frost", eyeGlow = "white" } },
	-- RANGER
	{ id = "ranger_e", acc = { "acc_wolf_tooth", "acc_thumb_ring" }, cat = "ranger", rank = "E", name = "Scout", desc = "Field shirt, goggles up, a quiver and a hunting bow.", look = { top = "tactical", topColor = "forest", trim = "khaki", bottom = "cargo", bottomColor = "olive", shoes = "boots", gloves = "fingerless", armor = "none", headwear = "goggles", back = "quiver", backColor = "brown", weapon = "hunting_bow" } },
	{ id = "ranger", acc = { "acc_hawk_feather" }, cat = "ranger", rank = "D", name = "Ranger", desc = "Field coat, quiver, a hood against the weather.", look = { top = "trench", topColor = "forest", trim = "khaki", bottom = "cargo", bottomColor = "olive", shoes = "boots", armor = "pauldrons", armorColor = "brown", headwear = "hood", back = "quiver", backColor = "brown", weapon = "hunting_bow" } },
	{ id = "ranger_c", acc = { "acc_windleaf", "acc_eagle_eye" }, cat = "ranger", rank = "C", name = "Pathfinder", desc = "Guild field uniform, a feathered cap, an archer's guard.", look = { top = "guild_ranger", topColor = "forest", trim = "gold", bottom = "breeches", bottomColor = "brown", shoes = "knee_boots", gloves = "leather", armor = "archer_guard", armorColor = "brown", headwear = "feather_cap", back = "quiver", backColor = "brown", weapon = "hunting_bow" } },
	{ id = "ranger_a", acc = { "acc_sylvan_bracers", "acc_moonbow_earring", "acc_storm_quiver" }, cat = "ranger", rank = "A", name = "Windrunner", desc = "Laced leathers, a leather cuirass, the hood up.", look = { top = "ranger_leathers", topColor = "brown", trim = "cream", bottom = "breeches", bottomColor = "olive", shoes = "knee_boots", gloves = "bracers", armor = "leather_armor", armorColor = "rust", headwear = "hood", extra = "gaiter", back = "quiver", backColor = "rust", weapon = "composite_bow" } },
	{ id = "ranger_s", acc = { "acc_starfall_pendant", "acc_falcon_spirit", "acc_greenwood_circlet" }, cat = "ranger", rank = "S", name = "Starfall Archer", desc = "A duster that's crossed every Gate, a cloak, green light in the eyes.", look = { top = "duster", topColor = "forest", trim = "gold", bottom = "breeches", bottomColor = "brown", shoes = "knee_boots", gloves = "bracers", armor = "archer_guard", armorColor = "gold", back = "hooded_cloak", backColor = "forest", weapon = "composite_bow", aura = "verdant", eyeGlow = "green" } },
	-- HEALER
	{ id = "healer_e", acc = { "acc_bandage_pouch", "acc_prayer_beads" }, cat = "healer", rank = "E", name = "Field Medic", desc = "A healer's coat, medical gloves and a full medic pack.", look = { top = "medic", topColor = "white", trim = "teal", bottom = "cargo", bottomColor = "slate", shoes = "sneakers", gloves = "medical", armor = "none", back = "medic_pack", backColor = "white", extra = "lanyard" } },
	{ id = "healer", acc = { "acc_tin_symbol" }, cat = "healer", rank = "D", name = "Healer", desc = "White coat, the veil, a quiet glow.", look = { top = "medic", topColor = "white", trim = "teal", bottom = "slacks", bottomColor = "white", shoes = "dress", armor = "none", headwear = "healer_veil", back = "scrolls", backColor = "white", aura = "verdant" } },
	{ id = "healer_c", acc = { "acc_dawn_symbol", "acc_mender_ribbon", "acc_mercy_ring" }, cat = "healer", rank = "C", name = "Cleric", desc = "The Mender's uniform, the veil and a lantern that closes wounds.", look = { top = "guild_healer", topColor = "ivory", trim = "gold", bottom = "long_skirt", bottomColor = "cream", shoes = "dress", gloves = "silk", armor = "none", headwear = "healer_veil", back = "lantern", backColor = "gold", weapon = "mercy_lantern" } },
	{ id = "healer_a", acc = { "acc_little_censer", "acc_lifebloom", "acc_mercy_ring" }, cat = "healer", rank = "A", name = "High Priest", desc = "Vestments, a stole of gold, a silver tiara.", look = { top = "priest", topColor = "ivory", trim = "gold", bottom = "long_robe", bottomColor = "white", shoes = "curled", gloves = "silk", armor = "none", headwear = "tiara", extra = "necklace", back = "lantern", backColor = "gold", weapon = "mercy_lantern", aura = "gold" } },
	{ id = "healer_s", acc = { "acc_heart_of_dawn", "acc_last_light_ring", "acc_spirit_wisp" }, cat = "healer", rank = "S", name = "Saint of Dawn", desc = "Gilded plate over white, a halo and wings of light.", look = { top = "templar", topColor = "white", trim = "gold", bottom = "long_robe", bottomColor = "ivory", shoes = "curled", gloves = "silk", armor = "holy_plate", armorColor = "gold", headwear = "halo", back = "mana_wings", backColor = "white", weapon = "mercy_lantern", aura = "gold", eyeGlow = "gold" } },
	-- ASSOCIATION
	{ id = "assoc_agent", cat = "association", name = "Association Agent", desc = "Black blazer, the badge, an earpiece.", look = { top = "assoc", topColor = "black", trim = "white", bottom = "slacks", bottomColor = "black", shoes = "dress", armor = "none", extra = "earpiece", headwear = "none", back = "none", aura = "none" } },
	{ id = "assoc_officer", acc = { "acc_valour_medal" }, cat = "association", name = "Association Officer", desc = "The officer's coat and cap, gold on navy.", look = { top = "assoc_officer", topColor = "navy", trim = "gold", bottom = "slacks", bottomColor = "navy", shoes = "dress", gloves = "silk", armor = "none", headwear = "officer_cap", extra = "lanyard" } },
	{ id = "assoc_field", acc = { "acc_gate_compass" }, cat = "association", name = "Association Field Team", desc = "Field jacket, armband, raid helmet. First through the cordon.", look = { top = "assoc_field", topColor = "navy", trim = "mana", bottom = "tactical_pants", bottomColor = "charcoal", shoes = "boots", gloves = "gloves", armor = "vest", armorColor = "charcoal", headwear = "raid_helmet", back = "pack", backColor = "charcoal", weapon = "assoc_longsword" } },
	{ id = "surveillance", cat = "association", name = "Surveillance Team", desc = "Tactical shirt, goggles, a pack of sensors.", look = { top = "tactical", topColor = "navy", trim = "mana", bottom = "cargo", bottomColor = "charcoal", shoes = "boots", armor = "vest", armorColor = "navy", headwear = "goggles", back = "pack", backColor = "navy", extra = "earpiece" } },
	{ id = "assoc_research", cat = "association", name = "Association Researcher", desc = "Lab coat, round glasses, a crystal sample in the case.", look = { top = "medic", topColor = "white", trim = "mana", bottom = "slacks", bottomColor = "charcoal", shoes = "loafers", gloves = "medical", armor = "none", extra = "round_glasses", back = "scrolls", backColor = "slate" } },
	{ id = "collector", cat = "association", name = "Collection Crew", desc = "Hard hat, work clothes, a crate of crystals.", look = { top = "tactical", topColor = "orange", trim = "silver", bottom = "cargo", bottomColor = "charcoal", shoes = "boots", armor = "vest", armorColor = "orange", headwear = "hardhat", back = "crystal_crate", backColor = "slate", gloves = "work" } },
	-- GUILD
	{ id = "guild_recruit", acc = { "acc_licence_pin" }, cat = "guild", rank = "E", name = "Guild Recruit", desc = "Fresh guild colours and a raid pack.", look = { top = "guild", topColor = "navy", trim = "gold", bottom = "tactical_pants", bottomColor = "charcoal", shoes = "boots", gloves = "gloves", armor = "none", back = "pack", backColor = "navy", weapon = "shortsword" } },
	{ id = "striker", acc = { "acc_champion_belt" }, cat = "guild", rank = "B", name = "Guild Striker", desc = "Guild colours, plate, a cape that's seen a few Gates.", look = { top = "guild_fighter", topColor = "crimson", trim = "gold", bottom = "armored", bottomColor = "black", shoes = "sabatons", armor = "plate", armorColor = "slate", back = "cape", backColor = "crimson", aura = "rank", weapon = "assoc_longsword" } },
	{ id = "guild_arcanist", acc = { "acc_sigil_circlet", "acc_star_chart" }, cat = "guild", rank = "B", name = "Guild Arcanist", desc = "The Arcanist cut, a grimoire on a chain.", look = { top = "guild_mage", topColor = "royal", trim = "gold", bottom = "robe_skirt", bottomColor = "navy", shoes = "curled", gloves = "mage", armor = "none", headwear = "hairpin", back = "grimoire", backColor = "brown", weapon = "focus_orb", eyeGlow = "blue" } },
	{ id = "commander", acc = { "acc_valour_medal", "acc_guild_signet" }, cat = "guild", rank = "S", name = "Raid Commander", desc = "The long cape, a circlet, an S-rank's bearing.", look = { top = "raid_coat", topColor = "white", trim = "gold", bottom = "slacks", bottomColor = "white", shoes = "knee_boots", gloves = "silk", armor = "pauldrons", armorColor = "gold", back = "long_cape", backColor = "navy", headwear = "circlet", aura = "gold" } },
	{ id = "guild_master", acc = { "acc_gold_chain", "acc_guild_signet" }, cat = "guild", rank = "S", name = "Guild Master", desc = "The officer's coat, the guild's banner. Everyone follows.", look = { top = "raid_coat", topColor = "wine", trim = "gold", bottom = "breeches", bottomColor = "black", shoes = "knee_boots", gloves = "leather", armor = "single_pauldron", armorColor = "gold", back = "banner", backColor = "wine", extra = "monocle", aura = "rank" } },
	-- CIVILIAN
	{ id = "student", cat = "civilian", name = "Student", desc = "School uniform and a bag. Not awakened. Yet.", look = { top = "uniform", topColor = "navy", trim = "red", bottom = "slacks", bottomColor = "charcoal", shoes = "sneakers", armor = "none", weapon = "none", headwear = "none", back = "school_bag", backColor = "navy", aura = "none", eyeGlow = "none" } },
	{ id = "sailor_student", cat = "civilian", name = "Sailor Uniform", desc = "The sailor collar, a ribbon, loafers.", look = { top = "sailor", topColor = "white", trim = "navy", bottom = "skirt", bottomColor = "navy", shoes = "loafers", headwear = "ribbon", back = "school_bag", backColor = "brown" } },
	{ id = "office", cat = "civilian", name = "Office Worker", desc = "Waistcoat, tie, tired eyes. Gates are on the news.", look = { top = "waistcoat", topColor = "charcoal", trim = "white", bottom = "slacks", bottomColor = "charcoal", shoes = "dress", armor = "none", weapon = "none", headwear = "none", back = "none", aura = "none", marks = "dark_circles", face = "tired", extra = "lanyard" } },
	{ id = "salaryman", cat = "civilian", name = "Overtime", desc = "Shirt sleeves rolled up, tie loosened, glasses on.", look = { top = "office_shirt", topColor = "white", trim = "navy", bottom = "slacks", bottomColor = "charcoal", shoes = "dress", extra = "glasses" } },
	{ id = "shopkeeper", cat = "civilian", name = "Shopkeeper", desc = "The family restaurant's apron and a bandana.", look = { top = "apron", topColor = "white", trim = "crimson", bottom = "jeans", bottomColor = "denim", shoes = "sneakers", armor = "none", weapon = "none", headwear = "bandana", back = "none", aura = "none" } },
	{ id = "chef", cat = "civilian", name = "Chef", desc = "Double-breasted whites and a beret worn like a crown.", look = { top = "chef", topColor = "white", trim = "black", bottom = "slacks", bottomColor = "black", shoes = "loafers", headwear = "beret", extra = "none" } },
	{ id = "streetwear", acc = { "acc_silver_studs" }, cat = "civilian", name = "Streetwear", desc = "Varsity jacket, high-tops, a bucket hat and headphones round the neck.", look = { top = "varsity", topColor = "black", trim = "cream", bottom = "ripped", bottomColor = "denim", shoes = "hightops", headwear = "bucket_hat", extra = "ear_cuffs", back = "none" } },
	{ id = "runner", cat = "civilian", name = "Morning Run", desc = "Tracksuit, running shoes, headphones on.", look = { top = "tracksuit", topColor = "royal", trim = "white", bottom = "track_pants", bottomColor = "royal", shoes = "runners", headwear = "headphones" } },
	{ id = "winter", acc = { "acc_leather_band" }, cat = "civilian", name = "Winter Commute", desc = "Puffer jacket, a fur hat and a scarf to the nose.", look = { top = "puffer", topColor = "olive", trim = "cream", bottom = "jeans", bottomColor = "denim", shoes = "boots", gloves = "gloves", headwear = "fur_hat", extra = "scarf" } },
	{ id = "hanbok_day", acc = { "acc_jade_ring" }, cat = "civilian", name = "Hanbok Day", desc = "A hanbok jacket with a ribbon tie, a long skirt and a pin in the hair.", look = { top = "hanbok", topColor = "pink", trim = "crimson", bottom = "long_skirt", bottomColor = "royal", shoes = "loafers", headwear = "hairpin", extra = "none" } },
	{ id = "scholar", cat = "civilian", name = "Hanbok Scholar", desc = "The overcoat, the gat, a string of beads.", look = { top = "durumagi", topColor = "ivory", trim = "navy", bottom = "baji", bottomColor = "cream", shoes = "loafers", headwear = "gat", extra = "bead_necklace" } },
	-- ICONIC: original looks
	{ id = "gate_breaker", acc = { "acc_gatebreaker_mantle", "acc_blood_ruby_ring" }, cat = "iconic", rank = "S", name = "Gate Breaker", desc = "Black fur coat, a greatsword on the back, red eyes. The break stops here.", look = { top = "fur_coat", topColor = "black", trim = "crimson", bottom = "leather_pants", bottomColor = "black", shoes = "boots", gloves = "leather", armor = "spiked", armorColor = "charcoal", back = "greatsword", backColor = "black", weapon = "none", eyeGlow = "red", aura = "crimson", marks = "scar_eye" } },
	{ id = "frost_empress", acc = { "acc_frostglass_pendant", "acc_twin_orbs" }, cat = "iconic", rank = "S", name = "Frost Empress", desc = "White archmage robes, a crown of ice-light, winter in the air.", look = { top = "archmage", topColor = "white", trim = "sky", bottom = "long_robe", bottomColor = "sky", shoes = "curled", armor = "none", headwear = "spectral_crown", back = "mana_wings", backColor = "sky", weapon = "focus_orb", aura = "frost", eyeGlow = "white" } },
	{ id = "crimson_duelist", acc = { "acc_warlord_brooch", "acc_blood_ruby_ring" }, cat = "iconic", rank = "A", name = "Crimson Duelist", desc = "A sorcerer's cut in wine and gold, a half cape, a rapier.", look = { top = "sorcerer", topColor = "wine", trim = "gold", bottom = "leather_pants", bottomColor = "black", shoes = "knee_boots", gloves = "silk", armor = "breastplate", armorColor = "gold", back = "half_cape", backColor = "crimson", weapon = "duelist_rapier", extra = "earrings" } },
	{ id = "ashen_wanderer", acc = { "acc_red_tassel", "acc_lucky_coin" }, cat = "iconic", rank = "B", name = "Ashen Wanderer", desc = "Grey travelling robe, a straw hat, a katana nobody's seen drawn.", look = { top = "travel_robe", topColor = "ash", trim = "charcoal", bottom = "baji", bottomColor = "charcoal", shoes = "sandals", gloves = "wraps", armor = "none", headwear = "sedge_hat", back = "sheath", backColor = "charcoal", weapon = "plain_katana" } },
	{ id = "summoner_queen", acc = { "acc_ninth_circle", "acc_archmage_seal" }, cat = "iconic", rank = "S", name = "Summoner of the Deep", desc = "Plum summoner's robes, demon horns, a circle of runes.", look = { top = "summoner", topColor = "plum", trim = "lavender", bottom = "long_robe", bottomColor = "shadow", shoes = "curled", gloves = "long", armor = "none", headwear = "horns", back = "rune_ring", backColor = "lavender", weapon = "focus_orb", aura = "void", eyeGlow = "violet" } },
}
Looks.BUILD = {
	{ id = "slim", name = "Slim", pad = 0.04 },
	{ id = "regular", name = "Regular", pad = 0.08 },
	{ id = "broad", name = "Broad", pad = 0.14 },
}

Looks.DEFAULT = {
	skin = "light", face = "calm", eyes = "brown", brows = "straight",
	hair = 9243992729, hairDye = "jet",
	top = "jacket", topColor = "charcoal", trim = "mana",
	bottom = "cargo", bottomColor = "black",
	shoes = "boots", gloves = "none",
	armor = "none", armorColor = "slate",
	weapon = "none", extra = "none", build = "regular",
	marks = "none", eyeGlow = "none", headwear = "none", back = "none", backColor = "charcoal", aura = "none",
	accessories = {},
}
-- what a preset takes off when it doesn't name it (the outfit, not the person)
Looks.OUTFIT_BLANK = {
	accessories = {},
	gloves = "none", armor = "none", weapon = "none", extra = "none", headwear = "none", back = "none", aura = "none", eyeGlow = "none",
}

-- the fields that pick from each list
Looks.FIELDS = {
	skin = "SKIN", face = "FACE", eyes = "EYES", brows = "BROWS", hair = "HAIR", hairDye = "HAIR_DYES",
	top = "TOPS", topColor = "PALETTE", trim = "PALETTE", bottom = "BOTTOMS", bottomColor = "PALETTE",
	shoes = "SHOES", gloves = "GLOVES", armor = "ARMOR", armorColor = "PALETTE", weapon = "WEAPONS", extra = "EXTRAS", build = "BUILD",
	marks = "MARKS", eyeGlow = "EYE_GLOW", headwear = "HEADWEAR", back = "BACK", backColor = "PALETTE", aura = "AURA",
}
-- the order the creator shows them in, with their tab (each piece is followed by its colour)
Looks.TABS = {
	{ id = "presets", name = "Presets", presets = true, fields = {} },
	{ id = "body", name = "Body", fields = { "skin", "build", "aura" } },
	{ id = "face", name = "Face", fields = { "face", "eyes", "eyeGlow", "brows", "marks", "extra" } },
	{ id = "hair", name = "Head", fields = { "hair", "hairDye", "headwear" } },
	{ id = "clothes", name = "Outfit", fields = { "top", "topColor", "trim", "bottom", "bottomColor", "shoes", "gloves" } },
	{ id = "gear", name = "Gear", fields = { "armor", "armorColor", "back", "backColor", "weapon" } },
	{ id = "accessories", name = "Accessories", accessories = true, fields = {} },
	{ id = "colors", name = "Colours", fields = { "topColor", "trim", "bottomColor", "armorColor", "backColor", "hairDye" } },
}
Looks.LABELS = {
	skin = "Skin tone", build = "Build", face = "Expression", eyes = "Eye color", brows = "Brows", extra = "Face and neck",
	hair = "Hairstyle", hairDye = "Hair color", top = "Top", topColor = "Top color", trim = "Trim color",
	bottom = "Bottoms", bottomColor = "Bottoms color", shoes = "Shoes", gloves = "Gloves", armor = "Armor",
	armorColor = "Armor color", weapon = "Weapon",
	marks = "Scars and marks", eyeGlow = "Eye glow", headwear = "Headwear", back = "On your back", backColor = "Back color", aura = "Aura", accessories = "Accessories",
}

local index: { [string]: { [any]: any } } = {}
for _, listName in { "SKIN", "PALETTE", "HAIR_DYES", "HAIR", "FACE", "EYES", "BROWS", "TOPS", "BOTTOMS", "SHOES", "GLOVES", "ARMOR", "WEAPONS", "EXTRAS", "BUILD", "MARKS", "EYE_GLOW", "HEADWEAR", "BACK", "AURA", "PRESETS", "CLASSES", "CATEGORIES" } do
	local m = {}
	for _, o in Looks[listName] do
		m[o.id] = o
	end
	index[listName] = m
end

function Looks.find(listName: string, id: any): any
	local m = index[listName]
	return m and m[id]
end

function Looks.color(listName: string, id: any): { number }?
	local o = Looks.find(listName, id)
	return o and o.color
end

-- does an option suit a class? (no `cls`: it suits nobody in particular)
function Looks.suits(option: any, class: string): boolean
	local cls = option and option.cls
	return type(cls) == "string" and string.find("," .. cls .. ",", "," .. class .. ",", 1, true) ~= nil
end

-- a look the server can trust: every field one of the options, anything else the default
function Looks.clean(raw: any): any
	local out = table.clone(Looks.DEFAULT)
	if type(raw) ~= "table" then
		return out
	end
	for field, listName in Looks.FIELDS do
		local v = raw[field]
		if v ~= nil and Looks.find(listName, v) then
			out[field] = v
		end
	end
	-- (old saves: gloves were a yes/no)
	if raw.gloves == true then
		out.gloves = "gloves"
	elseif raw.gloves == false then
		out.gloves = "none"
	end
	out.accessories = Looks.cleanAccessories(raw.accessories)
	return out
end

-- a list of accessories the server can trust: known ids, one per body slot, at most
-- MAX_ACCESSORIES (a later one in the same slot is dropped)
function Looks.cleanAccessories(raw: any): { string }
	local out = {}
	if type(raw) ~= "table" then
		return out
	end
	local used = {}
	for i = 1, math.min(#raw, 16) do
		local a = Accessories.find(raw[i])
		if a and not used[a.slot] and #out < Looks.MAX_ACCESSORIES then
			used[a.slot] = true
			table.insert(out, a.id)
		end
	end
	return out
end

-- put an accessory on (taking off whatever's in its slot, and the oldest if all are full), or
-- take it off if it's on: a new list
function Looks.toggleAccessory(list: { string }?, id: string): { string }
	local a = Accessories.find(id)
	local out = {}
	local had = false
	local current: { string } = list or {}
	for _, other in current do
		local o = Accessories.find(other)
		if other == id then
			had = true
		elseif o and not (a and o.slot == a.slot) then
			table.insert(out, other)
		end
	end
	if a and not had then
		if #out >= Looks.MAX_ACCESSORIES then
			table.remove(out, 1)
		end
		table.insert(out, id)
	end
	return out
end

-- a look with a preset laid over it: the preset's whole outfit (what it doesn't name comes
-- off), and who you are stays unless the preset names it
function Looks.applyPreset(look: any, presetId: string): any
	local p = Looks.find("PRESETS", presetId)
	local out = table.clone(look)
	if p then
		for k, v in Looks.OUTFIT_BLANK do
			out[k] = v
		end
		for k, v in p.look do
			out[k] = v
		end
		out.accessories = p.acc or {}
	end
	return Looks.clean(out)
end

-- the presets on a shelf (Looks.CATEGORIES), in order
function Looks.presetsIn(cat: string): { any }
	local out = {}
	for _, p in Looks.PRESETS do
		if p.cat == cat then
			table.insert(out, p)
		end
	end
	return out
end

local RANK_OF = { E = 1, D = 2, C = 3, B = 4, A = 5, S = 6 }
-- the class's outfit for a rank (0 unawakened .. 6 S): the best of its presets at or under it
function Looks.classPreset(class: string, rank: number?): string?
	local best, bestRank = nil, -1
	local first, firstRank = nil, math.huge
	for _, p in Looks.PRESETS do
		if p.cat == class and p.rank then
			local r = RANK_OF[p.rank] or 1
			if r <= math.max(rank or 0, 1) and r > bestRank then
				best, bestRank = p.id, r
			end
			if r < firstRank then
				first, firstRank = p.id, r
			end
		end
	end
	return best or first
end

-- a random look (NPCs, the creator's dice). opts.civilian: only what a civilian wears;
-- opts.class: a Hunter of that class (its clothes, colours and weapons); neither: a Hunter
-- of any class
function Looks.random(rand: (number, number) -> number, opts: any?): any
	local civilian = opts and opts.civilian or (opts and opts.class == "civilian")
	local class = if civilian then nil else (opts and Looks.find("CLASSES", opts.class))
	if not civilian and not class then
		class = Looks.CLASSES[rand(1, #Looks.CLASSES)]
	end
	local function pick(list)
		return list[rand(1, #list)].id
	end
	-- from a list: what suits the class (or what a civilian wears), else anything
	local function pickFor(list: { any }, allowNone: boolean?): any
		local pool = {}
		for _, o in list do
			if civilian then
				if o.civ then
					table.insert(pool, o)
				end
			elseif class and Looks.suits(o, class.id) then
				table.insert(pool, o)
			end
		end
		if #pool == 0 then
			for _, o in list do
				if not civilian or o.civ then
					table.insert(pool, o)
				end
			end
		end
		if allowNone and #pool == 0 then
			return "none"
		end
		return pool[rand(1, #pool)].id
	end
	local function palette(ids: { string }?): string
		if ids and #ids > 0 then
			return ids[rand(1, #ids)]
		end
		return pick(Looks.PALETTE)
	end
	local l = {
		skin = pick(Looks.SKIN),
		face = pick(Looks.FACE),
		eyes = pick(Looks.EYES),
		brows = pick(Looks.BROWS),
		hair = pick(Looks.HAIR),
		hairDye = pick(Looks.HAIR_DYES),
		top = pickFor(Looks.TOPS),
		topColor = palette(class and class.tops),
		trim = palette(class and class.trims),
		bottom = pickFor(Looks.BOTTOMS),
		bottomColor = palette(class and class.tops),
		shoes = pickFor(Looks.SHOES),
		gloves = if rand(1, 3) == 1 then pickFor(Looks.GLOVES) else "none",
		armor = "none",
		armorColor = palette(class and class.metals),
		weapon = "none",
		extra = if rand(1, 3) == 1 then pickFor(Looks.EXTRAS) else "none",
		build = pick(Looks.BUILD),
		marks = if rand(1, 3) == 1 then pick(Looks.MARKS) else "none",
		eyeGlow = "none",
		headwear = if rand(1, 3) == 1 then pickFor(Looks.HEADWEAR) else "none",
		back = "none",
		backColor = palette(class and class.tops),
		aura = "none",
		accessories = {},
	}
	if class then
		l.armor = if rand(1, 3) > 1 then pickFor(Looks.ARMOR) else "none"
		l.back = if rand(1, 2) == 1 then pickFor(Looks.BACK) else "none"
		l.eyeGlow = if rand(1, 5) == 1 then pick(Looks.EYE_GLOW) else "none"
		l.aura = if rand(1, 6) == 1 then pick(Looks.AURA) else "none"
		local weapons = {}
		for _, w in Looks.WEAPONS do
			if w.family and class.weapons[w.family] then
				table.insert(weapons, w.id)
			end
		end
		l.weapon = if #weapons > 0 and rand(1, 4) > 1 then weapons[rand(1, #weapons)] else "none"
		-- a few of the class's accessories (and maybe one anyone wears)
		local acc = {}
		local own = Accessories.ofClass(class.id)
		for _ = 1, rand(0, 2) do
			acc = Looks.toggleAccessory(acc, own[rand(1, #own)].id)
		end
		if rand(1, 3) == 1 then
			local any = Accessories.ofClass("any")
			acc = Looks.toggleAccessory(acc, any[rand(1, #any)].id)
		end
		l.accessories = acc
	end
	if civilian then
		-- (never combat gear on a civilian, whatever the lists say)
		local hw = Looks.find("HEADWEAR", l.headwear)
		if not hw or hw.combat or not hw.civ then
			l.headwear = "none"
		end
		-- (now and then a ring or a chain: the general set's low grades)
		if rand(1, 4) == 1 then
			local cheap = {}
			for _, a in Accessories.ofClass("any") do
				if Accessories.GRADE_OF[a.grade] <= 2 then
					table.insert(cheap, a.id)
				end
			end
			l.accessories = { cheap[rand(1, #cheap)] }
		end
		if rand(1, 4) == 1 then
			l.back = pickFor(Looks.BACK)
			local b = Looks.find("BACK", l.back)
			if not b or b.combat then
				l.back = "none"
			end
		end
	end
	if l.skin == "classic" and rand(1, 3) > 1 then
		l.skin = "light"
	end
	return l
end

return Looks
