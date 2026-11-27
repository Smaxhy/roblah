--[[
	THE WEAPONS (BitLeveling, ORIGINAL items in the canon economy: Hunters fight with weapons
	forged from monster materials and mana crystals, bought from workshops or brought out of
	Gates, and the rare ones go to auction).

	A weapon you own is a BASE (one of the list below: a family, a grade E..S, a look) at a
	RARITY: one to three stars, and sometimes SHINY.
		★      the plain forging                                   x1.00
		★★     a fine one: better steel, better balance            x1.35
		★★★    a masterwork                                        x1.80
		Shiny  any star can come out shiny (about 1 in 60 drops): a weapon the mana has soaked
		       into. Very good buffs on top (+45% power, +6% heads in every clash, and a perk of
		       its family), and it shimmers in the hand.
	The odds of a drop's rarity are shown in game (Weapons.ODDS), never sold.

	Each variant is a gear item in the life sim (id "w_<base>_<stars>" or "..._s" for shiny:
	Weapons.gearList builds them all) and a 3D model on the R6 rig (Hunter/WeaponModels).
]]

local Weapons = {}

Weapons.GRADES = { "E", "D", "C", "B", "A", "S" }
Weapons.STARS = {
	{ stars = 1, label = "★", mult = 1, rarity = "common" },
	{ stars = 2, label = "★★", mult = 1.35, rarity = "rare" },
	{ stars = 3, label = "★★★", mult = 1.8, rarity = "epic" },
}
Weapons.SHINY = { mult = 1.45, heads = 6, rarity = "legendary" }
-- what comes out of a Gate: the stars (weights), and the chance it's shiny
Weapons.ODDS = { stars = { 70, 24, 6 }, shiny = 1 / 60 }

-- what the families fight with, how their power is shaped, and what a shiny one adds
-- stat: the clash stat it powers; shape: how the power splits (base / coinPower / coins)
-- perk: the shiny perk; kind: what the life avatar draws (Engine/Arms kinds)
Weapons.FAMILIES = {
	dagger = { name = "Dagger", stat = "agility", shape = "quick", perk = "coins", kind = "dagger", hands = 1 },
	daggers = { name = "Twin Daggers", stat = "agility", shape = "quick", perk = "coins", kind = "daggers", hands = 2 },
	sword = { name = "Sword", stat = "strength", shape = "even", perk = "heads", kind = "sword", hands = 1 },
	katana = { name = "Katana", stat = "strength", shape = "sharp", perk = "heads", kind = "katana", hands = 1 },
	greatsword = { name = "Greatsword", stat = "strength", shape = "heavy", perk = "power", kind = "greatsword", hands = 1 },
	rapier = { name = "Rapier", stat = "agility", shape = "sharp", perk = "heads", kind = "rapier", hands = 1 },
	cleaver = { name = "Cleaver", stat = "strength", shape = "heavy", perk = "power", kind = "cleaver", hands = 1 },
	scythe = { name = "Scythe", stat = "strength", shape = "sharp", perk = "power", kind = "scythe", hands = 1 },
	spear = { name = "Spear", stat = "agility", shape = "even", perk = "coins", kind = "spear", hands = 1 },
	halberd = { name = "Halberd", stat = "strength", shape = "heavy", perk = "guard", kind = "halberd", hands = 1 },
	axe = { name = "Axe", stat = "strength", shape = "heavy", perk = "power", kind = "axe", hands = 1 },
	axes = { name = "Twin Axes", stat = "strength", shape = "quick", perk = "coins", kind = "axe", hands = 2 },
	hammer = { name = "Hammer", stat = "strength", shape = "heavy", perk = "guard", kind = "maul", hands = 1 },
	mace = { name = "Mace", stat = "strength", shape = "even", perk = "guard", kind = "mace", hands = 1 },
	staff = { name = "Staff", stat = "intelligence", shape = "even", perk = "mind", kind = "staff", hands = 1 },
	wand = { name = "Wand", stat = "intelligence", shape = "sharp", perk = "mind", kind = "baton", hands = 1 },
	orb = { name = "Focus", stat = "intelligence", shape = "even", perk = "mind", kind = "lamp", hands = 1 },
	tome = { name = "Grimoire", stat = "intelligence", shape = "sharp", perk = "mind", kind = "book", hands = 1 },
	bow = { name = "Bow", stat = "agility", shape = "sharp", perk = "heads", kind = "crossbow", hands = 1 },
	crossbow = { name = "Crossbow", stat = "agility", shape = "even", perk = "heads", kind = "crossbow", hands = 1 },
	gauntlets = { name = "Gauntlets", stat = "strength", shape = "quick", perk = "coins", kind = "gauntlets", hands = 2 },
	claws = { name = "Claws", stat = "agility", shape = "quick", perk = "coins", kind = "claws", hands = 2 },
	shield = { name = "Shield", stat = "vitality", shape = "guard", perk = "guard", kind = "shield", hands = 2 },
	censer = { name = "Lantern", stat = "willpower", shape = "even", perk = "life", kind = "censer", hands = 1 },
	rod = { name = "Rod", stat = "willpower", shape = "even", perk = "life", kind = "staff", hands = 1 },
	chainblade = { name = "Chain-Blade", stat = "agility", shape = "quick", perk = "coins", kind = "chainblade", hands = 1 },
	chakram = { name = "Chakrams", stat = "agility", shape = "quick", perk = "heads", kind = "fan", hands = 2 },
	kusarigama = { name = "Kusarigama", stat = "agility", shape = "sharp", perk = "coins", kind = "sickle", hands = 2 },
}

-- base power by grade (E..S): what a ★ weapon adds to its stat's base in a clash
Weapons.POWER = { 2, 3, 5, 7, 10, 14 }

-- c: colours (blade/head, grip, trim, glow); p: shape knobs the model reads; price: in the
-- workshops (★ only, grades E..C); src: where else it comes from
local function rgb(r, g, b)
	return { r, g, b }
end
local STEEL, DARK, BRASS, WOOD, BONE = rgb(196, 200, 210), rgb(34, 30, 30), rgb(200, 160, 80), rgb(92, 66, 44), rgb(226, 218, 196)
local MANA, FROST, FIRE, VENOM, VOID, GOLD = rgb(90, 160, 255), rgb(170, 230, 255), rgb(255, 120, 50), rgb(130, 230, 90), rgb(150, 80, 230), rgb(255, 210, 90)

Weapons.list = {
	-- daggers
	{ id = "steel_dagger", name = "Hunter's Steel Dagger", family = "dagger", grade = 1, price = 2, c = { STEEL, DARK, BRASS, MANA }, p = { len = 1.0 }, desc = "Licensed-Hunters-only steel. Enough for an E-rank Gate." },
	{ id = "goblin_fang", name = "Goblin-Fang Knife", family = "dagger", grade = 1, price = 2, c = { BONE, WOOD, rgb(110, 90, 60), rgb(200, 255, 120) }, p = { len = 0.9, curve = 0.3 }, desc = "A goblin's tooth set in a wooden grip. Uglier than it is sharp." },
	{ id = "twin_stilettos", name = "Twin Fang Stilettos", family = "daggers", grade = 2, price = 6, c = { STEEL, DARK, rgb(150, 30, 40), rgb(255, 80, 80) }, p = { len = 1.1 }, desc = "Thin, quick, and made to be used together." },
	{ id = "spider_kris", name = "Venom Spider Kris", family = "dagger", grade = 3, price = 14, c = { rgb(60, 70, 60), DARK, VENOM, VENOM }, p = { len = 1.2, wave = true }, desc = "The wavy blade holds a C-rank spider's venom gland in the guard." },
	{ id = "shadowglass", name = "Shadowglass Dirks", family = "daggers", grade = 5, c = { rgb(30, 30, 46), DARK, VOID, VOID }, p = { len = 1.3 }, desc = "Black glass from an A-rank Gate. They make no sound at all." },
	{ id = "fang_of_the_deep", name = "Fang of the Deep Gate", family = "dagger", grade = 6, c = { rgb(240, 240, 255), DARK, GOLD, rgb(255, 60, 90) }, p = { len = 1.5, curve = 0.4 }, desc = "A tooth from something an S-rank raid barely survived." },
	-- swords
	{ id = "shortsword", name = "Hunter's Shortsword", family = "sword", grade = 1, price = 3, c = { STEEL, DARK, BRASS, MANA }, p = { len = 2.4, width = 0.3 }, desc = "The sword every rookie raid party has three of." },
	{ id = "assoc_longsword", name = "Association Longsword", family = "sword", grade = 2, price = 7, c = { STEEL, rgb(28, 50, 110), rgb(220, 225, 235), MANA }, p = { len = 3.2, width = 0.32 }, desc = "Standard issue for public raids. Plain, honest, reliable." },
	{ id = "crystal_longsword", name = "Crystal-Tempered Longsword", family = "sword", grade = 3, price = 16, c = { rgb(200, 220, 240), DARK, BRASS, MANA }, p = { len = 3.4, width = 0.34, fuller = true }, desc = "Quenched in crystal water. It holds an edge on things steel shouldn't cut." },
	{ id = "warlord_blade", name = "Orc Warlord's Blade", family = "sword", grade = 3, c = { rgb(120, 100, 90), rgb(60, 40, 30), rgb(150, 40, 30), FIRE }, p = { len = 3.3, width = 0.5, notched = true }, desc = "Notched, heavy, and still warm. Taken from a C-rank boss." },
	{ id = "frostbite_saber", name = "Frostbite Saber", family = "sword", grade = 4, c = { FROST, rgb(40, 60, 90), rgb(220, 240, 255), FROST }, p = { len = 3.3, width = 0.3, curve = 0.25 }, desc = "Frost creeps along the blade in a warm room." },
	{ id = "golem_heart_blade", name = "Golem-Heart Blade", family = "sword", grade = 5, c = { rgb(150, 140, 130), DARK, rgb(255, 170, 60), rgb(255, 170, 60) }, p = { len = 3.6, width = 0.42, gem = true }, desc = "A golem's core set in the hilt. It beats, slowly." },
	{ id = "starfall_edge", name = "Starfall Edge", family = "sword", grade = 6, c = { rgb(230, 236, 255), rgb(30, 30, 60), GOLD, rgb(140, 200, 255) }, p = { len = 3.9, width = 0.4, fuller = true, gem = true }, desc = "Forged from a fragment of an S-rank boss. Guilds bid in billions for less." },
	-- katana
	{ id = "plain_katana", name = "Plain Katana", family = "katana", grade = 2, price = 8, c = { STEEL, DARK, rgb(180, 150, 80), MANA }, p = { len = 3.1 }, desc = "A good blade with no story yet." },
	{ id = "moonlit_katana", name = "Moonlit Katana", family = "katana", grade = 4, c = { rgb(210, 220, 255), rgb(30, 30, 50), rgb(200, 200, 230), rgb(180, 200, 255) }, p = { len = 3.3 }, desc = "It catches light that isn't in the room." },
	{ id = "thousand_cut", name = "Thousand-Cut Katana", family = "katana", grade = 5, c = { rgb(240, 240, 245), rgb(80, 10, 20), GOLD, rgb(255, 70, 90) }, p = { len = 3.5 }, desc = "Every cut it makes is the same cut, perfect." },
	-- greatswords and cleavers
	{ id = "executioner_slab", name = "Executioner's Slab", family = "greatsword", grade = 3, c = { rgb(110, 112, 118), DARK, rgb(90, 90, 96), FIRE }, p = { len = 4.2, width = 0.7 }, desc = "Less a sword than a door with an edge." },
	{ id = "ogre_greatsword", name = "Ogre-Iron Greatsword", family = "greatsword", grade = 4, c = { rgb(120, 116, 110), rgb(60, 40, 30), BRASS, FIRE }, p = { len = 4.4, width = 0.62 }, desc = "Forged from what a B-rank Gate left behind. Heavy enough to argue with an ogre." },
	{ id = "titan_cleaver", name = "Titan's Cleaver", family = "cleaver", grade = 5, c = { rgb(150, 150, 156), DARK, rgb(200, 60, 40), FIRE }, p = { len = 3.6, width = 1.1 }, desc = "A butcher's blade sized for things that eat buildings." },
	{ id = "dragonkin_fang", name = "Dragon-kin Fang Greatsword", family = "greatsword", grade = 6, c = { rgb(240, 236, 226), rgb(40, 20, 50), GOLD, rgb(255, 80, 40) }, p = { len = 4.8, width = 0.7, gem = true }, desc = "One fang, ground into a blade. The heat never leaves it." },
	{ id = "butcher_cleaver", name = "Market Butcher's Cleaver", family = "cleaver", grade = 1, price = 2, c = { STEEL, WOOD, STEEL, MANA }, p = { len = 1.6, width = 0.8 }, desc = "Not made for monsters. It works anyway." },
	-- rapiers
	{ id = "duelist_rapier", name = "Duelist's Rapier", family = "rapier", grade = 3, price = 15, c = { STEEL, DARK, GOLD, MANA }, p = { len = 3.6 }, desc = "For Hunters who'd rather not be hit at all." },
	{ id = "naga_needle", name = "Needle of the Naga", family = "rapier", grade = 4, c = { rgb(140, 220, 200), rgb(20, 60, 60), rgb(80, 200, 180), rgb(80, 255, 220) }, p = { len = 3.8 }, desc = "A naga's spine, straightened and sharpened." },
	-- scythes
	{ id = "reaper_crescent", name = "Reaper's Crescent", family = "scythe", grade = 4, c = { rgb(70, 70, 80), WOOD, rgb(150, 150, 160), VOID }, p = { len = 5.2 }, desc = "A wraith's blade on a shaft of black ash." },
	{ id = "wraith_harvester", name = "Wraith Harvester", family = "scythe", grade = 5, c = { rgb(40, 40, 60), DARK, rgb(120, 100, 200), VOID }, p = { len = 5.6 }, desc = "It hums when someone near it is afraid." },
	-- spears, pikes, lances
	{ id = "hunter_spear", name = "Hunter's Spear", family = "spear", grade = 1, price = 3, c = { STEEL, WOOD, BRASS, MANA }, p = { len = 6 }, desc = "Keep the goblins at arm's length. A long arm." },
	{ id = "lizard_spear", name = "Lizardman-Bone Spear", family = "spear", grade = 2, price = 7, c = { BONE, WOOD, rgb(90, 140, 90), VENOM }, p = { len = 6.2 }, desc = "Light, nasty on the tip, and it doesn't rust." },
	{ id = "lightning_pike", name = "Lightning Pike", family = "spear", grade = 4, c = { rgb(220, 230, 255), DARK, GOLD, rgb(180, 220, 255) }, p = { len = 6.6, prongs = true }, desc = "It crackles before it strikes." },
	{ id = "wyvern_lance", name = "Wyvern-Tail Lance", family = "spear", grade = 5, c = { rgb(110, 150, 110), rgb(40, 50, 40), GOLD, VENOM }, p = { len = 7, lance = true }, desc = "The tail-spike of an A-rank wyvern, mounted on a lance." },
	-- halberds
	{ id = "guard_halberd", name = "Guard Halberd", family = "halberd", grade = 3, price = 14, c = { STEEL, WOOD, BRASS, MANA }, p = { len = 6.4 }, desc = "The cordon officer's best friend, when the cordon fails." },
	{ id = "glacier_halberd", name = "Glacier Halberd", family = "halberd", grade = 5, c = { FROST, rgb(50, 70, 100), rgb(220, 240, 255), FROST }, p = { len = 6.8 }, desc = "Cut from the ice of a cavern that was always snowing." },
	-- axes
	{ id = "woodsman_axe", name = "Woodsman's Axe", family = "axe", grade = 1, price = 2, c = { STEEL, WOOD, STEEL, MANA }, p = { len = 2.6 }, desc = "Someone's grandfather's. It's seen worse than goblins." },
	{ id = "hob_axe", name = "Hobgoblin Cleaver-Axe", family = "axe", grade = 2, price = 6, c = { rgb(120, 110, 100), rgb(70, 50, 30), rgb(110, 90, 60), FIRE }, p = { len = 2.8, double = true }, desc = "Crude, double-bitted, and very hard to stop." },
	{ id = "berserker_axes", name = "Berserker Twin Axes", family = "axes", grade = 4, c = { rgb(150, 140, 140), DARK, rgb(160, 30, 30), rgb(255, 60, 60) }, p = { len = 2.6 }, desc = "Two axes, no shield, no plan." },
	{ id = "world_splitter", name = "World-Splitter", family = "axe", grade = 6, c = { rgb(220, 210, 190), rgb(30, 20, 20), GOLD, rgb(255, 140, 60) }, p = { len = 3.6, double = true, gem = true }, desc = "The S-rank raid that brought it out lost four Hunters. Nobody uses it gently." },
	-- hammers and maces
	{ id = "iron_mace", name = "Iron Mace", family = "mace", grade = 1, price = 2, c = { rgb(120, 120, 126), WOOD, STEEL, MANA }, p = { len = 2.4 }, desc = "A ball of iron on a stick. Effective for exactly that reason." },
	{ id = "stonebreaker", name = "Stone-Breaker Hammer", family = "hammer", grade = 3, price = 15, c = { rgb(110, 110, 116), WOOD, BRASS, FIRE }, p = { len = 3.4 }, desc = "Made for golems. Works on everything else." },
	{ id = "golem_maul", name = "Golem Maul", family = "hammer", grade = 5, c = { rgb(150, 140, 130), DARK, rgb(255, 170, 60), rgb(255, 170, 60) }, p = { len = 4, big = true }, desc = "A golem's fist on a pillar of iron." },
	{ id = "earthshaker", name = "Earthshaker", family = "hammer", grade = 6, c = { rgb(80, 70, 60), DARK, GOLD, rgb(255, 120, 60) }, p = { len = 4.4, big = true, gem = true }, desc = "When it lands, the street remembers it." },
	{ id = "spiked_morningstar", name = "Spiked Morningstar", family = "mace", grade = 3, c = { rgb(100, 100, 106), DARK, BRASS, FIRE }, p = { len = 2.8, spikes = true }, desc = "Spikes on spikes." },
	-- staves, wands, foci, tomes
	{ id = "apprentice_wand", name = "Apprentice's Wand", family = "wand", grade = 1, price = 3, c = { WOOD, DARK, BRASS, MANA }, p = { len = 1.6 }, desc = "A crystal sliver in carved wood. Every Mage's first." },
	{ id = "mana_staff", name = "Mana-Conductive Staff", family = "staff", grade = 3, price = 16, c = { WOOD, DARK, BRASS, MANA }, p = { len = 5 }, desc = "A crystal core in carved wood. It hums under the hand." },
	{ id = "frostfire_staff", name = "Frostfire Staff", family = "staff", grade = 4, c = { rgb(60, 60, 80), DARK, rgb(220, 230, 255), rgb(255, 140, 220) }, p = { len = 5.2, prongs = true }, desc = "Hot and cold at once. Nobody can explain it, including the smith." },
	{ id = "sage_staff", name = "Sage's Crystal Staff", family = "staff", grade = 5, c = { rgb(230, 230, 240), rgb(40, 40, 60), GOLD, rgb(150, 230, 255) }, p = { len = 5.4, rings = true }, desc = "Three rings of crystal turn around the head." },
	{ id = "deep_gate_staff", name = "Staff of the Deep Gate", family = "staff", grade = 6, c = { rgb(20, 20, 40), DARK, GOLD, VOID }, p = { len = 5.8, rings = true, prongs = true }, desc = "Looking at the orb too long makes you feel like you're falling." },
	{ id = "focus_orb", name = "Focus Orb", family = "orb", grade = 2, price = 8, c = { rgb(150, 200, 255), DARK, BRASS, MANA }, p = { size = 0.8 }, desc = "A floating sphere of polished crystal." },
	{ id = "ember_grimoire", name = "Grimoire of Embers", family = "tome", grade = 4, c = { rgb(120, 40, 30), DARK, GOLD, FIRE }, p = { size = 1 }, desc = "The pages are warm. Some of them are burning, slowly, forever." },
	{ id = "void_codex", name = "Void Codex", family = "tome", grade = 5, c = { rgb(30, 20, 50), DARK, rgb(150, 100, 230), VOID }, p = { size = 1.1 }, desc = "Recovered from a Double Dungeon. The Association wants it back." },
	-- bows and crossbows
	{ id = "hunting_bow", name = "Hunting Bow", family = "bow", grade = 1, price = 3, c = { WOOD, DARK, STEEL, MANA }, p = { len = 3.6 }, desc = "A sporting bow, restrung for monsters." },
	{ id = "composite_bow", name = "Composite Bow", family = "bow", grade = 3, price = 14, c = { rgb(70, 60, 50), DARK, BRASS, MANA }, p = { len = 4 }, desc = "Horn, sinew and wood. It throws an arrow very far." },
	{ id = "wyvern_longbow", name = "Wyvern-Sinew Longbow", family = "bow", grade = 5, c = { rgb(80, 110, 80), DARK, GOLD, VENOM }, p = { len = 4.6 }, desc = "Strung with a wyvern's tendon. Only an A-rank can draw it." },
	{ id = "skypiercer", name = "Skypiercer", family = "bow", grade = 6, c = { rgb(230, 236, 255), rgb(30, 40, 70), GOLD, rgb(160, 220, 255) }, p = { len = 5 }, desc = "Its arrows don't come down." },
	{ id = "repeater", name = "Repeating Crossbow", family = "crossbow", grade = 3, price = 13, c = { rgb(90, 90, 96), WOOD, BRASS, MANA }, p = { len = 2 }, desc = "Six bolts in four seconds. Reloading takes longer." },
	-- gauntlets and claws
	{ id = "brawler_wraps", name = "Brawler's Wraps", family = "gauntlets", grade = 1, price = 2, c = { rgb(220, 210, 190), DARK, rgb(160, 40, 40), MANA }, p = {}, desc = "Tape, padding and attitude." },
	{ id = "iron_knuckles", name = "Iron Knuckles", family = "gauntlets", grade = 2, price = 6, c = { rgb(120, 120, 126), DARK, STEEL, MANA }, p = { studs = true }, desc = "Iron over the knuckles, leather over the rest." },
	{ id = "bear_claws", name = "Bear-Claw Gauntlets", family = "claws", grade = 4, c = { rgb(230, 236, 240), rgb(60, 70, 80), rgb(200, 220, 240), FROST }, p = {}, desc = "An ice bear's claws, set on steel. Still cold." },
	{ id = "titan_fists", name = "Titan Fists", family = "gauntlets", grade = 5, c = { rgb(140, 130, 120), DARK, rgb(255, 170, 60), rgb(255, 170, 60) }, p = { big = true }, desc = "Golem stone on the knuckles. Walls are a suggestion." },
	-- shields
	{ id = "riot_shield", name = "Riot Shield & Baton", family = "shield", grade = 1, price = 3, c = { rgb(40, 50, 60), DARK, rgb(200, 210, 220), MANA }, p = {}, desc = "Police surplus. It's held a cordon or two." },
	{ id = "tower_shield", name = "Tower Shield", family = "shield", grade = 3, price = 16, c = { rgb(120, 124, 132), DARK, BRASS, MANA }, p = { big = true }, desc = "A wall you carry." },
	{ id = "bulwark", name = "Bulwark of the Wall", family = "shield", grade = 5, c = { rgb(160, 150, 140), DARK, GOLD, rgb(255, 210, 120) }, p = { big = true, gem = true }, desc = "Every dent is a raid it brought someone home from." },
	-- healers
	{ id = "mercy_lantern", name = "Lantern of Mercy", family = "censer", grade = 3, price = 14, c = { rgb(230, 220, 190), DARK, GOLD, rgb(255, 240, 180) }, p = {}, desc = "Its light makes wounds close a little faster." },
	{ id = "sanctum_rod", name = "Sanctum Rod", family = "rod", grade = 5, c = { rgb(240, 240, 250), rgb(60, 60, 80), GOLD, rgb(140, 255, 200) }, p = { len = 4.6, rings = true }, desc = "A Healer's rod, worn smooth by a thousand raids." },
	-- exotic
	{ id = "chain_blade", name = "Chain-Blade", family = "chainblade", grade = 4, c = { STEEL, DARK, rgb(160, 160, 170), MANA }, p = { len = 2.4 }, desc = "A blade on a chain. It goes where you throw it and comes back." },
	{ id = "chakrams", name = "Moonring Chakrams", family = "chakram", grade = 3, c = { rgb(220, 226, 240), DARK, GOLD, rgb(200, 220, 255) }, p = { size = 1.1 }, desc = "Two rings of sharpened silver." },
	{ id = "kusarigama", name = "Shadow Kusarigama", family = "kusarigama", grade = 4, c = { rgb(60, 60, 70), DARK, rgb(120, 120, 130), VOID }, p = {}, desc = "A sickle, a chain, and a weight. Each one is a weapon." },
}

Weapons.byId = {}
for _, w in Weapons.list do
	Weapons.byId[w.id] = w
end

-- the gear id of a weapon at a rarity
function Weapons.gearId(base: string, stars: number, shiny: boolean?): string
	return "w_" .. base .. "_" .. tostring(stars) .. (if shiny then "_s" else "")
end

-- read a gear id back: base, stars, shiny (nil if it isn't a weapon)
function Weapons.parse(gearId: string?): (string?, number?, boolean?)
	if type(gearId) ~= "string" then
		return nil
	end
	local base, stars, shiny = string.match(gearId, "^w_(.-)_(%d)(_?s?)$")
	if not base or not Weapons.byId[base] then
		return nil
	end
	return base, tonumber(stars), shiny == "_s"
end

-- how strong a weapon is, as one number (the market and the auto-equip compare these)
function Weapons.power(base: string, stars: number, shiny: boolean?): number
	local w = Weapons.byId[base]
	if not w then
		return 0
	end
	local p = Weapons.POWER[w.grade] * Weapons.STARS[stars].mult
	if shiny then
		p *= Weapons.SHINY.mult
	end
	return math.floor(p * 10 + 0.5) / 10
end

function Weapons.label(base: string, stars: number, shiny: boolean?): string
	local w = Weapons.byId[base]
	return (if shiny then "Shiny " else "") .. Weapons.STARS[stars].label .. " " .. (if w then w.name else base)
end

-- every weapon at every rarity, as gear items for the life sim
function Weapons.gearList(): { any }
	local out = {}
	for _, w in Weapons.list do
		local fam = Weapons.FAMILIES[w.family]
		for _, st in Weapons.STARS do
			for _, shiny in { false, true } do
				local power = Weapons.power(w.id, st.stars, shiny)
				local stat = fam.stat
				local clash: any = {}
				local fight: any = {}
				local extra = {}
				local base = math.floor(power + 0.5)
				-- the family shapes the power: quick weapons trade base for coins, heavy ones
				-- for power per heads, guard weapons for toughness
				if fam.shape == "quick" then
					clash[stat] = { base = math.max(1, math.floor(base * 0.7)) }
					if st.stars >= 2 or w.grade >= 4 then
						fight.coins = 1
					end
				elseif fam.shape == "heavy" then
					clash[stat] = { base = math.max(1, math.floor(base * 0.8)), coinPower = 1 + math.floor(w.grade / 3) + (if st.stars == 3 then 1 else 0) }
				elseif fam.shape == "sharp" then
					clash[stat] = { base = base, coinPower = if st.stars >= 2 then 1 else 0 }
				elseif fam.shape == "guard" then
					clash[stat] = { base = base }
				else
					clash[stat] = { base = base, coinPower = if st.stars == 3 then 1 else 0 }
				end
				-- a weapon also helps the fight stat a little if it isn't the fight stat
				if stat ~= "strength" and stat ~= "vitality" then
					clash.strength = { base = math.max(1, math.floor(base * 0.4)) }
				end
				local item: any = {
					id = Weapons.gearId(w.id, st.stars, shiny),
					name = Weapons.label(w.id, st.stars, shiny),
					slot = "weapon",
					price = if w.price and st.stars == 1 and not shiny then w.price else 0,
					unique = not (w.price and st.stars == 1 and not shiny),
					minAge = 14,
					rarity = if shiny then (if st.stars == 3 then "unreal" else "legendary") else st.rarity,
					desc = w.desc .. " (" .. Weapons.GRADES[w.grade] .. "-grade " .. string.lower(fam.name) .. ")",
					clash = clash,
					fight = if next(fight) then fight else nil,
					look = { kind = fam.kind, color = w.c[1] },
					weapon = { base = w.id, stars = st.stars, shiny = shiny, power = power, grade = w.grade },
				}
				if fam.shape == "guard" then
					item.toughness = 1 - math.min(0.4, 0.06 * w.grade * st.mult)
					table.insert(extra, string.format("%d%% less damage", math.floor((1 - item.toughness) * 100 + 0.5)))
				end
				if shiny then
					item.heads = Weapons.SHINY.heads
					table.insert(extra, "+" .. Weapons.SHINY.heads .. "% heads")
					if fam.perk == "coins" then
						item.fight = item.fight or {}
						item.fight.coins = (item.fight.coins or 0) + 1
						table.insert(extra, "+1 coin in fights")
					elseif fam.perk == "power" then
						item.fight = item.fight or {}
						item.fight.coinPower = (item.fight.coinPower or 0) + 2
						table.insert(extra, "+2 power per heads in fights")
					elseif fam.perk == "guard" then
						item.toughness = (item.toughness or 1) * 0.85
						table.insert(extra, "15% less damage")
					elseif fam.perk == "mind" then
						item.yearly = { sanity = 3, intelligence = 1 }
						table.insert(extra, "+3 Composure and +1 Intelligence a year")
					elseif fam.perk == "life" then
						item.yearly = { vitality = 6, sanity = 2 }
						table.insert(extra, "+6 Vitality and +2 Composure a year")
					else
						item.heads += 4
						extra[#extra] = "+" .. (Weapons.SHINY.heads + 4) .. "% heads"
					end
				end
				local parts = {}
				for s, v in clash do
					local bits = {}
					if (v.base or 0) > 0 then
						table.insert(bits, "+" .. v.base .. " base")
					end
					if (v.coinPower or 0) > 0 then
						table.insert(bits, "+" .. v.coinPower .. " a heads")
					end
					if #bits > 0 then
						table.insert(parts, table.concat(bits, ", ") .. " (" .. s .. ")")
					end
				end
				if item.fight and item.fight.coins and not shiny then
					table.insert(parts, "+1 coin in fights")
				end
				for _, e in extra do
					table.insert(parts, e)
				end
				table.sort(parts)
				item.effect = table.concat(parts, "; ") .. "."
				table.insert(out, item)
			end
		end
	end
	return out
end

-- a drop: which weapon (by Gate rank, weighted to grades near it) at what rarity.
-- rng(n) -> 1..n, roll() -> [0, 1). opts: { minStars, shinyBoost }
function Weapons.roll(rank: number, rng: (number) -> number, roll: () -> number, opts: any?): (string, number, boolean)
	opts = opts or {}
	local pool, weights = {}, {}
	for _, w in Weapons.list do
		local gap = math.abs(w.grade - rank)
		if gap <= 1 then
			table.insert(pool, w.id)
			table.insert(weights, if gap == 0 then 3 else 1)
		end
	end
	local total = 0
	for _, wt in weights do
		total += wt
	end
	local r = roll() * total
	local base = pool[#pool]
	for i, wt in weights do
		r -= wt
		if r <= 0 then
			base = pool[i]
			break
		end
	end
	local sw = Weapons.ODDS.stars
	local stotal = sw[1] + sw[2] + sw[3]
	local sr = roll() * stotal
	local stars = if sr < sw[1] then 1 elseif sr < sw[1] + sw[2] then 2 else 3
	stars = math.max(stars, opts.minStars or 1)
	local shiny = roll() < Weapons.ODDS.shiny * (opts.shinyBoost or 1)
	local _ = rng
	return base, stars, shiny
end

return Weapons
