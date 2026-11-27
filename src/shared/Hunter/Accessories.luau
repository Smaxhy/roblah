--[[
	ACCESSORIES (BitLeveling, ORIGINAL items): rings, amulets, earrings, bracers, belts, brooches,
	circlets, mantles, charms, talismans, floating mana crystals, hip quivers, holy symbols...
	Fifteen or more for each Hunter class and a general set anyone can wear.

	Each accessory has a CLASS ("any" for the general set), a GRADE E..S, a SLOT on the body
	(where the R6 rig draws it: one per slot, Looks.MAX_ACCESSORIES at once) and a KIND (how
	it's drawn). Its power is a point budget set by the grade alone (BUDGET: E 2 .. S 14),
	spent on the things in its `mix`, most on the first:
		power   +1 base in the class's own stat in fights            1 point
		edge    +1 power per heads in the class's stat               3 points
		coins   +1 coin in fights                                     5 points
		heads   +2% heads                                             1 point
		guard   3% less damage taken                                  1 point
		growth  +1 of the class's stat a year                         2 points
		vigor   +2 Vitality a year                                    1 point
		calm    +1 Composure a year                                   1 point
		ward    bad years 4% less likely                              1 point
		charm   +1 base in Charisma (rallying)                         1 point
	so a higher grade is always worth more, and a class's accessory pays most to that class:
	its bonuses are in the stat the class fights with (Fighter Strength, Mage Intelligence,
	Assassin and Ranger Agility, Tanker Vitality, Healer Willpower).

	In the life sim an accessory is a "charm" gear item (Accessories.gearList, merged into the
	game's Gear list): bought with money, higher grades only for higher-ranked Hunters.

		Accessories.list               every accessory
		Accessories.find(id)           one (or nil)
		Accessories.ofClass(class)     a class's, by grade
		Accessories.points(a)          { kind = units } its budget, spent
		Accessories.score(a)           the points it's worth (= BUDGET[grade])
		Accessories.gearList()         the gear items for the engine
]]

local Accessories = {}

Accessories.GRADES = { "E", "D", "C", "B", "A", "S" }
Accessories.GRADE_OF = { E = 1, D = 2, C = 3, B = 4, A = 5, S = 6 }
Accessories.BUDGET = { 2, 3, 5, 7, 10, 14 }
Accessories.PRICE = { 3, 6, 14, 32, 75, 160 }
Accessories.RARITY = { "common", "common", "uncommon", "rare", "epic", "legendary" }
Accessories.COST = { power = 1, edge = 3, coins = 5, heads = 1, guard = 1, growth = 2, vigor = 1, calm = 1, ward = 1, charm = 1 }
Accessories.CLASSES = { "fighter", "mage", "assassin", "tanker", "ranger", "healer", "any" }
Accessories.CLASS_NAMES = { fighter = "Fighter", mage = "Mage", assassin = "Assassin", tanker = "Tanker", ranger = "Ranger", healer = "Healer", any = "Anyone" }
Accessories.CLASS_STAT = { fighter = "strength", mage = "intelligence", assassin = "agility", tanker = "vitality", ranger = "agility", healer = "willpower" }
Accessories.STAT_NAMES = { strength = "Strength", intelligence = "Intelligence", agility = "Agility", vitality = "Vitality", willpower = "Willpower" }
-- where on the body (one accessory per slot)
Accessories.SLOTS = {
	{ id = "head", name = "Brow" },
	{ id = "ear", name = "Ear" },
	{ id = "neck", name = "Neck" },
	{ id = "chest", name = "Chest" },
	{ id = "shoulder", name = "Shoulder" },
	{ id = "wrist", name = "Wrist" },
	{ id = "hand", name = "Hand" },
	{ id = "waist", name = "Waist" },
	{ id = "float", name = "Floating" },
}
-- the kinds the rig can draw, by slot
Accessories.KINDS = {
	head = { circlet = true },
	ear = { earring = true, stud = true, hoop = true, feather = true },
	neck = { amulet = true, fang = true, talisman = true, holy = true, token = true, coin = true, chain = true, key = true },
	chest = { brooch = true, badge = true, ribbon = true, leaf = true, sun = true, medal = true },
	shoulder = { spaulder = true, mantle = true, stole = true, fur = true, veil = true },
	wrist = { bracer = true, bracelet = true, beads = true, wrap = true },
	hand = { ring = true },
	waist = { belt = true, pouch = true, charm = true, tassel = true, book = true, quiver = true, knives = true, vial = true, censer = true, sash = true },
	float = { crystal = true, orbs = true, rune = true, blades = true, feather = true, orb = true },
}

-- colours
local STEEL, GOLD, SILVER, BONE = { 170, 176, 186 }, { 214, 180, 90 }, { 205, 210, 220 }, { 226, 216, 192 }
local LEATHER, WOOD, DARK, WHITE = { 100, 68, 44 }, { 120, 84, 52 }, { 34, 32, 38 }, { 240, 240, 236 }
local MANA, VIOLET, CRIMSON, VENOM = { 90, 170, 255 }, { 170, 110, 255 }, { 220, 50, 60 }, { 120, 230, 90 }
local EMBER, JADE, SKY, TEAL, GREEN = { 255, 140, 60 }, { 90, 190, 140 }, { 150, 210, 255 }, { 60, 200, 190 }, { 110, 220, 120 }

local list = {}
local function A(id: string, name: string, class: string, grade: string, slot: string, kind: string, c: { number }, g: { number }?, mix: { string }, desc: string)
	table.insert(list, { id = id, name = name, class = class, grade = grade, slot = slot, kind = kind, color = c, glow = g, mix = mix, desc = desc })
end

-- ── FIGHTER (Strength) ──
A("acc_iron_knuckle_ring", "Iron Knuckle Ring", "fighter", "E", "hand", "ring", STEEL, nil, { "power" }, "A heavy iron band. Makes a fist feel like a decision.")
A("acc_recruit_belt", "Recruit's Sword Belt", "fighter", "E", "waist", "belt", LEATHER, nil, { "power", "guard" }, "Thick leather, one brass buckle, a frog for a sword.")
A("acc_whetstone_charm", "Whetstone Charm", "fighter", "E", "waist", "charm", { 130, 130, 136 }, nil, { "power", "heads" }, "A pocket whetstone on a thong. Edges and nerves, kept sharp.")
A("acc_hobgoblin_fang", "Hobgoblin-Fang Necklace", "fighter", "D", "neck", "fang", BONE, nil, { "power", "edge" }, "Your first real kill, worn where you can see it.")
A("acc_brawler_bracer", "Brawler's Bracer", "fighter", "D", "wrist", "bracer", LEATHER, nil, { "power", "guard" }, "Laced tight over the forearm. Blocks what the blade misses.")
A("acc_red_tassel", "Red Sword Tassel", "fighter", "D", "waist", "tassel", CRIMSON, nil, { "heads", "power" }, "A silk tassel on the belt. Old raid parties say it brings clean cuts.")
A("acc_orc_tusk_amulet", "Orc-Tusk Amulet", "fighter", "C", "neck", "fang", BONE, CRIMSON, { "power", "edge" }, "A C-rank orc's tusk, bound in red cord. It still smells of the Gate.")
A("acc_war_spaulder", "War Spaulder", "fighter", "C", "shoulder", "spaulder", STEEL, nil, { "guard", "power" }, "One steel shoulder guard, the leading side. Fighters don't turn that shoulder away.")
A("acc_ember_bracelet", "Ember Bracelet", "fighter", "C", "wrist", "bracelet", EMBER, EMBER, { "power", "growth" }, "Fire-salamander scale beads that stay warm in winter.")
A("acc_champion_belt", "Champion's Belt", "fighter", "B", "waist", "belt", GOLD, nil, { "power", "edge", "guard" }, "Won in the guild's sparring hall. Nobody has taken it back yet.")
A("acc_blood_ruby_ring", "Blood-Ruby Ring", "fighter", "B", "hand", "ring", GOLD, CRIMSON, { "edge", "power" }, "A ruby grown in a red Gate. It brightens when you're hurt.")
A("acc_titan_grip", "Titan's Grip Bracers", "fighter", "A", "wrist", "bracer", GOLD, EMBER, { "power", "edge", "growth" }, "Forged from an A-rank giant's knuckle plates. Nothing slips from these hands.")
A("acc_warlord_brooch", "Warlord's Brooch", "fighter", "A", "chest", "brooch", GOLD, CRIMSON, { "edge", "coins", "power" }, "Pinned on the cloak of whoever leads the charge.")
A("acc_dragonheart", "Dragonheart Pendant", "fighter", "S", "neck", "amulet", GOLD, CRIMSON, { "power", "edge", "coins", "growth" }, "A sliver of a dragon's heart-crystal. It beats when you do.")
A("acc_gatebreaker_mantle", "Gatebreaker's Half-Mantle", "fighter", "S", "shoulder", "mantle", CRIMSON, GOLD, { "edge", "power", "guard" }, "Red cloth over one shoulder, worn by the one who walks into the break first.")

-- ── MAGE (Intelligence) ──
A("acc_apprentice_ring", "Apprentice's Focus Ring", "mage", "E", "hand", "ring", SILVER, MANA, { "power" }, "A chip of mana crystal set in silver. Every Mage's first focus.")
A("acc_chalk_pouch", "Rune-Chalk Pouch", "mage", "E", "waist", "pouch", { 70, 60, 110 }, nil, { "power", "calm" }, "Chalk for circles drawn in a hurry.")
A("acc_quartz_earring", "Quartz Earring", "mage", "E", "ear", "earring", SKY, MANA, { "power", "heads" }, "Clear quartz that hums faintly near a Gate.")
A("acc_floating_shard", "Floating Mana Shard", "mage", "D", "float", "crystal", MANA, MANA, { "power", "growth" }, "A shard that keeps by your shoulder, like a patient pet.")
A("acc_ink_bracelet", "Inkstone Bracelet", "mage", "D", "wrist", "beads", DARK, VIOLET, { "power", "calm" }, "Polished inkstone beads, each carved with a calming glyph.")
A("acc_star_chart", "Star-Chart Charm", "mage", "D", "waist", "charm", { 40, 50, 110 }, SKY, { "heads", "power" }, "A brass disc of the sky the night the first Gate opened.")
A("acc_sigil_circlet", "Sigil Circlet", "mage", "C", "head", "circlet", SILVER, VIOLET, { "power", "growth" }, "A thin silver band with one sigil at the brow. Thoughts go quiet and sharp.")
A("acc_frostglass_pendant", "Frostglass Pendant", "mage", "C", "neck", "amulet", SKY, SKY, { "power", "edge" }, "Ice from a frost-wyrm's lair that never melts.")
A("acc_pocket_grimoire", "Pocket Grimoire", "mage", "C", "waist", "book", { 90, 40, 60 }, VIOLET, { "growth", "power" }, "A palm-sized book of spells, chained to the belt.")
A("acc_twin_orbs", "Twin Orbiting Orbs", "mage", "B", "float", "orbs", MANA, MANA, { "power", "edge" }, "Two crystal spheres that circle you while you think.")
A("acc_sage_stole", "Sage's Stole", "mage", "B", "shoulder", "stole", { 60, 40, 120 }, GOLD, { "growth", "calm", "power" }, "Embroidered with the names of every Mage who wore it before.")
A("acc_archmage_seal", "Archmage's Seal Ring", "mage", "A", "hand", "ring", GOLD, VIOLET, { "edge", "power", "growth" }, "The seal of a circle of Mages that no longer meets.")
A("acc_void_prism", "Void Prism", "mage", "A", "float", "crystal", VIOLET, VIOLET, { "edge", "coins", "power" }, "A prism that splits mana instead of light.")
A("acc_starcore_amulet", "Starcore Amulet", "mage", "S", "neck", "amulet", WHITE, SKY, { "power", "edge", "growth", "coins" }, "A falling star's core, caught by an S-rank Mage and never given back.")
A("acc_ninth_circle", "Rune of the Ninth Circle", "mage", "S", "float", "rune", GOLD, VIOLET, { "edge", "power", "growth" }, "A rune that turns behind your head. Spells finish themselves.")

-- ── ASSASSIN (Agility) ──
A("acc_shadow_wrap", "Shadow Wrist-Wrap", "assassin", "E", "wrist", "wrap", DARK, nil, { "power" }, "Black cloth wound tight. Quieter hands.")
A("acc_smoke_pouch", "Smoke-Pellet Pouch", "assassin", "E", "waist", "pouch", DARK, nil, { "power", "ward" }, "Three pellets of grey smoke, for leaving.")
A("acc_black_stud", "Black Stud Earring", "assassin", "E", "ear", "stud", DARK, nil, { "heads" }, "Plain, black, forgettable. That's the point.")
A("acc_knife_belt", "Throwing-Knife Belt", "assassin", "D", "waist", "knives", STEEL, nil, { "power", "edge" }, "Five balanced knives along the belt, handles out.")
A("acc_venom_vial", "Venom-Vial Charm", "assassin", "D", "waist", "vial", VENOM, VENOM, { "edge", "power" }, "Spider venom in a glass vial. Don't drop it.")
A("acc_silent_ring", "Silent-Step Ring", "assassin", "D", "hand", "ring", DARK, VIOLET, { "power", "heads" }, "Your steps stop making a sound. Your heart doesn't.")
A("acc_night_moth", "Night-Moth Brooch", "assassin", "C", "chest", "brooch", DARK, VIOLET, { "heads", "power" }, "A moth of black enamel with violet eyes.")
A("acc_hidden_blade", "Hidden-Blade Bracer", "assassin", "C", "wrist", "bracer", DARK, nil, { "edge", "power" }, "A spring blade under the forearm guard.")
A("acc_crow_talisman", "Crow-Feather Talisman", "assassin", "C", "neck", "talisman", DARK, nil, { "power", "heads" }, "A paper talisman wrapped round a crow's feather.")
A("acc_phantom_veil", "Phantom Shoulder-Veil", "assassin", "B", "shoulder", "veil", { 50, 30, 80 }, VIOLET, { "coins", "power" }, "Gauze that blurs your outline when you move.")
A("acc_venom_fang_ring", "Venom-Fang Ring", "assassin", "B", "hand", "ring", SILVER, VENOM, { "edge", "power" }, "A hollow fang on the knuckle. One scratch is enough.")
A("acc_eclipse_earring", "Eclipse Earring", "assassin", "A", "ear", "hoop", DARK, VIOLET, { "coins", "power", "heads" }, "A black hoop ringed in violet light.")
A("acc_shadow_sash", "Sash of Long Shadows", "assassin", "A", "waist", "sash", { 40, 24, 60 }, VIOLET, { "power", "edge", "growth" }, "It moves a moment after you do.")
A("acc_nightfall_eye", "Nightfall Eye Pendant", "assassin", "S", "neck", "amulet", DARK, VIOLET, { "coins", "edge", "power" }, "An eye of violet glass that never closes.")
A("acc_void_blades", "Orbiting Void Blades", "assassin", "S", "float", "blades", DARK, VIOLET, { "coins", "edge", "power", "heads" }, "Two shadow-blades that keep at your back until called.")

-- ── TANKER (Vitality, and less damage) ──
A("acc_iron_band", "Iron Arm Band", "tanker", "E", "wrist", "bracer", STEEL, nil, { "guard" }, "A plain iron cuff. It's stopped a goblin's teeth.")
A("acc_steel_buckle", "Heavy Steel Buckle", "tanker", "E", "waist", "belt", STEEL, nil, { "guard", "power" }, "A belt built to hold up armour, not trousers.")
A("acc_oak_charm", "Oak-Heart Charm", "tanker", "E", "neck", "token", WOOD, nil, { "vigor", "guard" }, "A disc of old oak. Stubborn wood for a stubborn body.")
A("acc_rivet_ring", "Riveted Ring", "tanker", "D", "hand", "ring", STEEL, nil, { "power", "guard" }, "Hammered from an armour rivet.")
A("acc_shield_pin", "Shield-Wall Pin", "tanker", "D", "chest", "badge", STEEL, MANA, { "guard", "power" }, "Given to everyone who held the line in their first break.")
A("acc_stone_skin", "Stone-Skin Talisman", "tanker", "D", "neck", "talisman", { 140, 140, 136 }, nil, { "guard", "vigor" }, "A grey talisman that makes the skin feel like slate.")
A("acc_golem_core", "Golem-Core Amulet", "tanker", "C", "neck", "amulet", { 120, 116, 110 }, EMBER, { "guard", "power", "vigor" }, "A golem's core, still faintly warm.")
A("acc_bastion_spaulder", "Bastion Spaulder", "tanker", "C", "shoulder", "spaulder", STEEL, nil, { "guard" }, "A huge plate for the shield side.")
A("acc_iron_will_girdle", "Iron-Will Girdle", "tanker", "C", "waist", "belt", { 90, 94, 100 }, nil, { "guard", "calm" }, "Wide, heavy and reassuring.")
A("acc_bulwark_bracers", "Bulwark Bracers", "tanker", "B", "wrist", "bracer", { 120, 124, 132 }, MANA, { "guard", "power", "edge" }, "Thick enough to block with. Tankers do.")
A("acc_mountain_ring", "Mountain-Root Ring", "tanker", "B", "hand", "ring", { 110, 90, 60 }, GREEN, { "vigor", "guard", "growth" }, "Stone and root from the deepest Gate anyone mapped.")
A("acc_aegis_brooch", "Aegis Brooch", "tanker", "A", "chest", "brooch", GOLD, MANA, { "guard", "power", "edge" }, "A shield-shaped brooch that throws a thin barrier when struck.")
A("acc_titanhide_mantle", "Titanhide Mantle", "tanker", "A", "shoulder", "fur", { 120, 100, 80 }, nil, { "guard", "vigor" }, "The hide of something enormous, worn over the shoulders.")
A("acc_unbroken_heart", "Heart of the Unbroken", "tanker", "S", "neck", "amulet", GOLD, EMBER, { "guard", "power", "edge", "vigor" }, "The crystal of a Hunter who never fell. It refuses to let you, either.")
A("acc_fortress_sigil", "Fortress Sigil", "tanker", "S", "float", "rune", STEEL, MANA, { "guard", "edge", "power" }, "A floating shield-rune that turns toward every blow.")

-- ── RANGER (Agility, and aim) ──
A("acc_fletcher_kit", "Fletcher's Belt Kit", "ranger", "E", "waist", "pouch", LEATHER, nil, { "heads" }, "Spare points, feathers and twine.")
A("acc_wolf_tooth", "Wolf-Tooth Cord", "ranger", "E", "neck", "fang", BONE, nil, { "heads", "power" }, "One tooth of an E-rank direwolf.")
A("acc_thumb_ring", "Archer's Thumb Ring", "ranger", "E", "hand", "ring", BONE, nil, { "heads", "power" }, "A horn ring for a clean release.")
A("acc_hip_quiver", "Hip Quiver", "ranger", "D", "waist", "quiver", LEATHER, nil, { "power", "heads" }, "A short quiver at the hip, for the arrows you need now.")
A("acc_hawk_feather", "Hawk-Feather Earring", "ranger", "D", "ear", "feather", { 150, 110, 70 }, nil, { "heads" }, "A feather from a hawk that followed a raid party home.")
A("acc_trail_bracer", "Trail Bracer", "ranger", "D", "wrist", "bracer", LEATHER, nil, { "power", "ward" }, "Scuffed, oiled, and full of knife nicks.")
A("acc_eagle_eye", "Eagle-Eye Talisman", "ranger", "C", "neck", "talisman", GOLD, nil, { "heads", "edge" }, "An eye painted in gold on a strip of hide.")
A("acc_windleaf", "Windleaf Brooch", "ranger", "C", "chest", "leaf", GREEN, GREEN, { "heads", "power" }, "A leaf from a Gate forest, set in silver. It turns toward the wind.")
A("acc_hunter_stole", "Hunter's Fur Stole", "ranger", "C", "shoulder", "fur", { 150, 130, 100 }, nil, { "ward", "heads", "power" }, "Warm, light, and the colour of dry grass.")
A("acc_storm_quiver", "Stormfletch Quiver", "ranger", "B", "waist", "quiver", { 60, 70, 90 }, MANA, { "edge", "heads" }, "Arrows that crackle on the string.")
A("acc_moonbow_earring", "Moonbow Earring", "ranger", "B", "ear", "hoop", SILVER, SKY, { "coins", "heads" }, "A silver crescent. Shots at night fly true.")
A("acc_falcon_spirit", "Falcon Spirit", "ranger", "A", "float", "feather", GREEN, GREEN, { "heads", "edge", "power" }, "A spirit-falcon's feather that rides the air beside you, watching.")
A("acc_sylvan_bracers", "Sylvan Bracers", "ranger", "A", "wrist", "bracer", { 70, 110, 60 }, GREEN, { "power", "heads", "growth" }, "Living bark that grows a little tighter every year.")
A("acc_starfall_pendant", "Starfall Pendant", "ranger", "S", "neck", "amulet", GOLD, GREEN, { "heads", "edge", "coins" }, "It points at whatever you're aiming at.")
A("acc_greenwood_circlet", "Greenwood Circlet", "ranger", "S", "head", "circlet", { 90, 130, 70 }, GREEN, { "heads", "power", "edge", "growth" }, "A circlet of leaves that never wither.")

-- ── HEALER (Willpower, and keeping people alive) ──
A("acc_bandage_pouch", "Field Bandage Pouch", "healer", "E", "waist", "pouch", WHITE, nil, { "vigor" }, "Gauze, tape, and a Healer's patience.")
A("acc_prayer_beads", "Prayer-Bead Bracelet", "healer", "E", "wrist", "beads", WOOD, nil, { "calm", "vigor" }, "Wooden beads worn smooth by worried thumbs.")
A("acc_tin_symbol", "Tin Dawn Symbol", "healer", "E", "neck", "holy", SILVER, nil, { "power", "calm" }, "A little tin sun. Cheap, and it helps anyway.")
A("acc_herb_sachet", "Herb-Sachet Charm", "healer", "D", "waist", "charm", JADE, nil, { "vigor", "calm" }, "Dried mint and a mana herb from a C-rank garden.")
A("acc_mercy_ring", "Ring of Mercy", "healer", "D", "hand", "ring", GOLD, TEAL, { "power", "vigor" }, "Its stone glows over a wound that can still close.")
A("acc_mender_ribbon", "White Mender's Ribbon", "healer", "D", "chest", "ribbon", WHITE, nil, { "calm", "ward" }, "Worn by Healers on the front line, so the injured find them.")
A("acc_dawn_symbol", "Silver Dawn Symbol", "healer", "C", "neck", "holy", SILVER, GOLD, { "power", "vigor" }, "A silver sun on a chain. Warm to the touch.")
A("acc_little_censer", "Little Censer", "healer", "C", "waist", "censer", GOLD, { 255, 230, 160 }, { "vigor", "calm" }, "Calming smoke from a tiny brass censer at the hip.")
A("acc_halo_circlet", "Halo Circlet", "healer", "C", "head", "circlet", GOLD, GOLD, { "power", "growth" }, "A gold circlet. People trust whoever wears it.")
A("acc_saint_stole", "Saint's Stole", "healer", "B", "shoulder", "stole", WHITE, GOLD, { "vigor", "calm", "power" }, "White and gold, blessed at a shrine that stands on a closed Gate.")
A("acc_lifebloom", "Lifebloom Bracelet", "healer", "B", "wrist", "bracelet", GREEN, GREEN, { "vigor", "growth" }, "Green crystal flowers that open over the injured.")
A("acc_sunlit_brooch", "Sunlit Brooch", "healer", "A", "chest", "sun", GOLD, { 255, 230, 140 }, { "vigor", "power", "edge" }, "A small sun that is never quite out.")
A("acc_spirit_wisp", "Spirit-Light Wisp", "healer", "A", "float", "orb", { 255, 240, 200 }, { 255, 230, 160 }, { "vigor", "calm", "growth" }, "A warm light that follows you and settles on the hurt.")
A("acc_heart_of_dawn", "Heart of Dawn", "healer", "S", "neck", "holy", GOLD, { 255, 220, 120 }, { "vigor", "power", "edge", "calm" }, "The light of the first morning after the worst break in history.")
A("acc_last_light_ring", "Ring of the Last Light", "healer", "S", "hand", "ring", WHITE, { 255, 250, 230 }, { "vigor", "growth", "power" }, "Whoever wears it is the last to fall, and the first up.")

-- ── ANYONE (luck, nerve, people) ──
A("acc_lucky_coin", "Lucky Coin Charm", "any", "E", "neck", "coin", GOLD, nil, { "heads" }, "A coin with a hole in it, from a fortune teller in a night market.")
A("acc_silver_studs", "Silver Studs", "any", "E", "ear", "stud", SILVER, nil, { "charm" }, "Small, bright, and good for first impressions.")
A("acc_leather_band", "Plain Leather Band", "any", "E", "wrist", "bracelet", LEATHER, nil, { "ward" }, "A gift from someone who worries about you.")
A("acc_licence_pin", "Hunter's Licence Pin", "any", "D", "chest", "badge", GOLD, MANA, { "charm", "ward" }, "Proof you're registered. People stand back a little.")
A("acc_jade_ring", "Jade Ring", "any", "D", "hand", "ring", JADE, nil, { "calm", "heads" }, "Cool green jade. It steadies the hand that wears it.")
A("acc_gate_compass", "Gate Compass", "any", "D", "waist", "charm", GOLD, MANA, { "ward", "heads" }, "Its needle points to the nearest Gate. Walk the other way.")
A("acc_crystal_drop", "Crystal-Drop Earring", "any", "C", "ear", "earring", SKY, MANA, { "heads", "calm" }, "A teardrop of mana crystal.")
A("acc_guild_signet", "Guild Signet Ring", "any", "C", "hand", "ring", GOLD, nil, { "charm", "heads" }, "Your guild's crest in gold. Doors open.")
A("acc_storm_bottle", "Lightning in a Bottle", "any", "C", "waist", "vial", SKY, MANA, { "ward", "calm", "heads" }, "Caught in a thunder-beast's Gate. Uncork in emergencies.")
A("acc_wisp_charm", "Wisp-Lamp Charm", "any", "B", "waist", "charm", TEAL, TEAL, { "heads", "ward", "calm" }, "A tiny lamp with a wisp inside that knows the way out.")
A("acc_gold_chain", "Heavy Gold Chain", "any", "B", "neck", "chain", GOLD, nil, { "charm", "heads" }, "Loud, heavy, and very hard to ignore.")
A("acc_valour_medal", "Medal of Valour", "any", "B", "chest", "medal", GOLD, nil, { "charm", "calm", "ward" }, "From the city, for the day you ran toward the break.")
A("acc_fate_dice", "Fate-Bone Dice", "any", "A", "waist", "charm", BONE, nil, { "heads", "ward" }, "Two bone dice that never roll a one. Mostly.")
A("acc_aurora_crystal", "Aurora Crystal", "any", "A", "float", "crystal", { 160, 255, 210 }, { 160, 255, 210 }, { "heads", "calm", "charm" }, "A crystal that shifts colour with your mood.")
A("acc_gate_key", "Key to a Closed Gate", "any", "S", "neck", "key", GOLD, { 255, 220, 140 }, { "heads", "ward", "calm", "charm" }, "The only thing that ever came out of a Gate that closed from the inside.")
A("acc_deep_pearl", "Pearl of the Deep Gate", "any", "S", "float", "orb", WHITE, SKY, { "heads", "charm", "calm", "ward" }, "A pearl the size of a fist, floating at your shoulder. The sea in it is still moving.")

Accessories.list = list
local byId = {}
for _, a in list do
	byId[a.id] = a
end

function Accessories.find(id: any): any
	return if type(id) == "string" then byId[id] else nil
end

-- a class's accessories (or the general set: "any"), lowest grade first
function Accessories.ofClass(class: string): { any }
	local out = {}
	for _, a in list do
		if a.class == class then
			table.insert(out, a)
		end
	end
	table.sort(out, function(x, y)
		local gx, gy = Accessories.GRADE_OF[x.grade], Accessories.GRADE_OF[y.grade]
		if gx ~= gy then
			return gx < gy
		end
		return x.name < y.name
	end)
	return out
end

-- its budget, spent: the first in the mix gets the biggest share; what's left over goes to
-- the first 1-point thing in the mix (so it's always worth exactly its grade's budget)
function Accessories.points(a: any): { [string]: number }
	local budget = Accessories.BUDGET[Accessories.GRADE_OF[a.grade] or 1]
	local weights, total = {}, 0
	for i, k in a.mix do
		weights[i] = if i == 1 then 3 elseif i == 2 then 2 else 1
		total += weights[i]
	end
	local units: { [string]: number } = {}
	local spent = 0
	for i, k in a.mix do
		local cost = Accessories.COST[k] or 1
		local u = math.min(math.floor(budget * weights[i] / total / cost + 0.5), math.floor((budget - spent) / cost))
		units[k] = (units[k] or 0) + u
		spent += u * cost
	end
	local left = budget - spent
	for _, k in a.mix do
		if Accessories.COST[k] == 1 and left > 0 then
			units[k] += left
			left = 0
		end
	end
	return units
end

function Accessories.score(a: any): number
	local n = 0
	for k, u in Accessories.points(a) do
		n += u * (Accessories.COST[k] or 1)
	end
	return n
end

-- the engine's bonuses (the fields a gear item carries)
function Accessories.stats(a: any): any
	local stat = Accessories.CLASS_STAT[a.class]
	local out: any = {}
	for k, u in Accessories.points(a) do
		if u > 0 then
			if (k == "power" or k == "edge") and stat then
				out.clash = out.clash or {}
				out.clash[stat] = out.clash[stat] or {}
				local key = if k == "power" then "base" else "coinPower"
				out.clash[stat][key] = (out.clash[stat][key] or 0) + u
			elseif k == "charm" then
				out.clash = out.clash or {}
				out.clash.charisma = { base = u }
			elseif k == "coins" then
				out.fight = { coins = u }
			elseif k == "heads" then
				out.heads = 2 * u
			elseif k == "guard" then
				out.toughness = 1 - 0.03 * u
			elseif k == "ward" then
				out.hazardGuard = 1 - 0.04 * u
			elseif k == "growth" and stat then
				out.yearly = out.yearly or {}
				out.yearly[stat] = (out.yearly[stat] or 0) + u
			elseif k == "vigor" then
				out.yearly = out.yearly or {}
				out.yearly.vitality = (out.yearly.vitality or 0) + 2 * u
			elseif k == "calm" then
				out.yearly = out.yearly or {}
				out.yearly.sanity = (out.yearly.sanity or 0) + u
			end
		end
	end
	return out
end

-- what the effect line says
function Accessories.effect(a: any): string
	local s = Accessories.stats(a)
	local parts = {}
	for stat, v in s.clash or {} do
		local name = Accessories.STAT_NAMES[stat] or "Charisma"
		if (v.base or 0) > 0 then
			table.insert(parts, "+" .. v.base .. " base in " .. name .. " fights")
		end
		if (v.coinPower or 0) > 0 then
			table.insert(parts, "+" .. v.coinPower .. " a heads in " .. name .. " fights")
		end
	end
	if s.fight then
		table.insert(parts, "+" .. s.fight.coins .. " coin in fights")
	end
	if s.heads then
		table.insert(parts, "+" .. s.heads .. "% heads")
	end
	if s.toughness then
		table.insert(parts, math.floor((1 - s.toughness) * 100 + 0.5) .. "% less damage taken")
	end
	if s.hazardGuard then
		table.insert(parts, "bad years " .. math.floor((1 - s.hazardGuard) * 100 + 0.5) .. "% less likely")
	end
	for stat, n in s.yearly or {} do
		local name = if stat == "sanity" then "Composure" else (Accessories.STAT_NAMES[stat] or stat)
		table.insert(parts, "+" .. n .. " " .. name .. " a year")
	end
	table.sort(parts)
	local line = table.concat(parts, "; ")
	local stat = Accessories.CLASS_STAT[a.class]
	if stat then
		line ..= ". Made for " .. Accessories.CLASS_NAMES[a.class] .. "s: its bonuses are in " .. Accessories.STAT_NAMES[stat]
	end
	return line .. "."
end

local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
-- who may wear it in a life: low general pieces anyone; the rest Hunters near its grade
function Accessories.requires(a: any): any?
	local g = Accessories.GRADE_OF[a.grade] or 1
	if a.class == "any" and g <= 2 then
		return nil
	end
	local forms = {}
	for i = math.max(1, g - 1), 6 do
		table.insert(forms, HUNTERS[i])
	end
	return { form = forms }
end

local LOOK_KIND = { amulet = "stone", orb = "stone", crystal = "stone", orbs = "stone", fang = "token", holy = "token", coin = "token", medal = "token", censer = "bell", vial = "bell" }
-- every accessory as a gear item (the life sim's "charm" slot)
function Accessories.gearList(): { any }
	local out = {}
	for _, a in list do
		local g = Accessories.GRADE_OF[a.grade] or 1
		local s = Accessories.stats(a)
		table.insert(out, {
			id = a.id,
			name = a.name,
			slot = "charm",
			price = Accessories.PRICE[g],
			minAge = 14,
			rarity = Accessories.RARITY[g],
			desc = a.desc .. " (" .. a.grade .. "-grade " .. (if a.class == "any" then "accessory" else Accessories.CLASS_NAMES[a.class] .. "'s accessory") .. ")",
			effect = Accessories.effect(a),
			clash = s.clash,
			fight = s.fight,
			heads = s.heads,
			toughness = s.toughness,
			hazardGuard = s.hazardGuard,
			yearly = s.yearly,
			requires = Accessories.requires(a),
			look = { kind = LOOK_KIND[a.kind] or "token", color = a.glow or a.color },
			accessory = { id = a.id, class = a.class, grade = a.grade, slot = a.slot },
		})
	end
	return out
end

return Accessories
