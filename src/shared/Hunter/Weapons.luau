--[[
	THE WEAPONS (BitLeveling, ORIGINAL items in the canon economy: Hunters fight with weapons
	forged from monster materials and mana crystals, bought from workshops or brought out of
	Gates, and the rare ones go to auction).

	A weapon you own is a BASE (one of the list below: a family, a grade E..S, an element, a
	look) at a RARITY: one to three stars, and sometimes SHINY.
		★      the plain forging                                   x1.00
		★★     a fine one: better steel, better balance            x1.35
		★★★    a masterwork                                        x1.80
		Shiny  any star can come out shiny (about 1 in 60 drops): a weapon the mana has soaked
		       into. Very good buffs on top (+45% power, +6% heads in every clash, and a perk of
		       its family), and it shimmers in the hand.
	The odds of a drop's rarity are shown in game (Weapons.ODDS), never sold.

	Every family leans to one of canon's six classes (FAMILIES[f].class; every weapon copies it
	as w.class), and every weapon has an ELEMENT (fire, frost, lightning, venom, void, holy,
	wind, earth, or none): the colour and the effects it throws off in the city
	(Hunter/WeaponModels: ambient particles, light, the swing trail; client/WeaponFx: swings
	and hits). FAMILIES[f].fx is how a swing of it is drawn (slash, smash, thrust, shot, throw,
	spell, heal, punch, lash, bash, gust).

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

-- canon's six Hunter classes (the class a family leans to)
Weapons.CLASSES = { "fighter", "mage", "assassin", "tanker", "ranger", "healer" }
Weapons.CLASS_NAMES = { fighter = "Fighter", mage = "Mage", assassin = "Assassin", tanker = "Tanker", ranger = "Ranger", healer = "Healer" }

-- the elements: colour (the glow), deep (the shadow of it), light (the hot core)
Weapons.ELEMENT_LIST = { "none", "fire", "frost", "lightning", "venom", "void", "holy", "wind", "earth" }
Weapons.ELEMENTS = {
	none = { name = "None", color = { 120, 175, 255 }, deep = { 60, 110, 220 }, light = { 220, 236, 255 } },
	fire = { name = "Fire", color = { 255, 120, 40 }, deep = { 200, 40, 20 }, light = { 255, 220, 130 } },
	frost = { name = "Frost", color = { 150, 220, 255 }, deep = { 70, 140, 230 }, light = { 235, 250, 255 } },
	lightning = { name = "Lightning", color = { 255, 232, 90 }, deep = { 120, 150, 255 }, light = { 255, 255, 230 } },
	venom = { name = "Venom", color = { 120, 230, 80 }, deep = { 40, 130, 50 }, light = { 210, 255, 170 } },
	void = { name = "Void", color = { 150, 80, 240 }, deep = { 40, 10, 80 }, light = { 220, 190, 255 } },
	holy = { name = "Holy", color = { 255, 236, 170 }, deep = { 255, 190, 90 }, light = { 255, 252, 235 } },
	wind = { name = "Wind", color = { 150, 255, 200 }, deep = { 60, 190, 150 }, light = { 230, 255, 245 } },
	earth = { name = "Earth", color = { 214, 160, 80 }, deep = { 120, 80, 40 }, light = { 255, 220, 160 } },
}

-- what the families fight with, how their power is shaped, and what a shiny one adds
-- stat: the clash stat it powers; shape: how the power splits (base / coinPower / coins)
-- perk: the shiny perk; kind: what the life avatar draws (Engine/Arms kinds); class: the class
-- it leans to; fx: how a swing is drawn in the city (client/WeaponFx)
Weapons.FAMILIES = {
	-- fighter
	sword = { name = "Sword", stat = "strength", shape = "even", perk = "heads", kind = "sword", hands = 1, class = "fighter", fx = "slash" },
	katana = { name = "Katana", stat = "strength", shape = "sharp", perk = "heads", kind = "katana", hands = 1, class = "fighter", fx = "slash" },
	odachi = { name = "Odachi", stat = "strength", shape = "sharp", perk = "heads", kind = "katana", hands = 1, class = "fighter", fx = "slash" },
	twinswords = { name = "Twin Swords", stat = "strength", shape = "quick", perk = "coins", kind = "sword", hands = 2, class = "fighter", fx = "slash" },
	greatsword = { name = "Greatsword", stat = "strength", shape = "heavy", perk = "power", kind = "greatsword", hands = 1, class = "fighter", fx = "slash" },
	cleaver = { name = "Cleaver", stat = "strength", shape = "heavy", perk = "power", kind = "cleaver", hands = 1, class = "fighter", fx = "slash" },
	scythe = { name = "Scythe", stat = "strength", shape = "sharp", perk = "power", kind = "scythe", hands = 1, class = "fighter", fx = "slash" },
	spear = { name = "Spear", stat = "agility", shape = "even", perk = "coins", kind = "spear", hands = 1, class = "fighter", fx = "thrust" },
	trident = { name = "Trident", stat = "strength", shape = "even", perk = "heads", kind = "trident", hands = 1, class = "fighter", fx = "thrust" },
	axe = { name = "Axe", stat = "strength", shape = "heavy", perk = "power", kind = "axe", hands = 1, class = "fighter", fx = "slash" },
	axes = { name = "Twin Axes", stat = "strength", shape = "quick", perk = "coins", kind = "axe", hands = 2, class = "fighter", fx = "slash" },
	greataxe = { name = "Greataxe", stat = "strength", shape = "heavy", perk = "power", kind = "axe", hands = 1, class = "fighter", fx = "smash" },
	warhammer = { name = "Warhammer", stat = "strength", shape = "heavy", perk = "power", kind = "maul", hands = 1, class = "fighter", fx = "smash" },
	gauntlets = { name = "Gauntlets", stat = "strength", shape = "quick", perk = "coins", kind = "gauntlets", hands = 2, class = "fighter", fx = "punch" },
	-- tanker
	shield = { name = "Shield", stat = "vitality", shape = "guard", perk = "guard", kind = "shield", hands = 2, class = "tanker", fx = "bash" },
	buckler = { name = "Buckler", stat = "vitality", shape = "guard", perk = "guard", kind = "shield", hands = 2, class = "tanker", fx = "bash" },
	towershield = { name = "Tower Shield", stat = "vitality", shape = "guard", perk = "guard", kind = "shield", hands = 2, class = "tanker", fx = "bash" },
	mace = { name = "Mace", stat = "strength", shape = "even", perk = "guard", kind = "mace", hands = 1, class = "tanker", fx = "smash" },
	hammer = { name = "Hammer", stat = "strength", shape = "heavy", perk = "guard", kind = "maul", hands = 1, class = "tanker", fx = "smash" },
	flail = { name = "Flail", stat = "strength", shape = "even", perk = "power", kind = "flail", hands = 1, class = "tanker", fx = "smash" },
	halberd = { name = "Halberd", stat = "strength", shape = "heavy", perk = "guard", kind = "halberd", hands = 1, class = "tanker", fx = "slash" },
	glaive = { name = "Glaive", stat = "strength", shape = "heavy", perk = "guard", kind = "glaive", hands = 1, class = "tanker", fx = "slash" },
	lance = { name = "Lance", stat = "strength", shape = "heavy", perk = "guard", kind = "spear", hands = 1, class = "tanker", fx = "thrust" },
	-- assassin
	dagger = { name = "Dagger", stat = "agility", shape = "quick", perk = "coins", kind = "dagger", hands = 1, class = "assassin", fx = "slash" },
	daggers = { name = "Twin Daggers", stat = "agility", shape = "quick", perk = "coins", kind = "daggers", hands = 2, class = "assassin", fx = "slash" },
	rapier = { name = "Rapier", stat = "agility", shape = "sharp", perk = "heads", kind = "rapier", hands = 1, class = "assassin", fx = "thrust" },
	sai = { name = "Sai", stat = "agility", shape = "quick", perk = "coins", kind = "daggers", hands = 2, class = "assassin", fx = "thrust" },
	katar = { name = "Katars", stat = "agility", shape = "quick", perk = "heads", kind = "claws", hands = 2, class = "assassin", fx = "punch" },
	claws = { name = "Claws", stat = "agility", shape = "quick", perk = "coins", kind = "claws", hands = 2, class = "assassin", fx = "punch" },
	whip = { name = "Whip", stat = "agility", shape = "sharp", perk = "coins", kind = "whip", hands = 1, class = "assassin", fx = "lash" },
	chainblade = { name = "Chain-Blade", stat = "agility", shape = "quick", perk = "coins", kind = "chainblade", hands = 1, class = "assassin", fx = "lash" },
	kusarigama = { name = "Kusarigama", stat = "agility", shape = "sharp", perk = "coins", kind = "sickle", hands = 2, class = "assassin", fx = "lash" },
	-- ranger
	bow = { name = "Bow", stat = "agility", shape = "sharp", perk = "heads", kind = "crossbow", hands = 1, class = "ranger", fx = "shot" },
	longbow = { name = "Longbow", stat = "agility", shape = "sharp", perk = "heads", kind = "crossbow", hands = 1, class = "ranger", fx = "shot" },
	crossbow = { name = "Crossbow", stat = "agility", shape = "even", perk = "heads", kind = "crossbow", hands = 1, class = "ranger", fx = "shot" },
	arbalest = { name = "Arbalest", stat = "agility", shape = "heavy", perk = "power", kind = "crossbow", hands = 1, class = "ranger", fx = "shot" },
	javelin = { name = "Javelins", stat = "agility", shape = "even", perk = "coins", kind = "spear", hands = 1, class = "ranger", fx = "throw" },
	kunai = { name = "Throwing Knives", stat = "agility", shape = "quick", perk = "coins", kind = "knife", hands = 1, class = "ranger", fx = "throw" },
	chakram = { name = "Chakrams", stat = "agility", shape = "quick", perk = "heads", kind = "fan", hands = 2, class = "ranger", fx = "throw" },
	-- mage
	staff = { name = "Staff", stat = "intelligence", shape = "even", perk = "mind", kind = "staff", hands = 1, class = "mage", fx = "spell" },
	wand = { name = "Wand", stat = "intelligence", shape = "sharp", perk = "mind", kind = "baton", hands = 1, class = "mage", fx = "spell" },
	orb = { name = "Focus", stat = "intelligence", shape = "even", perk = "mind", kind = "lamp", hands = 1, class = "mage", fx = "spell" },
	crystal = { name = "Crystal Focus", stat = "intelligence", shape = "even", perk = "mind", kind = "lamp", hands = 1, class = "mage", fx = "spell" },
	tome = { name = "Grimoire", stat = "intelligence", shape = "sharp", perk = "mind", kind = "book", hands = 1, class = "mage", fx = "spell" },
	codex = { name = "Floating Grimoire", stat = "intelligence", shape = "sharp", perk = "mind", kind = "book", hands = 1, class = "mage", fx = "spell" },
	tablet = { name = "Rune Tablet", stat = "intelligence", shape = "even", perk = "mind", kind = "book", hands = 1, class = "mage", fx = "spell" },
	warfan = { name = "War Fan", stat = "intelligence", shape = "sharp", perk = "mind", kind = "fan", hands = 1, class = "mage", fx = "gust" },
	-- healer
	censer = { name = "Lantern", stat = "willpower", shape = "even", perk = "life", kind = "censer", hands = 1, class = "healer", fx = "heal" },
	thurible = { name = "Thurible", stat = "willpower", shape = "even", perk = "life", kind = "censer", hands = 1, class = "healer", fx = "heal" },
	bell = { name = "Handbell", stat = "willpower", shape = "even", perk = "life", kind = "bell", hands = 1, class = "healer", fx = "heal" },
	rod = { name = "Rod", stat = "willpower", shape = "even", perk = "life", kind = "staff", hands = 1, class = "healer", fx = "heal" },
	scepter = { name = "Scepter", stat = "willpower", shape = "sharp", perk = "life", kind = "baton", hands = 1, class = "healer", fx = "heal" },
	crescent = { name = "Crescent Staff", stat = "willpower", shape = "even", perk = "life", kind = "staff", hands = 1, class = "healer", fx = "heal" },
}
-- the families in a fixed order (by class, then as listed above)
Weapons.FAMILY_ORDER = {
	"sword", "katana", "odachi", "twinswords", "greatsword", "cleaver", "scythe", "spear", "trident", "axe", "axes", "greataxe", "warhammer", "gauntlets",
	"shield", "buckler", "towershield", "mace", "hammer", "flail", "halberd", "glaive", "lance",
	"dagger", "daggers", "rapier", "sai", "katar", "claws", "whip", "chainblade", "kusarigama",
	"bow", "longbow", "crossbow", "arbalest", "javelin", "kunai", "chakram",
	"staff", "wand", "orb", "crystal", "tome", "codex", "tablet", "warfan",
	"censer", "thurible", "bell", "rod", "scepter", "crescent",
}

-- base power by grade (E..S): what a ★ weapon adds to its stat's base in a clash
Weapons.POWER = { 2, 3, 5, 7, 10, 14 }

-- c: colours (blade/head, grip, trim, glow); p: shape knobs the model reads; price: in the
-- workshops (★ only, grades E..C); element: what it throws off (Weapons.ELEMENTS)
local function rgb(r, g, b)
	return { r, g, b }
end
local STEEL, DARK, BRASS, WOOD, BONE = rgb(196, 200, 210), rgb(34, 30, 30), rgb(200, 160, 80), rgb(92, 66, 44), rgb(226, 218, 196)
local MANA, FROST, FIRE, VENOM, VOID, GOLD = rgb(90, 160, 255), rgb(170, 230, 255), rgb(255, 120, 50), rgb(130, 230, 90), rgb(150, 80, 230), rgb(255, 210, 90)
local SILVER, IRON, LEATHER, BRONZE, JADE = rgb(222, 226, 236), rgb(104, 106, 114), rgb(84, 58, 40), rgb(176, 118, 62), rgb(80, 190, 140)
local OBSIDIAN, CRIMSON, NAVY, STONE, ICE = rgb(28, 26, 38), rgb(150, 28, 36), rgb(30, 44, 90), rgb(130, 124, 116), rgb(200, 236, 255)
local BOLT, HOLY, WIND, EARTH, EMBER, TEAL = rgb(255, 236, 100), rgb(255, 244, 200), rgb(150, 255, 205), rgb(214, 160, 80), rgb(255, 96, 40), rgb(60, 200, 190)
local SEA, VIOLET = rgb(30, 50, 46), rgb(170, 140, 250)

Weapons.list = {
	-- ══ FIGHTER ══════════════════════════════════════════════════════════════
	-- swords
	{ id = "shortsword", name = "Hunter's Shortsword", family = "sword", grade = 1, element = "none", price = 3, c = { STEEL, DARK, BRASS, MANA }, p = { len = 2.4, width = 0.3 }, desc = "The sword every rookie raid party has three of." },
	{ id = "assoc_longsword", name = "Association Longsword", family = "sword", grade = 2, element = "none", price = 7, c = { STEEL, rgb(28, 50, 110), rgb(220, 225, 235), MANA }, p = { len = 3.2, width = 0.32 }, desc = "Standard issue for public raids. Plain, honest, reliable." },
	{ id = "crystal_longsword", name = "Crystal-Tempered Longsword", family = "sword", grade = 3, element = "none", price = 16, c = { rgb(200, 220, 240), DARK, BRASS, MANA }, p = { len = 3.4, width = 0.34, fuller = true }, desc = "Quenched in crystal water. It holds an edge on things steel shouldn't cut." },
	{ id = "warlord_blade", name = "Orc Warlord's Blade", family = "sword", grade = 3, element = "fire", c = { rgb(120, 100, 90), rgb(60, 40, 30), rgb(150, 40, 30), FIRE }, p = { len = 3.3, width = 0.5, notched = true }, desc = "Notched, heavy, and still warm. Taken from a C-rank boss." },
	{ id = "frostbite_saber", name = "Frostbite Saber", family = "sword", grade = 4, element = "frost", c = { FROST, rgb(40, 60, 90), rgb(220, 240, 255), FROST }, p = { len = 3.3, width = 0.3, curve = 0.25 }, desc = "Frost creeps along the blade in a warm room." },
	{ id = "golem_heart_blade", name = "Golem-Heart Blade", family = "sword", grade = 5, element = "earth", c = { rgb(150, 140, 130), DARK, rgb(255, 170, 60), rgb(255, 170, 60) }, p = { len = 3.6, width = 0.42, gem = true }, desc = "A golem's core set in the hilt. It beats, slowly." },
	{ id = "starfall_edge", name = "Starfall Edge", family = "sword", grade = 6, element = "holy", c = { rgb(230, 236, 255), rgb(30, 30, 60), GOLD, rgb(140, 200, 255) }, p = { len = 3.9, width = 0.4, fuller = true, gem = true }, desc = "Forged from a fragment of an S-rank boss. Guilds bid in billions for less." },
	-- katana and odachi
	{ id = "plain_katana", name = "Plain Katana", family = "katana", grade = 2, element = "none", price = 8, c = { STEEL, DARK, rgb(180, 150, 80), MANA }, p = { len = 3.1 }, desc = "A good blade with no story yet." },
	{ id = "moonlit_katana", name = "Moonlit Katana", family = "katana", grade = 4, element = "holy", c = { rgb(210, 220, 255), rgb(30, 30, 50), rgb(200, 200, 230), rgb(180, 200, 255) }, p = { len = 3.3 }, desc = "It catches light that isn't in the room." },
	{ id = "thousand_cut", name = "Thousand-Cut Katana", family = "katana", grade = 5, element = "wind", c = { rgb(240, 240, 245), rgb(80, 10, 20), GOLD, rgb(255, 70, 90) }, p = { len = 3.5 }, desc = "Every cut it makes is the same cut, perfect." },
	{ id = "field_odachi", name = "Field Odachi", family = "odachi", grade = 2, element = "none", price = 8, c = { STEEL, NAVY, SILVER, MANA }, p = { len = 4.4 }, desc = "Too long for the subway. Exactly long enough for a hobgoblin." },
	{ id = "riverstone_odachi", name = "Riverstone Odachi", family = "odachi", grade = 3, element = "wind", c = { rgb(210, 222, 230), rgb(40, 60, 56), JADE, WIND }, p = { len = 4.7 }, desc = "Ground on a riverbed stone inside a C-rank Gate. It whistles when it moves." },
	{ id = "emberwake_odachi", name = "Ember-Wake Odachi", family = "odachi", grade = 4, element = "fire", c = { rgb(230, 226, 220), CRIMSON, BRASS, EMBER }, p = { len = 5.0, gem = true }, desc = "It leaves a line of sparks hanging in the air behind every cut." },
	{ id = "stormcutter", name = "Stormcutter Odachi", family = "odachi", grade = 5, element = "lightning", c = { rgb(225, 232, 245), OBSIDIAN, GOLD, BOLT }, p = { len = 5.2 }, desc = "Raised in an A-rank storm cavern. The thunder followed it home." },
	{ id = "heavenrend", name = "Heavenrend", family = "odachi", grade = 6, element = "holy", c = { rgb(244, 244, 252), rgb(60, 50, 80), GOLD, HOLY }, p = { len = 5.6, gem = true }, desc = "The longest blade the Association has ever licensed. It has never needed a second swing." },
	-- twin swords
	{ id = "practice_pair", name = "Paired Practice Swords", family = "twinswords", grade = 1, element = "none", price = 3, c = { IRON, LEATHER, BRASS, MANA }, p = { len = 2.2 }, desc = "Blunted for drills, then sharpened for the real thing." },
	{ id = "gale_sabers", name = "Gale Twin Sabers", family = "twinswords", grade = 3, element = "wind", c = { rgb(214, 230, 226), SEA, SILVER, WIND }, p = { len = 2.6, curve = 0.3 }, desc = "Light as a breeze and twice as hard to see coming." },
	{ id = "frostbound_pair", name = "Frostbound Pair", family = "twinswords", grade = 4, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { len = 2.8, fuller = true }, desc = "Two blades cut from one sheet of cavern ice that never melts." },
	{ id = "sun_moon_blades", name = "Sun-and-Moon Blades", family = "twinswords", grade = 5, element = "holy", c = { rgb(250, 240, 210), rgb(40, 40, 70), GOLD, HOLY }, p = { len = 3.0, gem = true, fuller = true }, desc = "One warm, one cool. They hum in harmony when crossed." },
	{ id = "twin_comets", name = "Twin Comets", family = "twinswords", grade = 6, element = "fire", c = { rgb(255, 236, 220), OBSIDIAN, GOLD, EMBER }, p = { len = 3.2, curve = 0.2, gem = true }, desc = "Forged from two halves of one falling stone. They burn hotter together." },
	-- greatswords and cleavers
	{ id = "executioner_slab", name = "Executioner's Slab", family = "greatsword", grade = 3, element = "fire", c = { rgb(110, 112, 118), DARK, rgb(90, 90, 96), FIRE }, p = { len = 4.2, width = 0.7 }, desc = "Less a sword than a door with an edge." },
	{ id = "ogre_greatsword", name = "Ogre-Iron Greatsword", family = "greatsword", grade = 4, element = "fire", c = { rgb(120, 116, 110), rgb(60, 40, 30), BRASS, FIRE }, p = { len = 4.4, width = 0.62 }, desc = "Forged from what a B-rank Gate left behind. Heavy enough to argue with an ogre." },
	{ id = "dragonkin_fang", name = "Dragon-kin Fang Greatsword", family = "greatsword", grade = 6, element = "fire", c = { rgb(240, 236, 226), rgb(40, 20, 50), GOLD, rgb(255, 80, 40) }, p = { len = 4.8, width = 0.7, gem = true }, desc = "One fang, ground into a blade. The heat never leaves it." },
	{ id = "butcher_cleaver", name = "Market Butcher's Cleaver", family = "cleaver", grade = 1, element = "none", price = 2, c = { STEEL, WOOD, STEEL, MANA }, p = { len = 1.6, width = 0.8 }, desc = "Not made for monsters. It works anyway." },
	{ id = "titan_cleaver", name = "Titan's Cleaver", family = "cleaver", grade = 5, element = "fire", c = { rgb(150, 150, 156), DARK, rgb(200, 60, 40), FIRE }, p = { len = 3.6, width = 1.1 }, desc = "A butcher's blade sized for things that eat buildings." },
	-- scythes
	{ id = "reaper_crescent", name = "Reaper's Crescent", family = "scythe", grade = 4, element = "void", c = { rgb(70, 70, 80), WOOD, rgb(150, 150, 160), VOID }, p = { len = 5.2 }, desc = "A wraith's blade on a shaft of black ash." },
	{ id = "wraith_harvester", name = "Wraith Harvester", family = "scythe", grade = 5, element = "void", c = { rgb(40, 40, 60), DARK, rgb(120, 100, 200), VOID }, p = { len = 5.6 }, desc = "It hums when someone near it is afraid." },
	-- spears and tridents
	{ id = "hunter_spear", name = "Hunter's Spear", family = "spear", grade = 1, element = "none", price = 3, c = { STEEL, WOOD, BRASS, MANA }, p = { len = 6 }, desc = "Keep the goblins at arm's length. A long arm." },
	{ id = "lizard_spear", name = "Lizardman-Bone Spear", family = "spear", grade = 2, element = "venom", price = 7, c = { BONE, WOOD, rgb(90, 140, 90), VENOM }, p = { len = 6.2 }, desc = "Light, nasty on the tip, and it doesn't rust." },
	{ id = "lightning_pike", name = "Lightning Pike", family = "spear", grade = 4, element = "lightning", c = { rgb(220, 230, 255), DARK, GOLD, rgb(180, 220, 255) }, p = { len = 6.6, prongs = true }, desc = "It crackles before it strikes." },
	{ id = "wyvern_lance", name = "Wyvern-Tail Lance", family = "spear", grade = 5, element = "venom", c = { rgb(110, 150, 110), rgb(40, 50, 40), GOLD, VENOM }, p = { len = 7, lance = true }, desc = "The tail-spike of an A-rank wyvern, mounted on a lance." },
	{ id = "harbor_trident", name = "Harbor Patrol Trident", family = "trident", grade = 2, element = "none", price = 7, c = { STEEL, WOOD, BRASS, MANA }, p = { len = 5.6 }, desc = "Coast guard issue. Made for nets and boats; it learned monsters fast." },
	{ id = "tidecaller", name = "Tidecaller Trident", family = "trident", grade = 3, element = "frost", c = { rgb(180, 220, 230), rgb(30, 60, 70), TEAL, FROST }, p = { len = 5.8 }, desc = "Cold sea water beads on the prongs, even in summer." },
	{ id = "naga_fork", name = "Naga Warden's Fork", family = "trident", grade = 4, element = "venom", c = { rgb(120, 190, 160), rgb(20, 50, 40), JADE, VENOM }, p = { len = 6, barbs = true }, desc = "Taken from the naga that guarded a B-rank Gate's flooded halls." },
	{ id = "stormfork", name = "Stormfork", family = "trident", grade = 5, element = "lightning", c = { rgb(220, 226, 240), NAVY, GOLD, BOLT }, p = { len = 6.2, gem = true }, desc = "Lightning lands on it in a storm. It seems to enjoy that." },
	{ id = "abyssal_trident", name = "Abyssal Trident", family = "trident", grade = 6, element = "void", c = { rgb(84, 72, 128), OBSIDIAN, VIOLET, VOID }, p = { len = 6.6, gem = true, barbs = true }, desc = "Pulled from a sunken S-rank dungeon. The water around it goes dark." },
	-- axes
	{ id = "woodsman_axe", name = "Woodsman's Axe", family = "axe", grade = 1, element = "none", price = 2, c = { STEEL, WOOD, STEEL, MANA }, p = { len = 2.6 }, desc = "Someone's grandfather's. It's seen worse than goblins." },
	{ id = "hob_axe", name = "Hobgoblin Cleaver-Axe", family = "axe", grade = 2, element = "none", price = 6, c = { rgb(120, 110, 100), rgb(70, 50, 30), rgb(110, 90, 60), FIRE }, p = { len = 2.8, double = true }, desc = "Crude, double-bitted, and very hard to stop." },
	{ id = "berserker_axes", name = "Berserker Twin Axes", family = "axes", grade = 4, element = "fire", c = { rgb(150, 140, 140), DARK, rgb(160, 30, 30), rgb(255, 60, 60) }, p = { len = 2.6 }, desc = "Two axes, no shield, no plan." },
	{ id = "world_splitter", name = "World-Splitter", family = "axe", grade = 6, element = "earth", c = { rgb(220, 210, 190), rgb(30, 20, 20), GOLD, rgb(255, 140, 60) }, p = { len = 3.6, double = true, gem = true }, desc = "The S-rank raid that brought it out lost four Hunters. Nobody uses it gently." },
	{ id = "logger_greataxe", name = "Logger's Greataxe", family = "greataxe", grade = 2, element = "none", price = 7, c = { STEEL, WOOD, IRON, MANA }, p = { len = 4.2 }, desc = "Bought to clear trees after a break. Now it clears other things." },
	{ id = "rimecleft", name = "Rimecleft Greataxe", family = "greataxe", grade = 4, element = "frost", c = { ICE, rgb(50, 64, 90), SILVER, FROST }, p = { len = 4.4 }, desc = "Every swing leaves frost on whatever it misses." },
	{ id = "thunderhead", name = "Thunderhead Greataxe", family = "greataxe", grade = 5, element = "lightning", c = { rgb(200, 206, 220), OBSIDIAN, GOLD, BOLT }, p = { len = 4.6, gem = true }, desc = "The air smells of rain when it comes out of its case." },
	{ id = "ruinmaker", name = "Ruinmaker", family = "greataxe", grade = 6, element = "earth", c = { rgb(150, 130, 110), rgb(40, 28, 20), GOLD, EARTH }, p = { len = 5.0, gem = true }, desc = "Made for siege walls, not monsters. It doesn't mind the difference." },
	-- warhammers
	{ id = "forge_warhammer", name = "Forge Warhammer", family = "warhammer", grade = 3, element = "fire", c = { IRON, WOOD, BRASS, FIRE }, p = { len = 4.2 }, desc = "Pried off a smithy's anvil stand. The head is still warm." },
	{ id = "quarry_breaker", name = "Quarry Breaker", family = "warhammer", grade = 4, element = "earth", c = { STONE, LEATHER, BRONZE, EARTH }, p = { len = 4.4 }, desc = "A mining hammer that went into an earth-type Gate and came out different." },
	{ id = "stormanvil", name = "Stormanvil", family = "warhammer", grade = 5, element = "lightning", c = { rgb(160, 166, 180), OBSIDIAN, GOLD, BOLT }, p = { len = 4.6, gem = true }, desc = "Each blow rings like a bell and lands like a storm." },
	{ id = "sealbreaker_maul", name = "Sealbreaker Maul", family = "warhammer", grade = 6, element = "holy", c = { rgb(236, 232, 222), rgb(50, 40, 70), GOLD, HOLY }, p = { len = 5, gem = true }, desc = "It keeps ringing for a full minute after every blow." },
	-- gauntlets
	{ id = "brawler_wraps", name = "Brawler's Wraps", family = "gauntlets", grade = 1, element = "none", price = 2, c = { rgb(220, 210, 190), DARK, rgb(160, 40, 40), MANA }, p = {}, desc = "Tape, padding and attitude." },
	{ id = "iron_knuckles", name = "Iron Knuckles", family = "gauntlets", grade = 2, element = "none", price = 6, c = { rgb(120, 120, 126), DARK, STEEL, MANA }, p = { studs = true }, desc = "Iron over the knuckles, leather over the rest." },
	{ id = "titan_fists", name = "Titan Fists", family = "gauntlets", grade = 5, element = "earth", c = { rgb(140, 130, 120), DARK, rgb(255, 170, 60), rgb(255, 170, 60) }, p = { big = true }, desc = "Golem stone on the knuckles. Walls are a suggestion." },

	-- ══ TANKER ═══════════════════════════════════════════════════════════════
	-- shields
	{ id = "riot_shield", name = "Riot Shield & Baton", family = "shield", grade = 1, element = "none", price = 3, c = { rgb(40, 50, 60), DARK, rgb(200, 210, 220), MANA }, p = {}, desc = "Police surplus. It's held a cordon or two." },
	{ id = "gatewatch_kite", name = "Gatewatch Kite Shield", family = "shield", grade = 2, element = "none", price = 7, c = { rgb(40, 60, 110), DARK, SILVER, MANA }, p = { kite = true }, desc = "An Association sentry's kite shield, with an arming sword to match." },
	{ id = "tower_shield", name = "Tower Shield", family = "shield", grade = 3, element = "none", price = 16, c = { rgb(120, 124, 132), DARK, BRASS, MANA }, p = { big = true }, desc = "A wall you carry." },
	{ id = "bearhide_round", name = "Bearhide Round Shield", family = "shield", grade = 4, element = "frost", c = { rgb(230, 232, 236), LEATHER, SILVER, FROST }, p = { round = true }, desc = "Ice bear hide over oak. Cold to the touch, warm behind." },
	{ id = "bulwark", name = "Bulwark of the Wall", family = "shield", grade = 5, element = "holy", c = { rgb(160, 150, 140), DARK, GOLD, rgb(255, 210, 120) }, p = { big = true, gem = true }, desc = "Every dent is a raid it brought someone home from." },
	{ id = "training_buckler", name = "Training Buckler & Gladius", family = "buckler", grade = 1, element = "none", price = 3, c = { IRON, LEATHER, BRASS, MANA }, p = { size = 1.25, len = 1.9 }, desc = "A fist-sized shield and a short sword: the first lesson in not getting hit." },
	{ id = "riveted_buckler", name = "Riveted Buckler & Shortsword", family = "buckler", grade = 2, element = "none", price = 7, c = { STEEL, DARK, BRASS, MANA }, p = { size = 1.35, len = 2.1, studs = true }, desc = "Twelve rivets, each one put in by hand." },
	{ id = "ember_buckler", name = "Ember Buckler", family = "buckler", grade = 3, element = "fire", c = { rgb(150, 80, 60), DARK, BRASS, FIRE }, p = { size = 1.4, len = 2.2, studs = true }, desc = "Its face glows like coals when something hits it." },
	{ id = "mirror_buckler", name = "Mirror Buckler", family = "buckler", grade = 4, element = "holy", c = { SILVER, NAVY, GOLD, HOLY }, p = { size = 1.5, len = 2.3, gem = true }, desc = "Polished until monsters flinch at their own reflection." },
	{ id = "gale_buckler", name = "Gale Buckler & Spatha", family = "buckler", grade = 5, element = "wind", c = { rgb(210, 230, 224), SEA, SILVER, WIND }, p = { size = 1.55, len = 2.6, gem = true }, desc = "It turns arrows aside before they arrive." },
	{ id = "cordon_pavise", name = "Cordon Pavise & Mace", family = "towershield", grade = 2, element = "none", price = 8, c = { rgb(70, 80, 92), DARK, rgb(220, 200, 80), MANA }, p = {}, desc = "A police barricade with a handle. The mace was an afterthought." },
	{ id = "frostwall", name = "Frostwall Pavise", family = "towershield", grade = 4, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { big = true }, desc = "Ice grows across its face to seal any crack." },
	{ id = "obsidian_rampart", name = "Obsidian Rampart", family = "towershield", grade = 5, element = "earth", c = { OBSIDIAN, DARK, BRONZE, EARTH }, p = { big = true, gem = true }, desc = "Black stone, a hand thick. A wyvern broke a tooth on it." },
	{ id = "last_line_aegis", name = "Aegis of the Last Line", family = "towershield", grade = 6, element = "holy", c = { rgb(236, 232, 220), rgb(50, 40, 70), GOLD, HOLY }, p = { big = true, gem = true }, desc = "It has stood at the front of every S-rank raid it went on. All of them came home." },
	-- maces, hammers, flails
	{ id = "iron_mace", name = "Iron Mace", family = "mace", grade = 1, element = "none", price = 2, c = { rgb(120, 120, 126), WOOD, STEEL, MANA }, p = { len = 2.4 }, desc = "A ball of iron on a stick. Effective for exactly that reason." },
	{ id = "patrol_flanged_mace", name = "Flanged Patrol Mace", family = "mace", grade = 2, element = "none", price = 6, c = { IRON, LEATHER, STEEL, MANA }, p = { len = 2.6, flanged = true }, desc = "Six iron flanges. Made for armour; works on shells." },
	{ id = "spiked_morningstar", name = "Spiked Morningstar", family = "mace", grade = 3, element = "none", c = { rgb(100, 100, 106), DARK, BRASS, FIRE }, p = { len = 2.8, spikes = true }, desc = "Spikes on spikes." },
	{ id = "warden_mace", name = "Warden's Flanged Mace", family = "mace", grade = 5, element = "holy", c = { SILVER, rgb(60, 50, 80), GOLD, HOLY }, p = { len = 3, flanged = true, gem = true }, desc = "The Healers' escorts carry it. Nothing gets past them twice." },
	{ id = "stonebreaker", name = "Stone-Breaker Hammer", family = "hammer", grade = 3, element = "earth", price = 15, c = { rgb(110, 110, 116), WOOD, BRASS, FIRE }, p = { len = 3.4 }, desc = "Made for golems. Works on everything else." },
	{ id = "golem_maul", name = "Golem Maul", family = "hammer", grade = 5, element = "earth", c = { rgb(150, 140, 130), DARK, rgb(255, 170, 60), rgb(255, 170, 60) }, p = { len = 4, big = true }, desc = "A golem's fist on a pillar of iron." },
	{ id = "earthshaker", name = "Earthshaker", family = "hammer", grade = 6, element = "earth", c = { rgb(80, 70, 60), DARK, GOLD, rgb(255, 120, 60) }, p = { len = 4.4, big = true, gem = true }, desc = "When it lands, the street remembers it." },
	{ id = "chain_flail", name = "Chain Flail", family = "flail", grade = 1, element = "none", price = 2, c = { IRON, WOOD, STEEL, MANA }, p = {}, desc = "An iron ball, a chain and a handle. Mostly the ball." },
	{ id = "cinder_flail", name = "Cinder Flail", family = "flail", grade = 3, element = "fire", c = { rgb(90, 70, 64), DARK, BRASS, EMBER }, p = { spikes = true }, desc = "The head is hollow and full of embers that never go out." },
	{ id = "hollowbell_flail", name = "Hollowbell Flail", family = "flail", grade = 4, element = "void", c = { rgb(60, 56, 80), OBSIDIAN, rgb(150, 120, 220), VOID }, p = { spikes = true }, desc = "It makes no sound on the swing and a terrible one on the landing." },
	{ id = "thornstar", name = "Thornstar Flail", family = "flail", grade = 5, element = "venom", c = { rgb(90, 110, 80), DARK, JADE, VENOM }, p = { spikes = true, twin = true }, desc = "Two heads, too many thorns, and a coating nobody wants to touch." },
	{ id = "meteor_flail", name = "Meteor Flail", family = "flail", grade = 6, element = "earth", c = { rgb(80, 60, 50), OBSIDIAN, GOLD, EARTH }, p = { spikes = true, big = true }, desc = "The head is a fallen star, still cracked and glowing." },
	-- polearms
	{ id = "guard_halberd", name = "Guard Halberd", family = "halberd", grade = 3, element = "none", price = 14, c = { STEEL, WOOD, BRASS, MANA }, p = { len = 6.4 }, desc = "The cordon officer's best friend, when the cordon fails." },
	{ id = "glacier_halberd", name = "Glacier Halberd", family = "halberd", grade = 5, element = "frost", c = { FROST, rgb(50, 70, 100), rgb(220, 240, 255), FROST }, p = { len = 6.8 }, desc = "Cut from the ice of a cavern that was always snowing." },
	{ id = "guardpost_glaive", name = "Guardpost Glaive", family = "glaive", grade = 1, element = "none", price = 3, c = { STEEL, WOOD, IRON, MANA }, p = { len = 5.6 }, desc = "Long enough to keep a goblin well on the other side of the tape." },
	{ id = "galeblade_glaive", name = "Galeblade Glaive", family = "glaive", grade = 3, element = "wind", c = { rgb(214, 230, 226), rgb(36, 56, 50), SILVER, WIND }, p = { len = 6 }, desc = "Its blade is thin as paper and stronger than the shaft it rides." },
	{ id = "frostmoon_glaive", name = "Frostmoon Glaive", family = "glaive", grade = 4, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { len = 6.2, hook = true }, desc = "A crescent of blue ice on a pole of white ash." },
	{ id = "solar_glaive", name = "Solar Glaive", family = "glaive", grade = 5, element = "holy", c = { rgb(250, 240, 214), rgb(80, 60, 40), GOLD, HOLY }, p = { len = 6.4, hook = true, gem = true }, desc = "It warms the hands of everyone standing behind it." },
	{ id = "voidmoon_glaive", name = "Voidmoon Glaive", family = "glaive", grade = 6, element = "void", c = { rgb(80, 66, 120), OBSIDIAN, VIOLET, VOID }, p = { len = 6.8, hook = true, gem = true }, desc = "The edge is darker than the blade. Light goes missing near it." },
	{ id = "breach_lance", name = "Breach Lance", family = "lance", grade = 2, element = "none", price = 7, c = { STEEL, WOOD, BRASS, MANA }, p = { len = 6.2 }, desc = "Built to punch through a dungeon door, and whatever waits behind it." },
	{ id = "ironhorn_lance", name = "Ironhorn Lance", family = "lance", grade = 3, element = "earth", c = { rgb(150, 140, 128), LEATHER, BRONZE, EARTH }, p = { len = 6.4 }, desc = "Tipped with an armoured beetle's horn. It doesn't chip." },
	{ id = "thunder_lance", name = "Thundercharge Lance", family = "lance", grade = 4, element = "lightning", c = { rgb(220, 226, 240), NAVY, GOLD, BOLT }, p = { len = 6.8 }, desc = "It hits twice: once with the point, once with the thunder." },
	{ id = "dawnbreaker", name = "Dawnbreaker Lance", family = "lance", grade = 6, element = "holy", c = { rgb(246, 242, 230), rgb(60, 50, 80), GOLD, HOLY }, p = { len = 7.4, gem = true }, desc = "Raised at sunrise over a cleared S-rank Gate. It has caught the light ever since." },

	-- ══ ASSASSIN ═════════════════════════════════════════════════════════════
	-- daggers
	{ id = "steel_dagger", name = "Hunter's Steel Dagger", family = "dagger", grade = 1, element = "none", price = 2, c = { STEEL, DARK, BRASS, MANA }, p = { len = 1.0 }, desc = "Licensed-Hunters-only steel. Enough for an E-rank Gate." },
	{ id = "goblin_fang", name = "Goblin-Fang Knife", family = "dagger", grade = 1, element = "none", price = 2, c = { BONE, WOOD, rgb(110, 90, 60), rgb(200, 255, 120) }, p = { len = 0.9, curve = 0.3 }, desc = "A goblin's tooth set in a wooden grip. Uglier than it is sharp." },
	{ id = "twin_stilettos", name = "Twin Fang Stilettos", family = "daggers", grade = 2, element = "none", price = 6, c = { STEEL, DARK, rgb(150, 30, 40), rgb(255, 80, 80) }, p = { len = 1.1 }, desc = "Thin, quick, and made to be used together." },
	{ id = "spider_kris", name = "Venom Spider Kris", family = "dagger", grade = 3, element = "venom", price = 14, c = { rgb(60, 70, 60), DARK, VENOM, VENOM }, p = { len = 1.2, wave = true }, desc = "The wavy blade holds a C-rank spider's venom gland in the guard." },
	{ id = "shadowglass", name = "Shadowglass Dirks", family = "daggers", grade = 5, element = "void", c = { rgb(30, 30, 46), DARK, VOID, VOID }, p = { len = 1.3 }, desc = "Black glass from an A-rank Gate. They make no sound at all." },
	{ id = "fang_of_the_deep", name = "Fang of the Deep Gate", family = "dagger", grade = 6, element = "void", c = { rgb(240, 240, 255), DARK, GOLD, rgb(255, 60, 90) }, p = { len = 1.5, curve = 0.4 }, desc = "A tooth from something an S-rank raid barely survived." },
	-- rapiers
	{ id = "duelist_rapier", name = "Duelist's Rapier", family = "rapier", grade = 3, element = "none", price = 15, c = { STEEL, DARK, GOLD, MANA }, p = { len = 3.6 }, desc = "For Hunters who'd rather not be hit at all." },
	{ id = "naga_needle", name = "Needle of the Naga", family = "rapier", grade = 4, element = "venom", c = { rgb(140, 220, 200), rgb(20, 60, 60), rgb(80, 200, 180), rgb(80, 255, 220) }, p = { len = 3.8 }, desc = "A naga's spine, straightened and sharpened." },
	{ id = "whisperwind_rapier", name = "Whisperwind Rapier", family = "rapier", grade = 5, element = "wind", c = { rgb(214, 232, 226), SEA, SILVER, WIND }, p = { len = 4 }, desc = "It moves before the wrist does." },
	{ id = "starneedle", name = "Starneedle", family = "rapier", grade = 6, element = "holy", c = { rgb(245, 245, 255), rgb(40, 40, 70), GOLD, HOLY }, p = { len = 4.2 }, desc = "Thin as a ray of light, and about as easy to dodge." },
	-- sai
	{ id = "practice_sai", name = "Practice Sai", family = "sai", grade = 1, element = "none", price = 2, c = { IRON, LEATHER, STEEL, MANA }, p = { len = 1.5 }, desc = "Blunt prongs for catching blades. A goblin's knife counts." },
	{ id = "iron_sai", name = "Iron Sai", family = "sai", grade = 2, element = "none", price = 6, c = { STEEL, DARK, BRASS, MANA }, p = { len = 1.7 }, desc = "Heavier than they look, faster than they should be." },
	{ id = "viper_sai", name = "Viper Sai", family = "sai", grade = 3, element = "venom", c = { rgb(80, 110, 80), DARK, JADE, VENOM }, p = { len = 1.8 }, desc = "The prongs are grooved, and the grooves are never quite dry." },
	{ id = "moonless_sai", name = "Moonless Sai", family = "sai", grade = 5, element = "void", c = { OBSIDIAN, DARK, rgb(160, 130, 230), VOID }, p = { len = 2, gem = true }, desc = "On a dark night you can't see them at all. Neither can anything else." },
	{ id = "stormprong_sai", name = "Stormprong Sai", family = "sai", grade = 6, element = "lightning", c = { rgb(220, 226, 240), NAVY, GOLD, BOLT }, p = { len = 2.1, gem = true }, desc = "Sparks jump between the prongs when they're held apart." },
	-- katars and claws
	{ id = "punch_katars", name = "Punch-Blade Katars", family = "katar", grade = 1, element = "none", price = 2, c = { STEEL, LEATHER, IRON, MANA }, p = { len = 1.1 }, desc = "A blade on a fist grip. Simple, close, quick." },
	{ id = "wolf_katars", name = "Wolf-Fang Katars", family = "katar", grade = 2, element = "none", price = 6, c = { BONE, LEATHER, BRASS, MANA }, p = { len = 1.2, notched = true }, desc = "Dire-wolf fangs set into steel frames." },
	{ id = "frosttooth_katars", name = "Frost-Tooth Katars", family = "katar", grade = 3, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { len = 1.3 }, desc = "The cuts they make sting with cold long after." },
	{ id = "silent_moon_katars", name = "Silent Moon Katars", family = "katar", grade = 5, element = "void", c = { rgb(50, 46, 70), OBSIDIAN, rgb(170, 140, 240), VOID }, p = { len = 1.5, gem = true }, desc = "Their owner never says a word in a raid. Neither do they." },
	{ id = "thunderclaw", name = "Thunderclaw Katars", family = "katar", grade = 6, element = "lightning", c = { rgb(230, 232, 245), NAVY, GOLD, BOLT }, p = { len = 1.6, gem = true }, desc = "The punch arrives a moment after the thunder does." },
	{ id = "bear_claws", name = "Bear-Claw Gauntlets", family = "claws", grade = 4, element = "frost", c = { rgb(230, 236, 240), rgb(60, 70, 80), rgb(200, 220, 240), FROST }, p = {}, desc = "An ice bear's claws, set on steel. Still cold." },
	-- whips and chains
	{ id = "hunting_whip", name = "Leather Hunting Whip", family = "whip", grade = 2, element = "none", price = 6, c = { LEATHER, DARK, BRASS, MANA }, p = { len = 5 }, desc = "Twelve feet of braided hide. The crack alone scatters giant rats." },
	{ id = "linked_chain_whip", name = "Linked Chain Whip", family = "whip", grade = 3, element = "none", c = { STEEL, DARK, SILVER, MANA }, p = { len = 5.5, chain = true }, desc = "Steel links with a blade at the end. It folds into a pocket." },
	{ id = "thornlash", name = "Thornlash", family = "whip", grade = 4, element = "venom", c = { rgb(70, 100, 60), DARK, JADE, VENOM }, p = { len = 5.8, thorns = true }, desc = "A vine from a B-rank jungle Gate, cured and braided. It still grows thorns." },
	{ id = "emberlash", name = "Emberlash", family = "whip", grade = 5, element = "fire", c = { rgb(120, 40, 30), DARK, GOLD, EMBER }, p = { len = 6.2, chain = true }, desc = "It writes lines of fire in the air and leaves them there a moment." },
	{ id = "voidcoil", name = "Voidcoil Whip", family = "whip", grade = 6, element = "void", c = { rgb(78, 64, 120), DARK, VIOLET, VOID }, p = { len = 6.6, chain = true, gem = true }, desc = "It is longer than it should be, and nobody can measure by how much." },
	{ id = "chain_blade", name = "Chain-Blade", family = "chainblade", grade = 4, element = "none", c = { STEEL, DARK, rgb(160, 160, 170), MANA }, p = { len = 2.4 }, desc = "A blade on a chain. It goes where you throw it and comes back." },
	{ id = "kusarigama", name = "Shadow Kusarigama", family = "kusarigama", grade = 4, element = "void", c = { rgb(60, 60, 70), DARK, rgb(120, 120, 130), VOID }, p = {}, desc = "A sickle, a chain, and a weight. Each one is a weapon." },

	-- ══ RANGER ═══════════════════════════════════════════════════════════════
	-- bows
	{ id = "hunting_bow", name = "Hunting Bow", family = "bow", grade = 1, element = "none", price = 3, c = { WOOD, DARK, STEEL, MANA }, p = { len = 3.6 }, desc = "A sporting bow, restrung for monsters." },
	{ id = "composite_bow", name = "Composite Bow", family = "bow", grade = 3, element = "none", price = 14, c = { rgb(70, 60, 50), DARK, BRASS, MANA }, p = { len = 4 }, desc = "Horn, sinew and wood. It throws an arrow very far." },
	{ id = "frostfeather_bow", name = "Frostfeather Bow", family = "bow", grade = 4, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { len = 4.2 }, desc = "Fletched with feathers from a bird that only lives in snow Gates." },
	{ id = "wyvern_longbow", name = "Wyvern-Sinew Longbow", family = "bow", grade = 5, element = "venom", c = { rgb(80, 110, 80), DARK, GOLD, VENOM }, p = { len = 4.6 }, desc = "Strung with a wyvern's tendon. Only an A-rank can draw it." },
	{ id = "skypiercer", name = "Skypiercer", family = "bow", grade = 6, element = "wind", c = { rgb(230, 236, 255), rgb(30, 40, 70), GOLD, rgb(160, 220, 255) }, p = { len = 5 }, desc = "Its arrows don't come down." },
	{ id = "yew_longbow", name = "Yew Longbow", family = "longbow", grade = 1, element = "none", price = 3, c = { rgb(150, 100, 60), LEATHER, STEEL, MANA }, p = { len = 5 }, desc = "Taller than its archer. Patient, the way its archer has to be." },
	{ id = "sentry_longbow", name = "Sentry Longbow", family = "longbow", grade = 2, element = "none", price = 7, c = { rgb(70, 60, 52), DARK, BRASS, MANA }, p = { len = 5.2 }, desc = "Issued to the Gate watch on the rooftops. It reaches the far end of a street." },
	{ id = "galestring", name = "Galestring Longbow", family = "longbow", grade = 4, element = "wind", c = { rgb(200, 220, 210), SEA, SILVER, WIND }, p = { len = 5.4 }, desc = "The wind changes direction to help its arrows along." },
	{ id = "sunfire_longbow", name = "Sunfire Longbow", family = "longbow", grade = 5, element = "fire", c = { rgb(150, 60, 30), DARK, GOLD, EMBER }, p = { len = 5.6, gem = true }, desc = "Each arrow catches fire the moment it leaves the string." },
	{ id = "aurora_longbow", name = "Aurora Longbow", family = "longbow", grade = 6, element = "frost", c = { rgb(220, 240, 255), NAVY, SILVER, FROST }, p = { len = 6, gem = true }, desc = "Its arrows trail coloured light across the sky like a winter night." },
	-- crossbows
	{ id = "hand_crossbow", name = "Hand Crossbow", family = "crossbow", grade = 2, element = "none", price = 6, c = { IRON, WOOD, BRASS, MANA }, p = { small = true }, desc = "Fits in a coat pocket. Fits a bolt into a goblin's knee." },
	{ id = "repeater", name = "Repeating Crossbow", family = "crossbow", grade = 3, element = "none", price = 13, c = { rgb(90, 90, 96), WOOD, BRASS, MANA }, p = { len = 2 }, desc = "Six bolts in four seconds. Reloading takes longer." },
	{ id = "venom_repeater", name = "Venom Repeater", family = "crossbow", grade = 4, element = "venom", c = { rgb(70, 90, 64), DARK, JADE, VENOM }, p = {}, desc = "Six bolts, six stings." },
	{ id = "windlass_arbalest", name = "Windlass Arbalest", family = "arbalest", grade = 2, element = "none", price = 8, c = { IRON, WOOD, BRASS, MANA }, p = {}, desc = "Slow to wind, quick to end an argument." },
	{ id = "siege_arbalest", name = "Siege Arbalest", family = "arbalest", grade = 3, element = "earth", c = { STONE, rgb(70, 50, 36), BRONZE, EARTH }, p = { big = true }, desc = "Built to pin a cave troll to the wall it came through." },
	{ id = "frostbolt_arbalest", name = "Frostbolt Arbalest", family = "arbalest", grade = 4, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = {}, desc = "Its bolts freeze the air they pass through." },
	{ id = "thunder_arbalest", name = "Thunder Arbalest", family = "arbalest", grade = 5, element = "lightning", c = { rgb(200, 206, 220), OBSIDIAN, GOLD, BOLT }, p = { big = true, gem = true }, desc = "The bolt and the thunderclap arrive together." },
	{ id = "eclipse_arbalest", name = "Eclipse Arbalest", family = "arbalest", grade = 6, element = "void", c = { OBSIDIAN, DARK, VIOLET, VOID }, p = { big = true, gem = true }, desc = "Every shot dims the room a little." },
	-- thrown
	{ id = "practice_javelins", name = "Practice Javelins", family = "javelin", grade = 1, element = "none", price = 2, c = { STEEL, WOOD, IRON, MANA }, p = { len = 4 }, desc = "Three light javelins and a strong shoulder." },
	{ id = "barbed_javelins", name = "Hooked Javelins", family = "javelin", grade = 2, element = "none", price = 6, c = { STEEL, rgb(70, 50, 36), BRASS, MANA }, p = { len = 4.2 }, desc = "Easy to throw, hard to pull back out of a hobgoblin's shield." },
	{ id = "hornet_javelins", name = "Hornet Javelins", family = "javelin", grade = 3, element = "venom", c = { rgb(220, 200, 80), DARK, JADE, VENOM }, p = { len = 4.4 }, desc = "Yellow and black, with a sting like their namesake." },
	{ id = "thunderbolt_javelins", name = "Thunderbolt Javelins", family = "javelin", grade = 4, element = "lightning", c = { rgb(225, 230, 245), NAVY, GOLD, BOLT }, p = { len = 4.6 }, desc = "Thrown up, they come down as lightning." },
	{ id = "windrunner_javelins", name = "Windrunner Javelins", family = "javelin", grade = 5, element = "wind", c = { rgb(210, 232, 226), SEA, SILVER, WIND }, p = { len = 4.8, gem = true }, desc = "They curve around a corner if you ask nicely." },
	{ id = "throwing_knife_belt", name = "Throwing Knife Belt", family = "kunai", grade = 1, element = "none", price = 2, c = { STEEL, LEATHER, IRON, MANA }, p = {}, desc = "Six balanced knives on a strap. Five, usually." },
	{ id = "kunai_bandolier", name = "Kunai Bandolier", family = "kunai", grade = 2, element = "none", price = 6, c = { rgb(60, 62, 70), DARK, STEEL, MANA }, p = {}, desc = "Black steel, ring pommels, a strap across the chest." },
	{ id = "ember_kunai", name = "Ember Kunai", family = "kunai", grade = 3, element = "fire", c = { rgb(120, 60, 40), DARK, BRASS, EMBER }, p = {}, desc = "Each one leaves a thread of smoke in the air." },
	{ id = "shade_kunai", name = "Shade Kunai", family = "kunai", grade = 4, element = "void", c = { OBSIDIAN, DARK, rgb(150, 120, 220), VOID }, p = {}, desc = "They come back to the belt by themselves. Nobody knows how." },
	{ id = "galeforce_kunai", name = "Galeforce Kunai", family = "kunai", grade = 6, element = "wind", c = { rgb(220, 236, 230), SEA, GOLD, WIND }, p = { gem = true }, desc = "Thrown in a fan of six, they arrive as one." },
	{ id = "chakrams", name = "Moonring Chakrams", family = "chakram", grade = 3, element = "none", c = { rgb(220, 226, 240), DARK, GOLD, rgb(200, 220, 255) }, p = { size = 1.1 }, desc = "Two rings of sharpened silver." },
	{ id = "sunwheel_chakrams", name = "Sunwheel Chakrams", family = "chakram", grade = 5, element = "holy", c = { rgb(255, 236, 190), DARK, GOLD, HOLY }, p = { size = 1.25, rays = true }, desc = "They throw light as they spin." },

	-- ══ MAGE ═════════════════════════════════════════════════════════════════
	-- staves and wands
	{ id = "apprentice_wand", name = "Apprentice's Wand", family = "wand", grade = 1, element = "none", price = 3, c = { WOOD, DARK, BRASS, MANA }, p = { len = 1.6 }, desc = "A crystal sliver in carved wood. Every Mage's first." },
	{ id = "spark_wand", name = "Spark Wand", family = "wand", grade = 1, element = "lightning", price = 3, c = { rgb(120, 100, 70), DARK, BRASS, BOLT }, p = { len = 1.5 }, desc = "It sparks when you're nervous. You'll be nervous." },
	{ id = "thunderwood_wand", name = "Thunderwood Wand", family = "wand", grade = 3, element = "lightning", c = { rgb(70, 60, 50), DARK, GOLD, BOLT }, p = { len = 1.8 }, desc = "Cut from a tree that lightning struck nine times." },
	{ id = "mana_staff", name = "Mana-Conductive Staff", family = "staff", grade = 3, element = "none", price = 16, c = { WOOD, DARK, BRASS, MANA }, p = { len = 5 }, desc = "A crystal core in carved wood. It hums under the hand." },
	{ id = "frostfire_staff", name = "Frostfire Staff", family = "staff", grade = 4, element = "frost", c = { rgb(60, 60, 80), DARK, rgb(220, 230, 255), rgb(255, 140, 220) }, p = { len = 5.2, prongs = true }, desc = "Hot and cold at once. Nobody can explain it, including the smith." },
	{ id = "sage_staff", name = "Sage's Crystal Staff", family = "staff", grade = 5, element = "frost", c = { rgb(230, 230, 240), rgb(40, 40, 60), GOLD, rgb(150, 230, 255) }, p = { len = 5.4, rings = true }, desc = "Three rings of crystal turn around the head." },
	{ id = "deep_gate_staff", name = "Staff of the Deep Gate", family = "staff", grade = 6, element = "void", c = { rgb(20, 20, 40), DARK, GOLD, VOID }, p = { len = 5.8, rings = true, prongs = true }, desc = "Looking at the orb too long makes you feel like you're falling." },
	-- foci
	{ id = "focus_orb", name = "Focus Orb", family = "orb", grade = 2, element = "none", price = 8, c = { rgb(150, 200, 255), DARK, BRASS, MANA }, p = { size = 0.8 }, desc = "A floating sphere of polished crystal." },
	{ id = "cracked_crystal", name = "Cracked Mana Crystal", family = "crystal", grade = 1, element = "none", price = 3, c = { rgb(170, 210, 255), DARK, BRASS, MANA }, p = { size = 0.7 }, desc = "An E-rank core with a crack in it. Still works, mostly." },
	{ id = "caged_ember", name = "Caged Ember Crystal", family = "crystal", grade = 3, element = "fire", c = { rgb(255, 170, 120), DARK, BRASS, FIRE }, p = { size = 0.85 }, desc = "A fire core in an iron cage. Keep it away from paper." },
	{ id = "stormglass", name = "Stormglass Focus", family = "crystal", grade = 4, element = "lightning", c = { rgb(255, 246, 190), NAVY, SILVER, BOLT }, p = { size = 0.9 }, desc = "A storm in a glass ball. It rattles the cage when it's restless." },
	{ id = "rimeheart", name = "Rimeheart Focus", family = "crystal", grade = 5, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { size = 1, rings = true }, desc = "A core that beats once a minute and frosts the air each time." },
	{ id = "abyss_lens", name = "Abyss Lens", family = "crystal", grade = 6, element = "void", c = { rgb(60, 40, 100), OBSIDIAN, GOLD, VOID }, p = { size = 1.1, rings = true }, desc = "Look into it and something looks back, politely." },
	-- books and tablets
	{ id = "field_spellbook", name = "Field Spellbook", family = "codex", grade = 2, element = "none", price = 8, c = { rgb(60, 70, 110), DARK, BRASS, MANA }, p = { size = 0.9 }, desc = "Dog-eared, annotated, coffee-stained. It floats when it's open." },
	{ id = "book_of_gales", name = "Book of Gales", family = "codex", grade = 3, element = "wind", c = { rgb(60, 110, 90), DARK, SILVER, WIND }, p = { size = 1 }, desc = "Its pages turn themselves, and a breeze comes off every one." },
	{ id = "ember_grimoire", name = "Grimoire of Embers", family = "tome", grade = 4, element = "fire", c = { rgb(120, 40, 30), DARK, GOLD, FIRE }, p = { size = 1 }, desc = "The pages are warm. Some of them are burning, slowly, forever." },
	{ id = "void_codex", name = "Void Codex", family = "tome", grade = 5, element = "void", c = { rgb(30, 20, 50), DARK, rgb(150, 100, 230), VOID }, p = { size = 1.1 }, desc = "Recovered from a Double Dungeon. The Association wants it back." },
	{ id = "codex_of_thunders", name = "Codex of Thunders", family = "codex", grade = 5, element = "lightning", c = { rgb(40, 50, 90), DARK, GOLD, BOLT }, p = { size = 1.1 }, desc = "Reading it aloud is not recommended indoors." },
	{ id = "last_page", name = "The Last Page", family = "codex", grade = 6, element = "holy", c = { rgb(240, 232, 210), rgb(60, 50, 40), GOLD, HOLY }, p = { size = 1.2 }, desc = "Whatever is written on its last page comes true. The page is blank. Everyone is relieved." },
	{ id = "clay_tablet", name = "Clay Rune Tablet", family = "tablet", grade = 1, element = "earth", price = 3, c = { rgb(170, 120, 80), DARK, BRONZE, EARTH }, p = {}, desc = "Five runes pressed into clay. A beginner's whole library." },
	{ id = "slate_tablet", name = "Slate Rune Tablet", family = "tablet", grade = 2, element = "none", price = 7, c = { rgb(80, 86, 96), DARK, SILVER, MANA }, p = {}, desc = "Cut from the floor of an E-rank Gate, runes and all." },
	{ id = "frost_tablet", name = "Frost Rune Tablet", family = "tablet", grade = 4, element = "frost", c = { rgb(180, 210, 230), NAVY, SILVER, FROST }, p = { big = true }, desc = "The runes are carved into ice that has never melted." },
	{ id = "furnace_tablet", name = "Furnace Rune Tablet", family = "tablet", grade = 5, element = "fire", c = { rgb(90, 50, 40), DARK, GOLD, EMBER }, p = { big = true }, desc = "Hot enough to cook on. Please don't." },
	{ id = "deep_rune_tablet", name = "Tablet of the Deep Runes", family = "tablet", grade = 6, element = "void", c = { rgb(30, 26, 46), DARK, GOLD, VOID }, p = { big = true, gem = true }, desc = "Nobody can read it. Everyone who tries dreams the same dream." },
	-- war fans
	{ id = "paper_warfan", name = "Paper War Fan", family = "warfan", grade = 2, element = "wind", price = 7, c = { rgb(240, 232, 214), WOOD, CRIMSON, WIND }, p = { size = 1.2 }, desc = "Paper and bamboo, folded with a little mana. It shouldn't be this sharp." },
	{ id = "ironrib_fan", name = "Iron-Ribbed War Fan", family = "warfan", grade = 3, element = "wind", c = { rgb(200, 206, 214), DARK, STEEL, WIND }, p = { size = 1.3, tips = true }, desc = "Steel ribs and silk. Close it to block, open it to cut." },
	{ id = "peacock_fan", name = "Flame Peacock Fan", family = "warfan", grade = 4, element = "fire", c = { rgb(255, 150, 90), CRIMSON, GOLD, EMBER }, p = { size = 1.4, gem = true, tips = true }, desc = "Every rib ends in a feather of fire." },
	{ id = "frost_lotus_fan", name = "Frost Lotus Fan", family = "warfan", grade = 5, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { size = 1.5, gem = true }, desc = "Open, it is a lotus of ice. Closed, it is a club of ice." },
	{ id = "ninth_wind_fan", name = "Fan of the Ninth Wind", family = "warfan", grade = 6, element = "wind", c = { rgb(230, 246, 240), rgb(40, 60, 56), GOLD, WIND }, p = { size = 1.6, gem = true, tips = true }, desc = "There are eight winds. This fan makes the ninth." },

	-- ══ HEALER ═══════════════════════════════════════════════════════════════
	-- lanterns and thuribles
	{ id = "field_lantern", name = "Field Lantern", family = "censer", grade = 1, element = "holy", price = 2, c = { rgb(200, 200, 190), DARK, BRASS, HOLY }, p = {}, desc = "A battery lantern with a crystal in it. The light feels kind." },
	{ id = "mercy_lantern", name = "Lantern of Mercy", family = "censer", grade = 3, element = "holy", price = 14, c = { rgb(230, 220, 190), DARK, GOLD, rgb(255, 240, 180) }, p = {}, desc = "Its light makes wounds close a little faster." },
	{ id = "stormlight_lantern", name = "Stormlight Lantern", family = "censer", grade = 4, element = "lightning", c = { rgb(220, 226, 240), NAVY, GOLD, BOLT }, p = {}, desc = "Lightning in a jar, tamed to a steady glow." },
	{ id = "long_night_lantern", name = "Lantern of the Long Night", family = "censer", grade = 6, element = "holy", c = { rgb(240, 232, 210), OBSIDIAN, GOLD, HOLY }, p = { big = true }, desc = "Carried through a night that lasted three days. It did not dim once." },
	{ id = "tin_thurible", name = "Tin Thurible", family = "thurible", grade = 1, element = "none", price = 2, c = { rgb(170, 170, 176), DARK, STEEL, rgb(200, 230, 255) }, p = {}, desc = "Burns mana crystal dust. Smells like rain." },
	{ id = "cedar_thurible", name = "Cedar Thurible", family = "thurible", grade = 2, element = "earth", price = 6, c = { BRONZE, LEATHER, BRASS, EARTH }, p = {}, desc = "Cedar smoke and quiet. Patients sleep better near it." },
	{ id = "silver_thurible", name = "Silver Thurible", family = "thurible", grade = 3, element = "holy", c = { SILVER, DARK, GOLD, HOLY }, p = { gem = true }, desc = "Its smoke settles on a wound like a clean bandage." },
	{ id = "mistveil_thurible", name = "Mistveil Thurible", family = "thurible", grade = 4, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { gem = true }, desc = "A cool mist pours out and hides the wounded from what hurt them." },
	{ id = "thousand_mornings", name = "Thurible of a Thousand Mornings", family = "thurible", grade = 6, element = "holy", c = { rgb(255, 240, 200), rgb(60, 50, 40), GOLD, HOLY }, p = { gem = true, big = true }, desc = "It has been swung over more recoveries than anyone has counted." },
	-- bells
	{ id = "shrine_handbell", name = "Shrine Handbell", family = "bell", grade = 1, element = "holy", price = 2, c = { BRASS, WOOD, GOLD, HOLY }, p = { size = 0.9 }, desc = "Its ring calms a frightened crowd. Sometimes a frightened Hunter." },
	{ id = "mending_bell", name = "Brass Mending Bell", family = "bell", grade = 2, element = "holy", price = 6, c = { BRONZE, LEATHER, GOLD, HOLY }, p = { size = 1 }, desc = "Every chime knits a small wound shut." },
	{ id = "windchime_bell", name = "Windchime Bell", family = "bell", grade = 3, element = "wind", c = { SILVER, rgb(40, 60, 56), JADE, WIND }, p = { size = 1, chimes = true }, desc = "It rings in a wind nobody else can feel, and breathing gets easier." },
	{ id = "frostglass_bell", name = "Frostglass Bell", family = "bell", grade = 4, element = "frost", c = { ICE, NAVY, SILVER, FROST }, p = { size = 1.1, chimes = true }, desc = "Its cold note numbs pain the way snow does." },
	{ id = "clear_morning_bell", name = "Bell of Clear Morning", family = "bell", grade = 5, element = "holy", c = { rgb(250, 240, 210), rgb(60, 50, 80), GOLD, HOLY }, p = { size = 1.2, chimes = true, gem = true }, desc = "Rung once at the end of a raid, it clears the fear out of a room." },
	{ id = "dawnsong_bell", name = "Dawnsong Bell", family = "bell", grade = 6, element = "holy", c = { rgb(255, 236, 180), rgb(70, 50, 40), GOLD, HOLY }, p = { size = 1.3, chimes = true, gem = true }, desc = "When it rings, wounded Hunters sit up to see where the sunrise is." },
	-- rods, scepters, crescents
	{ id = "willow_rod", name = "Willow Rod", family = "rod", grade = 2, element = "wind", price = 6, c = { rgb(150, 130, 90), LEATHER, SILVER, WIND }, p = { len = 4.2 }, desc = "Bends in the wind and never breaks. Healers like that in a rod." },
	{ id = "sanctum_rod", name = "Sanctum Rod", family = "rod", grade = 5, element = "holy", c = { rgb(240, 240, 250), rgb(60, 60, 80), GOLD, rgb(140, 255, 200) }, p = { len = 4.6, rings = true }, desc = "A Healer's rod, worn smooth by a thousand raids." },
	{ id = "medic_scepter", name = "Field Medic's Scepter", family = "scepter", grade = 1, element = "holy", price = 3, c = { SILVER, rgb(40, 60, 110), rgb(220, 60, 60), HOLY }, p = { len = 1.8 }, desc = "Half baton, half focus. Every Healer's first." },
	{ id = "jade_scepter", name = "Jade Scepter", family = "scepter", grade = 2, element = "earth", price = 7, c = { JADE, DARK, GOLD, rgb(140, 255, 180) }, p = { len = 1.9 }, desc = "Green stone that warms in the hand when someone nearby is hurt." },
	{ id = "sunstone_scepter", name = "Sunstone Scepter", family = "scepter", grade = 4, element = "fire", c = { rgb(255, 190, 120), rgb(80, 50, 30), GOLD, EMBER }, p = { len = 2.1, wings = true }, desc = "Its warmth gets cold hands moving again." },
	{ id = "stillwater_scepter", name = "Scepter of Still Water", family = "scepter", grade = 5, element = "frost", c = { rgb(190, 230, 245), NAVY, SILVER, FROST }, p = { len = 2.2, wings = true, gem = true }, desc = "Panic stops where its light reaches." },
	{ id = "dawn_scepter", name = "Scepter of Dawn", family = "scepter", grade = 6, element = "holy", c = { rgb(255, 246, 220), rgb(70, 50, 40), GOLD, HOLY }, p = { len = 2.4, wings = true, gem = true }, desc = "A sunrise on a stick, and every raid's favourite sight." },
	{ id = "pilgrim_crescent", name = "Pilgrim's Crescent Staff", family = "crescent", grade = 2, element = "holy", price = 7, c = { WOOD, LEATHER, SILVER, HOLY }, p = { len = 5 }, desc = "A walking staff with a silver moon on top. It has walked a long way." },
	{ id = "moonwell_staff", name = "Moonwell Staff", family = "crescent", grade = 3, element = "frost", c = { rgb(200, 220, 240), NAVY, SILVER, FROST }, p = { len = 5.2 }, desc = "Water gathers in the crescent's bowl, and it heals what it touches." },
	{ id = "verdant_crescent", name = "Verdant Crescent", family = "crescent", grade = 4, element = "earth", c = { rgb(110, 90, 60), rgb(40, 60, 30), JADE, rgb(150, 230, 120) }, p = { len = 5.4, vines = true }, desc = "Living wood. It puts out leaves in spring." },
	{ id = "halo_crescent", name = "Halo Crescent", family = "crescent", grade = 5, element = "holy", c = { rgb(250, 246, 230), rgb(60, 50, 80), GOLD, HOLY }, p = { len = 5.6, rings = true }, desc = "A ring of light hangs inside the crescent and does not fall." },
	{ id = "last_light", name = "Last Light Crescent", family = "crescent", grade = 6, element = "holy", c = { rgb(255, 250, 236), rgb(50, 40, 60), GOLD, HOLY }, p = { len = 6, rings = true, gem = true }, desc = "It was lit at the end of the worst raid anyone remembers, and never went out." },
}

Weapons.byId = {}
for _, w in Weapons.list do
	local fam = Weapons.FAMILIES[w.family]
	w.class = w.class or (fam and fam.class) or "fighter"
	w.element = w.element or "none"
	Weapons.byId[w.id] = w
end

-- a weapon's element and class (nil-safe: "none" / nil for something that isn't a weapon)
function Weapons.elementOf(base: string?): string
	local w = base and Weapons.byId[base]
	return if w then w.element else "none"
end
function Weapons.classOf(base: string?): string?
	local w = base and Weapons.byId[base]
	return if w then w.class else nil
end
-- an element's colour (Color3), or its deep/light shade
function Weapons.elementColor(element: string?, shade: string?): Color3
	local e = Weapons.ELEMENTS[element or "none"] or Weapons.ELEMENTS.none
	local t = (e :: any)[shade or "color"] or e.color
	return Color3.fromRGB(t[1], t[2], t[3])
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
					desc = w.desc .. " (" .. Weapons.GRADES[w.grade] .. "-grade " .. (if w.element ~= "none" then string.lower(Weapons.ELEMENTS[w.element].name) .. " " else "") .. string.lower(fam.name) .. ")",
					clash = clash,
					fight = if next(fight) then fight else nil,
					look = { kind = fam.kind, color = w.c[1] },
					weapon = { base = w.id, stars = st.stars, shiny = shiny, power = power, grade = w.grade, family = w.family, element = w.element, class = w.class },
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
