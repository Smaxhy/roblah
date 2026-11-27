--[[
	THE MONSTERS OF THE LIVE CITY (BitLeveling): the bestiary's bodies and numbers.

	Solo Leveling's Gates have goblins, orcs and high orcs, ice elves and ice bears, giants,
	giant ants, lizardmen, naga, golems, wyverns and dragons, demons and undead-like knights as
	monster TYPES; every kind here is this game's own design of a type (never a canon named
	individual), and the rest (kobolds, dwarves, forest and dark elves, lycans, treants...) are
	ORIGINAL. Hunter/Bestiary.luau says which is which, and what each one is.

	(Shared, so the client can build them too: the opening cutscene, the title screen. The live
	city's server builds them through server/HunterLive/Monsters, which forwards here.)

	About 180 kinds in 40 families, E to S. Each kind has:
	  name, rank, family, role (warrior, archer, shaman, brute, elite, leader...), behaviour
	  (server/HunterLive/MonsterAI: melee, ranged, caster, brute, swarm, flier, burrower,
	  healer, summoner, leader), hp / dmg / speed scaled by rank, role and family, reach, aggro
	  range, attack cooldown, 1-3 special abilities (MonsterAI.SPECIALS), an attack animation
	  style, and a body: a plan (humanoid, quad, insect, spider, serpent, flyer, golem,
	  elemental, treant...) with its knobs.

	Each is built from Parts on a Humanoid (HipHeight carries the body), in a hierarchy of
	Motor6D joints (root > torso > arms and head; root > legs; body > head > jaw...), so the
	client can animate it (client/MonsterAnim.luau keys on the JOINT names: Torso, Body, Head,
	Jaw, ArmR/ArmL, LegR/LegL, LegR1.., WingR/WingL, Tail, Tail2.., Seg1.., Tent1.., Orb1..,
	MandR/MandL, AntR/AntL, Nucleus, Lid). Part names and MeshRole attributes say which Blender
	mesh each part gets (Hunter/MeshLibrary). Where a new head mesh carries its own ears, beard,
	horns or mane, and the place's kit has it, the head is built as one box that holds them all.

		local model, hum = Monsters.build(kindId)
		Monsters.KINDS[rank] = { kind ids }      Monsters.FAMILIES[family] = { kind ids }
		Monsters.packFor(firstKind, rank, n, rand) -> a coherent pack of n kinds for one Gate
]]

local MeshLibrary = require(script.Parent:WaitForChild("MeshLibrary"))

local Monsters = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end
local V = Vector3.new

-- ── numbers ──────────────────────────────────────────────────────────────────
-- a rank's ordinary fighter (the 24 first kinds kept their own numbers; these sit on them)
Monsters.RANK_HP = { 60, 135, 300, 600, 1100, 2400 }
Monsters.RANK_DMG = { 7, 14, 24, 40, 64, 115 }
-- what a role does to the numbers, and how often it swings (seconds)
Monsters.ROLES = {
	warrior = { hp = 1, dmg = 1, spd = 0, cd = 1.1 },
	swarm = { hp = 0.6, dmg = 0.65, spd = 3, cd = 0.85 },
	archer = { hp = 0.75, dmg = 0.85, spd = 0, cd = 1.3 },
	caster = { hp = 0.7, dmg = 1, spd = -1, cd = 1.4 },
	shaman = { hp = 0.8, dmg = 0.7, spd = -1, cd = 1.4 },
	summoner = { hp = 0.85, dmg = 0.8, spd = -1, cd = 1.4 },
	brute = { hp = 1.45, dmg = 1.3, spd = -3, cd = 1.6 },
	elite = { hp = 1.4, dmg = 1.2, spd = 0, cd = 1.1 },
	leader = { hp = 1.8, dmg = 1.35, spd = 0, cd = 1.2 },
	flier = { hp = 0.8, dmg = 0.95, spd = 5, cd = 1.2 },
	burrower = { hp = 0.95, dmg = 1, spd = 0, cd = 1.1 },
	ambusher = { hp = 1.1, dmg = 1.3, spd = 0, cd = 1.2 },
}
-- the behaviours MonsterAI knows
Monsters.BEHAVIOURS = { "melee", "ranged", "caster", "brute", "swarm", "flier", "burrower", "healer", "summoner", "leader" }
-- the attack animation styles MonsterAnim knows
Monsters.ATTACKS = { "swing", "slam", "bite", "claw", "lunge", "shoot", "cast", "sting", "whip", "peck", "gore" }
Monsters.GAITS = { "biped", "stomp", "quad", "centaur", "crawler", "hexapod", "spider", "slither", "serpent", "swim", "flyer", "float", "blob", "golem", "orbit", "hop", "tentacled" }

-- ── the families: how they look by default, and what they do to the numbers ─────────
local SKIN_ICE, SKIN_DARK = rgb(214, 228, 240), rgb(96, 84, 120)
local LEATHER, DARKLEATHER, IRON, STEEL, GOLD, BONE = rgb(110, 80, 50), rgb(52, 44, 50), rgb(96, 98, 106), rgb(170, 172, 180), rgb(220, 180, 80), rgb(226, 218, 196)
Monsters.COLORS = { leather = LEATHER, iron = IRON, steel = STEEL, gold = GOLD, bone = BONE }

local FAM = {
	goblins = { gait = "biped", c = rgb(96, 130, 70), a = LEATHER, eye = rgb(255, 220, 80), atk = "swing", b = { plan = "humanoid", build = "lean", head = "goblin", outfit = "rags", hunch = 14 } },
	kobolds = { gait = "biped", c = rgb(196, 92, 48), a = rgb(92, 70, 52), eye = rgb(255, 200, 60), atk = "swing", b = { plan = "humanoid", build = "lean", head = "kobold", outfit = "rags", hunch = 20, tail = true, wide = 0.82, belly = rgb(236, 190, 120) } },
	vermin = { gait = "quad", c = rgb(90, 80, 74), a = rgb(200, 150, 150), eye = rgb(255, 60, 60), atk = "bite", stats = { hp = 0.9 } },
	orcs = { gait = "biped", c = rgb(92, 120, 70), a = rgb(120, 110, 100), eye = rgb(255, 80, 60), atk = "swing", b = { plan = "humanoid", build = "normal", head = "orc", outfit = "leather", hunch = 8 }, stats = { hp = 1.05 } },
	high_orcs = { gait = "biped", c = rgb(70, 92, 58), a = rgb(140, 40, 30), eye = rgb(255, 60, 40), atk = "swing", b = { plan = "humanoid", build = "normal", head = "orc", outfit = "plate", hunch = 6, wide = 1.12, paint = rgb(170, 40, 34) }, stats = { hp = 1.1, dmg = 1.05 } },
	ogres = { gait = "stomp", c = rgb(150, 120, 90), a = rgb(90, 70, 50), eye = rgb(255, 120, 60), atk = "slam", b = { plan = "humanoid", build = "hulking", head = "ogre", outfit = "rags", hunch = 18 }, stats = { hp = 1.1 } },
	trolls = { gait = "stomp", c = rgb(110, 110, 96), a = rgb(80, 70, 60), eye = rgb(255, 150, 60), atk = "claw", b = { plan = "humanoid", build = "hulking", head = "troll", outfit = "rags", hunch = 26, clawed = true }, stats = { hp = 1.15, spd = 1 } },
	giants = { gait = "stomp", c = rgb(196, 160, 128), a = rgb(120, 96, 70), eye = rgb(150, 210, 255), atk = "slam", b = { plan = "humanoid", build = "giant", head = "human", outfit = "fur", hunch = 6 }, stats = { hp = 1.3, dmg = 1.2, spd = 1 } },
	ice_elves = { gait = "biped", c = SKIN_ICE, a = rgb(180, 210, 236), eye = rgb(120, 220, 255), atk = "swing", b = { plan = "humanoid", build = "slender", head = "elf", outfit = "leather", hair = rgb(236, 242, 250), hairStyle = "long", leather = rgb(200, 214, 228), trim = rgb(120, 200, 255) }, stats = { hp = 0.9, dmg = 1.1, spd = 2 } },
	forest_elves = { gait = "biped", c = rgb(222, 190, 156), a = rgb(70, 110, 60), eye = rgb(170, 255, 140), atk = "swing", b = { plan = "humanoid", build = "slender", head = "elf", outfit = "leather", hair = rgb(120, 80, 44), hairStyle = "long", leather = rgb(80, 112, 62), trim = rgb(150, 110, 60) }, stats = { hp = 0.85, dmg = 1.05, spd = 2 } },
	dark_elves = { gait = "biped", c = SKIN_DARK, a = rgb(40, 32, 48), eye = rgb(220, 80, 255), atk = "swing", b = { plan = "humanoid", build = "slender", head = "elf", outfit = "leather", hair = rgb(232, 230, 240), hairStyle = "long", leather = rgb(36, 30, 44), trim = rgb(160, 70, 220) }, stats = { hp = 0.85, dmg = 1.15, spd = 2 } },
	dwarves = { gait = "biped", c = rgb(222, 160, 128), a = rgb(120, 70, 40), eye = rgb(255, 190, 90), atk = "swing", b = { plan = "humanoid", build = "stocky", head = "dwarf", outfit = "plate", hair = rgb(150, 70, 36), helm = "dwarf", metal = rgb(150, 120, 80) }, stats = { hp = 1.15, spd = -2 } },
	lizardfolk = { gait = "biped", c = rgb(70, 120, 90), a = rgb(200, 190, 120), eye = rgb(255, 230, 60), atk = "swing", b = { plan = "humanoid", build = "normal", head = "lizard", outfit = "rags", hunch = 12, tail = true, belly = rgb(200, 190, 120) } },
	naga = { gait = "serpent", c = rgb(60, 130, 120), a = rgb(220, 200, 120), eye = rgb(255, 240, 120), atk = "swing", b = { plan = "naga", head = "naga" } },
	ants = { gait = "hexapod", c = rgb(120, 46, 34), a = rgb(60, 30, 26), eye = rgb(255, 200, 80), atk = "bite", b = { plan = "insect", kind = "ant" } },
	beetles = { gait = "crawler", c = rgb(60, 66, 90), a = rgb(140, 220, 255), eye = rgb(140, 220, 255), atk = "gore", b = { plan = "insect", kind = "beetle" }, stats = { hp = 1.15, spd = -2 } },
	mantises = { gait = "hexapod", c = rgb(96, 160, 70), a = rgb(190, 220, 110), eye = rgb(255, 80, 60), atk = "lunge", b = { plan = "insect", kind = "mantis" }, stats = { dmg = 1.1, spd = 2 } },
	centipedes = { gait = "slither", c = rgb(120, 60, 40), a = rgb(230, 170, 60), eye = rgb(255, 200, 80), atk = "bite", b = { plan = "slither", kind = "centipede" } },
	scorpions = { gait = "spider", c = rgb(150, 110, 60), a = rgb(80, 50, 30), eye = rgb(255, 80, 40), atk = "sting", b = { plan = "scorpion" }, stats = { hp = 1.1 } },
	spiders = { gait = "spider", c = rgb(40, 36, 40), a = rgb(170, 40, 40), eye = rgb(255, 40, 40), atk = "lunge", b = { plan = "spider" } },
	wolves = { gait = "quad", c = rgb(80, 78, 84), a = rgb(200, 200, 210), eye = rgb(255, 220, 120), atk = "bite", b = { plan = "quad", kind = "wolf" }, stats = { spd = 6 } },
	bears = { gait = "quad", c = rgb(96, 70, 52), a = rgb(150, 120, 96), eye = rgb(255, 170, 80), atk = "claw", b = { plan = "quad", kind = "bear" }, stats = { hp = 1.15 } },
	boars = { gait = "quad", c = rgb(96, 72, 58), a = rgb(236, 226, 200), eye = rgb(255, 90, 60), atk = "gore", b = { plan = "quad", kind = "boar" } },
	great_cats = { gait = "quad", c = rgb(60, 56, 70), a = rgb(30, 28, 36), eye = rgb(200, 255, 120), atk = "claw", b = { plan = "quad", kind = "cat" }, stats = { dmg = 1.1, spd = 6 } },
	lycans = { gait = "biped", c = rgb(108, 104, 110), a = rgb(64, 60, 66), eye = rgb(255, 210, 80), atk = "claw", b = { plan = "humanoid", build = "normal", head = "lycan", outfit = "none", hunch = 24, clawed = true, tail = true, digitigrade = true }, stats = { dmg = 1.1, spd = 5 } },
	harpies = { gait = "flyer", c = rgb(150, 120, 100), a = rgb(110, 90, 76), eye = rgb(255, 210, 80), atk = "peck", b = { plan = "harpy" } },
	drakes = { gait = "flyer", c = rgb(80, 110, 80), a = rgb(200, 190, 130), eye = rgb(255, 230, 80), atk = "bite", b = { plan = "wyvern" } },
	dragonkin = { gait = "quad", c = rgb(46, 34, 66), a = rgb(255, 120, 60), eye = rgb(255, 60, 90), atk = "bite", b = { plan = "quad", kind = "drake" }, stats = { hp = 1.1, dmg = 1.05 } },
	golems = { gait = "golem", c = rgb(120, 116, 110), a = rgb(255, 170, 60), eye = rgb(255, 170, 60), atk = "slam", b = { plan = "golem" }, stats = { hp = 1.25, dmg = 1.05, spd = -4 } },
	elementals = { gait = "orbit", c = rgb(255, 120, 40), a = rgb(255, 220, 120), eye = rgb(255, 240, 200), atk = "cast", b = { plan = "elemental" }, stats = { hp = 0.95 } },
	slimes = { gait = "blob", c = rgb(80, 200, 160), a = rgb(140, 255, 210), eye = rgb(20, 40, 30), atk = "slam", b = { plan = "blob" }, stats = { hp = 1.15, dmg = 0.9, spd = -5 } },
	undead = { gait = "biped", c = BONE, a = rgb(70, 66, 74), eye = rgb(120, 200, 255), atk = "swing", b = { plan = "humanoid", build = "skeletal", head = "skull", outfit = "bones" }, stats = { hp = 0.9 } },
	demons = { gait = "biped", c = rgb(150, 40, 40), a = rgb(40, 30, 34), eye = rgb(255, 200, 60), atk = "swing", b = { plan = "humanoid", build = "normal", head = "demon", outfit = "plate", metal = rgb(50, 40, 44), wings = true, tail = true }, stats = { dmg = 1.1 } },
	hounds = { gait = "quad", c = rgb(50, 36, 34), a = rgb(255, 110, 40), eye = rgb(255, 160, 40), atk = "bite", b = { plan = "quad", kind = "hound" }, stats = { dmg = 1.05, spd = 5 } },
	plants = { gait = "stomp", c = rgb(96, 72, 50), a = rgb(80, 140, 60), eye = rgb(220, 255, 120), atk = "whip", b = { plan = "treant" } },
	aquatic = { gait = "swim", c = rgb(70, 130, 150), a = rgb(220, 200, 150), eye = rgb(255, 240, 160), atk = "swing", b = { plan = "merfolk" } },
	constructs = { gait = "biped", c = rgb(110, 112, 120), a = rgb(120, 200, 255), eye = rgb(120, 200, 255), atk = "swing", b = { plan = "humanoid", build = "normal", head = "helm", outfit = "armor_shell" } },
	minotaurs = { gait = "biped", c = rgb(110, 76, 56), a = rgb(230, 220, 200), eye = rgb(255, 60, 60), atk = "gore", b = { plan = "humanoid", build = "hulking", head = "bull", outfit = "leather", hunch = 10, digitigrade = true }, stats = { hp = 1.1, dmg = 1.1, spd = 1 } },
	centaurs = { gait = "centaur", c = rgb(196, 150, 112), a = rgb(110, 76, 50), eye = rgb(255, 220, 120), atk = "swing", b = { plan = "centaur", head = "human", hair = rgb(60, 40, 30), hairStyle = "long", outfit = "leather", leather = rgb(140, 110, 70), coat = rgb(120, 84, 56) }, stats = { spd = 6 } },
	basilisks = { gait = "quad", c = rgb(90, 110, 70), a = rgb(200, 210, 120), eye = rgb(255, 255, 120), atk = "bite", b = { plan = "quad", kind = "lizard" }, stats = { hp = 1.15, spd = -2 } },
}
Monsters.FAMILY_STYLE = FAM

-- ── the kinds ─────────────────────────────────────────────────────────────────
-- R(id, family, rank, role, behaviour, name, opts): opts may set s (size), gait, c/a/eye,
-- b (body knobs, over the family's), sp (special abilities), atk, basic (a ranged kind's
-- shot), sum (what it calls or splits into), and hp/dmg/speed (the first 24 keep theirs).
local ROWS = {}
local function R(id: string, fam: string, rank: number, role: string, beh: string, name: string, o: any)
	o = o or {}
	o.id, o.fam, o.rank, o.role, o.beh, o.name = id, fam, rank, role, beh, name
	table.insert(ROWS, o)
end

-- goblins (canon type)
R("goblin", "goblins", 1, "warrior", "melee", "Goblin", { s = 0.7, hp = 60, dmg = 8, speed = 17, sp = { "leap" }, b = { weapon = "club" } })
R("goblin_archer", "goblins", 1, "archer", "ranged", "Goblin Archer", { s = 0.68, sp = { "arrow" }, basic = "arrow", atk = "shoot", b = { weapon = "none", off = "bow", quiver = true, hood = true } })
R("goblin_shaman", "goblins", 1, "shaman", "healer", "Goblin Shaman", { s = 0.66, sp = { "heal", "firebolt" }, atk = "cast", b = { weapon = "staff", staffTop = "skull", feathers = true, outfit = "rags", cloak = rgb(120, 60, 50) } })
R("hobgoblin", "goblins", 2, "elite", "melee", "Hobgoblin", { s = 0.95, hp = 130, dmg = 14, speed = 16, c = rgb(120, 110, 70), a = rgb(90, 90, 96), eye = rgb(255, 170, 60), sp = { "shield", "charge" }, b = { build = "normal", hunch = 4, weapon = "spear", off = "shield_round", outfit = "plate", metal = rgb(90, 90, 96) } })
R("goblin_wolfrider", "goblins", 2, "warrior", "melee", "Goblin Wolf Rider", { s = 0.9, gait = "centaur", sp = { "charge", "howl" }, atk = "swing", b = { plan = "rider", mount = "wolf", mountC = rgb(84, 80, 86), weapon = "spear" } })
R("goblin_warboss", "goblins", 2, "leader", "leader", "Goblin Warboss", { s = 1.05, c = rgb(104, 124, 64), sp = { "warcry", "cleave" }, b = { build = "normal", hunch = 10, weapon = "greataxe", outfit = "plate", metal = rgb(110, 100, 90), helm = "horned", cape = rgb(130, 40, 34) } })
-- kobolds (original)
R("kobold", "kobolds", 1, "swarm", "swarm", "Kobold", { s = 0.58, sp = { "leap" }, b = { weapon = "pick" } })
R("kobold_slinger", "kobolds", 1, "archer", "ranged", "Kobold Slinger", { s = 0.56, sp = { "sling" }, basic = "sling", atk = "shoot", b = { weapon = "sling" } })
R("kobold_tunneler", "kobolds", 1, "burrower", "burrower", "Kobold Tunneler", { s = 0.6, sp = { "burrow" }, b = { weapon = "pick", helm = "miner" } })
R("kobold_trapper", "kobolds", 1, "archer", "ranged", "Kobold Trapper", { s = 0.58, c = rgb(150, 92, 60), sp = { "firepot" }, basic = "firepot", atk = "shoot", b = { weapon = "none", pots = true } })
R("kobold_foreman", "kobolds", 2, "leader", "leader", "Kobold Foreman", { s = 0.8, c = rgb(190, 116, 60), sp = { "warcry", "lash" }, b = { weapon = "whip", helm = "miner", outfit = "leather" } })
-- cave vermin (original)
R("giant_rat", "vermin", 1, "swarm", "swarm", "Giant Rat", { s = 0.6, hp = 45, dmg = 6, speed = 20, b = { plan = "quad", kind = "rat" }, sp = { "leap" } })
R("cave_bat", "vermin", 1, "flier", "flier", "Cave Bat", { s = 0.7, hp = 35, dmg = 5, speed = 22, gait = "flyer", c = rgb(50, 44, 54), a = rgb(80, 60, 70), eye = rgb(255, 200, 80), b = { plan = "bat" }, sp = { "dive" } })
R("cave_crawler", "vermin", 1, "swarm", "swarm", "Cave Crawler", { s = 0.6, gait = "hop", c = rgb(196, 186, 160), a = rgb(150, 140, 120), eye = rgb(40, 40, 40), b = { plan = "cricket" }, sp = { "leap" } })
R("shriek_bat", "vermin", 2, "flier", "flier", "Shriek Bat", { s = 1, gait = "flyer", c = rgb(70, 50, 60), a = rgb(120, 70, 80), eye = rgb(255, 120, 80), b = { plan = "bat", bigEars = true }, sp = { "scream", "dive" } })
-- orcs (canon type)
R("orc_scout", "orcs", 2, "swarm", "swarm", "Orc Scout", { s = 1.05, sp = { "leap" }, b = { build = "lean", weapon = "dagger", twin = true, hood = true } })
R("orc", "orcs", 3, "warrior", "melee", "Orc", { s = 1.35, hp = 300, dmg = 24, speed = 15, sp = { "cleave" }, b = { weapon = "axe" } })
R("orc_archer", "orcs", 3, "archer", "ranged", "Orc Archer", { s = 1.3, sp = { "arrow", "volley" }, basic = "arrow", atk = "shoot", b = { weapon = "none", off = "bow", quiver = true } })
R("orc_shaman", "orcs", 3, "shaman", "caster", "Orc Shaman", { s = 1.3, sp = { "firebolt", "heal" }, basic = "firebolt", atk = "cast", b = { outfit = "robe", cloth = rgb(90, 60, 50), weapon = "staff", staffTop = "skull", feathers = true } })
R("orc_berserker", "orcs", 3, "brute", "brute", "Orc Berserker", { s = 1.45, c = rgb(104, 126, 70), sp = { "enrage", "charge" }, b = { outfit = "fur", weapon = "axe", twin = true, hairStyle = "mohawk", hair = rgb(40, 30, 26), paint = rgb(180, 40, 30) } })
R("orc_warchief", "orcs", 4, "leader", "leader", "Orc Warchief", { s = 1.6, sp = { "warcry", "cleave", "charge" }, b = { weapon = "greataxe", outfit = "plate", metal = rgb(110, 104, 98), helm = "horned", cape = rgb(110, 40, 30) } })
-- high orcs (canon type)
R("high_orc", "high_orcs", 4, "elite", "melee", "High Orc", { s = 1.75, sp = { "cleave", "shield" }, b = { weapon = "axe", off = "shield_round", hairStyle = "topknot", hair = rgb(30, 24, 20) } })
R("high_orc_berserker", "high_orcs", 5, "brute", "brute", "High Orc Berserker", { s = 2, sp = { "enrage", "charge", "slam" }, b = { outfit = "fur", weapon = "greataxe", hairStyle = "mohawk", hair = rgb(30, 24, 20) } })
R("high_orc_shaman", "high_orcs", 5, "shaman", "caster", "High Orc Shaman", { s = 1.85, sp = { "lightning", "ward" }, basic = "lightning", atk = "cast", b = { outfit = "robe", cloth = rgb(60, 50, 70), weapon = "staff", staffTop = "crystal", feathers = true, hairStyle = "topknot", hair = rgb(220, 220, 220) } })
R("warlord", "high_orcs", 5, "leader", "leader", "High Orc Warlord", { s = 2.1, hp = 1200, dmg = 70, speed = 15, sp = { "warcry", "cleave", "charge" }, b = { weapon = "axe", cape = rgb(140, 40, 30), hairStyle = "topknot", hair = rgb(30, 24, 20) } })
-- ogres (original)
R("ogre", "ogres", 4, "brute", "brute", "Ogre", { s = 2, hp = 700, dmg = 46, speed = 13, sp = { "slam", "boulder" }, b = { weapon = "club" } })
R("ogre_mage", "ogres", 4, "caster", "caster", "Ogre Mage", { s = 1.9, c = rgb(90, 120, 170), a = rgb(60, 50, 90), eye = rgb(160, 230, 255), sp = { "frostbolt", "frost_nova" }, basic = "frostbolt", atk = "cast", b = { twoHeads = true, outfit = "robe", cloth = rgb(60, 50, 90), weapon = "staff", staffTop = "crystal" } })
R("ogre_warlord", "ogres", 5, "leader", "leader", "Ogre Warlord", { s = 2.4, sp = { "warcry", "stomp", "boulder" }, b = { weapon = "greatclub", outfit = "plate", metal = rgb(100, 90, 80), helm = "horned" } })
-- trolls (original)
R("moss_troll", "trolls", 2, "brute", "brute", "Moss Troll", { s = 1.3, c = rgb(90, 120, 70), a = rgb(60, 90, 50), sp = { "regen", "slam" }, b = { moss = true } })
R("troll", "trolls", 3, "brute", "brute", "Cave Troll", { s = 1.6, hp = 380, dmg = 28, speed = 12, sp = { "regen", "boulder" }, b = { weapon = "club" } })
R("frost_troll", "trolls", 4, "brute", "brute", "Frost Troll", { s = 1.85, c = rgb(200, 216, 230), a = rgb(140, 170, 200), eye = rgb(120, 220, 255), sp = { "regen", "frost_nova", "slam" }, b = { ice = true } })
R("troll_elder", "trolls", 4, "leader", "leader", "Troll Elder", { s = 2, c = rgb(96, 100, 90), sp = { "regen", "warcry", "boulder" }, b = { weapon = "staff", staffTop = "skull", hair = rgb(200, 200, 190), hairStyle = "wild", beads = true } })
-- giants (canon type)
R("giant_youngling", "giants", 4, "brute", "brute", "Young Hill Giant", { s = 2.6, sp = { "stomp", "boulder" }, b = { weapon = "club", hair = rgb(120, 80, 50), hairStyle = "wild", outfit = "tunic", cloth = rgb(130, 110, 80) } })
R("hill_giant", "giants", 5, "brute", "brute", "Hill Giant", { s = 3.3, sp = { "stomp", "boulder" }, b = { weapon = "greatclub", hair = rgb(90, 60, 40), hairStyle = "wild", beard = rgb(90, 60, 40) } })
R("stone_giant", "giants", 5, "brute", "brute", "Stone Giant", { s = 3.5, c = rgb(140, 140, 134), a = rgb(100, 96, 90), eye = rgb(255, 190, 90), sp = { "quake", "boulder" }, b = { stony = true, weapon = "none", outfit = "tunic", cloth = rgb(90, 86, 80) } })
R("frost_giant", "giants", 6, "brute", "brute", "Frost Giant", { s = 4.1, c = rgb(170, 200, 230), a = rgb(220, 228, 236), eye = rgb(140, 230, 255), sp = { "stomp", "frost_nova", "boulder" }, b = { weapon = "greataxe", ice = true, hair = rgb(236, 240, 248), beard = rgb(236, 240, 248), hairStyle = "long" } })
R("frost_giant_jarl", "giants", 6, "leader", "leader", "Frost Giant Jarl", { s = 4.5, c = rgb(150, 186, 224), a = rgb(230, 236, 244), eye = rgb(140, 230, 255), sp = { "warcry", "frost_breath", "stomp" }, b = { weapon = "greataxe", ice = true, crown = true, cape = rgb(40, 60, 110), hair = rgb(236, 240, 248), beard = rgb(236, 240, 248), hairStyle = "long", outfit = "plate", metal = rgb(150, 190, 230) } })
-- ice elves (canon type: the Snow Folk of the frozen Gates)
R("ice_elf_scout", "ice_elves", 4, "swarm", "swarm", "Ice Elf Scout", { s = 1, sp = { "leap", "blink" }, b = { weapon = "dagger", twin = true, hood = true } })
R("ice_elf_hunter", "ice_elves", 5, "warrior", "melee", "Ice Elf Hunter", { s = 1.1, sp = { "leap", "javelin" }, b = { weapon = "spear", iceWeapon = true, furCollar = true } })
R("ice_elf_archer", "ice_elves", 5, "archer", "ranged", "Ice Elf Archer", { s = 1.08, sp = { "arrow", "volley" }, basic = "arrow", atk = "shoot", b = { weapon = "none", off = "bow", iceWeapon = true, quiver = true, hood = true } })
R("ice_elf_frostmage", "ice_elves", 5, "caster", "caster", "Ice Elf Frost-mage", { s = 1.08, sp = { "frostbolt", "frost_nova", "blink" }, basic = "frostbolt", atk = "cast", b = { outfit = "robe", cloth = rgb(190, 214, 240), weapon = "staff", staffTop = "crystal", circlet = true } })
R("ice_elf_priestess", "ice_elves", 5, "shaman", "healer", "Ice Elf Priestess", { s = 1.05, sp = { "heal", "ward" }, atk = "cast", b = { outfit = "robe", cloth = rgb(236, 242, 250), weapon = "staff", staffTop = "crescent", circlet = true } })
R("ice_elf_warchief", "ice_elves", 6, "leader", "leader", "Ice Elf Warchief", { s = 1.45, sp = { "warcry", "cleave", "frost_nova" }, b = { weapon = "greataxe", iceWeapon = true, outfit = "plate", metal = rgb(170, 210, 240), cape = rgb(220, 232, 244), furCollar = true, helm = "crest" } })
-- forest elves (original)
R("forest_elf_scout", "forest_elves", 2, "archer", "ranged", "Forest Elf Scout", { s = 0.95, sp = { "arrow" }, basic = "arrow", atk = "shoot", b = { weapon = "none", off = "bow", quiver = true, hood = true } })
R("forest_elf_warden", "forest_elves", 3, "warrior", "melee", "Forest Elf Warden", { s = 1.05, sp = { "leap", "cleave" }, b = { weapon = "sword", twin = true, cape = rgb(60, 90, 50) } })
R("forest_elf_ranger", "forest_elves", 3, "archer", "ranged", "Forest Elf Ranger", { s = 1.05, sp = { "arrow", "volley" }, basic = "arrow", atk = "shoot", b = { weapon = "none", off = "bow", quiver = true, cape = rgb(60, 90, 50), hood = true } })
R("forest_elf_druid", "forest_elves", 4, "shaman", "summoner", "Forest Elf Druid", { s = 1.05, sum = "vine_lasher", sp = { "summon", "heal" }, atk = "cast", b = { outfit = "robe", cloth = rgb(70, 100, 56), weapon = "staff", staffTop = "leaf", circlet = true, leaves = true } })
-- dark elves (original)
R("dark_elf_stalker", "dark_elves", 4, "warrior", "melee", "Dark Elf Stalker", { s = 1, sp = { "blink", "leap" }, b = { weapon = "dagger", twin = true, hood = true } })
R("dark_elf_arbalest", "dark_elves", 4, "archer", "ranged", "Dark Elf Arbalest", { s = 1.02, sp = { "arrow", "volley" }, basic = "arrow", atk = "shoot", b = { weapon = "crossbow" } })
R("dark_elf_spellblade", "dark_elves", 5, "elite", "melee", "Dark Elf Spellblade", { s = 1.1, sp = { "blink", "cleave", "shadowbolt" }, b = { weapon = "scimitar", cape = rgb(60, 20, 70) } })
R("dark_elf_sorceress", "dark_elves", 5, "caster", "caster", "Dark Elf Sorceress", { s = 1.05, sp = { "shadowbolt", "drain", "blink" }, basic = "shadowbolt", atk = "cast", b = { outfit = "robe", cloth = rgb(50, 30, 64), weapon = "staff", staffTop = "orb", circlet = true } })
R("dark_elf_matriarch", "dark_elves", 6, "leader", "leader", "Dark Elf Matriarch", { s = 1.4, sum = "phase_spider", sp = { "warcry", "summon", "drain" }, atk = "cast", b = { outfit = "robe", cloth = rgb(40, 20, 50), weapon = "staff", staffTop = "crescent", crown = true, cape = rgb(90, 20, 90) } })
-- dwarves (original)
R("dwarf_miner", "dwarves", 2, "burrower", "burrower", "Dwarf Miner", { s = 0.95, sp = { "burrow" }, b = { weapon = "pick", helm = "miner", outfit = "leather" } })
R("dwarf_axeguard", "dwarves", 3, "elite", "melee", "Dwarf Axe-guard", { s = 1.05, sp = { "shield", "cleave" }, b = { weapon = "axe", off = "shield_round", metal = rgb(160, 150, 130) } })
R("dwarf_thunderer", "dwarves", 3, "archer", "ranged", "Dwarf Thunderer", { s = 1, sp = { "firepot" }, basic = "firepot", atk = "shoot", b = { weapon = "none", pots = true, outfit = "leather", hair = rgb(60, 40, 30) } })
R("dwarf_runesmith", "dwarves", 4, "shaman", "healer", "Dwarf Runesmith", { s = 1.05, sp = { "ward", "lightning" }, atk = "cast", b = { weapon = "hammer", runes = rgb(120, 220, 255), hair = rgb(200, 200, 196) } })
R("dwarf_berserker", "dwarves", 4, "brute", "brute", "Dwarf Berserker", { s = 1.1, sp = { "enrage", "leap" }, b = { weapon = "axe", twin = true, outfit = "fur", helm = "none", hair = rgb(200, 80, 30), hairStyle = "mohawk" } })
R("dwarf_forgelord", "dwarves", 5, "leader", "leader", "Dwarf Forge-lord", { s = 1.35, sp = { "warcry", "slam", "fire_nova" }, b = { weapon = "hammer", big = true, metal = rgb(90, 70, 60), forge = true, helm = "crest", cape = rgb(120, 40, 20), hair = rgb(60, 50, 50) } })
-- lizardfolk (canon type: lizardmen)
R("lizardman_skirmisher", "lizardfolk", 2, "archer", "ranged", "Lizardman Skirmisher", { s = 1.05, sp = { "javelin" }, basic = "javelin", atk = "shoot", b = { weapon = "javelin" } })
R("bog_toad", "lizardfolk", 2, "brute", "brute", "Bog Toad", { s = 1.2, gait = "hop", c = rgb(96, 110, 60), a = rgb(190, 180, 110), eye = rgb(255, 200, 60), atk = "bite", sp = { "lash", "leap" }, b = { plan = "toad" } })
R("lizardman", "lizardfolk", 3, "warrior", "melee", "Lizardman", { s = 1.2, hp = 260, dmg = 22, speed = 18, sp = { "tail_sweep" }, b = { weapon = "spear" } })
R("lizardman_shaman", "lizardfolk", 3, "shaman", "healer", "Lizardman Shaman", { s = 1.15, sp = { "heal", "spit" }, atk = "cast", b = { weapon = "staff", staffTop = "skull", feathers = true } })
R("lizardman_crocguard", "lizardfolk", 4, "brute", "brute", "Croc-headed Guard", { s = 1.7, c = rgb(70, 90, 60), sp = { "shield", "tail_sweep", "charge" }, b = { head = "croc", build = "hulking", weapon = "club", off = "shield_round" } })
-- naga (canon type)
R("naga", "naga", 3, "warrior", "melee", "Naga", { s = 1.2, hp = 280, dmg = 24, speed = 16, sp = { "tail_sweep" }, b = { weapon = "spear" } })
R("naga_siren", "naga", 4, "caster", "caster", "Naga Siren", { s = 1.25, c = rgb(90, 150, 150), sp = { "scream", "heal" }, atk = "cast", b = { weapon = "none", jewels = true } })
R("naga_myrmidon", "naga", 4, "elite", "melee", "Naga Myrmidon", { s = 1.4, c = rgb(50, 110, 110), sp = { "cleave", "tail_sweep" }, b = { fourArms = true, weapon = "scimitar", twin = true, armor = true } })
R("naga_tidecaller", "naga", 5, "leader", "leader", "Naga Tidecaller", { s = 1.6, c = rgb(40, 100, 120), a = rgb(240, 210, 120), sp = { "warcry", "frostbolt", "tail_sweep" }, atk = "cast", b = { weapon = "trident", crown = true, jewels = true } })
-- giant ants (canon type; these colonies are the game's own)
R("ant_worker", "ants", 2, "swarm", "burrower", "Ant Worker", { s = 0.8, sp = { "burrow" } })
R("ant_soldier", "ants", 3, "warrior", "melee", "Ant Soldier", { s = 1.15, sp = { "charge" }, b = { bigHead = true } })
R("ant_spitter", "ants", 3, "archer", "ranged", "Ant Spitter", { s = 1.05, c = rgb(140, 80, 30), sp = { "spit" }, basic = "spit", atk = "shoot", b = { bigAbdomen = true } })
R("winged_ant", "ants", 4, "flier", "flier", "Winged Ant", { s = 1.15, gait = "flyer", sp = { "dive", "spit" }, b = { wings = true } })
R("ant_royal_guard", "ants", 5, "elite", "melee", "Ant Royal Guard", { s = 1.6, c = rgb(90, 30, 26), a = rgb(220, 170, 60), sp = { "shield", "charge", "cleave" }, b = { bigHead = true, plated = true } })
-- beetles (original)
R("scarab", "beetles", 1, "swarm", "swarm", "Scarab", { s = 0.5, c = rgb(40, 90, 80), a = rgb(120, 230, 180), eye = rgb(200, 255, 220), sp = { "burrow" } })
R("beetle", "beetles", 2, "brute", "brute", "Armoured Beetle", { s = 1, hp = 150, dmg = 13, speed = 13, sp = { "charge", "shield" }, b = { horn = 1 } })
R("bombardier_beetle", "beetles", 2, "archer", "ranged", "Bombardier Beetle", { s = 0.95, c = rgb(150, 70, 30), a = rgb(255, 180, 60), eye = rgb(255, 220, 120), sp = { "scald" }, basic = "scald", atk = "shoot" })
R("rhino_beetle", "beetles", 3, "brute", "brute", "Rhino Beetle", { s = 1.5, c = rgb(70, 50, 40), a = rgb(200, 150, 90), eye = rgb(255, 160, 80), sp = { "charge", "slam" }, b = { horn = 2 } })
-- mantises (original)
R("blade_mantis", "mantises", 3, "warrior", "melee", "Blade Mantis", { s = 1.2, sp = { "leap", "cleave" } })
R("ghost_mantis", "mantises", 4, "warrior", "melee", "Ghost Mantis", { s = 1.35, c = rgb(214, 224, 230), a = rgb(170, 190, 210), eye = rgb(120, 220, 255), sp = { "blink", "cleave" } })
R("reaper_mantis", "mantises", 5, "elite", "melee", "Reaper Mantis", { s = 1.8, c = rgb(60, 70, 50), a = rgb(170, 60, 50), sp = { "leap", "cleave", "blink" } })
-- centipedes (original; not the System's penalty-zone ones)
R("tunnel_centipede", "centipedes", 2, "burrower", "burrower", "Tunnel Centipede", { s = 0.9, sp = { "burrow", "spit" } })
R("ironback_centipede", "centipedes", 4, "brute", "brute", "Ironback Centipede", { s = 1.4, c = rgb(70, 72, 80), a = rgb(170, 60, 40), sp = { "charge", "burrow" } })
R("sand_wyrm", "centipedes", 6, "brute", "burrower", "Sand Wyrm", { s = 3, c = rgb(190, 160, 110), a = rgb(140, 100, 70), eye = rgb(255, 120, 60), sp = { "burrow", "quake", "spit" }, b = { kind = "wyrm" } })
-- scorpions (original)
R("scorpling", "scorpions", 2, "swarm", "swarm", "Scorpling", { s = 0.65, sp = { "sting" } })
R("sand_scorpion", "scorpions", 3, "warrior", "melee", "Sand Scorpion", { s = 1.2, sp = { "sting", "charge" } })
R("emperor_scorpion", "scorpions", 5, "elite", "melee", "Emperor Scorpion", { s = 2, c = rgb(58, 50, 80), a = rgb(140, 100, 210), eye = rgb(170, 120, 255), sp = { "sting", "spit", "shield" } })
-- spiders (original)
R("spiderling", "spiders", 1, "swarm", "swarm", "Spiderling", { s = 0.5, sp = { "leap" } })
R("spider", "spiders", 2, "warrior", "melee", "Giant Spider", { s = 1, hp = 120, dmg = 15, speed = 19, sp = { "web", "leap" } })
R("weaver_spider", "spiders", 3, "summoner", "summoner", "Weaver Spider", { s = 1.3, c = rgb(70, 60, 50), a = rgb(230, 220, 200), sum = "spiderling", sp = { "web", "summon" } })
R("phase_spider", "spiders", 4, "warrior", "melee", "Phase Spider", { s = 1.35, c = rgb(60, 50, 110), a = rgb(150, 120, 255), eye = rgb(190, 160, 255), sp = { "blink", "web" } })
-- wolves (original)
R("grey_wolf", "wolves", 1, "swarm", "swarm", "Grey Wolf", { s = 0.75, c = rgb(120, 118, 120), sp = { "leap" } })
R("dire_wolf", "wolves", 2, "warrior", "melee", "Dire Wolf", { s = 1, hp = 110, dmg = 14, speed = 24, sp = { "leap", "howl" } })
R("frost_wolf", "wolves", 3, "warrior", "melee", "Frost Wolf", { s = 1.2, c = rgb(214, 224, 236), a = rgb(150, 190, 230), eye = rgb(120, 220, 255), sp = { "frost_breath", "leap" }, b = { frost = true } })
R("wolf_alpha", "wolves", 3, "leader", "leader", "Wolf Alpha", { s = 1.4, c = rgb(60, 58, 64), sp = { "howl", "leap" }, b = { mane = true, scar = true } })
-- bears (canon type: ice bears)
R("cave_bear", "bears", 3, "brute", "brute", "Cave Bear", { s = 1.35, sp = { "slam", "charge" } })
R("ice_bear", "bears", 4, "brute", "brute", "Ice Bear", { s = 1.6, hp = 560, dmg = 40, speed = 18, c = rgb(226, 232, 240), a = rgb(170, 210, 240), eye = rgb(120, 200, 255), sp = { "charge", "slam" }, b = { frost = true } })
R("ice_bear_alpha", "bears", 5, "leader", "leader", "Alpha Ice Bear", { s = 2.1, c = rgb(236, 240, 246), a = rgb(150, 200, 240), eye = rgb(120, 220, 255), sp = { "howl", "slam", "frost_nova" }, b = { frost = true, scar = true } })
-- boars (original)
R("wild_boar", "boars", 1, "brute", "brute", "Wild Boar", { s = 0.75, sp = { "charge" } })
R("razorback", "boars", 2, "brute", "brute", "Razorback", { s = 1.05, c = rgb(70, 52, 44), sp = { "charge", "enrage" }, b = { spikes = true } })
R("ironhide_boar", "boars", 3, "brute", "brute", "Ironhide Boar", { s = 1.4, c = rgb(90, 90, 96), a = rgb(220, 210, 190), sp = { "charge", "shield" }, b = { plated = true } })
-- great cats (original)
R("dusk_panther", "great_cats", 3, "warrior", "melee", "Dusk Panther", { s = 1.1, sp = { "leap" } })
R("sabre_cat", "great_cats", 4, "warrior", "melee", "Sabre Cat", { s = 1.35, c = rgb(190, 150, 90), a = rgb(110, 76, 40), eye = rgb(255, 210, 80), sp = { "leap", "cleave" }, b = { sabre = true, stripes = true } })
R("thunder_tiger", "great_cats", 5, "elite", "melee", "Thunder Tiger", { s = 1.8, c = rgb(230, 200, 120), a = rgb(40, 40, 50), eye = rgb(150, 220, 255), sp = { "leap", "lightning" }, b = { stripes = true, sparks = true } })
-- lycans (ORIGINAL type: not the System's steel-fanged ones)
R("ashen_lycan", "lycans", 4, "warrior", "melee", "Ashen Lycan", { s = 1.35, sp = { "leap", "howl" } })
R("lycan_packmaster", "lycans", 5, "leader", "leader", "Lycan Packmaster", { s = 1.7, c = rgb(70, 66, 74), a = rgb(140, 40, 40), sp = { "howl", "leap", "enrage" }, b = { scar = true, bracers = true } })
-- harpies and birds (original)
R("gloom_crow", "harpies", 2, "swarm", "flier", "Gloom Crow", { s = 0.85, c = rgb(30, 30, 36), a = rgb(60, 60, 80), eye = rgb(255, 90, 90), sp = { "dive" }, b = { plan = "bird" } })
R("harpy", "harpies", 3, "flier", "flier", "Harpy", { s = 1.05, sp = { "dive", "scream" } })
R("harpy_shrieker", "harpies", 4, "caster", "caster", "Harpy Shrieker", { s = 1.15, c = rgb(120, 90, 120), a = rgb(170, 120, 170), eye = rgb(255, 140, 255), sp = { "scream", "dive" }, atk = "cast" })
R("thunderbird", "harpies", 5, "flier", "flier", "Thunderbird", { s = 2, c = rgb(40, 60, 110), a = rgb(230, 220, 120), eye = rgb(170, 230, 255), sp = { "lightning", "dive" }, b = { plan = "bird", crest = true, sparks = true } })
-- wyverns and drakes (canon type: wyverns)
R("wyvern_hatchling", "drakes", 3, "flier", "flier", "Wyvern Hatchling", { s = 1.1, c = rgb(110, 140, 90), sp = { "dive", "firebolt" } })
R("fire_drake", "drakes", 4, "brute", "brute", "Fire Drake", { s = 1.5, gait = "quad", c = rgb(150, 50, 30), a = rgb(255, 160, 60), eye = rgb(255, 220, 80), sp = { "fire_breath", "charge" }, b = { plan = "quad", kind = "drake", wings = true, horns = true } })
R("wyvern", "drakes", 5, "flier", "flier", "Wyvern", { s = 2.2, hp = 1000, dmg = 68, speed = 22, sp = { "dive", "sting", "fire_breath" } })
R("storm_wyvern", "drakes", 6, "flier", "flier", "Storm Wyvern", { s = 2.9, c = rgb(50, 60, 90), a = rgb(150, 200, 255), eye = rgb(170, 230, 255), sp = { "lightning", "dive", "tail_sweep" }, b = { sparks = true, horns = true } })
-- dragon-kin (canon type)
R("dragonkin_drakeling", "dragonkin", 5, "warrior", "melee", "Dragon-kin Drakeling", { s = 1.8, c = rgb(70, 46, 90), sp = { "fire_breath", "leap" }, b = { horns = true } })
R("dragonkin", "dragonkin", 6, "brute", "brute", "Dragon-kin", { s = 3, hp = 2800, dmg = 120, speed = 18, sp = { "fire_breath", "tail_sweep", "stomp" }, b = { wings = true, horns = true, spines = true } })
R("dragonkin_knight", "dragonkin", 6, "elite", "melee", "Dragon-kin Knight", { s = 1.9, gait = "biped", c = rgb(96, 66, 130), a = rgb(255, 120, 60), sp = { "cleave", "charge", "fire_breath" }, b = { plan = "humanoid", build = "hulking", head = "draconic", outfit = "plate", metal = rgb(76, 60, 96), weapon = "greatsword", flame = true, wings = true, tail = true, hunch = 6 } })
R("dragonkin_flamecaller", "dragonkin", 6, "caster", "caster", "Dragon-kin Flamecaller", { s = 1.8, gait = "biped", c = rgb(120, 40, 50), a = rgb(60, 20, 30), eye = rgb(255, 200, 60), sp = { "meteor", "firebolt", "fire_nova" }, basic = "firebolt", atk = "cast", b = { plan = "humanoid", build = "normal", head = "draconic", outfit = "robe", cloth = rgb(90, 20, 30), weapon = "staff", staffTop = "orb", tail = true, wings = true } })
-- golems (canon type)
R("mud_golem", "golems", 1, "brute", "brute", "Mud Golem", { s = 0.95, c = rgb(110, 84, 60), a = rgb(180, 220, 120), eye = rgb(200, 255, 140), sp = { "slam" }, b = { mud = true } })
R("iron_golem", "golems", 4, "brute", "brute", "Iron Golem", { s = 1.9, hp = 820, dmg = 44, speed = 11, c = rgb(110, 112, 120), a = rgb(255, 150, 60), eye = rgb(255, 150, 60), sp = { "slam", "shield" }, b = { rivets = true, material = "metal" } })
R("crystal_golem", "golems", 4, "brute", "caster", "Crystal Golem", { s = 1.8, c = rgb(150, 160, 200), a = rgb(170, 140, 255), eye = rgb(200, 180, 255), sp = { "shard", "shield" }, basic = "shard", atk = "cast", b = { crystals = 5 } })
R("stone_golem", "golems", 5, "brute", "brute", "Stone Golem", { s = 2.5, hp = 1500, dmg = 76, speed = 10, sp = { "slam", "boulder", "shield" }, b = { crystals = 3, moss = true } })
R("magma_golem", "golems", 5, "brute", "brute", "Magma Golem", { s = 2.4, c = rgb(50, 40, 40), a = rgb(255, 110, 30), eye = rgb(255, 200, 60), sp = { "fire_nova", "slam" }, b = { cracks = true } })
R("colossus", "golems", 6, "brute", "brute", "Colossus", { s = 4, hp = 3600, dmg = 140, speed = 10, c = rgb(150, 140, 120), a = rgb(120, 200, 255), eye = rgb(120, 200, 255), sp = { "stomp", "quake", "shield" }, b = { crystals = 3, rivets = true, runes = rgb(120, 200, 255) } })
-- elementals (original)
R("mana_wisp", "elementals", 1, "caster", "caster", "Mana Wisp", { s = 0.6, c = rgb(110, 180, 255), a = rgb(200, 230, 255), eye = rgb(255, 255, 255), sp = { "shard" }, basic = "shard", b = { element = "mana" } })
R("earth_elemental", "elementals", 3, "brute", "brute", "Earth Elemental", { s = 1.5, c = rgb(120, 96, 70), a = rgb(170, 200, 110), eye = rgb(200, 255, 140), atk = "slam", sp = { "quake", "boulder" }, b = { element = "earth" } })
R("fire_elemental", "elementals", 3, "caster", "caster", "Fire Elemental", { s = 1.3, sp = { "firebolt", "fire_nova" }, basic = "firebolt", b = { element = "fire" } })
R("frost_elemental", "elementals", 4, "caster", "caster", "Frost Elemental", { s = 1.5, c = rgb(170, 220, 255), a = rgb(230, 245, 255), eye = rgb(255, 255, 255), sp = { "frostbolt", "frost_nova" }, basic = "frostbolt", b = { element = "frost" } })
R("storm_elemental", "elementals", 5, "caster", "caster", "Storm Elemental", { s = 1.8, c = rgb(70, 76, 100), a = rgb(170, 220, 255), eye = rgb(220, 240, 255), sp = { "lightning", "blink" }, basic = "lightning", b = { element = "storm" } })
R("inferno_elemental", "elementals", 6, "caster", "caster", "Inferno Elemental", { s = 2.6, c = rgb(255, 90, 30), a = rgb(255, 210, 90), eye = rgb(255, 255, 200), sp = { "meteor", "fire_nova", "firebolt" }, basic = "firebolt", b = { element = "fire", big = true } })
-- slimes (original)
R("slime", "slimes", 1, "warrior", "melee", "Mana Slime", { s = 0.9, hp = 70, dmg = 7, speed = 10, sum = "slime", sp = { "split" } })
R("acid_slime", "slimes", 2, "warrior", "melee", "Acid Slime", { s = 1.05, c = rgb(150, 210, 60), a = rgb(220, 255, 120), sum = "acid_slime", sp = { "spit", "split" } })
R("magma_slime", "slimes", 3, "warrior", "melee", "Magma Slime", { s = 1.2, c = rgb(60, 40, 40), a = rgb(255, 120, 40), eye = rgb(255, 220, 120), sum = "magma_slime", sp = { "fire_nova", "split" }, b = { crust = true } })
R("crowned_slime", "slimes", 4, "summoner", "summoner", "Crowned Slime", { s = 1.8, c = rgb(90, 140, 255), a = rgb(200, 230, 255), sum = "acid_slime", sp = { "summon", "slam" }, b = { crown = true } })
-- undead (original; skeletal and ghostly)
R("skeleton", "undead", 1, "warrior", "melee", "Skeleton Soldier", { s = 0.85, sp = { "shield" }, b = { weapon = "sword", off = "shield_round", rusty = true } })
R("skeleton_archer", "undead", 2, "archer", "ranged", "Skeleton Archer", { s = 0.9, sp = { "arrow" }, basic = "arrow", atk = "shoot", b = { weapon = "none", off = "bow", quiver = true } })
R("skeleton_mage", "undead", 2, "caster", "caster", "Skeleton Mage", { s = 0.9, sp = { "shadowbolt" }, basic = "shadowbolt", atk = "cast", b = { outfit = "robe_tatters", cloth = rgb(50, 40, 70), weapon = "staff", staffTop = "skull", hood = true } })
R("ghoul", "undead", 3, "swarm", "swarm", "Ghoul", { s = 1.1, c = rgb(150, 150, 156), a = rgb(80, 80, 90), eye = rgb(200, 255, 200), atk = "claw", sp = { "leap" }, b = { build = "lean", head = "ghoul", outfit = "rags", hunch = 34, clawed = true } })
R("wraith", "undead", 4, "caster", "caster", "Wraith", { s = 1.5, hp = 420, dmg = 38, speed = 20, gait = "float", c = rgb(60, 60, 90), a = rgb(150, 120, 255), eye = rgb(170, 140, 255), atk = "swing", sp = { "drain", "blink" }, basic = "shadowbolt", b = { plan = "float", scythe = true } })
R("grave_knight", "undead", 5, "elite", "melee", "Grave Knight", { s = 1.7, c = rgb(70, 72, 80), a = rgb(30, 30, 40), sp = { "cleave", "charge", "shield" }, b = { build = "normal", head = "helm", outfit = "armor_shell", weapon = "greatsword", cape = rgb(40, 36, 60), visor = rgb(120, 200, 255) } })
R("lich", "undead", 6, "summoner", "summoner", "Lich", { s = 1.9, gait = "float", c = rgb(50, 40, 70), a = rgb(120, 220, 255), eye = rgb(120, 220, 255), sum = "grave_knight", sp = { "raise", "frost_nova", "shadowbolt" }, basic = "shadowbolt", atk = "cast", b = { plan = "float", skull = true, crown = true, staff = true } })
R("hollow_king", "undead", 6, "leader", "leader", "Hollow King", { s = 2.6, hp = 2400, dmg = 125, speed = 16, gait = "float", c = rgb(30, 26, 40), a = rgb(255, 210, 90), eye = rgb(255, 60, 60), sum = "wraith", sp = { "warcry", "drain", "raise" }, b = { plan = "float", crown = true, staff = true } })
R("bone_drake", "undead", 6, "flier", "flier", "Bone Drake", { s = 2.7, gait = "flyer", c = BONE, a = rgb(120, 220, 255), eye = rgb(120, 220, 255), atk = "bite", sp = { "dive", "frost_breath" }, b = { plan = "wyvern", bones = true } })
-- demons (canon type: the demons of a demon Gate; these designs are the game's own)
R("imp", "demons", 1, "caster", "caster", "Imp", { s = 0.55, gait = "hop", c = rgb(200, 60, 50), sp = { "firebolt", "blink" }, basic = "firebolt", atk = "cast", b = { plan = "imp" } })
R("demon_soldier", "demons", 4, "warrior", "melee", "Demon Soldier", { s = 1.5, sp = { "cleave", "charge" }, b = { weapon = "glaive", wings = false } })
R("demon_knight", "demons", 5, "elite", "melee", "Demon Knight", { s = 1.85, c = rgb(120, 30, 34), sp = { "cleave", "blink", "fire_nova" }, b = { weapon = "greatsword", flame = true, cape = rgb(60, 10, 14), helm = "horned" } })
R("demon_warlock", "demons", 5, "caster", "caster", "Demon Warlock", { s = 1.7, c = rgb(110, 40, 70), sp = { "meteor", "shadowbolt", "ward" }, basic = "shadowbolt", atk = "cast", b = { outfit = "robe", cloth = rgb(50, 20, 30), weapon = "staff", staffTop = "orb" } })
R("demon_noble", "demons", 6, "leader", "leader", "Demon Noble", { s = 2.3, c = rgb(90, 20, 30), a = rgb(255, 200, 90), sum = "demon_soldier", sp = { "warcry", "meteor", "summon" }, b = { build = "hulking", weapon = "greatsword", flame = true, crown = true, cape = rgb(40, 10, 16), hunch = 2 } })
-- cerberus-like hounds (ORIGINAL; not canon's gatekeeper)
R("ember_hound", "hounds", 2, "warrior", "melee", "Ember Hound", { s = 0.95, sp = { "leap", "fire_breath" } })
R("twinhead_hound", "hounds", 4, "elite", "melee", "Two-headed Hound", { s = 1.5, sp = { "fire_breath", "leap", "howl" }, b = { heads = 2 } })
R("threehead_hound", "hounds", 6, "brute", "brute", "Three-headed Warhound", { s = 2.6, c = rgb(30, 24, 26), sp = { "fire_breath", "howl", "charge" }, b = { heads = 3, mane = true } })
-- plants (original)
R("mandrake", "plants", 1, "caster", "caster", "Mandrake", { s = 0.6, gait = "hop", c = rgb(200, 170, 120), a = rgb(90, 170, 70), eye = rgb(40, 30, 20), atk = "cast", sp = { "scream" }, b = { plan = "mandrake" } })
R("vine_lasher", "plants", 2, "warrior", "melee", "Vine Lasher", { s = 1, gait = "tentacled", c = rgb(70, 110, 50), a = rgb(220, 80, 110), eye = rgb(255, 220, 120), sp = { "lash" }, b = { plan = "vines" } })
R("spore_shambler", "plants", 2, "shaman", "caster", "Spore Shambler", { s = 1.1, gait = "biped", c = rgb(200, 190, 170), a = rgb(170, 60, 60), eye = rgb(220, 255, 140), atk = "slam", sp = { "spores", "slam" }, b = { plan = "humanoid", build = "stocky", head = "mushroom", outfit = "none", hunch = 8 } })
R("treant", "plants", 4, "brute", "brute", "Treant", { s = 2.2, sp = { "stomp", "lash" } })
R("elder_treant", "plants", 5, "leader", "leader", "Elder Treant", { s = 3, c = rgb(80, 66, 56), a = rgb(96, 140, 70), eye = rgb(255, 210, 120), sp = { "quake", "heal", "stomp" }, b = { blossoms = true } })
-- aquatic (original)
R("reef_crab", "aquatic", 2, "warrior", "melee", "Reef Crab", { s = 1, gait = "crawler", c = rgb(200, 90, 60), a = rgb(240, 200, 170), eye = rgb(20, 20, 20), atk = "lunge", sp = { "shield" }, b = { plan = "crab" } })
R("merfolk_warrior", "aquatic", 3, "warrior", "melee", "Merfolk Warrior", { s = 1.2, sp = { "charge" }, b = { weapon = "trident" } })
R("merfolk_tidecaller", "aquatic", 4, "shaman", "healer", "Merfolk Tidecaller", { s = 1.2, c = rgb(90, 150, 170), sp = { "frostbolt", "heal" }, atk = "cast", b = { weapon = "staff", staffTop = "orb", jewels = true } })
R("kraken_spawn", "aquatic", 4, "brute", "brute", "Kraken Spawn", { s = 1.7, gait = "tentacled", c = rgb(120, 60, 110), a = rgb(230, 160, 200), eye = rgb(255, 230, 100), atk = "whip", sp = { "lash", "ink" }, b = { plan = "kraken" } })
R("abyss_serpent", "aquatic", 6, "brute", "brute", "Abyssal Serpent", { s = 3, hp = 2600, dmg = 115, speed = 19, gait = "serpent", c = rgb(30, 40, 70), a = rgb(80, 220, 255), eye = rgb(80, 255, 255), atk = "bite", sp = { "frost_breath", "tail_sweep" }, b = { plan = "serpent", horns = true, fins = true } })
-- constructs and mimics (original)
R("living_armor", "constructs", 2, "warrior", "melee", "Living Armour", { s = 1.05, sp = { "shield", "charge" }, b = { weapon = "sword", off = "shield_kite", visor = rgb(120, 200, 255) } })
R("mimic", "constructs", 3, "ambusher", "melee", "Mimic", { s = 1.1, gait = "hop", c = rgb(120, 80, 46), a = rgb(220, 180, 80), eye = rgb(255, 210, 90), atk = "bite", sp = { "ambush", "lash" }, b = { plan = "mimic" } })
R("gargoyle", "constructs", 4, "flier", "flier", "Gargoyle", { s = 1.4, gait = "flyer", c = rgb(120, 120, 118), a = rgb(90, 90, 88), eye = rgb(255, 120, 60), atk = "claw", sp = { "dive", "shield" }, b = { plan = "gargoyle" } })
R("rune_sentinel", "constructs", 5, "brute", "brute", "Rune Sentinel", { s = 2.2, gait = "golem", c = rgb(80, 86, 100), a = rgb(120, 220, 255), eye = rgb(120, 220, 255), atk = "slam", sp = { "gaze", "shield", "slam" }, b = { plan = "golem", runes = rgb(120, 220, 255), oneEye = true, material = "metal" } })
-- minotaurs (original)
R("minotaur_raider", "minotaurs", 4, "warrior", "melee", "Minotaur Raider", { s = 1.7, sp = { "charge" }, b = { weapon = "axe" } })
R("minotaur", "minotaurs", 5, "brute", "brute", "Minotaur", { s = 2.2, hp = 1300, dmg = 74, speed = 17, sp = { "charge", "slam" }, b = { weapon = "greataxe" } })
R("minotaur_champion", "minotaurs", 6, "leader", "leader", "Minotaur Champion", { s = 2.8, c = rgb(70, 50, 40), sp = { "warcry", "charge", "stomp" }, b = { weapon = "greataxe", outfit = "plate", metal = rgb(120, 100, 70), cape = rgb(120, 30, 30) } })
-- centaurs (original)
R("centaur_skirmisher", "centaurs", 3, "archer", "ranged", "Centaur Skirmisher", { s = 1.15, sp = { "javelin", "charge" }, basic = "javelin", atk = "shoot", b = { weapon = "javelin" } })
R("centaur_archer", "centaurs", 4, "archer", "ranged", "Centaur Archer", { s = 1.25, sp = { "arrow", "volley" }, basic = "arrow", atk = "shoot", b = { weapon = "none", off = "bow", quiver = true } })
R("centaur_lancer", "centaurs", 5, "brute", "brute", "Centaur Lancer", { s = 1.6, c = rgb(150, 110, 80), sp = { "charge", "cleave" }, b = { weapon = "lance", armor = true } })
-- basilisks (original)
R("cockatrice", "basilisks", 2, "warrior", "melee", "Cockatrice", { s = 0.9, gait = "biped", c = rgb(200, 160, 90), a = rgb(170, 60, 50), eye = rgb(255, 255, 120), atk = "peck", sp = { "gaze", "leap" }, b = { plan = "cockatrice" } })
R("basilisk", "basilisks", 5, "brute", "brute", "Basilisk", { s = 1.9, sp = { "gaze", "tail_sweep", "spit" }, b = { legs = 4, crest = true } })
R("elder_basilisk", "basilisks", 6, "brute", "brute", "Elder Basilisk", { s = 2.8, c = rgb(60, 80, 56), a = rgb(230, 200, 90), sp = { "gaze", "tail_sweep", "quake" }, b = { legs = 4, crest = true, spines = true } })

-- ── the table every other module reads ─────────────────────────────────────────
local AGGRO = { flier = 110, ranged = 100, caster = 100, swarm = 95, leader = 95 }
local RANGE = { ranged = 34, caster = 26, healer = 22, summoner = 24, leader = 0 }
Monsters.DEFS = {}
Monsters.KINDS = { {}, {}, {}, {}, {}, {} }
Monsters.FAMILIES = {}
Monsters.ORDER = {} -- every kind, in the order written (families together, E to S within one)
for _, o in ROWS do
	local fam = FAM[o.fam]
	assert(fam, "Monsters: unknown family " .. tostring(o.fam))
	local role = Monsters.ROLES[o.role]
	assert(role, "Monsters: unknown role " .. tostring(o.role))
	local fs = fam.stats or {}
	local r = o.rank
	local b = table.clone(fam.b or {})
	for k, v in o.b or {} do
		b[k] = v
	end
	local s = o.s or 1
	local hp = o.hp or math.max(20, math.floor(Monsters.RANK_HP[r] * role.hp * (fs.hp or 1) / 5 + 0.5) * 5)
	local dmg = o.dmg or math.floor(Monsters.RANK_DMG[r] * role.dmg * (fs.dmg or 1) * 2 + 0.5) / 2
	local speed = o.speed or math.clamp(16 + role.spd + (fs.spd or 0), 8, 30)
	local gait = o.gait or fam.gait
	local d = {
		id = o.id,
		name = o.name,
		rank = r,
		family = o.fam,
		role = o.role,
		beh = o.beh,
		hp = hp,
		dmg = dmg,
		speed = speed,
		size = s,
		gait = gait,
		c = o.c or fam.c,
		a = o.a or fam.a,
		eye = o.eye or fam.eye,
		b = b,
		x = b, -- (the old name for the body knobs)
		sp = o.sp or {},
		atk = o.atk or fam.atk or "swing",
		basic = o.basic,
		sum = o.sum,
		-- how close it must be to land a blow (the live city's old rule: 5 + twice its size)
		reach = 5 + s * 2,
		aggro = if o.beh == "brute" and s < 1 then 80 else AGGRO[o.beh] or (if o.fam == "slimes" then 60 else 90),
		cd = role.cd,
		range = (RANGE[o.beh] or 0) + (if RANGE[o.beh] then s * 2 else 0),
	}
	if table.find(d.sp, "ambush") then
		d.aggro = 14
	end
	Monsters.DEFS[o.id] = d
	table.insert(Monsters.KINDS[r], o.id)
	Monsters.FAMILIES[o.fam] = Monsters.FAMILIES[o.fam] or {}
	table.insert(Monsters.FAMILIES[o.fam], o.id)
	table.insert(Monsters.ORDER, o.id)
end
for _, list in Monsters.KINDS do
	table.sort(list)
end
Monsters.FAMILY_ORDER = {}
for id in Monsters.FAMILIES do
	table.insert(Monsters.FAMILY_ORDER, id)
end
table.sort(Monsters.FAMILY_ORDER)

-- ── a Gate's pack: one family, its ranks, a leader and its support ──────────────
-- Given the first kind a Gate lets out, the rest come from the same family: fighters of the
-- Gate's rank, a support (a shaman, a caster, an archer), the family's leader if it has one at
-- that rank, and weaker kin from the rank below. `rand(a, b)` is an integer in [a, b].
local SUPPORT = { healer = true, caster = true, ranged = true, summoner = true }
function Monsters.packFor(first: string, rank: number, n: number, rand: ((number, number) -> number)?): { string }
	local roll = rand or function(a: number, b: number): number
		return math.random(a, b)
	end
	local d0 = Monsters.DEFS[first]
	if not d0 then
		return {}
	end
	local core, minions, leaders, supports, fighters = {}, {}, {}, {}, {}
	for _, id in Monsters.FAMILIES[d0.family] do
		local d = Monsters.DEFS[id]
		if d.rank == rank then
			table.insert(core, id)
			if d.beh == "leader" then
				table.insert(leaders, id)
			elseif SUPPORT[d.beh] then
				table.insert(supports, id)
			else
				table.insert(fighters, id)
			end
		elseif d.rank == rank - 1 or (d.rank == rank - 2 and rank >= 3) then
			table.insert(minions, id)
		end
	end
	-- (weaker kin: the ones that fight; their shamans and leaders only if there's nobody else)
	local minionFighters, minionSupports = {}, {}
	for _, id in minions do
		local b = Monsters.DEFS[id].beh
		if SUPPORT[b] then
			table.insert(minionSupports, id)
		elseif b ~= "leader" then
			table.insert(minionFighters, id)
		end
	end
	if #minionFighters > 0 then
		minions = minionFighters
	end
	if #supports == 0 then
		supports = minionSupports
	end
	if #fighters == 0 then
		fighters = if #minions > 0 then minions else core
	end
	local function pick(list: { string }): string?
		if #list == 0 then
			return nil
		end
		return list[roll(1, #list)]
	end
	local out = { first }
	local usedLeader = d0.beh == "leader"
	local supportsUsed = if SUPPORT[d0.beh] then 1 else 0
	local healers = if d0.beh == "healer" then 1 else 0
	local i = 1
	while #out < n do
		i += 1
		local id: string?
		if i == 2 and #supports > 0 then
			id = pick(supports)
		elseif i == 3 and not usedLeader and #leaders > 0 then
			id = pick(leaders)
			usedLeader = true
		elseif i % 4 == 0 and #minions > 0 then
			id = pick(minions)
		elseif i % 5 == 0 and supportsUsed < 2 and #supports > 0 then
			id = pick(supports)
		else
			id = pick(fighters)
		end
		id = id or first
		local d = Monsters.DEFS[id :: string]
		if SUPPORT[d.beh] then
			if supportsUsed >= 2 or (d.beh == "healer" and healers >= 1) then
				id = pick(fighters) or first
				d = Monsters.DEFS[id :: string]
			else
				supportsUsed += 1
				if d.beh == "healer" then
					healers += 1
				end
			end
		end
		table.insert(out, id :: string)
	end
	return out
end

-- ══ building ═══════════════════════════════════════════════════════════════════
local MAT = Enum.Material
local SMOOTH, FABRIC, METAL, WOOD, SLATE, NEON, ICE, GLASS = MAT.SmoothPlastic, MAT.Fabric, MAT.Metal, MAT.Wood, MAT.Slate, MAT.Neon, MAT.Ice, MAT.Glass
local ROCK, LEAF, GRASS, CRACKED, SAND = MAT.Rock, MAT.LeafyGrass, MAT.Grass, MAT.CrackedLava, MAT.Sand
local WOODC, WOODC2, DARK = rgb(100, 72, 48), rgb(80, 58, 40), rgb(26, 22, 26)

-- Blender layouts (tools/blender/dump_layout) set this to see every part where its new mesh goes
Monsters.MESH_LAYOUT = false

-- the roles MeshLibrary knows (a MeshRole it doesn't know is ignored: the part keeps its
-- name's role). roleFor(a, b...) is the first of them it knows.
local DECLARED: { [string]: boolean } = {}
for _, r in MeshLibrary.ROLES do
	DECLARED[r] = true
end
local function roleFor(...: string): string?
	for _, r in { ... } do
		if DECLARED[r] or Monsters.MESH_LAYOUT then
			return r
		end
	end
	return nil
end
-- is that role's mesh in the place's kit right now? (a head mesh that brings its own ears,
-- beard, horns or mane is built as one box only when it is)
local function kitHas(r: string): boolean
	if Monsters.MESH_LAYOUT then
		return true
	end
	if not DECLARED[r] then
		return false
	end
	local ok, found = pcall(function()
		local kit = MeshLibrary.kit()
		return kit and kit:FindFirstChild(r, true)
	end)
	return ok and found ~= nil
end

local function A(x: number?, y: number?, z: number?): CFrame
	return CFrame.Angles(math.rad(x or 0), math.rad(y or 0), math.rad(z or 0))
end
local function shade(c: Color3, f: number): Color3
	return Color3.new(math.clamp(c.R * f, 0, 1), math.clamp(c.G * f, 0, 1), math.clamp(c.B * f, 0, 1))
end
local function mix(a: Color3, b: Color3, t: number): Color3
	return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end
Monsters.shade = shade

local function newPart(model: Model, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, shape: string?): BasePart
	local p: BasePart
	if shape == "wedge" then
		p = Instance.new("WedgePart")
	else
		local part = Instance.new("Part")
		if shape == "ball" then
			part.Shape = Enum.PartType.Ball
		elseif shape == "cyl" then
			part.Shape = Enum.PartType.Cylinder
		end
		p = part
	end
	p.Name = name
	p.Size = V(math.max(size.X, 0.05), math.max(size.Y, 0.05), math.max(size.Z, 0.05))
	p.CFrame = cf
	p.Color = color
	p.Material = material or SMOOTH
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end

local function weld(a: BasePart, b: BasePart)
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = b
end

type Ctx = { model: Model, root: BasePart, s: number, d: any, b: any, hip: number, hover: number, meshHead: boolean }

-- a part welded to `parent`, placed in the parent's own space (units: times the kind's size)
local function deco(ctx: Ctx, parent: BasePart, name: string, size: Vector3, pos: Vector3, color: Color3?, mat: Enum.Material?, shape: string?, rot: CFrame?, meshRole: string?): BasePart
	local s = ctx.s
	local p = newPart(ctx.model, name, size * s, parent.CFrame * CFrame.new(pos * s) * (rot or CFrame.identity), color or ctx.d.c, mat, shape)
	if meshRole then
		p:SetAttribute("MeshRole", meshRole)
	end
	weld(parent, p)
	return p
end

-- a part on a joint: the joint sits at `at` in the parent's space, turned by `rot`; the part
-- hangs from it by `hang` (in the joint's space). The Motor6D is named `jn` .. "Joint" (the
-- name MonsterAnim animates), which may differ from the part's name (the one meshes go by).
local function joint(ctx: Ctx, parent: BasePart, name: string, size: Vector3, at: Vector3, hang: Vector3, color: Color3?, mat: Enum.Material?, shape: string?, rot: CFrame?, meshRole: string?, jn: string?): BasePart
	local s = ctx.s
	local c0 = CFrame.new(at * s) * (rot or CFrame.identity)
	local p = newPart(ctx.model, name, size * s, parent.CFrame * c0 * CFrame.new(hang * s), color or ctx.d.c, mat, shape)
	if meshRole then
		p:SetAttribute("MeshRole", meshRole)
	end
	local m = Instance.new("Motor6D")
	m.Name = (jn or name) .. "Joint"
	m.Part0 = parent
	m.Part1 = p
	m.C0 = c0
	m.C1 = CFrame.new(-hang * s)
	m.Parent = parent
	return p
end

local function makeRoot(ctx: Ctx, size: Vector3, y: number)
	local s = ctx.s
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = size * s
	root.CFrame = CFrame.new(0, y * s, 0)
	root.Transparency = 1
	root.CanCollide = true
	root.Parent = ctx.model
	ctx.model.PrimaryPart = root
	ctx.root = root
	ctx.hip = y - size.Y / 2
end

local function eyes(ctx: Ctx, head: BasePart, pos: Vector3, r: number, color: Color3?, name: string?)
	for _, sd in { 1, -1 } do
		deco(ctx, head, name or "Eye", V(r, r, r), V(pos.X * sd, pos.Y, pos.Z), color or ctx.d.eye, NEON, "ball")
	end
end

-- a two-part leg that reaches the ground: the upper part on a joint, going out (and up or
-- down) from the body, the lower part welded at the knee, down to the foot
local function insectLeg(ctx: Ctx, parent: BasePart, jn: string, at: Vector3, sd: number, yaw: number, up: number, upper: number, w: number, color: Color3, groundY: number, splay: number?): BasePart
	local s = ctx.s
	-- the upper segment's direction (in the parent's space): out to the side, `up` degrees above level
	local rot = A(0, yaw * sd, 0) * A(0, 0, -sd * (90 - up))
	local legPart = joint(ctx, parent, jn, V(w, upper, w), at, V(0, upper / 2, 0), color, nil, nil, rot, roleFor("leg_insect"), jn)
	local knee = (legPart.CFrame * CFrame.new(0, upper / 2 * s, 0)).Position
	local outward = parent.CFrame:VectorToWorldSpace(A(0, yaw * sd, 0) * V(sd, 0, 0))
	local foot = V(knee.X, groundY * s, knee.Z) + outward * (splay or 0.6) * s
	local mid = (knee + foot) / 2
	local up_ = (knee - foot).Unit
	local right = up_:Cross(V(0, 0, 1))
	if right.Magnitude < 0.05 then
		right = V(1, 0, 0)
	end
	right = right.Unit
	local cf = CFrame.fromMatrix(mid, right, up_)
	local lower = newPart(ctx.model, "Shin", V(w * 0.8 * s, (knee - foot).Magnitude + w * 0.5 * s, w * 0.8 * s), cf, shade(color, 0.85), nil, nil)
	local r = roleFor("leg_insect")
	if r then
		lower:SetAttribute("MeshRole", r)
	end
	weld(legPart, lower)
	return legPart
end

-- ── humanoids: goblins to giants, elves, dwarves, orcs, demons, skeletons ────────────
local BUILDS = {
	slender = { leg = 2.4, legW = 0.46, tw = 1.4, th = 2.0, td = 0.8, arm = 2.3, armW = 0.4 },
	lean = { leg = 1.65, legW = 0.55, tw = 1.6, th = 1.75, td = 1.0, arm = 2.0, armW = 0.5 },
	normal = { leg = 2.0, legW = 0.8, tw = 2.0, th = 2.2, td = 1.1, arm = 2.2, armW = 0.72 },
	stocky = { leg = 1.3, legW = 0.85, tw = 2.4, th = 2.0, td = 1.45, arm = 1.9, armW = 0.8 },
	hulking = { leg = 2.0, legW = 1.15, tw = 2.9, th = 2.6, td = 1.7, arm = 2.9, armW = 1.05 },
	giant = { leg = 2.7, legW = 1.0, tw = 2.6, th = 2.8, td = 1.45, arm = 3.0, armW = 0.9 },
	skeletal = { leg = 2.1, legW = 0.3, tw = 1.5, th = 2.0, td = 0.85, arm = 2.2, armW = 0.28 },
}

-- what a humanoid wears, as colours and materials
local function palette(ctx: Ctx): any
	local b, d = ctx.b, ctx.d
	local skin = b.skin or d.c
	local o = b.outfit or "rags"
	local leather = b.leather or LEATHER
	local cloth = b.cloth or d.a
	local metal = b.metal or IRON
	local skinMat = if b.stony then SLATE else SMOOTH
	local p = {
		skin = skin, skinMat = skinMat, cloth = cloth, leather = leather, metal = metal, o = o,
		torso = skin, torsoM = skinMat, leg = skin, legM = skinMat, arm = skin, armM = skinMat, boot = shade(leather, 0.7),
	}
	if o == "plate" then
		p.torso, p.torsoM = metal, METAL
		p.leg, p.legM = shade(leather, 0.8), FABRIC
	elseif o == "armor_shell" then
		p.torso, p.torsoM, p.leg, p.legM, p.arm, p.armM, p.boot = metal, METAL, shade(metal, 0.9), METAL, metal, METAL, shade(metal, 0.8)
	elseif o == "leather" then
		p.torso, p.torsoM = leather, FABRIC
		p.leg, p.legM = shade(leather, 0.75), FABRIC
	elseif o == "robe" or o == "robe_tatters" then
		p.torso, p.torsoM, p.arm, p.armM, p.leg, p.legM = cloth, FABRIC, cloth, FABRIC, shade(cloth, 0.7), FABRIC
	elseif o == "tunic" then
		p.torso, p.torsoM = cloth, FABRIC
	elseif o == "bones" then
		p.torso, p.leg, p.arm = BONE, BONE, BONE
	end
	return p
end

-- a hood (open at the front), hair, a helmet, a crown or a circlet on a head of size sz
local function headgear(ctx: Ctx, head: BasePart, sz: Vector3, pal: any)
	local b, d = ctx.b, ctx.d
	local top = sz.Y / 2
	local hair = b.hair
	if hair and not b.hood and (b.helm == nil or b.helm == "none") then
		local st = b.hairStyle or "short"
		if st == "long" then
			deco(ctx, head, "Hair", V(sz.X * 1.06, 0.28, sz.Z * 1.06), V(0, top + 0.06, 0.03), hair)
			deco(ctx, head, "Hair", V(sz.X * 1.0, sz.Y * 1.45, 0.24), V(0, -0.22, sz.Z / 2 + 0.06), hair)
		elseif st == "topknot" then
			deco(ctx, head, "Hair", V(sz.X * 1.02, 0.18, sz.Z * 1.02), V(0, top + 0.04, 0), hair)
			deco(ctx, head, "Hair", V(0.45, 0.45, 0.45), V(0, top + 0.32, 0.12), hair, nil, "ball")
		elseif st == "mohawk" then
			deco(ctx, head, "Hair", V(0.22, 0.5, sz.Z * 1.1), V(0, top + 0.2, 0.05), hair)
		elseif st == "wild" then
			for k = 0, 4 do
				local a = k / 5 * math.pi * 2
				deco(ctx, head, "Hair", V(0.6, 0.6, 0.6), V(math.cos(a) * sz.X * 0.36, top + 0.08 - (k % 2) * 0.15, math.sin(a) * sz.Z * 0.3 + 0.12), hair, nil, "ball")
			end
		else
			deco(ctx, head, "Hair", V(sz.X * 1.04, 0.22, sz.Z * 1.04), V(0, top + 0.04, 0.02), hair)
		end
	end
	if b.hood then
		local hc = if b.cloak then b.cloak elseif pal.o == "robe" or pal.o == "robe_tatters" then pal.cloth else shade(pal.leather, 0.85)
		deco(ctx, head, "HoodTop", V(sz.X * 1.22, 0.28, sz.Z * 1.2), V(0, top + 0.1, 0.04), hc, FABRIC)
		deco(ctx, head, "HoodBack", V(sz.X * 1.22, sz.Y * 1.15, 0.22), V(0, -0.02, sz.Z / 2 + 0.1), hc, FABRIC)
		for _, sd in { 1, -1 } do
			deco(ctx, head, "HoodSide", V(0.16, sz.Y * 1.05, sz.Z * 1.0), V(sd * (sz.X / 2 + 0.08), 0, 0.06), hc, FABRIC)
		end
	end
	local helm = b.helm
	local metal = b.metal or IRON
	if helm == "dwarf" or helm == "horned" or helm == "miner" or helm == "crest" then
		deco(ctx, head, "Helm", V(sz.X * 1.12, 0.55, sz.Z * 1.12), V(0, top + 0.02, 0.02), metal, METAL, nil, nil, roleFor("helm"))
		deco(ctx, head, "HelmRim", V(sz.X * 1.2, 0.12, sz.Z * 1.2), V(0, top - 0.22, 0.02), shade(metal, 0.8), METAL)
		if helm == "dwarf" then
			deco(ctx, head, "NoseGuard", V(0.12, 0.42, 0.1), V(0, top - 0.42, -sz.Z / 2 - 0.06), shade(metal, 0.8), METAL)
			for _, sd in { 1, -1 } do
				deco(ctx, head, "Horn", V(0.16, 0.5, 0.16), V(sd * sz.X * 0.58, top + 0.12, 0.05), BONE, nil, nil, A(0, 0, -sd * 55))
			end
		elseif helm == "horned" then
			for _, sd in { 1, -1 } do
				deco(ctx, head, "Horn", V(0.24, 1.0, 0.24), V(sd * sz.X * 0.62, top + 0.35, 0.05), BONE, nil, nil, A(-10, 0, -sd * 42))
			end
		elseif helm == "miner" then
			deco(ctx, head, "Lamp", V(0.32, 0.3, 0.14), V(0, top + 0.02, -sz.Z / 2 - 0.1), rgb(255, 236, 160), NEON)
		elseif helm == "crest" then
			deco(ctx, head, "Crest", V(0.16, 0.55, sz.Z * 1.25), V(0, top + 0.45, 0.05), b.trim or d.a, FABRIC)
		end
	end
	if b.crown then
		deco(ctx, head, "Crown", V(sz.X * 1.02, 0.36, sz.Z * 1.02), V(0, top + 0.16, 0), GOLD, METAL, nil, nil, roleFor("crown"))
		for k = -1, 1 do
			deco(ctx, head, "Spike", V(0.12, 0.4, 0.12), V(k * sz.X * 0.32, top + 0.45, -sz.Z * 0.45), GOLD, METAL)
		end
	elseif b.circlet then
		deco(ctx, head, "Circlet", V(sz.X * 1.05, 0.1, sz.Z * 1.05), V(0, sz.Y * 0.22, 0), rgb(220, 226, 236), METAL)
		deco(ctx, head, "Gem", V(0.16, 0.16, 0.16), V(0, sz.Y * 0.22, -sz.Z / 2 - 0.04), d.eye, NEON, "ball")
	end
	if b.feathers then
		for k = -1, 1 do
			deco(ctx, head, "Feather", V(0.08, 0.75, 0.22), V(k * 0.22, top + 0.25, 0.25), if k == 0 then rgb(220, 60, 50) else rgb(240, 220, 120), nil, nil, A(-20, 0, k * 18))
		end
	end
end

-- the heads: a dozen shapes, each with its face, ears, horns, beard
local HEADS: { [string]: any } = {}
HEADS.goblin = { size = V(1.2, 1.0, 1.0), deco = function(ctx, h, sz, pal)
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Ear", V(1.0, 0.16, 0.42), V(sd * 0.86, 0.12, 0.05), pal.skin, nil, nil, A(0, -sd * 15, sd * 18))
	end
	deco(ctx, h, "Nose", V(0.22, 0.24, 0.55), V(0, -0.05, -0.62), shade(pal.skin, 0.9))
	eyes(ctx, h, V(0.27, 0.13, -0.5), 0.22)
	deco(ctx, h, "Mouth", V(0.62, 0.07, 0.05), V(0, -0.3, -0.51), DARK)
end }
HEADS.kobold = { size = V(0.72, 0.68, 0.8), deco = function(ctx, h, sz, pal)
	-- a long, flat lizard-dog snout, horns swept back, a fan of frills
	deco(ctx, h, "Snout", V(0.5, 0.34, 0.95), V(0, -0.14, -0.8), pal.skin)
	deco(ctx, h, "Nose", V(0.3, 0.12, 0.1), V(0, 0.02, -1.25), DARK)
	deco(ctx, h, "Jaw", V(0.42, 0.14, 0.85), V(0, -0.33, -0.72), shade(pal.skin, 0.85))
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Horn", V(0.12, 0.65, 0.12), V(sd * 0.22, 0.38, 0.3), rgb(230, 220, 190), nil, nil, A(-68, 0, -sd * 12))
		deco(ctx, h, "Frill", V(0.5, 0.08, 0.36), V(sd * 0.45, 0.05, 0.15), ctx.b.belly or shade(pal.skin, 0.8), nil, nil, A(0, -sd * 25, sd * 30))
	end
	eyes(ctx, h, V(0.27, 0.12, -0.34), 0.17)
end }
HEADS.orc = { size = V(1.25, 1.15, 1.15), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Jaw", V(1.05, 0.42, 0.55), V(0, -0.5, -0.32), shade(pal.skin, 0.95))
	deco(ctx, h, "Brow", V(1.25, 0.22, 0.3), V(0, 0.22, -0.5), shade(pal.skin, 0.8))
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Tusk", V(0.14, 0.42, 0.14), V(sd * 0.3, -0.26, -0.62), BONE, nil, nil, A(0, 0, -sd * 8))
		deco(ctx, h, "Ear", V(0.42, 0.16, 0.26), V(sd * 0.68, 0.08, 0), pal.skin, nil, nil, A(0, -sd * 20, sd * 12))
	end
	eyes(ctx, h, V(0.28, 0.05, -0.56), 0.18)
	if ctx.b.paint then
		deco(ctx, h, "Paint", V(1.0, 0.14, 0.04), V(0, -0.08, -0.58), ctx.b.paint)
	end
end }
HEADS.ogre = { size = V(1.3, 1.15, 1.2), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Jaw", V(1.35, 0.5, 0.75), V(0, -0.5, -0.3), shade(pal.skin, 0.95))
	deco(ctx, h, "Brow", V(1.2, 0.2, 0.32), V(0, 0.2, -0.55), shade(pal.skin, 0.8))
	deco(ctx, h, "Nose", V(0.36, 0.36, 0.36), V(0, -0.02, -0.66), shade(pal.skin, 0.9), nil, "ball")
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Tusk", V(0.16, 0.45, 0.16), V(sd * 0.42, -0.12, -0.66), BONE)
		deco(ctx, h, "Ear", V(0.36, 0.26, 0.2), V(sd * 0.7, 0, 0), pal.skin)
	end
	eyes(ctx, h, V(0.25, 0.08, -0.58), 0.15)
end }
HEADS.troll = { size = V(1.0, 1.1, 1.1), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Nose", V(0.3, 0.75, 0.35), V(0, -0.15, -0.64), shade(pal.skin, 0.9), nil, nil, A(25, 0, 0))
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Ear", V(0.85, 0.16, 0.3), V(sd * 0.7, 0.05, 0.05), pal.skin, nil, nil, A(0, -sd * 10, -sd * 28))
		deco(ctx, h, "Tusk", V(0.11, 0.28, 0.11), V(sd * 0.25, -0.45, -0.55), BONE)
	end
	eyes(ctx, h, V(0.27, 0.15, -0.56), 0.16)
end }
HEADS.human = { size = V(1.05, 1.2, 1.1), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Nose", V(0.24, 0.3, 0.3), V(0, -0.05, -0.6), shade(pal.skin, 0.92))
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Ear", V(0.2, 0.35, 0.25), V(sd * 0.55, 0, 0), pal.skin)
	end
	eyes(ctx, h, V(0.25, 0.12, -0.55), 0.15)
	if ctx.b.beard then
		deco(ctx, h, "Beard", V(1.1, 1.0, 0.4), V(0, -0.72, -0.42), ctx.b.beard, nil, nil, nil, roleFor("beard"))
		deco(ctx, h, "Moustache", V(0.8, 0.18, 0.2), V(0, -0.3, -0.6), ctx.b.beard)
	end
	if ctx.b.stony then
		deco(ctx, h, "Brow", V(1.1, 0.25, 0.3), V(0, 0.22, -0.48), shade(pal.skin, 0.8), SLATE)
	end
end }
HEADS.lizard = { size = V(0.95, 0.9, 1.15), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Snout", V(0.72, 0.5, 0.95), V(0, -0.15, -0.95), pal.skin)
	deco(ctx, h, "Crest", V(0.12, 0.5, 1.1), V(0, 0.55, 0.15), ctx.d.a)
	eyes(ctx, h, V(0.42, 0.15, -0.32), 0.19)
end }
HEADS.croc = { size = V(1.05, 0.85, 1.2), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Snout", V(0.95, 0.45, 1.6), V(0, -0.18, -1.3), pal.skin)
	deco(ctx, h, "Teeth", V(0.85, 0.08, 1.3), V(0, -0.38, -1.25), BONE)
	eyes(ctx, h, V(0.3, 0.42, -0.3), 0.2)
end }
HEADS.bull = { size = V(1.25, 1.2, 1.25), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Snout", V(0.95, 0.75, 0.65), V(0, -0.3, -0.78), shade(pal.skin, 0.8))
	deco(ctx, h, "Ring", V(0.08, 0.4, 0.4), V(0, -0.62, -1.12), GOLD, METAL, "cyl", A(0, 90, 0))
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Horn", V(0.3, 1.35, 0.3), V(sd * 0.78, 0.45, -0.1), ctx.d.a, nil, nil, A(0, 0, -sd * 62))
		deco(ctx, h, "Horn", V(0.2, 0.7, 0.2), V(sd * 1.35, 0.95, -0.15), ctx.d.a, nil, nil, A(0, 0, -sd * 15))
		deco(ctx, h, "Ear", V(0.5, 0.18, 0.3), V(sd * 0.75, 0.1, 0.12), pal.skin)
	end
	eyes(ctx, h, V(0.34, 0.15, -0.6), 0.16)
end }
HEADS.skull = { name = "Skull", color = BONE, role = function()
	return roleFor("skull")
end, size = V(0.9, 1.0, 0.95), deco = function(ctx, h, sz, pal)
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Socket", V(0.26, 0.24, 0.06), V(sd * 0.2, 0.08, -0.47), DARK)
	end
	eyes(ctx, h, V(0.2, 0.08, -0.46), 0.13)
	deco(ctx, h, "Jaw", V(0.66, 0.24, 0.5), V(0, -0.6, -0.16), shade(BONE, 0.92))
end }
HEADS.ghoul = { size = V(0.9, 1.05, 0.95), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Jaw", V(0.7, 0.28, 0.5), V(0, -0.58, -0.18), shade(pal.skin, 0.85))
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Ear", V(0.42, 0.12, 0.2), V(sd * 0.5, 0.15, 0.05), pal.skin, nil, nil, A(0, 0, sd * 20))
	end
	eyes(ctx, h, V(0.22, 0.1, -0.47), 0.16)
end }
HEADS.draconic = { size = V(0.95, 0.9, 1.2), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Snout", V(0.7, 0.5, 1.0), V(0, -0.12, -1.0), pal.skin)
	deco(ctx, h, "Crest", V(0.12, 0.42, 0.8), V(0, 0.5, 0.2), ctx.d.a)
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Horn", V(0.18, 0.95, 0.18), V(sd * 0.3, 0.45, 0.4), ctx.d.a, nil, nil, A(62, 0, -sd * 10))
	end
	eyes(ctx, h, V(0.36, 0.15, -0.45), 0.17)
end }
HEADS.naga = { size = V(0.85, 0.85, 1.0), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Snout", V(0.6, 0.4, 0.6), V(0, -0.12, -0.72), pal.skin)
	deco(ctx, h, "Flare", V(1.9, 1.7, 0.16), V(0, 0.05, 0.5), ctx.d.a)
	deco(ctx, h, "FlareMark", V(0.9, 0.9, 0.04), V(0, 0.1, 0.6), shade(ctx.d.c, 0.6))
	eyes(ctx, h, V(0.3, 0.12, -0.45), 0.17)
end }
HEADS.fish = { size = V(0.95, 1.05, 1.0), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Fin", V(0.12, 0.8, 1.1), V(0, 0.75, 0.1), ctx.d.a, nil, nil, nil, roleFor("fin"))
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Fin", V(0.1, 0.5, 0.6), V(sd * 0.56, 0, 0.1), ctx.d.a, nil, nil, A(0, 0, -sd * 60), roleFor("fin"))
	end
	eyes(ctx, h, V(0.3, 0.12, -0.5), 0.22)
	deco(ctx, h, "Mouth", V(0.5, 0.08, 0.05), V(0, -0.32, -0.5), DARK)
end }
HEADS.bird = { size = V(0.85, 0.9, 0.95), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Beak", V(0.3, 0.26, 0.6), V(0, -0.1, -0.72), rgb(230, 190, 80))
	deco(ctx, h, "Crest", V(0.1, 0.6, 0.5), V(0, 0.58, 0.2), ctx.d.a, nil, nil, A(-25, 0, 0))
	eyes(ctx, h, V(0.3, 0.12, -0.4), 0.17)
end }
HEADS.helm = { color = function(ctx)
	return ctx.b.metal or ctx.d.c
end, mat = METAL, role = function()
	return roleFor("helm")
end, size = V(1.05, 1.2, 1.1), deco = function(ctx, h, sz, pal)
	deco(ctx, h, "Visor", V(0.74, 0.11, 0.06), V(0, 0.1, -0.57), ctx.b.visor or ctx.d.eye, NEON)
	deco(ctx, h, "Ridge", V(0.14, 0.2, sz.Z * 1.04), V(0, sz.Y / 2 + 0.06, 0), shade(ctx.b.metal or ctx.d.c, 0.8), METAL)
end }
HEADS.mushroom = { size = V(0.9, 0.75, 0.9), deco = function(ctx, h, sz, pal)
	local cap = deco(ctx, h, "Cap", V(2.3, 0.8, 2.3), V(0, 0.65, 0.05), ctx.d.a, nil, nil, nil, roleFor("shell_dome"))
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		deco(ctx, cap, "Spot", V(0.3, 0.3, 0.3), V(math.cos(a) * 0.75, 0.38, math.sin(a) * 0.75), rgb(245, 240, 225), nil, "ball")
	end
	eyes(ctx, h, V(0.2, 0, -0.44), 0.14)
end }
-- (the heads whose new mesh carries more than the head: built as one box when the kit has it)
HEADS.elf = { size = V(0.85, 1.05, 0.92), deco = function(ctx, h, sz, pal)
	if not ctx.meshHead then
		for _, sd in { 1, -1 } do
			deco(ctx, h, "Ear", V(1.0, 0.14, 0.3), V(sd * 0.72, 0.18, 0.12), pal.skin, nil, nil, A(0, -sd * 20, sd * 26))
		end
	end
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Eye", V(0.2, 0.07, 0.06), V(sd * 0.19, 0.05, -sz.Z / 2 - 0.01), ctx.d.eye, NEON)
	end
end, mesh = "head_elf", meshSize = V(2.1, 1.05, 0.95) }
HEADS.dwarf = { size = V(1.2, 1.15, 1.15), deco = function(ctx, h, sz, pal)
	local hair = ctx.b.hair or rgb(150, 70, 36)
	local y0 = if ctx.meshHead then sz.Y / 2 - 0.6 else 0 -- the face's height in the box
	deco(ctx, h, "Nose", V(0.4, 0.4, 0.4), V(0, y0 - 0.02, -sz.Z / 2 - 0.05), shade(pal.skin, 0.92), nil, "ball")
	eyes(ctx, h, V(0.26, y0 + 0.16, -sz.Z / 2 + 0.03), 0.14)
	if not ctx.meshHead then
		deco(ctx, h, "Beard", V(1.25, 1.3, 0.36), V(0, -0.85, -0.5), hair, nil, nil, nil, roleFor("beard"))
		deco(ctx, h, "Moustache", V(0.95, 0.22, 0.25), V(0, -0.28, -0.6), hair)
		for _, sd in { 1, -1 } do
			deco(ctx, h, "Braid", V(0.2, 0.55, 0.2), V(sd * 0.38, -1.55, -0.52), shade(hair, 0.9))
			deco(ctx, h, "Bead", V(0.24, 0.16, 0.24), V(sd * 0.38, -1.82, -0.52), GOLD, METAL)
		end
	end
end, mesh = "head_dwarf", meshSize = V(1.25, 2.1, 1.3) }
HEADS.demon = { size = V(1.1, 1.15, 1.1), deco = function(ctx, h, sz, pal)
	local y0 = if ctx.meshHead then -sz.Y / 2 + 0.55 else 0
	if not ctx.meshHead then
		for _, sd in { 1, -1 } do
			local horn = deco(ctx, h, "Horn", V(0.26, 1.0, 0.26), V(sd * 0.42, 0.75, 0.05), ctx.d.a, nil, nil, A(-25, 0, -sd * 28))
			deco(ctx, horn, "HornTip", V(0.16, 0.65, 0.16), V(0, 0.65, 0.18), ctx.d.a, nil, nil, A(-40, 0, 0))
		end
	end
	for _, sd in { 1, -1 } do
		deco(ctx, h, "Fang", V(0.1, 0.25, 0.1), V(sd * 0.16, y0 - 0.42, -sz.Z / 2 + 0.01), BONE)
		deco(ctx, h, "Ear", V(0.5, 0.14, 0.25), V(sd * (sz.X / 2 + 0.1), y0 + 0.1, 0), pal.skin, nil, nil, A(0, -sd * 20, sd * 15))
	end
	eyes(ctx, h, V(0.26, y0 + 0.12, -sz.Z / 2 + 0.02), 0.17)
end, mesh = "head_demon", meshSize = V(1.5, 1.9, 1.2) }
HEADS.lycan = { size = V(1.0, 0.95, 1.05), role = function()
	return roleFor("head_beast")
end, deco = function(ctx, h, sz, pal)
	if not ctx.meshHead then
		-- a wolf's head: a long muzzle, a dark nose, tall ears, a ruff of fur behind
		deco(ctx, h, "Snout", V(0.5, 0.42, 1.05), V(0, -0.18, -0.95), pal.skin)
		deco(ctx, h, "Nose", V(0.3, 0.16, 0.12), V(0, 0.0, -1.47), DARK)
		deco(ctx, h, "Jaw", V(0.44, 0.16, 0.9), V(0, -0.42, -0.85), shade(pal.skin, 0.8))
		for _, sd in { 1, -1 } do
			deco(ctx, h, "Ear", V(0.28, 0.72, 0.18), V(sd * 0.3, 0.7, 0.12), pal.skin, nil, nil, A(-10, 0, -sd * 14))
			deco(ctx, h, "Fang", V(0.08, 0.2, 0.08), V(sd * 0.15, -0.38, -1.3), BONE)
		end
		deco(ctx, h, "Mane", V(1.5, 1.2, 0.8), V(0, -0.15, 0.45), shade(pal.skin, 0.75), FABRIC, nil, nil, roleFor("mane"))
		eyes(ctx, h, V(0.26, 0.12, -0.52), 0.15)
	else
		eyes(ctx, h, V(0.3, 0.12, -sz.Z / 2 + 0.1), 0.17)
	end
end, mesh = "head_beast_maned", meshSize = V(1.8, 1.7, 1.9) }
Monsters.HEADS = HEADS

-- a head on a joint at the top of the torso
local function headOn(ctx: Ctx, torso: BasePart, at: Vector3, hunch: number, pal: any): BasePart
	local b = ctx.b
	local kind = b.head or "human"
	local H = HEADS[kind] or HEADS.human
	ctx.meshHead = H.mesh ~= nil and kitHas(H.mesh)
	local sz = (if ctx.meshHead then H.meshSize else H.size) * (b.headScale or 1)
	local role = if ctx.meshHead then H.mesh elseif H.role then H.role() else roleFor("head_biped")
	local color = if type(H.color) == "function" then H.color(ctx) elseif H.color then H.color else pal.skin
	-- (a box that holds a beard hangs lower; one that holds horns rises higher)
	local lift = if ctx.meshHead and kind == "dwarf" then sz.Y / 2 - 0.95 elseif ctx.meshHead and kind == "demon" then sz.Y / 2 - 0.55 else sz.Y / 2 - 0.05
	local head = joint(ctx, torso, H.name or "Head", sz, at, V(0, lift, -0.05), color, H.mat or pal.skinMat, nil, A(hunch, 0, 0), role, "Head")
	H.deco(ctx, head, sz, pal)
	if ctx.meshHead and kind == "dwarf" then
		-- (the helmet sits on the head, not on top of the beard's box)
		local cap = V(sz.X, 1.2, sz.Z)
		local top = deco(ctx, head, "HeadTop", V(0.1, 0.1, 0.1), V(0, sz.Y / 2 - 0.6, 0), pal.skin)
		top.Transparency = 1
		headgear(ctx, top, cap, pal)
	else
		headgear(ctx, head, sz, pal)
	end
	if b.scar then
		deco(ctx, head, "Scar", V(0.06, 0.5, 0.04), V(sz.X * 0.22, 0.1, -sz.Z / 2 - 0.01), rgb(230, 200, 190), nil, nil, A(0, 0, 25))
	end
	return head
end

-- ── what a hand holds ────────────────────────────────────────────────────────
-- Built in the arm's space: the grip at the hand, the weapon pointing forward and a little up
-- (an overhead swing carries it back over the shoulder, the strike brings it down in front).
local function held(ctx: Ctx, arm: BasePart, kind: string, P: any, sd: number)
	local b, d = ctx.b, ctx.d
	local big = if b.big then 1.35 else 1
	local g = V(0, -P.arm / 2 + 0.05, -P.armW * 0.15)
	local tilt = A(18, 0, 0)
	local metal = if b.iceWeapon then rgb(190, 230, 255) elseif b.rusty then rgb(130, 96, 70) else STEEL
	local metalM = if b.iceWeapon then ICE else METAL
	local function at(t: number, y: number?, x: number?): Vector3
		return g + tilt * V(x or 0, y or 0, -t)
	end
	local function piece(name: string, size: Vector3, t: number, color: Color3, mat: Enum.Material?, shape: string?, extra: CFrame?, role: string?, y: number?, x: number?): BasePart
		return deco(ctx, arm, name, size, at(t, y, x), color, mat, shape, tilt * (extra or CFrame.identity), role)
	end
	if kind == "club" then
		piece("Club", V(0.32, 0.32, 1.9) * big, 0.6 * big, WOODC, WOOD)
		piece("ClubHead", V(0.62, 0.62, 0.85) * big, 1.6 * big, WOODC2, WOOD)
	elseif kind == "greatclub" then
		piece("Club", V(0.5, 0.5, 2.8), 1.0, WOODC, WOOD)
		local head = piece("ClubHead", V(1.0, 1.0, 1.4), 2.6, WOODC2, WOOD)
		for k = 0, 3 do
			deco(ctx, head, "Spike", V(0.14, 0.45, 0.14), V(math.cos(k * 1.57) * 0.5, math.sin(k * 1.57) * 0.5, 0), STEEL, METAL, nil, A(0, 0, k * 90 - 90))
		end
	elseif kind == "axe" or kind == "pick" or kind == "cleaver" then
		piece("Haft", V(0.22, 0.22, 2.3) * big, 0.8 * big, WOODC, WOOD)
		if kind == "pick" then
			piece("PickHead", V(0.16, 1.5, 0.22) * big, 1.85 * big, IRON, METAL, nil, A(0, 0, 0))
		else
			piece("Blade", V(0.12, 1.05, 0.85) * big, 1.75 * big, metal, metalM, nil, nil, nil, 0.3 * big)
		end
	elseif kind == "greataxe" then
		piece("Haft", V(0.28, 0.28, 3.4), 1.2, WOODC, WOOD)
		piece("AxeHead", V(0.14, 1.7, 1.25), 2.55, metal, metalM, nil, nil, roleFor("axe_double"))
	elseif kind == "hammer" then
		piece("Haft", V(0.25, 0.25, 2.6) * big, 1.0 * big, WOODC, WOOD)
		local head = piece("HammerHead", V(0.8, 0.8, 1.4) * big, 2.25 * big, b.metal or IRON, METAL, nil, A(90, 0, 0), roleFor("hammer_head"))
		if b.runes or b.forge then
			deco(ctx, head, "Rune", V(0.84, 0.84, 0.2), V(0, 0, 0), b.runes or rgb(255, 140, 40), NEON)
		end
	elseif kind == "spear" or kind == "javelin" or kind == "lance" or kind == "glaive" then
		local len = if kind == "lance" then 6 elseif kind == "javelin" then 3.2 else 4.2
		local w = if kind == "lance" then 0.26 elseif kind == "javelin" then 0.13 else 0.17
		piece("Shaft", V(w, w, len), len * 0.32, if b.iceWeapon then rgb(170, 210, 240) else WOODC, if b.iceWeapon then ICE else WOOD)
		if kind == "glaive" then
			piece("Blade", V(0.1, 0.4, 1.6), len * 0.82 + 0.55, metal, metalM, nil, nil, roleFor("blade_curved"), 0.15)
		elseif kind == "lance" then
			piece("Guard", V(0.9, 0.9, 0.2), 0.6, metal, metalM, "cyl", A(0, 90, 0))
			piece("Point", V(0.18, 0.4, 1.2), len * 0.82 + 0.3, metal, metalM)
		else
			piece("Point", V(0.12, 0.4, 0.75), len * 0.82 + 0.1, metal, metalM)
		end
	elseif kind == "trident" then
		piece("Shaft", V(0.18, 0.18, 4.2), 1.35, rgb(60, 70, 80), METAL)
		piece("Prongs", V(0.12, 1.1, 0.9), 3.9, GOLD, METAL, nil, A(-90, 0, 0), roleFor("trident_head"))
	elseif kind == "sword" or kind == "scimitar" or kind == "dagger" or kind == "greatsword" then
		local len = if kind == "greatsword" then 3.4 elseif kind == "dagger" then 0.9 else 2.3
		local wid = if kind == "greatsword" then 0.55 elseif kind == "dagger" then 0.22 else 0.34
		local role = if kind == "scimitar" then roleFor("blade_curved") elseif kind == "greatsword" then roleFor("blade_wide", "blade") else roleFor("blade")
		piece("Grip", V(0.15, 0.15, 0.55), 0.05, DARKLEATHER)
		piece("Guard", V(if kind == "dagger" then 0.45 else wid * 2.4, 0.15, 0.18), 0.38, if b.flame then rgb(60, 30, 30) else GOLD, METAL)
		local blade = piece("Blade", V(0.11, wid, len), 0.45 + len / 2, metal, metalM, nil, nil, role)
		if b.flame then
			deco(ctx, blade, "Flame", V(0.16, wid * 0.6, len * 0.95), V(0, 0, 0), rgb(255, 120, 40), NEON)
		end
	elseif kind == "staff" then
		local top = b.staffTop or "orb"
		local shaft = deco(ctx, arm, "Shaft", V(0.2, 5.2, 0.2), g + V(0, 0.9, -0.45), WOODC2, WOOD)
		local tipY = 2.6
		if top == "crystal" then
			deco(ctx, shaft, "Crystal", V(0.5, 1.1, 0.5), V(0, tipY + 0.4, 0), d.eye, NEON, nil, nil, roleFor("crystal_cluster"))
		elseif top == "skull" then
			deco(ctx, shaft, "StaffSkull", V(0.6, 0.65, 0.6), V(0, tipY + 0.2, 0), BONE)
			deco(ctx, shaft, "Glow", V(0.25, 0.25, 0.25), V(0, tipY + 0.25, -0.3), d.eye, NEON, "ball")
		elseif top == "crescent" then
			deco(ctx, shaft, "Crescent", V(0.15, 0.9, 1.1), V(0, tipY + 0.35, 0), rgb(220, 226, 236), METAL, nil, nil, roleFor("staff_crescent"))
			deco(ctx, shaft, "Glow", V(0.3, 0.3, 0.3), V(0, tipY + 0.35, 0), d.eye, NEON, "ball")
		elseif top == "leaf" then
			deco(ctx, shaft, "Leaves", V(0.9, 0.8, 0.9), V(0, tipY + 0.3, 0), rgb(80, 150, 60), LEAF)
			deco(ctx, shaft, "Glow", V(0.3, 0.3, 0.3), V(0, tipY + 0.4, -0.3), d.eye, NEON, "ball")
		else
			deco(ctx, shaft, "Cage", V(0.75, 0.75, 0.75), V(0, tipY + 0.3, 0), GOLD, METAL, nil, nil, roleFor("orb_cage"))
			deco(ctx, shaft, "Orb", V(0.55, 0.55, 0.55), V(0, tipY + 0.3, 0), d.eye, NEON, "ball")
		end
	elseif kind == "bow" then
		-- (along the arm's forward axis: upright when the arm comes up to shoot)
		local wood = if b.iceWeapon then rgb(200, 230, 255) else WOODC
		local mat = if b.iceWeapon then ICE else WOOD
		deco(ctx, arm, "BowGrip", V(0.2, 0.2, 0.55), g + V(0, 0, -0.1), DARKLEATHER)
		deco(ctx, arm, "BowLimb", V(0.12, 0.14, 1.45), g + V(0, 0.2, -0.95), wood, mat, nil, A(-14, 0, 0))
		deco(ctx, arm, "BowLimb", V(0.12, 0.14, 1.45), g + V(0, 0.2, 0.75), wood, mat, nil, A(14, 0, 0))
		deco(ctx, arm, "String", V(0.04, 0.04, 3.1), g + V(0, 0.48, -0.1), rgb(230, 226, 210))
	elseif kind == "crossbow" then
		piece("Stock", V(0.26, 0.3, 1.7), 0.4, WOODC2, WOOD)
		piece("Prod", V(1.7, 0.14, 0.18), 1.1, IRON, METAL)
		piece("Bolt", V(0.08, 0.08, 1.0), 0.9, STEEL, METAL, nil, nil, nil, 0.18)
	elseif kind == "sling" then
		deco(ctx, arm, "Cord", V(0.06, 1.2, 0.06), g + V(0, -0.55, 0), rgb(150, 120, 90))
		deco(ctx, arm, "Pouch", V(0.3, 0.3, 0.3), g + V(0, -1.15, 0), LEATHER, FABRIC, "ball")
	elseif kind == "whip" then
		deco(ctx, arm, "Whip", V(0.1, 2.6, 0.1), g + V(0, -1.2, -0.3), DARKLEATHER, nil, nil, A(15, 0, 0))
	elseif kind == "shield_round" or kind == "shield_kite" or kind == "shield_tower" then
		local sz = if kind == "shield_tower" then V(0.3, 3.0, 1.7) elseif kind == "shield_kite" then V(0.22, 2.4, 1.5) else V(0.22, 1.9, 1.9)
		local shield = deco(ctx, arm, "Shield", sz, V(-sd * 0.1, -P.arm * 0.12, -P.armW * 0.5 - 0.2), if b.rusty then rgb(110, 90, 70) else b.metal or rgb(110, 80, 56), if b.metal then METAL else WOOD, if kind == "shield_round" then "cyl" else nil, A(0, 90, 0), roleFor(kind))
		deco(ctx, shield, "Boss", V(0.4, 0.4, 0.4), V(0.15, 0, 0), STEEL, METAL, "ball")
	end
end

-- ── a humanoid's legs, torso, arms and head (also the upper half of a centaur, a naga...) ──
local function humanLegs(ctx: Ctx, parent: BasePart, hip: Vector3, P: any, pal: any)
	local b = ctx.b
	local skeletal = pal.o == "bones"
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "LegR" else "LegL"
		local leg
		if skeletal then
			leg = joint(ctx, parent, "Bone" .. nm, V(P.legW, P.leg, P.legW), hip + V(sd * P.tw * 0.24, 0, 0), V(0, -P.leg / 2, 0), BONE, nil, nil, nil, roleFor("bone_limb"), nm)
			deco(ctx, leg, "Knee", V(P.legW * 1.6, P.legW * 1.6, P.legW * 1.6), V(0, 0, 0), BONE, nil, "ball")
		else
			leg = joint(ctx, parent, nm, V(P.legW, P.leg, P.legW * 1.05), hip + V(sd * P.tw * 0.26, 0, 0), V(0, -P.leg / 2, 0), pal.leg, pal.legM, nil, nil, nil, nm)
		end
		if b.digitigrade then
			deco(ctx, leg, "Hoof", V(P.legW * 1.15, 0.4, P.legW * 1.2), V(0, -P.leg / 2 + 0.2, -0.05), DARK)
		elseif not skeletal then
			deco(ctx, leg, "Foot", V(P.legW * 1.15, 0.28, P.legW * 1.6), V(0, -P.leg / 2 + 0.14, -P.legW * 0.3), pal.boot)
		else
			deco(ctx, leg, "Foot", V(P.legW * 1.5, 0.2, P.legW * 2.6), V(0, -P.leg / 2 + 0.1, -P.legW * 0.6), BONE)
		end
		if pal.o == "plate" or pal.o == "armor_shell" then
			deco(ctx, leg, "Greave", V(P.legW * 1.15, P.leg * 0.45, P.legW * 1.2), V(0, -P.leg * 0.18, 0), pal.metal, METAL)
		elseif pal.o == "fur" then
			deco(ctx, leg, "FurBoot", V(P.legW * 1.25, P.leg * 0.35, P.legW * 1.3), V(0, -P.leg * 0.3, 0), rgb(220, 210, 190), FABRIC)
		end
	end
end

-- returns torso, head, armR, armL (and a second pair on a four-armed naga)
local function upperBody(ctx: Ctx, parent: BasePart, waist: Vector3, P: any, pal: any, hunch: number): (BasePart, BasePart, BasePart, BasePart)
	local b, d = ctx.b, ctx.d
	local tw, th, td = P.tw, P.th, P.td
	local skeletal = pal.o == "bones"
	local robed = pal.o == "robe" or pal.o == "robe_tatters"
	local torso
	if skeletal then
		torso = joint(ctx, parent, "Ribs", V(tw * 0.85, th * 0.85, td), waist + V(0, 0.15, 0), V(0, th * 0.425, 0), BONE, nil, nil, A(-hunch), roleFor("ribcage"), "Torso")
		deco(ctx, torso, "Spine", V(0.26, th * 1.05, 0.26), V(0, -0.05, td * 0.35), shade(BONE, 0.9))
		for k = 0, 2 do
			deco(ctx, torso, "Rib", V(tw * 0.9, 0.12, td * 1.05), V(0, th * 0.3 - k * 0.42, 0), shade(BONE, 0.95))
		end
	else
		torso = joint(ctx, parent, "Torso", V(tw, th, td), waist, V(0, th / 2, 0), pal.torso, pal.torsoM, nil, A(-hunch), nil, "Torso")
	end
	-- arms
	local arms = {}
	local pairsN = if b.fourArms then 2 else 1
	for pairI = 1, pairsN do
		for _, sd in { 1, -1 } do
			local nm = (if sd > 0 then "ArmR" else "ArmL") .. (if pairI == 2 then "2" else "")
			local y = th / 2 - P.armW * 0.5 - (pairI - 1) * th * 0.38
			local at = V(sd * (tw / 2 + P.armW / 2 - 0.05), y, 0)
			local rot = A(hunch, 0, sd * (5 + (pairI - 1) * 14))
			local arm
			if skeletal then
				arm = joint(ctx, torso, "Bone" .. nm, V(P.armW, P.arm, P.armW), at, V(0, -P.arm / 2 + P.armW * 0.45, 0), BONE, nil, nil, rot, roleFor("bone_limb"), nm)
				deco(ctx, arm, "Hand", V(P.armW * 1.8, P.armW * 1.6, P.armW * 1.8), V(0, -P.arm / 2 - 0.05, 0), BONE)
			else
				local role = if b.clawed then roleFor("claw_hand", "arm") elseif robed then roleFor("robe_sleeve") else nil
				arm = joint(ctx, torso, nm, V(P.armW, P.arm, P.armW), at, V(0, -P.arm / 2 + P.armW * 0.45, 0), pal.arm, pal.armM, nil, rot, role, nm)
				if b.clawed then
					for k = -1, 1 do
						deco(ctx, arm, "Claw", V(0.1, 0.42, 0.1), V(k * P.armW * 0.3, -P.arm / 2 - 0.15, -P.armW * 0.3), BONE, nil, nil, A(20, 0, 0))
					end
				elseif pal.o ~= "armor_shell" then
					deco(ctx, arm, "Hand", V(P.armW * 1.08, P.armW * 0.9, P.armW * 1.08), V(0, -P.arm / 2 - P.armW * 0.2, 0), pal.skin, pal.skinMat)
				else
					deco(ctx, arm, "Gauntlet", V(P.armW * 1.2, P.armW * 1.1, P.armW * 1.2), V(0, -P.arm / 2 - P.armW * 0.2, 0), shade(pal.metal, 0.85), METAL, nil, nil, roleFor("gauntlet"))
				end
			end
			if pal.o == "plate" or pal.o == "armor_shell" then
				deco(ctx, arm, "Pauldron", V(P.armW * 1.75, 0.55, P.armW * 1.75), V(0, P.arm / 2 - P.armW * 0.35, 0), pal.metal, METAL, nil, nil, roleFor(if b.helm == "horned" then "pauldron_spiked" else "pauldron"))
			elseif b.bracers or pal.o == "leather" then
				deco(ctx, arm, "Bracer", V(P.armW * 1.15, 0.5, P.armW * 1.15), V(0, -P.arm * 0.32, 0), shade(pal.leather, 0.75), FABRIC)
			end
			if b.runes and not skeletal then
				deco(ctx, arm, "Rune", V(P.armW * 1.04, 0.08, P.armW * 1.04), V(0, -P.arm * 0.05, 0), b.runes, NEON)
			end
			arms[nm] = arm
		end
	end
	local head = headOn(ctx, torso, V(0, th / 2 + (if skeletal then 0.25 else 0.02), -td * 0.05), hunch, pal)
	-- the chest: armour, robes, straps, fur, paint, jewels
	local o = pal.o
	if o == "plate" or o == "armor_shell" then
		deco(ctx, torso, "Plate", V(tw * 1.06, th * 0.6, td * 1.12), V(0, th * 0.15, 0), pal.metal, METAL)
		deco(ctx, torso, "Gorget", V(tw * 0.6, 0.3, td * 0.9), V(0, th / 2, 0), shade(pal.metal, 0.85), METAL)
		if b.forge then
			deco(ctx, torso, "Ember", V(tw * 0.5, 0.12, 0.05), V(0, th * 0.2, -td * 0.57), rgb(255, 140, 40), NEON)
			deco(ctx, torso, "Ember", V(0.12, th * 0.4, 0.05), V(0, th * 0.05, -td * 0.57), rgb(255, 140, 40), NEON)
		end
	elseif o == "leather" then
		deco(ctx, torso, "Strap", V(0.25, th * 1.15, td * 1.08), V(0, 0, 0), shade(pal.leather, 0.7), FABRIC, nil, A(0, 0, 35))
	elseif o == "fur" then
		deco(ctx, torso, "Mane", V(tw * 1.15, 0.7, td * 1.3), V(0, th / 2 - 0.15, 0), rgb(220, 210, 190), FABRIC, nil, nil, roleFor("mane"))
	elseif robed then
		deco(ctx, torso, "Sash", V(tw * 1.04, 0.28, td * 1.06), V(0, -th / 2 + 0.25, 0), b.trim or GOLD, FABRIC)
	end
	if b.furCollar then
		deco(ctx, torso, "Mane", V(tw * 1.12, 0.55, td * 1.25), V(0, th / 2 - 0.1, 0), rgb(236, 236, 240), FABRIC, nil, nil, roleFor("mane"))
	end
	if b.paint then
		deco(ctx, torso, "Paint", V(0.25, th * 0.7, 0.04), V(-tw * 0.22, th * 0.05, -td / 2 - 0.02), b.paint, nil, nil, A(0, 0, -15))
	end
	if b.belly and (o == "rags" or o == "none") then
		deco(ctx, torso, "Belly", V(tw * 0.62, th * 0.78, 0.06), V(0, -th * 0.05, -td / 2 - 0.02), b.belly)
	end
	if b.jewels then
		deco(ctx, torso, "Necklace", V(tw * 0.7, 0.14, td * 1.08), V(0, th * 0.34, 0), GOLD, METAL)
		deco(ctx, torso, "Gem", V(0.22, 0.22, 0.22), V(0, th * 0.27, -td / 2 - 0.08), d.eye, NEON, "ball")
	end
	if b.beads then
		deco(ctx, torso, "Beads", V(tw * 0.75, 0.16, td * 1.1), V(0, th * 0.32, 0), BONE)
	end
	if b.runes and not skeletal then
		deco(ctx, torso, "Rune", V(tw * 0.35, th * 0.35, 0.05), V(0, th * 0.12, -td / 2 - 0.03), b.runes, NEON)
	end
	if b.leaves then
		deco(ctx, torso, "Leaves", V(tw * 1.25, 0.5, td * 1.3), V(0, th / 2 - 0.1, 0), rgb(90, 150, 60), LEAF)
	end
	if b.moss then
		deco(ctx, torso, "Moss", V(tw * 0.9, 0.35, td * 0.9), V(-tw * 0.15, th / 2 + 0.05, 0.1), rgb(80, 140, 60), GRASS)
	end
	if b.ice then
		for k = -1, 1 do
			deco(ctx, torso, "Crystal", V(0.35, 0.9, 0.35), V(k * tw * 0.3, th * 0.25 + math.abs(k) * -0.2, td / 2 + 0.15), rgb(190, 230, 255), ICE, nil, A(25, 0, k * 22), roleFor("crystal_cluster"))
		end
	end
	if b.stony then
		-- (a stone giant: boulders grown into its shoulders, moss, a vein of glowing ore)
		deco(ctx, torso, "Crack", V(0.1, th * 0.6, 0.05), V(tw * 0.2, 0, -td / 2 - 0.02), shade(pal.skin, 0.6), nil, nil, A(0, 0, 20))
		for _, sd in { 1, -1 } do
			deco(ctx, torso, "Boulder", V(1.2, 1.2, 1.2), V(sd * tw * 0.42, th / 2 + 0.05, 0.1), shade(pal.skin, 0.85), ROCK, "ball")
		end
		deco(ctx, torso, "Moss", V(tw * 0.8, 0.3, td * 0.9), V(-tw * 0.1, th / 2 + 0.1, 0.2), rgb(90, 130, 70), GRASS)
		deco(ctx, torso, "Ore", V(0.14, th * 0.5, 0.05), V(-tw * 0.25, th * 0.1, -td / 2 - 0.03), ctx.d.eye, NEON, nil, A(0, 0, -25))
	end
	if b.cape then
		deco(ctx, torso, "Cape", V(tw * 1.05, th + P.leg * 0.65, 0.12), V(0, -P.leg * 0.32 + 0.05, td / 2 + 0.1), b.cape, FABRIC)
	end
	if b.quiver then
		local q = deco(ctx, torso, "Quiver", V(0.42, 1.3, 0.42), V(tw * 0.25, th * 0.1, td / 2 + 0.25), shade(pal.leather, 0.85), FABRIC, nil, A(0, 0, -22))
		for k = -1, 1 do
			deco(ctx, q, "Arrow", V(0.06, 0.6, 0.12), V(k * 0.1, 0.85, 0), rgb(230, 230, 220))
		end
	end
	if b.pots then
		for k = -1, 1, 2 do
			deco(ctx, torso, "Pot", V(0.42, 0.42, 0.42), V(k * tw * 0.35, -th * 0.42, -td * 0.45), rgb(150, 90, 50), nil, "ball")
			deco(ctx, torso, "Fuse", V(0.08, 0.2, 0.08), V(k * tw * 0.35, -th * 0.42 + 0.28, -td * 0.45), rgb(255, 180, 60), NEON)
		end
	end
	if b.wings ~= nil and b.wings ~= false and ctx.d.family ~= "ants" then
		for _, sd in { 1, -1 } do
			local nm = if sd > 0 then "WingR" else "WingL"
			local wing = joint(ctx, torso, nm, V(3.2, 0.14, 1.8), V(sd * tw * 0.25, th * 0.3, td / 2 + 0.05), V(sd * 1.6, 0, 0), shade(d.a, 0.9), nil, nil, A(0, sd * -30, sd * 25), nil, nm)
			deco(ctx, wing, "WingBone", V(3.3, 0.24, 0.24), V(0, 0.05, -0.85), shade(d.c, 0.7))
		end
	end
	if b.tail then
		-- (it hangs down and back, and the tip curls up)
		local tail = joint(ctx, parent, "Tail", V(0.5, 0.45, 1.6), V(0, -0.5, td / 2), V(0, 0, 0.8), if pal.o == "plate" then pal.skin else pal.leg, nil, nil, A(28, 0, 0), nil, "Tail")
		joint(ctx, tail, "Tail", V(0.36, 0.34, 1.5), V(0, 0, 0.8), V(0, 0, 0.7), pal.skin, nil, nil, A(-18, 0, 0), nil, "Tail2")
	end
	-- the weapons
	local wep = b.weapon or "none"
	if wep ~= "none" then
		held(ctx, arms.ArmR, wep, P, 1)
		if b.twin then
			held(ctx, arms.ArmL, wep, P, -1)
		end
		if b.fourArms and arms.ArmR2 then
			held(ctx, arms.ArmR2, wep, P, 1)
			held(ctx, arms.ArmL2, wep, P, -1)
		end
	end
	if b.off then
		held(ctx, arms.ArmL, b.off, P, -1)
	end
	return torso, head, arms.ArmR, arms.ArmL
end

local PLANS: { [string]: (Ctx) -> () } = {}

PLANS.humanoid = function(ctx)
	local b = ctx.b
	local P = table.clone(BUILDS[b.build or "normal"])
	P.tw *= b.wide or 1
	local pal = palette(ctx)
	local rootH = 1.4
	makeRoot(ctx, V(P.tw, rootH, P.td + 0.2), P.leg + rootH / 2)
	local root = ctx.root
	humanLegs(ctx, root, V(0, -rootH / 2, 0), P, pal)
	-- what hangs from the waist
	local o = pal.o
	local waistY = -rootH / 2 + 0.25
	if o == "robe" or o == "robe_tatters" then
		local skirt = deco(ctx, root, "Skirt", V(P.tw * 1.18, P.leg * 0.95, P.td * 1.35), V(0, waistY - P.leg * 0.45, 0), pal.cloth, FABRIC, nil, nil, roleFor("robe_skirt"))
		if o == "robe_tatters" then
			skirt.Transparency = 0.25
		end
	elseif o == "rags" or o == "fur" then
		local c = if o == "fur" then rgb(200, 186, 160) else ctx.d.a
		deco(ctx, root, "Loin", V(P.tw * 0.5, 1.0, 0.12), V(0, waistY - 0.6, -P.td / 2 - 0.08), c, FABRIC)
		deco(ctx, root, "Loin", V(P.tw * 0.5, 0.9, 0.12), V(0, waistY - 0.55, P.td / 2 + 0.08), shade(c, 0.85), FABRIC)
	elseif o == "plate" or o == "armor_shell" then
		for _, sd in { 1, -1 } do
			deco(ctx, root, "Tasset", V(P.tw * 0.42, 0.75, 0.14), V(sd * P.tw * 0.24, waistY - 0.4, -P.td / 2 - 0.1), shade(pal.metal, 0.9), METAL)
		end
	elseif o == "tunic" then
		deco(ctx, root, "Kilt", V(P.tw * 1.08, 0.8, P.td * 1.12), V(0, waistY - 0.3, 0), pal.cloth, FABRIC)
	end
	if o ~= "none" and o ~= "bones" then
		deco(ctx, root, "Belt", V(P.tw * 1.04, 0.3, P.td * 1.08), V(0, waistY + 0.05, 0), shade(pal.leather, 0.6), FABRIC)
	elseif o == "bones" then
		deco(ctx, root, "Pelvis", V(P.tw * 0.7, 0.35, P.td * 0.6), V(0, waistY, 0), BONE)
	end
	upperBody(ctx, root, V(0, waistY, 0), P, pal, b.hunch or 0)
	if b.twoHeads then
		-- an ogre mage's second head, on the other shoulder
		local torso = ctx.model:FindFirstChild("Torso") :: BasePart
		local h2 = deco(ctx, torso, "Head", V(1.0, 0.95, 0.95), V(P.tw * 0.32, P.th / 2 + 0.45, 0), pal.skin, nil, nil, A(0, 20, 12), roleFor("head_biped"))
		eyes(ctx, h2, V(0.22, 0.05, -0.48), 0.14)
		deco(ctx, h2, "Jaw", V(1.0, 0.35, 0.55), V(0, -0.42, -0.25), shade(pal.skin, 0.95))
	end
	ctx.hover = 0
end

-- ── four legs: wolves, bears, boars, cats, rats, hounds, drakes, basilisks ─────────────
local QUAD = {
	wolf = { bw = 1.4, bh = 1.3, bl = 3.4, leg = 1.9, legW = 0.42, head = V(1.0, 0.95, 1.15), snout = V(0.55, 0.45, 0.85), ears = "pointy", tail = "bushy", neck = 0.55 },
	bear = { bw = 2.4, bh = 2.1, bl = 4.0, leg = 1.7, legW = 0.78, head = V(1.5, 1.35, 1.4), snout = V(0.8, 0.6, 0.65), ears = "round", tail = "stub", neck = 0.25 },
	boar = { bw = 1.7, bh = 1.55, bl = 3.0, leg = 1.05, legW = 0.48, head = V(1.15, 1.15, 1.25), snout = V(0.75, 0.6, 0.55), ears = "pointy", tail = "thin", neck = -0.1, tusks = true, ridge = true },
	cat = { bw = 1.3, bh = 1.2, bl = 3.6, leg = 1.85, legW = 0.46, head = V(1.1, 1.0, 1.05), snout = V(0.6, 0.42, 0.42), ears = "pointy", tail = "long", neck = 0.45 },
	rat = { bw = 1.3, bh = 1.1, bl = 2.6, leg = 0.85, legW = 0.34, head = V(0.85, 0.8, 1.1), snout = V(0.45, 0.38, 0.6), ears = "round", tail = "thin", neck = 0.1 },
	hound = { bw = 1.6, bh = 1.5, bl = 3.4, leg = 1.9, legW = 0.52, head = V(1.15, 1.05, 1.25), snout = V(0.65, 0.5, 0.8), ears = "pointy", tail = "thin", neck = 0.5, spikes = true },
	drake = { bw = 2.2, bh = 1.8, bl = 4.4, leg = 1.9, legW = 0.7, head = V(1.15, 1.0, 1.6), snout = V(0.75, 0.5, 0.9), ears = "none", tail = "long", neck = 1.1 },
	lizard = { bw = 1.9, bh = 1.05, bl = 4.6, leg = 0.95, legW = 0.5, head = V(1.25, 0.85, 1.5), snout = V(0.85, 0.45, 0.8), ears = "none", tail = "long", neck = 0.15, legs = 3, splay = true },
	horse = { bw = 1.7, bh = 1.6, bl = 4.3, leg = 2.3, legW = 0.45, head = V(0.9, 1.0, 1.6), snout = V(0.6, 0.6, 0.8), ears = "pointy", tail = "horse", neck = 1.2 },
}

-- a tail of `n` joints, each hanging off the one before (Tail, Tail2, Tail3...); `droop` > 0
-- carries it up and back, < 0 lets it hang
local function tailChain(ctx: Ctx, parent: BasePart, at: Vector3, n: number, w: number, len: number, color: Color3, droop: number, taper: number?): BasePart
	local prev = parent
	local pos = at
	local last = parent
	for k = 1, n do
		local f = 1 - (k - 1) * (taper or 0.22)
		local seg = joint(ctx, prev, "Tail", V(w * f, w * f * 0.9, len), pos, V(0, 0, len / 2), if k % 2 == 0 then shade(color, 0.95) else color, nil, nil, A(-droop, 0, 0), nil, if k == 1 then "Tail" else "Tail" .. k)
		prev = seg
		pos = V(0, 0, len / 2)
		last = seg
	end
	return last
end

-- a beast's head (jointed), with snout, jaw, eyes, ears, tusks, horns
local function beastHead(ctx: Ctx, body: BasePart, q: any, at: Vector3, yaw: number, suffix: string): BasePart
	local b, d = ctx.b, ctx.d
	local hz = q.head
	local maned = b.mane and kitHas("head_beast_maned")
	local size = if maned then V(hz.X * 1.7, hz.Y * 1.6, hz.Z * 1.6) else hz
	local head = joint(ctx, body, "Head", size, at, V(0, 0.05, -size.Z / 2 + 0.15), d.c, nil, nil, A(0, yaw, 0), if maned then "head_beast_maned" else nil, "Head" .. suffix)
	if not maned then
		local sn = q.snout
		deco(ctx, head, "Snout", sn, V(0, -hz.Y * 0.15, -hz.Z / 2 - sn.Z / 2 + 0.12), shade(d.c, 0.92))
		deco(ctx, head, "Nose", V(sn.X * 0.5, sn.Y * 0.35, 0.1), V(0, -hz.Y * 0.15 + sn.Y * 0.3, -hz.Z / 2 - sn.Z + 0.08), DARK)
		joint(ctx, head, "Jaw", V(sn.X * 0.85, sn.Y * 0.32, sn.Z * 0.95), V(0, -hz.Y * 0.15 - sn.Y * 0.5, -hz.Z / 2 + 0.12), V(0, -sn.Y * 0.16, -sn.Z * 0.47), shade(d.c, 0.85), nil, nil, nil, nil, "Jaw" .. suffix)
		if q.ears == "pointy" then
			for _, sd in { 1, -1 } do
				deco(ctx, head, "Ear", V(0.26, 0.5, 0.16), V(sd * hz.X * 0.32, hz.Y / 2 + 0.18, 0.1), d.c, nil, nil, A(-10, 0, -sd * 12))
			end
		elseif q.ears == "round" then
			for _, sd in { 1, -1 } do
				deco(ctx, head, "Ear", V(0.42, 0.42, 0.42), V(sd * hz.X * 0.4, hz.Y / 2, 0.1), d.c, nil, "ball")
			end
		end
	end
	eyes(ctx, head, V(hz.X * 0.3, hz.Y * 0.15, -size.Z / 2 + 0.02), math.max(0.16, hz.X * 0.17))
	if q.tusks then
		for _, sd in { 1, -1 } do
			deco(ctx, head, "Tusk", V(0.13, 0.5, 0.13), V(sd * q.snout.X * 0.5, -hz.Y * 0.1, -hz.Z / 2 - q.snout.Z * 0.6), d.a, nil, nil, A(-25, 0, -sd * 25))
		end
	end
	if b.sabre then
		for _, sd in { 1, -1 } do
			deco(ctx, head, "Fang", V(0.11, 0.65, 0.11), V(sd * 0.16, -hz.Y * 0.5, -hz.Z / 2 - 0.15), BONE)
		end
	end
	if b.horns then
		for _, sd in { 1, -1 } do
			local h = deco(ctx, head, "Horn", V(0.24, 1.2, 0.24), V(sd * hz.X * 0.3, hz.Y * 0.45, hz.Z * 0.25), d.a, nil, nil, A(58, 0, -sd * 12))
			deco(ctx, h, "Horn", V(0.16, 0.7, 0.16), V(0, 0.8, 0.1), shade(d.a, 0.85), nil, nil, A(20, 0, 0))
		end
	end
	if b.crest then
		deco(ctx, head, "Crest", V(0.12, 0.6, hz.Z * 0.9), V(0, hz.Y / 2 + 0.25, 0.1), d.a)
	end
	if b.scar then
		deco(ctx, head, "Scar", V(0.06, 0.5, 0.04), V(hz.X * 0.2, 0.1, -hz.Z / 2 - 0.01), rgb(230, 200, 190), nil, nil, A(0, 0, 25))
	end
	return head
end

PLANS.quad = function(ctx)
	local b, d = ctx.b, ctx.d
	local q = QUAD[b.kind or "wolf"] or QUAD.wolf
	local legPairs = b.legs or q.legs or 2
	makeRoot(ctx, V(q.bw, q.bh, q.bl), q.leg + q.bh / 2)
	local root = ctx.root
	local body = joint(ctx, root, "Body", V(q.bw, q.bh, q.bl), V(0, 0, 0), V(0, 0, 0), d.c, if b.kind == "drake" or b.kind == "lizard" then SLATE else SMOOTH, nil, nil, nil, "Body")
	deco(ctx, body, "Chest", V(q.bw * 1.08, q.bh * 1.08, q.bl * 0.42), V(0, 0.05, -q.bl * 0.27), d.c)
	deco(ctx, body, "Belly", V(q.bw * 0.82, 0.2, q.bl * 0.82), V(0, -q.bh / 2 + 0.05, 0), mix(d.c, d.a, 0.4))
	-- legs
	for k = 1, legPairs do
		local z = -q.bl / 2 + 0.55 + (k - 1) * (q.bl - 1.1) / math.max(1, legPairs - 1)
		for _, sd in { 1, -1 } do
			local nm = (if sd > 0 then "LegR" else "LegL") .. k
			if q.splay then
				local leg = joint(ctx, root, nm, V(q.legW, q.leg + 0.5, q.legW), V(sd * q.bw * 0.45, -q.bh * 0.25, z), V(0, -(q.leg + 0.5) / 2, 0), shade(d.c, 0.9), nil, nil, A(0, 0, sd * 28), nil, nm)
				deco(ctx, leg, "Paw", V(q.legW * 1.4, 0.25, q.legW * 1.6), V(0, -(q.leg + 0.5) / 2 + 0.1, -0.1), shade(d.c, 0.75), nil, nil, A(0, 0, -sd * 28))
			else
				local leg = joint(ctx, root, nm, V(q.legW, q.leg + 0.25, q.legW * 1.1), V(sd * q.bw * 0.32, -q.bh / 2 + 0.15, z), V(0, -(q.leg + 0.25) / 2, 0), d.c, nil, nil, nil, nil, nm)
				deco(ctx, leg, "Paw", V(q.legW * 1.25, 0.25, q.legW * 1.5), V(0, -(q.leg + 0.25) / 2 + 0.12, -0.08), shade(d.c, 0.75))
				if b.plated then
					deco(ctx, leg, "Plate", V(q.legW * 1.2, q.leg * 0.4, q.legW * 1.25), V(0, q.leg * 0.1, 0), IRON, METAL)
				end
			end
		end
	end
	-- the head (or two, or three), on a neck
	local heads = b.heads or 1
	local neckAt = V(0, q.bh * 0.25 + q.neck, -q.bl / 2 - 0.1)
	deco(ctx, body, "Neck", V(q.bw * 0.6, q.bh * 0.6 + q.neck, 1.0), V(0, q.bh * 0.15 + q.neck * 0.5, -q.bl / 2 + 0.2), d.c, nil, nil, A(-25, 0, 0))
	if heads == 1 then
		beastHead(ctx, body, q, neckAt, 0, "")
	else
		local offs = if heads == 2 then { -0.45, 0.45 } else { 0, -0.75, 0.75 }
		for i, x in offs do
			if x ~= 0 then
				deco(ctx, body, "Neck", V(q.bw * 0.45, q.bh * 0.5 + q.neck, 0.9), V(x * q.bw, q.bh * 0.15 + q.neck * 0.5, -q.bl / 2 + 0.2), d.c, nil, nil, A(-25, -x * 20, 0))
			end
			beastHead(ctx, body, q, neckAt + V(x * q.bw, if x == 0 then 0.25 else 0, if x == 0 then -0.1 else 0.1), -x * 22, if i == 1 then "" else tostring(i))
		end
	end
	-- a mane, a ridge, spikes, stripes, plates, frost, sparks
	if b.mane and not kitHas("head_beast_maned") then
		deco(ctx, body, "Mane", V(q.bw * 1.3, q.bh * 1.25, 1.3), V(0, q.bh * 0.2, -q.bl / 2 + 0.4), shade(d.c, 0.7), FABRIC, nil, nil, roleFor("mane"))
	end
	if q.ridge or b.spikes or q.spikes or b.spines then
		local n = if b.spines then 6 else 5
		for k = 1, n do
			local z = -q.bl * 0.4 + (k - 1) * q.bl * 0.8 / (n - 1)
			deco(ctx, body, "Spike", V(0.18, if b.spines then 0.9 else 0.5, if b.spines then 0.7 else 0.25), V(0, q.bh / 2 + 0.2, z), if b.spines or q.spikes then d.a else shade(d.c, 0.6), if q.spikes and d.family == "hounds" then NEON else nil, nil, A(-20, 0, 0))
		end
	end
	if b.stripes then
		for k = -2, 2 do
			deco(ctx, body, "Stripe", V(q.bw * 1.04, 0.18, 0.22), V(0, q.bh * 0.15, k * q.bl * 0.17), d.a, nil, nil, A(0, 0, 0))
		end
	end
	if b.plated then
		deco(ctx, body, "Plate", V(q.bw * 1.1, q.bh * 0.5, q.bl * 0.8), V(0, q.bh * 0.35, 0), IRON, METAL)
	end
	if b.frost then
		for k = -1, 1 do
			deco(ctx, body, "Frost", V(0.35, 0.8, 0.35), V(k * 0.4, q.bh / 2 + 0.25, k * 0.8), d.a, ICE, nil, A(0, 0, k * 15), roleFor("crystal_cluster"))
		end
	end
	if b.sparks then
		for k = -1, 1, 2 do
			deco(ctx, body, "Spark", V(0.12, 0.6, 0.12), V(k * q.bw * 0.52, q.bh * 0.2, k * 0.6), rgb(170, 230, 255), NEON, nil, A(0, 0, k * 30))
		end
	end
	if d.family == "hounds" then
		deco(ctx, body, "Ember", V(q.bw * 0.6, 0.12, q.bl * 0.5), V(0, -q.bh / 2 - 0.02, 0), d.a, NEON)
	end
	-- a tail
	local tail = q.tail
	if tail == "bushy" then
		tailChain(ctx, body, V(0, q.bh * 0.3, q.bl / 2), 2, 0.55, 1.2, shade(d.c, 1.05), 30, 0.1)
	elseif tail == "long" then
		tailChain(ctx, body, V(0, q.bh * 0.2, q.bl / 2), 3, if b.kind == "lizard" or b.kind == "drake" then 0.9 else 0.36, 1.4, d.c, if b.kind == "lizard" or b.kind == "drake" then -5 else 12, 0.25)
	elseif tail == "thin" then
		tailChain(ctx, body, V(0, q.bh * 0.25, q.bl / 2), 2, 0.22, 1.3, mix(d.c, d.a, 0.3), 20, 0.3)
	elseif tail == "horse" then
		tailChain(ctx, body, V(0, q.bh * 0.3, q.bl / 2), 2, 0.4, 1.1, b.hair or shade(d.c, 0.5), -40, 0.1)
	else
		joint(ctx, body, "Tail", V(0.4, 0.4, 0.5), V(0, q.bh * 0.3, q.bl / 2), V(0, 0, 0.25), d.c, nil, nil, nil, nil, "Tail")
	end
	-- wings (a drake's, a dragon-kin's)
	if b.wings then
		for _, sd in { 1, -1 } do
			local nm = if sd > 0 then "WingR" else "WingL"
			local wing = joint(ctx, body, nm, V(4.6, 0.18, 2.6), V(sd * q.bw * 0.4, q.bh * 0.45, -q.bl * 0.08), V(sd * 2.3, 0, 0), shade(d.a, 0.85), nil, nil, A(0, 0, sd * 18), nil, nm)
			deco(ctx, wing, "WingBone", V(4.7, 0.3, 0.3), V(0, 0.08, -1.2), shade(d.c, 0.8))
		end
	end
	ctx.hover = 0
end

-- ── six legs: ants, beetles, mantises, crickets ───────────────────────────────────
local INSECT = {
	ant = { thorax = V(0.85, 0.75, 1.35), abdomen = V(1.55, 1.25, 2.0), head = V(1.05, 0.95, 1.0), upper = 1.15, clear = 0.75, mand = 0.8, ant = 1.3, up = 38, legW = 0.15 },
	beetle = { thorax = V(1.8, 0.9, 1.1), abdomen = V(2.4, 1.35, 2.1), head = V(1.1, 0.8, 0.8), upper = 1.0, clear = 0.5, mand = 0.45, ant = 0.7, up = 25 },
	mantis = { thorax = V(0.7, 0.7, 1.5), abdomen = V(1.0, 0.8, 2.6), head = V(1.0, 0.85, 0.7), upper = 1.4, clear = 1.25, mand = 0.3, ant = 1.1, up = 40 },
}

PLANS.insect = function(ctx)
	local b, d = ctx.b, ctx.d
	local kind = b.kind or "ant"
	local I = INSECT[kind] or INSECT.ant
	local th, ab, hd = I.thorax, I.abdomen * (if b.bigAbdomen then 1.3 else 1), I.head * (if b.bigHead then 1.35 else 1)
	local y = I.clear + th.Y / 2
	makeRoot(ctx, V(th.X * 1.2, 1.0, th.Z + ab.Z * 0.6), y)
	local root = ctx.root
	local shellMat = if kind == "beetle" or b.plated then METAL else SMOOTH
	local raise = if kind == "mantis" then 38 else 0
	local thorax = joint(ctx, root, "Thorax", th, V(0, 0, 0), V(0, 0, 0), d.c, shellMat, nil, A(raise, 0, 0), roleFor("thorax_insect"), "Body")
	local abd
	if kind == "ant" then
		-- a narrow waist, then the round gaster, hanging a little
		deco(ctx, root, "Waist", V(0.4, 0.4, 0.6), V(0, 0.05, th.Z / 2 + 0.2), shade(d.c, 0.8))
		abd = joint(ctx, root, "Abdomen", V(ab.X, ab.X, ab.X) * 1.05, V(0, 0.15, th.Z / 2 + 0.45), V(0, 0.1, ab.X * 0.5), shade(d.c, 0.92), shellMat, "ball", A(12, 0, 0), roleFor("abdomen_insect", "abdomen"), "Abdomen")
		deco(ctx, abd, "Band", V(ab.X * 1.02, 0.12, ab.X * 0.75), V(0, 0, 0), shade(d.c, 0.75), nil, nil, A(80, 0, 0))
	else
		abd = joint(ctx, root, "Abdomen", ab, V(0, 0.05, th.Z / 2 - 0.05), V(0, ab.Y * 0.05, ab.Z / 2 - 0.05), shade(d.c, 0.92), shellMat, nil, A(if kind == "mantis" then -6 else 0, 0, 0), roleFor("abdomen_insect", "abdomen"), "Abdomen")
	end
	-- the head: forward of the thorax (on top of it for a mantis)
	local headAt = if kind == "mantis" then V(0, th.Y * 0.3, -th.Z / 2 - 0.1) else V(0, 0.05, -th.Z / 2 + 0.05)
	local head = joint(ctx, thorax, "InsectHead", hd, headAt, V(0, if kind == "mantis" then 0.2 else 0, -hd.Z / 2 + 0.05), d.c, shellMat, nil, A(-raise, 0, 0), roleFor("head_insect"), "Head")
	eyes(ctx, head, V(hd.X * 0.42, hd.Y * 0.18, -hd.Z * 0.2), if kind == "mantis" then 0.45 else hd.X * 0.32)
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "R" else "L"
		joint(ctx, head, "Mand" .. nm, V(0.18, 0.18, I.mand) * (if b.bigHead then 1.4 else 1), V(sd * hd.X * 0.22, -hd.Y * 0.28, -hd.Z / 2), V(0, 0, -I.mand / 2), d.a, nil, nil, A(0, -sd * 22, 0), roleFor("mandible"), "Mand" .. nm)
		joint(ctx, head, "Ant" .. nm, V(0.08, I.ant, 0.08), V(sd * hd.X * 0.22, hd.Y * 0.4, -hd.Z * 0.3), V(0, I.ant / 2, 0), shade(d.c, 0.7), nil, nil, A(-35, 0, -sd * 25), roleFor("antenna"), "Ant" .. nm)
	end
	-- the shell, horns, plates
	if kind == "beetle" then
		-- the wing cases: a dome over the back, split down the middle, and the plate behind the head
		local dome = kitHas("shell_dome")
		local L = ab.Z * 1.05
		if dome then
			deco(ctx, abd, "Shell", V(ab.X * 1.15, ab.Y * 1.0, L), V(0, ab.Y * 0.25, 0), d.c, METAL, nil, nil, "shell_dome")
		else
			for _, sd in { 1, -1 } do
				local half = deco(ctx, abd, "Elytron", V(ab.X * 0.56, ab.Y * 0.75, L), V(sd * ab.X * 0.28, ab.Y * 0.18, 0), d.c, METAL, nil, A(0, 0, -sd * 6))
				deco(ctx, half, "Elytron", V(ab.X * 0.42, ab.Y * 0.3, L * 0.86), V(-sd * ab.X * 0.05, ab.Y * 0.45, 0.02), shade(d.c, 1.15), METAL)
			end
			deco(ctx, abd, "Seam", V(0.08, 0.1, L * 0.95), V(0, ab.Y * 0.85, 0), d.a, NEON)
		end
		deco(ctx, thorax, "Pronotum", V(th.X * 1.08, th.Y * 0.9, th.Z * 1.05), V(0, th.Y * 0.2, 0), shade(d.c, 0.85), METAL)
		local horns = b.horn or 0
		if horns >= 1 then
			deco(ctx, head, "Horn", V(0.28, if horns >= 2 then 1.8 else 1.1, 0.28), V(0, hd.Y * 0.5, -hd.Z * 0.35), if horns >= 2 then shade(d.c, 1.2) else d.a, if horns >= 2 then SMOOTH else NEON, nil, A(-40, 0, 0))
		end
		if horns >= 2 then
			deco(ctx, thorax, "Horn", V(0.24, 0.9, 0.24), V(0, th.Y * 0.6, -th.Z * 0.2), shade(d.c, 1.2), nil, nil, A(-55, 0, 0))
		end
	end
	if b.plated then
		deco(ctx, thorax, "Plate", V(th.X * 1.2, 0.2, th.Z * 1.05), V(0, th.Y / 2 + 0.05, 0), d.a, METAL)
		deco(ctx, head, "Plate", V(hd.X * 1.05, 0.2, hd.Z * 0.9), V(0, hd.Y / 2 + 0.05, 0.05), d.a, METAL)
	end
	if b.bigAbdomen then
		deco(ctx, abd, "Sac", V(ab.X * 0.5, ab.Y * 0.5, 0.2), V(0, 0, ab.Z / 2), rgb(200, 255, 90), NEON)
	end
	-- the legs: three pairs (two for a mantis, whose front pair are its scythes)
	local legPairs = if kind == "mantis" then 2 else 3
	for k = 1, legPairs do
		local f = (k - 1) / math.max(1, legPairs - 1)
		local z = if kind == "mantis" then th.Z * 0.35 + f * 0.6 else -th.Z * 0.38 + f * th.Z * 0.76
		-- (the front legs reach forward, the back ones back)
		local yaw = if kind == "mantis" then -10 - f * 25 else 32 - f * 64
		for _, sd in { 1, -1 } do
			local nm = (if sd > 0 then "LegR" else "LegL") .. k
			insectLeg(ctx, root, nm, V(sd * th.X * 0.45, -th.Y * 0.2, z), sd, yaw, I.up, I.upper, I.legW or (0.16 + th.X * 0.06), shade(d.c, 0.7), 0, if kind == "beetle" then 0.45 else 0.75)
		end
	end
	if kind == "mantis" then
		for _, sd in { 1, -1 } do
			local nm = if sd > 0 then "ArmR" else "ArmL"
			local arm = joint(ctx, thorax, "Raptor" .. (if sd > 0 then "R" else "L"), V(0.24, 1.4, 0.24), V(sd * th.X * 0.4, th.Y * 0.1, -th.Z * 0.35), V(0, -0.6, 0), d.c, nil, nil, A(-raise + 30, 0, sd * 10), roleFor("leg_insect"), nm)
			deco(ctx, arm, "Scythe", V(0.12, 1.6, 0.35), V(0, -0.35, -0.55), d.a, nil, nil, A(-150, 0, 0), roleFor("leg_insect"))
		end
		for _, sd in { 1, -1 } do
			deco(ctx, abd, "WingFold", V(0.7, 0.06, ab.Z * 0.85), V(sd * 0.22, ab.Y / 2 + 0.03, -0.2), mix(d.c, d.a, 0.5), GLASS, nil, A(0, 0, sd * 8)).Transparency = 0.3
		end
	end
	-- wings (a winged ant flies)
	if b.wings then
		for _, sd in { 1, -1 } do
			local nm = if sd > 0 then "WingR" else "WingL"
			local w = joint(ctx, thorax, nm, V(3.0, 0.06, 1.1), V(sd * th.X * 0.35, th.Y * 0.5, 0), V(sd * 1.5, 0, 0.2), rgb(220, 230, 240), GLASS, nil, A(0, -sd * 12, sd * 12), roleFor(if sd > 0 then "wing_insect_r" else "wing_insect_l", if sd > 0 then "wing_r" else "wing_l"), nm)
			w.Transparency = 0.45
		end
	end
	ctx.hover = if b.wings then 3.2 else 0
end

-- ── eight legs: spiders, scorpions; and crabs ─────────────────────────────────────
PLANS.spider = function(ctx)
	local d = ctx.d
	local ceph, ab = V(2.0, 1.1, 1.9), V(2.6, 2.1, 2.7)
	local y = 1.3
	makeRoot(ctx, V(2.2, 1.0, 3.6), y)
	local root = ctx.root
	local body = joint(ctx, root, "Body", ceph, V(0, 0, -0.4), V(0, 0, 0), d.c, nil, nil, nil, nil, "Body")
	local abd = joint(ctx, root, "Abdomen", ab, V(0, 0.15, 0.5), V(0, ab.Y * 0.2, ab.Z / 2 - 0.1), shade(d.c, 1.08), if d.id == "phase_spider" then GLASS else nil, "ball", A(-10, 0, 0), nil, "Abdomen")
	if d.id == "phase_spider" then
		abd.Transparency = 0.25
		deco(ctx, abd, "Core", V(1.1, 1.1, 1.1), V(0, 0, 0), d.a, NEON, "ball")
	end
	deco(ctx, abd, "Mark", V(0.9, 0.9, 0.2), V(0, ab.Y * 0.38, -0.2), d.a, NEON, nil, A(-60, 0, 0))
	if d.id == "weaver_spider" then
		for k = -1, 1, 2 do
			deco(ctx, abd, "Stripe", V(0.3, 0.2, ab.Z * 0.95), V(k * 0.6, ab.Y * 0.32, 0), d.a)
		end
	end
	-- eyes: two big, four small
	eyes(ctx, body, V(0.3, 0.3, -ceph.Z / 2), 0.32)
	eyes(ctx, body, V(0.62, 0.38, -ceph.Z / 2 + 0.25), 0.18)
	eyes(ctx, body, V(0.15, 0.55, -ceph.Z / 2 + 0.15), 0.16)
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "R" else "L"
		joint(ctx, body, "Mand" .. nm, V(0.3, 0.6, 0.3), V(sd * 0.3, -0.25, -ceph.Z / 2 + 0.05), V(0, -0.25, -0.1), shade(d.c, 0.7), nil, nil, A(20, 0, 0), roleFor("mandible"), "Mand" .. nm)
	end
	for k = 1, 4 do
		local yaw = 52 - (k - 1) * 34
		for _, sd in { 1, -1 } do
			insectLeg(ctx, root, (if sd > 0 then "LegR" else "LegL") .. k, V(sd * ceph.X * 0.42, -0.1, -0.4 - ceph.Z * 0.35 + (k - 1) * ceph.Z * 0.23), sd, yaw, 48, 1.9, 0.26, shade(d.c, 0.85), 0, 1.0)
		end
	end
	ctx.hover = 0
end

PLANS.scorpion = function(ctx)
	local d = ctx.d
	local cara, ab = V(1.8, 0.8, 1.6), V(1.7, 0.7, 1.8)
	local y = 0.95
	makeRoot(ctx, V(2.0, 0.9, 3.2), y)
	local root = ctx.root
	local body = joint(ctx, root, "Carapace", cara, V(0, 0, -0.6), V(0, 0, 0), d.c, METAL, nil, nil, roleFor("thorax_insect"), "Body")
	local abd = joint(ctx, root, "Abdomen", ab, V(0, 0, 0.2), V(0, 0, ab.Z / 2), shade(d.c, 0.95), METAL, nil, nil, roleFor("abdomen_insect", "abdomen"), "Abdomen")
	for k = 1, 3 do
		deco(ctx, abd, "Band", V(ab.X * 1.04, ab.Y * 1.04, 0.12), V(0, 0, -ab.Z / 2 + k * ab.Z / 4), d.a, METAL)
	end
	eyes(ctx, body, V(0.25, cara.Y / 2, -cara.Z * 0.3), 0.2)
	-- the tail: five joints curling up over the back, and the stinger
	local prev = abd
	local at = V(0, 0.1, ab.Z / 2)
	for k = 1, 5 do
		local seg = joint(ctx, prev, "TailSeg", V(0.55 - k * 0.04, 0.55 - k * 0.04, 0.85), at, V(0, 0, 0.42), if k % 2 == 0 then d.c else shade(d.c, 0.9), METAL, nil, A(if k == 1 then -45 else -32, 0, 0), roleFor("segment"), if k == 1 then "Tail" else "Tail" .. k)
		prev = seg
		at = V(0, 0, 0.42)
	end
	deco(ctx, prev, "Stinger", V(0.3, 0.9, 0.3), V(0, 0.2, 0.55), d.a, nil, nil, A(-120, 0, 0), roleFor("stinger"))
	deco(ctx, prev, "Venom", V(0.18, 0.18, 0.18), V(0, -0.2, 0.75), d.eye, NEON, "ball")
	-- pincers
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "ArmR" else "ArmL"
		local arm = joint(ctx, body, "PincerArm", V(0.32, 0.32, 1.4), V(sd * cara.X * 0.4, 0, -cara.Z / 2), V(0, 0, -0.65), d.c, METAL, nil, A(10, sd * -25, 0), roleFor("leg_insect"), nm)
		deco(ctx, arm, "Pincer", V(0.65, 0.45, 0.95), V(sd * 0.12, 0, -1.05), shade(d.c, 1.1), METAL, nil, A(0, sd * 20, 0), roleFor("pincer"))
	end
	for k = 1, 4 do
		for _, sd in { 1, -1 } do
			insectLeg(ctx, root, (if sd > 0 then "LegR" else "LegL") .. k, V(sd * cara.X * 0.45, -0.1, -0.9 + (k - 1) * 0.55), sd, 34 - (k - 1) * 24, 32, 1.1, 0.2, shade(d.c, 0.8), 0, 0.6)
		end
	end
	ctx.hover = 0
end

PLANS.crab = function(ctx)
	local d = ctx.d
	local shellSz = V(2.6, 0.9, 1.9)
	makeRoot(ctx, V(2.4, 0.9, 1.8), 1.0)
	local root = ctx.root
	local body = joint(ctx, root, "Shell", shellSz, V(0, 0, 0), V(0, 0, 0), d.c, nil, nil, nil, roleFor("shell_dome"), "Body")
	deco(ctx, body, "Rim", V(shellSz.X * 1.05, 0.2, shellSz.Z * 1.05), V(0, -0.35, 0), shade(d.c, 0.8))
	deco(ctx, body, "Dome", V(shellSz.X * 0.7, 0.5, shellSz.Z * 0.7), V(0, 0.6, 0.05), shade(d.c, 1.1))
	for k = -1, 1, 2 do
		deco(ctx, body, "Spot", V(0.35, 0.1, 0.35), V(k * 0.45, 0.86, 0), d.a)
	end
	for _, sd in { 1, -1 } do
		local stalk = deco(ctx, body, "Stalk", V(0.12, 0.55, 0.12), V(sd * 0.35, 0.65, -shellSz.Z * 0.38), shade(d.c, 0.9))
		deco(ctx, stalk, "Eye", V(0.24, 0.24, 0.24), V(0, 0.3, 0), DARK, nil, "ball")
		local nm = if sd > 0 then "ArmR" else "ArmL"
		local arm = joint(ctx, body, "PincerArm", V(0.42, 0.42, 1.2), V(sd * shellSz.X * 0.44, 0, -shellSz.Z * 0.35), V(0, 0, -0.55), d.c, nil, nil, A(28, sd * -40, 0), roleFor("leg_insect"), nm)
		local claw = deco(ctx, arm, "Pincer", V(0.9, 0.75, 1.2), V(sd * 0.12, 0.1, -1.2), shade(d.c, 1.08), nil, nil, A(-15, sd * 30, 0), roleFor("pincer"))
		deco(ctx, claw, "Finger", V(0.3, 0.25, 0.8), V(-sd * 0.15, -0.45, -0.45), shade(d.c, 0.9), nil, nil, A(-10, 0, 0))
		deco(ctx, claw, "Tip", V(0.5, 0.4, 0.35), V(0, 0.05, -0.65), d.a)
	end
	for k = 1, 3 do
		for _, sd in { 1, -1 } do
			insectLeg(ctx, root, (if sd > 0 then "LegR" else "LegL") .. k, V(sd * shellSz.X * 0.45, -0.15, -0.4 + (k - 1) * 0.5), sd, 25 - (k - 1) * 25, 40, 1.0, 0.22, shade(d.c, 0.85), 0, 0.5)
		end
	end
	ctx.hover = 0
end

-- ── long bodies: centipedes and wyrms on the ground; serpents and naga rearing up ───────
local function segmentChain(ctx: Ctx, n: number, w: number, h: number, len: number, legs: boolean, color: Color3, accent: Color3, taper: number): BasePart
	local prev = ctx.root
	local at = V(0, -0.05, ctx.root.Size.Z / ctx.s / 2)
	for k = 1, n do
		local f = 1 - (k - 1) / n * taper
		local seg = joint(ctx, prev, "Seg", V(w * f, h * f, len), at, V(0, 0, len / 2), if k % 2 == 0 then color else shade(color, 0.9), nil, nil, nil, nil, "Seg" .. k)
		if legs then
			for _, sd in { 1, -1 } do
				deco(ctx, seg, "SegLeg", V(0.12, 0.12, 0.9 * f), V(sd * (w * f / 2 + 0.3), -h * f * 0.3, 0), accent, nil, nil, A(0, sd * 70, -sd * 25))
			end
		end
		prev = seg
		at = V(0, 0, len / 2)
	end
	return prev
end

PLANS.slither = function(ctx)
	local b, d = ctx.b, ctx.d
	if b.kind == "wyrm" then
		-- a sand wyrm: a ringed body on the ground, its front rearing up into a round maw
		makeRoot(ctx, V(1.8, 1.6, 2.0), 0.9)
		local root = ctx.root
		local neck = joint(ctx, root, "Neck", V(1.7, 2.4, 1.7), V(0, 0.4, -0.4), V(0, 1.2, 0), d.c, SAND, nil, A(-20, 0, 0), roleFor("segment"), "Neck")
		local maw = joint(ctx, neck, "Maw", V(2.0, 1.9, 1.6), V(0, 1.2, 0), V(0, 0.6, -0.3), shade(d.c, 1.05), SAND, nil, A(-35, 0, 0), roleFor("maw", "head_serpent"), "Head")
		deco(ctx, maw, "Mouth", V(1.4, 1.3, 0.1), V(0, 0, -0.81), rgb(60, 20, 20))
		for k = 0, 7 do
			local a = k / 8 * math.pi * 2
			deco(ctx, maw, "Tooth", V(0.14, 0.4, 0.14), V(math.cos(a) * 0.55, math.sin(a) * 0.5, -0.82), BONE, nil, nil, A(0, 0, math.deg(a) + 90))
		end
		eyes(ctx, maw, V(0.75, 0.55, -0.5), 0.2)
		segmentChain(ctx, 7, 1.8, 1.6, 1.4, false, d.c, d.a, 0.5)
		ctx.hover = 0
		return
	end
	-- a centipede: a head with mandibles and feelers, and a chain of legged segments
	makeRoot(ctx, V(1.3, 0.8, 1.4), 0.55)
	local root = ctx.root
	local hd = V(1.1, 0.7, 0.9)
	local head = joint(ctx, root, "InsectHead", hd, V(0, 0.05, -0.7), V(0, 0.1, -hd.Z / 2), d.c, METAL, nil, A(-8, 0, 0), roleFor("head_insect"), "Head")
	eyes(ctx, head, V(0.35, 0.2, -hd.Z * 0.3), 0.18)
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "R" else "L"
		joint(ctx, head, "Mand" .. nm, V(0.16, 0.16, 0.7), V(sd * 0.25, -0.15, -hd.Z / 2), V(0, 0, -0.35), d.a, nil, nil, A(0, -sd * 25, 0), roleFor("mandible"), "Mand" .. nm)
		joint(ctx, head, "Ant" .. nm, V(0.07, 1.3, 0.07), V(sd * 0.3, 0.25, -hd.Z * 0.3), V(0, 0.65, 0), d.a, nil, nil, A(-60, 0, -sd * 30), roleFor("antenna"), "Ant" .. nm)
	end
	local last = segmentChain(ctx, 8, 1.2, 0.6, 0.85, true, d.c, d.a, 0.35)
	for _, sd in { 1, -1 } do
		deco(ctx, last, "Prong", V(0.1, 0.1, 0.8), V(sd * 0.2, 0, 0.7), d.a, nil, nil, A(0, -sd * 25, 0))
	end
	ctx.hover = 0
end

PLANS.serpent = function(ctx)
	local b, d = ctx.b, ctx.d
	makeRoot(ctx, V(2.0, 1.6, 2.2), 0.95)
	local root = ctx.root
	local neck = joint(ctx, root, "Neck", V(1.3, 2.6, 1.3), V(0, 0.4, -0.3), V(0, 1.3, 0), d.c, nil, nil, A(-12, 0, 0), nil, "Neck")
	deco(ctx, neck, "Belly", V(1.0, 2.5, 0.1), V(0, 0, -0.66), d.a)
	local head = joint(ctx, neck, "Head", V(1.5, 1.0, 2.2), V(0, 1.3, 0), V(0, 0.3, -0.8), d.c, nil, nil, A(12, 0, 0), roleFor("head_serpent"), "Head")
	joint(ctx, head, "Jaw", V(1.3, 0.35, 1.9), V(0, -0.5, -0.2), V(0, -0.15, -0.75), shade(d.c, 0.8), nil, nil, nil, nil, "Jaw")
	eyes(ctx, head, V(0.5, 0.3, -0.75), 0.3)
	if b.horns then
		for _, sd in { 1, -1 } do
			deco(ctx, head, "Horn", V(0.25, 1.2, 0.25), V(sd * 0.55, 0.7, 0.4), d.a, NEON, nil, A(40, 0, -sd * 10))
		end
	end
	if b.fins then
		for _, sd in { 1, -1 } do
			deco(ctx, head, "Fin", V(0.1, 0.9, 1.2), V(sd * 0.8, 0.1, 0.5), d.a, nil, nil, A(0, 0, -sd * 50), roleFor("fin"))
		end
		deco(ctx, neck, "Fin", V(0.12, 1.0, 1.8), V(0, 0.2, 0.75), d.a, nil, nil, A(0, 90, 0), roleFor("fin"))
	end
	segmentChain(ctx, 6, 1.5, 1.3, 1.5, false, d.c, d.a, 0.55)
	ctx.hover = 0
end

PLANS.naga = function(ctx)
	local b, d = ctx.b, ctx.d
	local P = table.clone(BUILDS.normal)
	P.tw, P.th = 1.7, 2.0
	local pal = palette(ctx)
	pal.torso = d.c
	makeRoot(ctx, V(1.8, 1.4, 2.0), 1.4)
	local root = ctx.root
	deco(ctx, root, "Hips", V(1.6, 1.4, 1.6), V(0, -0.2, 0.1), d.c)
	if b.armor then
		deco(ctx, root, "Belt", V(1.7, 0.3, 1.7), V(0, 0.35, 0.1), GOLD, METAL)
	end
	upperBody(ctx, root, V(0, 0.4, 0), P, pal, -4)
	segmentChain(ctx, 6, 1.4, 1.1, 1.3, false, d.c, d.a, 0.55)
	ctx.hover = 0
end

PLANS.merfolk = function(ctx)
	local d = ctx.d
	local P = table.clone(BUILDS.normal)
	P.tw, P.th, P.arm = 1.7, 2.0, 2.1
	local pal = palette(ctx)
	pal.torso = d.c
	makeRoot(ctx, V(1.7, 1.4, 1.4), 3.2)
	local root = ctx.root
	deco(ctx, root, "Scales", V(1.6, 1.3, 1.3), V(0, -0.2, 0), shade(d.c, 0.85))
	upperBody(ctx, root, V(0, 0.4, 0), P, pal, 0)
	-- the tail curls down and back to a fin, just off the ground (they bring the water's lift with them)
	local prev = root
	local at = V(0, -0.7, 0.1)
	for k = 1, 4 do
		local f = 1 - (k - 1) * 0.18
		local seg = joint(ctx, prev, "Seg", V(1.2 * f, 1.1, 1.0 * f), at, V(0, -0.5, 0), if k % 2 == 0 then d.c else shade(d.c, 0.9), nil, nil, A(if k == 1 then 10 else 22, 0, 0), nil, "Seg" .. k)
		prev = seg
		at = V(0, -0.5, 0)
	end
	deco(ctx, prev, "Fin", V(0.12, 1.4, 1.6), V(0, -0.8, 0.4), d.a, nil, nil, A(0, 90, 0) * A(35, 0, 0), roleFor("fin"))
	ctx.hover = 0
end

-- ── fliers: bats, birds, harpies, wyverns, gargoyles ──────────────────────────────
local function wingPair(ctx: Ctx, parent: BasePart, at: Vector3, span: number, chord: number, color: Color3, style: string, boneColor: Color3?)
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "WingR" else "WingL"
		local role = if style == "feather" then roleFor(if sd > 0 then "wing_feather_r" else "wing_feather_l", if sd > 0 then "wing_r" else "wing_l") else nil
		local wing = joint(ctx, parent, nm, V(span, 0.16, chord), V(sd * at.X, at.Y, at.Z), V(sd * span / 2, 0, 0), color, if style == "bone" then GLASS else nil, nil, A(0, 0, sd * 12), role, nm)
		if style == "bone" then
			wing.Transparency = 0.55
			deco(ctx, wing, "WingBone", V(span * 1.02, 0.22, 0.22), V(0, 0.05, -chord * 0.45), boneColor or BONE, nil, nil, nil, roleFor("bone_limb"))
			for k = -1, 1 do
				deco(ctx, wing, "Finger", V(0.14, 0.14, chord * 0.9), V(sd * k * span * 0.25 + sd * span * 0.15, 0.05, 0), boneColor or BONE)
			end
		elseif style == "membrane" then
			deco(ctx, wing, "WingBone", V(span * 1.02, 0.24, 0.24), V(0, 0.06, -chord * 0.45), shade(ctx.d.c, 0.75))
			for k = 0, 1 do
				deco(ctx, wing, "Finger", V(0.12, 0.12, chord * 0.85), V(sd * (k * span * 0.3), 0.05, 0), shade(ctx.d.c, 0.75))
			end
		elseif style == "feather" then
			for k = 0, 2 do
				deco(ctx, wing, "Feather", V(span * (0.45 - k * 0.08), 0.1, chord * 0.35), V(sd * span * (0.12 + k * 0.08), -0.02, chord * 0.3 + k * 0.08), shade(color, 0.9 - k * 0.08))
			end
		end
	end
end

PLANS.bat = function(ctx)
	local b, d = ctx.b, ctx.d
	makeRoot(ctx, V(1.4, 1.2, 1.6), 0.6)
	local root = ctx.root
	local body = joint(ctx, root, "Body", V(1.3, 1.2, 1.7), V(0, 0, 0), V(0, 0, 0), d.c, FABRIC, nil, nil, nil, "Body")
	local head = joint(ctx, body, "BatHead", V(0.95, 0.85, 0.9), V(0, 0.4, -0.8), V(0, 0.1, -0.35), d.c, FABRIC, nil, nil, nil, "Head")
	eyes(ctx, head, V(0.25, 0.1, -0.45), 0.2)
	deco(ctx, head, "Snout", V(0.4, 0.3, 0.3), V(0, -0.15, -0.55), shade(d.c, 0.9))
	local ear = if b.bigEars then 1.0 else 0.6
	for _, sd in { 1, -1 } do
		deco(ctx, head, "Ear", V(0.3, ear, 0.16), V(sd * 0.3, 0.45 + ear * 0.3, 0), d.a, nil, nil, A(0, 0, -sd * 18))
		deco(ctx, head, "Fang", V(0.08, 0.2, 0.08), V(sd * 0.12, -0.35, -0.6), BONE)
		joint(ctx, root, "BatLeg", V(0.15, 0.6, 0.15), V(sd * 0.3, -0.5, 0.4), V(0, -0.3, 0), shade(d.c, 0.8), nil, nil, nil, nil, if sd > 0 then "LegR" else "LegL")
	end
	wingPair(ctx, body, V(0.6, 0.3, 0), 3.6, 2.0, d.a, "membrane")
	ctx.hover = 2.4
end

PLANS.bird = function(ctx)
	local b, d = ctx.b, ctx.d
	makeRoot(ctx, V(1.4, 1.2, 2.0), 0.6)
	local root = ctx.root
	local body = joint(ctx, root, "Body", V(1.2, 1.1, 2.0), V(0, 0, 0), V(0, 0, 0), d.c, FABRIC, nil, A(10, 0, 0), nil, "Body")
	local head = joint(ctx, body, "BirdHead", V(0.8, 0.8, 0.9), V(0, 0.45, -1.0), V(0, 0.15, -0.3), d.c, FABRIC, nil, A(-10, 0, 0), nil, "Head")
	deco(ctx, head, "Beak", V(0.28, 0.24, 0.65), V(0, -0.1, -0.7), if b.crest then GOLD else rgb(40, 40, 46))
	eyes(ctx, head, V(0.3, 0.12, -0.3), 0.18)
	if b.crest then
		for k = -1, 1 do
			deco(ctx, head, "Crest", V(0.1, 0.8, 0.3), V(k * 0.12, 0.6, 0.2 + math.abs(k) * 0.1), d.a, if b.sparks then NEON else nil, nil, A(-30, 0, k * 15))
		end
	end
	wingPair(ctx, body, V(0.5, 0.3, -0.1), 3.8, 1.6, d.c, "feather")
	local tail = joint(ctx, body, "Tail", V(1.0, 0.12, 1.3), V(0, 0.1, 1.0), V(0, 0, 0.6), shade(d.c, 0.85), FABRIC, nil, A(10, 0, 0), nil, "Tail")
	if b.sparks then
		deco(ctx, tail, "Spark", V(0.8, 0.08, 0.2), V(0, 0.05, 0.4), d.a, NEON)
	end
	for _, sd in { 1, -1 } do
		local leg = joint(ctx, root, "TalonLeg", V(0.18, 0.9, 0.18), V(sd * 0.3, -0.45, 0.2), V(0, -0.45, 0), rgb(200, 170, 80), nil, nil, nil, nil, if sd > 0 then "LegR" else "LegL")
		deco(ctx, leg, "Talon", V(0.4, 0.12, 0.45), V(0, -0.45, -0.1), rgb(60, 50, 40))
	end
	ctx.hover = 2.6
end

PLANS.harpy = function(ctx)
	local d = ctx.d
	local P = table.clone(BUILDS.slender)
	P.tw, P.th = 1.3, 1.8
	local pal = palette(ctx)
	pal.torso = shade(d.c, 1.05)
	pal.torsoM = FABRIC
	makeRoot(ctx, V(1.4, 1.2, 1.2), 1.0)
	local root = ctx.root
	local torso = joint(ctx, root, "Torso", V(P.tw, P.th, P.td), V(0, -0.3, 0), V(0, P.th / 2, 0), pal.torso, FABRIC, nil, A(-12, 0, 0), nil, "Torso")
	deco(ctx, torso, "Ruff", V(P.tw * 1.25, 0.5, P.td * 1.4), V(0, P.th / 2 - 0.15, 0), d.a, FABRIC, nil, nil, roleFor("mane"))
	ctx.b.head = "bird"
	headOn(ctx, torso, V(0, P.th / 2 + 0.05, 0), 12, pal)
	wingPair(ctx, torso, V(P.tw / 2, P.th * 0.35, 0), 3.6, 1.6, d.a, "feather")
	local tailF = joint(ctx, root, "Tail", V(0.9, 0.12, 1.2), V(0, -0.4, 0.45), V(0, 0, 0.55), shade(d.a, 0.9), FABRIC, nil, A(-20, 0, 0), nil, "Tail")
	local _ = tailF
	for _, sd in { 1, -1 } do
		local leg = joint(ctx, root, "TalonLeg", V(0.26, 1.6, 0.26), V(sd * 0.35, -0.6, 0.1), V(0, -0.8, 0), rgb(190, 160, 90), nil, nil, nil, nil, if sd > 0 then "LegR" else "LegL")
		deco(ctx, leg, "Feathers", V(0.45, 0.6, 0.45), V(0, 0.55, 0), d.c, FABRIC)
		deco(ctx, leg, "Talon", V(0.45, 0.14, 0.55), V(0, -0.8, -0.12), rgb(60, 50, 40))
	end
	ctx.hover = 1.6
end

PLANS.wyvern = function(ctx)
	local b, d = ctx.b, ctx.d
	local bones = b.bones
	makeRoot(ctx, V(1.6, 1.3, 2.6), 0.7)
	local root = ctx.root
	local body = joint(ctx, root, if bones then "Ribs" else "Body", V(1.5, 1.3, 2.6), V(0, 0, 0), V(0, 0, 0), d.c, nil, nil, A(5, 0, 0), if bones then roleFor("ribcage") else nil, "Body")
	if bones then
		deco(ctx, body, "Spine", V(0.3, 0.3, 3.0), V(0, 0.6, 0), BONE)
		deco(ctx, body, "Core", V(0.7, 0.7, 0.7), V(0, 0, 0), d.a, NEON, "ball")
	end
	local neck = deco(ctx, body, "Neck", V(0.7, 0.7, 1.6), V(0, 0.55, -1.6), d.c, nil, nil, A(30, 0, 0), if bones then roleFor("bone_limb") else nil)
	local _ = neck
	local head = joint(ctx, body, if bones then "Skull" else "WyrmHead", V(0.9, 0.75, 1.5), V(0, 1.1, -2.2), V(0, 0.1, -0.6), if bones then BONE else d.c, nil, nil, A(-5, 0, 0), if bones then roleFor("skull") else roleFor("head_serpent"), "Head")
	joint(ctx, head, "Jaw", V(0.75, 0.25, 1.3), V(0, -0.38, -0.1), V(0, -0.1, -0.55), shade(if bones then BONE else d.c, 0.85), nil, nil, nil, nil, "Jaw")
	eyes(ctx, head, V(0.32, 0.2, -0.45), 0.2)
	if b.horns or not bones then
		for _, sd in { 1, -1 } do
			deco(ctx, head, "Horn", V(0.18, 0.8, 0.18), V(sd * 0.28, 0.45, 0.4), d.a, nil, nil, A(65, 0, -sd * 12))
		end
	end
	wingPair(ctx, body, V(0.65, 0.45, -0.3), 4.2, 2.4, if bones then rgb(150, 220, 255) else d.a, if bones then "bone" else "membrane", BONE)
	local tip = tailChain(ctx, body, V(0, 0.1, 1.3), 3, 0.55, 1.3, d.c, 5, 0.25)
	if not bones then
		deco(ctx, tip, "Barb", V(0.5, 0.5, 0.6), V(0, 0, 0.7), d.a, nil, nil, A(45, 0, 0), roleFor("stinger"))
	end
	if b.sparks then
		deco(ctx, body, "Spark", V(0.15, 0.15, 2.4), V(0, 0.7, 0), d.a, NEON)
	end
	for _, sd in { 1, -1 } do
		local leg = joint(ctx, root, if bones then "BoneLeg" else "DrakeLeg", V(0.35, 1.2, 0.35), V(sd * 0.45, -0.4, 0.6), V(0, -0.6, 0), shade(d.c, 0.9), nil, nil, nil, if bones then roleFor("bone_limb") else nil, if sd > 0 then "LegR" else "LegL")
		deco(ctx, leg, "Talon", V(0.55, 0.16, 0.65), V(0, -0.6, -0.15), shade(d.a, 0.6))
	end
	ctx.hover = 3.0
end

PLANS.gargoyle = function(ctx)
	local d = ctx.d
	local P = table.clone(BUILDS.normal)
	P.leg = 1.6
	local pal = palette(ctx)
	pal.torso, pal.torsoM, pal.arm, pal.armM, pal.leg, pal.legM, pal.skin, pal.skinMat = d.c, SLATE, d.c, SLATE, d.c, SLATE, d.c, SLATE
	ctx.b.head = "demon"
	ctx.b.clawed = true
	ctx.b.digitigrade = true
	makeRoot(ctx, V(P.tw, 1.4, P.td + 0.2), P.leg + 0.7)
	local root = ctx.root
	humanLegs(ctx, root, V(0, -0.7, 0), P, pal)
	local torso = upperBody(ctx, root, V(0, -0.45, 0), P, pal, 22)
	wingPair(ctx, torso, V(P.tw * 0.3, P.th * 0.35, P.td / 2), 3.4, 1.9, shade(d.c, 0.85), "membrane")
	ctx.hover = 0.8
end

-- ── floating: wraiths, liches, the Hollow King ────────────────────────────────────
PLANS.float = function(ctx)
	local b, d = ctx.b, ctx.d
	makeRoot(ctx, V(2, 2, 1.4), 1.0)
	local root = ctx.root
	local robe = joint(ctx, root, "Robe", V(2, 3.2, 1.6), V(0, 0, 0), V(0, 0, 0), d.c, FABRIC, nil, nil, nil, "Torso")
	deco(ctx, root, "Hem", V(2.4, 0.6, 2), V(0, -1.7, 0), d.c, FABRIC).Transparency = 0.4
	deco(ctx, root, "Wisp", V(1.6, 0.8, 1.4), V(0, -2.3, 0.1), d.a, NEON).Transparency = 0.65
	local hood = joint(ctx, robe, "Hood", V(1.5, 1.4, 1.5), V(0, 1.6, 0), V(0, 0.5, 0), d.c, FABRIC, nil, nil, nil, "Head")
	if b.skull then
		local skull = deco(ctx, hood, "Skull", V(0.85, 0.95, 0.9), V(0, -0.05, -0.35), BONE, nil, nil, nil, roleFor("skull"))
		eyes(ctx, skull, V(0.2, 0.08, -0.45), 0.16)
		deco(ctx, skull, "Jaw", V(0.6, 0.22, 0.45), V(0, -0.55, -0.12), shade(BONE, 0.9))
	else
		deco(ctx, hood, "Void", V(1, 0.9, 0.2), V(0, -0.1, -0.7), rgb(5, 5, 8))
		eyes(ctx, hood, V(0.22, -0.05, -0.82), 0.2)
	end
	if b.crown then
		for k = 0, 4 do
			local a = k / 5 * math.pi * 2
			deco(ctx, hood, "Crown", V(0.18, 0.6, 0.18), V(math.cos(a) * 0.55, 0.85, math.sin(a) * 0.55), d.a, NEON)
		end
	end
	deco(ctx, robe, "Mantle", V(2.3, 0.5, 1.8), V(0, 1.3, 0), shade(d.c, 1.2), FABRIC)
	local armR = joint(ctx, robe, "ArmR", V(0.6, 2.2, 0.6), V(1.3, 1, 0), V(0, -1.1, 0), d.c, FABRIC, nil, nil, nil, "ArmR")
	joint(ctx, robe, "ArmL", V(0.6, 2.2, 0.6), V(-1.3, 1, 0), V(0, -1.1, 0), d.c, FABRIC, nil, nil, nil, "ArmL")
	if b.scythe or b.staff then
		local shaft = deco(ctx, armR, "Shaft", V(0.2, 5, 0.2), V(0, 0, -0.3), rgb(40, 36, 40), WOOD)
		if b.scythe then
			deco(ctx, shaft, "Blade", V(0.1, 0.6, 2.4), V(0, 2.5, -0.9), d.a, NEON)
		else
			deco(ctx, shaft, "Orb", V(0.8, 0.8, 0.8), V(0, 2.5, 0), d.a, NEON, "ball")
		end
	end
	ctx.hover = 2.2
end

-- ── slimes ────────────────────────────────────────────────────────────────────
PLANS.blob = function(ctx)
	local b, d = ctx.b, ctx.d
	makeRoot(ctx, V(2, 1.2, 2), 1.2)
	local root = ctx.root
	local core = joint(ctx, root, "Body", V(2.4, 2.0, 2.4), V(0, -0.4, 0), V(0, 0, 0), d.c, if b.crust then CRACKED else GLASS, "ball", nil, nil, "Body")
	core.Transparency = if b.crust then 0 else 0.25
	joint(ctx, root, "Nucleus", V(0.9, 0.9, 0.9), V(0, -0.3, 0), V(0, 0, 0), d.a, NEON, "ball", nil, nil, "Nucleus")
	eyes(ctx, core, V(0.35, 0.5, -1.1), 0.28)
	if b.crust then
		for k = 0, 3 do
			local a = k / 4 * math.pi * 2
			deco(ctx, core, "Crack", V(0.15, 0.9, 0.15), V(math.cos(a) * 1.0, 0.1, math.sin(a) * 1.0), d.a, NEON, nil, A(0, 0, 30))
		end
	end
	if b.crown then
		deco(ctx, core, "Crown", V(1.2, 0.45, 1.2), V(0, 1.05, 0), GOLD, METAL, nil, nil, roleFor("crown"))
		for k = -1, 1 do
			deco(ctx, core, "Spike", V(0.14, 0.45, 0.14), V(k * 0.38, 1.4, -0.5), GOLD, METAL)
		end
	end
	if d.id == "acid_slime" then
		for k = -1, 1, 2 do
			deco(ctx, core, "Drip", V(0.3, 0.6, 0.3), V(k * 0.8, -0.7, -0.6), d.a, NEON, "ball")
		end
	end
	ctx.hover = 0
end

-- ── golems and constructs ─────────────────────────────────────────────────────────
PLANS.golem = function(ctx)
	local b, d = ctx.b, ctx.d
	local mat = if b.material == "metal" then METAL elseif b.mud then MAT.Mud elseif b.cracks then MAT.Basalt elseif b.crystals and b.crystals > 3 then GLASS else SLATE
	makeRoot(ctx, V(2.6, 2, 1.6), 3)
	local root = ctx.root
	local torso = joint(ctx, root, "Torso", V(3, 2.6, 1.8), V(0, -0.6, 0), V(0, 1.0, 0), d.c, mat, if b.mud then "ball" else nil, nil, nil, "Torso")
	local head = joint(ctx, torso, "Head", V(1.2, 1, 1.1), V(0, 1.3, -0.3), V(0, 0.5, 0), d.c, mat, nil, nil, nil, "Head")
	if b.oneEye then
		deco(ctx, head, "Eye", V(0.55, 0.55, 0.2), V(0, 0.05, -0.56), d.eye, NEON, "cyl", A(0, 90, 0))
	else
		eyes(ctx, head, V(0.25, 0.05, -0.58), 0.22)
	end
	deco(ctx, torso, "Core", V(0.9, 0.9, 0.3), V(0, 0.2, -0.92), d.a, NEON)
	local nc = b.crystals or 0
	for k = 1, nc do
		local x = (k - (nc + 1) / 2) * 0.8
		deco(ctx, torso, "Crystal", V(0.5, 1.4, 0.5), V(x, 1.4, 0.55), d.a, NEON, nil, A(-20, 0, x * 18), roleFor("crystal_cluster"))
	end
	if b.rivets then
		for k = -1, 1, 2 do
			deco(ctx, torso, "Rivet", V(0.3, 0.3, 0.3), V(k * 1.2, 0.8, -0.92), rgb(70, 70, 76), METAL, "ball")
		end
	end
	if b.runes then
		deco(ctx, torso, "Rune", V(2.2, 0.12, 0.06), V(0, -0.6, -0.92), b.runes, NEON)
		deco(ctx, torso, "Rune", V(0.12, 1.6, 0.06), V(0.9, 0.1, -0.92), b.runes, NEON)
	end
	if b.cracks then
		for k = -1, 1 do
			deco(ctx, torso, "Crack", V(0.14, 1.6, 0.06), V(k * 0.9, 0.1, -0.92), d.a, NEON, nil, A(0, 0, k * 25 + 10))
		end
		deco(ctx, head, "Crack", V(0.8, 0.1, 0.06), V(0, 0.3, -0.56), d.a, NEON)
	end
	if b.moss then
		deco(ctx, torso, "Moss", V(2.4, 0.3, 1.4), V(-0.2, 1.35, 0.1), rgb(80, 130, 60), GRASS)
	end
	local armRole = nil
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "ArmR" else "ArmL"
		local arm = joint(ctx, torso, nm, V(1.2, 3, 1.2), V(sd * 2, 0.6, 0), V(0, -1.5, 0), d.c, mat, nil, nil, armRole, nm)
		deco(ctx, arm, "Fist", V(1.4, 1.1, 1.4), V(0, -1.6, 0), shade(d.c, 0.9), mat)
		local leg = joint(ctx, root, if sd > 0 then "LegR" else "LegL", V(1.2, 2, 1.2), V(sd * 0.8, -1, 0), V(0, -1, 0), d.c, mat, nil, nil, nil, if sd > 0 then "LegR" else "LegL")
		local _ = leg
		if b.material == "metal" then
			deco(ctx, arm, "Plate", V(1.3, 1.0, 1.3), V(0, 1.0, 0), shade(d.c, 0.85), METAL)
		end
	end
	if b.mud then
		for k = 0, 3 do
			local a = k / 4 * math.pi * 2
			deco(ctx, torso, "Lump", V(0.9, 0.9, 0.9), V(math.cos(a) * 1.2, 0.9, math.sin(a) * 0.6), shade(d.c, 1.1), MAT.Mud, "ball")
		end
		deco(ctx, torso, "Sprout", V(0.15, 0.7, 0.15), V(0.4, 1.5, 0), d.a)
	end
	ctx.hover = 0
end

-- ── elementals: a core with what it's made of circling it ───────────────────────────
PLANS.elemental = function(ctx)
	local b, d = ctx.b, ctx.d
	local el = b.element or "fire"
	local big = if b.big then 1.3 else 1
	makeRoot(ctx, V(1.8, 2, 1.6), 1.0)
	local root = ctx.root
	local coreSz = V(1.6, 2.2, 1.6) * big
	local core
	if el == "fire" then
		-- a ball of fire with tongues of flame licking up out of it, and a tail of it below
		core = joint(ctx, root, "FlameCore", coreSz, V(0, 0.3, 0), V(0, 0, 0), d.c, NEON, "ball", nil, roleFor("flame_core"), "Torso")
		deco(ctx, core, "Heart", V(0.8, 0.8, 0.8) * big, V(0, -0.1, -0.2), d.a, NEON, "ball")
		deco(ctx, core, "Glow", coreSz * 1.35, V(0, 0.1, 0), shade(d.c, 0.9), NEON, "ball").Transparency = 0.6
		for k = -1, 1 do
			local tall = if k == 0 then 1.9 else 1.3
			deco(ctx, core, "Tongue", V(0.5, tall, 0.5) * big, V(k * 0.45 * big, (coreSz.Y / 2 + tall * 0.3) * (if k == 0 then 1 else 0.85), k * 0.1), if k == 0 then d.a else d.c, NEON, nil, A(0, 45, k * -22))
		end
		for k = 1, 3 do
			deco(ctx, root, "Trail", V(1, 1, 1) * (1.1 - k * 0.25) * big, V(0, -0.6 - k * 0.45 * big, 0.15 * k), shade(d.c, 1 - k * 0.1), NEON, "ball").Transparency = 0.15 * k
		end
		if b.big then
			for k = 0, 4 do
				local a = k / 5 * math.pi * 2
				deco(ctx, core, "Crown", V(0.45, 0.9, 0.45), V(math.cos(a) * 1.0, coreSz.Y * 0.42, math.sin(a) * 1.0), rgb(50, 30, 30), CRACKED, nil, A(math.sin(a) * 25, 0, -math.cos(a) * 25))
			end
		end
	elseif el == "frost" then
		-- a cluster of ice: a tall crystal, four leaning out of it
		core = joint(ctx, root, "Crystal", V(0.9, coreSz.Y * 1.1, 0.9), V(0, 0.3, 0), V(0, 0, 0), d.c, ICE, nil, A(0, 45, 0), roleFor("crystal_cluster"), "Torso")
		for k = 0, 3 do
			local a = k / 4 * math.pi * 2 + 0.4
			deco(ctx, core, "Crystal", V(0.55, 1.5, 0.55), V(math.cos(a) * 0.55, -0.15, math.sin(a) * 0.55), shade(d.c, 0.92 + (k % 2) * 0.12), ICE, nil, A(math.sin(a) * 30, 0, -math.cos(a) * 30))
		end
		deco(ctx, core, "Heart", V(0.7, 0.7, 0.7), V(0, 0, -0.2), d.a, NEON, "ball")
	elseif el == "earth" then
		core = joint(ctx, root, "Boulder", coreSz * 1.15, V(0, 0.3, 0), V(0, 0, 0), d.c, ROCK, nil, nil, nil, "Torso")
		deco(ctx, core, "Moss", V(1.6, 0.3, 1.4), V(0, coreSz.Y * 0.55, 0), d.a, GRASS)
	elseif el == "storm" then
		core = joint(ctx, root, "Cloud", V(2.0, 1.8, 1.8) * big, V(0, 0.3, 0), V(0, 0, 0), d.c, SMOOTH, "ball", nil, nil, "Torso")
		for k = 0, 2 do
			local a = k / 3 * math.pi * 2
			deco(ctx, core, "Cloud", V(1.3, 1.3, 1.3), V(math.cos(a) * 0.8, 0.3, math.sin(a) * 0.7), shade(d.c, 1.15), nil, "ball")
		end
		deco(ctx, core, "Bolt", V(0.15, 1.6, 0.15), V(0.2, -0.9, -0.3), d.a, NEON, nil, A(0, 0, 20))
	else
		core = joint(ctx, root, "Core", V(1.0, 1.0, 1.0), V(0, 0.4, 0), V(0, 0, 0), d.c, NEON, "ball", nil, nil, "Torso")
		deco(ctx, core, "Halo", V(1.6, 1.6, 1.6), V(0, 0, 0), d.a, GLASS, "ball").Transparency = 0.6
	end
	-- a face in it
	if el ~= "mana" then
		eyes(ctx, core, V(0.32, coreSz.Y * 0.12, -coreSz.Z / 2 + 0.05), 0.24)
	else
		eyes(ctx, core, V(0.18, 0.05, -0.48), 0.16, rgb(40, 60, 120))
	end
	-- what circles it
	local n = if el == "mana" then 3 elseif el == "earth" then 5 else 4
	for k = 1, n do
		local a = (k - 1) / n * 360
		local sz = if el == "earth" then V(0.8, 0.7, 0.8) elseif el == "frost" then V(0.35, 0.9, 0.35) elseif el == "mana" then V(0.3, 0.3, 0.3) else V(0.5, 0.7, 0.5)
		local r = (if el == "mana" then 1.1 else 2.0) * big
		local color = if el == "earth" then shade(d.c, 1.1) else d.a
		local mat = if el == "earth" then ROCK elseif el == "frost" then ICE else NEON
		joint(ctx, root, "Orb", sz * big, V(0, 0.3 + (k % 2) * 0.5, 0), V(r, 0, 0), color, mat, if el == "fire" or el == "mana" then "ball" else nil, A(0, a, 0), if el == "frost" or el == "earth" then roleFor("crystal_cluster") else nil, "Orb" .. k)
	end
	-- fists that float at its sides
	if el ~= "mana" then
		for _, sd in { 1, -1 } do
			local nm = if sd > 0 then "ArmR" else "ArmL"
			local fist = joint(ctx, core, "Fist", V(0.9, 1.0, 0.9) * big, V(sd * (coreSz.X / 2 + 0.9), 0.0, -0.2), V(0, -0.6, 0), if el == "earth" then shade(d.c, 0.9) else d.a, if el == "earth" then ROCK elseif el == "frost" then ICE else NEON, nil, nil, nil, nm)
			local _ = fist
		end
	end
	ctx.hover = if el == "earth" then 0.6 else 1.6
end

-- ── plants ──────────────────────────────────────────────────────────────────────
PLANS.treant = function(ctx)
	local b, d = ctx.b, ctx.d
	local bark = d.c
	makeRoot(ctx, V(2.2, 1.6, 1.8), 2.0 + 0.8)
	local root = ctx.root
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "LegR" else "LegL"
		local leg = joint(ctx, root, "Root" .. (if sd > 0 then "R" else "L"), V(0.9, 2.2, 0.9), V(sd * 0.6, -0.8, 0), V(0, -1.0, 0), shade(bark, 0.9), WOOD, nil, A(0, 0, sd * 8), roleFor("root_leg"), nm)
		deco(ctx, leg, "Rootlet", V(0.35, 0.3, 1.2), V(sd * 0.3, -1.0, -0.4), shade(bark, 0.8), WOOD, nil, A(0, sd * 30, 0))
		deco(ctx, leg, "Rootlet", V(0.3, 0.3, 1.0), V(sd * 0.2, -1.0, 0.45), shade(bark, 0.8), WOOD, nil, A(0, -sd * 30, 0))
	end
	local trunk = joint(ctx, root, "Trunk", V(1.9, 3.8, 1.6), V(0, -0.5, 0), V(0, 1.9, 0), bark, WOOD, nil, A(-6, 0, 0), roleFor("trunk_bark"), "Torso")
	deco(ctx, trunk, "Knot", V(0.7, 0.7, 0.2), V(0.3, -0.6, -0.82), shade(bark, 0.7), WOOD, "ball")
	-- a face in the bark
	for _, sd in { 1, -1 } do
		deco(ctx, trunk, "Socket", V(0.45, 0.32, 0.1), V(sd * 0.38, 1.0, -0.8), DARK)
	end
	eyes(ctx, trunk, V(0.38, 1.0, -0.82), 0.2)
	deco(ctx, trunk, "Mouth", V(0.8, 0.25, 0.1), V(0, 0.35, -0.8), DARK)
	deco(ctx, trunk, "Moss", V(1.6, 0.4, 1.2), V(-0.2, -1.4, 0.2), rgb(80, 130, 60), GRASS)
	-- branch arms with twigs and leaves
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "ArmR" else "ArmL"
		local arm = joint(ctx, trunk, "Branch" .. (if sd > 0 then "R" else "L"), V(0.6, 3.0, 0.6), V(sd * 1.05, 1.3, 0), V(0, -1.4, 0), shade(bark, 0.95), WOOD, nil, A(6, 0, sd * 18), roleFor("root_leg"), nm)
		deco(ctx, arm, "Twig", V(0.25, 1.1, 0.25), V(sd * 0.3, -1.2, -0.2), shade(bark, 0.9), WOOD, nil, A(0, 0, sd * 40))
		deco(ctx, arm, "Twig", V(0.22, 0.9, 0.22), V(-sd * 0.25, -1.4, 0.1), shade(bark, 0.9), WOOD, nil, A(0, 0, -sd * 35))
		deco(ctx, arm, "Leaves", V(1.0, 0.9, 1.0), V(0, -1.6, 0), d.a, LEAF, "ball")
	end
	local leafy = kitHas("leaf_crown")
	local crown = joint(ctx, trunk, "Canopy", if leafy then V(3.8, 2.4, 3.4) else V(2.6, 1.6, 2.4), V(0, 1.9, 0.1), V(0, 1.0, 0), d.a, LEAF, if leafy then nil else "ball", nil, if leafy then "leaf_crown" else nil, "Head")
	if not leafy then
		for k = 0, 5 do
			local a = k / 6 * math.pi * 2
			deco(ctx, crown, "Leaves", V(1.7, 1.7, 1.7), V(math.cos(a) * 1.35, 0.15 + (k % 2) * 0.45, math.sin(a) * 1.2), shade(d.a, 0.85 + (k % 3) * 0.12), LEAF, "ball")
		end
		deco(ctx, crown, "Leaves", V(1.9, 1.9, 1.9), V(0, 0.9, 0), shade(d.a, 1.05), LEAF, "ball")
	end
	if b.blossoms then
		for k = 0, 5 do
			local a = k / 6 * math.pi * 2
			deco(ctx, crown, "Blossom", V(0.45, 0.45, 0.45), V(math.cos(a) * 1.7, 0.9, math.sin(a) * 1.5), rgb(255, 200, 230), NEON, "ball")
		end
	end
	ctx.hover = 0
end

PLANS.mandrake = function(ctx)
	local d = ctx.d
	makeRoot(ctx, V(1.3, 1.2, 1.3), 1.0)
	local root = ctx.root
	local body = joint(ctx, root, "Bulb", V(1.5, 1.6, 1.5), V(0, 0.1, 0), V(0, 0, 0), d.c, nil, "ball", nil, nil, "Body")
	eyes(ctx, body, V(0.25, 0.25, -0.68), 0.2, DARK)
	deco(ctx, body, "Mouth", V(0.45, 0.32, 0.1), V(0, -0.15, -0.72), rgb(60, 30, 20), nil, "ball")
	if kitHas("leaf_crown") then
		joint(ctx, body, "Leaves", V(1.6, 1.4, 1.6), V(0, 0.8, 0), V(0, 0.6, 0), d.a, LEAF, nil, nil, "leaf_crown", "Head")
	else
		-- a tuft of long leaves out of the top of the root
		local stem = joint(ctx, body, "Stem", V(0.3, 0.4, 0.3), V(0, 0.75, 0), V(0, 0.2, 0), shade(d.a, 0.8), nil, nil, nil, nil, "Head")
		for k = 0, 4 do
			local a = k / 5 * 360
			deco(ctx, stem, "Leaf", V(0.4, 1.3, 0.1), V(0, 0.2, 0), shade(d.a, 0.9 + (k % 2) * 0.2), LEAF, nil, A(0, a, 0) * CFrame.new(0, 0.6 * ctx.s, -0.25 * ctx.s) * A(-28, 0, 0))
		end
	end
	for _, sd in { 1, -1 } do
		joint(ctx, body, "Rootling", V(0.25, 1.0, 0.25), V(sd * 0.35, -0.65, 0), V(0, -0.45, 0), shade(d.c, 0.85), nil, nil, A(0, 0, sd * 10), roleFor("root_leg"), if sd > 0 then "LegR" else "LegL")
		joint(ctx, body, "Rootling", V(0.2, 0.9, 0.2), V(sd * 0.7, 0.05, 0), V(0, -0.4, 0), shade(d.c, 0.85), nil, nil, A(0, 0, sd * 35), roleFor("root_leg"), if sd > 0 then "ArmR" else "ArmL")
	end
	ctx.hover = 0
end

-- a rooted thing with lashing vines (or a kraken's spawn, with arms)
local function tentacles(ctx: Ctx, parent: BasePart, n: number, radius: number, y: number, len: number, w: number, color: Color3, tip: Color3, droop: number)
	for k = 1, n do
		local a = (k - 1) / n * 360 + 20
		local t1 = joint(ctx, parent, "Tentacle", V(w, len, w), V(0, y, 0), V(0, -len / 2, 0), color, nil, nil, A(0, a, 0) * CFrame.new(0, 0, -radius * ctx.s) * A(droop, 0, 0), roleFor("tentacle"), "Tent" .. k)
		joint(ctx, t1, "TentacleTip", V(w * 0.7, len * 0.9, w * 0.7), V(0, -len / 2, 0), V(0, -len * 0.45, 0), tip, nil, nil, A(25, 0, 0), roleFor("tentacle"), "Tent" .. k .. "b")
	end
end

PLANS.vines = function(ctx)
	local d = ctx.d
	makeRoot(ctx, V(1.8, 1.4, 1.8), 1.3)
	local root = ctx.root
	local pod = joint(ctx, root, "Pod", V(1.9, 1.6, 1.9), V(0, -0.2, 0), V(0, 0, 0), d.c, LEAF, "ball", nil, nil, "Body")
	deco(ctx, root, "RootMat", V(2.8, 0.3, 2.8), V(0, -1.15, 0), shade(d.c, 0.7), WOOD)
	local bloom = joint(ctx, pod, "Bloom", V(1.2, 0.9, 1.2), V(0, 0.8, 0), V(0, 0.45, 0), d.a, nil, nil, nil, nil, "Head")
	for k = 0, 4 do
		local a = k / 5 * 360
		deco(ctx, bloom, "Petal", V(0.6, 0.12, 1.1), V(0, 0.35, 0), d.a, nil, nil, A(0, a, 0) * CFrame.new(0, 0, -0.55 * ctx.s) * A(35, 0, 0))
	end
	eyes(ctx, bloom, V(0.22, 0.4, -0.35), 0.2)
	-- (the vines grow up and out of the pod, and lash forward)
	for k = 1, 5 do
		local a = (k - 1) / 5 * 360 + 36
		local t1 = joint(ctx, pod, "Tentacle", V(0.3, 2.0, 0.3), V(0, 0.4, 0), V(0, 1.0, 0), shade(d.c, 1.1), nil, nil, A(0, a, 0) * CFrame.new(0, 0, -0.6 * ctx.s) * A(-30, 0, 0), roleFor("tentacle"), "Tent" .. k)
		local t2 = joint(ctx, t1, "TentacleTip", V(0.22, 1.8, 0.22), V(0, 1.0, 0), V(0, 0.9, 0), shade(d.c, 1.2), nil, nil, A(-35, 0, 0), roleFor("tentacle"), "Tent" .. k .. "b")
		deco(ctx, t2, "Thorn", V(0.12, 0.4, 0.12), V(0, 0.6, -0.15), d.a, nil, nil, A(-40, 0, 0))
	end
	ctx.hover = 0
end

PLANS.kraken = function(ctx)
	local d = ctx.d
	makeRoot(ctx, V(2.2, 1.6, 2.2), 2.4)
	local root = ctx.root
	local mantle = joint(ctx, root, "Mantle", V(2.4, 3.0, 2.4), V(0, 0.6, 0.4), V(0, 0.4, 0), d.c, nil, nil, A(-20, 0, 0), roleFor("shell_dome"), "Body")
	deco(ctx, mantle, "Fin", V(0.12, 1.2, 1.4), V(0, 1.1, 0.6), d.a, nil, nil, nil, roleFor("fin"))
	local headB = deco(ctx, root, "Face", V(2.0, 1.2, 1.8), V(0, -0.4, 0), shade(d.c, 1.05))
	eyes(ctx, headB, V(0.65, 0.2, -0.82), 0.42)
	deco(ctx, headB, "Beak", V(0.4, 0.4, 0.4), V(0, -0.45, -0.75), DARK, nil, nil, A(45, 0, 0))
	tentacles(ctx, root, 8, 0.75, -0.9, 1.6, 0.42, shade(d.c, 0.95), d.a, 40)
	ctx.hover = 0
end

-- ── hoppers: toads, crickets, imps, mimics ─────────────────────────────────────────
PLANS.toad = function(ctx)
	local d = ctx.d
	makeRoot(ctx, V(2.0, 1.2, 2.2), 1.0)
	local root = ctx.root
	local body = joint(ctx, root, "Body", V(2.1, 1.4, 2.3), V(0, 0.1, 0.1), V(0, 0, 0), d.c, nil, nil, A(-12, 0, 0), nil, "Body")
	deco(ctx, body, "Belly", V(1.8, 0.4, 2.0), V(0, -0.55, 0), d.a)
	for k = 0, 4 do
		deco(ctx, body, "Wart", V(0.3, 0.3, 0.3), V(math.cos(k * 1.3) * 0.7, 0.7, math.sin(k * 1.3) * 0.8), shade(d.c, 0.8), nil, "ball")
	end
	local head = joint(ctx, body, "ToadHead", V(2.0, 0.8, 1.1), V(0, 0.2, -1.1), V(0, 0.1, -0.4), d.c, nil, nil, A(12, 0, 0), nil, "Head")
	joint(ctx, head, "Jaw", V(1.9, 0.35, 1.05), V(0, -0.35, 0.2), V(0, -0.1, -0.5), d.a, nil, nil, nil, nil, "Jaw")
	for _, sd in { 1, -1 } do
		local e = deco(ctx, head, "EyeBulb", V(0.6, 0.6, 0.6), V(sd * 0.6, 0.45, -0.1), d.c, nil, "ball")
		deco(ctx, e, "Eye", V(0.3, 0.3, 0.3), V(0, 0.1, -0.22), d.eye, NEON, "ball")
		local leg = joint(ctx, root, "HindLeg", V(0.7, 1.4, 1.6), V(sd * 1.05, -0.3, 0.7), V(0, -0.3, 0), shade(d.c, 0.95), nil, nil, A(0, 0, sd * 15), nil, if sd > 0 then "LegR" else "LegL")
		deco(ctx, leg, "Foot", V(0.8, 0.2, 1.2), V(sd * 0.1, -0.85, -0.6), shade(d.c, 0.85))
		local arm = joint(ctx, root, "FrontLeg", V(0.35, 1.1, 0.35), V(sd * 0.75, -0.2, -0.75), V(0, -0.5, 0), shade(d.c, 0.95), nil, nil, A(0, 0, sd * 12), nil, if sd > 0 then "ArmR" else "ArmL")
		deco(ctx, arm, "Hand", V(0.5, 0.15, 0.6), V(0, -0.55, -0.1), shade(d.c, 0.85))
	end
	ctx.hover = 0
end

PLANS.cricket = function(ctx)
	local d = ctx.d
	makeRoot(ctx, V(1.0, 0.8, 2.2), 0.9)
	local root = ctx.root
	local body = joint(ctx, root, "Thorax", V(1.0, 0.9, 1.4), V(0, 0, -0.3), V(0, 0, 0), d.c, nil, nil, nil, roleFor("thorax_insect"), "Body")
	joint(ctx, root, "Abdomen", V(1.1, 0.9, 1.6), V(0, 0, 0.4), V(0, 0, 0.75), shade(d.c, 0.92), nil, nil, A(8, 0, 0), roleFor("abdomen_insect", "abdomen"), "Abdomen")
	local head = joint(ctx, body, "InsectHead", V(0.9, 0.9, 0.7), V(0, 0.1, -0.7), V(0, 0, -0.3), d.c, nil, nil, nil, roleFor("head_insect"), "Head")
	eyes(ctx, head, V(0.38, 0.15, -0.15), 0.32, DARK)
	for _, sd in { 1, -1 } do
		local nm = if sd > 0 then "R" else "L"
		joint(ctx, head, "Ant" .. nm, V(0.06, 2.2, 0.06), V(sd * 0.2, 0.35, -0.3), V(0, 1.1, 0), d.a, nil, nil, A(-70, 0, -sd * 15), roleFor("antenna"), "Ant" .. nm)
		-- the big hind legs: a thick thigh folded up and back, the shin down to the ground behind
		local hind = joint(ctx, root, "HindLeg", V(0.36, 1.5, 0.5), V(sd * 0.55, 0, 0.25), V(0, 0.75, 0), d.a, nil, nil, A(55, 0, -sd * 12), roleFor("leg_insect"), if sd > 0 then "LegR" else "LegL")
		local s = ctx.s
		local knee = (hind.CFrame * CFrame.new(0, 0.75 * s, 0)).Position
		local foot = V(knee.X + sd * 0.15 * s, 0, knee.Z + 0.7 * s)
		local up_ = (knee - foot).Unit
		local shin = newPart(ctx.model, "Shin", V(0.18 * s, (knee - foot).Magnitude, 0.18 * s), CFrame.fromMatrix((knee + foot) / 2, up_:Cross(V(0, 0, 1)).Unit, up_), shade(d.a, 0.85), nil, nil)
		weld(hind, shin)
		insectLeg(ctx, root, (if sd > 0 then "LegR" else "LegL") .. "1", V(sd * 0.45, -0.2, -0.6), sd, 25, 25, 0.6, 0.14, d.a, 0, 0.4)
	end
	ctx.hover = 0
end

PLANS.imp = function(ctx)
	local d = ctx.d
	local P = { leg = 0.9, legW = 0.4, tw = 1.0, th = 1.0, td = 0.7, arm = 1.0, armW = 0.35 }
	local pal = palette(ctx)
	ctx.b.head = "demon"
	ctx.b.outfit = "none"
	ctx.b.wings = false -- (its own small wings and tail, below)
	ctx.b.tail = false
	pal.o = "none"
	makeRoot(ctx, V(1.0, 0.8, 0.8), P.leg + 0.4)
	local root = ctx.root
	humanLegs(ctx, root, V(0, -0.4, 0), P, pal)
	ctx.b.headScale = 1.15
	local torso = upperBody(ctx, root, V(0, -0.2, 0), P, pal, 8)
	wingPair(ctx, torso, V(0.3, 0.5, 0.35), 1.6, 1.0, shade(d.c, 0.6), "membrane")
	tailChain(ctx, root, V(0, -0.3, 0.35), 2, 0.18, 0.8, d.c, 10, 0.2)
	ctx.hover = 0
end

PLANS.mimic = function(ctx)
	local d = ctx.d
	makeRoot(ctx, V(2.0, 1.2, 1.4), 1.05)
	local root = ctx.root
	local chest = joint(ctx, root, "Chest", V(2.0, 1.1, 1.4), V(0, -0.05, 0), V(0, 0, 0), d.c, WOOD, nil, nil, nil, "Body")
	for k = -1, 1, 2 do
		deco(ctx, chest, "Band", V(0.2, 1.15, 1.45), V(k * 0.65, 0, 0), d.a, METAL)
	end
	deco(ctx, chest, "Lock", V(0.35, 0.4, 0.1), V(0, 0.25, -0.73), d.a, METAL)
	for k = -3, 3 do
		deco(ctx, chest, "Tooth", V(0.14, 0.26, 0.14), V(k * 0.26, 0.6, -0.62), BONE)
	end
	deco(ctx, chest, "Tongue", V(0.5, 0.15, 1.3), V(0, 0.45, -0.9), rgb(200, 70, 90), nil, nil, A(-10, 0, 0))
	-- the lid hinges at the back
	local lid = joint(ctx, chest, "Lid", V(2.05, 0.55, 1.45), V(0, 0.55, 0.7), V(0, 0.27, -0.72), d.c, WOOD, nil, nil, nil, "Lid")
	for k = -1, 1, 2 do
		deco(ctx, lid, "Band", V(0.22, 0.6, 1.5), V(k * 0.65, 0, 0), d.a, METAL)
	end
	for k = -3, 3 do
		deco(ctx, lid, "Tooth", V(0.14, 0.26, 0.14), V(k * 0.26, -0.3, -0.62), BONE)
	end
	eyes(ctx, lid, V(0.35, -0.2, -0.5), 0.2)
	for _, sd in { 1, -1 } do
		for k = 1, 2 do
			joint(ctx, root, "Leg", V(0.25, 0.7, 0.25), V(sd * 0.75, -0.55, if k == 1 then -0.45 else 0.45), V(0, -0.3, 0), shade(d.c, 0.8), WOOD, nil, nil, nil, (if sd > 0 then "LegR" else "LegL") .. k)
		end
	end
	ctx.hover = 0
end

-- ── half and half: centaurs, a goblin on a wolf, a cockatrice ──────────────────────────
PLANS.centaur = function(ctx)
	local b, d = ctx.b, ctx.d
	local q = QUAD.horse
	makeRoot(ctx, V(q.bw, q.bh, q.bl), q.leg + q.bh / 2)
	local root = ctx.root
	local body = joint(ctx, root, "Body", V(q.bw, q.bh, q.bl), V(0, 0, 0), V(0, 0, 0), b.coat or d.a, nil, nil, nil, nil, "Body")
	deco(ctx, body, "Chest", V(q.bw * 1.06, q.bh * 1.05, q.bl * 0.35), V(0, 0.05, -q.bl * 0.3), b.coat or d.a)
	for k = 1, 2 do
		local z = if k == 1 then -q.bl / 2 + 0.5 else q.bl / 2 - 0.5
		for _, sd in { 1, -1 } do
			local nm = (if sd > 0 then "LegR" else "LegL") .. k
			local leg = joint(ctx, root, "Hoof" .. (if sd > 0 then "R" else "L") .. k, V(q.legW, q.leg + 0.25, q.legW * 1.1), V(sd * q.bw * 0.32, -q.bh / 2 + 0.15, z), V(0, -(q.leg + 0.25) / 2, 0), shade(b.coat or d.a, 0.9), nil, nil, nil, roleFor("hoof_leg"), nm)
			deco(ctx, leg, "Hoof", V(q.legW * 1.25, 0.35, q.legW * 1.4), V(0, -(q.leg + 0.25) / 2 + 0.17, -0.05), DARK)
		end
	end
	tailChain(ctx, body, V(0, q.bh * 0.3, q.bl / 2), 2, 0.4, 1.1, b.hair or DARK, -40, 0.1)
	if b.armor then
		deco(ctx, body, "Barding", V(q.bw * 1.08, q.bh * 0.7, q.bl * 0.5), V(0, 0.1, -q.bl * 0.22), IRON, METAL)
	end
	local P = table.clone(BUILDS.normal)
	P.tw, P.th = 1.8, 2.0
	local pal = palette(ctx)
	upperBody(ctx, body, V(0, q.bh / 2 - 0.2, -q.bl / 2 + 0.55), P, pal, 0)
	ctx.hover = 0
end

PLANS.rider = function(ctx)
	local b, d = ctx.b, ctx.d
	local q = QUAD.wolf
	makeRoot(ctx, V(q.bw, q.bh, q.bl), q.leg + q.bh / 2)
	local root = ctx.root
	local wolfC = b.mountC or rgb(84, 80, 86)
	local body = joint(ctx, root, "Body", V(q.bw, q.bh, q.bl), V(0, 0, 0), V(0, 0, 0), wolfC, nil, nil, nil, nil, "Body")
	deco(ctx, body, "Chest", V(q.bw * 1.08, q.bh * 1.08, q.bl * 0.42), V(0, 0.05, -q.bl * 0.27), wolfC)
	deco(ctx, body, "Saddle", V(q.bw * 1.1, 0.25, 1.2), V(0, q.bh / 2 + 0.05, 0.1), LEATHER, FABRIC)
	for k = 1, 2 do
		local z = -q.bl / 2 + 0.55 + (k - 1) * (q.bl - 1.1)
		for _, sd in { 1, -1 } do
			local nm = (if sd > 0 then "LegR" else "LegL") .. k
			local leg = joint(ctx, root, nm, V(q.legW, q.leg + 0.25, q.legW * 1.1), V(sd * q.bw * 0.32, -q.bh / 2 + 0.15, z), V(0, -(q.leg + 0.25) / 2, 0), wolfC, nil, nil, nil, nil, nm)
			deco(ctx, leg, "Paw", V(q.legW * 1.25, 0.25, q.legW * 1.5), V(0, -(q.leg + 0.25) / 2 + 0.12, -0.08), shade(wolfC, 0.75))
		end
	end
	local saved = d.c
	d.c = wolfC
	deco(ctx, body, "Neck", V(q.bw * 0.6, q.bh * 0.6 + q.neck, 1.0), V(0, q.bh * 0.15 + q.neck * 0.5, -q.bl / 2 + 0.2), wolfC, nil, nil, A(-25, 0, 0))
	-- (the mount's head and jaw are HeadM / JawM: the rider has the Head)
	beastHead(ctx, body, q, V(0, q.bh * 0.25 + q.neck, -q.bl / 2 - 0.1), 0, "M")
	tailChain(ctx, body, V(0, q.bh * 0.3, q.bl / 2), 2, 0.55, 1.2, wolfC, 30, 0.1)
	d.c = saved
	-- the goblin astride it
	local P = table.clone(BUILDS.lean)
	local pal = palette(ctx)
	for _, sd in { 1, -1 } do
		deco(ctx, body, "RiderLeg", V(0.5, 1.2, 0.5), V(sd * (q.bw / 2 + 0.2), q.bh / 2 - 0.3, 0.1), pal.skin, nil, nil, A(-20, 0, sd * 10))
	end
	ctx.b.head = "goblin"
	upperBody(ctx, body, V(0, q.bh / 2 + 0.15, 0.1), P, pal, 10)
	ctx.hover = 0
end

PLANS.cockatrice = function(ctx)
	local d = ctx.d
	makeRoot(ctx, V(1.2, 1.2, 2.0), 1.9)
	local root = ctx.root
	local body = joint(ctx, root, "Body", V(1.3, 1.3, 2.0), V(0, 0.2, 0), V(0, 0, 0), d.c, FABRIC, nil, A(10, 0, 0), nil, "Torso")
	deco(ctx, body, "Neck", V(0.55, 1.4, 0.55), V(0, 0.8, -0.9), d.c, FABRIC, nil, A(-20, 0, 0))
	local head = joint(ctx, body, "BirdHead", V(0.7, 0.75, 0.8), V(0, 1.5, -1.2), V(0, 0.2, -0.2), d.c, FABRIC, nil, A(-10, 0, 0), nil, "Head")
	deco(ctx, head, "Beak", V(0.25, 0.22, 0.45), V(0, -0.05, -0.6), rgb(230, 190, 80))
	deco(ctx, head, "Comb", V(0.12, 0.45, 0.6), V(0, 0.5, 0), d.a)
	deco(ctx, head, "Wattle", V(0.18, 0.35, 0.18), V(0, -0.45, -0.35), d.a)
	eyes(ctx, head, V(0.28, 0.12, -0.25), 0.16)
	wingPair(ctx, body, V(0.6, 0.3, 0), 1.6, 1.1, shade(d.c, 0.9), "feather")
	tailChain(ctx, body, V(0, 0, 1.0), 3, 0.45, 1.0, rgb(90, 120, 70), 15, 0.25)
	for _, sd in { 1, -1 } do
		local leg = joint(ctx, root, "TalonLeg", V(0.24, 1.9, 0.24), V(sd * 0.35, -0.4, 0.1), V(0, -0.95, 0), rgb(220, 180, 80), nil, nil, nil, nil, if sd > 0 then "LegR" else "LegL")
		deco(ctx, leg, "Talon", V(0.45, 0.14, 0.6), V(0, -0.95, -0.15), rgb(120, 90, 50))
	end
	ctx.hover = 0
end

Monsters.PLANS = PLANS

-- build a kind: its body from its plan, a Humanoid that carries it, and its attributes
-- (Gait, Kind, Rank, Family, Behaviour, Attack, Size) for the client's animation
function Monsters.build(kind: string): (Model, Humanoid)
	local d0 = Monsters.DEFS[kind] or Monsters.DEFS.goblin
	local d = table.clone(d0)
	local b = table.clone(d0.b or {})
	local model = Instance.new("Model")
	model.Name = d.name
	local ctx: Ctx = { model = model, root = nil :: any, s = d.size, d = d, b = b, hip = 0, hover = 0, meshHead = false }
	local plan = PLANS[b.plan or "humanoid"] or PLANS.humanoid
	plan(ctx)
	local s = d.size
	local root = ctx.root
	-- stand it on the ground: the lowest thing it shows (a foot, a talon, a trailing flame) at
	-- y = 0. A walker's hip moves with it; a hoverer keeps the height it flies at.
	local lowest = math.huge
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p.Transparency < 0.95 then
			local h = p.Size / 2
			local cf = p.CFrame
			for _, c in { V(h.X, h.Y, h.Z), V(-h.X, h.Y, h.Z), V(h.X, -h.Y, h.Z), V(h.X, h.Y, -h.Z), V(-h.X, -h.Y, h.Z), V(-h.X, h.Y, -h.Z), V(h.X, -h.Y, -h.Z), V(-h.X, -h.Y, -h.Z) } do
				lowest = math.min(lowest, (cf * c).Y)
			end
		end
	end
	if lowest < math.huge and math.abs(lowest) > 0.01 then
		local shift = CFrame.new(0, -lowest, 0)
		for _, p in model:GetDescendants() do
			if p:IsA("BasePart") then
				p.CFrame = shift * p.CFrame
			end
		end
		local du = -lowest / s
		ctx.hip += du
		local g = d.gait
		if g == "flyer" or g == "float" or g == "orbit" then
			ctx.hover = math.max(0.3, (ctx.hover or 0) - du)
		end
	end
	local glow = Instance.new("PointLight")
	glow.Color = d.eye
	glow.Range = 8 * s
	glow.Brightness = 1.4
	glow.Parent = root
	local hum = Instance.new("Humanoid")
	hum.RigType = Enum.HumanoidRigType.R6
	-- how high the root rides above the ground (a flier's hover on top of its legs)
	hum.HipHeight = math.max(0.1, (ctx.hip + (ctx.hover or 0)) * s)
	hum.WalkSpeed = d.speed
	hum.MaxHealth = d.hp
	hum.Health = d.hp
	hum.BreakJointsOnDeath = false -- (it falls and fades on the client instead of coming apart)
	hum.DisplayName = d.name
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	hum.NameDisplayDistance = 80
	hum.HealthDisplayDistance = 80
	hum.Parent = model
	model:SetAttribute("Gait", d.gait)
	model:SetAttribute("Kind", kind)
	model:SetAttribute("Rank", d.rank)
	model:SetAttribute("Family", d.family)
	model:SetAttribute("Behaviour", d.beh)
	model:SetAttribute("Attack", d.atk)
	model:SetAttribute("Size", s)
	-- smooth Blender meshes over the parts, if the place has the kit (Hunter/MeshLibrary)
	MeshLibrary.dress(model, d.gait)
	return model, hum
end

return Monsters
