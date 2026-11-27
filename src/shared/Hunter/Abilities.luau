--[[
	THE LIVE CITY'S MOVES (BitLeveling, ORIGINAL game content), shared by the server
	(server/HunterLive decides every hit), the client's skill bar and loadout panel, and
	client/SkillFx (which draws them).

	Hunters' skills here are mana-driven techniques and spells: each move has a rank TIER (E..S),
	a mana cost, a cast time (or none), a cooldown, a reach, and a damage, heal, guard or buff
	that all come from one formula, so an S-rank move clearly outclasses an E-rank one and low
	tiers are cheap and quick:

		number = slot base x tier table x shape factor x the move's own factor (power, size...)

	Using a move needs the Hunter's rank to be at least its tier, its class (or one of its
	classes), and the life-sim skill that unlocks it, if it names one (Games/BitLeveling/
	Skills.luau: class trees, magic schools, Hunter craft). A player's mana pool grows with rank.

	SLOTS: Q quick, E move, R power, T guard/support, G ultimate. Any unlocked move of a slot can
	go in it (the loadout panel); by default the slot takes the best one unlocked.

	GROUPS (for the loadout's filter): each class's own signature moves; twelve magic schools
	(fire, frost, lightning, wind, earth, water, holy, void, venom, life, arcane, sound); six
	physical arts (sword, spear, fist, archery, shield, assassination); Hunter craft (anyone).

	A move is DATA: { id, name, slot, tier, shape, element, desc, ... }. The SHAPE says how the
	server resolves it (its kind) and how SkillFx draws it; the element gives it colour,
	particles and material. Signature moves also have a hand-made effect (fx = their id).

	Never the System's skills, never the Shadow Monarch's, never the dead raised: constructs are
	mana given a shape.
]]

local Abilities = {}

Abilities.SLOTS = { "Q", "E", "R", "T", "G" }
Abilities.SLOT_INFO = {
	Q = { name = "Quick", key = "Q" },
	E = { name = "Move", key = "E" },
	R = { name = "Power", key = "R" },
	T = { name = "Guard", key = "T" },
	G = { name = "Ultimate", key = "G" },
}
Abilities.CLASSES = { "fighter", "mage", "assassin", "tanker", "ranger", "healer" }
Abilities.TIER_LETTER = { "E", "D", "C", "B", "A", "S" }

-- ── the scaling ──
-- by tier (1 E .. 6 S): every table rises
Abilities.TIER = {
	power = { 1.0, 1.3, 1.65, 2.1, 2.7, 3.5 }, -- damage
	mana = { 1.0, 1.35, 1.8, 2.4, 3.2, 4.2 }, -- mana cost
	cd = { 0.8, 0.9, 1.0, 1.1, 1.22, 1.38 }, -- cooldown (big moves take longer to come back)
	cast = { 0.6, 0.75, 0.9, 1.0, 1.15, 1.35 }, -- cast time
	size = { 1.0, 1.1, 1.22, 1.36, 1.55, 1.8 }, -- reach and area
	dur = { 1.0, 1.08, 1.18, 1.3, 1.45, 1.65 }, -- how long it lasts
	heal = { 0.15, 0.19, 0.24, 0.3, 0.38, 0.5 }, -- share of max health
	guard = { 0.2, 0.26, 0.32, 0.4, 0.48, 0.58 }, -- share of damage turned aside
	buff = { 0.12, 0.17, 0.23, 0.3, 0.38, 0.5 }, -- extra damage
	debuff = { 0.15, 0.19, 0.24, 0.3, 0.36, 0.45 }, -- weaken / expose
}
-- by slot
Abilities.SLOT_BASE = {
	Q = { mult = 1.6, mana = 8, cd = 4, cast = 0, heal = 1, guard = 0.7, buff = 0.8 },
	E = { mult = 1.2, mana = 12, cd = 7.5, cast = 0, heal = 0.8, guard = 0.8, buff = 0.8 },
	R = { mult = 2.4, mana = 20, cd = 11, cast = 0.3, heal = 1.3, guard = 0.9, buff = 1 },
	T = { mult = 1.4, mana = 18, cd = 20, cast = 0.2, heal = 1.1, guard = 1, buff = 1 },
	G = { mult = 3.2, mana = 42, cd = 48, cast = 0.6, heal = 2, guard = 1.3, buff = 1.4 },
}
-- a Hunter's mana: the pool by rank, and how fast it comes back (a share of the pool a second)
Abilities.MANA = { pool = { 100, 150, 220, 320, 460, 680 }, regen = 0.02 }
function Abilities.manaPool(rank: number, intelligence: number?, willpower: number?): (number, number)
	local base = Abilities.MANA.pool[math.clamp(math.floor(rank), 1, 6)] or 100
	local pool = math.floor(base * (1 + ((intelligence or 0) + (willpower or 0)) / 600))
	return pool, pool * Abilities.MANA.regen
end

-- what each kind does on the server
Abilities.KINDS = {
	projectile = "flies at the nearest monster in front (or a fan of them); may burst",
	dash = "moves you forward (or back) through monsters; may land in an area",
	aoe = "hits an area at once: around you, in front, at the aimed spot or on a target",
	beam = "a straight line that hits everything along it",
	strike = "several blows on the nearest monster in reach",
	chain = "hits one monster, then jumps to the next ones",
	zone = "an area on the ground that keeps working for a while",
	buff = "makes you (and allies) hit harder or move faster for a while",
	heal = "heals you and nearby players (some keep healing, some cleanse)",
	shield = "you (and allies) take less damage for a while",
	taunt = "monsters near you must chase you; you brace",
	construct = "a construct of mana (never a soul) that fights for a few seconds",
	blink = "you vanish and reappear a few metres away",
}

--[[ SHAPES: how a move is resolved (kind) and drawn (SkillFx draws each shape, in the
	move's element). dmg: total damage against slot x tier (0: none). def: defaults; the
	geometry ones (range, radius, width, splash, jump) grow with tier and the move's `size`. ]]
local GEOM = { range = true, radius = true, width = true, splash = true, jump = true }
Abilities.SHAPES = {
	projectile = { kind = "projectile", dmg = 1.0, def = { range = 60, speed = 130 } },
	volley = { kind = "projectile", dmg = 0.62, def = { range = 55, count = 3, arc = 0.7, speed = 150 } },
	wave = { kind = "beam", dmg = 0.9, def = { range = 45, width = 4 } },
	lance = { kind = "beam", dmg = 0.95, def = { range = 65, width = 3.5 } },
	spikes = { kind = "beam", dmg = 0.9, def = { range = 36, width = 6, stun = 0.4 } },
	nova = { kind = "aoe", dmg = 0.8, def = { center = "self", radius = 15 } },
	shockwave = { kind = "aoe", dmg = 0.75, def = { center = "self", radius = 18, knock = 40 } },
	cone = { kind = "aoe", dmg = 0.95, def = { center = "self", range = 20, arc = 0.55 } },
	slash = { kind = "aoe", dmg = 1.0, instant = true, def = { center = "self", range = 12, arc = 0.15 } },
	strike = { kind = "strike", dmg = 1.2, instant = true, def = { range = 11, hits = 3 } },
	meteor = { kind = "aoe", dmg = 1.15, def = { center = "aim", range = 60, radius = 15, delay = 1 } },
	pillar = { kind = "aoe", dmg = 1.0, def = { center = "aim", range = 45, radius = 9 } },
	smite = { kind = "aoe", dmg = 1.05, def = { center = "target", range = 55, radius = 6 } },
	implode = { kind = "aoe", dmg = 0.9, def = { center = "aim", range = 45, radius = 13, pull = true, delay = 0.6 } },
	eruption = { kind = "aoe", dmg = 0.9, def = { center = "aim", range = 45, radius = 11, launch = true } },
	rain = { kind = "zone", dmg = 1.5, def = { center = "aim", range = 50, radius = 14, duration = 3, tick = 0.5 } },
	field = { kind = "zone", dmg = 1.4, def = { center = "aim", range = 40, radius = 12, duration = 5, tick = 0.5 } },
	storm = { kind = "zone", dmg = 1.7, def = { center = "aim", range = 55, radius = 20, duration = 5, tick = 0.5 } },
	wall = { kind = "zone", dmg = 1.2, def = { center = "front", range = 12, radius = 9, duration = 6, tick = 0.5 } },
	orbit = { kind = "zone", dmg = 1.3, def = { center = "self", follow = true, radius = 8, duration = 6, tick = 0.5 } },
	chain = { kind = "chain", dmg = 0.8, def = { range = 55, chains = 3, jump = 18 } },
	dash = { kind = "dash", dmg = 0.75, instant = true, def = { range = 26, width = 5 } },
	leap = { kind = "dash", dmg = 0.9, instant = true, def = { center = "aim", range = 30, width = 4, radius = 9 } },
	blink = { kind = "blink", dmg = 0, instant = true, def = { range = 24 } },
	dome = { kind = "shield", dmg = 0, guard = true, def = { radius = 16, allies = true, duration = 6 } },
	ward = { kind = "shield", dmg = 0, guard = true, def = { duration = 6 } },
	aura = { kind = "buff", dmg = 0, buff = "dmg", def = { duration = 8 } },
	haste = { kind = "buff", dmg = 0, buff = "speed", def = { duration = 6 } },
	motes = { kind = "heal", dmg = 0, heal = true, def = { radius = 20 } },
	renew = { kind = "heal", dmg = 0, heal = true, hot = true, def = { radius = 20, duration = 6, tick = 1 } },
	cleanse = { kind = "heal", dmg = 0, heal = true, def = { radius = 22, cleanse = true } },
	taunt = { kind = "taunt", dmg = 0.35, guard = true, def = { radius = 32, duration = 5 } },
	curse = { kind = "aoe", dmg = 0.4, def = { center = "aim", range = 40, radius = 12, duration = 6 } },
	construct = { kind = "construct", dmg = 2.0, def = { center = "front", range = 6, duration = 9, tick = 0.5, construct = { style = "knight", speed = 16, reach = 7 } } },
}

-- element palettes (RGB): core, glow, dark
Abilities.ELEMENTS = {
	physical = { name = "Steel", core = { 236, 226, 212 }, glow = { 255, 206, 140 }, dark = { 90, 80, 70 } },
	fire = { name = "Fire", core = { 255, 118, 36 }, glow = { 255, 214, 96 }, dark = { 150, 32, 10 } },
	frost = { name = "Frost", core = { 150, 218, 255 }, glow = { 232, 250, 255 }, dark = { 50, 110, 200 } },
	lightning = { name = "Lightning", core = { 150, 175, 255 }, glow = { 240, 244, 255 }, dark = { 70, 60, 200 } },
	wind = { name = "Wind", core = { 160, 250, 215 }, glow = { 236, 255, 246 }, dark = { 60, 150, 130 } },
	earth = { name = "Earth", core = { 168, 124, 82 }, glow = { 255, 184, 100 }, dark = { 80, 58, 40 } },
	water = { name = "Water", core = { 60, 150, 255 }, glow = { 190, 235, 255 }, dark = { 16, 60, 140 } },
	holy = { name = "Holy", core = { 255, 228, 140 }, glow = { 255, 250, 224 }, dark = { 200, 150, 60 } },
	void = { name = "Void", core = { 132, 60, 224 }, glow = { 222, 164, 255 }, dark = { 22, 6, 42 } },
	venom = { name = "Venom", core = { 130, 222, 80 }, glow = { 214, 255, 166 }, dark = { 50, 100, 30 } },
	life = { name = "Life", core = { 110, 230, 120 }, glow = { 230, 255, 190 }, dark = { 60, 120, 50 } },
	mana = { name = "Mana", core = { 90, 160, 255 }, glow = { 186, 224, 255 }, dark = { 30, 60, 160 } },
	sound = { name = "Sound", core = { 200, 170, 255 }, glow = { 250, 240, 255 }, dark = { 90, 70, 150 } },
}

-- the magic schools: their element, and the four school spells (Skills.luau) that open their
-- moves (an E move needs the 1st, D or C the 2nd, B the 3rd, A and S the 4th)
Abilities.SCHOOLS = {
	{ id = "fire", name = "Fire", element = "fire", skills = { "sk_fire_fireball", "sk_fire_ring", "sk_fire_focus", "sk_fire_inferno" } },
	{ id = "frost", name = "Frost", element = "frost", skills = { "sk_frost_shard", "sk_frost_spikes", "sk_frost_deep", "sk_frost_blizzard" } },
	{ id = "lightning", name = "Lightning", element = "lightning", skills = { "sk_storm_spark", "sk_storm_thunderclap", "sk_storm_conduit", "sk_storm_thunderstorm" } },
	{ id = "wind", name = "Wind", element = "wind", skills = { "sk_wind_gale", "sk_wind_blades", "sk_wind_rider", "sk_wind_tempest" } },
	{ id = "earth", name = "Earth", element = "earth", skills = { "sk_earth_skin", "sk_earth_pillars", "sk_earth_bedrock", "sk_earth_colossus" } },
	{ id = "water", name = "Water", element = "water", skills = { "sk_water_bullet", "sk_water_surge", "sk_water_current", "sk_water_maelstrom" } },
	{ id = "holy", name = "Holy", element = "holy", skills = { "sk_holy_smite", "sk_holy_pillar", "sk_holy_ground", "sk_holy_dawn" } },
	{ id = "void", name = "Void", element = "void", skills = { "sk_void_orb", "sk_void_well", "sk_void_null", "sk_void_singularity" } },
	{ id = "venom", name = "Venom", element = "venom", skills = { "sk_venom_dart", "sk_venom_miasma", "sk_venom_tolerance", "sk_venom_bloom" } },
	{ id = "life", name = "Life", element = "life", skills = { "sk_life_touch", "sk_life_bloom", "sk_life_wellspring", "sk_life_sanctum" } },
	{ id = "arcane", name = "Arcane", element = "mana", skills = { "sk_arcane_missile", "sk_arcane_ward", "sk_arcane_flow", "sk_arcane_barrage" } },
	{ id = "sound", name = "Sound", element = "sound", skills = { "sk_sound_pulse", "sk_sound_boom", "sk_sound_ear", "sk_sound_crescendo" } },
}
local TIER_STEP = { 1, 2, 2, 3, 4, 4 }
-- the physical arts: who can learn them (by class and rank)
Abilities.ARTS = {
	{ id = "sword", name = "Sword Arts", classes = { "fighter", "assassin" } },
	{ id = "spear", name = "Spear Arts", classes = { "fighter", "tanker" } },
	{ id = "fist", name = "Fist Arts", classes = { "fighter", "tanker" } },
	{ id = "archery", name = "Archery", classes = { "ranger" } },
	{ id = "shield", name = "Shield Arts", classes = { "tanker" } },
	{ id = "assassination", name = "Assassination", classes = { "assassin" } },
}

local list: { any } = {}
-- rows: { id, name, slot, tier, shape, desc, extras }
local function add(base: any, rows: { any })
	for _, r in rows do
		local ab: any = { id = r[1], name = r[2], slot = r[3], tier = r[4], shape = r[5], desc = r[6] }
		for k, v in base do
			ab[k] = v
		end
		for k, v in r[7] or {} do
			ab[k] = v
		end
		table.insert(list, ab)
	end
end

-- ── SIGNATURE MOVES: each class's own (and the first moves of each school), hand-drawn ──
add({ class = "fighter", group = "fighter", sig = true }, {
	{ "cleave", "Cleave", "Q", 1, "slash", "A wide cut through everything in front of you.", { element = "physical", range = 13, arc = 0.1 } },
	{ "rising_cut", "Rising Cut", "Q", 2, "slash", "An upward cut that throws them off their feet.", { element = "physical", unlock = "sk_rising_cut", range = 12, arc = 0.35, launch = true, power = 1.1 } },
	{ "shoulder_charge", "Shoulder Charge", "E", 1, "dash", "Run through the line; whatever's in the way goes flying.", { element = "physical", unlock = "sk_shoulder_charge", range = 26, width = 5, knock = 45 } },
	{ "leap_strike", "Leap Strike", "E", 4, "leap", "Leap to where you aim and land blade first; the street cracks.", { element = "earth", unlock = "sk_leap_strike", range = 34, radius = 11, stun = 0.8 } },
	{ "slam", "Ground Slam", "R", 1, "shockwave", "Bring the weapon down and the ground jumps.", { element = "earth", radius = 17, stun = 0.6, knock = false } },
	{ "whirlwind", "Whirlwind", "R", 2, "orbit", "Spin with the blade out; it cuts everything near you as you move.", { element = "physical", unlock = "sk_whirlwind", radius = 13, duration = 2.5 } },
	{ "iron_resolve", "Iron Resolve", "T", 3, "ward", "Set your jaw: blows land softer for a few seconds, and a breath back.", { element = "physical", unlock = "sk_iron_resolve", duration = 5, heals = true, healMul = 0.5 } },
	{ "war_cry", "War Cry", "T", 3, "aura", "A shout that puts strength in every arm near you.", { element = "physical", unlock = "sk_war_cry", radius = 30, allies = true, duration = 10 } },
	{ "earthsplitter", "Earthsplitter", "G", 5, "spikes", "Open the street in a line; stone erupts all along it.", { element = "earth", unlock = "sk_earthsplitter", range = 48, width = 7, stun = 1.2 } },
	{ "bladestorm", "Bladestorm", "G", 6, "orbit", "For four seconds you are a storm of blades.", { element = "physical", unlock = "sk_bladestorm", radius = 16, duration = 4 } },
})
add({ class = "mage", group = "mage", sig = true }, {
	{ "mana_bolt", "Mana Bolt", "Q", 1, "projectile", "A bolt of raw mana at the nearest monster in front.", { element = "mana", range = 70, speed = 140 } },
	{ "flame_lance", "Flame Lance", "Q", 2, "lance", "A spear of fire that goes through everything in a line.", { element = "fire", unlock = "sk_flame_lance", range = 75, width = 4, burn = 0.3 } },
	{ "arcane_step", "Arcane Step", "E", 2, "blink", "Fold the street and step across; mana bursts where you land.", { element = "mana", unlock = "sk_arcane_step", range = 30, radius = 8, hit = 0.6 } },
	{ "frost_nova", "Frost Nova", "R", 1, "nova", "Everything near you freezes and slows.", { element = "frost", radius = 19, slow = 0.35, slowFor = 4 } },
	{ "chain_lightning", "Chain Lightning", "R", 4, "chain", "Lightning that jumps from monster to monster.", { element = "lightning", unlock = "sk_chain_lightning", range = 60, chains = 5, jump = 22, stun = 0.4 } },
	{ "mana_shield", "Mana Shield", "T", 1, "dome", "Panes of hard mana around you and anyone close.", { element = "mana", unlock = "sk_mana_shield", radius = 14, duration = 6 } },
	{ "meteor", "Meteor", "G", 5, "meteor", "Call a burning rock down from a sky that isn't there.", { element = "fire", unlock = "sk_meteor", range = 70, radius = 20, delay = 1.1, burn = 0.5, knock = 40 } },
	{ "arcane_guardian", "Arcane Guardian", "G", 5, "construct", "An armoured guardian of mana steps out of a rune and fights for ten seconds.", { element = "mana", unlock = "sk_runic_circle", duration = 10, construct = { style = "knight", speed = 18, reach = 7 } } },
	{ "cataclysm", "Arcane Cataclysm", "G", 6, "meteor", "Runes fill the sky, and then the street remembers it for years.", { element = "mana", unlock = "sk_cataclysm", range = 60, radius = 30, delay = 1.6, stun = 1.5, power = 1.2 } },
})
add({ class = "assassin", group = "assassin", sig = true }, {
	{ "blade_flurry", "Blade Flurry", "Q", 1, "strike", "Six cuts on the nearest monster before it turns.", { element = "physical", range = 11, hits = 6 } },
	{ "fan_of_knives", "Fan of Knives", "Q", 4, "volley", "Six throwing knives in one arc.", { element = "physical", unlock = "sk_fan_of_knives", range = 40, count = 6, arc = 0.5, speed = 160 } },
	{ "shadow_step", "Shadow Step", "E", 1, "dash", "Close the distance in one step and land behind it.", { element = "void", center = "target", range = 34, width = 4, power = 1.3 } },
	{ "smoke_bomb", "Smoke Bomb", "E", 1, "blink", "A grey cloud where you stood; everything in it stumbles.", { element = "physical", unlock = "sk_smoke_bomb", back = true, range = 18, radius = 12, slow = 0.4, slowFor = 3 } },
	{ "venom_mist", "Venom Mist", "R", 3, "field", "A green mist that eats at whatever is inside it.", { element = "venom", unlock = "sk_venom_edge", center = "front", range = 10, radius = 12, duration = 4, slow = 0.7, slowFor = 1 } },
	{ "crippling_strike", "Crippling Strike", "R", 3, "strike", "Two low cuts; it limps for a while.", { element = "physical", unlock = "sk_crippling_strike", range = 11, hits = 2, slow = 0.4, slowFor = 4 } },
	{ "assassinate", "Assassinate", "R", 5, "dash", "Appear behind the nearest monster and find the place it can't defend.", { element = "void", unlock = "sk_assassinate", center = "target", range = 40, width = 3, power = 1.6 } },
	{ "afterimage", "Afterimage", "T", 5, "haste", "Blows land on copies of you a step behind; you move faster.", { element = "mana", unlock = "sk_afterimage", duration = 6, guards = true } },
	{ "phantom_dance", "Phantom Dance", "G", 6, "chain", "Afterimages cut through every monster close by.", { element = "void", unlock = "sk_phantom_dance", range = 30, chains = 6, jump = 20 } },
	{ "silent_verdict", "Silent Verdict", "G", 6, "strike", "The street goes quiet for half a second, and then the cut lands.", { element = "void", unlock = "sk_silent_verdict", range = 14, hits = 1, delay = 0.5, power = 1.4 } },
})
add({ class = "tanker", group = "tanker", sig = true }, {
	{ "shield_bash", "Shield Bash", "Q", 1, "slash", "Shield first into whatever is in front.", { element = "physical", range = 11, arc = 0.1, knock = 60, stun = 0.5, power = 0.85 } },
	{ "rampart_slam", "Rampart Slam", "Q", 4, "nova", "Drive the shield into the street; everything near it turns to you.", { element = "earth", unlock = "sk_fortress", center = "front", range = 8, radius = 10, taunt = 3 } },
	{ "bulwark_charge", "Bulwark Charge", "E", 3, "dash", "Shield up, at a run, through whatever is there.", { element = "physical", unlock = "sk_bulwark_charge", range = 30, width = 6, knock = 70, guards = true, duration = 2 } },
	{ "provoke", "Provoke", "R", 1, "taunt", "Make every monster near you look at you, not them, and brace.", { element = "physical", radius = 45, duration = 6, hit = false } },
	{ "hold_the_line", "Hold the Line", "R", 2, "taunt", "Stamp once: a shockwave, and everything near you has to come through you.", { element = "earth", unlock = "sk_hold_the_line", radius = 30, duration = 6, slow = 0.5, slowFor = 3, power = 2 } },
	{ "shield_wall", "Shield Wall", "T", 2, "dome", "A wall of mana-hardened shields for you and anyone behind you.", { element = "physical", unlock = "sk_shield_wall", radius = 18, duration = 6 } },
	{ "guardian_oath", "Guardian's Oath", "T", 4, "dome", "You take the blows meant for others; light covers everyone near.", { element = "holy", unlock = "sk_guardian_oath", radius = 28, duration = 8, heals = true, healMul = 0.4 } },
	{ "bastion", "Bastion", "G", 6, "taunt", "Become the wall a city stands behind: every monster near comes to you.", { element = "earth", unlock = "sk_bastion", radius = 60, duration = 8, stun = 1, power = 1.4, guardMul = 1.3 } },
	{ "aegis", "Aegis", "G", 6, "dome", "A dome of mana a whole street can hide under.", { element = "holy", unlock = "sk_aegis", radius = 26, duration = 8, guardMul = 1.2 } },
})
add({ class = "ranger", group = "ranger", sig = true }, {
	{ "piercing_arrow", "Piercing Arrow", "Q", 1, "lance", "An arrow that goes through everything in a line.", { element = "physical", range = 90, width = 4 } },
	{ "multishot", "Multishot", "Q", 2, "volley", "Three arrows, one draw.", { element = "physical", unlock = "sk_multishot", range = 70, count = 3, arc = 0.7, speed = 180 } },
	{ "backstep_shot", "Backstep Shot", "E", 3, "dash", "Jump back and loose an arrow before you land.", { element = "wind", unlock = "sk_backstep_shot", back = true, range = 18, width = 4, power = 1.3 } },
	{ "arrow_rain", "Arrow Rain", "R", 1, "rain", "The sky over them fills with arrows.", { element = "physical", range = 50, radius = 15, duration = 2 } },
	{ "snare_trap", "Snare Trap", "R", 2, "field", "A ring of mana on the ground that holds whatever steps in.", { element = "mana", unlock = "sk_snare_trap", range = 40, radius = 9, duration = 6, slow = 0.1, slowFor = 0.6, power = 0.4 } },
	{ "explosive_arrow", "Explosive Arrow", "R", 5, "projectile", "An arrowhead packed with mana; it goes off on contact.", { element = "fire", unlock = "sk_explosive_arrow", range = 80, splash = 12, knock = 50, speed = 160 } },
	{ "eagle_eye", "Eagle Eye", "T", 3, "aura", "Everything slows down and every weak spot shows.", { element = "wind", unlock = "sk_eagle_eye", duration = 8, buffMul = 1.4 } },
	{ "mana_hawk", "Mana Hawk", "T", 4, "construct", "A hawk made of your own mana circles, then dives, again and again.", { element = "wind", unlock = "sk_mana_hawk", center = "self", duration = 9, power = 0.6, construct = { style = "hawk", speed = 34, reach = 9 } } },
	{ "skypierce", "Skypierce", "G", 6, "lance", "An arrow of light that doesn't come down.", { element = "mana", unlock = "sk_skypierce", range = 140, width = 8 } },
	{ "starfall_volley", "Starfall Volley", "G", 6, "rain", "A sky of falling light, and every point of it an arrow.", { element = "holy", unlock = "sk_starfall_volley", range = 60, radius = 24, duration = 3 } },
})
add({ class = "healer", group = "healer", sig = true }, {
	{ "mend", "Mend", "Q", 1, "motes", "Close the wounds of everyone close to you.", { element = "holy", radius = 22 } },
	{ "soothing_light", "Soothing Light", "Q", 1, "renew", "Motes of light that keep healing for five seconds.", { element = "holy", unlock = "sk_soothing_light", radius = 18, duration = 5 } },
	{ "purifying_wave", "Purifying Wave", "E", 2, "shockwave", "A wave of light that pushes monsters back and steadies people.", { element = "holy", unlock = "sk_purify", radius = 16, knock = 55 } },
	{ "sanctuary", "Sanctuary", "R", 1, "field", "A dome where people heal, take less, and stop being afraid.", { element = "holy", center = "self", radius = 26, duration = 5, tick = 1, heals = true, guards = true, hit = false } },
	{ "regeneration", "Regeneration", "R", 4, "renew", "Wounds close on their own for eight seconds.", { element = "holy", unlock = "sk_regeneration", radius = 24, duration = 8 } },
	{ "barrier", "Barrier", "T", 3, "dome", "A shell of light around everyone near you.", { element = "holy", unlock = "sk_barrier", radius = 22, duration = 6 } },
	{ "warding_sigil", "Warding Sigil", "T", 3, "field", "A circle on the ground that blows can't cross easily; it burns monsters.", { element = "holy", unlock = "sk_warding_sigil", center = "self", radius = 16, duration = 8, guards = true, power = 0.3 } },
	{ "light_warden", "Light Warden", "G", 5, "construct", "A warden made of light stands over the wounded, healing and striking.", { element = "holy", unlock = "sk_light_warden", duration = 10, radius = 18, heals = true, healMul = 0.6, power = 0.6, construct = { style = "warden", speed = 14, reach = 8 } } },
	{ "grace", "Grace", "G", 6, "motes", "Pull everyone near you back from almost anything.", { element = "holy", unlock = "sk_grace", radius = 40, guards = true, duration = 4 } },
	{ "resurgence", "Resurgence", "G", 6, "motes", "Light floods the street: everyone gets back up, every monster burns.", { element = "holy", unlock = "sk_resurgence", radius = 45, hit = 0.7 } },
})
add({ class = "any", group = "craft", sig = true }, {
	{ "blink", "Blink", "E", 3, "blink", "Vanish and reappear a few metres ahead.", { element = "mana", unlock = "sk_blink", range = 26 } },
	{ "mana_armour", "Mana Armour", "T", 2, "ward", "Pull your mana tight over your skin.", { element = "mana", unlock = "sk_mana_armour", duration = 6 } },
})
-- the schools' first signature moves
local function school(id: string, sig: boolean?): any
	return { class = "any", school = id, group = id, sig = sig == true }
end
add(school("fire", true), {
	{ "fireball", "Fireball", "Q", 1, "projectile", "A ball of fire that bursts on whatever it hits.", { speed = 110, splash = 9, burn = 0.3 } },
	{ "ring_of_fire", "Ring of Fire", "R", 2, "field", "A circle of flame that burns whatever stays in it.", { range = 40, radius = 12, duration = 5 } },
	{ "inferno", "Inferno", "G", 6, "nova", "The air itself goes up around you.", { radius = 28, burn = 0.6, knock = 60 } },
})
add(school("frost", true), {
	{ "frost_shard", "Frost Shard", "Q", 1, "projectile", "A sliver of ice that leaves its target sluggish.", { speed = 150, slow = 0.5, slowFor = 3 } },
	{ "ice_spikes", "Ice Spikes", "R", 2, "spikes", "Spikes of ice erupt from the street in a line.", { range = 40, width = 8, stun = 0.8 } },
	{ "blizzard", "Blizzard", "G", 6, "storm", "A storm of ice over a whole block.", { range = 60, radius = 26, duration = 6, slow = 0.3, slowFor = 1 } },
})
add(school("lightning", true), {
	{ "static_spark", "Static Spark", "Q", 1, "chain", "A spark that jumps to the next thing, and the next.", { chains = 2, jump = 18 } },
	{ "thunderclap", "Thunderclap", "R", 2, "nova", "A crack of thunder that stuns everything close.", { radius = 16, stun = 1.2 } },
	{ "thunderstorm", "Thunderstorm", "G", 6, "storm", "A storm of your own over the street; bolts fall on whatever is under it.", { range = 60, radius = 26, duration = 5, stun = 0.3 } },
})
add(school("wind", true), {
	{ "gale_step", "Gale Step", "E", 1, "dash", "Ride a gust across the street, knocking things aside.", { range = 30, width = 6, knock = 55 } },
	{ "wind_blades", "Wind Blades", "Q", 2, "volley", "Three crescents of air sharp enough to cut steel.", { count = 3, arc = 0.75, speed = 120 } },
	{ "tempest", "Tempest", "G", 6, "field", "A cyclone that drags a crowd of monsters into itself.", { range = 50, radius = 22, duration = 5, pull = true } },
})
add(school("earth", true), {
	{ "stone_skin", "Stone Skin", "T", 1, "ward", "A shell of stone over your skin for a few hard seconds.", { duration = 7 } },
	{ "earth_pillars", "Earth Pillars", "R", 2, "eruption", "Pillars of rock punch up out of the street.", { radius = 13, stun = 0.6 } },
	{ "stone_colossus", "Stone Colossus", "G", 6, "construct", "A giant of stone and mana stands up out of the street and fights for a while.", { range = 8, duration = 12, construct = { style = "golem", speed = 14, reach = 10 } } },
})
add(school("holy", true), {
	{ "smite", "Smite", "Q", 1, "smite", "A shaft of light drops on the nearest monster in front.", {} },
	{ "pillar_of_light", "Pillar of Light", "R", 2, "pillar", "A column of light that burns monsters and mends the people in it.", { radius = 12, heals = true, healMul = 0.6 } },
	{ "dawnbreak", "Dawnbreak", "G", 6, "nova", "For a moment the street is lit like morning.", { radius = 34, heals = true, healMul = 0.5 } },
})
add(school("void", true), {
	{ "void_orb", "Void Orb", "Q", 1, "projectile", "A dark orb that drifts out and collapses, pulling everything in.", { speed = 60, splash = 10, delay = 0.4, pull = true } },
	{ "gravity_well", "Gravity Well", "R", 2, "field", "A patch of street where everything is suddenly very heavy.", { range = 45, radius = 14, duration = 4, pull = true, slow = 0.5, slowFor = 1 } },
	{ "singularity", "Singularity", "G", 6, "implode", "A point of nothing that swallows a crowd and then lets go.", { range = 55, radius = 24, delay = 1.5 } },
})

-- ── THE MAGIC SCHOOLS (drawn by shape, in the school's element) ──
add(school("fire"), {
	{ "ember_shot", "Ember Shot", "Q", 1, "projectile", "A flicked ember that sticks and burns.", { burn = 0.15, size = 0.8 } },
	{ "flame_breath", "Flame Breath", "R", 2, "cone", "Breathe out, and the street in front of you is fire.", { burn = 0.25 } },
	{ "blaze_step", "Blaze Step", "E", 2, "dash", "A burst of flame carries you forward, scorching what you pass.", { burn = 0.15 } },
	{ "wall_of_flame", "Wall of Flame", "R", 3, "wall", "A wall of fire across the street that burns anything crossing it.", {} },
	{ "pillar_of_flame", "Pillar of Flame", "R", 4, "pillar", "A column of fire bursts up under the aimed spot.", { burn = 0.3 } },
	{ "mantle_of_embers", "Mantle of Embers", "T", 4, "aura", "Fire wraps your arms; every blow lands hotter.", {} },
	{ "sunfall", "Sunfall", "G", 5, "meteor", "A sun-bright mass of fire falls on the aimed spot.", { burn = 0.4, size = 1.15 } },
	{ "scorching_ray", "Scorching Ray", "Q", 5, "lance", "A ray of white-hot fire, faster than any bolt.", { burn = 0.3 } },
})
add(school("frost"), {
	{ "ice_needles", "Ice Needles", "Q", 1, "volley", "A spray of needles of ice that numb what they hit.", { slow = 0.6, slowFor = 2 } },
	{ "frost_glide", "Frost Glide", "E", 2, "dash", "Slide on a path of ice that freezes what you pass.", { slow = 0.5, slowFor = 2 } },
	{ "rime_lance", "Rime Lance", "Q", 3, "lance", "A lance of ice that pierces a line and slows it.", { slow = 0.5, slowFor = 3 } },
	{ "glacial_wall", "Glacial Wall", "T", 3, "wall", "A wall of ice: whatever stays by it slows to a crawl.", { slow = 0.3, slowFor = 1, power = 0.5 } },
	{ "frozen_prison", "Frozen Prison", "R", 4, "eruption", "Ice closes over everything in one spot and holds it.", { stun = 1.5, launch = false } },
	{ "hoarfrost_armour", "Hoarfrost Armour", "T", 4, "ward", "A coat of hoarfrost that turns claws aside.", {} },
	{ "frost_domain", "Frost Domain", "G", 5, "field", "Winter takes a whole block: everything inside slows and freezes.", { slow = 0.25, slowFor = 1, size = 1.6 } },
	{ "glacial_rush", "Glacial Rush", "E", 5, "dash", "A charge on a road of ice that freezes everything beside it.", { slow = 0.4, slowFor = 3, size = 1.3 } },
})
add(school("lightning"), {
	{ "shock_bolt", "Shock Bolt", "Q", 1, "projectile", "A crackling bolt that jolts its target still.", { stun = 0.2 } },
	{ "bolt_step", "Bolt Step", "E", 2, "dash", "Become a streak of lightning across the street.", { stun = 0.3 } },
	{ "thunder_spear", "Thunder Spear", "Q", 3, "lance", "A spear of lightning thrown through a line of them.", { stun = 0.4 } },
	{ "storm_orbs", "Storm Orbs", "T", 3, "orbit", "Balls of lightning circle you and shock whatever comes close.", {} },
	{ "heavens_bolt", "Heaven's Bolt", "R", 4, "smite", "A bolt straight down from a clear sky.", { stun = 0.8, power = 1.2 } },
	{ "charged_barrier", "Charged Barrier", "T", 4, "dome", "A crackling dome: blows that land inside it lose their force.", {} },
	{ "skyfall_tempest", "Skyfall Tempest", "G", 5, "storm", "Lightning falls like rain on a whole street.", { stun = 0.3 } },
	{ "storm_pike", "Storm Pike", "Q", 6, "lance", "A pike of lightning as long as the street.", { stun = 0.6, size = 1.3 } },
})
add(school("wind"), {
	{ "air_slash", "Air Slash", "Q", 1, "wave", "A crescent of air flung down the street.", {} },
	{ "gust_burst", "Gust Burst", "R", 1, "shockwave", "A blast of wind that throws everything near you back.", { knock = 55, power = 0.8 } },
	{ "tailwind", "Tailwind", "T", 2, "haste", "The wind at your back, and at your allies'.", { allies = true, radius = 24 } },
	{ "vacuum_blade", "Vacuum Blade", "Q", 3, "wave", "A blade of empty air that cuts through a line.", { size = 1.3 } },
	{ "cyclone", "Cyclone", "R", 4, "field", "A cyclone that drags monsters in and spins them.", { pull = true } },
	{ "wind_barrier", "Wind Barrier", "T", 4, "dome", "A wall of wind around you that turns blows aside.", {} },
	{ "sky_render", "Sky Render", "G", 5, "lance", "One cut of wind that splits the street to the horizon.", { size = 1.6, width = 7 } },
	{ "zephyr_step", "Zephyr Step", "E", 6, "dash", "Be the wind for a moment, through everything in the way.", { knock = 60, size = 1.6 } },
})
add(school("earth"), {
	{ "stone_bullet", "Stone Bullet", "Q", 1, "projectile", "A fist-sized stone, thrown by mana.", { knock = 25 } },
	{ "tremor", "Tremor", "R", 1, "shockwave", "Stamp, and the ground under them shakes them off their feet.", { stun = 0.4, knock = false } },
	{ "stone_spikes", "Stone Spikes", "R", 2, "spikes", "Spikes of stone burst up in a line.", {} },
	{ "rampart_of_stone", "Rampart of Stone", "T", 3, "wall", "A wall of stone rises; the people behind it take less.", { guards = true, power = 0.5 } },
	{ "boulder_toss", "Boulder Toss", "Q", 3, "projectile", "A boulder torn out of the street and thrown.", { splash = 8, knock = 40, speed = 80 } },
	{ "quake", "Quake", "R", 4, "nova", "The street heaves around you.", { stun = 0.8, size = 1.4 } },
	{ "mountain_fall", "Mountain Fall", "G", 5, "meteor", "A mountain's worth of stone comes down on one spot.", { stun = 1, size = 1.2 } },
	{ "mountain_skin", "Mountain Skin", "T", 5, "ward", "Skin like a mountainside; claws skid off it.", { guardMul = 1.1 } },
})
add(school("water"), {
	{ "water_bullet", "Water Bullet", "Q", 1, "projectile", "A bullet of water hard as steel.", {} },
	{ "water_whip", "Water Whip", "Q", 2, "cone", "A whip of water that lashes everything in front.", { knock = 20 } },
	{ "tidal_surge", "Tidal Surge", "R", 2, "shockwave", "A wave bursts out from you and sweeps monsters back.", { knock = 60 } },
	{ "mist_step", "Mist Step", "E", 2, "blink", "Turn to mist and gather again a few metres on.", {} },
	{ "healing_rain", "Healing Rain", "T", 3, "renew", "Warm rain that closes wounds while it falls.", {} },
	{ "water_prison", "Water Prison", "R", 3, "implode", "A sphere of water closes over a spot and holds what's inside.", { stun = 1, pull = false } },
	{ "torrent", "Torrent", "Q", 4, "lance", "A torrent of water hard enough to cut stone.", { knock = 30 } },
	{ "tidal_wall", "Tidal Wall", "T", 4, "wall", "A standing wall of water; monsters crossing it are dragged back.", { slow = 0.4, slowFor = 1 } },
	{ "maelstrom", "Maelstrom", "G", 5, "field", "A whirlpool on dry street that drags everything in.", { pull = true, size = 1.5 } },
	{ "deluge", "Deluge", "G", 6, "rain", "The sky opens over one block and keeps falling.", { size = 1.6, slow = 0.6, slowFor = 1 } },
})
add(school("holy"), {
	{ "arrow_of_light", "Arrow of Light", "Q", 1, "projectile", "A shaft of light that flies true.", {} },
	{ "radiant_burst", "Radiant Burst", "R", 2, "nova", "Light bursts out of you, burning monsters and mending people.", { heals = true, healMul = 0.5 } },
	{ "blessing", "Blessing", "T", 2, "aura", "Light on everyone near you; their blows land harder.", { allies = true, radius = 24 } },
	{ "halo_ward", "Halo Ward", "T", 3, "dome", "A halo of light over everyone close.", {} },
	{ "lance_of_dawn", "Lance of Dawn", "Q", 4, "lance", "A lance of morning light through a line of monsters.", {} },
	{ "chains_of_light", "Chains of Light", "R", 4, "chain", "Chains of light leap from monster to monster and bind them.", { stun = 0.9 } },
	{ "radiant_judgement", "Radiant Judgement", "G", 5, "pillar", "A pillar of light the size of a building.", { size = 1.7, heals = true, healMul = 0.6 } },
	{ "sanctum_of_dawn", "Sanctum of Dawn", "T", 6, "dome", "A dome of morning light over everyone near; little gets through.", { size = 1.4 } },
})
add(school("void"), {
	{ "null_bolt", "Null Bolt", "Q", 1, "projectile", "A bead of nothing that bites where it lands.", {} },
	{ "void_step", "Void Step", "E", 2, "blink", "Fall into nothing and come out a few metres on.", {} },
	{ "gravity_crush", "Gravity Crush", "R", 2, "implode", "Everything in one spot is suddenly crushed together.", {} },
	{ "void_lance", "Void Lance", "Q", 3, "lance", "A line of nothing that erases what it passes through.", {} },
	{ "event_horizon", "Event Horizon", "T", 4, "dome", "A shell where blows slow to nothing before they land.", {} },
	{ "void_rift", "Void Rift", "R", 4, "field", "A tear in the ground that drags monsters down into it.", { pull = true, slow = 0.5, slowFor = 1 } },
	{ "collapse", "Collapse", "G", 5, "implode", "The street folds in on one point, and then lets go.", { size = 1.5 } },
	{ "rift_walk", "Rift Walk", "E", 5, "blink", "Walk into a rift and out a street further on; it pulls in where you land.", { radius = 10, hit = 0.6, pull = true } },
})
add(school("venom"), {
	{ "toxic_dart", "Toxic Dart", "Q", 1, "projectile", "A dart of venom that keeps working.", { burn = 0.2 } },
	{ "venom_spray", "Venom Spray", "R", 1, "cone", "A spray of venom over everything in front.", { burn = 0.2, power = 0.8 } },
	{ "noxious_step", "Noxious Step", "E", 2, "dash", "Dash through them, leaving venom behind.", { burn = 0.2 } },
	{ "miasma", "Miasma", "R", 2, "field", "A green fog that eats at whatever is inside it.", { slow = 0.7, slowFor = 1 } },
	{ "corroding_mark", "Corroding Mark", "T", 3, "curse", "Venom eats at their armour: everything hits them harder.", { expose = true } },
	{ "serpent_fang", "Serpent Fang", "Q", 3, "strike", "Two quick bites of a venom-coated blade.", { hits = 2, burn = 0.3 } },
	{ "toxic_bloom", "Toxic Bloom", "R", 4, "eruption", "Venom blooms out of the ground under them.", { burn = 0.4, launch = false } },
	{ "thorned_veil", "Thorned Veil", "T", 4, "ward", "A veil of venom around you; blows land softer.", {} },
	{ "venom_rain", "Venom Rain", "G", 5, "rain", "Green rain falls on a whole block.", { burn = 0.3 } },
	{ "thousand_stings", "Thousand Stings", "G", 6, "volley", "A storm of venomed needles over everything ahead.", { count = 8, arc = 0.3, burn = 0.4 } },
})
add(school("life"), {
	{ "verdant_touch", "Verdant Touch", "Q", 1, "motes", "Green light closes small wounds.", {} },
	{ "cleansing_bloom", "Cleansing Bloom", "T", 2, "cleanse", "Petals of light wash away fear and fatigue.", {} },
	{ "thorn_lash", "Thorn Lash", "Q", 2, "cone", "A lash of thorned vines across the front.", { slow = 0.6, slowFor = 2 } },
	{ "lifebloom", "Lifebloom", "R", 2, "renew", "Flowers of light open under everyone near and keep healing.", {} },
	{ "rootwalk", "Rootwalk", "E", 2, "blink", "Sink into the ground and rise again further on.", {} },
	{ "barkskin", "Barkskin", "T", 3, "ward", "Your skin hardens like old bark.", {} },
	{ "entangling_roots", "Entangling Roots", "R", 3, "eruption", "Roots burst up and hold whatever is standing there.", { stun = 1.2, launch = false } },
	{ "wellspring", "Wellspring", "T", 4, "renew", "A spring of life under everyone close.", { size = 1.4 } },
	{ "grove_guardian", "Grove Guardian", "G", 5, "construct", "A guardian of living wood and mana stands up and fights.", { construct = { style = "golem", speed = 14, reach = 9 } } },
	{ "evergreen_sanctum", "Evergreen Sanctum", "G", 6, "field", "A grove of light where people heal and blows soften.", { center = "self", heals = true, guards = true, hit = false, tick = 1, size = 1.6 } },
})
add(school("arcane"), {
	{ "arcane_missiles", "Arcane Missiles", "Q", 1, "volley", "Three seeking bolts of mana.", {} },
	{ "mana_burst", "Mana Burst", "R", 1, "nova", "Mana bursts out of you in a ring.", {} },
	{ "rune_trap", "Rune Trap", "R", 2, "field", "A rune on the ground that holds whatever steps in.", { slow = 0.1, slowFor = 0.6, power = 0.5 } },
	{ "phase_step", "Phase Step", "E", 2, "blink", "Step out of the world and back in.", {} },
	{ "rune_ward", "Rune Ward", "T", 3, "dome", "Runes turn about you and your allies.", {} },
	{ "orbiting_runes", "Orbiting Runes", "T", 3, "orbit", "Runes orbit you and cut what comes close.", {} },
	{ "mana_lance", "Mana Lance", "Q", 4, "lance", "A lance of condensed mana.", {} },
	{ "arcane_seal", "Arcane Seal", "R", 4, "curse", "A seal of runes saps the strength of everything inside.", { weaken = true } },
	{ "astral_barrage", "Astral Barrage", "G", 5, "rain", "A barrage of falling mana stars.", { size = 1.3 } },
	{ "rune_colossus", "Rune Colossus", "G", 6, "construct", "A colossus of runes and mana steps out of a circle.", { construct = { style = "golem", speed = 16, reach = 10 } } },
})
add(school("sound"), {
	{ "resonant_pulse", "Resonant Pulse", "Q", 1, "wave", "A pulse of sound you can see.", {} },
	{ "sonic_boom", "Sonic Boom", "R", 2, "shockwave", "A boom that throws monsters back and leaves them reeling.", { stun = 0.3 } },
	{ "echo_step", "Echo Step", "E", 2, "dash", "Ride your own echo across the street.", {} },
	{ "battle_hymn", "Battle Hymn", "T", 3, "aura", "A hum that puts strength in everyone who hears it.", { allies = true, radius = 26 } },
	{ "dissonance", "Dissonance", "R", 3, "curse", "A grinding note that saps their strength.", { center = "self", weaken = true } },
	{ "shatter_chord", "Shatter Chord", "Q", 3, "cone", "One chord that cracks armour in front of you.", { stun = 0.5 } },
	{ "resonance_barrier", "Resonance Barrier", "T", 4, "dome", "A humming dome that soaks up blows.", {} },
	{ "roar_of_the_deep", "Roar of the Deep", "R", 4, "nova", "A sound so low the ground shakes with it.", { stun = 0.6, size = 1.3 } },
	{ "tolling_bell", "Tolling Bell", "G", 5, "shockwave", "A bell only monsters can hear, tolling once.", { stun = 1.2, size = 1.6 } },
	{ "grand_crescendo", "Grand Crescendo", "G", 6, "storm", "Sound piles on sound until the street itself rings.", { stun = 0.4 } },
})

-- ── THE PHYSICAL ARTS (by class and rank) ──
local function art(id: string): any
	for _, a in Abilities.ARTS do
		if a.id == id then
			return { class = "any", classes = a.classes, art = id, group = id, element = "physical" }
		end
	end
	error("no art " .. id)
end
add(art("sword"), {
	{ "swift_cut", "Swift Cut", "Q", 1, "slash", "A clean cut, faster than it looks.", {} },
	{ "cross_slash", "Cross Slash", "Q", 2, "strike", "Two cuts in the shape of a cross.", { hits = 2 } },
	{ "blade_wave", "Blade Wave", "R", 2, "wave", "A cut that keeps going after the blade stops.", {} },
	{ "piercing_lunge", "Piercing Lunge", "E", 2, "dash", "A lunge that ends a street away.", { width = 3 } },
	{ "sword_aura", "Sword Aura", "T", 3, "aura", "Mana runs down the blade and stays there.", {} },
	{ "sheath_draw", "Sheath Draw", "Q", 3, "slash", "The blade leaves the sheath once, and that's enough.", { power = 1.3, size = 1.2 } },
	{ "hundred_petals", "Hundred Petals", "R", 4, "strike", "A storm of cuts like falling petals.", { hits = 8 } },
	{ "sky_splitting_slash", "Sky-Splitting Slash", "G", 5, "wave", "One slash that splits the street in two.", { size = 2, width = 7 } },
	{ "moonlight_arc", "Moonlight Arc", "Q", 6, "slash", "One arc of pale light, and everything in front of you falls.", { size = 1.6, power = 1.1 } },
})
add(art("spear"), {
	{ "spear_thrust", "Spear Thrust", "Q", 1, "lance", "Straight through, a long way.", { size = 0.35, width = 2.5 } },
	{ "sweeping_haft", "Sweeping Haft", "Q", 2, "slash", "A wide sweep of the haft.", { arc = -0.2, knock = 30 } },
	{ "pole_vault", "Pole Vault", "E", 2, "leap", "Plant the spear and vault, landing point first.", {} },
	{ "phalanx_stance", "Phalanx Stance", "T", 3, "ward", "Spear out, shoulder down, nothing gets close.", {} },
	{ "spear_volley", "Spear Volley", "R", 3, "volley", "Spears of mana thrown in a fan.", { count = 4, arc = 0.75 } },
	{ "impaling_drive", "Impaling Drive", "R", 3, "dash", "Charge spear first through a line of them.", { power = 1.3 } },
	{ "whirling_spear", "Whirling Spear", "R", 4, "nova", "The spear spins around you like a wheel.", {} },
	{ "comet_lance", "Comet Lance", "G", 5, "leap", "Leap high and come down like a comet, spear first.", { size = 1.5, stun = 1 } },
})
add(art("fist"), {
	{ "mana_jab", "Mana Jab", "Q", 1, "strike", "Two jabs with mana behind them.", { hits = 2 } },
	{ "palm_strike", "Palm Strike", "Q", 2, "cone", "An open palm and a wall of force.", { size = 0.6, knock = 50 } },
	{ "rushing_fists", "Rushing Fists", "R", 2, "strike", "A hundred punches in two seconds.", { hits = 8 } },
	{ "flying_knee", "Flying Knee", "E", 2, "dash", "Close the gap knee first.", {} },
	{ "iron_body", "Iron Body", "T", 3, "ward", "Breathe in, and your body becomes iron.", {} },
	{ "ground_breaker", "Ground Breaker", "R", 3, "nova", "Punch the street and the street breaks.", { stun = 0.5 } },
	{ "fist_pressure", "Fist Pressure", "Q", 4, "wave", "A punch at the air, and the air flies down the street.", {} },
	{ "heaven_shaking_fist", "Heaven-Shaking Fist", "G", 5, "shockwave", "One punch, and the shock goes for a block.", { size = 1.8, stun = 0.8 } },
})
add(art("archery"), {
	{ "quick_shot", "Quick Shot", "Q", 1, "projectile", "Draw and loose in one breath.", { speed = 200 } },
	{ "evasive_roll", "Evasive Roll", "E", 1, "dash", "Roll back out of reach.", { back = true, hit = false } },
	{ "split_arrow", "Split Arrow", "Q", 2, "volley", "One arrow that becomes three in the air.", {} },
	{ "venom_arrow", "Venom Arrow", "R", 2, "projectile", "An arrow with a venom-filled head.", { element = "venom", burn = 0.35 } },
	{ "hunters_mark", "Hunter's Mark", "T", 2, "curse", "Mark a target: everyone hits it harder.", { center = "target", expose = true, size = 0.6 } },
	{ "shock_arrow", "Shock Arrow", "Q", 3, "projectile", "An arrow that bursts into lightning.", { element = "lightning", stun = 0.5, splash = 6 } },
	{ "pinning_shot", "Pinning Shot", "R", 3, "projectile", "Pin it to the street.", { stun = 1.2, power = 1.1 } },
	{ "long_shot", "Long Shot", "R", 4, "lance", "An arrow from further than anyone else can see.", { size = 2 } },
	{ "arrow_storm", "Arrow Storm", "G", 5, "rain", "A storm of arrows over a whole block.", { size = 1.5 } },
	{ "sky_needle", "Sky Needle", "Q", 6, "projectile", "An arrow so fast it lands before the sound of the string.", { speed = 260, power = 1.2, splash = 6 } },
})
add(art("shield"), {
	{ "shield_edge", "Shield Edge", "Q", 1, "slash", "Strike with the rim of the shield.", { knock = 25 } },
	{ "shield_throw", "Shield Throw", "Q", 2, "chain", "The shield bounces from one monster to the next.", { chains = 2 } },
	{ "guard_rush", "Guard Rush", "E", 2, "dash", "Run behind the shield to where you're needed.", { guards = true, duration = 2 } },
	{ "challenging_roar", "Challenging Roar", "R", 2, "taunt", "A roar no monster can ignore.", {} },
	{ "iron_bastion", "Iron Bastion", "T", 3, "dome", "Iron-hard mana over everyone close.", {} },
	{ "counter_stance", "Counter Stance", "T", 4, "ward", "Brace for it, and turn it aside.", { guardMul = 1.3 } },
	{ "fortress_wall", "Fortress Wall", "R", 4, "wall", "A wall of shields of mana; people behind it take less.", { guards = true, power = 0.5 } },
	{ "unbroken_line", "Unbroken Line", "G", 5, "taunt", "Every monster near comes to you, and everyone behind you is safe.", { allies = true, size = 1.6, stun = 0.6 } },
})
add(art("assassination"), {
	{ "needle_strike", "Needle Strike", "Q", 1, "strike", "One precise strike where it hurts.", { hits = 1, power = 1.1 } },
	{ "fade_step", "Fade Step", "E", 1, "blink", "Gone from where they were looking.", { back = true } },
	{ "needle_storm", "Needle Storm", "Q", 2, "volley", "Five needles from a flick of the wrist.", { count = 5, arc = 0.6 } },
	{ "marked_target", "Marked Target", "T", 2, "curse", "Find the weak point and mark it for everyone.", { center = "target", expose = true, size = 0.6 } },
	{ "smokescreen", "Smokescreen", "T", 3, "field", "A cloud of smoke: monsters inside stumble about.", { center = "self", slow = 0.5, slowFor = 1, hit = false } },
	{ "ambush", "Ambush", "R", 3, "dash", "From nowhere to right behind it.", { center = "target", power = 1.3 } },
	{ "ghost_cut", "Ghost Cut", "R", 4, "strike", "Four cuts, and nobody saw the blade.", { hits = 4 } },
	{ "thousand_step_waltz", "Thousand-Step Waltz", "G", 5, "chain", "Step from monster to monster faster than they can turn.", { chains = 7 } },
	{ "vanishing_edge", "Vanishing Edge", "E", 6, "dash", "From here to behind it, and the cut already done.", { center = "target", power = 1.4 } },
})

-- ── HUNTER CRAFT (any class: by rank, or a craft skill) ──
local ALL = { "fighter", "mage", "assassin", "tanker", "ranger", "healer" }
add({ class = "any", group = "craft", element = "mana" }, {
	{ "battle_focus", "Battle Focus", "T", 1, "aura", "Breathe, and every blow counts for more.", { classes = ALL, element = "physical" } },
	{ "swift_feet", "Swift Feet", "E", 1, "haste", "Mana in the legs: you run faster for a while.", { classes = ALL, element = "wind" } },
	{ "first_aid", "First Aid", "Q", 1, "motes", "Bandage, pressure, a few calm words.", { unlock = "sk_field_medicine", element = "life", size = 0.4, healMul = 0.7 } },
	{ "challenge", "Challenge", "R", 1, "taunt", "Call the nearest monsters to you.", { classes = ALL, element = "physical", size = 0.6, hit = false } },
	{ "mana_barrier", "Mana Barrier", "T", 2, "dome", "A plain barrier of mana; every Hunter learns one.", { unlock = "sk_mana_armour" } },
	{ "clear_mind", "Clear Mind", "T", 2, "cleanse", "A breath that clears the fear out of everyone near.", { unlock = "sk_mana_breathing", element = "holy" } },
	{ "mana_bind", "Mana Bind", "R", 2, "curse", "Threads of mana that weigh them down and blunt their blows.", { unlock = "sk_mana_sensing", weaken = true, slow = 0.6, slowFor = 3 } },
	{ "sunder_mark", "Sunder Mark", "R", 3, "curse", "Read where its mana is thin, and mark it.", { unlock = "sk_gate_instinct", expose = true } },
	{ "rallying_banner", "Rallying Banner", "T", 3, "aura", "Plant a banner of light; everyone near fights harder.", { classes = ALL, element = "holy", allies = true, radius = 26 } },
	{ "mana_surge", "Mana Surge", "R", 3, "nova", "Let your mana out all at once.", { unlock = "sk_mana_sensing" } },
	{ "long_blink", "Long Blink", "E", 4, "blink", "A blink twice as far.", { unlock = "sk_blink", size = 2 } },
	{ "mana_sentry", "Mana Sentry", "G", 4, "construct", "A sentinel of mana fights beside you for a while.", { unlock = "sk_mana_sensing", power = 0.8 } },
})

-- ── more moves from their own files, when the game has them: Hunter/MonarchMoves.luau (the
-- Monarch classes, non-canon) and Hunter/TechniqueMoves.luau (techniques a long career teaches).
-- Each returns { groups = { { id, name, kind } }?, sets = { { base = {...}, rows = { ... } } } },
-- rows in the same form as above; they go through the same formula. ──
local extraGroups: { any } = {}
for _, name in { "MonarchMoves", "TechniqueMoves" } do
	local m = script.Parent:FindFirstChild(name)
	if m then
		local ext = require(m) :: any
		for _, set in ext.sets or {} do
			add(set.base or {}, set.rows or {})
		end
		for _, g in ext.groups or {} do
			table.insert(extraGroups, g)
		end
	end
end

-- ── finishing every move: its kind, defaults, and the numbers from the formula ──
local function r2(x: number): number
	return math.floor(x * 100 + 0.5) / 100
end
local schoolOf: { [string]: any } = {}
for _, s in Abilities.SCHOOLS do
	schoolOf[s.id] = s
end
local T = Abilities.TIER
for i, ab in list do
	local sh = Abilities.SHAPES[ab.shape]
	assert(sh, "move " .. tostring(ab.id) .. ": unknown shape " .. tostring(ab.shape))
	local t = math.clamp(ab.tier, 1, 6)
	local S = Abilities.SLOT_BASE[ab.slot]
	assert(S, "move " .. tostring(ab.id) .. ": unknown slot " .. tostring(ab.slot))
	ab.order = i
	ab.kind = ab.kind or sh.kind
	if ab.school then
		local sc = schoolOf[ab.school]
		ab.element = ab.element or sc.element
		ab.unlock = ab.unlock or sc.skills[TIER_STEP[t]]
	end
	if ab.sig then
		ab.fx = ab.fx or ab.id
	end
	-- the shape's defaults (geometry grows with tier and size)
	local grow = T.size[t] * (ab.size or 1)
	for k, v in sh.def do
		if ab[k] == nil then
			if GEOM[k] then
				ab[k] = math.floor(v * grow * 10 + 0.5) / 10
			elseif k == "duration" then
				ab[k] = r2(v * T.dur[t])
			else
				ab[k] = v
			end
		end
	end
	local hitFactor = if ab.hit == false then 0 elseif type(ab.hit) == "number" then ab.hit else sh.dmg
	-- `false` switches a shape's default off
	for k, v in table.clone(ab) do
		if v == false then
			ab[k] = nil
		end
	end
	ab.hit = nil
	ab.mana = math.floor(S.mana * T.mana[t] * (ab.manaMul or 1) + 0.5)
	ab.cd = math.floor(S.cd * T.cd[t] * (ab.cdMul or 1) * 10 + 0.5) / 10
	ab.cast = if sh.instant or ab.instant then 0 else r2(S.cast * T.cast[t])
	local total = S.mult * T.power[t] * hitFactor * (ab.power or 1)
	if ab.kind == "zone" then
		ab.mult = r2(total * ab.tick / ab.duration)
	elseif ab.kind == "construct" then
		ab.mult = r2(total * 0.9 / ab.duration)
	else
		ab.mult = r2(total)
	end
	if sh.heal or ab.heals then
		local h = T.heal[t] * S.heal * (ab.healMul or 1)
		if sh.hot or ab.kind == "zone" or ab.kind == "construct" then
			h = h * 1.6 * (ab.tick or 1) / (ab.duration or 6)
		end
		ab.heal = math.min(1, math.floor(h * 1000 + 0.5) / 1000)
	end
	if sh.guard or ab.guards then
		ab.guard = r2(1 - math.min(0.75, T.guard[t] * S.guard * (ab.guardMul or 1)))
	end
	local b = ab.buffs or sh.buff
	if b == "dmg" then
		ab.buff = { dmg = r2(1 + T.buff[t] * S.buff * (ab.buffMul or 1)) }
	elseif b == "speed" then
		ab.buff = { speed = r2(1.15 + 0.05 * t) }
	end
	if ab.weaken == true then
		ab.weaken = r2(1 - T.debuff[t])
	end
	if ab.expose == true then
		ab.expose = r2(1 + T.debuff[t])
	end
	ab.heals, ab.guards, ab.buffs = nil, nil, nil
end

Abilities.list = list
Abilities.byId = {} :: { [string]: any }
for _, ab in list do
	Abilities.byId[ab.id] = ab
end

-- the abilities a class can ever see: its own, and the ones open to it
function Abilities.forClass(class: string): { any }
	local out = {}
	for _, ab in list do
		if ab.class == class or (ab.class == "any" and (ab.classes == nil or table.find(ab.classes, class) ~= nil)) then
			table.insert(out, ab)
		end
	end
	return out
end

local function hasOf(has: any): (string) -> boolean
	if type(has) == "function" then
		return has
	end
	local set = has or {}
	return function(id: string): boolean
		return set[id] == true
	end
end
-- can this Hunter use it? (has: a set, or a function, of the life's trait ids; rank: 1..6)
function Abilities.usable(ab: any, class: string?, has: any, rank: number?): boolean
	if not ab or not class then
		return false
	end
	if ab.class ~= class and ab.class ~= "any" then
		return false
	end
	if ab.classes and not table.find(ab.classes, class) then
		return false
	end
	if rank ~= nil and ab.tier > rank then
		return false
	end
	return ab.unlock == nil or hasOf(has)(ab.unlock)
end
-- why not (for the loadout panel): nil if usable
function Abilities.lockReason(ab: any, class: string?, has: any, rank: number?, skillName: ((string) -> string?)?): string?
	if Abilities.usable(ab, class, has, rank) then
		return nil
	end
	if ab.classes and class and not table.find(ab.classes, class) then
		return "Not for your class"
	end
	if rank ~= nil and ab.tier > rank then
		return Abilities.TIER_LETTER[ab.tier] .. "-rank"
	end
	if ab.unlock then
		return "Learn " .. ((skillName and skillName(ab.unlock)) or ab.unlock)
	end
	return "Locked"
end

-- which is better for a slot by default: a higher tier, then the class's own, then the later one
local function better(a: any, b: any?, class: string): boolean
	if not b then
		return true
	end
	if a.tier ~= b.tier then
		return a.tier > b.tier
	end
	local aOwn, bOwn = a.class == class, b.class == class
	if aOwn ~= bOwn then
		return aOwn
	end
	return a.order > b.order
end

-- the bar a Hunter ends up with: what they saved, where it's still usable, and otherwise the
-- best unlocked move for the slot. Returns { [slot] = id }.
function Abilities.resolveBar(class: string?, saved: any, has: any, rank: number?): { [string]: string }
	local out = {}
	if not class then
		return out
	end
	local check = hasOf(has)
	for _, slot in Abilities.SLOTS do
		local want = type(saved) == "table" and saved[slot] or nil
		local ab = type(want) == "string" and Abilities.byId[want] or nil
		if ab and ab.slot == slot and Abilities.usable(ab, class, check, rank) then
			out[slot] = ab.id
		else
			local best = nil
			for _, cand in list do
				if cand.slot == slot and Abilities.usable(cand, class, check, rank) and better(cand, best, class) then
					best = cand
				end
			end
			if best then
				out[slot] = best.id
			end
		end
	end
	return out
end

-- the loadout panel's groups: { id, name, kind = "class" | "school" | "art" | "craft" }
function Abilities.groups(): { any }
	local out = {}
	for _, c in Abilities.CLASSES do
		table.insert(out, { id = c, name = string.upper(string.sub(c, 1, 1)) .. string.sub(c, 2), kind = "class" })
	end
	for _, s in Abilities.SCHOOLS do
		table.insert(out, { id = s.id, name = s.name, kind = "school" })
	end
	for _, a in Abilities.ARTS do
		table.insert(out, { id = a.id, name = a.name, kind = "art" })
	end
	table.insert(out, { id = "craft", name = "Hunter Craft", kind = "craft" })
	for _, g in extraGroups do
		table.insert(out, g)
	end
	return out
end

-- an element colour as an RGB table ({ r, g, b }: this file needs no Roblox globals)
function Abilities.colorOf(element: string?, which: string?): { number }
	local e = Abilities.ELEMENTS[element or "mana"] or Abilities.ELEMENTS.mana
	return e[which or "core"] or e.core
end

-- the problems with the table (tests/abilities_check; an empty list means it's sound)
function Abilities.problems(): { string }
	local out = {}
	local seen, names = {}, {}
	local classSet = { any = true }
	for _, c in Abilities.CLASSES do
		classSet[c] = true
	end
	local groupSet = {}
	for _, g in Abilities.groups() do
		groupSet[g.id] = true
	end
	for _, ab in list do
		local where = "move " .. tostring(ab.id)
		if type(ab.id) ~= "string" or seen[ab.id] then
			table.insert(out, where .. ": missing or repeated id")
		end
		seen[ab.id] = true
		if type(ab.name) ~= "string" or names[string.lower(ab.name)] then
			table.insert(out, where .. ": missing or repeated name " .. tostring(ab.name))
		end
		names[string.lower(tostring(ab.name))] = true
		if not classSet[ab.class] then
			table.insert(out, where .. ": unknown class " .. tostring(ab.class))
		end
		for _, c in ab.classes or {} do
			if not classSet[c] or c == "any" then
				table.insert(out, where .. ": unknown class " .. tostring(c) .. " in classes")
			end
		end
		if not Abilities.SLOT_INFO[ab.slot] then
			table.insert(out, where .. ": unknown slot " .. tostring(ab.slot))
		end
		if not Abilities.ELEMENTS[ab.element] then
			table.insert(out, where .. ": unknown element " .. tostring(ab.element))
		end
		if not Abilities.KINDS[ab.kind] then
			table.insert(out, where .. ": unknown kind " .. tostring(ab.kind))
		end
		if not Abilities.SHAPES[ab.shape] then
			table.insert(out, where .. ": unknown shape " .. tostring(ab.shape))
		end
		if not groupSet[ab.group] then
			table.insert(out, where .. ": unknown group " .. tostring(ab.group))
		end
		if type(ab.desc) ~= "string" or #ab.desc < 8 then
			table.insert(out, where .. ": needs a description")
		end
		if type(ab.tier) ~= "number" or ab.tier < 1 or ab.tier > 6 or ab.tier % 1 ~= 0 then
			table.insert(out, where .. ": tier must be 1 (E) to 6 (S)")
		end
		if type(ab.cd) ~= "number" or ab.cd <= 0 or type(ab.mana) ~= "number" or ab.mana <= 0 or type(ab.cast) ~= "number" or ab.cast < 0 then
			table.insert(out, where .. ": needs a cooldown, a mana cost and a cast time")
		end
		if ab.unlock ~= nil and (type(ab.unlock) ~= "string" or string.sub(ab.unlock, 1, 3) ~= "sk_") then
			table.insert(out, where .. ": unlock must be a skill id (sk_...)")
		end
		if ab.class == "any" and ab.unlock == nil and ab.classes == nil then
			table.insert(out, where .. ": a move open to any class needs a skill or a list of classes")
		end
		if ab.center ~= nil and ab.center ~= "self" and ab.center ~= "front" and ab.center ~= "aim" and ab.center ~= "target" then
			table.insert(out, where .. ": center must be self, front, aim or target")
		end
		local needs = {
			projectile = { "range" }, dash = { "range" }, beam = { "range", "width" }, strike = { "range" },
			chain = { "range", "chains", "jump" }, zone = { "radius", "duration", "tick" }, buff = { "duration", "buff" },
			heal = { "radius", "heal" }, shield = { "guard", "duration" }, taunt = { "radius", "duration" },
			construct = { "duration", "tick", "construct" }, blink = { "range" }, aoe = {},
		}
		for _, k in needs[ab.kind] or {} do
			if ab[k] == nil then
				table.insert(out, where .. ": a " .. tostring(ab.kind) .. " needs " .. k)
			end
		end
		if ab.kind == "aoe" and ab.radius == nil and ab.range == nil then
			table.insert(out, where .. ": an aoe needs a radius or a range")
		end
		if ab.tick and ab.tick < 0.25 then
			table.insert(out, where .. ": nothing can tick faster than the server steps (0.25 s)")
		end
		if ab.guard ~= nil and (ab.guard <= 0 or ab.guard >= 1) then
			table.insert(out, where .. ": guard is the share of damage still taken (0..1)")
		end
		if ab.heal ~= nil and (ab.heal <= 0 or ab.heal > 1) then
			table.insert(out, where .. ": heal is a share of max health (0..1]")
		end
		if ab.slot == "G" and ab.cd < 30 then
			table.insert(out, where .. ": an ultimate needs a long cooldown")
		end
		if ab.power and (ab.power < 0.3 or ab.power > 2.2) then
			table.insert(out, where .. ": power is a small factor (0.3..2.2)")
		end
	end
	return out
end

return Abilities
