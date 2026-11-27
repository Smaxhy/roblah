--[[
	R6 LOOKS: every option the R6 character creator offers (pure data, no Instances).
	The same table is read by the creator (client), checked by the server (anything not in
	here is refused), and drawn by Hunter/R6Rig.luau on both sides.

	A look (saved per player as profile.Data.r6):
		{ skin, face, eyes, brows, hair, hairDye, top, topColor, trim, bottom, bottomColor,
		  shoes, gloves, armor, armorColor, weapon, extra, build }
	Every field is an option id below (colors are palette ids). R6 has no body scaling,
	so `build` only changes how thick the clothes sit, never the rig.

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
	{ id = "white", name = "White", color = { 236, 236, 232 } },
	{ id = "navy", name = "Navy", color = { 26, 36, 72 } },
	{ id = "royal", name = "Royal Blue", color = { 46, 84, 190 } },
	{ id = "mana", name = "Mana Blue", color = { 70, 150, 255 } },
	{ id = "teal", name = "Teal", color = { 30, 130, 130 } },
	{ id = "forest", name = "Forest", color = { 40, 84, 52 } },
	{ id = "olive", name = "Olive Drab", color = { 96, 100, 56 } },
	{ id = "khaki", name = "Khaki", color = { 176, 160, 116 } },
	{ id = "brown", name = "Brown", color = { 98, 66, 42 } },
	{ id = "tan", name = "Tan", color = { 186, 142, 96 } },
	{ id = "crimson", name = "Crimson", color = { 160, 28, 36 } },
	{ id = "red", name = "Red", color = { 214, 52, 52 } },
	{ id = "orange", name = "Orange", color = { 230, 120, 40 } },
	{ id = "gold", name = "Gold", color = { 214, 172, 72 } },
	{ id = "violet", name = "Violet", color = { 110, 60, 170 } },
	{ id = "shadow", name = "Shadow Purple", color = { 50, 26, 80 } },
	{ id = "pink", name = "Pink", color = { 232, 140, 176 } },
	{ id = "silver", name = "Silver", color = { 196, 200, 208 } },
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

-- what's worn on the torso (and sleeves): each style is a set of shells over the R6 parts
Looks.TOPS = {
	{ id = "tee", name = "T-shirt", sleeves = "short" },
	{ id = "longsleeve", name = "Long Sleeve", sleeves = "long" },
	{ id = "hoodie", name = "Hoodie", sleeves = "long", hood = true, pocket = true },
	{ id = "jacket", name = "Bomber Jacket", sleeves = "long", open = true, collar = true },
	{ id = "leather", name = "Leather Jacket", sleeves = "long", open = true, collar = true, zips = true },
	{ id = "coat", name = "Long Coat", sleeves = "long", open = true, collar = true, tails = true },
	{ id = "trench", name = "Trench Coat", sleeves = "long", open = true, collar = true, tails = true, belt = true },
	{ id = "suit", name = "Suit Jacket", sleeves = "long", open = true, tie = true },
	{ id = "tactical", name = "Tactical Shirt", sleeves = "long", pockets = true },
	{ id = "tracksuit", name = "Tracksuit", sleeves = "long", stripes = true },
	{ id = "uniform", name = "School Uniform", sleeves = "long", tie = true, collar = true },
	{ id = "robe", name = "Mage's Robe", sleeves = "long", tails = true, hood = true },
	{ id = "tank", name = "Tank Top", sleeves = "none" },
	{ id = "turtleneck", name = "Turtleneck", sleeves = "long", highNeck = true },
	{ id = "guild", name = "Guild Uniform", sleeves = "long", collar = true, emblem = true, belt = true },
	{ id = "assoc", name = "Association Blazer", sleeves = "long", open = true, tie = true, badge = true },
	{ id = "sleeveless_hoodie", name = "Sleeveless Hoodie", sleeves = "none", hood = true, pocket = true },
	{ id = "gi", name = "Martial Gi", sleeves = "long", wrap = true, belt = true },
	{ id = "waistcoat", name = "Waistcoat & Shirt", sleeves = "long", waistcoat = true, tie = true },
	{ id = "apron", name = "Shop Apron", sleeves = "short", apron = true },
	{ id = "medic", name = "Healer's Coat", sleeves = "long", open = true, collar = true, tails = true, cross = true },
}
Looks.BOTTOMS = {
	{ id = "jeans", name = "Jeans" },
	{ id = "slacks", name = "Slacks", crease = true },
	{ id = "cargo", name = "Cargo Pants", pockets = true },
	{ id = "joggers", name = "Joggers", cuffs = true },
	{ id = "shorts", name = "Shorts", short = true },
	{ id = "skirt", name = "Pleated Skirt", skirt = true },
	{ id = "armored", name = "Armored Greaves", plates = true },
	{ id = "ripped", name = "Ripped Jeans", rips = true },
	{ id = "wide", name = "Wide Trousers", wide = true },
	{ id = "tactical_skirt", name = "Tactical Skirt", skirt = true, pockets = true },
}
Looks.SHOES = {
	{ id = "sneakers", name = "Sneakers" },
	{ id = "boots", name = "Combat Boots", tall = true },
	{ id = "dress", name = "Dress Shoes" },
	{ id = "sandals", name = "Sandals", low = true },
	{ id = "sabatons", name = "Armored Sabatons", tall = true, metal = true },
	{ id = "runners", name = "Running Shoes", trimSole = true },
	{ id = "geta", name = "Wooden Clogs", low = true, wood = true },
}
-- Hunter gear over the clothes (the look only; real gear is bought in a life)
Looks.ARMOR = {
	{ id = "none", name = "No armor" },
	{ id = "vest", name = "Raid Vest" },
	{ id = "plate", name = "Plate Cuirass" },
	{ id = "pauldrons", name = "Pauldrons" },
	{ id = "harness", name = "Strap Harness" },
	{ id = "heavy", name = "Tank Armor" },
	{ id = "cloak", name = "Shoulder Cloak" },
}
-- the weapon a look carries in the creator: the workshop weapons (★). A life's own weapon,
-- whatever its rarity, replaces it in the city (Hunter/Weapons.luau)
local Weapons = require(script.Parent:WaitForChild("Weapons"))
Looks.WEAPONS = { { id = "none", name = "Unarmed" } }
for _, w in Weapons.list do
	if w.price then
		table.insert(Looks.WEAPONS, { id = w.id, name = w.name })
	end
end
Looks.EXTRAS = {
	{ id = "none", name = "Nothing" },
	{ id = "glasses", name = "Glasses" },
	{ id = "shades", name = "Sunglasses" },
	{ id = "mask", name = "Face Mask" },
	{ id = "headband", name = "Headband" },
	{ id = "earpiece", name = "Association Earpiece" },
	{ id = "scarf", name = "Scarf" },
	{ id = "cap", name = "Cap" },
	{ id = "beanie", name = "Beanie" },
	{ id = "eyepatch", name = "Eyepatch" },
	{ id = "bandage", name = "Bandaged Cheek" },
	{ id = "choker", name = "Choker" },
	{ id = "earrings", name = "Earrings" },
	{ id = "monocle", name = "Monocle" },
	{ id = "half_mask", name = "Raider's Half Mask" },
	{ id = "medical", name = "Medical Mask" },
	{ id = "nose_band", name = "Nose Bandage" },
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
-- on the head, over the hair (some cover it)
Looks.HEADWEAR = {
	{ id = "none", name = "Nothing" },
	{ id = "hood", name = "Hood Up", hidesHair = true },
	{ id = "raid_helmet", name = "Raid Helmet", hidesHair = true },
	{ id = "knight_helm", name = "Knight's Helm", hidesHair = true },
	{ id = "horned_helm", name = "Horned Helm", hidesHair = true },
	{ id = "assassin_wrap", name = "Assassin's Wrap", hidesHair = true },
	{ id = "hardhat", name = "Mining Hard Hat", hidesHair = true },
	{ id = "mage_hat", name = "Mage's Hat" },
	{ id = "circlet", name = "Mana Circlet" },
	{ id = "healer_veil", name = "Healer's Veil" },
	{ id = "bandana", name = "Bandana" },
	{ id = "goggles", name = "Hunter Goggles" },
	{ id = "headphones", name = "Headphones" },
	{ id = "hairpin", name = "Crystal Hairpin" },
}
-- on the back
Looks.BACK = {
	{ id = "none", name = "Nothing" },
	{ id = "cape", name = "Cape" },
	{ id = "long_cape", name = "Commander's Cape" },
	{ id = "tattered", name = "Tattered Cape" },
	{ id = "quiver", name = "Quiver" },
	{ id = "pack", name = "Raid Pack" },
	{ id = "sheath", name = "Back Sheath" },
	{ id = "shield", name = "Back Shield" },
	{ id = "staff", name = "Staff on the Back" },
	{ id = "scrolls", name = "Scroll Case" },
	{ id = "crystal_crate", name = "Crystal Crate" },
	{ id = "banner", name = "Guild Banner" },
	{ id = "mana_wings", name = "Mana Wings (glow)" },
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

-- whole outfits in one click (the creator's PRESETS tab); a preset only sets what it names
Looks.PRESETS = {
	{ id = "assoc_agent", name = "Association Agent", desc = "Black blazer, the badge, an earpiece.", look = { top = "assoc", topColor = "black", trim = "white", bottom = "slacks", bottomColor = "black", shoes = "dress", armor = "none", extra = "earpiece", headwear = "none", back = "none", aura = "none" } },
	{ id = "surveillance", name = "Surveillance Team", desc = "Tactical shirt, goggles, a pack of sensors.", look = { top = "tactical", topColor = "navy", trim = "mana", bottom = "cargo", bottomColor = "charcoal", shoes = "boots", armor = "vest", armorColor = "navy", headwear = "goggles", back = "pack", backColor = "navy", extra = "earpiece" } },
	{ id = "striker", name = "Guild Striker", desc = "Guild colours, plate, a cape that's seen a few Gates.", look = { top = "guild", topColor = "crimson", trim = "gold", bottom = "armored", bottomColor = "black", shoes = "sabatons", armor = "plate", armorColor = "slate", back = "cape", backColor = "crimson", aura = "rank", weapon = "assoc_longsword" } },
	{ id = "tank", name = "Tanker", desc = "Heavy armor and a shield on the back.", look = { top = "tactical", topColor = "olive", trim = "orange", bottom = "armored", bottomColor = "olive", shoes = "sabatons", armor = "heavy", armorColor = "slate", headwear = "knight_helm", back = "shield", backColor = "slate", build = "broad" } },
	{ id = "assassin", name = "Assassin", desc = "Dark wraps, light feet, a blade across the back.", look = { top = "hoodie", topColor = "black", trim = "violet", bottom = "joggers", bottomColor = "black", shoes = "sneakers", armor = "harness", armorColor = "black", headwear = "assassin_wrap", back = "sheath", backColor = "black", eyeGlow = "violet", build = "slim", weapon = "twin_stilettos" } },
	{ id = "mage", name = "Mage", desc = "The robe, the hat, the staff, and mana in the eyes.", look = { top = "robe", topColor = "navy", trim = "gold", bottom = "slacks", bottomColor = "navy", shoes = "boots", armor = "none", headwear = "mage_hat", back = "scrolls", backColor = "brown", eyeGlow = "blue", aura = "mana", weapon = "mana_staff" } },
	{ id = "healer", name = "Healer", desc = "White coat, the veil, a quiet glow.", look = { top = "medic", topColor = "white", trim = "teal", bottom = "slacks", bottomColor = "white", shoes = "dress", armor = "none", headwear = "healer_veil", back = "scrolls", backColor = "white", aura = "verdant" } },
	{ id = "ranger", name = "Ranger", desc = "Field coat, quiver, a hood against the weather.", look = { top = "trench", topColor = "forest", trim = "khaki", bottom = "cargo", bottomColor = "olive", shoes = "boots", armor = "pauldrons", armorColor = "brown", headwear = "hood", back = "quiver", backColor = "brown", weapon = "hunting_bow" } },
	{ id = "collector", name = "Collection Crew", desc = "Hard hat, work clothes, a crate of crystals.", look = { top = "tactical", topColor = "orange", trim = "silver", bottom = "cargo", bottomColor = "charcoal", shoes = "boots", armor = "vest", armorColor = "orange", headwear = "hardhat", back = "crystal_crate", backColor = "slate", gloves = true } },
	{ id = "rogue", name = "Rogue Hunter", desc = "Leather, a half mask, a red glow nobody trusts.", look = { top = "leather", topColor = "black", trim = "red", bottom = "ripped", bottomColor = "charcoal", shoes = "boots", armor = "harness", armorColor = "crimson", extra = "half_mask", back = "tattered", backColor = "black", eyeGlow = "red", aura = "crimson", marks = "scar_eye" } },
	{ id = "commander", name = "Raid Commander", desc = "The long cape, the guild banner, an S-rank's bearing.", look = { top = "coat", topColor = "white", trim = "gold", bottom = "slacks", bottomColor = "white", shoes = "sabatons", armor = "pauldrons", armorColor = "gold", back = "long_cape", backColor = "navy", headwear = "circlet", aura = "gold" } },
	{ id = "student", name = "Student", desc = "School uniform and a bag. Not awakened. Yet.", look = { top = "uniform", topColor = "navy", trim = "red", bottom = "slacks", bottomColor = "charcoal", shoes = "sneakers", armor = "none", weapon = "none", headwear = "none", back = "pack", backColor = "navy", aura = "none", eyeGlow = "none" } },
	{ id = "office", name = "Office Worker", desc = "Waistcoat, tie, tired eyes. Gates are on the news.", look = { top = "waistcoat", topColor = "charcoal", trim = "white", bottom = "slacks", bottomColor = "charcoal", shoes = "dress", armor = "none", weapon = "none", headwear = "none", back = "none", aura = "none", marks = "dark_circles", face = "tired" } },
	{ id = "shopkeeper", name = "Shopkeeper", desc = "The family restaurant's apron and a bandana.", look = { top = "apron", topColor = "white", trim = "crimson", bottom = "jeans", bottomColor = "navy", shoes = "sneakers", armor = "none", weapon = "none", headwear = "bandana", back = "none", aura = "none" } },
	{ id = "brawler", name = "Martial Fighter", desc = "A gi, wraps on the hands, an ember in the fists.", look = { top = "gi", topColor = "white", trim = "black", bottom = "wide", bottomColor = "white", shoes = "geta", armor = "none", headwear = "bandana", gloves = true, aura = "ember", marks = "scar_cheek", weapon = "iron_knuckles" } },
	{ id = "frost_knight", name = "Frost Knight", desc = "Silver plate, horned helm, frost on the breath.", look = { top = "guild", topColor = "silver", trim = "mana", bottom = "armored", bottomColor = "silver", shoes = "sabatons", armor = "heavy", armorColor = "silver", headwear = "horned_helm", back = "long_cape", backColor = "navy", aura = "frost", eyeGlow = "white" } },
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
	shoes = "boots", gloves = false,
	armor = "none", armorColor = "slate",
	weapon = "none", extra = "none", build = "regular",
	marks = "none", eyeGlow = "none", headwear = "none", back = "none", backColor = "charcoal", aura = "none",
}

-- the fields that pick from each list
Looks.FIELDS = {
	skin = "SKIN", face = "FACE", eyes = "EYES", brows = "BROWS", hair = "HAIR", hairDye = "HAIR_DYES",
	top = "TOPS", topColor = "PALETTE", trim = "PALETTE", bottom = "BOTTOMS", bottomColor = "PALETTE",
	shoes = "SHOES", armor = "ARMOR", armorColor = "PALETTE", weapon = "WEAPONS", extra = "EXTRAS", build = "BUILD",
	marks = "MARKS", eyeGlow = "EYE_GLOW", headwear = "HEADWEAR", back = "BACK", backColor = "PALETTE", aura = "AURA",
}
-- the order the creator shows them in, with their tab
Looks.TABS = {
	{ id = "presets", name = "Presets", presets = true, fields = {} },
	{ id = "body", name = "Body", fields = { "skin", "build", "aura" } },
	{ id = "face", name = "Face", fields = { "face", "eyes", "eyeGlow", "brows", "marks", "extra" } },
	{ id = "hair", name = "Head", fields = { "hair", "hairDye", "headwear" } },
	{ id = "clothes", name = "Clothes", fields = { "top", "topColor", "trim", "bottom", "bottomColor", "shoes", "gloves" } },
	{ id = "gear", name = "Gear", fields = { "armor", "armorColor", "back", "backColor", "weapon" } },
}
Looks.LABELS = {
	skin = "Skin tone", build = "Build", face = "Expression", eyes = "Eye color", brows = "Brows", extra = "Accessory",
	hair = "Hairstyle", hairDye = "Hair color", top = "Top", topColor = "Top color", trim = "Trim color",
	bottom = "Bottoms", bottomColor = "Bottoms color", shoes = "Shoes", gloves = "Gloves", armor = "Armor",
	armorColor = "Armor color", weapon = "Weapon",
	marks = "Scars and marks", eyeGlow = "Eye glow", headwear = "Headwear", back = "On your back", backColor = "Back color", aura = "Aura",
}

local index: { [string]: { [any]: any } } = {}
for _, listName in { "SKIN", "PALETTE", "HAIR_DYES", "HAIR", "FACE", "EYES", "BROWS", "TOPS", "BOTTOMS", "SHOES", "ARMOR", "WEAPONS", "EXTRAS", "BUILD", "MARKS", "EYE_GLOW", "HEADWEAR", "BACK", "AURA", "PRESETS" } do
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
	out.gloves = raw.gloves == true
	return out
end

-- a look with a preset laid over it (only what the preset names changes)
function Looks.applyPreset(look: any, presetId: string): any
	local p = Looks.find("PRESETS", presetId)
	local out = table.clone(look)
	if p then
		for k, v in p.look do
			out[k] = v
		end
	end
	return Looks.clean(out)
end

-- a random look (NPCs, the creator's dice)
function Looks.random(rand: (number, number) -> number, opts: any?): any
	local function pick(list)
		return list[rand(1, #list)].id
	end
	local civilian = opts and opts.civilian
	local l = {
		skin = pick(Looks.SKIN),
		face = pick(Looks.FACE),
		eyes = pick(Looks.EYES),
		brows = pick(Looks.BROWS),
		hair = pick(Looks.HAIR),
		hairDye = pick(Looks.HAIR_DYES),
		top = pick(Looks.TOPS),
		topColor = pick(Looks.PALETTE),
		trim = pick(Looks.PALETTE),
		bottom = pick(Looks.BOTTOMS),
		bottomColor = pick(Looks.PALETTE),
		shoes = pick(Looks.SHOES),
		gloves = rand(1, 4) == 1,
		armor = if civilian then "none" else pick(Looks.ARMOR),
		armorColor = pick(Looks.PALETTE),
		weapon = if civilian then "none" else pick(Looks.WEAPONS),
		extra = if rand(1, 3) == 1 then pick(Looks.EXTRAS) else "none",
		build = pick(Looks.BUILD),
		marks = if rand(1, 3) == 1 then pick(Looks.MARKS) else "none",
		eyeGlow = if not civilian and rand(1, 5) == 1 then pick(Looks.EYE_GLOW) else "none",
		headwear = if rand(1, 4) == 1 then pick(Looks.HEADWEAR) else "none",
		back = if not civilian and rand(1, 3) == 1 then pick(Looks.BACK) else "none",
		backColor = pick(Looks.PALETTE),
		aura = if not civilian and rand(1, 6) == 1 then pick(Looks.AURA) else "none",
	}
	if civilian and (l.headwear == "knight_helm" or l.headwear == "horned_helm" or l.headwear == "raid_helmet" or l.headwear == "assassin_wrap") then
		l.headwear = "none"
	end
	if l.skin == "classic" and rand(1, 3) > 1 then
		l.skin = "light"
	end
	return l
end

return Looks
